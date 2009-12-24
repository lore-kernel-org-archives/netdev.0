From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
Subject: [PATCH 1/1] gianfar: Fix gianfar select_queue bogosity
Date: Thu, 24 Dec 2009 18:43:06 +0530
Message-ID: <1261660386814-git-send-email-sandeep.kumar@freescale.com>
Cc: davem@davemloft.net, yinghai@kernel.org, krkumar2@in.ibm.com,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: avorontsov@ru.mvista.com, galak@kernel.crashing.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:64195 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbZLXLc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 06:32:59 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBOBWwih012178
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 04:32:58 -0700 (MST)
Received: from udp153986uds.ap.freescale.net (udp153986uds.ap.freescale.net [10.232.134.194])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nBOBc6xi015550
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 05:38:12 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

The gfar_select_queue() function was used to set queue mapping
only for forwarding/bridging applications and the condition
for locally generated packets was completely ignored.

The solution is to remove the gfar_select_queue() function and
use skb_record_rx_queue to set queue mapping for
forwarding/bridging applications. This will ensure that in case of
forwarding/bridging applications txq = rxq will be selected and
skb_tx_hash will be used to pick up a txq for locally generated packets.

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---
 drivers/net/gianfar.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index e0620d0..8bd3c9f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -143,7 +143,6 @@ void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
@@ -455,7 +454,6 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_set_multicast_list = gfar_set_multi,
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
-	.ndo_select_queue = gfar_select_queue,
 	.ndo_get_stats = gfar_get_stats,
 	.ndo_vlan_rx_register = gfar_vlan_rx_register,
 	.ndo_set_mac_address = eth_mac_addr,
@@ -506,10 +504,6 @@ static inline int gfar_uses_fcb(struct gfar_private *priv)
 	return priv->vlgrp || priv->rx_csum_enable;
 }
 
-u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb)
-{
-	return skb_get_queue_mapping(skb);
-}
 static void free_tx_pointers(struct gfar_private *priv)
 {
 	int i = 0;
@@ -2470,10 +2464,11 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	fcb = (struct rxfcb *)skb->data;
 
 	/* Remove the FCB from the skb */
-	skb_set_queue_mapping(skb, fcb->rq);
 	/* Remove the padded bytes, if there are any */
-	if (amount_pull)
+	if (amount_pull) {
+		skb_record_rx_queue(skb, fcb->rq);
 		skb_pull(skb, amount_pull);
+	}
 
 	if (priv->rx_csum_enable)
 		gfar_rx_checksum(skb, fcb);
@@ -2554,7 +2549,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				/* Remove the FCS from the packet length */
 				skb_put(skb, pkt_len);
 				rx_queue->stats.rx_bytes += pkt_len;
-
+				skb_record_rx_queue(skb, rx_queue->qindex);
 				gfar_process_frame(dev, skb, amount_pull);
 
 			} else {
-- 
1.6.5.6

