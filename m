From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/6] rhashtable: Use a single bucket lock for sibling buckets
Date: Fri, 30 Jan 2015 01:20:39 +0100
Message-ID: <14d537500868b4ff0396168cf9d5db95d327c128.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53195 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758834AbbA3AUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:51 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rhashtable currently allows to use a bucket lock per bucket. This
requires multiple levels of complicated nested locking because when
resizing, a single bucket of the smaller table will map to two
buckets in the larger table. So far rhashtable has explicitly locked
both buckets in the larger table.

By excluding the highest bit of the hash from the bucket lock map and
thus only allowing locks to buckets in a ratio of 1:2, the locking
can be simplified a lot without losing the benefits of multiple locks.
Larger tables which benefit from multiple locks will not have a single
lock per bucket anyway.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 166 +++++++++++++++++++++++--------------------------------
 1 file changed, 68 insertions(+), 98 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 7413697..17eeabc 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -1,7 +1,7 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
- * Copyright (c) 2014 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2014-2015 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
  * Based on the following paper:
@@ -34,7 +34,6 @@
 enum {
 	RHT_LOCK_NORMAL,
 	RHT_LOCK_NESTED,
-	RHT_LOCK_NESTED2,
 };
 
 /* The bucket lock is selected based on the hash and protects mutations
@@ -128,8 +127,8 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
 	nr_pcpus = min_t(unsigned int, nr_pcpus, 32UL);
 	size = roundup_pow_of_two(nr_pcpus * ht->p.locks_mul);
 
-	/* Never allocate more than one lock per bucket */
-	size = min_t(unsigned int, size, tbl->size);
+	/* Never allocate more than 0.5 locks per bucket */
+	size = min_t(unsigned int, size, tbl->size >> 1);
 
 	if (sizeof(spinlock_t) != 0) {
 #ifdef CONFIG_NUMA
@@ -211,13 +210,36 @@ bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
 }
 EXPORT_SYMBOL_GPL(rht_shrink_below_30);
 
-static void hashtable_chain_unzip(const struct rhashtable *ht,
+static void lock_buckets(struct bucket_table *new_tbl,
+			 struct bucket_table *old_tbl, unsigned int hash)
+	__acquires(old_bucket_lock)
+{
+	spin_lock_bh(bucket_lock(old_tbl, hash));
+	if (new_tbl != old_tbl)
+		spin_lock_bh_nested(bucket_lock(new_tbl, hash),
+				    RHT_LOCK_NESTED);
+}
+
+static void unlock_buckets(struct bucket_table *new_tbl,
+			   struct bucket_table *old_tbl, unsigned int hash)
+	__releases(old_bucket_lock)
+{
+	if (new_tbl != old_tbl)
+		spin_unlock_bh(bucket_lock(new_tbl, hash));
+	spin_unlock_bh(bucket_lock(old_tbl, hash));
+}
+
+/**
+ * Unlink entries on bucket which hash to different bucket.
+ *
+ * Returns true if no more work needs to be performed on the bucket.
+ */
+static bool hashtable_chain_unzip(const struct rhashtable *ht,
 				  const struct bucket_table *new_tbl,
 				  struct bucket_table *old_tbl,
 				  size_t old_hash)
 {
 	struct rhash_head *he, *p, *next;
-	spinlock_t *new_bucket_lock, *new_bucket_lock2 = NULL;
 	unsigned int new_hash, new_hash2;
 
 	ASSERT_BUCKET_LOCK(old_tbl, old_hash);
@@ -226,10 +248,10 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
 				   old_hash);
 	if (rht_is_a_nulls(p))
-		return;
+		return false;
 
-	new_hash = new_hash2 = head_hashfn(ht, new_tbl, p);
-	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+	new_hash = head_hashfn(ht, new_tbl, p);
+	ASSERT_BUCKET_LOCK(new_tbl, new_hash);
 
 	/* Advance the old bucket pointer one or more times until it
 	 * reaches a node that doesn't hash to the same bucket as the
@@ -237,22 +259,19 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	 */
 	rht_for_each_continue(he, p->next, old_tbl, old_hash) {
 		new_hash2 = head_hashfn(ht, new_tbl, he);
+
+		/* All entries in a chain must alwas map to a single
+		 * bucket lock. This is ensured because the bucket lock
+		 * hash map ignores the highest bit.
+		 */
+		ASSERT_BUCKET_LOCK(new_tbl, new_hash2);
+
 		if (new_hash != new_hash2)
 			break;
 		p = he;
 	}
 	rcu_assign_pointer(old_tbl->buckets[old_hash], p->next);
 
-	spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
-
-	/* If we have encountered an entry that maps to a different bucket in
-	 * the new table, lock down that bucket as well as we might cut off
-	 * the end of the chain.
-	 */
-	new_bucket_lock2 = bucket_lock(new_tbl, new_hash);
-	if (new_bucket_lock != new_bucket_lock2)
-		spin_lock_bh_nested(new_bucket_lock2, RHT_LOCK_NESTED2);
-
 	/* Find the subsequent node which does hash to the same
 	 * bucket as node P, or NULL if no such node exists.
 	 */
@@ -271,21 +290,16 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	 */
 	rcu_assign_pointer(p->next, next);
 
-	if (new_bucket_lock != new_bucket_lock2)
-		spin_unlock_bh(new_bucket_lock2);
-	spin_unlock_bh(new_bucket_lock);
+	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
+				   old_hash);
+
+	return !rht_is_a_nulls(p);
 }
 
 static void link_old_to_new(struct bucket_table *new_tbl,
 			    unsigned int new_hash, struct rhash_head *entry)
 {
-	spinlock_t *new_bucket_lock;
-
-	new_bucket_lock = bucket_lock(new_tbl, new_hash);
-
-	spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
 	rcu_assign_pointer(*bucket_tail(new_tbl, new_hash), entry);
-	spin_unlock_bh(new_bucket_lock);
 }
 
 /**
@@ -308,7 +322,6 @@ int rhashtable_expand(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
 	struct rhash_head *he;
-	spinlock_t *old_bucket_lock;
 	unsigned int new_hash, old_hash;
 	bool complete = false;
 
@@ -338,16 +351,14 @@ int rhashtable_expand(struct rhashtable *ht)
 	 */
 	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
 		old_hash = rht_bucket_index(old_tbl, new_hash);
