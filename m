From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 8/9] rhashtable: Allow GFP_ATOMIC bucket table allocation
Date: Tue, 24 Mar 2015 00:50:27 +1100
Message-ID: <E1Ya2kN-0004Iw-KE@gondolin.me.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38457 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbbCWNut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:50:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ability to allocate bucket table with GFP_ATOMIC
instead of GFP_KERNEL.  This is needed when we perform an immediate
rehash during insertion.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |   26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5e04403..220a11a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -58,7 +58,8 @@ EXPORT_SYMBOL_GPL(lockdep_rht_bucket_is_held);
 #endif
 
 
-static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
+static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
+			      gfp_t gfp)
 {
 	unsigned int i, size;
 #if defined(CONFIG_PROVE_LOCKING)
@@ -75,12 +76,13 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
 
 	if (sizeof(spinlock_t) != 0) {
 #ifdef CONFIG_NUMA
-		if (size * sizeof(spinlock_t) > PAGE_SIZE)
+		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
+		    gfp == GFP_KERNEL)
 			tbl->locks = vmalloc(size * sizeof(spinlock_t));
 		else
 #endif
 		tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
-					   GFP_KERNEL);
+					   gfp);
 		if (!tbl->locks)
 			return -ENOMEM;
 		for (i = 0; i < size; i++)
@@ -105,23 +107,25 @@ static void bucket_table_free_rcu(struct rcu_head *head)
 }
 
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
-					       size_t nbuckets)
+					       size_t nbuckets,
+					       gfp_t gfp)
 {
 	struct bucket_table *tbl = NULL;
 	size_t size;
 	int i;
 
 	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
-	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
-		tbl = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
-	if (tbl == NULL)
+	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) ||
+	    gfp != GFP_KERNEL)
+		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
+	if (tbl == NULL && gfp == GFP_KERNEL)
 		tbl = vzalloc(size);
 	if (tbl == NULL)
 		return NULL;
 
 	tbl->size = nbuckets;
 
-	if (alloc_bucket_locks(ht, tbl) < 0) {
+	if (alloc_bucket_locks(ht, tbl, gfp) < 0) {
 		bucket_table_free(tbl);
 		return NULL;
 	}
@@ -288,7 +292,7 @@ static int rhashtable_expand(struct rhashtable *ht)
 
 	old_tbl = rhashtable_last_table(ht, old_tbl);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2, GFP_KERNEL);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -332,7 +336,7 @@ static int rhashtable_shrink(struct rhashtable *ht)
 	if (rht_dereference(old_tbl->future_tbl, ht))
 		return -EEXIST;
 
-	new_tbl = bucket_table_alloc(ht, size);
+	new_tbl = bucket_table_alloc(ht, size, GFP_KERNEL);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -689,7 +693,7 @@ int rhashtable_init(struct rhashtable *ht,
 		}
 	}
 
-	tbl = bucket_table_alloc(ht, size);
+	tbl = bucket_table_alloc(ht, size, GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
