From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Mon, 26 Jul 2004 17:06:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <10E7AA25-DF50-11D8-90B5-000393C30512@freescale.com>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com> <40EB89CC.2040100@pobox.com>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: multipart/mixed; boundary=Apple-Mail-1-903248500
Cc: Andy Fleming <AFLEMING@motorola.com>, <netdev@oss.sgi.com>,
        Kumar Gala <kumar.gala@motorola.com>, <hadi@cyberus.ca>,
        <dwmw2@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <40EB89CC.2040100@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-1-903248500
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

Argh.  We found a couple bugs in that last patch.  This patch fixes 
those bugs.  However, please note that the patch is done against the 
original submission from weeks ago.  This patch replaces my most recent 
patch.


--Apple-Mail-1-903248500
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="mypatch"
Content-Disposition: attachment;
	filename=mypatch

diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	Mon Jul 26 17:01:55 2004
+++ b/drivers/net/gianfar.c	Mon Jul 26 17:01:55 2004
@@ -8,7 +8,7 @@
  * Author: Andy Fleming
  * Maintainer: Kumar Gala (kumar.gala@freescale.com)
  *
- * Copyright 2004 Freescale Semiconductor, Inc
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -101,11 +101,6 @@
 #include <net/ip.h>
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,41)
-#define irqreturn_t void
-#define IRQ_HANDLED 
-#endif
-
 #define TX_TIMEOUT      (1*HZ)
 #define SKB_ALLOC_TIMEOUT 1000000
 #undef BRIEF_GFAR_ERRORS
@@ -117,9 +112,8 @@
 #define RECEIVE(x) netif_rx(x)
 #endif
 
-#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.0, "
-char gfar_driver_name[] = "Gianfar Ethernet";
-char gfar_driver_version[] = "1.0";
+const char gfar_driver_name[] = "Gianfar Ethernet";
+const char gfar_driver_version[] = "1.1";
 
 int startup_gfar(struct net_device *dev);
 static int gfar_enet_open(struct net_device *dev);
@@ -152,12 +146,9 @@
 static int gfar_accept_fastpath(struct net_device *dev, struct dst_entry *dst);
 #endif
 static inline int try_fastroute(struct sk_buff *skb, struct net_device *dev, int length);
-#ifdef CONFIG_GFAR_NAPI
 static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
-#else
-static int gfar_clean_rx_ring(struct net_device *dev);
-#endif
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
+static void gfar_phy_startup_timer(unsigned long data);
 
 extern struct ethtool_ops gfar_ethtool_ops;
 extern void gfar_gstrings_normon(struct net_device *dev, u32 stringset, 
@@ -183,7 +174,7 @@
 	struct ocp_gfar_data *einfo;
 	int idx;
 	int err = 0;
-	struct ethtool_ops *dev_ethtool_ops;
+	int dev_ethtool_ops = 0;
 
 	einfo = (struct ocp_gfar_data *) ocpdev->def->additions;
 
@@ -197,7 +188,8 @@
 	/* get a pointer to the register memory which can
 	 * configure the PHYs.  If it's different from this set,
 	 * get the device which has those regs */
-	if ((einfo->phyregidx >= 0) && (einfo->phyregidx != ocpdev->def->index)) {
+	if ((einfo->phyregidx >= 0) && 
+			(einfo->phyregidx != ocpdev->def->index)) {
 		mdiodev = ocp_find_device(OCP_ANY_ID,
 					  OCP_FUNC_GFAR, einfo->phyregidx);
 
@@ -222,7 +214,7 @@
 
 	/* get a pointer to the register memory */
 	priv->regs = (struct gfar *)
-	    ioremap(ocpdev->def->paddr, sizeof (struct gfar));
+		ioremap(ocpdev->def->paddr, sizeof (struct gfar));
 
 	if (priv->regs == NULL) {
 		err = -ENOMEM;
@@ -238,6 +230,8 @@
 		goto phy_regs_fail;
 	}
 
+	spin_lock_init(&priv->lock);
+
 	ocp_set_drvdata(ocpdev, dev);
 
 	/* Stop the DMA engine now, in case it was running before */
@@ -269,15 +263,13 @@
 	gfar_write(&priv->regs->ecntrl, ECNTRL_INIT_SETTINGS);
 
 	/* Copy the station address into the dev structure, */
-	/* and into the address registers MAC_STNADDR1,2. */
-	/* Backwards, because little endian MACs are dumb. */
-	/* Don't set the regs if the firmware already did */
 	memcpy(dev->dev_addr, einfo->mac_addr, MAC_ADDR_LEN);
 
 	/* Set the dev->base_addr to the gfar reg region */
 	dev->base_addr = (unsigned long) (priv->regs);
 
 	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &ocpdev->dev);
 
 	/* Fill in the dev structure */
 	dev->open = gfar_enet_open;
@@ -293,33 +285,16 @@
 	dev->change_mtu = gfar_change_mtu;
 	dev->mtu = 1500;
 	dev->set_multicast_list = gfar_set_multi;
-	dev->flags |= IFF_MULTICAST;
-
-	dev_ethtool_ops = 
-		(struct ethtool_ops *)kmalloc(sizeof(struct ethtool_ops), 
-					      GFP_KERNEL);
-
-	if(dev_ethtool_ops == NULL) {
-		err = -ENOMEM;
-		goto ethtool_fail;
-	}
-
-	memcpy(dev_ethtool_ops, &gfar_ethtool_ops, sizeof(gfar_ethtool_ops));
 
-	/* If there is no RMON support in this device, we don't
-	 * want to expose non-existant statistics */
-	if((priv->einfo->flags & GFAR_HAS_RMON) == 0) {
-		dev_ethtool_ops->get_strings = gfar_gstrings_normon;
-		dev_ethtool_ops->get_stats_count = gfar_stats_count_normon;
-		dev_ethtool_ops->get_ethtool_stats = gfar_fill_stats_normon;
-	}
+	/* Index into the array of possible ethtool
+	 * ops to catch all 4 possibilities */
+	if((priv->einfo->flags & GFAR_HAS_RMON) == 0)
+		dev_ethtool_ops += 1;
 
-	if((priv->einfo->flags & GFAR_HAS_COALESCE) == 0) {
-		dev_ethtool_ops->set_coalesce = NULL;
-		dev_ethtool_ops->get_coalesce = NULL;
-	}
+	if((priv->einfo->flags & GFAR_HAS_COALESCE) == 0)
+		dev_ethtool_ops += 2;
 
-	dev->ethtool_ops = dev_ethtool_ops;
+	dev->ethtool_ops = gfar_op_array[dev_ethtool_ops];
 
 #ifdef CONFIG_NET_FASTROUTE
 	dev->accept_fastpath = gfar_accept_fastpath;
@@ -332,19 +307,18 @@
 	priv->tx_ring_size = DEFAULT_TX_RING_SIZE;
 	priv->rx_ring_size = DEFAULT_RX_RING_SIZE;
 
-	/* Initially, coalescing is disabled */
-	priv->txcoalescing = 0;
-	priv->txcount = 0;
-	priv->txtime = 0;
-	priv->rxcoalescing = 0;
-	priv->rxcount = 0;
-	priv->rxtime = 0;
+	priv->txcoalescing = DEFAULT_TX_COALESCE;
+	priv->txcount = DEFAULT_TXCOUNT;
+	priv->txtime = DEFAULT_TXTIME;
+	priv->rxcoalescing = DEFAULT_RX_COALESCE;
+	priv->rxcount = DEFAULT_RXCOUNT;
+	priv->rxtime = DEFAULT_RXTIME;
 
 	err = register_netdev(dev);
 
 	if (err) {
 		printk(KERN_ERR "%s: Cannot register net device, aborting.\n",
-		       dev->name);
+				dev->name);
 		goto register_fail;
 	}
 
@@ -367,10 +341,7 @@
 
 	return 0;
 
-
 register_fail:
-	kfree(dev_ethtool_ops);
-ethtool_fail:
 	iounmap((void *) priv->phyregs);
 phy_regs_fail:
 	iounmap((void *) priv->regs);
@@ -386,7 +357,6 @@
 
 	ocp_set_drvdata(ocpdev, NULL);
 
-	kfree(dev->ethtool_ops);
 	iounmap((void *) priv->regs);
 	iounmap((void *) priv->phyregs);
 	free_netdev(dev);
@@ -399,26 +369,90 @@
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct phy_info *curphy;
+	unsigned int timeout = PHY_INIT_TIMEOUT;
+	struct gfar *phyregs = priv->phyregs;
+	struct gfar_mii_info *mii_info;
+	int err;
 
-	priv->link = 1;
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
-	priv->olddplx = -1;
+	priv->oldduplex = -1;
+
+	mii_info = kmalloc(sizeof(struct gfar_mii_info),
+			GFP_KERNEL);
+
+	if(NULL == mii_info) {
+		printk(KERN_ERR "%s: Could not allocate mii_info\n", 
+				dev->name);
+		return -ENOMEM;
+	}
+
+	mii_info->speed = SPEED_1000;
+	mii_info->duplex = DUPLEX_FULL;
+	mii_info->pause = 0;
+	mii_info->link = 1;
+
+	mii_info->advertising = (ADVERTISED_10baseT_Half |
+			ADVERTISED_10baseT_Full |
+			ADVERTISED_100baseT_Half |
+			ADVERTISED_100baseT_Full |
+			ADVERTISED_1000baseT_Full);
+	mii_info->autoneg = 1;
+
+	mii_info->mii_id = priv->einfo->phyid;
+
+	mii_info->dev = dev;
+
+	mii_info->mdio_read = &read_phy_reg;
+	mii_info->mdio_write = &write_phy_reg;
+
+	priv->mii_info = mii_info;
+
+	/* Reset the management interface */
+	gfar_write(&phyregs->miimcfg, MIIMCFG_RESET);
+
+	/* Setup the MII Mgmt clock speed */
+	gfar_write(&phyregs->miimcfg, MIIMCFG_INIT_VALUE);
+
+	/* Wait until the bus is free */
+	while ((gfar_read(&phyregs->miimind) & MIIMIND_BUSY) &&
+			timeout--)
+		cpu_relax();
+
+	if(timeout <= 0) {
+		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
+				dev->name);
+		err = -1;
+		goto bus_fail;
+	}
 
 	/* get info for this PHY */
-	curphy = get_phy_info(dev);
+	curphy = get_phy_info(priv->mii_info);
 
 	if (curphy == NULL) {
 		printk(KERN_ERR "%s: No PHY found\n", dev->name);
-		return -1;
+		err = -1;
+		goto no_phy;
 	}
 
-	priv->phyinfo = curphy;
+	mii_info->phyinfo = curphy;
 
-	/* Run the commands which configure the PHY */
-	phy_run_commands(dev, curphy->config);
+	/* Run the commands which initialize the PHY */
+	if(curphy->init) {
+		err = curphy->init(priv->mii_info);
+
+		if (err) 
+			goto phy_init_fail;
+	}
 
 	return 0;
+
+phy_init_fail:
+no_phy:
+bus_fail:
+	kfree(mii_info);
+
+	return err;
 }
 
 static void init_registers(struct net_device *dev)
