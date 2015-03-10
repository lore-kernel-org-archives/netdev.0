From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH v2] rhashtable: Add arbitrary rehash function
Date: Wed, 11 Mar 2015 09:43:48 +1100
Message-ID: <20150310224348.GA29994@gondor.apana.org.au>
References: <20150309222631.GA12221@gondor.apana.org.au>
 <E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37524 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbbCJWny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:43:54 -0400
Content-Disposition: inline
In-Reply-To: <E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a rehash function that supports the use of any
hash function for the new table.  This is needed to support changing
the random seed value during the lifetime of the hash table.

However for now the random seed value is still constant and the
rehash function is simply used to replace the existing expand/shrink
functions.

Signed-off-by: Herbert Xu <herbert.xu@redhat.com>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index ba15dce..9bc3fc4b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -66,9 +66,9 @@ static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 	return hash & (tbl->size - 1);
 }
 
-static u32 obj_raw_hashfn(struct rhashtable *ht, const void *ptr)
+static u32 obj_raw_hashfn(struct rhashtable *ht,
+			  const struct bucket_table *tbl, const void *ptr)
 {
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
 
 	if (unlikely(!ht->p.key_len))
@@ -80,10 +80,9 @@ static u32 obj_raw_hashfn(struct rhashtable *ht, const void *ptr)
 	return hash >> HASH_RESERVED_SPACE;
 }
 
-static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
+static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
+		      const void *key, u32 len)
 {
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
-
 	return ht->p.hashfn(key, len, tbl->hash_rnd) >> HASH_RESERVED_SPACE;
 }
 
@@ -91,7 +90,7 @@ static u32 head_hashfn(struct rhashtable *ht,
 		       const struct bucket_table *tbl,
 		       const struct rhash_head *he)
 {
-	return rht_bucket_index(tbl, obj_raw_hashfn(ht, rht_obj(ht, he)));
+	return rht_bucket_index(tbl, obj_raw_hashfn(ht, tbl, rht_obj(ht, he)));
 }
 
 #ifdef CONFIG_PROVE_LOCKING
@@ -165,18 +164,6 @@ EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
 #endif
 
 
-static struct rhash_head __rcu **bucket_tail(struct bucket_table *tbl, u32 n)
-{
-	struct rhash_head __rcu **pprev;
-
-	for (pprev = &tbl->buckets[n];
-	     !rht_is_a_nulls(rht_dereference_bucket(*pprev, tbl, n));
-	     pprev = &rht_dereference_bucket(*pprev, tbl, n)->next)
-		;
-
-	return pprev;
-}
-
 static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
 {
 	unsigned int i, size;
@@ -270,101 +257,99 @@ static bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
 	       (atomic_read(&ht->shift) > ht->p.min_shift);
 }
 
-static void lock_buckets(struct bucket_table *new_tbl,
-			 struct bucket_table *old_tbl, unsigned int hash)
-	__acquires(old_bucket_lock)
+static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 {
-	spin_lock_bh(bucket_lock(old_tbl, hash));
-	if (new_tbl != old_tbl)
-		spin_lock_bh_nested(bucket_lock(new_tbl, hash),
-				    RHT_LOCK_NESTED);
-}
+	struct bucket_table *new_tbl = rht_dereference(ht->future_tbl, ht);
+	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
+	struct rhash_head __rcu **pprev = &old_tbl->buckets[old_hash];
+	int err = -ENOENT;
+	struct rhash_head *head, *next, *entry;
+	spinlock_t *new_bucket_lock;
+	unsigned new_hash;
+
+	rht_for_each(entry, old_tbl, old_hash) {
+		err = 0;
+		next = rht_dereference_bucket(entry->next, old_tbl, old_hash);
+
+		if (rht_is_a_nulls(next))
+			break;
 
-static void unlock_buckets(struct bucket_table *new_tbl,
-			   struct bucket_table *old_tbl, unsigned int hash)
-	__releases(old_bucket_lock)
-{
-	if (new_tbl != old_tbl)
-		spin_unlock_bh(bucket_lock(new_tbl, hash));
-	spin_unlock_bh(bucket_lock(old_tbl, hash));
-}
+		pprev = &entry->next;
+	}
 
