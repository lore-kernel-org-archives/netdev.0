From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: revert pci express extensions
Date: Mon, 9 Oct 2006 14:40:38 -0700
Message-ID: <20061009144038.6d3a93d6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15805 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751897AbWJIVm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 17:42:27 -0400
To: Jeff Garzik <jgarzik@pobox.com>, Matthias Hentges <oe@hentges.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pci express error handling extensions don't work unless PCI access is via 
mmconfig. Otherwise, all accesses to pci config registers greater than 256 fail.
Since the sky2 driver has other ways of getting to PCI config space, it works
around this short coming, but the pci_find_ext_capablity doesn't work.

This backs out commit 91aeb3edbcf4e6ed72d138ac8c22fd68e6d717c3
Go back to hardcoding, since we know where the error registers are anyway.
Fixes  http://bugzilla.kernel.org/show_bug.cgi?id=7222

Signed-off-by: Stephen Hemminger <shemmminger@osdl.org>

---
 drivers/net/sky2.c |   30 ++++++++----------------------
 drivers/net/sky2.h |   45 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 51 insertions(+), 24 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-09 14:35:06.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-09 14:37:26.000000000 -0700
@@ -2220,8 +2220,7 @@
 		/* PCI-Express uncorrectable Error occurred */
 		u32 pex_err;
 
-		pex_err = sky2_pci_read32(hw,
-					  hw->err_cap + PCI_ERR_UNCOR_STATUS);
+		pex_err = sky2_pci_read32(hw, PEX_UNC_ERR_STAT);
 
 		if (net_ratelimit())
 			printk(KERN_ERR PFX "%s: pci express error (0x%x)\n",
@@ -2229,20 +2228,15 @@
 
 		/* clear the interrupt */
 		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
-		sky2_pci_write32(hw,
-				 hw->err_cap + PCI_ERR_UNCOR_STATUS,
-				 0xffffffffUL);
+		sky2_pci_write32(hw, PEX_UNC_ERR_STAT,
+				       0xffffffffUL);
 		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
-
-		/* In case of fatal error mask off to keep from getting stuck */
-		if (pex_err & (PCI_ERR_UNC_POISON_TLP | PCI_ERR_UNC_FCP
-			       | PCI_ERR_UNC_DLP)) {
+		if (pex_err & PEX_FATAL_ERRORS) {
 			u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
 			hwmsk &= ~Y2_IS_PCI_EXP;
 			sky2_write32(hw, B0_HWE_IMSK, hwmsk);
 		}
-
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2423,7 +2417,6 @@
 	u16 status;
 	u8 t8;
 	int i;
-	u32 msk;
 
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
@@ -2464,13 +2457,9 @@
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
 	/* clear any PEX errors */
-	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP)) {
-		hw->err_cap = pci_find_ext_capability(hw->pdev, PCI_EXT_CAP_ID_ERR);
-		if (hw->err_cap)
-			sky2_pci_write32(hw,
-					 hw->err_cap + PCI_ERR_UNCOR_STATUS,
-					 0xffffffffUL);
-	}
+	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP))
+		sky2_pci_write32(hw, PEX_UNC_ERR_STAT, 0xffffffffUL);
+
 
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
@@ -2527,10 +2516,7 @@
 		sky2_write8(hw, RAM_BUFFER(i, B3_RI_RTO_XS2), SK_RI_TO_53);
 	}
 
-	msk = Y2_HWE_ALL_MASK;
-	if (!hw->err_cap)
-		msk &= ~Y2_IS_PCI_EXP;
-	sky2_write32(hw, B0_HWE_IMSK, msk);
+	sky2_write32(hw, B0_HWE_IMSK, Y2_HWE_ALL_MASK);
 
 	for (i = 0; i < hw->ports; i++)
 		sky2_gmac_reset(hw, i);
--- sky2.orig/drivers/net/sky2.h	2006-10-09 14:35:06.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-10-09 14:35:09.000000000 -0700
@@ -6,15 +6,24 @@
 
 #define ETH_JUMBO_MTU		9000	/* Maximum MTU supported */
 
