From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/6] Pull request for 'r8169-fixes' branch
Date: Sun, 17 Aug 2008 18:23:30 +0200
Message-ID: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34300 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751423AbYHQQYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 12:24:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'r8169-fixes' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-fixes

to get the changes below.

Distance from 'upstream-davem' (d6f8aa8586dabe605454f3c98a5c1a577c3e0cfb)
-------------------------------------------------------------------------

2857ffb7b8913ef713533ac5783abd70a20529e4
dacf815434a4d5f5b45687873df46927c64cfb19
f162a5d1b326d54b0be7e3100f69763d8a707721
9c14ceafa5ca7f57225a43fb0785c56ddc7f1823
458a9f617adfb2fc5f38e7673339115c4ba3290f
ccdffb9a88b2907b159538d7bfd6256621db4f84

Diffstat
--------

 drivers/net/r8169.c |  401 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 335 insertions(+), 66 deletions(-)

Shortlog
--------

Francois Romieu (6):
      r8169: get ethtool settings through the generic mii helper
      r8169: Tx performance tweak helper
      r8169: use pci_find_capability for the PCI-E features
      r8169: add 8168/8101 registers description
      r8169: add hw start helpers for the 8168 and the 8101
      r8169: additional 8101 and 8102 support

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a3e3895..bbaf8a5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -61,6 +61,7 @@ static const int multicast_filter_limit = 32;
 /* MAC address length */
 #define MAC_ADDR_LEN	6
 
