From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH RFC 2/2] r8169: jumbo fixes.
Date: Sun, 17 Jul 2011 22:53:10 +0200
Message-ID: <20110717205310.GB6932@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52991 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab1GQVIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 17:08:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Hayes, I'd welcome comments regarding the jumbo enable/disable stuff)

- fix features : jumbo frames and checksumming can not be used at the
  same time.

- introduce hw_jumbo_{enable / disable} helpers. Their content has been
  creatively extracted from Realtek's own drivers. As an illustration,
  it would be nice to know how/if the MaxTxPacketSize register operates
  when the device can work with a 9k jumbo frame as its documentation
  (8168c) can not be applied beyond ~7k.

- rtl_tx_performance_tweak is moved forward. No change.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  302 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 248 insertions(+), 54 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ea8ee93..9451958 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -141,84 +141,104 @@ enum rtl_tx_desc_version {
 	RTL_TD_1	= 1,
 };
 
-#define _R(NAME,TD,FW) \
-	{ .name = NAME, .txd_version = TD, .fw_name = FW }
+#define JUMBO_1K	ETH_DATA_LEN
+#define JUMBO_4K	(4*1024 - ETH_HLEN - 2)
+#define JUMBO_6K	(6*1024 - ETH_HLEN - 2)
+#define JUMBO_7K	(7*1024 - ETH_HLEN - 2)
+#define JUMBO_9K	(9*1024 - ETH_HLEN - 2)
+
+#define _R(NAME,TD,FW,SZ,B) {	\
+	.name = NAME,		\
+	.txd_version = TD,	\
+	.fw_name = FW,		\
+	.jumbo_max = SZ,	\
+	.jumbo_csum_ok = B	\
+}
 
 static const struct {
 	const char *name;
 	enum rtl_tx_desc_version txd_version;
 	const char *fw_name;
+	u16 jumbo_max;
+	bool jumbo_csum_ok;
 } rtl_chip_infos[] = {
 	/* PCI devices. */
 	[RTL_GIGA_MAC_VER_01] =
-		_R("RTL8169",		RTL_TD_0, NULL),
+		_R("RTL8169",		RTL_TD_0, NULL, JUMBO_7K, true),
 	[RTL_GIGA_MAC_VER_02] =
-		_R("RTL8169s",		RTL_TD_0, NULL),
+		_R("RTL8169s",		RTL_TD_0, NULL, JUMBO_7K, true),
 	[RTL_GIGA_MAC_VER_03] =
-		_R("RTL8110s",		RTL_TD_0, NULL),
+		_R("RTL8110s",		RTL_TD_0, NULL, JUMBO_7K, true),
 	[RTL_GIGA_MAC_VER_04] =
-		_R("RTL8169sb/8110sb",	RTL_TD_0, NULL),
+		_R("RTL8169sb/8110sb",	RTL_TD_0, NULL, JUMBO_7K, true),
 	[RTL_GIGA_MAC_VER_05] =
-		_R("RTL8169sc/8110sc",	RTL_TD_0, NULL),
+		_R("RTL8169sc/8110sc",	RTL_TD_0, NULL, JUMBO_7K, true),
 	[RTL_GIGA_MAC_VER_06] =
-		_R("RTL8169sc/8110sc",	RTL_TD_0, NULL),
+		_R("RTL8169sc/8110sc",	RTL_TD_0, NULL, JUMBO_7K, true),
 	/* PCI-E devices. */
 	[RTL_GIGA_MAC_VER_07] =
-		_R("RTL8102e",		RTL_TD_1, NULL),
+		_R("RTL8102e",		RTL_TD_1, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_08] =
-		_R("RTL8102e",		RTL_TD_1, NULL),
+		_R("RTL8102e",		RTL_TD_1, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_09] =
-		_R("RTL8102e",		RTL_TD_1, NULL),
+		_R("RTL8102e",		RTL_TD_1, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_10] =
-		_R("RTL8101e",		RTL_TD_0, NULL),
+		_R("RTL8101e",		RTL_TD_0, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_11] =
-		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+		_R("RTL8168b/8111b",	RTL_TD_0, NULL, JUMBO_4K, false),
 	[RTL_GIGA_MAC_VER_12] =
-		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+		_R("RTL8168b/8111b",	RTL_TD_0, NULL, JUMBO_4K, false),
 	[RTL_GIGA_MAC_VER_13] =
-		_R("RTL8101e",		RTL_TD_0, NULL),
+		_R("RTL8101e",		RTL_TD_0, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_14] =
-		_R("RTL8100e",		RTL_TD_0, NULL),
+		_R("RTL8100e",		RTL_TD_0, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_15] =
-		_R("RTL8100e",		RTL_TD_0, NULL),
+		_R("RTL8100e",		RTL_TD_0, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_16] =
-		_R("RTL8101e",		RTL_TD_0, NULL),
+		_R("RTL8101e",		RTL_TD_0, NULL, JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_17] =
-		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+		_R("RTL8168b/8111b",	RTL_TD_1, NULL, JUMBO_4K, false),
 	[RTL_GIGA_MAC_VER_18] =
-		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL),
+		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_19] =
-		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_20] =
-		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_21] =
-		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_22] =
-		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_23] =
-		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL),
+		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_24] =
-		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL),
+		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL, JUMBO_6K, false),
 	[RTL_GIGA_MAC_VER_25] =
