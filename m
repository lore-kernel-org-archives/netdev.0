From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4] au1000_eth: convert to a platform_driver part one
Date: Tue, 28 Jul 2009 23:00:22 +0200
Message-ID: <200907282300.22417.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Manuel Lauss <manuel.lauss@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:47403 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbZG1VAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:00:30 -0400
Received: by mail-ew0-f226.google.com with SMTP id 26so359125ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 14:00:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts au1000_eth to become a platform_driver.
Nothing is functionaly changed, and we do not yet pass
PHY configuration, this is done in a follow-up patch.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 2aab1eb..a344cb3 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -54,6 +54,7 @@
 #include <linux/delay.h>
 #include <linux/crc32.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
 
 #include <asm/cpu.h>
 #include <asm/mipsregs.h>
@@ -394,7 +395,7 @@ static int mii_probe (struct net_device *dev)
 
 	if(aup->mac_id == 0) { /* get PHY0 */
 # if defined(AU1XXX_PHY0_ADDR)
-		phydev = au_macs[AU1XXX_PHY0_BUSID]->mii_bus->phy_map[AU1XXX_PHY0_ADDR];
+		phydev = aup->mii_bus->phy_map[AU1XXX_PHY0_ADDR];
 # else
 		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
 			dev->name);
@@ -402,7 +403,7 @@ static int mii_probe (struct net_device *dev)
 # endif /* defined(AU1XXX_PHY0_ADDR) */
 	} else if (aup->mac_id == 1) { /* get PHY1 */
 # if defined(AU1XXX_PHY1_ADDR)
-		phydev = au_macs[AU1XXX_PHY1_BUSID]->mii_bus->phy_map[AU1XXX_PHY1_ADDR];
+		phydev = aup->mii_bus->phy_map[AU1XXX_PHY1_ADDR];
 # else
 		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
 			dev->name);
@@ -429,13 +430,13 @@ static int mii_probe (struct net_device *dev)
 		printk (KERN_INFO DRV_NAME ": no PHY found on MAC1, "
 			"let's see if it's attached to MAC0...\n");
 
-		BUG_ON(!au_macs[0]);
-
 		/* find the first (lowest address) non-attached PHY on
 		 * the MAC0 MII bus */
 		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+			if (aup->mac_id == 1)
+				break;
 			struct phy_device *const tmp_phydev =
-				au_macs[0]->mii_bus->phy_map[phy_addr];
+				aup->mii_bus->phy_map[phy_addr];
 
 			if (!tmp_phydev)
 				continue; /* no PHY here... */
@@ -577,31 +578,6 @@ setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
 	}
 }
 
-static struct {
-	u32 base_addr;
-	u32 macen_addr;
-	int irq;
-	struct net_device *dev;
-} iflist[2] = {
-#ifdef CONFIG_SOC_AU1000
-	{AU1000_ETH0_BASE, AU1000_MAC0_ENABLE, AU1000_MAC0_DMA_INT},
-	{AU1000_ETH1_BASE, AU1000_MAC1_ENABLE, AU1000_MAC1_DMA_INT}
-#endif
-#ifdef CONFIG_SOC_AU1100
-	{AU1100_ETH0_BASE, AU1100_MAC0_ENABLE, AU1100_MAC0_DMA_INT}
-#endif
-#ifdef CONFIG_SOC_AU1500
-	{AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT},
-	{AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT}
-#endif
-#ifdef CONFIG_SOC_AU1550
-	{AU1550_ETH0_BASE, AU1550_MAC0_ENABLE, AU1550_MAC0_DMA_INT},
-	{AU1550_ETH1_BASE, AU1550_MAC1_ENABLE, AU1550_MAC1_DMA_INT}
-#endif
-};
-
-static int num_ifs;
-
 /*
  * ethtool operations
  */
@@ -1059,46 +1035,58 @@ static const struct net_device_ops au1000_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static struct net_device * au1000_probe(int port_num)
+static int __devinit au1000_probe(struct platform_device *pdev)
 {
 	static unsigned version_printed = 0;
 	struct au1000_private *aup = NULL;
 	struct net_device *dev = NULL;
 	db_dest_t *pDB, *pDBfree;
-	char ethaddr[6];
-	int irq, i, err;
-	u32 base, macen;
-
-	if (port_num >= NUM_ETH_INTERFACES)
-		return NULL;
+	int irq, i, err = 0;
+	struct resource *base, *macen;
+	DECLARE_MAC_BUF(ethaddr);
+
+	base = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!base) {
+		printk(KERN_ERR DRV_NAME ": failed to retrieve base register\n");
+		err = -ENODEV;
+		goto out;
+	}
 
-	base  = CPHYSADDR(iflist[port_num].base_addr );
-	macen = CPHYSADDR(iflist[port_num].macen_addr);
-	irq = iflist[port_num].irq;
+	macen = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!macen) {
+		printk(KERN_ERR DRV_NAME ": failed to retrieve MAC Enable register\n");
+		err = -ENODEV;
+		goto out;
+	}
 
