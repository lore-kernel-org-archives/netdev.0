From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [RESENDv2 09/11] netxen: cut-through rx changes
Date: Mon, 21 Jul 2008 19:44:08 -0700
Message-ID: <1216694650-23257-10-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:47601 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754962AbYGVCoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 22:44:12 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NX3031 supports cut-through operation where ingress packets are
directly dma'ed into host buffers to reduce latency.

This requires larger dma buffers (2kb) and different alignemnt.

The buffer posting logic is changed a bit. The free rx buffers
are maintained in linked list, since the received reference
handles can be out of order. However rx descriptors are still
posted sequentially, indexed by producer.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   38 ++-
 drivers/net/netxen/netxen_nic_ctx.c  |  710 ++++++++++++++++++++++++++++++++++
 drivers/net/netxen/netxen_nic_init.c |  191 +++++++---
 drivers/net/netxen/netxen_nic_main.c |   15 +-
 4 files changed, 876 insertions(+), 78 deletions(-)
 create mode 100644 drivers/net/netxen/netxen_nic_ctx.c

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e41f623..705fdf1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -140,6 +140,7 @@
 #define NX_RX_NORMAL_BUF_MAX_LEN       (NX_MAX_ETHERHDR + NX_ETHERMTU)
 #define NX_P2_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P2_MAX_MTU)
 #define NX_P3_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P3_MAX_MTU)
+#define NX_CT_DEFAULT_RX_BUF_LEN	2048
 
 #define MAX_RX_BUFFER_LENGTH		1760
 #define MAX_RX_JUMBO_BUFFER_LENGTH 	8062
@@ -391,8 +392,8 @@ struct rcv_desc {
 };
 
 /* opcode field in status_desc */
-#define RCV_NIC_PKT	(0xA)
-#define STATUS_NIC_PKT	((RCV_NIC_PKT) << 12)
+#define NETXEN_NIC_RXPKT_DESC  0x04
+#define NETXEN_OLD_RXPKT_DESC  0x3f
 
 /* for status field in status_desc */
 #define STATUS_NEED_CKSUM	(1)
