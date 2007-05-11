From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] [IPV6]: Restore semantics of Routing Header
 processing.
Date: Sat, 12 May 2007 01:17:18 +0900 (JST)
Message-ID: <20070512.011718.121506964.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37569 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758978AbXEKQRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 12:17:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "fix" for emerging security threats was overkill and it broke
basic semantic of IPv6 routing header processing.  We should assume
RT0 (or even RT2, depends on configuration) as "unknown" RH type so
that we
- silently ignore the routing header if segleft == 0,
- or, send ICMPv6 Parameter Problem message back to the sender,
  otherwise.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/exthdrs.c |   47 ++++++++++++++++-------------------------------
 1 files changed, 16 insertions(+), 31 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 14be0b9..05e9bb5 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -371,22 +371,13 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
 	struct rt0_hdr *rthdr;
 	int accept_source_route = ipv6_devconf.accept_source_route;
 
-	if (accept_source_route < 0 ||
-	    ((idev = in6_dev_get(skb->dev)) == NULL)) {
-		kfree_skb(skb);
-		return -1;
-	}
-	if (idev->cnf.accept_source_route < 0) {
+	idev = in6_dev_get(skb->dev);
+	if (idev) {
+		if (accept_source_route > idev->cnf.accept_source_route)
+			accept_source_route = idev->cnf.accept_source_route;
 		in6_dev_put(idev);
-		kfree_skb(skb);
-		return -1;
 	}
 
-	if (accept_source_route > idev->cnf.accept_source_route)
-		accept_source_route = idev->cnf.accept_source_route;
-
-	in6_dev_put(idev);
-
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
@@ -398,24 +389,6 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
 
 	hdr = (struct ipv6_rt_hdr *)skb_transport_header(skb);
 
-	switch (hdr->type) {
-#ifdef CONFIG_IPV6_MIP6
-	case IPV6_SRCRT_TYPE_2:
-		break;
-#endif
-	case IPV6_SRCRT_TYPE_0:
-		if (accept_source_route > 0)
-			break;
-		kfree_skb(skb);
-		return -1;
-	default:
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
-				 IPSTATS_MIB_INHDRERRORS);
-		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
-				  (&hdr->type) - skb_network_header(skb));
-		return -1;
-	}
-
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
 		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
@@ -454,6 +427,8 @@ looped_back:
 
 	switch (hdr->type) {
 	case IPV6_SRCRT_TYPE_0:
+		if (accept_source_route <= 0)
+			goto unknown_rh;
 		if (hdr->hdrlen & 0x01) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INHDRERRORS);
@@ -465,6 +440,8 @@ looped_back:
 		break;
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SRCRT_TYPE_2:
+		if (accept_source_route < 0)
+			goto unknown_rh;
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
@@ -474,6 +451,8 @@ looped_back:
 		}
 		break;
 #endif
+	default:
+		goto unknown_rh;
 	}
 
 	/*
@@ -577,6 +556,12 @@ looped_back:
 	skb_push(skb, skb->data - skb_network_header(skb));
 	dst_input(skb);
 	return -1;
+
+unknown_rh:
+	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
+			  (&hdr->type) - skb_network_header(skb));
+	return -1;
 }
 
 static struct inet6_protocol rthdr_protocol = {
-- 
1.5.1

