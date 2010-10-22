From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/5] netdev: bfin_mac: push settings to platform resources
Date: Fri, 22 Oct 2010 01:59:17 -0400
Message-ID: <1287727161-24671-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:40744 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183Ab0JVF7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Oct 2010 01:59:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Move all the pin settings out of the Kconfig and into the platform
resources (MII vs RMII).  This clean up also lets us push out the
phy settings so that board porters may control the layout.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/Kconfig      |    8 ---
 drivers/net/bfin_mac.c   |  145 ++++++++++++++++++++++++++++++----------------
 drivers/net/bfin_mac.h   |    2 +
 include/linux/bfin_mac.h |   29 +++++++++
 4 files changed, 125 insertions(+), 59 deletions(-)
 create mode 100644 include/linux/bfin_mac.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d24f54b..fb5b77a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -880,14 +880,6 @@ config BFIN_RX_DESC_NUM
 	help
 	  Set the number of buffer packets used in driver.
 
-config BFIN_MAC_RMII
-	bool "RMII PHY Interface"
-	depends on BFIN_MAC
-	default y if BFIN527_EZKIT
-	default n if BFIN537_STAMP
-	help
-	  Use Reduced PHY MII Interface
-
 config BFIN_MAC_USE_HWSTAMP
 	bool "Use IEEE 1588 hwstamp"
 	depends on BFIN_MAC && BF518
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 7a0e415..9dc445e 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1,7 +1,7 @@
 /*
  * Blackfin On-Chip MAC Driver
  *
- * Copyright 2004-2007 Analog Devices Inc.
+ * Copyright 2004-2010 Analog Devices Inc.
  *
  * Enter bugs at http://blackfin.uclinux.org/
  *
@@ -23,7 +23,6 @@
 #include <linux/device.h>
 #include <linux/spinlock.h>
 #include <linux/mii.h>
-#include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -75,12 +74,6 @@ static struct net_dma_desc_tx *current_tx_ptr;
 static struct net_dma_desc_tx *tx_desc;
 static struct net_dma_desc_rx *rx_desc;
 
-#if defined(CONFIG_BFIN_MAC_RMII)
-static u16 pin_req[] = P_RMII0;
-#else
-static u16 pin_req[] = P_MII0;
-#endif
-
 static void desc_list_free(void)
 {
 	struct net_dma_desc_rx *r;
@@ -346,23 +339,23 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 		}
 
 		if (phydev->speed != lp->old_speed) {
-#if defined(CONFIG_BFIN_MAC_RMII)
-			u32 opmode = bfin_read_EMAC_OPMODE();
-			switch (phydev->speed) {
-			case 10:
-				opmode |= RMII_10;
-				break;
-			case 100:
-				opmode &= ~(RMII_10);
-				break;
-			default:
-				printk(KERN_WARNING
-					"%s: Ack!  Speed (%d) is not 10/100!\n",
-					DRV_NAME, phydev->speed);
-				break;
+			if (phydev->interface == PHY_INTERFACE_MODE_RMII) {
+				u32 opmode = bfin_read_EMAC_OPMODE();
+				switch (phydev->speed) {
+				case 10:
+					opmode |= RMII_10;
+					break;
+				case 100:
+					opmode &= ~RMII_10;
+					break;
+				default:
+					printk(KERN_WARNING
+						"%s: Ack!  Speed (%d) is not 10/100!\n",
+						DRV_NAME, phydev->speed);
+					break;
+				}
+				bfin_write_EMAC_OPMODE(opmode);
 			}
-			bfin_write_EMAC_OPMODE(opmode);
-#endif
 
 			new_state = 1;
 			lp->old_speed = phydev->speed;
@@ -391,7 +384,7 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 /* MDC  = 2.5 MHz */
 #define MDC_CLK 2500000
 
-static int mii_probe(struct net_device *dev)
+static int mii_probe(struct net_device *dev, int phy_mode)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
@@ -410,8 +403,8 @@ static int mii_probe(struct net_device *dev)
 	sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
