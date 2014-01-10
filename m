From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/23] netfilter: nft_ct: load both IPv4 and IPv6 conntrack modules for NFPROTO_INET
Date: Fri, 10 Jan 2014 01:35:27 +0100
Message-ID: <1389314142-17969-9-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51525 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757061AbaAJAgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:07 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The ct expression can currently not be used in the inet family since
we don't have a conntrack module for NFPROTO_INET, so
nf_ct_l3proto_try_module_get() fails. Add some manual handling to
load the modules for both NFPROTO_IPV4 and NFPROTO_IPV6 if the
ct expression is used in the inet family.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c |   39 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 36 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 955f4e6..3727a32 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -129,6 +129,39 @@ static const struct nla_policy nft_ct_policy[NFTA_CT_MAX + 1] = {
 	[NFTA_CT_DIRECTION]	= { .type = NLA_U8 },
 };
 
+static int nft_ct_l3proto_try_module_get(uint8_t family)
+{
+	int err;
+
+	if (family == NFPROTO_INET) {
+		err = nf_ct_l3proto_try_module_get(NFPROTO_IPV4);
+		if (err < 0)
+			goto err1;
+		err = nf_ct_l3proto_try_module_get(NFPROTO_IPV6);
+		if (err < 0)
+			goto err2;
+	} else {
+		err = nf_ct_l3proto_try_module_get(family);
+		if (err < 0)
+			goto err1;
+	}
+	return 0;
+
+err2:
+	nf_ct_l3proto_module_put(NFPROTO_IPV4);
+err1:
+	return err;
+}
+
+static void nft_ct_l3proto_module_put(uint8_t family)
+{
+	if (family == NFPROTO_INET) {
+		nf_ct_l3proto_module_put(NFPROTO_IPV4);
+		nf_ct_l3proto_module_put(NFPROTO_IPV6);
+	} else
+		nf_ct_l3proto_module_put(family);
+}
+
 static int nft_ct_init(const struct nft_ctx *ctx,
 		       const struct nft_expr *expr,
 		       const struct nlattr * const tb[])
@@ -179,7 +212,7 @@ static int nft_ct_init(const struct nft_ctx *ctx,
 		return -EOPNOTSUPP;
 	}
 
-	err = nf_ct_l3proto_try_module_get(ctx->afi->family);
+	err = nft_ct_l3proto_try_module_get(ctx->afi->family);
 	if (err < 0)
 		return err;
 	priv->family = ctx->afi->family;
@@ -195,7 +228,7 @@ static int nft_ct_init(const struct nft_ctx *ctx,
 	return 0;
 
 err1:
-	nf_ct_l3proto_module_put(ctx->afi->family);
+	nft_ct_l3proto_module_put(ctx->afi->family);
 	return err;
 }
 
@@ -203,7 +236,7 @@ static void nft_ct_destroy(const struct nft_expr *expr)
 {
 	struct nft_ct *priv = nft_expr_priv(expr);
 
-	nf_ct_l3proto_module_put(priv->family);
+	nft_ct_l3proto_module_put(priv->family);
 }
 
 static int nft_ct_dump(struct sk_buff *skb, const struct nft_expr *expr)
-- 
1.7.10.4
