From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/47] netfilter: nft_set_rbtree: use seqcount to avoid lock in most cases
Date: Mon,  4 Sep 2017 00:27:19 +0200
Message-ID: <1504477667-12130-10-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

switch to lockless lockup. write side now also increments sequence
counter.  On lookup, sample counter value and only take the lock
if we did not find a match and the counter has changed.

This avoids need to write to private area in normal (lookup) cases.

In case we detect a writer (seqretry is true) we fall back to taking
the readlock.

The readlock is also used during dumps to ensure we get a consistent
tree walk.

Similar technique (rbtree+seqlock) was used by David Howells in rxrpc.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_rbtree.c | 49 +++++++++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index bce5382f1d49..d83a4ec5900d 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -19,8 +19,9 @@
 #include <net/netfilter/nf_tables.h>
 
 struct nft_rbtree {
-	rwlock_t		lock;
 	struct rb_root		root;
+	rwlock_t		lock;
+	seqcount_t		count;
 };
 
 struct nft_rbtree_elem {
@@ -40,8 +41,9 @@ static bool nft_rbtree_equal(const struct nft_set *set, const void *this,
 	return memcmp(this, nft_set_ext_key(&interval->ext), set->klen) == 0;
 }
 
-static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
-			      const u32 *key, const struct nft_set_ext **ext)
+static bool __nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
+				const u32 *key, const struct nft_set_ext **ext,
+				unsigned int seq)
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
 	const struct nft_rbtree_elem *rbe, *interval = NULL;
@@ -50,15 +52,17 @@ static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 	const void *this;
 	int d;
 
-	read_lock_bh(&priv->lock);
-	parent = priv->root.rb_node;
+	parent = rcu_dereference_raw(priv->root.rb_node);
 	while (parent != NULL) {
+		if (read_seqcount_retry(&priv->count, seq))
+			return false;
+
 		rbe = rb_entry(parent, struct nft_rbtree_elem, node);
 
 		this = nft_set_ext_key(&rbe->ext);
 		d = memcmp(this, key, set->klen);
 		if (d < 0) {
-			parent = parent->rb_left;
+			parent = rcu_dereference_raw(parent->rb_left);
 			if (interval &&
 			    nft_rbtree_equal(set, this, interval) &&
 			    nft_rbtree_interval_end(this) &&
@@ -66,15 +70,14 @@ static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 				continue;
 			interval = rbe;
 		} else if (d > 0)
-			parent = parent->rb_right;
+			parent = rcu_dereference_raw(parent->rb_right);
 		else {
 			if (!nft_set_elem_active(&rbe->ext, genmask)) {
-				parent = parent->rb_left;
+				parent = rcu_dereference_raw(parent->rb_left);
 				continue;
 			}
 			if (nft_rbtree_interval_end(rbe))
 				goto out;
-			read_unlock_bh(&priv->lock);
 
 			*ext = &rbe->ext;
 			return true;
@@ -84,15 +87,32 @@ static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
 	if (set->flags & NFT_SET_INTERVAL && interval != NULL &&
 	    nft_set_elem_active(&interval->ext, genmask) &&
 	    !nft_rbtree_interval_end(interval)) {
-		read_unlock_bh(&priv->lock);
 		*ext = &interval->ext;
 		return true;
 	}
 out:
-	read_unlock_bh(&priv->lock);
 	return false;
 }
 
+static bool nft_rbtree_lookup(const struct net *net, const struct nft_set *set,
+			      const u32 *key, const struct nft_set_ext **ext)
+{
+	struct nft_rbtree *priv = nft_set_priv(set);
+	unsigned int seq = read_seqcount_begin(&priv->count);
+	bool ret;
+
+	ret = __nft_rbtree_lookup(net, set, key, ext, seq);
+	if (ret || !read_seqcount_retry(&priv->count, seq))
+		return ret;
+
+	read_lock_bh(&priv->lock);
+	seq = read_seqcount_begin(&priv->count);
+	ret = __nft_rbtree_lookup(net, set, key, ext, seq);
+	read_unlock_bh(&priv->lock);
+
+	return ret;
+}
+
 static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 			       struct nft_rbtree_elem *new,
 			       struct nft_set_ext **ext)
@@ -130,7 +150,7 @@ static int __nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 			}
 		}
 	}
-	rb_link_node(&new->node, parent, p);
+	rb_link_node_rcu(&new->node, parent, p);
 	rb_insert_color(&new->node, &priv->root);
 	return 0;
 }
@@ -144,7 +164,9 @@ static int nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 	int err;
 
 	write_lock_bh(&priv->lock);
+	write_seqcount_begin(&priv->count);
 	err = __nft_rbtree_insert(net, set, rbe, ext);
+	write_seqcount_end(&priv->count);
 	write_unlock_bh(&priv->lock);
 
 	return err;
@@ -158,7 +180,9 @@ static void nft_rbtree_remove(const struct net *net,
 	struct nft_rbtree_elem *rbe = elem->priv;
 
 	write_lock_bh(&priv->lock);
+	write_seqcount_begin(&priv->count);
 	rb_erase(&rbe->node, &priv->root);
+	write_seqcount_end(&priv->count);
 	write_unlock_bh(&priv->lock);
 }
 
@@ -264,6 +288,7 @@ static int nft_rbtree_init(const struct nft_set *set,
 	struct nft_rbtree *priv = nft_set_priv(set);
 
 	rwlock_init(&priv->lock);
+	seqcount_init(&priv->count);
 	priv->root = RB_ROOT;
 	return 0;
 }
-- 
2.1.4


