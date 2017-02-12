From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/21] netfilter: nf_tables: pass netns to set->ops->remove()
Date: Sun, 12 Feb 2017 20:42:34 +0100
Message-ID: <1486928573-24773-3-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This new parameter is required by the new bitmap set type that comes in a
follow up patch.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 3 ++-
 net/netfilter/nf_tables_api.c     | 6 +++---
 net/netfilter/nft_set_hash.c      | 3 ++-
 net/netfilter/nft_set_rbtree.c    | 3 ++-
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 7dfdb517f0be..a721bcb1210c 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -298,7 +298,8 @@ struct nft_set_ops {
 	bool				(*deactivate_one)(const struct net *net,
 							  const struct nft_set *set,
 							  void *priv);
-	void				(*remove)(const struct nft_set *set,
+	void				(*remove)(const struct net *net,
+						  const struct nft_set *set,
 						  const struct nft_set_elem *elem);
 	void				(*walk)(const struct nft_ctx *ctx,
 						struct nft_set *set,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 57eeae63f597..3643ce345b59 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3752,7 +3752,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	return 0;
 
 err6:
-	set->ops->remove(set, &elem);
+	set->ops->remove(ctx->net, set, &elem);
 err5:
 	kfree(trans);
 err4:
@@ -4804,7 +4804,7 @@ static int nf_tables_commit(struct net *net, struct sk_buff *skb)
 			nf_tables_setelem_notify(&trans->ctx, te->set,
 						 &te->elem,
 						 NFT_MSG_DELSETELEM, 0);
-			te->set->ops->remove(te->set, &te->elem);
+			te->set->ops->remove(net, te->set, &te->elem);
 			atomic_dec(&te->set->nelems);
 			te->set->ndeact--;
 			break;
@@ -4925,7 +4925,7 @@ static int nf_tables_abort(struct net *net, struct sk_buff *skb)
 		case NFT_MSG_NEWSETELEM:
 			te = (struct nft_trans_elem *)trans->data;
 
-			te->set->ops->remove(te->set, &te->elem);
+			te->set->ops->remove(net, te->set, &te->elem);
 			atomic_dec(&te->set->nelems);
 			break;
 		case NFT_MSG_DELSETELEM:
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index e36069fb76ae..bb157bd47fe8 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -203,7 +203,8 @@ static void *nft_hash_deactivate(const struct net *net,
 	return he;
 }
 
-static void nft_hash_remove(const struct nft_set *set,
+static void nft_hash_remove(const struct net *net,
+			    const struct nft_set *set,
 			    const struct nft_set_elem *elem)
 {
 	struct nft_hash *priv = nft_set_priv(set);
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index f06f55ee516d..9fbd70da1633 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -151,7 +151,8 @@ static int nft_rbtree_insert(const struct net *net, const struct nft_set *set,
 	return err;
 }
 
-static void nft_rbtree_remove(const struct nft_set *set,
+static void nft_rbtree_remove(const struct net *net,
+			      const struct nft_set *set,
 			      const struct nft_set_elem *elem)
 {
 	struct nft_rbtree *priv = nft_set_priv(set);
-- 
2.1.4

