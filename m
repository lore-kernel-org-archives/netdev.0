From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 4/9] DM9000: Cleanup source code - remove forward declerations
Date: Mon, 16 Jun 2008 00:26:57 +0100
Message-ID: <20080615232815.340376398@fluff.org.uk>
References: <20080615232653.642837440@fluff.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54109 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756500AbYFOX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 19:28:17 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanups2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup the source code by moving the code around to avoid
having to declare the functions before they are used.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-15 23:15:39.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-15 23:28:03.000000000 +0100
@@ -152,23 +152,6 @@ static inline board_info_t *to_dm9000_bo
 	return dev->priv;
 }
 
-/* function declaration ------------------------------------- */
-static int dm9000_open(struct net_device *);
-static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
-static int dm9000_stop(struct net_device *);
-
-static void dm9000_init_dm9000(struct net_device *);
-
-static irqreturn_t dm9000_interrupt(int, void *);
-
-static int dm9000_phy_read(struct net_device *dev, int phy, int reg);
-static void dm9000_phy_write(struct net_device *dev, int phy, int reg, int v);
-
-static void dm9000_read_eeprom(board_info_t *, int addr, u8 *to);
-static void dm9000_write_eeprom(board_info_t *, int addr, u8 *dp);
-static void dm9000_rx(struct net_device *);
-static void dm9000_hash_table(struct net_device *);
-
 /* DM9000 network board routine ---------------------------- */
 
 static void
@@ -315,49 +298,129 @@ static void dm9000_schedule_poll(board_i
 		schedule_delayed_work(&db->phy_poll, HZ * 2);
 }
 
-/* Our watchdog timed out. Called by the networking layer */
-static void dm9000_timeout(struct net_device *dev)
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+}
+
+static unsigned int
+dm9000_read_locked(board_info_t *db, int reg)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
-	u8 reg_save;
 	unsigned long flags;
+	unsigned int ret;
 
-	/* Save previous register address */
-	reg_save = readb(db->io_addr);
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
+	ret = ior(db, reg);
+	spin_unlock_irqrestore(&db->lock, flags);
 
-	netif_stop_queue(dev);
-	dm9000_reset(db);
-	dm9000_init_dm9000(dev);
-	/* We can accept TX packets again */
-	dev->trans_start = jiffies;
-	netif_wake_queue(dev);
+	return ret;
+}
 
-	/* Restore previous register address */
-	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
+static int dm9000_wait_eeprom(board_info_t *db)
+{
+	unsigned int status;
+	int timeout = 8;	/* wait max 8msec */
+
+	/* The DM9000 data sheets say we should be able to
+	 * poll the ERRE bit in EPCR to wait for the EEPROM
+	 * operation. From testing several chips, this bit
+	 * does not seem to work. 
+	 *
+	 * We attempt to use the bit, but fall back to the
+	 * timeout (which is why we do not return an error
+	 * on expiry) to say that the EEPROM operation has
+	 * completed.
+	 */
+
+	while (1) {
+		status = dm9000_read_locked(db, DM9000_EPCR);
+
+		if ((status & EPCR_ERRE) == 0)
+			break;
+
+		if (timeout-- < 0) {
+			dev_dbg(db->dev, "timeout waiting EEPROM\n");
+			break;
+		}
+	}
+
+	return 0;
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
 /*
- *Used by netconsole
+ *  Read a word data from EEPROM
  */
-static void dm9000_poll_controller(struct net_device *dev)
+static void
+dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
 {
-	disable_irq(dev->irq);
-	dm9000_interrupt(dev->irq,dev);
-	enable_irq(dev->irq);
+	unsigned long flags;
+
+	if (db->flags & DM9000_PLATF_NO_EEPROM) {
+		to[0] = 0xff;
+		to[1] = 0xff;
+		return;
+	}
+
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	iow(db, DM9000_EPAR, offset);
+	iow(db, DM9000_EPCR, EPCR_ERPRR);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_wait_eeprom(db);
+
+	/* delay for at-least 150uS */
+	msleep(1);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	iow(db, DM9000_EPCR, 0x0);
+
+	to[0] = ior(db, DM9000_EPDRL);
+	to[1] = ior(db, DM9000_EPDRH);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->addr_lock);
 }
-#endif
 
-static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+/*
+ * Write a word data to SROM
+ */
+static void
+dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
 {
-	board_info_t *dm = to_dm9000_board(dev);
+	unsigned long flags;
 
-	if (!netif_running(dev))
-		return -EINVAL;
+	if (db->flags & DM9000_PLATF_NO_EEPROM)
+		return;
 
-	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+	iow(db, DM9000_EPAR, offset);
+	iow(db, DM9000_EPDRH, data[1]);
+	iow(db, DM9000_EPDRL, data[0]);
+	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_wait_eeprom(db);
+
+	mdelay(1);	/* wait at least 150uS to clear */
+
+	spin_lock_irqsave(&db->lock, flags);
+	iow(db, DM9000_EPCR, 0);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->addr_lock);
 }
 
 /* ethtool ops */
