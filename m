From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 13/13] TProxy: use the interface primary IP address as a
 default value for --on-ip
Date: Mon, 21 Sep 2009 16:46:40 +0200
Message-ID: <1253548005.12519.13.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58369 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751208AbZIUQY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 12:24:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The REDIRECT target and the older TProxy versions used the primary address
of the incoming interface as the default value of the --on-ip parameter.
This was unintentionally changed during the initial TProxy submission and
caused confusion among users.

This is implemented for both IPv4 and IPv6.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 net/netfilter/xt_TPROXY.c |   63 ++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 56 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 4a345cd..b99e2b5 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -16,15 +16,41 @@
 #include <net/checksum.h>
 #include <net/udp.h>
 #include <net/inet_sock.h>
-
+#include <linux/inetdevice.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter/xt_TPROXY.h>
 
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <net/if_inet6.h>
+#include <net/addrconf.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+#endif
+
 #include <net/netfilter/nf_tproxy_core.h>
+#include <linux/netfilter/xt_TPROXY.h>
+
+static inline __be32
+tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
+{
+	struct in_device *indev;
+	__be32 laddr;
+	
+        if (user_laddr)
+                return user_laddr;
+	
+        laddr = 0;
+        rcu_read_lock();
+        indev = __in_dev_get_rcu(skb->dev);
+        for_primary_ifa(indev) {
+		laddr = ifa->ifa_local;
+                break;
+        } endfor_ifa(indev);
+        rcu_read_unlock();
+        
+        return laddr ? laddr : daddr;
+}
 
 static unsigned int
 tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport, u_int32_t mark_mask, u_int32_t mark_value)
@@ -63,7 +89,7 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport, u_int32_t mark_mask,
 			 * there's a listener on the redirected port
 			 */
 			sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-						    iph->saddr, laddr ? laddr : iph->daddr,
+						    iph->saddr, tproxy_laddr4(skb, laddr, iph->daddr),
 						    hp->source, lport ? lport : hp->dest,
 						    skb->dev, NFT_LOOKUP_LISTENER);
 			if (sk2) {
@@ -80,7 +106,7 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport, u_int32_t mark_mask,
 		/* no there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
 		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-					   iph->saddr, laddr ? laddr : iph->daddr,
+					   iph->saddr, tproxy_laddr4(skb, laddr, iph->daddr),
 					   hp->source, lport ? lport : hp->dest,
 					   skb->dev, NFT_LOOKUP_LISTENER);
 	}
@@ -119,6 +145,29 @@ tproxy_tg4_v1(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+static inline const struct in6_addr *
+tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr, const struct in6_addr *daddr)
+{
+	struct inet6_dev *indev;
+	struct inet6_ifaddr *ifa;
+	struct in6_addr *laddr;
+	
+        if (!ipv6_addr_any(user_laddr))
+                return user_laddr;
+	
+        laddr = NULL;
+        rcu_read_lock();
+        indev = __in6_dev_get(skb->dev);
+        if (indev && (ifa = indev->addr_list)) {
+		laddr = &ifa->addr;
+	}
+        rcu_read_unlock();
+        
+        return laddr ? laddr : daddr;
+}
+
+
 static unsigned int
 tproxy_tg6_v1(struct sk_buff *skb, const struct xt_target_param *par)
 {
@@ -168,7 +217,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_target_param *par)
 			 * there's a listener on the redirected port
 			 */
 			sk2 = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
-						    &iph->saddr, !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
+						    &iph->saddr, tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr),
 						    hp->source, tgi->lport ? tgi->lport : hp->dest,
 						    par->in, NFT_LOOKUP_LISTENER);
 			if (sk2) {
@@ -185,7 +234,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_target_param *par)
 		/* no there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
 		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
-					   &iph->saddr, !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
+					   &iph->saddr, tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr),
 					   hp->source, tgi->lport ? tgi->lport : hp->dest,
 					   par->in, NFT_LOOKUP_LISTENER);
 	}
-- 
1.6.0.4

