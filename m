From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 03/10] r6040: fix scheduling while atomic in r6040_tx_timeout
Date: Sun, 13 Jul 2008 14:29:20 +0200
Message-ID: <200807131429.20589.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:47599 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbYGMMaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:30:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper function which only modifies R6040 MAC registers
use it when we timeout, and on adapter initialization. Fix
the scheduling while atomic but in the timeout routine due
to the reallocation of rx/tx buffers.

Signed-Off-By: Joerg Albert <jal2@gmx.de>
Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index d277deb..0972152 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -295,7 +295,6 @@ static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
 static void r6040_rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 {
 	struct r6040_descriptor *descptr;
-	void __iomem *ioaddr = lp->base;
 
 	descptr = lp->rx_insert_ptr;
 	while (lp->rx_free_desc < RX_DCNT) {
@@ -309,8 +308,6 @@ static void r6040_rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 		descptr->status = 0x8000;
 		descptr = descptr->vndescp;
 		lp->rx_free_desc++;
-		/* Trigger RX DMA */
-		iowrite16(lp->mcr0 | 0x0002, ioaddr);
 	}
 	lp->rx_insert_ptr = descptr;
 }
@@ -318,21 +315,16 @@ static void r6040_rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 static void r6040_alloc_txbufs(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	void __iomem *ioaddr = lp->base;
 
 	lp->tx_free_desc = TX_DCNT;
 
 	lp->tx_remove_ptr = lp->tx_insert_ptr = lp->tx_ring;
 	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
-
-	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
-	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
 }
 
 static void r6040_alloc_rxbufs(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	void __iomem *ioaddr = lp->base;
 
 	lp->rx_free_desc = 0;
 
@@ -340,9 +332,58 @@ static void r6040_alloc_rxbufs(struct net_device *dev)
 	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
 
 	r6040_rx_buf_alloc(lp, dev);
+}
+
+static void r6040_init_mac_regs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+	int limit = 2048;
+	u16 cmd;
+
+	/* Mask Off Interrupt */
+	iowrite16(MSK_INT, ioaddr + MIER);
 
+	/* Reset RDC MAC */
+	iowrite16(MAC_RST, ioaddr + MCR1);
+	while (limit--) {
+		cmd = ioread16(ioaddr + MCR1);
+		if (cmd & 0x1)
+			break;
+	}
+	/* Reset internal state machine */
+	iowrite16(2, ioaddr + MAC_SM);
+	iowrite16(0, ioaddr + MAC_SM);
+	udelay(5000);
+
+	/* MAC Bus Control Register */
+	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
+
+	/* Buffer Size Register */
+	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
+
+	/* Write TX ring start address */
+	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
+	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
+
+	/* Write RX ring start address */
 	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
 	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
+
+	/* Set interrupt waiting time and packet numbers */
+	iowrite16(0x0F06, ioaddr + MT_ICR);
+	iowrite16(0x0F06, ioaddr + MR_ICR);
+
+	/* Enable interrupts */
+	iowrite16(INT_MASK, ioaddr + MIER);
+
+	/* Enable TX and RX */
+	iowrite16(lp->mcr0 | 0x0002, ioaddr);
+
+	/* Let TX poll the descriptors
+	 * we may got called by r6040_tx_timeout which has left
+	 * some unsent tx buffers */
+	iowrite16(0x01, ioaddr + MTPR);
 }
 
 static void r6040_tx_timeout(struct net_device *dev)
@@ -350,27 +391,16 @@ static void r6040_tx_timeout(struct net_device *dev)
 	struct r6040_private *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->base;
 
-	printk(KERN_WARNING "%s: transmit timed out, status %4.4x, PHY status "
-		"%4.4x\n",
+	printk(KERN_WARNING "%s: transmit timed out, int enable %4.4x "
+		"status %4.4x, PHY status %4.4x\n",
 		dev->name, ioread16(ioaddr + MIER),
+		ioread16(ioaddr + MISR),
 		r6040_mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
 
-	disable_irq(dev->irq);
-	napi_disable(&priv->napi);
-	spin_lock(&priv->lock);
-	/* Clear all descriptors */
-	r6040_free_txbufs(dev);
-	r6040_free_rxbufs(dev);
-	r6040_alloc_txbufs(dev);
-	r6040_alloc_rxbufs(dev);
-
-	/* Reset MAC */
-	iowrite16(MAC_RST, ioaddr + MCR1);
-	spin_unlock(&priv->lock);
-	enable_irq(dev->irq);
-
 	dev->stats.tx_errors++;
-	netif_wake_queue(dev);
+
+	/* Reset MAC and re-init all registers */
+	r6040_init_mac_regs(dev);
 }
 
 static struct net_device_stats *r6040_get_stats(struct net_device *dev)
@@ -676,8 +706,6 @@ static void r6040_up(struct net_device *dev)
 	r6040_alloc_txbufs(dev);
 	r6040_alloc_rxbufs(dev);
 
-	/* Buffer Size Register */
-	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
 	/* Read the PHY ID */
 	lp->switch_sig = r6040_phy_read(ioaddr, 0, 2);
 
@@ -694,20 +722,9 @@ static void r6040_up(struct net_device *dev)
 		else
 			lp->phy_mode = (PHY_MODE & 0x0100) ? 0x8000:0x0;
 	}
-	/* MAC Bus Control Register :
-	 * - wait 1 host clock SDRAM bus request
-	 * - RX FIFO : 32 bytes 
-	 * - TX FIFO : 64 bytes 
-	 * - FIFO transfer lenght : 16 bytes */
-	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
 
-	/* MAC TX/RX Enable */
+	/* Set duplex mode */
 	lp->mcr0 |= lp->phy_mode;
-	iowrite16(lp->mcr0, ioaddr);
-
-	/* set interrupt waiting time and packet numbers */
-	iowrite16(0x0F06, ioaddr + MT_ICR);
-	iowrite16(0x0F06, ioaddr + MR_ICR);
 
 	/* improve performance (by RDC guys) */
 	r6040_phy_write(ioaddr, 30, 17, (r6040_phy_read(ioaddr, 30, 17) | 0x4000));
@@ -715,8 +732,8 @@ static void r6040_up(struct net_device *dev)
 	r6040_phy_write(ioaddr, 0, 19, 0x0000);
 	r6040_phy_write(ioaddr, 0, 30, 0x01F0);
 
-	/* Interrupt Mask Register */
-	iowrite16(INT_MASK, ioaddr + MIER);
+	/* Initialize all MAC registers */
+	r6040_init_mac_regs(dev);
 }
 
 /*
