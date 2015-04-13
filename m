From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next v2 2/4] cxgb4: add structure and macro definitions for FCoE DDP
Date: Mon, 13 Apr 2015 19:34:24 +0530
Message-ID: <bd322eb7d73398dbe6df96fc70b9b095aee4450e.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	kxie@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds new header file t4_tcb.h and
structure, macro definitions for FCoE DDP
support in cxgb4 driver.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h |   54 +++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |   29 +++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   59 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h     |   90 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h  |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    9 ++
 7 files changed, 250 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h
index bf9258a..458c696 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h
@@ -40,18 +40,70 @@
 #define CXGB_FCOE_TXPKT_CSUM_START	28
 #define CXGB_FCOE_TXPKT_CSUM_END	8
 
+#define CXGB_FCOE_ATID		13
+#define CXGB_FCOE_GET_XID(x)	((x) & 0x3FF)
+
+#define CXGB_FCOE_SHIFT_PORTID	11
+#define CXGB_FCOE_MASK_PORTID	0x3
+#define CXGB_FCOE_GET_PORTID(x)	\
+	(((x) >> CXGB_FCOE_SHIFT_PORTID) & CXGB_FCOE_MASK_PORTID)
+
+/* # of sentinel invalid page pods at the end of a group of valid page pods */
+#define CXGB_FCOE_NUM_SENTINEL_PPODS	0
+
+#define CXGB_FCOE_PPOD_SIZE		sizeof(struct pagepod)
+
+#define CXGB_FCOE_MAX_XCHGS_PORT	1024	/* Per netdev */
+#define CXGB_FCOE_MAX_PAGE_CNT		((10485760) / PAGE_SIZE)
+
+/* ddp flags */
+enum {
+	CXGB_FCOE_DDP_ERROR     = (1 << 0),
+	CXGB_FCOE_DDP_TID_VALID = (1 << 1),
+};
+
+struct cxgb_fcoe_ddp {
+	u8 h_source[ETH_ALEN];
+	u8 h_dest[ETH_ALEN];
+	unsigned int sgc;
+	struct scatterlist *sgl;
+	int ddp_len;
+	unsigned int tid;
+	unsigned int nppods;
+	unsigned int npages;
+	unsigned int ppod_tag;
+	unsigned int first_pg_off;
+	unsigned int xfer_len;
+	u16 vlan_tci;
+	u16 xid;
+	u8 d_id[3];
+	u8 flags;
+	dma_addr_t *ppod_gl;
+};
+
 /* fcoe flags */
 enum {
 	CXGB_FCOE_ENABLED     = (1 << 0),
 };
 
 struct cxgb_fcoe {
-	u8	flags;
+	u8 flags;
+	struct completion *cmpl;
+	struct cxgb_fcoe_ddp ddp[CXGB_FCOE_MAX_XCHGS_PORT];
 };
 
 int cxgb_fcoe_enable(struct net_device *);
 int cxgb_fcoe_disable(struct net_device *);
 bool cxgb_fcoe_sof_eof_supported(struct adapter *, struct sk_buff *);
 
