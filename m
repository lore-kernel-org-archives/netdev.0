From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/13] netfilter: nft_compat: call {target, match}->destroy() to cleanup entry
Date: Wed, 18 Jun 2014 11:44:34 +0200
Message-ID: <1403084679-11227-9-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41436 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965675AbaFRJo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:44:56 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, the reference to external objects (eg. modules) are not
released when the rules are removed.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 8a779be..1840989 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -195,6 +195,15 @@ static void
 nft_target_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 {
 	struct xt_target *target = expr->ops->data;
+	void *info = nft_expr_priv(expr);
+	struct xt_tgdtor_param par;
+
+	par.net = ctx->net;
+	par.target = target;
+	par.targinfo = info;
+	par.family = ctx->afi->family;
+	if (par.target->destroy != NULL)
+		par.target->destroy(&par);
 
 	module_put(target->me);
 }
@@ -382,6 +391,15 @@ static void
 nft_match_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 {
 	struct xt_match *match = expr->ops->data;
+	void *info = nft_expr_priv(expr);
+	struct xt_mtdtor_param par;
+
+	par.net = ctx->net;
+	par.match = match;
+	par.matchinfo = info;
+	par.family = ctx->afi->family;
+	if (par.match->destroy != NULL)
+		par.match->destroy(&par);
 
 	module_put(match->me);
 }
-- 
1.7.10.4
