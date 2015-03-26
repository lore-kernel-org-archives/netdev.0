From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/15] netfilter: nf_tables: consolide set element destruction
Date: Thu, 26 Mar 2015 13:06:59 +0100
Message-ID: <1427371622-4466-13-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

With the conversion to set extensions, it is now possible to consolidate
the different set element destruction functions.

The set implementations' ->remove() functions are changed to only take
the element out of their internal data structures. Elements will be freed
in a batched fashion after the global transaction's completion RCU grace
period.

This reduces the amount of grace periods required for nft_hash from N
to zero additional ones, additionally this guarantees that the set
elements' extensions of all implementations can be used under RCU
protection.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c     |   34 ++++++++++++++++++++--------------
 net/netfilter/nft_hash.c          |   18 ++++--------------
 net/netfilter/nft_rbtree.c        |   14 +-------------
 4 files changed, 27 insertions(+), 41 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index ef3457c..6ac6332 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -423,6 +423,8 @@ static inline struct nft_set_ext *nft_set_elem_ext(const struct nft_set *set,
 	return elem + set->ops->elemsize;
 }
 
+void nft_set_elem_destroy(const struct nft_set *set, void *elem);
+
 /**
  *	struct nft_expr_type - nf_tables expression type
  *
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 99cb884..b35512f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3155,6 +3155,18 @@ static void *nft_set_elem_init(const struct nft_set *set,
 	return elem;
 }
 
+void nft_set_elem_destroy(const struct nft_set *set, void *elem)
+{
+	struct nft_set_ext *ext = nft_set_elem_ext(set, elem);
+
+	nft_data_uninit(nft_set_ext_key(ext), NFT_DATA_VALUE);
+	if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
+		nft_data_uninit(nft_set_ext_data(ext), set->dtype);
+
+	kfree(elem);
+}
+EXPORT_SYMBOL_GPL(nft_set_elem_destroy);
+
 static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			    const struct nlattr *attr)
 {
@@ -3596,6 +3608,10 @@ static void nf_tables_commit_release(struct nft_trans *trans)
 	case NFT_MSG_DELSET:
 		nft_set_destroy(nft_trans_set(trans));
 		break;
+	case NFT_MSG_DELSETELEM:
+		nft_set_elem_destroy(nft_trans_elem_set(trans),
+				     nft_trans_elem(trans).priv);
+		break;
 	}
 	kfree(trans);
 }
@@ -3605,7 +3621,6 @@ static int nf_tables_commit(struct sk_buff *skb)
 	struct net *net = sock_net(skb->sk);
 	struct nft_trans *trans, *next;
 	struct nft_trans_elem *te;
-	struct nft_set_ext *ext;
 
 	/* Bump generation counter, invalidate any dump in progress */
 	while (++net->nft.base_seq == 0);
@@ -3690,18 +3705,12 @@ static int nf_tables_commit(struct sk_buff *skb)
 			break;
 		case NFT_MSG_DELSETELEM:
 			te = (struct nft_trans_elem *)trans->data;
-			ext = nft_set_elem_ext(te->set, te->elem.priv);
 
 			nf_tables_setelem_notify(&trans->ctx, te->set,
 						 &te->elem,
 						 NFT_MSG_DELSETELEM, 0);
 			te->set->ops->get(te->set, &te->elem);
-			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
-			if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
-				nft_data_uninit(nft_set_ext_data(ext),
-						te->set->dtype);
 			te->set->ops->remove(te->set, &te->elem);
-			nft_trans_destroy(trans);
 			break;
 		}
 	}
@@ -3733,6 +3742,10 @@ static void nf_tables_abort_release(struct nft_trans *trans)
 	case NFT_MSG_NEWSET:
 		nft_set_destroy(nft_trans_set(trans));
 		break;
+	case NFT_MSG_NEWSETELEM:
+		nft_set_elem_destroy(nft_trans_elem_set(trans),
+				     nft_trans_elem(trans).priv);
+		break;
 	}
 	kfree(trans);
 }
@@ -3742,7 +3755,6 @@ static int nf_tables_abort(struct sk_buff *skb)
 	struct net *net = sock_net(skb->sk);
 	struct nft_trans *trans, *next;
 	struct nft_trans_elem *te;
