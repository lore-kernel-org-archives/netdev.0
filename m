From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
Subject: [PATCH v4 2/7] gianfar: Introduce logical group support.
Date: Mon,  2 Nov 2009 22:33:09 +0530
Message-ID: <12571813893353-git-send-email-sandeep.kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35822 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447AbZKBPb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 10:31:59 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nA2FW2up029410
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 08:32:03 -0700 (MST)
Received: from udp153986uds.ap.freescale.net (udp153986uds.ap.freescale.net [10.232.134.194])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nA2FZWtR000549
	for <netdev@vger.kernel.org>; Mon, 2 Nov 2009 09:35:42 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

This patch introduces the group structure. The elements of this
structure are the interrupt lines, their corresponding names,
the register memory map.
The elements for this group are factored out from the gfar_private
structure. The introduction of group structure will help in
providing support for newer versions of etsec.

Currently, the support is present only for single group and
single tx/rx queues.

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---
 drivers/net/gianfar.c         |  364 ++++++++++++++++++++++-------------------
 drivers/net/gianfar.h         |   38 +++--
 drivers/net/gianfar_ethtool.c |   14 +-
 drivers/net/gianfar_sysfs.c   |   34 +++--
 4 files changed, 250 insertions(+), 200 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 354b2b5..fa0188e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -151,7 +151,6 @@ MODULE_LICENSE("GPL");
 static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 			    dma_addr_t buf)
 {
-	struct net_device *dev = rx_queue->dev;
 	u32 lstatus;
 
 	bdp->bufPtr = buf;
@@ -290,9 +289,9 @@ cleanup:
 static void gfar_init_mac(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
-	struct gfar __iomem *regs = priv->regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u32 rctrl = 0;
 	u32 tctrl = 0;
 	u32 attrs = 0;
@@ -407,24 +406,25 @@ static int gfar_of_init(struct net_device *dev)
 
 	/* get a pointer to the register memory */
 	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
-	priv->regs = ioremap(addr, size);
+	priv->gfargrp.regs = ioremap(addr, size);
 
-	if (priv->regs == NULL)
+	if (priv->gfargrp.regs == NULL)
 		return -ENOMEM;
 
-	priv->interruptTransmit = irq_of_parse_and_map(np, 0);
+	priv->gfargrp.priv = priv; /* back pointer from group to priv */
+	priv->gfargrp.interruptTransmit = irq_of_parse_and_map(np, 0);
 
 	model = of_get_property(np, "model", NULL);
 
 	/* If we aren't the FEC we have multiple interrupts */
 	if (model && strcasecmp(model, "FEC")) {
-		priv->interruptReceive = irq_of_parse_and_map(np, 1);
+		priv->gfargrp.interruptReceive = irq_of_parse_and_map(np, 1);
 
-		priv->interruptError = irq_of_parse_and_map(np, 2);
+		priv->gfargrp.interruptError = irq_of_parse_and_map(np, 2);
 
-		if (priv->interruptTransmit < 0 ||
-				priv->interruptReceive < 0 ||
-				priv->interruptError < 0) {
+		if (priv->gfargrp.interruptTransmit < 0 ||
+				priv->gfargrp.interruptReceive < 0 ||
+				priv->gfargrp.interruptError < 0) {
 			err = -EINVAL;
 			goto err_out;
 		}
@@ -491,7 +491,7 @@ static int gfar_of_init(struct net_device *dev)
 	return 0;
 
 err_out:
-	iounmap(priv->regs);
+	iounmap(priv->gfargrp.regs);
 	return err;
 }
 
@@ -517,6 +517,7 @@ static int gfar_probe(struct of_device *ofdev,
 	u32 tempval;
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
+	struct gfar __iomem *regs = NULL;
 	int err = 0;
 	int len_devname;
 
@@ -549,32 +550,34 @@ static int gfar_probe(struct of_device *ofdev,
 
 	spin_lock_init(&priv->tx_queue->txlock);
 	spin_lock_init(&priv->rx_queue->rxlock);
+	spin_lock_init(&priv->gfargrp.grplock);
 	spin_lock_init(&priv->bflock);
 	INIT_WORK(&priv->reset_task, gfar_reset_task);
 
 	dev_set_drvdata(&ofdev->dev, priv);
+	regs = priv->gfargrp.regs;
 
 	/* Stop the DMA engine now, in case it was running before */
 	/* (The firmware could have used it, and left it running). */
 	gfar_halt(dev);
 
 	/* Reset MAC layer */
-	gfar_write(&priv->regs->maccfg1, MACCFG1_SOFT_RESET);
+	gfar_write(&regs->maccfg1, MACCFG1_SOFT_RESET);
 
 	/* We need to delay at least 3 TX clocks */
 	udelay(2);
 
 	tempval = (MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
-	gfar_write(&priv->regs->maccfg1, tempval);
+	gfar_write(&regs->maccfg1, tempval);
 
 	/* Initialize MACCFG2. */
-	gfar_write(&priv->regs->maccfg2, MACCFG2_INIT_SETTINGS);
+	gfar_write(&regs->maccfg2, MACCFG2_INIT_SETTINGS);
 
 	/* Initialize ECNTRL */
-	gfar_write(&priv->regs->ecntrl, ECNTRL_INIT_SETTINGS);
+	gfar_write(&regs->ecntrl, ECNTRL_INIT_SETTINGS);
 
 	/* Set the dev->base_addr to the gfar reg region */
-	dev->base_addr = (unsigned long) (priv->regs);
+	dev->base_addr = (unsigned long) regs;
 
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
@@ -602,35 +605,35 @@ static int gfar_probe(struct of_device *ofdev,
 		priv->extended_hash = 1;
 		priv->hash_width = 9;
 
-		priv->hash_regs[0] = &priv->regs->igaddr0;
-		priv->hash_regs[1] = &priv->regs->igaddr1;
-		priv->hash_regs[2] = &priv->regs->igaddr2;
-		priv->hash_regs[3] = &priv->regs->igaddr3;
-		priv->hash_regs[4] = &priv->regs->igaddr4;
-		priv->hash_regs[5] = &priv->regs->igaddr5;
-		priv->hash_regs[6] = &priv->regs->igaddr6;
-		priv->hash_regs[7] = &priv->regs->igaddr7;
-		priv->hash_regs[8] = &priv->regs->gaddr0;
-		priv->hash_regs[9] = &priv->regs->gaddr1;
-		priv->hash_regs[10] = &priv->regs->gaddr2;
-		priv->hash_regs[11] = &priv->regs->gaddr3;
-		priv->hash_regs[12] = &priv->regs->gaddr4;
-		priv->hash_regs[13] = &priv->regs->gaddr5;
-		priv->hash_regs[14] = &priv->regs->gaddr6;
-		priv->hash_regs[15] = &priv->regs->gaddr7;
+		priv->hash_regs[0] = &regs->igaddr0;
+		priv->hash_regs[1] = &regs->igaddr1;
+		priv->hash_regs[2] = &regs->igaddr2;
+		priv->hash_regs[3] = &regs->igaddr3;
+		priv->hash_regs[4] = &regs->igaddr4;
+		priv->hash_regs[5] = &regs->igaddr5;
+		priv->hash_regs[6] = &regs->igaddr6;
+		priv->hash_regs[7] = &regs->igaddr7;
+		priv->hash_regs[8] = &regs->gaddr0;
+		priv->hash_regs[9] = &regs->gaddr1;
+		priv->hash_regs[10] = &regs->gaddr2;
+		priv->hash_regs[11] = &regs->gaddr3;
+		priv->hash_regs[12] = &regs->gaddr4;
+		priv->hash_regs[13] = &regs->gaddr5;
+		priv->hash_regs[14] = &regs->gaddr6;
+		priv->hash_regs[15] = &regs->gaddr7;
 
 	} else {
 		priv->extended_hash = 0;
 		priv->hash_width = 8;
 
-		priv->hash_regs[0] = &priv->regs->gaddr0;
-		priv->hash_regs[1] = &priv->regs->gaddr1;
-		priv->hash_regs[2] = &priv->regs->gaddr2;
-		priv->hash_regs[3] = &priv->regs->gaddr3;
-		priv->hash_regs[4] = &priv->regs->gaddr4;
-		priv->hash_regs[5] = &priv->regs->gaddr5;
-		priv->hash_regs[6] = &priv->regs->gaddr6;
-		priv->hash_regs[7] = &priv->regs->gaddr7;
+		priv->hash_regs[0] = &regs->gaddr0;
+		priv->hash_regs[1] = &regs->gaddr1;
+		priv->hash_regs[2] = &regs->gaddr2;
+		priv->hash_regs[3] = &regs->gaddr3;
+		priv->hash_regs[4] = &regs->gaddr4;
+		priv->hash_regs[5] = &regs->gaddr5;
+		priv->hash_regs[6] = &regs->gaddr6;
+		priv->hash_regs[7] = &regs->gaddr7;
 	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_PADDING)
@@ -672,20 +675,20 @@ static int gfar_probe(struct of_device *ofdev,
 
 	/* fill out IRQ number and name fields */
 	len_devname = strlen(dev->name);
-	strncpy(&priv->int_name_tx[0], dev->name, len_devname);
+	strncpy(&priv->gfargrp.int_name_tx[0], dev->name, len_devname);
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		strncpy(&priv->int_name_tx[len_devname],
+		strncpy(&priv->gfargrp.int_name_tx[len_devname],
 			"_tx", sizeof("_tx") + 1);
 
-		strncpy(&priv->int_name_rx[0], dev->name, len_devname);
-		strncpy(&priv->int_name_rx[len_devname],
+		strncpy(&priv->gfargrp.int_name_rx[0], dev->name, len_devname);
+		strncpy(&priv->gfargrp.int_name_rx[len_devname],
 			"_rx", sizeof("_rx") + 1);
 
-		strncpy(&priv->int_name_er[0], dev->name, len_devname);
-		strncpy(&priv->int_name_er[len_devname],
+		strncpy(&priv->gfargrp.int_name_er[0], dev->name, len_devname);
+		strncpy(&priv->gfargrp.int_name_er[len_devname],
 			"_er", sizeof("_er") + 1);
 	} else
-		priv->int_name_tx[len_devname] = '\0';
+		priv->gfargrp.int_name_tx[len_devname] = '\0';
 
 	/* Create all the sysfs files */
 	gfar_init_sysfs(dev);
@@ -702,7 +705,7 @@ static int gfar_probe(struct of_device *ofdev,
 	return 0;
 
 register_fail:
-	iounmap(priv->regs);
+	iounmap(priv->gfargrp.regs);
 	kfree(priv->rx_queue);
 rx_queue_fail:
 	kfree(priv->tx_queue);
@@ -727,7 +730,7 @@ static int gfar_remove(struct of_device *ofdev)
 	dev_set_drvdata(&ofdev->dev, NULL);
 
 	unregister_netdev(priv->ndev);
-	iounmap(priv->regs);
+	iounmap(priv->gfargrp.regs);
 	free_netdev(priv->ndev);
 
 	return 0;
@@ -741,6 +744,7 @@ static int gfar_suspend(struct device *dev)
 	struct net_device *ndev = priv->ndev;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
+	struct gfar __iomem *regs = NULL;
 	unsigned long flags;
 	u32 tempval;
 
@@ -750,6 +754,7 @@ static int gfar_suspend(struct device *dev)
 	netif_device_detach(ndev);
 	tx_queue = priv->tx_queue;
 	rx_queue = priv->rx_queue;
+	regs = priv->gfargrp.regs;
 
 	if (netif_running(ndev)) {
 		spin_lock_irqsave(&tx_queue->txlock, flags);
@@ -758,14 +763,14 @@ static int gfar_suspend(struct device *dev)
 		gfar_halt_nodisable(ndev);
 
 		/* Disable Tx, and Rx if wake-on-LAN is disabled. */
-		tempval = gfar_read(&priv->regs->maccfg1);
+		tempval = gfar_read(&regs->maccfg1);
 
 		tempval &= ~MACCFG1_TX_EN;
 
 		if (!magic_packet)
 			tempval &= ~MACCFG1_RX_EN;
 
-		gfar_write(&priv->regs->maccfg1, tempval);
+		gfar_write(&regs->maccfg1, tempval);
 
 		spin_unlock(&rx_queue->rxlock);
 		spin_unlock_irqrestore(&tx_queue->txlock, flags);
@@ -774,12 +779,12 @@ static int gfar_suspend(struct device *dev)
 
 		if (magic_packet) {
 			/* Enable interrupt on Magic Packet */
-			gfar_write(&priv->regs->imask, IMASK_MAG);
+			gfar_write(&regs->imask, IMASK_MAG);
 
 			/* Enable Magic Packet mode */
-			tempval = gfar_read(&priv->regs->maccfg2);
+			tempval = gfar_read(&regs->maccfg2);
 			tempval |= MACCFG2_MPEN;
-			gfar_write(&priv->regs->maccfg2, tempval);
+			gfar_write(&regs->maccfg2, tempval);
 		} else {
 			phy_stop(priv->phydev);
 		}
@@ -794,6 +799,7 @@ static int gfar_resume(struct device *dev)
 	struct net_device *ndev = priv->ndev;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
+	struct gfar __iomem *regs = NULL;
 	unsigned long flags;
 	u32 tempval;
 	int magic_packet = priv->wol_en &&
@@ -812,13 +818,14 @@ static int gfar_resume(struct device *dev)
 	 */
 	rx_queue = priv->rx_queue;
 	tx_queue = priv->tx_queue;
+	regs = priv->gfargrp.regs;
 
 	spin_lock_irqsave(&tx_queue->txlock, flags);
 	spin_lock(&rx_queue->rxlock);
 
-	tempval = gfar_read(&priv->regs->maccfg2);
+	tempval = gfar_read(&regs->maccfg2);
 	tempval &= ~MACCFG2_MPEN;
-	gfar_write(&priv->regs->maccfg2, tempval);
+	gfar_write(&regs->maccfg2, tempval);
 
 	gfar_start(ndev);
 
@@ -893,7 +900,11 @@ static int gfar_legacy_resume(struct of_device *ofdev)
 static phy_interface_t gfar_get_interface(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	u32 ecntrl = gfar_read(&priv->regs->ecntrl);
+	struct gfar __iomem *regs = NULL;
+	u32 ecntrl;
+
+	regs = priv->gfargrp.regs;
+	ecntrl = gfar_read(&regs->ecntrl);
 
 	if (ecntrl & ECNTRL_SGMII_MODE)
 		return PHY_INTERFACE_MODE_SGMII;
@@ -1015,46 +1026,48 @@ static void gfar_configure_serdes(struct net_device *dev)
 static void init_registers(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = NULL;
 
+	regs = priv->gfargrp.regs;
 	/* Clear IEVENT */
-	gfar_write(&priv->regs->ievent, IEVENT_INIT_CLEAR);
+	gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
 
 	/* Initialize IMASK */
-	gfar_write(&priv->regs->imask, IMASK_INIT_CLEAR);
+	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Init hash registers to zero */
-	gfar_write(&priv->regs->igaddr0, 0);
-	gfar_write(&priv->regs->igaddr1, 0);
-	gfar_write(&priv->regs->igaddr2, 0);
-	gfar_write(&priv->regs->igaddr3, 0);
-	gfar_write(&priv->regs->igaddr4, 0);
-	gfar_write(&priv->regs->igaddr5, 0);
-	gfar_write(&priv->regs->igaddr6, 0);
-	gfar_write(&priv->regs->igaddr7, 0);
-
-	gfar_write(&priv->regs->gaddr0, 0);
-	gfar_write(&priv->regs->gaddr1, 0);
-	gfar_write(&priv->regs->gaddr2, 0);
-	gfar_write(&priv->regs->gaddr3, 0);
-	gfar_write(&priv->regs->gaddr4, 0);
-	gfar_write(&priv->regs->gaddr5, 0);
-	gfar_write(&priv->regs->gaddr6, 0);
-	gfar_write(&priv->regs->gaddr7, 0);
+	gfar_write(&regs->igaddr0, 0);
+	gfar_write(&regs->igaddr1, 0);
+	gfar_write(&regs->igaddr2, 0);
+	gfar_write(&regs->igaddr3, 0);
+	gfar_write(&regs->igaddr4, 0);
+	gfar_write(&regs->igaddr5, 0);
+	gfar_write(&regs->igaddr6, 0);
+	gfar_write(&regs->igaddr7, 0);
+
+	gfar_write(&regs->gaddr0, 0);
+	gfar_write(&regs->gaddr1, 0);
+	gfar_write(&regs->gaddr2, 0);
+	gfar_write(&regs->gaddr3, 0);
+	gfar_write(&regs->gaddr4, 0);
+	gfar_write(&regs->gaddr5, 0);
+	gfar_write(&regs->gaddr6, 0);
+	gfar_write(&regs->gaddr7, 0);
 
 	/* Zero out the rmon mib registers if it has them */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
-		memset_io(&(priv->regs->rmon), 0, sizeof (struct rmon_mib));
+		memset_io(&(regs->rmon), 0, sizeof (struct rmon_mib));
 
 		/* Mask off the CAM interrupts */
-		gfar_write(&priv->regs->rmon.cam1, 0xffffffff);
-		gfar_write(&priv->regs->rmon.cam2, 0xffffffff);
+		gfar_write(&regs->rmon.cam1, 0xffffffff);
+		gfar_write(&regs->rmon.cam2, 0xffffffff);
 	}
 
 	/* Initialize the max receive buffer length */
-	gfar_write(&priv->regs->mrblr, priv->rx_buffer_size);
+	gfar_write(&regs->mrblr, priv->rx_buffer_size);
 
 	/* Initialize the Minimum Frame Length Register */
-	gfar_write(&priv->regs->minflr, MINFLR_INIT_SETTINGS);
+	gfar_write(&regs->minflr, MINFLR_INIT_SETTINGS);
 }
 
 
@@ -1062,7 +1075,7 @@ static void init_registers(struct net_device *dev)
 static void gfar_halt_nodisable(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = priv->regs;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u32 tempval;
 
 	/* Mask all interrupts */
@@ -1072,13 +1085,13 @@ static void gfar_halt_nodisable(struct net_device *dev)
 	gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
 
 	/* Stop the DMA, and wait for it to stop */
-	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval = gfar_read(&regs->dmactrl);
 	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS))
 	    != (DMACTRL_GRS | DMACTRL_GTS)) {
 		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
-		gfar_write(&priv->regs->dmactrl, tempval);
+		gfar_write(&regs->dmactrl, tempval);
 
-		while (!(gfar_read(&priv->regs->ievent) &
+		while (!(gfar_read(&regs->ievent) &
 			 (IEVENT_GRSC | IEVENT_GTSC)))
 			cpu_relax();
 	}
@@ -1088,7 +1101,7 @@ static void gfar_halt_nodisable(struct net_device *dev)
 void gfar_halt(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = priv->regs;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u32 tempval;
 
 	gfar_halt_nodisable(dev);
@@ -1122,11 +1135,11 @@ void stop_gfar(struct net_device *dev)
 
 	/* Free the IRQs */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		free_irq(priv->interruptError, dev);
-		free_irq(priv->interruptTransmit, dev);
-		free_irq(priv->interruptReceive, dev);
+		free_irq(priv->gfargrp.interruptError, &priv->gfargrp);
+		free_irq(priv->gfargrp.interruptTransmit, &priv->gfargrp);
+		free_irq(priv->gfargrp.interruptReceive, &priv->gfargrp);
 	} else {
-		free_irq(priv->interruptTransmit, dev);
+		free_irq(priv->gfargrp.interruptTransmit, &priv->gfargrp);
 	}
 
 	free_skb_resources(priv);
@@ -1201,9 +1214,7 @@ skip_rx_skbuff:
 void gfar_start(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar_priv_tx_q *tx_queue;
-	struct gfar_priv_rx_q *rx_queue;
-	struct gfar __iomem *regs = priv->regs;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u32 tempval;
 
 	/* Enable Rx and Tx in MACCFG1 */
@@ -1212,14 +1223,14 @@ void gfar_start(struct net_device *dev)
 	gfar_write(&regs->maccfg1, tempval);
 
 	/* Initialize DMACTRL to have WWR and WOP */
-	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval = gfar_read(&regs->dmactrl);
 	tempval |= DMACTRL_INIT_SETTINGS;
-	gfar_write(&priv->regs->dmactrl, tempval);
+	gfar_write(&regs->dmactrl, tempval);
 
 	/* Make sure we aren't stopped */
-	tempval = gfar_read(&priv->regs->dmactrl);
+	tempval = gfar_read(&regs->dmactrl);
 	tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
-	gfar_write(&priv->regs->dmactrl, tempval);
+	gfar_write(&regs->dmactrl, tempval);
 
 	/* Clear THLT/RHLT, so that the DMA starts polling now */
 	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
@@ -1235,7 +1246,7 @@ void gfar_start(struct net_device *dev)
 int startup_gfar(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
-	struct gfar __iomem *regs = priv->regs;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	int err;
 
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
@@ -1251,39 +1262,46 @@ int startup_gfar(struct net_device *ndev)
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
-		err = request_irq(priv->interruptError, gfar_error, 0,
-				  priv->int_name_er, ndev);
+		err = request_irq(priv->gfargrp.interruptError, gfar_error, 0,
+				  priv->gfargrp.int_name_er, &priv->gfargrp);
 		if (err) {
 			if (netif_msg_intr(priv))
 				pr_err("%s: Can't get IRQ %d\n", ndev->name,
-				       priv->interruptError);
+				       priv->gfargrp.interruptError);
 			goto err_irq_fail;
 		}
 
-		err = request_irq(priv->interruptTransmit, gfar_transmit, 0,
-				  priv->int_name_tx, ndev);
+		err = request_irq(priv->gfargrp.interruptTransmit,
+					gfar_transmit, 0,
+					priv->gfargrp.int_name_tx,
+					&priv->gfargrp);
 		if (err) {
 			if (netif_msg_intr(priv))
 				pr_err("%s: Can't get IRQ %d\n", ndev->name,
-				       priv->interruptTransmit);
+				       priv->gfargrp.interruptTransmit);
 			goto tx_irq_fail;
 		}
 
-		err = request_irq(priv->interruptReceive, gfar_receive, 0,
-				  priv->int_name_rx, ndev);
+		err = request_irq(priv->gfargrp.interruptReceive,
+					gfar_receive, 0,
+					priv->gfargrp.int_name_rx,
+					&priv->gfargrp);
 		if (err) {
 			if (netif_msg_intr(priv))
 				pr_err("%s: Can't get IRQ %d (receive0)\n",
-				       ndev->name, priv->interruptReceive);
+					ndev->name,
+					priv->gfargrp.interruptReceive);
 			goto rx_irq_fail;
 		}
 	} else {
-		err = request_irq(priv->interruptTransmit, gfar_interrupt,
-				0, priv->int_name_tx, ndev);
+		err = request_irq(priv->gfargrp.interruptTransmit,
+					gfar_interrupt, 0,
+					priv->gfargrp.int_name_tx,
+					&priv->gfargrp);
 		if (err) {
 			if (netif_msg_intr(priv))
 				pr_err("%s: Can't get IRQ %d\n", ndev->name,
-				       priv->interruptTransmit);
+				       priv->gfargrp.interruptTransmit);
 			goto err_irq_fail;
 		}
 	}
@@ -1296,9 +1314,9 @@ int startup_gfar(struct net_device *ndev)
 	return 0;
 
 rx_irq_fail:
-	free_irq(priv->interruptTransmit, ndev);
+	free_irq(priv->gfargrp.interruptTransmit, &priv->gfargrp);
 tx_irq_fail:
-	free_irq(priv->interruptError, ndev);
+	free_irq(priv->gfargrp.interruptError, &priv->gfargrp);
 err_irq_fail:
 	free_skb_resources(priv);
 	return err;
@@ -1403,6 +1421,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_tx_q *tx_queue = NULL;
+	struct gfar __iomem *regs = NULL;
 	struct txfcb *fcb = NULL;
 	struct txbd8 *txbdp, *txbdp_start, *base;
 	u32 lstatus;
@@ -1413,6 +1432,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_queue = priv->tx_queue;
 	base = tx_queue->tx_bd_base;
+	regs = priv->gfargrp.regs;
 
 	/* make space for additional header when fcb is needed */
 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
@@ -1536,7 +1556,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Tell the DMA to go go go */
-	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
+	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
 
 	/* Unlock priv */
 	spin_unlock_irqrestore(&tx_queue->txlock, flags);
@@ -1579,40 +1599,42 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_rx_q *rx_queue = NULL;
+	struct gfar __iomem *regs = NULL;
 	unsigned long flags;
 	u32 tempval;
 
 	rx_queue = priv->rx_queue;
+	regs = priv->gfargrp.regs;
 	spin_lock_irqsave(&rx_queue->rxlock, flags);
 
 	priv->vlgrp = grp;
 
 	if (grp) {
 		/* Enable VLAN tag insertion */
-		tempval = gfar_read(&priv->regs->tctrl);
+		tempval = gfar_read(&regs->tctrl);
 		tempval |= TCTRL_VLINS;
 
-		gfar_write(&priv->regs->tctrl, tempval);
+		gfar_write(&regs->tctrl, tempval);
 
 		/* Enable VLAN tag extraction */
-		tempval = gfar_read(&priv->regs->rctrl);
+		tempval = gfar_read(&regs->rctrl);
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
-		gfar_write(&priv->regs->rctrl, tempval);
+		gfar_write(&regs->rctrl, tempval);
 	} else {
 		/* Disable VLAN tag insertion */
-		tempval = gfar_read(&priv->regs->tctrl);
+		tempval = gfar_read(&regs->tctrl);
 		tempval &= ~TCTRL_VLINS;
-		gfar_write(&priv->regs->tctrl, tempval);
+		gfar_write(&regs->tctrl, tempval);
 
 		/* Disable VLAN tag extraction */
-		tempval = gfar_read(&priv->regs->rctrl);
+		tempval = gfar_read(&regs->rctrl);
 		tempval &= ~RCTRL_VLEX;
 		/* If parse is no longer required, then disable parser */
 		if (tempval & RCTRL_REQ_PARSER)
 			tempval |= RCTRL_PRSDEP_INIT;
 		else
 			tempval &= ~RCTRL_PRSDEP_INIT;
-		gfar_write(&priv->regs->rctrl, tempval);
+		gfar_write(&regs->rctrl, tempval);
 	}
 
 	gfar_change_mtu(dev, dev->mtu);
@@ -1624,6 +1646,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 {
 	int tempsize, tempval;
 	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	int oldsize = priv->rx_buffer_size;
 	int frame_size = new_mtu + ETH_HLEN;
 
@@ -1655,20 +1678,20 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 
 	dev->mtu = new_mtu;
 
-	gfar_write(&priv->regs->mrblr, priv->rx_buffer_size);
-	gfar_write(&priv->regs->maxfrm, priv->rx_buffer_size);
+	gfar_write(&regs->mrblr, priv->rx_buffer_size);
+	gfar_write(&regs->maxfrm, priv->rx_buffer_size);
 
 	/* If the mtu is larger than the max size for standard
 	 * ethernet frames (ie, a jumbo frame), then set maccfg2
 	 * to allow huge frames, and to check the length */
-	tempval = gfar_read(&priv->regs->maccfg2);
+	tempval = gfar_read(&regs->maccfg2);
 
 	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE)
 		tempval |= (MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
 	else
 		tempval &= ~(MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
 
-	gfar_write(&priv->regs->maccfg2, tempval);
+	gfar_write(&regs->maccfg2, tempval);
 
 	if ((oldsize != tempsize) && (dev->flags & IFF_UP))
 		startup_gfar(dev);
@@ -1787,9 +1810,9 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	return howmany;
 }
 
-static void gfar_schedule_cleanup(struct net_device *dev)
+static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
 {
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = gfargrp->priv;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned long flags;
@@ -1800,14 +1823,14 @@ static void gfar_schedule_cleanup(struct net_device *dev)
 	spin_lock(&rx_queue->rxlock);
 
 	if (napi_schedule_prep(&rx_queue->napi)) {
-		gfar_write(&priv->regs->imask, IMASK_RTX_DISABLED);
+		gfar_write(&gfargrp->regs->imask, IMASK_RTX_DISABLED);
 		__napi_schedule(&rx_queue->napi);
 	} else {
 		/*
 		 * Clear IEVENT, so interrupts aren't called again
 		 * because of the packets that have already arrived.
 		 */
-		gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
+		gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
 	}
 
 	spin_unlock(&rx_queue->rxlock);
@@ -1815,9 +1838,9 @@ static void gfar_schedule_cleanup(struct net_device *dev)
 }
 
 /* Interrupt Handler for Transmit complete */
-static irqreturn_t gfar_transmit(int irq, void *dev_id)
+static irqreturn_t gfar_transmit(int irq, void *grp_id)
 {
-	gfar_schedule_cleanup((struct net_device *)dev_id);
+	gfar_schedule_cleanup((struct gfar_priv_grp *)grp_id);
 	return IRQ_HANDLED;
 }
 
@@ -1897,9 +1920,9 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 	}
 }
 
-irqreturn_t gfar_receive(int irq, void *dev_id)
+irqreturn_t gfar_receive(int irq, void *grp_id)
 {
-	gfar_schedule_cleanup((struct net_device *)dev_id);
+	gfar_schedule_cleanup((struct gfar_priv_grp *)grp_id);
 	return IRQ_HANDLED;
 }
 
@@ -2053,6 +2076,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 			struct gfar_priv_rx_q, napi);
 	struct net_device *dev = rx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	int tx_cleaned = 0;
 	int rx_cleaned = 0;
@@ -2060,7 +2084,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived */
-	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
+	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
 	tx_queue = priv->tx_queue;
 
 	/* If we fail to get the lock, don't bother with the TX BDs */
@@ -2078,19 +2102,19 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 
 		/* Clear the halt bit in RSTAT */
-		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
+		gfar_write(&regs->rstat, RSTAT_CLEAR_RHALT);
 
-		gfar_write(&priv->regs->imask, IMASK_DEFAULT);
+		gfar_write(&regs->imask, IMASK_DEFAULT);
 
 		/* If we are coalescing interrupts, update the timer */
 		/* Otherwise, clear it */
 		if (likely(rx_queue->rxcoalescing)) {
-			gfar_write(&priv->regs->rxic, 0);
-			gfar_write(&priv->regs->rxic, rx_queue->rxic);
+			gfar_write(&regs->rxic, 0);
+			gfar_write(&regs->rxic, rx_queue->rxic);
 		}
 		if (likely(tx_queue->txcoalescing)) {
-			gfar_write(&priv->regs->txic, 0);
-			gfar_write(&priv->regs->txic, tx_queue->txic);
+			gfar_write(&regs->txic, 0);
+			gfar_write(&regs->txic, tx_queue->txic);
 		}
 	}
 
@@ -2109,41 +2133,40 @@ static void gfar_netpoll(struct net_device *dev)
 
 	/* If the device has multiple interrupts, run tx/rx */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		disable_irq(priv->interruptTransmit);
-		disable_irq(priv->interruptReceive);
-		disable_irq(priv->interruptError);
-		gfar_interrupt(priv->interruptTransmit, dev);
-		enable_irq(priv->interruptError);
-		enable_irq(priv->interruptReceive);
-		enable_irq(priv->interruptTransmit);
+		disable_irq(priv->gfargrp.interruptTransmit);
+		disable_irq(priv->gfargrp.interruptReceive);
+		disable_irq(priv->gfargrp.interruptError);
+		gfar_interrupt(priv->gfargrp.interruptTransmit, &priv->gfargrp);
+		enable_irq(priv->gfargrp.interruptError);
+		enable_irq(priv->gfargrp.interruptReceive);
+		enable_irq(priv->gfargrp.interruptTransmit);
 	} else {
-		disable_irq(priv->interruptTransmit);
-		gfar_interrupt(priv->interruptTransmit, dev);
-		enable_irq(priv->interruptTransmit);
+		disable_irq(priv->gfargrp.interruptTransmit);
+		gfar_interrupt(priv->gfargrp.interruptTransmit, &priv->gfargrp);
+		enable_irq(priv->gfargrp.interruptTransmit);
 	}
 }
 #endif
 
 /* The interrupt handler for devices with one interrupt */
-static irqreturn_t gfar_interrupt(int irq, void *dev_id)
+static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 {
-	struct net_device *dev = dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_priv_grp *gfargrp = grp_id;
 
 	/* Save ievent for future reference */
-	u32 events = gfar_read(&priv->regs->ievent);
+	u32 events = gfar_read(&gfargrp->regs->ievent);
 
 	/* Check for reception */
 	if (events & IEVENT_RX_MASK)
-		gfar_receive(irq, dev_id);
+		gfar_receive(irq, grp_id);
 
 	/* Check for transmit completion */
 	if (events & IEVENT_TX_MASK)
-		gfar_transmit(irq, dev_id);
+		gfar_transmit(irq, grp_id);
 
 	/* Check for errors */
 	if (events & IEVENT_ERR_MASK)
-		gfar_error(irq, dev_id);
+		gfar_error(irq, grp_id);
 
 	return IRQ_HANDLED;
 }
@@ -2158,7 +2181,7 @@ static void adjust_link(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_tx_q *tx_queue = NULL;
-	struct gfar __iomem *regs = priv->regs;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	unsigned long flags;
 	struct phy_device *phydev = priv->phydev;
 	int new_state = 0;
@@ -2241,7 +2264,7 @@ static void gfar_set_multi(struct net_device *dev)
 {
 	struct dev_mc_list *mc_ptr;
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = priv->regs;
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u32 tempval;
 
 	if (dev->flags & IFF_PROMISC) {
@@ -2374,10 +2397,11 @@ static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr)
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	int idx;
 	char tmpbuf[MAC_ADDR_LEN];
 	u32 tempval;
-	u32 __iomem *macptr = &priv->regs->macstnaddr1;
+	u32 __iomem *macptr = &regs->macstnaddr1;
 
 	macptr += num*2;
 
@@ -2394,16 +2418,18 @@ static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr)
 }
 
 /* GFAR error interrupt handler */
-static irqreturn_t gfar_error(int irq, void *dev_id)
+static irqreturn_t gfar_error(int irq, void *grp_id)
 {
-	struct net_device *dev = dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_priv_grp *gfargrp = grp_id;
+	struct gfar __iomem *regs = gfargrp->regs;
+	struct gfar_private *priv= gfargrp->priv;
+	struct net_device *dev = priv->ndev;
 
 	/* Save ievent for future reference */
-	u32 events = gfar_read(&priv->regs->ievent);
+	u32 events = gfar_read(&regs->ievent);
 
 	/* Clear IEVENT */
-	gfar_write(&priv->regs->ievent, events & IEVENT_ERR_MASK);
+	gfar_write(&regs->ievent, events & IEVENT_ERR_MASK);
 
 	/* Magic Packet is not an error. */
 	if ((priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
@@ -2413,7 +2439,7 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 	/* Hmm... */
 	if (netif_msg_rx_err(priv) || netif_msg_tx_err(priv))
 		printk(KERN_DEBUG "%s: error interrupt (ievent=0x%08x imask=0x%08x)\n",
-		       dev->name, events, gfar_read(&priv->regs->imask));
+		       dev->name, events, gfar_read(&regs->imask));
 
 	/* Update the error counters */
 	if (events & IEVENT_TXE) {
@@ -2431,7 +2457,7 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 			priv->extra_stats.tx_underrun++;
 
 			/* Reactivate the Tx Queues */
-			gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
+			gfar_write(&regs->tstat, TSTAT_CLEAR_THALT);
 		}
 		if (netif_msg_tx_err(priv))
 			printk(KERN_DEBUG "%s: Transmit Error\n", dev->name);
@@ -2440,11 +2466,11 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 		dev->stats.rx_errors++;
 		priv->extra_stats.rx_bsy++;
 
-		gfar_receive(irq, dev_id);
+		gfar_receive(irq, grp_id);
 
 		if (netif_msg_rx_err(priv))
 			printk(KERN_DEBUG "%s: busy error (rstat: %x)\n",
-			       dev->name, gfar_read(&priv->regs->rstat));
+			       dev->name, gfar_read(&regs->rstat));
 	}
 	if (events & IEVENT_BABR) {
 		dev->stats.rx_errors++;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index a60f93f..79e8471 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -770,6 +770,32 @@ struct gfar_priv_rx_q {
 	unsigned long rxic;
 };
 
+/**
+ *	struct gfar_priv_grp - per group structure
+ *	@priv: back pointer to the priv structure
+ *	@regs: the ioremapped register space for this group
+ *	@grp_id: group id for this group
+ *	@interruptTransmit: The TX interrupt number for this group
+ *	@interruptReceive: The RX interrupt number for this group
+ *	@interruptError: The ERROR interrupt number for this group
+ *	@int_name_tx: tx interrupt name for this group
+ *	@int_name_rx: rx interrupt name for this group
+ *	@int_name_er: er interrupt name for this group
+ */
+
+struct gfar_priv_grp {
+	spinlock_t grplock __attribute__ ((aligned (SMP_CACHE_BYTES)));
+	struct gfar_private *priv;
+	struct gfar __iomem *regs;
+	unsigned int interruptTransmit;
+	unsigned int interruptReceive;
+	unsigned int interruptError;
+
+	char int_name_tx[GFAR_INT_NAME_MAX];
+	char int_name_rx[GFAR_INT_NAME_MAX];
+	char int_name_er[GFAR_INT_NAME_MAX];
+};
+
 /* Struct stolen almost completely (and shamelessly) from the FCC enet source
  * (Ok, that's not so true anymore, but there is a family resemblence)
  * The GFAR buffer descriptors track the ring buffers.  The rx_bd_base
@@ -785,6 +811,7 @@ struct gfar_private {
 	struct net_device *ndev;
 	struct of_device *ofdev;
 
+	struct gfar_priv_grp gfargrp;
 	struct gfar_priv_tx_q *tx_queue;
 	struct gfar_priv_rx_q *rx_queue;
 
@@ -797,9 +824,6 @@ struct gfar_private {
 
 	struct vlan_group *vlgrp;
 
-	/* Unprotected fields */
-	/* Pointer to the GFAR memory mapped Registers */
-	struct gfar __iomem *regs;
 
 	/* Hash registers and their width */
 	u32 __iomem *hash_regs[16];
@@ -823,10 +847,6 @@ struct gfar_private {
 		wol_en:1; /* Wake-on-LAN enabled */
 	unsigned short padding;
 
-	unsigned int interruptTransmit;
-	unsigned int interruptReceive;
-	unsigned int interruptError;
-
 	/* PHY stuff */
 	struct phy_device *phydev;
 	struct mii_bus *mii_bus;
@@ -838,10 +858,6 @@ struct gfar_private {
 
 	struct work_struct reset_task;
 
-	char int_name_tx[GFAR_INT_NAME_MAX];
-	char int_name_rx[GFAR_INT_NAME_MAX];
-	char int_name_er[GFAR_INT_NAME_MAX];
-
 	/* Network Statistics */
 	struct gfar_extra_stats extra_stats;
 };
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 6d0d171..c681b41 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -137,10 +137,11 @@ static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 {
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	u64 *extra = (u64 *) & priv->extra_stats;
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
-		u32 __iomem *rmon = (u32 __iomem *) & priv->regs->rmon;
+		u32 __iomem *rmon = (u32 __iomem *) &regs->rmon;
 		struct gfar_stats *stats = (struct gfar_stats *) buf;
 
 		for (i = 0; i < GFAR_RMON_LEN; i++)
@@ -223,7 +224,7 @@ static void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs, voi
 {
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
-	u32 __iomem *theregs = (u32 __iomem *) priv->regs;
+	u32 __iomem *theregs = (u32 __iomem *) priv->gfargrp.regs;
 	u32 *buf = (u32 *) regbuf;
 
 	for (i = 0; i < sizeof (struct gfar) / sizeof (u32); i++)
@@ -349,6 +350,7 @@ static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 
@@ -407,13 +409,13 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	tx_queue->txic = mk_ic_value(cvals->tx_max_coalesced_frames,
 		gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs));
 
-	gfar_write(&priv->regs->rxic, 0);
+	gfar_write(&regs->rxic, 0);
 	if (rx_queue->rxcoalescing)
-		gfar_write(&priv->regs->rxic, rx_queue->rxic);
+		gfar_write(&regs->rxic, rx_queue->rxic);
 
-	gfar_write(&priv->regs->txic, 0);
+	gfar_write(&regs->txic, 0);
 	if (tx_queue->txcoalescing)
-		gfar_write(&priv->regs->txic, tx_queue->txic);
+		gfar_write(&regs->txic, tx_queue->txic);
 
 	return 0;
 }
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 9c664f8..adea11e 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -50,6 +50,7 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 				 const char *buf, size_t count)
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	int new_setting = 0;
 	u32 temp;
@@ -74,14 +75,14 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	/* Set the new stashing value */
 	priv->bd_stash_en = new_setting;
 
-	temp = gfar_read(&priv->regs->attr);
+	temp = gfar_read(&regs->attr);
 
 	if (new_setting)
 		temp |= ATTR_BDSTASH;
 	else
 		temp &= ~(ATTR_BDSTASH);
 
-	gfar_write(&priv->regs->attr, temp);
+	gfar_write(&regs->attr, temp);
 
 	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
 
@@ -103,6 +104,7 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 				      const char *buf, size_t count)
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned int length = simple_strtoul(buf, NULL, 0);
 	u32 temp;
@@ -122,20 +124,20 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 
 	priv->rx_stash_size = length;
 
-	temp = gfar_read(&priv->regs->attreli);
+	temp = gfar_read(&regs->attreli);
 	temp &= ~ATTRELI_EL_MASK;
 	temp |= ATTRELI_EL(length);
-	gfar_write(&priv->regs->attreli, temp);
+	gfar_write(&regs->attreli, temp);
 
 	/* Turn stashing on/off as appropriate */
-	temp = gfar_read(&priv->regs->attr);
+	temp = gfar_read(&regs->attr);
 
 	if (length)
 		temp |= ATTR_BUFSTASH;
 	else
 		temp &= ~(ATTR_BUFSTASH);
 
-	gfar_write(&priv->regs->attr, temp);
+	gfar_write(&regs->attr, temp);
 
 out:
 	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
@@ -161,6 +163,7 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 				       const char *buf, size_t count)
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	unsigned short index = simple_strtoul(buf, NULL, 0);
 	u32 temp;
@@ -180,10 +183,10 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 
 	priv->rx_stash_index = index;
 
-	temp = gfar_read(&priv->regs->attreli);
+	temp = gfar_read(&regs->attreli);
 	temp &= ~ATTRELI_EI_MASK;
 	temp |= ATTRELI_EI(index);
-	gfar_write(&priv->regs->attreli, flags);
+	gfar_write(&regs->attreli, flags);
 
 out:
 	spin_unlock_irqrestore(&rx_queue->rxlock, flags);
@@ -208,6 +211,7 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 				       const char *buf, size_t count)
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned int length = simple_strtoul(buf, NULL, 0);
 	u32 temp;
@@ -222,10 +226,10 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 
 	priv->fifo_threshold = length;
 
-	temp = gfar_read(&priv->regs->fifo_tx_thr);
+	temp = gfar_read(&regs->fifo_tx_thr);
 	temp &= ~FIFO_TX_THR_MASK;
 	temp |= length;
-	gfar_write(&priv->regs->fifo_tx_thr, temp);
+	gfar_write(&regs->fifo_tx_thr, temp);
 
 	spin_unlock_irqrestore(&tx_queue->txlock, flags);
 
@@ -248,6 +252,7 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 				    const char *buf, size_t count)
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned int num = simple_strtoul(buf, NULL, 0);
 	u32 temp;
