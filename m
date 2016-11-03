From: Kast Bernd <kastbernd@gmx.de>
Subject: [PATCH] r8169: Module parameter for opt-in of ASPM
Date: Fri, 4 Nov 2016 00:33:06 +0100
Message-ID: <20161103233306.GA9368@ASUS-Bernd.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a module parameter in order to activate ASPM. By that
the CPU can enter deep sleep modes (PC6) and power consumption can be
reduced (for example from 13W to 8W on my notebook with a Haswell CPU).
Basically, it reapplies d64ec841517a25f6d468bde9f67e5b4cffdc67c7, which
was reverted due to delayed link status detection and increased boot
times on some systems. These bugs are avoided by two actions:
        1) ASPM is turned off by default to avoid any problems with the
	default	configuration.
        2) Flags for ASPM and clock request are set after ephy_init,
	which wasn't respected on the previous patch. Thus ASPM with
	this patch could work even with previously failing systems.

Signed-off-by: Kast Bernd <kastbernd@gmx.de>
---
 drivers/net/ethernet/realtek/r8169.c | 100 ++++++++++++++++++++++++++++++++---
 1 file changed, 92 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index bf000d8..9d72198 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -346,6 +346,7 @@ MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
 static int use_dac = -1;
+static int use_aspm;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -509,6 +510,7 @@ enum rtl8168_registers {
 #define PWM_EN				(1 << 22)
 #define RXDV_GATED_EN			(1 << 19)
 #define EARLY_TALLY_EN			(1 << 16)
+#define FORCE_CLK			(1 << 15) /* force clock request */
 };
 
 enum rtl_register_content {
@@ -860,6 +862,8 @@ MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
+module_param(use_aspm, int, 0000);
+MODULE_PARM_DESC(use_aspm, "Enable ASPM power saving. Unsafe on some systems");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
 MODULE_LICENSE("GPL");
@@ -5924,7 +5928,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-	rtl_disable_clock_request(pdev);
+	if (!use_aspm)
+		rtl_disable_clock_request(pdev);
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
@@ -5934,7 +5939,13 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
-	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+
+	if (use_aspm) {
+		RTL_W8(Config5, (RTL_R8(Config5) & ~Spi_en) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	} else {
+		RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+	}
 }
 
 static void rtl_hw_start_8168f(struct rtl8169_private *tp)
@@ -5959,13 +5970,21 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-	rtl_disable_clock_request(pdev);
+	if (!use_aspm)
+		rtl_disable_clock_request(pdev);
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
-	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
-	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+
+	if (use_aspm) {
+		RTL_W32(MISC, RTL_R32(MISC) | PWM_EN | FORCE_CLK);
+		RTL_W8(Config5, (RTL_R8(Config5) & ~Spi_en) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	} else {
+		RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
+		RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
+	}
 }
 
 static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
@@ -6056,6 +6075,12 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8168g_1, ARRAY_SIZE(e_info_8168g_1));
+
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
 }
 
 static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
@@ -6074,6 +6099,12 @@ static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
 	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8168g_2, ARRAY_SIZE(e_info_8168g_2));
+
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
 }
 
 static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
@@ -6093,6 +6124,12 @@ static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
 	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8411_2, ARRAY_SIZE(e_info_8411_2));
+
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
 }
 
 static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
@@ -6115,6 +6152,12 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8168h_1, ARRAY_SIZE(e_info_8168h_1));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_0101, 0x00080002, ERIAR_EXGMAC);
@@ -6250,6 +6293,12 @@ static void rtl_hw_start_8168ep_1(struct rtl8169_private *tp)
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8168ep_1, ARRAY_SIZE(e_info_8168ep_1));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_hw_start_8168ep(tp);
 }
 
@@ -6267,6 +6316,12 @@ static void rtl_hw_start_8168ep_2(struct rtl8169_private *tp)
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8168ep_2, ARRAY_SIZE(e_info_8168ep_2));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_hw_start_8168ep(tp);
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
@@ -6289,6 +6344,12 @@ static void rtl_hw_start_8168ep_3(struct rtl8169_private *tp)
 	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
 	rtl_ephy_init(tp, e_info_8168ep_3, ARRAY_SIZE(e_info_8168ep_3));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_hw_start_8168ep(tp);
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
@@ -6539,6 +6600,12 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_pcie_state_l2l3_enable(tp, false);
 }
 
@@ -6566,6 +6633,12 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8402, ARRAY_SIZE(e_info_8402));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
@@ -6586,7 +6659,16 @@ static void rtl_hw_start_8106(struct rtl8169_private *tp)
 	/* Force LAN exit from ASPM if Rx/Tx are not idle */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
 
-	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
+	if (use_aspm) {
+		RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN | FORCE_CLK) &
+			~EARLY_TALLY_EN);
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	} else {
+		RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) &
+			~EARLY_TALLY_EN);
+	}
+
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
 
@@ -8217,8 +8299,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* disable ASPM completely as that cause random device stop working
 	 * problems as well as full system hangs for some PCIe devices users */
-	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
-				     PCIE_LINK_STATE_CLKPM);
+	if (!use_aspm) {
+		pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S |
+			PCIE_LINK_STATE_L1 | PCIE_LINK_STATE_CLKPM);
+	}
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
-- 
2.10.2
