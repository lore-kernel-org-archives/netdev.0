From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/4] r8169 driver updates
Date: Sat, 5 Mar 2011 10:37:16 +0100
Message-ID: <20110305093716.GA13835@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Jesse Gross <jesse@nicira.com>,
	Oliver Neukum <oneukum@suse.de>, dwmw2@infradead.org,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50173 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271Ab1CEJmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 04:42:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.r8169

to get the changes below.

- the firmware for the 8105 has been submitted to the linux-firmware.git tree
  (pending inclusion). It is not mandatory. I have checked the usual
  { monolithic / modular } {with / without} firmware combinations with a
  RTL8105E-VC (RTL_GIGA_MAC_VER_29). The usual limitation with firmware +
  suspend/resume still apply (see f1e02ed109df5f99abf942b8ccc99960cb09dd38).

- I have updated Oliver's patch - mostly for merge conflicts - and fixed a
  bug in my version of 2011/01/04. I have not forgotten mac pause control
  frames control (Ben's suggestion). It's just a bit lower priority now.

- VLAN does not ask for special comment. It's very sky2 like.

Distance from 'davem-next.base' (8da83f8e73a42fa3142843938aa1590b82acb6ec)
--------------------------------------------------------------------------

7a8fc77b3744e26ce1249d9ccb23e356d6010679
54405cde762408b00a445466a40da4f7f33a8479
5a5e4443150713347a7a7e4d0880b343348f5811
716b50a31fb237c480e67ad66dc23feb35d40772

Diffstat
--------

 drivers/net/Kconfig |    9 --
 drivers/net/r8169.c |  272 +++++++++++++++++++++++++++++++++------------------
 2 files changed, 178 insertions(+), 103 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: convert to new VLAN model.

Hayes Wang (2):
      r8169: adjust rtl8169_set_speed_xmii function.
      r8169: support the new chips for RTL8105E.

Oliver Neukum (1):
      r8169: support control of advertising.

Patch
-----

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4b3927..8d0d16f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2236,15 +2236,6 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config R8169_VLAN
-	bool "VLAN support"
-	depends on R8169 && VLAN_8021Q
-	---help---
-	  Say Y here for the r8169 driver to support the functions required
-	  by the kernel 802.1Q code.
-
-	  If in doubt, say Y.
-
 config SB1250_MAC
 	tristate "SB1250 Gigabit Ethernet support"
 	depends on SIBYTE_SB1xxx_SOC
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 469ab0b..52e20d5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -36,6 +36,7 @@
 
 #define FIRMWARE_8168D_1	"rtl_nic/rtl8168d-1.fw"
 #define FIRMWARE_8168D_2	"rtl_nic/rtl8168d-2.fw"
+#define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -123,6 +124,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_26 = 0x1a, // 8168D
 	RTL_GIGA_MAC_VER_27 = 0x1b, // 8168DP
 	RTL_GIGA_MAC_VER_28 = 0x1c, // 8168DP
+	RTL_GIGA_MAC_VER_29 = 0x1d, // 8105E
+	RTL_GIGA_MAC_VER_30 = 0x1e, // 8105E
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -160,7 +163,9 @@ static const struct {
 	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_25, 0xff7e1880), // PCI-E
 	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_26, 0xff7e1880), // PCI-E
 	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_27, 0xff7e1880), // PCI-E
