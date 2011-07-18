From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 18/45] bna: Implement Polling Mechanism for FW Ready
Date: Mon, 18 Jul 2011 01:22:38 -0700
Message-ID: <1310977385-5268-8-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37790 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801Ab1GRIXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:50 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - A poll mechanism replaces the current interrupt based FW READY method.
 - The timer based poll routine in IOC will query the ioc_fwstate register
   to see if there is a state change in FW, and sends the READY event.
 - Removed infrastructure needed to support mbox READY event from fw as well as
   IOC code.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |  117 +++++++++++++++-----------------------------
 drivers/net/bna/bfa_ioc.h |    5 +-
 drivers/net/bna/bfi.h     |   11 +----
 3 files changed, 45 insertions(+), 88 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index fcc9278..df26a8a 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -61,6 +61,7 @@ static bool bfa_nw_auto_recover = true;
 static void bfa_ioc_hw_sem_get(struct bfa_ioc *ioc);
 static void bfa_ioc_hw_sem_get_cancel(struct bfa_ioc *ioc);
 static void bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force);
+static void bfa_ioc_poll_fwinit(struct bfa_ioc *ioc);
 static void bfa_ioc_send_enable(struct bfa_ioc *ioc);
 static void bfa_ioc_send_disable(struct bfa_ioc *ioc);
 static void bfa_ioc_send_getattr(struct bfa_ioc *ioc);
