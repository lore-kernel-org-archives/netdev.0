From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 6/12] benet: beclib functions
Date: Thu, 12 Jun 2008 03:43:12 -0700
Message-ID: <20080612104312.54c39928@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:33543 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbYFLKnR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:43:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/chipobj_ll.c |  106 +++
 drivers/message/beclib/funcobj_ll.c | 1236 +++++++++++++++++++++++++++++++++++
 drivers/message/beclib/main_ll.c    |   37 +
 3 files changed, 1379 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/chipobj_ll.c
 create mode 100644 drivers/message/beclib/funcobj_ll.c
 create mode 100644 drivers/message/beclib/main_ll.c

diff --git a/drivers/message/beclib/chipobj_ll.c b/drivers/message/beclib/chipobj_ll.c
new file mode 100644
index 0000000..f2b3e51
--- /dev/null
+++ b/drivers/message/beclib/chipobj_ll.c
@@ -0,0 +1,106 @@
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
+BESTATUS be_chip_create(struct be_chip_object *chip)
+{
+	BESTATUS status = BE_SUCCESS;
+
+	ASSERT(chip);
+	memset(chip, 0, sizeof(*chip));
+
+	TRACE(DL_INFO, "Create chip object. object:0x%p", chip);
+
+	atomic_set(&chip->ref_count, 0);
+
+	INIT_LIST_HEAD(&chip->function_list_head);
+
+	spin_lock_init(&chip->lock.lock);
+
+	return status;
+}
+
+void be_chip_destroy(struct be_chip_object *chip)
+{
+	ASSERT(chip->ref_count == 0);
+
+	memset(chip, 0, sizeof(*chip));
+	TRACE(DL_INFO, "destroying chip %p", chip);
+}
+
+BESTATUS
+be_chip_insert_function_object(struct be_chip_object *chip_object,
+			       struct be_function_object *pfob)
+{
+	TRACE(DL_INFO, "Insert function into chip object.");
+
+	ASSERT(pfob->parent_chip == NULL ||
+	       pfob->parent_chip == chip_object);
+	pfob->parent_chip = chip_object;
+
+	be_chip_lock(chip_object);
+
+	atomic_inc(&chip_object->ref_count);
+	list_add_tail(&pfob->function_list, &chip_object->function_list_head);
+
+	be_chip_unlock(chip_object);
+
+	return BE_SUCCESS;
+}
+
+void
+be_chip_remove_function_object(struct be_chip_object *chip_object,
+			       struct be_function_object *pfob)
+{
+	pfob->parent_chip = NULL;
+
+	be_chip_lock(chip_object);
+
+	ASSERT(atomic_read(&chip_object->ref_count) > 0);
+	ASSERT(!list_empty(&chip_object->function_list_head));
+
+	atomic_dec(&chip_object->ref_count);
+	list_del(&pfob->function_list);
+
+	be_chip_unlock(chip_object);
+}
+
+/*
+    This routine serializes access to resources maintained
+    through a chip object.
+
+    ChipObject      - The chip object to acquire the lock for.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void be_chip_lock(struct be_chip_object *chip_object)
+{
+	spin_lock_irqsave(&chip_object->lock.lock, chip_object->lock.irql);
+}
+
+/*
+    This routine removes serialization done by ChipObjectLock.
+
+    ChipObject      - The chip object to drop the lock for.
+
+    IRQL < DISPATCH_LEVEL
+*/
+void be_chip_unlock(struct be_chip_object *chip_object)
+{
+	spin_unlock_irqrestore(&chip_object->lock.lock, chip_object->lock.irql);
+}
diff --git a/drivers/message/beclib/funcobj_ll.c b/drivers/message/beclib/funcobj_ll.c
new file mode 100644
index 0000000..0a6b134
--- /dev/null
+++ b/drivers/message/beclib/funcobj_ll.c
@@ -0,0 +1,1236 @@
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
+
+/*
+    This allocates and initializes a function object based on the information
+    provided by upper layer drivers.
+
+    sa_dev 	- pointer to a device object
+    function_type - networking or srorage function
+    mailbox	- pointer to a memory region for use as mailbox
+    pfob	- pointer to a memory region  where function object is
+			initilized.
+
+    Returns BE_SUCCESS on success and an appropriate BESTATUS on failure.
+
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
+*/
+BESTATUS
+be_function_create(struct sa_dev *sa_dev,
+		   u32 function_type, struct sa_sgl *mailbox,
+		   struct be_function_object *pfob)
+{
+	BESTATUS status;
+
+	ASSERT(sa_dev);
+	ASSERT(pfob);	/* not a magic assert */
+	ASSERT(function_type <= 2);
+
+	TRACE(DL_INFO,
+	      "Create function object. type:%s sa_dev:0x%p object:0x%p",
+	      (function_type == BE_FUNCTION_TYPE_ISCSI ? "iSCSI" :
+	       (function_type == BE_FUNCTION_TYPE_NETWORK ? "Network" :
+		"Arm")), sa_dev, pfob);
+
+	memset(pfob, 0, sizeof(*pfob));
+
+	atomic_set(&pfob->ref_count, 0);
+	pfob->type = function_type;
+	pfob->sa_dev = sa_dev;
+
+	spin_lock_init(&pfob->lock.lock);
+
+	spin_lock_init(&pfob->cq_lock);
+	spin_lock_init(&pfob->post_lock);
+	spin_lock_init(&pfob->mcc_context_lock);
+
+	INIT_LIST_HEAD(&pfob->links.pd_list_head);
+	INIT_LIST_HEAD(&pfob->links.cq_list_head);
+	INIT_LIST_HEAD(&pfob->links.eq_list_head);
+	INIT_LIST_HEAD(&pfob->links.cxn_list_head);
+	INIT_LIST_HEAD(&pfob->links.eth_sq_list_head);
+	INIT_LIST_HEAD(&pfob->links.eth_rq_list_head);
+
+	if (be_function_is_iscsi(pfob)) {
+		INIT_LIST_HEAD(&pfob->links.iscsi.wrbq_list_head);
+		INIT_LIST_HEAD(&pfob->links.iscsi.defq_list_head);
+
+		pfob->pci_function_number = 0;
+	} else {
+
+		INIT_LIST_HEAD(&pfob->links.networking.dq_list_head);
+		INIT_LIST_HEAD(&pfob->links.networking.sq_list_head);
+		INIT_LIST_HEAD(&pfob->links.networking.rq_list_head);
+		pfob->pci_function_number = 1;
+	}
+
+	pfob->config.rss_type = RSS_ENABLE_NONE;
+
+	pfob->emulate = FALSE;
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
+	 * Cache the firmware config for ASSERTs in beclib and later
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
+
+	if (status != BE_SUCCESS) {
+		/* No cleanup necessary */
+		TRACE(DL_ERR, "Failed to create function.");
+		memset(pfob, 0, sizeof(*pfob));
+	}
+
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
+BESTATUS be_function_destroy(struct be_function_object *pfob)
+{
+	TRACE(DL_INFO, "Destroy pfob. Object:0x%p",
+	      pfob);
+
+	if (be_function_is_iscsi(pfob)) {
+		ASSERT(list_empty(&pfob->links.cxn_list_head));
+		ASSERT(list_empty(&pfob->links.iscsi.wrbq_list_head));
+		ASSERT(list_empty(&pfob->links.iscsi.defq_list_head));
+		ASSERT(pfob->config.num_ooo == 0);
+		ASSERT(pfob->config.num_sgl == 0);
+	} else {
+		ASSERT(be_function_is_networking(pfob));
+		ASSERT(list_empty(&pfob->links.cxn_list_head));
+		ASSERT(list_empty(&pfob->links.networking.sq_list_head));
+		ASSERT(list_empty(&pfob->links.networking.rq_list_head));
+		ASSERT(list_empty(&pfob->links.networking.dq_list_head));
+		ASSERT(pfob->config.num_multicast == 0);
+		ASSERT(pfob->config.rss_type ==
+		       RSS_ENABLE_NONE);
+	}
+
+	ASSERT(pfob->config.num_template == 0);
+	ASSERT(pfob->config.num_jell == 0);
+	ASSERT(pfob->config.num_zero == 0);
+	ASSERT(list_empty(&pfob->links.eth_sq_list_head));
+	ASSERT(list_empty(&pfob->links.eth_rq_list_head));
+	ASSERT(pfob->config.num_vlan == 0);
+	ASSERT(pfob->links.mcc == NULL);
+	ASSERT(list_empty(&pfob->links.cq_list_head));
+	ASSERT(list_empty(&pfob->links.eq_list_head));
+	ASSERT(pfob->config.num_page_table == 0);
+
+	return BE_SUCCESS;
+}
+
+/* Create chip object.  */
+BESTATUS be_chip_object_create(struct be_chip_object *chip)
+{
+	BESTATUS status = 0;
+	bool chip_created = FALSE;
+
+	status = be_chip_create(chip);
+	if (status != BE_SUCCESS)
+		goto Error;
+
+	chip_created = TRUE;
+
+Error:
+	if (status != BE_SUCCESS) {
+
+		/* Cleanup everything in case of failure. */
+
+		if (chip_created)
+			be_chip_destroy(chip);
+
+	}
+
+	return status;
+}
+
+/* Create function object.  */
+BESTATUS be_function_object_create(struct sa_dev *sa_dev,
+		u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+		struct sa_sgl *mailbox_sgl, struct be_function_object *pfob,
+		struct be_chip_object *chip)	/* object to initialize */
+{
+	BESTATUS status = 0;
+	bool function_created = FALSE;
+
+	status = be_function_create(sa_dev, function_type, mailbox_sgl, pfob);
+	if (status != BE_SUCCESS)
+		goto Error;
+
+	function_created = TRUE;
+
+	status = be_chip_insert_function_object(chip, pfob);
+
+Error:
+	if (status != BE_SUCCESS) {
+		/* Cleanup everything in case of failure. */
+		if (function_created)
+			be_function_destroy(pfob);
+	}
+
+	return status;
+}
+
+/*
+ * Create both function and chip object with one call.  The lower level
+ * API will rarely use more than one function object.
+ */
+BESTATUS be_function_and_chip_create(
+		struct sa_dev *sa_dev,	/* previously created device */
+		u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+		struct sa_sgl *mailbox_sgl, struct sa_sgl *emulation_sgl,
+		struct be_function_object *pfob, struct be_chip_object *chip)
+{
+	BESTATUS status = 0;
+	bool function_created = FALSE, chip_created = FALSE;
+
+	status = be_function_create(sa_dev, function_type, mailbox_sgl, pfob);
+	if (status != BE_SUCCESS)
+		goto Error;
+
+	function_created = TRUE;
+
+	status = be_chip_create(chip);
+	if (status != BE_SUCCESS)
+		goto Error;
+
+	chip_created = TRUE;
+
+	status = be_chip_insert_function_object(chip, pfob);
+
+Error:
+	if (status != BE_SUCCESS) {
+
+		/* Cleanup everything in case of failure. */
+
+		if (chip_created)
+			be_chip_destroy(chip);
+
+		if (function_created)
+			be_function_destroy(pfob);
+	}
+
+	return status;
+}
+
+BESTATUS
+be_function_and_chip_destroy(struct be_function_object *pfob,
+			     struct be_chip_object *chip)
+{
+	TRACE(DL_INFO, "Destroy function & chip.");
+
+	be_chip_remove_function_object(chip, pfob);
+
+	be_chip_destroy(chip);
+
+	be_function_destroy(pfob);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS
+be_function_object_destroy(struct be_function_object *pfob,
+			   struct be_chip_object *chip)
+{
+	TRACE(DL_INFO, "Destroy function & chip.");
+
+	(void)be_mpu_uninit_mailbox(pfob);
+
+	be_chip_remove_function_object(chip, pfob);
+
+	be_function_destroy(pfob);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS be_chip_object_destroy(struct be_chip_object *chip)
+{
+	TRACE(DL_INFO, "Destroy function & chip.");
+
+	be_chip_destroy(chip);
+
+	return BE_SUCCESS;
+}
+
+BESTATUS be_function_cleanup(struct be_function_object *pfob)
+{
+	BESTATUS status = 0;
+	struct be_cq_object *cq = NULL;
+	struct be_eq_object *eq = NULL;
+#ifdef FUNCTION_NIC
+	struct be_ethsq_object *eth_sq = NULL;
+	struct be_ethrq_object *eth_rq = NULL;
+#endif
+	u32 isr;
+	u32 host_intr;
+	struct PCICFG_HOST_TIMER_INT_CTRL_CSR_AMAP ctrl;
+
+	TRACE(DL_INFO, "function cleanup. function:%d",
+	      be_function_get_function_number(pfob));
+
+
+#ifdef FUNCTION_NIC
+
+	if (!be_function_is_iscsi(pfob)) {
+
+		/* Multicast */
+		if (pfob->config.num_multicast > 0) {
+			status = be_rxf_multicast_config(pfob, FALSE,
+						    0, NULL, NULL, NULL, NULL);
+			ASSERT(status == BE_SUCCESS);
+		}
+	}
+#endif
+
+#ifdef FUNCTION_NIC
+	/* ETX */
+	while (!list_empty(&pfob->links.eth_sq_list_head)) {
+		eth_sq = list_first_entry(&pfob->links.eth_sq_list_head,
+		    struct be_ethsq_object, list);
+
+		status = be_eth_sq_destroy(eth_sq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/* ERX */
+	while (!list_empty(&pfob->links.eth_rq_list_head)) {
+
+		eth_rq = list_first_entry(&pfob->links.eth_rq_list_head,
+			    struct be_ethrq_object, list);
+
+		status = be_eth_rq_destroy(eth_rq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/* VLAN */
+	if (pfob->config.num_vlan > 0) {
+		status = be_rxf_vlan_config(pfob, FALSE, 0, NULL,
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
+	if (pfob->links.mcc)
+		status = be_mcc_ring_destroy(pfob->links.mcc);
+	/* CQs */
+	while (!list_empty(&pfob->links.cq_list_head)) {
+		cq = list_first_entry(&pfob->links.cq_list_head,
+					struct be_cq_object, cq_list);
+
+		status = be_cq_destroy(cq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/* EQs */
+	while (!list_empty(&pfob->links.eq_list_head)) {
+		eq = list_first_entry(&pfob->links.eq_list_head,
+				struct be_eq_object, eq_list);
+
+		status = be_eq_destroy(eq);
+		ASSERT(status == BE_SUCCESS);
+	}
+
+	/*
+	 * If interrupts are disabled, clear any CEV interrupt assertions that
+	 * fired after we stopped processing EQs.
+	 */
+	ctrl.dw[0] = PCICFG1_READ(pfob, host_timer_int_ctrl);
+	host_intr = AMAP_GET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+							hostintr, ctrl.dw);
+	if (!host_intr)
+		if (be_function_is_networking(pfob))
+			isr = CSR_READ(pfob, cev.isr1);
+		else
+			isr = CSR_READ(pfob, cev.isr0);
+	else
+		/* This should never happen... */
+		TRACE(DL_ERR,
+		      "Calling function_cleanup with interrupts enabled.");
+
+	/* Function object destroy */
+	status = be_function_object_destroy(pfob, pfob->parent_chip);
+	ASSERT(status == BE_SUCCESS);
+
+	return status;
+}
+
+/*
+    This routine adds a event queue object to a function object to allow
+    for correct tracking and reference counting.
+
+    pfob         - Function object to add the object to.
+
+    eq_object        - Event queue object to add.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_eq(struct be_function_object *pfob,
+		    struct be_eq_object *eq_object)
+{
+	_be_function_lock(pfob);
+
+	atomic_inc(&pfob->ref_count);
+	list_add_tail(&eq_object->eq_list, &pfob->links.eq_list_head);
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine removes a event queue object from a function object and
+    drops the reference count for the given function object.
+
+    pfob         - Function object to remove the object from.
+
+    eq_object        - Event queue object to remove.
+
+*/
+void
+_be_function_remove_eq(struct be_function_object *pfob,
+		       struct be_eq_object *eq_object)
+{
+	_be_function_lock(pfob);
+
+	list_del(&eq_object->eq_list);
+	atomic_dec(&pfob->ref_count);
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine adds a completion queue object to a function object to allow
+    for correct tracking and reference counting.
+
+    pfob         - Function object to add the object to.
+
+    cq_object        - Completion queue object to add.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_cq(struct be_function_object *pfob,
+		    struct be_cq_object *cq_object)
+{
+	_be_function_lock(pfob);
+
+	atomic_inc(&pfob->ref_count);
+	list_add_tail(&cq_object->cq_list, &pfob->links.cq_list_head);
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine removes a completion queue object from a function object and
+    drops the reference count for the given function object.
+
+    pfob         - Function object to remove the object from.
+
+    cq_object    - Completion queue object to remove.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_cq(struct be_function_object *pfob,
+		       struct be_cq_object *cq_object)
+{
+	_be_function_lock(pfob);
+
+	list_del(&cq_object->cq_list);
+	atomic_dec(&pfob->ref_count);
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine adds an Ethernet Send queue object to a function
+    object to allow for correct tracking and reference counting.
+
+    func_obj      - function object to add the object to.
+
+    eth_sq        - ethernet send queue object to add.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_add_eth_sq(struct be_function_object *pfob,
+			struct be_ethsq_object *eth_sq)
+{
+	_be_function_lock(pfob);
+
+	atomic_inc(&pfob->ref_count);
+	list_add_tail(&eth_sq->list, &pfob->links.eth_sq_list_head);
+
+	_be_function_unlock(pfob);
+
+}
+
+/*
+    This routine removes an Ethernet Send Queue object from a function object
+    and drops the reference count for the given function object.
+
+    pfob         - Function object to remove the object from.
+
+    EthSq        - Ethernet Send Queue object to remove.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_eth_sq(struct be_function_object *pfob,
+			   struct be_ethsq_object *eth_sq)
+{
+	_be_function_lock(pfob);
+
+	list_del(&eth_sq->list);
+	atomic_dec(&pfob->ref_count);
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine adds an ethernet receive queue object to a
+    function object to allow for correct tracking and reference counting.
+
+    pfob     - Function object to add the object to.
+
+    EthRq       - Ethernet Receive Queue object to add.
+
+    RssIndex    - Rss Index that this RQ will map to. Unless this RQ is for
+		a priviledged execution environment, the RssIndex must be
+		set to RSS_ID_INDEX_DQ.
+
+    IRQL < DISPATCH_LEVEL
+*/
+void
+_be_function_add_eth_rq(struct be_function_object *pfob,
+			struct be_ethrq_object *eth_rq)
+{
+	_be_function_lock(pfob);
+
+	atomic_inc(&pfob->ref_count);
+	list_add_tail(&eth_rq->list, &pfob->links.eth_rq_list_head);
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine removes an Ethernet receive queue object from a function object
+    and drops the reference count for the given function object.
+
+    pfob     - Function object to remove the object from.
+
+    EthRq       - Ethernet receive queue object to remove.
+
+    RssIndex    - Rss Index for the EthRq to remove.
+
+    IRQL < DISPATCH_LEVEL
+
+*/
+void
+_be_function_remove_eth_rq(struct be_function_object *pfob,
+			   struct be_ethrq_object *eth_rq)
+{
+	_be_function_lock(pfob);
+
+	list_del(&eth_rq->list);
+	atomic_dec(&pfob->ref_count);
+
+	_be_function_unlock(pfob);
+
+}
+
+/*
+    This routine adds a Mcc Send queue object to a function object to allow
+    for correct tracking and reference counting.
+
+    pfob         - Function object to add the object to.
+
+    mcc           - Mcc Send Queue object to add.
+
+*/
+void
+_be_function_add_mcc(struct be_function_object *pfob,
+		     struct be_mcc_object *mcc)
+{
+	ASSERT(pfob->links.mcc == NULL);
+
+	_be_function_lock(pfob);
+
+	atomic_inc(&pfob->ref_count);
+	pfob->links.mcc = mcc;
+
+	_be_function_unlock(pfob);
+}
+
+/*
+    This routine removes an MCC Send Queue object from a function object and
+    drops the reference count for the given function object.
+
+    pfob     - Function object to remove the object from.
+
+    mcc      - Mcc Send Queue object to remove.
+
+*/
+void
+_be_function_remove_mcc(struct be_function_object *pfob,
+			struct be_mcc_object *mcc)
+{
+	_be_function_lock(pfob);
+
+	pfob->links.mcc = NULL;
+	atomic_dec(&pfob->ref_count);
+
+	_be_function_unlock(pfob);
+}
+
+
+void *
+be_function_prepare_embedded_fwcmd(struct be_function_object *pfob,
+	struct MCC_WRB_AMAP *wrb, u32 payload_length, u32 request_length,
+	u32 response_length, u32 opcode, u32 subsystem)
+{
+	struct FWCMD_REQUEST_HEADER *header = NULL;
+	u32 n;
+
+	ASSERT(wrb);
+
+	n = AMAP_BYTE_OFFSET(MCC_WRB, payload);
+	AMAP_SET_BITS_PTR(MCC_WRB, embedded, wrb, 1);
+	AMAP_SET_BITS_PTR(MCC_WRB, payload_length, wrb,
+		min(payload_length, n));
+	header = (struct FWCMD_REQUEST_HEADER *)((u8 *)wrb + n);
+
+	header->timeout = 0;
+	header->domain = be_function_get_pd_number(pfob);
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
+	u32 payload_length,
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
+	AMAP_SET_BITS_PTR(MCC_WRB, payload_length, wrb, payload_length);
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
+	AMAP_SET_BITS_PTR_UNION(MCC_WRB_PAYLOAD, sgl[0].length, plp,
+					payload_length);
+	AMAP_SET_BITS_PTR_UNION(MCC_WRB_PAYLOAD, sgl[0].pa_lo, plp,
+					sa_lo(fwcmd_pa));
+	AMAP_SET_BITS_PTR_UNION(MCC_WRB_PAYLOAD, sgl[0].pa_hi, plp,
+					sa_hi(fwcmd_pa));
+
+	header->timeout = 0;
+	header->domain = be_function_get_pd_number(pfob);
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
+	if (pfob->links.mcc)
+		wrb = _be_mpu_peek_ring_wrb(pfob->links.mcc, FALSE);
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
+/*
+    This routine posts an MCC WRB command to a function object's MCC send
+    queue (if avaiable) or posts the WRB to the MCC WRB mail box if a send
+    queue is not setup.
+
+    pfob     - function object to add the object to.
+    wrb                 - wrb to post.  This may be a va from the
+			  be_function_peek_mcc_wrb function, so the
+			  driver need not declare additional memory.
+    callback  - address of a callback routine to invoke once the WRB
+			is completed.
+    callback_context - opaque context to be passed during the call to
+			the callback.
+    Returns BE_SUCCESS if successfull, otherwise a useful error code
+	is returned.
+*/
+BESTATUS
+be_function_post_mcc_wrb(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb, MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context, void *optional_fwcmd_va)
+{
+	struct be_mcc_wrb_response_copy response_copy = { 0 };
+	return be_function_post_mcc_wrb_complete(pfob, wrb, NULL,
+				 callback, callback_context, NULL, NULL,
+					 optional_fwcmd_va, response_copy);
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_queue_context(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		void *optional_fwcmd_va)
+{
+	struct be_mcc_wrb_response_copy response_copy = { 0 };
+	return be_function_post_mcc_wrb_complete(pfob, wrb, queue_context,
+			callback, callback_context, NULL,
+			 NULL, optional_fwcmd_va, response_copy);
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_copy(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context, void *optional_fwcmd_va,
+		struct be_mcc_wrb_response_copy response_copy)
+{
+	return be_function_post_mcc_wrb_complete(pfob,
+			wrb, queue_context, callback, callback_context, NULL,
+				 NULL, optional_fwcmd_va, response_copy);
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_internal_callback(
+		struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context,
+		void *optional_fwcmd_va)
+{
+	struct be_mcc_wrb_response_copy response_copy = { 0 };
+	return be_function_post_mcc_wrb_complete(pfob, wrb,
+			queue_context, callback, callback_context,
+			internal_callback, internal_callback_context,
+			optional_fwcmd_va, response_copy);
+}
+
+#if defined(SA_DEBUG)
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
+	wrb_context->consumed_count = pfob->stats.consumed_wrbs;
+
+	if (header) {
+		wrb_context->opcode = header->opcode;
+		wrb_context->subsystem = header->subsystem;
+
+	} else {
+		wrb_context->opcode = 0;
+		wrb_context->subsystem = 0;
+		TRACE(DL_FWCMD,
+			"Post FWCMD. emul:0 embed:0 Unknown sub/op. ctx:%p",
+				wrb_context);
+	}
+}
+#else
+#define be_function_debug_print_wrb(a_, b_, c_, d_)
+#endif
+
+BESTATUS
+be_function_post_mcc_wrb_complete(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context, void *optional_fwcmd_va,
+		struct be_mcc_wrb_response_copy response_copy)
+{
+	BESTATUS status;
+	struct be_mcc_wrb_context *wrb_context = NULL;
+	u64 *p;
+
+	if (queue_context) {
+
+		/* Initialize context.         */
+		queue_context->context.internal_callback = internal_callback;
+		queue_context->context.internal_callback_context =
+		    internal_callback_context;
+		queue_context->context.callback = callback;
+		queue_context->context.callback_context = callback_context;
+		queue_context->context.copy = response_copy;
+		queue_context->context.optional_fwcmd_va = optional_fwcmd_va;
+
+		/* Queue this request */
+		status = be_function_queue_mcc_wrb(pfob, queue_context);
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
+	p = (u64 *) ((u8 *)wrb + AMAP_BYTE_OFFSET(MCC_WRB, tag));
+	*p = SA_PTR_TO_U64(wrb_context);
+
+	/* Print info about this FWCMD for debug builds. */
+	be_function_debug_print_wrb(pfob, wrb, optional_fwcmd_va, wrb_context);
+
+	/*
+	 * issue the WRB to the MPU as appropriate
+	 */
+	if (pfob->links.mcc) {
+		/*
+		 * we're in WRB mode, pass to the mcc layer
+		 */
+		status = _be_mpu_post_wrb_ring(pfob->links.  mcc,
+					wrb, wrb_context);
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
+void _be_function_lock(struct be_function_object *pfob)
+{
+	spin_lock_irqsave(&pfob->lock.lock, pfob->lock.irql);
+}
+
+void _be_function_unlock(struct be_function_object *pfob)
+{
+	spin_unlock_irqrestore(&pfob->lock.lock, pfob->lock.irql);
+}
+
+u32 be_function_get_function_number(struct be_function_object *pfob)
+{
+	return pfob->pci_function_number;
+}
+
+u32 be_function_get_function_type(struct be_function_object *pfob)
+{
+	return pfob->type;
+}
+
+u32 be_function_get_pd_number(struct be_function_object *pfob)
+{
+
+	/* only PD0 supported in Linux drivers */
+	return 0;
+}
+
+bool be_function_is_vm(struct be_function_object *pfob)
+{
+	return be_function_get_pd_number(pfob) > 0;
+}
+
+BESTATUS
+be_function_ring_destroy_async(struct be_function_object *pfob,
+		u32 id, u32 ring_type, MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context)
+{
+
+	struct FWCMD_COMMON_RING_DESTROY *fwcmd = NULL;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	BESTATUS status = 0;
+
+	be_lock_wrb_post(pfob);
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
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_internal_callback(pfob, wrb,
+		NULL, callback, callback_context, internal_callback,
+					internal_callback_context, fwcmd);
+	if (status != BE_SUCCESS && status != BE_PENDING) {
+		TRACE(DL_ERR,
+		      "Ring destroy fwcmd failed. id:%d ring_type:%d", id,
+		      ring_type);
+		goto Error;
+	}
+
+Error:
+	be_unlock_wrb_post(pfob);
+	return status;
+}
+
+BESTATUS
+be_function_ring_destroy(struct be_function_object *pfob, u32 id, u32 ring_type)
+{
+	return be_function_ring_destroy_async(pfob, id,
+			      ring_type, NULL, NULL, NULL, NULL);
+}
+
+void
+be_sgl_to_pa_list(struct sa_sgl *sgl, struct PHYS_ADDR *pa_list, u32 max_num)
+{
+	u32 num_pages = sa_sgl_get_page_count(sgl);
+	u32 i = 0;
+	u64 pa = sgl->pa;
+	__le64 lepa;
+
+	ASSERT(pa_list);
+	ASSERT(pa);
+
+	for (i = 0; i < min(num_pages, max_num); i++) {
+		lepa = cpu_to_le64(pa);
+		pa_list[i].lo = sa_lo(lepa);
+		pa_list[i].hi = sa_hi(lepa);
+		pa += PAGE_SIZE;
+	}
+}
+
+
+
+/*
+ *---------------------------------------------------------------------------
+ * Function: be_function_enable_interrupts
+ *   Enables interrupts for the given PCI function.
+ * pfob    -
+ * return return_type - void
+ *----------------------------------------------------------------------------
+ */
+void be_function_enable_interrupts(struct be_function_object *pfob)
+{
+	struct be_eq_object *eq = NULL;
+	struct CQ_DB_AMAP cq_db;
+	u32 host_intr;
+	u32 isr;
+	struct PCICFG_HOST_TIMER_INT_CTRL_CSR_AMAP ctrl;
+
+	ctrl.dw[0] = PCICFG1_READ(pfob, host_timer_int_ctrl);
+	host_intr = AMAP_GET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+							hostintr, ctrl.dw);
+	if (!host_intr) {
+		/*
+		 * Read-clear the ISR to make sure that any EQs that
+		 * fired after the host interrupt was masked are no longer
+		 * asserted.  If the EQs still have a producer-consumer
+		 * mismatch, they will re-assert after they are armed.  This
+		 * handles the situation where software polls CQs and EQs
+		 * with interrupts disabled.
+		 */
+		if (be_function_is_networking(pfob))
+			isr = CSR_READ(pfob, cev.isr1);
+		else
+			isr = CSR_READ(pfob, cev.isr0);
+
+		/*
+		 * Read-Modify-Write the control register
+		 *
+		 */
+		AMAP_SET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR, hostintr,
+				ctrl.dw, 1);
+		PCICFG1_WRITE_CONST(pfob, host_timer_int_ctrl,
+				ctrl.dw[0]);
+	}
+
+	cq_db.dw[0] = 0;		/* clear entire doorbell */
+	AMAP_SET_BITS_PTR(CQ_DB, event, &cq_db, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &cq_db, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &cq_db, 0);
+
+	/* Lock the function object while walking the EQ list. */
+	_be_function_lock(pfob);
+
+	/* Rearm each EQ. */
+	list_for_each_entry(eq, &pfob->links.eq_list_head, eq_list) {
+		AMAP_SET_BITS_PTR(CQ_DB, qid, &cq_db, eq->eq_id);
+		PD_WRITE(pfob, cq_db, cq_db);
+	}
+
+	_be_function_unlock(pfob);
+}
+
+/*
+ *----------------------------------------------------------------------------
+ * Function: be_function_disable_interrupts
+ *   Disables interrupts for the given PCI function.
+ * pfob    -
+ * return return_type - void
+ *----------------------------------------------------------------------------
+ */
+void be_function_disable_interrupts(struct be_function_object *pfob)
+{
+	u32 host_intr;
+	struct PCICFG_HOST_TIMER_INT_CTRL_CSR_AMAP ctrl;
+
+	/*
+	 * Read-Modify-Write of the control register in PCI config space.
+	 */
+	ctrl.dw[0] = PCICFG1_READ(pfob, host_timer_int_ctrl);
+	host_intr = AMAP_GET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+				hostintr, ctrl.dw);
+	if (host_intr) {
+		AMAP_SET_BITS_PTR(PCICFG_HOST_TIMER_INT_CTRL_CSR,
+				hostintr, ctrl.dw, 0);
+		PCICFG1_WRITE_CONST(pfob, host_timer_int_ctrl, ctrl.dw[0]);
+	}
+}
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
+ * callback           - Callback function invoked when the FWCMD completes.
+ * callback_context   - Passed to the callback function.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------------------
+ */
+BESTATUS
+be_function_get_fw_version(struct be_function_object *pfob,
+		struct FWCMD_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD *fwv,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context)
+{
+	BESTATUS status = BE_SUCCESS;
+	struct MCC_WRB_AMAP *wrb = NULL;
+	struct FWCMD_COMMON_GET_FW_VERSION *fwcmd = NULL;
+
+	be_lock_wrb_post(pfob);
+
+	wrb = be_function_peek_mcc_wrb(pfob);
+	if (!wrb) {
+		TRACE(DL_ERR, "MCC wrb peek failed.");
+		status = BE_STATUS_NO_MCC_WRB;
+		goto Error;
+	}
+
+	if (!callback && !fwv) {
+		TRACE(DL_ERR, "callback and response buffer NULL!");
+		status = BE_NOT_OK;
+		goto Error;
+	}
+	/* Prepares an embedded fwcmd, including request/response sizes. */
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_GET_FW_VERSION);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(pfob, wrb, NULL, callback,
+			callback_context, fwcmd,
+			BE_CREATE_MCC_RESPONSE_COPY(FWCMD_COMMON_GET_FW_VERSION,
+			     params.response, fwv));
+
+Error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
+BESTATUS
+be_function_queue_mcc_wrb(struct be_function_object *pfob,
+			  struct be_generic_queue_context *queue_context)
+{
+	BESTATUS status;
+
+	ASSERT(queue_context);
+
+	/*
+	 * issue the WRB to the MPU as appropriate
+	 */
+	if (pfob->links.mcc) {
+
+		/* We're in ring mode.  Queue this item. */
+		pfob->links.mcc->backlog_length++;
+		list_add_tail(&queue_context->context.list,
+					&pfob->links.mcc->backlog);
+
+		pfob->stats.queued_wrbs++;
+		pfob->stats.queue_length = pfob->links.mcc->backlog_length;
+		pfob->stats.max_queue_length = max(pfob->stats.queue_length,
+						pfob->stats.max_queue_length);
+		status = BE_PENDING;
+
+	} else {
+		status = BE_NOT_OK;
+	}
+
+	return status;
+}
+
+
+BESTATUS
+be_function_internal_query_firmware_config(struct be_function_object *pfob,
+				   struct BE_FIRMWARE_CONFIG *config)
+{
+	struct FWCMD_COMMON_FIRMWARE_CONFIG *fwcmd = NULL;
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
+	fwcmd = BE_PREPARE_EMBEDDED_FWCMD(pfob, wrb, COMMON_FIRMWARE_CONFIG);
+
+	/* Post the Ioctl */
+	status = be_function_post_mcc_wrb_with_copy(pfob, wrb, NULL,
+		NULL, NULL, fwcmd,
+		BE_CREATE_MCC_RESPONSE_COPY(FWCMD_COMMON_FIRMWARE_CONFIG,
+		params.response, config));
+error:
+	be_unlock_wrb_post(pfob);
+
+	return status;
+}
+
diff --git a/drivers/message/beclib/main_ll.c b/drivers/message/beclib/main_ll.c
new file mode 100644
index 0000000..8202e7e
--- /dev/null
+++ b/drivers/message/beclib/main_ll.c
@@ -0,0 +1,37 @@
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
+unsigned int trace_level;
+/*
+    System-invoked entry point for system DLL.
+    This routine gets called once per system instantiation, is
+    responsible for registering the the driver's entry points.
+    Initialization and configuration occur elsewhere.
+
+    Returns SA_SUCCESS if ok.
+
+    IRQL: PASSIVE_LEVEL
+*/
+BESTATUS be_initialize_library(void)
+{
+	SA_TRACE(DL_NOTE, "Built on " __DATE__ " " __TIME__);
+
+	sa_trace_set_debug_level_string(DL_HW, "hw");
+
+	return BE_SUCCESS;
+}
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

