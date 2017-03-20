From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/22] netfilter: nft_set_rbtree: use per-set rwlock to improve the scalability
Date: Mon, 20 Mar 2017 11:08:43 +0100
Message-ID: <1490004530-9128-16-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Karel Rericha reported that in his test case, ICMP packets going through
boxes had normally about 5ms latency. But when running nft, actually
listing the sets with interval flags, latency would go up to 30-100ms.
This was observed when router throughput is from 600Mbps to 2Gbps.

This is because we use a single global spinlock to protect the whole
rbtree sets, so "dumping sets" will race with the "key lookup" inevitably.
But actually they are all _readers_, so it's ok to convert the spinlock
to rwlock to avoid competition between them. Also use per-set rwlock since
each set is independent.

Reported-by: Karel Rericha <karel@unitednetworks.cz>
Tested-by: Karel Rericha <karel@unitednetworks.cz>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_rbtree.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index 78dfbf9588b3..e97e2fb53f0a 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -18,9 +18,8 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 
-static DEFINE_SPINLOCK(nft_rbtree_lock);
-
 struct nft_rbtree {
+	rwlock_t		lock;
 	struct rb_root		root;
 };
 
@@ -44,14 +43,14 @@ static bool nft_rbtree_equal(const struct nft_set *set, const void *this,
 static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 			      const u32 *key, const struct nft_set_ext **ext)
 {
-	const struct nft_rbtree *priv = nft_set_priv(set);
+	struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
 	u8 genmask = nft_genmask_cur(net);
 	const struct rb_node *parent;
 	const void *this;
 	int d;
 
-	spin_lock_bh(&nft_rbtree_lock);
+	read_lock_bh(&priv->lock);
 	parent = priv->root.rb_node;
 	while (parent != NULL) {
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
@@ -75,7 +74,7 @@ static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 			}
 			if (nft_rbtree_interval_end(rbe))
 				goto out;
-			spin_unlock_bh(&nft_rbtree_lock);
+			read_unlock_bh(&priv->lock);
 
 			*ext = &rbe->ext;
 			return true;
@@ -85,12 +84,12 @@ static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 	if (set->flags & NFT_SET_INTERVAL && interval != NULL &&
 	    nft_set_elem_active(&interval->ext, genmask) &&
 	    !nft_rbtree_interval_end(interval)) {
-		spin_unlock_bh(&nft_rbtree_lock);
+		read_unlock_bh(&priv->lock);
 		*ext = &interval->ext;
 		return true;
 	}
 out:
-	spin_unlock_bh(&nft_rbtree_lock);
+	read_unlock_bh(&priv->lock);
 	return false;
 }
 
@@ -140,12 +139,13 @@ static int nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 			     const struct nft_set_elem *elem,
 			     struct nft_set_ext **ext)
 {
+	struct nft_rbtree *priv = nft_set_priv(set);
 	struct nft_rbtree_elem *rbe = elem->priv;
 	int err;
 
-	spin_lock_bh(&nft_rbtree_lock);
+	write_lock_bh(&priv->lock);
 	err = __nft_rbtree_insert(net, set, rbe, ext);
-	spin_unlock_bh(&nft_rbtree_lock);
+	write_unlock_bh(&priv->lock);
 
 	return err;
 }
@@ -157,9 +157,9 @@ static void nft_rbtree_remove(const struct net *net,
 	struct nft_rbtree *priv = nft_set_priv(set);
 	struct nft_rbtree_elem *rbe = elem->priv;
 
-	spin_lock_bh(&nft_rbtree_lock);
+	write_lock_bh(&priv->lock);
 	rb_erase(&rbe->node, &priv->root);
-	spin_unlock_bh(&nft_rbtree_lock);
+	write_unlock_bh(&priv->lock);
 }
 
 static void nft_rbtree_activate(const struct net *net,
@@ -224,12 +224,12 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 			    struct nft_set *set,
 			    struct nft_set_iter *iter)
 {
-	const struct nft_rbtree *priv = nft_set_priv(set);
+	struct nft_rbtree *priv = nft_set_priv(set);
 	struct nft_rbtree_elem *rbe;
 	struct nft_set_elem elem;
 	struct rb_node *node;
 
-	spin_lock_bh(&nft_rbtree_lock);
+	read_lock_bh(&priv->lock);
 	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
 
@@ -242,13 +242,13 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 
 		iter->err = iter->fn(ctx, set, iter, &elem);
 		if (iter->err < 0) {
-			spin_unlock_bh(&nft_rbtree_lock);
+			read_unlock_bh(&priv->lock);
 			return;
 		}
 cont:
 		iter->count++;
 	}
-	spin_unlock_bh(&nft_rbtree_lock);
+	read_unlock_bh(&priv->lock);
 }
 
 static unsigned int nft_rbtree_privsize(const struct nlattr * const nla[])
@@ -262,6 +262,7 @@ static int nft_rbtree_init(const struct nft_set *set,
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
 
+	rwlock_init(&priv->lock);
 	priv->root = RB_ROOT;
 	return 0;
 }
-- 
2.1.4