@@ -77,7 +78,6 @@ static void bfa_ioc_lpu_stop(struct bfa_ioc *ioc);
 static void bfa_ioc_fail_notify(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_enabled(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_disabled(struct bfa_ioc *ioc);
-static void bfa_ioc_pf_initfailed(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_failed(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc);
 static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
@@ -107,11 +107,10 @@ enum ioc_event {
 	IOC_E_ENABLED		= 5,	/*!< f/w enabled		*/
 	IOC_E_FWRSP_GETATTR	= 6,	/*!< IOC get attribute response	*/
 	IOC_E_DISABLED		= 7,	/*!< f/w disabled		*/
-	IOC_E_INITFAILED	= 8,	/*!< failure notice by iocpf sm	*/
-	IOC_E_PFAILED		= 9,	/*!< failure notice by iocpf sm	*/
-	IOC_E_HBFAIL		= 10,	/*!< heartbeat failure		*/
-	IOC_E_HWERROR		= 11,	/*!< hardware error interrupt	*/
-	IOC_E_TIMEOUT		= 12,	/*!< timeout			*/
+	IOC_E_PFAILED		= 8,	/*!< failure notice by iocpf sm	*/
+	IOC_E_HBFAIL		= 9,	/*!< heartbeat failure		*/
+	IOC_E_HWERROR		= 10,	/*!< hardware error interrupt	*/
+	IOC_E_TIMEOUT		= 11,	/*!< timeout			*/
 };
 
 bfa_fsm_state_decl(bfa_ioc, uninit, struct bfa_ioc, enum ioc_event);
@@ -299,7 +298,7 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 		/* !!! fall through !!! */
 	case IOC_E_HWERROR:
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
 		if (event != IOC_E_PFAILED)
 			bfa_iocpf_initfail(ioc);
 		break;
@@ -351,7 +350,7 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 		/* fall through */
 	case IOC_E_TIMEOUT:
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
 		if (event != IOC_E_PFAILED)
 			bfa_iocpf_getattrfail(ioc);
 		break;
@@ -492,14 +491,11 @@ bfa_ioc_sm_fail_retry(struct bfa_ioc *ioc, enum ioc_event event)
 		 * Initialization retry failed.
 		 */
 		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
 		if (event != IOC_E_PFAILED)
 			bfa_iocpf_initfail(ioc);
 		break;
 
-	case IOC_E_INITFAILED:
-		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
-		break;
-
 	case IOC_E_ENABLE:
 		break;
 
@@ -561,7 +557,7 @@ bfa_ioc_sm_fail(struct bfa_ioc *ioc, enum ioc_event event)
 static void
 bfa_iocpf_sm_reset_entry(struct bfa_iocpf *iocpf)
 {
-	iocpf->retry_count = 0;
+	iocpf->fw_mismatch_notified = false;
 	iocpf->auto_recover = bfa_nw_auto_recover;
 }
 
@@ -605,7 +601,6 @@ bfa_iocpf_sm_fwcheck(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	case IOCPF_E_SEMLOCKED:
 		if (bfa_ioc_firmware_lock(ioc)) {
 			if (bfa_ioc_sync_start(ioc)) {
-				iocpf->retry_count = 0;
 				bfa_ioc_sync_join(ioc);
 				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
 			} else {
@@ -643,10 +638,10 @@ static void
 bfa_iocpf_sm_mismatch_entry(struct bfa_iocpf *iocpf)
 {
 	/* Call only the first time sm enters fwmismatch state. */
-	if (iocpf->retry_count == 0)
+	if (iocpf->fw_mismatch_notified == false)
 		bfa_ioc_pf_fwmismatch(iocpf->ioc);
 
-	iocpf->retry_count++;
+	iocpf->fw_mismatch_notified = true;
 	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
 		msecs_to_jiffies(BFA_IOC_TOV));
 }
@@ -722,8 +717,7 @@ bfa_iocpf_sm_semwait(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_hwinit_entry(struct bfa_iocpf *iocpf)
 {
-	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
-		msecs_to_jiffies(BFA_IOC_TOV));
+	iocpf->poll_time = 0;
 	bfa_ioc_reset(iocpf->ioc, 0);
 }
 
@@ -738,20 +732,12 @@ bfa_iocpf_sm_hwinit(struct bfa_iocpf *iocpf, enum iocpf_event event)
 
 	switch (event) {
 	case IOCPF_E_FWREADY:
-		del_timer(&ioc->iocpf_timer);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_enabling);
 		break;
 
-	case IOCPF_E_INITFAIL:
-		del_timer(&ioc->iocpf_timer);
-		/*
-		 * !!! fall through !!!
-		 */
-
 	case IOCPF_E_TIMEOUT:
 		bfa_nw_ioc_hw_sem_release(ioc);
-		if (event == IOCPF_E_TIMEOUT)
-			bfa_ioc_pf_failed(ioc);
+		bfa_ioc_pf_failed(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail_sync);
 		break;
 
@@ -772,6 +758,7 @@ bfa_iocpf_sm_enabling_entry(struct bfa_iocpf *iocpf)
 {
 	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
 		msecs_to_jiffies(BFA_IOC_TOV));
+	iocpf->ioc->cbfn->reset_cbfn(iocpf->ioc->bfa);
 	bfa_ioc_send_enable(iocpf->ioc);
 }
 
@@ -809,21 +796,11 @@ bfa_iocpf_sm_enabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling);
 		break;
 
-	case IOCPF_E_FWREADY:
-		bfa_ioc_send_enable(ioc);
-		break;
-
 	default:
 		bfa_sm_fault(event);
 	}
 }
 
-static bool
-bfa_nw_ioc_is_operational(struct bfa_ioc *ioc)
-{
-	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_op);
-}
-
 static void
 bfa_iocpf_sm_ready_entry(struct bfa_iocpf *iocpf)
 {
@@ -833,8 +810,6 @@ bfa_iocpf_sm_ready_entry(struct bfa_iocpf *iocpf)
 static void
 bfa_iocpf_sm_ready(struct bfa_iocpf *iocpf, enum iocpf_event event)
 {
-	struct bfa_ioc *ioc = iocpf->ioc;
-
 	switch (event) {
 	case IOCPF_E_DISABLE:
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling);
@@ -848,14 +823,6 @@ bfa_iocpf_sm_ready(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail_sync);
 		break;
 
-	case IOCPF_E_FWREADY:
-		bfa_ioc_pf_failed(ioc);
-		if (bfa_nw_ioc_is_operational(ioc))
-			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail_sync);
-		else
-			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail_sync);
-		break;
-
 	default:
 		bfa_sm_fault(event);
 	}
