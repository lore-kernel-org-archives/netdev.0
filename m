From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/7] sky2: Add PCI device specfic register 4 & 5
Date: Mon, 04 Jun 2007 17:23:22 -0700
Message-ID: <20070605002738.678824366@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37605 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759268AbXFEAnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:21 -0400
Content-Disposition: inline; filename=sky2-pci-reg45.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to setup more PCI control control registers are on Yukon EX.
Some of these also exist on Yukon EC-U as well.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   18 ++++++++----
 drivers/net/sky2.h |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 89 insertions(+), 6 deletions(-)

--- a/drivers/net/sky2.c	2007-06-04 08:46:34.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-04 08:46:41.000000000 -0700
@@ -217,13 +217,19 @@ static void sky2_power_on(struct sky2_hw
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
-		u32 reg1;
+		u32 reg;
 
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
-		reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
-		reg1 &= P_ASPM_CONTROL_MSK;
-		sky2_pci_write32(hw, PCI_DEV_REG4, reg1);
-		sky2_pci_write32(hw, PCI_DEV_REG5, 0);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG4);
+		/* set all bits to 0 except bits 15..12 and 8 */
+		reg &= P_ASPM_CONTROL_MSK;
+		sky2_pci_write32(hw, PCI_DEV_REG4, reg);
+
+		reg = sky2_pci_read32(hw, PCI_DEV_REG5);
+		/* set all bits to 0 except bits 28 & 27 */
+		reg &= P_CTL_TIM_VMAIN_AV_MSK;
+		sky2_pci_write32(hw, PCI_DEV_REG5, reg);
+
+		sky2_pci_write32(hw, PCI_CFG_REG_1, 0);
 	}
 }
 