@@ -424,6 +425,8 @@ struct rcv_desc {
 	(((sts_data) >> 28) & 0xFFFF)
 #define netxen_get_sts_prot(sts_data)	\
 	(((sts_data) >> 44) & 0x0F)
+#define netxen_get_sts_pkt_offset(sts_data)	\
+	(((sts_data) >> 48) & 0x1F)
 #define netxen_get_sts_opcode(sts_data)	\
 	(((sts_data) >> 58) & 0x03F)
 
@@ -438,17 +441,30 @@ struct rcv_desc {
 
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
-	   28-43 reference_handle, 44-47 protocol, 48-52 unused
+	   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
 	   53-55 desc_cnt, 56-57 owner, 58-63 opcode
 	 */
 	__le64 status_desc_data;
-	__le32 hash_value;
-	u8 hash_type;
-	u8 msg_type;
-	u8 unused;
-	/* Bit pattern: 0-6 lro_count indicates frag sequence,
-	   7 last_frag indicates last frag */
-	u8 lro;
+	union {
+		struct {
+			__le32 hash_value;
+			u8 hash_type;
+			u8 msg_type;
+			u8 unused;
+			union {
+				/* Bit pattern: 0-6 lro_count indicates frag
+				 * sequence, 7 last_frag indicates last frag
+				 */
+				u8 lro;
+
+				/* chained buffers */
+				u8 nr_frags;
+			};
+		};
+		struct {
+			__le16 frag_handles[4];
+		};
+	};
 } __attribute__ ((aligned(16)));
 
 enum {
@@ -774,6 +790,7 @@ struct netxen_cmd_buffer {
 
 /* In rx_buffer, we do not need multiple fragments as is a single buffer */
 struct netxen_rx_buffer {
+	struct list_head list;
 	struct sk_buff *skb;
 	u64 dma;
 	u16 ref_handle;
@@ -854,6 +871,7 @@ struct nx_host_rds_ring {
 	u32 dma_size;
 	u32 skb_size;
 	struct netxen_rx_buffer *rx_buf_arr;	/* rx buffers for receive   */
+	struct list_head free_list;
 	int begin_alloc;
 };
 
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
new file mode 100644
index 0000000..64babc5
--- /dev/null
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -0,0 +1,710 @@
+/*
+ * Copyright (C) 2003 - 2008 NetXen, Inc.
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
+ * MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called LICENSE.
+ *
+ * Contact Information:
+ *    info@netxen.com
+ * NetXen,
+ * 3965 Freedom Circle, Fourth floor,
+ * Santa Clara, CA 95054
+ *
+ */
+
+#include "netxen_nic_hw.h"
+#include "netxen_nic.h"
+#include "netxen_nic_phan_reg.h"
+
+#define NXHAL_VERSION	1
+
+static int
+netxen_api_lock(struct netxen_adapter *adapter)
+{
+	u32 done = 0, timeout = 0;
+
+	for (;;) {
+		/* Acquire PCIE HW semaphore5 */
+		netxen_nic_read_w0(adapter,
+			NETXEN_PCIE_REG(PCIE_SEM5_LOCK), &done);
+
+		if (done == 1)
+			break;
+
+		if (++timeout >= NX_OS_CRB_RETRY_COUNT) {
+			printk(KERN_ERR "%s: lock timeout.\n", __func__);
+			return -1;
+		}
+
+		msleep(1);
+	}
+
+#if 0
+	netxen_nic_write_w1(adapter,
+		NETXEN_API_LOCK_ID, NX_OS_API_LOCK_DRIVER);
+#endif
+	return 0;
+}
+
+static int
+netxen_api_unlock(struct netxen_adapter *adapter)
+{
+	u32 val;
+
+	/* Release PCIE HW semaphore5 */
+	netxen_nic_read_w0(adapter,
+		NETXEN_PCIE_REG(PCIE_SEM5_UNLOCK), &val);
+	return 0;
+}
+
+static u32
+netxen_poll_rsp(struct netxen_adapter *adapter)
+{
+	u32 raw_rsp, rsp = NX_CDRP_RSP_OK;
+	int	timeout = 0;
+
+	do {
+		/* give atleast 1ms for firmware to respond */
+		msleep(1);
+
+		if (++timeout > NX_OS_CRB_RETRY_COUNT)
+			return NX_CDRP_RSP_TIMEOUT;
+
+		netxen_nic_read_w1(adapter, NX_CDRP_CRB_OFFSET,
+				&raw_rsp);
+
+		rsp = le32_to_cpu(raw_rsp);
+	} while (!NX_CDRP_IS_RSP(rsp));
+
+	return rsp;
+}
+
+static u32
+netxen_issue_cmd(struct netxen_adapter *adapter,
+	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd)
+{
+	u32 rsp;
+	u32 signature = 0;
+	u32 rcode = NX_RCODE_SUCCESS;
+
+	signature = NX_CDRP_SIGNATURE_MAKE(pci_fn, version);
+
+	/* Acquire semaphore before accessing CRB */
+	if (netxen_api_lock(adapter))
+		return NX_RCODE_TIMEOUT;
+
+	netxen_nic_write_w1(adapter, NX_SIGN_CRB_OFFSET,
+			cpu_to_le32(signature));
+
+	netxen_nic_write_w1(adapter, NX_ARG1_CRB_OFFSET,
+			cpu_to_le32(arg1));
+
+	netxen_nic_write_w1(adapter, NX_ARG2_CRB_OFFSET,
+			cpu_to_le32(arg2));
+
+	netxen_nic_write_w1(adapter, NX_ARG3_CRB_OFFSET,
+			cpu_to_le32(arg3));
+
+	netxen_nic_write_w1(adapter, NX_CDRP_CRB_OFFSET,
+			cpu_to_le32(NX_CDRP_FORM_CMD(cmd)));
+
+	rsp = netxen_poll_rsp(adapter);
+
+	if (rsp == NX_CDRP_RSP_TIMEOUT) {
+		printk(KERN_ERR "%s: card response timeout.\n",
+				netxen_nic_driver_name);
+
+		rcode = NX_RCODE_TIMEOUT;
+	} else if (rsp == NX_CDRP_RSP_FAIL) {
+		netxen_nic_read_w1(adapter, NX_ARG1_CRB_OFFSET, &rcode);
+		rcode = le32_to_cpu(rcode);
+
+		printk(KERN_ERR "%s: failed card response code:0x%x\n",
+				netxen_nic_driver_name, rcode);
+	}
+
+	/* Release semaphore */
+	netxen_api_unlock(adapter);
+
+	return rcode;
+}
+
+u32
+nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu)
+{
+	u32 rcode = NX_RCODE_SUCCESS;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
+
+	if (recv_ctx->state == NX_HOST_CTX_STATE_ACTIVE)
+		rcode = netxen_issue_cmd(adapter,
+				adapter->ahw.pci_func,
+				NXHAL_VERSION,
+				recv_ctx->context_id,
+				mtu,
+				0,
+				NX_CDRP_CMD_SET_MTU);
+
+	return rcode;
+}
+
+static int
+nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
+{
+	void *addr;
+	nx_hostrq_rx_ctx_t *prq;
+	nx_cardrsp_rx_ctx_t *prsp;
+	nx_hostrq_rds_ring_t *prq_rds;
+	nx_hostrq_sds_ring_t *prq_sds;
+	nx_cardrsp_rds_ring_t *prsp_rds;
+	nx_cardrsp_sds_ring_t *prsp_sds;
+	struct nx_host_rds_ring *rds_ring;
+
+	dma_addr_t hostrq_phys_addr, cardrsp_phys_addr;
+	u64 phys_addr;
+
+	int i, nrds_rings, nsds_rings;
+	size_t rq_size, rsp_size;
+	u32 cap, reg;
+
+	int err;
+
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
+
+	/* only one sds ring for now */
+	nrds_rings = adapter->max_rds_rings;
+	nsds_rings = 1;
+
+	rq_size =
+		SIZEOF_HOSTRQ_RX(nx_hostrq_rx_ctx_t, nrds_rings, nsds_rings);
+	rsp_size =
+		SIZEOF_CARDRSP_RX(nx_cardrsp_rx_ctx_t, nrds_rings, nsds_rings);
+
+	addr = pci_alloc_consistent(adapter->pdev,
+				rq_size, &hostrq_phys_addr);
+	if (addr == NULL)
+		return -ENOMEM;
+	prq = (nx_hostrq_rx_ctx_t *)addr;
+
+	addr = pci_alloc_consistent(adapter->pdev,
+			rsp_size, &cardrsp_phys_addr);
+	if (addr == NULL) {
+		err = -ENOMEM;
+		goto out_free_rq;
+	}
+	prsp = (nx_cardrsp_rx_ctx_t *)addr;
+
+	prq->host_rsp_dma_addr = cpu_to_le64(cardrsp_phys_addr);
+
+	cap = (NX_CAP0_LEGACY_CONTEXT | NX_CAP0_LEGACY_MN);
+	cap |= (NX_CAP0_JUMBO_CONTIGUOUS | NX_CAP0_LRO_CONTIGUOUS);
+
+	prq->capabilities[0] = cpu_to_le32(cap);
+	prq->host_int_crb_mode =
+		cpu_to_le32(NX_HOST_INT_CRB_MODE_SHARED);
+	prq->host_rds_crb_mode =
+		cpu_to_le32(NX_HOST_RDS_CRB_MODE_UNIQUE);
+
+	prq->num_rds_rings = cpu_to_le16(nrds_rings);
+	prq->num_sds_rings = cpu_to_le16(nsds_rings);
+	prq->rds_ring_offset = 0;
+	prq->sds_ring_offset = prq->rds_ring_offset +
+		(sizeof(nx_hostrq_rds_ring_t) * nrds_rings);
+
+	prq_rds = (nx_hostrq_rds_ring_t *)(prq->data + prq->rds_ring_offset);
+
+	for (i = 0; i < nrds_rings; i++) {
+
+		rds_ring = &recv_ctx->rds_rings[i];
+
+		prq_rds[i].host_phys_addr = cpu_to_le64(rds_ring->phys_addr);
+		prq_rds[i].ring_size = cpu_to_le32(rds_ring->max_rx_desc_count);
+		prq_rds[i].ring_kind = cpu_to_le32(i);
+		prq_rds[i].buff_size = cpu_to_le64(rds_ring->dma_size);
+	}
+
+	prq_sds = (nx_hostrq_sds_ring_t *)(prq->data + prq->sds_ring_offset);
+
+	prq_sds[0].host_phys_addr =
+		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
+	prq_sds[0].ring_size = cpu_to_le32(adapter->max_rx_desc_count);
+	/* only one msix vector for now */
+	prq_sds[0].msi_index = cpu_to_le32(0);
+
+	/* now byteswap offsets */
+	prq->rds_ring_offset = cpu_to_le32(prq->rds_ring_offset);
+	prq->sds_ring_offset = cpu_to_le32(prq->sds_ring_offset);
+
+	phys_addr = hostrq_phys_addr;
+	err = netxen_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			NXHAL_VERSION,
+			(u32)(phys_addr >> 32),
+			(u32)(phys_addr & 0xffffffff),
+			rq_size,
+			NX_CDRP_CMD_CREATE_RX_CTX);
+	if (err) {
+		printk(KERN_WARNING
+			"Failed to create rx ctx in firmware%d\n", err);
+		goto out_free_rsp;
+	}
+
+
+	prsp_rds = ((nx_cardrsp_rds_ring_t *)
+			 &prsp->data[prsp->rds_ring_offset]);
+
+	for (i = 0; i < le32_to_cpu(prsp->num_rds_rings); i++) {
+		rds_ring = &recv_ctx->rds_rings[i];
+
+		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
+		rds_ring->crb_rcv_producer = NETXEN_NIC_REG(reg - 0x200);
+	}
+
+	prsp_sds = ((nx_cardrsp_sds_ring_t *)
+			&prsp->data[prsp->sds_ring_offset]);
+	reg = le32_to_cpu(prsp_sds[0].host_consumer_crb);
+	recv_ctx->crb_sts_consumer = NETXEN_NIC_REG(reg - 0x200);
+
+	reg = le32_to_cpu(prsp_sds[0].interrupt_crb);
+	adapter->crb_intr_mask = NETXEN_NIC_REG(reg - 0x200);
+
+	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
+	recv_ctx->context_id = le16_to_cpu(prsp->context_id);
+	recv_ctx->virt_port = le16_to_cpu(prsp->virt_port);
+
+out_free_rsp:
+	pci_free_consistent(adapter->pdev, rsp_size, prsp, cardrsp_phys_addr);
+out_free_rq:
+	pci_free_consistent(adapter->pdev, rq_size, prq, hostrq_phys_addr);
+	return err;
+}
+
+static void
+nx_fw_cmd_destroy_rx_ctx(struct netxen_adapter *adapter)
+{
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx[0];
+
+	if (netxen_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			NXHAL_VERSION,
+			recv_ctx->context_id,
+			NX_DESTROY_CTX_RESET,
+			0,
+			NX_CDRP_CMD_DESTROY_RX_CTX)) {
+
+		printk(KERN_WARNING
+			"%s: Failed to destroy rx ctx in firmware\n",
+			netxen_nic_driver_name);
+	}
+}
+
+static int
+nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
+{
+	nx_hostrq_tx_ctx_t	*prq;
+	nx_hostrq_cds_ring_t	*prq_cds;
+	nx_cardrsp_tx_ctx_t	*prsp;
+	void	*rq_addr, *rsp_addr;
+	size_t	rq_size, rsp_size;
+	u32	temp;
+	int	err = 0;
+	u64	offset, phys_addr;
+	dma_addr_t	rq_phys_addr, rsp_phys_addr;
+
+	rq_size = SIZEOF_HOSTRQ_TX(nx_hostrq_tx_ctx_t);
+	rq_addr = pci_alloc_consistent(adapter->pdev,
+		rq_size, &rq_phys_addr);
+	if (!rq_addr)
+		return -ENOMEM;
+
+	rsp_size = SIZEOF_CARDRSP_TX(nx_cardrsp_tx_ctx_t);
+	rsp_addr = pci_alloc_consistent(adapter->pdev,
+		rsp_size, &rsp_phys_addr);
+	if (!rsp_addr) {
+		err = -ENOMEM;
+		goto out_free_rq;
+	}
+
+	memset(rq_addr, 0, rq_size);
+	prq = (nx_hostrq_tx_ctx_t *)rq_addr;
+
+	memset(rsp_addr, 0, rsp_size);
+	prsp = (nx_cardrsp_tx_ctx_t *)rsp_addr;
+
+	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
+
+	temp = (NX_CAP0_LEGACY_CONTEXT | NX_CAP0_LEGACY_MN | NX_CAP0_LSO);
+	prq->capabilities[0] = cpu_to_le32(temp);
+
+	prq->host_int_crb_mode =
+		cpu_to_le32(NX_HOST_INT_CRB_MODE_SHARED);
+
+	prq->interrupt_ctl = 0;
+	prq->msi_index = 0;
+
+	prq->dummy_dma_addr = cpu_to_le64(adapter->dummy_dma.phys_addr);
+
+	offset = adapter->ctx_desc_phys_addr+sizeof(struct netxen_ring_ctx);
+	prq->cmd_cons_dma_addr = cpu_to_le64(offset);
+
+	prq_cds = &prq->cds_ring;
+
+	prq_cds->host_phys_addr =
+		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
+
+	prq_cds->ring_size = cpu_to_le32(adapter->max_tx_desc_count);
+
+	phys_addr = rq_phys_addr;
+	err = netxen_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			NXHAL_VERSION,
+			(u32)(phys_addr >> 32),
+			((u32)phys_addr & 0xffffffff),
+			rq_size,
+			NX_CDRP_CMD_CREATE_TX_CTX);
+
+	if (err == NX_RCODE_SUCCESS) {
+		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
+		adapter->crb_addr_cmd_producer =
+			NETXEN_NIC_REG(temp - 0x200);
+#if 0
+		adapter->tx_state =
+			le32_to_cpu(prsp->host_ctx_state);
+#endif
+		adapter->tx_context_id =
+			le16_to_cpu(prsp->context_id);
+	} else {
+		printk(KERN_WARNING
+			"Failed to create tx ctx in firmware%d\n", err);
+		err = -EIO;
+	}
+
+	pci_free_consistent(adapter->pdev, rsp_size, rsp_addr, rsp_phys_addr);
+
+out_free_rq:
+	pci_free_consistent(adapter->pdev, rq_size, rq_addr, rq_phys_addr);
+
+	return err;
+}
+
+static void
+nx_fw_cmd_destroy_tx_ctx(struct netxen_adapter *adapter)
+{
+	if (netxen_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			NXHAL_VERSION,
+			adapter->tx_context_id,
+			NX_DESTROY_CTX_RESET,
+			0,
+			NX_CDRP_CMD_DESTROY_TX_CTX)) {
+
+		printk(KERN_WARNING
+			"%s: Failed to destroy tx ctx in firmware\n",
+			netxen_nic_driver_name);
+	}
+}
+
+static u64 ctx_addr_sig_regs[][3] = {
+	{NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
+	{NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
+	{NETXEN_NIC_REG(0x198), NETXEN_NIC_REG(0x19c), NETXEN_NIC_REG(0x1c8)},
+	{NETXEN_NIC_REG(0x1a0), NETXEN_NIC_REG(0x1a4), NETXEN_NIC_REG(0x1cc)}
+};
+
+#define CRB_CTX_ADDR_REG_LO(FUNC_ID)	(ctx_addr_sig_regs[FUNC_ID][0])
+#define CRB_CTX_ADDR_REG_HI(FUNC_ID)	(ctx_addr_sig_regs[FUNC_ID][2])
+#define CRB_CTX_SIGNATURE_REG(FUNC_ID)	(ctx_addr_sig_regs[FUNC_ID][1])
+
+#define lower32(x)	((u32)((x) & 0xffffffff))
+#define upper32(x)	((u32)(((u64)(x) >> 32) & 0xffffffff))
+
+static struct netxen_recv_crb recv_crb_registers[] = {
+	/* Instance 0 */
+	{
+		/* crb_rcv_producer: */
+		{
+			NETXEN_NIC_REG(0x100),
+			/* Jumbo frames */
+			NETXEN_NIC_REG(0x110),
+			/* LRO */
+			NETXEN_NIC_REG(0x120)
+		},
+		/* crb_sts_consumer: */
+		NETXEN_NIC_REG(0x138),
+	},
+	/* Instance 1 */
+	{
+		/* crb_rcv_producer: */
+		{
+			NETXEN_NIC_REG(0x144),
+			/* Jumbo frames */
+			NETXEN_NIC_REG(0x154),
+			/* LRO */
+			NETXEN_NIC_REG(0x164)
+		},
+		/* crb_sts_consumer: */
+		NETXEN_NIC_REG(0x17c),
+	},
+	/* Instance 2 */
+	{
+		/* crb_rcv_producer: */
+		{
+			NETXEN_NIC_REG(0x1d8),
+			/* Jumbo frames */
+			NETXEN_NIC_REG(0x1f8),
+			/* LRO */
+			NETXEN_NIC_REG(0x208)
+		},
+		/* crb_sts_consumer: */
+		NETXEN_NIC_REG(0x220),
+	},
+	/* Instance 3 */
+	{
+		/* crb_rcv_producer: */
+		{
+			NETXEN_NIC_REG(0x22c),
+			/* Jumbo frames */
+			NETXEN_NIC_REG(0x23c),
+			/* LRO */
+			NETXEN_NIC_REG(0x24c)
+		},
+		/* crb_sts_consumer: */
+		NETXEN_NIC_REG(0x264),
+	},
+};
+
+static int
+netxen_init_old_ctx(struct netxen_adapter *adapter)
+{
+	struct netxen_recv_context *recv_ctx;
+	struct nx_host_rds_ring *rds_ring;
+	int ctx, ring;
+	int func_id = adapter->portnum;
+
+	adapter->ctx_desc->cmd_ring_addr =
+		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
+	adapter->ctx_desc->cmd_ring_size =
+		cpu_to_le32(adapter->max_tx_desc_count);
+
+	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
+		recv_ctx = &adapter->recv_ctx[ctx];
+
+		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+			rds_ring = &recv_ctx->rds_rings[ring];
+
+			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
+				cpu_to_le64(rds_ring->phys_addr);
+			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
+				cpu_to_le32(rds_ring->max_rx_desc_count);
+		}
+		adapter->ctx_desc->sts_ring_addr =
+			cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
+		adapter->ctx_desc->sts_ring_size =
+			cpu_to_le32(adapter->max_rx_desc_count);
+	}
+
+	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
+			lower32(adapter->ctx_desc_phys_addr));
+	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_HI(func_id),
+			upper32(adapter->ctx_desc_phys_addr));
+	adapter->pci_write_normalize(adapter, CRB_CTX_SIGNATURE_REG(func_id),
+			NETXEN_CTX_SIGNATURE | func_id);
+	return 0;
+}
+
+static uint32_t sw_int_mask[4] = {
+	CRB_SW_INT_MASK_0, CRB_SW_INT_MASK_1,
+	CRB_SW_INT_MASK_2, CRB_SW_INT_MASK_3
+};
+
+int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
+{
+	struct netxen_hardware_context *hw = &adapter->ahw;
+	u32 state = 0;
+	void *addr;
+	int err = 0;
+	int ctx, ring;
+	struct netxen_recv_context *recv_ctx;
+	struct nx_host_rds_ring *rds_ring;
+
+	err = netxen_receive_peg_ready(adapter);
+	if (err) {
+		printk(KERN_ERR "Rcv Peg initialization not complete:%x.\n",
+				state);
+		return err;
+	}
+
+	addr = pci_alloc_consistent(adapter->pdev,
+			sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
+			&adapter->ctx_desc_phys_addr);
+
+	if (addr == NULL) {
+		DPRINTK(ERR, "failed to allocate hw context\n");
+		return -ENOMEM;
+	}
+	memset(addr, 0, sizeof(struct netxen_ring_ctx));
+	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
+	adapter->ctx_desc->ctx_id = cpu_to_le32(adapter->portnum);
+	adapter->ctx_desc->cmd_consumer_offset =
+		cpu_to_le64(adapter->ctx_desc_phys_addr +
+			sizeof(struct netxen_ring_ctx));
+	adapter->cmd_consumer =
+		(__le32 *)(((char *)addr) + sizeof(struct netxen_ring_ctx));
+
+	/* cmd desc ring */
+	addr = pci_alloc_consistent(adapter->pdev,
+			sizeof(struct cmd_desc_type0) *
+			adapter->max_tx_desc_count,
+			&hw->cmd_desc_phys_addr);
+
+	if (addr == NULL) {
+		printk(KERN_ERR "%s failed to allocate tx desc ring\n",
+				netxen_nic_driver_name);
+		return -ENOMEM;
+	}
+
+	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
+
+	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
+		recv_ctx = &adapter->recv_ctx[ctx];
+
+		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+			/* rx desc ring */
+			rds_ring = &recv_ctx->rds_rings[ring];
+			addr = pci_alloc_consistent(adapter->pdev,
+					RCV_DESC_RINGSIZE,
+					&rds_ring->phys_addr);
+			if (addr == NULL) {
+				printk(KERN_ERR "%s failed to allocate rx "
+					"desc ring[%d]\n",
+					netxen_nic_driver_name, ring);
+				err = -ENOMEM;
+				goto err_out_free;
+			}
+			rds_ring->desc_head = (struct rcv_desc *)addr;
+
+			if (adapter->fw_major < 4)
+				rds_ring->crb_rcv_producer =
+					recv_crb_registers[adapter->portnum].
+					crb_rcv_producer[ring];
+		}
+
+		/* status desc ring */
+		addr = pci_alloc_consistent(adapter->pdev,
+				STATUS_DESC_RINGSIZE,
+				&recv_ctx->rcv_status_desc_phys_addr);
+		if (addr == NULL) {
+			printk(KERN_ERR "%s failed to allocate sts desc ring\n",
+					netxen_nic_driver_name);
+			err = -ENOMEM;
+			goto err_out_free;
+		}
+		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
+
+		if (adapter->fw_major < 4)
+			recv_ctx->crb_sts_consumer =
+				recv_crb_registers[adapter->portnum].
+				crb_sts_consumer;
+	}
+
+	if (adapter->fw_major >= 4) {
+		adapter->intr_scheme = INTR_SCHEME_PERPORT;
+		adapter->msi_mode = MSI_MODE_MULTIFUNC;
+
+		err = nx_fw_cmd_create_rx_ctx(adapter);
+		if (err)
+			goto err_out_free;
+		err = nx_fw_cmd_create_tx_ctx(adapter);
+		if (err)
+			goto err_out_free;
+	} else {
+
+		adapter->intr_scheme = adapter->pci_read_normalize(adapter,
+				CRB_NIC_CAPABILITIES_FW);
+		adapter->msi_mode = adapter->pci_read_normalize(adapter,
+				CRB_NIC_MSI_MODE_FW);
+		adapter->crb_intr_mask = sw_int_mask[adapter->portnum];
+
+		err = netxen_init_old_ctx(adapter);
+		if (err) {
+			netxen_free_hw_resources(adapter);
+			return err;
+		}
+
+	}
+
+	return 0;
+
+err_out_free:
+	netxen_free_hw_resources(adapter);
+	return err;
+}
+
+void netxen_free_hw_resources(struct netxen_adapter *adapter)
+{
+	struct netxen_recv_context *recv_ctx;
+	struct nx_host_rds_ring *rds_ring;
+	int ctx, ring;
+
+	if (adapter->fw_major >= 4) {
+		nx_fw_cmd_destroy_tx_ctx(adapter);
+		nx_fw_cmd_destroy_rx_ctx(adapter);
+	}
+
+	if (adapter->ctx_desc != NULL) {
+		pci_free_consistent(adapter->pdev,
+				sizeof(struct netxen_ring_ctx) +
+				sizeof(uint32_t),
+				adapter->ctx_desc,
+				adapter->ctx_desc_phys_addr);
+		adapter->ctx_desc = NULL;
+	}
+
+	if (adapter->ahw.cmd_desc_head != NULL) {
+		pci_free_consistent(adapter->pdev,
+				sizeof(struct cmd_desc_type0) *
+				adapter->max_tx_desc_count,
+				adapter->ahw.cmd_desc_head,
+				adapter->ahw.cmd_desc_phys_addr);
+		adapter->ahw.cmd_desc_head = NULL;
+	}
+
+	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
+		recv_ctx = &adapter->recv_ctx[ctx];
+		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+			rds_ring = &recv_ctx->rds_rings[ring];
+
+			if (rds_ring->desc_head != NULL) {
+				pci_free_consistent(adapter->pdev,
+						RCV_DESC_RINGSIZE,
+						rds_ring->desc_head,
+						rds_ring->phys_addr);
+				rds_ring->desc_head = NULL;
+			}
+		}
+
+		if (recv_ctx->rcv_status_desc_head != NULL) {
+			pci_free_consistent(adapter->pdev,
+					STATUS_DESC_RINGSIZE,
+					recv_ctx->rcv_status_desc_head,
+					recv_ctx->rcv_status_desc_phys_addr);
+			recv_ctx->rcv_status_desc_head = NULL;
+		}
+	}
+}
+
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 7b51240..01ab31b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -262,17 +262,30 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				rds_ring->max_rx_desc_count =
 					adapter->max_rx_desc_count;
 				rds_ring->flags = RCV_DESC_NORMAL;
