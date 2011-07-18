From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 42/45] bna: PLL Init Fix and Add Stats Attributes
Date: Mon, 18 Jul 2011 01:23:02 -0700
Message-ID: <1310977385-5268-32-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37853 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755019Ab1GRIZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:21 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Fix to release soft reset in PLL init for HW
 - Added Stats Attributes
 - Removed some unused code

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs_cna.h |    8 +++++++-
 drivers/net/bna/bfa_ioc.c      |   19 ++++++-------------
 drivers/net/bna/bfa_ioc.h      |   12 ++----------
 drivers/net/bna/bfa_ioc_ct.c   |    9 ++++++++-
 drivers/net/bna/bfi.h          |   19 ++++++++++---------
 5 files changed, 33 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bna/bfa_defs_cna.h b/drivers/net/bna/bfa_defs_cna.h
index 7e0a918..8ab33ee 100644
--- a/drivers/net/bna/bfa_defs_cna.h
+++ b/drivers/net/bna/bfa_defs_cna.h
@@ -15,7 +15,6 @@
  * All rights reserved
  * www.brocade.com
  */
-
 #ifndef __BFA_DEFS_CNA_H__
 #define __BFA_DEFS_CNA_H__
 
@@ -55,6 +54,9 @@ struct bfa_port_fc_stats {
 	u64	bad_os_count;	/*!< Invalid ordered sets	*/
 	u64	err_enc_out;	/*!< Encoding err nonframe_8b10b */
 	u64	err_enc;	/*!< Encoding err frame_8b10b	*/
+	u64	bbsc_frames_lost; /*!< Credit Recovery-Frames Lost  */
+	u64	bbsc_credits_lost; /*!< Credit Recovery-Credits Lost */
+	u64	bbsc_link_resets; /*!< Credit Recovery-Link Resets   */
 };
 
 /**
@@ -100,6 +102,10 @@ struct bfa_port_eth_stats {
 	u64	rx_fcoe_zero_pause; /*!< Rx FCoE zero pause	*/
 	u64	tx_fcoe_pause;	/*!< Tx FCoE pause		*/
 	u64	tx_fcoe_zero_pause; /*!< Tx FCoE zero pause	*/
+	u64	rx_iscsi_pause;	/*!< Rx iSCSI pause		*/
+	u64	rx_iscsi_zero_pause; /*!< Rx iSCSI zero pause	*/
+	u64	tx_iscsi_pause;	/*!< Tx iSCSI pause		*/
+	u64	tx_iscsi_zero_pause; /*!< Tx iSCSI zero pause	*/
 };
 
 /**
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index b086cd7..36a040f 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -17,8 +17,6 @@
  */
 
 #include "bfa_ioc.h"
-#include "cna.h"
-#include "bfi.h"
 #include "bfi_reg.h"
 #include "bfa_defs.h"
 
@@ -144,10 +142,6 @@ static struct bfa_sm_table ioc_sm_table[] = {
 	{BFA_SM(bfa_ioc_sm_acq_addr), BFA_IOC_ACQ_ADDR},
 };
 
-/**
- * IOCPF state machine definitions/declarations
- */
-
 /*
  * Forward declareations for iocpf state machine
  */
@@ -362,7 +356,6 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 
 	case IOC_E_FWRSP_ACQ_ADDR:
 		del_timer(&ioc->ioc_timer);
-		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_FAA_ACQ_ADDR);
 		bfa_ioc_hb_monitor(ioc);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_acq_addr);
 		break;
@@ -481,7 +474,7 @@ bfa_ioc_sm_disabling_entry(struct bfa_ioc *ioc)
 }
 
 /**
- * IOC is being desabled
+ * IOC is being disabled
  */
 static void
 bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
@@ -511,7 +504,7 @@ bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 /**
- * IOC desable completion entry.
+ * IOC disable completion entry.
  */
 static void
 bfa_ioc_sm_disabled_entry(struct bfa_ioc *ioc)