@@ -483,6 +517,20 @@
 	gfar_write(&priv->regs->tbipa, TBIPA_VALUE);
 }
 
+void mii_clear_phy_interrupt(struct gfar_mii_info *mii_info)
+{
+	if(mii_info->phyinfo->ack_interrupt)
+		mii_info->phyinfo->ack_interrupt(mii_info);
+}
+
+
+void mii_configure_phy_interrupt(struct gfar_mii_info *mii_info, u32 interrupts)
+{
+	mii_info->interrupts = interrupts;
+	mii_info->phyinfo->config_intr(mii_info);
+}
+
+
 void stop_gfar(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -494,7 +542,7 @@
 	spin_lock_irqsave(&priv->lock, flags);
 
 	/* Tell the kernel the link is down */
-	priv->link = 0;
+	priv->mii_info->link = 0;
 	adjust_link(dev);
 
 	/* Mask all interrupts */
@@ -521,7 +569,12 @@
 	gfar_write(&regs->maccfg1, tempval);
 
 	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
-		phy_run_commands(dev, priv->phyinfo->shutdown);
+		/* Clear any pending interrupts */
+		mii_clear_phy_interrupt(priv->mii_info);
+
+		/* Disable PHY Interrupts */
+		mii_configure_phy_interrupt(priv->mii_info, 
+				MII_INTERRUPT_DISABLED);
 	}
 
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -543,15 +596,14 @@
 
 	free_skb_resources(priv);
 
-	dma_unmap_single(NULL, gfar_read(&regs->tbase),
-			sizeof(struct txbd)*priv->tx_ring_size,
-			DMA_BIDIRECTIONAL);
-	dma_unmap_single(NULL, gfar_read(&regs->rbase),
-			sizeof(struct rxbd)*priv->rx_ring_size,
-			DMA_BIDIRECTIONAL);
+	dma_free_coherent(NULL,
+			sizeof(struct txbd8)*priv->tx_ring_size
+			+ sizeof(struct rxbd8)*priv->rx_ring_size,
+			priv->tx_bd_base,
+			gfar_read(&regs->tbase));
 
 	/* Free the buffer descriptors */
-	kfree(priv->tx_bd_base);
+	kfree(priv->mii_info);
 }
 
 /* If there are any tx skbs or rx skbs still around, free them.
@@ -610,7 +662,8 @@
 {
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
-	unsigned long addr;
+	dma_addr_t addr;
+	unsigned long vaddr;
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar *regs = priv->regs;
@@ -620,32 +673,27 @@
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	addr =
-	    (unsigned int) kmalloc(sizeof (struct txbd8) * priv->tx_ring_size +
-				   sizeof (struct rxbd8) * priv->rx_ring_size,
-				   GFP_KERNEL);
+	vaddr = (unsigned long) dma_alloc_coherent(NULL, 
+			sizeof (struct txbd8) * priv->tx_ring_size +
+			sizeof (struct rxbd8) * priv->rx_ring_size,
+			&addr, GFP_KERNEL);
 
-	if (addr == 0) {
+	if (vaddr == 0) {
 		printk(KERN_ERR "%s: Could not allocate buffer descriptors!\n",
 		       dev->name);
 		return -ENOMEM;
 	}
 
-	priv->tx_bd_base = (struct txbd8 *) addr;
+	priv->tx_bd_base = (struct txbd8 *) vaddr;
 
 	/* enet DMA only understands physical addresses */
-	gfar_write(&regs->tbase, 
-			dma_map_single(NULL, (void *)addr, 
-				sizeof(struct txbd8) * priv->tx_ring_size,
-				DMA_BIDIRECTIONAL));
+	gfar_write(&regs->tbase, addr);
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
 	addr = addr + sizeof (struct txbd8) * priv->tx_ring_size;
-	priv->rx_bd_base = (struct rxbd8 *) addr;
-	gfar_write(&regs->rbase, 
-			dma_map_single(NULL, (void *)addr, 
-				sizeof(struct rxbd8) * priv->rx_ring_size,
-				DMA_BIDIRECTIONAL));
+	vaddr = vaddr + sizeof (struct txbd8) * priv->tx_ring_size;
+	priv->rx_bd_base = (struct rxbd8 *) vaddr;
+	gfar_write(&regs->rbase, addr);
 
 	/* Setup the skbuff rings */
 	priv->tx_skbuff =
@@ -755,39 +803,13 @@
 		}
 	}
 
-	/* Grab the PHY interrupt */
-	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
-		if (request_irq(priv->einfo->interruptPHY, phy_interrupt,
-				SA_SHIRQ, "phy_interrupt", dev) < 0) {
-			printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
-			       dev->name, priv->einfo->interruptPHY);
-
-			err = -1;
-
-			if (priv->einfo->flags & GFAR_HAS_MULTI_INTR)
-				goto phy_irq_fail;
-			else
-				goto tx_irq_fail;
-		}
-	} else {
-		init_timer(&priv->phy_info_timer);
-		priv->phy_info_timer.function = &gfar_phy_timer;
-		priv->phy_info_timer.data = (unsigned long) dev;
-		mod_timer(&priv->phy_info_timer, jiffies + 2 * HZ);
-	}
-
-	/* Set up the bottom half queue */
-	INIT_WORK(&priv->tq, (void (*)(void *))gfar_phy_change, dev);
+	/* Set up the PHY change work queue */
+	INIT_WORK(&priv->tq, gfar_phy_change, dev);
 
-	/* Configure the PHY interrupt */
-	phy_run_commands(dev, priv->phyinfo->startup);
-
-	/* Tell the kernel the link is up, and determine the
-	 * negotiated features (speed, duplex) */
-	adjust_link(dev);
-
-	if (priv->link == 0)
-		printk(KERN_INFO "%s: No link detected\n", dev->name);
+	init_timer(&priv->phy_info_timer);
+	priv->phy_info_timer.function = &gfar_phy_startup_timer;
+	priv->phy_info_timer.data = (unsigned long) priv->mii_info;
+	mod_timer(&priv->phy_info_timer, jiffies + HZ);
 
 	/* Configure the coalescing support */
 	if (priv->txcoalescing)
@@ -827,8 +849,6 @@
 
 	return 0;
 
-phy_irq_fail:
-	free_irq(priv->einfo->interruptReceive, dev);
 rx_irq_fail:
 	free_irq(priv->einfo->interruptTransmit, dev);
 tx_irq_fail:
@@ -838,6 +858,11 @@
 	free_skb_resources(priv);
 tx_skb_fail:
 	kfree(priv->tx_bd_base);
+	kfree(priv->mii_info);
+
+	if (priv->mii_info->phyinfo->close)
+		priv->mii_info->phyinfo->close(priv->mii_info);
+
 	return err;
 }
 
@@ -854,7 +879,7 @@
 
 	err = init_phy(dev);
 
-	if (err)
+	if(err)
 		return err;
 
 	err = startup_gfar(dev);
@@ -1148,8 +1173,7 @@
 		startup_gfar(dev);
 	}
 
-	if (!netif_queue_stopped(dev))
-		netif_schedule(dev);
+	netif_schedule(dev);
 }
 
 /* Interrupt Handler for Transmit complete */
@@ -1315,7 +1339,7 @@
 #else
 
 	spin_lock(&priv->lock);
-	gfar_clean_rx_ring(dev);
+	gfar_clean_rx_ring(dev, priv->rx_ring_size);
 
 	/* If we are coalescing interrupts, update the timer */
 	/* Otherwise, clear it */
@@ -1368,14 +1392,10 @@
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
- *   until all are gone (or, in the case of NAPI, the budget/quota
- *   has been reached). Returns the number of frames handled
+ *   until the budget/quota has been reached. Returns the number 
+ *   of frames handled
  */
-#ifdef CONFIG_GFAR_NAPI
 static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
