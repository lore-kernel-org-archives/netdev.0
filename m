From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipv4 tunnels: fix an oops when using ipip/sit with IPsec
Date: Wed, 28 Aug 2013 11:54:50 +0200
Message-ID: <1377683690-4506-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@nicira.com, hongjun.li@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37320 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab3H1JzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 05:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Hongjun <hongjun.li@6wind.com>

Since commit 3d7b46cd20e3 (ip_tunnel: push generic protocol handling to
ip_tunnel module.), an Oops is triggered when an xfrm policy is configured on
an IPv4 over IPv4 tunnel.

xfrm4_policy_check() calls __xfrm_policy_check2(), which uses skb_dst(skb). But
this field is NULL because iptunnel_pull_header() calls skb_dst_drop(skb).

Signed-off-by: Li Hongjun <hongjun.li@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipip.c | 5 ++---
 net/ipv6/sit.c  | 6 ++----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 51fc2a1dcdd3..b3ac3c3f6219 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -190,15 +190,14 @@ static int ipip_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph;
 
-	if (iptunnel_pull_header(skb, 0, tpi.proto))
-		goto drop;
-
 	iph = ip_hdr(skb);
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 			iph->saddr, iph->daddr, 0);
 	if (tunnel) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
+		if (iptunnel_pull_header(skb, 0, tpi.proto))
+			goto drop;
 		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
 	}
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a3437a4cd07e..1e6a81d0c897 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -645,11 +645,7 @@ static int ipip_rcv(struct sk_buff *skb)
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
 
-	if (iptunnel_pull_header(skb, 0, tpi.proto))
-		goto drop;
-
 	iph = ip_hdr(skb);
-
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
@@ -659,6 +655,8 @@ static int ipip_rcv(struct sk_buff *skb)
 
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
+		if (iptunnel_pull_header(skb, 0, tpi.proto))
+			goto drop;
 		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
 	}
 
-- 
1.8.2.1