@@ -527,294 +590,78 @@ static unsigned char dm9000_type_to_char
 	return '?';
 }
 
-#define res_size(_r) (((_r)->end - (_r)->start) + 1)
-
 /*
- * Search DM9000 board, allocate space and register it
+ *  Set DM9000 multicast address
  */
-static int __devinit
-dm9000_probe(struct platform_device *pdev)
+static void
+dm9000_hash_table(struct net_device *dev)
 {
-	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
-	struct board_info *db;	/* Point a board information structure */
-	struct net_device *ndev;
-	const unsigned char *mac_src;
-	int ret = 0;
-	int iosize;
-	int i;
-	u32 id_val;
-
-	/* Init network device */
-	ndev = alloc_etherdev(sizeof (struct board_info));
-	if (!ndev) {
-		dev_err(&pdev->dev, "could not allocate device.\n");
-		return -ENOMEM;
-	}
+	board_info_t *db = (board_info_t *) dev->priv;
+	struct dev_mc_list *mcptr = dev->mc_list;
+	int mc_cnt = dev->mc_count;
+	int i, oft;
+	u32 hash_val;
+	u16 hash_table[4];
+	u8 rcr = RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
+	unsigned long flags;
 
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
-	dev_dbg(&pdev->dev, "dm9000_probe()\n");
+	spin_lock_irqsave(&db->lock, flags);
 
-	/* setup board info structure */
-	db = (struct board_info *) ndev->priv;
-	memset(db, 0, sizeof (*db));
+	for (i = 0, oft = DM9000_PAR; i < 6; i++, oft++)
+		iow(db, oft, dev->dev_addr[i]);
 
-	db->dev = &pdev->dev;
-	db->ndev = ndev;
+	/* Clear Hash Table */
+	for (i = 0; i < 4; i++)
+		hash_table[i] = 0x0;
 
-	spin_lock_init(&db->lock);
-	mutex_init(&db->addr_lock);
+	/* broadcast address */
+	hash_table[3] = 0x8000;
 
-	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
+	if (dev->flags & IFF_PROMISC)
+		rcr |= RCR_PRMSC;
 
-	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (dev->flags & IFF_ALLMULTI)
+		rcr |= RCR_ALL;
 
-	if (db->addr_res == NULL || db->data_res == NULL ||
-	    db->irq_res == NULL) {
-		dev_err(db->dev, "insufficient resources\n");
-		ret = -ENOENT;
-		goto out;
+	/* the multicast address in Hash Table : 64 bits */
+	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
+		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
-	iosize = res_size(db->addr_res);
-	db->addr_req = request_mem_region(db->addr_res->start, iosize,
-					  pdev->name);
-
-	if (db->addr_req == NULL) {
-		dev_err(db->dev, "cannot claim address reg area\n");
-		ret = -EIO;
-		goto out;
+	/* Write the hash table to MAC MD table */
+	for (i = 0, oft = DM9000_MAR; i < 4; i++) {
+		iow(db, oft++, hash_table[i]);
+		iow(db, oft++, hash_table[i] >> 8);
 	}
 
-	db->io_addr = ioremap(db->addr_res->start, iosize);
+	iow(db, DM9000_RCR, rcr);
+	spin_unlock_irqrestore(&db->lock, flags);
+}
 
-	if (db->io_addr == NULL) {
-		dev_err(db->dev, "failed to ioremap address reg\n");
-		ret = -EINVAL;
-		goto out;
-	}
+/*
+ * Initilize dm9000 board
+ */
+static void
+dm9000_init_dm9000(struct net_device *dev)
+{
+	board_info_t *db = dev->priv;
+	unsigned int imr;
 
-	iosize = res_size(db->data_res);
-	db->data_req = request_mem_region(db->data_res->start, iosize,
-					  pdev->name);
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
-	if (db->data_req == NULL) {
-		dev_err(db->dev, "cannot claim data reg area\n");
-		ret = -EIO;
-		goto out;
-	}
+	/* I/O mode */
+	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
 
-	db->io_data = ioremap(db->data_res->start, iosize);
+	/* GPIO0 on pre-activate PHY */
+	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
+	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
+	iow(db, DM9000_GPR, 0);	/* Enable PHY */
 
-	if (db->io_data == NULL) {
-		dev_err(db->dev,"failed to ioremap data reg\n");
-		ret = -EINVAL;
-		goto out;
-	}
-
-	/* fill in parameters for net-dev structure */
-	ndev->base_addr = (unsigned long)db->io_addr;
-	ndev->irq	= db->irq_res->start;
-
-	/* ensure at least we have a default set of IO routines */
-	dm9000_set_io(db, iosize);
-
-	/* check to see if anything is being over-ridden */
-	if (pdata != NULL) {
-		/* check to see if the driver wants to over-ride the
-		 * default IO width */
-
-		if (pdata->flags & DM9000_PLATF_8BITONLY)
-			dm9000_set_io(db, 1);
-
-		if (pdata->flags & DM9000_PLATF_16BITONLY)
-			dm9000_set_io(db, 2);
-
-		if (pdata->flags & DM9000_PLATF_32BITONLY)
-			dm9000_set_io(db, 4);
-
-		/* check to see if there are any IO routine
-		 * over-rides */
-
-		if (pdata->inblk != NULL)
-			db->inblk = pdata->inblk;
-
-		if (pdata->outblk != NULL)
-			db->outblk = pdata->outblk;
-
-		if (pdata->dumpblk != NULL)
-			db->dumpblk = pdata->dumpblk;
-
-		db->flags = pdata->flags;
-	}
-
-	dm9000_reset(db);
-
-	/* try multiple times, DM9000 sometimes gets the read wrong */
-	for (i = 0; i < 8; i++) {
-		id_val  = ior(db, DM9000_VIDL);
-		id_val |= (u32)ior(db, DM9000_VIDH) << 8;
-		id_val |= (u32)ior(db, DM9000_PIDL) << 16;
-		id_val |= (u32)ior(db, DM9000_PIDH) << 24;
-
-		if (id_val == DM9000_ID)
-			break;
-		dev_err(db->dev, "read wrong id 0x%08x\n", id_val);
-	}
-
-	if (id_val != DM9000_ID) {
-		dev_err(db->dev, "wrong id: 0x%08x\n", id_val);
-		ret = -ENODEV;
-		goto out;
-	}
-
-	/* Identify what type of DM9000 we are working on */
-
-	id_val = ior(db, DM9000_CHIPR);
-	dev_dbg(db->dev, "dm9000 revision 0x%02x\n", id_val);
-
-	switch (id_val) {
-	case CHIPR_DM9000A:
-		db->type = TYPE_DM9000A;
-		break;
-	case CHIPR_DM9000B:
-		db->type = TYPE_DM9000B;
-		break;
-	default:
-		dev_dbg(db->dev, "ID %02x => defaulting to DM9000E\n", id_val);
-		db->type = TYPE_DM9000E;
-	}
-
-	/* from this point we assume that we have found a DM9000 */
-
-	/* driver system function */
-	ether_setup(ndev);
-
-	ndev->open		 = &dm9000_open;
-	ndev->hard_start_xmit    = &dm9000_start_xmit;
-	ndev->tx_timeout         = &dm9000_timeout;
-	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	ndev->stop		 = &dm9000_stop;
-	ndev->set_multicast_list = &dm9000_hash_table;
-	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
-	ndev->do_ioctl		 = &dm9000_ioctl;
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller	 = &dm9000_poll_controller;
-#endif
-
-	db->msg_enable       = NETIF_MSG_LINK;
-	db->mii.phy_id_mask  = 0x1f;
-	db->mii.reg_num_mask = 0x1f;
-	db->mii.force_media  = 0;
-	db->mii.full_duplex  = 0;
-	db->mii.dev	     = ndev;
-	db->mii.mdio_read    = dm9000_phy_read;
-	db->mii.mdio_write   = dm9000_phy_write;
-
-	mac_src = "eeprom";
-
-	/* try reading the node address from the attached EEPROM */
-	for (i = 0; i < 6; i += 2)
-		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
-
-	if (!is_valid_ether_addr(ndev->dev_addr)) {
-		/* try reading from mac */
-		
-		mac_src = "chip";
-		for (i = 0; i < 6; i++)
-			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
-	}
-
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
-			 "set using ifconfig\n", ndev->name);
-
-	platform_set_drvdata(pdev, ndev);
-	ret = register_netdev(ndev);
-
-	if (ret == 0) {
-		DECLARE_MAC_BUF(mac);
-		printk("%s: dm9000%c at %p,%p IRQ %d MAC: %s (%s)\n",
-		       ndev->name, dm9000_type_to_char(db->type),
-		       db->io_addr, db->io_data, ndev->irq,
-		       print_mac(mac, ndev->dev_addr), mac_src);
-	}
-	return 0;
-
-out:
-	dev_err(db->dev, "not found (%d).\n", ret);
-
-	dm9000_release_board(pdev, db);
-	free_netdev(ndev);
-
-	return ret;
-}
-
-/*
- *  Open the interface.
- *  The interface is opened whenever "ifconfig" actives it.
- */
-static int
-dm9000_open(struct net_device *dev)
-{
-	board_info_t *db = dev->priv;
-	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
-
-	if (netif_msg_ifup(db))
-		dev_dbg(db->dev, "enabling %s\n", dev->name);
-
-	/* If there is no IRQ type specified, default to something that
-	 * may work, and tell the user that this is a problem */
-
-	if (irqflags == IRQF_TRIGGER_NONE) {
-		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
-		irqflags = DEFAULT_TRIGGER;
-	}
-	
-	irqflags |= IRQF_SHARED;
-
-	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
-		return -EAGAIN;
-
-	/* Initialize DM9000 board */
-	dm9000_reset(db);
-	dm9000_init_dm9000(dev);
-
-	/* Init driver variable */
-	db->dbug_cnt = 0;
-
-	mii_check_media(&db->mii, netif_msg_link(db), 1);
-	netif_start_queue(dev);
-	
-	dm9000_schedule_poll(db);
-
-	return 0;
-}
-
-/*
- * Initilize dm9000 board
- */
-static void
-dm9000_init_dm9000(struct net_device *dev)
-{
-	board_info_t *db = dev->priv;
-	unsigned int imr;
-
-	dm9000_dbg(db, 1, "entering %s\n", __func__);
-
-	/* I/O mode */
-	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
-
-	/* GPIO0 on pre-activate PHY */
-	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
-	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
-	iow(db, DM9000_GPR, 0);	/* Enable PHY */
-
-	if (db->flags & DM9000_PLATF_EXT_PHY)
-		iow(db, DM9000_NCR, NCR_EXT_PHY);
+	if (db->flags & DM9000_PLATF_EXT_PHY)
+		iow(db, DM9000_NCR, NCR_EXT_PHY);
 
 	/* Program operating register */
 	iow(db, DM9000_TCR, 0);	        /* TX Polling clear */
@@ -843,6 +690,29 @@ dm9000_init_dm9000(struct net_device *de
 	dev->trans_start = 0;
 }
 
+/* Our watchdog timed out. Called by the networking layer */
+static void dm9000_timeout(struct net_device *dev)
+{
+	board_info_t *db = (board_info_t *) dev->priv;
+	u8 reg_save;
+	unsigned long flags;
+
+	/* Save previous register address */
+	reg_save = readb(db->io_addr);
+	spin_lock_irqsave(&db->lock,flags);
+
+	netif_stop_queue(dev);
+	dm9000_reset(db);
+	dm9000_init_dm9000(dev);
+	/* We can accept TX packets again */
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+
+	/* Restore previous register address */
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock,flags);
+}
+
 /*
  *  Hardware start transmission.
  *  Send a packet to media from the upper layer.
@@ -891,60 +761,23 @@ dm9000_start_xmit(struct sk_buff *skb, s
 	return 0;
 }
 
-static void
-dm9000_shutdown(struct net_device *dev)
-{
-	board_info_t *db = dev->priv;
-
-	/* RESET device */
-	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
-	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
-	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
-	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
-}
-
 /*
- * Stop the interface.
- * The interface is stopped when it is brought.
+ * DM9000 interrupt handler
+ * receive the packet to upper layer, free the transmitted packet
  */