-	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_28, 0xff7e1880)  // PCI-E
+	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_28, 0xff7e1880), // PCI-E
+	_R("RTL8105e",		RTL_GIGA_MAC_VER_29, 0xff7e1880), // PCI-E
+	_R("RTL8105e",		RTL_GIGA_MAC_VER_30, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -267,9 +272,15 @@ enum rtl8168_8101_registers {
 #define	EPHYAR_REG_MASK			0x1f
 #define	EPHYAR_REG_SHIFT		16
 #define	EPHYAR_DATA_MASK		0xffff
+	DLLPR			= 0xd0,
+#define	PM_SWITCH			(1 << 6)
 	DBG_REG			= 0xd1,
 #define	FIX_NAK_1			(1 << 4)
 #define	FIX_NAK_2			(1 << 3)
+	TWSI			= 0xd2,
+	MCU			= 0xd3,
+#define	EN_NDP				(1 << 3)
+#define	EN_OOB_RESET			(1 << 2)
 	EFUSEAR			= 0xdc,
 #define	EFUSEAR_FLAG			0x80000000
 #define	EFUSEAR_WRITE_CMD		0x80000000
@@ -526,9 +537,6 @@ struct rtl8169_private {
 	u16 napi_event;
 	u16 intr_mask;
 	int phy_1000_ctrl_reg;
-#ifdef CONFIG_R8169_VLAN
-	struct vlan_group *vlgrp;
-#endif
 
 	struct mdio_ops {
 		void (*write)(void __iomem *, int, int);
@@ -540,7 +548,7 @@ struct rtl8169_private {
 		void (*up)(struct rtl8169_private *);
 	} pll_power_ops;
 
-	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
+	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
 	void (*hw_start)(struct net_device *);
@@ -568,6 +576,7 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 MODULE_FIRMWARE(FIRMWARE_8168D_1);
 MODULE_FIRMWARE(FIRMWARE_8168D_2);
+MODULE_FIRMWARE(FIRMWARE_8105E_1);
 
 static int rtl8169_open(struct net_device *dev);
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -1096,7 +1105,7 @@ static int rtl8169_get_regs_len(struct net_device *dev)
 }
 
 static int rtl8169_set_speed_tbi(struct net_device *dev,
-				 u8 autoneg, u16 speed, u8 duplex)
+				 u8 autoneg, u16 speed, u8 duplex, u32 ignored)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1119,17 +1128,30 @@ static int rtl8169_set_speed_tbi(struct net_device *dev,
 }
 
 static int rtl8169_set_speed_xmii(struct net_device *dev,
-				  u8 autoneg, u16 speed, u8 duplex)
+				  u8 autoneg, u16 speed, u8 duplex, u32 adv)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int giga_ctrl, bmcr;
+	int rc = -EINVAL;
+
+	rtl_writephy(tp, 0x1f, 0x0000);
 
 	if (autoneg == AUTONEG_ENABLE) {
 		int auto_nego;
 
 		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
-		auto_nego |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
-			      ADVERTISE_100HALF | ADVERTISE_100FULL);
+		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
+				ADVERTISE_100HALF | ADVERTISE_100FULL);
+
+		if (adv & ADVERTISED_10baseT_Half)
+			auto_nego |= ADVERTISE_10HALF;
+		if (adv & ADVERTISED_10baseT_Full)
+			auto_nego |= ADVERTISE_10FULL;
+		if (adv & ADVERTISED_100baseT_Half)
+			auto_nego |= ADVERTISE_100HALF;
+		if (adv & ADVERTISED_100baseT_Full)
+			auto_nego |= ADVERTISE_100FULL;
+
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
 		giga_ctrl = rtl_readphy(tp, MII_CTRL1000);
@@ -1143,27 +1165,22 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		    (tp->mac_version != RTL_GIGA_MAC_VER_13) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
-			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
-		} else {
+		    (tp->mac_version != RTL_GIGA_MAC_VER_16) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_29) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_30)) {
+			if (adv & ADVERTISED_1000baseT_Half)
+				giga_ctrl |= ADVERTISE_1000HALF;
+			if (adv & ADVERTISED_1000baseT_Full)
+				giga_ctrl |= ADVERTISE_1000FULL;
+		} else if (adv & (ADVERTISED_1000baseT_Half |
+				  ADVERTISED_1000baseT_Full)) {
 			netif_info(tp, link, dev,
 				   "PHY does not support 1000Mbps\n");
+			goto out;
 		}
 
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
 
-		if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
-		    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-		    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
-			/*
-			 * Wake up the PHY.
-			 * Vendor specific (0x1f) and reserved (0x0e) MII
-			 * registers.
-			 */
-			rtl_writephy(tp, 0x1f, 0x0000);
-			rtl_writephy(tp, 0x0e, 0x0000);
-		}
-
 		rtl_writephy(tp, MII_ADVERTISE, auto_nego);
 		rtl_writephy(tp, MII_CTRL1000, giga_ctrl);
 	} else {
@@ -1174,12 +1191,10 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		else if (speed == SPEED_100)
 			bmcr = BMCR_SPEED100;
 		else
-			return -EINVAL;
+			goto out;
 
 		if (duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
-
-		rtl_writephy(tp, 0x1f, 0x0000);
 	}
 
 	tp->phy_1000_ctrl_reg = giga_ctrl;
@@ -1197,16 +1212,18 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		}
 	}
 