-		_R("RTL8168d/8111d",	RTL_TD_1, FIRMWARE_8168D_1),
+		_R("RTL8168d/8111d",	RTL_TD_1, FIRMWARE_8168D_1,
+							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_26] =
-		_R("RTL8168d/8111d",	RTL_TD_1, FIRMWARE_8168D_2),
+		_R("RTL8168d/8111d",	RTL_TD_1, FIRMWARE_8168D_2,
+							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_27] =
-		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL),
+		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL, JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_28] =
-		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL),
+		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL, JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_29] =
-		_R("RTL8105e",		RTL_TD_1, FIRMWARE_8105E_1),
+		_R("RTL8105e",		RTL_TD_1, FIRMWARE_8105E_1,
+							JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_30] =
-		_R("RTL8105e",		RTL_TD_1, FIRMWARE_8105E_1),
+		_R("RTL8105e",		RTL_TD_1, FIRMWARE_8105E_1,
+							JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_31] =
-		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL),
+		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL, JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_32] =
-		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1),
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1,
+							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_33] =
-		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2),
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2,
+							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_34] =
-		_R("RTL8168evl/8111evl",RTL_TD_1, FIRMWARE_8168E_3)
+		_R("RTL8168evl/8111evl",RTL_TD_1, FIRMWARE_8168E_3,
+							JUMBO_9K, false),
 };
 #undef _R
 
@@ -457,8 +477,12 @@ enum rtl_register_content {
 	/* Config3 register p.25 */
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
+	Jumbo_En0	= (1 << 2),	/* 8168 only. Reserved in the 8168b */
 	Beacon_en	= (1 << 0),	/* 8168 only. Reserved in the 8168b */
 
+	/* Config4 register */
+	Jumbo_En1	= (1 << 1),	/* 8168 only. Reserved in the 8168b */
+
 	/* Config5 register p.27 */
 	BWF		= (1 << 6),	/* Accept Broadcast wakeup frame */
 	MWF		= (1 << 5),	/* Accept Multicast wakeup frame */
@@ -667,6 +691,11 @@ struct rtl8169_private {
 		void (*up)(struct rtl8169_private *);
 	} pll_power_ops;
 
+	struct jumbo_ops {
+		void (*enable)(struct rtl8169_private *);
+		void (*disable)(struct rtl8169_private *);
+	} jumbo_ops;
+
 	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
@@ -727,6 +756,19 @@ static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
 
+static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
+{
+	int cap = pci_pcie_cap(pdev);
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
 static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1467,9 +1509,15 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static u32 rtl8169_fix_features(struct net_device *dev, u32 features)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+
 	if (dev->mtu > TD_MSS_MAX)
 		features &= ~NETIF_F_ALL_TSO;
 
+	if (dev->mtu > JUMBO_1K &&
+	    !rtl_chip_infos[tp->mac_version].jumbo_csum_ok)
+		features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
+
 	return features;
 }
 
@@ -3438,8 +3486,8 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	r8168_phy_power_up(tp);
 }
 
