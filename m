From: ggrundstrom@neteffect.com
Subject: [PATCH 2/14] nes: device structures and defines
Date: Tue, 7 Aug 2007 19:45:14 -0500
Message-ID: <200708080045.l780jE9E004667@neteffect.com>
Cc: ewg@lists.openfabrics.org, ggrundstrom@neteffect.com,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75.neteffect.com ([204.57.75.75]:49969 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759229AbXHHAvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 20:51:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Main include file for device structures and defines

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/nes.h
--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.2/drivers/infiniband/hw/nes/nes.h	2007-08-06 20:09:04.000000000 -0500
@@ -0,0 +1,525 @@
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
+
+#include <rdma/ib_smi.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_pack.h>
+#include <rdma/rdma_cm.h>
+#include <rdma/iw_cm.h>
+
+#define TBIRD
+#define NES_TWO_PORT
+#define NES_LEGACY_INT_DETECT
+#define NES_ENABLE_CQE_READ
+#define NES_SEND_FIRST_WRITE
+
+#define QUEUE_DISCONNECTS
+
+#define DRV_BUILD "rc9.13.1"
+
+#define DRV_NAME    "iw_nes"
+#define DRV_VERSION	"0.4 Build " DRV_BUILD
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
+/* debug levels */
+#define NES_DBG_RX			0x00000001
+#define NES_DBG_RX_PKT_DUMP	0x00000002
+#define NES_DBG_TX			0x00000004
+#define NES_DBG_TX_PKT_DUMP	0x00000008
+#define NES_DBG_ALL			0xffffffff
+
+#define NES_DRV_OPT_ENABLE_MPA_VER_0	0x00000001
+#define NES_DRV_OPT_DISABLE_MPA_CRC		0x00000002
+#define NES_DRV_OPT_DISABLE_FIRST_WRITE	0x00000004
+#define NES_DRV_OPT_DISABLE_INTF		0x00000008
+#define NES_DRV_OPT_ENABLE_MSI			0x00000010
+#define NES_DRV_OPT_DUAL_LOGICAL_PORT	0x00000020
+#define NES_DRV_OPT_SUPRESS_OPTION_BC	0x00000040
+
+#define NES_AEQ_EVENT_TIMEOUT 2500
+#define NES_DISCONNECT_EVENT_TIMEOUT 2000
+
+#ifdef NES_DEBUG
+#define assert(expr)												\
+if(!(expr)) {														\
+	printk(KERN_ERR PFX "Assertion failed! %s, %s, %s, line %d\n",	\
+		   #expr, __FILE__, __FUNCTION__, __LINE__);				\
+}
+#ifndef dprintk
+#define dprintk(fmt, args...) do { printk(KERN_ERR PFX fmt, ##args); } while (0)
+#endif
+#define NES_EVENT_TIMEOUT	1200000
+/* #define NES_EVENT_TIMEOUT	1200 */
+#else
+#define assert(expr)          do {} while (0)
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
+
+extern unsigned int nes_drv_opt;
+extern unsigned int nes_debug_level;
+
+extern struct list_head nes_adapter_list;
+extern struct list_head nes_dev_list;
+
+extern int max_mtu;
+#define max_frame_len (max_mtu+ETH_HLEN)
+extern int interrupt_mod_interval;
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
+/* Linux kernel version interface changes */
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18))
+static inline unsigned short nes_skb_lso_size(const struct sk_buff *skb)
+{
+	return(skb_shinfo(skb)->tso_size);
+}
+#define nes_skb_linearize(_skb, _type)  skb_linearize(_skb, _type)
+#define NES_INIT_WORK(_work, _func, _data)  INIT_WORK(_work, _func)
+#else
+static inline unsigned short nes_skb_lso_size(const struct sk_buff *skb)
+{
+	return(skb_shinfo(skb)->gso_size);
+}
+#define nes_skb_linearize(_skb, _type)  skb_linearize(_skb)
+#define NES_INIT_WORK(_work, _func, _data)  INIT_WORK(_work, _func)
+#endif
+
+/* Read from memory-mapped device */
+static inline u32 nes_read_indexed(struct nes_device *nesdev, u32 reg_index)
+{
+	unsigned long flags;
+	void __iomem * addr = nesdev->index_reg;
+	u32 value;
+
+	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
+
+	/* dprintk("Reading from indexed offset %08X using address %p and %p.\n",
+			reg_index, addr, addr+4); */
+	writel(cpu_to_le32(reg_index), addr);
+	value = le32_to_cpu(readl((u8 *)addr + 4));
+
+	/* dprintk("Got %08X.\n", value); */
+	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
+	return (value);
+}
+
+static inline u32 nes_read32(const void __iomem * addr)
+{
+	return(le32_to_cpu(readl(addr)));
+}
+
+static inline u16 nes_read16(const void __iomem * addr)
+{
+	return(le16_to_cpu(readw(addr)));
+}
+
+static inline u8 nes_read8(const void __iomem * addr)
+{
+	return(readb(addr));
+}
+
+/* Write to memory-mapped device */
+static inline void nes_write_indexed(struct nes_device *nesdev, u32 reg_index, u32 val)
+{
+	unsigned long flags;
+	void __iomem * addr = nesdev->index_reg;
+
+	spin_lock_irqsave(&nesdev->indexed_regs_lock, flags);
+
+	/* dprintk("Writing %08X, to indexed offset %08X using address %p and %p.\n",
+			val, reg_index, addr, addr+4); */
+	writel(cpu_to_le32(reg_index), addr);
+	writel(cpu_to_le32(val),(u8 *)addr + 4);
+
+	spin_unlock_irqrestore(&nesdev->indexed_regs_lock, flags);
+}
+
+static inline void nes_write32(void __iomem * addr, u32 val)
+{
+	/* dprintk("Writing %08X, to address %p.\n", val, addr); */
+	writel(cpu_to_le32(val), addr);
+}
+
+static inline void nes_write16(void __iomem * addr, u16 val)
+{
+	writew(cpu_to_le16(val), addr);
+}
+
+static inline void nes_write8(void __iomem * addr, u8 val)
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
+	dprintk("nes_alloc_resource: resource_array=%p, max_resources=%u,"
+			" req_resource=%u, next=%u\n",
+			resource_array, max_resources, *req_resource_num, *next);
+
+	resource_num = find_next_zero_bit(resource_array, max_resources, *next);
+	dprintk("nes_alloc_resource: resource_num=%u\n", resource_num);
+	if (resource_num >= max_resources) {
+		resource_num = find_first_zero_bit(resource_array, max_resources);
+		if (resource_num >= max_resources) {
+			printk(KERN_ERR PFX "%s: No available resourcess.\n", __FUNCTION__);
+			spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+			return(-EMFILE);
+		}
+	}
+	dprintk("%s: find_next_zero_bit returned = %u (max = %u).\n",
+			__FUNCTION__, resource_num, max_resources);
+	set_bit(resource_num, resource_array);
+	*next = resource_num+1;
+	if (*next == max_resources) {
+		*next = 0;
+	}
+	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+	*req_resource_num = resource_num;
+	return (0);
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
+	return (container_of(ibdev, struct nes_ib_device, ibdev)->nesvnic);
+}
+
+static inline struct nes_pd *to_nespd(struct ib_pd *ibpd) {
+	return (container_of(ibpd, struct nes_pd, ibpd));
+}
+
+static inline struct nes_ucontext *to_nesucontext(struct ib_ucontext *ibucontext) {
+	return (container_of(ibucontext, struct nes_ucontext, ibucontext));
+}
+
+static inline struct nes_mr *to_nesmr(struct ib_mr *ibmr) {
+	return (container_of(ibmr, struct nes_mr, ibmr));
+}
+
+static inline struct nes_mr *to_nesmw(struct ib_mw *ibmw) {
+	return (container_of(ibmw, struct nes_mr, ibmw));
+}
+
+static inline struct nes_mr *to_nesfmr(struct ib_fmr *ibfmr) {
+	return (container_of(ibfmr, struct nes_mr, ibfmr));
+}
+
+static inline struct nes_cq *to_nescq(struct ib_cq *ibcq) {
+	return (container_of(ibcq, struct nes_cq, ibcq));
+}
+
+static inline struct nes_qp *to_nesqp(struct ib_qp *ibqp) {
+	return (container_of(ibqp, struct nes_qp, ibqp));
+}
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
+unsigned int nes_reset_adapter_ne010(struct nes_device *, u8 *);
+unsigned int nes_reset_adapter_ne020(struct nes_device *, u8 *);
+int nes_init_serdes(struct nes_device *, u8 port_count);
+void nes_init_csr_ne010(struct nes_device *, u8 hw_rev);
+void nes_init_csr_ne020(struct nes_device *, u8 hw_rev, u8 port_count);
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
+struct net_device *nes_netdev_init(struct nes_device *, void __iomem *);
+void nes_netdev_destroy(struct net_device *);
+void nes_destroy_adapter(struct nes_adapter *);
+
+/* nes_cm.c */
+void *nes_cm_create(struct net_device *netdev);
+int nes_cm_recv(struct sk_buff *skb_p, struct net_device *netdevice);
+void nes_update_arp(unsigned char *, u32, u32, u16, u16);
+void nes_manage_arp_cache(struct net_device *, unsigned char *, u32, u32);
+void nes_sock_release(struct nes_qp *, unsigned long *);
+void nes_disconnect_worker(void *);
+void flush_wqes(struct nes_device *nesdev, struct nes_qp *nesqp, u32 which_wq, u32 wait_completion);
+int nes_manage_apbvt(struct nes_vnic *nesvnic, u32 accel_local_port,
+		u32 nic_index, u32 add_port);
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
+void nes_dump_mem(void *, int);
+u32 nes_crc32(u32, u32, u32, u32, u8 *, u32, u32, u32);
+
+extern int nes_if_count;
+extern int mpa_version;
+extern unsigned int send_first;
+
+
+#define NES_CQP_REQUEST_NOT_HOLDING_LOCK 0
+#define NES_CQP_REQUEST_HOLDING_LOCK 1
+#define NES_CQP_REQUEST_NO_DOORBELL_RING 0
+#define NES_CQP_REQUEST_RING_DOORBELL 1
+
+static inline struct nes_cqp_request
+		*nes_get_cqp_request(struct nes_device *nesdev, int holding_lock)
+{
+	unsigned long flags;
+	struct nes_cqp_request *cqp_request = NULL;
+
+	if (!holding_lock) {
+		spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	}
+	if (!list_empty(&nesdev->cqp_avail_reqs)) {
+		cqp_request = list_entry(nesdev->cqp_avail_reqs.next,
+				struct nes_cqp_request, list);
+		list_del_init(&cqp_request->list);
+	}
+	if (!holding_lock) {
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	}
+
+	if (cqp_request) {
+		cqp_request->waiting = 0;
+		cqp_request->request_done = 0;
+		init_waitqueue_head(&cqp_request->waitq);
+		/* dprintk("%s: Got cqp request %p from the available list \n",
+				__FUNCTION__, cqp_request); */
+	} else
+		dprintk("%s: CQP request queue is empty.\n", __FUNCTION__);
+
+	return (cqp_request);
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
+		*((struct nes_cqp_request **)&cqp_wqe->wqe_words
+				[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX]) = cqp_request;
+		dprintk("%s: CQP request (opcode 0x%02X), line 1 = 0x%08X put on CQPs SQ,"
+				" request = %p, cqp_head = %u, cqp_tail = %u, cqp_size = %u,"
+				" waiting = %d, refcount = %d.\n",
+				__FUNCTION__, cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]&0x3f,
+				cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX], cqp_request,
+				nesdev->cqp.sq_head, nesdev->cqp.sq_tail, nesdev->cqp.sq_size,
+				cqp_request->waiting, atomic_read(&cqp_request->refcount));
+	} else {
+		dprintk("%s: CQP request %p (opcode 0x%02X), line 1 = 0x%08X"
+				" put on the pending queue.\n",
+				__FUNCTION__, cqp_request,
+				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_OPCODE_IDX]&0x3f,
+				cqp_request->cqp_wqe.wqe_words[NES_CQP_WQE_ID_IDX]);
+		list_add_tail(&cqp_request->list, &nesdev->cqp_pending_reqs);
+	}
+
+	if (ring_doorbell) {
+		barrier();
+		/* Ring doorbell (1 WQEs) */
+		nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 | nesdev->cqp.qp_id);
+	}
+
+	if (!holding_lock) {
+		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	}
+
+	return;
+}
+
+#endif	/* __NES_H */
