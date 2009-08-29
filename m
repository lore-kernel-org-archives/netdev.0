From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 5/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 22:18:39 -0700
Message-ID: <200908290518.n7T5Id0A031887@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:35855 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbZH2FYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 01:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 5/9 which contains linux driver source for 
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.30 

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---


diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_cee.c linux-2.6.30.5-mod/drivers/net/bna/bfa_cee.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_cee.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_cee.c	2009-08-28 21:09:24.170816000 -0700
@@ -0,0 +1,499 @@
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
+#include <cs/bfa_trc.h>
+#include <cs/bfa_log.h>
+#include <cs/bfa_debug.h>
+#include <cee/bfa_cee.h>
+#include <bfi/bfi_cee.h>
+#include <bfi/bfi.h>
+#include <bfa_ioc.h>
+#include <cna/bfa_cna_trcmod.h>
+
+BFA_TRC_FILE(CNA, CEE);
+
+#define bfa_ioc_portid(__ioc) ((__ioc)->port_id)
+#define bfa_lpuid(__arg) bfa_ioc_portid(&(__arg)->ioc)
+
+static void bfa_cee_format_lldp_cfg(struct bfa_cee_lldp_cfg_s *lldp_cfg);
+static void bfa_cee_format_dcbcx_stats(struct bfa_cee_dcbx_stats_s
+				       *dcbcx_stats);
+static void bfa_cee_format_lldp_stats(struct bfa_cee_lldp_stats_s
+				      *lldp_stats);
+static void bfa_cee_format_cfg_stats(struct bfa_cee_cfg_stats_s *cfg_stats);
+static void bfa_cee_format_cee_cfg(void *buffer);
+static void bfa_cee_format_cee_stats(void *buffer);
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
+static u32
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
+static u32
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
+	bfa_trc(cee, 0);
+	if (status == BFA_STATUS_OK) {
+		bfa_trc(cee, 0);
+		/*
+		 * The requested data has been copied to the DMA area, *process
+		 * it.
+		 */
+		memcpy(cee->attr, cee->attr_dma.kva,
+		       sizeof(struct bfa_cee_attr_s));
+		bfa_cee_format_cee_cfg(cee->attr);
+	}
+	cee->get_attr_pending = BFA_FALSE;
+	if (cee->cbfn.get_attr_cbfn) {
+		bfa_trc(cee, 0);
+		cee->cbfn.get_attr_cbfn(cee->cbfn.get_attr_cbarg, status);
+	}
+	bfa_trc(cee, 0);
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
+	bfa_trc(cee, 0);
+	if (status == BFA_STATUS_OK) {
+		bfa_trc(cee, 0);
+		/*
+		 * The requested data has been copied to the DMA area, process
+		 * it.
+		 */
+		memcpy(cee->stats, cee->stats_dma.kva,
+		       sizeof(struct bfa_cee_stats_s));
+		bfa_cee_format_cee_stats(cee->stats);
+	}
+	cee->get_stats_pending = BFA_FALSE;
+	bfa_trc(cee, 0);
+	if (cee->cbfn.get_stats_cbfn) {
+		bfa_trc(cee, 0);
+		cee->cbfn.get_stats_cbfn(cee->cbfn.get_stats_cbarg, status);
+	}
+	bfa_trc(cee, 0);
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
+	return (bfa_cee_attr_meminfo() + bfa_cee_stats_meminfo());
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
+bfa_cee_mem_claim(struct bfa_cee_s *cee, u8 * dma_kva, u64 dma_pa)
+{
+	cee->attr_dma.kva = dma_kva;
+	cee->attr_dma.pa = dma_pa;
+	cee->stats_dma.kva = dma_kva + bfa_cee_attr_meminfo();
+	cee->stats_dma.pa = dma_pa + bfa_cee_attr_meminfo();
+	cee->attr = (struct bfa_cee_attr_s *) dma_kva;
+	cee->stats =
+		(struct bfa_cee_stats_s *) (dma_kva + bfa_cee_attr_meminfo());
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
+	bfa_trc(cee, 0);
+	if (!bfa_ioc_is_operational(cee->ioc)) {
+		bfa_trc(cee, 0);
+		return BFA_STATUS_IOC_FAILURE;
+	}
+	if (cee->get_attr_pending == BFA_TRUE) {
+		bfa_trc(cee, 0);
+		return BFA_STATUS_DEVBUSY;
+	}
+	cee->get_attr_pending = BFA_TRUE;
+	cmd = (struct bfi_cee_get_req_s *) cee->get_cfg_mb.msg;
+	cee->attr = attr;
+	cee->cbfn.get_attr_cbfn = cbfn;
+	cee->cbfn.get_attr_cbarg = cbarg;
+	bfi_h2i_set(cmd->mh, BFI_MC_CEE, BFI_CEE_H2I_GET_CFG_REQ,
+		    bfa_ioc_portid(cee->ioc));
+	bfa_dma_be_addr_set(cmd->dma_addr, cee->attr_dma.pa);
+	bfa_ioc_mbox_queue(cee->ioc, &cee->get_cfg_mb);
+	bfa_trc(cee, 0);
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
+bfa_cee_get_stats(struct bfa_cee_s * cee, struct bfa_cee_stats_s * stats,
+		  bfa_cee_get_stats_cbfn_t cbfn, void *cbarg)
+{
+	struct bfi_cee_get_req_s *cmd;
+
+	bfa_assert((cee != NULL) && (cee->ioc != NULL));
+
+	if (!bfa_ioc_is_operational(cee->ioc)) {
+		bfa_trc(cee, 0);
+		return BFA_STATUS_IOC_FAILURE;
+	}
+	if (cee->get_stats_pending == BFA_TRUE) {
+		bfa_trc(cee, 0);
+		return BFA_STATUS_DEVBUSY;
+	}
+	cee->get_stats_pending = BFA_TRUE;
+	cmd = (struct bfi_cee_get_req_s *) cee->get_stats_mb.msg;
+	cee->stats = stats;
+	cee->cbfn.get_stats_cbfn = cbfn;
+	cee->cbfn.get_stats_cbarg = cbarg;
+	bfi_h2i_set(cmd->mh, BFI_MC_CEE, BFI_CEE_H2I_GET_STATS_REQ,
+		    bfa_ioc_portid(cee->ioc));
+	bfa_dma_be_addr_set(cmd->dma_addr, cee->stats_dma.pa);
+	bfa_ioc_mbox_queue(cee->ioc, &cee->get_stats_mb);
+	bfa_trc(cee, 0);
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
+bfa_cee_reset_stats(struct bfa_cee_s * cee, bfa_cee_reset_stats_cbfn_t cbfn,
+		    void *cbarg)
+{
+	struct bfi_cee_reset_stats_s *cmd;
+
+	bfa_assert((cee != NULL) && (cee->ioc != NULL));
+	if (!bfa_ioc_is_operational(cee->ioc)) {
+		bfa_trc(cee, 0);
+		return BFA_STATUS_IOC_FAILURE;
+	}
+	if (cee->reset_stats_pending == BFA_TRUE) {
+		bfa_trc(cee, 0);
+		return BFA_STATUS_DEVBUSY;
+	}
+	cee->reset_stats_pending = BFA_TRUE;
+	cmd = (struct bfi_cee_reset_stats_s *) cee->reset_stats_mb.msg;
+	cee->cbfn.reset_stats_cbfn = cbfn;
+	cee->cbfn.reset_stats_cbarg = cbarg;
+	bfi_h2i_set(cmd->mh, BFI_MC_CEE, BFI_CEE_H2I_RESET_STATS,
+		    bfa_ioc_portid(cee->ioc));
+	bfa_ioc_mbox_queue(cee->ioc, &cee->reset_stats_mb);
+	bfa_trc(cee, 0);
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
+	struct bfa_cee_s *cee = (struct bfa_cee_s *) cbarg;
+	msg = (union bfi_cee_i2h_msg_u *) m;
+	get_rsp = (struct bfi_cee_get_rsp_s *) m;
+	bfa_trc(cee, msg->mh.msg_id);
+	switch (msg->mh.msg_id) {
+	case BFI_CEE_I2H_GET_CFG_RSP:
+		bfa_trc(cee, get_rsp->cmd_status);
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
+	cee = (struct bfa_cee_s *) arg;
+
+	if (cee->get_attr_pending == BFA_TRUE) {
+		cee->get_attr_status = BFA_STATUS_FAILED;
+		cee->get_attr_pending = BFA_FALSE;
+		if (cee->cbfn.get_attr_cbfn) {
+			cee->cbfn.get_attr_cbfn(cee->cbfn.get_attr_cbarg,
+						BFA_STATUS_FAILED);
+		}
+	}
+	if (cee->get_stats_pending == BFA_TRUE) {
+		cee->get_stats_status = BFA_STATUS_FAILED;
+		cee->get_stats_pending = BFA_FALSE;
+		if (cee->cbfn.get_stats_cbfn) {
+			cee->cbfn.get_stats_cbfn(cee->cbfn.get_stats_cbarg,
+						 BFA_STATUS_FAILED);
+		}
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
+	bfa_trc(cee, 0);
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
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_fcpim.h linux-2.6.30.5-mod/drivers/net/bna/bfa_fcpim.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_fcpim.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_fcpim.h	2009-08-28 21:09:24.357815000 -0700
@@ -0,0 +1,161 @@
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
+#ifndef __BFA_FCPIM_H__
+#define __BFA_FCPIM_H__
+
+#include <bfa.h>
+#include <bfa_svc.h>
+#include <bfi/bfi_fcpim.h>
+#include <defs/bfa_defs_fcpim.h>
+
+/*
+ * forward declarations
+ */
+struct bfa_itnim_s;
+struct bfa_ioim_s;
+struct bfa_tskim_s;
+struct bfad_ioim_s;
+struct bfad_tskim_s;
+
+/*
+ * bfa fcpim module API functions
+ */
+void bfa_fcpim_path_tov_set(struct bfa_s *bfa, u16 path_tov);
+u16 bfa_fcpim_path_tov_get(struct bfa_s *bfa);
+void bfa_fcpim_qdepth_set(struct bfa_s *bfa, u16 q_depth);
+u16 bfa_fcpim_qdepth_get(struct bfa_s *bfa);
+bfa_status_t bfa_fcpim_get_modstats(struct bfa_s *bfa,
+				    struct bfa_fcpim_stats_s *modstats);
+bfa_status_t bfa_fcpim_clr_modstats(struct bfa_s *bfa);
+
+/*
+ * bfa itnim API functions
+ */
+struct bfa_itnim_s *bfa_itnim_create(struct bfa_s *bfa,
+				     struct bfa_rport_s *rport, void *itnim);
+void bfa_itnim_delete(struct bfa_itnim_s *itnim);
+void bfa_itnim_online(struct bfa_itnim_s *itnim, bfa_boolean_t seq_rec);
+void bfa_itnim_offline(struct bfa_itnim_s *itnim);
+void bfa_itnim_get_stats(struct bfa_itnim_s *itnim,
+			 struct bfa_itnim_hal_stats_s *stats);
+void bfa_itnim_clear_stats(struct bfa_itnim_s *itnim);
+
+
+/**
+ * 		BFA completion callback for bfa_itnim_online().
+ *
+ * @param[in]		itnim		FCS or driver itnim instance
+ *
+ * return None
+ */
+void bfa_cb_itnim_online(void *itnim);
+
+/**
+ * 		BFA completion callback for bfa_itnim_offline().
+ *
+ * @param[in]		itnim		FCS or driver itnim instance
+ *
+ * return None
+ */
+void bfa_cb_itnim_offline(void *itnim);
+void bfa_cb_itnim_tov_begin(void *itnim);
+void bfa_cb_itnim_tov(void *itnim);
+
+/**
+ * 		BFA notification to FCS/driver for second level error recovery.
+ *
+ * Atleast one I/O request has timedout and target is unresponsive to
+ * repeated abort requests. Second level error recovery should be initiated
+ * by starting implicit logout and recovery procedures.
+ *
+ * @param[in]		itnim		FCS or driver itnim instance
+ *
+ * return None
+ */
+void bfa_cb_itnim_sler(void *itnim);
+
+/*
+ * bfa ioim API functions
+ */
+struct bfa_ioim_s *bfa_ioim_alloc(struct bfa_s *bfa,
+				  struct bfad_ioim_s *dio,
+				  struct bfa_itnim_s *itnim, u16 nsgles);
+
+void bfa_ioim_free(struct bfa_ioim_s *ioim);
+void bfa_ioim_start(struct bfa_ioim_s *ioim);
+void bfa_ioim_abort(struct bfa_ioim_s *ioim);
+void bfa_ioim_delayed_comp(struct bfa_ioim_s *ioim, bfa_boolean_t iotov);
+
+
+/**
+ * 		I/O completion notification.
+ *
+ * @param[in]		dio			driver IO structure
+ * @param[in]		io_status		IO completion status
+ * @param[in]		scsi_status		SCSI status returned by target
+ * @param[in]		sns_len			SCSI sense length, 0 if none
+ * @param[in]		sns_info		SCSI sense data, if any
+ * @param[in]		residue			Residual length
+ *
+ * @return None
+ */
+void bfa_cb_ioim_done(void *bfad, struct bfad_ioim_s *dio,
+		      enum bfi_ioim_status io_status,
+		      u8 scsi_status, int sns_len, u8 * sns_info, s32 residue);
+
+/**
+ * 		I/O good completion notification.
+ *
+ * @param[in]		dio			driver IO structure
+ *
+ * @return None
+ */
+void bfa_cb_ioim_good_comp(void *bfad, struct bfad_ioim_s *dio);
+
+/**
+ * 		I/O abort completion notification
+ *
+ * @param[in]		dio			driver IO that was aborted
+ *
+ * @return None
+ */
+void bfa_cb_ioim_abort(void *bfad, struct bfad_ioim_s *dio);
+void bfa_cb_ioim_resfree(void *hcb_bfad);
+
+void bfa_cb_ioim_resfree(void *hcb_bfad);
+
+/*
+ * bfa tskim API functions
+ */
+struct bfa_tskim_s *bfa_tskim_alloc(struct bfa_s *bfa,
+				    struct bfad_tskim_s *dtsk);
+void bfa_tskim_free(struct bfa_tskim_s *tskim);
+void bfa_tskim_start(struct bfa_tskim_s *tskim,
+		     struct bfa_itnim_s *itnim, lun_t lun,
+		     enum fcp_tm_cmnd tm, u8 t_secs);
+void bfa_cb_tskim_done(void *bfad, struct bfad_tskim_s *dtsk,
+		       enum bfi_tskim_status tsk_status);
+
+#endif /* __BFA_FCPIM_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_fcxp_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_fcxp_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_fcxp_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_fcxp_priv.h	2009-08-28 21:09:24.236814000 -0700
@@ -0,0 +1,145 @@
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
+#ifndef __BFA_FCXP_PRIV_H__
+#define __BFA_FCXP_PRIV_H__
+
+#include <cs/bfa_sm.h>
+#include <protocol/fc.h>
+#include <bfa_svc.h>
+#include <bfi/bfi_fcxp.h>
+
+#define BFA_FCXP_MIN     	(1)
+#define BFA_FCXP_MAX_IBUF_SZ	(2 * 1024 + 256)
+#define BFA_FCXP_MAX_LBUF_SZ	(4 * 1024 + 256)
+
+struct bfa_fcxp_mod_s {
+	struct bfa_s *bfa;	/*  backpointer to BFA */
+	struct bfa_fcxp_s *fcxp_list;	/*  array of FCXPs */
+	u16 num_fcxps;		/*  max num FCXP requests */
+	struct list_head fcxp_free_q;	/*  free FCXPs */
+	struct list_head fcxp_active_q;	/*  active FCXPs */
+	void *req_pld_list_kva;	/*  list of FCXP req pld */
+	u64 req_pld_list_pa;	/*  list of FCXP req pld */
+	void *rsp_pld_list_kva;	/*  list of FCXP resp pld */
+	u64 rsp_pld_list_pa;	/*  list of FCXP resp pld */
+	struct list_head wait_q;	/*  wait queue for free fcxp */
+	u32 req_pld_sz;
+	u32 rsp_pld_sz;
+};
+
+#define BFA_FCXP_MOD(__bfa)		(&(__bfa)->modules.fcxp_mod)
+#define BFA_FCXP_FROM_TAG(__mod, __tag)	(&(__mod)->fcxp_list[__tag])
+
+typedef void (*fcxp_send_cb_t) (struct bfa_s * ioc, struct bfa_fcxp_s * fcxp,
+				void *cb_arg, bfa_status_t req_status,
+				u32 rsp_len, u32 resid_len,
+				struct fchs_s * rsp_fchs);
+
+/**
+ * Information needed for a FCXP request
+ */
+struct bfa_fcxp_req_info_s {
+	struct bfa_rport_s *bfa_rport;	/*  Pointer to the bfa rport that was
+					 *returned from bfa_rport_create().
+					 *This could be left NULL for WKA or for
+					 *FCXP interactions before the rport
+					 *nexus is established
+					 */
+	struct fchs_s fchs;	/*  request FC header structure */
+	u8 cts;			/*  continous sequence */
+	u8 class;		/*  FC class for the request/response */
+	u16 max_frmsz;		/*  max send frame size */
+	u16 vf_id;		/*  vsan tag if applicable */
+	u8 lp_tag;		/*  lport tag */
+	u32 req_tot_len;	/*  request payload total length */
+};
+
+struct bfa_fcxp_rsp_info_s {
+	struct fchs_s rsp_fchs;	/*  Response frame's FC header will
+				 * be *sent back in this field */
+	u8 rsp_timeout;		/*  timeout in seconds, 0-no response
+				 */
+	u8 rsvd2[3];
+	u32 rsp_maxlen;		/*  max response length expected */
+};
+
+struct bfa_fcxp_s {
+	struct list_head qe;	/*  fcxp queue element */
+	bfa_sm_t sm;		/*  state machine */
+	void *caller;		/*  driver or fcs */
+	struct bfa_fcxp_mod_s *fcxp_mod;
+	/*  back pointer to fcxp mod */
+	u16 fcxp_tag;		/*  internal tag */
+	struct bfa_fcxp_req_info_s req_info;
+	/*  request info */
+	struct bfa_fcxp_rsp_info_s rsp_info;
+	/*  response info */
+	u8 use_ireqbuf;		/*  use internal req buf */
+	u8 use_irspbuf;		/*  use internal rsp buf */
+	u32 nreq_sgles;		/*  num request SGLEs */
+	u32 nrsp_sgles;		/*  num response SGLEs */
+	struct list_head req_sgpg_q;	/*  SG pages for request buf */
+	struct list_head req_sgpg_wqe;	/*  wait queue for req SG page */
+	struct list_head rsp_sgpg_q;	/*  SG pages for response buf */
+	struct list_head rsp_sgpg_wqe;	/*  wait queue for rsp SG page */
+
+	bfa_fcxp_get_sgaddr_t req_sga_cbfn;
+	/*  SG elem addr user function */
+	bfa_fcxp_get_sglen_t req_sglen_cbfn;
+	/*  SG elem len user function */
+	bfa_fcxp_get_sgaddr_t rsp_sga_cbfn;
+	/*  SG elem addr user function */
+	bfa_fcxp_get_sglen_t rsp_sglen_cbfn;
+	/*  SG elem len user function */
+	bfa_cb_fcxp_send_t send_cbfn;	/*  send completion callback */
+	void *send_cbarg;	/*  callback arg */
+	struct bfa_sge_s req_sge[BFA_FCXP_MAX_SGES];
+	/*  req SG elems */
+	struct bfa_sge_s rsp_sge[BFA_FCXP_MAX_SGES];
+	/*  rsp SG elems */
+	u8 rsp_status;		/*  comp: rsp status */
+	u32 rsp_len;		/*  comp: actual response len */
+	u32 residue_len;	/*  comp: residual rsp length */
+	struct fchs_s rsp_fchs;	/*  comp: response fchs */
+	struct bfa_cb_qe_s hcb_qe;	/*  comp: callback qelem */
+	struct bfa_reqq_wait_s reqq_wqe;
+	bfa_boolean_t reqq_waiting;
+};
+
+#define BFA_FCXP_REQ_PLD(_fcxp) 	(bfa_fcxp_get_reqbuf(_fcxp))
+
+#define BFA_FCXP_RSP_FCHS(_fcxp) 	(&((_fcxp)->rsp_info.fchs))
+#define BFA_FCXP_RSP_PLD(_fcxp) 	(bfa_fcxp_get_rspbuf(_fcxp))
+
+#define BFA_FCXP_REQ_PLD_PA(_fcxp)					\
+	((_fcxp)->fcxp_mod->req_pld_list_pa +				\
+		((_fcxp)->fcxp_mod->req_pld_sz  * (_fcxp)->fcxp_tag))
+
+#define BFA_FCXP_RSP_PLD_PA(_fcxp) 					\
+	((_fcxp)->fcxp_mod->rsp_pld_list_pa +				\
+		((_fcxp)->fcxp_mod->rsp_pld_sz * (_fcxp)->fcxp_tag))
+
+void bfa_fcxp_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+#endif /* __BFA_FCXP_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_intr_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_intr_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_intr_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_intr_priv.h	2009-08-28 21:09:24.028815000 -0700
@@ -0,0 +1,122 @@
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
+#ifndef __BFA_INTR_PRIV_H__
+#define __BFA_INTR_PRIV_H__
+
+/**
+ * Message handler
+ */
+typedef void (*bfa_isr_func_t) (struct bfa_s * bfa, struct bfi_msg_s * m);
+void bfa_isr_unhandled(struct bfa_s *bfa, struct bfi_msg_s *m);
+void bfa_isr_bind(enum bfi_mclass mc, bfa_isr_func_t isr_func);
+
+
+#define bfa_reqq_pi(__bfa, __reqq)	(__bfa)->iocfc.req_cq_pi[__reqq]
+#define bfa_reqq_ci(__bfa, __reqq)					\
+	*(u32 *)((__bfa)->iocfc.req_cq_shadow_ci[__reqq].kva)
+
+#define bfa_reqq_full(__bfa, __reqq)				\
+	(((bfa_reqq_pi(__bfa, __reqq) + 1) &			\
+	  ((__bfa)->iocfc.cfg.drvcfg.num_reqq_elems - 1)) ==	\
+	 bfa_reqq_ci(__bfa, __reqq))
+
+#define bfa_reqq_next(__bfa, __reqq)				\
+	(bfa_reqq_full(__bfa, __reqq) ? NULL :			\
+	 ((void *)((struct bfi_msg_s *)((__bfa)->iocfc.req_cq_ba[__reqq].kva) \
+			  + bfa_reqq_pi((__bfa), (__reqq)))))
+
+#define bfa_reqq_produce(__bfa, __reqq)	do {				\
+	(__bfa)->iocfc.req_cq_pi[__reqq]++;				\
+	(__bfa)->iocfc.req_cq_pi[__reqq] &=				\
+		((__bfa)->iocfc.cfg.drvcfg.num_reqq_elems - 1);      \
+	bfa_reg_write((__bfa)->iocfc.bfa_regs.cpe_q_pi[__reqq],		\
+				(__bfa)->iocfc.req_cq_pi[__reqq]);      \
+	bfa_os_mmiowb();      \
+} while (0)
+
+#define bfa_rspq_pi(__bfa, __rspq)					\
+	*(u32 *)((__bfa)->iocfc.rsp_cq_shadow_pi[__rspq].kva)
+
+#define bfa_rspq_ci(__bfa, __rspq)	(__bfa)->iocfc.rsp_cq_ci[__rspq]
+#define bfa_rspq_elem(__bfa, __rspq, __ci)				\
+	&((struct bfi_msg_s *)((__bfa)->iocfc.rsp_cq_ba[__rspq].kva))[__ci]
+
+#define CQ_INCR(__index, __size)					\
+			(__index)++; (__index) &= ((__size) - 1)
+
+/**
+ * Queue element to wait for room in request queue. FIFO order is
+ * maintained when fullfilling requests.
+ */
+struct bfa_reqq_wait_s {
+	struct list_head qe;
+	void (*qresume) (void *cbarg);
+	void *cbarg;
+};
+
+/**
+ * Circular queue usage assignments
+ */
+enum {
+	BFA_REQQ_IOC = 0,	/*  all low-priority IOC msgs   */
+	BFA_REQQ_FCXP = 0,	/*  all FCXP messages           */
+	BFA_REQQ_LPS = 0,	/*  all lport service msgs      */
+	BFA_REQQ_PORT = 0,	/*  all port messages           */
+	BFA_REQQ_FLASH = 0,	/*  for flash module            */
+	BFA_REQQ_DIAG = 0,	/*  for diag module             */
+	BFA_REQQ_RPORT = 0,	/*  all port messages           */
+	BFA_REQQ_SBOOT = 0,	/*  all san boot messages       */
+	BFA_REQQ_QOS_LO = 1,	/*  all low priority IO */
+	BFA_REQQ_QOS_MD = 2,	/*  all medium priority IO      */
+	BFA_REQQ_QOS_HI = 3,	/*  all high priority IO        */
+};
+
+static inline void
+bfa_reqq_winit(struct bfa_reqq_wait_s *wqe, void (*qresume) (void *cbarg),
+	       void *cbarg)
+{
+	wqe->qresume = qresume;
+	wqe->cbarg = cbarg;
+}
+
+#define bfa_reqq(__bfa, __reqq)	&(__bfa)->reqq_waitq[__reqq]
+
+/**
+ * static inline void
+ * bfa_reqq_wait(struct bfa_s *bfa, int reqq, struct bfa_reqq_wait_s *wqe)
+ */
+#define bfa_reqq_wait(__bfa, __reqq, __wqe) do {			\
+									\
+		struct list_head *waitq = bfa_reqq(__bfa, __reqq);      \
+									\
+		bfa_assert(((__reqq) < BFI_IOC_MAX_CQS));      \
+		bfa_assert((__wqe)->qresume && (__wqe)->cbarg);      \
+									\
+		list_add_tail(&(__wqe)->qe, waitq);      \
+} while (0)
+
+#define bfa_reqq_wcancel(__wqe)	list_del(&(__wqe)->qe)
+
+#endif /* __BFA_INTR_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_iocfc.h linux-2.6.30.5-mod/drivers/net/bna/bfa_iocfc.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_iocfc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_iocfc.h	2009-08-28 21:09:23.940817000 -0700
@@ -0,0 +1,174 @@
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
+#ifndef __BFA_IOCFC_H__
+#define __BFA_IOCFC_H__
+
+#include <bfa_ioc.h>
+#include <bfa.h>
+#include <bfi/bfi_iocfc.h>
+#include <bfa_callback_priv.h>
+
+#define BFA_REQQ_NELEMS_MIN	(4)
+#define BFA_RSPQ_NELEMS_MIN	(4)
+
+struct bfa_iocfc_regs_s {
+	bfa_os_addr_t intr_status;
+	bfa_os_addr_t intr_mask;
+	bfa_os_addr_t cpe_q_pi[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t cpe_q_ci[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t cpe_q_depth[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t cpe_q_ctrl[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t rme_q_ci[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t rme_q_pi[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t rme_q_depth[BFI_IOC_MAX_CQS];
+	bfa_os_addr_t rme_q_ctrl[BFI_IOC_MAX_CQS];
+};
+
+/**
+ * MSIX vector handlers
+ */
+#define BFA_MSIX_MAX_VECTORS	22
+typedef void (*bfa_msix_handler_t) (struct bfa_s * bfa, int vec);
+struct bfa_msix_s {
+	int nvecs;
+	bfa_msix_handler_t handler[BFA_MSIX_MAX_VECTORS];
+};
+
+/**
+ * Chip specific interfaces
+ */
+struct bfa_hwif_s {
+	void (*hw_reginit) (struct bfa_s * bfa);
+	void (*hw_rspq_ack) (struct bfa_s * bfa, int rspq);
+	void (*hw_msix_init) (struct bfa_s * bfa, int nvecs);
+	void (*hw_msix_install) (struct bfa_s * bfa);
+	void (*hw_msix_uninstall) (struct bfa_s * bfa);
+	void (*hw_isr_mode_set) (struct bfa_s * bfa, bfa_boolean_t msix);
+	void (*hw_msix_getvecs) (struct bfa_s * bfa, u32 * vecmap,
+				 u32 * nvecs, u32 * maxvec);
+};
+typedef void (*bfa_cb_iocfc_t) (void *cbarg, enum bfa_status status);
+
+struct bfa_iocfc_s {
+	struct bfa_s *bfa;
+	struct bfa_iocfc_cfg_s cfg;
+	int action;
+
+	u32 req_cq_pi[BFI_IOC_MAX_CQS];
+	u32 rsp_cq_ci[BFI_IOC_MAX_CQS];
+
+	struct bfa_cb_qe_s init_hcb_qe;
+	struct bfa_cb_qe_s stop_hcb_qe;
+	struct bfa_cb_qe_s dis_hcb_qe;
+	struct bfa_cb_qe_s stats_hcb_qe;
+	bfa_boolean_t cfgdone;
+
+	struct bfa_dma_s cfg_info;
+	struct bfi_iocfc_cfg_s *cfginfo;
+	struct bfa_dma_s cfgrsp_dma;
+	struct bfi_iocfc_cfgrsp_s *cfgrsp;
+	struct bfi_iocfc_cfg_reply_s *cfg_reply;
+
+	u8 *stats_kva;
+	u64 stats_pa;
+	struct bfa_fw_stats_s *fw_stats;
+	struct bfa_timer_s stats_timer;	/*  timer */
+	struct bfa_iocfc_stats_s *stats_ret;	/*  driver stats location */
+	bfa_status_t stats_status;	/*  stats/statsclr status */
+	bfa_boolean_t stats_busy;	/*  outstanding stats */
+	bfa_cb_ioc_t stats_cbfn;	/*  driver callback function */
+	void *stats_cbarg;	/*  user callback arg */
+
+	struct bfa_dma_s req_cq_ba[BFI_IOC_MAX_CQS];
+	struct bfa_dma_s req_cq_shadow_ci[BFI_IOC_MAX_CQS];
+	struct bfa_dma_s rsp_cq_ba[BFI_IOC_MAX_CQS];
+	struct bfa_dma_s rsp_cq_shadow_pi[BFI_IOC_MAX_CQS];
+	struct bfa_iocfc_regs_s bfa_regs;	/*  BFA device registers */
+	struct bfa_hwif_s hwif;
+
+	bfa_cb_iocfc_t updateq_cbfn;	/*  bios callback function */
+	void *updateq_cbarg;	/*  bios callback arg */
+};
+
+#define bfa_lpuid(__bfa)		bfa_ioc_portid(&(__bfa)->ioc)
+#define bfa_msix_init(__bfa, __nvecs)	\
+	(__bfa)->iocfc.hwif.hw_msix_init(__bfa, __nvecs)
+#define bfa_msix_install(__bfa)	\
+	(__bfa)->iocfc.hwif.hw_msix_install(__bfa)
+#define bfa_msix_uninstall(__bfa)	\
+	(__bfa)->iocfc.hwif.hw_msix_uninstall(__bfa)
+#define bfa_isr_mode_set(__bfa, __msix)	\
+	(__bfa)->iocfc.hwif.hw_isr_mode_set(__bfa, __msix)
+#define bfa_msix_getvecs(__bfa, __vecmap, __nvecs, __maxvec)	\
+	(__bfa)->iocfc.hwif.hw_msix_getvecs(__bfa, __vecmap, __nvecs, __maxvec)
+
+/*
+ * FC specific IOC functions.
+ */
+void bfa_iocfc_meminfo(struct bfa_iocfc_cfg_s *cfg, u32 * km_len, u32 * dm_len);
+void bfa_iocfc_attach(struct bfa_s *bfa, void *bfad,
+		      struct bfa_iocfc_cfg_s *cfg,
+		      struct bfa_meminfo_s *meminfo,
+		      struct bfa_pcidev_s *pcidev);
+void bfa_iocfc_detach(struct bfa_s *bfa);
+void bfa_iocfc_init(struct bfa_s *bfa);
+void bfa_iocfc_start(struct bfa_s *bfa);
+void bfa_iocfc_stop(struct bfa_s *bfa);
+void bfa_iocfc_isr(void *bfa, struct bfi_mbmsg_s *msg);
+void bfa_iocfc_set_snsbase(struct bfa_s *bfa, u64 snsbase_pa);
+bfa_boolean_t bfa_iocfc_is_operational(struct bfa_s *bfa);
+void bfa_iocfc_reset_queues(struct bfa_s *bfa);
+void bfa_iocfc_updateq(struct bfa_s *bfa, u32 reqq_ba, u32 rspq_ba,
+		       u32 reqq_sci, u32 rspq_spi,
+		       bfa_cb_iocfc_t cbfn, void *cbarg);
+
+void bfa_msix_all(struct bfa_s *bfa, int vec);
+void bfa_msix_reqq(struct bfa_s *bfa, int vec);
+void bfa_msix_rspq(struct bfa_s *bfa, int vec);
+void bfa_msix_lpu_err(struct bfa_s *bfa, int vec);
+
+void bfa_hwcb_reginit(struct bfa_s *bfa);
+void bfa_hwcb_rspq_ack(struct bfa_s *bfa, int rspq);
+void bfa_hwcb_msix_init(struct bfa_s *bfa, int nvecs);
+void bfa_hwcb_msix_install(struct bfa_s *bfa);
+void bfa_hwcb_msix_uninstall(struct bfa_s *bfa);
+void bfa_hwcb_isr_mode_set(struct bfa_s *bfa, bfa_boolean_t msix);
+void bfa_hwcb_msix_getvecs(struct bfa_s *bfa, u32 * vecmap,
+			   u32 * nvecs, u32 * maxvec);
+void bfa_hwct_reginit(struct bfa_s *bfa);
+void bfa_hwct_rspq_ack(struct bfa_s *bfa, int rspq);
+void bfa_hwct_msix_init(struct bfa_s *bfa, int nvecs);
+void bfa_hwct_msix_install(struct bfa_s *bfa);
+void bfa_hwct_msix_uninstall(struct bfa_s *bfa);
+void bfa_hwct_isr_mode_set(struct bfa_s *bfa, bfa_boolean_t msix);
+void bfa_hwct_msix_getvecs(struct bfa_s *bfa, u32 * vecmap,
+			   u32 * nvecs, u32 * maxvec);
+
+void bfa_com_meminfo(bfa_boolean_t mincfg, u32 * dm_len);
+void bfa_com_attach(struct bfa_s *bfa, struct bfa_meminfo_s *mi,
+		    bfa_boolean_t mincfg);
+void bfa_iocfc_get_bootwwns(struct bfa_s *bfa, u8 * nwwns, wwn_t ** wwns);
+
+#endif /* __BFA_IOCFC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_ipfc.h linux-2.6.30.5-mod/drivers/net/bna/bfa_ipfc.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_ipfc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_ipfc.h	2009-08-28 21:09:24.055820000 -0700
@@ -0,0 +1,108 @@
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
+#ifndef __BFA_IPFC_H__
+#define __BFA_IPFC_H__
+
+#include <bfa.h>
+
+
+/**
+ * Packet receive status
+ */
+BFA_IPFC_STATUS_OK = 0,		/*  good packet          */
+	BFA_IPFC_STATUS_PARTIAL = 1,	/*  only partial frame is recvd */
+	BFA_IPFC_STATUS_ERROR = 2,	/*  driver requested return      */
+} bfa_ipfc_status_t;
+
+/*
+ * bfa ipfc API functions
+ */
+void bfa_ipfc_meminfo(int npkts, struct bfa_meminfo_s *meminfo);
+void bfa_ipfc_attach(struct bfa_s *bfa, void *dipfc, int npkts,
+		     struct bfa_meminfo_s *meminfo);
+void bfa_ipfc_detach(struct bfa_s *bfa);
+bfa_ipfc_pkt_t *bfa_ipfc_postpkt(struct bfa_s *bfa, bfad_pkt_t * dpkt);
+void bfa_ipfc_flushpkt(bfa_ipfc_pkt_t * pkt);
+
+/**
+ * 		Completion callback for bfa_ipfc_detach().
+ *
+ * @param[in]		dipfc		driver IPFC instance
+ *
+ * @return None
+ */
+void bfa_cb_ipfc_detach(void *dipfc);
+
+/**
+ * 		Callback to process a received packet.
+ *
+ * @param[in]		dipfc		driver IPFC instance
+ * @param[in]		dpkt		driver packet
+ * @param[in]		status		Status of received packet.
+ * @param[in]		pktlen		Length of packet received.
+ * @param[in]		residue		Residual length in bytes of packet
+ *					that was not copied due to lack of
+ *					space.
+ *
+ * @return None
+ */
+typedef
+void (*send_cbfn_t) (void *dipfc, bfad_pkt_t * dpkt,
+		     bfa_ipfc_status_t status, u32 pktlen, u32 residue);
+
+void bfa_hcb_ipfc_pktrecv(void *dipfc, bfad_pkt_t * dpkt,
+			  bfa_ipfc_status_t status, u32 pktlen, u32 residue);
+
+
+/**
+ * 		Get number of SG elements required to map receive packet buffer.
+ *
+ * @param[in]		dpkt		driver packet
+ *
+ * @return Number of SG elements for the packet.
+ */
+int bfa_hcb_ipfc_nsgles(bfad_pkt_t * dpkt);
+
+/**
+ * 		Get total packet buffer size in bytes.
+ *
+ * @param[in]		dpkt		driver packet
+ *
+ * @return Packet size in bytes.
+ */
+u16 bfa_hcb_ipfc_pktlen(bfad_pkt_t * dpkt);
+
+
+/**
+ * 		Get SG element of the mapped packet buffer given the SG index.
+ *
+ * @param[in]		dpkt		driver packet
+ * @param[in]		sge_idx		SG element index
+ * @param[out]		sge		SG element contents
+ *
+ * @return None
+ */
+void bfa_hcb_ipfc_sge(bfad_pkt_t * dpkt, int sge_idx, struct bfa_sge_s *sge);
+
+#endif /* __BFA_IPFC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_ipfc_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_ipfc_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_ipfc_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_ipfc_priv.h	2009-08-28 21:09:23.973815000 -0700
@@ -0,0 +1,51 @@
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
+#ifndef __BFA_IPFC_PRIV_H__
+#define __BFA_IPFC_PRIV_H__
+
+#include <bfa_ipfc.h>
+
+struct bfa_ipfc_pkt_s {
+	struct list_head qe;
+	bfa_sm_t sm;
+	struct bfa_s *bfa;
+	bfad_pkt_t *dpkt;
+	void *dipfc;
+	u16 pkt_tag;
+	u16 pkt_len;
+	u16 residue_len;
+	bfa_ipfc_status_t status;
+	struct bfa_cb_qe_s hcb_qe;
+	send_cbfn_t send_cbfn;
+	struct bfa_reqq_wait_s reqq_wqe;
+};
+
+struct bfa_s *bfa;
+bfa_ipfc_pkt_t *pkt_arr;
+struct list_head pkt_q;
+struct list_head pkt_free_q;
+int npkts;
+} bfa_ipfc_mod_t;
+
+#endif /* __BFA_IPFC_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_log.c linux-2.6.30.5-mod/drivers/net/bna/bfa_log.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_log.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_log.c	2009-08-28 21:09:24.127818000 -0700
@@ -0,0 +1,354 @@
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
+ *  bfa_log.c BFA log library
+ */
+
+#include <bfa_os_inc.h>
+#include <cs/bfa_log.h>
+
+/*
+ * global log info structure
+ */
+struct bfa_log_info_s {
+	u32 start_idx;		/*  start index for a module */
+	u32 total_count;	/*  total count for a module */
+	enum bfa_log_severity level;	/*  global log level */
+	bfa_log_cb_t cbfn;	/*  callback function */
+};
+
+static struct bfa_log_info_s bfa_log_info[BFA_LOG_MODULE_ID_MAX + 1];
+static u32 bfa_log_msg_total_count;
+static int bfa_log_initialized;
+
+static char *bfa_log_severity[] =
+	{ "[none]", "[critical]", "[error]", "[warn]", "[info]", "" };
+
+/**
+ * BFA log library initialization
+ *
+ * The log library initialization includes the following,
+ *    - set log instance name and callback function
+ *    - read the message array generated from xml files
+ *    - calculate start index for each module
+ *    - calculate message count for each module
+ *    - perform error checking
+ *
+ * @param[in] log_mod - log module info
+ * @param[in] instance_name - instance name
+ * @param[in] cbfn - callback function
+ *
+ * It return 0 on success, or -1 on failure
+ */
+int
+bfa_log_init(struct bfa_log_mod_s *log_mod, char *instance_name,
+	     bfa_log_cb_t cbfn)
+{
+	struct bfa_log_msgdef_s *msg;
+	u32 pre_mod_id = 0;
+	u32 cur_mod_id = 0;
+	u32 i, pre_idx, idx, msg_id;
+
+	/*
+	 * set instance name
+	 */
+	if (log_mod) {
+		strncpy(log_mod->instance_info, instance_name,
+			sizeof(log_mod->instance_info));
+		log_mod->cbfn = cbfn;
+		for (i = 0; i <= BFA_LOG_MODULE_ID_MAX; i++)
+			log_mod->log_level[i] = BFA_LOG_WARNING;
+	}
+
+	if (bfa_log_initialized)
+		return 0;
+
+	for (i = 0; i <= BFA_LOG_MODULE_ID_MAX; i++) {
+		bfa_log_info[i].start_idx = 0;
+		bfa_log_info[i].total_count = 0;
+		bfa_log_info[i].level = BFA_LOG_WARNING;
+		bfa_log_info[i].cbfn = cbfn;
+	}
+
+	pre_idx = 0;
+	idx = 0;
+	msg = bfa_log_msg_array;
+	msg_id = BFA_LOG_GET_MSG_ID(msg);
+	pre_mod_id = BFA_LOG_GET_MOD_ID(msg_id);
+	while (msg_id != 0) {
+		cur_mod_id = BFA_LOG_GET_MOD_ID(msg_id);
+
+		if (cur_mod_id > BFA_LOG_MODULE_ID_MAX) {
+			cbfn(log_mod, msg_id,
+			     "%s%s log: module id %u out of range\n",
+			     BFA_LOG_CAT_NAME, bfa_log_severity[BFA_LOG_ERROR],
+			     cur_mod_id);
+			return -1;
+		}
+
+		if (pre_mod_id > BFA_LOG_MODULE_ID_MAX) {
+			cbfn(log_mod, msg_id,
+			     "%s%s log: module id %u out of range\n",
+			     BFA_LOG_CAT_NAME, bfa_log_severity[BFA_LOG_ERROR],
+			     pre_mod_id);
+			return -1;
+		}
+
+		if (cur_mod_id != pre_mod_id) {
+			bfa_log_info[pre_mod_id].start_idx = pre_idx;
+			bfa_log_info[pre_mod_id].total_count = idx - pre_idx;
+			pre_mod_id = cur_mod_id;
+			pre_idx = idx;
+		}
+
+		idx++;
+		msg++;
+		msg_id = BFA_LOG_GET_MSG_ID(msg);
+	}
+
+	bfa_log_info[cur_mod_id].start_idx = pre_idx;
+	bfa_log_info[cur_mod_id].total_count = idx - pre_idx;
+	bfa_log_msg_total_count = idx;
+
+	cbfn(log_mod, msg_id, "%s%s log: init OK, msg total count %u\n",
+	     BFA_LOG_CAT_NAME,
+	     bfa_log_severity[BFA_LOG_INFO], bfa_log_msg_total_count);
+
+	bfa_log_initialized = 1;
+
+	return 0;
+}
+
+/**
+ * BFA log set log level for a module
+ *
+ * @param[in] log_mod - log module info
+ * @param[in] mod_id - module id
+ * @param[in] log_level - log severity level
+ *
+ * It return BFA_STATUS_OK on success, or > 0 on failure
+ */
+bfa_status_t
+bfa_log_set_level(struct bfa_log_mod_s * log_mod, int mod_id,
+		  enum bfa_log_severity log_level)
+{
+	if (mod_id <= BFA_LOG_UNUSED_ID || mod_id > BFA_LOG_MODULE_ID_MAX)
+		return BFA_STATUS_EINVAL;
+
+	if (log_level <= BFA_LOG_INVALID || log_level > BFA_LOG_LEVEL_MAX)
+		return BFA_STATUS_EINVAL;
+
+	if (log_mod)
+		log_mod->log_level[mod_id] = log_level;
+	else
+		bfa_log_info[mod_id].level = log_level;
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * BFA log set log level for all modules
+ *
+ * @param[in] log_mod - log module info
+ * @param[in] log_level - log severity level
+ *
+ * It return BFA_STATUS_OK on success, or > 0 on failure
+ */
+bfa_status_t
+bfa_log_set_level_all(struct bfa_log_mod_s * log_mod,
+		      enum bfa_log_severity log_level)
+{
+	int mod_id = BFA_LOG_UNUSED_ID + 1;
+
+	if (log_level <= BFA_LOG_INVALID || log_level > BFA_LOG_LEVEL_MAX)
+		return BFA_STATUS_EINVAL;
+
+	if (log_mod) {
+		for (; mod_id <= BFA_LOG_MODULE_ID_MAX; mod_id++)
+			log_mod->log_level[mod_id] = log_level;
+	} else {
+		for (; mod_id <= BFA_LOG_MODULE_ID_MAX; mod_id++)
+			bfa_log_info[mod_id].level = log_level;
+	}
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * BFA log set log level for all aen sub-modules
+ *
+ * @param[in] log_mod - log module info
+ * @param[in] log_level - log severity level
+ *
+ * It return BFA_STATUS_OK on success, or > 0 on failure
+ */
+bfa_status_t
+bfa_log_set_level_aen(struct bfa_log_mod_s * log_mod,
+		      enum bfa_log_severity log_level)
+{
+	int mod_id = BFA_LOG_AEN_MIN + 1;
+
+	if (log_mod) {
+		for (; mod_id <= BFA_LOG_AEN_MAX; mod_id++)
+			log_mod->log_level[mod_id] = log_level;
+	} else {
+		for (; mod_id <= BFA_LOG_AEN_MAX; mod_id++)
+			bfa_log_info[mod_id].level = log_level;
+	}
+
+	return BFA_STATUS_OK;
+}
+
+/**
+ * BFA log get log level for a module
+ *
+ * @param[in] log_mod - log module info
+ * @param[in] mod_id - module id
+ *
+ * It returns log level or -1 on error
+ */
+enum bfa_log_severity
+bfa_log_get_level(struct bfa_log_mod_s *log_mod, int mod_id)
+{
+	if (mod_id <= BFA_LOG_UNUSED_ID || mod_id > BFA_LOG_MODULE_ID_MAX)
+		return BFA_LOG_INVALID;
+
+	if (log_mod)
+		return (log_mod->log_level[mod_id]);
+	else
+		return (bfa_log_info[mod_id].level);
+}
+
+enum bfa_log_severity
+bfa_log_get_msg_level(struct bfa_log_mod_s *log_mod, u32 msg_id)
+{
+	struct bfa_log_msgdef_s *msg;
+	u32 mod = BFA_LOG_GET_MOD_ID(msg_id);
+	u32 idx = BFA_LOG_GET_MSG_IDX(msg_id) - 1;
+
+	if (!bfa_log_initialized)
+		return BFA_LOG_INVALID;
+
+	if (mod > BFA_LOG_MODULE_ID_MAX)
+		return BFA_LOG_INVALID;
+
+	if (idx >= bfa_log_info[mod].total_count) {
+		bfa_log_info[mod].cbfn(log_mod, msg_id,
+				       "%s%s log: inconsistent idx %u vs. total count %u\n",
+				       BFA_LOG_CAT_NAME,
+				       bfa_log_severity[BFA_LOG_ERROR], idx,
+				       bfa_log_info[mod].total_count);
+		return BFA_LOG_INVALID;
+	}
+
+	msg = bfa_log_msg_array + bfa_log_info[mod].start_idx + idx;
+	if (msg_id != BFA_LOG_GET_MSG_ID(msg)) {
+		bfa_log_info[mod].cbfn(log_mod, msg_id,
+				       "%s%s log: inconsistent msg id %u array msg id %u\n",
+				       BFA_LOG_CAT_NAME,
+				       bfa_log_severity[BFA_LOG_ERROR], msg_id,
+				       BFA_LOG_GET_MSG_ID(msg));
+		return BFA_LOG_INVALID;
+	}
+
+	return BFA_LOG_GET_SEVERITY(msg);
+}
+
+/**
+ * BFA log message handling
+ *
+ * BFA log message handling finds the message based on message id and prints
+ * out the message based on its format and arguments. It also does prefix
+ * the severity etc.
+ *
+ * @param[in] log_mod - log module info
+ * @param[in] msg_id - message id
+ * @param[in] ... - message arguments
+ *
+ * It return 0 on success, or -1 on errors
+ */
+int
+bfa_log(struct bfa_log_mod_s *log_mod, u32 msg_id, ...)
+{
+	va_list ap;
+	char buf[256];
+	struct bfa_log_msgdef_s *msg;
+	int log_level;
+	u32 mod = BFA_LOG_GET_MOD_ID(msg_id);
+	u32 idx = BFA_LOG_GET_MSG_IDX(msg_id) - 1;
+
+	if (!bfa_log_initialized)
+		return -1;
+
+	if (mod > BFA_LOG_MODULE_ID_MAX)
+		return -1;
+
+	if (idx >= bfa_log_info[mod].total_count) {
+		bfa_log_info[mod].
+			cbfn
+			(log_mod, msg_id,
+			 "%s%s log: inconsistent idx %u vs. total count %u\n",
+			 BFA_LOG_CAT_NAME, bfa_log_severity[BFA_LOG_ERROR], idx,
+			 bfa_log_info[mod].total_count);
+		return -1;
+	}
+
+	msg = bfa_log_msg_array + bfa_log_info[mod].start_idx + idx;
+	if (msg_id != BFA_LOG_GET_MSG_ID(msg)) {
+		bfa_log_info[mod].
+			cbfn
+			(log_mod, msg_id,
+			 "%s%s log: inconsistent msg id %u array msg id %u\n",
+			 BFA_LOG_CAT_NAME, bfa_log_severity[BFA_LOG_ERROR],
+			 msg_id, BFA_LOG_GET_MSG_ID(msg));
+		return -1;
+	}
+
+	log_level = log_mod ? log_mod->log_level[mod] : bfa_log_info[mod].level;
+	if ((BFA_LOG_GET_SEVERITY(msg) > log_level) &&
+	    (msg->attributes != BFA_LOG_ATTR_NONE))
+		return 0;
+
+	va_start(ap, msg_id);
+	bfa_os_vsprintf(buf, BFA_LOG_GET_MSG_FMT_STRING(msg), ap);
+	va_end(ap);
+
+	if (log_mod)
+		log_mod->cbfn(log_mod, msg_id, "%s[%s]%s%s %s: %s\n",
+			      BFA_LOG_CAT_NAME, log_mod->instance_info,
+			      bfa_log_severity[BFA_LOG_GET_SEVERITY(msg)],
+			      (msg->attributes & BFA_LOG_ATTR_AUDIT)
+			      ? " (audit) " : "", msg->msg_value, buf);
+	else
+		bfa_log_info[mod].cbfn(log_mod, msg_id, "%s%s%s %s: %s\n",
+				       BFA_LOG_CAT_NAME,
+				       bfa_log_severity[BFA_LOG_GET_SEVERITY
+							(msg)],
+				       (msg->
+					attributes & BFA_LOG_ATTR_AUDIT) ?
+				       " (audit) " : "", msg->msg_value, buf);
+
+	return 0;
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_port_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_port_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_port_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_port_priv.h	2009-08-28 21:09:24.458814000 -0700
@@ -0,0 +1,96 @@
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
+#ifndef __BFA_PORT_PRIV_H__
+#define __BFA_PORT_PRIV_H__
+
+#include <defs/bfa_defs_pport.h>
+#include <bfi/bfi_pport.h>
+#include "bfa_intr_priv.h"
+
+/**
+ * BFA physical port data structure
+ */
+struct bfa_pport_s {
+	struct bfa_s *bfa;	/*  parent BFA instance */
+	bfa_sm_t sm;		/*  port state machine */
+	wwn_t nwwn;		/*  node wwn of physical port */
+	wwn_t pwwn;		/*  port wwn of physical oprt */
+	enum bfa_pport_speed speed_sup;
+	/*  supported speeds */
+	enum bfa_pport_speed speed;	/*  current speed */
+	enum bfa_pport_topology topology;	/*  current topology */
+	u8 myalpa;		/*  my ALPA in LOOP topology */
+	u8 rsvd[3];
+	struct bfa_pport_cfg_s cfg;	/*  current port configuration */
+	struct bfa_qos_attr_s qos_attr;	/* QoS Attributes */
+	struct bfa_qos_vc_attr_s qos_vc_attr;	/*  VC info from ELP */
+	struct bfa_reqq_wait_s reqq_wait;
+	/*  to wait for room in reqq */
+	struct bfa_reqq_wait_s svcreq_wait;
+	/*  to wait for room in reqq */
+	struct bfa_reqq_wait_s stats_reqq_wait;
+	/*  to wait for room in reqq (stats) */
+	void *event_cbarg;
+	void (*event_cbfn) (void *cbarg, bfa_pport_event_t event);
+	union {
+		union bfi_pport_i2h_msg_u i2hmsg;
+	} event_arg;
+	void *bfad;		/*  BFA driver handle */
+	struct bfa_cb_qe_s hcb_qe;	/*  BFA callback queue elem */
+	enum bfa_pport_linkstate hcb_event;
+	/*  link event for callback */
+	u32 msgtag;		/*  fimrware msg tag for reply */
+	u8 *stats_kva;
+	u64 stats_pa;
+	union bfa_pport_stats_u *stats;	/*  pport stats */
+	u32 mypid:24;
+	u32 rsvd_b:8;
+	struct bfa_timer_s timer;	/*  timer */
+	union bfa_pport_stats_u *stats_ret;
+	/*  driver stats location */
+	bfa_status_t stats_status;
+	/*  stats/statsclr status */
+	bfa_boolean_t stats_busy;
+	/*  outstanding stats/statsclr */
+	bfa_boolean_t stats_qfull;
+	bfa_boolean_t diag_busy;
+	/*  diag busy status */
+	bfa_boolean_t beacon;
+	/*  port beacon status */
+	bfa_boolean_t link_e2e_beacon;
+	/*  link beacon status */
+	bfa_cb_pport_t stats_cbfn;
+	/*  driver callback function */
+	void *stats_cbarg;
+	/* *!< user callback arg */
+};
+
+#define BFA_PORT_MOD(__bfa)	(&(__bfa)->modules.pport)
+
+/*
+ * public functions
+ */
+void bfa_pport_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+#endif /* __BFA_PORT_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_rport_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_rport_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_rport_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_rport_priv.h	2009-08-28 21:09:24.112824000 -0700
@@ -0,0 +1,52 @@
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
+#ifndef __BFA_RPORT_PRIV_H__
+#define __BFA_RPORT_PRIV_H__
+
+#include <bfa_svc.h>
+
+#define BFA_RPORT_MIN	4
+
+struct bfa_rport_mod_s {
+	struct bfa_rport_s *rps_list;	/*  list of rports      */
+	struct list_head rp_free_q;	/*  free bfa_rports     */
+	struct list_head rp_active_q;	/*  free bfa_rports     */
+	u16 num_rports;		/*  number of rports    */
+};
+
+#define BFA_RPORT_MOD(__bfa)	(&(__bfa)->modules.rport_mod)
+
+/**
+ * Convert rport tag to RPORT
+ */
+#define BFA_RPORT_FROM_TAG(__bfa, _tag)				\
+	(BFA_RPORT_MOD(__bfa)->rps_list +				\
+	 ((_tag) & (BFA_RPORT_MOD(__bfa)->num_rports - 1)))
+
+/*
+ * external functions
+ */
+void bfa_rport_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+#endif /* __BFA_RPORT_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_sgpg_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_sgpg_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_sgpg_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_sgpg_priv.h	2009-08-28 21:09:24.190817000 -0700
@@ -0,0 +1,84 @@
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
+ *  hal_sgpg.h BFA SG page module
+ */
+
+#ifndef __BFA_SGPG_PRIV_H__
+#define __BFA_SGPG_PRIV_H__
+
+#include <cs/bfa_q.h>
+
+#define BFA_SGPG_MIN	(16)
+
+/**
+ * Alignment macro for SG page allocation
+ */
+#define BFA_SGPG_ROUNDUP(_l) (((_l) + (sizeof(struct bfi_sgpg_s) - 1)) \
+			& ~(sizeof(struct bfi_sgpg_s) - 1))
+
+struct bfa_sgpg_wqe_s {
+	struct list_head qe;	/*  queue sg page element       */
+	int nsgpg;		/*  pages to be allocated       */
+	int nsgpg_total;	/*  total pages required        */
+	void (*cbfn) (void *cbarg);
+	/*  callback function           */
+	void *cbarg;		/*  callback arg                */
+	struct list_head sgpg_q;	/*  queue of alloced sgpgs      */
+};
+
+struct bfa_sgpg_s {
+	struct list_head qe;	/*  queue sg page element       */
+	struct bfi_sgpg_s *sgpg;	/*  va of SG page              */
+	union bfi_addr_u sgpg_pa;	/*  pa of SG page              */
+};
+
+/**
+ * Given number of SG elements, BFA_SGPG_NPAGE() returns the number of
+ * SG pages required.
+ */
+#define BFA_SGPG_NPAGE(_nsges)  (((_nsges) / BFI_SGPG_DATA_SGES) + 1)
+
+struct bfa_sgpg_mod_s {
+	struct bfa_s *bfa;
+	int num_sgpgs;		/*  number of SG pages          */
+	int free_sgpgs;		/*  number of free SG pages     */
+	struct bfa_sgpg_s *hsgpg_arr;	/*  BFA SG page array   */
+	struct bfi_sgpg_s *sgpg_arr;	/*  actual SG page array        */
+	u64 sgpg_arr_pa;	/*  SG page array DMA addr      */
+	struct list_head sgpg_q;	/*  queue of free SG pages      */
+	struct list_head sgpg_wait_q;	/*  wait queue for SG pages       */
+};
+#define BFA_SGPG_MOD(__bfa)	(&(__bfa)->modules.sgpg_mod)
+
+bfa_status_t bfa_sgpg_malloc(struct bfa_s *bfa, struct list_head *sgpg_q,
+			     int nsgpgs);
+void bfa_sgpg_mfree(struct bfa_s *bfa, struct list_head *sgpg_q, int nsgpgs);
+void bfa_sgpg_winit(struct bfa_sgpg_wqe_s *wqe,
+		    void (*cbfn) (void *cbarg), void *cbarg);
+void bfa_sgpg_wait(struct bfa_s *bfa, struct bfa_sgpg_wqe_s *wqe, int nsgpgs);
+void bfa_sgpg_wcancel(struct bfa_s *bfa, struct bfa_sgpg_wqe_s *wqe);
+
+#endif /* __BFA_SGPG_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_sm.c linux-2.6.30.5-mod/drivers/net/bna/bfa_sm.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_sm.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_sm.c	2009-08-28 21:09:24.331823000 -0700
@@ -0,0 +1,43 @@
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
+	int i = 0;
+
+	while (smt[i].sm && smt[i].sm != sm)
+		i++;
+	return smt[i].state;
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_timer.h linux-2.6.30.5-mod/drivers/net/bna/bfa_timer.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_timer.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_timer.h	2009-08-28 21:09:24.081817000 -0700
@@ -0,0 +1,59 @@
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
+#ifndef __BFA_TIMER_H__
+#define __BFA_TIMER_H__
+
+#include <bfa_os_inc.h>
+#include <cs/bfa_q.h>
+
+struct bfa_s;
+
+typedef void (*bfa_timer_cbfn_t) (void *);
+
+/**
+ * BFA timer data structure
+ */
+struct bfa_timer_s {
+	struct list_head qe;
+	bfa_timer_cbfn_t timercb;
+	void *arg;
+	int timeout;			/**< in millisecs. */
+};
+
+/**
+ * Timer module structure
+ */
+struct bfa_timer_mod_s {
+	struct list_head timer_q;
+};
+
+#define BFA_TIMER_FREQ 500 /**< specified in millisecs */
+
+void bfa_timer_beat(struct bfa_timer_mod_s *mod);
+void bfa_timer_init(struct bfa_timer_mod_s *mod);
+void bfa_timer_begin(struct bfa_timer_mod_s *mod, struct bfa_timer_s *timer,
+		     bfa_timer_cbfn_t timercb, void *arg, unsigned int timeout);
+void bfa_timer_stop(struct bfa_timer_s *timer);
+
+#endif /* __BFA_TIMER_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_uf_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_uf_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_uf_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_uf_priv.h	2009-08-28 21:09:23.889825000 -0700
@@ -0,0 +1,54 @@
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
+#ifndef __BFA_UF_PRIV_H__
+#define __BFA_UF_PRIV_H__
+
+#include <cs/bfa_sm.h>
+#include <bfa_svc.h>
+#include <bfi/bfi_uf.h>
+
+#define BFA_UF_MIN	(4)
+
+struct bfa_uf_mod_s {
+	struct bfa_s *bfa;	/*  back pointer to BFA */
+	struct bfa_uf_s *uf_list;	/*  array of UFs */
+	u16 num_ufs;		/*  num unsolicited rx frames */
+	struct list_head uf_free_q;	/*  free UFs */
+	struct list_head uf_posted_q;	/*  UFs posted to IOC */
+	struct bfa_uf_buf_s *uf_pbs_kva;	/*  list UF bufs request pld */
+	u64 uf_pbs_pa;		/*  phy addr for UF bufs */
+	struct bfi_uf_buf_post_s *uf_buf_posts;
+	/*  pre-built UF post msgs */
+	bfa_cb_uf_recv_t ufrecv;	/*  uf recv handler function */
+	void *cbarg;		/*  uf receive handler arg */
+};
+
+#define BFA_UF_MOD(__bfa)	(&(__bfa)->modules.uf_mod)
+
+#define ufm_pbs_pa(_ufmod, _uftag)	\
+	((_ufmod)->uf_pbs_pa + sizeof(struct bfa_uf_buf_s) * (_uftag))
+
+void bfa_uf_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+
+#endif /* __BFA_UF_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bnad_compat.h linux-2.6.30.5-mod/drivers/net/bna/bnad_compat.h
--- linux-2.6.30.5-orig/drivers/net/bna/bnad_compat.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bnad_compat.h	2009-08-28 21:09:23.838816000 -0700
@@ -0,0 +1,115 @@
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
+#define NETDEV_TX_OK 0		/* driver took care of the packet */
+#endif
+
+#ifndef NETDEV_TX_BUSY
+#define NETDEV_TX_BUSY 1	/* driver tx path was busy */
+#endif
+
+#ifndef NETDEV_TX_LOCKED
+#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
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
+#define bnad_isr_t irq_handler_t
+
+#ifdef BNAD_NAPI
+#define BNAD_NEW_NAPI
+#endif
+
+#define BNAD_VLAN_FEATURES
+
+#define netif_rx_schedule_prep(_netdev, _napi)  napi_schedule_prep(_napi)
+#define __netif_rx_schedule(_netdev, _napi)     __napi_schedule(_napi)
+#define netif_rx_complete(_netdev, _napi)       napi_complete(_napi)
+
+#endif /* _BNAD_COMPAT_H_ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bnad.h linux-2.6.30.5-mod/drivers/net/bna/bnad.h
--- linux-2.6.30.5-orig/drivers/net/bna/bnad.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bnad.h	2009-08-28 21:09:24.207818000 -0700
@@ -0,0 +1,522 @@
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
+#ifndef _BNAD_H_
+#define _BNAD_H_
+
+#if defined(__VMKERNEL_MODULE__) || defined(__ESX_COS__)
+#include <linux/config.h>
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/inetdevice.h>
+#include <linux/if_arp.h>
+#include <linux/delay.h>
+#include <net/ip.h>
+#include <net/sock.h>
+#include <net/checksum.h>
+#ifdef CONFIG_IP_MROUTE
+#include <linux/mroute.h>
+#endif
+
+#endif
+
+#include <cee/bfa_cee.h>
+#include "bna.h"
+
+#ifdef BNAD_LRO
+#if !defined(CONFIG_INET_LRO) && !defined(CONFIG_INET_LRO_MODULE)
+#include <net/ip.h>
+#ifndef __VMKERNEL_MODULE__
+#include <net/tcp.h>
+#else
+#include <linux/tcp.h>
+#endif
+#else
+#include <linux/inet_lro.h>
+#endif
+#endif
+
+#include "bnad_compat.h"
+
+#ifdef BNAD_LRO
+#if !defined(CONFIG_INET_LRO) && !defined(CONFIG_INET_LRO_MODULE)
+#include "inet_lro.h"
+#endif
+
+#define BNAD_LRO_MAX_DESC	8
+#define BNAD_LRO_MAX_AGGR	64
+
+#endif
+
+#define BNAD_MAX_Q_DEPTH	0x10000
+#define BNAD_MIN_Q_DEPTH	0x200
+
+#define BNAD_TXQ_NUM		1
+#define BNAD_TX_FUNC_ID		0
+#define BNAD_ENTRIES_PER_TXQ	2048
+
+#define BNAD_MAX_RXQS		64
+#define BNAD_MAX_RXQSETS_USED	16
+#define BNAD_RX_FUNC_ID		0
+#define BNAD_ENTRIES_PER_RXQ	2048
+
+#define BNAD_MAX_CQS		64
+#define BNAD_MAX_RXQS_PER_CQ	2
+
+#define BNAD_MSIX_ERR_MAILBOX_NUM	1
+
+#define BNAD_INTX_MAX_IB_NUM	16
+#define BNAD_INTX_IB_NUM	2	/* 1 for Tx, 1 for Rx */
+#define BNAD_INTX_TX_IB_ID	0
+#define BNAD_INTX_RX_IB_ID	1
+
+#define BNAD_QUEUE_NAME_SIZE	16
+
+#define BNAD_JUMBO_MTU		9000
+
+#define BNAD_COALESCING_TIMER_UNIT	5	/* 5us */
+#define BNAD_MAX_COALESCING_TIMEO	0xFF	/* in 5us units */
+#define BNAD_MAX_INTERPKT_COUNT		0xFF
+#define BNAD_MAX_INTERPKT_TIMEO		0xF	/* in 0.5us units */
+
+#define BNAD_TX_COALESCING_TIMEO	20	/* 20 * 5 = 100us */
+#define BNAD_TX_INTERPKT_COUNT		32
+
+#define BNAD_RX_COALESCING_TIMEO	12	/* 12 * 5 = 60us */
+#define BNAD_RX_INTERPKT_COUNT		6
+#define BNAD_RX_INTERPKT_TIMEO		3	/* 3 * 0.5 = 1.5us */
+
+#define BNAD_SMALL_RXBUF_SIZE	128
+
+#define BNAD_RIT_OFFSET		0
+#define BNAD_MULTICAST_RXQ_ID	0
+
+#define BNAD_NETIF_WAKE_THRESHOLD	8
+
+#define BNAD_TX_MAX_VECTORS		255
+#define BNAD_TX_MAX_VECTORS_PER_WI	4
+#define BNAD_TX_MAX_DATA_PER_WI		0xFFFFFF	/* 24 bits */
+#define BNAD_TX_MAX_DATA_PER_VECTOR	0x3FFF	/* 14 bits */
+#define BNAD_TX_MAX_WRR_QUOTA		0xFFF	/* 12 bits */
+
+#define BNAD_RXQ_REFILL_THRESHOLD_SHIFT	3
+
+#define BNAD_CQ_PROCESS_LIMIT		512
+
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+#define BNAD_FIRST_NETQ_ID	1
+#define BNAD_FIRST_NETQ_RXF	1
+#define BNAD_VMW_DEFAULT_QUEUE  0
+#define BNAD_MBOX_TIMEOUT	(100)
+#define BNAD_MBOX_MDELAY	(10)
+#define BNAD_MBOX_WAITING	(BFI_LL_CMD_NOT_EXEC)
+
+#define BNAD_GET_RIT_FROM_RXF(_rxf_id)	(((_rxf_id - BNAD_FIRST_NETQ_RXF) / \
+	bnad_vmw_max_netq_filters ) + BNAD_FIRST_NETQ_RXF)
+
+#define BNAD_WAIT_FOR_COMPLETION(_X) \
+	{    \
+		int i; \
+		for(i = 0; i < BNAD_MBOX_TIMEOUT; i++) {      \
+			msleep(BNAD_MBOX_MDELAY);      \
+			if (_X != BNAD_MBOX_WAITING) \
+				break; \
+		}	\
+	 }
+
+#endif
+
+#define BNAD_NOT_READY(_bnad)	test_bit(BNAD_RESETTING, &(_bnad)->state)
+
+#define BNAD_Q_INDEX_CHANGE(_old_idx, _updated_idx, _q_depth)	\
+    (((_updated_idx) - (_old_idx)) & ((_q_depth) - 1))
+
+#if defined (__VMKERNEL_MODULE__) || defined(BNAD_OWN_LOCK)
+#define bnad_lock()	spin_lock(&bnad->lock)
+#define bnad_unlock()	spin_unlock(&bnad->lock)
+#define bnad_trylock() 	spin_trylock(&bnad->lock)
+#define bnad_is_locked() spin_is_locked(&bnad->lock)
+#define ASSERT_BNAD_LOCK() do { if (bnad_is_locked() == 0)  \
+{ \
+	printk("bna: lock: assert failed at " __FILE__ "(%d)\n", __LINE__); } \
+} while(0)
+
+#ifndef RTNL_DEFINES
+#define RTNL_DEFINES 1
+
+#undef rtnl_lock
+#define rtnl_lock()	bnad_lock()
+
+#undef rtnl_unlock
+#define rtnl_unlock()	bnad_unlock()
+
+#undef ASSERT_RTNL
+#define ASSERT_RTNL()	ASSERT_BNAD_LOCK()
+
+#endif
+#else
+#define bnad_lock()
+#define bnad_unlock()
+#endif
+
+struct bnad_skb_unmap {
+	struct sk_buff *skb;
+	  DECLARE_PCI_UNMAP_ADDR(dma_addr)
+};
+
+struct bnad_unmap_q {
+	u32 producer_index;
+	u32 consumer_index;
+	struct bnad_skb_unmap *unmap_array;
+	u32 q_depth;
+};
+
+struct bnad_ib_entry {
+	struct bna_ib *ib;
+	void *ib_seg_addr;
+	struct bna_ib_config ib_config;
+};
+
+struct bnad_txq_info {
+	unsigned long flags;
+#define BNAD_TXQ_FREE_SENT	0
+	struct bna_txq txq;
+	struct bna_ib ib;
+	struct bnad_unmap_q skb_unmap_q;
+	u64 tx_packets;
+	u64 tx_bytes;
+	struct bnad *bnad;
+	volatile u32 *hw_consumer_index;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	atomic_t counter;
+#endif
+	struct bna_txq_config txq_config;
+	char name[BNAD_QUEUE_NAME_SIZE];
+#ifdef DEBUG_TX
+	u32 max_tso;
+	u32 tx_vectors[32];
+#endif
+} ____cacheline_aligned;
+
+struct bnad_rxq_info {
+	unsigned long flags;
+#define BNAD_RXQ_REFILL		0
+	struct bna_rxq rxq;
+	struct bnad_unmap_q skb_unmap_q;
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 rx_packets_with_error;
+	u64 rxbuf_alloc_failed;
+	struct bnad *bnad;
+	u32 rxq_id;
+	struct bna_rxq_config rxq_config;
+#ifdef DEBUG_RX
+	u32 rx_packets_cpu[BNAD_MAX_RXQSETS_USED];
+	u32 rx_bytes_cpu[BNAD_MAX_RXQSETS_USED];
+#endif
+} ____cacheline_aligned;
+
+struct bnad_cq_info {
+	struct bna_cq cq;
+	struct bna_ib ib;
+	struct bnad *bnad;
+#ifdef BNA_DYN_INTR_MOD
+	struct bna_pkt_rate pkt_rate;
+	u8 rx_coalescing_timeo;	/* Unit is 5usec. */
+#endif
+	volatile u32 *hw_producer_index;
+#ifdef BNAD_LRO
+	struct net_lro_mgr lro;
+#endif
+#ifdef BNAD_NEW_NAPI
+	struct napi_struct napi;
+#endif
+	u32 cq_id;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	atomic_t counter;
+	atomic_t completions_flag;
+#endif
+	struct bna_cq_config cq_config;
+	char name[BNAD_QUEUE_NAME_SIZE];
+} ____cacheline_aligned;
+
+struct bnad_txf_info {
+	u32 txf_id;
+	struct bna_txf_config txf_config;
+};
+
+struct bnad_rxf_info {
+	u32 rxf_id;
+	struct bna_rxf_config rxf_config;
+};
+
+enum bnad_ucast_cmd {
+	BNAD_UCAST_MAC_SET,
+	BNAD_UCAST_MAC_ADD,
+	BNAD_UCAST_MAC_DEL
+};
+
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+
+{
+	vmknetddi_queueops_filter_t filter;	/* filter details */
+	u32 rxf_id;		/* rxf_id used for the filter */
+} bnad_vmw_netq_filter_t;
+
+{
+	vmknetddi_queueops_queue_t type;	/* NetQueue type */
+	enum bna_bool_e used;	/* used flag */
+	u32 active_filter_count;	/* current number of filters */
+} bnad_vmw_netq_t;
+
+#endif
+
+struct bnad_diag_lb_params {
+	struct bnad *bnad;
+	struct completion diag_lb_comp;
+	int diag_lb_comp_status;
+	int diag_lb_link_state;
+#define BNAD_DIAG_LB_LS_UNKNOWN	-1
+#define BNAD_DIAG_LB_LS_UP	 0
+#define BNAD_DIAG_LB_LS_DOWN	 1
+};
+
+#define BNAD_AEN_MAX_APPS 8
+struct bnad_aen_file_s {
+	struct list_head qe;
+	struct bnad *bnad;
+	s32 ri;
+	s32 app_id;
+};
+
+struct bnad {
+	struct net_device *netdev;
+	struct pci_dev *pcidev;
+	struct bna_dev_s *priv;
+
+	unsigned long state;
+#define BNAD_DISABLED		0
+#define BNAD_RESETTING		1
+#define BNAD_REMOVED		2
+#define BNAD_DIAG_LB_MODE	3
+#define BNAD_SET_UCAST		4
+#define BNAD_IOC_DISABLED	5
+#define BNAD_PORT_DISABLED	6
+#define BNAD_MBOX_IRQ_DISABLED	7
+
+	unsigned int flags;
+#define BNAD_F_MSIX		0x01
+#define BNAD_F_PROMISC		0x02
+#define BNAD_F_ALLMULTI		0x04
+#define BNAD_F_WOL		0x08
+#define BNAD_F_TXQ_DEPTH	0x10
+#define BNAD_F_RXQ_DEPTH	0x20
+
+
+	uint txq_num;
+	uint txq_depth;
+	struct bnad_txq_info *txq_table;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	u64 rxq_active;
+#endif
+	uint rxq_num;
+	uint rxq_depth;
+	struct bnad_rxq_info *rxq_table;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	u64 cq_active;
+#endif
+	uint cq_num;
+	struct bnad_cq_info *cq_table;
+
+	struct vlan_group *vlangrp;
+
+	u32 rx_csum;
+
+	uint msix_num;
+	struct msix_entry *msix_table;
+
+	uint ib_num;
+	struct bnad_ib_entry *ib_table;
+
+	struct bna_rit_entry *rit;	/* RxQ Indirection Table */
+
+	spinlock_t priv_lock ____cacheline_aligned;
+
+	uint txf_num;
+	struct bnad_txf_info *txf_table;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	u64 rxf_active;
+#endif
+	uint rxf_num;
+	struct bnad_rxf_info *rxf_table;
+
+	struct timer_list stats_timer;
+	struct net_device_stats net_stats;
+
+	u8 tx_coalescing_timeo;	/* Unit is 5usec. */
+	u8 tx_interpkt_count;
+
+	u8 rx_coalescing_timeo;	/* Unit is 5usec. */
+	u8 rx_interpkt_count;
+	u8 rx_interpkt_timeo;	/* 4 bits, unit is 0.5usec. */
+#ifdef BNA_DYN_INTR_MOD
+	u8 rx_dyn_coalesce_on;	/* Rx Dynamic Intr Moderation Flag */
+#else
+	u8 rsvd_1;
+#endif
+	u8 ref_count;
+	u8 lldp_comp_status;
+	u8 cee_stats_comp_status;
+	u8 cee_reset_stats_status;
+	u8 ucast_comp_status;
+	u8 qstop_comp_status;
+	u16 rsvd_2;
+	int ioc_comp_status;
+
+	struct bna_pause_config pause_config;
+
+	struct bna_stats *hw_stats;
+	struct bnad_drv_stats stats;
+
+	struct work_struct work;
+	unsigned int work_flags;
+#define BNAD_WF_ERROR		0x1
+#define BNAD_WF_RESETDONE	0x2
+
+	struct completion lldp_comp;
+	struct completion cee_stats_comp;
+	struct completion cee_reset_stats_comp;
+	struct completion ucast_comp;
+	struct completion qstop_comp;
+	struct completion ioc_comp;
+
+	u32 bna_id;
+	u8 __iomem *bar0;	/* registers */
+	unsigned char perm_addr[ETH_ALEN];
+	u32 pci_saved_config[16];
+
+	void *priv_stats;
+	  DECLARE_PCI_UNMAP_ADDR(priv_stats_dma)
+
+	struct bfa_log_mod_s log_data;
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_log_mod_s *logmod;
+	struct bfa_aen_s *aen;
+	struct bfa_aen_s aen_buf;
+	struct bnad_aen_file_s file_buf[BNAD_AEN_MAX_APPS];
+	struct list_head file_q;
+	struct list_head file_free_q;
+	struct bna_meminfo ioc_meminfo[BNA_MEM_T_MAX];
+	struct timer_list ioc_timer;
+#if defined (__VMKERNEL_MODULE__) || defined(BNAD_OWN_LOCK)
+	spinlock_t lock;
+#endif
+
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	u32 netq_rx_num;	/* current number of Rx NetQueues */
+	bnad_vmw_netq_t *netq_rx;	/* pointer to allocated NetQueue array */
+	bnad_vmw_netq_filter_t *filters;	/* pointer to global array of filters */
+#endif
+
+	struct bna_mbox_cbfn priv_cbfn;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	atomic_t counter;
+#endif
+
+	char adapter_name[64];
+	char port_name[64];
+
+	/* Diagnostics */
+	struct bna_diag_lb_pkt_stats *lb_stats;
+	struct bnad_diag_lb_params *dlbp;
+
+	/* CEE Stuff */
+	struct bfa_cee_cbfn_s cee_cbfn;
+	struct bfa_cee_s cee;
+
+	struct list_head list_entry;
+};
+
+extern uint bnad_rxqs_per_cq;
+extern uint bnad_rxq_depth;
+extern uint bnad_txq_depth;
+extern uint bnad_small_large_rxbufs;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+extern uint bnad_vmw_max_netqs;
+extern uint bnad_vmw_max_netq_filters;
+#endif
+
+extern struct list_head bnad_list;
+
+int bnad_open(struct net_device *netdev);
+int bnad_stop(struct net_device *netdev);
+int bnad_stop_locked(struct net_device *netdev);
+int bnad_open_locked(struct net_device *netdev);
+int bnad_sw_reset(struct net_device *netdev);
+int bnad_resetting(struct bnad *bnad);
+void bnad_set_ethtool_ops(struct net_device *netdev);
+void bnad_ioctl_init(void);
+void bnad_ioctl_exit(void);
+struct net_device_stats *bnad_get_stats(struct net_device *netdev);
+void bnad_reset_stats(struct net_device *netdev);
+
+int bnad_ucast_mac(struct bnad *bnad, unsigned int rxf_id,
+		   u8 * mac_ptr, unsigned int cmd);
+int bnad_rxq_init(struct bnad *bnad, uint rxq_id);
+void bnad_setup_rxq(struct bnad *bnad, uint rxq_id);
+void bnad_alloc_for_rxq(struct bnad *bnad, uint rxq_id);
+void bnad_free_rxq(struct bnad *bnad, uint rxq_id);
+int bnad_cq_init(struct bnad *bnad, uint cq_id);
+void bnad_setup_cq(struct bnad *bnad, uint cq_id);
+int bnad_alloc_ib(struct bnad *bnad, uint ib_id);
+void bnad_setup_ib(struct bnad *bnad, uint ib_id);
+void bnad_rxib_init(struct bnad *bnad, uint cq_id, uint ib_id);
+void bnad_free_ib(struct bnad *bnad, uint ib_id);
+int bnad_request_cq_irq(struct bnad *bnad, uint cq_id);
+u32 bnad_get_msglevel(struct net_device *netdev);
+void bnad_set_msglevel(struct net_device *netdev, u32 msglevel);
+int bnad_alloc_unmap_q(struct bnad_unmap_q *unmap_q, u32 q_depth);
+int bnad_disable_rxq(struct bnad *bnad, u32 rxq_id);
+void bnad_free_cq(struct bnad *bnad, uint cq_id);
+void bnad_add_to_list(struct bnad *bnad);
+void bnad_remove_from_list(struct bnad *bnad);
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+int bnad_alloc_netq_array(struct bnad *bnad);
+int bnad_netqueue_ops(vmknetddi_queueops_op_t op, void *args);
+int bnad_enable_untagged_packets(struct bnad *bnad, uint rxf_id, uint enable);
+int bnad_netq_restore_filters(struct bnad *bnad);
+int bnad_netq_remove_filters(struct bnad *bnad);
+#endif
+struct bnad *get_bnadev(int bna_id);
+/* For diagnostics */
+int bnad_diag_lb_rx(struct bnad *bnad, struct sk_buff *skb);
+int bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev);
+
+#endif /* _BNAD_H_ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bnad_trcmod.h linux-2.6.30.5-mod/drivers/net/bna/bnad_trcmod.h
--- linux-2.6.30.5-orig/drivers/net/bna/bnad_trcmod.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bnad_trcmod.h	2009-08-28 21:09:23.923818000 -0700
@@ -0,0 +1,46 @@
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
+ *  bfad_trcmod.h Linux driver trace modules
+ */
+
+
+#ifndef __BNAD_TRCMOD_H__
+#define __BNAD_TRCMOD_H__
+
+
+/*
+ * !!! Only append to the enums defined here to avoid any versioning
+ * !!! needed between trace utility and driver version
+ */
+enum {
+	BNA_TRC_LDRV_BNAD = 63,
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	BNA_TRC_LDRV_NETQ = 62,
+#endif
+	BNA_TRC_LDRV_IOCTL = 61,
+	BNA_TRC_LDRV_DIAG = 60,
+};
+#endif /* __BNAD_TRCMOD_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_intr.h linux-2.6.30.5-mod/drivers/net/bna/bna_intr.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna_intr.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_intr.h	2009-08-28 21:09:24.383816000 -0700
@@ -0,0 +1,95 @@
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
+ *
+ * File for interrupt macros and functions
+ */
+
+#ifndef __BNA_INTR_H__
+#define __BNA_INTR_H__
+
+static inline void
+bna_intx_disable(struct bna_dev_s *dev, volatile u32 * cur_mask)
+{
+	/* Store the original mask */
+	*cur_mask = bna_reg_read(dev->regs.fn_int_mask);
+	bna_reg_write(dev->regs.fn_int_mask, 0xffffffff);
+}
+
+#define bna_intx_enable(dev, new_mask) 			\
+	bna_reg_write((dev)->regs.fn_int_mask, (new_mask))
+
+#define bna_mbox_intr_disable(dev)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	     (bna_reg_read((dev)->regs.fn_int_mask) | \
+	     (__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)))
+
+#define bna_mbox_intr_enable(dev)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	     (bna_reg_read((dev)->regs.fn_int_mask) & \
+	     ~(__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)))
+
+static inline void
+bna_intr_status_get(struct bna_dev_s *dev, u32 * status)
+{
+	*status = bna_reg_read(dev->regs.fn_int_status);
+	/*
+	 * Clear the status bits before returning
+	 * But do not touch the mailbox bits as yet
+	 */
+	/* Write a '1' to clear the required bits */
+	if (*status) {
+		bna_reg_write(dev->regs.fn_int_status,
+			      *status &
+			      ~(__LPU02HOST_MBOX0_STATUS_BITS |
+				__LPU02HOST_MBOX1_STATUS_BITS |
+				__LPU12HOST_MBOX0_STATUS_BITS |
+				__LPU12HOST_MBOX1_STATUS_BITS));
+	}
+}
+
+#define bna_intr_status_get_no_clr(dev, status)		\
+	*(status) = bna_reg_read((dev)->regs.fn_int_status)
+
+#define bna_intr_mask_get(dev, mask)		\
+	(*mask) = bna_reg_read((dev)->regs.fn_int_mask)
+
+#define bna_intr_ack(dev, intr_bmap)		\
+	bna_reg_write((dev)->regs.fn_int_status, (intr_bmap))
+
+#define bna_ib_intx_disable(dev, ib_id)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	    bna_reg_read((dev)->regs.fn_int_mask) | \
+	    (1 << (ib_id)))
+
+#define bna_ib_intx_enable(dev, ib_id)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	    bna_reg_read((dev)->regs.fn_int_mask) & \
+	    ~(1 << (ib_id)))
+
+extern const struct bna_chip_regs_offset reg_offset[];
+#define bna_mbox_msix_idx_set(dev, msix_vector)		\
+	bna_reg_write((dev)->bar0 + reg_offset[(dev)->pci_fn].msix_idx, \
+	    ((msix_vector) & 0x000001ff))
+
+
+#endif /* __BNA_INTR_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_log_trc.h linux-2.6.30.5-mod/drivers/net/bna/bna_log_trc.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna_log_trc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_log_trc.h	2009-08-28 21:09:24.598813000 -0700
@@ -0,0 +1,331 @@
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
+ *
+ *	Copyright (c) 2008 Brocade Communications Systems, Inc.
+ *  All rights reserved.
+ *
+ *  Description:
+ *  Common logging and Tracing structure and function definitions
+ *
+ */
+#ifndef _BNA_LOG_TRC_H
+#define _BNA_LOG_TRC_H
+
+#include <bna_os.h>
+#include <bfa_trc.h>
+
+#ifndef BNA_STAT_REC_MAX
+#define BNA_STAT_REC_MAX 	256
+#endif
+
+#ifndef BNA_DESC_MAX
+#define BNA_DESC_MAX		32
+#endif
+
+#define STAT_VALID_SIGN		0xEFEFEFEF
+#define STAT_INVALID_SIGN 	0xFEFEFEFE
+
+#define TRACE_CRITICAL_LEVEL	1
+#define	TRACE_ERROR_LEVEL	2
+#define TRACE_WARN_LEVEL	5
+#define TRACE_INFO_LEVEL	6
+#define TRACE_DEBUG_LEVEL	7
+
+#define LOG_CRITICAL_LEVEL	TRACE_CRITICAL_LEVEL
+#define	LOG_ERROR_LEVEL		TRACE_ERROR_LEVEL
+#define LOG_WARN_LEVEL		TRACE_WARN_LEVEL
+#define LOG_INFO_LEVEL		TRACE_INFO_LEVEL
+#define LOG_DEBUG_LEVEL		TRACE_DEBUG_LEVEL
+
+/* Can be used to vary level of tracing */
+#define	BNA_TRACE_CURRENT_LEVEL	TRACE_DEBUG_LEVEL
+/* Can be used to vary level of logging */
+#define BNA_LOG_CURRENT_LEVEL	LOG_DEBUG_LEVEL
+
+
+struct bfa_trc_mod_s;
+
+extern u32 bna_trc_curr_lvl;
+
+#define BNA_TRC_SET_LEVEL(_lvl)		\
+	u32 bna_trc_curr_lvl = (_lvl);
+
+
+
+
+typedef unsigned long (*bna_log_func_t) (const char *fmt, ...);
+
+
+struct bna_log_mod_s {
+	u32 current_lvl;
+	bna_log_func_t log_func;
+};
+extern struct bna_log_mod_s logmod;
+
+
+struct bna_stat_rec_s {
+	u32 signature;
+	u32 counter;
+	u8 desc[BNA_DESC_MAX];	/* Description of the counter */
+};
+
+
+struct bna_stat_mod_s {
+	u32 rec_index;
+	struct bna_stat_rec_s stat_recs[BNA_STAT_REC_MAX];
+};
+
+/**
+ *	brief Handle to Statistics counter record array
+ */
+typedef void *bna_stat_handle_t;
+
+#define BNA_TRC_MOD(__mod)	((BNA_TRC_ ## __mod) << BFA_TRC_MOD_SH)
+
+#define BNA_TRC_FILE(__mod, __submod)					\
+	static int __trc_fileno = ((BNA_TRC_ ## __mod ## _ ## __submod) | \
+						 BNA_TRC_MOD(__mod))
+
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 32 bit value to be traced
+ */
+#define bna_trc32	bfa_trc32
+
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 64 bit value to be traced
+ */
+#define bna_trc		bfa_trc
+
+/**
+ * @param[in] log_function - OS dependent logging function
+ */
+
+#define BNA_LOG_INIT(log_function)	\
+	struct bna_log_mod_s logmod = {BNA_LOG_CURRENT_LEVEL, log_function}
+
+
+/*
+ * Level based tracing is currently not supported.
+ * All the BNA_TRC_X macros call bfa_trc directly.
+ */
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 64 bit value to be traced
+ * @param[in] _log  - Input to Logging function
+ */
+#define BNA_TRACE_ERROR(_trcp, _data, _log)			\
+do {								\
+	if (bna_trc_curr_lvl >= TRACE_ERROR_LEVEL)		\
+		bna_trc((_trcp), (u64)(_data));      \
+	BNA_LOG_ERROR(_log);      \
+} while (0)
+
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 64 bit value to be traced
+ * @param[in] _log  - Input to Logging function
+ */
+#define BNA_TRACE_WARN(_trcp, _data, _log)			\
+do {								\
+	if (bna_trc_curr_lvl >= TRACE_WARN_LEVEL)		\
+		bna_trc((_trcp), (u64)(_data));      \
+	BNA_LOG_WARN(_log);      \
+} while (0)
+
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 64 bit value to be traced
+ * @param[in] _log  - Input to Logging function
+ */
+#define BNA_TRACE_INFO(_trcp, _data, _log)			\
+do {								\
+	if (bna_trc_curr_lvl >= TRACE_INFO_LEVEL)		\
+		bna_trc((_trcp), (u64)(_data));      \
+      	BNA_LOG_INFO(_log);      \
+} while (0)
+
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 64 bit value to be traced
+ * @param[in] _log  - Input to Logging function
+ */
+#define BNA_TRACE_DEBUG(_trcp, _data, _log)			\
+do {								\
+	if (bna_trc_curr_lvl >= TRACE_DEBUG_LEVEL)		\
+		bna_trc((_trcp), (u64)(_data));      \
+      	BNA_LOG_DEBUG(_log);      \
+} while (0)
+
+/**
+ * @param[in] _trcp - Pointer to structure embedding bna_trc_mod_t
+ * @param[in] _data - 64 bit value to be traced
+ */
+#define BNA_TRACE(_trcp, _data)					\
+do {								\
+	bna_trc((_trcp), (u64)(_data));      \
+} while (0)
+
+
+
+/**
+ * @param[in] _log - Input to Logging Function
+ */
+#define BNA_LOG_ERROR(_log)				\
+	if(logmod.current_lvl >= LOG_ERROR_LEVEL) {      \
+		logmod.log_func("bna: ");      \
+		logmod.log_func _log;			\
+	}
+
+/**
+ * @param[in] _log - Input to Logging Function
+ */
+#define BNA_LOG_WARN(_log)   				\
+	if(logmod.current_lvl >= LOG_WARN_LEVEL) {      \
+		logmod.log_func("bna: ");      \
+		logmod.log_func _log;			\
+	}
+
+/**
+ * @param[in] _log - Input to Logging Function
+ */
+#define BNA_LOG_INFO(_log)   				\
+	if(logmod.current_lvl >= LOG_INFO_LEVEL) {      \
+		logmod.log_func("bna: ");      \
+		logmod.log_func _log;			\
+	}
+
+/**
+ * @param[in] _log - Input to Logging Function
+ */
+#define BNA_LOG_DEBUG(_log)				\
+	if(logmod.current_lvl >= LOG_DEBUG_LEVEL) {      \
+		logmod.log_func("bna: ");      \
+		logmod.log_func _log;			\
+	}
+
+/**
+ * @param[in] trcm - Pointer to Trace Module
+ */
+#define bna_trc_init bfa_trc_init
+
+/**
+ * @param[in] trcm - Pointer to Trace Module
+ */
+#define bna_trc_stop bfa_trc_stop;
+
+#if 0
+/**
+ * @param[in] trcm - Pointer to Trace Module
+ * @param[in] level - New tracing level
+ */
+static inline void
+bna_trc_change_level(bna_trc_mod_t * trcm, u32 level)
+{
+	BNA_ASSERT(trcm != NULL);
+	trcm->current_lvl = level;
+}
+#endif
+
+/**
+ * @param[in] level	- New tracing level
+ */
+static __inline void
+bna_log_change_level(u32 level)
+{
+	logmod.current_lvl = level;
+}
+
+
+#ifdef BNAFW			/* BNA Firmware */
+extern void dc_flush(void *data);
+#else
+#define dc_flush(data)
+#endif
+
+
+
+/**
+ * Functions for managing operational counters
+ */
+
+/**
+ * @param[in] stat - Pointer to Stat module
+ */
+static inline void
+bna_stat_init(struct bna_stat_mod_s *stat)
+{
+	u32 idx = 0;
+	stat->rec_index = 0;
+	for (idx = 0; idx < BNA_STAT_REC_MAX; idx++) {
+		stat->stat_recs[idx].signature = STAT_INVALID_SIGN;
+	}
+}
+
+/**
+ * @param[in] stat - Pointer to Stat module
+ * @param[in] desc - Description of Stat counter
+ * @param[in] size - Size of the Description String
+ * @return bna_stat_handle_t - Handle to registered stat
+ */
+static inline bna_stat_handle_t
+bna_stat_register(struct bna_stat_mod_s *stat, char *desc, u32 size)
+{
+	u32 cnt = 0;
+	if (size > BNA_DESC_MAX)
+		size = BNA_DESC_MAX;
+
+	while ((stat->stat_recs[stat->rec_index].signature != STAT_VALID_SIGN)
+	       && (cnt++ < BNA_STAT_REC_MAX)) {
+		stat->rec_index =
+			(stat->rec_index + 1) & (BNA_STAT_REC_MAX - 1);
+	}
+	stat->stat_recs[stat->rec_index].signature = STAT_VALID_SIGN;
+	bna_os_memcpy(stat->stat_recs[stat->rec_index].desc, desc, size);
+	return ((bna_stat_handle_t) &stat->stat_recs[stat->rec_index]);
+
+}
+
+/**
+ * @param[in] handle - Handle returned in bna_stat_register call
+ */
+
+static inline void
+bna_stat_deregister(bna_stat_handle_t handle)
+{
+
+	struct bna_stat_rec_s *rec = NULL;
+	BNA_ASSERT(handle);
+	rec = (struct bna_stat_rec_s *) handle;
+	rec->signature = STAT_INVALID_SIGN;
+}
+
+/**
+ * @param handle - Handle returned in bna_stat_register call
+ */
+
+static inline void
+bna_stat_inc(bna_stat_handle_t handle)
+{
+	BNA_ASSERT(handle);
+	if (((struct bna_stat_rec_s *) handle)->signature == STAT_VALID_SIGN)
+		((struct bna_stat_rec_s *) handle)->counter++;
+}
+
+#endif /* __BNA_LOG_TRC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_os.h linux-2.6.30.5-mod/drivers/net/bna/bna_os.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna_os.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_os.h	2009-08-28 21:09:24.154817000 -0700
@@ -0,0 +1,188 @@
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
+#ifdef __VMKERNEL_MODULE__
+#ifndef __iomem
+#define __iomem
+#endif
+#endif
+
+#ifdef DEBUG
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
+#define BNA_LOG(bnad, level, mask, fmt, arg...)				\
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
+#define BNA_TRC(value)
+
+#else /* DEBUG */
+
+#define BNA_ASSERT(p)
+#define BNA_LOG(bnad, level, mask, fmt, arg...)
+#define BNA_DEV_PRINTF(bnad, level, fmt, arg...)
+#define BNA_PRINTF(level, fmt, arg...)
+#define BNA_TRC(value)
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
+typedef void *bna_os_addr_t;
+
+#define bna_os_reg_read(_raddr)		readl(_raddr)
+#define bna_os_reg_write(_raddr, _val)	writel(_val, _raddr)
+#define bna_os_mem_read(_raddr, _off)      \
+    		bna_os_ntohl(((volatile u32 *)_raddr)[(_off) >> 2])
+#define bna_os_mem_write(_raddr, _off, _val)   \
+            (((volatile u32 *)_raddr)[(_off) >> 2]) = bna_os_htonl(_val)
+
+#define bna_os_mem_readw(_raddr)      	\
+		bna_os_htonl(*((volatile u32 *)(_raddr)))
+#define bna_os_mem_writew(_raddr, _val)   \
+		*((volatile u32 *)(_raddr)) = bna_os_htonl((_val))
+
+/* Required for DMA address manipulation in IOC */
+#define bfa_os_u32(__pa64) ((__pa64) >> 32)
+struct bna_log_mod_s;
+void bna_os_printf(struct bna_log_mod_s *log_mod, u32 msg_id,
+		   const char *fmt, ...);
+
+#endif /* __BNA_OS_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_priv.h linux-2.6.30.5-mod/drivers/net/bna/bna_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_priv.h	2009-08-28 21:09:24.413817000 -0700
@@ -0,0 +1,496 @@
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
+	u32 vlan_ram_entry;	/* FIXME */
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
+	u32 fc_bit;		/*  31:1->res;0->fc_bit */
+	u32 ll_fn_63_32;	/*  LL fns 63 to 32 */
+	u32 ll_fn_31_0;		/*  LL fns 31 to 0 */
+};
+
+/**
+ *  Structure which maps to RxFn Indirection Table (RIT)
+ *  Size : 1 word
+ *  See catapult_spec.pdf, RxA for details
+ */
+struct bna_rit_mem {
+	u32 rxq_ids;		/*  31:12->res;11:0->two 6 bit RxQ Ids */
+};
+
+/**
+ *  Structure which maps to RSS Table entry
+ *  Size : 16 words
+ *  See catapult_spec.pdf, RAD for details
+ */
+struct bna_rss_mem {
+	u32 type_n_hash;	/*  31:12->res;
+				   11:8 ->protocol type
+				   7:0 ->hash index */
+	u32 hash_key[10];	/*  40 byte Toeplitz hash key */
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
+	u32 pg_cnt_n_prd_ptr;	/*  31:16->total page count
+				   15:0 ->producer pointer (index?) */
+	u32 entry_n_pg_size;	/*  31:16->entry size
+				   15:0 ->page size */
+	u32 sg_n_cq_n_cns_ptr;	/* 31:28->reserved; 27:24->sg count
+				   23:16->CQ; 15:0->consumer pointer(index?) */
+	u32 buf_sz_n_q_state;	/*  31:16->buffer size; 15:0-> Q state */
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
+#if 0				/* obsolete, now replaced by reserved fields */
+	u32 nxt_pg_addr_lo u32 nxt_pg_addr_hi;
+#endif
+	u32 reserved1;
+	u32 reserved2;
+	u32 pg_cnt_n_prd_ptr;	/*  31:16->total page count
+				   15:0 ->producer pointer (index?) */
+	u32 entry_n_pg_size;	/*  31:16->entry size
+				   15:0 ->page size */
+	u32 int_blk_n_cns_ptr;	/*  31:24->Int Blk Id; 23:16->Int Blk Offset
+				   15:0 ->consumer pointer(index?) */
+	u32 cns_ptr2_n_q_state;	/* 31:16->cons. ptr 2; 15:0-> Q state */
+	u32 nxt_qid_n_fid_n_pri;	/*  17:10->next QId;9:3->FID;2:0->Priority */
+	u32 wvc_n_cquota_n_rquota;	/*  31:24->WI Vector Count;
+					   23:12->Cfg Quota;
+					   11:0 ->Run Quota */
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
+	u32 pg_cnt_n_prd_ptr;	/*  31:16->total page count
+				   15:0 ->producer pointer (index?) */
+	u32 entry_n_pg_size;	/*  31:16->entry size
+				   15:0 ->page size */
+	u32 int_blk_n_cns_ptr;	/*  31:24->Int Blk Id; 23:16->Int Blk Offset
+				   15:0 ->consumer pointer(index?) */
+	u32 q_state;		/*  31:16->reserved; 15:0-> Q state */
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
+	u32 clsc_n_ctrl_n_msix;	/*  31:24->coalescing;
+				   23:16->coalescing cfg;
+				   15:8 ->control;
+				   7:0 ->msix; */
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
+	u32 idx;		/*  31:16->res;15:0->idx; */
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
+#ifdef BNA_DYN_INTR_MOD
+/**
+ * Interrupt Moderation
+ */
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
+#define BNA_HIGH_LOAD_4		0	/* r >= 80 */
+#define BNA_HIGH_LOAD_3		1	/* 60 <= r < 80 */
+#define BNA_HIGH_LOAD_2		2	/* 50 <= r < 60 */
+#define BNA_HIGH_LOAD_1		3	/* 40 <= r < 50 */
+#define BNA_LOW_LOAD_1		4	/* 30 <= r < 40 */
+#define BNA_LOW_LOAD_2		5	/* 20 <= r < 30 */
+#define BNA_LOW_LOAD_3		6	/* 10 <= r < 20 */
+#define BNA_LOW_LOAD_4		7	/* r  <  10 K */
+#define BNA_LOAD_TYPES		BNA_LOW_LOAD_4
+
+#define BNA_BIAS_TYPES		2	/* small : small > large*2 */
+					/* large : if small is false */
+
+#endif /* BNA_DYN_INTR_MOD */
+
+#endif /* __BNA_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_queue.c linux-2.6.30.5-mod/drivers/net/bna/bna_queue.c
--- linux-2.6.30.5-orig/drivers/net/bna/bna_queue.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_queue.c	2009-08-28 21:09:24.001821000 -0700
@@ -0,0 +1,503 @@
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
+ *    Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *    All rights reserved.
+ *
+ *    @file bna_queue.c BNA Queues
+ */
+
+#include <bna_os.h>
+#include <bna_log_trc.h>
+#include "bna.h"
+#include "bna_hwreg.h"
+#include "bna_priv.h"
+#include "bna_trcmod.h"
+#include <bfi/bfi_ll.h>
+
+BNA_TRC_FILE(HAL, QUEUE);
+
+#define BNA_Q_IDLE_STATE	0x00008001
+/*
+ *-----------------------------------------------------------------------------
+ *  bna_txq_config()
+ *
+ *  For TxQ "txq_id", it configures the Tx-Queue as specified by "cfg_ptr".
+ *-----------------------------------------------------------------------------
+ */
+void
+bna_txq_config(struct bna_dev_s *dev, struct bna_txq *q_ptr,
+	       unsigned int txq_id, const struct bna_txq_config *cfg_ptr)
+{
+	struct bna_rxtx_q_mem *q_mem;
+	struct bna_txq_mem txq_cfg, *txq_mem;
+	const struct bna_qpt *qpt = &cfg_ptr->qpt;
+	struct bna_dma_addr cur_q_addr;
+	struct bna_doorbell_qset *qset;
+	u32 pg_num;
+
+	BNA_ASSERT(txq_id < BNA_TXQ_ID_MAX);
+	/* Check if the depth is a power of 2 */
+	BNA_ASSERT(BNA_POWER_OF_2(q_ptr->q.q_depth));
+
+	BNA_TRACE(dev, txq_id);
+
+	cur_q_addr = *((struct bna_dma_addr *) (qpt->kv_qpt_ptr));
+
+	/*
+	 * Fill out structure, to be subsequently written
+	 * to hardware
+	 */
+	txq_cfg.pg_tbl_addr_lo = qpt->hw_qpt_ptr.lsb;
+	txq_cfg.pg_tbl_addr_hi = qpt->hw_qpt_ptr.msb;
+
+	/* FIXME */
+	txq_cfg.cur_q_entry_lo = cur_q_addr.lsb;
+	txq_cfg.cur_q_entry_hi = cur_q_addr.msb;
+
+	txq_cfg.pg_cnt_n_prd_ptr = (qpt->page_count << 16) | 0x0;
+
+	/* Is the entry size in words ? Check */
+	txq_cfg.entry_n_pg_size = ((BNA_TXQ_ENTRY_SIZE >> 2) << 16) |
+		(qpt->page_size >> 2);
+	txq_cfg.int_blk_n_cns_ptr =
+		((((u8) cfg_ptr->ib_seg_index) << 24) |
+		 (((u8) cfg_ptr->ib_id) << 16) | 0x0);
+	txq_cfg.cns_ptr2_n_q_state = BNA_Q_IDLE_STATE;
+	txq_cfg.nxt_qid_n_fid_n_pri = (((cfg_ptr->txf_id
+					 & 0x3f) << 3) | (cfg_ptr->
+							  priority & 0x3));
+	txq_cfg.wvc_n_cquota_n_rquota =
+		(((cfg_ptr->wrr_quota & 0xfff) << 12) | (cfg_ptr->
+							 wrr_quota & 0xfff));
+
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+				  HQM_RXTX_Q_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr, pg_num);
+	/* Write to h/w */
+	q_mem = (struct bna_rxtx_q_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_RXTX_Q_RAM_BASE_OFFSET);
+
+	txq_mem = &q_mem[txq_id].txq;
+
+	/*
+	 * The following 4 lines, is a hack b'cos the H/W needs to read
+	 * these DMA addresses as little endian
+	 */
+	bna_mem_writew(&txq_mem->pg_tbl_addr_lo,
+		       bna_os_htonl(txq_cfg.pg_tbl_addr_lo));
+	bna_mem_writew(&txq_mem->pg_tbl_addr_hi,
+		       bna_os_htonl(txq_cfg.pg_tbl_addr_hi));
+	bna_mem_writew(&txq_mem->cur_q_entry_lo,
+		       bna_os_htonl(txq_cfg.cur_q_entry_lo));
+	bna_mem_writew(&txq_mem->cur_q_entry_hi,
+		       bna_os_htonl(txq_cfg.cur_q_entry_hi));
+
+	bna_mem_writew(&txq_mem->pg_cnt_n_prd_ptr, txq_cfg.pg_cnt_n_prd_ptr);
+	bna_mem_writew(&txq_mem->entry_n_pg_size, txq_cfg.entry_n_pg_size);
+	bna_mem_writew(&txq_mem->int_blk_n_cns_ptr, txq_cfg.int_blk_n_cns_ptr);
+	bna_mem_writew(&txq_mem->cns_ptr2_n_q_state,
+		       txq_cfg.cns_ptr2_n_q_state);
+	bna_mem_writew(&txq_mem->nxt_qid_n_fid_n_pri,
+		       txq_cfg.nxt_qid_n_fid_n_pri);
+	bna_mem_writew(&txq_mem->wvc_n_cquota_n_rquota,
+		       txq_cfg.wvc_n_cquota_n_rquota);
+
+	BNA_LOG_DEBUG(("TxQ %u\n", txq_id));
+	BNA_LOG_DEBUG(("TxQ pg_tbl_addr_lo 0x%x\n",
+		       bna_os_ntohl(txq_cfg.pg_tbl_addr_lo)));
+	BNA_LOG_DEBUG(("TxQ cur_q_entry_lo 0x%x\n",
+		       bna_os_ntohl(txq_cfg.cur_q_entry_lo)));
+	BNA_LOG_DEBUG(("TxQ pg_cnt_n_prd_ptr 0x%x\n",
+		       txq_cfg.pg_cnt_n_prd_ptr));
+	BNA_LOG_DEBUG(("TxQ entry_n_pg_size 0x%x\n", txq_cfg.entry_n_pg_size));
+	BNA_LOG_DEBUG(("TxQ int_blk_n_cns_ptr 0x%x\n",
+		       txq_cfg.int_blk_n_cns_ptr));
+	BNA_LOG_DEBUG(("TxQ cns_ptr2_n_q_state 0x%x\n",
+		       txq_cfg.cns_ptr2_n_q_state));
+	BNA_LOG_DEBUG(("TxQ nxt_qid_n_fid_n_pri 0x%x\n",
+		       txq_cfg.nxt_qid_n_fid_n_pri))
+		BNA_LOG_DEBUG(("TxQ wvc_n_cquota_n_rquota 0x%x\n",
+			       txq_cfg.wvc_n_cquota_n_rquota));
+
+	qset = (struct bna_doorbell_qset *)
+		BNA_GET_DOORBELL_BASE_ADDR(dev->bar0);
+	q_ptr->doorbell = &qset[txq_id].txq[0];
+
+	q_ptr->q.producer_index = 0;
+	q_ptr->q.consumer_index = 0;
+}
+
+
+/**
+ * bna_txq_stop()
+ *
+ * 	Stops the TxQ identified by the TxQ Id.
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	conclude if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the TxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e
+bna_txq_stop(struct bna_dev_s *dev, u32 txq_id)
+{
+	struct bfi_ll_q_stop_req ll_req;
+	u64 bit_mask = 1 << txq_id;
+
+	ll_req.mh.msg_class = BFI_MC_LL;
+	ll_req.mh.msg_id = BFI_LL_H2I_TXQ_STOP_REQ;
+	ll_req.mh.mtag.i2htok = 0;
+
+	ll_req.q_id_mask[0] = bna_os_htonl((u32) bit_mask);
+	ll_req.q_id_mask[1] = bna_os_htonl((u32) (bit_mask >> 32));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+/*
+ *-----------------------------------------------------------------------------
+ *  bna_rxq_config()
+ *
+ *  For RxQ "rxq_id", it configures the Rx-Queue as specified by "cfg_ptr".
+ *-----------------------------------------------------------------------------
+ */
+void
+bna_rxq_config(struct bna_dev_s *dev, struct bna_rxq *q_ptr,
+	       unsigned int rxq_id, const struct bna_rxq_config *cfg_ptr)
+{
+	struct bna_rxtx_q_mem *q_mem;
+	struct bna_rxq_mem rxq_cfg, *rxq_mem;
+	const struct bna_qpt *qpt = &cfg_ptr->qpt;
+	struct bna_dma_addr cur_q_addr;
+	struct bna_doorbell_qset *qset;
+	u32 pg_num;
+
+	BNA_ASSERT(rxq_id < BNA_RXQ_ID_MAX);
+
+	/* Check if the depth is a power of 2 */
+	BNA_ASSERT(BNA_POWER_OF_2(q_ptr->q.q_depth));
+
+	BNA_TRACE(dev, rxq_id);
+
+	cur_q_addr = *((struct bna_dma_addr *) (qpt->kv_qpt_ptr));
+	/*
+	 * Fill out structure, to be subsequently written
+	 * to hardware
+	 */
+	rxq_cfg.pg_tbl_addr_lo = qpt->hw_qpt_ptr.lsb;
+	rxq_cfg.pg_tbl_addr_hi = qpt->hw_qpt_ptr.msb;
+	rxq_cfg.cur_q_entry_lo = cur_q_addr.lsb;
+	rxq_cfg.cur_q_entry_hi = cur_q_addr.msb;
+
+	rxq_cfg.pg_cnt_n_prd_ptr = (qpt->page_count << 16) | 0x0;
+	rxq_cfg.entry_n_pg_size = ((BNA_RXQ_ENTRY_SIZE >> 2) << 16) |
+		(qpt->page_size >> 2);
+	rxq_cfg.sg_n_cq_n_cns_ptr = (((u8) cfg_ptr->cq_id) << 16) | 0x0;
+	rxq_cfg.buf_sz_n_q_state =
+		(cfg_ptr->buffer_size << 16) | BNA_Q_IDLE_STATE;
+	rxq_cfg.next_qid = 0x0 | (0x3 << 8);
+
+	/* Write the page number register */
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+				  HQM_RXTX_Q_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, pg_num);
+
+	/* Write to h/w */
+	q_mem = (struct bna_rxtx_q_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_RXTX_Q_RAM_BASE_OFFSET);
+	rxq_mem = &q_mem[rxq_id].rxq;
+
+	bna_mem_writew(&rxq_mem->pg_tbl_addr_lo,
+		       bna_os_htonl(rxq_cfg.pg_tbl_addr_lo));
+	bna_mem_writew(&rxq_mem->pg_tbl_addr_hi,
+		       bna_os_htonl(rxq_cfg.pg_tbl_addr_hi));
+	bna_mem_writew(&rxq_mem->cur_q_entry_lo,
+		       bna_os_htonl(rxq_cfg.cur_q_entry_lo));
+	bna_mem_writew(&rxq_mem->cur_q_entry_hi,
+		       bna_os_htonl(rxq_cfg.cur_q_entry_hi));
+
+	bna_mem_writew(&rxq_mem->pg_cnt_n_prd_ptr, rxq_cfg.pg_cnt_n_prd_ptr);
+	bna_mem_writew(&rxq_mem->entry_n_pg_size, rxq_cfg.entry_n_pg_size);
+	bna_mem_writew(&rxq_mem->sg_n_cq_n_cns_ptr, rxq_cfg.sg_n_cq_n_cns_ptr);
+	bna_mem_writew(&rxq_mem->buf_sz_n_q_state, rxq_cfg.buf_sz_n_q_state);
+	bna_mem_writew(&rxq_mem->next_qid, rxq_cfg.next_qid);
+
+	BNA_LOG_DEBUG(("RxQ %u\n", rxq_id));
+	BNA_LOG_DEBUG(("RxQ pg_tbl_addr_lo 0x%x\n",
+		       bna_os_ntohl(rxq_cfg.pg_tbl_addr_lo)));
+	BNA_LOG_DEBUG(("RxQ cur_q_entry_lo 0x%x\n",
+		       bna_os_ntohl(rxq_cfg.cur_q_entry_lo)));
+	BNA_LOG_DEBUG(("RxQ pg_cnt_n_prd_ptr 0x%x\n",
+		       rxq_cfg.pg_cnt_n_prd_ptr));
+	BNA_LOG_DEBUG(("RxQ entry_n_pg_size 0x%x\n", rxq_cfg.entry_n_pg_size));
+	BNA_LOG_DEBUG(("RxQ sg_n_cq_n_cns_ptr 0x%x\n",
+		       rxq_cfg.sg_n_cq_n_cns_ptr));
+	BNA_LOG_DEBUG(("RxQ buf_sz_n_q_state 0x%x\n",
+		       rxq_cfg.buf_sz_n_q_state));
+	BNA_LOG_DEBUG(("RxQ next_qid %u\n", rxq_cfg.next_qid));
+
+	qset = (struct bna_doorbell_qset *)
+		BNA_GET_DOORBELL_BASE_ADDR(dev->bar0);
+	q_ptr->doorbell = &qset[rxq_id].rxq[0];
+
+	q_ptr->q.producer_index = 0;
+	q_ptr->q.consumer_index = 0;
+}
+
+
+/**
+ * bna_rxq_stop()
+ *
+ * 	Stops the RxQ identified by the RxQ Id.
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	conclude if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the RxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e
+bna_rxq_stop(struct bna_dev_s *dev, u32 rxq_id)
+{
+	struct bfi_ll_q_stop_req ll_req;
+	u64 bit_mask = 1 << rxq_id;
+
+	ll_req.mh.msg_class = BFI_MC_LL;
+	ll_req.mh.msg_id = BFI_LL_H2I_RXQ_STOP_REQ;
+	ll_req.mh.mtag.i2htok = 0;
+
+	ll_req.q_id_mask[0] = bna_os_htonl((u32) bit_mask);
+	ll_req.q_id_mask[1] = bna_os_htonl((u32) (bit_mask >> 32));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+enum bna_status_e
+bna_multi_rxq_stop(struct bna_dev_s *dev, u64 rxq_id_mask)
+{
+	struct bfi_ll_q_stop_req ll_req;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RXQ_STOP_REQ, 0);
+
+	ll_req.q_id_mask[0] = bna_os_htonl((u32) rxq_id_mask);
+	ll_req.q_id_mask[1] = bna_os_htonl((u32) (rxq_id_mask >> 32));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+/*
+ *-----------------------------------------------------------------------------
+ *  bna_cq_config()
+ *
+ *  For CQ "cq_id", it configures the Rx-Completion Queue as specified by
+ *  "cfg_ptr".
+ *-----------------------------------------------------------------------------
+ */
+void
+bna_cq_config(struct bna_dev_s *dev, struct bna_cq *q_ptr,
+	      unsigned int cq_id, const struct bna_cq_config *cfg_ptr)
+{
+	struct bna_cq_mem cq_cfg, *cq_mem;
+	const struct bna_qpt *qpt = &cfg_ptr->qpt;
+	struct bna_dma_addr cur_q_addr;
+	u32 pg_num;
+
+	BNA_ASSERT(cq_id < BNA_CQ_ID_MAX);
+
+	/* Check if the depth is a power of 2 */
+	/* How do we ensure this ? */
+	BNA_ASSERT(BNA_POWER_OF_2(q_ptr->q.q_depth));
+
+	BNA_TRACE(dev, cq_id);
+
+	cur_q_addr = *((struct bna_dma_addr *) (qpt->kv_qpt_ptr));
+
+	/*
+	 * Fill out structure, to be subsequently written
+	 * to hardware
+	 */
+	cq_cfg.pg_tbl_addr_lo = qpt->hw_qpt_ptr.lsb;
+	cq_cfg.pg_tbl_addr_hi = qpt->hw_qpt_ptr.msb;
+	cq_cfg.cur_q_entry_lo = cur_q_addr.lsb;
+	cq_cfg.cur_q_entry_hi = cur_q_addr.msb;
+
+	cq_cfg.pg_cnt_n_prd_ptr = (qpt->page_count << 16) | 0x0;
+	cq_cfg.entry_n_pg_size = ((BNA_CQ_ENTRY_SIZE >> 2) << 16) |
+		(qpt->page_size >> 2);
+	cq_cfg.int_blk_n_cns_ptr = ((((u8) cfg_ptr->ib_seg_index) << 24) |
+				    (((u8) cfg_ptr->ib_id) << 16) | 0x0);
+	cq_cfg.q_state = BNA_Q_IDLE_STATE;
+
+	/* Write the page number register */
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+				  HQM_CQ_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr, pg_num);
+	/* H/W write */
+	cq_mem = (struct bna_cq_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_CQ_RAM_BASE_OFFSET);
+	bna_mem_writew(&cq_mem[cq_id].pg_tbl_addr_lo,
+		       bna_os_htonl(cq_cfg.pg_tbl_addr_lo));
+	bna_mem_writew(&cq_mem[cq_id].pg_tbl_addr_hi,
+		       bna_os_htonl(cq_cfg.pg_tbl_addr_hi));
+	bna_mem_writew(&cq_mem[cq_id].cur_q_entry_lo,
+		       bna_os_htonl(cq_cfg.cur_q_entry_lo));
+	bna_mem_writew(&cq_mem[cq_id].cur_q_entry_hi,
+		       bna_os_htonl(cq_cfg.cur_q_entry_hi));
+
+	bna_mem_writew(&cq_mem[cq_id].pg_cnt_n_prd_ptr,
+		       cq_cfg.pg_cnt_n_prd_ptr);
+	bna_mem_writew(&cq_mem[cq_id].entry_n_pg_size, cq_cfg.entry_n_pg_size);
+	bna_mem_writew(&cq_mem[cq_id].int_blk_n_cns_ptr,
+		       cq_cfg.int_blk_n_cns_ptr);
+	bna_mem_writew(&cq_mem[cq_id].q_state, cq_cfg.q_state);
+
+	BNA_LOG_DEBUG(("CQ %u\n", cq_id));
+	BNA_LOG_DEBUG(("CQ pg_tbl_addr_lo 0x%x\n",
+		       bna_os_ntohl(cq_cfg.pg_tbl_addr_lo)));
+	BNA_LOG_DEBUG(("CQ cur_q_entry_lo 0x%x\n",
+		       bna_os_ntohl(cq_cfg.cur_q_entry_lo)));
+	BNA_LOG_DEBUG(("CQ pg_cnt_n_prd_ptr 0x%x\n", cq_cfg.pg_cnt_n_prd_ptr));
+	BNA_LOG_DEBUG(("CQ entry_n_pg_size 0x%x\n", cq_cfg.entry_n_pg_size));
+	BNA_LOG_DEBUG(("CQ int_blk_n_cns_ptr 0x%x\n",
+		       cq_cfg.int_blk_n_cns_ptr));
+	BNA_LOG_DEBUG(("CQ q_state 0x%x\n", cq_cfg.q_state));
+
+	q_ptr->q.producer_index = 0;
+	q_ptr->q.consumer_index = 0;
+
+}
+
+/*
+ * bna_ib_idx_reset()
+ *
+ *   For the specified IB, it clears the IB index
+ *
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return none
+ */
+void
+bna_ib_idx_reset(struct bna_dev_s *dev, const struct bna_ib_config *cfg_ptr)
+{
+	u32 i, pg_num, *ib_idx;
+
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+				  HQM_INDX_TBL_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, pg_num);
+
+	ib_idx = (u32 *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_INDX_TBL_RAM_BASE_OFFSET);
+	ib_idx += cfg_ptr->index_table_offset;
+	for (i = 0; i < cfg_ptr->seg_size; i++)
+		*ib_idx++ = 0;
+}
+
+/*
+ * bna_ib_config_set()
+ *
+ *   For IB "ib_id", it configures the Interrupt Block specified by "cfg_ptr".
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ * @param[in] ib_id   - interrupt-block ID
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+void
+bna_ib_config_set(struct bna_dev_s *dev, struct bna_ib *ib_ptr,
+		  unsigned int ib_id, const struct bna_ib_config *cfg_ptr)
+{
+	struct bna_ib_blk_mem ib_cfg, *ib_mem;
+	u32 pg_num;
+	struct bna_doorbell_qset *qset;
+
+	BNA_ASSERT(ib_id < BNA_IB_ID_MAX);
+
+	BNA_TRACE(dev, ib_id);
+
+	ib_cfg.host_addr_lo = (u32) (cfg_ptr->ib_seg_addr.lsb);
+	ib_cfg.host_addr_hi = (u32) (cfg_ptr->ib_seg_addr.msb);
+
+	ib_cfg.clsc_n_ctrl_n_msix = ((cfg_ptr->coalescing_timer << 16) |
+				     (cfg_ptr->control_flags << 8) 
+				     | (cfg_ptr->msix_vector));
+	ib_cfg.ipkt_n_ent_n_idxof =
+		((cfg_ptr->interpkt_timer & 0xf) << 16) | (cfg_ptr->
+							   seg_size << 8) |
+		(cfg_ptr->index_table_offset);
+	ib_cfg.ipkt_cnt_cfg_n_unacked = (cfg_ptr->interpkt_count << 24);
+
+	/* Write the page number register */
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+				  HQM_IB_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, pg_num);
+
+	ib_mem = (struct bna_ib_blk_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_IB_RAM_BASE_OFFSET);
+
+	bna_mem_writew(&ib_mem[ib_id].host_addr_lo,
+		       bna_os_htonl(ib_cfg.host_addr_lo));
+	bna_mem_writew(&ib_mem[ib_id].host_addr_hi,
+		       bna_os_htonl(ib_cfg.host_addr_hi));
+
+	bna_mem_writew(&ib_mem[ib_id].clsc_n_ctrl_n_msix,
+		       ib_cfg.clsc_n_ctrl_n_msix);
+	bna_mem_writew(&ib_mem[ib_id].ipkt_n_ent_n_idxof,
+		       ib_cfg.ipkt_n_ent_n_idxof);
+	bna_mem_writew(&ib_mem[ib_id].ipkt_cnt_cfg_n_unacked,
+		       ib_cfg.ipkt_cnt_cfg_n_unacked);
+
+	BNA_LOG_DEBUG(("IB %d: host addr 0x%x clsc_n_ctrl_n_msix 0x%x\n",
+		       ib_id, bna_os_htonl(ib_cfg.host_addr_lo),
+		       ib_cfg.clsc_n_ctrl_n_msix));
+	BNA_LOG_DEBUG(("	ipkt_n_ent_n_idxof 0x%x ipkt_cnt_cfg_n_unacked 0x%x\n", 
+			ib_cfg.ipkt_n_ent_n_idxof, ib_cfg.ipkt_cnt_cfg_n_unacked));
+
+	qset = (struct bna_doorbell_qset *)
+		BNA_GET_DOORBELL_BASE_ADDR(dev->bar0);
+	ib_ptr->doorbell_addr =
+		(&qset[ib_id >> 1].ib0[(ib_id & 0x1) * (0x20 >> 2)]);
+
+	ib_ptr->doorbell_ack =
+		BNA_DOORBELL_IB_INT_ACK(cfg_ptr->coalescing_timer, 0);
+
+	bna_ib_idx_reset(dev, cfg_ptr);
+}
+
+/*
+ * bna_ib_disable()
+ *
+ *   Disables the Interrupt Block "ib_id".
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ *
+ * @return None
+ */
+void
+bna_ib_disable(struct bna_dev_s *bna_dev, const struct bna_ib *ib_ptr)
+{
+	bna_reg_write(ib_ptr->doorbell_addr, BNA_DOORBELL_IB_INT_DISABLE);
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_trcmod.h linux-2.6.30.5-mod/drivers/net/bna/bna_trcmod.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna_trcmod.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_trcmod.h	2009-08-28 21:09:24.282823000 -0700
@@ -0,0 +1,43 @@
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
+ * See <> for copyright and licensing details.
+ */
+
+/**
+ *  bna_trcmod.h BNA CAL driver trace modules
+ */
+
+
+#ifndef __BNA_TRCMOD_H__
+#define __BNA_TRCMOD_H__
+
+/*
+ * !!! Only append to the enums defined here to avoid any versioning
+ * !!! needed between trace utility and driver version
+ */
+enum {
+	BNA_TRC_HAL_FN = 63,
+	BNA_TRC_HAL_IF = 62,
+	BNA_TRC_HAL_QUEUE = 61,
+	BNA_TRC_HAL_IOCTL = 60,
+};
+#endif /* __BNA_TRCMOD_H__ */
