From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 4/15] BE NIC driver - beclib (h/w access lib) headers
Date: Thu, 15 May 2008 02:14:39 -0700
Message-ID: <20080515091439.31df9cc3@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.245.99]:12287 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbYEOJKC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:10:02 -0400
Received: from 124.30.166.146 ([124.30.166.146])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Thu, 15 May 2008 02:14:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/beclib_common.h      |   95 ++
 drivers/message/beclib/beclib_ll.h          |  675 +++++++++++
 drivers/message/beclib/beclib_ll_bmap_nic.h | 1667 +++++++++++++++++++++++++++
 drivers/message/beclib/beclib_ll_enum_nic.h |   63 +
 4 files changed, 2500 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/beclib_common.h
 create mode 100644 drivers/message/beclib/beclib_ll.h
 create mode 100644 drivers/message/beclib/beclib_ll_bmap_nic.h
 create mode 100644 drivers/message/beclib/beclib_ll_enum_nic.h

diff --git a/drivers/message/beclib/beclib_common.h b/drivers/message/beclib/beclib_common.h
new file mode 100644
index 0000000..2f04f6e
--- /dev/null
+++ b/drivers/message/beclib/beclib_common.h
@@ -0,0 +1,95 @@
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
+#ifndef __beclib_common_h__
+#define __beclib_common_h__
+
+#include "sa.h"
+
+#if !defined(BE_CONFIG)
+#define BE_CONFIG 0
+#define CONFIG0
+#endif
+
+/*Id ranges and RID conversions based on config */
+#include "be_gen_id_ranges.h"
+
+/* Srcgen includes */
+
+#include "regmap.h"		/* srcgen array map output */
+#include "host_struct.h"	/* srcgen array map output */
+#include "ioctl_top.h"		/* srcgen array map output */
+
+#include "host_struct_bmap.h"	/* srcgen bitmap output */
+#include "ioctl_top_bmap.h"	/* srcgen bitmap output */
+
+#include "bestatus.h"
+
+/* Debug trace categories. */
+enum BE_DEBUG_LEVELS {
+	DL_HW = 0x00000100,
+	DL_IOCTL = 0x00000200,
+
+	BE_DL_MIN_VALUE = 0x100,	/* this is the min value used */
+	BE_DL_MAX_VALUE = 0x800	/* this is the higheset value used */
+} ;
+
+SA_GLOBAL_C_ASSERT(beclib_debug_level_range,
+		   ((u32) BE_DL_MIN_VALUE > (u32) SA_DL_MAX_VALUE));
+
+#include "beregister.h"	/* Macros for register access using srcgen structs */
+#include "beclib_stats.h"
+
+/*  BECLIB status data type maps to the SA_STATUS */
+typedef SA_STATUS BESTATUS, *PBESTATUS;
+
+/* BECLIB calling convention.  Use default currently. */
+#define BECALL
+
+/* Forward declarations. */
+struct BE_FUNCTION_OBJECT;
+struct BE_EQ_OBJECT;
+struct BE_CQ_OBJECT;
+
+/* Callback types.  Deprecate most of these. */
+typedef void (BECALL *MCC_WRB_CQE_CALLBACK) (void *context,
+				BESTATUS status,
+				struct MCC_WRB_AMAP *optional_wrb);
+typedef void (BECALL *MCC_ASYNC_EVENT_CALLBACK) (void *context,
+				u32 event_code,
+				void *event);
+
+typedef BESTATUS(*EQ_CALLBACK) (struct BE_FUNCTION_OBJECT *,
+				struct BE_EQ_OBJECT *, void *context);
+typedef BESTATUS(*CQ_CALLBACK) (struct BE_FUNCTION_OBJECT *,
+				struct BE_CQ_OBJECT *, void *context);
+
+#endif /* __beclib_common_h__ */
diff --git a/drivers/message/beclib/beclib_ll.h b/drivers/message/beclib/beclib_ll.h
new file mode 100644
index 0000000..2f45619
--- /dev/null
+++ b/drivers/message/beclib/beclib_ll.h
@@ -0,0 +1,675 @@
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
+#ifndef __beclib_lower_h__
+#define __beclib_lower_h__
+
+#include "beclib_common.h"	/* High and low level API commonalities */
+
+/*!
+@brief
+    Internal memory descriptor for memory shared by both the host driver and
+    the controller
+*/
+struct BE_SHARED_MEM_DESCRIPTOR {
+	void *va;		/*! virtual address */
+	struct SA_SGL *sgl;		/*! memory descriptor list */
+	u32 tag;		/*! memory tracking tag */
+} ;
+
+/*!
+@brief
+    Locking structure for beklib.
+*/
+struct BE_LOCK {
+	SA_SPINLOCK lock;
+	SA_IRQ irql;
+} ;
+
+/*!
+@brief
+    Represents a Blade Engine chip. This is used to manage
+    global chip resources.  Only the ARM uses this from the low
+    level API.
+*/
+struct BE_CHIP_OBJECT {
+	u32 magic;
+	u32 ref_count;
+	struct BE_LOCK lock;
+	SA_LIST_ENTRY function_list_head;
+
+} ;
+
+struct BE_MCC_WRB_RESPONSE_COPY {
+	u16 length;		/* bytes in response */
+	u16 ioctl_offset;	/* offset within the wrb of the response */
+	void *va;		/* user's va to copy response into */
+
+} ;
+
+struct BE_MCC_WRB_CONTEXT {
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
+	SA_LIST_ENTRY next;	/* links context structs together in
+				   free list */
+
+	struct BE_MCC_WRB_RESPONSE_COPY copy;	/* Optional parameters to copy
+					   embedded response to user's va */
+
+#if defined(SA_DEBUG)
+	u16 subsystem, opcode;	/* Track this IOCTL for debug builds. */
+	struct MCC_WRB_AMAP *ring_wrb;
+	u32 consumed_count;
+#endif
+} ;
+
+/*!
+@brief
+    Represents a function object for network or storage.  This
+    is used to manage per-function resources like MCC CQs, etc.
+*/
+struct BE_FUNCTION_OBJECT {
+
+	u32 magic;		/*!< magic for detecting memory corruption. */
+	struct BE_CHIP_OBJECT *parent_chip;
+
+	/*
+	 *! Generic system abstraction (SA) device object for accessing
+	 * registers, physical memory, etc.
+	 */
+	struct SA_DEV *sa_dev;
+
+	u32 emulate;		/* if set, MPU is not available.
+				  Emulate everything.     */
+	u32 pend_queue_driving;	/* if set, drive the queued WRBs
+				   after releasing the WRB lock */
+
+	SA_SPINLOCK post_lock;	/* lock for verifying one thread posting wrbs */
+	SA_SPINLOCK cq_lock;	/* lock for verifying one thread
+				   processing cq */
+	SA_SPINLOCK mcc_context_lock;	/* lock for protecting mcc
+					   context free list */
+	SA_IRQ post_irq;
+	SA_IRQ cq_irq;
+
+	u32 ref_count;		/*!< number obejcts referencing this funcobj */
+	struct BE_LOCK lock;		/*!< synchronization lock         */
+	u32 type;
+	u32 pci_function_number;
+
+	SA_LIST_ENTRY function_list;	/*!< for linking these objects
+					  together */
+
+	struct {
+		SA_LIST_ENTRY pd_list_head;	/* protection domain list */
+		SA_LIST_ENTRY cq_list_head;	/* completion queue list */
+		SA_LIST_ENTRY eq_list_head;	/* event queue list     */
+		SA_LIST_ENTRY cxn_list_head;	/* list of active
+						   connections */
+		SA_LIST_ENTRY eth_sq_list_head;	/* list of ethernet
+						   send rings */
+		SA_LIST_ENTRY eth_rq_list_head;	/* list of ether RX rings */
+		SA_LIST_ENTRY rdma_qp_list_head;	/* queue pair list */
+
+		struct BE_MCC_OBJECT *mcc;	/* mcc rings. */
+		struct BE_PD_OBJECT *pd_object; /* perceived PD 0 */
+
+		union {
+			struct {
+				SA_LIST_ENTRY wrbq_list_head;
+				SA_LIST_ENTRY defq_list_head;
+			} iscsi;
+
+			struct {
+				SA_LIST_ENTRY dq_list_head;
+				SA_LIST_ENTRY sq_list_head;
+				SA_LIST_ENTRY rq_list_head;
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
+		struct BE_MCC_WRB_CONTEXT default_context;
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
+	SA_IRQ current_irql;
+
+	struct BE_FIRMWARE_CONFIG fw_config;
+	struct BECLIB_FUNCTION_STATS stats;
+
+} ;
+
+/*!
+@brief
+    Represents a protection domain
+*/
+struct BE_PD_OBJECT {
+	u32 magic;
+	u32 ref_count;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+	SA_LIST_ENTRY pd_list;
+
+	u32 pd_id;
+	u8 *pd_page_va;
+	u64 pd_page_pa;
+
+} ;
+
+/*!
+  @brief
+      Represents an Event Queue
+*/
+struct BE_EQ_OBJECT {
+	u32 magic;
+	u32 ref_count;
+	struct BE_LOCK lock;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+
+	SA_LIST_ENTRY eq_list;
+	SA_LIST_ENTRY cq_list_head;
+
+	u32 eq_id;
+	EQ_CALLBACK callback;
+	void *callback_context;
+
+} ;
+
+/*!
+@brief
+    Manages a completion queue
+*/
+struct BE_CQ_OBJECT {
+	u32 magic;
+	u32 ref_count;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+	struct BE_EQ_OBJECT *eq_object;
+
+	SA_LIST_ENTRY cq_list;
+	SA_LIST_ENTRY cqlist_for_eq;
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
+/*!
+@brief
+    Manages an ethernet send queue
+*/
+struct BE_ETHSQ_OBJECT {
+	u32 magic;
+
+	SA_LIST_ENTRY list;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+	struct BE_CQ_OBJECT *cq_object;
+	u32 bid;
+
+} ;
+
+/*!
+@brief
+    Manages an ethernet receive queue
+*/
+struct BE_ETHRQ_OBJECT {
+	u32 magic;
+	SA_LIST_ENTRY list;
+	struct BE_FUNCTION_OBJECT *parent_function;
+	u32 rid;
+	struct BE_CQ_OBJECT *cq_object;
+	struct BE_CQ_OBJECT *rss_cq_object[4];
+
+} ;
+
+/*!
+@brief
+    Manages an MCC
+*/
+struct BE_MCC_OBJECT {
+	u32 magic;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+	SA_LIST_ENTRY mcc_list;
+
+	struct BE_CQ_OBJECT *cq_object;
+
+	/* Async event callback for MCC CQ. */
+	MCC_ASYNC_EVENT_CALLBACK async_callback;
+	void *async_context;
+
+	struct {
+		struct BE_MCC_WRB_CONTEXT *base;
+		u32 num;
+		SA_LIST_ENTRY list_head;
+	} wrb_context;
+
+	struct {
+		struct SA_SGL *sgl;
+		struct BE_SHARED_MEM_DESCRIPTOR sm_descriptor;
+		struct SA_RING ring;
+	} sq;
+
+	struct {
+		struct BE_SHARED_MEM_DESCRIPTOR sm_descriptor;
+		struct SA_RING ring;
+	} cq;
+
+	u32 processing;		/* flag indicating that one thread
+				   is processing CQ */
+	u32 rearm;		/* doorbell rearm setting to make
+				   sure the active processing thread */
+	/* rearms the CQ if any of the threads requested it. */
+
+	SA_LIST_ENTRY backlog;
+	u32 backlog_length;
+	u32 driving_backlog;
+	u32 consumed_index;
+
+} ;
+
+/*!
+@brief
+   Manages an iSCSI default PDU
+*/
+struct BE_DEFAULT_PDU_QUEUE_OBJECT {
+	u32 magic;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+	SA_LIST_ENTRY func_list;
+	struct BE_CQ_OBJECT *cq_object;
+	struct SA_SGL *sgl;
+	u32 rid;
+} ;
+
+struct BE_ISCSI_WRB_QUEUE_OBJECT {
+
+	u32 magic;
+
+	struct BE_FUNCTION_OBJECT *parent_function;
+
+	SA_LIST_ENTRY wrbq_list;
+
+	/*u32 cra, length; */
+	u32 cid;
+	struct SA_SGL *sgl;
+	u32 length;
+
+} ;
+
+/*!
+@brief
+   Manages iSCSI connection resources like CID, WRB ring, etc.
+*/
+struct BE_ISCSI_CONNECTION_OBJECT {
+	u32 magic;
+	struct BE_FUNCTION_OBJECT *parent_function;
+
+	struct BE_CQ_OBJECT *cq;
+	struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq;
+	struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq;
+
+	SA_LIST_ENTRY connection_list;
+} ;
+
+/* Queue context header -- the required software information for
+ * queueing a WRB.
+ */
+struct BE_QUEUE_DRIVER_CONTEXT {
+	MCC_WRB_CQE_CALLBACK internal_callback;	/* Function to call on
+						   completion */
+	void *internal_callback_context;	/* Parameter to pass
+						   to completion function */
+
+	MCC_WRB_CQE_CALLBACK callback;	/* Function to call on completion */
+	void *callback_context;	/* Parameter to pass to completion function */
+
+	struct BE_MCC_WRB_RESPONSE_COPY copy;	/* Optional parameters to copy
+					   embedded response to user's va */
+
+	void *optional_ioctl_va;
+
+	SA_LIST_ENTRY list;
+
+	u32 bytes;
+
+} ;
+
+/*
+ * Common MCC WRB header that all commands require.
+ */
+struct BE_MCC_WRB_HEADER {
+	u8 rsvd[AMAP_BYTE_OFFSET(MCC_WRB, payload)];
+} ;
+SA_GLOBAL_C_ASSERT(queue_header,
+	sizeof(struct BE_MCC_WRB_HEADER) == AMAP_BYTE_OFFSET(MCC_WRB, payload));
+
+/*
+ * All non embedded commands supported by beclib functions only allow
+ * 1 SGE.  This queue context handles them all.
+ */
+struct BE_NONEMBEDDED_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct MCC_SGE_AMAP sge[1];
+} ;
+
+/*
+ * ------------------------------------------------------------------------
+ *  This section contains the specific queue struct for each command.
+ *  The user could always provide a BE_GENERIC_QUEUE_CONTEXT but this is a
+ *  rather large struct.  By using the specific struct, memory consumption
+ *  can be reduced.
+ * ------------------------------------------------------------------------
+ */
+
+struct BE_LINK_STATUS_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_NTWK_LINK_STATUS_QUERY ioctl;
+} ;
+
+struct BE_MULTICAST_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_NTWK_MULTICAST_SET ioctl;
+} ;
+
+struct BE_WAKE_ON_LAN_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_ETH_ACPI_CONFIG ioctl;
+} ;
+
+struct BE_VLAN_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_NTWK_VLAN_CONFIG ioctl;
+} ;
+
+struct BE_PROMISCUOUS_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_ETH_PROMISCUOUS ioctl;
+} ;
+
+struct BE_FORCE_FAILOVER_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_FORCE_FAILOVER ioctl;
+} ;
+
+struct BE_RSS_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_ETH_RSS_CONFIG ioctl;
+} ;
+
+struct BE_NOP_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_NOP ioctl;
+} ;
+
+struct BE_RXF_FILTER_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_NTWK_RX_FILTER ioctl;
+} ;
+
+struct BE_EQ_MODIFY_DELAY_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct IOCTL_COMMON_MODIFY_EQ_DELAY ioctl;
+} ;
+
+/*
+ * The generic context is the largest size that would be required.
+ * It is the software context plus an entire WRB.
+ */
+struct BE_GENERIC_QUEUE_CONTEXT {
+	struct BE_QUEUE_DRIVER_CONTEXT context;
+	struct BE_MCC_WRB_HEADER wrb_header;
+	struct MCC_WRB_PAYLOAD_AMAP payload;
+} ;
+
+SA_GLOBAL_C_ASSERT(generic_queue_context,
+	sizeof(struct BE_GENERIC_QUEUE_CONTEXT) >=
+	  sizeof(struct BE_QUEUE_DRIVER_CONTEXT) + sizeof(struct MCC_WRB_AMAP));
+
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
+/*
+ * These define constant 32-bit values that are stored as the magic
+ * number in each data type.  The magic number is a debugging tool.
+ * In debug mode we use asserts to constantly check the integrity
+ * of the magic value, which spots double frees and some memory corruption.
+ * In release mode, the magic value can be used for post-mortem
+ * debugging without symbols to locate data types in memory -- this is
+ * easier using 4 character strings.
+ */
+#define BE_CHIP_MAGIC			SA_TAG("beco")
+#define BE_FUNCTION_MAGIC		SA_TAG("befo")
+#define BE_PD_MAGIC			SA_TAG("bepd")
+#define BE_CQ_MAGIC			SA_TAG("becq")
+#define BE_EQ_MAGIC			SA_TAG("beeq")
+#define BE_ETHSQ_MAGIC			SA_TAG("bees")
+#define BE_ETHRQ_MAGIC			SA_TAG("beer")
+#define BE_MCC_MAGIC			SA_TAG("bemc")
+#define BE_DEFAULT_PDU_QUEUE_MAGIC	SA_TAG("bedp")
+#define BE_ISCSI_CONNECTION_MAGIC	SA_TAG("beic")
+#define BE_TPM_CONNECTION_MAGIC		SA_TAG("betc")
+#define BE_TPM_SQ_MAGIC			SA_TAG("besq")
+#define BE_TPM_RQ_MAGIC			SA_TAG("berq")
+#define BE_TPM_DQ_MAGIC			SA_TAG("bedq")
+#define BE_ISCSI_WRB_QUEUE_MAGIC	SA_TAG("beiq")
+#define BE_RDMA_QP_MAGIC		SA_TAG("beqp")
+#define BE_RDMA_CXN_MAGIC		SA_TAG("brcx")
+
+/*
+ * Macro to declare an inline function that asserts on both a pointer and
+ * the magic value.  Inline function nicely forces type safety at compile time.
+ */
+#define MAGIC_ASSERT_DECLARE(_type_) \
+static INLINE void _type_##_ASSERT(struct BE_##_type_##_OBJECT *p) { \
+		ASSERT(p);					\
+		ASSERT(p->magic == BE_##_type_##_MAGIC);	\
+	}
+
+/*
+ * Declare inline functions, e.g. CHIP_ASSERT, that check the
+ * pointer for non-NULL and verify the magic constant.  Since they
+ * are functions, they also verify the type of the pointer at compile time.
+ */
+MAGIC_ASSERT_DECLARE(CHIP)
+MAGIC_ASSERT_DECLARE(FUNCTION)
+MAGIC_ASSERT_DECLARE(PD)
+MAGIC_ASSERT_DECLARE(CQ)
+MAGIC_ASSERT_DECLARE(EQ)
+MAGIC_ASSERT_DECLARE(ETHSQ)
+MAGIC_ASSERT_DECLARE(ETHRQ)
+MAGIC_ASSERT_DECLARE(MCC)
+MAGIC_ASSERT_DECLARE(DEFAULT_PDU_QUEUE)
+MAGIC_ASSERT_DECLARE(ISCSI_CONNECTION)
+MAGIC_ASSERT_DECLARE(ISCSI_WRB_QUEUE)
+/* Shorter names */
+#define ISCSI_CXN_ASSERT  ISCSI_CONNECTION_ASSERT
+#define ISCSI_WRBQ_ASSERT ISCSI_WRB_QUEUE_ASSERT
+#define ISCSI_DEFQ_ASSERT DEFAULT_PDU_QUEUE_ASSERT
+/* Include the srcgen API. */
+#include "beclib_ll_enum_nic.h"
+#include "beclib_ll_bmap_nic.h"
+/*
+ * ----------------------------------------------------------------------
+ *   API MACROS
+ * ----------------------------------------------------------------------
+ */
+#define BE_IOCTL_NAME(_short_name_)     IOCTL_##_short_name_
+#define BE_OPCODE_NAME(_short_name_)    OPCODE_##_short_name_
+#define BE_SUBSYSTEM_NAME(_short_name_) SUBSYSTEM_##_short_name_
+
+
+/*
+ * BMAP version of BE_PREPARE_EMBEDDED_IOCTL. Use this
+ * version for ioctls that use bmap structures.
+ */
+#define BE_PREPARE_EMBEDDED_IOCTL(_pfob_, _wrb_, _short_name_)	\
+	((struct BE_IOCTL_NAME(_short_name_) *)				\
+	be_function_prepare_embedded_ioctl(_pfob_, _wrb_,	\
+		sizeof(struct BE_IOCTL_NAME(_short_name_)),		\
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.request), \
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.response), \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_)));
+/*
+ * AMAP version of BE_PREPARE_EMBEDDED_IOCTL. Use this
+ * version for ioctls that use amap structures.
+ */
+#define BE_IOCTL_NAME_AMAP(_short_name_)     IOCTL_##_short_name_##_AMAP
+
+#define BE_PREPARE_EMBEDDED_IOCTL_AMAP(_pfob_, _wrb_, _short_name_)	\
+	((struct BE_IOCTL_NAME_AMAP(_short_name_) *)			\
+	be_function_prepare_embedded_ioctl(_pfob_, _wrb_,		\
+		AMAP_BYTE_SIZE(IOCTL_##_short_name_),			\
+		AMAP_BIT_SIZE(IOCTL_##_short_name_, params.request)/8,	\
+		AMAP_BIT_SIZE(IOCTL_##_short_name_, params.response)/8, \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_)));
+
+#define BE_PREPARE_NONEMBEDDED_IOCTL(_pfob_, _wrb_, _iva_, _ipa_, _short_name_)\
+	((struct BE_IOCTL_NAME(_short_name_) *)				\
+	be_function_prepare_nonembedded_ioctl(_pfob_, _wrb_, (_iva_), (_ipa_), \
+		sizeof(struct BE_IOCTL_NAME(_short_name_)),		\
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.request), \
+		SA_SIZEOF_FIELD(BE_IOCTL_NAME(_short_name_), params.response), \
+		BE_OPCODE_NAME(_short_name_),				\
+		BE_SUBSYSTEM_NAME(_short_name_)));
+
+/*
+ * ----------------------------------------------------------------------
+ *   API Inline Functions
+ * ----------------------------------------------------------------------
+ * Returns TRUE for the ISCSI function
+ */
+static INLINE bool
+be_function_is_iscsi(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	return (pfob->type == BE_FUNCTION_TYPE_ISCSI);
+}
+
+/* Returns TRUE for the networking function */
+static INLINE bool
+be_function_is_networking(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	return (pfob->type == BE_FUNCTION_TYPE_NETWORK);
+}
+
+static INLINE void
+be_function_copy_stats(struct BE_FUNCTION_OBJECT *pfob,
+		       struct BECLIB_FUNCTION_STATS *stats)
+{
+	FUNCTION_ASSERT(pfob);
+	ASSERT(stats);
+	sa_memcpy(stats, &pfob->stats,
+				sizeof(pfob->stats));
+
+}
+
+/* Returns a pointer to the parent chip object for this function. */
+static INLINE struct BE_CHIP_OBJECT *
+be_function_get_chip_object(struct BE_FUNCTION_OBJECT *pfob)
+{
+	FUNCTION_ASSERT(pfob);
+	return (pfob->parent_chip);
+}
+
+#endif /* __beclib_lower__ */
diff --git a/drivers/message/beclib/beclib_ll_bmap_nic.h b/drivers/message/beclib/beclib_ll_bmap_nic.h
new file mode 100644
index 0000000..25e3caa
--- /dev/null
+++ b/drivers/message/beclib/beclib_ll_bmap_nic.h
@@ -0,0 +1,1667 @@
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
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __beclib_ll_bmap_h__
+#define __beclib_ll_bmap_h__
+
+#ifndef SG_C_ASSERT
+#define SG_C_ASSERT(_name_, _condition_)
+#endif
+
+/*
+ *-----------------------------------------------------
+ * Function: be_initialize_library
+ *   Call to initialize the static library. This initializes the debug traces.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-----------------------------------------------------
+ */
+BESTATUS be_initialize_library(void);
+
+/*
+ *---------------------------------------------------
+ * Function: be_function_and_chip_create
+ *   Create both function and chip object with one call.
+ *   The lower level API will rarely *   use more than one function object.
+ * sa_dev          - Previously created device.
+ * function_type   -
+ * mailbox_sgl     - SGL with length equal to sizeof(MCC_MAILBOX). This must be
+ *                   physically contiguous. The starting address must be
+ *                   aligned to 16 byte boundary.
+ * emulation_sgl   - SGL with length equal to one page . Must be physically
+ *                   contiguous. Starting address must be 16 byte aligned.
+ * pfob - On input, a pointer to an allocated function object. On
+ *                   output, it is initialized. This is an opaque object.
+ *                   Do not access the members.
+ * chip            - On input this is a pointer to an allocated chip object.
+ * 		     On output, it is initialized. This is an opaque object.
+ * 		     Do not access the members.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------
+ */
+BESTATUS
+be_function_and_chip_create(struct SA_DEV *sa_dev,
+			    u32 function_type,
+			    struct SA_SGL *mailbox_sgl,
+			    struct SA_SGL *emulation_sgl,
+			    struct BE_FUNCTION_OBJECT *pfob,
+			    struct BE_CHIP_OBJECT *chip);
+
+/*
+ *---------------------------------------------------
+ * Function: be_function_object_create
+ *   Create function object .
+ * sa_dev          - Previously created device.
+ * function_type   -
+ * mailbox_sgl     - SGL with length equal to sizeof(MCC_MAILBOX).
+ * 		     This must be physically contiguous. The starting
+ * 		     address must be aligned to 16 byte boundary.
+ * pfob - On input this is a pointer to an allocated function
+ * 		     object. On output, it is initialized. This is an
+ * 		     opaque object. Do not access the members.
+ * chip            - On input this is a pointer to an allocated chip object.
+ * 		     On output, it is initialized. This is an opaque object.
+ * 		     Do not access the members.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *----------------------------------------------------
+ */
+BESTATUS
+be_function_object_create(struct SA_DEV *sa_dev,
+			  u32 function_type,
+			  struct SA_SGL *mailbox_sgl,
+			  struct BE_FUNCTION_OBJECT *pfob,
+			  struct BE_CHIP_OBJECT *chip);
+
+/*
+ *-----------------------------------------------
+ * Function: be_chip_object_create
+ *   Create chip object .
+ * chip          - On input this is a pointer to an allocated chip object.
+ * 		   On output, it is initialized. This is an opaque object.
+ * 		   Do not access the members.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_chip_object_create(struct BE_CHIP_OBJECT *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_and_chip_destroy
+ *   This destroys the function and chip object created by the
+ *   be_function_and_chip_create function. It assumes that all
+ *   sub-objects created for this function have already been
+ *   destroyed -- it asserts if this is not true. This function is called by
+ *   be_function_cleanup -- Use be_function_cleanup to automatically cleanup all
+ *   sub-objects.
+ * pfob - Previously created function object.
+ * chip            - Previously created chip object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_and_chip_destroy(struct BE_FUNCTION_OBJECT *pfob,
+			     struct BE_CHIP_OBJECT *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_object_destroy
+ *   This destroys the function object created by the
+ *   be_function_object_create function.  It assumes that all
+ *   sub-objects created for this function have already been destroyed
+ *   -- it asserts if this is not true. This function is called by
+ *   be_function_cleanup --
+ *   Use be_function_cleanup to automatically cleanup all sub-objects.
+ * pfob - Previously created function object.
+ * chip            - Previously created chip object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_object_destroy(struct BE_FUNCTION_OBJECT *pfob,
+			   struct BE_CHIP_OBJECT *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_chip_object_destroy
+ *   This destroys the chip object created by the
+ *   be_chip_object_create function. It assumes that all sub-objects
+ *   created for this chip have already been destroyed -- it
+ *   asserts if this is not true. This function is called by
+ *   be_function_cleanup -- Use be_function_cleanup to automatically
+ *   cleanup all sub-objects.
+ * chip          - Previously created chip object.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_chip_object_destroy(struct BE_CHIP_OBJECT *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_cleanup
+ *   This function destroys all objects that reference the function
+ *   object including the all queues  (mcc, etx, erx, iscsi/wrbq/defq, eq)  -
+ *   iscsi ooo buffers  - software jell buffers (during emulation)  -
+ *   template header buffers (if host based)  - WDMA
+ *   zero buffer (during emulation)  - vlan tags  - multicast addresses  - rss
+ *   configuration  - wake on lan entries (ACPI)  - chip object  -
+ *   pfob  All objects are destroyed with synchronous ioctls
+ *   that poll for their completions. This
+ *   function is optional, all objects can be explicitly cleaned up.
+ * pfob - Previously created function object
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_function_cleanup(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_get_function_number
+ *   Returns the PCI function number.
+ * pfob        - Previously created function object
+ * return function_number -
+ *---------------------------------------------------------------
+ */
+u32
+be_function_get_function_number(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_get_function_type
+ *   Returns the function type.
+ * pfob      -
+ * return function_type -
+ *---------------------------------------------------------------
+ */
+u32
+be_function_get_function_type(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_is_iscsi
+ *   Returns TRUE for the ISCSI function.
+ * pfob -
+ * return is_iscsi -
+ *---------------------------------------------------------------
+ */
+static INLINE bool
+be_function_is_iscsi(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_is_networking
+ *   Returns TRUE for the networking function.
+ * pfob      -
+ * return is_networking -
+ *---------------------------------------------------------------
+ */
+static INLINE bool
+be_function_is_networking(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_copy_stats
+ *   Copies the function object stats into the memory supplied by the caller.
+ * pfob    - The previously created function object.
+ * stats              - Pointer to a stat struct. The stats are copied.
+ * return return_type -
+ *---------------------------------------------------------------
+ */
+static INLINE void
+be_function_copy_stats(struct BE_FUNCTION_OBJECT *pfob,
+		       struct BECLIB_FUNCTION_STATS *stats);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_nop
+ *   Issues a NOP command to the MCC ring. The command is completed with
+ *   a successful status. This can be used to pend operations until
+ *   a short time in the future, since the callback function will
+ *   be invoked upon command completion. The returned status
+ *   will be BE_PENDING if the command was issued successfully.
+ * pfob    -
+ * callback           - Callback function invoked when the NOP completes.
+ * callback_context   - Passed to the callback function.
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is
+ * 			used to queue the operation. It will be posted
+ * 			to the MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring in
+ *                      the order they are received. It is always valid
+ *                      to pass a pointer to a generic BE_GENERIC_QUEUE_CONTEXT.
+ *                      However, the specific context structs are
+ *                      generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING
+ * 			(postive value) if the IOCTL completion is
+ * 			pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_nop(struct BE_FUNCTION_OBJECT *pfob,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct BE_NOP_QUEUE_CONTEXT *queue_context);
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_get_fw_version
+ *   Retrieves the firmware version on the adpater. If the callback
+ *   is NULL this call executes synchronously. If the callback is
+ *   not NULL, the returned status will be BE_PENDING if the
+ *   command was issued successfully.
+ * pfob    -
+ * fw_version         - Pointer to response buffer if callback is NULL.
+ * callback           - Callback function invoked when the IOCTL completes.
+ * callback_context   - Passed to the callback function.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_get_fw_version(struct BE_FUNCTION_OBJECT *pfob,
+	struct IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD *fw_version,
+	MCC_WRB_CQE_CALLBACK callback,
+	void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_manage_FAT_log
+ *   This routine can be used to manage the BladeEngine Fault Analysis
+ *   Tool (FAT) log.  This includes querying the FAT log size,
+ *   retrieving the FAT log, and clearing the FAT log. The log data
+ *   can be anaylzed by BladeEngine support tools to diagnose faults.
+ *   Only host domains (domain 0) may issue this request.
+ * pfob   -
+ * sgl               - SGL representing the FAT log buffer landing space.
+ * 			The SGL should be page aligned. It does not
+ * 			require a virtual address.
+ * num_pages         - The number of pages in the SGL. A value of zero (0)
+ * 			implies no FAT log data transfer will take place.
+ * 			The num_pages is limited to 27 pages.
+ * page_offset       - The page_offset specifies the starting page
+ * 			offset when retrieving the FAT log. For example,
+ * 			a value of 0 requests data starting at byte
+ * 			offset 0 of the FAT log. Likewise, a value
+ * 			of 5 requests data starting at byte offset 20480 of
+ * 			the FAT log. A caller may choose to issue multiple
+ * 			queries when the FAT log buffer size is larger
+ *                     than the number of pages specified.
+ * clear_log         - Set to clear the log.
+ * log_size          - The size of the BladeEngine FAT log in bytes.
+ * bytes_transferred - The number of FAT log data bytes transferred.
+ * return status     - BE_SUCCESS (0) on success. Negative error code
+ * 			on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_manage_FAT_log(struct BE_FUNCTION_OBJECT *pfob,
+			   struct SA_SGL *sgl,
+			   u32 num_pages,
+			   u32 page_offset,
+			   bool clear_log,
+			   u32 *log_size,
+			   u32 *bytes_transferred);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_query_firmware_config
+ *   Queries the firmware configuration currently loaded. This
+ *   configuration includes information regarding the EP processor
+ *   configuration for various Upper Layer Protocols.
+ * pfob -
+ * config          - The configuration parameters currently loaded by firmware.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_query_firmware_config(struct BE_FUNCTION_OBJECT *pfob,
+				  struct BE_FIRMWARE_CONFIG *config);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_config_red
+ *   This function configures global and/or ULP specific Random Early Drop (RED)
+ *   functionality.
+ * pfob    -
+ * parameters         - The RED parameters. Only parameters for the
+ * 			chutes owned by the
+ *                      current PCI function are applied.
+ * callback           - Optional callback function.
+ * callback_context   - Optional context for callback function.
+ * queue_context      - Optional context for queueing the IOCTL.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_config_red(struct BE_FUNCTION_OBJECT *pfob,
+		       struct BE_RED_PARAMETERS *parameters,
+		       MCC_WRB_CQE_CALLBACK callback,
+		       void *callback_context,
+		       struct BE_GENERIC_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_config_port_equalization
+ *   This function configures or returns the XAUI port equalization
+ *   parameters of BladeEngine.
+ * pfob    -
+ * parameters         - XAUI port equalization parameters.
+ * write              - Set (1) to write the parameters, otherwise
+ * 			clear (0) to read the
+ *                      parameters.
+ * callback           - Optional callback function.
+ * callback_context   - Optional context for callback function.
+ * queue_context      - Optional context for queueing the IOCTL.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_config_port_equalization(struct BE_FUNCTION_OBJECT *pfob,
+		struct IOCTL_COMMON_PORT_EQUALIZATION_PARAMS *parameters,
+		bool write,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct BE_GENERIC_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_passthru_ioctl
+ *   This routine issues an embedded IOCTL in pass-through mode.
+ * pfob  -
+ * payload          - The embedded payload for the MCC_WRB structure.
+ * 			The input buffer is
+ *                    overwritten with response data.
+ * callback         - Callback function invoked when the IOCTL completes.
+ * callback_context - Callback context passed to the callback function.
+ * return status    - BE_SUCCESS (0) on success. Negative error code on
+ * 			failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_passthru_ioctl(struct BE_FUNCTION_OBJECT *pfob,
+			   struct MCC_WRB_PAYLOAD_AMAP *payload,
+			   MCC_WRB_CQE_CALLBACK callback,
+			   void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_modify_delay
+ *   Changes the EQ delay for a group of EQs.
+ * pfob    -
+ * num_eq             - The number of EQs in the eq_array to adjust.
+ * 			This also is the number of delay values in the
+ * 			eq_delay_array.
+ * eq_array           - Array of struct BE_EQ_OBJECT pointers to adjust.
+ * eq_delay_array     - Array of "num_eq" timer delays in units of
+ * 			microseconds. The be_eq_query_delay_range ioctl
+ * 			returns the resolution and range of legal EQ delays.
+ * callback           -
+ * callback_context   -
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is
+ * 			used to queue the operation. It will be posted to
+ * 			the MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring
+ *                      in the order they are received. It is always
+ *                      valid to pass a pointer to a generic
+ *                      BE_GENERIC_QUEUE_CONTEXT. However, the
+ *                      specific context structs
+ *                      are generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_modify_delay(struct BE_FUNCTION_OBJECT *pfob,
+		   u32 num_eq,
+		   struct BE_EQ_OBJECT **eq_array,
+		   u32 *eq_delay_array,
+		   MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct BE_EQ_MODIFY_DELAY_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_query_delay_range
+ *   Queries the resolution and range allowed for EQ delay. This is
+ *   a constant set by the firmware, so it may be queried one time
+ *   at system boot. It is the same for all EQs.  This is a synchronous IOCTL.
+ * pfob     -
+ * eq_delay_resolution - Resolution of EQ delay in microseconds.
+ * eq_delay_max        - Max value of EQ delay in microseconds.
+ * return status       - BE_SUCCESS (0) on success. Negative error code
+ * 			on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_query_delay_range(struct BE_FUNCTION_OBJECT *pfob,
+			u32 *eq_delay_resolution,
+			u32 *eq_delay_max);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_create
+ *   Creates an eq_object. This is a synchronous IOCTL.
+ * pfob -
+ * sgl             - No virtual address required.
+ * eqe_size        - EQ entry size in bytes. Either 4 or 16.
+ * num_entries     - Power of 2, fom 256 to 4k.
+ * watermark       - Eventable CQs only. CEV_WMARK_* or ~0UL for no watermark.
+ * timer_delay     - Interrupt timer delay. ~0UL disables timer. Otherwise,
+ * 			it is eq_delay_resolution units up to eq_delay_max
+ * 			decimal. The resolution and max are queried from
+ * 			be_eq_query_delay_range. e.g. If an 16 us delay
+ * 			is required, timer_delay should be
+ * 			8us/eq_delay_resolution.
+ * eq_object       - Created EQ object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_create(struct BE_FUNCTION_OBJECT *pfob,
+	     struct SA_SGL *sgl,
+	     u32 eqe_size,
+	     u32 num_entries,
+	     u32 watermark,
+	     u32 timer_delay, struct BE_EQ_OBJECT *eq_object);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_fake_create
+ *   Creates an eq_object that does not have an associated memory
+ *   ring. The object is used to generate an interrupt from software.
+ *   The EQ will interrupt the host every time the EQ is rearmed,
+ *   after the EQ delay expires. The EQ should always be rearmed with a
+ *   num_popped count of 0 in the doorbell register.
+ *   The be_function_enable_interrupts function will cause an
+ *   immediate interrupt from this EQ. This is a synchronous IOCTL.
+ * pfob -
+ * timer_delay     - Interrupt timer delay. ~0UL disables timer.
+ * 			Otherwise, it is eq_delay_resolution units up to
+ * 			eq_delay_max decimal. The resolution and max are
+ * 			queried from be_eq_query_delay_range. e.g. If an
+ * 			16 us delay is required, timer_delay should be
+ * 			16 us/eq_delay_resolution.
+ * eq_object       - Created EQ object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_fake_create(struct BE_FUNCTION_OBJECT *pfob,
+		  u32 timer_delay, struct BE_EQ_OBJECT *eq_object);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_destroy
+ *   Destroys an eq_object. This function is called as part of
+ *   be_function_cleanup.
+ * eq            -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_eq_destroy(struct BE_EQ_OBJECT *eq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_get_id
+ *   Return the allocated ID that must be used to ring the doorbell for the EQ.
+ *---------------------------------------------------------------
+ */
+u32 be_eq_get_id(struct BE_EQ_OBJECT *eq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_cq_create
+ *   Creates a CQ. This uses a synchronous IOCTL.
+ * pfob     -
+ * sgl                 - No virtual address required, except for MCC CQ.
+ * length              - Length is bytes of queue. Number of entries is
+ * 			power of 2, from 256 to 1k.  solicited_eventable -
+ * 			If TRUE, only CQEs with solicited event bit cause
+ * 			eqe write.
+ * no_delay            - If eventable, TRUE means force interrupt
+ * 			immediately (ignore watermark & timer).
+ * wm_thresh           - If eventable, watermark encodings CEV_WMARK_* or
+ * 			~0UL for no watermark.
+ * eq_object           - Optional, if set this is an eventable CQ.
+ * cq_object           - Created CQ object.
+ * return status       - BE_SUCCESS (0) on success.
+ * 			Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_cq_create(struct BE_FUNCTION_OBJECT *pfob,
+	struct SA_SGL *sgl, u32 length,
+	bool solicited_eventable, bool no_delay,
+	u32 wm_thresh, struct BE_EQ_OBJECT *eq_object,
+	struct BE_CQ_OBJECT *cq_object);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_cq_destroy
+ *   Destroys a CQ. All clients that reference this CQ must
+ *   be destroyed first. This function is called as part of
+ *   be_function_cleanup.
+ * cq            -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_cq_destroy(struct BE_CQ_OBJECT *cq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_cq_get_id
+ *   Returns the allocated CQ id used for ringing the doorbell.
+ * cq        -
+ * return id -
+ *---------------------------------------------------------------
+ */
+u32 be_cq_get_id(struct BE_CQ_OBJECT *cq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_ring_create
+ *   This creates a MCC ring and switches from mailbox mode to ring mode.
+ *   The number of outstanding MCC commands is the minimum of the
+ *   number of entries in the ring and the number of context structures
+ *   (i.e. num_context_entries). BECLIB uses the context entries to
+ *   track outstanding MCC WRBs since they may complete out-of-order. You may
+ *   provide zero context entries, which will limit BECLIB to one
+ *   MCC WRB at a time.
+ * pfob     -
+ * sgl                 - A virtual address is required.
+ * length              - length in bytes
+ * context_array       - Array of context structs. Each outstanding MCC WRB
+ * 			 requires a context entry. BECLIB has 1 by
+ * 			 default. The context array allows you to post
+ * 			 more -- this must be non-pageable memory, but it is
+ *                       not used for DMA. Most likely the number of
+ *                       context structs will match the size of the
+ *                       MCC ring. Since commands complete out-of-order,
+ *                       this lets beclib fully utilize the ring. However,
+ *                       the size may be either lower or higher than
+ *                       the ring size.  num_context_entries - number of
+ *                       context structs
+ * cq                  - Associated completion queue created with an SGL
+ * 			 with a mapped virtual address
+ * mcc                 - On input this is a pointer to an allocated
+ * 			 MCC_OBJECT On ouput this is a created MCC object.
+ * 			 This is an opaque object. Do not reference any
+ * 			 members.
+ * return status       - BE_SUCCESS (0) on success.
+ * 			 Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_mcc_ring_create(struct BE_FUNCTION_OBJECT *pfob,
+		   struct SA_SGL *sgl,
+		   u32 length,
+		   struct BE_MCC_WRB_CONTEXT *context_array,
+		   u32 num_context_entries,
+		   struct BE_CQ_OBJECT *cq, struct BE_MCC_OBJECT *mcc);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_ring_destroy
+ *   Cleans up MCC ring and switches to mailbox mode. This function is
+ *   called as part of be_function_cleanup.
+ * mcc_object    -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_mcc_ring_destroy(struct BE_MCC_OBJECT *mcc_object);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_process_cq
+ *   Processes mcc completions. This should be called from
+ *   the interrupt or DPC to process the MCC cq, when a corresponding
+ *   event queue entry is received. It can also be called to
+ *   poll the CQ from a timer routine for non-eventable completions.
+ *   Keep in mind, only one thread can be inside beclib at any
+ *   given time. That means this function must be
+ *   serialized with the posting of MCC WRBs.
+ * mcc_object    -
+ * rearm         - rearm should be TRUE only if called due to EQE
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_mcc_process_cq(struct BE_MCC_OBJECT *mcc_object, bool rearm);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_add_async_event_callback
+ * mcc_object       -
+ * callback         - Function callback invoked when an asynchronous event
+ * 			is received on the MCC cq. It follows the prototype:
+ *  typedef void (BECALL *MCC_ASYNC_EVENT_CALLBACK) (void *context,
+ *  				u32 event_code, void *event);
+ *
+ *  			The context parameter is a copy of the
+ *  			callback_context pointer provided to this function.
+ *  			The event_code is the code from the common
+ *  			portion of the event entry. The event
+ *  			parameter is a pointer to the 16 byte async
+ *  			event message.
+ * callback_context - Passed to the callback function.
+ * return status    - BE_SUCCESS (0) on success. Negative error code on
+ * 			failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_mcc_add_async_event_callback(struct BE_MCC_OBJECT *mcc_object,
+				MCC_ASYNC_EVENT_CALLBACK callback,
+				void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_pci_soft_reset
+ *   This function is called to issue a BladeEngine soft reset. Callers
+ *   should acquire the soft reset semaphore before calling this function.
+ *   Additionaly, callers should ensure they cannot be pre-empted while
+ *   the routine executes. Upon completion of this routine, callers
+ *   should release the reset semaphore. This routine implicitly waits
+ *   for BladeEngine POST to complete.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_pci_soft_reset(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_acquire_reset_semaphore
+ *   Acquires the reset semaphore. If success is returned, the caller owns
+ *   the reset semaphore. Otherwise the caller does not own the
+ *   reset semaphore. Callers must acquire the reset semaphore before
+ *   inducing a BladeEngine runtime reset. Callers must also
+ *   release the reset semaphore once they are done with a soft reset.
+ *   Release of the reset semaphore is accomplished with
+ *   be_release_reset_semaphore.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_acquire_reset_semaphore(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_release_reset_semaphore
+ *   Releases the reset semaphore. Callers must release the reset
+ *   semaphore once they are done with a soft reset.
+ * pfob    -
+ * return return_type -
+ *---------------------------------------------------------------
+ */
+void be_release_reset_semaphore(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_drive_POST
+ *   This function is called to drive BladeEngine POST. The
+ *   caller should ensure they cannot be pre-empted while this routine
+ *   executes.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_drive_POST(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_defq_create
+ *   Creates a default PDU ring for the current protection domain. Each queue
+ *   contains 8 byte physical addresses to default PDU buffers.
+ * pfob       -
+ * sgl                   - no virtual address required
+ * length                - bytes in total ring
+ * default_buffer_length - bytes in each buffer posted to ring
+ * cq_object             - cq that will receive completions
+ * defq                  -
+ * return status         - BE_SUCCESS (0) on success. Negative
+ * 				error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_iscsi_defq_create(struct BE_FUNCTION_OBJECT *pfob,
+		     struct SA_SGL *sgl,
+		     u32 length,
+		     u32 default_buffer_length,
+		     struct BE_CQ_OBJECT *cq_object,
+		     struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_defq_destroy
+ *   Destroys the default queue. All connections for the PD should
+ *   be torn down first.  This function is called as part of
+ *   be_function_cleanup.
+ * defq          -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_iscsi_defq_destroy(struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_defq_get_id
+ *   Gets the allocated ID for this queue. The id is used to
+ *   ring the doorbell to post buffers to the default queue.
+ * defq      -
+ * return id -
+ *---------------------------------------------------------------
+ */
+u32 be_iscsi_defq_get_id(struct BE_DEFAULT_PDU_QUEUE_OBJECT *defq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_wrb_queue_create
+ *   Creates a WRB ring. Use the "get_cid" function to query
+ *   the corresponding cid for the ring.
+ * pfob -
+ * sgl             -
+ * num_entries     - max = 32k / sizeof(ISCSI_INITIATOR_WRB)
+ * wrbq            -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_iscsi_wrb_queue_create(struct BE_FUNCTION_OBJECT *pfob,
+			  struct SA_SGL *sgl,
+			  u32 num_entries,
+			  struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_wrb_queue_destroy
+ *   Destroys the wrb ring. Make sure the connection is torn down
+ *   before destroying the ring. This function is called as part
+ *   of be_function_cleanup.
+ * wrbq          -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_iscsi_wrb_queue_destroy(struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_wrbq_get_cid
+ *   Queries the allocated cid for the wrbq.
+ * wrbq       -
+ * return cid -
+ *---------------------------------------------------------------
+ */
+u32 be_iscsi_wrbq_get_cid(struct BE_ISCSI_WRB_QUEUE_OBJECT *wrbq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_post_sgl_pages
+ *   Posts memory for iSCSI SGLs to the chip for the given
+ *   protection domain. The memory may be posted with multiple calls
+ *   to this function by incrementing the page_offset.  The SGL
+ *   does not require a valid virtual address. The SGL should be page aligned.
+ *   This must be done before any connections are offloaded.
+ *   1 page table must be posted to the chip per 2MB of frags.
+ * pfob -
+ * sgl             - memory is posted starting with page 0 in this sgl
+ * page_offset     - offset on the chip where the pages are mapped
+ * num_pages       - number of pages to post from the current sgl
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_iscsi_post_sgl_pages(struct BE_FUNCTION_OBJECT *pfob,
+			struct SA_SGL *sgl,
+			u32 page_offset, u32 num_pages);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_iscsi_remove_sgl_pages
+ *   Removes all the sgl memory for the given protection domain. This
+ *   function is called as part of be_function_cleanup.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_iscsi_remove_sgl_pages(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_create
+ *   Creates an ethernet send ring.
+ * pfob -
+ * sgl             - no virtual address required
+ * length_in_bytes -
+ * type            - The type of ring to create.
+ * ulp             - The requested ULP number for the ring. This
+ * 			should be zero based, i.e. 0,1,2. This must be valid
+ * 			NIC ULP based on the firmware config.  All
+ * 			doorbells for this ring must be sent to this ULP. The
+ * 			first network ring allocated for each ULP are
+ * 			igher performance than subsequent rings.
+ * cq_object       - cq object for completions
+ * eth_sq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create(struct BE_FUNCTION_OBJECT *pfob,
+		struct SA_SGL *sgl, u32 length_in_bytes,
+		u32 type, u32 ulp,
+		struct BE_CQ_OBJECT *cq_object,
+		struct BE_ETHSQ_OBJECT *eth_sq);
+
+/*
+ * This is a set of optional parameters for be_eth_sq_create_ex. Certain
+ * ring types require additional parameters provided in this struct.
+ */
+struct BE_ETH_SQ_PARAMETERS {
+	u32 port;
+	u32 rsvd0[2];
+} ;
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_create_ex
+ *   Creates an ethernet send ring - extended version with additional parameters
+ * pfob -
+ * sgl             - no virtual address required
+ * length_in_bytes -
+ * type            - The type of ring to create.
+ * ulp             - The requested ULP number for the ring. This
+ * 			should be zero based, i.e. 0,1,2. This must be
+ * 			valid NIC ULP based on the firmware config.
+ * 			All doorbells for this ring must be sent to
+ * 			this ULP. The first network ring allocated for
+ * 			each ULP are higher performance than subsequent rings.
+ * cq_object       - cq object for completions
+ * ex_parameters   - Additional parameters (that may increase in future
+ * 			revisions). These parameters are only used for
+ * 			certain ring types -- see BE_ETH_SQ_PARAMETER
+ * 			for details.
+ * eth_sq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create_ex(struct BE_FUNCTION_OBJECT *pfob,
+		    struct SA_SGL *sgl,
+		    u32 length_in_bytes,
+		    u32 type,
+		    u32 ulp,
+		    struct BE_CQ_OBJECT *cq_object,
+		    struct BE_ETH_SQ_PARAMETERS *ex_parameters,
+		    struct BE_ETHSQ_OBJECT *eth_sq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_destroy
+ *   Destroys an ethernet send ring. The driver must wait for
+ *   all send completions before destroying the ring. This function
+ *   is called as part of be_function_cleanup.
+ * eth_sq        -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_eth_sq_destroy(struct BE_ETHSQ_OBJECT *eth_sq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_get_id
+ *   Query the allocated id for the send ring. This ID is used
+ *   to ring the doorbell.
+ * eth_sq    -
+ * return id -
+ *---------------------------------------------------------------
+ */
+u32 be_eth_sq_get_id(struct BE_ETHSQ_OBJECT *eth_sq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_set_flow_control
+ *   This function sets the flow control characteristics of BladeEngine.
+ * pfob -
+ * txfc_enable     -
+ * rxfc_enable     -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_flow_control(struct BE_FUNCTION_OBJECT *pfob,
+			bool txfc_enable, bool rxfc_enable);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_get_flow_control
+ *   This function gets the flow control characteristics of BladeEngine.
+ * pfob -
+ * txfc_enable     -
+ * rxfc_enable     -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_flow_control(struct BE_FUNCTION_OBJECT *pfob,
+			bool *txfc_enable,
+			bool *rxfc_enable);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_set_qos
+ *   This function sets the ethernet transmit Quality of Service (QoS)
+ *   characteristics of BladeEngine for the domain. All ethernet transmit
+ *   rings of the domain will evenly share the bandwidth. The exeception
+ *   to sharing is the host primary (super) ethernet transmit
+ *   ring as well as the host ethernet forwarding ring for missed offload
+ *   data.
+ * pfob -
+ * max_bps         - the maximum bits per second in units of
+ * 			10 Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units
+ * 			of 1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_qos(struct BE_FUNCTION_OBJECT *pfob,
+	       u32 max_bps, u32 max_pps);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_get_qos
+ *   This function retrieves the ethernet transmit Quality of Service (QoS)
+ *   characteristics for the domain.
+ * pfob -
+ * max_bps         - the maximum bits per second in units of 10
+ * 			Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units of
+ * 			1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_qos(struct BE_FUNCTION_OBJECT *pfob,
+	       u32 *max_bps, u32 *max_pps);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_set_frame_size
+ *   This function sets the ethernet maximum frame size. The
+ *   previous values are returned.
+ * pfob -
+ * tx_frame_size   - maximum transmit frame size in bytes
+ * rx_frame_size   - maximum receive frame size in bytes
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_frame_size(struct BE_FUNCTION_OBJECT *pfob,
+		      u32 *tx_frame_size,
+		      u32 *rx_frame_size);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_create
+ *   Creates an ethernet receive ring for posting rx buffers. Each
+ *   buffer posted to the ring should be the size indicated from
+ *   calling the be_eth_rq_get_frag_size function.
+ *   Only the host protection domain can receive broadcast/multicast
+ *   frames. It can choose to receive the CQ entries for these
+ *   frames on a separate completion queue, or it can
+ *   use the same CQ. This is determines by the bcmc_cq_object parameter.
+ * pfob -
+ * sgl             -
+ * cq_object       -
+ * bcmc_cq_object  - optional
+ * eth_rq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_create(struct BE_FUNCTION_OBJECT *pfob,
+		 struct SA_SGL *sgl,
+		 struct BE_CQ_OBJECT *cq_object,
+		 struct BE_CQ_OBJECT *bcmc_cq_object,
+		 struct BE_ETHRQ_OBJECT *eth_rq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_destroy
+ *   Destroys an ethernet receive ring. This function is called as part of
+ *   be_function_cleanup.
+ * eth_rq        -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_eth_rq_destroy(struct BE_ETHRQ_OBJECT *eth_rq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_destroy_options
+ *   Destroys an ethernet receive ring with finer granularity
+ *   options than the standard be_eth_rq_destroy() API function.
+ * eth_rq           -
+ * flush            - Set to 1 to flush the ring, set to 0 to
+ * 			bypass the flush and force invalidation.
+ * callback         - Callback function on completion
+ * callback_context - Callback context
+ * return status    - BE_SUCCESS (0) on success. Negative error
+ * 			code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_destroy_options(struct BE_ETHRQ_OBJECT *eth_rq,
+			  bool flush,
+			  MCC_WRB_CQE_CALLBACK callback,
+			  void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_destroy_async
+ *   Same as be_eth_rq_destroy, but this version allows an async callback.
+ * eth_rq             -
+ * callback           -
+ * callback_context   -
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_destroy_async(struct BE_ETHRQ_OBJECT *eth_rq,
+			MCC_WRB_CQE_CALLBACK callback,
+			void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_get_id
+ *   Queries the allocated ID for the ethernet receive ring.
+ *   This should be used for ringing the doorbell to post buffers.
+ * EthRq     -
+ * return id -
+ *---------------------------------------------------------------
+ */
+u32 be_eth_rq_get_id(struct BE_ETHRQ_OBJECT *EthRq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_set_frag_size
+ *   Changes the global ethernet receive fragment size. This
+ *   is very expensive and should rarely be done.  This function may
+ *   require a reboot for the fragsize to take affect. If the function
+ *   succeeds, and the returned actual_frag_size_bytes does not match
+ *   new_frag_size_bytes, then the driver must continue to use
+ *   the actual_frag_size_bytes until the next reboot.
+ * pfob        -
+ * new_frag_size_bytes    - New frag size to set. This must be a
+ * 				power of 2, from 128 to 16k.
+ * actual_frag_size_bytes - The current actual frag size. If the function
+ * 				succeeds, and this differs from the
+ * 				new_frag_size_bytes, then the new frag
+ * 				size will be applied after a reboot.
+ * 				The driver must use this size.
+ * return status          - BE_SUCCESS (0) on success. Negative error
+ * 				code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_set_frag_size(struct BE_FUNCTION_OBJECT *pfob,
+			u32 new_frag_size_bytes,
+			u32 *actual_frag_size_bytes);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_get_frag_size
+ *   Queries the global ethernet receive fragment size. All drivers
+ *   should query the frag size and use the specified size.
+ *   Alternatively, they should use the maximum fragment size.
+ * pfob -
+ * frag_size_bytes - The current actual frag size. If the function
+ * 			succeeds, and this differs from the
+ * 			new_frag_size_bytes, then the new frag size will be
+ * 			applied after a reboot. The driver must use this size.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_get_frag_size(struct BE_FUNCTION_OBJECT *pfob,
+			u32 *frag_size_bytes);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_prepare_embedded_ioctl
+ *   Use the BE_PREPARE_EMBEDDED_IOCTL macro, instead of calling this
+ *   function directly.
+ * pfob -
+ * wrb             -
+ * payload_length  -
+ * request_length  -
+ * response_length -
+ * opcode          -
+ * subsystem       -
+ * return ioctl    -
+ *---------------------------------------------------------------
+ */
+void *
+be_function_prepare_embedded_ioctl(struct BE_FUNCTION_OBJECT *pfob,
+				   struct MCC_WRB_AMAP *wrb,
+				   u32 payload_length,
+				   u32 request_length,
+				   u32 response_length,
+				   u32 opcode, u32 subsystem);
+void *
+be_function_prepare_embedded_ioctl_xx(struct BE_FUNCTION_OBJECT *pfob,
+				   struct MCC_WRB_AMAP *wrb,
+				   u32 payload_length,
+				   u32 request_length,
+				   u32 response_length,
+				   u32 opcode, u32 subsystem);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_prepare_nonembedded_ioctl
+ *   Use the BE_PREPARE_NONEMBEDDED_IOCTL macro, instead of
+ *   calling this function
+ *   directly.
+ * pfob -
+ * wrb             -
+ * ioctl_header_va -
+ * ioctl_header_pa -
+ * payload_length  -
+ * request_length  -
+ * response_length -
+ * opcode          -
+ * subsystem       -
+ * return ioctl    -
+ *---------------------------------------------------------------
+ */
+void *
+be_function_prepare_nonembedded_ioctl(struct BE_FUNCTION_OBJECT *pfob,
+	struct MCC_WRB_AMAP *wrb,
+	void *ioctl_header_va,
+	u64 ioctl_header_pa,
+	u32 payload_length,
+	u32 request_length,
+	u32 response_length,
+	u32 opcode, u32 subsystem);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_lock_mcc
+ *   Acquires the MCC posting lock. This lock must be held while calling
+ *   be_function_post_mcc_wrb. If using the be_function_peek_mcc_wrb,
+ *   the caller should acquire the lock before the peek function
+ *   call and hold it until after the post function call. Additionally,
+ *   the "peeked" WRB should not be accessed after this lock
+ *   is released since another thread may reuse the WRB.
+ * pfob    -
+ * return return_type -
+ *---------------------------------------------------------------
+ */
+void be_function_lock_mcc(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_unlock_mcc
+ *   Releases the MCC posting lock acquired by calling be_function_lock_mcc.
+ * pfob    -
+ * return return_type -
+ *---------------------------------------------------------------
+ */
+void be_function_unlock_mcc(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_peek_mcc_wrb
+ *   Returns a pointer to the next WRB to post, either the mailbox
+ *   buffer or the next WRB in the ring. When using this function,
+ *   the caller must ensure that no other thread
+ *   will post an MCC wrb until after this WRB is posted.
+ * pfob -
+ * return wrb      - Pointer to the next WRB to post, NULL on failure.
+ *---------------------------------------------------------------
+ */
+struct MCC_WRB_AMAP *
+be_function_peek_mcc_wrb(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_post_mcc_wrb
+ *   Posts a WRB to either mailbox or mcc ring. The wrb pointer
+ *   may be the pointer returned by the be_function_peek_mcc_wrb function.
+ *   It not, the wrb is copied into the ring/mailbox. The callback may
+ *   be NULL, in which case the function will not return until the
+ *   WRB completes. It will poll the mailbox status or MCC CQ in that case.
+ *   Other outstanding MCC WRBs may be completed in this context
+ *   if the callback is NULL.  This function (nor any other synchronous
+ *   IOCTL function) may be called from an MCC_WRB_CQE_CALLBACK context.
+ *   Only asynchronous IOCTLs may be posted during the completion of
+ *   another IOCTL. Otherwise, the software will deadlock.
+ * funcobj            -
+ * wrb                -
+ * callback           -
+ * callback_context   -
+ * optional_ioctl_va  -
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_post_mcc_wrb(struct BE_FUNCTION_OBJECT *funcobj,
+			 struct MCC_WRB_AMAP *wrb,
+			 MCC_WRB_CQE_CALLBACK callback,
+			 void *callback_context,
+			 void *optional_ioctl_va);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_mac_address_read_write
+ *   Reads or writes the MAC address.
+ * pfob    -
+ * port1              - Specifies port 0 or 1
+ * mac1               - Specifies addres 0 or 1 (BE has 2 per port)
+ * mgmt               - Specifies the management port. If TRUE, the
+ * 			port1 and mac1
+ *                      parameters are ignored.
+ * write              - If TRUE, the MAC address is set.
+ * permanent          - If TRUE, the MAC read is the permanent address
+ * mac_address        - Address to set, or address returned.
+ * callback           - optional
+ * callback_context   - optional
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_mac_address_read_write(struct BE_FUNCTION_OBJECT *pfob,
+			      bool port1,
+			      bool mac1,
+			      bool mgmt,
+			      bool write,
+			      bool permanent,
+			      struct SA_MAC_ADDRESS *mac_address,
+			      MCC_WRB_CQE_CALLBACK callback,
+			      void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_multicast_config
+ *   Writes all multicast addresses for this protection domain.
+ *   This function is called as part of be_function_cleanup to
+ *   remove all multicast filters.
+ * pfob    -
+ * promiscuous        - TRUE, enables promiscuous mode where all multicast
+ * 			packets are passed up. Allows supporting >32
+ * 			multicast addresses.
+ * num                - number of mac addresses in the table. Max=32.
+ * mac_table          -
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation. It
+ *                      will be posted to the MCC ring when space
+ *                      becomes available. All queued commands will be
+ *                      posted to the ring in the order they are
+ *                      received. It is always valid to pass a pointer
+ *                      to a generic BE_GENERIC_QUEUE_CONTEXT. However, the
+ *                      specific context structs are generally smaller
+ *                      than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_multicast_config(struct BE_FUNCTION_OBJECT *pfob,
+			bool promiscuous,
+			u32 num,
+			struct SA_MAC_ADDRESS *mac_table,
+			MCC_WRB_CQE_CALLBACK callback,
+			void *callback_context,
+			struct BE_MULTICAST_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_vlan_config
+ *   Writes all vlan tags for this protection domain. This function
+ *   is called as part of be_function_cleanup to remove all vlan filters.
+ * pfob    -
+ * promiscuous        - TRUE, enables promiscuous mode where all
+ * 			vlan packets are passed up the stack. Allows
+ * 			supporting >32 vlan tags.
+ * num                - Number of vlan tags in the array.
+ * vlan_tag_array     -
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is used
+ * 			to queue the operation. It will be posted to the
+ * 			MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring in
+ *                      the order they are received. It is always valid
+ *                      to pass a pointer to a generic
+ *                      BE_GENERIC_QUEUE_CONTEXT. However, the specific
+ *                      context structs are generally smaller than
+ *                      the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_vlan_config(struct BE_FUNCTION_OBJECT *pfob,
+		   bool promiscuous,
+		   u32 num,
+		   u16 *vlan_tag_array,
+		   MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct BE_VLAN_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_wake_on_lan_config
+ *   Configures wake-on-lan for the controller. Wake-on-lan is only
+ *   supported for the host system virtual machine - wake-on-lan is not
+ *   supported per protection domain. To enable magic packet
+ *   reception, use null pointer arguments for pattern & pattern mask,
+ *   set magic_packet_enable to true, and set the port enables
+ *   to true. To disable magic packet reception, use null pointer
+ *   arguments for pattern & pattern mask, set magic_packet_enable to true,
+ *   and set the port enables to false. To remove a pattern, set both
+ *   enable_port0 and enable_port1 to FALSE, and provide the index
+ *   you previously used to enable the pattern. This function is
+ *   not called as part of be_function_cleanup to remove all wake-on-lan
+ *   patterns, since be_function_cleanup could be called when the
+ *   system wants to wake up on a magic or interesting packet.
+ * pfob     -
+ * enable_port0        - If TRUE, enable this pattern for port0.
+ * enable_port1        - If TRUE, enable this pattern for port1.
+ * magic_packet_enable - If TRUE, enable magic packet for the enabled ports.
+ * index               - index 0-3 for the packet to program
+ * pattern             - 128 byte magic pattern
+ * pattern_mask        - 128 bit mask indicating which bytes in the
+ * 			pattern should be matched.
+ * callback            - optional
+ * callback_context    - optional
+ * queue_context       - Optional. Pointer to a previously allocated struct.
+ * 			 If the MCC WRB ring is full, this structure is
+ * 			 used to queue the operation. It will be posted
+ * 			 to the MCC ring when space becomes available.
+ * 			 All queued commands will be posted to the
+ * 			 ring in the order they are received. It is
+ * 			 always valid to pass a pointer to a generic
+ * 			 BE_GENERIC_QUEUE_CONTEXT. However, the specific
+ * 			 context structs are generally smaller than
+ * 			 the generic struct.
+ * return pend_status  - BE_SUCCESS (0) on success. BE_PENDING
+ * 			 (postive value) if the IOCTL completion
+ * 			 is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_wake_on_lan_config(struct BE_FUNCTION_OBJECT *pfob,
+			bool enable_port0, bool enable_port1,
+			bool magic_packet_enable, u32 index,
+			void *pattern, void *pattern_mask,
+			MCC_WRB_CQE_CALLBACK callback,
+			void *callback_context,
+			struct BE_WAKE_ON_LAN_QUEUE_CONTEXT *queue_context);
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_rss_config
+ *   Configures Receive Side Scaling for the host networking function.
+ *   This function is called as part of be_function_cleanup
+ *   to disable RSS.
+ * pfob    -
+ * rss_type           - Use enumeration ENABLE_RSS_ENUM.
+ * num_cq             - Number of RSS CQs. 0, 2, 3, or 4
+ * cq_id_array        - Array of num_cq IDs for RSS CQs.
+ * default_cq_id      - CQ id for the default non-RSS ethernet CQ.
+ * flush_mask         - Mask of CQ ids to flush.
+ * hash               - 16 byte hash.
+ * cpu_table_length   - bytes (power of 2 from 2 to 128)
+ * cpu_table          - cpu_table_length bytes. Each byte
+ * 			indicates a CPU from 0 to num_cq-1.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation. It
+ *                      will be posted to the MCC ring when space
+ *                      becomes available. All queued commands will be
+ *                      posted to the ring in the order they are
+ *                      received. It is always valid to pass
+ *                      a pointer to a generic BE_GENERIC_QUEUE_CONTEXT.
+ *                      However, the specific context structs
+ *                      are generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING
+ * 			(postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_rss_config(struct BE_FUNCTION_OBJECT *pfob,
+		  u32 rss_type, u32 num_cq, u32 *cq_id_array,
+		  u32 default_cq_id, u32 flush_mask, void *hash,
+		  u32 cpu_table_length, u8 *cpu_table,
+		  MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		  struct BE_RSS_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_link_status
+ *   Queries the link status.
+ * pfob    -
+ * link_status        - returned status
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
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_link_status(struct BE_FUNCTION_OBJECT *pfob,
+		   struct BE_LINK_STATUS *link_status,
+		   MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct BE_LINK_STATUS_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_query_eth_statistics
+ *   Queries the ethernet statistics. The resulting statistics are
+ *   stored in the ioctl response buffer.
+ * pfob    -
+ * va_for_ioctl       - Virtual address of the IOCTL buffer. This buffer must be
+ *                      physically contiguous.
+ * pa_for_ioctl       - Physical address of the IOCTL buffer. This buffer must
+ * 			be physically contiguous.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation.
+ * 			It will be posted to the MCC ring when space
+ * 			becomes available. All queued commands will be posted
+ * 			to the ring in the order they are received.
+ * 			It is always valid to pass a pointer to a
+ * 			generic BE_GENERIC_QUEUE_CONTEXT. However, the
+ * 			specific context structs are generally smaller than
+ * 			the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING (postive value)
+ * 			if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_query_eth_statistics(struct BE_FUNCTION_OBJECT *pfob,
+		struct IOCTL_ETH_GET_STATISTICS *va_for_ioctl,
+		u64 pa_for_ioctl, MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct BE_NONEMBEDDED_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_promiscuous
+ *   Enables or disables promiscuous mode for each MAC port.
+ * pfob    -
+ * enable_port0       - Enable/Disable promiscuous mode on port 0.
+ * enable_port1       - Enable/Disable promiscuous mode on port 1.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation.
+ * 			It will be posted to the MCC ring when space
+ * 			becomes available. All queued commands will be
+ * 			posted to the ring in the order they are
+ * 			received. It is always valid to pass a
+ * 			pointer to a generic BE_GENERIC_QUEUE_CONTEXT.
+ * 			However, the specific context structs are
+ * 			generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_promiscuous(struct BE_FUNCTION_OBJECT *pfob,
+		   bool enable_port0,
+		   bool enable_port1,
+		   MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct BE_PROMISCUOUS_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_force_failover
+ *   Forces failure of all traffic to the specified MAC port. Use
+ *   the be_rxf_link_status to query to active port. Automatic failover
+ *   feature of BladeEngine is implicitly disabled with this call.
+ * pfob    -
+ * port               - Port to use, 0 or 1.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			BE_QUEUE_CONTEXT struct. If the MCC WRB ring
+ * 			is full, this structure is used to queue
+ * 			the operation. It will be posted to the
+ * 			MCC ring when space becomes available. All
+ * 			queued commands will be posted to the ring in
+ * 			the order they are received.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING
+ * 			(postive value) if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_force_failover(struct BE_FUNCTION_OBJECT *pfob,
+		u32 port,
+		MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct BE_FORCE_FAILOVER_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
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
+ * 			used to queue the operation. It will be posted to
+ * 			the MCC ring when space becomes available. All
+ * 			queued commands will be posted to the ring in
+ * 			the order they are received. It is always valid
+ * 			to pass a pointer to a generic
+ * 			BE_GENERIC_QUEUE_CONTEXT. However, the
+ * 			specific context structs are generally
+ * 			smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING (postive value)
+ * 			if the IOCTL
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_filter_config(struct BE_FUNCTION_OBJECT *pfob,
+		     struct NTWK_RX_FILTER_SETTINGS *settings,
+		     MCC_WRB_CQE_CALLBACK callback,
+		     void *callback_context,
+		     struct BE_RXF_FILTER_QUEUE_CONTEXT *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_enable_interrupts
+ *   Enables interrupts for the given PCI function.
+ * pfob    -
+ * return return_type -
+ *---------------------------------------------------------------
+ */
+void be_function_enable_interrupts(struct BE_FUNCTION_OBJECT *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_disable_interrupts
+ *   Disables interrupts for the given PCI function.
+ * pfob    -
+ * return return_type -
+ *---------------------------------------------------------------
+ */
+void
+be_function_disable_interrupts(struct BE_FUNCTION_OBJECT *pfob);
+
+#endif /* __beclib_ll_bmap_h__ */
diff --git a/drivers/message/beclib/beclib_ll_enum_nic.h b/drivers/message/beclib/beclib_ll_enum_nic.h
new file mode 100644
index 0000000..dbc45f0
--- /dev/null
+++ b/drivers/message/beclib/beclib_ll_enum_nic.h
@@ -0,0 +1,63 @@
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
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __beclib_ll_enum_h__
+#define __beclib_ll_enum_h__
+
+/* --- BE_FUNCTION_ENUM --- */
+#define BE_FUNCTION_TYPE_ISCSI          (0)
+#define BE_FUNCTION_TYPE_NETWORK        (1)
+#define BE_FUNCTION_TYPE_ARM            (2)
+
+enum BE_FUNCTION_ENUM {
+	ENUM_BE_FUNCTION_TYPE_ISCSI = 0x0UL,
+	ENUM_BE_FUNCTION_TYPE_NETWORK = 0x1UL,
+	ENUM_BE_FUNCTION_TYPE_ARM = 0x2UL
+} ;
+
+/* --- BE_ETH_TX_RING_TYPE_ENUM --- */
+#define BE_ETH_TX_RING_TYPE_FORWARDING  (1) 	/* Ether ring for forwarding */
+#define BE_ETH_TX_RING_TYPE_STANDARD    (2)	/* Ether ring for sending */
+						/* network packets. */
+#define BE_ETH_TX_RING_TYPE_BOUND       (3)	/* Ethernet ring for sending */
+						/* network packets, bound */
+						/* to a physical port. */
+
+enum BE_ETH_TX_RING_TYPE_ENUM {
+	ENUM_BE_ETH_TX_RING_TYPE_FORWARDING = 0x1UL,
+	ENUM_BE_ETH_TX_RING_TYPE_STANDARD = 0x2UL,
+	ENUM_BE_ETH_TX_RING_TYPE_BOUND = 0x3UL
+} ;
+
+#endif /* __beclib_ll_enum_h__ */
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

