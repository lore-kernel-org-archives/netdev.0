From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 0/4] Pull request for 'davem-next.r8169' branch
Date: Thu, 22 Sep 2011 23:02:02 +0200
Message-ID: <20110922210202.GA16362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48056 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860Ab1IVVDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 17:03:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

The series includes the remaining part of Hayes's recent patches as
well as some jumbo frames changes.

The pci_write_config_byte(pdev, 0x79, ... should be replaced with some
rtl_tx_performance_tweak variant. Feel free to peel the top-most patch
if you want me to respin it with the jumbo changes patch.

Distance from 'davem-next' (8decf868790b48a727d7e7ca164f2bcd3c1389c0)
---------------------------------------------------------------------

d58d46b5d85139d18eb939aa7279c160bab70484
deb9d93c89d311714a60809b28160e538e1cbb43
c2218925f3a653ac6c39e62eb0e10232d2b44dab
3090bd9a3102331ed981280ef05ee5433ce978d7

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |  487 ++++++++++++++++++++++++++++++----
 1 files changed, 430 insertions(+), 57 deletions(-)

Shortlog
--------

Francois Romieu (2):
      r8169: expand received packet length indication.
      r8169: jumbo fixes.

Hayes Wang (2):
      r8169: define the early size for 8111evl
      r8169: support new chips of RTL8111F

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6eb9f4e..2ce6070 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -42,6 +42,8 @@
 #define FIRMWARE_8168E_1	"rtl_nic/rtl8168e-1.fw"
 #define FIRMWARE_8168E_2	"rtl_nic/rtl8168e-2.fw"
 #define FIRMWARE_8168E_3	"rtl_nic/rtl8168e-3.fw"
+#define FIRMWARE_8168F_1	"rtl_nic/rtl8168f-1.fw"
+#define FIRMWARE_8168F_2	"rtl_nic/rtl8168f-2.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 
 #ifdef RTL8169_DEBUG
@@ -133,6 +135,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_32,
 	RTL_GIGA_MAC_VER_33,
 	RTL_GIGA_MAC_VER_34,
+	RTL_GIGA_MAC_VER_35,
+	RTL_GIGA_MAC_VER_36,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -141,84 +145,110 @@ enum rtl_tx_desc_version {
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
+	.jumbo_tx_csum = B	\
+}
 
 static const struct {
 	const char *name;
 	enum rtl_tx_desc_version txd_version;
 	const char *fw_name;
+	u16 jumbo_max;
+	bool jumbo_tx_csum;
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
+	[RTL_GIGA_MAC_VER_35] =
+		_R("RTL8168f/8111f",	RTL_TD_1, FIRMWARE_8168F_1,
+							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_36] =
+		_R("RTL8168f/8111f",	RTL_TD_1, FIRMWARE_8168F_2,
+							JUMBO_9K, false),
 };
 #undef _R
 
@@ -311,6 +341,7 @@ enum rtl_registers {
 	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
 
 #define TxPacketMax	(8064 >> 7)
+#define EarlySize	0x27
 
 	FuncEvent	= 0xf0,
 	FuncEventMask	= 0xf4,
@@ -460,8 +491,12 @@ enum rtl_register_content {
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
@@ -670,6 +705,11 @@ struct rtl8169_private {
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
@@ -714,6 +754,8 @@ MODULE_FIRMWARE(FIRMWARE_8168E_1);
 MODULE_FIRMWARE(FIRMWARE_8168E_2);
 MODULE_FIRMWARE(FIRMWARE_8168E_3);
 MODULE_FIRMWARE(FIRMWARE_8105E_1);
+MODULE_FIRMWARE(FIRMWARE_8168F_1);
+MODULE_FIRMWARE(FIRMWARE_8168F_2);
 
 static int rtl8169_open(struct net_device *dev);
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -732,6 +774,19 @@ static void rtl8169_down(struct net_device *dev);
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
@@ -1202,6 +1257,19 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 			     ERIAR_EXGMAC);
 		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
 			     ERIAR_EXGMAC);
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_35 ||
+		   tp->mac_version == RTL_GIGA_MAC_VER_36) {
+		if (RTL_R8(PHYstatus) & _1000bpsF) {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x00000011, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x00000005, ERIAR_EXGMAC);
+		} else {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x0000001f, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x0000003f, ERIAR_EXGMAC);
+		}
 	}
 }
 
@@ -1487,9 +1555,15 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static u32 rtl8169_fix_features(struct net_device *dev, u32 features)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+
 	if (dev->mtu > TD_MSS_MAX)
 		features &= ~NETIF_F_ALL_TSO;
 
+	if (dev->mtu > JUMBO_1K &&
+	    !rtl_chip_infos[tp->mac_version].jumbo_tx_csum)
+		features &= ~NETIF_F_IP_CSUM;
+
 	return features;
 }
 
