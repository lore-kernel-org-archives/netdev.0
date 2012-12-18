From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 16/17] ndisc: Fill in ND message on skb directly.
Date: Tue, 18 Dec 2012 19:56:22 +0900
Message-ID: <50D04BD6.6020802@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56644 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754524Ab2LRK4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:56:23 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use compound literals to fill out ND message on skb.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   55 +++++++++++++++++++++++++++---------------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 580a2f0..e614388 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -477,9 +477,6 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	struct in6_addr tmpaddr;
 	struct inet6_ifaddr *ifp;
 	const struct in6_addr *src_addr;
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
-	};
 	struct nd_msg *msg;
 	int optlen = 0;
 	struct sk_buff *skb;
@@ -505,17 +502,20 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	if (inc_opt)
 		optlen += ndisc_opt_addr_space(dev);
 
-	icmp6h.icmp6_router = router;
-	icmp6h.icmp6_solicited = solicited;
-	icmp6h.icmp6_override = override;
-
 	skb = ndisc_alloc_skb(dev, sizeof(struct nd_msg) + optlen);
 	if (!skb)
 		return;
 
 	msg = (struct nd_msg *)__skb_put(skb, sizeof(struct nd_msg));
-	memcpy(msg, &icmp6h, sizeof(icmp6h));
-	msg->target = *solicited_addr;
+	*msg = (struct nd_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
+			.icmp6_router = router,
+			.icmp6_solicited = solicited,
+			.icmp6_override = override,
+		},
+		.target = *solicited_addr,
+	};
 
 	if (inc_opt)
 		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
@@ -550,9 +550,6 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr)
 {
 	struct in6_addr addr_buf;
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
-	};
 	struct nd_msg *msg;
 	int inc_opt = dev->addr_len;
 	int optlen = 0;
@@ -575,8 +572,12 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		return;
 
 	msg = (struct nd_msg *)__skb_put(skb, sizeof(struct nd_msg));
-	memcpy(&msg->icmph, &icmp6h, sizeof(msg->icmph));
-	msg->target = *solicit;
+	*msg = (struct nd_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
+		},
+		.target = *solicit,
+	};
 
 	if (inc_opt)
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
@@ -588,9 +589,6 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		   const struct in6_addr *daddr)
 {
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_ROUTER_SOLICITATION,
-	};
 	struct rs_msg *msg;
 	int send_sllao = dev->addr_len;
 	int optlen = 0;
@@ -628,7 +626,11 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		return;
 
 	msg = (struct rs_msg *)__skb_put(skb, sizeof(struct rs_msg));
-	memcpy(&msg->icmph, &icmp6h, sizeof(msg->icmph));
+	*msg = (struct rs_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_ROUTER_SOLICITATION,
+		},
+	};
 
 	if (send_sllao)
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
@@ -1469,16 +1471,13 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	skb_put(buff, sizeof(struct red_msg));
 	msg = (struct red_msg *)icmp6_hdr(buff);
-
-	memset(&msg->icmph, 0, sizeof(struct icmp6hdr));
-	msg->icmph.icmp6_type = NDISC_REDIRECT;
-
-	/*
-	 *	copy target and destination addresses
-	 */
-
-	msg->target = *target;
-	msg->dest = ipv6_hdr(skb)->daddr;
+	*msg = (struct red_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_REDIRECT,
+		},
+		.target = *target,
+		.dest = ipv6_hdr(skb)->daddr,
+	};
 
 	/*
 	 *	include target_address option
-- 
1.7.9.5
