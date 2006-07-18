From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 06/10] MLSXFRM-v02: Add security context to acquire messages
 using netlink
Date: Tue, 18 Jul 2006 12:24:37 -0500
Message-ID: <44BD1955.70504@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	hallyn@elg11.watson.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:65059 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932316AbWGRRYy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:24:54 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge Hallyn <serue@us.ibm.com>

This includes the security context of a security association created for use by IKE
in the acquire messages sent to IKE daemons using netlink/xfrm_user. This would allow
the daemons to include the security context in the negotiation, so that the resultant
association is unique to that security context.

Signed-off-by:  <hallyn@elg11.watson.ibm.com>
---
 net/xfrm/xfrm_user.c |   45 ++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 16 deletions(-)

--- linux-2.6.17.flow/net/xfrm/xfrm_user.c	2006-07-14 09:57:24.000000000 -0500
+++ linux-2.6.17/net/xfrm/xfrm_user.c	2006-07-17 14:58:45.000000000 -0500
@@ -910,27 +910,40 @@ rtattr_failure:
 	return -1;
 }
 
-static int copy_to_user_sec_ctx(struct xfrm_policy *xp, struct sk_buff *skb)
+static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
 {
-	if (xp->security) {
-		int ctx_size = sizeof(struct xfrm_sec_ctx) +
-				xp->security->ctx_len;
-		struct rtattr *rt = __RTA_PUT(skb, XFRMA_SEC_CTX, ctx_size);
-		struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
-
-		uctx->exttype = XFRMA_SEC_CTX;
-		uctx->len = ctx_size;
-		uctx->ctx_doi = xp->security->ctx_doi;
-		uctx->ctx_alg = xp->security->ctx_alg;
-		uctx->ctx_len = xp->security->ctx_len;
-		memcpy(uctx + 1, xp->security->ctx_str, xp->security->ctx_len);
-	}
-	return 0;
+	int ctx_size = sizeof(struct xfrm_sec_ctx) + s->ctx_len;
+	struct rtattr *rt = __RTA_PUT(skb, XFRMA_SEC_CTX, ctx_size);
+	struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
+
+	uctx->exttype = XFRMA_SEC_CTX;
+	uctx->len = ctx_size;
+	uctx->ctx_doi = s->ctx_doi;
+	uctx->ctx_alg = s->ctx_alg;
+	uctx->ctx_len = s->ctx_len;
+	memcpy(uctx + 1, s->ctx_str, s->ctx_len);
+ 	return 0;
 
  rtattr_failure:
 	return -1;
 }
 
+static inline int copy_to_user_state_sec_ctx(struct xfrm_state *x, struct sk_buff *skb)
+{
+	if (x->security) {
+		return copy_sec_ctx(x->security, skb);
+	}
+	return 0;
+}
+
+static inline int copy_to_user_sec_ctx(struct xfrm_policy *xp, struct sk_buff *skb)
+{
+	if (xp->security) {
+		return copy_sec_ctx(xp->security, skb);
+	}
+	return 0;
+}
+
 static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
@@ -1709,7 +1722,7 @@ static int build_acquire(struct sk_buff 
 
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
-	if (copy_to_user_sec_ctx(xp, skb))
+	if (copy_to_user_state_sec_ctx(x, skb))
 		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
