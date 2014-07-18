From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/18] netfilter: nft_log: request explicit logger when loading rules
Date: Fri, 18 Jul 2014 13:01:05 +0200
Message-ID: <1405681272-4994-12-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This includes the special handling for NFPROTO_INET. There is
no real inet logger since we don't see packets of this family.
However, rules are loaded using this special family type. So
let's just request both IPV4 and IPV6 loggers.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_log.c |   24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 10cfb15..55d4297 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -50,6 +50,7 @@ static int nft_log_init(const struct nft_ctx *ctx,
 	struct nft_log *priv = nft_expr_priv(expr);
 	struct nf_loginfo *li = &priv->loginfo;
 	const struct nlattr *nla;
+	int ret;
 
 	nla = tb[NFTA_LOG_PREFIX];
 	if (nla != NULL) {
@@ -71,16 +72,37 @@ static int nft_log_init(const struct nft_ctx *ctx,
 			ntohs(nla_get_be16(tb[NFTA_LOG_QTHRESHOLD]));
 	}
 
-	return 0;
+	if (ctx->afi->family == NFPROTO_INET) {
+		ret = nf_logger_find_get(NFPROTO_IPV4, li->type);
+		if (ret < 0)
+			return ret;
+
+		ret = nf_logger_find_get(NFPROTO_IPV6, li->type);
+		if (ret < 0) {
+			nf_logger_put(NFPROTO_IPV4, li->type);
+			return ret;
+		}
+		return 0;
+	}
+
+	return nf_logger_find_get(ctx->afi->family, li->type);
 }
 
 static void nft_log_destroy(const struct nft_ctx *ctx,
 			    const struct nft_expr *expr)
 {
 	struct nft_log *priv = nft_expr_priv(expr);
+	struct nf_loginfo *li = &priv->loginfo;
 
 	if (priv->prefix != nft_log_null_prefix)
 		kfree(priv->prefix);
+
+	if (ctx->afi->family == NFPROTO_INET) {
+		nf_logger_put(NFPROTO_IPV4, li->type);
+		nf_logger_put(NFPROTO_IPV6, li->type);
+	} else {
+		nf_logger_put(ctx->afi->family, li->type);
+	}
 }
 
 static int nft_log_dump(struct sk_buff *skb, const struct nft_expr *expr)
-- 
1.7.10.4