-				rds_ring->dma_size = RX_DMA_MAP_LEN;
-				rds_ring->skb_size = MAX_RX_BUFFER_LENGTH;
+				if (adapter->ahw.cut_through) {
+					rds_ring->dma_size =
+						NX_CT_DEFAULT_RX_BUF_LEN;
+					rds_ring->skb_size =
+						NX_CT_DEFAULT_RX_BUF_LEN;
+				} else {
+					rds_ring->dma_size = RX_DMA_MAP_LEN;
+					rds_ring->skb_size =
+						MAX_RX_BUFFER_LENGTH;
+				}
 				break;
 
 			case RCV_DESC_JUMBO:
 				rds_ring->max_rx_desc_count =
 					adapter->max_jumbo_rx_desc_count;
 				rds_ring->flags = RCV_DESC_JUMBO;
-				rds_ring->dma_size = RX_JUMBO_DMA_MAP_LEN;
+				if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+					rds_ring->dma_size =
+						NX_P3_RX_JUMBO_BUF_MAX_LEN;
+				else
+					rds_ring->dma_size =
+						NX_P2_RX_JUMBO_BUF_MAX_LEN;
 				rds_ring->skb_size =
-					MAX_RX_JUMBO_BUFFER_LENGTH;
+					rds_ring->dma_size + NET_IP_ALIGN;
 				break;
 
 			case RCV_RING_LRO:
