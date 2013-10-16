From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] {selinux, af_key} Rework pfkey_sadb2xfrm_user_sec_ctx
Date: Wed, 16 Oct 2013 14:15:14 +0800
Message-ID: <1381904114-29556-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54928 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab3JPGPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 02:15:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking advantages of sadb_x_sec_ctx and xfrm_user_sec_ctx share the same
structure arrangement, rework pfkey_sadb2xfrm_user_sec_ctx by casting
sadb_x_sec_ctx into xfrm_user_sec_ctx with minor len fix.

Then we can:
 -Avoid kmalloc/free memory for xfrm_user_sec_ctx, sadb_x_sec_ctx would be fine.
 -Fix missing return value check bug for pfkey_compile_policy when kmalloc fails

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/key/af_key.c |   33 +--------------------------------
 1 file changed, 1 insertion(+), 32 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9d58537..c7d304d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -435,22 +435,9 @@ static inline int verify_sec_ctx_len(const void *p)
 
 static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_ctx(const struct sadb_x_sec_ctx *sec_ctx)
 {
-	struct xfrm_user_sec_ctx *uctx = NULL;
-	int ctx_size = sec_ctx->sadb_x_ctx_len;
-
-	uctx = kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL);
-
-	if (!uctx)
-		return NULL;
+	struct xfrm_user_sec_ctx *uctx = (struct xfrm_user_sec_ctx *)sec_ctx;
 
 	uctx->len = pfkey_sec_ctx_len(sec_ctx);
-	uctx->exttype = sec_ctx->sadb_x_sec_exttype;
-	uctx->ctx_doi = sec_ctx->sadb_x_ctx_doi;
-	uctx->ctx_alg = sec_ctx->sadb_x_ctx_alg;
-	uctx->ctx_len = sec_ctx->sadb_x_ctx_len;
-	memcpy(uctx + 1, sec_ctx + 1,
-	       uctx->ctx_len);
-
 	return uctx;
 }
 
@@ -1125,12 +1112,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	if (sec_ctx != NULL) {
 		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 
-		if (!uctx)
-			goto out;
-
 		err = security_xfrm_state_alloc(x, uctx);
-		kfree(uctx);
-
 		if (err)
 			goto out;
 	}
@@ -2225,14 +2207,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 	if (sec_ctx != NULL) {
 		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 
-		if (!uctx) {
-			err = -ENOBUFS;
-			goto out;
-		}
-
 		err = security_xfrm_policy_alloc(&xp->security, uctx);
-		kfree(uctx);
-
 		if (err)
 			goto out;
 	}
@@ -2329,11 +2304,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 	if (sec_ctx != NULL) {
 		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 
-		if (!uctx)
-			return -ENOMEM;
-
 		err = security_xfrm_policy_alloc(&pol_ctx, uctx);
-		kfree(uctx);
 		if (err)
 			return err;
 	}
@@ -3230,8 +3201,6 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 			goto out;
 		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
-		kfree(uctx);
-
 		if (*dir)
 			goto out;
 	}
-- 
1.7.9.5