-	struct nft_set_ext *ext;
 
 	list_for_each_entry_safe(trans, next, &net->nft.commit_list, list) {
 		switch (trans->msg_type) {
@@ -3804,15 +3816,9 @@ static int nf_tables_abort(struct sk_buff *skb)
 		case NFT_MSG_NEWSETELEM:
 			nft_trans_elem_set(trans)->nelems--;
 			te = (struct nft_trans_elem *)trans->data;
-			ext = nft_set_elem_ext(te->set, te->elem.priv);
 
 			te->set->ops->get(te->set, &te->elem);
-			nft_data_uninit(&te->elem.key, NFT_DATA_VALUE);
-			if (nft_set_ext_exists(ext, NFT_SET_EXT_DATA))
-				nft_data_uninit(nft_set_ext_data(ext),
-						te->set->dtype);
 			te->set->ops->remove(te->set, &te->elem);
-			nft_trans_destroy(trans);
 			break;
 		case NFT_MSG_DELSETELEM:
 			nft_trans_elem_set(trans)->nelems++;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 15951a8..94bf25d 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -96,23 +96,12 @@ static int nft_hash_insert(const struct nft_set *set,
 					    nft_hash_params);
 }
 
-static void nft_hash_elem_destroy(const struct nft_set *set,
-				  struct nft_hash_elem *he)
-{
-	nft_data_uninit(nft_set_ext_key(&he->ext), NFT_DATA_VALUE);
-	if (set->flags & NFT_SET_MAP)
-		nft_data_uninit(nft_set_ext_data(&he->ext), set->dtype);
-	kfree(he);
-}
-
 static void nft_hash_remove(const struct nft_set *set,
 			    const struct nft_set_elem *elem)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 
 	rhashtable_remove_fast(&priv->ht, elem->cookie, nft_hash_params);
-	synchronize_rcu();
-	kfree(elem->cookie);
 }
 
 static int nft_hash_get(const struct nft_set *set, struct nft_set_elem *elem)
@@ -208,16 +197,17 @@ static int nft_hash_init(const struct nft_set *set,
 	return rhashtable_init(&priv->ht, &params);
 }
 
-static void nft_free_element(void *ptr, void *arg)
+static void nft_hash_elem_destroy(void *ptr, void *arg)
 {
-	nft_hash_elem_destroy((const struct nft_set *)arg, ptr);
+	nft_set_elem_destroy((const struct nft_set *)arg, ptr);
 }
 
 static void nft_hash_destroy(const struct nft_set *set)
 {
 	struct nft_hash *priv = nft_set_priv(set);
 
-	rhashtable_free_and_destroy(&priv->ht, nft_free_element, (void *)set);
+	rhashtable_free_and_destroy(&priv->ht, nft_hash_elem_destroy,
+				    (void *)set);
 }
 
 static bool nft_hash_estimate(const struct nft_set_desc *desc, u32 features,
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index ebf6e60..332c6af 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -72,17 +72,6 @@ out:
 	return false;
 }
 
-static void nft_rbtree_elem_destroy(const struct nft_set *set,
-				    struct nft_rbtree_elem *rbe)
-{
-	nft_data_uninit(nft_set_ext_key(&rbe->ext), NFT_DATA_VALUE);
-	if (set->flags & NFT_SET_MAP &&
-	    nft_set_ext_exists(&rbe->ext, NFT_SET_EXT_DATA))
-		nft_data_uninit(nft_set_ext_data(&rbe->ext), set->dtype);
-
-	kfree(rbe);
-}
-
 static int __nft_rbtree_insert(const struct nft_set *set,
 			       struct nft_rbtree_elem *new)
 {
@@ -133,7 +122,6 @@ static void nft_rbtree_remove(const struct nft_set *set,
 	spin_lock_bh(&nft_rbtree_lock);
 	rb_erase(&rbe->node, &priv->root);
 	spin_unlock_bh(&nft_rbtree_lock);
-	kfree(rbe);
 }
 
 static int nft_rbtree_get(const struct nft_set *set, struct nft_set_elem *elem)
@@ -213,7 +201,7 @@ static void nft_rbtree_destroy(const struct nft_set *set)
 	while ((node = priv->root.rb_node) != NULL) {
 		rb_erase(node, &priv->root);
 		rbe = rb_entry(node, struct nft_rbtree_elem, node);
-		nft_rbtree_elem_destroy(set, rbe);
+		nft_set_elem_destroy(set, rbe);
 	}
 }
 
-- 
1.7.10.4

