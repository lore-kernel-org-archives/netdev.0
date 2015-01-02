From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/9] nft_hash: Remove rhashtable_remove_pprev()
Date: Fri,  2 Jan 2015 23:00:18 +0100
Message-ID: <257e56ba4e6b8c7d556de5c8cfe86e048f1aa264.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39302 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbbABWAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:00:42 -0500
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The removal function of nft_hash currently stores a reference to the
previous element during lookup which is used to optimize removal later
on. This was possible because a lock is held throughout calling
rhashtable_lookup() and rhashtable_remove().

With the introdution of deferred table resizing in parallel to lookups
and insertions, the nftables lock will no longer synchronize all
table mutations and the stored pprev may become invalid.

Removing this optimization makes removal slightly more expensive on
average but allows taking the resize cost out of the insert and
remove path.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Cc: netfilter-devel@vger.kernel.org
---
 include/linux/rhashtable.h |  2 --
 lib/rhashtable.c           | 34 +++++++---------------------------
 net/netfilter/nft_hash.c   | 11 +++--------
 3 files changed, 10 insertions(+), 37 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index b54e24a..f624d4b 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -105,8 +105,6 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params);
 
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node);
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node);
-void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
-			     struct rhash_head __rcu **pprev);
 
 bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size);
 bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 0bd29c1..e6b85c4 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -345,32 +345,6 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 EXPORT_SYMBOL_GPL(rhashtable_insert);
 
 /**
- * rhashtable_remove_pprev - remove object from hash table given previous element
- * @ht:		hash table
- * @obj:	pointer to hash head inside object
- * @pprev:	pointer to previous element
- *
- * Identical to rhashtable_remove() but caller is alreayd aware of the element
- * in front of the element to be deleted. This is in particular useful for
- * deletion when combined with walking or lookup.
- */
-void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
-			     struct rhash_head __rcu **pprev)
-{
-	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
-
-	ASSERT_RHT_MUTEX(ht);
-
-	RCU_INIT_POINTER(*pprev, obj->next);
-	ht->nelems--;
-
-	if (ht->p.shrink_decision &&
-	    ht->p.shrink_decision(ht, tbl->size))
-		rhashtable_shrink(ht);
-}
-EXPORT_SYMBOL_GPL(rhashtable_remove_pprev);
-
-/**
  * rhashtable_remove - remove object from hash table
  * @ht:		hash table
  * @obj:	pointer to hash head inside object
@@ -403,7 +377,13 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 			continue;
 		}
 
-		rhashtable_remove_pprev(ht, he, pprev);
+		RCU_INIT_POINTER(*pprev, he->next);
+		ht->nelems--;
+
+		if (ht->p.shrink_decision &&
+		    ht->p.shrink_decision(ht, tbl->size))
+			rhashtable_shrink(ht);
+
 		return true;
 	}
 
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index d93f1f4..7f903cf 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -83,15 +83,10 @@ static void nft_hash_remove(const struct nft_set *set,
 			    const struct nft_set_elem *elem)
 {
 	struct rhashtable *priv = nft_set_priv(set);
-	struct rhash_head *he, __rcu **pprev;
-
-	pprev = elem->cookie;
-	he = rht_dereference((*pprev), priv);
-
-	rhashtable_remove_pprev(priv, he, pprev);
 
+	rhashtable_remove(priv, elem->cookie);
 	synchronize_rcu();
-	kfree(he);
+	kfree(elem->cookie);
 }
 
 struct nft_compare_arg {
@@ -105,7 +100,7 @@ static bool nft_hash_compare(void *ptr, void *arg)
 	struct nft_compare_arg *x = arg;
 
 	if (!nft_data_cmp(&he->key, &x->elem->key, x->set->klen)) {
-		x->elem->cookie = &he->node;
+		x->elem->cookie = he;
 		x->elem->flags = 0;
 		if (x->set->flags & NFT_SET_MAP)
 			nft_data_copy(&x->elem->data, he->data);
-- 
1.9.3