@@ -261,10 +266,10 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 
 	priv->fifo_starve = num;
 
-	temp = gfar_read(&priv->regs->fifo_tx_starve);
+	temp = gfar_read(&regs->fifo_tx_starve);
 	temp &= ~FIFO_TX_STARVE_MASK;
 	temp |= num;
-	gfar_write(&priv->regs->fifo_tx_starve, temp);
+	gfar_write(&regs->fifo_tx_starve, temp);
 
 	spin_unlock_irqrestore(&tx_queue->txlock, flags);
 
@@ -288,6 +293,7 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 					const char *buf, size_t count)
 {
 	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
+	struct gfar __iomem *regs = priv->gfargrp.regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	unsigned int num = simple_strtoul(buf, NULL, 0);
 	u32 temp;
@@ -301,10 +307,10 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 
 	priv->fifo_starve_off = num;
 
-	temp = gfar_read(&priv->regs->fifo_tx_starve_shutoff);
+	temp = gfar_read(&regs->fifo_tx_starve_shutoff);
 	temp &= ~FIFO_TX_STARVE_OFF_MASK;
 	temp |= num;
-	gfar_write(&priv->regs->fifo_tx_starve_shutoff, temp);
+	gfar_write(&regs->fifo_tx_starve_shutoff, temp);
 
 	spin_unlock_irqrestore(&tx_queue->txlock, flags);
 
-- 
1.5.4.6

