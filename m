From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 15/17] ndisc: Break down ndisc_build_skb().
Date: Tue, 18 Dec 2012 19:56:16 +0900
Message-ID: <50D04BD0.7050407@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56642 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754707Ab2LRK4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:56:18 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split up ndisc_build_skb() into pieces; sk_buff allocation
by ndisc_allocl_skb(), filling out the core message and
options.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   98 ++++++++++++++++++++++++++----------------------------
 1 file changed, 48 insertions(+), 50 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c974d9d..580a2f0 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -410,47 +410,6 @@ static void ip6_nd_hdr(struct sk_buff *skb, const struct in6_addr *saddr,
 	hdr->payload_len = htons(len);
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
 static void __ndisc_send(struct sk_buff *skb, struct dst_entry *dst,
 			 const struct in6_addr *daddr,
 			 const struct in6_addr *saddr)
@@ -521,6 +480,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
 	};
+	struct nd_msg *msg;
+	int optlen = 0;
 	struct sk_buff *skb;
 
 	/* for anycast or proxy, solicited_addr != src_addr */
@@ -539,16 +500,27 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		src_addr = &tmpaddr;
 	}
 
+	if (!dev->addr_len)
+		inc_opt = 0;
+	if (inc_opt)
+		optlen += ndisc_opt_addr_space(dev);
+
 	icmp6h.icmp6_router = router;
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	skb = ndisc_build_skb(dev, daddr, src_addr,
-			      &icmp6h, solicited_addr,
-			      inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	skb = ndisc_alloc_skb(dev, sizeof(struct nd_msg) + optlen);
 	if (!skb)
 		return;
 
+	msg = (struct nd_msg *)__skb_put(skb, sizeof(struct nd_msg));
+	memcpy(msg, &icmp6h, sizeof(icmp6h));
+	msg->target = *solicited_addr;
+
+	if (inc_opt)
+		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
+				       dev->dev_addr);
+
 	ndisc_send(skb, neigh, daddr, src_addr);
 }
 
@@ -581,6 +553,9 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
 	};
+	struct nd_msg *msg;
+	int inc_opt = dev->addr_len;
+	int optlen = 0;
 	struct sk_buff *skb;
 
 	if (saddr == NULL) {
@@ -590,12 +565,23 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	skb = ndisc_build_skb(dev, daddr, saddr,
-			      &icmp6h, solicit,
-			      !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (ipv6_addr_any(saddr))
+		inc_opt = 0;
+	if (inc_opt)
+		optlen += ndisc_opt_addr_space(dev);
+
+	skb = ndisc_alloc_skb(dev, sizeof(struct nd_msg) + optlen);
 	if (!skb)
 		return;
 
+	msg = (struct nd_msg *)__skb_put(skb, sizeof(struct nd_msg));
+	memcpy(&msg->icmph, &icmp6h, sizeof(msg->icmph));
+	msg->target = *solicit;
+
+	if (inc_opt)
+		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
+				       dev->dev_addr);
+
 	ndisc_send(skb, neigh, daddr, saddr);
 }
 
@@ -605,7 +591,9 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_ROUTER_SOLICITATION,
 	};
+	struct rs_msg *msg;
 	int send_sllao = dev->addr_len;
+	int optlen = 0;
 	struct sk_buff *skb;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
@@ -630,12 +618,22 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	skb = ndisc_build_skb(dev, daddr, saddr,
-			      &icmp6h, NULL,
-			      send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (!dev->addr_len)
+		send_sllao = 0;
+	if (send_sllao)
+		optlen += ndisc_opt_addr_space(dev);
+
+	skb = ndisc_alloc_skb(dev, sizeof(struct rs_msg) + optlen);
 	if (!skb)
 		return;
 
+	msg = (struct rs_msg *)__skb_put(skb, sizeof(struct rs_msg));
+	memcpy(&msg->icmph, &icmp6h, sizeof(msg->icmph));
+
+	if (send_sllao)
+		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
+				       dev->dev_addr);
+
 	ndisc_send(skb, NULL, daddr, saddr);
 }
 
-- 
1.7.9.5
