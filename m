From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
Subject: [PATCH v4 3/7] gianfar: Add Multiple Queue Support
Date: Mon,  2 Nov 2009 22:33:15 +0530
Message-ID: <12571813953697-git-send-email-sandeep.kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35868 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517AbZKBPcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 10:32:11 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nA2FWDru029483
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 08:32:14 -0700 (MST)
Received: from udp153986uds.ap.freescale.net (udp153986uds.ap.freescale.net [10.232.134.194])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nA2FZcge000552
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 09:35:51 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

This patch introduces multiple Tx and Rx queues.
The incoming packets can be classified into different queues
based on filer rules (out of scope of this patch). The number
of queues enabled will be based on a DTS entries fsl,num_tx_queues
and fsl,num_rx_queues.

Although we are enabling multiple queues, the interrupt coalescing
is on per device level (etsec-1.7 doesn't support multiple rxics
and txics).

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---
 drivers/net/gianfar.c         |  695 +++++++++++++++++++++++++++--------------
 drivers/net/gianfar.h         |   96 ++++++-
 drivers/net/gianfar_ethtool.c |   70 +++--
 drivers/net/gianfar_sysfs.c   |   50 ++--
 4 files changed, 621 insertions(+), 290 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index fa0188e..aa258e8 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -143,6 +143,7 @@ void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
@@ -171,71 +172,89 @@ static int gfar_init_bds(struct net_device *ndev)
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
-	int i;
-
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
+	int i, j;
 
-	/* Initialize some variables in our dev structure */
-	tx_queue->num_txbdfree = tx_queue->tx_ring_size;
-	tx_queue->dirty_tx = tx_queue->cur_tx = tx_queue->tx_bd_base;
-	rx_queue->cur_rx = rx_queue->rx_bd_base;
-	tx_queue->skb_curtx = tx_queue->skb_dirtytx = 0;
-	rx_queue->skb_currx = 0;
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		tx_queue = priv->tx_queue[i];
+		/* Initialize some variables in our dev structure */
+		tx_queue->num_txbdfree = tx_queue->tx_ring_size;
+		tx_queue->dirty_tx = tx_queue->tx_bd_base;
+		tx_queue->cur_tx = tx_queue->tx_bd_base;
+		tx_queue->skb_curtx = 0;
+		tx_queue->skb_dirtytx = 0;
+
+		/* Initialize Transmit Descriptor Ring */
+		txbdp = tx_queue->tx_bd_base;
+		for (j = 0; j < tx_queue->tx_ring_size; j++) {
+			txbdp->lstatus = 0;
+			txbdp->bufPtr = 0;
+			txbdp++;
+		}
 
-	/* Initialize Transmit Descriptor Ring */
-	txbdp = tx_queue->tx_bd_base;
-	for (i = 0; i < tx_queue->tx_ring_size; i++) {
-		txbdp->lstatus = 0;
-		txbdp->bufPtr = 0;
-		txbdp++;
+		/* Set the last descriptor in the ring to indicate wrap */
+		txbdp--;
+		txbdp->status |= TXBD_WRAP;
 	}
 
-	/* Set the last descriptor in the ring to indicate wrap */
-	txbdp--;
-	txbdp->status |= TXBD_WRAP;
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		rx_queue = priv->rx_queue[i];
+		rx_queue->cur_rx = rx_queue->rx_bd_base;
+		rx_queue->skb_currx = 0;
+		rxbdp = rx_queue->rx_bd_base;
 
-	rxbdp = rx_queue->rx_bd_base;
-	for (i = 0; i < rx_queue->rx_ring_size; i++) {
-		struct sk_buff *skb = rx_queue->rx_skbuff[i];
+		for (j = 0; j < rx_queue->rx_ring_size; j++) {
+			struct sk_buff *skb = rx_queue->rx_skbuff[j];
 
-		if (skb) {
-			gfar_init_rxbdp(rx_queue, rxbdp, rxbdp->bufPtr);
-		} else {
-			skb = gfar_new_skb(ndev);
-			if (!skb) {
-				pr_err("%s: Can't allocate RX buffers\n",
-				       ndev->name);
-				return -ENOMEM;
+			if (skb) {
+				gfar_init_rxbdp(rx_queue, rxbdp,
+						rxbdp->bufPtr);
+			} else {
+				skb = gfar_new_skb(ndev);
+				if (!skb) {
+					pr_err("%s: Can't allocate RX buffers\n",
+							ndev->name);
+					goto err_rxalloc_fail;
+				}
+				rx_queue->rx_skbuff[j] = skb;
+
+				gfar_new_rxbdp(rx_queue, rxbdp, skb);
 			}
-			rx_queue->rx_skbuff[i] = skb;
 
-			gfar_new_rxbdp(rx_queue, rxbdp, skb);
+			rxbdp++;
 		}
 
-		rxbdp++;
 	}
 
 	return 0;
+
+err_rxalloc_fail:
+	free_skb_resources(priv);
+	return -ENOMEM;
 }
 
 static int gfar_alloc_skb_resources(struct net_device *ndev)
 {
 	void *vaddr;
-	int i;
+	dma_addr_t addr;
+	int i, j, k;
 	struct gfar_private *priv = netdev_priv(ndev);
 	struct device *dev = &priv->ofdev->dev;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
+	priv->total_tx_ring_size = 0;
+	for (i = 0; i < priv->num_tx_queues; i++)
+		priv->total_tx_ring_size += priv->tx_queue[i]->tx_ring_size;
+
+	priv->total_rx_ring_size = 0;
+	for (i = 0; i < priv->num_rx_queues; i++)
+		priv->total_rx_ring_size += priv->rx_queue[i]->rx_ring_size;
 
 	/* Allocate memory for the buffer descriptors */
 	vaddr = dma_alloc_coherent(dev,
-			sizeof(*tx_queue->tx_bd_base) * tx_queue->tx_ring_size +
-			sizeof(*rx_queue->rx_bd_base) * rx_queue->rx_ring_size,
-			&tx_queue->tx_bd_dma_base, GFP_KERNEL);
+			sizeof(struct txbd8) * priv->total_tx_ring_size +
+			sizeof(struct rxbd8) * priv->total_rx_ring_size,
+			&addr, GFP_KERNEL);
 	if (!vaddr) {
 		if (netif_msg_ifup(priv))
 			pr_err("%s: Could not allocate buffer descriptors!\n",
@@ -243,38 +262,57 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		return -ENOMEM;
 	}
 
-	tx_queue->tx_bd_base = vaddr;
-	tx_queue->dev = ndev;
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		tx_queue = priv->tx_queue[i];
+		tx_queue->tx_bd_base = (struct txbd8 *) vaddr;
+		tx_queue->tx_bd_dma_base = addr;
+		tx_queue->dev = ndev;
+		/* enet DMA only understands physical addresses */
+		addr    += sizeof(struct txbd8) *tx_queue->tx_ring_size;
+		vaddr   += sizeof(struct txbd8) *tx_queue->tx_ring_size;
+	}
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
-	vaddr = vaddr + sizeof(*tx_queue->tx_bd_base) * tx_queue->tx_ring_size;
-	rx_queue->rx_bd_base = vaddr;
-	rx_queue->dev = ndev;
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		rx_queue = priv->rx_queue[i];
+		rx_queue->rx_bd_base = (struct rxbd8 *) vaddr;
+		rx_queue->rx_bd_dma_base = addr;
+		rx_queue->dev = ndev;
+		addr    += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
+		vaddr   += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
+	}
 
 	/* Setup the skbuff rings */
