From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/9] nftables: nft_rbtree: fix locking
Date: Fri, 30 Jan 2015 07:46:28 +0000
Message-ID: <1422603994-5836-4-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34109 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbbA3Hqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:46:46 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a race condition and unnecessary locking:

* the root rb_node must only be accessed under the lock in nft_rbtree_lookup()
* the lock is not needed in lookup functions in netlink contexts

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nft_rbtree.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 46214f2..417796f 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -37,10 +37,11 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 {
 	const struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
-	const struct rb_node *parent = priv->root.rb_node;
+	const struct rb_node *parent;
 	int d;
 
 	spin_lock_bh(&nft_rbtree_lock);
+	parent = priv->root.rb_node;
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
@@ -158,7 +159,6 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 	struct nft_rbtree_elem *rbe;
 	int d;
 
-	spin_lock_bh(&nft_rbtree_lock);
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
@@ -173,11 +173,9 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 			    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 				nft_data_copy(&elem->data, rbe->data);
 			elem->flags = rbe->flags;
-			spin_unlock_bh(&nft_rbtree_lock);
 			return 0;
 		}
 	}
-	spin_unlock_bh(&nft_rbtree_lock);
 	return -ENOENT;
 }
 
@@ -190,7 +188,6 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 	struct nft_set_elem elem;
 	struct rb_node *node;
 
-	spin_lock_bh(&nft_rbtree_lock);
 	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
 		if (iter->count < iter->skip)
 			goto cont;
@@ -203,14 +200,11 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 		elem.flags = rbe->flags;
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
-		if (iter->err < 0) {
-			spin_unlock_bh(&nft_rbtree_lock);
+		if (iter->err < 0)
 			return;
-		}
 cont:
 		iter->count++;
 	}
-	spin_unlock_bh(&nft_rbtree_lock);
 }
 
 static unsigned int nft_rbtree_privsize(const struct nlattr * const nla[])
-- 
2.1.0
