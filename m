From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 7/12] benet: beclib functions
Date: Thu, 12 Jun 2008 03:44:27 -0700
Message-ID: <20080612104427.188add78@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:40102 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbYFLKoc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:44:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/eq_ll.c  |  523 +++++++++++++++
 drivers/message/beclib/mpu_ll.c | 1380 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 1903 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/eq_ll.c
 create mode 100644 drivers/message/beclib/mpu_ll.c

diff --git a/drivers/message/beclib/eq_ll.c b/drivers/message/beclib/eq_ll.c
new file mode 100644
index 0000000..d822eda
--- /dev/null
+++ b/drivers/message/beclib/eq_ll.c
@@ -0,0 +1,523 @@
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
+ *============================================================================
+ *                            F I L E   S C O P E
+ *============================================================================
+ */
+
+static inline struct be_eq_object *
+_be_eq_id_to_object(struct be_function_object *pfob, u32 eq_id)
+{
+	struct be_eq_object *eq_cur;
+	struct be_eq_object *eq_ret = NULL;
+	u32 eid;
+
+	_be_function_lock(pfob);
+
+	list_for_each_entry(eq_cur, &pfob->links.eq_list_head, eq_list) {
+		eid = be_eq_get_id(eq_cur);
+		if (eid == eq_id) {
+			eq_ret = eq_cur;
+			break;
+		}
+	}
+
+	_be_function_unlock(pfob);
+
+	return eq_ret;
+}
+
+/*
+ *============================================================================
+ *                  P U B L I C  R O U T I N E S
+ *============================================================================
+ */
+
+/*
+    This routine creates an event queue based on the client completion
+    queue configuration information.
+
+    FunctionObject      - Handle to a function object
+    EqBaseVa            - Base VA for a the EQ ring
+    SizeEncoding        - The encoded size for the EQ entries. This value is
+			either CEV_EQ_SIZE_4 or CEV_EQ_SIZE_16
+    NumEntries          - CEV_CQ_CNT_* values.
+    Watermark           - Enables watermark based coalescing.  This parameter
+			must be of the type CEV_WMARK_* if watermarks
+			are enabled.  If watermarks to to be disabled
+			this value should be-1.
+    TimerDelay          - If a timer delay is enabled this value should be the
+			time of the delay in 8 microsecond units.  If
+			delays are not used this parameter should be
+			set to -1.
+    ppEqObject          - Internal EQ Handle returned.
+
+    Returns BE_SUCCESS if successfull,, otherwise a useful error code
+	is returned.
+
+    IRQL < DISPATCH_LEVEL
+*/
+static BESTATUS
+be_eq_create_internal(struct be_function_object *pfob,
+		struct sa_sgl *sgl, u32 eqe_size, u32 num_entries,
+		u32 watermark,	/* CEV_WMARK_* or -1 */
+		u32 timer_delay,	/* in 8us units, or -1 */
+		bool fake_eq, struct be_eq_object *eq_object)
+{
+	BESTATUS status = BE_SUCCESS;
+	u32 num_entries_encoding, eqe_size_encoding, length;
+	struct FWCMD_COMMON_EQ_CREATE *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 n;
+
+	ASSERT(sgl);
+	ASSERT(eq_object);
+
+	/*
+	 * To avoid assuming the enumeration values are constant,
+	 * I'm using a switch statement instead of calculating this
+	 * with sa_log2.
+	 */
+	switch (num_entries) {
+	case 256:
+		num_entries_encoding = CEV_EQ_CNT_256;
+		break;
+	case 512:
+		num_entries_encoding = CEV_EQ_CNT_512;
+		break;
+	case 1024:
+		num_entries_encoding = CEV_EQ_CNT_1024;
+		break;
+	case 2048:
+		num_entries_encoding = CEV_EQ_CNT_2048;
+		break;
+	case 4096:
+		num_entries_encoding = CEV_EQ_CNT_4096;
+		break;
+	default:
+		ASSERT(0);
+		return BE_STATUS_INVALID_PARAMETER;
+	}
+
+	/*
+	 * To avoid assuming the enumeration values are constant,
+	 * I'm using a switch statement instead of calculating
+	 * this with sa_log2.
+	 */
+	switch (eqe_size) {
+	case 4:
+		eqe_size_encoding = CEV_EQ_SIZE_4;
+		break;
+	case 16:
+		eqe_size_encoding = CEV_EQ_SIZE_16;
+		break;
+	default:
+		ASSERT(0);
+		return BE_STATUS_INVALID_PARAMETER;
+	}
+
+	if ((eqe_size == 4 && num_entries < 1024) ||
+	    (eqe_size == 16 && num_entries == 4096)) {
+		TRACE(DL_ERR, "Bad EQ size. eqe_size:%d num_entries:%d",
+		      eqe_size, num_entries);
+		ASSERT(0);
+		return BE_STATUS_INVALID_PARAMETER;
+	}
+
+	memset(eq_object, 0, sizeof(*eq_object));
+
+	atomic_set(&eq_object->ref_count, 0);
+	eq_object->parent_function = pfob;
+	eq_object->eq_id = 0xFFFFFFFF;
+
+	spin_lock_init(&eq_object->lock.lock);
+
+	INIT_LIST_HEAD(&eq_object->cq_list_head);
+
+	length = num_entries * eqe_size;
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
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_EQ_CREATE);
+
+	fwcmd->params.request.num_pages =
+			SA_PAGES_SPANNED(sa_sgl_get_offset(sgl), length);
+
+	n = be_function_get_function_number(pfob);
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, Func, &fwcmd->params.request.context, n);
+
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, valid, &fwcmd->params.request.context, 1);
+
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, Size,
+			&fwcmd->params.request.context, eqe_size_encoding);
+
+	n = be_function_get_pd_number(pfob);
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, PD, &fwcmd->params.request.context, n);
+
+	/* Let the caller ARM the EQ with the doorbell. */
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, Armed, &fwcmd->params.request.context, 0);
+
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, Count, &fwcmd->params.request.context,
+					num_entries_encoding);
+
+	n = be_function_get_function_number(pfob) * 32;
+	AMAP_SET_BITS_PTR(EQ_CONTEXT, EventVect,
+				&fwcmd->params.request.context, n);
+	if (fake_eq) {
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, Cidx,
+					&fwcmd->params.request.context, 0);
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, Pidx,
+					&fwcmd->params.request.context, 2);
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, EPIdx,
+					&fwcmd->params.request.context, 2);
+	}
+	if (watermark != -1) {
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, WME,
+				&fwcmd->params.request.context, 1);
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, Watermark,
+				&fwcmd->params.request.context, watermark);
+		ASSERT(watermark <= CEV_WMARK_240);
+	} else
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, WME,
+					&fwcmd->params.request.context, 0);
+	if (timer_delay != -1) {
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, TMR,
+					&fwcmd->params.request.context, 1);
+
+		ASSERT(timer_delay <= 250);	/* max value according to EAS */
+		timer_delay = min(timer_delay, (u32)250);
+
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, Delay,
+				&fwcmd->params.request.context, timer_delay);
+	} else {
+		AMAP_SET_BITS_PTR(EQ_CONTEXT, TMR,
+				&fwcmd->params.request.context, 0);
+	}
+	/* Create a page list for the FWCMD. */
+	be_sgl_to_pa_list(sgl, fwcmd->params.request.pages,
+			  ARRAY_SIZE(fwcmd->params.request.pages));
+
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create EQ failed.");
+		goto Error;
+	}
+	/* Get the EQ id.  The MPU allocates the IDs. */
+	eq_object->eq_id = fwcmd->params.response.eq_id;
+
+	/* insert tracking object */
+	_be_function_add_eq(pfob, eq_object);
+
+	TRACE(DL_INFO,
+	      "eq created. function:%d pd:%d eqid:%d bytes:%d eqeBytes:%d"
+	      " wm:%d td:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob), eq_object->eq_id,
+	      num_entries * eqe_size, eqe_size, watermark, timer_delay);
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS be_eq_create(struct be_function_object *pfob, struct sa_sgl
+		*sgl, u32 eqe_size, u32 num_entries,
+		u32 watermark,	/* CEV_WMARK_* or -1 */
+		u32 timer_delay,	/* in 8us units, or -1 */
+		struct be_eq_object *eq_object)
+{
+	return be_eq_create_internal(pfob, sgl, eqe_size, num_entries,
+			     watermark, timer_delay, FALSE, eq_object);
+}
+
+
+/*
+    Returns the EQ ID for EQ. This is the ID the chip references the queue as.
+
+    EqObject            - EQ Handle returned from EqObjectCreate.
+
+    Returns EQ ID
+
+    IRQL: any
+
+*/
+u32 be_eq_get_id(struct be_eq_object *eq_object)
+{
+	return eq_object->eq_id;
+}
+
+
+/*
+    References the given object. The object is guaranteed to remain active until
+    the reference count drops to zero.
+
+    eq_object            - CQ handle returned from cq_object_create.
+
+    returns the current reference count on the object
+
+    IRQL: any
+
+*/
+static void be_eq_reference(struct be_eq_object *eq_object)
+{
+	atomic_inc(&eq_object->ref_count);
+}
+
+/*
+    Dereferences the given object. The object is guaranteed to remain
+    active until the reference count drops to zero.
+
+    eq_object            - CQ handle returned from cq_object_create.
+
+    returns the current reference count on the object
+
+    IRQL: any
+
+*/
+static void be_eq_dereference(struct be_eq_object *eq_object)
+{
+	atomic_dec(&eq_object->ref_count);
+}
+
+/*
+    This routine adds a CQ as a dependent object on the given EQ. This will
+    cause the reference count to be incrmented and the CQ to be placed on
+    the EQ's list of active CQ objects.
+
+    eq_object            - EQ handle returned from eq_object_create.
+    cq_object            - CQ handle that is dependent on this EQ
+
+    Returns EQ ID
+
+    IRQL: < DISPATCH_LEVEL
+
+*/
+void _be_eq_add_cq(struct be_eq_object *eq_object,
+				struct be_cq_object *cq_object)
+{
+	be_eq_reference(eq_object);
+
+	list_add_tail(&cq_object->cqlist_for_eq, &eq_object->cq_list_head);
+
+}
+/*
+    This routine removes a CQ as a dependent object on the given EQ. This will
+    cause the reference count to be decrmented and the CQ to be removed from
+    the EQ's list of active CQ objects.
+
+    eq_object            - EQ handle returned from eq_object_create.
+    cq_object            - CQ handle that was dependent on this EQ
+
+    Returns EQ ID
+
+    IRQL: < DISPATCH_LEVEL
+*/
+void
+_be_eq_remove_cq(struct be_eq_object *eq_object, struct be_cq_object *cq_object)
+{
+	be_eq_dereference(eq_object);
+
+	list_del(&cq_object->cqlist_for_eq);
+}
+
+/*
+    Deferences the given object. Once the object's reference count drops to
+    zero, the object is destroyed and all resources that are held by this
+    object are released.  The on-chip context is also destroyed along with
+    the queue ID, and any mappings made into the UT.
+
+    eq_object            - EQ handle returned from eq_object_create.
+
+    Returns BE_SUCCESS if successfull, otherwise a useful error code
+	is returned.
+
+    IRQL: IRQL < DISPATCH_LEVEL
+*/
+BESTATUS be_eq_destroy(struct be_eq_object *eq_object)
+{
+	BESTATUS status = 0;
+
+	ASSERT(eq_object->ref_count == 0);
+	/* no CQs should reference this EQ now */
+	ASSERT(list_empty(&eq_object->cq_list_head));
+
+	/* Send fwcmd to destroy the EQ. */
+	status = be_function_ring_destroy(eq_object->parent_function,
+				     eq_object->eq_id, FWCMD_RING_TYPE_EQ);
+	ASSERT(status == 0);
+
+	/* remove from the function */
+	_be_function_remove_eq(eq_object->parent_function, eq_object);
+
+	/* zero tracking object */
+	memset(eq_object, 0, sizeof(struct be_eq_object));
+
+	return BE_SUCCESS;
+}
+
+/*
+ *---------------------------------------------------------------------------
+ * Function: be_eq_modify_delay
+ *   Changes the EQ delay for a group of EQs.
+ * num_eq             - The number of EQs in the eq_array to adjust.
+ * 			This also is the number of delay values in
+ * 			the eq_delay_array.
+ * eq_array           - Array of struct be_eq_object pointers to adjust.
+ * eq_delay_array     - Array of "num_eq" timer delays in units
+ * 			of microseconds. The be_eq_query_delay_range
+ * 			fwcmd returns the resolution and range of
+ *                      legal EQ delays.
+ * callback           -
+ * callback_context   -
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation. It
+ *                      will be posted to the MCC ring when space
+ *                      becomes available. All queued commands will
+ *                      be posted to the ring in the order they are
+ *                      received. It is always valid to pass a pointer to
+ *                      a generic be_generic_queue_context. However,
+ *                      the specific context structs
+ *                      are generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *-------------------------------------------------------------------------
+ */
+BESTATUS
+be_eq_modify_delay(struct be_function_object *pfob,
+		   u32 num_eq, struct be_eq_object **eq_array,
+		   u32 *eq_delay_array, MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct be_eq_modify_delay_queue_context *queue_context)
+{
+	struct FWCMD_COMMON_MODIFY_EQ_DELAY *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+	struct be_generic_queue_context *generic_context = NULL;
+	u32 i;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (struct MCC_WRB_AMAP *)
+					&queue_context->wrb_header;
+			generic_context = (struct be_generic_queue_context *)
+				queue_context;
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_MODIFY_EQ_DELAY);
+
+	ASSERT(num_eq > 0);
+	ASSERT(num_eq <= ARRAY_SIZE(fwcmd->params.request.delay));
+	fwcmd->params.request.num_eq = num_eq;
+	for (i = 0; i < num_eq; i++) {
+		fwcmd->params.request.delay[i].eq_id =
+		    be_eq_get_id(eq_array[i]);
+		fwcmd->params.request.delay[i].delay_in_microseconds =
+		    eq_delay_array[i];
+	}
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(pfob, wrb,
+			generic_context, callback, callback_context, fwcmd);
+
+Error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+
+}
+
+/*
+ *--------------------------------------------------------------------------
+ * Function: be_eq_query_delay_range
+ *   Queries the resolution and range allowed for EQ delay.
+ *   This is a constant set by the firmware, so it may be queried
+ *   one time at system boot. It is the same for all EQs.
+ *   This is a synchronous FWCMD.
+ * pfob     - Previously created function object
+ * eq_delay_resolution - Resolution of EQ delay in microseconds.
+ * eq_delay_max        - Max value of EQ delay in microseconds.
+ * return status       - BE_SUCCESS (0) on success. Negative
+ * 			error code on failure.
+ *--------------------------------------------------------------------------
+ */
+BESTATUS
+be_eq_query_delay_range(struct be_function_object *pfob,
+			u32 *eq_delay_resolution, u32 *eq_delay_max)
+{
+	struct FWCMD_COMMON_MODIFY_EQ_DELAY *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	ASSERT(eq_delay_resolution);
+	ASSERT(eq_delay_max);
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_MODIFY_EQ_DELAY);
+
+	/* init the context */
+	fwcmd->params.request.num_eq = 0;
+
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "Query EQ delay range failed.");
+		goto Error;
+	}
+
+	*eq_delay_resolution =
+	    fwcmd->params.response.delay_resolution_in_microseconds;
+	*eq_delay_max = fwcmd->params.response.delay_max_in_microseconds;
+
+	TRACE(DL_INFO, "eq delay. function:%d pd:%d resolution:%d max:%d",
+	      be_function_get_function_number(pfob),
+	      be_function_get_pd_number(pfob),
+	      *eq_delay_resolution, *eq_delay_max);
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+
+}
diff --git a/drivers/message/beclib/mpu_ll.c b/drivers/message/beclib/mpu_ll.c
new file mode 100644
index 0000000..5d77203
--- /dev/null
+++ b/drivers/message/beclib/mpu_ll.c
@@ -0,0 +1,1380 @@
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
+ *============================================================================
+ *                            F I L E   S C O P E
+ *============================================================================
+ */
+
+/*
+    This routine converts from a BladeEngine Mcc wrb completion status to
+    a standard NT status;
+
+    MccStatus   - BE Mcc WRB completion status to convert
+
+    Returns BE status code
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+static BESTATUS be_mcc_wrb_status_to_bestatus(u32 mcc_status)
+{
+	/* TODO -- Fix this if we want better status codes. */
+	switch (mcc_status) {
+	case MGMT_STATUS_SUCCESS:
+		return SA_SUCCESS;
+	default:
+		return BE_NOT_OK;
+	}
+}
+
+/*
+    This routine waits for a previously posted mailbox WRB to be completed.
+    Specifically it waits for the mailbox to say that it's ready to accept
+    more data by setting the LSB of the mailbox pd register to 1.
+
+    pcontroller      - The function object to post this data to
+
+    IRQL < DISPATCH_LEVEL
+*/
+static void be_mcc_mailbox_wait(struct be_function_object *pfob)
+{
+	struct MPU_MAILBOX_DB_AMAP mailbox_db;
+	u32 i = 0;
+	u32 tl, ready;
+
+	if (pfob->emulate) {
+		/* No waiting for mailbox in emulated mode. */
+		return;
+	}
+
+
+	tl = sa_trace_set_level(sa_trace_get_level() & ~DL_HW);
+
+	mailbox_db.dw[0] = PD_READ(pfob, mcc_bootstrap_db);
+	ready = AMAP_GET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db);
+
+	while (ready == FALSE) {
+		if ((++i & 0x3FFFF) == 0) {
+			TRACE(DL_WARN,
+			      "Waiting for mailbox ready for %dk polls.",
+			      i / 1000);
+		}
+
+		sa_dev_stall(pfob->sa_dev, 1);
+
+		mailbox_db.dw[0] = PD_READ(pfob, mcc_bootstrap_db);
+		ready = AMAP_GET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db);
+	}
+	sa_trace_set_level(tl);
+
+}
+
+/*
+    This routine tells the MCC mailbox that there is data to processed
+    in the mailbox. It does this by setting the physical address for the
+    mailbox location and clearing the LSB.  This routine returns immediately
+    and does not wait for the WRB to be processed.
+
+    pcontroller      - The function object to post this data to
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+static void be_mcc_mailbox_notify(struct be_function_object *pfob)
+{
+	struct MPU_MAILBOX_DB_AMAP mailbox_db;
+	u32 pa;
+
+	ASSERT(pfob->mailbox.pa);
+	ASSERT(pfob->mailbox.va);
+
+	/* If emulated, do not ring the mailbox */
+	if (pfob->emulate) {
+		TRACE(DL_WARN, "MPU disabled. Skipping mailbox notify.");
+		return;
+	}
+
+	pfob->stats.mailbox_wrbs++;
+
+	/* form the higher bits in the address */
+	mailbox_db.dw[0] = 0;	/* init */
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, hi, &mailbox_db, 1);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db, 0);
+
+	SA_C_ASSERT(AMAP_BIT_SIZE(MPU_MAILBOX_DB, address) == 30);
+	pa = (u32) sa_upper_bits64(pfob->mailbox.pa, 30);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, address, &mailbox_db, pa);
+
+	/* Wait for the MPU to be ready */
+	be_mcc_mailbox_wait(pfob);
+
+	/* Ring doorbell 1st time */
+	PD_WRITE(pfob, mcc_bootstrap_db, mailbox_db);
+
+	/* Wait for 1st write to be acknowledged. */
+	be_mcc_mailbox_wait(pfob);
+
+	/* form the lower bits in the address */
+	pa = (u32) sa_bit_range64(pfob->mailbox.pa, 4, 30);
+
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, hi, &mailbox_db, 0);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db, 0);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, address, &mailbox_db, pa);
+
+	/* Ring doorbell 2nd time */
+	PD_WRITE(pfob, mcc_bootstrap_db, mailbox_db);
+}
+
+/*
+    This routine tells the MCC mailbox that there is data to processed
+    in the mailbox. It does this by setting the physical address for the
+    mailbox location and clearing the LSB.  This routine spins until the
+    MPU writes a 1 into the LSB indicating that the data has been received
+    and is ready to be processed.
+
+    pcontroller      - The function object to post this data to
+
+    IRQL < DISPATCH_LEVEL
+*/
+static void
+be_mcc_mailbox_notify_and_wait(struct be_function_object *pfob)
+{
+	/*
+	 * Notify it
+	 */
+	be_mcc_mailbox_notify(pfob);
+
+	/*
+	 * Now wait for completion of WRB
+	 */
+	be_mcc_mailbox_wait(pfob);
+}
+
+void
+be_mcc_process_cqe(struct be_function_object *pfob,
+				struct MCC_CQ_ENTRY_AMAP *cqe)
+{
+
+	struct be_mcc_wrb_context *wrb_context = NULL;
+	u32 offset, completion_status;
+	u8 *p;
+
+	ASSERT(cqe);
+
+	/*
+	 * A command completed.  Commands complete out-of-order.
+	 * Determine which command completed from the TAG.
+	 */
+	offset = AMAP_BYTE_OFFSET(MCC_CQ_ENTRY, mcc_tag);
+	p = (u8 *) cqe + offset;
+	wrb_context = (struct be_mcc_wrb_context *) SA_U64_TO_PTR(*((u64 *) p));
+
+	ASSERT(wrb_context);
+
+#ifdef SA_DEBUG
+	/*
+	 * Assert that at least one WRB was consumed since we posted this one.
+	 * If this assert fires, it indicates that a WRB was completed
+	 * before it was consumed.
+	 */
+	if (wrb_context->ring_wrb) {
+		ASSERT(C_GT(pfob->stats.consumed_wrbs,
+			wrb_context->consumed_count));
+	}
+#endif
+
+	/*
+	 * Perform a response copy if requested.
+	 * Only copy data if the FWCMD is successful.
+	 */
+	completion_status = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY,
+						completion_status, cqe);
+	if (completion_status == MGMT_STATUS_SUCCESS &&
+	    wrb_context->copy.length > 0) {
+		ASSERT(wrb_context->wrb);
+		ASSERT(wrb_context->copy.va);
+		p = (u8 *)wrb_context->wrb + AMAP_BYTE_OFFSET(MCC_WRB, payload);
+		memcpy(wrb_context->copy.va,
+			  (u8 *)p + wrb_context->copy.fwcmd_offset,
+			  wrb_context->copy.length);
+	}
+
+	/* internal callback */
+	if (wrb_context->internal_callback) {
+		wrb_context->internal_callback(
+			wrb_context->internal_callback_context,
+			be_mcc_wrb_status_to_bestatus(completion_status),
+			wrb_context->wrb);
+	}
+
+	/* callback */
+	if (wrb_context->callback) {
+		wrb_context->callback(wrb_context->callback_context,
+		      be_mcc_wrb_status_to_bestatus(completion_status),
+				      wrb_context->wrb);
+	}
+	/* Free the context structure */
+	_be_mcc_free_wrb_context(pfob, wrb_context);
+}
+
+void be_drive_mcc_wrb_queue(struct be_mcc_object *mcc)
+{
+	struct be_function_object *pfob = NULL;
+	BESTATUS status = BE_PENDING;
+	struct be_generic_queue_context *queue_context;
+	struct MCC_WRB_AMAP *wrb;
+	struct MCC_WRB_AMAP *queue_wrb;
+	u32 length, payload_length, sge_count, embedded;
+
+	pfob = mcc->parent_function;
+
+	be_lock_wrb_post(pfob);
+
+	if (mcc->driving_backlog) {
+		be_unlock_wrb_post(pfob);
+		return;
+	}
+	/* Acquire the flag to limit 1 thread to redrive posts. */
+	mcc->driving_backlog = 1;
+
+	while (!list_empty(&mcc->backlog)) {
+
+		wrb = _be_mpu_peek_ring_wrb(mcc, TRUE);	/* Driving the queue */
+		if (!wrb)
+			break;	/* No space in the ring yet. */
+		/* Get the next queued entry to process. */
+		queue_context = list_first_entry(&mcc->backlog,
+				struct be_generic_queue_context, context.list);
+		list_del(&queue_context->context.list);
+		pfob->links.mcc->backlog_length--;
+
+		/*
+		 * Compute the required length of the WRB.
+		 * Since the queue element may be smaller than
+		 * the complete WRB, copy only the required number of bytes.
+		 */
+		queue_wrb = (struct MCC_WRB_AMAP *) &queue_context->wrb_header;
+		embedded = AMAP_GET_BITS_PTR(MCC_WRB, embedded, queue_wrb);
+		if (embedded) {
+			payload_length = AMAP_GET_BITS_PTR(MCC_WRB,
+						payload_length, queue_wrb);
+			length = sizeof(struct be_mcc_wrb_header) +
+								payload_length;
+		} else {
+			sge_count = AMAP_GET_BITS_PTR(MCC_WRB, sge_count,
+								queue_wrb);
+			ASSERT(sge_count == 1); /* only 1 frag. */
+			length = sizeof(struct be_mcc_wrb_header) +
+			    sge_count * sizeof(struct MCC_SGE_AMAP);
+		}
+
+		/*
+		 * Truncate the length based on the size of the
+		 * queue element.  Some elements that have output parameters
+		 * can be smaller than the payload_length field would
+		 * indicate.  We really only need to copy the request
+		 * parameters, not the response.
+		 */
+		length = min(length, (u32) (queue_context->context.bytes -
+				SA_FIELD_OFFSET(be_generic_queue_context,
+					wrb_header)));
+
+		/* Copy the queue element WRB into the ring. */
+		memcpy(wrb, &queue_context->wrb_header, length);
+
+		/* Post the wrb.  This should not fail assuming we have
+		 * enough context structs. */
+		status = be_function_post_mcc_wrb_complete(pfob,
+				wrb, NULL,	/* Do not queue */
+			   queue_context->context.callback,
+			   queue_context->context.callback_context,
+			   queue_context->context.internal_callback,
+			   queue_context->context.internal_callback_context,
+			   queue_context->context.optional_fwcmd_va,
+			   queue_context->context.copy);
+
+		if (status == BE_SUCCESS) {
+
+			/*
+			 * Synchronous completion. Since it was queued,
+			 * we will invoke the callback.
+			 * To the user, this is an asynchronous request.
+			 */
+			be_unlock_wrb_post(pfob);
+
+			ASSERT(queue_context->context.callback);
+
+			queue_context->context.callback(
+				queue_context->context.callback_context,
+						BE_SUCCESS, NULL);
+
+			be_lock_wrb_post(pfob);
+
+		} else if (status != BE_PENDING) {
+			/*
+			 * Another resource failed.  Should never happen
+			 * if we have sufficient MCC_WRB_CONTEXT structs.
+			 * Return to head of the queue.
+			 */
+			TRACE(DL_WARN,
+			      "beclib : failed to post a queued WRB. 0x%x",
+			      status);
+			list_add(&queue_context->context.list, &mcc->backlog);
+			pfob->links.mcc->backlog_length++;
+			break;
+		}
+	}
+
+	pfob->stats.queue_length = pfob->links.mcc->backlog_length;
+
+	/* Free the flag to limit 1 thread to redrive posts. */
+	mcc->driving_backlog = 0;
+
+	be_unlock_wrb_post(pfob);
+}
+
+/* This function asserts that the WRB was consumed in order. */
+#ifdef SA_DEBUG
+u32 be_mcc_wrb_consumed_in_order(struct be_mcc_object *mcc,
+					struct MCC_CQ_ENTRY_AMAP *cqe)
+{
+	struct be_function_object *pfob = mcc->parent_function;
+	struct be_mcc_wrb_context *wrb_context = NULL;
+	u32 wrb_index;
+	u32 wrb_consumed_in_order;
+	u32 offset;
+	u8 *p;
+
+	ASSERT(cqe);
+
+	/*
+	 * A command completed.  Commands complete out-of-order.
+	 * Determine which command completed from the TAG.
+	 */
+	offset = AMAP_BYTE_OFFSET(MCC_CQ_ENTRY, mcc_tag);
+	p = (u8 *) cqe + offset;
+	wrb_context = (struct be_mcc_wrb_context *) SA_U64_TO_PTR(*((u64 *) p));
+
+	ASSERT(wrb_context);
+
+	wrb_index = (u32) (((SA_PTR_TO_U64(wrb_context->ring_wrb) -
+	     SA_PTR_TO_U64(mcc->sq.ring.va))) / sizeof(struct MCC_WRB_AMAP));
+	ASSERT(wrb_index < sa_ring_num(&mcc->sq.ring));
+
+	wrb_consumed_in_order = (u32) (wrb_index == mcc->consumed_index);
+	mcc->consumed_index =
+	    sa_addc(mcc->consumed_index, 1, sa_ring_num(&mcc->sq.ring));
+
+	return wrb_consumed_in_order;
+}
+#endif
+
+BESTATUS be_mcc_process_cq(struct be_mcc_object *mcc, bool rearm)
+{
+	struct be_function_object *pfob = NULL;
+	struct MCC_CQ_ENTRY_AMAP *cqe;
+	struct CQ_DB_AMAP db;
+	struct sa_ring *cq_ring = &mcc->cq.ring;
+	struct sa_ring *mcc_ring = &mcc->sq.ring;
+	u32 num_processed = 0;
+	u32 consumed = 0, valid, completed, cqe_consumed, async_event;
+
+	pfob = mcc->parent_function;
+
+	spin_lock_irqsave(&pfob->cq_lock, pfob->cq_irq);
+
+	pfob->stats.processed_cq++;
+
+	/*
+	 * Verify that only one thread is processing the CQ at once.
+	 * We cannot hold the lock while processing the CQ due to
+	 * the callbacks into the OS.  Therefore, this flag is used
+	 * to control it.  If any of the threads want to
+	 * rearm the CQ, we need to honor that.
+	 */
+	if (mcc->processing != 0) {
+		mcc->rearm = mcc->rearm || rearm;
+		goto Error;
+	} else {
+		mcc->processing = 1;	/* lock processing for this thread. */
+		mcc->rearm = rearm;	/* set our rearm setting */
+	}
+
+	spin_unlock_irqrestore(&pfob->cq_lock, pfob->cq_irq);
+
+	cqe = sa_ring_current(cq_ring);
+	valid = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY, valid, cqe);
+	while (valid) {
+
+		pfob->stats.cq_entries++;
+
+		if (num_processed >= 8) {
+			/* coalesce doorbells, but free space in cq
+			 * ring while processing. */
+			db.dw[0] = 0;	/* clear */
+			AMAP_SET_BITS_PTR(CQ_DB, qid, &db, cq_ring->id);
+			AMAP_SET_BITS_PTR(CQ_DB, rearm, &db, FALSE);
+			AMAP_SET_BITS_PTR(CQ_DB, event, &db, FALSE);
+			AMAP_SET_BITS_PTR(CQ_DB, num_popped, &db,
+							num_processed);
+			num_processed = 0;
+
+			PD_WRITE(pfob, cq_db, db);
+		}
+
+		async_event = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY, async_event, cqe);
+		if (async_event) {
+			/* This is an asynchronous event. */
+			struct ASYNC_EVENT_TRAILER_AMAP *async_trailer =
+			    (struct ASYNC_EVENT_TRAILER_AMAP *)
+			    ((u8 *) cqe + sizeof(struct MCC_CQ_ENTRY_AMAP) -
+			     sizeof(struct ASYNC_EVENT_TRAILER_AMAP));
+			u32 event_code;
+			async_event = AMAP_GET_BITS_PTR(ASYNC_EVENT_TRAILER,
+						async_event, async_trailer);
+			ASSERT(async_event == 1);
+
+
+			valid = AMAP_GET_BITS_PTR(ASYNC_EVENT_TRAILER,
+						valid, async_trailer);
+			ASSERT(valid == 1);
+
+			pfob->stats.async_events++;
+
+			/* Call the async event handler if it is installed. */
+			if (mcc->async_callback) {
+				event_code =
+					AMAP_GET_BITS_PTR(ASYNC_EVENT_TRAILER,
+						event_code, async_trailer);
+				mcc->async_callback(mcc->async_context,
+					    (u32) event_code,
+					    (void *) cqe);
+			} else {
+				pfob->stats.ignored_async_events++;
+			}
+
+		} else {
+			/* This is a completion entry. */
+
+			/* No vm forwarding in this driver. */
+
+			cqe_consumed = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY,
+						consumed, cqe);
+			if (cqe_consumed) {
+				/*
+				 * A command on the MCC ring was consumed.
+				 * Update the consumer index.
+				 * These occur in order.
+				 */
+				ASSERT(be_mcc_wrb_consumed_in_order(mcc, cqe));
+				consumed++;
+				pfob->stats.consumed_wrbs++;
+			}
+
+			completed = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY,
+					completed, cqe);
+			if (completed) {
+				/* A command completed.  Use tag to
+				 * determine which command.  */
+				be_mcc_process_cqe(pfob, cqe);
+				pfob->stats.completed_wrbs++;
+			}
+		}
+
+		/* Reset the CQE */
+		AMAP_SET_BITS_PTR(MCC_CQ_ENTRY, valid, cqe, FALSE);
+		num_processed++;
+
+		TRACE(DL_FWCMD, " update the cidx now cidx=%x", cq_ring->cidx);
+		/* Update our tracking for the CQ ring. */
+		cqe = sa_ring_next(cq_ring);
+		valid = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY, valid, cqe);
+	}
+
+	TRACE(DL_INFO, "num_processed:0x%x, and consumed:0x%x",
+	      num_processed, consumed);
+	/*
+	 * Grab the CQ lock to synchronize the "rearm" setting for
+	 * the doorbell, and for clearing the "processing" flag.
+	 */
+	spin_lock_irqsave(&pfob->cq_lock, pfob->cq_irq);
+
+	/*
+	 * Rearm the cq.  This is done based on the global mcc->rearm
+	 * flag which combines the rearm parameter from the current
+	 * call to process_cq and any other threads
+	 * that tried to process the CQ while this one was active.
+	 * This handles the situation where a sync. fwcmd was processing
+	 * the CQ while the interrupt/dpc tries to process it.
+	 * The sync process gets to continue -- but it is now
+	 * responsible for the rearming.
+	 */
+	if (num_processed > 0 || mcc->rearm == TRUE) {
+		db.dw[0] = 0;	/* clear */
+		AMAP_SET_BITS_PTR(CQ_DB, qid, &db, cq_ring->id);
+		AMAP_SET_BITS_PTR(CQ_DB, rearm, &db, mcc->rearm);
+		AMAP_SET_BITS_PTR(CQ_DB, event, &db, FALSE);
+		AMAP_SET_BITS_PTR(CQ_DB, num_popped, &db, num_processed);
+
+		PD_WRITE(pfob, cq_db, db);
+	}
+	/*
+	 * Update the consumer index after ringing the CQ doorbell.
+	 * We don't want another thread to post more WRBs before we
+	 * have CQ space available.
+	 */
+	sa_ring_consume_multiple(mcc_ring, consumed);
+
+	/* Clear the processing flag. */
+	mcc->processing = 0;
+
+Error:
+	spin_unlock_irqrestore(&pfob->cq_lock, pfob->cq_irq);
+	/*
+	 * Use the local variable to detect if the current thread
+	 * holds the WRB post lock.  If rearm is FALSE, this is
+	 * either a synchronous command, or the upper layer driver is polling
+	 * from a thread.  We do not drive the queue from that
+	 * context since the driver may hold the
+	 * wrb post lock already.
+	 */
+	if (rearm)
+		be_drive_mcc_wrb_queue(mcc);
+	else
+		pfob->pend_queue_driving = 1;
+
+	return BE_SUCCESS;
+}
+
+/*
+ *============================================================================
+ *                  P U B L I C  R O U T I N E S
+ *============================================================================
+ */
+
+/*
+    This routine creates an MCC object.  This object contains an MCC send queue
+    and a CQ private to the MCC.
+
+    pcontroller      - Handle to a function object
+
+    EqObject            - EQ object that will be used to dispatch this MCC
+
+    ppMccObject         - Pointer to an internal Mcc Object returned.
+
+    Returns BE_SUCCESS if successfull,, otherwise a useful error code
+	is returned.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+BESTATUS
+be_mcc_ring_create(struct be_function_object *pfob,
+		   struct sa_sgl *sgl, u32 length,
+		   struct be_mcc_wrb_context *context_array,
+		   u32 num_context_entries,
+		   struct be_cq_object *cq, struct be_mcc_object *mcc)
+{
+	BESTATUS status = 0;
+
+	struct FWCMD_COMMON_MCC_CREATE *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 num_entries_encoded, n, i;
+	void *va = NULL;
+
+	if (length < sizeof(struct MCC_WRB_AMAP) * 2) {
+		TRACE(DL_ERR, "Invalid MCC ring length:%d", length);
+		return BE_NOT_OK;
+	}
+	/*
+	 * Reduce the actual ring size to be less than the number
+	 * of context entries.  This ensures that we run out of
+	 * ring WRBs first so the queuing works correctly.  We never
+	 * queue based on context structs.
+	 */
+	if (num_context_entries + 1 <
+			length / sizeof(struct MCC_WRB_AMAP) - 1) {
+
+		u32 max_length =
+		    (num_context_entries + 2) * sizeof(struct MCC_WRB_AMAP);
+
+		length = sa_gt_power2(max_length) / 2;
+		ASSERT(length <= max_length);
+
+		TRACE(DL_WARN,
+			"MCC ring length reduced based on context entries."
+			" length:%d wrbs:%d context_entries:%d", length,
+			length / sizeof(struct MCC_WRB_AMAP),
+			num_context_entries);
+	}
+
+	be_lock_wrb_post(pfob);
+
+	num_entries_encoded =
+	    be_ring_length_to_encoding(length, sizeof(struct MCC_WRB_AMAP));
+
+	/* Init MCC object. */
+	memset(mcc, 0, sizeof(*mcc));
+	mcc->parent_function = pfob;
+	mcc->cq_object = cq;
+
+	INIT_LIST_HEAD(&mcc->backlog);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_MCC_CREATE);
+
+	fwcmd->params.request.num_pages = sa_ceiling(length, PAGE_SIZE);
+	/*
+	 * Program MCC ring context
+	 */
+	n = be_function_get_pd_number(pfob);
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT, pdid,
+			&fwcmd->params.request.context, n);
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT, invalid,
+			&fwcmd->params.request.context, FALSE);
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT, ring_size,
+			&fwcmd->params.request.context, num_entries_encoded);
+
+	n = be_cq_get_id(cq);
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT,
+				cq_id, &fwcmd->params.request.context, n);
+	be_sgl_to_pa_list(sgl, fwcmd->params.request.pages,
+				ARRAY_SIZE(fwcmd->params.request.pages));
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, fwcmd);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create CQ failed.");
+		goto error;
+	}
+	/*
+	 * Create a linked list of context structures
+	 */
+	mcc->wrb_context.base = context_array;
+	mcc->wrb_context.num = num_context_entries;
+	INIT_LIST_HEAD(&mcc->wrb_context.list_head);
+	memset(context_array, 0,
+		    sizeof(struct be_mcc_wrb_context) * num_context_entries);
+	for (i = 0; i < mcc->wrb_context.num; i++) {
+		list_add_tail(&context_array[i].next,
+					&mcc->wrb_context.list_head);
+	}
+
+	/*
+	 *
+	 * Create an sa_ring for tracking WRB hw ring
+	 */
+	va = sa_sgl_get_base_va(sgl);
+	ASSERT(va);
+	sa_ring_create(&mcc->sq.ring, length / sizeof(struct MCC_WRB_AMAP),
+				sizeof(struct MCC_WRB_AMAP), va);
+	mcc->sq.ring.id = fwcmd->params.response.id;
+	/*
+	 * Init a sa_ring for tracking the MCC CQ.
+	 */
+	ASSERT(cq->va);
+	sa_ring_create(&mcc->cq.ring, cq->num_entries,
+		       sizeof(struct MCC_CQ_ENTRY_AMAP), cq->va);
+	mcc->cq.ring.id = be_cq_get_id(cq);
+
+	/* Force zeroing of CQ. */
+	memset(cq->va, 0, cq->num_entries * sizeof(struct MCC_CQ_ENTRY_AMAP));
+
+	/* Initialize debug index. */
+	mcc->consumed_index = 0;
+
+	be_cq_object_reference(cq);
+	_be_function_add_mcc(pfob, mcc);
+
+	TRACE(DL_INFO, "MCC ring created. id:%d bytes:%d cq_id:%d cq_entries:%d"
+	      " num_context:%d", mcc->sq.ring.id, length,
+	      be_cq_get_id(cq), cq->num_entries, num_context_entries);
+
+error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+u32 be_mcc_get_id(struct be_mcc_object *mcc)
+{
+	return mcc->sq.ring.id;
+}
+
+/*
+    This routine destroys an MCC send queue
+
+    MccObject         - Internal Mcc Object to be destroyed.
+
+    Returns BE_SUCCESS if successfull, otherwise an error code is returned.
+
+    IRQL < DISPATCH_LEVEL
+
+    The caller of this routine must ensure that no other WRB may be posted
+    until this routine returns.
+
+*/
+BESTATUS be_mcc_ring_destroy(struct be_mcc_object *mcc)
+{
+	BESTATUS status = 0;
+
+
+	ASSERT(mcc->processing == 0);
+
+	/*
+	 * Remove the ring from the function object.
+	 * This transitions back to mailbox mode.
+	 */
+	_be_function_remove_mcc(mcc->parent_function, mcc);
+
+	/* Send fwcmd to destroy the queue.  (Using the mailbox.) */
+	status =
+	    be_function_ring_destroy(mcc->parent_function, mcc->sq.ring.id,
+				     FWCMD_RING_TYPE_MCC);
+	ASSERT(status == 0);
+
+	/* Release the SQ reference to the CQ */
+	be_cq_object_dereference(mcc->cq_object);
+
+	return status;
+}
+
+static void
+mcc_wrb_sync_callback(void *context, BESTATUS completion_status,
+						struct MCC_WRB_AMAP *wrb)
+{
+	struct be_mcc_wrb_context *wrb_context =
+				(struct be_mcc_wrb_context *) context;
+	ASSERT(wrb_context);
+	*wrb_context->users_final_status = completion_status;
+}
+
+/*
+    This routine posts a command to the MCC send queue
+
+    mcc       - Internal Mcc Object to be destroyed.
+
+    wrb             - wrb to post.
+
+    Returns BE_SUCCESS if successfull, otherwise an error code is returned.
+
+    IRQL < DISPATCH_LEVEL if CompletionCallback is not NULL
+    IRQL <=DISPATCH_LEVEL if CompletionCallback is  NULL
+
+    If this routine is called with CompletionCallback != NULL the
+    call is considered to be asynchronous and will return as soon
+    as the WRB is posted to the MCC with BE_PENDING.
+
+    If CompletionCallback is NULL, then this routine will not return until
+    a completion for this MCC command has been processed.
+    If called at DISPATCH_LEVEL the CompletionCallback must be NULL.
+
+    This routine should only be called if the MPU has been boostraped past
+    mailbox mode.
+
+
+*/
+BESTATUS
+_be_mpu_post_wrb_ring(struct be_mcc_object *mcc, struct MCC_WRB_AMAP *wrb,
+				struct be_mcc_wrb_context *wrb_context)
+{
+
+	struct MCC_WRB_AMAP *ring_wrb = NULL;
+	BESTATUS status = BE_PENDING;
+	BESTATUS final_status = BE_PENDING;
+	MCC_WRB_CQE_CALLBACK callback = NULL;
+	struct MCC_DB_AMAP mcc_db;
+	u32 embedded;
+
+	ASSERT(sa_ring_num_empty(&mcc->sq.ring) > 0);
+	/*
+	 * Input wrb is most likely the next wrb in the ring, since the client
+	 * can peek at the address.
+	 */
+	ring_wrb = sa_ring_producer_ptr(&mcc->sq.ring);
+	if (wrb != ring_wrb) {
+		/* If not equal, copy it into the ring. */
+		memcpy(ring_wrb, wrb, sizeof(struct MCC_WRB_AMAP));
+	}
+	/* Minimal verification of posted WRB. */
+
+	embedded = AMAP_GET_BITS_PTR(MCC_WRB, embedded, ring_wrb);
+	if (embedded) {
+		/* embedded commands will have the response within the WRB. */
+		wrb_context->wrb = ring_wrb;
+	} else {
+		/*
+		 * non-embedded commands will not have the response
+		 * within the WRB, and they may complete out-of-order.
+		 * The WRB will not be valid to inspect
+		 * during the completion.
+		 */
+		wrb_context->wrb = NULL;
+	}
+
+	callback = wrb_context->callback;
+
+	if (callback == NULL) {
+		/* Assign our internal callback if this is a
+		 * synchronous call. */
+		wrb_context->callback = mcc_wrb_sync_callback;
+		wrb_context->callback_context = wrb_context;
+		wrb_context->users_final_status = &final_status;
+
+		mcc->parent_function->stats.synchronous_wrbs++;
+	}
+	/* Increment producer index */
+
+	mcc_db.dw[0] = 0;		/* initialize */
+	AMAP_SET_BITS_PTR(MCC_DB, rid, &mcc_db, mcc->sq.ring.id);
+	AMAP_SET_BITS_PTR(MCC_DB, numPosted, &mcc_db, 1);
+
+	mcc->parent_function->stats.posted_wrbs++;
+
+	sa_ring_produce(&mcc->sq.ring);
+	PD_WRITE(mcc->parent_function, mpu_mcc_db, mcc_db);
+	TRACE(DL_INFO, "pidx: %x and cidx: %x.", mcc->sq.ring.pidx,
+	      mcc->sq.ring.cidx);
+
+	if (callback == NULL) {
+
+		int polls = 0;	/* At >= 1 us per poll   */
+
+		/* Wait until this command completes, polling the CQ. */
+		do {
+
+			TRACE(DL_INFO,
+			      "FWCMD submitted in the poll mode.");
+			/* Do not rearm CQ in this context. */
+			be_mcc_process_cq(mcc, FALSE);
+
+			if (final_status == BE_PENDING) {
+				if ((++polls & 0x7FFFF) == 0) {
+					TRACE(DL_WARN,
+					      "Warning : polling MCC CQ for %d"
+					      "ms.", polls / 1000);
+				}
+
+				sa_dev_stall(mcc->parent_function->sa_dev, 1);
+			}
+
+			/* final_status changed when the command completes */
+		} while (final_status == BE_PENDING);
+
+		status = final_status;
+	}
+
+	return status;
+}
+
+struct MCC_WRB_AMAP *
+_be_mpu_peek_ring_wrb(struct be_mcc_object *mcc, bool driving_queue)
+{
+	/* If we have queued items, do not allow a post to bypass the queue. */
+	if (!driving_queue && !list_empty(&mcc->backlog))
+		return NULL;
+
+	if (sa_ring_num_empty(&mcc->sq.ring) <= 0)
+		return NULL;
+	return (struct MCC_WRB_AMAP *) sa_ring_producer_ptr(&mcc->sq.ring);
+}
+
+BESTATUS
+be_mpu_init_mailbox(struct be_function_object *pfob, struct sa_sgl *mailbox)
+{
+	ASSERT(mailbox);
+	pfob->mailbox.va = mailbox->va;
+	pfob->mailbox.pa =  cpu_to_le64(mailbox->pa);
+	pfob->mailbox.length = mailbox->length;
+
+	ASSERT((SA_PTR_TO_U32(pfob->mailbox.va) & 0xf) == 0);
+	ASSERT((SA_PTR_TO_U32(pfob->mailbox.pa) & 0xf) == 0);
+	/*
+	 * Issue the WRB to set MPU endianness
+	 */
+	{
+		u64 *endian_check = (u64 *) (pfob->mailbox.va +
+					AMAP_BYTE_OFFSET(MCC_MAILBOX, wrb));
+		*endian_check = 0xFF1234FFFF5678FFULL;
+	}
+
+	be_mcc_mailbox_notify_and_wait(pfob);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS be_mpu_uninit_mailbox(struct be_function_object *pfob)
+{
+	ASSERT(pfob->mailbox.va);
+	ASSERT((SA_PTR_TO_U32(pfob->mailbox.va) & 0xf) == 0);
+	ASSERT((SA_PTR_TO_U32(pfob->mailbox.pa) & 0xf) == 0);
+	/*
+	 * Issue the WRB to indicate mailbox teardown
+	 */
+	{
+		u8 *mbox_unint;
+		u32 offset;
+
+		offset = AMAP_BYTE_OFFSET(MCC_MAILBOX, wrb);
+		mbox_unint = (u8 *) pfob->mailbox.va +
+				offset;
+
+		*mbox_unint++ = 0xFF;	/* byte 0 */
+		*mbox_unint++ = 0xAA;	/* byte 1 */
+		*mbox_unint++ = 0xBB;	/* byte 2 */
+		*mbox_unint++ = 0xFF;	/* byte 3 */
+		*mbox_unint++ = 0xFF;	/* byte 4 */
+		*mbox_unint++ = 0xCC;	/* byte 5 */
+		*mbox_unint++ = 0xDD;	/* byte 6 */
+		*mbox_unint++ = 0xFF;	/* byte 7 */
+	}
+
+	be_mcc_mailbox_notify_and_wait(pfob);
+
+	return BE_SUCCESS;
+}
+
+/*
+    This routine posts a command to the MCC mailbox.
+
+    FuncObj         - Function Object to post the WRB on behalf of.
+    wrb             - wrb to post.
+    CompletionCallback  - Address of a callback routine to invoke once the WRB
+				is completed.
+    CompletionCallbackContext - Opaque context to be passed during the call to
+				the CompletionCallback.
+    Returns BE_SUCCESS if successfull, otherwise an error code is returned.
+
+    IRQL <=DISPATCH_LEVEL if CompletionCallback is  NULL
+
+    This routine will block until a completion for this MCC command has been
+    processed. If called at DISPATCH_LEVEL the CompletionCallback must be NULL.
+
+    This routine should only be called if the MPU has not been boostraped past
+    mailbox mode.
+*/
+BESTATUS
+_be_mpu_post_wrb_mailbox(struct be_function_object *pfob,
+	 struct MCC_WRB_AMAP *wrb, struct be_mcc_wrb_context *wrb_context)
+{
+	struct MCC_MAILBOX_AMAP *mailbox = NULL;
+	struct MCC_WRB_AMAP *mb_wrb;
+	struct MCC_CQ_ENTRY_AMAP *mb_cq;
+	u32 offset, completion_status;
+
+	ASSERT(pfob->links.mcc == NULL);
+	mailbox = pfob->mailbox.va;
+	ASSERT(mailbox);
+
+	offset = AMAP_BYTE_OFFSET(MCC_MAILBOX, wrb);
+	mb_wrb = (struct MCC_WRB_AMAP *) (u8 *)mailbox + offset;
+	if (mb_wrb != wrb) {
+		memset(mailbox, 0, sizeof(*mailbox));
+		memcpy(mb_wrb, wrb, sizeof(struct MCC_WRB_AMAP));
+	}
+	/* The callback can inspect the final WRB to get output parameters. */
+	wrb_context->wrb = mb_wrb;
+
+	be_mcc_mailbox_notify_and_wait(pfob);
+
+	/* A command completed.  Use tag to determine which command. */
+	offset = AMAP_BYTE_OFFSET(MCC_MAILBOX, cq);
+	mb_cq = (struct MCC_CQ_ENTRY_AMAP *) ((u8 *)mailbox + offset);
+	be_mcc_process_cqe(pfob, mb_cq);
+
+	completion_status = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY,
+				completion_status, mb_cq);
+	return be_mcc_wrb_status_to_bestatus(completion_status);
+}
+
+struct be_mcc_wrb_context *
+_be_mcc_allocate_wrb_context(struct be_function_object *pfob)
+{
+	struct be_mcc_wrb_context *context = NULL;
+	unsigned long irq;
+
+	spin_lock_irqsave(&pfob->mcc_context_lock, irq);
+
+	if (!pfob->mailbox.default_context_allocated) {
+		/* Use the single default context that we
+		 * always have allocated. */
+		pfob->mailbox.default_context_allocated = TRUE;
+		context = &pfob->mailbox.default_context;
+	} else if (pfob->links.mcc) {
+		/* Get a context from the free list. If any are available. */
+		if (!list_empty(&pfob->links.mcc->wrb_context.list_head)) {
+			context = list_first_entry(
+				&pfob->links.mcc->wrb_context.list_head,
+					 struct be_mcc_wrb_context, next);
+		}
+	}
+
+	spin_unlock_irqrestore(&pfob->mcc_context_lock, irq);
+
+	return context;
+}
+
+void
+_be_mcc_free_wrb_context(struct be_function_object *pfob,
+			 struct be_mcc_wrb_context *context)
+{
+	unsigned long irq;
+
+	ASSERT(context);
+	/*
+	 * Zero during free to try and catch any bugs where the context
+	 * is accessed after a free.
+	 */
+	memset(context, 0, sizeof(context));
+
+	spin_lock_irqsave(&pfob->mcc_context_lock, irq);
+
+	if (context == &pfob->mailbox.default_context) {
+		/* Free the default context. */
+		ASSERT(pfob->mailbox.default_context_allocated);
+		pfob->mailbox.default_context_allocated = FALSE;
+	} else {
+		/* Add to free list. */
+		ASSERT(pfob->links.mcc);
+		list_add_tail(&context->next,
+				&pfob->links.mcc->wrb_context.list_head);
+	}
+
+	spin_unlock_irqrestore(&pfob->mcc_context_lock, irq);
+}
+
+BESTATUS
+be_mcc_add_async_event_callback(struct be_mcc_object *mcc_object,
+		MCC_ASYNC_EVENT_CALLBACK callback, void *callback_context)
+{
+	/* Lock against anyone trying to change the callback/context pointers
+	 * while being used. */
+	spin_lock_irqsave(&mcc_object->parent_function->cq_lock,
+		mcc_object->parent_function->cq_irq);
+
+	/* Assign the async callback. */
+	mcc_object->async_context = callback_context;
+	mcc_object->async_callback = callback;
+
+	spin_unlock_irqrestore(&mcc_object->parent_function->cq_lock,
+		mcc_object->parent_function->cq_irq);
+
+	return BE_SUCCESS;
+}
+
+#define MPU_EP_CONTROL 0
+#define MPU_EP_SEMAPHORE 0xac
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_wait_for_POST_complete
+ *   Waits until the BladeEngine POST completes (either in error or success).
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+static BESTATUS be_wait_for_POST_complete(struct be_function_object *pfob)
+{
+	struct MGMT_HBA_POST_STATUS_STRUCT_AMAP postStatus;
+	BESTATUS status;
+	u32 post_error, post_stage;
+
+	const u32 us_per_loop = 1000;	/* 1000us */
+	const u32 print_frequency_loops = 1000000 / us_per_loop;
+	const u32 max_loops = 60 * print_frequency_loops;
+	u32 loops = 0;
+
+	/*
+	 * Wait for arm fw indicating it is done or a fatal error happened.
+	 * Note: POST can take some time to complete depending on configuration
+	 * settings (consider ARM attempts to acquire an IP address
+	 * over DHCP!!!).
+	 *
+	 */
+	do {
+		postStatus.dw[0] =
+		    BeCsrRead(pfob->sa_dev, MPU_EP_SEMAPHORE, NULL);
+		post_error = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						error, &postStatus);
+		post_stage = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						stage, &postStatus);
+		if (0 == (loops % print_frequency_loops)) {
+			/* Print current status */
+			TRACE(DL_INFO, "POST status = 0x%x (stage = 0x%x)",
+				postStatus.dw[0], post_stage);
+		}
+		sa_dev_stall(pfob->sa_dev, us_per_loop);
+	} while ((post_error != 1) &&
+		 (post_stage != POST_STAGE_ARMFW_READY) &&
+		 (++loops < max_loops));
+
+	if (post_error == 1) {
+		TRACE(DL_ERR, "POST error! Status = 0x%x (stage = 0x%x)",
+		      postStatus.dw[0], post_stage);
+		status = BE_NOT_OK;
+	} else if (post_stage != POST_STAGE_ARMFW_READY) {
+		TRACE(DL_ERR,
+		      "POST time-out! Status = 0x%x (stage = 0x%x)",
+		      postStatus.dw[0], post_stage);
+		status = BE_NOT_OK;
+	} else {
+		status = BE_SUCCESS;
+	}
+
+	return status;
+}
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_kickoff_and_wait_for_POST
+ *   Interacts with the BladeEngine management processor to initiate POST, and
+ *   subsequently waits until POST completes (either in error or success).
+ *   The caller must acquire the reset semaphore before initiating POST
+ *   to prevent multiple drivers interacting with the management processor.
+ *   Once POST is complete the caller must release the reset semaphore.
+ *   Callers who only want to wait for POST complete may call
+ *   be_wait_for_POST_complete.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+static BESTATUS
+be_kickoff_and_wait_for_POST(struct be_function_object *pfob)
+{
+	struct MGMT_HBA_POST_STATUS_STRUCT_AMAP postStatus;
+	BESTATUS status;
+
+	const u32 us_per_loop = 1000;	/* 1000us */
+	const u32 print_frequency_loops = 1000000 / us_per_loop;
+	const u32 max_loops = 5 * print_frequency_loops;
+	u32 loops = 0;
+	u32 post_error, post_stage;
+
+	/* Wait for arm fw awaiting host ready or a fatal error happened. */
+	TRACE(DL_INFO, "Wait for BladeEngine ready to POST");
+	do {
+		postStatus.dw[0] =
+		    BeCsrRead(pfob->sa_dev, MPU_EP_SEMAPHORE, NULL);
+		post_error = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						error, &postStatus);
+		post_stage = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						stage, &postStatus);
+		if (0 == (loops % print_frequency_loops)) {
+			/* Print current status */
+			TRACE(DL_INFO, "POST status = 0x%x (stage = 0x%x)",
+			      postStatus.dw[0], post_stage);
+		}
+		sa_dev_stall(pfob->sa_dev, us_per_loop);
+	} while ((post_error != 1) &&
+		 (post_stage < POST_STAGE_AWAITING_HOST_RDY) &&
+		 (++loops < max_loops));
+
+	if (post_error == 1) {
+		TRACE(DL_ERR,
+		      "Pre-POST error! Status = 0x%x (stage = 0x%x)",
+		      postStatus.dw[0], post_stage);
+		status = BE_NOT_OK;
+	} else if (post_stage == POST_STAGE_AWAITING_HOST_RDY) {
+		BeCsrWrite(pfob->sa_dev, MPU_EP_SEMAPHORE,
+			   POST_STAGE_HOST_RDY, NULL);
+
+		/* Wait for POST to complete */
+		status = be_wait_for_POST_complete(pfob);
+	} else {
+		/*
+		 * Either a timeout waiting for host ready signal or POST has
+		 * moved ahead without requiring a host ready signal.
+		 * Might as well give POST a chance to complete
+		 * (or timeout again).
+		 */
+		status = be_wait_for_POST_complete(pfob);
+	}
+
+	return status;
+}
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_pci_soft_reset
+ *   This function is called to issue a BladeEngine soft reset.
+ *   Callers should acquire the soft reset semaphore before calling this
+ *   function. Additionaly, callers should ensure they cannot be pre-empted
+ *   while the routine executes. Upon completion of this routine, callers
+ *   should release the reset semaphore. This routine implicitly waits
+ *   for BladeEngine POST to complete.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS be_pci_soft_reset(struct be_function_object *pfob)
+{
+	struct PCICFG_SOFT_RESET_CSR_AMAP soft_reset;
+	struct PCICFG_ONLINE0_CSR_AMAP pciOnline0;
+	struct PCICFG_ONLINE1_CSR_AMAP pciOnline1;
+	struct EP_CONTROL_CSR_AMAP epControlCsr;
+	BESTATUS status = BE_SUCCESS;
+	u32 i, soft_reset_bit;
+
+	TRACE(DL_NOTE, "PCI reset...");
+
+	/* Issue soft reset #1 to get BladeEngine into a known state. */
+	soft_reset.dw[0] = PCICFG0_READ(pfob, soft_reset);
+	AMAP_SET_BITS_PTR(PCICFG_SOFT_RESET_CSR, softreset, soft_reset.dw, 1);
+	PCICFG0_WRITE(pfob, host_timer_int_ctrl, soft_reset.dw[0]);
+
+	/*
+	 * wait til soft reset is deasserted - hardware
+	 * deasserts after some time.
+	 */
+	i = 0;
+	do {
+		sa_dev_stall(pfob->sa_dev, 50);
+		soft_reset.dw[0] = PCICFG0_READ(pfob, soft_reset);
+		soft_reset_bit = AMAP_GET_BITS_PTR(PCICFG_SOFT_RESET_CSR,
+					softreset, soft_reset.dw);
+	} while (soft_reset_bit  && (i++ < 1024));
+	if (soft_reset_bit != 0) {
+		TRACE(DL_ERR, "Soft-reset #1 did not deassert as expected.");
+		status = BE_NOT_OK;
+		goto Error_label;
+	}
+	/* Mask everything  */
+	PCICFG0_WRITE_CONST(pfob, ue_status_low_mask, 0xFFFFFFFF);
+	PCICFG0_WRITE_CONST(pfob, ue_status_hi_mask, 0xFFFFFFFF);
+
+	/*
+	 * Set everything offline except MPU IRAM (it is offline with
+	 * the soft-reset, but soft-reset does not reset the PCICFG registers!)
+	 */
+
+	pciOnline0.dw[0] = 0;
+	pciOnline1.dw[0] = 0;
+	AMAP_SET_BITS_PTR(PCICFG_ONLINE1_CSR, mpu_iram_online,
+				pciOnline1.dw, 1);
+	PCICFG0_WRITE(pfob, online0, pciOnline0.dw[0]);
+	PCICFG0_WRITE(pfob, online1, pciOnline1.dw[0]);
+
+	sa_dev_stall(pfob->sa_dev, 20000);
+
+	/* Issue soft reset #2. */
+	AMAP_SET_BITS_PTR(PCICFG_SOFT_RESET_CSR, softreset, soft_reset.dw, 1);
+	PCICFG0_WRITE(pfob, host_timer_int_ctrl, soft_reset.dw[0]);
+
+	/*
+	 * wait til soft reset is deasserted - hardware
+	 * deasserts after some time.
+	 */
+	i = 0;
+	do {
+		sa_dev_stall(pfob->sa_dev, 50);
+		soft_reset.dw[0] = PCICFG0_READ(pfob, soft_reset);
+		soft_reset_bit = AMAP_GET_BITS_PTR(PCICFG_SOFT_RESET_CSR,
+					softreset, soft_reset.dw);
+	} while (soft_reset_bit  && (i++ < 1024));
+	if (soft_reset_bit != 0) {
+		TRACE(DL_ERR, "Soft-reset #1 did not deassert as expected.");
+		status = BE_NOT_OK;
+		goto Error_label;
+	}
+
+
+	sa_dev_stall(pfob->sa_dev, 20000);
+
+	/* Take MPU out of reset. */
+
+	epControlCsr.dw[0] =
+	    BeCsrRead(pfob->sa_dev, MPU_EP_CONTROL, NULL);
+	AMAP_SET_BITS_PTR(EP_CONTROL_CSR, CPU_reset, &epControlCsr, 0);
+	BeCsrWrite(pfob->sa_dev, MPU_EP_CONTROL,
+		   (u32)epControlCsr.dw, NULL);
+
+	/* Kickoff BE POST and wait for completion */
+	status = be_kickoff_and_wait_for_POST(pfob);
+
+Error_label:
+	return status;
+}
+
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_pci_reset_required
+ *   This private function is called to detect if a host entity is
+ *   required to issue a PCI soft reset and subsequently drive
+ *   BladeEngine POST. Scenarios where this is required:
+ *   1) BIOS-less configuration
+ *   2) Hot-swap/plug/power-on
+ * pfob -
+ * return   TRUE if a reset is required, FALSE otherwise
+ *-------------------------------------------------------------------
+ */
+static bool be_pci_reset_required(struct be_function_object *pfob)
+{
+	struct MGMT_HBA_POST_STATUS_STRUCT_AMAP postStatus;
+	bool doReset = FALSE;
+	u32 post_error, post_stage;
+
+	/*
+	 * Read the POST status register
+	 */
+	postStatus.dw[0] = BeCsrRead(pfob->sa_dev, MPU_EP_SEMAPHORE, NULL);
+	post_error = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT, error,
+								&postStatus);
+	post_stage = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT, stage,
+								&postStatus);
+	if (post_stage <= POST_STAGE_AWAITING_HOST_RDY) {
+		/*
+		 * If BladeEngine is waiting for host ready indication,
+		 * we want to do a PCI reset.
+		 */
+		doReset = TRUE;
+	}
+
+	return doReset;
+}
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_drive_POST
+ *   This function is called to drive BladeEngine POST. The
+ *   caller should ensure they cannot be pre-empted while this routine executes.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS be_drive_POST(struct be_function_object *pfob)
+{
+	BESTATUS status;
+
+	if (FALSE != be_pci_reset_required(pfob)) {
+		/* PCI reset is needed (implicitly starts and waits for POST) */
+		status = be_pci_soft_reset(pfob);
+	} else {
+		/* No PCI reset is needed, start POST */
+		status = be_kickoff_and_wait_for_POST(pfob);
+	}
+
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

