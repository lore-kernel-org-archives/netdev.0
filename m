From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 6/6] r8169: support RTL8111E-VL
Date: Tue, 5 Jul 2011 17:44:55 +0800
Message-ID: <1309859095-32031-6-git-send-email-hayeswang@realtek.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41485 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab1GEJqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:46:47 -0400
In-Reply-To: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support RTL8111E-VL

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |  188 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 181 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 01da16a..bee9e49 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -41,6 +41,7 @@
 #define FIRMWARE_8168D_2	"rtl_nic/rtl8168d-2.fw"
 #define FIRMWARE_8168E_1	"rtl_nic/rtl8168e-1.fw"
 #define FIRMWARE_8168E_2	"rtl_nic/rtl8168e-2.fw"
+#define FIRMWARE_8168E_3	"rtl_nic/rtl8168e-3.fw"
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 
 #ifdef RTL8169_DEBUG
@@ -133,6 +134,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_31,
 	RTL_GIGA_MAC_VER_32,
 	RTL_GIGA_MAC_VER_33,
+	RTL_GIGA_MAC_VER_34,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -216,7 +218,9 @@ static const struct {
 	[RTL_GIGA_MAC_VER_32] =
 		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1),
 	[RTL_GIGA_MAC_VER_33] =
-		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2)
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2),
+	[RTL_GIGA_MAC_VER_34] =
+		_R("RTL8168evl/8111evl",RTL_TD_1, FIRMWARE_8168E_3)
 };
 #undef _R
 
@@ -1151,6 +1155,39 @@ static void rtl8169_xmii_reset_enable(struct rtl8169_private *tp)
 	rtl_writephy(tp, MII_BMCR, val & 0xffff);
 }
 
+static void rtl_link_chg_patch(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct net_device *dev = tp->dev;
+
+	if (!netif_running(dev))
+		return;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		if (RTL_R8(PHYstatus) & _1000bpsF) {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x00000011, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x00000005, ERIAR_EXGMAC);
+		} else if (RTL_R8(PHYstatus) & _100bps) {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x0000001f, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x00000005, ERIAR_EXGMAC);
+		} else {
+			rtl_eri_write(ioaddr, 0x1bc, ERIAR_MASK_1111,
+				      0x0000001f, ERIAR_EXGMAC);
+			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
+				      0x0000003f, ERIAR_EXGMAC);
+		}
+		/* Reset packet filter */
+		rtl_eri_write_w0w1(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01,
+				   0x00, ERIAR_EXGMAC);
+		rtl_eri_write_w0w1(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00,
+				   0x01, ERIAR_EXGMAC);
+	}
+}
+
 static void __rtl8169_check_link_status(struct net_device *dev,
 					struct rtl8169_private *tp,
 					void __iomem *ioaddr, bool pm)
@@ -1159,6 +1196,7 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
+		rtl_link_chg_patch(tp);
 		/* This is to cancel a scheduled suspend if there's one. */
 		if (pm)
 			pm_request_resume(&tp->pci_dev->dev);
@@ -1687,6 +1725,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168E family. */
+		{ 0x7c800000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
 		{ 0x7cf00000, 0x2c200000,	RTL_GIGA_MAC_VER_33 },
 		{ 0x7cf00000, 0x2c100000,	RTL_GIGA_MAC_VER_32 },
 		{ 0x7c800000, 0x2c000000,	RTL_GIGA_MAC_VER_33 },
@@ -2664,7 +2703,7 @@ static void rtl8168d_4_hw_phy_config(struct rtl8169_private *tp)
 	rtl_patchphy(tp, 0x0d, 1 << 5);
 }
 
-static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
+static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		/* Enable Delay cap */
@@ -2737,6 +2776,91 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x0d, 0x0000);
 }
 
+static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		/* Enable Delay cap */
+		{ 0x1f, 0x0004 },
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x00ac },
+		{ 0x18, 0x0006 },
+		{ 0x1f, 0x0002 },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		/* Channel estimation fine tune */
+		{ 0x1f, 0x0003 },
+		{ 0x09, 0xa20f },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		/* Green Setting */
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0x8b5b },
+		{ 0x06, 0x9222 },
+		{ 0x05, 0x8b6d },
+		{ 0x06, 0x8000 },
+		{ 0x05, 0x8b76 },
+		{ 0x06, 0x8000 },
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
+	rtl_w1w0_phy(tp, 0x17, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002D);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	/* improve 10M EEE waveform */
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
+
+	/* EEE setting */
+	rtl_eri_write_w0w1(tp->mmio_addr, 0x1b0, ERIAR_MASK_1111, 0x0003,
+			   0x0000, ERIAR_EXGMAC);
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b85);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x2000);
+	rtl_writephy(tp, 0x1f, 0x0004);
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x0020);
+	rtl_w1w0_phy(tp, 0x06, 0x0000, 0x0100);
+	rtl_writephy(tp, 0x1f, 0x0002);
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
@@ -2856,7 +2980,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl8168e_hw_phy_config(tp);
+		rtl8168e_1_hw_phy_config(tp);
+		break;
+	case RTL_GIGA_MAC_VER_34:
+		rtl8168e_2_hw_phy_config(tp);
 		break;
 
 	default:
@@ -3235,6 +3362,7 @@ static void r8168_phy_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_28:
 	case RTL_GIGA_MAC_VER_31:
 		rtl_writephy(tp, 0x0e, 0x0200);
+	case RTL_GIGA_MAC_VER_34:
 	default:
 		rtl_writephy(tp, MII_BMCR, BMCR_PDOWN);
 		break;
@@ -3364,6 +3492,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_31:
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_34:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -3838,6 +3967,9 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		while (!(RTL_R32(TxConfig) & TX_EMPTY))
+			udelay(100);
 	} else {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		udelay(100);
@@ -4245,9 +4377,9 @@ static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_enable_clock_request(pdev);
 }
 
-static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	static const struct ephy_info e_info_8168e[] = {
+	static const struct ephy_info e_info_8168e_1[] = {
 		{ 0x00, 0x0200,	0x0100 },
 		{ 0x00, 0x0000,	0x0004 },
 		{ 0x06, 0x0002,	0x0001 },
@@ -4265,7 +4397,7 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	rtl_csi_access_enable_2(ioaddr);
 
-	rtl_ephy_init(ioaddr, e_info_8168e, ARRAY_SIZE(e_info_8168e));
+	rtl_ephy_init(ioaddr, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4280,6 +4412,45 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
+static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static const struct ephy_info e_info_8168e_2[] = {
+		{ 0x09, 0x0000,	0x0080 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_csi_access_enable_1(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_eri_write(ioaddr, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
+	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x07ff0060, ERIAR_EXGMAC);
+	rtl_eri_write_w0w1(ioaddr, 0x1b0, ERIAR_MASK_0001, 0x00, 0x10,
+			   ERIAR_EXGMAC);
+	rtl_eri_write_w0w1(ioaddr, 0xd4, ERIAR_MASK_0011, 0xff00, 0x0c00,
+			   ERIAR_EXGMAC);
+
+	RTL_W8(MaxTxPacketSize, 0x27);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W32(TxConfig, RTL_R32(TxConfig) | AUTO_FIFO);
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
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4368,7 +4539,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
-		rtl_hw_start_8168e(ioaddr, pdev);
+		rtl_hw_start_8168e_1(ioaddr, pdev);
+		break;
+	case RTL_GIGA_MAC_VER_34:
+		rtl_hw_start_8168e_2(ioaddr, pdev);
 		break;
 
 	default:
-- 
1.7.3.2