-	tx_queue->tx_skbuff = kmalloc(sizeof(*tx_queue->tx_skbuff) *
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		tx_queue = priv->tx_queue[i];
+		tx_queue->tx_skbuff = kmalloc(sizeof(*tx_queue->tx_skbuff) *
 				  tx_queue->tx_ring_size, GFP_KERNEL);
-	if (!tx_queue->tx_skbuff) {
-		if (netif_msg_ifup(priv))
-			pr_err("%s: Could not allocate tx_skbuff\n",
-			       ndev->name);
-		goto cleanup;
-	}
+		if (!tx_queue->tx_skbuff) {
+			if (netif_msg_ifup(priv))
+				pr_err("%s: Could not allocate tx_skbuff\n",
+						ndev->name);
+			goto cleanup;
+		}
 
-	for (i = 0; i < tx_queue->tx_ring_size; i++)
-		tx_queue->tx_skbuff[i] = NULL;
+		for (k = 0; k < tx_queue->tx_ring_size; k++)
+			tx_queue->tx_skbuff[k] = NULL;
+	}
 
-	rx_queue->rx_skbuff = kmalloc(sizeof(*rx_queue->rx_skbuff) *
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		rx_queue = priv->rx_queue[i];
+		rx_queue->rx_skbuff = kmalloc(sizeof(*rx_queue->rx_skbuff) *
 				  rx_queue->rx_ring_size, GFP_KERNEL);
-	if (!rx_queue->rx_skbuff) {
-		if (netif_msg_ifup(priv))
-			pr_err("%s: Could not allocate rx_skbuff\n",
-			       ndev->name);
-		goto cleanup;
-	}
 
-	for (i = 0; i < rx_queue->rx_ring_size; i++)
-		rx_queue->rx_skbuff[i] = NULL;
+		if (!rx_queue->rx_skbuff) {
+			if (netif_msg_ifup(priv))
+				pr_err("%s: Could not allocate rx_skbuff\n",
+				       ndev->name);
+			goto cleanup;
+		}
+
+		for (j = 0; j < rx_queue->rx_ring_size; j++)
+			rx_queue->rx_skbuff[j] = NULL;
+	}
 
 	if (gfar_init_bds(ndev))
 		goto cleanup;
@@ -286,33 +324,47 @@ cleanup:
 	return -ENOMEM;
 }
 
+static void gfar_init_tx_rx_base(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = priv->gfargrp.regs;
+	u32 *baddr;
+	int i;
+
+	baddr = &regs->tbase0;
+	for(i = 0; i < priv->num_tx_queues; i++) {
+		gfar_write(baddr, priv->tx_queue[i]->tx_bd_dma_base);
+		baddr	+= 2;
+	}
+
+	baddr = &regs->rbase0;
+	for(i = 0; i < priv->num_rx_queues; i++) {
+		gfar_write(baddr, priv->rx_queue[i]->rx_bd_dma_base);
+		baddr   += 2;
+	}
+}
+
 static void gfar_init_mac(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u32 rctrl = 0;
 	u32 tctrl = 0;
 	u32 attrs = 0;
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
-
-	/* enet DMA only understands physical addresses */
-	gfar_write(&regs->tbase0, tx_queue->tx_bd_dma_base);
-	gfar_write(&regs->rbase0, tx_queue->tx_bd_dma_base +
-				  sizeof(*tx_queue->tx_bd_base) *
-				  tx_queue->tx_ring_size);
+	/* write the tx/rx base registers */
+	gfar_init_tx_rx_base(priv);
 
 	/* Configure the coalescing support */
 	gfar_write(&regs->txic, 0);
-	if (tx_queue->txcoalescing)
-		gfar_write(&regs->txic, tx_queue->txic);
+	if (priv->tx_queue[0]->txcoalescing)
+		gfar_write(&regs->txic, priv->tx_queue[0]->txic);
 
 	gfar_write(&regs->rxic, 0);
-	if (rx_queue->rxcoalescing)
-		gfar_write(&regs->rxic, rx_queue->rxic);
+	if (priv->rx_queue[0]->rxcoalescing)
+		gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
+
+	if (priv->rx_filer_enable)
+		rctrl |= RCTRL_FILREN;
 
 	if (priv->rx_csum_enable)
 		rctrl |= RCTRL_CHECKSUMMING;
@@ -341,6 +393,8 @@ static void gfar_init_mac(struct net_device *ndev)
 	if (ndev->features & NETIF_F_IP_CSUM)
 		tctrl |= TCTRL_INIT_CSUM;
 
+	tctrl |= TCTRL_TXSCHED_PRIO;
+
 	gfar_write(&regs->tctrl, tctrl);
 
 	/* Set the extraction length and index */
@@ -374,6 +428,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_set_multicast_list = gfar_set_multi,
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
+	.ndo_select_queue = gfar_select_queue,
 	.ndo_vlan_rx_register = gfar_vlan_rx_register,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
@@ -382,36 +437,131 @@ static const struct net_device_ops gfar_netdev_ops = {
 #endif
 };
 
+void lock_rx_qs(struct gfar_private *priv)
+{
+	int i = 0x0;
+
+	for (i = 0; i < priv->num_rx_queues; i++)
+		spin_lock(&priv->rx_queue[i]->rxlock);
+}
+
+void lock_tx_qs(struct gfar_private *priv)
+{
+	int i = 0x0;
+
+	for (i = 0; i < priv->num_tx_queues; i++)
+		spin_lock(&priv->tx_queue[i]->txlock);
+}
+
+void unlock_rx_qs(struct gfar_private *priv)
+{
+	int i = 0x0;
+
+	for (i = 0; i < priv->num_rx_queues; i++)
+		spin_unlock(&priv->rx_queue[i]->rxlock);
+}
+
+void unlock_tx_qs(struct gfar_private *priv)
+{
+	int i = 0x0;
+
+	for (i = 0; i < priv->num_tx_queues; i++)
+		spin_unlock(&priv->tx_queue[i]->txlock);
+}
+
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
 	return priv->vlgrp || priv->rx_csum_enable;
 }
 
-static int gfar_of_init(struct net_device *dev)
+u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	return skb_get_queue_mapping(skb);
+}
+static void free_tx_pointers(struct gfar_private *priv)
+{
+	int i = 0;
+
+	for (i = 0; i < priv->num_tx_queues; i++)
+		kfree(priv->tx_queue[i]);
+}
+
+static void free_rx_pointers(struct gfar_private *priv)
+{
+	int i = 0;
+
+	for (i = 0; i < priv->num_rx_queues; i++)
+		kfree(priv->rx_queue[i]);
+}
+
+static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 {
 	const char *model;
 	const char *ctype;
 	const void *mac_addr;
 	u64 addr, size;
-	int err = 0;
-	struct gfar_private *priv = netdev_priv(dev);
-	struct device_node *np = priv->node;
+	int err = 0, i;
+	struct net_device *dev = NULL;
+	struct gfar_private *priv = NULL;
+	struct device_node *np = ofdev->node;
 	const u32 *stash;
 	const u32 *stash_len;
 	const u32 *stash_idx;
+	unsigned int num_tx_qs, num_rx_qs;
+	u32 *tx_queues, *rx_queues;
 
 	if (!np || !of_device_is_available(np))
 		return -ENODEV;
 
+	/* parse the num of tx and rx queues */
+	tx_queues = (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
+	num_tx_qs = tx_queues ? *tx_queues : 1;
+
+	if (num_tx_qs > MAX_TX_QS) {
+		printk(KERN_ERR "num_tx_qs(=%d) greater than MAX_TX_QS(=%d)\n",
+				num_tx_qs, MAX_TX_QS);
+		printk(KERN_ERR "Cannot do alloc_etherdev, aborting\n");
+		return -EINVAL;
+	}
+
+	rx_queues = (u32 *)of_get_property(np, "fsl,num_rx_queues", NULL);
+	num_rx_qs = rx_queues ? *rx_queues : 1;
+
+	if (num_rx_qs > MAX_RX_QS) {
+		printk(KERN_ERR "num_rx_qs(=%d) greater than MAX_RX_QS(=%d)\n",
+				num_tx_qs, MAX_TX_QS);
+		printk(KERN_ERR "Cannot do alloc_etherdev, aborting\n");
+		return -EINVAL;
+	}
+
+	*pdev = alloc_etherdev_mq(sizeof(*priv), num_tx_qs);
+	dev = *pdev;
+	if (NULL == dev)
+		return -ENOMEM;
+
+	priv = netdev_priv(dev);
+	priv->node = ofdev->node;
+	priv->ndev = dev;
+
+	dev->num_tx_queues = num_tx_qs;
+	dev->real_num_tx_queues = num_tx_qs;
+	priv->num_tx_queues = num_tx_qs;
+	priv->num_rx_queues = num_rx_qs;
+
 	/* get a pointer to the register memory */
 	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
 	priv->gfargrp.regs = ioremap(addr, size);
 
-	if (priv->gfargrp.regs == NULL)
-		return -ENOMEM;
+	if (priv->gfargrp.regs == NULL) {
+		err = -ENOMEM;
+		goto err_out;
+	}
 
 	priv->gfargrp.priv = priv; /* back pointer from group to priv */
+	priv->gfargrp.rx_bit_map = DEFAULT_MAPPING;
+	priv->gfargrp.tx_bit_map = DEFAULT_MAPPING;
+
 	priv->gfargrp.interruptTransmit = irq_of_parse_and_map(np, 0);
 
 	model = of_get_property(np, "model", NULL);
@@ -430,6 +580,38 @@ static int gfar_of_init(struct net_device *dev)
 		}
 	}
 
