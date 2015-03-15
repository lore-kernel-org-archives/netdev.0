From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 6/14] rhashtable: Remove max_shift and min_shift
Date: Sun, 15 Mar 2015 21:44:31 +1100
Message-ID: <E1YX623-0005nb-4V@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33597 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbbCOKog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that nobody uses max_shift and min_shift, we can safely remove
them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    4 ----
 lib/rhashtable.c           |    7 +------
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 81267fe..99425f2 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -83,8 +83,6 @@ struct rhashtable;
  * @key_len: Length of key
  * @key_offset: Offset of key in struct to be hashed
  * @head_offset: Offset of rhash_head in struct to be hashed
- * @max_shift: Maximum number of shifts while expanding
- * @min_shift: Minimum number of shifts while shrinking
  * @max_size: Maximum size while expanding
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
@@ -97,8 +95,6 @@ struct rhashtable_params {
 	size_t			key_len;
 	size_t			key_offset;
 	size_t			head_offset;
-	size_t			max_shift;
-	size_t			min_shift;
 	unsigned int		max_size;
 	unsigned int		min_size;
 	u32			nulls_base;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5101e18..a74ba72 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -188,7 +188,6 @@ static bool rht_grow_above_75(const struct rhashtable *ht,
 {
 	/* Expand table when exceeding 75% load */
 	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
-	       (!ht->p.max_shift || tbl->size < (1 << ht->p.max_shift)) &&
 	       (!ht->p.max_size || tbl->size < ht->p.max_size);
 }
 
@@ -202,7 +201,6 @@ static bool rht_shrink_below_30(const struct rhashtable *ht,
 {
 	/* Shrink table beneath 30% load */
 	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
-	       tbl->size > (1 << ht->p.min_shift) &&
 	       tbl->size > ht->p.min_size;
 }
 
@@ -874,8 +872,7 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
-		   max(1UL << params->min_shift,
-		       (unsigned long)params->min_size));
+		   (unsigned long)params->min_size);
 }
 
 /**
@@ -935,8 +932,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->nulls_base && params->nulls_base < (1U << RHT_BASE_SHIFT))
 		return -EINVAL;
 
-	params->min_shift = max_t(size_t, params->min_shift,
-				  ilog2(HASH_MIN_SIZE));
 	params->min_size = max(params->min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)