-	/* search for connect PHY device */
-	for (i = 0; i < PHY_MAX_ADDR; i++) {
+	/* search for connected PHY device */
+	for (i = 0; i < PHY_MAX_ADDR; ++i) {
 		struct phy_device *const tmp_phydev = lp->mii_bus->phy_map[i];
 
 		if (!tmp_phydev)
@@ -428,13 +421,14 @@ static int mii_probe(struct net_device *dev)
 		return -ENODEV;
 	}
 
-#if defined(CONFIG_BFIN_MAC_RMII)
-	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, PHY_INTERFACE_MODE_RMII);
-#else
+	if (phy_mode != PHY_INTERFACE_MODE_RMII &&
+		phy_mode != PHY_INTERFACE_MODE_MII) {
+		printk(KERN_INFO "%s: Invalid phy interface mode\n", dev->name);
+		return -EINVAL;
+	}
+
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, PHY_INTERFACE_MODE_MII);
-#endif
+			0, phy_mode);
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
@@ -569,6 +563,8 @@ static const struct ethtool_ops bfin_mac_ethtool_ops = {
 /**************************************************************************/
 void setup_system_regs(struct net_device *dev)
 {
+	struct bfin_mac_local *lp = netdev_priv(dev);
+	int i;
 	unsigned short sysctl;
 
 	/*
@@ -576,6 +572,15 @@ void setup_system_regs(struct net_device *dev)
 	 * Configure checksum support and rcve frame word alignment
 	 */
 	sysctl = bfin_read_EMAC_SYSCTL();
+	/*
+	 * check if interrupt is requested for any PHY,
+	 * enable PHY interrupt only if needed
+	 */
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		if (lp->mii_bus->irq[i] != PHY_POLL)
+			break;
+	if (i < PHY_MAX_ADDR)
+		sysctl |= PHYIE;
 	sysctl |= RXDWA;
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	sysctl |= RXCKS;
@@ -1202,7 +1207,7 @@ static void bfin_mac_disable(void)
 /*
  * Enable Interrupts, Receive, and Transmit
  */
-static int bfin_mac_enable(void)
+static int bfin_mac_enable(struct phy_device *phydev)
 {
 	int ret;
 	u32 opmode;
@@ -1232,12 +1237,13 @@ static int bfin_mac_enable(void)
 		opmode |= DRO | DC | PSF;
 	opmode |= RE;
 
-#if defined(CONFIG_BFIN_MAC_RMII)
-	opmode |= RMII; /* For Now only 100MBit are supported */
+	if (phydev->interface == PHY_INTERFACE_MODE_RMII) {
+		opmode |= RMII; /* For Now only 100MBit are supported */
 #if (defined(CONFIG_BF537) || defined(CONFIG_BF536)) && CONFIG_BF_REV_0_2
-	opmode |= TE;
-#endif
+		opmode |= TE;
 #endif
+	}
+
 	/* Turn on the EMAC rx */
 	bfin_write_EMAC_OPMODE(opmode);
 
@@ -1269,7 +1275,7 @@ static void bfin_mac_timeout(struct net_device *dev)
 	if (netif_queue_stopped(lp->ndev))
 		netif_wake_queue(lp->ndev);
 
-	bfin_mac_enable();
+	bfin_mac_enable(lp->phydev);
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -1341,11 +1347,19 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 
 static int bfin_mac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
 		return bfin_mac_hwtstamp_ioctl(netdev, ifr, cmd);
 	default:
-		return -EOPNOTSUPP;
+		if (lp->phydev)
+			return phy_mii_ioctl(lp->phydev, ifr, cmd);
+		else
+			return -EOPNOTSUPP;
 	}
 }
 
@@ -1393,7 +1407,7 @@ static int bfin_mac_open(struct net_device *dev)
 	setup_mac_addr(dev->dev_addr);
 
 	bfin_mac_disable();
-	ret = bfin_mac_enable();
+	ret = bfin_mac_enable(lp->phydev);
 	if (ret)
 		return ret;
 	pr_debug("hardware init finished\n");
@@ -1449,6 +1463,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	struct bfin_mac_local *lp;
 	struct platform_device *pd;
+	struct bfin_mii_bus_platform_data *mii_bus_data;
 	int rc;
 
 	ndev = alloc_etherdev(sizeof(struct bfin_mac_local));
@@ -1500,11 +1515,12 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	if (!lp->mii_bus) {
 		dev_err(&pdev->dev, "Cannot get mii_bus!\n");
 		rc = -ENODEV;
-		goto out_err_mii_bus_probe;
+		goto out_err_probe_mac;
 	}
 	lp->mii_bus->priv = ndev;
+	mii_bus_data = pd->dev.platform_data;
 
-	rc = mii_probe(ndev);
+	rc = mii_probe(ndev, mii_bus_data->phy_mode);
 	if (rc) {
 		dev_err(&pdev->dev, "MII Probe failed!\n");
 		goto out_err_mii_probe;
@@ -1551,8 +1567,6 @@ out_err_request_irq:
 out_err_mii_probe:
 	mdiobus_unregister(lp->mii_bus);
 	mdiobus_free(lp->mii_bus);
-out_err_mii_bus_probe:
-	peripheral_free_list(pin_req);
 out_err_probe_mac:
 	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
@@ -1575,8 +1589,6 @@ static int __devexit bfin_mac_remove(struct platform_device *pdev)
 
 	free_netdev(ndev);
 
-	peripheral_free_list(pin_req);
-
 	return 0;
 }
 
@@ -1622,12 +1634,21 @@ static int bfin_mac_resume(struct platform_device *pdev)
 static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 {
 	struct mii_bus *miibus;
+	struct bfin_mii_bus_platform_data *mii_bus_pd;
+	const unsigned short *pin_req;
 	int rc, i;
 
+	mii_bus_pd = dev_get_platdata(&pdev->dev);
+	if (!mii_bus_pd) {
+		dev_err(&pdev->dev, "No peripherals in platform data!\n");
+		return -EINVAL;
+	}
+
 	/*
 	 * We are setting up a network card,
 	 * so set the GPIO pins to Ethernet mode
 	 */
+	pin_req = mii_bus_pd->mac_peripherals;
 	rc = peripheral_request_list(pin_req, DRV_NAME);
 	if (rc) {
 		dev_err(&pdev->dev, "Requesting peripherals failed!\n");
@@ -1644,13 +1665,30 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 
 	miibus->parent = &pdev->dev;
 	miibus->name = "bfin_mii_bus";
+	miibus->phy_mask = mii_bus_pd->phy_mask;
+
 	snprintf(miibus->id, MII_BUS_ID_SIZE, "0");
 	miibus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	if (miibus->irq == NULL)
-		goto out_err_alloc;
-	for (i = 0; i < PHY_MAX_ADDR; ++i)
+	if (!miibus->irq)
+		goto out_err_irq_alloc;
+
+	for (i = rc; i < PHY_MAX_ADDR; ++i)
 		miibus->irq[i] = PHY_POLL;
 
+	rc = clamp(mii_bus_pd->phydev_number, 0, PHY_MAX_ADDR);
+	if (rc != mii_bus_pd->phydev_number)
+		dev_err(&pdev->dev, "Invalid number (%i) of phydevs\n",
+			mii_bus_pd->phydev_number);
+	for (i = 0; i < rc; ++i) {
+		unsigned short phyaddr = mii_bus_pd->phydev_data[i].addr;
+		if (phyaddr < PHY_MAX_ADDR)
+			miibus->irq[phyaddr] = mii_bus_pd->phydev_data[i].irq;
+		else
+			dev_err(&pdev->dev,
+				"Invalid PHY address %i for phydev %i\n",
+				phyaddr, i);
+	}
+
 	rc = mdiobus_register(miibus);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
@@ -1662,6 +1700,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 
 out_err_mdiobus_register:
 	kfree(miibus->irq);
+out_err_irq_alloc:
 	mdiobus_free(miibus);
 out_err_alloc:
 	peripheral_free_list(pin_req);
@@ -1672,11 +1711,15 @@ out_err_alloc:
 static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
 {
 	struct mii_bus *miibus = platform_get_drvdata(pdev);
+	struct bfin_mii_bus_platform_data *mii_bus_pd =
+		dev_get_platdata(&pdev->dev);
+
 	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
 	kfree(miibus->irq);
 	mdiobus_free(miibus);
-	peripheral_free_list(pin_req);
+	peripheral_free_list(mii_bus_pd->mac_peripherals);
+
 	return 0;
 }
 
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 04e4050..aed68be 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -14,6 +14,8 @@
 #include <linux/clocksource.h>
 #include <linux/timecompare.h>
 #include <linux/timer.h>
+#include <linux/etherdevice.h>
+#include <linux/bfin_mac.h>
 
 #define BFIN_MAC_CSUM_OFFLOAD
 
diff --git a/include/linux/bfin_mac.h b/include/linux/bfin_mac.h
new file mode 100644
index 0000000..904dec7
--- /dev/null
+++ b/include/linux/bfin_mac.h
@@ -0,0 +1,29 @@
+/*
+ * Blackfin On-Chip MAC Driver
+ *
+ * Copyright 2004-2010 Analog Devices Inc.
+ *
+ * Enter bugs at http://blackfin.uclinux.org/
+ *
+ * Licensed under the GPL-2 or later.
+ */
+
+#ifndef _LINUX_BFIN_MAC_H_
+#define _LINUX_BFIN_MAC_H_
+
+#include <linux/phy.h>
+
+struct bfin_phydev_platform_data {
+	unsigned short addr;
+	int irq;
+};
+
+struct bfin_mii_bus_platform_data {
+	int phydev_number;
+	struct bfin_phydev_platform_data *phydev_data;
+	const unsigned short *mac_peripherals;
+	int phy_mode;
+	unsigned int phy_mask;
+};
+
+#endif
-- 
1.7.3.1

