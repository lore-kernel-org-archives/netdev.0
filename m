From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 25/45] bna: Move FW Init to HW Init and Disable Hang Unmapped Fix
Date: Mon, 18 Jul 2011 01:22:45 -0700
Message-ID: <1310977385-5268-15-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48244 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754323Ab1GRIYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:13 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Move the bfa_ioc_poll_fwinit() function call out of bfa_ioc_boot() and put
   it inside the caller of bfa_ioc_boot(), which is bfa_ioc_hwinit()
 - Diag memtest call bfa_ioc_boot() to download memtest specific fw code.
   Inside bfa_ioc_boot(), it called bfa_ioc_poll_fwinit() which start a timer,
   with a timeout duration much shorter than the memtest timer. As a result,
   this poll timer expired, and cause the assert. But eventually, the
   memtest complete successfully.
 - Handle the case where PCI mapping goes away when IOCPF state machine is
   waiting for semaphore.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h |    1 +
 drivers/net/bna/bfa_ioc.c  |   91 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 89 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index e89830f..621d50b 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -124,6 +124,7 @@ enum bfa_ioc_state {
 	BFA_IOC_DISABLED	= 10,	/*!< IOC is disabled */
 	BFA_IOC_FWMISMATCH	= 11,	/*!< IOC f/w different from drivers */
 	BFA_IOC_ENABLING	= 12,	/*!< IOC is being enabled */
+	BFA_IOC_HWFAIL		= 13,	/*!< PCI mapping doesn't exist */
 };
 
 /**
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index a38f5cd..216d0d1 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -79,6 +79,7 @@ static void bfa_ioc_fail_notify(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_enabled(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_disabled(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_failed(struct bfa_ioc *ioc);
+static void bfa_ioc_pf_hwfailed(struct bfa_ioc *ioc);
 static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc);
 static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
 			 u32 boot_param);
@@ -111,6 +112,7 @@ enum ioc_event {
 	IOC_E_HBFAIL		= 9,	/*!< heartbeat failure		*/
 	IOC_E_HWERROR		= 10,	/*!< hardware error interrupt	*/
 	IOC_E_TIMEOUT		= 11,	/*!< timeout			*/
+	IOC_E_HWFAILED		= 12,	/*!< PCI mapping failure notice	*/
 };
 
 bfa_fsm_state_decl(bfa_ioc, uninit, struct bfa_ioc, enum ioc_event);
@@ -122,6 +124,7 @@ bfa_fsm_state_decl(bfa_ioc, fail_retry, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, fail, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, disabling, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, disabled, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, hwfail, struct bfa_ioc, enum ioc_event);
 
 static struct bfa_sm_table ioc_sm_table[] = {
 	{BFA_SM(bfa_ioc_sm_uninit), BFA_IOC_UNINIT},
@@ -133,6 +136,7 @@ static struct bfa_sm_table ioc_sm_table[] = {
 	{BFA_SM(bfa_ioc_sm_fail), BFA_IOC_FAIL},
 	{BFA_SM(bfa_ioc_sm_disabling), BFA_IOC_DISABLING},
 	{BFA_SM(bfa_ioc_sm_disabled), BFA_IOC_DISABLED},
+	{BFA_SM(bfa_ioc_sm_hwfail), BFA_IOC_HWFAIL},
 };
 
 /**
@@ -164,6 +168,7 @@ enum iocpf_event {
 	IOCPF_E_GETATTRFAIL	= 9,	/*!< init fail notice by ioc sm	*/
 	IOCPF_E_SEMLOCKED	= 10,   /*!< h/w semaphore is locked	*/
 	IOCPF_E_TIMEOUT		= 11,   /*!< f/w response timeout	*/
+	IOCPF_E_SEM_ERROR	= 12,   /*!< h/w sem mapping error	*/
 };
 
 /**
@@ -303,6 +308,11 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 			bfa_iocpf_initfail(ioc);
 		break;
 
+	case IOC_E_HWFAILED:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_hwfail);
+		break;
+
 	case IOC_E_DISABLE:
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
 		break;
@@ -434,6 +444,11 @@ bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_iocpf_fail(ioc);
 		break;
 
+	case IOC_E_HWFAILED:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_hwfail);
+		bfa_ioc_disable_comp(ioc);
+		break;
+
 	default:
 		bfa_sm_fault(event);
 	}
@@ -497,6 +512,11 @@ bfa_ioc_sm_fail_retry(struct bfa_ioc *ioc, enum ioc_event event)
 			bfa_iocpf_initfail(ioc);
 		break;
 
+	case IOC_E_HWFAILED:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_hwfail);
+		break;
+
 	case IOC_E_ENABLE:
 		break;
 
@@ -548,6 +568,36 @@ bfa_ioc_sm_fail(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
+static void
+bfa_ioc_sm_hwfail_entry(struct bfa_ioc *ioc)
+{
+}
+
+/**
+ * IOC failure.
+ */
+static void
+bfa_ioc_sm_hwfail(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+
+	case IOC_E_ENABLE:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		break;
+
+	case IOC_E_DISABLE:
+		ioc->cbfn->disable_cbfn(ioc->bfa);
+		break;
+
+	case IOC_E_DETACH:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_uninit);
+		break;
+
+	default:
+		bfa_sm_fault(event);
+	}
+}
+
 /**
  * IOCPF State Machine
  */
