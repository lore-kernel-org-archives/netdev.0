From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 17/19] ndisc: Break down __ndisc_send().
Date: Tue, 22 Jan 2013 01:49:13 +0900
Message-ID: <50FD7189.9070206@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50379 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752592Ab3AUQtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:49:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   45 +++++++++++++++++++++------------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index dda4add..79a56a7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -503,29 +503,12 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	rcu_read_unlock();
 }
 
-/*
- *	Send a Neighbour Discover packet
- */
-static void __ndisc_send(struct net_device *dev,
-			 const struct in6_addr *daddr,
-			 const struct in6_addr *saddr,
-			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
-			 int llinfo)
-{
-	struct sk_buff *skb;
-
-	skb = ndisc_build_skb(dev, daddr, saddr, icmp6h, target, llinfo);
-	if (!skb)
-		return;
-
-	ndisc_send_skb(skb, daddr, saddr);
-}
-
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 			  const struct in6_addr *daddr,
 			  const struct in6_addr *solicited_addr,
 			  bool router, bool solicited, bool override, bool inc_opt)
 {
+	struct sk_buff *skb;
 	struct in6_addr tmpaddr;
 	struct inet6_ifaddr *ifp;
 	const struct in6_addr *src_addr;
@@ -553,8 +536,12 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	__ndisc_send(dev, daddr, src_addr, &icmp6h, solicited_addr,
-		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	skb = ndisc_build_skb(dev, daddr, src_addr, &icmp6h, solicited_addr,
+			      inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	if (!skb)
+		return;
+
+	ndisc_send_skb(skb, daddr, src_addr);
 }
 
 static void ndisc_send_unsol_na(struct net_device *dev)
@@ -582,6 +569,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		   const struct in6_addr *solicit,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr)
 {
+	struct sk_buff *skb;
 	struct in6_addr addr_buf;
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
@@ -594,13 +582,18 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	__ndisc_send(dev, daddr, saddr, &icmp6h, solicit,
-		     !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	skb = ndisc_build_skb(dev, daddr, saddr, &icmp6h, solicit,
+			      !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (!skb)
+		return;
+
+	ndisc_send_skb(skb, daddr, saddr);
 }
 
 void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		   const struct in6_addr *daddr)
 {
+	struct sk_buff *skb;
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_ROUTER_SOLICITATION,
 	};
@@ -628,8 +621,12 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	__ndisc_send(dev, daddr, saddr, &icmp6h, NULL,
-		     send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	skb = ndisc_build_skb(dev, daddr, saddr, &icmp6h, NULL,
+			      send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	if (!skb)
+		return;
+
+	ndisc_send_skb(skb, daddr, saddr);
 }
 
 
-- 
1.7.9.5
