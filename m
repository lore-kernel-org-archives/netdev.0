From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 10/14] gianfar: Make all BD status writes 32-bit
Date: Tue, 16 Dec 2008 17:21:03 -0600
Message-ID: <1229469667-25002-11-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
 <1229469667-25002-7-git-send-email-afleming@freescale.com>
 <1229469667-25002-8-git-send-email-afleming@freescale.com>
 <1229469667-25002-9-git-send-email-afleming@freescale.com>
 <1229469667-25002-10-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	Dai Haruki <Dai.Haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39704 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751AbYLPXVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:23 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNLAeG013550
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL9s0006154
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-10-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever we want to update the status field in a BD, we usually want to
update the length field, too.  By combining them into one 32-bit field, we
reduce the number of stores to memory shared with the controller, and we
eliminate the need for order-enforcement, as the length and "READY" bit are
now updated atomically at the same time.

Signed-off-by: Dai Haruki <Dai.Haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   36 +++++++++++++++---------------------
 drivers/net/gianfar.h |   20 ++++++++++++++++----
 2 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2c88701..27dbe5a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -854,8 +854,7 @@ static void free_skb_resources(struct gfar_private *priv)
 				priv->rx_skbuff[i] = NULL;
 			}
 
-			rxbdp->status = 0;
-			rxbdp->length = 0;
+			rxbdp->lstatus = 0;
 			rxbdp->bufPtr = 0;
 
 			rxbdp++;
@@ -976,8 +975,7 @@ int startup_gfar(struct net_device *dev)
 	/* Initialize Transmit Descriptor Ring */
 	txbdp = priv->tx_bd_base;
 	for (i = 0; i < priv->tx_ring_size; i++) {
-		txbdp->status = 0;
-		txbdp->length = 0;
+		txbdp->lstatus = 0;
 		txbdp->bufPtr = 0;
 		txbdp++;
 	}
@@ -1216,7 +1214,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	struct txfcb *fcb = NULL;
 	struct txbd8 *txbdp, *base;
-	u16 status;
+	u32 lstatus;
 	unsigned long flags;
 
 	/* Update transmit stats */
@@ -1230,26 +1228,25 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	base = priv->tx_bd_base;
 
 	/* Clear all but the WRAP status flags */
-	status = txbdp->status & TXBD_WRAP;
+	lstatus = txbdp->lstatus & BD_LFLAG(TXBD_WRAP);
 
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb);
-		status |= TXBD_TOE;
+		lstatus |= BD_LFLAG(TXBD_TOE);
 		gfar_tx_checksum(skb, fcb);
 	}
 
 	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
 		if (unlikely(NULL == fcb)) {
 			fcb = gfar_add_fcb(skb);
-			status |= TXBD_TOE;
+			lstatus |= BD_LFLAG(TXBD_TOE);
 		}
 
 		gfar_tx_vlan(skb, fcb);
 	}
 
 	/* Set buffer length and pointer */
-	txbdp->length = skb->len;
 	txbdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			skb->len, DMA_TO_DEVICE);
 
@@ -1260,12 +1257,10 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->skb_curtx =
 	    (priv->skb_curtx + 1) & TX_RING_MOD_MASK(priv->tx_ring_size);
 
-	/* Flag the BD as interrupt-causing */
-	status |= TXBD_INTERRUPT;
-
-	/* Flag the BD as ready to go, last in frame, and  */
-	/* in need of CRC */
-	status |= (TXBD_READY | TXBD_LAST | TXBD_CRC);
+	/* Flag the BD as ready, interrupt-causing, last, and in need of CRC */
+	lstatus |= 
+		BD_LFLAG(TXBD_READY | TXBD_LAST | TXBD_CRC | TXBD_INTERRUPT) |
+		skb->len;
 
 	dev->trans_start = jiffies;
 
@@ -1278,7 +1273,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 
 	eieio();
-	txbdp->status = status;
+	txbdp->lstatus = lstatus;
 
 	txbdp = next_bd(txbdp, base, priv->tx_ring_size);
 
@@ -1542,20 +1537,19 @@ static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
 		struct sk_buff *skb)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	u32 * status_len = (u32 *)bdp;
-	u16 flags;
+	u32 lstatus;
 
 	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			priv->rx_buffer_size, DMA_FROM_DEVICE);
 
-	flags = RXBD_EMPTY | RXBD_INTERRUPT;
+	lstatus = BD_LFLAG(RXBD_EMPTY | RXBD_INTERRUPT);
 
 	if (bdp == priv->rx_bd_base + priv->rx_ring_size - 1)
-		flags |= RXBD_WRAP;
+		lstatus |= BD_LFLAG(RXBD_WRAP);
 
 	eieio();
 
-	*status_len = (u32)flags << 16;
+	bdp->lstatus = lstatus;
 }
 
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 1ebf7ac..9c8974d 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -311,6 +311,8 @@ extern const char gfar_driver_version[];
 #define ATTRELI_EI_MASK		0x00003fff
 #define ATTRELI_EI(x) (x)
 
+#define BD_LFLAG(flags) ((flags) << 16)
+#define BD_LENGTH_MASK		0x00ff
 
 /* TxBD status field bits */
 #define TXBD_READY		0x8000
@@ -374,8 +376,13 @@ extern const char gfar_driver_version[];
 
 struct txbd8
 {
-	u16	status;	/* Status Fields */
-	u16	length;	/* Buffer length */
+	union {
+		struct {
+			u16	status;	/* Status Fields */
+			u16	length;	/* Buffer length */
+		};
+		u32 lstatus;
+	};
 	u32	bufPtr;	/* Buffer Pointer */
 };
 
@@ -390,8 +397,13 @@ struct txfcb {
 
 struct rxbd8
 {
-	u16	status;	/* Status Fields */
-	u16	length;	/* Buffer Length */
+	union {
+		struct {
+			u16	status;	/* Status Fields */
+			u16	length;	/* Buffer Length */
+		};
+		u32 lstatus;
+	};
 	u32	bufPtr;	/* Buffer Pointer */
 };
 
-- 
1.5.4.GIT

