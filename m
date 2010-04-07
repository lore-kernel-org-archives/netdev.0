From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/7] au1000-eth: Use (dev|netdev|netif)_<level> macro helpers
Date: Wed, 7 Apr 2010 10:09:17 +0200
Message-ID: <201004071009.17388.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:64281 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259Ab0DGIKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:24 -0400
Received: by mail-ew0-f220.google.com with SMTP id 20so385422ewy.1
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 0c59d4c..5afca6c 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -187,8 +187,7 @@ static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
-			printk(KERN_ERR "%s: read_MII busy timeout!!\n",
-					dev->name);
+			netdev_err(dev, "read_MII busy timeout!!\n");
 			return -1;
 		}
 	}
@@ -202,8 +201,7 @@ static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
-			printk(KERN_ERR "%s: mdio_read busy timeout!!\n",
-					dev->name);
+			netdev_err(dev, "mdio_read busy timeout!!\n");
 			return -1;
 		}
 	}
@@ -222,8 +220,7 @@ static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
-			printk(KERN_ERR "%s: mdio_write busy timeout!!\n",
-					dev->name);
+			netdev_err(dev, "mdio_write busy timeout!!\n");
 			return;
 		}
 	}
@@ -270,8 +267,7 @@ static void au1000_hard_stop(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
-	if (au1000_debug > 4)
-		printk(KERN_INFO "%s: hard stop\n", dev->name);
+	netif_dbg(aup, drv, dev, "hard stop\n");
 
 	aup->mac->control &= ~(MAC_RX_ENABLE | MAC_TX_ENABLE);
 	au_sync_delay(10);
@@ -281,8 +277,7 @@ static void au1000_enable_rx_tx(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
-	if (au1000_debug > 4)
-		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
+	netif_dbg(aup, hw, dev, "enable_rx_tx\n");
 
 	aup->mac->control |= (MAC_RX_ENABLE | MAC_TX_ENABLE);
 	au_sync_delay(10);
@@ -309,9 +304,8 @@ au1000_adjust_link(struct net_device *dev)
 		case SPEED_100:
 			break;
 		default:
-			printk(KERN_WARNING
-			       "%s: Speed (%d) is not 10/100 ???\n",
-			       dev->name, phydev->speed);
+			netdev_warn(dev, "Speed (%d) is not 10/100 ???\n",
+							phydev->speed);
 			break;
 		}
 
@@ -359,11 +353,11 @@ au1000_adjust_link(struct net_device *dev)
 
 	if (status_change) {
 		if (phydev->link)
-			printk(KERN_INFO "%s: link up (%d/%s)\n",
-			       dev->name, phydev->speed,
+			netdev_info(dev, "link up (%d/%s)\n",
+			       phydev->speed,
 			       DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
 		else
-			printk(KERN_INFO "%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 	}
 }
 
@@ -378,8 +372,7 @@ static int au1000_mii_probe (struct net_device *dev)
 		if (aup->phy_addr)
 			phydev = aup->mii_bus->phy_map[aup->phy_addr];
 		else
-			printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
-				dev->name);
+			netdev_info(dev, "using PHY-less setup\n");
 		return 0;
 	} else {
 		int phy_addr;
@@ -396,7 +389,7 @@ static int au1000_mii_probe (struct net_device *dev)
 			/* try harder to find a PHY */
 			if (!phydev && (aup->mac_id == 1)) {
 				/* no PHY found, maybe we have a dual PHY? */
-				printk (KERN_INFO DRV_NAME ": no PHY found on MAC1, "
+				dev_info(&dev->dev, ": no PHY found on MAC1, "
 					"let's see if it's attached to MAC0...\n");
 
 				/* find the first (lowest address) non-attached PHY on
@@ -422,7 +415,7 @@ static int au1000_mii_probe (struct net_device *dev)
 	}
 
 	if (!phydev) {
-		printk (KERN_ERR DRV_NAME ":%s: no PHY found\n", dev->name);
+		netdev_err(dev, "no PHY found\n");
 		return -1;
 	}
 
@@ -433,7 +426,7 @@ static int au1000_mii_probe (struct net_device *dev)
 			0, PHY_INTERFACE_MODE_MII);
 
 	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		netdev_err(dev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -454,8 +447,8 @@ static int au1000_mii_probe (struct net_device *dev)
 	aup->old_duplex = -1;
 	aup->phy_dev = phydev;
 
-	printk(KERN_INFO "%s: attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n", dev->name,
+	netdev_info(dev, "attached PHY driver [%s] "
+	       "(mii_bus:phy_addr=%s, irq=%d)\n",
 	       phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
 
 	return 0;
@@ -517,9 +510,8 @@ static void au1000_reset_mac(struct net_device *dev)
 	struct au1000_private *const aup = netdev_priv(dev);
 	unsigned long flags;
 
-	if (au1000_debug > 4)
-		printk(KERN_INFO "%s: reset mac, aup %x\n",
-		       dev->name, (unsigned)aup);
+	netif_dbg(aup, hw, dev, "reset mac, aup %x\n",
+					(unsigned)aup);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -625,8 +617,7 @@ static int au1000_init(struct net_device *dev)
 	int i;
 	u32 control;
 
-	if (au1000_debug > 4)
-		printk("%s: au1000_init\n", dev->name);
+	netif_dbg(aup, hw, dev, "au1000_init\n");
 
 	/* bring the device out of reset */
 	au1000_enable_mac(dev, 1);
@@ -703,8 +694,7 @@ static int au1000_rx(struct net_device *dev)
 	db_dest_t *pDB;
 	u32	frmlen;
 
-	if (au1000_debug > 5)
-		printk("%s: au1000_rx head %d\n", dev->name, aup->rx_head);
+	netif_dbg(aup, rx_status, dev, "au1000_rx head %d\n", aup->rx_head);
 
 	prxd = aup->rx_dma_ring[aup->rx_head];
 	buff_stat = prxd->buff_stat;
@@ -719,9 +709,7 @@ static int au1000_rx(struct net_device *dev)
 			frmlen -= 4; /* Remove FCS */
 			skb = dev_alloc_skb(frmlen + 2);
 			if (skb == NULL) {
-				printk(KERN_ERR
-				       "%s: Memory squeeze, dropping packet.\n",
-				       dev->name);
+				netdev_err(dev, "Memory squeeze, dropping packet.\n");
 				dev->stats.rx_dropped++;
 				continue;
 			}
@@ -833,20 +821,18 @@ static int au1000_open(struct net_device *dev)
 	int retval;
 	struct au1000_private *aup = netdev_priv(dev);
 
-	if (au1000_debug > 4)
-		printk("%s: open: dev=%p\n", dev->name, dev);
+	netif_dbg(aup, drv, dev, "open: dev=%p\n", dev);
 
 	retval = request_irq(dev->irq, au1000_interrupt, 0,
 					dev->name, dev);
 	if (retval) {
-		printk(KERN_ERR "%s: unable to get IRQ %d\n",
-				dev->name, dev->irq);
+		netdev_err(dev, "unable to get IRQ %d\n", dev->irq);
 		return retval;
 	}
 
 	retval = au1000_init(dev);
 	if (retval) {
-		printk(KERN_ERR "%s: error in au1000_init\n", dev->name);
+		netdev_err(dev, "error in au1000_init\n");
 		free_irq(dev->irq, dev);
 		return retval;
 	}
@@ -859,8 +845,7 @@ static int au1000_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 
-	if (au1000_debug > 4)
-		printk("%s: open: Initialization done.\n", dev->name);
+	netif_dbg(aup, drv, dev, "open: Initialization done.\n");
 
 	return 0;
 }
@@ -870,8 +855,7 @@ static int au1000_close(struct net_device *dev)
 	unsigned long flags;
 	struct au1000_private *const aup = netdev_priv(dev);
 
-	if (au1000_debug > 4)
-		printk("%s: close: dev=%p\n", dev->name, dev);
+	netif_dbg(aup, drv, dev, "close: dev=%p\n", dev);
 
 	if (aup->phy_dev)
 		phy_stop(aup->phy_dev);
@@ -902,9 +886,8 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	db_dest_t *pDB;
 	int i;
 
-	if (au1000_debug > 5)
-		printk("%s: tx: aup %x len=%d, data=%p, head %d\n",
-				dev->name, (unsigned)aup, skb->len,
+	netif_dbg(aup, tx_queued, dev, "tx: aup %x len=%d, data=%p, head %d\n",
+				(unsigned)aup, skb->len,
 				skb->data, aup->tx_head);
 
 	ptxd = aup->tx_dma_ring[aup->tx_head];
@@ -951,7 +934,7 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
  */
 static void au1000_tx_timeout(struct net_device *dev)
 {
-	printk(KERN_ERR "%s: au1000_tx_timeout: dev=%p\n", dev->name, dev);
+	netdev_err(dev, "au1000_tx_timeout: dev=%p\n", dev);
 	au1000_reset_mac(dev);
 	au1000_init(dev);
 	dev->trans_start = jiffies;
@@ -962,8 +945,7 @@ static void au1000_multicast_list(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
-	if (au1000_debug > 4)
-		printk("%s: au1000_multicast_list: flags=%x\n", dev->name, dev->flags);
+	netif_dbg(aup, drv, dev, "au1000_multicast_list: flags=%x\n", dev->flags);
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
@@ -971,7 +953,7 @@ static void au1000_multicast_list(struct net_device *dev)
 			   netdev_mc_count(dev) > MULTICAST_FILTER_LIMIT) {
 		aup->mac->control |= MAC_PASS_ALL_MULTI;
 		aup->mac->control &= ~MAC_PROMISCUOUS;
-		printk(KERN_INFO "%s: Pass all multicast\n", dev->name);
+		netdev_info(dev, "Pass all multicast\n");
 	} else {
 		struct netdev_hw_addr *ha;
 		u32 mc_filter[2];	/* Multicast hash filter */
@@ -1025,40 +1007,40 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	base = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!base) {
-		printk(KERN_ERR DRV_NAME ": failed to retrieve base register\n");
+		dev_err(&pdev->dev, "failed to retrieve base register\n");
 		err = -ENODEV;
 		goto out;
 	}
 
 	macen = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	if (!macen) {
-		printk(KERN_ERR DRV_NAME ": failed to retrieve MAC Enable register\n");
+		dev_err(&pdev->dev, "failed to retrieve MAC Enable register\n");
 		err = -ENODEV;
 		goto out;
 	}
 
 	irq = platform_get_irq(pdev, 0);
 	if (irq < 0) {
-		printk(KERN_ERR DRV_NAME ": failed to retrieve IRQ\n");
+		dev_err(&pdev->dev, "failed to retrieve IRQ\n");
 		err = -ENODEV;
 		goto out;
 	}
 
 	if (!request_mem_region(base->start, resource_size(base), pdev->name)) {
-		printk(KERN_ERR DRV_NAME ": failed to request memory region for base registers\n");
+		dev_err(&pdev->dev, "failed to request memory region for base registers\n");
 		err = -ENXIO;
 		goto out;
 	}
 
 	if (!request_mem_region(macen->start, resource_size(macen), pdev->name)) {
-		printk(KERN_ERR DRV_NAME ": failed to request memory region for MAC enable register\n");
+		dev_err(&pdev->dev, "failed to request memory region for MAC enable register\n");
 		err = -ENXIO;
 		goto err_request;
 	}
 
 	dev = alloc_etherdev(sizeof(struct au1000_private));
 	if (!dev) {
-		printk(KERN_ERR "%s: alloc_etherdev failed\n", DRV_NAME);
+		dev_err(&pdev->dev, "alloc_etherdev failed\n");
 		err = -ENOMEM;
 		goto err_alloc;
 	}
@@ -1076,7 +1058,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 						(NUM_TX_BUFFS + NUM_RX_BUFFS),
 						&aup->dma_addr,	0);
 	if (!aup->vaddr) {
-		printk(KERN_ERR DRV_NAME ": failed to allocate data buffers\n");
+		dev_err(&pdev->dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
 		goto err_vaddr;
 	}
@@ -1084,7 +1066,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	/* aup->mac is the base address of the MAC's registers */
 	aup->mac = (volatile mac_reg_t *)ioremap_nocache(base->start, resource_size(base));
 	if (!aup->mac) {
-		printk(KERN_ERR DRV_NAME ": failed to ioremap MAC registers\n");
+		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
 		err = -ENXIO;
 		goto err_remap1;
 	}
@@ -1092,7 +1074,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
         /* Setup some variables for quick register address access */
 	aup->enable = (volatile u32 *)ioremap_nocache(macen->start, resource_size(macen));
 	if (!aup->enable) {
-		printk(KERN_ERR DRV_NAME ": failed to ioremap MAC enable register\n");
+		dev_err(&pdev->dev, "failed to ioremap MAC enable register\n");
 		err = -ENXIO;
 		goto err_remap2;
 	}
@@ -1102,8 +1084,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		if (prom_get_ethernet_addr(ethaddr) == 0)
 			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
 		else {
-			printk(KERN_INFO "%s: No MAC address found\n",
-					 dev->name);
+			netdev_info(dev, "No MAC address found\n");
 				/* Use the hard coded MAC addresses */
 		}
 
@@ -1123,7 +1104,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	pd = pdev->dev.platform_data;
 	if (!pd) {
-		printk(KERN_INFO DRV_NAME ": no platform_data passed, PHY search on MAC0\n");
+		dev_info(&pdev->dev, "no platform_data passed, PHY search on MAC0\n");
 		aup->phy1_search_mac0 = 1;
 	} else {
 		aup->phy_static_config = pd->phy_static_config;
@@ -1135,7 +1116,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	if (aup->phy_busid && aup->phy_busid > 0) {
-		printk(KERN_ERR DRV_NAME ": MAC0-associated PHY attached 2nd MACs MII"
+		dev_err(&pdev->dev, "MAC0-associated PHY attached 2nd MACs MII"
 				"bus not supported yet\n");
 		err = -ENODEV;
 		goto err_mdiobus_alloc;
@@ -1143,7 +1124,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	aup->mii_bus = mdiobus_alloc();
 	if (aup->mii_bus == NULL) {
-		printk(KERN_ERR DRV_NAME ": failed to allocate mdiobus structure\n");
+		dev_err(&pdev->dev, "failed to allocate mdiobus structure\n");
 		err = -ENOMEM;
 		goto err_mdiobus_alloc;
 	}
@@ -1167,7 +1148,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	err = mdiobus_register(aup->mii_bus);
 	if (err) {
-		printk(KERN_ERR DRV_NAME " failed to register MDIO bus\n");
+		dev_err(&pdev->dev, "failed to register MDIO bus\n");
 		goto err_mdiobus_reg;
 	}
 
@@ -1218,13 +1199,12 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR DRV_NAME "%s: Cannot register net device, aborting.\n",
-					dev->name);
+		netdev_err(dev, "Cannot register net device, aborting.\n");
 		goto err_out;
 	}
 
-	printk("%s: Au1xx0 Ethernet found at 0x%lx, irq %d\n",
-			dev->name, (unsigned long)base->start, irq);
+	netdev_info(dev, "Au1xx0 Ethernet found at 0x%lx, irq %d\n",
+			(unsigned long)base->start, irq);
 	if (version_printed++ == 0)
 		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
 
