From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC] IXP4xx: Add PHYLIB support to Ethernet driver.
Date: Sun, 21 Dec 2008 02:14:33 +0100
Message-ID: <m3prjmba86.fsf@maximus.localdomain>
References: <m3vdtebadt.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37189 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbYLUBOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 20:14:53 -0500
In-Reply-To: <m3vdtebadt.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Sun\, 21 Dec 2008 02\:11\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few patches I'm posting for review only.

Not for operational use.

IXP4xx: Add PHYLIB support to Ethernet driver.
    
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -51,7 +51,7 @@ config EP93XX_ETH
 config IXP4XX_ETH
 	tristate "Intel IXP4xx Ethernet support"
 	depends on ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR
-	select MII
+	select PHYLIB
 	help
 	  Say Y here if you want to use built-in Ethernet ports
 	  on IXP4xx processor.
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index d837328..cd69c9f 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -30,7 +30,7 @@
 #include <linux/etherdevice.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
-#include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/platform_device.h>
 #include <mach/npe.h>
 #include <mach/qmgr.h>
@@ -59,7 +59,6 @@
 #define NAPI_WEIGHT		16
 #define MDIO_INTERVAL		(3 * HZ)
 #define MAX_MDIO_RETRIES	100 /* microseconds, typically 30 cycles */
-#define MAX_MII_RESET_RETRIES	100 /* mdio_read() cycles, typically 4 */
 #define MAX_CLOSE_WAIT		1000 /* microseconds, typically 2-3 cycles */
 
 #define NPE_ID(port_id)		((port_id) >> 4)
@@ -164,14 +163,13 @@ struct port {
 	struct npe *npe;
 	struct net_device *netdev;
 	struct napi_struct napi;
-	struct mii_if_info mii;
-	struct delayed_work mdio_thread;
+	struct phy_device *phydev;
 	struct eth_plat_info *plat;
 	buffer_t *rx_buff_tab[RX_DESCS], *tx_buff_tab[TX_DESCS];
 	struct desc *desc_tab;	/* coherent */
 	u32 desc_tab_phys;
 	int id;			/* logical port ID */
-	u16 mii_bmcr;
+	int speed, duplex;
 };
 
 /* NPE message structure */
@@ -242,19 +240,20 @@ static inline void memcpy_swab32(u32 *dest, u32 *src, int cnt)
 
 static spinlock_t mdio_lock;
 static struct eth_regs __iomem *mdio_regs; /* mdio command and status only */
+struct mii_bus *mdio_bus;
 static int ports_open;
 static struct port *npe_port_tab[MAX_NPES];
 static struct dma_pool *dma_pool;
 
 
