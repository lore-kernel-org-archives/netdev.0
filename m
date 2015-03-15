From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Sun, 15 Mar 2015 21:44:25 +1100
Message-ID: <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55231 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbCOKoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keeping both size and shift is silly.  We only need one.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    2 --
 lib/rhashtable.c           |    5 ++---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 1695378..f16e856 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -51,7 +51,6 @@ struct rhash_head {
  * @size: Number of hash buckets
  * @rehash: Current bucket being rehashed
  * @hash_rnd: Random seed to fold into hash
- * @shift: Current size (1 << shift)
  * @locks_mask: Mask to apply before accessing locks[]
  * @locks: Array of spinlocks protecting individual buckets
  * @walkers: List of active walkers
@@ -63,7 +62,6 @@ struct bucket_table {
 	unsigned int		size;
 	unsigned int		rehash;
 	u32			hash_rnd;
-	u32			shift;
 	unsigned int		locks_mask;
 	spinlock_t		*locks;
 	struct list_head	walkers;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index c523d3a..4a99c0c 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -162,7 +162,6 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 		return NULL;
 
 	tbl->size = nbuckets;
-	tbl->shift = ilog2(nbuckets);
 
 	if (alloc_bucket_locks(ht, tbl) < 0) {
 		bucket_table_free(tbl);
@@ -189,7 +188,7 @@ static bool rht_grow_above_75(const struct rhashtable *ht,
 {
 	/* Expand table when exceeding 75% load */
 	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
-	       (!ht->p.max_shift || tbl->shift < ht->p.max_shift);
+	       (!ht->p.max_shift || tbl->size < (1 << ht->p.max_shift));
 }
 
 /**
@@ -202,7 +201,7 @@ static bool rht_shrink_below_30(const struct rhashtable *ht,
 {
 	/* Shrink table beneath 30% load */
 	return atomic_read(&ht->nelems) < (tbl->size * 3 / 10) &&
-	       tbl->shift > ht->p.min_shift;
+	       tbl->size > (1 << ht->p.min_shift);
 }
 
 static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
