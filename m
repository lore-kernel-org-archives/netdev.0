From: ggrundstrom@neteffect.com
Subject: [PATCH 11/14] nes: OpenFabrics kernel verbs
Date: Tue, 7 Aug 2007 20:19:27 -0500
Message-ID: <200708080119.l781JRc2004874@neteffect.com>
Cc: ewg@lists.openfabrics.org, ggrundstrom@neteffect.com,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75.neteffect.com ([204.57.75.75]:52181 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S934600AbXHHBZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:25:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OpenFabrics kernel verbs provider routines

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_verbs.c
--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_verbs.c	2007-08-06 20:09:05.000000000 -0500
@@ -0,0 +1,3605 @@
+/*
+ * Copyright (c) 2006 - 2007 NetEffect, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/random.h>
+#include <asm/byteorder.h>
+
+#include <rdma/ib_verbs.h>
+#include <rdma/iw_cm.h>
+#include <rdma/ib_user_verbs.h>
+
+#include "nes.h"
+
+atomic_t mod_qp_timouts;
+atomic_t qps_created;
+extern atomic_t cm_closes;
+atomic_t sw_qps_destroyed;
+
+extern int disable_mpa_crc;
+
+
+/**
+ * nes_alloc_mw
+ */
+static struct ib_mw *nes_alloc_mw(struct ib_pd *ibpd) {
+	unsigned long flags;
+	struct nes_pd *nespd = to_nespd(ibpd);
+	struct nes_vnic *nesvnic = to_nesvnic(ibpd->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_cqp_request *cqp_request;
+	struct nes_mr *nesmr;
+	struct ib_mw *ibmw;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	int ret;
+	u32 stag;
+	u32 stag_index = 0;
+	u32 next_stag_index = 0;
+	u32 driver_key = 0;
+	u8 stag_key = 0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	get_random_bytes(&next_stag_index, sizeof(next_stag_index));
+	stag_key = (u8)next_stag_index;
+
+	driver_key = 0;
+
+	next_stag_index >>= 8;
+	next_stag_index %= nesadapter->max_mr;
+
+	ret = nes_alloc_resource(nesadapter, nesadapter->allocated_mrs,
+			nesadapter->max_mr, &stag_index, &next_stag_index);
+	if (ret) {
+		return (ERR_PTR(ret));
+	}
+
+	nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
+	if (!nesmr) {
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		return (ERR_PTR(-ENOMEM));
+	}
+
+	stag = stag_index << 8;
+	stag |= driver_key;
+	stag += (u32)stag_key;
+
+	dprintk("%s: Registering STag 0x%08X, index = 0x%08X\n",
+			__FUNCTION__, stag, stag_index);
+
+	/* Register the region with the adapter */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		kfree(nesmr);
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		return (ERR_PTR(-ENOMEM));
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			cpu_to_le32( NES_CQP_ALLOCATE_STAG | NES_CQP_STAG_RIGHTS_REMOTE_READ |
+			NES_CQP_STAG_RIGHTS_REMOTE_WRITE | NES_CQP_STAG_VA_TO |
+			NES_CQP_STAG_REM_ACC_EN);
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX] =
+			cpu_to_le32(nespd->pd_id&0x00007fff);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] = cpu_to_le32(stag);
+
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_HIGH_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] = 0;
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT);
+	dprintk("%s: Register STag 0x%08X completed, wait_event_timeout ret = %u,"
+			" CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+			__FUNCTION__, stag, ret, cqp_request->major_code, cqp_request->minor_code);
+	if ((!ret) || (cqp_request->major_code)) {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+		kfree(nesmr);
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		if (!ret) {
+			return (ERR_PTR(-ETIME));
+		} else {
+			return (ERR_PTR(-ENOMEM));
+		}
+	} else {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+	}
+
+	nesmr->ibmw.rkey = stag;
+	nesmr->mode = IWNES_MEMREG_TYPE_MW;
+	ibmw = &nesmr->ibmw;
+	nesmr->pbl_4k = 0;
+	nesmr->pbls_used = 0;
+
+	return (ibmw);
+}
+
+
+/**
+ * nes_dealloc_mw
+ */
+static int nes_dealloc_mw(struct ib_mw *ibmw)
+{
+	struct nes_mr *nesmr = to_nesmw(ibmw);
+	struct nes_vnic *nesvnic = to_nesvnic(ibmw->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_cqp_request *cqp_request;
+	int err = 0;
+	unsigned long flags;
+	int ret;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	/* Deallocate the window with the adapter */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		return (-ENOMEM);
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] = NES_CQP_DEALLOCATE_STAG;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] = ibmw->rkey;
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("Waiting for deallocate STag 0x%08X to complete.\n", ibmw->rkey);
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT);
+	dprintk("Deallocate STag completed, wait_event_timeout ret = %u,"
+			" CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+			ret, cqp_request->major_code, cqp_request->minor_code);
+	if ((!ret) || (cqp_request->major_code)) {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+		if (!ret) {
+			err = -ETIME;
+		} else {
+			err = -EIO;
+		}
+	} else {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+	}
+
+	nes_free_resource(nesadapter, nesadapter->allocated_mrs,
+			(ibmw->rkey&0x0fffff00) >> 8);
+	kfree(nesmr);
+
+	return (err);
+}
+
+
+/**
+ * nes_bind_mw
+ */
+static int nes_bind_mw(struct ib_qp *ibqp, struct ib_mw *ibmw,
+		struct ib_mw_bind *ibmw_bind)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibqp->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	/* struct nes_mr *nesmr = to_nesmw(ibmw); */
+	struct nes_qp *nesqp = to_nesqp(ibqp);
+	struct nes_hw_qp_wqe *wqe;
+	unsigned long flags = 0;
+	u32 head;
+	u32 wqe_misc = 0;
+	u32 qsize;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	if (nesqp->ibqp_state > IB_QPS_RTS)
+		return (-EINVAL);
+
+		spin_lock_irqsave(&nesqp->lock, flags);
+
+	head = nesqp->hwqp.sq_head;
+	qsize = nesqp->hwqp.sq_tail;
+
+	/* Check for SQ overflow */
+	if (((head + (2 * qsize) - nesqp->hwqp.sq_tail) % qsize) == (qsize - 1)) {
+		return (-EINVAL);
+	}
+
+	wqe = &nesqp->hwqp.sq_vbase[head];
+	/* dprintk("%s:processing sq wqe at %p, head = %u.\n", __FUNCTION__, wqe, head); */
+	*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_SCRATCH_LOW_IDX]) = ibmw_bind->wr_id;
+	*((struct nes_qp **)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
+	wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX] |= head;
+	wqe_misc = NES_IWARP_SQ_OP_BIND;
+
+	wqe_misc |= NES_IWARP_SQ_WQE_LOCAL_FENCE;
+
+	if (ibmw_bind->send_flags & IB_SEND_SIGNALED)
+		wqe_misc |= NES_IWARP_SQ_WQE_SIGNALED_COMPL;
+
+	if (ibmw_bind->mw_access_flags & IB_ACCESS_REMOTE_WRITE) {
+		wqe_misc |= NES_CQP_STAG_RIGHTS_REMOTE_WRITE;
+	}
+	if (ibmw_bind->mw_access_flags & IB_ACCESS_REMOTE_READ) {
+		wqe_misc |= NES_CQP_STAG_RIGHTS_REMOTE_READ;
+	}
+
+	wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] = cpu_to_le32(wqe_misc);
+	wqe->wqe_words[NES_IWARP_SQ_BIND_WQE_MR_IDX] = cpu_to_le32(ibmw_bind->mr->lkey);
+	wqe->wqe_words[NES_IWARP_SQ_BIND_WQE_MW_IDX] = cpu_to_le32(ibmw->rkey);
+	wqe->wqe_words[NES_IWARP_SQ_BIND_WQE_LENGTH_LOW_IDX] =
+			cpu_to_le32(ibmw_bind->length);
+	wqe->wqe_words[NES_IWARP_SQ_BIND_WQE_LENGTH_HIGH_IDX] = 0;
+	*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_BIND_WQE_VA_FBO_LOW_IDX]) =
+			cpu_to_le64(ibmw_bind->addr);
+
+	head++;
+	if (head >= qsize)
+		head = 0;
+
+	nesqp->hwqp.sq_head = head;
+	barrier();
+
+	nes_write32(nesdev->regs + NES_WQE_ALLOC,
+			(1 << 24) | 0x00800000 | nesqp->hwqp.qp_id);
+
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+
+	return (0);
+}
+
+
+/**
+ * nes_alloc_fmr
+ */
+static struct ib_fmr *nes_alloc_fmr(struct ib_pd *ibpd, int ibmr_access_flags,
+		struct ib_fmr_attr *ibfmr_attr)
+{
+	unsigned long flags;
+	struct nes_pd *nespd = to_nespd(ibpd);
+	struct nes_vnic *nesvnic = to_nesvnic(ibpd->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_mr *nesmr;
+	struct nes_cqp_request *cqp_request;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	int ret;
+	u32 stag;
+	u32 stag_index = 0;
+	u32 next_stag_index = 0;
+	u32 driver_key = 0;
+	u8 stag_key = 0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	get_random_bytes(&next_stag_index, sizeof(next_stag_index));
+	stag_key = (u8)next_stag_index;
+
+	driver_key = 0;
+
+	next_stag_index >>= 8;
+	next_stag_index %= nesadapter->max_mr;
+
+	ret = nes_alloc_resource(nesadapter, nesadapter->allocated_mrs,
+			nesadapter->max_mr, &stag_index, &next_stag_index);
+	if (ret) {
+		return (ERR_PTR(ret));
+	}
+
+	nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
+	if (!nesmr) {
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		return (ERR_PTR(-ENOMEM));
+	}
+
+	nesmr->mode = IWNES_MEMREG_TYPE_FMR;
+	if (ibfmr_attr->max_pages == 1) {
+		/* use zero length PBL */
+		nesmr->pbl_4k = 0;
+		nesmr->pbls_used = 0;
+	} else if (ibfmr_attr->max_pages <= 32) {
+		/* use PBL 256 */
+		nesmr->pbl_4k = 0;
+		nesmr->pbls_used = 1;
+	} else if (ibfmr_attr->max_pages <= 512) {
+		/* use 4K PBLs */
+		nesmr->pbl_4k = 1;
+		nesmr->pbls_used = 1;
+	} else {
+		/* use two level 4K PBLs */
+		/* add support for two level 256B PBLs */
+		nesmr->pbl_4k = 1;
+		nesmr->pbls_used = 1 + (ibfmr_attr->max_pages >> 9) +
+				((ibfmr_attr->max_pages & 511) ? 1:0);
+	}
+	/* Register the region with the adapter */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+
+	/* track PBL resources */
+	if (nesmr->pbls_used != 0) {
+		if (nesmr->pbl_4k) {
+			if (nesmr->pbls_used > nesadapter->free_4kpbl) {
+				kfree(nesmr);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+				return (ERR_PTR(-ENOMEM));
+			} else {
+				nesadapter->free_4kpbl -= nesmr->pbls_used;
+			}
+		} else {
+			if (nesmr->pbls_used > nesadapter->free_256pbl) {
+				kfree(nesmr);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+				return (ERR_PTR(-ENOMEM));
+			} else {
+				nesadapter->free_256pbl -= nesmr->pbls_used;
+			}
+		}
+	}
+
+	stag = stag_index << 8;
+	stag |= driver_key;
+	stag += (u32)stag_key;
+
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		kfree(nesmr);
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		return (ERR_PTR(-ENOMEM));
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	dprintk("%s: Registering STag 0x%08X, index = 0x%08X\n",
+			__FUNCTION__, stag, stag_index);
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			cpu_to_le32(NES_CQP_ALLOCATE_STAG | NES_CQP_STAG_RIGHTS_REMOTE_READ |
+			NES_CQP_STAG_RIGHTS_REMOTE_WRITE | NES_CQP_STAG_VA_TO |
+			NES_CQP_STAG_REM_ACC_EN | NES_CQP_STAG_MR |
+			(nesmr->pbl_4k == 1) ? NES_CQP_STAG_PBL_BLK_SIZE : 0);
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX] =
+			cpu_to_le32(nespd->pd_id & 0x00007fff);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] = cpu_to_le32(stag);
+
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_HIGH_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] =
+			cpu_to_le32((nesmr->pbls_used > 1) ?
+			(nesmr->pbls_used-1) : nesmr->pbls_used);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] = 0;
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT);
+	dprintk("%s: Register STag 0x%08X completed, wait_event_timeout ret = %u,"
+			" CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+			__FUNCTION__, stag, ret, cqp_request->major_code, cqp_request->minor_code);
+
+	if ((!ret) || (cqp_request->major_code)) {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+		kfree(nesmr);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		if (!ret) {
+			return (ERR_PTR(-ETIME));
+		} else {
+			return (ERR_PTR(-EIO));
+		}
+	} else {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+	}
+
+	nesmr->ibfmr.lkey = stag;
+	nesmr->ibfmr.rkey = stag;
+
+	return (&nesmr->ibfmr);
+}
+
+
+/**
+ * nes_dealloc_fmr
+ */
+static int nes_dealloc_fmr(struct ib_fmr *ibfmr)
+{
+	struct nes_mr *nesmr = to_nesfmr(ibfmr);
+	struct nes_mr temp_nesmr = *nesmr;
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	temp_nesmr.ibmw.device = ibfmr->device;
+	temp_nesmr.ibmw.pd = ibfmr->pd;
+	temp_nesmr.ibmw.rkey = ibfmr->rkey;
+	temp_nesmr.ibmw.uobject = NULL;
+
+	return (nes_dealloc_mw(&temp_nesmr.ibmw));
+}
+
+
+/**
+ * nes_map_phys_fmr
+ */
+static int nes_map_phys_fmr(struct ib_fmr *ibfmr, u64 *page_list,
+		int list_len, u64 iova)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (0);
+}
+
+
+/**
+ * nes_unmap_frm
+ */
+static int nes_unmap_fmr(struct list_head *ibfmr_list)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (0);
+}
+
+
+/**
+ * nes_query_device
+ */
+static int nes_query_device(struct ib_device *ibdev, struct ib_device_attr *props)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_ib_device *nesibdev = nesvnic->nesibdev;
+
+	/* dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__); */
+
+	memset(props, 0, sizeof(*props));
+	memcpy(&props->sys_image_guid, nesvnic->netdev->dev_addr, 6);
+
+	props->fw_ver = nesdev->nesadapter->fw_ver;
+	props->device_cap_flags = nesdev->nesadapter->device_cap_flags;
+	props->vendor_id = nesdev->nesadapter->vendor_id;
+	props->vendor_part_id = nesdev->nesadapter->vendor_part_id;
+	props->hw_ver = nesdev->nesadapter->hw_rev;
+	props->max_mr_size = 0x80000000;
+	props->max_qp = nesibdev->max_qp;
+	props->max_qp_wr = nesdev->nesadapter->max_qp_wr - 2;
+	props->max_sge = nesdev->nesadapter->max_sge;
+	props->max_cq = nesibdev->max_cq;
+	props->max_cqe = nesdev->nesadapter->max_cqe - 1;
+	props->max_mr = nesibdev->max_mr;
+	props->max_mw = nesibdev->max_mr;
+	props->max_pd = nesibdev->max_pd;
+	props->max_sge_rd = 1;
+	switch (nesdev->nesadapter->max_irrq_wr) {
+		case 0:
+			props->max_qp_rd_atom = 1;
+			break;
+		case 1:
+			props->max_qp_rd_atom = 4;
+			break;
+		case 2:
+			props->max_qp_rd_atom = 16;
+			break;
+		case 3:
+			props->max_qp_rd_atom = 32;
+			break;
+		default:
+			props->max_qp_rd_atom = 0;
+	}
+	props->max_qp_init_rd_atom = props->max_qp_wr;
+	props->atomic_cap = IB_ATOMIC_NONE;
+
+	return (0);
+}
+
+
+/**
+ * nes_query_port
+ */
+static int nes_query_port(struct ib_device *ibdev, u8 port, struct ib_port_attr *props)
+{
+	/* dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__); */
+
+	memset(props, 0, sizeof(*props));
+
+	props->max_mtu = IB_MTU_2048;
+	props->active_mtu = IB_MTU_2048;
+	props->lid = 1;
+	props->lmc = 0;
+	props->sm_lid = 0;
+	props->sm_sl = 0;
+	props->state = IB_PORT_ACTIVE;
+	props->phys_state = 0;
+	props->port_cap_flags = IB_PORT_CM_SUP | IB_PORT_REINIT_SUP |
+			IB_PORT_VENDOR_CLASS_SUP | IB_PORT_BOOT_MGMT_SUP;
+	props->gid_tbl_len = 1;
+	props->pkey_tbl_len = 1;
+	props->qkey_viol_cntr = 0;
+	props->active_width = IB_WIDTH_4X;
+	props->active_speed = 1;
+	props->max_msg_sz = 0x80000000;
+
+	return (0);
+}
+
+
+/**
+ * nes_modify_port
+ */
+static int nes_modify_port(struct ib_device *ibdev, u8 port,
+		int port_modify_mask, struct ib_port_modify *props)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (0);
+}
+
+
+/**
+ * nes_query_pkey
+ */
+static int nes_query_pkey(struct ib_device *ibdev, u8 port, u16 index, u16 * pkey)
+{
+	/* dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__); */
+	*pkey = 0;
+	return (0);
+}
+
+
+/**
+ * nes_query_gid
+ */
+static int nes_query_gid(struct ib_device *ibdev, u8 port,
+		int index, union ib_gid *gid)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibdev);
+
+	/* dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__); */
+	memset(&(gid->raw[0]), 0, sizeof(gid->raw));
+	memcpy(&(gid->raw[0]), nesvnic->netdev->dev_addr, 6);
+
+	return (0);
+}
+
+
+/**
+ * nes_alloc_ucontext - Allocate the user context data structure. This keeps track
+ * of all objects associated with a particular user-mode client.
+ */
+static struct ib_ucontext *nes_alloc_ucontext(struct ib_device *ibdev,
+		struct ib_udata *udata)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_alloc_ucontext_resp uresp;
+	struct nes_ucontext *nes_ucontext;
+	struct nes_ib_device *nesibdev = nesvnic->nesibdev;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	memset(&uresp, 0, sizeof uresp);
+
+	uresp.max_qps = nesibdev->max_qp;
+	uresp.max_pds = nesibdev->max_pd;
+	uresp.wq_size = nesdev->nesadapter->max_qp_wr*2;
+
+	nes_ucontext = kmalloc(sizeof *nes_ucontext, GFP_KERNEL);
+	if (!nes_ucontext)
+		return (ERR_PTR(-ENOMEM));
+
+	memset(nes_ucontext, 0, sizeof(struct nes_ucontext));
+
+	nes_ucontext->nesdev = nesdev;
+	nes_ucontext->mmap_wq_offset = ((uresp.max_pds * 4096) + PAGE_SIZE-1) / PAGE_SIZE;
+	nes_ucontext->mmap_cq_offset = nes_ucontext->mmap_wq_offset +
+			((sizeof(struct nes_hw_qp_wqe) * uresp.max_qps * 2) + PAGE_SIZE-1) /
+			PAGE_SIZE;
+
+	if (ib_copy_to_udata(udata, &uresp, sizeof uresp)) {
+		kfree(nes_ucontext);
+		return (ERR_PTR(-EFAULT));
+	}
+
+	INIT_LIST_HEAD(&nes_ucontext->cq_reg_mem_list);
+	return(&nes_ucontext->ibucontext);
+}
+
+
+/**
+ * nes_dealloc_ucontext
+ */
+static int nes_dealloc_ucontext(struct ib_ucontext *context)
+{
+	/* struct nes_vnic *nesvnic = to_nesvnic(context->device); */
+	/* struct nes_device *nesdev = nesvnic->nesdev; */
+	struct nes_ucontext *nes_ucontext = to_nesucontext(context);
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	kfree(nes_ucontext);
+	return (0);
+}
+
+
+/**
+ * nes_mmap
+ */
+static int nes_mmap(struct ib_ucontext *context, struct vm_area_struct *vma)
+{
+	unsigned long index;
+	struct nes_vnic *nesvnic = to_nesvnic(context->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	/* struct nes_adapter *nesadapter = nesdev->nesadapter; */
+	struct nes_ucontext *nes_ucontext;
+	struct nes_qp *nesqp;
+
+	nes_ucontext = to_nesucontext(context);
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	if (vma->vm_pgoff >= nes_ucontext->mmap_wq_offset) {
+		index = (vma->vm_pgoff - nes_ucontext->mmap_wq_offset) * PAGE_SIZE;
+		index /= ((sizeof(struct nes_hw_qp_wqe) * nesdev->nesadapter->max_qp_wr * 2) +
+				  PAGE_SIZE-1) & (~(PAGE_SIZE-1));
+		if (!test_bit(index, nes_ucontext->allocated_wqs)) {
+			dprintk("%s: wq %lu not allocated\n", __FUNCTION__, index);
+			return (-EFAULT);
+		}
+		nesqp = nes_ucontext->mmap_nesqp[index];
+		if (NULL == nesqp) {
+			dprintk("%s: wq %lu has a NULL QP base.\n", __FUNCTION__, index);
+			return (-EFAULT);
+		}
+		if (remap_pfn_range(vma, vma->vm_start,
+				nesqp->hwqp.sq_pbase >> PAGE_SHIFT,
+				vma->vm_end - vma->vm_start,	
+				vma->vm_page_prot)) {
+			dprintk("%s: remap_pfn_range failed.\n", __FUNCTION__);
+			return(-EAGAIN);
+		}
+		vma->vm_private_data = nesqp;
+		return (0);
+	} else {
+		index = vma->vm_pgoff;
+		if (!test_bit(index, nes_ucontext->allocated_doorbells))
+			return(-EFAULT);
+
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		if (io_remap_pfn_range(vma, vma->vm_start,
+				(nesdev->doorbell_start +
+				((nes_ucontext->mmap_db_index[index]-nesdev->base_doorbell_index) * 4096))
+				>> PAGE_SHIFT, PAGE_SIZE, vma->vm_page_prot))
+			return(-EAGAIN);
+		vma->vm_private_data = nes_ucontext;
+		return (0);
+	}
+
+	return(-ENOSYS);
+}
+
+
+/**
+ * nes_alloc_pd
+ */
+static struct ib_pd *nes_alloc_pd(struct ib_device *ibdev,
+		struct ib_ucontext *context, struct ib_udata *udata)
+{
+	struct nes_pd *nespd;
+	struct nes_vnic *nesvnic = to_nesvnic(ibdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_ucontext *nesucontext;
+	struct nes_alloc_pd_resp uresp;
+	u32 pd_num = 0;
+	int err;
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
+			atomic_read(&nesvnic->netdev->refcnt));
+
+	err = nes_alloc_resource(nesadapter, nesadapter->allocated_pds,
+			nesadapter->max_pd, &pd_num, &nesadapter->next_pd);
+	if (err) {
+		return (ERR_PTR(err));
+	}
+
+	nespd = kmalloc(sizeof (struct nes_pd), GFP_KERNEL);
+	if (!nespd) {
+		nes_free_resource(nesadapter, nesadapter->allocated_pds, pd_num);
+		return (ERR_PTR(-ENOMEM));
+	}
+	memset(nespd, 0, sizeof(struct nes_pd));
+	dprintk("Allocating PD (%p) for ib device %s\n",
+			nespd, nesvnic->nesibdev->ibdev.name);
+
+	nespd->pd_id = pd_num + nesadapter->base_pd;
+
+	if (context) {
+		nesucontext = to_nesucontext(context);
+		nespd->mmap_db_index = find_next_zero_bit(nesucontext->allocated_doorbells,
+				NES_MAX_USER_DB_REGIONS, nesucontext->first_free_db);
+		dprintk("find_first_zero_biton doorbells returned %u, mapping pd_id %u.\n",
+				nespd->mmap_db_index, nespd->pd_id);
+		if (nespd->mmap_db_index > NES_MAX_USER_DB_REGIONS) {
+			dprintk("%s:%u: mmap_db_index > MAX\n", __FUNCTION__, __LINE__);
+			nes_free_resource(nesadapter, nesadapter->allocated_pds, pd_num);
+			kfree(nespd);
+			return (ERR_PTR(-ENOMEM));
+		}
+
+		uresp.pd_id = nespd->pd_id;
+		uresp.mmap_db_index = nespd->mmap_db_index;
+		if (ib_copy_to_udata(udata, &uresp, sizeof (struct nes_alloc_pd_resp))) {
+			nes_free_resource(nesadapter, nesadapter->allocated_pds, pd_num);
+			kfree(nespd);
+			return (ERR_PTR(-EFAULT));
+		}
+
+		set_bit(nespd->mmap_db_index, nesucontext->allocated_doorbells);
+		nesucontext->mmap_db_index[nespd->mmap_db_index] = nespd->pd_id;
+		nesucontext->first_free_db = nespd->mmap_db_index + 1;
+	}
+
+	dprintk("%s: PD%u structure located @%p.\n",
+			__FUNCTION__, nespd->pd_id,  nespd);
+	dprintk("%s: netdev refcnt = %u.\n",
+			__FUNCTION__, atomic_read(&nesvnic->netdev->refcnt));
+	return(&nespd->ibpd);
+}
+
+
+/**
+ * nes_dealloc_pd
+ */
+static int nes_dealloc_pd(struct ib_pd *ibpd)
+{
+	struct nes_ucontext *nesucontext;
+	struct nes_pd *nespd = to_nespd(ibpd);
+	struct nes_vnic *nesvnic = to_nesvnic(ibpd->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+
+	if ((ibpd->uobject) && (ibpd->uobject->context)) {
+		nesucontext = to_nesucontext(ibpd->uobject->context);
+		dprintk("%s: Clearing bit %u from allocated doorbells\n",
+				__FUNCTION__, nespd->mmap_db_index);
+		clear_bit(nespd->mmap_db_index, nesucontext->allocated_doorbells);
+		nesucontext->mmap_db_index[nespd->mmap_db_index] = 0;
+		if (nesucontext->first_free_db > nespd->mmap_db_index) {
+			nesucontext->first_free_db = nespd->mmap_db_index;
+		}
+	}
+
+	dprintk("%s: Deallocating PD%u structure located @%p.\n",
+			__FUNCTION__, nespd->pd_id,  nespd);
+	nes_free_resource(nesadapter, nesadapter->allocated_pds,
+			nespd->pd_id-nesadapter->base_pd);
+	kfree(nespd);
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	/* dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
+			atomic_read(&nesvnic->netdev->refcnt)); */
+	return (0);
+}
+
+
+/**
+ * nes_create_ah
+ */
+static struct ib_ah *nes_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (ERR_PTR(-ENOSYS));
+}
+
+
+/**
+ * nes_destroy_ah
+ */
+static int nes_destroy_ah(struct ib_ah *ah)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (-ENOSYS);
+}
+
+
+/**
+ * nes_create_qp
+ */
+static struct ib_qp *nes_create_qp(struct ib_pd *ibpd,
+		struct ib_qp_init_attr *init_attr, struct ib_udata *udata)
+{
+	u64 u64temp= 0;
+	u64 u64nesqp = 0;
+	struct nes_pd *nespd = to_nespd(ibpd);
+	struct nes_vnic *nesvnic = to_nesvnic(ibpd->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_qp *nesqp;
+	struct nes_cq *nescq;
+	struct nes_ucontext *nes_ucontext;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_cqp_request *cqp_request;
+	struct nes_create_qp_resp uresp;
+	u32 qp_num = 0;
+	/* u32 counter = 0; */
+	void *mem;
+	unsigned long flags;
+	int ret;
+	int sq_size;
+	int rq_size;
+	u8 sq_encoded_size;
+	u8 rq_encoded_size;
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10))
+	u32 mem_size;
+	void *vmem;
+#endif
+	/* int counter; */
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
+			atomic_read(&nesvnic->netdev->refcnt));
+
+	atomic_inc(&qps_created);
+	switch (init_attr->qp_type) {
+		case IB_QPT_RC:
+			init_attr->cap.max_inline_data = 0;
+
+			if (init_attr->cap.max_send_wr < 32) {
+				sq_size = 32;
+				sq_encoded_size = 1;
+			} else if (init_attr->cap.max_send_wr < 128) {
+				sq_size = 128;
+				sq_encoded_size = 2;
+			} else if (init_attr->cap.max_send_wr < 512) {
+				sq_size = 512;
+				sq_encoded_size = 3;
+			} else {
+				printk(KERN_ERR PFX "%s: SQ size (%u) too large.\n",
+						__FUNCTION__, init_attr->cap.max_send_wr);
+				return (ERR_PTR(-EINVAL));
+			}
+			init_attr->cap.max_send_wr = sq_size - 2;
+			if (init_attr->cap.max_recv_wr < 32) {
+				rq_size = 32;
+				rq_encoded_size = 1;
+			} else if (init_attr->cap.max_recv_wr < 128) {
+				rq_size = 128;
+				rq_encoded_size = 2;
+			} else if (init_attr->cap.max_recv_wr < 512) {
+				rq_size = 512;
+				rq_encoded_size = 3;
+			} else {
+				printk(KERN_ERR PFX "%s: RQ size (%u) too large.\n",
+						__FUNCTION__, init_attr->cap.max_recv_wr);
+				return (ERR_PTR(-EINVAL));
+			}
+			init_attr->cap.max_recv_wr = rq_size -1;
+			dprintk("%s: RQ size = %u, SQ Size = %u.\n", __FUNCTION__,
+					rq_size, sq_size);
+
+			ret = nes_alloc_resource(nesadapter, nesadapter->allocated_qps,
+					nesadapter->max_qp, &qp_num, &nesadapter->next_qp);
+			if (ret) {
+				return (ERR_PTR(ret));
+			}
+
+			/* Need 512 (actually now 1024) byte alignment on this structure */
+			mem = kzalloc(sizeof(*nesqp)+NES_SW_CONTEXT_ALIGN-1, GFP_KERNEL);
+			if (!mem) {
+				nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+				dprintk("%s: Unable to allocate QP\n", __FUNCTION__);
+				return (ERR_PTR(-ENOMEM));
+			}
+			u64nesqp = (u64)mem;   /* u64nesqp = (u64)((uint)mem); */
+			u64nesqp += ((u64)NES_SW_CONTEXT_ALIGN) - 1;
+			u64temp = ((u64)NES_SW_CONTEXT_ALIGN) - 1;
+			u64nesqp &= ~u64temp;
+			nesqp = (struct nes_qp *)u64nesqp;
+			dprintk("nesqp = %p, allocated buffer = %p.  Rounded to closest %u\n",
+					nesqp, mem, NES_SW_CONTEXT_ALIGN);
+			nesqp->allocated_buffer = mem;
+
+			if (udata) {
+				if ((ibpd->uobject) && (ibpd->uobject->context)) {
+					nesqp->user_mode = 1;
+					nes_ucontext = to_nesucontext(ibpd->uobject->context);
+					nesqp->mmap_sq_db_index =
+							find_next_zero_bit(nes_ucontext->allocated_wqs,
+							NES_MAX_USER_WQ_REGIONS, nes_ucontext->first_free_wq);
+					dprintk("find_first_zero_biton wqs returned %u\n",
+							nespd->mmap_db_index);
+					if (nesqp->mmap_sq_db_index > NES_MAX_USER_WQ_REGIONS) {
+						dprintk("%s: db index > max user regions, failing create QP\n",
+								__FUNCTION__);
+						nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+						kfree(nesqp->allocated_buffer);
+						return (ERR_PTR(-ENOMEM));
+					}
+					set_bit(nesqp->mmap_sq_db_index, nes_ucontext->allocated_wqs);
+					nes_ucontext->mmap_nesqp[nesqp->mmap_sq_db_index] = nesqp;
+					nes_ucontext->first_free_wq = nesqp->mmap_sq_db_index + 1;
+				} else {
+					nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+					kfree(nesqp->allocated_buffer);
+					return (ERR_PTR(-EFAULT));
+				}
+			}
+
+			nesqp->qp_mem_size = (sizeof(struct nes_hw_qp_wqe) * sq_size) +
+					(sizeof(struct nes_hw_qp_wqe) * rq_size) +
+					max((u32)sizeof(struct nes_qp_context), ((u32)256))  +
+					256;	/* this is Q2 */
+			/* Round up to a multiple of a page */
+			nesqp->qp_mem_size += PAGE_SIZE - 1;
+			nesqp->qp_mem_size &= ~(PAGE_SIZE - 1);
+
+			mem = pci_alloc_consistent(nesdev->pcidev, nesqp->qp_mem_size,
+					&nesqp->hwqp.sq_pbase);
+			if (!mem) {
+				nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+				dprintk("%s: Unable to allocate memory for host descriptor rings\n",
+						__FUNCTION__);
+				kfree(nesqp->allocated_buffer);
+				return (ERR_PTR(-ENOMEM));
+			}
+			dprintk(PFX "%s: PCI consistent memory for "
+					"host descriptor rings located @ %p (pa = 0x%08lX.) size = %u.\n",
+					__FUNCTION__, mem, (unsigned long)nesqp->hwqp.sq_pbase,
+					nesqp->qp_mem_size);
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10))
+			mem_size = nesqp->qp_mem_size;
+			vmem = mem;
+			while (mem_size > 0) {
+				dprintk("%s: Setting memory page %p reserved, mem_size=%u\n",
+						__FUNCTION__, vmem, mem_size);
+				SetPageReserved(virt_to_page(vmem));
+				mem_size -= PAGE_SIZE;
+				vmem += PAGE_SIZE;
+			}
+#endif
+
+			memset(mem, 0, nesqp->qp_mem_size);
+
+			nesqp->hwqp.sq_vbase = mem;
+			nesqp->hwqp.sq_size = sq_size;
+			nesqp->hwqp.sq_encoded_size = sq_encoded_size;
+			nesqp->hwqp.sq_head = 1;
+			mem += sizeof(struct nes_hw_qp_wqe) * sq_size;
+
+			nesqp->hwqp.rq_vbase = mem;
+			nesqp->hwqp.rq_size = rq_size;
+			nesqp->hwqp.rq_encoded_size = rq_encoded_size;
+			nesqp->hwqp.rq_pbase = nesqp->hwqp.sq_pbase +
+					sizeof(struct nes_hw_qp_wqe) * sq_size;
+			mem += sizeof(struct nes_hw_qp_wqe)*rq_size;
+
+			nesqp->hwqp.q2_vbase = mem;
+			nesqp->hwqp.q2_pbase = nesqp->hwqp.rq_pbase +
+					sizeof(struct nes_hw_qp_wqe) * rq_size;
+			mem += 256;
+			memset(nesqp->hwqp.q2_vbase, 0, 256);
+
+			nesqp->nesqp_context = mem;
+			nesqp->nesqp_context_pbase = nesqp->hwqp.q2_pbase + 256;
+			memset(nesqp->nesqp_context, 0, sizeof(*nesqp->nesqp_context));
+
+			dprintk("%s:%u: nesqp->nesqp_context_pbase = %p\n",
+					__FUNCTION__, __LINE__, (void *) nesqp->nesqp_context_pbase);
+
+			nesqp->hwqp.qp_id = qp_num;
+			nesqp->ibqp.qp_num = nesqp->hwqp.qp_id;
+			nesqp->nespd = nespd;
+
+			nescq = to_nescq(init_attr->send_cq);
+			nesqp->nesscq = nescq;
+			nescq = to_nescq(init_attr->recv_cq);
+			nesqp->nesrcq = nescq;
+
+			nesqp->nesqp_context->misc |= (u32)PCI_FUNC(nesdev->pcidev->devfn) <<
+					NES_QPCONTEXT_MISC_PCI_FCN_SHIFT;
+			nesqp->nesqp_context->misc |= (u32)nesqp->hwqp.rq_encoded_size <<
+					NES_QPCONTEXT_MISC_RQ_SIZE_SHIFT;
+			nesqp->nesqp_context->misc |= (u32)nesqp->hwqp.sq_encoded_size <<
+					NES_QPCONTEXT_MISC_SQ_SIZE_SHIFT;
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_PRIV_EN;
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_FAST_REGISTER_EN;
+			nesqp->nesqp_context->cqs = nesqp->nesscq->hw_cq.cq_number +
+					((u32)nesqp->nesrcq->hw_cq.cq_number << 16);
+			u64temp = (u64)nesqp->hwqp.sq_pbase;
+			nesqp->nesqp_context->sq_addr_low = (u32)u64temp;
+			nesqp->nesqp_context->sq_addr_high = (u32)(u64temp >> 32);
+			u64temp = (u64)nesqp->hwqp.rq_pbase;
+			nesqp->nesqp_context->rq_addr_low = (u32)u64temp;
+			nesqp->nesqp_context->rq_addr_high = (u32)(u64temp >> 32);
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			dprintk("%s: next_qp_nic_index=%u, using nic_index=%d\n",
+					__FUNCTION__, nesvnic->next_qp_nic_index,
+					nesvnic->qp_nic_index[nesvnic->next_qp_nic_index]);
+			nesqp->nesqp_context->misc2 |=
+					(u32)nesvnic->qp_nic_index[nesvnic->next_qp_nic_index] <<
+					NES_QPCONTEXT_MISC2_NIC_INDEX_SHIFT;
+			nesvnic->next_qp_nic_index++;
+			if ((nesvnic->next_qp_nic_index > 3) ||
+					(nesvnic->qp_nic_index[nesvnic->next_qp_nic_index] == 0xf)) {
+				nesvnic->next_qp_nic_index = 0;
+			}
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+
+			nesqp->nesqp_context->pd_index_wscale |= (u32)nesqp->nespd->pd_id << 16;
+			u64temp = (u64)nesqp->hwqp.q2_pbase;
+			nesqp->nesqp_context->q2_addr_low = (u32)u64temp;
+			nesqp->nesqp_context->q2_addr_high = (u32)(u64temp>>32);
+			*((struct nes_qp **)&nesqp->nesqp_context->aeq_token_low) = nesqp;
+			nesqp->nesqp_context->ird_ord_sizes = NES_QPCONTEXT_ORDIRD_ALSMM |
+					((((u32)nesadapter->max_irrq_wr) <<
+					NES_QPCONTEXT_ORDIRD_IRDSIZE_SHIFT) & NES_QPCONTEXT_ORDIRD_IRDSIZE_MASK);
+			if (disable_mpa_crc) {
+				dprintk("%s Disabling MPA crc checking due to module option.\n", __FUNCTION__);
+				nesqp->nesqp_context->ird_ord_sizes |= NES_QPCONTEXT_ORDIRD_RNMC;
+			}
+
+
+			/* Create the QP */
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+			if (NULL == cqp_request) {
+				dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+				pci_free_consistent(nesdev->pcidev, nesqp->qp_mem_size,
+						nesqp->hwqp.sq_vbase, nesqp->hwqp.sq_pbase);
+				kfree(nesqp->allocated_buffer);
+				return (ERR_PTR(-ENOMEM));
+			}
+			cqp_request->waiting = 1;
+			cqp_wqe = &cqp_request->cqp_wqe;
+
+			cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+					NES_CQP_CREATE_QP | NES_CQP_QP_TYPE_IWARP |
+					NES_CQP_QP_IWARP_STATE_IDLE;
+			cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |= NES_CQP_QP_CQS_VALID;
+			cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] = nesqp->hwqp.qp_id;
+			cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+			*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+					&nesdev->cqp;
+			cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+			cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+			u64temp = (u64)nesqp->nesqp_context_pbase;
+			cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_LOW_IDX] = (u32)u64temp;
+			cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_HIGH_IDX] = (u32)(u64temp >> 32);
+
+			atomic_set(&cqp_request->refcount, 2);
+			nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+					NES_CQP_REQUEST_RING_DOORBELL);
+
+			/* Wait for CQP */
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+			/* dprintk("Waiting for create iWARP QP%u to complete.\n",
+					nesqp->hwqp.qp_id); */
+			ret = wait_event_timeout(cqp_request->waitq,
+					(0 != cqp_request->request_done), NES_EVENT_TIMEOUT);
+			dprintk("Create iwarp QP completed, wait_event_timeout ret=%u,"
+					" nesdev->cqp_head = %u, nesdev->cqp.sq_tail = %u,"
+					" CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+					ret, nesdev->cqp.sq_head, nesdev->cqp.sq_tail,
+					cqp_request->major_code, cqp_request->minor_code);
+			if ((!ret) || (cqp_request->major_code)) {
+				if (atomic_dec_and_test(&cqp_request->refcount)) {
+					spin_lock_irqsave(&nesdev->cqp.lock, flags);
+					list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+					spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				}
+				nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+				pci_free_consistent(nesdev->pcidev, nesqp->qp_mem_size,
+						nesqp->hwqp.sq_vbase, nesqp->hwqp.sq_pbase);
+				kfree(nesqp->allocated_buffer);
+				if (!ret) {
+					return (ERR_PTR(-ETIME));
+				} else {
+					return (ERR_PTR(-EIO));
+				}
+			} else {
+				if (atomic_dec_and_test(&cqp_request->refcount)) {
+					spin_lock_irqsave(&nesdev->cqp.lock, flags);
+					list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+					spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				}
+			}
+
+			if (ibpd->uobject) {
+				uresp.mmap_sq_db_index = nesqp->mmap_sq_db_index;
+				uresp.actual_sq_size = sq_size;
+				uresp.actual_rq_size = rq_size;
+				uresp.qp_id = nesqp->hwqp.qp_id;
+				if (ib_copy_to_udata(udata, &uresp, sizeof uresp)) {
+					pci_free_consistent(nesdev->pcidev, nesqp->qp_mem_size,
+							nesqp->hwqp.sq_vbase, nesqp->hwqp.sq_pbase);
+					nes_free_resource(nesadapter, nesadapter->allocated_qps, qp_num);
+					kfree(nesqp->allocated_buffer);
+					return (ERR_PTR(-EFAULT));
+				}
+			}
+
+			dprintk("%s: QP%u structure located @%p.Size = %u.\n",
+					__FUNCTION__, nesqp->hwqp.qp_id,  nesqp, (u32)sizeof(*nesqp));
+			spin_lock_init(&nesqp->lock);
+			init_waitqueue_head(&nesqp->state_waitq);
+			init_waitqueue_head(&nesqp->kick_waitq);
+			nes_add_ref(&nesqp->ibqp);
+			break;
+		default:
+			dprintk("%s: Invalid QP type: %d\n", __FUNCTION__, init_attr->qp_type);
+			return (ERR_PTR(-EINVAL));
+			break;
+	}
+
+	/* update the QP table */
+	nesdev->nesadapter->qp_table[nesqp->hwqp.qp_id-NES_FIRST_QPN] = nesqp;
+	dprintk("%s: netdev refcnt = %u.\n",
+			__FUNCTION__, atomic_read(&nesvnic->netdev->refcnt));
+
+	return (&nesqp->ibqp);
+}
+
+
+/**
+ * nes_destroy_qp
+ */
+static int nes_destroy_qp(struct ib_qp *ibqp)
+{
+	struct nes_qp *nesqp = to_nesqp(ibqp);
+	/* struct nes_vnic *nesvnic = to_nesvnic(ibqp->device); */
+	struct nes_ucontext *nes_ucontext;
+	struct ib_qp_attr attr;
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10))
+	u32 mem_size;
+	void *vmem;
+#endif
+	struct iw_cm_id *cm_id;
+	struct iw_cm_event cm_event;
+	int ret;
+
+	dprintk("%s:%u: Destroying QP%u, qp reference count = %d\n",
+			__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, atomic_read(&nesqp->refcount));
+
+	atomic_inc(&sw_qps_destroyed);
+	/* Blow away the connection if it exists. */
+	if (((nesqp->ibqp_state == IB_QPS_INIT) ||
+		 (nesqp->ibqp_state == IB_QPS_RTR)) && (nesqp->cm_id)) {
+		cm_id = nesqp->cm_id;
+		cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
+		cm_event.status = IW_CM_EVENT_STATUS_TIMEOUT;
+		cm_event.local_addr = cm_id->local_addr;
+		cm_event.remote_addr = cm_id->remote_addr;
+		cm_event.private_data = NULL;
+		cm_event.private_data_len = 0;
+
+		dprintk("%s: Generating a CM Timeout Event for "
+				" QP%u. cm_id = %p, refcount = %u. \n",
+				__FUNCTION__, nesqp->hwqp.qp_id,
+				cm_id, atomic_read(&nesqp->refcount));
+
+		cm_id->rem_ref(cm_id);
+		ret = cm_id->event_handler(cm_id, &cm_event);
+		if (ret)
+			dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+					__FUNCTION__, __LINE__, ret);
+	}
+
+	if (nesqp->ibqp_state == IB_QPS_RTS) {
+		attr.qp_state = IB_QPS_ERR;
+		nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE, NULL);
+	}
+
+	if (nesqp->user_mode) {
+		if ((ibqp->uobject)&&(ibqp->uobject->context)) {
+			nes_ucontext = to_nesucontext(ibqp->uobject->context);
+			clear_bit(nesqp->mmap_sq_db_index, nes_ucontext->allocated_wqs);
+			nes_ucontext->mmap_nesqp[nesqp->mmap_sq_db_index] = NULL;
+			if (nes_ucontext->first_free_wq > nesqp->mmap_sq_db_index) {
+				nes_ucontext->first_free_wq = nesqp->mmap_sq_db_index;
+			}
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10))
+			mem_size = nesqp->qp_mem_size;
+			vmem = nesqp->hwqp.sq_vbase;
+			while (mem_size > 0) {
+				dprintk("%s: Remove reserved memory page %p, mem_size=%u\n",
+						__FUNCTION__, vmem, mem_size);
+				ClearPageReserved(virt_to_page(vmem));
+				mem_size -= PAGE_SIZE;
+				vmem += PAGE_SIZE;
+			}
+#endif
+		}
+	}
+
+	nes_rem_ref(&nesqp->ibqp);
+	/* dprintk("%s: netdev refcnt = %u.\n",
+			__FUNCTION__, atomic_read(&nesvnic->netdev->refcnt)); */
+	dprintk("%s:%u: QP%u, leaving\n", __FUNCTION__, __LINE__, nesqp->hwqp.qp_id);
+	return (0);
+}
+
+
+/**
+ * nes_create_cq
+ */
+static struct ib_cq *nes_create_cq(struct ib_device *ibdev, int entries,
+		struct ib_ucontext *context, struct ib_udata *udata)
+{
+	u64 u64temp;
+	struct nes_vnic *nesvnic = to_nesvnic(ibdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_cq *nescq;
+	struct nes_ucontext *nes_ucontext = NULL;
+	struct nes_cqp_request *cqp_request;
+	void *mem = NULL;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_pbl *nespbl = NULL;
+	struct nes_create_cq_req req;
+	struct nes_create_cq_resp resp;
+	u32 cq_num = 0;
+	u32 pbl_entries = 1;
+	int err;
+	unsigned long flags;
+	int ret;
+
+	dprintk("%s:%u: entries = %u\n", __FUNCTION__, __LINE__, entries);
+	/* dprintk("%s: netdev refcnt = %u.\n",
+			__FUNCTION__, atomic_read(&nesvnic->netdev->refcnt)); */
+
+	err = nes_alloc_resource(nesadapter, nesadapter->allocated_cqs,
+			nesadapter->max_cq, &cq_num, &nesadapter->next_cq);
+	if (err) {
+		return (ERR_PTR(err));
+	}
+
+	nescq = kmalloc(sizeof(struct nes_cq), GFP_KERNEL);
+	if (!nescq) {
+		nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+		dprintk("%s: Unable to allocate CQ\n", __FUNCTION__);
+		return (ERR_PTR(-ENOMEM));
+	}
+	memset(nescq, 0, sizeof (struct nes_cq));
+
+	nescq->hw_cq.cq_size = max(entries + 1, 5);
+	nescq->hw_cq.cq_number = cq_num;
+	nescq->ibcq.cqe = nescq->hw_cq.cq_size - 1;
+
+	if (context) {
+		nes_ucontext = to_nesucontext(context);
+		if (ib_copy_from_udata(&req, udata, sizeof (struct nes_create_cq_req))) {
+			nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+			kfree(nescq);
+			return (ERR_PTR(-EFAULT));
+		}
+		dprintk("%s: CQ Virtual Address = %08lX, size = %u.\n",
+				__FUNCTION__, (unsigned long)req.user_cq_buffer, entries);
+		list_for_each_entry(nespbl, &nes_ucontext->cq_reg_mem_list, list) {
+			if (nespbl->user_base == (unsigned long )req.user_cq_buffer) {
+				list_del(&nespbl->list);
+				err = 0;
+				dprintk("%s: Found PBL for virtual CQ. nespbl=%p.\n",
+						__FUNCTION__, nespbl);
+				break;
+			}
+		}
+		if (err) {
+			nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+			kfree(nescq);
+			return (ERR_PTR(err));
+		}
+		pbl_entries = nespbl->pbl_size >> 3;
+		nescq->cq_mem_size = 0;
+		dprintk("%s: Userspace PBL, pbl_size=%u, pbl_vbase=%p, pbl_pbase=%p\n",
+				__FUNCTION__, nespbl->pbl_size, (void *)nespbl->pbl_vbase,
+				(void *)nespbl->pbl_pbase);
+		dprintk("%s:     pbl_entries=%u, cq_mem_size=%u\n",
+				__FUNCTION__, pbl_entries, nescq->cq_mem_size);
+	} else {
+		nescq->cq_mem_size = nescq->hw_cq.cq_size * sizeof(struct nes_hw_cqe);
+		dprintk("%s: Attempting to allocate pci memory (%u entries, %u bytes) for CQ%u.\n",
+				__FUNCTION__, entries, nescq->cq_mem_size, nescq->hw_cq.cq_number);
+
+		/* allocate the physical buffer space */
+		mem = pci_alloc_consistent(nesdev->pcidev, nescq->cq_mem_size,
+				&nescq->hw_cq.cq_pbase);
+		if (!mem) {
+			dprintk(KERN_ERR PFX "Unable to allocate pci memory for cq\n");
+			nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+			kfree(nescq);
+			return (ERR_PTR(-ENOMEM));
+		}
+
+		memset(mem, 0, nescq->cq_mem_size);
+		nescq->hw_cq.cq_vbase = mem;
+		nescq->hw_cq.cq_head = 0;
+		dprintk("%s: CQ%u virtual address @ %p, phys = 0x%08X\n",
+				__FUNCTION__, nescq->hw_cq.cq_number, nescq->hw_cq.cq_vbase,
+				(u32)nescq->hw_cq.cq_pbase);
+	}
+
+	nescq->hw_cq.ce_handler = nes_iwarp_ce_handler;
+	spin_lock_init(&nescq->lock);
+
+	/* send CreateCQ request to CQP */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		if (!context)
+			pci_free_consistent(nesdev->pcidev, nescq->cq_mem_size, mem,
+					nescq->hw_cq.cq_pbase);
+		nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+		kfree(nescq);
+		return (ERR_PTR(-ENOMEM));
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			NES_CQP_CREATE_CQ | NES_CQP_CQ_CEQ_VALID |
+			NES_CQP_CQ_CHK_OVERFLOW |
+			NES_CQP_CQ_CEQE_MASK |((u32)nescq->hw_cq.cq_size << 16);
+	if (1 != pbl_entries) {
+		if (pbl_entries > 32) {
+			/* use 4k pbl */
+			dprintk("%s: pbl_entries=%u, use a 4k PBL\n", __FUNCTION__, pbl_entries);
+			if (0 == nesadapter->free_4kpbl) {
+				list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				if (!context)
+					pci_free_consistent(nesdev->pcidev, nescq->cq_mem_size, mem,
+							nescq->hw_cq.cq_pbase);
+				nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+				kfree(nescq);
+				return (ERR_PTR(-ENOMEM));
+			} else {
+				cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
+						(NES_CQP_CQ_VIRT | NES_CQP_CQ_4KB_CHUNK);
+				nescq->virtual_cq = 2;
+				nesadapter->free_4kpbl--;
+			}
+		} else {
+			/* use 256 byte pbl */
+			dprintk("%s: pbl_entries=%u, use a 256 byte PBL\n",
+					__FUNCTION__, pbl_entries);
+			if (0 == nesadapter->free_256pbl) {
+				list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				if (!context)
+					pci_free_consistent(nesdev->pcidev, nescq->cq_mem_size, mem,
+							nescq->hw_cq.cq_pbase);
+				nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+				kfree(nescq);
+				return (ERR_PTR(-ENOMEM));
+			} else {
+				cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |= NES_CQP_CQ_VIRT;
+				nescq->virtual_cq = 1;
+				nesadapter->free_256pbl--;
+			}
+		}
+	}
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
+			cpu_to_le32(nescq->hw_cq.cq_number | ((u32)nesdev->ceq_index << 16));
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	if (context) {
+		if (1 != pbl_entries)
+			u64temp = (u64)nespbl->pbl_pbase;
+		else
+			u64temp	= nespbl->pbl_vbase[0];
+		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] =
+				cpu_to_le32(nes_ucontext->mmap_db_index[0]);
+	} else {
+		u64temp = (u64)nescq->hw_cq.cq_pbase;
+		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] = 0;
+	}
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_LOW_IDX] = cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_HIGH_IDX] = cpu_to_le32((u32)(u64temp >> 32));
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX] = 0;
+	*((struct nes_hw_cq **)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]) =
+			&nescq->hw_cq;
+	*((u64 *)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]) >>= 1;
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("Waiting for create iWARP CQ%u to complete.\n", nescq->hw_cq.cq_number);
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT * 2);
+	dprintk("Create iWARP CQ%u completed, wait_event_timeout ret = %d.\n",
+			nescq->hw_cq.cq_number, ret);
+	if ((!ret) || (cqp_request->major_code)) {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+		dprintk("iWARP CQ%u create timeout expired, major code = 0x%04X,"
+				" minor code = 0x%04X\n",
+				nescq->hw_cq.cq_number, cqp_request->major_code, cqp_request->minor_code);
+		if (!context)
+			pci_free_consistent(nesdev->pcidev, nescq->cq_mem_size, mem,
+					nescq->hw_cq.cq_pbase);
+		nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+		kfree(nescq);
+		return (ERR_PTR(-EIO));
+	} else {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+	}
+
+	if (context) {
+		/* free the nespbl */
+		pci_free_consistent(nesdev->pcidev, nespbl->pbl_size, nespbl->pbl_vbase,
+				nespbl->pbl_pbase);
+		kfree(nespbl);
+		resp.cq_id = nescq->hw_cq.cq_number;
+		resp.cq_size = nescq->hw_cq.cq_size;
+		resp.mmap_db_index = 0;
+		if (ib_copy_to_udata(udata, &resp, sizeof resp)) {
+			nes_free_resource(nesadapter, nesadapter->allocated_cqs, cq_num);
+			kfree(nescq);
+			return (ERR_PTR(-EFAULT));
+		}
+	}
+
+	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
+			atomic_read(&nesvnic->netdev->refcnt));
+	return(&nescq->ibcq);
+}
+
+
+/**
+ * nes_destroy_cq
+ */
+static int nes_destroy_cq(struct ib_cq *ib_cq)
+{
+	struct nes_cq *nescq;
+	struct nes_device *nesdev;
+	struct nes_vnic *nesvnic;
+	struct nes_adapter *nesadapter;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_cqp_request *cqp_request;
+	unsigned long flags;
+	int ret;
+
+	dprintk("%s:%u: %p.\n", __FUNCTION__, __LINE__, ib_cq);
+
+	if (ib_cq == NULL)
+		return (0);
+
+	nescq = to_nescq(ib_cq);
+	nesvnic = to_nesvnic(ib_cq->device);
+	nesdev = nesvnic->nesdev;
+	nesadapter = nesdev->nesadapter;
+	/* dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
+			atomic_read(&nesvnic->netdev->refcnt)); */
+
+	dprintk("%s:%u: Destroy CQ%u\n",
+			__FUNCTION__, __LINE__, nescq->hw_cq.cq_number);
+
+	/* Send DestroyCQ request to CQP */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		return (-ENOMEM);
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			NES_CQP_DESTROY_CQ | (nescq->hw_cq.cq_size << 16);
+
+	if (nescq->virtual_cq == 1) {
+		nesadapter->free_256pbl++;
+		if (nesadapter->free_256pbl > nesadapter->max_256pbl) {
+			printk(KERN_ERR PFX "%s: free 256B PBLs(%u) has exceeded the max(%u)\n",
+					__FUNCTION__, nesadapter->free_256pbl, nesadapter->max_256pbl);
+		}
+	} else if (nescq->virtual_cq == 2) {
+		nesadapter->free_4kpbl++;
+		if (nesadapter->free_4kpbl > nesadapter->max_4kpbl) {
+			printk(KERN_ERR PFX "%s: free 4K PBLs(%u) has exceeded the max(%u)\n",
+					__FUNCTION__, nesadapter->free_4kpbl, nesadapter->max_4kpbl);
+		}
+		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |= NES_CQP_CQ_4KB_CHUNK;
+	}
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
+			nescq->hw_cq.cq_number | ((u32)PCI_FUNC(nesdev->pcidev->devfn) << 16);
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("Waiting for destroy iWARP CQ%u to complete.\n",
+			nescq->hw_cq.cq_number);
+	/* cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1); */
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT);
+	dprintk("Destroy iWARP CQ%u completed, wait_event_timeout ret = %u,"
+			" CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+			nescq->hw_cq.cq_number, ret, cqp_request->major_code,
+			cqp_request->minor_code);
+	if ((!ret) || (cqp_request->major_code)) {
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+		if (!ret) {
+			dprintk("iWARP CQ%u destroy timeout expired\n", nescq->hw_cq.cq_number);
+			ret = -ETIME;
+		} else {
+			dprintk("iWARP CQ%u destroy failed\n", nescq->hw_cq.cq_number);
+			ret = -EIO;
+		}
+	} else {
+		ret = 0;
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+	}
+
+	if (nescq->cq_mem_size)
+		pci_free_consistent(nesdev->pcidev, nescq->cq_mem_size,
+				(void *)nescq->hw_cq.cq_vbase, nescq->hw_cq.cq_pbase);
+	nes_free_resource(nesadapter, nesadapter->allocated_cqs, nescq->hw_cq.cq_number);
+	kfree(nescq);
+
+	/* dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
+			atomic_read(&nesvnic->netdev->refcnt)); */
+	return (ret);
+}
+
+
+/**
+ * nes_reg_mr
+ */
+static int nes_reg_mr(struct nes_device *nesdev, struct nes_pd *nespd,
+		u32 stag, u64 region_length, struct nes_root_vpbl *root_vpbl,
+		dma_addr_t single_buffer, u16 pbl_count, u16 residual_page_count,
+		int acc, u64 *iova_start)
+{
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_cqp_request *cqp_request;
+	unsigned long flags;
+	int ret;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	/* int count; */
+	u16 major_code;
+
+	/* Register the region with the adapter */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		return (-ENOMEM);
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	/* track PBL resources */
+	if (pbl_count != 0) {
+		if (pbl_count > 1) {
+			/* Two level PBL */
+			if ((pbl_count+1) > nesadapter->free_4kpbl) {
+				dprintk("%s: Out of 4KB Pbls for two level request.\n",
+						__FUNCTION__);
+				list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				return(-ENOMEM);
+			} else {
+				nesadapter->free_4kpbl -= pbl_count+1;
+			}
+		} else if (residual_page_count > 32) {
+			if (pbl_count > nesadapter->free_4kpbl) {
+				dprintk("%s: Out of 4KB Pbls.\n", __FUNCTION__);
+				list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				return (-ENOMEM);
+			} else {
+				nesadapter->free_4kpbl -= pbl_count;
+			}
+		} else {
+			if (pbl_count > nesadapter->free_256pbl) {
+				dprintk("%s: Out of 256B Pbls.\n", __FUNCTION__);
+				list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+				spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+				return (-ENOMEM);
+			} else {
+				nesadapter->free_256pbl -= pbl_count;
+			}
+		}
+	}
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			NES_CQP_REGISTER_STAG | NES_CQP_STAG_RIGHTS_LOCAL_READ;
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
+			NES_CQP_STAG_VA_TO | NES_CQP_STAG_MR;
+	if (acc & IB_ACCESS_LOCAL_WRITE) {
+		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |= NES_CQP_STAG_RIGHTS_LOCAL_WRITE;
+	}
+	if (acc & IB_ACCESS_REMOTE_WRITE) {
+		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
+				NES_CQP_STAG_RIGHTS_REMOTE_WRITE | NES_CQP_STAG_REM_ACC_EN;
+	}
+	if (acc & IB_ACCESS_REMOTE_READ) {
+		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
+				NES_CQP_STAG_RIGHTS_REMOTE_READ | NES_CQP_STAG_REM_ACC_EN;
+	}
+	if (acc & IB_ACCESS_MW_BIND) {
+		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
+				NES_CQP_STAG_RIGHTS_WINDOW_BIND | NES_CQP_STAG_REM_ACC_EN;
+	}
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_VA_LOW_IDX] = cpu_to_le32((u32)*iova_start);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_VA_HIGH_IDX] =
+			cpu_to_le32((u32)((((u64)*iova_start) >> 32)));
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_LOW_IDX] = cpu_to_le32((u32)region_length);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX] =
+			cpu_to_le32((u32)(region_length >> 8) & 0xff000000);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX] |=
+			cpu_to_le32(nespd->pd_id & 0x00007fff);
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] = cpu_to_le32(stag);
+
+	if (pbl_count == 0) {
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_LOW_IDX] =
+				cpu_to_le32((u32)single_buffer);
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_HIGH_IDX] =
+				cpu_to_le32((u32)((((u64)single_buffer) >> 32)));
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] = 0;
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] = 0;
+	} else {
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_LOW_IDX] =
+				cpu_to_le32((u32)root_vpbl->pbl_pbase);
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_HIGH_IDX] =
+				cpu_to_le32((u32)((((u64)root_vpbl->pbl_pbase) >> 32)));
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] = cpu_to_le32(pbl_count);
+		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] =
+				cpu_to_le32(((pbl_count-1) * 4096) + (residual_page_count*8));
+		if ((pbl_count > 1) || (residual_page_count > 32)) {
+			cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=  NES_CQP_STAG_PBL_BLK_SIZE;
+		}
+	}
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]);
+
+	barrier();
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT);
+	dprintk("%s: Register STag 0x%08X completed, wait_event_timeout ret = %u,"
+			" CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+			__FUNCTION__, stag, ret, cqp_request->major_code, cqp_request->minor_code);
+	major_code = cqp_request->major_code;
+	if (atomic_dec_and_test(&cqp_request->refcount)) {
+		spin_lock_irqsave(&nesdev->cqp.lock, flags);
+		list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	}
+	if (!ret)
+		return(-ETIME);
+	else if (major_code)
+		return(-EIO);
+	else
+		return (0);
+
+	return (0);
+}
+
+
+/**
+ * nes_reg_phys_mr
+ */
+static struct ib_mr *nes_reg_phys_mr(struct ib_pd *ib_pd,
+		struct ib_phys_buf *buffer_list, int num_phys_buf, int acc,
+		u64 * iova_start)
+{
+	u64 region_length;
+	struct nes_pd *nespd = to_nespd(ib_pd);
+	struct nes_vnic *nesvnic = to_nesvnic(ib_pd->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_mr *nesmr;
+	struct ib_mr *ibmr;
+	struct nes_vpbl vpbl;
+	struct nes_root_vpbl root_vpbl;
+	u32 stag;
+	u32 i;
+	u32 stag_index = 0;
+	u32 next_stag_index = 0;
+	u32 driver_key = 0;
+	u32 root_pbl_index = 0;
+	u32 cur_pbl_index = 0;
+	int err = 0, pbl_depth = 0;
+	int ret = 0;
+	u16 pbl_count = 0;
+	u8 single_page = 1;
+	u8 stag_key = 0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	pbl_depth = 0;
+	region_length = 0;
+	vpbl.pbl_vbase = NULL;
+	root_vpbl.pbl_vbase = NULL;
+	root_vpbl.pbl_pbase = 0;
+
+	get_random_bytes(&next_stag_index, sizeof(next_stag_index));
+	stag_key = (u8)next_stag_index;
+
+	driver_key = 0;
+
+	next_stag_index >>= 8;
+	next_stag_index %= nesadapter->max_mr;
+	if (num_phys_buf > (1024*512)) {
+		return (ERR_PTR(-E2BIG));
+	}
+
+	err = nes_alloc_resource(nesadapter, nesadapter->allocated_mrs, nesadapter->max_mr,
+			&stag_index, &next_stag_index);
+	if (err) {
+		return (ERR_PTR(err));
+	}
+
+	nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
+	if (!nesmr) {
+		nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+		return (ERR_PTR(-ENOMEM));
+	}
+
+	for (i = 0; i < num_phys_buf; i++) {
+
+		if ((i & 0x01FF) == 0) {
+			if (1 == root_pbl_index) {
+				/* Allocate the root PBL */
+				root_vpbl.pbl_vbase = pci_alloc_consistent(nesdev->pcidev, 8192,
+						&root_vpbl.pbl_pbase);
+				dprintk("%s: Allocating root PBL, va = %p, pa = 0x%08X\n",
+						__FUNCTION__, root_vpbl.pbl_vbase,
+						(unsigned int)root_vpbl.pbl_pbase);
+				if (!root_vpbl.pbl_vbase) {
+					pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
+							vpbl.pbl_pbase);
+					nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+					kfree(nesmr);
+					return (ERR_PTR(-ENOMEM));
+				}
+				root_vpbl.leaf_vpbl = kmalloc(sizeof(*root_vpbl.leaf_vpbl)*1024, GFP_KERNEL);
+				if (!root_vpbl.leaf_vpbl) {
+					pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
+							root_vpbl.pbl_pbase);
+					pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
+							vpbl.pbl_pbase);
+					nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+					kfree(nesmr);
+					return (ERR_PTR(-ENOMEM));
+				}
+				root_vpbl.pbl_vbase[0].pa_low = cpu_to_le32((u32)vpbl.pbl_pbase);
+				root_vpbl.pbl_vbase[0].pa_high =
+						cpu_to_le32((u32)((((u64)vpbl.pbl_pbase) >> 32)));
+				root_vpbl.leaf_vpbl[0] = vpbl;
+			}
+			/* Allocate a 4K buffer for the PBL */
+			vpbl.pbl_vbase = pci_alloc_consistent(nesdev->pcidev, 4096,
+					&vpbl.pbl_pbase);
+			dprintk("%s: Allocating leaf PBL, va = %p, pa = 0x%016lX\n",
+					__FUNCTION__, vpbl.pbl_vbase, (unsigned long)vpbl.pbl_pbase);
+			if (!vpbl.pbl_vbase) {
+				nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+				ibmr = ERR_PTR(-ENOMEM);
+				kfree(nesmr);
+				goto reg_phys_err;
+			}
+			/* Fill in the root table */
+			if (1 <= root_pbl_index) {
+				root_vpbl.pbl_vbase[root_pbl_index].pa_low =
+						cpu_to_le32((u32)vpbl.pbl_pbase);
+				root_vpbl.pbl_vbase[root_pbl_index].pa_high =
+						cpu_to_le32((u32)((((u64)vpbl.pbl_pbase) >> 32)));
+				root_vpbl.leaf_vpbl[root_pbl_index] = vpbl;
+			}
+			root_pbl_index++;
+			cur_pbl_index = 0;
+		}
+		if (buffer_list[i].addr & ~PAGE_MASK) {
+			/* TODO: Unwind allocated buffers */
+			nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+			dprintk("Unaligned Memory Buffer: 0x%x\n",
+					(unsigned int) buffer_list[i].addr);
+			ibmr = ERR_PTR(-EINVAL);
+			kfree(nesmr);
+			goto reg_phys_err;
+		}
+
+		if (!buffer_list[i].size) {
+			nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+			dprintk("Invalid Buffer Size\n");
+			ibmr = ERR_PTR(-EINVAL);
+			kfree(nesmr);
+			goto reg_phys_err;
+		}
+
+		region_length += buffer_list[i].size;
+		if ((i != 0) && (single_page)) {
+			if ((buffer_list[i-1].addr+PAGE_SIZE) != buffer_list[i].addr)
+				single_page = 0;
+		}
+		vpbl.pbl_vbase[cur_pbl_index].pa_low = cpu_to_le32((u32)buffer_list[i].addr);
+		vpbl.pbl_vbase[cur_pbl_index++].pa_high =
+				cpu_to_le32((u32)((((u64)buffer_list[i].addr) >> 32)));
+	}
+
+	stag = stag_index << 8;
+	stag |= driver_key;
+	stag += (u32)stag_key;
+
+	dprintk("%s: Registering STag 0x%08X, VA = 0x%016lX,"
+			" length = 0x%016lX, index = 0x%08X\n",
+			__FUNCTION__, stag, (unsigned long)*iova_start,
+			(unsigned long)region_length, stag_index);
+
+	region_length -= (*iova_start)&PAGE_MASK;
+
+	/* Make the leaf PBL the root if only one PBL */
+	if (root_pbl_index == 1) {
+		root_vpbl.pbl_pbase = vpbl.pbl_pbase;
+	}
+
+	if (single_page) {
+		pbl_count = 0;
+	} else {
+		pbl_count = root_pbl_index;
+	}
+	ret = nes_reg_mr(nesdev, nespd, stag, region_length, &root_vpbl,
+			buffer_list[0].addr, pbl_count, (u16)cur_pbl_index, acc, iova_start);
+
+	if (ret == 0) {
+		nesmr->ibmr.rkey = stag;
+		nesmr->ibmr.lkey = stag;
+		nesmr->mode = IWNES_MEMREG_TYPE_MEM;
+		ibmr = &nesmr->ibmr;
+		nesmr->pbl_4k = ((pbl_count > 1) || (cur_pbl_index > 32)) ? 1 : 0;
+		nesmr->pbls_used = pbl_count;
+		if (pbl_count > 1) {
+			nesmr->pbls_used++;
+		}
+	} else {
+		kfree(nesmr);
+		ibmr = ERR_PTR(-ENOMEM);
+	}
+
+	reg_phys_err:
+	/* free the resources */
+	if (root_pbl_index == 1) {
+		/* single PBL case */
+		pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase, vpbl.pbl_pbase);
+	} else {
+		for (i=0; i<root_pbl_index; i++) {
+			pci_free_consistent(nesdev->pcidev, 4096, root_vpbl.leaf_vpbl[i].pbl_vbase,
+					root_vpbl.leaf_vpbl[i].pbl_pbase);
+		}
+		kfree(root_vpbl.leaf_vpbl);
+		pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
+				root_vpbl.pbl_pbase);
+	}
+
+	return (ibmr);
+}
+
+
+/**
+ * nes_get_dma_mr
+ */
+static struct ib_mr *nes_get_dma_mr(struct ib_pd *pd, int acc) {
+	struct ib_phys_buf bl;
+	u64 kva = 0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	bl.size = (u64)0xffffffffffULL;
+	bl.addr = 0;
+	return (nes_reg_phys_mr(pd, &bl, 1, acc, &kva));
+}
+
+
+/**
+ * nes_reg_user_mr
+ */
+static struct ib_mr *nes_reg_user_mr(struct ib_pd *pd, struct ib_umem *region,
+		int acc, struct ib_udata *udata)
+{
+	u64 iova_start;
+	u64 *pbl;
+	u64 region_length;
+	dma_addr_t last_dma_addr = 0;
+	dma_addr_t first_dma_addr = 0;
+	struct nes_pd *nespd = to_nespd(pd);
+	struct nes_vnic *nesvnic = to_nesvnic(pd->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct ib_mr *ibmr;
+	struct ib_umem_chunk *chunk;
+	struct nes_ucontext *nes_ucontext;
+	struct nes_pbl *nespbl;
+	struct nes_mr *nesmr;
+	struct nes_mem_reg_req req;
+	struct nes_vpbl vpbl;
+	struct nes_root_vpbl root_vpbl;
+	int j;
+	int page_count = 0;
+	int err, pbl_depth = 0;
+	int ret;
+	u32 stag;
+	u32 stag_index = 0;
+	u32 next_stag_index;
+	u32 driver_key;
+	u32 root_pbl_index = 0;
+	u32 cur_pbl_index = 0;
+	u16 pbl_count;
+	u8 single_page = 1;
+	u8 stag_key;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	dprintk("%s: User base = 0x%lX, Virt base = 0x%lX, length = %u,"
+			" offset = %u, page size = %u.\n",
+			__FUNCTION__, region->user_base, region->virt_base, (u32)region->length,
+			region->offset, region->page_size);
+
+	if (ib_copy_from_udata(&req, udata, sizeof(req)))
+		return (ERR_PTR(-EFAULT));
+	dprintk("%s: Memory Registration type = %08X.\n", __FUNCTION__, req.reg_type);
+
+	switch (req.reg_type) {
+		case IWNES_MEMREG_TYPE_MEM:
+			pbl_depth = 0;
+			region_length = 0;
+			vpbl.pbl_vbase = NULL;
+			root_vpbl.pbl_vbase = NULL;
+			root_vpbl.pbl_pbase = 0;
+
+			get_random_bytes(&next_stag_index, sizeof(next_stag_index));
+			stag_key = (u8)next_stag_index;
+
+			driver_key = 0;
+
+			next_stag_index >>= 8;
+			next_stag_index %= nesadapter->max_mr;
+
+			err = nes_alloc_resource(nesadapter, nesadapter->allocated_mrs,
+					nesadapter->max_mr, &stag_index, &next_stag_index);
+			if (err) {
+				return (ERR_PTR(err));
+			}
+
+			nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
+			if (!nesmr) {
+				nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+				return (ERR_PTR(-ENOMEM));
+			}
+
+			list_for_each_entry(chunk, &region->chunk_list, list) {
+				dprintk("%s: Chunk: nents = %u, nmap = %u .\n",
+						__FUNCTION__, chunk->nents, chunk->nmap);
+				for (j = 0; j < chunk->nmap; ++j) {
+					if ((page_count&0x01FF) == 0) {
+						if (page_count>(1024*512)) {
+							pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
+									vpbl.pbl_pbase);
+							nes_free_resource(nesadapter,
+									nesadapter->allocated_mrs, stag_index);
+							kfree(nesmr);
+							return (ERR_PTR(-E2BIG));
+						}
+						if (1 == root_pbl_index) {
+							root_vpbl.pbl_vbase = pci_alloc_consistent(nesdev->pcidev,
+									8192, &root_vpbl.pbl_pbase);
+							dprintk("%s: Allocating root PBL, va = %p, pa = 0x%08X\n",
+									__FUNCTION__, root_vpbl.pbl_vbase,
+									(unsigned int)root_vpbl.pbl_pbase);
+							if (!root_vpbl.pbl_vbase) {
+								pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
+										vpbl.pbl_pbase);
+								nes_free_resource(nesadapter, nesadapter->allocated_mrs,
+										stag_index);
+								kfree(nesmr);
+								return (ERR_PTR(-ENOMEM));
+							}
+							root_vpbl.leaf_vpbl = kmalloc(sizeof(*root_vpbl.leaf_vpbl)*1024,
+									GFP_KERNEL);
+							if (!root_vpbl.leaf_vpbl) {
+								pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
+										root_vpbl.pbl_pbase);
+								pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
+										vpbl.pbl_pbase);
+								nes_free_resource(nesadapter, nesadapter->allocated_mrs,
+										stag_index);
+								kfree(nesmr);
+								return (ERR_PTR(-ENOMEM));
+							}
+							root_vpbl.pbl_vbase[0].pa_low =
+									cpu_to_le32((u32)vpbl.pbl_pbase);
+							root_vpbl.pbl_vbase[0].pa_high =
+									cpu_to_le32((u32)((((u64)vpbl.pbl_pbase) >> 32)));
+							root_vpbl.leaf_vpbl[0] = vpbl;
+						}
+						vpbl.pbl_vbase = pci_alloc_consistent(nesdev->pcidev, 4096,
+								&vpbl.pbl_pbase);
+						dprintk("%s: Allocating leaf PBL, va = %p, pa = 0x%08X\n",
+								__FUNCTION__, vpbl.pbl_vbase, (unsigned int)vpbl.pbl_pbase);
+						if (!vpbl.pbl_vbase) {
+							nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+							ibmr = ERR_PTR(-ENOMEM);
+							kfree(nesmr);
+							goto reg_user_mr_err;
+						}
+						if (1 <= root_pbl_index) {
+							root_vpbl.pbl_vbase[root_pbl_index].pa_low =
+									cpu_to_le32((u32)vpbl.pbl_pbase);
+							root_vpbl.pbl_vbase[root_pbl_index].pa_high =
+									cpu_to_le32((u32)((((u64)vpbl.pbl_pbase)>>32)));
+							root_vpbl.leaf_vpbl[root_pbl_index] = vpbl;
+						}
+						root_pbl_index++;
+						cur_pbl_index = 0;
+					}
+					if (sg_dma_address(&chunk->page_list[j]) & ~PAGE_MASK) {
+						nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
+						dprintk("%s: Unaligned Memory Buffer: 0x%x\n", __FUNCTION__,
+								(unsigned int) sg_dma_address(&chunk->page_list[j]));
+						ibmr = ERR_PTR(-EINVAL);
+						kfree(nesmr);
+						goto reg_user_mr_err;
+					}
+
+					if (!sg_dma_len(&chunk->page_list[j])) {
+						nes_free_resource(nesadapter, nesadapter->allocated_mrs,
+								stag_index);
+						dprintk("%s: Invalid Buffer Size\n", __FUNCTION__);
+						ibmr = ERR_PTR(-EINVAL);
+						kfree(nesmr);
+						goto reg_user_mr_err;
+					}
+
+					region_length += sg_dma_len(&chunk->page_list[j]);
+					if (single_page) {
+						if (page_count != 0) {
+							if ((last_dma_addr+PAGE_SIZE) !=
+									sg_dma_address(&chunk->page_list[j]))
+								single_page = 0;
+							last_dma_addr = sg_dma_address(&chunk->page_list[j]);
+						} else {
+							first_dma_addr = sg_dma_address(&chunk->page_list[j]);
+							last_dma_addr = first_dma_addr;
+						}
+					}
+
+					vpbl.pbl_vbase[cur_pbl_index].pa_low =
+							cpu_to_le32((u32)sg_dma_address(&chunk->page_list[j]));
+					vpbl.pbl_vbase[cur_pbl_index].pa_high =
+							cpu_to_le32((u32)((((u64)sg_dma_address(&chunk->page_list[j]))>>32)));
+					cur_pbl_index++;
+					page_count++;
+				}
+			}
+
+			dprintk("%s[%u] calculating stag, stag_index=0x%08x, driver_key=0x%08x,"
+					" stag_key=0x%08x\n", __FUNCTION__, __LINE__,
+					stag_index, driver_key, stag_key);
+			stag = stag_index << 8;
+			stag |= driver_key;
+			stag += (u32)stag_key;
+			if (stag == 0) {
+				stag = 1;
+			}
+
+			iova_start = (u64)region->virt_base;
+			dprintk("%s: Registering STag 0x%08X, VA = 0x%08X, length = 0x%08X,"
+					" index = 0x%08X, region->length=0x%08llx\n",
+					__FUNCTION__, stag, (unsigned int)iova_start,
+					(unsigned int)region_length, stag_index,
+					(unsigned long long)region->length);
+
+			/* Make the leaf PBL the root if only one PBL */
+			if (root_pbl_index == 1) {
+				root_vpbl.pbl_pbase = vpbl.pbl_pbase;
+			}
+
+			if (single_page) {
+				pbl_count = 0;
+			} else {
+				pbl_count = root_pbl_index;
+				first_dma_addr = 0;
+			}
+			ret = nes_reg_mr( nesdev, nespd, stag, region->length, &root_vpbl,
+					first_dma_addr, pbl_count, (u16)cur_pbl_index, acc, &iova_start);
+
+			if (ret == 0) {
+				nesmr->ibmr.rkey = stag;
+				nesmr->ibmr.lkey = stag;
+				nesmr->mode = IWNES_MEMREG_TYPE_MEM;
+				ibmr = &nesmr->ibmr;
+				nesmr->pbl_4k = ((pbl_count > 1) || (cur_pbl_index > 32)) ? 1 : 0;
+				nesmr->pbls_used = pbl_count;
+				if (pbl_count > 1) {
+					nesmr->pbls_used++;
+				}
+			} else {
+				kfree(nesmr);
+				ibmr = ERR_PTR(-ENOMEM);
+			}
+
+			reg_user_mr_err:
+			/* free the resources */
+			if (root_pbl_index == 1) {
+				pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
+						vpbl.pbl_pbase);
+			} else {
+				for (j=0; j<root_pbl_index; j++) {
+					pci_free_consistent(nesdev->pcidev, 4096,
+							root_vpbl.leaf_vpbl[j].pbl_vbase,
+							root_vpbl.leaf_vpbl[j].pbl_pbase);
+				}
+				kfree(root_vpbl.leaf_vpbl);
+				pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
+						root_vpbl.pbl_pbase);
+			}
+
+			return (ibmr);
+			break;
+		case IWNES_MEMREG_TYPE_QP:
+			return (ERR_PTR(-ENOSYS));
+			break;
+		case IWNES_MEMREG_TYPE_CQ:
+			nespbl = kmalloc(sizeof(*nespbl), GFP_KERNEL);
+			if (!nespbl) {
+				dprintk("%s: Unable to allocate PBL\n", __FUNCTION__);
+				return (ERR_PTR(-ENOMEM));
+			}
+			memset(nespbl, 0, sizeof(*nespbl));
+			nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
+			if (!nesmr) {
+				kfree(nespbl);
+				dprintk("%s: Unable to allocate nesmr\n", __FUNCTION__);
+				return (ERR_PTR(-ENOMEM));
+			}
+			memset(nesmr, 0, sizeof(*nesmr));
+			nes_ucontext = to_nesucontext(pd->uobject->context);
+			pbl_depth = region->length >> PAGE_SHIFT;
+			pbl_depth += (region->length & ~PAGE_MASK) ? 1 : 0;
+			nespbl->pbl_size = pbl_depth*sizeof(u64);
+			dprintk("%s: Attempting to allocate CQ PBL memory, %u bytes, %u entries.\n",
+					__FUNCTION__, nespbl->pbl_size, pbl_depth);
+			pbl = pci_alloc_consistent(nesdev->pcidev, nespbl->pbl_size,
+					&nespbl->pbl_pbase);
+			if (!pbl) {
+				kfree(nesmr);
+				kfree(nespbl);
+				dprintk("%s: Unable to allocate cq PBL memory\n", __FUNCTION__);
+				return (ERR_PTR(-ENOMEM));
+			}
+
+			nespbl->pbl_vbase = pbl;
+			nespbl->user_base = region->user_base;
+			dprintk("%s: Allocated CQ PBL memory, %u bytes, pbl_pbase=%p,"
+					" pbl_vbase=%p user_base=0x%lx\n",
+					__FUNCTION__, nespbl->pbl_size, (void *)nespbl->pbl_pbase,
+					(void*)nespbl->pbl_vbase, nespbl->user_base);
+
+			list_for_each_entry(chunk, &region->chunk_list, list) {
+				for (j = 0; j < chunk->nmap; ++j) {
+					*pbl = cpu_to_le64((u64)sg_dma_address(&chunk->page_list[j]));
+					/* dprintk("%s: pbl=%p, *pbl=0x%016llx\n", __FUNCTION__, pbl, *pbl); */
+					pbl++;
+				}
+			}
+			list_add_tail(&nespbl->list, &nes_ucontext->cq_reg_mem_list);
+			nesmr->ibmr.rkey = -1;
+			nesmr->ibmr.lkey = -1;
+			nesmr->mode = IWNES_MEMREG_TYPE_CQ;
+			return (&nesmr->ibmr);
+			break;
+	}
+
+	return (ERR_PTR(-ENOSYS));
+}
+
+
+/**
+ * nes_dereg_mr
+ */
+static int nes_dereg_mr(struct ib_mr *ib_mr)
+{
+	struct nes_mr *nesmr = to_nesmr(ib_mr);
+	struct nes_vnic *nesvnic = to_nesvnic(ib_mr->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_cqp_request *cqp_request;
+	unsigned long flags;
+	int ret;
+	u16 major_code;
+	u16 minor_code;
+
+	dprintk("%s:%u ib_mr=%p, rkey = 0x%08X, lkey = 0x%08X, mode = %u\n",
+			__FUNCTION__, __LINE__, ib_mr, ib_mr->rkey, ib_mr->lkey, nesmr->mode);
+
+	if (nesmr->mode != IWNES_MEMREG_TYPE_MEM) {
+		kfree(nesmr);
+		return (0);
+	}
+
+	/* Deallocate the region with the adapter */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		return (-ENOMEM);
+	}
+	cqp_request->waiting = 1;
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	if (0 != nesmr->pbls_used) {
+		if (nesmr->pbl_4k) {
+			nesadapter->free_4kpbl += nesmr->pbls_used;
+			if (nesadapter->free_4kpbl > nesadapter->max_4kpbl) {
+				printk(KERN_ERR PFX "free 4KB PBLs(%u) has exceeded the max(%u)\n",
+					   nesadapter->free_4kpbl, nesadapter->max_4kpbl);
+			}
+		} else {
+			nesadapter->free_256pbl += nesmr->pbls_used;
+			if (nesadapter->free_256pbl > nesadapter->max_256pbl) {
+				printk(KERN_ERR PFX "free 256B PBLs(%u) has exceeded the max(%u)\n",
+					   nesadapter->free_256pbl, nesadapter->max_256pbl);
+			}
+		}
+	}
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			NES_CQP_DEALLOCATE_STAG | NES_CQP_STAG_VA_TO |
+			NES_CQP_STAG_DEALLOC_PBLS | NES_CQP_STAG_MR;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] = ib_mr->rkey;
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("%s: Waiting for deallocate STag 0x%08X completed\n",
+			__FUNCTION__, ib_mr->rkey);
+	ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+			NES_EVENT_TIMEOUT);
+	dprintk("%s: Deallocate STag 0x%08X completed, wait_event_timeout ret = %u,"
+			" CQP Major:Minor codes = 0x%04X:0x%04X\n",
+			__FUNCTION__, ib_mr->rkey, ret, cqp_request->major_code, cqp_request->minor_code);
+
+	nes_free_resource(nesadapter, nesadapter->allocated_mrs,
+			(ib_mr->rkey & 0x0fffff00) >> 8);
+
+	kfree(nesmr);
+
+	major_code = cqp_request->major_code;
+	minor_code = cqp_request->minor_code;
+	if (atomic_dec_and_test(&cqp_request->refcount)) {
+		spin_lock_irqsave(&nesdev->cqp.lock, flags);
+		list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	}
+	if (!ret) {
+		dprintk(KERN_ERR PFX "%s:%u Timeout waiting to destroy STag,"
+				" ib_mr=%p, rkey = 0x%08X\n",
+				__FUNCTION__, __LINE__, ib_mr, ib_mr->rkey);
+		return(-ETIME);
+	} else if (major_code) {
+		dprintk(KERN_ERR PFX "%s:%u Error (0x%04X:0x%04X) while attempting"
+				" to destroy STag, ib_mr=%p, rkey = 0x%08X\n",
+				__FUNCTION__, __LINE__, major_code, minor_code,
+				ib_mr, ib_mr->rkey);
+		return(-EIO);
+	} else
+		return (0);
+}
+
+
+/**
+ * show_rev
+ */
+static ssize_t show_rev(struct class_device *cdev, char *buf)
+{
+	struct nes_ib_device *nesibdev =
+			container_of(cdev, struct nes_ib_device, ibdev.class_dev);
+	struct nes_vnic *nesvnic = nesibdev->nesvnic;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (sprintf(buf, "%x\n", nesvnic->nesdev->nesadapter->hw_rev));
+}
+
+
+/**
+ * show_fw_ver
+ */
+static ssize_t show_fw_ver(struct class_device *cdev, char *buf)
+{
+	struct nes_ib_device *nesibdev =
+			container_of(cdev, struct nes_ib_device, ibdev.class_dev);
+	struct nes_vnic *nesvnic = nesibdev->nesvnic;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (sprintf(buf, "%x.%x.%x\n",
+			(int)(nesvnic->nesdev->nesadapter->fw_ver >> 32),
+			(int)(nesvnic->nesdev->nesadapter->fw_ver >> 16) & 0xffff,
+			(int)(nesvnic->nesdev->nesadapter->fw_ver & 0xffff)));
+}
+
+
+/**
+ * show_hca
+ */
+static ssize_t show_hca(struct class_device *cdev, char *buf)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (sprintf(buf, "NES020\n"));
+}
+
+
+/**
+ * show_board
+ */
+static ssize_t show_board(struct class_device *cdev, char *buf)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (sprintf(buf, "%.*s\n", 32, "NES020 Board ID"));
+}
+
+
+static CLASS_DEVICE_ATTR(hw_rev, S_IRUGO, show_rev, NULL);
+static CLASS_DEVICE_ATTR(fw_ver, S_IRUGO, show_fw_ver, NULL);
+static CLASS_DEVICE_ATTR(hca_type, S_IRUGO, show_hca, NULL);
+static CLASS_DEVICE_ATTR(board_id, S_IRUGO, show_board, NULL);
+
+static struct class_device_attribute *nes_class_attributes[] = {
+	&class_device_attr_hw_rev,
+	&class_device_attr_fw_ver,
+	&class_device_attr_hca_type,
+	&class_device_attr_board_id
+};
+
+
+/**
+ * nes_query_qp
+ */
+static int nes_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		int attr_mask, struct ib_qp_init_attr *init_attr)
+{
+	struct nes_qp *nesqp = to_nesqp(ibqp);
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+
+	attr->qp_access_flags = 0;
+	attr->cap.max_send_wr = nesqp->hwqp.sq_size;
+	attr->cap.max_recv_wr = nesqp->hwqp.rq_size;
+	attr->cap.max_recv_sge = 1;
+	attr->cap.max_inline_data = 0;	  /* 64?*/
+
+	init_attr->event_handler = nesqp->ibqp.event_handler;
+	init_attr->qp_context = nesqp->ibqp.qp_context;
+	init_attr->send_cq = nesqp->ibqp.send_cq;
+	init_attr->recv_cq = nesqp->ibqp.recv_cq;
+	init_attr->srq = nesqp->ibqp.srq = nesqp->ibqp.srq;
+	init_attr->cap = attr->cap;
+
+	dprintk("%s:%u Leaving\n", __FUNCTION__, __LINE__);
+
+	return (0);
+}
+
+
+/**
+ * nes_hw_modify_qp
+ */
+int nes_hw_modify_qp(struct nes_device *nesdev, struct nes_qp *nesqp, u32 next_iwarp_state, u32 wait_completion)
+{
+	u64 u64temp;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	/* struct iw_cm_id *cm_id = nesqp->cm_id; */
+	/* struct iw_cm_event cm_event; */
+	struct nes_cqp_request *cqp_request;
+	unsigned long flags;
+	int ret;
+	u16 major_code;
+
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+
+	dprintk("%s:%u: QP%u, refcount = %d\n",
+			__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, atomic_read(&nesqp->refcount));
+
+	cqp_request = nes_get_cqp_request(nesdev, NES_CQP_REQUEST_HOLDING_LOCK);
+	if (NULL == cqp_request) {
+		dprintk("%s: Failed to get a cqp_request.\n", __FUNCTION__);
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		return (-ENOMEM);
+	}
+	if (wait_completion) {
+		cqp_request->waiting = 1;
+	} else {
+		cqp_request->waiting = 0;
+	}
+	cqp_wqe = &cqp_request->cqp_wqe;
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
+			NES_CQP_MODIFY_QP | NES_CQP_QP_TYPE_IWARP | next_iwarp_state;
+	dprintk("%s:%u: using next_iwarp_state=%08x, wqe_words=%08x\n",
+			__FUNCTION__, __LINE__,
+			next_iwarp_state, cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]);
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] = nesqp->hwqp.qp_id;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =
+			&nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = 0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+	u64temp = (u64)nesqp->nesqp_context_pbase;
+	cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_LOW_IDX] = (u32)u64temp;
+	cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_HIGH_IDX] = (u32)(u64temp >> 32);
+
+
+
+	atomic_set(&cqp_request->refcount, 2);
+	nes_post_cqp_request(nesdev, cqp_request, NES_CQP_REQUEST_HOLDING_LOCK,
+			NES_CQP_REQUEST_RING_DOORBELL);
+
+	/* Wait for CQP */
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	if (wait_completion) {
+		/* dprintk("Waiting for modify iWARP QP%u to complete.\n", nesqp->hwqp.qp_id); */
+		ret = wait_event_timeout(cqp_request->waitq, (0 != cqp_request->request_done),
+				NES_EVENT_TIMEOUT);
+		dprintk("%s:%u: Modify iwarp QP%u completed, wait_event_timeout ret=%u, "
+				"CQP Major:Minor codes = 0x%04X:0x%04X.\n",
+				__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, ret, cqp_request->major_code,
+				cqp_request->minor_code);
+		major_code = cqp_request->major_code;
+		if (major_code) {
+			dprintk("%s:%u: Modify iwarp QP%u failed"
+				"CQP Major:Minor codes = 0x%04X:0x%04X, intended next state = 0x%08X.\n",
+				__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, cqp_request->major_code,
+				cqp_request->minor_code, next_iwarp_state);
+		}
+		if (atomic_dec_and_test(&cqp_request->refcount)) {
+			spin_lock_irqsave(&nesdev->cqp.lock, flags);
+			list_add_tail(&cqp_request->list, &nesdev->cqp_avail_reqs);
+			spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		}
+		if (!ret)
+			return(-ETIME);
+		else if (major_code)
+			return(-EIO);
+		else
+			return (0);
+	} else {
+		return (0);
+	}
+}
+
+
+/**
+ * nes_modify_qp
+ */
+int nes_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		int attr_mask, struct ib_udata *udata)
+{
+	struct nes_qp *nesqp = to_nesqp(ibqp);
+	struct nes_vnic *nesvnic = to_nesvnic(ibqp->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	/* u32 cqp_head; */
+	/* u32 counter; */
+	u32 next_iwarp_state = 0;
+	int err;
+	unsigned long qplockflags;
+	int ret;
+	u16 original_last_aeq;
+	u8 issue_modify_qp = 0;
+	u8 issue_disconnect = 0;
+	u8 dont_wait = 0;
+
+	nes_add_ref(&nesqp->ibqp);
+	spin_lock_irqsave(&nesqp->lock, qplockflags);
+
+	dprintk("%s:QP%u: QP State = %u, cur QP State = %u, iwarp_state = 0x%X, refcount = %d. \n",
+			__FUNCTION__, nesqp->hwqp.qp_id, attr->qp_state, nesqp->ibqp_state,
+			nesqp->iwarp_state, atomic_read(&nesqp->refcount));
+	dprintk("%s:QP%u: hw_iwarp_state=0x%X, hw_tcp_state=0x%X, QP Access Flags=0x%X,"
+			" attr_mask = 0x%0x. \n",
+			__FUNCTION__, nesqp->hwqp.qp_id, nesqp->hw_iwarp_state,
+			nesqp->hw_tcp_state, attr->qp_access_flags, attr_mask);
+
+	if (attr_mask & IB_QP_STATE) {
+		switch (attr->qp_state) {
+			case IB_QPS_INIT:
+				dprintk("%s:QP%u: new state = init. \n",
+						__FUNCTION__, nesqp->hwqp.qp_id);
+				if (nesqp->iwarp_state > (u32)NES_CQP_QP_IWARP_STATE_IDLE) {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return (-EINVAL);
+				}
+				next_iwarp_state = NES_CQP_QP_IWARP_STATE_IDLE;
+				issue_modify_qp = 1;
+				break;
+			case IB_QPS_RTR:
+				dprintk("%s:QP%u: new state = rtr. \n",
+						__FUNCTION__, nesqp->hwqp.qp_id );
+				if (nesqp->iwarp_state>(u32)NES_CQP_QP_IWARP_STATE_IDLE) {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return (-EINVAL);
+				}
+				next_iwarp_state = NES_CQP_QP_IWARP_STATE_IDLE;
+				issue_modify_qp = 1;
+				break;
+			case IB_QPS_RTS:
+				dprintk("%s:QP%u: new state = rts. \n",
+						__FUNCTION__, nesqp->hwqp.qp_id );
+				if (nesqp->iwarp_state>(u32)NES_CQP_QP_IWARP_STATE_RTS) {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return (-EINVAL);
+				}
+				if (nesqp->cm_id == NULL) {
+					dprintk("%s:QP%u: Failing attempt to move QP to RTS without a CM_ID. \n",
+							__FUNCTION__, nesqp->hwqp.qp_id );
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return (-EINVAL);
+				}
+				next_iwarp_state = NES_CQP_QP_IWARP_STATE_RTS;
+				if (nesqp->iwarp_state != NES_CQP_QP_IWARP_STATE_RTS)
+					next_iwarp_state |= NES_CQP_QP_CONTEXT_VALID |
+							NES_CQP_QP_ARP_VALID | NES_CQP_QP_ORD_VALID;
+				issue_modify_qp = 1;
+				nesqp->hw_tcp_state = NES_AEQE_TCP_STATE_ESTABLISHED;
+				nesqp->hw_iwarp_state = NES_AEQE_IWARP_STATE_RTS;
+				nesqp->hte_added = 1;
+				break;
+			case IB_QPS_SQD:
+				issue_modify_qp = 1;
+				dprintk("%s:QP%u: new state=closing. SQ head=%u, SQ tail=%u\n",
+						__FUNCTION__, nesqp->hwqp.qp_id, nesqp->hwqp.sq_head,
+						nesqp->hwqp.sq_tail);
+				if (nesqp->iwarp_state==(u32)NES_CQP_QP_IWARP_STATE_CLOSING) {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return 0;
+				} else {
+					if (nesqp->iwarp_state > (u32)NES_CQP_QP_IWARP_STATE_CLOSING) {
+						dprintk("%s:QP%u: State change to closing ignored due to current iWARP state\n",
+								__FUNCTION__, nesqp->hwqp.qp_id);
+						spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+						nes_rem_ref(&nesqp->ibqp);
+						return (-EINVAL);
+					}
+					if (nesqp->hw_iwarp_state != NES_AEQE_IWARP_STATE_RTS) {
+						dprintk("%s:QP%u: State change to closing already done based on hw state.\n",
+								__FUNCTION__, nesqp->hwqp.qp_id);
+						issue_modify_qp = 0;
+						nesqp->in_disconnect = 0;
+					}
+					switch (nesqp->hw_iwarp_state) {
+						case NES_AEQE_IWARP_STATE_CLOSING:
+							next_iwarp_state = NES_CQP_QP_IWARP_STATE_CLOSING;
+						case NES_AEQE_IWARP_STATE_TERMINATE:
+							next_iwarp_state = NES_CQP_QP_IWARP_STATE_TERMINATE;
+							break;
+						case NES_AEQE_IWARP_STATE_ERROR:
+							next_iwarp_state = NES_CQP_QP_IWARP_STATE_ERROR;
+							break;
+						default:
+							next_iwarp_state = NES_CQP_QP_IWARP_STATE_CLOSING;
+							nesqp->in_disconnect = 1;
+							nesqp->hw_iwarp_state = NES_AEQE_IWARP_STATE_CLOSING;
+							break;
+					}
+				}
+				break;
+			case IB_QPS_SQE:
+				dprintk("%s:QP%u: new state = terminate. \n",
+						__FUNCTION__, nesqp->hwqp.qp_id );
+				if (nesqp->iwarp_state>=(u32)NES_CQP_QP_IWARP_STATE_TERMINATE) {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return (-EINVAL);
+				}
+				/* next_iwarp_state = (NES_CQP_QP_IWARP_STATE_TERMINATE | 0x02000000); */
+				next_iwarp_state = NES_CQP_QP_IWARP_STATE_TERMINATE;
+				nesqp->hw_iwarp_state = NES_AEQE_IWARP_STATE_TERMINATE;
+				issue_modify_qp = 1;
+				nesqp->in_disconnect = 1;
+				break;
+			case IB_QPS_ERR:
+			case IB_QPS_RESET:
+				if (nesqp->iwarp_state==(u32)NES_CQP_QP_IWARP_STATE_ERROR) {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_rem_ref(&nesqp->ibqp);
+					return (-EINVAL);
+				}
+				dprintk("%s:QP%u: new state = error. \n",
+						__FUNCTION__, nesqp->hwqp.qp_id );
+				next_iwarp_state = NES_CQP_QP_IWARP_STATE_ERROR;
+				/* next_iwarp_state = (NES_CQP_QP_IWARP_STATE_TERMINATE | 0x02000000); */
+				if (nesqp->hte_added) {
+					dprintk("%s:%u: set CQP_QP_DEL_HTE\n", __FUNCTION__, __LINE__);
+					next_iwarp_state |= NES_CQP_QP_DEL_HTE;
+					nesqp->hte_added = 0;
+				}
+				if ((nesqp->hw_tcp_state > NES_AEQE_TCP_STATE_CLOSED) &&
+					(nesqp->hw_tcp_state != NES_AEQE_TCP_STATE_TIME_WAIT)) {
+					next_iwarp_state |= NES_CQP_QP_RESET;
+					nesqp->in_disconnect = 1;
+				} else {
+					dprintk("%s:%u:QP%u NOT setting NES_CQP_QP_RESET since TCP state = %u\n",
+						__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, nesqp->hw_tcp_state);
+					dont_wait = 1;
+				}
+				issue_modify_qp = 1;
+				nesqp->hw_iwarp_state = NES_AEQE_IWARP_STATE_ERROR;
+				break;
+			default:
+				spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+				nes_rem_ref(&nesqp->ibqp);
+				return (-EINVAL);
+				break;
+		}
+
+		nesqp->ibqp_state = attr->qp_state;
+		if (((nesqp->iwarp_state & NES_CQP_QP_IWARP_STATE_MASK) ==
+				(u32)NES_CQP_QP_IWARP_STATE_RTS) &&
+				((next_iwarp_state & NES_CQP_QP_IWARP_STATE_MASK) >
+				(u32)NES_CQP_QP_IWARP_STATE_RTS)) {
+			nesqp->iwarp_state = next_iwarp_state & NES_CQP_QP_IWARP_STATE_MASK;
+			dprintk("%s:%u: Change nesqp->iwarp_state=%08x\n",
+					__FUNCTION__, __LINE__, nesqp->iwarp_state);
+			issue_disconnect = 1;
+		} else {
+			nesqp->iwarp_state = next_iwarp_state & NES_CQP_QP_IWARP_STATE_MASK;
+			dprintk("%s:%u: Change nesqp->iwarp_state=%08x\n",
+					__FUNCTION__, __LINE__, nesqp->iwarp_state);
+		}
+	}
+
+	if (attr_mask & IB_QP_ACCESS_FLAGS) {
+		if (attr->qp_access_flags & IB_ACCESS_LOCAL_WRITE) {
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_RDMA_WRITE_EN |
+					NES_QPCONTEXT_MISC_RDMA_READ_EN;
+			issue_modify_qp = 1;
+		}
+		if (attr->qp_access_flags & IB_ACCESS_REMOTE_WRITE) {
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_RDMA_WRITE_EN;
+			issue_modify_qp = 1;
+		}
+		if (attr->qp_access_flags & IB_ACCESS_REMOTE_READ) {
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_RDMA_READ_EN;
+			issue_modify_qp = 1;
+		}
+		if (attr->qp_access_flags & IB_ACCESS_MW_BIND) {
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_WBIND_EN;
+			issue_modify_qp = 1;
+		}
+
+		if (nesqp->user_mode) {
+			nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_RDMA_WRITE_EN |
+					NES_QPCONTEXT_MISC_RDMA_READ_EN;
+			issue_modify_qp = 1;
+		}
+	}
+
+	original_last_aeq = nesqp->last_aeq;
+	spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+
+	dprintk("%s[%u]: issue_modify_qp=%u\n", __FUNCTION__, __LINE__, issue_modify_qp);
+
+	ret = 0;
+	if (issue_modify_qp) {
+		dprintk("%s[%u]: call nes_hw_modify_qp\n", __FUNCTION__, __LINE__);
+		ret = nes_hw_modify_qp(nesdev, nesqp, next_iwarp_state, 1);
+		if (ret)
+			dprintk("%s[%u]: nes_hw_modify_qp (next_iwarp_state = 0x%08X)"
+					" failed for QP%u.\n",
+					__FUNCTION__, __LINE__, next_iwarp_state, nesqp->hwqp.qp_id);
+
+	}
+
+	if ((issue_modify_qp) && (nesqp->ibqp_state > IB_QPS_RTS)) {
+		dprintk("%s%u: QP%u Issued ModifyQP refcount (%d),"
+				" original_last_aeq = 0x%04X. last_aeq = 0x%04X.\n",
+				__FUNCTION__, __LINE__, nesqp->hwqp.qp_id,
+				atomic_read(&nesqp->refcount), original_last_aeq, nesqp->last_aeq);
+		if ((!ret) ||
+				((original_last_aeq != NES_AEQE_AEID_RDMAP_ROE_BAD_LLP_CLOSE) &&
+				(ret))) {
+			if (dont_wait) {
+				if (nesqp->cm_id) {
+					dprintk("%s%u: QP%u Queuing fake disconnect for QP refcount (%d),"
+							" original_last_aeq = 0x%04X. last_aeq = 0x%04X.\n",
+							__FUNCTION__, __LINE__, nesqp->hwqp.qp_id,
+							atomic_read(&nesqp->refcount), original_last_aeq,
+							nesqp->last_aeq);
+					/* this one is for the cm_disconnect thread */
+					nes_add_ref(&nesqp->ibqp);
+					spin_lock_irqsave(&nesqp->lock, qplockflags);
+					nesqp->hw_tcp_state = NES_AEQE_TCP_STATE_CLOSED;
+					nesqp->last_aeq = NES_AEQE_AEID_RESET_SENT;
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_cm_disconn(nesqp);
+				} else {
+					nes_rem_ref(&nesqp->ibqp);
+				}
+			} else {
+				spin_lock_irqsave(&nesqp->lock, qplockflags);
+				if (nesqp->cm_id) {
+					/* These two are for the timer thread */
+					nes_add_ref(&nesqp->ibqp);
+					nesqp->cm_id->add_ref(nesqp->cm_id);
+					dprintk("%s%u: QP%u Not decrementing QP refcount (%d),"
+							" need ae to finish up, original_last_aeq = 0x%04X."
+							" last_aeq = 0x%04X, scheduling timer.\n",
+							__FUNCTION__, __LINE__, nesqp->hwqp.qp_id,
+							atomic_read(&nesqp->refcount), original_last_aeq,
+							nesqp->last_aeq);
+					schedule_nes_timer(nesqp->cm_node_p, (struct sk_buff *) nesqp, NES_TIMER_TYPE_CLOSE, 1);
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+				} else {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					dprintk("%s%u: QP%u Not decrementing QP refcount (%d),"
+							" need ae to finish up, original_last_aeq = 0x%04X."
+							" last_aeq = 0x%04X.\n",
+							__FUNCTION__, __LINE__, nesqp->hwqp.qp_id,
+							atomic_read(&nesqp->refcount), original_last_aeq,
+							nesqp->last_aeq);
+				}
+			}
+		} else {
+			dprintk("%s%u: QP%u Decrementing QP refcount (%d), No ae to finish up,"
+					" original_last_aeq = 0x%04X. last_aeq = 0x%04X.\n",
+					__FUNCTION__, __LINE__, nesqp->hwqp.qp_id,
+					atomic_read(&nesqp->refcount), original_last_aeq, nesqp->last_aeq);
+			nes_rem_ref(&nesqp->ibqp);
+		}
+	} else {
+		dprintk("%s%u: QP%u Decrementing QP refcount (%d), No ae to finish up,"
+				" original_last_aeq = 0x%04X. last_aeq = 0x%04X.\n",
+				__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, atomic_read(&nesqp->refcount),
+				original_last_aeq, nesqp->last_aeq);
+		nes_rem_ref(&nesqp->ibqp);
+	}
+
+	err = 0;
+
+	dprintk("%s: QP%u Leaving\n", __FUNCTION__, nesqp->hwqp.qp_id);
+
+	return (err);
+}
+
+
+/**
+ * nes_muticast_attach
+ */
+static int nes_multicast_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (-ENOSYS);
+}
+
+
+/**
+ * nes_multicast_detach
+ */
+static int nes_multicast_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (-ENOSYS);
+}
+
+
+/**
+ * nes_process_mad
+ */
+static int nes_process_mad(struct ib_device *ibdev, int mad_flags,
+		u8 port_num, struct ib_wc *in_wc, struct ib_grh *in_grh,
+		struct ib_mad *in_mad, struct ib_mad *out_mad)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (-ENOSYS);
+}
+
+
+/**
+ * nes_post_send
+ */
+static int nes_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
+		struct ib_send_wr **bad_wr)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibqp->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_qp *nesqp = to_nesqp(ibqp);
+	u32 qsize = nesqp->hwqp.sq_size;
+	struct nes_hw_qp_wqe *wqe;
+	unsigned long flags = 0;
+	u32 head;
+	u32 wqe_misc = 0;
+	int err = 0;
+	u32 wqe_count = 0;
+	u32 counter;
+	int sge_index;
+	u32 total_payload_length = 0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	if (nesqp->ibqp_state > IB_QPS_RTS)
+		return (-EINVAL);
+
+		spin_lock_irqsave(&nesqp->lock, flags);
+
+	head = nesqp->hwqp.sq_head;
+
+	while (ib_wr) {
+		/* Check for SQ overflow */
+		if (((head + (2 * qsize) - nesqp->hwqp.sq_tail) % qsize) == (qsize - 1)) {
+			err = -EINVAL;
+			break;
+		}
+
+		wqe = &nesqp->hwqp.sq_vbase[head];
+		/* dprintk("%s:processing sq wqe for QP%u at %p, head = %u.\n",
+				__FUNCTION__, nesqp->hwqp.qp_id, wqe, head); */
+		*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_SCRATCH_LOW_IDX]) =
+				ib_wr->wr_id;
+		*((struct nes_qp **)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX] |= head;
+
+		switch (ib_wr->opcode) {
+			case IB_WR_SEND:
+				if (ib_wr->send_flags & IB_SEND_SOLICITED) {
+					wqe_misc = NES_IWARP_SQ_OP_SENDSE;
+				} else {
+					wqe_misc = NES_IWARP_SQ_OP_SEND;
+				}
+				if (ib_wr->num_sge > nesdev->nesadapter->max_sge) {
+					err = -EINVAL;
+					break;
+				}
+				if (ib_wr->send_flags & IB_SEND_FENCE) {
+					wqe_misc |= NES_IWARP_SQ_WQE_LOCAL_FENCE;
+				}
+				if ((ib_wr->send_flags & IB_SEND_INLINE) &&
+						(ib_wr->sg_list[0].length <= 64)) {
+					memcpy(&wqe->wqe_words[NES_IWARP_SQ_WQE_IMM_DATA_START_IDX],
+							(void *)ib_wr->sg_list[0].addr, ib_wr->sg_list[0].length);
+					wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
+							ib_wr->sg_list[0].length;
+					wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
+							NES_IWARP_SQ_WQE_IMM_DATA;
+				} else {
+					total_payload_length = 0;
+					for (sge_index=0; sge_index < ib_wr->num_sge; sge_index++) {
+						wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX+(sge_index*4)] =
+								cpu_to_le32((u32)ib_wr->sg_list[sge_index].addr);
+						wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX+(sge_index*4)] =
+								cpu_to_le32((u32)(ib_wr->sg_list[sge_index].addr>>32));
+						wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX+(sge_index*4)] =
+								cpu_to_le32(ib_wr->sg_list[sge_index].length);
+						wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX+(sge_index*4)] =
+								cpu_to_le32(ib_wr->sg_list[sge_index].lkey);
+						total_payload_length += ib_wr->sg_list[sge_index].length;
+					}
+					wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
+							cpu_to_le32(total_payload_length);
+				}
+
+				break;
+			case IB_WR_RDMA_WRITE:
+				wqe_misc = NES_IWARP_SQ_OP_RDMAW;
+				if (ib_wr->num_sge > nesdev->nesadapter->max_sge) {
+					dprintk("%s:%u: Exceeded max sge, ib_wr=%u, max=%u\n",
+							__FUNCTION__, __LINE__, ib_wr->num_sge,
+							nesdev->nesadapter->max_sge);
+					err = -EINVAL;
+					break;
+				}
+				if (ib_wr->send_flags & IB_SEND_FENCE) {
+					wqe_misc |= NES_IWARP_SQ_WQE_LOCAL_FENCE;
+				}
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_STAG_IDX] =
+						cpu_to_le32(ib_wr->wr.rdma.rkey);
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_LOW_IDX] =
+						cpu_to_le32(ib_wr->wr.rdma.remote_addr);
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_HIGH_IDX] =
+						cpu_to_le32((u32)(ib_wr->wr.rdma.remote_addr >> 32));
+
+				if ((ib_wr->send_flags & IB_SEND_INLINE) &&
+						(ib_wr->sg_list[0].length <= 64)) {
+					memcpy(&wqe->wqe_words[NES_IWARP_SQ_WQE_IMM_DATA_START_IDX],
+							(void *)ib_wr->sg_list[0].addr, ib_wr->sg_list[0].length);
+					wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
+							ib_wr->sg_list[0].length;
+					wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
+							NES_IWARP_SQ_WQE_IMM_DATA;
+				} else {
+					total_payload_length = 0;
+					for (sge_index=0; sge_index < ib_wr->num_sge; sge_index++) {
+						wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX+(sge_index*4)] =
+								cpu_to_le32((u32)ib_wr->sg_list[sge_index].addr);
+						wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX+(sge_index*4)] =
+								cpu_to_le32((u32)(ib_wr->sg_list[sge_index].addr>>32));
+						wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX+(sge_index*4)] =
+								cpu_to_le32(ib_wr->sg_list[sge_index].length);
+						wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX+(sge_index*4)] =
+								cpu_to_le32(ib_wr->sg_list[sge_index].lkey);
+						total_payload_length += ib_wr->sg_list[sge_index].length;
+					}
+					wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
+							cpu_to_le32(total_payload_length);
+				}
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX] =
+						wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX];
+				break;
+			case IB_WR_RDMA_READ:
+				/* IWarp only supports 1 sge for RDMA reads */
+				if (ib_wr->num_sge > 1) {
+					dprintk("%s:%u: Exceeded max sge, ib_wr=%u, max=1\n",
+							__FUNCTION__, __LINE__, ib_wr->num_sge);
+					err = -EINVAL;
+					break;
+				}
+				wqe_misc = NES_IWARP_SQ_OP_RDMAR;
+
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_LOW_IDX] =
+						cpu_to_le32(ib_wr->wr.rdma.remote_addr);
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_HIGH_IDX] =
+						cpu_to_le32((u32)(ib_wr->wr.rdma.remote_addr >> 32));
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_STAG_IDX] =
+						cpu_to_le32(ib_wr->wr.rdma.rkey);
+				wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX] =
+						cpu_to_le32(ib_wr->sg_list->length);
+				wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] =
+						cpu_to_le32(ib_wr->sg_list->addr);
+				wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX] =
+						cpu_to_le32((u32)(ib_wr->sg_list->addr >> 32));
+				wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] =
+						cpu_to_le32(ib_wr->sg_list->lkey);
+				break;
+			default:
+				/* error */
+				err = -EINVAL;
+				break;
+		}
+
+		if (ib_wr->send_flags & IB_SEND_SIGNALED) {
+			dprintk("%s:%u: Setting SQ_WQE_SIGNALED_COMPL\n",
+					__FUNCTION__, __LINE__);
+			wqe_misc |= NES_IWARP_SQ_WQE_SIGNALED_COMPL;
+		}
+		wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] = cpu_to_le32(wqe_misc);
+
+		ib_wr = ib_wr->next;
+		head++;
+		wqe_count++;
+		if (head >= qsize)
+			head = 0;
+
+	}
+
+	nesqp->hwqp.sq_head = head;
+	barrier();
+	while (wqe_count) {
+		counter = min(wqe_count, ((u32)255));
+		wqe_count -= counter;
+		nes_write32(nesdev->regs + NES_WQE_ALLOC,
+				(counter << 24) | 0x00800000 | nesqp->hwqp.qp_id);
+	}
+
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+
+	if (err)
+		*bad_wr = ib_wr;
+	return(err);
+}
+
+
+/**
+ * nes_post_recv
+ */
+static int nes_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *ib_wr,
+		struct ib_recv_wr **bad_wr)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibqp->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_qp *nesqp = to_nesqp(ibqp);
+	u32 qsize = nesqp->hwqp.rq_size;
+	struct nes_hw_qp_wqe *wqe;
+	unsigned long flags = 0;
+	u32 head;
+	int err = 0;
+	u32 wqe_count = 0;
+	u32 counter;
+	int sge_index;
+	u32 total_payload_length;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	if (nesqp->ibqp_state > IB_QPS_RTS)
+		return (-EINVAL);
+
+		spin_lock_irqsave(&nesqp->lock, flags);
+
+	head = nesqp->hwqp.rq_head;
+
+	while (ib_wr) {
+		if (ib_wr->num_sge > nesdev->nesadapter->max_sge) {
+			err = -EINVAL;
+			break;
+		}
+		/* Check for RQ overflow */
+		if (((head + (2 * qsize) - nesqp->hwqp.rq_tail) % qsize) == (qsize - 1)) {
+			err = -EINVAL;
+			break;
+		}
+
+		dprintk("%s: ibwr sge count = %u.\n", __FUNCTION__, ib_wr->num_sge);
+		wqe = &nesqp->hwqp.rq_vbase[head];
+
+		/* dprintk("%s:QP%u:processing rq wqe at %p, head = %u.\n",
+				__FUNCTION__, nesqp->hwqp.qp_id, wqe, head); */
+		*((u64 *)&wqe->wqe_words[NES_IWARP_RQ_WQE_COMP_SCRATCH_LOW_IDX]) =
+				ib_wr->wr_id;
+		*((struct nes_qp **)&wqe->wqe_words[NES_IWARP_RQ_WQE_COMP_CTX_LOW_IDX]) =
+				nesqp;
+		wqe->wqe_words[NES_IWARP_RQ_WQE_COMP_CTX_LOW_IDX] |= head;
+
+		total_payload_length = 0;
+		for (sge_index=0; sge_index < ib_wr->num_sge; sge_index++) {
+			wqe->wqe_words[NES_IWARP_RQ_WQE_FRAG0_LOW_IDX+(sge_index*4)] =
+					cpu_to_le32((u32)ib_wr->sg_list[sge_index].addr);
+			wqe->wqe_words[NES_IWARP_RQ_WQE_FRAG0_HIGH_IDX+(sge_index*4)] =
+					cpu_to_le32((u32)(ib_wr->sg_list[sge_index].addr >> 32));
+			wqe->wqe_words[NES_IWARP_RQ_WQE_LENGTH0_IDX+(sge_index*4)] =
+					cpu_to_le32(ib_wr->sg_list[sge_index].length);
+			wqe->wqe_words[NES_IWARP_RQ_WQE_STAG0_IDX+(sge_index*4)] =
+					cpu_to_le32(ib_wr->sg_list[sge_index].lkey);
+			total_payload_length += ib_wr->sg_list[sge_index].length;
+		}
+		wqe->wqe_words[NES_IWARP_RQ_WQE_TOTAL_PAYLOAD_IDX] =
+				cpu_to_le32(total_payload_length);
+
+		ib_wr = ib_wr->next;
+		head++;
+		wqe_count++;
+		if (head >= qsize)
+			head = 0;
+	}
+
+	nesqp->hwqp.rq_head = head;
+	barrier();
+	while (wqe_count) {
+		counter = min(wqe_count, ((u32)255));
+		wqe_count -= counter;
+		nes_write32(nesdev->regs+NES_WQE_ALLOC, (counter<<24) | nesqp->hwqp.qp_id);
+	}
+
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+
+	if (err)
+		*bad_wr = ib_wr;
+	return (err);
+}
+
+
+/**
+ * nes_poll_cq
+ */
+static int nes_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *entry)
+{
+	u64 wrid;
+	/* u64 u64temp; */
+	struct nes_vnic *nesvnic = to_nesvnic(ibcq->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_cq *nescq = to_nescq(ibcq);
+	struct nes_qp *nesqp;
+	struct nes_hw_cqe cqe;
+	unsigned long flags = 0;
+	u32 head;
+	u32 wq_tail;
+	u32 cq_size;
+	u32 cqe_count=0;
+	u32 wqe_index;
+	/* u32 counter; */
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+		spin_lock_irqsave(&nescq->lock, flags);
+
+	head = nescq->hw_cq.cq_head;
+	cq_size = nescq->hw_cq.cq_size;
+
+	while (cqe_count<num_entries) {
+		if (le32_to_cpu(nescq->hw_cq.cq_vbase[head].cqe_words[NES_CQE_OPCODE_IDX]) &
+				NES_CQE_VALID) {
+			cqe = nescq->hw_cq.cq_vbase[head];
+			nescq->hw_cq.cq_vbase[head].cqe_words[NES_CQE_OPCODE_IDX] = 0;
+			wqe_index = cqe.cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX] &
+					(nesdev->nesadapter->max_qp_wr - 1);
+			cqe.cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX] &= ~(NES_SW_CONTEXT_ALIGN-1);
+			barrier();
+			/* parse CQE, get completion context from WQE (either rq or sq */
+			nesqp = *((struct nes_qp **)&cqe.cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX]);
+			memset(entry, 0, sizeof *entry);
+			if (0 == cqe.cqe_words[NES_CQE_ERROR_CODE_IDX]) {
+				entry->status = IB_WC_SUCCESS;
+			} else {
+				entry->status = IB_WC_WR_FLUSH_ERR;
+			}
+
+			entry->qp = &nesqp->ibqp;
+			entry->src_qp = nesqp->hwqp.qp_id;
+
+			if (le32_to_cpu(cqe.cqe_words[NES_CQE_OPCODE_IDX]) & NES_CQE_SQ) {
+				if (nesqp->skip_lsmm) {
+					nesqp->skip_lsmm = 0;
+					wq_tail = nesqp->hwqp.sq_tail++;
+				}
+
+				/* Working on a SQ Completion*/
+				wq_tail = wqe_index;
+				nesqp->hwqp.sq_tail = (wqe_index+1)&(nesqp->hwqp.sq_size - 1);
+				wrid = *((u64 *)&nesqp->hwqp.sq_vbase[wq_tail].
+						wqe_words[NES_IWARP_SQ_WQE_COMP_SCRATCH_LOW_IDX]);
+				entry->byte_len = le32_to_cpu(nesqp->hwqp.sq_vbase[wq_tail].
+						wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX]);
+
+				switch (le32_to_cpu(nesqp->hwqp.sq_vbase[wq_tail].
+						wqe_words[NES_IWARP_SQ_WQE_MISC_IDX]) & 0x3f) {
+					case NES_IWARP_SQ_OP_RDMAW:
+						dprintk("%s: Operation = RDMA WRITE.\n", __FUNCTION__);
+						entry->opcode = IB_WC_RDMA_WRITE;
+						break;
+					case NES_IWARP_SQ_OP_RDMAR:
+						dprintk("%s: Operation = RDMA READ.\n", __FUNCTION__);
+						entry->opcode = IB_WC_RDMA_READ;
+						entry->byte_len = le32_to_cpu(nesqp->hwqp.sq_vbase[wq_tail].
+								wqe_words[NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX]);
+						break;
+					case NES_IWARP_SQ_OP_SENDINV:
+					case NES_IWARP_SQ_OP_SENDSEINV:
+					case NES_IWARP_SQ_OP_SEND:
+					case NES_IWARP_SQ_OP_SENDSE:
+						dprintk("%s: Operation = Send.\n", __FUNCTION__);
+						entry->opcode = IB_WC_SEND;
+						break;
+				}
+			} else {
+				/* Working on a RQ Completion*/
+				wq_tail = wqe_index;
+				nesqp->hwqp.rq_tail = (wqe_index+1)&(nesqp->hwqp.rq_size - 1);
+				entry->byte_len = le32_to_cpu(cqe.cqe_words[NES_CQE_PAYLOAD_LENGTH_IDX]);
+				wrid = *((u64 *)&nesqp->hwqp.rq_vbase[wq_tail].
+						 wqe_words[NES_IWARP_RQ_WQE_COMP_SCRATCH_LOW_IDX]);
+				entry->opcode = IB_WC_RECV;
+			}
+			entry->wr_id = wrid;
+
+			if (++head >= cq_size)
+				head = 0;
+			cqe_count++;
+			nescq->polled_completions++;
+			if ((nescq->polled_completions > (cq_size/2)) ||
+					(nescq->polled_completions == 255)) {
+				dprintk("%s: CQ%u Issuing CQE Allocate since more than half of cqes"
+						" are pending %u of %u.\n",
+						__FUNCTION__, nescq->hw_cq.cq_number,
+						nescq->polled_completions, cq_size);
+				nes_write32(nesdev->regs+NES_CQE_ALLOC,
+						nescq->hw_cq.cq_number | (nescq->polled_completions << 16));
+				nescq->polled_completions = 0;
+			}
+			entry++;
+		} else
+			break;
+	}
+
+	if (nescq->polled_completions) {
+		/* dprintk("%s: CQ%u Issuing CQE Allocate for %u cqes.\n",
+				__FUNCTION__, nescq->hw_cq.cq_number, nescq->polled_completions); */
+		nes_write32(nesdev->regs+NES_CQE_ALLOC,
+				nescq->hw_cq.cq_number | (nescq->polled_completions << 16));
+		nescq->polled_completions = 0;
+	}
+
+	nescq->hw_cq.cq_head = head;
+	dprintk("%s: Reporting %u completions for CQ%u.\n", __FUNCTION__, cqe_count,
+			nescq->hw_cq.cq_number);
+
+		spin_unlock_irqrestore(&nescq->lock, flags);
+
+	return (cqe_count);
+}
+
+
+/**
+ * nes_req_notify_cq
+ */
+static int nes_req_notify_cq(struct ib_cq *ibcq, enum ib_cq_notify notify)
+{
+	struct nes_vnic *nesvnic = to_nesvnic(ibcq->device);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_cq *nescq = to_nescq(ibcq);
+	u32 cq_arm;
+
+	dprintk("%s: Requesting notification for CQ%u.\n",
+			__FUNCTION__, nescq->hw_cq.cq_number);
+
+	cq_arm = nescq->hw_cq.cq_number;
+	if (notify == IB_CQ_NEXT_COMP)
+		cq_arm |= NES_CQE_ALLOC_NOTIFY_NEXT;
+	else if (notify == IB_CQ_SOLICITED)
+		cq_arm |= NES_CQE_ALLOC_NOTIFY_SE;
+	else
+		return (-EINVAL);
+
+	/* dprintk("%s: Arming CQ%u, command = 0x%08X.\n",
+			__FUNCTION__, nescq->hw_cq.cq_number, cq_arm); */
+	nes_write32(nesdev->regs+NES_CQE_ALLOC, cq_arm);
+	nes_read32(nesdev->regs+NES_CQE_ALLOC);
+
+	return (0);
+}
+
+
+/**
+ * nes_init_ofa_device
+ */
+struct nes_ib_device *nes_init_ofa_device(struct net_device *netdev)
+{
+	struct nes_ib_device *nesibdev;
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	nesibdev = (struct nes_ib_device *)ib_alloc_device(sizeof(struct nes_ib_device));
+	if (nesibdev == NULL) {
+		return(NULL);
+	}
+	strlcpy(nesibdev->ibdev.name, "nes%d", IB_DEVICE_NAME_MAX);
+	nesibdev->ibdev.owner = THIS_MODULE;
+
+	nesibdev->ibdev.node_type = RDMA_NODE_RNIC;
+	memset(&nesibdev->ibdev.node_guid, 0, sizeof(nesibdev->ibdev.node_guid));
+	memcpy(&nesibdev->ibdev.node_guid, netdev->dev_addr, 6);
+
+	nesibdev->ibdev.uverbs_cmd_mask =
+			(1ull << IB_USER_VERBS_CMD_GET_CONTEXT) |
+			(1ull << IB_USER_VERBS_CMD_QUERY_DEVICE) |
+			(1ull << IB_USER_VERBS_CMD_QUERY_PORT) |
+			(1ull << IB_USER_VERBS_CMD_ALLOC_PD) |
+			(1ull << IB_USER_VERBS_CMD_DEALLOC_PD) |
+			(1ull << IB_USER_VERBS_CMD_REG_MR) |
+			(1ull << IB_USER_VERBS_CMD_DEREG_MR) |
+			(1ull << IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
+			(1ull << IB_USER_VERBS_CMD_CREATE_CQ) |
+			(1ull << IB_USER_VERBS_CMD_DESTROY_CQ) |
+			(1ull << IB_USER_VERBS_CMD_CREATE_AH) |
+			(1ull << IB_USER_VERBS_CMD_DESTROY_AH) |
+			(1ull << IB_USER_VERBS_CMD_REQ_NOTIFY_CQ) |
+			(1ull << IB_USER_VERBS_CMD_CREATE_QP) |
+			(1ull << IB_USER_VERBS_CMD_MODIFY_QP) |
+			(1ull << IB_USER_VERBS_CMD_POLL_CQ) |
+			(1ull << IB_USER_VERBS_CMD_DESTROY_QP) |
+			(1ull << IB_USER_VERBS_CMD_ALLOC_MW) |
+			(1ull << IB_USER_VERBS_CMD_BIND_MW) |
+			(1ull << IB_USER_VERBS_CMD_DEALLOC_MW) |
+			(1ull << IB_USER_VERBS_CMD_POST_RECV) |
+			(1ull << IB_USER_VERBS_CMD_POST_SEND);
+
+	nesibdev->ibdev.phys_port_cnt = 1;
+	nesibdev->ibdev.dma_device = &nesdev->pcidev->dev;
+	nesibdev->ibdev.class_dev.dev = &nesdev->pcidev->dev;
+	nesibdev->ibdev.query_device = nes_query_device;
+	nesibdev->ibdev.query_port = nes_query_port;
+	nesibdev->ibdev.modify_port = nes_modify_port;
+	nesibdev->ibdev.query_pkey = nes_query_pkey;
+	nesibdev->ibdev.query_gid = nes_query_gid;
+	nesibdev->ibdev.alloc_ucontext = nes_alloc_ucontext;
+	nesibdev->ibdev.dealloc_ucontext = nes_dealloc_ucontext;
+	nesibdev->ibdev.mmap = nes_mmap;
+	nesibdev->ibdev.alloc_pd = nes_alloc_pd;
+	nesibdev->ibdev.dealloc_pd = nes_dealloc_pd;
+	nesibdev->ibdev.create_ah = nes_create_ah;
+	nesibdev->ibdev.destroy_ah = nes_destroy_ah;
+	nesibdev->ibdev.create_qp = nes_create_qp;
+	nesibdev->ibdev.modify_qp = nes_modify_qp;
+	nesibdev->ibdev.query_qp = nes_query_qp;
+	nesibdev->ibdev.destroy_qp = nes_destroy_qp;
+	nesibdev->ibdev.create_cq = nes_create_cq;
+	nesibdev->ibdev.destroy_cq = nes_destroy_cq;
+	nesibdev->ibdev.poll_cq = nes_poll_cq;
+	nesibdev->ibdev.get_dma_mr = nes_get_dma_mr;
+	nesibdev->ibdev.reg_phys_mr = nes_reg_phys_mr;
+	nesibdev->ibdev.reg_user_mr = nes_reg_user_mr;
+	nesibdev->ibdev.dereg_mr = nes_dereg_mr;
+	nesibdev->ibdev.alloc_mw = nes_alloc_mw;
+	nesibdev->ibdev.dealloc_mw = nes_dealloc_mw;
+	nesibdev->ibdev.bind_mw = nes_bind_mw;
+
+	nesibdev->ibdev.alloc_fmr = nes_alloc_fmr;
+	nesibdev->ibdev.unmap_fmr = nes_unmap_fmr;
+	nesibdev->ibdev.dealloc_fmr = nes_dealloc_fmr;
+	nesibdev->ibdev.map_phys_fmr = nes_map_phys_fmr;
+
+	nesibdev->ibdev.attach_mcast = nes_multicast_attach;
+	nesibdev->ibdev.detach_mcast = nes_multicast_detach;
+	nesibdev->ibdev.process_mad = nes_process_mad;
+
+	nesibdev->ibdev.req_notify_cq = nes_req_notify_cq;
+	nesibdev->ibdev.post_send = nes_post_send;
+	nesibdev->ibdev.post_recv = nes_post_recv;
+
+	nesibdev->ibdev.iwcm = kmalloc(sizeof(*nesibdev->ibdev.iwcm), GFP_KERNEL);
+	if (nesibdev->ibdev.iwcm == NULL) {
+		ib_dealloc_device(&nesibdev->ibdev);
+		return(NULL);
+	}
+	nesibdev->ibdev.iwcm->add_ref = nes_add_ref;
+	nesibdev->ibdev.iwcm->rem_ref = nes_rem_ref;
+	nesibdev->ibdev.iwcm->get_qp = nes_get_qp;
+	nesibdev->ibdev.iwcm->connect = nes_connect;
+	nesibdev->ibdev.iwcm->accept = nes_accept;
+	nesibdev->ibdev.iwcm->reject = nes_reject;
+	nesibdev->ibdev.iwcm->create_listen = nes_create_listen;
+	nesibdev->ibdev.iwcm->destroy_listen = nes_destroy_listen;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return(nesibdev);
+}
+
+
+/**
+ * nes_destroy_ofa_device
+ */
+void nes_destroy_ofa_device(struct nes_ib_device *nesibdev)
+{
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+	if (NULL == nesibdev)
+		return;
+
+	nes_unregister_ofa_device(nesibdev);
+
+	kfree(nesibdev->ibdev.iwcm);
+	ib_dealloc_device(&nesibdev->ibdev);
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+}
+
+
+/**
+ * nes_register_ofa_device
+ */
+int nes_register_ofa_device(struct nes_ib_device *nesibdev)
+{
+	struct nes_vnic *nesvnic = nesibdev->nesvnic;
+	struct nes_device *nesdev = nesvnic->nesdev;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	int i, ret;
+
+	dprintk("%s: %u: &nesvnic=0x%p : &ibdev=0x%p\n", __FUNCTION__, __LINE__,
+			nesvnic, &nesvnic->nesibdev->ibdev);
+
+	ret = ib_register_device(&nesvnic->nesibdev->ibdev);
+	if (ret) {
+		dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+		return(ret);
+	}
+
+	dprintk("%s:%u after ib_register_device\n", __FUNCTION__, __LINE__);
+
+	/* Get the resources allocated to this device */
+	nesibdev->max_cq = (nesadapter->max_cq-NES_FIRST_QPN) / nesadapter->port_count;
+	nesibdev->max_mr = nesadapter->max_mr / nesadapter->port_count;
+	nesibdev->max_qp = (nesadapter->max_qp-NES_FIRST_QPN) / nesadapter->port_count;
+	nesibdev->max_pd = nesadapter->max_pd / nesadapter->port_count;
+
+	for (i = 0; i < ARRAY_SIZE(nes_class_attributes); ++i) {
+		dprintk("%s:%u call class_device_create_file\n", __FUNCTION__, __LINE__);
+		ret = class_device_create_file(&nesibdev->ibdev.class_dev, nes_class_attributes[i]);
+		if (ret) {
+			dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+			while (i > 0) {
+				i--;
+				class_device_remove_file(&nesibdev->ibdev.class_dev,
+						nes_class_attributes[i]);
+			}
+			ib_unregister_device(&nesibdev->ibdev);
+			return(ret);
+		}
+	}
+
+	nesvnic->of_device_registered = 1;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	return (0);
+}
+
+
+/**
+ * nes_unregister_ofa_device
+ */
+void nes_unregister_ofa_device(struct nes_ib_device *nesibdev)
+{
+	struct nes_vnic *nesvnic = nesibdev->nesvnic;
+	int i;
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+	if (NULL == nesibdev)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(nes_class_attributes); ++i) {
+		class_device_remove_file(&nesibdev->ibdev.class_dev, nes_class_attributes[i]);
+	}
+
+	if (nesvnic->of_device_registered) {
+		dprintk("%s:%u call ib_unregister_device()\n", __FUNCTION__, __LINE__);
+		ib_unregister_device(&nesibdev->ibdev);
+	}
+
+	nesvnic->of_device_registered = 0;
+
+	dprintk("%s:%u\n", __FUNCTION__, __LINE__);
+}
+
