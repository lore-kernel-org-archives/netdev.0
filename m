From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/9] rhashtable: Supports for nulls marker
Date: Mon, 15 Dec 2014 13:51:10 +0100
Message-ID: <02891770218e264db864396086f838fabdd0c6a2.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38910 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbaLOMvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:51:19 -0500
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to allow for wider usage of rhashtable, use a special nulls
marker to terminate each chain. The reason for not using the existing
nulls_list is that the prev pointer usage would not be valid as entries
can be linked in two different buckets at the same time.

The 4 nulls base bits can be set through the rhashtable_params structure
like this:

struct rhashtable_params params = {
        [...]
        .nulls_base = (1U << RHT_BASE_SHIFT),
};

This reduces the hash length from 32 bits to 27 bits.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/list_nulls.h |  3 ++-
 include/linux/rhashtable.h | 57 ++++++++++++++++++++++++++++++++++++++--------
 lib/rhashtable.c           | 37 ++++++++++++++++++++++++------
 3 files changed, 79 insertions(+), 18 deletions(-)

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
index 5d10ae36..e8c300e 100644
--- a/include/linux/list_nulls.h
+++ b/include/linux/list_nulls.h
@@ -21,8 +21,9 @@ struct hlist_nulls_head {
 struct hlist_nulls_node {
 	struct hlist_nulls_node *next, **pprev;
 };
+#define NULLS_MARKER(value) (1UL | (((long)value) << 1))
 #define INIT_HLIST_NULLS_HEAD(ptr, nulls) \
-	((ptr)->first = (struct hlist_nulls_node *) (1UL | (((long)nulls) << 1)))
+	((ptr)->first = (struct hlist_nulls_node *) NULLS_MARKER(nulls))
 
 #define hlist_nulls_entry(ptr, type, member) container_of(ptr,type,member)
 /**
diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index a1688f0..de7cac7 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -18,15 +18,32 @@
 #ifndef _LINUX_RHASHTABLE_H
 #define _LINUX_RHASHTABLE_H
 
-#include <linux/rculist.h>
+#include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 
+/*
+ * The end of the chain is marked with a special nulls marks which has
+ * the following format:
+ *
+ * +-------+-----------------------------------------------------+-+
+ * | Base  |                      Hash                           |1|
+ * +-------+-----------------------------------------------------+-+
+ *
+ * Base (4 bits) : Reserved to distinguish between multiple tables.
+ *                 Specified via &struct rhashtable_params.nulls_base.
+ * Hash (27 bits): Full hash (unmasked) of first element added to bucket
+ * 1 (1 bit)     : Nulls marker (always set)
+ *
+ * The remaining bits of the next pointer remain unused for now.
+ */
+#define RHT_BASE_BITS		4
+#define RHT_HASH_BITS		27
+#define RHT_BASE_SHIFT		RHT_HASH_BITS
+
 struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
 
-#define INIT_HASH_HEAD(ptr) ((ptr)->next = NULL)
-
 /**
  * struct bucket_table - Table of hash buckets
  * @size: Number of hash buckets
@@ -55,6 +72,7 @@ struct rhashtable;
  * @hash_rnd: Seed to use while hashing
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
+ * @nulls_base: Base value to generate nulls marker
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
@@ -69,6 +87,7 @@ struct rhashtable_params {
 	u32			hash_rnd;
 	size_t			max_shift;
 	size_t			min_shift;
+	u32			nulls_base;
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
@@ -100,6 +119,24 @@ struct rhashtable {
 	bool                            being_destroyed;
 };
 
+static inline unsigned long rht_marker(const struct rhashtable *ht, u32 hash)
+{
+	return NULLS_MARKER(ht->p.nulls_base + hash);
+}
+
+#define INIT_RHT_NULLS_HEAD(ptr, ht, hash) \
+	((ptr) = (typeof(ptr)) rht_marker(ht, hash))
+
+static inline bool rht_is_a_nulls(const struct rhash_head *ptr)
+{
+	return ((unsigned long) ptr & 1);
+}
+
+static inline unsigned long rht_get_nulls_value(const struct rhash_head *ptr)
+{
+	return ((unsigned long) ptr) >> 1;
+}
+
 #ifdef CONFIG_PROVE_LOCKING
 int lockdep_rht_mutex_is_held(struct rhashtable *ht);
 int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash);
@@ -157,7 +194,7 @@ void rhashtable_destroy(struct rhashtable *ht);
  */
 #define rht_for_each_continue(pos, head, tbl, hash) \
 	for (pos = rht_dereference_bucket(head, tbl, hash); \
-	     pos; \
+	     !rht_is_a_nulls(pos); \
 	     pos = rht_dereference_bucket((pos)->next, tbl, hash))
 
 /**
@@ -180,7 +217,7 @@ void rhashtable_destroy(struct rhashtable *ht);
  */
 #define rht_for_each_entry_continue(tpos, pos, head, tbl, hash, member)	\
 	for (pos = rht_dereference_bucket(head, tbl, hash);		\
-	     pos && rht_entry(tpos, pos, member);			\
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	\
 	     pos = rht_dereference_bucket((pos)->next, tbl, hash))
 
 /**
@@ -209,9 +246,9 @@ void rhashtable_destroy(struct rhashtable *ht);
  */
 #define rht_for_each_entry_safe(tpos, pos, next, tbl, hash, member)	    \
 	for (pos = rht_dereference_bucket((tbl)->buckets[hash], tbl, hash), \
-	     next = pos ? rht_dereference_bucket(pos->next, tbl, hash)      \
-			: NULL;						    \
-	     pos && rht_entry(tpos, pos, member);			    \
+	     next = !rht_is_a_nulls(pos) ?				    \
+		       rht_dereference_bucket(pos->next, tbl, hash) : NULL; \
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	    \
 	     pos = next)
 
 /**
@@ -228,7 +265,7 @@ void rhashtable_destroy(struct rhashtable *ht);
 #define rht_for_each_rcu_continue(pos, head, tbl, hash)			\
 	for (({barrier(); }),						\
 	     pos = rht_dereference_bucket_rcu(head, tbl, hash);		\
-	     pos;							\
+	     !rht_is_a_nulls(pos);					\
 	     pos = rcu_dereference_raw(pos->next))
 
 /**
@@ -260,7 +297,7 @@ void rhashtable_destroy(struct rhashtable *ht);
 #define rht_for_each_entry_rcu_continue(tpos, pos, head, tbl, hash, member) \
 	for (({barrier(); }),						    \
 	     pos = rht_dereference_bucket_rcu(head, tbl, hash);		    \
-	     pos && rht_entry(tpos, pos, member);			    \
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	    \
 	     pos = rht_dereference_bucket_rcu(pos->next, tbl, hash))
 
 /**
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 312e343..cbad192 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -28,6 +28,9 @@
 #define HASH_MIN_SIZE		4UL
 #define BUCKET_LOCKS_PER_CPU   128UL
 
+/* Base bits plus 1 bit for nulls marker */
+#define HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
+
 enum {
 	RHT_LOCK_NORMAL,
 	RHT_LOCK_NESTED,
@@ -86,7 +89,7 @@ static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
 		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
 				    ht->p.hash_rnd);
 
-	return hash;
+	return hash >> HASH_RESERVED_SPACE;
 }
 
 static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
