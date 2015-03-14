From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 5/6] rhashtable: Add rehash counter to bucket_table
Date: Sat, 14 Mar 2015 13:57:24 +1100
Message-ID: <E1YWcGS-0002oU-RF@gondolin.me.apana.org.au>
References: <20150314025339.GA10585@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36488 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbbCNC52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:57:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a rehash counter to bucket_table to indicate
the last bucket that has been rehashed.  This serves two purposes:

1. Any bucket that has been rehashed can never gain a new object.
2. If the rehash counter reaches the size of the table, the table
will forever remain empty.

This patch also downsizes bucket_table->size to an unsigned int
since we do not support sizes greater than 32 bits yet.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    4 +++-
 lib/rhashtable.c           |    1 +
 lib/test_rhashtable.c      |    2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index a0abddd..ed7562a 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -49,6 +49,7 @@ struct rhash_head {
 /**
  * struct bucket_table - Table of hash buckets
  * @size: Number of hash buckets
+ * @rehash: Current bucket being rehashed
  * @hash_rnd: Random seed to fold into hash
  * @shift: Current size (1 << shift)
  * @locks_mask: Mask to apply before accessing locks[]
@@ -58,7 +59,8 @@ struct rhash_head {
  * @buckets: size * hash buckets
  */
 struct bucket_table {
-	size_t			size;
+	unsigned int		size;
+	unsigned int		rehash;
 	u32			hash_rnd;
 	u32			shift;
 	unsigned int		locks_mask;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 36fb091..ff4ea17 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -260,6 +260,7 @@ static void rhashtable_rehash_chain(struct rhashtable *ht, unsigned old_hash)
 	spin_lock_bh(old_bucket_lock);
 	while (!rhashtable_rehash_one(ht, old_hash))
 		;
+	old_tbl->rehash++;
 	spin_unlock_bh(old_bucket_lock);
 }
 
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 67c7593..16974fd 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -80,7 +80,7 @@ static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 		rcu_cnt = cnt = 0;
 
 		if (!quiet)
-			pr_info(" [%#4x/%zu]", i, tbl->size);
+			pr_info(" [%#4x/%u]", i, tbl->size);
 
 		rht_for_each_entry_rcu(obj, pos, tbl, i, node) {
 			cnt++;