--- a/drivers/net/sky2.h	2007-06-04 08:45:25.000000000 -0700
+++ b/drivers/net/sky2.h	2007-06-04 08:46:41.000000000 -0700
@@ -14,6 +14,8 @@ enum {
 	PCI_DEV_REG3	= 0x80,
 	PCI_DEV_REG4	= 0x84,
 	PCI_DEV_REG5    = 0x88,
+	PCI_CFG_REG_0	= 0x90,
+	PCI_CFG_REG_1	= 0x94,
 };
 
 enum {
@@ -28,6 +30,7 @@ enum {
 enum pci_dev_reg_1 {
 	PCI_Y2_PIG_ENA	 = 1<<31, /* Enable Plug-in-Go (YUKON-2) */
 	PCI_Y2_DLL_DIS	 = 1<<30, /* Disable PCI DLL (YUKON-2) */
+	PCI_SW_PWR_ON_RST= 1<<30, /* SW Power on Reset (Yukon-EX) */
 	PCI_Y2_PHY2_COMA = 1<<29, /* Set PHY 2 to Coma Mode (YUKON-2) */
 	PCI_Y2_PHY1_COMA = 1<<28, /* Set PHY 1 to Coma Mode (YUKON-2) */
 	PCI_Y2_PHY2_POWD = 1<<27, /* Set PHY 2 to Power Down (YUKON-2) */
@@ -67,6 +70,80 @@ enum pci_dev_reg_4 {
 				  | P_ASPM_CLKRUN_REQUEST | P_ASPM_INT_FIFO_EMPTY,
 };
 
+/*	PCI_OUR_REG_5		32 bit	Our Register 5 (Yukon-ECU only) */
+enum pci_dev_reg_5 {
+					/* Bit 31..27:	for A3 & later */
+	P_CTL_DIV_CORE_CLK_ENA	= 1<<31, /* Divide Core Clock Enable */
+	P_CTL_SRESET_VMAIN_AV	= 1<<30, /* Soft Reset for Vmain_av De-Glitch */
+	P_CTL_BYPASS_VMAIN_AV	= 1<<29, /* Bypass En. for Vmain_av De-Glitch */
+	P_CTL_TIM_VMAIN_AV_MSK	= 3<<27, /* Bit 28..27: Timer Vmain_av Mask */
+					 /* Bit 26..16: Release Clock on Event */
+	P_REL_PCIE_RST_DE_ASS	= 1<<26, /* PCIe Reset De-Asserted */
+	P_REL_GPHY_REC_PACKET	= 1<<25, /* GPHY Received Packet */
+	P_REL_INT_FIFO_N_EMPTY	= 1<<24, /* Internal FIFO Not Empty */
+	P_REL_MAIN_PWR_AVAIL	= 1<<23, /* Main Power Available */
+	P_REL_CLKRUN_REQ_REL	= 1<<22, /* CLKRUN Request Release */
+	P_REL_PCIE_RESET_ASS	= 1<<21, /* PCIe Reset Asserted */
+	P_REL_PME_ASSERTED	= 1<<20, /* PME Asserted */
+	P_REL_PCIE_EXIT_L1_ST	= 1<<19, /* PCIe Exit L1 State */
+	P_REL_LOADER_NOT_FIN	= 1<<18, /* EPROM Loader Not Finished */
+	P_REL_PCIE_RX_EX_IDLE	= 1<<17, /* PCIe Rx Exit Electrical Idle State */
+	P_REL_GPHY_LINK_UP	= 1<<16, /* GPHY Link Up */
+
+					/* Bit 10.. 0: Mask for Gate Clock */
+	P_GAT_PCIE_RST_ASSERTED	= 1<<10,/* PCIe Reset Asserted */
+	P_GAT_GPHY_N_REC_PACKET	= 1<<9, /* GPHY Not Received Packet */
+	P_GAT_INT_FIFO_EMPTY	= 1<<8, /* Internal FIFO Empty */
+	P_GAT_MAIN_PWR_N_AVAIL	= 1<<7, /* Main Power Not Available */
+	P_GAT_CLKRUN_REQ_REL	= 1<<6, /* CLKRUN Not Requested */
+	P_GAT_PCIE_RESET_ASS	= 1<<5, /* PCIe Reset Asserted */
+	P_GAT_PME_DE_ASSERTED	= 1<<4, /* PME De-Asserted */
+	P_GAT_PCIE_ENTER_L1_ST	= 1<<3, /* PCIe Enter L1 State */
+	P_GAT_LOADER_FINISHED	= 1<<2, /* EPROM Loader Finished */
+	P_GAT_PCIE_RX_EL_IDLE	= 1<<1, /* PCIe Rx Electrical Idle State */
+	P_GAT_GPHY_LINK_DOWN	= 1<<0,	/* GPHY Link Down */
+
+	PCIE_OUR5_EVENT_CLK_D3_SET = P_REL_GPHY_REC_PACKET |
+				     P_REL_INT_FIFO_N_EMPTY |
+				     P_REL_PCIE_EXIT_L1_ST |
+				     P_REL_PCIE_RX_EX_IDLE |
+				     P_GAT_GPHY_N_REC_PACKET |
+				     P_GAT_INT_FIFO_EMPTY |
+				     P_GAT_PCIE_ENTER_L1_ST |
+				     P_GAT_PCIE_RX_EL_IDLE,
+};
+
+#/*	PCI_CFG_REG_1			32 bit	Config Register 1 (Yukon-Ext only) */
+enum pci_cfg_reg1 {
+	P_CF1_DIS_REL_EVT_RST	= 1<<24, /* Dis. Rel. Event during PCIE reset */
+										/* Bit 23..21: Release Clock on Event */
+	P_CF1_REL_LDR_NOT_FIN	= 1<<23, /* EEPROM Loader Not Finished */
+	P_CF1_REL_VMAIN_AVLBL	= 1<<22, /* Vmain available */
+	P_CF1_REL_PCIE_RESET	= 1<<21, /* PCI-E reset */
+										/* Bit 20..18: Gate Clock on Event */
+	P_CF1_GAT_LDR_NOT_FIN	= 1<<20, /* EEPROM Loader Finished */
+	P_CF1_GAT_PCIE_RX_IDLE	= 1<<19, /* PCI-E Rx Electrical idle */
+	P_CF1_GAT_PCIE_RESET	= 1<<18, /* PCI-E Reset */
+	P_CF1_PRST_PHY_CLKREQ	= 1<<17, /* Enable PCI-E rst & PM2PHY gen. CLKREQ */
+	P_CF1_PCIE_RST_CLKREQ	= 1<<16, /* Enable PCI-E rst generate CLKREQ */
+
+	P_CF1_ENA_CFG_LDR_DONE	= 1<<8, /* Enable core level Config loader done */
+
+	P_CF1_ENA_TXBMU_RD_IDLE	= 1<<1, /* Enable TX BMU Read  IDLE for ASPM */
+	P_CF1_ENA_TXBMU_WR_IDLE	= 1<<0, /* Enable TX BMU Write IDLE for ASPM */
+
+	PCIE_CFG1_EVENT_CLK_D3_SET = P_CF1_DIS_REL_EVT_RST |
+					P_CF1_REL_LDR_NOT_FIN |
+					P_CF1_REL_VMAIN_AVLBL |
+					P_CF1_REL_PCIE_RESET |
+					P_CF1_GAT_LDR_NOT_FIN |
+					P_CF1_GAT_PCIE_RESET |
+					P_CF1_PRST_PHY_CLKREQ |
+					P_CF1_ENA_CFG_LDR_DONE |
+					P_CF1_ENA_TXBMU_RD_IDLE |
+					P_CF1_ENA_TXBMU_WR_IDLE,
+};
+
 
 #define PCI_STATUS_ERROR_BITS (PCI_STATUS_DETECTED_PARITY | \
 			       PCI_STATUS_SIG_SYSTEM_ERROR | \

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

