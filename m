From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] au1000: reorder functions
Date: Thu, 22 Jan 2009 12:04:51 +0100
Message-ID: <200901221204.51393.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	Manuel Lauss <mano@roarinelk.homelinux.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:36154 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbZAVLFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 06:05:11 -0500
Received: by ik-out-1112.google.com with SMTP id c28so248800ika.5
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 03:05:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is a resent rebased on net-next-2.6. Thanks !
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] au1000: reorder functions

This patch reorders functions so that we do longer need
forward declarations.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 9c875bb..2180376 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -81,24 +81,6 @@ MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_LICENSE("GPL");
 
-// prototypes
-static void hard_stop(struct net_device *);
-static void enable_rx_tx(struct net_device *dev);
-static struct net_device * au1000_probe(int port_num);
-static int au1000_init(struct net_device *);
-static int au1000_open(struct net_device *);
-static int au1000_close(struct net_device *);
-static int au1000_tx(struct sk_buff *, struct net_device *);
-static int au1000_rx(struct net_device *);
-static irqreturn_t au1000_interrupt(int, void *);
-static void au1000_tx_timeout(struct net_device *);
-static void set_rx_mode(struct net_device *);
-static int au1000_ioctl(struct net_device *, struct ifreq *, int);
-static int au1000_mdio_read(struct net_device *, int, int);
-static void au1000_mdio_write(struct net_device *, int, int, u16);
-static void au1000_adjust_link(struct net_device *);
-static void enable_mac(struct net_device *, int);
-
 /*
  * Theory of operation
  *
@@ -188,6 +170,26 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
 # error MAC0-associated PHY attached 2nd MACs MII bus not supported yet
 #endif
 
+static void enable_mac(struct net_device *dev, int force_reset)
+{
+	unsigned long flags;
+	struct au1000_private *aup = netdev_priv(dev);
+
+	spin_lock_irqsave(&aup->lock, flags);
+
+	if(force_reset || (!aup->mac_enabled)) {
+		*aup->enable = MAC_EN_CLOCK_ENABLE;
+		au_sync_delay(2);
+		*aup->enable = (MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
+				| MAC_EN_CLOCK_ENABLE);
+		au_sync_delay(2);
+
+		aup->mac_enabled = 1;
+	}
+
+	spin_unlock_irqrestore(&aup->lock, flags);
+}
+
 /*
  * MII operations
  */
@@ -281,6 +283,107 @@ static int au1000_mdiobus_reset(struct mii_bus *bus)
 	return 0;
 }
 
+static void hard_stop(struct net_device *dev)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+
+	if (au1000_debug > 4)
+		printk(KERN_INFO "%s: hard stop\n", dev->name);
+
+	aup->mac->control &= ~(MAC_RX_ENABLE | MAC_TX_ENABLE);
+	au_sync_delay(10);
+}
+
+static void enable_rx_tx(struct net_device *dev)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+
+	if (au1000_debug > 4)
+		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
+
+	aup->mac->control |= (MAC_RX_ENABLE | MAC_TX_ENABLE);
+	au_sync_delay(10);
+}
+
+static void
+au1000_adjust_link(struct net_device *dev)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+	struct phy_device *phydev = aup->phy_dev;
+	unsigned long flags;
+
+	int status_change = 0;
+
+	BUG_ON(!aup->phy_dev);
+
+	spin_lock_irqsave(&aup->lock, flags);
+
+	if (phydev->link && (aup->old_speed != phydev->speed)) {
+		// speed changed
+
+		switch(phydev->speed) {
+		case SPEED_10:
+		case SPEED_100:
+			break;
+		default:
+			printk(KERN_WARNING
+			       "%s: Speed (%d) is not 10/100 ???\n",
+			       dev->name, phydev->speed);
+			break;
+		}
+
+		aup->old_speed = phydev->speed;
+
+		status_change = 1;
+	}
+
+	if (phydev->link && (aup->old_duplex != phydev->duplex)) {
+		// duplex mode changed
+
+		/* switching duplex mode requires to disable rx and tx! */
+		hard_stop(dev);
+
+		if (DUPLEX_FULL == phydev->duplex)
+			aup->mac->control = ((aup->mac->control
+					     | MAC_FULL_DUPLEX)
+					     & ~MAC_DISABLE_RX_OWN);
+		else
+			aup->mac->control = ((aup->mac->control
+					      & ~MAC_FULL_DUPLEX)
+					     | MAC_DISABLE_RX_OWN);
+		au_sync_delay(1);
+
+		enable_rx_tx(dev);
+		aup->old_duplex = phydev->duplex;
+
+		status_change = 1;
+	}
+
+	if(phydev->link != aup->old_link) {
+		// link state changed
+
+		if (!phydev->link) {
+			/* link went down */
+			aup->old_speed = 0;
+			aup->old_duplex = -1;
+		}
+
+		aup->old_link = phydev->link;
+		status_change = 1;
+	}
+
+	spin_unlock_irqrestore(&aup->lock, flags);
+
+	if (status_change) {
+		if (phydev->link)
+			printk(KERN_INFO "%s: link up (%d/%s)\n",
+			       dev->name, phydev->speed,
+			       DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
+		else
+			printk(KERN_INFO "%s: link down\n", dev->name);
+	}
+}
+
 static int mii_probe (struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
@@ -412,48 +515,6 @@ void ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
 	aup->pDBfree = pDB;
 }
 
