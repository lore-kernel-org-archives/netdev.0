From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 2/7] rhashtable: Allow hash/comparison functions to be inlined
Date: Fri, 20 Mar 2015 21:57:00 +1100
Message-ID: <E1YYubs-0004l5-Dt@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:58697 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbCTK5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch deals with the complaint that we make indirect function
calls on the fast paths unnecessarily in rhashtable.  We resolve
it by moving the fast paths into inline functions that take struct
rhashtable_param (which obviously must be the same set of parameters
supplied to rhashtable_init) as an argument.

The only remaining indirect call is to obj_hashfn (or key_hashfn it
obj_hashfn is unset) on the rehash as well as the insert-during-
rehash slow path.

This patch also extends the support of vairable-length keys to
include those where the key is fixed but scattered in the object.
For example, in netlink we want to key off the namespace and the
portid but they're not next to each other.

This patch does this by directly using the object hash function
as the indicator of whether the key is accessible or not.  It
also adds a new function obj_cmpfn to compare a key against an
object.  This means that the caller no longer needs to supply
explicit compare functions.

All this is done in a backwards compatible manner so no existing
users are affected until they convert to the new interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |  386 +++++++++++++++++++++++++++++++++++++++++++++
 lib/rhashtable.c           |  163 +++++--------------
 2 files changed, 436 insertions(+), 113 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index c85363c..2e221a1 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -22,6 +22,7 @@
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
+#include <linux/rcupdate.h>
 
 /*
  * The end of the chain is marked with a special nulls marks which has
@@ -42,6 +43,9 @@
 #define RHT_HASH_BITS		27
 #define RHT_BASE_SHIFT		RHT_HASH_BITS
 
+/* Base bits plus 1 bit for nulls marker */
+#define RHT_HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
+
 struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
@@ -72,8 +76,20 @@ struct bucket_table {
 	struct rhash_head __rcu	*buckets[] ____cacheline_aligned_in_smp;
 };
 
+/**
+ * struct rhashtable_compare_arg - Key for the function rhashtable_compare
+ * @ht: Hash table
+ * @key: Key to compare against
+ */
+struct rhashtable_compare_arg {
+	struct rhashtable *ht;
+	const void *key;
+};
+
 typedef u32 (*rht_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 seed);
+typedef int (*rht_obj_cmpfn_t)(struct rhashtable_compare_arg *arg,
+			       const void *obj);
 
 struct rhashtable;
 