@@ -879,7 +846,6 @@ bfa_iocpf_sm_disabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 
 	switch (event) {
 	case IOCPF_E_FWRSP_DISABLE:
-	case IOCPF_E_FWREADY:
 		del_timer(&ioc->iocpf_timer);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
 		break;
@@ -948,7 +914,6 @@ bfa_iocpf_sm_disabled(struct bfa_iocpf *iocpf, enum iocpf_event event)
 
 	switch (event) {
 	case IOCPF_E_ENABLE:
-		iocpf->retry_count = 0;
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_semwait);
 		break;
 
@@ -979,20 +944,10 @@ bfa_iocpf_sm_initfail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	switch (event) {
 	case IOCPF_E_SEMLOCKED:
 		bfa_ioc_notify_fail(ioc);
-		bfa_ioc_sync_ack(ioc);
-		iocpf->retry_count++;
-		if (iocpf->retry_count >= BFA_IOC_HWINIT_MAX) {
-			bfa_ioc_sync_leave(ioc);
-			bfa_nw_ioc_hw_sem_release(ioc);
-			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail);
-		} else {
-			if (bfa_ioc_sync_complete(ioc))
-				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_hwinit);
-			else {
-				bfa_nw_ioc_hw_sem_release(ioc);
-				bfa_fsm_set_state(iocpf, bfa_iocpf_sm_semwait);
-			}
-		}
+		bfa_ioc_sync_leave(ioc);
+		writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+		bfa_nw_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail);
 		break;
 
 	case IOCPF_E_DISABLE:
@@ -1017,7 +972,6 @@ bfa_iocpf_sm_initfail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_initfail_entry(struct bfa_iocpf *iocpf)
 {
-	bfa_ioc_pf_initfailed(iocpf->ioc);
 }
 
 /**
@@ -1068,11 +1022,11 @@ bfa_iocpf_sm_fail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 
 	switch (event) {
 	case IOCPF_E_SEMLOCKED:
-		iocpf->retry_count = 0;
 		bfa_ioc_sync_ack(ioc);
 		bfa_ioc_notify_fail(ioc);
 		if (!iocpf->auto_recover) {
 			bfa_ioc_sync_leave(ioc);
+			writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
 			bfa_nw_ioc_hw_sem_release(ioc);
 			bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
 		} else {
@@ -1383,7 +1337,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 	 * just wait for an initialization completion interrupt.
 	 */
 	if (ioc_fwstate == BFI_IOC_INITING) {
-		ioc->cbfn->reset_cbfn(ioc->bfa);
+		bfa_ioc_poll_fwinit(ioc);
 		return;
 	}
 
@@ -1397,7 +1351,6 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 		 * be flushed. Otherwise MSI-X interrupts are not delivered.
 		 */
 		bfa_ioc_msgflush(ioc);
-		ioc->cbfn->reset_cbfn(ioc->bfa);
 		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_FWREADY);
 		return;
 	}
@@ -1681,12 +1634,6 @@ bfa_ioc_pf_disabled(struct bfa_ioc *ioc)
 }
 
 static void
