From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] r6040 various bugfixes
Date: Thu, 15 Nov 2007 19:37:43 +0100
Message-ID: <200711151937.44681.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.int-evry.fr ([157.159.10.44]:36640 "EHLO
	smtp1.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbXKOSiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:38:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes various bugfixes spotted by Stephen, thanks !

- add functions to allocate/free TX and RX buffers
- recover from transmit timeout and use the 4 helpers defined below
- use netdev_alloc_skb instead of dev_alloc_skb
- do not use a private stats structure to store statistics
- break each TX/RX error to a separate line for better reading
- suppress volatiles and make checkpatch happy
- better control of the timer
- fix spin_unlock_irq typo in netdev_get_settings
- fix various typos and spelling in the driver

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
-- 
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index edce5a4..529c903 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -172,7 +172,6 @@ struct r6040_private {
 	struct net_device *dev;
 	struct mii_if_info mii_if;
 	struct napi_struct napi;
-	struct net_device_stats stats;
 	u16	napi_rx_running;
 	void __iomem *base;
 };
@@ -233,18 +232,121 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 	phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
+static void r6040_free_txbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	int i;
+
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
+
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
+static void r6040_alloc_txbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	struct r6040_descriptor *descptr;
+	int i;
+	dma_addr_t desc_dma, start_dma;
+
+	lp->tx_free_desc = TX_DCNT;
+	/* Zero all descriptors */
+	memset(lp->desc_pool, 0, ALLOC_DESC_SIZE);
+	lp->tx_insert_ptr = (struct r6040_descriptor *)lp->desc_pool;
+	lp->tx_remove_ptr = lp->tx_insert_ptr;
+
+	/* Init TX descriptor */
+	descptr = lp->tx_insert_ptr;
+	desc_dma = lp->desc_dma;
+	start_dma = desc_dma;
+	for (i = 0; i < TX_DCNT; i++) {
+		descptr->ndesc = cpu_to_le32(desc_dma +
+			sizeof(struct r6040_descriptor));
+		descptr->vndescp = (descptr + 1);
+		descptr = (descptr + 1);
+		desc_dma += sizeof(struct r6040_descriptor);
+	}
+	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
+	(descptr - 1)->vndescp = lp->tx_insert_ptr;
+}
+
+static void r6040_alloc_rxbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	struct r6040_descriptor *descptr;
+	int i;
+	dma_addr_t desc_dma, start_dma;
+
+	lp->rx_free_desc = 0;
+	/* Zero all descriptors */
+	memset(lp->desc_pool, 0, ALLOC_DESC_SIZE);
+	lp->rx_insert_ptr = (struct r6040_descriptor *)lp->tx_insert_ptr +
+		TX_DCNT;
+	lp->rx_remove_ptr = lp->rx_insert_ptr;
+
+	/* Init RX descriptor */
+	start_dma = desc_dma;
+	descptr = lp->rx_insert_ptr;
+	for (i = 0; i < RX_DCNT; i++) {
+		descptr->ndesc = cpu_to_le32(desc_dma +
+			sizeof(struct r6040_descriptor));
+		descptr->vndescp = (descptr + 1);
+		descptr = (descptr + 1);
+		desc_dma += sizeof(struct r6040_descriptor);
+	}
+	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
+	(descptr - 1)->vndescp = lp->rx_insert_ptr;
+}
+
 static void
 r6040_tx_timeout(struct net_device *dev)
 {
 	struct r6040_private *priv = netdev_priv(dev);
+	void __iomem *ioaddr = priv->base;
 
+	printk(KERN_WARNING "%s: transmit timed out, status %4.4x, PHY status "
+		"%4.4x\n",
+		dev->name, ioread16(ioaddr + MIER),
+		mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
 	disable_irq(dev->irq);
 	napi_disable(&priv->napi);
+
 	spin_lock(&priv->lock);
-	dev->stats.tx_errors++;
+	/* Clear all descriptors */
+	r6040_free_txbufs(dev);
+	r6040_free_rxbufs(dev);
+	r6040_alloc_txbufs(dev);
+	r6040_alloc_rxbufs(dev);
+
+	/* Reset MAC */
+	iowrite16(MAC_RST, ioaddr + MCR1);
 	spin_unlock(&priv->lock);
+	enable_irq(dev->irq);
 
-	netif_stop_queue(dev);
+	dev->stats.tx_errors++;
+	netif_wake_queue(dev);
 }
 
 /* Allocate skb buffer for rx descriptor */
@@ -255,7 +357,7 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 
 	descptr = lp->rx_insert_ptr;
 	while (lp->rx_free_desc < RX_DCNT) {
-		descptr->skb_ptr = dev_alloc_skb(MAX_BUF_SIZE);
+		descptr->skb_ptr = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 
 		if (!descptr->skb_ptr)
 			break;
@@ -279,11 +381,11 @@ static struct net_device_stats *r6040_get_stats(struct net_device *dev)
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
@@ -291,7 +393,6 @@ static void r6040_down(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
-	int i;
 	int limit = 2048;
 	u16 *adrp;
 	u16 cmd;
@@ -312,26 +413,9 @@ static void r6040_down(struct net_device *dev)
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
-
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
 	pci_free_consistent(lp->pdev, ALLOC_DESC_SIZE,
@@ -431,19 +515,20 @@ static int r6040_rx(struct net_device *dev, int limit)
 
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
-		if (err & 0x0400) priv->stats.rx_errors++;
+		if (err & 0x0400) dev->stats.rx_errors++;
 		/* RX FIFO over-run */
-		if (err & 0x8000) priv->stats.rx_fifo_errors++;
+		if (err & 0x8000) dev->stats.rx_fifo_errors++;
 		/* RX descriptor unavailable */
-		if (err & 0x0080) priv->stats.rx_frame_errors++;
+		if (err & 0x0080) dev->stats.rx_frame_errors++;
 		/* Received packet with length over buffer lenght */
-		if (err & 0x0020) priv->stats.rx_over_errors++;
-		/* Received packet with too long or short */
-		if (err & (0x0010|0x0008)) priv->stats.rx_length_errors++;
+		if (err & 0x0020) dev->stats.rx_over_errors++;
+		/* Received packet too long or short */
+		if (err & 0x0010) dev->stats.rx_lenght_errors++;
+		if (err & 0x0008) dev->stats.rx_length_errors++;
 		/* Received packet with CRC errors */
 		if (err & 0x0004) {
 			spin_lock(&priv->lock);
-			priv->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			spin_unlock(&priv->lock);
 		}
 
@@ -468,8 +553,8 @@ static int r6040_rx(struct net_device *dev, int limit)
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
@@ -497,11 +582,12 @@ static void r6040_tx(struct net_device *dev)
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
 
-		if (err & 0x0200) priv->stats.rx_fifo_errors++;
-		if (err & (0x2000 | 0x4000)) priv->stats.tx_carrier_errors++;
+		if (err & 0x0200) dev->stats.tx_fifo_errors++;
+		if (err & 0x2000) dev->stats.tx_carrier_errors++;
+		if (err & 0x4000) dev->stats.tx_carrier_errors++;
 
 		if (descptr->status & 0x8000)
-			break; /* Not complte */
+			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
 		pci_unmap_single(priv->pdev, descptr->buf,
 			skb_ptr->len, PCI_DMA_TODEVICE);
@@ -544,7 +630,6 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 status;
-	int handled = 1;
 
 	/* Mask off RDC MAC interrupt */
 	iowrite16(MSK_INT, ioaddr + MIER);
@@ -564,7 +649,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	if (status & 0x10)
 		r6040_tx(dev);
 
-	return IRQ_RETVAL(handled);
+	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -581,61 +666,24 @@ static void r6040_poll_controller(struct net_device *dev)
 static void r6040_up(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	struct r6040_descriptor *descptr;
-	void __iomem *ioaddr = lp->base;
-	int i;
 	__le32 tmp_addr;
-	dma_addr_t desc_dma, start_dma;
-
-	/* Initialize */
-	lp->tx_free_desc = TX_DCNT;
-	lp->rx_free_desc = 0;
-	/* Init descriptor */
-	memset(lp->desc_pool, 0, ALLOC_DESC_SIZE); /* Let all descriptor = 0 */
-	lp->tx_insert_ptr = (struct r6040_descriptor *)lp->desc_pool;
-	lp->tx_remove_ptr = lp->tx_insert_ptr;
-	lp->rx_insert_ptr = (struct r6040_descriptor *)lp->tx_insert_ptr +
-		TX_DCNT;
-	lp->rx_remove_ptr = lp->rx_insert_ptr;
-	/* Init TX descriptor */
-	descptr = lp->tx_insert_ptr;
-	desc_dma = lp->desc_dma;
-	start_dma = desc_dma;
-	for (i = 0; i < TX_DCNT; i++) {
-		descptr->ndesc = cpu_to_le32(desc_dma +
-			sizeof(struct r6040_descriptor));
-		descptr->vndescp = (descptr + 1);
-		descptr = (descptr + 1);
-		desc_dma += sizeof(struct r6040_descriptor);
-	}
-	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
-	(descptr - 1)->vndescp = lp->tx_insert_ptr;
+	void __iomem *ioaddr = lp->base;
 
-	/* Init RX descriptor */
-	start_dma = desc_dma;
-	descptr = lp->rx_insert_ptr;
-	for (i = 0; i < RX_DCNT; i++) {
-		descptr->ndesc = cpu_to_le32(desc_dma +
-			sizeof(struct r6040_descriptor));
-		descptr->vndescp = (descptr + 1);
-		descptr = (descptr + 1);
-		desc_dma += sizeof(struct r6040_descriptor);
-	}
-	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
-	(descptr - 1)->vndescp = lp->rx_insert_ptr;
+	r6040_alloc_txbufs(dev);
+	r6040_alloc_rxbufs(dev);
 
 	/* Allocate buffer for RX descriptor */
 	rx_buf_alloc(lp, dev);
 
 	/* TX and RX descriptor start Register */
 	tmp_addr = cpu_to_le32((u32)lp->tx_insert_ptr);
-	tmp_addr = virt_to_bus((volatile void *)tmp_addr);
+	tmp_addr = virt_to_bus((void *)tmp_addr);
 	/* Lower 16-bits to MTD_SA0 */
 	iowrite16(tmp_addr, ioaddr + MTD_SA0);
 	/* Higher 16-bits to MTD_SA1 */
 	iowrite16((u16)(tmp_addr >> 16), ioaddr + MTD_SA1);
 	tmp_addr = cpu_to_le32((u32)lp->rx_insert_ptr);
-	tmp_addr = virt_to_bus((volatile void *)tmp_addr);
+	tmp_addr = virt_to_bus((void *)tmp_addr);
 	iowrite16(tmp_addr, ioaddr + MRD_SA0);
 	iowrite16((u16)(tmp_addr >> 16), ioaddr + MRD_SA1);
 
@@ -703,8 +751,7 @@ static void r6040_timer(unsigned long data)
 	}
 
 	/* Timer active again */
-	lp->timer.expires = TIMER_WUT;
-	add_timer(&lp->timer);
+	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
 }
 
 /* Read/set MAC address routines */
@@ -756,10 +803,8 @@ r6040_open(struct net_device *dev)
 	if (lp->switch_sig != ICPLUS_PHY_ID) {
 		/* set and active a timer process */
 		init_timer(&lp->timer);
-		lp->timer.expires = TIMER_WUT;
 		lp->timer.data = (unsigned long)dev;
 		lp->timer.function = &r6040_timer;
-		add_timer(&lp->timer);
 	}
 	return 0;
 }
@@ -773,12 +818,9 @@ r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	int ret;
 
-	if (!skb)	/* NULL skb directly return */
-		return ret;
-
 	if (skb->len >= MAX_BUF_SIZE) {	/* Packet too long, drop it */
 		dev_kfree_skb(skb);
-		return ret;
+		return NETDEV_TX_OK;
 	}
 
 	/* Critical Section */
@@ -788,8 +830,7 @@ r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!lp->tx_free_desc) {
 		spin_unlock_irqrestore(&lp->lock, flags);
 		printk(KERN_ERR DRV_NAME ": no tx descriptor\n");
-		ret = 1;
-		return ret;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Statistic Counter */
@@ -916,7 +957,7 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	spin_lock_irq(&rp->lock);
 	rc = mii_ethtool_gset(&rp->mii_if, cmd);
-	spin_unlock_irq(&rp->mii_if);
+	spin_unlock_irq(&rp->lock);
 
 	return rc;
 }
@@ -1082,7 +1123,7 @@ static void __devexit r6040_remove_one(struct pci_dev *pdev)
 
 static struct pci_device_id r6040_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, PCI_DEVICE_ID_RDC_R6040) },
-	{0 }
+	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, r6040_pci_tbl);