-	return 0;
+	rc = 0;
+out:
+	return rc;
 }
 
 static int rtl8169_set_speed(struct net_device *dev,
-			     u8 autoneg, u16 speed, u8 duplex)
+			     u8 autoneg, u16 speed, u8 duplex, u32 advertising)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int ret;
 
-	ret = tp->set_speed(dev, autoneg, speed, duplex);
+	ret = tp->set_speed(dev, autoneg, speed, duplex, advertising);
 
 	if (netif_running(dev) && (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -1221,7 +1238,8 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8169_set_speed(dev,
+		cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return ret;
@@ -1255,8 +1273,6 @@ static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
 	return 0;
 }
 
-#ifdef CONFIG_R8169_VLAN
-
 static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 				      struct sk_buff *skb)
 {
@@ -1264,64 +1280,37 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
 }
 
-static void rtl8169_vlan_rx_register(struct net_device *dev,
-				     struct vlan_group *grp)
+#define NETIF_F_HW_VLAN_TX_RX	(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
+
+static void rtl8169_vlan_mode(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	tp->vlgrp = grp;
-	/*
-	 * Do not disable RxVlan on 8110SCd.
-	 */
-	if (tp->vlgrp || (tp->mac_version == RTL_GIGA_MAC_VER_05))
+	if (dev->features & NETIF_F_HW_VLAN_RX)
 		tp->cp_cmd |= RxVlan;
 	else
 		tp->cp_cmd &= ~RxVlan;
 	RTL_W16(CPlusCmd, tp->cp_cmd);
+	/* PCI commit */
 	RTL_R16(CPlusCmd);
 	spin_unlock_irqrestore(&tp->lock, flags);
+
+	dev->vlan_features = dev->features &~ NETIF_F_HW_VLAN_TX_RX;
 }
 
-static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
-			       struct sk_buff *skb, int polling)
+static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *skb)
 {
 	u32 opts2 = le32_to_cpu(desc->opts2);
-	struct vlan_group *vlgrp = tp->vlgrp;
-	int ret;
 
-	if (vlgrp && (opts2 & RxVlanTag)) {
-		u16 vtag = swab16(opts2 & 0xffff);
+	if (opts2 & RxVlanTag)
+		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
 
-		if (likely(polling))
-			vlan_gro_receive(&tp->napi, vlgrp, vtag, skb);
-		else
-			__vlan_hwaccel_rx(skb, vlgrp, vtag, polling);
-		ret = 0;
-	} else
-		ret = -1;
 	desc->opts2 = 0;
-	return ret;
 }
 
-#else /* !CONFIG_R8169_VLAN */
-
-static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
-				      struct sk_buff *skb)
-{
-	return 0;
-}
-
-static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
-			       struct sk_buff *skb, int polling)
-{
-	return -1;
-}
-
-#endif
-
 static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1492,6 +1481,28 @@ static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
+static int rtl8169_set_flags(struct net_device *dev, u32 data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long old_feat = dev->features;
+	int rc;
+
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_05) &&
+	    !(data & ETH_FLAG_RXVLAN)) {
+		netif_info(tp, drv, dev, "8110SCd requires hardware Rx VLAN\n");
+		return -EINVAL;
+	}
+
+	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_TXVLAN | ETH_FLAG_RXVLAN);
+	if (rc)
+		return rc;
+
+	if ((old_feat ^ dev->features) & NETIF_F_HW_VLAN_RX)
+		rtl8169_vlan_mode(dev);
+
+	return 0;
+}
+
 static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
@@ -1511,6 +1522,8 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_strings		= rtl8169_get_strings,
 	.get_sset_count		= rtl8169_get_sset_count,
 	.get_ethtool_stats	= rtl8169_get_ethtool_stats,
+	.set_flags		= rtl8169_set_flags,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 static void rtl8169_get_mac_version(struct rtl8169_private *tp,
@@ -1559,6 +1572,9 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
+		{ 0x7cf00000, 0x40900000,	RTL_GIGA_MAC_VER_29 },
+		{ 0x7c800000, 0x40800000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x34a00000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7cf00000, 0x24a00000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7cf00000, 0x34900000,	RTL_GIGA_MAC_VER_08 },
@@ -2435,6 +2451,33 @@ static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0005 },
+		{ 0x1a, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0004 },
+		{ 0x1c, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0001 },
+		{ 0x15, 0x7701 },
+		{ 0x1f, 0x0000 }
+	};
+
+	/* Disable ALDPS before ram code */
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(100);
+
+	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
+		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2502,6 +2545,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_28:
 		rtl8168d_4_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_29:
