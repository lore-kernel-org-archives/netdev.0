From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [4/5] [v2] pasemi_mac: phy support
Date: Wed, 18 Apr 2007 01:27:21 -0500
Message-ID: <20070418062721.GE11308@lixom.net>
References: <20070416061654.GB19783@lixom.net> <20070418062451.GA11308@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:37188 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016AbXDRGJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 02:09:01 -0400
Content-Disposition: inline
In-Reply-To: <20070418062451.GA11308@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PHY support for pasemi_mac. Also add msg_enable flags for future
disablement of the link messages.

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: powerpc/drivers/net/pasemi_mac.c
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.c
+++ powerpc/drivers/net/pasemi_mac.c
@@ -594,6 +592,110 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	return IRQ_HANDLED;
 }
 
+static void pasemi_adjust_link(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	int msg;
+	unsigned int flags;
+	unsigned int new_flags;
+
+	if (!mac->phydev->link) {
+		/* If no link, MAC speed settings don't matter. Just report
+		 * link down and return.
+		 */
+		if (mac->link && netif_msg_link(mac))
+			printk(KERN_INFO "%s: Link is down.\n", dev->name);
+
+		netif_carrier_off(dev);
+		mac->link = 0;
+
+		return;
+	} else
+		netif_carrier_on(dev);
+
+	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
+	new_flags = flags & ~(PAS_MAC_CFG_PCFG_HD | PAS_MAC_CFG_PCFG_SPD_M);
+
+	if (!mac->phydev->duplex)
+		new_flags |= PAS_MAC_CFG_PCFG_HD;
+
+	switch (mac->phydev->speed) {
+	case 1000:
+		new_flags |= PAS_MAC_CFG_PCFG_SPD_1G;
+		break;
+	case 100:
+		new_flags |= PAS_MAC_CFG_PCFG_SPD_100M;
+		break;
+	case 10:
+		new_flags |= PAS_MAC_CFG_PCFG_SPD_10M;
+		break;
+	default:
+		printk("Unsupported speed %d\n", mac->phydev->speed);
+	}
+
+	/* Print on link or speed/duplex change */
+	msg = mac->link != mac->phydev->link || flags != new_flags;
+
+	mac->duplex = mac->phydev->duplex;
+	mac->speed = mac->phydev->speed;
+	mac->link = mac->phydev->link;
+
+	if (new_flags != flags)
+		pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, new_flags);
+
+	if (msg && netif_msg_link(mac))
+		printk(KERN_INFO "%s: Link is up at %d Mbps, %s duplex.\n",
+		       dev->name, mac->speed, mac->duplex ? "full" : "half");
+}
+
+static int pasemi_mac_phy_init(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	struct device_node *dn, *phy_dn;
+	struct phy_device *phydev;
+	unsigned int phy_id;
+	const phandle *ph;
+	const unsigned int *prop;
+	struct resource r;
+	int ret;
+
+	dn = pci_device_to_OF_node(mac->pdev);
+	ph = get_property(dn, "phy-handle", NULL);
+	if (!ph)
+		return -ENODEV;
+	phy_dn = of_find_node_by_phandle(*ph);
+
+	prop = get_property(phy_dn, "reg", NULL);
+	ret = of_address_to_resource(phy_dn->parent, 0, &r);
+	if (ret)
+		goto err;
+
+	phy_id = *prop;
+	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, (int)r.start, phy_id);
+
+	of_node_put(phy_dn);
+
+	mac->link = 0;
+	mac->speed = 0;
+	mac->duplex = -1;
+
+	phydev = phy_connect(dev, mac->phy_id, &pasemi_adjust_link, 0, PHY_INTERFACE_MODE_SGMII);
+
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to phy\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	mac->phydev = phydev;
+
+	return 0;
+
+err:
+	of_node_put(phy_dn);
+	return -ENODEV;
+}
+
+
 static int pasemi_mac_open(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -667,6 +769,13 @@ static int pasemi_mac_open(struct net_de
 
 	pasemi_mac_replenish_rx_ring(dev);
 
+	ret = pasemi_mac_phy_init(dev);
+	/* Some configs don't have PHYs (XAUI etc), so don't complain about
+	 * failed init due to -ENODEV.
+	 */
+	if (ret && ret != -ENODEV)
+		dev_warn(&mac->pdev->dev, "phy init failed: %d\n", ret);
+
 	netif_start_queue(dev);
 	netif_poll_enable(dev);
 
@@ -697,6 +806,9 @@ static int pasemi_mac_open(struct net_de
 		goto out_rx_int;
 	}
 
+	if (mac->phydev)
+		phy_start(mac->phydev);
+
 	return 0;
 
 out_rx_int:
@@ -720,6 +832,11 @@ static int pasemi_mac_close(struct net_d
 	unsigned int stat;
 	int retries;
 
+	if (mac->phydev) {
+		phy_stop(mac->phydev);
+		phy_disconnect(mac->phydev);
+	}
+
 	netif_stop_queue(dev);
 
 	/* Clean out any pending buffers */
@@ -1013,6 +1130,9 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
 	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
 
+	/* Enable most messages by default */
+	mac->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+
 	err = register_netdev(dev);
 
 	if (err) {
Index: powerpc/drivers/net/pasemi_mac.h
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.h
+++ powerpc/drivers/net/pasemi_mac.h
@@ -24,6 +24,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
+#include <linux/phy.h>
 
 struct pasemi_mac_txring {
 	spinlock_t	 lock;
@@ -54,6 +55,7 @@ struct pasemi_mac {
 	struct pci_dev *pdev;
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
+	struct phy_device *phydev;
 	struct net_device_stats stats;
 
 	/* Pointer to the cacheable per-channel status registers */
@@ -75,6 +77,12 @@ struct pasemi_mac {
 	struct pasemi_mac_rxring *rx;
 	unsigned long	tx_irq;
 	unsigned long	rx_irq;
+	int	link;
+	int	speed;
+	int	duplex;
+
+	unsigned int	msg_enable;
+	char	phy_id[BUS_ID_SIZE];
 };
 
 /* Software status descriptor (desc_info) */
Index: powerpc/drivers/net/Kconfig
===================================================================
--- powerpc.orig/drivers/net/Kconfig
+++ powerpc/drivers/net/Kconfig
@@ -2490,6 +2490,7 @@ config NETXEN_NIC
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC64 && PCI
+	select PHYLIB
 	help
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.
