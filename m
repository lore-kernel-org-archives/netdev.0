From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 05/12] sky2: advanced error reporting
Date: Wed, 29 Aug 2007 12:58:14 -0700
Message-ID: <20070829195842.939833136@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33526 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932453AbXH2UCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:02:35 -0400
Content-Disposition: inline; filename=sky2-recoverable.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the kernel interfaces for advanced error reporting.
This should be cleaner and clear up errors on boot.

For those systems with busted BIOS's that don't correctly 
support mmconfig, advanced error reporting will be disabled.
The PCI registers for advanced error reporting start at 0x100 which
is too large to be accessed by legacy functions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   51 +++++++++++++++++++++++++++------------------------
 drivers/net/sky2.h |   41 -----------------------------------------
 2 files changed, 27 insertions(+), 65 deletions(-)

--- a/drivers/net/sky2.c	2007-08-29 11:40:53.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:41:07.000000000 -0700
@@ -31,6 +31,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
+#include <linux/aer.h>
 #include <linux/ip.h>
 #include <net/ip.h>
 #include <linux/tcp.h>
@@ -2369,7 +2370,11 @@ static void sky2_hw_error(struct sky2_hw
 
 static void sky2_hw_intr(struct sky2_hw *hw)
 {
+	struct pci_dev *pdev = hw->pdev;
 	u32 status = sky2_read32(hw, B0_HWE_ISRC);
+	u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
+
+	status &= hwmsk;
 
 	if (status & Y2_IS_TIST_OV)
 		sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ);
@@ -2379,7 +2384,7 @@ static void sky2_hw_intr(struct sky2_hw 
 
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
-			dev_err(&hw->pdev->dev, "PCI hardware error (0x%x)\n",
+			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
 		sky2_pci_write16(hw, PCI_STATUS,
@@ -2388,22 +2393,13 @@ static void sky2_hw_intr(struct sky2_hw 
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
-		u32 pex_err;
-
-		pex_err = sky2_pci_read32(hw, PEX_UNC_ERR_STAT);
-
-		if (net_ratelimit())
-			dev_err(&hw->pdev->dev, "PCI Express error (0x%x)\n",
-				pex_err);
+		int pos = pci_find_aer_capability(hw->pdev);
+		u32 err;
 
-		/* clear the interrupt */
-		sky2_pci_write32(hw, PEX_UNC_ERR_STAT,
-				       0xffffffffUL);
-		if (pex_err & PEX_FATAL_ERRORS) {
-			u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
-			hwmsk &= ~Y2_IS_PCI_EXP;
-			sky2_write32(hw, B0_HWE_IMSK, hwmsk);
-		}
+		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, &err);
+  		if (net_ratelimit())
+			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
+		pci_cleanup_aer_uncorrect_error_status(pdev);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2641,8 +2637,10 @@ static int __devinit sky2_init(struct sk
 
 static void sky2_reset(struct sky2_hw *hw)
 {
+	struct pci_dev *pdev = hw->pdev;
 	u16 status;
-	int i;
+	int i, cap;
+	u32 hwe_mask = Y2_HWE_ALL_MASK;
 
 	/* disable ASF */
 	if (hw->chip_id == CHIP_ID_YUKON_EX) {
@@ -2666,10 +2664,19 @@ static void sky2_reset(struct sky2_hw *h
 
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
-	/* clear any PEX errors */
-	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP))
-		sky2_pci_write32(hw, PEX_UNC_ERR_STAT, 0xffffffffUL);
+	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (cap) {
+		/* Check for advanced error reporting */
+		pci_cleanup_aer_uncorrect_error_status(pdev);
+		pci_cleanup_aer_correct_error_status(pdev);
+
+		/* If error bit is stuck on ignore it */
+		if (sky2_read32(hw, B0_HWE_ISRC) & Y2_IS_PCI_EXP)
+			dev_info(&pdev->dev, "ignoring stuck error report bit\n");
 
+		else if (pci_enable_pcie_error_reporting(pdev))
+			hwe_mask |= Y2_IS_PCI_EXP;
+	}
 
 	sky2_power_on(hw);
 
@@ -2721,7 +2728,7 @@ static void sky2_reset(struct sky2_hw *h
 		sky2_write8(hw, RAM_BUFFER(i, B3_RI_RTO_XS2), SK_RI_TO_53);
 	}
 
-	sky2_write32(hw, B0_HWE_IMSK, Y2_HWE_ALL_MASK);
+	sky2_write32(hw, B0_HWE_IMSK, hwe_mask);
 
 	for (i = 0; i < hw->ports; i++)
 		sky2_gmac_reset(hw, i);
--- a/drivers/net/sky2.h	2007-08-29 11:40:51.000000000 -0700
+++ b/drivers/net/sky2.h	2007-08-29 11:41:07.000000000 -0700
@@ -18,14 +18,6 @@ enum {
 	PCI_CFG_REG_1	= 0x94,
 };
 
-enum {
-	PEX_DEV_CAP	= 0xe4,
-	PEX_DEV_CTRL	= 0xe8,
-	PEX_DEV_STA	= 0xea,
-	PEX_LNK_STAT	= 0xf2,
-	PEX_UNC_ERR_STAT= 0x104,
-};
-
 /* Yukon-2 */
 enum pci_dev_reg_1 {
 	PCI_Y2_PIG_ENA	 = 1<<31, /* Enable Plug-in-Go (YUKON-2) */
@@ -151,38 +143,6 @@ enum pci_cfg_reg1 {
 			       PCI_STATUS_REC_TARGET_ABORT | \
 			       PCI_STATUS_PARITY)
 
-enum pex_dev_ctrl {
-	PEX_DC_MAX_RRS_MSK	= 7<<12, /* Bit 14..12:	Max. Read Request Size */
-	PEX_DC_EN_NO_SNOOP	= 1<<11,/* Enable No Snoop */
-	PEX_DC_EN_AUX_POW	= 1<<10,/* Enable AUX Power */
-	PEX_DC_EN_PHANTOM	= 1<<9,	/* Enable Phantom Functions */
-	PEX_DC_EN_EXT_TAG	= 1<<8,	/* Enable Extended Tag Field */
-	PEX_DC_MAX_PLS_MSK	= 7<<5,	/* Bit  7.. 5:	Max. Payload Size Mask */
-	PEX_DC_EN_REL_ORD	= 1<<4,	/* Enable Relaxed Ordering */
-	PEX_DC_EN_UNS_RQ_RP	= 1<<3,	/* Enable Unsupported Request Reporting */
-	PEX_DC_EN_FAT_ER_RP	= 1<<2,	/* Enable Fatal Error Reporting */
-	PEX_DC_EN_NFA_ER_RP	= 1<<1,	/* Enable Non-Fatal Error Reporting */
-	PEX_DC_EN_COR_ER_RP	= 1<<0,	/* Enable Correctable Error Reporting */
-};
-#define  PEX_DC_MAX_RD_RQ_SIZE(x) (((x)<<12) & PEX_DC_MAX_RRS_MSK)
-
-/* PEX_UNC_ERR_STAT	 PEX Uncorrectable Errors Status Register (Yukon-2) */
-enum pex_err {
-	PEX_UNSUP_REQ 	= 1<<20, /* Unsupported Request Error */
-
-	PEX_MALFOR_TLP	= 1<<18, /* Malformed TLP */
-
-	PEX_UNEXP_COMP	= 1<<16, /* Unexpected Completion */
-
-	PEX_COMP_TO	= 1<<14, /* Completion Timeout */
-	PEX_FLOW_CTRL_P	= 1<<13, /* Flow Control Protocol Error */
-	PEX_POIS_TLP	= 1<<12, /* Poisoned TLP */
-
-	PEX_DATA_LINK_P = 1<<4,	/* Data Link Protocol Error */
-	PEX_FATAL_ERRORS= (PEX_MALFOR_TLP | PEX_FLOW_CTRL_P | PEX_DATA_LINK_P),
-};
-
-
 enum csr_regs {
 	B0_RAP		= 0x0000,
 	B0_CTST		= 0x0004,
@@ -419,7 +379,6 @@ enum {
 			  Y2_IS_PAR_RX2 | Y2_IS_TCP_TXS2| Y2_IS_TCP_TXA2,
 
 	Y2_HWE_ALL_MASK	= Y2_IS_TIST_OV | Y2_IS_MST_ERR | Y2_IS_IRQ_STAT |
-			  Y2_IS_PCI_EXP |
 			  Y2_HWE_L1_MASK | Y2_HWE_L2_MASK,
 };
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