@@ -89,6 +105,7 @@ struct rhashtable;
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
+ * @obj_cmpfn: Function to compare key with object
  */
 struct rhashtable_params {
 	size_t			nelem_hint;
@@ -101,6 +118,7 @@ struct rhashtable_params {
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
+	rht_obj_cmpfn_t		obj_cmpfn;
 };
 
 /**
@@ -165,6 +183,83 @@ static inline unsigned long rht_get_nulls_value(const struct rhash_head *ptr)
 	return ((unsigned long) ptr) >> 1;
 }
 
+static inline void *rht_obj(const struct rhashtable *ht,
+			    const struct rhash_head *he)
+{
+	return (char *)he - ht->p.head_offset;
+}
+
+static inline unsigned int rht_bucket_index(const struct bucket_table *tbl,
+					    unsigned int hash)
+{
+	return (hash >> RHT_HASH_RESERVED_SPACE) & (tbl->size - 1);
+}
+
+static inline unsigned int rht_key_hashfn(
+	struct rhashtable *ht, const struct bucket_table *tbl,
+	const void *key, const struct rhashtable_params params)
+{
+	return rht_bucket_index(tbl, params.hashfn(key, params.key_len ?:
+							ht->p.key_len,
+						   tbl->hash_rnd));
+}
+
+static inline unsigned int rht_head_hashfn(
+	struct rhashtable *ht, const struct bucket_table *tbl,
+	const struct rhash_head *he, const struct rhashtable_params params)
+{
+	const char *ptr = rht_obj(ht, he);
+
+	return likely(params.obj_hashfn) ?
+	       rht_bucket_index(tbl, params.obj_hashfn(ptr, tbl->hash_rnd)) :
+	       rht_key_hashfn(ht, tbl, ptr + params.key_offset, params);
+}
+
+/**
+ * rht_grow_above_75 - returns true if nelems > 0.75 * table-size
+ * @ht:		hash table
+ * @tbl:	current table
+ */
+static inline bool rht_grow_above_75(const struct rhashtable *ht,
+				     const struct bucket_table *tbl)
+{
+	/* Expand table when exceeding 75% load */
+	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
+	       (!ht->p.max_size || tbl->size < ht->p.max_size);
+}
+
+/**
+ * rht_shrink_below_30 - returns true if nelems < 0.3 * table-size
+ * @ht:		hash table
+ * @tbl:	current table
+ */
+static inline bool rht_shrink_below_30(const struct rhashtable *ht,
+				       const struct bucket_table *tbl)
+{
+	/* Shrink table beneath 30% load */
+	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
+	       tbl->size > ht->p.min_size;
+}
+
+/* The bucket lock is selected based on the hash and protects mutations
+ * on a group of hash buckets.
+ *
+ * A maximum of tbl->size/2 bucket locks is allocated. This ensures that
+ * a single lock always covers both buckets which may both contains
+ * entries which link to the same bucket of the old table during resizing.
+ * This allows to simplify the locking as locking the bucket in both
+ * tables during resize always guarantee protection.
+ *
+ * IMPORTANT: When holding the bucket lock of both the old and new table
+ * during expansions and shrinking, the old bucket lock must always be
+ * acquired first.
+ */
+static inline spinlock_t *rht_bucket_lock(const struct bucket_table *tbl,
+					  unsigned int hash)
+{
+	return &tbl->locks[hash & tbl->locks_mask];
+}
+
 #ifdef CONFIG_PROVE_LOCKING
 int lockdep_rht_mutex_is_held(struct rhashtable *ht);
 int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash);
@@ -184,6 +279,9 @@ static inline int lockdep_rht_bucket_is_held(const struct bucket_table *tbl,
 int rhashtable_init(struct rhashtable *ht,
 		    const struct rhashtable_params *params);
 
+int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
+			   struct rhash_head *obj,
+			   struct bucket_table *old_tbl);
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
 
@@ -356,4 +454,292 @@ void rhashtable_destroy(struct rhashtable *ht);
 	rht_for_each_entry_rcu_continue(tpos, pos, (tbl)->buckets[hash],\
 					tbl, hash, member)
 
