From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/4] forcedeth: fix power management support
Date: Mon, 21 May 2007 20:23:04 -0400
Message-ID: <465237E8.1060005@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020706060506080500020609"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:15450 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512AbXEVDIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 23:08:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020706060506080500020609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the power management functions. It includes lowering 
the phy speed to conserve power.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------020706060506080500020609
Content-Type: text/plain;
 name="patch-forcedeth-pm"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-pm"

--- old/drivers/net/forcedeth.c	2007-05-01 15:32:03.000000000 -0400
+++ new/drivers/net/forcedeth.c	2007-05-21 19:54:39.000000000 -0400
@@ -812,6 +812,10 @@
 
 	/* flow control */
 	u32 pause_flags;
+
+	/* power saved state */
+	u32 saved_config_space[64];
+	u32 saved_phyinterface;
 };
 
 /*
@@ -5344,42 +5348,137 @@
 }
 
 #ifdef CONFIG_PM
+static void nv_set_low_speed(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	int adv = 0;
+	int lpa = 0;
+	int adv_lpa, bmcr, tries = 0;
+	int mii_status;
+	u32 control_1000;
+
+	/* lower the speed if we are in 1000Mbps autoneg */
+	if (np->autoneg == 0 || ((np->linkspeed & 0xFFF) != NVREG_LINKSPEED_1000))
+		return;
+
+	adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
+	lpa = mii_rw(dev, np->phyaddr, MII_LPA, MII_READ);
+	control_1000 = mii_rw(dev, np->phyaddr, MII_CTRL1000, MII_READ);
+
+	adv_lpa = lpa & adv;
+
+	/* lower the speed if partner has advertised other speeds */
+	if ((adv_lpa & LPA_10FULL) || (adv_lpa & LPA_10HALF)) {
+		adv &= ~(ADVERTISE_100BASE4 | ADVERTISE_100FULL | ADVERTISE_100HALF);
+		control_1000 &= ~ADVERTISE_1000FULL;
+	} else if ((adv_lpa & LPA_100FULL) || (adv_lpa & LPA_100HALF)) {
+		control_1000 &= ~ADVERTISE_1000FULL;
+	} else
+		return;
+
+	/* set new advertisements */
+	mii_rw(dev, np->phyaddr, MII_ADVERTISE, adv);
+	mii_rw(dev, np->phyaddr, MII_CTRL1000, control_1000);
+
+	bmcr = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
+	if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
+		bmcr |= BMCR_ANENABLE;
+		/* reset the phy in order for settings to stick,
+		 * and cause autoneg to start */
+		if (phy_reset(dev, bmcr)) {
+			printk(KERN_INFO "%s: phy reset failed\n", dev->name);
+			return;
+		}
+	} else {
+		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
+		mii_rw(dev, np->phyaddr, MII_BMCR, bmcr);
+	}
+	mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
+	mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
+	while (!(mii_status & BMSR_ANEGCOMPLETE)) {
+		msleep(100);
+		mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
+		if (tries++ > 50)
+			break;
+	}
+
+	nv_update_linkspeed(dev);
+
+	return;
+}
+
 static int nv_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	int i;
 
-	if (!netif_running(dev))
-		goto out;
+	dprintk(KERN_DEBUG "forcedeth: nv_suspend\n");
+
+	if (netif_running(dev)) {
+		netif_device_detach(dev);
 
-	netif_device_detach(dev);
+		/* bring down the adapter */
+		nv_close(dev);
+	}
 
-	// Gross.
-	nv_close(dev);
+	/* set phy to a lower speed to conserve power */
+	if (!np->mac_in_use)
+		nv_set_low_speed(dev);
 
 	pci_save_state(pdev);
+
+	/* save any device state */
+	np->saved_phyinterface = readl(base + NvRegPhyInterface);
+	for (i = 0; i < 64; i++) {
+		pci_read_config_dword(pdev, i*4, &np->saved_config_space[i]);
+	}
+
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
+
 	return 0;
 }
 
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
 	int rc = 0;
+	int i;
+	u32 txreg;
 
-	if (!netif_running(dev))
-		goto out;
-
-	netif_device_attach(dev);
+	dprintk(KERN_DEBUG "forcedeth: nv_resume\n");
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+
+	/* restore saved config space */
+	for (i = 0; i < 64; i++) {
+		pci_write_config_dword(pdev, i*4, np->saved_config_space[i]);
+	}
+
 	pci_enable_wake(pdev, PCI_D0, 0);
 
-	rc = nv_open(dev);
-out:
+	/* restore saved driver state */
+	txreg = readl(base + NvRegTransmitPoll);
+	txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
+	writel(txreg, base + NvRegTransmitPoll);
+	writel(np->saved_phyinterface, base + NvRegPhyInterface);
+	writel(np->orig_mac[0], base + NvRegMacAddrA);
+	writel(np->orig_mac[1], base + NvRegMacAddrB);
+
+	/* re-initialize the phy */
+	phy_init(dev);
+
+	if (netif_running(dev)) {
+		netif_device_attach(dev);
+
+		/* bring up the adapter */
+		rc = nv_open(dev);
+	}
 	return rc;
 }
 #else

--------------020706060506080500020609--
