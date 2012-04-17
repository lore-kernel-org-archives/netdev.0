From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 5/7] r8169: support the new RTL8402 chip.
Date: Tue, 17 Apr 2012 12:59:39 +0200
Message-ID: <7e18dca16246b2891239cfc3c6e2dfcea715d353.1334660032.git.romieu@fr.zoreil.com>
References: <1334660032.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37860 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754710Ab2DQLE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 07:04:26 -0400
In-Reply-To: <1334660032.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  122 +++++++++++++++++++++++++++++++++-
 1 files changed, 121 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8a9cb20..03020a4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -44,6 +44,7 @@
 #define FIRMWARE_8168F_1	"rtl_nic/rtl8168f-1.fw"
 #define FIRMWARE_8168F_2	"rtl_nic/rtl8168f-2.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
+#define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -133,6 +134,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_34,
 	RTL_GIGA_MAC_VER_35,
 	RTL_GIGA_MAC_VER_36,
+	RTL_GIGA_MAC_VER_37,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -245,6 +247,9 @@ static const struct {
 	[RTL_GIGA_MAC_VER_36] =
 		_R("RTL8168f/8111f",	RTL_TD_1, FIRMWARE_8168F_2,
 							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_37] =
+		_R("RTL8402",		RTL_TD_1, FIRMWARE_8402_1,
+							JUMBO_1K, true),
 };
 #undef _R
 
@@ -357,6 +362,9 @@ enum rtl8168_8101_registers {
 #define	CSIAR_BYTE_ENABLE		0x0f
 #define	CSIAR_BYTE_ENABLE_SHIFT		12
 #define	CSIAR_ADDR_MASK			0x0fff
+#define CSIAR_FUNC_CARD			0x00000000
+#define CSIAR_FUNC_SDIO			0x00010000
+#define CSIAR_FUNC_NIC			0x00020000
 	PMCH			= 0x6f,
 	EPHYAR			= 0x80,
 #define	EPHYAR_FLAG			0x80000000
@@ -775,6 +783,7 @@ MODULE_FIRMWARE(FIRMWARE_8168E_3);
 MODULE_FIRMWARE(FIRMWARE_8105E_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
+MODULE_FIRMWARE(FIRMWARE_8402_1);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -1289,6 +1298,16 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
 				      0x0000003f, ERIAR_EXGMAC);
 		}
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_37) {
+		if (RTL_R8(PHYstatus) & _10bps) {
+			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
+				      0x4d02, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_0011,
+				      0x0060, ERIAR_EXGMAC);
+		} else {
+			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
+				      0x0000, ERIAR_EXGMAC);
+		}
 	}
 }
 
@@ -1902,6 +1921,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
 		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40900000,	RTL_GIGA_MAC_VER_29 },
@@ -3136,6 +3156,25 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	/* Disable ALDPS before setting firmware */
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(20);
+
+	rtl_apply_firmware(tp);
+
+	/* EEE setting */
+	rtl_eri_write(ioaddr, 0x1b0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x10, 0x401f);
+	rtl_writephy(tp, 0x19, 0x7030);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3224,6 +3263,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168f_2_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_37:
+		rtl8402_hw_phy_config(tp);
+		break;
+
 	default:
 		break;
 	}
@@ -3461,6 +3504,7 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
 	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_37:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3682,6 +3726,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_16:
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
+	case RTL_GIGA_MAC_VER_37:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -3991,7 +4036,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 			udelay(20);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
-	           tp->mac_version == RTL_GIGA_MAC_VER_36) {
+	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_37) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		while (!(RTL_R32(TxConfig) & TXCFG_EMPTY))
 			udelay(100);
@@ -4263,6 +4309,41 @@ static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
 	return value;
 }
 
+static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT |
+		CSIAR_FUNC_NIC);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u32 r8402_csi_read(void __iomem *ioaddr, int addr)
+{
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) | CSIAR_FUNC_NIC |
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
 static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
 {
 	struct csi_ops *ops = &tp->csi_ops;
@@ -4286,6 +4367,11 @@ static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
 		ops->read	= NULL;
 		break;
 
+	case RTL_GIGA_MAC_VER_37:
+		ops->write	= r8402_csi_write;
+		ops->read	= r8402_csi_read;
+		break;
+
 	default:
 		ops->write	= r8169_csi_write;
 		ops->read	= r8169_csi_read;
@@ -4871,6 +4957,36 @@ static void rtl_hw_start_8105e_2(struct rtl8169_private *tp)
 	rtl_ephy_write(ioaddr, 0x1e, rtl_ephy_read(ioaddr, 0x1e) | 0x8000);
 }
 
+static void rtl_hw_start_8402(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8402[] = {
+		{ 0x19,	0xffff, 0xff64 },
+		{ 0x1e,	0, 0x4000 }
+	};
+
+	rtl_csi_access_enable_2(tp);
+
+	/* Force LAN exit from ASPM if Rx/Tx are not idle */
+	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
+
+	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
+	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+
+	rtl_ephy_init(ioaddr, e_info_8402, ARRAY_SIZE(e_info_8402));
+
+	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00000006, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00,
+		     ERIAR_EXGMAC);
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4911,6 +5027,10 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_30:
 		rtl_hw_start_8105e_2(tp);
 		break;
+
+	case RTL_GIGA_MAC_VER_37:
+		rtl_hw_start_8402(tp);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
-- 
1.7.7.6
