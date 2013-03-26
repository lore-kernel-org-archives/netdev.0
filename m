From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v4 net-next 4/5] VXLAN: Use IP Tunnels tunnel ENC encap API
Date: Mon, 25 Mar 2013 17:49:53 -0700
Message-ID: <1364258993-3272-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog032.obsmtp.com ([74.125.150.106]:43699 "HELO
	na6sys009bog032.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932340Ab3CZAzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 20:55:14 -0400
Received: by mail-da0-f69.google.com with SMTP id j17so6903220dan.0
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 17:55:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use common ecn_encap functions from ip_tunnel module.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e532b2a..7624ab1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -864,28 +864,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-/* Extract dsfield from inner protocol */
-static inline u8 vxlan_get_dsfield(const struct iphdr *iph,
-				   const struct sk_buff *skb)
-{
-	if (skb->protocol == htons(ETH_P_IP))
-		return iph->tos;
-	else if (skb->protocol == htons(ETH_P_IPV6))
-		return ipv6_get_dsfield((const struct ipv6hdr *)iph);
-	else
-		return 0;
-}
-
-/* Propogate ECN bits out */
-static inline u8 vxlan_ecn_encap(u8 tos,
-				 const struct iphdr *iph,
-				 const struct sk_buff *skb)
-{
-	u8 inner = vxlan_get_dsfield(iph, skb);
-
-	return INET_ECN_encapsulate(tos, inner);
-}
-
 static void vxlan_sock_free(struct sk_buff *skb)
 {
 	sock_put(skb->sk);
@@ -996,7 +974,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	tos = vxlan->tos;
 	if (tos == 1)
-		tos = vxlan_get_dsfield(old_iph, skb);
+		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
 	src_port = vxlan_src_port(vxlan, skb);
 
@@ -1047,7 +1025,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	iph->ihl	= sizeof(struct iphdr) >> 2;
 	iph->frag_off	= df;
 	iph->protocol	= IPPROTO_UDP;
-	iph->tos	= vxlan_ecn_encap(tos, old_iph, skb);
+	iph->tos	= ip_tunnel_ecn_encap(tos, old_iph, skb);
 	iph->daddr	= dst;
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
-- 
1.7.1
