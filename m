From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r6040' branch
Date: Tue, 5 Feb 2008 23:34:52 +0100
Message-ID: <20080205223452.GA8361@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Florian Fainelli <florian.fainelli@telecomint.eu>,
	Sten Wang <sten.wang@rdc.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50000 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752427AbYBEWxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 17:53:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'r6040' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r6040

to get the changes below.

I have simply rebased the r6040 branch from december on top of
Linus's latest head and given each patch a compile test.
The content is identical to Florian's initial work (minus the
removal of the unused TIMER_WUT and a duplicate update of an
error counter).

Distance from 'master' (21511abd0a248a3f225d3b611cfabb93124605a7)
-----------------------------------------------------------------

ec6d2d453a932fd50c5fd95d5aac633b4e5f241d
106adf3c84d081776a1d1fbb8a047cad12af2bb9
b4f1255d6839bd970d5ff20a9c3d73f73c9adaa3
d248fd77902fcf33b0bc49ab521930877d94890f

Diffstat
--------

 drivers/net/r6040.c |  233 +++++++++++++++++++++++++++++---------------------
 1 files changed, 135 insertions(+), 98 deletions(-)

Shortlog
--------

Florian Fainelli (4):
      r6040: do not use a private stats structure to store statistics
      r6040: add helpers to allocate and free the Tx/Rx buffers
      r6040: recover from transmit timeout
      r6040: cleanups

Patch
-----

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 2334f4e..19184e4 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -61,7 +61,6 @@
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(6000 * HZ / 1000)
-#define TIMER_WUT	(jiffies + HZ * 1)/* timer wakeup time : 1 second */
 
 /* RDC MAC I/O Size */
 #define R6040_IO_SIZE	256
@@ -174,8 +173,6 @@ struct r6040_private {
 	struct net_device *dev;
 	struct mii_if_info mii_if;
 	struct napi_struct napi;
-	struct net_device_stats stats;
-	u16	napi_rx_running;
 	void __iomem *base;
 };
 
@@ -235,17 +232,53 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 	phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
-static void r6040_tx_timeout(struct net_device *dev)
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
@@ -256,7 +289,7 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 
 	descptr = lp->rx_insert_ptr;
 	while (lp->rx_free_desc < RX_DCNT) {
-		descptr->skb_ptr = dev_alloc_skb(MAX_BUF_SIZE);
+		descptr->skb_ptr = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 
 		if (!descptr->skb_ptr)
 			break;
@@ -272,6 +305,63 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
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
@@ -280,11 +370,11 @@ static struct net_device_stats *r6040_get_stats(struct net_device *dev)
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
@@ -293,7 +383,6 @@ static void r6040_down(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	struct pci_dev *pdev = lp->pdev;
-	int i;
 	int limit = 2048;
 	u16 *adrp;
 	u16 cmd;
@@ -313,27 +402,12 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);
 	free_irq(dev->irq, dev);
+
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
@@ -432,19 +506,24 @@ static int r6040_rx(struct net_device *dev, int limit)
 
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
+		if (err & (0x0010 | 0x0008))
+			dev->stats.rx_length_errors++;
 		/* Received packet with CRC errors */
 		if (err & 0x0004) {
 			spin_lock(&priv->lock);
-			priv->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			spin_unlock(&priv->lock);
 		}
 
@@ -469,8 +548,8 @@ static int r6040_rx(struct net_device *dev, int limit)
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
@@ -498,11 +577,13 @@ static void r6040_tx(struct net_device *dev)
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
 
-		if (err & 0x0200) priv->stats.rx_fifo_errors++;
-		if (err & (0x2000 | 0x4000)) priv->stats.tx_carrier_errors++;
+		if (err & 0x0200)
+			dev->stats.rx_fifo_errors++;
+		if (err & (0x2000 | 0x4000))
+			dev->stats.tx_carrier_errors++;
 
 		if (descptr->status & 0x8000)
-			break; /* Not complte */
+			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
 		pci_unmap_single(priv->pdev, descptr->buf,
 			skb_ptr->len, PCI_DMA_TODEVICE);
@@ -545,7 +626,6 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 status;
-	int handled = 1;
 
 	/* Mask off RDC MAC interrupt */
 	iowrite16(MSK_INT, ioaddr + MIER);
@@ -565,7 +645,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	if (status & 0x10)
 		r6040_tx(dev);
 
-	return IRQ_RETVAL(handled);
+	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -577,53 +657,15 @@ static void r6040_poll_controller(struct net_device *dev)
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
-
 /* Init RDC MAC */
 static void r6040_up(struct net_device *dev)
 {
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
@@ -689,8 +731,7 @@ static void r6040_timer(unsigned long data)
 	}
 
 	/* Timer active again */
-	lp->timer.expires = TIMER_WUT;
-	add_timer(&lp->timer);
+	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
 }
 
 /* Read/set MAC address routines */
@@ -746,14 +787,10 @@ static int r6040_open(struct net_device *dev)
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
 
-- 
Ueimor