@@ -95,6 +98,7 @@ static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
 	u32 hash;
 
 	hash = ht->p.hashfn(key, len, ht->p.hash_rnd);
+	hash >>= HASH_RESERVED_SPACE;
 
 	return rht_bucket_index(tbl, hash);
 }
@@ -111,7 +115,7 @@ static struct rhash_head __rcu **bucket_tail(struct bucket_table *tbl, u32 n)
 	struct rhash_head __rcu **pprev;
 
 	for (pprev = &tbl->buckets[n];
-	     rht_dereference_bucket(*pprev, tbl, n);
+	     !rht_is_a_nulls(rht_dereference_bucket(*pprev, tbl, n));
 	     pprev = &rht_dereference_bucket(*pprev, tbl, n)->next)
 		;
 
@@ -164,6 +168,7 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 {
 	struct bucket_table *tbl;
 	size_t size;
+	int i;
 
 	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
 	tbl = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
@@ -180,6 +185,9 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 		return NULL;
 	}
 
+	for (i = 0; i < nbuckets; i++)
+		INIT_RHT_NULLS_HEAD(tbl->buckets[i], ht, i);
+
 	return tbl;
 }
 
@@ -221,7 +229,7 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	/* Old bucket empty, no work needed. */
 	p = rht_dereference_bucket(old_tbl->buckets[old_hash], old_tbl,
 				   old_hash);