+	for (i = 0; i < priv->num_tx_queues; i++)
+	       priv->tx_queue[i] = NULL;
+	for (i = 0; i < priv->num_rx_queues; i++)
+		priv->rx_queue[i] = NULL;
+
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		priv->tx_queue[i] =  (struct gfar_priv_tx_q *)kmalloc(
+				sizeof (struct gfar_priv_tx_q), GFP_KERNEL);
+		if (!priv->tx_queue[i]) {
+			err = -ENOMEM;
+			goto tx_alloc_failed;
+		}
+		priv->tx_queue[i]->tx_skbuff = NULL;
+		priv->tx_queue[i]->qindex = i;
+		priv->tx_queue[i]->dev = dev;
+		spin_lock_init(&(priv->tx_queue[i]->txlock));
+	}
+
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		priv->rx_queue[i] = (struct gfar_priv_rx_q *)kmalloc(
+					sizeof (struct gfar_priv_rx_q), GFP_KERNEL);
+		if (!priv->rx_queue[i]) {
+			err = -ENOMEM;
+			goto rx_alloc_failed;
+		}
+		priv->rx_queue[i]->rx_skbuff = NULL;
+		priv->rx_queue[i]->qindex = i;
+		priv->rx_queue[i]->dev = dev;
+		spin_lock_init(&(priv->rx_queue[i]->rxlock));
+	}
+
+
 	stash = of_get_property(np, "bd-stash", NULL);
 
 	if (stash) {
@@ -490,8 +672,13 @@ static int gfar_of_init(struct net_device *dev)
 
 	return 0;
 
+rx_alloc_failed:
+	free_rx_pointers(priv);
+tx_alloc_failed:
+	free_tx_pointers(priv);
 err_out:
 	iounmap(priv->gfargrp.regs);
+	free_netdev(dev);
 	return err;
 }
 
@@ -509,6 +696,17 @@ static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
 }
 
