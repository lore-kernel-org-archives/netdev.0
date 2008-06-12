From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 8/12] benet: beclib functions
Date: Thu, 12 Jun 2008 03:45:45 -0700
Message-ID: <20080612104545.305dba05@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:18553 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859AbYFLKpu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:45:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/cq_ll.c    |  302 ++++++++++++++++++
 drivers/message/beclib/ethrx_ll.c |  356 +++++++++++++++++++++
 drivers/message/beclib/ethtx_ll.c |  479 ++++++++++++++++++++++++++++
 drivers/message/beclib/rxf_ll.c   |  620 +++++++++++++++++++++++++++++++++++++
 4 files changed, 1757 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/cq_ll.c
 create mode 100644 drivers/message/beclib/ethrx_ll.c
 create mode 100644 drivers/message/beclib/ethtx_ll.c
 create mode 100644 drivers/message/beclib/rxf_ll.c

diff --git a/drivers/message/beclib/cq_ll.c b/drivers/message/beclib/cq_ll.c
new file mode 100644
index 0000000..ac9980a
--- /dev/null
+++ b/drivers/message/beclib/cq_ll.c
@@ -0,0 +1,302 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+#include "pch.h"
+
+/*
+ * Completion Queue Objects
+ */
+
+/*
+    This routines searches for a CqId that is bound to a
+    specified function object.
+
+    pfob  - function object the CQ should be bound to.
+    cq_id            - cq_id to find
+
+    Returns  pointer to the CQ_OBJECT that represents this cq_id.
+	NULL if not found
+
+    IRQL: <= DISPATCH_LEVEL
+*/
+static inline struct be_cq_object *
+be_cq_id_to_object(struct be_function_object *pfob, u32 cq_id)
+{
+	struct be_cq_object *cq_cur;
+	struct be_cq_object *cq_ret = NULL;
+	u32 cid;
+
+	_be_function_lock(pfob);
+
+	list_for_each_entry(cq_cur, &pfob->links.cq_list_head, cq_list) {
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
+/*
+    This routine creates a completion queue based on the client completion
+    queue configuration information.
+
+
+    FunctionObject      - Handle to a function object
+    CqBaseVa            - Base VA for a the CQ ring
+    NumEntries          - CEV_CQ_CNT_* values
+    solEventEnable      - 0 = All CQEs can generate Events if CQ is eventable
+			1 = only CQEs with solicited bit set are eventable
+    eventable           - Eventable CQ, generates interrupts.
+    nodelay             - 1 = Force interrupt, relevent if CQ eventable.
+			Interrupt is asserted immediately after EQE
+			write is confirmed, regardless of EQ Timer
+			or watermark settings.
+    wme                 - Enable watermark based coalescing
+    wmThresh            - High watermark(CQ fullness at which event
+			or interrupt should be asserted).  These are the
+			CEV_WATERMARK encoded values.
+    EqObject            - EQ Handle to assign to this CQ
+    ppCqObject          - Internal CQ Handle returned.
+
+    Returns BE_SUCCESS if successfull, otherwise a useful error code is
+	returned.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+BESTATUS be_cq_create(struct be_function_object *pfob,
+	struct sa_sgl *sgl, u32 length, bool solicited_eventable,
+	bool no_delay, u32 wm_thresh,
+	struct be_eq_object *eq_object, struct be_cq_object *cq_object)
+{
+	BESTATUS status = BE_SUCCESS;
+	u32 num_entries_encoding;
+	u32 num_entries = length / sizeof(struct MCC_CQ_ENTRY_AMAP);
+	struct FWCMD_COMMON_CQ_CREATE *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 n;
+
+	ASSERT(sgl);
+	ASSERT(cq_object);
+	ASSERT(length % sizeof(struct MCC_CQ_ENTRY_AMAP) == 0);
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
+	memset(cq_object, 0, sizeof(*cq_object));
+
+	atomic_set(&cq_object->ref_count, 0);
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_CQ_CREATE);
+
+	fwcmd->params.request.num_pages =
+	    SA_PAGES_SPANNED(sa_sgl_get_offset(sgl), length);
+
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, valid, &fwcmd->params.request.context, 1);
+	n = be_function_get_function_number(pfob);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, Func, &fwcmd->params.request.context, n);
+
+	n = (eq_object != NULL);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, Eventable,
+				&fwcmd->params.request.context, n);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, Armed, &fwcmd->params.request.context, 1);
+
+	n = eq_object ? eq_object->eq_id : 0;
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, EQID, &fwcmd->params.request.context, n);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, Count,
+			&fwcmd->params.request.context, num_entries_encoding);
+
+	n = be_function_get_pd_number(pfob);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, PD, &fwcmd->params.request.context, n);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, NoDelay,
+				&fwcmd->params.request.context, no_delay);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, SolEvent,
+			&fwcmd->params.request.context, solicited_eventable);
+
+	n = (wm_thresh != 0xFFFFFFFF);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, WME, &fwcmd->params.request.context, n);
+
+	n = (n ? wm_thresh : 0);
+	AMAP_SET_BITS_PTR(CQ_CONTEXT, Watermark,
+				&fwcmd->params.request.context, n);
+	/* Create a page list for the FWCMD. */
+	be_sgl_to_pa_list(sgl, fwcmd->params.request.pages,
+			  ARRAY_SIZE(fwcmd->params.request.pages));
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create CQ failed.");
+		goto Error;
+	}
+	/* Remember the CQ id. */
+	cq_object->cq_id = fwcmd->params.response.cq_id;
+
+	/* insert this cq into eq_object reference */
+	if (eq_object)
+		_be_eq_add_cq(eq_object, cq_object);
+
+	/* insert this cq into function_object */
+	_be_function_add_cq(pfob, cq_object);
+	TRACE(DL_INFO,
+	      "cq created. function:%d pd:%d cqid:%d bytes:%d eqid:%d"
+	      " se:%d nd:%d wm:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob), cq_object->cq_id,
+	      num_entries * sizeof(struct MCC_CQ_ENTRY_AMAP),
+	      eq_object ? be_eq_get_id(eq_object) : -1,
+	      (u32) solicited_eventable, (u32) no_delay, wm_thresh);
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+    Returns the CQ ID for CQ. This is the ID the chip references the queue as.
+
+    cq_object            - CQ handle returned from cq_object_create.
+
+    Returns CQ ID
+
+    IRQL: any
+
+*/
+u32 be_cq_get_id(struct be_cq_object *cq_object)
+{
+	return cq_object->cq_id;
+}
+
+/*
+    References the given object. The object is guaranteed to remain active until
+    the reference count drops to zero.
+
+    cq_object            - CQ handle returned from cq_object_create.
+
+    returns the current reference count on the object
+
+    IRQL: any
+
+*/
+void be_cq_object_reference(struct be_cq_object *cq_object)
+{
+	atomic_inc(&cq_object->ref_count);
+}
+
+/*
+
+    Dereferences the given object. The object is guaranteed to
+    remain active until the reference count drops to zero.
+
+    cq_object            - CQ handle returned from cq_object_create.
+
+    returns the current reference count on the object
+
+    IRQL: any
+
+*/
+void be_cq_object_dereference(struct be_cq_object *cq_object)
+{
+	atomic_dec(&cq_object->ref_count);
+}
+
+/*
+
+    Deferences the given object. Once the object's reference count drops to
+    zero, the object is destroyed and all resources that are held by this object
+    are released.  The on-chip context is also destroyed along with the queue
+    ID, and any mappings made into the UT.
+
+    cq_object            - CQ handle returned from cq_object_create.
+
+    returns the current reference count on the object
+
+    IRQL: IRQL < DISPATCH_LEVEL
+*/
+BESTATUS be_cq_destroy(struct be_cq_object *cq_object)
+{
+	BESTATUS status = 0;
+
+	/* Nothing should reference this CQ at this point. */
+	ASSERT(cq_object->ref_count == 0);
+
+	/* Send fwcmd to destroy the CQ. */
+	status =
+	    be_function_ring_destroy(cq_object->parent_function,
+				     cq_object->cq_id, FWCMD_RING_TYPE_CQ);
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
+	memset(cq_object, 0, sizeof(*cq_object));
+
+	return BE_SUCCESS;
+}
diff --git a/drivers/message/beclib/ethrx_ll.c b/drivers/message/beclib/ethrx_ll.c
new file mode 100644
index 0000000..53b9f44
--- /dev/null
+++ b/drivers/message/beclib/ethrx_ll.c
@@ -0,0 +1,356 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+#include "pch.h"
+
+/*
+    This routine creates a Ethernet receive ring.
+
+    pfob      - handle to a function object
+    rq_base_va            - base VA for the default receive ring. this must be
+			exactly 8K in length and continguous physical memory.
+    cq_object            - handle to a previously created CQ to be associated
+			with the RQ.
+    pp_eth_rq             - pointer to an opqaue handle where an eth
+			receive object is returned.
+    Returns BE_SUCCESS if successfull, , otherwise a useful
+    BESTATUS error code is returned.
+
+    IRQL: < DISPATCH_LEVEL
+    this function allocates a struct be_ethrq_object *object.
+    there must be no more than 1 of these per function object, unless the
+    function object supports RSS (is networking and on the host).
+    the rq_base_va must point to a buffer of exactly 8K.
+    the erx::host_cqid (or host_stor_cqid) register and erx::ring_page registers
+    will be updated as appropriate on return
+*/
+BESTATUS
+be_eth_rq_create(struct be_function_object *pfob,
+			struct sa_sgl *sgl, struct be_cq_object *cq_object,
+			struct be_cq_object *bcmc_cq_object,
+			struct be_ethrq_object *eth_rq)
+{
+	BESTATUS status = 0;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct FWCMD_COMMON_ETH_RX_CREATE *fwcmd = NULL;
+	u32 pd;
+
+	/* MPU will set the  */
+	ASSERT(sgl);
+	ASSERT(eth_rq);
+
+	be_lock_wrb_post(pfob);
+
+	eth_rq->parent_function = pfob;
+	eth_rq->cq_object = cq_object;
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_ETH_RX_CREATE);
+
+	fwcmd->params.request.num_pages = 2;	/* required length */
+	fwcmd->params.request.cq_id = be_cq_get_id(cq_object);
+
+	if (bcmc_cq_object) {
+		/* Only pd 0 host & storage can receive broadcast/multicast. */
+		pd =  be_function_get_pd_number(pfob);
+		if (pd != 0) {
+			TRACE(DL_WARN,
+			      "bcmc_cq_object ignored for pd_number:%d",
+			      be_function_get_pd_number(pfob));
+		}
+		fwcmd->params.request.bcmc_cq_id =
+		    be_cq_get_id(bcmc_cq_object);
+	} else {
+		fwcmd->params.request.bcmc_cq_id = 0xFFFF;
+	}
+
+	/* Create a page list for the FWCMD. */
+	be_sgl_to_pa_list(sgl, fwcmd->params.request.pages,
+			  ARRAY_SIZE(fwcmd->params.request.pages));
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "fwcmd to map eth rxq frags failed.");
+		goto Error;
+	}
+	/* Save the ring ID for cleanup. */
+	eth_rq->rid = fwcmd->params.response.id;
+
+	be_cq_object_reference(cq_object);
+
+	_be_function_add_eth_rq(pfob, eth_rq);
+
+	TRACE(DL_INFO,
+	      "eth rq created. function:%d pd:%d bytes:%d bcmc_id:%d cq_id:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob),
+	      sa_sgl_get_page_count(sgl) * (u32)PAGE_SIZE,
+	      (bcmc_cq_object ? be_cq_get_id(bcmc_cq_object) : -1),
+	      be_cq_get_id(cq_object));
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+
+    This routine returns the RID for an Ethernet receive queue
+
+    EthRq - Ethernet receive queue handle returned from EthRqCreate
+
+    Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+    IRQL: <= DISPATCH_LEVEL
+*/
+u32 be_eth_rq_get_id(struct be_ethrq_object *rq)
+{
+	return rq->rid;
+}
+
+/*
+    This routine destroys an Ethernet receive queue
+
+    eth_rq - ethernet receive queue handle returned from eth_rq_create
+
+    Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+    This function frees resourcs allocated by EthRqCreate.
+    The erx::host_cqid (or host_stor_cqid) register and erx::ring_page registers
+    will be updated as appropriate on return
+    IRQL: < DISPATCH_LEVEL
+*/
+
+static void be_eth_rq_destroy_internal_callback(void *context, BESTATUS status,
+					 struct MCC_WRB_AMAP *wrb)
+{
+	struct be_ethrq_object *eth_rq = (struct be_ethrq_object *) context;
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
+be_eth_rq_destroy_async(struct be_ethrq_object *eth_rq,
+			MCC_WRB_CQE_CALLBACK callback, void *callback_context)
+{
+	BESTATUS status = BE_SUCCESS;
+
+	/* Send fwcmd to destroy the RQ. */
+	status = be_function_ring_destroy_async(eth_rq->parent_function,
+			eth_rq->rid, FWCMD_RING_TYPE_ETH_RX,
+			callback, callback_context,
+			be_eth_rq_destroy_internal_callback, eth_rq);
+
+	return status;
+}
+
+BESTATUS be_eth_rq_destroy(struct be_ethrq_object *eth_rq)
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
+be_eth_rq_destroy_options(struct be_ethrq_object *eth_rq,
+			  bool flush, MCC_WRB_CQE_CALLBACK callback,
+			  void *callback_context)
+{
+	struct FWCMD_COMMON_RING_DESTROY *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = BE_SUCCESS;
+	struct be_function_object *pfob = NULL;
+
+	pfob = eth_rq->parent_function;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_RING_DESTROY);
+
+	fwcmd->params.request.id = eth_rq->rid;
+	fwcmd->params.request.ring_type = FWCMD_RING_TYPE_ETH_RX;
+	fwcmd->params.request.bypass_flush = ((0 == flush) ? 1 : 0);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_internal_callback(pfob, wrb,
+			NULL, callback, callback_context,
+			be_eth_rq_destroy_internal_callback, eth_rq, fwcmd);
+
+	if (status != BE_SUCCESS && status != BE_PENDING) {
+		TRACE(DL_ERR,
+		      "eth_rq ring destroy fwcmd failed. id:%d, flush:%d",
+		      eth_rq->rid, flush);
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+    This routine queries the frag size for erx.
+
+    pfob      - handle to a function object
+
+    frag_size_bytes       - erx frag size in bytes that is/was set.
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+    code is returned.
+
+    IRQL: < DISPATCH_LEVEL
+
+*/
+BESTATUS
+be_eth_rq_get_frag_size(struct be_function_object *pfob,
+			u32 *frag_size_bytes)
+{
+	struct FWCMD_ETH_GET_RX_FRAG_SIZE *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, ETH_GET_RX_FRAG_SIZE);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "get frag size fwcmd failed.");
+		goto error;
+	}
+
+	*frag_size_bytes =
+	    1 << fwcmd->params.response.actual_fragsize_log2;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*
+    This routine attempts to set the frag size for erx.  If the frag size is
+    already set, the attempt fails and the current frag size is returned.
+
+    pfob      - Handle to a function object
+
+    new_frag_size_bytes       - Erx frag size in bytes that is/was set.
+
+    current_frag_size_bytes    - Pointer to location where currrent frag
+				 is to be rturned
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+    code is returned.
+
+    IRQL: < DISPATCH_LEVEL
+
+    This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_rq_set_frag_size(struct be_function_object *pfob,
+			u32 new_frag_size_bytes, u32 *current_frag_size_bytes)
+{
+	struct FWCMD_ETH_SET_RX_FRAG_SIZE *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, ETH_SET_RX_FRAG_SIZE);
+
+	ASSERT(new_frag_size_bytes >= 128 &&
+	       new_frag_size_bytes <= 16 * 1024);
+
+	/* This is the log2 of the fragsize.  This is not the exact
+	 * ERX encoding. */
+	fwcmd->params.request.new_fragsize_log2 =
+	    sa_log2(new_frag_size_bytes);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "set frag size fwcmd failed.");
+		goto error;
+	}
+
+	*current_frag_size_bytes =
+			1 << fwcmd->params.response.actual_fragsize_log2;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
diff --git a/drivers/message/beclib/ethtx_ll.c b/drivers/message/beclib/ethtx_ll.c
new file mode 100644
index 0000000..0a9906b
--- /dev/null
+++ b/drivers/message/beclib/ethtx_ll.c
@@ -0,0 +1,479 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
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
+ *                   struct be_eth_sq_parameters for details.
+ * eth_sq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create_ex(struct be_function_object *pfob,
+		    struct sa_sgl *sgl, u32 length, u32 type,
+		    u32 ulp, struct be_cq_object *cq_object,
+		    struct be_eth_sq_parameters *ex_parameters,
+		    struct be_ethsq_object *eth_sq)
+{
+	struct FWCMD_COMMON_ETH_TX_CREATE *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	u32 n;
+
+	ASSERT(sgl);
+	ASSERT(eth_sq);
+	ASSERT(ex_parameters);
+
+	be_lock_wrb_post(pfob);
+	memset(eth_sq, 0, sizeof(*eth_sq));
+
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_ETH_TX_CREATE);
+	fwcmd->header.request.port_number = ex_parameters->port;
+
+	n = be_function_get_pd_number(pfob);
+	AMAP_SET_BITS_PTR(ETX_CONTEXT, pd_id,
+				&fwcmd->params.request.context, n);
+
+	n = be_ring_length_to_encoding(length, sizeof(struct ETH_WRB_AMAP));
+	AMAP_SET_BITS_PTR(ETX_CONTEXT, tx_ring_size,
+					&fwcmd->params.request.context, n);
+
+	AMAP_SET_BITS_PTR(ETX_CONTEXT, cq_id_send,
+			&fwcmd->params.request.context, cq_object->cq_id);
+
+	n = be_function_get_function_number(pfob);
+	AMAP_SET_BITS_PTR(ETX_CONTEXT, func, &fwcmd->params.request.context, n);
+
+	fwcmd->params.request.type = type;
+	fwcmd->params.request.ulp_num  = (1 << ulp);
+	fwcmd->params.request.num_pages = sa_ceiling(length, PAGE_SIZE);
+	ASSERT(sa_sgl_get_page_count(sgl) >= fwcmd->params.request.num_pages);
+
+	/* Create a page list for the FWCMD. */
+	be_sgl_to_pa_list(sgl, fwcmd->params.request.pages,
+			  ARRAY_SIZE(fwcmd->params.request.pages));
+
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create etx queue failed.");
+		goto Error;
+	}
+	/* save the butler ID */
+	eth_sq->bid = fwcmd->params.response.cid;
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
+/*
+    this routine creates an ethernet send queue
+
+    pfob      - handle to a function object
+    send_queue_va         - base VA for a the ethernet send ring
+    ring_size_power_of_two  - number of entries in the
+				ring (power of two). 32K = 0, 1 = rsvd,
+				2 = 1, 3 = 4 ....
+    cq_object            - internal CQ handle returned.
+    pp_eth_sq             - internal eth sq handle returned.
+
+    Returns BE_SUCCESS if successfull, otherwise an error code is returned.
+
+    IRQL: < DISPATCH_LEVEL
+    this function allocates an eth_sq object
+
+*/
+BESTATUS be_eth_sq_create(struct be_function_object *pfob,
+		struct sa_sgl *sgl, u32 length, u32 type,
+		u32 ulp,	/* 0,1,2 ulp id for the request ring */
+		struct be_cq_object *cq_object,
+		struct be_ethsq_object *eth_sq)
+{
+	struct be_eth_sq_parameters ex_parameters = { 0 };
+
+	return be_eth_sq_create_ex(pfob, sgl, length, type,
+				   ulp, cq_object, &ex_parameters, eth_sq);
+}
+
+/*
+    This routine returns the RID for an Etx SQ
+
+    EthSq - EthSq Handle returned from EthSqCreate
+
+    Returns the RID for an Etx SQ
+
+*/
+u32 be_eth_sq_get_id(struct be_ethsq_object *eth_sq)
+{
+	return eth_sq->bid;
+}
+
+/*
+    This routine destroys an ethernet send queue
+
+    EthSq - EthSq Handle returned from EthSqCreate
+
+    This function always return BE_SUCCESS.
+
+    This function frees memory allocated by EthSqCreate for the EthSq Object.
+
+*/
+BESTATUS be_eth_sq_destroy(struct be_ethsq_object *eth_sq)
+{
+	BESTATUS status = 0;
+
+	/* Send fwcmd to destroy the queue. */
+	status = be_function_ring_destroy(eth_sq->parent_function, eth_sq->bid,
+				     FWCMD_RING_TYPE_ETH_TX);
+	ASSERT(status == 0);
+
+	/* Derefence any associated CQs. */
+	be_cq_object_dereference(eth_sq->cq_object);
+
+	/* Remove from function */
+	_be_function_remove_eth_sq(eth_sq->parent_function, eth_sq);
+
+	/* Clear tracking object */
+	memset(eth_sq, 0, sizeof(*eth_sq));
+
+	return status;
+}
+
+/*
+    This routine attempts to set the transmit flow control parameters.
+
+    FunctionObject      - Handle to a function object
+
+    txfc_enable         - transmit flow control enable - true for
+			  enable, false for disable
+
+    rxfc_enable         - receive flow control enable - true for
+				enable, false for disable
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS error
+    code is returned.
+
+    IRQL: < DISPATCH_LEVEL
+
+    This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_set_flow_control(struct be_function_object *pfob,
+			bool txfc_enable, bool rxfc_enable)
+{
+	struct FWCMD_COMMON_SET_FLOW_CONTROL *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_SET_FLOW_CONTROL);
+
+	fwcmd->params.request.rx_flow_control = rxfc_enable;
+	fwcmd->params.request.tx_flow_control = txfc_enable;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "set flow control fwcmd failed.");
+		goto error;
+	}
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+/*
+    This routine attempts to get the transmit flow control parameters.
+
+    pfob      - Handle to a function object
+
+    txfc_enable         - transmit flow control enable - true for
+			enable, false for disable
+
+    rxfc_enable         - receive flow control enable - true for enable,
+			false for disable
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS error code
+			is returned.
+
+    IRQL: < DISPATCH_LEVEL
+
+    This function always fails in non-privileged machine context.
+*/
+BESTATUS
+be_eth_get_flow_control(struct be_function_object *pfob,
+			bool *txfc_enable, bool *rxfc_enable)
+{
+	struct FWCMD_COMMON_GET_FLOW_CONTROL *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_GET_FLOW_CONTROL);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "get flow control fwcmd failed.");
+		goto error;
+	}
+
+	*txfc_enable = fwcmd->params.response.tx_flow_control;
+	*rxfc_enable = fwcmd->params.response.rx_flow_control;
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
+be_eth_set_qos(struct be_function_object *pfob, u32 max_bps, u32 max_pps)
+{
+	struct FWCMD_COMMON_SET_QOS *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_SET_QOS);
+
+	/* Set fields in fwcmd */
+	fwcmd->params.request.max_bits_per_second_NIC = max_bps;
+	fwcmd->params.request.max_packets_per_second_NIC = max_pps;
+	fwcmd->params.request.valid_flags = QOS_BITS_NIC | QOS_PKTS_NIC;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0)
+		TRACE(DL_ERR, "network set qos fwcmd failed.");
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
+ * max_bps         - the maximum bits per second in units of
+ * 			10 Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units of
+ * 			1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_qos(struct be_function_object *pfob, u32 *max_bps, u32 *max_pps)
+{
+	struct FWCMD_COMMON_GET_QOS *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_GET_QOS);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "network get qos fwcmd failed.");
+		goto error;
+	}
+
+	*max_bps = fwcmd->params.response.max_bits_per_second_NIC;
+	*max_pps = fwcmd->params.response.max_packets_per_second_NIC;
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
+be_eth_set_frame_size(struct be_function_object *pfob,
+		      u32 *tx_frame_size, u32 *rx_frame_size)
+{
+	struct FWCMD_COMMON_SET_FRAME_SIZE *fwcmd = NULL;
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
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_SET_FRAME_SIZE);
+	fwcmd->params.request.max_tx_frame_size = *tx_frame_size;
+	fwcmd->params.request.max_rx_frame_size = *rx_frame_size;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "network set frame size fwcmd failed.");
+		goto error;
+	}
+
+	*tx_frame_size = fwcmd->params.response.chip_max_tx_frame_size;
+	*rx_frame_size = fwcmd->params.response.chip_max_rx_frame_size;
+
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
diff --git a/drivers/message/beclib/rxf_ll.c b/drivers/message/beclib/rxf_ll.c
new file mode 100644
index 0000000..d9328e4
--- /dev/null
+++ b/drivers/message/beclib/rxf_ll.c
@@ -0,0 +1,620 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+#include "pch.h"
+
+/*
+    This routine adds, removes, or reads a WoL magic packet.
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+    IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_wake_on_lan_config(struct be_function_object *pfob,
+	bool enable_port0, bool enable_port1,
+	bool magic_packet_enable, u32 index,
+	void *pattern, void *pattern_mask,
+	MCC_WRB_CQE_CALLBACK callback,
+	void *callback_context,
+	struct be_wake_on_lan_queue_context *queue_context)
+{
+	struct FWCMD_ETH_ACPI_CONFIG *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = BE_SUCCESS;
+	struct be_generic_queue_context *generic_context = NULL;
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
+			generic_context = (struct be_generic_queue_context *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, ETH_ACPI_CONFIG);
+
+	fwcmd->params.request.index = index;
+	fwcmd->params.request.port0 = enable_port0;
+	fwcmd->params.request.port1 = enable_port1;
+	fwcmd->params.request.magic_packet = magic_packet_enable;
+
+	if (enable_port0 || enable_port1) {
+		if (pattern) {
+			memcpy(fwcmd->params.request.byte_pattern,
+			  pattern, sizeof(fwcmd->params.request.byte_pattern));
+		}
+		if (pattern_mask) {
+			memcpy(fwcmd->params.request.bit_mask,
+			  pattern_mask, sizeof(fwcmd->params.request.bit_mask));
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
+					callback, callback_context, fwcmd);
+
+	if (status < 0) {
+		TRACE(DL_ERR, "wake-on-lan fwcmd failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+    This routine gets or sets a mac address for a domain
+    given the port and mac.
+
+    FunctionObject  - Function object handle.
+    port1           - Set to TRUE if this function will set/get the Port 1
+			address.  Only the host may set this to TRUE.
+    mac1            - Set to TRUE if this function will set/get the
+			MAC 1 address.  Only the host may set this to TRUE.
+    write           - Set to TRUE if this function should write the mac address.
+    mac_address      - Buffer of the mac address to read or write.
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+    IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_mac_address_read_write(struct be_function_object *pfob,
+		bool port1,	/* VM must always set to false */
+		bool mac1,	/* VM must always set to false */
+		bool mgmt, bool write,
+		bool permanent, u8 *mac_address,
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context)	/* optional */
+{
+	BESTATUS status = BE_SUCCESS;
+	union {
+		struct FWCMD_COMMON_NTWK_MAC_QUERY *query;
+		struct FWCMD_COMMON_NTWK_MAC_SET *set;
+	} fwcmd = {NULL};
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 type = 0;
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
+		/* Prepares an embedded fwcmd, including
+		 * request/response sizes.
+		 */
+		fwcmd.set = BE_PREPARE_EMBEDDED_FWCMD(pfob,
+					       wrb, COMMON_NTWK_MAC_SET);
+
+		fwcmd.set->params.request.invalidate = 0;
+		fwcmd.set->params.request.mac1 = (mac1 ? 1 : 0);
+		fwcmd.set->params.request.port = (port1 ? 1 : 0);
+		fwcmd.set->params.request.type = type;
+
+		/* Copy the mac address to set. */
+		fwcmd.set->params.request.mac.SizeOfStructure =
+		    sizeof(fwcmd.set->params.request.mac);
+		memcpy(fwcmd.set->params.request.mac.MACAddress,
+			  mac_address, sizeof(*mac_address));
+
+		/* Post the Ioctl */
+		status = be_function_post_mcc_wrb(pfob,
+						  wrb,
+						  callback,
+						  callback_context,
+						  fwcmd.set);
+
+	} else {
+
+		/*
+		 * Prepares an embedded fwcmd, including
+		 * request/response sizes.
+		 */
+		fwcmd.query = BE_PREPARE_EMBEDDED_FWCMD(pfob,
+					       wrb, COMMON_NTWK_MAC_QUERY);
+
+		fwcmd.query->params.request.mac1 = (mac1 ? 1 : 0);
+		fwcmd.query->params.request.port = (port1 ? 1 : 0);
+		fwcmd.query->params.request.type = type;
+		fwcmd.query->params.request.permanent = permanent;
+
+		/* Post the Ioctl (with a copy for the response) */
+		status = be_function_post_mcc_wrb_with_copy(pfob,
+			wrb, NULL,	/* queue context */
+			callback, callback_context, fwcmd.query,
+			BE_CREATE_MCC_RESPONSE_COPY(FWCMD_COMMON_NTWK_MAC_QUERY,
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
+/*
+    This routine writes data to context memory.
+
+    pfob  - Function object handle.
+    mac_table     - Set to the 128-bit multicast address hash table.
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+    IRQL: < DISPATCH_LEVEL
+*/
+
+BESTATUS be_rxf_multicast_config(struct be_function_object *pfob,
+		bool promiscuous, u32 num, u8 *mac_table,
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context,
+		struct be_multicast_queue_context *queue_context)
+{
+	BESTATUS status = BE_SUCCESS;
+	struct FWCMD_COMMON_NTWK_MULTICAST_SET *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct be_generic_queue_context *generic_context = NULL;
+
+	ASSERT(num <= SA_NUMBER_OF_FIELD(FWCMD_COMMON_NTWK_MULTICAST_SET,
+				  params.request.mac));
+
+	if (num > SA_NUMBER_OF_FIELD(
+			FWCMD_COMMON_NTWK_MULTICAST_SET, params.request.mac)) {
+		TRACE(DL_ERR, "Too many multicast addresses. BE supports %d.",
+		      SA_NUMBER_OF_FIELD(FWCMD_COMMON_NTWK_MULTICAST_SET,
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
+			generic_context = (struct be_generic_queue_context *)
+								queue_context;
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_NTWK_MULTICAST_SET);
+
+	TRACE(DL_INFO,
+	      "multicast config. function:%d promiscuous:%d num:%d",
+	      be_function_get_function_number(pfob),
+	      promiscuous, num);
+
+	fwcmd->params.request.promiscuous = promiscuous;
+	if (!promiscuous) {
+
+		fwcmd->params.request.num_mac = num;
+
+		if (num > 0) {
+			u32 i = 0;
+
+			ASSERT(mac_table);
+			memcpy(fwcmd->params.request.mac, mac_table, 6 * num);
+			for (i = 0; i < num; i++) {
+				TRACE(DL_VERBOSE, " multicast address[%d]: "
+				      "%02x:%02x:%02x:%02x:%02x:%02x", i,
+					(u32)*(mac_table),
+					(u32)*(mac_table+1),
+					(u32)*(mac_table+2),
+					(u32)*(mac_table+3),
+					(u32)*(mac_table+4),
+					(u32)*(mac_table+5));
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
+				callback_context, fwcmd);
+	if (status < 0) {
+		TRACE(DL_ERR, "multicast fwcmd failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+/*
+    This routine adds or removes a vlan tag from the rxf table.
+
+    FunctionObject  - Function object handle.
+    VLanTag         - VLan tag to add or remove.
+    Add             - Set to TRUE if this will add a vlan tag
+
+    Returns BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+
+    IRQL: < DISPATCH_LEVEL
+*/
+BESTATUS be_rxf_vlan_config(struct be_function_object *pfob,
+		bool promiscuous, u32 num, u16 *vlan_tag_array,
+		MCC_WRB_CQE_CALLBACK callback,	/* optional */
+		void *callback_context,
+		struct be_vlan_queue_context *queue_context)	/* optional */
+{
+	BESTATUS status = BE_SUCCESS;
+	struct FWCMD_COMMON_NTWK_VLAN_CONFIG *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct be_generic_queue_context *generic_context = NULL;
+
+	if (num > SA_NUMBER_OF_FIELD(FWCMD_COMMON_NTWK_VLAN_CONFIG,
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
+			generic_context = (struct be_generic_queue_context *)
+					queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_NTWK_VLAN_CONFIG);
+
+	TRACE(DL_INFO, "vlan config. function:%d promiscuous:%d num:%d",
+	      be_function_get_function_number(pfob), promiscuous, num);
+
+	fwcmd->params.request.promiscuous = promiscuous;
+	if (!promiscuous) {
+
+		fwcmd->params.request.num_vlan = num;
+
+		if (num > 0) {
+			ASSERT(vlan_tag_array);
+			memcpy(fwcmd->params.request.vlan_tag, vlan_tag_array,
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
+					callback_context, fwcmd);
+	if (status < 0) {
+		TRACE(DL_ERR, "vlan fwcmd failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+
+BESTATUS be_rxf_link_status(struct be_function_object *pfob,
+		struct BE_LINK_STATUS *link_status,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct be_link_status_queue_context *queue_context)
+{
+	struct FWCMD_COMMON_NTWK_LINK_STATUS_QUERY *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct be_generic_queue_context *generic_context = NULL;
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
+			generic_context = (struct be_generic_queue_context *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb,
+					       COMMON_NTWK_LINK_STATUS_QUERY);
+
+	/* Post or queue the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(pfob, wrb,
+		generic_context,	/* Queue context */
+		callback, callback_context, fwcmd,
+		BE_CREATE_MCC_RESPONSE_COPY(FWCMD_COMMON_NTWK_LINK_STATUS_QUERY,
+					params.response, link_status));
+
+	if (status < 0) {
+		TRACE(DL_ERR, "link status fwcmd failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS
+be_rxf_query_eth_statistics(struct be_function_object *pfob,
+		    struct FWCMD_ETH_GET_STATISTICS *va_for_fwcmd,
+		    u64 pa_for_fwcmd, MCC_WRB_CQE_CALLBACK callback,
+		    void *callback_context,
+		    struct be_nonembedded_queue_context *queue_context)
+{
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct be_generic_queue_context *generic_context = NULL;
+
+	ASSERT(va_for_fwcmd);
+	ASSERT(pa_for_fwcmd);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct be_generic_queue_context *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+
+	TRACE(DL_INFO,
+	      "Query eth stats. fwcmd va:%p pa:0x%08x_%08x",
+	      va_for_fwcmd, sa_hi(pa_for_fwcmd), sa_lo(pa_for_fwcmd));
+
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	va_for_fwcmd = BE_PREPARE_NONEMBEDDED_FWCMD(pfob, wrb,
+			  va_for_fwcmd, pa_for_fwcmd, ETH_GET_STATISTICS);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+			wrb, generic_context, callback, callback_context,
+					va_for_fwcmd);
+	if (status < 0) {
+		TRACE(DL_ERR, "eth stats fwcmd failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS
+be_rxf_promiscuous(struct be_function_object *pfob,
+		   bool enable_port0, bool enable_port1,
+		   MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		   struct be_promiscuous_queue_context *queue_context)
+{
+	struct FWCMD_ETH_PROMISCUOUS *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct be_generic_queue_context *generic_context = NULL;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+						&queue_context->wrb_header;
+			generic_context = (struct be_generic_queue_context *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, ETH_PROMISCUOUS);
+
+	fwcmd->params.request.port0_promiscuous = enable_port0;
+	fwcmd->params.request.port1_promiscuous = enable_port1;
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob,
+			wrb, generic_context, callback, callback_context,
+			fwcmd);
+
+	if (status < 0) {
+		TRACE(DL_ERR, "promiscuous fwcmd failed.");
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
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
+ *                      be_generic_queue_context. However, the specific
+ *                      context structs are generally smaller than
+ *                      the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_filter_config(struct be_function_object *pfob,
+		     struct NTWK_RX_FILTER_SETTINGS *settings,
+		     MCC_WRB_CQE_CALLBACK callback,
+		     void *callback_context,
+		     struct be_rxf_filter_queue_context *queue_context)
+{
+	struct FWCMD_COMMON_NTWK_RX_FILTER *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct be_generic_queue_context *generic_context = NULL;
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
+			generic_context = (struct be_generic_queue_context *)
+				queue_context;	/* Indicate to queue */
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_NTWK_RX_FILTER);
+	memcpy(&fwcmd->params.request, settings, sizeof(*settings));
+
+	/* Post or queue the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(pfob,
+			wrb, generic_context,	/* Queue context */
+			callback, callback_context, fwcmd,
+			BE_CREATE_MCC_RESPONSE_COPY(FWCMD_COMMON_NTWK_RX_FILTER,
+				params.response, settings));
+
+	if (status < 0) {
+		TRACE(DL_ERR, "RXF/ERX filter config fwcmd failed.");
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