-/**
- * Unlink entries on bucket which hash to different bucket.
- *
- * Returns true if no more work needs to be performed on the bucket.
- */
-static bool hashtable_chain_unzip(struct rhashtable *ht,
-				  const struct bucket_table *new_tbl,
-				  struct bucket_table *old_tbl,
-				  size_t old_hash)
-{
-	struct rhash_head *he, *p, *next;
-	unsigned int new_hash, new_hash2;
+	if (err)
+		goto out;
 
-	ASSERT_BUCKET_LOCK(ht, old_tbl, old_hash);
+	new_hash = head_hashfn(ht, new_tbl, entry);
 
-	/* Old bucket empty, no work needed. */
-	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
-				   old_hash);
-	if (rht_is_a_nulls(p))
-		return false;
+	new_bucket_lock = bucket_lock(new_tbl, new_hash);
 
-	new_hash = head_hashfn(ht, new_tbl, p);
-	ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash);
+	spin_lock(new_bucket_lock);
+	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
+				      new_tbl, new_hash);
 
-	/* Advance the old bucket pointer one or more times until it
-	 * reaches a node that doesn't hash to the same bucket as the
-	 * previous node p. Call the previous node p;
-	 */
-	rht_for_each_continue(he, p->next, old_tbl, old_hash) {
-		new_hash2 = head_hashfn(ht, new_tbl, he);
-		ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash2);
+	if (rht_is_a_nulls(head))
+		INIT_RHT_NULLS_HEAD(entry->next, ht, new_hash);
+	else
+		RCU_INIT_POINTER(entry->next, head);
 
-		if (new_hash != new_hash2)
-			break;
-		p = he;
-	}
-	rcu_assign_pointer(old_tbl->buckets[old_hash], p->next);
+	rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
+	spin_unlock(new_bucket_lock);
 
-	/* Find the subsequent node which does hash to the same
-	 * bucket as node P, or NULL if no such node exists.
-	 */
-	INIT_RHT_NULLS_HEAD(next, ht, old_hash);
-	if (!rht_is_a_nulls(he)) {
-		rht_for_each_continue(he, he->next, old_tbl, old_hash) {
-			if (head_hashfn(ht, new_tbl, he) == new_hash) {
-				next = he;
-				break;
-			}
-		}
-	}
+	rcu_assign_pointer(*pprev, next);
 
-	/* Set p's next pointer to that subsequent node pointer,
-	 * bypassing the nodes which do not hash to p's bucket
-	 */
-	rcu_assign_pointer(p->next, next);
+out:
+	return err;
+}
+
+static void rhashtable_rehash_chain(struct rhashtable *ht, unsigned old_hash)
+{
+	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
+	spinlock_t *old_bucket_lock;
 
-	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
-				   old_hash);
+	old_bucket_lock = bucket_lock(old_tbl, old_hash);
 
-	return !rht_is_a_nulls(p);
+	spin_lock_bh(old_bucket_lock);
+	while (!rhashtable_rehash_one(ht, old_hash))
+		;
+	spin_unlock_bh(old_bucket_lock);
 }
 
-static void link_old_to_new(struct rhashtable *ht, struct bucket_table *new_tbl,
-			    unsigned int new_hash, struct rhash_head *entry)
+static void rhashtable_rehash(struct rhashtable *ht,
+			      struct bucket_table *new_tbl)
 {
-	ASSERT_BUCKET_LOCK(ht, new_tbl, new_hash);
+	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
+	unsigned old_hash;
+
+	get_random_bytes(&new_tbl->hash_rnd, sizeof(new_tbl->hash_rnd));
 
-	rcu_assign_pointer(*bucket_tail(new_tbl, new_hash), entry);
+	/* Make insertions go into the new, empty table right away. Deletions
+	 * and lookups will be attempted in both tables until we synchronize.
+	 * The synchronize_rcu() guarantees for the new table to be picked up
+	 * so no new additions go into the old table while we relink.
+	 */
+	rcu_assign_pointer(ht->future_tbl, new_tbl);
+
+	for (old_hash = 0; old_hash < old_tbl->size; old_hash++)
+		rhashtable_rehash_chain(ht, old_hash);
+
+	/* Publish the new table pointer. */
+	rcu_assign_pointer(ht->tbl, new_tbl);
+
+	/* Wait for readers. All new readers will see the new
+	 * table, and thus no references to the old table will
+	 * remain.
+	 */
+	synchronize_rcu();
+
+	bucket_table_free(old_tbl);
 }
 
 /**
  * rhashtable_expand - Expand hash table while allowing concurrent lookups
  * @ht:		the hash table to expand
  *
- * A secondary bucket array is allocated and the hash entries are migrated
- * while keeping them on both lists until the end of the RCU grace period.
+ * A secondary bucket array is allocated and the hash entries are migrated.
  *
  * This function may only be called in a context where it is safe to call
  * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
@@ -378,9 +363,6 @@ static void link_old_to_new(struct rhashtable *ht, struct bucket_table *new_tbl,
 int rhashtable_expand(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
-	struct rhash_head *he;
-	unsigned int new_hash, old_hash;
-	bool complete = false;
 
 	ASSERT_RHT_MUTEX(ht);
 
@@ -392,64 +374,8 @@ int rhashtable_expand(struct rhashtable *ht)
 
 	atomic_inc(&ht->shift);
 
-	/* Make insertions go into the new, empty table right away. Deletions
-	 * and lookups will be attempted in both tables until we synchronize.
-	 * The synchronize_rcu() guarantees for the new table to be picked up
-	 * so no new additions go into the old table while we relink.
-	 */
-	rcu_assign_pointer(ht->future_tbl, new_tbl);
-	synchronize_rcu();
+	rhashtable_rehash(ht, new_tbl);
 
