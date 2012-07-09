From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/6] r8169: add RTL8106E support.
Date: Tue, 10 Jul 2012 00:44:05 +0200
Message-ID: <5598bfe5191d09cdd622aeac39badc42508b227f.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59220 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab2GIW4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:42 -0400
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   56 ++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d7a04e0..7afc593 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -46,6 +46,7 @@
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
+#define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -141,6 +142,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_36,
 	RTL_GIGA_MAC_VER_37,
 	RTL_GIGA_MAC_VER_38,
+	RTL_GIGA_MAC_VER_39,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -259,6 +261,9 @@ static const struct {
 	[RTL_GIGA_MAC_VER_38] =
 		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
 							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_39] =
+		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_1,
+							JUMBO_1K, true),
 };
 #undef _R
 
@@ -431,7 +436,9 @@ enum rtl8168_registers {
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
+#define DISABLE_LAN_EN			(1 << 23) /* Enable GPIO pin */
 #define PWM_EN				(1 << 22)
+#define EARLY_TALLY_EN			(1 << 16)
 };
 
 enum rtl_register_content {
@@ -794,6 +801,7 @@ MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
+MODULE_FIRMWARE(FIRMWARE_8106E_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -1933,6 +1941,8 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x44900000,	RTL_GIGA_MAC_VER_39 },
+		{ 0x7c800000, 0x44800000,	RTL_GIGA_MAC_VER_39 },
 		{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
 		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
@@ -3273,6 +3283,30 @@ static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0004 },
+		{ 0x10, 0xc07f },
+		{ 0x19, 0x7030 },
+		{ 0x1f, 0x0000 }
+	};
+
+	/* Disable ALDPS before ram code */
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(100);
+
+	rtl_apply_firmware(tp);
+
+	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3369,6 +3403,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8411_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_39:
+		rtl8106e_hw_phy_config(tp);
+		break;
+
 	default:
 		break;
 	}
@@ -3608,6 +3646,7 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_37:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_39:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3830,6 +3869,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
 	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_39:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -5123,6 +5163,18 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 		     ERIAR_EXGMAC);
 }
 
+static void rtl_hw_start_8106(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	/* Force LAN exit from ASPM if Rx/Tx are not idle */
+	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
+
+	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
+	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5167,6 +5219,10 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_37:
 		rtl_hw_start_8402(tp);
 		break;
+
+	case RTL_GIGA_MAC_VER_39:
+		rtl_hw_start_8106(tp);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
-- 
1.7.10.4
