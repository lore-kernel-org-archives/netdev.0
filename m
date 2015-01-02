From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/9] rhashtable: Per bucket locks & deferred expansion/shrinking
Date: Fri,  2 Jan 2015 23:00:20 +0100
Message-ID: <a746063f4fdb433d110e0a5945efe8b6b0f39bc7.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces an array of spinlocks to protect bucket mutations. The number
of spinlocks per CPU is configurable and selected based on the hash of
the bucket. This allows for parallel insertions and removals of entries
which do not share a lock.

The patch also defers expansion and shrinking to a worker queue which
allows insertion and removal from atomic context. Insertions and
deletions may occur in parallel to it and are only held up briefly
while the particular bucket is linked or unzipped.

Mutations of the bucket table pointer is protected by a new mutex, read
access is RCU protected.

In the event of an expansion or shrinking, the new bucket table allocated
is exposed as a so called future table as soon as the resize process
starts.  Lookups, deletions, and insertions will briefly use both tables.
The future table becomes the main table after an RCU grace period and
initial linking of the old to the new table was performed. Optimization
of the chains to make use of the new number of buckets follows only the
new table is in use.

The side effect of this is that during that RCU grace period, a bucket
traversal using any rht_for_each() variant on the main table will not see
any insertions performed during the RCU grace period which would at that
point land in the future table. The lookup will see them as it searches
both tables if needed.

Having multiple insertions and removals occur in parallel requires nelems
to become an atomic counter.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |  37 ++--
 lib/rhashtable.c           | 458 ++++++++++++++++++++++++++++++++++-----------
 net/netfilter/nft_hash.c   |  27 ++-
 net/netlink/af_netlink.c   |  15 +-
 4 files changed, 384 insertions(+), 153 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index f624d4b..a1688f0 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -19,6 +19,7 @@
 #define _LINUX_RHASHTABLE_H
 
 #include <linux/rculist.h>
+#include <linux/workqueue.h>
 
 struct rhash_head {
 	struct rhash_head __rcu		*next;
@@ -26,8 +27,17 @@ struct rhash_head {
 
 #define INIT_HASH_HEAD(ptr) ((ptr)->next = NULL)
 
+/**
+ * struct bucket_table - Table of hash buckets
+ * @size: Number of hash buckets
+ * @locks_mask: Mask to apply before accessing locks[]
+ * @locks: Array of spinlocks protecting individual buckets
+ * @buckets: size * hash buckets
+ */
 struct bucket_table {
 	size_t				size;
+	unsigned int			locks_mask;
+	spinlock_t			*locks;
 	struct rhash_head __rcu		*buckets[];
 };
 
@@ -45,11 +55,11 @@ struct rhashtable;
  * @hash_rnd: Seed to use while hashing
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
+ * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
  * @grow_decision: If defined, may return true if table should expand
  * @shrink_decision: If defined, may return true if table should shrink
- * @mutex_is_held: Must return true if protecting mutex is held
  */
 struct rhashtable_params {
 	size_t			nelem_hint;
@@ -59,37 +69,42 @@ struct rhashtable_params {
 	u32			hash_rnd;
 	size_t			max_shift;
 	size_t			min_shift;
+	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
 	bool			(*grow_decision)(const struct rhashtable *ht,
 						 size_t new_size);
 	bool			(*shrink_decision)(const struct rhashtable *ht,
 						   size_t new_size);
-#ifdef CONFIG_PROVE_LOCKING
-	int			(*mutex_is_held)(void *parent);
-	void			*parent;
-#endif
 };
 
 /**
  * struct rhashtable - Hash table handle
  * @tbl: Bucket table
+ * @future_tbl: Table under construction during expansion/shrinking
  * @nelems: Number of elements in table
  * @shift: Current size (1 << shift)
  * @p: Configuration parameters
+ * @run_work: Deferred worker to expand/shrink asynchronously
+ * @mutex: Mutex to protect current/future table swapping
+ * @being_destroyed: True if table is set up for destruction
  */
 struct rhashtable {
 	struct bucket_table __rcu	*tbl;
-	size_t				nelems;
+	struct bucket_table __rcu       *future_tbl;
+	atomic_t			nelems;
 	size_t				shift;
 	struct rhashtable_params	p;
+	struct delayed_work             run_work;
+	struct mutex                    mutex;
+	bool                            being_destroyed;
 };
 
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_rht_mutex_is_held(const struct rhashtable *ht);
+int lockdep_rht_mutex_is_held(struct rhashtable *ht);
 int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash);
 #else
-static inline int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
+static inline int lockdep_rht_mutex_is_held(struct rhashtable *ht)
 {
 	return 1;
 }
@@ -112,11 +127,11 @@ bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size);
 int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
-void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
-void *rhashtable_lookup_compare(const struct rhashtable *ht, const void *key,
+void *rhashtable_lookup(struct rhashtable *ht, const void *key);
+void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg);
 
-void rhashtable_destroy(const struct rhashtable *ht);
+void rhashtable_destroy(struct rhashtable *ht);
 
 #define rht_dereference(p, ht) \
 	rcu_dereference_protected(p, lockdep_rht_mutex_is_held(ht))
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e6b85c4..312e343 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -26,19 +26,42 @@
 
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4UL
+#define BUCKET_LOCKS_PER_CPU   128UL
+
+enum {
+	RHT_LOCK_NORMAL,
+	RHT_LOCK_NESTED,
+	RHT_LOCK_NESTED2,
+};
+
+/* The bucket lock is selected based on the hash and protects mutations
+ * on a group of hash buckets.
+ *
+ * IMPORTANT: When holding the bucket lock of both the old and new table
+ * during expansions and shrinking, the old bucket lock must always be
+ * acquired first.
+ */
+static spinlock_t *bucket_lock(const struct bucket_table *tbl, u32 hash)
+{
+	return &tbl->locks[hash & tbl->locks_mask];
+}
 
 #define ASSERT_RHT_MUTEX(HT) BUG_ON(!lockdep_rht_mutex_is_held(HT))
+#define ASSERT_BUCKET_LOCK(TBL, HASH) \
+	BUG_ON(!lockdep_rht_bucket_is_held(TBL, HASH))
 
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
+int lockdep_rht_mutex_is_held(struct rhashtable *ht)
 {
-	return ht->p.mutex_is_held(ht->p.parent);
+	return (debug_locks) ? lockdep_is_held(&ht->mutex) : 1;
 }
 EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
 
 int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash)
 {
-	return 1;
+	spinlock_t *lock = bucket_lock(tbl, hash);
+
+	return (debug_locks) ? lockdep_is_held(lock) : 1;
 }
 EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
 #endif
