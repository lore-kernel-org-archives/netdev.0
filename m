From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] rhashtable: Per bucket locks & expansion/shrinking in work queue
Date: Mon, 15 Sep 2014 14:18:04 +0200
Message-ID: <fe862eb8add076215918a0def9c3bd4fe8a104c7.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces an array of spinlocks to protect bucket mutations. The numbe=
r
of spinlocks per CPU is configurable and selected based on the hash of
the bucket. This allows for parallel insertions and removals of entries
which do not share a lock.

The patch also defers expansion and shrinking to a worker queue which
allow insertion and removal from atomic context. Insertions and
deletions may occur in parallel to it and are only held up briefly
while the particular bucket is linked or unzipped.

Mutations of the bucket table pointer is protected by a new mutex, read
access to that pointer for insertion and deletion is RCU protected.

In the event of an expansion or shrinking, the new bucket table allocat=
ed
is exposed as a so called future table right away. Lookups, deletions, =
and
insertions will briefly use both tables. The future table becomes the m=
ain
table after an RCU grace period and initial relinking was performed whi=
ch
guarantees that no new insertions occur on the old table but all entrie=
s
can be found.

The side effect of this is that during that RCU grace period, a bucket
traversal using any rht_for_each() variant on the main table will not s=
ee
any insertions performed during the RCU grace period which would at tha=
t
point land in the future table. The lookup will see them as it searches
both tables if needed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |  42 +++--
 lib/rhashtable.c           | 375 +++++++++++++++++++++++++++++++------=
--------
 net/netfilter/nft_hash.c   |  59 +++----
 net/netlink/af_netlink.c   |   5 +-
 4 files changed, 330 insertions(+), 151 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index e9cdbda..dc8a447 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -19,13 +19,23 @@
 #define _LINUX_RHASHTABLE_H
=20
 #include <linux/list_nulls.h>
+#include <linux/workqueue.h>
=20
 struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
=20
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
=20
@@ -44,6 +54,7 @@ struct rhashtable;
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
  * @nulls_base: Base value to generate nulls marker
+ * @locks_mul: Number of bucket locks to allocate per cpu (default: 12=
8)
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
  * @grow_decision: If defined, may return true if table should expand
@@ -59,6 +70,7 @@ struct rhashtable_params {
 	size_t			max_shift;
 	size_t			min_shift;
 	int			nulls_base;
+	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
 	bool			(*grow_decision)(const struct rhashtable *ht,
@@ -71,15 +83,23 @@ struct rhashtable_params {
 /**
  * struct rhashtable - Hash table handle
  * @tbl: Bucket table
+ * @future_tbl: Future table during expansion and shrinking
  * @nelems: Number of elements in table
  * @shift: Current size (1 << shift)
  * @p: Configuration parameters
+ * @run_work: Delayed work executing expansion/shrinking
+ * @mutex: Hold while expansion/shrinking takes places
+ * @being_destroyed: True if table is set to be destroyed
  */
 struct rhashtable {
 	struct bucket_table __rcu	*tbl;
+	struct bucket_table __rcu	*future_tbl;
 	size_t				nelems;
 	size_t				shift;
 	struct rhashtable_params	p;
+	struct delayed_work		run_work;
+	struct mutex			mutex;
+	bool				being_destroyed;
 };
=20
 static inline unsigned long rht_marker(const struct rhashtable *ht, u3=
2 hash)
@@ -101,9 +121,16 @@ static inline unsigned long rht_get_nulls_value(co=
nst struct rhash_head *ptr)
 }
=20
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_rht_mutex_is_held(const struct rhashtable *ht);
+int lockdep_rht_mutex_is_held(struct rhashtable *ht);
+int rht_bucket_lock_is_held(const struct bucket_table *tbl, u32 hash);
 #else
-static inline int lockdep_rht_mutex_is_held(const struct rhashtable *h=
t)
+static inline int lockdep_rht_mutex_is_held(struct rhashtable *ht)
+{
+	return 1;
+}
+
+static inline int lockdep_rht_bucket_is_held(const struct bucket_table=
 *tbl,
+					     u32 hash)
 {
 	return 1;
 }
@@ -112,12 +139,9 @@ static inline int lockdep_rht_mutex_is_held(const =
struct rhashtable *ht)
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *p=
arams);
=20
 u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u3=
2 len);
-u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr);
=20
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node)=
;
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node)=
;
-void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head =
*obj,
-			     struct rhash_head __rcu **pprev);
=20
 bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size);
 bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)=
