From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 28/45] bna: Add New IOC event
Date: Mon, 18 Jul 2011 01:22:48 -0700
Message-ID: <1310977385-5268-18-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48250 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754412Ab1GRIYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:24 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - ACQ_ADDR IOC state and its state machine implementation.
 - The changes related to FAA enable/disable/query in firmware

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h        |    1 +
 drivers/net/bna/bfa_defs_status.h |    9 +++++
 drivers/net/bna/bfa_ioc.c         |   69 ++++++++++++++++++++++++++++++++++++-
 drivers/net/bna/bfi.h             |    1 +
 4 files changed, 79 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index 621d50b..e7dd91f 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -125,6 +125,7 @@ enum bfa_ioc_state {
 	BFA_IOC_FWMISMATCH	= 11,	/*!< IOC f/w different from drivers */
 	BFA_IOC_ENABLING	= 12,	/*!< IOC is being enabled */
 	BFA_IOC_HWFAIL		= 13,	/*!< PCI mapping doesn't exist */
+	BFA_IOC_ACQ_ADDR	= 14,	/*!< Acquiring addr from fabric */
 };
 
 /**
diff --git a/drivers/net/bna/bfa_defs_status.h b/drivers/net/bna/bfa_defs_status.h
index 7c5fe6c..bf7f87a 100644
--- a/drivers/net/bna/bfa_defs_status.h
+++ b/drivers/net/bna/bfa_defs_status.h
@@ -205,6 +205,15 @@ enum bfa_status {
 	BFA_STATUS_BOOT_CODE_TIMEDOUT = 177,
 	BFA_STATUS_NO_VPORT_LOCK = 178,
 	BFA_STATUS_VPORT_NO_CNFG = 179,
+	BFA_STATUS_FEATURE_NOT_SUPPORTED = 180,
+	BFA_STATUS_ENTRY_EXISTS = 181,
+	BFA_STATUS_ENTRY_NOT_EXISTS = 182,
+	BFA_STATUS_NO_CHANGE = 183,
+	BFA_STATUS_DISABLED = 184,
+	BFA_STATUS_FAA_ENABLED = 185,
+	BFA_STATUS_FAA_DISABLED = 186,
+	BFA_STATUS_FAA_ACQUIRED = 187,
+	BFA_STATUS_FAA_ACQ_ADDR = 188,
 	BFA_STATUS_MAX_VAL
 };
 
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 2dd19d2..2130b5a 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -113,6 +113,7 @@ enum ioc_event {
 	IOC_E_HWERROR		= 10,	/*!< hardware error interrupt	*/
 	IOC_E_TIMEOUT		= 11,	/*!< timeout			*/
 	IOC_E_HWFAILED		= 12,	/*!< PCI mapping failure notice	*/
+	IOC_E_FWRSP_ACQ_ADDR	= 13,	/*!< Acquiring address		*/
 };
 
 bfa_fsm_state_decl(bfa_ioc, uninit, struct bfa_ioc, enum ioc_event);
@@ -125,6 +126,7 @@ bfa_fsm_state_decl(bfa_ioc, fail, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, disabling, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, disabled, struct bfa_ioc, enum ioc_event);
 bfa_fsm_state_decl(bfa_ioc, hwfail, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, acq_addr, struct bfa_ioc, enum ioc_event);
 
 static struct bfa_sm_table ioc_sm_table[] = {
 	{BFA_SM(bfa_ioc_sm_uninit), BFA_IOC_UNINIT},
@@ -137,6 +139,7 @@ static struct bfa_sm_table ioc_sm_table[] = {
 	{BFA_SM(bfa_ioc_sm_disabling), BFA_IOC_DISABLING},
 	{BFA_SM(bfa_ioc_sm_disabled), BFA_IOC_DISABLED},
 	{BFA_SM(bfa_ioc_sm_hwfail), BFA_IOC_HWFAIL},
+	{BFA_SM(bfa_ioc_sm_acq_addr), BFA_IOC_ACQ_ADDR},
 };
 
 /**
@@ -351,9 +354,17 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 	case IOC_E_FWRSP_GETATTR:
 		del_timer(&ioc->ioc_timer);
 		bfa_ioc_check_attr_wwns(ioc);
+		bfa_ioc_hb_monitor(ioc);
 		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
 		break;
 
+	case IOC_E_FWRSP_ACQ_ADDR:
+		del_timer(&ioc->ioc_timer);
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_FAA_ACQ_ADDR);
+		bfa_ioc_hb_monitor(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_acq_addr);
+		break;
+
 	case IOC_E_PFFAILED:
 	case IOC_E_HWERROR:
 		del_timer(&ioc->ioc_timer);
@@ -378,11 +389,54 @@ bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
+/**
+ * Acquiring address from fabric (entry function)
+ */
+static void
+bfa_ioc_sm_acq_addr_entry(struct bfa_ioc *ioc)
+{
+}
+
+/**
+ * Acquiring address from the fabric
+ */
+static void
+bfa_ioc_sm_acq_addr(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_FWRSP_GETATTR:
+		bfa_ioc_check_attr_wwns(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
+		break;
+
+	case IOC_E_PFFAILED:
+	case IOC_E_HWERROR:
+		bfa_ioc_hb_stop(ioc);
+	case IOC_E_HBFAIL:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
+		if (event != IOC_E_PFFAILED)
+			bfa_iocpf_getattrfail(ioc);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_hb_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabling);
+		break;
+
+	case IOC_E_ENABLE:
+		break;
+
+	default:
+		bfa_sm_fault(event);
+	}
+}
+
 static void
 bfa_ioc_sm_op_entry(struct bfa_ioc *ioc)
 {
 	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_OK);
-	bfa_ioc_hb_monitor(ioc);
+	bfa_ioc_event_notify(ioc, BFA_IOC_E_ENABLED);
 }
 
 static void
@@ -1639,6 +1693,15 @@ bfa_ioc_getattr_reply(struct bfa_ioc *ioc)
 }
 
 /**
+ * Response from f/w that IOC attributes are not ready
+ */
+static void
+bfa_ioc_acq_addr_reply(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_FWRSP_ACQ_ADDR);
+}
+
+/**
  * Attach time initialization of mbox logic.
  */
 static void
@@ -1856,6 +1919,10 @@ bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 		bfa_ioc_getattr_reply(ioc);
 		break;
 
+	case BFI_IOC_I2H_ACQ_ADDR_REPLY:
+		bfa_ioc_acq_addr_reply(ioc);
+		break;
+
 	default:
 		BUG_ON(1);
 	}
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index d95eeb2..8d238a7 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -225,6 +225,7 @@ enum bfi_ioc_i2h_msgs {
 	BFI_IOC_I2H_DISABLE_REPLY	= BFA_I2HM(2),
 	BFI_IOC_I2H_GETATTR_REPLY	= BFA_I2HM(3),
 	BFI_IOC_I2H_HBEAT		= BFA_I2HM(4),
+	BFI_IOC_I2H_ACQ_ADDR_REPLY	= BFA_I2HM(5),
 };
 
 /**
-- 
1.7.1