+static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
+				     const void *obj)
+{
+	struct rhashtable *ht = arg->ht;
+	const char *ptr = obj;
+
+	return memcmp(ptr + ht->p.key_offset, arg->key, ht->p.key_len);
+}
+
+/**
+ * rhashtable_lookup_fast - search hash table, inlined version
+ * @ht:		hash table
+ * @key:	the pointer to the key
+ * @params:	hash table parameters
+ *
+ * Computes the hash value for the key and traverses the bucket chain looking
+ * for a entry with an identical key. The first matching entry is returned.
+ *
+ * Returns the first entry on which the compare function returned true.
+ */
+static inline void *rhashtable_lookup_fast(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params)
+{
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
+	const struct bucket_table *tbl;
+	struct rhash_head *he;
+	unsigned hash;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+restart:
+	hash = rht_key_hashfn(ht, tbl, key, params);
+	rht_for_each_rcu(he, tbl, hash) {
+		if (params.obj_cmpfn ?
+		    params.obj_cmpfn(&arg, rht_obj(ht, he)) :
+		    rhashtable_compare(&arg, rht_obj(ht, he)))
+			continue;
+		rcu_read_unlock();
+		return rht_obj(ht, he);
+	}
+
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
+	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(tbl))
+		goto restart;
+	rcu_read_unlock();
+
+	return NULL;
+}
+
+static inline int __rhashtable_insert_fast(
+	struct rhashtable *ht, const void *key, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
+	int err = -EEXIST;
+	struct bucket_table *tbl, *new_tbl;
+	struct rhash_head *head;
+	spinlock_t *lock;
+	unsigned hash;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = rht_head_hashfn(ht, tbl, obj, params);
+	lock = rht_bucket_lock(tbl, hash);
+
+	spin_lock_bh(lock);
+
+	/* Because we have already taken the bucket lock in tbl,
+	 * if we find that future_tbl is not yet visible then
+	 * that guarantees all other insertions of the same entry
+	 * will also grab the bucket lock in tbl because until
+	 * the rehash completes ht->tbl won't be changed.
+	 */
+	new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(new_tbl)) {
+		err = rhashtable_insert_slow(ht, key, obj, new_tbl);
+		goto out;
+	}
+
+	if (!key)
+		goto skip_lookup;
+
+	rht_for_each(head, tbl, hash) {
+		if (unlikely(!(params.obj_cmpfn ?
+			       params.obj_cmpfn(&arg, rht_obj(ht, head)) :
+			       rhashtable_compare(&arg, rht_obj(ht, head)))))
+			goto out;
+	}
+
+skip_lookup:
+	err = 0;
+
+	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+
+	RCU_INIT_POINTER(obj->next, head);
+
+	rcu_assign_pointer(tbl->buckets[hash], obj);
+
+	atomic_inc(&ht->nelems);
+	if (rht_grow_above_75(ht, tbl))
+		schedule_work(&ht->run_work);
+
+out:
+	spin_unlock_bh(lock);
+	rcu_read_unlock();
+
+	return err;
+}
+
+/**
+ * rhashtable_insert_fast - insert object into hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ * @params:	hash table parameters
+ *
+ * Will take a per bucket spinlock to protect against mutual mutations
+ * on the same bucket. Multiple insertions may occur in parallel unless
+ * they map to the same bucket lock.
+ *
+ * It is safe to call this function from atomic context.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
+ */
+static inline int rhashtable_insert_fast(
+	struct rhashtable *ht, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	return __rhashtable_insert_fast(ht, NULL, obj, params);
+}
+
+/**
+ * rhashtable_lookup_insert_fast - lookup and insert object into hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ * @params:	hash table parameters
+ *
+ * Locks down the bucket chain in both the old and new table if a resize
+ * is in progress to ensure that writers can't remove from the old table
+ * and can't insert to the new table during the atomic operation of search
+ * and insertion. Searches for duplicates in both the old and new table if
+ * a resize is in progress.
+ *
+ * This lookup function may only be used for fixed key hash table (key_len
+ * parameter set). It will BUG() if used inappropriately.
+ *
+ * It is safe to call this function from atomic context.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
+ */
+static inline int rhashtable_lookup_insert_fast(
+	struct rhashtable *ht, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	const char *key = rht_obj(ht, obj);
+
+	BUG_ON(ht->p.obj_hashfn);
+
+	return __rhashtable_insert_fast(ht, key + ht->p.key_offset, obj,
+					params);
+}
+
+/**
+ * rhashtable_lookup_insert_key - search and insert object to hash table
+ *				  with explicit key
+ * @ht:		hash table
+ * @key:	key 
+ * @obj:	pointer to hash head inside object
+ * @params:	hash table parameters
+ *
+ * Locks down the bucket chain in both the old and new table if a resize
+ * is in progress to ensure that writers can't remove from the old table
+ * and can't insert to the new table during the atomic operation of search
+ * and insertion. Searches for duplicates in both the old and new table if
+ * a resize is in progress.
+ *
+ * Lookups may occur in parallel with hashtable mutations and resizing.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
+ *
+ * Returns zero on success.
+ */
+static inline int rhashtable_lookup_insert_key(
+	struct rhashtable *ht, const void *key, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	BUG_ON(!ht->p.obj_hashfn || !key);
+
+	return __rhashtable_insert_fast(ht, key, obj, params);
+}
+
+static inline int __rhashtable_remove_fast(
+	struct rhashtable *ht, struct bucket_table *tbl,
+	struct rhash_head *obj, const struct rhashtable_params params)
+{
+	struct rhash_head __rcu **pprev;
+	struct rhash_head *he;
+	spinlock_t * lock;
+	unsigned hash;
+	int err = -ENOENT;
+
+	hash = rht_head_hashfn(ht, tbl, obj, params);
+	lock = rht_bucket_lock(tbl, hash);
+
+	spin_lock_bh(lock);
+
+	pprev = &tbl->buckets[hash];
+	rht_for_each(he, tbl, hash) {
+		if (he != obj) {
+			pprev = &he->next;
+			continue;
+		}
+
+		rcu_assign_pointer(*pprev, obj->next);
+		err = 0;
+		break;
+	}
+
+	spin_unlock_bh(lock);
+
+	return err;
+}
+
+/**
+ * rhashtable_remove_fast - remove object from hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ * @params:	hash table parameters
+ *
+ * Since the hash chain is single linked, the removal operation needs to
+ * walk the bucket chain upon removal. The removal operation is thus
+ * considerable slow if the hash table is not correctly sized.
+ *
+ * Will automatically shrink the table via rhashtable_expand() if the
+ * shrink_decision function specified at rhashtable_init() returns true.
+ *
+ * Returns zero on success, -ENOENT if the entry could not be found.
+ */
+static inline int rhashtable_remove_fast(
+	struct rhashtable *ht, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	struct bucket_table *tbl;
+	int err;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	/* Because we have already taken (and released) the bucket
+	 * lock in old_tbl, if we find that future_tbl is not yet
+	 * visible then that guarantees the entry to still be in
+	 * the old tbl if it exists.
+	 */
+	while ((err = __rhashtable_remove_fast(ht, tbl, obj, params)) &&
+	       (tbl = rht_dereference_rcu(tbl->future_tbl, ht)))
+		;
+
+	if (err)
+		goto out;
+
+	atomic_dec(&ht->nelems);
+	if (rht_shrink_below_30(ht, tbl))
+		schedule_work(&ht->run_work);
+
+out:
+	rcu_read_unlock();
+
+	return err;
+}
+
 #endif /* _LINUX_RHASHTABLE_H */
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e0a9d59..d1d23fb 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -1,13 +1,13 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
+ * Copyright (c) 2015 Herbert Xu <herbert@gondor.apana.org.au>
  * Copyright (c) 2014-2015 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
