From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: nf_tables: reject loops from set element jump to chain
Date: Fri, 17 Jun 2016 20:25:15 +0200
Message-ID: <1466187919-12800-4-git-send-email-pablo@netfilter.org>
References: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Liping Zhang says:

"Users may add such a wrong nft rules successfully, which will cause an
endless jump loop:

  # nft add rule filter test tcp dport vmap {1: jump test}

This is because before we commit, the element in the current anonymous
set is inactive, so osp->walk will skip this element and miss the
validate check."

To resolve this problem, this patch passes the generation mask to the
walk function through the iter container structure depending on the code
path:

1) If we're dumping the elements, then we have to check if the element
   is active in the current generation. Thus, we check for the current
   bit in the genmask.

2) If we're checking for loops, then we have to check if the element is
   active in the next generation, as we're in the middle of a
   transaction. Thus, we check for the next bit in the genmask.

Based on original patch from Liping Zhang.

Reported-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Liping Zhang <liping.zhang@spreadtrum.com>
---
 include/net/netfilter/nf_tables.h |  1 +
 net/netfilter/nf_tables_api.c     | 15 +++++++++------
 net/netfilter/nft_hash.c          |  3 +--
 net/netfilter/nft_rbtree.c        |  3 +--
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 0922354..f7c291f 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -167,6 +167,7 @@ struct nft_set_elem {
 
 struct nft_set;
 struct nft_set_iter {
+	u8		genmask;
 	unsigned int	count;
 	unsigned int	skip;
 	int		err;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 492f6f8..0fd6998 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2951,6 +2951,7 @@ int nf_tables_bind_set(const struct nft_ctx *ctx, struct nft_set *set,
 				goto bind;
 		}
 
+		iter.genmask	= nft_genmask_next(ctx->net);
 		iter.skip 	= 0;
 		iter.count	= 0;
 		iter.err	= 0;
@@ -3192,12 +3193,13 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	args.cb		= cb;
-	args.skb	= skb;
-	args.iter.skip	= cb->args[0];
-	args.iter.count	= 0;
-	args.iter.err   = 0;
-	args.iter.fn	= nf_tables_dump_setelem;
+	args.cb			= cb;
+	args.skb		= skb;
+	args.iter.genmask	= nft_genmask_cur(ctx.net);
+	args.iter.skip		= cb->args[0];
+	args.iter.count		= 0;
+	args.iter.err		= 0;
+	args.iter.fn		= nf_tables_dump_setelem;
 	set->ops->walk(&ctx, set, &args.iter);
 
 	nla_nest_end(skb, nest);
@@ -4284,6 +4286,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 			    binding->chain != chain)
 				continue;
 
+			iter.genmask	= nft_genmask_next(ctx->net);
 			iter.skip 	= 0;
 			iter.count	= 0;
 			iter.err	= 0;
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 6fa0165..f39c53a 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -189,7 +189,6 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 	struct nft_hash_elem *he;
 	struct rhashtable_iter hti;
 	struct nft_set_elem elem;
-	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 	int err;
 
 	err = rhashtable_walk_init(&priv->ht, &hti, GFP_KERNEL);
@@ -218,7 +217,7 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 			goto cont;
 		if (nft_set_elem_expired(&he->ext))
 			goto cont;
-		if (!nft_set_elem_active(&he->ext, genmask))
+		if (!nft_set_elem_active(&he->ext, iter->genmask))
 			goto cont;
 
 		elem.priv = he;
diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index f762094..7201d57 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -211,7 +211,6 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 	struct nft_rbtree_elem *rbe;
 	struct nft_set_elem elem;
 	struct rb_node *node;
-	u8 genmask = nft_genmask_cur(read_pnet(&set->pnet));
 
 	spin_lock_bh(&nft_rbtree_lock);
 	for (node = rb_first(&priv->root); node != NULL; node = rb_next(node)) {
@@ -219,7 +218,7 @@ static void nft_rbtree_walk(const struct nft_ctx *ctx,
 
 		if (iter->count < iter->skip)
 			goto cont;
-		if (!nft_set_elem_active(&rbe->ext, genmask))
+		if (!nft_set_elem_active(&rbe->ext, iter->genmask))
 			goto cont;
 
 		elem.priv = rbe;
-- 
2.1.4

