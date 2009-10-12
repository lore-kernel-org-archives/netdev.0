From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 4/8] gianfar: Split allocation and initialization steps out
	of startup_gfar()
Date: Mon, 12 Oct 2009 20:00:34 +0400
Message-ID: <20091012160034.GD2463@oksana.dev.rtsoft.ru>
References: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Two new functions implemented: gfar_alloc_skb_resources() and
gfar_init_mac(). We'll use gfar_init_mac() for restoring after
hibernation.

The patch just moves the code around, there should be no functional
changes.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |  334 ++++++++++++++++++++++++++-----------------------
 1 files changed, 176 insertions(+), 158 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ee23431..4dcaaa7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -147,6 +147,176 @@ MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
 
+static int gfar_alloc_skb_resources(struct net_device *ndev)
+{
+	struct txbd8 *txbdp;
+	struct rxbd8 *rxbdp;
+	dma_addr_t addr = 0;
+	void *vaddr;
+	int i;
+	struct gfar_private *priv = netdev_priv(ndev);
+	struct device *dev = &priv->ofdev->dev;
+	struct gfar __iomem *regs = priv->regs;
+
+	/* Allocate memory for the buffer descriptors */
+	vaddr = dma_alloc_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
+					sizeof(*rxbdp) * priv->rx_ring_size,
+				   &addr, GFP_KERNEL);
+	if (!vaddr) {
+		if (netif_msg_ifup(priv))
+			pr_err("%s: Could not allocate buffer descriptors!\n",
+			       ndev->name);
+		return -ENOMEM;
+	}
+
+	priv->tx_bd_base = vaddr;
+
+	/* enet DMA only understands physical addresses */
+	gfar_write(&regs->tbase0, addr);
+
+	/* Start the rx descriptor ring where the tx ring leaves off */
+	addr = addr + sizeof(*txbdp) * priv->tx_ring_size;
+	vaddr = vaddr + sizeof(*txbdp) * priv->tx_ring_size;
+	priv->rx_bd_base = vaddr;
+	gfar_write(&regs->rbase0, addr);
+
+	/* Setup the skbuff rings */
+	priv->tx_skbuff = kmalloc(sizeof(*priv->tx_skbuff) *
+				  priv->tx_ring_size, GFP_KERNEL);
+	if (!priv->tx_skbuff) {
+		if (netif_msg_ifup(priv))
+			pr_err("%s: Could not allocate tx_skbuff\n",
+			       ndev->name);
+		goto cleanup;
+	}
+
+	for (i = 0; i < priv->tx_ring_size; i++)
+		priv->tx_skbuff[i] = NULL;
+
+	priv->rx_skbuff = kmalloc(sizeof(*priv->rx_skbuff) *
+				  priv->rx_ring_size, GFP_KERNEL);
+	if (!priv->rx_skbuff) {
+		if (netif_msg_ifup(priv))
+			pr_err("%s: Could not allocate rx_skbuff\n",
+			       ndev->name);
+		goto cleanup;
+	}
+
+	for (i = 0; i < priv->rx_ring_size; i++)
+		priv->rx_skbuff[i] = NULL;
+
+	/* Initialize some variables in our dev structure */
+	priv->num_txbdfree = priv->tx_ring_size;
+	priv->dirty_tx = priv->cur_tx = priv->tx_bd_base;
+	priv->cur_rx = priv->rx_bd_base;
+	priv->skb_curtx = priv->skb_dirtytx = 0;
+	priv->skb_currx = 0;
+
+	/* Initialize Transmit Descriptor Ring */
+	txbdp = priv->tx_bd_base;
+	for (i = 0; i < priv->tx_ring_size; i++) {
+		txbdp->lstatus = 0;
+		txbdp->bufPtr = 0;
+		txbdp++;
+	}
+
+	/* Set the last descriptor in the ring to indicate wrap */
+	txbdp--;
+	txbdp->status |= TXBD_WRAP;
+
+	rxbdp = priv->rx_bd_base;
+	for (i = 0; i < priv->rx_ring_size; i++) {
+		struct sk_buff *skb;
+
+		skb = gfar_new_skb(ndev);
+		if (!skb) {
+			pr_err("%s: Can't allocate RX buffers\n", ndev->name);
+			goto cleanup;
+		}
+
+		priv->rx_skbuff[i] = skb;
+
+		gfar_new_rxbdp(ndev, rxbdp, skb);
+
+		rxbdp++;
+	}
+
+	return 0;
+
+cleanup:
+	free_skb_resources(priv);
+	return -ENOMEM;
+}
+
+static void gfar_init_mac(struct net_device *ndev)
+{
+	struct gfar_private *priv = netdev_priv(ndev);
+	struct gfar __iomem *regs = priv->regs;
+	u32 rctrl = 0;
+	u32 tctrl = 0;
+	u32 attrs = 0;
+
+	/* Configure the coalescing support */
+	gfar_write(&regs->txic, 0);
+	if (priv->txcoalescing)
+		gfar_write(&regs->txic, priv->txic);
+
+	gfar_write(&regs->rxic, 0);
+	if (priv->rxcoalescing)
+		gfar_write(&regs->rxic, priv->rxic);
+
+	if (priv->rx_csum_enable)
+		rctrl |= RCTRL_CHECKSUMMING;
+
+	if (priv->extended_hash) {
+		rctrl |= RCTRL_EXTHASH;
+
+		gfar_clear_exact_match(ndev);
+		rctrl |= RCTRL_EMEN;
+	}
+
+	if (priv->padding) {
+		rctrl &= ~RCTRL_PAL_MASK;
+		rctrl |= RCTRL_PADDING(priv->padding);
+	}
+
+	/* keep vlan related bits if it's enabled */
+	if (priv->vlgrp) {
+		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
+		tctrl |= TCTRL_VLINS;
+	}
+
+	/* Init rctrl based on our settings */
+	gfar_write(&regs->rctrl, rctrl);
+
+	if (ndev->features & NETIF_F_IP_CSUM)
+		tctrl |= TCTRL_INIT_CSUM;
+
+	gfar_write(&regs->tctrl, tctrl);
+
+	/* Set the extraction length and index */
+	attrs = ATTRELI_EL(priv->rx_stash_size) |
+		ATTRELI_EI(priv->rx_stash_index);
+
+	gfar_write(&regs->attreli, attrs);
+
+	/* Start with defaults, and add stashing or locking
+	 * depending on the approprate variables */
+	attrs = ATTR_INIT_SETTINGS;
+
+	if (priv->bd_stash_en)
+		attrs |= ATTR_BDSTASH;
+
+	if (priv->rx_stash_size != 0)
+		attrs |= ATTR_BUFSTASH;
+
+	gfar_write(&regs->attr, attrs);
+
+	gfar_write(&regs->fifo_tx_thr, priv->fifo_threshold);
+	gfar_write(&regs->fifo_tx_starve, priv->fifo_starve);
+	gfar_write(&regs->fifo_tx_starve_shutoff, priv->fifo_starve_off);
+}
+
 static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_open = gfar_enet_open,
 	.ndo_start_xmit = gfar_start_xmit,
