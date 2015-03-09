From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] rhashtable: Move hash_rnd into bucket_table
Date: Tue, 10 Mar 2015 09:27:55 +1100
Message-ID: <E1YV69T-0003DX-CV@gondolin.me.apana.org.au>
References: <20150309222631.GA12221@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52662 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710AbbCIW17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:27:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently hash_rnd is a parameter that users can set.  However,
no existing users set this parameter.  It is also something that
people are unlikely to want to set directly since it's just a
random number.

In preparation for allowing the reseeding/rehashing of rhashtable,
this patch moves hash_rnd into bucket_table so that it's now an
internal state rather than a parameter.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    4 ++--
 lib/rhashtable.c           |   24 +++++++++++++++---------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index d438eeb..5ef8ea5 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -49,12 +49,14 @@ struct rhash_head {
 /**
  * struct bucket_table - Table of hash buckets
  * @size: Number of hash buckets
+ * @hash_rnd: Random seed to fold into hash
  * @locks_mask: Mask to apply before accessing locks[]
  * @locks: Array of spinlocks protecting individual buckets
  * @buckets: size * hash buckets
  */
 struct bucket_table {
 	size_t			size;
+	u32			hash_rnd;
 	unsigned int		locks_mask;
 	spinlock_t		*locks;
 
@@ -72,7 +74,6 @@ struct rhashtable;
  * @key_len: Length of key
  * @key_offset: Offset of key in struct to be hashed
  * @head_offset: Offset of rhash_head in struct to be hashed
- * @hash_rnd: Seed to use while hashing
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
  * @nulls_base: Base value to generate nulls marker
@@ -85,7 +86,6 @@ struct rhashtable_params {
 	size_t			key_len;
 	size_t			key_offset;
 	size_t			head_offset;
-	u32			hash_rnd;
 	size_t			max_shift;
 	size_t			min_shift;
 	u32			nulls_base;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b5344ef..ba15dce 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -66,25 +66,28 @@ static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 	return hash & (tbl->size - 1);
 }
 
-static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
+static u32 obj_raw_hashfn(struct rhashtable *ht, const void *ptr)
 {
+	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
 
 	if (unlikely(!ht->p.key_len))
-		hash = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
+		hash = ht->p.obj_hashfn(ptr, tbl->hash_rnd);
 	else
 		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
-				    ht->p.hash_rnd);
+				    tbl->hash_rnd);
 
 	return hash >> HASH_RESERVED_SPACE;
 }
 
 static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
 {
-	return ht->p.hashfn(key, len, ht->p.hash_rnd) >> HASH_RESERVED_SPACE;
+	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	return ht->p.hashfn(key, len, tbl->hash_rnd) >> HASH_RESERVED_SPACE;
 }
 
-static u32 head_hashfn(const struct rhashtable *ht,
+static u32 head_hashfn(struct rhashtable *ht,
 		       const struct bucket_table *tbl,
 		       const struct rhash_head *he)
 {
@@ -92,7 +95,7 @@ static u32 head_hashfn(const struct rhashtable *ht,
 }
 
 #ifdef CONFIG_PROVE_LOCKING
-static void debug_dump_buckets(const struct rhashtable *ht,
+static void debug_dump_buckets(struct rhashtable *ht,
 			       const struct bucket_table *tbl)
 {
 	struct rhash_head *he;
@@ -385,6 +388,8 @@ int rhashtable_expand(struct rhashtable *ht)
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
+	new_tbl->hash_rnd = old_tbl->hash_rnd;
+
 	atomic_inc(&ht->shift);
 
 	/* Make insertions go into the new, empty table right away. Deletions
@@ -476,6 +481,8 @@ int rhashtable_shrink(struct rhashtable *ht)
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
+	new_tbl->hash_rnd = tbl->hash_rnd;
+
 	rcu_assign_pointer(ht->future_tbl, new_tbl);
 	synchronize_rcu();
 
@@ -1099,14 +1106,13 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (tbl == NULL)
 		return -ENOMEM;
 
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
+
 	atomic_set(&ht->nelems, 0);
 	atomic_set(&ht->shift, ilog2(tbl->size));
 	RCU_INIT_POINTER(ht->tbl, tbl);
 	RCU_INIT_POINTER(ht->future_tbl, tbl);
 
-	if (!ht->p.hash_rnd)
-		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
-
 	INIT_WORK(&ht->run_work, rht_deferred_worker);
 
 	return 0;