-	/* For each new bucket, search the corresponding old bucket for the
-	 * first entry that hashes to the new bucket, and link the end of
-	 * newly formed bucket chain (containing entries added to future
-	 * table) to that entry. Since all the entries which will end up in
-	 * the new bucket appear in the same old bucket, this constructs an
-	 * entirely valid new hash table, but with multiple buckets
-	 * "zipped" together into a single imprecise chain.
-	 */
-	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
-		old_hash = rht_bucket_index(old_tbl, new_hash);
-		lock_buckets(new_tbl, old_tbl, new_hash);
-		rht_for_each(he, old_tbl, old_hash) {
-			if (head_hashfn(ht, new_tbl, he) == new_hash) {
-				link_old_to_new(ht, new_tbl, new_hash, he);
-				break;
-			}
-		}
-		unlock_buckets(new_tbl, old_tbl, new_hash);
-		cond_resched();
-	}
-
-	/* Unzip interleaved hash chains */
-	while (!complete && !ht->being_destroyed) {
-		/* Wait for readers. All new readers will see the new
-		 * table, and thus no references to the old table will
-		 * remain.
-		 */
-		synchronize_rcu();
-
-		/* For each bucket in the old table (each of which
-		 * contains items from multiple buckets of the new
-		 * table): ...
-		 */
-		complete = true;
-		for (old_hash = 0; old_hash < old_tbl->size; old_hash++) {
-			lock_buckets(new_tbl, old_tbl, old_hash);
-
-			if (hashtable_chain_unzip(ht, new_tbl, old_tbl,
-						  old_hash))
-				complete = false;
-
-			unlock_buckets(new_tbl, old_tbl, old_hash);
-			cond_resched();
-		}
-	}
-
-	rcu_assign_pointer(ht->tbl, new_tbl);
-	synchronize_rcu();
-
-	bucket_table_free(old_tbl);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rhashtable_expand);
@@ -473,7 +399,6 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *tbl = rht_dereference(ht->tbl, ht);
-	unsigned int new_hash;
 
 	ASSERT_RHT_MUTEX(ht);
 
@@ -483,39 +408,9 @@ int rhashtable_shrink(struct rhashtable *ht)
 
 	new_tbl->hash_rnd = tbl->hash_rnd;
 
-	rcu_assign_pointer(ht->future_tbl, new_tbl);
-	synchronize_rcu();
-
-	/* Link the first entry in the old bucket to the end of the
-	 * bucket in the new table. As entries are concurrently being
-	 * added to the new table, lock down the new bucket. As we
-	 * always divide the size in half when shrinking, each bucket
-	 * in the new table maps to exactly two buckets in the old
-	 * table.
-	 */
-	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
-		lock_buckets(new_tbl, tbl, new_hash);
-
-		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
-				   tbl->buckets[new_hash]);
-		ASSERT_BUCKET_LOCK(ht, tbl, new_hash + new_tbl->size);
-		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
-				   tbl->buckets[new_hash + new_tbl->size]);
-
-		unlock_buckets(new_tbl, tbl, new_hash);
-		cond_resched();
-	}
-
-	/* Publish the new, valid hash table */
-	rcu_assign_pointer(ht->tbl, new_tbl);
 	atomic_dec(&ht->shift);
 
