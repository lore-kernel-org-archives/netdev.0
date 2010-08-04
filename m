From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 4/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 3 Aug 2010 22:33:36 -0700
Message-ID: <201008040533.o745Xa2Z023729@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ddutt@brocade.com>, <huangj@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54426 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613Ab0HDFdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 01:33:44 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o745UNmY023494
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 22:33:43 -0700
Received: from hq-exedge.brocade.com (hq-exedge.brocade.com [66.243.153.83])
	by mx0b-000f0801.pphosted.com with ESMTP id qf0f101uk-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 22:33:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 4/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
Source is based against net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bfa_ioc.c   | 1839 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 bna.h       |  654 +++++++++++++++++++++
 bna_hw.h    | 1491 ++++++++++++++++++++++++++++++++++++++++++++++++
 bna_types.h | 1135 +++++++++++++++++++++++++++++++++++++
 4 files changed, 5119 insertions(+)

diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_ioc.c net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_ioc.c
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_ioc.c	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_ioc.c	2010-08-02 17:19:19.828262000 -0700
@@ -0,0 +1,1839 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+
+#include "bfa_ioc.h"
+#include "cna.h"
+#include "bfi.h"
+#include "bfi_ctreg.h"
+#include "bfa_defs.h"
+
+/**
+ * IOC local definitions
+ */
+
+#define bfa_ioc_timer_start(__ioc)					\
+	mod_timer(&(__ioc)->ioc_timer, jiffies +	\
+			msecs_to_jiffies(BFA_IOC_TOV))
+#define bfa_ioc_timer_stop(__ioc)   del_timer(&(__ioc)->ioc_timer)
+
+#define bfa_ioc_recovery_timer_start(__ioc)				\
+	mod_timer(&(__ioc)->ioc_timer, jiffies +	\
+			msecs_to_jiffies(BFA_IOC_TOV_RECOVER))
+
+#define bfa_sem_timer_start(__ioc)					\
+	mod_timer(&(__ioc)->sem_timer, jiffies +	\
+			msecs_to_jiffies(BFA_IOC_HWSEM_TOV))
+#define bfa_sem_timer_stop(__ioc)	del_timer(&(__ioc)->sem_timer)
+
+#define bfa_hb_timer_start(__ioc)					\
+	mod_timer(&(__ioc)->hb_timer, jiffies +		\
+			msecs_to_jiffies(BFA_IOC_HB_TOV))
+#define bfa_hb_timer_stop(__ioc)	del_timer(&(__ioc)->hb_timer)
+
+/**
+ * Asic specific macros : see bfa_hw_cb.c and bfa_hw_ct.c for details.
+ */
+
+#define bfa_ioc_firmware_lock(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_firmware_lock(__ioc))
+#define bfa_ioc_firmware_unlock(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_firmware_unlock(__ioc))
+#define bfa_ioc_reg_init(__ioc) ((__ioc)->ioc_hwif->ioc_reg_init(__ioc))
+#define bfa_ioc_map_port(__ioc) ((__ioc)->ioc_hwif->ioc_map_port(__ioc))
+#define bfa_ioc_notify_hbfail(__ioc)			\
+			((__ioc)->ioc_hwif->ioc_notify_hbfail(__ioc))
+
+#define bfa_ioc_is_optrom(__ioc)	\
+	(bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(__ioc)) < BFA_IOC_FWIMG_MINSZ)
+
+#define bfa_ioc_mbox_cmd_pending(__ioc)		\
+			(!list_empty(&((__ioc)->mbox_mod.cmd_q)) || \
+			readl((__ioc)->ioc_regs.hfn_mbox_cmd))
+
+bool bfa_auto_recover = true;
+
+/*
+ * forward declarations
+ */
+static void bfa_ioc_hw_sem_get(struct bfa_ioc *ioc);
+static void bfa_ioc_hw_sem_get_cancel(struct bfa_ioc *ioc);
+static void bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force);
+static void bfa_ioc_send_enable(struct bfa_ioc *ioc);
+static void bfa_ioc_send_disable(struct bfa_ioc *ioc);
+static void bfa_ioc_send_getattr(struct bfa_ioc *ioc);
+static void bfa_ioc_hb_monitor(struct bfa_ioc *ioc);
+static void bfa_ioc_hb_stop(struct bfa_ioc *ioc);
+static void bfa_ioc_reset(struct bfa_ioc *ioc, bool force);
+static void bfa_ioc_mbox_poll(struct bfa_ioc *ioc);
+static void bfa_ioc_mbox_hbfail(struct bfa_ioc *ioc);
+static void bfa_ioc_recover(struct bfa_ioc *ioc);
+static void bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc);
+static void bfa_ioc_disable_comp(struct bfa_ioc *ioc);
+static void bfa_ioc_lpu_stop(struct bfa_ioc *ioc);
+
+/**
+ * IOC state machine events
+ */
+enum ioc_event {
+	IOC_E_ENABLE		= 1,	/*!< IOC enable request		*/
+	IOC_E_DISABLE		= 2,	/*!< IOC disable request	*/
+	IOC_E_TIMEOUT		= 3,	/*!< f/w response timeout	*/
+	IOC_E_FWREADY		= 4,	/*!< f/w initialization done	*/
+	IOC_E_FWRSP_GETATTR	= 5,	/*!< IOC get attribute response	*/
+	IOC_E_FWRSP_ENABLE	= 6,	/*!< enable f/w response	*/
+	IOC_E_FWRSP_DISABLE	= 7,	/*!< disable f/w response	*/
+	IOC_E_HBFAIL		= 8,	/*!< heartbeat failure		*/
+	IOC_E_HWERROR		= 9,	/*!< hardware error interrupt	*/
+	IOC_E_SEMLOCKED		= 10,	/*!< h/w semaphore is locked	*/
+	IOC_E_DETACH		= 11,	/*!< driver detach cleanup	*/
+};
+
+bfa_fsm_state_decl(bfa_ioc, reset, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, fwcheck, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, mismatch, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, semwait, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, hwinit, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, enabling, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, getattr, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, op, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, initfail, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, hbfail, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, disabling, struct bfa_ioc, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, disabled, struct bfa_ioc, enum ioc_event);
+
+static struct bfa_sm_table ioc_sm_table[] = {
+	{BFA_SM(bfa_ioc_sm_reset), BFA_IOC_RESET},
+	{BFA_SM(bfa_ioc_sm_fwcheck), BFA_IOC_FWMISMATCH},
+	{BFA_SM(bfa_ioc_sm_mismatch), BFA_IOC_FWMISMATCH},
+	{BFA_SM(bfa_ioc_sm_semwait), BFA_IOC_SEMWAIT},
+	{BFA_SM(bfa_ioc_sm_hwinit), BFA_IOC_HWINIT},
+	{BFA_SM(bfa_ioc_sm_enabling), BFA_IOC_HWINIT},
+	{BFA_SM(bfa_ioc_sm_getattr), BFA_IOC_GETATTR},
+	{BFA_SM(bfa_ioc_sm_op), BFA_IOC_OPERATIONAL},
+	{BFA_SM(bfa_ioc_sm_initfail), BFA_IOC_INITFAIL},
+	{BFA_SM(bfa_ioc_sm_hbfail), BFA_IOC_HBFAIL},
+	{BFA_SM(bfa_ioc_sm_disabling), BFA_IOC_DISABLING},
+	{BFA_SM(bfa_ioc_sm_disabled), BFA_IOC_DISABLED},
+};
+
+/**
+ * Reset entry actions -- initialize state machine
+ */
+static void
+bfa_ioc_sm_reset_entry(struct bfa_ioc *ioc)
+{
+	ioc->retry_count = 0;
+	ioc->auto_recover = bfa_auto_recover;
+}
+
+/**
+ * Beginning state. IOC is in reset state.
+ */
+static void
+bfa_ioc_sm_reset(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_ENABLE:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fwcheck);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_disable_comp(ioc);
+		break;
+
+	case IOC_E_DETACH:
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * Semaphore should be acquired for version check.
+ */
+static void
+bfa_ioc_sm_fwcheck_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_hw_sem_get(ioc);
+}
+
+/**
+ * Awaiting h/w semaphore to continue with version check.
+ */
+static void
+bfa_ioc_sm_fwcheck(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_SEMLOCKED:
+		if (bfa_ioc_firmware_lock(ioc)) {
+			ioc->retry_count = 0;
+			bfa_fsm_set_state(ioc, bfa_ioc_sm_hwinit);
+		} else {
+			bfa_ioc_hw_sem_release(ioc);
+			bfa_fsm_set_state(ioc, bfa_ioc_sm_mismatch);
+		}
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_disable_comp(ioc);
+		/* fall through */
+
+	case IOC_E_DETACH:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		break;
+
+	case IOC_E_FWREADY:
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * Notify enable completion callback and generate mismatch AEN.
+ */
+static void
+bfa_ioc_sm_mismatch_entry(struct bfa_ioc *ioc)
+{
+	/**
+	 * Provide enable completion callback and AEN notification only once.
+	 */
+	if (ioc->retry_count == 0)
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+	ioc->retry_count++;
+	bfa_ioc_timer_start(ioc);
+}
+
+/**
+ * Awaiting firmware version match.
+ */
+static void
+bfa_ioc_sm_mismatch(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_TIMEOUT:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fwcheck);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_disable_comp(ioc);
+		/* fall through */
+
+	case IOC_E_DETACH:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		break;
+
+	case IOC_E_FWREADY:
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
+bfa_ioc_sm_semwait_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_hw_sem_get(ioc);
+}
+
+/**
+ * Awaiting semaphore for h/w initialzation.
+ */
+static void
+bfa_ioc_sm_semwait(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_SEMLOCKED:
+		ioc->retry_count = 0;
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_hwinit);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_hw_sem_get_cancel(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_hwinit_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_reset(ioc, false);
+}
+
+/**
+ * @brief
+ * Hardware is being initialized. Interrupts are enabled.
+ * Holding hardware semaphore lock.
+ */
+static void
+bfa_ioc_sm_hwinit(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_FWREADY:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_enabling);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/* fall through */
+
+	case IOC_E_TIMEOUT:
+		ioc->retry_count++;
+		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
+			bfa_ioc_timer_start(ioc);
+			bfa_ioc_reset(ioc, true);
+			break;
+		}
+
+		bfa_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_initfail);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_hw_sem_release(ioc);
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_enabling_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_send_enable(ioc);
+}
+
+/**
+ * Host IOC function is being enabled, awaiting response from firmware.
+ * Semaphore is acquired.
+ */
+static void
+bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_FWRSP_ENABLE:
+		bfa_ioc_timer_stop(ioc);
+		bfa_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/* fall through */
+
+	case IOC_E_TIMEOUT:
+		ioc->retry_count++;
+		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
+			writel(BFI_IOC_UNINIT,
+				      ioc->ioc_regs.ioc_fwstate);
+			bfa_fsm_set_state(ioc, bfa_ioc_sm_hwinit);
+			break;
+		}
+
+		bfa_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_initfail);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_timer_stop(ioc);
+		bfa_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	case IOC_E_FWREADY:
+		bfa_ioc_send_enable(ioc);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_getattr_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_send_getattr(ioc);
+}
+
+/**
+ * @brief
+ * IOC configuration in progress. Timer is active.
+ */
+static void
+bfa_ioc_sm_getattr(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_FWRSP_GETATTR:
+		bfa_ioc_timer_stop(ioc);
+		bfa_ioc_check_attr_wwns(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/* fall through */
+
+	case IOC_E_TIMEOUT:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_initfail);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
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
+		break;
+
+	case IOC_E_HWERROR:
+	case IOC_E_FWREADY:
+		/**
+		 * Hard error or IOC recovery by other function.
+		 * Treat it same as heartbeat failure.
+		 */
+		bfa_ioc_hb_stop(ioc);
+		/* !!! fall through !!! */
+
+	case IOC_E_HBFAIL:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_hbfail);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_disabling_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_send_disable(ioc);
+}
+
+/**
+ * IOC is being disabled
+ */
+static void
+bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_FWRSP_DISABLE:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/*
+		 * !!! fall through !!!
+		 */
+
+	case IOC_E_TIMEOUT:
+		writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * IOC disable completion entry.
+ */
+static void
+bfa_ioc_sm_disabled_entry(struct bfa_ioc *ioc)
+{
+	bfa_ioc_disable_comp(ioc);
+}
+
+static void
+bfa_ioc_sm_disabled(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_ENABLE:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_semwait);
+		break;
+
+	case IOC_E_DISABLE:
+		ioc->cbfn->disable_cbfn(ioc->bfa);
+		break;
+
+	case IOC_E_FWREADY:
+		break;
+
+	case IOC_E_DETACH:
+		bfa_ioc_firmware_unlock(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_initfail_entry(struct bfa_ioc *ioc)
+{
+	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+	bfa_ioc_timer_start(ioc);
+}
+
+/**
+ * @brief
+ * Hardware initialization failed.
+ */
+static void
+bfa_ioc_sm_initfail(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+	case IOC_E_DISABLE:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	case IOC_E_DETACH:
+		bfa_ioc_timer_stop(ioc);
+		bfa_ioc_firmware_unlock(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+		break;
+
+	case IOC_E_TIMEOUT:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_semwait);
+		break;
+
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+static void
+bfa_ioc_sm_hbfail_entry(struct bfa_ioc *ioc)
+{
+	struct list_head			*qe;
+	struct bfa_ioc_hbfail_notify *notify;
+
+	/**
+	 * Mark IOC as failed in hardware and stop firmware.
+	 */
+	bfa_ioc_lpu_stop(ioc);
+	writel(BFI_IOC_FAIL, ioc->ioc_regs.ioc_fwstate);
+
+	/**
+	 * Notify other functions on HB failure.
+	 */
+	bfa_ioc_notify_hbfail(ioc);
+
+	/**
+	 * Notify driver and common modules registered for notification.
+	 */
+	ioc->cbfn->hbfail_cbfn(ioc->bfa);
+	list_for_each(qe, &ioc->hb_notify_q) {
+		notify = (struct bfa_ioc_hbfail_notify *) qe;
+		notify->cbfn(notify->cbarg);
+	}
+
+	/**
+	 * Flush any queued up mailbox requests.
+	 */
+	bfa_ioc_mbox_hbfail(ioc);
+
+	/**
+	 * Trigger auto-recovery after a delay.
+	 */
+	if (ioc->auto_recover)
+		mod_timer(&ioc->ioc_timer, jiffies +
+			msecs_to_jiffies(BFA_IOC_TOV_RECOVER));
+}
+
+/**
+ * @brief
+ * IOC heartbeat failure.
+ */
+static void
+bfa_ioc_sm_hbfail(struct bfa_ioc *ioc, enum ioc_event event)
+{
+	switch (event) {
+
+	case IOC_E_ENABLE:
+		ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+		break;
+
+	case IOC_E_DISABLE:
+		if (ioc->auto_recover)
+			bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_disabled);
+		break;
+
+	case IOC_E_TIMEOUT:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_semwait);
+		break;
+
+	case IOC_E_FWREADY:
+		/**
+		 * Recovery is already initiated by other function.
+		 */
+		break;
+
+	case IOC_E_HWERROR:
+		/*
+		 * HB failure notification, ignore.
+		 */
+		break;
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+/**
+ * BFA IOC private functions
+ */
+
+static void
+bfa_ioc_disable_comp(struct bfa_ioc *ioc)
+{
+	struct list_head			*qe;
+	struct bfa_ioc_hbfail_notify *notify;
+
+	ioc->cbfn->disable_cbfn(ioc->bfa);
+
+	/**
+	 * Notify common modules registered for notification.
+	 */
+	list_for_each(qe, &ioc->hb_notify_q) {
+		notify = (struct bfa_ioc_hbfail_notify *) qe;
+		notify->cbfn(notify->cbarg);
+	}
+}
+
+void
+bfa_ioc_sem_timeout(void *ioc_arg)
+{
+	struct bfa_ioc *ioc = (struct bfa_ioc *) ioc_arg;
+
+	bfa_ioc_hw_sem_get(ioc);
+}
+
+bool
+bfa_ioc_sem_get(void __iomem *sem_reg)
+{
+	u32 r32;
+	int cnt = 0;
+#define BFA_SEM_SPINCNT	3000
+
+	r32 = readl(sem_reg);
+
+	while (r32 && (cnt < BFA_SEM_SPINCNT)) {
+		cnt++;
+		udelay(2);
+		r32 = readl(sem_reg);
+	}
+
+	if (r32 == 0)
+		return true;
+
+	BUG_ON(!(cnt < BFA_SEM_SPINCNT));
+	return false;
+}
+
+void
+bfa_ioc_sem_release(void __iomem *sem_reg)
+{
+	writel(1, sem_reg);
+}
+
+static void
+bfa_ioc_hw_sem_get(struct bfa_ioc *ioc)
+{
+	u32	r32;
+
+	/**
+	 * First read to the semaphore register will return 0, subsequent reads
+	 * will return 1. Semaphore is released by writing 1 to the register
+	 */
+	r32 = readl(ioc->ioc_regs.ioc_sem_reg);
+	if (r32 == 0) {
+		bfa_fsm_send_event(ioc, IOC_E_SEMLOCKED);
+		return;
+	}
+
+	mod_timer(&ioc->sem_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_HWSEM_TOV));
+}
+
+void
+bfa_ioc_hw_sem_release(struct bfa_ioc *ioc)
+{
+	writel(1, ioc->ioc_regs.ioc_sem_reg);
+}
+
+static void
+bfa_ioc_hw_sem_get_cancel(struct bfa_ioc *ioc)
+{
+	del_timer(&ioc->sem_timer);
+}
+
+/**
+ * @brief
+ * Initialize LPU local memory (aka secondary memory / SRAM)
+ */
+static void
+bfa_ioc_lmem_init(struct bfa_ioc *ioc)
+{
+	u32	pss_ctl;
+	int		i;
+#define PSS_LMEM_INIT_TIME  10000
+
+	pss_ctl = readl(ioc->ioc_regs.pss_ctl_reg);
+	pss_ctl &= ~__PSS_LMEM_RESET;
+	pss_ctl |= __PSS_LMEM_INIT_EN;
+
+	/*
+	 * i2c workaround 12.5khz clock
+	 */
+	pss_ctl |= __PSS_I2C_CLK_DIV(3UL);
+	writel(pss_ctl, ioc->ioc_regs.pss_ctl_reg);
+
+	/**
+	 * wait for memory initialization to be complete
+	 */
+	i = 0;
+	do {
+		pss_ctl = readl(ioc->ioc_regs.pss_ctl_reg);
+		i++;
+	} while (!(pss_ctl & __PSS_LMEM_INIT_DONE) && (i < PSS_LMEM_INIT_TIME));
+
+	/**
+	 * If memory initialization is not successful, IOC timeout will catch
+	 * such failures.
+	 */
+	BUG_ON(!(pss_ctl & __PSS_LMEM_INIT_DONE));
+
+	pss_ctl &= ~(__PSS_LMEM_INIT_DONE | __PSS_LMEM_INIT_EN);
+	writel(pss_ctl, ioc->ioc_regs.pss_ctl_reg);
+}
+
+static void
+bfa_ioc_lpu_start(struct bfa_ioc *ioc)
+{
+	u32	pss_ctl;
+
+	/**
+	 * Take processor out of reset.
+	 */
+	pss_ctl = readl(ioc->ioc_regs.pss_ctl_reg);
+	pss_ctl &= ~__PSS_LPU0_RESET;
+
+	writel(pss_ctl, ioc->ioc_regs.pss_ctl_reg);
+}
+
+static void
+bfa_ioc_lpu_stop(struct bfa_ioc *ioc)
+{
+	u32	pss_ctl;
+
+	/**
+	 * Put processors in reset.
+	 */
+	pss_ctl = readl(ioc->ioc_regs.pss_ctl_reg);
+	pss_ctl |= (__PSS_LPU0_RESET | __PSS_LPU1_RESET);
+
+	writel(pss_ctl, ioc->ioc_regs.pss_ctl_reg);
+}
+
+/**
+ * Get driver and firmware versions.
+ */
+void
+bfa_ioc_fwver_get(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
+{
+	u32	pgnum, pgoff;
+	u32	loff = 0;
+	int		i;
+	u32	*fwsig = (u32 *) fwhdr;
+
+	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
+	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+
+	for (i = 0; i < (sizeof(struct bfi_ioc_image_hdr) / sizeof(u32));
+	     i++) {
+		fwsig[i] =
+			swab32(readl((loff) + (ioc->ioc_regs.smem_page_start)));
+		loff += sizeof(u32);
+	}
+}
+
+/**
+ * Returns TRUE if same.
+ */
+bool
+bfa_ioc_fwver_cmp(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
+{
+	struct bfi_ioc_image_hdr *drv_fwhdr;
+	int i;
+
+	drv_fwhdr = (struct bfi_ioc_image_hdr *)
+		bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), 0);
+
+	for (i = 0; i < BFI_IOC_MD5SUM_SZ; i++) {
+		if (fwhdr->md5sum[i] != drv_fwhdr->md5sum[i])
+			return false;
+	}
+
+	return true;
+}
+
+/**
+ * Return true if current running version is valid. Firmware signature and
+ * execution context (driver/bios) must match.
+ */
+static bool
+bfa_ioc_fwver_valid(struct bfa_ioc *ioc)
+{
+	struct bfi_ioc_image_hdr fwhdr, *drv_fwhdr;
+
+	/**
+	 * If bios/efi boot (flash based) -- return true
+	 */
+	if (bfa_ioc_is_optrom(ioc))
+		return true;
+
+	bfa_ioc_fwver_get(ioc, &fwhdr);
+	drv_fwhdr = (struct bfi_ioc_image_hdr *)
+		bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), 0);
+
+	if (fwhdr.signature != drv_fwhdr->signature)
+		return false;
+
+	if (fwhdr.exec != drv_fwhdr->exec)
+		return false;
+
+	return bfa_ioc_fwver_cmp(ioc, &fwhdr);
+}
+
+/**
+ * Conditionally flush any pending message from firmware at start.
+ */
+static void
+bfa_ioc_msgflush(struct bfa_ioc *ioc)
+{
+	u32	r32;
+
+	r32 = readl(ioc->ioc_regs.lpu_mbox_cmd);
+	if (r32)
+		writel(1, ioc->ioc_regs.lpu_mbox_cmd);
+}
+
+/**
+ * @img ioc_init_logic.jpg
+ */
+static void
+bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
+{
+	enum bfi_ioc_state ioc_fwstate;
+	bool fwvalid;
+
+	ioc_fwstate = readl(ioc->ioc_regs.ioc_fwstate);
+
+	if (force)
+		ioc_fwstate = BFI_IOC_UNINIT;
+
+	/**
+	 * check if firmware is valid
+	 */
+	fwvalid = (ioc_fwstate == BFI_IOC_UNINIT) ?
+		false : bfa_ioc_fwver_valid(ioc);
+
+	if (!fwvalid) {
+		bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, ioc->pcidev.device_id);
+		return;
+	}
+
+	/**
+	 * If hardware initialization is in progress (initialized by other IOC),
+	 * just wait for an initialization completion interrupt.
+	 */
+	if (ioc_fwstate == BFI_IOC_INITING) {
+		ioc->cbfn->reset_cbfn(ioc->bfa);
+		return;
+	}
+
+	/**
+	 * If IOC function is disabled and firmware version is same,
+	 * just re-enable IOC.
+	 *
+	 * If option rom, IOC must not be in operational state. With
+	 * convergence, IOC will be in operational state when 2nd driver
+	 * is loaded.
+	 */
+	if (ioc_fwstate == BFI_IOC_DISABLED ||
+	    (!bfa_ioc_is_optrom(ioc) && ioc_fwstate == BFI_IOC_OP)) {
+		/**
+		 * When using MSI-X any pending firmware ready event should
+		 * be flushed. Otherwise MSI-X interrupts are not delivered.
+		 */
+		bfa_ioc_msgflush(ioc);
+		ioc->cbfn->reset_cbfn(ioc->bfa);
+		bfa_fsm_send_event(ioc, IOC_E_FWREADY);
+		return;
+	}
+
+	/**
+	 * Initialize the h/w for any other states.
+	 */
+	bfa_ioc_boot(ioc, BFI_BOOT_TYPE_NORMAL, ioc->pcidev.device_id);
+}
+
+void
+bfa_ioc_timeout(void *ioc_arg)
+{
+	struct bfa_ioc *ioc = (struct bfa_ioc *) ioc_arg;
+
+	bfa_fsm_send_event(ioc, IOC_E_TIMEOUT);
+}
+
+void
+bfa_ioc_mbox_send(struct bfa_ioc *ioc, void *ioc_msg, int len)
+{
+	u32 *msgp = (u32 *) ioc_msg;
+	u32 i;
+
+	BUG_ON(!(len <= BFI_IOC_MSGLEN_MAX));
+
+	/*
+	 * first write msg to mailbox registers
+	 */
+	for (i = 0; i < len / sizeof(u32); i++)
+		writel(cpu_to_le32(msgp[i]),
+			      ioc->ioc_regs.hfn_mbox + i * sizeof(u32));
+
+	for (; i < BFI_IOC_MSGLEN_MAX / sizeof(u32); i++)
+		writel(0, ioc->ioc_regs.hfn_mbox + i * sizeof(u32));
+
+	/*
+	 * write 1 to mailbox CMD to trigger LPU event
+	 */
+	writel(1, ioc->ioc_regs.hfn_mbox_cmd);
+	(void) readl(ioc->ioc_regs.hfn_mbox_cmd);
+}
+
+static void
+bfa_ioc_send_enable(struct bfa_ioc *ioc)
+{
+	struct bfi_ioc_ctrl_req enable_req;
+	struct timeval tv;
+
+	bfi_h2i_set(enable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_ENABLE_REQ,
+		    bfa_ioc_portid(ioc));
+	enable_req.ioc_class = ioc->ioc_mc;
+	do_gettimeofday(&tv);
+	enable_req.tv_sec = ntohl(tv.tv_sec);
+	bfa_ioc_mbox_send(ioc, &enable_req, sizeof(struct bfi_ioc_ctrl_req));
+}
+
+static void
+bfa_ioc_send_disable(struct bfa_ioc *ioc)
+{
+	struct bfi_ioc_ctrl_req disable_req;
+
+	bfi_h2i_set(disable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_DISABLE_REQ,
+		    bfa_ioc_portid(ioc));
+	bfa_ioc_mbox_send(ioc, &disable_req, sizeof(struct bfi_ioc_ctrl_req));
+}
+
+static void
+bfa_ioc_send_getattr(struct bfa_ioc *ioc)
+{
+	struct bfi_ioc_getattr_req attr_req;
+
+	bfi_h2i_set(attr_req.mh, BFI_MC_IOC, BFI_IOC_H2I_GETATTR_REQ,
+		    bfa_ioc_portid(ioc));
+	bfa_dma_be_addr_set(attr_req.attr_addr, ioc->attr_dma.pa);
+	bfa_ioc_mbox_send(ioc, &attr_req, sizeof(attr_req));
+}
+
+void
+bfa_ioc_hb_check(void *cbarg)
+{
+	struct bfa_ioc *ioc = cbarg;
+	u32	hb_count;
+
+	hb_count = readl(ioc->ioc_regs.heartbeat);
+	if (ioc->hb_count == hb_count) {
+		pr_crit("Firmware heartbeat failure at %d", hb_count);
+		bfa_ioc_recover(ioc);
+		return;
+	} else {
+		ioc->hb_count = hb_count;
+	}
+
+	bfa_ioc_mbox_poll(ioc);
+	mod_timer(&ioc->hb_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_HB_TOV));
+}
+
+static void
+bfa_ioc_hb_monitor(struct bfa_ioc *ioc)
+{
+	ioc->hb_count = readl(ioc->ioc_regs.heartbeat);
+	mod_timer(&ioc->hb_timer, jiffies +
+		msecs_to_jiffies(BFA_IOC_HB_TOV));
+}
+
+static void
+bfa_ioc_hb_stop(struct bfa_ioc *ioc)
+{
+	del_timer(&ioc->hb_timer);
+}
+
+/**
+ * @brief
+ *	Initiate a full firmware download.
+ */
+static void
+bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
+		    u32 boot_param)
+{
+	u32 *fwimg;
+	u32 pgnum, pgoff;
+	u32 loff = 0;
+	u32 chunkno = 0;
+	u32 i;
+
+	/**
+	 * Initialize LMEM first before code download
+	 */
+	bfa_ioc_lmem_init(ioc);
+
+	/**
+	 * Flash based firmware boot
+	 */
+	if (bfa_ioc_is_optrom(ioc))
+		boot_type = BFI_BOOT_TYPE_FLASH;
+	fwimg = bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc), chunkno);
+
+	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
+
+	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+
+	for (i = 0; i < bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(ioc)); i++) {
+		if (BFA_IOC_FLASH_CHUNK_NO(i) != chunkno) {
+			chunkno = BFA_IOC_FLASH_CHUNK_NO(i);
+			fwimg = bfa_cb_image_get_chunk(BFA_IOC_FWIMG_TYPE(ioc),
+					BFA_IOC_FLASH_CHUNK_ADDR(chunkno));
+		}
+
+		/**
+		 * write smem
+		 */
+		writel((swab32(fwimg[BFA_IOC_FLASH_OFFSET_IN_CHUNK(i)])),
+			      ((ioc->ioc_regs.smem_page_start) + (loff)));
+
+		loff += sizeof(u32);
+
+		/**
+		 * handle page offset wrap around
+		 */
+		loff = PSS_SMEM_PGOFF(loff);
+		if (loff == 0) {
+			pgnum++;
+			writel(pgnum,
+				      ioc->ioc_regs.host_page_num_fn);
+		}
+	}
+
+	writel(bfa_ioc_smem_pgnum(ioc, 0),
+		      ioc->ioc_regs.host_page_num_fn);
+
+	/*
+	 * Set boot type and boot param at the end.
+	*/
+	writel((swab32(swab32(boot_type))), ((ioc->ioc_regs.smem_page_start)
+			+ (BFI_BOOT_TYPE_OFF)));
+	writel((swab32(swab32(boot_param))), ((ioc->ioc_regs.smem_page_start)
+			+ (BFI_BOOT_PARAM_OFF)));
+}
+
+static void
+bfa_ioc_reset(struct bfa_ioc *ioc, bool force)
+{
+	bfa_ioc_hwinit(ioc, force);
+}
+
+/**
+ * @brief
+ * Update BFA configuration from firmware configuration.
+ */
+static void
+bfa_ioc_getattr_reply(struct bfa_ioc *ioc)
+{
+	struct bfi_ioc_attr *attr = ioc->attr;
+
+	attr->adapter_prop  = ntohl(attr->adapter_prop);
+	attr->card_type     = ntohl(attr->card_type);
+	attr->maxfrsize	    = ntohs(attr->maxfrsize);
+
+	bfa_fsm_send_event(ioc, IOC_E_FWRSP_GETATTR);
+}
+
+/**
+ * Attach time initialization of mbox logic.
+ */
+static void
+bfa_ioc_mbox_attach(struct bfa_ioc *ioc)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+	int	mc;
+
+	INIT_LIST_HEAD(&mod->cmd_q);
+	for (mc = 0; mc < BFI_MC_MAX; mc++) {
+		mod->mbhdlr[mc].cbfn = NULL;
+		mod->mbhdlr[mc].cbarg = ioc->bfa;
+	}
+}
+
+/**
+ * Mbox poll timer -- restarts any pending mailbox requests.
+ */
+static void
+bfa_ioc_mbox_poll(struct bfa_ioc *ioc)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+	struct bfa_mbox_cmd *cmd;
+	u32			stat;
+
+	/**
+	 * If no command pending, do nothing
+	 */
+	if (list_empty(&mod->cmd_q))
+		return;
+
+	/**
+	 * If previous command is not yet fetched by firmware, do nothing
+	 */
+	stat = readl(ioc->ioc_regs.hfn_mbox_cmd);
+	if (stat)
+		return;
+
+	/**
+	 * Enqueue command to firmware.
+	 */
+	bfa_q_deq(&mod->cmd_q, &cmd);
+	bfa_ioc_mbox_send(ioc, cmd->msg, sizeof(cmd->msg));
+}
+
+/**
+ * Cleanup any pending requests.
+ */
+static void
+bfa_ioc_mbox_hbfail(struct bfa_ioc *ioc)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+	struct bfa_mbox_cmd *cmd;
+
+	while (!list_empty(&mod->cmd_q))
+		bfa_q_deq(&mod->cmd_q, &cmd);
+}
+
+/**
+ * IOC public
+ */
+enum bfa_status
+bfa_ioc_pll_init(struct bfa_ioc *ioc)
+{
+	/*
+	 *  Hold semaphore so that nobody can access the chip during init.
+	 */
+	bfa_ioc_sem_get(ioc->ioc_regs.ioc_init_sem_reg);
+
+	bfa_ioc_pll_init_asic(ioc);
+
+	ioc->pllinit = true;
+	/*
+	 *  release semaphore.
+	 */
+	bfa_ioc_sem_release(ioc->ioc_regs.ioc_init_sem_reg);
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * Interface used by diag module to do firmware boot with memory test
+ * as the entry vector.
+ */
+void
+bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type, u32 boot_param)
+{
+	void __iomem *rb;
+
+	bfa_ioc_stats(ioc, ioc_boots);
+
+	if (bfa_ioc_pll_init(ioc) != BFA_STATUS_OK)
+		return;
+
+	/**
+	 * Initialize IOC state of all functions on a chip reset.
+	 */
+	rb = ioc->pcidev.pci_bar_kva;
+	if (boot_param == BFI_BOOT_TYPE_MEMTEST) {
+		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC0_STATE_REG));
+		writel(BFI_IOC_MEMTEST, (rb + BFA_IOC1_STATE_REG));
+	} else {
+		writel(BFI_IOC_INITING, (rb + BFA_IOC0_STATE_REG));
+		writel(BFI_IOC_INITING, (rb + BFA_IOC1_STATE_REG));
+	}
+
+	bfa_ioc_msgflush(ioc);
+	bfa_ioc_download_fw(ioc, boot_type, boot_param);
+
+	/**
+	 * Enable interrupts just before starting LPU
+	 */
+	ioc->cbfn->reset_cbfn(ioc->bfa);
+	bfa_ioc_lpu_start(ioc);
+}
+
+/**
+ * Enable/disable IOC failure auto recovery.
+ */
+void
+bfa_ioc_auto_recover(bool auto_recover)
+{
+	bfa_auto_recover = auto_recover;
+}
+
+bool
+bfa_ioc_is_operational(struct bfa_ioc *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_op);
+}
+
+bool
+bfa_ioc_is_initialized(struct bfa_ioc *ioc)
+{
+	u32 r32 = readl(ioc->ioc_regs.ioc_fwstate);
+
+	return ((r32 != BFI_IOC_UNINIT) &&
+		(r32 != BFI_IOC_INITING) &&
+		(r32 != BFI_IOC_MEMTEST));
+}
+
+void
+bfa_ioc_msgget(struct bfa_ioc *ioc, void *mbmsg)
+{
+	u32	*msgp = mbmsg;
+	u32	r32;
+	int		i;
+
+	/**
+	 * read the MBOX msg
+	 */
+	for (i = 0; i < (sizeof(union bfi_ioc_i2h_msg_u) / sizeof(u32));
+	     i++) {
+		r32 = readl(ioc->ioc_regs.lpu_mbox +
+				   i * sizeof(u32));
+		msgp[i] = htonl(r32);
+	}
+
+	/**
+	 * turn off mailbox interrupt by clearing mailbox status
+	 */
+	writel(1, ioc->ioc_regs.lpu_mbox_cmd);
+	readl(ioc->ioc_regs.lpu_mbox_cmd);
+}
+
+void
+bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
+{
+	union bfi_ioc_i2h_msg_u	*msg;
+
+	msg = (union bfi_ioc_i2h_msg_u *) m;
+
+	bfa_ioc_stats(ioc, ioc_isrs);
+
+	switch (msg->mh.msg_id) {
+	case BFI_IOC_I2H_HBEAT:
+		break;
+
+	case BFI_IOC_I2H_READY_EVENT:
+		bfa_fsm_send_event(ioc, IOC_E_FWREADY);
+		break;
+
+	case BFI_IOC_I2H_ENABLE_REPLY:
+		bfa_fsm_send_event(ioc, IOC_E_FWRSP_ENABLE);
+		break;
+
+	case BFI_IOC_I2H_DISABLE_REPLY:
+		bfa_fsm_send_event(ioc, IOC_E_FWRSP_DISABLE);
+		break;
+
+	case BFI_IOC_I2H_GETATTR_REPLY:
+		bfa_ioc_getattr_reply(ioc);
+		break;
+
+	default:
+		BUG_ON(1);
+	}
+}
+
+/**
+ * IOC attach time initialization and setup.
+ *
+ * @param[in]	ioc	memory for IOC
+ * @param[in]	bfa	driver instance structure
+ */
+void
+bfa_ioc_attach(struct bfa_ioc *ioc, void *bfa, struct bfa_ioc_cbfn *cbfn)
+{
+	ioc->bfa	= bfa;
+	ioc->cbfn	= cbfn;
+	ioc->fcmode	= false;
+	ioc->pllinit	= false;
+	ioc->dbg_fwsave_once = true;
+
+	bfa_ioc_mbox_attach(ioc);
+	INIT_LIST_HEAD(&ioc->hb_notify_q);
+
+	bfa_fsm_set_state(ioc, bfa_ioc_sm_reset);
+}
+
+/**
+ * Driver detach time IOC cleanup.
+ */
+void
+bfa_ioc_detach(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_DETACH);
+}
+
+/**
+ * Setup IOC PCI properties.
+ *
+ * @param[in]	pcidev	PCI device information for this IOC
+ */
+void
+bfa_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
+		 enum bfi_mclass mc)
+{
+	ioc->ioc_mc	= mc;
+	ioc->pcidev	= *pcidev;
+	ioc->ctdev	= bfa_asic_id_ct(ioc->pcidev.device_id);
+	ioc->cna	= ioc->ctdev && !ioc->fcmode;
+
+	bfa_ioc_set_ct_hwif(ioc);
+
+	bfa_ioc_map_port(ioc);
+	bfa_ioc_reg_init(ioc);
+}
+
+/**
+ * Initialize IOC dma memory
+ *
+ * @param[in]	dm_kva	kernel virtual address of IOC dma memory
+ * @param[in]	dm_pa	physical address of IOC dma memory
+ */
+void
+bfa_ioc_mem_claim(struct bfa_ioc *ioc,  u8 *dm_kva, u64 dm_pa)
+{
+	/**
+	 * dma memory for firmware attribute
+	 */
+	ioc->attr_dma.kva = dm_kva;
+	ioc->attr_dma.pa = dm_pa;
+	ioc->attr = (struct bfi_ioc_attr *) dm_kva;
+}
+
+/**
+ * Return size of dma memory required.
+ */
+u32
+bfa_ioc_meminfo(void)
+{
+	return roundup(sizeof(struct bfi_ioc_attr), BFA_DMA_ALIGN_SZ);
+}
+
+void
+bfa_ioc_enable(struct bfa_ioc *ioc)
+{
+	bfa_ioc_stats(ioc, ioc_enables);
+	ioc->dbg_fwsave_once = true;
+
+	bfa_fsm_send_event(ioc, IOC_E_ENABLE);
+}
+
+void
+bfa_ioc_disable(struct bfa_ioc *ioc)
+{
+	bfa_ioc_stats(ioc, ioc_disables);
+	bfa_fsm_send_event(ioc, IOC_E_DISABLE);
+}
+
+u32
+bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr)
+{
+	return PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, fmaddr);
+}
+
+u32
+bfa_ioc_smem_pgoff(struct bfa_ioc *ioc, u32 fmaddr)
+{
+	return PSS_SMEM_PGOFF(fmaddr);
+}
+
+/**
+ * Register mailbox message handler functions
+ *
+ * @param[in]	ioc		IOC instance
+ * @param[in]	mcfuncs		message class handler functions
+ */
+void
+bfa_ioc_mbox_register(struct bfa_ioc *ioc, bfa_ioc_mbox_mcfunc_t *mcfuncs)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+	int				mc;
+
+	for (mc = 0; mc < BFI_MC_MAX; mc++)
+		mod->mbhdlr[mc].cbfn = mcfuncs[mc];
+}
+
+/**
+ * Register mailbox message handler function, to be called by common modules
+ */
+void
+bfa_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
+		    bfa_ioc_mbox_mcfunc_t cbfn, void *cbarg)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+
+	mod->mbhdlr[mc].cbfn	= cbfn;
+	mod->mbhdlr[mc].cbarg = cbarg;
+}
+
+/**
+ * Queue a mailbox command request to firmware. Waits if mailbox is busy.
+ * Responsibility of caller to serialize
+ *
+ * @param[in]	ioc	IOC instance
+ * @param[i]	cmd	Mailbox command
+ */
+void
+bfa_ioc_mbox_queue(struct bfa_ioc *ioc, struct bfa_mbox_cmd *cmd)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+	u32			stat;
+
+	/**
+	 * If a previous command is pending, queue new command
+	 */
+	if (!list_empty(&mod->cmd_q)) {
+		list_add_tail(&cmd->qe, &mod->cmd_q);
+		return;
+	}
+
+	/**
+	 * If mailbox is busy, queue command for poll timer
+	 */
+	stat = readl(ioc->ioc_regs.hfn_mbox_cmd);
+	if (stat) {
+		list_add_tail(&cmd->qe, &mod->cmd_q);
+		return;
+	}
+
+	/**
+	 * mailbox is free -- queue command to firmware
+	 */
+	bfa_ioc_mbox_send(ioc, cmd->msg, sizeof(cmd->msg));
+}
+
+/**
+ * Handle mailbox interrupts
+ */
+void
+bfa_ioc_mbox_isr(struct bfa_ioc *ioc)
+{
+	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
+	struct bfi_mbmsg m;
+	int				mc;
+
+	bfa_ioc_msgget(ioc, &m);
+
+	/**
+	 * Treat IOC message class as special.
+	 */
+	mc = m.mh.msg_class;
+	if (mc == BFI_MC_IOC) {
+		bfa_ioc_isr(ioc, &m);
+		return;
+	}
+
+	if ((mc > BFI_MC_MAX) || (mod->mbhdlr[mc].cbfn == NULL))
+		return;
+
+	mod->mbhdlr[mc].cbfn(mod->mbhdlr[mc].cbarg, &m);
+}
+
+void
+bfa_ioc_error_isr(struct bfa_ioc *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_HWERROR);
+}
+
+void
+bfa_ioc_set_fcmode(struct bfa_ioc *ioc)
+{
+	ioc->fcmode  = true;
+	ioc->port_id = bfa_ioc_pcifn(ioc);
+}
+
+/**
+ * return true if IOC is disabled
+ */
+bool
+bfa_ioc_is_disabled(struct bfa_ioc *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabling) ||
+		bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabled);
+}
+
+/**
+ * return true if IOC firmware is different.
+ */
+bool
+bfa_ioc_fw_mismatch(struct bfa_ioc *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_reset) ||
+		bfa_fsm_cmp_state(ioc, bfa_ioc_sm_fwcheck) ||
+		bfa_fsm_cmp_state(ioc, bfa_ioc_sm_mismatch);
+}
+
+#define bfa_ioc_state_disabled(__sm)		\
+	(((__sm) == BFI_IOC_UNINIT) ||		\
+	 ((__sm) == BFI_IOC_INITING) ||		\
+	 ((__sm) == BFI_IOC_HWINIT) ||		\
+	 ((__sm) == BFI_IOC_DISABLED) ||	\
+	 ((__sm) == BFI_IOC_FAIL) ||		\
+	 ((__sm) == BFI_IOC_CFG_DISABLED))
+
+/**
+ * Check if adapter is disabled -- both IOCs should be in a disabled
+ * state.
+ */
+bool
+bfa_ioc_adapter_is_disabled(struct bfa_ioc *ioc)
+{
+	u32	ioc_state;
+	void __iomem *rb = ioc->pcidev.pci_bar_kva;
+
+	if (!bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabled))
+		return false;
+
+	ioc_state = readl(rb + BFA_IOC0_STATE_REG);
+	if (!bfa_ioc_state_disabled(ioc_state))
+		return false;
+
+	if (ioc->pcidev.device_id != PCI_DEVICE_ID_BROCADE_FC_8G1P) {
+		ioc_state = readl(rb + BFA_IOC1_STATE_REG);
+		if (!bfa_ioc_state_disabled(ioc_state))
+			return false;
+	}
+
+	return true;
+}
+
+/**
+ * Add to IOC heartbeat failure notification queue. To be used by common
+ * modules such as cee, port, diag.
+ */
+void
+bfa_ioc_hbfail_register(struct bfa_ioc *ioc,
+			struct bfa_ioc_hbfail_notify *notify)
+{
+	list_add_tail(&notify->qe, &ioc->hb_notify_q);
+}
+
+#define BFA_MFG_NAME "Brocade"
+void
+bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
+			 struct bfa_adapter_attr *ad_attr)
+{
+	struct bfi_ioc_attr *ioc_attr;
+
+	ioc_attr = ioc->attr;
+
+	bfa_ioc_get_adapter_serial_num(ioc, ad_attr->serial_num);
+	bfa_ioc_get_adapter_fw_ver(ioc, ad_attr->fw_ver);
+	bfa_ioc_get_adapter_optrom_ver(ioc, ad_attr->optrom_ver);
+	bfa_ioc_get_adapter_manufacturer(ioc, ad_attr->manufacturer);
+	memcpy(&ad_attr->vpd, &ioc_attr->vpd,
+		      sizeof(struct bfa_mfg_vpd));
+
+	ad_attr->nports = bfa_ioc_get_nports(ioc);
+	ad_attr->max_speed = bfa_ioc_speed_sup(ioc);
+
+	bfa_ioc_get_adapter_model(ioc, ad_attr->model);
+	/* For now, model descr uses same model string */
+	bfa_ioc_get_adapter_model(ioc, ad_attr->model_descr);
+
+	ad_attr->card_type = ioc_attr->card_type;
+	ad_attr->is_mezz = bfa_mfg_is_mezz(ioc_attr->card_type);
+
+	if (BFI_ADAPTER_IS_SPECIAL(ioc_attr->adapter_prop))
+		ad_attr->prototype = 1;
+	else
+		ad_attr->prototype = 0;
+
+	ad_attr->pwwn = bfa_ioc_get_pwwn(ioc);
+	ad_attr->mac  = bfa_ioc_get_mac(ioc);
+
+	ad_attr->pcie_gen = ioc_attr->pcie_gen;
+	ad_attr->pcie_lanes = ioc_attr->pcie_lanes;
+	ad_attr->pcie_lanes_orig = ioc_attr->pcie_lanes_orig;
+	ad_attr->asic_rev = ioc_attr->asic_rev;
+
+	bfa_ioc_get_pci_chip_rev(ioc, ad_attr->hw_ver);
+
+	ad_attr->cna_capable = ioc->cna;
+	ad_attr->trunk_capable = (ad_attr->nports > 1) && !ioc->cna;
+}
+
+enum bfa_ioc_type
+bfa_ioc_get_type(struct bfa_ioc *ioc)
+{
+	if (!ioc->ctdev || ioc->fcmode)
+		return BFA_IOC_TYPE_FC;
+	else if (ioc->ioc_mc == BFI_MC_IOCFC)
+		return BFA_IOC_TYPE_FCoE;
+	else if (ioc->ioc_mc == BFI_MC_LL)
+		return BFA_IOC_TYPE_LL;
+	else {
+		BUG_ON(!(ioc->ioc_mc == BFI_MC_LL));
+		return BFA_IOC_TYPE_LL;
+	}
+}
+
+void
+bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num)
+{
+	memset(serial_num, 0, BFA_ADAPTER_SERIAL_NUM_LEN);
+	memcpy(serial_num,
+			(void *)ioc->attr->brcd_serialnum,
+			BFA_ADAPTER_SERIAL_NUM_LEN);
+}
+
+void
+bfa_ioc_get_adapter_fw_ver(struct bfa_ioc *ioc, char *fw_ver)
+{
+	memset(fw_ver, 0, BFA_VERSION_LEN);
+	memcpy(fw_ver, ioc->attr->fw_version, BFA_VERSION_LEN);
+}
+
+void
+bfa_ioc_get_pci_chip_rev(struct bfa_ioc *ioc, char *chip_rev)
+{
+	BUG_ON(!(chip_rev));
+
+	memset(chip_rev, 0, BFA_IOC_CHIP_REV_LEN);
+
+	chip_rev[0] = 'R';
+	chip_rev[1] = 'e';
+	chip_rev[2] = 'v';
+	chip_rev[3] = '-';
+	chip_rev[4] = ioc->attr->asic_rev;
+	chip_rev[5] = '\0';
+}
+
+void
+bfa_ioc_get_adapter_optrom_ver(struct bfa_ioc *ioc, char *optrom_ver)
+{
+	memset(optrom_ver, 0, BFA_VERSION_LEN);
+	memcpy(optrom_ver, ioc->attr->optrom_version,
+		      BFA_VERSION_LEN);
+}
+
+void
+bfa_ioc_get_adapter_manufacturer(struct bfa_ioc *ioc, char *manufacturer)
+{
+	memset(manufacturer, 0, BFA_ADAPTER_MFG_NAME_LEN);
+	memcpy(manufacturer, BFA_MFG_NAME, BFA_ADAPTER_MFG_NAME_LEN);
+}
+
+void
+bfa_ioc_get_adapter_model(struct bfa_ioc *ioc, char *model)
+{
+	struct bfi_ioc_attr *ioc_attr;
+
+	BUG_ON(!(model));
+	memset(model, 0, BFA_ADAPTER_MODEL_NAME_LEN);
+
+	ioc_attr = ioc->attr;
+
+	/**
+	 * model name
+	 */
+	snprintf(model, BFA_ADAPTER_MODEL_NAME_LEN, "%s-%u",
+		BFA_MFG_NAME, ioc_attr->card_type);
+}
+
+enum bfa_ioc_state
+bfa_ioc_get_state(struct bfa_ioc *ioc)
+{
+	return bfa_sm_to_state(ioc_sm_table, ioc->fsm);
+}
+
+void
+bfa_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr)
+{
+	memset((void *)ioc_attr, 0, sizeof(struct bfa_ioc_attr));
+
+	ioc_attr->state = bfa_ioc_get_state(ioc);
+	ioc_attr->port_id = ioc->port_id;
+
+	ioc_attr->ioc_type = bfa_ioc_get_type(ioc);
+
+	bfa_ioc_get_adapter_attr(ioc, &ioc_attr->adapter_attr);
+
+	ioc_attr->pci_attr.device_id = ioc->pcidev.device_id;
+	ioc_attr->pci_attr.pcifn = ioc->pcidev.pci_func;
+	bfa_ioc_get_pci_chip_rev(ioc, ioc_attr->pci_attr.chip_rev);
+}
+
+/**
+ * WWN public
+ */
+u64
+bfa_ioc_get_pwwn(struct bfa_ioc *ioc)
+{
+	return ioc->attr->pwwn;
+}
+
+u64
+bfa_ioc_get_nwwn(struct bfa_ioc *ioc)
+{
+	return ioc->attr->nwwn;
+}
+
+u64
+bfa_ioc_get_adid(struct bfa_ioc *ioc)
+{
+	return ioc->attr->mfg_pwwn;
+}
+
+mac_t
+bfa_ioc_get_mac(struct bfa_ioc *ioc)
+{
+	/*
+	 * Currently mfg mac is used as FCoE enode mac (not configured by PBC)
+	 */
+	if (bfa_ioc_get_type(ioc) == BFA_IOC_TYPE_FCoE)
+		return bfa_ioc_get_mfg_mac(ioc);
+	else
+		return ioc->attr->mac;
+}
+
+u64
+bfa_ioc_get_mfg_pwwn(struct bfa_ioc *ioc)
+{
+	return ioc->attr->mfg_pwwn;
+}
+
+u64
+bfa_ioc_get_mfg_nwwn(struct bfa_ioc *ioc)
+{
+	return ioc->attr->mfg_nwwn;
+}
+
+mac_t
+bfa_ioc_get_mfg_mac(struct bfa_ioc *ioc)
+{
+	mac_t	m;
+
+	m = ioc->attr->mfg_mac;
+	if (bfa_mfg_is_old_wwn_mac_model(ioc->attr->card_type))
+		m.mac[MAC_ADDRLEN - 1] += bfa_ioc_pcifn(ioc);
+	else
+		bfa_mfg_increment_wwn_mac(&(m.mac[MAC_ADDRLEN-3]),
+			bfa_ioc_pcifn(ioc));
+
+	return m;
+}
+
+bool
+bfa_ioc_get_fcmode(struct bfa_ioc *ioc)
+{
+	return ioc->fcmode || !bfa_asic_id_ct(ioc->pcidev.device_id);
+}
+
+/**
+ * Firmware failure detected. Start recovery actions.
+ */
+static void
+bfa_ioc_recover(struct bfa_ioc *ioc)
+{
+	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
+}
+
+static void
+bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc)
+{
+	if (bfa_ioc_get_type(ioc) == BFA_IOC_TYPE_LL)
+		return;
+
+}
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bna.h net-next-2.6.35-rc1-mod/drivers/net/bna/bna.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bna.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bna.h	2010-08-02 17:19:19.840229000 -0700
@@ -0,0 +1,654 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#ifndef __BNA_H__
+#define __BNA_H__
+
+#include "bfa_wc.h"
+#include "bfa_ioc.h"
+#include "cna.h"
+#include "bfi_ll.h"
+#include "bna_types.h"
+
+extern u32 bna_dim_vector[][BNA_BIAS_T_MAX];
+extern u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
+
+/**
+ *
+ *  Macros and constants
+ *
+ */
+
+#define BNA_IOC_TIMER_FREQ		200
+
+/* Log string size */
+#define BNA_MESSAGE_SIZE		256
+
+#define bna_device_timer(_dev)		bfa_timer_beat(&((_dev)->timer_mod))
+
+/* MBOX API for PORT, TX, RX */
+#define bna_mbox_qe_fill(_qe, _cmd, _cmd_len, _cbfn, _cbarg)		\
+do {									\
+	memcpy(&((_qe)->cmd.msg[0]), (_cmd), (_cmd_len));	\
+	(_qe)->cbfn = (_cbfn);						\
+	(_qe)->cbarg = (_cbarg);					\
+} while (0)
+
+#define bna_is_small_rxq(rcb) ((rcb)->id == 1)
+
+#define BNA_MAC_IS_EQUAL(_mac1, _mac2)					\
+	(!memcmp((_mac1), (_mac2), sizeof(mac_t)))
+
+#define BNA_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
+
+#define BNA_TO_POWER_OF_2(x)						\
+do {									\
+	int _shift = 0;							\
+	while ((x) && (x) != 1) {					\
+		(x) >>= 1;						\
+		_shift++;						\
+	}								\
+	(x) <<= _shift;							\
+} while (0)
+
+#define BNA_TO_POWER_OF_2_HIGH(x)					\
+do {									\
+	int n = 1;							\
+	while (n < (x))							\
+		n <<= 1;						\
+	(x) = n;							\
+} while (0)
+
+/*
+ * input : _addr-> os dma addr in host endian format,
+ * output : _bna_dma_addr-> pointer to hw dma addr
+ */
+#define BNA_SET_DMA_ADDR(_addr, _bna_dma_addr)				\
+do {									\
+	u64 tmp_addr =						\
+	cpu_to_be64((u64)(_addr));				\
+	(_bna_dma_addr)->msb = ((struct bna_dma_addr *)&tmp_addr)->msb; \
+	(_bna_dma_addr)->lsb = ((struct bna_dma_addr *)&tmp_addr)->lsb; \
+} while (0)
+
+/*
+ * input : _bna_dma_addr-> pointer to hw dma addr
+ * output : _addr-> os dma addr in host endian format
+ */
+#define BNA_GET_DMA_ADDR(_bna_dma_addr, _addr)			\
+do {								\
+	(_addr) = ((((u64)ntohl((_bna_dma_addr)->msb))) << 32)		\
+	| ((ntohl((_bna_dma_addr)->lsb) & 0xffffffff));	\
+} while (0)
+
+#define	containing_rec(addr, type, field)				\
+	((type *)((unsigned char *)(addr) - 				\
+	(unsigned char *)(&((type *)0)->field)))
+
+#define BNA_TXQ_WI_NEEDED(_vectors)	(((_vectors) + 3) >> 2)
+
+/* TxQ element is 64 bytes */
+#define BNA_TXQ_PAGE_INDEX_MAX		(PAGE_SIZE >> 6)
+#define BNA_TXQ_PAGE_INDEX_MAX_SHIFT	(PAGE_SHIFT - 6)
+
+#define BNA_TXQ_QPGE_PTR_GET(_qe_idx, _qpt_ptr, _qe_ptr, _qe_ptr_range) \
+{									\
+	unsigned int page_index;	/* index within a page */	\
+	void *page_addr;						\
+	page_index = (_qe_idx) & (BNA_TXQ_PAGE_INDEX_MAX - 1); 		\
+	(_qe_ptr_range) = (BNA_TXQ_PAGE_INDEX_MAX - page_index); 	\
+	page_addr = (_qpt_ptr)[((_qe_idx) >>  BNA_TXQ_PAGE_INDEX_MAX_SHIFT)];\
+	(_qe_ptr) = &((struct bna_txq_entry *)(page_addr))[page_index]; \
+}
+
+/* RxQ element is 8 bytes */
+#define BNA_RXQ_PAGE_INDEX_MAX		(PAGE_SIZE >> 3)
+#define BNA_RXQ_PAGE_INDEX_MAX_SHIFT	(PAGE_SHIFT - 3)
+
+#define BNA_RXQ_QPGE_PTR_GET(_qe_idx, _qpt_ptr, _qe_ptr, _qe_ptr_range) \
+{									\
+	unsigned int page_index;	/* index within a page */	\
+	void *page_addr;						\
+	page_index = (_qe_idx) & (BNA_RXQ_PAGE_INDEX_MAX - 1);		\
+	(_qe_ptr_range) = (BNA_RXQ_PAGE_INDEX_MAX - page_index);	\
+	page_addr = (_qpt_ptr)[((_qe_idx) >>				\
+				BNA_RXQ_PAGE_INDEX_MAX_SHIFT)];		\
+	(_qe_ptr) = &((struct bna_rxq_entry *)(page_addr))[page_index]; \
+}
+
+/* CQ element is 16 bytes */
+#define BNA_CQ_PAGE_INDEX_MAX		(PAGE_SIZE >> 4)
+#define BNA_CQ_PAGE_INDEX_MAX_SHIFT	(PAGE_SHIFT - 4)
+
+#define BNA_CQ_QPGE_PTR_GET(_qe_idx, _qpt_ptr, _qe_ptr, _qe_ptr_range)	\
+{									\
+	unsigned int page_index;	  /* index within a page */	\
+	void *page_addr;						\
+									\
+	page_index = (_qe_idx) & (BNA_CQ_PAGE_INDEX_MAX - 1);		\
+	(_qe_ptr_range) = (BNA_CQ_PAGE_INDEX_MAX - page_index);		\
+	page_addr = (_qpt_ptr)[((_qe_idx) >>				\
+				    BNA_CQ_PAGE_INDEX_MAX_SHIFT)];	\
+	(_qe_ptr) = &((struct bna_cq_entry *)(page_addr))[page_index];\
+}
+
+#define BNA_QE_INDX_2_PTR(_cast, _qe_idx, _q_base)			\
+	(&((_cast *)(_q_base))[(_qe_idx)])
+
+#define BNA_QE_INDX_RANGE(_qe_idx, _q_depth) ((_q_depth) - (_qe_idx))
+
+#define BNA_QE_INDX_ADD(_qe_idx, _qe_num, _q_depth)			\
+	((_qe_idx) = ((_qe_idx) + (_qe_num)) & ((_q_depth) - 1))
+
+#define BNA_Q_INDEX_CHANGE(_old_idx, _updated_idx, _q_depth)		\
+	(((_updated_idx) - (_old_idx)) & ((_q_depth) - 1))
+
+#define BNA_QE_FREE_CNT(_q_ptr, _q_depth)				\
+	(((_q_ptr)->consumer_index - (_q_ptr)->producer_index - 1) &	\
+	 ((_q_depth) - 1))
+
+#define BNA_QE_IN_USE_CNT(_q_ptr, _q_depth)				\
+	((((_q_ptr)->producer_index - (_q_ptr)->consumer_index)) &	\
+	 (_q_depth - 1))
+
+#define BNA_Q_GET_CI(_q_ptr)		((_q_ptr)->q.consumer_index)
+
+#define BNA_Q_GET_PI(_q_ptr)		((_q_ptr)->q.producer_index)
+
+#define BNA_Q_PI_ADD(_q_ptr, _num)					\
+	(_q_ptr)->q.producer_index =					\
+		(((_q_ptr)->q.producer_index + (_num)) &		\
+		((_q_ptr)->q.q_depth - 1))
+
+#define BNA_Q_CI_ADD(_q_ptr, _num) 					\
+	(_q_ptr)->q.consumer_index =					\
+		(((_q_ptr)->q.consumer_index + (_num))  		\
+		& ((_q_ptr)->q.q_depth - 1))
+
+#define BNA_Q_FREE_COUNT(_q_ptr)					\
+	(BNA_QE_FREE_CNT(&((_q_ptr)->q), (_q_ptr)->q.q_depth))
+
+#define BNA_Q_IN_USE_COUNT(_q_ptr)  					\
+	(BNA_QE_IN_USE_CNT(&(_q_ptr)->q, (_q_ptr)->q.q_depth))
+
+/* These macros build the data portion of the TxQ/RxQ doorbell */
+#define BNA_DOORBELL_Q_PRD_IDX(_pi) 	(0x80000000 | (_pi))
+#define BNA_DOORBELL_Q_STOP		(0x40000000)
+
+/* These macros build the data portion of the IB doorbell */
+#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events) \
+	(0x80000000 | ((_timeout) << 16) | (_events))
+#define BNA_DOORBELL_IB_INT_DISABLE 	(0x40000000)
+
+/* Set the coalescing timer for the given ib */
+#define bna_ib_coalescing_timer_set(_i_dbell, _cls_timer)		\
+	((_i_dbell)->doorbell_ack = BNA_DOORBELL_IB_INT_ACK((_cls_timer), 0));
+
+/* Acks 'events' # of events for a given ib */
+#define bna_ib_ack(_i_dbell, _events)					\
+	(writel(((_i_dbell)->doorbell_ack | (_events)), \
+		(_i_dbell)->doorbell_addr));
+
+#define bna_txq_prod_indx_doorbell(_tcb)				\
+	(writel(BNA_DOORBELL_Q_PRD_IDX((_tcb)->producer_index), \
+		(_tcb)->q_dbell));
+
+#define bna_rxq_prod_indx_doorbell(_rcb)				\
+	(writel(BNA_DOORBELL_Q_PRD_IDX((_rcb)->producer_index), \
+		(_rcb)->q_dbell));
+
+#define BNA_LARGE_PKT_SIZE		1000
+
+#define BNA_UPDATE_PKT_CNT(_pkt, _len)					\
+do {									\
+	if ((_len) > BNA_LARGE_PKT_SIZE) {				\
+		(_pkt)->large_pkt_cnt++;				\
+	} else {							\
+		(_pkt)->small_pkt_cnt++;				\
+	}								\
+} while (0)
+
+#define	call_rxf_stop_cbfn(rxf, status)					\
+	if ((rxf)->stop_cbfn) {						\
+		(*(rxf)->stop_cbfn)((rxf)->stop_cbarg, (status));	\
+		(rxf)->stop_cbfn = NULL;				\
+		(rxf)->stop_cbarg = NULL;				\
+	}
+
+#define	call_rxf_start_cbfn(rxf, status)				\
+	if ((rxf)->start_cbfn) {					\
+		(*(rxf)->start_cbfn)((rxf)->start_cbarg, (status));	\
+		(rxf)->start_cbfn = NULL;				\
+		(rxf)->start_cbarg = NULL;				\
+	}
+
+#define	call_rxf_cam_fltr_cbfn(rxf, status)				\
+	if ((rxf)->cam_fltr_cbfn) {					\
+		(*(rxf)->cam_fltr_cbfn)((rxf)->cam_fltr_cbarg, rxf->rx,	\
+					(status));			\
+		(rxf)->cam_fltr_cbfn = NULL;				\
+		(rxf)->cam_fltr_cbarg = NULL;				\
+	}
+
+#define	call_rxf_pause_cbfn(rxf, status)				\
+	if ((rxf)->oper_state_cbfn) {					\
+		(*(rxf)->oper_state_cbfn)((rxf)->oper_state_cbarg, rxf->rx,\
+					(status));			\
+		(rxf)->rxf_flags &= ~BNA_RXF_FL_OPERSTATE_CHANGED;	\
+		(rxf)->oper_state_cbfn = NULL;				\
+		(rxf)->oper_state_cbarg = NULL;				\
+	}
+
+#define	call_rxf_resume_cbfn(rxf, status) call_rxf_pause_cbfn(rxf, status)
+
+#define is_xxx_enable(mode, bitmask, xxx) ((bitmask & xxx) && (mode & xxx))
+
+#define is_xxx_disable(mode, bitmask, xxx) ((bitmask & xxx) && !(mode & xxx))
+
+#define xxx_enable(mode, bitmask, xxx)					\
+do {									\
+	bitmask |= xxx;							\
+	mode |= xxx;							\
+} while (0)
+
+#define xxx_disable(mode, bitmask, xxx)					\
+do {									\
+	bitmask |= xxx;							\
+	mode &= ~xxx;							\
+} while (0)
+
+#define xxx_inactive(mode, bitmask, xxx)				\
+do {									\
+	bitmask &= ~xxx;						\
+	mode &= ~xxx;							\
+} while (0)
+
+#define is_promisc_enable(mode, bitmask)				\
+	is_xxx_enable(mode, bitmask, BNA_RXMODE_PROMISC)
+
+#define is_promisc_disable(mode, bitmask)				\
+	is_xxx_disable(mode, bitmask, BNA_RXMODE_PROMISC)
+
+#define promisc_enable(mode, bitmask)					\
+	xxx_enable(mode, bitmask, BNA_RXMODE_PROMISC)
+
+#define promisc_disable(mode, bitmask)					\
+	xxx_disable(mode, bitmask, BNA_RXMODE_PROMISC)
+
+#define promisc_inactive(mode, bitmask)					\
+	xxx_inactive(mode, bitmask, BNA_RXMODE_PROMISC)
+
+#define is_default_enable(mode, bitmask)				\
+	is_xxx_enable(mode, bitmask, BNA_RXMODE_DEFAULT)
+
+#define is_default_disable(mode, bitmask)				\
+	is_xxx_disable(mode, bitmask, BNA_RXMODE_DEFAULT)
+
+#define default_enable(mode, bitmask)					\
+	xxx_enable(mode, bitmask, BNA_RXMODE_DEFAULT)
+
+#define default_disable(mode, bitmask)					\
+	xxx_disable(mode, bitmask, BNA_RXMODE_DEFAULT)
+
+#define default_inactive(mode, bitmask)					\
+	xxx_inactive(mode, bitmask, BNA_RXMODE_DEFAULT)
+
+#define is_allmulti_enable(mode, bitmask)				\
+	is_xxx_enable(mode, bitmask, BNA_RXMODE_ALLMULTI)
+
+#define is_allmulti_disable(mode, bitmask)				\
+	is_xxx_disable(mode, bitmask, BNA_RXMODE_ALLMULTI)
+
+#define allmulti_enable(mode, bitmask)					\
+	xxx_enable(mode, bitmask, BNA_RXMODE_ALLMULTI)
+
+#define allmulti_disable(mode, bitmask)					\
+	xxx_disable(mode, bitmask, BNA_RXMODE_ALLMULTI)
+
+#define allmulti_inactive(mode, bitmask)				\
+	xxx_inactive(mode, bitmask, BNA_RXMODE_ALLMULTI)
+
+#define	GET_RXQS(rxp, q0, q1)	do {					\
+	switch ((rxp)->type) {						\
+	case BNA_RXP_SINGLE:						\
+		(q0) = rxp->rxq.single.only;				\
+		(q1) = NULL;						\
+		break;							\
+	case BNA_RXP_SLR:						\
+		(q0) = rxp->rxq.slr.large;				\
+		(q1) = rxp->rxq.slr.small;				\
+		break;							\
+	case BNA_RXP_HDS:						\
+		(q0) = rxp->rxq.hds.data;				\
+		(q1) = rxp->rxq.hds.hdr;				\
+		break;							\
+	}								\
+} while (0)
+
+/**
+ *
+ * Function prototypes
+ *
+ */
+
+/**
+ * BNA
+ */
+
+/* Internal APIs */
+void bna_adv_res_req(struct bna_res_info *res_info);
+
+/* APIs for BNAD */
+void bna_res_req(struct bna_res_info *res_info);
+void bna_init(struct bna *bna, struct bnad *bnad,
+			struct bna_ident *ident, struct bfa_pcidev *pcidev,
+			struct bna_res_info *res_info);
+void bna_uninit(struct bna *bna);
+void bna_stats_get(struct bna *bna);
+void bna_stats_clr(struct bna *bna);
+void bna_get_perm_mac(struct bna *bna, u8 *mac);
+
+/* APIs for Rx */
+int bna_rit_mod_can_satisfy(struct bna_rit_mod *rit_mod, int seg_size);
+
+/* APIs for RxF */
+struct bna_mac *bna_ucam_mod_mac_get(struct bna_ucam_mod *ucam_mod);
+void bna_ucam_mod_mac_put(struct bna_ucam_mod *ucam_mod,
+			  struct bna_mac *mac);
+struct bna_mac *bna_mcam_mod_mac_get(struct bna_mcam_mod *mcam_mod);
+void bna_mcam_mod_mac_put(struct bna_mcam_mod *mcam_mod,
+			  struct bna_mac *mac);
+struct bna_rit_segment *
+bna_rit_mod_seg_get(struct bna_rit_mod *rit_mod, int seg_size);
+void bna_rit_mod_seg_put(struct bna_rit_mod *rit_mod,
+			struct bna_rit_segment *seg);
+
+/**
+ * DEVICE
+ */
+
+/* Interanl APIs */
+void bna_adv_device_init(struct bna_device *device, struct bna *bna,
+			struct bna_res_info *res_info);
+
+/* APIs for BNA */
+void bna_device_init(struct bna_device *device, struct bna *bna,
+		     struct bna_res_info *res_info);
+void bna_device_uninit(struct bna_device *device);
+void bna_device_cb_port_stopped(void *arg, enum bna_cb_status status);
+int bna_device_status_get(struct bna_device *device);
+int bna_device_state_get(struct bna_device *device);
+
+/* APIs for BNAD */
+void bna_device_enable(struct bna_device *device);
+void bna_device_disable(struct bna_device *device,
+			enum bna_cleanup_type type);
+
+/**
+ * MBOX
+ */
+
+/* APIs for DEVICE */
+void bna_mbox_mod_init(struct bna_mbox_mod *mbox_mod, struct bna *bna);
+void bna_mbox_mod_uninit(struct bna_mbox_mod *mbox_mod);
+void bna_mbox_mod_start(struct bna_mbox_mod *mbox_mod);
+void bna_mbox_mod_stop(struct bna_mbox_mod *mbox_mod);
+
+/* APIs for PORT, TX, RX */
+void bna_mbox_handler(struct bna *bna, u32 intr_status);
+void bna_mbox_send(struct bna *bna, struct bna_mbox_qe *mbox_qe);
+
+/**
+ * PORT
+ */
+
+/* APIs for BNA */
+void bna_port_init(struct bna_port *port, struct bna *bna);
+void bna_port_uninit(struct bna_port *port);
+int bna_port_state_get(struct bna_port *port);
+int bna_llport_state_get(struct bna_llport *llport);
+
+/* APIs for DEVICE */
+void bna_port_start(struct bna_port *port);
+void bna_port_stop(struct bna_port *port);
+void bna_port_fail(struct bna_port *port);
+
+/* API for RX */
+int bna_port_mtu_get(struct bna_port *port);
+void bna_llport_admin_up(struct bna_llport *llport);
+void bna_llport_admin_down(struct bna_llport *llport);
+
+/* API for BNAD */
+void bna_port_enable(struct bna_port *port);
+void bna_port_disable(struct bna_port *port, enum bna_cleanup_type type,
+		      void (*cbfn)(void *, enum bna_cb_status));
+void bna_port_pause_config(struct bna_port *port,
+			   struct bna_pause_config *pause_config,
+			   void (*cbfn)(struct bnad *, enum bna_cb_status));
+void bna_port_mtu_set(struct bna_port *port, int mtu,
+		      void (*cbfn)(struct bnad *, enum bna_cb_status));
+void bna_port_mac_get(struct bna_port *port, mac_t *mac);
+void bna_port_type_set(struct bna_port *port, enum bna_port_type type);
+void bna_port_linkcbfn_set(struct bna_port *port,
+			   void (*linkcbfn)(struct bnad *,
+					    enum bna_link_status));
+void bna_port_admin_up(struct bna_port *port);
+void bna_port_admin_down(struct bna_port *port);
+
+/* Callbacks for TX, RX */
+void bna_port_cb_tx_stopped(struct bna_port *port,
+			    enum bna_cb_status status);
+void bna_port_cb_rx_stopped(struct bna_port *port,
+			    enum bna_cb_status status);
+
+/* Callbacks for MBOX */
+void bna_port_cb_link_up(struct bna_port *port, struct bfi_ll_aen *aen,
+			 int status);
+void bna_port_cb_link_down(struct bna_port *port, int status);
+
+/**
+ * IB
+ */
+
+/* APIs for BNA */
+void bna_ib_mod_init(struct bna_ib_mod *ib_mod, struct bna *bna,
+		     struct bna_res_info *res_info);
+void bna_ib_mod_uninit(struct bna_ib_mod *ib_mod);
+
+/* APIs for TX, RX */
+struct bna_ib *bna_ib_get(struct bna_ib_mod *ib_mod,
+			    enum bna_intr_type intr_type, int vector);
+void bna_ib_put(struct bna_ib_mod *ib_mod, struct bna_ib *ib);
+int bna_ib_reserve_idx(struct bna_ib *ib);
+void bna_ib_release_idx(struct bna_ib *ib, int idx);
+int bna_ib_config(struct bna_ib *ib, struct bna_ib_config *ib_config);
+void bna_ib_start(struct bna_ib *ib);
+void bna_ib_stop(struct bna_ib *ib);
+void bna_ib_fail(struct bna_ib *ib);
+void bna_ib_coalescing_timeo_set(struct bna_ib *ib, u8 coalescing_timeo);
+
+/**
+ * TX MODULE AND TX
+ */
+
+/* Internal APIs */
+void bna_tx_prio_changed(struct bna_tx *tx, int prio);
+
+/* APIs for BNA */
+void bna_tx_mod_init(struct bna_tx_mod *tx_mod, struct bna *bna,
+		     struct bna_res_info *res_info);
+void bna_tx_mod_uninit(struct bna_tx_mod *tx_mod);
+int bna_tx_state_get(struct bna_tx *tx);
+
+/* APIs for PORT */
+void bna_tx_mod_start(struct bna_tx_mod *tx_mod, enum bna_tx_type type);
+void bna_tx_mod_stop(struct bna_tx_mod *tx_mod, enum bna_tx_type type);
+void bna_tx_mod_fail(struct bna_tx_mod *tx_mod);
+void bna_tx_mod_prio_changed(struct bna_tx_mod *tx_mod, int prio);
+void bna_tx_mod_cee_link_status(struct bna_tx_mod *tx_mod, int cee_link);
+
+/* APIs for BNAD */
+void bna_tx_res_req(int num_txq, int txq_depth,
+		    struct bna_res_info *res_info);
+struct bna_tx *bna_tx_create(struct bna *bna, struct bnad *bnad,
+			       struct bna_tx_config *tx_cfg,
+			       struct bna_tx_event_cbfn *tx_cbfn,
+			       struct bna_res_info *res_info, void *priv);
+void bna_tx_destroy(struct bna_tx *tx);
+void bna_tx_enable(struct bna_tx *tx);
+void bna_tx_disable(struct bna_tx *tx, enum bna_cleanup_type type,
+		    void (*cbfn)(void *, struct bna_tx *,
+				 enum bna_cb_status));
+enum bna_cb_status
+bna_tx_prio_set(struct bna_tx *tx, int prio,
+		void (*cbfn)(struct bnad *, struct bna_tx *,
+			     enum bna_cb_status));
+void bna_tx_coalescing_timeo_set(struct bna_tx *tx, int coalescing_timeo);
+
+/**
+ * RX MODULE, RX, RXF
+ */
+
+/* Internal APIs */
+void rxf_cb_cam_fltr_mbox_cmd(void *arg, int status);
+void rxf_cam_mbox_cmd(struct bna_rxf *rxf, u8 cmd,
+		const struct bna_mac *mac_addr);
+void __rxf_vlan_filter_set(struct bna_rxf *rxf, enum bna_status status);
+void bna_rxf_adv_init(struct bna_rxf *rxf,
+		struct bna_rx *rx,
+		struct bna_rx_config *q_config);
+int rxf_process_packet_filter_ucast(struct bna_rxf *rxf);
+int rxf_process_packet_filter_promisc(struct bna_rxf *rxf);
+int rxf_process_packet_filter_default(struct bna_rxf *rxf);
+int rxf_process_packet_filter_allmulti(struct bna_rxf *rxf);
+int rxf_clear_packet_filter_ucast(struct bna_rxf *rxf);
+int rxf_clear_packet_filter_promisc(struct bna_rxf *rxf);
+int rxf_clear_packet_filter_default(struct bna_rxf *rxf);
+int rxf_clear_packet_filter_allmulti(struct bna_rxf *rxf);
+void rxf_reset_packet_filter_ucast(struct bna_rxf *rxf);
+void rxf_reset_packet_filter_promisc(struct bna_rxf *rxf);
+void rxf_reset_packet_filter_default(struct bna_rxf *rxf);
+void rxf_reset_packet_filter_allmulti(struct bna_rxf *rxf);
+
+/* APIs for BNA */
+void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
+		     struct bna_res_info *res_info);
+void bna_rx_mod_uninit(struct bna_rx_mod *rx_mod);
+int bna_rx_state_get(struct bna_rx *rx);
+int bna_rxf_state_get(struct bna_rxf *rxf);
+
+/* APIs for PORT */
+void bna_rx_mod_start(struct bna_rx_mod *rx_mod, enum bna_rx_type type);
+void bna_rx_mod_stop(struct bna_rx_mod *rx_mod, enum bna_rx_type type);
+void bna_rx_mod_fail(struct bna_rx_mod *rx_mod);
+
+/* APIs for BNAD */
+void bna_rx_res_req(struct bna_rx_config *rx_config,
+		    struct bna_res_info *res_info);
+struct bna_rx *bna_rx_create(struct bna *bna, struct bnad *bnad,
+			       struct bna_rx_config *rx_cfg,
+			       struct bna_rx_event_cbfn *rx_cbfn,
+			       struct bna_res_info *res_info, void *priv);
+void bna_rx_destroy(struct bna_rx *rx);
+void bna_rx_enable(struct bna_rx *rx);
+void bna_rx_disable(struct bna_rx *rx, enum bna_cleanup_type type,
+		    void (*cbfn)(void *, struct bna_rx *,
+				 enum bna_cb_status));
+void bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo);
+void bna_rx_dim_reconfig(struct bna *bna, u32 vector[][BNA_BIAS_T_MAX]);
+void bna_rx_dim_update(struct bna_ccb *ccb);
+enum bna_cb_status
+bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *,
+			      enum bna_cb_status));
+enum bna_cb_status
+bna_rx_ucast_add(struct bna_rx *rx, u8* ucmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *,
+			      enum bna_cb_status));
+enum bna_cb_status
+bna_rx_ucast_del(struct bna_rx *rx, u8 *ucmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *,
+			      enum bna_cb_status));
+enum bna_cb_status
+bna_rx_mcast_add(struct bna_rx *rx, u8 *mcmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *,
+			      enum bna_cb_status));
+enum bna_cb_status
+bna_rx_mcast_del(struct bna_rx *rx, u8 *mcmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *,
+			      enum bna_cb_status));
+enum bna_cb_status
+bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mcmac,
+		     void (*cbfn)(struct bnad *, struct bna_rx *,
+				  enum bna_cb_status));
+void bna_rx_mcast_delall(struct bna_rx *rx,
+			 void (*cbfn)(struct bnad *, struct bna_rx *,
+				      enum bna_cb_status));
+enum bna_cb_status
+bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
+		enum bna_rxmode bitmask,
+		void (*cbfn)(struct bnad *, struct bna_rx *,
+			     enum bna_cb_status));
+void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
+void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
+void bna_rx_vlanfilter_enable(struct bna_rx *rx);
+void bna_rx_vlanfilter_disable(struct bna_rx *rx);
+void bna_rx_rss_enable(struct bna_rx *rx);
+void bna_rx_rss_disable(struct bna_rx *rx);
+void bna_rx_rss_reconfig(struct bna_rx *rx, struct bna_rxf_rss *rss_config);
+void bna_rx_rss_rit_set(struct bna_rx *rx, unsigned int *vectors,
+			int nvectors);
+void bna_rx_hds_enable(struct bna_rx *rx, struct bna_rxf_hds *hds_config,
+		       void (*cbfn)(struct bnad *, struct bna_rx *,
+				    enum bna_cb_status));
+void bna_rx_hds_disable(struct bna_rx *rx,
+			void (*cbfn)(struct bnad *, struct bna_rx *,
+				     enum bna_cb_status));
+void bna_rx_receive_pause(struct bna_rx *rx,
+			  void (*cbfn)(struct bnad *, struct bna_rx *,
+				       enum bna_cb_status));
+void bna_rx_receive_resume(struct bna_rx *rx,
+			   void (*cbfn)(struct bnad *, struct bna_rx *,
+					enum bna_cb_status));
+
+/* RxF APIs for RX */
+void bna_rxf_start(struct bna_rxf *rxf);
+void bna_rxf_stop(struct bna_rxf *rxf);
+void bna_rxf_fail(struct bna_rxf *rxf);
+void bna_rxf_init(struct bna_rxf *rxf, struct bna_rx *rx,
+		  struct bna_rx_config *q_config);
+void bna_rxf_uninit(struct bna_rxf *rxf);
+
+/* Callback from RXF to RX */
+void bna_rx_cb_rxf_stopped(struct bna_rx *rx, enum bna_cb_status);
+void bna_rx_cb_rxf_started(struct bna_rx *rx, enum bna_cb_status);
+
+/**
+ * BNAD
+ */
+
+/* Callbacks for BNA */
+void bnad_cb_stats_get(struct bnad *bnad, enum bna_cb_status status,
+		       struct bna_stats *stats);
+void bnad_cb_stats_clr(struct bnad *bnad);
+
+/* Callbacks for DEVICE */
+void bnad_cb_device_enabled(struct bnad *bnad, enum bna_cb_status status);
+void bnad_cb_device_disabled(struct bnad *bnad, enum bna_cb_status status);
+void bnad_cb_device_enable_mbox_intr(struct bnad *bnad);
+void bnad_cb_device_disable_mbox_intr(struct bnad *bnad);
+
+/* Callbacks for port */
+void bnad_cb_port_link_status(struct bnad *bnad,
+			      enum bna_link_status status);
+
+#endif  /* __BNA_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bna_hw.h net-next-2.6.35-rc1-mod/drivers/net/bna/bna_hw.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bna_hw.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bna_hw.h	2010-08-02 17:19:19.853228000 -0700
@@ -0,0 +1,1491 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * File for interrupt macros and functions
+ */
+
+#ifndef __BNA_HW_H__
+#define __BNA_HW_H__
+
+#include "bfi_ctreg.h"
+
+/**
+ *
+ * SW imposed limits
+ *
+ */
+
+#ifndef BNA_BIOS_BUILD
+
+#define BFI_MAX_TXQ			64
+#define BFI_MAX_RXQ			64
+#define	BFI_MAX_RXF			64
+#define BFI_MAX_IB			128
+#define	BFI_MAX_RIT_SIZE		256
+#define	BFI_RSS_RIT_SIZE		64
+#define	BFI_NONRSS_RIT_SIZE		1
+#define BFI_MAX_UCMAC			256
+#define BFI_MAX_MCMAC			512
+#define BFI_IBIDX_SIZE			4
+#define BFI_MAX_VLAN			4095
+
+/**
+ * There are 2 free IB index pools:
+ *	pool1: 120 segments of 1 index each
+ *	pool8: 1 segment of 8 indexes
+ */
+#define BFI_IBIDX_POOL1_SIZE		116
+#define	BFI_IBIDX_POOL1_ENTRY_SIZE	1
+#define BFI_IBIDX_POOL2_SIZE		2
+#define	BFI_IBIDX_POOL2_ENTRY_SIZE	2
+#define	BFI_IBIDX_POOL8_SIZE		1
+#define	BFI_IBIDX_POOL8_ENTRY_SIZE	8
+#define	BFI_IBIDX_TOTAL_POOLS		3
+#define	BFI_IBIDX_TOTAL_SEGS		119 /* (POOL1 + POOL2 + POOL8)_SIZE */
+#define	BFI_IBIDX_MAX_SEGSIZE		8
+#define init_ibidx_pool(name)						\
+static struct bna_ibidx_pool name[BFI_IBIDX_TOTAL_POOLS] =		\
+{									\
+	{ BFI_IBIDX_POOL1_SIZE, BFI_IBIDX_POOL1_ENTRY_SIZE },		\
+	{ BFI_IBIDX_POOL2_SIZE, BFI_IBIDX_POOL2_ENTRY_SIZE },		\
+	{ BFI_IBIDX_POOL8_SIZE, BFI_IBIDX_POOL8_ENTRY_SIZE }		\
+}
+
+/**
+ * There are 2 free RIT segment pools:
+ * 	Pool1: 192 segments of 1 RIT entry each
+ *	Pool2: 1 segment of 64 RIT entry
+ */
+#define BFI_RIT_SEG_POOL1_SIZE		192
+#define BFI_RIT_SEG_POOL1_ENTRY_SIZE	1
+#define BFI_RIT_SEG_POOLRSS_SIZE	1
+#define BFI_RIT_SEG_POOLRSS_ENTRY_SIZE	64
+#define BFI_RIT_SEG_TOTAL_POOLS		2
+#define BFI_RIT_TOTAL_SEGS		193 /* POOL1_SIZE + POOLRSS_SIZE */
+#define init_ritseg_pool(name)						\
+static struct bna_ritseg_pool_cfg name[BFI_RIT_SEG_TOTAL_POOLS] =	\
+{									\
+	{ BFI_RIT_SEG_POOL1_SIZE, BFI_RIT_SEG_POOL1_ENTRY_SIZE },	\
+	{ BFI_RIT_SEG_POOLRSS_SIZE, BFI_RIT_SEG_POOLRSS_ENTRY_SIZE }	\
+}
+
+#else /* BNA_BIOS_BUILD */
+
+#define BFI_MAX_TXQ			1
+#define BFI_MAX_RXQ			1
+#define	BFI_MAX_RXF			1
+#define BFI_MAX_IB			2
+#define	BFI_MAX_RIT_SIZE		2
+#define	BFI_RSS_RIT_SIZE		64
+#define	BFI_NONRSS_RIT_SIZE		1
+#define BFI_MAX_UCMAC			1
+#define BFI_MAX_MCMAC			8
+#define BFI_IBIDX_SIZE			4
+#define BFI_MAX_VLAN			4095
+/* There is one free pool: 2 segments of 1 index each */
+#define BFI_IBIDX_POOL1_SIZE		2
+#define	BFI_IBIDX_POOL1_ENTRY_SIZE	1
+#define	BFI_IBIDX_TOTAL_POOLS		1
+#define	BFI_IBIDX_TOTAL_SEGS		2 /* POOL1_SIZE */
+#define	BFI_IBIDX_MAX_SEGSIZE		1
+#define init_ibidx_pool(name)						\
+static struct bna_ibidx_pool name[BFI_IBIDX_TOTAL_POOLS] =		\
+{									\
+	{ BFI_IBIDX_POOL1_SIZE, BFI_IBIDX_POOL1_ENTRY_SIZE }		\
+}
+
+#define BFI_RIT_SEG_POOL1_SIZE		1
+#define BFI_RIT_SEG_POOL1_ENTRY_SIZE	1
+#define BFI_RIT_SEG_TOTAL_POOLS		1
+#define BFI_RIT_TOTAL_SEGS		1 /* POOL1_SIZE */
+#define init_ritseg_pool(name)						\
+static struct bna_ritseg_pool_cfg name[BFI_RIT_SEG_TOTAL_POOLS] =	\
+{									\
+	{ BFI_RIT_SEG_POOL1_SIZE, BFI_RIT_SEG_POOL1_ENTRY_SIZE }	\
+}
+
+#endif /* BNA_BIOS_BUILD */
+
+#define BFI_RSS_HASH_KEY_LEN		10
+
+#define BFI_COALESCING_TIMER_UNIT	5	/* 5us */
+#define BFI_MAX_COALESCING_TIMEO	0xFF	/* in 5us units */
+#define BFI_MAX_INTERPKT_COUNT		0xFF
+#define BFI_MAX_INTERPKT_TIMEO		0xF	/* in 0.5us units */
+#define BFI_TX_COALESCING_TIMEO		20	/* 20 * 5 = 100us */
+#define BFI_TX_INTERPKT_COUNT		32
+#define	BFI_RX_COALESCING_TIMEO		12	/* 12 * 5 = 60us */
+#define	BFI_RX_INTERPKT_COUNT		6	/* Pkt Cnt = 6 */
+#define	BFI_RX_INTERPKT_TIMEO		3	/* 3 * 0.5 = 1.5us */
+
+#define BFI_TXQ_WI_SIZE			64	/* bytes */
+#define BFI_RXQ_WI_SIZE			8	/* bytes */
+#define BFI_CQ_WI_SIZE			16	/* bytes */
+#define BFI_TX_MAX_WRR_QUOTA		0xFFF
+
+#define BFI_TX_MAX_VECTORS_PER_WI	4
+#define BFI_TX_MAX_VECTORS_PER_PKT	0xFF
+#define BFI_TX_MAX_DATA_PER_VECTOR	0xFFFF
+#define BFI_TX_MAX_DATA_PER_PKT		0xFFFFFF
+
+/* Small Q buffer size */
+#define BFI_SMALL_RXBUF_SIZE		128
+
+/* Defined separately since BFA_FLASH_DMA_BUF_SZ is in bfa_flash.c */
+#define BFI_FLASH_DMA_BUF_SZ		0x010000 /* 64K DMA */
+#define BFI_HW_STATS_SIZE		0x4000 /* 16K DMA */
+
+/**
+ *
+ * HW register offsets, macros
+ *
+ */
+
+/* DMA Block Register Host Window Start Address */
+#define DMA_BLK_REG_ADDR		0x00013000
+
+/* DMA Block Internal Registers */
+#define DMA_CTRL_REG0			(DMA_BLK_REG_ADDR + 0x000)
+#define DMA_CTRL_REG1			(DMA_BLK_REG_ADDR + 0x004)
+#define DMA_ERR_INT_STATUS		(DMA_BLK_REG_ADDR + 0x008)
+#define DMA_ERR_INT_ENABLE		(DMA_BLK_REG_ADDR + 0x00c)
+#define DMA_ERR_INT_STATUS_SET		(DMA_BLK_REG_ADDR + 0x010)
+
+/* APP Block Register Address Offset from BAR0 */
+#define APP_BLK_REG_ADDR		0x00014000
+
+/* Host Function Interrupt Mask Registers */
+#define HOSTFN0_INT_MASK		(APP_BLK_REG_ADDR + 0x004)
+#define HOSTFN1_INT_MASK		(APP_BLK_REG_ADDR + 0x104)
+#define HOSTFN2_INT_MASK		(APP_BLK_REG_ADDR + 0x304)
+#define HOSTFN3_INT_MASK		(APP_BLK_REG_ADDR + 0x404)
+
+/**
+ * Host Function PCIe Error Registers
+ * Duplicates "Correctable" & "Uncorrectable"
+ * registers in PCIe Config space.
+ */
+#define FN0_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x014)
+#define FN1_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x114)
+#define FN2_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x314)
+#define FN3_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x414)
+
+/* Host Function Error Type Status Registers */
+#define FN0_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x018)
+#define FN1_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x118)
+#define FN2_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x318)
+#define FN3_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x418)
+
+/* Host Function Error Type Mask Registers */
+#define FN0_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x01c)
+#define FN1_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x11c)
+#define FN2_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x31c)
+#define FN3_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x41c)
+
+/* Catapult Host Semaphore Status Registers (App block) */
+#define HOST_SEM_STS0_REG		(APP_BLK_REG_ADDR + 0x630)
+#define HOST_SEM_STS1_REG		(APP_BLK_REG_ADDR + 0x634)
+#define HOST_SEM_STS2_REG		(APP_BLK_REG_ADDR + 0x638)
+#define HOST_SEM_STS3_REG		(APP_BLK_REG_ADDR + 0x63c)
+#define HOST_SEM_STS4_REG		(APP_BLK_REG_ADDR + 0x640)
+#define HOST_SEM_STS5_REG		(APP_BLK_REG_ADDR + 0x644)
+#define HOST_SEM_STS6_REG		(APP_BLK_REG_ADDR + 0x648)
+#define HOST_SEM_STS7_REG		(APP_BLK_REG_ADDR + 0x64c)
+
+/* PCIe Misc Register */
+#define PCIE_MISC_REG			(APP_BLK_REG_ADDR + 0x200)
+
+/* Temp Sensor Control Registers */
+#define TEMPSENSE_CNTL_REG		(APP_BLK_REG_ADDR + 0x250)
+#define TEMPSENSE_STAT_REG		(APP_BLK_REG_ADDR + 0x254)
+
+/* APP Block local error registers */
+#define APP_LOCAL_ERR_STAT		(APP_BLK_REG_ADDR + 0x258)
+#define APP_LOCAL_ERR_MSK		(APP_BLK_REG_ADDR + 0x25c)
+
+/* PCIe Link Error registers */
+#define PCIE_LNK_ERR_STAT		(APP_BLK_REG_ADDR + 0x260)
+#define PCIE_LNK_ERR_MSK		(APP_BLK_REG_ADDR + 0x264)
+
+/**
+ * FCoE/FIP Ethertype Register
+ * 31:16 -- Chip wide value for FIP type
+ * 15:0  -- Chip wide value for FCoE type
+ */
+#define FCOE_FIP_ETH_TYPE		(APP_BLK_REG_ADDR + 0x280)
+
+/**
+ * Reserved Ethertype Register
+ * 31:16 -- Reserved
+ * 15:0  -- Other ethertype
+ */
+#define RESV_ETH_TYPE			(APP_BLK_REG_ADDR + 0x284)
+
+/**
+ * Host Command Status Registers
+ * Each set consists of 3 registers :
+ * clear, set, cmd
+ * 16 such register sets in all
+ * See catapult_spec.pdf for detailed functionality
+ * Put each type in a single macro accessed by _num ?
+ */
+#define HOST_CMDSTS0_CLR_REG		(APP_BLK_REG_ADDR + 0x500)
+#define HOST_CMDSTS0_SET_REG		(APP_BLK_REG_ADDR + 0x504)
+#define HOST_CMDSTS0_REG		(APP_BLK_REG_ADDR + 0x508)
+#define HOST_CMDSTS1_CLR_REG		(APP_BLK_REG_ADDR + 0x510)
+#define HOST_CMDSTS1_SET_REG		(APP_BLK_REG_ADDR + 0x514)
+#define HOST_CMDSTS1_REG		(APP_BLK_REG_ADDR + 0x518)
+#define HOST_CMDSTS2_CLR_REG		(APP_BLK_REG_ADDR + 0x520)
+#define HOST_CMDSTS2_SET_REG		(APP_BLK_REG_ADDR + 0x524)
+#define HOST_CMDSTS2_REG		(APP_BLK_REG_ADDR + 0x528)
+#define HOST_CMDSTS3_CLR_REG		(APP_BLK_REG_ADDR + 0x530)
+#define HOST_CMDSTS3_SET_REG		(APP_BLK_REG_ADDR + 0x534)
+#define HOST_CMDSTS3_REG		(APP_BLK_REG_ADDR + 0x538)
+#define HOST_CMDSTS4_CLR_REG		(APP_BLK_REG_ADDR + 0x540)
+#define HOST_CMDSTS4_SET_REG		(APP_BLK_REG_ADDR + 0x544)
+#define HOST_CMDSTS4_REG		(APP_BLK_REG_ADDR + 0x548)
+#define HOST_CMDSTS5_CLR_REG		(APP_BLK_REG_ADDR + 0x550)
+#define HOST_CMDSTS5_SET_REG		(APP_BLK_REG_ADDR + 0x554)
+#define HOST_CMDSTS5_REG		(APP_BLK_REG_ADDR + 0x558)
+#define HOST_CMDSTS6_CLR_REG		(APP_BLK_REG_ADDR + 0x560)
+#define HOST_CMDSTS6_SET_REG		(APP_BLK_REG_ADDR + 0x564)
+#define HOST_CMDSTS6_REG		(APP_BLK_REG_ADDR + 0x568)
+#define HOST_CMDSTS7_CLR_REG		(APP_BLK_REG_ADDR + 0x570)
+#define HOST_CMDSTS7_SET_REG		(APP_BLK_REG_ADDR + 0x574)
+#define HOST_CMDSTS7_REG		(APP_BLK_REG_ADDR + 0x578)
+#define HOST_CMDSTS8_CLR_REG		(APP_BLK_REG_ADDR + 0x580)
+#define HOST_CMDSTS8_SET_REG		(APP_BLK_REG_ADDR + 0x584)
+#define HOST_CMDSTS8_REG		(APP_BLK_REG_ADDR + 0x588)
+#define HOST_CMDSTS9_CLR_REG		(APP_BLK_REG_ADDR + 0x590)
+#define HOST_CMDSTS9_SET_REG		(APP_BLK_REG_ADDR + 0x594)
+#define HOST_CMDSTS9_REG		(APP_BLK_REG_ADDR + 0x598)
+#define HOST_CMDSTS10_CLR_REG		(APP_BLK_REG_ADDR + 0x5A0)
+#define HOST_CMDSTS10_SET_REG		(APP_BLK_REG_ADDR + 0x5A4)
+#define HOST_CMDSTS10_REG		(APP_BLK_REG_ADDR + 0x5A8)
+#define HOST_CMDSTS11_CLR_REG		(APP_BLK_REG_ADDR + 0x5B0)
+#define HOST_CMDSTS11_SET_REG		(APP_BLK_REG_ADDR + 0x5B4)
+#define HOST_CMDSTS11_REG		(APP_BLK_REG_ADDR + 0x5B8)
+#define HOST_CMDSTS12_CLR_REG		(APP_BLK_REG_ADDR + 0x5C0)
+#define HOST_CMDSTS12_SET_REG		(APP_BLK_REG_ADDR + 0x5C4)
+#define HOST_CMDSTS12_REG		(APP_BLK_REG_ADDR + 0x5C8)
+#define HOST_CMDSTS13_CLR_REG		(APP_BLK_REG_ADDR + 0x5D0)
+#define HOST_CMDSTS13_SET_REG		(APP_BLK_REG_ADDR + 0x5D4)
+#define HOST_CMDSTS13_REG		(APP_BLK_REG_ADDR + 0x5D8)
+#define HOST_CMDSTS14_CLR_REG		(APP_BLK_REG_ADDR + 0x5E0)
+#define HOST_CMDSTS14_SET_REG		(APP_BLK_REG_ADDR + 0x5E4)
+#define HOST_CMDSTS14_REG		(APP_BLK_REG_ADDR + 0x5E8)
+#define HOST_CMDSTS15_CLR_REG		(APP_BLK_REG_ADDR + 0x5F0)
+#define HOST_CMDSTS15_SET_REG		(APP_BLK_REG_ADDR + 0x5F4)
+#define HOST_CMDSTS15_REG		(APP_BLK_REG_ADDR + 0x5F8)
+
+/**
+ * LPU0 Block Register Address Offset from BAR0
+ * Range 0x18000 - 0x18033
+ */
+#define LPU0_BLK_REG_ADDR		0x00018000
+
+/**
+ * LPU0 Registers
+ * Should they be directly used from host,
+ * except for diagnostics ?
+ * CTL_REG : Control register
+ * CMD_REG : Triggers exec. of cmd. in
+ *           Mailbox memory
+ */
+#define LPU0_MBOX_CTL_REG		(LPU0_BLK_REG_ADDR + 0x000)
+#define LPU0_MBOX_CMD_REG		(LPU0_BLK_REG_ADDR + 0x004)
+#define LPU0_MBOX_LINK_0REG		(LPU0_BLK_REG_ADDR + 0x008)
+#define LPU1_MBOX_LINK_0REG		(LPU0_BLK_REG_ADDR + 0x00c)
+#define LPU0_MBOX_STATUS_0REG		(LPU0_BLK_REG_ADDR + 0x010)
+#define LPU1_MBOX_STATUS_0REG		(LPU0_BLK_REG_ADDR + 0x014)
+#define LPU0_ERR_STATUS_REG		(LPU0_BLK_REG_ADDR + 0x018)
+#define LPU0_ERR_SET_REG		(LPU0_BLK_REG_ADDR + 0x020)
+
+/**
+ * LPU1 Block Register Address Offset from BAR0
+ * Range 0x18400 - 0x18433
+ */
+#define LPU1_BLK_REG_ADDR		0x00018400
+
+/**
+ * LPU1 Registers
+ * Same as LPU0 registers above
+ */
+#define LPU1_MBOX_CTL_REG		(LPU1_BLK_REG_ADDR + 0x000)
+#define LPU1_MBOX_CMD_REG		(LPU1_BLK_REG_ADDR + 0x004)
+#define LPU0_MBOX_LINK_1REG		(LPU1_BLK_REG_ADDR + 0x008)
+#define LPU1_MBOX_LINK_1REG		(LPU1_BLK_REG_ADDR + 0x00c)
+#define LPU0_MBOX_STATUS_1REG		(LPU1_BLK_REG_ADDR + 0x010)
+#define LPU1_MBOX_STATUS_1REG		(LPU1_BLK_REG_ADDR + 0x014)
+#define LPU1_ERR_STATUS_REG		(LPU1_BLK_REG_ADDR + 0x018)
+#define LPU1_ERR_SET_REG		(LPU1_BLK_REG_ADDR + 0x020)
+
+/**
+ * PSS Block Register Address Offset from BAR0
+ * Range 0x18800 - 0x188DB
+ */
+#define PSS_BLK_REG_ADDR		0x00018800
+
+/**
+ * PSS Registers
+ * For details, see catapult_spec.pdf
+ * ERR_STATUS_REG : Indicates error in PSS module
+ * RAM_ERR_STATUS_REG : Indicates RAM module that detected error
+ */
+#define ERR_STATUS_SET			(PSS_BLK_REG_ADDR + 0x018)
+#define PSS_RAM_ERR_STATUS_REG		(PSS_BLK_REG_ADDR + 0x01C)
+
+/**
+ * PSS Semaphore Lock Registers, total 16
+ * First read when unlocked returns 0,
+ * and is set to 1, atomically.
+ * Subsequent reads returns 1.
+ * To clear set the value to 0.
+ * Range : 0x20 to 0x5c
+ */
+#define PSS_SEM_LOCK_REG(_num) 		\
+	(PSS_BLK_REG_ADDR + 0x020 + ((_num) << 2))
+
+/**
+ * PSS Semaphore Status Registers,
+ * corresponding to the lock registers above
+ */
+#define PSS_SEM_STATUS_REG(_num) 		\
+	(PSS_BLK_REG_ADDR + 0x060 + ((_num) << 2))
+
+/**
+ * Catapult CPQ Registers
+ * Defines for Mailbox Registers
+ * Used to send mailbox commands to firmware from
+ * host. The data part is written to the MBox
+ * memory, registers are used to indicate that
+ * a commnad is resident in memory.
+ *
+ * Note : LPU0<->LPU1 mailboxes are not listed here
+ */
+#define CPQ_BLK_REG_ADDR		0x00019000
+
+#define HOSTFN0_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x130)
+#define HOSTFN0_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x134)
+#define LPU0_HOSTFN0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x138)
+#define LPU1_HOSTFN0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x13C)
+
+#define HOSTFN1_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x140)
+#define HOSTFN1_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x144)
+#define LPU0_HOSTFN1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x148)
+#define LPU1_HOSTFN1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x14C)
+
+#define HOSTFN2_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x170)
+#define HOSTFN2_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x174)
+#define LPU0_HOSTFN2_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x178)
+#define LPU1_HOSTFN2_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x17C)
+
+#define HOSTFN3_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x180)
+#define HOSTFN3_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x184)
+#define LPU0_HOSTFN3_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x188)
+#define LPU1_HOSTFN3_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x18C)
+
+/* Host Function Force Parity Error Registers */
+#define HOSTFN0_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x120)
+#define HOSTFN1_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x124)
+#define HOSTFN2_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x128)
+#define HOSTFN3_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x12C)
+
+/* LL Port[0|1] Halt Mask Registers */
+#define LL_HALT_MSK_P0			(CPQ_BLK_REG_ADDR + 0x1A0)
+#define LL_HALT_MSK_P1			(CPQ_BLK_REG_ADDR + 0x1B0)
+
+/* LL Port[0|1] Error Mask Registers */
+#define LL_ERR_MSK_P0			(CPQ_BLK_REG_ADDR + 0x1D0)
+#define LL_ERR_MSK_P1			(CPQ_BLK_REG_ADDR + 0x1D4)
+
+/* EMC FLI (Flash Controller) Block Register Address Offset from BAR0 */
+#define FLI_BLK_REG_ADDR		0x0001D000
+
+/* EMC FLI Registers */
+#define FLI_CMD_REG			(FLI_BLK_REG_ADDR + 0x000)
+#define FLI_ADDR_REG			(FLI_BLK_REG_ADDR + 0x004)
+#define FLI_CTL_REG			(FLI_BLK_REG_ADDR + 0x008)
+#define FLI_WRDATA_REG			(FLI_BLK_REG_ADDR + 0x00C)
+#define FLI_RDDATA_REG			(FLI_BLK_REG_ADDR + 0x010)
+#define FLI_DEV_STATUS_REG		(FLI_BLK_REG_ADDR + 0x014)
+#define FLI_SIG_WD_REG			(FLI_BLK_REG_ADDR + 0x018)
+
+/**
+ * RO register
+ * 31:16 -- Vendor Id
+ * 15:0  -- Device Id
+ */
+#define FLI_DEV_VENDOR_REG		(FLI_BLK_REG_ADDR + 0x01C)
+#define FLI_ERR_STATUS_REG		(FLI_BLK_REG_ADDR + 0x020)
+
+/**
+ * RAD (RxAdm) Block Register Address Offset from BAR0
+ * RAD0 Range : 0x20000 - 0x203FF
+ * RAD1 Range : 0x20400 - 0x207FF
+ */
+#define RAD0_BLK_REG_ADDR		0x00020000
+#define RAD1_BLK_REG_ADDR		0x00020400
+
+/* RAD0 Registers */
+#define RAD0_CTL_REG			(RAD0_BLK_REG_ADDR + 0x000)
+#define RAD0_PE_PARM_REG		(RAD0_BLK_REG_ADDR + 0x004)
+#define RAD0_BCN_REG			(RAD0_BLK_REG_ADDR + 0x008)
+
+/* Default function ID register */
+#define RAD0_DEFAULT_REG		(RAD0_BLK_REG_ADDR + 0x00C)
+
+/* Default promiscuous ID register */
+#define RAD0_PROMISC_REG		(RAD0_BLK_REG_ADDR + 0x010)
+
+#define RAD0_BCNQ_REG			(RAD0_BLK_REG_ADDR + 0x014)
+
+/*
+ * This register selects 1 of 8 PM Q's using
+ * VLAN pri, for non-BCN packets without a VLAN tag
+ */
+#define RAD0_DEFAULTQ_REG		(RAD0_BLK_REG_ADDR + 0x018)
+
+#define RAD0_ERR_STS			(RAD0_BLK_REG_ADDR + 0x01C)
+#define RAD0_SET_ERR_STS		(RAD0_BLK_REG_ADDR + 0x020)
+#define RAD0_ERR_INT_EN			(RAD0_BLK_REG_ADDR + 0x024)
+#define RAD0_FIRST_ERR			(RAD0_BLK_REG_ADDR + 0x028)
+#define RAD0_FORCE_ERR			(RAD0_BLK_REG_ADDR + 0x02C)
+
+#define RAD0_IF_RCVD			(RAD0_BLK_REG_ADDR + 0x030)
+#define RAD0_IF_RCVD_OCTETS_HIGH	(RAD0_BLK_REG_ADDR + 0x034)
+#define RAD0_IF_RCVD_OCTETS_LOW		(RAD0_BLK_REG_ADDR + 0x038)
+#define RAD0_IF_RCVD_VLAN		(RAD0_BLK_REG_ADDR + 0x03C)
+#define RAD0_IF_RCVD_UCAST		(RAD0_BLK_REG_ADDR + 0x040)
+#define RAD0_IF_RCVD_UCAST_OCTETS_HIGH	(RAD0_BLK_REG_ADDR + 0x044)
+#define RAD0_IF_RCVD_UCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x048)
+#define RAD0_IF_RCVD_UCAST_VLAN		(RAD0_BLK_REG_ADDR + 0x04C)
+#define RAD0_IF_RCVD_MCAST		(RAD0_BLK_REG_ADDR + 0x050)
+#define RAD0_IF_RCVD_MCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x054)
+#define RAD0_IF_RCVD_MCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x058)
+#define RAD0_IF_RCVD_MCAST_VLAN		(RAD0_BLK_REG_ADDR + 0x05C)
+#define RAD0_IF_RCVD_BCAST		(RAD0_BLK_REG_ADDR + 0x060)
+#define RAD0_IF_RCVD_BCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x064)
+#define RAD0_IF_RCVD_BCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x068)
+#define RAD0_IF_RCVD_BCAST_VLAN		(RAD0_BLK_REG_ADDR + 0x06C)
+#define RAD0_DROPPED_FRAMES		(RAD0_BLK_REG_ADDR + 0x070)
+
+#define RAD0_MAC_MAN_1H			(RAD0_BLK_REG_ADDR + 0x080)
+#define RAD0_MAC_MAN_1L			(RAD0_BLK_REG_ADDR + 0x084)
+#define RAD0_MAC_MAN_2H			(RAD0_BLK_REG_ADDR + 0x088)
+#define RAD0_MAC_MAN_2L			(RAD0_BLK_REG_ADDR + 0x08C)
+#define RAD0_MAC_MAN_3H			(RAD0_BLK_REG_ADDR + 0x090)
+#define RAD0_MAC_MAN_3L			(RAD0_BLK_REG_ADDR + 0x094)
+#define RAD0_MAC_MAN_4H			(RAD0_BLK_REG_ADDR + 0x098)
+#define RAD0_MAC_MAN_4L			(RAD0_BLK_REG_ADDR + 0x09C)
+
+#define RAD0_LAST4_IP			(RAD0_BLK_REG_ADDR + 0x100)
+
+/* RAD1 Registers */
+#define RAD1_CTL_REG			(RAD1_BLK_REG_ADDR + 0x000)
+#define RAD1_PE_PARM_REG		(RAD1_BLK_REG_ADDR + 0x004)
+#define RAD1_BCN_REG			(RAD1_BLK_REG_ADDR + 0x008)
+
+/* Default function ID register */
+#define RAD1_DEFAULT_REG		(RAD1_BLK_REG_ADDR + 0x00C)
+
+/* Promiscuous function ID register */
+#define RAD1_PROMISC_REG		(RAD1_BLK_REG_ADDR + 0x010)
+
+#define RAD1_BCNQ_REG			(RAD1_BLK_REG_ADDR + 0x014)
+
+/*
+ * This register selects 1 of 8 PM Q's using
+ * VLAN pri, for non-BCN packets without a VLAN tag
+ */
+#define RAD1_DEFAULTQ_REG		(RAD1_BLK_REG_ADDR + 0x018)
+
+#define RAD1_ERR_STS			(RAD1_BLK_REG_ADDR + 0x01C)
+#define RAD1_SET_ERR_STS		(RAD1_BLK_REG_ADDR + 0x020)
+#define RAD1_ERR_INT_EN			(RAD1_BLK_REG_ADDR + 0x024)
+
+/**
+ * TXA Block Register Address Offset from BAR0
+ * TXA0 Range : 0x21000 - 0x213FF
+ * TXA1 Range : 0x21400 - 0x217FF
+ */
+#define TXA0_BLK_REG_ADDR		0x00021000
+#define TXA1_BLK_REG_ADDR		0x00021400
+
+/* TXA Registers */
+#define TXA0_CTRL_REG			(TXA0_BLK_REG_ADDR + 0x000)
+#define TXA1_CTRL_REG			(TXA1_BLK_REG_ADDR + 0x000)
+
+/**
+ * TSO Sequence # Registers (RO)
+ * Total 8 (for 8 queues)
+ * Holds the last seq.# for TSO frames
+ * See catapult_spec.pdf for more details
+ */
+#define TXA0_TSO_TCP_SEQ_REG(_num)		\
+	(TXA0_BLK_REG_ADDR + 0x020 + ((_num) << 2))
+
+#define TXA1_TSO_TCP_SEQ_REG(_num)		\
+	(TXA1_BLK_REG_ADDR + 0x020 + ((_num) << 2))
+
+/**
+ * TSO IP ID # Registers (RO)
+ * Total 8 (for 8 queues)
+ * Holds the last IP ID for TSO frames
+ * See catapult_spec.pdf for more details
+ */
+#define TXA0_TSO_IP_INFO_REG(_num)		\
+	(TXA0_BLK_REG_ADDR + 0x040 + ((_num) << 2))
+
+#define TXA1_TSO_IP_INFO_REG(_num)		\
+	(TXA1_BLK_REG_ADDR + 0x040 + ((_num) << 2))
+
+/**
+ * RXA Block Register Address Offset from BAR0
+ * RXA0 Range : 0x21800 - 0x21BFF
+ * RXA1 Range : 0x21C00 - 0x21FFF
+ */
+#define RXA0_BLK_REG_ADDR		0x00021800
+#define RXA1_BLK_REG_ADDR		0x00021C00
+
+/* RXA Registers */
+#define RXA0_CTL_REG			(RXA0_BLK_REG_ADDR + 0x040)
+#define RXA1_CTL_REG			(RXA1_BLK_REG_ADDR + 0x040)
+
+/**
+ * PPLB Block Register Address Offset from BAR0
+ * PPLB0 Range : 0x22000 - 0x223FF
+ * PPLB1 Range : 0x22400 - 0x227FF
+ */
+#define PLB0_BLK_REG_ADDR		0x00022000
+#define PLB1_BLK_REG_ADDR		0x00022400
+
+/**
+ * PLB Registers
+ * Holds RL timer used time stamps in RLT tagged frames
+ */
+#define PLB0_ECM_TIMER_REG		(PLB0_BLK_REG_ADDR + 0x05C)
+#define PLB1_ECM_TIMER_REG		(PLB1_BLK_REG_ADDR + 0x05C)
+
+/* Controls the rate-limiter on each of the priority class */
+#define PLB0_RL_CTL			(PLB0_BLK_REG_ADDR + 0x060)
+#define PLB1_RL_CTL			(PLB1_BLK_REG_ADDR + 0x060)
+
+/**
+ * Max byte register, total 8, 0-7
+ * see catapult_spec.pdf for details
+ */
+#define PLB0_RL_MAX_BC(_num)			\
+	(PLB0_BLK_REG_ADDR + 0x064 + ((_num) << 2))
+#define PLB1_RL_MAX_BC(_num)			\
+	(PLB1_BLK_REG_ADDR + 0x064 + ((_num) << 2))
+
+/**
+ * RL Time Unit Register for priority 0-7
+ * 4 bits per priority
+ * (2^rl_unit)*1us is the actual time period
+ */
+#define PLB0_RL_TU_PRIO			(PLB0_BLK_REG_ADDR + 0x084)
+#define PLB1_RL_TU_PRIO			(PLB1_BLK_REG_ADDR + 0x084)
+
+/**
+ * RL byte count register,
+ * bytes transmitted in (rl_unit*1)us time period
+ * 1 per priority, 8 in all, 0-7.
+ */
+#define PLB0_RL_BYTE_CNT(_num)			\
+	(PLB0_BLK_REG_ADDR + 0x088 + ((_num) << 2))
+#define PLB1_RL_BYTE_CNT(_num)			\
+	(PLB1_BLK_REG_ADDR + 0x088 + ((_num) << 2))
+
+/**
+ * RL Min factor register
+ * 2 bits per priority,
+ * 4 factors possible: 1, 0.5, 0.25, 0
+ * 2'b00 - 0; 2'b01 - 0.25; 2'b10 - 0.5; 2'b11 - 1
+ */
+#define PLB0_RL_MIN_REG			(PLB0_BLK_REG_ADDR + 0x0A8)
+#define PLB1_RL_MIN_REG			(PLB1_BLK_REG_ADDR + 0x0A8)
+
+/**
+ * RL Max factor register
+ * 2 bits per priority,
+ * 4 factors possible: 1, 0.5, 0.25, 0
+ * 2'b00 - 0; 2'b01 - 0.25; 2'b10 - 0.5; 2'b11 - 1
+ */
+#define PLB0_RL_MAX_REG			(PLB0_BLK_REG_ADDR + 0x0AC)
+#define PLB1_RL_MAX_REG			(PLB1_BLK_REG_ADDR + 0x0AC)
+
+/* MAC SERDES Address Paging register */
+#define PLB0_EMS_ADD_REG		(PLB0_BLK_REG_ADDR + 0xD0)
+#define PLB1_EMS_ADD_REG		(PLB1_BLK_REG_ADDR + 0xD0)
+
+/* LL EMS Registers */
+#define LL_EMS0_BLK_REG_ADDR		0x00026800
+#define LL_EMS1_BLK_REG_ADDR		0x00026C00
+
+/**
+ * BPC Block Register Address Offset from BAR0
+ * BPC0 Range : 0x23000 - 0x233FF
+ * BPC1 Range : 0x23400 - 0x237FF
+ */
+#define BPC0_BLK_REG_ADDR		0x00023000
+#define BPC1_BLK_REG_ADDR		0x00023400
+
+/**
+ * PMM Block Register Address Offset from BAR0
+ * PMM0 Range : 0x23800 - 0x23BFF
+ * PMM1 Range : 0x23C00 - 0x23FFF
+ */
+#define PMM0_BLK_REG_ADDR		0x00023800
+#define PMM1_BLK_REG_ADDR		0x00023C00
+
+/**
+ * HQM Block Register Address Offset from BAR0
+ * HQM0 Range : 0x24000 - 0x243FF
+ * HQM1 Range : 0x24400 - 0x247FF
+ */
+#define HQM0_BLK_REG_ADDR		0x00024000
+#define HQM1_BLK_REG_ADDR		0x00024400
+
+/**
+ * HQM Control Register
+ * Controls some aspects of IB
+ * See catapult_spec.pdf for details
+ */
+#define HQM0_CTL_REG			(HQM0_BLK_REG_ADDR + 0x000)
+#define HQM1_CTL_REG			(HQM1_BLK_REG_ADDR + 0x000)
+
+/**
+ * HQM Stop Q Semaphore Registers.
+ * Only one Queue resource can be stopped at
+ * any given time. This register controls access
+ * to the single stop Q resource.
+ * See catapult_spec.pdf for details
+ */
+#define HQM0_RXQ_STOP_SEM		(HQM0_BLK_REG_ADDR + 0x028)
+#define HQM0_TXQ_STOP_SEM		(HQM0_BLK_REG_ADDR + 0x02C)
+#define HQM1_RXQ_STOP_SEM		(HQM1_BLK_REG_ADDR + 0x028)
+#define HQM1_TXQ_STOP_SEM		(HQM1_BLK_REG_ADDR + 0x02C)
+
+/**
+ * LUT Block Register Address Offset from BAR0
+ * LUT0 Range : 0x25800 - 0x25BFF
+ * LUT1 Range : 0x25C00 - 0x25FFF
+ */
+#define LUT0_BLK_REG_ADDR		0x00025800
+#define LUT1_BLK_REG_ADDR		0x00025C00
+
+/**
+ * LUT Registers
+ * See catapult_spec.pdf for details
+ */
+#define LUT0_ERR_STS			(LUT0_BLK_REG_ADDR + 0x000)
+#define LUT1_ERR_STS			(LUT1_BLK_REG_ADDR + 0x000)
+#define LUT0_SET_ERR_STS		(LUT0_BLK_REG_ADDR + 0x004)
+#define LUT1_SET_ERR_STS		(LUT1_BLK_REG_ADDR + 0x004)
+
+/**
+ * TRC (Debug/Trace) Register Offset from BAR0
+ * Range : 0x26000 -- 0x263FFF
+ */
+#define TRC_BLK_REG_ADDR		0x00026000
+
+/**
+ * TRC Registers
+ * See catapult_spec.pdf for details of each
+ */
+#define TRC_CTL_REG			(TRC_BLK_REG_ADDR + 0x000)
+#define TRC_MODS_REG			(TRC_BLK_REG_ADDR + 0x004)
+#define TRC_TRGC_REG			(TRC_BLK_REG_ADDR + 0x008)
+#define TRC_CNT1_REG			(TRC_BLK_REG_ADDR + 0x010)
+#define TRC_CNT2_REG			(TRC_BLK_REG_ADDR + 0x014)
+#define TRC_NXTS_REG			(TRC_BLK_REG_ADDR + 0x018)
+#define TRC_DIRR_REG			(TRC_BLK_REG_ADDR + 0x01C)
+
+/**
+ * TRC Trigger match filters, total 10
+ * Determines the trigger condition
+ */
+#define TRC_TRGM_REG(_num)		\
+	(TRC_BLK_REG_ADDR + 0x040 + ((_num) << 2))
+
+/**
+ * TRC Next State filters, total 10
+ * Determines the next state conditions
+ */
+#define TRC_NXTM_REG(_num)		\
+	(TRC_BLK_REG_ADDR + 0x080 + ((_num) << 2))
+
+/**
+ * TRC Store Match filters, total 10
+ * Determines the store conditions
+ */
+#define TRC_STRM_REG(_num)		\
+	(TRC_BLK_REG_ADDR + 0x0C0 + ((_num) << 2))
+
+/* DOORBELLS ACCESS */
+
+/**
+ * Catapult doorbells
+ * Each doorbell-queue set has
+ * 1 RxQ, 1 TxQ, 2 IBs in that order
+ * Size of each entry in 32 bytes, even though only 1 word
+ * is used. For Non-VM case each doorbell-q set is
+ * separated by 128 bytes, for VM case it is separated
+ * by 4K bytes
+ * Non VM case Range : 0x38000 - 0x39FFF
+ * VM case Range     : 0x100000 - 0x11FFFF
+ * The range applies to both HQMs
+ */
+#define HQM_DOORBELL_BLK_BASE_ADDR	0x00038000
+#define HQM_DOORBELL_VM_BLK_BASE_ADDR	0x00100000
+
+/* MEMORY ACCESS */
+
+/**
+ * Catapult H/W Block Memory Access Address
+ * To the host a memory space of 32K (page) is visible
+ * at a time. The address range is from 0x08000 to 0x0FFFF
+ */
+#define HW_BLK_HOST_MEM_ADDR		0x08000
+
+/**
+ * Catapult LUT Memory Access Page Numbers
+ * Range : LUT0 0xa0-0xa1
+ *         LUT1 0xa2-0xa3
+ */
+#define LUT0_MEM_BLK_BASE_PG_NUM	0x000000A0
+#define LUT1_MEM_BLK_BASE_PG_NUM	0x000000A2
+
+/**
+ * Catapult RxFn Database Memory Block Base Offset
+ *
+ * The Rx function database exists in LUT block.
+ * In PCIe space this is accessible as a 256x32
+ * bit block. Each entry in this database is 4
+ * (4 byte) words. Max. entries is 64.
+ * Address of an entry corresponding to a function
+ * = base_addr + (function_no. * 16)
+ */
+#define RX_FNDB_RAM_BASE_OFFSET		0x0000B400
+
+/**
+ * Catapult TxFn Database Memory Block Base Offset Address
+ *
+ * The Tx function database exists in LUT block.
+ * In PCIe space this is accessible as a 64x32
+ * bit block. Each entry in this database is 1
+ * (4 byte) word. Max. entries is 64.
+ * Address of an entry corresponding to a function
+ * = base_addr + (function_no. * 4)
+ */
+#define TX_FNDB_RAM_BASE_OFFSET		0x0000B800
+
+/**
+ * Catapult Unicast CAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Shared by both the LL & FCoE driver.
+ * Size is 256x48 bits; mapped to PCIe space
+ * 512x32 bit blocks. For each address, bits
+ * are written in the order : [47:32] and then
+ * [31:0].
+ */
+#define UCAST_CAM_BASE_OFFSET		0x0000A800
+
+/**
+ * Catapult Unicast RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Shared by both the LL & FCoE driver.
+ * Size is 256x9 bits.
+ */
+#define UCAST_RAM_BASE_OFFSET		0x0000B000
+
+/**
+ * Catapult Mulicast CAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Shared by both the LL & FCoE driver.
+ * Size is 256x48 bits; mapped to PCIe space
+ * 512x32 bit blocks. For each address, bits
+ * are written in the order : [47:32] and then
+ * [31:0].
+ */
+#define MCAST_CAM_BASE_OFFSET		0x0000A000
+
+/**
+ * Catapult VLAN RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Size is 4096x66 bits; mapped to PCIe space as
+ * 8192x32 bit blocks.
+ * All the 4K entries are within the address range
+ * 0x0000 to 0x8000, so in the first LUT page.
+ */
+#define VLAN_RAM_BASE_OFFSET		0x00000000
+
+/**
+ * Catapult Tx Stats RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Size is 1024x33 bits;
+ * Each Tx function has 64 bytes of space
+ */
+#define TX_STATS_RAM_BASE_OFFSET	0x00009000
+
+/**
+ * Catapult Rx Stats RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Size is 1024x33 bits;
+ * Each Rx function has 64 bytes of space
+ */
+#define RX_STATS_RAM_BASE_OFFSET	0x00008000
+
+/* Catapult RXA Memory Access Page Numbers */
+#define RXA0_MEM_BLK_BASE_PG_NUM	0x0000008C
+#define RXA1_MEM_BLK_BASE_PG_NUM	0x0000008D
+
+/**
+ * Catapult Multicast Vector Table Base Offset Address
+ *
+ * Exists in RxA memory space.
+ * Organized as 512x65 bit block.
+ * However for each entry 16 bytes allocated (power of 2)
+ * Total size 512*16 bytes.
+ * There are two logical divisions, 256 entries each :
+ * a) Entries 0x00 to 0xff (256) -- Approx. MVT
+ *    Offset 0x000 to 0xFFF
+ * b) Entries 0x100 to 0x1ff (256) -- Exact MVT
+ *    Offsets 0x1000 to 0x1FFF
+ */
+#define MCAST_APPROX_MVT_BASE_OFFSET	0x00000000
+#define MCAST_EXACT_MVT_BASE_OFFSET	0x00001000
+
+/**
+ * Catapult RxQ Translate Table (RIT) Base Offset Address
+ *
+ * Exists in RxA memory space
+ * Total no. of entries 64
+ * Each entry is 1 (4 byte) word.
+ * 31:12 -- Reserved
+ * 11:0  -- Two 6 bit RxQ Ids
+ */
+#define FUNCTION_TO_RXQ_TRANSLATE	0x00002000
+
+/* Catapult RxAdm (RAD) Memory Access Page Numbers */
+#define RAD0_MEM_BLK_BASE_PG_NUM	0x00000086
+#define RAD1_MEM_BLK_BASE_PG_NUM	0x00000087
+
+/**
+ * Catapult RSS Table Base Offset Address
+ *
+ * Exists in RAD memory space.
+ * Each entry is 352 bits, but alligned on
+ * 64 byte (512 bit) boundary. Accessed
+ * 4 byte words, the whole entry can be
+ * broken into 11 word accesses.
+ */
+#define RSS_TABLE_BASE_OFFSET		0x00000800
+
+/**
+ * Catapult CPQ Block Page Number
+ * This value is written to the page number registers
+ * to access the memory associated with the mailboxes.
+ */
+#define CPQ_BLK_PG_NUM			0x00000005
+
+/**
+ * Clarification :
+ * LL functions are 2 & 3; can HostFn0/HostFn1
+ * <-> LPU0/LPU1 memories be used ?
+ */
+/**
+ * Catapult HostFn0/HostFn1 to LPU0/LPU1 Mbox memory
+ * Per catapult_spec.pdf, the offset of the mbox
+ * memory is in the register space at an offset of 0x200
+ */
+#define CPQ_BLK_REG_MBOX_ADDR		(CPQ_BLK_REG_ADDR + 0x200)
+
+#define HOSTFN_LPU_MBOX			(CPQ_BLK_REG_MBOX_ADDR + 0x000)
+
+/* Catapult LPU0/LPU1 to HostFn0/HostFn1 Mbox memory */
+#define LPU_HOSTFN_MBOX			(CPQ_BLK_REG_MBOX_ADDR + 0x080)
+
+/**
+ * Catapult HQM Block Page Number
+ * This is written to the page number register for
+ * the appropriate function to access the memory
+ * associated with HQM
+ */
+#define HQM0_BLK_PG_NUM			0x00000096
+#define HQM1_BLK_PG_NUM			0x00000097
+
+/**
+ * Note that TxQ and RxQ entries are interlaced
+ * the HQM memory, i.e RXQ0, TXQ0, RXQ1, TXQ1.. etc.
+ */
+
+#define HQM_RXTX_Q_RAM_BASE_OFFSET	0x00004000
+
+/**
+ * CQ Memory
+ * Exists in HQM Memory space
+ * Each entry is 16 (4 byte) words of which
+ * only 12 words are used for configuration
+ * Total 64 entries per HQM memory space
+ */
+#define HQM_CQ_RAM_BASE_OFFSET		0x00006000
+
+/**
+ * Interrupt Block (IB) Memory
+ * Exists in HQM Memory space
+ * Each entry is 8 (4 byte) words of which
+ * only 5 words are used for configuration
+ * Total 128 entries per HQM memory space
+ */
+#define HQM_IB_RAM_BASE_OFFSET		0x00001000
+
+/**
+ * Index Table (IT) Memory
+ * Exists in HQM Memory space
+ * Each entry is 1 (4 byte) word which
+ * is used for configuration
+ * Total 128 entries per HQM memory space
+ */
+#define HQM_INDX_TBL_RAM_BASE_OFFSET	0x00002000
+
+/**
+ * PSS Block Memory Page Number
+ * This is written to the appropriate page number
+ * register to access the CPU memory.
+ * Also known as the PSS secondary memory (SMEM).
+ * Range : 0x180 to 0x1CF
+ * See catapult_spec.pdf for details
+ */
+#define PSS_BLK_PG_NUM			0x00000180
+
+/**
+ * Offsets of different instances of PSS SMEM
+ * 2.5M of continuous 1T memory space : 2 blocks
+ * of 1M each (32 pages each, page=32KB) and 4 smaller
+ * blocks of 128K each (4 pages each, page=32KB)
+ * PSS_LMEM_INST0 is used for firmware download
+ */
+#define PSS_LMEM_INST0			0x00000000
+#define PSS_LMEM_INST1			0x00100000
+#define PSS_LMEM_INST2			0x00200000
+#define PSS_LMEM_INST3			0x00220000
+#define PSS_LMEM_INST4			0x00240000
+#define PSS_LMEM_INST5			0x00260000
+
+#define BNA_PCI_REG_CT_ADDRSZ		(0x40000)
+
+#define BNA_GET_PAGE_NUM(_base_page, _offset)   \
+	((_base_page) + ((_offset) >> 15))
+
+#define BNA_GET_PAGE_OFFSET(_offset)    \
+	((_offset) & 0x7fff)
+
+#define BNA_GET_MEM_BASE_ADDR(_bar0, _base_offset)	\
+	((_bar0) + HW_BLK_HOST_MEM_ADDR		\
+	  + BNA_GET_PAGE_OFFSET((_base_offset)))
+
+#define BNA_GET_VLAN_MEM_ENTRY_ADDR(_bar0, _fn_id, _vlan_id)\
+	(_bar0 + (HW_BLK_HOST_MEM_ADDR)  \
+	+ (BNA_GET_PAGE_OFFSET(VLAN_RAM_BASE_OFFSET))	\
+	+ (((_fn_id) & 0x3f) << 9)	  \
+	+ (((_vlan_id) & 0xfe0) >> 3))
+
+/**
+ *
+ *  Interrupt related bits, flags and macros
+ *
+ */
+
+#define __LPU02HOST_MBOX0_STATUS_BITS 0x00100000
+#define __LPU12HOST_MBOX0_STATUS_BITS 0x00200000
+#define __LPU02HOST_MBOX1_STATUS_BITS 0x00400000
+#define __LPU12HOST_MBOX1_STATUS_BITS 0x00800000
+
+#define __LPU02HOST_MBOX0_MASK_BITS	0x00100000
+#define __LPU12HOST_MBOX0_MASK_BITS	0x00200000
+#define __LPU02HOST_MBOX1_MASK_BITS	0x00400000
+#define __LPU12HOST_MBOX1_MASK_BITS	0x00800000
+
+#define __LPU2HOST_MBOX_MASK_BITS			 \
+	(__LPU02HOST_MBOX0_MASK_BITS | __LPU02HOST_MBOX1_MASK_BITS |	\
+	  __LPU12HOST_MBOX0_MASK_BITS | __LPU12HOST_MBOX1_MASK_BITS)
+
+#define __LPU2HOST_IB_STATUS_BITS	0x0000ffff
+
+#define BNA_IS_LPU0_MBOX_INTR(_intr_status) \
+	((_intr_status) & (__LPU02HOST_MBOX0_STATUS_BITS | \
+			__LPU02HOST_MBOX1_STATUS_BITS))
+
+#define BNA_IS_LPU1_MBOX_INTR(_intr_status) \
+	((_intr_status) & (__LPU12HOST_MBOX0_STATUS_BITS | \
+		__LPU12HOST_MBOX1_STATUS_BITS))
+
+#define BNA_IS_MBOX_INTR(_intr_status)		\
+	((_intr_status) &  			\
+	(__LPU02HOST_MBOX0_STATUS_BITS |	\
+	 __LPU02HOST_MBOX1_STATUS_BITS |	\
+	 __LPU12HOST_MBOX0_STATUS_BITS |	\
+	 __LPU12HOST_MBOX1_STATUS_BITS))
+
+#define __EMC_ERROR_STATUS_BITS		0x00010000
+#define __LPU0_ERROR_STATUS_BITS	0x00020000
+#define __LPU1_ERROR_STATUS_BITS	0x00040000
+#define __PSS_ERROR_STATUS_BITS		0x00080000
+
+#define __HALT_STATUS_BITS		0x01000000
+
+#define __EMC_ERROR_MASK_BITS		0x00010000
+#define __LPU0_ERROR_MASK_BITS		0x00020000
+#define __LPU1_ERROR_MASK_BITS		0x00040000
+#define __PSS_ERROR_MASK_BITS		0x00080000
+
+#define __HALT_MASK_BITS		0x01000000
+
+#define __ERROR_MASK_BITS		\
+	(__EMC_ERROR_MASK_BITS | __LPU0_ERROR_MASK_BITS | \
+	  __LPU1_ERROR_MASK_BITS | __PSS_ERROR_MASK_BITS | \
+	  __HALT_MASK_BITS)
+
+#define BNA_IS_ERR_INTR(_intr_status)	\
+	((_intr_status) &  		\
+	(__EMC_ERROR_STATUS_BITS |  	\
+	 __LPU0_ERROR_STATUS_BITS | 	\
+	 __LPU1_ERROR_STATUS_BITS | 	\
+	 __PSS_ERROR_STATUS_BITS  | 	\
+	 __HALT_STATUS_BITS))
+
+#define BNA_IS_MBOX_ERR_INTR(_intr_status)	\
+	(BNA_IS_MBOX_INTR((_intr_status)) |	\
+	 BNA_IS_ERR_INTR((_intr_status)))
+
+#define BNA_IS_INTX_DATA_INTR(_intr_status)	\
+	((_intr_status) & __LPU2HOST_IB_STATUS_BITS)
+
+#define BNA_INTR_STATUS_MBOX_CLR(_intr_status)			\
+do {								\
+	(_intr_status) &= ~(__LPU02HOST_MBOX0_STATUS_BITS |	\
+			__LPU02HOST_MBOX1_STATUS_BITS | 	\
+			__LPU12HOST_MBOX0_STATUS_BITS | 	\
+			__LPU12HOST_MBOX1_STATUS_BITS); 	\
+} while (0)
+
+#define BNA_INTR_STATUS_ERR_CLR(_intr_status)		\
+do {							\
+	(_intr_status) &= ~(__EMC_ERROR_STATUS_BITS |	\
+		__LPU0_ERROR_STATUS_BITS |		\
+		__LPU1_ERROR_STATUS_BITS |		\
+		__PSS_ERROR_STATUS_BITS  |		\
+		__HALT_STATUS_BITS);			\
+} while (0)
+
+#define bna_intx_disable(_bna, _cur_mask)		\
+{							\
+	(_cur_mask) = readl((_bna)->regs.fn_int_mask);\
+	writel(0xffffffff, (_bna)->regs.fn_int_mask);\
+}
+
+#define bna_intx_enable(bna, new_mask) 			\
+	writel((new_mask), (bna)->regs.fn_int_mask)
+
+#define bna_mbox_intr_disable(bna)		\
+	writel((readl((bna)->regs.fn_int_mask) | \
+	     (__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)), \
+	     (bna)->regs.fn_int_mask)
+
+#define bna_mbox_intr_enable(bna)		\
+	writel((readl((bna)->regs.fn_int_mask) & \
+	     ~(__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)), \
+	     (bna)->regs.fn_int_mask)
+
+#define bna_intr_status_get(_bna, _status)				\
+{									\
+	(_status) = readl((_bna)->regs.fn_int_status);		\
+	if ((_status)) {						\
+		writel((_status) & ~(__LPU02HOST_MBOX0_STATUS_BITS |\
+					  __LPU02HOST_MBOX1_STATUS_BITS |\
+					  __LPU12HOST_MBOX0_STATUS_BITS |\
+					  __LPU12HOST_MBOX1_STATUS_BITS), \
+			      (_bna)->regs.fn_int_status);\
+	}								\
+}
+
+#define bna_intr_status_get_no_clr(_bna, _status)		\
+	(_status) = readl((_bna)->regs.fn_int_status)
+
+#define bna_intr_mask_get(bna, mask)		\
+	(*mask) = readl((bna)->regs.fn_int_mask)
+
+#define bna_intr_ack(bna, intr_bmap)		\
+	writel((intr_bmap), (bna)->regs.fn_int_status)
+
+#define bna_ib_intx_disable(bna, ib_id)		\
+	writel(readl((bna)->regs.fn_int_mask) | \
+	    (1 << (ib_id)), \
+	    (bna)->regs.fn_int_mask)
+
+#define bna_ib_intx_enable(bna, ib_id)		\
+	writel(readl((bna)->regs.fn_int_mask) & \
+	    ~(1 << (ib_id)), \
+	    (bna)->regs.fn_int_mask)
+
+#define bna_mbox_msix_idx_set(_device) \
+do {\
+	writel(((_device)->vector & 0x000001FF), \
+		(_device)->bna->pcidev.pci_bar_kva + \
+		reg_offset[(_device)->bna->pcidev.pci_func].msix_idx);\
+} while (0)
+
+/**
+ *
+ * TxQ, RxQ, CQ related bits, offsets, macros
+ *
+ */
+
+#define	BNA_Q_IDLE_STATE	0x00008001
+
+#define BNA_GET_DOORBELL_BASE_ADDR(_bar0)	\
+	((_bar0) + HQM_DOORBELL_BLK_BASE_ADDR)
+
+#define BNA_GET_DOORBELL_ENTRY_OFFSET(_entry)		\
+	((HQM_DOORBELL_BLK_BASE_ADDR)		\
+	+ (_entry << 7))
+
+#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events) \
+		(0x80000000 | ((_timeout) << 16) | (_events))
+
+#define BNA_DOORBELL_IB_INT_DISABLE		(0x40000000)
+
+/* TxQ Entry Opcodes */
+#define BNA_TXQ_WI_SEND 		(0x402)	/* Single Frame Transmission */
+#define BNA_TXQ_WI_SEND_LSO 		(0x403)	/* Multi-Frame Transmission */
+#define BNA_TXQ_WI_EXTENSION		(0x104)	/* Extension WI */
+
+/* TxQ Entry Control Flags */
+#define BNA_TXQ_WI_CF_FCOE_CRC  	(1 << 8)
+#define BNA_TXQ_WI_CF_IPID_MODE 	(1 << 5)
+#define BNA_TXQ_WI_CF_INS_PRIO  	(1 << 4)
+#define BNA_TXQ_WI_CF_INS_VLAN  	(1 << 3)
+#define BNA_TXQ_WI_CF_UDP_CKSUM 	(1 << 2)
+#define BNA_TXQ_WI_CF_TCP_CKSUM 	(1 << 1)
+#define BNA_TXQ_WI_CF_IP_CKSUM  	(1 << 0)
+
+#define BNA_TXQ_WI_L4_HDR_N_OFFSET(_hdr_size, _offset) \
+		(((_hdr_size) << 10) | ((_offset) & 0x3FF))
+
+/*
+ * Completion Q defines
+ */
+/* CQ Entry Flags */
+#define	BNA_CQ_EF_MAC_ERROR 	(1 <<  0)
+#define	BNA_CQ_EF_FCS_ERROR 	(1 <<  1)
+#define	BNA_CQ_EF_TOO_LONG  	(1 <<  2)
+#define	BNA_CQ_EF_FC_CRC_OK 	(1 <<  3)
+
+#define	BNA_CQ_EF_RSVD1 	(1 <<  4)
+#define	BNA_CQ_EF_L4_CKSUM_OK	(1 <<  5)
+#define	BNA_CQ_EF_L3_CKSUM_OK	(1 <<  6)
+#define	BNA_CQ_EF_HDS_HEADER	(1 <<  7)
+
+#define	BNA_CQ_EF_UDP   	(1 <<  8)
+#define	BNA_CQ_EF_TCP   	(1 <<  9)
+#define	BNA_CQ_EF_IP_OPTIONS	(1 << 10)
+#define	BNA_CQ_EF_IPV6  	(1 << 11)
+
+#define	BNA_CQ_EF_IPV4  	(1 << 12)
+#define	BNA_CQ_EF_VLAN  	(1 << 13)
+#define	BNA_CQ_EF_RSS   	(1 << 14)
+#define	BNA_CQ_EF_RSVD2 	(1 << 15)
+
+#define	BNA_CQ_EF_MCAST_MATCH   (1 << 16)
+#define	BNA_CQ_EF_MCAST 	(1 << 17)
+#define BNA_CQ_EF_BCAST 	(1 << 18)
+#define	BNA_CQ_EF_REMOTE 	(1 << 19)
+
+#define	BNA_CQ_EF_LOCAL		(1 << 20)
+
+/**
+ *
+ * Data structures
+ *
+ */
+
+enum txf_flags {
+	BFI_TXF_CF_ENABLE		= 1 << 0,
+	BFI_TXF_CF_VLAN_FILTER		= 1 << 8,
+	BFI_TXF_CF_VLAN_ADMIT		= 1 << 9,
+	BFI_TXF_CF_VLAN_INSERT		= 1 << 10,
+	BFI_TXF_CF_RSVD1		= 1 << 11,
+	BFI_TXF_CF_MAC_SA_CHECK		= 1 << 12,
+	BFI_TXF_CF_VLAN_WI_BASED	= 1 << 13,
+	BFI_TXF_CF_VSWITCH_MCAST	= 1 << 14,
+	BFI_TXF_CF_VSWITCH_UCAST	= 1 << 15,
+	BFI_TXF_CF_RSVD2		= 0x7F << 1
+};
+
+enum ib_flags {
+	BFI_IB_CF_MASTER_ENABLE		= (1 << 0),
+	BFI_IB_CF_MSIX_MODE		= (1 << 1),
+	BFI_IB_CF_COALESCING_MODE	= (1 << 2),
+	BFI_IB_CF_INTER_PKT_ENABLE	= (1 << 3),
+	BFI_IB_CF_INT_ENABLE		= (1 << 4),
+	BFI_IB_CF_INTER_PKT_DMA		= (1 << 5),
+	BFI_IB_CF_ACK_PENDING		= (1 << 6),
+	BFI_IB_CF_RESERVED1		= (1 << 7)
+};
+
+enum rss_hash_type {
+	BFI_RSS_T_V4_TCP    		= (1 << 11),
+	BFI_RSS_T_V4_IP     		= (1 << 10),
+	BFI_RSS_T_V6_TCP    		= (1 <<  9),
+	BFI_RSS_T_V6_IP     		= (1 <<  8)
+};
+enum hds_header_type {
+	BNA_HDS_T_V4_TCP	= (1 << 11),
+	BNA_HDS_T_V4_UDP	= (1 << 10),
+	BNA_HDS_T_V6_TCP	= (1 << 9),
+	BNA_HDS_T_V6_UDP	= (1 << 8),
+	BNA_HDS_FORCED		= (1 << 7),
+};
+enum rxf_flags {
+	BNA_RXF_CF_SM_LG_RXQ			= (1 << 15),
+	BNA_RXF_CF_DEFAULT_VLAN			= (1 << 14),
+	BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE	= (1 << 13),
+	BNA_RXF_CF_VLAN_STRIP			= (1 << 12),
+	BNA_RXF_CF_RSS_ENABLE			= (1 <<  8)
+};
+struct bna_chip_regs_offset {
+	u32 page_addr;
+	u32 fn_int_status;
+	u32 fn_int_mask;
+	u32 msix_idx;
+};
+extern const struct bna_chip_regs_offset reg_offset[];
+
+struct bna_chip_regs {
+	void __iomem *page_addr;
+	void __iomem *fn_int_status;
+	void __iomem *fn_int_mask;
+};
+
+struct bna_txq_mem {
+	u32 pg_tbl_addr_lo;
+	u32 pg_tbl_addr_hi;
+	u32 cur_q_entry_lo;
+	u32 cur_q_entry_hi;
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;	/* 31:16->total page count */
+					/* 15:0 ->producer pointer (index?) */
+	u32 entry_n_pg_size; 	/* 31:16->entry size */
+					/* 15:0 ->page size */
+	u32 int_blk_n_cns_ptr;	/* 31:24->Int Blk Id;  */
+					/* 23:16->Int Blk Offset */
+					/* 15:0 ->consumer pointer(index?) */
+	u32 cns_ptr2_n_q_state;	/* 31:16->cons. ptr 2; 15:0-> Q state */
+	u32 nxt_qid_n_fid_n_pri;	/* 17:10->next */
+					/* QId;9:3->FID;2:0->Priority */
+	u32 wvc_n_cquota_n_rquota; /* 31:24->WI Vector Count; */
+					/* 23:12->Cfg Quota; */
+					/* 11:0 ->Run Quota */
+	u32 reserved3[4];
+};
+
+struct bna_rxq_mem {
+	u32 pg_tbl_addr_lo;
+	u32 pg_tbl_addr_hi;
+	u32 cur_q_entry_lo;
+	u32 cur_q_entry_hi;
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;	/* 31:16->total page count */
+					/* 15:0 ->producer pointer (index?) */
+	u32 entry_n_pg_size;	/* 31:16->entry size */
+					/* 15:0 ->page size */
+	u32 sg_n_cq_n_cns_ptr;	/* 31:28->reserved; 27:24->sg count */
+					/* 23:16->CQ; */
+					/* 15:0->consumer pointer(index?) */
+	u32 buf_sz_n_q_state; 	/* 31:16->buffer size; 15:0-> Q state */
+	u32 next_qid;		/* 17:10->next QId */
+	u32 reserved3;
+	u32 reserved4[4];
+};
+
+struct bna_rxtx_q_mem {
+	struct bna_rxq_mem rxq;
+	struct bna_txq_mem txq;
+};
+
+struct bna_cq_mem {
+	u32 pg_tbl_addr_lo;
+	u32 pg_tbl_addr_hi;
+	u32 cur_q_entry_lo;
+	u32 cur_q_entry_hi;
+
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;	/* 31:16->total page count */
+					/* 15:0 ->producer pointer (index?) */
+	u32 entry_n_pg_size;	/* 31:16->entry size */
+					/* 15:0 ->page size */
+	u32 int_blk_n_cns_ptr;	/* 31:24->Int Blk Id; */
+					/* 23:16->Int Blk Offset */
+					/* 15:0 ->consumer pointer(index?) */
+	u32 q_state;		/* 31:16->reserved; 15:0-> Q state */
+	u32 reserved3[2];
+	u32 reserved4[4];
+};
+
+struct bna_ib_blk_mem {
+	u32 host_addr_lo;
+	u32 host_addr_hi;
+	u32 clsc_n_ctrl_n_msix;	/* 31:24->coalescing; */
+					/* 23:16->coalescing cfg; */
+					/* 15:8 ->control; */
+					/* 7:0 ->msix; */
+	u32 ipkt_n_ent_n_idxof;
+	u32 ipkt_cnt_cfg_n_unacked;
+
+	u32 reserved[3];
+};
+
+struct bna_idx_tbl_mem {
+	u32 idx;	  /* !< 31:16->res;15:0->idx; */
+};
+
+struct bna_doorbell_qset {
+	u32 rxq[0x20 >> 2];
+	u32 txq[0x20 >> 2];
+	u32 ib0[0x20 >> 2];
+	u32 ib1[0x20 >> 2];
+};
+
+struct bna_rx_fndb_ram {
+	u32 rss_prop;
+	u32 size_routing_props;
+	u32 rit_hds_mcastq;
+	u32 control_flags;
+};
+
+struct bna_tx_fndb_ram {
+	u32 vlan_n_ctrl_flags;
+};
+
+/**
+ * @brief
+ *  Structure which maps to RxFn Indirection Table (RIT)
+ *  Size : 1 word
+ *  See catapult_spec.pdf, RxA for details
+ */
+struct bna_rit_mem {
+	u32 rxq_ids;	/* !< 31:12->res;11:0->two 6 bit RxQ Ids */
+};
+
+/**
+ * @brief
+ *  Structure which maps to RSS Table entry
+ *  Size : 16 words
+ *  See catapult_spec.pdf, RAD for details
+ */
+struct bna_rss_mem {
+	/*
+	 * 31:12-> res
+	 * 11:8 -> protocol type
+	 *  7:0 -> hash index
+	 */
+	u32 type_n_hash;
+	u32 hash_key[10];  /* !< 40 byte Toeplitz hash key */
+	u32 reserved[5];
+};
+
+/* TxQ Vector (a.k.a. Tx-Buffer Descriptor) */
+struct bna_dma_addr {
+	u32		msb;
+	u32		lsb;
+};
+
+struct bna_txq_wi_vector {
+	u16 		reserved;
+	u16 		length;		/* Only 14 LSB are valid */
+	struct bna_dma_addr host_addr; /* Tx-Buf DMA addr */
+};
+
+typedef u16 bna_txq_wi_opcode_t;
+
+typedef u16 bna_txq_wi_ctrl_flag_t;
+
+/**
+ *  TxQ Entry Structure
+ *
+ *  BEWARE:  Load values into this structure with correct endianess.
+ */
+struct bna_txq_entry {
+	union {
+		struct {
+			u8 reserved;
+			u8 num_vectors;	/* number of vectors present */
+			bna_txq_wi_opcode_t opcode; /* Either */
+						    /* BNA_TXQ_WI_SEND or */
+						    /* BNA_TXQ_WI_SEND_LSO */
+			bna_txq_wi_ctrl_flag_t flags; /* OR of all the flags */
+			u16 l4_hdr_size_n_offset;
+			u16 vlan_tag;
+			u16 lso_mss;	/* Only 14 LSB are valid */
+			u32 frame_length;	/* Only 24 LSB are valid */
+		} wi;
+
+		struct {
+			u16 reserved;
+			bna_txq_wi_opcode_t opcode; /* Must be */
+						    /* BNA_TXQ_WI_EXTENSION */
+			u32 reserved2[3];	/* Place holder for */
+						/* removed vector (12 bytes) */
+		} wi_ext;
+	} hdr;
+	struct bna_txq_wi_vector vector[4];
+};
+#define wi_hdr  	hdr.wi
+#define wi_ext_hdr  hdr.wi_ext
+
+/* RxQ Entry Structure */
+struct bna_rxq_entry {		/* Rx-Buffer */
+	struct bna_dma_addr host_addr; /* Rx-Buffer DMA address */
+};
+
+typedef u32 bna_cq_e_flag_t;
+
+/* CQ Entry Structure */
+struct bna_cq_entry {
+	bna_cq_e_flag_t flags;
+	u16 vlan_tag;
+	u16 length;
+	u32 rss_hash;
+	u8 valid;
+	u8 reserved1;
+	u8 reserved2;
+	u8 rxq_id;
+};
+
+#endif /* __BNA_HW_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bna_types.h net-next-2.6.35-rc1-mod/drivers/net/bna/bna_types.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bna_types.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bna_types.h	2010-08-02 17:19:19.864227000 -0700
@@ -0,0 +1,1135 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+#ifndef __BNA_TYPES_H__
+#define __BNA_TYPES_H__
+
+#include "cna.h"
+#include "bna_hw.h"
+#include "bfa_cee.h"
+
+/**
+ *
+ * Forward declarations
+ *
+ */
+
+struct bna_txq;
+struct bna_tx;
+struct bna_rxq;
+struct bna_cq;
+struct bna_rx;
+struct bna_rxf;
+struct bna_port;
+struct bna;
+struct bnad;
+
+/**
+ *
+ * Enums, primitive data types
+ *
+ */
+
+enum bna_status {
+	BNA_STATUS_T_DISABLED	= 0,
+	BNA_STATUS_T_ENABLED	= 1
+};
+
+enum bna_cleanup_type {
+	BNA_HARD_CLEANUP 	= 0,
+	BNA_SOFT_CLEANUP 	= 1
+};
+
+enum bna_cb_status {
+	BNA_CB_SUCCESS 		= 0,
+	BNA_CB_FAIL		= 1,
+	BNA_CB_INTERRUPT	= 2,
+	BNA_CB_BUSY		= 3,
+	BNA_CB_INVALID_MAC	= 4,
+	BNA_CB_MCAST_LIST_FULL	= 5,
+	BNA_CB_UCAST_CAM_FULL	= 6,
+	BNA_CB_WAITING		= 7,
+	BNA_CB_NOT_EXEC		= 8
+};
+
+enum bna_res_type {
+	BNA_RES_T_MEM		= 1,
+	BNA_RES_T_INTR		= 2
+};
+
+enum bna_mem_type {
+	BNA_MEM_T_KVA 		= 1,
+	BNA_MEM_T_DMA 		= 2
+};
+
+enum bna_intr_type {
+	BNA_INTR_T_INTX		= 1,
+	BNA_INTR_T_MSIX		= 2
+};
+
+enum bna_res_req_type {
+	BNA_RES_MEM_T_COM 		= 0,
+	BNA_RES_MEM_T_ATTR 		= 1,
+	BNA_RES_MEM_T_FWTRC 		= 2,
+	BNA_RES_MEM_T_STATS 		= 3,
+	BNA_RES_MEM_T_SWSTATS		= 4,
+	BNA_RES_MEM_T_IBIDX		= 5,
+	BNA_RES_MEM_T_IB_ARRAY		= 6,
+	BNA_RES_MEM_T_INTR_ARRAY	= 7,
+	BNA_RES_MEM_T_IDXSEG_ARRAY	= 8,
+	BNA_RES_MEM_T_TX_ARRAY		= 9,
+	BNA_RES_MEM_T_TXQ_ARRAY		= 10,
+	BNA_RES_MEM_T_RX_ARRAY		= 11,
+	BNA_RES_MEM_T_RXP_ARRAY		= 12,
+	BNA_RES_MEM_T_RXQ_ARRAY		= 13,
+	BNA_RES_MEM_T_UCMAC_ARRAY	= 14,
+	BNA_RES_MEM_T_MCMAC_ARRAY	= 15,
+	BNA_RES_MEM_T_RIT_ENTRY		= 16,
+	BNA_RES_MEM_T_RIT_SEGMENT	= 17,
+	BNA_RES_INTR_T_MBOX		= 18,
+	BNA_RES_T_MAX
+};
+
+enum bna_tx_res_req_type {
+	BNA_TX_RES_MEM_T_TCB	= 0,
+	BNA_TX_RES_MEM_T_UNMAPQ	= 1,
+	BNA_TX_RES_MEM_T_QPT 	= 2,
+	BNA_TX_RES_MEM_T_SWQPT	= 3,
+	BNA_TX_RES_MEM_T_PAGE 	= 4,
+	BNA_TX_RES_INTR_T_TXCMPL = 5,
+	BNA_TX_RES_T_MAX,
+};
+
+enum bna_rx_mem_type {
+	BNA_RX_RES_MEM_T_CCB		= 0,	/* CQ context */
+	BNA_RX_RES_MEM_T_RCB		= 1,	/* CQ context */
+	BNA_RX_RES_MEM_T_UNMAPQ		= 2,	/* UnmapQ for RxQs */
+	BNA_RX_RES_MEM_T_CQPT		= 3,	/* CQ QPT */
+	BNA_RX_RES_MEM_T_CSWQPT		= 4,	/* S/W QPT */
+	BNA_RX_RES_MEM_T_CQPT_PAGE	= 5,	/* CQPT page */
+	BNA_RX_RES_MEM_T_HQPT		= 6,	/* RX QPT */
+	BNA_RX_RES_MEM_T_DQPT		= 7,	/* RX QPT */
+	BNA_RX_RES_MEM_T_HSWQPT		= 8,	/* RX s/w QPT */
+	BNA_RX_RES_MEM_T_DSWQPT		= 9,	/* RX s/w QPT */
+	BNA_RX_RES_MEM_T_DPAGE		= 10,	/* RX s/w QPT */
+	BNA_RX_RES_MEM_T_HPAGE		= 11,	/* RX s/w QPT */
+	BNA_RX_RES_T_INTR		= 12,	/* Rx interrupts */
+	BNA_RX_RES_T_MAX		= 13
+};
+
+enum bna_mbox_state {
+	BNA_MBOX_FREE		= 0,
+	BNA_MBOX_POSTED		= 1
+};
+
+enum bna_tx_type {
+	BNA_TX_T_REGULAR	= 0,
+	BNA_TX_T_LOOPBACK	= 1,
+};
+
+enum bna_tx_flags {
+	BNA_TX_F_PORT_STARTED	= 1,
+	BNA_TX_F_ENABLED	= 2,
+	BNA_TX_F_PRIO_LOCK	= 4,
+};
+
+enum bna_tx_mod_flags {
+	BNA_TX_MOD_F_PORT_STARTED	= 1,
+	BNA_TX_MOD_F_PORT_LOOPBACK	= 2,
+};
+
+enum bna_rx_type {
+	BNA_RX_T_REGULAR	= 0,
+	BNA_RX_T_LOOPBACK	= 1,
+};
+
+enum bna_rxp_type {
+	BNA_RXP_SINGLE 		= 1,
+	BNA_RXP_SLR 		= 2,
+	BNA_RXP_HDS 		= 3
+};
+
+enum bna_rxmode {
+	BNA_RXMODE_PROMISC 	= 1,
+	BNA_RXMODE_DEFAULT 	= 2,
+	BNA_RXMODE_ALLMULTI 	= 4
+};
+
+enum bna_rx_event {
+	RX_E_START			= 1,
+	RX_E_STOP			= 2,
+	RX_E_FAIL			= 3,
+	RX_E_RXF_STARTED		= 4,
+	RX_E_RXF_STOPPED		= 5,
+	RX_E_RXQ_STOPPED		= 6,
+};
+
+enum bna_rx_state {
+	BNA_RX_STOPPED			= 1,
+	BNA_RX_RXF_START_WAIT		= 2,
+	BNA_RX_STARTED			= 3,
+	BNA_RX_RXF_STOP_WAIT		= 4,
+	BNA_RX_RXQ_STOP_WAIT		= 5,
+};
+
+enum bna_rx_flags {
+	BNA_RX_F_ENABLE		= 0x01,		/* bnad enabled rxf */
+	BNA_RX_F_PORT_ENABLED	= 0x02,		/* Port object is enabled */
+	BNA_RX_F_PORT_FAILED	= 0x04,		/* Port in failed state */
+};
+
+enum bna_rx_mod_flags {
+	BNA_RX_MOD_F_PORT_STARTED	= 1,
+	BNA_RX_MOD_F_PORT_LOOPBACK	= 2,
+};
+
+enum bna_rxf_oper_state {
+	BNA_RXF_OPER_STATE_RUNNING	= 0x01, /* rxf operational */
+	BNA_RXF_OPER_STATE_PAUSED	= 0x02,	/* rxf in PAUSED state */
+};
+
+enum bna_rxf_flags {
+	BNA_RXF_FL_STOP_PENDING 	= 0x01,
+	BNA_RXF_FL_FAILED		= 0x02,
+	BNA_RXF_FL_RSS_CONFIG_PENDING	= 0x04,
+	BNA_RXF_FL_OPERSTATE_CHANGED	= 0x08,
+	BNA_RXF_FL_RXF_ENABLED		= 0x10,
+	BNA_RXF_FL_VLAN_CONFIG_PENDING	= 0x20,
+};
+
+enum bna_rxf_event {
+	RXF_E_START			= 1,
+	RXF_E_STOP			= 2,
+	RXF_E_FAIL			= 3,
+	RXF_E_CAM_FLTR_MOD		= 4,
+	RXF_E_STARTED			= 5,
+	RXF_E_STOPPED			= 6,
+	RXF_E_CAM_FLTR_RESP		= 7,
+	RXF_E_PAUSE			= 8,
+	RXF_E_RESUME			= 9,
+	RXF_E_STAT_CLEARED		= 10,
+};
+
+enum bna_rxf_state {
+	BNA_RXF_STOPPED			= 1,
+	BNA_RXF_START_WAIT		= 2,
+	BNA_RXF_CAM_FLTR_MOD_WAIT	= 3,
+	BNA_RXF_STARTED			= 4,
+	BNA_RXF_CAM_FLTR_CLR_WAIT	= 5,
+	BNA_RXF_STOP_WAIT		= 6,
+	BNA_RXF_PAUSE_WAIT		= 7,
+	BNA_RXF_RESUME_WAIT		= 8,
+	BNA_RXF_STAT_CLR_WAIT		= 9,
+};
+
+enum bna_port_type {
+	BNA_PORT_T_REGULAR		= 0,
+	BNA_PORT_T_LOOPBACK_INTERNAL	= 1,
+	BNA_PORT_T_LOOPBACK_EXTERNAL	= 2,
+};
+
+enum bna_link_status {
+	BNA_LINK_DOWN		= 0,
+	BNA_LINK_UP		= 1,
+	BNA_CEE_UP 		= 2
+};
+
+enum bna_llport_flags {
+	BNA_LLPORT_F_ENABLED 	= 1,
+	BNA_LLPORT_F_RX_ENABLED	= 2
+};
+
+enum bna_port_flags {
+	BNA_PORT_F_DEVICE_READY	= 1,
+	BNA_PORT_F_ENABLED	= 2,
+	BNA_PORT_F_PAUSE_CHANGED = 4,
+	BNA_PORT_F_MTU_CHANGED	= 8
+};
+
+enum bna_pkt_rates {
+	BNA_PKT_RATE_10K		= 10000,
+	BNA_PKT_RATE_20K		= 20000,
+	BNA_PKT_RATE_30K		= 30000,
+	BNA_PKT_RATE_40K		= 40000,
+	BNA_PKT_RATE_50K		= 50000,
+	BNA_PKT_RATE_60K		= 60000,
+	BNA_PKT_RATE_70K		= 70000,
+	BNA_PKT_RATE_80K		= 80000,
+};
+
+enum bna_dim_load_types {
+	BNA_LOAD_T_HIGH_4		= 0, /* 80K <= r */
+	BNA_LOAD_T_HIGH_3		= 1, /* 60K <= r < 80K */
+	BNA_LOAD_T_HIGH_2		= 2, /* 50K <= r < 60K */
+	BNA_LOAD_T_HIGH_1		= 3, /* 40K <= r < 50K */
+	BNA_LOAD_T_LOW_1		= 4, /* 30K <= r < 40K */
+	BNA_LOAD_T_LOW_2		= 5, /* 20K <= r < 30K */
+	BNA_LOAD_T_LOW_3		= 6, /* 10K <= r < 20K */
+	BNA_LOAD_T_LOW_4		= 7, /* r < 10K */
+	BNA_LOAD_T_MAX			= 8
+};
+
+enum bna_dim_bias_types {
+	BNA_BIAS_T_SMALL		= 0, /* small pkts > (large pkts * 2) */
+	BNA_BIAS_T_LARGE		= 1, /* Not BNA_BIAS_T_SMALL */
+	BNA_BIAS_T_MAX			= 2
+};
+
+#define BNA_MAX_NAME_SIZE	64
+struct bna_ident {
+	int 			id;
+	char			name[BNA_MAX_NAME_SIZE];
+};
+
+struct bna_mac {
+	/* This should be the first one */
+	struct list_head			qe;
+	u8			addr[ETH_ALEN];
+};
+
+struct bna_mem_descr {
+	u32		len;
+	void		*kva;
+	struct bna_dma_addr dma;
+};
+
+struct bna_mem_info {
+	enum bna_mem_type mem_type;
+	u32		len;
+	u32 		num;
+	u32		align_sz; /* 0/1 = no alignment */
+	struct bna_mem_descr *mdl;
+	void			*cookie; /* For bnad to unmap dma later */
+};
+
+struct bna_intr_descr {
+	int			vector;
+};
+
+struct bna_intr_info {
+	enum bna_intr_type intr_type;
+	int			num;
+	struct bna_intr_descr *idl;
+};
+
+union bna_res_u {
+	struct bna_mem_info mem_info;
+	struct bna_intr_info intr_info;
+};
+
+struct bna_res_info {
+	enum bna_res_type res_type;
+	union bna_res_u		res_u;
+};
+
+/* HW QPT */
+struct bna_qpt {
+	struct bna_dma_addr hw_qpt_ptr;
+	void		*kv_qpt_ptr;
+	u32		page_count;
+	u32		page_size;
+};
+
+/**
+ *
+ * Device
+ *
+ */
+
+struct bna_device {
+	bfa_fsm_t		fsm;
+	struct bfa_ioc ioc;
+
+	enum bna_intr_type intr_type;
+	int			vector;
+
+	void (*ready_cbfn)(struct bnad *bnad, enum bna_cb_status status);
+	struct bnad *ready_cbarg;
+
+	void (*stop_cbfn)(struct bnad *bnad, enum bna_cb_status status);
+	struct bnad *stop_cbarg;
+
+	struct bna *bna;
+};
+
+/**
+ *
+ * Mail box
+ *
+ */
+
+struct bna_mbox_qe {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	struct bfa_mbox_cmd cmd;
+	u32 		cmd_len;
+	/* Callback for port, tx, rx, rxf */
+	void (*cbfn)(void *arg, int status);
+	void 			*cbarg;
+};
+
+struct bna_mbox_mod {
+	enum bna_mbox_state state;
+	struct list_head			posted_q;
+	u32		msg_pending;
+	u32		msg_ctr;
+	struct bna *bna;
+};
+
+/**
+ *
+ * Port
+ *
+ */
+
+/* Pause configuration */
+struct bna_pause_config {
+	enum bna_status tx_pause;
+	enum bna_status rx_pause;
+};
+
+struct bna_llport {
+	bfa_fsm_t		fsm;
+	enum bna_llport_flags flags;
+
+	enum bna_port_type type;
+
+	enum bna_link_status link_status;
+
+	int			admin_up_count;
+
+	void (*stop_cbfn)(struct bna_port *, enum bna_cb_status);
+
+	struct bna_mbox_qe mbox_qe;
+
+	struct bna *bna;
+};
+
+struct bna_port {
+	bfa_fsm_t		fsm;
+	enum bna_port_flags flags;
+
+	enum bna_port_type type;
+
+	struct bna_llport llport;
+
+	struct bna_pause_config pause_config;
+	u8			priority;
+	int			mtu;
+
+	/* Callback for bna_port_disable(), port_stop() */
+	void (*stop_cbfn)(void *, enum bna_cb_status);
+	void			*stop_cbarg;
+
+	/* Callback for bna_port_pause_config() */
+	void (*pause_cbfn)(struct bnad *, enum bna_cb_status);
+
+	/* Callback for bna_port_mtu_set() */
+	void (*mtu_cbfn)(struct bnad *, enum bna_cb_status);
+
+	void (*link_cbfn)(struct bnad *, enum bna_link_status);
+
+	struct bfa_wc		chld_stop_wc;
+
+	struct bna_mbox_qe mbox_qe;
+
+	struct bna *bna;
+};
+
+/**
+ *
+ * Interrupt Block
+ *
+ */
+
+/* IB index segment structure */
+struct bna_ibidx_seg {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	u8			ib_seg_size;
+	u8			ib_idx_tbl_offset;
+};
+
+/* Interrupt structure */
+struct bna_intr {
+	/* This should be the first one */
+	struct list_head			qe;
+	int			ref_count;
+
+	enum bna_intr_type intr_type;
+	int			vector;
+
+	struct bna_ib *ib;
+};
+
+/* Doorbell structure */
+struct bna_ib_dbell {
+	void *__iomem doorbell_addr;
+	u32		doorbell_ack;
+};
+
+/* Interrupt timer configuration */
+struct bna_ib_config {
+	u8 		coalescing_timeo;    /* Unit is 5usec. */
+
+	int			interpkt_count;
+	int			interpkt_timeo;
+
+	enum ib_flags ctrl_flags;
+};
+
+/* IB structure */
+struct bna_ib {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	int			ib_id;
+
+	int			ref_count;
+	int			start_count;
+
+	struct bna_dma_addr ib_seg_host_addr;
+	void		*ib_seg_host_addr_kva;
+	u32		idx_mask; /* Size >= BNA_IBIDX_MAX_SEGSIZE */
+
+	struct bna_ibidx_seg *idx_seg;
+
+	struct bna_ib_dbell door_bell;
+
+	struct bna_intr *intr;
+
+	struct bna_ib_config ib_config;
+
+	struct bna *bna;
+};
+
+/* IB module - keeps track of IBs and interrupts */
+struct bna_ib_mod {
+	struct bna_ib *ib;		/* BFI_MAX_IB entries */
+	struct bna_intr *intr;		/* BFI_MAX_IB entries */
+	struct bna_ibidx_seg *idx_seg;	/* BNA_IBIDX_TOTAL_SEGS */
+
+	struct list_head			ib_free_q;
+
+	struct list_head		ibidx_seg_pool[BFI_IBIDX_TOTAL_POOLS];
+
+	struct list_head			intr_free_q;
+	struct list_head			intr_active_q;
+
+	struct bna *bna;
+};
+
+/**
+ *
+ * Tx object
+ *
+ */
+
+/* Tx datapath control structure */
+#define BNA_Q_NAME_SIZE		16
+struct bna_tcb {
+	/* Fast path */
+	void			**sw_qpt;
+	void			*unmap_q;
+	u32		producer_index;
+	u32		consumer_index;
+	volatile u32	*hw_consumer_index;
+	u32		q_depth;
+	void *__iomem q_dbell;
+	struct bna_ib_dbell *i_dbell;
+	int			page_idx;
+	int			page_count;
+	/* Control path */
+	struct bna_txq *txq;
+	struct bnad *bnad;
+	enum bna_intr_type intr_type;
+	int			intr_vector;
+	u8			priority; /* Current priority */
+	unsigned long		flags; /* Used by bnad as required */
+	int			id;
+	char			name[BNA_Q_NAME_SIZE];
+};
+
+/* TxQ QPT and configuration */
+struct bna_txq {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	int			txq_id;
+
+	u8			priority;
+
+	struct bna_qpt qpt;
+	struct bna_tcb *tcb;
+	struct bna_ib *ib;
+	int			ib_seg_offset;
+
+	struct bna_tx *tx;
+
+	u64 		tx_packets;
+	u64 		tx_bytes;
+};
+
+/* TxF structure (hardware Tx Function) */
+struct bna_txf {
+	int			txf_id;
+	enum txf_flags ctrl_flags;
+	u16		vlan;
+};
+
+/* Tx object */
+struct bna_tx {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	bfa_fsm_t		fsm;
+	enum bna_tx_flags flags;
+
+	enum bna_tx_type type;
+
+	struct list_head			txq_q;
+	struct bna_txf txf;
+
+	/* Tx event handlers */
+	void (*tcb_setup_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tcb_destroy_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_stall_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_resume_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_cleanup_cbfn)(struct bnad *, struct bna_tcb *);
+
+	/* callback for bna_tx_disable(), bna_tx_stop() */
+	void (*stop_cbfn)(void *arg, struct bna_tx *tx,
+				enum bna_cb_status status);
+	void			*stop_cbarg;
+
+	/* callback for bna_tx_prio_set() */
+	void (*prio_change_cbfn)(struct bnad *bnad, struct bna_tx *tx,
+				enum bna_cb_status status);
+
+	struct bfa_wc		txq_stop_wc;
+
+	struct bna_mbox_qe mbox_qe;
+
+	struct bna *bna;
+	void			*priv;	/* bnad's cookie */
+};
+
+struct bna_tx_config {
+	int			num_txq;
+	int			txq_depth;
+	enum bna_tx_type tx_type;
+};
+
+struct bna_tx_event_cbfn {
+	/* Optional */
+	void (*tcb_setup_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tcb_destroy_cbfn)(struct bnad *, struct bna_tcb *);
+	/* Mandatory */
+	void (*tx_stall_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_resume_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_cleanup_cbfn)(struct bnad *, struct bna_tcb *);
+};
+
+/* Tx module - keeps track of free, active tx objects */
+struct bna_tx_mod {
+	struct bna_tx *tx;		/* BFI_MAX_TXQ entries */
+	struct bna_txq *txq;		/* BFI_MAX_TXQ entries */
+
+	struct list_head			tx_free_q;
+	struct list_head			tx_active_q;
+
+	struct list_head			txq_free_q;
+
+	/* callback for bna_tx_mod_stop() */
+	void (*stop_cbfn)(struct bna_port *port,
+				enum bna_cb_status status);
+
+	struct bfa_wc		tx_stop_wc;
+
+	enum bna_tx_mod_flags flags;
+
+	int			priority;
+	int			cee_link;
+
+	u32		txf_bmap[2];
+
+	struct bna *bna;
+};
+
+/**
+ *
+ * Receive Indirection Table
+ *
+ */
+
+/* One row of RIT table */
+struct bna_rit_entry {
+	u8 large_rxq_id;	/* used for either large or data buffers */
+	u8 small_rxq_id;	/* used for either small or header buffers */
+};
+
+/* RIT segment */
+struct bna_rit_segment {
+	struct list_head			qe;
+
+	u32		rit_offset;
+	u32		rit_size;
+	/**
+	 * max_rit_size: Varies per RIT segment depending on how RIT is
+	 * partitioned
+	 */
+	u32		max_rit_size;
+
+	struct bna_rit_entry *rit;
+};
+
+struct bna_rit_mod {
+	struct bna_rit_entry *rit;
+	struct bna_rit_segment *rit_segment;
+
+	struct list_head		rit_seg_pool[BFI_RIT_SEG_TOTAL_POOLS];
+};
+
+/**
+ *
+ * Rx object
+ *
+ */
+
+/* Rx datapath control structure */
+struct bna_rcb {
+	/* Fast path */
+	void			**sw_qpt;
+	void			*unmap_q;
+	u32		producer_index;
+	u32		consumer_index;
+	u32		q_depth;
+	void *__iomem q_dbell;
+	int			page_idx;
+	int			page_count;
+	/* Control path */
+	struct bna_rxq *rxq;
+	struct bna_cq *cq;
+	struct bnad *bnad;
+	unsigned long		flags;
+	int			id;
+};
+
+/* RxQ structure - QPT, configuration */
+struct bna_rxq {
+	struct list_head			qe;
+	int			rxq_id;
+
+	int			buffer_size;
+	int			q_depth;
+
+	struct bna_qpt qpt;
+	struct bna_rcb *rcb;
+
+	struct bna_rxp *rxp;
+	struct bna_rx *rx;
+
+	u64 		rx_packets;
+	u64		rx_bytes;
+	u64 		rx_packets_with_error;
+	u64 		rxbuf_alloc_failed;
+};
+
+/* RxQ pair */
+union bna_rxq_u {
+	struct {
+		struct bna_rxq *hdr;
+		struct bna_rxq *data;
+	} hds;
+	struct {
+		struct bna_rxq *small;
+		struct bna_rxq *large;
+	} slr;
+	struct {
+		struct bna_rxq *only;
+		struct bna_rxq *reserved;
+	} single;
+};
+
+/* Packet rate for Dynamic Interrupt Moderation */
+struct bna_pkt_rate {
+	u32		small_pkt_cnt;
+	u32		large_pkt_cnt;
+};
+
+/* Completion control structure */
+struct bna_ccb {
+	/* Fast path */
+	void			**sw_qpt;
+	u32		producer_index;
+	volatile u32	*hw_producer_index;
+	u32		q_depth;
+	struct bna_ib_dbell *i_dbell;
+	struct bna_rcb *rcb[2];
+	void			*ctrl; /* For bnad */
+	struct bna_pkt_rate pkt_rate;
+	int			page_idx;
+	int			page_count;
+
+	/* Control path */
+	struct bna_cq *cq;
+	struct bnad *bnad;
+	enum bna_intr_type intr_type;
+	int			intr_vector;
+	u8			rx_coalescing_timeo; /* For NAPI */
+	int			id;
+	char			name[BNA_Q_NAME_SIZE];
+};
+
+/* CQ QPT, configuration  */
+struct bna_cq {
+	int			cq_id;
+
+	struct bna_qpt qpt;
+	struct bna_ccb *ccb;
+
+	struct bna_ib *ib;
+	u8			ib_seg_offset;
+
+	struct bna_rx *rx;
+};
+
+struct bna_rss_config {
+	enum rss_hash_type hash_type;
+	u8			hash_mask;
+	u32		toeplitz_hash_key[BFI_RSS_HASH_KEY_LEN];
+};
+
+struct bna_hds_config {
+	enum hds_header_type hdr_type;
+	int			header_size;
+};
+
+/* This structure is used during RX creation */
+struct bna_rx_config {
+	enum bna_rx_type rx_type;
+	int			num_paths;
+	enum bna_rxp_type rxp_type;
+	int			paused;
+	int			q_depth;
+	/*
+	 * Small/Large (or Header/Data) buffer size to be configured
+	 * for SLR and HDS queue type. Large buffer size comes from
+	 * port->mtu.
+	 */
+	int			small_buff_size;
+
+	enum bna_status rss_status;
+	struct bna_rss_config rss_config;
+
+	enum bna_status hds_status;
+	struct bna_hds_config hds_config;
+
+	enum bna_status vlan_strip_status;
+};
+
+/* Rx Path structure - one per MSIX vector/CPU */
+struct bna_rxp {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	enum bna_rxp_type type;
+	union	bna_rxq_u	rxq;
+	struct bna_cq cq;
+
+	struct bna_rx *rx;
+
+	/* MSI-x vector number for configuring RSS */
+	int			vector;
+
+	struct bna_mbox_qe mbox_qe;
+};
+
+/* HDS configuration structure */
+struct bna_rxf_hds {
+	enum hds_header_type hdr_type;
+	int			header_size;
+};
+
+/* RSS configuration structure */
+struct bna_rxf_rss {
+	enum rss_hash_type hash_type;
+	u8			hash_mask;
+	u32		toeplitz_hash_key[BFI_RSS_HASH_KEY_LEN];
+};
+
+/* RxF structure (hardware Rx Function) */
+struct bna_rxf {
+	bfa_fsm_t		fsm;
+	int			rxf_id;
+	enum rxf_flags ctrl_flags;
+	u16		default_vlan_tag;
+	enum bna_rxf_oper_state rxf_oper_state;
+	enum bna_status hds_status;
+	struct bna_rxf_hds hds_cfg;
+	enum bna_status rss_status;
+	struct bna_rxf_rss rss_cfg;
+	struct bna_rit_segment *rit_segment;
+	struct bna_rx *rx;
+	u32		forced_offset;
+	struct bna_mbox_qe mbox_qe;
+	int			mcast_rxq_id;
+
+	/* callback for bna_rxf_start() */
+	void (*start_cbfn) (struct bna_rx *rx, enum bna_cb_status status);
+	struct bna_rx *start_cbarg;
+
+	/* callback for bna_rxf_stop() */
+	void (*stop_cbfn) (struct bna_rx *rx, enum bna_cb_status status);
+	struct bna_rx *stop_cbarg;
+
+	/* callback for bna_rxf_receive_enable() / bna_rxf_receive_disable() */
+	void (*oper_state_cbfn) (struct bnad *bnad, struct bna_rx *rx,
+			enum bna_cb_status status);
+	struct bnad *oper_state_cbarg;
+
+	/**
+	 * callback for:
+	 *	bna_rxf_ucast_set()
+	 *	bna_rxf_{ucast/mcast}_add(),
+	 * 	bna_rxf_{ucast/mcast}_del(),
+	 *	bna_rxf_mode_set()
+	 */
+	void (*cam_fltr_cbfn)(struct bnad *bnad, struct bna_rx *rx,
+				enum bna_cb_status status);
+	struct bnad *cam_fltr_cbarg;
+
+	enum bna_rxf_flags rxf_flags;
+
+	/* List of unicast addresses yet to be applied to h/w */
+	struct list_head			ucast_pending_add_q;
+	struct list_head			ucast_pending_del_q;
+	int			ucast_pending_set;
+	/* ucast addresses applied to the h/w */
+	struct list_head			ucast_active_q;
+	struct bna_mac *ucast_active_mac;
+
+	/* List of multicast addresses yet to be applied to h/w */
+	struct list_head			mcast_pending_add_q;
+	struct list_head			mcast_pending_del_q;
+	/* multicast addresses applied to the h/w */
+	struct list_head			mcast_active_q;
+
+	/* Rx modes yet to be applied to h/w */
+	enum bna_rxmode rxmode_pending;
+	enum bna_rxmode rxmode_pending_bitmask;
+	/* Rx modes applied to h/w */
+	enum bna_rxmode rxmode_active;
+
+	enum bna_status vlan_filter_status;
+	u32		vlan_filter_table[(BFI_MAX_VLAN + 1) / 32];
+};
+
+/* Rx object */
+struct bna_rx {
+	/* This should be the first one */
+	struct list_head			qe;
+
+	bfa_fsm_t		fsm;
+
+	enum bna_rx_type type;
+
+	/* list-head for RX path objects */
+	struct list_head			rxp_q;
+
+	struct bna_rxf rxf;
+
+	enum bna_rx_flags rx_flags;
+
+	struct bna_mbox_qe mbox_qe;
+
+	struct bfa_wc		rxq_stop_wc;
+
+	/* Rx event handlers */
+	void (*rcb_setup_cbfn)(struct bnad *, struct bna_rcb *);
+	void (*rcb_destroy_cbfn)(struct bnad *, struct bna_rcb *);
+	void (*ccb_setup_cbfn)(struct bnad *, struct bna_ccb *);
+	void (*ccb_destroy_cbfn)(struct bnad *, struct bna_ccb *);
+	void (*rx_cleanup_cbfn)(struct bnad *, struct bna_ccb *);
+	void (*rx_post_cbfn)(struct bnad *, struct bna_rcb *);
+
+	/* callback for bna_rx_disable(), bna_rx_stop() */
+	void (*stop_cbfn)(void *arg, struct bna_rx *rx,
+				enum bna_cb_status status);
+	void			*stop_cbarg;
+
+	struct bna *bna;
+	void			*priv; /* bnad's cookie */
+};
+
+struct bna_rx_event_cbfn {
+	/* Optional */
+	void (*rcb_setup_cbfn)(struct bnad *, struct bna_rcb *);
+	void (*rcb_destroy_cbfn)(struct bnad *, struct bna_rcb *);
+	void (*ccb_setup_cbfn)(struct bnad *, struct bna_ccb *);
+	void (*ccb_destroy_cbfn)(struct bnad *, struct bna_ccb *);
+	/* Mandatory */
+	void (*rx_cleanup_cbfn)(struct bnad *, struct bna_ccb *);
+	void (*rx_post_cbfn)(struct bnad *, struct bna_rcb *);
+};
+
+/* Rx module - keeps track of free, active rx objects */
+struct bna_rx_mod {
+	struct bna *bna;		/* back pointer to parent */
+	struct bna_rx *rx;		/* BFI_MAX_RXQ entries */
+	struct bna_rxp *rxp;		/* BFI_MAX_RXQ entries */
+	struct bna_rxq *rxq;		/* BFI_MAX_RXQ entries */
+
+	struct list_head			rx_free_q;
+	struct list_head			rx_active_q;
+	int			rx_free_count;
+
+	struct list_head			rxp_free_q;
+	int			rxp_free_count;
+
+	struct list_head			rxq_free_q;
+	int			rxq_free_count;
+
+	enum bna_rx_mod_flags flags;
+
+	/* callback for bna_rx_mod_stop() */
+	void (*stop_cbfn)(struct bna_port *port,
+				enum bna_cb_status status);
+
+	struct bfa_wc		rx_stop_wc;
+	u32		dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX];
+	u32		rxf_bmap[2];
+};
+
+/**
+ *
+ * CAM
+ *
+ */
+
+struct bna_ucam_mod {
+	struct bna_mac *ucmac;		/* BFI_MAX_UCMAC entries */
+	struct list_head			free_q;
+
+	struct bna *bna;
+};
+
+struct bna_mcam_mod {
+	struct bna_mac *mcmac;		/* BFI_MAX_MCMAC entries */
+	struct list_head			free_q;
+
+	struct bna *bna;
+};
+
+/**
+ *
+ * Statistics
+ *
+ */
+
+struct bna_tx_stats {
+	int			tx_state;
+	int			tx_flags;
+	int			num_txqs;
+	u32		txq_bmap[2];
+	int			txf_id;
+};
+
+struct bna_rx_stats {
+	int			rx_state;
+	int			rx_flags;
+	int			num_rxps;
+	int			num_rxqs;
+	u32		rxq_bmap[2];
+	u32		cq_bmap[2];
+	int			rxf_id;
+	int			rxf_state;
+	int			rxf_oper_state;
+	int			num_active_ucast;
+	int			num_active_mcast;
+	int			rxmode_active;
+	int			vlan_filter_status;
+	u32		vlan_filter_table[(BFI_MAX_VLAN + 1) / 32];
+	int			rss_status;
+	int			hds_status;
+};
+
+struct bna_sw_stats {
+	int			device_state;
+	int			port_state;
+	int			port_flags;
+	int			llport_state;
+	int			priority;
+	int			num_active_tx;
+	int			num_active_rx;
+	struct bna_tx_stats tx_stats[BFI_MAX_TXQ];
+	struct bna_rx_stats rx_stats[BFI_MAX_RXQ];
+};
+
+struct bna_stats {
+	u32		txf_bmap[2];
+	u32		rxf_bmap[2];
+	struct bfi_ll_stats	*hw_stats;
+	struct bna_sw_stats *sw_stats;
+};
+
+/**
+ *
+ * BNA
+ *
+ */
+
+struct bna {
+	struct bna_ident ident;
+	struct bfa_pcidev pcidev;
+
+	int			port_num;
+
+	struct bna_chip_regs regs;
+
+	struct bna_dma_addr hw_stats_dma;
+	struct bna_stats stats;
+
+	struct bna_device device;
+	struct bfa_cee cee;
+
+	struct bna_mbox_mod mbox_mod;
+
+	struct bna_port port;
+
+	struct bna_tx_mod tx_mod;
+
+	struct bna_rx_mod rx_mod;
+
+	struct bna_ib_mod ib_mod;
+
+	struct bna_ucam_mod ucam_mod;
+	struct bna_mcam_mod mcam_mod;
+
+	struct bna_rit_mod rit_mod;
+
+	int			rxf_default_id;
+	int			rxf_promisc_id;
+
+	struct bna_mbox_qe mbox_qe;
+
+	struct bnad *bnad;
+};
+
+#endif	/* __BNA_TYPES_H__ */
