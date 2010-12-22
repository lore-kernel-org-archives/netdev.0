From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 09/10] bna: IOC failure auto recovery fix
Date: Tue, 21 Dec 2010 23:23:15 -0800
Message-ID: <1293002596-3239-10-git-send-email-rmody@brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54325 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752446Ab0LVHtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:49:11 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBM7ML8v021240
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:29 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.141.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tb71ag48k-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:28 -0800
In-Reply-To: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
	- Made IOC auto_recovery synchronized and not timer based.
	- Only one PCI function will attempt to recover and reinitialize the ASIC on a failure, that too after all the active
PCI functions acknowledge the IOC failure.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h   |   22 +-
 drivers/net/bna/bfa_ioc.c    | 1174 ++++++++++++++++++++++++++++++++----------
 drivers/net/bna/bfa_ioc.h    |   49 +-
 drivers/net/bna/bfa_ioc_ct.c |  102 ++++-
 drivers/net/bna/bfi_ctreg.h  |   41 +-
 drivers/net/bna/bna.h        |    2 -
 drivers/net/bna/bnad.c       |   21 +-
 7 files changed, 1061 insertions(+), 350 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index 29c1b8d..2ea0dfe 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -112,16 +112,18 @@ struct bfa_ioc_pci_attr {
  * IOC states
  */
 enum bfa_ioc_state {
-	BFA_IOC_RESET		= 1,	/*!< IOC is in reset state */
-	BFA_IOC_SEMWAIT		= 2,	/*!< Waiting for IOC h/w semaphore */
-	BFA_IOC_HWINIT		= 3,	/*!< IOC h/w is being initialized */
-	BFA_IOC_GETATTR		= 4,	/*!< IOC is being configured */
-	BFA_IOC_OPERATIONAL	= 5,	/*!< IOC is operational */
-	BFA_IOC_INITFAIL	= 6,	/*!< IOC hardware failure */
-	BFA_IOC_HBFAIL		= 7,	/*!< IOC heart-beat failure */
-	BFA_IOC_DISABLING	= 8,	/*!< IOC is being disabled */
-	BFA_IOC_DISABLED	= 9,	/*!< IOC is disabled */
-	BFA_IOC_FWMISMATCH	= 10,	/*!< IOC f/w different from drivers */
+	BFA_IOC_UNINIT		= 1,	/*!< IOC is in uninit state */
+	BFA_IOC_RESET		= 2,	/*!< IOC is in reset state */
+	BFA_IOC_SEMWAIT		= 3,	/*!< Waiting for IOC h/w semaphore */
+	BFA_IOC_HWINIT		= 4,	/*!< IOC h/w is being initialized */
+	BFA_IOC_GETATTR		= 5,	/*!< IOC is being configured */
+	BFA_IOC_OPERATIONAL	= 6,	/*!< IOC is operational */
+	BFA_IOC_INITFAIL	= 7,	/*!< IOC hardware failure */
+	BFA_IOC_FAIL		= 8,	/*!< IOC heart-beat failure */
+	BFA_IOC_DISABLING	= 9,	/*!< IOC is being disabled */
+	BFA_IOC_DISABLED	= 10,	/*!< IOC is disabled */
+	BFA_IOC_FWMISMATCH	= 11,	/*!< IOC f/w different from drivers */
+	BFA_IOC_ENABLING	= 12,	/*!< IOC is being enabled */
 };
 
 /**
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 8ed147e..34933cb 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -26,25 +26,6 @@
  * IOC local definitions
  */
 
-#define bfa_ioc_timer_start(__ioc)					\
-	mod_timer(&(__ioc)->ioc_timer, jiffies +	\
-			msecs_to_jiffies(BFA_IOC_TOV))
-#define bfa_ioc_timer_stop(__ioc)   del_timer(&(__ioc)->ioc_timer)
-
-#define bfa_ioc_recovery_timer_start(__ioc)				\
-	mod_timer(&(__ioc)->ioc_timer, jiffies +	\
-			msecs_to_jiffies(BFA_IOC_TOV_RECOVER))
-
-#define bfa_sem_timer_start(__ioc)					\
-	mod_timer(&(__ioc)->sem_timer, jiffies +	\
-			msecs_to_jiffies(BFA_IOC_HWSEM_TOV))
-#define bfa_sem_timer_stop(__ioc)	del_timer(&(__ioc)->sem_timer)
-
-#define bfa_hb_timer_start(__ioc)					\
-	mod_timer(&(__ioc)->hb_timer, jiffies +		\
-			msecs_to_jiffies(BFA_IOC_HB_TOV))
-#define bfa_hb_timer_stop(__ioc)	del_timer(&(__ioc)->hb_timer)
-
 /**
  * Asic specific macros : see bfa_hw_cb.c and bfa_hw_ct.c for details.
  */
@@ -55,8 +36,16 @@
 			((__ioc)->ioc_hwif->ioc_firmware_unlock(__ioc))
 #define bfa_ioc_reg_init(__ioc) ((__ioc)->ioc_hwif->ioc_reg_init(__ioc))
 #define bfa_ioc_map_port(__ioc) ((__ioc)->ioc_hwif->ioc_map_port(__ioc))
-#define bfa_ioc_notify_hbfail(__ioc)			\
-			((__ioc)->ioc_hwif->ioc_notify_hbfail(__ioc))
+#define bfa_ioc_notify_fail(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_notify_fail(__ioc))
+#define bfa_ioc_sync_join(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_sync_join(__ioc))
+#define bfa_ioc_sync_leave(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_sync_leave(__ioc))
+#define bfa_ioc_sync_ack(__ioc)				\
+			((__ioc)->ioc_hwif->ioc_sync_ack(__ioc))
+#define bfa_ioc_sync_complete(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_sync_complete(__ioc))
 
 #define bfa_ioc_mbox_cmd_pending(__ioc)		\
 			(!list_empty(&((__ioc)->mbox_mod.cmd_q)) || \
@@ -82,6 +71,12 @@ static void bfa_ioc_recover(struct bfa_ioc *ioc);
 static void bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc);
 static void bfa_ioc_disable_comp(struct bfa_ioc *ioc);
 static void bfa_ioc_lpu_stop(struct bfa_ioc *ioc);
+static void bfa_ioc_fail_notify(struct bfa_ioc *ioc);
+static void bfa_ioc_pf_enabled(struct bfa_ioc *ioc);
+static void bfa_ioc_pf_disabled(struct bfa_ioc *ioc);
+static void bfa_ioc_pf_initfailed(struct bfa_ioc *ioc);
+static void bfa_ioc_pf_failed(struct bfa_ioc *ioc);
+static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc);
 static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
 			 u32 boot_param);
 static u32 bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr);
@@ -100,69 +95,171 @@ static void bfa_ioc_get_adapter_model(struct bfa_ioc *ioc, char *model);
 static u64 bfa_ioc_get_pwwn(struct bfa_ioc *ioc);
 
 /**
- * IOC state machine events
+ * IOC state machine definitions/declarations
  */
 enum ioc_event {
-	IOC_E_ENABLE		= 1,	/*!< IOC enable request		*/
-	IOC_E_DISABLE		= 2,	/*!< IOC disable request	*/
-	IOC_E_TIMEOUT		= 3,	/*!< f/w response timeout	*/
-	IOC_E_FWREADY		= 4,	/*!< f/w initialization done	*/
-	IOC_E_FWRSP_GETATTR	= 5,	/*!< IOC get attribute response	*/
-	IOC_E_FWRSP_ENABLE	= 6,	/*!< enable f/w response	*/
-	IOC_E_FWRSP_DISABLE	= 7,	/*!< disable f/w response	*/
-	IOC_E_HBFAIL		= 8,	/*!< heartbeat failure		*/
-	IOC_E_HWERROR		= 9,	/*!< hardware error interrupt	*/
-	IOC_E_SEMLOCKED		= 10,	/*!< h/w semaphore is locked	*/
-	IOC_E_DETACH		= 11,	/*!< driver detach cleanup	*/
+	IOC_E_RESET		= 1,	/*!< IOC reset request		*/
+	IOC_E_ENABLE		= 2,	/*!< IOC enable request		*/
+	IOC_E_DISABLE		= 3,	/*!< IOC disable request	*/
+	IOC_E_DETACH		= 4,	/*!< driver detach cleanup	*/
+	IOC_E_ENABLED		= 5,	/*!< f/w enabled		*/
+	IOC_E_FWRSP_GETATTR	= 6,	/*!< IOC get attribute response	*/
+	IOC_E_DISABLED		= 7,	/*!< f/w disabled		*/
+	IOC_E_INITFAILED	= 8,	/*!< failure notice by iocpf sm	*/
+	IOC_E_PFAILED		= 9,	/*!< failure notice by iocpf sm	*/
+	IOC_E_HBFAIL		= 10,	/*!< heartbeat failure		*/
+	IOC_E_HWERROR		= 11,	/*!< hardware error interrupt	*/
+	IOC_E_TIMEOUT		= 12,	/*!< timeout			*/
 };
 
