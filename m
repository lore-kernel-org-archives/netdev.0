From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 4/5] VXLAN: Use IP Tunnels tunnel ENC encap API
Date: Tue, 19 Mar 2013 01:10:27 -0700
Message-ID: <1363680627-1847-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:53892 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934194Ab3CSIKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 04:10:46 -0400
Received: by mail-pb0-f72.google.com with SMTP id wz12so303333pbc.7
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 01:10:46 -0700 (PDT)
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