- * Based on the following paper:
- * https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
- *
  * Code partially derived from nft_hash
+ * Rewritten with rehash code from br_multicast plus single list
+ * pointer as suggested by Josh Triplett
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -30,53 +30,11 @@
 #define HASH_MIN_SIZE		4U
 #define BUCKET_LOCKS_PER_CPU   128UL
 
-/* Base bits plus 1 bit for nulls marker */
-#define HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
-
-/* The bucket lock is selected based on the hash and protects mutations
- * on a group of hash buckets.
- *
- * A maximum of tbl->size/2 bucket locks is allocated. This ensures that
- * a single lock always covers both buckets which may both contains
- * entries which link to the same bucket of the old table during resizing.
- * This allows to simplify the locking as locking the bucket in both
- * tables during resize always guarantee protection.
- *
- * IMPORTANT: When holding the bucket lock of both the old and new table
- * during expansions and shrinking, the old bucket lock must always be
- * acquired first.
- */
-static spinlock_t *bucket_lock(const struct bucket_table *tbl, u32 hash)
-{
-	return &tbl->locks[hash & tbl->locks_mask];
-}
-
-static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
-{
-	return (void *) he - ht->p.head_offset;
-}
-
-static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
-{
-	return (hash >> HASH_RESERVED_SPACE) & (tbl->size - 1);
-}
-
-static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
-		      const void *key)
-{
-	return rht_bucket_index(tbl, ht->p.hashfn(key, ht->p.key_len,
-						  tbl->hash_rnd));
-}
-
 static u32 head_hashfn(struct rhashtable *ht,
 		       const struct bucket_table *tbl,
 		       const struct rhash_head *he)
 {
-	const char *ptr = rht_obj(ht, he);
-
-	return likely(ht->p.key_len) ?
-	       key_hashfn(ht, tbl, ptr + ht->p.key_offset) :
-	       rht_bucket_index(tbl, ht->p.obj_hashfn(ptr, tbl->hash_rnd));
+	return rht_head_hashfn(ht, tbl, he, ht->p);
 }
 
 #ifdef CONFIG_PROVE_LOCKING
