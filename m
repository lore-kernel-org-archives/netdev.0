From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 5/9] NetEffect 10Gb RNIC Driver: hardware interface c file
Date: Thu, 26 Oct 2006 19:09:39 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBC@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:29150 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946043AbWJ0AJl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:09:41 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 5 of 9.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/hw/nes/nes_hw.c
new/drivers/infiniband/hw/nes/nes_hw.c
--- old/drivers/infiniband/hw/nes/nes_hw.c	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_hw.c	2006-10-25
10:15:50.000000000 -0500
@@ -0,0 +1,1470 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
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
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+
+#include "nes.h"
+
+
+#if defined(SA1)
+struct nes_init_values init_values[] = 
+{
+	{0x00000600,0x55555555}, 
+	{0x00000604,0x55555555}, 
+	{0x00002000,0x00000001}, 
+	{0x00002004,0x00000001}, 
+	{0x00002008,0x0000FFFF}, 
+	{0x0000200C,0x00000001}, 
+	{0x00002010,0x00000241}, 
+	{0x0000201C,0x75345678}, 
+	{0x00005100,0x00000008}, 
+	{0x00006000,0x000000e0}, 
+	{0x00006008,0x000000e0}, 
+//	{0x00006018,0x00000001}, 
+//	{0x00006028,0x00000001}, 
+	{0x00006038,0x00000003}, 
+	{0x000060B8,0x00000002}, 
+	{0x00006090,0xFFFFFFFF}, 
+	{0x00000900,0x20000001}, 
+//	{0x000001E8,0x000208c2}, 
+	{0x000001E8,0x000208c4}, 
+	{0x000001EC,0x5f1e8480}, 
+	{0x000001FC,0x00050005}, 
+	{0x00000B00,0x00001000}, 
+	{0x000010C8,0x00000003}, 
+	{0x00005008,0x1F1F1F1F}, 
+	{0x00005010,0x1F1F1F1F}, 
+	{0x00005018,0x1F1F1F1F}, 
+	{0x00005020,0x1F1F1F1F}, 
+//	{0x000060B8,0x00000001}, 
+	{0x000060C0,0x00000194}, 
+	{0x000060C8,0x00000020}, 
+	{0x00000000,0x00000000}	 
+};
+#endif
+
+
+/**
+ * nes_adapter_init - initialize adapter
+ *
+ * @param nesdev
+ * @param num_pds
+ * 
+ * @return struct nes_adapter*
+ */
+struct nes_adapter *nes_adapter_init(struct nes_dev *nesdev, unsigned
long num_pds) {
+	struct nes_adapter *nesadapter = NULL;
+	int i=0;
+	int found = 0;
+	u32 u32temp;
+	u16 max_rq_wrs;
+	u16 max_sq_wrs;
+	u32 max_mr;
+	u32 max_256pbl;
+	u32 max_4kpbl;
+	u32 max_qp;
+	u32 max_irrq;
+	u32 max_cq;
+	u32 hte_index_mask;
+	u32 adapter_size;
+	u32 arp_table_size;
+
+	/* search the list of existing adapters */
+	list_for_each_entry(nesadapter, &nes_adapter_list, list) {
+		dprintk("Searching Adapter list for PCI devfn =
0x%X.\n", nesdev->pcidev->devfn);
+		if ((PCI_SLOT(nesadapter->devfn) ==
PCI_SLOT(nesdev->pcidev->devfn)) && 
+			(nesadapter->bus_number ==
nesdev->pcidev->bus->number)) {
+			found = 1;           
+			break;
+		}
+	}
+
+	if (!found) {
+		if (nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_QP_CONTROL+PCI_FUNC(nesdev->pcidev->devfn)*8)) {
+			nes_write32(nesdev->regs+NES_SOFTWARE_RESET,
0xd);
+		}
+		/* enable the ports */
+		nes_write32(nesdev->regs+NES_SOFTWARE_RESET, 0);
+
+		u32temp = 0;
+		while ( nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_INT_CPU_STATUS) != 0x80 ) {
+			if (u32temp++ > 10000) break;
+			mdelay(1);
+		}
+
+		if (nes_read_indexed(nesdev->index_reg,
NES_IDX_INT_CPU_STATUS) != 0x80) {
+			printk(KERN_ERR PFX "Internal CPU not ready,
status = %02X\n",
+
nes_read_indexed(nesdev->index_reg, NES_IDX_INT_CPU_STATUS) );
+			return NULL;
+		}
+
+		while ( init_values[i].index != 0 ) {
+			nes_write_indexed(nesdev->index_reg, 
+
init_values[i].index, init_values[i].data);
+			i++;
+		}
+
+		nes_write_indexed(nesdev->index_reg,
NES_IDX_GPIO_CONTROL, 0x00000070);
+		nes_write_indexed(nesdev->index_reg, NES_IDX_GPIO_DATA,
0);
+
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_TCP_TIMER_SIZE0);
+		u32temp &= 0xf0f0f0f0;
+		u32temp |= 0x05050105; 
+		u32temp &= 0xffffff0f;
+		u32temp |= 0x00000090; 
+		nes_write_indexed(nesdev->index_reg,
NES_IDX_TCP_TIMER_SIZE0, u32temp);
+
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_TCP_TIMER_SIZE1);
+		u32temp &= 0x0000f0f0;
+		u32temp |= 0x00000505; 
+		u32temp &= 0xffff0f0f;
+		u32temp |= 0x00009090; 
+		nes_write_indexed(nesdev->index_reg,
NES_IDX_TCP_TIMER_SIZE1, u32temp);
+
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_TCP_CONFIG0);
+		u32temp |= 0x00000001;
+		nes_write_indexed(nesdev->index_reg,
NES_IDX_TCP_CONFIG0, u32temp);
+
+		nes_write_indexed(nesdev->index_reg,
NES_IDX_DENALI_CTL_22, 0x00FF0000);
+
+		nesadapter->tick_delta = 2000;
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_TCP_TIMER_CONFIG);
+		nes_write_indexed(nesdev->index_reg,
NES_IDX_TCP_TIMER_CONFIG, 
+
(u32temp&0xff000000)|((nesadapter->tick_delta*1000)&0x00ffffff)); // set
to 10ms
+
+		max_qp = nes_read_indexed(nesdev->index_reg,
NES_IDX_QP_CTX_SIZE);
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_QUAD_HASH_TABLE_SIZE);
+		if (max_qp > ((u32)1 << (u32temp & 0x001f))) {
+			dprintk("Reducing Max QPs to %u due to hash
table size. ht size reg = 0x%08X\n", max_qp, u32temp );
+			max_qp = (u32)1 << (u32temp & 0x001f);
+		}
+
+		hte_index_mask = ((u32)1 << ((u32temp & 0x001f)+1))-1;
+		dprintk("Max QP = %u, hte_index_mask = 0x%08X.\n",
max_qp, hte_index_mask);
+
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_IRRQ_COUNT);
+
+		max_irrq = 1<<(u32temp&0x001f);
+
+		if (max_qp > max_irrq) {
+			max_qp = max_irrq;
+			dprintk("Reducing Max QPs to %u due to Available
Q1s.\n", max_qp);
+		}
+
+		/* there should be no reason to allocate more pds than
qps */
+		if (num_pds > max_qp)
+			num_pds = max_qp;
+
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_MRT_SIZE);
+		max_mr = (u32)8192 << (u32temp&0x3);
+
+		u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_PBL_REGION_SIZE);
+		max_256pbl = (u32)1 << (u32temp & 0x0000001f);
+		max_4kpbl = (u32)1 << ((u32temp>>16) & 0x0000001f);
+		max_cq = nes_read_indexed(nesdev->index_reg,
NES_IDX_CQ_CTX_SIZE);
+
+		arp_table_size = NES_ARP_TABLE_SIZE;
+		max_qp -= 5;
+		arp_table_size -= 5;
+
+		adapter_size = (sizeof(struct
nes_adapter)+(sizeof(unsigned long)-1))&(~(sizeof(unsigned long)-1)); 
+		adapter_size += sizeof(unsigned
long)*BITS_TO_LONGS(max_qp);
+		adapter_size += sizeof(unsigned
long)*BITS_TO_LONGS(max_mr);
+		adapter_size += sizeof(unsigned
long)*BITS_TO_LONGS(max_cq);
+		adapter_size += sizeof(unsigned
long)*BITS_TO_LONGS(num_pds);
+		adapter_size += sizeof(unsigned long) *
BITS_TO_LONGS(NES_ARP_TABLE_SIZE);
+		adapter_size += sizeof(struct nes_qp **)*max_qp;
+
+		nesadapter = kzalloc(adapter_size, GFP_KERNEL);
+		dprintk("Adapter not found, allocating new one @ %p,
size = %u (actual size = %u).\n", nesadapter, (u32)sizeof(struct
nes_adapter), adapter_size);
+		if (nesadapter){
+			nesadapter->devfn = nesdev->pcidev->devfn;
+			nesadapter->bus_number =
nesdev->pcidev->bus->number;
+			nesadapter->ref_count = 1;
+			
+			nesadapter->max_qp = max_qp;
+			nesadapter->hte_index_mask = hte_index_mask;
+			nesadapter->max_irrq = max_irrq;
+			nesadapter->max_mr = max_mr;
+			nesadapter->max_256pbl = max_256pbl - 1;
+			nesadapter->max_4kpbl = max_4kpbl - 1;
+			nesadapter->max_cq = max_cq;
+			nesadapter->free_256pbl = max_256pbl-1;
+			nesadapter->free_4kpbl = max_4kpbl-1;
+			nesadapter->max_pd = num_pds;
+			nesadapter->arp_table_size = arp_table_size;
+			nesadapter->base_pd = 1;
+
+			nesadapter->allocated_qps = (unsigned long
*)&(((unsigned char *)nesadapter)[(sizeof(struct
nes_adapter)+(sizeof(unsigned long)-1))&(~(sizeof(unsigned long)-1))]);
+			nesadapter->allocated_cqs =
&nesadapter->allocated_qps[BITS_TO_LONGS(max_qp)];
+			nesadapter->allocated_mrs =
&nesadapter->allocated_cqs[BITS_TO_LONGS(max_cq)];
+			nesadapter->allocated_pds =
&nesadapter->allocated_mrs[BITS_TO_LONGS(max_mr)];
+			nesadapter->allocated_arps =
&nesadapter->allocated_pds[BITS_TO_LONGS(num_pds)];
+			nesadapter->qp_table = (struct nes_qp
**)(&nesadapter->allocated_arps[BITS_TO_LONGS(NES_ARP_TABLE_SIZE)]);
+
+
+			/* mark the usual suspect QPs and CQs as in use
*/
+			for (u32temp=0; u32temp<NES_FIRST_QPN;
u32temp++) {
+				set_bit(u32temp,
nesadapter->allocated_qps);
+				set_bit(u32temp,
nesadapter->allocated_cqs);
+			}
+			
+			u32temp = nes_read_indexed(nesdev->index_reg,
NES_IDX_QP_MAX_CFG_SIZES);
+			
+			max_rq_wrs = ((u32temp>>8) & 3);
+			switch (max_rq_wrs) {
+				case 0:
+					max_rq_wrs = 4;
+					break;
+				case 1:
+					max_rq_wrs = 16;
+					break;
+				case 2:
+					max_rq_wrs = 32;
+					break;
+				case 3:
+					max_rq_wrs = 512;
+					break;
+			}
+			
+			max_sq_wrs = (u32temp & 3);
+			switch (max_sq_wrs) {
+				case 0:
+					max_sq_wrs = 4;
+					break;
+				case 1:
+					max_sq_wrs = 16;
+					break;
+				case 2:
+					max_sq_wrs = 32;
+					break;
+				case 3:
+					max_sq_wrs = 512;
+					break;
+			}
+			nesadapter->max_qp_wr = min(max_rq_wrs,
max_sq_wrs);
+			dprintk("Max wqes = %u.\n",
nesadapter->max_qp_wr );
+
+			/* Encoded */
+			nesadapter->max_irrq_wr = (u32temp >> 16) & 3;
+//			dprintk("%s: Max IRRQ wqes = %u.\n",
__FUNCTION__, nesadapter->max_irrq_wr );
+			
+			nesadapter->max_sge = 4;
+			nesadapter->max_cqe = 32767;
+
+			dprintk("%s:Initializing adapter resource lock
(%p).\n", 
+					__FUNCTION__,
&nesadapter->resource_lock );
+			spin_lock_init(&nesadapter->resource_lock);
+			
+			list_add_tail(&nesadapter->list,
&nes_adapter_list);
+			i = 0;
+			
+		}
+	}else 
+		nesadapter->ref_count++;
+
+	return nesadapter;
+}
+
+
+/**
+ * nes_cqp_init
+ * 
+ * @param nesdev
+ * 
+ * @return int
+ */
+int nes_cqp_init(struct nes_dev *nesdev)
+{
+	struct nes_port *nes_port = NULL;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct net_device *netdev = alloc_etherdev(sizeof(*nes_port));
+	struct nes_hw_cqp_qp_context *cqp_qp_context;
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_hw_ceq *ceq;
+	struct nes_hw_aeq *aeq;
+	void *mem;
+	char *lmi_buf;
+	dma_addr_t lmi_dma_handle;
+	u32 count=0;
+	u32 cqp_head;
+	u64 u64temp;
+
+	// Allocate Memory
+	nesdev->cqp_mem_size =  (sizeof(struct
nes_hw_cqp_wqe)*NES_CQP_SQ_SIZE) +	  /* needs 512 byte alignment */
+							(sizeof(struct
nes_hw_cqe)*NES_CCQ_SIZE) +			  /* needs 256 byte
alignment */
+							(sizeof(struct
nes_hw_ceqe)*nesadapter->max_cq) +	  /* needs 256 byte alignment */
+							(sizeof(struct
nes_hw_aeqe)*nesadapter->max_qp) +	  /* needs 256 byte alignment */
+							sizeof(struct
nes_hw_cqp_qp_context) +				  /* needs 8
byte alignment */
+							8192;
/* this is the masq table */
+
+	mem = pci_alloc_consistent(nesdev->pcidev, nesdev->cqp_mem_size,
+
&nesdev->cqp.sq_pbase);
+	if (!mem) {
+		dprintk(KERN_ERR PFX "Unable to allocate memory for "
+				"host descriptor rings\n");
+		free_netdev(netdev);
+		return ERR_PTR(-ENOMEM);
+	}
+	dprintk("Allocated CQP structures at %p (phys = %016lX), size =
%u.\n", mem, 
+			(unsigned long)nesdev->cqp.sq_pbase,
nesdev->cqp_mem_size);
+	if (((u64)((unsigned)mem))&(512-1)) {
+		dprintk("CQP SQ base (%p) not 512 byte aligned.\n",
mem);
+	}
+	memset(mem, 0, nesdev->cqp_mem_size);
+
+	nesdev->mac_index = PCI_FUNC(nesdev->pcidev->devfn);
+	spin_lock_init(&nesdev->cqp.lock);
+	init_waitqueue_head( &nesdev->cqp.waitq );
+
+	// Setup Various Structures
+	nesdev->cqp.sq_vbase = mem;
+	nesdev->cqp.sq_size = NES_CQP_SQ_SIZE;
+	nesdev->cqp.sq_head = 0;
+	nesdev->cqp.sq_tail = 0;
+	nesdev->cqp.qp_id = PCI_FUNC(nesdev->pcidev->devfn);
+	mem += sizeof(struct nes_hw_cqp_wqe)*nesdev->cqp.sq_size;
+
+	nesdev->ccq.cq_vbase = mem;
+	nesdev->ccq.cq_pbase = nesdev->cqp.sq_pbase + (sizeof(struct
nes_hw_cqp_wqe)*nesdev->cqp.sq_size);
+	nesdev->ccq.cq_size = NES_CCQ_SIZE;
+	nesdev->ccq.cq_head = 0;
+	nesdev->ccq.ce_handler = cqp_ce_handler;
+	nesdev->ccq.cq_number = PCI_FUNC(nesdev->pcidev->devfn);
+	mem += sizeof(struct nes_hw_cqe)*nesdev->ccq.cq_size;
+	dprintk("CCQ  at %p (phys = %016lX).\n", nesdev->ccq.cq_vbase,
(unsigned long)nesdev->ccq.cq_pbase);
+
+	ceq = &nesadapter->ceq[PCI_FUNC(nesdev->pcidev->devfn)];
+	ceq->ceq_vbase = mem;
+	ceq->ceq_pbase = nesdev->ccq.cq_pbase + (sizeof(struct
nes_hw_cqe)*nesdev->ccq.cq_size);
+	ceq->ceq_size = nesadapter->max_cq;
+	ceq->ceq_head = 0;
+	mem += sizeof(struct nes_hw_ceqe)*nesadapter->max_cq;
+	dprintk("CEQ  at %p (phys = %016lX).\n", ceq->ceq_vbase,
(unsigned long)ceq->ceq_pbase);
+
+	aeq = &nesadapter->aeq[PCI_FUNC(nesdev->pcidev->devfn)];
+	aeq->aeq_vbase = mem;
+	aeq->aeq_pbase = ceq->ceq_pbase + (sizeof(struct
nes_hw_ceqe)*nesadapter->max_cq);
+	aeq->aeq_size = nesadapter->max_qp;
+	aeq->aeq_head = 0;
+	mem += sizeof(struct nes_hw_aeqe)*nesadapter->max_qp;
+	dprintk("AEQ  at %p (phys = %016lX).\n", aeq->aeq_vbase,
(unsigned long)aeq->aeq_pbase);
+
+	// Setup QP Context
+	cqp_qp_context = mem;
+	cqp_qp_context->context_words[0] =
(PCI_FUNC(nesdev->pcidev->devfn)<<12) + (1<<10);
+	cqp_qp_context->context_words[1] = 0;
+	cqp_qp_context->context_words[2] = (u32)nesdev->cqp.sq_pbase;
+	cqp_qp_context->context_words[3] =
((u64)nesdev->cqp.sq_pbase)>>32;
+	mem += sizeof(struct nes_hw_cqp_qp_context);
+
+	nesdev->apbv_table = mem;
+	memset(nesdev->apbv_table, 0, sizeof(*nesdev->apbv_table));
+
+	dprintk("Address of CQP Context = %p.\n", cqp_qp_context);
+	for (count=0;count<4 ; count++ ) {
+		dprintk("CQP Context, Line %u = %08X.\n", count,
cqp_qp_context->context_words[count]); 
+	}
+
+	// Write the address to Create CQP
+	if ((sizeof(dma_addr_t) > 4)) {
+		nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_CREATE_CQP_HIGH+(PCI_FUNC(nesdev->pcidev->devfn)*8), 
+
((u64)aeq->aeq_pbase+(sizeof(struct nes_hw_aeqe)*aeq->aeq_size))>>32);
+	} else {
+		nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_CREATE_CQP_HIGH+(PCI_FUNC(nesdev->pcidev->devfn)*8), 0);
+	}
+	nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_CREATE_CQP_LOW+(PCI_FUNC(nesdev->pcidev->devfn)*8), 
+
(u32)(aeq->aeq_pbase+(sizeof(struct nes_hw_aeqe)*aeq->aeq_size)));
+
+	dprintk("Address of CQP SQ = %p.\n", nesdev->cqp.sq_vbase);
+
+	lmi_buf = pci_alloc_consistent(nesdev->pcidev, 1024,
&lmi_dma_handle);
+	if (lmi_buf == NULL) {
+		free_netdev(netdev);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	cqp_head = nesdev->cqp.sq_head++;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_LMI_ACCESS + 0x20000000);
+	cqp_wqe->wqe_words[NES_CQP_LMI_WQE_LMI_OFFSET_IDX] =  0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
0x01010101;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
0x02020202;
+	u64temp = (u64)lmi_dma_handle;
+	cqp_wqe->wqe_words[NES_CQP_LMI_WQE_FRAG_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_LMI_WQE_FRAG_HIGH_IDX] =
cpu_to_le32((u32)(u64temp >> 32));
+	cqp_wqe->wqe_words[NES_CQP_LMI_WQE_FRAG_LEN_IDX] =
cpu_to_le32(1024);
+
+	// Write Create CCQ WQE
+	cqp_head = nesdev->cqp.sq_head++;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_CQ | NES_CQP_CQ_CEQ_VALID | 
+
NES_CQP_CQ_CHK_OVERFLOW | (nesdev->ccq.cq_size<<16));
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(PCI_FUNC(nesdev->pcidev->devfn) || 
+
(PCI_FUNC(nesdev->pcidev->devfn)<<16));
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
0x03030303;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
0x04040404;
+	u64temp = (u64)nesdev->ccq.cq_pbase;
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX] =  0;
+	/* TODO: the following 2 lines likely have endian issues */
+	*((struct nes_hw_cq
**)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]) =
&nesdev->ccq;
+	*((u64 *)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX])
>>= 1;
+	dprintk("%s: CQ%u context = 0x%08X:0x%08X.\n", __FUNCTION__,
nesdev->ccq.cq_number, 
+		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX], 
+		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]);
+	
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] =  0;
+
+	// Write Create CEQ WQE
+	cqp_head = nesdev->cqp.sq_head++;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_CEQ + (PCI_FUNC(nesdev->pcidev->devfn)<<8));
+	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_ELEMENT_COUNT_IDX] =
cpu_to_le32(ceq->ceq_size);
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
0x05050505;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
0x06060606;
+	u64temp = (u64)ceq->ceq_pbase;
+	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_CEQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+
+	// Write Create AEQ WQE
+	cqp_head = nesdev->cqp.sq_head++;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_AEQ + (PCI_FUNC(nesdev->pcidev->devfn)<<8));
+	cqp_wqe->wqe_words[NES_CQP_AEQ_WQE_ELEMENT_COUNT_IDX] =
cpu_to_le32(aeq->aeq_size);
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
0x07070707;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
0x08080808;
+	u64temp = (u64)aeq->aeq_pbase;
+	cqp_wqe->wqe_words[NES_CQP_AEQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_AEQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+
+	// Poll until CCQP done
+	// TODO: Cleanup if CQP does not behave
+	count = 0;
+	do {
+		if (count++ > 1000)	break;
+		udelay(10);
+	} while ( !(nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_QP_CONTROL+
+
(PCI_FUNC(nesdev->pcidev->devfn)*8))&(1<<8)) );
+
+	dprintk("QP Status        = 0x%08X bytes\n", 
+			nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_QP_CONTROL+(PCI_FUNC(nesdev->pcidev->devfn)*8)));
+
+	// Ring doorbell (4 WQEs)
+	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x04800000 |
nesdev->cqp.qp_id );
+
+	/* wait for the CCQ, CEQ, and AEQ to get created */
+	count = 0;
+	do {
+		if (count++ > 1000)	break;
+		udelay(10);
+	} while ( ((nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_QP_CONTROL+
+
(PCI_FUNC(nesdev->pcidev->devfn)*8)) & (15<<8)) != (15<<8)) );
+
+	/* dump the QP status value */
+	dprintk("QP Status        = 0x%08X bytes\n", 
+			nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_QP_CONTROL+(PCI_FUNC(nesdev->pcidev->devfn)*8)));
+
+	pci_free_consistent(nesdev->pcidev, 1024, lmi_buf,
lmi_dma_handle);
+	/* bump head since create CCQ does not generate a completion */
+	nesdev->cqp.sq_tail++;
+	nesdev->cqp.sq_tail++;
+
+	return 0;
+}
+
+
+/**
+ * nes_phy_init
+ */
+int nes_phy_init(struct nes_dev *nesdev)
+{
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	u32 u32temp;
+	u32 counter;
+	u32 mac_index = nesdev->mac_index;
+	u16 phy_data;
+	u16 link_up = 0;
+
+
+	dprintk("10G PHY\n");
+
+	nes_write_indexed(nesdev->index_reg, 0x2004, 0x00000019);
+	udelay(30);				/* do we really need
this? */
+
+	nes_read_10G_phy_reg(nesdev->index_reg, 0,
nesadapter->phy_index[mac_index]);
+	phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL );
+	dprintk("Phy data from register 0 = 0x%X.\n", phy_data);
+
+	nes_read_10G_phy_reg(nesdev->index_reg, 1,
nesadapter->phy_index[mac_index]);
+	phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL );
+	dprintk("Phy data from register 1 = 0x%X.\n", phy_data);
+
+	// reset the phy
+	nes_write_10G_phy_reg(nesdev->index_reg, 0,
nesadapter->phy_index[mac_index], 0x8000);
+	for (counter = 0; counter < 100; counter++)
+	{
+		mdelay(1);
+		nes_read_10G_phy_reg(nesdev->index_reg, 0,
nesadapter->phy_index[mac_index]);
+		phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL );
+		dprintk("Phy data from register 0 after reset =
0x%X.\n", phy_data);
+
+		if (!(phy_data & 0x8000))
+		{
+			break;
+		}
+	}
+
+	// device identifier 1
+	nes_read_10G_phy_reg(nesdev->index_reg, 2,
nesadapter->phy_index[mac_index]);
+	phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL );
+	dprintk("Phy data from register 2 = 0x%X.\n", phy_data);
+
+	// device identifier 2
+	nes_read_10G_phy_reg(nesdev->index_reg, 3,
nesadapter->phy_index[mac_index]);
+	phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL );
+	dprintk("Phy data from register 3 = 0x%X.\n", phy_data);
+
+	// primary channel lanes (0-3) analog transmit configuration
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd021,
nesadapter->phy_index[mac_index], 0x160a);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd029,
nesadapter->phy_index[mac_index], 0x160a);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd031,
nesadapter->phy_index[mac_index], 0x160a);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd039,
nesadapter->phy_index[mac_index], 0x160a);
+
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd041,
nesadapter->phy_index[mac_index], 0x160a);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd049,
nesadapter->phy_index[mac_index], 0x160a);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd051,
nesadapter->phy_index[mac_index], 0x160a);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd059,
nesadapter->phy_index[mac_index], 0x160a);
+
+	// primary channel lanes (0-3) analog receive configuration
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd025,
nesadapter->phy_index[mac_index], 0x8201);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd02d,
nesadapter->phy_index[mac_index], 0x8201);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd035,
nesadapter->phy_index[mac_index], 0x8201);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd03d,
nesadapter->phy_index[mac_index], 0x8201);
+
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd045,
nesadapter->phy_index[mac_index], 0x8201);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd04d,
nesadapter->phy_index[mac_index], 0x8201);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd055,
nesadapter->phy_index[mac_index], 0x8201);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd05d,
nesadapter->phy_index[mac_index], 0x8201);
+
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd023,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd02b,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd033,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd03b,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd043,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd04b,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd053,
nesadapter->phy_index[mac_index], 0x0500);
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd05b,
nesadapter->phy_index[mac_index], 0x0500);
+
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd000,
nesadapter->phy_index[mac_index], 0x0800);
+
+	// master register port status
+	nes_write_10G_phy_reg(nesdev->index_reg, 0xd00c,
nesadapter->phy_index[mac_index], 0x8070);
+
+	// try to let the link come up
+	nes_read_10G_phy_reg(nesdev->index_reg, 0x18,
nesadapter->phy_index[mac_index]);
+	phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL);
+	dprintk("10G phy data from register 0x18 = 0x%X\n", phy_data);
+	// clear any faults
+	nes_read_10G_phy_reg(nesdev->index_reg, 8,
nesadapter->phy_index[mac_index]);
+	phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL);
+	dprintk("10G phy data from register 8 = 0x%X\n", phy_data);
+
+	counter = 0;
+	do {
+		msleep(1);
+		nes_read_10G_phy_reg(nesdev->index_reg, 1,
nesadapter->phy_index[mac_index]);
+		phy_data = (u16)nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_MDIO_CONTROL );
+	} while ( (!(phy_data & 0x0004)) && (counter++<100) );
+
+	dprintk("10G phy data from register 1 = 0x%X, counter=%d\n",
phy_data, counter);
+
+	return 0;
+}
+
+
+/**
+ * nes_nic_qp_init
+ */
+int nes_nic_qp_init(struct nes_dev *nesdev, struct net_device *netdev)
+{
+	struct nes_hw_cqp_wqe *cqp_wqe;
+	struct nes_hw_nic_sq_wqe *nic_sqe;
+	struct nes_hw_nic_qp_context *nic_context;
+	struct sk_buff *skb;
+	struct nes_hw_nic_rq_wqe *nic_rqe;
+	u8 *virt_address;
+	unsigned long flags;
+	dma_addr_t bus_address;
+	u64 u64temp;
+	int ret;
+	u32 cqp_head;
+	u32 counter;
+	u32 wqe_count;
+
+	/* Allocate SQ, RQ, CQ, Reuse CEQ based on the PCI function */
+	nesdev->nic_mem_size = (NES_NIC_WQ_SIZE * sizeof(struct
nes_hw_nic_sq_wqe)) +
+						   (NES_NIC_WQ_SIZE *
sizeof(struct nes_hw_nic_rq_wqe)) +
+						   (NES_NIC_WQ_SIZE * 2
* sizeof(struct nes_hw_nic_cqe)) +
+						   (NES_NIC_WQ_SIZE *
sizeof(struct nes_first_frag)) +
+						   sizeof(struct
nes_hw_nic_qp_context);
+	dprintk("NIC PCI memory size = %u.\n", nesdev->nic_mem_size);
+
+	/* TODO: check for NULL */
+	virt_address = pci_alloc_consistent(nesdev->pcidev,
nesdev->nic_mem_size, &bus_address);
+
+	/* Setup the first Fragment buffers */
+	nesdev->hnic.first_frag_vbase = (void *)virt_address;
+	virt_address += NES_NIC_WQ_SIZE * sizeof(struct nes_first_frag);
+
+	for (counter=0; counter<NES_NIC_WQ_SIZE; counter++ ) {
+		nesdev->hnic.frag_paddr[counter] = bus_address;
+		bus_address += sizeof(struct nes_first_frag);
+	}
+
+	/* setup the SQ */
+	nesdev->hnic.sq_vbase = (void *)virt_address;
+	nesdev->hnic.sq_pbase = bus_address;
+	virt_address += NES_NIC_WQ_SIZE * sizeof(struct
nes_hw_nic_sq_wqe);
+	bus_address += NES_NIC_WQ_SIZE * sizeof(struct
nes_hw_nic_sq_wqe);
+	nesdev->hnic.sq_head = 0;
+	nesdev->hnic.sq_tail = 0;
+	nesdev->hnic.sq_size = NES_NIC_WQ_SIZE;
+	nesdev->hnic.qp_id = 16+(PCI_FUNC(nesdev->pcidev->devfn)*2);
+	for (counter=0; counter<(NES_NIC_WQ_SIZE); counter++) {
+		nic_sqe = &nesdev->hnic.sq_vbase[counter];
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_MISC_IDX] =
NES_NIC_SQ_WQE_DISABLE_CHKSUM | NES_NIC_SQ_WQE_COMPLETION;
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_0_TAG_IDX] =
(u32)NES_FIRST_FRAG_SIZE<<16;
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_LOW_IDX] =
(u32)nesdev->hnic.frag_paddr[counter];
+		nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG0_HIGH_IDX] =
(u32)((u64)nesdev->hnic.frag_paddr[counter]>>32);
+	}
+	/* TODO: if first frag is usually un-aligned, setup the first
frag SGEs here */
+	spin_lock_init(&nesdev->hnic.sq_lock);
+
+	/* setup the RQ */
+	nesdev->hnic.rq_vbase = (void
*)(&nesdev->hnic.sq_vbase[NES_NIC_WQ_SIZE]);
+	nesdev->hnic.rq_head = 0;
+	nesdev->hnic.rq_tail = 0;
+	nesdev->hnic.rq_size = NES_NIC_WQ_SIZE;
+	nesdev->hnic.rq_pbase = nesdev->hnic.sq_pbase + (NES_NIC_WQ_SIZE
* sizeof(struct nes_hw_nic_sq_wqe));
+
+	/* setup the CQ */
+	nesdev->hnic_cq.cq_vbase = (void
*)(&nesdev->hnic.rq_vbase[NES_NIC_WQ_SIZE]);
+	nesdev->hnic_cq.cq_head = 0;
+	nesdev->hnic_cq.cq_size = NES_NIC_WQ_SIZE*2;
+	nesdev->hnic_cq.cq_number = nesdev->hnic.qp_id;
+	nesdev->hnic_cq.ce_handler = nes_hnic_ce_handler;
+	nesdev->hnic_cq.cq_pbase = nesdev->hnic.rq_pbase +
(NES_NIC_WQ_SIZE * sizeof(struct nes_hw_nic_rq_wqe));
+
+	/* Send CreateCQ request to CQP */
+	spin_lock_irqsave(&nesdev->cqp.lock, flags);
+	cqp_head = nesdev->cqp.sq_head;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] = NES_CQP_CREATE_CQ |
NES_CQP_CQ_CEQ_VALID | 
+
(nesdev->hnic_cq.cq_size << 16);
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
nesdev->hnic_cq.cq_number | ((u32)PCI_FUNC(nesdev->pcidev->devfn)<<16);
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) = &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] = cqp_head;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
+	u64temp = (u64)nesdev->hnic_cq.cq_pbase;
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX] =  0;
+	/* the following two lines likely have endian issues */
+	*((struct nes_hw_nic_cq
**)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]) =
&nesdev->hnic_cq;
+	*((u64 *)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX])
>>= 1;
+	dprintk("%s: CQ%u context = 0x%08X:0x%08X.\n", __FUNCTION__,
nesdev->hnic_cq.cq_number, 
+		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX], 
+		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]);
+	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] =  0;
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]);
+	if (++cqp_head >= nesdev->cqp.sq_size) cqp_head = 0;
+	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
+
+	/* Send CreateQP request to CQP */
+	nic_context = (void
*)(&nesdev->hnic_cq.cq_vbase[nesdev->hnic_cq.cq_size]);
+	nic_context->context_words[NES_NIC_CTX_MISC_IDX] =
cpu_to_le32((u32)NES_NIC_CTX_SIZE |
((u32)PCI_FUNC(nesdev->pcidev->devfn)<<12));
+	dprintk("NES_NIC_CTX_SIZE = %0x, word0 = %u.\n",
NES_NIC_CTX_SIZE, nic_context->context_words[NES_NIC_CTX_MISC_IDX]);
+
+	u64temp = (u64)nesdev->hnic.sq_pbase;
+	nic_context->context_words[NES_NIC_CTX_SQ_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	nic_context->context_words[NES_NIC_CTX_SQ_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+	u64temp = (u64)nesdev->hnic.rq_pbase;
+	nic_context->context_words[NES_NIC_CTX_RQ_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	nic_context->context_words[NES_NIC_CTX_RQ_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+
+	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
cpu_to_le32(NES_CQP_CREATE_QP | NES_CQP_QP_TYPE_NIC);
+	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
cpu_to_le32(nesdev->hnic.qp_id);
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
+	*((struct nes_hw_cqp
**)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
cqp_head;
+	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
+	u64temp = (u64)nesdev->hnic_cq.cq_pbase +
(nesdev->hnic_cq.cq_size * sizeof(struct nes_hw_nic_cqe));
+	cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_LOW_IDX] =
cpu_to_le32((u32)u64temp);
+	cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_HIGH_IDX] =
cpu_to_le32((u32)(u64temp>>32));
+	if (++cqp_head >= nesdev->cqp.sq_size) cqp_head = 0;
+
+	nesdev->cqp.sq_head = cqp_head;
+	barrier();
+
+	// Ring doorbell (2 WQEs)
+	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x02800000 |
nesdev->cqp.qp_id );
+
+	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
+	dprintk("Waiting for create NIC QP to complete.\n");
+	cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
+	ret =
wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
2);
+	dprintk("Create NIC QP completed, wait_event_timeout ret =
%u.\n", ret);
+
+	/* Populate the RQ */
+	for (counter=0; counter<(NES_NIC_WQ_SIZE-1); counter++) {
+		skb = dev_alloc_skb(max_frame_len);
+		if (!skb) {
+			dprintk(KERN_ERR PFX "%s: out of memory for
receive\n", netdev->name);
+			// TODO: Unwind the NIC
+			return -ENOMEM;
+		}
+
+		skb->dev = netdev;
+
+		bus_address = pci_map_single(nesdev->pcidev, skb->data,
max_frame_len, PCI_DMA_FROMDEVICE);
+
+		nic_rqe = &nesdev->hnic.rq_vbase[counter];
+		nic_rqe->wqe_words[NES_NIC_RQ_WQE_LENGTH_1_0_IDX] =
cpu_to_le32(max_frame_len);
+		nic_rqe->wqe_words[NES_NIC_RQ_WQE_LENGTH_3_2_IDX] = 0;
+		nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_LOW_IDX] =
cpu_to_le32((u32)bus_address);
+		nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_HIGH_IDX] =
cpu_to_le32((u32)((u64)bus_address>>32));
+		nesdev->hnic.rx_skb[counter] = skb; 
+	}
+
+	wqe_count = NES_NIC_WQ_SIZE-1;
+	nesdev->hnic.rq_head = wqe_count-1;
+	barrier();
+	do {
+		counter = min(wqe_count, ((u32)255));
+		wqe_count -= counter;
+		nes_write32(nesdev->regs+NES_WQE_ALLOC, (counter<<24) |
nesdev->hnic.qp_id );
+	} while (wqe_count);
+
+	return 0;
+}
+
+
+#define MAX_DPC_ITERATIONS 128
+/**
+ * nes_dpc
+ *
+ * @param param
+ */
+void nes_dpc(unsigned long param)
+{
+	struct nes_dev *nesdev = (struct nes_dev *) param;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	u32 counter;
+	u32 loop_counter = 0;
+	u32 int_status_bit;
+	u32 int_stat;
+	u32 temp_int_stat;
+
+//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	do {
+		int_stat = nes_read32(nesdev->regs + NES_INT_STAT);
+		/* Mask off bits for interrupts we are not processing */
+		int_stat &= nesdev->int_req;
+		// dprintk("Interrupt Status (postfilter)  = 0x%08X\n",
int_stat );
+
+		if (int_stat) {
+			/* Ack the interrupts */
+			nes_write32(nesdev->regs+NES_INT_STAT, 
+
(int_stat&~(NES_INT_INTF|NES_INT_TIMER|NES_INT_MAC0|NES_INT_MAC1|NES_INT
_MAC2|NES_INT_MAC3)));
+
+			temp_int_stat = int_stat;
+			/* Process the CEQs */
+			for (counter=0, int_status_bit=1; counter<16 ;
counter++) {
+				if (int_stat & int_status_bit) {
+					nes_process_ceq(nesdev,
&nesadapter->ceq[counter]);
+					temp_int_stat &=
~int_status_bit;
+				}
+				if (!(temp_int_stat & 0x0000ffff))
+					break;
+				int_status_bit <<= 1;
+			}
+
+			/* Process the AEQ for this pci function */
+			int_status_bit =
1<<(16+PCI_FUNC(nesdev->pcidev->devfn));
+			if (int_stat & int_status_bit) {
+				nes_process_aeq(nesdev,
&nesadapter->aeq[PCI_FUNC(nesdev->pcidev->devfn)]);
+			}
+
+			/* Process the MAC interrupt for this pci
function */
+			int_status_bit = 1<<(24+nesdev->mac_index);
+			if (int_stat & int_status_bit) {
+				nes_process_mac_intr(nesdev,
nesdev->mac_index);
+			}
+
+			if (int_stat & NES_INT_TIMER) {
+
+			}
+
+
+			if (int_stat & NES_INT_TSW) {
+			}
+		}
+		/* Don't use the interface interrupt bit stay in loop */
+		int_stat &=
~NES_INT_INTF|NES_INT_TIMER|NES_INT_MAC0|NES_INT_MAC1|NES_INT_MAC2|NES_I
NT_MAC3;
+	} while ((int_stat != 0) && (loop_counter++ <
MAX_DPC_ITERATIONS));
+
+	// Enable interrupts
+	nes_write32(nesdev->regs+NES_INT_MASK, ~nesdev->int_req);
+}
+
+
+/**
+ * nes_process_ceq
+ * 
+ * @param nesdev
+ * @param ceq
+ */
+void nes_process_ceq(struct nes_dev *nesdev, struct nes_hw_ceq *ceq)
+{
+	u64 u64temp;
+	struct nes_hw_cq *cq;
+	u32 head;
+	u32 ceq_size;
+
+//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	head = ceq->ceq_head;
+	ceq_size = ceq->ceq_size;
+
+	do {
+		if
(le32_to_cpu(ceq->ceq_vbase[head].ceqe_words[NES_CEQE_CQ_CTX_HIGH_IDX])
& NES_CEQE_VALID) {
+			u64temp = *((u64
*)&ceq->ceq_vbase[head].ceqe_words[NES_CEQE_CQ_CTX_LOW_IDX]);
+			u64temp <<= 1;
+			cq = *((struct nes_hw_cq **)&u64temp);
+			barrier();
+			/* make the CEQE not valid */
+
ceq->ceq_vbase[head].ceqe_words[NES_CEQE_CQ_CTX_HIGH_IDX] = 0;
+
+			/* call the event handler */
+			cq->ce_handler(nesdev, cq);
+
+			if (++head >= ceq_size)
+				head = 0;
+		} else {
+			break;
+		}
+	} while ( 1 );
+	ceq->ceq_head = head;
+}
+
+
+/**
+ * nes_process_aeq
+ * 
+ * @param nesdev
+ * @param aeq
+ */
+void nes_process_aeq(struct nes_dev *nesdev, struct nes_hw_aeq *aeq)
+{
+	u64 u64temp;
+	u32 head;
+	u32 aeq_size;
+	struct nes_hw_aeqe volatile *aeqe;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	head = aeq->aeq_head;
+	aeq_size = aeq->aeq_size;
+
+	do {
+		aeqe = &aeq->aeq_vbase[head];
+		if ((le32_to_cpu(aeqe->aeqe_words[NES_AEQE_MISC_IDX]) &
NES_AEQE_VALID) == 0)
+			break;
+		aeqe->aeqe_words[NES_AEQE_MISC_IDX] =
le32_to_cpu(aeqe->aeqe_words[NES_AEQE_MISC_IDX]);
+		aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID_IDX] =
le32_to_cpu(aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID_IDX]);
+		if (aeqe->aeqe_words[NES_AEQE_MISC_IDX] &
(NES_AEQE_QP|NES_AEQE_CQ)) {
+			if (aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID_IDX]
>= NES_FIRST_QPN) {
+				/* dealing with an accelerated QP
related AE */
+				u64temp = *((u64
*)&aeqe->aeqe_words[NES_AEQE_COMP_CTXT_LOW_IDX]);
+				nes_process_iwarp_aeqe(nesdev, (struct
nes_hw_aeqe *)aeqe);
+			} else {
+			}
+		} else if (aeqe->aeqe_words[NES_AEQE_MISC_IDX] &
NES_AEQE_CQ) {
+			/* dealing with a CQ related AE */
+			dprintk("%s: Processing CQ realated AE, misc =
0x%04X\n", __FUNCTION__, 
+
(u16)(aeqe->aeqe_words[NES_AEQE_MISC_IDX]>>16));
+		}
+
+		aeqe->aeqe_words[NES_AEQE_MISC_IDX] = 0;
+
+		head++; 
+		if (head >= aeq_size)
+			head = 0;
+	}
+	while ( 1 );
+	aeq->aeq_head = head;
+}
+
+
+/**
+ * nes_process_mac_intr
+ * 
+ * @param nesdev
+ * @param mac_number
+ */
+void nes_process_mac_intr(struct nes_dev *nesdev, u32 mac_number)
+{
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	struct nes_port *nes_port = netdev_priv(nesdev->netdev);
+	u32 mac_status;
+	u32 mac_index = nesdev->mac_index;
+	u16 phy_data;
+
+	// ack the MAC interrupt
+	mac_status = nes_read_indexed(nesdev->index_reg,
NES_IDX_MAC_INT_STATUS );
+	/* Clear the interrupt */
+	nes_write_indexed(nesdev->index_reg, NES_IDX_MAC_INT_STATUS,
mac_status );
+
+	dprintk("MAC interrupt status = 0x%X.\n", mac_status);
+
+	if (mac_status & (NES_MAC_INT_LINK_STAT_CHG |
NES_MAC_INT_XGMII_EXT)) {
+		/* read the PHY interrupt status register */
+		// read status
+		nes_read_10G_phy_reg(nesdev->index_reg, 1,
nesadapter->phy_index[mac_index]);
+		phy_data = (u16)nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_MAC_MDIO_CONTROL );
+		dprintk("10G phy data from register 1 = 0x%X\n",
phy_data);
+
+		if (!(phy_data & 0x0004))
+		{
+			dprintk("link reports down, check faults\n");
+
+//			nes_read_10G_phy_reg(nesdev->index_reg, 0x18,
nesadapter->phy_index[mac_index]);
+//			phy_data =
(u16)nes_read_indexed(nesdev->index_reg, NES_IDX_MAC_MDIO_CONTROL);
+//			dprintk("10G phy data from register 0x18 =
0x%X\n", phy_data);
+			// clear any faults
+			nes_read_10G_phy_reg(nesdev->index_reg, 8,
nesadapter->phy_index[mac_index]);
+			phy_data =
(u16)nes_read_indexed(nesdev->index_reg, NES_IDX_MAC_MDIO_CONTROL);
+			dprintk("10G phy data from register 8 = 0x%X\n",
phy_data);
+
+			// read status, again
+			nes_read_10G_phy_reg(nesdev->index_reg, 1,
nesadapter->phy_index[mac_index]);
+			phy_data =
(u16)nes_read_indexed(nesdev->index_reg, 
+
NES_IDX_MAC_MDIO_CONTROL );
+			dprintk("10G phy data from register 1 = 0x%X\n",
phy_data);
+		}
+
+		if (phy_data & 0x0004)
+		{
+			dprintk("The Link is UP!!.  linkup was %d\n",
nes_port->linkup);
+			if (nes_port->linkup == 0) {
+				printk(PFX "The Link is now up for port
%u.\n", nesdev->mac_index);
+				if (netif_queue_stopped(nesdev->netdev))
+
netif_start_queue(nesdev->netdev);
+				nes_port->linkup = 1;
+				netif_carrier_on(nesdev->netdev);
+			}
+		} else {
+			dprintk("The Link is Down!!. linkup was %d\n",
nes_port->linkup);
+			if (nes_port->linkup == 1) {
+				printk(PFX "The Link is now down for
port %u.\n", nesdev->mac_index);
+				if
(!(netif_queue_stopped(nesdev->netdev)))
+
netif_stop_queue(nesdev->netdev);
+				nes_port->linkup = 0;
+				netif_carrier_off(nesdev->netdev);
+			}
+		}
+	}
+	if (mac_status & NES_MAC_INT_TX_UNDERFLOW) {
+		dprintk("The MAC reported a TX underflow!!.\n");
+	}
+	if (mac_status & NES_MAC_INT_TX_ERROR) {
+		dprintk("The MAC reported a TX Error!!.\n");
+	}
+}
+
+
+/**
+ * nes_hnic_ce_handler
+ * 
+ * @param nesdev
+ * @param cq
+ */
+void nes_hnic_ce_handler(struct nes_dev *nesdev, struct nes_hw_nic_cq
*cq)
+{
+	struct nes_hw_nic *nesnic;
+	struct nes_port *nes_port = netdev_priv(nesdev->netdev);
+	struct nes_hw_nic_rq_wqe *nic_rqe;
+	struct nes_hw_nic_sq_wqe *nic_sqe;
+	struct sk_buff *skb;
+	struct sk_buff *rx_skb;
+	struct sk_buff *dup_rx_skb;
+	struct tcphdr *pTCPHeader;
+	struct iphdr *pIPHeader;
+	unsigned long flags;
+	u64 u64temp;
+	u8 u8temp;
+	dma_addr_t bus_address;
+	u32 head;
+	u32 cq_size;
+	u32 rx_pkt_size;
+	u32 cqe_count=0;
+
+//	dprintk("%s:%s:%u:\n", __FILE__, __FUNCTION__, __LINE__);
+
+	head = cq->cq_head;
+	cq_size = cq->cq_size;
+	do {
+		if
(le32_to_cpu(cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX]) &
NES_NIC_CQE_VALID) {
+			nesnic = &nesdev->hnic;
+
cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX] =
le32_to_cpu(cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX]);
+
+			if
(cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX]&NES_NIC_CQE_SQ) {
+//				dprintk("%s: Processing SQ completion
for QP%u. SQ Tail = %u.\n", __FUNCTION__, 
+//						nesdev->hnic.qp_id,
nesnic->sq_tail);
+				nic_sqe =
&nesnic->sq_vbase[nesnic->sq_tail];
+				skb = nesnic->tx_skb[nesnic->sq_tail];
+//            	dprintk("SQ skb = %p.\n", skb);
+				if
(nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_2_1_IDX] != 0) {
+					u64temp =
le32_to_cpu(nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_LOW_IDX]);
+					u64temp +=
((u64)le32_to_cpu(nic_sqe->wqe_words[NES_NIC_SQ_WQE_FRAG1_HIGH_IDX]))<<3
2;
+					bus_address =
(dma_addr_t)u64temp;
+					pci_unmap_single(nesdev->pcidev,
bus_address,
+
le32_to_cpu(nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_2_1_IDX]),
PCI_DMA_TODEVICE);
+					dev_kfree_skb_any(skb);
+				}
+				spin_lock_irqsave(&nesnic->sq_lock,
flags);
+				nesnic->sq_tail++;
+				nesnic->sq_tail &= nesnic->sq_size-1;
+				/* restart the queue if it had been
stopped */
+				if (netif_queue_stopped(nesdev->netdev))
+
netif_wake_queue(nesdev->netdev);
+				spin_unlock_irqrestore(&nesnic->sq_lock,
flags);
+			} else {
+				rx_pkt_size =
cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX]&0x0000ffff;
+//				dprintk("%s: Processing RQ completion
for QP%u. RQ Tail = %u, size = %u.\n", 
+//							__FUNCTION__,
nesdev->hnic.qp_id, nesnic->rq_tail, rx_pkt_size);
+				nic_rqe =
&nesnic->rq_vbase[nesnic->rq_tail];
+				/* Get the skb */
+				rx_skb =
nesnic->rx_skb[nesnic->rq_tail];
+//            	dprintk("Dequeued RQ skb = %p.\n", rx_skb);
+				/* unmap the buffer */
+				nic_rqe =
&nesnic->rq_vbase[nesdev->hnic.rq_tail];
+				bus_address =
le32_to_cpu(nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_LOW_IDX]);
+				bus_address +=
((u64)le32_to_cpu(nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_HIGH_IDX]))<<3
2;
+//   	      	dprintk("skb %p getting removed from the RQ at index %u
(bus address = %X).\n", 
+//         	   				rx_skb, nesnic->rq_tail,
(u32)bus_address);
+				pci_unmap_single(nesdev->pcidev,
bus_address,
+
max_frame_len, PCI_DMA_FROMDEVICE);
+				/* setup the old skb */
+				rx_skb->tail = rx_skb->data +
rx_pkt_size;
+				rx_skb->len = rx_pkt_size;
+				rx_skb->protocol =
eth_type_trans(rx_skb, nesdev->netdev);
+				nesnic->rq_tail++;
+				nesnic->rq_tail &= nesnic->rq_size - 1;
+				/* get a new skb */
+				skb = dev_alloc_skb(max_frame_len);
+				if (skb) {
+//   	         	dprintk("skb %p added to the RQ at index %u.\n",
skb, nesnic->rq_head);
+					skb->dev = nesdev->netdev;
+
+					/* map put down to the chip */
+					bus_address =
pci_map_single(nesdev->pcidev, 
+
skb->data, max_frame_len, PCI_DMA_FROMDEVICE);
+//   	         	dprintk("skb %p added to the RQ at index %u (bus
address = %X).\n", skb, nesnic->rq_head, bus_address);
+
+					nic_rqe =
&nesnic->rq_vbase[nesdev->hnic.rq_head];
+
nic_rqe->wqe_words[NES_NIC_RQ_WQE_LENGTH_1_0_IDX] =
cpu_to_le32(max_frame_len);
+
nic_rqe->wqe_words[NES_NIC_RQ_WQE_LENGTH_3_2_IDX] = 0;
+
nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_LOW_IDX] =
cpu_to_le32((u32)bus_address);
+
nic_rqe->wqe_words[NES_NIC_RQ_WQE_FRAG0_HIGH_IDX] =
cpu_to_le32((u32)((u64)bus_address>>32));
+					nesnic->rx_skb[nesnic->rq_head]
= skb; 
+					nesnic->rq_head++;
+					nesnic->rq_head &=
nesnic->rq_size - 1;
+
nes_write32(nesdev->regs+NES_WQE_ALLOC, (1<<24) | nesnic->qp_id );
+				} else {
+					// TODO: Set a timer and/or add
code to rx to allocate more buffers
+				}
+
+				/* indicate the old skb up to the stack
*/
+				/* Need to dup arps, and filter packets
based on ports */
+
+				// if the packet is TCP/IPv4, look it up
+				if
((le32_to_cpu(cq->cq_vbase[head].cqe_words[NES_NIC_CQE_TAG_PKT_TYPE_IDX]
) & 0xF3E)== 0x112) {
+					/* TODO: Assuming DIX for now,
allow for SNAP and VLAN */
+					pIPHeader = (struct iphdr
*)rx_skb->data;
+					pTCPHeader = (struct tcphdr
*)(rx_skb->data+(4*pIPHeader->ihl));
+					u8temp = 1 <<
(ntohs(pTCPHeader->dest)&7);
+					if ((nesdev->local_ipaddr ==
pIPHeader->daddr) && 
+
(nesdev->apbv_table[ntohs(pTCPHeader->dest)>>3] & u8temp)) {
+
stack_ops_p->nesif_rx(rx_skb);
+					} else {
+						netif_rx(rx_skb);
+					}
+				} else {
+					if (ntohs(rx_skb->protocol) ==
ETH_P_ARP) {
+						if
(nesdev->nes_stack_start) {
+							dup_rx_skb =
skb_clone(rx_skb, GFP_ATOMIC);
+							if (dup_rx_skb)
{
+
stack_ops_p->nesif_rx(dup_rx_skb);
+							}
+						}
+					}
+					netif_rx(rx_skb);
+				}
+
+				nesdev->netdev->last_rx = jiffies;
+				nes_port->netstats.rx_packets++;
+				nes_port->netstats.rx_bytes +=
(cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX]&0x0000ffff);
+			}
+
cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX] = 0;
+			// Accounting...
+			cqe_count++;
+			if (++head >= cq_size) head = 0;
+			if (cqe_count == 255) {
+				// Arm the CCQ
+				nes_write32(nesdev->regs+NES_CQE_ALLOC,

+							cq->cq_number |
(cqe_count << 16) );
+				cqe_count = 0;
+			}
+		} else {
+			break;
+		}
+	} while ( 1 );
+	cq->cq_head = head;
+//   dprintk("CQ%u Processed = %u cqes, new head = %u.\n",
cq->cq_number, cqe_count, cq->cq_head);
+	// Arm the CCQ
+	nes_write32(nesdev->regs+NES_CQE_ALLOC,
NES_CQE_ALLOC_NOTIFY_NEXT | 
+				cq->cq_number | (cqe_count << 16) );
+}
+
+
+/**
+ * cqp_ce_handler
+ * 
+ * @param nesdev
+ * @param cq
+ */
+void cqp_ce_handler(struct nes_dev *nesdev, struct nes_hw_cq *cq)
+{
+	struct nes_hw_cqp *cqp;
+	u32 head;
+	u32 cq_size;
+	u32 cqe_count=0;
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	head = cq->cq_head;
+	cq_size = cq->cq_size;
+
+	do {
+		/* process the CQE */
+		if
(le32_to_cpu(cq->cq_vbase[head].cqe_words[NES_CQE_OPCODE_IDX]) &
NES_CQE_VALID) {
+			cqp = *((struct nes_hw_cqp
**)&cq->cq_vbase[head].cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX]);
+
+			if
(cq->cq_vbase[head].cqe_words[NES_CQE_ERROR_CODE_IDX]) {
+
cq->cq_vbase[head].cqe_words[NES_CQE_ERROR_CODE_IDX] = 
+
le32_to_cpu(cq->cq_vbase[head].cqe_words[NES_CQE_ERROR_CODE_IDX]);
+				dprintk("Bad Completion code from CQP,
Major/Minor codes = 0x%04X:%04X.\n", 
+
(u16)(cq->cq_vbase[head].cqe_words[NES_CQE_ERROR_CODE_IDX]>>16),
+
(u16)cq->cq_vbase[head].cqe_words[NES_CQE_ERROR_CODE_IDX]);
+			}
+
+			if (++cqp->sq_tail >= cqp->sq_size)
+				cqp->sq_tail = 0;
+			wake_up(&nesdev->cqp.waitq);
+
+			cq->cq_vbase[head].cqe_words[NES_CQE_OPCODE_IDX]
= 0;
+			// Accounting...
+			cqe_count++;
+			if (++head >= cq_size)
+				head = 0;
+		} else {
+			break;
+		}
+	} while ( 1 );
+	cq->cq_head = head;
+
+	/* Arm the CCQ */
+	nes_write32(nesdev->regs+NES_CQE_ALLOC,
NES_CQE_ALLOC_NOTIFY_NEXT | 
+				cq->cq_number | (cqe_count << 16) );
+}
+
+
+/**
+ * nes_process_iwarp_aeqe
+ * 
+ * @param nesdev
+ * @param aeqe
+ */
+void nes_process_iwarp_aeqe(struct nes_dev *nesdev, struct nes_hw_aeqe
*aeqe)
+{
+	u64 context;
+    struct nes_qp *nesqp;
+    struct iw_cm_id *cm_id;
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+    struct ib_event ibevent;
+    struct iw_cm_event cmevent;
+	u32 aeq_info;
+    u16 async_event_id;
+
+    dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	context = aeqe->aeqe_words[NES_AEQE_COMP_CTXT_LOW_IDX];
+	context +=
((u64)aeqe->aeqe_words[NES_AEQE_COMP_CTXT_HIGH_IDX])<<32;
+	aeq_info = le32_to_cpu(aeqe->aeqe_words[NES_AEQE_MISC_IDX]);
+	async_event_id = (u16)aeq_info;
+
+    switch (async_event_id){
+        case NES_AEQE_AEID_LLP_FIN_RECEIVED:
+            nesqp = *((struct nes_qp **)&context);
+            if (nesqp->cm_id){
+                cm_id = nesqp->cm_id;
+				if (cm_id->event_handler) {
+	                cmevent.event = IW_CM_EVENT_DISCONNECT;
+					cmevent.status =
IW_CM_EVENT_STATUS_OK;
+	                cmevent.local_addr = cm_id->local_addr;
+	                cmevent.remote_addr = cm_id->remote_addr;
+	                cmevent.private_data = NULL;
+	                cmevent.private_data_len = 0;
+	                dprintk("%s:Generating a Disconnect Event
(normal) for QP%u \n", 
+	                        __FUNCTION__, nesqp->hwqp.qp_id);
+	                cm_id->event_handler(nesqp->cm_id, &cmevent);
+					/* TODO: this does not seem
correct, Seems like app should do close */
+					INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+					queue_work(nesqp->aewq,
&nesqp->ae_work);
+				}
+            }
+            break;
+		case NES_AEQE_AEID_LLP_CLOSE_COMPLETE:
+			nesqp = *((struct nes_qp **)&context);
+			nesqp->last_aeq =
NES_AEQE_AEID_LLP_CLOSE_COMPLETE;
+			dprintk("%s: Processing an
NES_AEQE_AEID_LLP_CLOSE_COMPLETE event on QP%u \n", 
+					__FUNCTION__,
nesqp->hwqp.qp_id);
+			INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+			queue_work(nesqp->aewq, &nesqp->ae_work);
+			break;
+        case NES_AEQE_AEID_LLP_CONNECTION_RESET:
+            nesqp = *((struct nes_qp **)&context);
+            if (nesqp->cm_id){
+                cm_id = nesqp->cm_id;
+				if (cm_id->event_handler) {
+					cmevent.event =
IW_CM_EVENT_DISCONNECT;
+					cmevent.status =
IW_CM_EVENT_STATUS_OK;
+					cmevent.local_addr =
cm_id->local_addr;
+					cmevent.remote_addr =
cm_id->remote_addr;
+					cmevent.private_data = NULL;
+					cmevent.private_data_len = 0;
+					dprintk("%s:Generating a
Disconnect Event (reset) for QP%u \n", 
+							__FUNCTION__,
nesqp->hwqp.qp_id);
+					cm_id->event_handler(cm_id,
&cmevent);
+					/* TODO: this does not seem
correct, Seems like app should do close */
+					dprintk("nesqp->aewq = %p.\n",
nesqp->aewq );
+					INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+					queue_work(nesqp->aewq,
&nesqp->ae_work);
+				}
+            }
+            break;
+		case NES_AEQE_AEID_AMP_BAD_STAG_INDEX:
+			if (NES_AEQE_INBOUND_RDMA&aeq_info) {
+				nesqp =
nesadapter->qp_table[le32_to_cpu(aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID
_IDX])-NES_FIRST_QPN];
+			} else {
+				/* TODO: get the actual WQE and mask off
wqe index */
+				context &= ~((u64)511);
+				nesqp = *((struct nes_qp **)&context);
+			}
+			printk("%s: Processing an
NES_AEQE_AEID_AMP_BAD_STAG_INDEX event on QP%u \n", 
+					__FUNCTION__,
nesqp->hwqp.qp_id);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_ACCESS_ERR;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context );
+			}
+			break;
+		case NES_AEQE_AEID_AMP_UNALLOCATED_STAG:
+			nesqp = *((struct nes_qp **)&context);
+			printk("%s: Processing an
NES_AEQE_AEID_AMP_UNALLOCATED_STAG event on QP%u \n", 
+					__FUNCTION__,
nesqp->hwqp.qp_id);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_ACCESS_ERR;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context);
+			}
+			break;
+		case NES_AEQE_AEID_PRIV_OPERATION_DENIED:
+			nesqp =
nesadapter->qp_table[le32_to_cpu(aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID
_IDX])-NES_FIRST_QPN];
+			printk("%s: Processing an
NES_AEQE_AEID_PRIV_OPERATION_DENIED event on QP%u, nesqp = %p, AE
reported %p \n", 
+					__FUNCTION__, nesqp->hwqp.qp_id,
nesqp, *((struct nes_qp **)&context));
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_ACCESS_ERR;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context);
+			}
+		case NES_AEQE_AEID_CQ_OPERATION_ERROR:
+			printk("%s: Processing an
NES_AEQE_AEID_CQ_OPERATION_ERROR event on CQ%u \n", 
+					__FUNCTION__,
le32_to_cpu(aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID_IDX]));
+			/* TODO: Need to add code to lookup the CQ
context based on the CQID from the AE
+					and generate an event */
+			break;
+		case
NES_AEQE_AEID_DDP_UBE_DDP_MESSAGE_TOO_LONG_FOR_AVAILABLE_BUFFER:
+			/* SA1 Errata: completion context not filled in
*/
+			nesqp =
nesadapter->qp_table[le32_to_cpu(aeqe->aeqe_words[NES_AEQE_COMP_QP_CQ_ID
_IDX])-NES_FIRST_QPN];
+			printk("%s: Processing an
NES_AEQE_AEID_DDP_UBE_DDP_MESSAGE_TOO_LONG_FOR_AVAILABLE_BUFFER event on
QP%u \n", 
+					__FUNCTION__,
nesqp->hwqp.qp_id);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_ACCESS_ERR;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context );
+			}
+			/* TODO: this does not seem correct, Seems like
app should do close */
+			INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+			queue_work(nesqp->aewq, &nesqp->ae_work);
+			break;
+		case
NES_AEQE_AEID_DDP_UBE_INVALID_MSN_NO_BUFFER_AVAILABLE:
+			nesqp = *((struct nes_qp **)&context);
+			printk("%s: Processing an
NES_AEQE_AEID_DDP_UBE_INVALID_MSN_NO_BUFFER_AVAILABLE event on QP%u \n",

+					__FUNCTION__, nesqp->hwqp.qp_id
);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_FATAL;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context );
+			}
+			/* TODO: this does not seem correct, Seems like
app should do close */
+			INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+			queue_work(nesqp->aewq, &nesqp->ae_work);
+			break;
+		case NES_AEQE_AEID_LLP_RECEIVED_MPA_CRC_ERROR:
+			nesqp = *((struct nes_qp **)&context);
+			printk("%s: Processing an
NES_AEQE_AEID_LLP_RECEIVED_MPA_CRC_ERROR event on QP%u \n  Q2 Data: \n",

+					__FUNCTION__, nesqp->hwqp.qp_id
);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_FATAL;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context );
+			}
+			/* TODO: this does not seem correct, Seems like
app should do close */
+			INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+			queue_work(nesqp->aewq, &nesqp->ae_work);
+			break;
+		case NES_AEQE_AEID_LLP_TERMINATE_RECEIVED:
+            nesqp = *((struct nes_qp **)&context);
+			printk("%s: Processing an
NES_AEQE_AEID_LLP_TERMINATE_RECEIVED event on QP%u \n  Q2 Data: \n", 
+					__FUNCTION__, nesqp->hwqp.qp_id
);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_FATAL;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context );
+			}
+			nesqp->ibqp_state = IB_QPS_SQE;
+			nesqp->iwarp_state =
NES_CQP_QP_IWARP_STATE_TERMINATE;
+			/* TODO: this does not seem correct, Seems like
app should do close */
+			INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+			queue_work(nesqp->aewq, &nesqp->ae_work);
+			break;
+		case NES_AEQE_AEID_RDMAP_ROE_BAD_LLP_CLOSE:
+            nesqp = *((struct nes_qp **)&context);
+			printk("%s: Processing an
NES_AEQE_AEID_RDMAP_ROE_BAD_LLP_CLOSE event on QP%u \n", 
+					__FUNCTION__, nesqp->hwqp.qp_id
);
+			if (nesqp->ibqp.event_handler) {
+				ibevent.device = nesqp->ibqp.device;
+				ibevent.element.qp = &nesqp->ibqp;
+				ibevent.event = IB_EVENT_QP_FATAL;
+				nesqp->ibqp.event_handler(&ibevent,
nesqp->ibqp.qp_context );
+			}
+			nesqp->ibqp_state = IB_QPS_SQE;
+			nesqp->iwarp_state =
NES_CQP_QP_IWARP_STATE_TERMINATE;
+			/* TODO: this does not seem correct, Seems like
app should do close */
+			INIT_WORK(&nesqp->ae_work,
nes_disconnect_worker, nesqp);
+			queue_work(nesqp->aewq, &nesqp->ae_work);
+			break;
+			/* TODO: additional AEs need to be here */
+        default:
+            printk("%s: Processing an iWARP related AE for QP, misc =
0x%04X\n", __FUNCTION__, 
+							async_event_id);
+            break;
+    }
+}
+
+
+/**
+ * iwarp_ce_handler
+ * 
+ * @param nesdev
+ * @param hw_cq
+ */
+void iwarp_ce_handler(struct nes_dev *nesdev, struct nes_hw_cq *hw_cq)
+{
+	struct nes_cq *nescq = container_of(hw_cq, struct nes_cq,
hw_cq);
+
+//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+//	dprintk("%s: Processing completion event for iWARP CQ%u.\n",
__FUNCTION__, nescq->hw_cq.cq_number);
+	nes_write32(nesdev->regs+NES_CQ_ACK, nescq->hw_cq.cq_number );
+
+	if (nescq->ibcq.comp_handler)
+		nescq->ibcq.comp_handler(&nescq->ibcq,
nescq->ibcq.cq_context);
+
+	return; 
+
+}
+