-	/* Wait for readers. No new readers will have references to the
-	 * old hash table.
-	 */
-	synchronize_rcu();
-
-	bucket_table_free(tbl);
+	rhashtable_rehash(ht, new_tbl);
 
 	return 0;
 }
@@ -545,18 +440,46 @@ unlock:
 	mutex_unlock(&ht->mutex);
 }
 
-static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
-				struct bucket_table *tbl,
-				const struct bucket_table *old_tbl, u32 hash)
+static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
+				bool (*compare)(void *, void *), void *arg)
 {
-	bool no_resize_running = tbl == old_tbl;
+	struct bucket_table *tbl, *old_tbl;
 	struct rhash_head *head;
+	bool no_resize_running;
+	unsigned hash;
+	bool success = true;
+
+	rcu_read_lock();
+
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = obj_raw_hashfn(ht, old_tbl, rht_obj(ht, obj));
+
+	spin_lock_bh(bucket_lock(old_tbl, hash));
+
+	/* Because we have already taken the bucket lock in old_tbl,
+	 * if we find that future_tbl is not yet visible then that
+	 * guarantees all other insertions of the same entry will
+	 * also grab the bucket lock in old_tbl because until the
+	 * rehash completes ht->tbl won't be changed.
+	 */
+	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	if (tbl != old_tbl) {
+		hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
+		spin_lock(bucket_lock(tbl, hash));
+	}
+
+	if (compare &&
+	    rhashtable_lookup_compare(ht, rht_obj(ht, obj) + ht->p.key_offset,
+				      compare, arg)) {
+		success = false;
+		goto exit;
+	}
+
+	no_resize_running = tbl == old_tbl;
 
 	hash = rht_bucket_index(tbl, hash);
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
 
-	ASSERT_BUCKET_LOCK(ht, tbl, hash);
-
 	if (rht_is_a_nulls(head))
 		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
 	else
@@ -567,6 +490,19 @@ static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	atomic_inc(&ht->nelems);
 	if (no_resize_running && rht_grow_above_75(ht, tbl->size))
 		schedule_work(&ht->run_work);
+
+exit:
+	if (tbl != old_tbl) {
+		hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
+		spin_unlock(bucket_lock(tbl, hash));
+	}
+
+	hash = obj_raw_hashfn(ht, old_tbl, rht_obj(ht, obj));
+	spin_unlock_bh(bucket_lock(old_tbl, hash));
+
+	rcu_read_unlock();
+
+	return success;
 }
 
 /**
@@ -586,22 +522,42 @@ static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
  */
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl, *old_tbl;
+	__rhashtable_insert(ht, obj, NULL, NULL);
+}
+EXPORT_SYMBOL_GPL(rhashtable_insert);
+
+static bool __rhashtable_remove(struct rhashtable *ht,
+				struct bucket_table *tbl,
+				struct rhash_head *obj)
+{
+	struct rhash_head __rcu **pprev;
+	struct rhash_head *he;
+	spinlock_t * lock;
 	unsigned hash;
+	bool ret = false;
 
-	rcu_read_lock();
+	hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
+	lock = bucket_lock(tbl, hash);
+	hash = rht_bucket_index(tbl, hash);
 
-	tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
+	spin_lock_bh(lock);
 
-	lock_buckets(tbl, old_tbl, hash);
-	__rhashtable_insert(ht, obj, tbl, old_tbl, hash);
-	unlock_buckets(tbl, old_tbl, hash);
+	pprev = &tbl->buckets[hash];
+	rht_for_each(he, tbl, hash) {
+		if (he != obj) {
+			pprev = &he->next;
+			continue;
+		}
 
-	rcu_read_unlock();
+		rcu_assign_pointer(*pprev, obj->next);
+		ret = true;
+		break;
+	}
+
+	spin_unlock_bh(lock);
+
+	return ret;
 }
