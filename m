From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 11/14] gianfar: Add Scatter Gather support
Date: Tue, 16 Dec 2008 17:21:04 -0600
Message-ID: <1229469667-25002-12-git-send-email-afleming@freescale.com>
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
 <1229469667-25002-11-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Poonam Aggrwal <poonam.aggrwal@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39697 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbYLPXVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:23 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9f8013542
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL8C4020998
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-11-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

Scatter Gather support in gianfar driver to handle fragmented frames on
the transmit side.

Signed-off-by: Poonam Aggrwal <poonam.aggrwal@freescale.com>
Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c         |  213 ++++++++++++++++++++++++++++-------------
 drivers/net/gianfar.h         |    1 +
 drivers/net/gianfar_ethtool.c |    2 +
 3 files changed, 149 insertions(+), 67 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 27dbe5a..454bf2f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -368,7 +368,7 @@ static int gfar_probe(struct of_device *ofdev,
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable = 1;
-		dev->features |= NETIF_F_IP_CSUM;
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HIGHDMA;
 	} else
 		priv->rx_csum_enable = 0;
 
@@ -426,6 +426,7 @@ static int gfar_probe(struct of_device *ofdev,
 	priv->rx_buffer_size = DEFAULT_RX_BUFFER_SIZE;
 	priv->tx_ring_size = DEFAULT_TX_RING_SIZE;
 	priv->rx_ring_size = DEFAULT_RX_RING_SIZE;
+	priv->num_txbdfree = DEFAULT_TX_RING_SIZE;
 
 	priv->txcoalescing = DEFAULT_TX_COALESCE;
 	priv->txic = DEFAULT_TXIC;
@@ -819,22 +820,26 @@ static void free_skb_resources(struct gfar_private *priv)
 {
 	struct rxbd8 *rxbdp;
 	struct txbd8 *txbdp;
-	int i;
+	int i, j;
 
 	/* Go through all the buffer descriptors and free their data buffers */
 	txbdp = priv->tx_bd_base;
 
 	for (i = 0; i < priv->tx_ring_size; i++) {
+		if (!priv->tx_skbuff[i])
+			continue;
 
-		if (priv->tx_skbuff[i]) {
-			dma_unmap_single(&priv->dev->dev, txbdp->bufPtr,
-					txbdp->length,
-					DMA_TO_DEVICE);
-			dev_kfree_skb_any(priv->tx_skbuff[i]);
-			priv->tx_skbuff[i] = NULL;
+		dma_unmap_single(&priv->dev->dev, txbdp->bufPtr,
+				txbdp->length, DMA_TO_DEVICE);
+		txbdp->lstatus = 0;
+		for (j = 0; j < skb_shinfo(priv->tx_skbuff[i])->nr_frags; j++) {
+			txbdp++;
+			dma_unmap_page(&priv->dev->dev, txbdp->bufPtr,
+					txbdp->length, DMA_TO_DEVICE);
 		}
-
 		txbdp++;
+		dev_kfree_skb_any(priv->tx_skbuff[i]);
+		priv->tx_skbuff[i] = NULL;
 	}
 
 	kfree(priv->tx_skbuff);
@@ -967,6 +972,7 @@ int startup_gfar(struct net_device *dev)
 		priv->rx_skbuff[i] = NULL;
 
 	/* Initialize some variables in our dev structure */
+	priv->num_txbdfree = priv->tx_ring_size;
 	priv->dirty_tx = priv->cur_tx = priv->tx_bd_base;
 	priv->cur_rx = priv->rx_bd_base;
 	priv->skb_curtx = priv->skb_dirtytx = 0;
@@ -1207,28 +1213,84 @@ void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
 	fcb->vlctl = vlan_tx_tag_get(skb);
 }
 
+static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
+			       struct txbd8 *base, int ring_size)
+{
+	struct txbd8 *new_bd = bdp + stride;
+
+	return (new_bd >= (base + ring_size)) ? (new_bd - ring_size) : new_bd;
+}
+
+static inline struct txbd8 *next_txbd(struct txbd8 *bdp, struct txbd8 *base,
+		int ring_size)
+{
+	return skip_txbd(bdp, 1, base, ring_size);
+}
+
 /* This is called by the kernel when a frame is ready for transmission. */
 /* It is pointed to by the dev->hard_start_xmit function pointer */
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct txfcb *fcb = NULL;
-	struct txbd8 *txbdp, *base;
+	struct txbd8 *txbdp, *txbdp_start, *base;
 	u32 lstatus;
+	int i;
+	u32 bufaddr;
 	unsigned long flags;
+	unsigned int nr_frags, length;
+
+	base = priv->tx_bd_base;
+
+	/* total number of fragments in the SKB */
+	nr_frags = skb_shinfo(skb)->nr_frags;
+
+	spin_lock_irqsave(&priv->txlock, flags);
+
+	/* check if there is space to queue this packet */
+	if (nr_frags > priv->num_txbdfree) {
+		/* no space, stop the queue */
+		netif_stop_queue(dev);
+		dev->stats.tx_fifo_errors++;
+		spin_unlock_irqrestore(&priv->txlock, flags);
+		return NETDEV_TX_BUSY;
+	}
 
 	/* Update transmit stats */
 	dev->stats.tx_bytes += skb->len;
 
-	/* Lock priv now */
-	spin_lock_irqsave(&priv->txlock, flags);
+	txbdp = txbdp_start = priv->cur_tx;
 
-	/* Point at the first free tx descriptor */
-	txbdp = priv->cur_tx;
-	base = priv->tx_bd_base;
+	if (nr_frags == 0) {
+		lstatus = txbdp->lstatus | BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
+	} else {
+		/* Place the fragment addresses and lengths into the TxBDs */
+		for (i = 0; i < nr_frags; i++) {
+			/* Point at the next BD, wrapping as needed */
+			txbdp = next_txbd(txbdp, base, priv->tx_ring_size);
+
+			length = skb_shinfo(skb)->frags[i].size;
+
+			lstatus = txbdp->lstatus | length |
+				BD_LFLAG(TXBD_READY);
+
+			/* Handle the last BD specially */
+			if (i == nr_frags - 1)
+				lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 
-	/* Clear all but the WRAP status flags */
-	lstatus = txbdp->lstatus & BD_LFLAG(TXBD_WRAP);
+			bufaddr = dma_map_page(&dev->dev,
+					skb_shinfo(skb)->frags[i].page,
+					skb_shinfo(skb)->frags[i].page_offset,
+					length,
+					DMA_TO_DEVICE);
+
+			/* set the TxBD length and buffer pointer */
+			txbdp->bufPtr = bufaddr;
+			txbdp->lstatus = lstatus;
+		}
+
+		lstatus = txbdp_start->lstatus;
+	}
 
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
@@ -1246,48 +1308,45 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gfar_tx_vlan(skb, fcb);
 	}
 