-static void enable_rx_tx(struct net_device *dev)
-{
-	struct au1000_private *aup = netdev_priv(dev);
-
-	if (au1000_debug > 4)
-		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
-
-	aup->mac->control |= (MAC_RX_ENABLE | MAC_TX_ENABLE);
-	au_sync_delay(10);
-}
-
-static void hard_stop(struct net_device *dev)
-{
-	struct au1000_private *aup = netdev_priv(dev);
-
-	if (au1000_debug > 4)
-		printk(KERN_INFO "%s: hard stop\n", dev->name);
-
-	aup->mac->control &= ~(MAC_RX_ENABLE | MAC_TX_ENABLE);
-	au_sync_delay(10);
-}
-
-static void enable_mac(struct net_device *dev, int force_reset)
-{
-	unsigned long flags;
-	struct au1000_private *aup = netdev_priv(dev);
-
-	spin_lock_irqsave(&aup->lock, flags);
-
-	if(force_reset || (!aup->mac_enabled)) {
-		*aup->enable = MAC_EN_CLOCK_ENABLE;
-		au_sync_delay(2);
-		*aup->enable = (MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
-				| MAC_EN_CLOCK_ENABLE);
-		au_sync_delay(2);
-
-		aup->mac_enabled = 1;
-	}
-
-	spin_unlock_irqrestore(&aup->lock, flags);
-}
-
 static void reset_mac_unlocked(struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
@@ -542,30 +603,6 @@ static struct {
 static int num_ifs;
 
 /*
- * Setup the base address and interrupt of the Au1xxx ethernet macs
- * based on cpu type and whether the interface is enabled in sys_pinfunc
- * register. The last interface is enabled if SYS_PF_NI2 (bit 4) is 0.
- */
-static int __init au1000_init_module(void)
-{
-	int ni = (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
-	struct net_device *dev;
-	int i, found_one = 0;
-
-	num_ifs = NUM_ETH_INTERFACES - ni;
-
-	for(i = 0; i < num_ifs; i++) {
-		dev = au1000_probe(i);
-		iflist[i].dev = dev;
-		if (dev)
-			found_one++;
-	}
-	if (!found_one)
-		return -ENODEV;
-	return 0;
-}
-
-/*
  * ethtool operations
  */
 
@@ -611,199 +648,6 @@ static const struct ethtool_ops au1000_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 };
 
-static struct net_device * au1000_probe(int port_num)
-{
-	static unsigned version_printed = 0;
-	struct au1000_private *aup = NULL;
-	struct net_device *dev = NULL;
-	db_dest_t *pDB, *pDBfree;
-	char ethaddr[6];
-	int irq, i, err;
-	u32 base, macen;
-
-	if (port_num >= NUM_ETH_INTERFACES)
- 		return NULL;
-
-	base  = CPHYSADDR(iflist[port_num].base_addr );
-	macen = CPHYSADDR(iflist[port_num].macen_addr);
-	irq = iflist[port_num].irq;
-
-	if (!request_mem_region( base, MAC_IOSIZE, "Au1x00 ENET") ||
-	    !request_mem_region(macen, 4, "Au1x00 ENET"))
-		return NULL;
-
-	if (version_printed++ == 0)
-		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
-
-	dev = alloc_etherdev(sizeof(struct au1000_private));
-	if (!dev) {
-		printk(KERN_ERR "%s: alloc_etherdev failed\n", DRV_NAME);
-		return NULL;
-	}
-
-	if ((err = register_netdev(dev)) != 0) {
-		printk(KERN_ERR "%s: Cannot register net device, error %d\n",
-				DRV_NAME, err);
-		free_netdev(dev);
-		return NULL;
-	}
-
-	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
-		dev->name, base, irq);
-
-	aup = netdev_priv(dev);
-
-	spin_lock_init(&aup->lock);
-
-	/* Allocate the data buffers */
-	/* Snooping works fine with eth on all au1xxx */
-	aup->vaddr = (u32)dma_alloc_noncoherent(NULL, MAX_BUF_SIZE *
-						(NUM_TX_BUFFS + NUM_RX_BUFFS),
-						&aup->dma_addr,	0);
-	if (!aup->vaddr) {
-		free_netdev(dev);
-		release_mem_region( base, MAC_IOSIZE);
-		release_mem_region(macen, 4);
-		return NULL;
-	}
-
-	/* aup->mac is the base address of the MAC's registers */
-	aup->mac = (volatile mac_reg_t *)iflist[port_num].base_addr;
-
-	/* Setup some variables for quick register address access */
-	aup->enable = (volatile u32 *)iflist[port_num].macen_addr;
-	aup->mac_id = port_num;
-	au_macs[port_num] = aup;
-
-	if (port_num == 0) {
-		if (prom_get_ethernet_addr(ethaddr) == 0)
-			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
-		else {
-			printk(KERN_INFO "%s: No MAC address found\n",
-					 dev->name);
-				/* Use the hard coded MAC addresses */
-		}
-
-		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
-	} else if (port_num == 1)
-		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
-
-	/*
-	 * Assign to the Ethernet ports two consecutive MAC addresses
-	 * to match those that are printed on their stickers
-	 */
-	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
-	dev->dev_addr[5] += port_num;
-
-	*aup->enable = 0;
-	aup->mac_enabled = 0;
-
-	aup->mii_bus = mdiobus_alloc();
-	if (aup->mii_bus == NULL)
-		goto err_out;
-
-	aup->mii_bus->priv = dev;
-	aup->mii_bus->read = au1000_mdiobus_read;
-	aup->mii_bus->write = au1000_mdiobus_write;
-	aup->mii_bus->reset = au1000_mdiobus_reset;
-	aup->mii_bus->name = "au1000_eth_mii";
-	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
-	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	for(i = 0; i < PHY_MAX_ADDR; ++i)
-		aup->mii_bus->irq[i] = PHY_POLL;
-
-	/* if known, set corresponding PHY IRQs */
-#if defined(AU1XXX_PHY_STATIC_CONFIG)
-# if defined(AU1XXX_PHY0_IRQ)
-	if (AU1XXX_PHY0_BUSID == aup->mac_id)
-		aup->mii_bus->irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
-# endif
-# if defined(AU1XXX_PHY1_IRQ)
-	if (AU1XXX_PHY1_BUSID == aup->mac_id)
-		aup->mii_bus->irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
-# endif
-#endif
-	mdiobus_register(aup->mii_bus);
-
-	if (mii_probe(dev) != 0) {
-		goto err_out;
-	}
-
-	pDBfree = NULL;
-	/* setup the data buffer descriptors and attach a buffer to each one */
-	pDB = aup->db;
-	for (i = 0; i < (NUM_TX_BUFFS+NUM_RX_BUFFS); i++) {
-		pDB->pnext = pDBfree;
-		pDBfree = pDB;
-		pDB->vaddr = (u32 *)((unsigned)aup->vaddr + MAX_BUF_SIZE*i);
-		pDB->dma_addr = (dma_addr_t)virt_to_bus(pDB->vaddr);
-		pDB++;
-	}
-	aup->pDBfree = pDBfree;
-
-	for (i = 0; i < NUM_RX_DMA; i++) {
-		pDB = GetFreeDB(aup);
-		if (!pDB) {
-			goto err_out;
-		}
-		aup->rx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
-		aup->rx_db_inuse[i] = pDB;
-	}
-	for (i = 0; i < NUM_TX_DMA; i++) {
-		pDB = GetFreeDB(aup);
-		if (!pDB) {
-			goto err_out;
-		}
-		aup->tx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
-		aup->tx_dma_ring[i]->len = 0;
-		aup->tx_db_inuse[i] = pDB;
-	}
-
-	dev->base_addr = base;
-	dev->irq = irq;
-	dev->open = au1000_open;
-	dev->hard_start_xmit = au1000_tx;
-	dev->stop = au1000_close;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &au1000_ioctl;
-	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
-	dev->tx_timeout = au1000_tx_timeout;
-	dev->watchdog_timeo = ETH_TX_TIMEOUT;
-
-	/*
-	 * The boot code uses the ethernet controller, so reset it to start
-	 * fresh.  au1000_init() expects that the device is in reset state.
-	 */
-	reset_mac(dev);
-
-	return dev;
-
-err_out:
-	if (aup->mii_bus != NULL) {
-		mdiobus_unregister(aup->mii_bus);
-		mdiobus_free(aup->mii_bus);
-	}
-
-	/* here we should have a valid dev plus aup-> register addresses
-	 * so we can reset the mac properly.*/
-	reset_mac(dev);
-
-	for (i = 0; i < NUM_RX_DMA; i++) {
-		if (aup->rx_db_inuse[i])
-			ReleaseDB(aup, aup->rx_db_inuse[i]);
-	}
-	for (i = 0; i < NUM_TX_DMA; i++) {
-		if (aup->tx_db_inuse[i])
-			ReleaseDB(aup, aup->tx_db_inuse[i]);
-	}
-	dma_free_noncoherent(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
-			     (void *)aup->vaddr, aup->dma_addr);
-	unregister_netdev(dev);
-	free_netdev(dev);
-	release_mem_region( base, MAC_IOSIZE);
-	release_mem_region(macen, 4);
-	return NULL;
-}
 
 /*
  * Initialize the interface.
@@ -864,83 +708,170 @@ static int au1000_init(struct net_device *dev)
 	return 0;
 }
 
-static void
-au1000_adjust_link(struct net_device *dev)
+static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
 	struct au1000_private *aup = netdev_priv(dev);
-	struct phy_device *phydev = aup->phy_dev;
-	unsigned long flags;
+	struct net_device_stats *ps = &dev->stats;
 
-	int status_change = 0;
+	ps->rx_packets++;
+	if (status & RX_MCAST_FRAME)
+		ps->multicast++;
 
-	BUG_ON(!aup->phy_dev);
+	if (status & RX_ERROR) {
+		ps->rx_errors++;
+		if (status & RX_MISSED_FRAME)
+			ps->rx_missed_errors++;
+		if (status & (RX_OVERLEN | RX_OVERLEN | RX_LEN_ERROR))
+			ps->rx_length_errors++;
+		if (status & RX_CRC_ERROR)
+			ps->rx_crc_errors++;
+		if (status & RX_COLL)
+			ps->collisions++;
+	}
+	else
+		ps->rx_bytes += status & RX_FRAME_LEN_MASK;
 
-	spin_lock_irqsave(&aup->lock, flags);
+}
 
-	if (phydev->link && (aup->old_speed != phydev->speed)) {
-		// speed changed
+/*
+ * Au1000 receive routine.
+ */
+static int au1000_rx(struct net_device *dev)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+	struct sk_buff *skb;
+	volatile rx_dma_t *prxd;
+	u32 buff_stat, status;
+	db_dest_t *pDB;
+	u32	frmlen;
 
-		switch(phydev->speed) {
-		case SPEED_10:
-		case SPEED_100:
-			break;
-		default:
-			printk(KERN_WARNING
-			       "%s: Speed (%d) is not 10/100 ???\n",
-			       dev->name, phydev->speed);
-			break;
-		}
+	if (au1000_debug > 5)
+		printk("%s: au1000_rx head %d\n", dev->name, aup->rx_head);
 
-		aup->old_speed = phydev->speed;
+	prxd = aup->rx_dma_ring[aup->rx_head];
+	buff_stat = prxd->buff_stat;
+	while (buff_stat & RX_T_DONE)  {
+		status = prxd->status;
+		pDB = aup->rx_db_inuse[aup->rx_head];
+		update_rx_stats(dev, status);
+		if (!(status & RX_ERROR))  {
 
-		status_change = 1;
+			/* good frame */
+			frmlen = (status & RX_FRAME_LEN_MASK);
+			frmlen -= 4; /* Remove FCS */
+			skb = dev_alloc_skb(frmlen + 2);
+			if (skb == NULL) {
+				printk(KERN_ERR
+				       "%s: Memory squeeze, dropping packet.\n",
+				       dev->name);
+				dev->stats.rx_dropped++;
+				continue;
+			}
+			skb_reserve(skb, 2);	/* 16 byte IP header align */
+			skb_copy_to_linear_data(skb,
+				(unsigned char *)pDB->vaddr, frmlen);
+			skb_put(skb, frmlen);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);	/* pass the packet to upper layers */
+		}
+		else {
+			if (au1000_debug > 4) {
+				if (status & RX_MISSED_FRAME)
+					printk("rx miss\n");
+				if (status & RX_WDOG_TIMER)
+					printk("rx wdog\n");
+				if (status & RX_RUNT)
+					printk("rx runt\n");
+				if (status & RX_OVERLEN)
+					printk("rx overlen\n");
+				if (status & RX_COLL)
+					printk("rx coll\n");
+				if (status & RX_MII_ERROR)
+					printk("rx mii error\n");
+				if (status & RX_CRC_ERROR)
+					printk("rx crc error\n");
+				if (status & RX_LEN_ERROR)
+					printk("rx len error\n");
+				if (status & RX_U_CNTRL_FRAME)
+					printk("rx u control frame\n");
+				if (status & RX_MISSED_FRAME)
+					printk("rx miss\n");
+			}
+		}
+		prxd->buff_stat = (u32)(pDB->dma_addr | RX_DMA_ENABLE);
+		aup->rx_head = (aup->rx_head + 1) & (NUM_RX_DMA - 1);
+		au_sync();
+
+		/* next descriptor */
+		prxd = aup->rx_dma_ring[aup->rx_head];
+		buff_stat = prxd->buff_stat;
 	}
