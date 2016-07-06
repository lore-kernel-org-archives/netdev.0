From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/26] netfilter: nf_log: handle NFPROTO_INET properly in nf_logger_[find_get|put]
Date: Wed,  6 Jul 2016 16:23:46 +0200
Message-ID: <1467815048-2240-5-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

When we request NFPROTO_INET, it means both NFPROTO_IPV4 and NFPROTO_IPV6.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c  | 20 ++++++++++++++++++++
 net/netfilter/nft_log.c | 21 +--------------------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index a5d41df..73b845d 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -159,6 +159,20 @@ int nf_logger_find_get(int pf, enum nf_log_type type)
 	struct nf_logger *logger;
 	int ret = -ENOENT;
 
+	if (pf == NFPROTO_INET) {
+		ret = nf_logger_find_get(NFPROTO_IPV4, type);
+		if (ret < 0)
+			return ret;
+
+		ret = nf_logger_find_get(NFPROTO_IPV6, type);
+		if (ret < 0) {
+			nf_logger_put(NFPROTO_IPV4, type);
+			return ret;
+		}
+
+		return 0;
+	}
+
 	if (rcu_access_pointer(loggers[pf][type]) == NULL)
 		request_module("nf-logger-%u-%u", pf, type);
 
@@ -179,6 +193,12 @@ void nf_logger_put(int pf, enum nf_log_type type)
 {
 	struct nf_logger *logger;
 
+	if (pf == NFPROTO_INET) {
+		nf_logger_put(NFPROTO_IPV4, type);
+		nf_logger_put(NFPROTO_IPV6, type);
+		return;
+	}
+
 	BUG_ON(loggers[pf][type] == NULL);
 
 	rcu_read_lock();
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 319c22b..713d668 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -52,7 +52,6 @@ static int nft_log_init(const struct nft_ctx *ctx,
 	struct nft_log *priv = nft_expr_priv(expr);
 	struct nf_loginfo *li = &priv->loginfo;
 	const struct nlattr *nla;
-	int ret;
 
 	nla = tb[NFTA_LOG_PREFIX];
 	if (nla != NULL) {
@@ -97,19 +96,6 @@ static int nft_log_init(const struct nft_ctx *ctx,
 		break;
 	}
 
-	if (ctx->afi->family == NFPROTO_INET) {
-		ret = nf_logger_find_get(NFPROTO_IPV4, li->type);
-		if (ret < 0)
-			return ret;
-
-		ret = nf_logger_find_get(NFPROTO_IPV6, li->type);
-		if (ret < 0) {
-			nf_logger_put(NFPROTO_IPV4, li->type);
-			return ret;
-		}
-		return 0;
-	}
-
 	return nf_logger_find_get(ctx->afi->family, li->type);
 }
 
@@ -122,12 +108,7 @@ static void nft_log_destroy(const struct nft_ctx *ctx,
 	if (priv->prefix != nft_log_null_prefix)
 		kfree(priv->prefix);
 
-	if (ctx->afi->family == NFPROTO_INET) {
-		nf_logger_put(NFPROTO_IPV4, li->type);
-		nf_logger_put(NFPROTO_IPV6, li->type);
-	} else {
-		nf_logger_put(ctx->afi->family, li->type);
-	}
+	nf_logger_put(ctx->afi->family, li->type);
 }
 
 static int nft_log_dump(struct sk_buff *skb, const struct nft_expr *expr)
-- 
2.1.4

