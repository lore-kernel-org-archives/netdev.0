From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/8] sky2: use standard pci register capabilties for error
 register
Date: Tue, 26 Sep 2006 16:09:21 -0700
Message-ID: <20060926160921.58673bd0@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32691 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965141AbWIZXRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:25 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHInW026362
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHISw006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use the standard pci capability mechanism to access PCI express error
registers, rather than hard coding the offset. Mask off the PCI express
error from ever occuring on non-PCI express systems.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/sky2.c |   32 +++++++++++++++++++++++---------
 drivers/net/sky2.h |   45 ++-------------------------------------------
 2 files changed, 25 insertions(+), 52 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:00.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:02.000000000 -0700
@@ -2093,7 +2093,7 @@
 
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write16(hw, PCI_STATUS,
-				      pci_err | PCI_STATUS_ERROR_BITS);
+				 pci_err | PCI_STATUS_ERROR_BITS);
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
@@ -2101,7 +2101,8 @@
 		/* PCI-Express uncorrectable Error occurred */
 		u32 pex_err;
 
-		pex_err = sky2_pci_read32(hw, PEX_UNC_ERR_STAT);
+		pex_err = sky2_pci_read32(hw,
+					  hw->err_cap + PCI_ERR_UNCOR_STATUS);
 
 		if (net_ratelimit())
 			printk(KERN_ERR PFX "%s: pci express error (0x%x)\n",
@@ -2109,15 +2110,20 @@
 
 		/* clear the interrupt */
 		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
-		sky2_pci_write32(hw, PEX_UNC_ERR_STAT,
-				       0xffffffffUL);
+		sky2_pci_write32(hw,
+				 hw->err_cap + PCI_ERR_UNCOR_STATUS,
+				 0xffffffffUL);
 		sky2_write32(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
-		if (pex_err & PEX_FATAL_ERRORS) {
+
+		/* In case of fatal error mask off to keep from getting stuck */
+		if (pex_err & (PCI_ERR_UNC_POISON_TLP | PCI_ERR_UNC_FCP
+			       | PCI_ERR_UNC_DLP)) {
 			u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
 			hwmsk &= ~Y2_IS_PCI_EXP;
 			sky2_write32(hw, B0_HWE_IMSK, hwmsk);
 		}
+
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2298,6 +2304,7 @@
 	u16 status;
 	u8 t8;
 	int i;
+	u32 msk;
 
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
@@ -2338,9 +2345,13 @@
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
 	/* clear any PEX errors */
-	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP))
-		sky2_pci_write32(hw, PEX_UNC_ERR_STAT, 0xffffffffUL);
-
+	if (pci_find_capability(hw->pdev, PCI_CAP_ID_EXP)) {
+		hw->err_cap = pci_find_ext_capability(hw->pdev, PCI_EXT_CAP_ID_ERR);
+		if (hw->err_cap)
+			sky2_pci_write32(hw,
+					 hw->err_cap + PCI_ERR_UNCOR_STATUS,
+					 0xffffffffUL);
+	}
 
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
@@ -2397,7 +2408,10 @@
 		sky2_write8(hw, RAM_BUFFER(i, B3_RI_RTO_XS2), SK_RI_TO_53);
 	}
 
-	sky2_write32(hw, B0_HWE_IMSK, Y2_HWE_ALL_MASK);
+	msk = Y2_HWE_ALL_MASK;
+	if (!hw->err_cap)
+		msk &= ~Y2_IS_PCI_EXP;
+	sky2_write32(hw, B0_HWE_IMSK, msk);
 
 	for (i = 0; i < hw->ports; i++)
 		sky2_gmac_reset(hw, i);
--- netdev-2.6.orig/drivers/net/sky2.h	2006-09-25 10:54:17.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.h	2006-09-25 15:23:02.000000000 -0700
@@ -4,24 +4,15 @@
 #ifndef _SKY2_H
 #define _SKY2_H
 
-/* PCI config registers */
+/* PCI device specific config registers */
 enum {
 	PCI_DEV_REG1	= 0x40,
 	PCI_DEV_REG2	= 0x44,
-	PCI_DEV_STATUS  = 0x7c,
 	PCI_DEV_REG3	= 0x80,
 	PCI_DEV_REG4	= 0x84,
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
@@ -70,39 +61,6 @@
 			       PCI_STATUS_REC_MASTER_ABORT | \
 			       PCI_STATUS_REC_TARGET_ABORT | \
 			       PCI_STATUS_PARITY)
-
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
@@ -1873,6 +1831,7 @@
 	struct net_device    *dev[2];
 
 	int		     pm_cap;
+	int		     err_cap;
 	u8	     	     chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;
