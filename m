From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/4] VXLAN: Use UDP Tunnel segmention.
Date: Fri, 15 Feb 2013 17:06:20 -0800
Message-ID: <1360976780-1924-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:45283 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750797Ab3BPBEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:04:38 -0500
Received: by mail-gh0-f197.google.com with SMTP id f15so1535511ghb.8
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:04:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable TSO for VXLAN devices and use UDP_TUNNEL offload support.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9d70421..61b7cd0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -823,6 +823,20 @@ static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 	return (((u64) hash * range) >> 32) + vxlan->port_min;
 }
 
+static int handle_offloads(struct sk_buff *skb)
+{
+	if (skb_is_gso(skb)) {
+		int err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			return err;
+
+		skb_shinfo(skb)->gso_type |= (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP);
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	return 0;
+}
+
 /* Transmit local packets over Vxlan
  *
  * Outer IP header inherits ECN and DF from inner header.
@@ -962,13 +976,12 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	iph->daddr	= dst;
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
+	ip_select_ident(iph, &rt->dst, NULL);
 
 	vxlan_set_owner(dev, skb);
 
-	/* See iptunnel_xmit() */
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(iph, &rt->dst, NULL);
+	if (handle_offloads(skb))
+		goto drop;
 
 	err = ip_local_out(skb);
 	if (likely(net_xmit_eval(err) == 0)) {
@@ -1190,8 +1203,10 @@ static void vxlan_setup(struct net_device *dev)
 	dev->features	|= NETIF_F_NETNS_LOCAL;
 	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features   |= NETIF_F_RXCSUM;
+	dev->features   |= NETIF_F_GSO_SOFTWARE;
 
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
+	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
-- 
1.7.1
