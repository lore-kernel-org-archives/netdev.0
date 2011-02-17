From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 2/2] r8169: Support RTL8105E
Date: Thu, 17 Feb 2011 19:37:48 +0800
Message-ID: <1297942668-23274-2-git-send-email-hayeswang@realtek.com>
References: <1297942668-23274-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52241 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab1BQLkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 06:40:49 -0500
In-Reply-To: <1297942668-23274-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support the new chips for RTL8105E

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |  113 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 111 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9eaf78f..b80c583 100644
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
 
@@ -227,6 +232,10 @@ enum rtl_registers {
 	MultiIntr	= 0x5c,
 	PHYAR		= 0x60,
 	PHYstatus	= 0x6c,
+	DLLPR		= 0xd0,
+	DbgReg		= 0xd1,
+	TWSI		= 0xd2,
+	MCU		= 0xd3,
 	RxMaxSize	= 0xda,
 	CPlusCmd	= 0xe0,
 	IntrMitigate	= 0xe2,
@@ -427,6 +436,13 @@ enum rtl_register_content {
 
 	/* DumpCounterCommand */
 	CounterDump	= 0x8,
+
+	/* MCU */
+	EnNDP		= (1 << 3),
+	EnOOBReset		= (1 << 2),
+
+	/* DLLPR */
+	PmSwitch	= (1 << 6),
 };
 
 enum desc_status_bit {
@@ -568,6 +584,7 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 MODULE_FIRMWARE(FIRMWARE_8168D_1);
 MODULE_FIRMWARE(FIRMWARE_8168D_2);
+MODULE_FIRMWARE(FIRMWARE_8105E_1);
 
 static int rtl8169_open(struct net_device *dev);
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -1143,7 +1160,9 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		    (tp->mac_version != RTL_GIGA_MAC_VER_13) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
+		    (tp->mac_version != RTL_GIGA_MAC_VER_16) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_29) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_30)) {
 			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
 		} else {
 			netif_info(tp, link, dev,
@@ -1559,6 +1578,9 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
+		{ 0x7cf00000, 0x40900000,	RTL_GIGA_MAC_VER_29 },
+		{ 0x7c800000, 0x40800000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x34a00000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7cf00000, 0x24a00000,	RTL_GIGA_MAC_VER_09 },
 		{ 0x7cf00000, 0x34900000,	RTL_GIGA_MAC_VER_08 },
@@ -2435,6 +2457,57 @@ static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001},
+		{ 0x15, 0x7701},
+		{ 0x1f, 0x0000}
+	};
+
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(100);
+
+	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
+		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+
+	if(RTL_R8(0xef) & 0x08) {
+		static const struct phy_reg phy_reg_init1[] = {
+			{ 0x1f, 0x0005},
+			{ 0x1a, 0x0004},
+			{ 0x1f, 0x0000}
+		};
+		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
+	} else {
+		static const struct phy_reg phy_reg_init1[] = {
+			{ 0x1f, 0x0005},
+			{ 0x1a, 0x0000},
+			{ 0x1f, 0x0000}
+		};
+		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
+	}
+
+	if(RTL_R8(0xef) & 0x010) {
+		static const struct phy_reg phy_reg_init1[] = {
+			{ 0x1f, 0x0004},
+			{ 0x1c, 0x0000},
+			{ 0x1f, 0x0000}
+		};
+		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
+	} else {
+		static const struct phy_reg phy_reg_init1[] = {
+			{ 0x1f, 0x0004},
+			{ 0x1c, 0x0200},
+			{ 0x1f, 0x0000}
+		};
+		rtl_writephy_batch(tp, phy_reg_init1, ARRAY_SIZE(phy_reg_init1));
+	}
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2502,6 +2575,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_28:
 		rtl8168d_4_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_29:
+	case RTL_GIGA_MAC_VER_30:
+		rtl8105e_hw_phy_config(tp);
+		break;
 
 	default:
 		break;
@@ -2940,6 +3017,8 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_09:
 	case RTL_GIGA_MAC_VER_10:
 	case RTL_GIGA_MAC_VER_16:
+	case RTL_GIGA_MAC_VER_29:
+	case RTL_GIGA_MAC_VER_30:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -3895,6 +3974,31 @@ static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
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
+	RTL_W8(MCU, RTL_R8(MCU) | EnNDP | EnOOBReset);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PmSwitch);
+
+	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3925,6 +4029,11 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_09:
 		rtl_hw_start_8102e_2(ioaddr, pdev);
 		break;
+
+	case RTL_GIGA_MAC_VER_29:
+	case RTL_GIGA_MAC_VER_30:
+		rtl_hw_start_8105e_1(ioaddr, pdev);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
-- 
1.7.3.2