-		old_bucket_lock = bucket_lock(old_tbl, old_hash);
-
-		spin_lock_bh(old_bucket_lock);
+		lock_buckets(new_tbl, old_tbl, new_hash);
 		rht_for_each(he, old_tbl, old_hash) {
 			if (head_hashfn(ht, new_tbl, he) == new_hash) {
 				link_old_to_new(new_tbl, new_hash, he);
 				break;
 			}
 		}
-		spin_unlock_bh(old_bucket_lock);
+		unlock_buckets(new_tbl, old_tbl, new_hash);
 	}
 
 	/* Publish the new table pointer. Lookups may now traverse
@@ -370,18 +381,13 @@ int rhashtable_expand(struct rhashtable *ht)
 		 */
 		complete = true;
 		for (old_hash = 0; old_hash < old_tbl->size; old_hash++) {
-			struct rhash_head *head;
-
-			old_bucket_lock = bucket_lock(old_tbl, old_hash);
-			spin_lock_bh(old_bucket_lock);
+			lock_buckets(new_tbl, old_tbl, old_hash);
 
-			hashtable_chain_unzip(ht, new_tbl, old_tbl, old_hash);
-			head = rht_dereference_bucket(old_tbl->buckets[old_hash],
-						      old_tbl, old_hash);
-			if (!rht_is_a_nulls(head))
+			if (hashtable_chain_unzip(ht, new_tbl, old_tbl,
+						  old_hash))
 				complete = false;
 
-			spin_unlock_bh(old_bucket_lock);
+			unlock_buckets(new_tbl, old_tbl, old_hash);
 		}
 	}
 
@@ -409,7 +415,6 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *tbl = rht_dereference(ht->tbl, ht);
-	spinlock_t *new_bucket_lock, *old_bucket_lock1, *old_bucket_lock2;
 	unsigned int new_hash;
 
 	ASSERT_RHT_MUTEX(ht);
@@ -432,31 +437,14 @@ int rhashtable_shrink(struct rhashtable *ht)
 	 * to lock down both matching buckets in the old table.
 	 */
 	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
-		old_bucket_lock1 = bucket_lock(tbl, new_hash);
-		old_bucket_lock2 = bucket_lock(tbl, new_hash + new_tbl->size);
-		new_bucket_lock = bucket_lock(new_tbl, new_hash);
-
-		spin_lock_bh(old_bucket_lock1);
-
-		/* Depending on the lock per buckets mapping, the bucket in
-		 * the lower and upper region may map to the same lock.
-		 */
-		if (old_bucket_lock1 != old_bucket_lock2) {
-			spin_lock_bh_nested(old_bucket_lock2, RHT_LOCK_NESTED);
-			spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED2);
-		} else {
-			spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
-		}
+		lock_buckets(new_tbl, tbl, new_hash);
 
 		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
 				   tbl->buckets[new_hash]);
 		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
 				   tbl->buckets[new_hash + new_tbl->size]);
 
