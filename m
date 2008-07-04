From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 5/8] benet: hwlib functions
Date: Fri, 04 Jul 2008 09:55:05 -0700
Message-ID: <20080704165505.341f0749@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.245.99]:35277 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbYGDQzK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 12:55:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/net/benet/hwlib/funcobj.c |  565 +++++++++++++++
 drivers/net/benet/hwlib/mpu.c     | 1362 +++++++++++++++++++++++++++++++++++++
 2 files changed, 1927 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/benet/hwlib/funcobj.c
 create mode 100644 drivers/net/benet/hwlib/mpu.c

diff --git a/drivers/net/benet/hwlib/funcobj.c b/drivers/net/benet/hwlib/funcobj.c
new file mode 100644
index 0000000..6eabe96
--- /dev/null
+++ b/drivers/net/benet/hwlib/funcobj.c
@@ -0,0 +1,565 @@
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
+#include "hwlib.h"
+#include "bestatus.h"
+
+
+int
+be_function_internal_query_firmware_config(struct be_function_object *pfob,
+				   struct BE_FIRMWARE_CONFIG *config)
+{
+	struct FWCMD_COMMON_FIRMWARE_CONFIG *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	int status = 0;
+	unsigned long irql;
+	struct be_mcc_wrb_response_copy rc;
+
+	spin_lock_irqsave(&pfob->post_lock, irql);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_FIRMWARE_CONFIG);
+
+	rc.length = FIELD_SIZEOF(struct FWCMD_COMMON_FIRMWARE_CONFIG,
+					params.response);
+	rc.fwcmd_offset = offsetof(struct FWCMD_COMMON_FIRMWARE_CONFIG,
+					params.response);
+	rc.va = config;
+
+	/* Post the f/w command */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL,
+					NULL, NULL, NULL, fwcmd, &rc);
+error:
+	spin_unlock_irqrestore(&pfob->post_lock, irql);
+	if (pfob->pend_queue_driving && pfob->mcc) {
+		pfob->pend_queue_driving = 0;
+		be_drive_mcc_wrb_queue(pfob->mcc);
+	}
+	return status;
+}
+
+/*
+    This allocates and initializes a function object based on the information
+    provided by upper layer drivers.
+
+    Returns BE_SUCCESS on success and an appropriate int on failure.
+
+    A function object represents a single BladeEngine (logical) PCI function.
+    That is a function object either represents
+    the networking side of BladeEngine or the iSCSI side of BladeEngine.
+
+    This routine will also detect and create an appropriate PD object for the
+    PCI function as needed.
+*/
+int
+be_function_object_create(u8 __iomem *csr_va, u8 __iomem *db_va,
+		u8 __iomem *pci_va, u32 function_type,
+		struct ring_desc *mailbox, struct be_function_object *pfob)
+{
+	int status;
+
+	ASSERT(pfob);	/* not a magic assert */
+	ASSERT(function_type <= 2);
+
+	TRACE(DL_INFO, "Create function object. type:%s object:0x%p",
+	      (function_type == BE_FUNCTION_TYPE_ISCSI ? "iSCSI" :
+	       (function_type == BE_FUNCTION_TYPE_NETWORK ? "Network" :
+		"Arm")), pfob);
+
+	memset(pfob, 0, sizeof(*pfob));
+
+	pfob->type = function_type;
+	pfob->csr_va = csr_va;
+	pfob->db_va = db_va;
+	pfob->pci_va = pci_va;
+
+	spin_lock_init(&pfob->cq_lock);
+	spin_lock_init(&pfob->post_lock);
+	spin_lock_init(&pfob->mcc_context_lock);
+
+
+	pfob->pci_function_number = 1;
+
+
+	pfob->emulate = false;
+	TRACE(DL_NOTE, "Non-emulation mode");
+	status = be_drive_POST(pfob);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "BladeEngine POST failed.");
+		goto error;
+	}
+
+	/* Initialize the mailbox */
+	status = be_mpu_init_mailbox(pfob, mailbox);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "Failed to initialize mailbox.");
+		goto error;
+	}
+	/*
+	 * Cache the firmware config for ASSERTs in hwclib and later
+	 * driver queries.
+	 */
+	status = be_function_internal_query_firmware_config(pfob,
+					       &pfob->fw_config);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "Failed to query firmware config.");
+		goto error;
+	}
+
+error:
+	if (status != BE_SUCCESS) {
+		/* No cleanup necessary */
+		TRACE(DL_ERR, "Failed to create function.");
+		memset(pfob, 0, sizeof(*pfob));
+	}
+	return status;
+}
+
+/*
+    This routine drops the reference count on a given function object. Once
+    the reference count falls to zero, the function object is destroyed and all
+    resources held are freed.
+
+    FunctionObject      - The function object to drop the reference to.
+*/
+int be_function_object_destroy(struct be_function_object *pfob)
+{
+	TRACE(DL_INFO, "Destroy pfob. Object:0x%p",
+	      pfob);
+
+
+	ASSERT(pfob->mcc == NULL);
+
+	return BE_SUCCESS;
+}
+
+int be_function_cleanup(struct be_function_object *pfob)
+{
+	int status = 0;
+	u32 isr;
+	u32 host_intr;
+	struct PCICFG_HOST_TIMER_INT_CTRL_CSR_AMAP ctrl;
+
+
+	if (pfob->type == BE_FUNCTION_TYPE_NETWORK) {
+		status = be_rxf_multicast_config(pfob, false, 0,
+						NULL, NULL, NULL, NULL);
+		ASSERT(status == BE_SUCCESS);
+	}
+	/* VLAN */
+	status = be_rxf_vlan_config(pfob, false, 0, NULL, NULL, NULL, NULL);
+	ASSERT(status == BE_SUCCESS);
+	/*
+	 * MCC Queue -- Switches to mailbox mode.  May want to destroy
+	 * all but the MCC CQ before this call if polling CQ is much better
+	 * performance than polling mailbox register.
+	 */
+	if (pfob->mcc)
+		status = be_mcc_ring_destroy(pfob->mcc);
+	/*
+	 * If interrupts are disabled, clear any CEV interrupt assertions that
+	 * fired after we stopped processing EQs.
+	 */
+	ctrl.dw[0] = PCICFG1_READ(pfob, host_timer_int_ctrl);
+	host_intr = AMAP_GET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+							hostintr, ctrl.dw);
+	if (!host_intr)
+		if (pfob->type == BE_FUNCTION_TYPE_NETWORK)
+			isr = CSR_READ(pfob, cev.isr1);
+		else
+			isr = CSR_READ(pfob, cev.isr0);
+	else
+		/* This should never happen... */
+		TRACE(DL_ERR, "function_cleanup called with interrupt enabled");
+	/* Function object destroy */
+	status = be_function_object_destroy(pfob);
+	ASSERT(status == BE_SUCCESS);
+
+	return status;
+}
+
+
+void *
+be_function_prepare_embedded_fwcmd(struct be_function_object *pfob,
+	struct MCC_WRB_AMAP *wrb, u32 payld_len, u32 request_length,
+	u32 response_length, u32 opcode, u32 subsystem)
+{
+	struct FWCMD_REQUEST_HEADER *header = NULL;
+	u32 n;
+
+	ASSERT(wrb);
+
+	n = AMAP_BYTE_OFFSET(MCC_WRB, payload);
+	AMAP_SET_BITS_PTR(MCC_WRB, embedded, wrb, 1);
+	AMAP_SET_BITS_PTR(MCC_WRB, payload_length, wrb, min(payld_len, n));
+	header = (struct FWCMD_REQUEST_HEADER *)((u8 *)wrb + n);
+
+	header->timeout = 0;
+	header->domain = 0;
+	header->request_length = max(request_length, response_length);
+	header->opcode = opcode;
+	header->subsystem = subsystem;
+
+	return header;
+}
+
+void *
+be_function_prepare_nonembedded_fwcmd(struct be_function_object *pfob,
+	struct MCC_WRB_AMAP *wrb,
+	void *fwcmd_va, u64 fwcmd_pa,
+	u32 payld_len,
+	u32 request_length,
+	u32 response_length,
+	u32 opcode, u32 subsystem)
+{
+	struct FWCMD_REQUEST_HEADER *header = NULL;
+	u32 n;
+	struct MCC_WRB_PAYLOAD_AMAP *plp;
+
+	ASSERT(wrb);
+	ASSERT(fwcmd_va);
+
+	header = (struct FWCMD_REQUEST_HEADER *) fwcmd_va;
+
+	AMAP_SET_BITS_PTR(MCC_WRB, embedded, wrb, 0);
+	AMAP_SET_BITS_PTR(MCC_WRB, payload_length, wrb, payld_len);
+
+	/*
+	 * Assume one fragment. The caller may override the SGL by
+	 * rewriting the 0th length and adding more entries.  They
+	 * will also need to update the sge_count.
+	 */
+	AMAP_SET_BITS_PTR(MCC_WRB, sge_count, wrb, 1);
+
+	n = AMAP_BYTE_OFFSET(MCC_WRB, payload);
+	plp = (struct MCC_WRB_PAYLOAD_AMAP *)((u8 *)wrb + n);
+	AMAP_SET_BITS_PTR(MCC_WRB_PAYLOAD, sgl[0].length, plp, payld_len);
+	AMAP_SET_BITS_PTR(MCC_WRB_PAYLOAD, sgl[0].pa_lo, plp, (u32)fwcmd_pa);
+	AMAP_SET_BITS_PTR(MCC_WRB_PAYLOAD, sgl[0].pa_hi, plp,
+					upper_32_bits(fwcmd_pa));
+
+	header->timeout = 0;
+	header->domain = 0;
+	header->request_length = max(request_length, response_length);
+	header->opcode = opcode;
+	header->subsystem = subsystem;
+
+	return header;
+}
+
+struct MCC_WRB_AMAP *
+be_function_peek_mcc_wrb(struct be_function_object *pfob)
+{
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 offset;
+
+	if (pfob->mcc)
+		wrb = _be_mpu_peek_ring_wrb(pfob->mcc, false);
+	else {
+		offset = AMAP_BYTE_OFFSET(MCC_MAILBOX, wrb);
+		wrb = (struct MCC_WRB_AMAP *) ((u8 *) pfob->mailbox.va +
+				offset);
+	}
+
+	if (wrb)
+		memset(wrb, 0, sizeof(struct MCC_WRB_AMAP));
+
+	return wrb;
+}
+
+#if defined(BE_DEBUG)
+void be_function_debug_print_wrb(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb, void *optional_fwcmd_va,
+		struct be_mcc_wrb_context *wrb_context)
+{
+
+	struct FWCMD_REQUEST_HEADER *header = NULL;
+	u8 embedded;
+	u32 n;
+
+	embedded = AMAP_GET_BITS_PTR(MCC_WRB, embedded, wrb);
+
+	if (embedded) {
+		n = AMAP_BYTE_OFFSET(MCC_WRB, payload);
+		header = (struct FWCMD_REQUEST_HEADER *)((u8 *)wrb + n);
+	} else {
+		header = (struct FWCMD_REQUEST_HEADER *) optional_fwcmd_va;
+	}
+
+	/* Save the completed count before posting for a debug assert. */
+
+	if (header) {
+		wrb_context->opcode = header->opcode;
+		wrb_context->subsystem = header->subsystem;
+
+	} else {
+		wrb_context->opcode = 0;
+		wrb_context->subsystem = 0;
+	}
+}
+#else
+#define be_function_debug_print_wrb(a_, b_, c_, d_)
+#endif
+
+int
+be_function_post_mcc_wrb(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_q_ctxt *q_ctxt,
+		mcc_wrb_cqe_callback cb, void *cb_context,
+		mcc_wrb_cqe_callback internal_cb,
+		void *internal_cb_context, void *optional_fwcmd_va,
+		struct be_mcc_wrb_response_copy *rc)
+{
+	int status;
+	struct be_mcc_wrb_context *wrb_context = NULL;
+	u64 *p;
+
+	if (q_ctxt) {
+		/* Initialize context.         */
+		q_ctxt->context.internal_cb = internal_cb;
+		q_ctxt->context.internal_cb_context = internal_cb_context;
+		q_ctxt->context.cb = cb;
+		q_ctxt->context.cb_context = cb_context;
+		if (rc) {
+			q_ctxt->context.copy.length = rc->length;
+			q_ctxt->context.copy.fwcmd_offset = rc->fwcmd_offset;
+			q_ctxt->context.copy.va = rc->va;
+		} else
+			q_ctxt->context.copy.length = 0;
+
+		q_ctxt->context.optional_fwcmd_va = optional_fwcmd_va;
+
+		/* Queue this request */
+		status = be_function_queue_mcc_wrb(pfob, q_ctxt);
+
+		goto Error;
+	}
+	/*
+	 * Allocate a WRB context struct to hold the callback pointers,
+	 * status, etc.  This is required if commands complete out of order.
+	 */
+	wrb_context = _be_mcc_allocate_wrb_context(pfob);
+	if (!wrb_context) {
+		TRACE(DL_WARN, "Failed to allocate MCC WRB context.");
+		status = BE_STATUS_SYSTEM_RESOURCES;
+		goto Error;
+	}
+	/* Initialize context. */
+	memset(wrb_context, 0, sizeof(*wrb_context));
+	wrb_context->internal_cb = internal_cb;
+	wrb_context->internal_cb_context = internal_cb_context;
+	wrb_context->cb = cb;
+	wrb_context->cb_context = cb_context;
+	if (rc) {
+		wrb_context->copy.length = rc->length;
+		wrb_context->copy.fwcmd_offset = rc->fwcmd_offset;
+		wrb_context->copy.va = rc->va;
+	} else
+		wrb_context->copy.length = 0;
+	wrb_context->wrb = wrb;
+
+	/*
+	 * Copy the context pointer into the WRB opaque tag field.
+	 * Verify assumption of 64-bit tag with a compile time assert.
+	 */
+	p = (u64 *) ((u8 *)wrb + AMAP_BYTE_OFFSET(MCC_WRB, tag));
+	*p = (u64)(size_t)wrb_context;
+
+	/* Print info about this FWCMD for debug builds. */
+	be_function_debug_print_wrb(pfob, wrb, optional_fwcmd_va, wrb_context);
+
+	/*
+	 * issue the WRB to the MPU as appropriate
+	 */
+	if (pfob->mcc) {
+		/*
+		 * we're in WRB mode, pass to the mcc layer
+		 */
+		status = _be_mpu_post_wrb_ring(pfob->mcc, wrb, wrb_context);
+	} else {
+		/*
+		 * we're in mailbox mode
+		 */
+		status = _be_mpu_post_wrb_mailbox(pfob, wrb, wrb_context);
+
+		/* mailbox mode always completes synchronously */
+		ASSERT(status != BE_STATUS_PENDING);
+	}
+
+Error:
+
+	return status;
+}
+
+int
+be_function_ring_destroy(struct be_function_object *pfob,
+		u32 id, u32 ring_type, mcc_wrb_cqe_callback cb,
+		void *cb_context, mcc_wrb_cqe_callback internal_cb,
+		void *internal_cb_context)
+{
+
+	struct FWCMD_COMMON_RING_DESTROY *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	int status = 0;
+	unsigned long irql;
+
+	spin_lock_irqsave(&pfob->post_lock, irql);
+
+	TRACE(DL_INFO, "Destroy ring id:%d type:%d", id, ring_type);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in destroy ring.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_RING_DESTROY);
+
+	fwcmd->params.request.id = id;
+	fwcmd->params.request.ring_type = ring_type;
+
+	/* Post the f/w command */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, cb, cb_context,
+				internal_cb, internal_cb_context, fwcmd, NULL);
+	if (status != BE_SUCCESS && status != BE_PENDING) {
+		TRACE(DL_ERR, "Ring destroy fwcmd failed. id:%d ring_type:%d",
+			id, ring_type);
+		goto Error;
+	}
+
+Error:
+	spin_unlock_irqrestore(&pfob->post_lock, irql);
+	if (pfob->pend_queue_driving && pfob->mcc) {
+		pfob->pend_queue_driving = 0;
+		be_drive_mcc_wrb_queue(pfob->mcc);
+	}
+	return status;
+}
+
+void
+be_rd_to_pa_list(struct ring_desc *rd, struct PHYS_ADDR *pa_list, u32 max_num)
+{
+	u32 num_pages = PAGES_SPANNED(rd->va, rd->length);
+	u32 i = 0;
+	u64 pa = rd->pa;
+	__le64 lepa;
+
+	ASSERT(pa_list);
+	ASSERT(pa);
+
+	for (i = 0; i < min(num_pages, max_num); i++) {
+		lepa = cpu_to_le64(pa);
+		pa_list[i].lo = (u32)lepa;
+		pa_list[i].hi = upper_32_bits(lepa);
+		pa += PAGE_SIZE;
+	}
+}
+
+
+
+/*-----------------------------------------------------------------------------
+ * Function: be_function_get_fw_version
+ *   Retrieves the firmware version on the adpater. If the callback is
+ *   NULL this call executes synchronously. If the callback is not NULL,
+ *   the returned status will be BE_PENDING if the command was issued
+ *   successfully.
+ * pfob    -
+ * fwv         - Pointer to response buffer if callback is NULL.
+ * cb           - Callback function invoked when the FWCMD completes.
+ * cb_context   - Passed to the callback function.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+int
+be_function_get_fw_version(struct be_function_object *pfob,
+		struct FWCMD_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD *fwv,
+		mcc_wrb_cqe_callback cb, void *cb_context)
+{
+	int status = BE_SUCCESS;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct FWCMD_COMMON_GET_FW_VERSION *fwcmd = NULL;
+	unsigned long irql;
+	struct be_mcc_wrb_response_copy rc;
+
+	spin_lock_irqsave(&pfob->post_lock, irql);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+
+	if (!cb && !fwv) {
+		TRACE(DL_ERR, "callback and response buffer NULL!");
+		status = BE_NOT_OK;
+		goto Error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_GET_FW_VERSION);
+
+	rc.length = FIELD_SIZEOF(struct FWCMD_COMMON_GET_FW_VERSION,
+					params.response);
+	rc.fwcmd_offset = offsetof(struct FWCMD_COMMON_GET_FW_VERSION,
+					params.response);
+	rc.va = fwv;
+
+	/* Post the f/w command */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, cb,
+				cb_context, NULL, NULL, fwcmd, &rc);
+
+Error:
+	spin_unlock_irqrestore(&pfob->post_lock, irql);
+	if (pfob->pend_queue_driving && pfob->mcc) {
+		pfob->pend_queue_driving = 0;
+		be_drive_mcc_wrb_queue(pfob->mcc);
+	}
+	return status;
+}
+
+int
+be_function_queue_mcc_wrb(struct be_function_object *pfob,
+			  struct be_generic_q_ctxt *q_ctxt)
+{
+	int status;
+
+	ASSERT(q_ctxt);
+
+	/*
+	 * issue the WRB to the MPU as appropriate
+	 */
+	if (pfob->mcc) {
+
+		/* We're in ring mode.  Queue this item. */
+		pfob->mcc->backlog_length++;
+		list_add_tail(&q_ctxt->context.list, &pfob->mcc->backlog);
+		status = BE_PENDING;
+	} else {
+		status = BE_NOT_OK;
+	}
+	return status;
+}
+
diff --git a/drivers/net/benet/hwlib/mpu.c b/drivers/net/benet/hwlib/mpu.c
new file mode 100644
index 0000000..b8db4df
--- /dev/null
+++ b/drivers/net/benet/hwlib/mpu.c
@@ -0,0 +1,1362 @@
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
+#include "hwlib.h"
+#include "bestatus.h"
+
+static
+inline void mp_ring_create(struct mp_ring *ring, u32 num, u32 size, void *va)
+{
+	ASSERT(ring);
+	memset(ring, 0, sizeof(struct mp_ring));
+	ring->num = num;
+	ring->pages = DIV_ROUND_UP(num * size, PAGE_SIZE);
+	ring->itemSize = size;
+	ring->va = va;
+}
+
+/*
+ * -----------------------------------------------------------------------
+ * Interface for 2 index rings. i.e. consumer/producer rings
+ * --------------------------------------------------------------------------
+ */
+
+/* Returns number items pending on ring. */
+static inline u32 mp_ring_num_pending(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	if (ring->num == 0)
+		return 0;
+	return be_subc(ring->pidx, ring->cidx, ring->num);
+}
+
+/* Returns number items free on ring. */
+static inline u32 mp_ring_num_empty(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	return ring->num - 1 - mp_ring_num_pending(ring);
+}
+
+/* Consume 1 item */
+static inline void mp_ring_consume(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(ring->pidx != ring->cidx);
+
+	ring->cidx = be_addc(ring->cidx, 1, ring->num);
+}
+
+/* Produce 1 item */
+static inline void mp_ring_produce(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	ring->pidx = be_addc(ring->pidx, 1, ring->num);
+}
+
+/* Consume count items */
+static inline void mp_ring_consume_multiple(struct mp_ring *ring, u32 count)
+{
+	ASSERT(ring);
+	ASSERT(mp_ring_num_pending(ring) >= count);
+	ring->cidx = be_addc(ring->cidx, count, ring->num);
+}
+
+static inline void *mp_ring_item(struct mp_ring *ring, u32 index)
+{
+	ASSERT(ring);
+	ASSERT(index < ring->num);
+	ASSERT(ring->itemSize > 0);
+	return (u8 *) ring->va + index * ring->itemSize;
+}
+
+/* Ptr to produce item */
+static inline void *mp_ring_producer_ptr(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	return mp_ring_item(ring, ring->pidx);
+}
+
+/*
+ * Returns a pointer to the current location in the ring.
+ * This is used for rings with 1 index.
+ */
+static inline void *mp_ring_current(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(ring->pidx == 0);	/* not used */
+
+	return mp_ring_item(ring, ring->cidx);
+}
+
+/*
+ * Increment index for rings with only 1 index.
+ * This is used for rings with 1 index.
+ */
+static inline void *mp_ring_next(struct mp_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(ring->num > 0);
+	ASSERT(ring->pidx == 0);	/* not used */
+
+	ring->cidx = be_addc(ring->cidx, 1, ring->num);
+	return mp_ring_current(ring);
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
+	u32 ready;
+
+	if (pfob->emulate) {
+		/* No waiting for mailbox in emulated mode. */
+		return;
+	}
+
+	mailbox_db.dw[0] = PD_READ(pfob, mcc_bootstrap_db);
+	ready = AMAP_GET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db);
+
+	while (ready == false) {
+		if ((++i & 0x3FFFF) == 0) {
+			TRACE(DL_WARN, "Waiting for mailbox ready - %dk polls",
+								i / 1000);
+		}
+		udelay(1);
+		mailbox_db.dw[0] = PD_READ(pfob, mcc_bootstrap_db);
+		ready = AMAP_GET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db);
+	}
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
+	/* form the higher bits in the address */
+	mailbox_db.dw[0] = 0;	/* init */
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, hi, &mailbox_db, 1);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db, 0);
+
+	/* bits 34 to 63 */
+	pa = (u32) (pfob->mailbox.pa >> 34);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, address, &mailbox_db, pa);
+
+	/* Wait for the MPU to be ready */
+	be_mcc_mailbox_wait(pfob);
+
+	/* Ring doorbell 1st time */
+	PD_WRITE(pfob, mcc_bootstrap_db, mailbox_db.dw[0]);
+
+	/* Wait for 1st write to be acknowledged. */
+	be_mcc_mailbox_wait(pfob);
+
+	/* lower bits 30 bits from 4th bit (bits 4 to 33)*/
+	pa = (u32) (pfob->mailbox.pa >> 4) & 0x3FFFFFFF;
+
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, hi, &mailbox_db, 0);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, ready, &mailbox_db, 0);
+	AMAP_SET_BITS_PTR(MPU_MAILBOX_DB, address, &mailbox_db, pa);
+
+	/* Ring doorbell 2nd time */
+	PD_WRITE(pfob, mcc_bootstrap_db, mailbox_db.dw[0]);
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
+	struct be_mcc_wrb_context *wrb_context = NULL;
+	u32 offset, status;
+	u8 *p;
+
+	ASSERT(cqe);
+	/*
+	 * A command completed.  Commands complete out-of-order.
+	 * Determine which command completed from the TAG.
+	 */
+	offset = AMAP_BYTE_OFFSET(MCC_CQ_ENTRY, mcc_tag);
+	p = (u8 *) cqe + offset;
+	wrb_context = (struct be_mcc_wrb_context *)(void *)(size_t)(*(u64 *)p);
+
+	ASSERT(wrb_context);
+	/*
+	 * Perform a response copy if requested.
+	 * Only copy data if the FWCMD is successful.
+	 */
+	status = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY, completion_status, cqe);
+	if (status == MGMT_STATUS_SUCCESS && wrb_context->copy.length > 0) {
+		ASSERT(wrb_context->wrb);
+		ASSERT(wrb_context->copy.va);
+		p = (u8 *)wrb_context->wrb + AMAP_BYTE_OFFSET(MCC_WRB, payload);
+		memcpy(wrb_context->copy.va,
+			  (u8 *)p + wrb_context->copy.fwcmd_offset,
+			  wrb_context->copy.length);
+	}
+
+	if (status)
+		status = BE_NOT_OK;
+	/* internal callback */
+	if (wrb_context->internal_cb) {
+		wrb_context->internal_cb(wrb_context->internal_cb_context,
+						status, wrb_context->wrb);
+	}
+
+	/* callback */
+	if (wrb_context->cb) {
+		wrb_context->cb(wrb_context->cb_context,
+					      status, wrb_context->wrb);
+	}
+	/* Free the context structure */
+	_be_mcc_free_wrb_context(pfob, wrb_context);
+}
+
+void be_drive_mcc_wrb_queue(struct be_mcc_object *mcc)
+{
+	struct be_function_object *pfob = NULL;
+	int status = BE_PENDING;
+	struct be_generic_q_ctxt *q_ctxt;
+	struct MCC_WRB_AMAP *wrb;
+	struct MCC_WRB_AMAP *queue_wrb;
+	u32 length, payload_length, sge_count, embedded;
+	unsigned long irql;
+
+	BUILD_BUG_ON((sizeof(struct be_generic_q_ctxt) <
+			  sizeof(struct be_queue_driver_context) +
+					sizeof(struct MCC_WRB_AMAP)));
+	pfob = mcc->parent_function;
+
+	spin_lock_irqsave(&pfob->post_lock, irql);
+
+	if (mcc->driving_backlog) {
+		spin_unlock_irqrestore(&pfob->post_lock, irql);
+		if (pfob->pend_queue_driving && pfob->mcc) {
+			pfob->pend_queue_driving = 0;
+			be_drive_mcc_wrb_queue(pfob->mcc);
+		}
+		return;
+	}
+	/* Acquire the flag to limit 1 thread to redrive posts. */
+	mcc->driving_backlog = 1;
+
+	while (!list_empty(&mcc->backlog)) {
+		wrb = _be_mpu_peek_ring_wrb(mcc, true);	/* Driving the queue */
+		if (!wrb)
+			break;	/* No space in the ring yet. */
+		/* Get the next queued entry to process. */
+		q_ctxt = list_first_entry(&mcc->backlog,
+				struct be_generic_q_ctxt, context.list);
+		list_del(&q_ctxt->context.list);
+		pfob->mcc->backlog_length--;
+		/*
+		 * Compute the required length of the WRB.
+		 * Since the queue element may be smaller than
+		 * the complete WRB, copy only the required number of bytes.
+		 */
+		queue_wrb = (struct MCC_WRB_AMAP *) &q_ctxt->wrb_header;
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
+		length = min(length, (u32) (q_ctxt->context.bytes -
+			offsetof(struct be_generic_q_ctxt, wrb_header)));
+
+		/* Copy the queue element WRB into the ring. */
+		memcpy(wrb, &q_ctxt->wrb_header, length);
+
+		/* Post the wrb.  This should not fail assuming we have
+		 * enough context structs. */
+		status = be_function_post_mcc_wrb(pfob, wrb, NULL,
+			   q_ctxt->context.cb, q_ctxt->context.cb_context,
+			   q_ctxt->context.internal_cb,
+			   q_ctxt->context.internal_cb_context,
+			   q_ctxt->context.optional_fwcmd_va,
+			   &q_ctxt->context.copy);
+
+		if (status == BE_SUCCESS) {
+			/*
+			 * Synchronous completion. Since it was queued,
+			 * we will invoke the callback.
+			 * To the user, this is an asynchronous request.
+			 */
+			spin_unlock_irqrestore(&pfob->post_lock, irql);
+			if (pfob->pend_queue_driving && pfob->mcc) {
+				pfob->pend_queue_driving = 0;
+				be_drive_mcc_wrb_queue(pfob->mcc);
+			}
+
+			ASSERT(q_ctxt->context.cb);
+
+			q_ctxt->context.cb(
+				q_ctxt->context.cb_context,
+						BE_SUCCESS, NULL);
+
+			spin_lock_irqsave(&pfob->post_lock, irql);
+
+		} else if (status != BE_PENDING) {
+			/*
+			 * Another resource failed.  Should never happen
+			 * if we have sufficient MCC_WRB_CONTEXT structs.
+			 * Return to head of the queue.
+			 */
+			TRACE(DL_WARN, "Failed to post a queued WRB. 0x%x",
+			      status);
+			list_add(&q_ctxt->context.list, &mcc->backlog);
+			pfob->mcc->backlog_length++;
+			break;
+		}
+	}
+
+	/* Free the flag to limit 1 thread to redrive posts. */
+	mcc->driving_backlog = 0;
+	spin_unlock_irqrestore(&pfob->post_lock, irql);
+}
+
+/* This function asserts that the WRB was consumed in order. */
+#ifdef BE_DEBUG
+u32 be_mcc_wrb_consumed_in_order(struct be_mcc_object *mcc,
+					struct MCC_CQ_ENTRY_AMAP *cqe)
+{
+	struct be_mcc_wrb_context *wrb_context = NULL;
+	u32 wrb_index;
+	u32 wrb_consumed_in_order;
+	u32 offset;
+	u8 *p;
+
+	ASSERT(cqe);
+	/*
+	 * A command completed.  Commands complete out-of-order.
+	 * Determine which command completed from the TAG.
+	 */
+	offset = AMAP_BYTE_OFFSET(MCC_CQ_ENTRY, mcc_tag);
+	p = (u8 *) cqe + offset;
+	wrb_context = (struct be_mcc_wrb_context *)(void *)(size_t)(*(u64 *)p);
+
+	ASSERT(wrb_context);
+
+	wrb_index = (u32) (((u64)(size_t)wrb_context->ring_wrb -
+		(u64)(size_t)mcc->sq.ring.va) / sizeof(struct MCC_WRB_AMAP));
+
+	ASSERT(wrb_index < mcc->sq.ring.num);
+
+	wrb_consumed_in_order = (u32) (wrb_index == mcc->consumed_index);
+	mcc->consumed_index = be_addc(mcc->consumed_index, 1, mcc->sq.ring.num);
+	return wrb_consumed_in_order;
+}
+#endif
+
+int be_mcc_process_cq(struct be_mcc_object *mcc, bool rearm)
+{
+	struct be_function_object *pfob = NULL;
+	struct MCC_CQ_ENTRY_AMAP *cqe;
+	struct CQ_DB_AMAP db;
+	struct mp_ring *cq_ring = &mcc->cq.ring;
+	struct mp_ring *mp_ring = &mcc->sq.ring;
+	u32 num_processed = 0;
+	u32 consumed = 0, valid, completed, cqe_consumed, async_event;
+
+	pfob = mcc->parent_function;
+
+	spin_lock_irqsave(&pfob->cq_lock, pfob->cq_irq);
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
+	cqe = mp_ring_current(cq_ring);
+	valid = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY, valid, cqe);
+	while (valid) {
+
+		if (num_processed >= 8) {
+			/* coalesce doorbells, but free space in cq
+			 * ring while processing. */
+			db.dw[0] = 0;	/* clear */
+			AMAP_SET_BITS_PTR(CQ_DB, qid, &db, cq_ring->id);
+			AMAP_SET_BITS_PTR(CQ_DB, rearm, &db, false);
+			AMAP_SET_BITS_PTR(CQ_DB, event, &db, false);
+			AMAP_SET_BITS_PTR(CQ_DB, num_popped, &db,
+							num_processed);
+			num_processed = 0;
+
+			PD_WRITE(pfob, cq_db, db.dw[0]);
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
+			/* Call the async event handler if it is installed. */
+			if (mcc->async_cb) {
+				event_code =
+					AMAP_GET_BITS_PTR(ASYNC_EVENT_TRAILER,
+						event_code, async_trailer);
+				mcc->async_cb(mcc->async_context,
+					    (u32) event_code, (void *) cqe);
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
+			}
+
+			completed = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY,
+					completed, cqe);
+			if (completed) {
+				/* A command completed.  Use tag to
+				 * determine which command.  */
+				be_mcc_process_cqe(pfob, cqe);
+			}
+		}
+
+		/* Reset the CQE */
+		AMAP_SET_BITS_PTR(MCC_CQ_ENTRY, valid, cqe, false);
+		num_processed++;
+
+		/* Update our tracking for the CQ ring. */
+		cqe = mp_ring_next(cq_ring);
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
+	if (num_processed > 0 || mcc->rearm == true) {
+		db.dw[0] = 0;	/* clear */
+		AMAP_SET_BITS_PTR(CQ_DB, qid, &db, cq_ring->id);
+		AMAP_SET_BITS_PTR(CQ_DB, rearm, &db, mcc->rearm);
+		AMAP_SET_BITS_PTR(CQ_DB, event, &db, false);
+		AMAP_SET_BITS_PTR(CQ_DB, num_popped, &db, num_processed);
+
+		PD_WRITE(pfob, cq_db, db.dw[0]);
+	}
+	/*
+	 * Update the consumer index after ringing the CQ doorbell.
+	 * We don't want another thread to post more WRBs before we
+	 * have CQ space available.
+	 */
+	mp_ring_consume_multiple(mp_ring, consumed);
+
+	/* Clear the processing flag. */
+	mcc->processing = 0;
+
+Error:
+	spin_unlock_irqrestore(&pfob->cq_lock, pfob->cq_irq);
+	/*
+	 * Use the local variable to detect if the current thread
+	 * holds the WRB post lock.  If rearm is false, this is
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
+int
+be_mcc_ring_create(struct be_function_object *pfob,
+		   struct ring_desc *rd, u32 length,
+		   struct be_mcc_wrb_context *context_array,
+		   u32 num_context_entries,
+		   struct be_cq_object *cq, struct be_mcc_object *mcc)
+{
+	int status = 0;
+
+	struct FWCMD_COMMON_MCC_CREATE *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	u32 num_entries_encoded, n, i;
+	void *va = NULL;
+	unsigned long irql;
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
+		if (is_power_of_2(max_length))
+			length = __roundup_pow_of_two(max_length+1) / 2;
+		else
+			length = __roundup_pow_of_two(max_length) / 2;
+
+		ASSERT(length <= max_length);
+
+		TRACE(DL_WARN,
+			"MCC ring length reduced based on context entries."
+			" length:%d wrbs:%d context_entries:%d", length,
+			length / sizeof(struct MCC_WRB_AMAP),
+			num_context_entries);
+	}
+
+	spin_lock_irqsave(&pfob->post_lock, irql);
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
+	fwcmd->params.request.num_pages = DIV_ROUND_UP(length, PAGE_SIZE);
+	/*
+	 * Program MCC ring context
+	 */
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT, pdid,
+			&fwcmd->params.request.context, 0);
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT, invalid,
+			&fwcmd->params.request.context, false);
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT, ring_size,
+			&fwcmd->params.request.context, num_entries_encoded);
+
+	n = cq->cq_id;
+	AMAP_SET_BITS_PTR(MCC_RING_CONTEXT,
+				cq_id, &fwcmd->params.request.context, n);
+	be_rd_to_pa_list(rd, fwcmd->params.request.pages,
+				ARRAY_SIZE(fwcmd->params.request.pages));
+	/* Post the f/w command */
+	status = be_function_post_mcc_wrb(pfob, wrb, NULL, NULL, NULL,
+						NULL, NULL, fwcmd, NULL);
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
+	 * Create an mcc_ring for tracking WRB hw ring
+	 */
+	va = rd->va;
+	ASSERT(va);
+	mp_ring_create(&mcc->sq.ring, length / sizeof(struct MCC_WRB_AMAP),
+				sizeof(struct MCC_WRB_AMAP), va);
+	mcc->sq.ring.id = fwcmd->params.response.id;
+	/*
+	 * Init a mcc_ring for tracking the MCC CQ.
+	 */
+	ASSERT(cq->va);
+	mp_ring_create(&mcc->cq.ring, cq->num_entries,
+		       sizeof(struct MCC_CQ_ENTRY_AMAP), cq->va);
+	mcc->cq.ring.id = cq->cq_id;
+
+	/* Force zeroing of CQ. */
+	memset(cq->va, 0, cq->num_entries * sizeof(struct MCC_CQ_ENTRY_AMAP));
+
+	/* Initialize debug index. */
+	mcc->consumed_index = 0;
+
+	atomic_inc(&cq->ref_count);
+	pfob->mcc = mcc;
+
+	TRACE(DL_INFO, "MCC ring created. id:%d bytes:%d cq_id:%d cq_entries:%d"
+	      " num_context:%d", mcc->sq.ring.id, length,
+	      cq->cq_id, cq->num_entries, num_context_entries);
+
+error:
+	spin_unlock_irqrestore(&pfob->post_lock, irql);
+	if (pfob->pend_queue_driving && pfob->mcc) {
+		pfob->pend_queue_driving = 0;
+		be_drive_mcc_wrb_queue(pfob->mcc);
+	}
+	return status;
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
+int be_mcc_ring_destroy(struct be_mcc_object *mcc)
+{
+	int status = 0;
+	struct be_function_object *pfob = mcc->parent_function;
+
+
+	ASSERT(mcc->processing == 0);
+
+	/*
+	 * Remove the ring from the function object.
+	 * This transitions back to mailbox mode.
+	 */
+	pfob->mcc = NULL;
+
+	/* Send fwcmd to destroy the queue.  (Using the mailbox.) */
+	status = be_function_ring_destroy(mcc->parent_function, mcc->sq.ring.id,
+			     FWCMD_RING_TYPE_MCC, NULL, NULL, NULL, NULL);
+	ASSERT(status == 0);
+
+	/* Release the SQ reference to the CQ */
+	atomic_dec(&mcc->cq_object->ref_count);
+
+	return status;
+}
+
+static void
+mcc_wrb_sync_cb(void *context, int staus, struct MCC_WRB_AMAP *wrb)
+{
+	struct be_mcc_wrb_context *wrb_context =
+				(struct be_mcc_wrb_context *) context;
+	ASSERT(wrb_context);
+	*wrb_context->users_final_status = staus;
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
+int
+_be_mpu_post_wrb_ring(struct be_mcc_object *mcc, struct MCC_WRB_AMAP *wrb,
+				struct be_mcc_wrb_context *wrb_context)
+{
+
+	struct MCC_WRB_AMAP *ring_wrb = NULL;
+	int status = BE_PENDING;
+	int final_status = BE_PENDING;
+	mcc_wrb_cqe_callback cb = NULL;
+	struct MCC_DB_AMAP mcc_db;
+	u32 embedded;
+
+	ASSERT(mp_ring_num_empty(&mcc->sq.ring) > 0);
+	/*
+	 * Input wrb is most likely the next wrb in the ring, since the client
+	 * can peek at the address.
+	 */
+	ring_wrb = mp_ring_producer_ptr(&mcc->sq.ring);
+	if (wrb != ring_wrb) {
+		/* If not equal, copy it into the ring. */
+		memcpy(ring_wrb, wrb, sizeof(struct MCC_WRB_AMAP));
+	}
+#ifdef BE_DEBUG
+	wrb_context->ring_wrb = ring_wrb;
+#endif
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
+	cb = wrb_context->cb;
+
+	if (cb == NULL) {
+		/* Assign our internal callback if this is a
+		 * synchronous call. */
+		wrb_context->cb = mcc_wrb_sync_cb;
+		wrb_context->cb_context = wrb_context;
+		wrb_context->users_final_status = &final_status;
+	}
+	/* Increment producer index */
+
+	mcc_db.dw[0] = 0;		/* initialize */
+	AMAP_SET_BITS_PTR(MCC_DB, rid, &mcc_db, mcc->sq.ring.id);
+	AMAP_SET_BITS_PTR(MCC_DB, numPosted, &mcc_db, 1);
+
+	mp_ring_produce(&mcc->sq.ring);
+	PD_WRITE(mcc->parent_function, mpu_mcc_db, mcc_db.dw[0]);
+	TRACE(DL_INFO, "pidx: %x and cidx: %x.", mcc->sq.ring.pidx,
+	      mcc->sq.ring.cidx);
+
+	if (cb == NULL) {
+		int polls = 0;	/* At >= 1 us per poll   */
+		/* Wait until this command completes, polling the CQ. */
+		do {
+			TRACE(DL_INFO, "FWCMD submitted in the poll mode.");
+			/* Do not rearm CQ in this context. */
+			be_mcc_process_cq(mcc, false);
+
+			if (final_status == BE_PENDING) {
+				if ((++polls & 0x7FFFF) == 0) {
+					TRACE(DL_WARN,
+					      "Warning : polling MCC CQ for %d"
+					      "ms.", polls / 1000);
+				}
+
+				udelay(1);
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
+	if (mp_ring_num_empty(&mcc->sq.ring) <= 0)
+		return NULL;
+	return (struct MCC_WRB_AMAP *) mp_ring_producer_ptr(&mcc->sq.ring);
+}
+
+int
+be_mpu_init_mailbox(struct be_function_object *pfob, struct ring_desc *mailbox)
+{
+	ASSERT(mailbox);
+	pfob->mailbox.va = mailbox->va;
+	pfob->mailbox.pa =  cpu_to_le64(mailbox->pa);
+	pfob->mailbox.length = mailbox->length;
+
+	ASSERT(((u32)(size_t)pfob->mailbox.va & 0xf) == 0);
+	ASSERT(((u32)(size_t)pfob->mailbox.pa & 0xf) == 0);
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
+int
+_be_mpu_post_wrb_mailbox(struct be_function_object *pfob,
+	 struct MCC_WRB_AMAP *wrb, struct be_mcc_wrb_context *wrb_context)
+{
+	struct MCC_MAILBOX_AMAP *mailbox = NULL;
+	struct MCC_WRB_AMAP *mb_wrb;
+	struct MCC_CQ_ENTRY_AMAP *mb_cq;
+	u32 offset, status;
+
+	ASSERT(pfob->mcc == NULL);
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
+	status = AMAP_GET_BITS_PTR(MCC_CQ_ENTRY, completion_status, mb_cq);
+	if (status)
+		status = BE_NOT_OK;
+	return status;
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
+		pfob->mailbox.default_context_allocated = true;
+		context = &pfob->mailbox.default_context;
+	} else if (pfob->mcc) {
+		/* Get a context from the free list. If any are available. */
+		if (!list_empty(&pfob->mcc->wrb_context.list_head)) {
+			context = list_first_entry(
+				&pfob->mcc->wrb_context.list_head,
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
+		pfob->mailbox.default_context_allocated = false;
+	} else {
+		/* Add to free list. */
+		ASSERT(pfob->mcc);
+		list_add_tail(&context->next,
+				&pfob->mcc->wrb_context.list_head);
+	}
+
+	spin_unlock_irqrestore(&pfob->mcc_context_lock, irq);
+}
+
+int
+be_mcc_add_async_event_callback(struct be_mcc_object *mcc_object,
+		mcc_async_event_callback cb, void *cb_context)
+{
+	/* Lock against anyone trying to change the callback/context pointers
+	 * while being used. */
+	spin_lock_irqsave(&mcc_object->parent_function->cq_lock,
+		mcc_object->parent_function->cq_irq);
+
+	/* Assign the async callback. */
+	mcc_object->async_context = cb_context;
+	mcc_object->async_cb = cb;
+
+	spin_unlock_irqrestore(&mcc_object->parent_function->cq_lock,
+					mcc_object->parent_function->cq_irq);
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
+static int be_wait_for_POST_complete(struct be_function_object *pfob)
+{
+	struct MGMT_HBA_POST_STATUS_STRUCT_AMAP status;
+	int s;
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
+		status.dw[0] = ioread32(pfob->csr_va + MPU_EP_SEMAPHORE);
+		post_error = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						error, &status);
+		post_stage = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						stage, &status);
+		if (0 == (loops % print_frequency_loops)) {
+			/* Print current status */
+			TRACE(DL_INFO, "POST status = 0x%x (stage = 0x%x)",
+				status.dw[0], post_stage);
+		}
+		udelay(us_per_loop);
+	} while ((post_error != 1) &&
+		 (post_stage != POST_STAGE_ARMFW_READY) &&
+		 (++loops < max_loops));
+
+	if (post_error == 1) {
+		TRACE(DL_ERR, "POST error! Status = 0x%x (stage = 0x%x)",
+		      status.dw[0], post_stage);
+		s = BE_NOT_OK;
+	} else if (post_stage != POST_STAGE_ARMFW_READY) {
+		TRACE(DL_ERR, "POST time-out! Status = 0x%x (stage = 0x%x)",
+		      status.dw[0], post_stage);
+		s = BE_NOT_OK;
+	} else {
+		s = BE_SUCCESS;
+	}
+	return s;
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
+static int
+be_kickoff_and_wait_for_POST(struct be_function_object *pfob)
+{
+	struct MGMT_HBA_POST_STATUS_STRUCT_AMAP status;
+	int s;
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
+		status.dw[0] = ioread32(pfob->csr_va + MPU_EP_SEMAPHORE);
+		post_error = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						error, &status);
+		post_stage = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT,
+						stage, &status);
+		if (0 == (loops % print_frequency_loops)) {
+			/* Print current status */
+			TRACE(DL_INFO, "POST status = 0x%x (stage = 0x%x)",
+			      status.dw[0], post_stage);
+		}
+		udelay(us_per_loop);
+	} while ((post_error != 1) &&
+		 (post_stage < POST_STAGE_AWAITING_HOST_RDY) &&
+		 (++loops < max_loops));
+
+	if (post_error == 1) {
+		TRACE(DL_ERR, "Pre-POST error! Status = 0x%x (stage = 0x%x)",
+		      status.dw[0], post_stage);
+		s = BE_NOT_OK;
+	} else if (post_stage == POST_STAGE_AWAITING_HOST_RDY) {
+		iowrite32(POST_STAGE_HOST_RDY, pfob->csr_va + MPU_EP_SEMAPHORE);
+
+		/* Wait for POST to complete */
+		s = be_wait_for_POST_complete(pfob);
+	} else {
+		/*
+		 * Either a timeout waiting for host ready signal or POST has
+		 * moved ahead without requiring a host ready signal.
+		 * Might as well give POST a chance to complete
+		 * (or timeout again).
+		 */
+		s = be_wait_for_POST_complete(pfob);
+	}
+	return s;
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
+int be_pci_soft_reset(struct be_function_object *pfob)
+{
+	struct PCICFG_SOFT_RESET_CSR_AMAP soft_reset;
+	struct PCICFG_ONLINE0_CSR_AMAP pciOnline0;
+	struct PCICFG_ONLINE1_CSR_AMAP pciOnline1;
+	struct EP_CONTROL_CSR_AMAP epControlCsr;
+	int status = BE_SUCCESS;
+	u32 i, soft_reset_bit;
+
+	TRACE(DL_NOTE, "PCI reset...");
+
+	/* Issue soft reset #1 to get BladeEngine into a known state. */
+	soft_reset.dw[0] = PCICFG0_READ(pfob, soft_reset);
+	AMAP_SET_BITS_PTR(PCICFG_SOFT_RESET_CSR, softreset, soft_reset.dw, 1);
+	PCICFG0_WRITE(pfob, host_timer_int_ctrl, soft_reset.dw[0]);
+	/*
+	 * wait til soft reset is deasserted - hardware
+	 * deasserts after some time.
+	 */
+	i = 0;
+	do {
+		udelay(50);
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
+	PCICFG0_WRITE(pfob, ue_status_low_mask, 0xFFFFFFFF);
+	PCICFG0_WRITE(pfob, ue_status_hi_mask, 0xFFFFFFFF);
+	/*
+	 * Set everything offline except MPU IRAM (it is offline with
+	 * the soft-reset, but soft-reset does not reset the PCICFG registers!)
+	 */
+	pciOnline0.dw[0] = 0;
+	pciOnline1.dw[0] = 0;
+	AMAP_SET_BITS_PTR(PCICFG_ONLINE1_CSR, mpu_iram_online,
+				pciOnline1.dw, 1);
+	PCICFG0_WRITE(pfob, online0, pciOnline0.dw[0]);
+	PCICFG0_WRITE(pfob, online1, pciOnline1.dw[0]);
+
+	udelay(20000);
+
+	/* Issue soft reset #2. */
+	AMAP_SET_BITS_PTR(PCICFG_SOFT_RESET_CSR, softreset, soft_reset.dw, 1);
+	PCICFG0_WRITE(pfob, host_timer_int_ctrl, soft_reset.dw[0]);
+	/*
+	 * wait til soft reset is deasserted - hardware
+	 * deasserts after some time.
+	 */
+	i = 0;
+	do {
+		udelay(50);
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
+	udelay(20000);
+
+	/* Take MPU out of reset. */
+
+	epControlCsr.dw[0] = ioread32(pfob->csr_va + MPU_EP_CONTROL);
+	AMAP_SET_BITS_PTR(EP_CONTROL_CSR, CPU_reset, &epControlCsr, 0);
+	iowrite32((u32)epControlCsr.dw, pfob->csr_va + MPU_EP_CONTROL);
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
+ * return   true if a reset is required, false otherwise
+ *-------------------------------------------------------------------
+ */
+static bool be_pci_reset_required(struct be_function_object *pfob)
+{
+	struct MGMT_HBA_POST_STATUS_STRUCT_AMAP status;
+	bool do_reset = false;
+	u32 post_error, post_stage;
+
+	/*
+	 * Read the POST status register
+	 */
+	status.dw[0] = ioread32(pfob->csr_va + MPU_EP_SEMAPHORE);
+	post_error = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT, error,
+								&status);
+	post_stage = AMAP_GET_BITS_PTR(MGMT_HBA_POST_STATUS_STRUCT, stage,
+								&status);
+	if (post_stage <= POST_STAGE_AWAITING_HOST_RDY) {
+		/*
+		 * If BladeEngine is waiting for host ready indication,
+		 * we want to do a PCI reset.
+		 */
+		do_reset = true;
+	}
+
+	return do_reset;
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
+int be_drive_POST(struct be_function_object *pfob)
+{
+	int status;
+
+	if (false != be_pci_reset_required(pfob)) {
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

