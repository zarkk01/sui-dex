module suidex::lock;

use sui::dynamic_object_field as dof;

public struct LockedObjectKey has copy, drop, store {}

public struct Locked<phantom T: key + store> has key, store {
    id: UID,
    key: ID,
}

public struct Key has key, store {
    id: UID,
}

public fun lock<T: key + store>(obj: T, ctx: &mut TxContext): (Locked<T>, Key) {
    let key: Key = Key {
        id: object::new(ctx),
    };

    let mut locked: Locked<T> = Locked {
        id: object::new(ctx),
        key: object::id(&key),
    };

    dof::add(&mut locked.id, LockedObjectKey {}, obj);

    (locked, key)
}

public fun unlock<T: key + store>(mut locked: Locked<T>, key: Key, ctx: &mut TxContext): T {
    assert!(object::id(&key) == locked.key);
    let Key { id } = key;
    id.delete();

    let obj = dof::remove(&mut locked.id, LockedObjectKey {});

    let Locked { id, key: _ } = locked;
    id.delete();
    (obj)
}
