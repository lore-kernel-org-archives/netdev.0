From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: nf_tables: restrict nat/masq expressions to nat chain type
Date: Mon, 20 Oct 2014 10:10:34 +0200
Message-ID: <1413792639-3954-3-git-send-email-pablo@netfilter.org>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the missing validation code to avoid the use of nat/masq from
non-nat chains. The validation assumes two possible configuration
scenarios:

1) Use of nat from base chain that is not of nat type. Reject this
   configuration from the nft_*_init() path of the expression.

2) Use of nat from non-base chain. In this case, we have to wait until
   the non-base chain is referenced by at least one base chain via
   jump/goto. This is resolved from the nft_*_validate() path which is
   called from nf_tables_check_loops().

The user gets an -EOPNOTSUPP in both cases.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h  |    3 +++
 include/net/netfilter/nft_masq.h   |    3 +++
 net/ipv4/netfilter/nft_masq_ipv4.c |    1 +
 net/ipv6/netfilter/nft_masq_ipv6.c |    1 +
 net/netfilter/nf_tables_api.c      |   14 ++++++++++++++
 net/netfilter/nft_masq.c           |   12 ++++++++++++
 net/netfilter/nft_nat.c            |   12 ++++++++++++
 7 files changed, 46 insertions(+)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 3d72923..845c596 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -530,6 +530,9 @@ enum nft_chain_type {
 	NFT_CHAIN_T_MAX
 };
 
+int nft_chain_validate_dependency(const struct nft_chain *chain,
+				  enum nft_chain_type type);
+
 struct nft_stats {
 	u64			bytes;
 	u64			pkts;
diff --git a/include/net/netfilter/nft_masq.h b/include/net/netfilter/nft_masq.h
index c72729f..e2a518b 100644
--- a/include/net/netfilter/nft_masq.h
+++ b/include/net/netfilter/nft_masq.h
@@ -13,4 +13,7 @@ int nft_masq_init(const struct nft_ctx *ctx,
 
 int nft_masq_dump(struct sk_buff *skb, const struct nft_expr *expr);
 
+int nft_masq_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		      const struct nft_data **data);
+
 #endif /* _NFT_MASQ_H_ */
diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 1c636d6..c1023c4 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -39,6 +39,7 @@ static const struct nft_expr_ops nft_masq_ipv4_ops = {
 	.eval		= nft_masq_ipv4_eval,
 	.init		= nft_masq_init,
 	.dump		= nft_masq_dump,
+	.validate	= nft_masq_validate,
 };
 
 static struct nft_expr_type nft_masq_ipv4_type __read_mostly = {
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index 556262f..8a7ac68 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -39,6 +39,7 @@ static const struct nft_expr_ops nft_masq_ipv6_ops = {
 	.eval		= nft_masq_ipv6_eval,
 	.init		= nft_masq_init,
 	.dump		= nft_masq_dump,
+	.validate	= nft_masq_validate,
 };
 
 static struct nft_expr_type nft_masq_ipv6_type __read_mostly = {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 556a0df..65eb2a1 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3744,6 +3744,20 @@ static const struct nfnetlink_subsystem nf_tables_subsys = {
 	.abort		= nf_tables_abort,
 };
 
+int nft_chain_validate_dependency(const struct nft_chain *chain,
+				  enum nft_chain_type type)
+{
+	const struct nft_base_chain *basechain;
+
+	if (chain->flags & NFT_BASE_CHAIN) {
+		basechain = nft_base_chain(chain);
+		if (basechain->type->type != type)
+			return -EOPNOTSUPP;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nft_chain_validate_dependency);
+
 /*
  * Loop detection - walk through the ruleset beginning at the destination chain
  * of a new jump until either the source chain is reached (loop) or all
diff --git a/net/netfilter/nft_masq.c b/net/netfilter/nft_masq.c
index 6637bab..d1ffd5e 100644
--- a/net/netfilter/nft_masq.c
+++ b/net/netfilter/nft_masq.c
@@ -26,6 +26,11 @@ int nft_masq_init(const struct nft_ctx *ctx,
 		  const struct nlattr * const tb[])
 {
 	struct nft_masq *priv = nft_expr_priv(expr);
+	int err;
+
+	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+	if (err < 0)
+		return err;
 
 	if (tb[NFTA_MASQ_FLAGS] == NULL)
 		return 0;
@@ -55,5 +60,12 @@ nla_put_failure:
 }
 EXPORT_SYMBOL_GPL(nft_masq_dump);
 
+int nft_masq_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		      const struct nft_data **data)
+{
+	return nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+}
+EXPORT_SYMBOL_GPL(nft_masq_validate);
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>");
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 799550b..0f0af6e 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -95,6 +95,10 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	u32 family;
 	int err;
 
+	err = nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+	if (err < 0)
+		return err;
+
 	if (tb[NFTA_NAT_TYPE] == NULL)
 		return -EINVAL;
 
@@ -205,6 +209,13 @@ nla_put_failure:
 	return -1;
 }
 
+static int nft_nat_validate(const struct nft_ctx *ctx,
+			    const struct nft_expr *expr,
+			    const struct nft_data **data)
+{
+	return nft_chain_validate_dependency(ctx->chain, NFT_CHAIN_T_NAT);
+}
+
 static struct nft_expr_type nft_nat_type;
 static const struct nft_expr_ops nft_nat_ops = {
 	.type           = &nft_nat_type,
@@ -212,6 +223,7 @@ static const struct nft_expr_ops nft_nat_ops = {
 	.eval           = nft_nat_eval,
 	.init           = nft_nat_init,
 	.dump           = nft_nat_dump,
+	.validate	= nft_nat_validate,
 };
 
 static struct nft_expr_type nft_nat_type __read_mostly = {
-- 
1.7.10.4