;
@@ -126,10 +150,10 @@ int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
=20
 void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
-void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
+void *rhashtable_lookup_compare(const struct rhashtable *ht, const voi=
d *key,
 				bool (*compare)(void *, void *), void *arg);
=20
-void rhashtable_destroy(const struct rhashtable *ht);
+void rhashtable_destroy(struct rhashtable *ht);
=20
 #define rht_dereference(p, ht) \
 	rcu_dereference_protected(p, lockdep_rht_mutex_is_held(ht))
@@ -138,10 +162,10 @@ void rhashtable_destroy(const struct rhashtable *=
ht);
 	rcu_dereference_check(p, lockdep_rht_mutex_is_held(ht))
=20
 #define rht_dereference_bucket(p, tbl, hash) \
-	rcu_dereference_protected(p, lockdep_rht_mutex_is_held(ht))
+	rcu_dereference_protected(p, lockdep_rht_bucket_is_held(tbl, hash))
=20
 #define rht_dereference_bucket_rcu(p, tbl, hash) \
-	rcu_dereference_check(p, lockdep_rht_mutex_is_held(ht))
+	rcu_dereference_check(p, lockdep_rht_bucket_is_held(tbl, hash))
=20
 #define rht_entry(tpos, pos, member) \
 	({ tpos =3D container_of(pos, typeof(*tpos), member); 1; })
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d871483..2a6ff3d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -27,6 +27,7 @@
=20
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4UL
+#define BUCKET_LOCKS_PER_CPU	128UL
=20
 /*
  * The nulls marker consists of:
@@ -45,14 +46,42 @@
 #define HASH_BASE_MIN		(1 << (31 - HASH_BASE_BITS))
 #define HASH_RESERVED_SPACE	(HASH_BASE_BITS + 1)
=20
+/* The bucket lock is selected based on the hash and protects mutation=
s
+ * on a group of hash buckets.
+ *
+ * Important: When holding the bucket lock of both the old and new tab=
le
+ * during expansions and shrinking, the old bucket lock must always be
+ * acquired first.
+ */
+static spinlock_t *bucket_lock(const struct bucket_table *tbl, u32 has=
h)
+{
+	return &tbl->locks[hash & tbl->locks_mask];
+}
+
 #define ASSERT_RHT_MUTEX(HT) BUG_ON(!lockdep_rht_mutex_is_held(HT))
=20
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
+int lockdep_rht_mutex_is_held(struct rhashtable *ht)
 {
-	return ht->p.mutex_is_held();
+#ifdef CONFIG_LOCKDEP
+	return (debug_locks) ? lockdep_is_held(&ht->mutex) : 1;
+#else
+	return 1;
+#endif
 }
 EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
+
+int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 has=
h)
+{
+#ifdef CONFIG_LOCKDEP
+	spinlock_t *lock =3D bucket_lock(tbl, hash);
+
+	return (debug_locks) ? lockdep_is_held(lock) : 1;
+#else
+	return 1;
+#endif
+}
+EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
 #endif
=20
 static void *rht_obj(const struct rhashtable *ht, const struct rhash_h=
ead *he)
@@ -85,39 +114,19 @@ static u32 obj_raw_hashfn(const struct rhashtable =
*ht, const void *ptr)
  * @len:	length of key
  *
  * Computes the hash value using the hash function provided in the 'ha=
shfn'
- * of struct rhashtable_params. The returned value is guaranteed to be
- * smaller than the number of buckets in the hash table.
+ * of struct rhashtable_params.
  */
 u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u3=
2 len)
 {
-	struct bucket_table *tbl =3D rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
=20
 	hash =3D ht->p.hashfn(key, len, ht->p.hash_rnd);
 	hash >>=3D HASH_RESERVED_SPACE;
=20
-	return rht_bucket_index(hash, tbl);
+	return hash;
 }
 EXPORT_SYMBOL_GPL(rhashtable_hashfn);
=20
-/**
- * rhashtable_obj_hashfn - compute hash for hashed object
- * @ht:		hash table to compuate for
- * @ptr:	pointer to hashed object
- *
- * Computes the hash value using the hash function `hashfn` respective=
ly
- * 'obj_hashfn' depending on whether the hash table is set up to work =
with
- * a fixed length key. The returned value is guaranteed to be smaller =
than
- * the number of buckets in the hash table.
- */
-u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr)
-{
-	struct bucket_table *tbl =3D rht_dereference_rcu(ht->tbl, ht);
-
-	return rht_bucket_index(obj_raw_hashfn(ht, ptr), tbl);
-}
-EXPORT_SYMBOL_GPL(rhashtable_obj_hashfn);
-
 static u32 head_hashfn(const struct rhashtable *ht,
 		       const struct rhash_head *he,
 		       const struct bucket_table *tbl)
