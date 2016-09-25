From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/53] netfilter: nft_dynset: allow to invert match criteria
Date: Mon, 26 Sep 2016 01:06:24 +0200
Message-ID: <1474844823-2026-15-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dynset expression matches if we can fit a new entry into the set.
If there is no room for it, then it breaks the rule evaluation.

This patch introduces the inversion flag so you can add rules to
explicitly drop packets that don't fit into the set. For example:

 # nft filter input flow table xyz size 4 { ip saddr timeout 120s counter } overflow drop

This is useful to provide a replacement for connlimit.

For the rule above, every new entry uses the IPv4 address as key in the
set, this entry gets a timeout of 120 seconds that gets refresh on every
packet seen. If we get new flow and our set already contains 4 entries
already, then this packet is dropped.

You can already express this in positive logic, assuming default policy
to drop:

 # nft filter input flow table xyz size 4 { ip saddr timeout 10s counter } accept

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  6 ++++++
 net/netfilter/nft_dynset.c               | 20 +++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 8c653bbd1ead..bc0eb6a1066d 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -575,6 +575,10 @@ enum nft_dynset_ops {
 	NFT_DYNSET_OP_UPDATE,
 };
 
+enum nft_dynset_flags {
+	NFT_DYNSET_F_INV	= (1 << 0),
+};
+
 /**
  * enum nft_dynset_attributes - dynset expression attributes
  *
@@ -585,6 +589,7 @@ enum nft_dynset_ops {
  * @NFTA_DYNSET_SREG_DATA: source register of the data (NLA_U32)
  * @NFTA_DYNSET_TIMEOUT: timeout value for the new element (NLA_U64)
  * @NFTA_DYNSET_EXPR: expression (NLA_NESTED: nft_expr_attributes)
+ * @NFTA_DYNSET_FLAGS: flags (NLA_U32)
  */
 enum nft_dynset_attributes {
 	NFTA_DYNSET_UNSPEC,
@@ -596,6 +601,7 @@ enum nft_dynset_attributes {
 	NFTA_DYNSET_TIMEOUT,
 	NFTA_DYNSET_EXPR,
 	NFTA_DYNSET_PAD,
+	NFTA_DYNSET_FLAGS,
 	__NFTA_DYNSET_MAX,
 };
 #define NFTA_DYNSET_MAX		(__NFTA_DYNSET_MAX - 1)
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 0af26699bf04..e3b83c31da2e 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -22,6 +22,7 @@ struct nft_dynset {
 	enum nft_dynset_ops		op:8;
 	enum nft_registers		sreg_key:8;
 	enum nft_registers		sreg_data:8;
+	bool				invert;
 	u64				timeout;
 	struct nft_expr			*expr;
 	struct nft_set_binding		binding;
@@ -82,10 +83,14 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 
 		if (sexpr != NULL)
 			sexpr->ops->eval(sexpr, regs, pkt);
+
+		if (priv->invert)
+			regs->verdict.code = NFT_BREAK;
 		return;
 	}
 out:
-	regs->verdict.code = NFT_BREAK;
+	if (!priv->invert)
+		regs->verdict.code = NFT_BREAK;
 }
 
 static const struct nla_policy nft_dynset_policy[NFTA_DYNSET_MAX + 1] = {
@@ -96,6 +101,7 @@ static const struct nla_policy nft_dynset_policy[NFTA_DYNSET_MAX + 1] = {
 	[NFTA_DYNSET_SREG_DATA]	= { .type = NLA_U32 },
 	[NFTA_DYNSET_TIMEOUT]	= { .type = NLA_U64 },
 	[NFTA_DYNSET_EXPR]	= { .type = NLA_NESTED },
+	[NFTA_DYNSET_FLAGS]	= { .type = NLA_U32 },
 };
 
 static int nft_dynset_init(const struct nft_ctx *ctx,
@@ -113,6 +119,15 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	    tb[NFTA_DYNSET_SREG_KEY] == NULL)
 		return -EINVAL;
 
+	if (tb[NFTA_DYNSET_FLAGS]) {
+		u32 flags = ntohl(nla_get_be32(tb[NFTA_DYNSET_FLAGS]));
+
+		if (flags & ~NFT_DYNSET_F_INV)
+			return -EINVAL;
+		if (flags & NFT_DYNSET_F_INV)
+			priv->invert = true;
+	}
+
 	set = nf_tables_set_lookup(ctx->table, tb[NFTA_DYNSET_SET_NAME],
 				   genmask);
 	if (IS_ERR(set)) {
@@ -220,6 +235,7 @@ static void nft_dynset_destroy(const struct nft_ctx *ctx,
 static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_dynset *priv = nft_expr_priv(expr);
+	u32 flags = priv->invert ? NFT_DYNSET_F_INV : 0;
 
 	if (nft_dump_register(skb, NFTA_DYNSET_SREG_KEY, priv->sreg_key))
 		goto nla_put_failure;
@@ -235,6 +251,8 @@ static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (priv->expr && nft_expr_dump(skb, NFTA_DYNSET_EXPR, priv->expr))
 		goto nla_put_failure;
+	if (nla_put_be32(skb, NFTA_DYNSET_FLAGS, htonl(flags)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
2.1.4

