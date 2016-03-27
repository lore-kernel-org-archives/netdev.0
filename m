From: Kast Bernd <kastbernd@gmx.de>
Subject: [RFC] r8169: Module parameter for opt-in of ASPM
Date: Mon, 28 Mar 2016 00:54:54 +0200
Message-ID: <20160327225454.GA13032@ASUS-Bernd.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

this patch adds a module parameter in order to activate ASPM.
Basically it reapplies d64ec841517a25f6d468bde9f67e5b4cffdc67c7, which
was reverted as some people reported delayed link status detection and
increased boot times: https://lkml.org/lkml/2013/2/6/372.

The differences to this patch are:
	1) Turned off by default but with module parameter for activation
	2) Flags for aspm and clock request are set after ephy_init
	3) Minor changes because of merging

Motivation for changes compared to previous patch:
	1) Probably the patch wouldn't be merged when it is active by
	default

	2) There are comments, that state: "disable aspm and clock
	request before access ephy", thus I tried to respect that and
	activate it afterwards.
	Perhaps that was even the cause for the problems that let to
	reverting the old patch, but unfortunately couldn't reproduce
	these bugs and therefore wasn't	able to check if it's solved with
	my version.

Remarks:
	1) This patch drops power usage	from 13W to 8W and therefore
	leads to a vastly increased battery life and reduced heat
	dissipation on my notebook. Some people reported similar issues
	on different hardware (for example):
	https://bugzilla.kernel.org/show_bug.cgi?id=72211
	http://www.spinics.net/lists/netdev/msg298949.html
	Especially on newer systems (Haswell) the power savings seem to
	be huge, as the network chip prevents the CPU from entering
	deeper package sleep states (no PC6/PC7 are reached, only PC3).

	2) To benefit from the power savings a reboot is not sufficient.
	At least on my system it has to be powered off completely (cold
	boot). There seem to be no kernel functions to enable a link
	state, there is just pci_disable_link_state to disable low power
	states, thus this problem can't be solved by now.

	3) This patch was tested only on a single system and supports
	only the same cards than the old patch, as I couldn't find any
	documents to read about the registers and flags of newer cards.
	If anybody could send me a link, or tell me that it's save to
	set the same flags on newer cards this patch could probably also
	cover those cards.

Should I add support for newer cards, too?
Is there any chance to enable ASPM by default again?
Which improvements do I need to do in order to get this patch to the
kernel again?

I would appreciate any kind of feedback.

Signed-off-by: Kast Bernd <kastbernd@gmx.de>
---
 drivers/net/ethernet/realtek/r8169.c | 82 ++++++++++++++++++++++++++++++++----
 1 file changed, 74 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 537974c..6a533a4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -346,6 +346,7 @@ MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
 static int use_dac;
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
+module_param(use_aspm, int, 0);
+MODULE_PARM_DESC(use_aspm, "Enable ASPM power saving. Unsave on some systems");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
 MODULE_LICENSE("GPL");
@@ -5899,7 +5903,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-	rtl_disable_clock_request(pdev);
+	if (!use_aspm)
+		rtl_disable_clock_request(pdev);
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
@@ -5909,7 +5914,13 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
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
@@ -5934,13 +5945,21 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
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
@@ -5957,6 +5976,12 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
+	if (use_aspm) {
+		RTL_W32(MISC, (RTL_R32(MISC) | FORCE_CLK));
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	}
+
 	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
@@ -6031,6 +6056,12 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
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
@@ -6049,6 +6080,12 @@ static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
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
@@ -6068,6 +6105,12 @@ static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
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
@@ -6514,6 +6557,12 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_pcie_state_l2l3_enable(tp, false);
 }
 
@@ -6541,6 +6590,12 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8402, ARRAY_SIZE(e_info_8402));
 
+	if (use_aspm) {
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+		RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
+	}
+
 	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
@@ -6561,7 +6616,16 @@ static void rtl_hw_start_8106(struct rtl8169_private *tp)
 	/* Force LAN exit from ASPM if Rx/Tx are not idle */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
 
-	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
+	if (!use_aspm) {
+		RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) &
+				~EARLY_TALLY_EN);
+	} else {
+		RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN | FORCE_CLK) &
+				~EARLY_TALLY_EN);
+		RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+		RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	}
+
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
 
@@ -8181,8 +8245,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* disable ASPM completely as that cause random device stop working
 	 * problems as well as full system hangs for some PCIe devices users */
-	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
-				     PCIE_LINK_STATE_CLKPM);
+	if (!use_aspm) {
+		pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S
+				| PCIE_LINK_STATE_L1 | PCIE_LINK_STATE_CLKPM);
+	}
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
-- 
2.7.4