+static unsigned int reverse_bitmap(unsigned int bit_map, unsigned int max_qs)
+{
+	unsigned int new_bit_map = 0x0;
+	int mask = 0x1 << (max_qs - 1), i;
+	for (i = 0; i < max_qs; i++) {
+		if (bit_map & mask)
+			new_bit_map = new_bit_map + (1 << i);
+		mask = mask >> 0x1;
+	}
+	return new_bit_map;
+}
 /* Set up the ethernet device structure, private data,
  * and anything else we need before we start */
 static int gfar_probe(struct of_device *ofdev,
@@ -518,14 +716,14 @@ static int gfar_probe(struct of_device *ofdev,
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
 	struct gfar __iomem *regs = NULL;
-	int err = 0;
+	int err = 0, i;
 	int len_devname;
+	u32 rstat = 0, tstat = 0, rqueue = 0, tqueue = 0;
 
-	/* Create an ethernet device instance */
-	dev = alloc_etherdev(sizeof (*priv));
+	err = gfar_of_init(ofdev, &dev);
 
-	if (NULL == dev)
-		return -ENOMEM;
+	if (err)
+		return err;
 
 	priv = netdev_priv(dev);
 	priv->ndev = dev;
@@ -533,23 +731,6 @@ static int gfar_probe(struct of_device *ofdev,
 	priv->node = ofdev->node;
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
-	err = gfar_of_init(dev);
-
-	if (err)
-		goto regs_fail;
-
-	priv->tx_queue = (struct gfar_priv_tx_q *)kmalloc(
-				sizeof (struct gfar_priv_tx_q), GFP_KERNEL);
-	if (!priv->tx_queue)
-		goto regs_fail;
-
-	priv->rx_queue = (struct gfar_priv_rx_q *)kmalloc(
-				sizeof (struct gfar_priv_rx_q), GFP_KERNEL);
-	if (!priv->rx_queue)
-		goto rx_queue_fail;
-
-	spin_lock_init(&priv->tx_queue->txlock);
-	spin_lock_init(&priv->rx_queue->rxlock);
 	spin_lock_init(&priv->gfargrp.grplock);
 	spin_lock_init(&priv->bflock);
 	INIT_WORK(&priv->reset_task, gfar_reset_task);
@@ -587,8 +768,8 @@ static int gfar_probe(struct of_device *ofdev,
 	dev->netdev_ops = &gfar_netdev_ops;
 	dev->ethtool_ops = &gfar_ethtool_ops;
 
-	/* Register for napi ...NAPI is for each rx_queue */
-	netif_napi_add(dev, &priv->rx_queue->napi, gfar_poll, GFAR_DEV_WEIGHT);
+	/* Register for napi ...We are registering NAPI for each grp */
+	netif_napi_add(dev, &priv->gfargrp.napi, gfar_poll, GFAR_DEV_WEIGHT);
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable = 1;
@@ -644,17 +825,44 @@ static int gfar_probe(struct of_device *ofdev,
 	if (dev->features & NETIF_F_IP_CSUM)
 		dev->hard_header_len += GMAC_FCB_LEN;
 
+	/* Need to reverse the bit maps as  bit_map's MSB is q0
+	 * but, for_each_bit parses from right to left, which
+	 * basically reverses the queue numbers */
+	priv->gfargrp.tx_bit_map = reverse_bitmap(priv->gfargrp.tx_bit_map, MAX_TX_QS);
+	priv->gfargrp.rx_bit_map = reverse_bitmap(priv->gfargrp.rx_bit_map, MAX_RX_QS);
+
+	/* Calculate RSTAT, TSTAT, RQUEUE and TQUEUE values */
+	for_each_bit(i, &priv->gfargrp.rx_bit_map, priv->num_rx_queues) {
+		priv->gfargrp.num_rx_queues++;
+		rstat = rstat | (RSTAT_CLEAR_RHALT >> i);
+		rqueue = rqueue | ((RQUEUE_EN0 | RQUEUE_EX0) >> i);
+	}
+	for_each_bit (i, &priv->gfargrp.tx_bit_map, priv->num_tx_queues) {
+		priv->gfargrp.num_tx_queues++;
+		tstat = tstat | (TSTAT_CLEAR_THALT >> i);
+		tqueue = tqueue | (TQUEUE_EN0 >> i);
+	}
+	priv->gfargrp.rstat = rstat;
+	priv->gfargrp.tstat = tstat;
+
+	gfar_write(&regs->rqueue, rqueue);
+	gfar_write(&regs->tqueue, tqueue);
+
 	priv->rx_buffer_size = DEFAULT_RX_BUFFER_SIZE;
 
 	/* Initializing some of the rx/tx queue level parameters */
-	priv->tx_queue->tx_ring_size = DEFAULT_TX_RING_SIZE;
-	priv->tx_queue->num_txbdfree = DEFAULT_TX_RING_SIZE;
-	priv->tx_queue->txcoalescing = DEFAULT_TX_COALESCE;
-	priv->tx_queue->txic = DEFAULT_TXIC;
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		priv->tx_queue[i]->tx_ring_size = DEFAULT_TX_RING_SIZE;
+		priv->tx_queue[i]->num_txbdfree = DEFAULT_TX_RING_SIZE;
+		priv->tx_queue[i]->txcoalescing = DEFAULT_TX_COALESCE;
+		priv->tx_queue[i]->txic = DEFAULT_TXIC;
+	}
 
-	priv->rx_queue->rx_ring_size = DEFAULT_RX_RING_SIZE;
-	priv->rx_queue->rxcoalescing = DEFAULT_RX_COALESCE;
-	priv->rx_queue->rxic = DEFAULT_RXIC;
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		priv->rx_queue[i]->rx_ring_size = DEFAULT_RX_RING_SIZE;
+		priv->rx_queue[i]->rxcoalescing = DEFAULT_RX_COALESCE;
+		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
+	}
 
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
@@ -699,17 +907,19 @@ static int gfar_probe(struct of_device *ofdev,
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
 	printk(KERN_INFO "%s: Running with NAPI enabled\n", dev->name);
-	printk(KERN_INFO "%s: %d/%d RX/TX BD ring size\n",
-	       dev->name, priv->rx_queue->rx_ring_size, priv->tx_queue->tx_ring_size);
+	for (i = 0; i < priv->num_rx_queues; i++)
+		printk(KERN_INFO "%s: :RX BD ring size for Q[%d]: %d\n",
+			dev->name, i, priv->rx_queue[i]->rx_ring_size);
+	for(i = 0; i < priv->num_tx_queues; i++)
+		 printk(KERN_INFO "%s:TX BD ring size for Q[%d]: %d\n",
+			dev->name, i, priv->tx_queue[i]->tx_ring_size);
 
 	return 0;
 
 register_fail:
 	iounmap(priv->gfargrp.regs);
-	kfree(priv->rx_queue);
-rx_queue_fail:
-	kfree(priv->tx_queue);
-regs_fail:
+	free_tx_pointers(priv);
+	free_rx_pointers(priv);
 	if (priv->phy_node)
 		of_node_put(priv->phy_node);
 	if (priv->tbi_node)
@@ -742,8 +952,6 @@ static int gfar_suspend(struct device *dev)
 {
 	struct gfar_private *priv = dev_get_drvdata(dev);
 	struct net_device *ndev = priv->ndev;
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct gfar __iomem *regs = NULL;
 	unsigned long flags;
 	u32 tempval;
@@ -752,13 +960,13 @@ static int gfar_suspend(struct device *dev)
 		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	netif_device_detach(ndev);
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
 	regs = priv->gfargrp.regs;
 
 	if (netif_running(ndev)) {
-		spin_lock_irqsave(&tx_queue->txlock, flags);
-		spin_lock(&rx_queue->rxlock);
+
+		local_irq_save(flags);
+		lock_tx_qs(priv);
+		lock_rx_qs(priv);
 
 		gfar_halt_nodisable(ndev);
 
@@ -772,10 +980,11 @@ static int gfar_suspend(struct device *dev)
 
 		gfar_write(&regs->maccfg1, tempval);
 
-		spin_unlock(&rx_queue->rxlock);
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
+		unlock_rx_qs(priv);
+		unlock_tx_qs(priv);
+		local_irq_restore(flags);
 
-		napi_disable(&rx_queue->napi);
+		napi_disable(&priv->gfargrp.napi);
 
 		if (magic_packet) {
 			/* Enable interrupt on Magic Packet */
@@ -797,8 +1006,6 @@ static int gfar_resume(struct device *dev)
 {
 	struct gfar_private *priv = dev_get_drvdata(dev);
 	struct net_device *ndev = priv->ndev;
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct gfar __iomem *regs = NULL;
 	unsigned long flags;
 	u32 tempval;
@@ -816,12 +1023,11 @@ static int gfar_resume(struct device *dev)
 	/* Disable Magic Packet mode, in case something
 	 * else woke us up.
 	 */
-	rx_queue = priv->rx_queue;
-	tx_queue = priv->tx_queue;
 	regs = priv->gfargrp.regs;
 
-	spin_lock_irqsave(&tx_queue->txlock, flags);
-	spin_lock(&rx_queue->rxlock);
+	local_irq_save(flags);
+	lock_tx_qs(priv);
+	lock_rx_qs(priv);
 
 	tempval = gfar_read(&regs->maccfg2);
 	tempval &= ~MACCFG2_MPEN;
@@ -829,12 +1035,13 @@ static int gfar_resume(struct device *dev)
 
 	gfar_start(ndev);
 
-	spin_unlock(&rx_queue->rxlock);
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	unlock_rx_qs(priv);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 
 	netif_device_attach(ndev);
 
-	napi_enable(&rx_queue->napi);
+	napi_enable(&priv->gfargrp.napi);
 
 	return 0;
 }
@@ -861,7 +1068,7 @@ static int gfar_restore(struct device *dev)
 		phy_start(priv->phydev);
 
 	netif_device_attach(ndev);
-	napi_enable(&priv->napi);
+	napi_enable(&priv->gfargrp.napi);
 
 	return 0;
 }
@@ -1115,23 +1322,21 @@ void gfar_halt(struct net_device *dev)
 void stop_gfar(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned long flags;
 
 	phy_stop(priv->phydev);
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
 
 	/* Lock it down */
-	spin_lock_irqsave(&tx_queue->txlock, flags);
-	spin_lock(&rx_queue->rxlock);
+	local_irq_save(flags);
+	lock_tx_qs(priv);
+	lock_rx_qs(priv);
 
 	gfar_halt(dev);
 
-	spin_unlock(&rx_queue->rxlock);
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	unlock_rx_qs(priv);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 
 	/* Free the IRQs */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
@@ -1145,24 +1350,14 @@ void stop_gfar(struct net_device *dev)
 	free_skb_resources(priv);
 }
 
-/* If there are any tx skbs or rx skbs still around, free them.
- * Then free tx_skbuff and rx_skbuff */
-static void free_skb_resources(struct gfar_private *priv)
+static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
 {
-	struct device *dev = &priv->ofdev->dev;
-	struct rxbd8 *rxbdp;
 	struct txbd8 *txbdp;
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
+	struct gfar_private *priv = netdev_priv(tx_queue->dev);
 	int i, j;
 
-	/* Go through all the buffer descriptors and free their data buffers */
-	tx_queue = priv->tx_queue;
 	txbdp = tx_queue->tx_bd_base;
 
-	if (!tx_queue->tx_skbuff)
-		goto skip_tx_skbuff;
-
 	for (i = 0; i < tx_queue->tx_ring_size; i++) {
 		if (!tx_queue->tx_skbuff[i])
 			continue;
@@ -1170,7 +1365,8 @@ static void free_skb_resources(struct gfar_private *priv)
 		dma_unmap_single(&priv->ofdev->dev, txbdp->bufPtr,
 				txbdp->length, DMA_TO_DEVICE);
 		txbdp->lstatus = 0;
-		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags; j++) {
+		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags;
+				j++) {
 			txbdp++;
 			dma_unmap_page(&priv->ofdev->dev, txbdp->bufPtr,
 					txbdp->length, DMA_TO_DEVICE);
@@ -1179,36 +1375,58 @@ static void free_skb_resources(struct gfar_private *priv)
 		dev_kfree_skb_any(tx_queue->tx_skbuff[i]);
 		tx_queue->tx_skbuff[i] = NULL;
 	}
-
 	kfree(tx_queue->tx_skbuff);
-skip_tx_skbuff:
+}
 
-	rx_queue = priv->rx_queue;
-	rxbdp = rx_queue->rx_bd_base;
+static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
+{
+	struct rxbd8 *rxbdp;
+	struct gfar_private *priv = netdev_priv(rx_queue->dev);
+	int i;
 
-	if (!rx_queue->rx_skbuff)
-		goto skip_rx_skbuff;
+	rxbdp = rx_queue->rx_bd_base;
 
 	for (i = 0; i < rx_queue->rx_ring_size; i++) {
 		if (rx_queue->rx_skbuff[i]) {
-			dma_unmap_single(&priv->ofdev->dev, rxbdp->bufPtr,
-					 priv->rx_buffer_size,
+			dma_unmap_single(&priv->ofdev->dev,
+					rxbdp->bufPtr, priv->rx_buffer_size,
 					DMA_FROM_DEVICE);
 			dev_kfree_skb_any(rx_queue->rx_skbuff[i]);
 			rx_queue->rx_skbuff[i] = NULL;
 		}
-
 		rxbdp->lstatus = 0;
 		rxbdp->bufPtr = 0;
 		rxbdp++;
 	}
-
 	kfree(rx_queue->rx_skbuff);
-skip_rx_skbuff:
+}
 
-	dma_free_coherent(dev, sizeof(*txbdp) * tx_queue->tx_ring_size +
-			       sizeof(*rxbdp) * rx_queue->rx_ring_size,
-			  tx_queue->tx_bd_base, tx_queue->tx_bd_dma_base);
+/* If there are any tx skbs or rx skbs still around, free them.
+ * Then free tx_skbuff and rx_skbuff */
+static void free_skb_resources(struct gfar_private *priv)
+{
+	struct gfar_priv_tx_q *tx_queue = NULL;
+	struct gfar_priv_rx_q *rx_queue = NULL;
+	int i;
+
+	/* Go through all the buffer descriptors and free their data buffers */
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		tx_queue = priv->tx_queue[i];
+		if(!tx_queue->tx_skbuff)
+			free_skb_tx_queue(tx_queue);
+	}
+
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		rx_queue = priv->rx_queue[i];
+		if(!rx_queue->rx_skbuff)
+			free_skb_rx_queue(rx_queue);
+	}
+
+	dma_free_coherent(&priv->ofdev->dev,
+			sizeof(struct txbd8) * priv->total_tx_ring_size +
+			sizeof(struct rxbd8) * priv->total_rx_ring_size,
+			priv->tx_queue[0]->tx_bd_base,
+			priv->tx_queue[0]->tx_bd_dma_base);
 }
 
 void gfar_start(struct net_device *dev)
@@ -1233,8 +1451,8 @@ void gfar_start(struct net_device *dev)
 	gfar_write(&regs->dmactrl, tempval);
 
 	/* Clear THLT/RHLT, so that the DMA starts polling now */
-	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
-	gfar_write(&regs->rstat, RSTAT_CLEAR_RHALT);
+	gfar_write(&regs->tstat, priv->gfargrp.tstat);
+	gfar_write(&regs->rstat, priv->gfargrp.rstat);
 
 	/* Unmask the interrupts we look for */
 	gfar_write(&regs->imask, IMASK_DEFAULT);
@@ -1329,7 +1547,7 @@ static int gfar_enet_open(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	int err;
 
-	napi_enable(&priv->rx_queue->napi);
+	napi_enable(&priv->gfargrp.napi);
 
 	skb_queue_head_init(&priv->rx_recycle);
 
@@ -1341,17 +1559,17 @@ static int gfar_enet_open(struct net_device *dev)
 	err = init_phy(dev);
 
 	if (err) {
-		napi_disable(&priv->rx_queue->napi);
+		napi_disable(&priv->gfargrp.napi);
 		return err;
 	}
 
 	err = startup_gfar(dev);
 	if (err) {
-		napi_disable(&priv->rx_queue->napi);
+		napi_disable(&priv->gfargrp.napi);
 		return err;
 	}
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	device_set_wakeup_enable(&dev->dev, priv->wol_en);
 
@@ -1421,16 +1639,20 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_tx_q *tx_queue = NULL;
+	struct netdev_queue *txq;
 	struct gfar __iomem *regs = NULL;
 	struct txfcb *fcb = NULL;
 	struct txbd8 *txbdp, *txbdp_start, *base;
 	u32 lstatus;
-	int i;
+	int i, rq = 0;
 	u32 bufaddr;
 	unsigned long flags;
 	unsigned int nr_frags, length;
 
-	tx_queue = priv->tx_queue;
+
+	rq = skb->queue_mapping;
+	tx_queue = priv->tx_queue[rq];
+	txq = netdev_get_tx_queue(dev, rq);
 	base = tx_queue->tx_bd_base;
 	regs = priv->gfargrp.regs;
 
@@ -1458,7 +1680,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* check if there is space to queue this packet */
 	if ((nr_frags+1) > tx_queue->num_txbdfree) {
 		/* no space, stop the queue */
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		dev->stats.tx_fifo_errors++;
 		spin_unlock_irqrestore(&tx_queue->txlock, flags);
 		return NETDEV_TX_BUSY;
@@ -1550,13 +1772,13 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
 	if (!tx_queue->num_txbdfree) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 
 		dev->stats.tx_fifo_errors++;
 	}
 
 	/* Tell the DMA to go go go */
-	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
+	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT >> tx_queue->qindex);
 
 	/* Unlock priv */
 	spin_unlock_irqrestore(&tx_queue->txlock, flags);
@@ -1569,7 +1791,7 @@ static int gfar_close(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	napi_disable(&priv->rx_queue->napi);
+	napi_disable(&priv->gfargrp.napi);
 
 	skb_queue_purge(&priv->rx_recycle);
 	cancel_work_sync(&priv->reset_task);
@@ -1579,7 +1801,7 @@ static int gfar_close(struct net_device *dev)
 	phy_disconnect(priv->phydev);
 	priv->phydev = NULL;
 
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	return 0;
 }
@@ -1598,14 +1820,13 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 		struct vlan_group *grp)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct gfar __iomem *regs = NULL;
 	unsigned long flags;
 	u32 tempval;
 
-	rx_queue = priv->rx_queue;
 	regs = priv->gfargrp.regs;
-	spin_lock_irqsave(&rx_queue->rxlock, flags);
+	local_irq_save(flags);
+	lock_rx_qs(priv);
 
 	priv->vlgrp = grp;
 
@@ -1639,7 +1860,8 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 
 	gfar_change_mtu(dev, dev->mtu);
 
-	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
+	unlock_rx_qs(priv);
+	local_irq_restore(flags);
 }
 
 static int gfar_change_mtu(struct net_device *dev, int new_mtu)
@@ -1711,10 +1933,10 @@ static void gfar_reset_task(struct work_struct *work)
 	struct net_device *dev = priv->ndev;
 
 	if (dev->flags & IFF_UP) {
-		netif_stop_queue(dev);
+		netif_tx_stop_all_queues(dev);
 		stop_gfar(dev);
 		startup_gfar(dev);
-		netif_start_queue(dev);
+		netif_tx_start_all_queues(dev);
 	}
 
 	netif_tx_schedule_all(dev);
@@ -1745,7 +1967,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	int howmany = 0;
 	u32 lstatus;
 
-	rx_queue = priv->rx_queue;
+	rx_queue = priv->rx_queue[tx_queue->qindex];
 	bdp = tx_queue->dirty_tx;
 	skb_dirtytx = tx_queue->skb_dirtytx;
 
@@ -1798,8 +2020,8 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	}
 
 	/* If we freed a buffer, we can restart transmission, if necessary */
-	if (netif_queue_stopped(dev) && tx_queue->num_txbdfree)
-		netif_wake_queue(dev);
+	if (__netif_subqueue_stopped(dev, tx_queue->qindex) && tx_queue->num_txbdfree)
+		netif_wake_subqueue(dev, tx_queue->qindex);
 
 	/* Update dirty indicators */
 	tx_queue->skb_dirtytx = skb_dirtytx;
@@ -1812,19 +2034,12 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
 {
-	struct gfar_private *priv = gfargrp->priv;
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned long flags;
 
-	rx_queue = priv->rx_queue;
-	tx_queue = priv->tx_queue;
-	spin_lock_irqsave(&tx_queue->txlock, flags);
-	spin_lock(&rx_queue->rxlock);
-
-	if (napi_schedule_prep(&rx_queue->napi)) {
+	spin_lock_irqsave(&gfargrp->grplock, flags);
+	if (napi_schedule_prep(&gfargrp->napi)) {
 		gfar_write(&gfargrp->regs->imask, IMASK_RTX_DISABLED);
-		__napi_schedule(&rx_queue->napi);
+		__napi_schedule(&gfargrp->napi);
 	} else {
 		/*
 		 * Clear IEVENT, so interrupts aren't called again
@@ -1832,9 +2047,8 @@ static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
 		 */
 		gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
 	}
+	spin_unlock_irqrestore(&gfargrp->grplock, flags);
 
-	spin_unlock(&rx_queue->rxlock);
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
 }
 
 /* Interrupt Handler for Transmit complete */
@@ -1952,6 +2166,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	fcb = (struct rxfcb *)skb->data;
 
 	/* Remove the FCB from the skb */
+	skb_set_queue_mapping(skb, fcb->rq);
 	/* Remove the padded bytes, if there are any */
 	if (amount_pull)
 		skb_pull(skb, amount_pull);
@@ -2072,28 +2287,54 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
-	struct gfar_priv_rx_q *rx_queue = container_of(napi,
-			struct gfar_priv_rx_q, napi);
-	struct net_device *dev = rx_queue->dev;
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_priv_grp *gfargrp = container_of(napi,
+			struct gfar_priv_grp, napi);
+	struct gfar_private *priv = gfargrp->priv;
 	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
-	int tx_cleaned = 0;
-	int rx_cleaned = 0;
+	struct gfar_priv_rx_q *rx_queue = NULL;
+	int rx_cleaned = 0, budget_per_queue = 0, rx_cleaned_per_queue = 0;
+	int tx_cleaned = 0, i, left_over_budget = budget, serviced_queues = 0;
+	int num_queues = 0;
 	unsigned long flags;
 
+	num_queues = gfargrp->num_rx_queues;
+	budget_per_queue = budget/num_queues;
+
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived */
 	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
-	tx_queue = priv->tx_queue;
 
-	/* If we fail to get the lock, don't bother with the TX BDs */
-	if (spin_trylock_irqsave(&tx_queue->txlock, flags)) {
-		tx_cleaned = gfar_clean_tx_ring(tx_queue);
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
-	}
+	while (num_queues && left_over_budget) {
 
-	rx_cleaned = gfar_clean_rx_ring(rx_queue, budget);
+		budget_per_queue = left_over_budget/num_queues;
+		left_over_budget = 0;
+
+		for_each_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
+			if (test_bit(i, &serviced_queues))
+				continue;
+			rx_queue = priv->rx_queue[i];
+			tx_queue = priv->tx_queue[rx_queue->qindex];
+
+			/* If we fail to get the lock,
+			 * don't bother with the TX BDs */
+			if (spin_trylock_irqsave(&tx_queue->txlock, flags)) {
+				tx_cleaned += gfar_clean_tx_ring(tx_queue);
+				spin_unlock_irqrestore(&tx_queue->txlock,
+							flags);
+			}
+
+			rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
+							budget_per_queue);
+			rx_cleaned += rx_cleaned_per_queue;
+			if(rx_cleaned_per_queue < budget_per_queue) {
+				left_over_budget = left_over_budget +
+					(budget_per_queue - rx_cleaned_per_queue);
+				set_bit(i, &serviced_queues);
+				num_queues--;
+			}
+		}
+	}
 
 	if (tx_cleaned)
 		return budget;
@@ -2102,7 +2343,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 
 		/* Clear the halt bit in RSTAT */
-		gfar_write(&regs->rstat, RSTAT_CLEAR_RHALT);
+		gfar_write(&regs->rstat, gfargrp->rstat);
 
 		gfar_write(&regs->imask, IMASK_DEFAULT);
 
@@ -2180,14 +2421,14 @@ static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 static void adjust_link(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar __iomem *regs = priv->gfargrp.regs;
 	unsigned long flags;
 	struct phy_device *phydev = priv->phydev;
 	int new_state = 0;
 
-	tx_queue = priv->tx_queue;
-	spin_lock_irqsave(&tx_queue->txlock, flags);
+	local_irq_save(flags);
+	lock_tx_qs(priv);
+
 	if (phydev->link) {
 		u32 tempval = gfar_read(&regs->maccfg2);
 		u32 ecntrl = gfar_read(&regs->ecntrl);
@@ -2252,8 +2493,8 @@ static void adjust_link(struct net_device *dev)
 
 	if (new_state && netif_msg_link(priv))
 		phy_print_status(phydev);
-
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 }
 
 /* Update the hash table based on the current list of multicast
@@ -2457,7 +2698,7 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 			priv->extra_stats.tx_underrun++;
 
 			/* Reactivate the Tx Queues */
-			gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
+			gfar_write(&regs->tstat, gfargrp->tstat);
 		}
 		if (netif_msg_tx_err(priv))
 			printk(KERN_DEBUG "%s: Transmit Error\n", dev->name);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 79e8471..5ae769d 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -75,6 +75,10 @@
 extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
 
+/* MAXIMUM NUMBER OF QUEUES SUPPORTED */
+#define MAX_TX_QS	0x8
+#define MAX_RX_QS	0x8
+
 /* These need to be powers of 2 for this driver */
 #define DEFAULT_TX_RING_SIZE	256
 #define DEFAULT_RX_RING_SIZE	256
@@ -172,12 +176,63 @@ extern const char gfar_driver_version[];
 
 #define MINFLR_INIT_SETTINGS	0x00000040
 
+/* Tqueue control */
+#define TQUEUE_EN0		0x00008000
+#define TQUEUE_EN1		0x00004000
+#define TQUEUE_EN2		0x00002000
+#define TQUEUE_EN3		0x00001000
+#define TQUEUE_EN4		0x00000800
+#define TQUEUE_EN5		0x00000400
+#define TQUEUE_EN6		0x00000200
+#define TQUEUE_EN7		0x00000100
+#define TQUEUE_EN_ALL		0x0000FF00
+
+#define TR03WT_WT0_MASK		0xFF000000
+#define TR03WT_WT1_MASK		0x00FF0000
+#define TR03WT_WT2_MASK		0x0000FF00
+#define TR03WT_WT3_MASK		0x000000FF
+
+#define TR47WT_WT4_MASK		0xFF000000
+#define TR47WT_WT5_MASK		0x00FF0000
+#define TR47WT_WT6_MASK		0x0000FF00
+#define TR47WT_WT7_MASK		0x000000FF
+
+/* Rqueue control */
+#define RQUEUE_EX0		0x00800000
+#define RQUEUE_EX1		0x00400000
+#define RQUEUE_EX2		0x00200000
+#define RQUEUE_EX3		0x00100000
+#define RQUEUE_EX4		0x00080000
+#define RQUEUE_EX5		0x00040000
+#define RQUEUE_EX6		0x00020000
+#define RQUEUE_EX7		0x00010000
+#define RQUEUE_EX_ALL		0x00FF0000
+
+#define RQUEUE_EN0		0x00000080
+#define RQUEUE_EN1		0x00000040
+#define RQUEUE_EN2		0x00000020
+#define RQUEUE_EN3		0x00000010
+#define RQUEUE_EN4		0x00000008
+#define RQUEUE_EN5		0x00000004
+#define RQUEUE_EN6		0x00000002
+#define RQUEUE_EN7		0x00000001
+#define RQUEUE_EN_ALL		0x000000FF
+
 /* Init to do tx snooping for buffers and descriptors */
 #define DMACTRL_INIT_SETTINGS   0x000000c3
 #define DMACTRL_GRS             0x00000010
 #define DMACTRL_GTS             0x00000008
 
-#define TSTAT_CLEAR_THALT       0x80000000
+#define TSTAT_CLEAR_THALT_ALL	0xFF000000
+#define TSTAT_CLEAR_THALT	0x80000000
+#define TSTAT_CLEAR_THALT0	0x80000000
+#define TSTAT_CLEAR_THALT1	0x40000000
+#define TSTAT_CLEAR_THALT2	0x20000000
+#define TSTAT_CLEAR_THALT3	0x10000000
+#define TSTAT_CLEAR_THALT4	0x08000000
+#define TSTAT_CLEAR_THALT5	0x04000000
+#define TSTAT_CLEAR_THALT6	0x02000000
+#define TSTAT_CLEAR_THALT7	0x01000000
 
 /* Interrupt coalescing macros */
 #define IC_ICEN			0x80000000
@@ -228,6 +283,13 @@ extern const char gfar_driver_version[];
 #define TCTRL_IPCSEN		0x00004000
 #define TCTRL_TUCSEN		0x00002000
 #define TCTRL_VLINS		0x00001000
+#define TCTRL_THDF		0x00000800
+#define TCTRL_RFCPAUSE		0x00000010
+#define TCTRL_TFCPAUSE		0x00000008
+#define TCTRL_TXSCHED_MASK	0x00000006
+#define TCTRL_TXSCHED_INIT	0x00000000
+#define TCTRL_TXSCHED_PRIO	0x00000002
+#define TCTRL_TXSCHED_WRRS	0x00000004
 #define TCTRL_INIT_CSUM		(TCTRL_TUCSEN | TCTRL_IPCSEN)
 
 #define IEVENT_INIT_CLEAR	0xffffffff
@@ -700,6 +762,8 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
 
+#define DEFAULT_MAPPING 	0xFF
+
 /**
  *	struct gfar_priv_tx_q - per tx queue structure
  *	@txlock: per queue tx spin lock
@@ -743,7 +807,6 @@ struct gfar_priv_tx_q {
 /**
  *	struct gfar_priv_rx_q - per rx queue structure
  *	@rxlock: per queue rx spin lock
- *	@napi: the napi poll function
  *	@rx_skbuff: skb pointers
  *	@skb_currx: currently use skb pointer
  *	@rx_bd_base: First rx buffer descriptor
@@ -757,8 +820,8 @@ struct gfar_priv_tx_q {
 
 struct gfar_priv_rx_q {
 	spinlock_t rxlock __attribute__ ((aligned (SMP_CACHE_BYTES)));
-	struct	napi_struct napi;
 	struct	sk_buff ** rx_skbuff;
+	dma_addr_t rx_bd_dma_base;
 	struct	rxbd8 *rx_bd_base;
 	struct	rxbd8 *cur_rx;
 	struct	net_device *dev;
@@ -772,6 +835,7 @@ struct gfar_priv_rx_q {
 
 /**
  *	struct gfar_priv_grp - per group structure
+ *	@napi: the napi poll function
  *	@priv: back pointer to the priv structure
  *	@regs: the ioremapped register space for this group
  *	@grp_id: group id for this group
@@ -785,8 +849,17 @@ struct gfar_priv_rx_q {
 
 struct gfar_priv_grp {
 	spinlock_t grplock __attribute__ ((aligned (SMP_CACHE_BYTES)));
+	struct	napi_struct napi;
 	struct gfar_private *priv;
 	struct gfar __iomem *regs;
+	unsigned int rx_bit_map;
+	unsigned int tx_bit_map;
+	unsigned int num_tx_queues;
+	unsigned int num_rx_queues;
+	unsigned int rstat;
+	unsigned int tstat;
+	unsigned int imask;
+	unsigned int ievent;
 	unsigned int interruptTransmit;
 	unsigned int interruptReceive;
 	unsigned int interruptError;
@@ -807,13 +880,21 @@ struct gfar_priv_grp {
  */
 struct gfar_private {
 
+	/* Indicates how many tx, rx queues are enabled */
+	unsigned int num_tx_queues;
+	unsigned int num_rx_queues;
+
+	/* The total tx and rx ring size for the enabled queues */
+	unsigned int total_tx_ring_size;
+	unsigned int total_rx_ring_size;
+
 	struct device_node *node;
 	struct net_device *ndev;
 	struct of_device *ofdev;
 
 	struct gfar_priv_grp gfargrp;
-	struct gfar_priv_tx_q *tx_queue;
-	struct gfar_priv_rx_q *rx_queue;
+	struct gfar_priv_tx_q *tx_queue[MAX_TX_QS];
+	struct gfar_priv_rx_q *rx_queue[MAX_RX_QS];
 
 	/* RX per device parameters */
 	unsigned int rx_buffer_size;
@@ -844,6 +925,7 @@ struct gfar_private {
 	unsigned char rx_csum_enable:1,
 		extended_hash:1,
 		bd_stash_en:1,
+		rx_filer_enable:1,
 		wol_en:1; /* Wake-on-LAN enabled */
 	unsigned short padding;
 
@@ -874,6 +956,10 @@ static inline void gfar_write(volatile unsigned __iomem *addr, u32 val)
 	out_be32(addr, val);
 }
 
+extern void lock_rx_qs(struct gfar_private *priv);
+extern void lock_tx_qs(struct gfar_private *priv);
+extern void unlock_rx_qs(struct gfar_private *priv);
+extern void unlock_tx_qs(struct gfar_private *priv);
 extern irqreturn_t gfar_receive(int irq, void *dev_id);
 extern int startup_gfar(struct net_device *dev);
 extern void stop_gfar(struct net_device *dev);
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index c681b41..d3d2623 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -204,9 +204,11 @@ static int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	if (NULL == phydev)
 		return -ENODEV;
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
+	tx_queue = priv->tx_queue[0];
+	rx_queue = priv->rx_queue[0];
 
+	/* etsec-1.7 and older versions have only one txic
+	 * and rxic regs although they support multiple queues */
 	cmd->maxtxpkt = get_icft_value(tx_queue->txic);
 	cmd->maxrxpkt = get_icft_value(rx_queue->rxic);
 
@@ -298,8 +300,8 @@ static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	if (NULL == priv->phydev)
 		return -ENODEV;
 
-	rx_queue = priv->rx_queue;
-	tx_queue = priv->tx_queue;
+	rx_queue = priv->rx_queue[0];
+	tx_queue = priv->tx_queue[0];
 
 	rxtime  = get_ictt_value(rx_queue->rxic);
 	rxcount = get_icft_value(rx_queue->rxic);
@@ -357,8 +359,8 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
+	tx_queue = priv->tx_queue[0];
+	rx_queue = priv->rx_queue[0];
 
 	/* Set up rx coalescing */
 	if ((cvals->rx_coalesce_usecs == 0) ||
@@ -429,8 +431,8 @@ static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rv
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
+	tx_queue = priv->tx_queue[0];
+	rx_queue = priv->rx_queue[0];
 
 	rvals->rx_max_pending = GFAR_RX_MAX_RING_SIZE;
 	rvals->rx_mini_max_pending = GFAR_RX_MAX_RING_SIZE;
@@ -453,9 +455,7 @@ static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rv
 static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar_priv_rx_q *rx_queue = NULL;
-	int err = 0;
+	int err = 0, i = 0;
 
 	if (rvals->rx_pending > GFAR_RX_MAX_RING_SIZE)
 		return -EINVAL;
@@ -475,37 +475,41 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 		return -EINVAL;
 	}
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
 
 	if (dev->flags & IFF_UP) {
 		unsigned long flags;
 
 		/* Halt TX and RX, and process the frames which
 		 * have already been received */
-		spin_lock_irqsave(&tx_queue->txlock, flags);
-		spin_lock(&rx_queue->rxlock);
+		local_irq_save(flags);
+		lock_tx_qs(priv);
+		lock_rx_qs(priv);
 
 		gfar_halt(dev);
 
-		spin_unlock(&rx_queue->rxlock);
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
+		unlock_rx_qs(priv);
+		unlock_tx_qs(priv);
+		local_irq_restore(flags);
 
-		gfar_clean_rx_ring(rx_queue, rx_queue->rx_ring_size);
+		for (i = 0; i < priv->num_rx_queues; i++)
+			gfar_clean_rx_ring(priv->rx_queue[i],
+					priv->rx_queue[i]->rx_ring_size);
 
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
 	}
 
 	/* Change the size */
-	rx_queue->rx_ring_size = rvals->rx_pending;
-	tx_queue->tx_ring_size = rvals->tx_pending;
-	tx_queue->num_txbdfree = tx_queue->tx_ring_size;
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		priv->rx_queue[i]->rx_ring_size = rvals->rx_pending;
+		priv->tx_queue[i]->tx_ring_size = rvals->tx_pending;
+		priv->tx_queue[i]->num_txbdfree = priv->tx_queue[i]->tx_ring_size;
+	}
 
 	/* Rebuild the rings with the new size */
 	if (dev->flags & IFF_UP) {
 		err = startup_gfar(dev);
-		netif_wake_queue(dev);
+		netif_tx_wake_all_queues(dev);
 	}
 	return err;
 }