+	return 0;
+}
 
-	if (phydev->link && (aup->old_duplex != phydev->duplex)) {
-		// duplex mode changed
+static void update_tx_stats(struct net_device *dev, u32 status)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+	struct net_device_stats *ps = &dev->stats;
 
-		/* switching duplex mode requires to disable rx and tx! */
-		hard_stop(dev);
+	if (status & TX_FRAME_ABORTED) {
+		if (!aup->phy_dev || (DUPLEX_FULL == aup->phy_dev->duplex)) {
+			if (status & (TX_JAB_TIMEOUT | TX_UNDERRUN)) {
+				/* any other tx errors are only valid
+				 * in half duplex mode */
+				ps->tx_errors++;
+				ps->tx_aborted_errors++;
+			}
+		}
+		else {
+			ps->tx_errors++;
+			ps->tx_aborted_errors++;
+			if (status & (TX_NO_CARRIER | TX_LOSS_CARRIER))
+				ps->tx_carrier_errors++;
+		}
+	}
+}
 
-		if (DUPLEX_FULL == phydev->duplex)
-			aup->mac->control = ((aup->mac->control
-					     | MAC_FULL_DUPLEX)
-					     & ~MAC_DISABLE_RX_OWN);
-		else
-			aup->mac->control = ((aup->mac->control
-					      & ~MAC_FULL_DUPLEX)
-					     | MAC_DISABLE_RX_OWN);
-		au_sync_delay(1);
+/*
+ * Called from the interrupt service routine to acknowledge
+ * the TX DONE bits.  This is a must if the irq is setup as
+ * edge triggered.
+ */
+static void au1000_tx_ack(struct net_device *dev)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+	volatile tx_dma_t *ptxd;
 