-	/* Set buffer length and pointer */
-	txbdp->bufPtr = dma_map_single(&dev->dev, skb->data,
-			skb->len, DMA_TO_DEVICE);
-
-	/* Save the skb pointer so we can free it later */
+	/* setup the TxBD length and buffer pointer for the first BD */
 	priv->tx_skbuff[priv->skb_curtx] = skb;
+	txbdp_start->bufPtr = dma_map_single(&dev->dev, skb->data,
+			skb_headlen(skb), DMA_TO_DEVICE);
 
-	/* Update the current skb pointer (wrapping if this was the last) */
-	priv->skb_curtx =
-	    (priv->skb_curtx + 1) & TX_RING_MOD_MASK(priv->tx_ring_size);
+	lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
 
-	/* Flag the BD as ready, interrupt-causing, last, and in need of CRC */
-	lstatus |= 
-		BD_LFLAG(TXBD_READY | TXBD_LAST | TXBD_CRC | TXBD_INTERRUPT) |
-		skb->len;
-
-	dev->trans_start = jiffies;
-
-	/* The powerpc-specific eieio() is used, as wmb() has too strong
+	/*
+	 * The powerpc-specific eieio() is used, as wmb() has too strong
 	 * semantics (it requires synchronization between cacheable and
 	 * uncacheable mappings, which eieio doesn't provide and which we
 	 * don't need), thus requiring a more expensive sync instruction.  At
 	 * some point, the set of architecture-independent barrier functions
 	 * should be expanded to include weaker barriers.
 	 */
-
 	eieio();
-	txbdp->lstatus = lstatus;
 
