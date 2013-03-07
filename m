From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/4] VXLAN: Use UDP Tunnel segmention.
Date: Thu,  7 Mar 2013 15:22:36 -0800
Message-ID: <1362698556-2510-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:35897 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757597Ab3CGXVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 18:21:12 -0500
Received: by mail-qe0-f70.google.com with SMTP id a11so1832720qen.5
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 15:21:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable TSO for VXLAN devices and use UDP_TUNNEL to offload vxlan
segmentation.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f10e58a..f057ec0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -820,6 +820,20 @@ static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
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
@@ -963,9 +977,8 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	vxlan_set_owner(dev, skb);
 
-	/* See iptunnel_xmit() */
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		skb->ip_summed = CHECKSUM_NONE;
+	if (handle_offloads(skb))
+		goto drop;
 
 	err = ip_local_out(skb);
 	if (likely(net_xmit_eval(err) == 0)) {
@@ -1187,8 +1200,10 @@ static void vxlan_setup(struct net_device *dev)
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