-static void rtl_pll_power_op(struct rtl8169_private *tp,
-			     void (*op)(struct rtl8169_private *))
+static void rtl_generic_op(struct rtl8169_private *tp,
+			   void (*op)(struct rtl8169_private *))
 {
 	if (op)
 		op(tp);
@@ -3447,12 +3495,12 @@ static void rtl_pll_power_op(struct rtl8169_private *tp,
 
 static void rtl_pll_power_down(struct rtl8169_private *tp)
 {
-	rtl_pll_power_op(tp, tp->pll_power_ops.down);
+	rtl_generic_op(tp, tp->pll_power_ops.down);
 }
 
 static void rtl_pll_power_up(struct rtl8169_private *tp)
 {
-	rtl_pll_power_op(tp, tp->pll_power_ops.up);
+	rtl_generic_op(tp, tp->pll_power_ops.up);
 }
 
 static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
@@ -3541,6 +3589,150 @@ static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
 	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
 }
 
+static void rtl_hw_jumbo_enable(struct rtl8169_private *tp)
+{
+	rtl_generic_op(tp, tp->jumbo_ops.enable);
+}
+
+static void rtl_hw_jumbo_disable(struct rtl8169_private *tp)
+{
+	rtl_generic_op(tp, tp->jumbo_ops.disable);
+}
+
+static void r8168c_hw_jumbo_enable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
+	RTL_W8(Config4, RTL_R8(Config4) | Jumbo_En1);
+	rtl_tx_performance_tweak(tp->pci_dev, 0x2 << MAX_READ_REQUEST_SHIFT);
+}
+
+static void r8168c_hw_jumbo_disable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
+	RTL_W8(Config4, RTL_R8(Config4) & ~Jumbo_En1);
+	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
+}
+
+static void r8168dp_hw_jumbo_enable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
+}
+
+static void r8168dp_hw_jumbo_disable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
+}
+
+static void r8168e_hw_jumbo_enable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	RTL_W8(MaxTxPacketSize, 0x3f);
+	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
+	RTL_W8(Config4, RTL_R8(Config4) | 0x01);
+	pci_write_config_byte(pdev, 0x79, 0x20);
+}
+
+static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	RTL_W8(MaxTxPacketSize, 0x0c);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
+	RTL_W8(Config4, RTL_R8(Config4) & ~0x01);
+	pci_write_config_byte(pdev, 0x79, 0x50);
+}
+
+static void r8168b_0_hw_jumbo_enable(struct rtl8169_private *tp)
+{
+	rtl_tx_performance_tweak(tp->pci_dev,
+		(0x2 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
+}
+
+static void r8168b_0_hw_jumbo_disable(struct rtl8169_private *tp)
+{
+	rtl_tx_performance_tweak(tp->pci_dev,
+		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
+}
+
+static void r8168b_1_hw_jumbo_enable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	r8168b_0_hw_jumbo_enable(tp);
+
+	RTL_W8(Config4, RTL_R8(Config4) | (1 << 0));
+}
+
+static void r8168b_1_hw_jumbo_disable(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	r8168b_0_hw_jumbo_disable(tp);
+
+	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
+}
+
+static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
+{
+	struct jumbo_ops *ops = &tp->jumbo_ops;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_11:
+		ops->disable	= r8168b_0_hw_jumbo_disable;
+		ops->enable	= r8168b_0_hw_jumbo_enable;
+		break;
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		ops->disable	= r8168b_1_hw_jumbo_disable;
+		ops->enable	= r8168b_1_hw_jumbo_enable;
+		break;
+	case RTL_GIGA_MAC_VER_18: /* Wild guess. Needs info from Realtek. */
+	case RTL_GIGA_MAC_VER_19:
+	case RTL_GIGA_MAC_VER_20:
+	case RTL_GIGA_MAC_VER_21: /* Wild guess. Needs info from Realtek. */
+	case RTL_GIGA_MAC_VER_22:
+	case RTL_GIGA_MAC_VER_23:
+	case RTL_GIGA_MAC_VER_24:
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
+		ops->disable	= r8168c_hw_jumbo_disable;
+		ops->enable	= r8168c_hw_jumbo_enable;
+		break;
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
+		ops->disable	= r8168dp_hw_jumbo_disable;
+		ops->enable	= r8168dp_hw_jumbo_enable;
+		break;
+	case RTL_GIGA_MAC_VER_31: /* Wild guess. Needs info from Realtek. */
+	case RTL_GIGA_MAC_VER_32:
+	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_34:
+		ops->disable	= r8168e_hw_jumbo_disable;
+		ops->enable	= r8168e_hw_jumbo_enable;
+		break;
+
+	/*
+	 * No action needed for jumbo frames with 8169.
+	 * No jumbo for 810x at all.
+	 */
+	default:
+		ops->disable	= NULL;
+		ops->enable	= NULL;
+		break;
+	}
+}
+
 static void rtl_hw_reset(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3685,6 +3877,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
+	rtl_init_jumbo_ops(tp);
 
 	rtl8169_print_mac_version(tp);
 
@@ -3766,6 +3959,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
 		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
 		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
+	if (rtl_chip_infos[chipset].jumbo_max != JUMBO_1K) {
+		netif_info(tp, probe, dev, "jumbo features [frames: %d bytes, "
+			   "rx/tx checksumming: %s]\n",
+			   rtl_chip_infos[chipset].jumbo_max,
+			   rtl_chip_infos[chipset].jumbo_csum_ok ? "ok" : "ko");
+	}
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
@@ -4122,19 +4321,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
-static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
-{
-	int cap = pci_pcie_cap(pdev);
-
-	if (cap) {
-		u16 ctl;
-
-		pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &ctl);
-		ctl = (ctl & ~PCI_EXP_DEVCTL_READRQ) | force;
-		pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, ctl);
-	}
-}
-
 static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
 {
 	u32 csi;
@@ -4714,9 +4900,17 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < ETH_ZLEN || new_mtu > SafeMtu)
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (new_mtu < ETH_ZLEN ||
+	    new_mtu > rtl_chip_infos[tp->mac_version].jumbo_max)
 		return -EINVAL;
 
+	if (new_mtu > ETH_DATA_LEN)
+		rtl_hw_jumbo_enable(tp);
+	else
+		rtl_hw_jumbo_disable(tp);
+
 	dev->mtu = new_mtu;
 	netdev_update_features(dev);
 
-- 
1.7.4.4

