From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/21] netfilter: nft_ct: prepare for key-dependent error unwind
Date: Sun, 12 Feb 2017 20:42:42 +0100
Message-ID: <1486928573-24773-11-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60460 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751390AbdBLTnS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:18 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 943BFBA6FF
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8404DDA845
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B4D09DA845
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:14 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Next patch will add ZONE_ID set support which will need similar
error unwind (put operation) as conntrack labels.

Prepare for this: remove the 'label_got' boolean in favor
of a switch statement that can be extended in next patch.

As we already have that in the set_destroy function place that in
a separate function and call it from the set init function.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 5bd4cdfdcda5..2d82df2737da 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -386,12 +386,24 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	return 0;
 }
 
+static void __nft_ct_set_destroy(const struct nft_ctx *ctx, struct nft_ct *priv)
+{
+	switch (priv->key) {
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	case NFT_CT_LABELS:
+		nf_connlabels_put(ctx->net);
+		break;
+#endif
+	default:
+		break;
+	}
+}
+
 static int nft_ct_set_init(const struct nft_ctx *ctx,
 			   const struct nft_expr *expr,
 			   const struct nlattr * const tb[])
 {
 	struct nft_ct *priv = nft_expr_priv(expr);
-	bool label_got = false;
 	unsigned int len;
 	int err;
 
@@ -412,7 +424,6 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 		err = nf_connlabels_get(ctx->net, (len * BITS_PER_BYTE) - 1);
 		if (err)
 			return err;
-		label_got = true;
 		break;
 #endif
 	default:
@@ -431,8 +442,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 	return 0;
 
 err1:
-	if (label_got)
-		nf_connlabels_put(ctx->net);
+	__nft_ct_set_destroy(ctx, priv);
 	return err;
 }
 
@@ -447,16 +457,7 @@ static void nft_ct_set_destroy(const struct nft_ctx *ctx,
 {
 	struct nft_ct *priv = nft_expr_priv(expr);
 
-	switch (priv->key) {
-#ifdef CONFIG_NF_CONNTRACK_LABELS
-	case NFT_CT_LABELS:
-		nf_connlabels_put(ctx->net);
-		break;
-#endif
-	default:
-		break;
-	}
-
+	__nft_ct_set_destroy(ctx, priv);
 	nft_ct_netns_put(ctx->net, ctx->afi->family);
 }
 
-- 
2.1.4
