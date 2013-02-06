From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 4/5] r8169: Update the RTL8111G parameters
Date: Wed, 6 Feb 2013 22:46:26 +0800
Message-ID: <1360161987-3268-4-git-send-email-hayeswang@realtek.com>
References: <1360161987-3268-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360161987-3268-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- replace rtl8168g-1.fw with rtl8168g-2.fw which support new method.
- fix PHY power down is useless.
- disable rx early which causes the rx abnormal.
- fix the conflict between jumbo frame and flow control.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 55a7fb5..c25a329 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -47,7 +47,7 @@
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
-#define FIRMWARE_8168G_1	"rtl_nic/rtl8168g-1.fw"
+#define FIRMWARE_8168G_1	"rtl_nic/rtl8168g-2.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -329,6 +329,7 @@ enum rtl_registers {
 #define	RXCFG_FIFO_SHIFT		13
 					/* No threshold before first PCI xfer */
 #define	RX_FIFO_THRESH			(7 << RXCFG_FIFO_SHIFT)
+#define	RX_EARLY_OFF			(1 << 11)
 #define	RXCFG_DMA_SHIFT			8
 					/* Unlimited maximum PCI burst. */
 #define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
@@ -4077,6 +4078,10 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x40);
+		break;
 	}
 }
 
@@ -4094,6 +4099,10 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0x40);
+		break;
 	}
 
 	r8168_phy_power_up(tp);
@@ -4199,6 +4208,10 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
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
@@ -5190,7 +5203,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 
-	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x06, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
-- 
1.8.1