-static int
-dm9000_stop(struct net_device *ndev)
+
+static void
+dm9000_tx_done(struct net_device *dev, board_info_t * db)
 {
-	board_info_t *db = ndev->priv;
+	int tx_status = ior(db, DM9000_NSR);	/* Got TX status */
 
-	if (netif_msg_ifdown(db))
-		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
+	if (tx_status & (NSR_TX2END | NSR_TX1END)) {
+		/* One packet sent complete */
+		db->tx_pkt_cnt--;
+		dev->stats.tx_packets++;
 
-	cancel_delayed_work_sync(&db->phy_poll);
-
-	netif_stop_queue(ndev);
-	netif_carrier_off(ndev);
-
-	/* free interrupt */
-	free_irq(ndev->irq, ndev);
-
-	dm9000_shutdown(ndev);
-
-	return 0;
-}
-
-/*
- * DM9000 interrupt handler
- * receive the packet to upper layer, free the transmitted packet
- */
-
-static void
-dm9000_tx_done(struct net_device *dev, board_info_t * db)
-{
-	int tx_status = ior(db, DM9000_NSR);	/* Got TX status */
-
-	if (tx_status & (NSR_TX2END | NSR_TX1END)) {
-		/* One packet sent complete */
-		db->tx_pkt_cnt--;
-		dev->stats.tx_packets++;
-
-		if (netif_msg_tx_done(db))
-			dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
+		if (netif_msg_tx_done(db))
+			dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
 
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
@@ -957,59 +790,6 @@ dm9000_tx_done(struct net_device *dev, b
 	}
 }
 
-static irqreturn_t
-dm9000_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	board_info_t *db = dev->priv;
-	int int_status;
-	u8 reg_save;
-
-	dm9000_dbg(db, 3, "entering %s\n", __func__);
-
-	/* A real interrupt coming */
-
-	spin_lock(&db->lock);
-
-	/* Save previous register address */
-	reg_save = readb(db->io_addr);
-
-	/* Disable all interrupts */
-	iow(db, DM9000_IMR, IMR_PAR);
-
-	/* Got DM9000 interrupt status */
-	int_status = ior(db, DM9000_ISR);	/* Got ISR */
-	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
-
-	if (netif_msg_intr(db))
-		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
-
-	/* Received the coming packet */
-	if (int_status & ISR_PRS)
-		dm9000_rx(dev);
-
-	/* Trnasmit Interrupt check */
-	if (int_status & ISR_PTS)
-		dm9000_tx_done(dev, db);
-
-	if (db->type != TYPE_DM9000E) {
-		if (int_status & ISR_LNKCHNG) {
-			/* fire a link-change request */
-			schedule_delayed_work(&db->phy_poll, 1);
-		}
-	}
-
-	/* Re-enable interrupt mask */
-	iow(db, DM9000_IMR, db->imr_all);
-
-	/* Restore previous register address */
-	writeb(reg_save, db->io_addr);
-
-	spin_unlock(&db->lock);
-
-	return IRQ_HANDLED;
-}
-
 struct dm9000_rxhdr {
 	u8	RxPktReady;
 	u8	RxStatus;
@@ -1113,205 +893,144 @@ dm9000_rx(struct net_device *dev)
 	} while (rxbyte == DM9000_PKT_RDY);
 }
 