@@ -294,6 +307,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				goto err_out;
 			}
 			memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
+			INIT_LIST_HEAD(&rds_ring->free_list);
 			rds_ring->begin_alloc = 0;
 			/*
 			 * Now go through all of them, set reference handles
@@ -302,6 +316,8 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			num_rx_bufs = rds_ring->max_rx_desc_count;
 			rx_buf = rds_ring->rx_buf_arr;
 			for (i = 0; i < num_rx_bufs; i++) {
+				list_add_tail(&rx_buf->list,
+						&rds_ring->free_list);
 				rx_buf->ref_handle = i;
 				rx_buf->state = NETXEN_BUFFER_FREE;
 				rx_buf++;
@@ -1137,15 +1153,47 @@ int netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	return 0;
 }
 
+static struct sk_buff *netxen_process_rxbuf(struct netxen_adapter *adapter,
+		struct nx_host_rds_ring *rds_ring, u16 index, u16 cksum)
+{
+	struct netxen_rx_buffer *buffer;
+	struct sk_buff *skb;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	pci_unmap_single(adapter->pdev, buffer->dma, rds_ring->dma_size,
+			PCI_DMA_FROMDEVICE);
+
+	skb = buffer->skb;
+	if (!skb)
+		goto no_skb;
+
+	if (likely(adapter->rx_csum && cksum == STATUS_CKSUM_OK)) {
+		adapter->stats.csummed++;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	} else
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->dev = adapter->netdev;
+
+	buffer->skb = NULL;
+
+no_skb:
+	buffer->state = NETXEN_BUFFER_FREE;
+	buffer->lro_current_frags = 0;
+	buffer->lro_expected_frags = 0;
+	list_add_tail(&buffer->list, &rds_ring->free_list);
+	return skb;
+}
+
 /*
  * netxen_process_rcv() send the received packet to the protocol stack.
  * and if the number of receives exceeds RX_BUFFERS_REFILL, then we
  * invoke the routine to send more rx buffers to the Phantom...
  */
 static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
