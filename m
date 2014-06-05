From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nft_rbtree: introduce locking
Date: Thu,  5 Jun 2014 17:08:24 +0200
Message-ID: <1401980906-25290-5-git-send-email-pablo@netfilter.org>
References: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1401980906-25290-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no rbtree rcu version yet, so let's fall back on the spinlock
to protect the concurrent access of this structure both from user
(to update the set content) and kernel-space (in the packet path).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_rbtree.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 072e611..e1836ff 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -18,6 +18,8 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 
+static DEFINE_SPINLOCK(nft_rbtree_lock);
+
 struct nft_rbtree {
 	struct rb_root		root;
 };
@@ -38,6 +40,7 @@ static bool nft_rbtree_lookup(const struct nft_set *set,
 	const struct rb_node *parent = priv->root.rb_node;
 	int d;
 
+	spin_lock_bh(&nft_rbtree_lock);
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
@@ -53,6 +56,8 @@ found:
 				goto out;
 			if (set->flags & NFT_SET_MAP)
 				nft_data_copy(data, rbe->data);
+
+			spin_unlock_bh(&nft_rbtree_lock);
 			return true;
 		}
 	}
@@ -62,6 +67,7 @@ found:
 		goto found;
 	}
 out:
+	spin_unlock_bh(&nft_rbtree_lock);
 	return false;
 }
 
@@ -124,9 +130,12 @@ static int nft_rbtree_insert(const struct nft_set *set,
 	    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 		nft_data_copy(rbe->data, &elem->data);
 
+	spin_lock_bh(&nft_rbtree_lock);
 	err = __nft_rbtree_insert(set, rbe);
 	if (err < 0)
 		kfree(rbe);
+
+	spin_unlock_bh(&nft_rbtree_lock);
 	return err;
 }
 
@@ -136,7 +145,9 @@ static void nft_rbtree_remove(const struct nft_set *set,
 	struct nft_rbtree *priv = nft_set_priv(set);
 	struct nft_rbtree_elem *rbe = elem->cookie;
 
+	spin_lock_bh(&nft_rbtree_lock);
 	rb_erase(&rbe->node, &priv->root);
+	spin_unlock_bh(&nft_rbtree_lock);
 	kfree(rbe);
 }
 
@@ -147,6 +158,7 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 	struct nft_rbtree_elem *rbe;
 	int d;
 
+	spin_lock_bh(&nft_rbtree_lock);
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
@@ -161,9 +173,11 @@ static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
 			    !(rbe->flags & NFT_SET_ELEM_INTERVAL_END))
 				nft_data_copy(&elem->data, rbe->data);
 			elem->flags = rbe->flags;
+			spin_unlock_bh(&nft_rbtree_lock);
 			return 0;
 		}
 	}
+	spin_unlock_bh(&nft_rbtree_lock);
 	return -ENOENT;
 }
 
@@ -176,6 +190,7 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 	struct nft_set_elem elem;
 	struct rb_node *node;
 
+	spin_lock_bh(&nft_rbtree_lock);
 	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
 		if (iter->count < iter->skip)
 			goto cont;
@@ -188,11 +203,14 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 		elem.flags = rbe->flags;
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
-		if (iter->err < 0)
+		if (iter->err < 0) {
+			spin_unlock_bh(&nft_rbtree_lock);
 			return;
+		}
 cont:
 		iter->count++;
 	}
+	spin_unlock_bh(&nft_rbtree_lock);
 }
 
 static unsigned int nft_rbtree_privsize(const struct nlattr * const nla[])
@@ -216,11 +234,13 @@ static void nft_rbtree_destroy(const struct nft_set *set)
 	struct nft_rbtree_elem *rbe;
 	struct rb_node *node;
 
+	spin_lock_bh(&nft_rbtree_lock);
 	while ((node = priv->root.rb_node) != NULL) {
 		rb_erase(node, &priv->root);
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
 		nft_rbtree_elem_destroy(set, rbe);
 	}
+	spin_unlock_bh(&nft_rbtree_lock);
 }
 
 static bool nft_rbtree_estimate(const struct nft_set_desc *desc, u32 features,
-- 
1.7.10.4