+bfa_fsm_state_decl(bfa_ioc, uninit, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, reset, struct bfa_ioc, enum ioc_event);
-bfa_fsm_state_decl(bfa_ioc, fwcheck, struct bfa_ioc, enum ioc_event);
-bfa_fsm_state_decl(bfa_ioc, mismatch, struct bfa_ioc, enum ioc_event);
-bfa_fsm_state_decl(bfa_ioc, semwait, struct bfa_ioc, enum ioc_event);
-bfa_fsm_state_decl(bfa_ioc, hwinit, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, enabling, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, getattr, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, op, struct bfa_ioc, enum ioc_event);
-bfa_fsm_state_decl(bfa_ioc, initfail, struct bfa_ioc, enum ioc_event);
-bfa_fsm_state_decl(bfa_ioc, hbfail, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, fail_retry, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, fail, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, disabling, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, disabled, struct bfa_ioc, enum ioc_event);
 
 static struct bfa_sm_table ioc_sm_table[] = {
+	{BFA_SM(bfa_ioc_sm_uninit), BFA_IOC_UNINIT},
 	{BFA_SM(bfa_ioc_sm_reset), BFA_IOC_RESET},
-	{BFA_SM(bfa_ioc_sm_fwcheck), BFA_IOC_FWMISMATCH},
-	{BFA_SM(bfa_ioc_sm_mismatch), BFA_IOC_FWMISMATCH},
-	{BFA_SM(bfa_ioc_sm_semwait), BFA_IOC_SEMWAIT},
-	{BFA_SM(bfa_ioc_sm_hwinit), BFA_IOC_HWINIT},
-	{BFA_SM(bfa_ioc_sm_enabling), BFA_IOC_HWINIT},
+	{BFA_SM(bfa_ioc_sm_enabling), BFA_IOC_ENABLING},
 	{BFA_SM(bfa_ioc_sm_getattr), BFA_IOC_GETATTR},
 	{BFA_SM(bfa_ioc_sm_op), BFA_IOC_OPERATIONAL},
-	{BFA_SM(bfa_ioc_sm_initfail), BFA_IOC_INITFAIL},
-	{BFA_SM(bfa_ioc_sm_hbfail), BFA_IOC_HBFAIL},
+	{BFA_SM(bfa_ioc_sm_fail_retry), BFA_IOC_INITFAIL},
+	{BFA_SM(bfa_ioc_sm_fail), BFA_IOC_FAIL},
 	{BFA_SM(bfa_ioc_sm_disabling), BFA_IOC_DISABLING},
 	{BFA_SM(bfa_ioc_sm_disabled), BFA_IOC_DISABLED},
 };
 
 /**
+ * IOCPF state machine definitions/declarations
+ */
+
+/*
+ * Forward declareations for iocpf state machine
+ */
+static void bfa_iocpf_enable(struct bfa_ioc *ioc);
+static void bfa_iocpf_disable(struct bfa_ioc *ioc);
+static void bfa_iocpf_fail(struct bfa_ioc *ioc);
+static void bfa_iocpf_initfail(struct bfa_ioc *ioc);
+static void bfa_iocpf_getattrfail(struct bfa_ioc *ioc);
+static void bfa_iocpf_stop(struct bfa_ioc *ioc);
+
+/**
+ * IOCPF state machine events
+ */
+enum iocpf_event {
+	IOCPF_E_ENABLE		= 1,	/*!< IOCPF enable request	*/
+	IOCPF_E_DISABLE		= 2,	/*!< IOCPF disable request	*/
+	IOCPF_E_STOP		= 3,	/*!< stop on driver detach	*/
+	IOCPF_E_FWREADY	 	= 4,	/*!< f/w initialization done	*/
+	IOCPF_E_FWRSP_ENABLE	= 5,	/*!< enable f/w response	*/
+	IOCPF_E_FWRSP_DISABLE	= 6,	/*!< disable f/w response	*/
+	IOCPF_E_FAIL		= 7,	/*!< failure notice by ioc sm	*/
+	IOCPF_E_INITFAIL	= 8,	/*!< init fail notice by ioc sm	*/
+	IOCPF_E_GETATTRFAIL	= 9,	/*!< init fail notice by ioc sm	*/
+	IOCPF_E_SEMLOCKED	= 10,   /*!< h/w semaphore is locked	*/
+	IOCPF_E_TIMEOUT		= 11,   /*!< f/w response timeout	*/
+};
+
+/**
+ * IOCPF states
+ */
+enum bfa_iocpf_state {
+	BFA_IOCPF_RESET		= 1,	/*!< IOC is in reset state */
+	BFA_IOCPF_SEMWAIT	= 2,	/*!< Waiting for IOC h/w semaphore */
+	BFA_IOCPF_HWINIT	= 3,	/*!< IOC h/w is being initialized */
+	BFA_IOCPF_READY		= 4,	/*!< IOCPF is initialized */
+	BFA_IOCPF_INITFAIL	= 5,	/*!< IOCPF failed */
+	BFA_IOCPF_FAIL		= 6,	/*!< IOCPF failed */
+	BFA_IOCPF_DISABLING	= 7,	/*!< IOCPF is being disabled */
+	BFA_IOCPF_DISABLED	= 8,	/*!< IOCPF is disabled */
+	BFA_IOCPF_FWMISMATCH	= 9,	/*!< IOC f/w different from drivers */
+};
+
+bfa_fsm_state_decl(bfa_iocpf, reset, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, fwcheck, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, mismatch, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, semwait, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, hwinit, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, enabling, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, ready, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, initfail_sync, struct bfa_iocpf,
+						enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, initfail, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, fail_sync, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, fail, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, disabling, struct bfa_iocpf, enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, disabling_sync, struct bfa_iocpf,
+						enum iocpf_event);
+bfa_fsm_state_decl(bfa_iocpf, disabled, struct bfa_iocpf, enum iocpf_event);
+
+static struct bfa_sm_table iocpf_sm_table[] = {
+	{BFA_SM(bfa_iocpf_sm_reset), BFA_IOCPF_RESET},
+	{BFA_SM(bfa_iocpf_sm_fwcheck), BFA_IOCPF_FWMISMATCH},
+	{BFA_SM(bfa_iocpf_sm_mismatch), BFA_IOCPF_FWMISMATCH},
+	{BFA_SM(bfa_iocpf_sm_semwait), BFA_IOCPF_SEMWAIT},
+	{BFA_SM(bfa_iocpf_sm_hwinit), BFA_IOCPF_HWINIT},
+	{BFA_SM(bfa_iocpf_sm_enabling), BFA_IOCPF_HWINIT},
+	{BFA_SM(bfa_iocpf_sm_ready), BFA_IOCPF_READY},
+	{BFA_SM(bfa_iocpf_sm_initfail_sync), BFA_IOCPF_INITFAIL},
+	{BFA_SM(bfa_iocpf_sm_initfail), BFA_IOCPF_INITFAIL},
+	{BFA_SM(bfa_iocpf_sm_fail_sync), BFA_IOCPF_FAIL},
+	{BFA_SM(bfa_iocpf_sm_fail), BFA_IOCPF_FAIL},
+	{BFA_SM(bfa_iocpf_sm_disabling), BFA_IOCPF_DISABLING},
+	{BFA_SM(bfa_iocpf_sm_disabling_sync), BFA_IOCPF_DISABLING},
+	{BFA_SM(bfa_iocpf_sm_disabled), BFA_IOCPF_DISABLED},
+};
+
+/**
+ * IOC State Machine
+ */
+
+/**
+ * Beginning state. IOC uninit state.
+ */
+static void
+bfa_ioc_sm_uninit_entry(struct bfa_ioc *ioc)
+{
+}
+
+/**
+ * IOC is in uninit state.
+ */
+static void
+bfa_ioc_sm_uninit(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_RESET:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
  * Reset entry actions -- initialize state machine
  */
 static void
 bfa_ioc_sm_reset_entry(struct bfa_ioc *ioc)
 {
-	ioc->retry_count = 0;
-	ioc->auto_recover = bfa_nw_auto_recover;
+	bfa_fsm_set_state(&ioc->iocpf, bfa_iocpf_sm_reset);
 }
 
 /**
- * Beginning state. IOC is in reset state.
+ * IOC is in reset state.
  */
 static void
 bfa_ioc_sm_reset(struct bfa_ioc *ioc, enum ioc_event event)
 {
 	switch (event) {
 	case IOC_E_ENABLE:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_fwcheck);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_enabling);
 		break;
 
 	case IOC_E_DISABLE:
@@ -170,6 +267,7 @@ bfa_ioc_sm_reset(struct bfa_ioc *ioc, enum ioc_event event)
 		break;
 
 	case IOC_E_DETACH:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
 		break;
 
 	default:
@@ -177,42 +275,43 @@ bfa_ioc_sm_reset(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
-/**
- * Semaphore should be acquired for version check.
- */
 static void
-bfa_ioc_sm_fwcheck_entry(struct bfa_ioc *ioc)
+bfa_ioc_sm_enabling_entry(struct bfa_ioc *ioc)
 {
-	bfa_ioc_hw_sem_get(ioc);
+	bfa_iocpf_enable(ioc);
 }
 
 /**
- * Awaiting h/w semaphore to continue with version check.
+ * Host IOC function is being enabled, awaiting response from firmware.
+ * Semaphore is acquired.
  */
 static void
-bfa_ioc_sm_fwcheck(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 {
 	switch (event) {
-	case IOC_E_SEMLOCKED:
-		if (bfa_ioc_firmware_lock(ioc)) {
-			ioc->retry_count = 0;
-			bfa_fsm_set_state(ioc, bfa_ioc_sm_hwinit);
-		} else {
-			bfa_nw_ioc_hw_sem_release(ioc);
-			bfa_fsm_set_state(ioc, bfa_ioc_sm_mismatch);
-		}
+	case IOC_E_ENABLED:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
+		break;
+
+	case IOC_E_PFAILED:
+		/* !!! fall through !!! */
+	case IOC_E_HWERROR:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
+		if (event != IOC_E_PFAILED)
+			bfa_iocpf_initfail(ioc);
 		break;
 
 	case IOC_E_DISABLE:
-		bfa_ioc_disable_comp(ioc);
-		/* fall through */
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
+		break;
 
 	case IOC_E_DETACH:
-		bfa_ioc_hw_sem_get_cancel(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
+		bfa_iocpf_stop(ioc);
 		break;
 
-	case IOC_E_FWREADY:
+	case IOC_E_ENABLE:
 		break;
 
 	default:
@@ -221,41 +320,85 @@ bfa_ioc_sm_fwcheck(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 /**
- * Notify enable completion callback and generate mismatch AEN.
+ * Semaphore should be acquired for version check.
  */
 static void
-bfa_ioc_sm_mismatch_entry(struct bfa_ioc *ioc)
+bfa_ioc_sm_getattr_entry(struct bfa_ioc *ioc)
 {
-	/**
-	 * Provide enable completion callback and AEN notification only once.
-	 */
-	if (ioc->retry_count == 0)
-		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
-	ioc->retry_count++;
-	bfa_ioc_timer_start(ioc);
+	mod_timer(&ioc->ioc_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_TOV));
+	bfa_ioc_send_getattr(ioc);
 }
 
 /**
- * Awaiting firmware version match.
+ * IOC configuration in progress. Timer is active.
  */
 static void
-bfa_ioc_sm_mismatch(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 {
 	switch (event) {
+	case IOC_E_FWRSP_GETATTR:
+		del_timer(&ioc->ioc_timer);
+		bfa_ioc_check_attr_wwns(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
+		break;
+
+	case IOC_E_PFAILED:
+	case IOC_E_HWERROR:
+		del_timer(&ioc->ioc_timer);
+		/* fall through */
 	case IOC_E_TIMEOUT:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_fwcheck);
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
+		if (event != IOC_E_PFAILED)
+			bfa_iocpf_getattrfail(ioc);
 		break;
 
 	case IOC_E_DISABLE:
-		bfa_ioc_disable_comp(ioc);
-		/* fall through */
+		del_timer(&ioc->ioc_timer);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
+		break;
 
-	case IOC_E_DETACH:
-		bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+	case IOC_E_ENABLE:
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_op_entry(struct bfa_ioc *ioc)
+{
+	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_OK);
+	bfa_ioc_hb_monitor(ioc);
+}
+
+static void
+bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_ENABLE:
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_hb_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
 		break;
 
-	case IOC_E_FWREADY:
+	case IOC_E_PFAILED:
+	case IOC_E_HWERROR:
+		bfa_ioc_hb_stop(ioc);
+		/* !!! fall through !!! */
+	case IOC_E_HBFAIL:
+		bfa_ioc_fail_notify(ioc);
+		if (ioc->iocpf.auto_recover)
+			bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
+		else
+			bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
+
+		if (event != IOC_E_PFAILED)
+			bfa_iocpf_fail(ioc);
 		break;
 
 	default:
@@ -263,30 +406,61 @@ bfa_ioc_sm_mismatch(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
+static void
+bfa_ioc_sm_disabling_entry(struct bfa_ioc *ioc)
+{
+	bfa_iocpf_disable(ioc);
+}
+
 /**
- * Request for semaphore.
+ * IOC is being desabled
  */
 static void
-bfa_ioc_sm_semwait_entry(struct bfa_ioc *ioc)
+bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
 {
-	bfa_ioc_hw_sem_get(ioc);
+	switch (event) {
+	case IOC_E_DISABLED:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	case IOC_E_HWERROR:
+		/*
+		 * No state change.  Will move to disabled state
+		 * after iocpf sm completes failure processing and
+		 * moves to disabled state.
+		 */
+		bfa_iocpf_fail(ioc);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
 }
 
 /**
- * Awaiting semaphore for h/w initialzation.
+ * IOC desable completion entry.
  */
 static void
-bfa_ioc_sm_semwait(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_ioc_sm_disabled_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_disable_comp(ioc);
+}
+
+static void
+bfa_ioc_sm_disabled(struct bfa_ioc *ioc, enum ioc_event event)
 {
 	switch (event) {
-	case IOC_E_SEMLOCKED:
-		ioc->retry_count = 0;
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_hwinit);
+	case IOC_E_ENABLE:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_enabling);
 		break;
 
 	case IOC_E_DISABLE:
-		bfa_ioc_hw_sem_get_cancel(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		ioc->cbfn->disable_cbfn(ioc->bfa);
+		break;
+
+	case IOC_E_DETACH:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
+		bfa_iocpf_stop(ioc);
 		break;
 
 	default:
@@ -295,46 +469,45 @@ bfa_ioc_sm_semwait(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 static void
-bfa_ioc_sm_hwinit_entry(struct bfa_ioc *ioc)
+bfa_ioc_sm_fail_retry_entry(struct bfa_ioc *ioc)
 {
-	bfa_ioc_timer_start(ioc);
-	bfa_ioc_reset(ioc, false);
 }
 
 /**
- * @brief
- * Hardware is being initialized. Interrupts are enabled.
- * Holding hardware semaphore lock.
+ * Hardware initialization retry.
  */
 static void
-bfa_ioc_sm_hwinit(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_ioc_sm_fail_retry(struct bfa_ioc *ioc, enum ioc_event event)
 {
 	switch (event) {
-	case IOC_E_FWREADY:
-		bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_enabling);
+	case IOC_E_ENABLED:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
 		break;
 
+	case IOC_E_PFAILED:
 	case IOC_E_HWERROR:
-		bfa_ioc_timer_stop(ioc);
-		/* fall through */
+		/**
+		 * Initialization retry failed.
+		 */
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		if (event != IOC_E_PFAILED)
+			bfa_iocpf_initfail(ioc);
+		break;
 
-	case IOC_E_TIMEOUT:
-		ioc->retry_count++;
-		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
-			bfa_ioc_timer_start(ioc);
-			bfa_ioc_reset(ioc, true);
-			break;
-		}
+	case IOC_E_INITFAILED:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
+		break;
 
-		bfa_nw_ioc_hw_sem_release(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_initfail);
+	case IOC_E_ENABLE:
 		break;
 
 	case IOC_E_DISABLE:
-		bfa_nw_ioc_hw_sem_release(ioc);
-		bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
+		break;
+
+	case IOC_E_DETACH:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
+		bfa_iocpf_stop(ioc);
 		break;
 
 	default:
@@ -343,51 +516,248 @@ bfa_ioc_sm_hwinit(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 static void
-bfa_ioc_sm_enabling_entry(struct bfa_ioc *ioc)
+bfa_ioc_sm_fail_entry(struct bfa_ioc *ioc)
 {
-	bfa_ioc_timer_start(ioc);
-	bfa_ioc_send_enable(ioc);
 }
 
 /**
- * Host IOC function is being enabled, awaiting response from firmware.
- * Semaphore is acquired.
+ * IOC failure.
  */
 static void
-bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_ioc_sm_fail(struct bfa_ioc *ioc, enum ioc_event event)
 {
 	switch (event) {
-	case IOC_E_FWRSP_ENABLE:
-		bfa_ioc_timer_stop(ioc);
-		bfa_nw_ioc_hw_sem_release(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
+	case IOC_E_ENABLE:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
+		break;
+
+	case IOC_E_DETACH:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
+		bfa_iocpf_stop(ioc);
 		break;
 
 	case IOC_E_HWERROR:
-		bfa_ioc_timer_stop(ioc);
-		/* fall through */
+		/* HB failure notification, ignore. */
+		break;
 
-	case IOC_E_TIMEOUT:
-		ioc->retry_count++;
-		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
-			writel(BFI_IOC_UNINIT,
-				      ioc->ioc_regs.ioc_fwstate);
-			bfa_fsm_set_state(ioc, bfa_ioc_sm_hwinit);
-			break;
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * IOCPF State Machine
+ */
+
+/**
+ * Reset entry actions -- initialize state machine
+ */
+static void
+bfa_iocpf_sm_reset_entry(struct bfa_iocpf *iocpf)
+{
+	iocpf->retry_count = 0;
+	iocpf->auto_recover = bfa_nw_auto_recover;
+}
+
+/**
+ * Beginning state. IOC is in reset state.
+ */
+static void
+bfa_iocpf_sm_reset(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	switch (event) {
+	case IOCPF_E_ENABLE:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fwcheck);
+		break;
+
+	case IOCPF_E_STOP:
+		break;
+
+	default:
+		bfa_sm_fault(iocpf->ioc, event);
+	}
+}
+
+/**
+ * Semaphore should be acquired for version check.
+ */
+static void
+bfa_iocpf_sm_fwcheck_entry(struct bfa_iocpf *iocpf)
+{
+	bfa_ioc_hw_sem_get(iocpf->ioc);
+}
+
+/**
+ * Awaiting h/w semaphore to continue with version check.
+ */
+static void
+bfa_iocpf_sm_fwcheck(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	struct bfa_ioc *ioc = iocpf->ioc;
+
+	switch (event) {
+	case IOCPF_E_SEMLOCKED:
+		if (bfa_ioc_firmware_lock(ioc)) {
+			if (bfa_ioc_sync_complete(ioc)) {
+				iocpf->retry_count = 0;
+				bfa_ioc_sync_join(ioc);
+				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
+			} else {
+				bfa_ioc_firmware_unlock(ioc);
+				bfa_nw_ioc_hw_sem_release(ioc);
+				mod_timer(&ioc->sem_timer, jiffies +
+					msecs_to_jiffies(BFA_IOC_HWSEM_TOV));
+			}
+		} else {
+			bfa_nw_ioc_hw_sem_release(ioc);
+			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_mismatch);
 		}
+		break;
 
-		bfa_nw_ioc_hw_sem_release(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_initfail);
+	case IOCPF_E_DISABLE:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
+		bfa_ioc_pf_disabled(ioc);
 		break;
 
-	case IOC_E_DISABLE:
-		bfa_ioc_timer_stop(ioc);
+	case IOCPF_E_STOP:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * Notify enable completion callback
+ */
+static void
+bfa_iocpf_sm_mismatch_entry(struct bfa_iocpf *iocpf)
+{
+	/* Call only the first time sm enters fwmismatch state. */
+	if (iocpf->retry_count == 0)
+		bfa_ioc_pf_fwmismatch(iocpf->ioc);
+
+	iocpf->retry_count++;
+	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_TOV));
+}
+
+/**
+ * Awaiting firmware version match.
+ */
+static void
+bfa_iocpf_sm_mismatch(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	struct bfa_ioc *ioc = iocpf->ioc;
+
+	switch (event) {
+	case IOCPF_E_TIMEOUT:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fwcheck);
+		break;
+
+	case IOCPF_E_DISABLE:
+		del_timer(&ioc->iocpf_timer);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
+		bfa_ioc_pf_disabled(ioc);
+		break;
+
+	case IOCPF_E_STOP:
+		del_timer(&ioc->iocpf_timer);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * Request for semaphore.
+ */
+static void
+bfa_iocpf_sm_semwait_entry(struct bfa_iocpf *iocpf)
+{
+	bfa_ioc_hw_sem_get(iocpf->ioc);
+}
+
+/**
+ * Awaiting semaphore for h/w initialzation.
+ */
+static void
+bfa_iocpf_sm_semwait(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	struct bfa_ioc *ioc = iocpf->ioc;
+
+	switch (event) {
+	case IOCPF_E_SEMLOCKED:
+		if (bfa_ioc_sync_complete(ioc)) {
+			bfa_ioc_sync_join(ioc);
+			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
+		} else {
+			bfa_nw_ioc_hw_sem_release(ioc);
+			mod_timer(&ioc->sem_timer, jiffies +
+				msecs_to_jiffies(BFA_IOC_HWSEM_TOV));
+		}
+		break;
+
+	case IOCPF_E_DISABLE:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_iocpf_sm_hwinit_entry(struct bfa_iocpf *iocpf)
+{
+	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_TOV));
+	bfa_ioc_reset(iocpf->ioc, 0);
+}
+
+/**
+ * Hardware is being initialized. Interrupts are enabled.
+ * Holding hardware semaphore lock.
+ */
+static void
+bfa_iocpf_sm_hwinit(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	struct bfa_ioc *ioc = iocpf->ioc;
+
+	switch (event) {
+	case IOCPF_E_FWREADY:
+		del_timer(&ioc->iocpf_timer);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_enabling);
+		break;
+
+	case IOCPF_E_INITFAIL:
+		del_timer(&ioc->iocpf_timer);
+		/*
+		 * !!! fall through !!!
+		 */
+
+	case IOCPF_E_TIMEOUT:
 		bfa_nw_ioc_hw_sem_release(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		if (event == IOCPF_E_TIMEOUT)
+			bfa_ioc_pf_failed(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail_sync);
 		break;
 
-	case IOC_E_FWREADY:
-		bfa_ioc_send_enable(ioc);
+	case IOCPF_E_DISABLE:
+		del_timer(&ioc->iocpf_timer);
+		bfa_ioc_sync_leave(ioc);
+		bfa_nw_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabled);
 		break;
 
 	default:
@@ -396,37 +766,49 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 static void
-bfa_ioc_sm_getattr_entry(struct bfa_ioc *ioc)
+bfa_iocpf_sm_enabling_entry(struct bfa_iocpf *iocpf)
 {
-	bfa_ioc_timer_start(ioc);
-	bfa_ioc_send_getattr(ioc);
+	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_TOV));
+	bfa_ioc_send_enable(iocpf->ioc);
 }
 
 /**
- * @brief
- * IOC configuration in progress. Timer is active.
+ * Host IOC function is being enabled, awaiting response from firmware.
+ * Semaphore is acquired.
  */
 static void
-bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_iocpf_sm_enabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
+	struct bfa_ioc *ioc = iocpf->ioc;
+
 	switch (event) {
-	case IOC_E_FWRSP_GETATTR:
-		bfa_ioc_timer_stop(ioc);
-		bfa_ioc_check_attr_wwns(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
+	case IOCPF_E_FWRSP_ENABLE:
+		del_timer(&ioc->iocpf_timer);
+		bfa_nw_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_ready);
 		break;
 
-	case IOC_E_HWERROR:
-		bfa_ioc_timer_stop(ioc);
-		/* fall through */
+	case IOCPF_E_INITFAIL:
+		del_timer(&ioc->iocpf_timer);
+		/*
+		 * !!! fall through !!!
+		 */
+	case IOCPF_E_TIMEOUT:
+		bfa_nw_ioc_hw_sem_release(ioc);
+		if (event == IOCPF_E_TIMEOUT)
+			bfa_ioc_pf_failed(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail_sync);
+		break;
 
-	case IOC_E_TIMEOUT:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_initfail);
+	case IOCPF_E_DISABLE:
+		del_timer(&ioc->iocpf_timer);
+		bfa_nw_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling);
 		break;
 
-	case IOC_E_DISABLE:
-		bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+	case IOCPF_E_FWREADY:
+		bfa_ioc_send_enable(ioc);
 		break;
 
 	default:
@@ -434,36 +816,42 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
+static bool
+bfa_nw_ioc_is_operational(struct bfa_ioc *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_op);
+}
+
 static void
-bfa_ioc_sm_op_entry(struct bfa_ioc *ioc)
+bfa_iocpf_sm_ready_entry(struct bfa_iocpf *iocpf)
 {
-	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_OK);
-	bfa_ioc_hb_monitor(ioc);
+	bfa_ioc_pf_enabled(iocpf->ioc);
 }
 
 static void
-bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_iocpf_sm_ready(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
+	struct bfa_ioc *ioc = iocpf->ioc;
+
 	switch (event) {
-	case IOC_E_ENABLE:
+	case IOCPF_E_DISABLE:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling);
 		break;
 
-	case IOC_E_DISABLE:
-		bfa_ioc_hb_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
+	case IOCPF_E_GETATTRFAIL:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail_sync);
 		break;
 
-	case IOC_E_HWERROR:
-	case IOC_E_FWREADY:
-		/**
-		 * Hard error or IOC recovery by other function.
-		 * Treat it same as heartbeat failure.
-		 */
-		bfa_ioc_hb_stop(ioc);
-		/* !!! fall through !!! */
+	case IOCPF_E_FAIL:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail_sync);
+		break;
 
-	case IOC_E_HBFAIL:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_hbfail);
+	case IOCPF_E_FWREADY:
+		bfa_ioc_pf_failed(ioc);
+		if (bfa_nw_ioc_is_operational(ioc))
+			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail_sync);
+		else
+			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail_sync);
 		break;
 
 	default:
@@ -472,33 +860,40 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 static void
-bfa_ioc_sm_disabling_entry(struct bfa_ioc *ioc)
+bfa_iocpf_sm_disabling_entry(struct bfa_iocpf *iocpf)
 {
-	bfa_ioc_timer_start(ioc);
-	bfa_ioc_send_disable(ioc);
+	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_TOV));
+	bfa_ioc_send_disable(iocpf->ioc);
 }
 
 /**
  * IOC is being disabled
  */
 static void
-bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_iocpf_sm_disabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
+	struct bfa_ioc *ioc = iocpf->ioc;
+
 	switch (event) {
-	case IOC_E_FWRSP_DISABLE:
-		bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+	case IOCPF_E_FWRSP_DISABLE:
+	case IOCPF_E_FWREADY:
+		del_timer(&ioc->iocpf_timer);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
 		break;
 
-	case IOC_E_HWERROR:
-		bfa_ioc_timer_stop(ioc);
+	case IOCPF_E_FAIL:
+		del_timer(&ioc->iocpf_timer);
 		/*
 		 * !!! fall through !!!
 		 */
 
-	case IOC_E_TIMEOUT:
+	case IOCPF_E_TIMEOUT:
 		writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
+		break;
+
+	case IOCPF_E_FWRSP_ENABLE:
 		break;
 
 	default:
@@ -506,33 +901,58 @@ bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
-/**
- * IOC disable completion entry.
- */
 static void
-bfa_ioc_sm_disabled_entry(struct bfa_ioc *ioc)
+bfa_iocpf_sm_disabling_sync_entry(struct bfa_iocpf *iocpf)
 {
-	bfa_ioc_disable_comp(ioc);
+	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
+/**
+ * IOC hb ack request is being removed.
+ */
 static void
-bfa_ioc_sm_disabled(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_iocpf_sm_disabling_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
+	struct bfa_ioc *ioc = iocpf->ioc;
+
 	switch (event) {
-	case IOC_E_ENABLE:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_semwait);
+	case IOCPF_E_SEMLOCKED:
+		bfa_ioc_sync_leave(ioc);
+		bfa_nw_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabled);
 		break;
 
-	case IOC_E_DISABLE:
-		ioc->cbfn->disable_cbfn(ioc->bfa);
+	case IOCPF_E_FAIL:
 		break;
 
-	case IOC_E_FWREADY:
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * IOC disable completion entry.
+ */
+static void
+bfa_iocpf_sm_disabled_entry(struct bfa_iocpf *iocpf)
+{
+	bfa_ioc_pf_disabled(iocpf->ioc);
+}
+
+static void
+bfa_iocpf_sm_disabled(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	struct bfa_ioc *ioc = iocpf->ioc;
+
+	switch (event) {
+	case IOCPF_E_ENABLE:
+		iocpf->retry_count = 0;
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_semwait);
 		break;
 
-	case IOC_E_DETACH:
+	case IOCPF_E_STOP:
 		bfa_ioc_firmware_unlock(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
 		break;
 
 	default:
@@ -541,33 +961,50 @@ bfa_ioc_sm_disabled(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 static void
-bfa_ioc_sm_initfail_entry(struct bfa_ioc *ioc)
+bfa_iocpf_sm_initfail_sync_entry(struct bfa_iocpf *iocpf)
 {
-	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
-	bfa_ioc_timer_start(ioc);
+	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
 /**
- * @brief
  * Hardware initialization failed.
  */
 static void
-bfa_ioc_sm_initfail(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_iocpf_sm_initfail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
+	struct bfa_ioc *ioc = iocpf->ioc;
+
 	switch (event) {
-	case IOC_E_DISABLE:
-		bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+	case IOCPF_E_SEMLOCKED:
+		bfa_ioc_notify_fail(ioc);
+		bfa_ioc_sync_ack(ioc);
+		iocpf->retry_count++;
+		if (iocpf->retry_count >= BFA_IOC_HWINIT_MAX) {
+			bfa_ioc_sync_leave(ioc);
+			bfa_nw_ioc_hw_sem_release(ioc);
+			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail);
+		} else {
+			if (bfa_ioc_sync_complete(ioc))
+				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
+			else {
+				bfa_nw_ioc_hw_sem_release(ioc);
+				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_semwait);
+			}
+		}
 		break;
 
-	case IOC_E_DETACH:
-		bfa_ioc_timer_stop(ioc);
+	case IOCPF_E_DISABLE:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
+		break;
+
+	case IOCPF_E_STOP:
+		bfa_ioc_hw_sem_get_cancel(ioc);
 		bfa_ioc_firmware_unlock(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
 		break;
 
-	case IOC_E_TIMEOUT:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_semwait);
+	case IOCPF_E_FAIL:
 		break;
 
 	default:
@@ -576,80 +1013,108 @@ bfa_ioc_sm_initfail(struct bfa_ioc *ioc, enum ioc_event event)
 }
 
 static void
-bfa_ioc_sm_hbfail_entry(struct bfa_ioc *ioc)
+bfa_iocpf_sm_initfail_entry(struct bfa_iocpf *iocpf)
 {
-	struct list_head			*qe;
-	struct bfa_ioc_hbfail_notify *notify;
+	bfa_ioc_pf_initfailed(iocpf->ioc);
+}
 
-	/**
-	 * Mark IOC as failed in hardware and stop firmware.
-	 */
-	bfa_ioc_lpu_stop(ioc);
-	writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+/**
+ * Hardware initialization failed.
+ */
+static void
+bfa_iocpf_sm_initfail(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	struct bfa_ioc *ioc = iocpf->ioc;
 
-	/**
-	 * Notify other functions on HB failure.
-	 */
-	bfa_ioc_notify_hbfail(ioc);
+	switch (event) {
+	case IOCPF_E_DISABLE:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabled);
+		break;
 
-	/**
-	 * Notify driver and common modules registered for notification.
-	 */
-	ioc->cbfn->hbfail_cbfn(ioc->bfa);
-	list_for_each(qe, &ioc->hb_notify_q) {
-		notify = (struct bfa_ioc_hbfail_notify *) qe;
-		notify->cbfn(notify->cbarg);
+	case IOCPF_E_STOP:
+		bfa_ioc_firmware_unlock(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
 	}
+}
 
+static void
+bfa_iocpf_sm_fail_sync_entry(struct bfa_iocpf *iocpf)
+{
 	/**
-	 * Flush any queued up mailbox requests.
+	 * Mark IOC as failed in hardware and stop firmware.
 	 */
-	bfa_ioc_mbox_hbfail(ioc);
+	bfa_ioc_lpu_stop(iocpf->ioc);
 
 	/**
-	 * Trigger auto-recovery after a delay.
+	 * Flush any queued up mailbox requests.
 	 */
-	if (ioc->auto_recover)
-		mod_timer(&ioc->ioc_timer, jiffies +
-			msecs_to_jiffies(BFA_IOC_TOV_RECOVER));
+	bfa_ioc_mbox_hbfail(iocpf->ioc);
+	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
 /**
- * @brief
- * IOC heartbeat failure.
+ * IOC is in failed state.
  */
 static void
-bfa_ioc_sm_hbfail(struct bfa_ioc *ioc, enum ioc_event event)
+bfa_iocpf_sm_fail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
-	switch (event) {
+	struct bfa_ioc *ioc = iocpf->ioc;
 
-	case IOC_E_ENABLE:
-		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+	switch (event) {
+	case IOCPF_E_SEMLOCKED:
+		iocpf->retry_count = 0;
+		bfa_ioc_sync_ack(ioc);
+		bfa_ioc_notify_fail(ioc);
+		if (!iocpf->auto_recover) {
+			bfa_ioc_sync_leave(ioc);
+			bfa_nw_ioc_hw_sem_release(ioc);
+			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
+		} else {
+			if (bfa_ioc_sync_complete(ioc))
+				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
+			else {
+				bfa_nw_ioc_hw_sem_release(ioc);
+				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_semwait);
+			}
+		}
 		break;
 
-	case IOC_E_DISABLE:
-		if (ioc->auto_recover)
-			bfa_ioc_timer_stop(ioc);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+	case IOCPF_E_DISABLE:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
 		break;
 
-	case IOC_E_TIMEOUT:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_semwait);
+	case IOCPF_E_FAIL:
 		break;
 
-	case IOC_E_FWREADY:
-		/**
-		 * Recovery is already initiated by other function.
-		 */
-		break;
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
 
-	case IOC_E_HWERROR:
-		/*
-		 * HB failure notification, ignore.
-		 */
+static void
+bfa_iocpf_sm_fail_entry(struct bfa_iocpf *iocpf)
+{
+}
+
+/**
+ * @brief
+ * IOC is in failed state.
+ */
+static void
+bfa_iocpf_sm_fail(struct bfa_iocpf *iocpf, enum iocpf_event event)
+{
+	switch (event) {
+	case IOCPF_E_DISABLE:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabled);
 		break;
+
 	default:
-		bfa_sm_fault(ioc, event);
+		bfa_sm_fault(iocpf->ioc, event);
 	}
 }
 
@@ -674,14 +1139,6 @@ bfa_ioc_disable_comp(struct bfa_ioc *ioc)
 	}
 }
 
-void
-bfa_nw_ioc_sem_timeout(void *ioc_arg)
-{
-	struct bfa_ioc *ioc = (struct bfa_ioc *) ioc_arg;
-
-	bfa_ioc_hw_sem_get(ioc);
-}
-
 bool
 bfa_nw_ioc_sem_get(void __iomem *sem_reg)
 {
@@ -721,7 +1178,7 @@ bfa_ioc_hw_sem_get(struct bfa_ioc *ioc)
 	 */
 	r32 = readl(ioc->ioc_regs.ioc_sem_reg);
 	if (r32 == 0) {
-		bfa_fsm_send_event(ioc, IOC_E_SEMLOCKED);
+		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_SEMLOCKED);
 		return;
 	}
 
@@ -932,7 +1389,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 		 */
 		bfa_ioc_msgflush(ioc);
 		ioc->cbfn->reset_cbfn(ioc->bfa);
-		bfa_fsm_send_event(ioc, IOC_E_FWREADY);
+		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_FWREADY);
 		return;
 	}
 
@@ -1018,7 +1475,6 @@ bfa_nw_ioc_hb_check(void *cbarg)
 
 	hb_count = readl(ioc->ioc_regs.heartbeat);
 	if (ioc->hb_count == hb_count) {
-		pr_crit("Firmware heartbeat failure at %d", hb_count);
 		bfa_ioc_recover(ioc);
 		return;
 	} else {
@@ -1189,6 +1645,55 @@ bfa_ioc_mbox_hbfail(struct bfa_ioc *ioc)
 		bfa_q_deq(&mod->cmd_q, &cmd);
 }
 
+static void
+bfa_ioc_fail_notify(struct bfa_ioc *ioc)
+{
+	struct list_head		*qe;
+	struct bfa_ioc_hbfail_notify	*notify;
+
+	/**
+	 * Notify driver and common modules registered for notification.
+	 */
+	ioc->cbfn->hbfail_cbfn(ioc->bfa);
+	list_for_each(qe, &ioc->hb_notify_q) {
+		notify = (struct bfa_ioc_hbfail_notify *) qe;
+		notify->cbfn(notify->cbarg);
+	}
+}
+
+static void
+bfa_ioc_pf_enabled(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_ENABLED);
+}
+
+static void
+bfa_ioc_pf_disabled(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_DISABLED);
+}
+
+static void
+bfa_ioc_pf_initfailed(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_INITFAILED);
+}
+
+static void
+bfa_ioc_pf_failed(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_PFAILED);
+}
+
+static void
+bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc)
+{
+	/**
+	 * Provide enable completion callback and AEN notification.
+	 */
+	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+}
+
 /**
  * IOC public
  */
@@ -1284,6 +1789,7 @@ static void
 bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 {
 	union bfi_ioc_i2h_msg_u	*msg;
+	struct bfa_iocpf *iocpf = &ioc->iocpf;
 
 	msg = (union bfi_ioc_i2h_msg_u *) m;
 
@@ -1294,15 +1800,15 @@ bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 		break;
 
 	case BFI_IOC_I2H_READY_EVENT:
-		bfa_fsm_send_event(ioc, IOC_E_FWREADY);
+		bfa_fsm_send_event(iocpf, IOCPF_E_FWREADY);
 		break;
 
 	case BFI_IOC_I2H_ENABLE_REPLY:
-		bfa_fsm_send_event(ioc, IOC_E_FWRSP_ENABLE);
+		bfa_fsm_send_event(iocpf, IOCPF_E_FWRSP_ENABLE);
 		break;
 
 	case BFI_IOC_I2H_DISABLE_REPLY:
-		bfa_fsm_send_event(ioc, IOC_E_FWRSP_DISABLE);
+		bfa_fsm_send_event(iocpf, IOCPF_E_FWRSP_DISABLE);
 		break;
 
 	case BFI_IOC_I2H_GETATTR_REPLY:
@@ -1328,11 +1834,13 @@ bfa_nw_ioc_attach(struct bfa_ioc *ioc, void *bfa, struct bfa_ioc_cbfn *cbfn)
 	ioc->fcmode	= false;
 	ioc->pllinit	= false;
 	ioc->dbg_fwsave_once = true;
+	ioc->iocpf.ioc  = ioc;
 
 	bfa_ioc_mbox_attach(ioc);
 	INIT_LIST_HEAD(&ioc->hb_notify_q);
 
-	bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+	bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
+	bfa_fsm_send_event(ioc, IOC_E_RESET);
 }
 
 /**
@@ -1637,7 +2145,40 @@ bfa_ioc_get_adapter_model(struct bfa_ioc *ioc, char *model)
 static enum bfa_ioc_state
 bfa_ioc_get_state(struct bfa_ioc *ioc)
 {
-	return bfa_sm_to_state(ioc_sm_table, ioc->fsm);
+	enum bfa_iocpf_state iocpf_st;
+	enum bfa_ioc_state ioc_st = bfa_sm_to_state(ioc_sm_table, ioc->fsm);
+
+	if (ioc_st == BFA_IOC_ENABLING ||
+		ioc_st == BFA_IOC_FAIL || ioc_st == BFA_IOC_INITFAIL) {
+
+		iocpf_st = bfa_sm_to_state(iocpf_sm_table, ioc->iocpf.fsm);
+
+		switch (iocpf_st) {
+		case BFA_IOCPF_SEMWAIT:
+			ioc_st = BFA_IOC_SEMWAIT;
+			break;
+
+		case BFA_IOCPF_HWINIT:
+			ioc_st = BFA_IOC_HWINIT;
+			break;
+
+		case BFA_IOCPF_FWMISMATCH:
+			ioc_st = BFA_IOC_FWMISMATCH;
+			break;
+
+		case BFA_IOCPF_FAIL:
+			ioc_st = BFA_IOC_FAIL;
+			break;
+
+		case BFA_IOCPF_INITFAIL:
+			ioc_st = BFA_IOC_INITFAIL;
+			break;
+
+		default:
+			break;
+		}
+	}
+	return ioc_st;
 }
 
 void
@@ -1678,8 +2219,13 @@ bfa_nw_ioc_get_mac(struct bfa_ioc *ioc)
 static void
 bfa_ioc_recover(struct bfa_ioc *ioc)
 {
-	bfa_ioc_stats(ioc, ioc_hbfails);
-	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
+	u16 bdf;
+
+	bdf = (ioc->pcidev.pci_slot << 8 | ioc->pcidev.pci_func << 3 |
+					ioc->pcidev.device_id);
+
+	pr_crit("Firmware heartbeat failure at %d", bdf);
+	BUG_ON(1);
 }
 
 static void
@@ -1687,5 +2233,61 @@ bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc)
 {
 	if (bfa_ioc_get_type(ioc) == BFA_IOC_TYPE_LL)
 		return;
+}
+
+/**
+ * @dg hal_iocpf_pvt BFA IOC PF private functions
+ * @{
+ */
+
+static void
+bfa_iocpf_enable(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_ENABLE);
+}
 
+static void
+bfa_iocpf_disable(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_DISABLE);
+}
+
+static void
+bfa_iocpf_fail(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_FAIL);
+}
+
+static void
+bfa_iocpf_initfail(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_INITFAIL);
+}
+
+static void
+bfa_iocpf_getattrfail(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_GETATTRFAIL);
+}
+
+static void
+bfa_iocpf_stop(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_STOP);
+}
+
+void
+bfa_nw_iocpf_timeout(void *ioc_arg)
+{
+	struct bfa_ioc  *ioc = (struct bfa_ioc *) ioc_arg;
+
+	bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_TIMEOUT);
+}
+
+void
+bfa_nw_iocpf_sem_timeout(void *ioc_arg)
+{
+	struct bfa_ioc  *ioc = (struct bfa_ioc *) ioc_arg;
+
+	bfa_ioc_hw_sem_get(ioc);
 }
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index a73d84e..e4974bc 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -26,16 +26,7 @@
 #define BFA_IOC_TOV		3000	/* msecs */
 #define BFA_IOC_HWSEM_TOV	500	/* msecs */
 #define BFA_IOC_HB_TOV		500	/* msecs */
