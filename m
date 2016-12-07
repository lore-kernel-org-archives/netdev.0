From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 47/50] netfilter: nf_tables: support for set flushing
Date: Wed,  7 Dec 2016 22:52:53 +0100
Message-ID: <1481147576-5690-48-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for set flushing, that consists of walking over
the set elements if the NFTA_SET_ELEM_LIST_ELEMENTS attribute is set.
This patch requires the following changes:

1) Add set->ops->deactivate_one() operation: This allows us to
   deactivate an element from the set element walk path, given we can
   skip the lookup that happens in ->deactivate().

2) Add a new nft_trans_alloc_gfp() function since we need to allocate
   transactions using GFP_ATOMIC given the set walk path happens with
   held rcu_read_lock.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  6 ++++-
 net/netfilter/nf_tables_api.c     | 55 ++++++++++++++++++++++++++++++++++-----
 net/netfilter/nft_set_hash.c      |  1 +
 net/netfilter/nft_set_rbtree.c    |  1 +
 4 files changed, 56 insertions(+), 7 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 85f0f03f1e87..924325c46aab 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -259,7 +259,8 @@ struct nft_expr;
  *	@lookup: look up an element within the set
  *	@insert: insert new element into set
  *	@activate: activate new element in the next generation
- *	@deactivate: deactivate element in the next generation
+ *	@deactivate: lookup for element and deactivate it in the next generation
+ *	@deactivate_one: deactivate element in the next generation
  *	@remove: remove element from set
  *	@walk: iterate over all set elemeennts
  *	@privsize: function to return size of set private data
@@ -294,6 +295,9 @@ struct nft_set_ops {
 	void *				(*deactivate)(const struct net *net,
 						      const struct nft_set *set,
 						      const struct nft_set_elem *elem);
+	bool				(*deactivate_one)(const struct net *net,
+							  const struct nft_set *set,
+							  void *priv);
 	void				(*remove)(const struct nft_set *set,
 						  const struct nft_set_elem *elem);
 	void				(*walk)(const struct nft_ctx *ctx,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b42059795819..a019a87e58ee 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -111,12 +111,12 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 	ctx->seq	= nlh->nlmsg_seq;
 }
 
-static struct nft_trans *nft_trans_alloc(const struct nft_ctx *ctx,
-					 int msg_type, u32 size)
+static struct nft_trans *nft_trans_alloc_gfp(const struct nft_ctx *ctx,
+					     int msg_type, u32 size, gfp_t gfp)
 {
 	struct nft_trans *trans;
 
-	trans = kzalloc(sizeof(struct nft_trans) + size, GFP_KERNEL);
+	trans = kzalloc(sizeof(struct nft_trans) + size, gfp);
 	if (trans == NULL)
 		return NULL;
 
@@ -126,6 +126,12 @@ static struct nft_trans *nft_trans_alloc(const struct nft_ctx *ctx,
 	return trans;
 }
 
+static struct nft_trans *nft_trans_alloc(const struct nft_ctx *ctx,
+					 int msg_type, u32 size)
+{
+	return nft_trans_alloc_gfp(ctx, msg_type, size, GFP_KERNEL);
+}
+
 static void nft_trans_destroy(struct nft_trans *trans)
 {
 	list_del(&trans->list);
@@ -3876,6 +3882,34 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	return err;
 }
 
+static int nft_flush_set(const struct nft_ctx *ctx,
+			 const struct nft_set *set,
+			 const struct nft_set_iter *iter,
+			 const struct nft_set_elem *elem)
+{
+	struct nft_trans *trans;
+	int err;
+
+	trans = nft_trans_alloc_gfp(ctx, NFT_MSG_DELSETELEM,
+				    sizeof(struct nft_trans_elem), GFP_ATOMIC);
+	if (!trans)
+		return -ENOMEM;
+
+	if (!set->ops->deactivate_one(ctx->net, set, elem->priv)) {
+		err = -ENOENT;
+		goto err1;
+	}
+
+	nft_trans_elem_set(trans) = (struct nft_set *)set;
+	nft_trans_elem(trans) = *((struct nft_set_elem *)elem);
+	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
+
+	return 0;
+err1:
+	kfree(trans);
+	return err;
+}
+
 static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
 				const struct nlattr * const nla[])
@@ -3886,9 +3920,6 @@ static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 	struct nft_ctx ctx;
 	int rem, err = 0;
 
-	if (nla[NFTA_SET_ELEM_LIST_ELEMENTS] == NULL)
-		return -EINVAL;
-
 	err = nft_ctx_init_from_elemattr(&ctx, net, skb, nlh, nla, genmask);
 	if (err < 0)
 		return err;
@@ -3900,6 +3931,18 @@ static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 	if (!list_empty(&set->bindings) && set->flags & NFT_SET_CONSTANT)
 		return -EBUSY;
 
+	if (nla[NFTA_SET_ELEM_LIST_ELEMENTS] == NULL) {
+		struct nft_set_dump_args args = {
+			.iter	= {
+				.genmask	= genmask,
+				.fn		= nft_flush_set,
+			},
+		};
+		set->ops->walk(&ctx, set, &args.iter);
+
+		return args.iter.err;
+	}
+
 	nla_for_each_nested(attr, nla[NFTA_SET_ELEM_LIST_ELEMENTS], rem) {
 		err = nft_del_setelem(&ctx, set, attr);
 		if (err < 0)
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 73f7687c5656..1e20e2bbb6d9 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -397,6 +397,7 @@ static struct nft_set_ops nft_hash_ops __read_mostly = {
 	.insert		= nft_hash_insert,
 	.activate	= nft_hash_activate,
 	.deactivate	= nft_hash_deactivate,
+	.deactivate_one	= nft_hash_deactivate_one,
 	.remove		= nft_hash_remove,
 	.lookup		= nft_hash_lookup,
 	.update		= nft_hash_update,
diff --git a/net/netfilter/nft_set_rbtree.c b/net/netfilter/nft_set_rbtree.c
index 5580bb64dc0f..08376e50f6cd 100644
--- a/net/netfilter/nft_set_rbtree.c
+++ b/net/netfilter/nft_set_rbtree.c
@@ -304,6 +304,7 @@ static struct nft_set_ops nft_rbtree_ops __read_mostly = {
 	.insert		= nft_rbtree_insert,
 	.remove		= nft_rbtree_remove,
 	.deactivate	= nft_rbtree_deactivate,
+	.deactivate_one	= nft_rbtree_deactivate_one,
 	.activate	= nft_rbtree_activate,
 	.lookup		= nft_rbtree_lookup,
 	.walk		= nft_rbtree_walk,
-- 
2.1.4

