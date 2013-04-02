From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next 5/8] r8169: Update the RTL8111G parameters
Date: Tue, 2 Apr 2013 16:23:39 +0800
Message-ID: <1364891022-3220-5-git-send-email-hayeswang@realtek.com>
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

- replace rtl8168g-1.fw with rtl8168g-2.fw which support new method.
- fix PHY power down is useless.
- disable rx early which causes the rx abnormal.
- enable auto fifo.
- set 10M IFG to default value.
- fix the conflict between jumbo frame and flow control.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7e7d37..0211836 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -47,7 +47,7 @@
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
-#define FIRMWARE_8168G_1	"rtl_nic/rtl8168g-1.fw"
+#define FIRMWARE_8168G_2	"rtl_nic/rtl8168g-2.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -262,7 +262,7 @@ static const struct {
 		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_1,
 							JUMBO_1K, true),
 	[RTL_GIGA_MAC_VER_40] =
-		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_1,
+		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_2,
 							JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_41] =
 		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),
@@ -329,6 +329,7 @@ enum rtl_registers {
 #define	RXCFG_FIFO_SHIFT		13
 					/* No threshold before first PCI xfer */
 #define	RX_FIFO_THRESH			(7 << RXCFG_FIFO_SHIFT)
+#define	RX_EARLY_OFF			(1 << 11)
 #define	RXCFG_DMA_SHIFT			8
 					/* Unlimited maximum PCI burst. */
 #define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
@@ -814,7 +815,7 @@ MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
 MODULE_FIRMWARE(FIRMWARE_8106E_1);
-MODULE_FIRMWARE(FIRMWARE_8168G_1);
+MODULE_FIRMWARE(FIRMWARE_8168G_2);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -3967,6 +3968,8 @@ static void r8168_phy_power_down(struct rtl8169_private *tp)
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
 		rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE | BMCR_PDOWN);
 		break;
 
@@ -4028,6 +4031,11 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0x00000000,
+			     0xfc000000, ERIAR_EXGMAC);
+		break;
 	}
 }
 
@@ -4045,6 +4053,11 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0xfc000000,
+			     0x00000000, ERIAR_EXGMAC);
+		break;
 	}
 
 	r8168_phy_power_up(tp);
@@ -4150,6 +4163,10 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
+		break;
 	default:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST);
 		break;
@@ -5128,6 +5145,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
+	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
+
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_0101, 0x080002, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xcc, ERIAR_MASK_0001, 0x38, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xd0, ERIAR_MASK_0001, 0x48, ERIAR_EXGMAC);
@@ -5139,6 +5158,7 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 
 	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
 	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_eri_write(tp, 0x2f8, ERIAR_MASK_0011, 0x1d8f, ERIAR_EXGMAC);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
@@ -5150,7 +5170,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 
-	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x06, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
-- 
1.8.1
