From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 2/3] Revert "net: fec: put tx to napi poll function to fix dead lock"
Date: Fri, 19 Apr 2013 16:36:03 +0200
Message-ID: <1366382164-10968-3-git-send-email-l.stach@pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Fabio Estevam <festevam@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60800 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030551Ab3DSOhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:37:10 -0400
In-Reply-To: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit de5fb0a053482d89262c3284b67884cd2c621adc.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.c | 86 ++++++++++++++++++------------------
 drivers/net/ethernet/freescale/fec.h |  3 ++
 2 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 5721ca1..d2f7983 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -247,13 +247,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct bufdesc *bdp;
 	void *bufaddr;
 	unsigned short	status;
-	unsigned int index;
+	unsigned long flags;
 
 	if (!fep->link) {
 		/* Link is down or autonegotiation is in progress. */
 		return NETDEV_TX_BUSY;
 	}
 
+	spin_lock_irqsave(&fep->hw_lock, flags);
 	/* Fill in a Tx ring entry */
 	bdp = fep->cur_tx;
 
@@ -264,6 +265,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		 * This should not happen, since ndev->tbusy should be set.
 		 */
 		printk("%s: tx queue full!.\n", ndev->name);
+		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -279,13 +281,13 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	 * 4-byte boundaries. Use bounce buffers to copy data
 	 * and get it aligned. Ugh.
 	 */
-	if (fep->bufdesc_ex)
-		index = (struct bufdesc_ex *)bdp -
-			(struct bufdesc_ex *)fep->tx_bd_base;
-	else
-		index = bdp - fep->tx_bd_base;
-
 	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
+		unsigned int index;
+		if (fep->bufdesc_ex)
+			index = (struct bufdesc_ex *)bdp -
+				(struct bufdesc_ex *)fep->tx_bd_base;
+		else
+			index = bdp - fep->tx_bd_base;
 		memcpy(fep->tx_bounce[index], skb->data, skb->len);
 		bufaddr = fep->tx_bounce[index];
 	}
@@ -299,7 +301,10 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		swap_buffer(bufaddr, skb->len);
 
 	/* Save skb pointer */
-	fep->tx_skbuff[index] = skb;
+	fep->tx_skbuff[fep->skb_cur] = skb;
+
+	ndev->stats.tx_bytes += skb->len;
+	fep->skb_cur = (fep->skb_cur+1) & TX_RING_MOD_MASK;
 
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
@@ -327,22 +332,26 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			ebdp->cbd_esc = BD_ENET_TX_INT;
 		}
 	}
+	/* Trigger transmission start */
+	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
+
 	/* If this was the last BD in the ring, start at the beginning again. */
 	if (status & BD_ENET_TX_WRAP)
 		bdp = fep->tx_bd_base;
 	else
 		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
 
-	fep->cur_tx = bdp;
-
-	if (fep->cur_tx == fep->dirty_tx)
+	if (bdp == fep->dirty_tx) {
+		fep->tx_full = 1;
 		netif_stop_queue(ndev);
+	}
 
-	/* Trigger transmission start */
-	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
+	fep->cur_tx = bdp;
 
 	skb_tx_timestamp(skb);
 
+	spin_unlock_irqrestore(&fep->hw_lock, flags);
+
 	return NETDEV_TX_OK;
 }
 
@@ -374,7 +383,7 @@ static void fec_enet_bd_init(struct net_device *dev)
 
 	/* ...and the same for transmit */
 	bdp = fep->tx_bd_base;