@@ -616,6 +666,11 @@ bfa_iocpf_sm_fwcheck(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		}
 		break;
 
+	case IOCPF_E_SEM_ERROR:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
+		bfa_ioc_pf_hwfailed(ioc);
+		break;
+
 	case IOCPF_E_DISABLE:
 		bfa_ioc_hw_sem_get_cancel(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
@@ -705,6 +760,11 @@ bfa_iocpf_sm_semwait(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		}
 		break;
 
+	case IOCPF_E_SEM_ERROR:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
+		bfa_ioc_pf_hwfailed(ioc);
+		break;
+
 	case IOCPF_E_DISABLE:
 		bfa_ioc_hw_sem_get_cancel(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
@@ -894,6 +954,11 @@ bfa_iocpf_sm_disabling_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabled);
 		break;
 
+	case IOCPF_E_SEM_ERROR:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
+		bfa_ioc_pf_hwfailed(ioc);
+		break;
+
 	case IOCPF_E_FAIL:
 		break;
 
@@ -955,6 +1020,11 @@ bfa_iocpf_sm_initfail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_initfail);
 		break;
 
+	case IOCPF_E_SEM_ERROR:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
+		bfa_ioc_pf_hwfailed(ioc);
+		break;
+
 	case IOCPF_E_DISABLE:
 		bfa_ioc_hw_sem_get_cancel(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
@@ -1044,6 +1114,11 @@ bfa_iocpf_sm_fail_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		}
 		break;
 
+	case IOCPF_E_SEM_ERROR:
+		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_fail);
+		bfa_ioc_pf_hwfailed(ioc);
+		break;
+
 	case IOCPF_E_DISABLE:
 		bfa_ioc_hw_sem_get_cancel(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
@@ -1143,7 +1218,11 @@ bfa_ioc_hw_sem_get(struct bfa_ioc *ioc)
 	 * will return 1. Semaphore is released by writing 1 to the register
 	 */
 	r32 = readl(ioc->ioc_regs.ioc_sem_reg);
-	if (r32 == 0) {
+	if (r32 == ~0) {
+		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_SEM_ERROR);
+		return;
+	}
+	if (!(r32 & 1)) {
 		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_SEMLOCKED);
 		return;
 	}
@@ -1334,6 +1413,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 
 	if (!fwvalid) {
 		bfa_ioc_boot(ioc, BFI_FWBOOT_TYPE_NORMAL, boot_env);
+		bfa_ioc_poll_fwinit(ioc);
 		return;
 	}
 
@@ -1364,6 +1444,7 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 	 * Initialize the h/w for any other states.
 	 */
 	bfa_ioc_boot(ioc, BFI_FWBOOT_TYPE_NORMAL, boot_env);
+	bfa_ioc_poll_fwinit(ioc);
 }
 
 void
@@ -1645,6 +1726,12 @@ bfa_ioc_pf_failed(struct bfa_ioc *ioc)
 }
 
 static void
+bfa_ioc_pf_hwfailed(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_HWFAILED);
+}
+
+static void
 bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc)
 {
 	/**
@@ -1701,9 +1788,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 
 	bfa_ioc_msgflush(ioc);
 	bfa_ioc_download_fw(ioc, boot_type, boot_env);
-
 	bfa_ioc_lpu_start(ioc);
-	bfa_ioc_poll_fwinit(ioc);
 }
 
 /**
-- 
1.7.1

