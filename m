From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 4/7] secid reconciliation-v03: Invoke LSM hook for outbound
 traffic
Date: Thu, 28 Sep 2006 21:33:06 -0500
Message-ID: <451C85E2.2030201@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:57414 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161289AbWI2CdU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 22:33:20 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invoke the skb_flow_out LSM hook for outbound
traffic for secid reconciliation and flow control.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 net/netfilter/xt_CONNSECMARK.c |   70 +++++++++++++++++++++++--------
 net/netfilter/xt_SECMARK.c     |   33 +++++++++++++-
 2 files changed, 85 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 4673862..40b4150 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -17,6 +17,8 @@
  */
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/security.h>
+#include <linux/netfilter_ipv6.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_CONNSECMARK.h>
 #include <net/netfilter/nf_conntrack_compat.h>
@@ -33,34 +35,70 @@ MODULE_ALIAS("ip6t_CONNSECMARK");
  * If the packet has a security mark and the connection does not, copy
  * the security mark from the packet to the connection.
  */
-static void secmark_save(struct sk_buff *skb)
+static void secmark_save(struct sk_buff *skb, unsigned int hooknum,
+		const struct xt_target *target)
 {
 	if (skb->secmark) {
 		u32 *connsecmark;
 		enum ip_conntrack_info ctinfo;
 
 		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
-		if (connsecmark && !*connsecmark)
-			if (*connsecmark != skb->secmark)
+		if (connsecmark)
+			if (*connsecmark != skb->secmark) {
 				*connsecmark = skb->secmark;
+			}
 	}
 }
 
 /*
- * If packet has no security mark, and the connection does, restore the
- * security mark from the connection to the packet.
+ * On the inbound, restore the security mark from the connection to the packet.
+ * On the outbound, filter based on the current secmark.
  */
-static void secmark_restore(struct sk_buff *skb)
+static unsigned int secmark_restore(struct sk_buff *skb, unsigned int hooknum,
+		   const struct net_device *in, const struct xt_target *target)
 {
-	if (!skb->secmark) {
-		u32 *connsecmark;
-		enum ip_conntrack_info ctinfo;
-
-		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
-		if (connsecmark && *connsecmark)
-			if (skb->secmark != *connsecmark)
-				skb->secmark = *connsecmark;
+	u32 *psecmark;
+	enum ip_conntrack_info ctinfo;
+
+	psecmark = nf_ct_get_secmark(skb, &ctinfo);
+
+	if (psecmark && *psecmark) {
+
+printk(KERN_ERR "IN HOOK (%d) (%u) (%u)\n", hooknum, skb->secmark, *psecmark);
+		/* Set secmark on inbound and filter it on outbound */
+		if ((target->family == AF_INET &&
+			(hooknum == NF_IP_POST_ROUTING ||
+			 hooknum == NF_IP_LOCAL_OUT ||
+			 hooknum == NF_IP_FORWARD)) ||
+		    (target->family == AF_INET6 &&
+			(hooknum == NF_IP6_POST_ROUTING ||
+			 hooknum == NF_IP6_LOCAL_OUT ||
+			 hooknum == NF_IP6_FORWARD))) {
+			/* outbound */
+			int err;
+
+			err = security_skb_flow_out(skb, *psecmark);
+printk(KERN_ERR "ERR (%d) (%u)\n", err, skb->secmark);
+			if (!err)
+				return NF_DROP;
+		}
+		else	/* inbound */
+			/* loopback traffic should already be labeled
+			   and any filtering on outbound should suffice */
+			if (in == &loopback_dev)
+				goto out;
+
+		/* inbound or done with outbound check or no LSM hook
+		   for outbound */
+		if (skb->secmark != *psecmark)
+{
+printk(KERN_ERR "RESTORING FROM (%u) TO (%u) (%u)\n", skb->secmark, *psecmark, 0xffffffff);
+			skb->secmark = *psecmark;
+}
 	}
+
+out:
+	return XT_CONTINUE;
 }
 
 static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
@@ -73,11 +111,11 @@ static unsigned int target(struct sk_buf
 
 	switch (info->mode) {
 	case CONNSECMARK_SAVE:
-		secmark_save(skb);
+		secmark_save(skb, hooknum, target);
 		break;
 
 	case CONNSECMARK_RESTORE:
-		secmark_restore(skb);
+		return secmark_restore(skb, hooknum, in, target);
 		break;
 
 	default:
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index add7521..28dc059 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -15,8 +15,10 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/selinux.h>
+#include <linux/security.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_SECMARK.h>
+#include <linux/netfilter_ipv6.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
@@ -47,9 +49,36 @@ static unsigned int target(struct sk_buf
 		BUG();
 	}
 
-	if ((*pskb)->secmark != secmark)
-		(*pskb)->secmark = secmark;
+	if (secmark) {
+
+		/* Set secmark on inbound and filter it on outbound */
+		if ((target->family == AF_INET &&
+			(hooknum == NF_IP_POST_ROUTING ||
+			 hooknum == NF_IP_LOCAL_OUT ||
+			 hooknum == NF_IP_FORWARD)) ||
+		    (target->family == AF_INET6 &&
+			(hooknum == NF_IP6_POST_ROUTING ||
+			 hooknum == NF_IP6_LOCAL_OUT ||
+			 hooknum == NF_IP6_FORWARD))) {
+			/* outbound */
+			int err;
+
+			err = security_skb_flow_out(*pskb, secmark);
+			if (!err)
+				return NF_DROP;
+		}
+		else 	/* inbound */
+			/* loopback traffic should already be labeled
+			   and any filtering on outbound should suffice */
+			if (in == &loopback_dev)
+				goto out;
+
+		/* inbound or no LSM hook for outbound */
+		if ((*pskb)->secmark != secmark)
+			(*pskb)->secmark = secmark;
+	}
 
+out:
 	return XT_CONTINUE;
 }
 
