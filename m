From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Thu, 24 Jul 2008 23:09:05 +0200
Message-ID: <20080724210905.GB27489@electric-eye.fr.zoreil.com>
References: <200807241554.m6OFsaL1005401@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mario Limonciello <Mario_Limonciello@Dell.com>,
	kernel@vger.kernel.org, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: c4p7n1@capitanio.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58270 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbYGXVJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 17:09:18 -0400
Content-Disposition: inline
In-Reply-To: <200807241554.m6OFsaL1005401@post.webmailer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

c4p7n1@capitanio.org <c4p7n1@capitanio.org> :
[...]
> It only remains other (cosmetic?) not-linux-only issue: the *E chip-sets have
> a built in 100Mb/s transceiver
> 
> http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PNid=14&PFid=7&Level=5&Conn=4&ProdID=19
> 
> but the driver advertises 1G:
> 
> Settings for eth0:
> 	Supported ports: [ TP ]
> 	Supported link modes:   10baseT/Half 10baseT/Full 
> 	                        100baseT/Half 100baseT/Full 
> 	                        1000baseT/Full 

Ahem.

Can you give the completely untested patch below a try (say, against
2.6.26 or more) ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a3e3895..1a8a21f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -406,13 +406,15 @@ struct rtl8169_private {
 	struct vlan_group *vlgrp;
 #endif
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
-	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
 	unsigned features;
+
+	struct mii_if_info mii;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -482,6 +484,23 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void rtl_mdio_write(struct net_device *dev, int phy_id, int location,
+			   int val)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	mdio_write(ioaddr, location, val);
+}
+
+static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return mdio_read(ioaddr, location);
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -850,7 +869,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 
 #endif
 
-static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -867,65 +886,29 @@ static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cmd->speed = SPEED_1000;
 	cmd->duplex = DUPLEX_FULL; /* Always set */
+
+	return 0;
 }
 
-static void rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	u8 status;
-
-	cmd->supported = SUPPORTED_10baseT_Half |
-			 SUPPORTED_10baseT_Full |
-			 SUPPORTED_100baseT_Half |
-			 SUPPORTED_100baseT_Full |
-			 SUPPORTED_1000baseT_Full |
-			 SUPPORTED_Autoneg |
-			 SUPPORTED_TP;
-
-	cmd->autoneg = 1;
-	cmd->advertising = ADVERTISED_TP | ADVERTISED_Autoneg;
-
-	if (tp->phy_auto_nego_reg & ADVERTISE_10HALF)
-		cmd->advertising |= ADVERTISED_10baseT_Half;
-	if (tp->phy_auto_nego_reg & ADVERTISE_10FULL)
-		cmd->advertising |= ADVERTISED_10baseT_Full;
-	if (tp->phy_auto_nego_reg & ADVERTISE_100HALF)
-		cmd->advertising |= ADVERTISED_100baseT_Half;
-	if (tp->phy_auto_nego_reg & ADVERTISE_100FULL)
-		cmd->advertising |= ADVERTISED_100baseT_Full;
-	if (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL)
-		cmd->advertising |= ADVERTISED_1000baseT_Full;
-
-	status = RTL_R8(PHYstatus);
-
-	if (status & _1000bpsF)
-		cmd->speed = SPEED_1000;
-	else if (status & _100bps)
-		cmd->speed = SPEED_100;
-	else if (status & _10bps)
-		cmd->speed = SPEED_10;
-
-	if (status & TxFlowCtrl)
-		cmd->advertising |= ADVERTISED_Asym_Pause;
-	if (status & RxFlowCtrl)
-		cmd->advertising |= ADVERTISED_Pause;
-
-	cmd->duplex = ((status & _1000bpsF) || (status & FullDup)) ?
-		      DUPLEX_FULL : DUPLEX_HALF;
+
+	return mii_ethtool_gset(&tp->mii, cmd);
 }
 
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	unsigned long flags;
+	int rc;
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	tp->get_settings(dev, cmd);
+	rc = tp->get_settings(dev, cmd);
 
 	spin_unlock_irqrestore(&tp->lock, flags);
-	return 0;
+	return rc;
 }
 
 static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
@@ -1578,6 +1561,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
 	const unsigned int region = cfg->region;
 	struct rtl8169_private *tp;
+	struct mii_if_info *mii;
 	struct net_device *dev;
 	void __iomem *ioaddr;
 	unsigned int i;
@@ -1602,6 +1586,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->pci_dev = pdev;
 	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
 
+	mii = &tp->mii;
+	mii->dev = dev;
+	mii->mdio_read = rtl_mdio_read;
+	mii->mdio_write = rtl_mdio_write;
+	mii->phy_id_mask = 0x1f;
+	mii->reg_num_mask = 0x1f;
+
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
-- 
Ueimor
