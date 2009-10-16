From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 3/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 11:24:56 -0700
Message-ID: <200910161824.n9GIOuiK010141@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:36259 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbZJPSaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 14:30:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 3/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.32

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bfa_cee.c     |  463 +++++++++++
 bfa_csdebug.c |   62 +
 bfa_ioc.c     | 2273 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 bfa_sm.c      |   45 +
 bna_if.c      |  588 +++++++++++++++
 bna_iocll.h   |   66 +
 bna_os.h      |  182 ++++
 bna_priv.h    |  490 ++++++++++++
 bnad_compat.h |  111 ++
 bnad_defs.h   |   36 
 cna.h         |   32 
 11 files changed, 4348 insertions(+)

diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_cee.c linux-2.6.32-rc4-mod/drivers/net/bna/bfa_cee.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_cee.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_cee.c	2009-10-16 10:30:53.404436000 -0700
@@ -0,0 +1,463 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#include <defs/bfa_defs_cee.h>
+#include <cs/bfa_debug.h>
+#include <cee/bfa_cee.h>
+#include <bfi/bfi_cee.h>
+#include <bfi/bfi.h>
+#include <bfa_ioc.h>
+
+
+#define bfa_ioc_portid(__ioc) ((__ioc)->port_id)
+#define bfa_lpuid(__arg) bfa_ioc_portid(&(__arg)->ioc)
+
+static void     bfa_cee_format_lldp_cfg(struct bfa_cee_lldp_cfg_s *lldp_cfg);
+static void     bfa_cee_format_dcbcx_stats(struct bfa_cee_dcbx_stats_s
+					   *dcbcx_stats);
+static void     bfa_cee_format_lldp_stats(struct bfa_cee_lldp_stats_s
+					  *lldp_stats);
+static void     bfa_cee_format_cfg_stats(struct bfa_cee_cfg_stats_s *cfg_stats);
+static void     bfa_cee_format_cee_cfg(void *buffer);
+static void     bfa_cee_format_cee_stats(void *buffer);
+
+static void
+bfa_cee_format_cee_stats(void *buffer)
+{
+	struct bfa_cee_stats_s *cee_stats = buffer;
+	bfa_cee_format_dcbcx_stats(&cee_stats->dcbx_stats);
+	bfa_cee_format_lldp_stats(&cee_stats->lldp_stats);
+	bfa_cee_format_cfg_stats(&cee_stats->cfg_stats);
+}
+
+static void
+bfa_cee_format_cee_cfg(void *buffer)
+{
+	struct bfa_cee_attr_s *cee_cfg = buffer;
+	bfa_cee_format_lldp_cfg(&cee_cfg->lldp_remote);
+}
+
+static void
+bfa_cee_format_dcbcx_stats(struct bfa_cee_dcbx_stats_s *dcbcx_stats)
+{
+	dcbcx_stats->subtlvs_unrecognized =
+		bfa_os_ntohl(dcbcx_stats->subtlvs_unrecognized);
+	dcbcx_stats->negotiation_failed =
+		bfa_os_ntohl(dcbcx_stats->negotiation_failed);
+	dcbcx_stats->remote_cfg_changed =
+		bfa_os_ntohl(dcbcx_stats->remote_cfg_changed);
+	dcbcx_stats->tlvs_received = bfa_os_ntohl(dcbcx_stats->tlvs_received);
+	dcbcx_stats->tlvs_invalid = bfa_os_ntohl(dcbcx_stats->tlvs_invalid);
+	dcbcx_stats->seqno = bfa_os_ntohl(dcbcx_stats->seqno);
+	dcbcx_stats->ackno = bfa_os_ntohl(dcbcx_stats->ackno);
+	dcbcx_stats->recvd_seqno = bfa_os_ntohl(dcbcx_stats->recvd_seqno);
+	dcbcx_stats->recvd_ackno = bfa_os_ntohl(dcbcx_stats->recvd_ackno);
+}
+
+static void
+bfa_cee_format_lldp_stats(struct bfa_cee_lldp_stats_s *lldp_stats)
+{
+	lldp_stats->frames_transmitted =
+		bfa_os_ntohl(lldp_stats->frames_transmitted);
+	lldp_stats->frames_aged_out = bfa_os_ntohl(lldp_stats->frames_aged_out);
+	lldp_stats->frames_discarded =
+		bfa_os_ntohl(lldp_stats->frames_discarded);
+	lldp_stats->frames_in_error = bfa_os_ntohl(lldp_stats->frames_in_error);
+	lldp_stats->frames_rcvd = bfa_os_ntohl(lldp_stats->frames_rcvd);
+	lldp_stats->tlvs_discarded = bfa_os_ntohl(lldp_stats->tlvs_discarded);
+	lldp_stats->tlvs_unrecognized =
+		bfa_os_ntohl(lldp_stats->tlvs_unrecognized);
+}
+
+static void
+bfa_cee_format_cfg_stats(struct bfa_cee_cfg_stats_s *cfg_stats)
+{
+	cfg_stats->cee_status_down = bfa_os_ntohl(cfg_stats->cee_status_down);
+	cfg_stats->cee_status_up = bfa_os_ntohl(cfg_stats->cee_status_up);
+	cfg_stats->cee_hw_cfg_changed =
+		bfa_os_ntohl(cfg_stats->cee_hw_cfg_changed);
+	cfg_stats->recvd_invalid_cfg =
+		bfa_os_ntohl(cfg_stats->recvd_invalid_cfg);
+}
+
+static void
+bfa_cee_format_lldp_cfg(struct bfa_cee_lldp_cfg_s *lldp_cfg)
+{
+	lldp_cfg->time_to_interval = bfa_os_ntohs(lldp_cfg->time_to_interval);
+	lldp_cfg->enabled_system_cap =
+		bfa_os_ntohs(lldp_cfg->enabled_system_cap);
+}
+
+/**
+ * bfa_cee_attr_meminfo()
+ *
+ *
+ * @param[in] void
+ *
+ * @return Size of DMA region
+ */
+static          u32
+bfa_cee_attr_meminfo(void)
+{
+	return BFA_ROUNDUP(sizeof(struct bfa_cee_attr_s), BFA_DMA_ALIGN_SZ);
+}
+
+/**
+ * bfa_cee_stats_meminfo()
+ *
+ *
+ * @param[in] void
+ *
+ * @return Size of DMA region
+ */
+static          u32
+bfa_cee_stats_meminfo(void)
+{
+	return BFA_ROUNDUP(sizeof(struct bfa_cee_stats_s), BFA_DMA_ALIGN_SZ);
+}
+
+/**
+ * bfa_cee_get_attr_isr()
+ *
+ *
+ * @param[in] cee - Pointer to the CEE module
+ *            status - Return status from the f/w
+ *
+ * @return void
+ */
+static void
+bfa_cee_get_attr_isr(struct bfa_cee_s *cee, bfa_status_t status)
+{
+	cee->get_attr_status = status;
+	if (status == BFA_STATUS_OK) {
+		/*
+		 * The requested data has been copied to the DMA area, *process
+		 * it.
+		 */
+		memcpy(cee->attr, cee->attr_dma.kva,
+		       sizeof(struct bfa_cee_attr_s));
+		bfa_cee_format_cee_cfg(cee->attr);
+	}
+	cee->get_attr_pending = BFA_FALSE;
+	if (cee->cbfn.get_attr_cbfn)
+		cee->cbfn.get_attr_cbfn(cee->cbfn.get_attr_cbarg, status);
+}
+
+/**
+ * bfa_cee_get_attr_isr()
+ *
+ *
+ * @param[in] cee - Pointer to the CEE module
+ *            status - Return status from the f/w
+ *
+ * @return void
+ */
+static void
+bfa_cee_get_stats_isr(struct bfa_cee_s *cee, bfa_status_t status)
+{
+	cee->get_stats_status = status;
+	if (status == BFA_STATUS_OK) {
+		/*
+		 * The requested data has been copied to the DMA area, process
+		 * it.
+		 */
+		memcpy(cee->stats, cee->stats_dma.kva,
+		       sizeof(struct bfa_cee_stats_s));
+		bfa_cee_format_cee_stats(cee->stats);
+	}
+	cee->get_stats_pending = BFA_FALSE;
+	if (cee->cbfn.get_stats_cbfn)
+		cee->cbfn.get_stats_cbfn(cee->cbfn.get_stats_cbarg, status);
+}
+
+/**
+ * bfa_cee_get_attr_isr()
+ *
+ *
+ * @param[in] cee - Pointer to the CEE module
+ *            status - Return status from the f/w
+ *
+ * @return void
+ */
+static void
+bfa_cee_reset_stats_isr(struct bfa_cee_s *cee, bfa_status_t status)
+{
+	cee->reset_stats_status = status;
+	cee->reset_stats_pending = BFA_FALSE;
+	if (cee->cbfn.reset_stats_cbfn)
+		cee->cbfn.reset_stats_cbfn(cee->cbfn.reset_stats_cbarg, status);
+}
+
+/**
+ * bfa_cee_meminfo()
+ *
+ *
+ * @param[in] void
+ *
+ * @return Size of DMA region
+ */
+u32
+bfa_cee_meminfo(void)
+{
+	return bfa_cee_attr_meminfo() + bfa_cee_stats_meminfo();
+}
+
+/**
+ * bfa_cee_mem_claim()
+ *
+ *
+ * @param[in] cee CEE module pointer
+ * 	      dma_kva Kernel Virtual Address of CEE DMA Memory
+ * 	      dma_pa  Physical Address of CEE DMA Memory
+ *
+ * @return void
+ */
+void
+bfa_cee_mem_claim(struct bfa_cee_s *cee, u8 *dma_kva, u64 dma_pa)
+{
+	cee->attr_dma.kva = dma_kva;
+	cee->attr_dma.pa = dma_pa;
+	cee->stats_dma.kva = dma_kva + bfa_cee_attr_meminfo();
+	cee->stats_dma.pa = dma_pa + bfa_cee_attr_meminfo();
+	cee->attr = (struct bfa_cee_attr_s *)dma_kva;
+	cee->stats =
+		(struct bfa_cee_stats_s *)(dma_kva + bfa_cee_attr_meminfo());
+}
+
+/**
+ * bfa_cee_get_attr()
+ *
+ *   Send the request to the f/w to fetch CEE attributes.
+ *
+ * @param[in] Pointer to the CEE module data structure.
+ *
+ * @return Status
+ */
+
+bfa_status_t
+bfa_cee_get_attr(struct bfa_cee_s *cee, struct bfa_cee_attr_s *attr,
+		 bfa_cee_get_attr_cbfn_t cbfn, void *cbarg)
+{
+	struct bfi_cee_get_req_s *cmd;
+
+	bfa_assert((cee != NULL) && (cee->ioc != NULL));
+	if (!bfa_ioc_is_operational(cee->ioc))
+		return BFA_STATUS_IOC_FAILURE;
+	if (cee->get_attr_pending == BFA_TRUE)
+		return BFA_STATUS_DEVBUSY;
+	cee->get_attr_pending = BFA_TRUE;
+	cmd = (struct bfi_cee_get_req_s *)cee->get_cfg_mb.msg;
+	cee->attr = attr;
+	cee->cbfn.get_attr_cbfn = cbfn;
+	cee->cbfn.get_attr_cbarg = cbarg;
+	bfi_h2i_set(cmd->mh, BFI_MC_CEE, BFI_CEE_H2I_GET_CFG_REQ,
+		    bfa_ioc_portid(cee->ioc));
+	bfa_dma_be_addr_set(cmd->dma_addr, cee->attr_dma.pa);
+	bfa_ioc_mbox_queue(cee->ioc, &cee->get_cfg_mb);
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * bfa_cee_get_stats()
+ *
+ *   Send the request to the f/w to fetch CEE statistics.
+ *
+ * @param[in] Pointer to the CEE module data structure.
+ *
+ * @return Status
+ */
+
+bfa_status_t
+bfa_cee_get_stats(struct bfa_cee_s *cee, struct bfa_cee_stats_s *stats,
+		  bfa_cee_get_stats_cbfn_t cbfn, void *cbarg)
+{
+	struct bfi_cee_get_req_s *cmd;
+
+	bfa_assert((cee != NULL) && (cee->ioc != NULL));
+
+	if (!bfa_ioc_is_operational(cee->ioc))
+		return BFA_STATUS_IOC_FAILURE;
+	if (cee->get_stats_pending == BFA_TRUE)
+		return BFA_STATUS_DEVBUSY;
+	cee->get_stats_pending = BFA_TRUE;
+	cmd = (struct bfi_cee_get_req_s *)cee->get_stats_mb.msg;
+	cee->stats = stats;
+	cee->cbfn.get_stats_cbfn = cbfn;
+	cee->cbfn.get_stats_cbarg = cbarg;
+	bfi_h2i_set(cmd->mh, BFI_MC_CEE, BFI_CEE_H2I_GET_STATS_REQ,
+		    bfa_ioc_portid(cee->ioc));
+	bfa_dma_be_addr_set(cmd->dma_addr, cee->stats_dma.pa);
+	bfa_ioc_mbox_queue(cee->ioc, &cee->get_stats_mb);
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * bfa_cee_reset_stats()
+ *
+ *
+ * @param[in] Pointer to the CEE module data structure.
+ *
+ * @return Status
+ */
+
+bfa_status_t
+bfa_cee_reset_stats(struct bfa_cee_s *cee, bfa_cee_reset_stats_cbfn_t cbfn,
+		    void *cbarg)
+{
+	struct bfi_cee_reset_stats_s *cmd;
+
+	bfa_assert((cee != NULL) && (cee->ioc != NULL));
+	if (!bfa_ioc_is_operational(cee->ioc))
+		return BFA_STATUS_IOC_FAILURE;
+	if (cee->reset_stats_pending == BFA_TRUE)
+		return BFA_STATUS_DEVBUSY;
+	cee->reset_stats_pending = BFA_TRUE;
+	cmd = (struct bfi_cee_reset_stats_s *)cee->reset_stats_mb.msg;
+	cee->cbfn.reset_stats_cbfn = cbfn;
+	cee->cbfn.reset_stats_cbarg = cbarg;
+	bfi_h2i_set(cmd->mh, BFI_MC_CEE, BFI_CEE_H2I_RESET_STATS,
+		    bfa_ioc_portid(cee->ioc));
+	bfa_ioc_mbox_queue(cee->ioc, &cee->reset_stats_mb);
+	return BFA_STATUS_OK;
+}
+
+/**
+ * bfa_cee_isrs()
+ *
+ *
+ * @param[in] Pointer to the CEE module data structure.
+ *
+ * @return void
+ */
+
+void
+bfa_cee_isr(void *cbarg, struct bfi_mbmsg_s *m)
+{
+	union bfi_cee_i2h_msg_u *msg;
+	struct bfi_cee_get_rsp_s *get_rsp;
+	struct bfa_cee_s *cee = (struct bfa_cee_s *)cbarg;
+	msg = (union bfi_cee_i2h_msg_u *)m;
+	get_rsp = (struct bfi_cee_get_rsp_s *)m;
+	switch (msg->mh.msg_id) {
+	case BFI_CEE_I2H_GET_CFG_RSP:
+		bfa_cee_get_attr_isr(cee, get_rsp->cmd_status);
+		break;
+	case BFI_CEE_I2H_GET_STATS_RSP:
+		bfa_cee_get_stats_isr(cee, get_rsp->cmd_status);
+		break;
+	case BFI_CEE_I2H_RESET_STATS_RSP:
+		bfa_cee_reset_stats_isr(cee, get_rsp->cmd_status);
+		break;
+	default:
+		bfa_assert(0);
+	}
+}
+
+/**
+ * bfa_cee_hbfail()
+ *
+ *
+ * @param[in] Pointer to the CEE module data structure.
+ *
+ * @return void
+ */
+
+void
+bfa_cee_hbfail(void *arg)
+{
+	struct bfa_cee_s *cee;
+	cee = (struct bfa_cee_s *)arg;
+
+	if (cee->get_attr_pending == BFA_TRUE) {
+		cee->get_attr_status = BFA_STATUS_FAILED;
+		cee->get_attr_pending = BFA_FALSE;
+		if (cee->cbfn.get_attr_cbfn)
+			cee->cbfn.get_attr_cbfn(cee->cbfn.get_attr_cbarg,
+						BFA_STATUS_FAILED);
+	}
+	if (cee->get_stats_pending == BFA_TRUE) {
+		cee->get_stats_status = BFA_STATUS_FAILED;
+		cee->get_stats_pending = BFA_FALSE;
+		if (cee->cbfn.get_stats_cbfn)
+			cee->cbfn.get_stats_cbfn(cee->cbfn.get_stats_cbarg,
+						 BFA_STATUS_FAILED);
+	}
+	if (cee->reset_stats_pending == BFA_TRUE) {
+		cee->reset_stats_status = BFA_STATUS_FAILED;
+		cee->reset_stats_pending = BFA_FALSE;
+		if (cee->cbfn.reset_stats_cbfn) {
+			cee->cbfn.reset_stats_cbfn(cee->cbfn.reset_stats_cbarg,
+						   BFA_STATUS_FAILED);
+		}
+	}
+}
+
+/**
+ * bfa_cee_attach()
+ *
+ *
+ * @param[in] cee - Pointer to the CEE module data structure
+ *            ioc - Pointer to the ioc module data structure
+ *            dev - Pointer to the device driver module data structure
+ *                  The device driver specific mbox ISR functions have
+ *                  this pointer as one of the parameters.
+ *            trcmod -
+ *            logmod -
+ *
+ * @return void
+ */
+void
+bfa_cee_attach(struct bfa_cee_s *cee, struct bfa_ioc_s *ioc, void *dev,
+	       struct bfa_trc_mod_s *trcmod, struct bfa_log_mod_s *logmod)
+{
+	bfa_assert(cee != NULL);
+	cee->dev = dev;
+	cee->trcmod = trcmod;
+	cee->logmod = logmod;
+	cee->ioc = ioc;
+
+	bfa_ioc_mbox_regisr(cee->ioc, BFI_MC_CEE, bfa_cee_isr, cee);
+	bfa_ioc_hbfail_init(&cee->hbfail, bfa_cee_hbfail, cee);
+	bfa_ioc_hbfail_register(cee->ioc, &cee->hbfail);
+}
+
+/**
+ * bfa_cee_detach()
+ *
+ *
+ * @param[in] cee - Pointer to the CEE module data structure
+ *
+ * @return void
+ */
+void
+bfa_cee_detach(struct bfa_cee_s *cee)
+{
+	/*
+	 * For now, just check if there is some ioctl pending and mark that as
+	 * failed?
+	 */
+	/* bfa_cee_hbfail(cee); */
+}
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_csdebug.c linux-2.6.32-rc4-mod/drivers/net/bna/bfa_csdebug.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_csdebug.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_csdebug.c	2009-10-16 10:30:53.421438000 -0700
@@ -0,0 +1,62 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#include <cs/bfa_debug.h>
+#include <bfa_os_inc.h>
+#include <cs/bfa_q.h>
+
+/**
+ *  cs_debug_api
+ */
+
+
+void
+bfa_panic(int line, char *file, char *panicstr)
+{
+	bfa_os_panic();
+}
+
+void
+bfa_sm_panic(struct bfa_log_mod_s *logm, int line, char *file, int event)
+{
+	bfa_os_panic();
+}
+
+int
+bfa_q_is_on_q_func(struct list_head *q, struct list_head *qe)
+{
+	struct list_head        *tqe;
+
+	tqe = bfa_q_next(q);
+	while (tqe != q) {
+		if (tqe == qe)
+			return 1;
+		tqe = bfa_q_next(tqe);
+		if (tqe == NULL)
+			break;
+	}
+	return 0;
+}
+
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_ioc.c linux-2.6.32-rc4-mod/drivers/net/bna/bfa_ioc.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_ioc.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_ioc.c	2009-10-16 10:30:53.439441000 -0700
@@ -0,0 +1,2273 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#include <bfa_ioc.h>
+#include <bfa_fwimg_priv.h>
+#include <cs/bfa_debug.h>
+#include <bfi/bfi_ioc.h>
+#include <bfi/bfi_ctreg.h>
+#include <defs/bfa_defs_pci.h>
+#include <cna.h>
+
+
+/**
+ * IOC local definitions
+ */
+#define BFA_IOC_TOV		2000	/* msecs */
+#define BFA_IOC_HB_TOV		1000	/* msecs */
+#define BFA_IOC_HB_FAIL_MAX	4
+#define BFA_IOC_HWINIT_MAX	2
+#define BFA_IOC_FWIMG_MINSZ     (16 * 1024)
+#define BFA_IOC_TOV_RECOVER	(BFA_IOC_HB_FAIL_MAX * BFA_IOC_HB_TOV \
+				+ BFA_IOC_TOV)
+
+#define bfa_ioc_timer_start(__ioc)					\
+	bfa_timer_begin((__ioc)->timer_mod, &(__ioc)->ioc_timer,	\
+			bfa_ioc_timeout, (__ioc), BFA_IOC_TOV)
+#define bfa_ioc_timer_stop(__ioc)   bfa_timer_stop(&(__ioc)->ioc_timer)
+
+#define BFA_DBG_FWTRC_ENTS	(BFI_IOC_TRC_ENTS)
+#define BFA_DBG_FWTRC_LEN					\
+	(BFA_DBG_FWTRC_ENTS * sizeof(struct bfa_trc_s) +	\
+	 (sizeof(struct bfa_trc_mod_s) -			\
+	  BFA_TRC_MAX * sizeof(struct bfa_trc_s)))
+#define BFA_DBG_FWTRC_OFF(_fn)	(BFI_IOC_TRC_OFF + BFA_DBG_FWTRC_LEN * (_fn))
+#define bfa_ioc_stats(_ioc, _stats)	((_ioc)->stats._stats++)
+
+#define BFA_FLASH_CHUNK_NO(off)         (off / BFI_FLASH_CHUNK_SZ_WORDS)
+#define BFA_FLASH_OFFSET_IN_CHUNK(off)  (off % BFI_FLASH_CHUNK_SZ_WORDS)
+#define BFA_FLASH_CHUNK_ADDR(chunkno)   (chunkno * BFI_FLASH_CHUNK_SZ_WORDS)
+bfa_boolean_t   bfa_auto_recover = BFA_FALSE;
+
+/*
+ * forward declarations
+ */
+static void     bfa_ioc_hw_sem_get(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_hw_sem_release(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_hw_sem_get_cancel(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_hwinit(struct bfa_ioc_s *ioc, bfa_boolean_t force);
+static void     bfa_ioc_timeout(void *ioc);
+static void     bfa_ioc_send_enable(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_send_disable(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_send_getattr(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_hb_monitor(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_hb_stop(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_reset(struct bfa_ioc_s *ioc, bfa_boolean_t force);
+static void     bfa_ioc_mbox_poll(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_mbox_hbfail(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_recover(struct bfa_ioc_s *ioc);
+static bfa_boolean_t bfa_ioc_firmware_lock(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_firmware_unlock(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_disable_comp(struct bfa_ioc_s *ioc);
+static void     bfa_ioc_lpu_stop(struct bfa_ioc_s *ioc);
+
+/**
+ *  bfa_ioc_sm
+ */
+
+/**
+ * IOC state machine events
+ */
+enum ioc_event {
+	IOC_E_ENABLE = 1,	/*  IOC enable request */
+	IOC_E_DISABLE = 2,	/*  IOC disable request */
+	IOC_E_TIMEOUT = 3,	/*  f/w response timeout */
+	IOC_E_FWREADY = 4,	/*  f/w initialization done */
+	IOC_E_FWRSP_GETATTR = 5,	/*  IOC get attribute response */
+	IOC_E_FWRSP_ENABLE = 6,	/*  enable f/w response */
+	IOC_E_FWRSP_DISABLE = 7,	/*  disable f/w response */
+	IOC_E_HBFAIL = 8,	/*  heartbeat failure */
+	IOC_E_HWERROR = 9,	/*  hardware error interrupt */
+	IOC_E_SEMLOCKED = 10,	/*  h/w semaphore is locked */
+	IOC_E_DETACH = 11,	/*  driver detach cleanup */
+};
+
+bfa_fsm_state_decl(bfa_ioc, reset, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, fwcheck, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, mismatch, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, semwait, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, hwinit, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, enabling, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, getattr, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, op, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, initfail, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, hbfail, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, disabling, struct bfa_ioc_s, enum ioc_event);
+bfa_fsm_state_decl(bfa_ioc, disabled, struct bfa_ioc_s, enum ioc_event);
+
+static struct bfa_sm_table_s ioc_sm_table[] = {
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
+bfa_ioc_sm_reset_entry(struct bfa_ioc_s *ioc)
+{
+	ioc->retry_count = 0;
+	ioc->auto_recover = bfa_auto_recover;
+}
+
+/**
+ * Beginning state. IOC is in reset state.
+ */
+static void
+bfa_ioc_sm_reset(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+bfa_ioc_sm_fwcheck_entry(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_hw_sem_get(ioc);
+}
+
+/**
+ * Awaiting h/w semaphore to continue with version check.
+ */
+static void
+bfa_ioc_sm_fwcheck(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+		/*
+		 * fall through
+		 */
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
+bfa_ioc_sm_mismatch_entry(struct bfa_ioc_s *ioc)
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
+bfa_ioc_sm_mismatch(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
+	switch (event) {
+	case IOC_E_TIMEOUT:
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_fwcheck);
+		break;
+
+	case IOC_E_DISABLE:
+		bfa_ioc_disable_comp(ioc);
+		/*
+		 * fall through
+		 */
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
+bfa_ioc_sm_semwait_entry(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_hw_sem_get(ioc);
+}
+
+/**
+ * Awaiting semaphore for h/w initialzation.
+ */
+static void
+bfa_ioc_sm_semwait(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+
+static void
+bfa_ioc_sm_hwinit_entry(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_reset(ioc, BFA_FALSE);
+}
+
+/**
+ * Hardware is being initialized. Interrupts are enabled.
+ * Holding hardware semaphore lock.
+ */
+static void
+bfa_ioc_sm_hwinit(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
+	switch (event) {
+	case IOC_E_FWREADY:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_enabling);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/*
+		 * fall through
+		 */
+
+	case IOC_E_TIMEOUT:
+		ioc->retry_count++;
+		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
+			bfa_ioc_timer_start(ioc);
+			bfa_ioc_reset(ioc, BFA_TRUE);
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
+
+static void
+bfa_ioc_sm_enabling_entry(struct bfa_ioc_s *ioc)
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
+bfa_ioc_sm_enabling(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
+	switch (event) {
+	case IOC_E_FWRSP_ENABLE:
+		bfa_ioc_timer_stop(ioc);
+		bfa_ioc_hw_sem_release(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_getattr);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/*
+		 * fall through
+		 */
+
+	case IOC_E_TIMEOUT:
+		ioc->retry_count++;
+		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
+			bfa_reg_write(ioc->ioc_regs.ioc_fwstate,
+				      BFI_IOC_UNINIT);
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
+
+static void
+bfa_ioc_sm_getattr_entry(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_send_getattr(ioc);
+}
+
+/**
+ * IOC configuration in progress. Timer is active.
+ */
+static void
+bfa_ioc_sm_getattr(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
+	switch (event) {
+	case IOC_E_FWRSP_GETATTR:
+		bfa_ioc_timer_stop(ioc);
+		bfa_fsm_set_state(ioc, bfa_ioc_sm_op);
+		break;
+
+	case IOC_E_HWERROR:
+		bfa_ioc_timer_stop(ioc);
+		/*
+		 * fall through
+		 */
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
+
+static void
+bfa_ioc_sm_op_entry(struct bfa_ioc_s *ioc)
+{
+	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_OK);
+	bfa_ioc_hb_monitor(ioc);
+}
+
+static void
+bfa_ioc_sm_op(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+		/*
+		 * !!! fall through !!!
+		 */
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
+
+static void
+bfa_ioc_sm_disabling_entry(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_timer_start(ioc);
+	bfa_ioc_send_disable(ioc);
+}
+
+/**
+ * IOC is being disabled
+ */
+static void
+bfa_ioc_sm_disabling(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
+	switch (event) {
+	case IOC_E_HWERROR:
+	case IOC_E_FWRSP_DISABLE:
+		bfa_ioc_timer_stop(ioc);
+		/*
+		 * !!! fall through !!!
+		 */
+
+	case IOC_E_TIMEOUT:
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
+bfa_ioc_sm_disabled_entry(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_disable_comp(ioc);
+}
+
+static void
+bfa_ioc_sm_disabled(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+
+static void
+bfa_ioc_sm_initfail_entry(struct bfa_ioc_s *ioc)
+{
+	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
+	bfa_ioc_timer_start(ioc);
+}
+
+/**
+ * Hardware initialization failed.
+ */
+static void
+bfa_ioc_sm_initfail(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+
+static void
+bfa_ioc_sm_hbfail_entry(struct bfa_ioc_s *ioc)
+{
+	struct list_head *qe;
+	struct bfa_ioc_hbfail_notify_s *notify;
+
+	/**
+	 * Mark IOC as failed in hardware and stop firmware.
+	 */
+	bfa_ioc_lpu_stop(ioc);
+	bfa_reg_write(ioc->ioc_regs.ioc_fwstate, BFI_IOC_HBFAIL);
+
+	if (ioc->pcidev.device_id == BFA_PCI_DEVICE_ID_CT) {
+		bfa_reg_write(ioc->ioc_regs.ll_halt, __FW_INIT_HALT_P);
+		/*
+		 * Wait for halt to take effect
+		 */
+		bfa_reg_read(ioc->ioc_regs.ll_halt);
+	}
+
+	/**
+	 * Notify driver and common modules registered for notification.
+	 */
+	ioc->cbfn->hbfail_cbfn(ioc->bfa);
+	list_for_each(qe, &ioc->hb_notify_q) {
+		notify = (struct bfa_ioc_hbfail_notify_s *)qe;
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
+	if (ioc->auto_recover) {
+		bfa_timer_begin(ioc->timer_mod, &ioc->ioc_timer,
+				bfa_ioc_timeout, ioc, BFA_IOC_TOV_RECOVER);
+	}
+}
+
+/**
+ * IOC heartbeat failure.
+ */
+static void
+bfa_ioc_sm_hbfail(struct bfa_ioc_s *ioc, enum ioc_event event)
+{
+
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
+	default:
+		bfa_sm_fault(ioc, event);
+	}
+}
+
+
+
+/**
+ *  bfa_ioc_pvt BFA IOC private functions
+ */
+
+static void
+bfa_ioc_disable_comp(struct bfa_ioc_s *ioc)
+{
+	struct list_head *qe;
+	struct bfa_ioc_hbfail_notify_s *notify;
+
+	ioc->cbfn->disable_cbfn(ioc->bfa);
+
+	/**
+	 * Notify common modules registered for notification.
+	 */
+	list_for_each(qe, &ioc->hb_notify_q) {
+		notify = (struct bfa_ioc_hbfail_notify_s *)qe;
+		notify->cbfn(notify->cbarg);
+	}
+}
+
+static void
+bfa_ioc_sem_timeout(void *ioc_arg)
+{
+	struct bfa_ioc_s *ioc = (struct bfa_ioc_s *)ioc_arg;
+
+	bfa_ioc_hw_sem_get(ioc);
+}
+
+static void
+bfa_ioc_usage_sem_get(struct bfa_ioc_s *ioc)
+{
+	u32        r32;
+	int             cnt = 0;
+#define BFA_SEM_SPINCNT	1000
+
+	do {
+		r32 = bfa_reg_read(ioc->ioc_regs.ioc_usage_sem_reg);
+		cnt++;
+		if (cnt > BFA_SEM_SPINCNT)
+			break;
+	} while (r32 != 0);
+	bfa_assert(cnt < BFA_SEM_SPINCNT);
+}
+
+static void
+bfa_ioc_usage_sem_release(struct bfa_ioc_s *ioc)
+{
+	bfa_reg_write(ioc->ioc_regs.ioc_usage_sem_reg, 1);
+}
+
+static void
+bfa_ioc_hw_sem_get(struct bfa_ioc_s *ioc)
+{
+	u32        r32;
+
+	/**
+	 * First read to the semaphore register will return 0, subsequent reads
+	 * will return 1. Semaphore is released by writing 0 to the register
+	 */
+	r32 = bfa_reg_read(ioc->ioc_regs.ioc_sem_reg);
+	if (r32 == 0) {
+		bfa_fsm_send_event(ioc, IOC_E_SEMLOCKED);
+		return;
+	}
+
+	bfa_timer_begin(ioc->timer_mod, &ioc->sem_timer, bfa_ioc_sem_timeout,
+			ioc, BFA_IOC_TOV);
+}
+
+static void
+bfa_ioc_hw_sem_release(struct bfa_ioc_s *ioc)
+{
+	bfa_reg_write(ioc->ioc_regs.ioc_sem_reg, 1);
+}
+
+static void
+bfa_ioc_hw_sem_get_cancel(struct bfa_ioc_s *ioc)
+{
+	bfa_timer_stop(&ioc->sem_timer);
+}
+
+/**
+ * Initialize LPU local memory (aka secondary memory / SRAM)
+ */
+static void
+bfa_ioc_lmem_init(struct bfa_ioc_s *ioc)
+{
+	u32        pss_ctl;
+	int             i;
+#define PSS_LMEM_INIT_TIME  10000
+
+	pss_ctl = bfa_reg_read(ioc->ioc_regs.pss_ctl_reg);
+	pss_ctl &= ~__PSS_LMEM_RESET;
+	pss_ctl |= __PSS_LMEM_INIT_EN;
+	pss_ctl |= __PSS_I2C_CLK_DIV(3UL); /* i2c workaround 12.5khz clock */
+	bfa_reg_write(ioc->ioc_regs.pss_ctl_reg, pss_ctl);
+
+	/**
+	 * wait for memory initialization to be complete
+	 */
+	i = 0;
+	do {
+		pss_ctl = bfa_reg_read(ioc->ioc_regs.pss_ctl_reg);
+		i++;
+	} while (!(pss_ctl & __PSS_LMEM_INIT_DONE) && (i < PSS_LMEM_INIT_TIME));
+
+	/**
+	 * If memory initialization is not successful, IOC timeout will catch
+	 * such failures.
+	 */
+	bfa_assert(pss_ctl & __PSS_LMEM_INIT_DONE);
+
+	pss_ctl &= ~(__PSS_LMEM_INIT_DONE | __PSS_LMEM_INIT_EN);
+	bfa_reg_write(ioc->ioc_regs.pss_ctl_reg, pss_ctl);
+}
+
+static void
+bfa_ioc_lpu_start(struct bfa_ioc_s *ioc)
+{
+	u32        pss_ctl;
+
+	/**
+	 * Take processor out of reset.
+	 */
+	pss_ctl = bfa_reg_read(ioc->ioc_regs.pss_ctl_reg);
+	pss_ctl &= ~__PSS_LPU0_RESET;
+
+	bfa_reg_write(ioc->ioc_regs.pss_ctl_reg, pss_ctl);
+}
+
+static void
+bfa_ioc_lpu_stop(struct bfa_ioc_s *ioc)
+{
+	u32        pss_ctl;
+
+	/**
+	 * Put processors in reset.
+	 */
+	pss_ctl = bfa_reg_read(ioc->ioc_regs.pss_ctl_reg);
+	pss_ctl |= (__PSS_LPU0_RESET | __PSS_LPU1_RESET);
+
+	bfa_reg_write(ioc->ioc_regs.pss_ctl_reg, pss_ctl);
+}
+
+/**
+ * Get driver and firmware versions.
+ */
+static void
+bfa_ioc_fwver_get(struct bfa_ioc_s *ioc, struct bfi_ioc_image_hdr_s *fwhdr)
+{
+	u32        pgnum, pgoff;
+	u32        loff = 0;
+	int             i;
+	u32       *fwsig = (u32 *) fwhdr;
+
+	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
+	bfa_reg_write(ioc->ioc_regs.host_page_num_fn, pgnum);
+
+	for (i = 0; i < (sizeof(struct bfi_ioc_image_hdr_s) / sizeof(u32));
+	     i++) {
+		fwsig[i] = bfa_mem_read(ioc->ioc_regs.smem_page_start, loff);
+		loff += sizeof(u32);
+	}
+}
+
+static u32 *
+bfa_ioc_fwimg_get_chunk(struct bfa_ioc_s *ioc, u32 off)
+{
+	if (ioc->ctdev)
+		return bfi_image_ct_get_chunk(off);
+	return bfi_image_cb_get_chunk(off);
+}
+
+static          u32
+bfa_ioc_fwimg_get_size(struct bfa_ioc_s *ioc)
+{
+return (ioc->ctdev) ? bfi_image_ct_size : bfi_image_cb_size;
+}
+
+/**
+ * Returns TRUE if same.
+ */
+static          bfa_boolean_t
+bfa_ioc_fwver_cmp(struct bfa_ioc_s *ioc, struct bfi_ioc_image_hdr_s *fwhdr)
+{
+	struct bfi_ioc_image_hdr_s *drv_fwhdr;
+	int             i;
+
+	drv_fwhdr =
+		(struct bfi_ioc_image_hdr_s *)bfa_ioc_fwimg_get_chunk(ioc, 0);
+
+	for (i = 0; i < BFI_IOC_MD5SUM_SZ; i++) {
+		if (fwhdr->md5sum[i] != drv_fwhdr->md5sum[i])
+			return BFA_FALSE;
+	}
+
+	return BFA_TRUE;
+}
+
+/**
+ * Return true if current running version is valid. Firmware signature and
+ * execution context (driver/bios) must match.
+ */
+static          bfa_boolean_t
+bfa_ioc_fwver_valid(struct bfa_ioc_s *ioc)
+{
+	struct bfi_ioc_image_hdr_s fwhdr, *drv_fwhdr;
+
+	/**
+	 * If bios/efi boot (flash based) -- return true
+	 */
+	if (bfa_ioc_fwimg_get_size(ioc) < BFA_IOC_FWIMG_MINSZ)
+		return BFA_TRUE;
+
+	bfa_ioc_fwver_get(ioc, &fwhdr);
+	drv_fwhdr =
+		(struct bfi_ioc_image_hdr_s *)bfa_ioc_fwimg_get_chunk(ioc, 0);
+
+	if (fwhdr.signature != drv_fwhdr->signature)
+		return BFA_FALSE;
+
+	if (fwhdr.exec != drv_fwhdr->exec)
+		return BFA_FALSE;
+
+	return bfa_ioc_fwver_cmp(ioc, &fwhdr);
+}
+
+/**
+ * Return true if firmware of current driver matches the running firmware.
+ */
+static          bfa_boolean_t
+bfa_ioc_firmware_lock(struct bfa_ioc_s *ioc)
+{
+	enum bfi_ioc_state ioc_fwstate;
+	u32        usecnt;
+	struct bfi_ioc_image_hdr_s fwhdr;
+
+	/**
+	 * Firmware match check is relevant only for CNA.
+	 */
+	if (!ioc->cna)
+		return BFA_TRUE;
+
+	/**
+	 * If bios boot (flash based) -- do not increment usage count
+	 */
+	if (bfa_ioc_fwimg_get_size(ioc) < BFA_IOC_FWIMG_MINSZ)
+		return BFA_TRUE;
+
+	bfa_ioc_usage_sem_get(ioc);
+	usecnt = bfa_reg_read(ioc->ioc_regs.ioc_usage_reg);
+
+	/**
+	 * If usage count is 0, always return TRUE.
+	 */
+	if (usecnt == 0) {
+		bfa_reg_write(ioc->ioc_regs.ioc_usage_reg, 1);
+		bfa_ioc_usage_sem_release(ioc);
+		return BFA_TRUE;
+	}
+
+	ioc_fwstate = bfa_reg_read(ioc->ioc_regs.ioc_fwstate);
+
+	/**
+	 * Use count cannot be non-zero and chip in uninitialized state.
+	 */
+	bfa_assert(ioc_fwstate != BFI_IOC_UNINIT);
+
+	/**
+	 * Check if another driver with a different firmware is active
+	 */
+	bfa_ioc_fwver_get(ioc, &fwhdr);
+	if (!bfa_ioc_fwver_cmp(ioc, &fwhdr)) {
+		bfa_ioc_usage_sem_release(ioc);
+		return BFA_FALSE;
+	}
+
+	/**
+	 * Same firmware version. Increment the reference count.
+	 */
+	usecnt++;
+	bfa_reg_write(ioc->ioc_regs.ioc_usage_reg, usecnt);
+	bfa_ioc_usage_sem_release(ioc);
+	return BFA_TRUE;
+}
+
+static void
+bfa_ioc_firmware_unlock(struct bfa_ioc_s *ioc)
+{
+	u32        usecnt;
+
+	/**
+	 * Firmware lock is relevant only for CNA.
+	 * If bios boot (flash based) -- do not decrement usage count
+	 */
+	if (!ioc->cna || (bfa_ioc_fwimg_get_size(ioc) < BFA_IOC_FWIMG_MINSZ))
+		return;
+
+	/**
+	 * decrement usage count
+	 */
+	bfa_ioc_usage_sem_get(ioc);
+	usecnt = bfa_reg_read(ioc->ioc_regs.ioc_usage_reg);
+	bfa_assert(usecnt > 0);
+
+	usecnt--;
+	bfa_reg_write(ioc->ioc_regs.ioc_usage_reg, usecnt);
+
+	bfa_ioc_usage_sem_release(ioc);
+}
+
+/**
+ * Conditionally flush any pending message from firmware at start.
+ */
+static void
+bfa_ioc_msgflush(struct bfa_ioc_s *ioc)
+{
+	u32        r32;
+
+	r32 = bfa_reg_read(ioc->ioc_regs.lpu_mbox_cmd);
+	if (r32)
+		bfa_reg_write(ioc->ioc_regs.lpu_mbox_cmd, 1);
+}
+
+
+static void
+bfa_ioc_hwinit(struct bfa_ioc_s *ioc, bfa_boolean_t force)
+{
+	enum bfi_ioc_state ioc_fwstate;
+	bfa_boolean_t   fwvalid;
+
+	ioc_fwstate = bfa_reg_read(ioc->ioc_regs.ioc_fwstate);
+
+	if (force)
+		ioc_fwstate = BFI_IOC_UNINIT;
+
+
+	/**
+	 * check if firmware is valid
+	 */
+	fwvalid = (ioc_fwstate == BFI_IOC_UNINIT) ?
+			BFA_FALSE : bfa_ioc_fwver_valid(ioc);
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
+	 */
+	if (ioc_fwstate == BFI_IOC_DISABLED || ioc_fwstate == BFI_IOC_OP) {
+
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
+static void
+bfa_ioc_timeout(void *ioc_arg)
+{
+	struct bfa_ioc_s *ioc = (struct bfa_ioc_s *)ioc_arg;
+
+	bfa_fsm_send_event(ioc, IOC_E_TIMEOUT);
+}
+
+void
+bfa_ioc_mbox_send(struct bfa_ioc_s *ioc, void *ioc_msg, int len)
+{
+	u32       *msgp = (u32 *) ioc_msg;
+	u32        i;
+
+
+	bfa_assert(len <= BFI_IOC_MSGLEN_MAX);
+
+	/*
+	 * first write msg to mailbox registers
+	 */
+	for (i = 0; i < len / sizeof(u32); i++)
+		bfa_reg_write(ioc->ioc_regs.hfn_mbox + i * sizeof(u32),
+			      bfa_os_wtole(msgp[i]));
+
+	for (; i < BFI_IOC_MSGLEN_MAX / sizeof(u32); i++)
+		bfa_reg_write(ioc->ioc_regs.hfn_mbox + i * sizeof(u32), 0);
+
+	/*
+	 * write 1 to mailbox CMD to trigger LPU event
+	 */
+	bfa_reg_write(ioc->ioc_regs.hfn_mbox_cmd, 1);
+	(void)bfa_reg_read(ioc->ioc_regs.hfn_mbox_cmd);
+}
+
+static void
+bfa_ioc_send_enable(struct bfa_ioc_s *ioc)
+{
+	struct bfi_ioc_ctrl_req_s enable_req;
+
+	bfi_h2i_set(enable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_ENABLE_REQ,
+		    bfa_ioc_portid(ioc));
+	enable_req.ioc_class = ioc->ioc_mc;
+	bfa_ioc_mbox_send(ioc, &enable_req, sizeof(struct bfi_ioc_ctrl_req_s));
+}
+
+static void
+bfa_ioc_send_disable(struct bfa_ioc_s *ioc)
+{
+	struct bfi_ioc_ctrl_req_s disable_req;
+
+	bfi_h2i_set(disable_req.mh, BFI_MC_IOC, BFI_IOC_H2I_DISABLE_REQ,
+		    bfa_ioc_portid(ioc));
+	bfa_ioc_mbox_send(ioc, &disable_req, sizeof(struct bfi_ioc_ctrl_req_s));
+}
+
+static void
+bfa_ioc_send_getattr(struct bfa_ioc_s *ioc)
+{
+	struct bfi_ioc_getattr_req_s attr_req;
+
+	bfi_h2i_set(attr_req.mh, BFI_MC_IOC, BFI_IOC_H2I_GETATTR_REQ,
+		    bfa_ioc_portid(ioc));
+	bfa_dma_be_addr_set(attr_req.attr_addr, ioc->attr_dma.pa);
+	bfa_ioc_mbox_send(ioc, &attr_req, sizeof(attr_req));
+}
+
+static void
+bfa_ioc_hb_check(void *cbarg)
+{
+	struct bfa_ioc_s *ioc = cbarg;
+	u32        hb_count;
+
+	hb_count = bfa_reg_read(ioc->ioc_regs.heartbeat);
+	if (ioc->hb_count == hb_count) {
+		ioc->hb_fail++;
+	} else {
+		ioc->hb_count = hb_count;
+		ioc->hb_fail = 0;
+	}
+
+	if (ioc->hb_fail >= BFA_IOC_HB_FAIL_MAX) {
+		ioc->hb_fail = 0;
+		bfa_ioc_recover(ioc);
+		return;
+	}
+
+	bfa_ioc_mbox_poll(ioc);
+	bfa_timer_begin(ioc->timer_mod, &ioc->ioc_timer, bfa_ioc_hb_check, ioc,
+			BFA_IOC_HB_TOV);
+}
+
+static void
+bfa_ioc_hb_monitor(struct bfa_ioc_s *ioc)
+{
+	ioc->hb_fail = 0;
+	ioc->hb_count = bfa_reg_read(ioc->ioc_regs.heartbeat);
+	bfa_timer_begin(ioc->timer_mod, &ioc->ioc_timer, bfa_ioc_hb_check, ioc,
+			BFA_IOC_HB_TOV);
+}
+
+static void
+bfa_ioc_hb_stop(struct bfa_ioc_s *ioc)
+{
+	bfa_timer_stop(&ioc->ioc_timer);
+}
+
+/**
+ * Host to LPU mailbox message addresses
+ */
+static struct {
+	u32        hfn_mbox, lpu_mbox, hfn_pgn;
+} iocreg_fnreg[] = {
+	{
+	HOSTFN0_LPU_MBOX0_0, LPU_HOSTFN0_MBOX0_0, HOST_PAGE_NUM_FN0}, {
+	HOSTFN1_LPU_MBOX0_8, LPU_HOSTFN1_MBOX0_8, HOST_PAGE_NUM_FN1}, {
+	HOSTFN2_LPU_MBOX0_0, LPU_HOSTFN2_MBOX0_0, HOST_PAGE_NUM_FN2}, {
+	HOSTFN3_LPU_MBOX0_8, LPU_HOSTFN3_MBOX0_8, HOST_PAGE_NUM_FN3}
+};
+
+/**
+ * Host <-> LPU mailbox command/status registers - port 0
+ */
+static struct {
+	u32        hfn, lpu;
+} iocreg_mbcmd_p0[] = {
+	{
+	HOSTFN0_LPU0_MBOX0_CMD_STAT, LPU0_HOSTFN0_MBOX0_CMD_STAT}, {
+	HOSTFN1_LPU0_MBOX0_CMD_STAT, LPU0_HOSTFN1_MBOX0_CMD_STAT}, {
+	HOSTFN2_LPU0_MBOX0_CMD_STAT, LPU0_HOSTFN2_MBOX0_CMD_STAT}, {
+	HOSTFN3_LPU0_MBOX0_CMD_STAT, LPU0_HOSTFN3_MBOX0_CMD_STAT}
+};
+
+/**
+ * Host <-> LPU mailbox command/status registers - port 1
+ */
+static struct {
+	u32        hfn, lpu;
+} iocreg_mbcmd_p1[] = {
+	{
+	HOSTFN0_LPU1_MBOX0_CMD_STAT, LPU1_HOSTFN0_MBOX0_CMD_STAT}, {
+	HOSTFN1_LPU1_MBOX0_CMD_STAT, LPU1_HOSTFN1_MBOX0_CMD_STAT}, {
+	HOSTFN2_LPU1_MBOX0_CMD_STAT, LPU1_HOSTFN2_MBOX0_CMD_STAT}, {
+	HOSTFN3_LPU1_MBOX0_CMD_STAT, LPU1_HOSTFN3_MBOX0_CMD_STAT}
+};
+
+/**
+ * Shared IRQ handling in INTX mode
+ */
+static struct {
+	u32        isr, msk;
+} iocreg_shirq_next[] = {
+	{
+	HOSTFN1_INT_STATUS, HOSTFN1_INT_MSK}, {
+	HOSTFN2_INT_STATUS, HOSTFN2_INT_MSK}, {
+	HOSTFN3_INT_STATUS, HOSTFN3_INT_MSK}, {
+HOSTFN0_INT_STATUS, HOSTFN0_INT_MSK},};
+
+static void
+bfa_ioc_reg_init(struct bfa_ioc_s *ioc)
+{
+	bfa_os_addr_t   rb;
+	int             pcifn = bfa_ioc_pcifn(ioc);
+
+	rb = bfa_ioc_bar0(ioc);
+
+	ioc->ioc_regs.hfn_mbox = rb + iocreg_fnreg[pcifn].hfn_mbox;
+	ioc->ioc_regs.lpu_mbox = rb + iocreg_fnreg[pcifn].lpu_mbox;
+	ioc->ioc_regs.host_page_num_fn = rb + iocreg_fnreg[pcifn].hfn_pgn;
+
+	if (ioc->port_id == 0) {
+		ioc->ioc_regs.heartbeat = rb + BFA_IOC0_HBEAT_REG;
+		ioc->ioc_regs.ioc_fwstate = rb + BFA_IOC0_STATE_REG;
+		ioc->ioc_regs.hfn_mbox_cmd = rb + iocreg_mbcmd_p0[pcifn].hfn;
+		ioc->ioc_regs.lpu_mbox_cmd = rb + iocreg_mbcmd_p0[pcifn].lpu;
+		ioc->ioc_regs.ll_halt = rb + FW_INIT_HALT_P0;
+	} else {
+		ioc->ioc_regs.heartbeat = (rb + BFA_IOC1_HBEAT_REG);
+		ioc->ioc_regs.ioc_fwstate = (rb + BFA_IOC1_STATE_REG);
+		ioc->ioc_regs.hfn_mbox_cmd = rb + iocreg_mbcmd_p1[pcifn].hfn;
+		ioc->ioc_regs.lpu_mbox_cmd = rb + iocreg_mbcmd_p1[pcifn].lpu;
+		ioc->ioc_regs.ll_halt = rb + FW_INIT_HALT_P1;
+	}
+
+	/**
+	 * Shared IRQ handling in INTX mode
+	 */
+	ioc->ioc_regs.shirq_isr_next = rb + iocreg_shirq_next[pcifn].isr;
+	ioc->ioc_regs.shirq_msk_next = rb + iocreg_shirq_next[pcifn].msk;
+
+	/*
+	 * PSS control registers
+	 */
+	ioc->ioc_regs.pss_ctl_reg = (rb + PSS_CTL_REG);
+	ioc->ioc_regs.app_pll_fast_ctl_reg = (rb + APP_PLL_425_CTL_REG);
+	ioc->ioc_regs.app_pll_slow_ctl_reg = (rb + APP_PLL_312_CTL_REG);
+
+	/*
+	 * IOC semaphore registers and serialization
+	 */
+	ioc->ioc_regs.ioc_sem_reg = (rb + HOST_SEM0_REG);
+	ioc->ioc_regs.ioc_usage_sem_reg = (rb + HOST_SEM1_REG);
+	ioc->ioc_regs.ioc_usage_reg = (rb + BFA_FW_USE_COUNT);
+
+	/**
+	 * sram memory access
+	 */
+	ioc->ioc_regs.smem_page_start = (rb + PSS_SMEM_PAGE_START);
+	ioc->ioc_regs.smem_pg0 = BFI_IOC_SMEM_PG0_CB;
+	if (ioc->pcidev.device_id == BFA_PCI_DEVICE_ID_CT)
+		ioc->ioc_regs.smem_pg0 = BFI_IOC_SMEM_PG0_CT;
+}
+
+/**
+ *      Initiate a full firmware download.
+ */
+static void
+bfa_ioc_download_fw(struct bfa_ioc_s *ioc, u32 boot_type,
+		    u32 boot_param)
+{
+	u32       *fwimg;
+	u32        pgnum, pgoff;
+	u32        loff = 0;
+	u32        chunkno = 0;
+	u32        i;
+
+	/**
+	 * Initialize LMEM first before code download
+	 */
+	bfa_ioc_lmem_init(ioc);
+
+	/**
+	 * Flash based firmware boot
+	 */
+	if (bfa_ioc_fwimg_get_size(ioc) < BFA_IOC_FWIMG_MINSZ)
+		boot_type = BFI_BOOT_TYPE_FLASH;
+	fwimg = bfa_ioc_fwimg_get_chunk(ioc, chunkno);
+	fwimg[BFI_BOOT_TYPE_OFF / sizeof(u32)] = bfa_os_swap32(boot_type);
+	fwimg[BFI_BOOT_PARAM_OFF / sizeof(u32)] =
+		bfa_os_swap32(boot_param);
+
+	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
+
+	bfa_reg_write(ioc->ioc_regs.host_page_num_fn, pgnum);
+
+	for (i = 0; i < bfa_ioc_fwimg_get_size(ioc); i++) {
+
+		if (BFA_FLASH_CHUNK_NO(i) != chunkno) {
+			chunkno = BFA_FLASH_CHUNK_NO(i);
+			fwimg = bfa_ioc_fwimg_get_chunk(ioc,
+					BFA_FLASH_CHUNK_ADDR(chunkno));
+		}
+
+		/**
+		 * write smem
+		 */
+		bfa_mem_write(ioc->ioc_regs.smem_page_start, loff,
+			      fwimg[BFA_FLASH_OFFSET_IN_CHUNK(i)]);
+
+		loff += sizeof(u32);
+
+		/**
+		 * handle page offset wrap around
+		 */
+		loff = PSS_SMEM_PGOFF(loff);
+		if (loff == 0) {
+			pgnum++;
+			bfa_reg_write(ioc->ioc_regs.host_page_num_fn, pgnum);
+		}
+	}
+
+	bfa_reg_write(ioc->ioc_regs.host_page_num_fn,
+		      bfa_ioc_smem_pgnum(ioc, 0));
+}
+
+static void
+bfa_ioc_reset(struct bfa_ioc_s *ioc, bfa_boolean_t force)
+{
+	bfa_ioc_hwinit(ioc, force);
+}
+
+/**
+ * Update BFA configuration from firmware configuration.
+ */
+static void
+bfa_ioc_getattr_reply(struct bfa_ioc_s *ioc)
+{
+	struct bfi_ioc_attr_s *attr = ioc->attr;
+
+	attr->adapter_prop = bfa_os_ntohl(attr->adapter_prop);
+	attr->maxfrsize = bfa_os_ntohs(attr->maxfrsize);
+
+	bfa_fsm_send_event(ioc, IOC_E_FWRSP_GETATTR);
+}
+
+/**
+ * Attach time initialization of mbox logic.
+ */
+static void
+bfa_ioc_mbox_attach(struct bfa_ioc_s *ioc)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+	int             mc;
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
+bfa_ioc_mbox_poll(struct bfa_ioc_s *ioc)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+	struct bfa_mbox_cmd_s *cmd;
+	u32        stat;
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
+	stat = bfa_reg_read(ioc->ioc_regs.hfn_mbox_cmd);
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
+bfa_ioc_mbox_hbfail(struct bfa_ioc_s *ioc)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+	struct bfa_mbox_cmd_s *cmd;
+
+	while (!list_empty(&mod->cmd_q))
+		bfa_q_deq(&mod->cmd_q, &cmd);
+}
+
+/**
+ * Initialize IOC to port mapping.
+ */
+
+#define FNC_PERS_FN_SHIFT(__fn)	((__fn) * 8)
+static void
+bfa_ioc_map_port(struct bfa_ioc_s *ioc)
+{
+	bfa_os_addr_t   rb = ioc->pcidev.pci_bar_kva;
+	u32        r32;
+
+	/**
+	 * For crossbow, port id is same as pci function.
+	 */
+	if (ioc->pcidev.device_id != BFA_PCI_DEVICE_ID_CT) {
+		ioc->port_id = bfa_ioc_pcifn(ioc);
+		return;
+	}
+
+	/**
+	 * For catapult, base port id on personality register and IOC type
+	 */
+	r32 = bfa_reg_read(rb + FNC_PERS_REG);
+	r32 >>= FNC_PERS_FN_SHIFT(bfa_ioc_pcifn(ioc));
+	ioc->port_id = (r32 & __F0_PORT_MAP_MK) >> __F0_PORT_MAP_SH;
+
+}
+
+
+
+/**
+ *  bfa_ioc_public
+ */
+
+/**
+* Set interrupt mode for a function: INTX or MSIX
+ */
+void
+bfa_ioc_isr_mode_set(struct bfa_ioc_s *ioc, bfa_boolean_t msix)
+{
+	bfa_os_addr_t   rb = ioc->pcidev.pci_bar_kva;
+	u32        r32, mode;
+
+	r32 = bfa_reg_read(rb + FNC_PERS_REG);
+
+	mode = (r32 >> FNC_PERS_FN_SHIFT(bfa_ioc_pcifn(ioc))) &
+		__F0_INTX_STATUS;
+
+	/**
+	 * If already in desired mode, do not change anything
+	 */
+	if (!msix && mode)
+		return;
+
+	if (msix)
+		mode = __F0_INTX_STATUS_MSIX;
+	else
+		mode = __F0_INTX_STATUS_INTA;
+
+	r32 &= ~(__F0_INTX_STATUS << FNC_PERS_FN_SHIFT(bfa_ioc_pcifn(ioc)));
+	r32 |= (mode << FNC_PERS_FN_SHIFT(bfa_ioc_pcifn(ioc)));
+
+	bfa_reg_write(rb + FNC_PERS_REG, r32);
+}
+
+bfa_status_t
+bfa_ioc_pll_init(struct bfa_ioc_s *ioc)
+{
+	bfa_os_addr_t   rb = ioc->pcidev.pci_bar_kva;
+	u32        pll_sclk, pll_fclk, r32;
+
+	if (ioc->pcidev.device_id == BFA_PCI_DEVICE_ID_CT) {
+		pll_sclk =
+			__APP_PLL_312_ENABLE | __APP_PLL_312_LRESETN |
+			__APP_PLL_312_RSEL200500 | __APP_PLL_312_P0_1(0U) |
+			__APP_PLL_312_JITLMT0_1(3U) |
+			__APP_PLL_312_CNTLMT0_1(1U);
+		pll_fclk =
+			__APP_PLL_425_ENABLE | __APP_PLL_425_LRESETN |
+			__APP_PLL_425_RSEL200500 | __APP_PLL_425_P0_1(0U) |
+			__APP_PLL_425_JITLMT0_1(3U) |
+			__APP_PLL_425_CNTLMT0_1(1U);
+
+		/**
+		 * 	For catapult, choose operational mode FC/FCoE
+		 */
+		if (ioc->fcmode) {
+			bfa_reg_write((rb + OP_MODE), 0);
+			bfa_reg_write((rb + ETH_MAC_SER_REG),
+				      __APP_EMS_CMLCKSEL | __APP_EMS_REFCKBUFEN2
+				      | __APP_EMS_CHANNEL_SEL);
+		} else {
+			ioc->pllinit = BFA_TRUE;
+			bfa_reg_write((rb + OP_MODE), __GLOBAL_FCOE_MODE);
+			bfa_reg_write((rb + ETH_MAC_SER_REG),
+				      __APP_EMS_REFCKBUFEN1);
+		}
+	} else {
+		pll_sclk =
+			__APP_PLL_312_ENABLE | __APP_PLL_312_LRESETN |
+			__APP_PLL_312_P0_1(3U) | __APP_PLL_312_JITLMT0_1(3U) |
+			__APP_PLL_312_CNTLMT0_1(3U);
+		pll_fclk =
+			__APP_PLL_425_ENABLE | __APP_PLL_425_LRESETN |
+			__APP_PLL_425_RSEL200500 | __APP_PLL_425_P0_1(3U) |
+			__APP_PLL_425_JITLMT0_1(3U) |
+			__APP_PLL_425_CNTLMT0_1(3U);
+	}
+
+	bfa_reg_write((rb + BFA_IOC0_STATE_REG), BFI_IOC_UNINIT);
+	bfa_reg_write((rb + BFA_IOC1_STATE_REG), BFI_IOC_UNINIT);
+
+	bfa_reg_write((rb + HOSTFN0_INT_MSK), 0xffffffffU);
+	bfa_reg_write((rb + HOSTFN1_INT_MSK), 0xffffffffU);
+	bfa_reg_write((rb + HOSTFN0_INT_STATUS), 0xffffffffU);
+	bfa_reg_write((rb + HOSTFN1_INT_STATUS), 0xffffffffU);
+	bfa_reg_write((rb + HOSTFN0_INT_MSK), 0xffffffffU);
+	bfa_reg_write((rb + HOSTFN1_INT_MSK), 0xffffffffU);
+
+	bfa_reg_write(ioc->ioc_regs.app_pll_slow_ctl_reg,
+		      __APP_PLL_312_LOGIC_SOFT_RESET);
+	bfa_reg_write(ioc->ioc_regs.app_pll_slow_ctl_reg,
+		      __APP_PLL_312_BYPASS | __APP_PLL_312_LOGIC_SOFT_RESET);
+	bfa_reg_write(ioc->ioc_regs.app_pll_fast_ctl_reg,
+		      __APP_PLL_425_LOGIC_SOFT_RESET);
+	bfa_reg_write(ioc->ioc_regs.app_pll_fast_ctl_reg,
+		      __APP_PLL_425_BYPASS | __APP_PLL_425_LOGIC_SOFT_RESET);
+	bfa_os_udelay(2);
+	bfa_reg_write(ioc->ioc_regs.app_pll_slow_ctl_reg,
+		      __APP_PLL_312_LOGIC_SOFT_RESET);
+	bfa_reg_write(ioc->ioc_regs.app_pll_fast_ctl_reg,
+		      __APP_PLL_425_LOGIC_SOFT_RESET);
+
+	bfa_reg_write(ioc->ioc_regs.app_pll_slow_ctl_reg,
+		      pll_sclk | __APP_PLL_312_LOGIC_SOFT_RESET);
+	bfa_reg_write(ioc->ioc_regs.app_pll_fast_ctl_reg,
+		      pll_fclk | __APP_PLL_425_LOGIC_SOFT_RESET);
+
+	/**
+	 * Wait for PLLs to lock.
+	 */
+	bfa_os_udelay(2000);
+	bfa_reg_write((rb + HOSTFN0_INT_STATUS), 0xffffffffU);
+	bfa_reg_write((rb + HOSTFN1_INT_STATUS), 0xffffffffU);
+
+	bfa_reg_write(ioc->ioc_regs.app_pll_slow_ctl_reg, pll_sclk);
+	bfa_reg_write(ioc->ioc_regs.app_pll_fast_ctl_reg, pll_fclk);
+
+	if (ioc->pcidev.device_id == BFA_PCI_DEVICE_ID_CT) {
+		bfa_reg_write((rb + MBIST_CTL_REG), __EDRAM_BISTR_START);
+		bfa_os_udelay(1000);
+		r32 = bfa_reg_read((rb + MBIST_STAT_REG));
+	}
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * Interface used by diag module to do firmware boot with memory test
+ * as the entry vector.
+ */
+void
+bfa_ioc_boot(struct bfa_ioc_s *ioc, u32 boot_type, u32 boot_param)
+{
+	bfa_os_addr_t   rb;
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
+		bfa_reg_write((rb + BFA_IOC0_STATE_REG), BFI_IOC_MEMTEST);
+		bfa_reg_write((rb + BFA_IOC1_STATE_REG), BFI_IOC_MEMTEST);
+	} else {
+		bfa_reg_write((rb + BFA_IOC0_STATE_REG), BFI_IOC_INITING);
+		bfa_reg_write((rb + BFA_IOC1_STATE_REG), BFI_IOC_INITING);
+	}
+
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
+bfa_ioc_auto_recover(bfa_boolean_t auto_recover)
+{
+	bfa_auto_recover = BFA_FALSE;
+}
+
+
+bfa_boolean_t
+bfa_ioc_is_operational(struct bfa_ioc_s *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_op);
+}
+
+void
+bfa_ioc_msgget(struct bfa_ioc_s *ioc, void *mbmsg)
+{
+	u32       *msgp = mbmsg;
+	u32        r32;
+	int             i;
+
+	/**
+	 * read the MBOX msg
+	 */
+	for (i = 0; i < (sizeof(union bfi_ioc_i2h_msg_u) / sizeof(u32));
+	     i++) {
+		r32 = bfa_reg_read(ioc->ioc_regs.lpu_mbox +
+				   i * sizeof(u32));
+		msgp[i] = bfa_os_htonl(r32);
+	}
+
+	/**
+	 * turn off mailbox interrupt by clearing mailbox status
+	 */
+	bfa_reg_write(ioc->ioc_regs.lpu_mbox_cmd, 1);
+	bfa_reg_read(ioc->ioc_regs.lpu_mbox_cmd);
+}
+
+void
+bfa_ioc_isr(struct bfa_ioc_s *ioc, struct bfi_mbmsg_s *m)
+{
+	union bfi_ioc_i2h_msg_u *msg;
+
+	msg = (union bfi_ioc_i2h_msg_u *)m;
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
+		bfa_assert(0);
+	}
+}
+
+/**
+ * IOC attach time initialization and setup.
+ *
+ * @param[in]	ioc	memory for IOC
+ * @param[in]	bfa	driver instance structure
+ * @param[in]	trcmod	kernel trace module
+ * @param[in]	aen	kernel aen event module
+ * @param[in]	logm	kernel logging module
+ */
+void
+bfa_ioc_attach(struct bfa_ioc_s *ioc, void *bfa, struct bfa_ioc_cbfn_s *cbfn,
+	       struct bfa_timer_mod_s *timer_mod, struct bfa_trc_mod_s *trcmod,
+	       struct bfa_aen_s *aen, struct bfa_log_mod_s *logm)
+{
+	ioc->bfa = bfa;
+	ioc->cbfn = cbfn;
+	ioc->timer_mod = timer_mod;
+	ioc->trcmod = trcmod;
+	ioc->aen = aen;
+	ioc->logm = logm;
+	ioc->fcmode = BFA_FALSE;
+	ioc->pllinit = BFA_FALSE;
+	ioc->dbg_fwsave_once = BFA_TRUE;
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
+bfa_ioc_detach(struct bfa_ioc_s *ioc)
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
+bfa_ioc_pci_init(struct bfa_ioc_s *ioc, struct bfa_pcidev_s *pcidev,
+		 enum bfi_mclass mc)
+{
+	ioc->ioc_mc = mc;
+	ioc->pcidev = *pcidev;
+	ioc->ctdev = (ioc->pcidev.device_id == BFA_PCI_DEVICE_ID_CT);
+	ioc->cna = ioc->ctdev && !ioc->fcmode;
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
+bfa_ioc_mem_claim(struct bfa_ioc_s *ioc, u8 *dm_kva, u64 dm_pa)
+{
+	/**
+	 * dma memory for firmware attribute
+	 */
+	ioc->attr_dma.kva = dm_kva;
+	ioc->attr_dma.pa = dm_pa;
+	ioc->attr = (struct bfi_ioc_attr_s *)dm_kva;
+}
+
+/**
+ * Return size of dma memory required.
+ */
+u32
+bfa_ioc_meminfo(void)
+{
+	return BFA_ROUNDUP(sizeof(struct bfi_ioc_attr_s), BFA_DMA_ALIGN_SZ);
+}
+
+void
+bfa_ioc_enable(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_stats(ioc, ioc_enables);
+	ioc->dbg_fwsave_once = BFA_TRUE;
+
+	bfa_fsm_send_event(ioc, IOC_E_ENABLE);
+}
+
+void
+bfa_ioc_disable(struct bfa_ioc_s *ioc)
+{
+	bfa_ioc_stats(ioc, ioc_disables);
+	bfa_fsm_send_event(ioc, IOC_E_DISABLE);
+}
+
+/**
+ * Returns memory required for saving firmware trace in case of crash.
+ * Driver must call this interface to allocate memory required for
+ * automatic saving of firmware trace. Driver should call
+ * bfa_ioc_debug_memclaim() right after bfa_ioc_attach() to setup this
+ * trace memory.
+ */
+int
+bfa_ioc_debug_trcsz(bfa_boolean_t auto_recover)
+{
+return (auto_recover) ? BFA_DBG_FWTRC_LEN : 0;
+}
+
+/**
+ * Initialize memory for saving firmware trace. Driver must initialize
+ * trace memory before call bfa_ioc_enable().
+ */
+void
+bfa_ioc_debug_memclaim(struct bfa_ioc_s *ioc, void *dbg_fwsave)
+{
+	bfa_assert(ioc->auto_recover);
+	ioc->dbg_fwsave = dbg_fwsave;
+	ioc->dbg_fwsave_len = bfa_ioc_debug_trcsz(ioc->auto_recover);
+}
+
+u32
+bfa_ioc_smem_pgnum(struct bfa_ioc_s *ioc, u32 fmaddr)
+{
+	return PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, fmaddr);
+}
+
+u32
+bfa_ioc_smem_pgoff(struct bfa_ioc_s *ioc, u32 fmaddr)
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
+bfa_ioc_mbox_register(struct bfa_ioc_s *ioc, bfa_ioc_mbox_mcfunc_t *mcfuncs)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+	int             mc;
+
+	for (mc = 0; mc < BFI_MC_MAX; mc++)
+		mod->mbhdlr[mc].cbfn = mcfuncs[mc];
+}
+
+/**
+ * Register mailbox message handler function, to be called by common modules
+ */
+void
+bfa_ioc_mbox_regisr(struct bfa_ioc_s *ioc, enum bfi_mclass mc,
+		    bfa_ioc_mbox_mcfunc_t cbfn, void *cbarg)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+
+	mod->mbhdlr[mc].cbfn = cbfn;
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
+bfa_ioc_mbox_queue(struct bfa_ioc_s *ioc, struct bfa_mbox_cmd_s *cmd)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+	u32        stat;
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
+	stat = bfa_reg_read(ioc->ioc_regs.hfn_mbox_cmd);
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
+bfa_ioc_mbox_isr(struct bfa_ioc_s *ioc)
+{
+	struct bfa_ioc_mbox_mod_s *mod = &ioc->mbox_mod;
+	struct bfi_mbmsg_s m;
+	int             mc;
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
+bfa_ioc_error_isr(struct bfa_ioc_s *ioc)
+{
+	bfa_fsm_send_event(ioc, IOC_E_HWERROR);
+}
+
+#ifndef BFA_BIOS_BUILD
+
+/**
+ * return true if IOC is disabled
+ */
+bfa_boolean_t
+bfa_ioc_is_disabled(struct bfa_ioc_s *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabling)
+		|| bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabled);
+}
+
+/**
+ * return true if IOC firmware is different.
+ */
+bfa_boolean_t
+bfa_ioc_fw_mismatch(struct bfa_ioc_s *ioc)
+{
+	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_reset)
+		|| bfa_fsm_cmp_state(ioc, bfa_ioc_sm_fwcheck)
+		|| bfa_fsm_cmp_state(ioc, bfa_ioc_sm_mismatch);
+}
+
+#define bfa_ioc_state_disabled(__sm)		\
+	(((__sm) == BFI_IOC_UNINIT) ||		\
+	 ((__sm) == BFI_IOC_INITING) ||		\
+	 ((__sm) == BFI_IOC_HWINIT) ||		\
+	 ((__sm) == BFI_IOC_DISABLED) ||	\
+	 ((__sm) == BFI_IOC_HBFAIL) ||		\
+	 ((__sm) == BFI_IOC_CFG_DISABLED))
+
+/**
+ * Check if adapter is disabled -- both IOCs should be in a disabled
+ * state.
+ */
+bfa_boolean_t
+bfa_ioc_adapter_is_disabled(struct bfa_ioc_s *ioc)
+{
+	u32        ioc_state;
+	bfa_os_addr_t   rb = ioc->pcidev.pci_bar_kva;
+
+	if (!bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabled))
+		return BFA_FALSE;
+
+	ioc_state = bfa_reg_read(rb + BFA_IOC0_STATE_REG);
+	if (!bfa_ioc_state_disabled(ioc_state))
+		return BFA_FALSE;
+
+	ioc_state = bfa_reg_read(rb + BFA_IOC1_STATE_REG);
+	if (!bfa_ioc_state_disabled(ioc_state))
+		return BFA_FALSE;
+
+	return BFA_TRUE;
+}
+
+/**
+ * Add to IOC heartbeat failure notification queue. To be used by common
+ * modules such as
+ */
+void
+bfa_ioc_hbfail_register(struct bfa_ioc_s *ioc,
+			struct bfa_ioc_hbfail_notify_s *notify)
+{
+	list_add_tail(&notify->qe, &ioc->hb_notify_q);
+}
+
+#define BFA_MFG_NAME "Brocade"
+void
+bfa_ioc_get_adapter_attr(struct bfa_ioc_s *ioc,
+			 struct bfa_adapter_attr_s *ad_attr)
+{
+	struct bfi_ioc_attr_s *ioc_attr;
+	char            model[BFA_ADAPTER_MODEL_NAME_LEN];
+
+	ioc_attr = ioc->attr;
+	bfa_os_memcpy((void *)&ad_attr->serial_num,
+		      (void *)ioc_attr->brcd_serialnum,
+		      BFA_ADAPTER_SERIAL_NUM_LEN);
+
+	bfa_os_memcpy(&ad_attr->fw_ver, ioc_attr->fw_version, BFA_VERSION_LEN);
+	bfa_os_memcpy(&ad_attr->optrom_ver, ioc_attr->optrom_version,
+		      BFA_VERSION_LEN);
+	bfa_os_memcpy(&ad_attr->manufacturer, BFA_MFG_NAME,
+		      BFA_ADAPTER_MFG_NAME_LEN);
+	bfa_os_memcpy(&ad_attr->vpd, &ioc_attr->vpd,
+		      sizeof(struct bfa_mfg_vpd_s));
+
+	ad_attr->nports = BFI_ADAPTER_GETP(NPORTS, ioc_attr->adapter_prop);
+	ad_attr->max_speed = BFI_ADAPTER_GETP(SPEED, ioc_attr->adapter_prop);
+
+	/**
+	 * model name
+	 */
+	if (BFI_ADAPTER_GETP(SPEED, ioc_attr->adapter_prop) == 10) {
+		strcpy(model, "BR-10?0");
+		model[5] = '0' + ad_attr->nports;
+	} else {
+		strcpy(model, "Brocade-??5");
+		model[8] =
+			'0' + BFI_ADAPTER_GETP(SPEED, ioc_attr->adapter_prop);
+		model[9] = '0' + ad_attr->nports;
+	}
+
+	if (BFI_ADAPTER_IS_SPECIAL(ioc_attr->adapter_prop))
+		ad_attr->prototype = 1;
+	else
+		ad_attr->prototype = 0;
+
+	bfa_os_memcpy(&ad_attr->model, model, BFA_ADAPTER_MODEL_NAME_LEN);
+	bfa_os_memcpy(&ad_attr->model_descr, &ad_attr->model,
+		      BFA_ADAPTER_MODEL_NAME_LEN);
+
+	ad_attr->pwwn = bfa_ioc_get_pwwn(ioc);
+	ad_attr->mac = bfa_ioc_get_mac(ioc);
+
+	ad_attr->pcie_gen = ioc_attr->pcie_gen;
+	ad_attr->pcie_lanes = ioc_attr->pcie_lanes;
+	ad_attr->pcie_lanes_orig = ioc_attr->pcie_lanes_orig;
+	ad_attr->asic_rev = ioc_attr->asic_rev;
+	ad_attr->hw_ver[0] = 'R';
+	ad_attr->hw_ver[1] = 'e';
+	ad_attr->hw_ver[2] = 'v';
+	ad_attr->hw_ver[3] = '-';
+	ad_attr->hw_ver[4] = ioc_attr->asic_rev;
+	ad_attr->hw_ver[5] = '\0';
+
+	ad_attr->cna_capable = ioc->cna;
+}
+
+void
+bfa_ioc_get_attr(struct bfa_ioc_s *ioc, struct bfa_ioc_attr_s *ioc_attr)
+{
+	bfa_os_memset((void *)ioc_attr, 0, sizeof(struct bfa_ioc_attr_s));
+
+	ioc_attr->state = bfa_sm_to_state(ioc_sm_table, ioc->fsm);
+	ioc_attr->port_id = ioc->port_id;
+
+	if (!ioc->ctdev)
+		ioc_attr->ioc_type = BFA_IOC_TYPE_FC;
+	else if (ioc->ioc_mc == BFI_MC_IOCFC)
+		ioc_attr->ioc_type = BFA_IOC_TYPE_FCoE;
+	else if (ioc->ioc_mc == BFI_MC_LL)
+		ioc_attr->ioc_type = BFA_IOC_TYPE_LL;
+
+	bfa_ioc_get_adapter_attr(ioc, &ioc_attr->adapter_attr);
+
+	ioc_attr->pci_attr.device_id = ioc->pcidev.device_id;
+	ioc_attr->pci_attr.pcifn = ioc->pcidev.pci_func;
+	ioc_attr->pci_attr.chip_rev[0] = 'R';
+	ioc_attr->pci_attr.chip_rev[1] = 'e';
+	ioc_attr->pci_attr.chip_rev[2] = 'v';
+	ioc_attr->pci_attr.chip_rev[3] = '-';
+	ioc_attr->pci_attr.chip_rev[4] = ioc_attr->adapter_attr.asic_rev;
+	ioc_attr->pci_attr.chip_rev[5] = '\0';
+}
+
+/**
+ *  hal_wwn_public
+ */
+wwn_t
+bfa_ioc_get_pwwn(struct bfa_ioc_s *ioc)
+{
+	union {
+		wwn_t           wwn;
+		u8         byte[sizeof(wwn_t)];
+	}
+	w;
+
+	w.wwn = ioc->attr->mfg_wwn;
+
+	if (bfa_ioc_portid(ioc) == 1)
+		w.byte[7]++;
+
+	return w.wwn;
+}
+
+wwn_t
+bfa_ioc_get_nwwn(struct bfa_ioc_s *ioc)
+{
+	union {
+		wwn_t           wwn;
+		u8         byte[sizeof(wwn_t)];
+	}
+	w;
+
+	w.wwn = ioc->attr->mfg_wwn;
+
+	if (bfa_ioc_portid(ioc) == 1)
+		w.byte[7]++;
+
+	w.byte[0] = 0x20;
+
+	return w.wwn;
+}
+
+wwn_t
+bfa_ioc_get_wwn_naa5(struct bfa_ioc_s *ioc, u16 inst)
+{
+	union {
+		wwn_t           wwn;
+		u8         byte[sizeof(wwn_t)];
+	}
+	w              , w5;
+
+
+	w.wwn = ioc->attr->mfg_wwn;
+	w5.byte[0] = 0x50 | w.byte[2] >> 4;
+	w5.byte[1] = w.byte[2] << 4 | w.byte[3] >> 4;
+	w5.byte[2] = w.byte[3] << 4 | w.byte[4] >> 4;
+	w5.byte[3] = w.byte[4] << 4 | w.byte[5] >> 4;
+	w5.byte[4] = w.byte[5] << 4 | w.byte[6] >> 4;
+	w5.byte[5] = w.byte[6] << 4 | w.byte[7] >> 4;
+	w5.byte[6] = w.byte[7] << 4 | (inst & 0x0f00) >> 8;
+	w5.byte[7] = (inst & 0xff);
+
+	return w5.wwn;
+}
+
+u64
+bfa_ioc_get_adid(struct bfa_ioc_s *ioc)
+{
+	return ioc->attr->mfg_wwn;
+}
+
+mac_t
+bfa_ioc_get_mac(struct bfa_ioc_s *ioc)
+{
+	mac_t           mac;
+
+	mac = ioc->attr->mfg_mac;
+	mac.mac[MAC_ADDRLEN - 1] += bfa_ioc_pcifn(ioc);
+
+	return mac;
+}
+
+void
+bfa_ioc_set_fcmode(struct bfa_ioc_s *ioc)
+{
+	ioc->fcmode = BFA_TRUE;
+	ioc->port_id = bfa_ioc_pcifn(ioc);
+}
+
+bfa_boolean_t
+bfa_ioc_get_fcmode(struct bfa_ioc_s *ioc)
+{
+	return ioc->fcmode || (ioc->pcidev.device_id != BFA_PCI_DEVICE_ID_CT);
+}
+
+/**
+ * Return true if interrupt should be claimed.
+ */
+bfa_boolean_t
+bfa_ioc_intx_claim(struct bfa_ioc_s *ioc)
+{
+	u32        isr, msk;
+
+	/**
+	 * Always claim if not catapult.
+	 */
+	if (!ioc->ctdev)
+		return BFA_TRUE;
+
+	/**
+	 * FALSE if next device is claiming interrupt.
+	 * TRUE if next device is not interrupting or not present.
+	 */
+	msk = bfa_reg_read(ioc->ioc_regs.shirq_msk_next);
+	isr = bfa_reg_read(ioc->ioc_regs.shirq_isr_next);
+	return !(isr & ~msk);
+}
+
+/**
+ * Retrieve saved firmware trace from a prior IOC failure.
+ */
+bfa_status_t
+bfa_ioc_debug_fwsave(struct bfa_ioc_s *ioc, void *trcdata, int *trclen)
+{
+	int             tlen;
+
+	if (ioc->dbg_fwsave_len == 0)
+		return BFA_STATUS_ENOFSAVE;
+
+	tlen = *trclen;
+	if (tlen > ioc->dbg_fwsave_len)
+		tlen = ioc->dbg_fwsave_len;
+
+	bfa_os_memcpy(trcdata, ioc->dbg_fwsave, tlen);
+	*trclen = tlen;
+	return BFA_STATUS_OK;
+}
+
+/**
+ * Retrieve saved firmware trace from a prior IOC failure.
+ */
+bfa_status_t
+bfa_ioc_debug_fwtrc(struct bfa_ioc_s *ioc, void *trcdata, int *trclen)
+{
+	u32        pgnum;
+	u32        loff = BFA_DBG_FWTRC_OFF(bfa_ioc_portid(ioc));
+	int             i, tlen;
+	u32       *tbuf = trcdata, r32;
+
+
+	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	loff = bfa_ioc_smem_pgoff(ioc, loff);
+	bfa_reg_write(ioc->ioc_regs.host_page_num_fn, pgnum);
+
+	tlen = *trclen;
+	if (tlen > BFA_DBG_FWTRC_LEN)
+		tlen = BFA_DBG_FWTRC_LEN;
+	tlen /= sizeof(u32);
+
+
+	for (i = 0; i < tlen; i++) {
+		r32 = bfa_mem_read(ioc->ioc_regs.smem_page_start, loff);
+		tbuf[i] = bfa_os_ntohl(r32);
+		loff += sizeof(u32);
+
+		/**
+		 * handle page offset wrap around
+		 */
+		loff = PSS_SMEM_PGOFF(loff);
+		if (loff == 0) {
+			pgnum++;
+			bfa_reg_write(ioc->ioc_regs.host_page_num_fn, pgnum);
+		}
+	}
+	bfa_reg_write(ioc->ioc_regs.host_page_num_fn,
+		      bfa_ioc_smem_pgnum(ioc, 0));
+
+	*trclen = tlen * sizeof(u32);
+	return BFA_STATUS_OK;
+}
+
+/**
+ * Save firmware trace if configured.
+ */
+static void
+bfa_ioc_debug_save(struct bfa_ioc_s *ioc)
+{
+	int             tlen;
+
+	if (ioc->dbg_fwsave_len) {
+		tlen = ioc->dbg_fwsave_len;
+		bfa_ioc_debug_fwtrc(ioc, ioc->dbg_fwsave, &tlen);
+	}
+}
+
+/**
+ * Firmware failure detected. Start recovery actions.
+ */
+static void
+bfa_ioc_recover(struct bfa_ioc_s *ioc)
+{
+	if (ioc->dbg_fwsave_once) {
+		ioc->dbg_fwsave_once = BFA_FALSE;
+		bfa_ioc_debug_save(ioc);
+	}
+
+	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
+}
+
+#else
+
+static void
+bfa_ioc_recover(struct bfa_ioc_s *ioc)
+{
+	bfa_assert(0);
+}
+
+#endif
+
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_sm.c linux-2.6.32-rc4-mod/drivers/net/bna/bfa_sm.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_sm.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_sm.c	2009-10-16 10:30:53.456445000 -0700
@@ -0,0 +1,45 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfasm.c BFA State machine utility functions
+ */
+
+#include <cs/bfa_sm.h>
+
+/**
+ *  cs_sm_api
+ */
+
+int
+bfa_sm_to_state(struct bfa_sm_table_s *smt, bfa_sm_t sm)
+{
+	int             i = 0;
+
+	while (smt[i].sm && smt[i].sm != sm)
+		i++;
+	return smt[i].state;
+}
+
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad_compat.h linux-2.6.32-rc4-mod/drivers/net/bna/bnad_compat.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bnad_compat.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad_compat.h	2009-10-16 10:30:53.536442000 -0700
@@ -0,0 +1,111 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * All rights reserved.
+ */
+
+#ifndef _BNAD_COMPAT_H_
+#define _BNAD_COMPAT_H_
+
+#include <linux/version.h>
+
+#ifndef SET_MODULE_OWNER
+#define SET_MODULE_OWNER(netdev) do { } while (0)
+#endif
+
+#ifndef SET_NETDEV_DEV
+#define SET_NETDEV_DEV(netdev, dev) do { } while (0)
+#endif
+
+#ifndef module_param
+#define module_param(name, type, perm)	MODULE_PARM(name, "i");
+#endif
+
+#ifndef NET_IP_ALIGN
+#define NET_IP_ALIGN 2
+#endif
+
+#ifndef NETDEV_TX_OK
+#define NETDEV_TX_OK 0 /* driver took care of the packet */
+#endif
+
+#ifndef NETDEV_TX_BUSY
+#define NETDEV_TX_BUSY 1 /* driver tx path was busy */
+#endif
+
+#ifndef NETDEV_TX_LOCKED
+#define NETDEV_TX_LOCKED -1 /* driver tx lock was already taken */
+#endif
+
+#ifndef ALIGN
+#define ALIGN(x, a)	(((x) + (a) - 1) & ~((a) - 1))
+#endif
+
+#ifndef ETH_FCS_LEN
+#define ETH_FCS_LEN 4
+#endif
+
+#ifndef CHECKSUM_PARTIAL
+#define CHECKSUM_PARTIAL CHECKSUM_HW
+#endif
+
+#ifndef IRQF_SHARED
+#define IRQF_SHARED SA_SHIRQ
+#endif
+
+#ifndef SKB_DATAREF_SHIFT
+#define skb_header_cloned(_skb) 0
+#endif
+
+#ifndef VERIFY_WRITE
+#define VERIFY_WRITE 1
+#endif
+
+#ifndef VERIFY_READ
+#define VERIFY_READ 0
+#endif
+
+#ifndef dev_err
+#define dev_err(dev, format, arg...)	\
+	printk(KERN_ERR "bna: " format , ## arg)
+#endif
+#ifndef dev_info
+#define dev_info(dev, format, arg...)	\
+	printk(KERN_INFO "bna: " format , ## arg)
+#endif
+#ifndef dev_warn
+#define dev_warn(dev, format, arg...)	\
+	printk(KERN_WARNING "bna: " format , ## arg)
+#endif
+
+#ifndef NETIF_F_GSO
+#define gso_size tso_size
+#endif
+
+/* PCI error recovery support, available in 2.6.16 and later. */
+#define HAVE_PCI_ERROR_RECOVERY
+
+#define BNAD_VLAN_FEATURES
+
+#define netif_rx_schedule_prep(_netdev, _napi)  napi_schedule_prep(_napi)
+#define __netif_rx_schedule(_netdev, _napi)     __napi_schedule(_napi)
+#define netif_rx_complete(_netdev, _napi)       napi_complete(_napi)
+
+
+
+#endif /* _BNAD_COMPAT_H_ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad_defs.h linux-2.6.32-rc4-mod/drivers/net/bna/bnad_defs.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bnad_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad_defs.h	2009-10-16 10:30:53.551449000 -0700
@@ -0,0 +1,36 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * All rights reserved.
+ */
+
+#ifndef _BNAD_DEFS_H_
+#define _BNAD_DEFS_H_
+
+#define BNAD_NAME	"bna"
+#define BNAD_VERSION	"2.0.0.0"
+
+#ifndef PCI_VENDOR_ID_BROCADE
+#define PCI_VENDOR_ID_BROCADE	0x1657
+#endif
+
+#ifndef PCI_DEVICE_ID_BROCADE_CATAPULT
+#define PCI_DEVICE_ID_BROCADE_CATAPULT	0x0014
+#endif
+
+#endif /* _BNAD_DEFS_H_ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_if.c linux-2.6.32-rc4-mod/drivers/net/bna/bna_if.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_if.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_if.c	2009-10-16 10:30:53.472448000 -0700
@@ -0,0 +1,588 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ *	Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *	All rights reserved.
+ *
+ *	file bna_if.c BNA Hardware and Firmware Interface
+ */
+#include <bna_os.h>
+#include "bna.h"
+#include "bna_hwreg.h"
+#include "bna_priv.h"
+#include "bna_iocll.h"
+#include "bna_intr.h"
+#include <bfi/bfi_cee.h>
+#include <protocol/types.h>
+#include <cee/bfa_cee.h>
+
+
+
+
+#define BNA_FLASH_DMA_BUF_SZ	0x010000	/* 64K */
+
+#define DO_CALLBACK(cbfn)	\
+do {				\
+	if (mb_cbfns->cbfn) {      \
+		if (qe && qe->cbarg) {      \
+			(mb_cbfns->cbfn)(qe->cbarg, status);      \
+		} else {					\
+			(mb_cbfns->cbfn)(dev->cbarg, status);      \
+		}			\
+	}			\
+} while (0)
+
+#define DO_DIAG_CALLBACK(cbfn, data)	\
+do {								\
+	if (mb_cbfns->cbfn) {      \
+		if (qe && qe->cbarg) {      \
+			(mb_cbfns->cbfn)(qe->cbarg, data, status);      \
+		} else {					\
+			(mb_cbfns->cbfn)(dev->cbarg, data, status);      \
+		}						\
+	}							\
+} while (0)
+
+#define bna_mbox_q_is_empty(mb_q)		\
+	((mb_q)->producer_index == 		\
+	    (mb_q)->consumer_index)
+
+#define bna_mbox_q_first(mb_q)			\
+	 (&(mb_q)->mb_qe[(mb_q)->consumer_index])
+
+/* FIXME : Should come from the driver */
+static u32 bna_ioc_auto_recover;
+
+/**
+ * bna_register_callback()
+ *
+ *	  Function called by the driver to register a callback
+ *	  with the BNA
+ *
+ * @param[in] bna_dev   - Opaque handle to BNA private device
+ * @param[in] cbfns	- Structure for the callback functions.
+ * @param[in] cbarg	- Argument to use with the callback
+ * @param[in] cmd_code  - Command code exported to the drivers
+ *
+ * @return void
+ */
+void bna_register_callback(struct bna_dev_s *dev, struct bna_mbox_cbfn *cbfns,
+	void *cbarg)
+{
+	bna_os_memcpy(&dev->mb_cbfns, cbfns, sizeof(dev->mb_cbfns));
+	dev->cbarg = cbarg;
+}
+
+void
+bna_mbox_q_init(struct bna_mbox_q *q)
+{
+	BNA_ASSERT(BNA_POWER_OF_2(BNA_MAX_MBOX_CMD_QUEUE));
+
+	q->producer_index = q->consumer_index = 0;
+	q->posted = NULL;
+}
+
+static struct bna_mbox_cmd_qe *
+bna_mbox_enq(struct bna_mbox_q *mbox_q,
+	void *cmd, u32 cmd_len, void *cbarg) {
+	struct bna_mbox_cmd_qe *qe;
+
+	if (!BNA_QE_FREE_CNT(mbox_q, BNA_MAX_MBOX_CMD_QUEUE)) {
+		DPRINTK(WARNING, "No free Mbox Command Element\n");
+		return NULL;
+	}
+
+	DPRINTK(DEBUG, "Mbox PI 0x%x\n", mbox_q->producer_index);
+
+	qe = &mbox_q->mb_qe[mbox_q->producer_index];
+	BNA_QE_INDX_ADD(mbox_q->producer_index, 1,
+	    BNA_MAX_MBOX_CMD_QUEUE);
+	bna_os_memcpy(&qe->cmd.msg[0], cmd, cmd_len);
+	qe->cmd_len = cmd_len;
+	qe->cbarg = cbarg;
+
+	return qe;
+}
+
+static void
+bna_mbox_deq(struct bna_mbox_q *mbox_q)
+{
+
+	DPRINTK(DEBUG, "Mbox CI 0x%x\n", mbox_q->consumer_index);
+
+	/* Free one from the head */
+	BNA_QE_INDX_ADD(mbox_q->consumer_index, 1,
+	    BNA_MAX_MBOX_CMD_QUEUE);
+}
+
+static void
+bna_do_stats_update(struct bna_dev_s *dev, u8 status)
+{
+	if (status != BFI_LL_CMD_OK)
+		return;
+	bna_stats_process(dev);
+}
+
+static void
+bna_do_drv_ll_cb(struct bna_dev_s *dev, u8 cmd_code,
+   u8 status, struct bna_mbox_cmd_qe *qe)
+{
+	struct bna_mbox_cbfn *mb_cbfns = &dev->mb_cbfns;
+
+	switch (cmd_code) {
+	case BFI_LL_I2H_MAC_UCAST_SET_RSP:
+		DO_CALLBACK(ucast_set_cb);
+		break;
+	case BFI_LL_I2H_MAC_UCAST_ADD_RSP:
+		DO_CALLBACK(ucast_add_cb);
+		break;
+	case BFI_LL_I2H_MAC_UCAST_DEL_RSP:
+		DO_CALLBACK(ucast_del_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_ADD_RSP:
+		DO_CALLBACK(mcast_add_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_DEL_RSP:
+		DO_CALLBACK(mcast_del_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_FILTER_RSP:
+		DO_CALLBACK(mcast_filter_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_DEL_ALL_RSP:
+		DO_CALLBACK(mcast_del_all_cb);
+		break;
+	case BFI_LL_I2H_RXF_PROMISCUOUS_SET_RSP:
+		DO_CALLBACK(set_promisc_cb);
+		break;
+	case BFI_LL_I2H_RXF_DEFAULT_SET_RSP:
+		DO_CALLBACK(set_default_cb);
+		break;
+	case BFI_LL_I2H_TXQ_STOP_RSP:
+		DO_CALLBACK(txq_stop_cb);
+		break;
+	case BFI_LL_I2H_RXQ_STOP_RSP:
+		DO_CALLBACK(rxq_stop_cb);
+		break;
+	case BFI_LL_I2H_PORT_ADMIN_RSP:
+		DO_CALLBACK(port_admin_cb);
+		break;
+	case BFI_LL_I2H_STATS_GET_RSP:
+		bna_do_stats_update(dev, status);
+		DO_CALLBACK(stats_get_cb);
+		break;
+	case BFI_LL_I2H_STATS_CLEAR_RSP:
+		DO_CALLBACK(stats_clr_cb);
+		break;
+	case BFI_LL_I2H_LINK_DOWN_AEN:
+		DO_CALLBACK(link_down_cb);
+		break;
+	case BFI_LL_I2H_LINK_UP_AEN:
+		DO_CALLBACK(link_up_cb);
+		break;
+	case BFI_LL_I2H_DIAG_LOOPBACK_RSP:
+		DO_CALLBACK(set_diag_lb_cb);
+		break;
+	case BFI_LL_I2H_SET_PAUSE_RSP:
+		DO_CALLBACK(set_pause_cb);
+		break;
+	case BFI_LL_I2H_MTU_INFO_RSP:
+		DO_CALLBACK(mtu_info_cb);
+		break;
+	case BFI_LL_I2H_RX_RSP:
+		DO_CALLBACK(rxf_cb);
+		break;
+	case BFI_LL_I2H_CEE_DOWN_AEN:
+		break;
+	case BFI_LL_I2H_CEE_UP_AEN:
+		break;
+	default:
+		DPRINTK(WARNING, "cb(): unknown msg Id %d for LL class\n",
+			cmd_code);
+		break;
+	}
+}
+
+
+static enum bna_status_e
+bna_flush_mbox_q(struct bna_dev_s *dev, u8 wait_for_rsp)
+{
+	struct bna_mbox_q *q;
+	struct bna_mbox_cmd_qe *qe = NULL;
+	u8 msg_id = 0, msg_class = 0;
+
+	q = &dev->mbox_q;
+
+	if (bna_mbox_q_is_empty(q))
+		return BNA_OK;
+	if (q->posted != NULL && wait_for_rsp) {
+		qe = (struct bna_mbox_cmd_qe *)(q->posted);
+		/* The driver has to retry */
+		return BNA_BUSY;
+	}
+
+	while (!bna_mbox_q_is_empty(q)) {
+		qe = bna_mbox_q_first(q);
+		msg_class = ((struct bfi_mhdr_s *)(&qe->cmd.msg[0]))->msg_class;
+		msg_id = ((struct bfi_mhdr_s *)(&qe->cmd.msg[0]))->msg_id;
+
+
+		BNA_ASSERT(msg_class == BFI_MC_LL);
+
+		bna_do_drv_ll_cb(dev,  BFA_I2HM(msg_id),
+		    BFI_LL_CMD_NOT_EXEC, qe);
+		bna_mbox_deq(q);
+	}
+	/* Reinit the queue, i.e prod = cons = 0; */
+	bna_mbox_q_init(q);
+	return BNA_OK;
+}
+
+enum bna_status_e
+bna_cleanup(void *bna_dev)
+{
+	struct bna_dev_s *dev = (struct bna_dev_s *)bna_dev;
+
+	dev->msg_ctr = 0;
+
+	return bna_flush_mbox_q(dev, 0);
+}
+
+/**
+ * Check both command queues
+ * Write to mailbox if required
+ */
+static enum bna_status_e
+bna_chk_n_snd_q(struct bna_dev_s *dev)
+{
+	struct bna_mbox_cmd_qe *qe = NULL;
+	struct bna_mbox_q *q;
+	struct bfi_mhdr_s *mh = NULL;
+
+	q = &dev->mbox_q;
+
+	if ((bna_mbox_q_is_empty(q)) || (q->posted != NULL))
+		return BNA_OK;
+
+	qe = bna_mbox_q_first(q);
+	/* Do not post any more commands if disable pending */
+	if (dev->ioc_disable_pending == 1)
+		return BNA_OK;
+
+	mh = ((struct bfi_mhdr_s *)(&qe->cmd.msg[0]));
+	mh->mtag.i2htok = bna_os_htons(dev->msg_ctr);
+	dev->msg_ctr++;
+	bfa_ioc_mbox_queue(&dev->ioc, &qe->cmd);
+	q->posted = qe;
+
+	return BNA_OK;
+}
+
+enum bna_status_e
+bna_mbox_send(struct bna_dev_s *dev, void *cmd, u32 cmd_len,
+    void *cbarg)
+{
+	struct bna_mbox_cmd_qe *qe;
+	struct bna_mbox_q *q;
+
+	BNA_ASSERT(cmd_len <= BNA_MAX_MBOX_CMD_LEN);
+
+	if (dev->ioc_disable_pending) {
+		DPRINTK(WARNING,
+			"IOC Disable is pending :"
+			"Cannot queue Cmd class %d id %d\n",
+			mh->msg_class, mh->msg_id);
+		return BNA_FAIL;
+	}
+
+	if (!bfa_ioc_is_operational(&dev->ioc)) {
+		DPRINTK(ERR,
+			"IOC is not operational :"
+			"Cannot queue Cmd class %d id %d\n",
+			mh->msg_class, mh->msg_id);
+		return BNA_FAIL;
+	}
+
+	q = &dev->mbox_q;
+	qe = bna_mbox_enq(q, cmd, cmd_len, cbarg);
+	if (qe == NULL)
+		return BNA_FAIL;
+	return bna_chk_n_snd_q(dev);
+}
+
+
+/**
+ * Returns 1, if this is an aen, 0 otherwise
+ */
+static int
+bna_is_aen(u8 msg_id)
+{
+	return
+	   (msg_id == BFI_LL_I2H_LINK_DOWN_AEN ||
+	    msg_id == BFI_LL_I2H_LINK_UP_AEN ||
+	    msg_id == BFI_LL_I2H_CEE_DOWN_AEN ||
+	    msg_id == BFI_LL_I2H_CEE_UP_AEN);
+}
+
+static void
+bna_err_handler(struct bna_dev_s *dev, u32 intr_status)
+{
+	u32 curr_mask;
+
+	DPRINTK(DEBUG, "HW ERROR : INT statux 0x%x on port %d\n",
+		intr_status, dev->port);
+
+	bfa_ioc_error_isr(&dev->ioc);
+
+	/*
+	 * Disable all the bits in interrupt mask, including
+	 * the mbox & error bits.
+	 * This is required so that once h/w error hits, we don't
+	 * get into a loop.
+	 */
+	bna_intx_disable(dev, &curr_mask);
+
+	if (dev->mb_cbfns.hw_error_cb)
+		(dev->mb_cbfns.hw_error_cb)(dev->cbarg, 0);
+}
+
+void
+bna_ll_isr(void *llarg, struct bfi_mbmsg_s *msg)
+{
+	u32 aen = 0;
+	struct bna_dev_s *dev = (struct bna_dev_s *)llarg;
+	struct bna_mbox_cmd_qe *qe = NULL;
+	struct bna_mbox_q *mbox_q = NULL;
+	struct bfi_ll_rsp *mb_rsp = NULL;
+
+	mb_rsp = (struct bfi_ll_rsp *)(msg);
+
+	BNA_ASSERT(mb_rsp->mh.msg_class == BFI_MC_LL);
+
+	aen = bna_is_aen(mb_rsp->mh.msg_id);
+	if (!aen) {
+		mbox_q = &dev->mbox_q;
+
+		BNA_ASSERT(!bna_mbox_q_is_empty(mbox_q));
+		qe = bna_mbox_q_first(mbox_q);
+		BNA_ASSERT(mbox_q->posted == qe);
+
+		if (BFA_I2HM(((struct bfi_mhdr_s *)
+			(&qe->cmd.msg[0]))->msg_id) != mb_rsp->mh.msg_id) {
+			DPRINTK(ERR,
+			"Invalid Rsp Msg %d:%d (Expected %d:%d) on %d\n",
+			mb_rsp->mh.msg_class, mb_rsp->mh.msg_id,
+			((struct bfi_mhdr_s *)(&qe->cmd.msg[0]))->msg_class,
+			BFA_I2HM(((struct bfi_mhdr_s *)
+			(&qe->cmd.msg[0]))->msg_id),
+			dev->port);
+			BNA_ASSERT(0);
+			return;
+		}
+		bna_mbox_deq(mbox_q);
+		mbox_q->posted = NULL;
+	}
+	bna_do_drv_ll_cb(dev, mb_rsp->mh.msg_id, mb_rsp->error, qe);
+	bna_chk_n_snd_q(dev);
+}
+
+
+void
+bna_mbox_err_handler(struct bna_dev_s *dev, u32 intr_status)
+{
+	if (BNA_IS_ERR_INTR(intr_status)) {
+		bna_err_handler(dev, intr_status);
+		return;
+	}
+
+	if (BNA_IS_MBOX_INTR(intr_status))
+		bfa_ioc_mbox_isr(&dev->ioc);
+}
+
+/**
+ * bna_port_admin()
+ *
+ *   Enable (up) or disable (down) the interface administratively.
+ *
+ * @param[in]  dev	- pointer to BNA device structure
+ * @param[in]  enable - enable/disable the interface.
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+enum bna_status_e
+bna_port_admin(struct bna_dev_s *bna_dev, enum bna_enable_e enable)
+{
+	struct bna_dev_s *dev = (struct bna_dev_s *)bna_dev;
+	struct bfi_ll_port_admin_req ll_req;
+
+	ll_req.mh.msg_class = BFI_MC_LL;
+	ll_req.mh.msg_id = BFI_LL_H2I_PORT_ADMIN_REQ;
+	ll_req.mh.mtag.i2htok = 0;
+
+	ll_req.up = enable;
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+/**
+ * bna_port_param_get()
+ *
+ *   Get the port parameters.
+ *
+ * @param[in]   dev	   - pointer to BNA device structure
+ * @param[out]  param_ptr - pointer to where the parameters will be returned.
+ *
+ * @return void
+ */
+void
+bna_port_param_get(struct bna_dev_s *dev, struct bna_port_param *param_ptr)
+{
+	param_ptr->supported = BNA_TRUE;
+	param_ptr->advertising = BNA_TRUE;
+	param_ptr->speed = BNA_LINK_SPEED_10Gbps;
+	param_ptr->duplex = BNA_TRUE;
+	param_ptr->autoneg = BNA_FALSE;
+	param_ptr->port = dev->port;
+}
+
+/**
+ * bna_port_mac_get()
+ *
+ *   Get the Burnt-in or permanent MAC address.  This function does not return
+ *   the MAC set thru bna_rxf_ucast_mac_set() but the one that is assigned to
+ *   the port upon reset.
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+ * @param[out] mac_ptr - Burnt-in or permanent MAC address.
+ *
+ * @return void
+ */
+void
+bna_port_mac_get(struct bna_dev_s *bna_dev, u8 *mac_ptr)
+{
+	struct bna_dev_s *dev = (struct bna_dev_s *)bna_dev;
+	mac_t mac;
+
+	mac = bfa_ioc_get_mac(&dev->ioc);
+
+	/* TODO : Use mac_t, remove memcpy */
+	bna_os_memcpy(mac_ptr, &mac, sizeof(mac_t));
+}
+
+/**
+ *	IOC Integration
+ */
+
+/**
+ *	bfa_iocll_cbfn
+ *	Structure for callbacks to be implemented by
+ *	the driver.
+ */
+static struct bfa_ioc_cbfn_s bfa_iocll_cbfn = {
+	bna_iocll_enable_cbfn,
+	bna_iocll_disable_cbfn,
+	bna_iocll_hbfail_cbfn,
+	bna_iocll_reset_cbfn
+};
+
+
+static void
+bna_iocll_memclaim(struct bna_dev_s *dev, struct bna_meminfo *mi)
+{
+
+	bfa_ioc_mem_claim(&dev->ioc, mi[BNA_DMA_MEM_T_ATTR].kva,
+	    mi[BNA_DMA_MEM_T_ATTR].dma);
+
+	if (bna_ioc_auto_recover)
+		bfa_ioc_debug_memclaim(&dev->ioc,
+		    mi[BNA_KVA_MEM_T_FWTRC].kva);
+}
+
+void
+bna_iocll_meminfo(struct bna_dev_s *dev, struct bna_meminfo *mi)
+{
+
+
+	mi[BNA_DMA_MEM_T_ATTR].len =
+	    BNA_ALIGN(bfa_ioc_meminfo(), BNA_PAGE_SIZE);
+
+	mi[BNA_KVA_MEM_T_FWTRC].len =
+	    bfa_ioc_debug_trcsz(bna_ioc_auto_recover);
+}
+
+void
+bna_iocll_attach(struct bna_dev_s *dev, void *bnad, struct bna_meminfo *meminfo,
+    struct bfa_pcidev_s *pcidev, struct bfa_trc_mod_s *trcmod,
+    struct bfa_aen_s *aen, struct bfa_log_mod_s *logm)
+{
+	bfa_ioc_attach(&dev->ioc, bnad, &bfa_iocll_cbfn, &dev->timer_mod,
+		       trcmod, aen, logm);
+	bfa_ioc_pci_init(&dev->ioc, pcidev, BFI_MC_LL);
+
+	bfa_ioc_mbox_regisr(&dev->ioc, BFI_MC_LL, bna_ll_isr, dev);
+	bna_iocll_memclaim(dev, meminfo);
+
+
+	bfa_timer_init(&dev->timer_mod);
+
+}
+
+/**
+ * FIXME :
+ * Either the driver or CAL should serialize
+ * this IOC disable
+ * Currently this is happening indirectly b'cos
+ * bfa_ioc_disable() is not called if there
+ * is an outstanding cmd in the queue, which
+ * could not be flushed.
+ */
+enum bna_status_e
+bna_iocll_disable(struct bna_dev_s *dev)
+{
+	enum bna_status_e ret;
+
+	dev->ioc_disable_pending = 1;
+	ret = bna_flush_mbox_q(dev, 1);
+	if (ret != BNA_OK) {
+		DPRINTK(WARNING, "Unable to flush Mbox Queues [%d]\n", ret);
+		return ret;
+	}
+
+	bfa_ioc_disable(&dev->ioc);
+	dev->ioc_disable_pending = 0;
+
+	return BNA_OK;
+}
+
+void
+bna_iocll_getinfo(struct bna_dev_s *dev, char *serial_num, u32 size)
+{
+	struct bfa_adapter_attr_s ad_attr;
+	u32 length;
+
+	bfa_ioc_get_adapter_attr(&dev->ioc, &ad_attr);
+	length = BNA_MIN(size, sizeof(ad_attr.serial_num));
+	bna_os_memcpy(serial_num, ad_attr.serial_num, length);
+}
+
+/* Dummy */
+/* FIXME : Delete once bfa_diag.c is fixed */
+void
+bfa_pport_beacon(struct bfa_s *bfa, bfa_boolean_t beacon,
+		bfa_boolean_t link_e2e_beacon)
+{
+}
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_iocll.h linux-2.6.32-rc4-mod/drivers/net/bna/bna_iocll.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_iocll.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_iocll.h	2009-10-16 10:30:53.488437000 -0700
@@ -0,0 +1,66 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BNA_IOCLL_H__
+#define __BNA_IOCLL_H__
+
+#include <bfa_ioc.h>
+#include <bfa_timer.h>
+#include <bfi/bfi_ll.h>
+
+#define BNA_IOC_TIMER_FREQ BFA_TIMER_FREQ
+
+/*
+ * LL specific IOC functions.
+ */
+void bna_iocll_meminfo(struct bna_dev_s *bna_dev, struct bna_meminfo *meminfo);
+void bna_iocll_attach(struct bna_dev_s *bna_dev, void *bnad,
+	struct bna_meminfo *meminfo, struct bfa_pcidev_s *pcidev,
+	struct bfa_trc_mod_s *trcmod, struct bfa_aen_s *aen,
+	struct bfa_log_mod_s *logmod);
+enum bna_status_e bna_iocll_disable(struct bna_dev_s *bna_dev);
+void bna_iocll_getinfo(struct bna_dev_s *bna_dev, char *serial_num, u32 size);
+#define bna_iocll_detach(dev) bfa_ioc_detach(&((dev)->ioc))
+#define bna_iocll_enable(dev) bfa_ioc_enable(&((dev)->ioc))
+#define bna_iocll_debug_fwsave(dev, trc_data, trc_len)		\
+	bfa_ioc_debug_fwsave(&((dev)->ioc), (trc_data), (trc_len))
+#define bna_iocll_debug_fwtrc(dev, trc_data, trc_len)		\
+	bfa_ioc_debug_fwtrc(&((dev)->ioc), (trc_data), (trc_len))
+#define bna_iocll_timer(dev) bfa_timer_beat(&((dev)->timer_mod))
+#define bna_iocll_getstats(dev, ioc_stats)	\
+	bfa_ioc_fetch_stats(&((dev)->ioc), (ioc_stats))
+#define bna_iocll_resetstats(dev) bfa_ioc_clr_stats(&((dev)->ioc))
+#define bna_iocll_getattr(dev, ioc_attr)	\
+	bfa_ioc_get_attr(&((dev)->ioc), (ioc_attr))
+
+/**
+ * Callback functions to be implemented by the driver
+ */
+void bna_iocll_enable_cbfn(void *bnad, enum bfa_status status);
+void bna_iocll_disable_cbfn(void *bnad);
+void bna_iocll_hbfail_cbfn(void *bnad);
+void bna_iocll_reset_cbfn(void *bnad);
+
+#endif /* __BNA_IOCLL_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_os.h linux-2.6.32-rc4-mod/drivers/net/bna/bna_os.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_os.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_os.h	2009-10-16 10:30:53.504447000 -0700
@@ -0,0 +1,182 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See <license_file> for copyright and licensing details.
+ */
+
+/**
+ * Contains declarations of linux specific calls required for Brocade
+ * FCoE HBA driver implementation. Each OS has to provide this file.
+ */
+
+/**
+ *  bna_os.h Linux driver OS specific declarations.
+ */
+
+#ifndef __BNA_OS_H__
+#define __BNA_OS_H__
+
+#ifdef __KERNEL__
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/if_ether.h> /* Hack for ETH_ALEN: Do we care ? */
+#include <asm/page.h>
+#include <asm/io.h>
+#include <asm/string.h>
+#else
+#include <sys/io.h>
+#endif
+
+#ifdef __KERNEL__
+
+#define BNA_PAGE_SIZE		PAGE_SIZE
+#define BNA_PAGE_SHIFT		PAGE_SHIFT
+
+#define BNA_ERR			KERN_ERR
+#define BNA_WARNING		KERN_WARNING
+#define BNA_NOTICE		KERN_NOTICE
+#define BNA_INFO		KERN_INFO
+#define BNA_DEBUG		KERN_DEBUG
+
+
+#ifdef DEBUG
+
+#define PFX "BNA: "
+#define DPRINTK(klevel, fmt, args...) do {  \
+		printk(KERN_##klevel PFX fmt, \
+		## args);      \
+} while (0)
+
+#ifdef BNA_ASSERT_PRINTK_ONLY
+#define BNA_ASSERT(p) do {						\
+	if (!(p))							\
+		printk(KERN_ERR "assert(%s) failed at %s:%d\n",		\
+		    #p, __FILE__, __LINE__);      \
+} while (0)
+#else
+#define BNA_ASSERT(p) do {						\
+	if (!(p)) {      \
+		printk(KERN_ERR "assert(%s) failed at %s:%d\n",		\
+		    #p, __FILE__, __LINE__);      \
+		BUG();      \
+	}								\
+} while (0)
+#endif
+
+#ifndef BNA_DEV_PRINTF
+#define BNA_DEV_PRINTF(bnad, level, fmt, arg...)			\
+		dev_printk(level, &(((bnad_t *)(bnad))			\
+			->pcidev->dev), fmt, ##arg);
+#endif
+
+#define BNA_PRINTF(level, fmt, arg...)					\
+		printk(level fmt, ##arg);
+
+#else /* DEBUG */
+
+#define BNA_ASSERT(p)
+#define BNA_DEV_PRINTF(bnad, level, fmt, arg...)
+#define BNA_PRINTF(level, fmt, arg...)
+
+#define DPRINTK(klevel, fmt, args...)   do { \
+		} while (0)
+
+#endif /* !DEBUG */
+
+#else /*  __KERNEL__ */
+
+#define BNA_ASSERT(p)
+
+#endif /*  !__KERNEL__ */
+
+#define bna_os_swap_3b(_x)				\
+	((((_x) & 0xff) << 16) |		\
+	((_x) & 0x00ff00) |			\
+	(((_x) & 0xff0000) >> 16))
+
+#define bna_os_swap_8b(_x) 				\
+     ((((_x) & 0xff00000000000000ull) >> 56)		\
+      | (((_x) & 0x00ff000000000000ull) >> 40)		\
+      | (((_x) & 0x0000ff0000000000ull) >> 24)		\
+      | (((_x) & 0x000000ff00000000ull) >> 8)		\
+      | (((_x) & 0x00000000ff000000ull) << 8)		\
+      | (((_x) & 0x0000000000ff0000ull) << 24)		\
+      | (((_x) & 0x000000000000ff00ull) << 40)		\
+      | (((_x) & 0x00000000000000ffull) << 56))
+
+#define bna_os_swap32(_x) 			\
+	((((_x) & 0xff) << 24) 		|	\
+	(((_x) & 0x0000ff00) << 8)	|	\
+	(((_x) & 0x00ff0000) >> 8)	|	\
+	(((_x) & 0xff000000) >> 24))
+
+
+#ifndef __BIGENDIAN
+#define bna_os_htons(_x) ((u16)((((_x) & 0xff00) >> 8) | \
+				 (((_x) & 0x00ff) << 8)))
+
+#define bna_os_htonl(_x)	bna_os_swap32(_x)
+#define bna_os_htonll(_x)	bna_os_swap_8b(_x)
+
+#define bna_os_wtole(_x)   	(_x)
+#define bna_os_wtobe(_x)   	bna_os_swap32(_x)
+
+#define bna_os_dma_addr64(_x)	bna_os_swap_8b(_x)
+
+#else
+
+#define bna_os_htons(_x)   (_x)
+#define bna_os_htonl(_x)   (_x)
+#define bna_os_htonll(_x)  (_x)
+
+#define bna_os_wtole(_x)   bna_os_swap32(_x)
+#define bna_os_wtobe(_x)   (_x)
+
+#define bna_os_dma_addr64(_x)	(_x)
+
+#endif
+
+#define bna_os_ntohs(_x)   bna_os_htons(_x)
+#define bna_os_ntohl(_x)   bna_os_htonl(_x)
+#define bna_os_ntohll(_x)  bna_os_htonll(_x)
+#define bna_os_ntoh3b(_x)  bna_os_hton3b(_x)
+
+#define bna_os_memset	memset
+#define bna_os_memcpy	memcpy
+#define bna_os_udelay	udelay
+#define bna_os_vsprintf vsprintf
+
+#define bna_os_reg_read(_raddr)		readl(_raddr)
+#define bna_os_reg_write(_raddr, _val)	writel(_val, _raddr)
+#define bna_os_mem_read(_raddr, _off)      \
+			bna_os_ntohl(((u32 *)_raddr)[(_off) >> 2])
+#define bna_os_mem_write(_raddr, _off, _val)   \
+			(((u32 *)_raddr)[(_off) >> 2]) = bna_os_htonl(_val)
+
+#define bna_os_mem_readw(_raddr)      	\
+		bna_os_htonl(*((u32 *)(_raddr)))
+#define bna_os_mem_writew(_raddr, _val)   \
+		{*((u32 *)(_raddr)) = bna_os_htonl((_val))}
+
+/* Required for DMA address manipulation in IOC */
+#define bfa_os_u32(__pa64) ((__pa64) >> 32)
+
+#endif /* __BNA_OS_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_priv.h linux-2.6.32-rc4-mod/drivers/net/bna/bna_priv.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_priv.h	2009-10-16 10:30:53.519452000 -0700
@@ -0,0 +1,490 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ * See <license_file> for copyright and licensing details.
+ */
+
+/**
+ *  BNA register access macros.p
+ */
+
+#ifndef __BNA_PRIV_H__
+#define __BNA_PRIV_H__
+
+
+#define bna_mem_read(_raddr, _off)  bna_os_mem_read(_raddr, _off)
+#define bna_mem_write(_raddr, _off, _val)	\
+	bna_os_mem_write(_raddr, _off, _val)
+
+
+/**
+	Macros to declare a bit table
+ *
+ * @param[in] _table - bit table to be declared
+ * @param[in] _size  - size in bits
+ */
+#define BNA_BIT_TABLE_DECLARE(_table, _size)	\
+	(u32 _table[(_size) / 32])
+/**
+	Macros to set bits in  a bit table
+ *
+ * @param[in] _table - bit table to be declared
+ * @param[in] _bit	- bit to be set
+ */
+#define BNA_BIT_TABLE_SET(_table, _bit)				\
+	(_table[(_bit) / 32] |= (1 << ((_bit) & (32 - 1))))
+/**
+	Macros to clear bits in  a bit table
+ *
+ * @param[in] _table - bit table to be declared
+ * @param[in] _bit	- bit to be set
+ */
+#define BNA_BIT_TABLE_CLEAR(_table, _bit)	 	 \
+	(_table[(_bit) / 32] &= ~(1 << ((_bit) & (32 - 1))))
+/**
+	Macros to set bits in a 32 bit word
+ *
+ * @param[in] _word  - word in which bit is to be set
+ * @param[in] _bit	- bit to be set (starting at 0)
+ */
+#define BNA_BIT_WORD_SET(_word, _bit)		\
+	((_word) |= (1 << (_bit)))
+/**
+	Macros to clear bits in a 32 bit word
+ *
+ * @param[in] _word  - word in which bit is to be cleared
+ * @param[in] _bit	- bit to be cleared (starting at 0)
+ */
+#define BNA_BIT_WORD_CLEAR(_word, _bit) 	\
+	((_word) &= ~(1 << (_bit)))
+
+/**
+ * BNA_GET_PAGE_NUM()
+ *
+ *  Macro to calculate the page number for the
+ *  memory spanning multiple pages.
+ *
+ * @param[in] _base_page - Base Page Number for memory
+ * @param[in] _offset	- Offset for which page number
+ *	  	 is calculated
+ */
+#define BNA_GET_PAGE_NUM(_base_page, _offset)	\
+	((_base_page) + ((_offset) >> 15))
+/**
+ * BNA_GET_PAGE_OFFSET()
+ *
+ *  Macro to calculate the page offset for the
+ *  from the base offset (from the top of the block)
+ *  Each page 0x8000 (32KB) in size
+ *
+ * @param[in] _offset - Offset from the top of the block
+ */
+#define BNA_GET_PAGE_OFFSET(_offset)	\
+	((_offset) & 0x7fff)
+
+/**
+ * BNA_GET_WORD_OFFSET()
+ *
+ *  Macro to calculate the address of a word from
+ *  the base address. Needed to access H/W memory
+ *  as 4 byte words. Starts from 0.
+ *
+ * @param[in] _base_offset - Starting offset of the data
+ * @param[in] _word	 	- Word no. for which address is calculated
+ */
+#define BNA_GET_WORD_OFFSET(_base_offset, _word)	\
+	((_base_offset) + ((_word) << 2))
+/**
+ * BNA_GET_BYTE_OFFSET()
+ *
+ *  Macro to calculate the address of a byte from
+ *  the base address. Most of H/W memory is accessed
+ *  as 4 byte words, so use this macro carefully.
+ *  Starts from 0.
+ *
+ * @param[in] _base_offset - Starting offset of the data
+ * @param[in] _byte	 	- Byte no. for which address is calculated
+ */
+#define BNA_GET_BYTE_OFFSET(_base_offset, _byte)	\
+	((_base_offset) + (_byte))
+
+/**
+ * BNA_GET_MEM_BASE_ADDR()
+ *
+ *  Macro to calculate the base address of
+ *  any memory block given the bar0 address
+ *  and the memory base offset
+ *
+ * @param[in] _bar0	 - BARO address
+ * @param[in] _base_offset - Starting offset of the memory
+ */
+#define BNA_GET_MEM_BASE_ADDR(_bar0, _base_offset)		\
+	((_bar0) + HW_BLK_HOST_MEM_ADDR		\
+	  + BNA_GET_PAGE_OFFSET((_base_offset)))
+
+/**
+ *  Structure which maps to Rx FnDb config
+ *  Size : 4 words
+ *  See catapult_spec.pdf, RxA for details
+ */
+struct bna_rx_fndb_ram {
+	u32 rss_prop;
+	u32 size_routing_props;
+	u32 rit_hds_mcastq;
+	u32 control_flags;
+};
+
+/**
+ *  Structure which maps to Tx FnDb config
+ *  Size : 1 word
+ *  See catapult_spec.pdf, TxA for details
+ */
+struct bna_tx_fndb_ram {
+	u32 vlan_n_ctrl_flags;
+};
+
+/**
+ *  Structure which maps to Unicast/Multicast CAM entry
+ *  Size : 2 words
+ *  See catapult_spec.pdf, LUT for details
+ */
+struct bna_cam {
+	u32 cam_mac_addr_47_32;	/*  31:16->res;15:0->MAC */
+	u32 cam_mac_addr_31_0;
+};
+
+/**
+ *  Structure which maps to Unicast RAM entry
+ *  Size : 1 word
+ *  See catapult_spec.pdf, LUT for details
+ */
+struct bna_ucast_mem {
+	u32 ucast_ram_entry;
+};
+
+/**
+ *  Structure which maps to VLAN RAM entry
+ *  Size : 1 word ?? Need to verify
+ *  See catapult_spec.pdf, LUT for details
+ */
+struct bna_vlan_mem {
+	u32 vlan_ram_entry;  /* FIXME */
+};
+#define BNA_GET_VLAN_MEM_ENTRY_ADDR(_bar0, _fn_id, _vlan_id)\
+	(_bar0 + (HW_BLK_HOST_MEM_ADDR)  \
+	+ (BNA_GET_PAGE_OFFSET(VLAN_RAM_BASE_OFFSET))	\
+	+ (((_fn_id) & 0x3f) << 9)	  \
+	+ (((_vlan_id) & 0xfe0) >> 3))
+
+/**
+ *  Structure which maps to exact/approx MVT RAM entry
+ *  Size : 4 words
+ *  See catapult_spec.pdf, RxA for details
+ */
+struct bna_mvt_mem {
+	u32 reserved;
+	u32 fc_bit;	/*  31:1->res;0->fc_bit */
+	u32 ll_fn_63_32;	/*  LL fns 63 to 32 */
+	u32 ll_fn_31_0;	/*  LL fns 31 to 0 */
+};
+
+/**
+ *  Structure which maps to RxFn Indirection Table (RIT)
+ *  Size : 1 word
+ *  See catapult_spec.pdf, RxA for details
+ */
+struct bna_rit_mem {
+	u32 rxq_ids;	/*  31:12->res;11:0->two 6 bit RxQ Ids */
+};
+
+/**
+ *  Structure which maps to RSS Table entry
+ *  Size : 16 words
+ *  See catapult_spec.pdf, RAD for details
+ */
+struct bna_rss_mem {
+	u32 type_n_hash;	/*  31:12->res;
+			 11:8 ->protocol type
+			  7:0 ->hash index */
+	u32 hash_key[10];  /*  40 byte Toeplitz hash key */
+	u32 reserved[5];
+};
+
+/**
+ *  Structure which maps to RxQ Memory entry
+ *  Size : 16 words, entries are 32 words apart
+ *	  	 Alternate arrangement of RxQ & TxQ
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_rxq_mem {
+	u32 pg_tbl_addr_lo;
+	u32 pg_tbl_addr_hi;
+	u32 cur_q_entry_lo;
+	u32 cur_q_entry_hi;
+#if 0
+	u32 nxt_pg_addr_lo;
+	u32 nxt_pg_addr_hi;
+#endif
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;/*  31:16->total page count
+			15:0 ->producer pointer (index?)*/
+	u32 entry_n_pg_size; /*  31:16->entry size
+			15:0 ->page size */
+	u32 sg_n_cq_n_cns_ptr; /* 31:28->reserved; 27:24->sg count
+			23:16->CQ; 15:0->consumer pointer(index?) */
+	u32 buf_sz_n_q_state; /*  31:16->buffer size; 15:0-> Q state */
+	u32 next_qid;		/*  17:10->next QId */
+	u32 reserved3;
+	u32 reserved4[4];
+};
+
+
+/**
+ *  Structure which maps to TxQ Memory entry
+ *  Size : 16 words, entries are 32 words apart
+ *	  	 Alternate arrangement of RxQ & TxQ
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_txq_mem {
+	u32 pg_tbl_addr_lo;
+	u32 pg_tbl_addr_hi;
+	u32 cur_q_entry_lo;
+	u32 cur_q_entry_hi;
+#if 0	/* obsolete, now replaced by reserved fields */
+	u32 nxt_pg_addr_lo
+	u32 nxt_pg_addr_hi;
+#endif
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;/*  31:16->total page count
+			15:0 ->producer pointer (index?)*/
+	u32 entry_n_pg_size; /*  31:16->entry size
+			15:0 ->page size */
+	u32 int_blk_n_cns_ptr;/*  31:24->Int Blk Id; 23:16->Int Blk Offset
+			15:0 ->consumer pointer(index?) */
+	u32 cns_ptr2_n_q_state;/* 31:16->cons. ptr 2; 15:0-> Q state */
+	u32 nxt_qid_n_fid_n_pri;/*  17:10->next QId;9:3->FID;2:0->Priority */
+	u32 wvc_n_cquota_n_rquota; /*  31:24->WI Vector Count;
+			 23:12->Cfg Quota;
+			 11:0 ->Run Quota */
+	u32 reserved3[4];
+};
+
+/**
+ *  Structure which maps to RxQ and TxQ Memory entry
+ *  Size : 32 words, entries are 32 words apart
+ *	  	 Alternate arrangement of RxQ & TxQ
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_rxtx_q_mem {
+	struct bna_rxq_mem rxq;
+	struct bna_txq_mem txq;
+};
+
+/**
+ *  Structure which maps to CQ Memory entry
+ *  Size : 16 words
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_cq_mem {
+	u32 pg_tbl_addr_lo;
+	u32 pg_tbl_addr_hi;
+	u32 cur_q_entry_lo;
+	u32 cur_q_entry_hi;
+#if 0
+	u32 nxt_pg_addr_lo;
+	u32 nxt_pg_addr_hi;
+#endif
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;/*  31:16->total page count
+			15:0 ->producer pointer (index?)*/
+	u32 entry_n_pg_size; /*  31:16->entry size
+			15:0 ->page size */
+	u32 int_blk_n_cns_ptr;/*  31:24->Int Blk Id; 23:16->Int Blk Offset
+			15:0 ->consumer pointer(index?) */
+	u32 q_state;		 /*  31:16->reserved; 15:0-> Q state */
+	u32 reserved3[2];
+	u32 reserved4[4];
+};
+
+/**
+ *  Structure which maps to Interrupt Block Memory entry
+ *  Size : 8 words (used: 5 words)
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_ib_blk_mem {
+	u32 host_addr_lo;
+	u32 host_addr_hi;
+	u32 clsc_n_ctrl_n_msix;/*  31:24->coalescing;
+			  23:16->coalescing cfg;
+			  15:8 ->control;
+				7:0 ->msix; */
+	u32 ipkt_n_ent_n_idxof;
+	u32 ipkt_cnt_cfg_n_unacked;
+
+	u32 reserved[3];
+};
+
+/**
+ *  Structure which maps to Index Table Block Memory entry
+ *  Size : 1 word
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_idx_tbl_mem {
+	u32 idx;	  /*  31:16->res;15:0->idx; */
+};
+
+/**
+ *  Structure which maps to Doorbell QSet Memory,
+ *  Organization of Doorbell address space for a
+ *  QSet (RxQ, TxQ, Rx IB, Tx IB)
+ *  For Non-VM qset entries are back to back.
+ *  Size : 128 bytes / 4K bytes for Non-VM / VM
+ *  See catapult_spec.pdf, HQM for details
+ */
+struct bna_doorbell_qset {
+	u32 rxq[0x20 >> 2];
+	u32 txq[0x20 >> 2];
+	u32 ib0[0x20 >> 2];
+	u32 ib1[0x20 >> 2];
+};
+
+
+#define BNA_GET_DOORBELL_BASE_ADDR(_bar0)	\
+	((_bar0) + HQM_DOORBELL_BLK_BASE_ADDR)
+
+
+/**
+ * BNA_GET_DOORBELL_ENTRY_OFFSET()
+ *
+ *  Macro to calculate the offset of the Doorbell QSet
+ *  in the Non VM case.
+ *  Entries are 128 bytes apart. Does not need a page
+ *  number register for access.
+ *
+ * @param[in] _entry - Entry Number
+ */
+#define BNA_GET_DOORBELL_ENTRY_OFFSET(_entry)		\
+	((HQM_DOORBELL_BLK_BASE_ADDR)		\
+	+ (_entry << 7))
+/**
+ * BNA_GET_DOORBELL_VM_ENTRY_OFFSET()
+ *
+ *  Macro to calculate the offset of the Doorbell QSet
+ *  in the VM case.
+ *  Entries are 4K (0x1000) bytes apart.
+ *  Does not need a page number register for access.
+ *
+ * @param[in] _entry - Entry Number
+ */
+#define BNA_GET_DOORBELL_VM_ENTRY_OFFSET(_entry)	\
+	((HQM_DOORBELL_VM_BLK_BASE_ADDR)	\
+	+ (_entry << 12))
+
+/**
+ * BNA_GET_PSS_SMEM_PAGE_NUM()
+ *
+ *  Macro to calculate the page number of PSS SMEM
+ *  block from a linear offset
+ *
+ * @param[in] _loff - Linear offset from the top of memory
+ */
+#define BNA_GET_PSS_SMEM_PAGE_NUM(_loff)		\
+	(BNA_GET_PAGE_NUM(PSS_SMEM_BLK_PG_NUM, (_loff)))
+/**
+ * BNA_GET_PSS_SMEM_PAGE_OFFSET()
+ *
+ *  Macro to calculate the page offset from the top
+ *  of a PSS SMEM page, for a given linear offset
+ *
+ * @param[in] _loff - Linear offset from the top of memory
+ */
+#define BNA_GET_PSS_SMEM_PAGE_OFFSET(_loff)	 	 \
+	(PSS_SMEM_BLK_MEM_ADDR  		\
+	+ BNA_GET_PAGE_OFFSET((_loff)))
+
+/**
+ * BNA_GET_MBOX_PAGE_NUM()
+ *
+ *  Macro to calculate the page number of HostFn<->LPU/
+ *  LPU<->HostFn Mailbox block from a linear offset
+ *
+ * @param[in] _loff - Linear offset from the top of memory
+ */
+#define BNA_GET_MBOX_PAGE_NUM(_loff)			\
+	(BNA_GET_PAGE_NUM(CPQ_BLK_PG_NUM, (_loff)))
+/**
+ * BNA_GET_HOSTFN_LPU_MBOX_PAGE_OFFSET()
+ *
+ *  Macro to calculate the HostFn<->LPU
+ *  Mailbox page offset from the linear offset
+ *
+ * @param[in] _loff - Linear offset in bytes from the top of memory
+ */
+#define BNA_GET_HOSTFN_LPU_MBOX_PAGE_OFFSET(_loff)		\
+	(HOSTFN_LPU_MBOX + BNA_GET_PAGE_OFFSET((_loff)))
+/**
+ * BNA_GET_LPU_HOSTFN_MBOX_PAGE_OFFSET()
+ *
+ *  Macro to calculate the LPU<->HostFn
+ *  Mailbox page offset from the linear offset
+ *
+ * @param[in] _loff - Linear offset from the top of memory
+ */
+#define BNA_GET_LPU_HOSTFN_MBOX_PAGE_OFFSET(_loff)		\
+	(LPU_HOSTFN_MBOX + BNA_GET_PAGE_OFFSET((_loff)))
+
+
+#define bna_hw_stats_to_stats bna_os_dma_addr64
+
+void bna_mbox_q_init(struct bna_mbox_q *q);
+
+#define BNA_80K_PKT_RATE		 80000
+#define BNA_70K_PKT_RATE		 70000
+#define BNA_60K_PKT_RATE		 60000
+#define BNA_50K_PKT_RATE		 50000
+#define BNA_40K_PKT_RATE		 40000
+#define BNA_30K_PKT_RATE		 30000
+#define BNA_20K_PKT_RATE		 20000
+#define BNA_10K_PKT_RATE		 10000
+
+/**
+ * Defines are in order of decreasing load
+ * i.e BNA_HIGH_LOAD_3 has the highest load
+ * and BNA_LOW_LOAD_3 has the lowest load.
+ */
+
+#define BNA_HIGH_LOAD_4		0 	/* r >= 80 */
+#define BNA_HIGH_LOAD_3		1	/* 60 <= r < 80 */
+#define BNA_HIGH_LOAD_2		2	/* 50 <= r < 60 */
+#define BNA_HIGH_LOAD_1		3	/* 40 <= r < 50 */
+#define BNA_LOW_LOAD_1		4	/* 30 <= r < 40 */
+#define BNA_LOW_LOAD_2		5	/* 20 <= r < 30 */
+#define BNA_LOW_LOAD_3		6	/* 10 <= r < 20 */
+#define BNA_LOW_LOAD_4		7	/* r  <  10 K */
+#define BNA_LOAD_TYPES		BNA_LOW_LOAD_4
+
+#define BNA_BIAS_TYPES		2 	/* small : small > large*2 */
+					/* large : if small is false */
+
+#endif /* __BNA_PRIV_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/cna.h linux-2.6.32-rc4-mod/drivers/net/bna/cna.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/cna.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/cna.h	2009-10-16 10:30:53.566453000 -0700
@@ -0,0 +1,32 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+#ifndef __CNA_H__
+#define __CNA_H__
+
+#include <cs/bfa_trc.h>
+#include <defs/bfa_defs_types.h>
+
+extern char bfa_version[];
+void bfa_ioc_auto_recover(bfa_boolean_t auto_recover);
+
+#endif /* __CNA_H__ */
