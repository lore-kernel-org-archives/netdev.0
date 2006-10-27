From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 3/5] NetEffect 10Gb RNIC Userspace Library: userspace header files
Date: Thu, 26 Oct 2006 19:47:40 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9ECF@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:6370 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1423735AbWJ0Arl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:47:41 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace driver patch 3 of 5.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/src/userspace/libnes/src/nes-abi.h
new/src/userspace/libnes/src/nes-abi.h
--- old/src/userspace/libnes/src/nes-abi.h	1969-12-31
18:00:00.000000000 -0600
+++ new/src/userspace/libnes/src/nes-abi.h	2006-10-25
10:27:58.000000000 -0500
@@ -0,0 +1,99 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
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
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef nes_ABI_H
+#define nes_ABI_H
+
+#include <infiniband/kern-abi.h>
+
+struct nes_ualloc_ucontext_resp {
+	struct ibv_get_context_resp ibv_resp;
+	__u32 max_pds; /* maximum pds allowed for this user process */
+	__u32 max_qps; /* maximum qps allowed for this user process */
+	__u32 wq_size; /* defines the size of the WQs (sq+rq) allocated
to the mmaped area */
+	__u32 reserved;
+};
+
+struct nes_ualloc_pd_resp {
+	struct ibv_alloc_pd_resp ibv_resp;
+	__u32 pd_id;
+	__u32 db_index;
+};
+
+struct nes_ucreate_cq {
+	struct ibv_create_cq ibv_cmd;
+   __u64 user_cq_buffer;
+};
+
+enum nes_umemreg_type {
+	NES_UMEMREG_TYPE_MEM = 0x0000,
+	NES_UMEMREG_TYPE_QP = 0x0001,
+	NES_UMEMREG_TYPE_CQ = 0x0002,
+};
+
+struct nes_ureg_mr {
+	struct ibv_reg_mr ibv_cmd;
+	__u32 reg_type; /* indicates if id is memory, QP or CQ */
+	__u32 reserved; /* QP or CQ ID */
+};
+
+struct nes_ucreate_cq_resp {
+	struct ibv_create_cq_resp ibv_resp;
+	__u32 cq_id;
+	__u32 cq_size;
+	__u32 mmap_db_index;
+	__u32 reserved;
+};
+
+struct nes_ucreate_qp {
+	struct ibv_create_qp ibv_cmd;
+};
+
+struct nes_ucreate_qp_resp {
+	struct ibv_create_qp_resp ibv_resp;
+	__u32 qp_id;
+	__u32 actual_sq_size;
+	__u32 actual_rq_size;
+	__u32 mmap_sq_db_index;
+	__u32 mmap_rq_db_index;
+	__u32 reserved;
+};
+
+
+struct nes_cqe {
+	__u32 header;
+	__u32 len;
+	__u32 wrid_hi_stag;
+	__u32 wrid_low_msn;
+};
+
+#endif				/* nes_ABI_H */
diff -ruNp old/src/userspace/libnes/src/nes.map
new/src/userspace/libnes/src/nes.map
--- old/src/userspace/libnes/src/nes.map	1969-12-31
18:00:00.000000000 -0600
+++ new/src/userspace/libnes/src/nes.map	2006-10-25
11:11:45.000000000 -0500
@@ -0,0 +1,6 @@
+{
+	global:
+		ibv_driver_init;
+		openib_driver_init;
+	local: *;
+};
diff -ruNp old/src/userspace/libnes/src/nes_umain.h
new/src/userspace/libnes/src/nes_umain.h
--- old/src/userspace/libnes/src/nes_umain.h	1969-12-31
18:00:00.000000000 -0600
+++ new/src/userspace/libnes/src/nes_umain.h	2006-10-25
10:27:59.000000000 -0500
@@ -0,0 +1,271 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
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
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef nes_umain_H
+#define nes_umain_H
+
+#include <infiniband/driver.h>
+#include <infiniband/arch.h>
+
+#define HIDDEN __attribute__((visibility ("hidden")))
+
+#define PFX	"nes: "
+
+#define NES_MAX_SQ_PAYLOAD_SIZE	0x40000000	/* for errata 5,
bug 2784 */
+
+enum nes_cqe_opcode_bits {
+	NES_CQE_STAG_VALID = (1<<6),
+	NES_CQE_ERROR = (1<<7),
+	NES_CQE_SQ = (1<<8),
+	NES_CQE_SE = (1<<9),
+	NES_CQE_PSH = (1<<29),
+	NES_CQE_FIN = (1<<30),
+	NES_CQE_VALID = (1<<31),
+};
+
+enum nes_cqe_word_idx {
+	NES_CQE_PAYLOAD_LENGTH_IDX = 0,
+	NES_CQE_COMP_COMP_CTX_LOW_IDX = 2,
+	NES_CQE_COMP_COMP_CTX_HIGH_IDX = 3,
+	NES_CQE_INV_STAG_IDX = 4,
+	NES_CQE_QP_ID_IDX = 5,
+	NES_CQE_ERROR_CODE_IDX = 6,
+	NES_CQE_OPCODE_IDX = 7,
+};
+
+enum nes_cqe_allocate_bits {
+	NES_CQE_ALLOC_INC_SELECT = (1<<28),
+	NES_CQE_ALLOC_NOTIFY_NEXT = (1<<29),
+	NES_CQE_ALLOC_NOTIFY_SE = (1<<30),
+	NES_CQE_ALLOC_RESET = (1<<31),
+};
+
+enum nes_iwarp_sq_wqe_word_idx {
+	NES_IWARP_SQ_WQE_MISC_IDX = 0,
+	NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX = 1,
+	NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX = 2,
+	NES_IWARP_SQ_WQE_COMP_CTX_HIGH_IDX = 3,
+	NES_IWARP_SQ_WQE_COMP_SCRATCH_LOW_IDX = 4,
+	NES_IWARP_SQ_WQE_COMP_SCRATCH_HIGH_IDX = 5,
+	NES_IWARP_SQ_WQE_INV_STAG_LOW_IDX = 7,
+	NES_IWARP_SQ_WQE_RDMA_TO_LOW_IDX = 8,
+	NES_IWARP_SQ_WQE_RDMA_TO_HIGH_IDX = 9,
+	NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX = 10,
+	NES_IWARP_SQ_WQE_RDMA_STAG_IDX = 11,
+	NES_IWARP_SQ_WQE_FRAG0_LOW_IDX = 16,
+	NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX = 17,
+	NES_IWARP_SQ_WQE_LENGTH0_IDX = 18,
+	NES_IWARP_SQ_WQE_STAG0_IDX = 19,
+	NES_IWARP_SQ_WQE_FRAG1_LOW_IDX = 20,
+	NES_IWARP_SQ_WQE_FRAG1_HIGH_IDX = 21,
+	NES_IWARP_SQ_WQE_LENGTH1_IDX = 22,
+	NES_IWARP_SQ_WQE_STAG1_IDX = 23,
+	NES_IWARP_SQ_WQE_FRAG2_LOW_IDX = 24,
+	NES_IWARP_SQ_WQE_FRAG2_HIGH_IDX = 25,
+	NES_IWARP_SQ_WQE_LENGTH2_IDX = 26,
+	NES_IWARP_SQ_WQE_STAG2_IDX = 27,
+	NES_IWARP_SQ_WQE_FRAG3_LOW_IDX = 28,
+	NES_IWARP_SQ_WQE_FRAG3_HIGH_IDX = 29,
+	NES_IWARP_SQ_WQE_LENGTH3_IDX = 30,
+	NES_IWARP_SQ_WQE_STAG3_IDX = 31,
+};
+
+enum nes_iwarp_rq_wqe_word_idx {
+	NES_IWARP_RQ_WQE_TOTAL_PAYLOAD_IDX = 1,
+	NES_IWARP_RQ_WQE_COMP_CTX_LOW_IDX = 2,
+	NES_IWARP_RQ_WQE_COMP_CTX_HIGH_IDX = 3,
+	NES_IWARP_RQ_WQE_COMP_SCRATCH_LOW_IDX = 4,
+	NES_IWARP_RQ_WQE_COMP_SCRATCH_HIGH_IDX = 5,
+	NES_IWARP_RQ_WQE_FRAG0_LOW_IDX = 8,
+	NES_IWARP_RQ_WQE_FRAG0_HIGH_IDX = 9,
+	NES_IWARP_RQ_WQE_LENGTH0_IDX = 10,
+	NES_IWARP_RQ_WQE_STAG0_IDX = 11,
+	NES_IWARP_RQ_WQE_FRAG1_LOW_IDX = 12,
+	NES_IWARP_RQ_WQE_FRAG1_HIGH_IDX = 13,
+	NES_IWARP_RQ_WQE_LENGTH1_IDX = 14,
+	NES_IWARP_RQ_WQE_STAG1_IDX = 15,
+	NES_IWARP_RQ_WQE_FRAG2_LOW_IDX = 16,
+	NES_IWARP_RQ_WQE_FRAG2_HIGH_IDX = 17,
+	NES_IWARP_RQ_WQE_LENGTH2_IDX = 18,
+	NES_IWARP_RQ_WQE_STAG2_IDX = 19,
+	NES_IWARP_RQ_WQE_FRAG3_LOW_IDX = 20,
+	NES_IWARP_RQ_WQE_FRAG3_HIGH_IDX = 21,
+	NES_IWARP_RQ_WQE_LENGTH3_IDX = 22,
+	NES_IWARP_RQ_WQE_STAG3_IDX = 23,
+};
+
+enum nes_iwarp_sq_opcodes {
+	NES_IWARP_SQ_WQE_STREAMING = (1<<23),
+	NES_IWARP_SQ_WQE_READ_FENCE = (1<<29),
+	NES_IWARP_SQ_WQE_LOCAL_FENCE = (1<<30),
+	NES_IWARP_SQ_WQE_SIGNALED_COMPL = (1<<31),
+};
+
+enum nes_iwarp_sq_wqe_bits {
+	NES_IWARP_SQ_OP_RDMAW = 0,
+	NES_IWARP_SQ_OP_RDMAR = 1,
+	NES_IWARP_SQ_OP_SEND = 3,
+	NES_IWARP_SQ_OP_SENDINV = 4,
+	NES_IWARP_SQ_OP_SENDSE = 5,
+	NES_IWARP_SQ_OP_SENDSEINV = 6,
+	NES_IWARP_SQ_OP_BIND = 8,
+	NES_IWARP_SQ_OP_FAST_REG = 9,
+	NES_IWARP_SQ_OP_LOCINV = 10,
+	NES_IWARP_SQ_OP_RDMAR_LOCINV = 11,
+	NES_IWARP_SQ_OP_NOP = 12,
+};
+
+struct nes_hw_qp_wqe {
+   uint32_t wqe_words[32];
+};
+
+struct nes_hw_cqe {
+   uint32_t cqe_words[8];
+};
+
+enum nes_uhca_type {
+	NETEFFECT_nes
+};
+
+struct nes_user_doorbell {
+   uint32_t wqe_alloc;
+   uint32_t reserved[3];
+   uint32_t cqe_alloc;
+};
+
+struct nes_udevice {
+	struct ibv_device ibv_dev;
+	enum nes_uhca_type hca_type;
+	int page_size;
+};
+
+struct nes_upd {
+	struct ibv_pd ibv_pd;
+	struct nes_user_doorbell volatile *udoorbell;
+	uint32_t pd_id;
+	uint32_t db_index;
+};
+
+struct nes_uvcontext {
+	struct ibv_context ibv_ctx;
+	struct nes_upd *nesupd;
+	uint32_t max_pds; /* maximum pds allowed for this user process
*/
+	uint32_t max_qps; /* maximum qps allowed for this user process
*/
+	uint32_t wq_size; /* defines the size of the WQs (sq+rq)
allocated to the mmaped area */
+};
+
+struct nes_ucq {
+	struct ibv_cq ibv_cq;
+	struct nes_hw_cqe volatile *cqes;
+	struct ibv_mr mr;
+	uint32_t cq_id;
+	uint16_t size;
+	uint16_t head;
+	uint16_t polled_completions;
+};
+
+struct nes_uqp {
+	struct ibv_qp ibv_qp;
+	struct nes_hw_qp_wqe volatile *sq_vbase;
+	struct nes_hw_qp_wqe volatile *rq_vbase;
+	uint32_t qp_id;
+	uint32_t bytes_sent;
+	uint16_t sq_db_index;
+	uint16_t sq_head;
+	uint16_t sq_tail;
+	uint16_t sq_size;
+	uint16_t rq_db_index;
+	uint16_t rq_head;
+	uint16_t rq_tail;
+	uint16_t rq_size;
+};
+
+#define to_nes_uxxx(xxx, type)
\
+	((struct nes_u##type *)					\
+	 ((void *) ib##xxx - offsetof(struct nes_u##type, ibv_##xxx)))
+
+static inline struct nes_udevice *to_nes_udev(struct ibv_device *ibdev)
+{
+	return to_nes_uxxx(dev, device);
+}
+
+static inline struct nes_uvcontext *to_nes_uctx(struct ibv_context
*ibctx)
+{
+	return to_nes_uxxx(ctx, vcontext);
+}
+
+static inline struct nes_upd *to_nes_upd(struct ibv_pd *ibpd)
+{
+	return to_nes_uxxx(pd, pd);
+}
+
+static inline struct nes_ucq *to_nes_ucq(struct ibv_cq *ibcq)
+{
+	return to_nes_uxxx(cq, cq);
+}
+
+static inline struct nes_uqp *to_nes_uqp(struct ibv_qp *ibqp)
+{
+	return to_nes_uxxx(qp, qp);
+}
+
+
+/* nes_umain.c */
+struct ibv_device *ibv_driver_init(const char *, int);
+
+/* nes_uverbs.c */
+int nes_uquery_device(struct ibv_context *, struct ibv_device_attr *);
+int nes_uquery_port(struct ibv_context *, uint8_t, struct ibv_port_attr
*);
+struct ibv_pd *nes_ualloc_pd(struct ibv_context *);
+int nes_ufree_pd(struct ibv_pd *);
+struct ibv_mr *nes_ureg_mr(struct ibv_pd *, void *, size_t, enum
ibv_access_flags);
+int nes_udereg_mr(struct ibv_mr *);
+struct ibv_cq *nes_ucreate_cq(struct ibv_context *, int, struct
ibv_comp_channel *, int);
+int nes_uresize_cq(struct ibv_cq *, int);
+int nes_udestroy_cq(struct ibv_cq *);
+int nes_upoll_cq(struct ibv_cq *, int, struct ibv_wc *);
+int nes_uarm_cq(struct ibv_cq *, int);
+struct ibv_srq *nes_ucreate_srq(struct ibv_pd *, struct
ibv_srq_init_attr *);
+int nes_umodify_srq(struct ibv_srq *, struct ibv_srq_attr *, enum
ibv_srq_attr_mask);
+int nes_udestroy_srq(struct ibv_srq *);
+int nes_upost_srq_recv(struct ibv_srq *, struct ibv_recv_wr *, struct
ibv_recv_wr **);
+struct ibv_qp *nes_ucreate_qp(struct ibv_pd *, struct ibv_qp_init_attr
*);
+int nes_umodify_qp(struct ibv_qp *, struct ibv_qp_attr *, enum
ibv_qp_attr_mask);
+int nes_udestroy_qp(struct ibv_qp *);
+int nes_upost_send(struct ibv_qp *, struct ibv_send_wr *, struct
ibv_send_wr **);
+int nes_upost_recv(struct ibv_qp *, struct ibv_recv_wr *, struct
ibv_recv_wr **);
+struct ibv_ah *nes_ucreate_ah(struct ibv_pd *, struct ibv_ah_attr *);
+int nes_udestroy_ah(struct ibv_ah *);
+int nes_uattach_mcast(struct ibv_qp *, union ibv_gid *, uint16_t);
+int nes_udetach_mcast(struct ibv_qp *, union ibv_gid *, uint16_t);
+
+#endif				/* nes_umain_H */