-#else
-static int gfar_clean_rx_ring(struct net_device *dev)
-#endif
 {
 	struct rxbd8 *bdp;
 	struct sk_buff *skb;
@@ -1386,12 +1406,7 @@
 	/* Get the first full descriptor */
 	bdp = priv->cur_rx;
 
-#ifdef CONFIG_GFAR_NAPI
-#define GFAR_RXDONE() ((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))
-#else
-#define GFAR_RXDONE() (bdp->status & RXBD_EMPTY)
-#endif
-	while (!GFAR_RXDONE()) {
+	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		skb = priv->rx_skbuff[priv->skb_currx];
 
 		if (!(bdp->status &
@@ -1462,7 +1477,6 @@
 	if (rx_work_limit > dev->quota)
 		rx_work_limit = dev->quota;
 
-	spin_lock(&priv->lock);
 	howmany = gfar_clean_rx_ring(dev, rx_work_limit);
 
 	dev->quota -= howmany;
@@ -1489,8 +1503,6 @@
 		priv->rxclean = 1;
 	}
 
-	spin_unlock(priv->lock);
-
 	return (rx_work_limit < 0) ? 1 : 0;
 }
 #endif
@@ -1586,10 +1598,14 @@
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct gfar_private *priv = netdev_priv(dev);
 
-	/* Run the commands which acknowledge the interrupt */
-	phy_run_commands(dev, priv->phyinfo->ack_int);
+	/* Clear the interrupt */
+	mii_clear_phy_interrupt(priv->mii_info);
+
+	/* Disable PHY interrupts */
+	mii_configure_phy_interrupt(priv->mii_info,
+			MII_INTERRUPT_DISABLED);
 
-	/* Schedule the bottom half */
+	/* Schedule the phy change */
 	schedule_work(&priv->tq);
 
 	return IRQ_HANDLED;
@@ -1600,18 +1616,24 @@
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct gfar_private *priv = netdev_priv(dev);
-	int timeout = HZ / 1000 + 1;
+	int result = 0;
 
 	/* Delay to give the PHY a chance to change the
 	 * register state */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(timeout);
+	msleep(1);
 
-	/* Run the commands which check the link state */
-	phy_run_commands(dev, priv->phyinfo->handle_int);
+	/* Update the link, speed, duplex */
+	result = priv->mii_info->phyinfo->read_status(priv->mii_info);
 
-	/* React to the change in state */
-	adjust_link(dev);
+	/* Adjust the known status as long as the link
+	 * isn't still coming up */
+	if((0 == result) || (priv->mii_info->link == 0))
+		adjust_link(dev);
+
+	/* Reenable interrupts, if needed */
+	if (priv->einfo->flags & GFAR_HAS_PHY_INTR)
+		mii_configure_phy_interrupt(priv->mii_info,
+				MII_INTERRUPT_ENABLED);
 }
 
 /* Called every so often on systems that don't interrupt
@@ -1623,7 +1645,72 @@
 
 	schedule_work(&priv->tq);
 
-	mod_timer(&priv->phy_info_timer, jiffies + 2 * HZ);
+	mod_timer(&priv->phy_info_timer, jiffies +
+			GFAR_PHY_CHANGE_TIME * HZ);
+}
+
+/* Keep trying aneg for some time
+ * If, after GFAR_AN_TIMEOUT seconds, it has not
+ * finished, we switch to forced.
+ * Either way, once the process has completed, we either
+ * request the interrupt, or switch the timer over to 
+ * using gfar_phy_timer to check status */
+static void gfar_phy_startup_timer(unsigned long data)
+{
+	int result;
+	static int secondary = GFAR_AN_TIMEOUT;
+	struct gfar_mii_info *mii_info = (struct gfar_mii_info *)data;
+	struct gfar_private *priv = netdev_priv(mii_info->dev);
+
+	/* Configure the Auto-negotiation */
+	result = mii_info->phyinfo->config_aneg(mii_info);
+
+	/* If autonegotiation failed to start, and
+	 * we haven't timed out, reset the timer, and return */
+	if (result && secondary--) {
+		mod_timer(&priv->phy_info_timer, jiffies + HZ);
+		return;
+	} else if (result) {
+		/* Couldn't start autonegotiation.
+		 * Try switching to forced */
+		mii_info->autoneg = 0;
+		result = mii_info->phyinfo->config_aneg(mii_info);
+
+		/* Forcing failed!  Give up */
+		if(result) {
+			printk(KERN_ERR "%s: Forcing failed!\n",
+					mii_info->dev->name);
+			return;
+		}
+	}
+
+	/* Kill the timer so it can be restarted */
+	del_timer_sync(&priv->phy_info_timer);
+
+	/* Grab the PHY interrupt, if necessary/possible */
+	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
+		if (request_irq(priv->einfo->interruptPHY, 
+					phy_interrupt,
+					SA_SHIRQ, 
+					"phy_interrupt", 
+					mii_info->dev) < 0) {
+			printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
+					mii_info->dev->name,
+					priv->einfo->interruptPHY);
+		} else {
+			mii_configure_phy_interrupt(priv->mii_info, 
+					MII_INTERRUPT_ENABLED);
+			return;
+		}
+	}
+
+	/* Start the timer again, this time in order to
+	 * handle a change in status */
+	init_timer(&priv->phy_info_timer);
+	priv->phy_info_timer.function = &gfar_phy_timer;
+	priv->phy_info_timer.data = (unsigned long) mii_info->dev;
+	mod_timer(&priv->phy_info_timer, jiffies +
+			GFAR_PHY_CHANGE_TIME * HZ);
 }
 
 /* Called every time the controller might need to be made
@@ -1637,12 +1724,13 @@
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar *regs = priv->regs;
 	u32 tempval;
+	struct gfar_mii_info *mii_info = priv->mii_info;
 
-	if (priv->link) {
+	if (mii_info->link) {
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
-		if (priv->duplexity != priv->olddplx) {
-			if (!(priv->duplexity)) {
+		if (mii_info->duplex != priv->oldduplex) {
+			if (!(mii_info->duplex)) {
 				tempval = gfar_read(&regs->maccfg2);
 				tempval &= ~(MACCFG2_FULL_DUPLEX);
 				gfar_write(&regs->maccfg2, tempval);
@@ -1658,11 +1746,11 @@
 				       dev->name);
 			}
 
-			priv->olddplx = priv->duplexity;
+			priv->oldduplex = mii_info->duplex;
 		}
 
-		if (priv->speed != priv->oldspeed) {
-			switch (priv->speed) {
+		if (priv->mii_info->speed != priv->oldspeed) {
+			switch (priv->mii_info->speed) {
 			case 1000:
 				tempval = gfar_read(&regs->maccfg2);
 				tempval =
@@ -1679,14 +1767,14 @@
 			default:
 				printk(KERN_WARNING
 				       "%s: Ack!  Speed (%d) is not 10/100/1000!\n",
-				       dev->name, priv->speed);
+				       dev->name, priv->mii_info->speed);
 				break;
 			}
 
 			printk(KERN_INFO "%s: Speed %dBT\n", dev->name,
-			       priv->speed);
+			       priv->mii_info->speed);
 
-			priv->oldspeed = priv->speed;
+			priv->oldspeed = priv->mii_info->speed;
 		}
 
 		if (!priv->oldlink) {
@@ -1700,7 +1788,7 @@
 			printk(KERN_INFO "%s: Link is down\n", dev->name);
 			priv->oldlink = 0;
 			priv->oldspeed = 0;
-			priv->olddplx = -1;
+			priv->oldduplex = -1;
 			netif_carrier_off(dev);
 		}
 	}
diff -Nru a/drivers/net/gianfar.h b/drivers/net/gianfar.h
--- a/drivers/net/gianfar.h	Mon Jul 26 17:01:55 2004
+++ b/drivers/net/gianfar.h	Mon Jul 26 17:01:55 2004
@@ -8,7 +8,7 @@
  * Author: Andy Fleming
  * Maintainer: Kumar Gala (kumar.gala@freescale.com)
  *
- * Copyright 2004 Freescale Semiconductor, Inc
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -42,15 +42,7 @@
 #include <linux/module.h>
 #include <linux/version.h>
 #include <linux/crc32.h>
-
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
 #include <linux/workqueue.h>
-#else
-#include <linux/tqueue.h>
-#define work_struct tq_struct
-#define schedule_work schedule_task
-#endif
-
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <asm/ocp.h>
@@ -70,8 +62,13 @@
 
 #define MAC_ADDR_LEN 6
 
-extern char gfar_driver_name[];
-extern char gfar_driver_version[];
+#define PHY_INIT_TIMEOUT 100000
+#define GFAR_PHY_CHANGE_TIME 2
+
+#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.1, "
+#define DRV_NAME "gfar-enet"
+extern const char gfar_driver_name[];
+extern const char gfar_driver_version[];
 
 /* These need to be powers of 2 for this driver */
 #ifdef CONFIG_GFAR_NAPI
@@ -105,11 +102,13 @@
 #define GFAR_100_TIME   2560
 #define GFAR_10_TIME    25600
 
+#define DEFAULT_TX_COALESCE 1
 #define DEFAULT_TXCOUNT	16
-#define DEFAULT_TXTIME	32768
+#define DEFAULT_TXTIME	400
 
+#define DEFAULT_RX_COALESCE 1
 #define DEFAULT_RXCOUNT	16
-#define DEFAULT_RXTIME	32768
+#define DEFAULT_RXTIME	400
 
 #define TBIPA_VALUE		0x1f
 #define MIIMCFG_INIT_VALUE	0x00000007
@@ -467,8 +466,7 @@
  * empty and completely full conditions.  The empty/ready indicator in
  * the buffer descriptor determines the actual condition.
  */
-struct gfar_private
-{
+struct gfar_private {
 	/* pointers to arrays of skbuffs for tx and rx */
 	struct sk_buff ** tx_skbuff;
 	struct sk_buff ** rx_skbuff;
@@ -496,7 +494,6 @@
 	struct txbd8 *cur_tx;	        /* Next free ring entry */
 	struct txbd8 *dirty_tx;		/* The Ring entry to be freed. */
 	struct gfar *regs;	/* Pointer to the GFAR memory mapped Registers */
-	struct phy_info *phyinfo;
 	struct gfar *phyregs;
 	struct work_struct tq;
 	struct timer_list phy_info_timer;
@@ -509,15 +506,14 @@
 	unsigned int rx_ring_size;
 	wait_queue_head_t rxcleanupq;
 	unsigned int rxclean;
-	int link;	/* current link state */
-	int oldlink;
-	int duplexity; /* Indicates negotiated duplex state */
-	int olddplx;
-	int speed;	/* Indicates negotiated speed */
-	int oldspeed;
-	
+
 	/* Info structure initialized by board setup code */
 	struct ocp_gfar_data *einfo;
+
+	struct gfar_mii_info *mii_info;
+	int oldspeed;
+	int oldduplex;
+	int oldlink;
 };
 
 extern inline u32 gfar_read(volatile unsigned *addr)
@@ -532,6 +528,6 @@
 	out_be32(addr, val);
 }
 
-
+extern struct ethtool_ops *gfar_op_array[];
 
 #endif /* __GIANFAR_H */
diff -Nru a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
--- a/drivers/net/gianfar_ethtool.c	Mon Jul 26 17:01:55 2004
+++ b/drivers/net/gianfar_ethtool.c	Mon Jul 26 17:01:55 2004
@@ -1,18 +1,18 @@
 /*
- * drivers/net/gianfar_ethtool.c
+ *  drivers/net/gianfar_ethtool.c
  *
- * Gianfar Ethernet Driver
- * Ethtool support for Gianfar Enet
- * Based on e1000 ethtool support
+ *  Gianfar Ethernet Driver
+ *  Ethtool support for Gianfar Enet
+ *  Based on e1000 ethtool support
  *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *  Author: Andy Fleming
+ *  Maintainer: Kumar Gala (kumar.gala@freescale.com)
  *
- * Copyright 2004 Freescale Semiconductor, Inc
+ *  Copyright (c) 2003,2004 Freescale Semiconductor, Inc.
  *
- * This software may be used and distributed according to 
- * the terms of the GNU Public License, Version 2, incorporated herein 
- * by reference.
+ *  This software may be used and distributed according to 
+ *  the terms of the GNU Public License, Version 2, incorporated herein 
+ *  by reference.
  */
 
 #include <linux/config.h>
