From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/25] netfilter: nft_meta: split nft_meta_init() into two functions for get/set
Date: Wed, 21 May 2014 11:43:00 +0200
Message-ID: <1400665402-5835-3-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55923 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbaEUJng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 05:43:36 -0400
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

For value spanning multiple registers, we need to validate the length
of data loads. In order to add this to nft_meta, we need the length from
key validation. Split the nft_meta_init() function into two functions
for the get and set operations as preparation for that.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Pablo Neira Ayuso <pablo@gnumonks.org>
---
 net/netfilter/nft_meta.c |   65 +++++++++++++++++++++-------------------------
 1 file changed, 30 insertions(+), 35 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 425cf39..6d0b8cc2 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -170,21 +170,15 @@ static const struct nla_policy nft_meta_policy[NFTA_META_MAX + 1] = {
 	[NFTA_META_SREG]	= { .type = NLA_U32 },
 };
 
-static int nft_meta_init_validate_set(uint32_t key)
+static int nft_meta_get_init(const struct nft_ctx *ctx,
+			     const struct nft_expr *expr,
+			     const struct nlattr * const tb[])
 {
-	switch (key) {
-	case NFT_META_MARK:
-	case NFT_META_PRIORITY:
-	case NFT_META_NFTRACE:
-		return 0;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
+	struct nft_meta *priv = nft_expr_priv(expr);
+	int err;
 
-static int nft_meta_init_validate_get(uint32_t key)
-{
-	switch (key) {
+	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
+	switch (priv->key) {
 	case NFT_META_LEN:
 	case NFT_META_PROTOCOL:
 	case NFT_META_NFPROTO:
@@ -205,39 +199,40 @@ static int nft_meta_init_validate_get(uint32_t key)
 #ifdef CONFIG_NETWORK_SECMARK
 	case NFT_META_SECMARK:
 #endif
-		return 0;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
 
+	priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
+	err = nft_validate_output_register(priv->dreg);
+	if (err < 0)
+		return err;
+
+	err = nft_validate_data_load(ctx, priv->dreg, NULL, NFT_DATA_VALUE);
+	if (err < 0)
+		return err;
+
+	return 0;
 }
 
-static int nft_meta_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
-			 const struct nlattr * const tb[])
+static int nft_meta_set_init(const struct nft_ctx *ctx,
+			     const struct nft_expr *expr,
+			     const struct nlattr * const tb[])
 {
 	struct nft_meta *priv = nft_expr_priv(expr);
 	int err;
 
 	priv->key = ntohl(nla_get_be32(tb[NFTA_META_KEY]));
-
-	if (tb[NFTA_META_DREG]) {
-		err = nft_meta_init_validate_get(priv->key);
-		if (err < 0)
-			return err;
-
-		priv->dreg = ntohl(nla_get_be32(tb[NFTA_META_DREG]));
-		err = nft_validate_output_register(priv->dreg);
-		if (err < 0)
-			return err;
-
-		return nft_validate_data_load(ctx, priv->dreg, NULL,
-					      NFT_DATA_VALUE);
+	switch (priv->key) {
+	case NFT_META_MARK:
+	case NFT_META_PRIORITY:
+	case NFT_META_NFTRACE:
+		break;
+	default:
+		return -EOPNOTSUPP;
 	}
 
-	err = nft_meta_init_validate_set(priv->key);
-	if (err < 0)
-		return err;
-
 	priv->sreg = ntohl(nla_get_be32(tb[NFTA_META_SREG]));
 	err = nft_validate_input_register(priv->sreg);
 	if (err < 0)
@@ -282,7 +277,7 @@ static const struct nft_expr_ops nft_meta_get_ops = {
 	.type		= &nft_meta_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
 	.eval		= nft_meta_get_eval,
-	.init		= nft_meta_init,
+	.init		= nft_meta_get_init,
 	.dump		= nft_meta_get_dump,
 };
 
@@ -290,7 +285,7 @@ static const struct nft_expr_ops nft_meta_set_ops = {
 	.type		= &nft_meta_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_meta)),
 	.eval		= nft_meta_set_eval,
-	.init		= nft_meta_init,
+	.init		= nft_meta_set_init,
 	.dump		= nft_meta_set_dump,
 };
 
-- 
1.7.10.4