-		spin_unlock_bh(new_bucket_lock);
-		if (old_bucket_lock1 != old_bucket_lock2)
-			spin_unlock_bh(old_bucket_lock2);
-		spin_unlock_bh(old_bucket_lock1);
+		unlock_buckets(new_tbl, tbl, new_hash);
 	}
 
 	/* Publish the new, valid hash table */
@@ -539,19 +527,18 @@ static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
  */
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl;
-	spinlock_t *lock;
+	struct bucket_table *tbl, *old_tbl;
 	unsigned hash;
 
 	rcu_read_lock();
 
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
 	hash = head_hashfn(ht, tbl, obj);
-	lock = bucket_lock(tbl, hash);
 
-	spin_lock_bh(lock);
+	lock_buckets(tbl, old_tbl, hash);
 	__rhashtable_insert(ht, obj, tbl, hash);
-	spin_unlock_bh(lock);
+	unlock_buckets(tbl, old_tbl, hash);
 
 	rcu_read_unlock();
 }
@@ -574,21 +561,20 @@ EXPORT_SYMBOL_GPL(rhashtable_insert);
  */
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl;
+	struct bucket_table *tbl, *new_tbl, *old_tbl;
 	struct rhash_head __rcu **pprev;
 	struct rhash_head *he;
-	spinlock_t *lock;
-	unsigned int hash;
+	unsigned int hash, new_hash;
 	bool ret = false;
 
 	rcu_read_lock();
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = head_hashfn(ht, tbl, obj);
-
-	lock = bucket_lock(tbl, hash);
-	spin_lock_bh(lock);
+	tbl = old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	new_hash = head_hashfn(ht, new_tbl, obj);
 
+	lock_buckets(new_tbl, old_tbl, new_hash);
 restart:
+	hash = rht_bucket_index(tbl, new_hash);
 	pprev = &tbl->buckets[hash];
 	rht_for_each(he, tbl, hash) {
 		if (he != obj) {
@@ -607,18 +593,12 @@ restart:
 	 * resizing. Thus traversing both is fine and the added cost is
 	 * very rare.
 	 */
-	if (tbl != rht_dereference_rcu(ht->future_tbl, ht)) {
-		spin_unlock_bh(lock);
-
-		tbl = rht_dereference_rcu(ht->future_tbl, ht);
-		hash = head_hashfn(ht, tbl, obj);
-
-		lock = bucket_lock(tbl, hash);
-		spin_lock_bh(lock);
+	if (tbl != new_tbl) {
+		tbl = new_tbl;
 		goto restart;
 	}
 
-	spin_unlock_bh(lock);
+	unlock_buckets(new_tbl, old_tbl, new_hash);
 
 	if (ret) {
 		atomic_dec(&ht->nelems);
@@ -774,24 +754,17 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 				      void *arg)
 {
 	struct bucket_table *new_tbl, *old_tbl;
-	spinlock_t *new_bucket_lock, *old_bucket_lock;
-	u32 new_hash, old_hash;
+	u32 new_hash;
 	bool success = true;
 
 	BUG_ON(!ht->p.key_len);
 
 	rcu_read_lock();
-
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	old_hash = head_hashfn(ht, old_tbl, obj);
-	old_bucket_lock = bucket_lock(old_tbl, old_hash);
-	spin_lock_bh(old_bucket_lock);
-
 	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	new_hash = head_hashfn(ht, new_tbl, obj);
-	new_bucket_lock = bucket_lock(new_tbl, new_hash);
-	if (unlikely(old_tbl != new_tbl))
-		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
+
+	lock_buckets(new_tbl, old_tbl, new_hash);
 
 	if (rhashtable_lookup_compare(ht, rht_obj(ht, obj) + ht->p.key_offset,
 				      compare, arg)) {
@@ -802,10 +775,7 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 	__rhashtable_insert(ht, obj, new_tbl, new_hash);
 
 exit:
-	if (unlikely(old_tbl != new_tbl))
-		spin_unlock_bh(new_bucket_lock);
-	spin_unlock_bh(old_bucket_lock);
-
+	unlock_buckets(new_tbl, old_tbl, new_hash);
 	rcu_read_unlock();
 
 	return success;
-- 
1.9.3
