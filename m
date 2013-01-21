From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 18/19] ndisc: Break down ndisc_build_skb() and build
 message directly.
Date: Tue, 22 Jan 2013 01:49:17 +0900
Message-ID: <50FD718D.2080709@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50383 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753780Ab3AUQtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:49:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Construct NS/NA/RS message directly using C99 compound literals.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |  122 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 63 insertions(+), 59 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 79a56a7..1c01566 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -413,47 +413,6 @@ static void ip6_nd_hdr(struct sk_buff *skb,
 	hdr->daddr = *daddr;
 }
 
-static struct sk_buff *ndisc_build_skb(struct net_device *dev,
-				       const struct in6_addr *daddr,
-				       const struct in6_addr *saddr,
-				       struct icmp6hdr *icmp6h,
-				       const struct in6_addr *target,
-				       int llinfo)
-{
-	struct sk_buff *skb;
-	struct icmp6hdr *hdr;
-	int len;
-	int optlen = 0;
-	u8 *opt;
-
-	if (!dev->addr_len)
-		llinfo = 0;
-
-	len = sizeof(struct icmp6hdr) + (target ? sizeof(*target) : 0);
-	if (llinfo)
-		optlen += ndisc_opt_addr_space(dev);
-
-	skb = ndisc_alloc_skb(dev, len + optlen);
-	if (!skb)
-		return NULL;
-
-	skb_put(skb, len);
-
-	hdr = (struct icmp6hdr *)skb_transport_header(skb);
-	memcpy(hdr, icmp6h, sizeof(*hdr));
-
-	opt = skb_transport_header(skb) + sizeof(struct icmp6hdr);
-	if (target) {
-		*(struct in6_addr *)opt = *target;
-		opt += sizeof(*target);
-	}
-
-	if (llinfo)
-		ndisc_fill_addr_option(skb, llinfo, dev->dev_addr);
-
-	return skb;
-}
-
 static void ndisc_send_skb(struct sk_buff *skb,
 			   const struct in6_addr *daddr,
 			   const struct in6_addr *saddr)
@@ -512,9 +471,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	struct in6_addr tmpaddr;
 	struct inet6_ifaddr *ifp;
 	const struct in6_addr *src_addr;
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
-	};
+	struct nd_msg *msg;
+	int optlen = 0;
 
 	/* for anycast or proxy, solicited_addr != src_addr */
 	ifp = ipv6_get_ifaddr(dev_net(dev), solicited_addr, dev, 1);
@@ -532,15 +490,31 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		src_addr = &tmpaddr;
 	}
 
-	icmp6h.icmp6_router = router;
-	icmp6h.icmp6_solicited = solicited;
-	icmp6h.icmp6_override = override;
+	if (!dev->addr_len)
+		inc_opt = 0;
+	if (inc_opt)
+		optlen += ndisc_opt_addr_space(dev);
 
-	skb = ndisc_build_skb(dev, daddr, src_addr, &icmp6h, solicited_addr,
-			      inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
 		return;
 
+	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	*msg = (struct nd_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
+			.icmp6_router = router,
+			.icmp6_solicited = solicited,
+			.icmp6_override = override,
+		},
+		.target = *solicited_addr,
+	};
+
+	if (inc_opt)
+		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
+				       dev->dev_addr);
+
+
 	ndisc_send_skb(skb, daddr, src_addr);
 }
 
@@ -571,9 +545,9 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 {
 	struct sk_buff *skb;
 	struct in6_addr addr_buf;
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
-	};
+	int inc_opt = dev->addr_len;
+	int optlen = 0;
+	struct nd_msg *msg;
 
 	if (saddr == NULL) {
 		if (ipv6_get_lladdr(dev, &addr_buf,
@@ -582,11 +556,27 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	skb = ndisc_build_skb(dev, daddr, saddr, &icmp6h, solicit,
-			      !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (ipv6_addr_any(saddr))
+		inc_opt = 0;
+	if (inc_opt)
+		optlen += ndisc_opt_addr_space(dev);
+
+	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
 		return;
 
+	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	*msg = (struct nd_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
+		},
+		.target = *solicit,
+	};
+
+	if (inc_opt)
+		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
+				       dev->dev_addr);
+
 	ndisc_send_skb(skb, daddr, saddr);
 }
 
@@ -594,10 +584,9 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		   const struct in6_addr *daddr)
 {
 	struct sk_buff *skb;
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_ROUTER_SOLICITATION,
-	};
+	struct rs_msg *msg;
 	int send_sllao = dev->addr_len;
+	int optlen = 0;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	/*
@@ -621,11 +610,26 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	skb = ndisc_build_skb(dev, daddr, saddr, &icmp6h, NULL,
-			      send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (!dev->addr_len)
+		send_sllao = 0;
+	if (send_sllao)
+		optlen += ndisc_opt_addr_space(dev);
+
+	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
 		return;
 
+	msg = (struct rs_msg *)skb_put(skb, sizeof(*msg));
+	*msg = (struct rs_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_ROUTER_SOLICITATION,
+		},
+	};
+
+	if (send_sllao)
+		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
+				       dev->dev_addr);
+
 	ndisc_send_skb(skb, daddr, saddr);
 }
 
-- 
1.7.9.5