@@ -927,106 +1097,17 @@ void gfar_start(struct net_device *dev)
 /* Bring the controller up and running */
 int startup_gfar(struct net_device *ndev)
 {
-	struct txbd8 *txbdp;
-	struct rxbd8 *rxbdp;
-	dma_addr_t addr = 0;
-	void *vaddr;
-	int i;
 	struct gfar_private *priv = netdev_priv(ndev);
-	struct device *dev = &priv->ofdev->dev;
 	struct gfar __iomem *regs = priv->regs;
 	int err;
-	u32 rctrl = 0;
-	u32 tctrl = 0;
-	u32 attrs = 0;
 
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
-	/* Allocate memory for the buffer descriptors */
-	vaddr = dma_alloc_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
-					sizeof(*rxbdp) * priv->rx_ring_size,
-				   &addr, GFP_KERNEL);
-	if (!vaddr) {
-		if (netif_msg_ifup(priv))
-			pr_err("%s: Could not allocate buffer descriptors!\n",
-			       ndev->name);
-		return -ENOMEM;
-	}
-
-	priv->tx_bd_base = vaddr;
-
-	/* enet DMA only understands physical addresses */
-	gfar_write(&regs->tbase0, addr);
-
-	/* Start the rx descriptor ring where the tx ring leaves off */
-	addr = addr + sizeof(*txbdp) * priv->tx_ring_size;
-	vaddr = vaddr + sizeof(*txbdp) * priv->tx_ring_size;
-	priv->rx_bd_base = vaddr;
-	gfar_write(&regs->rbase0, addr);
-
-	/* Setup the skbuff rings */
-	priv->tx_skbuff = kmalloc(sizeof(*priv->tx_skbuff) *
-				  priv->tx_ring_size, GFP_KERNEL);
-	if (!priv->tx_skbuff) {
-		if (netif_msg_ifup(priv))
-			pr_err("%s: Could not allocate tx_skbuff\n",
-			       ndev->name);
-		err = -ENOMEM;
-		goto tx_skb_fail;
-	}
-
-	for (i = 0; i < priv->tx_ring_size; i++)
-		priv->tx_skbuff[i] = NULL;
-
-	priv->rx_skbuff = kmalloc(sizeof(*priv->rx_skbuff) *
-				  priv->rx_ring_size, GFP_KERNEL);
-	if (!priv->rx_skbuff) {
-		if (netif_msg_ifup(priv))
-			pr_err("%s: Could not allocate rx_skbuff\n",
-			       ndev->name);
-		err = -ENOMEM;
-		goto rx_skb_fail;
-	}
-
-	for (i = 0; i < priv->rx_ring_size; i++)
-		priv->rx_skbuff[i] = NULL;
-
-	/* Initialize some variables in our dev structure */
-	priv->num_txbdfree = priv->tx_ring_size;
-	priv->dirty_tx = priv->cur_tx = priv->tx_bd_base;
-	priv->cur_rx = priv->rx_bd_base;
-	priv->skb_curtx = priv->skb_dirtytx = 0;
-	priv->skb_currx = 0;
-
-	/* Initialize Transmit Descriptor Ring */
-	txbdp = priv->tx_bd_base;
-	for (i = 0; i < priv->tx_ring_size; i++) {
-		txbdp->lstatus = 0;
-		txbdp->bufPtr = 0;
-		txbdp++;
-	}
-
-	/* Set the last descriptor in the ring to indicate wrap */
-	txbdp--;
-	txbdp->status |= TXBD_WRAP;
-
-	rxbdp = priv->rx_bd_base;
-	for (i = 0; i < priv->rx_ring_size; i++) {
-		struct sk_buff *skb;
-
-		skb = gfar_new_skb(ndev);
-		if (!skb) {
-			pr_err("%s: Can't allocate RX buffers\n", ndev->name);
-			err = -ENOMEM;
-			goto err_rxalloc_fail;
-		}
-
-		priv->rx_skbuff[i] = skb;
-
-		gfar_new_rxbdp(ndev, rxbdp, skb);
+	err = gfar_alloc_skb_resources(ndev);
+	if (err)
+		return err;
 
-		rxbdp++;
-	}
+	gfar_init_mac(ndev);
 
 	/* If the device has multiple interrupts, register for
 	 * them.  Otherwise, only register for the one */
