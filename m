From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 8/14] rhashtable: Fix support of objects with no accessible keys
Date: Sun, 15 Mar 2015 21:44:33 +1100
Message-ID: <E1YX625-0005o9-F7@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52878 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbbCOKoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current support of so-called (a misnomer actually) vairable-
length keys is broken.  I found out about this after trying to
actually use it for netlink by incorporating the namespace into
the key.

The crux of the matter is that all the code that is needed to
make it work (such as netlink_lookup_insert_compare) only works
when key_len != 0.  However, the object hash function is only
used when key_len == 0.

In fact key_len should always be non-zero since even for these
objects with inaccessible keys, we need to use a key to perform
a table lookup.

This patch fixes this by directly using the object hash function
as the indicator of whether the key is accessible or not.  It
also adds a new function obj_cmpfn to compare a key against an
object.  This means that the caller no longer needs to supply
explicit compare functions.

All this is done in a backwards compatible manner so we can rip
out the existing users safely after this patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    5 +
 lib/rhashtable.c           |  158 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 143 insertions(+), 20 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 99425f2..de7ac49 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -74,6 +74,7 @@ struct bucket_table {
 
 typedef u32 (*rht_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 seed);
+typedef bool (*rht_obj_cmpfn_t)(const void *key, const void *obj);
 
 struct rhashtable;
 
@@ -89,6 +90,7 @@ struct rhashtable;
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
+ * @obj_cmpfn: Function to compare key with object
  */
 struct rhashtable_params {
 	size_t			nelem_hint;
@@ -101,6 +103,7 @@ struct rhashtable_params {
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
+	rht_obj_cmpfn_t		obj_cmpfn;
 };
 
 /**
@@ -198,6 +201,8 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 				      struct rhash_head *obj,
 				      bool (*compare)(void *, void *),
 				      void *arg);
+int rhashtable_lookup_insert_key(struct rhashtable *ht,
+				 const void *key, struct rhash_head *obj);
 
 int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter);
 void rhashtable_walk_exit(struct rhashtable_iter *iter);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a74ba72..8b3cae3 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -74,7 +74,7 @@ static u32 head_hashfn(struct rhashtable *ht,
 {
 	const char *ptr = rht_obj(ht, he);
 
-	return likely(ht->p.key_len) ?
+	return likely(!ht->p.obj_hashfn) ?
 	       key_hashfn(ht, tbl, ptr + ht->p.key_offset) :
 	       rht_bucket_index(tbl, ht->p.obj_hashfn(ptr, tbl->hash_rnd));
 }
@@ -376,6 +376,69 @@ unlock:
 	mutex_unlock(&ht->mutex);
 }
 
+static int __rhashtable_lookup_insert_key(struct rhashtable *ht,
+					  const void *key,
+					  struct rhash_head *obj)
+{
+	struct bucket_table *tbl, *old_tbl;
+	struct rhash_head *head;
+	bool no_resize_running;
+	unsigned hash;
+	int err = -EEXIST;
+
+	rcu_read_lock();
+
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = head_hashfn(ht, old_tbl, obj);
+
+	spin_lock_bh(bucket_lock(old_tbl, hash));
+
+	/* Because we have already taken the bucket lock in old_tbl,
+	 * if we find that future_tbl is not yet visible then that
+	 * guarantees all other insertions of the same entry will
+	 * also grab the bucket lock in old_tbl because until the
+	 * rehash completes ht->tbl won't be changed.
+	 */
+	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
+	if (tbl != old_tbl) {
+		hash = head_hashfn(ht, tbl, obj);
+		spin_lock_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
+	}
+
+	if (key && rhashtable_lookup(ht, key))
+		goto exit;
+
+	err = 0;
+
+	no_resize_running = tbl == old_tbl;
+
+	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+
+	if (rht_is_a_nulls(head))
+		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
+	else
+		RCU_INIT_POINTER(obj->next, head);
+
+	rcu_assign_pointer(tbl->buckets[hash], obj);
+
+	atomic_inc(&ht->nelems);
+	if (no_resize_running && rht_grow_above_75(ht, tbl))
+		schedule_work(&ht->run_work);
+
+exit:
+	if (tbl != old_tbl) {
+		hash = head_hashfn(ht, tbl, obj);
+		spin_unlock(bucket_lock(tbl, hash));
+	}
+
+	hash = head_hashfn(ht, old_tbl, obj);
+	spin_unlock_bh(bucket_lock(old_tbl, hash));
+
+	rcu_read_unlock();
+
+	return err;
+}
+
 static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 				bool (*compare)(void *, void *), void *arg)
 {
@@ -457,7 +520,9 @@ exit:
  */
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	__rhashtable_insert(ht, obj, NULL, NULL);
+	BUG_ON(ht->p.obj_hashfn);
+
+	__rhashtable_lookup_insert_key(ht, NULL, obj);
 }
 EXPORT_SYMBOL_GPL(rhashtable_insert);
 
