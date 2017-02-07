From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] rhashtable: Add nested tables
Date: Tue, 07 Feb 2017 20:39:45 +0800
Message-ID: <E1cb53h-0003qD-No@gondobar>
References: <20170207123827.GA14678@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60785 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754081AbdBGMj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 07:39:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code that handles GFP_ATOMIC kmalloc failure on
insertion.  As we cannot use vmalloc, we solve it by making our
hash table nested.  That is, we allocate single pages at each level
and reach our desired table size by nesting them.

When a nested table is created, only a single page is allocated
at the top-level.  Lower levels are allocated on demand during
insertion.  Therefore for each insertion to succeed, only two
(non-consecutive) pages are needed.

After a nested table is created, a rehash will be scheduled in
order to switch to a vmalloced table as soon as possible.  Also,
the rehash code will never rehash into a nested table.  If we
detect a nested table during a rehash, the rehash will be aborted
and a new rehash will be scheduled.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   78 +++++++++----
 lib/rhashtable.c           |  269 ++++++++++++++++++++++++++++++++++++---------
 2 files changed, 275 insertions(+), 72 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 5c132d3..f2e12a8 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -61,6 +61,7 @@ struct rhlist_head {
 /**
  * struct bucket_table - Table of hash buckets
  * @size: Number of hash buckets
+ * @nest: Number of bits of first-level nested table.
  * @rehash: Current bucket being rehashed
  * @hash_rnd: Random seed to fold into hash
  * @locks_mask: Mask to apply before accessing locks[]
@@ -68,10 +69,12 @@ struct rhlist_head {
  * @walkers: List of active walkers
  * @rcu: RCU structure for freeing the table
  * @future_tbl: Table under construction during rehashing
+ * @ntbl: Nested table used when out of memory.
  * @buckets: size * hash buckets
  */
 struct bucket_table {
 	unsigned int		size;
+	unsigned int		nest;
 	unsigned int		rehash;
 	u32			hash_rnd;
 	unsigned int		locks_mask;
@@ -81,7 +84,7 @@ struct bucket_table {
 
 	struct bucket_table __rcu *future_tbl;
 
-	struct rhash_head __rcu	*buckets[] ____cacheline_aligned_in_smp;
+	struct rhash_head __rcu *buckets[] ____cacheline_aligned_in_smp;
 };
 
 /**
@@ -374,6 +377,12 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
 				 void *arg);
 void rhashtable_destroy(struct rhashtable *ht);
 
+struct rhash_head __rcu **rht_bucket_nested(const struct bucket_table *tbl,
+					    unsigned int hash);
+struct rhash_head __rcu **rht_bucket_nested_insert(struct rhashtable *ht,
+						   struct bucket_table *tbl,
+						   unsigned int hash);
+
 #define rht_dereference(p, ht) \
 	rcu_dereference_protected(p, lockdep_rht_mutex_is_held(ht))
 
@@ -389,6 +398,27 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
 #define rht_entry(tpos, pos, member) \
 	({ tpos = container_of(pos, typeof(*tpos), member); 1; })
 
+static inline struct rhash_head __rcu *const *rht_bucket(
+	const struct bucket_table *tbl, unsigned int hash)
+{
+	return unlikely(tbl->nest) ? rht_bucket_nested(tbl, hash) :
+				     &tbl->buckets[hash];
+}
+
+static inline struct rhash_head __rcu **rht_bucket_var(
+	struct bucket_table *tbl, unsigned int hash)
+{
+	return unlikely(tbl->nest) ? rht_bucket_nested(tbl, hash) :
+				     &tbl->buckets[hash];
+}
+
+static inline struct rhash_head __rcu **rht_bucket_insert(
+	struct rhashtable *ht, struct bucket_table *tbl, unsigned int hash)
+{
+	return unlikely(tbl->nest) ? rht_bucket_nested_insert(ht, tbl, hash) :
+				     &tbl->buckets[hash];
+}
+
 /**
  * rht_for_each_continue - continue iterating over hash chain
  * @pos:	the &struct rhash_head to use as a loop cursor.
@@ -408,7 +438,7 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
  * @hash:	the hash value / bucket index
  */
 #define rht_for_each(pos, tbl, hash) \
-	rht_for_each_continue(pos, (tbl)->buckets[hash], tbl, hash)
+	rht_for_each_continue(pos, *rht_bucket(tbl, hash), tbl, hash)
 
 /**
  * rht_for_each_entry_continue - continue iterating over hash chain
@@ -433,7 +463,7 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
  * @member:	name of the &struct rhash_head within the hashable struct.
  */
 #define rht_for_each_entry(tpos, pos, tbl, hash, member)		\
-	rht_for_each_entry_continue(tpos, pos, (tbl)->buckets[hash],	\
+	rht_for_each_entry_continue(tpos, pos, *rht_bucket(tbl, hash),	\
 				    tbl, hash, member)
 
 /**
@@ -448,13 +478,13 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
  * This hash chain list-traversal primitive allows for the looped code to
  * remove the loop cursor from the list.
  */
-#define rht_for_each_entry_safe(tpos, pos, next, tbl, hash, member)	    \
-	for (pos = rht_dereference_bucket((tbl)->buckets[hash], tbl, hash), \
-	     next = !rht_is_a_nulls(pos) ?				    \
-		       rht_dereference_bucket(pos->next, tbl, hash) : NULL; \
-	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	    \
-	     pos = next,						    \
-	     next = !rht_is_a_nulls(pos) ?				    \
+#define rht_for_each_entry_safe(tpos, pos, next, tbl, hash, member)	      \
+	for (pos = rht_dereference_bucket(*rht_bucket(tbl, hash), tbl, hash), \
+	     next = !rht_is_a_nulls(pos) ?				      \
+		       rht_dereference_bucket(pos->next, tbl, hash) : NULL;   \
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	      \
+	     pos = next,						      \
+	     next = !rht_is_a_nulls(pos) ?				      \
 		       rht_dereference_bucket(pos->next, tbl, hash) : NULL)
 
 /**
@@ -485,7 +515,7 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
  * traversal is guarded by rcu_read_lock().
  */
 #define rht_for_each_rcu(pos, tbl, hash)				\
-	rht_for_each_rcu_continue(pos, (tbl)->buckets[hash], tbl, hash)
+	rht_for_each_rcu_continue(pos, *rht_bucket(tbl, hash), tbl, hash)
 
 /**
  * rht_for_each_entry_rcu_continue - continue iterating over rcu hash chain
@@ -518,8 +548,8 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
  * the _rcu mutation primitives such as rhashtable_insert() as long as the
  * traversal is guarded by rcu_read_lock().
  */
-#define rht_for_each_entry_rcu(tpos, pos, tbl, hash, member)		\
-	rht_for_each_entry_rcu_continue(tpos, pos, (tbl)->buckets[hash],\
+#define rht_for_each_entry_rcu(tpos, pos, tbl, hash, member)		   \
+	rht_for_each_entry_rcu_continue(tpos, pos, *rht_bucket(tbl, hash), \
 					tbl, hash, member)
 
 /**
@@ -565,7 +595,7 @@ static inline struct rhash_head *__rhashtable_lookup(
 		.ht = ht,
 		.key = key,
 	};
-	const struct bucket_table *tbl;
+	struct bucket_table *tbl;
 	struct rhash_head *he;
 	unsigned int hash;
 
@@ -697,8 +727,12 @@ static inline void *__rhashtable_insert_fast(
 	}
 
 	elasticity = ht->elasticity;
-	pprev = &tbl->buckets[hash];
-	rht_for_each(head, tbl, hash) {
+	pprev = rht_bucket_insert(ht, tbl, hash);
+	data = ERR_PTR(-ENOMEM);
+	if (!pprev)
+		goto out;
+
+	rht_for_each_continue(head, *pprev, tbl, hash) {
 		struct rhlist_head *plist;
 		struct rhlist_head *list;
 
@@ -736,7 +770,7 @@ static inline void *__rhashtable_insert_fast(
 	if (unlikely(rht_grow_above_100(ht, tbl)))
 		goto slow_path;
 
-	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	head = rht_dereference_bucket(*pprev, tbl, hash);
 
 	RCU_INIT_POINTER(obj->next, head);
 	if (rhlist) {
@@ -746,7 +780,7 @@ static inline void *__rhashtable_insert_fast(
 		RCU_INIT_POINTER(list->next, NULL);
 	}
 
-	rcu_assign_pointer(tbl->buckets[hash], obj);
+	rcu_assign_pointer(*pprev, obj);
 
 	atomic_inc(&ht->nelems);
 	if (rht_grow_above_75(ht, tbl))
@@ -955,8 +989,8 @@ static inline int __rhashtable_remove_fast_one(
 
 	spin_lock_bh(lock);
 
-	pprev = &tbl->buckets[hash];
-	rht_for_each(he, tbl, hash) {
+	pprev = rht_bucket_var(tbl, hash);
+	rht_for_each_continue(he, *pprev, tbl, hash) {
 		struct rhlist_head *list;
 
 		list = container_of(he, struct rhlist_head, rhead);
@@ -1107,8 +1141,8 @@ static inline int __rhashtable_replace_fast(
 
 	spin_lock_bh(lock);
 
-	pprev = &tbl->buckets[hash];
-	rht_for_each(he, tbl, hash) {
+	pprev = rht_bucket_var(tbl, hash);
+	rht_for_each_continue(he, *pprev, tbl, hash) {
 		if (he != obj_old) {
 			pprev = &he->next;
 			continue;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 32d0ad0..38485e8 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -32,6 +32,11 @@
 #define HASH_MIN_SIZE		4U
 #define BUCKET_LOCKS_PER_CPU	32UL
 
+union nested_table {
+	union nested_table __rcu *table;
+	struct rhash_head __rcu *bucket;
+};
+
 static u32 head_hashfn(struct rhashtable *ht,
 		       const struct bucket_table *tbl,
 		       const struct rhash_head *he)
@@ -76,6 +81,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 	/* Never allocate more than 0.5 locks per bucket */
 	size = min_t(unsigned int, size, tbl->size >> 1);
 
+	if (tbl->nest)
+		size = min(size, 1U << tbl->nest);
+
 	if (sizeof(spinlock_t) != 0) {
 		tbl->locks = NULL;
 #ifdef CONFIG_NUMA
@@ -99,8 +107,45 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 	return 0;
 }
 
+static void nested_table_free(union nested_table *ntbl, unsigned int size)
+{
+	const unsigned int shift = PAGE_SHIFT - ilog2(sizeof(void *));
+	const unsigned int len = 1 << shift;
+	unsigned int i;
+
+	ntbl = rcu_dereference_raw(ntbl->table);
+	if (!ntbl)
+		return;
+
+	if (size > len) {
+		size >>= shift;
+		for (i = 0; i < len; i++)
+			nested_table_free(ntbl + i, size);
+	}
+
+	kfree(ntbl);
+}
+
+static void nested_bucket_table_free(const struct bucket_table *tbl)
+{
+	unsigned int size = tbl->size >> tbl->nest;
+	unsigned int len = 1 << tbl->nest;
+	union nested_table *ntbl;
+	unsigned int i;
+
+	ntbl = (union nested_table *)rcu_dereference_raw(tbl->buckets[0]);
+
+	for (i = 0; i < len; i++)
+		nested_table_free(ntbl + i, size);
+
+	kfree(ntbl);
+}
+
 static void bucket_table_free(const struct bucket_table *tbl)
 {
+	if (tbl->nest)
+		nested_bucket_table_free(tbl);
+
 	if (tbl)
 		kvfree(tbl->locks);
 
@@ -112,6 +157,59 @@ static void bucket_table_free_rcu(struct rcu_head *head)
 	bucket_table_free(container_of(head, struct bucket_table, rcu));
 }
 
+static union nested_table *nested_table_alloc(struct rhashtable *ht,
+					      union nested_table __rcu **prev,
+					      unsigned int shifted,
+					      unsigned int nhash)
+{
+	union nested_table *ntbl;
+	int i;
+
+	ntbl = rcu_dereference(*prev);
+	if (ntbl)
+		return ntbl;
+
+	ntbl = kzalloc(PAGE_SIZE, GFP_ATOMIC);
+
+	if (ntbl && shifted) {
+		for (i = 0; i < PAGE_SIZE / sizeof(ntbl[0].bucket); i++)
+			INIT_RHT_NULLS_HEAD(ntbl[i].bucket, ht,
+					    (i << shifted) | nhash);
+	}
+
+	rcu_assign_pointer(*prev, ntbl);
+
+	return ntbl;
+}
+
+static struct bucket_table *nested_bucket_table_alloc(struct rhashtable *ht,
+						      size_t nbuckets,
+						      gfp_t gfp)
+{
+	const unsigned int shift = PAGE_SHIFT - ilog2(sizeof(void *));
+	struct bucket_table *tbl;
+	size_t size;
+
+	if (nbuckets < (1 << (shift + 1)))
+		return NULL;
+
+	size = sizeof(*tbl) + sizeof(tbl->buckets[0]);
+
+	tbl = kzalloc(size, gfp);
+	if (!tbl)
+		return NULL;
+
+	if (!nested_table_alloc(ht, (union nested_table __rcu **)tbl->buckets,
+				0, 0)) {
+		kfree(tbl);
+		return NULL;
+	}
+
+	tbl->nest = (ilog2(nbuckets) - 1) % shift + 1;
+
+	return tbl;
+}
+
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 					       size_t nbuckets,
 					       gfp_t gfp)
@@ -126,10 +224,17 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
 	if (tbl == NULL && gfp == GFP_KERNEL)
 		tbl = vzalloc(size);
+
+	size = nbuckets;
+
+	if (tbl == NULL && gfp != GFP_KERNEL) {
+		tbl = nested_bucket_table_alloc(ht, nbuckets, gfp);
+		nbuckets = 0;
+	}
 	if (tbl == NULL)
 		return NULL;
 
-	tbl->size = nbuckets;
+	tbl->size = size;
 
 	if (alloc_bucket_locks(ht, tbl, gfp) < 0) {
 		bucket_table_free(tbl);
@@ -164,12 +269,17 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	struct bucket_table *new_tbl = rhashtable_last_table(ht,
 		rht_dereference_rcu(old_tbl->future_tbl, ht));
-	struct rhash_head __rcu **pprev = &old_tbl->buckets[old_hash];
-	int err = -ENOENT;
+	struct rhash_head __rcu **pprev = rht_bucket_var(old_tbl, old_hash);
+	int err = -EAGAIN;
 	struct rhash_head *head, *next, *entry;
 	spinlock_t *new_bucket_lock;
 	unsigned int new_hash;
 
+	if (new_tbl->nest)
+		goto out;
+
+	err = -ENOENT;
+
 	rht_for_each(entry, old_tbl, old_hash) {
 		err = 0;
 		next = rht_dereference_bucket(entry->next, old_tbl, old_hash);
@@ -202,19 +312,26 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 	return err;
 }
 
-static void rhashtable_rehash_chain(struct rhashtable *ht,
+static int rhashtable_rehash_chain(struct rhashtable *ht,
 				    unsigned int old_hash)
 {
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	spinlock_t *old_bucket_lock;
+	int err;
 
 	old_bucket_lock = rht_bucket_lock(old_tbl, old_hash);
 
 	spin_lock_bh(old_bucket_lock);
-	while (!rhashtable_rehash_one(ht, old_hash))
+	while (!(err = rhashtable_rehash_one(ht, old_hash)))
 		;
-	old_tbl->rehash++;
+
+	if (err == -ENOENT) {
+		old_tbl->rehash++;
+		err = 0;
+	}
 	spin_unlock_bh(old_bucket_lock);
+
+	return err;
 }
 
 static int rhashtable_rehash_attach(struct rhashtable *ht,
@@ -246,13 +363,17 @@ static int rhashtable_rehash_table(struct rhashtable *ht)
 	struct bucket_table *new_tbl;
 	struct rhashtable_walker *walker;
 	unsigned int old_hash;
+	int err;
 
 	new_tbl = rht_dereference(old_tbl->future_tbl, ht);
 	if (!new_tbl)
 		return 0;
 
-	for (old_hash = 0; old_hash < old_tbl->size; old_hash++)
-		rhashtable_rehash_chain(ht, old_hash);
+	for (old_hash = 0; old_hash < old_tbl->size; old_hash++) {
+		err = rhashtable_rehash_chain(ht, old_hash);
+		if (err)
+			return err;
+	}
 
 	/* Publish the new table pointer. */
 	rcu_assign_pointer(ht->tbl, new_tbl);
@@ -271,31 +392,16 @@ static int rhashtable_rehash_table(struct rhashtable *ht)
 	return rht_dereference(new_tbl->future_tbl, ht) ? -EAGAIN : 0;
 }
 
-/**
- * rhashtable_expand - Expand hash table while allowing concurrent lookups
- * @ht:		the hash table to expand
- *
- * A secondary bucket array is allocated and the hash entries are migrated.
- *
- * This function may only be called in a context where it is safe to call
- * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
- *
- * The caller must ensure that no concurrent resizing occurs by holding
- * ht->mutex.
- *
- * It is valid to have concurrent insertions and deletions protected by per
- * bucket locks or concurrent RCU protected lookups and traversals.
- */
-static int rhashtable_expand(struct rhashtable *ht)
+static int rhashtable_rehash_alloc(struct rhashtable *ht,
+				   struct bucket_table *old_tbl,
+				   unsigned int size)
 {
-	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
+	struct bucket_table *new_tbl;
 	int err;
 
 	ASSERT_RHT_MUTEX(ht);
 
-	old_tbl = rhashtable_last_table(ht, old_tbl);
-
-	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2, GFP_KERNEL);
+	new_tbl = bucket_table_alloc(ht, size, GFP_KERNEL);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -324,12 +430,9 @@ static int rhashtable_expand(struct rhashtable *ht)
  */
 static int rhashtable_shrink(struct rhashtable *ht)
 {
-	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
+	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	unsigned int nelems = atomic_read(&ht->nelems);
 	unsigned int size = 0;
-	int err;
-
-	ASSERT_RHT_MUTEX(ht);
 
 	if (nelems)
 		size = roundup_pow_of_two(nelems * 3 / 2);
@@ -342,15 +445,7 @@ static int rhashtable_shrink(struct rhashtable *ht)
 	if (rht_dereference(old_tbl->future_tbl, ht))
 		return -EEXIST;
 
-	new_tbl = bucket_table_alloc(ht, size, GFP_KERNEL);
-	if (new_tbl == NULL)
-		return -ENOMEM;
-
-	err = rhashtable_rehash_attach(ht, old_tbl, new_tbl);
-	if (err)
-		bucket_table_free(new_tbl);
-
-	return err;
+	return rhashtable_rehash_alloc(ht, old_tbl, size);
 }
 
 static void rht_deferred_worker(struct work_struct *work)
@@ -366,11 +461,14 @@ static void rht_deferred_worker(struct work_struct *work)
 	tbl = rhashtable_last_table(ht, tbl);
 
 	if (rht_grow_above_75(ht, tbl))
-		rhashtable_expand(ht);
+		err = rhashtable_rehash_alloc(ht, tbl, tbl->size * 2);
 	else if (ht->p.automatic_shrinking && rht_shrink_below_30(ht, tbl))
-		rhashtable_shrink(ht);
+		err = rhashtable_shrink(ht);
+	else if (tbl->nest)
+		err = rhashtable_rehash_alloc(ht, tbl, tbl->size);
 
-	err = rhashtable_rehash_table(ht);
+	if (!err)
+		err = rhashtable_rehash_table(ht);
 
 	mutex_unlock(&ht->mutex);
 
@@ -439,8 +537,8 @@ static void *rhashtable_lookup_one(struct rhashtable *ht,
 	int elasticity;
 
 	elasticity = ht->elasticity;
-	pprev = &tbl->buckets[hash];
-	rht_for_each(head, tbl, hash) {
+	pprev = rht_bucket_var(tbl, hash);
+	rht_for_each_continue(head, *pprev, tbl, hash) {
 		struct rhlist_head *list;
 		struct rhlist_head *plist;
 
@@ -477,6 +575,7 @@ static struct bucket_table *rhashtable_insert_one(struct rhashtable *ht,
 						  struct rhash_head *obj,
 						  void *data)
 {
+	struct rhash_head __rcu **pprev;
 	struct bucket_table *new_tbl;
 	struct rhash_head *head;
 
@@ -499,7 +598,11 @@ static struct bucket_table *rhashtable_insert_one(struct rhashtable *ht,
 	if (unlikely(rht_grow_above_100(ht, tbl)))
 		return ERR_PTR(-EAGAIN);
 
-	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	pprev = rht_bucket_insert(ht, tbl, hash);
+	if (!pprev)
+		return ERR_PTR(-ENOMEM);
+
+	head = rht_dereference_bucket(*pprev, tbl, hash);
 
 	RCU_INIT_POINTER(obj->next, head);
 	if (ht->rhlist) {
@@ -509,7 +612,7 @@ static struct bucket_table *rhashtable_insert_one(struct rhashtable *ht,
 		RCU_INIT_POINTER(list->next, NULL);
 	}
 
-	rcu_assign_pointer(tbl->buckets[hash], obj);
+	rcu_assign_pointer(*pprev, obj);
 
 	atomic_inc(&ht->nelems);
 	if (rht_grow_above_75(ht, tbl))
@@ -975,7 +1078,7 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
 				 void (*free_fn)(void *ptr, void *arg),
 				 void *arg)
 {
-	const struct bucket_table *tbl;
+	struct bucket_table *tbl;
 	unsigned int i;
 
 	cancel_work_sync(&ht->run_work);
@@ -986,7 +1089,7 @@ void rhashtable_free_and_destroy(struct rhashtable *ht,
 		for (i = 0; i < tbl->size; i++) {
 			struct rhash_head *pos, *next;
 
-			for (pos = rht_dereference(tbl->buckets[i], ht),
+			for (pos = rht_dereference(*rht_bucket(tbl, i), ht),
 			     next = !rht_is_a_nulls(pos) ?
 					rht_dereference(pos->next, ht) : NULL;
 			     !rht_is_a_nulls(pos);
@@ -1007,3 +1110,69 @@ void rhashtable_destroy(struct rhashtable *ht)
 	return rhashtable_free_and_destroy(ht, NULL, NULL);
 }
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
+
+struct rhash_head __rcu **rht_bucket_nested(const struct bucket_table *tbl,
+					    unsigned int hash)
+{
+	const unsigned int shift = PAGE_SHIFT - ilog2(sizeof(void *));
+	static struct rhash_head __rcu *rhnull =
+		(struct rhash_head __rcu *)NULLS_MARKER(0);
+	unsigned int index = hash & ((1 << tbl->nest) - 1);
+	unsigned int size = tbl->size >> tbl->nest;
+	union nested_table *ntbl;
+
+	ntbl = (union nested_table *)rcu_dereference_raw(tbl->buckets[0]);
+	ntbl = rcu_dereference(ntbl[index].table);
+	hash >>= tbl->nest;
+
+	while (ntbl && size > (1 << shift)) {
+		index = hash & ((1 << shift) - 1);
+		ntbl = rcu_dereference(ntbl[index].table);
+		size >>= shift;
+		hash >>= shift;
+	}
+
+	if (!ntbl)
+		return &rhnull;
+
+	return &ntbl[hash].bucket;
+
+}
+EXPORT_SYMBOL_GPL(rht_bucket_nested);
+
+struct rhash_head __rcu **rht_bucket_nested_insert(struct rhashtable *ht,
+						   struct bucket_table *tbl,
+						   unsigned int hash)
+{
+	const unsigned int shift = PAGE_SHIFT - ilog2(sizeof(void *));
+	unsigned int index = hash & ((1 << tbl->nest) - 1);
+	unsigned int size = tbl->size >> tbl->nest;
+	union nested_table *ntbl;
+	unsigned int shifted;
+	unsigned int nhash;
+
+	ntbl = (union nested_table *)rcu_dereference_raw(tbl->buckets[0]);
+	hash >>= tbl->nest;
+	nhash = index;
+	shifted = tbl->nest;
+	ntbl = nested_table_alloc(ht, &ntbl[index].table,
+				  size <= (1 << shift) ? shifted : 0, nhash);
+
+	while (ntbl && size > (1 << shift)) {
+		index = hash & ((1 << shift) - 1);
+		size >>= shift;
+		hash >>= shift;
+		nhash |= index << shifted;
+		shifted += shift;
+		ntbl = nested_table_alloc(ht, &ntbl[index].table,
+					  size <= (1 << shift) ? shifted : 0,
+					  nhash);
+	}
+
+	if (!ntbl)
+		return NULL;
+
+	return &ntbl[hash].bucket;
+
+}
+EXPORT_SYMBOL_GPL(rht_bucket_nested_insert);
