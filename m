From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/9] netfilter: nft_compat: remove incomplete 32/64 bits arch compat code
Date: Fri,  3 Oct 2014 19:20:20 +0200
Message-ID: <1412356824-6362-6-git-send-email-pablo@netfilter.org>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43922 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754235AbaJCRTk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 13:19:40 -0400
In-Reply-To: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code was based on the wrong asumption that you can probe based
on the match/target private size that we get from userspace. This
doesn't work at all when you have to dump the info back to userspace
since you don't know what word size the userspace utility is using.

Currently, the extensions that require arch compat are limit match
and the ebt_mark match/target. The standard targets are not used by
the nft-xt compat layer, so they are not affected. We can work around
this limitation with a new revision that uses arch agnostic types.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |  116 ++++++--------------------------------------
 1 file changed, 15 insertions(+), 101 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 1840989..7e2683c 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -101,26 +101,12 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 
 static void target_compat_from_user(struct xt_target *t, void *in, void *out)
 {
-#ifdef CONFIG_COMPAT
-	if (t->compat_from_user) {
-		int pad;
-
-		t->compat_from_user(out, in);
-		pad = XT_ALIGN(t->targetsize) - t->targetsize;
-		if (pad > 0)
-			memset(out + t->targetsize, 0, pad);
-	} else
-#endif
-		memcpy(out, in, XT_ALIGN(t->targetsize));
-}
+	int pad;
 
-static inline int nft_compat_target_offset(struct xt_target *target)
-{
-#ifdef CONFIG_COMPAT
-	return xt_compat_target_offset(target);
-#else
-	return 0;
-#endif
+	memcpy(out, in, t->targetsize);
+	pad = XT_ALIGN(t->targetsize) - t->targetsize;
+	if (pad > 0)
+		memset(out + t->targetsize, 0, pad);
 }
 
 static const struct nla_policy nft_rule_compat_policy[NFTA_RULE_COMPAT_MAX + 1] = {
@@ -208,34 +194,6 @@ nft_target_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 	module_put(target->me);
 }
 
-static int
-target_dump_info(struct sk_buff *skb, const struct xt_target *t, const void *in)
-{
-	int ret;
-
-#ifdef CONFIG_COMPAT
-	if (t->compat_to_user) {
-		mm_segment_t old_fs;
-		void *out;
-
-		out = kmalloc(XT_ALIGN(t->targetsize), GFP_ATOMIC);
-		if (out == NULL)
-			return -ENOMEM;
-
-		/* We want to reuse existing compat_to_user */
-		old_fs = get_fs();
-		set_fs(KERNEL_DS);
-		t->compat_to_user(out, in);
-		set_fs(old_fs);
-		ret = nla_put(skb, NFTA_TARGET_INFO, XT_ALIGN(t->targetsize), out);
-		kfree(out);
-	} else
-#endif
-		ret = nla_put(skb, NFTA_TARGET_INFO, XT_ALIGN(t->targetsize), in);
-
-	return ret;
-}
-
 static int nft_target_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct xt_target *target = expr->ops->data;
@@ -243,7 +201,7 @@ static int nft_target_dump(struct sk_buff *skb, const struct nft_expr *expr)
 
 	if (nla_put_string(skb, NFTA_TARGET_NAME, target->name) ||
 	    nla_put_be32(skb, NFTA_TARGET_REV, htonl(target->revision)) ||
-	    target_dump_info(skb, target, info))
+	    nla_put(skb, NFTA_TARGET_INFO, XT_ALIGN(target->targetsize), info))
 		goto nla_put_failure;
 
 	return 0;
@@ -341,17 +299,12 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 
 static void match_compat_from_user(struct xt_match *m, void *in, void *out)
 {
-#ifdef CONFIG_COMPAT
-	if (m->compat_from_user) {
-		int pad;
-
-		m->compat_from_user(out, in);
-		pad = XT_ALIGN(m->matchsize) - m->matchsize;
-		if (pad > 0)
-			memset(out + m->matchsize, 0, pad);
-	} else
-#endif
-		memcpy(out, in, XT_ALIGN(m->matchsize));
+	int pad;
+
+	memcpy(out, in, m->matchsize);
+	pad = XT_ALIGN(m->matchsize) - m->matchsize;
+	if (pad > 0)
+		memset(out + m->matchsize, 0, pad);
 }
 
 static int
@@ -404,43 +357,6 @@ nft_match_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 	module_put(match->me);
 }
 
-static int
-match_dump_info(struct sk_buff *skb, const struct xt_match *m, const void *in)
-{
-	int ret;
-
-#ifdef CONFIG_COMPAT
-	if (m->compat_to_user) {
-		mm_segment_t old_fs;
-		void *out;
-
-		out = kmalloc(XT_ALIGN(m->matchsize), GFP_ATOMIC);
-		if (out == NULL)
-			return -ENOMEM;
-
-		/* We want to reuse existing compat_to_user */
-		old_fs = get_fs();
-		set_fs(KERNEL_DS);
-		m->compat_to_user(out, in);
-		set_fs(old_fs);
-		ret = nla_put(skb, NFTA_MATCH_INFO, XT_ALIGN(m->matchsize), out);
-		kfree(out);
-	} else
-#endif
-		ret = nla_put(skb, NFTA_MATCH_INFO, XT_ALIGN(m->matchsize), in);
-
-	return ret;
-}
-
-static inline int nft_compat_match_offset(struct xt_match *match)
-{
-#ifdef CONFIG_COMPAT
-	return xt_compat_match_offset(match);
-#else
-	return 0;
-#endif
-}
-
 static int nft_match_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	void *info = nft_expr_priv(expr);
@@ -448,7 +364,7 @@ static int nft_match_dump(struct sk_buff *skb, const struct nft_expr *expr)
 
 	if (nla_put_string(skb, NFTA_MATCH_NAME, match->name) ||
 	    nla_put_be32(skb, NFTA_MATCH_REV, htonl(match->revision)) ||
-	    match_dump_info(skb, match, info))
+	    nla_put(skb, NFTA_MATCH_INFO, XT_ALIGN(match->matchsize), info))
 		goto nla_put_failure;
 
 	return 0;
@@ -643,8 +559,7 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 		return ERR_PTR(-ENOMEM);
 
 	nft_match->ops.type = &nft_match_type;
-	nft_match->ops.size = NFT_EXPR_SIZE(XT_ALIGN(match->matchsize) +
-					    nft_compat_match_offset(match));
+	nft_match->ops.size = NFT_EXPR_SIZE(XT_ALIGN(match->matchsize));
 	nft_match->ops.eval = nft_match_eval;
 	nft_match->ops.init = nft_match_init;
 	nft_match->ops.destroy = nft_match_destroy;
@@ -714,8 +629,7 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 		return ERR_PTR(-ENOMEM);
 
 	nft_target->ops.type = &nft_target_type;
-	nft_target->ops.size = NFT_EXPR_SIZE(XT_ALIGN(target->targetsize) +
-					     nft_compat_target_offset(target));
+	nft_target->ops.size = NFT_EXPR_SIZE(XT_ALIGN(target->targetsize));
 	nft_target->ops.eval = nft_target_eval;
 	nft_target->ops.init = nft_target_init;
 	nft_target->ops.destroy = nft_target_destroy;
-- 
1.7.10.4