-	if (!request_mem_region( base, MAC_IOSIZE, "Au1x00 ENET") ||
-	    !request_mem_region(macen, 4, "Au1x00 ENET"))
-		return NULL;
+	irq = platform_get_irq(pdev, 0);
+	if (irq < 0) {
+		printk(KERN_ERR DRV_NAME ": failed to retrieve IRQ\n");
+		err = -ENODEV;
+		goto out;
+	}
 
-	if (version_printed++ == 0)
-		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+	if (!request_mem_region(base->start, resource_size(base), pdev->name)) {
+		printk(KERN_ERR DRV_NAME ": failed to request memory region for base registers\n");
+		err = -ENXIO;
+		goto out;
+	}
+	
+	if (!request_mem_region(macen->start, resource_size(macen), pdev->name)) {
+		printk(KERN_ERR DRV_NAME ": failed to request memory region for MAC enable register\n");
+		err = -ENXIO;
+		goto err_request;
+	}
 
 	dev = alloc_etherdev(sizeof(struct au1000_private));
 	if (!dev) {
 		printk(KERN_ERR "%s: alloc_etherdev failed\n", DRV_NAME);
-		return NULL;
+		err = -ENOMEM;
+		goto err_alloc;
 	}
 
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
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	platform_set_drvdata(pdev, dev);
 	aup = netdev_priv(dev);
 
 	spin_lock_init(&aup->lock);
@@ -1109,21 +1097,29 @@ static struct net_device * au1000_probe(int port_num)
 						(NUM_TX_BUFFS + NUM_RX_BUFFS),
 						&aup->dma_addr,	0);
 	if (!aup->vaddr) {
-		free_netdev(dev);
-		release_mem_region( base, MAC_IOSIZE);
-		release_mem_region(macen, 4);
-		return NULL;
+		printk(KERN_ERR DRV_NAME ": failed to allocate data buffers\n");
+		err = -ENOMEM;
+		goto err_vaddr;
 	}
 
 	/* aup->mac is the base address of the MAC's registers */
-	aup->mac = (volatile mac_reg_t *)iflist[port_num].base_addr;
+	aup->mac = (volatile mac_reg_t *)ioremap_nocache(base->start, resource_size(base));
+	if (!aup->mac) {
+		printk(KERN_ERR DRV_NAME ": failed to ioremap MAC registers\n");
+		err = -ENXIO;
+		goto err_remap1;
+	}
 
-	/* Setup some variables for quick register address access */
-	aup->enable = (volatile u32 *)iflist[port_num].macen_addr;
-	aup->mac_id = port_num;
-	au_macs[port_num] = aup;
+        /* Setup some variables for quick register address access */
+        aup->enable = (volatile u32 *)ioremap_nocache(macen->start, resource_size(macen));
+	if (!aup->enable) {
+		printk(KERN_ERR DRV_NAME ": failed to ioremap MAC enable register\n");
+		err = -ENXIO;
+		goto err_remap2;
+	}
+	aup->mac_id = pdev->id;
 
-	if (port_num == 0) {
+	if (pdev->id == 0) {
 		if (prom_get_ethernet_addr(ethaddr) == 0)
 			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
 		else {
@@ -1133,7 +1129,7 @@ static struct net_device * au1000_probe(int port_num)
 		}
 
 		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
-	} else if (port_num == 1)
+	} else if (pdev->id == 1)
 		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
 
 	/*
@@ -1141,14 +1137,17 @@ static struct net_device * au1000_probe(int port_num)
 	 * to match those that are printed on their stickers
 	 */
 	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
-	dev->dev_addr[5] += port_num;
+	dev->dev_addr[5] += pdev->id;
 
 	*aup->enable = 0;
 	aup->mac_enabled = 0;
 
 	aup->mii_bus = mdiobus_alloc();
-	if (aup->mii_bus == NULL)
-		goto err_out;
+	if (aup->mii_bus == NULL) {
+		printk(KERN_ERR DRV_NAME ": failed to allocate mdiobus structure\n");
+		err = -ENOMEM;
+		goto err_mdiobus_alloc;
+	}
 
 	aup->mii_bus->priv = dev;
 	aup->mii_bus->read = au1000_mdiobus_read;
@@ -1159,7 +1158,6 @@ static struct net_device * au1000_probe(int port_num)
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	for(i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus->irq[i] = PHY_POLL;
-
 	/* if known, set corresponding PHY IRQs */
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
 # if defined(AU1XXX_PHY0_IRQ)
@@ -1171,11 +1169,14 @@ static struct net_device * au1000_probe(int port_num)
 		aup->mii_bus->irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
 # endif
 #endif
-	mdiobus_register(aup->mii_bus);
+	err = mdiobus_register(aup->mii_bus);
+	if (err) {
+		printk(KERN_ERR DRV_NAME " failed to register MDIO bus\n");
+		goto err_mdiobus_reg;
+	}
 
-	if (mii_probe(dev) != 0) {
+	if (mii_probe(dev) != 0)
 		goto err_out;
-	}
 
 	pDBfree = NULL;
 	/* setup the data buffer descriptors and attach a buffer to each one */
@@ -1207,7 +1208,7 @@ static struct net_device * au1000_probe(int port_num)
 		aup->tx_db_inuse[i] = pDB;
 	}
 
