From: shemminger@osdl.org
Subject: [PATCH 3/4] bridge-netfilter: simplify nf_bridge_pad
Date: Tue, 22 Aug 2006 17:10:53 -0700
Message-ID: <20060823001231.148789000@localhost.localdomain>
References: <20060823001050.363374000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37598 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750971AbWHWATW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 20:19:22 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=br-nf-pad.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do some simple optimization on the nf_bridge_pad() function
and don't use magic constants. Eliminate a double call and
the #ifdef'd code for CONFIG_BRIDGE_NETFILTER.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br-nf.orig/include/linux/netfilter_bridge.h	2006-08-22 16:46:47.000000000 -0700
+++ br-nf/include/linux/netfilter_bridge.h	2006-08-22 16:52:25.000000000 -0700
@@ -5,9 +5,8 @@
  */
 
 #include <linux/netfilter.h>
-#if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
 #include <linux/if_ether.h>
-#endif
+#include <linux/if_vlan.h>
 
 /* Bridge Hooks */
 /* After promisc drops, checksum checks. */
@@ -57,16 +56,10 @@
 
 /* This is called by the IP fragmenting code and it ensures there is
  * enough room for the encapsulating header (if there is one). */
-static inline
-int nf_bridge_pad(struct sk_buff *skb)
+static inline int nf_bridge_pad(const struct sk_buff *skb)
 {
-	if (skb->protocol == __constant_htons(ETH_P_IP))
-		return 0;
-	if (skb->nf_bridge) {
-		if (skb->protocol == __constant_htons(ETH_P_8021Q))
-			return 4;
-	}
-	return 0;
+ 	return (skb->nf_bridge && skb->protocol == htons(ETH_P_8021Q))
+		? VLAN_HLEN : 0;
 }
 
 struct bridge_skb_cb {
@@ -78,6 +71,7 @@
 extern int brnf_deferred_hooks;
 #else
 #define nf_bridge_maybe_copy_header(skb)	(0)
+#define nf_bridge_pad(skb)			(0)
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
 #endif /* __KERNEL__ */
--- br-nf.orig/net/ipv4/ip_output.c	2006-08-22 16:43:41.000000000 -0700
+++ br-nf/net/ipv4/ip_output.c	2006-08-22 16:51:22.000000000 -0700
@@ -425,7 +425,7 @@
 	int ptr;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len, ll_rs;
+	unsigned int mtu, hlen, left, len, ll_rs, pad;
 	int offset;
 	__be16 not_last_frag;
 	struct rtable *rt = (struct rtable*)skb->dst;
@@ -554,14 +554,13 @@
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = raw + hlen;		/* Where to start from */
 
-#ifdef CONFIG_BRIDGE_NETFILTER
 	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
-	 * we need to make room for the encapsulating header */
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->u.dst.dev, nf_bridge_pad(skb));
-	mtu -= nf_bridge_pad(skb);
-#else
-	ll_rs = LL_RESERVED_SPACE(rt->u.dst.dev);
-#endif
+	 * we need to make room for the encapsulating header
+	 */
+	pad = nf_bridge_pad(skb);
+	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->u.dst.dev, pad);
+	mtu -= pad;
+
 	/*
 	 *	Fragment the datagram.
 	 */

--


