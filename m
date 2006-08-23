From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 20/44] [IPV6] MIP6: Add inbound interface of routing header type 2.
Date: Thu, 24 Aug 2006 00:02:21 +0900
Message-ID: <11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:3721 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964932AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <1156345366676-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add inbound interface of routing header type 2 for Mobile IPv6.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/addrconf.h |    7 +++++
 net/ipv6/exthdrs.c     |   69 ++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 68 insertions(+), 8 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 3d71251..5fc8627 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -61,6 +61,13 @@ extern int			addrconf_set_dstaddr(void _
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
index fe3f737..8d4af75 100644
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
@@ -303,6 +335,27 @@ looped_back:
 	addr = rthdr->addr;
 	addr += i - 1;
 
+	switch (hdr->type) {
+#ifdef CONFIG_IPV6_MIP6
+	case IPV6_SRCRT_TYPE_2:
+		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
+				     (xfrm_address_t *)&skb->nh.ipv6h->saddr,
+				     IPPROTO_ROUTING) < 0) {
+			IP6_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+			kfree_skb(skb);
+			return -1;
+		}
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
1.4.0