+#define MAX_READ_REQUEST_SHIFT	12
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
@@ -95,6 +96,10 @@ enum mac_version {
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
@@ -121,6 +126,10 @@ static const struct {
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
@@ -196,9 +205,6 @@ enum rtl_registers {
 	Config5		= 0x56,
 	MultiIntr	= 0x5c,
 	PHYAR		= 0x60,
-	TBICSR		= 0x64,
-	TBI_ANAR	= 0x68,
-	TBI_LPAR	= 0x6a,
 	PHYstatus	= 0x6c,
 	RxMaxSize	= 0xda,
 	CPlusCmd	= 0xe0,
@@ -212,6 +218,32 @@ enum rtl_registers {
 	FuncForceEvent	= 0xfc,
 };
 
+enum rtl8110_registers {
+	TBICSR			= 0x64,
+	TBI_ANAR		= 0x68,
+	TBI_LPAR		= 0x6a,
+};
+
+enum rtl8168_8101_registers {
+	CSIDR			= 0x64,
+	CSIAR			= 0x68,
+#define	CSIAR_FLAG			0x80000000
+#define	CSIAR_WRITE_CMD			0x80000000
+#define	CSIAR_BYTE_ENABLE		0x0f
+#define	CSIAR_BYTE_ENABLE_SHIFT		12
+#define	CSIAR_ADDR_MASK			0x0fff
+
+	EPHYAR			= 0x80,
+#define	EPHYAR_FLAG			0x80000000
+#define	EPHYAR_WRITE_CMD		0x80000000
+#define	EPHYAR_REG_MASK			0x1f
+#define	EPHYAR_REG_SHIFT		16
+#define	EPHYAR_DATA_MASK		0xffff
+	DBG_REG			= 0xd1,
+#define	FIX_NAK_1			(1 << 4)
+#define	FIX_NAK_2			(1 << 3)
+};
+
 enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
@@ -265,7 +297,13 @@ enum rtl_register_content {
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
 	/* Config1 register p.24 */
+	LEDS1		= (1 << 7),
+	LEDS0		= (1 << 6),
 	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
+	Speed_down	= (1 << 4),
+	MEMMAP		= (1 << 3),
+	IOMAP		= (1 << 2),
+	VPD		= (1 << 1),
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
@@ -275,6 +313,7 @@ enum rtl_register_content {
 	/* Config3 register p.25 */
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
+	Beacon_en	= (1 << 0),	/* 8168 only. Reserved in the 8168b */
 
 	/* Config5 register p.27 */
 	BWF		= (1 << 6),	/* Accept Broadcast wakeup frame */
@@ -292,7 +331,16 @@ enum rtl_register_content {
 	TBINwComplete	= 0x01000000,
 
 	/* CPlusCmd p.31 */
-	PktCntrDisable	= (1 << 7),	// 8168
+	EnableBist	= (1 << 15),	// 8168 8101
+	Mac_dbgo_oe	= (1 << 14),	// 8168 8101
+	Normal_mode	= (1 << 13),	// unused
+	Force_half_dup	= (1 << 12),	// 8168 8101
+	Force_rxflow_en	= (1 << 11),	// 8168 8101
+	Force_txflow_en	= (1 << 10),	// 8168 8101
+	Cxpl_dbg_sel	= (1 << 9),	// 8168 8101
+	ASF		= (1 << 8),	// 8168 8101
+	PktCntrDisable	= (1 << 7),	// 8168 8101
+	Mac_dbgo_sel	= 0x001c,	// 8168
 	RxVlan		= (1 << 6),
 	RxChkSum	= (1 << 5),
 	PCIDAC		= (1 << 4),
@@ -370,8 +418,9 @@ struct ring_info {
 };
 
 enum features {
-	RTL_FEATURE_WOL	= (1 << 0),
-	RTL_FEATURE_MSI	= (1 << 1),
+	RTL_FEATURE_WOL		= (1 << 0),
+	RTL_FEATURE_MSI		= (1 << 1),
+	RTL_FEATURE_GMII	= (1 << 2),
 };
 
 struct rtl8169_private {
@@ -406,13 +455,16 @@ struct rtl8169_private {
 	struct vlan_group *vlgrp;
 #endif
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
-	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
+	int pcie_cap;
 	struct delayed_work task;
 	unsigned features;
+
+	struct mii_if_info mii;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -482,6 +534,94 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
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
+static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
+		(reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(EPHYAR) & EPHYAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
+{
+	u16 value = 0xffff;
+	unsigned int i;
+
+	RTL_W32(EPHYAR, (reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(EPHYAR) & EPHYAR_FLAG) {
+			value = RTL_R32(EPHYAR) & EPHYAR_DATA_MASK;
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
+static void rtl_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
+{
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
+			value = RTL_R32(CSIDR);
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -705,8 +845,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		}
 	}
 
-	/* The 8100e/8101e do Fast Ethernet only. */
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+	/* The 8100e/8101e/8102e do Fast Ethernet only. */
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_07) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_08) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_09) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_10) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
@@ -850,7 +994,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 
 #endif
 
-static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -867,65 +1011,29 @@ static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 
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
@@ -1116,8 +1224,17 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
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
+		{ 0x7c800000, 0x24800000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
 		/* FIXME: where did these entries come from ? -- FR */
 		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
@@ -1279,6 +1396,22 @@ static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
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
@@ -1296,6 +1429,11 @@ static void rtl_hw_phy_config(struct net_device *dev)
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
@@ -1513,7 +1651,7 @@ static const struct rtl_cfg_info {
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
-	unsigned msi;
+	unsigned features;
 } rtl_cfg_infos [] = {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
@@ -1522,7 +1660,7 @@ static const struct rtl_cfg_info {
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
-		.msi		= 0
+		.features	= RTL_FEATURE_GMII
 	},
 	[RTL_CFG_1] = {
 		.hw_start	= rtl_hw_start_8168,
@@ -1531,7 +1669,7 @@ static const struct rtl_cfg_info {
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
-		.msi		= RTL_FEATURE_MSI
+		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI
 	},
 	[RTL_CFG_2] = {
 		.hw_start	= rtl_hw_start_8101,
@@ -1540,7 +1678,7 @@ static const struct rtl_cfg_info {
 		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
-		.msi		= RTL_FEATURE_MSI
+		.features	= RTL_FEATURE_MSI
 	}
 };
 
@@ -1552,7 +1690,7 @@ static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
 	u8 cfg2;
 
 	cfg2 = RTL_R8(Config2) & ~MSIEnable;
-	if (cfg->msi) {
+	if (cfg->features & RTL_FEATURE_MSI) {
 		if (pci_enable_msi(pdev)) {
 			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
 		} else {
@@ -1578,6 +1716,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
 	const unsigned int region = cfg->region;
 	struct rtl8169_private *tp;
+	struct mii_if_info *mii;
 	struct net_device *dev;
 	void __iomem *ioaddr;
 	unsigned int i;
@@ -1602,6 +1741,14 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->pci_dev = pdev;
 	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
 
+	mii = &tp->mii;
+	mii->dev = dev;
+	mii->mdio_read = rtl_mdio_read;
+	mii->mdio_write = rtl_mdio_write;
+	mii->phy_id_mask = 0x1f;
+	mii->reg_num_mask = 0x1f;
+	mii->supports_gmii = !!(cfg->features & RTL_FEATURE_GMII);
+
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
@@ -1670,6 +1817,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_res_4;
 	}
 
+	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (!tp->pcie_cap && netif_msg_probe(tp))
+		dev_info(&pdev->dev, "no PCI Express capability\n");
+
 	/* Unneeded ? Don't mess with Mrs. Murphy. */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
@@ -2061,12 +2212,51 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
+static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int cap = tp->pcie_cap;
+
+	if (cap) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &ctl);
+		ctl = (ctl & ~PCI_EXP_DEVCTL_READRQ) | force;
+		pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, ctl);
+	}
+}
+
+static void rtl_csi_access_enable(void __iomem *ioaddr)
+{
+	u32 csi;
+
+	csi = rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
+	rtl_csi_write(ioaddr, 0x070c, csi | 0x27000000);
+}
+
+struct ephy_info {
+	unsigned int offset;
+	u16 mask;
+	u16 bits;
+};
+
+static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, int len)
+{
+	u16 w;
+
+	while (len-- > 0) {
+		w = (rtl_ephy_read(ioaddr, e->offset) & ~e->mask) | e->bits;
+		rtl_ephy_write(ioaddr, e->offset, w);
+		e++;
+	}
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 ctl;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -2080,10 +2270,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	/* Tx performance tweak. */
-	pci_read_config_byte(pdev, 0x69, &ctl);
-	ctl = (ctl & ~0x70) | 0x50;
-	pci_write_config_byte(pdev, 0x69, ctl);
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W16(IntrMitigate, 0x5151);
 
@@ -2110,6 +2297,70 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
+#define R810X_CPCMD_QUIRK_MASK (\
+	EnableBist | \
+	Mac_dbgo_oe | \
+	Force_half_dup | \
+	Force_half_dup | \
+	Force_txflow_en | \
+	Cxpl_dbg_sel | \
+	ASF | \
+	PktCntrDisable | \
+	PCIDAC | \
+	PCIMulRW)
+
+static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8102e_1[] = {
+		{ 0x01,	0, 0x6e65 },
+		{ 0x02,	0, 0x091f },
+		{ 0x03,	0, 0xc2f9 },
+		{ 0x06,	0, 0xafb5 },
+		{ 0x07,	0, 0x0e00 },
+		{ 0x19,	0, 0xec80 },
+		{ 0x01,	0, 0x2e65 },
+		{ 0x01,	0, 0x6e65 }
+	};
+	u8 cfg1;
+
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(DBG_REG, FIX_NAK_1);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W8(Config1,
+	       LEDS1 | LEDS0 | Speed_down | MEMMAP | IOMAP | VPD | PMEnable);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	cfg1 = RTL_R8(Config1);
+	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
+		RTL_W8(Config1, cfg1 & ~LEDS0);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
+
+	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
+}
+
+static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W8(Config1, MEMMAP | IOMAP | VPD | PMEnable);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
+}
+
+static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8102e_2(ioaddr, pdev);
+
+	rtl_ephy_write(ioaddr, 0x03, 0xc2f9);
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2118,8 +2369,26 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
-		pci_write_config_word(pdev, 0x68, 0x00);
-		pci_write_config_word(pdev, 0x69, 0x08);
+		int cap = tp->pcie_cap;
+
+		if (cap) {
+			pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL,
+					      PCI_EXP_DEVCTL_NOSNOOP_EN);
+		}
+	}
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+		rtl_hw_start_8102e_1(ioaddr, pdev);
+		break;
+
+	case RTL_GIGA_MAC_VER_08:
+		rtl_hw_start_8102e_3(ioaddr, pdev);
+		break;
+
+	case RTL_GIGA_MAC_VER_09:
+		rtl_hw_start_8102e_2(ioaddr, pdev);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-- 
Ueimor