@@ -90,7 +48,7 @@ EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
 
 int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash)
 {
-	spinlock_t *lock = bucket_lock(tbl, hash);
+	spinlock_t *lock = rht_bucket_lock(tbl, hash);
 
 	return (debug_locks) ? lockdep_is_held(lock) : 1;
 }
@@ -178,32 +136,6 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 	return tbl;
 }
 
-/**
- * rht_grow_above_75 - returns true if nelems > 0.75 * table-size
- * @ht:		hash table
- * @tbl:	current table
- */
-static bool rht_grow_above_75(const struct rhashtable *ht,
-			      const struct bucket_table *tbl)
-{
-	/* Expand table when exceeding 75% load */
-	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
-	       (!ht->p.max_size || tbl->size < ht->p.max_size);
-}
-
-/**
- * rht_shrink_below_30 - returns true if nelems < 0.3 * table-size
- * @ht:		hash table
- * @tbl:	current table
- */
-static bool rht_shrink_below_30(const struct rhashtable *ht,
-				const struct bucket_table *tbl)
-{
-	/* Shrink table beneath 30% load */
-	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
-	       tbl->size > ht->p.min_size;
-}
-
 static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 {
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
@@ -230,7 +162,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 
 	new_hash = head_hashfn(ht, new_tbl, entry);
 
-	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+	new_bucket_lock = rht_bucket_lock(new_tbl, new_hash);
 
 	spin_lock_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
 	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
@@ -255,7 +187,7 @@ static void rhashtable_rehash_chain(struct rhashtable *ht, unsigned old_hash)
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	spinlock_t *old_bucket_lock;
 
-	old_bucket_lock = bucket_lock(old_tbl, old_hash);
+	old_bucket_lock = rht_bucket_lock(old_tbl, old_hash);
 
 	spin_lock_bh(old_bucket_lock);
 	while (!rhashtable_rehash_one(ht, old_hash))
@@ -376,6 +308,37 @@ unlock:
 	mutex_unlock(&ht->mutex);
 }
 