@@ -543,9 +608,9 @@ struct rhashtable_compare_arg {
 	const void *key;
 };
 
-static bool rhashtable_compare(void *ptr, void *arg)
+static bool rhashtable_compare(const void *arg, const void *ptr)
 {
-	struct rhashtable_compare_arg *x = arg;
+	const struct rhashtable_compare_arg *x = arg;
 	struct rhashtable *ht = x->ht;
 
 	return !memcmp(ptr + ht->p.key_offset, x->key, ht->p.key_len);
@@ -559,9 +624,6 @@ static bool rhashtable_compare(void *ptr, void *arg)
  * Computes the hash value for the key and traverses the bucket chain looking
  * for a entry with an identical key. The first matching entry is returned.
  *
- * This lookup function may only be used for fixed key hash table (key_len
- * parameter set). It will BUG() if used inappropriately.
- *
  * Lookups may occur in parallel with hashtable mutations and resizing.
  */
 void *rhashtable_lookup(struct rhashtable *ht, const void *key)
@@ -570,10 +632,41 @@ void *rhashtable_lookup(struct rhashtable *ht, const void *key)
 		.ht = ht,
 		.key = key,
 	};
+	const struct bucket_table *tbl;
+	rht_obj_cmpfn_t compare;
+	const void *compare_key;
+	struct rhash_head *he;
+	u32 hash;
+
+	if (ht->p.obj_cmpfn) {
+		compare = ht->p.obj_cmpfn;
+		compare_key = key;
+	} else {
+		compare = rhashtable_compare;
+		compare_key = &arg;
+	}
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+restart:
+	hash = key_hashfn(ht, tbl, key);
+	rht_for_each_rcu(he, tbl, hash) {
+		if (!compare(compare_key, rht_obj(ht, he)))
+			continue;
+		rcu_read_unlock();
+		return rht_obj(ht, he);
+	}
 
-	BUG_ON(!ht->p.key_len);
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
+	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(tbl))
+		goto restart;
+	rcu_read_unlock();
 
-	return rhashtable_lookup_compare(ht, key, &rhashtable_compare, &arg);
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup);
 
@@ -644,15 +737,12 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
  */
 bool rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct rhashtable_compare_arg arg = {
-		.ht = ht,
-		.key = rht_obj(ht, obj) + ht->p.key_offset,
-	};
+	const char *key = rht_obj(ht, obj);
 
-	BUG_ON(!ht->p.key_len);
+	BUG_ON(ht->p.obj_hashfn);
+
+	return !__rhashtable_lookup_insert_key(ht, key + ht->p.key_offset, obj);
 
-	return rhashtable_lookup_compare_insert(ht, obj, &rhashtable_compare,
-						&arg);
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_insert);
 
@@ -681,13 +771,41 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 				      bool (*compare)(void *, void *),
 				      void *arg)
 {
-	BUG_ON(!ht->p.key_len);
-
 	return __rhashtable_insert(ht, obj, compare, arg);
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
 
 /**
+ * rhashtable_lookup_insert_key - search and insert object to hash table
+ *                                with explicit key
+ * @ht:		hash table
+ * @key:	key 
+ * @obj:	pointer to hash head inside object
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
+int rhashtable_lookup_insert_key(struct rhashtable *ht,
+				 const void *key, struct rhash_head *obj)
+{
+	BUG_ON(!ht->p.obj_hashfn || !key);
+
+	return __rhashtable_lookup_insert_key(ht, key, obj);
+}
+EXPORT_SYMBOL_GPL(rhashtable_lookup_insert_key);
+
+/**
  * rhashtable_walk_init - Initialise an iterator
  * @ht:		Table to walk over
  * @iter:	Hash table Iterator
@@ -925,8 +1043,8 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 
 	size = HASH_DEFAULT_SIZE;
 
-	if ((params->key_len && !params->hashfn) ||
-	    (!params->key_len && !params->obj_hashfn))
+	if (!params->hashfn || !params->key_len ||
+	    (params->obj_hashfn && !params->obj_cmpfn))
 		return -EINVAL;
 
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
