From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 1/8] gianfar: Some cleanups for startup_gfar()
Date: Mon, 12 Oct 2009 20:00:26 +0400
Message-ID: <20091012160026.GA2463@oksana.dev.rtsoft.ru>
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

We're going to split the startup_gfar() into 3 separate functions,
so let's cleanup the code a little bit so that cosmetic changes
won't distract attention from logical ones.

- Remove needless casts (e.g. (struct sk_buff **)kmalloc());
- Turn 'unsigned long vaddr;' into 'void *vaddr', to avoid casting;
- Add new 'struct device *dev' variable as a shorthand for
  '&priv->ofdev->dev' that is used all over the place, also rename
  'struct net_device *dev' to 'struct net_device *ndev';
- Turn printk(KERN_ERR ...) to pr_err(...), which is shorter;
- Don't return bogus -1 (i.e. -EPERM) when request_irq() fails;
- Turn '&priv->regs->' to just '&regs->'.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |  143 ++++++++++++++++++++++---------------------------
 1 files changed, 64 insertions(+), 79 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 5bf31f1..8c7322f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -925,16 +925,17 @@ void gfar_start(struct net_device *dev)
 }
 
 /* Bring the controller up and running */
-int startup_gfar(struct net_device *dev)
+int startup_gfar(struct net_device *ndev)
 {
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
 	dma_addr_t addr = 0;
-	unsigned long vaddr;
+	void *vaddr;
 	int i;
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(ndev);
+	struct device *dev = &priv->ofdev->dev;
 	struct gfar __iomem *regs = priv->regs;
-	int err = 0;
+	int err;
 	u32 rctrl = 0;
 	u32 tctrl = 0;
 	u32 attrs = 0;
@@ -942,38 +943,34 @@ int startup_gfar(struct net_device *dev)
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(&priv->ofdev->dev,
-			sizeof (struct txbd8) * priv->tx_ring_size +
-			sizeof (struct rxbd8) * priv->rx_ring_size,
-			&addr, GFP_KERNEL);
-
-	if (vaddr == 0) {
+	vaddr = dma_alloc_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
+					sizeof(*rxbdp) * priv->rx_ring_size,
+				   &addr, GFP_KERNEL);
+	if (!vaddr) {
 		if (netif_msg_ifup(priv))
-			printk(KERN_ERR "%s: Could not allocate buffer descriptors!\n",
-					dev->name);
+			pr_err("%s: Could not allocate buffer descriptors!\n",
+			       ndev->name);
 		return -ENOMEM;
 	}
 
-	priv->tx_bd_base = (struct txbd8 *) vaddr;
+	priv->tx_bd_base = vaddr;
 
 	/* enet DMA only understands physical addresses */
 	gfar_write(&regs->tbase0, addr);
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
-	addr = addr + sizeof (struct txbd8) * priv->tx_ring_size;
-	vaddr = vaddr + sizeof (struct txbd8) * priv->tx_ring_size;
-	priv->rx_bd_base = (struct rxbd8 *) vaddr;
+	addr = addr + sizeof(*txbdp) * priv->tx_ring_size;
+	vaddr = vaddr + sizeof(*txbdp) * priv->tx_ring_size;
+	priv->rx_bd_base = vaddr;
 	gfar_write(&regs->rbase0, addr);
 
 	/* Setup the skbuff rings */
-	priv->tx_skbuff =
-	    (struct sk_buff **) kmalloc(sizeof (struct sk_buff *) *
-					priv->tx_ring_size, GFP_KERNEL);
-
-	if (NULL == priv->tx_skbuff) {
+	priv->tx_skbuff = kmalloc(sizeof(*priv->tx_skbuff) *
+				  priv->tx_ring_size, GFP_KERNEL);
+	if (!priv->tx_skbuff) {
 		if (netif_msg_ifup(priv))
-			printk(KERN_ERR "%s: Could not allocate tx_skbuff\n",
-					dev->name);
+			pr_err("%s: Could not allocate tx_skbuff\n",
+			       ndev->name);
 		err = -ENOMEM;
 		goto tx_skb_fail;
 	}
@@ -981,14 +978,12 @@ int startup_gfar(struct net_device *dev)
 	for (i = 0; i < priv->tx_ring_size; i++)
 		priv->tx_skbuff[i] = NULL;
 
-	priv->rx_skbuff =
-	    (struct sk_buff **) kmalloc(sizeof (struct sk_buff *) *
-					priv->rx_ring_size, GFP_KERNEL);
-
-	if (NULL == priv->rx_skbuff) {
+	priv->rx_skbuff = kmalloc(sizeof(*priv->rx_skbuff) *
+				  priv->rx_ring_size, GFP_KERNEL);
+	if (!priv->rx_skbuff) {
 		if (netif_msg_ifup(priv))
-			printk(KERN_ERR "%s: Could not allocate rx_skbuff\n",
-					dev->name);
+			pr_err("%s: Could not allocate rx_skbuff\n",
+			       ndev->name);
 		err = -ENOMEM;
 		goto rx_skb_fail;
 	}
@@ -1019,18 +1014,16 @@ int startup_gfar(struct net_device *dev)
 	for (i = 0; i < priv->rx_ring_size; i++) {
 		struct sk_buff *skb;
 
-		skb = gfar_new_skb(dev);
-
+		skb = gfar_new_skb(ndev);
 		if (!skb) {
-			printk(KERN_ERR "%s: Can't allocate RX buffers\n",
-					dev->name);
-
+			pr_err("%s: Can't allocate RX buffers\n", ndev->name);
+			err = -ENOMEM;
 			goto err_rxalloc_fail;
 		}
 
 		priv->rx_skbuff[i] = skb;
 
-		gfar_new_rxbdp(dev, rxbdp, skb);
+		gfar_new_rxbdp(ndev, rxbdp, skb);
 
 		rxbdp++;
 	}
@@ -1044,44 +1037,39 @@ int startup_gfar(struct net_device *dev)
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
-		if (request_irq(priv->interruptError, gfar_error,
-				0, priv->int_name_er, dev) < 0) {
+		err = request_irq(priv->interruptError, gfar_error, 0,
+				  priv->int_name_er, ndev);
+		if (err) {
 			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, priv->interruptError);
-
-			err = -1;
+				pr_err("%s: Can't get IRQ %d\n", ndev->name,
+				       priv->interruptError);
 			goto err_irq_fail;
 		}
 
-		if (request_irq(priv->interruptTransmit, gfar_transmit,
-				0, priv->int_name_tx, dev) < 0) {
+		err = request_irq(priv->interruptTransmit, gfar_transmit, 0,
+				  priv->int_name_tx, ndev);
+		if (err) {
 			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, priv->interruptTransmit);
-
-			err = -1;
-
+				pr_err("%s: Can't get IRQ %d\n", ndev->name,
+				       priv->interruptTransmit);
 			goto tx_irq_fail;
 		}
 
-		if (request_irq(priv->interruptReceive, gfar_receive,
-				0, priv->int_name_rx, dev) < 0) {
+		err = request_irq(priv->interruptReceive, gfar_receive, 0,
+				  priv->int_name_rx, ndev);
+		if (err) {
 			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d (receive0)\n",
-						dev->name, priv->interruptReceive);
-
-			err = -1;
+				pr_err("%s: Can't get IRQ %d (receive0)\n",
+				       ndev->name, priv->interruptReceive);
 			goto rx_irq_fail;
 		}
 	} else {
-		if (request_irq(priv->interruptTransmit, gfar_interrupt,
-				0, priv->int_name_tx, dev) < 0) {
+		err = request_irq(priv->interruptTransmit, gfar_interrupt,
+				0, priv->int_name_tx, ndev);
+		if (err) {
 			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, priv->interruptTransmit);
-
-			err = -1;
+				pr_err("%s: Can't get IRQ %d\n", ndev->name,
+				       priv->interruptTransmit);
 			goto err_irq_fail;
 		}
 	}
@@ -1103,7 +1091,7 @@ int startup_gfar(struct net_device *dev)
 	if (priv->extended_hash) {
 		rctrl |= RCTRL_EXTHASH;
 
-		gfar_clear_exact_match(dev);
+		gfar_clear_exact_match(ndev);
 		rctrl |= RCTRL_EMEN;
 	}
 
@@ -1119,18 +1107,18 @@ int startup_gfar(struct net_device *dev)
 	}
 
 	/* Init rctrl based on our settings */
-	gfar_write(&priv->regs->rctrl, rctrl);
+	gfar_write(&regs->rctrl, rctrl);
 
-	if (dev->features & NETIF_F_IP_CSUM)
+	if (ndev->features & NETIF_F_IP_CSUM)
 		tctrl |= TCTRL_INIT_CSUM;
 
-	gfar_write(&priv->regs->tctrl, tctrl);
+	gfar_write(&regs->tctrl, tctrl);
 
 	/* Set the extraction length and index */
 	attrs = ATTRELI_EL(priv->rx_stash_size) |
 		ATTRELI_EI(priv->rx_stash_index);
 
-	gfar_write(&priv->regs->attreli, attrs);
+	gfar_write(&regs->attreli, attrs);
 
 	/* Start with defaults, and add stashing or locking
 	 * depending on the approprate variables */
@@ -1142,32 +1130,29 @@ int startup_gfar(struct net_device *dev)
 	if (priv->rx_stash_size != 0)
 		attrs |= ATTR_BUFSTASH;
 
-	gfar_write(&priv->regs->attr, attrs);
+	gfar_write(&regs->attr, attrs);
 
-	gfar_write(&priv->regs->fifo_tx_thr, priv->fifo_threshold);
-	gfar_write(&priv->regs->fifo_tx_starve, priv->fifo_starve);
-	gfar_write(&priv->regs->fifo_tx_starve_shutoff, priv->fifo_starve_off);
+	gfar_write(&regs->fifo_tx_thr, priv->fifo_threshold);
+	gfar_write(&regs->fifo_tx_starve, priv->fifo_starve);
+	gfar_write(&regs->fifo_tx_starve_shutoff, priv->fifo_starve_off);
 
 	/* Start the controller */
-	gfar_start(dev);
+	gfar_start(ndev);
 
 	return 0;
 
 rx_irq_fail:
-	free_irq(priv->interruptTransmit, dev);
+	free_irq(priv->interruptTransmit, ndev);
 tx_irq_fail:
-	free_irq(priv->interruptError, dev);
+	free_irq(priv->interruptError, ndev);
 err_irq_fail:
 err_rxalloc_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
-	dma_free_coherent(&priv->ofdev->dev,
-			sizeof(struct txbd8)*priv->tx_ring_size
-			+ sizeof(struct rxbd8)*priv->rx_ring_size,
-			priv->tx_bd_base,
-			gfar_read(&regs->tbase0));
-
+	dma_free_coherent(dev, sizeof(*txbdp) * priv->tx_ring_size +
+			       sizeof(*rxbdp) * priv->rx_ring_size,
+			  priv->tx_bd_base, gfar_read(&regs->tbase0));
 	return err;
 }
 
-- 
1.6.3.3