@@ -66,7 +89,7 @@ static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
 	return hash;
 }
 
-static u32 key_hashfn(const struct rhashtable *ht, const void *key, u32 len)
+static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
 {
 	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
@@ -95,7 +118,49 @@ static struct rhash_head __rcu **bucket_tail(struct bucket_table *tbl, u32 n)
 	return pprev;
 }
 
-static struct bucket_table *bucket_table_alloc(size_t nbuckets)
+static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
+{
+	unsigned int i, size;
+#if defined(CONFIG_PROVE_LOCKING)
+	unsigned int nr_pcpus = 2;
+#else
+	unsigned int nr_pcpus = num_possible_cpus();
+#endif
+
+	nr_pcpus = min_t(unsigned int, nr_pcpus, 32UL);
+	size = roundup_pow_of_two(nr_pcpus * ht->p.locks_mul);
+
+	/* Never allocate more than one lock per bucket */
+	size = min_t(unsigned int, size, tbl->size);
+
+	if (sizeof(spinlock_t) != 0) {
+#ifdef CONFIG_NUMA
+		if (size * sizeof(spinlock_t) > PAGE_SIZE)
+			tbl->locks = vmalloc(size * sizeof(spinlock_t));
+		else
+#endif
+		tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
+					   GFP_KERNEL);
+		if (!tbl->locks)
+			return -ENOMEM;
+		for (i = 0; i < size; i++)
+			spin_lock_init(&tbl->locks[i]);
+	}
+	tbl->locks_mask = size - 1;
+
+	return 0;
+}
+
+static void bucket_table_free(const struct bucket_table *tbl)
+{
+	if (tbl)
+		kvfree(tbl->locks);
+
+	kvfree(tbl);
+}
+
+static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
+					       size_t nbuckets)
 {
 	struct bucket_table *tbl;
 	size_t size;
@@ -110,12 +175,12 @@ static struct bucket_table *bucket_table_alloc(size_t nbuckets)
 
 	tbl->size = nbuckets;
 
-	return tbl;
-}
+	if (alloc_bucket_locks(ht, tbl) < 0) {
+		bucket_table_free(tbl);
+		return NULL;
+	}
 
-static void bucket_table_free(const struct bucket_table *tbl)
-{
-	kvfree(tbl);
+	return tbl;
 }
 
 /**
@@ -126,7 +191,7 @@ static void bucket_table_free(const struct bucket_table *tbl)
 bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
 {
 	/* Expand table when exceeding 75% load */