@@ -58,64 +58,64 @@
 void gfar_gdrvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo);
 
 static char stat_gstrings[][ETH_GSTRING_LEN] = {
-	"RX Dropped by Kernel",
-	"RX Large Frame Errors",
-	"RX Short Frame Errors",
-	"RX Non-Octet Errors",
-	"RX CRC Errors",
-	"RX Overrun Errors",
-	"RX Busy Errors",
-	"RX Babbling Errors",
-	"RX Truncated Frames",
-	"Ethernet Bus Error",
-	"TX Babbling Errors",
-	"TX Underrun Errors",
-	"RX SKB Missing Errors",
-	"TX Timeout Errors",
-	"tx&rx 64B frames",
-	"tx&rx 65-127B frames",
-	"tx&rx 128-255B frames",
-	"tx&rx 256-511B frames",
-	"tx&rx 512-1023B frames",
-	"tx&rx 1024-1518B frames",
-	"tx&rx 1519-1522B Good VLAN",
-	"RX bytes",
-	"RX Packets",
-	"RX FCS Errors",
-	"Receive Multicast Packet",
-	"Receive Broadcast Packet",
-	"RX Control Frame Packets",
-	"RX Pause Frame Packets",
-	"RX Unknown OP Code",
-	"RX Alignment Error",
-	"RX Frame Length Error",
-	"RX Code Error",
-	"RX Carrier Sense Error",
-	"RX Undersize Packets",
-	"RX Oversize Packets",
-	"RX Fragmented Frames",
-	"RX Jabber Frames",
-	"RX Dropped Frames",
-	"TX Byte Counter",
-	"TX Packets",
-	"TX Multicast Packets",
-	"TX Broadcast Packets",
-	"TX Pause Control Frames",
-	"TX Deferral Packets",
-	"TX Excessive Deferral Packets",
-	"TX Single Collision Packets",
-	"TX Multiple Collision Packets",
-	"TX Late Collision Packets",
-	"TX Excessive Collision Packets",
-	"TX Total Collision",
-	"RESERVED",
-	"TX Dropped Frames",
-	"TX Jabber Frames",
-	"TX FCS Errors",
-	"TX Control Frames",
-	"TX Oversize Frames",
-	"TX Undersize Frames",
-	"TX Fragmented Frames",
+	"rx-dropped-by-kernel",
+	"rx-large-frame-errors",
+	"rx-short-frame-errors",
+	"rx-non-octet-errors",
+	"rx-crc-errors",
+	"rx-overrun-errors",
+	"rx-busy-errors",
+	"rx-babbling-errors",
+	"rx-truncated-frames",
+	"ethernet-bus-error",
+	"tx-babbling-errors",
+	"tx-underrun-errors",
+	"rx-skb-missing-errors",
+	"tx-timeout-errors",
+	"tx-rx-64-frames",
+	"tx-rx-65-127-frames",
+	"tx-rx-128-255-frames",
+	"tx-rx-256-511-frames",
+	"tx-rx-512-1023-frames",
+	"tx-rx-1024-1518-frames",
+	"tx-rx-1519-1522-good-vlan",
+	"rx-bytes",
+	"rx-packets",
+	"rx-fcs-errors",
+	"receive-multicast-packet",
+	"receive-broadcast-packet",
+	"rx-control-frame-packets",
+	"rx-pause-frame-packets",
+	"rx-unknown-op-code",
+	"rx-alignment-error",
+	"rx-frame-length-error",
+	"rx-code-error",
+	"rx-carrier-sense-error",
+	"rx-undersize-packets",
+	"rx-oversize-packets",
+	"rx-fragmented-frames",
+	"rx-jabber-frames",
+	"rx-dropped-frames",
+	"tx-byte-counter",
+	"tx-packets",
+	"tx-multicast-packets",
+	"tx-broadcast-packets",
+	"tx-pause-control-frames",
+	"tx-deferral-packets",
+	"tx-excessive-deferral-packets",
+	"tx-single-collision-packets",
+	"tx-multiple-collision-packets",
+	"tx-late-collision-packets",
+	"tx-excessive-collision-packets",
+	"tx-total-collision",
+	"reserved",
+	"tx-dropped-frames",
+	"tx-jabber-frames",
+	"tx-fcs-errors",
+	"tx-control-frames",
+	"tx-oversize-frames",
+	"tx-undersize-frames",
+	"tx-fragmented-frames",
 };
 
 /* Fill in an array of 64-bit statistics from various sources.
@@ -125,7 +125,7 @@
 void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy, u64 * buf)
 {
 	int i;
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	u32 *rmon = (u32 *) & priv->regs->rmon;
 	u64 *extra = (u64 *) & priv->extra_stats;
 	struct gfar_stats *stats = (struct gfar_stats *) buf;
@@ -154,7 +154,7 @@
 		struct ethtool_stats *dummy, u64 * buf)
 {
 	int i;
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	u64 *extra = (u64 *) & priv->extra_stats;
 
 	for (i = 0; i < GFAR_EXTRA_STATS_LEN; i++) {
@@ -171,7 +171,7 @@
 void gfar_gdrvinfo(struct net_device *dev, struct
 	      ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, gfar_driver_name, GFAR_INFOSTR_LEN);
+	strncpy(drvinfo->driver, DRV_NAME, GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->fw_version, "N/A", GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->bus_info, "N/A", GFAR_INFOSTR_LEN);
@@ -184,7 +184,7 @@
 /* Return the current settings in the ethtool_cmd structure */
 int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	uint gigabit_support = 
 		priv->einfo->flags & GFAR_HAS_GIGABIT ? SUPPORTED_1000baseT_Full : 0;
 	uint gigabit_advert = 
@@ -201,10 +201,10 @@
 			    | ADVERTISED_100baseT_Full
 			    | gigabit_advert | ADVERTISED_Autoneg);
 
-	cmd->speed = priv->speed;
-	cmd->duplex = priv->duplexity;
+	cmd->speed = priv->mii_info->speed;
+	cmd->duplex = priv->mii_info->duplex;
 	cmd->port = PORT_MII;
-	cmd->phy_address = priv->einfo->phyid;
+	cmd->phy_address = priv->mii_info->mii_id;
 	cmd->transceiver = XCVR_EXTERNAL;
 	cmd->autoneg = AUTONEG_ENABLE;
 	cmd->maxtxpkt = priv->txcount;
@@ -223,7 +223,7 @@
 void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
 {
 	int i;
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	u32 *theregs = (u32 *) priv->regs;
 	u32 *buf = (u32 *) regbuf;
 
@@ -231,13 +231,6 @@
 		buf[i] = theregs[i];
 }
 
-/* Return the link state 1 is up, 0 is down */
-u32 gfar_get_link(struct net_device *dev)
-{
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
-	return (u32) priv->link;
-}
-
 /* Fill in a buffer with the strings which correspond to the
  * stats */
 void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf)
