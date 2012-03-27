From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 5/5] r8169: support RTL8411
Date: Tue, 27 Mar 2012 15:53:54 +0800
Message-ID: <1332834834-5185-5-git-send-email-hayeswang@realtek.com>
References: <1332834834-5185-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:59460 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab2C0H55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 03:57:57 -0400
In-Reply-To: <1332834834-5185-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support the new chip RTL8411.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  140 +++++++++++++++++++++++++++++++++-
 1 files changed, 138 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6c2835f..99daad7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -46,6 +46,7 @@
 #define FIRMWARE_8168F_2	"rtl_nic/rtl8168f-2.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
+#define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -136,6 +137,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_35,
 	RTL_GIGA_MAC_VER_36,
 	RTL_GIGA_MAC_VER_37,
+	RTL_GIGA_MAC_VER_38,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -250,6 +252,9 @@ static const struct {
 							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_37] =
 		_R("RTL8402",		RTL_TD_1, FIRMWARE_8402_1,
+							JUMBO_1K, true),
+	[RTL_GIGA_MAC_VER_38] =
+		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
 							JUMBO_1K, true)
 };
 #undef _R
@@ -783,6 +788,7 @@ MODULE_FIRMWARE(FIRMWARE_8105E_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
+MODULE_FIRMWARE(FIRMWARE_8411_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -1262,7 +1268,8 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 	if (!netif_running(dev))
 		return;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		if (RTL_R8(PHYstatus) & _1000bpsF) {
 			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
 				      0x00000011, ERIAR_EXGMAC);
@@ -1867,6 +1874,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168F family. */
+		{ 0x7c800000, 0x48800000,	RTL_GIGA_MAC_VER_38 },
 		{ 0x7cf00000, 0x48100000,	RTL_GIGA_MAC_VER_36 },
 		{ 0x7cf00000, 0x48000000,	RTL_GIGA_MAC_VER_35 },
 
@@ -3084,6 +3092,104 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl8168f_hw_phy_config(tp);
 }
 
+static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
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
+		{ 0x19, 0x00aa },
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
+
+	rtl_apply_firmware(tp);
+
+	rtl8168f_hw_phy_config(tp);
+
+	/* Improve 2-pair detection performance */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x4000, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	/* Modify green table for giga */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b54);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0800);
+	rtl_writephy(tp, 0x05, 0x8b5d);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0800);
+	rtl_writephy(tp, 0x05, 0x8a7c);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x05, 0x8a7f);
+	rtl_w1w0_phy(tp, 0x06, 0x0100, 0x0000);
+	rtl_writephy(tp, 0x05, 0x8a82);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x05, 0x8a85);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x05, 0x8a88);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* uc same-seed solution */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x8000, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* eee setting */
+	rtl_w1w0_eri(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x0020);
+	rtl_w1w0_phy(tp, 0x15, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x0d, 0x0007);
+	rtl_writephy(tp, 0x0e, 0x003c);
+	rtl_writephy(tp, 0x0d, 0x4007);
+	rtl_writephy(tp, 0x0e, 0x0000);
+	rtl_writephy(tp, 0x0d, 0x0000);
+
+	/* Green feature */
+	rtl_writephy(tp, 0x1f, 0x0003);
+	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
+	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3238,6 +3344,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8402_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_38:
+		rtl8411_hw_phy_config(tp);
+		break;
+
 	default:
 		break;
 	}
@@ -3476,6 +3586,7 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3722,6 +3833,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
+	case RTL_GIGA_MAC_VER_38:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -4008,7 +4120,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
-	           tp->mac_version == RTL_GIGA_MAC_VER_37) {
+	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
@@ -4317,6 +4430,7 @@ static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
 		ops->write	= r8402_csi_write;
 		ops->read	= r8402_csi_read;
 		break;
@@ -4705,6 +4819,24 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 }
 
+static void rtl_hw_start_8411(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168f_1[] = {
+		{ 0x06, 0x00c0,	0x0020 },
+		{ 0x0f, 0xffff,	0x5200 },
+		{ 0x1e, 0x0000,	0x4000 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_hw_start_8168f(tp);
+
+	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000,
+		     ERIAR_EXGMAC);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4802,6 +4934,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168f_1(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_38:
+		rtl_hw_start_8411(tp);
+		break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.7.7.6