-			       struct status_desc *desc)
+		struct status_desc *desc, struct status_desc *frag_desc)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
 	u64 sts_data = le64_to_cpu(desc->status_desc_data);
 	int index = netxen_get_sts_refhandle(sts_data);
@@ -1154,8 +1202,8 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	struct sk_buff *skb;
 	u32 length = netxen_get_sts_totallength(sts_data);
 	u32 desc_ctx;
+	u16 pkt_offset = 0, cksum;
 	struct nx_host_rds_ring *rds_ring;
-	int ret;
 
 	desc_ctx = netxen_get_sts_type(sts_data);
 	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
@@ -1191,41 +1239,52 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		}
 	}
 
-	pci_unmap_single(pdev, buffer->dma, rds_ring->dma_size,
-			 PCI_DMA_FROMDEVICE);
-
-	skb = (struct sk_buff *)buffer->skb;
+	cksum = netxen_get_sts_status(sts_data);
 
-	if (likely(adapter->rx_csum &&
-			netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
-		adapter->stats.csummed++;
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else
-		skb->ip_summed = CHECKSUM_NONE;
+	skb = netxen_process_rxbuf(adapter, rds_ring, index, cksum);
+	if (!skb)
+		return;
 
-	skb->dev = netdev;
 	if (desc_ctx == RCV_DESC_LRO_CTXID) {
 		/* True length was only available on the last pkt */
 		skb_put(skb, buffer->lro_length);
 	} else {
-		skb_put(skb, length);
+		if (length > rds_ring->skb_size)
+			skb_put(skb, rds_ring->skb_size);
+		else
+			skb_put(skb, length);
+
+		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
+		if (pkt_offset)
+			skb_pull(skb, pkt_offset);
 	}
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	ret = netif_receive_skb(skb);
-	netdev->last_rx = jiffies;
-
 	/*
-	 * We just consumed one buffer so post a buffer.
+	 * rx buffer chaining is disabled, walk and free
+	 * any spurious rx buffer chain.
 	 */
-	buffer->skb = NULL;
-	buffer->state = NETXEN_BUFFER_FREE;
-	buffer->lro_current_frags = 0;
-	buffer->lro_expected_frags = 0;
+	if (frag_desc) {
+		u16 i, nr_frags = desc->nr_frags;
+
+		dev_kfree_skb_any(skb);
+		for (i = 0; i < nr_frags; i++) {
+			index = frag_desc->frag_handles[i];
+			skb = netxen_process_rxbuf(adapter,
+					rds_ring, index, cksum);
+			if (skb)
+				dev_kfree_skb_any(skb);
+		}
+		adapter->stats.rxdropped++;
+	} else {
 
-	adapter->stats.no_rcv++;
-	adapter->stats.rxbytes += length;
+		netif_receive_skb(skb);
+		netdev->last_rx = jiffies;
+
+		adapter->stats.no_rcv++;
+		adapter->stats.rxbytes += length;
+	}
 }
 
 /* Process Receive status ring */
@@ -1233,9 +1292,11 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 {
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
-	struct status_desc *desc;	/* used to read status desc here */
+	struct status_desc *desc, *frag_desc;
 	u32 consumer = recv_ctx->status_rx_consumer;
 	int count = 0, ring;
+	u64 sts_data;
+	u16 opcode;
 
 	while (count < max) {
 		desc = &desc_head[consumer];
@@ -1244,9 +1305,26 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 				netxen_get_sts_owner(desc));
 			break;
 		}
-		netxen_process_rcv(adapter, ctxid, desc);
+
+		sts_data = le64_to_cpu(desc->status_desc_data);
+		opcode = netxen_get_sts_opcode(sts_data);
+		frag_desc = NULL;
+		if (opcode == NETXEN_NIC_RXPKT_DESC) {
+			if (desc->nr_frags) {
+				consumer = get_next_index(consumer,
+						adapter->max_rx_desc_count);
+				frag_desc = &desc_head[consumer];
+				netxen_set_sts_owner(frag_desc,
+						STATUS_OWNER_PHANTOM);
+			}
+		}
+
+		netxen_process_rcv(adapter, ctxid, desc, frag_desc);
+
 		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
-		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
+
+		consumer = get_next_index(consumer,
+				adapter->max_rx_desc_count);
 		count++;
 	}
 	for (ring = 0; ring < adapter->max_rds_rings; ring++)
