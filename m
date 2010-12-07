From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 1/3] xfrm: Add Traffic Flow Confidentiality padding XFRM attribute
Date: Tue,  7 Dec 2010 11:29:02 +0100
Message-ID: <1291717744-30111-2-git-send-email-martin@strongswan.org>
References: <1291717744-30111-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:37476 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249Ab0LGK3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 05:29:31 -0500
In-Reply-To: <1291717744-30111-1-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The XFRMA_TFC attribute for XFRM state installation configures
Traffic Flow Confidentiality by padding ESP packets to a specified
length.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 include/linux/xfrm.h |    6 ++++++
 include/net/xfrm.h   |    1 +
 net/xfrm/xfrm_user.c |   16 ++++++++++++++--
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b971e38..7cd5232 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -283,6 +283,7 @@ enum xfrm_attr_type_t {
 	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
+	XFRMA_TFC,		/* struct xfrm_tfc */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -293,6 +294,11 @@ struct xfrm_mark {
 	__u32           m; /* mask */
 };
 
+struct xfrm_tfc {
+	__u16		pad;
+	__u16		flags;
+};
+
 enum xfrm_sadattr_type_t {
 	XFRMA_SAD_UNSPEC,
 	XFRMA_SAD_CNT,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bcfb6b2..03468c0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -143,6 +143,7 @@ struct xfrm_state {
 	struct xfrm_id		id;
 	struct xfrm_selector	sel;
 	struct xfrm_mark	mark;
+	struct xfrm_tfc		tfc;
 
 	u32			genid;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8bae6b2..df6a60f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -148,7 +148,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		     !attrs[XFRMA_ALG_AUTH_TRUNC]) ||
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
-		    attrs[XFRMA_ALG_COMP])
+		    attrs[XFRMA_ALG_COMP]	||
+		    attrs[XFRMA_TFC])
 			goto out;
 		break;
 
@@ -172,7 +173,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_AUTH]	||
 		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
-		    attrs[XFRMA_ALG_CRYPT])
+		    attrs[XFRMA_ALG_CRYPT]	||
+		    attrs[XFRMA_TFC])
 			goto out;
 		break;
 
@@ -186,6 +188,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ENCAP]		||
 		    attrs[XFRMA_SEC_CTX]	||
+		    attrs[XFRMA_TFC]		||
 		    !attrs[XFRMA_COADDR])
 			goto out;
 		break;
@@ -439,6 +442,9 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
+	if (attrs[XFRMA_TFC])
+		memcpy(&x->tfc, nla_data(attrs[XFRMA_TFC]), sizeof(x->tfc));
+
 	if (attrs[XFRMA_COADDR]) {
 		x->coaddr = kmemdup(nla_data(attrs[XFRMA_COADDR]),
 				    sizeof(*x->coaddr), GFP_KERNEL);
@@ -688,6 +694,9 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (x->encap)
 		NLA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
+	if (x->tfc.pad)
+		NLA_PUT(skb, XFRMA_TFC, sizeof(x->tfc), &x->tfc);
+
 	if (xfrm_mark_put(skb, &x->mark))
 		goto nla_put_failure;
 
@@ -2122,6 +2131,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_MIGRATE]		= { .len = sizeof(struct xfrm_user_migrate) },
 	[XFRMA_KMADDRESS]	= { .len = sizeof(struct xfrm_user_kmaddress) },
 	[XFRMA_MARK]		= { .len = sizeof(struct xfrm_mark) },
+	[XFRMA_TFC]		= { .len = sizeof(struct xfrm_tfc) },
 };
 
 static struct xfrm_link {
@@ -2301,6 +2311,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(*x->calg));
 	if (x->encap)
 		l += nla_total_size(sizeof(*x->encap));
+	if (x->tfc.pad)
+		l += nla_total_size(sizeof(x->tfc));
 	if (x->security)
 		l += nla_total_size(sizeof(struct xfrm_user_sec_ctx) +
 				    x->security->ctx_len);
-- 
1.7.1