+void cxgb_fcoe_init_ddp(struct adapter *);
+void cxgb_fcoe_exit_ddp(struct adapter *);
+void cxgb_fcoe_cpl_act_open_rpl(struct adapter *, unsigned int,
+				unsigned int, unsigned int);
+int cxgb_fcoe_rx_handler(struct sge_rspq *, const __be64 *);
+void cxgb_fcoe_free_ppods(struct adapter *, unsigned int, unsigned int);
+int cxgb_fcoe_ddp_setup(struct net_device *, u16,
+			struct scatterlist *, unsigned int);
+int cxgb_fcoe_ddp_done(struct net_device *, u16);
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 #endif /* __CXGB4_FCOE_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 78ab4d4..412a740 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -218,6 +218,13 @@ struct cxgb4_virt_res {                      /* virtualized HW resources */
 	struct cxgb4_range qp;
 	struct cxgb4_range cq;
 	struct cxgb4_range ocq;
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	u8 *ppod_map;
+	u16 *tid2xid;
+	unsigned int toe_nppods;
+	unsigned int fcoe_nppods;
+	spinlock_t ppod_map_lock;	/* page pod map lock */
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 };
 
 #define OCQ_WIN_OFFSET(pdev, vres) \
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 380b15c..133e776 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -164,6 +164,35 @@ struct rsp_ctrl {
 #define QINTR_TIMER_IDX(x) ((x) << 1)
 #define QINTR_TIMER_IDX_GET(x) (((x) >> 1) & 0x7)
 
+/* # of pages a pagepod can hold without needing another pagepod */
+#define PPOD_PAGES 4U
+
+struct pagepod {
+	__be64 vld_tid_pgsz_tag_color;
+	__be64 len_offset;
+	__be64 rsvd;
+	__be64 addr[PPOD_PAGES + 1];
+};
+
+#define PPOD_COLOR_S    0
+#define PPOD_COLOR_V(x) ((x) << PPOD_COLOR_S)
+
+#define PPOD_TAG_S    6
+#define PPOD_TAG_V(x) ((x) << PPOD_TAG_S)
+
+#define PPOD_TID_S    32
+#define PPOD_TID_V(x) ((__u64)(x) << PPOD_TID_S)
+
+#define PPOD_VALID_S    56
+#define PPOD_VALID_V(x) ((__u64)(x) << PPOD_VALID_S)
+#define PPOD_VALID_F    PPOD_VALID_V(1ULL)
+
+#define PPOD_LEN_S    32
+#define PPOD_LEN_V(x) ((__u64)(x) << PPOD_LEN_S)
+
+#define PPOD_OFST_S    0
+#define PPOD_OFST_V(x) ((x) << PPOD_OFST_S)
+
 /*
  * Flash layout.
  */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 7e2137d..8142d4e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -74,6 +74,8 @@ enum {
 	CPL_PASS_ESTABLISH    = 0x41,
 	CPL_RX_DATA_DDP       = 0x42,
 	CPL_PASS_ACCEPT_REQ   = 0x44,
+	CPL_RX_FCOE_DDP       = 0x46,
+	CPL_FCOE_HDR          = 0x47,
 	CPL_TRACE_PKT_T5      = 0x48,
 	CPL_RX_ISCSI_DDP      = 0x49,
 
@@ -88,6 +90,7 @@ enum {
 
 	CPL_TRACE_PKT         = 0xB0,
 	CPL_ISCSI_DATA	      = 0xB2,
+	CPL_FCOE_DATA         = 0xB3,
 
 	CPL_FW4_MSG           = 0xC0,
 	CPL_FW4_PLD           = 0xC1,
@@ -227,6 +230,10 @@ struct work_request_hdr {
 #define TX_CHAN_S    2
 #define TX_CHAN_V(x) ((x) << TX_CHAN_S)
 
+#define NON_OFFLOAD_S    7
+#define NON_OFFLOAD_V(x) ((x) << NON_OFFLOAD_S)
+#define NON_OFFLOAD_F    NON_OFFLOAD_V(1U)
+
 #define ULP_MODE_S    8
 #define ULP_MODE_V(x) ((x) << ULP_MODE_S)
 
@@ -417,6 +424,11 @@ struct cpl_t5_act_open_req {
 	__be64 params;
 };
 
+/* cpl_t5_act_open_req.params field */
+#define AOPEN_FCOEMASK_S	0
+#define AOPEN_FCOEMASK_V(x)	((x) << AOPEN_FCOEMASK_S)
+#define AOPEN_FCOEMASK_F	AOPEN_FCOEMASK_V(1U)
+
 struct cpl_act_open_req6 {
 	WR_HDR;
 	union opcode_tid ot;
@@ -734,6 +746,44 @@ struct cpl_iscsi_hdr {
 #define ISCSI_DDP_V(x) ((x) << ISCSI_DDP_S)
 #define ISCSI_DDP_F    ISCSI_DDP_V(1U)
 
+struct cpl_fcoe_hdr {
+	struct rss_header rsshdr;
+	union opcode_tid ot;
+	__be16 oxid;
+	__be16 len;
+	__be32 rctl_fctl;
+	__u8 cs_ctl;
+	__u8 df_ctl;
+	__u8 sof;
+	__u8 eof;
+	__be16 seq_cnt;
+	__u8 seq_id;
+	__u8 type;
+	__be32 param;
+};
+
+/* cpl_fcoe_hdr.rctl_fctl fields */
+#define FCOE_FCHDR_RCTL_S	24
+#define FCOE_FCHDR_RCTL_M	0xff
+#define FCOE_FCHDR_RCTL_G(x)	\
+	(((x) >> FCOE_FCHDR_RCTL_S) & FCOE_FCHDR_RCTL_M)
+
+#define FCOE_FCHDR_FCTL_S	0
+#define FCOE_FCHDR_FCTL_M	0xffffff
+#define G_FCOE_FCHDR_FCTL(x)	\
+	(((x) >> FCOE_FCHDR_FCTL_S) & FCOE_FCHDR_FCTL_M)
+
+struct cpl_rx_fcoe_ddp {
+	struct rss_header rsshdr;
+	union opcode_tid ot;
+	__be16 rsvd;
+	__be16 len;
+	__be32 seq;
+	__be32 ddp_report;
+	__be32 ulp_crc;
+	__be32 ddpvld;
+};
+
 struct cpl_rx_data {
 	union opcode_tid ot;
 	__be16 rsvd;
@@ -1099,4 +1149,13 @@ struct ulp_mem_io {
 #define ULP_MEMIO_DATA_LEN_S    0
 #define ULP_MEMIO_DATA_LEN_V(x) ((x) << ULP_MEMIO_DATA_LEN_S)
 
+struct ulp_txpkt {
+	__be32 cmd_dest;
+	__be32 len;
+};
+
+/* ulp_txpkt.cmd_dest fields */
+#define ULP_TXPKT_DEST_S    16
+#define ULP_TXPKT_DEST_V(x) ((x) << ULP_TXPKT_DEST_S)
+
 #endif  /* __T4_MSG_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h b/drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h
new file mode 100644
index 0000000..1ccd7f3
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h
@@ -0,0 +1,90 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2015 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef _T4_TCB_DEFS_H
+#define _T4_TCB_DEFS_H
+
+/* 95:32 */
+#define TCB_T_FLAGS_W    1
+
+/* 105:96 */
+#define TCB_RSS_INFO_S    0
+#define TCB_RSS_INFO_M    0x3ffULL
+#define TCB_RSS_INFO_V(x) ((x) << TCB_RSS_INFO_S)
+
+/* 115:112 */
+#define TCB_T_STATE_W    3
+#define TCB_T_STATE_S    16
+#define TCB_T_STATE_M    0xfULL
+#define TCB_T_STATE_V(x) ((x) << TCB_T_STATE_S)
+
+/* 855:832 */
+#define TCB_RX_DDP_BUF0_OFFSET_W    26
+#define TCB_RX_DDP_BUF0_OFFSET_S    0
+#define TCB_RX_DDP_BUF0_OFFSET_M    0xffffffULL
+#define TCB_RX_DDP_BUF0_OFFSET_V(x) ((x) << TCB_RX_DDP_BUF0_OFFSET_S)
+
+/* 879:856 */
+#define TCB_RX_DDP_BUF0_LEN_S    24
+#define TCB_RX_DDP_BUF0_LEN_M    0xffffffULL
+#define TCB_RX_DDP_BUF0_LEN_V(x) ((__u64)(x) << TCB_RX_DDP_BUF0_LEN_S)
+
+/* 903:880 */
+#define TCB_RX_DDP_FLAGS_W    27
+
+/* 991:960 */
+#define TCB_RX_DDP_BUF0_TAG_W    30
+#define TCB_RX_DDP_BUF0_TAG_S    0
+#define TCB_RX_DDP_BUF0_TAG_M    0xffffffffULL
+#define TCB_RX_DDP_BUF0_TAG_V(x) ((x) << TCB_RX_DDP_BUF0_TAG_S)
+
+#define TF_NON_OFFLOAD_S    1
+#define TF_NON_OFFLOAD_V(x) ((x) << TF_NON_OFFLOAD_S)
+
+#define TF_DDP_INDICATE_OUT_S    16
+#define TF_DDP_INDICATE_OUT_V(x) ((x) << TF_DDP_INDICATE_OUT_S)
+
+#define TF_DDP_OFF_S    18
+#define TF_DDP_OFF_V(x) ((x) << TF_DDP_OFF_S)
+
+#define TF_DDP_BUF_INF_S    20
+#define TF_DDP_BUF_INF_V(x) ((x) << TF_DDP_BUF_INF_S)
+
+#define TF_DDP_BUF0_VALID_S    24
+#define TF_DDP_BUF0_VALID_V(x) ((x) << TF_DDP_BUF0_VALID_S)
+
+#define TF_DDP_BUF0_INDICATE_S    25
+#define TF_DDP_BUF0_INDICATE_V(x) ((x) << TF_DDP_BUF0_INDICATE_S)
+
+#endif /* _T4_TCB_DEFS_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index 19b2dcf..28a8d36 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -61,6 +61,9 @@
 #define SGE_TIMERREGS			6
 #define TIMERREG_COUNTER0_X		0
 
+/* Egress Context field values */
+#define IDXSIZE_UNIT_X			64
+
 /* T5 and later support a new BAR2-based doorbell mechanism for Egress Queues.
  * The User Doorbells are each 128 bytes in length with a Simple Doorbell at
  * offsets 8x and a Write Combining single 64-byte Egress Queue Unit
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 03fbfd1..0babf8e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -101,6 +101,7 @@ enum fw_wr_opcodes {
 	FW_RI_BIND_MW_WR               = 0x18,
 	FW_RI_FR_NSMR_WR               = 0x19,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
+	FW_POFCOE_ULPTX_WR	       = 0x43,
 	FW_LASTC2E_WR                  = 0x70
 };
 
@@ -631,6 +632,12 @@ struct fw_eth_tx_pkt_vm_wr {
 	__be16 vlantci;
 };
 
+struct fw_pofcoe_ulptx_wr {
+	__be32 op_pkd;
+	__be32 equiq_to_len16;
+	__u64  cookie;
+};
+
 #define FW_CMD_MAX_TIMEOUT 10000
 
 /*
@@ -985,6 +992,8 @@ enum fw_caps_config_fcoe {
 	FW_CAPS_CONFIG_FCOE_INITIATOR	= 0x00000001,
 	FW_CAPS_CONFIG_FCOE_TARGET	= 0x00000002,
 	FW_CAPS_CONFIG_FCOE_CTRL_OFLD	= 0x00000004,
+	FW_CAPS_CONFIG_POFCOE_INITIATOR = 0x00000008,
+	FW_CAPS_CONFIG_POFCOE_TARGET    = 0x00000010,
 };
 
 enum fw_memtype_cf {
-- 
1.7.1