@@ -513,29 +517,29 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_rx_q *rx_queue = NULL;
-	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned long flags;
-	int err = 0;
+	int err = 0, i = 0;
 
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return -EOPNOTSUPP;
 
-	tx_queue = priv->tx_queue;
-	rx_queue = priv->rx_queue;
 
 	if (dev->flags & IFF_UP) {
 		/* Halt TX and RX, and process the frames which
 		 * have already been received */
-		spin_lock_irqsave(&tx_queue->txlock, flags);
-		spin_lock(&rx_queue->rxlock);
+		local_irq_save(flags);
+		lock_tx_qs(priv);
+		lock_rx_qs(priv);
 
 		gfar_halt(dev);
 
-		spin_unlock(&rx_queue->rxlock);
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
+		unlock_tx_qs(priv);
+		unlock_rx_qs(priv);
+		local_irq_save(flags);
 
-		gfar_clean_rx_ring(rx_queue, rx_queue->rx_ring_size);
+		for (i = 0; i < priv->num_rx_queues; i++)
+			gfar_clean_rx_ring(priv->rx_queue[i],
+					priv->rx_queue[i]->rx_ring_size);
 
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
@@ -547,7 +551,7 @@ static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 
 	if (dev->flags & IFF_UP) {
 		err = startup_gfar(dev);
-		netif_wake_queue(dev);
+		netif_tx_wake_all_queues(dev);
 	}
 	return err;
 }
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index adea11e..4b726f6 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -51,7 +51,6 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	struct gfar __iomem *regs = priv->gfargrp.regs;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	int new_setting = 0;
 	u32 temp;
 	unsigned long flags;