@@ -1348,36 +1426,31 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	int index = 0;
 	netxen_ctx_msg msg = 0;
 	dma_addr_t dma;
+	struct list_head *head;
 
 	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
 	index = rds_ring->begin_alloc;
-	buffer = &rds_ring->rx_buf_arr[index];
+	head = &rds_ring->free_list;
+
 	/* We can start writing rx descriptors into the phantom memory. */
-	while (buffer->state == NETXEN_BUFFER_FREE) {
+	while (!list_empty(head)) {
+
 		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
-			/*
-			 * TODO
-			 * We need to schedule the posting of buffers to the pegs.
-			 */
 			rds_ring->begin_alloc = index;
-			DPRINTK(ERR, "netxen_post_rx_buffers: "
-				" allocated only %d buffers\n", count);
 			break;
 		}
 
+		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
+		list_del(&buffer->list);
+
 		count++;	/* now there should be no failure */
 		pdesc = &rds_ring->desc_head[producer];
 
-#if defined(XGB_DEBUG)
-		*(unsigned long *)(skb->head) = 0xc0debabe;
-		if (skb_is_nonlinear(skb)) {
-			printk("Allocated SKB @%p is nonlinear\n");
-		}
-#endif
-		skb_reserve(skb, 2);
+		if (!adapter->ahw.cut_through)
+			skb_reserve(skb, 2);
 		/* This will be setup when we receive the
 		 * buffer after it has been filled  FSL  TBD TBD
 		 * skb->dev = netdev;
@@ -1395,7 +1468,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		producer =
 		    get_next_index(producer, rds_ring->max_rx_desc_count);
 		index = get_next_index(index, rds_ring->max_rx_desc_count);
-		buffer = &rds_ring->rx_buf_arr[index];
 	}
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
@@ -1439,32 +1511,29 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 	struct netxen_rx_buffer *buffer;
 	int count = 0;
 	int index = 0;
+	struct list_head *head;
 
 	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
 	index = rds_ring->begin_alloc;
-	buffer = &rds_ring->rx_buf_arr[index];
+	head = &rds_ring->free_list;
 	/* We can start writing rx descriptors into the phantom memory. */
-	while (buffer->state == NETXEN_BUFFER_FREE) {
+	while (!list_empty(head)) {
+
 		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
-			/*
-			 * We need to schedule the posting of buffers to the pegs.
-			 */
 			rds_ring->begin_alloc = index;
-			DPRINTK(ERR, "netxen_post_rx_buffers_nodb: "
-				" allocated only %d buffers\n", count);
 			break;
 		}
+
+		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
+		list_del(&buffer->list);
+
 		count++;	/* now there should be no failure */
 		pdesc = &rds_ring->desc_head[producer];
-		skb_reserve(skb, 2);
-		/*
-		 * This will be setup when we receive the
-		 * buffer after it has been filled
-		 * skb->dev = netdev;
-		 */
+		if (!adapter->ahw.cut_through)
+			skb_reserve(skb, 2);
 		buffer->skb = skb;
 		buffer->state = NETXEN_BUFFER_BUSY;
 		buffer->dma = pci_map_single(pdev, skb->data,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index df48f89..b3c084f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -844,17 +844,18 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* Handshake with the card before we register the devices. */
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 
-		if (NX_IS_REVISION_P3(revision_id)) {
-			adapter->hw_read_wx(adapter,
-					NETXEN_MIU_MN_CONTROL, &val, 4);
-			adapter->ahw.cut_through = (val & 0x4) ? 1 : 0;
-			dev_info(&pdev->dev, "firmware running in %s mode\n",
-			adapter->ahw.cut_through ? "cut through" : "legacy");
-		}
 	}	/* first_driver */
 
 	netxen_nic_flash_print(adapter);
 
+	if (NX_IS_REVISION_P3(revision_id)) {
+		adapter->hw_read_wx(adapter,
+				NETXEN_MIU_MN_CONTROL, &val, 4);
+		adapter->ahw.cut_through = (val & 0x4) ? 1 : 0;
+		dev_info(&pdev->dev, "firmware running in %s mode\n",
+		adapter->ahw.cut_through ? "cut through" : "legacy");
+	}
+
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
-- 
1.5.4.3