-	return ht->nelems > (new_size / 4 * 3);
+	return atomic_read(&ht->nelems) > (new_size / 4 * 3);
 }
 EXPORT_SYMBOL_GPL(rht_grow_above_75);
 
@@ -138,41 +203,59 @@ EXPORT_SYMBOL_GPL(rht_grow_above_75);
 bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
 {
 	/* Shrink table beneath 30% load */
-	return ht->nelems < (new_size * 3 / 10);
+	return atomic_read(&ht->nelems) < (new_size * 3 / 10);
 }
 EXPORT_SYMBOL_GPL(rht_shrink_below_30);
 
 static void hashtable_chain_unzip(const struct rhashtable *ht,
 				  const struct bucket_table *new_tbl,
-				  struct bucket_table *old_tbl, size_t n)
+				  struct bucket_table *old_tbl,
+				  size_t old_hash)
 {
 	struct rhash_head *he, *p, *next;
-	unsigned int h;
+	spinlock_t *new_bucket_lock, *new_bucket_lock2 = NULL;
+	unsigned int new_hash, new_hash2;
+
+	ASSERT_BUCKET_LOCK(old_tbl, old_hash);
 
 	/* Old bucket empty, no work needed. */
-	p = rht_dereference(old_tbl->buckets[n], ht);
+	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
+				   old_hash);
 	if (!p)
 		return;
 
+	new_hash = new_hash2 = head_hashfn(ht, new_tbl, p);
+	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+
 	/* Advance the old bucket pointer one or more times until it
 	 * reaches a node that doesn't hash to the same bucket as the
 	 * previous node p. Call the previous node p;
 	 */
