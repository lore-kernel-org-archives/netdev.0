From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 5/12] benet: beclib header files
Date: Thu, 12 Jun 2008 03:42:18 -0700
Message-ID: <20080612104218.0625d526@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.245.99]:16394 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756531AbYFLKmX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/beclib_ll.h         |  559 ++++++++++++++++++++++++++++
 drivers/message/beclib/beclib_private_ll.h |  298 +++++++++++++++
 drivers/message/beclib/beclib_stats.h      |   54 +++
 drivers/message/beclib/beregister.h        |  367 ++++++++++++++++++
 drivers/message/beclib/bestatus.h          |  103 +++++
 drivers/message/beclib/pch.h               |   35 ++
 6 files changed, 1416 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/beclib_ll.h
 create mode 100644 drivers/message/beclib/beclib_private_ll.h
 create mode 100644 drivers/message/beclib/beclib_stats.h
 create mode 100644 drivers/message/beclib/beregister.h
 create mode 100644 drivers/message/beclib/bestatus.h
 create mode 100644 drivers/message/beclib/pch.h

diff --git a/drivers/message/beclib/beclib_ll.h b/drivers/message/beclib/beclib_ll.h
new file mode 100644
index 0000000..26d354f
--- /dev/null
+++ b/drivers/message/beclib/beclib_ll.h
@@ -0,0 +1,559 @@
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
+#ifndef __beclib_lower_h__
+#define __beclib_lower_h__
+
+#include "beclib_common.h"	/* High and low level API commonalities */
+
+/*
+    Internal memory descriptor for memory shared by both the host driver and
+    the controller
+*/
+struct be_shared_mem_descriptor {
+	void *va;		/*! virtual address */
+	struct sa_sgl *sgl;		/*! memory descriptor list */
+	u32 tag;		/*! memory tracking tag */
+} ;
+
+/*
+    Locking structure for beklib.
+*/
+struct be_lock {
+	spinlock_t lock;
+	unsigned long irql;
+} ;
+
+/*
+    Represents a Blade Engine chip. This is used to manage
+    global chip resources.  Only the ARM uses this from the low
+    level API.
+*/
+struct be_chip_object {
+	u32 magic;
+	atomic_t ref_count;
+	struct be_lock lock;
+	struct list_head function_list_head;
+
+} ;
+
+struct be_mcc_wrb_response_copy {
+	u16 length;		/* bytes in response */
+	u16 fwcmd_offset;	/* offset within the wrb of the response */
+	void *va;		/* user's va to copy response into */
+
+} ;
+
+struct be_mcc_wrb_context {
+
+	MCC_WRB_CQE_CALLBACK internal_callback;	/* Function to call on
+						completion */
+	void *internal_callback_context;	/* Parameter to pass
+						   to completion function */
+
+	MCC_WRB_CQE_CALLBACK callback;	/* Function to call on completion */
+	void *callback_context;	/* Parameter to pass to completion function */
+
+	BESTATUS *users_final_status;	/* pointer to a local
+						variable for synchronous
+						commands */
+	struct MCC_WRB_AMAP *wrb;	/* pointer to original wrb for embedded
+						commands only */
+	struct list_head next;	/* links context structs together in
+				   free list */
+
+	struct be_mcc_wrb_response_copy copy;	/* Optional parameters to copy
+					   embedded response to user's va */
+
+#if defined(SA_DEBUG)
+	u16 subsystem, opcode;	/* Track this FWCMD for debug builds. */
+	struct MCC_WRB_AMAP *ring_wrb;
+	u32 consumed_count;
+#endif
+} ;
+
+/*
+    Represents a function object for network or storage.  This
+    is used to manage per-function resources like MCC CQs, etc.
+*/
+struct be_function_object {
+
+	u32 magic;		/*!< magic for detecting memory corruption. */
+	struct be_chip_object *parent_chip;
+
+	/*
+	 * Generic system abstraction (SA) device object for accessing
+	 * registers, physical memory, etc.
+	 */
+	struct sa_dev *sa_dev;
+
+	u32 emulate;		/* if set, MPU is not available.
+				  Emulate everything.     */
+	u32 pend_queue_driving;	/* if set, drive the queued WRBs
+				   after releasing the WRB lock */
+
+	spinlock_t post_lock;	/* lock for verifying one thread posting wrbs */
+	spinlock_t cq_lock;	/* lock for verifying one thread
+				   processing cq */
+	spinlock_t mcc_context_lock;	/* lock for protecting mcc
+					   context free list */
+	unsigned long post_irq;
+	unsigned long cq_irq;
+
+	atomic_t ref_count;	/* # of  objects  referencing this funcobj */
+	struct be_lock lock;		/* synchronization lock */
+	u32 type;
+	u32 pci_function_number;
+
+	struct list_head function_list;	/* for linking these objects together */
+
+	struct {
+		struct list_head pd_list_head;	/* protection domain list */
+		struct list_head cq_list_head;	/* completion queue list */
+		struct list_head eq_list_head;	/* event queue list     */
+		struct list_head cxn_list_head;	/* list of active
+						   connections */
+		struct list_head eth_sq_list_head;	/* list of ethernet
+								send rings */
+		struct list_head eth_rq_list_head;	/* list of ether RX
+								rings */
+		struct list_head rdma_qp_list_head;	/* queue pair list */
+
+		struct be_mcc_object *mcc;	/* mcc rings. */
+		struct be_pd_object *pd_object; /* perceived PD 0 */
+
+		union {
+			struct {
+				struct list_head wrbq_list_head;
+				struct list_head defq_list_head;
+			} iscsi;
+
+			struct {
+				struct list_head dq_list_head;
+				struct list_head sq_list_head;
+				struct list_head rq_list_head;
+			} networking;
+		};
+	} links;
+
+	struct {
+		struct MCC_MAILBOX_AMAP *va;	/* VA to the mailbox */
+		u64 pa;	/* PA to the mailbox */
+		u32 length;	/* byte length of mailbox */
+
+		/* One default context struct used for posting at
+		 * least one MCC_WRB
+		 */
+		struct be_mcc_wrb_context default_context;
+		bool default_context_allocated;
+	} mailbox;
+
+	struct {
+		/* Page table     */
+		u32 num_page_table;
+		u32 num_sgl;
+
+		/* Wake on lans configured. */
+		u32 wol_bitmask;	/* bits 0,1,2,3 are set if
+					   corresponding index is enabled */
+		u32 num_jell;
+		u32 num_vlan;
+		u32 num_template;
+		u32 num_multicast;
+		u32 rss_type;
+		u32 num_zero;
+		u32 num_ooo;
+	} config;
+
+	u32 own_semaphore;
+	unsigned long current_irql;
+
+	struct BE_FIRMWARE_CONFIG fw_config;
+	struct beclib_function_stats stats;
+} ;
+
+/*
+    Represents a protection domain
+*/
+struct be_pd_object {
+	u32 magic;
+	atomic_t ref_count;
+
+	struct be_function_object *parent_function;
+	struct list_head pd_list;
+
+	u32 pd_id;
+	u8 *pd_page_va;
+	u64 pd_page_pa;
+
+} ;
+
+/*
+      Represents an Event Queue
+*/
+struct be_eq_object {
+	u32 magic;
+	atomic_t ref_count;
+	struct be_lock lock;
+
+	struct be_function_object *parent_function;
+
+	struct list_head eq_list;
+	struct list_head cq_list_head;
+
+	u32 eq_id;
+	EQ_CALLBACK callback;
+	void *callback_context;
+
+} ;
+
+/*
+    Manages a completion queue
+*/
+struct be_cq_object {
+	u32 magic;
+	atomic_t ref_count;
+
+	struct be_function_object *parent_function;
+	struct be_eq_object *eq_object;
+
+	struct list_head cq_list;
+	struct list_head cqlist_for_eq;
+
+	void *va;
+	u32 num_entries;
+
+	CQ_CALLBACK callback;
+	void *callback_context;
+
+	u32 cq_id;
+
+} ;
+
+/*
+    Manages an ethernet send queue
+*/
+struct be_ethsq_object {
+	u32 magic;
+
+	struct list_head list;
+
+	struct be_function_object *parent_function;
+	struct be_cq_object *cq_object;
+	u32 bid;
+
+} ;
+
+/*
+@brief
+    Manages an ethernet receive queue
+*/
+struct be_ethrq_object {
+	u32 magic;
+	struct list_head list;
+	struct be_function_object *parent_function;
+	u32 rid;
+	struct be_cq_object *cq_object;
+	struct be_cq_object *rss_cq_object[4];
+
+} ;
+
+/*
+    Manages an MCC
+*/
+struct be_mcc_object {
+	u32 magic;
+
+	struct be_function_object *parent_function;
+	struct list_head mcc_list;
+
+	struct be_cq_object *cq_object;
+
+	/* Async event callback for MCC CQ. */
+	MCC_ASYNC_EVENT_CALLBACK async_callback;
+	void *async_context;
+
+	struct {
+		struct be_mcc_wrb_context *base;
+		u32 num;
+		struct list_head list_head;
+	} wrb_context;
+
+	struct {
+		struct sa_sgl *sgl;
+		struct be_shared_mem_descriptor sm_descriptor;
+		struct sa_ring ring;
+	} sq;
+
+	struct {
+		struct be_shared_mem_descriptor sm_descriptor;
+		struct sa_ring ring;
+	} cq;
+
+	u32 processing;		/* flag indicating that one thread
+				   is processing CQ */
+	u32 rearm;		/* doorbell rearm setting to make
+				   sure the active processing thread */
+	/* rearms the CQ if any of the threads requested it. */
+
+	struct list_head backlog;
+	u32 backlog_length;
+	u32 driving_backlog;
+	u32 consumed_index;
+
+} ;
+
+/*
+   Manages an iSCSI default PDU
+*/
+struct be_default_pdu_queue_object {
+	u32 magic;
+
+	struct be_function_object *parent_function;
+	struct list_head func_list;
+	struct be_cq_object *cq_object;
+	struct sa_sgl *sgl;
+	u32 rid;
+} ;
+
+struct be_iscsi_wrb_queue_object {
+
+	u32 magic;
+
+	struct be_function_object *parent_function;
+
+	struct list_head wrbq_list;
+
+	/*u32 cra, length; */
+	u32 cid;
+	struct sa_sgl *sgl;
+	u32 length;
+
+} ;
+
+/*
+   Manages iSCSI connection resources like CID, WRB ring, etc.
+*/
+struct be_iscsi_connection_object {
+	u32 magic;
+	struct be_function_object *parent_function;
+
+	struct be_cq_object *cq;
+	struct be_iscsi_wrb_queue_object *wrbq;
+	struct be_default_pdu_queue_object *defq;
+
+	struct list_head connection_list;
+} ;
+
+/* Queue context header -- the required software information for
+ * queueing a WRB.
+ */
+struct be_queue_driver_context {
+	MCC_WRB_CQE_CALLBACK internal_callback;	/* Function to call on
+						   completion */
+	void *internal_callback_context;	/* Parameter to pass
+						   to completion function */
+
+	MCC_WRB_CQE_CALLBACK callback;	/* Function to call on completion */
+	void *callback_context;	/* Parameter to pass to completion function */
+
+	struct be_mcc_wrb_response_copy copy;	/* Optional parameters to copy
+					   embedded response to user's va */
+
+	void *optional_fwcmd_va;
+
+	struct list_head list;
+
+	u32 bytes;
+
+} ;
+
+/*
+ * Common MCC WRB header that all commands require.
+ */
+struct be_mcc_wrb_header {
+	u8 rsvd[AMAP_BYTE_OFFSET(MCC_WRB, payload)];
+} ;
+SA_GLOBAL_C_ASSERT(queue_header,
+	sizeof(struct be_mcc_wrb_header) == AMAP_BYTE_OFFSET(MCC_WRB, payload));
+
+/*
+ * All non embedded commands supported by beclib functions only allow
+ * 1 SGE.  This queue context handles them all.
+ */
+struct be_nonembedded_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct MCC_SGE_AMAP sge[1];
+} ;
+
+/*
+ * ------------------------------------------------------------------------
+ *  This section contains the specific queue struct for each command.
+ *  The user could always provide a be_generic_queue_context but this is a
+ *  rather large struct.  By using the specific struct, memory consumption
+ *  can be reduced.
+ * ------------------------------------------------------------------------
+ */
+
+struct be_link_status_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_NTWK_LINK_STATUS_QUERY fwcmd;
+} ;
+
+struct be_multicast_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_NTWK_MULTICAST_SET fwcmd;
+} ;
+
+struct be_wake_on_lan_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_ETH_ACPI_CONFIG fwcmd;
+} ;
+
+struct be_vlan_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_NTWK_VLAN_CONFIG fwcmd;
+} ;
+
+struct be_promiscuous_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_ETH_PROMISCUOUS fwcmd;
+} ;
+
+struct be_force_failover_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_FORCE_FAILOVER fwcmd;
+} ;
+
+
+struct be_nop_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_NOP fwcmd;
+} ;
+
+struct be_rxf_filter_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_NTWK_RX_FILTER fwcmd;
+} ;
+
+struct be_eq_modify_delay_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct FWCMD_COMMON_MODIFY_EQ_DELAY fwcmd;
+} ;
+
+/*
+ * The generic context is the largest size that would be required.
+ * It is the software context plus an entire WRB.
+ */
+struct be_generic_queue_context {
+	struct be_queue_driver_context context;
+	struct be_mcc_wrb_header wrb_header;
+	struct MCC_WRB_PAYLOAD_AMAP payload;
+} ;
+
+SA_GLOBAL_C_ASSERT(generic_queue_context,
+	sizeof(struct be_generic_queue_context) >=
+	  sizeof(struct be_queue_driver_context) + sizeof(struct MCC_WRB_AMAP));
+/*
+ * Types for the BE_QUEUE_CONTEXT object.
+ */
+#define BE_QUEUE_INVALID	(0)
+#define BE_QUEUE_LINK_STATUS	(0xA006)
+#define BE_QUEUE_ETH_STATS	(0xA007)
+#define BE_QUEUE_TPM_STATS	(0xA008)
+#define BE_QUEUE_TCP_STATS	(0xA009)
+#define BE_QUEUE_MULTICAST	(0xA00A)
+#define BE_QUEUE_VLAN		(0xA00B)
+#define BE_QUEUE_RSS		(0xA00C)
+#define BE_QUEUE_FORCE_FAILOVER	(0xA00D)
+#define BE_QUEUE_PROMISCUOUS	(0xA00E)
+#define BE_QUEUE_WAKE_ON_LAN	(0xA00F)
+#define BE_QUEUE_NOP		(0xA010)
+
+#include "beclib_ll_enum_nic.h"
+#include "beclib_ll_bmap_nic.h"
+/*
+ * ----------------------------------------------------------------------
+ *   API MACROS
+ * ----------------------------------------------------------------------
+ */
+#define BE_FWCMD_NAME(_short_name_)     FWCMD_##_short_name_
+#define BE_OPCODE_NAME(_short_name_)    OPCODE_##_short_name_
+#define BE_SUBSYSTEM_NAME(_short_name_) SUBSYSTEM_##_short_name_
+
+
+#define BE_PREPARE_EMBEDDED_FWCMD(_pfob_, _wrb_, _short_name_)	\
+	((struct BE_FWCMD_NAME(_short_name_) *)				\
+	be_function_prepare_embedded_fwcmd(_pfob_, _wrb_,	\
+		sizeof(struct BE_FWCMD_NAME(_short_name_)),		\
+		SA_SIZEOF_FIELD(BE_FWCMD_NAME(_short_name_), params.request), \
+		SA_SIZEOF_FIELD(BE_FWCMD_NAME(_short_name_), params.response), \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_)));
+
+#define BE_PREPARE_NONEMBEDDED_FWCMD(_pfob_, _wrb_, _iva_, _ipa_, _short_name_)\
+	((struct BE_FWCMD_NAME(_short_name_) *)				\
+	be_function_prepare_nonembedded_fwcmd(_pfob_, _wrb_, (_iva_), (_ipa_), \
+		sizeof(struct BE_FWCMD_NAME(_short_name_)),		\
+		SA_SIZEOF_FIELD(BE_FWCMD_NAME(_short_name_), params.request), \
+		SA_SIZEOF_FIELD(BE_FWCMD_NAME(_short_name_), params.response), \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_)));
+/*
+ * ----------------------------------------------------------------------
+ *   API Inline Functions
+ * ----------------------------------------------------------------------
+ * Returns TRUE for the ISCSI function
+ */
+static inline bool
+be_function_is_iscsi(struct be_function_object *pfob)
+{
+	return (pfob->type == BE_FUNCTION_TYPE_ISCSI);
+}
+
+/* Returns TRUE for the networking function */
+static inline bool
+be_function_is_networking(struct be_function_object *pfob)
+{
+	return (pfob->type == BE_FUNCTION_TYPE_NETWORK);
+}
+
+static inline void
+be_function_copy_stats(struct be_function_object *pfob,
+		       struct beclib_function_stats *stats)
+{
+	memcpy(stats, &pfob->stats, (size_t)sizeof(pfob->stats));
+
+}
+
+/* Returns a pointer to the parent chip object for this function. */
+static inline struct be_chip_object *
+be_function_get_chip_object(struct be_function_object *pfob)
+{
+	return pfob->parent_chip;
+}
+
+#endif /* __beclib_lower__ */
diff --git a/drivers/message/beclib/beclib_private_ll.h b/drivers/message/beclib/beclib_private_ll.h
new file mode 100644
index 0000000..b70d8cc
--- /dev/null
+++ b/drivers/message/beclib/beclib_private_ll.h
@@ -0,0 +1,298 @@
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
+#ifndef __beclib_private_h__
+#define __beclib_private_h__
+
+/*
+ * ------------------------------------------------------
+ * Chip Object
+ * ------------------------------------------------------
+ */
+
+void be_chip_lock(struct be_chip_object *chip_object);
+void be_chip_unlock(struct be_chip_object *chip_object);
+
+/*
+ * ------------------------------------------------------
+ *  Function Object
+ * ------------------------------------------------------
+ */
+
+/* Init function object. */
+BESTATUS be_function_create(struct sa_dev *sa_dev,
+			u32 function_type,	/* e.g FUNCTION_TYPE_ISCSI */
+			struct sa_sgl *mailbox_sgl,
+			struct be_function_object *pfob);
+
+/* Creates one chip object. */
+BESTATUS be_chip_create(struct be_chip_object *chip);
+
+/*
+ * Inserts the function object into the chip object.  Both must be previously
+ * created.  This function will initialize the chip during emulation.
+ */
+BESTATUS
+be_chip_insert_function_object(struct be_chip_object *chip_object,
+			       struct be_function_object *pfob);
+
+/*
+ * Cleans up the chip object.
+ * This function is called as part of be_function_cleanup.
+ */
+void be_chip_destroy(struct be_chip_object *chip);
+
+/*
+ * Destroys the function object.  This assumes that all resources for
+ * this function have already been destroy, and it asserts if that
+ * is not true.
+ * This function is called as part of be_function_cleanup.
+ */
+BESTATUS be_function_destroy(struct be_function_object *pfob);
+
+/*
+ * Removes the function object from the chip.
+ * This function is called as part of be_function_cleanup.
+ */
+void
+be_chip_remove_function_object(struct be_chip_object *chip_object,
+			       struct be_function_object *pfob);
+
+void _be_function_lock(struct be_function_object *fo);
+void _be_function_unlock(struct be_function_object *fo);
+
+void _be_function_add_eq(struct be_function_object *fo,
+				struct be_eq_object *eq_object);
+void _be_function_remove_eq(struct be_function_object *fo,
+			    struct be_eq_object *eq_object);
+
+void _be_function_add_cq(struct be_function_object *fo,
+					struct be_cq_object *cq_object);
+void _be_function_remove_cq(struct be_function_object *fo,
+			    struct be_cq_object *cq_object);
+
+void _be_function_add_eth_sq(struct be_function_object *fo,
+			     struct be_ethsq_object *eth_sq);
+void _be_function_remove_eth_sq(struct be_function_object *fo,
+				struct be_ethsq_object *eth_sq);
+
+void _be_function_add_eth_rq(struct be_function_object *fo,
+			     struct be_ethrq_object *eth_rq);
+void _be_function_remove_eth_rq(struct be_function_object *fo,
+				struct be_ethrq_object *eth_rq);
+
+void _be_function_add_mcc(struct be_function_object *fo,
+					struct be_mcc_object *mcc);
+void _be_function_remove_mcc(struct be_function_object *fo,
+					struct be_mcc_object *mcc);
+
+
+BESTATUS
+be_function_ring_destroy(struct be_function_object *pfob,
+			 u32 id, u32 ring_type);
+
+BESTATUS
+be_function_ring_destroy_async(struct be_function_object *pfob,
+		       u32 id, u32 ring_type, MCC_WRB_CQE_CALLBACK callback,
+		       void *callback_context,
+		       MCC_WRB_CQE_CALLBACK internal_callback,
+		       void *internal_callback_context);
+
+#define BE_CREATE_MCC_RESPONSE_COPY(_fwcmd_type_, _field_, _va_)           \
+	be_create_mcc_response_copy(SA_FIELD_OFFSET(_fwcmd_type_, _field_),  \
+		SA_SIZEOF_FIELD(_fwcmd_type_, _field_),  (_va_))	\
+
+static inline
+struct be_mcc_wrb_response_copy
+be_create_mcc_response_copy(u16 offset, u16 length, void *va)
+{
+	struct be_mcc_wrb_response_copy rc;
+	rc.length = length;
+	rc.fwcmd_offset = offset;
+	rc.va = va;
+	return rc;
+}
+
+BESTATUS
+be_function_post_mcc_wrb_with_queue_context(struct be_function_object
+		*pfob, struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		void *optional_fwcmd_va);
+
+BESTATUS
+be_function_post_mcc_wrb_with_copy(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		void *optional_fwcmd_va,
+		struct be_mcc_wrb_response_copy response_copy);
+
+BESTATUS
+be_function_post_mcc_wrb_with_internal_callback(
+		struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context,
+		void *optional_fwcmd_va);
+
+BESTATUS
+be_function_post_mcc_wrb_complete(struct be_function_object *pfob,
+		struct MCC_WRB_AMAP *wrb,
+		struct be_generic_queue_context *queue_context,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		MCC_WRB_CQE_CALLBACK internal_callback,
+		void *internal_callback_context, void *optional_fwcmd_va,
+		struct be_mcc_wrb_response_copy response_copy);
+
+/* Returns the protection domain number. 0 is host. */
+u32 be_function_get_pd_number(struct be_function_object *pfob);
+
+bool be_function_is_vm(struct be_function_object *pfob);
+
+BESTATUS
+be_function_queue_mcc_wrb(struct be_function_object *pfob,
+			  struct be_generic_queue_context *queue_context);
+
+BESTATUS
+be_function_internal_query_firmware_config(struct be_function_object *pfob,
+			struct BE_FIRMWARE_CONFIG *config);
+
+/*
+ * ------------------------------------------------------
+ *  Event Queue
+ * ------------------------------------------------------
+ */
+
+void _be_eq_add_cq(struct be_eq_object *eq_object,
+				struct be_cq_object *cq_object);
+void _be_eq_remove_cq(struct be_eq_object *eq_object,
+				struct be_cq_object *cq_object);
+/*
+ * ------------------------------------------------------
+ *  Completion Queue Object
+ * ------------------------------------------------------
+ */
+
+void be_cq_object_reference(struct be_cq_object *cq_object);
+
+void be_cq_object_dereference(struct be_cq_object *cq_object);
+
+/*
+ * ------------------------------------------------------
+ *  MCC QUEUE
+ * ------------------------------------------------------
+ */
+
+BESTATUS
+be_mpu_init_mailbox(struct be_function_object *pfob, struct sa_sgl *mailbox);
+
+BESTATUS be_mpu_uninit_mailbox(struct be_function_object *pfob);
+
+struct MCC_WRB_AMAP *
+_be_mpu_peek_ring_wrb(struct be_mcc_object *mcc, bool driving_queue);
+
+struct be_mcc_wrb_context *
+_be_mcc_allocate_wrb_context(struct be_function_object *pfob);
+
+void
+_be_mcc_free_wrb_context(struct be_function_object *pfob,
+			 struct be_mcc_wrb_context *context);
+
+BESTATUS
+_be_mpu_post_wrb_mailbox(struct be_function_object *pfob,
+	 struct MCC_WRB_AMAP *wrb, struct be_mcc_wrb_context *wrb_context);
+
+BESTATUS
+_be_mpu_post_wrb_ring(struct be_mcc_object *mcc,
+	struct MCC_WRB_AMAP *wrb, struct be_mcc_wrb_context *wrb_context);
+
+void
+be_mcc_process_cqe(struct be_function_object *pfob,
+		   struct MCC_CQ_ENTRY_AMAP *cqe);
+
+u32 be_mcc_get_id(struct be_mcc_object *mcc);
+
+void be_drive_mcc_wrb_queue(struct be_mcc_object *mcc);
+
+
+/*
+ * ------------------------------------------------------
+ *  Ring Sizes
+ * ------------------------------------------------------
+ */
+static inline u32 be_ring_encoding_to_length(u32 encoding, u32 object_size)
+{
+
+	ASSERT(encoding != 1);	/* 1 is rsvd */
+	ASSERT(encoding < 16);
+	ASSERT(object_size > 0);
+
+	if (encoding == 0)	/* 32k deep */
+		encoding = 16;
+
+	return (1 << (encoding - 1)) * object_size;
+}
+
+static inline
+u32 be_ring_length_to_encoding(u32 length_in_bytes, u32 object_size)
+{
+
+	u32 count, encoding;
+
+	ASSERT(object_size > 0);
+	ASSERT(length_in_bytes % object_size == 0);
+
+	count = length_in_bytes / object_size;
+
+	ASSERT(count > 1);
+	ASSERT(count <= 32 * 1024);
+	ASSERT(length_in_bytes <= 8 * SA_PAGE_SIZE); /* max ring size in UT */
+
+	encoding = sa_log2(count) + 1;
+
+	if (encoding == 16)
+		encoding = 0;	/* 32k deep */
+
+	return encoding;
+}
+
+/*
+ * ------------------------------------------------------
+ *  Locking
+ * ------------------------------------------------------
+ */
+
+static inline void be_lock_wrb_post(struct be_function_object *pfob)
+{
+	spin_lock_irqsave(&pfob->post_lock, pfob->post_irq);
+}
+
+static inline void be_unlock_wrb_post(struct be_function_object *pfob)
+{
+	spin_unlock_irqrestore(&pfob->post_lock, pfob->post_irq);
+
+	if (pfob->pend_queue_driving && pfob->links.mcc) {
+		pfob->pend_queue_driving = 0;
+		pfob->stats.pended_queue_driving++;
+		be_drive_mcc_wrb_queue(pfob->links.mcc);
+	}
+}
+void be_sgl_to_pa_list(struct sa_sgl *sgl, struct PHYS_ADDR *pa_list,
+						u32 max_num);
+#endif /* __beclib_private_h__ */
diff --git a/drivers/message/beclib/beclib_stats.h b/drivers/message/beclib/beclib_stats.h
new file mode 100644
index 0000000..3fc75bd
--- /dev/null
+++ b/drivers/message/beclib/beclib_stats.h
@@ -0,0 +1,54 @@
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
+#ifndef __beclib_stats_h__
+#define __beclib_stats_h__
+
+struct beclib_function_stats {
+	union {
+		u32 dw[32];	/* Reserve space for a fixed number of stats. */
+		struct {
+			u32 mailbox_wrbs;
+			u32 emulated_wrbs;
+
+			/* Pertain to WRBs posted to ring only */
+			u32 synchronous_wrbs;
+			u32 posted_wrbs;
+			u32 consumed_wrbs;
+			u32 completed_wrbs;
+
+			/* SW queueing */
+			u32 queued_wrbs;
+			u32 queue_length;
+			u32 max_queue_length;
+			u32 pended_queue_driving;
+
+			/* MCC CQ */
+			u32 processed_cq;
+			u32 cq_entries;
+			u32 async_events;
+			u32 ignored_async_events;
+
+			/* Locks */
+			u32 post_lock_acquires;
+			u32 cq_lock_acquires;
+			u64 post_lock_ticks;
+			u64 cq_lock_ticks;
+		};
+	};
+} ;
+
+#endif /* __beclib_stats_h__ */
diff --git a/drivers/message/beclib/beregister.h b/drivers/message/beclib/beregister.h
new file mode 100644
index 0000000..fc1d22b
--- /dev/null
+++ b/drivers/message/beclib/beregister.h
@@ -0,0 +1,367 @@
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
+#ifndef __BEREGISTER_H__
+#define __BEREGISTER_H__
+
+/*
+
+@brief
+    This macro zeros out a data structure whose contents happen to be
+    exactly 32-bits. Many controller registers have bit map structures
+    defined to represent them and this routine allows for easy and correct
+    initialization of the register to 0.
+
+@param
+    reg         - Pointer to the 32-bit structure to zero out.
+
+@return
+
+@note
+    IRQL: any
+
+*/
+
+/* The order in which the three PCI BAR detailas are stored in sa_dev */
+enum SA_DEV_BAR_TYPE {
+	SA_BAR_TYPE_CSR = 0,
+	SA_BAR_TYPE_PD,
+	SA_BAR_TYPE_PCI,
+	SA_BAR_TYPE_MAX
+} ;
+
+/*
+ * MemOrIOMapped has the following two values
+ * for reference purpose
+ */
+enum SA_DEV_MAPPED_TYPE {
+	SA_IO_MAPPED = 0x01,
+	SA_MEM_MAPPED = 0x02
+} ;
+
+struct sa_dev_bar_locations {
+	u8 __iomem *base_va;	/* Virtual Address */
+	u64 base_pa;		/* Physical Address */
+	u32 length;		/* Length of register space */
+} ;
+
+#define SA_DEV_MAX_BARS (8)
+/*
+ * Context structure passed to create the device object.
+ */
+/*
+ * Device Object
+ */
+struct sa_dev {
+	u32 num_bars;
+	struct sa_dev_bar_locations bars[SA_DEV_MAX_BARS];
+} ;
+
+#include <linux/delay.h>
+
+static inline SA_STATUS sa_dev_create(struct sa_dev_bar_locations *bars,
+		u32 num_bars, void *os_handle, struct sa_dev *dev)
+{
+	ASSERT(dev);
+	ASSERT(bars);
+
+	/* Zero the struct */
+	memset(dev, 0, sizeof(*dev));
+
+	/* Copy the bar info */
+	dev->num_bars = num_bars;
+	memcpy(dev->bars, bars, sizeof(struct sa_dev_bar_locations) * num_bars);
+
+	return SA_SUCCESS;
+}
+
+static inline void sa_dev_destroy(struct sa_dev *dev)
+{
+	memset(dev, 0, sizeof(*dev));
+}
+
+static inline u32 sa_dev_read_u32(struct sa_dev *dev, u32 bar, u32 offset)
+{
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	return ioread32(dev->bars[bar].base_va + offset);
+}
+
+static inline void sa_dev_write_u32(struct sa_dev *dev, u32 bar,
+			u32 offset, u32 value)
+{
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	iowrite32(value, dev->bars[bar].base_va + offset);
+}
+
+static inline void sa_dev_stall(struct sa_dev *dev, u32 us_to_stall)
+{
+	udelay(us_to_stall);
+}
+/*
+ *
+ * Macros for reading/writing a protection domain or CSR registers
+ * in BladeEngine.
+ */
+#define PD_READ(_fo_, _field_)     				\
+	BePdRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PROTECTION_DOMAIN_DBMAP, _field_),	\
+	SA_DBG_CSTR(#_field_))
+
+#define PD_WRITE(_fo_, _field_, _value_)			\
+	BePdWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PROTECTION_DOMAIN_DBMAP, _field_),	\
+	(_value_).dw[0], SA_DBG_CSTR(#_field_))
+
+#define PD_WRITE_CONST(_fo_, _field_, _value_)			\
+	BePdWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PROTECTION_DOMAIN_DBMAP, _field_),	\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define CSR_READ(_fo_, _field_)				\
+	BeCsrRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(BLADE_ENGINE_CSRMAP, _field_),	\
+	SA_DBG_CSTR(#_field_))				\
+
+#define CSR_WRITE(_fo_, _field_, _value_)			\
+	BeCsrWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(BLADE_ENGINE_CSRMAP, _field_),	\
+	(_value_).dw, SA_DBG_CSTR(#_field_))
+
+#define CSR_WRITE_CONST(_fo_, _field_, _value_)		\
+	BeCsrWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(BLADE_ENGINE_CSRMAP, _field_),	\
+	 (_value_), SA_DBG_CSTR(#_field_))
+/*
+ *
+ * Macros for reading/writing a protection domain or
+ * CSR registers in BladeEngine.
+ */
+#define PCICFG0_READ(_fo_, _field_)				\
+	BePciCfgRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG0_CSRMAP, _field_),		\
+	SA_DBG_CSTR(#_field_))
+
+
+#define PCICFG0_WRITE(_fo_, _field_, _value_)                  \
+	BePciCfgWrite((_fo_)->sa_dev,                           \
+	AMAP_BYTE_OFFSET(PCICFG0_CSRMAP, _field_),             \
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define PCICFG0_WRITE_CONST(_fo_, _field_, _value_)		\
+	BePciCfgWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG0_CSRMAP, _field_),		\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define PCICFG1_READ(_fo_, _field_)				\
+	BePciCfgRead((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG1_CSRMAP, _field_),		\
+	SA_DBG_CSTR(#_field_))
+
+#define PCICFG1_WRITE_CONST(_fo_, _field_, _value_)		\
+	BePciCfgWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG1_CSRMAP, _field_),		\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define PCICFG1_WRITE(_fo_, _field_, _value_)			\
+	BePciCfgWrite((_fo_)->sa_dev,				\
+	AMAP_BYTE_OFFSET(PCICFG1_CSRMAP, _field_),		\
+	(_value_), SA_DBG_CSTR(#_field_))
+
+#define RXULP_PD_WRITE(_function_object_, _ulp_number_, _value_)	\
+	switch (_ulp_number_) {						\
+	case 0:								\
+		PD_WRITE((_function_object_), iscsi_default_pdu_db,	\
+			(_value_));					\
+		break;							\
+	case 1:								\
+		PD_WRITE((_function_object_), rdma_rq_db, (_value_));	\
+		break;							\
+	case 2:								\
+		PD_WRITE((_function_object_), tpm_rq_db, (_value_));	\
+		break;							\
+	default:							\
+		BREAKPOINT();						\
+    }									\
+
+
+#define TXULP_PD_WRITE(_function_object_, _ulp_number_, _value_)	\
+	switch (_ulp_number_) {						\
+	case 0:								\
+		PD_WRITE((_function_object_), iscsi_wrb_post_db, (_value_)); \
+		break;							\
+	case 1:								\
+		PD_WRITE((_function_object_), rdma_sq_db, (_value_));	\
+		break;							\
+	case 2:								\
+		PD_WRITE((_function_object_), etx_sq_db, (_value_));	\
+		break;							\
+	default:							\
+		BREAKPOINT();						\
+	    }								\
+
+/*
+    This routine reads from a register located within the protection domain
+    doorbell space for a given function object.
+
+    FuncObj     - Pointer to the function object to read from.
+
+    Offset      - The Offset(in bytes) to read from within the
+			function's PD space.
+
+    Returns the value read.
+
+    IRQL: any
+
+*/
+static inline u32
+BePdRead(struct sa_dev *sa_dev, u32 offset, const char *dbg_name)
+{
+	u32 v;
+
+	v = sa_dev_read_u32(sa_dev, SA_BAR_TYPE_PD, offset);
+	return v;
+}
+
+/*
+    This routine writes to a register located within the protection domain
+    doorbell space for a given function object.
+
+    FuncObj     - Pointer to the function object to read from.
+
+    Offset      - The Offset (in bytes) to write to within the
+			function's PD space.
+
+    Value       - The value to write to the register.
+
+    IRQL: any
+
+*/
+static inline void
+BePdWrite(struct sa_dev *sa_dev,
+	  u32 offset, u32 value, const char *dbg_name)
+{
+	ASSERT(offset < sizeof(struct PROTECTION_DOMAIN_DBMAP_AMAP));
+
+	TRACE(DL_HW, "PD Write. offset:0x%04x value:0x%08x (%s)", offset,
+	      value, dbg_name);
+	sa_dev_write_u32(sa_dev, SA_BAR_TYPE_PD, offset, value);
+}
+
+/*
+    This routine reads from a register located within the CSR space for a
+    given function object.
+
+    sa_dev - Context for this set of register space
+
+    Offset          - The Offset (in bytes) to read from within
+			the function's CSR space.
+
+    The value read.
+
+    IRQL: any
+
+*/
+static inline u32
+BeCsrRead(struct sa_dev *sa_dev, u32 offset, const char *dbg_name)
+{
+	u32 value;
+
+	value = sa_dev_read_u32(sa_dev, SA_BAR_TYPE_CSR, offset);
+	return value;
+}
+
+/*
+    This routine writes to a register located within the CSR
+    space for a given function object.
+
+    sa_dev - Context for this set of register space
+
+    Offset          - The Offset (in bytes) to write to within
+			the function's CSR space.
+
+    Value           - The value to write to the register.
+
+    IRQL: any
+
+*/
+static inline void
+BeCsrWrite(struct sa_dev *sa_dev,
+	   u32 offset, u32 value, const char *dbg_name)
+{
+	ASSERT(offset < sizeof(struct BLADE_ENGINE_CSRMAP_AMAP));
+
+	TRACE(DL_HW, "CSR Write. offset:0x%04x value:0x%08x (%s)", offset,
+	      value, dbg_name);
+
+	sa_dev_write_u32(sa_dev, SA_BAR_TYPE_CSR, offset, value);
+}
+
+/*
+    This routine reads from a register located within the pci cfg
+    space for a given function object.
+
+    sa_dev - Context for this set of register space
+
+    Offset          - The Offset (in bytes) to read from within
+			the function's pci cfg space.
+    The value read.
+
+    IRQL: any
+
+*/
+static inline u32
+BePciCfgRead(struct sa_dev *sa_dev, u32 offset, const char *dbg_name)
+{
+	u32 value;
+
+	value = sa_dev_read_u32(sa_dev, SA_BAR_TYPE_PCI, offset);
+	return value;
+}
+
+/*
+    This routine writes to a register located within the pci cfg
+    space for a given function object.
+
+    sa_dev - Context for this set of register space
+
+    Offset          - The Offset (in bytes) to write to within
+		the function's pci cfg space.
+
+    Value           - The value to write to the register.
+
+
+    IRQL: any
+
+*/
+static inline void
+BePciCfgWrite(struct sa_dev *sa_dev,
+	      u32 offset, u32 value, const char *dbg_name)
+{
+
+	ASSERT(offset < sizeof(struct BLADE_ENGINE_CSRMAP_AMAP));
+
+	TRACE(DL_HW, "PCICFG Write. offset:0x%04x value:0x%08x (%s)",
+	      offset, value, dbg_name);
+
+	sa_dev_write_u32(sa_dev, SA_BAR_TYPE_PCI, offset, value);
+
+}
+
+#endif /* __BEREGISTER_H__ */
diff --git a/drivers/message/beclib/bestatus.h b/drivers/message/beclib/bestatus.h
new file mode 100644
index 0000000..a714b08
--- /dev/null
+++ b/drivers/message/beclib/bestatus.h
@@ -0,0 +1,103 @@
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
+#ifndef _BESTATUS_H_
+#define _BESTATUS_H_
+
+#define BE_SUCCESS                      ((SA_STATUS)0x00000000L)
+/*
+ * MessageId: BE_PENDING
+ *  The BladeEngine Driver call succeeded, and pended operation.
+ */
+#define BE_PENDING                       ((SA_STATUS)0x20070001L)
+#define BE_STATUS_PENDING                (BE_PENDING)
+/*
+ * MessageId: BE_NOT_OK
+ *  An error occurred.
+ */
+#define BE_NOT_OK                        ((SA_STATUS)0xE0070002L)
+/*
+ * MessageId: BE_STATUS_SYSTEM_RESOURCES
+ *  Insufficient host system resources exist to complete the API.
+ */
+#define BE_STATUS_SYSTEM_RESOURCES       ((SA_STATUS)0xE0070003L)
+/*
+ * MessageId: BE_STATUS_CHIP_RESOURCES
+ *  Insufficient chip resources exist to complete the API.
+ */
+#define BE_STATUS_CHIP_RESOURCES         ((SA_STATUS)0xE0070004L)
+/*
+ * MessageId: BE_STATUS_NO_RESOURCE
+ *  Insufficient resources to complete request.
+ */
+#define BE_STATUS_NO_RESOURCE            ((SA_STATUS)0xE0070005L)
+/*
+ * MessageId: BE_STATUS_BUSY
+ *  Resource is currently busy.
+ */
+#define BE_STATUS_BUSY                   ((SA_STATUS)0xE0070006L)
+/*
+ * MessageId: BE_STATUS_INVALID_PARAMETER
+ *  Invalid Parameter in request.
+ */
+#define BE_STATUS_INVALID_PARAMETER      ((SA_STATUS)0xE0000007L)
+/*
+ * MessageId: BE_STATUS_NOT_SUPPORTED
+ *  Requested operation is not supported.
+ */
+#define BE_STATUS_NOT_SUPPORTED          ((SA_STATUS)0xE000000DL)
+
+/*
+ * ***************************************************************************
+ *                     E T H E R N E T   S T A T U S
+ * ***************************************************************************
+ */
+
+/*
+ * MessageId: BE_ETH_TX_ERROR
+ *  The Ethernet device driver failed to transmit a packet.
+ */
+#define BE_ETH_TX_ERROR                  ((SA_STATUS)0xE0070101L)
+
+/*
+ * ***************************************************************************
+ *                     S H A R E D   S T A T U S
+ * ***************************************************************************
+ */
+
+/*
+ * MessageId: BE_STATUS_VBD_INVALID_VERSION
+ *  The device driver is not compatible with this version of the VBD.
+ */
+#define BE_STATUS_INVALID_VERSION    ((SA_STATUS)0xE0070402L)
+/*
+ * MessageId: BE_STATUS_DOMAIN_DENIED
+ *  The operation failed to complete due to insufficient access
+ *  rights for the requesting domain.
+ */
+#define BE_STATUS_DOMAIN_DENIED          ((SA_STATUS)0xE0070403L)
+/*
+ * MessageId: BE_STATUS_TCP_NOT_STARTED
+ *  The embedded TCP/IP stack has not been started.
+ */
+#define BE_STATUS_TCP_NOT_STARTED        ((SA_STATUS)0xE0070409L)
+/*
+ * MessageId: BE_STATUS_NO_MCC_WRB
+ *  No free MCC WRB are available for posting the request.
+ */
+#define BE_STATUS_NO_MCC_WRB                 ((SA_STATUS)0xE0070414L)
+
+#endif /* _BESTATUS_ */
diff --git a/drivers/message/beclib/pch.h b/drivers/message/beclib/pch.h
new file mode 100644
index 0000000..cdea315
--- /dev/null
+++ b/drivers/message/beclib/pch.h
@@ -0,0 +1,35 @@
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
+/*
+    Each .c file in beclib includes this "precompiled header" file.
+    It should ONLY be included by beclib files.
+    Clients of beclib should include "beclib.h" instead.
+*/
+#ifndef __pch_h__
+#define __pch_h__
+
+/*
+ * -----------------------------------------------------------------------
+ *    Our custom includes
+ * -----------------------------------------------------------------------
+ */
+
+#include "beclib_ll.h"
+#include "beclib_private_ll.h"
+#include "bestatus.h"
+
+#endif /* __pch_h__ */
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