@@ -836,7 +829,7 @@ static void
 bfa_iocpf_sm_hwinit_entry(struct bfa_iocpf *iocpf)
 {
 	iocpf->poll_time = 0;
-	bfa_ioc_reset(iocpf->ioc, 0);
+	bfa_ioc_reset(iocpf->ioc, false);
 }
 
 /**
@@ -1825,6 +1818,9 @@ bfa_ioc_fail_notify(struct bfa_ioc *ioc)
 	bfa_ioc_event_notify(ioc, BFA_IOC_E_FAILED);
 }
 
+/**
+ * IOCPF to IOC interface
+ */
 static void
 bfa_ioc_pf_enabled(struct bfa_ioc *ioc)
 {
@@ -2372,9 +2368,6 @@ bfa_ioc_get_adapter_model(struct bfa_ioc *ioc, char *model)
 
 	ioc_attr = ioc->attr;
 
-	/**
-	 * model name
-	 */
 	snprintf(model, BFA_ADAPTER_MODEL_NAME_LEN, "%s-%u",
 		BFA_MFG_NAME, ioc_attr->card_type);
 }
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 5b6cbbe..1195df5 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -152,16 +152,7 @@ struct bfa_ioc_notify {
 };
 
 /**
- * Heartbeat failure notification queue element.
- */
-struct bfa_ioc_hbfail_notify {
-	struct list_head	qe;
-	bfa_ioc_hbfail_cbfn_t	cbfn;
-	void			*cbarg;
-};
-
-/**
- * Initialize a heartbeat failure notification structure
+ * Initialize a IOC event notification structure
  */
 #define bfa_ioc_notify_init(__notify, __cbfn, __cbarg) do {	\
 	(__notify)->cbfn = (__cbfn);				\
@@ -294,6 +285,7 @@ void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 
 void bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc);
 void bfa_nw_ioc_set_ct2_hwif(struct bfa_ioc *ioc);
+void bfa_ioc_ct2_poweron(struct bfa_ioc *ioc);
 
 void bfa_nw_ioc_attach(struct bfa_ioc *ioc, void *bfa,
 		struct bfa_ioc_cbfn *cbfn);
diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index a615c15..43f382f 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -844,10 +844,17 @@ bfa_ioc_ct2_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 	 * release soft reset on s_clk & l_clk
 	 */
 	r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
-	writel((r32 & ~__APP_PLL_LCLK_LOGIC_SOFT_RESET),
+	writel((r32 & ~__APP_PLL_SCLK_LOGIC_SOFT_RESET),
 			(rb + CT2_APP_PLL_SCLK_CTL_REG));
 
 	/*
+	 * release soft reset on s_clk & l_clk
+	 */
+	r32 = readl((rb + CT2_APP_PLL_LCLK_CTL_REG));
+	writel(r32 & ~__APP_PLL_LCLK_LOGIC_SOFT_RESET,
+		      (rb + CT2_APP_PLL_LCLK_CTL_REG));
+
+	/*
 	 * Announce flash device presence, if flash was corrupted.
 	 */
 	if (wgn == (__WGN_READY | __GLBL_PF_VF_CFG_RDY)) {
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 8dd8463..17522f3 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -181,16 +181,20 @@ enum bfi_mclass {
 	BFI_MC_SFP		= 22,	/*!< SFP module			    */
 	BFI_MC_MSGQ		= 23,	/*!< MSGQ			    */
 	BFI_MC_ENET		= 24,	/*!< ENET commands/responses	    */
-	BFI_MC_MAX		= 32
+	BFI_MC_PHY		= 25,	/*!< External PHY message class	    */
+	BFI_MC_NBOOT		= 26,	/*!< Network Boot		    */
+	BFI_MC_TIO_READ		= 27,	/*!< read IO (Target mode)	    */
+	BFI_MC_TIO_WRITE	= 28,	/*!< write IO (Target mode)	    */
+	BFI_MC_TIO_DATA_XFERED	= 29,	/*!< ds transferred (target mode)   */
+	BFI_MC_TIO_IO		= 30,	/*!< IO (Target mode)		    */
+	BFI_MC_TIO		= 31,	/*!< IO (target mode)		    */
+	BFI_MC_MFG		= 32,	/*!< MFG/ASIC block commands	    */
+	BFI_MC_EDMA		= 33,	/*!< EDMA copy commands		    */
+	BFI_MC_MAX		= 34
 };
 
-#define BFI_IOC_MAX_CQS		4
-#define BFI_IOC_MAX_CQS_ASIC	8
 #define BFI_IOC_MSGLEN_MAX	32	/* 32 bytes */
 
-#define BFI_BOOT_MEMTEST_RES_ADDR   0x900
-#define BFI_BOOT_MEMTEST_RES_SIG    0xA0A1A2A3
-
 /**
  *----------------------------------------------------------------------
  *				IOC
@@ -331,9 +335,6 @@ enum bfi_port_mode {
 	BFI_PORT_MODE_ETH	= 2,
 };
 
-/**
- *  BFI_IOC_I2H_READY_EVENT message
- */
 struct bfi_ioc_hbeat {
 	struct bfi_mhdr mh;		/*!< common msg header		*/
 	u32	   hb_count;	/*!< current heart beat count	*/
-- 
1.7.1

