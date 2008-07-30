From: c4p7n1@capitanio.org
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Wed, 30 Jul 2008 20:05:23 +0200 (MEST)
Message-ID: <200807301805.m6UI5NXw013427@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Mario Limonciello" <Mario_Limonciello@Dell.com>,
	"Edward Hsu" <edward_hsu@realtek.com.tw>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p00-ob.rzone.de ([81.169.146.193]:18579 "EHLO
	cg-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbYG3SF3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 14:05:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [...]
> > Subsystem: Toshiba America Info Systems Unknown device [1179:ff64]
> > means Realtek RTL8102E Family PCI-E Fast Ethernet NIC (NDIS 6.0)
> > [Toshiba America Information Systems] 1179:ff64 rev 02
> [...]

After solving another unrelated rc1 issue, I can confirm that this device
works without any problems.

[   13.388384] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[   13.388457] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   13.388537] r8169 0000:02:00.0: setting latency timer to 64
[   13.388665] PM: Adding info for No Bus:eth0
[   13.388855] eth0: RTL8102e at 0xf8924000, , XID 34a00000 IRQ 220


Thanks everybody involved for help.
Martin Capitanio

-----
git diff v2.6.27-rc1

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a3e3895..9810aeb 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -95,6 +95,10 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_04 = 0x04, // 8169SB
 	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
+	RTL_GIGA_MAC_VER_07 = 0x07, // 8102e
+	RTL_GIGA_MAC_VER_08 = 0x08, // 8102e
+	RTL_GIGA_MAC_VER_09 = 0x09, // 8102e
+	RTL_GIGA_MAC_VER_10 = 0x0a, // 8101e
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
 	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be
 	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb
@@ -121,6 +125,10 @@ static const struct {
 	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880), // 8110SCe
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_07, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_08, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_09, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_10, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -406,13 +414,15 @@ struct rtl8169_private {
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
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew ");
@@ -482,6 +492,28 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
+{
+	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
+}
+
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
@@ -850,7 +882,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp,
struct RxDesc *desc,
 
 #endif
 
-static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -867,65 +899,30 @@ static void rtl8169_gset_tbi(struct net_device *dev,
struct ethtool_cmd *cmd)
 
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
 
 static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd
*cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	unsigned long flags;
+	int rc;
 
 	spin_lock_irqsave(&tp->lock, flags);
 
 	tp->get_settings(dev, cmd);
+	rc = tp->get_settings(dev, cmd);
 
 	spin_unlock_irqrestore(&tp->lock, flags);
-	return 0;
+	return rc;
 }
 
 static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs
*regs,
@@ -1116,8 +1113,16 @@ static void rtl8169_get_mac_version(struct
rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x34a00000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7cf00000, 0x24a00000,	RTL_GIGA_MAC_VER_09 },
+		{ 0x7cf00000, 0x34900000,	RTL_GIGA_MAC_VER_08 },
+		{ 0x7cf00000, 0x24900000,	RTL_GIGA_MAC_VER_08 },
+		{ 0x7cf00000, 0x34800000,	RTL_GIGA_MAC_VER_07 },
+		{ 0x7cf00000, 0x24800000,	RTL_GIGA_MAC_VER_07 },
 		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x7cf00000, 0x34300000,	RTL_GIGA_MAC_VER_10 },
 		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7c800000, 0x34800000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
 		/* FIXME: where did these entries come from ? -- FR */
 		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
@@ -1279,6 +1284,22 @@ static void rtl8168cx_hw_phy_config(void __iomem
*ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0003 },
+		{ 0x08, 0x441d },
+		{ 0x01, 0x9100 },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_patch(ioaddr, 0x11, 1 << 12);
+	mdio_patch(ioaddr, 0x19, 1 << 13);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1296,6 +1317,11 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+		rtl8102e_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
@@ -1578,6 +1604,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct
pci_device_id *ent)
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
 	const unsigned int region = cfg->region;
 	struct rtl8169_private *tp;
+	struct mii_if_info *mii;
 	struct net_device *dev;
 	void __iomem *ioaddr;
 	unsigned int i;
@@ -1602,6 +1629,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct
pci_device_id *ent)
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