-	if (!p)
+	if (rht_is_a_nulls(p))
 		return;
 
 	new_hash = new_hash2 = head_hashfn(ht, new_tbl, p);
@@ -252,8 +260,8 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 	/* Find the subsequent node which does hash to the same
 	 * bucket as node P, or NULL if no such node exists.
 	 */
-	next = NULL;
-	if (he) {
+	INIT_RHT_NULLS_HEAD(next, ht, old_hash);
+	if (!rht_is_a_nulls(he)) {
 		rht_for_each_continue(he, he->next, old_tbl, old_hash) {
 			if (head_hashfn(ht, new_tbl, he) == new_hash) {
 				next = he;
@@ -369,11 +377,15 @@ int rhashtable_expand(struct rhashtable *ht)
 		 */
 		complete = true;
 		for (old_hash = 0; old_hash < old_tbl->size; old_hash++) {
+			struct rhash_head *head;
+
 			old_bucket_lock = bucket_lock(old_tbl, old_hash);
 			spin_lock_bh(old_bucket_lock);
 
 			hashtable_chain_unzip(ht, new_tbl, old_tbl, old_hash);
-			if (old_tbl->buckets[old_hash] != NULL)
+			head = rht_dereference_bucket(old_tbl->buckets[old_hash],
+						      old_tbl, old_hash);
+			if (!rht_is_a_nulls(head))
 				complete = false;
 
 			spin_unlock_bh(old_bucket_lock);
@@ -498,6 +510,7 @@ static void rht_deferred_worker(struct work_struct *work)
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
 	struct bucket_table *tbl;
+	struct rhash_head *head;
 	spinlock_t *lock;
 	unsigned hash;
 
@@ -508,7 +521,12 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 	lock = bucket_lock(tbl, hash);
 
 	spin_lock_bh(lock);
-	RCU_INIT_POINTER(obj->next, tbl->buckets[hash]);
+	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+	if (rht_is_a_nulls(head))
+		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
+	else
+		RCU_INIT_POINTER(obj->next, head);
+
 	rcu_assign_pointer(tbl->buckets[hash], obj);
 	spin_unlock_bh(lock);
 
@@ -709,6 +727,7 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.key_offset = offsetof(struct test_obj, key),
  *	.key_len = sizeof(int),
  *	.hashfn = jhash,
+ *	.nulls_base = (1U << RHT_BASE_SHIFT),
  * };
  *
  * Configuration Example 2: Variable length keys
@@ -741,6 +760,9 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	    (!params->key_len && !params->obj_hashfn))
 		return -EINVAL;
 
+	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
+		return -EINVAL;
+
 	params->min_shift = max_t(size_t, params->min_shift,
 				  ilog2(HASH_MIN_SIZE));
 
@@ -974,6 +996,7 @@ static int __init test_rht_init(void)
 		.key_offset = offsetof(struct test_obj, value),
 		.key_len = sizeof(int),
 		.hashfn = jhash,
+		.nulls_base = (3U << RHT_BASE_SHIFT),
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
 	};
-- 
1.9.3
