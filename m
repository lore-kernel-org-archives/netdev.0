From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 8/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:43:27 -0800
Message-ID: <20080217024327.d5a49cac@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:14752 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbYBQCnc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:43:32 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:43:28 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Event queue, completion queue and management
processor ring creation functions in
beclib.

--------------------------------
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/eq_ll.c benet/linux-2.6.24.2/drivers/message/beclib/eq_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/eq_ll.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/eq_ll.c	2008-02-14 15:23:07.809205584 +0530
@@ -0,0 +1,751 @@
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
+ *============================================================================
+ *                            F I L E   S C O P E
+ *============================================================================
+ */
+
+/*!
+
+@brief
+    This routine serializes access to resources maintained through an EQ object.
+
+@param
+    eq_object      - The event queue object to acquire the lock for.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+
+STATIC void _be_eq_lock(IN PBE_EQ_OBJECT eq_object)
+{
+	SA_NOT_USED(eq_object);
+	/*
+	 * BUG - Work around storport driver dispatch issues.
+	 *SA_ASSERT_BLOCKING ();
+	 *be_lock_acquire (&eq_object->lock);
+	 */
+}
+
+/*!
+
+@brief
+    This routine removes serialization done by EqObjectLock.
+@param
+    eq_object      - the event queue object to drop the lock for.
+@return
+@note
+    IRQL < DISPATCH_LEVEL
+*/
+STATIC void _be_eq_unlock(IN PBE_EQ_OBJECT eq_object)
+{
+	SA_NOT_USED(eq_object);
+	/*be_lock_release (&eq_object->lock); */
+}
+
+STATIC
+    INLINE
+    PBE_EQ_OBJECT
+_be_eq_id_to_object(IN PBE_FUNCTION_OBJECT function_object, IN u32 eq_id)
+{
+	PBE_EQ_OBJECT eq_cur;
+	PBE_EQ_OBJECT eq_ret = NULL;
+
+	_be_function_lock(function_object);
+
+	SA_FOR_EACH_LIST_ENTRY(eq_cur, function_object->links.eq_list_head,
+			       BE_EQ_OBJECT, eq_list) {
+		if (be_eq_get_id(eq_cur) == eq_id) {
+
+			eq_ret = eq_cur;
+			break;
+		}
+	}
+
+	_be_function_unlock(function_object);
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
+/*!
+
+@brief
+    This routine creates an event queue based on the client completion
+    queue configuration information.
+
+@param
+    FunctionObject      - Handle to a function object
+@param
+    EqBaseVa            - Base VA for a the EQ ring
+@param
+    SizeEncoding        - The encoded size for the EQ entries. This value is
+			either CEV_EQ_SIZE_4 or CEV_EQ_SIZE_16
+@param
+    NumEntries          - CEV_CQ_CNT_* values.
+@param
+    Watermark           - Enables watermark based coalescing.  This parameter
+			must be of the type CEV_WMARK_* if watermarks
+			are enabled.  If watermarks to to be disabled
+			this value should be-1.
+@param
+    TimerDelay          - If a timer delay is enabled this value should be the
+			time of the delay in 8 microsecond units.  If
+			delays are not used this parameter should be
+			set to -1.
+@param
+    ppEqObject          - Internal EQ Handle returned.
+
+@return
+    BE_SUCCESS if successfull,, otherwise a useful error code is returned.
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+     If the FunctionObject represents an ISCSI function, then the EQID
+     returned will be between 0-31.
+*/
+BESTATUS be_eq_create_internal(PBE_FUNCTION_OBJECT function_object,
+		PSA_SGL sgl, u32 eqe_size, u32 num_entries,
+		u32 watermark,	/* CEV_WMARK_* or -1 */
+		u32 timer_delay,	/* in 8us units, or -1 */
+		boolean fake_eq, PBE_EQ_OBJECT eq_object)
+{
+	BESTATUS status = BE_SUCCESS;
+	u32 num_entries_encoding, eqe_size_encoding, length;
+	IOCTL_COMMON_EQ_CREATE *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+
+	ASSERT(sgl);
+	ASSERT(eq_object);
+
+	FUNCTION_ASSERT(function_object);
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
+	sa_zero_mem(eq_object, sizeof(*eq_object));
+
+	eq_object->magic = BE_EQ_MAGIC;
+	eq_object->ref_count = 0;
+	eq_object->parent_function = function_object;
+	eq_object->eq_id = 0xFFFFFFFF;
+
+	be_lock_init(&eq_object->lock);
+
+	sa_initialize_list_head(&eq_object->cq_list_head);
+
+	length = num_entries * eqe_size;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_EQ_CREATE);
+
+	ioctl->params.request.num_pages =
+	    SA_PAGES_SPANNED(sa_sgl_get_offset(sgl), length);
+
+	/* init the context */
+	ioctl->params.request.context.Func =
+	    be_function_get_function_number(function_object);
+	ioctl->params.request.context.valid = TRUE;
+	ioctl->params.request.context.Size = eqe_size_encoding;
+	ioctl->params.request.context.PD =
+	    be_function_get_pd_number(function_object);
+	ioctl->params.request.context.Count = num_entries_encoding;
+	/* Let the caller ARM the EQ with the doorbell. */
+	ioctl->params.request.context.Armed = FALSE;
+	ioctl->params.request.context.EventVect =
+	    be_function_get_function_number(function_object) * 32;
+
+	if (fake_eq) {
+		ioctl->params.request.context.Cidx = 0;
+		ioctl->params.request.context.Pidx = 2;
+		ioctl->params.request.context.EPIdx = 2;
+	}
+
+	if (watermark != -1) {
+		ioctl->params.request.context.WME = TRUE;
+		ioctl->params.request.context.Watermark = watermark;
+		ASSERT(watermark <= CEV_WMARK_240);
+	} else {
+		ioctl->params.request.context.WME = FALSE;
+	}
+
+	if (timer_delay != -1) {
+		ioctl->params.request.context.TMR = TRUE;
+
+		ASSERT(timer_delay <= 250);	/* max value according to EAS */
+		timer_delay = MIN(timer_delay, 250);
+
+		ioctl->params.request.context.Delay = timer_delay;
+
+	} else {
+		ioctl->params.request.context.TMR = FALSE;
+	}
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl,
+			  ioctl->params.request.pages,
+			  SA_NUMBER_OF(ioctl->params.request.pages));
+
+	status =
+	    be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create EQ failed.");
+		goto Error;
+	}
+	/* Get the EQ id.  The MPU allocates the IDs. */
+	eq_object->eq_id = ioctl->params.response.eq_id;
+
+	/* insert tracking object */
+	_be_function_add_eq(function_object, eq_object);
+
+	TRACE(DL_INFO,
+	      "eq created. function:%d pd:%d eqid:%d bytes:%d eqeBytes:%d"
+	      " wm:%d td:%d",
+	      be_function_get_function_number(function_object),
+	      be_function_get_pd_number(function_object), eq_object->eq_id,
+	      num_entries * eqe_size, eqe_size, watermark, timer_delay);
+
+Error:
+	be_unlock_wrb_post(function_object);
+	return status;
+}
+
+BESTATUS be_eq_create(PBE_FUNCTION_OBJECT function_object, PSA_SGL
+		sgl, u32 eqe_size, u32 num_entries,
+		u32 watermark,	/* CEV_WMARK_* or -1 */
+		u32 timer_delay,	/* in 8us units, or -1 */
+		PBE_EQ_OBJECT eq_object)
+{
+	return be_eq_create_internal(function_object,
+				     sgl,
+				     eqe_size,
+				     num_entries,
+				     watermark,
+				     timer_delay, FALSE, eq_object);
+}
+
+BESTATUS be_eq_fake_create(PBE_FUNCTION_OBJECT function_object,
+		u32 timer_delay,	/* in 8us units, or -1 */
+		PBE_EQ_OBJECT eq_object)
+{
+	SA_SGL sgl;
+
+	sa_sgl_create_contiguous((PVOID) 0xbad0000,
+				 (SA_PHYSICAL_ADDRESS) 0xbad00000,
+				 SA_PAGE_SIZE, &sgl);
+
+	return be_eq_create_internal(function_object,
+				     &sgl,
+				     sizeof(EQ_ENTRY),
+				     4096 / sizeof(EQ_ENTRY),
+				     0xFFFFFFFF,
+				     timer_delay, TRUE, eq_object);
+}
+
+/*!
+
+@brief
+    Returns the EQ ID for EQ. This is the ID the chip references the queue as.
+
+@param
+    EqObject            - EQ Handle returned from EqObjectCreate.
+
+@return
+    EQ ID
+@note
+    IRQL: any
+
+*/
+u32 be_eq_get_id(IN PBE_EQ_OBJECT eq_object)
+{
+	EQ_ASSERT(eq_object);
+	return eq_object->eq_id;
+}
+
+/*!
+
+@brief
+    Sets the current callback to be invoked when a EQ entry is made available.
+    This need only be set if the owner of this EQ does not recieve the EQ
+    completions directly. i.e. it does not service interrupts.
+
+@param
+    eq_object            - EQ handle returned from eq_object_create.
+
+@param
+    callback            - function to invoke when the EQ needs processing.
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
+    this routine is currently not synchronized w/ the DPC that may run the EQ.
+    therefore it is the callers responcibility to ensure the EQ will not
+    interrupt while this routine is executing.
+*/
+EQ_CALLBACK
+be_eq_set_callback(IN PBE_EQ_OBJECT eq_object,
+		   IN EQ_CALLBACK callback, IN PVOID context)
+{
+	EQ_CALLBACK old_callback;
+
+	EQ_ASSERT(eq_object);
+
+	old_callback = eq_object->callback;
+
+	eq_object->callback = callback;
+	eq_object->callback_context = context;
+
+	return old_callback;
+}
+
+/*!
+
+@brief
+    This routine handles EQ processing on EQs that were 'unrecognized' by upper
+    level drivers.  The only EQs that should be processed by this routine are
+	* iWARP EQ
+    The iWARP EQ will be delegated further for handling by the
+    iWARP device driver
+
+@param
+    FunctionObject      - Handle to a function object
+@param
+    EqId                - The Eq that has just completed processing
+
+@return
+
+@note
+    IRQL: DISPATCH_LEVEL only
+
+    This routine should be called immediately when a EQ from a ULD is not
+    recognized.
+*/
+void
+be_eq_delegate_processing(IN PBE_FUNCTION_OBJECT function_object,
+			  IN u32 eq_id)
+{
+	PBE_EQ_OBJECT eq_object;
+
+	FUNCTION_ASSERT(function_object);
+
+	eq_object = _be_eq_id_to_object(function_object, eq_id);
+
+	if (eq_object) {
+
+		eq_object->callback(function_object, eq_object,
+				    eq_object->callback_context);
+
+	} else {
+
+		TRACE(DL_WARN, "eq_id %d not found for delegation", eq_id);
+	}
+
+}
+
+/*!
+
+@brief
+    This routine adds a CQ as a dependent object on the given EQ. This will
+    cause the reference count to be incrmented and the CQ to be placed on
+    the EQ's list of active CQ objects.
+
+@param
+    eq_object            - EQ handle returned from eq_object_create.
+@param
+    cq_object            - CQ handle that is dependent on this EQ
+
+@return
+    EQ ID
+@note
+    IRQL: < DISPATCH_LEVEL
+
+*/
+void _be_eq_add_cq(IN PBE_EQ_OBJECT eq_object, IN PBE_CQ_OBJECT cq_object)
+{
+	EQ_ASSERT(eq_object);
+
+	CQ_ASSERT(cq_object);
+
+	_be_eq_lock(eq_object);
+
+	be_eq_reference(eq_object);
+
+	sa_insert_tail_list(&eq_object->cq_list_head,
+			    &cq_object->cqlist_for_eq);
+
+	_be_eq_unlock(eq_object);
+}
+
+/*!
+
+@brief
+    References the given object. The object is guaranteed to remain active until
+    the reference count drops to zero.
+
+@param
+    eq_object            - CQ handle returned from cq_object_create.
+
+@return
+    returns the current reference count on the object
+
+@note
+    IRQL: any
+
+*/
+u32 be_eq_reference(PBE_EQ_OBJECT eq_object)
+{
+	EQ_ASSERT(eq_object);
+	return sa_atomic_increment(&eq_object->ref_count);
+}
+
+/*!
+
+@brief
+    Dereferences the given object. The object is guaranteed to remain
+    active until the reference count drops to zero.
+
+@param
+    eq_object            - CQ handle returned from cq_object_create.
+
+@return
+    returns the current reference count on the object
+
+@note
+    IRQL: any
+
+*/
+u32 be_eq_dereference(PBE_EQ_OBJECT eq_object)
+{
+	EQ_ASSERT(eq_object);
+	return sa_atomic_decrement(&eq_object->ref_count);
+}
+
+/*!
+@brief
+    This routine removes a CQ as a dependent object on the given EQ. This will
+    cause the reference count to be decrmented and the CQ to be removed from
+    the EQ's list of active CQ objects.
+@param
+    eq_object            - EQ handle returned from eq_object_create.
+@param
+    cq_object            - CQ handle that was dependent on this EQ
+@return
+    EQ ID
+@note
+    IRQL: < DISPATCH_LEVEL
+*/
+void
+_be_eq_remove_cq(IN PBE_EQ_OBJECT eq_object, IN PBE_CQ_OBJECT cq_object)
+{
+	EQ_ASSERT(eq_object);
+	CQ_ASSERT(cq_object);
+
+	be_eq_dereference(eq_object);
+
+	_be_eq_lock(eq_object);
+	sa_remove_entry_list(&cq_object->cqlist_for_eq);
+	_be_eq_unlock(eq_object);
+}
+
+/*!
+@brief
+    Deferences the given object. Once the object's reference count drops to
+    zero, the object is destroyed and all resources that are held by this
+    object are released.  The on-chip context is also destroyed along with
+    the queue ID, and any mappings made into the UT.
+@param
+    eq_object            - EQ handle returned from eq_object_create.
+@return
+    BE_SUCCESS if successfull, , otherwise a useful error code is returned.
+@note
+    IRQL: IRQL < DISPATCH_LEVEL
+*/
+BESTATUS be_eq_destroy(PBE_EQ_OBJECT eq_object)
+{
+	BESTATUS status = 0;
+
+	EQ_ASSERT(eq_object);
+
+	ASSERT(eq_object->ref_count == 0);
+	/* no CQs should reference this EQ now */
+	ASSERT(sa_is_list_empty(&eq_object->cq_list_head));
+
+	/* Send ioctl to destroy the EQ. */
+	status =
+	    be_function_ring_destroy(eq_object->parent_function,
+				     eq_object->eq_id, IOCTL_RING_TYPE_EQ);
+	ASSERT(status == 0);
+
+	/* remove from the function */
+	_be_function_remove_eq(eq_object->parent_function, eq_object);
+
+	/* zero tracking object */
+	sa_zero_mem(eq_object, sizeof(BE_EQ_OBJECT));
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
+ * eq_array           - Array of BE_EQ_OBJECT pointers to adjust.
+ * eq_delay_array     - Array of "num_eq" timer delays in units
+ * 			of microseconds. The be_eq_query_delay_range
+ * 			ioctl returns the resolution and range of
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
+ *                      a generic BE_GENERIC_QUEUE_CONTEXT. However,
+ *                      the specific context structs
+ *                      are generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *-------------------------------------------------------------------------
+ */
+BESTATUS
+be_eq_modify_delay(IN PBE_FUNCTION_OBJECT function_object,
+		   IN u32 num_eq,
+		   IN BE_EQ_OBJECT **eq_array,
+		   IN u32 *eq_delay_array,
+		   IN MCC_WRB_CQE_CALLBACK callback,
+		   IN PVOID callback_context,
+		   IN PBE_EQ_MODIFY_DELAY_QUEUE_CONTEXT queue_context)
+{
+	IOCTL_COMMON_MODIFY_EQ_DELAY *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+	PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+	u32 i;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (MCC_WRB *) &queue_context->wrb_header;
+			generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+				queue_context;
+			generic_context->context.bytes =
+			    sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_MODIFY_EQ_DELAY);
+
+	ASSERT(num_eq > 0);
+	ASSERT(num_eq <= SA_NUMBER_OF(ioctl->params.request.delay));
+	ioctl->params.request.num_eq = num_eq;
+	for (i = 0; i < num_eq; i++) {
+		ioctl->params.request.delay[i].eq_id =
+		    be_eq_get_id(eq_array[i]);
+		ioctl->params.request.delay[i].delay_in_microseconds =
+		    eq_delay_array[i];
+	}
+
+	/* Post the Ioctl */
+	status =
+	    be_function_post_mcc_wrb_with_queue_context(function_object,
+							wrb,
+							generic_context,
+							callback,
+							callback_context,
+							ioctl);
+
+Error:
+	be_unlock_wrb_post(function_object);
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
+ *   This is a synchronous IOCTL.
+ * function_object     - Previously created function object
+ * eq_delay_resolution - Resolution of EQ delay in microseconds.
+ * eq_delay_max        - Max value of EQ delay in microseconds.
+ * return status       - BE_SUCCESS (0) on success. Negative
+ * 			error code on failure.
+ *--------------------------------------------------------------------------
+ */
+BESTATUS
+be_eq_query_delay_range(IN PBE_FUNCTION_OBJECT function_object,
+			OUT u32 *eq_delay_resolution,
+			OUT u32 *eq_delay_max)
+{
+	IOCTL_COMMON_MODIFY_EQ_DELAY *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+
+	FUNCTION_ASSERT(function_object);
+
+	ASSERT(eq_delay_resolution);
+	ASSERT(eq_delay_max);
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_MODIFY_EQ_DELAY);
+
+	/* init the context */
+	ioctl->params.request.num_eq = 0;
+
+	status =
+	    be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "Query EQ delay range failed.");
+		goto Error;
+	}
+
+	*eq_delay_resolution =
+	    ioctl->params.response.delay_resolution_in_microseconds;
+	*eq_delay_max = ioctl->params.response.delay_max_in_microseconds;
+
+	TRACE(DL_INFO, "eq delay. function:%d pd:%d resolution:%d max:%d",
+	      be_function_get_function_number(function_object),
+	      be_function_get_pd_number(function_object),
+	      *eq_delay_resolution, *eq_delay_max);
+
+Error:
+	be_unlock_wrb_post(function_object);
+	return status;
+
+}
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/cq_ll.c benet/linux-2.6.24.2/drivers/message/beclib/cq_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/cq_ll.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/cq_ll.c	2008-02-14 15:23:07.810205432 +0530
@@ -0,0 +1,443 @@
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
+    function_object  - function object the CQ should be bound to.
+@param
+    cq_id            - cq_id to find
+@return
+    A pointer to the CQ_OBJECT that represents this CqId. NULL if not found
+@note
+    IRQL: <= DISPATCH_LEVEL
+*/
+STATIC
+    INLINE
+    PBE_CQ_OBJECT
+be_cq_id_to_object(PBE_FUNCTION_OBJECT function_object, u32 cq_id)
+{
+	PBE_CQ_OBJECT cq_cur;
+	PBE_CQ_OBJECT cq_ret = NULL;
+
+	_be_function_lock(function_object);
+
+	SA_FOR_EACH_LIST_ENTRY(cq_cur, function_object->links.cq_list_head,
+			       BE_CQ_OBJECT, cq_list) {
+		if (be_cq_get_id(cq_cur) == cq_id) {
+
+			cq_ret = cq_cur;
+			break;
+		}
+	}
+
+	_be_function_unlock(function_object);
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
+BESTATUS be_cq_create(PBE_FUNCTION_OBJECT function_object,
+	PSA_SGL sgl, u32 length, boolean solicited_eventable,
+	boolean no_delay, u32 wm_thresh,
+	PBE_EQ_OBJECT eq_object, OUT PBE_CQ_OBJECT cq_object)
+{
+	BESTATUS status = BE_SUCCESS;
+	u32 num_entries_encoding;
+	u32 num_entries = length / sizeof(ISCSI_CQ_ENTRY);
+	IOCTL_COMMON_CQ_CREATE *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+
+	ASSERT(sgl);
+	ASSERT(cq_object);
+	ASSERT(length % sizeof(ISCSI_CQ_ENTRY) == 0);
+
+	FUNCTION_ASSERT(function_object);
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
+	cq_object->parent_function = function_object;
+	cq_object->eq_object = eq_object;
+	cq_object->num_entries = num_entries;
+	/* save for MCC cq processing */
+	cq_object->va = sa_sgl_get_base_va(sgl);
+
+	/* map into UT. */
+	length = num_entries * sizeof(ISCSI_CQ_ENTRY);
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_CQ_CREATE);
+
+	ioctl->params.request.num_pages =
+	    SA_PAGES_SPANNED(sa_sgl_get_offset(sgl), length);
+
+	/* context */
+	ioctl->params.request.context.valid = TRUE;
+	ioctl->params.request.context.Func =
+	    be_function_get_function_number(function_object);
+	ioctl->params.request.context.Eventable = (eq_object != NULL);
+	ioctl->params.request.context.Armed = TRUE;
+	ioctl->params.request.context.EQID =
+	    eq_object ? eq_object->eq_id : 0;
+	ioctl->params.request.context.Count = num_entries_encoding;
+	ioctl->params.request.context.PD =
+	    be_function_get_pd_number(function_object);
+	ioctl->params.request.context.NoDelay = no_delay;
+	ioctl->params.request.context.SolEvent = solicited_eventable;
+	ioctl->params.request.context.WME = (wm_thresh != 0xFFFFFFFF);
+	ioctl->params.request.context.Watermark =
+	    (ioctl->params.request.context.WME ? wm_thresh : 0);
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl,
+			  ioctl->params.request.pages,
+			  SA_NUMBER_OF(ioctl->params.request.pages));
+
+	/* Post the Ioctl */
+	status =
+	    be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create CQ failed.");
+		goto Error;
+	}
+	/* Remember the CQ id. */
+	cq_object->cq_id = ioctl->params.response.cq_id;
+
+	/* insert this cq into eq_object reference */
+	if (eq_object) {
+		_be_eq_add_cq(eq_object, cq_object);
+	}
+	/* insert this cq into function_object */
+	_be_function_add_cq(function_object, cq_object);
+
+	TRACE(DL_INFO,
+	      "cq created. function:%d pd:%d cqid:%d bytes:%d eqid:%d"
+	      " se:%d nd:%d wm:%d",
+	      be_function_get_function_number(function_object),
+	      be_function_get_pd_number(function_object), cq_object->cq_id,
+	      num_entries * sizeof(ISCSI_CQ_ENTRY),
+	      eq_object ? be_eq_get_id(eq_object) : -1,
+	      (u32) solicited_eventable, (u32) no_delay, wm_thresh);
+
+Error:
+	be_unlock_wrb_post(function_object);
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
+u32 be_cq_get_id(PBE_CQ_OBJECT cq_object)
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
+be_cq_object_set_callback(PBE_CQ_OBJECT cq_object,
+			  CQ_CALLBACK callback, PVOID context)
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
+    function_object      - handle to a function object
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
+be_cq_object_delegate_processing(PBE_FUNCTION_OBJECT function_object,
+				 u32 cq_id)
+{
+	PBE_CQ_OBJECT cq_object;
+
+	FUNCTION_ASSERT(function_object);
+
+	cq_object = be_cq_id_to_object(function_object, cq_id);
+
+	if (cq_object) {
+
+		ASSERT(cq_object->callback);
+		cq_object->callback(function_object, cq_object,
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
+u32 be_cq_object_reference(PBE_CQ_OBJECT cq_object)
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
+u32 be_cq_object_dereference(PBE_CQ_OBJECT cq_object)
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
+BESTATUS be_cq_destroy(PBE_CQ_OBJECT cq_object)
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
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/mpu_ll.c benet/linux-2.6.24.2/drivers/message/beclib/mpu_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/mpu_ll.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/mpu_ll.c	2008-02-14 15:32:53.337191800 +0530
@@ -0,0 +1,1559 @@
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
+ *============================================================================
+ *                            F I L E   S C O P E
+ *============================================================================
+ */
+
+void
+_be_mcc_free_wrb_buffers(PBE_MCC_OBJECT mcc,
+			 PBE_MCC_WRB_CONTEXT wrb_context);
+
+/*!
+
+@brief
+    This routine converts from a BladeEngine Mcc wrb completion status to
+    a standard NT status;
+
+@param
+    MccStatus   - BE Mcc WRB completion status to convert
+
+@return
+    An NT status
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+STATIC BESTATUS be_mcc_wrb_status_to_bestatus(IN u32 mcc_status)
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
+/*!
+@brief
+    This routine waits for a previously posted mailbox WRB to be completed.
+    Specifically it waits for the mailbox to say that it's ready to accept
+    more data by setting the LSB of the mailbox pd register to 1.
+
+@param
+    pcontroller      - The function object to post this data to
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+*/
+STATIC void be_mcc_mailbox_wait(IN PBE_FUNCTION_OBJECT function_object)
+{
+	MPU_MAILBOX_DB mailbox_db;
+	u32 i = 0;
+	u32 tl;
+
+	FUNCTION_ASSERT(function_object);
+
+	if (function_object->emulate) {
+		/* No waiting for mailbox in emulated mode. */
+		return;
+	}
+
+	mailbox_db.dw = PD_READ(function_object, mcc_bootstrap_db);
+
+	tl = sa_trace_set_level(sa_trace_get_level() & ~DL_HW);
+	while (mailbox_db.ready == FALSE) {
+		if ((++i & 0x3FFFF) == 0) {
+			TRACE(DL_WARN,
+			      "Waiting for mailbox ready for %dk polls.",
+			      i / 1000);
+		}
+
+		sa_dev_stall(function_object->sa_dev, 1);
+
+		mailbox_db.dw = PD_READ(function_object, mcc_bootstrap_db);
+	}
+	sa_trace_set_level(tl);
+
+}
+
+/*!
+
+@brief
+    This routine tells the MCC mailbox that there is data to processed
+    in the mailbox. It does this by setting the physical address for the
+    mailbox location and clearing the LSB.  This routine returns immediately
+    and does not wait for the WRB to be processed.
+
+
+@param
+    pcontroller      - The function object to post this data to
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+STATIC void be_mcc_mailbox_notify(IN PBE_FUNCTION_OBJECT function_object)
+{
+	MPU_MAILBOX_DB mailbox_db;
+
+	FUNCTION_ASSERT(function_object);
+	ASSERT(function_object->mailbox.pa);
+	ASSERT(function_object->mailbox.va);
+
+	/* If emulated, do not ring the mailbox */
+	if (function_object->emulate) {
+		TRACE(DL_WARN, "MPU disabled. Skipping mailbox notify.");
+		return;
+	}
+
+	function_object->stats.mailbox_wrbs++;
+
+	/* form the higher bits in the address */
+	mailbox_db.dw = 0;	/* init */
+	mailbox_db.hi = 1;
+	mailbox_db.ready = 0;
+	SA_C_ASSERT(BE_BIT_SIZE(MPU_MAILBOX_DB, address) == 30);
+	mailbox_db.address =
+	    (u32) sa_upper_bits64(function_object->mailbox.pa, 30);
+
+	/* Wait for the MPU to be ready */
+	be_mcc_mailbox_wait(function_object);
+
+	/* Ring doorbell 1st time */
+	PD_WRITE(function_object, mcc_bootstrap_db, mailbox_db);
+
+	/* Wait for 1st write to be acknowledged. */
+	be_mcc_mailbox_wait(function_object);
+
+	/* form the lower bits in the address */
+	mailbox_db.hi = 0;
+	mailbox_db.ready = 0;
+	mailbox_db.address =
+	    (u32) sa_bit_range64(function_object->mailbox.pa, 4, 30);
+
+	/* Ring doorbell 2nd time */
+	PD_WRITE(function_object, mcc_bootstrap_db, mailbox_db);
+}
+
+/*!
+@brief
+    This routine tells the MCC mailbox that there is data to processed
+    in the mailbox. It does this by setting the physical address for the
+    mailbox location and clearing the LSB.  This routine spins until the
+    MPU writes a 1 into the LSB indicating that the data has been received
+    and is ready to be processed.
+
+@param
+    pcontroller      - The function object to post this data to
+@return
+@note
+    IRQL < DISPATCH_LEVEL
+*/
+STATIC
+    void
+be_mcc_mailbox_notify_and_wait(IN PBE_FUNCTION_OBJECT function_object)
+{
+	/*
+	 * Notify it
+	 */
+	be_mcc_mailbox_notify(function_object);
+
+	/*
+	 * Now wait for completion of WRB
+	 */
+	be_mcc_mailbox_wait(function_object);
+}
+
+void
+be_mcc_process_cqe(PBE_FUNCTION_OBJECT function_object, PMCC_CQ_ENTRY cqe)
+{
+
+	PBE_MCC_WRB_CONTEXT wrb_context = NULL;
+
+	FUNCTION_ASSERT(function_object);
+	ASSERT(cqe);
+
+	/*
+	 * A command completed.  Commands complete out-of-order.
+	 * Determine which command completed from the TAG.
+	 */
+	SA_C_ASSERT(sizeof(cqe->mcc_tag) >= sizeof(u64));
+	wrb_context =
+	    (PBE_MCC_WRB_CONTEXT) SA_U64_TO_PTR(*((u64 *) cqe->mcc_tag));
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
+		ASSERT(C_GT
+		       (function_object->stats.consumed_wrbs,
+			wrb_context->consumed_count));
+	}
+#endif
+
+	/*
+	 * Perform a response copy if requested.
+	 * Only copy data if the IOCTL is successful.
+	 */
+	if (cqe->completion_status == MGMT_STATUS_SUCCESS &&
+	    wrb_context->copy.length > 0) {
+		ASSERT(wrb_context->wrb);
+		ASSERT(wrb_context->wrb->embedded);
+		ASSERT(wrb_context->copy.va);
+		ASSERT(wrb_context->copy.ioctl_offset +
+		       wrb_context->copy.length <= SA_SIZEOF_FIELD(MCC_WRB,
+								   payload));
+		sa_memcpy(wrb_context->copy.va,
+			  (u8 *) &wrb_context->wrb->payload +
+			  wrb_context->copy.ioctl_offset,
+			  wrb_context->copy.length);
+	}
+
+	/* internal callback */
+	if (wrb_context->internal_callback) {
+		wrb_context->internal_callback(wrb_context->
+					       internal_callback_context,
+					       be_mcc_wrb_status_to_bestatus
+					       (cqe->completion_status),
+					       wrb_context->wrb);
+	}
+
+	/* callback */
+	if (wrb_context->callback) {
+		wrb_context->callback(wrb_context->callback_context,
+		      be_mcc_wrb_status_to_bestatus(cqe->completion_status),
+				      wrb_context->wrb);
+	}
+	/* Free the context structure */
+	_be_mcc_free_wrb_context(function_object, wrb_context);
+}
+
+void be_drive_mcc_wrb_queue(IN PBE_MCC_OBJECT mcc)
+{
+	PBE_FUNCTION_OBJECT function_object = NULL;
+	BESTATUS status = BE_PENDING;
+	PBE_GENERIC_QUEUE_CONTEXT queue_context;
+	PSA_LIST_ENTRY entry;
+	MCC_WRB *wrb;
+	MCC_WRB *queue_wrb;
+	u32 length;
+
+	MCC_ASSERT(mcc);
+
+	function_object = mcc->parent_function;
+
+	be_lock_wrb_post(function_object);
+
+	if (mcc->driving_backlog) {
+		be_unlock_wrb_post(function_object);
+		return;
+	}
+	/* Acquire the flag to limit 1 thread to redrive posts. */
+	mcc->driving_backlog = 1;
+
+	while (!sa_is_list_empty(&mcc->backlog)) {
+
+		wrb = _be_mpu_peek_ring_wrb(mcc, TRUE);	/* Driving the queue */
+		if (!wrb) {
+			break;	/* No space in the ring yet. */
+		}
+		/* Get the next queued entry to process. */
+		entry = sa_remove_head_list(&mcc->backlog);
+		ASSERT(entry);
+		queue_context =
+		    SA_CONTAINING_RECORD(entry, BE_GENERIC_QUEUE_CONTEXT,
+					 context.list);
+		function_object->links.mcc->backlog_length--;
+
+		/*
+		 * Compute the required length of the WRB.
+		 * Since the queue element may be smaller than
+		 * the complete WRB, copy only the required number of bytes.
+		 */
+		queue_wrb = (MCC_WRB *) &queue_context->wrb_header;
+		if (queue_wrb->embedded) {
+			length =
+			    sizeof(BE_MCC_WRB_HEADER) +
+			    queue_wrb->payload_length;
+		} else {
+			ASSERT(queue_wrb->sge_count == 1); /* only 1 frag. */
+			length = sizeof(BE_MCC_WRB_HEADER) +
+			    queue_wrb->sge_count * sizeof(MCC_SGE);
+		}
+
+		/*
+		 * Truncate the length based on the size of the
+		 * queue element.  Some elements that have output parameters
+		 * can be smaller than the payload_length field would
+		 * indicate.  We really only need to copy the request
+		 * parameters, not the response.
+		 */
+		ASSERT(queue_context->context.bytes >=
+		       SA_FIELD_OFFSET(BE_GENERIC_QUEUE_CONTEXT,
+				       wrb_header));
+		length =
+		    MIN(length,
+			queue_context->context.bytes -
+			SA_FIELD_OFFSET(BE_GENERIC_QUEUE_CONTEXT,
+					wrb_header));
+
+		/* Copy the queue element WRB into the ring. */
+		sa_memcpy(wrb, &queue_context->wrb_header, length);
+
+		/* Post the wrb.  This should not fail assuming we have
+		 * enough context structs. */
+		status = be_function_post_mcc_wrb_complete(function_object,
+				wrb, NULL,	/* Do not queue */
+			   queue_context->context.
+			   callback,
+			   queue_context->context.
+			   callback_context,
+			   queue_context->context.
+			   internal_callback,
+			   queue_context->context.
+			   internal_callback_context,
+			   queue_context->context.
+			   optional_ioctl_va,
+			   queue_context->context.copy);
+
+		if (status == BE_SUCCESS) {
+
+			/*
+			 * Synchronous completion. Since it was queued,
+			 * we will invoke the callback.
+			 * To the user, this is an asynchronous request.
+			 */
+			be_unlock_wrb_post(function_object);
+
+			ASSERT(queue_context->context.callback);
+
+			queue_context->context.callback(queue_context->context.
+						callback_context,
+						BE_SUCCESS, NULL);
+
+			be_lock_wrb_post(function_object);
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
+			sa_insert_head_list(&mcc->backlog,
+					    &queue_context->context.list);
+			function_object->links.mcc->backlog_length++;
+			break;
+		}
+	}
+
+	function_object->stats.queue_length =
+	    function_object->links.mcc->backlog_length;
+
+	/* Free the flag to limit 1 thread to redrive posts. */
+	mcc->driving_backlog = 0;
+
+	be_unlock_wrb_post(function_object);
+}
+
+/* This function asserts that the WRB was consumed in order. */
+#ifdef SA_DEBUG
+u32 be_mcc_wrb_consumed_in_order(PBE_MCC_OBJECT mcc, PMCC_CQ_ENTRY cqe)
+{
+	PBE_FUNCTION_OBJECT function_object = mcc->parent_function;
+	PBE_MCC_WRB_CONTEXT wrb_context = NULL;
+	u32 wrb_index;
+	u32 wrb_consumed_in_order;
+
+	FUNCTION_ASSERT(function_object);
+	ASSERT(cqe);
+
+	/*
+	 * A command completed.  Commands complete out-of-order.
+	 * Determine which command completed from the TAG.
+	 */
+	SA_C_ASSERT(sizeof(cqe->mcc_tag) >= sizeof(u64));
+	wrb_context =
+	    (PBE_MCC_WRB_CONTEXT) SA_U64_TO_PTR(*((u64 *) cqe->mcc_tag));
+
+	ASSERT(wrb_context);
+
+	wrb_index =
+	    (u32) (((SA_PTR_TO_U64(wrb_context->ring_wrb) -
+		     SA_PTR_TO_U64(mcc->sq.ring.va))) / sizeof(MCC_WRB));
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
+BESTATUS be_mcc_process_cq(IN PBE_MCC_OBJECT mcc, IN boolean rearm)
+{
+	PBE_FUNCTION_OBJECT function_object = NULL;
+	PMCC_CQ_ENTRY cqe;
+	CQ_DB db;
+	PSA_RING cq_ring = &mcc->cq.ring;
+	PSA_RING mcc_ring = &mcc->sq.ring;
+	u32 num_processed = 0;
+	u32 consumed = 0;
+
+	function_object = mcc->parent_function;
+	FUNCTION_ASSERT(function_object);
+
+	be_lock_cq_process(function_object);
+
+	function_object->stats.processed_cq++;
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
+	be_unlock_cq_process(function_object);
+
+	cqe = sa_ring_current(cq_ring);
+	while (cqe->valid) {
+
+		function_object->stats.cq_entries++;
+
+		if (num_processed >= 8) {
+			/* coalesce doorbells, but free space in cq
+			 * ring while processing. */
+			db.dw = 0;	/* clear */
+			db.qid = cq_ring->id;
+			db.rearm = FALSE;	/* Rearm at the end! */
+			db.event = FALSE;
+			db.num_popped = num_processed;
+			num_processed = 0;
+
+			PD_WRITE(function_object, cq_db, db);
+		}
+
+		if (cqe->async_event) {
+			/* This is an asynchronous event. */
+			ASYNC_EVENT_TRAILER *async_trailer =
+			    (ASYNC_EVENT_TRAILER *)
+			    ((u8 *) cqe + sizeof(MCC_CQ_ENTRY) -
+			     sizeof(ASYNC_EVENT_TRAILER));
+
+			/* The async_event bit must be in the same
+			 * location in both structs. */
+			SA_C_ASSERT(BE_WORD_OFFSET
+				    (MCC_CQ_ENTRY,
+				     async_event) * 32 +
+				    BE_BIT_OFFSET(MCC_CQ_ENTRY,
+						  async_event) ==
+				    BE_BIT_OFFSET(ASYNC_EVENT_TRAILER,
+						  async_event) +
+				    8 * (sizeof(MCC_CQ_ENTRY) -
+					 sizeof(ASYNC_EVENT_TRAILER)));
+
+			ASSERT(async_trailer->async_event == 1);
+			ASSERT(async_trailer->valid == 1);
+
+			function_object->stats.async_events++;
+
+			/* Call the async event handler if it is installed. */
+			if (mcc->async_callback) {
+				TRACE(DL_INFO,
+				      "Async event. Type:0x%x Code:0x%x",
+				      async_trailer->event_type,
+				      async_trailer->event_code);
+				mcc->async_callback(mcc->async_context,
+						    (u32) async_trailer->
+						    event_code,
+						    (PVOID) cqe);
+			} else {
+				TRACE(DL_WARN,
+				      "No async callback for event."
+				      " Type:0x%x Code:0x%x",
+				      async_trailer->event_type,
+				      async_trailer->event_code);
+				function_object->stats.
+				    ignored_async_events++;
+			}
+
+		} else {
+			/* This is a completion entry. */
+
+			/* No vm forwarding in this driver. */
+			ASSERT(cqe->hpi_buffer_completion == 0);
+
+			if (cqe->consumed) {
+				/*
+				 * A command on the MCC ring was consumed.
+				 * Update the consumer index.
+				 * These occur in order.
+				 */
+				ASSERT(be_mcc_wrb_consumed_in_order
+				       (mcc, cqe));
+				consumed++;
+				function_object->stats.consumed_wrbs++;
+			}
+
+			if (cqe->completed) {
+				/* A command completed.  Use tag to
+				 * determine which command.  */
+				be_mcc_process_cqe(function_object, cqe);
+				function_object->stats.completed_wrbs++;
+			}
+		}
+
+		/* Reset the CQE */
+		cqe->valid = FALSE;
+		num_processed++;
+
+		TRACE(DL_IOCTL, " update the cidx now cidx=%x",
+		      cq_ring->cidx);
+		/* Update our tracking for the CQ ring. */
+		cqe = sa_ring_next(cq_ring);
+	}
+
+	TRACE(DL_INFO, "num_processed:0x%x, and consumed:0x%x",
+	      num_processed, consumed);
+	/*
+	 * Grab the CQ lock to synchronize the "rearm" setting for
+	 * the doorbell, and for clearing the "processing" flag.
+	 */
+	be_lock_cq_process(function_object);
+
+	/*
+	 * Rearm the cq.  This is done based on the global mcc->rearm
+	 * flag which combines the rearm parameter from the current
+	 * call to process_cq and any other threads
+	 * that tried to process the CQ while this one was active.
+	 * This handles the situation where a sync. ioctl was processing
+	 * the CQ while the interrupt/dpc tries to process it.
+	 * The sync process gets to continue -- but it is now
+	 * responsible for the rearming.
+	 */
+	if (num_processed > 0 || mcc->rearm == TRUE) {
+		db.dw = 0;	/* clear */
+		db.qid = cq_ring->id;
+		db.rearm = mcc->rearm;
+		db.event = FALSE;
+		db.num_popped = num_processed;
+
+		PD_WRITE(function_object, cq_db, db);
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
+
+	be_unlock_cq_process(function_object);
+
+	/*
+	 * Use the local variable to detect if the current thread
+	 * holds the WRB post lock.  If rearm is FALSE, this is
+	 * either a synchronous command, or the upper layer driver is polling
+	 * from a thread.  We do not drive the queue from that
+	 * context since the driver may hold the
+	 * wrb post lock already.
+	 */
+	if (rearm) {
+		be_drive_mcc_wrb_queue(mcc);
+	} else {
+		function_object->pend_queue_driving = 1;
+	}
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
+/*!
+
+@brief
+    This routine creates an MCC object.  This object contains an MCC send queue
+    and a CQ private to the MCC.
+
+@param
+    pcontroller      - Handle to a function object
+
+@param
+    EqObject            - EQ object that will be used to dispatch this MCC
+
+@param
+    ppMccObject         - Pointer to an internal Mcc Object returned.
+
+@return
+    BE_SUCCESS if successfull,, otherwise a useful error code is returned.
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+BESTATUS
+be_mcc_ring_create(IN PBE_FUNCTION_OBJECT function_object,
+		   IN PSA_SGL sgl,
+		   IN u32 length,
+		   IN PBE_MCC_WRB_CONTEXT context_array,
+		   IN u32 num_context_entries,
+		   IN PBE_CQ_OBJECT cq, IN PBE_MCC_OBJECT mcc)
+{
+	BESTATUS status = 0;
+
+	IOCTL_COMMON_MCC_CREATE *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	u32 num_entries_encoded;
+	PVOID va = NULL;
+	u32 i;
+
+	if (length < sizeof(MCC_WRB) * 2) {
+		TRACE(DL_ERR, "Invalid MCC ring length:%d", length);
+		return BE_NOT_OK;
+	}
+	/*
+	 * Reduce the actual ring size to be less than the number
+	 * of context entries.  This ensures that we run out of
+	 * ring WRBs first so the queuing works correctly.  We never
+	 * queue based on context structs.
+	 */
+	if (num_context_entries + 1 < length / sizeof(MCC_WRB) - 1) {
+
+		u32 max_length =
+		    (num_context_entries + 2) * sizeof(MCC_WRB);
+
+		length = sa_gt_power2(max_length) / 2;
+		ASSERT(length <= max_length);
+
+		TRACE(DL_WARN,
+		      "MCC ring length reduced based on context entries."
+		      " length:%d wrbs:%d context_entries:%d",
+		      length,
+		      length / sizeof(MCC_WRB), num_context_entries);
+	}
+
+	be_lock_wrb_post(function_object);
+
+	num_entries_encoded =
+	    be_ring_length_to_encoding(length, sizeof(MCC_WRB));
+
+	/* Init MCC object. */
+	SA_ZERO_MEM(mcc);
+	mcc->magic = BE_MCC_MAGIC;
+	mcc->parent_function = function_object;
+	mcc->cq_object = cq;
+
+	sa_initialize_list_head(&mcc->backlog);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in create EQ.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_MCC_CREATE);
+
+	ioctl->params.request.num_pages = sa_ceiling(length, SA_PAGE_SIZE);
+	ASSERT(ioctl->params.request.num_pages <=
+	       sa_sgl_get_page_count(sgl));
+
+	/*
+	 * Program MCC ring context
+	 */
+	ioctl->params.request.context.pdid =
+	    be_function_get_pd_number(function_object);
+	ioctl->params.request.context.invalid = FALSE;
+	ioctl->params.request.context.ring_size = num_entries_encoded;
+	ioctl->params.request.context.cq_id = be_cq_get_id(cq);
+
+	/* Create a page list for the IOCTL. */
+	be_sgl_to_pa_list(sgl, ioctl->params.request.pages,
+			  SA_NUMBER_OF(ioctl->params.request.pages));
+
+	/* Post the Ioctl */
+	status =
+	    be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to create CQ failed.");
+		goto error;
+	}
+	/*
+	 * Create a linked list of context structures
+	 */
+	mcc->wrb_context.base = context_array;
+	mcc->wrb_context.num = num_context_entries;
+	sa_initialize_list_head(&mcc->wrb_context.list_head);
+	sa_zero_mem(context_array,
+		    sizeof(BE_MCC_WRB_CONTEXT) * num_context_entries);
+	for (i = 0; i < mcc->wrb_context.num; i++) {
+		sa_insert_tail_list(&mcc->wrb_context.list_head,
+				    &context_array[i].next);
+	}
+
+	/*
+	 *
+	 * Create an SA_RING for tracking WRB hw ring
+	 */
+	va = sa_sgl_get_base_va(sgl);
+	ASSERT(va);
+	sa_ring_create(&mcc->sq.ring,
+		       length / sizeof(MCC_WRB), sizeof(MCC_WRB), va);
+	mcc->sq.ring.id = ioctl->params.response.id; /* save the butler id! */
+
+	/*
+	 * Init a SA_RING for tracking the MCC CQ.
+	 */
+	ASSERT(cq->va);
+	sa_ring_create(&mcc->cq.ring, cq->num_entries,
+		       sizeof(ISCSI_CQ_ENTRY), cq->va);
+	mcc->cq.ring.id = be_cq_get_id(cq);
+
+	/* Force zeroing of CQ. */
+	sa_zero_mem(cq->va, cq->num_entries * sizeof(ISCSI_CQ_ENTRY));
+
+	/* Initialize debug index. */
+	mcc->consumed_index = 0;
+
+	be_cq_object_reference(cq);
+	_be_function_add_mcc(function_object, mcc);
+
+	TRACE(DL_INFO,
+	      "MCC ring created. id:%d bytes:%d cq_id:%d cq_entries:%d"
+	      " num_context:%d",
+	      ioctl->params.response.id,
+	      length,
+	      be_cq_get_id(cq), cq->num_entries, num_context_entries);
+
+error:
+	be_unlock_wrb_post(function_object);
+	return status;
+}
+
+u32 be_mcc_get_id(PBE_MCC_OBJECT mcc)
+{
+	MCC_ASSERT(mcc);
+	return mcc->sq.ring.id;
+}
+
+/*!
+
+@brief
+    This routine destroys an MCC send queue
+
+@param
+    MccObject         - Internal Mcc Object to be destroyed.
+
+@return
+    BE_SUCCESS if successfull,, otherwise a useful error code is returned.
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+    The caller of this routine must ensure that no other WRB may be posted
+    until this routine returns.
+
+*/
+BESTATUS be_mcc_ring_destroy(IN PBE_MCC_OBJECT mcc)
+{
+	BESTATUS status = 0;
+
+	MCC_ASSERT(mcc);
+
+	ASSERT(mcc->processing == 0);
+
+	/*
+	 * Remove the ring from the function object.
+	 * This transitions back to mailbox mode.
+	 */
+	_be_function_remove_mcc(mcc->parent_function, mcc);
+
+	/* Send ioctl to destroy the queue.  (Using the mailbox.) */
+	status =
+	    be_function_ring_destroy(mcc->parent_function, mcc->sq.ring.id,
+				     IOCTL_RING_TYPE_MCC);
+	ASSERT(status == 0);
+
+	/* Release the SQ reference to the CQ */
+	be_cq_object_dereference(mcc->cq_object);
+
+	return status;
+}
+
+STATIC void
+mcc_wrb_sync_callback(IN PVOID context,
+		      IN BESTATUS completion_status, IN PMCC_WRB wrb)
+{
+	PBE_MCC_WRB_CONTEXT wrb_context = (PBE_MCC_WRB_CONTEXT) context;
+
+	SA_NOT_USED(wrb);
+
+	ASSERT(wrb_context);
+
+	*wrb_context->users_final_status = completion_status;
+}
+
+/*!
+
+@brief
+    This routine posts a command to the MCC send queue
+
+@param
+    MccObject       - Internal Mcc Object to be destroyed.
+
+@param
+    wrb             - wrb to post.
+
+
+@param
+    CompletionCallback  - Address of a callback routine to invoke once the WRB
+			is completed.
+
+@param
+    CompletionCallbackContext - Opaque context to be passed during the call to
+				the CompletionCallback.
+
+@return
+    BE_SUCCESS if successfull,, otherwise a useful error code is returned.
+
+@note
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
+_be_mpu_post_wrb_ring(IN PBE_MCC_OBJECT mcc,
+		      IN PMCC_WRB wrb, IN PBE_MCC_WRB_CONTEXT wrb_context)
+{
+
+	PMCC_WRB ring_wrb = NULL;
+	BESTATUS status = BE_PENDING;
+	volatile BESTATUS final_status = BE_PENDING;
+	MCC_WRB_CQE_CALLBACK callback = NULL;
+	MCC_DB mcc_db;
+
+	MCC_ASSERT(mcc);
+	ASSERT(sa_ring_num_empty(&mcc->sq.ring) > 0);
+
+	/*
+	 * Input wrb is most likely the next wrb in the ring, since the client
+	 * can peek at the address.
+	 */
+	ring_wrb = sa_ring_producer_ptr(&mcc->sq.ring);
+	if (wrb != ring_wrb) {
+		/* If not equal, copy it into the ring. */
+		sa_memcpy(ring_wrb, wrb, sizeof(MCC_WRB));
+	}
+	/* Minimal verification of posted WRB. */
+	ASSERT(wrb->embedded || wrb->sge_count > 0);
+
+	SA_DBG_ONLY(wrb_context->ring_wrb = ring_wrb;)
+
+	    if (ring_wrb->embedded) {
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
+	sa_ring_produce(&mcc->sq.ring);
+
+	mcc_db.dw = 0;		/* initialize */
+	mcc_db.rid = mcc->sq.ring.id;
+	mcc_db.numPosted = 1;
+
+	mcc->parent_function->stats.posted_wrbs++;
+
+	PD_WRITE(mcc->parent_function, mpu_mcc_db, mcc_db); /* Ring doorbell */
+	TRACE(DL_INFO, "pidx: %x and cidx: %x.", mcc->sq.ring.pidx,
+	      mcc->sq.ring.cidx);
+
+	if (callback == NULL) {
+
+		i32 polls = 0;	/* At >= 1 us per poll   */
+
+		/* Wait until this command completes, polling the CQ. */
+		do {
+
+			TRACE(DL_INFO,
+			      "IOCTL submitted in the poll mode.");
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
+		} while (final_status == BE_PENDING);
+
+		status = final_status;
+	}
+
+	return status;
+}
+
+PMCC_WRB
+_be_mpu_peek_ring_wrb(IN PBE_MCC_OBJECT mcc, boolean driving_queue)
+{
+	MCC_ASSERT(mcc);
+
+	/* If we have queued items, do not allow a post to bypass the queue. */
+	if (!driving_queue && !sa_is_list_empty(&mcc->backlog)) {
+		return NULL;
+	}
+
+	if (sa_ring_num_empty(&mcc->sq.ring) <= 0) {
+		return NULL;
+	}
+
+	return (PMCC_WRB) sa_ring_producer_ptr(&mcc->sq.ring);
+}
+
+BESTATUS
+be_mpu_init_mailbox(IN PBE_FUNCTION_OBJECT function_object,
+		    IN PSA_SGL mailbox)
+{
+	FUNCTION_ASSERT(function_object);
+	ASSERT(mailbox);
+
+	function_object->mailbox.va = sa_sgl_get_base_va(mailbox);
+	function_object->mailbox.pa =
+	    sa_sgl_get_page(mailbox, 0) + sa_sgl_get_offset(mailbox);
+	function_object->mailbox.length =
+	    MIN(SA_PAGE_SIZE - sa_sgl_get_offset(mailbox),
+		sa_sgl_get_byte_count(mailbox));
+
+	ASSERT((SA_PTR_TO_U32(function_object->mailbox.va) & 0xf) == 0);
+	ASSERT((SA_PTR_TO_U32(function_object->mailbox.pa) & 0xf) == 0);
+	/*
+	 * Issue the WRB to set MPU endianness
+	 */
+	{
+		u8 *endian_check = (u8 *) &function_object->mailbox.va->wrb;
+		*endian_check++ = 0xFF;	/* byte 0 */
+		*endian_check++ = 0x12;	/* byte 1 */
+		*endian_check++ = 0x34;	/* byte 2 */
+		*endian_check++ = 0xFF;	/* byte 3 */
+		*endian_check++ = 0xFF;	/* byte 4 */
+		*endian_check++ = 0x56;	/* byte 5 */
+		*endian_check++ = 0x78;	/* byte 6 */
+		*endian_check++ = 0xFF;	/* byte 7 */
+	}
+
+	be_mcc_mailbox_notify_and_wait(function_object);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS be_mpu_uninit_mailbox(IN PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	ASSERT(function_object->mailbox.va);
+	ASSERT((SA_PTR_TO_U32(function_object->mailbox.va) & 0xf) == 0);
+	ASSERT((SA_PTR_TO_U32(function_object->mailbox.pa) & 0xf) == 0);
+	/*
+	 * Issue the WRB to indicate mailbox teardown
+	 */
+	{
+		u8 *mbox_unint = (u8 *) &function_object->mailbox.va->wrb;
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
+	be_mcc_mailbox_notify_and_wait(function_object);
+
+	return BE_SUCCESS;
+}
+
+void be_mpu_cleanup_mailbox(PBE_FUNCTION_OBJECT function_object)
+{
+
+	FUNCTION_ASSERT(function_object);
+	/*function_object->mailbox.sgl = NULL; */
+	function_object->mailbox.va = NULL;
+	function_object->mailbox.pa = 0ULL;
+	function_object->mailbox.length = 0UL;
+}
+
+/*!
+@brief
+    This routine posts a command to the MCC mailbox.
+@param
+    FuncObj         - Function Object to post the WRB on behalf of.
+@param
+    wrb             - wrb to post.
+@param
+    CompletionCallback  - Address of a callback routine to invoke once the WRB
+				is completed.
+@param
+    CompletionCallbackContext - Opaque context to be passed during the call to
+				the CompletionCallback.
+@return
+    BE_SUCCESS if successfull,, otherwise a useful error code is returned.
+@note
+    IRQL <=DISPATCH_LEVEL if CompletionCallback is  NULL
+
+    This routine will block until a completion for this MCC command has been
+     processed. If called at DISPATCH_LEVEL the CompletionCallback must be NULL.
+
+    This routine should only be called if the MPU has not been boostraped past
+    mailbox mode.
+*/
+BESTATUS
+_be_mpu_post_wrb_mailbox(IN PBE_FUNCTION_OBJECT function_object,
+			 IN PMCC_WRB wrb,
+			 IN PBE_MCC_WRB_CONTEXT wrb_context)
+{
+	PMCC_MAILBOX mailbox = NULL;
+
+	FUNCTION_ASSERT(function_object);
+	ASSERT(function_object->links.mcc == NULL);
+
+	mailbox = function_object->mailbox.va;
+	ASSERT(mailbox);
+
+	if ((PMCC_WRB) &mailbox->wrb != wrb) {
+		SA_ZERO_MEM(mailbox);
+		sa_memcpy(&mailbox->wrb, wrb, sizeof(MCC_WRB));
+	}
+	/* The callback can inspect the final WRB to get output parameters. */
+	wrb_context->wrb = &mailbox->wrb;
+
+	be_mcc_mailbox_notify_and_wait(function_object);
+
+	/* A command completed.  Use tag to determine which command. */
+	be_mcc_process_cqe(function_object, &mailbox->cq);
+
+	return be_mcc_wrb_status_to_bestatus(mailbox->cq.
+					     completion_status);
+}
+
+PBE_MCC_WRB_CONTEXT
+_be_mcc_allocate_wrb_context(PBE_FUNCTION_OBJECT function_object)
+{
+	PBE_MCC_WRB_CONTEXT context = NULL;
+	SA_IRQ irq;
+
+	FUNCTION_ASSERT(function_object);
+
+	sa_acquire_spinlock(&function_object->mcc_context_lock, &irq);
+
+	if (!function_object->mailbox.default_context_allocated) {
+		/* Use the single default context that we
+		 * always have allocated. */
+		function_object->mailbox.default_context_allocated = TRUE;
+		context = &function_object->mailbox.default_context;
+	} else if (function_object->links.mcc) {
+		/* Get a context from the free list. If any are available. */
+		if (!sa_is_list_empty
+		    (&function_object->links.mcc->wrb_context.list_head)) {
+			PSA_LIST_ENTRY list_entry =
+			    sa_remove_head_list(&function_object->links.
+						mcc->wrb_context.
+						list_head);
+			context =
+			    SA_CONTAINING_RECORD(list_entry,
+						 BE_MCC_WRB_CONTEXT, next);
+		}
+	}
+
+	sa_release_spinlock(&function_object->mcc_context_lock, &irq);
+
+	return context;
+}
+
+void
+_be_mcc_free_wrb_context(PBE_FUNCTION_OBJECT function_object,
+			 PBE_MCC_WRB_CONTEXT context)
+{
+	SA_IRQ irq;
+
+	FUNCTION_ASSERT(function_object);
+	ASSERT(context);
+
+	/*
+	 * Zero during free to try and catch any bugs where the context
+	 * is accessed after a free.
+	 */
+	sa_zero_mem(context, sizeof(context));
+
+	sa_acquire_spinlock(&function_object->mcc_context_lock, &irq);
+
+	if (context == &function_object->mailbox.default_context) {
+		/* Free the default context. */
+		ASSERT(function_object->mailbox.default_context_allocated);
+		function_object->mailbox.default_context_allocated = FALSE;
+	} else {
+		/* Add to free list. */
+		ASSERT(function_object->links.mcc);
+		sa_insert_tail_list(&function_object->links.mcc->
+				    wrb_context.list_head, &context->next);
+	}
+
+	sa_release_spinlock(&function_object->mcc_context_lock, &irq);
+}
+
+BESTATUS
+be_mcc_add_async_event_callback(IN BE_MCC_OBJECT *mcc_object,
+				IN MCC_ASYNC_EVENT_CALLBACK callback,
+				IN PVOID callback_context)
+{
+	MCC_ASSERT(mcc_object);
+
+	/* Lock against anyone trying to change the callback/context pointers
+	 * while being used. */
+	be_lock_cq_process(mcc_object->parent_function);
+
+	/* Assign the async callback. */
+	mcc_object->async_context = callback_context;
+	mcc_object->async_callback = callback;
+
+	be_unlock_cq_process(mcc_object->parent_function);
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
+ * function_object -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS be_wait_for_POST_complete(IN PBE_FUNCTION_OBJECT function_object)
+{
+	MGMT_HBA_POST_STATUS_STRUCT postStatus;
+	BESTATUS status;
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
+		postStatus.dw =
+		    BeCsrRead(function_object->sa_dev, MPU_EP_SEMAPHORE, NULL);
+		if (0 == (loops % print_frequency_loops)) {
+			/* Print current status */
+			TRACE(DL_INFO, "POST status = 0x%x (stage = 0x%x)",
+			      postStatus.dw, postStatus.stage);
+		}
+		sa_dev_stall(function_object->sa_dev, us_per_loop);
+	} while ((postStatus.error != 1) &&
+		 (postStatus.stage != POST_STAGE_ARMFW_READY) &&
+		 (++loops < max_loops));
+
+	if (postStatus.error == 1) {
+		TRACE(DL_ERR, "POST error! Status = 0x%x (stage = 0x%x)",
+		      postStatus.dw, postStatus.stage);
+		status = BE_NOT_OK;
+	} else if (postStatus.stage != POST_STAGE_ARMFW_READY) {
+		TRACE(DL_ERR,
+		      "POST time-out! Status = 0x%x (stage = 0x%x)",
+		      postStatus.dw, postStatus.stage);
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
+ * function_object -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS
+be_kickoff_and_wait_for_POST(IN PBE_FUNCTION_OBJECT function_object)
+{
+	MGMT_HBA_POST_STATUS_STRUCT postStatus;
+	BESTATUS status;
+
+	const u32 us_per_loop = 1000;	/* 1000us */
+	const u32 print_frequency_loops = 1000000 / us_per_loop;
+	const u32 max_loops = 5 * print_frequency_loops;
+	u32 loops = 0;
+
+	/* Wait for arm fw awaiting host ready or a fatal error happened. */
+	TRACE(DL_INFO, "Wait for BladeEngine ready to POST");
+	do {
+		postStatus.dw =
+		    BeCsrRead(function_object->sa_dev, MPU_EP_SEMAPHORE, NULL);
+		if (0 == (loops % print_frequency_loops)) {
+			/* Print current status */
+			TRACE(DL_INFO, "POST status = 0x%x (stage = 0x%x)",
+			      postStatus.dw, postStatus.stage);
+		}
+		sa_dev_stall(function_object->sa_dev, us_per_loop);
+	} while ((postStatus.error != 1) &&
+		 (postStatus.stage < POST_STAGE_AWAITING_HOST_RDY) &&
+		 (++loops < max_loops));
+
+	if (postStatus.error == 1) {
+		TRACE(DL_ERR,
+		      "Pre-POST error! Status = 0x%x (stage = 0x%x)",
+		      postStatus.dw, postStatus.stage);
+		status = BE_NOT_OK;
+	} else if (postStatus.stage == POST_STAGE_AWAITING_HOST_RDY) {
+		BeCsrWrite(function_object->sa_dev, MPU_EP_SEMAPHORE,
+			   POST_STAGE_HOST_RDY, NULL);
+
+		/* Wait for POST to complete */
+		status = be_wait_for_POST_complete(function_object);
+	} else {
+		/*
+		 * Either a timeout waiting for host ready signal or POST has
+		 * moved ahead without requiring a host ready signal.
+		 * Might as well give POST a chance to complete
+		 * (or timeout again).
+		 */
+		status = be_wait_for_POST_complete(function_object);
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
+ * function_object -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS be_pci_soft_reset(PBE_FUNCTION_OBJECT function_object)
+{
+	PCICFG_SOFT_RESET_CSR pciSoftReset;
+	PCICFG_ONLINE0_CSR pciOnline0;
+	PCICFG_ONLINE1_CSR pciOnline1;
+	EP_CONTROL_CSR epControlCsr;
+	BESTATUS status = BE_SUCCESS;
+	u32 i;
+
+	TRACE(DL_NOTE, "PCI reset...");
+
+	/* Issue soft reset #1 to get BladeEngine into a known state. */
+	pciSoftReset.dw = PCICFG0_READ(function_object, soft_reset);
+	pciSoftReset.softreset = 1;
+	PCICFG0_WRITE(function_object, soft_reset, pciSoftReset);
+
+	/*
+	 * wait til soft reset is deasserted - hardware
+	 * deasserts after some time.
+	 */
+	i = 0;
+	while (pciSoftReset.softreset && (i++ < 1024)) {
+		sa_dev_stall(function_object->sa_dev, 50);
+		pciSoftReset.dw =
+		    PCICFG0_READ(function_object, soft_reset);
+	};
+	if (pciSoftReset.softreset != 0) {
+		TRACE(DL_ERR,
+		      "Soft-reset #1 did not deassert as expected.");
+		status = BE_NOT_OK;
+		goto Error_label;
+	}
+	/* Mask everything  */
+	PCICFG0_WRITE_CONST(function_object, ue_status_low_mask,
+			    0xFFFFFFFF);
+	PCICFG0_WRITE_CONST(function_object, ue_status_hi_mask,
+			    0xFFFFFFFF);
+
+	/*
+	 * Set everything offline except MPU IRAM (it is offline with
+	 * the soft-reset, but soft-reset does not reset the PCICFG registers!)
+	 */
+	pciOnline0.dw = 0;
+	pciOnline1.dw = 0;
+	pciOnline1.mpu_iram_online = 1;
+	PCICFG0_WRITE(function_object, online0, pciOnline0);
+	PCICFG0_WRITE(function_object, online1, pciOnline1);
+
+	sa_dev_stall(function_object->sa_dev, 50000);	/* delay 5ms */
+
+	/* Issue soft reset #2. */
+	pciSoftReset.softreset = 1;
+	PCICFG0_WRITE(function_object, soft_reset, pciSoftReset);
+
+	/*
+	 * wait til soft reset is deasserted - hardware
+	 * deasserts after some time.
+	 */
+	i = 0;
+	while (pciSoftReset.softreset && (i++ < 1024)) {
+		sa_dev_stall(function_object->sa_dev, 50);
+		pciSoftReset.dw =
+		    PCICFG0_READ(function_object, soft_reset);
+	};
+	if (pciSoftReset.softreset != 0) {
+		TRACE(DL_ERR,
+		      "Soft-reset #2 did not deassert as expected.");
+		status = BE_NOT_OK;
+		goto Error_label;
+	}
+
+	sa_dev_stall(function_object->sa_dev, 50000);	/* delay 5ms */
+
+	/* Take MPU out of reset. */
+
+	/*epControlCsr.dw = CSR_READ(function_object, mpu.ep.ep_control); */
+	epControlCsr.dw =
+	    BeCsrRead(function_object->sa_dev, MPU_EP_CONTROL, NULL);
+	epControlCsr.CPU_reset = 0;
+	/*CSR_WRITE(function_object, mpu.ep.ep_control, epControlCsr); */
+	BeCsrWrite(function_object->sa_dev, MPU_EP_CONTROL,
+		   epControlCsr.dw, NULL);
+
+	/* Kickoff BE POST and wait for completion */
+	status = be_kickoff_and_wait_for_POST(function_object);
+
+Error_label:
+	return status;
+}
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_acquire_reset_semaphore
+ *   Acquires the reset semaphore. If success is returned, the
+ *   caller owns the reset semaphore. Otherwise the caller does not
+ *   own the reset semaphore. Callers must acquire the reset semaphore
+ *   before inducing a BladeEngine runtime reset. Callers must
+ *   also release the reset semaphore once they are done with a
+ *   soft reset. Release of the reset semaphore is accomplished with
+ *   be_release_reset_semaphore.
+ * function_object -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS be_acquire_reset_semaphore(IN PBE_FUNCTION_OBJECT function_object)
+{
+	ASSERT(FALSE == function_object->own_semaphore);
+	if (FALSE == function_object->own_semaphore) {
+		if (0 == PCICFG0_READ(function_object, semaphore[2])) {
+			/* This driver now owns the resource */
+			function_object->own_semaphore = TRUE;
+			return BE_SUCCESS;
+		} else {
+			/* Some other driver owns the resource */
+			return BE_NOT_OK;
+		}
+	}
+
+	return BE_SUCCESS;
+}
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_release_reset_semaphore
+ *   Releases the reset semaphore. Callers must release the reset
+ *   semaphore once they are done with a soft reset.
+ * function_object    -
+ * return return_type -
+ *-------------------------------------------------------------------
+ */
+void be_release_reset_semaphore(IN PBE_FUNCTION_OBJECT function_object)
+{
+	ASSERT(TRUE == function_object->own_semaphore);
+
+	if (TRUE == function_object->own_semaphore) {
+		PCICFG0_WRITE_CONST(function_object, semaphore[2], 0);
+		function_object->own_semaphore = FALSE;
+	}
+
+	return;
+}
+
+/*
+ *-------------------------------------------------------------------
+ * Function: be_pci_reset_required
+ *   This private function is called to detect if a host entity is
+ *   required to issue a PCI soft reset and subsequently drive
+ *   BladeEngine POST. Scenarios where this is required:
+ *   1) BIOS-less configuration
+ *   2) Hot-swap/plug/power-on
+ * function_object -
+ * return   TRUE if a reset is required, FALSE otherwise
+ *-------------------------------------------------------------------
+ */
+boolean be_pci_reset_required(IN PBE_FUNCTION_OBJECT function_object)
+{
+	MGMT_HBA_POST_STATUS_STRUCT postStatus;
+	boolean doReset = FALSE;
+
+	/*
+	 * Read the POST status register
+	 *postStatus.dw = CSR_READ(function_object, mpu.ep.ep_semaphore);
+	 */
+	postStatus.dw =
+	    BeCsrRead(function_object->sa_dev, MPU_EP_SEMAPHORE, NULL);
+
+	if (postStatus.stage <= POST_STAGE_AWAITING_HOST_RDY) {
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
+ * function_object -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-------------------------------------------------------------------
+ */
+BESTATUS be_drive_POST(IN PBE_FUNCTION_OBJECT function_object)
+{
+	BESTATUS status;
+
+	if (FALSE != be_pci_reset_required(function_object)) {
+		/* PCI reset is needed (implicitly starts and waits for POST) */
+		status = be_pci_soft_reset(function_object);
+	} else {
+		/* No PCI reset is needed, start POST */
+		status = be_kickoff_and_wait_for_POST(function_object);
+	}
+
+	return status;
+}

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