@@ -59,7 +58,6 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_BD_STASHING))
 		return count;
 
-	rx_queue = priv->rx_queue;
 
 	/* Find out the new setting */
 	if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
@@ -70,7 +68,9 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	else
 		return count;
 
-	spin_lock_irqsave(&rx_queue->rxlock, flags);
+
+	local_irq_save(flags);
+	lock_rx_qs(priv);
 
 	/* Set the new stashing value */
 	priv->bd_stash_en = new_setting;
@@ -84,7 +84,8 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 
 	gfar_write(&regs->attr, temp);
 
-	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
+	unlock_rx_qs(priv);
+	local_irq_restore(flags);
 
 	return count;
 }
@@ -105,7 +106,6 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	struct gfar __iomem *regs = priv->gfargrp.regs;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned int length = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -113,9 +113,9 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_BUF_STASHING))
 		return count;
 
-	rx_queue = priv->rx_queue;
+	local_irq_save(flags);
+	lock_rx_qs(priv);
 
-	spin_lock_irqsave(&rx_queue->rxlock, flags);
 	if (length > priv->rx_buffer_size)
 		goto out;
 
@@ -140,7 +140,8 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 	gfar_write(&regs->attr, temp);
 
 out:
-	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
+	unlock_rx_qs(priv);
+	local_irq_restore(flags);
 
 	return count;
 }
