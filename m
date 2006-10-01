From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 8/9] secid reconciliation-v04: Use secmark when classifying
 flow using skb
Date: Sun, 01 Oct 2006 16:27:09 -0500
Message-ID: <452032AD.6080303@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:3617 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932411AbWJAV1f
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 17:27:35 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This beings secmark into the picture when classifying flows
using an skb.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h |   10 ----------
 include/linux/skbuff.h   |   20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 10 deletions(-)

--- net-2.6.sid/include/linux/security.h	2006-09-30 16:02:59.000000000 -0500
+++ net-2.6/include/linux/security.h	2006-10-01 13:07:43.000000000 -0500
@@ -3223,12 +3223,6 @@ static inline int security_xfrm_decode_s
 	return security_ops->xfrm_decode_session(skb, secid, 1);
 }
 
-static inline void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl)
-{
-	int rc = security_ops->xfrm_decode_session(skb, &fl->secid, 0);
-
-	BUG_ON(rc);
-}
 #else	/* CONFIG_SECURITY_NETWORK_XFRM */
 static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
 {
@@ -3297,10 +3291,6 @@ static inline int security_xfrm_decode_s
 	return 0;
 }
 
-static inline void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl)
-{
-}
-
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
 #ifdef CONFIG_KEYS
--- net-2.6.sid/include/linux/skbuff.h	2006-09-27 18:20:54.000000000 -0500
+++ net-2.6/include/linux/skbuff.h	2006-10-01 13:17:22.000000000 -0500
@@ -30,6 +30,7 @@
 #include <net/checksum.h>
 #include <linux/dmaengine.h>
 #include <net/flow.h>
+#include <linux/security.h>
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -1514,6 +1515,20 @@ static inline void security_flow_classif
 	skb->secmark = fl->secid;
 }
 
+static inline void security_skb_classify_flow(struct sk_buff *skb,
+					struct flowi *fl)
+{
+	/*
+	 * We need to check for xfrm label here since secid reconciliation
+	 * may or may not have happened yet and we want the
+	 * flow to use the best available label.
+	 */
+	int rc = security_xfrm_decode_session(skb, &fl->secid);
+
+	if (rc || !fl->secid)
+		fl->secid = skb->secmark;
+}
+
 #else
 
 static inline void security_skb_classify_skb(struct sk_buff *from,
@@ -1526,6 +1541,11 @@ static inline void security_flow_classif
 {
 }
 
+static inline void security_skb_classify_flow(struct sk_buff *skb,
+					struct flowi *fl)
+{
+}
+
 #endif /* CONFIG_SECURITY_NETWORK */
 
 #endif	/* __KERNEL__ */
