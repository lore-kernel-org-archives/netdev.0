From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 06/17] sky2: advanced error reporting
Date: Tue, 08 May 2007 20:49:55 -0700
Message-ID: <20070509035028.970057572@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59641 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S969669AbXEIEKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:10:16 -0400
Cc: Greg KH <greg@kroah.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz
Content-Disposition: inline; filename=sky2-recoverable.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the kernel interfaces for advanced error reporting.
This should be cleaner and clear up errors on boot.

Note: for those systems with busted BIOS's that don't correctly 
support mmconfig, advanced error reporting will be disabled.
The PCI registers for advanced error reporting start at 0x100 which
is too large to be accessed by legacy functions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   50 ++++++++++++++++++++++++++++++--------------------
 drivers/net/sky2.h |   41 -----------------------------------------
 2 files changed, 30 insertions(+), 61 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:28:58.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:29:01.000000000 -0700
@@ -31,6 +31,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
+#include <linux/aer.h>
 #include <linux/ip.h>
 #include <net/ip.h>
 #include <linux/tcp.h>
@@ -2270,7 +2271,11 @@ static void sky2_hw_error(struct sky2_hw
 
 static void sky2_hw_intr(struct sky2_hw *hw)
 {
+	struct pci_dev *pdev = hw->pdev;
 	u32 status = sky2_read32(hw, B0_HWE_ISRC);
+	u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
+
+	status &= hwmsk;
 
 	if (status & Y2_IS_TIST_OV)
 		sky2_write8(hw, GMAC_TI_ST_CTRL, GMT_ST_CLR_IRQ);
@@ -2280,32 +2285,34 @@ static void sky2_hw_intr(struct sky2_hw 
 
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
-			dev_err(&hw->pdev->dev, "PCI hardware error (0x%x)\n",
+			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
 		sky2_pci_write16(hw, PCI_STATUS,
 				 pci_err | PCI_STATUS_ERROR_BITS);
 	}
 
+	/* PCI-Express error occurred */
 	if (status & Y2_IS_PCI_EXP) {
-		/* PCI-Express uncorrectable Error occurred */
-		u32 pex_err;
+		int pos = pci_find_aer_capability(hw->pdev);
+		u32 status, mask;
+
+		/* should never happen since found capability during reset */
+		BUG_ON(!pos);
 
-		pex_err = sky2_pci_read32(hw, PEX_UNC_ERR_STAT);
+		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, &status);
+		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &mask);
 
 		if (net_ratelimit())
-			dev_err(&hw->pdev->dev, "PCI Express error (0x%x)\n",
-				pex_err);
+			dev_err(&pdev->dev, "PCI Express error (0x%x)\n",
+				status);
 
-		/* clear the interrupt */
-		sky2_pci_write32(hw, PEX_UNC_ERR_STAT,
-				       0xffffffffUL);
-
-		if (pex_err & PEX_FATAL_ERRORS) {
-			u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
-			hwmsk &= ~Y2_IS_PCI_EXP;
-			sky2_write32(hw, B0_HWE_IMSK, hwmsk);
-		}
+		if (pdev->error_state == pci_channel_io_normal)
+			status &= ~mask; /* Clear corresponding nonfatal bits */
+		else
+			status &= mask; /* Clear corresponding fatal bits */
+
+		pci_write_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, status);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2533,6 +2540,7 @@ static void sky2_reset(struct sky2_hw *h
 {
 	u16 status;
 	int i;
+	u32 hwe_mask = Y2_HWE_ALL_MASK;
 
 	/* disable ASF */
 	if (hw->chip_id == CHIP_ID_YUKON_EX) {
@@ -2550,16 +2558,18 @@ static void sky2_reset(struct sky2_hw *h
 
 	/* clear PCI errors, if any */
 	status = sky2_pci_read16(hw, PCI_STATUS);
-
 	sky2_pci_write16(hw, PCI_STATUS, status | PCI_STATUS_ERROR_BITS);
 
 
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
-	/* clear any PEX errors */
-	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP))
-		sky2_pci_write32(hw, PEX_UNC_ERR_STAT, 0xffffffffUL);
+	/* Check for advanced error reporting */
+	if (pci_find_aer_capability(hw->pdev)) {
+		hwe_mask |= Y2_IS_PCI_EXP;
 
+		pci_cleanup_aer_uncorrect_error_status(hw->pdev);
+		pci_enable_pcie_error_reporting(hw->pdev);
+	}
 
 	sky2_power_on(hw);
 
@@ -2606,7 +2616,7 @@ static void sky2_reset(struct sky2_hw *h
 		sky2_write8(hw, RAM_BUFFER(i, B3_RI_RTO_XS2), SK_RI_TO_53);
 	}
 
-	sky2_write32(hw, B0_HWE_IMSK, Y2_HWE_ALL_MASK);
+	sky2_write32(hw, B0_HWE_IMSK, hwe_mask);
 
 	for (i = 0; i < hw->ports; i++)
 		sky2_gmac_reset(hw, i);
--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-05-08 09:57:31.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-05-08 10:29:01.000000000 -0700
@@ -16,14 +16,6 @@ enum {
 	PCI_DEV_REG5    = 0x88,
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
@@ -74,38 +66,6 @@ enum pci_dev_reg_4 {
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
@@ -342,7 +302,6 @@ enum {
 			  Y2_IS_PAR_RX2 | Y2_IS_TCP_TXS2| Y2_IS_TCP_TXA2,
 
 	Y2_HWE_ALL_MASK	= Y2_IS_TIST_OV | Y2_IS_MST_ERR | Y2_IS_IRQ_STAT |
-			  Y2_IS_PCI_EXP |
 			  Y2_HWE_L1_MASK | Y2_HWE_L2_MASK,
 };
 

--