@@ -164,7 +165,6 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	struct gfar __iomem *regs = priv->gfargrp.regs;
-	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned short index = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -172,9 +172,9 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_BUF_STASHING))
 		return count;
 
-	rx_queue = priv->rx_queue;
+	local_irq_save(flags);
+	lock_rx_qs(priv);
 
-	spin_lock_irqsave(&rx_queue->rxlock, flags);
 	if (index > priv->rx_stash_size)
 		goto out;
 
@@ -189,7 +189,8 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	gfar_write(&regs->attreli, flags);
 
 out:
-	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
+	unlock_rx_qs(priv);
+	local_irq_restore(flags);
 
 	return count;
 }
@@ -212,7 +213,6 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	struct gfar __iomem *regs = priv->gfargrp.regs;
-	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned int length = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -220,9 +220,8 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 	if (length > GFAR_MAX_FIFO_THRESHOLD)
 		return count;
 
-	tx_queue = priv->tx_queue;
-
-	spin_lock_irqsave(&tx_queue->txlock, flags);
+	local_irq_save(flags);
+	lock_tx_qs(priv);
 
 	priv->fifo_threshold = length;
 
@@ -231,7 +230,8 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 	temp |= length;
 	gfar_write(&regs->fifo_tx_thr, temp);
 
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 
 	return count;
 }
