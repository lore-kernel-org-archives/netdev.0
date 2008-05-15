From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 8/15] BE NIC driver - beclib functions
Date: Thu, 15 May 2008 02:21:56 -0700
Message-ID: <20080515092156.08216c44@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:2057 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYEOJRS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:17:18 -0400
Received: from 124.30.166.146 ([124.30.166.146])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Thu, 15 May 2008 02:21:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/cq_ll.c    |  467 ++++++++++++++++++
 drivers/message/beclib/ethrx_ll.c |  420 ++++++++++++++++
 drivers/message/beclib/ethtx_ll.c |  553 +++++++++++++++++++++
 drivers/message/beclib/rxf_ll.c   |  951 +++++++++++++++++++++++++++++++++++++
 4 files changed, 2391 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/cq_ll.c
 create mode 100644 drivers/message/beclib/ethrx_ll.c
 create mode 100644 drivers/message/beclib/ethtx_ll.c
 create mode 100644 drivers/message/beclib/rxf_ll.c

diff --git a/drivers/message/beclib/cq_ll.c b/drivers/message/beclib/cq_ll.c
new file mode 100644
index 0000000..f2a916a
--- /dev/null
+++ b/drivers/message/beclib/cq_ll.c
@@ -0,0 +1,467 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*
+ * Completion Queue Objects
+ */
+
+/*!
+@brief
+    This routines searches for a CqId that is bound to a
+    specified function object.
+@param
+    pfob  - function object the CQ should be bound to.
+@param
+    cq_id            - cq_id to find
+@return
+    A pointer to the CQ_OBJECT that represents this CqId. NULL if not found
+@note
+    IRQL: <= DISPATCH_LEVEL
+*/
+static INLINE struct BE_CQ_OBJECT *
+be_cq_id_to_object(struct BE_FUNCTION_OBJECT *pfob, u32 cq_id)
+{
+	struct BE_CQ_OBJECT *cq_cur;
+	struct BE_CQ_OBJECT *cq_ret = NULL;
+	u32 cid;
+
+	_be_function_lock(pfob);
+
+	SA_FOR_EACH_LIST_ENTRY(cq_cur, pfob->links.cq_list_head,
+			       struct BE_CQ_OBJECT, cq_list) {
+		cid = be_cq_get_id(cq_cur);
+		if (cid == cq_id) {
+			cq_ret = cq_cur;
+			break;
+		}
+	}
+
+	_be_function_unlock(pfob);
+
+	if (!cq_ret) {
+		TRACE(DL_ERR, "Failed to locate cq_id:%d for processing.",
+		      cq_id);
+	}
+
+	return cq_ret;
+}
+
+/*
+ *============================================================================
+ *                  P U B L I C  R O U T I N E S
+ *============================================================================
+ */
+
+/*!
+
+@brief
+    This routine creates a completion queue based on the client completion
+    queue configuration information.
+
+
+@param
+    FunctionObject      - Handle to a function object
+@param
+    CqBaseVa            - Base VA for a the CQ ring
+@param
+    NumEntries          - CEV_CQ_CNT_* values
+@param
+    solEventEnable      - 0 = All CQEs can generate Events if CQ is eventable
+			1 = only CQEs with solicited bit set are eventable
+@param
+    eventable           - Eventable CQ, generates interrupts.
+@param
+    nodelay             - 1 = Force interrupt, relevent if CQ eventable.
+			Interrupt is asserted immediately after EQE
+			write is confirmed, regardless of EQ Timer
+			or watermark settings.
+@param
+    wme                 - Enable watermark based coalescing
+@param
+    wmThresh            - High watermark(CQ fullness at which event
+			or interrupt should be asserted).  These are the
+			CEV_WATERMARK encoded values.
+@param
+    EqObject            - EQ Handle to assign to this CQ
+@param
+    ppCqObject          - Internal CQ Handle returned.
+
+@return
+    BE_SUCCESS if successfull, otherwise a useful error code is returned.
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+BESTATUS be_cq_create(struct BE_FUNCTION_OBJECT *pfob,
+	struct SA_SGL *sgl, u32 length, bool solicited_eventable,
+	bool no_delay, u32 wm_thresh,
+	struct BE_EQ_OBJECT *eq_object, struct BE_CQ_OBJECT *cq_object)
+{
+	BESTATUS status = BE_SUCCESS;
+	u32 num_entries_encoding;
+	u32 num_entries = length / sizeof(struct MCC_CQ_ENTRY_AMAP);
+	struct IOCTL_COMMON_CQ_CREATE_AMAP *ioctl = NULL;
+	struct BE_IOCTL_COMMON_CQ_CREATE_AMAP *be_ioctl;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct PHYS_ADDR *pa_listp;
+	u32 n, npages;
+
+	ASSERT(sgl);
+	ASSERT(cq_object);
+	ASSERT(length % sizeof(struct MCC_CQ_ENTRY_AMAP) == 0);
+
+	FUNCTION_ASSERT(pfob);
+
+	switch (num_entries) {
+	case 256:
+		num_entries_encoding = CEV_CQ_CNT_256;
+		break;
+	case 512:
+		num_entries_encoding = CEV_CQ_CNT_512;
+		break;
+	case 1024:
+		num_entries_encoding = CEV_CQ_CNT_1024;
+		break;
+	default:
+		ASSERT(0);
+		return BE_STATUS_INVALID_PARAMETER;
+	}
+
+	/*
+	 * All cq entries all the same size.  Use iSCSI version
+	 * as a test for the proper sgl length.
+	 */
+	sa_zero_mem(cq_object, sizeof(*cq_object));
+
+	cq_object->magic = BE_CQ_MAGIC;
+	cq_object->ref_count = 0;
+	cq_object->parent_function = pfob;
+	cq_object->eq_object = eq_object;
+	cq_object->num_entries = num_entries;
+	/* save for MCC cq processing */
+	cq_object->va = sa_sgl_get_base_va(sgl);
+
+	/* map into UT. */
+	length = num_entries * sizeof(struct MCC_CQ_ENTRY_AMAP);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL_AMAP(pfob, wrb,
+					       COMMON_CQ_CREATE);
+
+
+	n = SA_PAGES_SPANNED(sa_sgl_get_offset(sgl), length);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.num_pages,
+					ioctl, n);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.valid,
+					ioctl, 1);
+	n = be_function_get_function_number(pfob);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.Func,
+					ioctl, n);
+
+	n = (eq_object != NULL);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE,
+			params.request.context.Eventable, ioctl, n);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.Armed,
+			ioctl, 1);
+
+	n = eq_object ? eq_object->eq_id : 0;
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.EQID,
+				ioctl, n);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.Count,
+				ioctl, num_entries_encoding);
+
+	n = be_function_get_pd_number(pfob);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.PD,
+				ioctl, n);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE,
+			params.request.context.NoDelay, ioctl, no_delay);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE,
+		params.request.context.SolEvent, ioctl, solicited_eventable);
+
+	n = (wm_thresh != 0xFFFFFFFF);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE, params.request.context.WME,
+			ioctl, n);
+
+	n = (n ? wm_thresh : 0);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_CQ_CREATE,
+			params.request.context.Watermark, ioctl, n);
+
+	n = AMAP_WORD_OFFSET(IOCTL_COMMON_CQ_CREATE, params.request.pages);
+	pa_listp = (struct PHYS_ADDR *)((u32 *)ioctl + n);
+	be_ioctl = (struct BE_IOCTL_COMMON_CQ_CREATE_AMAP *)ioctl;
+	npages = SA_NUMBER_OF(be_ioctl->params.request.pages);
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl, pa_listp, npages);
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl, pa_listp, npages);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create CQ failed.");
+		goto Error;
+	}
+	/* Remember the CQ id. */
+	cq_object->cq_id = AMAP_GET_BITS_PTR(IOCTL_COMMON_CQ_CREATE,
+				params.response.cq_id, ioctl);
+
+	/* insert this cq into eq_object reference */
+	if (eq_object)
+		_be_eq_add_cq(eq_object, cq_object);
+
+	/* insert this cq into pfob */
+	_be_function_add_cq(pfob, cq_object);
+
+	TRACE(DL_INFO,
+	      "cq created. function:%d pd:%d cqid:%d bytes:%d eqid:%d"
+	      " se:%d nd:%d wm:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob), cq_object->cq_id,
+	      num_entries * sizeof(struct MCC_CQ_ENTRY_AMAP),
+	      eq_object ? be_eq_get_id(eq_object) : -1,
+	      (u32) solicited_eventable, (u32) no_delay, wm_thresh);
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+
+@brief
+    Returns the CQ ID for CQ. This is the ID the chip references the queue as.
+
+@param
+    cq_object            - CQ handle returned from cq_object_create.
+
+@return
+    CQ ID
+@note
+    IRQL: any
+
+*/
+u32 be_cq_get_id(struct BE_CQ_OBJECT *cq_object)
+{
+	CQ_ASSERT(cq_object);
+	return cq_object->cq_id;
+}
+
+/*!
+
+@brief
+    Sets the current callback to be invoked when a CQ entry is made available.
+    This need only be set if the owner of this CQ does not recieve the CQ
+    completions directly. i.e. it does not service interrupts.
+
+@param
+    cq_object            - CQ handle returned from cq_object_create.
+
+@param
+    callback            - function to invoke when the CQ needs processing.
+
+@param
+    context             - opaque context to pass to callback.
+
+@return
+    ptr to the previous callback.
+
+@note
+    IRQL: any
+
+    this routine is currently not synchronized w/ the DPC that may run the CQ.
+    therefore it is the callers responsibility to ensure the CQ will not
+    interrupt while this routine is executing.
+*/
+CQ_CALLBACK
+be_cq_object_set_callback(struct BE_CQ_OBJECT *cq_object,
+			  CQ_CALLBACK callback, void *context)
+{
+	CQ_CALLBACK old_callback;
+
+	CQ_ASSERT(cq_object);
+
+	old_callback = cq_object->callback;
+
+	cq_object->callback = callback;
+	cq_object->callback_context = context;
+
+	return old_callback;
+}
+
+/*!
+
+@brief
+    This routine handles CQ processing on CQs that were 'unrecognized' by upper
+    level drivers.  The only CQs that should be processed by this routine are
+    MCC CQ and iWARP CQ and of these, only the MCC CQ will be processed
+    in this routine. The iWARP CQ will be delegated further for handling
+    by the iWARP device driver
+
+@param
+    pfob      - handle to a function object
+@param
+    cq_id                - the cq that has just completed processing
+
+@return
+
+
+@note
+    IRQL: DISPATCH_LEVEL only
+
+    this routine should be called immediately when a CQ from a ULD is not
+    recognized.
+*/
+void
+be_cq_object_delegate_processing(struct BE_FUNCTION_OBJECT *pfob, u32 cq_id)
+{
+	struct BE_CQ_OBJECT *cq_object;
+
+	FUNCTION_ASSERT(pfob);
+
+	cq_object = be_cq_id_to_object(pfob, cq_id);
+
+	if (cq_object) {
+
+		ASSERT(cq_object->callback);
+		cq_object->callback(pfob, cq_object,
+				    cq_object->callback_context);
+
+	} else {
+
+		TRACE(DL_WARN, "cq_id %d not found for delegation", cq_id);
+	}
+
+}
+
+/*!
+
+@brief
+    References the given object. The object is guaranteed to remain active until
+    the reference count drops to zero.
+
+@param
+    cq_object            - CQ handle returned from cq_object_create.
+
+@return
+    returns the current reference count on the object
+
+@note
+    IRQL: any
+
+*/
+u32 be_cq_object_reference(struct BE_CQ_OBJECT *cq_object)
+{
+	CQ_ASSERT(cq_object);
+	return sa_atomic_increment(&cq_object->ref_count);
+}
+
+/*!
+
+@brief
+    Dereferences the given object. The object is guaranteed to
+    remain active until the reference count drops to zero.
+
+@param
+    cq_object            - CQ handle returned from cq_object_create.
+
+@return
+    returns the current reference count on the object
+
+@note
+    IRQL: any
+
+*/
+u32 be_cq_object_dereference(struct BE_CQ_OBJECT *cq_object)
+{
+	CQ_ASSERT(cq_object);
+	return sa_atomic_decrement(&cq_object->ref_count);
+}
+
+/*!
+
+@brief
+    Deferences the given object. Once the object's reference count drops to
+    zero, the object is destroyed and all resources that are held by this object
+    are released.  The on-chip context is also destroyed along with the queue
+    ID, and any mappings made into the UT.
+
+@param
+    cq_object            - CQ handle returned from cq_object_create.
+
+@return
+    returns the current reference count on the object
+
+@note
+    IRQL: IRQL < DISPATCH_LEVEL
+*/
+BESTATUS be_cq_destroy(struct BE_CQ_OBJECT *cq_object)
+{
+	BESTATUS status = 0;
+
+	CQ_ASSERT(cq_object);
+	FUNCTION_ASSERT(cq_object->parent_function);
+
+	/* Nothing should reference this CQ at this point. */
+	ASSERT(cq_object->ref_count == 0);
+
+	/* Send ioctl to destroy the CQ. */
+	status =
+	    be_function_ring_destroy(cq_object->parent_function,
+				     cq_object->cq_id, IOCTL_RING_TYPE_CQ);
+	ASSERT(status == 0);
+
+	/* Remove reference if this is an eventable CQ. */
+	if (cq_object->eq_object)
+		_be_eq_remove_cq(cq_object->eq_object, cq_object);
+
+	/* Remove from the function object. */
+	_be_function_remove_cq(cq_object->parent_function, cq_object);
+
+	/* Zero the software tracking object. */
+	sa_zero_mem(cq_object, sizeof(*cq_object));
+
+	return BE_SUCCESS;
+}
diff --git a/drivers/message/beclib/ethrx_ll.c b/drivers/message/beclib/ethrx_ll.c
new file mode 100644
index 0000000..235c5e8
--- /dev/null
+++ b/drivers/message/beclib/ethrx_ll.c
@@ -0,0 +1,420 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*!
+
+@brief
+    This routine creates a Ethernet receive ring.
+
+@param
+    pfob      - handle to a function object
+@param
+    rq_base_va            - base VA for the default receive ring. this must be
+			exactly 8K in length and continguous physical memory.
+@param
+    cq_object            - handle to a previously created CQ to be associated
+			with the RQ.
+@param
+    pp_eth_rq             - pointer to an opqaue handle where an eth
+			receive object is returned.
+@return
+    BE_SUCCESS if successfull, , otherwise a useful
+    BESTATUS error code is returned.
+@note
+    IRQL: < DISPATCH_LEVEL
+    this function allocates a struct BE_ETHRQ_OBJECT *object.
+    there must be no more than 1 of these per function object, unless the
+    function object supports RSS (is networking and on the host).
+    the rq_base_va must point to a buffer of exactly 8K.
+    the erx::host_cqid (or host_stor_cqid) register and erx::ring_page registers
+    will be updated as appropriate on return
+*/
+BESTATUS
+be_eth_rq_create(struct BE_FUNCTION_OBJECT *pfob,
+			struct SA_SGL *sgl, struct BE_CQ_OBJECT *cq_object,
+			struct BE_CQ_OBJECT *bcmc_cq_object,
+			struct BE_ETHRQ_OBJECT *eth_rq)
+{
+	BESTATUS status = 0;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct IOCTL_COMMON_ETH_RX_CREATE *ioctl = NULL;
+	u32 pd;
+
+	/* MPU will set the  */
+	ASSERT(sgl);
+	ASSERT(eth_rq);
+
+	FUNCTION_ASSERT(pfob);
+	CQ_ASSERT(cq_object);
+
+	be_lock_wrb_post(pfob);
+
+	eth_rq->magic = BE_ETHRQ_MAGIC;
+	eth_rq->parent_function = pfob;
+	eth_rq->cq_object = cq_object;
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_ETH_RX_CREATE);
+
+	ioctl->params.request.num_pages = 2;	/* required length */
+	ioctl->params.request.cq_id = be_cq_get_id(cq_object);
+
+	if (bcmc_cq_object) {
+		/* Only pd 0 host & storage can receive broadcast/multicast. */
+		pd =  be_function_get_pd_number(pfob);
+		if (pd != 0) {
+			TRACE(DL_WARN,
+			      "bcmc_cq_object ignored for pd_number:%d",
+			      be_function_get_pd_number(pfob));
+		}
+		ioctl->params.request.bcmc_cq_id =
+		    be_cq_get_id(bcmc_cq_object);
+	} else {
+		ioctl->params.request.bcmc_cq_id = 0xFFFF;
+	}
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl,
+			  ioctl->params.request.pages,
+			  SA_NUMBER_OF(ioctl->params.request.pages));
+
+	/* Post the Ioctl */
+	status =
+	    be_function_post_mcc_wrb(pfob, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "ioctl to map eth rxq frags failed.");
+		goto Error;
+	}
+	/* Save the ring ID for cleanup. */
+	eth_rq->rid = ioctl->params.response.id;
+
+	be_cq_object_reference(cq_object);
+
+	_be_function_add_eth_rq(pfob, eth_rq);
+
+	TRACE(DL_INFO,
+	      "eth rq created. function:%d pd:%d bytes:%d bcmc_id:%d cq_id:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob),
+	      sa_sgl_get_page_count(sgl) * SA_PAGE_SIZE,
+	      (bcmc_cq_object ? be_cq_get_id(bcmc_cq_object) : -1),
+	      be_cq_get_id(cq_object));
+
+Error:
+
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+
+@brief
+    This routine returns the RID for an Ethernet receive queue
+
+@param
+    EthRq - Ethernet receive queue handle returned from EthRqCreate
+
+@return
+    Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+@note
+    IRQL: <= DISPATCH_LEVEL
+*/
+u32 be_eth_rq_get_id(struct BE_ETHRQ_OBJECT *rq)
+{
+	ETHRQ_ASSERT(rq);
+	return rq->rid;
+}
+
+/*!
+
+@brief
+    This routine destroys an Ethernet receive queue
+
+@param
+    eth_rq - ethernet receive queue handle returned from eth_rq_create
+
+@return
+    Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+@note
+    This function frees resourcs allocated by EthRqCreate.
+    The erx::host_cqid (or host_stor_cqid) register and erx::ring_page registers
+    will be updated as appropriate on return
+    IRQL: < DISPATCH_LEVEL
+*/
+
+static void be_eth_rq_destroy_internal_callback(void *context, BESTATUS status,
+					 struct MCC_WRB_AMAP *wrb)
+{
+	struct BE_ETHRQ_OBJECT *eth_rq = (struct BE_ETHRQ_OBJECT *) context;
+	ETHRQ_ASSERT(eth_rq);
+
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR,
+		      "Destroy eth rq failed in internal callback.\n");
+	} else {
+		/* Dereference any CQs associated with this queue. */
+		be_cq_object_dereference(eth_rq->cq_object);
+
+		/* Remove from the function object. */
+		_be_function_remove_eth_rq(eth_rq->parent_function,
+					   eth_rq);
+	}
+
+	return;
+}
+
+BESTATUS
+be_eth_rq_destroy_async(struct BE_ETHRQ_OBJECT *eth_rq,
+			MCC_WRB_CQE_CALLBACK callback, void *callback_context)
+{
+	BESTATUS status = BE_SUCCESS;
+	ETHRQ_ASSERT(eth_rq);
+
+	/* Send ioctl to destroy the RQ. */
+	status = be_function_ring_destroy_async(eth_rq->parent_function,
+					eth_rq->rid,
+					IOCTL_RING_TYPE_ETH_RX,
+					callback,
+					callback_context,
+					be_eth_rq_destroy_internal_callback,
+					eth_rq);
+
+	return status;
+}
+
+BESTATUS be_eth_rq_destroy(struct BE_ETHRQ_OBJECT *eth_rq)
+{
+	return be_eth_rq_destroy_async(eth_rq, NULL, NULL);
+}
+
+/*
+ *---------------------------------------------------------------------------
+ * Function: be_eth_rq_destroy_options
+ *   Destroys an ethernet receive ring with finer granularity options
+ *   than the standard be_eth_rq_destroy() API function.
+ * eth_rq           -
+ * flush            - Set to 1 to flush the ring, set to 0 to bypass the flush
+ * callback         - Callback function on completion
+ * callback_context - Callback context
+ * return status    - BE_SUCCESS (0) on success. Negative error code on failure.
+ *----------------------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_destroy_options(struct BE_ETHRQ_OBJECT *eth_rq,
+			  bool flush, MCC_WRB_CQE_CALLBACK callback,
+			  void *callback_context)
+{
+	struct IOCTL_COMMON_RING_DESTROY *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = BE_SUCCESS;
+	struct BE_FUNCTION_OBJECT *pfob = NULL;
+
+	ETHRQ_ASSERT(eth_rq);
+
+	pfob = eth_rq->parent_function;
+	FUNCTION_ASSERT(pfob);
+
+	be_lock_wrb_post(pfob);
+
+	TRACE(DL_INFO, "Destroy eth_rq ring id:%d, flush:%d", eth_rq->rid,
+	      flush);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in destroy eth_rq ring.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_RING_DESTROY);
+
+	ioctl->params.request.id = eth_rq->rid;
+	ioctl->params.request.ring_type = IOCTL_RING_TYPE_ETH_RX;
+	ioctl->params.request.bypass_flush = ((0 == flush) ? 1 : 0);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_internal_callback(pfob, wrb,
+			NULL, callback, callback_context,
+			be_eth_rq_destroy_internal_callback, eth_rq, ioctl);
+
+	if (status != BE_SUCCESS && status != BE_PENDING) {
+		TRACE(DL_ERR,
+		      "eth_rq ring destroy ioctl failed. id:%d, flush:%d",
+		      eth_rq->rid, flush);
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+
+@brief
+    This routine queries the frag size for erx.
+
+@param
+    pfob      - handle to a function object
+
+@param
+    frag_size_bytes       - erx frag size in bytes that is/was set.
+
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+    code is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+
+*/
+BESTATUS
+be_eth_rq_get_frag_size(struct BE_FUNCTION_OBJECT *pfob,
+			u32 *frag_size_bytes)
+{
+	struct IOCTL_ETH_GET_RX_FRAG_SIZE *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	ASSERT(frag_size_bytes);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		return BE_STATUS_NO_MCC_WRB;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, ETH_GET_RX_FRAG_SIZE);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL,
+					  NULL,	/* context  */
+					  ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "get frag size ioctl failed.");
+		goto error;
+	}
+
+	*frag_size_bytes =
+	    1 << ioctl->params.response.actual_fragsize_log2;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*!
+
+@brief
+    This routine attempts to set the frag size for erx.  If the frag size is
+    already set, the attempt fails and the current frag size is returned.
+
+@param
+    pfob      - Handle to a function object
+
+@param
+    new_frag_size_bytes       - Erx frag size in bytes that is/was set.
+
+@param
+    current_frag_size_bytes    - Pointer to location where currrent frag
+				 is to be rturned
+
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+    code is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+
+    This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_rq_set_frag_size(struct BE_FUNCTION_OBJECT *pfob,
+			u32 new_frag_size_bytes, u32 *current_frag_size_bytes)
+{
+	struct IOCTL_ETH_SET_RX_FRAG_SIZE *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	ASSERT(current_frag_size_bytes);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, ETH_SET_RX_FRAG_SIZE);
+
+	ASSERT(new_frag_size_bytes >= 128 &&
+	       new_frag_size_bytes <= 16 * 1024);
+
+	/* This is the log2 of the fragsize.  This is not the exact
+	 * ERX encoding. */
+	ioctl->params.request.new_fragsize_log2 =
+	    sa_log2(new_frag_size_bytes);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL,
+					  NULL, ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "set frag size ioctl failed.");
+		goto error;
+	}
+
+	*current_frag_size_bytes =
+			1 << ioctl->params.response.actual_fragsize_log2;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
diff --git a/drivers/message/beclib/ethtx_ll.c b/drivers/message/beclib/ethtx_ll.c
new file mode 100644
index 0000000..735b238
--- /dev/null
+++ b/drivers/message/beclib/ethtx_ll.c
@@ -0,0 +1,553 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_sq_create_ex
+ *   Creates an ethernet send ring - extended version with
+ *   additional parameters.
+ * pfob -
+ * sgl             - no virtual address required
+ * length_in_bytes -
+ * type            - The type of ring to create.
+ * ulp             - The requested ULP number for the ring.
+ * 		     This should be zero based, i.e. 0,1,2. This must
+ * 		     be valid NIC ULP based on the firmware config.
+ *                   All doorbells for this ring must be sent to
+ *                   this ULP. The first network ring allocated for
+ *                   each ULP are higher performance than subsequent rings.
+ * cq_object       - cq object for completions
+ * ex_parameters   - Additional parameters (that may increase in
+ * 		     future revisions). These parameters are only used
+ * 		     for certain ring types -- see
+ *                   struct BE_ETH_SQ_PARAMETERS for details.
+ * eth_sq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create_ex(struct BE_FUNCTION_OBJECT *pfob,
+		    struct SA_SGL *sgl, u32 length, u32 type,
+		    u32 ulp, struct BE_CQ_OBJECT *cq_object,
+		    struct BE_ETH_SQ_PARAMETERS *ex_parameters,
+		    struct BE_ETHSQ_OBJECT *eth_sq)
+{
+	struct IOCTL_COMMON_ETH_TX_CREATE_AMAP *ioctl = NULL;
+	struct BE_IOCTL_COMMON_ETH_TX_CREATE_AMAP *be_ioctl;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct PHYS_ADDR *pa_listp;
+	u32 n, npages;
+
+	ASSERT(sgl);
+	ASSERT(eth_sq);
+	ASSERT(ex_parameters);
+
+	FUNCTION_ASSERT(pfob);
+	be_lock_wrb_post(pfob);
+
+	sa_zero_mem(eth_sq, sizeof(*eth_sq));
+
+	eth_sq->magic = BE_ETHSQ_MAGIC;
+	eth_sq->parent_function = pfob;
+	eth_sq->bid = 0xFFFFFFFF;
+	eth_sq->cq_object = cq_object;
+
+	/* Translate beclib interface to arm interface. */
+	switch (type) {
+	case BE_ETH_TX_RING_TYPE_FORWARDING:
+		type = ETH_TX_RING_TYPE_FORWARDING;
+		break;
+	case BE_ETH_TX_RING_TYPE_STANDARD:
+		type = ETH_TX_RING_TYPE_STANDARD;
+		break;
+	case BE_ETH_TX_RING_TYPE_BOUND:
+		ASSERT(ex_parameters->port < 2);
+		type = ETH_TX_RING_TYPE_BOUND;
+		break;
+	default:
+		TRACE(DL_ERR, "Invalid eth tx ring type:%d", type);
+		return BE_NOT_OK;
+		break;
+	}
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* NIC must be supported by the current config. */
+	ASSERT(pfob->fw_config.nic_ulp_mask);
+
+	/*
+	 * The ulp parameter must select a valid NIC ULP
+	 * for the current config.
+	 */
+	ASSERT((1 << ulp) & pfob->fw_config.nic_ulp_mask);
+
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL_AMAP(pfob, wrb, COMMON_ETH_TX_CREATE);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		header.request.port_number, ioctl, ex_parameters->port);
+
+	n = be_function_get_pd_number(pfob);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.context.pd_id, ioctl, n);
+
+	n = be_ring_length_to_encoding(length, sizeof(struct ETH_WRB_AMAP));
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.context.tx_ring_size, ioctl, n);
+
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.context.cq_id_send, ioctl, cq_object->cq_id);
+
+	n = be_function_get_function_number(pfob);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.context.func, ioctl, n);
+
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.type, ioctl, type);
+
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.ulp_num, ioctl, (1 << ulp));
+
+	n = sa_ceiling(length, SA_PAGE_SIZE);
+	AMAP_SET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+		params.request.num_pages, ioctl, n);
+
+	n = AMAP_WORD_OFFSET(IOCTL_COMMON_ETH_TX_CREATE, params.request.pages);
+	pa_listp = (struct PHYS_ADDR *)((u32 *)ioctl + n);
+	be_ioctl = (struct BE_IOCTL_COMMON_ETH_TX_CREATE_AMAP *)ioctl;
+	npages = SA_NUMBER_OF(be_ioctl->params.request.pages);
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl, pa_listp, npages);
+
+
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create etx queue failed.");
+		goto Error;
+	}
+	/* save the butler ID */
+	eth_sq->bid = AMAP_GET_BITS_PTR(IOCTL_COMMON_ETH_TX_CREATE,
+			params.response.cid, ioctl);
+
+	/* add a reference to the corresponding CQ */
+	be_cq_object_reference(cq_object);
+
+	/* add this object to the function object */
+	_be_function_add_eth_sq(pfob, eth_sq);
+
+	TRACE(DL_INFO,
+	      "eth sq created. function:%d pd:%d bid:%d bytes:%d cq_id:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob), eth_sq->bid,
+				      length, be_cq_get_id(cq_object));
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+
+}
+
+/*!
+
+@brief
+    this routine creates an ethernet send queue
+
+@param
+    pfob      - handle to a function object
+@param
+    send_queue_va         - base VA for a the ethernet send ring
+@param
+    ring_size_power_of_two  - number of entries in the
+				ring (power of two). 32K = 0, 1 = rsvd,
+				2 = 1, 3 = 4 ....
+@param
+    cq_object            - internal CQ handle returned.
+@param
+    pp_eth_sq             - internal eth sq handle returned.
+
+@return
+    BE_SUCCESS if successfull, , otherwise a useful error code is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+    this function allocates an eth_sq object
+
+*/
+BESTATUS be_eth_sq_create(struct BE_FUNCTION_OBJECT *pfob,
+		struct SA_SGL *sgl, u32 length, u32 type,
+		u32 ulp,	/* 0,1,2 ulp id for the request ring */
+		struct BE_CQ_OBJECT *cq_object,
+		struct BE_ETHSQ_OBJECT *eth_sq)
+{
+	struct BE_ETH_SQ_PARAMETERS ex_parameters = { 0 };
+
+	return be_eth_sq_create_ex(pfob, sgl, length, type,
+				   ulp, cq_object, &ex_parameters, eth_sq);
+}
+
+/*!
+
+@brief
+    This routine returns the RID for an Etx SQ
+
+@param
+    EthSq - EthSq Handle returned from EthSqCreate
+
+@return
+    The RID for an Etx SQ
+
+@note
+
+*/
+u32 be_eth_sq_get_id(struct BE_ETHSQ_OBJECT *eth_sq)
+{
+	ETHSQ_ASSERT(eth_sq);
+	return eth_sq->bid;
+}
+
+/*!
+
+@brief
+    This routine destroys an ethernet send queue
+
+@param
+    EthSq - EthSq Handle returned from EthSqCreate
+
+@return
+    This function always return BE_SUCCESS.
+
+@note
+    This function frees memory allocated by EthSqCreate for the EthSq Object.
+
+*/
+BESTATUS be_eth_sq_destroy(struct BE_ETHSQ_OBJECT *eth_sq)
+{
+	BESTATUS status = 0;
+
+	ETHSQ_ASSERT(eth_sq);
+
+	/* Send ioctl to destroy the queue. */
+	status =
+	    be_function_ring_destroy(eth_sq->parent_function, eth_sq->bid,
+				     IOCTL_RING_TYPE_ETH_TX);
+	ASSERT(status == 0);
+
+	/* Derefence any associated CQs. */
+	be_cq_object_dereference(eth_sq->cq_object);
+
+	/* Remove from function */
+	_be_function_remove_eth_sq(eth_sq->parent_function, eth_sq);
+
+	/* Clear tracking object */
+	sa_zero_mem(eth_sq, sizeof(*eth_sq));
+
+	return status;
+}
+
+/*!
+
+@brief
+    This routine attempts to set the transmit flow control parameters.
+
+@param
+    FunctionObject      - Handle to a function object
+
+@param
+    txfc_enable         - transmit flow control enable - true for
+			  enable, false for disable
+
+@param
+    rxfc_enable         - receive flow control enable - true for
+				enable, false for disable
+
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+    code is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+
+    This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_set_flow_control(struct BE_FUNCTION_OBJECT *pfob,
+			bool txfc_enable, bool rxfc_enable)
+{
+	struct IOCTL_COMMON_SET_FLOW_CONTROL *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_SET_FLOW_CONTROL);
+
+	ioctl->params.request.rx_flow_control = rxfc_enable;
+	ioctl->params.request.tx_flow_control = txfc_enable;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL,
+					  NULL, ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "set flow control ioctl failed.");
+		goto error;
+	}
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*!
+
+@brief
+    This routine attempts to get the transmit flow control parameters.
+
+@param
+    pfob      - Handle to a function object
+
+@param
+    txfc_enable         - transmit flow control enable - true for
+			enable, false for disable
+
+@param
+    rxfc_enable         - receive flow control enable - true for enable,
+			false for disable
+
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS error code
+			is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+
+    This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_get_flow_control(struct BE_FUNCTION_OBJECT *pfob,
+			bool *txfc_enable, bool *rxfc_enable)
+{
+	struct IOCTL_COMMON_GET_FLOW_CONTROL *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_GET_FLOW_CONTROL);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "get flow control ioctl failed.");
+		goto error;
+	}
+
+	*txfc_enable = ioctl->params.response.tx_flow_control;
+	*rxfc_enable = ioctl->params.response.rx_flow_control;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_set_qos
+ *   This function sets the ethernet transmit Quality of Service (QoS)
+ *   characteristics of BladeEngine for the domain. All ethernet
+ *   transmit rings of the domain will evenly share the bandwidth.
+ *   The exeception to sharing is the host primary (super) ethernet
+ *   transmit ring as well as the host ethernet forwarding ring
+ *   for missed offload data.
+ * pfob -
+ * max_bps         - the maximum bits per second in units of
+ * 			10 Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units
+ * 			of 1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_qos(struct BE_FUNCTION_OBJECT *pfob, u32 max_bps, u32 max_pps)
+{
+	struct IOCTL_COMMON_SET_QOS *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_SET_QOS);
+
+	/* Set fields in ioctl */
+	ioctl->params.request.max_bits_per_second_NIC = max_bps;
+	ioctl->params.request.max_packets_per_second_NIC = max_pps;
+	ioctl->params.request.valid_flags = QOS_BITS_NIC | QOS_PKTS_NIC;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL,
+					  NULL, ioctl);
+
+	if (status != 0)
+		TRACE(DL_ERR, "network set qos ioctl failed.");
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_get_qos
+ *   This function retrieves the ethernet transmit Quality of Service (QoS)
+ *   characteristics for the domain.
+ * pfob -
+ * max_bps         - the maximum bits per second in units of
+ * 			10 Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units of
+ * 			1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_qos(struct BE_FUNCTION_OBJECT *pfob, u32 *max_bps, u32 *max_pps)
+{
+	struct IOCTL_COMMON_GET_QOS *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_GET_QOS);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "network get qos ioctl failed.");
+		goto error;
+	}
+
+	*max_bps = ioctl->params.response.max_bits_per_second_NIC;
+	*max_pps = ioctl->params.response.max_packets_per_second_NIC;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*
+ *---------------------------------------------------------
+ * Function: be_eth_set_frame_size
+ *   This function sets the ethernet maximum frame size. The previous
+ *   values are returned.
+ * pfob -
+ * tx_frame_size   - maximum transmit frame size in bytes
+ * rx_frame_size   - maximum receive frame size in bytes
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_frame_size(struct BE_FUNCTION_OBJECT *pfob,
+		      u32 *tx_frame_size, u32 *rx_frame_size)
+{
+	struct IOCTL_COMMON_SET_FRAME_SIZE *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_SET_FRAME_SIZE);
+	ioctl->params.request.max_tx_frame_size = *tx_frame_size;
+	ioctl->params.request.max_rx_frame_size = *rx_frame_size;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "network set frame size ioctl failed.");
+		goto error;
+	}
+
+	*tx_frame_size = ioctl->params.response.chip_max_tx_frame_size;
+	*rx_frame_size = ioctl->params.response.chip_max_rx_frame_size;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
diff --git a/drivers/message/beclib/rxf_ll.c b/drivers/message/beclib/rxf_ll.c
new file mode 100644
index 0000000..e94e1ba
--- /dev/null
+++ b/drivers/message/beclib/rxf_ll.c
@@ -0,0 +1,951 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#include "pch.h"
+
+/*!
+
+@brief
+    This routine adds, removes, or reads a WoL magic packet.
+
+@param
+    FunctionObject  - Function object handle.
+
+@param
+    Mac1            - Set to TRUE if this function will operate on
+			the MAC 1 Magic Packet.
+
+@param
+    Operation       - Operation to perform.
+
+@param
+    Pattern         - Pattern to set, or the pattern returned.
+
+@param
+    PatternMask     - Pattern mask to set, or the pattern mask returned.
+
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+
+*/
+BESTATUS be_rxf_wake_on_lan_config(struct BE_FUNCTION_OBJECT *pfob,
+	bool enable_port0, bool enable_port1,
+	bool magic_packet_enable, u32 index,
+	void *pattern, void *pattern_mask,
+	MCC_WRB_CQE_CALLBACK callback,
+	void *callback_context,
+	struct BE_WAKE_ON_LAN_QUEUE_CONTEXT *queue_context)
+{
+	struct IOCTL_ETH_ACPI_CONFIG *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = BE_SUCCESS;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	FUNCTION_ASSERT(pfob);
+
+	/* Valid range for index is 0-3. */
+	ASSERT(index < 4);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, ETH_ACPI_CONFIG);
+
+	ioctl->params.request.index = index;
+	ioctl->params.request.port0 = enable_port0;
+	ioctl->params.request.port1 = enable_port1;
+	ioctl->params.request.magic_packet = magic_packet_enable;
+
+	if (enable_port0 || enable_port1) {
+		if (pattern) {
+			sa_memcpy(ioctl->params.request.byte_pattern,
+				  pattern,
+				  sizeof(ioctl->params.request.
+					 byte_pattern));
+		}
+		if (pattern_mask) {
+			sa_memcpy(ioctl->params.request.bit_mask,
+				  pattern_mask,
+				  sizeof(ioctl->params.request.bit_mask));
+		}
+		/* Track which indicies are enabled/disabled */
+		pfob->config.wol_bitmask |= (1 << index);
+	} else {
+
+		/* Track which indicies are enabled/disabled */
+		pfob->config.wol_bitmask &= ~(1 << index);
+	}
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+					wrb, generic_context,
+					callback, callback_context, ioctl);
+
+	if (status < 0) {
+		TRACE(DL_ERR, "wake-on-lan ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+@brief
+    This routine gets or sets a mac address for a domain
+    given the port and mac.
+@param
+    FunctionObject  - Function object handle.
+@param
+    Port1           - Set to TRUE if this function will set/get the Port 1
+			address.  Only the host may set this to TRUE.
+@param
+    Mac1            - Set to TRUE if this function will set/get the
+			MAC 1 address.  Only the host may set this to TRUE.
+@param
+    Write           - Set to TRUE if this function should write the mac address.
+@param
+    MacAddress      - Buffer of the mac address to read or write.
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+@note
+    IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_mac_address_read_write(struct BE_FUNCTION_OBJECT *pfob,
+		bool port1,	/* VM must always set to false */
+		bool mac1,	/* VM must always set to false */
+		bool mgmt, bool write,
+		bool permanent, struct SA_MAC_ADDRESS *mac_address,
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context)	/* optional */
+{
+	BESTATUS status = BE_SUCCESS;
+	union {
+		struct IOCTL_COMMON_NTWK_MAC_QUERY *query;
+		struct IOCTL_COMMON_NTWK_MAC_SET *set;
+	} ioctl = {0};
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 type = 0;
+
+	FUNCTION_ASSERT(pfob);
+
+	be_lock_wrb_post(pfob);
+
+	ASSERT(mac_address);
+
+	ASSERT(port1 == FALSE
+	       || be_function_is_vm(pfob) == FALSE);
+	ASSERT(mac1 == FALSE
+	       || be_function_is_vm(pfob) == FALSE);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+
+	if (mgmt) {
+		type = MAC_ADDRESS_TYPE_MANAGEMENT;
+	} else if (be_function_is_vm(pfob) &&
+			be_function_is_networking(pfob)) {
+		type = MAC_ADDRESS_TYPE_PD;
+	} else {
+		if (be_function_is_networking(pfob))
+			type = MAC_ADDRESS_TYPE_NETWORK;
+		else
+			type = MAC_ADDRESS_TYPE_STORAGE;
+	}
+
+	if (write) {
+		/* Prepares an embedded ioctl, including
+		 * request/response sizes.
+		 */
+		ioctl.set = BE_PREPARE_EMBEDDED_IOCTL(pfob,
+					       wrb, COMMON_NTWK_MAC_SET);
+
+		ioctl.set->params.request.invalidate = 0;
+		ioctl.set->params.request.mac1 = (mac1 ? 1 : 0);
+		ioctl.set->params.request.port = (port1 ? 1 : 0);
+		ioctl.set->params.request.type = type;
+
+		/* Copy the mac address to set. */
+		ioctl.set->params.request.mac.SizeOfStructure =
+		    sizeof(ioctl.set->params.request.mac);
+		sa_memcpy(ioctl.set->params.request.mac.MACAddress,
+			  mac_address, sizeof(*mac_address));
+
+		/* Post the Ioctl */
+		status = be_function_post_mcc_wrb(pfob,
+						  wrb,
+						  callback,
+						  callback_context,
+						  ioctl.set);
+
+	} else {
+
+		/*
+		 * Prepares an embedded ioctl, including
+		 * request/response sizes.
+		 */
+		ioctl.query = BE_PREPARE_EMBEDDED_IOCTL(pfob,
+					       wrb, COMMON_NTWK_MAC_QUERY);
+
+		ioctl.query->params.request.mac1 = (mac1 ? 1 : 0);
+		ioctl.query->params.request.port = (port1 ? 1 : 0);
+		ioctl.query->params.request.type = type;
+		ioctl.query->params.request.permanent = permanent;
+
+		/* Post the Ioctl (with a copy for the response) */
+		status = be_function_post_mcc_wrb_with_copy(pfob,
+			wrb, NULL,	/* queue context */
+			callback, callback_context, ioctl.query,
+			BE_CREATE_MCC_RESPONSE_COPY(IOCTL_COMMON_NTWK_MAC_QUERY,
+				params.response.mac.MACAddress, mac_address));
+	}
+
+	if (status < 0) {
+		TRACE(DL_ERR, "mac set/query failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+@brief
+    This routine writes data to context memory.
+@param
+    FunctionObject  - Function object handle.
+@param
+    McHashTable     - Set to the 128-bit multicast address hash table.
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+@note
+    IRQL: < DISPATCH_LEVEL
+*/
+
+BESTATUS be_rxf_multicast_config(struct BE_FUNCTION_OBJECT *pfob,
+		bool promiscuous, u32 num, struct SA_MAC_ADDRESS *mac_table,
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context,
+		struct BE_MULTICAST_QUEUE_CONTEXT *queue_context)
+{
+	BESTATUS status = BE_SUCCESS;
+	struct IOCTL_COMMON_NTWK_MULTICAST_SET *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	FUNCTION_ASSERT(pfob);
+	ASSERT(num <=
+	       SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_MULTICAST_SET,
+				  params.request.mac));
+
+	if (num > SA_NUMBER_OF_FIELD(
+			IOCTL_COMMON_NTWK_MULTICAST_SET, params.request.mac)) {
+		TRACE(DL_ERR, "Too many multicast addresses. BE supports %d.",
+		      SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_MULTICAST_SET,
+					 params.request.mac));
+		return BE_NOT_OK;
+	}
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+								queue_context;
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_NTWK_MULTICAST_SET);
+
+	TRACE(DL_INFO,
+	      "multicast config. function:%d promiscuous:%d num:%d",
+	      be_function_get_function_number(pfob),
+	      promiscuous, num);
+
+	ioctl->params.request.promiscuous = promiscuous;
+	if (!promiscuous) {
+
+		ioctl->params.request.num_mac = num;
+
+		if (num > 0) {
+			u32 i = 0;
+
+			ASSERT(mac_table);
+			sa_memcpy(ioctl->params.request.mac, mac_table,
+				  6 * num);
+			for (i = 0; i < num; i++) {
+				TRACE(DL_VERBOSE, " multicast address[%d]: "
+				      "%02x:%02x:%02x:%02x:%02x:%02x", i,
+					(u32)mac_table[i].bytes[0],
+					(u32)mac_table[i].bytes[1],
+					(u32)mac_table[i].bytes[2],
+					(u32)mac_table[i].bytes[3],
+					(u32)mac_table[i].bytes[4],
+					(u32)mac_table[i].bytes[5]);
+			}
+		}
+		/* track number of addresses */
+		pfob->config.num_multicast = num;
+	} else {
+		/* track number of addresses */
+		pfob->config.num_multicast = 0xFF;	/* infinite */
+	}
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+				wrb, generic_context, callback,
+				callback_context, ioctl);
+	if (status < 0) {
+		TRACE(DL_ERR, "multicast ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+@brief
+    This routine adds or removes a vlan tag from the rxf table.
+@param
+    FunctionObject  - Function object handle.
+@param
+    VLanTag         - VLan tag to add or remove.
+@param
+    Add             - Set to TRUE if this will add a vlan tag
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+@note
+    IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_vlan_config(struct BE_FUNCTION_OBJECT *pfob,
+		bool promiscuous, u32 num, u16 *vlan_tag_array,
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context,
+		struct BE_VLAN_QUEUE_CONTEXT *queue_context)	/* optional */
+{
+	BESTATUS status = BE_SUCCESS;
+	struct IOCTL_COMMON_NTWK_VLAN_CONFIG *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	FUNCTION_ASSERT(pfob);
+
+	if (num > SA_NUMBER_OF_FIELD(IOCTL_COMMON_NTWK_VLAN_CONFIG,
+					       params.request.vlan_tag)) {
+		TRACE(DL_ERR, "Too many VLAN tags.");
+		return BE_NOT_OK;
+	}
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+					queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_NTWK_VLAN_CONFIG);
+
+	TRACE(DL_INFO, "vlan config. function:%d promiscuous:%d num:%d",
+	      be_function_get_function_number(pfob), promiscuous, num);
+
+	ioctl->params.request.promiscuous = promiscuous;
+	if (!promiscuous) {
+
+		ioctl->params.request.num_vlan = num;
+
+		if (num > 0) {
+			ASSERT(vlan_tag_array);
+			sa_memcpy(ioctl->params.request.vlan_tag,
+				  vlan_tag_array,
+				  num * sizeof(vlan_tag_array[0]));
+		}
+		/* Track number of tags */
+		pfob->config.num_vlan = num;
+
+	} else {
+		/* promiscuous mode, tracking number is set inifinite */
+		pfob->config.num_vlan = 0xFF;
+	}
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+					wrb, generic_context, callback,
+					callback_context, ioctl);
+	if (status < 0) {
+		TRACE(DL_ERR, "vlan ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*!
+@brief
+    This routine assigns a CPU number to an RSS table.
+@param
+    FunctionObject      - Function object handle.
+@param
+    RssEntry            - The RSS entry (bucket) to assign this CPU to.
+@param
+    Cpu                 - The CPU number that incomming packets that hash to
+			the RssEntry bucket index will be directed to.
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+@note
+    IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_rss_config(struct BE_FUNCTION_OBJECT *pfob,
+		u32 rss_type,	/* use enumeration ENABLE_RSS_ENUM */
+		u32 num_cq,	/* 2, 3, or 4 */
+		u32 *cq_id_array,	/* Array of num_cq id values */
+		u32 default_cq_id,	/* non-RSS default CQ ID */
+		u32 flush_mask,	/* mask of CQs to flush */
+		void *hash,	/* 16 bytes */
+		u32 cpu_table_length, /* bytes (power of 2 from 2 to 128) */
+		u8 *cpu_table,	/* 2 to 128 bytes */
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context,
+		struct BE_RSS_QUEUE_CONTEXT *queue_context)	/* optional */
+{
+	BESTATUS status = BE_SUCCESS;
+	struct IOCTL_ETH_RSS_CONFIG *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	FUNCTION_ASSERT(pfob);
+
+	be_lock_wrb_post(pfob);
+
+	ASSERT(!be_function_is_vm(pfob));
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, ETH_RSS_CONFIG);
+
+	ioctl->params.request.enable_rss = rss_type;
+	ioctl->params.request.cq_flush_mask = flush_mask;
+
+	if (cq_id_array) {
+		ioctl->params.request.cqid0 = cq_id_array[0];
+		ioctl->params.request.cqid1 = cq_id_array[1];
+		ioctl->params.request.cqid2 = cq_id_array[2];
+		ioctl->params.request.cqid3 = cq_id_array[3];
+	}
+
+	if (rss_type != RSS_ENABLE_NONE) {
+		ASSERT(num_cq >= 1 && num_cq <= 4);
+		ASSERT(cq_id_array);
+		ASSERT(hash);
+	}
+
+	if (hash) {
+		sa_memcpy(ioctl->params.request.hash, hash,
+			  sizeof(ioctl->params.request.hash));
+	}
+	/*
+	 * Double check the table.  Each entry should be 0 to
+	 * num_cq-1 corresponding to the index in the cq_id_array to use.
+	 */
+	if (cpu_table_length > 0) {
+
+		ASSERT(cpu_table);
+		ASSERT(cpu_table_length <=
+		       sizeof(ioctl->params.request.cpu_table));
+
+		ioctl->params.request.cpu_table_size_log2 =
+		    sa_log2(cpu_table_length);
+		ASSERT(ioctl->params.request.cpu_table_size_log2 > 0
+		       && ioctl->params.request.cpu_table_size_log2 <= 7);
+
+		sa_memcpy(ioctl->params.request.cpu_table, cpu_table,
+			  cpu_table_length);
+	}
+
+	TRACE(DL_INFO, "RSS hash. 0x%08x 0x%08x 0x%08x 0x%08x",
+	      ioctl->params.request.hash[0],
+	      ioctl->params.request.hash[1],
+	      ioctl->params.request.hash[2],
+	      ioctl->params.request.hash[3]);
+
+	TRACE(DL_INFO,
+	      "RSS table. log2(len):%d 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x"
+	      " 0x%02x 0x%02x 0x%02x",
+	      ioctl->params.request.cpu_table_size_log2,
+	      ioctl->params.request.cpu_table[0],
+	      ioctl->params.request.cpu_table[1],
+	      ioctl->params.request.cpu_table[2],
+	      ioctl->params.request.cpu_table[3],
+	      ioctl->params.request.cpu_table[4],
+	      ioctl->params.request.cpu_table[5],
+	      ioctl->params.request.cpu_table[6],
+	      ioctl->params.request.cpu_table[7]);
+
+	/* software tracking */
+	pfob->config.rss_type = rss_type;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+				wrb, generic_context, callback,
+				callback_context, ioctl);
+	if (status < 0) {
+		TRACE(DL_ERR, "rss ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS be_rxf_link_status(struct BE_FUNCTION_OBJECT *pfob,
+		struct BE_LINK_STATUS *link_status,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct BE_LINK_STATUS_QUEUE_CONTEXT *queue_context)
+{
+	struct IOCTL_COMMON_NTWK_LINK_STATUS_QUERY *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	ASSERT(link_status);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb,
+					       COMMON_NTWK_LINK_STATUS_QUERY);
+
+	/* Post or queue the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(pfob, wrb,
+		generic_context,	/* Queue context */
+		callback, callback_context, ioctl,
+		BE_CREATE_MCC_RESPONSE_COPY(IOCTL_COMMON_NTWK_LINK_STATUS_QUERY,
+					params.response, link_status));
+
+	if (status < 0) {
+		TRACE(DL_ERR, "link status ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS
+be_rxf_query_eth_statistics(struct BE_FUNCTION_OBJECT *pfob,
+		    struct IOCTL_ETH_GET_STATISTICS *va_for_ioctl,
+		    u64 pa_for_ioctl, MCC_WRB_CQE_CALLBACK callback,
+		    void *callback_context,
+		    struct BE_NONEMBEDDED_QUEUE_CONTEXT *queue_context)
+{
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	ASSERT(va_for_ioctl);
+	ASSERT(pa_for_ioctl);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+
+	TRACE(DL_INFO,
+	      "Query eth stats. ioctl va:%p pa:0x%08x_%08x",
+	      va_for_ioctl, sa_hi(pa_for_ioctl), sa_lo(pa_for_ioctl));
+
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	va_for_ioctl = BE_PREPARE_NONEMBEDDED_IOCTL(pfob, wrb,
+			  va_for_ioctl, pa_for_ioctl, ETH_GET_STATISTICS);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+			wrb, generic_context, callback, callback_context,
+					va_for_ioctl);
+	if (status < 0) {
+		TRACE(DL_ERR, "eth stats ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS
+be_rxf_promiscuous(struct BE_FUNCTION_OBJECT *pfob,
+		   bool enable_port0, bool enable_port1,
+		   MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		   struct BE_PROMISCUOUS_QUEUE_CONTEXT *queue_context)
+{
+	struct IOCTL_ETH_PROMISCUOUS *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, ETH_PROMISCUOUS);
+
+	ioctl->params.request.port0_promiscuous = enable_port0;
+	ioctl->params.request.port1_promiscuous = enable_port1;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+			wrb, generic_context, callback, callback_context,
+			ioctl);
+
+	if (status < 0) {
+		TRACE(DL_ERR, "promiscuous ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+ *------------------------------------------------------------------
+ * Function: be_rxf_force_failover
+ *   Forces failure of all traffic to the specified MAC port.
+ *   Use the be_rxf_link_status to query to active port. Automatic
+ *   failover feature of BladeEngine is implicitly disabled with this call.
+ * pfob    -
+ * port               - Port to use, 0 or 1.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			BE_QUEUE_CONTEXT struct. If the MCC WRB ring is
+ * 			full, this structure is used to queue the operation.
+ * 			It will be posted to the MCC ring when space
+ * 			becomes available. All queued commands will be
+ * 			posted to the ring in the order they are received.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *--------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_force_failover(struct BE_FUNCTION_OBJECT *pfob,
+		      u32 port, MCC_WRB_CQE_CALLBACK callback,
+		      void *callback_context,
+		      struct BE_FORCE_FAILOVER_QUEUE_CONTEXT *queue_context)
+{
+	struct IOCTL_COMMON_FORCE_FAILOVER *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_FORCE_FAILOVER);
+
+	ASSERT(port == 0 || port == 1);
+	ioctl->params.request.move_to_port = port;
+	ioctl->params.request.failover_config = FAILOVER_CONFIG_OFF;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+					wrb, generic_context, callback,
+					callback_context, ioctl);
+
+	if (status < 0) {
+		TRACE(DL_ERR, "force failover ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+ *--------------------------------------------------------------------------
+ * Function: be_rxf_manage_autofailover
+ *   Enables or disables BladeEngine automatic port failover.
+ * pfob    -
+ * enable             - Set to 1 to enable the feature. Set to 0 to disable
+ * 			the feature.
+ * callback           - Optional callback function. When the command
+ * 			completes the callback function will be called
+ * 			with the callback context.
+ * callback_context   - Optional callback context.
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			BE_QUEUE_CONTEXT struct. If the MCC WRB ring is full,
+ * 			this structure is used to queue the operation. It
+ * 			will be posted to the MCC ring when space
+ *                      becomes available. All queued commands will
+ *                      be posted to the ring in the order they are received.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *-----------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_manage_autofailover(struct BE_FUNCTION_OBJECT *pfob,
+	bool enable, MCC_WRB_CQE_CALLBACK callback,
+	void *callback_context,
+	struct BE_FORCE_FAILOVER_QUEUE_CONTEXT *queue_context)
+{
+	struct IOCTL_COMMON_FORCE_FAILOVER *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_FORCE_FAILOVER);
+
+	if (enable) {
+		ioctl->params.request.failover_config = FAILOVER_CONFIG_ON;
+	} else {
+		ioctl->params.request.failover_config =
+		    FAILOVER_CONFIG_OFF;
+	}
+	ioctl->params.request.move_to_port = FAILOVER_PORT_NONE;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+					wrb, generic_context, callback,
+					callback_context, ioctl);
+
+	if (status < 0) {
+		TRACE(DL_ERR, "manage autofailover ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+ *-------------------------------------------------------------------------
+ * Function: be_rxf_filter_config
+ *   Configures BladeEngine ethernet receive filter settings.
+ * pfob    -
+ * settings           - Pointer to the requested filter settings.
+ * 			The response from BladeEngine will be placed back
+ * 			in this structure.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is
+ * 			used to queue the operation. It will be posted
+ * 			to the MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring in
+ *                      the order they are received. It is always valid
+ *                      to pass a pointer to a generic
+ *                      BE_GENERIC_QUEUE_CONTEXT. However, the specific
+ *                      context structs are generally smaller than
+ *                      the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_filter_config(struct BE_FUNCTION_OBJECT *pfob,
+		     struct NTWK_RX_FILTER_SETTINGS *settings,
+		     MCC_WRB_CQE_CALLBACK callback,
+		     void *callback_context,
+		     struct BE_RXF_FILTER_QUEUE_CONTEXT *queue_context)
+{
+	struct IOCTL_COMMON_NTWK_RX_FILTER *ioctl = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct BE_GENERIC_QUEUE_CONTEXT *generic_context = NULL;
+
+	ASSERT(settings);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct BE_GENERIC_QUEUE_CONTEXT *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_PREPARE_EMBEDDED_IOCTL(pfob, wrb, COMMON_NTWK_RX_FILTER);
+	sa_memcpy(&ioctl->params.request, settings, sizeof(*settings));
+
+	/* Post or queue the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(pfob,
+			wrb, generic_context,	/* Queue context */
+			callback, callback_context, ioctl,
+			BE_CREATE_MCC_RESPONSE_COPY(IOCTL_COMMON_NTWK_RX_FILTER,
+				params.response, settings));
+
+	if (status < 0) {
+		TRACE(DL_ERR, "RXF/ERX filter config ioctl failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