@@ -252,7 +245,7 @@
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->speed) {
+	switch (priv->mii_info->speed) {
 	case 1000:
 		count = GFAR_GBIT_TIME;
 		break;
@@ -276,7 +269,7 @@
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->speed) {
+	switch (priv->mii_info->speed) {
 	case 1000:
 		count = GFAR_GBIT_TIME;
 		break;
@@ -298,7 +291,7 @@
  * structure.  */
 int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 
 	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, priv->rxtime);
 	cvals->rx_max_coalesced_frames = priv->rxcount;
@@ -344,7 +337,7 @@
  */
 int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 
 	/* Set up rx coalescing */
 	if ((cvals->rx_coalesce_usecs == 0) ||
@@ -386,7 +379,7 @@
  * jumbo are ignored by the driver */
 void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 
 	rvals->rx_max_pending = GFAR_RX_MAX_RING_SIZE;
 	rvals->rx_mini_max_pending = GFAR_RX_MAX_RING_SIZE;
@@ -409,7 +402,7 @@
 int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
 {
 	u32 tempval;
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	int err = 0;
 
 	if (rvals->rx_pending > GFAR_RX_MAX_RING_SIZE)
@@ -473,7 +466,7 @@
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
 	.get_regs = gfar_get_regs,
-	.get_link = gfar_get_link,
+	.get_link = ethtool_op_get_link,
 	.get_coalesce = gfar_gcoalesce,
 	.set_coalesce = gfar_scoalesce,
 	.get_ringparam = gfar_gringparam,
@@ -481,4 +474,52 @@
 	.get_strings = gfar_gstrings,
 	.get_stats_count = gfar_stats_count,
 	.get_ethtool_stats = gfar_fill_stats,
+};
+
+struct ethtool_ops gfar_normon_nocoalesce_ethtool_ops = {
+	.get_settings = gfar_gsettings,
+	.get_drvinfo = gfar_gdrvinfo,
+	.get_regs_len = gfar_reglen,
+	.get_regs = gfar_get_regs,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = gfar_gringparam,
+	.set_ringparam = gfar_sringparam,
+	.get_strings = gfar_gstrings_normon,
+	.get_stats_count = gfar_stats_count_normon,
+	.get_ethtool_stats = gfar_fill_stats_normon,
+};
+
+struct ethtool_ops gfar_nocoalesce_ethtool_ops = {
+	.get_settings = gfar_gsettings,
+	.get_drvinfo = gfar_gdrvinfo,
+	.get_regs_len = gfar_reglen,
+	.get_regs = gfar_get_regs,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = gfar_gringparam,
+	.set_ringparam = gfar_sringparam,
+	.get_strings = gfar_gstrings,
+	.get_stats_count = gfar_stats_count,
+	.get_ethtool_stats = gfar_fill_stats,
+};
+
+struct ethtool_ops gfar_normon_ethtool_ops = {
+	.get_settings = gfar_gsettings,
+	.get_drvinfo = gfar_gdrvinfo,
+	.get_regs_len = gfar_reglen,
+	.get_regs = gfar_get_regs,
+	.get_link = ethtool_op_get_link,
+	.get_coalesce = gfar_gcoalesce,
+	.set_coalesce = gfar_scoalesce,
+	.get_ringparam = gfar_gringparam,
+	.set_ringparam = gfar_sringparam,
+	.get_strings = gfar_gstrings_normon,
+	.get_stats_count = gfar_stats_count_normon,
+	.get_ethtool_stats = gfar_fill_stats_normon,
+};
+
+struct ethtool_ops *gfar_op_array[] = {
+	&gfar_ethtool_ops,
+	&gfar_normon_ethtool_ops,
+	&gfar_nocoalesce_ethtool_ops,
+	&gfar_normon_nocoalesce_ethtool_ops
 };
diff -Nru a/drivers/net/gianfar_phy.c b/drivers/net/gianfar_phy.c
--- a/drivers/net/gianfar_phy.c	Mon Jul 26 17:01:55 2004
+++ b/drivers/net/gianfar_phy.c	Mon Jul 26 17:01:55 2004
@@ -8,7 +8,7 @@
  * Author: Andy Fleming
  * Maintainer: Kumar Gala (kumar.gala@freescale.com)
  *
- * Copyright 2004 Freescale Semiconductor, Inc
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -38,21 +38,31 @@
 #include <linux/module.h>
 #include <linux/version.h>
 #include <linux/crc32.h>
+#include <linux/mii.h>
 
 #include "gianfar.h"
 #include "gianfar_phy.h"
 
+static void config_genmii_advert(struct gfar_mii_info *mii_info);
+static void genmii_setup_forced(struct gfar_mii_info *mii_info);
+static void genmii_restart_aneg(struct gfar_mii_info *mii_info);
+static int gbit_config_aneg(struct gfar_mii_info *mii_info);
+static int genmii_config_aneg(struct gfar_mii_info *mii_info);
+static int genmii_update_link(struct gfar_mii_info *mii_info);
+static int genmii_read_status(struct gfar_mii_info *mii_info);
+u16 phy_read(struct gfar_mii_info *mii_info, u16 regnum);
+void phy_write(struct gfar_mii_info *mii_info, u16 regnum, u16 val);
+
 /* Write value to the PHY for this device to the register at regnum, */
 /* waiting until the write is done before it returns.  All PHY */
 /* configuration has to be done through the TSEC1 MIIM regs */
-void write_phy_reg(struct net_device *dev, u16 regnum, u16 value)
+void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar *regbase = priv->phyregs;
-	struct ocp_gfar_data *einfo = priv->einfo;
 
 	/* Set the PHY address and the register address we want to write */
-	gfar_write(&regbase->miimadd, ((einfo->phyid) << 8) | regnum);
+	gfar_write(&regbase->miimadd, (mii_id << 8) | regnum);
 
 	/* Write out the value we want */
 	gfar_write(&regbase->miimcon, value);
@@ -65,19 +75,18 @@
 /* Reads from register regnum in the PHY for device dev, */
 /* returning the value.  Clears miimcom first.  All PHY */
 /* configuration has to be done through the TSEC1 MIIM regs */
-u16 read_phy_reg(struct net_device *dev, u16 regnum)
+int read_phy_reg(struct net_device *dev, int mii_id, int regnum)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar *regbase = priv->phyregs;
-	struct ocp_gfar_data *einfo = priv->einfo;
 	u16 value;
 
 	/* Set the PHY address and the register address we want to read */
-	gfar_write(&regbase->miimadd, ((einfo->phyid) << 8) | regnum);
+	gfar_write(&regbase->miimadd, (mii_id << 8) | regnum);
 
 	/* Clear miimcom, and then initiate a read */
 	gfar_write(&regbase->miimcom, 0);
-	gfar_write(&regbase->miimcom, MIIM_READ_COMMAND);
+	gfar_write(&regbase->miimcom, MII_READ_COMMAND);
 
 	/* Wait for the transaction to finish */
 	while (gfar_read(&regbase->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
@@ -89,362 +98,531 @@
 	return value;
 }
 
-/* returns which value to write to the control register. */
-/* For 10/100 the value is slightly different. */
-u16 mii_cr_init(u16 mii_reg, struct net_device * dev)
+/* Writes MII_ADVERTISE with the appropriate values, after
+ * sanitizing advertise to make sure only supported features
+ * are advertised 
+ */
+static void config_genmii_advert(struct gfar_mii_info *mii_info)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
-	struct ocp_gfar_data *einfo = priv->einfo;
+	u32 advertise;
+	u16 adv;
 
-	if (einfo->flags & GFAR_HAS_GIGABIT)
-		return MIIM_CONTROL_INIT;
-	else
-		return MIIM_CR_INIT;
+	/* Only allow advertising what this PHY supports */
+	mii_info->advertising &= mii_info->phyinfo->features;
+	advertise = mii_info->advertising;
+
+	/* Setup standard advertisement */
+	adv = phy_read(mii_info, MII_ADVERTISE);
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+	if (advertise & ADVERTISED_10baseT_Half)
+		adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		adv |= ADVERTISE_100FULL;
+	phy_write(mii_info, MII_ADVERTISE, adv);
+}
+
+static void genmii_setup_forced(struct gfar_mii_info *mii_info)
+{
+	u16 ctrl;
+	u32 features = mii_info->phyinfo->features;
+	
+	ctrl = phy_read(mii_info, MII_BMCR);
+
+	ctrl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPEED1000|BMCR_ANENABLE);
+	ctrl |= BMCR_RESET;
+
+	switch(mii_info->speed) {
+		case SPEED_1000:
+			if(features & (SUPPORTED_1000baseT_Half
+						| SUPPORTED_1000baseT_Full)) {
+				ctrl |= BMCR_SPEED1000;
+				break;
+			}
+			mii_info->speed = SPEED_100;
+		case SPEED_100:
+			if (features & (SUPPORTED_100baseT_Half
+						| SUPPORTED_100baseT_Full)) {
+				ctrl |= BMCR_SPEED100;
+				break;
+			}
+			mii_info->speed = SPEED_10;
+		case SPEED_10:
+			if (features & (SUPPORTED_10baseT_Half
+						| SUPPORTED_10baseT_Full))
+				break;
+		default: /* Unsupported speed! */
+			printk(KERN_ERR "%s: Bad speed!\n", 
+					mii_info->dev->name);
+			break;
+	}
+
+	phy_write(mii_info, MII_BMCR, ctrl);
 }
 
-#define BRIEF_GFAR_ERRORS
-/* Wait for auto-negotiation to complete */
-u16 mii_parse_sr(u16 mii_reg, struct net_device * dev)
+
+/* Enable and Restart Autonegotiation */
+static void genmii_restart_aneg(struct gfar_mii_info *mii_info)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	u16 ctl;
+
+	ctl = phy_read(mii_info, MII_BMCR);
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	phy_write(mii_info, MII_BMCR, ctl);
+}
 
-	unsigned int timeout = GFAR_AN_TIMEOUT;
 
-	if (mii_reg & MIIM_STATUS_LINK)
-		priv->link = 1;
+static int gbit_config_aneg(struct gfar_mii_info *mii_info)
+{
+	u16 adv;
+	u32 advertise;
+
+	if(mii_info->autoneg) {
+		/* Configure the ADVERTISE register */
+		config_genmii_advert(mii_info);
+		advertise = mii_info->advertising;
+
+		adv = phy_read(mii_info, MII_1000BASETCONTROL);
+		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
+				MII_1000BASETCONTROL_HALFDUPLEXCAP);
+		if (advertise & SUPPORTED_1000baseT_Half)
+			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
+		if (advertise & SUPPORTED_1000baseT_Full)
+			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
+		phy_write(mii_info, MII_1000BASETCONTROL, adv);
+
+		/* Start/Restart aneg */
+		genmii_restart_aneg(mii_info);
+	} else
+		genmii_setup_forced(mii_info);
+
+	return 0;
+}
+
+static int marvell_config_aneg(struct gfar_mii_info *mii_info)
+{
+	/* The Marvell PHY has an errata which requires
+	 * that certain registers get written in order
+	 * to restart autonegotiation */
+	phy_write(mii_info, MII_BMCR, BMCR_RESET);
+
+	phy_write(mii_info, 0x1d, 0x1f);
+	phy_write(mii_info, 0x1e, 0x200c);
+	phy_write(mii_info, 0x1d, 0x5);
+	phy_write(mii_info, 0x1e, 0);
+	phy_write(mii_info, 0x1e, 0x100);
+
+	gbit_config_aneg(mii_info);
+
+	return 0;
+}
+static int genmii_config_aneg(struct gfar_mii_info *mii_info)
+{
+	if (mii_info->autoneg) {
+		config_genmii_advert(mii_info);
+		genmii_restart_aneg(mii_info);
+	} else
+		genmii_setup_forced(mii_info);
+
+	return 0;
+}
+
+
+static int genmii_update_link(struct gfar_mii_info *mii_info)
+{
+	u16 status;
+
+	/* Do a fake read */
+	phy_read(mii_info, MII_BMSR);
+
+	/* Read link and autonegotiation status */
+	status = phy_read(mii_info, MII_BMSR);
+	if ((status & BMSR_LSTATUS) == 0)
+		mii_info->link = 0;
 	else
-		priv->link = 0;
+		mii_info->link = 1;
 
-	/* Only auto-negotiate if the link has just gone up */
-	if (priv->link && !priv->oldlink) {
-		while ((!(mii_reg & MIIM_STATUS_AN_DONE)) && timeout--)
-			mii_reg = read_phy_reg(dev, MIIM_STATUS);
-
-#if defined(BRIEF_GFAR_ERRORS)
-		if (mii_reg & MIIM_STATUS_AN_DONE)
-			printk(KERN_INFO "%s: Auto-negotiation done\n",
-			       dev->name);
-		else
-			printk(KERN_INFO "%s: Auto-negotiation timed out\n",
-			       dev->name);
-#endif
-	}
+	/* If we are autonegotiating, and not done, 
+	 * return an error */
+	if (mii_info->autoneg && !(status & BMSR_ANEGCOMPLETE))
+		return -EAGAIN;
 
 	return 0;
 }
 
-/* Determine the speed and duplex which was negotiated */
-u16 mii_parse_88E1011_psr(u16 mii_reg, struct net_device * dev)
+static int genmii_read_status(struct gfar_mii_info *mii_info)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
-	unsigned int speed;
+	u16 status;
+	int err;
 