+int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
+			   struct rhash_head *obj,
+			   struct bucket_table *tbl)
+{
+	struct rhash_head *head;
+	unsigned hash;
+	int err = -EEXIST;
+
+	hash = head_hashfn(ht, tbl, obj);
+	spin_lock_nested(rht_bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
+
+	if (key && rhashtable_lookup_fast(ht, key, ht->p))
+		goto exit;
+
+	err = 0;
+
+	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+
+	RCU_INIT_POINTER(obj->next, head);
+
+	rcu_assign_pointer(tbl->buckets[hash], obj);
+
+	atomic_inc(&ht->nelems);
+
+exit:
+	spin_unlock(rht_bucket_lock(tbl, hash));
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(rhashtable_insert_slow);
+
 static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 				bool (*compare)(void *, void *), void *arg)
 {
@@ -390,7 +353,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
 	hash = head_hashfn(ht, old_tbl, obj);
-	old_lock = bucket_lock(old_tbl, hash);
+	old_lock = rht_bucket_lock(old_tbl, hash);
 
 	spin_lock_bh(old_lock);
 
@@ -403,7 +366,8 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
 	if (tbl != old_tbl) {
 		hash = head_hashfn(ht, tbl, obj);
-		spin_lock_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
+		spin_lock_nested(rht_bucket_lock(tbl, hash),
+				 SINGLE_DEPTH_NESTING);
 	}
 
 	if (compare &&
@@ -430,7 +394,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 
 exit:
 	if (tbl != old_tbl)
-		spin_unlock(bucket_lock(tbl, hash));
+		spin_unlock(rht_bucket_lock(tbl, hash));
 
 	spin_unlock_bh(old_lock);
 
@@ -471,7 +435,7 @@ static bool __rhashtable_remove(struct rhashtable *ht,
 	bool ret = false;
 
 	hash = head_hashfn(ht, tbl, obj);
-	lock = bucket_lock(tbl, hash);
+	lock = rht_bucket_lock(tbl, hash);
 
 	spin_lock_bh(lock);
 
@@ -537,19 +501,6 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 }
 EXPORT_SYMBOL_GPL(rhashtable_remove);
 
-struct rhashtable_compare_arg {
-	struct rhashtable *ht;
-	const void *key;
-};
-
-static bool rhashtable_compare(void *ptr, void *arg)
-{
-	struct rhashtable_compare_arg *x = arg;
-	struct rhashtable *ht = x->ht;
-
-	return !memcmp(ptr + ht->p.key_offset, x->key, ht->p.key_len);
-}
-
 /**
  * rhashtable_lookup - lookup key in hash table
  * @ht:		hash table
@@ -565,14 +516,7 @@ static bool rhashtable_compare(void *ptr, void *arg)
  */
 void *rhashtable_lookup(struct rhashtable *ht, const void *key)
 {
-	struct rhashtable_compare_arg arg = {
-		.ht = ht,
-		.key = key,
-	};
-
-	BUG_ON(!ht->p.key_len);
-
-	return rhashtable_lookup_compare(ht, key, &rhashtable_compare, &arg);
+	return rhashtable_lookup_fast(ht, key, ht->p);
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup);
 
@@ -591,7 +535,8 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
  * Returns the first entry on which the compare function returned true.
  */
 void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
-				bool (*compare)(void *, void *), void *arg)
+				bool (*compare)(void *, void *),
+				void *arg)
 {
 	const struct bucket_table *tbl;
 	struct rhash_head *he;
@@ -601,7 +546,7 @@ void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 
 	tbl = rht_dereference_rcu(ht->tbl, ht);
 restart:
-	hash = key_hashfn(ht, tbl, key);
+	hash = rht_key_hashfn(ht, tbl, key, ht->p);
 	rht_for_each_rcu(he, tbl, hash) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
@@ -643,15 +588,7 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
  */
 bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct rhashtable_compare_arg arg = {
-		.ht = ht,
-		.key = rht_obj(ht, obj) + ht->p.key_offset,
-	};
-
-	BUG_ON(!ht->p.key_len);
-
-	return rhashtable_lookup_compare_insert(ht, obj, &rhashtable_compare,
-						&arg);
+	return rhashtable_lookup_insert_fast(ht, obj, ht->p);
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
 
@@ -927,8 +864,8 @@ int rhashtable_init(struct rhashtable *ht,
 
 	size = HASH_DEFAULT_SIZE;
 
-	if ((params->key_len && !params->hashfn) ||
-	    (!params->key_len && !params->obj_hashfn))
+	if ((!(params->key_len && params->hashfn) && !params->obj_hashfn) ||
+	    (params->obj_hashfn && !params->obj_cmpfn))
 		return -EINVAL;
 
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