-		enable_rx_tx(dev);
-		aup->old_duplex = phydev->duplex;
+	ptxd = aup->tx_dma_ring[aup->tx_tail];
 
-		status_change = 1;
-	}
+	while (ptxd->buff_stat & TX_T_DONE) {
+		update_tx_stats(dev, ptxd->status);
+		ptxd->buff_stat &= ~TX_T_DONE;
+		ptxd->len = 0;
+		au_sync();
 
-	if(phydev->link != aup->old_link) {
-		// link state changed
+		aup->tx_tail = (aup->tx_tail + 1) & (NUM_TX_DMA - 1);
+		ptxd = aup->tx_dma_ring[aup->tx_tail];
 
-		if (!phydev->link) {
-			/* link went down */
-			aup->old_speed = 0;
-			aup->old_duplex = -1;
+		if (aup->tx_full) {
+			aup->tx_full = 0;
+			netif_wake_queue(dev);
 		}
-
-		aup->old_link = phydev->link;
-		status_change = 1;
 	}
+}
 
-	spin_unlock_irqrestore(&aup->lock, flags);
+/*
+ * Au1000 interrupt service routine.
+ */
+static irqreturn_t au1000_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
 
-	if (status_change) {
-		if (phydev->link)
-			printk(KERN_INFO "%s: link up (%d/%s)\n",
-			       dev->name, phydev->speed,
-			       DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
-		else
-			printk(KERN_INFO "%s: link down\n", dev->name);
-	}
+	/* Handle RX interrupts first to minimize chance of overrun */
+
+	au1000_rx(dev);
+	au1000_tx_ack(dev);
+	return IRQ_RETVAL(1);
 }
 
 static int au1000_open(struct net_device *dev)
@@ -1003,88 +934,6 @@ static int au1000_close(struct net_device *dev)
 	return 0;
 }
 
