From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/22] netfilter: nf_tables: validate the expr explicitly after init successfully
Date: Mon, 20 Mar 2017 11:08:34 +0100
Message-ID: <1490004530-9128-7-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52100 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754010AbdCTKJe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6A60E523F4
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 572E5DA877
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0EC2FDA8FF
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:05 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

When we want to validate the expr's dependency or hooks, we must do two
things to accomplish it. First, write a X_validate callback function
and point ->validate to it. Second, call X_validate in init routine.
This is very common, such as fib, nat, reject expr and so on ...

It is a little ugly, since we will call X_validate in the expr's init
routine, it's better to do it in nf_tables_newexpr. So we can avoid to
do this again and again. After doing this, the second step listed above
is not useful anymore, remove them now.

Patch was tested by nftables/tests/py/nft-test.py and
nftables/tests/shell/run-tests.sh.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nft_reject_bridge.c |  6 +-----
 net/netfilter/nf_tables_api.c            | 11 +++++++++++
 net/netfilter/nft_compat.c               |  8 --------
 net/netfilter/nft_fib.c                  |  2 +-
 net/netfilter/nft_masq.c                 |  4 ----
 net/netfilter/nft_meta.c                 |  4 ----
 net/netfilter/nft_nat.c                  |  4 ----
 net/netfilter/nft_redir.c                |  4 ----
 net/netfilter/nft_reject.c               |  5 -----
 net/netfilter/nft_reject_inet.c          |  6 +-----
 10 files changed, 14 insertions(+), 40 deletions(-)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 206dc266ecd2..346ef6b00b8f 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -375,11 +375,7 @@ static int nft_reject_bridge_init(const struct nft_ctx *ctx,
 				  const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	int icmp_code, err;
-
-	err = nft_reject_bridge_validate(ctx, expr, NULL);
-	if (err < 0)
-		return err;
+	int icmp_code;
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5e0ccfd5bb37..fd8789eccc92 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1772,8 +1772,19 @@ static int nf_tables_newexpr(const struct nft_ctx *ctx,
 			goto err1;
 	}
 
+	if (ops->validate) {
+		const struct nft_data *data = NULL;
+
+		err = ops->validate(ctx, expr, &data);
+		if (err < 0)
+			goto err2;
+	}
+
 	return 0;
 
+err2:
+	if (ops->destroy)
+		ops->destroy(ctx, expr);
 err1:
 	expr->ops = NULL;
 	return err;
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index c21e7eb8dce0..fab6bf3f955e 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -230,10 +230,6 @@ nft_target_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	union nft_entry e = {};
 	int ret;
 
-	ret = nft_compat_chain_validate_dependency(target->table, ctx->chain);
-	if (ret < 0)
-		goto err;
-
 	target_compat_from_user(target, nla_data(tb[NFTA_TARGET_INFO]), info);
 
 	if (ctx->nla[NFTA_RULE_COMPAT]) {
@@ -419,10 +415,6 @@ nft_match_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	union nft_entry e = {};
 	int ret;
 
-	ret = nft_compat_chain_validate_dependency(match->table, ctx->chain);
-	if (ret < 0)
-		goto err;
-
 	match_compat_from_user(match, nla_data(tb[NFTA_MATCH_INFO]), info);
 
 	if (ctx->nla[NFTA_RULE_COMPAT]) {
diff --git a/net/netfilter/nft_fib.c b/net/netfilter/nft_fib.c
index 29a4906adc27..fd0b19303b0d 100644
--- a/net/netfilter/nft_fib.c
+++ b/net/netfilter/nft_fib.c
@@ -112,7 +112,7 @@ int nft_fib_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	if (err < 0)
 		return err;
 
-	return nft_fib_validate(ctx, expr, NULL);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nft_fib_init);
 
diff --git a/net/netfilter/nft_masq.c b/net/netfilter/nft_masq.c
index 11ce016cd479..6ac03d4266c9 100644
--- a/net/netfilter/nft_masq.c
+++ b/net/netfilter/nft_masq.c
@@ -46,10 +46,6 @@ int nft_masq_init(const struct nft_ctx *ctx,
 	struct nft_masq *priv = nft_expr_priv(expr);
 	int err;
 
-	err = nft_masq_validate(ctx, expr, NULL);
-	if (err)
-		return err;
-
 	if (tb[NFTA_MASQ_FLAGS]) {
 		priv->flags = ntohl(nla_get_be32(tb[NFTA_MASQ_FLAGS]));
 		if (priv->flags & ~NF_NAT_RANGE_MASK)
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index e1f5ca9b423b..d14417aaf5d4 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -370,10 +370,6 @@ int nft_meta_set_init(const struct nft_ctx *ctx,
 		return -EOPNOTSUPP;
 	}
 
-	err = nft_meta_set_validate(ctx, expr, NULL);
-	if (err < 0)
-		return err;
-
 	priv->sreg = nft_parse_register(tb[NFTA_META_SREG]);
 	err = nft_validate_register_load(priv->sreg, len);
 	if (err < 0)
diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index 19a7bf3236f9..26a74dfb3b7a 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -138,10 +138,6 @@ static int nft_nat_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 		return -EINVAL;
 	}
 
-	err = nft_nat_validate(ctx, expr, NULL);
-	if (err < 0)
-		return err;
-
 	if (tb[NFTA_NAT_FAMILY] == NULL)
 		return -EINVAL;
 
diff --git a/net/netfilter/nft_redir.c b/net/netfilter/nft_redir.c
index 40dcd05146d5..1e66538bf0ff 100644
--- a/net/netfilter/nft_redir.c
+++ b/net/netfilter/nft_redir.c
@@ -47,10 +47,6 @@ int nft_redir_init(const struct nft_ctx *ctx,
 	unsigned int plen;
 	int err;
 
-	err = nft_redir_validate(ctx, expr, NULL);
-	if (err < 0)
-		return err;
-
 	plen = FIELD_SIZEOF(struct nf_nat_range, min_addr.all);
 	if (tb[NFTA_REDIR_REG_PROTO_MIN]) {
 		priv->sreg_proto_min =
diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index c64de3f7379d..29f5bd2377b0 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -42,11 +42,6 @@ int nft_reject_init(const struct nft_ctx *ctx,
 		    const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	int err;
-
-	err = nft_reject_validate(ctx, expr, NULL);
-	if (err < 0)
-		return err;
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 9e90a02cb104..5a7fb5ff867d 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -66,11 +66,7 @@ static int nft_reject_inet_init(const struct nft_ctx *ctx,
 				const struct nlattr * const tb[])
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
-	int icmp_code, err;
-
-	err = nft_reject_validate(ctx, expr, NULL);
-	if (err < 0)
-		return err;
+	int icmp_code;
 
 	if (tb[NFTA_REJECT_TYPE] == NULL)
 		return -EINVAL;
-- 
2.1.4
