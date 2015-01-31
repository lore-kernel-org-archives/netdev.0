From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC] rhashtable: rhashtable_rehash
Date: Sat, 31 Jan 2015 21:23:29 +1100
Message-ID: <20150131102329.GA29520@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34231 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbbAaKXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 05:23:33 -0500
Content-Disposition: inline
In-Reply-To: <20150131102150.GA29498@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a totally untested patch that illustrates what I want to
do with rehash.

Note that this depends on the hash rnd patch I just sent.

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4c3da1f..ebd5e44 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -79,9 +79,9 @@ static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 	return hash & (tbl->size - 1);
 }
 
-static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
+static u32 obj_raw_hashfn(const struct rhashtable *ht,
+			  struct bucket_table *tbl, const void *ptr)
 {
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
 
 	if (unlikely(!ht->p.key_len))
@@ -93,9 +93,9 @@ static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
 	return hash >> HASH_RESERVED_SPACE;
 }
 
-static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
+static u32 key_hashfn(struct rhashtable *ht, struct bucket_table *tbl,
+		      const void *key, u32 len)
 {
-	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
 
 	hash = ht->p.hashfn(key, len, tbl->hash_rnd);
@@ -295,6 +295,89 @@ static void link_old_to_new(struct bucket_table *new_tbl,
 	spin_unlock_bh(new_bucket_lock);
 }
 
+static void rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
+{
+	struct *old_tbl = rht_dereference(ht->tbl, ht);
+	struct *new_tbl = rht_dereference(ht->future_tbl, ht);
+	struct rhash_head *head, *next, *entry;
+	struct rhash_head __rcu **pprev;
+	spinlock_t *new_bucket_lock;
+	unsigned int new_hash;
+
+	pprev = &old_tbl->buckets[old_hash];
+	rht_for_each(entry, old_tbl, old_hash) {
+		next = rht_dereference_bucket(entry->next, old_tbl, old_hash);
+
+		if (rht_is_a_nulls(next))
+			break;
+
+		pprev = &entry->next;
+	}
+
+	new_hash = head_hashfn(ht, new_tbl, entry);
+
+	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+
+	spin_lock(new_bucket_lock);
+	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
+				      new_tbl, new_hash);
+
+	if (rht_is_a_nulls(head))
+		INIT_RHT_NULLS_HEAD(entry->next, ht, hash);
+	else
+		RCU_INIT_POINTER(entry->next, head);
+
+	rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
+	spin_unlock(new_bucket_lock);
+
+	rcu_assign_pointer(*pprev, next);
+}
+
+static void rhashtable_rehash_chain(struct rhashtable *ht,
+				    unsigned int old_hash)
+{
+	struct *old_tbl = rht_dereference(ht->tbl, ht);
+	spinlock_t *old_bucket_lock;
+
+	old_bucket_lock = bucket_lock(old_tbl, old_hash);
+
+	spin_lock_bh(old_bucket_lock);
+	while (!rht_is_a_nulls(rht_dereference_bucket(
+		old_tbl->buckets[old_hash], old_tbl, old_hash)))
+		rhashtable_rehash_one(ht, old_hash);
+	spin_unlock_bh(old_bucket_lock);
+}
+
+static void rhashtable_rehash(struct rhashtable *ht,
+			      struct bucket_table *new_tbl)
+{
+	struct *old_tbl = rht_dereference(ht->tbl, ht);
+
+	get_random_bytes(&new_tbl->hash_rnd, sizeof(new_tbl->hash_rnd));
+
+	/* Make insertions go into the new, empty table right away. Deletions
+	 * and lookups will be attempted in both tables until we synchronize.
+	 * The synchronize_rcu() guarantees for the new table to be picked up
+	 * so no new additions go into the old table while we relink.
+	 */
+	rcu_assign_pointer(ht->future_tbl, new_tbl);
+	synchronize_rcu();
+
+	for (old_hash = 0; i < old_tbl->size; old_hash++)
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
+}
+
 /**
  * rhashtable_expand - Expand hash table while allowing concurrent lookups
  * @ht:		the hash table to expand
@@ -327,72 +410,8 @@ int rhashtable_expand(struct rhashtable *ht)
 
 	atomic_inc(&ht->shift);
 
-	/* Make insertions go into the new, empty table right away. Deletions
-	 * and lookups will be attempted in both tables until we synchronize.
-	 * The synchronize_rcu() guarantees for the new table to be picked up
-	 * so no new additions go into the old table while we relink.
-	 */
-	rcu_assign_pointer(ht->future_tbl, new_tbl);
-	synchronize_rcu();
-
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
-		old_bucket_lock = bucket_lock(old_tbl, old_hash);
-
-		spin_lock_bh(old_bucket_lock);
-		rht_for_each(he, old_tbl, old_hash) {
-			if (head_hashfn(ht, new_tbl, he) == new_hash) {
-				link_old_to_new(new_tbl, new_hash, he);
-				break;
-			}
-		}
-		spin_unlock_bh(old_bucket_lock);
-	}
-
-	/* Publish the new table pointer. Lookups may now traverse
-	 * the new table, but they will not benefit from any
-	 * additional efficiency until later steps unzip the buckets.
-	 */
-	rcu_assign_pointer(ht->tbl, new_tbl);
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
-			struct rhash_head *head;
-
-			old_bucket_lock = bucket_lock(old_tbl, old_hash);
-			spin_lock_bh(old_bucket_lock);
-
-			hashtable_chain_unzip(ht, new_tbl, old_tbl, old_hash);
-			head = rht_dereference_bucket(old_tbl->buckets[old_hash],
-						      old_tbl, old_hash);
-			if (!rht_is_a_nulls(head))
-				complete = false;
-
-			spin_unlock_bh(old_bucket_lock);
-		}
-	}
+	rhashtable_rehash(ht, new_tbl);
 
-	bucket_table_free(old_tbl);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rhashtable_expand);
@@ -425,57 +444,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	rcu_assign_pointer(ht->future_tbl, new_tbl);
-	synchronize_rcu();
-
-	/* Link the first entry in the old bucket to the end of the
-	 * bucket in the new table. As entries are concurrently being
-	 * added to the new table, lock down the new bucket. As we
-	 * always divide the size in half when shrinking, each bucket
-	 * in the new table maps to exactly two buckets in the old
-	 * table.
-	 *
-	 * As removals can occur concurrently on the old table, we need
-	 * to lock down both matching buckets in the old table.
-	 */
-	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
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
-
-		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
-				   tbl->buckets[new_hash]);
-		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
-				   tbl->buckets[new_hash + new_tbl->size]);
-
-		spin_unlock_bh(new_bucket_lock);
-		if (old_bucket_lock1 != old_bucket_lock2)
-			spin_unlock_bh(old_bucket_lock2);
-		spin_unlock_bh(old_bucket_lock1);
-	}
-
-	/* Publish the new, valid hash table */
-	rcu_assign_pointer(ht->tbl, new_tbl);
-	atomic_dec(&ht->shift);
-
-	/* Wait for readers. No new readers will have references to the
-	 * old hash table.
-	 */
-	synchronize_rcu();
-
-	bucket_table_free(tbl);
+	rhashtable_rehash(ht, new_tbl);
 
 	return 0;
 }

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
