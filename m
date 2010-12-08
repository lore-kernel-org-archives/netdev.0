From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 1/3] xfrm: Add Traffic Flow Confidentiality padding XFRM attribute
Date: Wed,  8 Dec 2010 15:37:49 +0100
Message-ID: <1291819071-17538-2-git-send-email-martin@strongswan.org>
References: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:39854 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755194Ab0LHOjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 09:39:15 -0500
In-Reply-To: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XFRMA_TFCPAD attribute for XFRM state installation configures
Traffic Flow Confidentiality by padding ESP packets to a specified
length.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 include/linux/xfrm.h |    1 +
 include/net/xfrm.h   |    1 +
 net/xfrm/xfrm_user.c |   19 +++++++++++++++++--
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b971e38..930fdd2 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -283,6 +283,7 @@ enum xfrm_attr_type_t {
 	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
+	XFRMA_TFCPAD,		/* __u32 */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bcfb6b2..bdcade7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -143,6 +143,7 @@ struct xfrm_state {
 	struct xfrm_id		id;
 	struct xfrm_selector	sel;
 	struct xfrm_mark	mark;
+	u32			tfcpad;
 
 	u32			genid;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8bae6b2..8eb8895 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -148,7 +148,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		     !attrs[XFRMA_ALG_AUTH_TRUNC]) ||
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
-		    attrs[XFRMA_ALG_COMP])
+		    attrs[XFRMA_ALG_COMP]	||
+		    attrs[XFRMA_TFCPAD])
 			goto out;
 		break;
 
@@ -165,6 +166,9 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		     attrs[XFRMA_ALG_CRYPT]) &&
 		    attrs[XFRMA_ALG_AEAD])
 			goto out;
+		if (attrs[XFRMA_TFCPAD] &&
+		    p->mode != XFRM_MODE_TUNNEL)
+			goto out;
 		break;
 
 	case IPPROTO_COMP:
@@ -172,7 +176,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_AUTH]	||
 		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
-		    attrs[XFRMA_ALG_CRYPT])
+		    attrs[XFRMA_ALG_CRYPT]	||
+		    attrs[XFRMA_TFCPAD])
 			goto out;
 		break;
 
@@ -186,6 +191,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ENCAP]		||
 		    attrs[XFRMA_SEC_CTX]	||
+		    attrs[XFRMA_TFCPAD]		||
 		    !attrs[XFRMA_COADDR])
 			goto out;
 		break;
@@ -439,6 +445,9 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
+	if (attrs[XFRMA_TFCPAD])
+		x->tfcpad = nla_get_u32(attrs[XFRMA_TFCPAD]);
+
 	if (attrs[XFRMA_COADDR]) {
 		x->coaddr = kmemdup(nla_data(attrs[XFRMA_COADDR]),
 				    sizeof(*x->coaddr), GFP_KERNEL);
@@ -688,6 +697,9 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (x->encap)
 		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
+	if (x->tfcpad)
+		NLA_PUT_U32(skb, XFRMA_TFCPAD, x->tfcpad);
+
 	if (xfrm_mark_put(skb, &x->mark))
 		goto nla_put_failure;
 
@@ -2122,6 +2134,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_MIGRATE]		= { .len = sizeof(struct xfrm_user_migrate) },
 	[XFRMA_KMADDRESS]	= { .len = sizeof(struct xfrm_user_kmaddress) },
 	[XFRMA_MARK]		= { .len = sizeof(struct xfrm_mark) },
+	[XFRMA_TFCPAD]		= { .type = NLA_U32 },
 };
 
 static struct xfrm_link {
@@ -2301,6 +2314,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(*x->calg));
 	if (x->encap)
 		l += nla_total_size(sizeof(*x->encap));
+	if (x->tfcpad)
+		l += nla_total_size(sizeof(x->tfcpad));
 	if (x->security)
 		l += nla_total_size(sizeof(struct xfrm_user_sec_ctx) +
 				    x->security->ctx_len);
-- 
1.7.1