-	h = head_hashfn(ht, new_tbl, p);
-	rht_for_each_continue(he, p->next, old_tbl, n) {
-		if (head_hashfn(ht, new_tbl, he) != h)
+	rht_for_each_continue(he, p->next, old_tbl, old_hash) {
+		new_hash2 = head_hashfn(ht, new_tbl, he);
+		if (new_hash != new_hash2)
 			break;
 		p = he;
 	}
-	RCU_INIT_POINTER(old_tbl->buckets[n], p->next);
+	rcu_assign_pointer(old_tbl->buckets[old_hash], p->next);
+
+	spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
+
+	/* If we have encountered an entry that maps to a different bucket in
+	 * the new table, lock down that bucket as well as we might cut off
+	 * the end of the chain.
+	 */
+	new_bucket_lock2 = bucket_lock(new_tbl, new_hash);
+	if (new_bucket_lock != new_bucket_lock2)
+		spin_lock_bh_nested(new_bucket_lock2, RHT_LOCK_NESTED2);
 
 	/* Find the subsequent node which does hash to the same
 	 * bucket as node P, or NULL if no such node exists.
 	 */
 	next = NULL;
 	if (he) {
-		rht_for_each_continue(he, he->next, old_tbl, n) {
-			if (head_hashfn(ht, new_tbl, he) == h) {
+		rht_for_each_continue(he, he->next, old_tbl, old_hash) {
+			if (head_hashfn(ht, new_tbl, he) == new_hash) {
 				next = he;
 				break;
 			}
@@ -182,7 +265,23 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	/* Set p's next pointer to that subsequent node pointer,
 	 * bypassing the nodes which do not hash to p's bucket
 	 */
-	RCU_INIT_POINTER(p->next, next);
+	rcu_assign_pointer(p->next, next);
+
+	if (new_bucket_lock != new_bucket_lock2)
+		spin_unlock_bh(new_bucket_lock2);
+	spin_unlock_bh(new_bucket_lock);
+}
+
+static void link_old_to_new(struct bucket_table *new_tbl,
+			    unsigned int new_hash, struct rhash_head *entry)
+{
+	spinlock_t *new_bucket_lock;
+
+	new_bucket_lock = bucket_lock(new_tbl, new_hash);
+
+	spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED);
+	rcu_assign_pointer(*bucket_tail(new_tbl, new_hash), entry);
+	spin_unlock_bh(new_bucket_lock);
 }
 
 /**
@@ -195,43 +294,59 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
  * This function may only be called in a context where it is safe to call
  * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
  *
- * The caller must ensure that no concurrent table mutations take place.
- * It is however valid to have concurrent lookups if they are RCU protected.
+ * The caller must ensure that no concurrent resizing occurs by holding
+ * ht->mutex.
+ *
+ * It is valid to have concurrent insertions and deletions protected by per
+ * bucket locks or concurrent RCU protected lookups and traversals.
  */
 int rhashtable_expand(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
 	struct rhash_head *he;
-	unsigned int i, h;
-	bool complete;
+	spinlock_t *old_bucket_lock;
+	unsigned int new_hash, old_hash;
+	bool complete = false;
 
 	ASSERT_RHT_MUTEX(ht);
 
 	if (ht->p.max_shift && ht->shift >= ht->p.max_shift)
 		return 0;
 
-	new_tbl = bucket_table_alloc(old_tbl->size * 2);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
 	ht->shift++;
 
-	/* For each new bucket, search the corresponding old bucket
-	 * for the first entry that hashes to the new bucket, and
-	 * link the new bucket to that entry. Since all the entries
-	 * which will end up in the new bucket appear in the same
-	 * old bucket, this constructs an entirely valid new hash
-	 * table, but with multiple buckets "zipped" together into a
-	 * single imprecise chain.
+	/* Make insertions go into the new, empty table right away. Deletions
+	 * and lookups will be attempted in both tables until we synchronize.
+	 * The synchronize_rcu() guarantees for the new table to be picked up
+	 * so no new additions go into the old table while we relink.
+	 */
+	rcu_assign_pointer(ht->future_tbl, new_tbl);
+	synchronize_rcu();
+
+	/* For each new bucket, search the corresponding old bucket for the
+	 * first entry that hashes to the new bucket, and link the end of
+	 * newly formed bucket chain (containing entries added to future
+	 * table) to that entry. Since all the entries which will end up in
+	 * the new bucket appear in the same old bucket, this constructs an
+	 * entirely valid new hash table, but with multiple buckets
+	 * "zipped" together into a single imprecise chain.
 	 */
-	for (i = 0; i < new_tbl->size; i++) {
-		h = rht_bucket_index(old_tbl, i);
-		rht_for_each(he, old_tbl, h) {
-			if (head_hashfn(ht, new_tbl, he) == i) {
-				RCU_INIT_POINTER(new_tbl->buckets[i], he);
+	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
+		old_hash = rht_bucket_index(old_tbl, new_hash);
+		old_bucket_lock = bucket_lock(old_tbl, old_hash);
+
+		spin_lock_bh(old_bucket_lock);
+		rht_for_each(he, old_tbl, old_hash) {
+			if (head_hashfn(ht, new_tbl, he) == new_hash) {
+				link_old_to_new(new_tbl, new_hash, he);
 				break;
 			}
 		}
+		spin_unlock_bh(old_bucket_lock);
 	}
 
 	/* Publish the new table pointer. Lookups may now traverse
@@ -241,7 +356,7 @@ int rhashtable_expand(struct rhashtable *ht)
 	rcu_assign_pointer(ht->tbl, new_tbl);
 
 	/* Unzip interleaved hash chains */
-	do {
+	while (!complete && !ht->being_destroyed) {
 		/* Wait for readers. All new readers will see the new
 		 * table, and thus no references to the old table will
 		 * remain.
@@ -253,12 +368,17 @@ int rhashtable_expand(struct rhashtable *ht)
 		 * table): ...
 		 */
 		complete = true;
-		for (i = 0; i < old_tbl->size; i++) {
-			hashtable_chain_unzip(ht, new_tbl, old_tbl, i);
-			if (old_tbl->buckets[i] != NULL)
+		for (old_hash = 0; old_hash < old_tbl->size; old_hash++) {
+			old_bucket_lock = bucket_lock(old_tbl, old_hash);
+			spin_lock_bh(old_bucket_lock);
+
+			hashtable_chain_unzip(ht, new_tbl, old_tbl, old_hash);
+			if (old_tbl->buckets[old_hash] != NULL)
 				complete = false;
+
+			spin_unlock_bh(old_bucket_lock);
 		}
-	} while (!complete);
+	}
 
 	bucket_table_free(old_tbl);
 	return 0;
@@ -272,38 +392,65 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
  * This function may only be called in a context where it is safe to call
  * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
  *
+ * The caller must ensure that no concurrent resizing occurs by holding
+ * ht->mutex.
+ *
  * The caller must ensure that no concurrent table mutations take place.
  * It is however valid to have concurrent lookups if they are RCU protected.
+ *
+ * It is valid to have concurrent insertions and deletions protected by per
+ * bucket locks or concurrent RCU protected lookups and traversals.
  */
 int rhashtable_shrink(struct rhashtable *ht)
 {
-	struct bucket_table *ntbl, *tbl = rht_dereference(ht->tbl, ht);
-	unsigned int i;
+	struct bucket_table *new_tbl, *tbl = rht_dereference(ht->tbl, ht);
+	spinlock_t *new_bucket_lock, *old_bucket_lock1, *old_bucket_lock2;
+	unsigned int new_hash;
 
 	ASSERT_RHT_MUTEX(ht);
 
 	if (ht->shift <= ht->p.min_shift)
 		return 0;
 
-	ntbl = bucket_table_alloc(tbl->size / 2);
-	if (ntbl == NULL)
+	new_tbl = bucket_table_alloc(ht, tbl->size / 2);
+	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	ht->shift--;
+	rcu_assign_pointer(ht->future_tbl, new_tbl);
+	synchronize_rcu();
 
-	/* Link each bucket in the new table to the first bucket
-	 * in the old table that contains entries which will hash
-	 * to the new bucket.
+	/* Link the first entry in the old bucket to the end of the
+	 * bucket in the new table. As entries are concurrently being
+	 * added to the new table, lock down the new bucket. As we
+	 * always divide the size in half when shrinking, each bucket
+	 * in the new table maps to exactly two buckets in the old
+	 * table.
+	 *
+	 * As removals can occur concurrently on the old table, we need
+	 * to lock down both matching buckets in the old table.
 	 */
-	for (i = 0; i < ntbl->size; i++) {
-		ntbl->buckets[i] = tbl->buckets[i];
-		RCU_INIT_POINTER(*bucket_tail(ntbl, i),
-				 tbl->buckets[i + ntbl->size]);
-
+	for (new_hash = 0; new_hash < new_tbl->size; new_hash++) {
+		old_bucket_lock1 = bucket_lock(tbl, new_hash);
+		old_bucket_lock2 = bucket_lock(tbl, new_hash + new_tbl->size);
+		new_bucket_lock = bucket_lock(new_tbl, new_hash);
+
+		spin_lock_bh(old_bucket_lock1);
+		spin_lock_bh_nested(old_bucket_lock2, RHT_LOCK_NESTED);
+		spin_lock_bh_nested(new_bucket_lock, RHT_LOCK_NESTED2);
+
+		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
+				   tbl->buckets[new_hash]);
+		rcu_assign_pointer(*bucket_tail(new_tbl, new_hash),
+				   tbl->buckets[new_hash + new_tbl->size]);
+
+		spin_unlock_bh(new_bucket_lock);
+		spin_unlock_bh(old_bucket_lock2);
+		spin_unlock_bh(old_bucket_lock1);
 	}
 
 	/* Publish the new, valid hash table */
-	rcu_assign_pointer(ht->tbl, ntbl);
+	rcu_assign_pointer(ht->tbl, new_tbl);
+	ht->shift--;
 
 	/* Wait for readers. No new readers will have references to the
 	 * old hash table.
@@ -316,31 +463,63 @@ int rhashtable_shrink(struct rhashtable *ht)
 }
 EXPORT_SYMBOL_GPL(rhashtable_shrink);
 
+static void rht_deferred_worker(struct work_struct *work)
+{
+	struct rhashtable *ht;
+	struct bucket_table *tbl;
+
+	ht = container_of(work, struct rhashtable, run_work.work);
+	mutex_lock(&ht->mutex);
+	tbl = rht_dereference(ht->tbl, ht);
+
+	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+		rhashtable_expand(ht);
+	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
+		rhashtable_shrink(ht);
+
+	mutex_unlock(&ht->mutex);
+}
+
 /**
  * rhashtable_insert - insert object into hash hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
  *
- * Will automatically grow the table via rhashtable_expand() if the the
- * grow_decision function specified at rhashtable_init() returns true.
+ * Will take a per bucket spinlock to protect against mutual mutations
+ * on the same bucket. Multiple insertions may occur in parallel unless
+ * they map to the same bucket lock.
  *
- * The caller must ensure that no concurrent table mutations occur. It is
- * however valid to have concurrent lookups if they are RCU protected.
+ * It is safe to call this function from atomic context.
+ *
+ * Will trigger an automatic deferred table resizing if the size grows
+ * beyond the watermark indicated by grow_decision() which can be passed
+ * to rhashtable_init().
  */
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
-	u32 hash;
+	struct bucket_table *tbl;
+	spinlock_t *lock;
+	unsigned hash;
 
-	ASSERT_RHT_MUTEX(ht);
+	rcu_read_lock();
 
+	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	hash = head_hashfn(ht, tbl, obj);
+	lock = bucket_lock(tbl, hash);
+
+	spin_lock_bh(lock);
 	RCU_INIT_POINTER(obj->next, tbl->buckets[hash]);
 	rcu_assign_pointer(tbl->buckets[hash], obj);
-	ht->nelems++;
+	spin_unlock_bh(lock);
 
-	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
-		rhashtable_expand(ht);
+	atomic_inc(&ht->nelems);
+
+	/* Only grow the table if no resizing is currently in progress. */
+	if (ht->tbl != ht->future_tbl &&
+	    ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+		schedule_delayed_work(&ht->run_work, 0);
+
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(rhashtable_insert);
 
@@ -361,32 +540,56 @@ EXPORT_SYMBOL_GPL(rhashtable_insert);
  */
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
+	struct bucket_table *tbl;
 	struct rhash_head __rcu **pprev;
 	struct rhash_head *he;
-	u32 h;
+	spinlock_t *lock;
+	unsigned int hash;
 
-	ASSERT_RHT_MUTEX(ht);
+	rcu_read_lock();
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = head_hashfn(ht, tbl, obj);
 
-	h = head_hashfn(ht, tbl, obj);
+	lock = bucket_lock(tbl, hash);
+	spin_lock_bh(lock);
 
-	pprev = &tbl->buckets[h];
-	rht_for_each(he, tbl, h) {
+restart:
+	pprev = &tbl->buckets[hash];
+	rht_for_each(he, tbl, hash) {
 		if (he != obj) {
 			pprev = &he->next;
 			continue;
 		}
 
-		RCU_INIT_POINTER(*pprev, he->next);
-		ht->nelems--;
+		rcu_assign_pointer(*pprev, obj->next);
+		atomic_dec(&ht->nelems);
 
-		if (ht->p.shrink_decision &&
+		spin_unlock_bh(lock);
+
+		if (ht->tbl != ht->future_tbl &&
+		    ht->p.shrink_decision &&
 		    ht->p.shrink_decision(ht, tbl->size))
-			rhashtable_shrink(ht);
+			schedule_delayed_work(&ht->run_work, 0);
+
+		rcu_read_unlock();
 
 		return true;
 	}
 
+	if (tbl != rht_dereference_rcu(ht->tbl, ht)) {
+		spin_unlock_bh(lock);
+
+		tbl = rht_dereference_rcu(ht->tbl, ht);
+		hash = head_hashfn(ht, tbl, obj);
+
+		lock = bucket_lock(tbl, hash);
+		spin_lock_bh(lock);
+		goto restart;
+	}
+
+	spin_unlock_bh(lock);
+	rcu_read_unlock();
+
 	return false;
 }
 EXPORT_SYMBOL_GPL(rhashtable_remove);
@@ -402,25 +605,35 @@ EXPORT_SYMBOL_GPL(rhashtable_remove);
  * This lookup function may only be used for fixed key hash table (key_len
  * paramter set). It will BUG() if used inappropriately.
  *
- * Lookups may occur in parallel with hash mutations as long as the lookup is
- * guarded by rcu_read_lock(). The caller must take care of this.
+ * Lookups may occur in parallel with hashtable mutations and resizing.
  */
-void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
+void *rhashtable_lookup(struct rhashtable *ht, const void *key)
 {
-	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+	const struct bucket_table *tbl, *old_tbl;
 	struct rhash_head *he;
-	u32 h;
+	u32 hash;
 
 	BUG_ON(!ht->p.key_len);
 
-	h = key_hashfn(ht, key, ht->p.key_len);
-	rht_for_each_rcu(he, tbl, h) {
+	rcu_read_lock();
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	hash = key_hashfn(ht, key, ht->p.key_len);
+restart:
+	rht_for_each_rcu(he, tbl, rht_bucket_index(tbl, hash)) {
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
 			continue;
+		rcu_read_unlock();
 		return rht_obj(ht, he);
 	}
 
+	if (unlikely(tbl != old_tbl)) {
+		tbl = old_tbl;
+		goto restart;
+	}
+
+	rcu_read_unlock();
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup);
@@ -435,25 +648,36 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
  * Traverses the bucket chain behind the provided hash value and calls the
  * specified compare function for each entry.
  *
- * Lookups may occur in parallel with hash mutations as long as the lookup is
- * guarded by rcu_read_lock(). The caller must take care of this.
+ * Lookups may occur in parallel with hashtable mutations and resizing.
  *
  * Returns the first entry on which the compare function returned true.
  */
-void *rhashtable_lookup_compare(const struct rhashtable *ht, const void *key,
+void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 				bool (*compare)(void *, void *), void *arg)
 {
-	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+	const struct bucket_table *tbl, *old_tbl;
 	struct rhash_head *he;
 	u32 hash;
 
+	rcu_read_lock();
+
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	hash = key_hashfn(ht, key, ht->p.key_len);
-	rht_for_each_rcu(he, tbl, hash) {
+restart:
+	rht_for_each_rcu(he, tbl, rht_bucket_index(tbl, hash)) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
+		rcu_read_unlock();
 		return rht_obj(ht, he);
 	}
 
+	if (unlikely(tbl != old_tbl)) {
+		tbl = old_tbl;
+		goto restart;
+	}
+	rcu_read_unlock();
+
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
@@ -485,9 +709,6 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.key_offset = offsetof(struct test_obj, key),
  *	.key_len = sizeof(int),
  *	.hashfn = jhash,
- * #ifdef CONFIG_PROVE_LOCKING
- *	.mutex_is_held = &my_mutex_is_held,
- * #endif
  * };
  *
  * Configuration Example 2: Variable length keys
@@ -507,9 +728,6 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.head_offset = offsetof(struct test_obj, node),
  *	.hashfn = jhash,
  *	.obj_hashfn = my_hash_fn,
- * #ifdef CONFIG_PROVE_LOCKING
- *	.mutex_is_held = &my_mutex_is_held,
- * #endif
  * };
  */
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
@@ -529,18 +747,29 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(params);
 
-	tbl = bucket_table_alloc(size);
+	memset(ht, 0, sizeof(*ht));
+	mutex_init(&ht->mutex);
+	memcpy(&ht->p, params, sizeof(*params));
+
+	if (params->locks_mul)
+		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
+	else
+		ht->p.locks_mul = BUCKET_LOCKS_PER_CPU;
+
+	tbl = bucket_table_alloc(ht, size);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-	memset(ht, 0, sizeof(*ht));
 	ht->shift = ilog2(tbl->size);
-	memcpy(&ht->p, params, sizeof(*params));
 	RCU_INIT_POINTER(ht->tbl, tbl);
+	RCU_INIT_POINTER(ht->future_tbl, tbl);
 
 	if (!ht->p.hash_rnd)
 		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
 
+	if (ht->p.grow_decision || ht->p.shrink_decision)
+		INIT_DEFERRABLE_WORK(&ht->run_work, rht_deferred_worker);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rhashtable_init);
@@ -553,9 +782,16 @@ EXPORT_SYMBOL_GPL(rhashtable_init);
  * has to make sure that no resizing may happen by unpublishing the hashtable
  * and waiting for the quiescent cycle before releasing the bucket array.
  */
-void rhashtable_destroy(const struct rhashtable *ht)
+void rhashtable_destroy(struct rhashtable *ht)
 {
-	bucket_table_free(ht->tbl);
+	ht->being_destroyed = true;
+
+	mutex_lock(&ht->mutex);
+
+	cancel_delayed_work(&ht->run_work);
+	bucket_table_free(rht_dereference(ht->tbl, ht));
+
+	mutex_unlock(&ht->mutex);
 }
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
 
@@ -570,13 +806,6 @@ EXPORT_SYMBOL_GPL(rhashtable_destroy);
 #define TEST_PTR	((void *) 0xdeadbeef)
 #define TEST_NEXPANDS	4
 
-#ifdef CONFIG_PROVE_LOCKING
-static int test_mutex_is_held(void *parent)
-{
-	return 1;
-}
-#endif
-
 struct test_obj {
 	void			*ptr;
 	int			value;
@@ -646,10 +875,10 @@ static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 				i, tbl->buckets[i], cnt);
 	}
 
-	pr_info("  Traversal complete: counted=%u, nelems=%zu, entries=%d\n",
-		total, ht->nelems, TEST_ENTRIES);
+	pr_info("  Traversal complete: counted=%u, nelems=%u, entries=%d\n",
+		total, atomic_read(&ht->nelems), TEST_ENTRIES);
 
-	if (total != ht->nelems || total != TEST_ENTRIES)
+	if (total != atomic_read(&ht->nelems) || total != TEST_ENTRIES)
 		pr_warn("Test failed: Total count mismatch ^^^");
 }
 
@@ -688,7 +917,9 @@ static int __init test_rhashtable(struct rhashtable *ht)
 
 	for (i = 0; i < TEST_NEXPANDS; i++) {
 		pr_info("  Table expansion iteration %u...\n", i);
+		mutex_lock(&ht->mutex);
 		rhashtable_expand(ht);
+		mutex_unlock(&ht->mutex);
 
 		rcu_read_lock();
 		pr_info("  Verifying lookups...\n");
@@ -698,7 +929,9 @@ static int __init test_rhashtable(struct rhashtable *ht)
 
 	for (i = 0; i < TEST_NEXPANDS; i++) {
 		pr_info("  Table shrinkage iteration %u...\n", i);
+		mutex_lock(&ht->mutex);
 		rhashtable_shrink(ht);
+		mutex_unlock(&ht->mutex);
 
 		rcu_read_lock();
 		pr_info("  Verifying lookups...\n");
@@ -741,9 +974,6 @@ static int __init test_rht_init(void)
 		.key_offset = offsetof(struct test_obj, value),
 		.key_len = sizeof(int),
 		.hashfn = jhash,
-#ifdef CONFIG_PROVE_LOCKING
-		.mutex_is_held = &test_mutex_is_held,
-#endif
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
 	};
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 7f903cf..75887d7 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -33,7 +33,7 @@ static bool nft_hash_lookup(const struct nft_set *set,
 			    const struct nft_data *key,
 			    struct nft_data *data)
 {
-	const struct rhashtable *priv = nft_set_priv(set);
+	struct rhashtable *priv = nft_set_priv(set);
 	const struct nft_hash_elem *he;
 
 	he = rhashtable_lookup(priv, key);
@@ -113,7 +113,7 @@ static bool nft_hash_compare(void *ptr, void *arg)
 
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 {
-	const struct rhashtable *priv = nft_set_priv(set);
+	struct rhashtable *priv = nft_set_priv(set);
 	struct nft_compare_arg arg = {
 		.set = set,
 		.elem = elem,
@@ -129,7 +129,7 @@ static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			  struct nft_set_iter *iter)
 {
-	const struct rhashtable *priv = nft_set_priv(set);
+	struct rhashtable *priv = nft_set_priv(set);
 	const struct bucket_table *tbl;
 	const struct nft_hash_elem *he;
 	struct nft_set_elem elem;
@@ -162,13 +162,6 @@ static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 	return sizeof(struct rhashtable);
 }
 
-#ifdef CONFIG_PROVE_LOCKING
-static int lockdep_nfnl_lock_is_held(void *parent)
-{
-	return lockdep_nfnl_is_held(NFNL_SUBSYS_NFTABLES);
-}
-#endif
-
 static int nft_hash_init(const struct nft_set *set,
 			 const struct nft_set_desc *desc,
 			 const struct nlattr * const tb[])
@@ -182,9 +175,6 @@ static int nft_hash_init(const struct nft_set *set,
 		.hashfn = jhash,
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
-#ifdef CONFIG_PROVE_LOCKING
-		.mutex_is_held = lockdep_nfnl_lock_is_held,
-#endif
 	};
 
 	return rhashtable_init(priv, &params);
@@ -192,16 +182,23 @@ static int nft_hash_init(const struct nft_set *set,
 
 static void nft_hash_destroy(const struct nft_set *set)
 {
-	const struct rhashtable *priv = nft_set_priv(set);
-	const struct bucket_table *tbl = priv->tbl;
+	struct rhashtable *priv = nft_set_priv(set);
+	const struct bucket_table *tbl;
 	struct nft_hash_elem *he;
 	struct rhash_head *pos, *next;
 	unsigned int i;
 
+	/* Stop an eventual async resizing */
+	priv->being_destroyed = true;
+	mutex_lock(&priv->mutex);
+
+	tbl = rht_dereference(priv->tbl, priv);
 	for (i = 0; i < tbl->size; i++) {
 		rht_for_each_entry_safe(he, pos, next, tbl, i, node)
 			nft_hash_elem_destroy(set, he);
 	}
+	mutex_unlock(&priv->mutex);
+
 	rhashtable_destroy(priv);
 }
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 57449b6..738c3bf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -114,15 +114,6 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 DEFINE_MUTEX(nl_sk_hash_lock);
 EXPORT_SYMBOL_GPL(nl_sk_hash_lock);
 
-#ifdef CONFIG_PROVE_LOCKING
-static int lockdep_nl_sk_hash_is_held(void *parent)
-{
-	if (debug_locks)
-		return lockdep_is_held(&nl_sk_hash_lock) || lockdep_is_held(&nl_table_lock);
-	return 1;
-}
-#endif
-
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
 static DEFINE_SPINLOCK(netlink_tap_lock);
@@ -1063,7 +1054,8 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 		goto err;
 
 	err = -ENOMEM;
-	if (BITS_PER_LONG > 32 && unlikely(table->hash.nelems >= UINT_MAX))
+	if (BITS_PER_LONG > 32 &&
+	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
 		goto err;
 
 	nlk_sk(sk)->portid = portid;
@@ -3122,9 +3114,6 @@ static int __init netlink_proto_init(void)
 		.max_shift = 16, /* 64K */
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
-#ifdef CONFIG_PROVE_LOCKING
-		.mutex_is_held = lockdep_nl_sk_hash_is_held,
-#endif
 	};
 
 	if (err != 0)
-- 
1.9.3