@@ -125,6 +134,56 @@ static u32 head_hashfn(const struct rhashtable *ht=
,
 	return rht_bucket_index(obj_raw_hashfn(ht, rht_obj(ht, he)), tbl);
 }
=20
+static struct rhash_head __rcu **rht_list_tail(struct bucket_table *tb=
l, u32 n)
+{
+	struct rhash_head __rcu **pprev;
+
+	for (pprev =3D &tbl->buckets[n];
+	     !rht_is_a_nulls(rht_dereference_bucket(*pprev, tbl, n));
+	     pprev =3D &rht_dereference_bucket(*pprev, tbl, n)->next)
+		;
+
+	return pprev;
+}
+
+static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_tab=
le *tbl)
+{
+	unsigned int i, size;
+#if defined(CONFIG_PROVE_LOCKING)
+	unsigned int nr_pcpus =3D 2;
+#else
+	unsigned int nr_pcpus =3D num_possible_cpus();
+#endif
+
+	nr_pcpus =3D min_t(unsigned int, nr_pcpus, 32UL);
+	size =3D nr_pcpus * ht->p.locks_mul;
+
+	if (sizeof(spinlock_t) !=3D 0) {
+#ifdef CONFIG_NUMA
+		if (size * sizeof(spinlock_t) > PAGE_SIZE)
+			tbl->locks =3D vmalloc(size * sizeof(spinlock_t));
+		else
+#endif
+		tbl->locks =3D kmalloc_array(size, sizeof(spinlock_t),
+					   GFP_KERNEL);
+		if (!tbl->locks)
+			return -ENOMEM;
+		for (i =3D 0; i < size; i++)
+			spin_lock_init(&tbl->locks[i]);
+	}
+	tbl->locks_mask =3D size - 1;
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
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 					       size_t nbuckets)
 {
@@ -143,16 +202,16 @@ static struct bucket_table *bucket_table_alloc(st=
ruct rhashtable *ht,
 	for (i =3D 0; i < nbuckets; i++)
 		INIT_RHT_NULLS_HEAD(tbl->buckets[i], ht, i);
=20
+	if (alloc_bucket_locks(ht, tbl) < 0) {
+		bucket_table_free(tbl);
+		return NULL;
+	}
+
 	tbl->size =3D nbuckets;
=20
 	return tbl;
 }
=20
-static void bucket_table_free(const struct bucket_table *tbl)
-{
-	kvfree(tbl);
-}
-
 /**
  * rht_grow_above_75 - returns true if nelems > 0.75 * table-size
  * @ht:		hash table
@@ -183,8 +242,11 @@ static void hashtable_chain_unzip(const struct rha=
shtable *ht,
 {
 	struct rhash_head *he, *p;
 	struct rhash_head __rcu *next;
+	spinlock_t *new_bucket_lock;
 	u32 hash, new_tbl_idx;
=20
+	BUG_ON(!lockdep_rht_bucket_is_held(old_tbl, n));
+
 	/* Old bucket empty, no work needed. */
 	p =3D rht_get_bucket(old_tbl, n);
 	if (rht_is_a_nulls(p))
@@ -196,6 +258,10 @@ static void hashtable_chain_unzip(const struct rha=
shtable *ht,
 	 */
 	hash =3D obj_raw_hashfn(ht, rht_obj(ht, p));
 	new_tbl_idx =3D rht_bucket_index(hash, new_tbl);
+
+	new_bucket_lock =3D bucket_lock(new_tbl, new_tbl_idx);
+	spin_lock_bh_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
+
 	rht_for_each_continue(he, p->next, old_tbl, n) {
 		if (head_hashfn(ht, he, new_tbl) !=3D new_tbl_idx)
 			break;
@@ -204,7 +270,7 @@ static void hashtable_chain_unzip(const struct rhas=
htable *ht,
 	RCU_INIT_POINTER(old_tbl->buckets[n], he);
=20
 	/* Find the subsequent node which does hash to the same
-	 * bucket as node P, or NULL if no such node exists.
+	 * bucket as node P, or nulls if no such node exists.
 	 */
 	INIT_RHT_NULLS_HEAD(next, ht, hash);
 	if (!rht_is_a_nulls(he)) {
@@ -219,7 +285,9 @@ static void hashtable_chain_unzip(const struct rhas=
htable *ht,
 	/* Set p's next pointer to that subsequent node pointer,
 	 * bypassing the nodes which do not hash to p's bucket
 	 */
-	RCU_INIT_POINTER(p->next, next);
+	rcu_assign_pointer(p->next, next);
+
+	spin_unlock_bh(new_bucket_lock);
 }
=20
 /**
@@ -239,8 +307,9 @@ int rhashtable_expand(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl =3D rht_dereference(ht->tbl, h=
t);
 	struct rhash_head *he;
+	spinlock_t *new_bucket_lock, *old_bucket_lock;
 	unsigned int i, h;
-	bool complete;
+	bool complete =3D false;
=20
 	ASSERT_RHT_MUTEX(ht);
=20
@@ -253,22 +322,38 @@ int rhashtable_expand(struct rhashtable *ht)
=20
 	ht->shift++;
=20
-	/* For each new bucket, search the corresponding old bucket
-	 * for the =EF=AC=81rst entry that hashes to the new bucket, and
-	 * link the new bucket to that entry. Since all the entries
-	 * which will end up in the new bucket appear in the same
-	 * old bucket, this constructs an entirely valid new hash
-	 * table, but with multiple buckets "zipped" together into a
-	 * single imprecise chain.
+	/* Make insertions go into the new, empty table right away. Deletions
+	 * and lookups will be attemped in both tables until we synchronzie.
+	 * The synchronize_rcu() guarantees for the new table to be picked up
+	 * so no new additions go into the old table while we relink.
+	 */
+	rcu_assign_pointer(ht->future_tbl, new_tbl);
+	synchronize_rcu();
+
+	/* For each new bucket, search the corresponding old bucket for the
+	 * =EF=AC=81rst entry that hashes to the new bucket, and link the end=
 of
+	 * newly formed bucket chain (containing entries added to future
+	 * table) to that entry. Since all the entries which will end up in
+	 * the new bucket appear in the same old bucket, this constructs an
+	 * entirely valid new hash table, but with multiple buckets
+	 * "zipped" together into a single imprecise chain.
 	 */
 	for (i =3D 0; i < new_tbl->size; i++) {
 		h =3D i & (old_tbl->size - 1);
+		old_bucket_lock =3D bucket_lock(old_tbl, h);
+		spin_lock_bh(old_bucket_lock);
+
 		rht_for_each(he, old_tbl, h) {
 			if (head_hashfn(ht, he, new_tbl) =3D=3D i) {
-				RCU_INIT_POINTER(new_tbl->buckets[i], he);
+				new_bucket_lock =3D bucket_lock(new_tbl, i);
+				spin_lock_bh_nested(new_bucket_lock,
+						    SINGLE_DEPTH_NESTING);
+				rcu_assign_pointer(*rht_list_tail(new_tbl, i), he);
+				spin_unlock_bh(new_bucket_lock);
 				break;
 			}
 		}
+		spin_unlock_bh(old_bucket_lock);
 	}
=20
 	/* Publish the new table pointer. Lookups may now traverse
@@ -278,7 +363,7 @@ int rhashtable_expand(struct rhashtable *ht)
 	rcu_assign_pointer(ht->tbl, new_tbl);
=20
 	/* Unzip interleaved hash chains */
-	do {
+	while (!complete && !ht->being_destroyed) {
 		/* Wait for readers. All new readers will see the new
 		 * table, and thus no references to the old table will
 		 * remain.
@@ -291,11 +376,18 @@ int rhashtable_expand(struct rhashtable *ht)
 		 */
 		complete =3D true;
 		for (i =3D 0; i < old_tbl->size; i++) {
+			spinlock_t *old_bucket_lock;
+
+			old_bucket_lock =3D bucket_lock(old_tbl, i);
+			spin_lock_bh(old_bucket_lock);
+
 			hashtable_chain_unzip(ht, new_tbl, old_tbl, i);
-			if (!rht_is_a_nulls(old_tbl->buckets[i]))
+			if (!rht_is_a_nulls(rht_get_bucket(old_tbl, i)))
 				complete =3D false;
+
+			spin_unlock_bh(old_bucket_lock);
 		}
-	} while (!complete);
+	}
=20
 	bucket_table_free(old_tbl);
 	return 0;
@@ -315,7 +407,7 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *ntbl, *tbl =3D rht_dereference(ht->tbl, ht);
-	struct rhash_head __rcu **pprev;
+	spinlock_t *new_bucket_lock, *old_bucket_lock;
 	unsigned int i;
=20
 	ASSERT_RHT_MUTEX(ht);
@@ -327,28 +419,31 @@ int rhashtable_shrink(struct rhashtable *ht)
 	if (ntbl =3D=3D NULL)
 		return -ENOMEM;
=20
-	ht->shift--;
+	rcu_assign_pointer(ht->future_tbl, ntbl);
+	synchronize_rcu();
=20
 	/* Link each bucket in the new table to the =EF=AC=81rst bucket
 	 * in the old table that contains entries which will hash
 	 * to the new bucket.
 	 */
 	for (i =3D 0; i < ntbl->size; i++) {
+		old_bucket_lock =3D bucket_lock(tbl, rht_bucket_index(i, tbl));
+		new_bucket_lock =3D bucket_lock(ntbl, i);
+
+		spin_lock_bh(old_bucket_lock);
+		spin_lock_bh_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
+
 		ntbl->buckets[i] =3D tbl->buckets[i];
+		rcu_assign_pointer(*rht_list_tail(ntbl, i),
+				   tbl->buckets[i + ntbl->size]);
=20
-		/* Link each bucket in the new table to the =EF=AC=81rst bucket
-		 * in the old table that contains entries which will hash
-		 * to the new bucket.
-		 */
-		for (pprev =3D &ntbl->buckets[i];
-		     !rht_is_a_nulls(rht_dereference_bucket(*pprev, ntbl, i));
-		     pprev =3D &rht_dereference_bucket(*pprev, ntbl, i)->next)
-			;
-		RCU_INIT_POINTER(*pprev, tbl->buckets[i + ntbl->size]);
+		spin_unlock_bh(new_bucket_lock);
+		spin_unlock_bh(old_bucket_lock);
 	}
=20
 	/* Publish the new, valid hash table */
 	rcu_assign_pointer(ht->tbl, ntbl);
+	ht->shift--;
=20
 	/* Wait for readers. No new readers will have references to the
 	 * old hash table.
@@ -361,6 +456,23 @@ int rhashtable_shrink(struct rhashtable *ht)
 }
 EXPORT_SYMBOL_GPL(rhashtable_shrink);
=20
+static void rht_deferred_worker(struct work_struct *work)
+{
+	struct rhashtable *ht;
+	struct bucket_table *tbl;
+
+	ht =3D container_of(work, struct rhashtable, run_work.work);
+	mutex_lock(&ht->mutex);
+	tbl =3D rht_dereference(ht->tbl, ht);
+
+	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+		rhashtable_expand(ht);
+	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size=
))
+		rhashtable_shrink(ht);
+
+	mutex_unlock(&ht->mutex);
+}
+
 /**
  * rhashtable_insert - insert object into hash hash table
  * @ht:		hash table
@@ -369,18 +481,23 @@ EXPORT_SYMBOL_GPL(rhashtable_shrink);
  * Will automatically grow the table via rhashtable_expand() if the th=
e
  * grow_decision function specified at rhashtable_init() returns true.
  *
- * The caller must ensure that no concurrent table mutations occur. It=
 is
- * however valid to have concurrent lookups if they are RCU protected.
+ * Will take a per bucket spinlock to protect against mutual mutations
+ * on the same bucket.
  */
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl =3D rht_dereference(ht->tbl, ht);
+	struct bucket_table *tbl;
+	spinlock_t *lock;
 	u32 hash, idx;
=20
-	ASSERT_RHT_MUTEX(ht);
-
+	rcu_read_lock();
+	tbl =3D rht_dereference_rcu(ht->future_tbl, ht);
 	hash =3D obj_raw_hashfn(ht, rht_obj(ht, obj));
 	idx =3D rht_bucket_index(hash, tbl);
+
+	lock =3D bucket_lock(tbl, idx);
+	spin_lock_bh(lock);
+
 	if (rht_is_a_nulls(rht_get_bucket(tbl, idx)))
 		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
 	else
@@ -388,36 +505,14 @@ void rhashtable_insert(struct rhashtable *ht, str=
uct rhash_head *obj)
 	rcu_assign_pointer(tbl->buckets[idx], obj);
 	ht->nelems++;
=20
-	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
-		rhashtable_expand(ht);
-}
-EXPORT_SYMBOL_GPL(rhashtable_insert);
-
-/**
- * rhashtable_remove_pprev - remove object from hash table given previ=
ous element
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- * @pprev:	pointer to previous element
- *
- * Identical to rhashtable_remove() but caller is alreayd aware of the=
 element
- * in front of the element to be deleted. This is in particular useful=
 for
- * deletion when combined with walking or lookup.
- */
-void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head =
*obj,
-			     struct rhash_head __rcu **pprev)
-{
-	struct bucket_table *tbl =3D rht_dereference(ht->tbl, ht);
-
-	ASSERT_RHT_MUTEX(ht);
+	spin_unlock_bh(lock);
=20
-	RCU_INIT_POINTER(*pprev, obj->next);
-	ht->nelems--;
+	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+		schedule_delayed_work(&ht->run_work, 0);
=20
-	if (ht->p.shrink_decision &&
-	    ht->p.shrink_decision(ht, tbl->size))
-		rhashtable_shrink(ht);
+	rcu_read_unlock();
 }
-EXPORT_SYMBOL_GPL(rhashtable_remove_pprev);
+EXPORT_SYMBOL_GPL(rhashtable_insert);
=20
 /**
  * rhashtable_remove - remove object from hash table
@@ -436,14 +531,20 @@ EXPORT_SYMBOL_GPL(rhashtable_remove_pprev);
  */
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl =3D rht_dereference(ht->tbl, ht);
-	struct rhash_head __rcu **pprev;
+	struct bucket_table *tbl;
 	struct rhash_head *he;
+	struct rhash_head __rcu **pprev;
+	spinlock_t *lock;
 	u32 idx;
=20
-	ASSERT_RHT_MUTEX(ht);
-
+	rcu_read_lock();
+	tbl =3D rht_dereference_rcu(ht->future_tbl, ht);
 	idx =3D head_hashfn(ht, obj, tbl);
+
+	lock =3D bucket_lock(tbl, idx);
+	spin_lock_bh(lock);
+
+restart:
 	pprev =3D &tbl->buckets[idx];
 	rht_for_each(he, tbl, idx) {
 		if (he !=3D obj) {
@@ -451,10 +552,34 @@ bool rhashtable_remove(struct rhashtable *ht, str=
uct rhash_head *obj)
 			continue;
 		}
=20
-		rhashtable_remove_pprev(ht, he, pprev);
+		rcu_assign_pointer(*pprev, obj->next);
+		ht->nelems--;
+
+		spin_unlock_bh(lock);
+
+		if (ht->p.shrink_decision &&
+		    ht->p.shrink_decision(ht, tbl->size))
+			schedule_delayed_work(&ht->run_work, 0);
+
+		rcu_read_unlock();
+
 		return true;
 	}
=20
+	if (tbl !=3D rht_dereference_rcu(ht->tbl, ht)) {
+		spin_unlock_bh(lock);
+
+		tbl =3D rht_dereference_rcu(ht->tbl, ht);
+		idx =3D head_hashfn(ht, obj, tbl);
+
+		lock =3D bucket_lock(tbl, idx);
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
@@ -471,24 +596,32 @@ EXPORT_SYMBOL_GPL(rhashtable_remove);
  * paramter set). It will BUG() if used inappropriately.
  *
  * Lookups may occur in parallel with hash mutations as long as the lo=
okup is
- * guarded by rcu_read_lock(). The caller must take care of this.
+ * guarded by rcu_read_lock(). Otherwise the ht->mutex must be held.
  */
 void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
 {
-	const struct bucket_table *tbl =3D rht_dereference_rcu(ht->tbl, ht);
+	const struct bucket_table *tbl, *old_tbl;
 	struct rhash_head *he;
 	u32 h;
=20
 	BUG_ON(!ht->p.key_len);
=20
+	old_tbl =3D rht_dereference_rcu(ht->tbl, ht);
+	tbl =3D rht_dereference_rcu(ht->future_tbl, ht);
 	h =3D rhashtable_hashfn(ht, key, ht->p.key_len);
-	rht_for_each_rcu(he, tbl, h) {
+restart:
+	rht_for_each_rcu(he, tbl, rht_bucket_index(h, tbl)) {
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
 			continue;
 		return rht_obj(ht, he);
 	}
=20
+	if (unlikely(tbl !=3D old_tbl)) {
+		tbl =3D old_tbl;
+		goto restart;
+	}
+
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup);
@@ -496,7 +629,7 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
 /**
  * rhashtable_lookup_compare - search hash table with compare function
  * @ht:		hash table
- * @hash:	hash value of desired entry
+ * @key:	the pointer to the key
  * @compare:	compare function, must return true on match
  * @arg:	argument passed on to compare function
  *
@@ -508,21 +641,28 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
  *
  * Returns the first entry on which the compare function returned true=
=2E
  */
-void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
+void *rhashtable_lookup_compare(const struct rhashtable *ht, const voi=
d *key,
 				bool (*compare)(void *, void *), void *arg)
 {
-	const struct bucket_table *tbl =3D rht_dereference_rcu(ht->tbl, ht);
+	const struct bucket_table *tbl, *old_tbl;
 	struct rhash_head *he;
+	u32 h;
=20
-	if (unlikely(hash >=3D tbl->size))
-		return NULL;
-
-	rht_for_each_rcu(he, tbl, hash) {
+	old_tbl =3D rht_dereference_rcu(ht->tbl, ht);
+	tbl =3D rht_dereference_rcu(ht->future_tbl, ht);
+	h =3D rhashtable_hashfn(ht, key, ht->p.key_len);
+restart:
+	rht_for_each_rcu(he, tbl, rht_bucket_index(h, tbl)) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
 		return (void *) he - ht->p.head_offset;
 	}
=20
+	if (unlikely(tbl !=3D old_tbl)) {
+		tbl =3D old_tbl;
+		goto restart;
+	}
+
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare);
@@ -554,7 +694,6 @@ static size_t rounded_hashtable_size(struct rhashta=
ble_params *params)
  *	.key_offset =3D offsetof(struct test_obj, key),
  *	.key_len =3D sizeof(int),
  *	.hashfn =3D arch_fast_hash,
- *	.mutex_is_held =3D &my_mutex_is_held,
  * };
  *
  * Configuration Example 2: Variable length keys
@@ -574,7 +713,6 @@ static size_t rounded_hashtable_size(struct rhashta=
ble_params *params)
  *	.head_offset =3D offsetof(struct test_obj, node),
  *	.hashfn =3D arch_fast_hash,
  *	.obj_hashfn =3D my_hash_fn,
- *	.mutex_is_held =3D &my_mutex_is_held,
  * };
  */
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *p=
arams)
@@ -599,6 +737,12 @@ int rhashtable_init(struct rhashtable *ht, struct =
rhashtable_params *params)
=20
 	memset(ht, 0, sizeof(*ht));
 	memcpy(&ht->p, params, sizeof(*params));
+	mutex_init(&ht->mutex);
+
+	if (params->locks_mul)
+		ht->p.locks_mul =3D roundup_pow_of_two(params->locks_mul);
+	else
+		ht->p.locks_mul =3D BUCKET_LOCKS_PER_CPU;
=20
 	tbl =3D bucket_table_alloc(ht, size);
 	if (tbl =3D=3D NULL)
@@ -606,10 +750,14 @@ int rhashtable_init(struct rhashtable *ht, struct=
 rhashtable_params *params)
=20
 	ht->shift =3D ilog2(tbl->size);
 	RCU_INIT_POINTER(ht->tbl, tbl);
+	RCU_INIT_POINTER(ht->future_tbl, tbl);
=20
 	if (!ht->p.hash_rnd)
 		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
=20
+	if (ht->p.grow_decision || ht->p.shrink_decision)
+		INIT_DEFERRABLE_WORK(&ht->run_work, rht_deferred_worker);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rhashtable_init);
@@ -620,11 +768,16 @@ EXPORT_SYMBOL_GPL(rhashtable_init);
  *
  * Frees the bucket array.
  */
