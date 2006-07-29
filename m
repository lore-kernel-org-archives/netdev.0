From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 4/20] [PATCH] [IPV6] MIP6: Add inbound interface of routing header type 2.
Date: Sat, 29 Jul 2006 18:38:22 +0900
Message-ID: <11541659023402-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:38531 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422711AbWG2JiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:23 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add inbound interface of routing header type 2 for Mobile IPv6.
Based on MIPL2 kernel patch.
---
 include/net/addrconf.h |    7 +++++
 net/ipv6/exthdrs.c     |   71 +++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 70 insertions(+), 8 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 750e250..71fc890 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -62,6 +62,13 @@ extern int			addrconf_set_dstaddr(void _
 extern int			ipv6_chk_addr(struct in6_addr *addr,
 					      struct net_device *dev,
 					      int strict);
+/* XXX: this is a placeholder till addrconf supports */
+#ifdef CONFIG_IPV6_MIP6
+static inline int ipv6_chk_home_addr(struct in6_addr *addr)
+{
+	return 0;
+}
+#endif
 extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
 						struct net_device *dev,
 						int strict);
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a18d425..138cb12 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -43,6 +43,9 @@ #include <net/rawv6.h>
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
+#ifdef CONFIG_IPV6_MIP6
+#include <net/xfrm.h>
+#endif
 
 #include <asm/uaccess.h>
 
@@ -219,7 +222,7 @@ static int ipv6_rthdr_rcv(struct sk_buff
 {
 	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
-	struct in6_addr *addr;
+	struct in6_addr *addr = NULL;
 	struct in6_addr daddr;
 	int n, i;
 
@@ -244,6 +247,23 @@ static int ipv6_rthdr_rcv(struct sk_buff
 
 looped_back:
 	if (hdr->segments_left == 0) {
+		switch (hdr->type) {
+#ifdef CONFIG_IPV6_MIP6
+		case IPV6_SRCRT_TYPE_2:
+			/* Silently discard type 2 header unless it was
+			 * processed by own
+			 */
+			if (!addr) {
+				IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+				kfree_skb(skb);
+				return -1;
+			}
+			break;
+#endif
+		default:
+			break;
+		}
+
 		opt->lastopt = skb->h.raw - skb->nh.raw;
 		opt->srcrt = skb->h.raw - skb->nh.raw;
 		skb->h.raw += (hdr->hdrlen + 1) << 3;
@@ -253,17 +273,29 @@ looped_back:
 		return 1;
 	}
 
-	if (hdr->type != IPV6_SRCRT_TYPE_0) {
+	switch (hdr->type) {
+	case IPV6_SRCRT_TYPE_0:
+		if (hdr->hdrlen & 0x01) {
+			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->hdrlen) - skb->nh.raw);
+			return -1;
+		}
+		break;
+#ifdef CONFIG_IPV6_MIP6
+	case IPV6_SRCRT_TYPE_2:
+		/* Silently discard invalid RTH type 2 */
+		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
+			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			kfree_skb(skb);
+			return -1;
+		}
+		break;
+#endif
+	default:
 		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->type) - skb->nh.raw);
 		return -1;
 	}
-	
-	if (hdr->hdrlen & 0x01) {
-		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
-		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->hdrlen) - skb->nh.raw);
-		return -1;
-	}
 
 	/*
 	 *	This is the routing header forwarding algorithm from
@@ -303,6 +335,29 @@ looped_back:
 	addr = rthdr->addr;
 	addr += i - 1;
 
+	switch (hdr->type) {
+#ifdef CONFIG_IPV6_MIP6
+	case IPV6_SRCRT_TYPE_2:
+		if (__xfrm6_rcv_one(skb,
+				    (xfrm_address_t *)addr,
+				    (xfrm_address_t *)&skb->nh.ipv6h->saddr,
+				    IPPROTO_ROUTING) < 0) {
+			IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+			kfree_skb(skb);
+			return -1;
+		}
+
+		if (!ipv6_chk_home_addr(addr)) {
+			IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+			kfree_skb(skb);
+			return -1;
+		}
+		break;
+#endif
+	default:
+		break;
+	}
+
 	if (ipv6_addr_is_multicast(addr)) {
 		IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
-- 
1.4.1

