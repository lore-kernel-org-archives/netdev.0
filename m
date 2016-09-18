From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: [PATCH 1/2] rhashtable: Add rhlist interface
Date: Sun, 18 Sep 2016 21:53:53 +0800
Message-ID: <E1blcXZ-0001r9-LG@gondolin.me.apana.org.au>
References: <20160918135030.GA7062@gondor.apana.org.au>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The insecure_elasticity setting is an ugly wart brought out by
users who need to insert duplicate objects (that is, distinct
objects with identical keys) into the same table.

In fact, those users have a much bigger problem.  Once those
duplicate objects are inserted, they don't have an interface to
find them (unless you count the walker interface which walks
over the entire table).

Some users have resorted to doing a manual walk over the hash
table which is of course broken because they don't handle the
potential existence of multiple hash tables.  The result is that
they will break sporadically when they encounter a hash table
resize/rehash.

This patch provides a way out for those users, at the expense
of an extra pointer per object.  Essentially each object is now
a list of objects carrying the same key.  The hash table will
only see the lists so nothing changes as far as rhashtable is
concerned.

To use this new interface, you need to insert a struct rhlist_head
into your objects instead of struct rhash_head.  While the hash
table is unchanged, for type-safety you'll need to use struct
rhltable instead of struct rhashtable.  All the existing interfaces
have been duplicated for rhlist, including the hash table walker.

One missing feature is nulls marking because AFAIK the only potential
user of it does not need duplicate objects.  Should anyone need
this it shouldn't be too hard to add.

Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
---

 include/linux/rhashtable.h |  490 ++++++++++++++++++++++++++++++++++-----------
 lib/rhashtable.c           |  231 ++++++++++++++++-----
 2 files changed, 560 insertions(+), 161 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index fd82584..dc7bea6 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -1,7 +1,7 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
- * Copyright (c) 2015 Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
+ * Copyright (c) 2015-2016 Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
  * Copyright (c) 2014-2015 Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
  *
@@ -53,6 +53,11 @@ struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
 
+struct rhlist_head {
+	struct rhash_head		rhead;
+	struct rhlist_head __rcu	*next;
+};
+
 /**
  * struct bucket_table - Table of hash buckets
  * @size: Number of hash buckets
@@ -137,6 +142,7 @@ struct rhashtable_params {
  * @key_len: Key length for hashfn
  * @elasticity: Maximum chain length before rehash
  * @p: Configuration parameters
+ * @rhlist: True if this is an rhltable
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
  * @lock: Spin lock to protect walker list
@@ -147,12 +153,21 @@ struct rhashtable {
 	unsigned int			key_len;
 	unsigned int			elasticity;
 	struct rhashtable_params	p;
+	bool				rhlist;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
 	spinlock_t			lock;
 };
 
 /**
+ * struct rhltable - Hash table with duplicate objects in a list
+ * @ht: Underlying rhtable
+ */
+struct rhltable {
+	struct rhashtable ht;
+};
+
+/**
  * struct rhashtable_walker - Hash table walker
  * @list: List entry on list of walkers
  * @tbl: The table that we were walking over
@@ -163,9 +178,10 @@ struct rhashtable_walker {
 };
 
 /**
- * struct rhashtable_iter - Hash table iterator, fits into netlink cb
+ * struct rhashtable_iter - Hash table iterator
  * @ht: Table to iterate through
  * @p: Current pointer
+ * @list: Current hash list pointer
  * @walker: Associated rhashtable walker
  * @slot: Current slot
  * @skip: Number of entries to skip in slot
@@ -173,6 +189,7 @@ struct rhashtable_walker {
 struct rhashtable_iter {
 	struct rhashtable *ht;
 	struct rhash_head *p;
+	struct rhlist_head *list;
 	struct rhashtable_walker walker;
 	unsigned int slot;
 	unsigned int skip;
@@ -339,13 +356,11 @@ static inline int lockdep_rht_bucket_is_held(const struct bucket_table *tbl,
 
 int rhashtable_init(struct rhashtable *ht,
 		    const struct rhashtable_params *params);
+int rhltable_init(struct rhltable *hlt,
+		  const struct rhashtable_params *params);
 
-struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
-					    const void *key,
-					    struct rhash_head *obj,
-					    struct bucket_table *old_tbl,
-					    void **data);
-int rhashtable_insert_rehash(struct rhashtable *ht, struct bucket_table *tbl);
+void *rhashtable_insert_slow(struct rhashtable *ht, const void *key,
+			     struct rhash_head *obj);
 
 void rhashtable_walk_enter(struct rhashtable *ht,
 			   struct rhashtable_iter *iter);
@@ -507,6 +522,31 @@ void rhashtable_destroy(struct rhashtable *ht);
 	rht_for_each_entry_rcu_continue(tpos, pos, (tbl)->buckets[hash],\
 					tbl, hash, member)
 
+/**
+ * rhl_for_each_rcu - iterate over rcu hash table list
+ * @pos:	the &struct rlist_head to use as a loop cursor.
+ * @list:	the head of the list
+ *
+ * This hash chain list-traversal primitive should be used on the
+ * list returned by rhltable_lookup.
+ */
+#define rhl_for_each_rcu(pos, list)					\
+	for (pos = list; pos; pos = rcu_dereference_raw(pos->next))
+
+/**
+ * rhl_for_each_entry_rcu - iterate over rcu hash table list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rlist_head to use as a loop cursor.
+ * @list:	the head of the list
+ * @member:	name of the &struct rlist_head within the hashable struct.
+ *
+ * This hash chain list-traversal primitive should be used on the
+ * list returned by rhltable_lookup.
+ */
+#define rhl_for_each_entry_rcu(tpos, pos, list, member)			\
+	for (pos = list; pos && rht_entry(tpos, pos, member);		\
+	     pos = rcu_dereference_raw(pos->next))
+
 static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
 				     const void *obj)
 {
@@ -516,18 +556,8 @@ static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
 	return memcmp(ptr + ht->p.key_offset, arg->key, ht->p.key_len);
 }
 
