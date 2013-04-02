From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next 6/8] r8169: add a new chip for RTL8111G
Date: Tue, 2 Apr 2013 16:23:40 +0800
Message-ID: <1364891022-3220-6-git-send-email-hayeswang@realtek.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new chip for RTL8111G series.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 45 ++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0211836..573b693 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -48,6 +48,7 @@
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
 #define FIRMWARE_8168G_2	"rtl_nic/rtl8168g-2.fw"
+#define FIRMWARE_8168G_3	"rtl_nic/rtl8168g-3.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -140,6 +141,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_39,
 	RTL_GIGA_MAC_VER_40,
 	RTL_GIGA_MAC_VER_41,
+	RTL_GIGA_MAC_VER_42,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -266,6 +268,9 @@ static const struct {
 							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_41] =
 		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_42] =
+		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_3,
+							JUMBO_9K, false),
 };
 #undef _R
 
@@ -514,6 +519,7 @@ enum rtl_register_content {
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
+	ClkReqEn	= (1 << 7),	/* Clock Request Enable */
 	MSIEnable	= (1 << 5),	/* 8169 only. Reserved in the 8168. */
 	PCI_Clock_66MHz = 0x01,
 	PCI_Clock_33MHz = 0x00,
@@ -534,6 +540,7 @@ enum rtl_register_content {
 	Spi_en		= (1 << 3),
 	LanWake		= (1 << 1),	/* LanWake enable/disable */
 	PMEStatus	= (1 << 0),	/* PME status can be reset by PCI RST# */
+	ASPM_en		= (1 << 0),	/* ASPM enable */
 
 	/* TBICSR p.28 */
 	TBIReset	= 0x80000000,
@@ -816,6 +823,7 @@ MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
 MODULE_FIRMWARE(FIRMWARE_8106E_1);
 MODULE_FIRMWARE(FIRMWARE_8168G_2);
+MODULE_FIRMWARE(FIRMWARE_8168G_3);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -2036,6 +2044,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168G family. */
+		{ 0x7cf00000, 0x50900000,	RTL_GIGA_MAC_VER_42 },
 		{ 0x7cf00000, 0x4c100000,	RTL_GIGA_MAC_VER_41 },
 		{ 0x7cf00000, 0x4c000000,	RTL_GIGA_MAC_VER_40 },
 
@@ -3439,6 +3448,11 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168g_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	rtl_apply_firmware(tp);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3624,6 +3638,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_40:
 		rtl8168g_1_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_42:
+		rtl8168g_2_hw_phy_config(tp);
+		break;
 
 	case RTL_GIGA_MAC_VER_41:
 	default:
@@ -3832,6 +3849,7 @@ static void rtl_init_mdio_ops(struct rtl8169_private *tp)
 		break;
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
 		ops->write	= r8168g_mdio_write;
 		ops->read	= r8168g_mdio_read;
 		break;
@@ -3859,6 +3877,7 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_39:
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -4121,6 +4140,7 @@ static void rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_38:
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -4165,6 +4185,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 		break;
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
 		break;
 	default:
@@ -4323,6 +4344,7 @@ static void rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	 */
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
 	default:
 		ops->disable	= NULL;
 		ops->enable	= NULL;
@@ -4430,6 +4452,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_42 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
@@ -5174,6 +5197,24 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
 }
 
+static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168g_2[] = {
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 },
+		{ 0x19, 0xffff,	0xfc00 },
+		{ 0x1e, 0xffff,	0x20eb }
+	};
+
+	rtl_hw_start_8168g_1(tp);
+
+	/* disable aspm and clock request before access ephy */
+	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
+	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
+	rtl_ephy_init(tp, e_info_8168g_2, ARRAY_SIZE(e_info_8168g_2));
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5279,6 +5320,9 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_41:
 		rtl_hw_start_8168g_1(tp);
 		break;
+	case RTL_GIGA_MAC_VER_42:
+		rtl_hw_start_8168g_2(tp);
+		break;
 
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
@@ -6766,6 +6810,7 @@ static void rtl_hw_initialize(struct rtl8169_private *tp)
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
 		rtl_hw_init_8168g(tp);
 		break;
 
-- 
1.8.1
