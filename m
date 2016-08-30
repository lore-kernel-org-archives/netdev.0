From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] netfilter: nft_meta: improve the validity check of pkttype set expr
Date: Tue, 30 Aug 2016 13:26:21 +0200
Message-ID: <1472556383-6787-6-git-send-email-pablo@netfilter.org>
References: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

"meta pkttype set" is only supported on prerouting chain with bridge
family and ingress chain with netdev family.

But the validate check is incomplete, and the user can add the nft
rules on input chain with bridge family, for example:
  # nft add table bridge filter
  # nft add chain bridge filter input {type filter hook input \
    priority 0 \;}
  # nft add chain bridge filter test
  # nft add rule bridge filter test meta pkttype set unicast
  # nft add rule bridge filter input jump test

This patch fixes the problem.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_meta.h       |  4 ++++
 net/bridge/netfilter/nft_meta_bridge.c |  1 +
 net/netfilter/nft_meta.c               | 17 +++++++++++++----
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nft_meta.h b/include/net/netfilter/nft_meta.h
index d27588c..1139cde 100644
--- a/include/net/netfilter/nft_meta.h
+++ b/include/net/netfilter/nft_meta.h
@@ -36,4 +36,8 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 void nft_meta_set_destroy(const struct nft_ctx *ctx,
 			  const struct nft_expr *expr);
 
+int nft_meta_set_validate(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr,
+			  const struct nft_data **data);
+
 #endif
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 4b901d9..ad47a92 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -86,6 +86,7 @@ static const struct nft_expr_ops nft_meta_bridge_set_ops = {
 	.init		= nft_meta_set_init,
 	.destroy	= nft_meta_set_destroy,
 	.dump		= nft_meta_set_dump,
+	.validate	= nft_meta_set_validate,
 };
 
 static const struct nft_expr_ops *
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 2863f34..8a6bc76 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -291,10 +291,16 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 }
 EXPORT_SYMBOL_GPL(nft_meta_get_init);
 
-static int nft_meta_set_init_pkttype(const struct nft_ctx *ctx)
+int nft_meta_set_validate(const struct nft_ctx *ctx,
+			  const struct nft_expr *expr,
+			  const struct nft_data **data)
 {
+	struct nft_meta *priv = nft_expr_priv(expr);
 	unsigned int hooks;
 
+	if (priv->key != NFT_META_PKTTYPE)
+		return 0;
+
 	switch (ctx->afi->family) {
 	case NFPROTO_BRIDGE:
 		hooks = 1 << NF_BR_PRE_ROUTING;
@@ -308,6 +314,7 @@ static int nft_meta_set_init_pkttype(const struct nft_ctx *ctx)
 
 	return nft_chain_validate_hooks(ctx->chain, hooks);
 }
+EXPORT_SYMBOL_GPL(nft_meta_set_validate);
 
 int nft_meta_set_init(const struct nft_ctx *ctx,
 		      const struct nft_expr *expr,
@@ -327,15 +334,16 @@ int nft_meta_set_init(const struct nft_ctx *ctx,
 		len = sizeof(u8);
 		break;
 	case NFT_META_PKTTYPE:
-		err = nft_meta_set_init_pkttype(ctx);
-		if (err)
-			return err;
 		len = sizeof(u8);
 		break;
 	default:
 		return -EOPNOTSUPP;
 	}
 
+	err = nft_meta_set_validate(ctx, expr, NULL);
+	if (err < 0)
+		return err;
+
 	priv->sreg = nft_parse_register(tb[NFTA_META_SREG]);
 	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
@@ -407,6 +415,7 @@ static const struct nft_expr_ops nft_meta_set_ops = {
 	.init		= nft_meta_set_init,
 	.destroy	= nft_meta_set_destroy,
 	.dump		= nft_meta_set_dump,
+	.validate	= nft_meta_set_validate,
 };
 
 static const struct nft_expr_ops *
-- 
2.1.4

