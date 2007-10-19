From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 2/14 v2] nes: device structures and defines
Date: Fri, 19 Oct 2007 15:04:08 -0500
Message-ID: <200710192004.l9JK48dm021704@neteffect.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: ewg@lists.openfabrics.org, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Main include file for device structures and defines.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/nes.h	2007-10-19 09:59:12.000000000 -0500
@@ -0,0 +1,613 @@
+/*
+ * Copyright (c) 2006 - 2007 NetEffect, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
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
+
+#ifndef __NES_H
+#define __NES_H
+
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/dma-mapping.h>
+#include <linux/workqueue.h>
+#include <linux/slab.h>
+#include <asm/semaphore.h>
+#include <linux/version.h>
+#include <asm/io.h>
+
+#include <rdma/ib_smi.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_pack.h>
+#include <rdma/rdma_cm.h>
+#include <rdma/iw_cm.h>
+
+#define TBIRD
+#define NES_TWO_PORT
+#define NES_ENABLE_CQE_READ
+#define NES_SEND_FIRST_WRITE
+
+#define QUEUE_DISCONNECTS
+
+#define DRV_BUILD "1"
+
+#define DRV_NAME    "iw_nes"
+#define DRV_VERSION	"0.5 Build " DRV_BUILD
+#define PFX         DRV_NAME ": "
+
+/*
+ * NetEffect PCI vendor id and NE010 PCI device id.
+ */
+#ifndef PCI_VENDOR_ID_NETEFFECT	/* not in pci.ids yet */
+#define PCI_VENDOR_ID_NETEFFECT 0x1678
+#define PCI_DEVICE_ID_NETEFFECT_NE020 0x0100
+#endif
+
+#define NE020_REV		4
+#define NE020_REV1		5
+
+#define BAR_0                	0
+#define BAR_1                	2
+
+#define RX_BUF_SIZE         	(1536 + 8)
+
+#define NES_REG0_SIZE       	(4 * 1024)
+#define NES_TX_TIMEOUT			(6*HZ)
+#define NES_FIRST_QPN			64
+#define NES_SW_CONTEXT_ALIGN 	1024
+
+#define NES_NIC_MAX_NICS		16
+#define NES_MAX_ARP_TABLE_SIZE 	4096
+
+#define MAX_DPC_ITERATIONS 		128
+
+#define NES_DRV_OPT_ENABLE_MPA_VER_0	0x00000001
+#define NES_DRV_OPT_DISABLE_MPA_CRC		0x00000002
+#define NES_DRV_OPT_DISABLE_FIRST_WRITE	0x00000004
+#define NES_DRV_OPT_DISABLE_INTF		0x00000008
+#define NES_DRV_OPT_ENABLE_MSI			0x00000010
+#define NES_DRV_OPT_DUAL_LOGICAL_PORT	0x00000020
+#define NES_DRV_OPT_SUPRESS_OPTION_BC	0x00000040
+#define NES_DRV_OPT_NO_INLINE_DATA		0x00000080
+
+#define NES_AEQ_EVENT_TIMEOUT 2500
+#define NES_DISCONNECT_EVENT_TIMEOUT 2000
+
+/* debug levels */
+#define NES_DBG_HW			0x00000001
+#define NES_DBG_INIT		0x00000002
+#define NES_DBG_ISR			0x00000004
+#define NES_DBG_PHY			0x00000008
+#define NES_DBG_NETDEV		0x00000010
+#define NES_DBG_CM			0x00000020
+#define NES_DBG_CM1         0x00000040
+#define NES_DBG_NIC_RX		0x00000080
+#define NES_DBG_NIC_TX		0x00000100
+#define NES_DBG_CQP			0x00000200
+#define NES_DBG_MMAP		0x00000400
+#define NES_DBG_MR			0x00000800
+#define NES_DBG_PD			0x00001000
+#define NES_DBG_CQ			0x00002000
+#define NES_DBG_QP			0x00004000
+#define NES_DBG_MOD_QP		0x00008000
+#define NES_DBG_AEQ			0x00010000
+#define NES_DBG_IW_RX		0x00020000
+#define NES_DBG_IW_TX		0x00040000
+#define NES_DBG_SHUTDOWN	0x00080000
+#define NES_DBG_RSVD1		0x10000000
+#define NES_DBG_RSVD2		0x20000000
+#define NES_DBG_RSVD3		0x40000000
+#define NES_DBG_RSVD4		0x80000000
+#define NES_DBG_ALL			0xffffffff
+
+#ifdef CONFIG_INFINIBAND_NES_DEBUG
+#define assert(expr)												\
+if(!(expr)) {														\
+	printk(KERN_ERR PFX "Assertion failed! %s, %s, %s, line %d\n",	\
+		   #expr, __FILE__, __FUNCTION__, __LINE__);				\
+}
+
+#define nes_debug(level, fmt, args...) \
+	if (level & nes_debug_level) \
+		printk(KERN_ERR PFX "%s[%u]: " fmt, __FUNCTION__, __LINE__, ##args)
+
+#ifndef dprintk
+#define dprintk(fmt, args...) do { printk(KERN_ERR PFX fmt, ##args); } while (0)
+#endif
+#define NES_EVENT_TIMEOUT	1200000
+/* #define NES_EVENT_TIMEOUT	1200 */
+#else
+#define assert(expr)          do {} while (0)
+#define nes_debug(level, fmt, args...)
+#define dprintk(fmt, args...) do {} while (0)
+
+#define NES_EVENT_TIMEOUT	100000
+#endif
+
+#include "nes_hw.h"
+#include "nes_verbs.h"
+#include "nes_context.h"
+#include "nes_user.h"
+#include "nes_cm.h"
+
+extern int max_mtu;
+extern int nics_per_function;
+#define max_frame_len (max_mtu+ETH_HLEN)
+extern int interrupt_mod_interval;
+extern int nes_if_count;
+extern int mpa_version;
+extern int disable_mpa_crc;
+extern unsigned int send_first;
+extern unsigned int nes_drv_opt;
+extern unsigned int nes_debug_level;
+
+extern struct list_head nes_adapter_list;
+extern struct list_head nes_dev_list;
+
+extern struct nes_cm_core *g_cm_core;
+
+extern atomic_t cm_connects;
+extern atomic_t cm_accepts;
+extern atomic_t cm_disconnects;
+extern atomic_t cm_closes;
+extern atomic_t cm_connecteds;
+extern atomic_t cm_connect_reqs;
+extern atomic_t cm_rejects;
+extern atomic_t mod_qp_timouts;
+extern atomic_t qps_created;
+extern atomic_t qps_destroyed;
+extern atomic_t sw_qps_destroyed;
+extern u32 mh_detected;
+extern u32 mh_pauses_sent;
+extern u32 cm_packets_sent;
+extern u32 cm_packets_bounced;
+extern u32 cm_packets_created;
+extern u32 cm_packets_received;
+extern u32 cm_packets_dropped;
+extern u32 cm_packets_retrans;
+extern u32 cm_listens_created;
+extern u32 cm_listens_destroyed;
+extern u32 cm_backlog_drops;
+extern atomic_t cm_nodes_created;
+extern atomic_t cm_nodes_destroyed;
+extern atomic_t cm_accel_dropped_pkts;
+extern atomic_t cm_resets_recvd;
+
+extern u32 crit_err_count;
+extern u32 mh_detected;
+extern u32 mh_pauses_sent;
+
+extern atomic_t cqp_reqs_allocated;
+extern atomic_t cqp_reqs_freed;
+extern atomic_t cqp_reqs_dynallocated;
+extern atomic_t cqp_reqs_dynfreed;
+extern atomic_t cqp_reqs_queued;
+extern atomic_t cqp_reqs_redriven;
+
+
+struct nes_device {
+	struct nes_adapter *nesadapter;
+	void __iomem *regs;
+	void __iomem *index_reg;
+	struct pci_dev *pcidev;
+	struct net_device *netdev[NES_NIC_MAX_NICS];
+	u64 link_status_interrupts;
+	struct tasklet_struct dpc_tasklet;
+	spinlock_t indexed_regs_lock;
+	unsigned long doorbell_start;
+	unsigned long csr_start;
+	unsigned long mac_tx_errors;
+	unsigned long mac_pause_frames_sent;
+	unsigned long mac_pause_frames_received;
+	unsigned long mac_rx_errors;
+	unsigned long mac_rx_crc_errors;
+	unsigned long mac_rx_symbol_err_frames;
+	unsigned long mac_rx_jabber_frames;
+	unsigned long mac_rx_oversized_frames;
+	unsigned long mac_rx_short_frames;
+	unsigned int mac_index;
+	unsigned int nes_stack_start;
+
+	/* Control Structures */
+	void *cqp_vbase;
+	dma_addr_t cqp_pbase;
+	u32 cqp_mem_size;
+	u8 ceq_index;
+	u8 nic_ceq_index;
+	struct nes_hw_cqp cqp;
+	struct nes_hw_cq ccq;
+	struct list_head cqp_avail_reqs;
+	struct list_head cqp_pending_reqs;
+	struct nes_cqp_request *nes_cqp_requests;
+
+	u32 int_req;
+	u32 int_stat;
+	u32 timer_int_req;
+	u32 timer_only_int_count;
+	u32 intf_int_req;
+	u32 et_rx_coalesce_usecs_irq;
+	u32 last_mac_tx_pauses;
+	u32 last_used_chunks_tx;
+	struct list_head list;
+
+	u16 base_doorbell_index;
+	u8 msi_enabled;
+	u8 netdev_count;
+	u8 napi_isr_ran;
+	u8 disable_rx_flow_control;
+	u8 disable_tx_flow_control;
+};
+
+
+static inline int nes_skb_is_gso(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_size;
+}
+
+#define nes_skb_linearize(_skb)  skb_linearize(_skb)
+
+
+/* Read from memory-mapped device */
+static inline u32 nes_read_indexed(struct nes_device *nesdev, u32 reg_index)
+{
+	unsigned long flags;
+	void __iomem *addr = nesdev->index_reg;
+	u32 value;
+
+	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
+
+	writel(reg_index, addr);
+	value = readl((void __iomem *)addr + 4);
+
+	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
+	return value;
+}
+
+static inline u32 nes_read32(const void __iomem* addr)
+{
+	return readl(addr);
+}
+
+static inline u16 nes_read16(const void __iomem* addr)
+{
+	return readw(addr);
+}
+
+static inline u8 nes_read8(const void __iomem* addr)
+{
+	return readb(addr);
+}
+
+/* Write to memory-mapped device */
+static inline void nes_write_indexed(struct nes_device *nesdev, u32 reg_index, u32 val)
+{
+	unsigned long flags;
+	void __iomem *addr = nesdev->index_reg;
+
+	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
+
+	writel(reg_index, addr);
+	writel(val, (void __iomem *)addr + 4);
+
+	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
+}
+
+static inline void nes_write32(void __iomem *addr, u32 val)
+{
+	writel(val, addr);
+}
+
+static inline void nes_write16(void __iomem *addr, u16 val)
+{
+	writew(val, addr);
+}
+
+static inline void nes_write8(void __iomem *addr, u8 val)
+{
+	writeb(val, addr);
+}
+
+
+
+static inline int nes_alloc_resource(struct nes_adapter *nesadapter,
+		unsigned long *resource_array, u32 max_resources,
+		u32 *req_resource_num, u32 *next)
+{
+	unsigned long flags;
+	u32 resource_num;
+
+	spin_lock_irqsave(&nesadapter->resource_lock, flags);
+
+	resource_num = find_next_zero_bit(resource_array, max_resources, *next);
+	if (resource_num >= max_resources) {
+		resource_num = find_first_zero_bit(resource_array, max_resources);
+		if (resource_num >= max_resources) {
+			printk(KERN_ERR PFX "%s: No available resourcess.\n", __FUNCTION__);
+			spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+			return -EMFILE;
+		}
+	}
+	nes_debug(NES_DBG_HW, "find_next_zero_bit returned = %u (max = %u).\n",
+			resource_num, max_resources);
+	set_bit(resource_num, resource_array);
+	*next = resource_num+1;
+	if (*next == max_resources) {
+		*next = 0;
+	}
+	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+	*req_resource_num = resource_num;
+
+	return 0;
+}
+
+static inline int nes_is_resource_allocated(struct nes_adapter *nesadapter,
+		unsigned long *resource_array, u32 resource_num)
+{
+	unsigned long flags;
+	int bit_is_set;
+
+	spin_lock_irqsave(&nesadapter->resource_lock, flags);
+
+	bit_is_set = test_bit(resource_num, resource_array);
+	nes_debug(NES_DBG_HW, "resource_num %u is%s allocated.\n",
+			resource_num, (bit_is_set ? "": " not"));
+	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+
+	return bit_is_set;
+}
+
+static inline void nes_free_resource(struct nes_adapter *nesadapter,
+		unsigned long *resource_array, u32 resource_num)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nesadapter->resource_lock, flags);
+	clear_bit(resource_num, resource_array);
+	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+}
+
+static inline struct nes_vnic *to_nesvnic(struct ib_device *ibdev) {
+	return(container_of(ibdev, struct nes_ib_device, ibdev)->nesvnic);
+}
+
+static inline struct nes_pd *to_nespd(struct ib_pd *ibpd) {
+	return(container_of(ibpd, struct nes_pd, ibpd));
+}
+
+static inline struct nes_ucontext *to_nesucontext(struct ib_ucontext *ibucontext) {
+	return(container_of(ibucontext, struct nes_ucontext, ibucontext));
+}
+
+static inline struct nes_mr *to_nesmr(struct ib_mr *ibmr) {
+	return(container_of(ibmr, struct nes_mr, ibmr));
+}
+
+static inline struct nes_mr *to_nesmr_from_ibfmr(struct ib_fmr *ibfmr) {
+	return(container_of(ibfmr, struct nes_mr, ibfmr));
+}
+
+static inline struct nes_mr *to_nesmw(struct ib_mw *ibmw) {
+	return(container_of(ibmw, struct nes_mr, ibmw));
+}
+
+static inline struct nes_fmr *to_nesfmr(struct nes_mr *nesmr) {
+	return(container_of(nesmr, struct nes_fmr, nesmr));
+}
+
+static inline struct nes_cq *to_nescq(struct ib_cq *ibcq) {
+	return(container_of(ibcq, struct nes_cq, ibcq));
+}
+
+static inline struct nes_qp *to_nesqp(struct ib_qp *ibqp) {
+	return(container_of(ibqp, struct nes_qp, ibqp));
+}
+
+
+#define NES_CQP_REQUEST_NOT_HOLDING_LOCK 0
+#define NES_CQP_REQUEST_HOLDING_LOCK 1
+#define NES_CQP_REQUEST_NO_DOORBELL_RING 0
+#define NES_CQP_REQUEST_RING_DOORBELL 1
+
+static inline struct nes_cqp_request
+		*nes_get_cqp_request(struct nes_device *nesdev, int holding_lock) {
+	unsigned long flags;
+	struct nes_cqp_request *cqp_request = NULL;
+
+	if (!holding_lock) {
+		spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	}
+	if (!list_empty(&nesdev->cqp_avail_reqs)) {
+		cqp_request = list_entry(nesdev->cqp_avail_reqs.next,
+				struct nes_cqp_request, list);
+		atomic_inc(&cqp_reqs_allocated);
+		list_del_init(&cqp_request->list);
+	} else if (!holding_lock) {
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+		cqp_request = kzalloc(sizeof(struct nes_cqp_request),
+							  GFP_KERNEL);
+		if (cqp_request) {
+			cqp_request->dynamic = 1;
+			INIT_LIST_HEAD(&cqp_request->list);
+			atomic_inc(&cqp_reqs_dynallocated);
+		}
+		spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	}
+	if (!holding_lock) {
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	}
+
+	if (cqp_request) {
+		init_waitqueue_head(&cqp_request->waitq);
+		cqp_request->waiting = 0;
+		cqp_request->request_done = 0;
+		init_waitqueue_head(&cqp_request->waitq);
+		nes_debug(NES_DBG_CQP, "Got cqp request %p from the available list \n",
+				cqp_request);
+	} else
+		printk(KERN_ERR PFX "%s: Could not allocated a CQP request.\n",
+			   __FUNCTION__);
+
+	return cqp_request;
+}
+
+static inline void nes_post_cqp_request(struct nes_device *nesdev,
+		struct nes_cqp_request *cqp_request, int holding_lock, int ring_doorbell)
+{
+	/* caller must be holding CQP lock */
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	unsigned long flags;
+	u32 cqp_head;
+
+	if (!holding_lock) {
+		spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	}
+
+	if (((((nesdev->cqp.sq_tail+(nesdev->cqp.sq_size*2))-nesdev->cqp.sq_head) &
+			(nesdev->cqp.sq_size - 1)) != 1)
+			&& (list_empty(&nesdev->cqp_pending_reqs))) {
+		cqp_head = nesdev->cqp.sq_head++;
+		nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
+		cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+		memcpy(cqp_wqe, &cqp_request->cqp_wqe, sizeof(*cqp_wqe));
+		barrier();
+		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = cpu_to_le32((u32)((u64)(cqp_request)));
+		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = cpu_to_le32((u32)(((u64)(cqp_request))>>32));
+		nes_debug(NES_DBG_CQP, "CQP request (opcode 0x%02X), line 1 = 0x%08X put on CQPs SQ,"
+				" request = %p, cqp_head = %u, cqp_tail = %u, cqp_size = %u,"
+				" waiting = %d, refcount = %d.\n",
+				le32_to_cpu(cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX])&0x3f,
+				le32_to_cpu(cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX]), cqp_request,
+				nesdev->cqp.sq_head, nesdev->cqp.sq_tail, nesdev->cqp.sq_size,
+				cqp_request->waiting, atomic_read(&cqp_request->refcount));
+		barrier();
+		if (ring_doorbell) {
+			/* Ring doorbell (1 WQEs) */
+			nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 | nesdev->cqp.qp_id);
+		}
+
+		barrier();
+	} else {
+		atomic_inc(&cqp_reqs_queued);
+		nes_debug(NES_DBG_CQP, "CQP request %p (opcode 0x%02X), line 1 = 0x%08X"
+				" put on the pending queue.\n",
+				cqp_request,
+				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_OPCODE_IDX]&0x3f,
+				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_ID_IDX]);
+		list_add_tail(&cqp_request->list, &nesdev->cqp_pending_reqs);
+	}
+
+	if (!holding_lock) {
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	}
+
+	return;
+}
+
+
+/* Utils */
+#define CRC32C_POLY     0x1EDC6F41
+#define ORDER           32
+#define REFIN           1
+#define REFOUT          1
+#define NES_HASH_CRC_INITAL_VALUE 0xFFFFFFFF
+#define NES_HASH_CRC_FINAL_XOR    0xFFFFFFFF
+
+/* nes.c */
+void nes_add_ref(struct ib_qp *);
+void nes_rem_ref(struct ib_qp *);
+struct ib_qp *nes_get_qp(struct ib_device *, int);
+
+/* nes_hw.c */
+struct nes_adapter *nes_init_adapter(struct nes_device *, u8);
+unsigned int nes_reset_adapter_ne020(struct nes_device *, u8 *);
+int nes_init_serdes(struct nes_device *, u8, u8, u8);
+void nes_init_csr_ne020(struct nes_device *, u8, u8);
+void nes_destroy_adapter(struct nes_adapter *);
+int nes_init_cqp(struct nes_device *);
+int nes_init_phy(struct nes_device *);
+int nes_init_nic_qp(struct nes_device *, struct net_device *);
+void nes_destroy_nic_qp(struct nes_vnic *);
+int nes_napi_isr(struct nes_device *);
+void nes_dpc(unsigned long);
+void nes_process_ceq(struct nes_device *, struct nes_hw_ceq *);
+void nes_process_aeq(struct nes_device *, struct nes_hw_aeq *);
+void nes_process_mac_intr(struct nes_device *, u32);
+void nes_nic_napi_ce_handler(struct nes_device *, struct nes_hw_nic_cq *);
+void nes_nic_ce_handler(struct nes_device *, struct nes_hw_nic_cq *);
+void nes_cqp_ce_handler(struct nes_device *, struct nes_hw_cq *);
+void nes_process_iwarp_aeqe(struct nes_device *, struct nes_hw_aeqe *);
+void nes_iwarp_ce_handler(struct nes_device *, struct nes_hw_cq *);
+int nes_destroy_cqp(struct nes_device *);
+int nes_nic_cm_xmit(struct sk_buff *, struct net_device *);
+
+/* nes_nic.c */
+void nes_netdev_exit(struct nes_vnic *);
+struct net_device *nes_netdev_init(struct nes_device *, void __iomem *);
+void nes_netdev_destroy(struct net_device *);
+int nes_nic_cm_xmit(struct sk_buff *, struct net_device *);
+
+/* nes_cm.c */
+void *nes_cm_create(struct net_device *);
+int nes_cm_recv(struct sk_buff *, struct net_device *);
+void nes_update_arp(unsigned char *, u32, u32, u16, u16);
+void nes_manage_arp_cache(struct net_device *, unsigned char *, u32, u32);
+void nes_sock_release(struct nes_qp *, unsigned long *);
+struct nes_cm_core *nes_cm_alloc_core(void);
+void nes_disconnect_worker(void *);
+void flush_wqes(struct nes_device *nesdev, struct nes_qp *, u32, u32);
+int nes_manage_apbvt(struct nes_vnic *, u32, u32, u32);
+
+int nes_cm_disconn(struct nes_qp *);
+void nes_cm_disconn_worker(void *);
+
+/* nes_verbs.c */
+int nes_hw_modify_qp(struct nes_device *, struct nes_qp *, u32, u32);
+int nes_modify_qp(struct ib_qp *, struct ib_qp_attr *, int, struct ib_udata *);
+struct nes_ib_device *nes_init_ofa_device(struct net_device *);
+void nes_destroy_ofa_device(struct nes_ib_device *);
+int nes_register_ofa_device(struct nes_ib_device *);
+void nes_unregister_ofa_device(struct nes_ib_device *);
+
+/* nes_util.c */
+int nes_read_eeprom_values(struct nes_device *, struct nes_adapter *);
+void nes_write_1G_phy_reg(struct nes_device *, u8, u8, u16);
+void nes_read_1G_phy_reg(struct nes_device *, u8, u8, u16 *);
+void nes_write_10G_phy_reg(struct nes_device *, u16, u8, u16);
+void nes_read_10G_phy_reg(struct nes_device *, u16, u8);
+int nes_arp_table(struct nes_device *, u32, u8 *, u32);
+void nes_mh_fix(unsigned long);
+void nes_dump_mem(unsigned int, void *, int);
+u32 nes_crc32(u32, u32, u32, u32, u8 *, u32, u32, u32);
+
+#endif	/* __NES_H */