+	case RTL_GIGA_MAC_VER_30:
+		rtl8105e_hw_phy_config(tp);
+		break;
 
 	default:
 		break;
@@ -2633,11 +2680,12 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	rtl8169_phy_reset(dev, tp);
 
-	/*
-	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
-	 * only 8101. Don't panic.
-	 */
-	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
+	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
+		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
+		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
+		tp->mii.supports_gmii ?
+			ADVERTISED_1000baseT_Half |
+			ADVERTISED_1000baseT_Full : 0);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
@@ -2793,9 +2841,6 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 	.ndo_set_mac_address	= rtl_set_mac_address,
 	.ndo_do_ioctl		= rtl8169_ioctl,
 	.ndo_set_multicast_list	= rtl_set_rx_mode,
-#ifdef CONFIG_R8169_VLAN
-	.ndo_vlan_rx_register	= rtl8169_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= rtl8169_netpoll,
 #endif
@@ -2940,6 +2985,8 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_09:
 	case RTL_GIGA_MAC_VER_10:
 	case RTL_GIGA_MAC_VER_16:
+	case RTL_GIGA_MAC_VER_29:
+	case RTL_GIGA_MAC_VER_30:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -3087,6 +3134,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
+	/*
+	 * Pretend we are using VLANs; This bypasses a nasty bug where
+	 * Interrupts stop flowing on high load on 8110SCd controllers.
+	 */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
+		tp->cp_cmd |= RxVlan;
+
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 
@@ -3155,10 +3209,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
-#ifdef CONFIG_R8169_VLAN
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
-	dev->features |= NETIF_F_GRO;
+	dev->features |= NETIF_F_HW_VLAN_TX_RX | NETIF_F_GRO;
 
 	tp->intr_mask = 0xffff;
 	tp->hw_start = cfg->hw_start;
@@ -3276,12 +3327,7 @@ static int rtl8169_open(struct net_device *dev)
 
 	rtl8169_init_phy(dev, tp);
 
-	/*
-	 * Pretend we are using VLANs; This bypasses a nasty bug where
-	 * Interrupts stop flowing on high load on 8110SCd controllers.
-	 */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | RxVlan);
+	rtl8169_vlan_mode(dev);
 
 	rtl_pll_power_up(tp);
 
@@ -3902,6 +3948,37 @@ static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_ephy_write(ioaddr, 0x03, 0xc2f9);
 }
 
+static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static const struct ephy_info e_info_8105e_1[] = {
+		{ 0x07,	0, 0x4000 },
+		{ 0x19,	0, 0x0200 },
+		{ 0x19,	0, 0x0020 },
+		{ 0x1e,	0, 0x2000 },
+		{ 0x03,	0, 0x0001 },
+		{ 0x19,	0, 0x0100 },
+		{ 0x19,	0, 0x0004 },
+		{ 0x0a,	0, 0x0020 }
+	};
+
+	/* Force LAN exit from ASPM if Rx/Tx are not idel */
+	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
+
+	/* disable Early Tally Counter */
+	RTL_W32(FuncEvent, RTL_R32(FuncEvent) & ~0x010000);
+
+	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PM_SWITCH);
+
+	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
+}
+
+static void rtl_hw_start_8105e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8105e_1(ioaddr, pdev);
+	rtl_ephy_write(ioaddr, 0x1e, rtl_ephy_read(ioaddr, 0x1e) | 0x8000);
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3930,6 +4007,13 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_09:
 		rtl_hw_start_8102e_2(ioaddr, pdev);
 		break;
+
+	case RTL_GIGA_MAC_VER_29:
+		rtl_hw_start_8105e_1(ioaddr, pdev);
+		break;
+	case RTL_GIGA_MAC_VER_30:
+		rtl_hw_start_8105e_2(ioaddr, pdev);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
@@ -4593,12 +4677,12 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 
-			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
-				if (likely(polling))
-					napi_gro_receive(&tp->napi, skb);
-				else
-					netif_rx(skb);
-			}
+			rtl8169_rx_vlan_tag(desc, skb);
+
+			if (likely(polling))
+				napi_gro_receive(&tp->napi, skb);
+			else
+				netif_rx(skb);
 
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
-- 
Ueimor