@@ -1741,6 +1815,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
+		/* 8168F family. */
+		{ 0x7cf00000, 0x48100000,	RTL_GIGA_MAC_VER_36 },
+		{ 0x7cf00000, 0x48000000,	RTL_GIGA_MAC_VER_35 },
+
 		/* 8168E family. */
 		{ 0x7c800000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
 		{ 0x7cf00000, 0x2c200000,	RTL_GIGA_MAC_VER_33 },
@@ -2875,6 +2953,97 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168f_1_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		/* Channel estimation fine tune */
+		{ 0x1f, 0x0003 },
+		{ 0x09, 0xa20f },
+		{ 0x1f, 0x0000 },
+
+		/* Modify green table for giga & fnet */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b55 },
+		{ 0x06, 0x0000 },
+		{ 0x05, 0x8b5e },
+		{ 0x06, 0x0000 },
+		{ 0x05, 0x8b67 },
+		{ 0x06, 0x0000 },
+		{ 0x05, 0x8b70 },
+		{ 0x06, 0x0000 },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x0078 },
+		{ 0x17, 0x0000 },
+		{ 0x19, 0x00fb },
+		{ 0x1f, 0x0000 },
+
+		/* Modify green table for 10M */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b79 },
+		{ 0x06, 0xaa00 },
+		{ 0x1f, 0x0000 },
+
+		/* Disable hiimpedance detection (RTCT) */
+		{ 0x1f, 0x0003 },
+		{ 0x01, 0x328a },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_apply_firmware(tp);
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	/* For 4-corner performance improve */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b80);
+	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	/* Improve 10M EEE waveform */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b86);
+	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* Improve 2-pair detection performance */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x4000, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
+static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	rtl_apply_firmware(tp);
+
+	/* For 4-corner performance improve */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b80);
+	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	/* Improve 10M EEE waveform */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b86);
+	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -2999,6 +3168,12 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_34:
 		rtl8168e_2_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_35:
+		rtl8168f_1_hw_phy_config(tp);
+		break;
+	case RTL_GIGA_MAC_VER_36:
+		rtl8168f_2_hw_phy_config(tp);
+		break;
 
 	default:
 		break;
@@ -3483,8 +3658,8 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	r8168_phy_power_up(tp);
 }
 
-static void rtl_pll_power_op(struct rtl8169_private *tp,
-			     void (*op)(struct rtl8169_private *))
+static void rtl_generic_op(struct rtl8169_private *tp,
+			   void (*op)(struct rtl8169_private *))
 {
 	if (op)
 		op(tp);
@@ -3492,12 +3667,12 @@ static void rtl_pll_power_op(struct rtl8169_private *tp,
 
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
@@ -3534,6 +3709,8 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
 	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_35:
+	case RTL_GIGA_MAC_VER_36:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -3586,6 +3763,150 @@ static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
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
@@ -3730,6 +4051,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
+	rtl_init_jumbo_ops(tp);
 
 	rtl8169_print_mac_version(tp);
 
@@ -3813,6 +4135,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
 		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
 		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
+	if (rtl_chip_infos[chipset].jumbo_max != JUMBO_1K) {
+		netif_info(tp, probe, dev, "jumbo features [frames: %d bytes, "
+			   "tx checksumming: %s]\n",
+			   rtl_chip_infos[chipset].jumbo_max,
+			   rtl_chip_infos[chipset].jumbo_tx_csum ? "ok" : "ko");
+	}
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
@@ -4008,7 +4336,9 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
-	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_36) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
@@ -4167,19 +4497,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
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
@@ -4479,7 +4796,50 @@ static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
 		     ERIAR_EXGMAC);
 
-	RTL_W8(MaxTxPacketSize, 0x27);
+	RTL_W8(MaxTxPacketSize, EarlySize);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
+	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+
+	/* Adjust EEE LED frequency */
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
+	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+}
+
+static void rtl_hw_start_8168f_1(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static const struct ephy_info e_info_8168f_1[] = {
+		{ 0x06, 0x00c0,	0x0020 },
+		{ 0x08, 0x0001,	0x0002 },
+		{ 0x09, 0x0000,	0x0080 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_csi_access_enable_1(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x00000060, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
+		     ERIAR_EXGMAC);
+
+	RTL_W8(MaxTxPacketSize, EarlySize);
 
 	rtl_disable_clock_request(pdev);
 
@@ -4588,6 +4948,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168e_2(ioaddr, pdev);
 		break;
 
+	case RTL_GIGA_MAC_VER_35:
+	case RTL_GIGA_MAC_VER_36:
+		rtl_hw_start_8168f_1(ioaddr, pdev);
+		break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
@@ -4759,9 +5124,17 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
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
 
@@ -5356,7 +5729,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		} else {
 			struct sk_buff *skb;
 			dma_addr_t addr = le64_to_cpu(desc->addr);
-			int pkt_size = (status & 0x00001FFF) - 4;
+			int pkt_size = (status & 0x00003fff) - 4;
 
 			/*
 			 * The driver does not support incoming fragmented
-- 
Ueimor