-void rhashtable_destroy(const struct rhashtable *ht)
+void rhashtable_destroy(struct rhashtable *ht)
 {
-	const struct bucket_table *tbl =3D rht_dereference(ht->tbl, ht);
+	ht->being_destroyed =3D true;
=20
-	bucket_table_free(tbl);
+	mutex_lock(&ht->mutex);
+
+	cancel_delayed_work(&ht->run_work);
+	bucket_table_free(rht_dereference(ht->tbl, ht));
+
+	mutex_unlock(&ht->mutex);
 }
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
=20
@@ -639,11 +792,6 @@ EXPORT_SYMBOL_GPL(rhashtable_destroy);
 #define TEST_PTR	((void *) 0xdeadbeef)
 #define TEST_NEXPANDS	4
=20
-static int test_mutex_is_held(void)
-{
-	return 1;
-}
-
 struct test_obj {
 	void			*ptr;
 	int			value;
@@ -755,7 +903,9 @@ static int __init test_rhashtable(struct rhashtable=
 *ht)
=20
 	for (i =3D 0; i < TEST_NEXPANDS; i++) {
 		pr_info("  Table expansion iteration %u...\n", i);
+		mutex_lock(&ht->mutex);
 		rhashtable_expand(ht);
+		mutex_unlock(&ht->mutex);
=20
 		rcu_read_lock();
 		pr_info("  Verifying lookups...\n");
@@ -765,7 +915,9 @@ static int __init test_rhashtable(struct rhashtable=
 *ht)
=20
 	for (i =3D 0; i < TEST_NEXPANDS; i++) {
 		pr_info("  Table shrinkage iteration %u...\n", i);
+		mutex_lock(&ht->mutex);
 		rhashtable_shrink(ht);
+		mutex_unlock(&ht->mutex);
=20
 		rcu_read_lock();
 		pr_info("  Verifying lookups...\n");
@@ -804,7 +956,6 @@ static int __init test_rht_init(void)
 		.key_offset =3D offsetof(struct test_obj, value),
 		.key_len =3D sizeof(int),
 		.hashfn =3D arch_fast_hash,
-		.mutex_is_held =3D &test_mutex_is_held,
 		.grow_decision =3D rht_grow_above_75,
 		.shrink_decision =3D rht_shrink_below_30,
 	};
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 68b654b..436f77b 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -83,41 +83,48 @@ static void nft_hash_remove(const struct nft_set *s=
et,
 			    const struct nft_set_elem *elem)
 {
 	struct rhashtable *priv =3D nft_set_priv(set);
-	struct rhash_head *he, __rcu **pprev;
-
-	pprev =3D elem->cookie;
-	he =3D rht_dereference((*pprev), priv);
-
-	rhashtable_remove_pprev(priv, he, pprev);
+	struct rhash_head *he =3D elem->cookie;
=20
+	rhashtable_remove(priv, he);
 	synchronize_rcu();
 	kfree(he);
 }
=20
+struct nft_compare_arg {
+	const struct nft_set *set;
+	struct nft_set_elem *elem;
+};
+
+static bool nft_hash_compare(void *ptr, void *arg)
+{
+	struct nft_hash_elem *he =3D ptr;
+	struct nft_compare_arg *x =3D arg;
+
+	if (!nft_data_cmp(&he->key, &x->elem->key, x->set->klen)) {
+		x->elem->cookie =3D &he->node;
+		x->elem->flags =3D 0;
+		if (x->set->flags & NFT_SET_MAP)
+			nft_data_copy(&x->elem->data, he->data);
+
+		return true;
+	}
+
+	return false;
+}
+
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem=
 *elem)
 {
 	const struct rhashtable *priv =3D nft_set_priv(set);
-	const struct bucket_table *tbl =3D rht_dereference_rcu(priv->tbl, pri=
v);
-	struct rhash_head __rcu * const *pprev;
-	struct rhash_head *pos;
-	struct nft_hash_elem *he;
-	u32 h;
-
-	h =3D rhashtable_hashfn(priv, &elem->key, set->klen);
-	pprev =3D &tbl->buckets[h];
-	rht_for_each_entry_rcu(he, pos, tbl, h, node) {
-		if (nft_data_cmp(&he->key, &elem->key, set->klen)) {
-			pprev =3D &he->node.next;
-			continue;
-		}
+	struct nft_compare_arg arg =3D {
+		.set =3D set,
+		.elem =3D elem,
+	};
=20
-		elem->cookie =3D (void *)pprev;
-		elem->flags =3D 0;
-		if (set->flags & NFT_SET_MAP)
-			nft_data_copy(&elem->data, he->data);
+	if (rhashtable_lookup_compare(priv, &elem->key,
+				      &nft_hash_compare, &arg))
 		return 0;
-	}
-	return -ENOENT;
+	else
+		return -ENOENT;
 }
=20
 static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_=
set *set,
@@ -182,7 +189,7 @@ static int nft_hash_init(const struct nft_set *set,
=20
 static void nft_hash_destroy(const struct nft_set *set)
 {
-	const struct rhashtable *priv =3D nft_set_priv(set);
+	struct rhashtable *priv =3D nft_set_priv(set);
 	const struct bucket_table *tbl;
 	struct nft_hash_elem *he;
 	struct rhash_head *pos, *next;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 98e5b58..4e02fa2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1015,11 +1015,8 @@ static struct sock *__netlink_lookup(struct netl=
ink_table *table, u32 portid,
 		.net =3D net,
 		.portid =3D portid,
 	};
-	u32 hash;
=20
-	hash =3D rhashtable_hashfn(&table->hash, &portid, sizeof(portid));
-
-	return rhashtable_lookup_compare(&table->hash, hash,
+	return rhashtable_lookup_compare(&table->hash, &portid,
 					 &netlink_compare, &arg);
 }
=20
--=20
1.9.3