-EXPORT_SYMBOL_GPL(rhashtable_insert);
 
 /**
  * rhashtable_remove - remove object from hash table
@@ -620,68 +576,28 @@ EXPORT_SYMBOL_GPL(rhashtable_insert);
  */
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl, *new_tbl, *old_tbl;
-	struct rhash_head __rcu **pprev;
-	struct rhash_head *he, *he2;
-	unsigned int hash, new_hash;
-	bool ret = false;
+	struct bucket_table *tbl, *old_tbl;
+	bool ret;
 
 	rcu_read_lock();
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	tbl = new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	new_hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
-	lock_buckets(new_tbl, old_tbl, new_hash);
-restart:
-	hash = rht_bucket_index(tbl, new_hash);
-	pprev = &tbl->buckets[hash];
-	rht_for_each(he, tbl, hash) {
-		if (he != obj) {
-			pprev = &he->next;
-			continue;
-		}
-
-		ASSERT_BUCKET_LOCK(ht, tbl, hash);
-
-		if (old_tbl->size > new_tbl->size && tbl == old_tbl &&
-		    !rht_is_a_nulls(obj->next) &&
-		    head_hashfn(ht, tbl, obj->next) != hash) {
-			rcu_assign_pointer(*pprev, (struct rhash_head *) rht_marker(ht, hash));
-		} else if (unlikely(old_tbl->size < new_tbl->size && tbl == new_tbl)) {
-			rht_for_each_continue(he2, obj->next, tbl, hash) {
-				if (head_hashfn(ht, tbl, he2) == hash) {
-					rcu_assign_pointer(*pprev, he2);
-					goto found;
-				}
-			}
-
-			rcu_assign_pointer(*pprev, (struct rhash_head *) rht_marker(ht, hash));
-		} else {
-			rcu_assign_pointer(*pprev, obj->next);
-		}
-
-found:
-		ret = true;
-		break;
-	}
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	ret = __rhashtable_remove(ht, old_tbl, obj);
 
-	/* The entry may be linked in either 'tbl', 'future_tbl', or both.
-	 * 'future_tbl' only exists for a short period of time during
-	 * resizing. Thus traversing both is fine and the added cost is
-	 * very rare.
+	/* Because we have already taken (and released) the bucket
+	 * lock in old_tbl, if we find that future_tbl is not yet
+	 * visible then that guarantees the entry to still be in
+	 * old_tbl if it exists.
 	 */
-	if (tbl != old_tbl) {
-		tbl = old_tbl;
-		goto restart;
-	}
-
-	unlock_buckets(new_tbl, old_tbl, new_hash);
+	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	if (!ret && old_tbl != tbl)
+		ret = __rhashtable_remove(ht, tbl, obj);
 
 	if (ret) {
-		bool no_resize_running = new_tbl == old_tbl;
+		bool no_resize_running = tbl == old_tbl;
 
 		atomic_dec(&ht->nelems);
-		if (no_resize_running && rht_shrink_below_30(ht, new_tbl->size))
+		if (no_resize_running && rht_shrink_below_30(ht, tbl->size))
 			schedule_work(&ht->run_work);
 	}
 
@@ -753,9 +669,8 @@ void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 
 	rcu_read_lock();
 
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	hash = key_hashfn(ht, key, ht->p.key_len);
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = key_hashfn(ht, tbl, key, ht->p.key_len);
 restart:
 	rht_for_each_rcu(he, tbl, rht_bucket_index(tbl, hash)) {
 		if (!compare(rht_obj(ht, he), arg))
@@ -764,10 +679,10 @@ restart:
 		return rht_obj(ht, he);
 	}
 
-	if (unlikely(tbl != old_tbl)) {
-		tbl = old_tbl;
+	old_tbl = tbl;
+	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	if (unlikely(tbl != old_tbl))
 		goto restart;
-	}
 	rcu_read_unlock();
 
 	return NULL;
@@ -833,32 +748,9 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 				      bool (*compare)(void *, void *),
 				      void *arg)
 {
-	struct bucket_table *new_tbl, *old_tbl;
-	u32 new_hash;
-	bool success = true;
-
 	BUG_ON(!ht->p.key_len);
 
-	rcu_read_lock();
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	new_hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
-
-	lock_buckets(new_tbl, old_tbl, new_hash);
-
-	if (rhashtable_lookup_compare(ht, rht_obj(ht, obj) + ht->p.key_offset,
-				      compare, arg)) {
-		success = false;
-		goto exit;
-	}
-
-	__rhashtable_insert(ht, obj, new_tbl, old_tbl, new_hash);
-
-exit:
-	unlock_buckets(new_tbl, old_tbl, new_hash);
-	rcu_read_unlock();
-
-	return success;
+	return __rhashtable_insert(ht, obj, compare, arg);
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
