From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] r6040 various cleanups
Date: Wed, 12 Dec 2007 10:44:01 +0100
Message-ID: <200712121044.01820.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.int-evry.fr ([157.159.10.44]:37948 "EHLO
	smtp1.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbXLLJoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 04:44:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch applies to Jeff's netdev-2.6 tree with Francois's r6040 recent changes pulled to this tree.

- remove unused private structure members
- functions to allocate/free TX and RX buffers
- recover from transmit timeout
- use netdev_alloc_skb instead of dev_alloc_skb
- do not use a private stats structure to store statistics
- break each TX/RX error to a separate line for better reading
- better control of the timer
- clean the IRQ handler
- fix typos and spelling mistakes in the driver

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
-- 
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 2334f4e..ff72c51 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -174,8 +174,6 @@ struct r6040_private {
 	struct net_device *dev;
 	struct mii_if_info mii_if;
 	struct napi_struct napi;
-	struct net_device_stats stats;
-	u16	napi_rx_running;
 	void __iomem *base;
 };
 
@@ -235,17 +233,54 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 	phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
-static void r6040_tx_timeout(struct net_device *dev)
+
+static void r6040_free_txbufs(struct net_device *dev)
 {
-	struct r6040_private *priv = netdev_priv(dev);
+	struct r6040_private *lp = netdev_priv(dev);
+	int i;
 
-	disable_irq(dev->irq);
-	napi_disable(&priv->napi);
-	spin_lock(&priv->lock);
-	dev->stats.tx_errors++;
-	spin_unlock(&priv->lock);
+	for (i = 0; i < TX_DCNT; i++) {
+		if (lp->tx_insert_ptr->skb_ptr) {
+			pci_unmap_single(lp->pdev, lp->tx_insert_ptr->buf,
+				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
+			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
+			lp->rx_insert_ptr->skb_ptr = NULL;
+		}
+		lp->tx_insert_ptr = lp->tx_insert_ptr->vndescp;
+	}
+}
 
-	netif_stop_queue(dev);
+static void r6040_free_rxbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < RX_DCNT; i++) {
+		if (lp->rx_insert_ptr->skb_ptr) {
+			pci_unmap_single(lp->pdev, lp->rx_insert_ptr->buf,
+				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(lp->rx_insert_ptr->skb_ptr);
+			lp->rx_insert_ptr->skb_ptr = NULL;
+		}
+		lp->rx_insert_ptr = lp->rx_insert_ptr->vndescp;
+	}
+}
+
+static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
+				 dma_addr_t desc_dma, int size)
+{
+	struct r6040_descriptor *desc = desc_ring;
+	dma_addr_t mapping = desc_dma;
+
+	while (size-- > 0) {
+		mapping += sizeof(sizeof(*desc));
+		desc->ndesc = cpu_to_le32(mapping);
+		desc->vndescp = desc + 1;
+		desc++;
+	}
+	desc--;
+	desc->ndesc = cpu_to_le32(desc_dma);
+	desc->vndescp = desc_ring;
 }
 
 /* Allocate skb buffer for rx descriptor */
@@ -256,7 +291,7 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 
 	descptr = lp->rx_insert_ptr;
 	while (lp->rx_free_desc < RX_DCNT) {
-		descptr->skb_ptr = dev_alloc_skb(MAX_BUF_SIZE);
+		descptr->skb_ptr = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 
 		if (!descptr->skb_ptr)
 			break;
@@ -272,6 +307,63 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 	lp->rx_insert_ptr = descptr;
 }
 
