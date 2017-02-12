From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/21] netfilter: nf_tables: rename deactivate_one() to flush()
Date: Sun, 12 Feb 2017 20:42:36 +0100
Message-ID: <1486928573-24773-5-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60442 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751355AbdBLTnP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:15 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 38AA2BA707
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:12 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 26C3ADA84A
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:12 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7BACDDA819
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:09 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although semantics are similar to deactivate() with no implicit element
lookup, this is only called from the set flush path, so better rename
this to flush().

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 8 ++++----
 net/netfilter/nf_tables_api.c     | 2 +-
 net/netfilter/nft_set_hash.c      | 8 ++++----
 net/netfilter/nft_set_rbtree.c    | 8 ++++----
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a721bcb1210c..ab155644d489 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -260,7 +260,7 @@ struct nft_expr;
  *	@insert: insert new element into set
  *	@activate: activate new element in the next generation
  *	@deactivate: lookup for element and deactivate it in the next generation
- *	@deactivate_one: deactivate element in the next generation
+ *	@flush: deactivate element in the next generation
  *	@remove: remove element from set
  *	@walk: iterate over all set elemeennts
  *	@privsize: function to return size of set private data
@@ -295,9 +295,9 @@ struct nft_set_ops {
 	void *				(*deactivate)(const struct net *net,
 						      const struct nft_set *set,
 						      const struct nft_set_elem *elem);
-	bool				(*deactivate_one)(const struct net *net,
-							  const struct nft_set *set,
-							  void *priv);
+	bool				(*flush)(const struct net *net,
+						 const struct nft_set *set,
+						 void *priv);
 	void				(*remove)(const struct net *net,
 						  const struct nft_set *set,
 						  const struct nft_set_elem *elem);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 790ffed82930..c09b11eb36fc 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3898,7 +3898,7 @@ static int nft_flush_set(const struct nft_ctx *ctx,
 	if (!trans)
 		return -ENOMEM;
 
-	if (!set->ops->deactivate_one(ctx->net, set, elem->priv)) {
+	if (!set->ops->flush(ctx->net, set, elem->priv)) {
 		err = -ENOENT;
 		goto err1;
 	}
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index bb157bd47fe8..2f10ac3b1b10 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -167,8 +167,8 @@ static void nft_hash_activate(const struct net *net, const struct nft_set *set,
 	nft_set_elem_clear_busy(&he->ext);
 }
 
-static bool nft_hash_deactivate_one(const struct net *net,
-				    const struct nft_set *set, void *priv)
+static bool nft_hash_flush(const struct net *net,
+			   const struct nft_set *set, void *priv)
 {
 	struct nft_hash_elem *he = priv;
 
@@ -195,7 +195,7 @@ static void *nft_hash_deactivate(const struct net *net,
 	rcu_read_lock();
 	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
 	if (he != NULL &&
-	    !nft_hash_deactivate_one(net, set, he))
+	    !nft_hash_flush(net, set, he))
 		he = NULL;
 
 	rcu_read_unlock();
@@ -398,7 +398,7 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.insert		= nft_hash_insert,
 	.activate	= nft_hash_activate,
 	.deactivate	= nft_hash_deactivate,
-	.deactivate_one	= nft_hash_deactivate_one,
+	.flush		= nft_hash_flush,
 	.remove		= nft_hash_remove,
 	.lookup		= nft_hash_lookup,
 	.update		= nft_hash_update,
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index 9fbd70da1633..81b8a4c2c061 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -172,8 +172,8 @@ static void nft_rbtree_activate(const struct net *net,
 	nft_set_elem_change_active(net, set, &rbe->ext);
 }
 
-static bool nft_rbtree_deactivate_one(const struct net *net,
-				      const struct nft_set *set, void *priv)
+static bool nft_rbtree_flush(const struct net *net,
+			     const struct nft_set *set, void *priv)
 {
 	struct nft_rbtree_elem *rbe = priv;
 
@@ -214,7 +214,7 @@ static void *nft_rbtree_deactivate(const struct net *net,
 				parent = parent->rb_right;
 				continue;
 			}
-			nft_rbtree_deactivate_one(net, set, rbe);
+			nft_rbtree_flush(net, set, rbe);
 			return rbe;
 		}
 	}
@@ -305,7 +305,7 @@ static struct nft_set_ops nft_rbtree_ops __read_mostly = {
 	.insert		= nft_rbtree_insert,
 	.remove		= nft_rbtree_remove,
 	.deactivate	= nft_rbtree_deactivate,
-	.deactivate_one	= nft_rbtree_deactivate_one,
+	.flush		= nft_rbtree_flush,
 	.activate	= nft_rbtree_activate,
 	.lookup		= nft_rbtree_lookup,
 	.walk		= nft_rbtree_walk,
-- 
2.1.4