-	fep->cur_tx = bdp;
+	fep->dirty_tx = fep->cur_tx = bdp;
 	for (i = 0; i < TX_RING_SIZE; i++) {
 
 		/* Initialize the BD for every fragment in the page. */
@@ -390,7 +399,6 @@ static void fec_enet_bd_init(struct net_device *dev)
 	/* Set the last buffer to wrap */
 	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
 	bdp->cbd_sc |= BD_SC_WRAP;
-	fep->dirty_tx = bdp;
 }
 
 /* This function is called to start or restart the FEC during a link
@@ -447,7 +455,8 @@ fec_restart(struct net_device *ndev, int duplex)
 		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc)
 			* RX_RING_SIZE,	fep->hwp + FEC_X_DES_START);
 
-
+	/* Reset SKB transmit buffers. */
+	fep->skb_cur = fep->skb_dirty = 0;
 	for (i = 0; i <= TX_RING_MOD_MASK; i++) {
 		if (fep->tx_skbuff[i]) {
 			dev_kfree_skb_any(fep->tx_skbuff[i]);
@@ -610,35 +619,20 @@ fec_enet_tx(struct net_device *ndev)
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
-	int	index = 0;
 
 	fep = netdev_priv(ndev);
+	spin_lock(&fep->hw_lock);
 	bdp = fep->dirty_tx;
 
-	/* get next bdp of dirty_tx */
-	if (bdp->cbd_sc & BD_ENET_TX_WRAP)
-		bdp = fep->tx_bd_base;
-	else
-		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
-
 	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
-
-		/* current queue is empty */
-		if (bdp == fep->cur_tx)
+		if (bdp == fep->cur_tx && fep->tx_full == 0)
 			break;
 
-		if (fep->bufdesc_ex)
-			index = (struct bufdesc_ex *)bdp -
-				(struct bufdesc_ex *)fep->tx_bd_base;
-		else
-			index = bdp - fep->tx_bd_base;
-
 		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 				FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
 
-		skb = fep->tx_skbuff[index];
-
+		skb = fep->tx_skbuff[fep->skb_dirty];
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
 				   BD_ENET_TX_RL | BD_ENET_TX_UN |
@@ -683,9 +677,8 @@ fec_enet_tx(struct net_device *ndev)
 
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
-		fep->tx_skbuff[index] = NULL;
-
-		fep->dirty_tx = bdp;
+		fep->tx_skbuff[fep->skb_dirty] = NULL;
+		fep->skb_dirty = (fep->skb_dirty + 1) & TX_RING_MOD_MASK;
 
 		/* Update pointer to next buffer descriptor to be transmitted */
 		if (status & BD_ENET_TX_WRAP)
@@ -695,12 +688,14 @@ fec_enet_tx(struct net_device *ndev)
 
 		/* Since we have freed up a buffer, the ring is no longer full
 		 */
-		if (fep->dirty_tx != fep->cur_tx) {
+		if (fep->tx_full) {
+			fep->tx_full = 0;
 			if (netif_queue_stopped(ndev))
 				netif_wake_queue(ndev);
 		}
 	}
-	return;
+	fep->dirty_tx = bdp;
+	spin_unlock(&fep->hw_lock);
 }
 
 
@@ -867,7 +862,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 		int_events = readl(fep->hwp + FEC_IEVENT);
 		writel(int_events, fep->hwp + FEC_IEVENT);
 
-		if (int_events & (FEC_ENET_RXF | FEC_ENET_TXF)) {
+		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
 
 			/* Disable the RX interrupt */
@@ -878,6 +873,15 @@ fec_enet_interrupt(int irq, void *dev_id)
 			}
 		}
 
+		/* Transmit OK, or non-fatal error. Update the buffer
+		 * descriptors. FEC handles all errors, we just discover
+		 * them as part of the transmit process.
+		 */
+		if (int_events & FEC_ENET_TXF) {
+			ret = IRQ_HANDLED;
+			fec_enet_tx(ndev);
+		}
+
 		if (int_events & FEC_ENET_MII) {
 			ret = IRQ_HANDLED;
 			complete(&fep->mdio_done);
@@ -893,8 +897,6 @@ static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 	int pkts = fec_enet_rx(ndev, budget);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	fec_enet_tx(ndev);
-
 	if (pkts < budget) {
 		napi_complete(napi);
 		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index fdc0037..ca20331 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -213,6 +213,8 @@ struct fec_enet_private {
 	unsigned char *tx_bounce[TX_RING_SIZE];
 	struct	sk_buff *tx_skbuff[TX_RING_SIZE];
 	struct	sk_buff *rx_skbuff[RX_RING_SIZE];
+	ushort	skb_cur;
+	ushort	skb_dirty;
 
 	/* CPM dual port RAM relative addresses */
 	dma_addr_t	bd_dma;
@@ -224,6 +226,7 @@ struct fec_enet_private {
 	/* The ring entries to be free()ed */
 	struct bufdesc	*dirty_tx;
 
+	uint	tx_full;
 	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
 	spinlock_t hw_lock;
 
-- 
1.8.2.rc2