@@ -1070,71 +1151,11 @@ int startup_gfar(struct net_device *ndev)
 		}
 	}
 
-	phy_start(priv->phydev);
-
-	/* Configure the coalescing support */
-	gfar_write(&regs->txic, 0);
-	if (priv->txcoalescing)
-		gfar_write(&regs->txic, priv->txic);
-
-	gfar_write(&regs->rxic, 0);
-	if (priv->rxcoalescing)
-		gfar_write(&regs->rxic, priv->rxic);
-
-	if (priv->rx_csum_enable)
-		rctrl |= RCTRL_CHECKSUMMING;
-
-	if (priv->extended_hash) {
-		rctrl |= RCTRL_EXTHASH;
-
-		gfar_clear_exact_match(ndev);
-		rctrl |= RCTRL_EMEN;
-	}
-
-	if (priv->padding) {
-		rctrl &= ~RCTRL_PAL_MASK;
-		rctrl |= RCTRL_PADDING(priv->padding);
-	}
-
-	/* keep vlan related bits if it's enabled */
-	if (priv->vlgrp) {
-		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
-		tctrl |= TCTRL_VLINS;
-	}
-
-	/* Init rctrl based on our settings */
-	gfar_write(&regs->rctrl, rctrl);
-
-	if (ndev->features & NETIF_F_IP_CSUM)
-		tctrl |= TCTRL_INIT_CSUM;
-
-	gfar_write(&regs->tctrl, tctrl);
-
-	/* Set the extraction length and index */
-	attrs = ATTRELI_EL(priv->rx_stash_size) |
-		ATTRELI_EI(priv->rx_stash_index);
-
-	gfar_write(&regs->attreli, attrs);
-
-	/* Start with defaults, and add stashing or locking
-	 * depending on the approprate variables */
-	attrs = ATTR_INIT_SETTINGS;
-
-	if (priv->bd_stash_en)
-		attrs |= ATTR_BDSTASH;
-
-	if (priv->rx_stash_size != 0)
-		attrs |= ATTR_BUFSTASH;
-
-	gfar_write(&regs->attr, attrs);
-
-	gfar_write(&regs->fifo_tx_thr, priv->fifo_threshold);
-	gfar_write(&regs->fifo_tx_starve, priv->fifo_starve);
-	gfar_write(&regs->fifo_tx_starve_shutoff, priv->fifo_starve_off);
-
 	/* Start the controller */
 	gfar_start(ndev);
 
+	phy_start(priv->phydev);
+
 	return 0;
 
 rx_irq_fail:
@@ -1142,9 +1163,6 @@ rx_irq_fail:
 tx_irq_fail:
 	free_irq(priv->interruptError, ndev);
 err_irq_fail:
-err_rxalloc_fail:
-rx_skb_fail:
-tx_skb_fail:
 	free_skb_resources(priv);
 	return err;
 }
-- 
1.6.3.3