-static unsigned int
-dm9000_read_locked(board_info_t *db, int reg)
+static irqreturn_t
+dm9000_interrupt(int irq, void *dev_id)
 {
-	unsigned long flags;
-	unsigned int ret;
+	struct net_device *dev = dev_id;
+	board_info_t *db = dev->priv;
+	int int_status;
+	u8 reg_save;
 
-	spin_lock_irqsave(&db->lock, flags);
-	ret = ior(db, reg);
-	spin_unlock_irqrestore(&db->lock, flags);
+	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
-	return ret;
-}
+	/* A real interrupt coming */
 
-static int dm9000_wait_eeprom(board_info_t *db)
-{
-	unsigned int status;
-	int timeout = 8;	/* wait max 8msec */
+	spin_lock(&db->lock);
 
-	/* The DM9000 data sheets say we should be able to
-	 * poll the ERRE bit in EPCR to wait for the EEPROM
-	 * operation. From testing several chips, this bit
-	 * does not seem to work. 
-	 *
-	 * We attempt to use the bit, but fall back to the
-	 * timeout (which is why we do not return an error
-	 * on expiry) to say that the EEPROM operation has
-	 * completed.
-	 */
+	/* Save previous register address */
+	reg_save = readb(db->io_addr);
 
-	while (1) {
-		status = dm9000_read_locked(db, DM9000_EPCR);
+	/* Disable all interrupts */
+	iow(db, DM9000_IMR, IMR_PAR);
 
-		if ((status & EPCR_ERRE) == 0)
-			break;
+	/* Got DM9000 interrupt status */
+	int_status = ior(db, DM9000_ISR);	/* Got ISR */
+	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
 
-		if (timeout-- < 0) {
-			dev_dbg(db->dev, "timeout waiting EEPROM\n");
-			break;
+	if (netif_msg_intr(db))
+		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
+
+	/* Received the coming packet */
+	if (int_status & ISR_PRS)
+		dm9000_rx(dev);
+
+	/* Trnasmit Interrupt check */
+	if (int_status & ISR_PTS)
+		dm9000_tx_done(dev, db);
+
+	if (db->type != TYPE_DM9000E) {
+		if (int_status & ISR_LNKCHNG) {
+			/* fire a link-change request */
+			schedule_delayed_work(&db->phy_poll, 1);
 		}
 	}
 
-	return 0;
+	/* Re-enable interrupt mask */
+	iow(db, DM9000_IMR, db->imr_all);
+
+	/* Restore previous register address */
+	writeb(reg_save, db->io_addr);
+
+	spin_unlock(&db->lock);
+
+	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
 /*
- *  Read a word data from EEPROM
+ *Used by netconsole
  */
-static void
-dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
+static void dm9000_poll_controller(struct net_device *dev)
 {
-	unsigned long flags;
-
-	if (db->flags & DM9000_PLATF_NO_EEPROM) {
-		to[0] = 0xff;
-		to[1] = 0xff;
-		return;
-	}
-
-	mutex_lock(&db->addr_lock);
+	disable_irq(dev->irq);
+	dm9000_interrupt(dev->irq,dev);
+	enable_irq(dev->irq);
+}
+#endif
 
-	spin_lock_irqsave(&db->lock, flags);
+/*
+ *  Open the interface.
+ *  The interface is opened whenever "ifconfig" actives it.
+ */
+static int
+dm9000_open(struct net_device *dev)
+{
+	board_info_t *db = dev->priv;
+	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
-	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPCR, EPCR_ERPRR);
+	if (netif_msg_ifup(db))
+		dev_dbg(db->dev, "enabling %s\n", dev->name);
 
-	spin_unlock_irqrestore(&db->lock, flags);
+	/* If there is no IRQ type specified, default to something that
+	 * may work, and tell the user that this is a problem */
 
-	dm9000_wait_eeprom(db);
+	if (irqflags == IRQF_TRIGGER_NONE) {
+		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
+		irqflags = DEFAULT_TRIGGER;
+	}
+	
+	irqflags |= IRQF_SHARED;
 
-	/* delay for at-least 150uS */
-	msleep(1);
+	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
+		return -EAGAIN;
 
-	spin_lock_irqsave(&db->lock, flags);
+	/* Initialize DM9000 board */
+	dm9000_reset(db);
+	dm9000_init_dm9000(dev);
 
-	iow(db, DM9000_EPCR, 0x0);
+	/* Init driver variable */
+	db->dbug_cnt = 0;
 
-	to[0] = ior(db, DM9000_EPDRL);
-	to[1] = ior(db, DM9000_EPDRH);
+	mii_check_media(&db->mii, netif_msg_link(db), 1);
+	netif_start_queue(dev);
+	
+	dm9000_schedule_poll(db);
 
-	spin_unlock_irqrestore(&db->lock, flags);
+	return 0;
+}
 
-	mutex_unlock(&db->addr_lock);
+/*
+ * Sleep, either by using msleep() or if we are suspending, then
+ * use mdelay() to sleep.
+ */
+static void dm9000_msleep(board_info_t *db, unsigned int ms)
+{
+	if (db->in_suspend)
+		mdelay(ms);
+	else
+		msleep(ms);
 }
 
 /*
- * Write a word data to SROM
+ *   Read a word from phyxcer
  */
-static void
-dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
+static int
+dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 {
+	board_info_t *db = (board_info_t *) dev->priv;
 	unsigned long flags;
-
-	if (db->flags & DM9000_PLATF_NO_EEPROM)
-		return;
+	unsigned int reg_save;
+	int ret;
 
 	mutex_lock(&db->addr_lock);
 
-	spin_lock_irqsave(&db->lock, flags);
-	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPDRH, data[1]);
-	iow(db, DM9000_EPDRL, data[0]);
-	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
-	spin_unlock_irqrestore(&db->lock, flags);
+	spin_lock_irqsave(&db->lock,flags);
 
-	dm9000_wait_eeprom(db);
+	/* Save previous register address */
+	reg_save = readb(db->io_addr);
 
-	mdelay(1);	/* wait at least 150uS to clear */
-
-	spin_lock_irqsave(&db->lock, flags);
-	iow(db, DM9000_EPCR, 0);
-	spin_unlock_irqrestore(&db->lock, flags);
-
-	mutex_unlock(&db->addr_lock);
-}
-
-/*
- *  Set DM9000 multicast address
- */
-static void
-dm9000_hash_table(struct net_device *dev)
-{
-	board_info_t *db = (board_info_t *) dev->priv;
-	struct dev_mc_list *mcptr = dev->mc_list;
-	int mc_cnt = dev->mc_count;
-	int i, oft;
-	u32 hash_val;
-	u16 hash_table[4];
-	u8 rcr = RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
-	unsigned long flags;
-
-	dm9000_dbg(db, 1, "entering %s\n", __func__);
-
-	spin_lock_irqsave(&db->lock, flags);
-
-	for (i = 0, oft = DM9000_PAR; i < 6; i++, oft++)
-		iow(db, oft, dev->dev_addr[i]);
-
-	/* Clear Hash Table */
-	for (i = 0; i < 4; i++)
-		hash_table[i] = 0x0;
-
-	/* broadcast address */
-	hash_table[3] = 0x8000;
-
-	if (dev->flags & IFF_PROMISC)
-		rcr |= RCR_PRMSC;
-
-	if (dev->flags & IFF_ALLMULTI)
-		rcr |= RCR_ALL;
-
-	/* the multicast address in Hash Table : 64 bits */
-	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
-		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
-		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
-	}
-
-	/* Write the hash table to MAC MD table */
-	for (i = 0, oft = DM9000_MAR; i < 4; i++) {
-		iow(db, oft++, hash_table[i]);
-		iow(db, oft++, hash_table[i] >> 8);
-	}
-
-	iow(db, DM9000_RCR, rcr);
-	spin_unlock_irqrestore(&db->lock, flags);
-}
-
-
-/*
- * Sleep, either by using msleep() or if we are suspending, then
- * use mdelay() to sleep.
- */
-static void dm9000_msleep(board_info_t *db, unsigned int ms)
-{
-	if (db->in_suspend)
-		mdelay(ms);
-	else
-		msleep(ms);
-}
-
-/*
- *   Read a word from phyxcer
- */
-static int
-dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
-{
-	board_info_t *db = (board_info_t *) dev->priv;
-	unsigned long flags;
-	unsigned int reg_save;
-	int ret;
-
-	mutex_lock(&db->addr_lock);
-
-	spin_lock_irqsave(&db->lock,flags);
-
-	/* Save previous register address */
-	reg_save = readb(db->io_addr);
-
-	/* Fill the phyxcer register into REG_0C */
-	iow(db, DM9000_EPAR, DM9000_PHY | reg);
+	/* Fill the phyxcer register into REG_0C */
+	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
 	iow(db, DM9000_EPCR, 0xc);	/* Issue phyxcer read command */
 
@@ -1383,6 +1102,269 @@ dm9000_phy_write(struct net_device *dev,
 	mutex_unlock(&db->addr_lock);
 }
 
+static void
+dm9000_shutdown(struct net_device *dev)
+{
+	board_info_t *db = dev->priv;
+
+	/* RESET device */
+	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
+	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
+	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
+	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
+}
+
+/*
+ * Stop the interface.
+ * The interface is stopped when it is brought.
+ */
+static int
+dm9000_stop(struct net_device *ndev)
+{
+	board_info_t *db = ndev->priv;
+
+	if (netif_msg_ifdown(db))
+		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
+
+	cancel_delayed_work_sync(&db->phy_poll);
+
+	netif_stop_queue(ndev);
+	netif_carrier_off(ndev);
+
+	/* free interrupt */
+	free_irq(ndev->irq, ndev);
+
+	dm9000_shutdown(ndev);
+
+	return 0;
+}
+
+#define res_size(_r) (((_r)->end - (_r)->start) + 1)
+
+/*
+ * Search DM9000 board, allocate space and register it
+ */
+static int __devinit
+dm9000_probe(struct platform_device *pdev)
+{
+	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
+	struct board_info *db;	/* Point a board information structure */
+	struct net_device *ndev;
+	const unsigned char *mac_src;
+	int ret = 0;
+	int iosize;
+	int i;
+	u32 id_val;
+
+	/* Init network device */
+	ndev = alloc_etherdev(sizeof (struct board_info));
+	if (!ndev) {
+		dev_err(&pdev->dev, "could not allocate device.\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	dev_dbg(&pdev->dev, "dm9000_probe()\n");
+
+	/* setup board info structure */
+	db = (struct board_info *) ndev->priv;
+	memset(db, 0, sizeof (*db));
+
+	db->dev = &pdev->dev;
+	db->ndev = ndev;
+
+	spin_lock_init(&db->lock);
+	mutex_init(&db->addr_lock);
+
+	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
+
+	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+
+	if (db->addr_res == NULL || db->data_res == NULL ||
+	    db->irq_res == NULL) {
+		dev_err(db->dev, "insufficient resources\n");
+		ret = -ENOENT;
+		goto out;
+	}
+
+	iosize = res_size(db->addr_res);
+	db->addr_req = request_mem_region(db->addr_res->start, iosize,
+					  pdev->name);
+
+	if (db->addr_req == NULL) {
+		dev_err(db->dev, "cannot claim address reg area\n");
+		ret = -EIO;
+		goto out;
+	}
+
+	db->io_addr = ioremap(db->addr_res->start, iosize);
+
+	if (db->io_addr == NULL) {
+		dev_err(db->dev, "failed to ioremap address reg\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	iosize = res_size(db->data_res);
+	db->data_req = request_mem_region(db->data_res->start, iosize,
+					  pdev->name);
+
+	if (db->data_req == NULL) {
+		dev_err(db->dev, "cannot claim data reg area\n");
+		ret = -EIO;
+		goto out;
+	}
+
+	db->io_data = ioremap(db->data_res->start, iosize);
+
+	if (db->io_data == NULL) {
+		dev_err(db->dev,"failed to ioremap data reg\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* fill in parameters for net-dev structure */
+	ndev->base_addr = (unsigned long)db->io_addr;
+	ndev->irq	= db->irq_res->start;
+
+	/* ensure at least we have a default set of IO routines */
+	dm9000_set_io(db, iosize);
+
+	/* check to see if anything is being over-ridden */
+	if (pdata != NULL) {
+		/* check to see if the driver wants to over-ride the
+		 * default IO width */
+
+		if (pdata->flags & DM9000_PLATF_8BITONLY)
+			dm9000_set_io(db, 1);
+
+		if (pdata->flags & DM9000_PLATF_16BITONLY)
+			dm9000_set_io(db, 2);
+
+		if (pdata->flags & DM9000_PLATF_32BITONLY)
+			dm9000_set_io(db, 4);
+
+		/* check to see if there are any IO routine
+		 * over-rides */
+
+		if (pdata->inblk != NULL)
+			db->inblk = pdata->inblk;
+
+		if (pdata->outblk != NULL)
+			db->outblk = pdata->outblk;
+
+		if (pdata->dumpblk != NULL)
+			db->dumpblk = pdata->dumpblk;
+
+		db->flags = pdata->flags;
+	}
+
+	dm9000_reset(db);
+
+	/* try multiple times, DM9000 sometimes gets the read wrong */
+	for (i = 0; i < 8; i++) {
+		id_val  = ior(db, DM9000_VIDL);
+		id_val |= (u32)ior(db, DM9000_VIDH) << 8;
+		id_val |= (u32)ior(db, DM9000_PIDL) << 16;
+		id_val |= (u32)ior(db, DM9000_PIDH) << 24;
+
+		if (id_val == DM9000_ID)
+			break;
+		dev_err(db->dev, "read wrong id 0x%08x\n", id_val);
+	}
+
+	if (id_val != DM9000_ID) {
+		dev_err(db->dev, "wrong id: 0x%08x\n", id_val);
+		ret = -ENODEV;
+		goto out;
+	}
+
+	/* Identify what type of DM9000 we are working on */
+
+	id_val = ior(db, DM9000_CHIPR);
+	dev_dbg(db->dev, "dm9000 revision 0x%02x\n", id_val);
+
+	switch (id_val) {
+	case CHIPR_DM9000A:
+		db->type = TYPE_DM9000A;
+		break;
+	case CHIPR_DM9000B:
+		db->type = TYPE_DM9000B;
+		break;
+	default:
+		dev_dbg(db->dev, "ID %02x => defaulting to DM9000E\n", id_val);
+		db->type = TYPE_DM9000E;
+	}
+
+	/* from this point we assume that we have found a DM9000 */
+
+	/* driver system function */
+	ether_setup(ndev);
+
+	ndev->open		 = &dm9000_open;
+	ndev->hard_start_xmit    = &dm9000_start_xmit;
+	ndev->tx_timeout         = &dm9000_timeout;
+	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
+	ndev->stop		 = &dm9000_stop;
+	ndev->set_multicast_list = &dm9000_hash_table;
+	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
+	ndev->do_ioctl		 = &dm9000_ioctl;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller	 = &dm9000_poll_controller;
+#endif
+
+	db->msg_enable       = NETIF_MSG_LINK;
+	db->mii.phy_id_mask  = 0x1f;
+	db->mii.reg_num_mask = 0x1f;
+	db->mii.force_media  = 0;
+	db->mii.full_duplex  = 0;
+	db->mii.dev	     = ndev;
+	db->mii.mdio_read    = dm9000_phy_read;
+	db->mii.mdio_write   = dm9000_phy_write;
+
+	mac_src = "eeprom";
+
+	/* try reading the node address from the attached EEPROM */
+	for (i = 0; i < 6; i += 2)
+		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
+
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		/* try reading from mac */
+		
+		mac_src = "chip";
+		for (i = 0; i < 6; i++)
+			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
+	}
+
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
+			 "set using ifconfig\n", ndev->name);
+
+	platform_set_drvdata(pdev, ndev);
+	ret = register_netdev(ndev);
+
+	if (ret == 0) {
+		DECLARE_MAC_BUF(mac);
+		printk("%s: dm9000%c at %p,%p IRQ %d MAC: %s (%s)\n",
+		       ndev->name, dm9000_type_to_char(db->type),
+		       db->io_addr, db->io_data, ndev->irq,
+		       print_mac(mac, ndev->dev_addr), mac_src);
+	}
+	return 0;
+
+out:
+	dev_err(db->dev, "not found (%d).\n", ret);
+
+	dm9000_release_board(pdev, db);
+	free_netdev(ndev);
+
+	return ret;
+}
+
 static int
 dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
 {

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