-static u16 mdio_cmd(struct net_device *dev, int phy_id, int location,
-		    int write, u16 cmd)
+static int ixp4xx_mdio_cmd(struct mii_bus *bus, int phy_id, int location,
+			   int write, u16 cmd)
 {
 	int cycles = 0;
 
 	if (__raw_readl(&mdio_regs->mdio_command[3]) & 0x80) {
-		printk(KERN_ERR "%s: MII not ready to transmit\n", dev->name);
-		return 0;
+		printk(KERN_ERR "%s: MII not ready to transmit\n", bus->name);
+		return -1;
 	}
 
 	if (write) {
@@ -273,107 +272,119 @@ static u16 mdio_cmd(struct net_device *dev, int phy_id, int location,
 	}
 
 	if (cycles == MAX_MDIO_RETRIES) {
-		printk(KERN_ERR "%s: MII write failed\n", dev->name);
-		return 0;
+		printk(KERN_ERR "%s #%i: MII write failed\n", bus->name,
+		       phy_id);
+		return -1;
 	}
 
 #if DEBUG_MDIO
-	printk(KERN_DEBUG "%s: mdio_cmd() took %i cycles\n", dev->name,
-	       cycles);
+	printk(KERN_DEBUG "%s #%i: mdio_%s() took %i cycles\n", bus->name,
+	       phy_id, write ? "write" : "read", cycles);
 #endif
 
 	if (write)
 		return 0;
 
 	if (__raw_readl(&mdio_regs->mdio_status[3]) & 0x80) {
-		printk(KERN_ERR "%s: MII read failed\n", dev->name);
-		return 0;
+#if DEBUG_MDIO
+		printk(KERN_DEBUG "%s #%i: MII read failed\n", bus->name,
+		       phy_id);
+#endif
+		return 0xFFFF; /* don't return error */
 	}
 
 	return (__raw_readl(&mdio_regs->mdio_status[0]) & 0xFF) |
-		(__raw_readl(&mdio_regs->mdio_status[1]) << 8);
+		((__raw_readl(&mdio_regs->mdio_status[1]) & 0xFF) << 8);
 }
 
-static int mdio_read(struct net_device *dev, int phy_id, int location)
+static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int location)
 {
 	unsigned long flags;
-	u16 val;
+	int ret;
 
 	spin_lock_irqsave(&mdio_lock, flags);
-	val = mdio_cmd(dev, phy_id, location, 0, 0);
+	ret = ixp4xx_mdio_cmd(bus, phy_id, location, 0, 0);
 	spin_unlock_irqrestore(&mdio_lock, flags);
-	return val;
+#if DEBUG_MDIO
+	printk(KERN_DEBUG "%s #%i: MII read [%i] -> 0x%X\n", bus->name,
+	       phy_id, location, ret);
+#endif
+	return ret;
 }
 
-static void mdio_write(struct net_device *dev, int phy_id, int location,
-		       int val)
+static int ixp4xx_mdio_write(struct mii_bus *bus, int phy_id, int location,
+			     u16 val)
 {
 	unsigned long flags;
+	int ret;
 
 	spin_lock_irqsave(&mdio_lock, flags);
-	mdio_cmd(dev, phy_id, location, 1, val);
+	ret = ixp4xx_mdio_cmd(bus, phy_id, location, 1, val);
 	spin_unlock_irqrestore(&mdio_lock, flags);
+#if DEBUG_MDIO
+	printk(KERN_DEBUG "%s #%i: MII read [%i] <- 0x%X, err = %i\n",
+	       bus->name, phy_id, location, val, ret);
+#endif
+	return ret;
 }
 
-static void phy_reset(struct net_device *dev, int phy_id)
+static int ixp4xx_mdio_register(void)
 {
-	struct port *port = netdev_priv(dev);
-	int cycles = 0;
+	int err;
+
+	if (!(mdio_bus = mdiobus_alloc()))
+		return -ENOMEM;
 
-	mdio_write(dev, phy_id, MII_BMCR, port->mii_bmcr | BMCR_RESET);
+	/* All MII PHY accesses use NPE-B Ethernet registers */
+	spin_lock_init(&mdio_lock);
+	mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
+	__raw_writel(DEFAULT_CORE_CNTRL, &mdio_regs->core_control);
 
-	while (cycles < MAX_MII_RESET_RETRIES) {
-		if (!(mdio_read(dev, phy_id, MII_BMCR) & BMCR_RESET)) {
-#if DEBUG_MDIO
-			printk(KERN_DEBUG "%s: phy_reset() took %i cycles\n",
-			       dev->name, cycles);
-#endif
-			return;
-		}
-		udelay(1);
-		cycles++;
-	}
+	mdio_bus->name = "IXP4xx MII Bus";
+	mdio_bus->read = &ixp4xx_mdio_read;
+	mdio_bus->write = &ixp4xx_mdio_write;
+	strcpy(mdio_bus->id, "0");
 
-	printk(KERN_ERR "%s: MII reset failed\n", dev->name);
+	if ((err = mdiobus_register(mdio_bus)))
+		mdiobus_free(mdio_bus);
+	return err;
 }
 
