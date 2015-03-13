From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/6] rhashtable: Add rehash counter to bucket_table
Date: Fri, 13 Mar 2015 20:57:14 +1100
Message-ID: <E1YWMLC-0000CE-RS@gondolin.me.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35413 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbbCMJ5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a rehash counter to bucket_table to indicate
the last bucket that has been rehashed.  This serves two purposes:

1. Any bucket that has been rehashed can never gain a new object.
2. If the rehash counter reaches the size of the table, the table
will forever remain empty.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    4 +++-
 lib/rhashtable.c           |    1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

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
 
