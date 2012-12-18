From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 14/17] ndisc: Concentrate ndisc_send() on sending
 message.
Date: Tue, 18 Dec 2012 19:56:10 +0900
Message-ID: <50D04BCA.8020703@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56638 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754707Ab2LRK4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:56:11 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Build NDISC message outside ndisc_send() and concentrate the
function sending sk_buff with given destination/source.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   51 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c0937d3..c974d9d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -488,26 +488,20 @@ static void __ndisc_send(struct sk_buff *skb, struct dst_entry *dst,
 /*
  *	Send a Neighbour Discover packet
  */
-static void ndisc_send(struct net_device *dev,
+static void ndisc_send(struct sk_buff *skb,
 		       struct neighbour *neigh,
 		       const struct in6_addr *daddr,
-		       const struct in6_addr *saddr,
-		       struct icmp6hdr *icmp6h, const struct in6_addr *target,
-		       int llinfo)
+		       const struct in6_addr *saddr)
 {
 	struct flowi6 fl6;
 	struct dst_entry *dst;
-	struct net *net = dev_net(dev);
+	struct net *net = dev_net(skb->dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
-	struct sk_buff *skb;
+	struct icmp6hdr *icmp6h = icmp6_hdr(skb);
 	u8 type = icmp6h->icmp6_type;
 
-	skb = ndisc_build_skb(dev, daddr, saddr, icmp6h, target, llinfo);
-	if (!skb)
-		return;
-
-	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
-	dst = icmp6_dst_alloc(dev, neigh, &fl6);
+	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
+	dst = icmp6_dst_alloc(skb->dev, neigh, &fl6);
 	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
@@ -527,6 +521,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
 	};
+	struct sk_buff *skb;
 
 	/* for anycast or proxy, solicited_addr != src_addr */
 	ifp = ipv6_get_ifaddr(dev_net(dev), solicited_addr, dev, 1);
@@ -548,9 +543,13 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	ndisc_send(dev, neigh, daddr, src_addr,
-		   &icmp6h, solicited_addr,
-		   inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	skb = ndisc_build_skb(dev, daddr, src_addr,
+			      &icmp6h, solicited_addr,
+			      inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	if (!skb)
+		return;
+
+	ndisc_send(skb, neigh, daddr, src_addr);
 }
 
 static void ndisc_send_unsol_na(struct net_device *dev)
@@ -582,6 +581,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
 	};
+	struct sk_buff *skb;
 
 	if (saddr == NULL) {
 		if (ipv6_get_lladdr(dev, &addr_buf,
@@ -590,9 +590,13 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	ndisc_send(dev, neigh, daddr, saddr,
-		   &icmp6h, solicit,
-		   !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	skb = ndisc_build_skb(dev, daddr, saddr,
+			      &icmp6h, solicit,
+			      !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (!skb)
+		return;
+
+	ndisc_send(skb, neigh, daddr, saddr);
 }
 
 void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
@@ -602,6 +606,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		.icmp6_type = NDISC_ROUTER_SOLICITATION,
 	};
 	int send_sllao = dev->addr_len;
+	struct sk_buff *skb;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	/*
@@ -625,9 +630,13 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	ndisc_send(dev, NULL, daddr, saddr,
-		   &icmp6h, NULL,
-		   send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	skb = ndisc_build_skb(dev, daddr, saddr,
+			      &icmp6h, NULL,
+			      send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (!skb)
+		return;
+
+	ndisc_send(skb, NULL, daddr, saddr);
 }
 
 
-- 
1.7.9.5
