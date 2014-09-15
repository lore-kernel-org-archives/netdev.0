From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5] rhashtable: Convert to nulls list
Date: Mon, 15 Sep 2014 14:18:02 +0200
Message-ID: <14f41656d3ac77f7217764315ae14b5771724fd4.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47306 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaIOMSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 08:18:10 -0400
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to allow wider usage of rhashtable, use a special nulls marker
to terminate each chain. The reason for not using the existing
nulls_list is that the pprev pointer usage would not be valid as entries
can be linked in two different buckets at the same time.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/list_nulls.h |   3 +-
 include/linux/rhashtable.h | 195 +++++++++++++++++++++++++++++++--------------
 lib/rhashtable.c           | 158 ++++++++++++++++++++++--------------
 net/netfilter/nft_hash.c   |  12 ++-
 net/netlink/af_netlink.c   |   9 ++-
 net/netlink/diag.c         |   4 +-
 6 files changed, 248 insertions(+), 133 deletions(-)

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
index 942fa44..e9cdbda 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -18,14 +18,12 @@
 #ifndef _LINUX_RHASHTABLE_H
 #define _LINUX_RHASHTABLE_H
 
-#include <linux/rculist.h>
+#include <linux/list_nulls.h>
 
 struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
 
-#define INIT_HASH_HEAD(ptr) ((ptr)->next = NULL)
-
 struct bucket_table {
 	size_t				size;
 	struct rhash_head __rcu		*buckets[];
@@ -45,6 +43,7 @@ struct rhashtable;
  * @hash_rnd: Seed to use while hashing
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
+ * @nulls_base: Base value to generate nulls marker
  * @hashfn: Function to hash key
  * @obj_hashfn: Function to hash object
  * @grow_decision: If defined, may return true if table should expand
@@ -59,6 +58,7 @@ struct rhashtable_params {
 	u32			hash_rnd;
 	size_t			max_shift;
 	size_t			min_shift;
+	int			nulls_base;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
 	bool			(*grow_decision)(const struct rhashtable *ht,
@@ -82,6 +82,24 @@ struct rhashtable {
 	struct rhashtable_params	p;
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
 int lockdep_rht_mutex_is_held(const struct rhashtable *ht);
 #else
@@ -119,92 +137,145 @@ void rhashtable_destroy(const struct rhashtable *ht);
 #define rht_dereference_rcu(p, ht) \
 	rcu_dereference_check(p, lockdep_rht_mutex_is_held(ht))
 
-#define rht_entry(ptr, type, member) container_of(ptr, type, member)
-#define rht_entry_safe(ptr, type, member) \
-({ \
-	typeof(ptr) __ptr = (ptr); \
-	   __ptr ? rht_entry(__ptr, type, member) : NULL; \
-})
+#define rht_dereference_bucket(p, tbl, hash) \
+	rcu_dereference_protected(p, lockdep_rht_mutex_is_held(ht))
+
+#define rht_dereference_bucket_rcu(p, tbl, hash) \
+	rcu_dereference_check(p, lockdep_rht_mutex_is_held(ht))
+
+#define rht_entry(tpos, pos, member) \
+	({ tpos = container_of(pos, typeof(*tpos), member); 1; })
 
-#define rht_next_entry_safe(pos, ht, member) \
-({ \
-	pos ? rht_entry_safe(rht_dereference((pos)->member.next, ht), \
-			     typeof(*(pos)), member) : NULL; \
-})
+static inline struct rhash_head *rht_get_bucket(const struct bucket_table *tbl,
+						u32 hash)
+{
+	return rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
+}
+
+static inline struct rhash_head *rht_get_bucket_rcu(const struct bucket_table *tbl,
+						    u32 hash)
+{
+	return rht_dereference_bucket_rcu(tbl->buckets[hash], tbl, hash);
+}
+
+/**
+ * rht_for_each_continue - continue iterating over hash chain
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ */
+#define rht_for_each_continue(pos, head, tbl, hash) \
+	for (pos = rht_dereference_bucket(head, tbl, hash); \
+	     !rht_is_a_nulls(pos); \
+	     pos = rht_dereference_bucket(pos->next, tbl, hash))
 
 /**
  * rht_for_each - iterate over hash chain
- * @pos:	&struct rhash_head to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
  */
-#define rht_for_each(pos, head, ht) \
-	for (pos = rht_dereference(head, ht); \
-	     pos; \
-	     pos = rht_dereference((pos)->next, ht))
+#define rht_for_each(pos, tbl, hash) \
+	for (pos = rht_get_bucket(tbl, hash); \
+	     !rht_is_a_nulls(pos); \
+	     pos = rht_dereference_bucket(pos->next, tbl, hash))
 
 /**
  * rht_for_each_entry - iterate over hash chain of given type
- * @pos:	type * to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
- * @member:	name of the rhash_head within the hashable struct.
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
  */
-#define rht_for_each_entry(pos, head, ht, member) \
-	for (pos = rht_entry_safe(rht_dereference(head, ht), \
-				   typeof(*(pos)), member); \
-	     pos; \
-	     pos = rht_next_entry_safe(pos, ht, member))
+#define rht_for_each_entry(tpos, pos, tbl, hash, member)		\
+	for (pos = rht_get_bucket(tbl, hash);				\
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	\
+	     pos = rht_dereference_bucket(pos->next, tbl, hash))
 
 /**
  * rht_for_each_entry_safe - safely iterate over hash chain of given type
- * @pos:	type * to use as a loop cursor.
- * @n:		type * to use for temporary next object storage
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
- * @member:	name of the rhash_head within the hashable struct.
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @next:	the &struct rhash_head to use as next in loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
  *
  * This hash chain list-traversal primitive allows for the looped code to
  * remove the loop cursor from the list.
  */
-#define rht_for_each_entry_safe(pos, n, head, ht, member)		\
-	for (pos = rht_entry_safe(rht_dereference(head, ht), \
-				  typeof(*(pos)), member), \
-	     n = rht_next_entry_safe(pos, ht, member); \
-	     pos; \
-	     pos = n, \
-	     n = rht_next_entry_safe(pos, ht, member))
+#define rht_for_each_entry_safe(tpos, pos, next, tbl, hash, member)	\
+	for (pos = rht_get_bucket(tbl, hash),				\
+	     next = !rht_is_a_nulls(pos) ?				\
+			rht_dereference_bucket(pos->next, tbl, hash) :	\
+			(struct rhash_head *) NULLS_MARKER(0);		\
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	\
+	     pos = next)
+
+/**
+ * rht_for_each_rcu_continue - continue iterating over rcu hash chain
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ *
+ * This hash chain list-traversal primitive may safely run concurrently with
+ * the _rcu mutation primitives such as rht_insert() as long as the traversal
+ * is guarded by rcu_read_lock().
+ */
+#define rht_for_each_rcu_continue(pos, head)				\
+	for (({barrier(); }), pos = rcu_dereference_raw(head);		\
+	     !rht_is_a_nulls(pos);					\
+	     pos = rcu_dereference_raw(pos->next))
 
 /**
  * rht_for_each_rcu - iterate over rcu hash chain
- * @pos:	&struct rhash_head to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @ht:		pointer to your struct rhashtable
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ *
+ * This hash chain list-traversal primitive may safely run concurrently with
+ * the _rcu mutation primitives such as rht_insert() as long as the traversal
+ * is guarded by rcu_read_lock().
+ */
+#define rht_for_each_rcu(pos, tbl, hash)				\
+	for (({barrier(); }), pos = rht_get_bucket_rcu(tbl, hash);	\
+	     !rht_is_a_nulls(pos);					\
+	     pos = rcu_dereference_raw(pos->next))
+
+/**
+ * rht_for_each_entry_rcu_continue - continue iterating over rcu hash chain
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @head:	the previous &struct rhash_head to continue from
+ * @member:	name of the &struct rhash_head within the hashable struct.
  *
  * This hash chain list-traversal primitive may safely run concurrently with
- * the _rcu fkht mutation primitives such as rht_insert() as long as the
- * traversal is guarded by rcu_read_lock().
+ * the _rcu mutation primitives such as rht_insert() as long as the traversal
+ * is guarded by rcu_read_lock().
  */
-#define rht_for_each_rcu(pos, head, ht) \
-	for (pos = rht_dereference_rcu(head, ht); \
-	     pos; \
-	     pos = rht_dereference_rcu((pos)->next, ht))
+#define rht_for_each_entry_rcu_continue(tpos, pos, head, member)	\
+	for (({barrier(); }),						\
+	     pos = rcu_dereference_raw(head);				\
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	\
+	     pos = rcu_dereference_raw(pos->next))
 
 /**
  * rht_for_each_entry_rcu - iterate over rcu hash chain of given type
- * @pos:	type * to use as a loop cursor.
- * @head:	head of the hash chain (struct rhash_head *)
- * @member:	name of the rhash_head within the hashable struct.
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct rhash_head to use as a loop cursor.
+ * @tbl:	the &struct bucket_table
+ * @hash:	the hash value / bucket index
+ * @member:	name of the &struct rhash_head within the hashable struct.
  *
  * This hash chain list-traversal primitive may safely run concurrently with
- * the _rcu fkht mutation primitives such as rht_insert() as long as the
- * traversal is guarded by rcu_read_lock().
+ * the _rcu mutation primitives such as rht_insert() as long as the traversal
+ * is guarded by rcu_read_lock().
  */
-#define rht_for_each_entry_rcu(pos, head, member) \
-	for (pos = rht_entry_safe(rcu_dereference_raw(head), \
-				  typeof(*(pos)), member); \
-	     pos; \
-	     pos = rht_entry_safe(rcu_dereference_raw((pos)->member.next), \
-				  typeof(*(pos)), member))
+#define rht_for_each_entry_rcu(tpos, pos, tbl, hash, member)		\
+	for (({barrier(); }),						\
+	     pos = rht_get_bucket_rcu(tbl, hash);			\
+	     (!rht_is_a_nulls(pos)) && rht_entry(tpos, pos, member);	\
+	     pos = rht_dereference_bucket_rcu(pos->next, tbl, hash))
 
 #endif /* _LINUX_RHASHTABLE_H */
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index c10df45..d871483 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -28,6 +28,23 @@
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4UL
 
+/*
+ * The nulls marker consists of:
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
+ */
+#define HASH_BASE_BITS		4
+#define HASH_BASE_MIN		(1 << (31 - HASH_BASE_BITS))
+#define HASH_RESERVED_SPACE	(HASH_BASE_BITS + 1)
+
 #define ASSERT_RHT_MUTEX(HT) BUG_ON(!lockdep_rht_mutex_is_held(HT))
 
 #ifdef CONFIG_PROVE_LOCKING
@@ -43,14 +60,22 @@ static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
 	return (void *) he - ht->p.head_offset;
 }
 
-static u32 __hashfn(const struct rhashtable *ht, const void *key,
-		      u32 len, u32 hsize)
+static u32 rht_bucket_index(u32 hash, const struct bucket_table *tbl)
 {
-	u32 h;
+	return hash & (tbl->size - 1);
+}
 
-	h = ht->p.hashfn(key, len, ht->p.hash_rnd);
+static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
+{
+	u32 hash;
+
+	if (unlikely(!ht->p.key_len))
+		hash = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
+	else
+		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
+				    ht->p.hash_rnd);
 
-	return h & (hsize - 1);
+	return hash >> HASH_RESERVED_SPACE;
 }
 
 /**
@@ -66,23 +91,14 @@ static u32 __hashfn(const struct rhashtable *ht, const void *key,
 u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len)
 {
 	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+	u32 hash;
 
-	return __hashfn(ht, key, len, tbl->size);
-}
-EXPORT_SYMBOL_GPL(rhashtable_hashfn);
-
-static u32 obj_hashfn(const struct rhashtable *ht, const void *ptr, u32 hsize)
-{
-	if (unlikely(!ht->p.key_len)) {
-		u32 h;
-
-		h = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
-
-		return h & (hsize - 1);
-	}
+	hash = ht->p.hashfn(key, len, ht->p.hash_rnd);
+	hash >>= HASH_RESERVED_SPACE;
 
-	return __hashfn(ht, ptr + ht->p.key_offset, ht->p.key_len, hsize);
+	return rht_bucket_index(hash, tbl);
 }
+EXPORT_SYMBOL_GPL(rhashtable_hashfn);
 
 /**
  * rhashtable_obj_hashfn - compute hash for hashed object
@@ -98,20 +114,23 @@ u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr)
 {
 	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 
-	return obj_hashfn(ht, ptr, tbl->size);
+	return rht_bucket_index(obj_raw_hashfn(ht, ptr), tbl);
 }
 EXPORT_SYMBOL_GPL(rhashtable_obj_hashfn);
 
 static u32 head_hashfn(const struct rhashtable *ht,
-		       const struct rhash_head *he, u32 hsize)
+		       const struct rhash_head *he,
+		       const struct bucket_table *tbl)
 {
-	return obj_hashfn(ht, rht_obj(ht, he), hsize);
+	return rht_bucket_index(obj_raw_hashfn(ht, rht_obj(ht, he)), tbl);
 }
 
-static struct bucket_table *bucket_table_alloc(size_t nbuckets)
+static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
+					       size_t nbuckets)
 {
 	struct bucket_table *tbl;
 	size_t size;
+	int i;
 
 	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
 	tbl = kzalloc(size, GFP_KERNEL);
@@ -121,6 +140,9 @@ static struct bucket_table *bucket_table_alloc(size_t nbuckets)
 	if (tbl == NULL)
 		return NULL;
 
+	for (i = 0; i < nbuckets; i++)
+		INIT_RHT_NULLS_HEAD(tbl->buckets[i], ht, i);
+
 	tbl->size = nbuckets;
 
 	return tbl;
@@ -159,34 +181,36 @@ static void hashtable_chain_unzip(const struct rhashtable *ht,
 				  const struct bucket_table *new_tbl,
 				  struct bucket_table *old_tbl, size_t n)
 {
-	struct rhash_head *he, *p, *next;
-	unsigned int h;
+	struct rhash_head *he, *p;
+	struct rhash_head __rcu *next;
+	u32 hash, new_tbl_idx;
 
 	/* Old bucket empty, no work needed. */
-	p = rht_dereference(old_tbl->buckets[n], ht);
-	if (!p)
+	p = rht_get_bucket(old_tbl, n);
+	if (rht_is_a_nulls(p))
 		return;
 
 	/* Advance the old bucket pointer one or more times until it
 	 * reaches a node that doesn't hash to the same bucket as the
 	 * previous node p. Call the previous node p;
 	 */
-	h = head_hashfn(ht, p, new_tbl->size);
-	rht_for_each(he, p->next, ht) {
-		if (head_hashfn(ht, he, new_tbl->size) != h)
+	hash = obj_raw_hashfn(ht, rht_obj(ht, p));
+	new_tbl_idx = rht_bucket_index(hash, new_tbl);
+	rht_for_each_continue(he, p->next, old_tbl, n) {
+		if (head_hashfn(ht, he, new_tbl) != new_tbl_idx)
 			break;
 		p = he;
 	}
-	RCU_INIT_POINTER(old_tbl->buckets[n], p->next);
+	RCU_INIT_POINTER(old_tbl->buckets[n], he);
 
 	/* Find the subsequent node which does hash to the same
 	 * bucket as node P, or NULL if no such node exists.
 	 */
-	next = NULL;
-	if (he) {
-		rht_for_each(he, he->next, ht) {
-			if (head_hashfn(ht, he, new_tbl->size) == h) {
-				next = he;
+	INIT_RHT_NULLS_HEAD(next, ht, hash);
+	if (!rht_is_a_nulls(he)) {
+		rht_for_each_continue(he, he->next, old_tbl, n) {
+			if (head_hashfn(ht, he, new_tbl) == new_tbl_idx) {
+				next = (struct rhash_head __rcu *) he;
 				break;
 			}
 		}
@@ -223,7 +247,7 @@ int rhashtable_expand(struct rhashtable *ht)
 	if (ht->p.max_shift && ht->shift >= ht->p.max_shift)
 		return 0;
 
-	new_tbl = bucket_table_alloc(old_tbl->size * 2);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -239,8 +263,8 @@ int rhashtable_expand(struct rhashtable *ht)
 	 */
 	for (i = 0; i < new_tbl->size; i++) {
 		h = i & (old_tbl->size - 1);
-		rht_for_each(he, old_tbl->buckets[h], ht) {
-			if (head_hashfn(ht, he, new_tbl->size) == i) {
+		rht_for_each(he, old_tbl, h) {
+			if (head_hashfn(ht, he, new_tbl) == i) {
 				RCU_INIT_POINTER(new_tbl->buckets[i], he);
 				break;
 			}
@@ -268,7 +292,7 @@ int rhashtable_expand(struct rhashtable *ht)
 		complete = true;
 		for (i = 0; i < old_tbl->size; i++) {
 			hashtable_chain_unzip(ht, new_tbl, old_tbl, i);
-			if (old_tbl->buckets[i] != NULL)
+			if (!rht_is_a_nulls(old_tbl->buckets[i]))
 				complete = false;
 		}
 	} while (!complete);
@@ -299,7 +323,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 	if (ht->shift <= ht->p.min_shift)
 		return 0;
 
-	ntbl = bucket_table_alloc(tbl->size / 2);
+	ntbl = bucket_table_alloc(ht, tbl->size / 2);
 	if (ntbl == NULL)
 		return -ENOMEM;
 
@@ -316,8 +340,9 @@ int rhashtable_shrink(struct rhashtable *ht)
 		 * in the old table that contains entries which will hash
 		 * to the new bucket.
 		 */
-		for (pprev = &ntbl->buckets[i]; *pprev != NULL;
-		     pprev = &rht_dereference(*pprev, ht)->next)
+		for (pprev = &ntbl->buckets[i];
+		     !rht_is_a_nulls(rht_dereference_bucket(*pprev, ntbl, i));
+		     pprev = &rht_dereference_bucket(*pprev, ntbl, i)->next)
 			;
 		RCU_INIT_POINTER(*pprev, tbl->buckets[i + ntbl->size]);
 	}
@@ -350,13 +375,17 @@ EXPORT_SYMBOL_GPL(rhashtable_shrink);
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 {
 	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
-	u32 hash;
+	u32 hash, idx;
 
 	ASSERT_RHT_MUTEX(ht);
 
-	hash = head_hashfn(ht, obj, tbl->size);
-	RCU_INIT_POINTER(obj->next, tbl->buckets[hash]);
-	rcu_assign_pointer(tbl->buckets[hash], obj);
+	hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
+	idx = rht_bucket_index(hash, tbl);
+	if (rht_is_a_nulls(rht_get_bucket(tbl, idx)))
+		INIT_RHT_NULLS_HEAD(obj->next, ht, hash);
+	else
+		obj->next = tbl->buckets[idx];
+	rcu_assign_pointer(tbl->buckets[idx], obj);
 	ht->nelems++;
 
 	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
@@ -410,14 +439,13 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
 	struct rhash_head __rcu **pprev;
 	struct rhash_head *he;
-	u32 h;
+	u32 idx;
 
 	ASSERT_RHT_MUTEX(ht);
 
-	h = head_hashfn(ht, obj, tbl->size);
-
-	pprev = &tbl->buckets[h];
-	rht_for_each(he, tbl->buckets[h], ht) {
+	idx = head_hashfn(ht, obj, tbl);
+	pprev = &tbl->buckets[idx];
+	rht_for_each(he, tbl, idx) {
 		if (he != obj) {
 			pprev = &he->next;
 			continue;
@@ -453,12 +481,12 @@ void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
 
 	BUG_ON(!ht->p.key_len);
 
-	h = __hashfn(ht, key, ht->p.key_len, tbl->size);
-	rht_for_each_rcu(he, tbl->buckets[h], ht) {
+	h = rhashtable_hashfn(ht, key, ht->p.key_len);
+	rht_for_each_rcu(he, tbl, h) {
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
 			continue;
-		return (void *) he - ht->p.head_offset;
+		return rht_obj(ht, he);
 	}
 
 	return NULL;
@@ -489,7 +517,7 @@ void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
 	if (unlikely(hash >= tbl->size))
 		return NULL;
 
-	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
+	rht_for_each_rcu(he, tbl, hash) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
 		return (void *) he - ht->p.head_offset;
@@ -560,19 +588,23 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	    (!params->key_len && !params->obj_hashfn))
 		return -EINVAL;
 
+	if (params->nulls_base && params->nulls_base < HASH_BASE_MIN)
+		return -EINVAL;
+
 	params->min_shift = max_t(size_t, params->min_shift,
 				  ilog2(HASH_MIN_SIZE));
 
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(params);
 
-	tbl = bucket_table_alloc(size);
+	memset(ht, 0, sizeof(*ht));
+	memcpy(&ht->p, params, sizeof(*params));
+
+	tbl = bucket_table_alloc(ht, size);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-	memset(ht, 0, sizeof(*ht));
 	ht->shift = ilog2(tbl->size);
-	memcpy(&ht->p, params, sizeof(*params));
 	RCU_INIT_POINTER(ht->tbl, tbl);
 
 	if (!ht->p.hash_rnd)
@@ -652,6 +684,7 @@ static void test_bucket_stats(struct rhashtable *ht, struct bucket_table *tbl,
 			      bool quiet)
 {
 	unsigned int cnt, rcu_cnt, i, total = 0;
+	struct rhash_head *pos;
 	struct test_obj *obj;
 
 	for (i = 0; i < tbl->size; i++) {
@@ -660,7 +693,7 @@ static void test_bucket_stats(struct rhashtable *ht, struct bucket_table *tbl,
 		if (!quiet)
 			pr_info(" [%#4x/%zu]", i, tbl->size);
 
-		rht_for_each_entry_rcu(obj, tbl->buckets[i], node) {
+		rht_for_each_entry_rcu(obj, pos, tbl, i, node) {
 			cnt++;
 			total++;
 			if (!quiet)
@@ -689,7 +722,8 @@ static void test_bucket_stats(struct rhashtable *ht, struct bucket_table *tbl,
 static int __init test_rhashtable(struct rhashtable *ht)
 {
 	struct bucket_table *tbl;
-	struct test_obj *obj, *next;
+	struct test_obj *obj;
+	struct rhash_head *pos, *next;
 	int err;
 	unsigned int i;
 
@@ -755,7 +789,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 error:
 	tbl = rht_dereference_rcu(ht->tbl, ht);
 	for (i = 0; i < tbl->size; i++)
-		rht_for_each_entry_safe(obj, next, tbl->buckets[i], ht, node)
+		rht_for_each_entry_safe(obj, pos, next, tbl, i, node)
 			kfree(obj);
 
 	return err;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index b52873c..68b654b 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -99,12 +99,13 @@ static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
 	const struct rhashtable *priv = nft_set_priv(set);
 	const struct bucket_table *tbl = rht_dereference_rcu(priv->tbl, priv);
 	struct rhash_head __rcu * const *pprev;
+	struct rhash_head *pos;
 	struct nft_hash_elem *he;
 	u32 h;
 
 	h = rhashtable_hashfn(priv, &elem->key, set->klen);
 	pprev = &tbl->buckets[h];
-	rht_for_each_entry_rcu(he, tbl->buckets[h], node) {
+	rht_for_each_entry_rcu(he, pos, tbl, h, node) {
 		if (nft_data_cmp(&he->key, &elem->key, set->klen)) {
 			pprev = &he->node.next;
 			continue;
@@ -130,7 +131,9 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 
 	tbl = rht_dereference_rcu(priv->tbl, priv);
 	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_rcu(he, tbl->buckets[i], node) {
+		struct rhash_head *pos;
+
+		rht_for_each_entry_rcu(he, pos, tbl, i, node) {
 			if (iter->count < iter->skip)
 				goto cont;
 
@@ -181,12 +184,13 @@ static void nft_hash_destroy(const struct nft_set *set)
 {
 	const struct rhashtable *priv = nft_set_priv(set);
 	const struct bucket_table *tbl;
-	struct nft_hash_elem *he, *next;
+	struct nft_hash_elem *he;
+	struct rhash_head *pos, *next;
 	unsigned int i;
 
 	tbl = rht_dereference(priv->tbl, priv);
 	for (i = 0; i < tbl->size; i++)
-		rht_for_each_entry_safe(he, next, tbl->buckets[i], priv, node)
+		rht_for_each_entry_safe(he, pos, next, tbl, i, node)
 			nft_hash_elem_destroy(set, he);
 
 	rhashtable_destroy(priv);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a1e6104..98e5b58 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2903,7 +2903,9 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 		const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 
 		for (j = 0; j < tbl->size; j++) {
-			rht_for_each_entry_rcu(nlk, tbl->buckets[j], node) {
+			struct rhash_head *node;
+
+			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
 				s = (struct sock *)nlk;
 
 				if (sock_net(s) != seq_file_net(seq))
@@ -2929,6 +2931,7 @@ static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct rhash_head *node;
 	struct netlink_sock *nlk;
 	struct nl_seq_iter *iter;
 	struct net *net;
@@ -2943,7 +2946,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	iter = seq->private;
 	nlk = v;
 
-	rht_for_each_entry_rcu(nlk, nlk->node.next, node)
+	rht_for_each_entry_rcu_continue(nlk, node, nlk->node.next, node)
 		if (net_eq(sock_net((struct sock *)nlk), net))
 			return nlk;
 
@@ -2955,7 +2958,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 
 		for (; j < tbl->size; j++) {
-			rht_for_each_entry_rcu(nlk, tbl->buckets[j], node) {
+			rht_for_each_entry_rcu(nlk, node, tbl, j, node) {
 				if (net_eq(sock_net((struct sock *)nlk), net)) {
 					iter->link = i;
 					iter->hash_idx = j;
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index de8c74a..1062bb4 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -113,7 +113,9 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	req = nlmsg_data(cb->nlh);
 
 	for (i = 0; i < htbl->size; i++) {
-		rht_for_each_entry(nlsk, htbl->buckets[i], ht, node) {
+		struct rhash_head *node;
+
+		rht_for_each_entry(nlsk, node, htbl, i, node) {
 			sk = (struct sock *)nlsk;
 
 			if (!net_eq(sock_net(sk), net))
-- 
1.9.3
