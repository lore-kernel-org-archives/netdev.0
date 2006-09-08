From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 4/7] secid reconciliation-v02: Invoke LSM hook for outbound
 traffic
Date: Fri, 08 Sep 2006 11:50:46 -0500
Message-ID: <45019F66.20603@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:2132 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750726AbWIHQvE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 12:51:04 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invoke the skb_netfilter_check LSM hook for outbound (OUTPUT/FORWARD)
traffic for secid reconciliation and flow control.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 net/netfilter/xt_CONNSECMARK.c |   44 ++++++++++++++++++++++---------
 net/netfilter/xt_SECMARK.c     |   20 ++++++++++++--
 2 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 4673862..a79bd20 100644
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
@@ -47,20 +49,32 @@ static void secmark_save(struct sk_buff 
 }
 
 /*
- * If packet has no security mark, and the connection does, restore the
- * security mark from the connection to the packet.
+ * On the inbound, restore the security mark from the connection to the packet.
+ * On the outbound, filter based on the current secmark.
  */
-static void secmark_restore(struct sk_buff *skb)
+static unsigned int secmark_restore(struct sk_buff *skb, unsigned int hooknum,
+			   const struct xt_target *target)
 {
-	if (!skb->secmark) {
-		u32 *connsecmark;
-		enum ip_conntrack_info ctinfo;
+	u32 *psecmark;
+	u32 secmark = 0;
+	enum ip_conntrack_info ctinfo;
 
-		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
-		if (connsecmark && *connsecmark)
-			if (skb->secmark != *connsecmark)
-				skb->secmark = *connsecmark;
-	}
+	psecmark = nf_ct_get_secmark(skb, &ctinfo);
+	if (psecmark)
+		secmark = *psecmark;
+
+	if (!secmark)
+		return XT_CONTINUE;
+
+	/* Set secmark on inbound and filter it on outbound */
+	if (hooknum == NF_IP_POST_ROUTING || hooknum == NF_IP6_POST_ROUTING) {
+		if (!security_skb_netfilter_check(skb, secmark))
+			return NF_DROP;
+	} else
+		if (skb->secmark != secmark)
+			skb->secmark = secmark;
+
+	return XT_CONTINUE;
 }
 
 static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
@@ -77,7 +91,7 @@ static unsigned int target(struct sk_buf
 		break;
 
 	case CONNSECMARK_RESTORE:
-		secmark_restore(skb);
+		return secmark_restore(skb, hooknum, target);
 		break;
 
 	default:
@@ -114,6 +128,9 @@ static struct xt_target xt_connsecmark_t
 		.target		= target,
 		.targetsize	= sizeof(struct xt_connsecmark_target_info),
 		.table		= "mangle",
+		.hooks		= (1 << NF_IP_LOCAL_IN) |
+				  (1 << NF_IP_FORWARD) |
+				  (1 << NF_IP_POST_ROUTING),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -123,6 +140,9 @@ static struct xt_target xt_connsecmark_t
 		.target		= target,
 		.targetsize	= sizeof(struct xt_connsecmark_target_info),
 		.table		= "mangle",
+		.hooks		= (1 << NF_IP6_LOCAL_IN) |
+				  (1 << NF_IP6_FORWARD) |
+				  (1 << NF_IP6_POST_ROUTING),
 		.me		= THIS_MODULE,
 	},
 };
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index add7521..de1de45 100644
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
@@ -47,8 +49,16 @@ static unsigned int target(struct sk_buf
 		BUG();
 	}
 
-	if ((*pskb)->secmark != secmark)
-		(*pskb)->secmark = secmark;
+	if (!secmark)
+		return XT_CONTINUE;
+
+	/* Set secmark on inbound and filter it on outbound */
+	if (hooknum == NF_IP_POST_ROUTING || hooknum == NF_IP6_POST_ROUTING) {
+		if (!security_skb_netfilter_check(*pskb, secmark))
+			return NF_DROP;
+	} else
+		if ((*pskb)->secmark != secmark)
+			(*pskb)->secmark = secmark;
 
 	return XT_CONTINUE;
 }
@@ -119,6 +129,9 @@ static struct xt_target xt_secmark_targe
 		.target		= target,
 		.targetsize	= sizeof(struct xt_secmark_target_info),
 		.table		= "mangle",
+		.hooks		= (1 << NF_IP_LOCAL_IN) |
+				  (1 << NF_IP_FORWARD) |
+				  (1 << NF_IP_POST_ROUTING),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -128,6 +141,9 @@ static struct xt_target xt_secmark_targe
 		.target		= target,
 		.targetsize	= sizeof(struct xt_secmark_target_info),
 		.table		= "mangle",
+		.hooks		= (1 << NF_IP6_LOCAL_IN) |
+				  (1 << NF_IP6_FORWARD) |
+				  (1 << NF_IP6_POST_ROUTING),
 		.me		= THIS_MODULE,
 	},
 };