-	dev->base_addr = base;
+	dev->base_addr = base->start;
 	dev->irq = irq;
 	dev->netdev_ops = &au1000_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
@@ -1219,14 +1220,24 @@ static struct net_device * au1000_probe(int port_num)
 	 */
 	reset_mac(dev);
 
-	return dev;
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_ERR DRV_NAME "%s: Cannot register net device, aborting.\n",
+					dev->name);
+		goto err_out;
+	}
+	
+	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
+					dev->name, base->start, irq);
+	if (version_printed++ == 0)
+		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+
+	return 0;
 
 err_out:
-	if (aup->mii_bus != NULL) {
+	if (aup->mii_bus != NULL)
 		mdiobus_unregister(aup->mii_bus);
-		mdiobus_free(aup->mii_bus);
-	}
-
+	
 	/* here we should have a valid dev plus aup-> register addresses
 	 * so we can reset the mac properly.*/
 	reset_mac(dev);
@@ -1239,67 +1250,84 @@ err_out:
 		if (aup->tx_db_inuse[i])
 			ReleaseDB(aup, aup->tx_db_inuse[i]);
 	}
+err_mdiobus_reg:
+	mdiobus_free(aup->mii_bus);
+err_mdiobus_alloc:
+	iounmap(aup->enable);
+err_remap2:
+	iounmap(aup->mac);
+err_remap1:
 	dma_free_noncoherent(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
 			     (void *)aup->vaddr, aup->dma_addr);
-	unregister_netdev(dev);
+err_vaddr:
 	free_netdev(dev);
-	release_mem_region( base, MAC_IOSIZE);
-	release_mem_region(macen, 4);
-	return NULL;
+err_alloc:
+	release_mem_region(macen->start, resource_size(macen));
+err_request:
+	release_mem_region(base->start, resource_size(base));
+out:
+	return err;
 }
 
-/*
- * Setup the base address and interrupt of the Au1xxx ethernet macs
- * based on cpu type and whether the interface is enabled in sys_pinfunc
- * register. The last interface is enabled if SYS_PF_NI2 (bit 4) is 0.
- */
-static int __init au1000_init_module(void)
+static int __devexit au1000_remove(struct platform_device *pdev)
 {
-	int ni = (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
-	struct net_device *dev;
-	int i, found_one = 0;
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct au1000_private *aup = netdev_priv(dev);
+	int i;
+	struct resource *base, *macen;
 
-	num_ifs = NUM_ETH_INTERFACES - ni;
+	platform_set_drvdata(pdev, NULL);
+
+	unregister_netdev(dev);
+	mdiobus_unregister(aup->mii_bus);
+	mdiobus_free(aup->mii_bus);
+
+	for (i = 0; i < NUM_RX_DMA; i++)
+		if (aup->rx_db_inuse[i])
+			ReleaseDB(aup, aup->rx_db_inuse[i]);
+
+	for (i = 0; i < NUM_TX_DMA; i++)
+		if (aup->tx_db_inuse[i])
+			ReleaseDB(aup, aup->tx_db_inuse[i]);
+
+	dma_free_noncoherent(NULL, MAX_BUF_SIZE *
+			(NUM_TX_BUFFS + NUM_RX_BUFFS),
+			(void *)aup->vaddr, aup->dma_addr);
+
+	iounmap(aup->mac);
+	iounmap(aup->enable);
+
+	base = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	release_mem_region(base->start, resource_size(base));
+
+	macen = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	release_mem_region(macen->start, resource_size(macen));
+	
+	free_netdev(dev);
 
-	for(i = 0; i < num_ifs; i++) {
-		dev = au1000_probe(i);
-		iflist[i].dev = dev;
-		if (dev)
-			found_one++;
-	}
-	if (!found_one)
-		return -ENODEV;
 	return 0;
 }
 
-static void __exit au1000_cleanup_module(void)
+static struct platform_driver au1000_eth_driver = {
+	.probe  = au1000_probe,
+	.remove = __devexit_p(au1000_remove),
+	.driver = {
+		.name   = "au1000-eth",
+		.owner  = THIS_MODULE,
+	},
+};
+MODULE_ALIAS("platform:au1000-eth");
+
+
+static int __init au1000_init_module(void)
+{
+	return platform_driver_register(&au1000_eth_driver);
+}
+
+static void __exit au1000_exit_module(void)
 {
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
-			dma_free_noncoherent(NULL, MAX_BUF_SIZE *
-					     (NUM_TX_BUFFS + NUM_RX_BUFFS),
-					     (void *)aup->vaddr, aup->dma_addr);
-			release_mem_region(dev->base_addr, MAC_IOSIZE);
-			release_mem_region(CPHYSADDR(iflist[i].macen_addr), 4);
-			free_netdev(dev);
-		}
-	}
+	platform_driver_unregister(&au1000_eth_driver);
 }
 
 module_init(au1000_init_module);
-module_exit(au1000_cleanup_module);
+module_exit(au1000_exit_module);