-/**
- * rhashtable_lookup_fast - search hash table, inlined version
- * @ht:		hash table
- * @key:	the pointer to the key
- * @params:	hash table parameters
- *
- * Computes the hash value for the key and traverses the bucket chain looking
- * for a entry with an identical key. The first matching entry is returned.
- *
- * Returns the first entry on which the compare function returned true.
- */
-static inline void *rhashtable_lookup_fast(
+/* Internal function, do not use. */
+static inline struct rhash_head *__rhashtable_lookup(
 	struct rhashtable *ht, const void *key,
 	const struct rhashtable_params params)
 {
@@ -539,8 +569,6 @@ static inline void *rhashtable_lookup_fast(
 	struct rhash_head *he;
 	unsigned int hash;
 
-	rcu_read_lock();
-
 	tbl = rht_dereference_rcu(ht->tbl, ht);
 restart:
 	hash = rht_key_hashfn(ht, tbl, key, params);
@@ -549,8 +577,7 @@ restart:
 		    params.obj_cmpfn(&arg, rht_obj(ht, he)) :
 		    rhashtable_compare(&arg, rht_obj(ht, he)))
 			continue;
-		rcu_read_unlock();
-		return rht_obj(ht, he);
+		return he;
 	}
 
 	/* Ensure we see any new tables. */
@@ -559,96 +586,165 @@ restart:
 	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
 	if (unlikely(tbl))
 		goto restart;
-	rcu_read_unlock();
 
 	return NULL;
 }
 