-/* PCI device specific config registers */
+/* PCI config registers */
 enum {
 	PCI_DEV_REG1	= 0x40,
 	PCI_DEV_REG2	= 0x44,
+	PCI_DEV_STATUS  = 0x7c,
 	PCI_DEV_REG3	= 0x80,
 	PCI_DEV_REG4	= 0x84,
 	PCI_DEV_REG5    = 0x88,
 };
 
+enum {
+	PEX_DEV_CAP	= 0xe4,
+	PEX_DEV_CTRL	= 0xe8,
+	PEX_DEV_STA	= 0xea,
+	PEX_LNK_STAT	= 0xf2,
+	PEX_UNC_ERR_STAT= 0x104,
+};
+
 /* Yukon-2 */
 enum pci_dev_reg_1 {
 	PCI_Y2_PIG_ENA	 = 1<<31, /* Enable Plug-in-Go (YUKON-2) */
@@ -63,6 +72,39 @@
 			       PCI_STATUS_REC_MASTER_ABORT | \
 			       PCI_STATUS_REC_TARGET_ABORT | \
 			       PCI_STATUS_PARITY)
+
+enum pex_dev_ctrl {
+	PEX_DC_MAX_RRS_MSK	= 7<<12, /* Bit 14..12:	Max. Read Request Size */
+	PEX_DC_EN_NO_SNOOP	= 1<<11,/* Enable No Snoop */
+	PEX_DC_EN_AUX_POW	= 1<<10,/* Enable AUX Power */
+	PEX_DC_EN_PHANTOM	= 1<<9,	/* Enable Phantom Functions */
+	PEX_DC_EN_EXT_TAG	= 1<<8,	/* Enable Extended Tag Field */
+	PEX_DC_MAX_PLS_MSK	= 7<<5,	/* Bit  7.. 5:	Max. Payload Size Mask */
+	PEX_DC_EN_REL_ORD	= 1<<4,	/* Enable Relaxed Ordering */
+	PEX_DC_EN_UNS_RQ_RP	= 1<<3,	/* Enable Unsupported Request Reporting */
+	PEX_DC_EN_FAT_ER_RP	= 1<<2,	/* Enable Fatal Error Reporting */
+	PEX_DC_EN_NFA_ER_RP	= 1<<1,	/* Enable Non-Fatal Error Reporting */
+	PEX_DC_EN_COR_ER_RP	= 1<<0,	/* Enable Correctable Error Reporting */
+};
+#define  PEX_DC_MAX_RD_RQ_SIZE(x) (((x)<<12) & PEX_DC_MAX_RRS_MSK)
+
+/* PEX_UNC_ERR_STAT	 PEX Uncorrectable Errors Status Register (Yukon-2) */
+enum pex_err {
+	PEX_UNSUP_REQ 	= 1<<20, /* Unsupported Request Error */
+
+	PEX_MALFOR_TLP	= 1<<18, /* Malformed TLP */
+
+	PEX_UNEXP_COMP	= 1<<16, /* Unexpected Completion */
+
+	PEX_COMP_TO	= 1<<14, /* Completion Timeout */
+	PEX_FLOW_CTRL_P	= 1<<13, /* Flow Control Protocol Error */
+	PEX_POIS_TLP	= 1<<12, /* Poisoned TLP */
+
+	PEX_DATA_LINK_P = 1<<4,	/* Data Link Protocol Error */
+	PEX_FATAL_ERRORS= (PEX_MALFOR_TLP | PEX_FLOW_CTRL_P | PEX_DATA_LINK_P),
+};
+
+
 enum csr_regs {
 	B0_RAP		= 0x0000,
 	B0_CTST		= 0x0004,
@@ -1836,7 +1878,6 @@
 	struct net_device    *dev[2];
 
 	int		     pm_cap;
-	int		     err_cap;
 	u8	     	     chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;