-static void eth_set_duplex(struct port *port)
+static void ixp4xx_mdio_remove(void)
 {
-	if (port->mii.full_duplex)
-		__raw_writel(DEFAULT_TX_CNTRL0 & ~TX_CNTRL0_HALFDUPLEX,
-			     &port->regs->tx_control[0]);
-	else
-		__raw_writel(DEFAULT_TX_CNTRL0 | TX_CNTRL0_HALFDUPLEX,
-			     &port->regs->tx_control[0]);
+	mdiobus_unregister(mdio_bus);
+	mdiobus_free(mdio_bus);
 }
 
 
-static void phy_check_media(struct port *port, int init)
+static void ixp4xx_adjust_link(struct net_device *dev)
 {
-	if (mii_check_media(&port->mii, 1, init))
-		eth_set_duplex(port);
-	if (port->mii.force_media) { /* mii_check_media() doesn't work */
-		struct net_device *dev = port->netdev;
-		int cur_link = mii_link_ok(&port->mii);
-		int prev_link = netif_carrier_ok(dev);
-
-		if (!prev_link && cur_link) {
-			printk(KERN_INFO "%s: link up\n", dev->name);
-			netif_carrier_on(dev);
-		} else if (prev_link && !cur_link) {
+	struct port *port = netdev_priv(dev);
+	struct phy_device *phydev = port->phydev;
+
+	if (!phydev->link) {
+		if (port->speed) {
+			port->speed = 0;
 			printk(KERN_INFO "%s: link down\n", dev->name);
-			netif_carrier_off(dev);
 		}
+		return;
 	}
-}
 
+	if (port->speed == phydev->speed && port->duplex == phydev->duplex)
+		return;
 
-static void mdio_thread(struct work_struct *work)
-{
-	struct port *port = container_of(work, struct port, mdio_thread.work);
+	port->speed = phydev->speed;
+	port->duplex = phydev->duplex;
 
-	phy_check_media(port, 0);
-	schedule_delayed_work(&port->mdio_thread, MDIO_INTERVAL);
+	if (port->duplex)
+		__raw_writel(DEFAULT_TX_CNTRL0 & ~TX_CNTRL0_HALFDUPLEX,
+			     &port->regs->tx_control[0]);
+	else
+		__raw_writel(DEFAULT_TX_CNTRL0 | TX_CNTRL0_HALFDUPLEX,
+			     &port->regs->tx_control[0]);
+
+	printk(KERN_INFO "%s: link up, speed %u Mb/s, %s duplex\n",
+	       dev->name, port->speed, port->duplex ? "full" : "half");
 }
 
 
@@ -778,16 +789,9 @@ static void eth_set_mcast_list(struct net_device *dev)
 
 static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	struct port *port = netdev_priv(dev);
-	unsigned int duplex_chg;
-	int err;
-
 	if (!netif_running(dev))
 		return -EINVAL;
-	err = generic_mii_ioctl(&port->mii, if_mii(req), cmd, &duplex_chg);
-	if (duplex_chg)
-		eth_set_duplex(port);
-	return err;
+	return -EINVAL;
 }
 
 
@@ -939,8 +943,6 @@ static int eth_open(struct net_device *dev)
 		}
 	}
 
-	mdio_write(dev, port->plat->phy, MII_BMCR, port->mii_bmcr);
-
 	memset(&msg, 0, sizeof(msg));
 	msg.cmd = NPE_VLAN_SETRXQOSENTRY;
 	msg.eth_id = port->id;
@@ -978,6 +980,9 @@ static int eth_open(struct net_device *dev)
 		return err;
 	}
 
+	port->speed = 0;	/* force "link up" message */
+	phy_start(port->phydev);
+
 	for (i = 0; i < ETH_ALEN; i++)
 		__raw_writel(dev->dev_addr[i], &port->regs->hw_addr[i]);
 	__raw_writel(0x08, &port->regs->random_seed);
