From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 07/14] gianfar: Enable padding and Optimize the frame prepended bytes handling
Date: Tue, 16 Dec 2008 17:21:00 -0600
Message-ID: <1229469667-25002-8-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
 <1229469667-25002-7-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39701 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbYLPXVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:23 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNLA2d013566
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL9v4020499
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-7-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

The eTSEC can prepend up to 32 bytes to a received frame, usually for the
purpose of aligning the IP address to a word boundary, so this turns it on.

While we're in there, make the handling of the pre-frame bytes (padding and
Frame Control Block) cleaner.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   87 +++++++++++++++++++++++--------------------------
 1 files changed, 41 insertions(+), 46 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c40ba18..21d7acf 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -131,7 +131,8 @@ static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
 static int gfar_clean_tx_ring(struct net_device *dev);
-static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
+static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
+			      int amount_pull);
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
 void gfar_halt(struct net_device *dev);
@@ -210,6 +211,7 @@ static int gfar_of_init(struct net_device *dev)
 			FSL_GIANFAR_DEV_HAS_COALESCE |
 			FSL_GIANFAR_DEV_HAS_RMON |
 			FSL_GIANFAR_DEV_HAS_MULTI_INTR |
+			FSL_GIANFAR_DEV_HAS_PADDING |
 			FSL_GIANFAR_DEV_HAS_CSUM |
 			FSL_GIANFAR_DEV_HAS_VLAN |
 			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
@@ -1664,59 +1666,38 @@ static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 }
 
 
-static inline struct rxfcb *gfar_get_fcb(struct sk_buff *skb)
-{
-	struct rxfcb *fcb = (struct rxfcb *)skb->data;
-
-	/* Remove the FCB from the skb */
-	skb_pull(skb, GMAC_FCB_LEN);
-
-	return fcb;
-}
-
 /* gfar_process_frame() -- handle one incoming packet if skb
  * isn't NULL.  */
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
-		int length)
+			      int amount_pull)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct rxfcb *fcb = NULL;
 
-	if (NULL == skb) {
-		if (netif_msg_rx_err(priv))
-			printk(KERN_WARNING "%s: Missing skb!!.\n", dev->name);
-		dev->stats.rx_dropped++;
-		priv->extra_stats.rx_skbmissing++;
-	} else {
-		int ret;
+	int ret;
 
-		/* Prep the skb for the packet */
-		skb_put(skb, length);
+	/* fcb is at the beginning if exists */
+	fcb = (struct rxfcb *)skb->data;
 
-		/* Grab the FCB if there is one */
-		if (gfar_uses_fcb(priv))
-			fcb = gfar_get_fcb(skb);
-
-		/* Remove the padded bytes, if there are any */
-		if (priv->padding)
-			skb_pull(skb, priv->padding);
+	/* Remove the FCB from the skb */
+	/* Remove the padded bytes, if there are any */
+	if (amount_pull)
+		skb_pull(skb, amount_pull);
 
-		if (priv->rx_csum_enable)
-			gfar_rx_checksum(skb, fcb);
+	if (priv->rx_csum_enable)
+		gfar_rx_checksum(skb, fcb);
 
-		/* Tell the skb what kind of packet this is */
-		skb->protocol = eth_type_trans(skb, dev);
+	/* Tell the skb what kind of packet this is */
+	skb->protocol = eth_type_trans(skb, dev);
 
-		/* Send the packet up the stack */
-		if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN))) {
-			ret = vlan_hwaccel_receive_skb(skb, priv->vlgrp,
-						       fcb->vlctl);
-		} else
-			ret = netif_receive_skb(skb);
+	/* Send the packet up the stack */
+	if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN)))
+		ret = vlan_hwaccel_receive_skb(skb, priv->vlgrp, fcb->vlctl);
+	else
+		ret = netif_receive_skb(skb);
 
-		if (NET_RX_DROP == ret)
-			priv->extra_stats.kernel_dropped++;
-	}
+	if (NET_RX_DROP == ret)
+		priv->extra_stats.kernel_dropped++;
 
 	return 0;
 }
@@ -1729,13 +1710,17 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 {
 	struct rxbd8 *bdp;
 	struct sk_buff *skb;
-	u16 pkt_len;
+	int pkt_len;
+	int amount_pull;
 	int howmany = 0;
 	struct gfar_private *priv = netdev_priv(dev);
 
 	/* Get the first full descriptor */
 	bdp = priv->cur_rx;
 
+	amount_pull = (gfar_uses_fcb(priv) ? GMAC_FCB_LEN : 0) +
+		priv->padding;
+
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		struct sk_buff *newskb;
 		rmb();
@@ -1765,12 +1750,22 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 			dev->stats.rx_packets++;
 			howmany++;
 
-			/* Remove the FCS from the packet length */
-			pkt_len = bdp->length - 4;
+			if (likely(skb)) {
+				pkt_len = bdp->length - ETH_FCS_LEN;
+				/* Remove the FCS from the packet length */
+				skb_put(skb, pkt_len);
+				dev->stats.rx_bytes += pkt_len;
+
+				gfar_process_frame(dev, skb, amount_pull);
 
-			gfar_process_frame(dev, skb, pkt_len);
+			} else {
+				if (netif_msg_rx_err(priv))
+					printk(KERN_WARNING
+					       "%s: Missing skb!\n", dev->name);
+				dev->stats.rx_dropped++;
+				priv->extra_stats.rx_skbmissing++;
+			}
 
-			dev->stats.rx_bytes += pkt_len;
 		}
 
 		priv->rx_skbuff[priv->skb_currx] = newskb;
-- 
1.5.4.GIT