-bfa_ioc_pf_initfailed(struct bfa_ioc *ioc)
-{
-	bfa_fsm_send_event(ioc, IOC_E_INITFAILED);
-}
-
-static void
 bfa_ioc_pf_failed(struct bfa_ioc *ioc)
 {
 	bfa_fsm_send_event(ioc, IOC_E_PFAILED);
@@ -1755,6 +1702,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 	 */
 	ioc->cbfn->reset_cbfn(ioc->bfa);
 	bfa_ioc_lpu_start(ioc);
+	bfa_ioc_poll_fwinit(ioc);
 }
 
 /**
@@ -1810,10 +1758,6 @@ bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 	case BFI_IOC_I2H_HBEAT:
 		break;
 
-	case BFI_IOC_I2H_READY_EVENT:
-		bfa_fsm_send_event(iocpf, IOCPF_E_FWREADY);
-		break;
-
 	case BFI_IOC_I2H_ENABLE_REPLY:
 		bfa_fsm_send_event(iocpf, IOCPF_E_FWRSP_ENABLE);
 		break;
@@ -2341,3 +2285,22 @@ bfa_nw_iocpf_sem_timeout(void *ioc_arg)
 
 	bfa_ioc_hw_sem_get(ioc);
 }
+
+static void
+bfa_ioc_poll_fwinit(struct bfa_ioc *ioc)
+{
+	u32 fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+
+	if (fwstate == BFI_IOC_DISABLED) {
+		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_FWREADY);
+		return;
+	}
+
+	if (ioc->iocpf.poll_time >= BFA_IOC_TOV) {
+		bfa_nw_iocpf_timeout(ioc);
+	} else {
+		ioc->iocpf.poll_time += BFA_IOC_POLL_TOV;
+		mod_timer(&ioc->ioc_timer, jiffies +
+			msecs_to_jiffies(BFA_IOC_POLL_TOV));
+	}
+}
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 95358a2..bcc9acc 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -26,7 +26,7 @@
 #define BFA_IOC_TOV		3000	/* msecs */
 #define BFA_IOC_HWSEM_TOV	500	/* msecs */
 #define BFA_IOC_HB_TOV		500	/* msecs */
-#define BFA_IOC_HWINIT_MAX	5
+#define BFA_IOC_POLL_TOV	200	/* msecs */
 
 /**
  * PCI device information required by IOC
@@ -170,8 +170,9 @@ struct bfa_ioc_hbfail_notify {
 struct bfa_iocpf {
 	bfa_fsm_t		fsm;
 	struct bfa_ioc		*ioc;
-	u32			retry_count;
+	bool			fw_mismatch_notified;
 	bool			auto_recover;
+	u32			poll_time;
 };
 
 struct bfa_ioc {
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 284c3f8..d95eeb2 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -224,8 +224,7 @@ enum bfi_ioc_i2h_msgs {
 	BFI_IOC_I2H_ENABLE_REPLY	= BFA_I2HM(1),
 	BFI_IOC_I2H_DISABLE_REPLY	= BFA_I2HM(2),
 	BFI_IOC_I2H_GETATTR_REPLY	= BFA_I2HM(3),
-	BFI_IOC_I2H_READY_EVENT		= BFA_I2HM(4),
-	BFI_IOC_I2H_HBEAT		= BFA_I2HM(5),
+	BFI_IOC_I2H_HBEAT		= BFA_I2HM(4),
 };
 
 /**
@@ -333,12 +332,6 @@ enum bfi_port_mode {
 /**
  *  BFI_IOC_I2H_READY_EVENT message
  */
-struct bfi_ioc_rdy_event {
-	struct bfi_mhdr mh;		/*!< common msg header */
-	u8			init_status;	/*!< init event status */
-	u8			rsvd[3];
-};
-
 struct bfi_ioc_hbeat {
 	struct bfi_mhdr mh;		/*!< common msg header		*/
 	u32	   hb_count;	/*!< current heart beat count	*/
@@ -426,7 +419,7 @@ union bfi_ioc_h2i_msg_u {
  */
 union bfi_ioc_i2h_msg_u {
 	struct bfi_mhdr mh;
-	struct bfi_ioc_rdy_event rdy_event;
+	struct bfi_ioc_ctrl_reply fw_event;
 	u32			mboxmsg[BFI_IOC_MSGSZ];
 };
 
-- 
1.7.1