-static void __exit au1000_cleanup_module(void)
-{
-	int i, j;
-	struct net_device *dev;
-	struct au1000_private *aup;
-
-	for (i = 0; i < num_ifs; i++) {
-		dev = iflist[i].dev;
-		if (dev) {
-			aup = netdev_priv(dev);
-			unregister_netdev(dev);
-			mdiobus_unregister(aup->mii_bus);
-			mdiobus_free(aup->mii_bus);
-			for (j = 0; j < NUM_RX_DMA; j++)
-				if (aup->rx_db_inuse[j])
-					ReleaseDB(aup, aup->rx_db_inuse[j]);
-			for (j = 0; j < NUM_TX_DMA; j++)
-				if (aup->tx_db_inuse[j])
-					ReleaseDB(aup, aup->tx_db_inuse[j]);
- 			dma_free_noncoherent(NULL, MAX_BUF_SIZE *
- 					     (NUM_TX_BUFFS + NUM_RX_BUFFS),
- 					     (void *)aup->vaddr, aup->dma_addr);
- 			release_mem_region(dev->base_addr, MAC_IOSIZE);
- 			release_mem_region(CPHYSADDR(iflist[i].macen_addr), 4);
-			free_netdev(dev);
-		}
-	}
-}
-
-static void update_tx_stats(struct net_device *dev, u32 status)
-{
-	struct au1000_private *aup = netdev_priv(dev);
-	struct net_device_stats *ps = &dev->stats;
-
-	if (status & TX_FRAME_ABORTED) {
-		if (!aup->phy_dev || (DUPLEX_FULL == aup->phy_dev->duplex)) {
-			if (status & (TX_JAB_TIMEOUT | TX_UNDERRUN)) {
-				/* any other tx errors are only valid
-				 * in half duplex mode */
-				ps->tx_errors++;
-				ps->tx_aborted_errors++;
-			}
-		}
-		else {
-			ps->tx_errors++;
-			ps->tx_aborted_errors++;
-			if (status & (TX_NO_CARRIER | TX_LOSS_CARRIER))
-				ps->tx_carrier_errors++;
-		}
-	}
-}
-
-
-/*
- * Called from the interrupt service routine to acknowledge
- * the TX DONE bits.  This is a must if the irq is setup as
- * edge triggered.
- */
-static void au1000_tx_ack(struct net_device *dev)
-{
-	struct au1000_private *aup = netdev_priv(dev);
-	volatile tx_dma_t *ptxd;
-
-	ptxd = aup->tx_dma_ring[aup->tx_tail];
-
-	while (ptxd->buff_stat & TX_T_DONE) {
-		update_tx_stats(dev, ptxd->status);
-		ptxd->buff_stat &= ~TX_T_DONE;
-		ptxd->len = 0;
-		au_sync();
-
-		aup->tx_tail = (aup->tx_tail + 1) & (NUM_TX_DMA - 1);
-		ptxd = aup->tx_dma_ring[aup->tx_tail];
-
-		if (aup->tx_full) {
-			aup->tx_full = 0;
-			netif_wake_queue(dev);
-		}
-	}
-}
-
-
 /*
  * Au1000 transmit routine.
  */
