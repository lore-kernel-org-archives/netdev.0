From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 1/7] rhashtable: Make rhashtable_init params argument const
Date: Fri, 20 Mar 2015 21:56:59 +1100
Message-ID: <E1YYubr-0004km-9d@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45322 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbCTK5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch marks the rhashtable_init params argument const as
there is no reason to modify it since we will always make a copy
of it in the rhashtable.

This patch also fixes a bug where we don't actually round up the
value of min_size unless it is less than HASH_MIN_SIZE.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    3 ++-
 lib/rhashtable.c           |    7 ++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 99425f2..c85363c 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -181,7 +181,8 @@ static inline int lockdep_rht_bucket_is_held(const struct bucket_table *tbl,
 }
 #endif /* CONFIG_PROVE_LOCKING */
 
-int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
+int rhashtable_init(struct rhashtable *ht,
+		    const struct rhashtable_params *params);
 
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e75c48d..e0a9d59 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -870,7 +870,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
 
-static size_t rounded_hashtable_size(struct rhashtable_params *params)
+static size_t rounded_hashtable_size(const struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
 		   (unsigned long)params->min_size);
@@ -919,7 +919,8 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.obj_hashfn = my_hash_fn,
  * };
  */
-int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
+int rhashtable_init(struct rhashtable *ht,
+		    const struct rhashtable_params *params)
 {
 	struct bucket_table *tbl;
 	size_t size;
@@ -946,7 +947,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (params->max_size)
 		ht->p.max_size = rounddown_pow_of_two(params->max_size);
 
-	ht->p.min_size = max(params->min_size, HASH_MIN_SIZE);
+	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
