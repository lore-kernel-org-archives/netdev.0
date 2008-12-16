From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 09/14] gianfar: Add macros for stepping through BDs
Date: Tue, 16 Dec 2008 17:21:02 -0600
Message-ID: <1229469667-25002-10-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
 <1229469667-25002-7-git-send-email-afleming@freescale.com>
 <1229469667-25002-8-git-send-email-afleming@freescale.com>
 <1229469667-25002-9-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39712 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbYLPXVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:24 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNLAPO013577
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:12 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBGNL9tV017610
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-9-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is based strongly on code from Dai Haruki <Dai.Haruki@freescale.com>.

The gianfar Buffer Descriptors are arranged in a circular array, the end of
which is denoted by setting the "WRAP" bit in the descriptor.  However, the
software knows the end of the ring because it knows how many descriptors are
there.  Rather than check each descriptor for whether the WRAP bit is set,
use pointer math to determine where the next BD is.  This is also useful for
when we want to look at BDs other than the very next one (for Scatter-Gather).

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   27 +++++++++------------------
 drivers/net/gianfar.h |    6 ++++++
 2 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6c0e0a3..2c88701 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1215,7 +1215,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct txfcb *fcb = NULL;
-	struct txbd8 *txbdp;
+	struct txbd8 *txbdp, *base;
 	u16 status;
 	unsigned long flags;
 
@@ -1227,6 +1227,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Point at the first free tx descriptor */
 	txbdp = priv->cur_tx;
+	base = priv->tx_bd_base;
 
 	/* Clear all but the WRAP status flags */
 	status = txbdp->status & TXBD_WRAP;
@@ -1279,12 +1280,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	eieio();
 	txbdp->status = status;
 
-	/* If this was the last BD in the ring, the next one */
-	/* is at the beginning of the ring */
-	if (txbdp->status & TXBD_WRAP)
-		txbdp = priv->tx_bd_base;
-	else
-		txbdp++;
+	txbdp = next_bd(txbdp, base, priv->tx_ring_size);
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
@@ -1470,11 +1466,12 @@ static void gfar_timeout(struct net_device *dev)
 /* Interrupt Handler for Transmit complete */
 static int gfar_clean_tx_ring(struct net_device *dev)
 {
-	struct txbd8 *bdp;
+	struct txbd8 *bdp, *base;
 	struct gfar_private *priv = netdev_priv(dev);
 	int howmany = 0;
 
 	bdp = priv->dirty_tx;
+	base = priv->tx_bd_base;
 	while ((bdp->status & TXBD_READY) == 0) {
 		/* If dirty_tx and cur_tx are the same, then either the */
 		/* ring is empty or full now (it could only be full in the beginning, */
@@ -1500,11 +1497,7 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 		/* Clean BD length for empty detection */
 		bdp->length = 0;
 
-		/* update bdp to point at next bd in the ring (wrapping if necessary) */
-		if (bdp->status & TXBD_WRAP)
-			bdp = priv->tx_bd_base;
-		else
-			bdp++;
+		bdp = next_bd(bdp, base, priv->tx_ring_size);
 
 		/* Move dirty_tx to be the next bd */
 		priv->dirty_tx = bdp;
@@ -1708,7 +1701,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
  */
 int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 {
-	struct rxbd8 *bdp;
+	struct rxbd8 *bdp, *base;
 	struct sk_buff *skb;
 	int pkt_len;
 	int amount_pull;
@@ -1717,6 +1710,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 	/* Get the first full descriptor */
 	bdp = priv->cur_rx;
+	base = priv->rx_bd_base;
 
 	amount_pull = (gfar_uses_fcb(priv) ? GMAC_FCB_LEN : 0) +
 		priv->padding;
@@ -1774,10 +1768,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 		gfar_new_rxbdp(dev, bdp, newskb);
 
 		/* Update to the next pointer */
-		if (bdp->status & RXBD_WRAP)
-			bdp = priv->rx_bd_base;
-		else
-			bdp++;
+		bdp = next_bd(bdp, base, priv->rx_ring_size);
 
 		/* update to point at the next skb */
 		priv->skb_currx =
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 1bdb50c..1ebf7ac 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -196,6 +196,12 @@ extern const char gfar_driver_version[];
 #define DEFAULT_TXIC mk_ic_value(DEFAULT_TXCOUNT, DEFAULT_TXTIME)
 #define DEFAULT_RXIC mk_ic_value(DEFAULT_RXCOUNT, DEFAULT_RXTIME)
 
+#define skip_bd(bdp, stride, base, ring_size) ({ \
+	typeof(bdp) new_bd = (bdp) + (stride); \
+	(new_bd >= (base) + (ring_size)) ? (new_bd - (ring_size)) : new_bd; })
+
+#define next_bd(bdp, base, ring_size) skip_bd(bdp, 1, base, ring_size)
+
 #define RCTRL_PAL_MASK		0x001f0000
 #define RCTRL_VLEX		0x00002000
 #define RCTRL_FILREN		0x00001000
-- 
1.5.4.GIT