-	if (priv->link) {
-		if (mii_reg & MIIM_88E1011_PHYSTAT_DUPLEX)
-			priv->duplexity = 1;
+	/* Update the link, but return if there
+	 * was an error */
+	err = genmii_update_link(mii_info);
+	if (err)
+		return err;
+
+	if (mii_info->autoneg) {
+		status = phy_read(mii_info, MII_LPA);
+
+		if (status & (LPA_10FULL | LPA_100FULL))
+			mii_info->duplex = DUPLEX_FULL;
+		else
+			mii_info->duplex = DUPLEX_HALF;
+		if (status & (LPA_100FULL | LPA_100HALF))
+			mii_info->speed = SPEED_100;
 		else
-			priv->duplexity = 0;
+			mii_info->speed = SPEED_10;
+		mii_info->pause = 0;
+	}
+	/* On non-aneg, we assume what we put in BMCR is the speed,
+	 * though magic-aneg shouldn't prevent this case from occurring
+	 */
 
-		speed = (mii_reg & MIIM_88E1011_PHYSTAT_SPEED);
+	return 0;
+}
+static int marvell_read_status(struct gfar_mii_info *mii_info)
+{
+	u16 status;
+	int err;
 
-		switch (speed) {
-		case MIIM_88E1011_PHYSTAT_GBIT:
-			priv->speed = 1000;
-			break;
-		case MIIM_88E1011_PHYSTAT_100:
-			priv->speed = 100;
-			break;
-		default:
-			priv->speed = 10;
-			break;
+	/* Update the link, but return if there
+	 * was an error */
+	err = genmii_update_link(mii_info);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds 
+	 * are as set */
+	if (mii_info->autoneg && mii_info->link) {
+		int speed;
+		status = phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
+
+#if 0
+		/* If speed and duplex aren't resolved,
+		 * return an error.  Isn't this handled
+		 * by checking aneg?
+		 */
+		if ((status & MII_M1011_PHY_SPEC_STATUS_RESOLVED) == 0)
+			return -EAGAIN;
+#endif
+
+		/* Get the duplexity */
+		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
+			mii_info->duplex = DUPLEX_FULL;
+		else
+			mii_info->duplex = DUPLEX_HALF;
+
+		/* Get the speed */
+		speed = status & MII_M1011_PHY_SPEC_STATUS_SPD_MASK;
+		switch(speed) {
+			case MII_M1011_PHY_SPEC_STATUS_1000:
+				mii_info->speed = SPEED_1000;
+				break;
+			case MII_M1011_PHY_SPEC_STATUS_100:
+				mii_info->speed = SPEED_100;
+				break;
+			default:
+				mii_info->speed = SPEED_10;
+				break;
 		}
-	} else {
-		priv->speed = 0;
-		priv->duplexity = 0;
+		mii_info->pause = 0;
 	}
 
 	return 0;
 }
 
-u16 mii_parse_cis8201(u16 mii_reg, struct net_device * dev)
+
+static int cis820x_read_status(struct gfar_mii_info *mii_info)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
-	unsigned int speed;
+	u16 status;
+	int err;
 
-	if (priv->link) {
-		if (mii_reg & MIIM_CIS8201_AUXCONSTAT_DUPLEX)
-			priv->duplexity = 1;
+	/* Update the link, but return if there
+	 * was an error */
+	err = genmii_update_link(mii_info);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds 
+	 * are as set */
+	if (mii_info->autoneg && mii_info->link) {
+		int speed;
+
+		status = phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
+		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
+			mii_info->duplex = DUPLEX_FULL;
 		else
-			priv->duplexity = 0;
+			mii_info->duplex = DUPLEX_HALF;
 
-		speed = mii_reg & MIIM_CIS8201_AUXCONSTAT_SPEED;
+		speed = status & MII_CIS8201_AUXCONSTAT_SPEED;
 
 		switch (speed) {
-		case MIIM_CIS8201_AUXCONSTAT_GBIT:
-			priv->speed = 1000;
+		case MII_CIS8201_AUXCONSTAT_GBIT:
+			mii_info->speed = SPEED_1000;
 			break;
-		case MIIM_CIS8201_AUXCONSTAT_100:
-			priv->speed = 100;
+		case MII_CIS8201_AUXCONSTAT_100:
+			mii_info->speed = SPEED_100;
 			break;
 		default:
-			priv->speed = 10;
+			mii_info->speed = SPEED_10;
 			break;
 		}
-	} else {
-		priv->speed = 0;
-		priv->duplexity = 0;
 	}
 
 	return 0;
 }
 
-u16 mii_parse_dm9161_scsr(u16 mii_reg, struct net_device * dev)
+static int marvell_ack_interrupt(struct gfar_mii_info *mii_info)
 {
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
+	/* Clear the interrupts by reading the reg */
+	phy_read(mii_info, MII_M1011_IEVENT);
 
-	if (mii_reg & (MIIM_DM9161_SCSR_100F | MIIM_DM9161_SCSR_100H))
-		priv->speed = 100;
+	return 0;
+}
+
+static int marvell_config_intr(struct gfar_mii_info *mii_info)
+{
+	if(mii_info->interrupts == MII_INTERRUPT_ENABLED)
+		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
 	else
-		priv->speed = 10;
+		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+
+	return 0;
+}
+
+static int cis820x_init(struct gfar_mii_info *mii_info)
+{
+	phy_write(mii_info, MII_CIS8201_AUX_CONSTAT, 
+			MII_CIS8201_AUXCONSTAT_INIT);
+	phy_write(mii_info, MII_CIS8201_EXT_CON1,
+			MII_CIS8201_EXTCON1_INIT);
+
+	return 0;
+}
+
+static int cis820x_ack_interrupt(struct gfar_mii_info *mii_info)
+{
+	phy_read(mii_info, MII_CIS8201_ISTAT);
+
+	return 0;
+}
 
-	if (mii_reg & (MIIM_DM9161_SCSR_100F | MIIM_DM9161_SCSR_10F))
-		priv->duplexity = 1;
+static int cis820x_config_intr(struct gfar_mii_info *mii_info)
+{
+	if(mii_info->interrupts == MII_INTERRUPT_ENABLED)
+		phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
 	else
-		priv->duplexity = 0;
+		phy_write(mii_info, MII_CIS8201_IMASK, 0);
 
 	return 0;
 }
 
-u16 dm9161_wait(u16 mii_reg, struct net_device *dev)
+#define DM9161_DELAY 10
+
+static int dm9161_read_status(struct gfar_mii_info *mii_info)
 {
-	int timeout = HZ;
-	int secondary = 10;
-	u16 temp;
-
-	do {
-
-		/* Davicom takes a bit to come up after a reset,
-		 * so wait here for a bit */
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(timeout);
-
-		temp = read_phy_reg(dev, MIIM_STATUS);
-
-		secondary--;
-	} while ((!(temp & MIIM_STATUS_AN_DONE)) && secondary);
-
-	return 0;
-}
-
-static struct phy_info phy_info_M88E1011S = {
-	0x01410c6,
-	"Marvell 88E1011S",
-	4,
-	(const struct phy_cmd[]) {	/* config */
-		/* Reset and configure the PHY */
-		{MIIM_CONTROL, MIIM_CONTROL_INIT, mii_cr_init},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* startup */
-		/* Status is read once to clear old link state */
-		{MIIM_STATUS, miim_read, NULL},
-		/* Auto-negotiate */
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		/* Read the status */
-		{MIIM_88E1011_PHY_STATUS, miim_read, mii_parse_88E1011_psr},
-		/* Clear the IEVENT register */
-		{MIIM_88E1011_IEVENT, miim_read, NULL},
-		/* Set up the mask */
-		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_INIT, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* ack_int */
-		/* Clear the interrupt */
-		{MIIM_88E1011_IEVENT, miim_read, NULL},
-		/* Disable interrupts */
-		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_CLEAR, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* handle_int */
-		/* Read the Status (2x to make sure link is right) */
-		{MIIM_STATUS, miim_read, NULL},
-		/* Check the status */
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		{MIIM_88E1011_PHY_STATUS, miim_read, mii_parse_88E1011_psr},
-			/* Enable Interrupts */
-		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_INIT, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* shutdown */
-		{MIIM_88E1011_IEVENT, miim_read, NULL},
-		{MIIM_88E1011_IMASK, MIIM_88E1011_IMASK_CLEAR, NULL},
-		{miim_end,}
-	},
-};
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genmii_update_link(mii_info);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds 
+	 * are as set */
+	if (mii_info->autoneg && mii_info->link) {
+		status = phy_read(mii_info, MII_DM9161_SCSR);
+		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
+			mii_info->speed = SPEED_100;
+		else
+			mii_info->speed = SPEED_10;
+
+		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_10F))
+			mii_info->duplex = DUPLEX_FULL;
+		else
+			mii_info->duplex = DUPLEX_HALF;
+	}
+
+	return 0;
+}
+
+
+static int dm9161_config_aneg(struct gfar_mii_info *mii_info)
+{
+	struct dm9161_private *priv = mii_info->priv;
+
+	if(0 == priv->resetdone)
+		return -EAGAIN;
+
+	return 0;
+}
+
+static void dm9161_timer(unsigned long data)
+{
+	struct gfar_mii_info *mii_info = (struct gfar_mii_info *)data;
+	struct dm9161_private *priv = mii_info->priv;
+	u16 status = phy_read(mii_info, MII_BMSR);
+
+	if (status & BMSR_ANEGCOMPLETE) {
+		priv->resetdone = 1;
+	} else
+		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+}
+
+static int dm9161_init(struct gfar_mii_info *mii_info)
+{
+	struct dm9161_private *priv;
+
+	/* Allocate the private data structure */
+	priv = kmalloc(sizeof(struct dm9161_private), GFP_KERNEL);
+
+	if (NULL == priv)
+		return -ENOMEM;
+
+	mii_info->priv = priv;
+
+	/* Reset is not done yet */
+	priv->resetdone = 0;
+
+	/* Isolate the PHY */
+	phy_write(mii_info, MII_BMCR, BMCR_ISOLATE);
+
+	/* Do not bypass the scrambler/descrambler */
+	phy_write(mii_info, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+
+	/* Clear 10BTCSR to default */
+	phy_write(mii_info, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT);
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	phy_write(mii_info, MII_BMCR, BMCR_ANENABLE);
+
+	/* Start a timer for DM9161_DELAY seconds to wait
+	 * for the PHY to be ready */
+	init_timer(&priv->timer);
+	priv->timer.function = &dm9161_timer;
+	priv->timer.data = (unsigned long) mii_info;
+	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+
+	return 0;
+}
+
+static void dm9161_close(struct gfar_mii_info *mii_info)
+{
+	struct dm9161_private *priv = mii_info->priv;
+
+	del_timer_sync(&priv->timer);
+	kfree(priv);
+}
+
+#if 0
+static int dm9161_ack_interrupt(struct gfar_mii_info *mii_info)
+{
+	phy_read(mii_info, MII_DM9161_INTR);
+
+	return 0;
+}
+#endif
 
-/* Cicada 8204 */
-static struct phy_info phy_info_cis8204 = {
-	0x3f11,
+/* Cicada 820x */
+static struct phy_info phy_info_cis820x = {
+	0x000fc440,
 	"Cicada Cis8204",
-	6,
-	(const struct phy_cmd[]) {	/* config */
-		/* Override PHY config settings */
-		{MIIM_CIS8201_AUX_CONSTAT, MIIM_CIS8201_AUXCONSTAT_INIT, NULL},
-		/* Set up the interface mode */
-		{MIIM_CIS8201_EXT_CON1, MIIM_CIS8201_EXTCON1_INIT, NULL},
-		/* Configure some basic stuff */
-		{MIIM_CONTROL, MIIM_CONTROL_INIT, mii_cr_init},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* startup */
-		/* Read the Status (2x to make sure link is right) */
-		{MIIM_STATUS, miim_read, NULL},
-		/* Auto-negotiate */
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		/* Read the status */
-		{MIIM_CIS8201_AUX_CONSTAT, miim_read, mii_parse_cis8201},
-		/* Clear the status register */
-		{MIIM_CIS8204_ISTAT, miim_read, NULL},
-		/* Enable interrupts */
-		{MIIM_CIS8204_IMASK, MIIM_CIS8204_IMASK_MASK, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* ack_int */
-		/* Clear the status register */
-		{MIIM_CIS8204_ISTAT, miim_read, NULL},
-		/* Disable interrupts */
-		{MIIM_CIS8204_IMASK, 0x0, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* handle_int */
-		/* Read the Status (2x to make sure link is right) */
-		{MIIM_STATUS, miim_read, NULL},
-		/* Auto-negotiate */
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		/* Read the status */
-		{MIIM_CIS8201_AUX_CONSTAT, miim_read, mii_parse_cis8201},
-		/* Enable interrupts */
-		{MIIM_CIS8204_IMASK, MIIM_CIS8204_IMASK_MASK, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* shutdown */
-		/* Clear the status register */
-		{MIIM_CIS8204_ISTAT, miim_read, NULL},
-		/* Disable interrupts */
-		{MIIM_CIS8204_IMASK, 0x0, NULL},
-		{miim_end,}
-	},
+	0x000fffc0,
+	.features	= MII_GBIT_FEATURES,
+	.init		= &cis820x_init,
+	.config_aneg	= &gbit_config_aneg,
+	.read_status	= &cis820x_read_status,
+	.ack_interrupt	= &cis820x_ack_interrupt,
+	.config_intr	= &cis820x_config_intr,
 };
 
-/* Cicada 8201 */
-static struct phy_info phy_info_cis8201 = {
-	0xfc41,
-	"CIS8201",
-	4,
-	(const struct phy_cmd[]) {	/* config */
-		/* Override PHY config settings */
-		{MIIM_CIS8201_AUX_CONSTAT, MIIM_CIS8201_AUXCONSTAT_INIT, NULL},
-		/* Set up the interface mode */
-		{MIIM_CIS8201_EXT_CON1, MIIM_CIS8201_EXTCON1_INIT, NULL},
-		/* Configure some basic stuff */
-		{MIIM_CONTROL, MIIM_CONTROL_INIT, mii_cr_init},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* startup */
-		/* Read the Status (2x to make sure link is right) */
-		{MIIM_STATUS, miim_read, NULL},
-		/* Auto-negotiate */
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		/* Read the status */
-		{MIIM_CIS8201_AUX_CONSTAT, miim_read, mii_parse_cis8201},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* ack_int */
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* handle_int */
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* shutdown */
-		{miim_end,}
-	},
+static struct phy_info phy_info_dm9161 = {
+	.phy_id		= 0x0181b880,
+	.name		= "Davicom DM9161E",
+	.phy_id_mask	= 0x0ffffff0,
+	.init		= dm9161_init,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= dm9161_read_status,
+	.close		= dm9161_close,
 };
 
-static struct phy_info phy_info_dm9161 = {
-	0x0181b88,
-	"Davicom DM9161E",
-	4,
-	(const struct phy_cmd[]) {	/* config */
-		{MIIM_CONTROL, MIIM_DM9161_CR_STOP, NULL},
-		/* Do not bypass the scrambler/descrambler */
-		{MIIM_DM9161_SCR, MIIM_DM9161_SCR_INIT, NULL},
-		/* Clear 10BTCSR to default */
-		{MIIM_DM9161_10BTCSR, MIIM_DM9161_10BTCSR_INIT, NULL},
-		/* Configure some basic stuff */
-		{MIIM_CONTROL, MIIM_CR_INIT, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* startup */
-		/* Restart Auto Negotiation */
-		{MIIM_CONTROL, MIIM_DM9161_CR_RSTAN, NULL},
-		/* Status is read once to clear old link state */
-		{MIIM_STATUS, miim_read, dm9161_wait},
-		/* Auto-negotiate */
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		/* Read the status */
-		{MIIM_DM9161_SCSR, miim_read, mii_parse_dm9161_scsr},
-		/* Clear any pending interrupts */
-		{MIIM_DM9161_INTR, miim_read, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* ack_int */
-		{MIIM_DM9161_INTR, miim_read, NULL},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* handle_int */
-		{MIIM_STATUS, miim_read, NULL},
-		{MIIM_STATUS, miim_read, mii_parse_sr},
-		{MIIM_DM9161_SCSR, miim_read, mii_parse_dm9161_scsr},
-		{miim_end,}
-	},
-	(const struct phy_cmd[]) {	/* shutdown */
-		{MIIM_DM9161_INTR, miim_read, NULL},
-		{miim_end,}
-	},
+static struct phy_info phy_info_marvell = {
+	.phy_id		= 0x01410c00,
+	.phy_id_mask	= 0xffffff00,
+	.name		= "Marvell 88E1101",
+	.features	= MII_GBIT_FEATURES,
+	.config_aneg	= &marvell_config_aneg,
+	.read_status	= &marvell_read_status,
+	.ack_interrupt	= &marvell_ack_interrupt,
+	.config_intr	= &marvell_config_intr,
+};
+
+static struct phy_info phy_info_genmii= {
+	.phy_id		= 0x00000000,
+	.phy_id_mask	= 0x00000000,
+	.name		= "Generic MII",
+	.features	= MII_BASIC_FEATURES,
+	.config_aneg	= genmii_config_aneg,
+	.read_status	= genmii_read_status,
 };
 
 static struct phy_info *phy_info[] = {
-	&phy_info_cis8201,
-	&phy_info_cis8204,
-	&phy_info_M88E1011S,
+	&phy_info_cis820x,
+	&phy_info_marvell,
 	&phy_info_dm9161,
+	&phy_info_genmii,
 	NULL
 };
 
+u16 phy_read(struct gfar_mii_info *mii_info, u16 regnum)
+{
+	return mii_info->mdio_read(mii_info->dev, mii_info->mii_id, regnum);
+}
+
+void phy_write(struct gfar_mii_info *mii_info, u16 regnum, u16 val)
+{
+	mii_info->mdio_write(mii_info->dev, 
+			mii_info->mii_id, 
+			regnum, val);
+}
+
 /* Use the PHY ID registers to determine what type of PHY is attached
  * to device dev.  return a struct phy_info structure describing that PHY
  */
-struct phy_info * get_phy_info(struct net_device *dev)
+struct phy_info * get_phy_info(struct gfar_mii_info *mii_info)
 {
 	u16 phy_reg;
 	u32 phy_ID;
 	int i;
 	struct phy_info *theInfo = NULL;
+	struct net_device *dev = mii_info->dev;
 
 	/* Grab the bits from PHYIR1, and put them in the upper half */
-	phy_reg = read_phy_reg(dev, MIIM_PHYIR1);
+	phy_reg = phy_read(mii_info, MII_PHYSID1);
 	phy_ID = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = read_phy_reg(dev, MIIM_PHYIR2);
+	phy_reg = phy_read(mii_info, MII_PHYSID2);
 	phy_ID |= (phy_reg & 0xffff);
 
 	/* loop through all the known PHY types, and find one that */
 	/* matches the ID we read from the PHY. */
 	for (i = 0; phy_info[i]; i++)
-		if (phy_info[i]->id == (phy_ID >> phy_info[i]->shift))
+		if (phy_info[i]->phy_id == 
+				(phy_ID & phy_info[i]->phy_id_mask)) {
 			theInfo = phy_info[i];
+			break;
+		}
 
+	/* This shouldn't happen, as we have generic PHY support */
 	if (theInfo == NULL) {
 		printk("%s: PHY id %x is not supported!\n", dev->name, phy_ID);
 		return NULL;
@@ -454,51 +632,4 @@
 	}
 
 	return theInfo;
-}
-
-/* Take a list of struct phy_cmd, and, depending on the values, either */
-/* read or write, using a helper function if provided */
-/* It is assumed that all lists of struct phy_cmd will be terminated by */
-/* mii_end. */
-void phy_run_commands(struct net_device *dev, const struct phy_cmd *cmd)
-{
-	int i;
-	u16 result;
-	struct gfar_private *priv = (struct gfar_private *) dev->priv;
-	struct gfar *phyregs = priv->phyregs;
-
-	/* Reset the management interface */
-	gfar_write(&phyregs->miimcfg, MIIMCFG_RESET);
-
-	/* Setup the MII Mgmt clock speed */
-	gfar_write(&phyregs->miimcfg, MIIMCFG_INIT_VALUE);
-
-	/* Wait until the bus is free */
-	while (gfar_read(&phyregs->miimind) & MIIMIND_BUSY)
-		cpu_relax();
-
-	for (i = 0; cmd->mii_reg != miim_end; i++) {
-		/* The command is a read if mii_data is miim_read */
-		if (cmd->mii_data == miim_read) {
-			/* Read the value of the PHY reg */
-			result = read_phy_reg(dev, cmd->mii_reg);
-
-			/* If a function was supplied, we need to let it process */
-			/* the result. */
-			if (cmd->funct != NULL)
-				(*(cmd->funct)) (result, dev);
-		} else {	/* Otherwise, it's a write */
-			/* If a function was supplied, it will provide 
-			 * the value to write */
-			/* Otherwise, the value was supplied in cmd->mii_data */
-			if (cmd->funct != NULL)
-				result = (*(cmd->funct)) (0, dev);
-			else
-				result = cmd->mii_data;
-
-			/* Write the appropriate value to the PHY reg */
-			write_phy_reg(dev, cmd->mii_reg, result);
-		}
-		cmd++;
-	}
 }
diff -Nru a/drivers/net/gianfar_phy.h b/drivers/net/gianfar_phy.h
--- a/drivers/net/gianfar_phy.h	Mon Jul 26 17:01:55 2004
+++ b/drivers/net/gianfar_phy.h	Mon Jul 26 17:01:55 2004
@@ -8,7 +8,7 @@
  * Author: Andy Fleming
  * Maintainer: Kumar Gala (kumar.gala@freescale.com)
  *
- * Copyright 2004 Freescale Semiconductor, Inc
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -19,135 +19,138 @@
 #ifndef __GIANFAR_PHY_H
 #define __GIANFAR_PHY_H
 
-#define miim_end ((u32)-2)
-#define miim_read ((u32)-1)
+#define MII_end ((u32)-2)
+#define MII_read ((u32)-1)
 
 #define MIIMIND_BUSY            0x00000001
 #define MIIMIND_NOTVALID        0x00000004
 
-#define MIIM_CONTROL		0x00
-#define MIIM_CONTROL_RESET	0x00008000
-#define MIIM_CONTROL_INIT	0x00001140
-#define MIIM_ANEN		0x00001000
-
-#define MIIM_CR                 0x00
-#define MIIM_CR_RST		0x00008000
-#define MIIM_CR_INIT	        0x00001000
-
-#define MIIM_STATUS		0x1
-#define MIIM_STATUS_AN_DONE	0x00000020
-#define MIIM_STATUS_LINK	0x0004
-
-#define MIIM_PHYIR1		0x2
-#define MIIM_PHYIR2		0x3
-
-#define GFAR_AN_TIMEOUT         0x000fffff
-
-#define MIIM_ANLPBPA	0x5
-#define MIIM_ANLPBPA_HALF	0x00000040
-#define MIIM_ANLPBPA_FULL	0x00000020
-
-#define MIIM_ANEX		0x6
-#define MIIM_ANEX_NP    	0x00000004
-#define MIIM_ANEX_PRX   	0x00000002
+#define GFAR_AN_TIMEOUT         2000
 
+/* 1000BT control (Marvell & BCM54xx at least) */
+#define MII_1000BASETCONTROL			0x09
+#define MII_1000BASETCONTROL_FULLDUPLEXCAP	0x0200
+#define MII_1000BASETCONTROL_HALFDUPLEXCAP	0x0100
 
 /* Cicada Extended Control Register 1 */
-#define MIIM_CIS8201_EXT_CON1           0x17
-#define MIIM_CIS8201_EXTCON1_INIT       0x0000
+#define MII_CIS8201_EXT_CON1           0x17
+#define MII_CIS8201_EXTCON1_INIT       0x0000
 
 /* Cicada Interrupt Mask Register */
-#define MIIM_CIS8204_IMASK		0x19
-#define MIIM_CIS8204_IMASK_IEN		0x8000
-#define MIIM_CIS8204_IMASK_SPEED	0x4000
-#define MIIM_CIS8204_IMASK_LINK		0x2000
-#define MIIM_CIS8204_IMASK_DUPLEX	0x1000
-#define MIIM_CIS8204_IMASK_MASK		0xf000
+#define MII_CIS8201_IMASK		0x19
+#define MII_CIS8201_IMASK_IEN		0x8000
+#define MII_CIS8201_IMASK_SPEED	0x4000
+#define MII_CIS8201_IMASK_LINK		0x2000
+#define MII_CIS8201_IMASK_DUPLEX	0x1000
+#define MII_CIS8201_IMASK_MASK		0xf000
 
 /* Cicada Interrupt Status Register */
-#define MIIM_CIS8204_ISTAT		0x1a
-#define MIIM_CIS8204_ISTAT_STATUS	0x8000
-#define MIIM_CIS8204_ISTAT_SPEED	0x4000
-#define MIIM_CIS8204_ISTAT_LINK		0x2000
-#define MIIM_CIS8204_ISTAT_DUPLEX	0x1000
+#define MII_CIS8201_ISTAT		0x1a
+#define MII_CIS8201_ISTAT_STATUS	0x8000
+#define MII_CIS8201_ISTAT_SPEED	0x4000
+#define MII_CIS8201_ISTAT_LINK		0x2000
+#define MII_CIS8201_ISTAT_DUPLEX	0x1000
 
 /* Cicada Auxiliary Control/Status Register */
-#define MIIM_CIS8201_AUX_CONSTAT        0x1c
-#define MIIM_CIS8201_AUXCONSTAT_INIT    0x0004
-#define MIIM_CIS8201_AUXCONSTAT_DUPLEX  0x0020
-#define MIIM_CIS8201_AUXCONSTAT_SPEED   0x0018
-#define MIIM_CIS8201_AUXCONSTAT_GBIT    0x0010
-#define MIIM_CIS8201_AUXCONSTAT_100     0x0008
+#define MII_CIS8201_AUX_CONSTAT        0x1c
+#define MII_CIS8201_AUXCONSTAT_INIT    0x0004
+#define MII_CIS8201_AUXCONSTAT_DUPLEX  0x0020
+#define MII_CIS8201_AUXCONSTAT_SPEED   0x0018
+#define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
+#define MII_CIS8201_AUXCONSTAT_100     0x0008
                                                                                 
 /* 88E1011 PHY Status Register */
-#define MIIM_88E1011_PHY_STATUS         0x11
-#define MIIM_88E1011_PHYSTAT_SPEED      0xc000
-#define MIIM_88E1011_PHYSTAT_GBIT       0x8000
-#define MIIM_88E1011_PHYSTAT_100        0x4000
-#define MIIM_88E1011_PHYSTAT_DUPLEX     0x2000
-#define MIIM_88E1011_PHYSTAT_LINK	0x0400
-
-#define MIIM_88E1011_IEVENT		0x13
-#define MIIM_88E1011_IEVENT_CLEAR	0x0000
-
-#define MIIM_88E1011_IMASK		0x12
-#define MIIM_88E1011_IMASK_INIT		0x6400
-#define MIIM_88E1011_IMASK_CLEAR	0x0000
-
-/* DM9161 Control register values */
-#define MIIM_DM9161_CR_STOP	0x0400
-#define MIIM_DM9161_CR_RSTAN	0x1200
+#define MII_M1011_PHY_SPEC_STATUS		0x11
+#define MII_M1011_PHY_SPEC_STATUS_1000		0x8000
+#define MII_M1011_PHY_SPEC_STATUS_100		0x4000
+#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
+#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
+#define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
+#define MII_M1011_PHY_SPEC_STATUS_LINK		0x0400
+
+#define MII_M1011_IEVENT		0x13
+#define MII_M1011_IEVENT_CLEAR		0x0000
+
+#define MII_M1011_IMASK			0x12
+#define MII_M1011_IMASK_INIT		0x6400
+#define MII_M1011_IMASK_CLEAR		0x0000
 
-#define MIIM_DM9161_SCR		0x10
-#define MIIM_DM9161_SCR_INIT	0x0610
+#define MII_DM9161_SCR		0x10
+#define MII_DM9161_SCR_INIT	0x0610
 
 /* DM9161 Specified Configuration and Status Register */
-#define MIIM_DM9161_SCSR	0x11
-#define MIIM_DM9161_SCSR_100F	0x8000
-#define MIIM_DM9161_SCSR_100H	0x4000
-#define MIIM_DM9161_SCSR_10F	0x2000
-#define MIIM_DM9161_SCSR_10H	0x1000
+#define MII_DM9161_SCSR	0x11
+#define MII_DM9161_SCSR_100F	0x8000
+#define MII_DM9161_SCSR_100H	0x4000
+#define MII_DM9161_SCSR_10F	0x2000
+#define MII_DM9161_SCSR_10H	0x1000
 
 /* DM9161 Interrupt Register */
-#define MIIM_DM9161_INTR	0x15
-#define MIIM_DM9161_INTR_PEND		0x8000
-#define MIIM_DM9161_INTR_DPLX_MASK	0x0800
-#define MIIM_DM9161_INTR_SPD_MASK	0x0400
-#define MIIM_DM9161_INTR_LINK_MASK	0x0200
-#define MIIM_DM9161_INTR_MASK		0x0100
-#define MIIM_DM9161_INTR_DPLX_CHANGE	0x0010
-#define MIIM_DM9161_INTR_SPD_CHANGE	0x0008
-#define MIIM_DM9161_INTR_LINK_CHANGE	0x0004
-#define MIIM_DM9161_INTR_INIT 		0x0000
-#define MIIM_DM9161_INTR_STOP	\
-(MIIM_DM9161_INTR_DPLX_MASK | MIIM_DM9161_INTR_SPD_MASK \
- | MIIM_DM9161_INTR_LINK_MASK | MIIM_DM9161_INTR_MASK)
+#define MII_DM9161_INTR	0x15
+#define MII_DM9161_INTR_PEND		0x8000
+#define MII_DM9161_INTR_DPLX_MASK	0x0800
+#define MII_DM9161_INTR_SPD_MASK	0x0400
+#define MII_DM9161_INTR_LINK_MASK	0x0200
+#define MII_DM9161_INTR_MASK		0x0100
+#define MII_DM9161_INTR_DPLX_CHANGE	0x0010
+#define MII_DM9161_INTR_SPD_CHANGE	0x0008
+#define MII_DM9161_INTR_LINK_CHANGE	0x0004
+#define MII_DM9161_INTR_INIT 		0x0000
+#define MII_DM9161_INTR_STOP	\
+(MII_DM9161_INTR_DPLX_MASK | MII_DM9161_INTR_SPD_MASK \
+ | MII_DM9161_INTR_LINK_MASK | MII_DM9161_INTR_MASK)
 
 /* DM9161 10BT Configuration/Status */
-#define MIIM_DM9161_10BTCSR	0x12
-#define MIIM_DM9161_10BTCSR_INIT	0x7800
+#define MII_DM9161_10BTCSR	0x12
+#define MII_DM9161_10BTCSR_INIT	0x7800
 
-
-#define MIIM_READ_COMMAND       0x00000001
-
-/*
- * struct phy_cmd:  A command for reading or writing a PHY register
- *
- * mii_reg:  The register to read or write
- *
- * mii_data:  For writes, the value to put in the register.
- * 	A value of -1 indicates this is a read.
- *
- * funct: A function pointer which is invoked for each command.
- * 	For reads, this function will be passed the value read
- *	from the PHY, and process it.
- *	For writes, the result of this function will be written
- *	to the PHY register
- */
-struct phy_cmd {
-    u32 mii_reg;
-    u32 mii_data;
-    u16 (*funct) (u16 mii_reg, struct net_device * dev);
+#define MII_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
+				 SUPPORTED_10baseT_Full | \
+				 SUPPORTED_100baseT_Half | \
+				 SUPPORTED_100baseT_Full | \
+				 SUPPORTED_Autoneg | \
+				 SUPPORTED_TP | \
+				 SUPPORTED_MII)
+
+#define MII_GBIT_FEATURES	(MII_BASIC_FEATURES | \
+				 SUPPORTED_1000baseT_Half | \
+				 SUPPORTED_1000baseT_Full)
+
+#define MII_READ_COMMAND       0x00000001
+
+#define MII_INTERRUPT_DISABLED 0x0
+#define MII_INTERRUPT_ENABLED 0x1
+/* Taken from mii_if_info and sungem_phy.h */
+struct gfar_mii_info {
+	/* Information about the PHY type */
+	/* And management functions */
+	struct phy_info *phyinfo;
+
+	/* forced speed & duplex (no autoneg)
+	 * partner speed & duplex & pause (autoneg)
+	 */
+	int speed;
+	int duplex;
+	int pause;
+
+	/* The most recently read link state */
+	int link;
+
+	/* Enabled Interrupts */
+	u32 interrupts;
+
+	u32 advertising;
+	int autoneg;
+	int mii_id;
+
+	/* private data pointer */
+	/* For use by PHYs to maintain extra state */
+	void *priv;
+
+	/* Provided by host chip */
+	struct net_device *dev;
+	int (*mdio_read) (struct net_device *dev, int mii_id, int reg);
+	void (*mdio_write) (struct net_device *dev, int mii_id, int reg, int val);
 };
 
 /* struct phy_info: a structure which defines attributes for a PHY
@@ -155,38 +158,48 @@
  * id will contain a number which represents the PHY.  During
  * startup, the driver will poll the PHY to find out what its
  * UID--as defined by registers 2 and 3--is.  The 32-bit result
- * gotten from the PHY will be shifted right by "shift" bits to
+ * gotten from the PHY will be ANDed with phy_id_mask to
  * discard any bits which may change based on revision numbers
  * unimportant to functionality
  *
- * The struct phy_cmd entries represent pointers to an arrays of
- * commands which tell the driver what to do to the PHY.
+ * There are 6 commands which take a gfar_mii_info structure.
+ * Each PHY must declare config_aneg, and read_status.
  */
 struct phy_info {
-    u32 id;
-    char *name;
-    unsigned int shift;
-    /* Called to configure the PHY, and modify the controller
-     * based on the results */
-    const struct phy_cmd *config;
-
-    /* Called when starting up the controller.  Usually sets
-     * up the interrupt for state changes */
-    const struct phy_cmd *startup;
-
-    /* Called inside the interrupt handler to acknowledge
-     * the interrupt */
-    const struct phy_cmd *ack_int;
-
-    /* Called in the bottom half to handle the interrupt */
-    const struct phy_cmd *handle_int;
-
-    /* Called when bringing down the controller.  Usually stops
-     * the interrupts from being generated */
-    const struct phy_cmd *shutdown;
+	u32 phy_id;
+	char *name;
+	unsigned int phy_id_mask;
+	u32 features;
+
+	/* Called to initialize the PHY */
+	int (*init)(struct gfar_mii_info *mii_info);
+
+	/* Called to suspend the PHY for power */
+	int (*suspend)(struct gfar_mii_info *mii_info);
+
+	/* Reconfigures autonegotiation (or disables it) */
+	int (*config_aneg)(struct gfar_mii_info *mii_info);
+
+	/* Determines the negotiated speed and duplex */
+	int (*read_status)(struct gfar_mii_info *mii_info);
+
+	/* Clears any pending interrupts */
+	int (*ack_interrupt)(struct gfar_mii_info *mii_info);
+
+	/* Enables or disables interrupts */
+	int (*config_intr)(struct gfar_mii_info *mii_info);
+
+	/* Clears up any memory if needed */
+	void (*close)(struct gfar_mii_info *mii_info);
 };
 
-struct phy_info *get_phy_info(struct net_device *dev);
-void phy_run_commands(struct net_device *dev, const struct phy_cmd *cmd);
+struct phy_info *get_phy_info(struct gfar_mii_info *mii_info);
+int read_phy_reg(struct net_device *dev, int mii_id, int regnum);
+void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value);
+
+struct dm9161_private {
+	struct timer_list timer;
+	int resetdone;
+};
 
 #endif /* GIANFAR_PHY_H */
diff -Nru a/include/linux/mii.h b/include/linux/mii.h
--- a/include/linux/mii.h	Mon Jul 26 17:01:54 2004
+++ b/include/linux/mii.h	Mon Jul 26 17:01:54 2004
@@ -33,7 +33,8 @@
 #define MII_NCONFIG         0x1c        /* Network interface config    */
 
 /* Basic mode control register. */
-#define BMCR_RESV               0x007f  /* Unused...                   */
+#define BMCR_RESV               0x003f  /* Unused...                   */
+#define BMCR_SPEED1000		0x0040  /* MSB of Speed (1000)         */
 #define BMCR_CTST               0x0080  /* Collision test              */
 #define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
 #define BMCR_ANRESTART          0x0200  /* Auto negotiation restart    */

--Apple-Mail-1-903248500--
