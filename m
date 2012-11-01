From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8169: enable internal ASPM and clock request settings
Date: Thu, 1 Nov 2012 22:37:31 +0800
Message-ID: <1351780651-1271-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following chips need to enable internal settings to let ASPM
and clock request work.

RTL8111E-VL, RTL8111F, RTL8411, RTL8111G
RTL8105, RTL8402, RTL8106

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 123c6a5..87d03f6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -456,6 +456,7 @@ enum rtl8168_registers {
 #define PWM_EN				(1 << 22)
 #define RXDV_GATED_EN			(1 << 19)
 #define EARLY_TALLY_EN			(1 << 16)
+#define FORCE_CLK			(1 << 15) /* force clock request */
 };
 
 enum rtl_register_content {
@@ -519,6 +520,7 @@ enum rtl_register_content {
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
+	ClkReqEn	= (1 << 7),	/* Clock Request Enable */
 	MSIEnable	= (1 << 5),	/* 8169 only. Reserved in the 8168. */
 	PCI_Clock_66MHz = 0x01,
 	PCI_Clock_33MHz = 0x00,
@@ -539,6 +541,7 @@ enum rtl_register_content {
 	Spi_en		= (1 << 3),
 	LanWake		= (1 << 1),	/* LanWake enable/disable */
 	PMEStatus	= (1 << 0),	/* PME status can be reset by PCI RST# */
+	ASPM_en		= (1 << 0),	/* ASPM enable */
 
 	/* TBICSR p.28 */
 	TBIReset	= 0x80000000,
@@ -5046,8 +5049,6 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-	rtl_disable_clock_request(pdev);
-
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 
@@ -5056,7 +5057,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
-	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+	RTL_W8(Config5, (RTL_R8(Config5) & ~Spi_en) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
 }
 
 static void rtl_hw_start_8168f(struct rtl8169_private *tp)
@@ -5081,13 +5083,12 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-	rtl_disable_clock_request(pdev);
-
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
-	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
-	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN | FORCE_CLK);
+	RTL_W8(Config5, (RTL_R8(Config5) & ~Spi_en) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
 }
 
 static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
@@ -5145,7 +5146,10 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
+	RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
 	RTL_W8(MaxTxPacketSize, EarlySize);
+	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
 
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
@@ -5361,6 +5365,9 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
+	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
 
 	rtl_ephy_init(tp, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
@@ -5386,6 +5393,9 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
+	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
 
 	rtl_ephy_init(tp, e_info_8402, ARRAY_SIZE(e_info_8402));
 
@@ -5407,7 +5417,10 @@ static void rtl_hw_start_8106(struct rtl8169_private *tp)
 	/* Force LAN exit from ASPM if Rx/Tx are not idle */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
 
-	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
+	RTL_W32(MISC, RTL_R32(MISC) & ~EARLY_TALLY_EN);
+	RTL_W32(MISC, RTL_R32(MISC) | DISABLE_LAN_EN | FORCE_CLK);
+	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
 }
-- 
1.7.11.4
