From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] net: af_key: fix sleeping under rcu
Date: Tue, 18 Mar 2014 08:43:02 +0100
Message-ID: <1395128583-26274-2-git-send-email-steffen.klassert@secunet.com>
References: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54077 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752322AbaCRHnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:43:16 -0400
In-Reply-To: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

There's a kmalloc with GFP_KERNEL in a helper
(pfkey_sadb2xfrm_user_sec_ctx) used in pfkey_compile_policy which is
called under rcu_read_lock. Adjust pfkey_sadb2xfrm_user_sec_ctx to have
a gfp argument and adjust the users.

CC: Dave Jones <davej@redhat.com>
CC: Steffen Klassert <steffen.klassert@secunet.com>
CC: Fan Du <fan.du@windriver.com>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1a04c13..1526023 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -433,12 +433,13 @@ static inline int verify_sec_ctx_len(const void *p)
 	return 0;
 }
 
-static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_ctx(const struct sadb_x_sec_ctx *sec_ctx)
+static inline struct xfrm_user_sec_ctx *pfkey_sadb2xfrm_user_sec_ctx(const struct sadb_x_sec_ctx *sec_ctx,
+								     gfp_t gfp)
 {
 	struct xfrm_user_sec_ctx *uctx = NULL;
 	int ctx_size = sec_ctx->sadb_x_ctx_len;
 
-	uctx = kmalloc((sizeof(*uctx)+ctx_size), GFP_KERNEL);
+	uctx = kmalloc((sizeof(*uctx)+ctx_size), gfp);
 
 	if (!uctx)
 		return NULL;
@@ -1124,7 +1125,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 
 	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
 	if (sec_ctx != NULL) {
-		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
+		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_KERNEL);
 
 		if (!uctx)
 			goto out;
@@ -2231,7 +2232,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
 	if (sec_ctx != NULL) {
-		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
+		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_KERNEL);
 
 		if (!uctx) {
 			err = -ENOBUFS;
@@ -2335,7 +2336,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 
 	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
 	if (sec_ctx != NULL) {
-		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
+		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_KERNEL);
 
 		if (!uctx)
 			return -ENOMEM;
@@ -3239,7 +3240,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 		}
 		if ((*dir = verify_sec_ctx_len(p)))
 			goto out;
-		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
+		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_ATOMIC);
 		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
 		kfree(uctx);
 
-- 
1.7.9.5
