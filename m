From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 9/9] netfilter: nft_masq: register/unregister notifiers on module init/exit
Date: Fri,  3 Oct 2014 19:20:24 +0200
Message-ID: <1412356824-6362-10-git-send-email-pablo@netfilter.org>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43900 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbaJCRTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 13:19:34 -0400
In-Reply-To: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

We have to register the notifiers in the masquerade expression from
the the module _init and _exit path.

This fixes crashes when removing the masquerade rule with no
ipt_MASQUERADE support in place (which was masking the problem).

Fixes: 9ba1f72 ("netfilter: nf_tables: add new nft_masq expression")
Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_masq_ipv4.c |   34 +++++++++++-----------------------
 net/ipv6/netfilter/nft_masq_ipv6.c |   34 +++++++++++-----------------------
 2 files changed, 22 insertions(+), 46 deletions(-)

diff --git a/net/ipv4/netfilter/nft_masq_ipv4.c b/net/ipv4/netfilter/nft_masq_ipv4.c
index 6ea1d20..1c636d6 100644
--- a/net/ipv4/netfilter/nft_masq_ipv4.c
+++ b/net/ipv4/netfilter/nft_masq_ipv4.c
@@ -32,33 +32,12 @@ static void nft_masq_ipv4_eval(const struct nft_expr *expr,
 	data[NFT_REG_VERDICT].verdict = verdict;
 }
 
-static int nft_masq_ipv4_init(const struct nft_ctx *ctx,
-			      const struct nft_expr *expr,
-			      const struct nlattr * const tb[])
-{
-	int err;
-
-	err = nft_masq_init(ctx, expr, tb);
-	if (err < 0)
-		return err;
-
-	nf_nat_masquerade_ipv4_register_notifier();
-	return 0;
-}
-
-static void nft_masq_ipv4_destroy(const struct nft_ctx *ctx,
-				  const struct nft_expr *expr)
-{
-	nf_nat_masquerade_ipv4_unregister_notifier();
-}
-
 static struct nft_expr_type nft_masq_ipv4_type;
 static const struct nft_expr_ops nft_masq_ipv4_ops = {
 	.type		= &nft_masq_ipv4_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_masq)),
 	.eval		= nft_masq_ipv4_eval,
-	.init		= nft_masq_ipv4_init,
-	.destroy	= nft_masq_ipv4_destroy,
+	.init		= nft_masq_init,
 	.dump		= nft_masq_dump,
 };
 
@@ -73,12 +52,21 @@ static struct nft_expr_type nft_masq_ipv4_type __read_mostly = {
 
 static int __init nft_masq_ipv4_module_init(void)
 {
-	return nft_register_expr(&nft_masq_ipv4_type);
+	int ret;
+
+	ret = nft_register_expr(&nft_masq_ipv4_type);
+	if (ret < 0)
+		return ret;
+
+	nf_nat_masquerade_ipv4_register_notifier();
+
+	return ret;
 }
 
 static void __exit nft_masq_ipv4_module_exit(void)
 {
 	nft_unregister_expr(&nft_masq_ipv4_type);
+	nf_nat_masquerade_ipv4_unregister_notifier();
 }
 
 module_init(nft_masq_ipv4_module_init);
diff --git a/net/ipv6/netfilter/nft_masq_ipv6.c b/net/ipv6/netfilter/nft_masq_ipv6.c
index 4e51334..556262f 100644
--- a/net/ipv6/netfilter/nft_masq_ipv6.c
+++ b/net/ipv6/netfilter/nft_masq_ipv6.c
@@ -32,33 +32,12 @@ static void nft_masq_ipv6_eval(const struct nft_expr *expr,
 	data[NFT_REG_VERDICT].verdict = verdict;
 }
 
-static int nft_masq_ipv6_init(const struct nft_ctx *ctx,
-			      const struct nft_expr *expr,
-			      const struct nlattr * const tb[])
-{
-	int err;
-
-	err = nft_masq_init(ctx, expr, tb);
-	if (err < 0)
-		return err;
-
-	nf_nat_masquerade_ipv6_register_notifier();
-	return 0;
-}
-
-static void nft_masq_ipv6_destroy(const struct nft_ctx *ctx,
-				  const struct nft_expr *expr)
-{
-	nf_nat_masquerade_ipv6_unregister_notifier();
-}
-
 static struct nft_expr_type nft_masq_ipv6_type;
 static const struct nft_expr_ops nft_masq_ipv6_ops = {
 	.type		= &nft_masq_ipv6_type,
 	.size		= NFT_EXPR_SIZE(sizeof(struct nft_masq)),
 	.eval		= nft_masq_ipv6_eval,
-	.init		= nft_masq_ipv6_init,
-	.destroy	= nft_masq_ipv6_destroy,
+	.init		= nft_masq_init,
 	.dump		= nft_masq_dump,
 };
 
@@ -73,12 +52,21 @@ static struct nft_expr_type nft_masq_ipv6_type __read_mostly = {
 
 static int __init nft_masq_ipv6_module_init(void)
 {
-	return nft_register_expr(&nft_masq_ipv6_type);
+	int ret;
+
+	ret = nft_register_expr(&nft_masq_ipv6_type);
+	if (ret < 0)
+		return ret;
+
+	nf_nat_masquerade_ipv6_register_notifier();
+
+	return ret;
 }
 
 static void __exit nft_masq_ipv6_module_exit(void)
 {
 	nft_unregister_expr(&nft_masq_ipv6_type);
+	nf_nat_masquerade_ipv6_unregister_notifier();
 }
 
 module_init(nft_masq_ipv6_module_init);
-- 
1.7.10.4