@@ -1142,123 +991,6 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static inline void update_rx_stats(struct net_device *dev, u32 status)
-{
-	struct au1000_private *aup = netdev_priv(dev);
-	struct net_device_stats *ps = &dev->stats;
-
-	ps->rx_packets++;
-	if (status & RX_MCAST_FRAME)
-		ps->multicast++;
-
-	if (status & RX_ERROR) {
-		ps->rx_errors++;
-		if (status & RX_MISSED_FRAME)
-			ps->rx_missed_errors++;
-		if (status & (RX_OVERLEN | RX_OVERLEN | RX_LEN_ERROR))
-			ps->rx_length_errors++;
-		if (status & RX_CRC_ERROR)
-			ps->rx_crc_errors++;
-		if (status & RX_COLL)
-			ps->collisions++;
-	}
-	else
-		ps->rx_bytes += status & RX_FRAME_LEN_MASK;
-
-}
-
-/*
- * Au1000 receive routine.
- */
-static int au1000_rx(struct net_device *dev)
-{
-	struct au1000_private *aup = netdev_priv(dev);
-	struct sk_buff *skb;
-	volatile rx_dma_t *prxd;
-	u32 buff_stat, status;
-	db_dest_t *pDB;
-	u32	frmlen;
-
-	if (au1000_debug > 5)
-		printk("%s: au1000_rx head %d\n", dev->name, aup->rx_head);
-
-	prxd = aup->rx_dma_ring[aup->rx_head];
-	buff_stat = prxd->buff_stat;
-	while (buff_stat & RX_T_DONE)  {
-		status = prxd->status;
-		pDB = aup->rx_db_inuse[aup->rx_head];
-		update_rx_stats(dev, status);
-		if (!(status & RX_ERROR))  {
-
-			/* good frame */
-			frmlen = (status & RX_FRAME_LEN_MASK);
-			frmlen -= 4; /* Remove FCS */
-			skb = dev_alloc_skb(frmlen + 2);
-			if (skb == NULL) {
-				printk(KERN_ERR
-				       "%s: Memory squeeze, dropping packet.\n",
-				       dev->name);
-				dev->stats.rx_dropped++;
-				continue;
-			}
-			skb_reserve(skb, 2);	/* 16 byte IP header align */
-			skb_copy_to_linear_data(skb,
-				(unsigned char *)pDB->vaddr, frmlen);
-			skb_put(skb, frmlen);
-			skb->protocol = eth_type_trans(skb, dev);
-			netif_rx(skb);	/* pass the packet to upper layers */
-		}
-		else {
-			if (au1000_debug > 4) {
-				if (status & RX_MISSED_FRAME)
-					printk("rx miss\n");
-				if (status & RX_WDOG_TIMER)
-					printk("rx wdog\n");
-				if (status & RX_RUNT)
-					printk("rx runt\n");
-				if (status & RX_OVERLEN)
-					printk("rx overlen\n");
-				if (status & RX_COLL)
-					printk("rx coll\n");
-				if (status & RX_MII_ERROR)
-					printk("rx mii error\n");
-				if (status & RX_CRC_ERROR)
-					printk("rx crc error\n");
-				if (status & RX_LEN_ERROR)
-					printk("rx len error\n");
-				if (status & RX_U_CNTRL_FRAME)
-					printk("rx u control frame\n");
-				if (status & RX_MISSED_FRAME)
-					printk("rx miss\n");
-			}
-		}
-		prxd->buff_stat = (u32)(pDB->dma_addr | RX_DMA_ENABLE);
-		aup->rx_head = (aup->rx_head + 1) & (NUM_RX_DMA - 1);
-		au_sync();
-
-		/* next descriptor */
-		prxd = aup->rx_dma_ring[aup->rx_head];
-		buff_stat = prxd->buff_stat;
-	}
-	return 0;
-}
-
-
-/*
- * Au1000 interrupt service routine.
- */
-static irqreturn_t au1000_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-
-	/* Handle RX interrupts first to minimize chance of overrun */
-
-	au1000_rx(dev);
-	au1000_tx_ack(dev);
-	return IRQ_RETVAL(1);
-}
-
-
 /*
  * The Tx ring has been full longer than the watchdog timeout
  * value. The transmitter must be hung?
@@ -1315,5 +1047,252 @@ static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
 }
 
+static struct net_device * au1000_probe(int port_num)
+{
+	static unsigned version_printed = 0;
+	struct au1000_private *aup = NULL;
+	struct net_device *dev = NULL;
+	db_dest_t *pDB, *pDBfree;
+	char ethaddr[6];
+	int irq, i, err;
+	u32 base, macen;
+
+	if (port_num >= NUM_ETH_INTERFACES)
+ 		return NULL;
+
+	base  = CPHYSADDR(iflist[port_num].base_addr );
+	macen = CPHYSADDR(iflist[port_num].macen_addr);
+	irq = iflist[port_num].irq;
+
+	if (!request_mem_region( base, MAC_IOSIZE, "Au1x00 ENET") ||
+	    !request_mem_region(macen, 4, "Au1x00 ENET"))
+		return NULL;
+
+	if (version_printed++ == 0)
+		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+
+	dev = alloc_etherdev(sizeof(struct au1000_private));
+	if (!dev) {
+		printk(KERN_ERR "%s: alloc_etherdev failed\n", DRV_NAME);
+		return NULL;
+	}
+
+	if ((err = register_netdev(dev)) != 0) {
+		printk(KERN_ERR "%s: Cannot register net device, error %d\n",
+				DRV_NAME, err);
+		free_netdev(dev);
+		return NULL;
+	}
+
+	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
+		dev->name, base, irq);
+
+	aup = netdev_priv(dev);
+
+	spin_lock_init(&aup->lock);
+
+	/* Allocate the data buffers */
+	/* Snooping works fine with eth on all au1xxx */
+	aup->vaddr = (u32)dma_alloc_noncoherent(NULL, MAX_BUF_SIZE *
+						(NUM_TX_BUFFS + NUM_RX_BUFFS),
+						&aup->dma_addr,	0);
+	if (!aup->vaddr) {
+		free_netdev(dev);
+		release_mem_region( base, MAC_IOSIZE);
+		release_mem_region(macen, 4);
+		return NULL;
+	}
+
+	/* aup->mac is the base address of the MAC's registers */
+	aup->mac = (volatile mac_reg_t *)iflist[port_num].base_addr;
+
+	/* Setup some variables for quick register address access */
+	aup->enable = (volatile u32 *)iflist[port_num].macen_addr;
+	aup->mac_id = port_num;
+	au_macs[port_num] = aup;
+
+	if (port_num == 0) {
+		if (prom_get_ethernet_addr(ethaddr) == 0)
+			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
+		else {
+			printk(KERN_INFO "%s: No MAC address found\n",
+					 dev->name);
+				/* Use the hard coded MAC addresses */
+		}
+
+		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
+	} else if (port_num == 1)
+		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
+
+	/*
+	 * Assign to the Ethernet ports two consecutive MAC addresses
+	 * to match those that are printed on their stickers
+	 */
+	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
+	dev->dev_addr[5] += port_num;
+
+	*aup->enable = 0;
+	aup->mac_enabled = 0;
+
+	aup->mii_bus = mdiobus_alloc();
+	if (aup->mii_bus == NULL)
+		goto err_out;
+
+	aup->mii_bus->priv = dev;
+	aup->mii_bus->read = au1000_mdiobus_read;
+	aup->mii_bus->write = au1000_mdiobus_write;
+	aup->mii_bus->reset = au1000_mdiobus_reset;
+	aup->mii_bus->name = "au1000_eth_mii";
+	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
+	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	for(i = 0; i < PHY_MAX_ADDR; ++i)
+		aup->mii_bus->irq[i] = PHY_POLL;
+
+	/* if known, set corresponding PHY IRQs */
+#if defined(AU1XXX_PHY_STATIC_CONFIG)
+# if defined(AU1XXX_PHY0_IRQ)
+	if (AU1XXX_PHY0_BUSID == aup->mac_id)
+		aup->mii_bus->irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
+# endif
+# if defined(AU1XXX_PHY1_IRQ)
+	if (AU1XXX_PHY1_BUSID == aup->mac_id)
+		aup->mii_bus->irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
+# endif
+#endif
+	mdiobus_register(aup->mii_bus);
+
+	if (mii_probe(dev) != 0) {
+		goto err_out;
+	}
+
+	pDBfree = NULL;
+	/* setup the data buffer descriptors and attach a buffer to each one */
+	pDB = aup->db;
+	for (i = 0; i < (NUM_TX_BUFFS+NUM_RX_BUFFS); i++) {
+		pDB->pnext = pDBfree;
+		pDBfree = pDB;
+		pDB->vaddr = (u32 *)((unsigned)aup->vaddr + MAX_BUF_SIZE*i);
+		pDB->dma_addr = (dma_addr_t)virt_to_bus(pDB->vaddr);
+		pDB++;
+	}
+	aup->pDBfree = pDBfree;
+
+	for (i = 0; i < NUM_RX_DMA; i++) {
+		pDB = GetFreeDB(aup);
+		if (!pDB) {
+			goto err_out;
+		}
+		aup->rx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
+		aup->rx_db_inuse[i] = pDB;
+	}
+	for (i = 0; i < NUM_TX_DMA; i++) {
+		pDB = GetFreeDB(aup);
+		if (!pDB) {
+			goto err_out;
+		}
+		aup->tx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
+		aup->tx_dma_ring[i]->len = 0;
+		aup->tx_db_inuse[i] = pDB;
+	}
+
+	dev->base_addr = base;
+	dev->irq = irq;
+	dev->open = au1000_open;
+	dev->hard_start_xmit = au1000_tx;
+	dev->stop = au1000_close;
+	dev->set_multicast_list = &set_rx_mode;
+	dev->do_ioctl = &au1000_ioctl;
+	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
+	dev->tx_timeout = au1000_tx_timeout;
+	dev->watchdog_timeo = ETH_TX_TIMEOUT;
+
+	/*
+	 * The boot code uses the ethernet controller, so reset it to start
+	 * fresh.  au1000_init() expects that the device is in reset state.
+	 */
+	reset_mac(dev);
+
+	return dev;
+
+err_out:
+	if (aup->mii_bus != NULL) {
+		mdiobus_unregister(aup->mii_bus);
+		mdiobus_free(aup->mii_bus);
+	}
+
+	/* here we should have a valid dev plus aup-> register addresses
+	 * so we can reset the mac properly.*/
+	reset_mac(dev);
+
+	for (i = 0; i < NUM_RX_DMA; i++) {
+		if (aup->rx_db_inuse[i])
+			ReleaseDB(aup, aup->rx_db_inuse[i]);
+	}
+	for (i = 0; i < NUM_TX_DMA; i++) {
+		if (aup->tx_db_inuse[i])
+			ReleaseDB(aup, aup->tx_db_inuse[i]);
+	}
+	dma_free_noncoherent(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
+			     (void *)aup->vaddr, aup->dma_addr);
+	unregister_netdev(dev);
+	free_netdev(dev);
+	release_mem_region( base, MAC_IOSIZE);
+	release_mem_region(macen, 4);
+	return NULL;
+}
+
+/*
+ * Setup the base address and interrupt of the Au1xxx ethernet macs
+ * based on cpu type and whether the interface is enabled in sys_pinfunc
+ * register. The last interface is enabled if SYS_PF_NI2 (bit 4) is 0.
+ */
+static int __init au1000_init_module(void)
+{
+	int ni = (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
+	struct net_device *dev;
+	int i, found_one = 0;
+
+	num_ifs = NUM_ETH_INTERFACES - ni;
+
+	for(i = 0; i < num_ifs; i++) {
+		dev = au1000_probe(i);
+		iflist[i].dev = dev;
+		if (dev)
+			found_one++;
+	}
+	if (!found_one)
+		return -ENODEV;
+	return 0;
+}
+
+static void __exit au1000_cleanup_module(void)
+{
+	int i, j;
+	struct net_device *dev;
+	struct au1000_private *aup;
+
+	for (i = 0; i < num_ifs; i++) {
+		dev = iflist[i].dev;
+		if (dev) {
+			aup = netdev_priv(dev);
+			unregister_netdev(dev);
+			mdiobus_unregister(aup->mii_bus);
+			mdiobus_free(aup->mii_bus);
+			for (j = 0; j < NUM_RX_DMA; j++)
+				if (aup->rx_db_inuse[j])
+					ReleaseDB(aup, aup->rx_db_inuse[j]);
+			for (j = 0; j < NUM_TX_DMA; j++)
+				if (aup->tx_db_inuse[j])
+					ReleaseDB(aup, aup->tx_db_inuse[j]);
+ 			dma_free_noncoherent(NULL, MAX_BUF_SIZE *
+ 					     (NUM_TX_BUFFS + NUM_RX_BUFFS),
+ 					     (void *)aup->vaddr, aup->dma_addr);
+ 			release_mem_region(dev->base_addr, MAC_IOSIZE);
+ 			release_mem_region(CPHYSADDR(iflist[i].macen_addr), 4);
+			free_netdev(dev);
+		}
+	}
+}
+
 module_init(au1000_init_module);
 module_exit(au1000_cleanup_module);
