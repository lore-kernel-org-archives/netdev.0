From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v4 04/16] IB/pvrdma: Add the paravirtual RDMA device specification
Date: Sun, 11 Sep 2016 21:49:14 -0700
Message-ID: <1473655766-31628-5-git-send-email-aditr@vmware.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:34207 "EHLO
        EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754171AbcILEub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 00:50:31 -0400
In-Reply-To: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch describes the main specification of the underlying virtual RDMA
device. The pvrdma_dev_api header file defines the Verbs commands and
their parameters that can be issued to the device backend.

Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>
Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
Reviewed-by: George Zhang <georgezhang@vmware.com>
Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
Reviewed-by: Bryan Tan <bryantan@vmware.com>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
Changes v3->v4:
 - Removed explicit enum values.

Changes v2->v3:
 - Defined 9 and 18 for page directory.
 - Stripped spaces in some comments.
---
 drivers/infiniband/hw/pvrdma/pvrdma_defs.h    | 302 +++++++++++++++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h | 342 ++++++++++++++++++++++++++
 2 files changed, 644 insertions(+)
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_defs.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h

diff --git a/drivers/infiniband/hw/pvrdma/pvrdma_defs.h b/drivers/infiniband/hw/pvrdma/pvrdma_defs.h
new file mode 100644
index 0000000..de7d1fb
--- /dev/null
+++ b/drivers/infiniband/hw/pvrdma/pvrdma_defs.h
@@ -0,0 +1,302 @@
+/*
+ * Copyright (c) 2012-2016 VMware, Inc.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of EITHER the GNU General Public License
+ * version 2 as published by the Free Software Foundation or the BSD
+ * 2-Clause License. This program is distributed in the hope that it
+ * will be useful, but WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED
+ * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License version 2 for more details at
+ * http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program available in the file COPYING in the main
+ * directory of this source tree.
+ *
+ * The BSD 2-Clause License
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
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
+ * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
+ * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
+ * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+ * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
+ * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
+ * OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __PVRDMA_DEFS_H__
+#define __PVRDMA_DEFS_H__
+
+#include <linux/types.h>
+#include "pvrdma_ib_verbs.h"
+#include "pvrdma_uapi.h"
+
+/*
+ * Masks and accessors for page directory, which is a two-level lookup:
+ * page directory -> page table -> page. Only one directory for now, but we
+ * could expand that easily. 9 bits for tables, 9 bits for pages, gives one
+ * gigabyte for memory regions and so forth.
+ */
+
+#define PVRDMA_PDIR_SHIFT		18
+#define PVRDMA_PTABLE_SHIFT		9
+#define PVRDMA_PAGE_DIR_DIR(x)		(((x) >> PVRDMA_PDIR_SHIFT) & 0x1)
+#define PVRDMA_PAGE_DIR_TABLE(x)	(((x) >> PVRDMA_PTABLE_SHIFT) & 0x1ff)
+#define PVRDMA_PAGE_DIR_PAGE(x)		((x) & 0x1ff)
+#define PVRDMA_PAGE_DIR_MAX_PAGES	(1 * 512 * 512)
+#define PVRDMA_MAX_FAST_REG_PAGES	128
+
+/*
+ * Max MSI-X vectors.
+ */
+
+#define PVRDMA_MAX_INTERRUPTS	3
+
+/* Register offsets within PCI resource on BAR1. */
+#define PVRDMA_REG_VERSION	0x00	/* R: Version of device. */
+#define PVRDMA_REG_DSRLOW	0x04	/* W: Device shared region low PA. */
+#define PVRDMA_REG_DSRHIGH	0x08	/* W: Device shared region high PA. */
+#define PVRDMA_REG_CTL		0x0c	/* W: PVRDMA_DEVICE_CTL */
+#define PVRDMA_REG_REQUEST	0x10	/* W: Indicate device request. */
+#define PVRDMA_REG_ERR		0x14	/* R: Device error. */
+#define PVRDMA_REG_ICR		0x18	/* R: Interrupt cause. */
+#define PVRDMA_REG_IMR		0x1c	/* R/W: Interrupt mask. */
+#define PVRDMA_REG_MACL		0x20	/* R/W: MAC address low. */
+#define PVRDMA_REG_MACH		0x24	/* R/W: MAC address high. */
+
+/* Object flags. */
+#define PVRDMA_CQ_FLAG_ARMED_SOL	BIT(0)	/* Armed for solicited-only. */
+#define PVRDMA_CQ_FLAG_ARMED		BIT(1)	/* Armed. */
+#define PVRDMA_MR_FLAG_DMA		BIT(0)	/* DMA region. */
+#define PVRDMA_MR_FLAG_FRMR		BIT(1)	/* Fast reg memory region. */
+
+/*
+ * Atomic operation capability (masked versions are extended atomic
+ * operations.
+ */
+
+#define PVRDMA_ATOMIC_OP_COMP_SWAP	BIT(0) /* Compare and swap. */
+#define PVRDMA_ATOMIC_OP_FETCH_ADD	BIT(1) /* Fetch and add. */
+#define PVRDMA_ATOMIC_OP_MASK_COMP_SWAP	BIT(2) /* Masked compare and swap. */
+#define PVRDMA_ATOMIC_OP_MASK_FETCH_ADD	BIT(3) /* Masked fetch and add. */
+
+/*
+ * Base Memory Management Extension flags to support Fast Reg Memory Regions
+ * and Fast Reg Work Requests. Each flag represents a verb operation and we
+ * must support all of them to qualify for the BMME device cap.
+ */
+
+#define PVRDMA_BMME_FLAG_LOCAL_INV	BIT(0) /* Local Invalidate. */
+#define PVRDMA_BMME_FLAG_REMOTE_INV	BIT(1) /* Remote Invalidate. */
+#define PVRDMA_BMME_FLAG_FAST_REG_WR	BIT(2) /* Fast Reg Work Request. */
+
+/*
+ * GID types. The interpretation of the gid_types bit field in the device
+ * capabilities will depend on the device mode. For now, the device only
+ * supports RoCE as mode, so only the different GID types for RoCE are
+ * defined.
+ */
+
+#define PVRDMA_GID_TYPE_FLAG_ROCE_V1 BIT(0)
+#define PVRDMA_GID_TYPE_FLAG_ROCE_V2 BIT(1)
+
+enum pvrdma_pci_resource {
+	PVRDMA_PCI_RESOURCE_MSIX,	/* BAR0: MSI-X, MMIO. */
+	PVRDMA_PCI_RESOURCE_REG,	/* BAR1: Registers, MMIO. */
+	PVRDMA_PCI_RESOURCE_UAR,	/* BAR2: UAR pages, MMIO, 64-bit. */
+	PVRDMA_PCI_RESOURCE_LAST,	/* Last. */
+};
+
+enum pvrdma_device_ctl {
+	PVRDMA_DEVICE_CTL_ACTIVATE,	/* Activate device. */
+	PVRDMA_DEVICE_CTL_QUIESCE,	/* Quiesce device. */
+	PVRDMA_DEVICE_CTL_RESET,	/* Reset device. */
+};
+
+enum pvrdma_intr_vector {
+	PVRDMA_INTR_VECTOR_RESPONSE,	/* Command response. */
+	PVRDMA_INTR_VECTOR_ASYNC,	/* Async events. */
+	PVRDMA_INTR_VECTOR_CQ,		/* CQ notification. */
+	/* Additional CQ notification vectors. */
+};
+
+enum pvrdma_intr_cause {
+	PVRDMA_INTR_CAUSE_RESPONSE	= (1 << PVRDMA_INTR_VECTOR_RESPONSE),
+	PVRDMA_INTR_CAUSE_ASYNC		= (1 << PVRDMA_INTR_VECTOR_ASYNC),
+	PVRDMA_INTR_CAUSE_CQ		= (1 << PVRDMA_INTR_VECTOR_CQ),
+};
+
+enum pvrdma_intr_type {
+	PVRDMA_INTR_TYPE_INTX,		/* Legacy. */
+	PVRDMA_INTR_TYPE_MSI,		/* MSI. */
+	PVRDMA_INTR_TYPE_MSIX,		/* MSI-X. */
+};
+
+enum pvrdma_gos_bits {
+	PVRDMA_GOS_BITS_UNK,		/* Unknown. */
+	PVRDMA_GOS_BITS_32,		/* 32-bit. */
+	PVRDMA_GOS_BITS_64,		/* 64-bit. */
+};
+
+enum pvrdma_gos_type {
+	PVRDMA_GOS_TYPE_UNK,		/* Unknown. */
+	PVRDMA_GOS_TYPE_LINUX,		/* Linux. */
+};
+
+enum pvrdma_device_mode {
+	PVRDMA_DEVICE_MODE_ROCE,	/* RoCE. */
+	PVRDMA_DEVICE_MODE_IWARP,	/* iWarp. */
+	PVRDMA_DEVICE_MODE_IB,		/* InfiniBand. */
+};
+
+struct pvrdma_gos_info {
+	__u32 gos_bits:2;	/* W: PVRDMA_GOS_BITS_ */
+	__u32 gos_type:4;	/* W: PVRDMA_GOS_TYPE_ */
+	__u32 gos_ver:16;	/* W: Guest OS version. */
+	__u32 gos_misc:10;	/* W: Other. */
+	__u32 pad;		/* Pad to 8-byte alignment. */
+};
+
+struct pvrdma_device_caps {
+	__u64 fw_ver;				/* R: Query device. */
+	__be64 node_guid;
+	__be64 sys_image_guid;
+	__u64 max_mr_size;
+	__u64 page_size_cap;
+	__u64 atomic_arg_sizes;			/* EXP verbs. */
+	__u32 exp_comp_mask;			/* EXP verbs. */
+	__u32 device_cap_flags2;		/* EXP verbs. */
+	__u32 max_fa_bit_boundary;		/* EXP verbs. */
+	__u32 log_max_atomic_inline_arg;	/* EXP verbs. */
+	__u32 vendor_id;
+	__u32 vendor_part_id;
+	__u32 hw_ver;
+	__u32 max_qp;
+	__u32 max_qp_wr;
+	__u32 device_cap_flags;
+	__u32 max_sge;
+	__u32 max_sge_rd;
+	__u32 max_cq;
+	__u32 max_cqe;
+	__u32 max_mr;
+	__u32 max_pd;
+	__u32 max_qp_rd_atom;
+	__u32 max_ee_rd_atom;
+	__u32 max_res_rd_atom;
+	__u32 max_qp_init_rd_atom;
+	__u32 max_ee_init_rd_atom;
+	__u32 max_ee;
+	__u32 max_rdd;
+	__u32 max_mw;
+	__u32 max_raw_ipv6_qp;
+	__u32 max_raw_ethy_qp;
+	__u32 max_mcast_grp;
+	__u32 max_mcast_qp_attach;
+	__u32 max_total_mcast_qp_attach;
+	__u32 max_ah;
+	__u32 max_fmr;
+	__u32 max_map_per_fmr;
+	__u32 max_srq;
+	__u32 max_srq_wr;
+	__u32 max_srq_sge;
+	__u32 max_uar;
+	__u32 gid_tbl_len;
+	__u16 max_pkeys;
+	__u8  local_ca_ack_delay;
+	__u8  phys_port_cnt;
+	__u8  mode;		/* PVRDMA_DEVICE_MODE_ */
+	__u8  atomic_ops;	/* PVRDMA_ATOMIC_OP_* bits */
+	__u8  bmme_flags;	/* Memory Mgmt Extensions for FRMR/FRWR */
+	__u8  gid_types;	/* PVRDMA_GID_TYPE_FLAG_ */
+	__u8  reserved[4];
+};
+
+struct pvrdma_ring_page_info {
+	__u32 num_pages;			/* Num pages incl. header. */
+	__u32 reserved;				/* Reserved. */
+	__u64 pdir_dma;				/* Page directory PA. */
+};
+
+#pragma pack(push, 1)
+
+struct pvrdma_device_shared_region {
+	__u32 driver_version;			/* W: Driver version. */
+	__u32 pad;				/* Pad to 8-byte align. */
+	struct pvrdma_gos_info gos_info;	/* W: Guest OS information. */
+	__u64 cmd_slot_dma;			/* W: Command slot address. */
+	__u64 resp_slot_dma;			/* W: Response slot address. */
+	struct pvrdma_ring_page_info async_ring_pages;
+						/* W: Async ring page info. */
+	struct pvrdma_ring_page_info cq_ring_pages;
+						/* W: CQ ring page info. */
+	__u32 uar_pfn;				/* W: UAR pageframe. */
+	__u32 pad2;				/* Pad to 8-byte align. */
+	struct pvrdma_device_caps caps;		/* R: Device capabilities. */
+};
+
+#pragma pack(pop)
+
+
+/* Event types. Currently a 1:1 mapping with enum ib_event. */
+enum pvrdma_eqe_type {
+	PVRDMA_EVENT_CQ_ERR,
+	PVRDMA_EVENT_QP_FATAL,
+	PVRDMA_EVENT_QP_REQ_ERR,
+	PVRDMA_EVENT_QP_ACCESS_ERR,
+	PVRDMA_EVENT_COMM_EST,
+	PVRDMA_EVENT_SQ_DRAINED,
+	PVRDMA_EVENT_PATH_MIG,
+	PVRDMA_EVENT_PATH_MIG_ERR,
+	PVRDMA_EVENT_DEVICE_FATAL,
+	PVRDMA_EVENT_PORT_ACTIVE,
+	PVRDMA_EVENT_PORT_ERR,
+	PVRDMA_EVENT_LID_CHANGE,
+	PVRDMA_EVENT_PKEY_CHANGE,
+	PVRDMA_EVENT_SM_CHANGE,
+	PVRDMA_EVENT_SRQ_ERR,
+	PVRDMA_EVENT_SRQ_LIMIT_REACHED,
+	PVRDMA_EVENT_QP_LAST_WQE_REACHED,
+	PVRDMA_EVENT_CLIENT_REREGISTER,
+	PVRDMA_EVENT_GID_CHANGE,
+};
+
+/* Event queue element. */
+struct pvrdma_eqe {
+	__u32 type;	/* Event type. */
+	__u32 info;	/* Handle, other. */
+};
+
+/* CQ notification queue element. */
+struct pvrdma_cqne {
+	__u32 info;	/* Handle */
+};
+
+static inline void pvrdma_init_cqe(struct pvrdma_cqe *cqe, __u64 wr_id,
+				   __u64 qp)
+{
+	memset(cqe, 0, sizeof(*cqe));
+	cqe->status = PVRDMA_WC_GENERAL_ERR;
+	cqe->wr_id = wr_id;
+	cqe->qp = qp;
+}
+
+#endif /* __PVRDMA_DEFS_H__ */
diff --git a/drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h b/drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h
new file mode 100644
index 0000000..4b4d8e5
--- /dev/null
+++ b/drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h
@@ -0,0 +1,342 @@
+/*
+ * Copyright (c) 2012-2016 VMware, Inc.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of EITHER the GNU General Public License
+ * version 2 as published by the Free Software Foundation or the BSD
+ * 2-Clause License. This program is distributed in the hope that it
+ * will be useful, but WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED
+ * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License version 2 for more details at
+ * http://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program available in the file COPYING in the main
+ * directory of this source tree.
+ *
+ * The BSD 2-Clause License
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
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
+ * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
+ * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
+ * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+ * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
+ * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
+ * OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __PVRDMA_DEV_API_H__
+#define __PVRDMA_DEV_API_H__
+
+#include <linux/types.h>
+#include "pvrdma_ib_verbs.h"
+
+enum {
+	PVRDMA_CMD_FIRST = 0,
+	PVRDMA_CMD_QUERY_PORT = PVRDMA_CMD_FIRST,
+	PVRDMA_CMD_QUERY_PKEY,
+	PVRDMA_CMD_CREATE_PD,
+	PVRDMA_CMD_DESTROY_PD,
+	PVRDMA_CMD_CREATE_MR,
+	PVRDMA_CMD_DESTROY_MR,
+	PVRDMA_CMD_CREATE_CQ,
+	PVRDMA_CMD_RESIZE_CQ,
+	PVRDMA_CMD_DESTROY_CQ,
+	PVRDMA_CMD_CREATE_QP,
+	PVRDMA_CMD_MODIFY_QP,
+	PVRDMA_CMD_QUERY_QP,
+	PVRDMA_CMD_DESTROY_QP,
+	PVRDMA_CMD_CREATE_UC,
+	PVRDMA_CMD_DESTROY_UC,
+	PVRDMA_CMD_CREATE_BIND,
+	PVRDMA_CMD_DESTROY_BIND,
+	PVRDMA_CMD_MAX,
+};
+
+enum {
+	PVRDMA_CMD_FIRST_RESP = (1 << 31),
+	PVRDMA_CMD_QUERY_PORT_RESP = PVRDMA_CMD_FIRST_RESP,
+	PVRDMA_CMD_QUERY_PKEY_RESP,
+	PVRDMA_CMD_CREATE_PD_RESP,
+	PVRDMA_CMD_DESTROY_PD_RESP_NOOP,
+	PVRDMA_CMD_CREATE_MR_RESP,
+	PVRDMA_CMD_DESTROY_MR_RESP_NOOP,
+	PVRDMA_CMD_CREATE_CQ_RESP,
+	PVRDMA_CMD_RESIZE_CQ_RESP,
+	PVRDMA_CMD_DESTROY_CQ_RESP_NOOP,
+	PVRDMA_CMD_CREATE_QP_RESP,
+	PVRDMA_CMD_MODIFY_QP_RESP,
+	PVRDMA_CMD_QUERY_QP_RESP,
+	PVRDMA_CMD_DESTROY_QP_RESP,
+	PVRDMA_CMD_CREATE_UC_RESP,
+	PVRDMA_CMD_DESTROY_UC_RESP_NOOP,
+	PVRDMA_CMD_CREATE_BIND_RESP_NOOP,
+	PVRDMA_CMD_DESTROY_BIND_RESP_NOOP,
+	PVRDMA_CMD_MAX_RESP,
+};
+
+struct pvrdma_cmd_hdr {
+	__u64 response;	/* Key for response lookup. */
+	__u32 cmd;	/* PVRDMA_CMD_ */
+	__u32 reserved;	/* Reserved. */
+};
+
+struct pvrdma_cmd_resp_hdr {
+	__u64 response;		/* From cmd hdr. */
+	__u32 ack;		/* PVRDMA_CMD_XXX_RESP */
+	__u8 err;		/* Error. */
+	__u8 reserved[3];	/* Reserved. */
+};
+
+struct pvrdma_cmd_query_port {
+	struct pvrdma_cmd_hdr hdr;
+	__u8 port_num;
+	__u8 reserved[7];
+};
+
+struct pvrdma_cmd_query_port_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	struct pvrdma_port_attr attrs;
+};
+
+struct pvrdma_cmd_query_pkey {
+	struct pvrdma_cmd_hdr hdr;
+	__u8 port_num;
+	__u8 index;
+	__u8 reserved[6];
+};
+
+struct pvrdma_cmd_query_pkey_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u16 pkey;
+	__u8 reserved[6];
+};
+
+struct pvrdma_cmd_create_uc {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 pfn; /* UAR page frame number */
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_uc_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 ctx_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_destroy_uc {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 ctx_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_pd {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 ctx_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_pd_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 pd_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_destroy_pd {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 pd_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_mr {
+	struct pvrdma_cmd_hdr hdr;
+	__u64 start;
+	__u64 length;
+	__u64 pdir_dma;
+	__u32 pd_handle;
+	__u32 access_flags;
+	__u32 flags;
+	__u32 nchunks;
+};
+
+struct pvrdma_cmd_create_mr_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 mr_handle;
+	__u32 lkey;
+	__u32 rkey;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_destroy_mr {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 mr_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_cq {
+	struct pvrdma_cmd_hdr hdr;
+	__u64 pdir_dma;
+	__u32 ctx_handle;
+	__u32 cqe;
+	__u32 nchunks;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_cq_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 cq_handle;
+	__u32 cqe;
+};
+
+struct pvrdma_cmd_resize_cq {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 cq_handle;
+	__u32 cqe;
+};
+
+struct pvrdma_cmd_resize_cq_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 cqe;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_destroy_cq {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 cq_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_qp {
+	struct pvrdma_cmd_hdr hdr;
+	__u64 pdir_dma;
+	__u32 pd_handle;
+	__u32 send_cq_handle;
+	__u32 recv_cq_handle;
+	__u32 srq_handle;
+	__u32 max_send_wr;
+	__u32 max_recv_wr;
+	__u32 max_send_sge;
+	__u32 max_recv_sge;
+	__u32 max_inline_data;
+	__u32 lkey;
+	__u32 access_flags;
+	__u16 total_chunks;
+	__u16 send_chunks;
+	__u16 max_atomic_arg;
+	__u8 sq_sig_all;
+	__u8 qp_type;
+	__u8 is_srq;
+	__u8 reserved[3];
+};
+
+struct pvrdma_cmd_create_qp_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 qpn;
+	__u32 max_send_wr;
+	__u32 max_recv_wr;
+	__u32 max_send_sge;
+	__u32 max_recv_sge;
+	__u32 max_inline_data;
+};
+
+struct pvrdma_cmd_modify_qp {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 qp_handle;
+	__u32 attr_mask;
+	struct pvrdma_qp_attr attrs;
+};
+
+struct pvrdma_cmd_query_qp {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 qp_handle;
+	__u32 attr_mask;
+};
+
+struct pvrdma_cmd_query_qp_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	struct pvrdma_qp_attr attrs;
+};
+
+struct pvrdma_cmd_destroy_qp {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 qp_handle;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_destroy_qp_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	__u32 events_reported;
+	__u8 reserved[4];
+};
+
+struct pvrdma_cmd_create_bind {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 mtu;
+	__u32 vlan;
+	__u32 index;
+	__u8 new_gid[16];
+	__u8 gid_type;
+	__u8 reserved[3];
+};
+
+struct pvrdma_cmd_destroy_bind {
+	struct pvrdma_cmd_hdr hdr;
+	__u32 index;
+	__u8 dest_gid[16];
+	__u8 reserved[4];
+};
+
+union pvrdma_cmd_req {
+	struct pvrdma_cmd_hdr hdr;
+	struct pvrdma_cmd_query_port query_port;
+	struct pvrdma_cmd_query_pkey query_pkey;
+	struct pvrdma_cmd_create_uc create_uc;
+	struct pvrdma_cmd_destroy_uc destroy_uc;
+	struct pvrdma_cmd_create_pd create_pd;
+	struct pvrdma_cmd_destroy_pd destroy_pd;
+	struct pvrdma_cmd_create_mr create_mr;
+	struct pvrdma_cmd_destroy_mr destroy_mr;
+	struct pvrdma_cmd_create_cq create_cq;
+	struct pvrdma_cmd_resize_cq resize_cq;
+	struct pvrdma_cmd_destroy_cq destroy_cq;
+	struct pvrdma_cmd_create_qp create_qp;
+	struct pvrdma_cmd_modify_qp modify_qp;
+	struct pvrdma_cmd_query_qp query_qp;
+	struct pvrdma_cmd_destroy_qp destroy_qp;
+	struct pvrdma_cmd_create_bind create_bind;
+	struct pvrdma_cmd_destroy_bind destroy_bind;
+};
+
+union pvrdma_cmd_resp {
+	struct pvrdma_cmd_resp_hdr hdr;
+	struct pvrdma_cmd_query_port_resp query_port_resp;
+	struct pvrdma_cmd_query_pkey_resp query_pkey_resp;
+	struct pvrdma_cmd_create_uc_resp create_uc_resp;
+	struct pvrdma_cmd_create_pd_resp create_pd_resp;
+	struct pvrdma_cmd_create_mr_resp create_mr_resp;
+	struct pvrdma_cmd_create_cq_resp create_cq_resp;
+	struct pvrdma_cmd_resize_cq_resp resize_cq_resp;
+	struct pvrdma_cmd_create_qp_resp create_qp_resp;
+	struct pvrdma_cmd_query_qp_resp query_qp_resp;
+	struct pvrdma_cmd_destroy_qp_resp destroy_qp_resp;
+};
+
+#endif /* __PVRDMA_DEV_API_H__ */
-- 
2.7.4