-#define BFA_IOC_HWINIT_MAX	2
-#define BFA_IOC_TOV_RECOVER	BFA_IOC_HB_TOV
-
-/**
- * Generic Scatter Gather Element used by driver
- */
-struct bfa_sge {
-	u32	sg_len;
-	void	*sg_addr;
-};
+#define BFA_IOC_HWINIT_MAX	5
 
 /**
  * PCI device information required by IOC
@@ -65,19 +56,6 @@ struct bfa_dma {
 #define BFI_SMEM_CT_SIZE	0x280000U	/* ! 2.5MB for catapult	*/
 
 /**
- * @brief BFA dma address assignment macro
- */
-#define bfa_dma_addr_set(dma_addr, pa)	\
-		__bfa_dma_addr_set(&dma_addr, (u64)pa)
-
-static inline void
-__bfa_dma_addr_set(union bfi_addr_u *dma_addr, u64 pa)
-{
-	dma_addr->a32.addr_lo = (u32) pa;
-	dma_addr->a32.addr_hi = (u32) (upper_32_bits(pa));
-}
-
-/**
  * @brief BFA dma address assignment macro. (big endian format)
  */
 #define bfa_dma_be_addr_set(dma_addr, pa)	\
@@ -105,8 +83,11 @@ struct bfa_ioc_regs {
 	void __iomem *host_page_num_fn;
 	void __iomem *heartbeat;
 	void __iomem *ioc_fwstate;
+	void __iomem *alt_ioc_fwstate;
 	void __iomem *ll_halt;
+	void __iomem *alt_ll_halt;
 	void __iomem *err_set;
+	void __iomem *ioc_fail_sync;
 	void __iomem *shirq_isr_next;
 	void __iomem *shirq_msk_next;
 	void __iomem *smem_page_start;
@@ -165,16 +146,22 @@ struct bfa_ioc_hbfail_notify {
 	(__notify)->cbarg = (__cbarg);				\
 } while (0)
 
+struct bfa_iocpf {
+	bfa_fsm_t		fsm;
+	struct bfa_ioc		*ioc;
+	u32			retry_count;
+	bool			auto_recover;
+};
+
 struct bfa_ioc {
 	bfa_fsm_t		fsm;
 	struct bfa 		*bfa;
 	struct bfa_pcidev 	pcidev;
-	struct bfa_timer_mod	*timer_mod;
 	struct timer_list 	ioc_timer;
+	struct timer_list 	iocpf_timer;
 	struct timer_list 	sem_timer;
 	struct timer_list	hb_timer;
 	u32			hb_count;
-	u32			retry_count;
 	struct list_head	hb_notify_q;
 	void			*dbg_fwsave;
 	int			dbg_fwsave_len;
@@ -182,7 +169,6 @@ struct bfa_ioc {
 	enum bfi_mclass		ioc_mc;
 	struct bfa_ioc_regs 	ioc_regs;
 	struct bfa_ioc_drv_stats stats;
-	bool			auto_recover;
 	bool			fcmode;
 	bool			ctdev;
 	bool			cna;
@@ -195,6 +181,7 @@ struct bfa_ioc {
 	struct bfa_ioc_cbfn	*cbfn;
 	struct bfa_ioc_mbox_mod	mbox_mod;
 	struct bfa_ioc_hwif	*ioc_hwif;
+	struct bfa_iocpf	iocpf;
 };
 
 struct bfa_ioc_hwif {
@@ -205,8 +192,12 @@ struct bfa_ioc_hwif {
 	void		(*ioc_map_port)	(struct bfa_ioc *ioc);
 	void		(*ioc_isr_mode_set)	(struct bfa_ioc *ioc,
 					bool msix);
-	void		(*ioc_notify_hbfail)	(struct bfa_ioc *ioc);
+	void		(*ioc_notify_fail)	(struct bfa_ioc *ioc);
 	void		(*ioc_ownership_reset)	(struct bfa_ioc *ioc);
+	void		(*ioc_sync_join)	(struct bfa_ioc *ioc);
+	void		(*ioc_sync_leave)	(struct bfa_ioc *ioc);
+	void		(*ioc_sync_ack)		(struct bfa_ioc *ioc);
+	bool		(*ioc_sync_complete)	(struct bfa_ioc *ioc);
 };
 
 #define bfa_ioc_pcifn(__ioc)		((__ioc)->pcidev.pci_func)
@@ -271,7 +262,6 @@ void bfa_nw_ioc_enable(struct bfa_ioc *ioc);
 void bfa_nw_ioc_disable(struct bfa_ioc *ioc);
 
 void bfa_nw_ioc_error_isr(struct bfa_ioc *ioc);
-
 void bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr);
 void bfa_nw_ioc_hbfail_register(struct bfa_ioc *ioc,
 	struct bfa_ioc_hbfail_notify *notify);
@@ -289,7 +279,8 @@ mac_t bfa_nw_ioc_get_mac(struct bfa_ioc *ioc);
  */
 void bfa_nw_ioc_timeout(void *ioc);
 void bfa_nw_ioc_hb_check(void *ioc);
-void bfa_nw_ioc_sem_timeout(void *ioc);
+void bfa_nw_iocpf_timeout(void *ioc);
+void bfa_nw_iocpf_sem_timeout(void *ioc);
 
 /*
  * F/W Image Size & Chunk
diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index 121cfd6..469997c 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -22,6 +22,15 @@
 #include "bfi_ctreg.h"
 #include "bfa_defs.h"
 
+#define bfa_ioc_ct_sync_pos(__ioc)	\
+		((u32) (1 << bfa_ioc_pcifn(__ioc)))
+#define BFA_IOC_SYNC_REQD_SH		16
+#define bfa_ioc_ct_get_sync_ackd(__val) (__val & 0x0000ffff)
+#define bfa_ioc_ct_clear_sync_ackd(__val) (__val & 0xffff0000)
+#define bfa_ioc_ct_get_sync_reqd(__val) (__val >> BFA_IOC_SYNC_REQD_SH)
+#define bfa_ioc_ct_sync_reqd_pos(__ioc) \
+		(bfa_ioc_ct_sync_pos(__ioc) << BFA_IOC_SYNC_REQD_SH)
+
 /*
  * forward declarations
  */
@@ -30,8 +39,12 @@ static void bfa_ioc_ct_firmware_unlock(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_reg_init(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_map_port(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_isr_mode_set(struct bfa_ioc *ioc, bool msix);
-static void bfa_ioc_ct_notify_hbfail(struct bfa_ioc *ioc);
+static void bfa_ioc_ct_notify_fail(struct bfa_ioc *ioc);
 static void bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc);
+static void bfa_ioc_ct_sync_join(struct bfa_ioc *ioc);
+static void bfa_ioc_ct_sync_leave(struct bfa_ioc *ioc);
+static void bfa_ioc_ct_sync_ack(struct bfa_ioc *ioc);
+static bool bfa_ioc_ct_sync_complete(struct bfa_ioc *ioc);
 static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode);
 
 static struct bfa_ioc_hwif nw_hwif_ct;
@@ -48,8 +61,12 @@ bfa_nw_ioc_set_ct_hwif(struct bfa_ioc *ioc)
 	nw_hwif_ct.ioc_reg_init = bfa_ioc_ct_reg_init;
 	nw_hwif_ct.ioc_map_port = bfa_ioc_ct_map_port;
 	nw_hwif_ct.ioc_isr_mode_set = bfa_ioc_ct_isr_mode_set;
-	nw_hwif_ct.ioc_notify_hbfail = bfa_ioc_ct_notify_hbfail;
+	nw_hwif_ct.ioc_notify_fail = bfa_ioc_ct_notify_fail;
 	nw_hwif_ct.ioc_ownership_reset = bfa_ioc_ct_ownership_reset;
+	nw_hwif_ct.ioc_sync_join = bfa_ioc_ct_sync_join;
+	nw_hwif_ct.ioc_sync_leave = bfa_ioc_ct_sync_leave;
+	nw_hwif_ct.ioc_sync_ack = bfa_ioc_ct_sync_ack;
+	nw_hwif_ct.ioc_sync_complete = bfa_ioc_ct_sync_complete;
 
 	ioc->ioc_hwif = &nw_hwif_ct;
 }
@@ -86,6 +103,7 @@ bfa_ioc_ct_firmware_lock(struct bfa_ioc *ioc)
 	if (usecnt == 0) {
 		writel(1, ioc->ioc_regs.ioc_usage_reg);
 		bfa_nw_ioc_sem_release(ioc->ioc_regs.ioc_usage_sem_reg);
+		writel(0, ioc->ioc_regs.ioc_fail_sync);
 		return true;
 	}
 
@@ -149,12 +167,14 @@ bfa_ioc_ct_firmware_unlock(struct bfa_ioc *ioc)
  * Notify other functions on HB failure.
  */
 static void
-bfa_ioc_ct_notify_hbfail(struct bfa_ioc *ioc)
+bfa_ioc_ct_notify_fail(struct bfa_ioc *ioc)
 {
 	if (ioc->cna) {
 		writel(__FW_INIT_HALT_P, ioc->ioc_regs.ll_halt);
+		writel(__FW_INIT_HALT_P, ioc->ioc_regs.alt_ll_halt);
 		/* Wait for halt to take effect */
 		readl(ioc->ioc_regs.ll_halt);
+		readl(ioc->ioc_regs.alt_ll_halt);
 	} else {
 		writel(__PSS_ERR_STATUS_SET, ioc->ioc_regs.err_set);
 		readl(ioc->ioc_regs.err_set);
@@ -206,15 +226,19 @@ bfa_ioc_ct_reg_init(struct bfa_ioc *ioc)
 	if (ioc->port_id == 0) {
 		ioc->ioc_regs.heartbeat = rb + BFA_IOC0_HBEAT_REG;
 		ioc->ioc_regs.ioc_fwstate = rb + BFA_IOC0_STATE_REG;
+		ioc->ioc_regs.alt_ioc_fwstate = rb + BFA_IOC1_STATE_REG;
 		ioc->ioc_regs.hfn_mbox_cmd = rb + iocreg_mbcmd_p0[pcifn].hfn;
 		ioc->ioc_regs.lpu_mbox_cmd = rb + iocreg_mbcmd_p0[pcifn].lpu;
 		ioc->ioc_regs.ll_halt = rb + FW_INIT_HALT_P0;
+		ioc->ioc_regs.alt_ll_halt = rb + FW_INIT_HALT_P1;
 	} else {
 		ioc->ioc_regs.heartbeat = (rb + BFA_IOC1_HBEAT_REG);
 		ioc->ioc_regs.ioc_fwstate = (rb + BFA_IOC1_STATE_REG);
+		ioc->ioc_regs.alt_ioc_fwstate = rb + BFA_IOC0_STATE_REG;
 		ioc->ioc_regs.hfn_mbox_cmd = rb + iocreg_mbcmd_p1[pcifn].hfn;
 		ioc->ioc_regs.lpu_mbox_cmd = rb + iocreg_mbcmd_p1[pcifn].lpu;
 		ioc->ioc_regs.ll_halt = rb + FW_INIT_HALT_P1;
+		ioc->ioc_regs.alt_ll_halt = rb + FW_INIT_HALT_P0;
 	}
 
 	/*
@@ -232,6 +256,7 @@ bfa_ioc_ct_reg_init(struct bfa_ioc *ioc)
 	ioc->ioc_regs.ioc_usage_sem_reg = (rb + HOST_SEM1_REG);
 	ioc->ioc_regs.ioc_init_sem_reg = (rb + HOST_SEM2_REG);
 	ioc->ioc_regs.ioc_usage_reg = (rb + BFA_FW_USE_COUNT);
+	ioc->ioc_regs.ioc_fail_sync = (rb + BFA_IOC_FAIL_SYNC);
 
 	/**
 	 * sram memory access
@@ -317,6 +342,77 @@ bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc)
 	bfa_nw_ioc_hw_sem_release(ioc);
 }
 
+/**
+ * Synchronized IOC failure processing routines
+ */
+static void
+bfa_ioc_ct_sync_join(struct bfa_ioc *ioc)
+{
+	u32 r32 = readl(ioc->ioc_regs.ioc_fail_sync);
+	u32 sync_pos = bfa_ioc_ct_sync_reqd_pos(ioc);
+
+	writel((r32 | sync_pos), ioc->ioc_regs.ioc_fail_sync);
+}
+
+static void
+bfa_ioc_ct_sync_leave(struct bfa_ioc *ioc)
+{
+	u32 r32 = readl(ioc->ioc_regs.ioc_fail_sync);
+	u32 sync_msk = bfa_ioc_ct_sync_reqd_pos(ioc) |
+					bfa_ioc_ct_sync_pos(ioc);
+
+	writel((r32 & ~sync_msk), ioc->ioc_regs.ioc_fail_sync);
+}
+
+static void
+bfa_ioc_ct_sync_ack(struct bfa_ioc *ioc)
+{
+	u32 r32 = readl(ioc->ioc_regs.ioc_fail_sync);
+
+	writel((r32 | bfa_ioc_ct_sync_pos(ioc)), ioc->ioc_regs.ioc_fail_sync);
+}
+
+static bool
+bfa_ioc_ct_sync_complete(struct bfa_ioc *ioc)
+{
+	u32 r32 = readl(ioc->ioc_regs.ioc_fail_sync);
+	u32 sync_reqd = bfa_ioc_ct_get_sync_reqd(r32);
+	u32 sync_ackd = bfa_ioc_ct_get_sync_ackd(r32);
+	u32 tmp_ackd;
+
+	if (sync_ackd == 0)
+		return true;
+
+	/**
+	 * The check below is to see whether any other PCI fn
+	 * has reinitialized the ASIC (reset sync_ackd bits)
+	 * and failed again while this IOC was waiting for hw
+	 * semaphore (in bfa_iocpf_sm_semwait()).
+	 */
+	tmp_ackd = sync_ackd;
+	if ((sync_reqd &  bfa_ioc_ct_sync_pos(ioc)) &&
+			!(sync_ackd & bfa_ioc_ct_sync_pos(ioc)))
+		sync_ackd |= bfa_ioc_ct_sync_pos(ioc);
+
+	if (sync_reqd == sync_ackd) {
+		writel(bfa_ioc_ct_clear_sync_ackd(r32),
+				ioc->ioc_regs.ioc_fail_sync);
+		writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+		writel(BFI_IOC_FAIL, ioc->ioc_regs.alt_ioc_fwstate);
+		return true;
+	}
+
+	/**
+	 * If another PCI fn reinitialized and failed again while
+	 * this IOC was waiting for hw sem, the sync_ackd bit for
+	 * this IOC need to be set again to allow reinitialization.
+	 */
+	if (tmp_ackd != sync_ackd)
+		writel((r32 | sync_ackd), ioc->ioc_regs.ioc_fail_sync);
+
+	return false;
+}
+
 static enum bfa_status
 bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode)
 {
diff --git a/drivers/net/bna/bfi_ctreg.h b/drivers/net/bna/bfi_ctreg.h
index 404ea35..5130d79 100644
--- a/drivers/net/bna/bfi_ctreg.h
+++ b/drivers/net/bna/bfi_ctreg.h
@@ -535,6 +535,7 @@ enum {
 #define BFA_IOC1_HBEAT_REG		HOST_SEM2_INFO_REG
 #define BFA_IOC1_STATE_REG		HOST_SEM3_INFO_REG
 #define BFA_FW_USE_COUNT		 HOST_SEM4_INFO_REG
+#define BFA_IOC_FAIL_SYNC		HOST_SEM5_INFO_REG
 
 #define CPE_DEPTH_Q(__n) \
 	(CPE_DEPTH_Q0 + (__n) * (CPE_DEPTH_Q1 - CPE_DEPTH_Q0))
@@ -552,22 +553,30 @@ enum {
 	(RME_PI_PTR_Q0 + (__n) * (RME_PI_PTR_Q1 - RME_PI_PTR_Q0))
 #define RME_CI_PTR_Q(__n) \
 	(RME_CI_PTR_Q0 + (__n) * (RME_CI_PTR_Q1 - RME_CI_PTR_Q0))
-#define HQM_QSET_RXQ_DRBL_P0(__n) (HQM_QSET0_RXQ_DRBL_P0 + (__n) \
-	* (HQM_QSET1_RXQ_DRBL_P0 - HQM_QSET0_RXQ_DRBL_P0))
-#define HQM_QSET_TXQ_DRBL_P0(__n) (HQM_QSET0_TXQ_DRBL_P0 + (__n) \
-	* (HQM_QSET1_TXQ_DRBL_P0 - HQM_QSET0_TXQ_DRBL_P0))
-#define HQM_QSET_IB_DRBL_1_P0(__n) (HQM_QSET0_IB_DRBL_1_P0 + (__n) \
-	* (HQM_QSET1_IB_DRBL_1_P0 - HQM_QSET0_IB_DRBL_1_P0))
-#define HQM_QSET_IB_DRBL_2_P0(__n) (HQM_QSET0_IB_DRBL_2_P0 + (__n) \
-	* (HQM_QSET1_IB_DRBL_2_P0 - HQM_QSET0_IB_DRBL_2_P0))
-#define HQM_QSET_RXQ_DRBL_P1(__n) (HQM_QSET0_RXQ_DRBL_P1 + (__n) \
-	* (HQM_QSET1_RXQ_DRBL_P1 - HQM_QSET0_RXQ_DRBL_P1))
-#define HQM_QSET_TXQ_DRBL_P1(__n) (HQM_QSET0_TXQ_DRBL_P1 + (__n) \
-	* (HQM_QSET1_TXQ_DRBL_P1 - HQM_QSET0_TXQ_DRBL_P1))
-#define HQM_QSET_IB_DRBL_1_P1(__n) (HQM_QSET0_IB_DRBL_1_P1 + (__n) \
-	* (HQM_QSET1_IB_DRBL_1_P1 - HQM_QSET0_IB_DRBL_1_P1))
-#define HQM_QSET_IB_DRBL_2_P1(__n) (HQM_QSET0_IB_DRBL_2_P1 + (__n) \
-	* (HQM_QSET1_IB_DRBL_2_P1 - HQM_QSET0_IB_DRBL_2_P1))
+#define HQM_QSET_RXQ_DRBL_P0(__n) \
+	(HQM_QSET0_RXQ_DRBL_P0 + (__n) * \
+		(HQM_QSET1_RXQ_DRBL_P0 - HQM_QSET0_RXQ_DRBL_P0))
+#define HQM_QSET_TXQ_DRBL_P0(__n) \
+	(HQM_QSET0_TXQ_DRBL_P0 + (__n) * \
+		(HQM_QSET1_TXQ_DRBL_P0 - HQM_QSET0_TXQ_DRBL_P0))
+#define HQM_QSET_IB_DRBL_1_P0(__n) \
+	(HQM_QSET0_IB_DRBL_1_P0 + (__n) * \
+		(HQM_QSET1_IB_DRBL_1_P0 - HQM_QSET0_IB_DRBL_1_P0))
+#define HQM_QSET_IB_DRBL_2_P0(__n) \
+	(HQM_QSET0_IB_DRBL_2_P0 + (__n) * \
+		(HQM_QSET1_IB_DRBL_2_P0 - HQM_QSET0_IB_DRBL_2_P0))
+#define HQM_QSET_RXQ_DRBL_P1(__n) \
+	(HQM_QSET0_RXQ_DRBL_P1 + (__n) * \
+		(HQM_QSET1_RXQ_DRBL_P1 - HQM_QSET0_RXQ_DRBL_P1))
+#define HQM_QSET_TXQ_DRBL_P1(__n) \
+	(HQM_QSET0_TXQ_DRBL_P1 + (__n) * \
+		(HQM_QSET1_TXQ_DRBL_P1 - HQM_QSET0_TXQ_DRBL_P1))
+#define HQM_QSET_IB_DRBL_1_P1(__n) \
+	(HQM_QSET0_IB_DRBL_1_P1 + (__n) * \
+		(HQM_QSET1_IB_DRBL_1_P1 - HQM_QSET0_IB_DRBL_1_P1))
+#define HQM_QSET_IB_DRBL_2_P1(__n) \
+	(HQM_QSET0_IB_DRBL_2_P1 + (__n) * \
+		(HQM_QSET1_IB_DRBL_2_P1 - HQM_QSET0_IB_DRBL_2_P1))
 
 #define CPE_Q_NUM(__fn, __q) (((__fn) << 2) + (__q))
 #define RME_Q_NUM(__fn, __q) (((__fn) << 2) + (__q))
