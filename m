From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: nf_tables: validate hooks in NAT expressions
Date: Sat, 31 Jan 2015 21:55:08 +0100
Message-ID: <1422737711-5169-2-git-send-email-pablo@netfilter.org>
References: <1422737711-5169-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1422737711-5169-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The user can crash the kernel if it uses any of the existing NAT
expressions from the wrong hook, so add some code to validate this
when loading the rule.

This patch introduces nft_chain_validate_hooks() which is based on
an existing function in the bridge version of the reject expression.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    2 ++
 net/bridge/netfilter/nft_reject_bridge.c |   29 +++++-----------------
 net/netfilter/nf_tables_api.c            |   18 ++++++++++++++
 net/netfilter/nft_masq.c                 |   26 ++++++++++++-------
 net/netfilter/nft_nat.c                  |   40 ++++++++++++++++++++++--------
 net/netfilter/nft_redir.c                |   25 +++++++++++++------
 6 files changed, 90 insertions(+), 50 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 3ae969e..9eaaa78 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -530,6 +530,8 @@ enum nft_chain_type {
 
 int nft_chain_validate_dependency(const struct nft_chain *chain,
 				  enum nft_chain_type type);
+int nft_chain_validate_hooks(const struct nft_chain *chain,
+                             unsigned int hook_flags);
 
 struct nft_stats {
 	u64			bytes;
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index b0330ae..3244aea 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -265,22 +265,12 @@ out:
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
 
-static int nft_reject_bridge_validate_hooks(const struct nft_chain *chain)
+static int nft_reject_bridge_validate(const struct nft_ctx *ctx,
+				      const struct nft_expr *expr,
+				      const struct nft_data **data)
 {
-	struct nft_base_chain *basechain;
-
-	if (chain->flags & NFT_BASE_CHAIN) {
-		basechain = nft_base_chain(chain);
-
-		switch (basechain->ops[0].hooknum) {
-		case NF_BR_PRE_ROUTING:
-		case NF_BR_LOCAL_IN:
-			break;
-		default:
-			return -EOPNOTSUPP;
-		}
-	}
-	return 0;
+	return nft_chain_validate_hooks(ctx->chain, (1 << NF_BR_PRE_ROUTING) |
+						    (1 << NF_BR_LOCAL_IN));
 }
 
 static int nft_reject_bridge_init(const struct nft_ctx *ctx,
@@ -290,7 +280,7 @@ static int nft_reject_bridge_init(const struct nft_ctx *ctx,
 	struct nft_reject *priv = nft_expr_priv(expr);
 	int icmp_code, err;
 
-	err = nft_reject_bridge_validate_hooks(ctx->chain);
+	err = nft_reject_bridge_validate(ctx, expr, NULL);
 	if (err < 0)
 		return err;
 
@@ -341,13 +331,6 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_reject_bridge_validate(const struct nft_ctx *ctx,
-				      const struct nft_expr *expr,
-				      const struct nft_data **data)
-{
-	return nft_reject_bridge_validate_hooks(ctx->chain);
-}
-
 static struct nft_expr_type nft_reject_bridge_type;
 static const struct nft_expr_ops nft_reject_bridge_ops = {
 	.type		= &nft_reject_bridge_type,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3b3ddb4..7e68694 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3753,6 +3753,24 @@ int nft_chain_validate_dependency(const struct nft_chain *chain,
 }
 EXPORT_SYMBOL_GPL(nft_chain_validate_dependency);
 
+int nft_chain_validate_hooks(const struct nft_chain *chain,
+			     unsigned int hook_flags)
+{
+	struct nft_base_chain *basechain;
+
+	if (chain->flags & NFT_BASE_CHAIN) {
+		basechain = nft_base_chain(chain);
+
+		if ((1 << basechain->ops[0].hooknum) & hook_flags)
+			return 0;
+
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_chain_validate_hooks);
+
 /*
  * Loop detection - walk through the ruleset beginning at the destination chain
  * of a new jump until either the source chain is reached (loop) or all
diff --git a/net/netfilter/nft_masq.c b/net/netfilter/nft_masq.c
index d1ffd5e..9aea747 100644
--- a/net/netfilter/nft_masq.c
+++ b/net/netfilter/nft_masq.c
@@ -21,6 +21,21 @@ const struct nla_policy nft_masq_policy[NFTA_MASQ_MAX + 1] = {
 };
 EXPORT_SYMBOL_GPL(nft_masq_policy);
 
+int nft_masq_validate(const struct nft_ctx *ctx,
+		      const struct nft_expr *expr,
+		      const struct nft_data **data)
+{
+	int err;
+
+	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+	if (err < 0)
+		return err;
+
+	return nft_chain_validate_hooks(ctx->chain,
+				        (1 << NF_INET_POST_ROUTING));
+}
+EXPORT_SYMBOL_GPL(nft_masq_validate);
+
 int nft_masq_init(const struct nft_ctx *ctx,
 		  const struct nft_expr *expr,
 		  const struct nlattr * const tb[])
@@ -28,8 +43,8 @@ int nft_masq_init(const struct nft_ctx *ctx,
 	struct nft_masq *priv = nft_expr_priv(expr);
 	int err;
 
-	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
-	if (err < 0)
+	err = nft_masq_validate(ctx, expr, NULL);
+	if (err)
 		return err;
 
 	if (tb[NFTA_MASQ_FLAGS] == NULL)
@@ -60,12 +75,5 @@ nla_put_failure:
 }
 EXPORT_SYMBOL_GPL(nft_masq_dump);
 
-int nft_masq_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
-		      const struct nft_data **data)
-{
-	return nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
-}
-EXPORT_SYMBOL_GPL(nft_masq_validate);
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index aff54fb1..a0837c6 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -88,17 +88,40 @@ static const struct nla_policy nft_nat_policy[NFTA_NAT_MAX + 1] = {
 	[NFTA_NAT_FLAGS]	 = { .type = NLA_U32 },
 };
 
-static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
-			const struct nlattr * const tb[])
+static int nft_nat_validate(const struct nft_ctx *ctx,
+			    const struct nft_expr *expr,
+			    const struct nft_data **data)
 {
 	struct nft_nat *priv = nft_expr_priv(expr);
-	u32 family;
 	int err;
 
 	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
 	if (err < 0)
 		return err;
 
+	switch (priv->type) {
+	case NFT_NAT_SNAT:
+		err = nft_chain_validate_hooks(ctx->chain,
+					       (1 << NF_INET_POST_ROUTING) |
+					       (1 << NF_INET_LOCAL_IN));
+		break;
+	case NFT_NAT_DNAT:
+		err = nft_chain_validate_hooks(ctx->chain,
+					       (1 << NF_INET_PRE_ROUTING) |
+					       (1 << NF_INET_LOCAL_OUT));
+		break;
+	}
+
+	return err;
+}
+
+static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+			const struct nlattr * const tb[])
+{
+	struct nft_nat *priv = nft_expr_priv(expr);
+	u32 family;
+	int err;
+
 	if (tb[NFTA_NAT_TYPE] == NULL ||
 	    (tb[NFTA_NAT_REG_ADDR_MIN] == NULL &&
 	     tb[NFTA_NAT_REG_PROTO_MIN] == NULL))
@@ -115,6 +138,10 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 		return -EINVAL;
 	}
 
+	err = nft_nat_validate(ctx, expr, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[NFTA_NAT_FAMILY] == NULL)
 		return -EINVAL;
 
@@ -219,13 +246,6 @@ nla_put_failure:
 	return -1;
 }
 
-static int nft_nat_validate(const struct nft_ctx *ctx,
-			    const struct nft_expr *expr,
-			    const struct nft_data **data)
-{
-	return nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
-}
-
 static struct nft_expr_type nft_nat_type;
 static const struct nft_expr_ops nft_nat_ops = {
 	.type           = &nft_nat_type,
diff --git a/net/netfilter/nft_redir.c b/net/netfilter/nft_redir.c
index 9e8093f..d7e9e93 100644
--- a/net/netfilter/nft_redir.c
+++ b/net/netfilter/nft_redir.c
@@ -23,6 +23,22 @@ const struct nla_policy nft_redir_policy[NFTA_REDIR_MAX + 1] = {
 };
 EXPORT_SYMBOL_GPL(nft_redir_policy);
 
+int nft_redir_validate(const struct nft_ctx *ctx,
+		       const struct nft_expr *expr,
+		       const struct nft_data **data)
+{
+	int err;
+
+	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+	if (err < 0)
+		return err;
+
+	return nft_chain_validate_hooks(ctx->chain,
+					(1 << NF_INET_PRE_ROUTING) |
+					(1 << NF_INET_LOCAL_OUT));
+}
+EXPORT_SYMBOL_GPL(nft_redir_validate);
+
 int nft_redir_init(const struct nft_ctx *ctx,
 		   const struct nft_expr *expr,
 		   const struct nlattr * const tb[])
@@ -30,7 +46,7 @@ int nft_redir_init(const struct nft_ctx *ctx,
 	struct nft_redir *priv = nft_expr_priv(expr);
 	int err;
 
-	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+	err = nft_redir_validate(ctx, expr, NULL);
 	if (err < 0)
 		return err;
 
@@ -88,12 +104,5 @@ nla_put_failure:
 }
 EXPORT_SYMBOL_GPL(nft_redir_dump);
 
-int nft_redir_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
-		       const struct nft_data **data)
-{
-	return nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
-}
-EXPORT_SYMBOL_GPL(nft_redir_validate);
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
-- 
1.7.10.4