+/**
+ * rhashtable_lookup - search hash table
+ * @ht:		hash table
+ * @key:	the pointer to the key
+ * @params:	hash table parameters
+ *
+ * Computes the hash value for the key and traverses the bucket chain looking
+ * for a entry with an identical key. The first matching entry is returned.
+ *
+ * This must only be called under the RCU read lock.
+ *
+ * Returns the first entry on which the compare function returned true.
+ */
+static inline void *rhashtable_lookup(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params)
+{
+	struct rhash_head *he = __rhashtable_lookup(ht, key, params);
+
+	return he ? rht_obj(ht, he) : NULL;
+}
+
+/**
+ * rhashtable_lookup_fast - search hash table, without RCU read lock
+ * @ht:		hash table
+ * @key:	the pointer to the key
+ * @params:	hash table parameters
+ *
+ * Computes the hash value for the key and traverses the bucket chain looking
+ * for a entry with an identical key. The first matching entry is returned.
+ *
+ * Only use this function when you have other mechanisms guaranteeing
+ * that the object won't go away after the RCU read lock is released.
+ *
+ * Returns the first entry on which the compare function returned true.
+ */
+static inline void *rhashtable_lookup_fast(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params)
+{
+	void *obj;
+
+	rcu_read_lock();
+	obj = rhashtable_lookup(ht, key, params);
+	rcu_read_unlock();
+
+	return obj;
+}
+
+/**
+ * rhltable_lookup - search hash list table
+ * @hlt:	hash table
+ * @key:	the pointer to the key
+ * @params:	hash table parameters
+ *
+ * Computes the hash value for the key and traverses the bucket chain looking
+ * for a entry with an identical key.  All matching entries are returned
+ * in a list.
+ *
+ * This must only be called under the RCU read lock.
+ *
+ * Returns the list of entries that match the given key.
+ */
+static inline struct rhlist_head *rhltable_lookup(
+	struct rhltable *hlt, const void *key,
+	const struct rhashtable_params params)
+{
+	struct rhash_head *he = __rhashtable_lookup(&hlt->ht, key, params);
+
+	return he ? container_of(he, struct rhlist_head, rhead) : NULL;
+}
+
 /* Internal function, please use rhashtable_insert_fast() instead. This
  * function returns the existing element already in hashes in there is a clash,
  * otherwise it returns an error via ERR_PTR().
  */
 static inline void *__rhashtable_insert_fast(
 	struct rhashtable *ht, const void *key, struct rhash_head *obj,
-	const struct rhashtable_params params)
+	const struct rhashtable_params params, bool rhlist)
 {
 	struct rhashtable_compare_arg arg = {
 		.ht = ht,
 		.key = key,
 	};
-	struct bucket_table *tbl, *new_tbl;
+	struct rhash_head __rcu **pprev;
+	struct bucket_table *tbl;
 	struct rhash_head *head;
 	spinlock_t *lock;
-	unsigned int elasticity;
 	unsigned int hash;
-	void *data = NULL;
-	int err;
+	int elasticity;
+	void *data;
 
-restart:
 	rcu_read_lock();
 
 	tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = rht_head_hashfn(ht, tbl, obj, params);
+	lock = rht_bucket_lock(tbl, hash);
+	spin_lock_bh(lock);
 
-	/* All insertions must grab the oldest table containing
-	 * the hashed bucket that is yet to be rehashed.
-	 */
-	for (;;) {
-		hash = rht_head_hashfn(ht, tbl, obj, params);
-		lock = rht_bucket_lock(tbl, hash);
-		spin_lock_bh(lock);
-
-		if (tbl->rehash <= hash)
-			break;
-
+	if (unlikely(rht_dereference_bucket(tbl->future_tbl, tbl, hash))) {
+slow_path:
 		spin_unlock_bh(lock);
-		tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+		rcu_read_unlock();
+		return rhashtable_insert_slow(ht, key, obj);
 	}
 
-	new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
-	if (unlikely(new_tbl)) {
-		tbl = rhashtable_insert_slow(ht, key, obj, new_tbl, &data);
-		if (!IS_ERR_OR_NULL(tbl))
-			goto slow_path;
+	elasticity = ht->elasticity;
+	pprev = &tbl->buckets[hash];
+	rht_for_each(head, tbl, hash) {
+		struct rhlist_head *plist;
+		struct rhlist_head *list;
+
+		elasticity--;
+		if (!key ||
+		    (params.obj_cmpfn ?
+		     params.obj_cmpfn(&arg, rht_obj(ht, head)) :
+		     rhashtable_compare(&arg, rht_obj(ht, head))))
+			continue;
+
+		data = rht_obj(ht, head);
 
-		err = PTR_ERR(tbl);
-		if (err == -EEXIST)
-			err = 0;
+		if (!rhlist)
+			goto out;
 
-		goto out;
-	}
 
-	err = -E2BIG;
-	if (unlikely(rht_grow_above_max(ht, tbl)))
-		goto out;
+		list = container_of(obj, struct rhlist_head, rhead);
+		plist = container_of(head, struct rhlist_head, rhead);
 
-	if (unlikely(rht_grow_above_100(ht, tbl))) {
-slow_path:
-		spin_unlock_bh(lock);
-		err = rhashtable_insert_rehash(ht, tbl);
-		rcu_read_unlock();
-		if (err)
-			return ERR_PTR(err);
+		RCU_INIT_POINTER(list->next, plist);
+		head = rht_dereference_bucket(head->next, tbl, hash);
+		RCU_INIT_POINTER(list->rhead.next, head);
+		rcu_assign_pointer(*pprev, obj);
 
-		goto restart;
+		goto good;
 	}
 
-	err = 0;
-	elasticity = ht->elasticity;
-	rht_for_each(head, tbl, hash) {
-		if (key &&
-		    unlikely(!(params.obj_cmpfn ?
-			       params.obj_cmpfn(&arg, rht_obj(ht, head)) :
-			       rhashtable_compare(&arg, rht_obj(ht, head))))) {
-			data = rht_obj(ht, head);
-			goto out;
-		}
-		if (!--elasticity)
-			goto slow_path;
-	}
+	if (elasticity <= 0)
+		goto slow_path;
+
+	data = ERR_PTR(-E2BIG);
+	if (unlikely(rht_grow_above_max(ht, tbl)))
+		goto out;
+
+	if (unlikely(rht_grow_above_100(ht, tbl)))
+		goto slow_path;
 
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
 
 	RCU_INIT_POINTER(obj->next, head);
+	if (rhlist) {
+		struct rhlist_head *list;
+
+		list = container_of(obj, struct rhlist_head, rhead);
+		RCU_INIT_POINTER(list->next, NULL);
+	}
 
 	rcu_assign_pointer(tbl->buckets[hash], obj);
 
@@ -656,11 +752,14 @@ slow_path:
 	if (rht_grow_above_75(ht, tbl))
 		schedule_work(&ht->run_work);
 
+good:
+	data = NULL;
+
 out:
 	spin_unlock_bh(lock);
 	rcu_read_unlock();
 
-	return err ? ERR_PTR(err) : data;
+	return data;
 }
 
 /**
@@ -685,7 +784,7 @@ static inline int rhashtable_insert_fast(
 {
 	void *ret;
 
-	ret = __rhashtable_insert_fast(ht, NULL, obj, params);
+	ret = __rhashtable_insert_fast(ht, NULL, obj, params, false);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 
@@ -693,6 +792,58 @@ static inline int rhashtable_insert_fast(
 }
 
 /**
+ * rhltable_insert_key - insert object into hash list table
+ * @hlt:	hash list table
+ * @key:	the pointer to the key
+ * @list:	pointer to hash list head inside object
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
+static inline int rhltable_insert_key(
+	struct rhltable *hlt, const void *key, struct rhlist_head *list,
+	const struct rhashtable_params params)
+{
+	return PTR_ERR(__rhashtable_insert_fast(&hlt->ht, key, &list->rhead,
+						params, true));
+}
+
+/**
+ * rhltable_insert - insert object into hash list table
+ * @hlt:	hash list table
+ * @list:	pointer to hash list head inside object
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
+static inline int rhltable_insert(
+	struct rhltable *hlt, struct rhlist_head *list,
+	const struct rhashtable_params params)
+{
+	const char *key = rht_obj(&hlt->ht, &list->rhead);
+
+	key += params.key_offset;
+
+	return rhltable_insert_key(hlt, key, list, params);
+}
+
+/**
  * rhashtable_lookup_insert_fast - lookup and insert object into hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
@@ -722,7 +873,8 @@ static inline int rhashtable_lookup_insert_fast(
 
 	BUG_ON(ht->p.obj_hashfn);
 
-	ret = __rhashtable_insert_fast(ht, key + ht->p.key_offset, obj, params);
+	ret = __rhashtable_insert_fast(ht, key + ht->p.key_offset, obj, params,
+				       false);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 
@@ -759,7 +911,7 @@ static inline int rhashtable_lookup_insert_key(
 
 	BUG_ON(!ht->p.obj_hashfn || !key);
 
-	ret = __rhashtable_insert_fast(ht, key, obj, params);
+	ret = __rhashtable_insert_fast(ht, key, obj, params, false);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 
@@ -783,13 +935,14 @@ static inline void *rhashtable_lookup_get_insert_key(
 {
 	BUG_ON(!ht->p.obj_hashfn || !key);
 
-	return __rhashtable_insert_fast(ht, key, obj, params);
+	return __rhashtable_insert_fast(ht, key, obj, params, false);
 }
 
 /* Internal function, please use rhashtable_remove_fast() instead */
-static inline int __rhashtable_remove_fast(
+static inline int __rhashtable_remove_fast_one(
 	struct rhashtable *ht, struct bucket_table *tbl,
-	struct rhash_head *obj, const struct rhashtable_params params)
+	struct rhash_head *obj, const struct rhashtable_params params,
+	bool rhlist)
 {
 	struct rhash_head __rcu **pprev;
 	struct rhash_head *he;
@@ -804,39 +957,65 @@ static inline int __rhashtable_remove_fast(
 
 	pprev = &tbl->buckets[hash];
 	rht_for_each(he, tbl, hash) {
+		struct rhlist_head *list;
+
+		list = container_of(he, struct rhlist_head, rhead);
+
 		if (he != obj) {
+			struct rhlist_head __rcu **lpprev;
+
 			pprev = &he->next;
-			continue;
+
+			if (!rhlist)
+				continue;
+
+			do {
+				lpprev = &list->next;
+				list = rht_dereference_bucket(list->next,
+							      tbl, hash);
+			} while (list && obj != &list->rhead);
+
+			if (!list)
+				continue;
+
+			list = rht_dereference_bucket(list->next, tbl, hash);
+			RCU_INIT_POINTER(*lpprev, list);
+			err = 0;
+			break;
 		}
 
-		rcu_assign_pointer(*pprev, obj->next);
-		err = 0;
+		obj = rht_dereference_bucket(obj->next, tbl, hash);
+
+		if (rhlist) {
+			list = rht_dereference_bucket(list->next, tbl, hash);
+			if (list) {
+				RCU_INIT_POINTER(list->rhead.next, obj);
+				obj = &list->rhead;
+			}
+		}
+
+		rcu_assign_pointer(*pprev, obj);
+		err = 1;
 		break;
 	}
 
 	spin_unlock_bh(lock);
 
+	if (err > 0) {
+		atomic_dec(&ht->nelems);
+		if (unlikely(ht->p.automatic_shrinking &&
+			     rht_shrink_below_30(ht, tbl)))
+			schedule_work(&ht->run_work);
+		err = 0;
+	}
+
 	return err;
 }
 
-/**
- * rhashtable_remove_fast - remove object from hash table
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- * @params:	hash table parameters
- *
- * Since the hash chain is single linked, the removal operation needs to
- * walk the bucket chain upon removal. The removal operation is thus
- * considerable slow if the hash table is not correctly sized.
- *
- * Will automatically shrink the table via rhashtable_expand() if the
- * shrink_decision function specified at rhashtable_init() returns true.
- *
- * Returns zero on success, -ENOENT if the entry could not be found.
- */
-static inline int rhashtable_remove_fast(
+/* Internal function, please use rhashtable_remove_fast() instead */
+static inline int __rhashtable_remove_fast(
 	struct rhashtable *ht, struct rhash_head *obj,
-	const struct rhashtable_params params)
+	const struct rhashtable_params params, bool rhlist)
 {
 	struct bucket_table *tbl;
 	int err;
@@ -850,24 +1029,60 @@ static inline int rhashtable_remove_fast(
 	 * visible then that guarantees the entry to still be in
 	 * the old tbl if it exists.
 	 */
-	while ((err = __rhashtable_remove_fast(ht, tbl, obj, params)) &&
+	while ((err = __rhashtable_remove_fast_one(ht, tbl, obj, params,
+						   rhlist)) &&
 	       (tbl = rht_dereference_rcu(tbl->future_tbl, ht)))
 		;
 
-	if (err)
-		goto out;
-
-	atomic_dec(&ht->nelems);
-	if (unlikely(ht->p.automatic_shrinking &&
-		     rht_shrink_below_30(ht, tbl)))
-		schedule_work(&ht->run_work);
-
-out:
 	rcu_read_unlock();
 
 	return err;
 }
 
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
+	return __rhashtable_remove_fast(ht, obj, params, false);
+}
+
+/**
+ * rhltable_remove - remove object from hash list table
+ * @hlt:	hash list table
+ * @list:	pointer to hash list head inside object
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
+static inline int rhltable_remove(
+	struct rhltable *hlt, struct rhlist_head *list,
+	const struct rhashtable_params params)
+{
+	return __rhashtable_remove_fast(&hlt->ht, &list->rhead, params, true);
+}
+
 /* Internal function, please use rhashtable_replace_fast() instead */
 static inline int __rhashtable_replace_fast(
 	struct rhashtable *ht, struct bucket_table *tbl,
@@ -958,4 +1173,51 @@ static inline int rhashtable_walk_init(struct rhashtable *ht,
 	return 0;
 }
 
+/**
+ * rhltable_walk_enter - Initialise an iterator
+ * @hlt:	Table to walk over
+ * @iter:	Hash table Iterator
+ *
+ * This function prepares a hash table walk.
+ *
+ * Note that if you restart a walk after rhashtable_walk_stop you
+ * may see the same object twice.  Also, you may miss objects if
+ * there are removals in between rhashtable_walk_stop and the next
+ * call to rhashtable_walk_start.
+ *
+ * For a completely stable walk you should construct your own data
+ * structure outside the hash table.
+ *
+ * This function may sleep so you must not call it from interrupt
+ * context or with spin locks held.
+ *
+ * You must call rhashtable_walk_exit after this function returns.
+ */
+static inline void rhltable_walk_enter(struct rhltable *hlt,
+				       struct rhashtable_iter *iter)
+{
+	return rhashtable_walk_enter(&hlt->ht, iter);
+}
+
+/**
+ * rhltable_free_and_destroy - free elements and destroy hash list table
+ * @hlt:	the hash list table to destroy
+ * @free_fn:	callback to release resources of element
+ * @arg:	pointer passed to free_fn
+ *
+ * See documentation for rhashtable_free_and_destroy.
+ */
+static inline void rhltable_free_and_destroy(struct rhltable *hlt,
+					     void (*free_fn)(void *ptr,
+							     void *arg),
+					     void *arg)
+{
+	return rhashtable_free_and_destroy(&hlt->ht, free_fn, arg);
+}
+
+static inline void rhltable_destroy(struct rhltable *hlt)
+{
+	return rhltable_free_and_destroy(hlt, NULL, NULL);
+}
+
 #endif /* _LINUX_RHASHTABLE_H */
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 06c2872..185fc14 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -378,22 +378,8 @@ static void rht_deferred_worker(struct work_struct *work)
 		schedule_work(&ht->run_work);
 }
 
-static bool rhashtable_check_elasticity(struct rhashtable *ht,
-					struct bucket_table *tbl,
-					unsigned int hash)
-{
-	unsigned int elasticity = ht->elasticity;
-	struct rhash_head *head;
-
-	rht_for_each(head, tbl, hash)
-		if (!--elasticity)
-			return true;
-
-	return false;
-}
-
-int rhashtable_insert_rehash(struct rhashtable *ht,
-			     struct bucket_table *tbl)
+static int rhashtable_insert_rehash(struct rhashtable *ht,
+				    struct bucket_table *tbl)
 {
 	struct bucket_table *old_tbl;
 	struct bucket_table *new_tbl;
@@ -439,57 +425,148 @@ fail:
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(rhashtable_insert_rehash);
 
-struct bucket_table *rhashtable_insert_slow(struct rhashtable *ht,
-					    const void *key,
-					    struct rhash_head *obj,
-					    struct bucket_table *tbl,
-					    void **data)
+static void *rhashtable_insert_one(struct rhashtable *ht,
+				   struct bucket_table *tbl, unsigned int hash,
+				   const void *key, struct rhash_head *obj)
 {
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
+	struct rhash_head __rcu **pprev;
+	struct rhash_head *head;
+	int elasticity;
+
+	elasticity = ht->elasticity;
+	pprev = &tbl->buckets[hash];
+	rht_for_each(head, tbl, hash) {
+		struct rhlist_head *list;
+		struct rhlist_head *plist;
+
+		elasticity--;
+		if (!key ||
+		    (ht->p.obj_cmpfn ?
+		     ht->p.obj_cmpfn(&arg, rht_obj(ht, head)) :
+		     rhashtable_compare(&arg, rht_obj(ht, head))))
+			continue;
+
+		if (!ht->rhlist)
+			return rht_obj(ht, head);
+
+		list = container_of(obj, struct rhlist_head, rhead);
+		plist = container_of(head, struct rhlist_head, rhead);
+
+		RCU_INIT_POINTER(list->next, plist);
+		head = rht_dereference_bucket(head->next, tbl, hash);
+		RCU_INIT_POINTER(list->rhead.next, head);
+		rcu_assign_pointer(*pprev, obj);
+
+		return NULL;
+	}
+
+	if (elasticity <= 0)
+		return ERR_PTR(-EAGAIN);
+
+	return ERR_PTR(-ENOENT);
+}
+
+static void *rhashtable_try_insert(struct rhashtable *ht, const void *key,
+				   struct rhash_head *obj)
+{
+	struct bucket_table *tbl;
 	struct rhash_head *head;
 	unsigned int hash;
-	int err;
+	spinlock_t *lock;
+	void *data;
 
-	tbl = rhashtable_last_table(ht, tbl);
-	hash = head_hashfn(ht, tbl, obj);
-	spin_lock_nested(rht_bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
-
-	err = -EEXIST;
-	if (key) {
-		*data = rhashtable_lookup_fast(ht, key, ht->p);
-		if (*data)
-			goto exit;
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	/* All insertions must grab the oldest table containing
+	 * the hashed bucket that is yet to be rehashed.
+	 */
+	for (;;) {
+		hash = rht_head_hashfn(ht, tbl, obj, ht->p);
+		lock = rht_bucket_lock(tbl, hash);
+		spin_lock_bh(lock);
+
+		if (tbl->rehash <= hash)
+			break;
+
+		spin_unlock_bh(lock);
+		tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	}
+
+	data = rhashtable_insert_one(ht, tbl, hash, key, obj);
+
+	while (PTR_ERR(data) == -ENOENT || PTR_ERR(data) == -EAGAIN) {
+		struct bucket_table *new_tbl;
+
+		new_tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+		if (!new_tbl)
+			break;
+
+		tbl = new_tbl;
+		hash = rht_head_hashfn(ht, tbl, obj, ht->p);
+		spin_lock_nested(rht_bucket_lock(tbl, hash),
+				 SINGLE_DEPTH_NESTING);
+
+		data = rhashtable_insert_one(ht, tbl, hash, key, obj);
+
+		spin_unlock(rht_bucket_lock(tbl, hash));
 	}
 
-	err = -E2BIG;
+	if (PTR_ERR(data) != -ENOENT)
+		goto exit;
+
+	data = ERR_PTR(-E2BIG);
 	if (unlikely(rht_grow_above_max(ht, tbl)))
 		goto exit;
 
-	err = -EAGAIN;
-	if (rhashtable_check_elasticity(ht, tbl, hash) ||
-	    rht_grow_above_100(ht, tbl))
+	data = ERR_PTR(-EAGAIN);
+	if (unlikely(rht_grow_above_100(ht, tbl)))
 		goto exit;
 
-	err = 0;
+	data = NULL;
 
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
 
 	RCU_INIT_POINTER(obj->next, head);
+	if (ht->rhlist) {
+		struct rhlist_head *list;
+
+		list = container_of(obj, struct rhlist_head, rhead);
+		RCU_INIT_POINTER(list->next, NULL);
+	}
 
 	rcu_assign_pointer(tbl->buckets[hash], obj);
 
 	atomic_inc(&ht->nelems);
+	if (rht_grow_above_75(ht, tbl))
+		schedule_work(&ht->run_work);
 
 exit:
-	spin_unlock(rht_bucket_lock(tbl, hash));
+	spin_unlock_bh(lock);
 
-	if (err == 0)
-		return NULL;
-	else if (err == -EAGAIN)
-		return tbl;
-	else
-		return ERR_PTR(err);
+	if (PTR_ERR(data) == -EAGAIN)
+		data = ERR_PTR(rhashtable_insert_rehash(ht, tbl) ?:
+			       -EAGAIN);
+
+	return data;
+}
+
+void *rhashtable_insert_slow(struct rhashtable *ht, const void *key,
+			     struct rhash_head *obj)
+{
+	void *data;
+
+	do {
+		rcu_read_lock();
+		data = rhashtable_try_insert(ht, key, obj);
+		rcu_read_unlock();
+	} while (PTR_ERR(data) == -EAGAIN);
+
+	return data;
 }
 EXPORT_SYMBOL_GPL(rhashtable_insert_slow);
 
@@ -593,11 +670,16 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_start);
 void *rhashtable_walk_next(struct rhashtable_iter *iter)
 {
 	struct bucket_table *tbl = iter->walker.tbl;
+	struct rhlist_head *list = iter->list;
 	struct rhashtable *ht = iter->ht;
 	struct rhash_head *p = iter->p;
+	bool rhlist = ht->rhlist;
 
 	if (p) {
-		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
+		if (!rhlist || !(list = rcu_dereference(list->next))) {
+			p = rcu_dereference(p->next);
+			list = container_of(p, struct rhlist_head, rhead);
+		}
 		goto next;
 	}
 
@@ -605,6 +687,18 @@ void *rhashtable_walk_next(struct rhashtable_iter *iter)
 		int skip = iter->skip;
 
 		rht_for_each_rcu(p, tbl, iter->slot) {
+			if (rhlist) {
+				list = container_of(p, struct rhlist_head,
+						    rhead);
+				do {
+					if (!skip)
+						goto next;
+					skip--;
+					list = rcu_dereference(list->next);
+				} while (list);
+
+				continue;
+			}
 			if (!skip)
 				break;
 			skip--;
@@ -614,7 +708,8 @@ next:
 		if (!rht_is_a_nulls(p)) {
 			iter->skip++;
 			iter->p = p;
-			return rht_obj(ht, p);
+			iter->list = list;
+			return rht_obj(ht, rhlist ? &list->rhead : p);
 		}
 
 		iter->skip = 0;
@@ -803,6 +898,48 @@ int rhashtable_init(struct rhashtable *ht,
 EXPORT_SYMBOL_GPL(rhashtable_init);
 
 /**
+ * rhltable_init - initialize a new hash list table
+ * @hlt:	hash list table to be initialized
+ * @params:	configuration parameters
+ *
+ * Initializes a new hash list table.
+ *
+ * See documentation for rhashtable_init.
+ */
+int rhltable_init(struct rhltable *hlt, const struct rhashtable_params *params)
+{
+	int err;
+
+	/* No rhlist NULLs marking for now. */
+	if (params->nulls_base)
+		return -EINVAL;
+
+	err = rhashtable_init(&hlt->ht, params);
+	hlt->ht.rhlist = true;
+	return err;
+}
+EXPORT_SYMBOL_GPL(rhltable_init);
+
+static void rhashtable_free_one(struct rhashtable *ht, struct rhash_head *obj,
+				void (*free_fn)(void *ptr, void *arg),
+				void *arg)
+{
+	struct rhlist_head *list;
+
+	if (!ht->rhlist) {
+		free_fn(rht_obj(ht, obj), arg);
+		return;
+	}
+
+	list = container_of(obj, struct rhlist_head, rhead);
+	do {
+		obj = &list->rhead;
+		list = rht_dereference(list->next, ht);
+		free_fn(rht_obj(ht, obj), arg);
+	} while (list);
+}
+
+/**
  * rhashtable_free_and_destroy - free elements and destroy hash table
  * @ht:		the hash table to destroy
  * @free_fn:	callback to release resources of element
@@ -839,7 +976,7 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
 			     pos = next,
 			     next = !rht_is_a_nulls(pos) ?
 					rht_dereference(pos->next, ht) : NULL)
-				free_fn(rht_obj(ht, pos), arg);
+				rhashtable_free_one(ht, pos, free_fn, arg);
 		}
 	}
 
