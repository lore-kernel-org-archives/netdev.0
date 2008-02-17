From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 6/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:33:00 -0800
Message-ID: <20080217023300.1118ec0a@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:54042 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbYBQCdG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:33:06 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:33:01 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

beclib functions that implement function object.

---------------------------------------------

diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/funcobj_ll.c benet/linux-2.6.24.2/drivers/message/beclib/funcobj_ll.c
--- orig/linux-2.6.24.2/drivers/message/beclib/funcobj_ll.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/funcobj_ll.c	2008-02-14 15:23:07.806206040 +0530
@@ -0,0 +1,2339 @@
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
+#ifdef FUNCTION_ISCSI
+/*
+ *============================================================================
+ *                            F I L E   S C O P E
+ *============================================================================
+ */
+
+/*!
+@brief
+    This routine allocates iscsi ooo buffers & then registers them
+    with the controller.
+@param function_object - the iscsi function object to create these for
+@param page_count      - number of pages to allocate for i_sc_si ooo buffers
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+*/
+BESTATUS
+be_function_iscsi_ooo_buffers_post(PBE_FUNCTION_OBJECT function_object,
+				   u32 page_count, PSA_SGL sgl)
+{
+	BESTATUS status = BE_SUCCESS;
+	IOCTL_COMMON_ISCSI_CFG_POST_OOO_BUFFERS *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	u32 num_pages = 0;
+	u32 page_offset = 0;
+	u32 i;
+
+	be_lock_wrb_post(function_object);
+
+	ASSERT(sa_sgl_get_offset(sgl) == 0);	/* need page aligned buffers */
+	ASSERT(page_count <= sa_sgl_get_page_count(sgl));
+
+	/* sw tracking */
+	function_object->config.num_ooo += page_count;
+
+	TRACE(DL_INFO, "post ooo buffers. num:%d", page_count);
+
+	/*
+	 * Post numerous ioctls to keep each one small enuf to be embedded in
+	 * the WRB.
+	 */
+	do {
+		wrb = be_function_peek_mcc_wrb(function_object);
+		if (!wrb) {
+			TRACE(DL_ERR, "MCC wrb peek failed.");
+			status = BE_STATUS_NO_MCC_WRB;
+			goto error;
+		}
+		/*
+		 * Prepares an embedded ioctl, including
+		 * request/response sizes.
+		 */
+		ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object,
+			       wrb, COMMON_ISCSI_CFG_POST_OOO_BUFFERS);
+
+		num_pages = MIN(page_count, SA_NUMBER_OF_FIELD(
+				IOCTL_COMMON_ISCSI_CFG_POST_OOO_BUFFERS,
+							params.request.pages));
+		ioctl->params.request.num_pages = num_pages;
+
+		/* Create a page list for the IOCTL. */
+		for (i = 0; i < ioctl->params.request.num_pages; i++) {
+			u64 pa = sa_sgl_get_page(sgl, page_offset + i);
+			ioctl->params.request.pages[i].lo = sa_lo(pa);
+			ioctl->params.request.pages[i].hi = sa_hi(pa);
+		}
+
+		page_offset += num_pages;
+		page_count -= num_pages;
+
+		ioctl->params.request.final = (page_count == 0 ? 1 : 0);
+
+		status =
+		    be_function_post_mcc_wrb(function_object, wrb, NULL,
+					     NULL, ioctl);
+		if (status != BE_SUCCESS) {
+			TRACE(DL_ERR,
+			      "MCC to add iscsi ooo buffers failed.");
+			goto error;
+		}
+
+	} while (page_count > 0);
+
+error:
+	be_unlock_wrb_post(function_object);
+	return status;
+}
+
+/*!
+@brief
+    This routine allocates iSCSI ooo buffers & then registers them
+    with the controller.
+@param
+    FunctionObject      - The iSCSI function object to create these for
+@param
+    PageCount           - Number of pages to allocate for iSCSI ooo buffers
+@return
+    BE_SUCCESS if successfull, otherwise a useful BESTATUS is returned.
+*/
+BESTATUS
+be_function_iscsi_ooo_buffers_remove(PBE_FUNCTION_OBJECT function_object)
+{
+	BESTATUS status = BE_SUCCESS;
+	IOCTL_COMMON_ISCSI_CFG_REMOVE_OOO_BUFFERS *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+
+	be_lock_wrb_post(function_object);
+
+	/* sw tracking */
+	function_object->config.num_ooo = 0;
+	TRACE(DL_INFO, "remove ooo buffers.");
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+				       COMMON_ISCSI_CFG_REMOVE_OOO_BUFFERS);
+
+	status =
+	    be_function_post_mcc_wrb(function_object, wrb, NULL, NULL,
+				     ioctl);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "MCC to remove iscsi ooo buffers failed.");
+		goto error;
+	}
+
+error:
+
+	be_unlock_wrb_post(function_object);
+	return status;
+}
+#endif
+
+/*!
+
+@brief
+    This allocates an initializes a function object based on the information
+    provided by upper layer drivers.
+
+@param
+     BarLocations     - Location & information on PCI BARs contained
+			by this PCI function
+@param
+    Upcall            - Dispatch table of calls into the upper layer drivers
+@param
+    ppFunctionObject  - New function object
+
+@return
+    Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+    A function object represents a single BladeEngine (logical) PCI function.
+    That is a function object either represents
+    the networking side of BladeEngine or the iSCSI side of BladeEngine. Each
+    function object has a chip object that is shared by up to 1 other function
+    object.
+
+    This routine will also detect and create an appropriate PD object for the
+    PCI function as needed.
+
+*/
+BESTATUS
+be_function_create(IN SA_DEV *sa_dev,
+		   IN u32 function_type,
+		   IN PSA_SGL mailbox,
+		   OUT PBE_FUNCTION_OBJECT function_object)
+{
+	BESTATUS status;
+
+	SA_TRACE_ENTRY();
+
+	ASSERT(sa_dev);
+	ASSERT(function_object);	/* not a magic assert */
+	ASSERT(function_type <= 2);
+
+	TRACE(DL_INFO,
+	      "Create function object. type:%s sa_dev:0x%p object:0x%p",
+	      (function_type == BE_FUNCTION_TYPE_ISCSI ? "iSCSI" :
+	       (function_type == BE_FUNCTION_TYPE_NETWORK ? "Network" :
+		"Arm")), sa_dev, function_object);
+
+	sa_zero_mem(function_object, sizeof(*function_object));
+
+	function_object->magic = BE_FUNCTION_MAGIC;
+	function_object->ref_count = 0;
+	function_object->type = function_type;
+	function_object->sa_dev = sa_dev;
+
+	be_lock_init(&function_object->lock);
+
+	sa_init_spinlock(&function_object->cq_lock);
+	sa_init_spinlock(&function_object->post_lock);
+	sa_init_spinlock(&function_object->mcc_context_lock);
+
+	sa_initialize_list_head(&function_object->links.pd_list_head);
+	sa_initialize_list_head(&function_object->links.cq_list_head);
+	sa_initialize_list_head(&function_object->links.eq_list_head);
+	sa_initialize_list_head(&function_object->links.cxn_list_head);
+	sa_initialize_list_head(&function_object->links.eth_sq_list_head);
+	sa_initialize_list_head(&function_object->links.eth_rq_list_head);
+
+	if (be_function_is_iscsi(function_object)) {
+		sa_initialize_list_head(&function_object->links.iscsi.
+					wrbq_list_head);
+		sa_initialize_list_head(&function_object->links.iscsi.
+					defq_list_head);
+
+		function_object->pci_function_number = 0;
+	} else {
+
+		sa_initialize_list_head(&function_object->links.networking.
+					dq_list_head);
+		sa_initialize_list_head(&function_object->links.networking.
+					sq_list_head);
+		sa_initialize_list_head(&function_object->links.networking.
+					rq_list_head);
+
+		function_object->pci_function_number = 1;
+	}
+
+	function_object->config.rss_type = RSS_ENABLE_NONE;
+
+	function_object->emulate = FALSE;
+	TRACE(DL_NOTE, "Non-emulation mode");
+	status = be_drive_POST(function_object);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "BladeEngine POST failed.");
+		goto error;
+	}
+
+	/* Initialize the mailbox */
+	status = be_mpu_init_mailbox(function_object, mailbox);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "Failed to initialize mailbox.");
+		goto error;
+	}
+	/*
+	 * Cache the firmware config for ASSERTs in beclib and later
+	 * driver queries.
+	 */
+	status = be_function_internal_query_firmware_config(function_object,
+					       &function_object->fw_config);
+	if (status != BE_SUCCESS) {
+		TRACE(DL_ERR, "Failed to query firmware config.");
+		goto error;
+	}
+
+error:
+
+	if (status != BE_SUCCESS) {
+		/* No cleanup necessary */
+		TRACE(DL_ERR, "Failed to create function.");
+		SA_ZERO_MEM(function_object);
+	}
+
+	return status;
+}
+
+/*!
+@brief
+    This routine drops the reference count on a given function object. Once
+    the reference count falls to zero, the function object is destroyed and all
+    resources held are freed.
+
+@param
+    FunctionObject      - The function object to drop the reference to.
+*/
+BESTATUS be_function_destroy(IN PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+
+	TRACE(DL_INFO, "Destroy function_object. Object:0x%p",
+	      function_object);
+
+	if (be_function_is_iscsi(function_object)) {
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.cxn_list_head));
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.iscsi.wrbq_list_head));
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.iscsi.defq_list_head));
+		ASSERT(function_object->config.num_ooo == 0);
+		ASSERT(function_object->config.num_sgl == 0);
+	} else {
+		ASSERT(be_function_is_networking(function_object));
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.cxn_list_head));
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.networking.sq_list_head));
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.networking.rq_list_head));
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.networking.dq_list_head));
+		ASSERT(function_object->config.num_multicast == 0);
+		ASSERT(function_object->config.rss_type ==
+		       RSS_ENABLE_NONE);
+	}
+
+	ASSERT(function_object->config.num_template == 0);
+	ASSERT(function_object->config.num_jell == 0);
+	ASSERT(function_object->config.num_zero == 0);
+	ASSERT(sa_is_list_empty(&function_object->links.eth_sq_list_head));
+	ASSERT(sa_is_list_empty(&function_object->links.eth_rq_list_head));
+	ASSERT(function_object->config.num_vlan == 0);
+	ASSERT(function_object->links.mcc == NULL);
+	ASSERT(sa_is_list_empty(&function_object->links.cq_list_head));
+	ASSERT(sa_is_list_empty(&function_object->links.eq_list_head));
+	ASSERT(function_object->config.num_page_table == 0);
+
+	/* Superfluous additional ref count.     */
+	ASSERT(function_object->ref_count == 0);
+
+	return BE_SUCCESS;
+}
+
+/* Create chip object.  */
+BESTATUS be_chip_object_create(PBE_CHIP_OBJECT chip)
+{
+	BESTATUS status = 0;
+	boolean chip_created = FALSE;
+
+	status = be_chip_create(chip);
+	if (status != BE_SUCCESS) {
+		goto Error;
+	}
+
+	chip_created = TRUE;
+
+Error:
+
+	if (status != BE_SUCCESS) {
+
+		/* Cleanup everything in case of failure. */
+
+		if (chip_created) {
+			be_chip_destroy(chip);
+		}
+
+	}
+
+	return status;
+
+}
+
+/* Create function object.  */
+BESTATUS be_function_object_create(
+		SA_DEV *sa_dev,/* previously created device */
+		u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+		PSA_SGL mailbox_sgl, PBE_FUNCTION_OBJECT function_object,
+		PBE_CHIP_OBJECT chip)	/* object to initialize */
+{
+	BESTATUS status = 0;
+	boolean function_created = FALSE;
+
+	status = be_function_create(sa_dev, function_type, mailbox_sgl,
+				    function_object);
+	if (status != BE_SUCCESS) {
+		goto Error;
+	}
+
+	function_created = TRUE;
+
+	status = be_chip_insert_function_object(chip, function_object);
+
+Error:
+
+	if (status != BE_SUCCESS) {
+
+		/* Cleanup everything in case of failure. */
+
+		if (function_created) {
+			be_function_destroy(function_object);
+		}
+	}
+
+	return status;
+
+}
+
+/*
+ * Create both function and chip object with one call.  The lower level
+ * API will rarely use more than one function object.
+ */
+BESTATUS be_function_and_chip_create(
+		SA_DEV *sa_dev,	/* previously created device */
+		u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+		PSA_SGL mailbox_sgl, PSA_SGL emulation_sgl,
+		PBE_FUNCTION_OBJECT function_object, PBE_CHIP_OBJECT chip)
+{
+	BESTATUS status = 0;
+	boolean function_created = FALSE, chip_created = FALSE;
+
+	status =
+	    be_function_create(sa_dev, function_type, mailbox_sgl,
+			       function_object);
+	if (status != BE_SUCCESS) {
+		goto Error;
+	}
+
+	function_created = TRUE;
+
+	status = be_chip_create(chip);
+	if (status != BE_SUCCESS) {
+		goto Error;
+	}
+
+	chip_created = TRUE;
+
+	status = be_chip_insert_function_object(chip, function_object);
+
+Error:
+
+	if (status != BE_SUCCESS) {
+
+		/* Cleanup everything in case of failure. */
+
+		if (chip_created) {
+			be_chip_destroy(chip);
+		}
+
+		if (function_created) {
+			be_function_destroy(function_object);
+		}
+	}
+
+	return status;
+
+}
+
+BESTATUS
+be_function_and_chip_destroy(PBE_FUNCTION_OBJECT function_object,
+			     PBE_CHIP_OBJECT chip)
+{
+	TRACE(DL_INFO, "Destroy function & chip.");
+
+	be_chip_remove_function_object(chip, function_object);
+
+	be_chip_destroy(chip);
+
+	be_function_destroy(function_object);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS
+be_function_object_destroy(PBE_FUNCTION_OBJECT function_object,
+			   PBE_CHIP_OBJECT chip)
+{
+	TRACE(DL_INFO, "Destroy function & chip.");
+
+	(void)be_mpu_uninit_mailbox(function_object);
+
+	be_chip_remove_function_object(chip, function_object);
+
+	be_function_destroy(function_object);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS be_chip_object_destroy(PBE_CHIP_OBJECT chip)
+{
+	TRACE(DL_INFO, "Destroy function & chip.");
+
+	be_chip_destroy(chip);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS be_function_cleanup(PBE_FUNCTION_OBJECT function_object)
+{
+	PSA_LIST_ENTRY list_entry;
+	BESTATUS status = 0;
+	BE_CQ_OBJECT *cq = NULL;
+	BE_EQ_OBJECT *eq = NULL;
+#ifdef FUNCTION_NIC
+	BE_ETHSQ_OBJECT *eth_sq = NULL;
+	BE_ETHRQ_OBJECT *eth_rq = NULL;
+#endif
+	u32 isr;
+	PCICFG_HOST_TIMER_INT_CTRL_CSR ctrl;
+
+	FUNCTION_ASSERT(function_object);
+
+	TRACE(DL_INFO, "function cleanup. function:%d",
+	      be_function_get_function_number(function_object));
+
+#ifdef FUNCTION_ISCSI
+
+	if (be_function_is_iscsi(function_object)) {
+		/*BE_ISCSI_CONNECTION_OBJECT *iscsi_cxn = NULL; */
+		BE_ISCSI_WRB_QUEUE_OBJECT *iscsi_wrbq = NULL;
+		BE_DEFAULT_PDU_QUEUE_OBJECT *iscsi_defq = NULL;
+
+		/* Assert that all connections are terminated. */
+		ASSERT(sa_is_list_empty
+		       (&function_object->links.cxn_list_head));
+
+		/* Destroy all WRB queues. */
+		while (!sa_is_list_empty
+		       (&function_object->links.iscsi.wrbq_list_head)) {
+			list_entry =
+			    sa_list_head(&function_object->links.iscsi.
+					 wrbq_list_head);
+			iscsi_wrbq =
+			    SA_CONTAINING_RECORD(list_entry,
+						 BE_ISCSI_WRB_QUEUE_OBJECT,
+						 wrbq_list);
+
+			status = be_iscsi_wrb_queue_destroy(iscsi_wrbq);
+			ASSERT(status == BE_SUCCESS);
+		}
+
+		/* Destroy the default PDU queues */
+		while (!sa_is_list_empty
+		       (&function_object->links.iscsi.defq_list_head)) {
+			list_entry =
+			    sa_list_head(&function_object->links.iscsi.
+					 defq_list_head);
+			iscsi_defq =
+			    SA_CONTAINING_RECORD(list_entry,
+						 BE_DEFAULT_PDU_QUEUE_OBJECT,
+						 func_list);
+
+			status = be_iscsi_defq_destroy(iscsi_defq);
+			ASSERT(status == BE_SUCCESS);
+		}
+
+		/* Out-of-order buffers */
+		if (function_object->config.num_ooo > 0) {
+			status =
+			    be_function_iscsi_ooo_buffers_remove
+			    (function_object);
+			ASSERT(status == BE_SUCCESS);
+		}
+		/* SGLs */
+		if (function_object->config.num_sgl > 0) {
+			status =
+			    be_iscsi_remove_sgl_pages(function_object);
+			ASSERT(status == BE_SUCCESS);
+		}
+	}
+#endif
+
+#ifdef FUNCTION_NIC
+
+	if (!be_function_is_iscsi(function_object)) {
+
+		/* Multicast */
+		if (function_object->config.num_multicast > 0) {
+			status =
+			    be_rxf_multicast_config(function_object, FALSE,
+						    0, NULL, NULL, NULL,
+						    NULL);
+			ASSERT(status == BE_SUCCESS);
+		}
+		/* RSS Disable */
+		if (function_object->config.rss_type != RSS_ENABLE_NONE) {
+			status =
+			    be_rxf_rss_config(function_object,
+					      RSS_ENABLE_NONE, 0, NULL, 0,
+					      0, NULL, 0, NULL, NULL, NULL,
+					      NULL);
+			ASSERT(status == BE_SUCCESS);
+		}
+	}
+#endif
+
+#ifdef FUNCTION_NIC
+	/* ETX */
+	while (!sa_is_list_empty(&function_object->links.eth_sq_list_head)) {
+		list_entry =
+		    sa_list_head(&function_object->links.eth_sq_list_head);
+		eth_sq =
+		    SA_CONTAINING_RECORD(list_entry, BE_ETHSQ_OBJECT,
+					 list);
+
+		status = be_eth_sq_destroy(eth_sq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/* ERX */
+	while (!sa_is_list_empty(&function_object->links.eth_rq_list_head)) {
+
+		list_entry =
+		    sa_list_head(&function_object->links.eth_rq_list_head);
+		eth_rq =
+		    SA_CONTAINING_RECORD(list_entry, BE_ETHRQ_OBJECT,
+					 list);
+
+		status = be_eth_rq_destroy(eth_rq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/* VLAN */
+	if (function_object->config.num_vlan > 0) {
+		status =
+		    be_rxf_vlan_config(function_object, FALSE, 0, NULL,
+				       NULL, NULL, NULL);
+		ASSERT(status == BE_SUCCESS);
+	}
+#endif
+
+	/*
+	 * MCC Queue -- Switches to mailbox mode.  May want to destroy
+	 * all but the MCC CQ before this call if polling CQ is much better
+	 * performance than polling mailbox register.
+	 */
+	if (function_object->links.mcc) {
+		status = be_mcc_ring_destroy(function_object->links.mcc);
+	}
+	/* CQs */
+	while (!sa_is_list_empty(&function_object->links.cq_list_head)) {
+		list_entry =
+		    sa_list_head(&function_object->links.cq_list_head);
+		cq = SA_CONTAINING_RECORD(list_entry, BE_CQ_OBJECT,
+					  cq_list);
+
+		status = be_cq_destroy(cq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/* EQs */
+	while (!sa_is_list_empty(&function_object->links.eq_list_head)) {
+		list_entry =
+		    sa_list_head(&function_object->links.eq_list_head);
+		eq = SA_CONTAINING_RECORD(list_entry, BE_EQ_OBJECT,
+					  eq_list);
+
+		status = be_eq_destroy(eq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/*
+	 * If interrupts are disabled, clear any CEV interrupt assertions that
+	 * fired after we stopped processing EQs.
+	 */
+	ctrl.dw = PCICFG1_READ(function_object, host_timer_int_ctrl);
+	if (!ctrl.hostintr) {
+		if (be_function_is_networking(function_object)) {
+			isr = CSR_READ(function_object, cev.isr1);
+		} else {
+			isr = CSR_READ(function_object, cev.isr0);
+		}
+	} else {
+		/* This should never happen... */
+		TRACE(DL_ERR,
+		      "Calling function_cleanup with interrupts enabled.");
+	}
+
+	/* Function object destroy */
+	status =
+	    be_function_object_destroy(function_object,
+				       function_object->parent_chip);
+	ASSERT(status == BE_SUCCESS);
+
+	return status;
+}
+
+/*!
+
+@brief
+    This routine adds a event queue object to a function object to allow
+    for correct tracking and reference counting.
+
+@param
+    function_object         - Function object to add the object to.
+
+@param
+    EqObject        - Event queue object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_eq(IN PBE_FUNCTION_OBJECT function_object,
+		    IN PBE_EQ_OBJECT eq_object)
+{
+	FUNCTION_ASSERT(function_object);
+	EQ_ASSERT(eq_object);
+
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.eq_list_head,
+			    &eq_object->eq_list);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes a event queue object from a function object and
+    drops the reference count for the given function object.
+
+@param
+    function_object         - Function object to remove the object from.
+
+@param
+    EqObject        - Event queue object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_eq(IN PBE_FUNCTION_OBJECT function_object,
+		       IN PBE_EQ_OBJECT eq_object)
+{
+	FUNCTION_ASSERT(function_object);
+	EQ_ASSERT(eq_object);
+
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&eq_object->eq_list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+
+}
+
+/*!
+
+@brief
+    This routine adds a completion queue object to a function object to allow
+    for correct tracking and reference counting.
+
+@param
+    function_object         - Function object to add the object to.
+
+@param
+    CqObject        - Completion queue object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_cq(IN PBE_FUNCTION_OBJECT function_object,
+		    IN PBE_CQ_OBJECT cq_object)
+{
+	FUNCTION_ASSERT(function_object);
+	CQ_ASSERT(cq_object);
+
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.cq_list_head,
+			    &cq_object->cq_list);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes a completion queue object from a function object and
+    drops the reference count for the given function object.
+
+@param
+    function_object         - Function object to remove the object from.
+
+@param
+    CqObject        - Completion queue object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_cq(IN PBE_FUNCTION_OBJECT function_object,
+		       IN PBE_CQ_OBJECT cq_object)
+{
+	FUNCTION_ASSERT(function_object);
+	CQ_ASSERT(cq_object);
+
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&cq_object->cq_list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine adds an Ethernet Send queue object to a function
+    object to allow for correct tracking and reference counting.
+
+@param
+    func_obj      - function object to add the object to.
+
+@param
+    eth_sq        - ethernet send queue object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_eth_sq(IN PBE_FUNCTION_OBJECT function_object,
+			IN PBE_ETHSQ_OBJECT eth_sq)
+{
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.eth_sq_list_head,
+			    &eth_sq->list);
+
+	_be_function_unlock(function_object);
+
+}
+
+/*!
+
+@brief
+    This routine removes an Ethernet Send Queue object from a function object
+    and drops the reference count for the given function object.
+
+@param
+    function_object         - Function object to remove the object from.
+
+@param
+    EthSq        - Ethernet Send Queue object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_eth_sq(IN PBE_FUNCTION_OBJECT function_object,
+			   IN PBE_ETHSQ_OBJECT eth_sq)
+{
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&eth_sq->list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine adds an ethernet receive queue object to a
+    function object to allow for correct tracking and reference counting.
+
+@param
+    function_object     - Function object to add the object to.
+
+@param
+    EthRq       - Ethernet Receive Queue object to add.
+
+@param
+    RssIndex    - Rss Index that this RQ will map to. Unless this RQ is for
+		a priviledged execution environment, the RssIndex must be
+		set to RSS_ID_INDEX_DQ.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_eth_rq(IN PBE_FUNCTION_OBJECT function_object,
+			IN PBE_ETHRQ_OBJECT eth_rq)
+{
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.eth_rq_list_head,
+			    &eth_rq->list);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes an Ethernet receive queue object from a function object
+    and drops the reference count for the given function object.
+
+@param
+    function_object     - Function object to remove the object from.
+
+@param
+    EthRq       - Ethernet receive queue object to remove.
+
+@param
+    RssIndex    - Rss Index for the EthRq to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_eth_rq(IN PBE_FUNCTION_OBJECT function_object,
+			   IN PBE_ETHRQ_OBJECT eth_rq)
+{
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&eth_rq->list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+
+}
+
+/*!
+
+@brief
+    This routine adds a Mcc Send queue object to a function object to allow
+    for correct tracking and reference counting.
+
+@param
+    function_object         - Function object to add the object to.
+
+@param
+    MccSq           - Mcc Send Queue object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_mcc(IN PBE_FUNCTION_OBJECT function_object,
+		     IN PBE_MCC_OBJECT mcc)
+{
+	FUNCTION_ASSERT(function_object);
+
+	ASSERT(function_object->links.mcc == NULL);
+	MCC_ASSERT(mcc);
+
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	function_object->links.mcc = mcc;
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes an MCC Send Queue object from a function object and
+    drops the reference count for the given function object.
+
+@param
+    function_object     - Function object to remove the object from.
+
+@param
+    MccSq      - Mcc Send Queue object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_mcc(IN PBE_FUNCTION_OBJECT function_object,
+			IN PBE_MCC_OBJECT mcc)
+{
+	FUNCTION_ASSERT(function_object);
+
+	MCC_ASSERT(function_object->links.mcc);
+
+	MCC_ASSERT(mcc);
+
+	SA_NOT_USED(mcc);
+
+	_be_function_lock(function_object);
+
+	function_object->links.mcc = NULL;
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine adds an iSCSI default PDU queue object to a function object to
+    allow for correct tracking and reference counting.
+
+@param
+    function_object             - Function object to add the object to.
+
+@param
+    DefaultPduObject    - Default PDU object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_default_pdu_queue(IN PBE_FUNCTION_OBJECT function_object,
+				   IN PBE_DEFAULT_PDU_QUEUE_OBJECT
+				   default_pdu_object)
+{
+	FUNCTION_ASSERT(function_object);
+	ASSERT(be_function_is_iscsi(function_object));
+
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.iscsi.defq_list_head,
+			    &default_pdu_object->func_list);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes an iSCSI default PDU Queue object from a function
+    object and drops the reference count for the given function object.
+
+@param
+    function_object         - Function object to remove the object from.
+
+@param
+    DefaultPduObject- iSCSI Default PDU Queue object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_default_pdu_queue(IN PBE_FUNCTION_OBJECT
+				      function_object,
+				      IN PBE_DEFAULT_PDU_QUEUE_OBJECT
+				      default_pdu_object)
+{
+	FUNCTION_ASSERT(function_object);
+	ASSERT(be_function_is_iscsi(function_object));
+
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&default_pdu_object->func_list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+}
+
+
+/*!
+
+@brief
+    This routine adds a event queue object to a function object to allow
+    for correct tracking and reference counting.
+
+@param
+    function_object         - Function object to add the object to.
+
+@param
+    EqObject        - Event queue object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_wrbq(IN PBE_FUNCTION_OBJECT function_object,
+		      IN PBE_ISCSI_WRB_QUEUE_OBJECT wrbq)
+{
+	FUNCTION_ASSERT(function_object);
+	ISCSI_WRBQ_ASSERT(wrbq);
+
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.iscsi.wrbq_list_head,
+			    &wrbq->wrbq_list);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes a event queue object from a function object and
+    drops the reference count for the given function object.
+
+@param
+    function_object         - Function object to remove the object from.
+
+@param
+    EqObject        - Event queue object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_wrbq(IN PBE_FUNCTION_OBJECT function_object,
+			 IN PBE_ISCSI_WRB_QUEUE_OBJECT wrbq)
+{
+	FUNCTION_ASSERT(function_object);
+	ISCSI_WRBQ_ASSERT(wrbq);
+
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&wrbq->wrbq_list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+
+}
+
+PVOID
+be_function_prepare_embedded_ioctl(IN PBE_FUNCTION_OBJECT function_object,
+				   IN PMCC_WRB wrb,
+				   IN u32 payload_length,
+				   IN u32 request_length,
+				   IN u32 response_length,
+				   IN u32 opcode, IN u32 subsystem)
+{
+	PIOCTL_REQUEST_HEADER header = NULL;
+
+	ASSERT(wrb);
+	FUNCTION_ASSERT(function_object);
+
+	ASSERT(payload_length <= SA_SIZEOF_FIELD(MCC_WRB, payload));
+
+	wrb->embedded = 1;
+	wrb->payload_length =
+	    MIN(payload_length, SA_SIZEOF_FIELD(MCC_WRB, payload));
+
+	header = (PIOCTL_REQUEST_HEADER) &wrb->payload;
+
+	header->timeout = 0;
+	header->domain = be_function_get_pd_number(function_object);
+	header->request_length = MAX(request_length, response_length);
+	header->opcode = opcode;
+	header->subsystem = subsystem;
+
+	return header;
+}
+
+PVOID
+be_function_prepare_nonembedded_ioctl(IN PBE_FUNCTION_OBJECT
+				      function_object, IN PMCC_WRB wrb,
+				      IN PVOID ioctl_va, IN u64 ioctl_pa,
+				      IN u32 payload_length,
+				      IN u32 request_length,
+				      IN u32 response_length,
+				      IN u32 opcode, IN u32 subsystem)
+{
+	PIOCTL_REQUEST_HEADER header = NULL;
+
+	ASSERT(wrb);
+	ASSERT(ioctl_va);
+	FUNCTION_ASSERT(function_object);
+
+	header = (PIOCTL_REQUEST_HEADER) ioctl_va;
+
+	wrb->embedded = 0;
+	wrb->payload_length = payload_length;
+
+	/*
+	 * Assume one fragment. The caller may override the SGL by
+	 * rewriting the 0th length and adding more entries.  They
+	 * will also need to update the sge_count.
+	 */
+	wrb->sge_count = 1;
+	wrb->payload.sgl[0].length = payload_length;
+	wrb->payload.sgl[0].pa_lo = sa_lo(ioctl_pa);
+	wrb->payload.sgl[0].pa_hi = sa_hi(ioctl_pa);
+
+	header->timeout = 0;
+	header->domain = be_function_get_pd_number(function_object);
+	header->request_length = MAX(request_length, response_length);
+	header->opcode = opcode;
+	header->subsystem = subsystem;
+
+	return header;
+}
+
+PMCC_WRB be_function_peek_mcc_wrb(IN PBE_FUNCTION_OBJECT function_object)
+{
+	PMCC_WRB wrb = NULL;
+	FUNCTION_ASSERT(function_object);
+
+	if (function_object->links.mcc) {
+
+		wrb = _be_mpu_peek_ring_wrb(function_object->links.mcc, FALSE);
+
+	} else {
+		wrb = (PMCC_WRB) &function_object->mailbox.va->wrb;
+	}
+
+	if (wrb) {
+		sa_memset(wrb, 0, sizeof(MCC_WRB));
+	}
+
+	return wrb;
+}
+
+/*!
+@brief
+    This routine posts an MCC WRB command to a function object's MCC send
+    queue (if avaiable) or posts the WRB to the MCC WRB mail box if a send
+    queue is not setup.
+@param
+    function_object     - function object to add the object to.
+@param
+    wrb                 - wrb to post.  This may be a va from the
+			  be_function_peek_mcc_wrb function, so the
+			  driver need not declare additional memory.
+@param
+    callback  - address of a callback routine to invoke once the WRB
+			is completed.
+@param
+    callback_context - opaque context to be passed during the call to
+			the callback.
+@return
+    BE_SUCCESS if successfull, otherwise a useful error code is returned.
+
+@note
+    IRQL < DISPATCH_LEVEL
+*/
+BESTATUS
+be_function_post_mcc_wrb(IN PBE_FUNCTION_OBJECT function_object,
+			 IN PMCC_WRB wrb,
+			 IN MCC_WRB_CQE_CALLBACK callback,
+			 IN PVOID callback_context,
+			 IN PVOID optional_ioctl_va)
+{
+	BE_MCC_WRB_RESPONSE_COPY response_copy = { 0 };
+	return be_function_post_mcc_wrb_complete(function_object, wrb, NULL,
+				 callback, callback_context, NULL, NULL,
+					 optional_ioctl_va, response_copy);
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_queue_context(IN PBE_FUNCTION_OBJECT
+					    function_object,
+					    IN PMCC_WRB wrb,
+					    IN PBE_GENERIC_QUEUE_CONTEXT
+					    queue_context,
+					    IN MCC_WRB_CQE_CALLBACK
+					    callback,
+					    IN PVOID callback_context,
+					    IN PVOID optional_ioctl_va)
+{
+	BE_MCC_WRB_RESPONSE_COPY response_copy = { 0 };
+	return be_function_post_mcc_wrb_complete(function_object,
+			wrb, queue_context, callback, callback_context, NULL,
+			 NULL, optional_ioctl_va, response_copy);
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_copy(IN PBE_FUNCTION_OBJECT function_object,
+				   IN PMCC_WRB wrb,
+				   IN PBE_GENERIC_QUEUE_CONTEXT
+				   queue_context,
+				   IN MCC_WRB_CQE_CALLBACK callback,
+				   IN PVOID callback_context,
+				   IN PVOID optional_ioctl_va,
+				   IN BE_MCC_WRB_RESPONSE_COPY
+				   response_copy)
+{
+	return be_function_post_mcc_wrb_complete(function_object,
+			wrb, queue_context, callback, callback_context, NULL,
+				 NULL, optional_ioctl_va, response_copy);
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_internal_callback(
+		IN PBE_FUNCTION_OBJECT function_object,
+		IN PMCC_WRB wrb,
+		IN PBE_GENERIC_QUEUE_CONTEXT queue_context,
+		IN MCC_WRB_CQE_CALLBACK callback,
+		IN PVOID callback_context,
+		IN MCC_WRB_CQE_CALLBACK internal_callback,
+		IN PVOID internal_callback_context,
+		IN PVOID optional_ioctl_va)
+{
+	BE_MCC_WRB_RESPONSE_COPY response_copy = { 0 };
+	return be_function_post_mcc_wrb_complete(function_object, wrb,
+			queue_context, callback, callback_context,
+			internal_callback, internal_callback_context,
+			optional_ioctl_va, response_copy);
+}
+
+#if defined(SA_DEBUG)
+void be_function_debug_print_wrb(PBE_FUNCTION_OBJECT function_object,
+				 PMCC_WRB wrb,
+				 PVOID optional_ioctl_va,
+				 PBE_MCC_WRB_CONTEXT wrb_context)
+{
+
+	PIOCTL_REQUEST_HEADER header = NULL;
+	if (wrb->embedded) {
+		header = (PIOCTL_REQUEST_HEADER) &wrb->payload;
+	} else {
+		header = (PIOCTL_REQUEST_HEADER) optional_ioctl_va;
+	}
+
+	/* Save the completed count before posting for a debug assert. */
+	wrb_context->consumed_count = function_object->stats.consumed_wrbs;
+
+	if (header) {
+		wrb_context->opcode = header->opcode;
+		wrb_context->subsystem = header->subsystem;
+
+	} else {
+		wrb_context->opcode = 0;
+		wrb_context->subsystem = 0;
+		TRACE(DL_IOCTL,
+			"Post IOCTL. emul:0 embed:0 Unknown sub/op. ctx:%p",
+				wrb_context);
+	}
+}
+#else
+#define be_function_debug_print_wrb(a_, b_, c_, d_)
+#endif
+
+BESTATUS
+be_function_post_mcc_wrb_complete(IN PBE_FUNCTION_OBJECT function_object,
+				  IN PMCC_WRB wrb,
+				  IN PBE_GENERIC_QUEUE_CONTEXT
+				  queue_context,
+				  IN MCC_WRB_CQE_CALLBACK callback,
+				  IN PVOID callback_context,
+				  IN MCC_WRB_CQE_CALLBACK
+				  internal_callback,
+				  IN PVOID internal_callback_context,
+				  IN PVOID optional_ioctl_va,
+				  IN BE_MCC_WRB_RESPONSE_COPY
+				  response_copy)
+{
+	BESTATUS status;
+	PBE_MCC_WRB_CONTEXT wrb_context = NULL;
+	FUNCTION_ASSERT(function_object);
+
+	if (queue_context) {
+
+		/* Initialize context.         */
+		queue_context->context.internal_callback =
+		    internal_callback;
+		queue_context->context.internal_callback_context =
+		    internal_callback_context;
+		queue_context->context.callback = callback;
+		queue_context->context.callback_context = callback_context;
+		queue_context->context.copy = response_copy;
+		queue_context->context.optional_ioctl_va =
+		    optional_ioctl_va;
+
+		/* Queue this request */
+		status =
+		    be_function_queue_mcc_wrb(function_object,
+					      queue_context);
+
+		goto Error;
+	}
+	/*
+	 * Allocate a WRB context struct to hold the callback pointers,
+	 * status, etc.  This is required if commands complete out of order.
+	 */
+	wrb_context = _be_mcc_allocate_wrb_context(function_object);
+	if (!wrb_context) {
+		TRACE(DL_WARN, "Failed to allocate MCC WRB context.");
+		status = BE_STATUS_SYSTEM_RESOURCES;
+		goto Error;
+	}
+	/* Initialize context. */
+	SA_ZERO_MEM(wrb_context);
+	wrb_context->internal_callback = internal_callback;
+	wrb_context->internal_callback_context = internal_callback_context;
+	wrb_context->callback = callback;
+	wrb_context->callback_context = callback_context;
+	wrb_context->copy = response_copy;
+	wrb_context->wrb = wrb;
+
+	/*
+	 * Copy the context pointer into the WRB opaque tag field.
+	 * Verify assumption of 64-bit tag with a compile time assert.
+	 */
+	SA_C_ASSERT(sizeof(wrb->tag) >= sizeof(u64));
+	*((u64 *) wrb->tag) = SA_PTR_TO_U64(wrb_context);
+
+	/* Print info about this IOCTL for debug builds. */
+	be_function_debug_print_wrb(function_object, wrb,
+				    optional_ioctl_va, wrb_context);
+
+	/*
+	 * issue the WRB to the MPU as appropriate
+	 */
+	if (function_object->links.mcc) {
+		/*
+		 * we're in WRB mode, pass to the mcc layer
+		 */
+		status =
+		    _be_mpu_post_wrb_ring(function_object->links.
+					  mcc, wrb, wrb_context);
+	} else {
+		/*
+		 * we're in mailbox mode
+		 */
+		status = _be_mpu_post_wrb_mailbox(function_object, wrb,
+					     wrb_context);
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
+void _be_function_lock(PBE_FUNCTION_OBJECT fo)
+{
+	be_lock_acquire(&fo->lock);
+}
+
+void _be_function_unlock(PBE_FUNCTION_OBJECT fo)
+{
+	be_lock_release(&fo->lock);
+}
+
+u32 be_function_get_function_number(PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	return function_object->pci_function_number;
+}
+
+u32 be_function_get_function_type(PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	return function_object->type;
+}
+
+u32 be_function_get_pd_number(PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+
+	/* only PD0 supported in Linux drivers */
+	return 0;
+}
+
+boolean be_function_is_vm(PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	return be_function_get_pd_number(function_object) > 0;
+}
+
+/*!
+
+@brief
+    References the given object. The object is guaranteed to remain active
+    until the reference count drops to zero.
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
+u32 _be_function_reference(PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	return sa_atomic_increment(&function_object->ref_count);
+}
+
+/*!
+@brief
+    Dereferences the given object. The object is guaranteed to remain
+    active until the reference count drops to zero.
+@param
+@return
+    returns the current reference count on the object
+@note
+    IRQL: any
+*/
+u32 _be_function_dereference(PBE_FUNCTION_OBJECT function_object)
+{
+	FUNCTION_ASSERT(function_object);
+	return sa_atomic_decrement(&function_object->ref_count);
+}
+
+BESTATUS
+be_function_ring_destroy_async(PBE_FUNCTION_OBJECT function_object,
+			       u32 id,
+			       u32 ring_type,
+			       MCC_WRB_CQE_CALLBACK callback,
+			       PVOID callback_context,
+			       MCC_WRB_CQE_CALLBACK internal_callback,
+			       PVOID internal_callback_context)
+{
+
+	IOCTL_COMMON_RING_DESTROY *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+
+	FUNCTION_ASSERT(function_object);
+
+	be_lock_wrb_post(function_object);
+
+	TRACE(DL_INFO, "Destroy ring id:%d type:%d", id, ring_type);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		ASSERT(wrb);
+		TRACE(DL_ERR, "No free MCC WRBs in destroy ring.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_RING_DESTROY);
+
+	ioctl->params.request.id = id;
+	ioctl->params.request.ring_type = ring_type;
+
+	/* Post the Ioctl */
+	status =
+	    be_function_post_mcc_wrb_with_internal_callback
+	    (function_object, wrb, NULL, callback, callback_context,
+	     internal_callback, internal_callback_context, ioctl);
+	if (status != BE_SUCCESS && status != BE_PENDING) {
+		TRACE(DL_ERR,
+		      "Ring destroy ioctl failed. id:%d ring_type:%d", id,
+		      ring_type);
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(function_object);
+	return status;
+}
+
+BESTATUS
+be_function_ring_destroy(PBE_FUNCTION_OBJECT function_object, u32 id,
+			 u32 ring_type)
+{
+	return be_function_ring_destroy_async(function_object, id,
+					      ring_type, NULL, NULL, NULL,
+					      NULL);
+}
+
+void be_sgl_to_pa_list(PSA_SGL sgl, PHYS_ADDR *pa_list, u32 max_num)
+{
+	u32 offset = sa_sgl_get_offset(sgl);
+	u32 num_pages = sa_sgl_get_page_count(sgl);
+	u32 i = 0;
+	u64 pa;
+
+	ASSERT(pa_list);
+	/* MUST BE page aligned if >1 page in ring */
+	ASSERT((offset == 0) || (num_pages == 1));
+
+	for (i = 0; i < MIN(num_pages, max_num); i++) {
+		pa = sa_sgl_get_page(sgl, i) + offset;
+		offset = 0;	/* offset applies to first page only */
+
+		ASSERT(pa);
+
+		pa_list[i].lo = sa_lo(pa);
+		pa_list[i].hi = sa_hi(pa);
+	}
+}
+
+/*!
+
+@brief
+    This routine adds an iSCSI connectoin object to a function object to allow
+    for correct tracking and reference counting.
+
+@param
+    function_object             - Function object to add the object to.
+
+@param
+    ConnectionObject    - iSCSI Connection object to add.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_iscsi_connection(IN PBE_FUNCTION_OBJECT function_object,
+				  IN PBE_ISCSI_CONNECTION_OBJECT
+				  connection_object)
+{
+	FUNCTION_ASSERT(function_object);
+
+	ASSERT(be_function_is_iscsi(function_object) == TRUE);
+
+	ISCSI_CXN_ASSERT(connection_object);
+
+	_be_function_lock(function_object);
+
+	sa_atomic_increment(&function_object->ref_count);
+	sa_insert_tail_list(&function_object->links.cxn_list_head,
+			    &connection_object->connection_list);
+
+	_be_function_unlock(function_object);
+}
+
+/*!
+
+@brief
+    This routine removes an iSCSI Connection object from a function object and
+    drops the reference count for the given function object.
+
+@param
+    function_object         - Function object to remove the object from.
+
+@param
+    ConnectionObject - iSCSI connection object to remove.
+
+@return
+
+@note
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_iscsi_connection(IN PBE_FUNCTION_OBJECT
+				     function_object,
+				     IN PBE_ISCSI_CONNECTION_OBJECT
+				     connection_object)
+{
+	FUNCTION_ASSERT(function_object);
+
+	ASSERT(be_function_is_iscsi(function_object) == TRUE);
+
+	ISCSI_CXN_ASSERT(connection_object);
+
+	_be_function_lock(function_object);
+
+	sa_remove_entry_list(&connection_object->connection_list);
+	sa_atomic_decrement(&function_object->ref_count);
+
+	_be_function_unlock(function_object);
+
+}
+
+void be_function_lock_mcc(IN PBE_FUNCTION_OBJECT function_object)
+{
+	be_lock_wrb_post(function_object);
+}
+
+void be_function_unlock_mcc(IN PBE_FUNCTION_OBJECT function_object)
+{
+	be_unlock_wrb_post(function_object);
+}
+
+/*
+ *---------------------------------------------------------------------------
+ * Function: be_function_enable_interrupts
+ *   Enables interrupts for the given PCI function.
+ * function_object    -
+ * return return_type - void
+ *----------------------------------------------------------------------------
+ */
+void be_function_enable_interrupts(IN PBE_FUNCTION_OBJECT function_object)
+{
+	BE_EQ_OBJECT *eq = NULL;
+	CQ_DB cq_db;
+	PCICFG_HOST_TIMER_INT_CTRL_CSR ctrl;
+	u32 isr;
+
+	FUNCTION_ASSERT(function_object);
+
+	ctrl.dw = PCICFG1_READ(function_object, host_timer_int_ctrl);
+	if (!ctrl.hostintr) {
+
+		/*
+		 * Read-clear the ISR to make sure that any EQs that
+		 * fired after the host interrupt was masked are no longer
+		 * asserted.  If the EQs still have a producer-consumer
+		 * mismatch, they will re-assert after they are armed.  This
+		 * handles the situation where software polls CQs and EQs
+		 * with interrupts disabled.
+		 */
+		if (be_function_is_networking(function_object)) {
+			isr = CSR_READ(function_object, cev.isr1);
+		} else {
+			isr = CSR_READ(function_object, cev.isr0);
+		}
+
+		/*
+		 * Read-Modify-Write the control register
+		 *
+		 */
+		ctrl.hostintr = 1;
+		PCICFG1_WRITE_CONST(function_object, host_timer_int_ctrl,
+				    ctrl.dw);
+	}
+
+	cq_db.dw = 0;		/* clear entire doorbell */
+	cq_db.event = 1;
+	cq_db.rearm = 1;
+	cq_db.num_popped = 0;
+
+	/* Lock the function object while walking the EQ list. */
+	_be_function_lock(function_object);
+
+	/* Rearm each EQ. */
+	SA_FOR_EACH_LIST_ENTRY(eq, function_object->links.eq_list_head,
+			       BE_EQ_OBJECT, eq_list) {
+
+		EQ_ASSERT(eq);
+
+		cq_db.qid = eq->eq_id;
+
+		PD_WRITE(function_object, cq_db, cq_db);
+	}
+
+	_be_function_unlock(function_object);
+}
+
+/*
+ *----------------------------------------------------------------------------
+ * Function: be_function_disable_interrupts
+ *   Disables interrupts for the given PCI function.
+ * function_object    -
+ * return return_type - void
+ *----------------------------------------------------------------------------
+ */
+void be_function_disable_interrupts(IN PBE_FUNCTION_OBJECT function_object)
+{
+	PCICFG_HOST_TIMER_INT_CTRL_CSR ctrl;
+
+	FUNCTION_ASSERT(function_object);
+
+	/*
+	 * Read-Modify-Write of the control register in PCI config space.
+	 */
+	ctrl.dw = PCICFG1_READ(function_object, host_timer_int_ctrl);
+	if (ctrl.hostintr) {
+		ctrl.hostintr = 0;
+		PCICFG1_WRITE_CONST(function_object, host_timer_int_ctrl,
+				    ctrl.dw);
+	}
+}
+
+/*
+ *----------------------------------------------------------------------------
+ * Function: be_function_nop
+ *   Issues a NOP command to the MCC ring. The command is completed with
+ *   a successful status. This can be used to pend operations until a
+ *   short time in the future, since the callback function will be
+ *   invoked upon command completion. The returned status
+ *   will be BE_PENDING if the command was issued successfully.
+ * function_object    -
+ * callback           - Callback function invoked when the NOP completes.
+ * callback_context   - Passed to the callback function.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING
+ *			(postive value) if the IOCTL completion is
+ *			pending. Negative error code on failure.
+ *-----------------------------------------------------------------------
+ */
+BESTATUS
+be_function_nop(IN PBE_FUNCTION_OBJECT function_object,
+		IN MCC_WRB_CQE_CALLBACK callback,
+		IN PVOID callback_context,
+		IN PBE_NOP_QUEUE_CONTEXT queue_context)
+{
+	BESTATUS status = BE_SUCCESS;
+	MCC_WRB *wrb = NULL;
+	IOCTL_COMMON_NOP *ioctl = NULL;
+	PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+	FUNCTION_ASSERT(function_object);
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (MCC_WRB *) &queue_context->wrb_header;
+			generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+					queue_context;	/* Indicate to queue */
+			generic_context->context.bytes =
+			    sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto Error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_NOP);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_queue_context(function_object,
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
+}
+
+/*-----------------------------------------------------------------------------
+ * Function: be_function_get_fw_version
+ *   Retrieves the firmware version on the adpater. If the callback is
+ *   NULL this call executes synchronously. If the callback is not NULL,
+ *   the returned status will be BE_PENDING if the command was issued
+ *   successfully.
+ * function_object    -
+ * fw_version         - Pointer to response buffer if callback is NULL.
+ * callback           - Callback function invoked when the IOCTL completes.
+ * callback_context   - Passed to the callback function.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_get_fw_version(IN PBE_FUNCTION_OBJECT function_object,
+			   OUT IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD
+			   * fw_version, IN MCC_WRB_CQE_CALLBACK callback,
+			   IN PVOID callback_context)
+{
+	BESTATUS status = BE_SUCCESS;
+	MCC_WRB *wrb = NULL;
+	IOCTL_COMMON_GET_FW_VERSION *ioctl = NULL;
+
+	FUNCTION_ASSERT(function_object);
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+
+	if (!callback && !fw_version) {
+		TRACE(DL_ERR, "callback and response buffer NULL!");
+		status = BE_NOT_OK;
+		goto Error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_GET_FW_VERSION);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(function_object, wrb, NULL,
+			callback, callback_context,
+			ioctl,
+			BE_CREATE_MCC_RESPONSE_COPY(IOCTL_COMMON_GET_FW_VERSION,
+					     params.response, fw_version));
+
+Error:
+	be_unlock_wrb_post(function_object);
+
+	return status;
+}
+
+BESTATUS
+be_function_queue_mcc_wrb(PBE_FUNCTION_OBJECT function_object,
+			  PBE_GENERIC_QUEUE_CONTEXT queue_context)
+{
+	BESTATUS status;
+
+	FUNCTION_ASSERT(function_object);
+	ASSERT(queue_context);
+
+	/*
+	 * issue the WRB to the MPU as appropriate
+	 */
+	if (function_object->links.mcc) {
+
+		/* We're in ring mode.  Queue this item. */
+		function_object->links.mcc->backlog_length++;
+		sa_insert_tail_list(&function_object->links.mcc->backlog,
+				    &queue_context->context.list);
+
+		function_object->stats.queued_wrbs++;
+		function_object->stats.queue_length =
+		    function_object->links.mcc->backlog_length;
+		function_object->stats.max_queue_length =
+		    MAX(function_object->stats.queue_length,
+			function_object->stats.max_queue_length);
+
+		status = BE_PENDING;
+
+	} else {
+
+		status = BE_NOT_OK;
+
+	}
+
+	return status;
+}
+
+/*
+ *-------------------------------------------------------------------------
+ * Function: be_function_manage_FAT_log
+ *   This routine can be used to manage the BladeEngine Fault Analysis
+ *   Tool (FAT) log.  This includes querying the FAT log size, retrieving
+ *   the FAT log, and clearing the FAT log. The log data can be anaylzed
+ *   by BladeEngine support tools to diagnose faults.
+ *   Only host domains (domain 0) may issue this request.
+ * function_object   -
+ * sgl               - The SGL representing the FAT log buffer landing space.
+ * 			The SGL should be page aligned. It does not require
+ * 			a virtual address.
+ * num_pages         - The number of pages in the SGL. A value of zero (0)
+ * 			implies no FAT log data transfer will take place.
+ * 			The num_pages is limited to 27 pages.
+ * page_offset       - The page_offset specifies the starting page offset
+ * 		       when retrieving the FAT log. For example, a value
+ * 		       of 0 requests data starting at byte offset 0 of the
+ * 		       FAT log. Likewise, a value of 5 requests data
+ * 		       starting at byte offset 20480 of the FAT log.
+ * 		       A caller may choose to issue multiple queries
+ * 		       when the FAT log buffer size is larger
+ *                     than the number of pages specified.
+ * clear_log         - Set to clear the log.
+ * log_size          - The size of the BladeEngine FAT log in bytes.
+ * bytes_transferred - The number of FAT log data bytes transferred.
+ * return status     - BE_SUCCESS (0) on success. Negative error code on failure
+ *----------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_manage_FAT_log(IN PBE_FUNCTION_OBJECT function_object,
+			   IN PSA_SGL sgl,
+			   IN u32 num_pages,
+			   IN u32 page_offset,
+			   IN boolean clear_log,
+			   OUT u32 *log_size, OUT u32 *bytes_transferred)
+{
+	IOCTL_COMMON_GET_FAT *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_GET_FAT);
+
+	/* Set parameters */
+	ioctl->params.request.clear_log = clear_log;
+	ioctl->params.request.page_offset = page_offset;
+	ioctl->params.request.num_pages = num_pages;
+
+	/* Create a page list for the IOCTL. */
+	ASSERT(sa_sgl_get_page_count(sgl) >=
+	       ioctl->params.request.num_pages);
+	be_sgl_to_pa_list(sgl, ioctl->params.request.buffer_addr,
+			  SA_NUMBER_OF(ioctl->params.request.buffer_addr));
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb(function_object, wrb, NULL,
+					  NULL, ioctl);
+
+	if (status != 0) {
+		TRACE(DL_ERR, "manage FAT log ioctl failed.");
+		goto error;
+	}
+
+	if (NULL != log_size) {
+		*log_size = ioctl->params.response.log_size;
+	}
+
+	if (NULL != bytes_transferred) {
+		*bytes_transferred =
+		    ioctl->params.response.bytes_transferred;
+	}
+
+      error:
+	be_unlock_wrb_post(function_object);
+
+	return status;
+}
+
+/*
+ *----------------------------------------------------------------------------
+ * Function: be_function_query_firmware_config
+ *   Queries the firmware configuration currently loaded. This
+ *   configuration includes information regarding the EP processor
+ *   configuration for various Upper Layer Protocols.
+ * function_object -
+ * config          - The configuration parameters currently loaded by firmware.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *--------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_query_firmware_config(IN PBE_FUNCTION_OBJECT function_object,
+				  OUT BE_FIRMWARE_CONFIG *config)
+{
+	FUNCTION_ASSERT(function_object);
+	ASSERT(config);
+
+	/* Copy the cached version. */
+	sa_memcpy(config, &function_object->fw_config, sizeof(*config));
+
+	return BE_SUCCESS;
+}
+
+BESTATUS
+be_function_internal_query_firmware_config(IN PBE_FUNCTION_OBJECT
+					   function_object,
+					   OUT BE_FIRMWARE_CONFIG *config)
+{
+	IOCTL_COMMON_FIRMWARE_CONFIG *ioctl = NULL;
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl =
+	    BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_FIRMWARE_CONFIG);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(function_object, wrb,
+			NULL, NULL, NULL, ioctl,
+			BE_CREATE_MCC_RESPONSE_COPY(
+				IOCTL_COMMON_FIRMWARE_CONFIG,
+				     params.response, config));
+
+error:
+	be_unlock_wrb_post(function_object);
+
+	return status;
+}
+
+/*
+ *---------------------------------------------------------------------------
+ * Function: be_function_config_red
+ *   This function configures global and/or ULP specific Random Early Drop (RED
+ *   functionality.
+ * function_object    -
+ * parameters         - The RED parameters. Only parameters for the
+ * 		        chutes owned by the current PCI function are applied.
+ * callback           - Optional callback function.
+ * callback_context   - Optional context for callback function.
+ * queue_context      - Optional context for queueing the IOCTL.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_config_red(IN PBE_FUNCTION_OBJECT function_object,
+		       IN PBE_RED_PARAMETERS parameters,
+		       IN MCC_WRB_CQE_CALLBACK callback,
+		       IN PVOID callback_context,
+		       IN PBE_CONFIG_RED_QUEUE_CONTEXT queue_context)
+{
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+	PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+	IOCTL_COMMON_RED_CONFIG *ioctl = NULL;
+	u32 i;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (MCC_WRB *) &queue_context->wrb_header;
+			generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+							queue_context;
+			generic_context->context.bytes = sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto error;
+		}
+	}
+	/* Prepares an embedded ioctl, including request/response sizes. */
+	ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+					       COMMON_RED_CONFIG);
+
+	for (i = 0; i < SA_NUMBER_OF(parameters->chute); i++) {
+		sa_memcpy(&ioctl->params.request.chute[i],
+			  &parameters->chute[i],
+			  sizeof(parameters->chute[0]));
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
+      error:
+	be_unlock_wrb_post(function_object);
+
+	return status;
+}
+
+/*
+ *----------------------------------------------------------------------------
+ * Function: be_function_config_port_equalization
+ *   This function configures or returns the XAUI port equalization
+ *   parameters of BladeEngine.
+ * function_object    -
+ * parameters         - XAUI port equalization parameters.
+ * write              - Set (1) to write the parameters, otherwise
+ * 			clear (0) to read the parameters.
+ * callback           - Optional callback function.
+ * callback_context   - Optional context for callback function.
+ * queue_context      - Optional context for queueing the IOCTL.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_config_port_equalization(IN PBE_FUNCTION_OBJECT
+				     function_object,
+				     IN OUT
+				     PIOCTL_COMMON_PORT_EQUALIZATION_PARAMS
+				     parameters, IN boolean write,
+				     IN MCC_WRB_CQE_CALLBACK callback,
+				     IN PVOID callback_context,
+				     IN
+				     PBE_CONFIG_PORT_EQUALIXATION_QUEUE_CONTEXT
+				     queue_context)
+{
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+	PBE_GENERIC_QUEUE_CONTEXT generic_context = NULL;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		if (queue_context && callback) {
+			wrb = (MCC_WRB *) &queue_context->wrb_header;
+			generic_context = (PBE_GENERIC_QUEUE_CONTEXT)
+					queue_context;
+			generic_context->context.bytes =
+			    sizeof(*queue_context);
+		} else {
+			status = BE_STATUS_NO_MCC_WRB;
+			goto error;
+		}
+	}
+
+	if (write) {
+		IOCTL_COMMON_SET_PORT_EQUALIZATION *ioctl;
+
+		/*
+		 * Prepare an embedded ioctl, including request/response
+		 * sizes.
+		 */
+		ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object, wrb,
+				       COMMON_SET_PORT_EQUALIZATION);
+
+		sa_memcpy(&ioctl->params.request,
+			  parameters, sizeof(*parameters));
+
+		/* Post the Ioctl */
+		status = be_function_post_mcc_wrb_with_queue_context(
+				function_object,
+				wrb, generic_context, callback,
+				callback_context, ioctl);
+	} else {
+		IOCTL_COMMON_GET_PORT_EQUALIZATION *ioctl;
+
+		/*
+		 * Prepare an embedded ioctl, including
+		 * request/response sizes.
+		 */
+		ioctl = BE_FUNCTION_PREPARE_EMBEDDED_IOCTL(function_object,
+				       wrb, COMMON_GET_PORT_EQUALIZATION);
+
+		/* This IOCTL response is copied into the parameters pointer */
+		status = be_function_post_mcc_wrb_with_copy(function_object,
+				wrb, generic_context, callback,
+				callback_context, ioctl,
+				BE_CREATE_MCC_RESPONSE_COPY(
+					IOCTL_COMMON_GET_PORT_EQUALIZATION,
+						params.
+						response,
+						parameters));
+	}
+
+error:
+	be_unlock_wrb_post(function_object);
+
+	return status;
+}
+
+/*
+ *------------------------------------------------------------------------
+ * Function: be_function_passthru_ioctl
+ *   This routine issues an embedded IOCTL in pass-through mode.
+ * function_object  -
+ * payload          - The embedded payload for the MCC_WRB structure.
+ * 		      The input buffer is overwritten with response data.
+ * callback         - Callback function invoked when the IOCTL completes.
+ * callback_context - Callback context passed to the callback function.
+ * return status    - BE_SUCCESS (0) on success. Negative error code on failure.
+ *----------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_passthru_ioctl(IN PBE_FUNCTION_OBJECT function_object,
+			   IN OUT MCC_WRB_PAYLOAD *payload,
+			   IN MCC_WRB_CQE_CALLBACK callback,
+			   IN PVOID callback_context)
+{
+	MCC_WRB *wrb = NULL;
+	BESTATUS status = 0;
+	PVOID ioctl = NULL;
+	PIOCTL_REQUEST_HEADER ioctl_header =
+	    (PIOCTL_REQUEST_HEADER) payload;
+
+	be_lock_wrb_post(function_object);
+
+	wrb = be_function_peek_mcc_wrb(function_object);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto error;
+	}
+	/* Prepares an embedded ioctl */
+	ioctl = be_function_prepare_embedded_ioctl(function_object,
+						   wrb,
+						   sizeof(MCC_WRB_PAYLOAD),
+						   ioctl_header->
+						   request_length,
+						   ioctl_header->
+						   request_length,
+						   ioctl_header->opcode,
+						   ioctl_header->
+						   subsystem);
+
+	/* Copy in the user's IOCTL payload */
+	sa_memcpy((void *)&wrb->payload,
+		  (void *)payload, sizeof(MCC_WRB_PAYLOAD));
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(function_object,
+			wrb, NULL, callback, callback_context,
+			ioctl, be_create_mcc_response_copy(0,
+					sizeof (MCC_WRB_PAYLOAD), payload));
+
+error:
+	be_unlock_wrb_post(function_object);
+
+	return status;
+}

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

