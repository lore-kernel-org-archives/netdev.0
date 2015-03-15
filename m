From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 2/14] rhashtable: Introduce max_size/min_size
Date: Sun, 15 Mar 2015 21:44:26 +1100
Message-ID: <E1YX61y-0005mR-MK@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56257 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbbCOKob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the parameters max_size and min_size which are
meant to replace max_shift and min_shift.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    4 ++++
 lib/rhashtable.c           |   12 ++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index f16e856..81267fe 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -85,6 +85,8 @@ struct rhashtable;
  * @head_offset: Offset of rhash_head in struct to be hashed
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
+ * @max_size: Maximum size while expanding
+ * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Function to hash key
@@ -97,6 +99,8 @@ struct rhashtable_params {
 	size_t			head_offset;
 	size_t			max_shift;
 	size_t			min_shift;
+	unsigned int		max_size;
+	unsigned int		min_size;
 	u32			nulls_base;
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4a99c0c..5101e18 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -27,7 +27,7 @@
 #include <linux/err.h>
 
 #define HASH_DEFAULT_SIZE	64UL
-#define HASH_MIN_SIZE		4UL
+#define HASH_MIN_SIZE		4U
 #define BUCKET_LOCKS_PER_CPU   128UL
 
 /* Base bits plus 1 bit for nulls marker */
@@ -188,7 +188,8 @@ static bool rht_grow_above_75(const struct rhashtable *ht,
 {
 	/* Expand table when exceeding 75% load */
 	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
-	       (!ht->p.max_shift || tbl->size < (1 << ht->p.max_shift));
+	       (!ht->p.max_shift || tbl->size < (1 << ht->p.max_shift)) &&
+	       (!ht->p.max_size || tbl->size < ht->p.max_size);
 }
 
 /**
@@ -201,7 +202,8 @@ static bool rht_shrink_below_30(const struct rhashtable *ht,
 {
 	/* Shrink table beneath 30% load */
 	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
-	       tbl->size > (1 << ht->p.min_shift);
+	       tbl->size > (1 << ht->p.min_shift) &&
+	       tbl->size > ht->p.min_size;
 }
 
 static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
@@ -872,7 +874,8 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
-		   1UL << params->min_shift);
+		   max(1UL << params->min_shift,
+		       (unsigned long)params->min_size));
 }
 
 /**
@@ -934,6 +937,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 
 	params->min_shift = max_t(size_t, params->min_shift,
 				  ilog2(HASH_MIN_SIZE));
+	params->min_size = max(params->min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(params);