+static void r6040_alloc_txbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
+	lp->tx_free_desc = TX_DCNT;
+
+	lp->tx_remove_ptr = lp->tx_insert_ptr = lp->tx_ring;
+	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
+
+	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
+	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
+}
+
+static void r6040_alloc_rxbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
+	lp->rx_free_desc = 0;
+
+	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
+	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
+
+	rx_buf_alloc(lp, dev);
+
+	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
+	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
+}
+
+static void r6040_tx_timeout(struct net_device *dev)
+{
+	struct r6040_private *priv = netdev_priv(dev);
+	void __iomem *ioaddr = priv->base;
+
+	printk(KERN_WARNING "%s: transmit timed out, status %4.4x, PHY status "
+		"%4.4x\n",
+		dev->name, ioread16(ioaddr + MIER),
+		mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
+
+	disable_irq(dev->irq);
+	napi_disable(&priv->napi);
+	spin_lock(&priv->lock);
+	/* Clear all descriptors */
+	r6040_free_txbufs(dev);
+	r6040_free_rxbufs(dev);
+	r6040_alloc_txbufs(dev);
+	r6040_alloc_rxbufs(dev);
+
+	/* Reset MAC */
+	iowrite16(MAC_RST, ioaddr + MCR1);
+	spin_unlock(&priv->lock);
+	enable_irq(dev->irq);
+
+	dev->stats.tx_errors++;
+	netif_wake_queue(dev);
+}
 
 static struct net_device_stats *r6040_get_stats(struct net_device *dev)
 {
@@ -280,11 +372,11 @@ static struct net_device_stats *r6040_get_stats(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->lock, flags);
-	priv->stats.rx_crc_errors += ioread8(ioaddr + ME_CNT1);
-	priv->stats.multicast += ioread8(ioaddr + ME_CNT0);
+	dev->stats.rx_crc_errors += ioread8(ioaddr + ME_CNT1);
+	dev->stats.multicast += ioread8(ioaddr + ME_CNT0);
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	return &priv->stats;
+	return &dev->stats;
 }
 
 /* Stop RDC MAC and Free the allocated resource */
@@ -293,7 +385,6 @@ static void r6040_down(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	struct pci_dev *pdev = lp->pdev;
-	int i;
 	int limit = 2048;
 	u16 *adrp;
 	u16 cmd;
@@ -314,26 +405,10 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(adrp[2], ioaddr + MID_0H);
 	free_irq(dev->irq, dev);
 	/* Free RX buffer */
-	for (i = 0; i < RX_DCNT; i++) {
-		if (lp->rx_insert_ptr->skb_ptr) {
-			pci_unmap_single(lp->pdev, lp->rx_insert_ptr->buf,
-				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(lp->rx_insert_ptr->skb_ptr);
-			lp->rx_insert_ptr->skb_ptr = NULL;
-		}
-		lp->rx_insert_ptr = lp->rx_insert_ptr->vndescp;
-	}
+	r6040_free_rxbufs(dev);
 
 	/* Free TX buffer */
-	for (i = 0; i < TX_DCNT; i++) {
-		if (lp->tx_insert_ptr->skb_ptr) {
-			pci_unmap_single(lp->pdev, lp->tx_insert_ptr->buf,
-				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
-			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
-			lp->rx_insert_ptr->skb_ptr = NULL;
-		}
-		lp->tx_insert_ptr = lp->tx_insert_ptr->vndescp;
-	}
+	r6040_free_txbufs(dev);
 
 	/* Free Descriptor memory */
 	pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
@@ -432,19 +507,26 @@ static int r6040_rx(struct net_device *dev, int limit)
 
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
-		if (err & 0x0400) priv->stats.rx_errors++;
+		if (err & 0x0400)
+			dev->stats.rx_errors++;
 		/* RX FIFO over-run */
-		if (err & 0x8000) priv->stats.rx_fifo_errors++;
+		if (err & 0x8000)
+			dev->stats.rx_fifo_errors++;
 		/* RX descriptor unavailable */
-		if (err & 0x0080) priv->stats.rx_frame_errors++;
+		if (err & 0x0080)
+			dev->stats.rx_frame_errors++;
 		/* Received packet with length over buffer lenght */
-		if (err & 0x0020) priv->stats.rx_over_errors++;
+		if (err & 0x0020)
+			dev->stats.rx_over_errors++;
 		/* Received packet with too long or short */
-		if (err & (0x0010|0x0008)) priv->stats.rx_length_errors++;
+		if (err & 0x0010)
+			dev->stats.rx_length_errors++;
+		if (err & 0x0008)
+			dev->stats.rx_length_errors++;
 		/* Received packet with CRC errors */
 		if (err & 0x0004) {
 			spin_lock(&priv->lock);
-			priv->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			spin_unlock(&priv->lock);
 		}
 
@@ -469,8 +551,8 @@ static int r6040_rx(struct net_device *dev, int limit)
 			/* Send to upper layer */
 			netif_receive_skb(skb_ptr);
 			dev->last_rx = jiffies;
-			priv->dev->stats.rx_packets++;
-			priv->dev->stats.rx_bytes += descptr->len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += descptr->len;
 			/* To next descriptor */
 			descptr = descptr->vndescp;
 			priv->rx_free_desc--;
@@ -498,11 +580,15 @@ static void r6040_tx(struct net_device *dev)
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
 
-		if (err & 0x0200) priv->stats.rx_fifo_errors++;
-		if (err & (0x2000 | 0x4000)) priv->stats.tx_carrier_errors++;
+		if (err & 0x0200)
+			dev->stats.rx_fifo_errors++;
+		if (err & 0x2000)
+			dev->stats.tx_carrier_errors++;
+		if (err & 0x4000)
+			dev->stats.tx_carrier_errors++;
 
 		if (descptr->status & 0x8000)
-			break; /* Not complte */
+			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
 		pci_unmap_single(priv->pdev, descptr->buf,
 			skb_ptr->len, PCI_DMA_TODEVICE);
@@ -545,7 +631,6 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 status;
-	int handled = 1;
 
 	/* Mask off RDC MAC interrupt */
 	iowrite16(MSK_INT, ioaddr + MIER);
@@ -565,7 +650,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	if (status & 0x10)
 		r6040_tx(dev);
 
-	return IRQ_RETVAL(handled);
+	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -577,22 +662,6 @@ static void r6040_poll_controller(struct net_device *dev)
 }
 #endif
 
-static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
-				 dma_addr_t desc_dma, int size)
-{
-	struct r6040_descriptor *desc = desc_ring;
-	dma_addr_t mapping = desc_dma;
-
-	while (size-- > 0) {
-		mapping += sizeof(sizeof(*desc));
-		desc->ndesc = cpu_to_le32(mapping);
-		desc->vndescp = desc + 1;
-		desc++;
-	}
-	desc--;
-	desc->ndesc = cpu_to_le32(desc_dma);
-	desc->vndescp = desc_ring;
-}
 
 /* Init RDC MAC */
 static void r6040_up(struct net_device *dev)
@@ -600,30 +669,9 @@ static void r6040_up(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 
-	/* Initialize */
-	lp->tx_free_desc = TX_DCNT;
-	lp->rx_free_desc = 0;
-	/* Init descriptor */
-	lp->tx_remove_ptr = lp->tx_insert_ptr = lp->tx_ring;
-	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
-	/* Init TX descriptor */
-	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
-
-	/* Init RX descriptor */
-	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
-
-	/* Allocate buffer for RX descriptor */
-	rx_buf_alloc(lp, dev);
-
-	/*
-	 * TX and RX descriptor start registers.
-	 * Lower 16-bits to MxD_SA0. Higher 16-bits to MxD_SA1.
-	 */
-	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
-	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
-
-	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
-	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
+	/* Initialise and alloc RX/TX buffers */
+	r6040_alloc_txbufs(dev);
+	r6040_alloc_rxbufs(dev);
 
 	/* Buffer Size Register */
 	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
@@ -689,8 +737,7 @@ static void r6040_timer(unsigned long data)
 	}
 
 	/* Timer active again */
-	lp->timer.expires = TIMER_WUT;
-	add_timer(&lp->timer);
+	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
 }
 
 /* Read/set MAC address routines */
@@ -746,14 +793,10 @@ static int r6040_open(struct net_device *dev)
 	napi_enable(&lp->napi);
 	netif_start_queue(dev);
 
-	if (lp->switch_sig != ICPLUS_PHY_ID) {
-		/* set and active a timer process */
-		init_timer(&lp->timer);
-		lp->timer.expires = TIMER_WUT;
-		lp->timer.data = (unsigned long)dev;
-		lp->timer.function = &r6040_timer;
-		add_timer(&lp->timer);
-	}
+	/* set and active a timer process */
+	setup_timer(&lp->timer, r6040_timer, (unsigned long) dev);
+	if (lp->switch_sig != ICPLUS_PHY_ID)
+		mod_timer(&lp->timer, jiffies + HZ);
 	return 0;
 }