@@ -253,7 +253,6 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	struct gfar __iomem *regs = priv->gfargrp.regs;
-	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned int num = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -261,8 +260,8 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 	if (num > GFAR_MAX_FIFO_STARVE)
 		return count;
 
-	tx_queue = priv->tx_queue;
-	spin_lock_irqsave(&tx_queue->txlock, flags);
+	local_irq_save(flags);
+	lock_tx_qs(priv);
 
 	priv->fifo_starve = num;
 
@@ -271,7 +270,8 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 	temp |= num;
 	gfar_write(&regs->fifo_tx_starve, temp);
 
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 
 	return count;
 }
@@ -294,7 +294,6 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
 	struct gfar __iomem *regs = priv->gfargrp.regs;
-	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned int num = simple_strtoul(buf, NULL, 0);
 	u32 temp;
 	unsigned long flags;
@@ -302,8 +301,8 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 	if (num > GFAR_MAX_FIFO_STARVE_OFF)
 		return count;
 
-	tx_queue = priv->tx_queue;
-	spin_lock_irqsave(&tx_queue->txlock, flags);
+	local_irq_save(flags);
+	lock_tx_qs(priv);
 
 	priv->fifo_starve_off = num;
 
@@ -312,7 +311,8 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 	temp |= num;
 	gfar_write(&regs->fifo_tx_starve_shutoff, temp);
 
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 
 	return count;
 }
-- 
1.5.4.6