-	txbdp = next_bd(txbdp, base, priv->tx_ring_size);
+	txbdp_start->lstatus = lstatus;
+
+	/* Update the current skb pointer to the next entry we will use 
+	 * (wrapping if necessary) */
+	priv->skb_curtx = (priv->skb_curtx + 1) &
+		TX_RING_MOD_MASK(priv->tx_ring_size);
+
+	priv->cur_tx = next_txbd(txbdp, base, priv->tx_ring_size);
+
+	/* reduce TxBD free count */
+	priv->num_txbdfree -= (nr_frags + 1);
+
+	dev->trans_start = jiffies;
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
-	if (txbdp == priv->dirty_tx) {
+	if (!priv->num_txbdfree) {
 		netif_stop_queue(dev);
 
 		dev->stats.tx_fifo_errors++;
 	}
 
-	/* Update the current txbd to the next one */
-	priv->cur_tx = txbdp;
-
 	/* Tell the DMA to go go go */
 	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
 
@@ -1461,46 +1520,66 @@ static void gfar_timeout(struct net_device *dev)
 /* Interrupt Handler for Transmit complete */
 static int gfar_clean_tx_ring(struct net_device *dev)
 {
-	struct txbd8 *bdp, *base;
 	struct gfar_private *priv = netdev_priv(dev);
+	struct txbd8 *bdp;
+	struct txbd8 *lbdp = NULL;
+	struct txbd8 *base = priv->tx_bd_base;
+	struct sk_buff *skb;
+	int skb_dirtytx;
+	int tx_ring_size = priv->tx_ring_size;
+	int frags = 0;
+	int i;
 	int howmany = 0;
+	u32 lstatus;
 
 	bdp = priv->dirty_tx;
-	base = priv->tx_bd_base;
-	while ((bdp->status & TXBD_READY) == 0) {
-		/* If dirty_tx and cur_tx are the same, then either the */
-		/* ring is empty or full now (it could only be full in the beginning, */
-		/* obviously).  If it is empty, we are done. */
-		if ((bdp == priv->cur_tx) && (netif_queue_stopped(dev) == 0))
+	skb_dirtytx = priv->skb_dirtytx;
+
+	while ((skb = priv->tx_skbuff[skb_dirtytx])) {
+		frags = skb_shinfo(skb)->nr_frags;
+		lbdp = skip_txbd(bdp, frags, base, tx_ring_size);
+
+		lstatus = lbdp->lstatus;
+
+		/* Only clean completed frames */
+		if ((lstatus & BD_LFLAG(TXBD_READY)) &&
+				(lstatus & BD_LENGTH_MASK))
 			break;
 
-		howmany++;
+		dma_unmap_single(&dev->dev,
+				bdp->bufPtr,
+				bdp->length,
+				DMA_TO_DEVICE);
 
-		/* Deferred means some collisions occurred during transmit, */
-		/* but we eventually sent the packet. */
-		if (bdp->status & TXBD_DEF)
-			dev->stats.collisions++;
+		bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
+		bdp = next_txbd(bdp, base, tx_ring_size);
 
-		/* Free the sk buffer associated with this TxBD */
-		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
+		for (i = 0; i < frags; i++) {
+			dma_unmap_page(&dev->dev,
+					bdp->bufPtr,
+					bdp->length,
+					DMA_TO_DEVICE);
+			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
+			bdp = next_txbd(bdp, base, tx_ring_size);
+		}
 
-		priv->tx_skbuff[priv->skb_dirtytx] = NULL;
-		priv->skb_dirtytx =
-		    (priv->skb_dirtytx +
-		     1) & TX_RING_MOD_MASK(priv->tx_ring_size);
+		dev_kfree_skb_any(skb);
+		priv->tx_skbuff[skb_dirtytx] = NULL;
 
-		/* Clean BD length for empty detection */
-		bdp->length = 0;
+		skb_dirtytx = (skb_dirtytx + 1) &
+			TX_RING_MOD_MASK(tx_ring_size);
 
-		bdp = next_bd(bdp, base, priv->tx_ring_size);
+		howmany++;
+		priv->num_txbdfree += frags + 1;
+	}
 
-		/* Move dirty_tx to be the next bd */
-		priv->dirty_tx = bdp;
+	/* If we freed a buffer, we can restart transmission, if necessary */
+	if (netif_queue_stopped(dev) && priv->num_txbdfree)
+		netif_wake_queue(dev);
 
-		/* We freed a buffer, so now we can restart transmission */
-		if (netif_queue_stopped(dev))
-			netif_wake_queue(dev);
-	} /* while ((bdp->status & TXBD_READY) == 0) */
+	/* Update dirty indicators */
+	priv->skb_dirtytx = skb_dirtytx;
+	priv->dirty_tx = bdp;
 
 	dev->stats.tx_packets += howmany;
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 9c8974d..7ef3cc5 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -728,6 +728,7 @@ struct gfar_private {
 	struct txbd8 *dirty_tx;		/* First buffer in line
 					   to be transmitted */
 	unsigned int tx_ring_size;
+	unsigned int num_txbdfree;	/* number of TxBDs free */
 
 	/* RX Locked fields */
 	spinlock_t rxlock;
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 3021057..59b3b5d 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -475,6 +475,7 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 	/* Change the size */
 	priv->rx_ring_size = rvals->rx_pending;
 	priv->tx_ring_size = rvals->tx_pending;
+	priv->num_txbdfree = priv->tx_ring_size;
 
 	/* Rebuild the rings with the new size */
 	if (dev->flags & IFF_UP) {
@@ -623,6 +624,7 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.get_tx_csum = gfar_get_tx_csum,
 	.set_rx_csum = gfar_set_rx_csum,
 	.set_tx_csum = gfar_set_tx_csum,
+	.set_sg = ethtool_op_set_sg,
 	.get_msglevel = gfar_get_msglevel,
 	.set_msglevel = gfar_set_msglevel,
 #ifdef CONFIG_PM
-- 
1.5.4.GIT

