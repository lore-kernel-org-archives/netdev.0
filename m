From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 6/9] rhashtable: Shrink to fit
Date: Tue, 24 Mar 2015 00:50:25 +1100
Message-ID: <E1Ya2kL-0004IO-CI@gondolin.me.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39855 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbbCWNuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:50:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes rhashtable_shrink to shrink to the smallest
size possible rather than halving the table.  This is needed
because with multiple rehashing we will defer shrinking until
all other rehashing is done, meaning that when we do shrink
we may be able to shrink a lot.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 798f01d..9623be3 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -261,8 +261,8 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
  * rhashtable_shrink - Shrink hash table while allowing concurrent lookups
  * @ht:		the hash table to shrink
  *
- * This function may only be called in a context where it is safe to call
- * synchronize_rcu(), e.g. not within a rcu_read_lock() section.
+ * This function shrinks the hash table to fit, i.e., the smallest
+ * size would not cause it to expand right away automatically.
  *
  * The caller must ensure that no concurrent resizing occurs by holding
  * ht->mutex.
@@ -276,10 +276,17 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
+	unsigned size = roundup_pow_of_two(atomic_read(&ht->nelems) * 3 / 2);
 
 	ASSERT_RHT_MUTEX(ht);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2);
+	if (size < ht->p.min_size)
+		size = ht->p.min_size;
+
+	if (old_tbl->size <= size)
+		return 0;
+
+	new_tbl = bucket_table_alloc(ht, size);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
