From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 3/3] enic: add h/w interface files
Date: Mon, 8 Sep 2008 20:58:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809082053540.18196@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:7268 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241AbYIID7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 23:59:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: add hw/ interface files

These files are the h/w-facing interface for queues, interrupts, and 
control.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/cq_desc.h linux-2.6.26.3-enic/drivers/net/enic/cq_desc.h
--- linux-2.6.26.3/drivers/net/enic/cq_desc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/cq_desc.h	2008-09-08 15:16:21.000000000 -0700
@@ -0,0 +1,79 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _CQ_DESC_H_
+#define _CQ_DESC_H_
+
+/*
+ * Completion queue descriptor types
+ */
+enum cq_desc_types {
+	CQ_DESC_TYPE_WQ_ENET = 0,
+	CQ_DESC_TYPE_DESC_COPY = 1,
+	CQ_DESC_TYPE_WQ_EXCH = 2,
+	CQ_DESC_TYPE_RQ_ENET = 3,
+	CQ_DESC_TYPE_RQ_FCP = 4,
+};
+
+/* Completion queue descriptor: 16B
+ *
+ * All completion queues have this basic layout.  The
+ * type_specfic area is unique for each completion
+ * queue type.
+ */
+struct cq_desc {
+	__le16 completed_index;
+	__le16 q_number;
+	u8 type_specfic[11];
+	u8 type_color;
+};
+
+#define CQ_DESC_TYPE_BITS        7
+#define CQ_DESC_TYPE_MASK        ((1 << CQ_DESC_TYPE_BITS) - 1)
+#define CQ_DESC_COLOR_MASK       1
+#define CQ_DESC_Q_NUM_BITS       10
+#define CQ_DESC_Q_NUM_MASK       ((1 << CQ_DESC_Q_NUM_BITS) - 1)
+#define CQ_DESC_COMP_NDX_BITS    12
+#define CQ_DESC_COMP_NDX_MASK    ((1 << CQ_DESC_COMP_NDX_BITS) - 1)
+
+static inline void cq_desc_dec(const struct cq_desc *desc_arg,
+	u8 *type, u8 *color, u16 *q_number, u16 *completed_index)
+{
+	const struct cq_desc *desc = desc_arg;
+	const u8 type_color = desc->type_color;
+
+	*color = (type_color >> CQ_DESC_TYPE_BITS) & CQ_DESC_COLOR_MASK;
+
+	/*
+	 * Make sure color bit is read from desc *before* other fields
+	 * are read from desc.  Hardware guarantees color bit is last
+	 * bit (byte) written.  Adding the rmb() prevents the compiler
+	 * and/or CPU from reordering the reads which would potentially
+	 * result in reading stale values.
+	 */
+
+	rmb();
+
+	*type = type_color & CQ_DESC_TYPE_MASK;
+	*q_number = le16_to_cpu(desc->q_number) & CQ_DESC_Q_NUM_MASK;
+	*completed_index = le16_to_cpu(desc->completed_index) &
+		CQ_DESC_COMP_NDX_MASK;
+}
+
+#endif /* _CQ_DESC_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/cq_enet_desc.h linux-2.6.26.3-enic/drivers/net/enic/cq_enet_desc.h
--- linux-2.6.26.3/drivers/net/enic/cq_enet_desc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/cq_enet_desc.h	2008-09-08 15:16:22.000000000 -0700
@@ -0,0 +1,169 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _CQ_ENET_DESC_H_
+#define _CQ_ENET_DESC_H_
+
+#include "cq_desc.h"
+
+/* Ethernet completion queue descriptor: 16B */
+struct cq_enet_wq_desc {
+	__le16 completed_index;
+	__le16 q_number;
+	u8 reserved[11];
+	u8 type_color;
+};
+
+static inline void cq_enet_wq_desc_dec(struct cq_enet_wq_desc *desc,
+	u8 *type, u8 *color, u16 *q_number, u16 *completed_index)
+{
+	cq_desc_dec((struct cq_desc *)desc, type,
+		color, q_number, completed_index);
+}
+
+/* Completion queue descriptor: Ethernet receive queue, 16B */
+struct cq_enet_rq_desc {
+	__le16 completed_index_flags;
+	__le16 q_number_rss_type_flags;
+	__le32 rss_hash;
+	__le16 bytes_written_flags;
+	__le16 vlan;
+	__le16 checksum_fcoe;
+	u8 flags;
+	u8 type_color;
+};
+
+#define CQ_ENET_RQ_DESC_FLAGS_INGRESS_PORT          (0x1 << 12)
+#define CQ_ENET_RQ_DESC_FLAGS_FCOE                  (0x1 << 13)
+#define CQ_ENET_RQ_DESC_FLAGS_EOP                   (0x1 << 14)
+#define CQ_ENET_RQ_DESC_FLAGS_SOP                   (0x1 << 15)
+
+#define CQ_ENET_RQ_DESC_RSS_TYPE_BITS               4
+#define CQ_ENET_RQ_DESC_RSS_TYPE_MASK \
+	((1 << CQ_ENET_RQ_DESC_RSS_TYPE_BITS) - 1)
+#define CQ_ENET_RQ_DESC_RSS_TYPE_NONE               0
+#define CQ_ENET_RQ_DESC_RSS_TYPE_IPv4               1
+#define CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv4           2
+#define CQ_ENET_RQ_DESC_RSS_TYPE_IPv6               3
+#define CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6           4
+#define CQ_ENET_RQ_DESC_RSS_TYPE_IPv6_EX            5
+#define CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6_EX        6
+
+#define CQ_ENET_RQ_DESC_FLAGS_CSUM_NOT_CALC         (0x1 << 14)
+
+#define CQ_ENET_RQ_DESC_BYTES_WRITTEN_BITS          14
+#define CQ_ENET_RQ_DESC_BYTES_WRITTEN_MASK \
+	((1 << CQ_ENET_RQ_DESC_BYTES_WRITTEN_BITS) - 1)
+#define CQ_ENET_RQ_DESC_FLAGS_TRUNCATED             (0x1 << 14)
+#define CQ_ENET_RQ_DESC_FLAGS_VLAN_STRIPPED         (0x1 << 15)
+
+#define CQ_ENET_RQ_DESC_FCOE_SOF_BITS               4
+#define CQ_ENET_RQ_DESC_FCOE_SOF_MASK \
+	((1 << CQ_ENET_RQ_DESC_FCOE_SOF_BITS) - 1)
+#define CQ_ENET_RQ_DESC_FCOE_EOF_BITS               8
+#define CQ_ENET_RQ_DESC_FCOE_EOF_MASK \
+	((1 << CQ_ENET_RQ_DESC_FCOE_EOF_BITS) - 1)
+#define CQ_ENET_RQ_DESC_FCOE_EOF_SHIFT              8
+
+#define CQ_ENET_RQ_DESC_FLAGS_TCP_UDP_CSUM_OK       (0x1 << 0)
+#define CQ_ENET_RQ_DESC_FCOE_FC_CRC_OK              (0x1 << 0)
+#define CQ_ENET_RQ_DESC_FLAGS_UDP                   (0x1 << 1)
+#define CQ_ENET_RQ_DESC_FCOE_ENC_ERROR              (0x1 << 1)
+#define CQ_ENET_RQ_DESC_FLAGS_TCP                   (0x1 << 2)
+#define CQ_ENET_RQ_DESC_FLAGS_IPV4_CSUM_OK          (0x1 << 3)
+#define CQ_ENET_RQ_DESC_FLAGS_IPV6                  (0x1 << 4)
+#define CQ_ENET_RQ_DESC_FLAGS_IPV4                  (0x1 << 5)
+#define CQ_ENET_RQ_DESC_FLAGS_IPV4_FRAGMENT         (0x1 << 6)
+#define CQ_ENET_RQ_DESC_FLAGS_FCS_OK                (0x1 << 7)
+
+static inline void cq_enet_rq_desc_dec(struct cq_enet_rq_desc *desc,
+	u8 *type, u8 *color, u16 *q_number, u16 *completed_index,
+	u8 *ingress_port, u8 *fcoe, u8 *eop, u8 *sop, u8 *rss_type,
+	u8 *csum_not_calc, u32 *rss_hash, u16 *bytes_written, u8 *packet_error,
+	u8 *vlan_stripped, u16 *vlan, u16 *checksum, u8 *fcoe_sof,
+	u8 *fcoe_fc_crc_ok, u8 *fcoe_enc_error, u8 *fcoe_eof,
+	u8 *tcp_udp_csum_ok, u8 *udp, u8 *tcp, u8 *ipv4_csum_ok,
+	u8 *ipv6, u8 *ipv4, u8 *ipv4_fragment, u8 *fcs_ok)
+{
+	u16 completed_index_flags = le16_to_cpu(desc->completed_index_flags);
+	u16 q_number_rss_type_flags =
+		le16_to_cpu(desc->q_number_rss_type_flags);
+	u16 bytes_written_flags = le16_to_cpu(desc->bytes_written_flags);
+
+	cq_desc_dec((struct cq_desc *)desc, type,
+		color, q_number, completed_index);
+
+	*ingress_port = (completed_index_flags &
+		CQ_ENET_RQ_DESC_FLAGS_INGRESS_PORT) ? 1 : 0;
+	*fcoe = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_FCOE) ?
+		1 : 0;
+	*eop = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_EOP) ?
+		1 : 0;
+	*sop = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_SOP) ?
+		1 : 0;
+
+	*rss_type = (u8)((q_number_rss_type_flags >> CQ_DESC_Q_NUM_BITS) &
+		CQ_ENET_RQ_DESC_RSS_TYPE_MASK);
+	*csum_not_calc = (q_number_rss_type_flags &
+		CQ_ENET_RQ_DESC_FLAGS_CSUM_NOT_CALC) ? 1 : 0;
+
+	*rss_hash = le32_to_cpu(desc->rss_hash);
+
+	*bytes_written = bytes_written_flags &
+		CQ_ENET_RQ_DESC_BYTES_WRITTEN_MASK;
+	*packet_error = (bytes_written_flags &
+		CQ_ENET_RQ_DESC_FLAGS_TRUNCATED) ? 1 : 0;
+	*vlan_stripped = (bytes_written_flags &
+		CQ_ENET_RQ_DESC_FLAGS_VLAN_STRIPPED) ? 1 : 0;
+
+	*vlan = le16_to_cpu(desc->vlan);
+
+	if (*fcoe) {
+		*fcoe_sof = (u8)(le16_to_cpu(desc->checksum_fcoe) &
+			CQ_ENET_RQ_DESC_FCOE_SOF_MASK);
+		*fcoe_fc_crc_ok = (desc->flags &
+			CQ_ENET_RQ_DESC_FCOE_FC_CRC_OK) ? 1 : 0;
+		*fcoe_enc_error = (desc->flags &
+			CQ_ENET_RQ_DESC_FCOE_ENC_ERROR) ? 1 : 0;
+		*fcoe_eof = (u8)((desc->checksum_fcoe >>
+			CQ_ENET_RQ_DESC_FCOE_EOF_SHIFT) &
+			CQ_ENET_RQ_DESC_FCOE_EOF_MASK);
+		*checksum = 0;
+	} else {
+		*fcoe_sof = 0;
+		*fcoe_fc_crc_ok = 0;
+		*fcoe_enc_error = 0;
+		*fcoe_eof = 0;
+		*checksum = le16_to_cpu(desc->checksum_fcoe);
+	}
+
+	*tcp_udp_csum_ok =
+		(desc->flags & CQ_ENET_RQ_DESC_FLAGS_TCP_UDP_CSUM_OK) ? 1 : 0;
+	*udp = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_UDP) ? 1 : 0;
+	*tcp = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_TCP) ? 1 : 0;
+	*ipv4_csum_ok =
+		(desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV4_CSUM_OK) ? 1 : 0;
+	*ipv6 = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV6) ? 1 : 0;
+	*ipv4 = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV4) ? 1 : 0;
+	*ipv4_fragment =
+		(desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV4_FRAGMENT) ? 1 : 0;
+	*fcs_ok = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_FCS_OK) ? 1 : 0;
+}
+
+#endif /* _CQ_ENET_DESC_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/rq_enet_desc.h linux-2.6.26.3-enic/drivers/net/enic/rq_enet_desc.h
--- linux-2.6.26.3/drivers/net/enic/rq_enet_desc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/rq_enet_desc.h	2008-09-08 15:16:24.000000000 -0700
@@ -0,0 +1,60 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _RQ_ENET_DESC_H_
+#define _RQ_ENET_DESC_H_
+
+/* Ethernet receive queue descriptor: 16B */
+struct rq_enet_desc {
+	__le64 address;
+	__le16 length_type;
+	u8 reserved[6];
+};
+
+enum rq_enet_type_types {
+	RQ_ENET_TYPE_ONLY_SOP = 0,
+	RQ_ENET_TYPE_NOT_SOP = 1,
+	RQ_ENET_TYPE_RESV2 = 2,
+	RQ_ENET_TYPE_RESV3 = 3,
+};
+
+#define RQ_ENET_ADDR_BITS		64
+#define RQ_ENET_LEN_BITS		14
+#define RQ_ENET_LEN_MASK		((1 << RQ_ENET_LEN_BITS) - 1)
+#define RQ_ENET_TYPE_BITS		2
+#define RQ_ENET_TYPE_MASK		((1 << RQ_ENET_TYPE_BITS) - 1)
+
+static inline void rq_enet_desc_enc(struct rq_enet_desc *desc,
+	u64 address, u8 type, u16 length)
+{
+	desc->address = cpu_to_le64(address);
+	desc->length_type = cpu_to_le16((length & RQ_ENET_LEN_MASK) |
+		((type & RQ_ENET_TYPE_MASK) << RQ_ENET_LEN_BITS));
+}
+
+static inline void rq_enet_desc_dec(struct rq_enet_desc *desc,
+	u64 *address, u8 *type, u16 *length)
+{
+	*address = le64_to_cpu(desc->address);
+	*length = le16_to_cpu(desc->length_type) & RQ_ENET_LEN_MASK;
+	*type = (u8)((le16_to_cpu(desc->length_type) >> RQ_ENET_LEN_BITS) &
+		RQ_ENET_TYPE_MASK);
+}
+
+#endif /* _RQ_ENET_DESC_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_cq.c linux-2.6.26.3-enic/drivers/net/enic/vnic_cq.c
--- linux-2.6.26.3/drivers/net/enic/vnic_cq.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_cq.c	2008-09-08 15:16:24.000000000 -0700
@@ -0,0 +1,89 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+
+#include "vnic_dev.h"
+#include "vnic_cq.h"
+
+void vnic_cq_free(struct vnic_cq *cq)
+{
+	vnic_dev_free_desc_ring(cq->vdev, &cq->ring);
+
+	cq->ctrl = NULL;
+}
+
+int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
+	unsigned int desc_count, unsigned int desc_size)
+{
+	int err;
+
+	cq->index = index;
+	cq->vdev = vdev;
+
+	cq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_CQ, index);
+	if (!cq->ctrl) {
+		printk(KERN_ERR "Failed to hook CQ[%d] resource\n", index);
+		return -EINVAL;
+	}
+
+	err = vnic_dev_alloc_desc_ring(vdev, &cq->ring, desc_count, desc_size);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
+	unsigned int color_enable, unsigned int cq_head, unsigned int cq_tail,
+	unsigned int cq_tail_color, unsigned int interrupt_enable,
+	unsigned int cq_entry_enable, unsigned int cq_message_enable,
+	unsigned int interrupt_offset, u64 cq_message_addr)
+{
+	u64 paddr;
+
+	paddr = (u64)cq->ring.base_addr | VNIC_PADDR_TARGET;
+	writeq(paddr, &cq->ctrl->ring_base);
+	iowrite32(cq->ring.desc_count, &cq->ctrl->ring_size);
+	iowrite32(flow_control_enable, &cq->ctrl->flow_control_enable);
+	iowrite32(color_enable, &cq->ctrl->color_enable);
+	iowrite32(cq_head, &cq->ctrl->cq_head);
+	iowrite32(cq_tail, &cq->ctrl->cq_tail);
+	iowrite32(cq_tail_color, &cq->ctrl->cq_tail_color);
+	iowrite32(interrupt_enable, &cq->ctrl->interrupt_enable);
+	iowrite32(cq_entry_enable, &cq->ctrl->cq_entry_enable);
+	iowrite32(cq_message_enable, &cq->ctrl->cq_message_enable);
+	iowrite32(interrupt_offset, &cq->ctrl->interrupt_offset);
+	writeq(cq_message_addr, &cq->ctrl->cq_message_addr);
+}
+
+void vnic_cq_clean(struct vnic_cq *cq)
+{
+	cq->to_clean = 0;
+	cq->last_color = 0;
+
+	iowrite32(0, &cq->ctrl->cq_head);
+	iowrite32(0, &cq->ctrl->cq_tail);
+	iowrite32(1, &cq->ctrl->cq_tail_color);
+
+	vnic_dev_clear_desc_ring(&cq->ring);
+}
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_cq.h linux-2.6.26.3-enic/drivers/net/enic/vnic_cq.h
--- linux-2.6.26.3/drivers/net/enic/vnic_cq.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_cq.h	2008-09-08 15:16:25.000000000 -0700
@@ -0,0 +1,113 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_CQ_H_
+#define _VNIC_CQ_H_
+
+#include "cq_desc.h"
+#include "vnic_dev.h"
+
+/* Completion queue control */
+struct vnic_cq_ctrl {
+	u64 ring_base;			/* 0x00 */
+	u32 ring_size;			/* 0x08 */
+	u32 pad0;
+	u32 flow_control_enable;	/* 0x10 */
+	u32 pad1;
+	u32 color_enable;		/* 0x18 */
+	u32 pad2;
+	u32 cq_head;			/* 0x20 */
+	u32 pad3;
+	u32 cq_tail;			/* 0x28 */
+	u32 pad4;
+	u32 cq_tail_color;		/* 0x30 */
+	u32 pad5;
+	u32 interrupt_enable;		/* 0x38 */
+	u32 pad6;
+	u32 cq_entry_enable;		/* 0x40 */
+	u32 pad7;
+	u32 cq_message_enable;		/* 0x48 */
+	u32 pad8;
+	u32 interrupt_offset;		/* 0x50 */
+	u32 pad9;
+	u64 cq_message_addr;		/* 0x58 */
+	u32 pad10;
+};
+
+struct vnic_cq {
+	unsigned int index;
+	struct vnic_dev *vdev;
+	struct vnic_cq_ctrl __iomem *ctrl;              /* memory-mapped */
+	struct vnic_dev_ring ring;
+	unsigned int to_clean;
+	unsigned int last_color;
+};
+
+static inline unsigned int vnic_cq_service(struct vnic_cq *cq,
+	unsigned int work_to_do,
+	int (*q_service)(struct vnic_dev *vdev, struct cq_desc *cq_desc,
+	u8 type, u16 q_number, u16 completed_index, void *opaque),
+	void *opaque)
+{
+	struct cq_desc *cq_desc;
+	unsigned int work_done = 0;
+	u16 q_number, completed_index;
+	u8 type, color;
+
+	cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
+		cq->ring.desc_size * cq->to_clean);
+	cq_desc_dec(cq_desc, &type, &color,
+		&q_number, &completed_index);
+
+	while (color != cq->last_color) {
+
+		if ((*q_service)(cq->vdev, cq_desc, type,
+			q_number, completed_index, opaque))
+			break;
+
+		cq->to_clean++;
+		if (cq->to_clean == cq->ring.desc_count) {
+			cq->to_clean = 0;
+			cq->last_color = cq->last_color ? 0 : 1;
+		}
+
+		cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
+			cq->ring.desc_size * cq->to_clean);
+		cq_desc_dec(cq_desc, &type, &color,
+			&q_number, &completed_index);
+
+		work_done++;
+		if (work_done >= work_to_do)
+			break;
+	}
+
+	return work_done;
+}
+
+void vnic_cq_free(struct vnic_cq *cq);
+int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
+	unsigned int desc_count, unsigned int desc_size);
+void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
+	unsigned int color_enable, unsigned int cq_head, unsigned int cq_tail,
+	unsigned int cq_tail_color, unsigned int interrupt_enable,
+	unsigned int cq_entry_enable, unsigned int message_enable,
+	unsigned int interrupt_offset, u64 message_addr);
+void vnic_cq_clean(struct vnic_cq *cq);
+
+#endif /* _VNIC_CQ_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_dev.c linux-2.6.26.3-enic/drivers/net/enic/vnic_dev.c
--- linux-2.6.26.3/drivers/net/enic/vnic_dev.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_dev.c	2008-09-08 15:16:25.000000000 -0700
@@ -0,0 +1,674 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/if_ether.h>
+
+#include "vnic_resource.h"
+#include "vnic_devcmd.h"
+#include "vnic_dev.h"
+#include "vnic_stats.h"
+
+struct vnic_res {
+	void __iomem *vaddr;
+	unsigned int count;
+};
+
+struct vnic_dev {
+	void *priv;
+	struct pci_dev *pdev;
+	struct vnic_res res[RES_TYPE_MAX];
+	enum vnic_dev_intr_mode intr_mode;
+	struct vnic_devcmd __iomem *devcmd;
+	struct vnic_devcmd_notify *notify;
+	struct vnic_devcmd_notify notify_copy;
+	dma_addr_t notify_pa;
+	u32 *linkstatus;
+	dma_addr_t linkstatus_pa;
+	struct vnic_stats *stats;
+	dma_addr_t stats_pa;
+	struct vnic_devcmd_fw_info *fw_info;
+	dma_addr_t fw_info_pa;
+};
+
+#define VNIC_MAX_RES_HDR_SIZE \
+	(sizeof(struct vnic_resource_header) + \
+	sizeof(struct vnic_resource) * RES_TYPE_MAX)
+#define VNIC_RES_STRIDE	128
+
+void *vnic_dev_priv(struct vnic_dev *vdev)
+{
+	return vdev->priv;
+}
+
+static int vnic_dev_discover_res(struct vnic_dev *vdev,
+	struct vnic_dev_bar *bar)
+{
+	struct vnic_resource_header __iomem *rh;
+	struct vnic_resource __iomem *r;
+	u8 type;
+
+	if (bar->len < VNIC_MAX_RES_HDR_SIZE) {
+		printk(KERN_ERR "vNIC BAR0 res hdr length error\n");
+		return -EINVAL;
+	}
+
+	rh = bar->vaddr;
+	if (!rh) {
+		printk(KERN_ERR "vNIC BAR0 res hdr not mem-mapped\n");
+		return -EINVAL;
+	}
+
+	if (ioread32(&rh->magic) != VNIC_RES_MAGIC ||
+	    ioread32(&rh->version) != VNIC_RES_VERSION) {
+		printk(KERN_ERR "vNIC BAR0 res magic/version error "
+			"exp (%lx/%lx) curr (%x/%x)\n",
+			VNIC_RES_MAGIC, VNIC_RES_VERSION,
+			ioread32(&rh->magic), ioread32(&rh->version));
+		return -EINVAL;
+	}
+
+	r = (struct vnic_resource __iomem *)(rh + 1);
+
+	while ((type = ioread8(&r->type)) != RES_TYPE_EOL) {
+
+		u8 bar_num = ioread8(&r->bar);
+		u32 bar_offset = ioread32(&r->bar_offset);
+		u32 count = ioread32(&r->count);
+		u32 len;
+
+		r++;
+
+		if (bar_num != 0)  /* only mapping in BAR0 resources */
+			continue;
+
+		switch (type) {
+		case RES_TYPE_WQ:
+		case RES_TYPE_RQ:
+		case RES_TYPE_CQ:
+		case RES_TYPE_INTR_CTRL:
+			/* each count is stride bytes long */
+			len = count * VNIC_RES_STRIDE;
+			if (len + bar_offset > bar->len) {
+				printk(KERN_ERR "vNIC BAR0 resource %d "
+					"out-of-bounds, offset 0x%x + "
+					"size 0x%x > bar len 0x%lx\n",
+					type, bar_offset,
+					len,
+					bar->len);
+				return -EINVAL;
+			}
+			break;
+		case RES_TYPE_INTR_PBA_LEGACY:
+		case RES_TYPE_DEVCMD:
+			len = count;
+			break;
+		default:
+			continue;
+		}
+
+		vdev->res[type].count = count;
+		vdev->res[type].vaddr = (char __iomem *)bar->vaddr + bar_offset;
+	}
+
+	return 0;
+}
+
+unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
+	enum vnic_res_type type)
+{
+	return vdev->res[type].count;
+}
+
+void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
+	unsigned int index)
+{
+	if (!vdev->res[type].vaddr)
+		return NULL;
+
+	switch (type) {
+	case RES_TYPE_WQ:
+	case RES_TYPE_RQ:
+	case RES_TYPE_CQ:
+	case RES_TYPE_INTR_CTRL:
+		return (char __iomem *)vdev->res[type].vaddr +
+			index * VNIC_RES_STRIDE;
+	default:
+		return (char __iomem *)vdev->res[type].vaddr;
+	}
+}
+
+unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
+	unsigned int desc_count, unsigned int desc_size)
+{
+	/* The base address of the desc rings must be 512 byte aligned.
+	 * Descriptor count is aligned to groups of 32 descriptors.  A
+	 * count of 0 means the maximum 4096 descriptors.  Descriptor
+	 * size is aligned to 16 bytes.
+	 */
+
+	unsigned int count_align = 32;
+	unsigned int desc_align = 16;
+
+	ring->base_align = 512;
+
+	if (desc_count == 0)
+		desc_count = 4096;
+
+	ring->desc_count = ALIGN(desc_count, count_align);
+
+	ring->desc_size = ALIGN(desc_size, desc_align);
+
+	ring->size = ring->desc_count * ring->desc_size;
+	ring->size_unaligned = ring->size + ring->base_align;
+
+	return ring->size_unaligned;
+}
+
+void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring)
+{
+	memset(ring->descs, 0, ring->size);
+}
+
+int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
+	unsigned int desc_count, unsigned int desc_size)
+{
+	vnic_dev_desc_ring_size(ring, desc_count, desc_size);
+
+	ring->descs_unaligned = pci_alloc_consistent(vdev->pdev,
+		ring->size_unaligned,
+		&ring->base_addr_unaligned);
+
+	if (!ring->descs_unaligned) {
+		printk(KERN_ERR
+		  "Failed to allocate ring (size=%d), aborting\n",
+			(int)ring->size);
+		return -ENOMEM;
+	}
+
+	ring->base_addr = ALIGN(ring->base_addr_unaligned,
+		ring->base_align);
+	ring->descs = (u8 *)ring->descs_unaligned +
+		(ring->base_addr - ring->base_addr_unaligned);
+
+	vnic_dev_clear_desc_ring(ring);
+
+	ring->desc_avail = ring->desc_count - 1;
+
+	return 0;
+}
+
+void vnic_dev_free_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring)
+{
+	if (ring->descs) {
+		pci_free_consistent(vdev->pdev,
+			ring->size_unaligned,
+			ring->descs_unaligned,
+			ring->base_addr_unaligned);
+		ring->descs = NULL;
+	}
+}
+
+int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+	u64 *a0, u64 *a1, int wait)
+{
+	struct vnic_devcmd __iomem *devcmd = vdev->devcmd;
+	int delay;
+	u32 status;
+	int dev_cmd_err[] = {
+		/* convert from fw's version of error.h to host's version */
+		0,	/* ERR_SUCCESS */
+		EINVAL,	/* ERR_EINVAL */
+		EFAULT,	/* ERR_EFAULT */
+		EPERM,	/* ERR_EPERM */
+		EBUSY,  /* ERR_EBUSY */
+	};
+	int err;
+
+	status = ioread32(&devcmd->status);
+	if (status & STAT_BUSY) {
+		printk(KERN_ERR "Busy devcmd %d\n", _CMD_N(cmd));
+		return -EBUSY;
+	}
+
+	if (_CMD_DIR(cmd) & _CMD_DIR_WRITE) {
+		writeq(*a0, &devcmd->args[0]);
+		writeq(*a1, &devcmd->args[1]);
+		wmb();
+	}
+
+	iowrite32(cmd, &devcmd->cmd);
+
+	if ((_CMD_FLAGS(cmd) & _CMD_FLAGS_NOWAIT))
+			return 0;
+
+	for (delay = 0; delay < wait; delay++) {
+
+		udelay(100);
+
+		status = ioread32(&devcmd->status);
+		if (!(status & STAT_BUSY)) {
+
+			if (status & STAT_ERROR) {
+				err = dev_cmd_err[(int)readq(&devcmd->args[0])];
+				printk(KERN_ERR "Error %d devcmd %d\n",
+					err, _CMD_N(cmd));
+				return -err;
+			}
+
+			if (_CMD_DIR(cmd) & _CMD_DIR_READ) {
+				rmb();
+				*a0 = readq(&devcmd->args[0]);
+				*a1 = readq(&devcmd->args[1]);
+			}
+
+			return 0;
+		}
+	}
+
+	printk(KERN_ERR "Timedout devcmd %d\n", _CMD_N(cmd));
+	return -ETIMEDOUT;
+}
+
+int vnic_dev_fw_info(struct vnic_dev *vdev,
+	struct vnic_devcmd_fw_info **fw_info)
+{
+	u64 a0, a1 = 0;
+	int wait = 1000;
+	int err = 0;
+
+	if (!vdev->fw_info) {
+		vdev->fw_info = pci_alloc_consistent(vdev->pdev,
+			sizeof(struct vnic_devcmd_fw_info),
+			&vdev->fw_info_pa);
+		if (!vdev->fw_info)
+			return -ENOMEM;
+
+		a0 = vdev->fw_info_pa;
+
+		/* only get fw_info once and cache it */
+		err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO, &a0, &a1, wait);
+	}
+
+	*fw_info = vdev->fw_info;
+
+	return err;
+}
+
+int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
+	void *value)
+{
+	u64 a0, a1;
+	int wait = 1000;
+	int err;
+
+	a0 = offset;
+	a1 = size;
+
+	err = vnic_dev_cmd(vdev, CMD_DEV_SPEC, &a0, &a1, wait);
+
+	switch (size) {
+	case 1: *(u8 *)value = (u8)a0; break;
+	case 2: *(u16 *)value = (u16)a0; break;
+	case 4: *(u32 *)value = (u32)a0; break;
+	case 8: *(u64 *)value = a0; break;
+	default: BUG(); break;
+	}
+
+	return err;
+}
+
+int vnic_dev_stats_clear(struct vnic_dev *vdev)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_STATS_CLEAR, &a0, &a1, wait);
+}
+
+int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats)
+{
+	u64 a0, a1;
+	int wait = 1000;
+
+	if (!vdev->stats) {
+		vdev->stats = pci_alloc_consistent(vdev->pdev,
+			sizeof(struct vnic_stats), &vdev->stats_pa);
+		if (!vdev->stats)
+			return -ENOMEM;
+	}
+
+	*stats = vdev->stats;
+	a0 = vdev->stats_pa;
+	a1 = sizeof(struct vnic_stats);
+
+	return vnic_dev_cmd(vdev, CMD_STATS_DUMP, &a0, &a1, wait);
+}
+
+int vnic_dev_close(struct vnic_dev *vdev)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_CLOSE, &a0, &a1, wait);
+}
+
+int vnic_dev_enable(struct vnic_dev *vdev)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
+}
+
+int vnic_dev_disable(struct vnic_dev *vdev)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_DISABLE, &a0, &a1, wait);
+}
+
+int vnic_dev_open(struct vnic_dev *vdev, int arg)
+{
+	u64 a0 = (u32)arg, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_OPEN, &a0, &a1, wait);
+}
+
+int vnic_dev_open_done(struct vnic_dev *vdev, int *done)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	*done = 0;
+
+	err = vnic_dev_cmd(vdev, CMD_OPEN_STATUS, &a0, &a1, wait);
+	if (err)
+		return err;
+
+	*done = (a0 == 0);
+
+	return 0;
+}
+
+int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
+{
+	u64 a0 = (u32)arg, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_SOFT_RESET, &a0, &a1, wait);
+}
+
+int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	*done = 0;
+
+	err = vnic_dev_cmd(vdev, CMD_SOFT_RESET_STATUS, &a0, &a1, wait);
+	if (err)
+		return err;
+
+	*done = (a0 == 0);
+
+	return 0;
+}
+
+int vnic_dev_hang_notify(struct vnic_dev *vdev)
+{
+	u64 a0, a1;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_HANG_NOTIFY, &a0, &a1, wait);
+}
+
+int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
+{
+	u64 a0, a1;
+	int wait = 1000;
+	int err, i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		mac_addr[i] = 0;
+
+	err = vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
+	if (err)
+		return err;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		mac_addr[i] = ((u8 *)&a0)[i];
+
+	return 0;
+}
+
+void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
+	int broadcast, int promisc, int allmulti)
+{
+	u64 a0, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	a0 = (directed ? CMD_PFILTER_DIRECTED : 0) |
+	     (multicast ? CMD_PFILTER_MULTICAST : 0) |
+	     (broadcast ? CMD_PFILTER_BROADCAST : 0) |
+	     (promisc ? CMD_PFILTER_PROMISCUOUS : 0) |
+	     (allmulti ? CMD_PFILTER_ALL_MULTICAST : 0);
+
+	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER, &a0, &a1, wait);
+	if (err)
+		printk(KERN_ERR "Can't set packet filter\n");
+}
+
+void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int err;
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		((u8 *)&a0)[i] = addr[i];
+
+	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
+	if (err)
+		printk(KERN_ERR
+			"Can't add addr [%02x:%02x:%02x:%02x:%02x:%02x], %d\n",
+			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5],
+			err);
+}
+
+void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
+{
+	u64 a0 = 0, a1 = 0;
+	int wait = 1000;
+	int err;
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		((u8 *)&a0)[i] = addr[i];
+
+	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
+	if (err)
+		printk(KERN_ERR
+			"Can't del addr [%02x:%02x:%02x:%02x:%02x:%02x], %d\n",
+			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5],
+			err);
+}
+
+int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
+{
+	u64 a0, a1;
+	int wait = 1000;
+
+	if (!vdev->notify) {
+		vdev->notify = pci_alloc_consistent(vdev->pdev,
+			sizeof(struct vnic_devcmd_notify),
+			&vdev->notify_pa);
+		if (!vdev->notify)
+			return -ENOMEM;
+	}
+
+	a0 = vdev->notify_pa;
+	a1 = ((u64)intr << 32) & 0x0000ffff00000000ULL;
+	a1 += sizeof(struct vnic_devcmd_notify);
+
+	return vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+}
+
+void vnic_dev_notify_unset(struct vnic_dev *vdev)
+{
+	u64 a0, a1;
+	int wait = 1000;
+
+	a0 = 0;  /* paddr = 0 to unset notify buffer */
+	a1 = 0x0000ffff00000000ULL; /* intr num = -1 to unreg for intr */
+	a1 += sizeof(struct vnic_devcmd_notify);
+
+	vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+}
+
+static int vnic_dev_notify_ready(struct vnic_dev *vdev)
+{
+	u32 *words;
+	unsigned int nwords = sizeof(struct vnic_devcmd_notify) / 4;
+	unsigned int i;
+	u32 csum;
+
+	if (!vdev->notify)
+		return 0;
+
+	do {
+		csum = 0;
+		memcpy(&vdev->notify_copy, vdev->notify,
+			sizeof(struct vnic_devcmd_notify));
+		words = (u32 *)&vdev->notify_copy;
+		for (i = 1; i < nwords; i++)
+			csum += words[i];
+	} while (csum != words[0]);
+
+	return 1;
+}
+
+int vnic_dev_init(struct vnic_dev *vdev, int arg)
+{
+	u64 a0 = (u32)arg, a1 = 0;
+	int wait = 1000;
+	return vnic_dev_cmd(vdev, CMD_INIT, &a0, &a1, wait);
+}
+
+int vnic_dev_link_status(struct vnic_dev *vdev)
+{
+	if (vdev->linkstatus)
+		return *vdev->linkstatus;
+
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.link_state;
+}
+
+u32 vnic_dev_port_speed(struct vnic_dev *vdev)
+{
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.port_speed;
+}
+
+u32 vnic_dev_msg_lvl(struct vnic_dev *vdev)
+{
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.msglvl;
+}
+
+u32 vnic_dev_mtu(struct vnic_dev *vdev)
+{
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.mtu;
+}
+
+void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
+	enum vnic_dev_intr_mode intr_mode)
+{
+	vdev->intr_mode = intr_mode;
+}
+
+enum vnic_dev_intr_mode vnic_dev_get_intr_mode(
+	struct vnic_dev *vdev)
+{
+	return vdev->intr_mode;
+}
+
+void vnic_dev_unregister(struct vnic_dev *vdev)
+{
+	if (vdev) {
+		if (vdev->notify)
+			pci_free_consistent(vdev->pdev,
+				sizeof(struct vnic_devcmd_notify),
+				vdev->notify,
+				vdev->notify_pa);
+		if (vdev->linkstatus)
+			pci_free_consistent(vdev->pdev,
+				sizeof(u32),
+				vdev->linkstatus,
+				vdev->linkstatus_pa);
+		if (vdev->stats)
+			pci_free_consistent(vdev->pdev,
+				sizeof(struct vnic_dev),
+				vdev->stats, vdev->stats_pa);
+		if (vdev->fw_info)
+			pci_free_consistent(vdev->pdev,
+				sizeof(struct vnic_devcmd_fw_info),
+				vdev->fw_info, vdev->fw_info_pa);
+		kfree(vdev);
+	}
+}
+
+struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
+	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar)
+{
+	if (!vdev) {
+		vdev = kzalloc(sizeof(struct vnic_dev), GFP_ATOMIC);
+		if (!vdev)
+			return NULL;
+	}
+
+	vdev->priv = priv;
+	vdev->pdev = pdev;
+
+	if (vnic_dev_discover_res(vdev, bar))
+		goto err_out;
+
+	vdev->devcmd = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD, 0);
+	if (!vdev->devcmd)
+		goto err_out;
+
+	return vdev;
+
+err_out:
+	vnic_dev_unregister(vdev);
+	return NULL;
+}
+
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_devcmd.h linux-2.6.26.3-enic/drivers/net/enic/vnic_devcmd.h
--- linux-2.6.26.3/drivers/net/enic/vnic_devcmd.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_devcmd.h	2008-09-08 15:16:25.000000000 -0700
@@ -0,0 +1,282 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_DEVCMD_H_
+#define _VNIC_DEVCMD_H_
+
+#define _CMD_NBITS      14
+#define _CMD_VTYPEBITS	10
+#define _CMD_FLAGSBITS  6
+#define _CMD_DIRBITS	2
+
+#define _CMD_NMASK      ((1 << _CMD_NBITS)-1)
+#define _CMD_VTYPEMASK  ((1 << _CMD_VTYPEBITS)-1)
+#define _CMD_FLAGSMASK  ((1 << _CMD_FLAGSBITS)-1)
+#define _CMD_DIRMASK    ((1 << _CMD_DIRBITS)-1)
+
+#define _CMD_NSHIFT     0
+#define _CMD_VTYPESHIFT (_CMD_NSHIFT+_CMD_NBITS)
+#define _CMD_FLAGSSHIFT (_CMD_VTYPESHIFT+_CMD_VTYPEBITS)
+#define _CMD_DIRSHIFT   (_CMD_FLAGSSHIFT+_CMD_FLAGSBITS)
+
+/*
+ * Direction bits (from host perspective).
+ */
+#define _CMD_DIR_NONE   0U
+#define _CMD_DIR_WRITE  1U
+#define _CMD_DIR_READ   2U
+#define _CMD_DIR_RW     (_CMD_DIR_WRITE | _CMD_DIR_READ)
+
+/*
+ * Flag bits.
+ */
+#define _CMD_FLAGS_NONE 0U
+#define _CMD_FLAGS_NOWAIT 1U
+
+/*
+ * vNIC type bits.
+ */
+#define _CMD_VTYPE_NONE  0U
+#define _CMD_VTYPE_ENET  1U
+#define _CMD_VTYPE_FC    2U
+#define _CMD_VTYPE_SCSI  4U
+#define _CMD_VTYPE_ALL   (_CMD_VTYPE_ENET | _CMD_VTYPE_FC | _CMD_VTYPE_SCSI)
+
+/*
+ * Used to create cmds..
+*/
+#define _CMDCF(dir, flags, vtype, nr)  \
+	(((dir)   << _CMD_DIRSHIFT) | \
+	((flags) << _CMD_FLAGSSHIFT) | \
+	((vtype) << _CMD_VTYPESHIFT) | \
+	((nr)    << _CMD_NSHIFT))
+#define _CMDC(dir, vtype, nr)    _CMDCF(dir, 0, vtype, nr)
+#define _CMDCNW(dir, vtype, nr)  _CMDCF(dir, _CMD_FLAGS_NOWAIT, vtype, nr)
+
+/*
+ * Used to decode cmds..
+*/
+#define _CMD_DIR(cmd)            (((cmd) >> _CMD_DIRSHIFT) & _CMD_DIRMASK)
+#define _CMD_FLAGS(cmd)          (((cmd) >> _CMD_FLAGSSHIFT) & _CMD_FLAGSMASK)
+#define _CMD_VTYPE(cmd)          (((cmd) >> _CMD_VTYPESHIFT) & _CMD_VTYPEMASK)
+#define _CMD_N(cmd)              (((cmd) >> _CMD_NSHIFT) & _CMD_NMASK)
+
+enum vnic_devcmd_cmd {
+	CMD_NONE                = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_NONE, 0),
+
+	/* mcpu fw info in mem: (u64)a0=paddr to struct vnic_devcmd_fw_info */
+	CMD_MCPU_FW_INFO        = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 1),
+
+	/* dev-specific block member:
+	 *    in: (u16)a0=offset,(u8)a1=size
+	 *    out: a0=value */
+	CMD_DEV_SPEC            = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 2),
+
+	/* stats clear */
+	CMD_STATS_CLEAR         = _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 3),
+
+	/* stats dump in mem: (u64)a0=paddr to stats area,
+	 *                    (u16)a1=sizeof stats area */
+	CMD_STATS_DUMP          = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 4),
+
+	/* set Rx packet filter: (u32)a0=filters (see CMD_PFILTER_*) */
+	CMD_PACKET_FILTER	= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 7),
+
+	/* hang detection notification */
+	CMD_HANG_NOTIFY         = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 8),
+
+	/* MAC address in (u48)a0 */
+	CMD_MAC_ADDR            = _CMDC(_CMD_DIR_READ,
+					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 9),
+
+	/* disable/enable promisc mode: (u8)a0=0/1 */
+/***** XXX DEPRECATED *****/
+	CMD_PROMISC_MODE        = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 10),
+
+	/* disable/enable all-multi mode: (u8)a0=0/1 */
+/***** XXX DEPRECATED *****/
+	CMD_ALLMULTI_MODE       = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 11),
+
+	/* add addr from (u48)a0 */
+	CMD_ADDR_ADD            = _CMDCNW(_CMD_DIR_WRITE,
+					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 12),
+
+	/* del addr from (u48)a0 */
+	CMD_ADDR_DEL            = _CMDCNW(_CMD_DIR_WRITE,
+					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 13),
+
+	/* add VLAN id in (u16)a0 */
+	CMD_VLAN_ADD            = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 14),
+
+	/* del VLAN id in (u16)a0 */
+	CMD_VLAN_DEL            = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 15),
+
+	/* nic_cfg in (u32)a0 */
+	CMD_NIC_CFG             = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 16),
+
+	/* union vnic_rss_key in mem: (u64)a0=paddr, (u16)a1=len */
+	CMD_RSS_KEY             = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 17),
+
+	/* union vnic_rss_cpu in mem: (u64)a0=paddr, (u16)a1=len */
+	CMD_RSS_CPU             = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 18),
+
+	/* initiate softreset */
+	CMD_SOFT_RESET          = _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 19),
+
+	/* softreset status:
+	 *    out: a0=0 reset complete, a0=1 reset in progress */
+	CMD_SOFT_RESET_STATUS   = _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 20),
+
+	/* set struct vnic_devcmd_notify buffer in mem:
+	 * in:
+	 *   (u64)a0=paddr to notify (set paddr=0 to unset)
+	 *   (u32)a1 & 0x00000000ffffffff=sizeof(struct vnic_devcmd_notify)
+	 *   (u16)a1 & 0x0000ffff00000000=intr num (-1 for no intr)
+	 * out:
+	 *   (u32)a1 = effective size
+	 */
+	CMD_NOTIFY              = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 21),
+
+	/* UNDI API: (u64)a0=paddr to s_PXENV_UNDI_ struct,
+	 *           (u8)a1=PXENV_UNDI_xxx */
+	CMD_UNDI                = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 22),
+
+	/* initiate open sequence (u32)a0=flags (see CMD_OPENF_*) */
+	CMD_OPEN		= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 23),
+
+	/* open status:
+	 *    out: a0=0 open complete, a0=1 open in progress */
+	CMD_OPEN_STATUS		= _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 24),
+
+	/* close vnic */
+	CMD_CLOSE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 25),
+
+	/* initialize virtual link: (u32)a0=flags (see CMD_INITF_*) */
+	CMD_INIT		= _CMDCNW(_CMD_DIR_READ, _CMD_VTYPE_ALL, 26),
+
+	/* variant of CMD_INIT, with provisioning info
+	 *     (u64)a0=paddr of vnic_devcmd_provinfo
+	 *     (u32)a1=sizeof provision info */
+	CMD_INIT_PROV_INFO	= _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 27),
+
+	/* enable virtual link */
+	CMD_ENABLE		= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 28),
+
+	/* disable virtual link */
+	CMD_DISABLE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 29),
+
+	/* stats dump all vnics on uplink in mem: (u64)a0=paddr (u32)a1=uif */
+	CMD_STATS_DUMP_ALL	= _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 30),
+
+	/* init status:
+	 *    out: a0=0 init complete, a0=1 init in progress
+	 *         if a0=0, a1=errno */
+	CMD_INIT_STATUS		= _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 31),
+
+	/* INT13 API: (u64)a0=paddr to vnic_int13_params struct
+	 *            (u8)a1=INT13_CMD_xxx */
+	CMD_INT13               = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_FC, 32),
+
+	/* logical uplink enable/disable: (u64)a0: 0/1=disable/enable */
+	CMD_LOGICAL_UPLINK      = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 33),
+
+	/* undo initialize of virtual link */
+	CMD_DEINIT		= _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 34),
+};
+
+/* flags for CMD_OPEN */
+#define CMD_OPENF_OPROM		0x1	/* open coming from option rom */
+
+/* flags for CMD_INIT */
+#define CMD_INITF_DEFAULT_MAC	0x1	/* init with default mac addr */
+
+/* flags for CMD_PACKET_FILTER */
+#define CMD_PFILTER_DIRECTED		0x01
+#define CMD_PFILTER_MULTICAST		0x02
+#define CMD_PFILTER_BROADCAST		0x04
+#define CMD_PFILTER_PROMISCUOUS		0x08
+#define CMD_PFILTER_ALL_MULTICAST	0x10
+
+enum vnic_devcmd_status {
+	STAT_NONE = 0,
+	STAT_BUSY = 1 << 0,	/* cmd in progress */
+	STAT_ERROR = 1 << 1,	/* last cmd caused error (code in a0) */
+};
+
+enum vnic_devcmd_error {
+	ERR_SUCCESS = 0,
+	ERR_EINVAL = 1,
+	ERR_EFAULT = 2,
+	ERR_EPERM = 3,
+	ERR_EBUSY = 4,
+	ERR_ECMDUNKNOWN = 5,
+	ERR_EBADSTATE = 6,
+	ERR_ENOMEM = 7,
+	ERR_ETIMEDOUT = 8,
+	ERR_ELINKDOWN = 9,
+};
+
+struct vnic_devcmd_fw_info {
+	char fw_version[32];
+	char fw_build[32];
+	char hw_version[32];
+	char hw_serial_number[32];
+};
+
+struct vnic_devcmd_notify {
+	u32 csum;		/* checksum over following words */
+
+	u32 link_state;		/* link up == 1 */
+	u32 port_speed;		/* effective port speed (rate limit) */
+	u32 mtu;		/* MTU */
+	u32 msglvl;		/* requested driver msg lvl */
+	u32 uif;		/* uplink interface */
+	u32 status;		/* status bits (see VNIC_STF_*) */
+	u32 error;		/* error code (see ERR_*) for first ERR */
+};
+#define VNIC_STF_FATAL_ERR	0x0001	/* fatal fw error */
+
+struct vnic_devcmd_provinfo {
+	u8 oui[3];
+	u8 type;
+	u8 data[0];
+};
+
+/*
+ * Writing cmd register causes STAT_BUSY to get set in status register.
+ * When cmd completes, STAT_BUSY will be cleared.
+ *
+ * If cmd completed successfully STAT_ERROR will be clear
+ * and args registers contain cmd-specific results.
+ *
+ * If cmd error, STAT_ERROR will be set and args[0] contains error code.
+ *
+ * status register is read-only.  While STAT_BUSY is set,
+ * all other register contents are read-only.
+ */
+
+/* Make sizeof(vnic_devcmd) a power-of-2 for I/O BAR. */
+#define VNIC_DEVCMD_NARGS 15
+struct vnic_devcmd {
+	u32 status;			/* RO */
+	u32 cmd;			/* RW */
+	u64 args[VNIC_DEVCMD_NARGS];	/* RW cmd args (little-endian) */
+};
+
+#endif /* _VNIC_DEVCMD_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_dev.h linux-2.6.26.3-enic/drivers/net/enic/vnic_dev.h
--- linux-2.6.26.3/drivers/net/enic/vnic_dev.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_dev.h	2008-09-08 15:16:26.000000000 -0700
@@ -0,0 +1,106 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_DEV_H_
+#define _VNIC_DEV_H_
+
+#include "vnic_resource.h"
+#include "vnic_devcmd.h"
+
+#ifndef VNIC_PADDR_TARGET
+#define VNIC_PADDR_TARGET	0x0000000000000000ULL
+#endif
+
+enum vnic_dev_intr_mode {
+	VNIC_DEV_INTR_MODE_UNKNOWN,
+	VNIC_DEV_INTR_MODE_INTX,
+	VNIC_DEV_INTR_MODE_MSI,
+	VNIC_DEV_INTR_MODE_MSIX,
+};
+
+struct vnic_dev_bar {
+	void __iomem *vaddr;
+	dma_addr_t bus_addr;
+	unsigned long len;
+};
+
+struct vnic_dev_ring {
+	void *descs;
+	size_t size;
+	dma_addr_t base_addr;
+	size_t base_align;
+	void *descs_unaligned;
+	size_t size_unaligned;
+	dma_addr_t base_addr_unaligned;
+	unsigned int desc_size;
+	unsigned int desc_count;
+	unsigned int desc_avail;
+};
+
+struct vnic_dev;
+struct vnic_stats;
+
+void *vnic_dev_priv(struct vnic_dev *vdev);
+unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
+	enum vnic_res_type type);
+void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
+	unsigned int index);
+unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
+	unsigned int desc_count, unsigned int desc_size);
+void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
+int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
+	unsigned int desc_count, unsigned int desc_size);
+void vnic_dev_free_desc_ring(struct vnic_dev *vdev,
+	struct vnic_dev_ring *ring);
+int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
+	u64 *a0, u64 *a1, int wait);
+int vnic_dev_fw_info(struct vnic_dev *vdev,
+	struct vnic_devcmd_fw_info **fw_info);
+int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
+	void *value);
+int vnic_dev_stats_clear(struct vnic_dev *vdev);
+int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
+int vnic_dev_hang_notify(struct vnic_dev *vdev);
+void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
+	int broadcast, int promisc, int allmulti);
+void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
+void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
+int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
+int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
+void vnic_dev_notify_unset(struct vnic_dev *vdev);
+int vnic_dev_link_status(struct vnic_dev *vdev);
+u32 vnic_dev_port_speed(struct vnic_dev *vdev);
+u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
+u32 vnic_dev_mtu(struct vnic_dev *vdev);
+int vnic_dev_close(struct vnic_dev *vdev);
+int vnic_dev_enable(struct vnic_dev *vdev);
+int vnic_dev_disable(struct vnic_dev *vdev);
+int vnic_dev_open(struct vnic_dev *vdev, int arg);
+int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
+int vnic_dev_init(struct vnic_dev *vdev, int arg);
+int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
+int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
+void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
+	enum vnic_dev_intr_mode intr_mode);
+enum vnic_dev_intr_mode vnic_dev_get_intr_mode(struct vnic_dev *vdev);
+void vnic_dev_unregister(struct vnic_dev *vdev);
+struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
+	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar);
+
+#endif /* _VNIC_DEV_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_enet.h linux-2.6.26.3-enic/drivers/net/enic/vnic_enet.h
--- linux-2.6.26.3/drivers/net/enic/vnic_enet.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_enet.h	2008-09-08 15:16:26.000000000 -0700
@@ -0,0 +1,47 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_ENIC_H_
+#define _VNIC_ENIC_H_
+
+/* Device-specific region: enet configuration */
+struct vnic_enet_config {
+	u32 flags;
+	u32 wq_desc_count;
+	u32 rq_desc_count;
+	u16 mtu;
+	u16 intr_timer;
+	u8 intr_timer_type;
+	u8 intr_mode;
+	char devname[16];
+};
+
+#define VENETF_TSO		0x1	/* TSO enabled */
+#define VENETF_LRO		0x2	/* LRO enabled */
+#define VENETF_RXCSUM		0x4	/* RX csum enabled */
+#define VENETF_TXCSUM		0x8	/* TX csum enabled */
+#define VENETF_RSS		0x10	/* RSS enabled */
+#define VENETF_RSSHASH_IPV4	0x20	/* Hash on IPv4 fields */
+#define VENETF_RSSHASH_TCPIPV4	0x40	/* Hash on TCP + IPv4 fields */
+#define VENETF_RSSHASH_IPV6	0x80	/* Hash on IPv6 fields */
+#define VENETF_RSSHASH_TCPIPV6	0x100	/* Hash on TCP + IPv6 fields */
+#define VENETF_RSSHASH_IPV6_EX	0x200	/* Hash on IPv6 extended fields */
+#define VENETF_RSSHASH_TCPIPV6_EX 0x400	/* Hash on TCP + IPv6 ext. fields */
+
+#endif /* _VNIC_ENIC_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_intr.c linux-2.6.26.3-enic/drivers/net/enic/vnic_intr.c
--- linux-2.6.26.3/drivers/net/enic/vnic_intr.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_intr.c	2008-09-08 15:16:26.000000000 -0700
@@ -0,0 +1,62 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+#include "vnic_dev.h"
+#include "vnic_intr.h"
+
+void vnic_intr_free(struct vnic_intr *intr)
+{
+	intr->ctrl = NULL;
+}
+
+int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
+	unsigned int index)
+{
+	intr->index = index;
+	intr->vdev = vdev;
+
+	intr->ctrl = vnic_dev_get_res(vdev, RES_TYPE_INTR_CTRL, index);
+	if (!intr->ctrl) {
+		printk(KERN_ERR "Failed to hook INTR[%d].ctrl resource\n",
+			index);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
+	unsigned int coalescing_type, unsigned int mask_on_assertion)
+{
+	iowrite32(coalescing_timer, &intr->ctrl->coalescing_timer);
+	iowrite32(coalescing_type, &intr->ctrl->coalescing_type);
+	iowrite32(mask_on_assertion, &intr->ctrl->mask_on_assertion);
+	iowrite32(0, &intr->ctrl->int_credits);
+}
+
+void vnic_intr_clean(struct vnic_intr *intr)
+{
+	iowrite32(0, &intr->ctrl->int_credits);
+}
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_intr.h linux-2.6.26.3-enic/drivers/net/enic/vnic_intr.h
--- linux-2.6.26.3/drivers/net/enic/vnic_intr.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_intr.h	2008-09-08 15:16:26.000000000 -0700
@@ -0,0 +1,92 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_INTR_H_
+#define _VNIC_INTR_H_
+
+#include <linux/pci.h>
+
+#include "vnic_dev.h"
+
+#define VNIC_INTR_TIMER_MAX		0xffff
+
+#define VNIC_INTR_TIMER_TYPE_ABS	0
+#define VNIC_INTR_TIMER_TYPE_QUIET	1
+
+/* Interrupt control */
+struct vnic_intr_ctrl {
+	u32 coalescing_timer;		/* 0x00 */
+	u32 pad0;
+	u32 coalescing_value;		/* 0x08 */
+	u32 pad1;
+	u32 coalescing_type;		/* 0x10 */
+	u32 pad2;
+	u32 mask_on_assertion;		/* 0x18 */
+	u32 pad3;
+	u32 mask;			/* 0x20 */
+	u32 pad4;
+	u32 int_credits;		/* 0x28 */
+	u32 pad5;
+	u32 int_credit_return;		/* 0x30 */
+	u32 pad6;
+};
+
+struct vnic_intr {
+	unsigned int index;
+	struct vnic_dev *vdev;
+	struct vnic_intr_ctrl __iomem *ctrl;		/* memory-mapped */
+};
+
+static inline void vnic_intr_unmask(struct vnic_intr *intr)
+{
+	iowrite32(0, &intr->ctrl->mask);
+}
+
+static inline void vnic_intr_mask(struct vnic_intr *intr)
+{
+	iowrite32(1, &intr->ctrl->mask);
+}
+
+static inline void vnic_intr_return_credits(struct vnic_intr *intr,
+	unsigned int credits, int unmask, int reset_timer)
+{
+#define VNIC_INTR_UNMASK_SHIFT		16
+#define VNIC_INTR_RESET_TIMER_SHIFT	17
+
+	u32 int_credit_return = (credits & 0xffff) |
+		(unmask ? (1 << VNIC_INTR_UNMASK_SHIFT) : 0) |
+		(reset_timer ? (1 << VNIC_INTR_RESET_TIMER_SHIFT) : 0);
+
+	iowrite32(int_credit_return, &intr->ctrl->int_credit_return);
+}
+
+static inline u32 vnic_intr_legacy_pba(u32 __iomem *legacy_pba)
+{
+	/* get and ack interrupt in one read (clear-and-ack-on-read) */
+	return ioread32(legacy_pba);
+}
+
+void vnic_intr_free(struct vnic_intr *intr);
+int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
+	unsigned int index);
+void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
+	unsigned int coalescing_type, unsigned int mask_on_assertion);
+void vnic_intr_clean(struct vnic_intr *intr);
+
+#endif /* _VNIC_INTR_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_nic.h linux-2.6.26.3-enic/drivers/net/enic/vnic_nic.h
--- linux-2.6.26.3/drivers/net/enic/vnic_nic.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_nic.h	2008-09-08 15:16:27.000000000 -0700
@@ -0,0 +1,65 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_NIC_H_
+#define _VNIC_NIC_H_
+
+#define NIC_CFG_RSS_DEFAULT_CPU_MASK_FIELD	0xffUL
+#define NIC_CFG_RSS_DEFAULT_CPU_SHIFT		0
+#define NIC_CFG_RSS_HASH_TYPE			(0xffUL << 8)
+#define NIC_CFG_RSS_HASH_TYPE_MASK_FIELD	0xffUL
+#define NIC_CFG_RSS_HASH_TYPE_SHIFT		8
+#define NIC_CFG_RSS_HASH_BITS			(7UL << 16)
+#define NIC_CFG_RSS_HASH_BITS_MASK_FIELD	7UL
+#define NIC_CFG_RSS_HASH_BITS_SHIFT		16
+#define NIC_CFG_RSS_BASE_CPU			(7UL << 19)
+#define NIC_CFG_RSS_BASE_CPU_MASK_FIELD		7UL
+#define NIC_CFG_RSS_BASE_CPU_SHIFT		19
+#define NIC_CFG_RSS_ENABLE			(1UL << 22)
+#define NIC_CFG_RSS_ENABLE_MASK_FIELD		1UL
+#define NIC_CFG_RSS_ENABLE_SHIFT		22
+#define NIC_CFG_TSO_IPID_SPLIT_EN		(1UL << 23)
+#define NIC_CFG_TSO_IPID_SPLIT_EN_MASK_FIELD	1UL
+#define NIC_CFG_TSO_IPID_SPLIT_EN_SHIFT		23
+#define NIC_CFG_IG_VLAN_STRIP_EN		(1UL << 24)
+#define NIC_CFG_IG_VLAN_STRIP_EN_MASK_FIELD	1UL
+#define NIC_CFG_IG_VLAN_STRIP_EN_SHIFT		24
+
+static inline void vnic_set_nic_cfg(u32 *nic_cfg,
+	u8 rss_default_cpu, u8 rss_hash_type,
+	u8 rss_hash_bits, u8 rss_base_cpu,
+	u8 rss_enable, u8 tso_ipid_split_en,
+	u8 ig_vlan_strip_en)
+{
+	*nic_cfg = (rss_default_cpu & NIC_CFG_RSS_DEFAULT_CPU_MASK_FIELD) |
+		((rss_hash_type & NIC_CFG_RSS_HASH_TYPE_MASK_FIELD)
+			<< NIC_CFG_RSS_HASH_TYPE_SHIFT) |
+		((rss_hash_bits & NIC_CFG_RSS_HASH_BITS_MASK_FIELD)
+			<< NIC_CFG_RSS_HASH_BITS_SHIFT) |
+		((rss_base_cpu & NIC_CFG_RSS_BASE_CPU_MASK_FIELD)
+			<< NIC_CFG_RSS_BASE_CPU_SHIFT) |
+		((rss_enable & NIC_CFG_RSS_ENABLE_MASK_FIELD)
+			<< NIC_CFG_RSS_ENABLE_SHIFT) |
+		((tso_ipid_split_en & NIC_CFG_TSO_IPID_SPLIT_EN_MASK_FIELD)
+			<< NIC_CFG_TSO_IPID_SPLIT_EN_SHIFT) |
+		((ig_vlan_strip_en & NIC_CFG_IG_VLAN_STRIP_EN_MASK_FIELD)
+			<< NIC_CFG_IG_VLAN_STRIP_EN_SHIFT);
+}
+
+#endif /* _VNIC_NIC_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_resource.h linux-2.6.26.3-enic/drivers/net/enic/vnic_resource.h
--- linux-2.6.26.3/drivers/net/enic/vnic_resource.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_resource.h	2008-09-08 15:16:27.000000000 -0700
@@ -0,0 +1,63 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_RESOURCE_H_
+#define _VNIC_RESOURCE_H_
+
+#define VNIC_RES_MAGIC		0x766E6963L	/* 'vnic' */
+#define VNIC_RES_VERSION	0x00000000L
+
+/* vNIC resource types */
+enum vnic_res_type {
+	RES_TYPE_EOL,			/* End-of-list */
+	RES_TYPE_WQ,			/* Work queues */
+	RES_TYPE_RQ,			/* Receive queues */
+	RES_TYPE_CQ,			/* Completion queues */
+	RES_TYPE_RSVD1,
+	RES_TYPE_NIC_CFG,		/* Enet NIC config registers */
+	RES_TYPE_RSVD2,
+	RES_TYPE_RSVD3,
+	RES_TYPE_RSVD4,
+	RES_TYPE_RSVD5,
+	RES_TYPE_INTR_CTRL,		/* Interrupt ctrl table */
+	RES_TYPE_INTR_TABLE,		/* MSI/MSI-X Interrupt table */
+	RES_TYPE_INTR_PBA,		/* MSI/MSI-X PBA table */
+	RES_TYPE_INTR_PBA_LEGACY,	/* Legacy intr status, r2c */
+	RES_TYPE_RSVD6,
+	RES_TYPE_RSVD7,
+	RES_TYPE_DEVCMD,		/* Device command region */
+	RES_TYPE_PASS_THRU_PAGE,	/* Pass-thru page */
+
+	RES_TYPE_MAX,			/* Count of resource types */
+};
+
+struct vnic_resource_header {
+	u32 magic;
+	u32 version;
+};
+
+struct vnic_resource {
+	u8 type;
+	u8 bar;
+	u8 pad[2];
+	u32 bar_offset;
+	u32 count;
+};
+
+#endif /* _VNIC_RESOURCE_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_rq.c linux-2.6.26.3-enic/drivers/net/enic/vnic_rq.c
--- linux-2.6.26.3/drivers/net/enic/vnic_rq.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_rq.c	2008-09-08 15:16:27.000000000 -0700
@@ -0,0 +1,199 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+#include "vnic_dev.h"
+#include "vnic_rq.h"
+
+static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
+{
+	struct vnic_rq_buf *buf;
+	struct vnic_dev *vdev;
+	unsigned int i, j, count = rq->ring.desc_count;
+	unsigned int blks = VNIC_RQ_BUF_BLKS_NEEDED(count);
+
+	vdev = rq->vdev;
+
+	for (i = 0; i < blks; i++) {
+		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ, GFP_ATOMIC);
+		if (!rq->bufs[i]) {
+			printk(KERN_ERR "Failed to alloc rq_bufs\n");
+			return -ENOMEM;
+		}
+	}
+
+	for (i = 0; i < blks; i++) {
+		buf = rq->bufs[i];
+		for (j = 0; j < VNIC_RQ_BUF_BLK_ENTRIES; j++) {
+			buf->index = i * VNIC_RQ_BUF_BLK_ENTRIES + j;
+			buf->desc = (u8 *)rq->ring.descs +
+				rq->ring.desc_size * buf->index;
+			if (buf->index + 1 == count) {
+				buf->next = rq->bufs[0];
+				break;
+			} else if (j + 1 == VNIC_RQ_BUF_BLK_ENTRIES) {
+				buf->next = rq->bufs[i + 1];
+			} else {
+				buf->next = buf + 1;
+				buf++;
+			}
+		}
+	}
+
+	rq->to_use = rq->to_clean = rq->bufs[0];
+	rq->buf_index = 0;
+
+	return 0;
+}
+
+void vnic_rq_free(struct vnic_rq *rq)
+{
+	struct vnic_dev *vdev;
+	unsigned int i;
+
+	vdev = rq->vdev;
+
+	vnic_dev_free_desc_ring(vdev, &rq->ring);
+
+	for (i = 0; i < VNIC_RQ_BUF_BLKS_MAX; i++) {
+		kfree(rq->bufs[i]);
+		rq->bufs[i] = NULL;
+	}
+
+	rq->ctrl = NULL;
+}
+
+int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
+	unsigned int desc_count, unsigned int desc_size)
+{
+	int err;
+
+	rq->index = index;
+	rq->vdev = vdev;
+
+	rq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_RQ, index);
+	if (!rq->ctrl) {
+		printk(KERN_ERR "Failed to hook RQ[%d] resource\n", index);
+		return -EINVAL;
+	}
+
+	vnic_rq_disable(rq);
+
+	err = vnic_dev_alloc_desc_ring(vdev, &rq->ring, desc_count, desc_size);
+	if (err)
+		return err;
+
+	err = vnic_rq_alloc_bufs(rq);
+	if (err) {
+		vnic_rq_free(rq);
+		return err;
+	}
+
+	return 0;
+}
+
+void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset)
+{
+	u64 paddr;
+	u32 fetch_index;
+
+	paddr = (u64)rq->ring.base_addr | VNIC_PADDR_TARGET;
+	writeq(paddr, &rq->ctrl->ring_base);
+	iowrite32(rq->ring.desc_count, &rq->ctrl->ring_size);
+	iowrite32(cq_index, &rq->ctrl->cq_index);
+	iowrite32(error_interrupt_enable, &rq->ctrl->error_interrupt_enable);
+	iowrite32(error_interrupt_offset, &rq->ctrl->error_interrupt_offset);
+	iowrite32(0, &rq->ctrl->dropped_packet_count);
+	iowrite32(0, &rq->ctrl->error_status);
+
+	/* Use current fetch_index as the ring starting point */
+	fetch_index = ioread32(&rq->ctrl->fetch_index);
+	rq->to_use = rq->to_clean =
+		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
+			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
+	iowrite32(fetch_index, &rq->ctrl->posted_index);
+
+	rq->buf_index = 0;
+}
+
+unsigned int vnic_rq_error_status(struct vnic_rq *rq)
+{
+	return ioread32(&rq->ctrl->error_status);
+}
+
+void vnic_rq_enable(struct vnic_rq *rq)
+{
+	iowrite32(1, &rq->ctrl->enable);
+}
+
+int vnic_rq_disable(struct vnic_rq *rq)
+{
+	unsigned int wait;
+
+	iowrite32(0, &rq->ctrl->enable);
+
+	/* Wait for HW to ACK disable request */
+	for (wait = 0; wait < 100; wait++) {
+		if (!(ioread32(&rq->ctrl->running)))
+			return 0;
+		udelay(1);
+	}
+
+	printk(KERN_ERR "Failed to disable RQ[%d]\n", rq->index);
+
+	return -ETIMEDOUT;
+}
+
+void vnic_rq_clean(struct vnic_rq *rq,
+	void (*buf_clean)(struct vnic_rq *rq, struct vnic_rq_buf *buf))
+{
+	struct vnic_rq_buf *buf;
+	u32 fetch_index;
+
+	BUG_ON(ioread32(&rq->ctrl->enable));
+
+	buf = rq->to_clean;
+
+	while (vnic_rq_desc_used(rq) > 0) {
+
+		(*buf_clean)(rq, buf);
+
+		buf = rq->to_clean = buf->next;
+		rq->ring.desc_avail++;
+	}
+
+	/* Use current fetch_index as the ring starting point */
+	fetch_index = ioread32(&rq->ctrl->fetch_index);
+	rq->to_use = rq->to_clean =
+		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
+			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
+	iowrite32(fetch_index, &rq->ctrl->posted_index);
+
+	rq->buf_index = 0;
+
+	vnic_dev_clear_desc_ring(&rq->ring);
+}
+
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_rq.h linux-2.6.26.3-enic/drivers/net/enic/vnic_rq.h
--- linux-2.6.26.3/drivers/net/enic/vnic_rq.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_rq.h	2008-09-08 15:16:28.000000000 -0700
@@ -0,0 +1,204 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_RQ_H_
+#define _VNIC_RQ_H_
+
+#include <linux/pci.h>
+
+#include "vnic_dev.h"
+#include "vnic_cq.h"
+
+/* Receive queue control */
+struct vnic_rq_ctrl {
+	u64 ring_base;			/* 0x00 */
+	u32 ring_size;			/* 0x08 */
+	u32 pad0;
+	u32 posted_index;		/* 0x10 */
+	u32 pad1;
+	u32 cq_index;			/* 0x18 */
+	u32 pad2;
+	u32 enable;			/* 0x20 */
+	u32 pad3;
+	u32 running;			/* 0x28 */
+	u32 pad4;
+	u32 fetch_index;		/* 0x30 */
+	u32 pad5;
+	u32 error_interrupt_enable;	/* 0x38 */
+	u32 pad6;
+	u32 error_interrupt_offset;	/* 0x40 */
+	u32 pad7;
+	u32 error_status;		/* 0x48 */
+	u32 pad8;
+	u32 dropped_packet_count;	/* 0x50 */
+	u32 pad9;
+	u32 dropped_packet_count_rc;	/* 0x58 */
+	u32 pad10;
+};
+
+/* Break the vnic_rq_buf allocations into blocks of 64 entries */
+#define VNIC_RQ_BUF_BLK_ENTRIES 64
+#define VNIC_RQ_BUF_BLK_SZ \
+	(VNIC_RQ_BUF_BLK_ENTRIES * sizeof(struct vnic_rq_buf))
+#define VNIC_RQ_BUF_BLKS_NEEDED(entries) \
+	DIV_ROUND_UP(entries, VNIC_RQ_BUF_BLK_ENTRIES)
+#define VNIC_RQ_BUF_BLKS_MAX VNIC_RQ_BUF_BLKS_NEEDED(4096)
+
+struct vnic_rq_buf {
+	struct vnic_rq_buf *next;
+	dma_addr_t dma_addr;
+	void *os_buf;
+	unsigned int os_buf_index;
+	unsigned int len;
+	unsigned int index;
+	void *desc;
+};
+
+struct vnic_rq {
+	unsigned int index;
+	struct vnic_dev *vdev;
+	struct vnic_rq_ctrl __iomem *ctrl;              /* memory-mapped */
+	struct vnic_dev_ring ring;
+	struct vnic_rq_buf *bufs[VNIC_RQ_BUF_BLKS_MAX];
+	struct vnic_rq_buf *to_use;
+	struct vnic_rq_buf *to_clean;
+	void *os_buf_head;
+	unsigned int buf_index;
+	unsigned int pkts_outstanding;
+};
+
+static inline unsigned int vnic_rq_desc_avail(struct vnic_rq *rq)
+{
+	/* how many does SW own? */
+	return rq->ring.desc_avail;
+}
+
+static inline unsigned int vnic_rq_desc_used(struct vnic_rq *rq)
+{
+	/* how many does HW own? */
+	return rq->ring.desc_count - rq->ring.desc_avail - 1;
+}
+
+static inline void *vnic_rq_next_desc(struct vnic_rq *rq)
+{
+	return rq->to_use->desc;
+}
+
+static inline unsigned int vnic_rq_next_index(struct vnic_rq *rq)
+{
+	return rq->to_use->index;
+}
+
+static inline unsigned int vnic_rq_next_buf_index(struct vnic_rq *rq)
+{
+	return rq->buf_index++;
+}
+
+static inline void vnic_rq_post(struct vnic_rq *rq,
+	void *os_buf, unsigned int os_buf_index,
+	dma_addr_t dma_addr, unsigned int len)
+{
+	struct vnic_rq_buf *buf = rq->to_use;
+
+	buf->os_buf = os_buf;
+	buf->os_buf_index = os_buf_index;
+	buf->dma_addr = dma_addr;
+	buf->len = len;
+
+	buf = buf->next;
+	rq->to_use = buf;
+	rq->ring.desc_avail--;
+
+	/* Move the posted_index every nth descriptor
+	 */
+
+#ifndef VNIC_RQ_RETURN_RATE
+#define VNIC_RQ_RETURN_RATE		0xf	/* keep 2^n - 1 */
+#endif
+
+	if ((buf->index & VNIC_RQ_RETURN_RATE) == 0)
+		iowrite32(buf->index, &rq->ctrl->posted_index);
+}
+
+static inline void vnic_rq_return_descs(struct vnic_rq *rq, unsigned int count)
+{
+	rq->ring.desc_avail += count;
+}
+
+enum desc_return_options {
+	VNIC_RQ_RETURN_DESC,
+	VNIC_RQ_DEFER_RETURN_DESC,
+};
+
+static inline void vnic_rq_service(struct vnic_rq *rq,
+	struct cq_desc *cq_desc, u16 completed_index,
+	int desc_return, void (*buf_service)(struct vnic_rq *rq,
+	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
+	int skipped, void *opaque), void *opaque)
+{
+	struct vnic_rq_buf *buf;
+	int skipped;
+
+	buf = rq->to_clean;
+	while (1) {
+
+		skipped = (buf->index != completed_index);
+
+		(*buf_service)(rq, cq_desc, buf, skipped, opaque);
+
+		if (desc_return == VNIC_RQ_RETURN_DESC)
+			rq->ring.desc_avail++;
+
+		rq->to_clean = buf->next;
+
+		if (!skipped)
+			break;
+
+		buf = rq->to_clean;
+	}
+}
+
+static inline int vnic_rq_fill(struct vnic_rq *rq,
+	int (*buf_fill)(struct vnic_rq *rq))
+{
+	int err;
+
+	while (vnic_rq_desc_avail(rq) > 1) {
+
+		err = (*buf_fill)(rq);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+void vnic_rq_free(struct vnic_rq *rq);
+int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
+	unsigned int desc_count, unsigned int desc_size);
+void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset);
+unsigned int vnic_rq_error_status(struct vnic_rq *rq);
+void vnic_rq_enable(struct vnic_rq *rq);
+int vnic_rq_disable(struct vnic_rq *rq);
+void vnic_rq_clean(struct vnic_rq *rq,
+	void (*buf_clean)(struct vnic_rq *rq, struct vnic_rq_buf *buf));
+
+#endif /* _VNIC_RQ_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_rss.h linux-2.6.26.3-enic/drivers/net/enic/vnic_rss.h
--- linux-2.6.26.3/drivers/net/enic/vnic_rss.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_rss.h	2008-09-08 15:16:28.000000000 -0700
@@ -0,0 +1,32 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ */
+
+#ifndef _VNIC_RSS_H_
+#define _VNIC_RSS_H_
+
+/* RSS key array */
+union vnic_rss_key {
+	struct {
+		u8 b[10];
+		u8 b_pad[6];
+	} key[4];
+	u64 raw[8];
+};
+
+/* RSS cpu array */
+union vnic_rss_cpu {
+	struct {
+		u8 b[4] ;
+		u8 b_pad[4];
+	} cpu[32];
+	u64 raw[32];
+};
+
+void vnic_set_rss_key(union vnic_rss_key *rss_key, u8 *key);
+void vnic_set_rss_cpu(union vnic_rss_cpu *rss_cpu, u8 *cpu);
+void vnic_get_rss_key(union vnic_rss_key *rss_key, u8 *key);
+void vnic_get_rss_cpu(union vnic_rss_cpu *rss_cpu, u8 *cpu);
+
+#endif /* _VNIC_RSS_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_stats.h linux-2.6.26.3-enic/drivers/net/enic/vnic_stats.h
--- linux-2.6.26.3/drivers/net/enic/vnic_stats.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_stats.h	2008-09-08 15:16:28.000000000 -0700
@@ -0,0 +1,70 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_STATS_H_
+#define _VNIC_STATS_H_
+
+/* Tx statistics */
+struct vnic_tx_stats {
+	u64 tx_frames_ok;
+	u64 tx_unicast_frames_ok;
+	u64 tx_multicast_frames_ok;
+	u64 tx_broadcast_frames_ok;
+	u64 tx_bytes_ok;
+	u64 tx_unicast_bytes_ok;
+	u64 tx_multicast_bytes_ok;
+	u64 tx_broadcast_bytes_ok;
+	u64 tx_drops;
+	u64 tx_errors;
+	u64 tx_tso;
+	u64 rsvd[16];
+};
+
+/* Rx statistics */
+struct vnic_rx_stats {
+	u64 rx_frames_ok;
+	u64 rx_frames_total;
+	u64 rx_unicast_frames_ok;
+	u64 rx_multicast_frames_ok;
+	u64 rx_broadcast_frames_ok;
+	u64 rx_bytes_ok;
+	u64 rx_unicast_bytes_ok;
+	u64 rx_multicast_bytes_ok;
+	u64 rx_broadcast_bytes_ok;
+	u64 rx_drop;
+	u64 rx_no_bufs;
+	u64 rx_errors;
+	u64 rx_rss;
+	u64 rx_crc_errors;
+	u64 rx_frames_64;
+	u64 rx_frames_127;
+	u64 rx_frames_255;
+	u64 rx_frames_511;
+	u64 rx_frames_1023;
+	u64 rx_frames_1518;
+	u64 rx_frames_to_max;
+	u64 rsvd[16];
+};
+
+struct vnic_stats {
+	struct vnic_tx_stats tx;
+	struct vnic_rx_stats rx;
+};
+
+#endif /* _VNIC_STATS_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_wq.c linux-2.6.26.3-enic/drivers/net/enic/vnic_wq.c
--- linux-2.6.26.3/drivers/net/enic/vnic_wq.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_wq.c	2008-09-08 15:16:28.000000000 -0700
@@ -0,0 +1,184 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+#include "vnic_dev.h"
+#include "vnic_wq.h"
+
+static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
+{
+	struct vnic_wq_buf *buf;
+	struct vnic_dev *vdev;
+	unsigned int i, j, count = wq->ring.desc_count;
+	unsigned int blks = VNIC_WQ_BUF_BLKS_NEEDED(count);
+
+	vdev = wq->vdev;
+
+	for (i = 0; i < blks; i++) {
+		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ, GFP_ATOMIC);
+		if (!wq->bufs[i]) {
+			printk(KERN_ERR "Failed to alloc wq_bufs\n");
+			return -ENOMEM;
+		}
+	}
+
+	for (i = 0; i < blks; i++) {
+		buf = wq->bufs[i];
+		for (j = 0; j < VNIC_WQ_BUF_BLK_ENTRIES; j++) {
+			buf->index = i * VNIC_WQ_BUF_BLK_ENTRIES + j;
+			buf->desc = (u8 *)wq->ring.descs +
+				wq->ring.desc_size * buf->index;
+			if (buf->index + 1 == count) {
+				buf->next = wq->bufs[0];
+				break;
+			} else if (j + 1 == VNIC_WQ_BUF_BLK_ENTRIES) {
+				buf->next = wq->bufs[i + 1];
+			} else {
+				buf->next = buf + 1;
+				buf++;
+			}
+		}
+	}
+
+	wq->to_use = wq->to_clean = wq->bufs[0];
+
+	return 0;
+}
+
+void vnic_wq_free(struct vnic_wq *wq)
+{
+	struct vnic_dev *vdev;
+	unsigned int i;
+
+	vdev = wq->vdev;
+
+	vnic_dev_free_desc_ring(vdev, &wq->ring);
+
+	for (i = 0; i < VNIC_WQ_BUF_BLKS_MAX; i++) {
+		kfree(wq->bufs[i]);
+		wq->bufs[i] = NULL;
+	}
+
+	wq->ctrl = NULL;
+}
+
+int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
+	unsigned int desc_count, unsigned int desc_size)
+{
+	int err;
+
+	wq->index = index;
+	wq->vdev = vdev;
+
+	wq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_WQ, index);
+	if (!wq->ctrl) {
+		printk(KERN_ERR "Failed to hook WQ[%d] resource\n", index);
+		return -EINVAL;
+	}
+
+	vnic_wq_disable(wq);
+
+	err = vnic_dev_alloc_desc_ring(vdev, &wq->ring, desc_count, desc_size);
+	if (err)
+		return err;
+
+	err = vnic_wq_alloc_bufs(wq);
+	if (err) {
+		vnic_wq_free(wq);
+		return err;
+	}
+
+	return 0;
+}
+
+void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset)
+{
+	u64 paddr;
+
+	paddr = (u64)wq->ring.base_addr | VNIC_PADDR_TARGET;
+	writeq(paddr, &wq->ctrl->ring_base);
+	iowrite32(wq->ring.desc_count, &wq->ctrl->ring_size);
+	iowrite32(0, &wq->ctrl->fetch_index);
+	iowrite32(0, &wq->ctrl->posted_index);
+	iowrite32(cq_index, &wq->ctrl->cq_index);
+	iowrite32(error_interrupt_enable, &wq->ctrl->error_interrupt_enable);
+	iowrite32(error_interrupt_offset, &wq->ctrl->error_interrupt_offset);
+	iowrite32(0, &wq->ctrl->error_status);
+}
+
+unsigned int vnic_wq_error_status(struct vnic_wq *wq)
+{
+	return ioread32(&wq->ctrl->error_status);
+}
+
+void vnic_wq_enable(struct vnic_wq *wq)
+{
+	iowrite32(1, &wq->ctrl->enable);
+}
+
+int vnic_wq_disable(struct vnic_wq *wq)
+{
+	unsigned int wait;
+
+	iowrite32(0, &wq->ctrl->enable);
+
+	/* Wait for HW to ACK disable request */
+	for (wait = 0; wait < 100; wait++) {
+		if (!(ioread32(&wq->ctrl->running)))
+			return 0;
+		udelay(1);
+	}
+
+	printk(KERN_ERR "Failed to disable WQ[%d]\n", wq->index);
+
+	return -ETIMEDOUT;
+}
+
+void vnic_wq_clean(struct vnic_wq *wq,
+	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf))
+{
+	struct vnic_wq_buf *buf;
+
+	BUG_ON(ioread32(&wq->ctrl->enable));
+
+	buf = wq->to_clean;
+
+	while (vnic_wq_desc_used(wq) > 0) {
+
+		(*buf_clean)(wq, buf);
+
+		buf = wq->to_clean = buf->next;
+		wq->ring.desc_avail++;
+	}
+
+	wq->to_use = wq->to_clean = wq->bufs[0];
+
+	iowrite32(0, &wq->ctrl->fetch_index);
+	iowrite32(0, &wq->ctrl->posted_index);
+	iowrite32(0, &wq->ctrl->error_status);
+
+	vnic_dev_clear_desc_ring(&wq->ring);
+}
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/vnic_wq.h linux-2.6.26.3-enic/drivers/net/enic/vnic_wq.h
--- linux-2.6.26.3/drivers/net/enic/vnic_wq.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/vnic_wq.h	2008-09-08 15:16:29.000000000 -0700
@@ -0,0 +1,154 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _VNIC_WQ_H_
+#define _VNIC_WQ_H_
+
+#include <linux/pci.h>
+
+#include "vnic_dev.h"
+#include "vnic_cq.h"
+
+/* Work queue control */
+struct vnic_wq_ctrl {
+	u64 ring_base;			/* 0x00 */
+	u32 ring_size;			/* 0x08 */
+	u32 pad0;
+	u32 posted_index;		/* 0x10 */
+	u32 pad1;
+	u32 cq_index;			/* 0x18 */
+	u32 pad2;
+	u32 enable;			/* 0x20 */
+	u32 pad3;
+	u32 running;			/* 0x28 */
+	u32 pad4;
+	u32 fetch_index;		/* 0x30 */
+	u32 pad5;
+	u32 dca_value;			/* 0x38 */
+	u32 pad6;
+	u32 error_interrupt_enable;	/* 0x40 */
+	u32 pad7;
+	u32 error_interrupt_offset;	/* 0x48 */
+	u32 pad8;
+	u32 error_status;		/* 0x50 */
+	u32 pad9;
+};
+
+struct vnic_wq_buf {
+	struct vnic_wq_buf *next;
+	dma_addr_t dma_addr;
+	void *os_buf;
+	unsigned int len;
+	unsigned int index;
+	int sop;
+	void *desc;
+};
+
+/* Break the vnic_wq_buf allocations into blocks of 64 entries */
+#define VNIC_WQ_BUF_BLK_ENTRIES 64
+#define VNIC_WQ_BUF_BLK_SZ \
+	(VNIC_WQ_BUF_BLK_ENTRIES * sizeof(struct vnic_wq_buf))
+#define VNIC_WQ_BUF_BLKS_NEEDED(entries) \
+	DIV_ROUND_UP(entries, VNIC_WQ_BUF_BLK_ENTRIES)
+#define VNIC_WQ_BUF_BLKS_MAX VNIC_WQ_BUF_BLKS_NEEDED(4096)
+
+struct vnic_wq {
+	unsigned int index;
+	struct vnic_dev *vdev;
+	struct vnic_wq_ctrl __iomem *ctrl;              /* memory-mapped */
+	struct vnic_dev_ring ring;
+	struct vnic_wq_buf *bufs[VNIC_WQ_BUF_BLKS_MAX];
+	struct vnic_wq_buf *to_use;
+	struct vnic_wq_buf *to_clean;
+	unsigned int pkts_outstanding;
+};
+
+static inline unsigned int vnic_wq_desc_avail(struct vnic_wq *wq)
+{
+	/* how many does SW own? */
+	return wq->ring.desc_avail;
+}
+
+static inline unsigned int vnic_wq_desc_used(struct vnic_wq *wq)
+{
+	/* how many does HW own? */
+	return wq->ring.desc_count - wq->ring.desc_avail - 1;
+}
+
+static inline void *vnic_wq_next_desc(struct vnic_wq *wq)
+{
+	return wq->to_use->desc;
+}
+
+static inline void vnic_wq_post(struct vnic_wq *wq,
+	void *os_buf, dma_addr_t dma_addr,
+	unsigned int len, int sop, int eop)
+{
+	struct vnic_wq_buf *buf = wq->to_use;
+
+	buf->sop = sop;
+	buf->os_buf = eop ? os_buf : NULL;
+	buf->dma_addr = dma_addr;
+	buf->len = len;
+
+	buf = buf->next;
+	if (eop)
+		iowrite32(buf->index, &wq->ctrl->posted_index);
+	wq->to_use = buf;
+
+	wq->ring.desc_avail--;
+}
+
+static inline void vnic_wq_service(struct vnic_wq *wq,
+	struct cq_desc *cq_desc, u16 completed_index,
+	void (*buf_service)(struct vnic_wq *wq,
+	struct cq_desc *cq_desc, struct vnic_wq_buf *buf, void *opaque),
+	void *opaque)
+{
+	struct vnic_wq_buf *buf;
+
+	buf = wq->to_clean;
+	while (1) {
+
+		(*buf_service)(wq, cq_desc, buf, opaque);
+
+		wq->ring.desc_avail++;
+
+		wq->to_clean = buf->next;
+
+		if (buf->index == completed_index)
+			break;
+
+		buf = wq->to_clean;
+	}
+}
+
+void vnic_wq_free(struct vnic_wq *wq);
+int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
+	unsigned int desc_count, unsigned int desc_size);
+void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
+	unsigned int error_interrupt_enable,
+	unsigned int error_interrupt_offset);
+unsigned int vnic_wq_error_status(struct vnic_wq *wq);
+void vnic_wq_enable(struct vnic_wq *wq);
+int vnic_wq_disable(struct vnic_wq *wq);
+void vnic_wq_clean(struct vnic_wq *wq,
+	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf));
+
+#endif /* _VNIC_WQ_H_ */
diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/wq_enet_desc.h linux-2.6.26.3-enic/drivers/net/enic/wq_enet_desc.h
--- linux-2.6.26.3/drivers/net/enic/wq_enet_desc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.26.3-enic/drivers/net/enic/wq_enet_desc.h	2008-09-08 15:16:29.000000000 -0700
@@ -0,0 +1,98 @@
+/*
+ * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef _WQ_ENET_DESC_H_
+#define _WQ_ENET_DESC_H_
+
+/* Ethernet work queue descriptor: 16B */
+struct wq_enet_desc {
+	__le64 address;
+	__le16 length;
+	__le16 mss_loopback;
+	__le16 header_length_flags;
+	__le16 vlan_tag;
+};
+
+#define WQ_ENET_ADDR_BITS		64
+#define WQ_ENET_LEN_BITS		14
+#define WQ_ENET_LEN_MASK		((1 << WQ_ENET_LEN_BITS) - 1)
+#define WQ_ENET_MSS_BITS		14
+#define WQ_ENET_MSS_MASK		((1 << WQ_ENET_MSS_BITS) - 1)
+#define WQ_ENET_MSS_SHIFT		2
+#define WQ_ENET_LOOPBACK_SHIFT		1
+#define WQ_ENET_HDRLEN_BITS		10
+#define WQ_ENET_HDRLEN_MASK		((1 << WQ_ENET_HDRLEN_BITS) - 1)
+#define WQ_ENET_FLAGS_OM_BITS		2
+#define WQ_ENET_FLAGS_OM_MASK		((1 << WQ_ENET_FLAGS_OM_BITS) - 1)
+#define WQ_ENET_FLAGS_EOP_SHIFT		12
+#define WQ_ENET_FLAGS_CQ_ENTRY_SHIFT	13
+#define WQ_ENET_FLAGS_FCOE_ENCAP_SHIFT	14
+#define WQ_ENET_FLAGS_VLAN_TAG_INSERT_SHIFT	15
+
+#define WQ_ENET_OFFLOAD_MODE_CSUM	0
+#define WQ_ENET_OFFLOAD_MODE_RESERVED	1
+#define WQ_ENET_OFFLOAD_MODE_CSUM_L4	2
+#define WQ_ENET_OFFLOAD_MODE_TSO	3
+
+static inline void wq_enet_desc_enc(struct wq_enet_desc *desc,
+	u64 address, u16 length, u16 mss, u16 header_length,
+	u8 offload_mode, u8 eop, u8 cq_entry, u8 fcoe_encap,
+	u8 vlan_tag_insert, u16 vlan_tag, u8 loopback)
+{
+	desc->address = cpu_to_le64(address);
+	desc->length = cpu_to_le16(length & WQ_ENET_LEN_MASK);
+	desc->mss_loopback = cpu_to_le16((mss & WQ_ENET_MSS_MASK) <<
+		WQ_ENET_MSS_SHIFT | (loopback & 1) << WQ_ENET_LOOPBACK_SHIFT);
+	desc->header_length_flags = cpu_to_le16(
+		(header_length & WQ_ENET_HDRLEN_MASK) |
+		(offload_mode & WQ_ENET_FLAGS_OM_MASK) << WQ_ENET_HDRLEN_BITS |
+		(eop & 1) << WQ_ENET_FLAGS_EOP_SHIFT |
+		(cq_entry & 1) << WQ_ENET_FLAGS_CQ_ENTRY_SHIFT |
+		(fcoe_encap & 1) << WQ_ENET_FLAGS_FCOE_ENCAP_SHIFT |
+		(vlan_tag_insert & 1) << WQ_ENET_FLAGS_VLAN_TAG_INSERT_SHIFT);
+	desc->vlan_tag = cpu_to_le16(vlan_tag);
+}
+
+static inline void wq_enet_desc_dec(struct wq_enet_desc *desc,
+	u64 *address, u16 *length, u16 *mss, u16 *header_length,
+	u8 *offload_mode, u8 *eop, u8 *cq_entry, u8 *fcoe_encap,
+	u8 *vlan_tag_insert, u16 *vlan_tag, u8 *loopback)
+{
+	*address = le64_to_cpu(desc->address);
+	*length = le16_to_cpu(desc->length) & WQ_ENET_LEN_MASK;
+	*mss = (le16_to_cpu(desc->mss_loopback) >> WQ_ENET_MSS_SHIFT) &
+		WQ_ENET_MSS_MASK;
+	*loopback = (u8)((le16_to_cpu(desc->mss_loopback) >>
+		WQ_ENET_LOOPBACK_SHIFT) & 1);
+	*header_length = le16_to_cpu(desc->header_length_flags) &
+		WQ_ENET_HDRLEN_MASK;
+	*offload_mode = (u8)((le16_to_cpu(desc->header_length_flags) >>
+		WQ_ENET_HDRLEN_BITS) & WQ_ENET_FLAGS_OM_MASK);
+	*eop = (u8)((le16_to_cpu(desc->header_length_flags) >>
+		WQ_ENET_FLAGS_EOP_SHIFT) & 1);
+	*cq_entry = (u8)((le16_to_cpu(desc->header_length_flags) >>
+		WQ_ENET_FLAGS_CQ_ENTRY_SHIFT) & 1);
+	*fcoe_encap = (u8)((le16_to_cpu(desc->header_length_flags) >>
+		WQ_ENET_FLAGS_FCOE_ENCAP_SHIFT) & 1);
+	*vlan_tag_insert = (u8)((le16_to_cpu(desc->header_length_flags) >>
+		WQ_ENET_FLAGS_VLAN_TAG_INSERT_SHIFT) & 1);
+	*vlan_tag = le16_to_cpu(desc->vlan_tag);
+}
+
+#endif /* _WQ_ENET_DESC_H_ */