@@ -1005,10 +1010,8 @@ static int eth_open(struct net_device *dev)
 	__raw_writel(DEFAULT_RX_CNTRL0, &port->regs->rx_control[0]);
 
 	napi_enable(&port->napi);
-	phy_check_media(port, 1);
 	eth_set_mcast_list(dev);
 	netif_start_queue(dev);
-	schedule_delayed_work(&port->mdio_thread, MDIO_INTERVAL);
 
 	qmgr_set_irq(port->plat->rxq, QUEUE_IRQ_SRC_NOT_EMPTY,
 		     eth_rx_irq, dev);
@@ -1099,14 +1102,10 @@ static int eth_close(struct net_device *dev)
 		printk(KERN_CRIT "%s: unable to disable loopback\n",
 		       dev->name);
 
-	port->mii_bmcr = mdio_read(dev, port->plat->phy, MII_BMCR) &
-		~(BMCR_RESET | BMCR_PDOWN); /* may have been altered */
-	mdio_write(dev, port->plat->phy, MII_BMCR,
-		   port->mii_bmcr | BMCR_PDOWN);
+	phy_stop(port->phydev);
 
 	if (!ports_open)
 		qmgr_disable_irq(TXDONE_QUEUE);
-	cancel_rearming_delayed_work(&port->mdio_thread);
 	destroy_queues(port);
 	release_queues(port);
 	return 0;
@@ -1118,6 +1117,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	struct net_device *dev;
 	struct eth_plat_info *plat = pdev->dev.platform_data;
 	u32 regs_phys;
+	char phy_id[BUS_ID_SIZE];
 	int err;
 
 	if (!(dev = alloc_etherdev(sizeof(struct port))))
@@ -1183,22 +1183,19 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	__raw_writel(DEFAULT_CORE_CNTRL, &port->regs->core_control);
 	udelay(50);
 
-	port->mii.dev = dev;
-	port->mii.mdio_read = mdio_read;
-	port->mii.mdio_write = mdio_write;
-	port->mii.phy_id = plat->phy;
-	port->mii.phy_id_mask = 0x1F;
-	port->mii.reg_num_mask = 0x1F;
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, "0", plat->phy);
+	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
+				   PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(port->phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(port->phydev);
+	}
+
+	port->phydev->irq = PHY_POLL;
 
 	printk(KERN_INFO "%s: MII PHY %i on %s\n", dev->name, plat->phy,
 	       npe_name(port->npe));
 
-	phy_reset(dev, plat->phy);
-	port->mii_bmcr = mdio_read(dev, plat->phy, MII_BMCR) &
-		~(BMCR_RESET | BMCR_PDOWN);
-	mdio_write(dev, plat->phy, MII_BMCR, port->mii_bmcr | BMCR_PDOWN);
-
-	INIT_DELAYED_WORK(&port->mdio_thread, mdio_thread);
 	return 0;
 
 err_unreg:
@@ -1232,20 +1229,19 @@ static struct platform_driver ixp4xx_eth_driver = {
 
 static int __init eth_init_module(void)
 {
+	int err;
 	if (!(ixp4xx_read_feature_bits() & IXP4XX_FEATURE_NPEB_ETH0))
 		return -ENOSYS;
 
-	/* All MII PHY accesses use NPE-B Ethernet registers */
-	spin_lock_init(&mdio_lock);
-	mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
-	__raw_writel(DEFAULT_CORE_CNTRL, &mdio_regs->core_control);
-
+	if ((err = ixp4xx_mdio_register()))
+		return err;
 	return platform_driver_register(&ixp4xx_eth_driver);
 }
 
 static void __exit eth_cleanup_module(void)
 {
 	platform_driver_unregister(&ixp4xx_eth_driver);
+	ixp4xx_mdio_remove();
 }
 
 MODULE_AUTHOR("Krzysztof Halasa");

-- 
Krzysztof Halasa