diff --git a/drivers/net/bna/bna.h b/drivers/net/bna/bna.h
index fd93f76..a287f89 100644
--- a/drivers/net/bna/bna.h
+++ b/drivers/net/bna/bna.h
@@ -32,8 +32,6 @@ extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 /* Log string size */
 #define BNA_MESSAGE_SIZE		256
 
-#define bna_device_timer(_dev)		bfa_timer_beat(&((_dev)->timer_mod))
-
 /* MBOX API for PORT, TX, RX */
 #define bna_mbox_qe_fill(_qe, _cmd, _cmd_len, _cbfn, _cbarg)		\
 do {									\
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 200df60..277dbe0 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -1425,13 +1425,24 @@ bnad_ioc_hb_check(unsigned long data)
 }
 
 static void
-bnad_ioc_sem_timeout(unsigned long data)
+bnad_iocpf_timeout(unsigned long data)
 {
 	struct bnad *bnad = (struct bnad *)data;
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_ioc_sem_timeout((void *) &bnad->bna.device.ioc);
+	bfa_nw_iocpf_timeout((void *) &bnad->bna.device.ioc);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+}
+
+static void
+bnad_iocpf_sem_timeout(unsigned long data)
+{
+	struct bnad *bnad = (struct bnad *)data;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bfa_nw_iocpf_sem_timeout((void *) &bnad->bna.device.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -3132,11 +3143,13 @@ bnad_pci_probe(struct pci_dev *pdev,
 				((unsigned long)bnad));
 	setup_timer(&bnad->bna.device.ioc.hb_timer, bnad_ioc_hb_check,
 				((unsigned long)bnad));
-	setup_timer(&bnad->bna.device.ioc.sem_timer, bnad_ioc_sem_timeout,
+	setup_timer(&bnad->bna.device.ioc.iocpf_timer, bnad_iocpf_timeout,
+				((unsigned long)bnad));
+	setup_timer(&bnad->bna.device.ioc.sem_timer, bnad_iocpf_sem_timeout,
 				((unsigned long)bnad));
 
 	/* Now start the timer before calling IOC */
-	mod_timer(&bnad->bna.device.ioc.ioc_timer,
+	mod_timer(&bnad->bna.device.ioc.iocpf_timer,
 		  jiffies + msecs_to_jiffies(BNA_IOC_TIMER_FREQ));
 
 	/*
-- 
1.7.1

