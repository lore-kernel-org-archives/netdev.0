From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 9/10] rhashtable: Allow GFP_ATOMIC bucket table allocation
Date: Sun, 22 Mar 2015 18:53:52 +1100
Message-ID: <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54550 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbCVHyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ability to allocate bucket table with GFP_ATOMIC
instead of GFP_KERNEL.  This is needed when we perform an immediate
rehash during insertion.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index c284099..59078ed 100644
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
@@ -105,15 +107,17 @@ static void bucket_table_free_rcu(struct rcu_head *head)
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
+	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) ||
+	    gfp != GFP_KERNEL)
+		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
 	if (tbl == NULL)
 		tbl = vzalloc(size);
 	if (tbl == NULL)
@@ -121,7 +125,7 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 
 	tbl->size = nbuckets;
 
-	if (alloc_bucket_locks(ht, tbl) < 0) {
+	if (alloc_bucket_locks(ht, tbl, gfp) < 0) {
 		bucket_table_free(tbl);
 		return NULL;
 	}
@@ -273,7 +277,7 @@ static int rhashtable_expand(struct rhashtable *ht)
 
 	old_tbl = rhashtable_last_table(ht, old_tbl);
 
-	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
+	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2, GFP_KERNEL);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -304,7 +308,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 	if (size < ht->p.min_size)
 		size = ht->p.min_size;
 
-	new_tbl = bucket_table_alloc(ht, size);
+	new_tbl = bucket_table_alloc(ht, size, GFP_KERNEL);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
@@ -678,7 +682,7 @@ int rhashtable_init(struct rhashtable *ht,
 		}
 	}
 
-	tbl = bucket_table_alloc(ht, size);
+	tbl = bucket_table_alloc(ht, size, GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
