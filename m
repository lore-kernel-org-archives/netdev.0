From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 06/19] bnx2x, cnic, bnx2i: use new FW/HSI
Date: Wed, 6 Oct 2010 15:23:26 +0200
Message-ID: <1286371407.30552.30.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1170 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971Ab0JFNjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the new FW HSI blob and the relevant definitions without logic changes.
It also included code adaptation for new HSI. New features are not enabled.

New FW/HSI includes:
- Support for 57712 HW
- Future support for VF (not used)
- Improvements in FW interrupts scheme
- FW FCoE hooks (stubs for future usage)

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h             |  532 +++++-
 drivers/net/bnx2x/bnx2x_cmn.c         |  488 +++---
 drivers/net/bnx2x/bnx2x_cmn.h         |  256 ++-
 drivers/net/bnx2x/bnx2x_ethtool.c     |   20 +-
 drivers/net/bnx2x/bnx2x_fw_defs.h     |  819 ++++-----
 drivers/net/bnx2x/bnx2x_fw_file_hdr.h |    1 +
 drivers/net/bnx2x/bnx2x_hsi.h         | 1465 +++++++--------
 drivers/net/bnx2x/bnx2x_init.h        |   41 +
 drivers/net/bnx2x/bnx2x_init_ops.h    |  338 ++++
 drivers/net/bnx2x/bnx2x_link.c        |    3 +-
 drivers/net/bnx2x/bnx2x_main.c        | 3208 ++++++++++++++++++++-------------
 drivers/net/bnx2x/bnx2x_stats.c       |   12 +-
 drivers/net/cnic.c                    |  285 ++--
 drivers/net/cnic.h                    |   51 +-
 drivers/net/cnic_defs.h               |  456 +++---
 drivers/net/cnic_if.h                 |    2 +
 drivers/scsi/bnx2i/bnx2i.h            |    2 +
 drivers/scsi/bnx2i/bnx2i_hwi.c        |    3 +-
 firmware/Makefile                     |    4 +-
 19 files changed, 4764 insertions(+), 3222 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 64329c5..8b053e0 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -33,13 +33,11 @@
 #define BNX2X_NEW_NAPI
 
 
-
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
 #include "../cnic_if.h"
 #endif
 
-
 #ifdef BCM_CNIC
 #define BNX2X_MIN_MSIX_VEC_CNT 3
 #define BNX2X_MSIX_VEC_FP_START 2
@@ -129,16 +127,18 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 	} while (0)
 #endif
 
+#define bnx2x_mc_addr(ha)      ((ha)->addr)
 
 #define U64_LO(x)			(u32)(((u64)(x)) & 0xffffffff)
 #define U64_HI(x)			(u32)(((u64)(x)) >> 32)
 #define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))
 
 
-#define REG_ADDR(bp, offset)		(bp->regview + offset)
+#define REG_ADDR(bp, offset)		((bp->regview) + (offset))
 
 #define REG_RD(bp, offset)		readl(REG_ADDR(bp, offset))
 #define REG_RD8(bp, offset)		readb(REG_ADDR(bp, offset))
+#define REG_RD16(bp, offset)		readw(REG_ADDR(bp, offset))
 
 #define REG_WR(bp, offset, val)		writel((u32)val, REG_ADDR(bp, offset))
 #define REG_WR8(bp, offset, val)	writeb((u8)val, REG_ADDR(bp, offset))
@@ -160,6 +160,9 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 				 offset, len32); \
 	} while (0)
 
+#define REG_WR_DMAE_LEN(bp, offset, valp, len32) \
+	REG_WR_DMAE(bp, offset, valp, len32)
+
 #define VIRT_WR_DMAE_LEN(bp, data, addr, len32, le32_swap) \
 	do { \
 		memcpy(GUNZIP_BUF(bp), data, (len32) * 4); \
@@ -175,16 +178,52 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 					 offsetof(struct shmem2_region, field))
 #define SHMEM2_RD(bp, field)		REG_RD(bp, SHMEM2_ADDR(bp, field))
 #define SHMEM2_WR(bp, field, val)	REG_WR(bp, SHMEM2_ADDR(bp, field), val)
+#define MF_CFG_ADDR(bp, field)		(bp->common.mf_cfg_base + \
+					 offsetof(struct mf_cfg, field))
 
-#define MF_CFG_RD(bp, field)		SHMEM_RD(bp, mf_cfg.field)
-#define MF_CFG_WR(bp, field, val)	SHMEM_WR(bp, mf_cfg.field, val)
+#define MF_CFG_RD(bp, field)		REG_RD(bp, MF_CFG_ADDR(bp, field))
+#define MF_CFG_WR(bp, field, val)	REG_WR(bp,\
+					       MF_CFG_ADDR(bp, field), (val))
 
 #define EMAC_RD(bp, reg)		REG_RD(bp, emac_base + reg)
 #define EMAC_WR(bp, reg, val)		REG_WR(bp, emac_base + reg, val)
 
+/* SP SB indices */
+
+/* General SP events - stats query, cfc delete, etc  */
+#define HC_SP_INDEX_ETH_DEF_CONS		3
+
+/* EQ completions */
+#define HC_SP_INDEX_EQ_CONS			7
+
+/* iSCSI L2 */
+#define HC_SP_INDEX_ETH_ISCSI_CQ_CONS		5
+#define HC_SP_INDEX_ETH_ISCSI_RX_CQ_CONS	1
+
+/**
+ *  CIDs and CLIDs:
+ *  CLIDs below is a CLID for func 0, then the CLID for other
+ *  functions will be calculated by the formula:
+ *
+ *  FUNC_N_CLID_X = N * NUM_SPECIAL_CLIENTS + FUNC_0_CLID_X
+ *
+ */
+/* iSCSI L2 */
+#define BNX2X_ISCSI_ETH_CL_ID		17
+#define BNX2X_ISCSI_ETH_CID		17
+
+/** Additional rings budgeting */
+#ifdef BCM_CNIC
+#define CNIC_CONTEXT_USE		1
+#else
+#define CNIC_CONTEXT_USE		0
+#endif /* BCM_CNIC */
+
 #define AEU_IN_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR \
 	AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR
 
+#define SM_RX_ID			0
+#define SM_TX_ID			1
 
 /* fast path */
 
@@ -254,11 +293,21 @@ union db_prod {
 #define RX_SGE_MASK_LEN_MASK		(RX_SGE_MASK_LEN - 1)
 #define NEXT_SGE_MASK_ELEM(el)		(((el) + 1) & RX_SGE_MASK_LEN_MASK)
 
+union host_hc_status_block {
+	/* pointer to fp status block e1x */
+	struct host_hc_status_block_e1x *e1x_sb;
+};
 
 struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
-	struct host_status_block *status_blk;
+	union host_hc_status_block status_blk;
+	/* chip independed shortcuts into sb structure */
+	__le16			*sb_index_values;
+	__le16			*sb_running_index;
+	/* chip independed shortcut into rx_prods_offset memory */
+	u32			ustorm_rx_prods_offset;
+
 	dma_addr_t		status_blk_mapping;
 
 	struct sw_tx_bd		*tx_buf_ring;
@@ -288,10 +337,15 @@ struct bnx2x_fastpath {
 #define BNX2X_FP_STATE_OPEN		0xa0000
 #define BNX2X_FP_STATE_HALTING		0xb0000
 #define BNX2X_FP_STATE_HALTED		0xc0000
+#define BNX2X_FP_STATE_TERMINATING	0xd0000
+#define BNX2X_FP_STATE_TERMINATED	0xe0000
 
 	u8			index;	/* number in fp array */
 	u8			cl_id;	/* eth client id */
-	u8			sb_id;	/* status block number in HW */
+	u8			cl_qzone_id;
+	u8			fw_sb_id;	/* status block number in FW */
+	u8			igu_sb_id;	/* status block number in HW */
+	u32			cid;
 
 	union db_prod		tx_db;
 
@@ -301,8 +355,7 @@ struct bnx2x_fastpath {
 	u16			tx_bd_cons;
 	__le16			*tx_cons_sb;
 
-	__le16			fp_c_idx;
-	__le16			fp_u_idx;
+	__le16			fp_hc_idx;
 
 	u16			rx_bd_prod;
 	u16			rx_bd_cons;
@@ -312,7 +365,7 @@ struct bnx2x_fastpath {
 	/* The last maximal completed SGE */
 	u16			last_max_sge;
 	__le16			*rx_cons_sb;
-	__le16			*rx_bd_cons_sb;
+
 
 
 	unsigned long		tx_pkt,
@@ -356,6 +409,8 @@ struct bnx2x_fastpath {
 #define NUM_TX_BD			(TX_DESC_CNT * NUM_TX_RINGS)
 #define MAX_TX_BD			(NUM_TX_BD - 1)
 #define MAX_TX_AVAIL			(MAX_TX_DESC_CNT * NUM_TX_RINGS - 2)
+#define INIT_JUMBO_TX_RING_SIZE		MAX_TX_AVAIL
+#define INIT_TX_RING_SIZE		MAX_TX_AVAIL
 #define NEXT_TX_IDX(x)		((((x) & MAX_TX_DESC_CNT) == \
 				  (MAX_TX_DESC_CNT - 1)) ? (x) + 2 : (x) + 1)
 #define TX_BD(x)			((x) & MAX_TX_BD)
@@ -370,6 +425,8 @@ struct bnx2x_fastpath {
 #define MAX_RX_BD			(NUM_RX_BD - 1)
 #define MAX_RX_AVAIL			(MAX_RX_DESC_CNT * NUM_RX_RINGS - 2)
 #define MIN_RX_AVAIL			128
+#define INIT_JUMBO_RX_RING_SIZE		MAX_RX_AVAIL
+#define INIT_RX_RING_SIZE		MAX_RX_AVAIL
 #define NEXT_RX_IDX(x)		((((x) & RX_DESC_MASK) == \
 				  (MAX_RX_DESC_CNT - 1)) ? (x) + 3 : (x) + 1)
 #define RX_BD(x)			((x) & MAX_RX_BD)
@@ -420,11 +477,12 @@ struct bnx2x_fastpath {
 						 le32_to_cpu((bd)->addr_lo))
 #define BD_UNMAP_LEN(bd)		(le16_to_cpu((bd)->nbytes))
 
-
+#define BNX2X_DB_MIN_SHIFT		3	/* 8 bytes */
+#define BNX2X_DB_SHIFT			7	/* 128 bytes*/
 #define DPM_TRIGER_TYPE			0x40
 #define DOORBELL(bp, cid, val) \
 	do { \
-		writel((u32)(val), bp->doorbells + (BCM_PAGE_SIZE * (cid)) + \
+		writel((u32)(val), bp->doorbells + (bp->db_size * (cid)) + \
 		       DPM_TRIGER_TYPE); \
 	} while (0)
 
@@ -482,31 +540,15 @@ struct bnx2x_fastpath {
 #define BNX2X_RX_SUM_FIX(cqe) \
 	BNX2X_PRS_FLAG_OVERETH_IPV4(cqe->fast_path_cqe.pars_flags.flags)
 
-
-#define FP_USB_FUNC_OFF			(2 + 2*HC_USTORM_SB_NUM_INDICES)
-#define FP_CSB_FUNC_OFF			(2 + 2*HC_CSTORM_SB_NUM_INDICES)
-
-#define U_SB_ETH_RX_CQ_INDEX		HC_INDEX_U_ETH_RX_CQ_CONS
-#define U_SB_ETH_RX_BD_INDEX		HC_INDEX_U_ETH_RX_BD_CONS
-#define C_SB_ETH_TX_CQ_INDEX		HC_INDEX_C_ETH_TX_CQ_CONS
+#define U_SB_ETH_RX_CQ_INDEX		1
+#define U_SB_ETH_RX_BD_INDEX		2
+#define C_SB_ETH_TX_CQ_INDEX		5
 
 #define BNX2X_RX_SB_INDEX \
-	(&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_CQ_INDEX])
-
-#define BNX2X_RX_SB_BD_INDEX \
-	(&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_BD_INDEX])
-
-#define BNX2X_RX_SB_INDEX_NUM \
-		(((U_SB_ETH_RX_CQ_INDEX << \
-		   USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT) & \
-		  USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER) | \
-		 ((U_SB_ETH_RX_BD_INDEX << \
-		   USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT) & \
-		  USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER))
+	(&fp->sb_index_values[U_SB_ETH_RX_CQ_INDEX])
 
 #define BNX2X_TX_SB_INDEX \
-	(&fp->status_blk->c_status_block.index_values[C_SB_ETH_TX_CQ_INDEX])
-
+	(&fp->sb_index_values[C_SB_ETH_TX_CQ_INDEX])
 
 /* end of fast path */
 
@@ -553,10 +595,16 @@ struct bnx2x_common {
 
 	u32			shmem_base;
 	u32			shmem2_base;
+	u32			mf_cfg_base;
 
 	u32			hw_config;
 
 	u32			bc_ver;
+
+	u8			int_block;
+#define INT_BLOCK_HC			0
+	u8			chip_port_mode;
+#define CHIP_PORT_MODE_NONE			0x2
 };
 
 
@@ -590,27 +638,98 @@ struct bnx2x_port {
 
 /* end of port */
 
+/* e1h Classification CAM line allocations */
+enum {
+	CAM_ETH_LINE = 0,
+	CAM_ISCSI_ETH_LINE,
+	CAM_MAX_PF_LINE = CAM_ISCSI_ETH_LINE
+};
 
+#define BNX2X_VF_ID_INVALID	0xFF
 
-#ifdef BCM_CNIC
-#define MAX_CONTEXT			15
-#else
-#define MAX_CONTEXT			16
-#endif
+/*
+ * The total number of L2 queues, MSIX vectors and HW contexts (CIDs) is
+ * control by the number of fast-path status blocks supported by the
+ * device (HW/FW). Each fast-path status block (FP-SB) aka non-default
+ * status block represents an independent interrupts context that can
+ * serve a regular L2 networking queue. However special L2 queues such
+ * as the FCoE queue do not require a FP-SB and other components like
+ * the CNIC may consume FP-SB reducing the number of possible L2 queues
+ *
+ * If the maximum number of FP-SB available is X then:
+ * a. If CNIC is supported it consumes 1 FP-SB thus the max number of
+ *    regular L2 queues is Y=X-1
+ * b. in MF mode the actual number of L2 queues is Y= (X-1/MF_factor)
+ * c. If the FCoE L2 queue is supported the actual number of L2 queues
+ *    is Y+1
+ * d. The number of irqs (MSIX vectors) is either Y+1 (one extra for
+ *    slow-path interrupts) or Y+2 if CNIC is supported (one additional
+ *    FP interrupt context for the CNIC).
+ * e. The number of HW context (CID count) is always X or X+1 if FCoE
+ *    L2 queue is supported. the cid for the FCoE L2 queue is always X.
+ */
+
+#define FP_SB_MAX_E1x		16	/* fast-path interrupt contexts E1x */
+#define MAX_CONTEXT		FP_SB_MAX_E1x
+
+/*
+ * cid_cnt paramter below refers to the value returned by
+ * 'bnx2x_get_l2_cid_count()' routine
+ */
+
+/*
+ * The number of FP context allocated by the driver == max number of regular
+ * L2 queues + 1 for the FCoE L2 queue
+ */
+#define L2_FP_COUNT(cid_cnt)	((cid_cnt) - CNIC_CONTEXT_USE)
 
 union cdu_context {
 	struct eth_context eth;
 	char pad[1024];
 };
 
+/* CDU host DB constants */
+#define CDU_ILT_PAGE_SZ_HW	3
+#define CDU_ILT_PAGE_SZ		(4096 << CDU_ILT_PAGE_SZ_HW) /* 32K */
+#define ILT_PAGE_CIDS		(CDU_ILT_PAGE_SZ / sizeof(union cdu_context))
+
+#ifdef BCM_CNIC
+#define CNIC_ISCSI_CID_MAX	256
+#define CNIC_CID_MAX		(CNIC_ISCSI_CID_MAX)
+#define CNIC_ILT_LINES		DIV_ROUND_UP(CNIC_CID_MAX, ILT_PAGE_CIDS)
+#endif
+
+#define QM_ILT_PAGE_SZ_HW	3
+#define QM_ILT_PAGE_SZ		(4096 << QM_ILT_PAGE_SZ_HW) /* 32K */
+#define QM_CID_ROUND		1024
+
+#ifdef BCM_CNIC
+/* TM (timers) host DB constants */
+#define TM_ILT_PAGE_SZ_HW	2
+#define TM_ILT_PAGE_SZ		(4096 << TM_ILT_PAGE_SZ_HW) /* 16K */
+/* #define TM_CONN_NUM		(CNIC_STARTING_CID+CNIC_ISCSI_CXT_MAX) */
+#define TM_CONN_NUM		1024
+#define TM_ILT_SZ		(8 * TM_CONN_NUM)
+#define TM_ILT_LINES		DIV_ROUND_UP(TM_ILT_SZ, TM_ILT_PAGE_SZ)
+
+/* SRC (Searcher) host DB constants */
+#define SRC_ILT_PAGE_SZ_HW	3
+#define SRC_ILT_PAGE_SZ		(4096 << SRC_ILT_PAGE_SZ_HW) /* 32K */
+#define SRC_HASH_BITS		10
+#define SRC_CONN_NUM		(1 << SRC_HASH_BITS) /* 1024 */
+#define SRC_ILT_SZ		(sizeof(struct src_ent) * SRC_CONN_NUM)
+#define SRC_T2_SZ		SRC_ILT_SZ
+#define SRC_ILT_LINES		DIV_ROUND_UP(SRC_ILT_SZ, SRC_ILT_PAGE_SZ)
+#endif
+
 #define MAX_DMAE_C			8
 
 /* DMA memory not used in fastpath */
 struct bnx2x_slowpath {
-	union cdu_context		context[MAX_CONTEXT];
 	struct eth_stats_query		fw_stats;
 	struct mac_configuration_cmd	mac_config;
 	struct mac_configuration_cmd	mcast_config;
+	struct client_init_ramrod_data	client_init_data;
 
 	/* used by dmae command executer */
 	struct dmae_command		dmae[MAX_DMAE_C];
@@ -638,37 +757,71 @@ struct attn_route {
 	u32	sig[4];
 };
 
+struct iro {
+	u32 base;
+	u16 m1;
+	u16 m2;
+	u16 m3;
+	u16 size;
+};
+
+struct hw_context {
+	union cdu_context *vcxt;
+	dma_addr_t cxt_mapping;
+	size_t size;
+};
+
+/* forward */
+struct bnx2x_ilt;
+
 typedef enum {
 	BNX2X_RECOVERY_DONE,
 	BNX2X_RECOVERY_INIT,
 	BNX2X_RECOVERY_WAIT,
 } bnx2x_recovery_state_t;
 
+/**
+ * Event queue (EQ or event ring) MC hsi
+ * NUM_EQ_PAGES and EQ_DESC_CNT_PAGE must be power of 2
+ */
+#define NUM_EQ_PAGES		1
+#define EQ_DESC_CNT_PAGE	(BCM_PAGE_SIZE / sizeof(union event_ring_elem))
+#define EQ_DESC_MAX_PAGE	(EQ_DESC_CNT_PAGE - 1)
+#define NUM_EQ_DESC		(EQ_DESC_CNT_PAGE * NUM_EQ_PAGES)
+#define EQ_DESC_MASK		(NUM_EQ_DESC - 1)
+#define MAX_EQ_AVAIL		(EQ_DESC_MAX_PAGE * NUM_EQ_PAGES - 2)
+
+/* depends on EQ_DESC_CNT_PAGE being a power of 2 */
+#define NEXT_EQ_IDX(x)		((((x) & EQ_DESC_MAX_PAGE) == \
+				  (EQ_DESC_MAX_PAGE - 1)) ? (x) + 2 : (x) + 1)
+
+/* depends on the above and on NUM_EQ_PAGES being a power of 2 */
+#define EQ_DESC(x)		((x) & EQ_DESC_MASK)
+
+#define BNX2X_EQ_INDEX \
+	(&bp->def_status_blk->sp_sb.\
+	index_values[HC_SP_INDEX_EQ_CONS])
+
 struct bnx2x {
 	/* Fields used in the tx and intr/napi performance paths
 	 * are grouped together in the beginning of the structure
 	 */
-	struct bnx2x_fastpath	fp[MAX_CONTEXT];
+	struct bnx2x_fastpath	*fp;
 	void __iomem		*regview;
 	void __iomem		*doorbells;
-#ifdef BCM_CNIC
-#define BNX2X_DB_SIZE		(18*BCM_PAGE_SIZE)
-#else
-#define BNX2X_DB_SIZE		(16*BCM_PAGE_SIZE)
-#endif
+	u16			db_size;
 
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
 
+	struct iro		*iro_arr;
+#define IRO (bp->iro_arr)
+
 	atomic_t		intr_sem;
 
 	bnx2x_recovery_state_t	recovery_state;
 	int			is_leader;
-#ifdef BCM_CNIC
-	struct msix_entry	msix_table[MAX_CONTEXT+2];
-#else
-	struct msix_entry	msix_table[MAX_CONTEXT+1];
-#endif
+	struct msix_entry	*msix_table;
 #define INT_MODE_INTx			1
 #define INT_MODE_MSI			2
 
@@ -680,7 +833,8 @@ struct bnx2x {
 
 	u32			rx_csum;
 	u32			rx_buf_size;
-#define ETH_OVREHEAD			(ETH_HLEN + 8)	/* 8 for CRC + VLAN */
+/* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
+#define ETH_OVREHEAD		(ETH_HLEN + 8 + 8)
 #define ETH_MIN_PACKET_SIZE		60
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
@@ -689,13 +843,12 @@ struct bnx2x {
 #define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
 					 L1_CACHE_SHIFT : 8)
 #define BNX2X_RX_ALIGN			(1 << BNX2X_RX_ALIGN_SHIFT)
+#define BNX2X_PXP_DRAM_ALIGN		(BNX2X_RX_ALIGN_SHIFT - 5)
 
-	struct host_def_status_block *def_status_blk;
-#define DEF_SB_ID			16
-	__le16			def_c_idx;
-	__le16			def_u_idx;
-	__le16			def_x_idx;
-	__le16			def_t_idx;
+	struct host_sp_status_block *def_status_blk;
+#define DEF_SB_IGU_ID			16
+#define DEF_SB_ID			HC_SP_SB_ID
+	__le16			def_idx;
 	__le16			def_att_idx;
 	u32			attn_state;
 	struct attn_route	attn_group[MAX_DYNAMIC_ATTN_GRPS];
@@ -711,6 +864,13 @@ struct bnx2x {
 	/* used to synchronize spq accesses */
 	spinlock_t		spq_lock;
 
+	/* event queue */
+	union event_ring_elem	*eq_ring;
+	dma_addr_t		eq_mapping;
+	u16			eq_prod;
+	u16			eq_cons;
+	__le16			*eq_cons_sb;
+
 	/* Flags for marking that there is a STAT_QUERY or
 	   SET_MAC ramrod pending */
 	int			stats_pending;
@@ -737,6 +897,8 @@ struct bnx2x {
 #define MF_FUNC_DIS			0x1000
 
 	int			func;
+	int			base_fw_ndsb;
+
 #define BP_PORT(bp)			(bp->func % PORT_MAX)
 #define BP_FUNC(bp)			(bp->func)
 #define BP_E1HVN(bp)			(bp->func >> 1)
@@ -801,6 +963,7 @@ struct bnx2x {
 #define BNX2X_STATE_CLOSING_WAIT4_HALT	0x4000
 #define BNX2X_STATE_CLOSING_WAIT4_DELETE 0x5000
 #define BNX2X_STATE_CLOSING_WAIT4_UNLOAD 0x6000
+#define BNX2X_STATE_FUNC_STARTED	0x7000
 #define BNX2X_STATE_DIAG		0xe000
 #define BNX2X_STATE_ERROR		0xf000
 
@@ -809,6 +972,15 @@ struct bnx2x {
 	int			disable_tpa;
 	int			int_mode;
 
+	struct tstorm_eth_mac_filter_config	mac_filters;
+#define BNX2X_ACCEPT_NONE		0x0000
+#define BNX2X_ACCEPT_UNICAST		0x0001
+#define BNX2X_ACCEPT_MULTICAST		0x0002
+#define BNX2X_ACCEPT_ALL_UNICAST	0x0004
+#define BNX2X_ACCEPT_ALL_MULTICAST	0x0008
+#define BNX2X_ACCEPT_BROADCAST		0x0010
+#define BNX2X_PROMISCUOUS_MODE		0x10000
+
 	u32			rx_mode;
 #define BNX2X_RX_MODE_NONE		0
 #define BNX2X_RX_MODE_NORMAL		1
@@ -817,12 +989,25 @@ struct bnx2x {
 #define BNX2X_MAX_MULTICAST		64
 #define BNX2X_MAX_EMUL_MULTI		16
 
-	u32 			rx_mode_cl_mask;
-
+	u8			igu_dsb_id;
+	u8			igu_base_sb;
+	u8			igu_sb_cnt;
 	dma_addr_t		def_status_blk_mapping;
 
 	struct bnx2x_slowpath	*slowpath;
 	dma_addr_t		slowpath_mapping;
+	struct hw_context	context;
+
+	struct bnx2x_ilt	*ilt;
+#define BP_ILT(bp)		((bp)->ilt)
+#define ILT_MAX_LINES		128
+
+	int			l2_cid_count;
+#define L2_ILT_LINES(bp)	(DIV_ROUND_UP((bp)->l2_cid_count, \
+				 ILT_PAGE_CIDS))
+#define BNX2X_DB_SIZE(bp)	((bp)->l2_cid_count * (1 << BNX2X_DB_SHIFT))
+
+	int			qm_cid_count;
 
 	int			dropless_fc;
 
@@ -842,9 +1027,10 @@ struct bnx2x {
 	void			*cnic_data;
 	u32			cnic_tag;
 	struct cnic_eth_dev	cnic_eth_dev;
-	struct host_status_block *cnic_sb;
+	union host_hc_status_block cnic_sb;
 	dma_addr_t		cnic_sb_mapping;
-#define CNIC_SB_ID(bp)			BP_L_ID(bp)
+#define CNIC_SB_ID(bp)		((bp)->base_fw_ndsb + BP_L_ID(bp))
+#define CNIC_IGU_SB_ID(bp)	((bp)->igu_base_sb)
 	struct eth_spe		*cnic_kwq;
 	struct eth_spe		*cnic_kwq_prod;
 	struct eth_spe		*cnic_kwq_cons;
@@ -914,12 +1100,167 @@ struct bnx2x {
 	const struct firmware	*firmware;
 };
 
+/**
+ *	Init queue/func interface
+ */
+/* queue init flags */
+#define QUEUE_FLG_TPA		0x0001
+#define QUEUE_FLG_CACHE_ALIGN	0x0002
+#define QUEUE_FLG_STATS		0x0004
+#define QUEUE_FLG_OV		0x0008
+#define QUEUE_FLG_VLAN		0x0010
+#define QUEUE_FLG_COS		0x0020
+#define QUEUE_FLG_HC		0x0040
+#define QUEUE_FLG_DHC		0x0080
+#define QUEUE_FLG_OOO		0x0100
+
+#define QUEUE_DROP_IP_CS_ERR	TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR
+#define QUEUE_DROP_TCP_CS_ERR	TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR
+#define QUEUE_DROP_TTL0		TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0
+#define QUEUE_DROP_UDP_CS_ERR	TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR
+
+
+
+/* rss capabilities */
+#define RSS_IPV4_CAP		0x0001
+#define RSS_IPV4_TCP_CAP	0x0002
+#define RSS_IPV6_CAP		0x0004
+#define RSS_IPV6_TCP_CAP	0x0008
 
 #define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT/E1HVN_MAX) \
 					      : MAX_CONTEXT)
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
 
+
+#define RSS_IPV4_CAP_MASK						\
+	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY
+
+#define RSS_IPV4_TCP_CAP_MASK						\
+	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY
+
+#define RSS_IPV6_CAP_MASK						\
+	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY
+
+#define RSS_IPV6_TCP_CAP_MASK						\
+	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY
+
+/* func init flags */
+#define FUNC_FLG_RSS		0x0001
+#define FUNC_FLG_STATS		0x0002
+/* removed  FUNC_FLG_UNMATCHED	0x0004 */
+#define FUNC_FLG_TPA		0x0008
+#define FUNC_FLG_SPQ		0x0010
+#define FUNC_FLG_LEADING	0x0020	/* PF only */
+
+#define FUNC_CONFIG(flgs)	((flgs) & (FUNC_FLG_RSS | FUNC_FLG_TPA | \
+					FUNC_FLG_LEADING))
+
+struct rxq_pause_params {
+	u16		bd_th_lo;
+	u16		bd_th_hi;
+	u16		rcq_th_lo;
+	u16		rcq_th_hi;
+	u16		sge_th_lo; /* valid iff QUEUE_FLG_TPA */
+	u16		sge_th_hi; /* valid iff QUEUE_FLG_TPA */
+	u16		pri_map;
+};
+
+struct bnx2x_rxq_init_params {
+	/* cxt*/
+	struct eth_context *cxt;
+
+	/* dma */
+	dma_addr_t	dscr_map;
+	dma_addr_t	sge_map;
+	dma_addr_t	rcq_map;
+	dma_addr_t	rcq_np_map;
+
+	u16		flags;
+	u16		drop_flags;
+	u16		mtu;
+	u16		buf_sz;
+	u16		fw_sb_id;
+	u16		cl_id;
+	u16		spcl_id;
+	u16		cl_qzone_id;
+
+	/* valid iff QUEUE_FLG_STATS */
+	u16		stat_id;
+
+	/* valid iff QUEUE_FLG_TPA */
+	u16		tpa_agg_sz;
+	u16		sge_buf_sz;
+	u16		max_sges_pkt;
+
+	/* valid iff QUEUE_FLG_CACHE_ALIGN */
+	u8		cache_line_log;
+
+	u8		sb_cq_index;
+	u32		cid;
+
+	/* desired interrupts per sec. valid iff QUEUE_FLG_HC */
+	u32		hc_rate;
+};
+
+struct bnx2x_txq_init_params {
+	/* cxt*/
+	struct eth_context *cxt;
+
+	/* dma */
+	dma_addr_t	dscr_map;
+
+	u16		flags;
+	u16		fw_sb_id;
+	u8		sb_cq_index;
+	u8		cos;		/* valid iff QUEUE_FLG_COS */
+	u16		stat_id;	/* valid iff QUEUE_FLG_STATS */
+	u16		traffic_type;
+	u32		cid;
+	u16		hc_rate;	/* desired interrupts per sec.*/
+					/* valid iff QUEUE_FLG_HC */
+
+};
+
+struct bnx2x_client_ramrod_params {
+	int *pstate;
+	int state;
+	u16 index;
+	u16 cl_id;
+	u32 cid;
+	u8 poll;
+#define CLIENT_IS_LEADING_RSS		0x02
+	u8 flags;
+};
+
+struct bnx2x_client_init_params {
+	struct rxq_pause_params pause;
+	struct bnx2x_rxq_init_params rxq_params;
+	struct bnx2x_txq_init_params txq_params;
+	struct bnx2x_client_ramrod_params ramrod_params;
+};
+
+struct bnx2x_rss_params {
+	int	mode;
+	u16	cap;
+	u16	result_mask;
+};
+
+struct bnx2x_func_init_params {
+
+	/* rss */
+	struct bnx2x_rss_params *rss;	/* valid iff FUNC_FLG_RSS */
+
+	/* dma */
+	dma_addr_t	fw_stat_map;	/* valid iff FUNC_FLG_STATS */
+	dma_addr_t	spq_map;	/* valid iff FUNC_FLG_SPQ */
+
+	u16		func_flgs;
+	u16		func_id;	/* abs fid */
+	u16		pf_id;
+	u16		spq_prod;	/* valid iff FUNC_FLG_SPQ */
+};
+
 #define for_each_queue(bp, var) \
 			for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++)
 #define for_each_nondefault_queue(bp, var) \
@@ -957,6 +1298,38 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 	return val;
 }
+#define BNX2X_ILT_ZALLOC(x, y, size) \
+	do { \
+		x = pci_alloc_consistent(bp->pdev, size, y); \
+		if (x) \
+			memset(x, 0, size); \
+	} while (0)
+
+#define BNX2X_ILT_FREE(x, y, size) \
+	do { \
+		if (x) { \
+			pci_free_consistent(bp->pdev, size, x, y); \
+			x = NULL; \
+			y = 0; \
+		} \
+	} while (0)
+
+#define ILOG2(x)	(ilog2((x)))
+
+#define ILT_NUM_PAGE_ENTRIES	(3072)
+/* In 57710/11 we use whole table since we have 8 func
+ */
+#define ILT_PER_FUNC		(ILT_NUM_PAGE_ENTRIES/8)
+
+#define FUNC_ILT_BASE(func)	(func * ILT_PER_FUNC)
+/*
+ * the phys address is shifted right 12 bits and has an added
+ * 1=valid bit added to the 53rd bit
+ * then since this is a wide register(TM)
+ * we split it into two 32 bit writes
+ */
+#define ONCHIP_ADDR1(x)		((u32)(((u64)x >> 12) & 0xFFFFFFFF))
+#define ONCHIP_ADDR2(x)		((u32)((1 << 20) | ((u64)x >> 44)))
 
 
 /* load/unload mode */
@@ -1032,7 +1405,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define MAX_SP_DESC_CNT			(SP_DESC_CNT - 1)
 
 
-#define BNX2X_BTR			1
+#define BNX2X_BTR			4
 #define MAX_SPQ_PENDING			8
 
 
@@ -1149,20 +1522,22 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 		  TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT))
 #define MULTI_MASK			0x7f
 
-
-#define DEF_USB_FUNC_OFF		(2 + 2*HC_USTORM_DEF_SB_NUM_INDICES)
-#define DEF_CSB_FUNC_OFF		(2 + 2*HC_CSTORM_DEF_SB_NUM_INDICES)
-#define DEF_XSB_FUNC_OFF		(2 + 2*HC_XSTORM_DEF_SB_NUM_INDICES)
-#define DEF_TSB_FUNC_OFF		(2 + 2*HC_TSTORM_DEF_SB_NUM_INDICES)
-
-#define C_DEF_SB_SP_INDEX		HC_INDEX_DEF_C_ETH_SLOW_PATH
-
 #define BNX2X_SP_DSB_INDEX \
-(&bp->def_status_blk->c_def_status_block.index_values[C_DEF_SB_SP_INDEX])
+		(&bp->def_status_blk->sp_sb.\
+					index_values[HC_SP_INDEX_ETH_DEF_CONS])
+#define SET_FLAG(value, mask, flag) \
+	do {\
+		(value) &= ~(mask);\
+		(value) |= ((flag) << (mask##_SHIFT));\
+	} while (0)
 
+#define GET_FLAG(value, mask) \
+	(((value) &= (mask)) >> (mask##_SHIFT))
 
 #define CAM_IS_INVALID(x) \
-(x.target_table_entry.flags == TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE)
+	(GET_FLAG(x.flags, \
+	MAC_CONFIGURATION_ENTRY_ACTION_TYPE) == \
+	(T_ETH_MAC_COMMAND_INVALIDATE))
 
 #define CAM_INVALIDATE(x) \
 	(x.target_table_entry.flags = TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE)
@@ -1181,6 +1556,14 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_VPD_LEN			128
 #define VENDOR_ID_LEN			4
 
+/* Congestion management fairness mode */
+#define CMNG_FNS_NONE		0
+#define CMNG_FNS_MINMAX		1
+
+#define HC_SEG_ACCESS_DEF		0   /*Driver decision 0-3*/
+#define HC_SEG_ACCESS_ATTN		4
+#define HC_SEG_ACCESS_NORM		0   /*Driver decision 0-1*/
+
 #ifdef BNX2X_MAIN
 #define BNX2X_EXTERN
 #else
@@ -1195,4 +1578,9 @@ extern void bnx2x_set_ethtool_ops(struct net_device *netdev);
 
 void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx);
 
+#define WAIT_RAMROD_POLL	0x01
+#define WAIT_RAMROD_COMMON	0x02
+
+int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
+			     int *state_p, int flags);
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 8d42067..bcc4a8f 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -27,6 +27,8 @@
 #include <linux/if_vlan.h>
 #endif
 
+#include "bnx2x_init.h"
+
 static int bnx2x_poll(struct napi_struct *napi, int budget);
 
 /* free skb in the packet ring at pos idx
@@ -190,14 +192,16 @@ static void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
 
 	/* First mark all used pages */
 	for (i = 0; i < sge_len; i++)
-		SGE_MASK_CLEAR_BIT(fp, RX_SGE(le16_to_cpu(fp_cqe->sgl[i])));
+		SGE_MASK_CLEAR_BIT(fp,
+			RX_SGE(le16_to_cpu(fp_cqe->sgl_or_raw_data.sgl[i])));
 
 	DP(NETIF_MSG_RX_STATUS, "fp_cqe->sgl[%d] = %d\n",
-	   sge_len - 1, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
+	   sge_len - 1, le16_to_cpu(fp_cqe->sgl_or_raw_data.sgl[sge_len - 1]));
 
 	/* Here we assume that the last SGE index is the biggest */
 	prefetch((void *)(fp->sge_mask));
-	bnx2x_update_last_max_sge(fp, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
+	bnx2x_update_last_max_sge(fp,
+		le16_to_cpu(fp_cqe->sgl_or_raw_data.sgl[sge_len - 1]));
 
 	last_max = RX_SGE(fp->last_max_sge);
 	last_elem = last_max >> RX_SGE_MASK_ELEM_SHIFT;
@@ -298,7 +302,8 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* Run through the SGL and compose the fragmented skb */
 	for (i = 0, j = 0; i < pages; i += PAGES_PER_SGE, j++) {
-		u16 sge_idx = RX_SGE(le16_to_cpu(fp_cqe->sgl[j]));
+		u16 sge_idx =
+			RX_SGE(le16_to_cpu(fp_cqe->sgl_or_raw_data.sgl[j]));
 
 		/* FW gives the indices of the SGE as if the ring is an array
 		   (meaning that "next" element will consume 2 indices) */
@@ -394,8 +399,9 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		if (!bnx2x_fill_frag_skb(bp, fp, skb,
 					 &cqe->fast_path_cqe, cqe_idx)) {
 #ifdef BCM_VLAN
-			if ((bp->vlgrp != NULL) && is_vlan_cqe &&
-			    (!is_not_hwaccel_vlan_cqe))
+			if ((bp->vlgrp != NULL) &&
+				(le16_to_cpu(cqe->fast_path_cqe.
+				pars_flags.flags) & PARSING_FLAGS_VLAN))
 				vlan_gro_receive(&fp->napi, bp->vlgrp,
 						 le16_to_cpu(cqe->fast_path_cqe.
 							     vlan_tag), skb);
@@ -686,9 +692,10 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 		return IRQ_HANDLED;
 	}
 
-	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
-	   fp->index, fp->sb_id);
-	bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
+	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB "
+			 "[fp %d fw_sd %d igusb %d]\n",
+	   fp->index, fp->fw_sb_id, fp->igu_sb_id);
+	bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -698,8 +705,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	/* Handle Rx and Tx according to MSI-X vector */
 	prefetch(fp->rx_cons_sb);
 	prefetch(fp->tx_cons_sb);
-	prefetch(&fp->status_blk->u_status_block.status_block_index);
-	prefetch(&fp->status_blk->c_status_block.status_block_index);
+	prefetch(&fp->sb_running_index[SM_RX_ID]);
 	napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 
 	return IRQ_HANDLED;
@@ -774,27 +780,73 @@ void bnx2x_link_report(struct bnx2x *bp)
 	}
 }
 
+/* Returns the number of actually allocated BDs */
+static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
+				      int rx_ring_size)
+{
+	struct bnx2x *bp = fp->bp;
+	u16 ring_prod, cqe_ring_prod;
+	int i;
+
+	fp->rx_comp_cons = 0;
+	cqe_ring_prod = ring_prod = 0;
+	for (i = 0; i < rx_ring_size; i++) {
+		if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
+			BNX2X_ERR("was only able to allocate "
+				  "%d rx skbs on queue[%d]\n", i, fp->index);
+			fp->eth_q_stats.rx_skb_alloc_failed++;
+			break;
+		}
+		ring_prod = NEXT_RX_IDX(ring_prod);
+		cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
+		WARN_ON(ring_prod <= i);
+	}
+
+	fp->rx_bd_prod = ring_prod;
+	/* Limit the CQE producer by the CQE ring size */
+	fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
+			       cqe_ring_prod);
+	fp->rx_pkt = fp->rx_calls = 0;
+
+	return i;
+}
+
+static inline void bnx2x_alloc_rx_bd_ring(struct bnx2x_fastpath *fp)
+{
+	struct bnx2x *bp = fp->bp;
+	int rx_ring_size = bp->rx_ring_size ? bp->rx_ring_size :
+					      MAX_RX_AVAIL/bp->num_queues;
+
+	rx_ring_size = max_t(int, MIN_RX_AVAIL, rx_ring_size);
+
+	bnx2x_alloc_rx_bds(fp, rx_ring_size);
+
+	/* Warning!
+	 * this will generate an interrupt (to the TSTORM)
+	 * must only be done after chip is initialized
+	 */
+	bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
+			     fp->rx_sge_prod);
+}
+
 void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
 	int max_agg_queues = CHIP_IS_E1(bp) ? ETH_MAX_AGGREGATION_QUEUES_E1 :
 					      ETH_MAX_AGGREGATION_QUEUES_E1H;
-	u16 ring_prod, cqe_ring_prod;
+	u16 ring_prod;
 	int i, j;
-	int rx_ring_size = bp->rx_ring_size ? bp->rx_ring_size :
-					      MAX_RX_AVAIL/bp->num_queues;
 
-	rx_ring_size = max_t(int, MIN_RX_AVAIL, rx_ring_size);
+	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN +
+		BNX2X_FW_IP_HDR_ALIGN_PAD;
 
-	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN;
 	DP(NETIF_MSG_IFUP,
 	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
 
-	if (bp->flags & TPA_ENABLE_FLAG) {
-
-		for_each_queue(bp, j) {
-			struct bnx2x_fastpath *fp = &bp->fp[j];
+	for_each_queue(bp, j) {
+		struct bnx2x_fastpath *fp = &bp->fp[j];
 
+		if (!fp->disable_tpa) {
 			for (i = 0; i < max_agg_queues; i++) {
 				fp->tpa_pool[i].skb =
 				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
@@ -812,6 +864,35 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 						   mapping, 0);
 				fp->tpa_state[i] = BNX2X_TPA_STOP;
 			}
+
+			/* "next page" elements initialization */
+			bnx2x_set_next_page_sgl(fp);
+
+			/* set SGEs bit mask */
+			bnx2x_init_sge_ring_bit_mask(fp);
+
+			/* Allocate SGEs and initialize the ring elements */
+			for (i = 0, ring_prod = 0;
+			     i < MAX_RX_SGE_CNT*NUM_RX_SGE_PAGES; i++) {
+
+				if (bnx2x_alloc_rx_sge(bp, fp, ring_prod) < 0) {
+					BNX2X_ERR("was only able to allocate "
+						  "%d rx sges\n", i);
+					BNX2X_ERR("disabling TPA for"
+						  " queue[%d]\n", j);
+					/* Cleanup already allocated elements */
+					bnx2x_free_rx_sge_range(bp,
+								fp, ring_prod);
+					bnx2x_free_tpa_pool(bp,
+							    fp, max_agg_queues);
+					fp->disable_tpa = 1;
+					ring_prod = 0;
+					break;
+				}
+				ring_prod = NEXT_SGE_IDX(ring_prod);
+			}
+
+			fp->rx_sge_prod = ring_prod;
 		}
 	}
 
@@ -819,98 +900,15 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		fp->rx_bd_cons = 0;
-		fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
-		fp->rx_bd_cons_sb = BNX2X_RX_SB_BD_INDEX;
-
-		/* "next page" elements initialization */
-		/* SGE ring */
-		for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
-			struct eth_rx_sge *sge;
-
-			sge = &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
-			sge->addr_hi =
-				cpu_to_le32(U64_HI(fp->rx_sge_mapping +
-					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
-			sge->addr_lo =
-				cpu_to_le32(U64_LO(fp->rx_sge_mapping +
-					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
-		}
 
-		bnx2x_init_sge_ring_bit_mask(fp);
-
-		/* RX BD ring */
-		for (i = 1; i <= NUM_RX_RINGS; i++) {
-			struct eth_rx_bd *rx_bd;
-
-			rx_bd = &fp->rx_desc_ring[RX_DESC_CNT * i - 2];
-			rx_bd->addr_hi =
-				cpu_to_le32(U64_HI(fp->rx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
-			rx_bd->addr_lo =
-				cpu_to_le32(U64_LO(fp->rx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
-		}
+		bnx2x_set_next_page_rx_bd(fp);
 
 		/* CQ ring */
-		for (i = 1; i <= NUM_RCQ_RINGS; i++) {
-			struct eth_rx_cqe_next_page *nextpg;
-
-			nextpg = (struct eth_rx_cqe_next_page *)
-				&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
-			nextpg->addr_hi =
-				cpu_to_le32(U64_HI(fp->rx_comp_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
-			nextpg->addr_lo =
-				cpu_to_le32(U64_LO(fp->rx_comp_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
-		}
-
-		/* Allocate SGEs and initialize the ring elements */
-		for (i = 0, ring_prod = 0;
-		     i < MAX_RX_SGE_CNT*NUM_RX_SGE_PAGES; i++) {
-
-			if (bnx2x_alloc_rx_sge(bp, fp, ring_prod) < 0) {
-				BNX2X_ERR("was only able to allocate "
-					  "%d rx sges\n", i);
-				BNX2X_ERR("disabling TPA for queue[%d]\n", j);
-				/* Cleanup already allocated elements */
-				bnx2x_free_rx_sge_range(bp, fp, ring_prod);
-				bnx2x_free_tpa_pool(bp, fp, max_agg_queues);
-				fp->disable_tpa = 1;
-				ring_prod = 0;
-				break;
-			}
-			ring_prod = NEXT_SGE_IDX(ring_prod);
-		}
-		fp->rx_sge_prod = ring_prod;
+		bnx2x_set_next_page_rx_cq(fp);
 
 		/* Allocate BDs and initialize BD ring */
-		fp->rx_comp_cons = 0;
-		cqe_ring_prod = ring_prod = 0;
-		for (i = 0; i < rx_ring_size; i++) {
-			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
-				BNX2X_ERR("was only able to allocate "
-					  "%d rx skbs on queue[%d]\n", i, j);
-				fp->eth_q_stats.rx_skb_alloc_failed++;
-				break;
-			}
-			ring_prod = NEXT_RX_IDX(ring_prod);
-			cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
-			WARN_ON(ring_prod <= i);
-		}
+		bnx2x_alloc_rx_bd_ring(fp);
 
-		fp->rx_bd_prod = ring_prod;
-		/* must not have more available CQEs than BDs */
-		fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
-					 cqe_ring_prod);
-		fp->rx_pkt = fp->rx_calls = 0;
-
-		/* Warning!
-		 * this will generate an interrupt (to the TSTORM)
-		 * must only be done after chip is initialized
-		 */
-		bnx2x_update_rx_prod(bp, fp, ring_prod, fp->rx_comp_prod,
-				     fp->rx_sge_prod);
 		if (j != 0)
 			continue;
 
@@ -921,6 +919,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func) + 4,
 		       U64_HI(fp->rx_comp_mapping));
 	}
+
 }
 static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 {
@@ -1252,6 +1251,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (rc)
 		return rc;
 
+	/* must be called before memory allocation and HW init */
+	bnx2x_ilt_set_info(bp);
+
 	if (bnx2x_alloc_mem(bp)) {
 		bnx2x_free_irq(bp, true);
 		return -ENOMEM;
@@ -1339,6 +1341,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		goto load_error2;
 	}
 
+	if (rc) {
+		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
+		goto load_error2;
+	}
+
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp, load_code);
 
@@ -1360,7 +1367,18 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_PORT;
 
-	rc = bnx2x_setup_leading(bp);
+	rc = bnx2x_func_start(bp);
+	if (rc) {
+		BNX2X_ERR("Function start failed!\n");
+#ifndef BNX2X_STOP_ON_ERROR
+		goto load_error3;
+#else
+		bp->panic = 1;
+		return -EBUSY;
+#endif
+	}
+
+	rc = bnx2x_setup_client(bp, &bp->fp[0], 1 /* Leading */);
 	if (rc) {
 		BNX2X_ERR("Setup leading failed!\n");
 #ifndef BNX2X_STOP_ON_ERROR
@@ -1377,37 +1395,37 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			bp->flags |= MF_FUNC_DIS;
 		}
 
-	if (bp->state == BNX2X_STATE_OPEN) {
 #ifdef BCM_CNIC
-		/* Enable Timer scan */
-		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 1);
+	/* Enable Timer scan */
+	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 1);
 #endif
-		for_each_nondefault_queue(bp, i) {
-			rc = bnx2x_setup_multi(bp, i);
-			if (rc)
+	for_each_nondefault_queue(bp, i) {
+		rc = bnx2x_setup_client(bp, &bp->fp[i], 0);
+		if (rc)
 #ifdef BCM_CNIC
-				goto load_error4;
+			goto load_error4;
 #else
-				goto load_error3;
+			goto load_error3;
 #endif
-		}
+	}
+
+	/* Now when Clients are configured we are ready to work */
+	bp->state = BNX2X_STATE_OPEN;
+
+	bnx2x_set_eth_mac(bp, 1);
 
-		if (CHIP_IS_E1(bp))
-			bnx2x_set_eth_mac_addr_e1(bp, 1);
-		else
-			bnx2x_set_eth_mac_addr_e1h(bp, 1);
 #ifdef BCM_CNIC
-		/* Set iSCSI L2 MAC */
-		mutex_lock(&bp->cnic_mutex);
-		if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
-			bnx2x_set_iscsi_eth_mac_addr(bp, 1);
-			bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
-			bnx2x_init_sb(bp, bp->cnic_sb, bp->cnic_sb_mapping,
-				      CNIC_SB_ID(bp));
-		}
-		mutex_unlock(&bp->cnic_mutex);
-#endif
+	/* Set iSCSI L2 MAC */
+	mutex_lock(&bp->cnic_mutex);
+	if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
+		bnx2x_set_iscsi_eth_mac_addr(bp, 1);
+		bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
+		bnx2x_init_sb(bp, bp->cnic_sb_mapping,
+			      BNX2X_VF_ID_INVALID, false,
+			      CNIC_SB_ID(bp), CNIC_IGU_SB_ID(bp));
 	}
+	mutex_unlock(&bp->cnic_mutex);
+#endif
 
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
@@ -1415,18 +1433,15 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Start fast path */
 	switch (load_mode) {
 	case LOAD_NORMAL:
-		if (bp->state == BNX2X_STATE_OPEN) {
-			/* Tx queue should be only reenabled */
-			netif_tx_wake_all_queues(bp->dev);
-		}
+		/* Tx queue should be only reenabled */
+		netif_tx_wake_all_queues(bp->dev);
 		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
 
 	case LOAD_OPEN:
 		netif_tx_start_all_queues(bp->dev);
-		if (bp->state != BNX2X_STATE_OPEN)
-			netif_tx_disable(bp->dev);
+		smp_mb__after_clear_bit();
 		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
@@ -1512,21 +1527,22 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
 
-	/* Disable HW interrupts, NAPI and Tx */
-	bnx2x_netif_stop(bp, 1);
-	netif_carrier_off(bp->dev);
-
 	del_timer_sync(&bp->timer);
 	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
 
 	/* Cleanup the chip if needed */
 	if (unload_mode != UNLOAD_RECOVERY)
 		bnx2x_chip_cleanup(bp, unload_mode);
+	else {
+		/* Disable HW interrupts, NAPI and Tx */
+		bnx2x_netif_stop(bp, 1);
+
+		/* Release IRQs */
+		bnx2x_free_irq(bp, false);
+	}
 
 	bp->port.pmf = 0;
 
@@ -1634,27 +1650,28 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 		/* Fall out from the NAPI loop if needed */
 		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 			bnx2x_update_fpsb_idx(fp);
-		/* bnx2x_has_rx_work() reads the status block, thus we need
-		 * to ensure that status block indices have been actually read
-		 * (bnx2x_update_fpsb_idx) prior to this check
-		 * (bnx2x_has_rx_work) so that we won't write the "newer"
-		 * value of the status block to IGU (if there was a DMA right
-		 * after bnx2x_has_rx_work and if there is no rmb, the memory
-		 * reading (bnx2x_update_fpsb_idx) may be postponed to right
-		 * before bnx2x_ack_sb). In this case there will never be
-		 * another interrupt until there is another update of the
-		 * status block, while there is still unhandled work.
+		/* bnx2x_has_rx_work() reads the status block,
+		 * thus we need to ensure that status block indices
+		 * have been actually read (bnx2x_update_fpsb_idx)
+		 * prior to this check (bnx2x_has_rx_work) so that
+		 * we won't write the "newer" value of the status block
+		 * to IGU (if there was a DMA right after
+		 * bnx2x_has_rx_work and if there is no rmb, the memory
+		 * reading (bnx2x_update_fpsb_idx) may be postponed
+		 * to right before bnx2x_ack_sb). In this case there
+		 * will never be another interrupt until there is
+		 * another update of the status block, while there
+		 * is still unhandled work.
 		 */
 			rmb();
 
 			if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 				napi_complete(napi);
 				/* Re-enable interrupts */
-				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-					     le16_to_cpu(fp->fp_c_idx),
-					     IGU_INT_NOP, 1);
-				bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-					     le16_to_cpu(fp->fp_u_idx),
+				DP(NETIF_MSG_HW,
+				   "Update index to %d\n", fp->fp_hc_idx);
+				bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID,
+					     le16_to_cpu(fp->fp_hc_idx),
 					     IGU_INT_ENABLE, 1);
 				break;
 			}
@@ -1850,7 +1867,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct sw_tx_bd *tx_buf;
 	struct eth_tx_start_bd *tx_start_bd;
 	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
-	struct eth_tx_parse_bd *pbd = NULL;
+	struct eth_tx_parse_bd_e1x *pbd_e1x = NULL;
 	u16 pkt_prod, bd_prod;
 	int nbd, fp_index;
 	dma_addr_t mapping;
@@ -1926,10 +1943,13 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
 
 	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
-	tx_start_bd->general_data =  (mac_type <<
-					ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
+	SET_FLAG(tx_start_bd->general_data,
+		  ETH_TX_START_BD_ETH_ADDR_TYPE,
+		  mac_type);
 	/* header nbd */
-	tx_start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
+	SET_FLAG(tx_start_bd->general_data,
+		  ETH_TX_START_BD_HDR_NBDS,
+		  1);
 
 	/* remember the first BD of the packet */
 	tx_buf->first_bd = fp->tx_bd_prod;
@@ -1943,62 +1963,68 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef BCM_VLAN
 	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb) &&
 	    (bp->flags & HW_VLAN_TX_FLAG)) {
-		tx_start_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
-		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
+		tx_start_bd->vlan_or_ethertype =
+		    cpu_to_le16(vlan_tx_tag_get(skb));
+		tx_start_bd->bd_flags.as_bitfield |=
+		    (X_ETH_OUTBAND_VLAN << ETH_TX_BD_FLAGS_VLAN_MODE_SHIFT);
 	} else
 #endif
-		tx_start_bd->vlan = cpu_to_le16(pkt_prod);
+		tx_start_bd->vlan_or_ethertype = cpu_to_le16(pkt_prod);
 
 	/* turn on parsing and get a BD */
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-	pbd = &fp->tx_desc_ring[bd_prod].parse_bd;
 
-	memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
+	if (xmit_type & XMIT_CSUM) {
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
+
+		if (xmit_type & XMIT_CSUM_V4)
+			tx_start_bd->bd_flags.as_bitfield |=
+						ETH_TX_BD_FLAGS_IP_CSUM;
+		else
+			tx_start_bd->bd_flags.as_bitfield |=
+						ETH_TX_BD_FLAGS_IPV6;
 
+		if (!(xmit_type & XMIT_CSUM_TCP))
+			tx_start_bd->bd_flags.as_bitfield |=
+						ETH_TX_BD_FLAGS_IS_UDP;
+	}
+	pbd_e1x = &fp->tx_desc_ring[bd_prod].parse_bd_e1x;
+	memset(pbd_e1x, 0, sizeof(struct eth_tx_parse_bd_e1x));
+	/* Set PBD in checksum offload case */
 	if (xmit_type & XMIT_CSUM) {
 		hlen = (skb_network_header(skb) - skb->data) / 2;
 
 		/* for now NS flag is not used in Linux */
-		pbd->global_data =
+		pbd_e1x->global_data =
 			(hlen | ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
-				 ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
+			 ETH_TX_PARSE_BD_E1X_LLC_SNAP_EN_SHIFT));
 
-		pbd->ip_hlen = (skb_transport_header(skb) -
+		pbd_e1x->ip_hlen_w = (skb_transport_header(skb) -
 				skb_network_header(skb)) / 2;
 
-		hlen += pbd->ip_hlen + tcp_hdrlen(skb) / 2;
+		hlen += pbd_e1x->ip_hlen_w + tcp_hdrlen(skb) / 2;
 
-		pbd->total_hlen = cpu_to_le16(hlen);
+		pbd_e1x->total_hlen_w = cpu_to_le16(hlen);
 		hlen = hlen*2;
 
-		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
-
-		if (xmit_type & XMIT_CSUM_V4)
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IP_CSUM;
-		else
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IPV6;
-
 		if (xmit_type & XMIT_CSUM_TCP) {
-			pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
+			pbd_e1x->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
 
 		} else {
 			s8 fix = SKB_CS_OFF(skb); /* signed! */
 
-			pbd->global_data |= ETH_TX_PARSE_BD_UDP_CS_FLG;
-
 			DP(NETIF_MSG_TX_QUEUED,
 			   "hlen %d  fix %d  csum before fix %x\n",
-			   le16_to_cpu(pbd->total_hlen), fix, SKB_CS(skb));
+			   le16_to_cpu(pbd_e1x->total_hlen_w),
+			   fix, SKB_CS(skb));
 
 			/* HW bug: fixup the CSUM */
-			pbd->tcp_pseudo_csum =
+			pbd_e1x->tcp_pseudo_csum =
 				bnx2x_csum_fix(skb_transport_header(skb),
 					       SKB_CS(skb), fix);
 
 			DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
-			   pbd->tcp_pseudo_csum);
+			   pbd_e1x->tcp_pseudo_csum);
 		}
 	}
 
@@ -2016,7 +2042,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   "  nbytes %d  flags %x  vlan %x\n",
 	   tx_start_bd, tx_start_bd->addr_hi, tx_start_bd->addr_lo,
 	   le16_to_cpu(tx_start_bd->nbd), le16_to_cpu(tx_start_bd->nbytes),
-	   tx_start_bd->bd_flags.as_bitfield, le16_to_cpu(tx_start_bd->vlan));
+	   tx_start_bd->bd_flags.as_bitfield,
+	   le16_to_cpu(tx_start_bd->vlan_or_ethertype));
 
 	if (xmit_type & XMIT_GSO) {
 
@@ -2031,24 +2058,25 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			bd_prod = bnx2x_tx_split(bp, fp, tx_buf, &tx_start_bd,
 						 hlen, bd_prod, ++nbd);
 
-		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
-		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
-		pbd->tcp_flags = pbd_tcp_flags(skb);
+		pbd_e1x->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+		pbd_e1x->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
+		pbd_e1x->tcp_flags = pbd_tcp_flags(skb);
 
 		if (xmit_type & XMIT_GSO_V4) {
-			pbd->ip_id = swab16(ip_hdr(skb)->id);
-			pbd->tcp_pseudo_csum =
+			pbd_e1x->ip_id = swab16(ip_hdr(skb)->id);
+			pbd_e1x->tcp_pseudo_csum =
 				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
 							  ip_hdr(skb)->daddr,
 							  0, IPPROTO_TCP, 0));
 
 		} else
-			pbd->tcp_pseudo_csum =
+			pbd_e1x->tcp_pseudo_csum =
 				swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 							&ipv6_hdr(skb)->daddr,
 							0, IPPROTO_TCP, 0));
 
-		pbd->global_data |= ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
+		pbd_e1x->global_data |=
+				ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN;
 	}
 	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
 
@@ -2088,13 +2116,14 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (total_pkt_bd != NULL)
 		total_pkt_bd->total_pkt_bytes = pkt_size;
 
-	if (pbd)
+	if (pbd_e1x)
 		DP(NETIF_MSG_TX_QUEUED,
-		   "PBD @%p  ip_data %x  ip_hlen %u  ip_id %u  lso_mss %u"
+		   "PBD (E1X) @%p  ip_data %x  ip_hlen %u  ip_id %u  lso_mss %u"
 		   "  tcp_flags %x  xsum %x  seq %u  hlen %u\n",
-		   pbd, pbd->global_data, pbd->ip_hlen, pbd->ip_id,
-		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
-		   pbd->tcp_send_seq, le16_to_cpu(pbd->total_hlen));
+		   pbd_e1x, pbd_e1x->global_data, pbd_e1x->ip_hlen_w,
+		   pbd_e1x->ip_id, pbd_e1x->lso_mss, pbd_e1x->tcp_flags,
+		   pbd_e1x->tcp_pseudo_csum, pbd_e1x->tcp_send_seq,
+		    le16_to_cpu(pbd_e1x->total_hlen_w));
 
 	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
 
@@ -2109,7 +2138,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	fp->tx_db.data.prod += nbd;
 	barrier();
-	DOORBELL(bp, fp->index, fp->tx_db.raw);
+	DOORBELL(bp, fp->cid, fp->tx_db.raw);
 
 	mmiowb();
 
@@ -2141,16 +2170,51 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 		return -EINVAL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	if (netif_running(dev)) {
-		if (CHIP_IS_E1(bp))
-			bnx2x_set_eth_mac_addr_e1(bp, 1);
-		else
-			bnx2x_set_eth_mac_addr_e1h(bp, 1);
-	}
+	if (netif_running(dev))
+		bnx2x_set_eth_mac(bp, 1);
 
 	return 0;
 }
 
+void bnx2x_free_mem_bp(struct bnx2x *bp)
+{
+	kfree(bp->fp);
+	kfree(bp->msix_table);
+	kfree(bp->ilt);
+}
+
+int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
+{
+	struct bnx2x_fastpath *fp;
+	struct msix_entry *tbl;
+	struct bnx2x_ilt *ilt;
+
+	/* fp array */
+	fp = kzalloc(L2_FP_COUNT(bp->l2_cid_count)*sizeof(*fp), GFP_KERNEL);
+	if (!fp)
+		goto alloc_err;
+	bp->fp = fp;
+
+	/* msix table */
+	tbl = kzalloc((bp->l2_cid_count + 1) * sizeof(*tbl),
+				  GFP_KERNEL);
+	if (!tbl)
+		goto alloc_err;
+	bp->msix_table = tbl;
+
+	/* ilt */
+	ilt = kzalloc(sizeof(*ilt), GFP_KERNEL);
+	if (!ilt)
+		goto alloc_err;
+	bp->ilt = ilt;
+
+	return 0;
+alloc_err:
+	bnx2x_free_mem_bp(bp);
+	return -ENOMEM;
+
+}
+
 /* called with rtnl_lock */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -2200,18 +2264,6 @@ void bnx2x_vlan_rx_register(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 
 	bp->vlgrp = vlgrp;
-
-	/* Set flags according to the required capabilities */
-	bp->flags &= ~(HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
-
-	if (dev->features & NETIF_F_HW_VLAN_TX)
-		bp->flags |= HW_VLAN_TX_FLAG;
-
-	if (dev->features & NETIF_F_HW_VLAN_RX)
-		bp->flags |= HW_VLAN_RX_FLAG;
-
-	if (netif_running(dev))
-		bnx2x_set_client_config(bp);
 }
 
 #endif
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 1ad08e4..2fb9045 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -107,6 +107,13 @@ void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
 void bnx2x_int_enable(struct bnx2x *bp);
 
 /**
+ * Disable HW interrupts.
+ *
+ * @param bp
+ */
+void bnx2x_int_disable(struct bnx2x *bp);
+
+/**
  * Disable interrupts. This function ensures that there are no
  * ISRs or SP DPCs (sp_task) are running after it returns.
  *
@@ -163,27 +170,30 @@ int bnx2x_alloc_mem(struct bnx2x *bp);
 void bnx2x_free_mem(struct bnx2x *bp);
 
 /**
- * Bring up a leading (the first) eth Client.
+ * Setup eth Client.
  *
  * @param bp
+ * @param fp
+ * @param is_leading
  *
  * @return int
  */
-int bnx2x_setup_leading(struct bnx2x *bp);
+int bnx2x_setup_client(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+		       int is_leading);
 
 /**
- * Setup non-leading eth Client.
+ * Bring down an eth client.
  *
  * @param bp
- * @param fp
+ * @param p
  *
  * @return int
  */
-int bnx2x_setup_multi(struct bnx2x *bp, int index);
+int bnx2x_stop_fw_client(struct bnx2x *bp,
+			 struct bnx2x_client_ramrod_params *p);
 
 /**
- * Set number of quueus according to mode and number of available
- * msi-x vectors
+ * Set number of quueus according to mode
  *
  * @param bp
  *
@@ -228,16 +238,7 @@ int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource);
  * @param bp driver handle
  * @param set
  */
-void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set);
-
-/**
- * Configure eth MAC address in the HW according to the value in
- * netdev->dev_addr for 57710
- *
- * @param bp driver handle
- * @param set
- */
-void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set);
+void bnx2x_set_eth_mac(struct bnx2x *bp, int set);
 
 #ifdef BCM_CNIC
 /**
@@ -257,12 +258,15 @@ int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set);
  * Initialize status block in FW and HW
  *
  * @param bp driver handle
- * @param sb host_status_block
  * @param dma_addr_t mapping
  * @param int sb_id
+ * @param int vfid
+ * @param u8 vf_valid
+ * @param int fw_sb_id
+ * @param int igu_sb_id
  */
-void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
-			  dma_addr_t mapping, int sb_id);
+void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
+			  u8 vf_valid, int fw_sb_id, int igu_sb_id);
 
 /**
  * Reconfigure FW/HW according to dev->flags rx mode
@@ -295,14 +299,6 @@ void bnx2x_disable_close_the_gate(struct bnx2x *bp);
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
 
 /**
- * Configures FW with client paramteres (like HW VLAN removal)
- * for each active client.
- *
- * @param bp
- */
-void bnx2x_set_client_config(struct bnx2x *bp);
-
-/**
  * Handle sp events
  *
  * @param fp fastpath handle for the event
@@ -310,14 +306,29 @@ void bnx2x_set_client_config(struct bnx2x *bp);
  */
 void bnx2x_sp_event(struct bnx2x_fastpath *fp,  union eth_rx_cqe *rr_cqe);
 
+/**
+ * Init/halt function before/after sending
+ * CLIENT_SETUP/CFC_DEL for the first/last client.
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_func_start(struct bnx2x *bp);
+int bnx2x_func_stop(struct bnx2x *bp);
+
+/**
+ * Prepare ILT configurations according to current driver
+ * parameters.
+ *
+ * @param bp
+ */
+void bnx2x_ilt_set_info(struct bnx2x *bp);
 
 static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 {
-	struct host_status_block *fpsb = fp->status_blk;
-
 	barrier(); /* status block is written to by the chip */
-	fp->fp_c_idx = fpsb->c_status_block.status_block_index;
-	fp->fp_u_idx = fpsb->u_status_block.status_block_index;
+	fp->fp_hc_idx = fp->sb_running_index[SM_RX_ID];
 }
 
 static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
@@ -344,8 +355,8 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 	wmb();
 
 	for (i = 0; i < sizeof(struct ustorm_eth_rx_producers)/4; i++)
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_RX_PRODS_OFFSET(BP_PORT(bp), fp->cl_id) + i*4,
+		REG_WR(bp,
+		       BAR_USTRORM_INTMEM + fp->ustorm_rx_prods_offset + i*4,
 		       ((u32 *)&rx_prods)[i]);
 
 	mmiowb(); /* keep prod updates ordered */
@@ -434,6 +445,17 @@ static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
 	return hw_cons != fp->tx_pkt_cons;
 }
 
+static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
+{
+	u16 rx_cons_sb;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
+	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
+		rx_cons_sb++;
+	return (fp->rx_comp_cons != rx_cons_sb);
+}
 static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 				     struct bnx2x_fastpath *fp, u16 index)
 {
@@ -454,13 +476,35 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	sge->addr_lo = 0;
 }
 
-static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
-					   struct bnx2x_fastpath *fp, int last)
+
+
+
+
+static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
 {
-	int i;
+	int i, j;
 
-	for (i = 0; i < last; i++)
-		bnx2x_free_rx_sge(bp, fp, i);
+	for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
+		int idx = RX_SGE_CNT * i - 1;
+
+		for (j = 0; j < 2; j++) {
+			SGE_MASK_CLEAR_BIT(fp, idx);
+			idx--;
+		}
+	}
+}
+
+static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
+{
+	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
+	memset(fp->sge_mask, 0xff,
+	       (NUM_RX_SGE >> RX_SGE_MASK_ELEM_SHIFT)*sizeof(u64));
+
+	/* Clear the two last indices in the page to 1:
+	   these are the indices that correspond to the "next" element,
+	   hence will never be indicated and should be removed from
+	   the calculations. */
+	bnx2x_clear_sge_mask_next_elems(fp);
 }
 
 static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
@@ -540,33 +584,15 @@ static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 			   dma_unmap_addr(cons_rx_buf, mapping));
 	*prod_bd = *cons_bd;
 }
-
-static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
+static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
+					   struct bnx2x_fastpath *fp, int last)
 {
-	int i, j;
-
-	for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
-		int idx = RX_SGE_CNT * i - 1;
+	int i;
 
-		for (j = 0; j < 2; j++) {
-			SGE_MASK_CLEAR_BIT(fp, idx);
-			idx--;
-		}
-	}
+	for (i = 0; i < last; i++)
+		bnx2x_free_rx_sge(bp, fp, i);
 }
 
-static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
-{
-	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
-	memset(fp->sge_mask, 0xff,
-	       (NUM_RX_SGE >> RX_SGE_MASK_ELEM_SHIFT)*sizeof(u64));
-
-	/* Clear the two last indices in the page to 1:
-	   these are the indices that correspond to the "next" element,
-	   hence will never be indicated and should be removed from
-	   the calculations. */
-	bnx2x_clear_sge_mask_next_elems(fp);
-}
 static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 				       struct bnx2x_fastpath *fp, int last)
 {
@@ -592,7 +618,7 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 }
 
 
-static inline void bnx2x_init_tx_ring(struct bnx2x *bp)
+static inline void bnx2x_init_tx_rings(struct bnx2x *bp)
 {
 	int i, j;
 
@@ -611,7 +637,7 @@ static inline void bnx2x_init_tx_ring(struct bnx2x *bp)
 					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 		}
 
-		fp->tx_db.data.header.header = DOORBELL_HDR_DB_TYPE;
+		SET_FLAG(fp->tx_db.data.header.header, DOORBELL_HDR_DB_TYPE, 1);
 		fp->tx_db.data.zero_fill1 = 0;
 		fp->tx_db.data.prod = 0;
 
@@ -619,22 +645,94 @@ static inline void bnx2x_init_tx_ring(struct bnx2x *bp)
 		fp->tx_pkt_cons = 0;
 		fp->tx_bd_prod = 0;
 		fp->tx_bd_cons = 0;
-		fp->tx_cons_sb = BNX2X_TX_SB_INDEX;
 		fp->tx_pkt = 0;
 	}
 }
-static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
+static inline void bnx2x_set_next_page_rx_bd(struct bnx2x_fastpath *fp)
 {
-	u16 rx_cons_sb;
+	int i;
 
-	/* Tell compiler that status block fields can change */
-	barrier();
-	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
-	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		rx_cons_sb++;
-	return fp->rx_comp_cons != rx_cons_sb;
+	for (i = 1; i <= NUM_RX_RINGS; i++) {
+		struct eth_rx_bd *rx_bd;
+
+		rx_bd = &fp->rx_desc_ring[RX_DESC_CNT * i - 2];
+		rx_bd->addr_hi =
+			cpu_to_le32(U64_HI(fp->rx_desc_mapping +
+				    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
+		rx_bd->addr_lo =
+			cpu_to_le32(U64_LO(fp->rx_desc_mapping +
+				    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
+	}
 }
 
+static inline void bnx2x_set_next_page_sgl(struct bnx2x_fastpath *fp)
+{
+	int i;
+
+	for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
+		struct eth_rx_sge *sge;
+
+		sge = &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
+		sge->addr_hi =
+			cpu_to_le32(U64_HI(fp->rx_sge_mapping +
+			BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+
+		sge->addr_lo =
+			cpu_to_le32(U64_LO(fp->rx_sge_mapping +
+			BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+	}
+}
+
+static inline void bnx2x_set_next_page_rx_cq(struct bnx2x_fastpath *fp)
+{
+	int i;
+	for (i = 1; i <= NUM_RCQ_RINGS; i++) {
+		struct eth_rx_cqe_next_page *nextpg;
+
+		nextpg = (struct eth_rx_cqe_next_page *)
+			&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
+		nextpg->addr_hi =
+			cpu_to_le32(U64_HI(fp->rx_comp_mapping +
+				   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+		nextpg->addr_lo =
+			cpu_to_le32(U64_LO(fp->rx_comp_mapping +
+				   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+	}
+}
+
+
+
+static inline void __storm_memset_struct(struct bnx2x *bp,
+					 u32 addr, size_t size, u32 *data)
+{
+	int i;
+	for (i = 0; i < size/4; i++)
+		REG_WR(bp, addr + (i * 4), data[i]);
+}
+
+static inline void storm_memset_mac_filters(struct bnx2x *bp,
+			struct tstorm_eth_mac_filter_config *mac_filters,
+			u16 abs_fid)
+{
+	size_t size = sizeof(struct tstorm_eth_mac_filter_config);
+
+	u32 addr = BAR_TSTRORM_INTMEM +
+			TSTORM_MAC_FILTER_CONFIG_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)mac_filters);
+}
+
+static inline void storm_memset_cmng(struct bnx2x *bp,
+				struct cmng_struct_per_port *cmng,
+				u8 port)
+{
+	size_t size = sizeof(struct cmng_struct_per_port);
+
+	u32 addr = BAR_XSTRORM_INTMEM +
+			XSTORM_CMNG_PER_PORT_VARS_OFFSET(port);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)cmng);
+}
 /* HW Lock for shared dual port PHYs */
 void bnx2x_acquire_phy_lock(struct bnx2x *bp);
 void bnx2x_release_phy_lock(struct bnx2x *bp);
@@ -659,4 +757,16 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
 int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
 
+/**
+ * Allocate/release memories outsize main driver structure
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp);
+void bnx2x_free_mem_bp(struct bnx2x *bp);
+
+#define BNX2X_FW_IP_HDR_ALIGN_PAD	2 /* FW places hdr with this padding */
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index d9748e9..56a0cb5 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1343,7 +1343,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	u16 pkt_prod, bd_prod;
 	struct sw_tx_bd *tx_buf;
 	struct eth_tx_start_bd *tx_start_bd;
-	struct eth_tx_parse_bd *pbd = NULL;
+	struct eth_tx_parse_bd_e1x *pbd_e1x = NULL;
 	dma_addr_t mapping;
 	union eth_rx_cqe *cqe;
 	u8 cqe_fp_flags;
@@ -1399,16 +1399,20 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
 	tx_start_bd->nbd = cpu_to_le16(2); /* start + pbd */
 	tx_start_bd->nbytes = cpu_to_le16(skb_headlen(skb));
-	tx_start_bd->vlan = cpu_to_le16(pkt_prod);
+	tx_start_bd->vlan_or_ethertype = cpu_to_le16(pkt_prod);
 	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
-	tx_start_bd->general_data = ((UNICAST_ADDRESS <<
-				ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT) | 1);
+	SET_FLAG(tx_start_bd->general_data,
+		 ETH_TX_START_BD_ETH_ADDR_TYPE,
+		 UNICAST_ADDRESS);
+	SET_FLAG(tx_start_bd->general_data,
+		 ETH_TX_START_BD_HDR_NBDS,
+		 1);
 
 	/* turn on parsing and get a BD */
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-	pbd = &fp_tx->tx_desc_ring[bd_prod].parse_bd;
+	pbd_e1x = &fp_tx->tx_desc_ring[bd_prod].parse_bd_e1x;
 
-	memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
+	memset(pbd_e1x, 0, sizeof(struct eth_tx_parse_bd_e1x));
 
 	wmb();
 
@@ -1578,9 +1582,9 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 
 	bp->set_mac_pending++;
 	smp_wmb();
-	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
 			   U64_HI(bnx2x_sp_mapping(bp, mac_config)),
-			   U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
+			   U64_LO(bnx2x_sp_mapping(bp, mac_config)), 1);
 	if (rc == 0) {
 		for (i = 0; i < 10; i++) {
 			if (!bp->set_mac_pending)
diff --git a/drivers/net/bnx2x/bnx2x_fw_defs.h b/drivers/net/bnx2x/bnx2x_fw_defs.h
index 08d71bf..f4e5b1c 100644
--- a/drivers/net/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x/bnx2x_fw_defs.h
@@ -7,369 +7,272 @@
  * the Free Software Foundation.
  */
 
-
-#define CSTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET ? 0x7000 : 0x1000)
-#define CSTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET ? (0x7020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
-#define CSTORM_DEF_SB_HC_DISABLE_C_OFFSET(function, index) \
-	(IS_E1H_OFFSET ? (0x8622 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100) + (index * 0x4)) : (0x3562 + (function * \
-	0x40) + (index * 0x4)))
-#define CSTORM_DEF_SB_HC_DISABLE_U_OFFSET(function, index) \
-	(IS_E1H_OFFSET ? (0x8822 + ((function>>1) * 0x80) + \
-	((function&1) * 0x200) + (index * 0x4)) : (0x35e2 + (function * \
-	0x80) + (index * 0x4)))
-#define CSTORM_DEF_SB_HOST_SB_ADDR_C_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8600 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100)) : (0x3540 + (function * 0x40)))
-#define CSTORM_DEF_SB_HOST_SB_ADDR_U_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8800 + ((function>>1) * 0x80) + \
-	((function&1) * 0x200)) : (0x35c0 + (function * 0x80)))
-#define CSTORM_DEF_SB_HOST_STATUS_BLOCK_C_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8608 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100)) : (0x3548 + (function * 0x40)))
-#define CSTORM_DEF_SB_HOST_STATUS_BLOCK_U_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8808 + ((function>>1) * 0x80) + \
-	((function&1) * 0x200)) : (0x35c8 + (function * 0x80)))
-#define CSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET ? 0x11e8 : 0xffffffff)
-#define CSTORM_HC_BTR_C_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x8c04 + (port * 0xf0)) : (0x36c4 + (port * 0xc0)))
-#define CSTORM_HC_BTR_U_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x8de4 + (port * 0xf0)) : (0x3844 + (port * 0xc0)))
-#define CSTORM_ISCSI_CQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6680 + (function * 0x8)) : (0x25a0 + \
-	(function * 0x8)))
-#define CSTORM_ISCSI_CQ_SQN_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x66c0 + (function * 0x8)) : (0x25b0 + \
-	(function * 0x8)))
-#define CSTORM_ISCSI_EQ_CONS_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x6040 + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x2410 + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x6044 + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x2414 + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x604c + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x241c + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x6057 + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x2427 + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_EQ_PROD_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x6042 + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x2412 + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x6056 + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x2426 + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_EQ_SB_NUM_OFFSET(function, eqIdx) \
-	(IS_E1H_OFFSET ? (0x6054 + (function * 0xc0) + (eqIdx * 0x18)) : \
-	(0x2424 + (function * 0xc0) + (eqIdx * 0x18)))
-#define CSTORM_ISCSI_HQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6640 + (function * 0x8)) : (0x2590 + \
-	(function * 0x8)))
-#define CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6004 + (function * 0x8)) : (0x2404 + \
-	(function * 0x8)))
-#define CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6002 + (function * 0x8)) : (0x2402 + \
-	(function * 0x8)))
-#define CSTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6000 + (function * 0x8)) : (0x2400 + \
-	(function * 0x8)))
-#define CSTORM_SB_HC_DISABLE_C_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0x811a + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)) : (0x305a + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)))
-#define CSTORM_SB_HC_DISABLE_U_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0xb01a + (port * 0x800) + (cpu_id * 0x80) + \
-	(index * 0x4)) : (0x401a + (port * 0x800) + (cpu_id * 0x80) + \
-	(index * 0x4)))
-#define CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0x8118 + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)) : (0x3058 + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)))
-#define CSTORM_SB_HC_TIMEOUT_U_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0xb018 + (port * 0x800) + (cpu_id * 0x80) + \
-	(index * 0x4)) : (0x4018 + (port * 0x800) + (cpu_id * 0x80) + \
-	(index * 0x4)))
-#define CSTORM_SB_HOST_SB_ADDR_C_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0x8100 + (port * 0x280) + (cpu_id * 0x28)) : \
-	(0x3040 + (port * 0x280) + (cpu_id * 0x28)))
-#define CSTORM_SB_HOST_SB_ADDR_U_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0xb000 + (port * 0x800) + (cpu_id * 0x80)) : \
-	(0x4000 + (port * 0x800) + (cpu_id * 0x80)))
-#define CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0x8108 + (port * 0x280) + (cpu_id * 0x28)) : \
-	(0x3048 + (port * 0x280) + (cpu_id * 0x28)))
-#define CSTORM_SB_HOST_STATUS_BLOCK_U_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0xb008 + (port * 0x800) + (cpu_id * 0x80)) : \
-	(0x4008 + (port * 0x800) + (cpu_id * 0x80)))
-#define CSTORM_SB_STATUS_BLOCK_C_SIZE 0x10
-#define CSTORM_SB_STATUS_BLOCK_U_SIZE 0x60
-#define CSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x1108 + (function * 0x8)) : (0x5108 + \
-	(function * 0x8)))
-#define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x3200 + (function * 0x20)) : 0xffffffff)
-#define TSTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET ? 0xa000 : 0x1000)
-#define TSTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET ? (0xa020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
-#define TSTORM_CLIENT_CONFIG_OFFSET(port, client_id) \
-	(IS_E1H_OFFSET ? (0x33a0 + (port * 0x1a0) + (client_id * 0x10)) \
-	: (0x9c0 + (port * 0x120) + (client_id * 0x10)))
-#define TSTORM_COMMON_SAFC_WORKAROUND_ENABLE_OFFSET \
-	(IS_E1H_OFFSET ? 0x1ed8 : 0xffffffff)
+#ifndef BNX2X_FW_DEFS_H
+#define BNX2X_FW_DEFS_H
+
+#define CSTORM_ASSERT_LIST_INDEX_OFFSET (IRO[142].base)
+#define CSTORM_ASSERT_LIST_OFFSET(assertListEntry) \
+	(IRO[141].base + ((assertListEntry) * IRO[141].m1))
+#define CSTORM_ETH_STATS_QUERY_ADDR_OFFSET(pfId) \
+	(IRO[144].base + ((pfId) * IRO[144].m1))
+#define CSTORM_EVENT_RING_DATA_OFFSET(pfId) \
+	(IRO[149].base + (((pfId)>>1) * IRO[149].m1) + (((pfId)&1) * \
+	IRO[149].m2))
+#define CSTORM_EVENT_RING_PROD_OFFSET(pfId) \
+	(IRO[150].base + (((pfId)>>1) * IRO[150].m1) + (((pfId)&1) * \
+	IRO[150].m2))
+#define CSTORM_FINAL_CLEANUP_COMPLETE_OFFSET(funcId) \
+	(IRO[156].base + ((funcId) * IRO[156].m1))
+#define CSTORM_FUNC_EN_OFFSET(funcId) \
+	(IRO[146].base + ((funcId) * IRO[146].m1))
+#define CSTORM_FUNCTION_MODE_OFFSET (IRO[153].base)
+#define CSTORM_IGU_MODE_OFFSET (IRO[154].base)
+#define CSTORM_ISCSI_CQ_SIZE_OFFSET(pfId) \
+	(IRO[311].base + ((pfId) * IRO[311].m1))
+#define CSTORM_ISCSI_CQ_SQN_SIZE_OFFSET(pfId) \
+	(IRO[312].base + ((pfId) * IRO[312].m1))
+	#define CSTORM_ISCSI_EQ_CONS_OFFSET(pfId, iscsiEqId) \
+	(IRO[304].base + ((pfId) * IRO[304].m1) + ((iscsiEqId) * \
+	IRO[304].m2))
+	#define CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(pfId, iscsiEqId) \
+	(IRO[306].base + ((pfId) * IRO[306].m1) + ((iscsiEqId) * \
+	IRO[306].m2))
+	#define CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(pfId, iscsiEqId) \
+	(IRO[305].base + ((pfId) * IRO[305].m1) + ((iscsiEqId) * \
+	IRO[305].m2))
+	#define \
+	CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(pfId, iscsiEqId) \
+	(IRO[307].base + ((pfId) * IRO[307].m1) + ((iscsiEqId) * \
+	IRO[307].m2))
+	#define CSTORM_ISCSI_EQ_PROD_OFFSET(pfId, iscsiEqId) \
+	(IRO[303].base + ((pfId) * IRO[303].m1) + ((iscsiEqId) * \
+	IRO[303].m2))
+	#define CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(pfId, iscsiEqId) \
+	(IRO[309].base + ((pfId) * IRO[309].m1) + ((iscsiEqId) * \
+	IRO[309].m2))
+	#define CSTORM_ISCSI_EQ_SB_NUM_OFFSET(pfId, iscsiEqId) \
+	(IRO[308].base + ((pfId) * IRO[308].m1) + ((iscsiEqId) * \
+	IRO[308].m2))
+#define CSTORM_ISCSI_HQ_SIZE_OFFSET(pfId) \
+	(IRO[310].base + ((pfId) * IRO[310].m1))
+#define CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfId) \
+	(IRO[302].base + ((pfId) * IRO[302].m1))
+#define CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfId) \
+	(IRO[301].base + ((pfId) * IRO[301].m1))
+#define CSTORM_ISCSI_PAGE_SIZE_OFFSET(pfId) \
+	(IRO[300].base + ((pfId) * IRO[300].m1))
+#define CSTORM_PATH_ID_OFFSET (IRO[159].base)
+#define CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(pfId) \
+	(IRO[137].base + ((pfId) * IRO[137].m1))
+#define CSTORM_SP_STATUS_BLOCK_OFFSET(pfId) \
+	(IRO[136].base + ((pfId) * IRO[136].m1))
+#define CSTORM_SP_STATUS_BLOCK_SIZE (IRO[136].size)
+#define CSTORM_SP_SYNC_BLOCK_OFFSET(pfId) \
+	(IRO[138].base + ((pfId) * IRO[138].m1))
+#define CSTORM_SP_SYNC_BLOCK_SIZE (IRO[138].size)
+#define CSTORM_STATS_FLAGS_OFFSET(pfId) \
+	(IRO[143].base + ((pfId) * IRO[143].m1))
+#define CSTORM_STATUS_BLOCK_DATA_OFFSET(sbId) \
+	(IRO[129].base + ((sbId) * IRO[129].m1))
+#define CSTORM_STATUS_BLOCK_OFFSET(sbId) \
+	(IRO[128].base + ((sbId) * IRO[128].m1))
+#define CSTORM_STATUS_BLOCK_SIZE (IRO[128].size)
+#define CSTORM_SYNC_BLOCK_OFFSET(sbId) \
+	(IRO[132].base + ((sbId) * IRO[132].m1))
+#define CSTORM_SYNC_BLOCK_SIZE (IRO[132].size)
+#define CSTORM_VF_PF_CHANNEL_STATE_OFFSET(vfId) \
+	(IRO[151].base + ((vfId) * IRO[151].m1))
+#define CSTORM_VF_PF_CHANNEL_VALID_OFFSET(vfId) \
+	(IRO[152].base + ((vfId) * IRO[152].m1))
+#define CSTORM_VF_TO_PF_OFFSET(funcId) \
+	(IRO[147].base + ((funcId) * IRO[147].m1))
+#define TSTORM_ACCEPT_CLASSIFY_FAILED_OFFSET (IRO[199].base)
+#define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(pfId) \
+	(IRO[198].base + ((pfId) * IRO[198].m1))
+#define TSTORM_ASSERT_LIST_INDEX_OFFSET (IRO[99].base)
+#define TSTORM_ASSERT_LIST_OFFSET(assertListEntry) \
+	(IRO[98].base + ((assertListEntry) * IRO[98].m1))
+	#define TSTORM_CLIENT_CONFIG_OFFSET(portId, clientId) \
+	(IRO[197].base + ((portId) * IRO[197].m1) + ((clientId) * \
+	IRO[197].m2))
+#define TSTORM_COMMON_SAFC_WORKAROUND_ENABLE_OFFSET (IRO[104].base)
 #define TSTORM_COMMON_SAFC_WORKAROUND_TIMEOUT_10USEC_OFFSET \
-	(IS_E1H_OFFSET ? 0x1eda : 0xffffffff)
-#define TSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET ? (0xb01a + ((function>>1) * 0x28) + \
-	((function&1) * 0xa0) + (index * 0x4)) : (0x141a + (function * \
-	0x28) + (index * 0x4)))
-#define TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0xb000 + ((function>>1) * 0x28) + \
-	((function&1) * 0xa0)) : (0x1400 + (function * 0x28)))
-#define TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0xb008 + ((function>>1) * 0x28) + \
-	((function&1) * 0xa0)) : (0x1408 + (function * 0x28)))
-#define TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2940 + (function * 0x8)) : (0x4928 + \
-	(function * 0x8)))
-#define TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x3000 + (function * 0x40)) : (0x1500 + \
-	(function * 0x40)))
-#define TSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET ? 0x1ed0 : 0xffffffff)
-#define TSTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0xb144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
-#define TSTORM_INDIRECTION_TABLE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x12c8 + (function * 0x80)) : (0x22c8 + \
-	(function * 0x80)))
-#define TSTORM_INDIRECTION_TABLE_SIZE 0x80
-#define TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(function, pblEntry) \
-	(IS_E1H_OFFSET ? (0x60c0 + (function * 0x40) + (pblEntry * 0x8)) \
-	: (0x4c30 + (function * 0x40) + (pblEntry * 0x8)))
-#define TSTORM_ISCSI_ERROR_BITMAP_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6340 + (function * 0x8)) : (0x4cd0 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6004 + (function * 0x8)) : (0x4c04 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6002 + (function * 0x8)) : (0x4c02 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6000 + (function * 0x8)) : (0x4c00 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_RQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6080 + (function * 0x8)) : (0x4c20 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6040 + (function * 0x8)) : (0x4c10 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6042 + (function * 0x8)) : (0x4c12 + \
-	(function * 0x8)))
-#define TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x6044 + (function * 0x8)) : (0x4c14 + \
-	(function * 0x8)))
-#define TSTORM_MAC_FILTER_CONFIG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x3008 + (function * 0x40)) : (0x1508 + \
-	(function * 0x40)))
-#define TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
-	(IS_E1H_OFFSET ? (0x2010 + (port * 0x490) + (stats_counter_id * \
-	0x40)) : (0x4010 + (port * 0x490) + (stats_counter_id * 0x40)))
-#define TSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x29c0 + (function * 0x8)) : (0x4948 + \
-	(function * 0x8)))
-#define TSTORM_TCP_MAX_CWND_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x4004 + (function * 0x8)) : (0x1fb4 + \
-	(function * 0x8)))
-#define USTORM_AGG_DATA_OFFSET (IS_E1H_OFFSET ? 0xa000 : 0x3000)
-#define USTORM_AGG_DATA_SIZE (IS_E1H_OFFSET ? 0x2000 : 0x1000)
-#define USTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET ? 0x8000 : 0x1000)
-#define USTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET ? (0x8020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
-#define USTORM_CQE_PAGE_BASE_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x1010 + (port * 0x680) + (clientId * 0x40)) : \
-	(0x4010 + (port * 0x360) + (clientId * 0x30)))
-#define USTORM_CQE_PAGE_NEXT_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x1028 + (port * 0x680) + (clientId * 0x40)) : \
-	(0x4028 + (port * 0x360) + (clientId * 0x30)))
-#define USTORM_ETH_PAUSE_ENABLED_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x2ad4 + (port * 0x8)) : 0xffffffff)
-#define USTORM_ETH_RING_PAUSE_DATA_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x1030 + (port * 0x680) + (clientId * 0x40)) : \
-	0xffffffff)
-#define USTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2a50 + (function * 0x8)) : (0x1dd0 + \
-	(function * 0x8)))
-#define USTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET ? 0x2448 : 0xffffffff)
-#define USTORM_ISCSI_CQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7044 + (function * 0x8)) : (0x2414 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_CQ_SQN_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7046 + (function * 0x8)) : (0x2416 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_ERROR_BITMAP_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7688 + (function * 0x8)) : (0x29c8 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7648 + (function * 0x8)) : (0x29b8 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7004 + (function * 0x8)) : (0x2404 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7002 + (function * 0x8)) : (0x2402 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7000 + (function * 0x8)) : (0x2400 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_R2TQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7040 + (function * 0x8)) : (0x2410 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7080 + (function * 0x8)) : (0x2420 + \
-	(function * 0x8)))
-#define USTORM_ISCSI_RQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x7084 + (function * 0x8)) : (0x2424 + \
-	(function * 0x8)))
-#define USTORM_MAX_AGG_SIZE_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x1018 + (port * 0x680) + (clientId * 0x40)) : \
-	(0x4018 + (port * 0x360) + (clientId * 0x30)))
-#define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2408 + (function * 0x8)) : (0x1da8 + \
-	(function * 0x8)))
-#define USTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
-	(IS_E1H_OFFSET ? (0x2450 + (port * 0x2d0) + (stats_counter_id * \
-	0x28)) : (0x1500 + (port * 0x2d0) + (stats_counter_id * 0x28)))
-#define USTORM_RX_PRODS_OFFSET(port, client_id) \
-	(IS_E1H_OFFSET ? (0x1000 + (port * 0x680) + (client_id * 0x40)) \
-	: (0x4000 + (port * 0x360) + (client_id * 0x30)))
-#define USTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x29f0 + (function * 0x8)) : (0x1db8 + \
-	(function * 0x8)))
-#define USTORM_TPA_BTR_OFFSET (IS_E1H_OFFSET ? 0x3da5 : 0x5095)
-#define USTORM_TPA_BTR_SIZE 0x1
-#define XSTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET ? 0x9000 : 0x1000)
-#define XSTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET ? (0x9020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
-#define XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x24a8 + (port * 0x50)) : (0x3a80 + (port * 0x50)))
-#define XSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET ? (0xa01a + ((function>>1) * 0x28) + \
-	((function&1) * 0xa0) + (index * 0x4)) : (0x141a + (function * \
-	0x28) + (index * 0x4)))
-#define XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0xa000 + ((function>>1) * 0x28) + \
-	((function&1) * 0xa0)) : (0x1400 + (function * 0x28)))
-#define XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0xa008 + ((function>>1) * 0x28) + \
-	((function&1) * 0xa0)) : (0x1408 + (function * 0x28)))
-#define XSTORM_E1HOV_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2c10 + (function * 0x8)) : 0xffffffff)
-#define XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2418 + (function * 0x8)) : (0x3a50 + \
-	(function * 0x8)))
-#define XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2588 + (function * 0x90)) : (0x3b60 + \
-	(function * 0x90)))
-#define XSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET ? 0x2c50 : 0xffffffff)
-#define XSTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0xa144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
-#define XSTORM_ISCSI_HQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x80c0 + (function * 0x8)) : (0x1c30 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_MAC_ADDR0_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8080 + (function * 0x8)) : (0x1c20 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_MAC_ADDR1_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8081 + (function * 0x8)) : (0x1c21 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_MAC_ADDR2_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8082 + (function * 0x8)) : (0x1c22 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_MAC_ADDR3_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8083 + (function * 0x8)) : (0x1c23 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_MAC_ADDR4_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8084 + (function * 0x8)) : (0x1c24 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_MAC_ADDR5_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8085 + (function * 0x8)) : (0x1c25 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_LOCAL_VLAN_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8086 + (function * 0x8)) : (0x1c26 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8004 + (function * 0x8)) : (0x1c04 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8002 + (function * 0x8)) : (0x1c02 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8000 + (function * 0x8)) : (0x1c00 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_R2TQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x80c4 + (function * 0x8)) : (0x1c34 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_SQ_SIZE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x80c2 + (function * 0x8)) : (0x1c32 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_TCP_VARS_ADV_WND_SCL_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8043 + (function * 0x8)) : (0x1c13 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8042 + (function * 0x8)) : (0x1c12 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_TCP_VARS_TOS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8041 + (function * 0x8)) : (0x1c11 + \
-	(function * 0x8)))
-#define XSTORM_ISCSI_TCP_VARS_TTL_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8040 + (function * 0x8)) : (0x1c10 + \
-	(function * 0x8)))
-#define XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
-	(IS_E1H_OFFSET ? (0xc000 + (port * 0x360) + (stats_counter_id * \
-	0x30)) : (0x3378 + (port * 0x360) + (stats_counter_id * 0x30)))
-#define XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2548 + (function * 0x90)) : (0x3b20 + \
-	(function * 0x90)))
-#define XSTORM_SPQ_PAGE_BASE_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2000 + (function * 0x10)) : (0x3328 + \
-	(function * 0x10)))
-#define XSTORM_SPQ_PROD_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2008 + (function * 0x10)) : (0x3330 + \
-	(function * 0x10)))
-#define XSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x23d8 + (function * 0x8)) : (0x3a40 + \
-	(function * 0x8)))
-#define XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x4000 + (port * 0x8)) : (0x1960 + (port * 0x8)))
-#define XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x4001 + (port * 0x8)) : (0x1961 + (port * 0x8)))
-#define XSTORM_TCP_TX_SWS_TIMER_VAL_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x4060 + ((function>>1) * 0x8) + ((function&1) \
-	* 0x4)) : (0x1978 + (function * 0x4)))
+	(IRO[105].base)
+#define TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(pfId) \
+	(IRO[96].base + ((pfId) * IRO[96].m1))
+#define TSTORM_FUNC_EN_OFFSET(funcId) \
+	(IRO[101].base + ((funcId) * IRO[101].m1))
+#define TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(pfId) \
+	(IRO[195].base + ((pfId) * IRO[195].m1))
+#define TSTORM_FUNCTION_MODE_OFFSET (IRO[103].base)
+#define TSTORM_INDIRECTION_TABLE_OFFSET(pfId) \
+	(IRO[91].base + ((pfId) * IRO[91].m1))
+#define TSTORM_INDIRECTION_TABLE_SIZE (IRO[91].size)
+	#define \
+	TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(pfId, iscsiConBufPblEntry) \
+	(IRO[260].base + ((pfId) * IRO[260].m1) + ((iscsiConBufPblEntry) \
+	* IRO[260].m2))
+#define TSTORM_ISCSI_ERROR_BITMAP_OFFSET(pfId) \
+	(IRO[264].base + ((pfId) * IRO[264].m1))
+#define TSTORM_ISCSI_L2_ISCSI_OOO_CID_TABLE_OFFSET(pfId) \
+	(IRO[265].base + ((pfId) * IRO[265].m1))
+#define TSTORM_ISCSI_L2_ISCSI_OOO_CLIENT_ID_TABLE_OFFSET(pfId) \
+	(IRO[266].base + ((pfId) * IRO[266].m1))
+#define TSTORM_ISCSI_L2_ISCSI_OOO_PROD_OFFSET(pfId) \
+	(IRO[267].base + ((pfId) * IRO[267].m1))
+#define TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfId) \
+	(IRO[263].base + ((pfId) * IRO[263].m1))
+#define TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfId) \
+	(IRO[262].base + ((pfId) * IRO[262].m1))
+#define TSTORM_ISCSI_PAGE_SIZE_OFFSET(pfId) \
+	(IRO[261].base + ((pfId) * IRO[261].m1))
+#define TSTORM_ISCSI_RQ_SIZE_OFFSET(pfId) \
+	(IRO[259].base + ((pfId) * IRO[259].m1))
+#define TSTORM_ISCSI_TCP_LOCAL_ADV_WND_OFFSET(pfId) \
+	(IRO[269].base + ((pfId) * IRO[269].m1))
+#define TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(pfId) \
+	(IRO[256].base + ((pfId) * IRO[256].m1))
+#define TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(pfId) \
+	(IRO[257].base + ((pfId) * IRO[257].m1))
+#define TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(pfId) \
+	(IRO[258].base + ((pfId) * IRO[258].m1))
+#define TSTORM_MAC_FILTER_CONFIG_OFFSET(pfId) \
+	(IRO[196].base + ((pfId) * IRO[196].m1))
+	#define TSTORM_PER_COUNTER_ID_STATS_OFFSET(portId, tStatCntId) \
+	(IRO[100].base + ((portId) * IRO[100].m1) + ((tStatCntId) * \
+	IRO[100].m2))
+#define TSTORM_STATS_FLAGS_OFFSET(pfId) \
+	(IRO[95].base + ((pfId) * IRO[95].m1))
+#define TSTORM_TCP_MAX_CWND_OFFSET(pfId) \
+	(IRO[211].base + ((pfId) * IRO[211].m1))
+#define TSTORM_VF_TO_PF_OFFSET(funcId) \
+	(IRO[102].base + ((funcId) * IRO[102].m1))
+#define USTORM_AGG_DATA_OFFSET (IRO[201].base)
+#define USTORM_AGG_DATA_SIZE (IRO[201].size)
+#define USTORM_ASSERT_LIST_INDEX_OFFSET (IRO[170].base)
+#define USTORM_ASSERT_LIST_OFFSET(assertListEntry) \
+	(IRO[169].base + ((assertListEntry) * IRO[169].m1))
+#define USTORM_ETH_PAUSE_ENABLED_OFFSET(portId) \
+	(IRO[178].base + ((portId) * IRO[178].m1))
+#define USTORM_ETH_STATS_QUERY_ADDR_OFFSET(pfId) \
+	(IRO[172].base + ((pfId) * IRO[172].m1))
+#define USTORM_FCOE_EQ_PROD_OFFSET(pfId) \
+	(IRO[313].base + ((pfId) * IRO[313].m1))
+#define USTORM_FUNC_EN_OFFSET(funcId) \
+	(IRO[174].base + ((funcId) * IRO[174].m1))
+#define USTORM_FUNCTION_MODE_OFFSET (IRO[177].base)
+#define USTORM_ISCSI_CQ_SIZE_OFFSET(pfId) \
+	(IRO[277].base + ((pfId) * IRO[277].m1))
+#define USTORM_ISCSI_CQ_SQN_SIZE_OFFSET(pfId) \
+	(IRO[278].base + ((pfId) * IRO[278].m1))
+#define USTORM_ISCSI_ERROR_BITMAP_OFFSET(pfId) \
+	(IRO[282].base + ((pfId) * IRO[282].m1))
+#define USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(pfId) \
+	(IRO[279].base + ((pfId) * IRO[279].m1))
+#define USTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfId) \
+	(IRO[275].base + ((pfId) * IRO[275].m1))
+#define USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfId) \
+	(IRO[274].base + ((pfId) * IRO[274].m1))
+#define USTORM_ISCSI_PAGE_SIZE_OFFSET(pfId) \
+	(IRO[273].base + ((pfId) * IRO[273].m1))
+#define USTORM_ISCSI_R2TQ_SIZE_OFFSET(pfId) \
+	(IRO[276].base + ((pfId) * IRO[276].m1))
+#define USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(pfId) \
+	(IRO[280].base + ((pfId) * IRO[280].m1))
+#define USTORM_ISCSI_RQ_SIZE_OFFSET(pfId) \
+	(IRO[281].base + ((pfId) * IRO[281].m1))
+#define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(pfId) \
+	(IRO[176].base + ((pfId) * IRO[176].m1))
+	#define USTORM_PER_COUNTER_ID_STATS_OFFSET(portId, uStatCntId) \
+	(IRO[173].base + ((portId) * IRO[173].m1) + ((uStatCntId) * \
+	IRO[173].m2))
+	#define USTORM_RX_PRODS_E1X_OFFSET(portId, clientId) \
+	(IRO[204].base + ((portId) * IRO[204].m1) + ((clientId) * \
+	IRO[204].m2))
+#define USTORM_RX_PRODS_E2_OFFSET(qzoneId) \
+	(IRO[205].base + ((qzoneId) * IRO[205].m1))
+#define USTORM_STATS_FLAGS_OFFSET(pfId) \
+	(IRO[171].base + ((pfId) * IRO[171].m1))
+#define USTORM_TPA_BTR_OFFSET (IRO[202].base)
+#define USTORM_TPA_BTR_SIZE (IRO[202].size)
+#define USTORM_VF_TO_PF_OFFSET(funcId) \
+	(IRO[175].base + ((funcId) * IRO[175].m1))
+#define XSTORM_AGG_INT_FINAL_CLEANUP_COMP_TYPE (IRO[59].base)
+#define XSTORM_AGG_INT_FINAL_CLEANUP_INDEX (IRO[58].base)
+#define XSTORM_ASSERT_LIST_INDEX_OFFSET (IRO[54].base)
+#define XSTORM_ASSERT_LIST_OFFSET(assertListEntry) \
+	(IRO[53].base + ((assertListEntry) * IRO[53].m1))
+#define XSTORM_CMNG_PER_PORT_VARS_OFFSET(portId) \
+	(IRO[47].base + ((portId) * IRO[47].m1))
+#define XSTORM_E1HOV_OFFSET(pfId) \
+	(IRO[55].base + ((pfId) * IRO[55].m1))
+#define XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(pfId) \
+	(IRO[45].base + ((pfId) * IRO[45].m1))
+#define XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(pfId) \
+	(IRO[49].base + ((pfId) * IRO[49].m1))
+#define XSTORM_FUNC_EN_OFFSET(funcId) \
+	(IRO[51].base + ((funcId) * IRO[51].m1))
+#define XSTORM_FUNCTION_MODE_OFFSET (IRO[56].base)
+#define XSTORM_ISCSI_HQ_SIZE_OFFSET(pfId) \
+	(IRO[290].base + ((pfId) * IRO[290].m1))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR0_OFFSET(pfId) \
+	(IRO[293].base + ((pfId) * IRO[293].m1))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR1_OFFSET(pfId) \
+	(IRO[294].base + ((pfId) * IRO[294].m1))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR2_OFFSET(pfId) \
+	(IRO[295].base + ((pfId) * IRO[295].m1))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR3_OFFSET(pfId) \
+	(IRO[296].base + ((pfId) * IRO[296].m1))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR4_OFFSET(pfId) \
+	(IRO[297].base + ((pfId) * IRO[297].m1))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR5_OFFSET(pfId) \
+	(IRO[298].base + ((pfId) * IRO[298].m1))
+#define XSTORM_ISCSI_LOCAL_VLAN_OFFSET(pfId) \
+	(IRO[299].base + ((pfId) * IRO[299].m1))
+#define XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfId) \
+	(IRO[289].base + ((pfId) * IRO[289].m1))
+#define XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfId) \
+	(IRO[288].base + ((pfId) * IRO[288].m1))
+#define XSTORM_ISCSI_PAGE_SIZE_OFFSET(pfId) \
+	(IRO[287].base + ((pfId) * IRO[287].m1))
+#define XSTORM_ISCSI_R2TQ_SIZE_OFFSET(pfId) \
+	(IRO[292].base + ((pfId) * IRO[292].m1))
+#define XSTORM_ISCSI_SQ_SIZE_OFFSET(pfId) \
+	(IRO[291].base + ((pfId) * IRO[291].m1))
+#define XSTORM_ISCSI_TCP_VARS_ADV_WND_SCL_OFFSET(pfId) \
+	(IRO[286].base + ((pfId) * IRO[286].m1))
+#define XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(pfId) \
+	(IRO[285].base + ((pfId) * IRO[285].m1))
+#define XSTORM_ISCSI_TCP_VARS_TOS_OFFSET(pfId) \
+	(IRO[284].base + ((pfId) * IRO[284].m1))
+#define XSTORM_ISCSI_TCP_VARS_TTL_OFFSET(pfId) \
+	(IRO[283].base + ((pfId) * IRO[283].m1))
+#define XSTORM_PATH_ID_OFFSET (IRO[65].base)
+	#define XSTORM_PER_COUNTER_ID_STATS_OFFSET(portId, xStatCntId) \
+	(IRO[50].base + ((portId) * IRO[50].m1) + ((xStatCntId) * \
+	IRO[50].m2))
+#define XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(pfId) \
+	(IRO[48].base + ((pfId) * IRO[48].m1))
+#define XSTORM_SPQ_DATA_OFFSET(funcId) \
+	(IRO[32].base + ((funcId) * IRO[32].m1))
+#define XSTORM_SPQ_DATA_SIZE (IRO[32].size)
+#define XSTORM_SPQ_PAGE_BASE_OFFSET(funcId) \
+	(IRO[30].base + ((funcId) * IRO[30].m1))
+#define XSTORM_SPQ_PROD_OFFSET(funcId) \
+	(IRO[31].base + ((funcId) * IRO[31].m1))
+#define XSTORM_STATS_FLAGS_OFFSET(pfId) \
+	(IRO[43].base + ((pfId) * IRO[43].m1))
+#define XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(portId) \
+	(IRO[206].base + ((portId) * IRO[206].m1))
+#define XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(portId) \
+	(IRO[207].base + ((portId) * IRO[207].m1))
+#define XSTORM_TCP_TX_SWS_TIMER_VAL_OFFSET(pfId) \
+	(IRO[209].base + (((pfId)>>1) * IRO[209].m1) + (((pfId)&1) * \
+	IRO[209].m2))
+#define XSTORM_VF_TO_PF_OFFSET(funcId) \
+	(IRO[52].base + ((funcId) * IRO[52].m1))
 #define COMMON_ASM_INVALID_ASSERT_OPCODE 0x0
 
-/**
-* This file defines HSI constants for the ETH flow
-*/
-#ifdef _EVEREST_MICROCODE
-#include "microcode_constants.h"
-#include "eth_rx_bd.h"
-#include "eth_tx_bd.h"
-#include "eth_rx_cqe.h"
-#include "eth_rx_sge.h"
-#include "eth_rx_cqe_next_page.h"
-#endif
-
 /* RSS hash types */
 #define DEFAULT_HASH_TYPE 0
 #define IPV4_HASH_TYPE 1
@@ -389,11 +292,17 @@
 #define U_ETH_NUM_OF_SGES_TO_FETCH 8
 #define U_ETH_MAX_SGES_FOR_PACKET 3
 
+/*Tx params*/
+#define X_ETH_NO_VLAN 0
+#define X_ETH_OUTBAND_VLAN 1
+#define X_ETH_INBAND_VLAN 2
 /* Rx ring params */
 #define U_ETH_LOCAL_BD_RING_SIZE 8
 #define U_ETH_LOCAL_SGE_RING_SIZE 10
 #define U_ETH_SGL_SIZE 8
-
+	/* The fw will padd the buffer with this value, so the IP header \
+	will be align to 4 Byte */
+#define IP_HEADER_ALIGNMENT_PADDING 2
 
 #define U_ETH_SGES_PER_PAGE_INVERSE_MASK \
 	(0xFFFF - ((PAGE_SIZE/((STRUCT_SIZE(eth_rx_sge))/8))-1))
@@ -409,16 +318,15 @@
 #define U_ETH_UNDEFINED_Q 0xFF
 
 /* values of command IDs in the ramrod message */
-#define RAMROD_CMD_ID_ETH_PORT_SETUP 80
-#define RAMROD_CMD_ID_ETH_CLIENT_SETUP 85
-#define RAMROD_CMD_ID_ETH_STAT_QUERY 90
-#define RAMROD_CMD_ID_ETH_UPDATE 100
-#define RAMROD_CMD_ID_ETH_HALT 105
-#define RAMROD_CMD_ID_ETH_SET_MAC 110
-#define RAMROD_CMD_ID_ETH_CFC_DEL 115
-#define RAMROD_CMD_ID_ETH_PORT_DEL 120
-#define RAMROD_CMD_ID_ETH_FORWARD_SETUP 125
-
+#define RAMROD_CMD_ID_ETH_UNUSED 0
+#define RAMROD_CMD_ID_ETH_CLIENT_SETUP 1
+#define RAMROD_CMD_ID_ETH_UPDATE 2
+#define RAMROD_CMD_ID_ETH_HALT 3
+#define RAMROD_CMD_ID_ETH_FORWARD_SETUP 4
+#define RAMROD_CMD_ID_ETH_ACTIVATE 5
+#define RAMROD_CMD_ID_ETH_DEACTIVATE 6
+#define RAMROD_CMD_ID_ETH_EMPTY 7
+#define RAMROD_CMD_ID_ETH_TERMINATE 8
 
 /* command values for set mac command */
 #define T_ETH_MAC_COMMAND_SET 0
@@ -431,7 +339,9 @@
 
 /* Maximal L2 clients supported */
 #define ETH_MAX_RX_CLIENTS_E1 18
-#define ETH_MAX_RX_CLIENTS_E1H 26
+#define ETH_MAX_RX_CLIENTS_E1H 28
+
+#define MAX_STAT_COUNTER_ID ETH_MAX_RX_CLIENTS_E1H
 
 /* Maximal aggregation queues supported */
 #define ETH_MAX_AGGREGATION_QUEUES_E1 32
@@ -443,6 +353,20 @@
 #define ETH_RSS_MODE_VLAN_PRI 2
 #define ETH_RSS_MODE_E1HOV_PRI 3
 #define ETH_RSS_MODE_IP_DSCP 4
+#define ETH_RSS_MODE_E2_INTEG 5
+
+
+/* ETH vlan filtering modes */
+#define ETH_VLAN_FILTER_ANY_VLAN 0 /* Don't filter by vlan */
+#define ETH_VLAN_FILTER_SPECIFIC_VLAN \
+	1 /* Only the vlan_id is allowed */
+#define ETH_VLAN_FILTER_CLASSIFY \
+	2 /* vlan will be added to CAM for classification */
+
+/* Fast path CQE selection */
+#define ETH_FP_CQE_REGULAR 0
+#define ETH_FP_CQE_SGL 1
+#define ETH_FP_CQE_RAW 2
 
 
 /**
@@ -458,6 +382,7 @@
 #define RESERVED_CONNECTION_TYPE_0 5
 #define RESERVED_CONNECTION_TYPE_1 6
 #define RESERVED_CONNECTION_TYPE_2 7
+#define NONE_CONNECTION_TYPE 8
 
 
 #define PROTOCOL_STATE_BIT_OFFSET 6
@@ -466,6 +391,16 @@
 #define TOE_STATE (TOE_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
 #define RDMA_STATE (RDMA_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
 
+/* values of command IDs in the ramrod message */
+#define RAMROD_CMD_ID_COMMON_FUNCTION_START 1
+#define RAMROD_CMD_ID_COMMON_FUNCTION_STOP 2
+#define RAMROD_CMD_ID_COMMON_CFC_DEL 3
+#define RAMROD_CMD_ID_COMMON_CFC_DEL_WB 4
+#define RAMROD_CMD_ID_COMMON_SET_MAC 5
+#define RAMROD_CMD_ID_COMMON_STAT_QUERY 6
+#define RAMROD_CMD_ID_COMMON_STOP_TRAFFIC 7
+#define RAMROD_CMD_ID_COMMON_START_TRAFFIC 8
+
 /* microcode fixed page page size 4K (chains and ring segments) */
 #define MC_PAGE_SIZE 4096
 
@@ -473,46 +408,26 @@
 /* Host coalescing constants */
 #define HC_IGU_BC_MODE 0
 #define HC_IGU_NBC_MODE 1
+/* Host coalescing constants. E1 includes E1H as well */
+
+/* Number of indices per slow-path SB */
+#define HC_SP_SB_MAX_INDICES 16
+
+/* Number of indices per SB */
+#define HC_SB_MAX_INDICES_E1X 8
+#define HC_SB_MAX_INDICES_E2 8
+
+#define HC_SB_MAX_SB_E1X 32
+#define HC_SB_MAX_SB_E2 136
+
+#define HC_SP_SB_ID 0xde
 
 #define HC_REGULAR_SEGMENT 0
 #define HC_DEFAULT_SEGMENT 1
+#define HC_SB_MAX_SM 2
 
-/* index numbers */
-#define HC_USTORM_DEF_SB_NUM_INDICES 8
-#define HC_CSTORM_DEF_SB_NUM_INDICES 8
-#define HC_XSTORM_DEF_SB_NUM_INDICES 4
-#define HC_TSTORM_DEF_SB_NUM_INDICES 4
-#define HC_USTORM_SB_NUM_INDICES 4
-#define HC_CSTORM_SB_NUM_INDICES 4
-
-/* index values - which counter to update */
-
-#define HC_INDEX_U_TOE_RX_CQ_CONS 0
-#define HC_INDEX_U_ETH_RX_CQ_CONS 1
-#define HC_INDEX_U_ETH_RX_BD_CONS 2
-#define HC_INDEX_U_FCOE_EQ_CONS 3
-
-#define HC_INDEX_C_TOE_TX_CQ_CONS 0
-#define HC_INDEX_C_ETH_TX_CQ_CONS 1
-#define HC_INDEX_C_ISCSI_EQ_CONS 2
-
-#define HC_INDEX_DEF_X_SPQ_CONS 0
-
-#define HC_INDEX_DEF_C_RDMA_EQ_CONS 0
-#define HC_INDEX_DEF_C_RDMA_NAL_PROD 1
-#define HC_INDEX_DEF_C_ETH_FW_TX_CQ_CONS 2
-#define HC_INDEX_DEF_C_ETH_SLOW_PATH 3
-#define HC_INDEX_DEF_C_ETH_RDMA_CQ_CONS 4
-#define HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS 5
-#define HC_INDEX_DEF_C_ETH_FCOE_CQ_CONS 6
-
-#define HC_INDEX_DEF_U_ETH_RDMA_RX_CQ_CONS 0
-#define HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS 1
-#define HC_INDEX_DEF_U_ETH_RDMA_RX_BD_CONS 2
-#define HC_INDEX_DEF_U_ETH_ISCSI_RX_BD_CONS 3
-#define HC_INDEX_DEF_U_ETH_FCOE_RX_CQ_CONS 4
-#define HC_INDEX_DEF_U_ETH_FCOE_RX_BD_CONS 5
-
+#define HC_SB_MAX_DYNAMIC_INDICES 4
+#define HC_FUNCTION_DISABLED 0xff
 /* used by the driver to get the SB offset */
 #define USTORM_ID 0
 #define CSTORM_ID 1
@@ -529,45 +444,17 @@
 
 
 /**** DEFINES FOR TIMERS/CLOCKS RESOLUTIONS ****/
-#define EMULATION_FREQUENCY_FACTOR 1600
-#define FPGA_FREQUENCY_FACTOR 100
 
 #define TIMERS_TICK_SIZE_CHIP (1e-3)
-#define TIMERS_TICK_SIZE_EMUL \
- ((TIMERS_TICK_SIZE_CHIP)/((EMULATION_FREQUENCY_FACTOR)))
-#define TIMERS_TICK_SIZE_FPGA \
- ((TIMERS_TICK_SIZE_CHIP)/((FPGA_FREQUENCY_FACTOR)))
 
 #define TSEMI_CLK1_RESUL_CHIP (1e-3)
-#define TSEMI_CLK1_RESUL_EMUL \
- ((TSEMI_CLK1_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
-#define TSEMI_CLK1_RESUL_FPGA \
- ((TSEMI_CLK1_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
-
-#define USEMI_CLK1_RESUL_CHIP (TIMERS_TICK_SIZE_CHIP)
-#define USEMI_CLK1_RESUL_EMUL (TIMERS_TICK_SIZE_EMUL)
-#define USEMI_CLK1_RESUL_FPGA (TIMERS_TICK_SIZE_FPGA)
 
 #define XSEMI_CLK1_RESUL_CHIP (1e-3)
-#define XSEMI_CLK1_RESUL_EMUL \
- ((XSEMI_CLK1_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
-#define XSEMI_CLK1_RESUL_FPGA \
- ((XSEMI_CLK1_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
-
-#define XSEMI_CLK2_RESUL_CHIP (1e-6)
-#define XSEMI_CLK2_RESUL_EMUL \
- ((XSEMI_CLK2_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
-#define XSEMI_CLK2_RESUL_FPGA \
- ((XSEMI_CLK2_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
 
 #define SDM_TIMER_TICK_RESUL_CHIP (4*(1e-6))
-#define SDM_TIMER_TICK_RESUL_EMUL \
- ((SDM_TIMER_TICK_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
-#define SDM_TIMER_TICK_RESUL_FPGA \
- ((SDM_TIMER_TICK_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
-
 
 /**** END DEFINES FOR TIMERS/CLOCKS RESOLUTIONS ****/
+
 #define XSTORM_IP_ID_ROLL_HALF 0x8000
 #define XSTORM_IP_ID_ROLL_ALL 0
 
@@ -576,10 +463,36 @@
 #define NUM_OF_PROTOCOLS 4
 #define NUM_OF_SAFC_BITS 16
 #define MAX_COS_NUMBER 4
-#define MAX_T_STAT_COUNTER_ID 18
-#define MAX_X_STAT_COUNTER_ID 18
-#define MAX_U_STAT_COUNTER_ID 18
 
+#define FAIRNESS_COS_WRR_MODE 0
+#define FAIRNESS_COS_ETS_MODE 1
+
+
+/* Priority Flow Control (PFC) */
+#define MAX_PFC_PRIORITIES 8
+#define MAX_PFC_TRAFFIC_TYPES 8
+
+/* Available Traffic Types for Link Layer Flow Control */
+#define LLFC_TRAFFIC_TYPE_NW 0
+#define LLFC_TRAFFIC_TYPE_FCOE 1
+#define LLFC_TRAFFIC_TYPE_ISCSI 2
+	/***************** START OF E2 INTEGRATION \
+	CODE***************************************/
+#define LLFC_TRAFFIC_TYPE_NW_COS1_E2INTEG 3
+	/***************** END OF E2 INTEGRATION \
+	CODE***************************************/
+#define LLFC_TRAFFIC_TYPE_MAX 4
+
+	/* used by array traffic_type_to_priority[] to mark traffic type \
+	that is not mapped to priority*/
+#define LLFC_TRAFFIC_TYPE_TO_PRIORITY_UNMAPPED 0xFF
+
+#define LLFC_MODE_NONE 0
+#define LLFC_MODE_PFC 1
+#define LLFC_MODE_SAFC 2
+
+#define DCB_DISABLED 0
+#define DCB_ENABLED 1
 
 #define UNKNOWN_ADDRESS 0
 #define UNICAST_ADDRESS 1
@@ -587,8 +500,32 @@
 #define BROADCAST_ADDRESS 3
 
 #define SINGLE_FUNCTION 0
-#define MULTI_FUNCTION 1
+#define MULTI_FUNCTION_SD 1
+#define MULTI_FUNCTION_SI 2
 
 #define IP_V4 0
 #define IP_V6 1
 
+
+#define C_ERES_PER_PAGE \
+	(PAGE_SIZE / BITS_TO_BYTES(STRUCT_SIZE(event_ring_elem)))
+#define C_ERE_PER_PAGE_MASK (C_ERES_PER_PAGE - 1)
+
+#define EVENT_RING_OPCODE_VF_PF_CHANNEL 0
+#define EVENT_RING_OPCODE_FUNCTION_START 1
+#define EVENT_RING_OPCODE_FUNCTION_STOP 2
+#define EVENT_RING_OPCODE_CFC_DEL 3
+#define EVENT_RING_OPCODE_CFC_DEL_WB 4
+#define EVENT_RING_OPCODE_SET_MAC 5
+#define EVENT_RING_OPCODE_STAT_QUERY 6
+#define EVENT_RING_OPCODE_STOP_TRAFFIC 7
+#define EVENT_RING_OPCODE_START_TRAFFIC 8
+#define EVENT_RING_OPCODE_FORWARD_SETUP 9
+
+#define VF_PF_CHANNEL_STATE_READY 0
+#define VF_PF_CHANNEL_STATE_WAITING_FOR_ACK 1
+
+#define VF_PF_CHANNEL_STATE_MAX_NUMBER 2
+
+
+#endif /* BNX2X_FW_DEFS_H */
diff --git a/drivers/net/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
index 3f5ee5d..f807262 100644
--- a/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
@@ -31,6 +31,7 @@ struct bnx2x_fw_file_hdr {
 	struct bnx2x_fw_file_section csem_pram_data;
 	struct bnx2x_fw_file_section xsem_int_table_data;
 	struct bnx2x_fw_file_section xsem_pram_data;
+	struct bnx2x_fw_file_section iro_arr;
 	struct bnx2x_fw_file_section fw_version;
 };
 
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 60d141c..596041c 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -6,6 +6,10 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  */
+#ifndef BNX2X_HSI_H
+#define BNX2X_HSI_H
+
+#include "bnx2x_fw_defs.h"
 
 struct license_key {
 	u32 reserved[6];
@@ -326,6 +330,7 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 	u32 lane_config;
 #define PORT_HW_CFG_LANE_SWAP_CFG_MASK		    0x0000ffff
 #define PORT_HW_CFG_LANE_SWAP_CFG_SHIFT 	    0
+
 #define PORT_HW_CFG_LANE_SWAP_CFG_TX_MASK	    0x000000ff
 #define PORT_HW_CFG_LANE_SWAP_CFG_TX_SHIFT	    0
 #define PORT_HW_CFG_LANE_SWAP_CFG_RX_MASK	    0x0000ff00
@@ -1016,11 +1021,12 @@ struct shmem_region {			       /*   SharedMem Offset (size) */
 	struct mgmtfw_state	mgmtfw_state;	       /* 0x4ac     (0x1b8) */
 
 	struct drv_port_mb	port_mb[PORT_MAX];     /* 0x664 (16*2=0x20) */
-	struct drv_func_mb	func_mb[E1H_FUNC_MAX];
+	struct drv_func_mb	func_mb[];	       /* 0x684
+					     (44*2/4/8=0x58/0xb0/0x160) */
+
+}; /* 57710 = 0x6dc | 57711 = 0x7E4 | 57712 = 0x734 */
 
-	struct mf_cfg		mf_cfg;
 
-};						       /* 0x6dc */
 
 
 struct shmem2_region {
@@ -1096,7 +1102,7 @@ struct emac_stats {
 };
 
 
-struct bmac_stats {
+struct bmac1_stats {
     u32     tx_stat_gtpkt_lo;
     u32     tx_stat_gtpkt_hi;
     u32     tx_stat_gtxpf_lo;
@@ -1202,8 +1208,8 @@ struct bmac_stats {
 
 
 union mac_stats {
-    struct emac_stats	emac_stats;
-    struct bmac_stats	bmac_stats;
+	struct emac_stats	emac_stats;
+	struct bmac1_stats	bmac1_stats;
 };
 
 
@@ -1377,17 +1383,17 @@ struct host_func_stats {
 };
 
 
-#define BCM_5710_FW_MAJOR_VERSION			5
-#define BCM_5710_FW_MINOR_VERSION			2
-#define BCM_5710_FW_REVISION_VERSION			13
-#define BCM_5710_FW_ENGINEERING_VERSION 		0
+#define BCM_5710_FW_MAJOR_VERSION			6
+#define BCM_5710_FW_MINOR_VERSION			0
+#define BCM_5710_FW_REVISION_VERSION			34
+#define BCM_5710_FW_ENGINEERING_VERSION			0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
 
 /*
  * attention bits
  */
-struct atten_def_status_block {
+struct atten_sp_status_block {
 	__le32 attn_bits;
 	__le32 attn_bits_ack;
 	u8 status_block_id;
@@ -1445,7 +1451,60 @@ struct doorbell_set_prod {
 
 
 /*
- * IGU driver acknowledgement register
+ * 3 lines. status block
+ */
+struct hc_status_block_e1x {
+	__le16 index_values[HC_SB_MAX_INDICES_E1X];
+	__le16 running_index[HC_SB_MAX_SM];
+	u32 rsrv;
+};
+
+/*
+ * host status block
+ */
+struct host_hc_status_block_e1x {
+	struct hc_status_block_e1x sb;
+};
+
+
+/*
+ * 3 lines. status block
+ */
+struct hc_status_block_e2 {
+	__le16 index_values[HC_SB_MAX_INDICES_E2];
+	__le16 running_index[HC_SB_MAX_SM];
+	u32 reserved;
+};
+
+/*
+ * host status block
+ */
+struct host_hc_status_block_e2 {
+	struct hc_status_block_e2 sb;
+};
+
+
+/*
+ * 5 lines. slow-path status block
+ */
+struct hc_sp_status_block {
+	__le16 index_values[HC_SP_SB_MAX_INDICES];
+	__le16 running_index;
+	__le16 rsrv;
+	u32 rsrv1;
+};
+
+/*
+ * host status block
+ */
+struct host_sp_status_block {
+	struct atten_sp_status_block atten_status_block;
+	struct hc_sp_status_block sp_sb;
+};
+
+
+/*
+ * IGU driver acknowledgment register
  */
 struct igu_ack_register {
 #if defined(__BIG_ENDIAN)
@@ -1603,8 +1662,14 @@ struct dmae_command {
 #define DMAE_COMMAND_DST_RESET_SHIFT 14
 #define DMAE_COMMAND_E1HVN (0x3<<15)
 #define DMAE_COMMAND_E1HVN_SHIFT 15
-#define DMAE_COMMAND_RESERVED0 (0x7FFF<<17)
-#define DMAE_COMMAND_RESERVED0_SHIFT 17
+#define DMAE_COMMAND_DST_VN (0x3<<17)
+#define DMAE_COMMAND_DST_VN_SHIFT 17
+#define DMAE_COMMAND_C_FUNC (0x1<<19)
+#define DMAE_COMMAND_C_FUNC_SHIFT 19
+#define DMAE_COMMAND_ERR_POLICY (0x3<<20)
+#define DMAE_COMMAND_ERR_POLICY_SHIFT 20
+#define DMAE_COMMAND_RESERVED0 (0x3FF<<22)
+#define DMAE_COMMAND_RESERVED0_SHIFT 22
 	u32 src_addr_lo;
 	u32 src_addr_hi;
 	u32 dst_addr_lo;
@@ -1629,11 +1694,11 @@ struct dmae_command {
 	u16 crc16_c;
 #endif
 #if defined(__BIG_ENDIAN)
-	u16 reserved2;
+	u16 reserved3;
 	u16 crc_t10;
 #elif defined(__LITTLE_ENDIAN)
 	u16 crc_t10;
-	u16 reserved2;
+	u16 reserved3;
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 xsum8;
@@ -1654,96 +1719,20 @@ struct double_regpair {
 
 
 /*
- * The eth storm context of Ustorm (configuration part)
+ * SDM operation gen command (generate aggregative interrupt)
  */
-struct ustorm_eth_st_context_config {
-#if defined(__BIG_ENDIAN)
-	u8 flags;
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT (0x1<<0)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT_SHIFT 0
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC (0x1<<1)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC_SHIFT 1
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA (0x1<<2)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<3)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 3
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
-	u8 status_block_id;
-	u8 clientId;
-	u8 sb_index_numbers;
-#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER (0xF<<0)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT 0
-#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER (0xF<<4)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT 4
-#elif defined(__LITTLE_ENDIAN)
-	u8 sb_index_numbers;
-#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER (0xF<<0)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT 0
-#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER (0xF<<4)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT 4
-	u8 clientId;
-	u8 status_block_id;
-	u8 flags;
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT (0x1<<0)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT_SHIFT 0
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC (0x1<<1)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC_SHIFT 1
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA (0x1<<2)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<3)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 3
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 bd_buff_size;
-	u8 statistics_counter_id;
-	u8 mc_alignment_log_size;
-#elif defined(__LITTLE_ENDIAN)
-	u8 mc_alignment_log_size;
-	u8 statistics_counter_id;
-	u16 bd_buff_size;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __local_sge_prod;
-	u8 __local_bd_prod;
-	u16 sge_buff_size;
-#elif defined(__LITTLE_ENDIAN)
-	u16 sge_buff_size;
-	u8 __local_bd_prod;
-	u8 __local_sge_prod;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __sdm_bd_expected_counter;
-	u8 cstorm_agg_int;
-	u8 __expected_bds_on_ram;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __expected_bds_on_ram;
-	u8 cstorm_agg_int;
-	u16 __sdm_bd_expected_counter;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __ring_data_ram_addr;
-	u16 __hc_cstorm_ram_addr;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __hc_cstorm_ram_addr;
-	u16 __ring_data_ram_addr;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 reserved1;
-	u8 max_sges_for_packet;
-	u16 __bd_ring_ram_addr;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __bd_ring_ram_addr;
-	u8 max_sges_for_packet;
-	u8 reserved1;
-#endif
-	u32 bd_page_base_lo;
-	u32 bd_page_base_hi;
-	u32 sge_page_base_lo;
-	u32 sge_page_base_hi;
-	struct regpair reserved2;
+struct sdm_op_gen {
+	__le32 command;
+#define SDM_OP_GEN_COMP_PARAM (0x1F<<0)
+#define SDM_OP_GEN_COMP_PARAM_SHIFT 0
+#define SDM_OP_GEN_COMP_TYPE (0x7<<5)
+#define SDM_OP_GEN_COMP_TYPE_SHIFT 5
+#define SDM_OP_GEN_AGG_VECT_IDX (0xFF<<8)
+#define SDM_OP_GEN_AGG_VECT_IDX_SHIFT 8
+#define SDM_OP_GEN_AGG_VECT_IDX_VALID (0x1<<16)
+#define SDM_OP_GEN_AGG_VECT_IDX_VALID_SHIFT 16
+#define SDM_OP_GEN_RESERVED (0x7FFF<<17)
+#define SDM_OP_GEN_RESERVED_SHIFT 17
 };
 
 /*
@@ -1762,20 +1751,13 @@ struct eth_rx_sge {
 	__le32 addr_hi;
 };
 
-/*
- * Local BDs and SGEs rings (in ETH)
- */
-struct eth_local_rx_rings {
-	struct eth_rx_bd __local_bd_ring[8];
-	struct eth_rx_sge __local_sge_ring[10];
-};
+
 
 /*
  * The eth storm context of Ustorm
  */
 struct ustorm_eth_st_context {
-	struct ustorm_eth_st_context_config common;
-	struct eth_local_rx_rings __rings;
+	u32 reserved0[48];
 };
 
 /*
@@ -1786,337 +1768,53 @@ struct tstorm_eth_st_context {
 };
 
 /*
- * The eth aggregative context section of Xstorm
- */
-struct xstorm_eth_extra_ag_context_section {
-#if defined(__BIG_ENDIAN)
-	u8 __tcp_agg_vars1;
-	u8 __reserved50;
-	u16 __mss;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __mss;
-	u8 __reserved50;
-	u8 __tcp_agg_vars1;
-#endif
-	u32 __snd_nxt;
-	u32 __tx_wnd;
-	u32 __snd_una;
-	u32 __reserved53;
-#if defined(__BIG_ENDIAN)
-	u8 __agg_val8_th;
-	u8 __agg_val8;
-	u16 __tcp_agg_vars2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __tcp_agg_vars2;
-	u8 __agg_val8;
-	u8 __agg_val8_th;
-#endif
-	u32 __reserved58;
-	u32 __reserved59;
-	u32 __reserved60;
-	u32 __reserved61;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_val7_th;
-	u16 __agg_val7;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val7;
-	u16 __agg_val7_th;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __tcp_agg_vars5;
-	u8 __tcp_agg_vars4;
-	u8 __tcp_agg_vars3;
-	u8 __reserved62;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __reserved62;
-	u8 __tcp_agg_vars3;
-	u8 __tcp_agg_vars4;
-	u8 __tcp_agg_vars5;
-#endif
-	u32 __tcp_agg_vars6;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_misc6;
-	u16 __tcp_agg_vars7;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __tcp_agg_vars7;
-	u16 __agg_misc6;
-#endif
-	u32 __agg_val10;
-	u32 __agg_val10_th;
-#if defined(__BIG_ENDIAN)
-	u16 __reserved3;
-	u8 __reserved2;
-	u8 __da_only_cnt;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __da_only_cnt;
-	u8 __reserved2;
-	u16 __reserved3;
-#endif
-};
-
-/*
  * The eth aggregative context of Xstorm
  */
 struct xstorm_eth_ag_context {
-#if defined(__BIG_ENDIAN)
-	u16 agg_val1;
-	u8 __agg_vars1;
-	u8 __state;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __state;
-	u8 __agg_vars1;
-	u16 agg_val1;
-#endif
+	u32 reserved0;
 #if defined(__BIG_ENDIAN)
 	u8 cdu_reserved;
-	u8 __agg_vars4;
-	u8 __agg_vars3;
-	u8 __agg_vars2;
+	u8 reserved2;
+	u16 reserved1;
 #elif defined(__LITTLE_ENDIAN)
-	u8 __agg_vars2;
-	u8 __agg_vars3;
-	u8 __agg_vars4;
+	u16 reserved1;
+	u8 reserved2;
 	u8 cdu_reserved;
 #endif
-	u32 __bd_prod;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_vars5;
-	u16 __agg_val4_th;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val4_th;
-	u16 __agg_vars5;
-#endif
-	struct xstorm_eth_extra_ag_context_section __extra_section;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_vars7;
-	u8 __agg_val3_th;
-	u8 __agg_vars6;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __agg_vars6;
-	u8 __agg_val3_th;
-	u16 __agg_vars7;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __agg_val11_th;
-	u16 __agg_val11;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val11;
-	u16 __agg_val11_th;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __reserved1;
-	u8 __agg_val6_th;
-	u16 __agg_val9;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val9;
-	u8 __agg_val6_th;
-	u8 __reserved1;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __agg_val2_th;
-	u16 __agg_val2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val2;
-	u16 __agg_val2_th;
-#endif
-	u32 __agg_vars8;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_misc0;
-	u16 __agg_val4;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val4;
-	u16 __agg_misc0;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __agg_val3;
-	u8 __agg_val6;
-	u8 __agg_val5_th;
-	u8 __agg_val5;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __agg_val5;
-	u8 __agg_val5_th;
-	u8 __agg_val6;
-	u8 __agg_val3;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __agg_misc1;
-	u16 __bd_ind_max_val;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __bd_ind_max_val;
-	u16 __agg_misc1;
-#endif
-	u32 __reserved57;
-	u32 __agg_misc4;
-	u32 __agg_misc5;
-};
-
-/*
- * The eth extra aggregative context section of Tstorm
- */
-struct tstorm_eth_extra_ag_context_section {
-	u32 __agg_val1;
-#if defined(__BIG_ENDIAN)
-	u8 __tcp_agg_vars2;
-	u8 __agg_val3;
-	u16 __agg_val2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val2;
-	u8 __agg_val3;
-	u8 __tcp_agg_vars2;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __agg_val5;
-	u8 __agg_val6;
-	u8 __tcp_agg_vars3;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __tcp_agg_vars3;
-	u8 __agg_val6;
-	u16 __agg_val5;
-#endif
-	u32 __reserved63;
-	u32 __reserved64;
-	u32 __reserved65;
-	u32 __reserved66;
-	u32 __reserved67;
-	u32 __tcp_agg_vars1;
-	u32 __reserved61;
-	u32 __reserved62;
-	u32 __reserved2;
+	u32 reserved3[30];
 };
 
 /*
  * The eth aggregative context of Tstorm
  */
 struct tstorm_eth_ag_context {
-#if defined(__BIG_ENDIAN)
-	u16 __reserved54;
-	u8 __agg_vars1;
-	u8 __state;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __state;
-	u8 __agg_vars1;
-	u16 __reserved54;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __agg_val4;
-	u16 __agg_vars2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_vars2;
-	u16 __agg_val4;
-#endif
-	struct tstorm_eth_extra_ag_context_section __extra_section;
+	u32 __reserved0[14];
 };
 
+
 /*
  * The eth aggregative context of Cstorm
  */
 struct cstorm_eth_ag_context {
-	u32 __agg_vars1;
-#if defined(__BIG_ENDIAN)
-	u8 __aux1_th;
-	u8 __aux1_val;
-	u16 __agg_vars2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_vars2;
-	u8 __aux1_val;
-	u8 __aux1_th;
-#endif
-	u32 __num_of_treated_packet;
-	u32 __last_packet_treated;
-#if defined(__BIG_ENDIAN)
-	u16 __reserved58;
-	u16 __reserved57;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __reserved57;
-	u16 __reserved58;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __reserved62;
-	u8 __reserved61;
-	u8 __reserved60;
-	u8 __reserved59;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __reserved59;
-	u8 __reserved60;
-	u8 __reserved61;
-	u8 __reserved62;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __reserved64;
-	u16 __reserved63;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __reserved63;
-	u16 __reserved64;
-#endif
-	u32 __reserved65;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_vars3;
-	u16 __rq_inv_cnt;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __rq_inv_cnt;
-	u16 __agg_vars3;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __packet_index_th;
-	u16 __packet_index;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __packet_index;
-	u16 __packet_index_th;
-#endif
+	u32 __reserved0[10];
 };
 
+
 /*
  * The eth aggregative context of Ustorm
  */
 struct ustorm_eth_ag_context {
-#if defined(__BIG_ENDIAN)
-	u8 __aux_counter_flags;
-	u8 __agg_vars2;
-	u8 __agg_vars1;
-	u8 __state;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __state;
-	u8 __agg_vars1;
-	u8 __agg_vars2;
-	u8 __aux_counter_flags;
-#endif
+	u32 __reserved0;
 #if defined(__BIG_ENDIAN)
 	u8 cdu_usage;
-	u8 __agg_misc2;
-	u16 __agg_misc1;
+	u8 __reserved2;
+	u16 __reserved1;
 #elif defined(__LITTLE_ENDIAN)
-	u16 __agg_misc1;
-	u8 __agg_misc2;
+	u16 __reserved1;
+	u8 __reserved2;
 	u8 cdu_usage;
 #endif
-	u32 __agg_misc4;
-#if defined(__BIG_ENDIAN)
-	u8 __agg_val3_th;
-	u8 __agg_val3;
-	u16 __agg_misc3;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_misc3;
-	u8 __agg_val3;
-	u8 __agg_val3_th;
-#endif
-	u32 __agg_val1;
-	u32 __agg_misc4_th;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_val2_th;
-	u16 __agg_val2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val2;
-	u16 __agg_val2_th;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __reserved2;
-	u8 __decision_rules;
-	u8 __decision_rule_enable_bits;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __decision_rule_enable_bits;
-	u8 __decision_rules;
-	u16 __reserved2;
-#endif
+	u32 __reserved3[6];
 };
 
 /*
@@ -2140,18 +1838,16 @@ struct timers_block_context {
  */
 struct eth_tx_bd_flags {
 	u8 as_bitfield;
-#define ETH_TX_BD_FLAGS_VLAN_TAG (0x1<<0)
-#define ETH_TX_BD_FLAGS_VLAN_TAG_SHIFT 0
-#define ETH_TX_BD_FLAGS_IP_CSUM (0x1<<1)
-#define ETH_TX_BD_FLAGS_IP_CSUM_SHIFT 1
-#define ETH_TX_BD_FLAGS_L4_CSUM (0x1<<2)
-#define ETH_TX_BD_FLAGS_L4_CSUM_SHIFT 2
-#define ETH_TX_BD_FLAGS_END_BD (0x1<<3)
-#define ETH_TX_BD_FLAGS_END_BD_SHIFT 3
+#define ETH_TX_BD_FLAGS_IP_CSUM (0x1<<0)
+#define ETH_TX_BD_FLAGS_IP_CSUM_SHIFT 0
+#define ETH_TX_BD_FLAGS_L4_CSUM (0x1<<1)
+#define ETH_TX_BD_FLAGS_L4_CSUM_SHIFT 1
+#define ETH_TX_BD_FLAGS_VLAN_MODE (0x3<<2)
+#define ETH_TX_BD_FLAGS_VLAN_MODE_SHIFT 2
 #define ETH_TX_BD_FLAGS_START_BD (0x1<<4)
 #define ETH_TX_BD_FLAGS_START_BD_SHIFT 4
-#define ETH_TX_BD_FLAGS_HDR_POOL (0x1<<5)
-#define ETH_TX_BD_FLAGS_HDR_POOL_SHIFT 5
+#define ETH_TX_BD_FLAGS_IS_UDP (0x1<<5)
+#define ETH_TX_BD_FLAGS_IS_UDP_SHIFT 5
 #define ETH_TX_BD_FLAGS_SW_LSO (0x1<<6)
 #define ETH_TX_BD_FLAGS_SW_LSO_SHIFT 6
 #define ETH_TX_BD_FLAGS_IPV6 (0x1<<7)
@@ -2166,7 +1862,7 @@ struct eth_tx_start_bd {
 	__le32 addr_hi;
 	__le16 nbd;
 	__le16 nbytes;
-	__le16 vlan;
+	__le16 vlan_or_ethertype;
 	struct eth_tx_bd_flags bd_flags;
 	u8 general_data;
 #define ETH_TX_START_BD_HDR_NBDS (0x3F<<0)
@@ -2179,48 +1875,48 @@ struct eth_tx_start_bd {
  * Tx regular BD structure
  */
 struct eth_tx_bd {
-	u32 addr_lo;
-	u32 addr_hi;
-	u16 total_pkt_bytes;
-	u16 nbytes;
+	__le32 addr_lo;
+	__le32 addr_hi;
+	__le16 total_pkt_bytes;
+	__le16 nbytes;
 	u8 reserved[4];
 };
 
 /*
- * Tx parsing BD structure for ETH,Relevant in START
+ * Tx parsing BD structure for ETH E1/E1h
  */
-struct eth_tx_parse_bd {
+struct eth_tx_parse_bd_e1x {
 	u8 global_data;
-#define ETH_TX_PARSE_BD_IP_HDR_START_OFFSET (0xF<<0)
-#define ETH_TX_PARSE_BD_IP_HDR_START_OFFSET_SHIFT 0
-#define ETH_TX_PARSE_BD_UDP_CS_FLG (0x1<<4)
-#define ETH_TX_PARSE_BD_UDP_CS_FLG_SHIFT 4
-#define ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN (0x1<<5)
-#define ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN_SHIFT 5
-#define ETH_TX_PARSE_BD_LLC_SNAP_EN (0x1<<6)
-#define ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT 6
-#define ETH_TX_PARSE_BD_NS_FLG (0x1<<7)
-#define ETH_TX_PARSE_BD_NS_FLG_SHIFT 7
+#define ETH_TX_PARSE_BD_E1X_IP_HDR_START_OFFSET_W (0xF<<0)
+#define ETH_TX_PARSE_BD_E1X_IP_HDR_START_OFFSET_W_SHIFT 0
+#define ETH_TX_PARSE_BD_E1X_RESERVED0 (0x1<<4)
+#define ETH_TX_PARSE_BD_E1X_RESERVED0_SHIFT 4
+#define ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN (0x1<<5)
+#define ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN_SHIFT 5
+#define ETH_TX_PARSE_BD_E1X_LLC_SNAP_EN (0x1<<6)
+#define ETH_TX_PARSE_BD_E1X_LLC_SNAP_EN_SHIFT 6
+#define ETH_TX_PARSE_BD_E1X_NS_FLG (0x1<<7)
+#define ETH_TX_PARSE_BD_E1X_NS_FLG_SHIFT 7
 	u8 tcp_flags;
-#define ETH_TX_PARSE_BD_FIN_FLG (0x1<<0)
-#define ETH_TX_PARSE_BD_FIN_FLG_SHIFT 0
-#define ETH_TX_PARSE_BD_SYN_FLG (0x1<<1)
-#define ETH_TX_PARSE_BD_SYN_FLG_SHIFT 1
-#define ETH_TX_PARSE_BD_RST_FLG (0x1<<2)
-#define ETH_TX_PARSE_BD_RST_FLG_SHIFT 2
-#define ETH_TX_PARSE_BD_PSH_FLG (0x1<<3)
-#define ETH_TX_PARSE_BD_PSH_FLG_SHIFT 3
-#define ETH_TX_PARSE_BD_ACK_FLG (0x1<<4)
-#define ETH_TX_PARSE_BD_ACK_FLG_SHIFT 4
-#define ETH_TX_PARSE_BD_URG_FLG (0x1<<5)
-#define ETH_TX_PARSE_BD_URG_FLG_SHIFT 5
-#define ETH_TX_PARSE_BD_ECE_FLG (0x1<<6)
-#define ETH_TX_PARSE_BD_ECE_FLG_SHIFT 6
-#define ETH_TX_PARSE_BD_CWR_FLG (0x1<<7)
-#define ETH_TX_PARSE_BD_CWR_FLG_SHIFT 7
-	u8 ip_hlen;
+#define ETH_TX_PARSE_BD_E1X_FIN_FLG (0x1<<0)
+#define ETH_TX_PARSE_BD_E1X_FIN_FLG_SHIFT 0
+#define ETH_TX_PARSE_BD_E1X_SYN_FLG (0x1<<1)
+#define ETH_TX_PARSE_BD_E1X_SYN_FLG_SHIFT 1
+#define ETH_TX_PARSE_BD_E1X_RST_FLG (0x1<<2)
+#define ETH_TX_PARSE_BD_E1X_RST_FLG_SHIFT 2
+#define ETH_TX_PARSE_BD_E1X_PSH_FLG (0x1<<3)
+#define ETH_TX_PARSE_BD_E1X_PSH_FLG_SHIFT 3
+#define ETH_TX_PARSE_BD_E1X_ACK_FLG (0x1<<4)
+#define ETH_TX_PARSE_BD_E1X_ACK_FLG_SHIFT 4
+#define ETH_TX_PARSE_BD_E1X_URG_FLG (0x1<<5)
+#define ETH_TX_PARSE_BD_E1X_URG_FLG_SHIFT 5
+#define ETH_TX_PARSE_BD_E1X_ECE_FLG (0x1<<6)
+#define ETH_TX_PARSE_BD_E1X_ECE_FLG_SHIFT 6
+#define ETH_TX_PARSE_BD_E1X_CWR_FLG (0x1<<7)
+#define ETH_TX_PARSE_BD_E1X_CWR_FLG_SHIFT 7
+	u8 ip_hlen_w;
 	s8 reserved;
-	__le16 total_hlen;
+	__le16 total_hlen_w;
 	__le16 tcp_pseudo_csum;
 	__le16 lso_mss;
 	__le16 ip_id;
@@ -2242,79 +1938,23 @@ struct eth_tx_next_bd {
 union eth_tx_bd_types {
 	struct eth_tx_start_bd start_bd;
 	struct eth_tx_bd reg_bd;
-	struct eth_tx_parse_bd parse_bd;
+	struct eth_tx_parse_bd_e1x parse_bd_e1x;
 	struct eth_tx_next_bd next_bd;
 };
 
+
 /*
  * The eth storm context of Xstorm
  */
 struct xstorm_eth_st_context {
-	u32 tx_bd_page_base_lo;
-	u32 tx_bd_page_base_hi;
-#if defined(__BIG_ENDIAN)
-	u16 tx_bd_cons;
-	u8 statistics_data;
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID (0x7F<<0)
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID_SHIFT 0
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE (0x1<<7)
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE_SHIFT 7
-	u8 __local_tx_bd_prod;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __local_tx_bd_prod;
-	u8 statistics_data;
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID (0x7F<<0)
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID_SHIFT 0
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE (0x1<<7)
-#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE_SHIFT 7
-	u16 tx_bd_cons;
-#endif
-	u32 __reserved1;
-	u32 __reserved2;
-#if defined(__BIG_ENDIAN)
-	u8 __ram_cache_index;
-	u8 __double_buffer_client;
-	u16 __pkt_cons;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __pkt_cons;
-	u8 __double_buffer_client;
-	u8 __ram_cache_index;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __statistics_address;
-	u16 __gso_next;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __gso_next;
-	u16 __statistics_address;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __local_tx_bd_cons;
-	u8 safc_group_num;
-	u8 safc_group_en;
-	u8 __is_eth_conn;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __is_eth_conn;
-	u8 safc_group_en;
-	u8 safc_group_num;
-	u8 __local_tx_bd_cons;
-#endif
-	union eth_tx_bd_types __bds[13];
+	u32 reserved0[60];
 };
 
 /*
  * The eth storm context of Cstorm
  */
 struct cstorm_eth_st_context {
-#if defined(__BIG_ENDIAN)
-	u16 __reserved0;
-	u8 sb_index_number;
-	u8 status_block_id;
-#elif defined(__LITTLE_ENDIAN)
-	u8 status_block_id;
-	u8 sb_index_number;
-	u16 __reserved0;
-#endif
-	u32 __reserved1[3];
+	u32 __reserved0[4];
 };
 
 /*
@@ -2362,103 +2002,114 @@ struct eth_tx_doorbell {
 
 
 /*
- * cstorm default status block, generated by ustorm
- */
-struct cstorm_def_status_block_u {
-	__le16 index_values[HC_USTORM_DEF_SB_NUM_INDICES];
-	__le16 status_block_index;
-	u8 func;
-	u8 status_block_id;
-	__le32 __flags;
-};
-
-/*
- * cstorm default status block, generated by cstorm
- */
-struct cstorm_def_status_block_c {
-	__le16 index_values[HC_CSTORM_DEF_SB_NUM_INDICES];
-	__le16 status_block_index;
-	u8 func;
-	u8 status_block_id;
-	__le32 __flags;
-};
-
-/*
- * xstorm status block
+ * client init fc data
  */
-struct xstorm_def_status_block {
-	__le16 index_values[HC_XSTORM_DEF_SB_NUM_INDICES];
-	__le16 status_block_index;
-	u8 func;
-	u8 status_block_id;
-	__le32 __flags;
+struct client_init_fc_data {
+	__le16 cqe_pause_thr_low;
+	__le16 cqe_pause_thr_high;
+	__le16 bd_pause_thr_low;
+	__le16 bd_pause_thr_high;
+	__le16 sge_pause_thr_low;
+	__le16 sge_pause_thr_high;
+	__le16 rx_cos_mask;
+	u8 safc_group_num;
+	u8 safc_group_en_flg;
+	u8 traffic_type;
+	u8 reserved0;
+	__le16 reserved1;
+	__le32 reserved2;
 };
 
-/*
- * tstorm status block
- */
-struct tstorm_def_status_block {
-	__le16 index_values[HC_TSTORM_DEF_SB_NUM_INDICES];
-	__le16 status_block_index;
-	u8 func;
-	u8 status_block_id;
-	__le32 __flags;
-};
 
 /*
- * host status block
+ * client init ramrod data
  */
-struct host_def_status_block {
-	struct atten_def_status_block atten_status_block;
-	struct cstorm_def_status_block_u u_def_status_block;
-	struct cstorm_def_status_block_c c_def_status_block;
-	struct xstorm_def_status_block x_def_status_block;
-	struct tstorm_def_status_block t_def_status_block;
+struct client_init_general_data {
+	u8 client_id;
+	u8 statistics_counter_id;
+	u8 statistics_en_flg;
+	u8 is_fcoe_flg;
+	u8 activate_flg;
+	u8 sp_client_id;
+	__le16 reserved0;
+	__le32 reserved1[2];
 };
 
 
 /*
- * cstorm status block, generated by ustorm
+ * client init rx data
  */
-struct cstorm_status_block_u {
-	__le16 index_values[HC_USTORM_SB_NUM_INDICES];
-	__le16 status_block_index;
-	u8 func;
+struct client_init_rx_data {
+	u8 tpa_en_flg;
+	u8 vmqueue_mode_en_flg;
+	u8 extra_data_over_sgl_en_flg;
+	u8 cache_line_alignment_log_size;
+	u8 enable_dynamic_hc;
+	u8 max_sges_for_packet;
+	u8 client_qzone_id;
+	u8 drop_ip_cs_err_flg;
+	u8 drop_tcp_cs_err_flg;
+	u8 drop_ttl0_flg;
+	u8 drop_udp_cs_err_flg;
+	u8 inner_vlan_removal_enable_flg;
+	u8 outer_vlan_removal_enable_flg;
 	u8 status_block_id;
-	__le32 __flags;
+	u8 rx_sb_index_number;
+	u8 reserved0[3];
+	__le16 bd_buff_size;
+	__le16 sge_buff_size;
+	__le16 mtu;
+	struct regpair bd_page_base;
+	struct regpair sge_page_base;
+	struct regpair cqe_page_base;
+	u8 is_leading_rss;
+	u8 is_approx_mcast;
+	__le16 max_agg_size;
+	__le32 reserved2[3];
+};
+
+/*
+ * client init tx data
+ */
+struct client_init_tx_data {
+	u8 enforce_security_flg;
+	u8 tx_status_block_id;
+	u8 tx_sb_index_number;
+	u8 reserved0;
+	__le16 mtu;
+	__le16 reserved1;
+	struct regpair tx_bd_page_base;
+	__le32 reserved2[2];
 };
 
 /*
- * cstorm status block, generated by cstorm
+ * client init ramrod data
  */
-struct cstorm_status_block_c {
-	__le16 index_values[HC_CSTORM_SB_NUM_INDICES];
-	__le16 status_block_index;
-	u8 func;
-	u8 status_block_id;
-	__le32 __flags;
+struct client_init_ramrod_data {
+	struct client_init_general_data general;
+	struct client_init_rx_data rx;
+	struct client_init_tx_data tx;
+	struct client_init_fc_data fc;
 };
 
+
 /*
- * host status block
+ * The data contain client ID need to the ramrod
  */
-struct host_status_block {
-	struct cstorm_status_block_u u_status_block;
-	struct cstorm_status_block_c c_status_block;
+struct eth_common_ramrod_data {
+	u32 client_id;
+	u32 reserved1;
 };
 
 
 /*
- * The data for RSS setup ramrod
+ * union for sgl and raw data.
  */
-struct eth_client_setup_ramrod_data {
-	u32 client_id;
-	u8 is_rdma;
-	u8 is_fcoe;
-	u16 reserved1;
+union eth_sgl_or_raw_data {
+	__le16 sgl[8];
+	u32 raw_data[4];
 };
 
-
 /*
  * regular eth FP CQE parameters struct
  */
@@ -2476,8 +2127,8 @@ struct eth_fast_path_rx_cqe {
 #define ETH_FAST_PATH_RX_CQE_START_FLG_SHIFT 4
 #define ETH_FAST_PATH_RX_CQE_END_FLG (0x1<<5)
 #define ETH_FAST_PATH_RX_CQE_END_FLG_SHIFT 5
-#define ETH_FAST_PATH_RX_CQE_RESERVED0 (0x3<<6)
-#define ETH_FAST_PATH_RX_CQE_RESERVED0_SHIFT 6
+#define ETH_FAST_PATH_RX_CQE_SGL_RAW_SEL (0x3<<6)
+#define ETH_FAST_PATH_RX_CQE_SGL_RAW_SEL_SHIFT 6
 	u8 status_flags;
 #define ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE (0x7<<0)
 #define ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE_SHIFT 0
@@ -2498,7 +2149,7 @@ struct eth_fast_path_rx_cqe {
 	__le16 pkt_len;
 	__le16 len_on_bd;
 	struct parsing_flags pars_flags;
-	__le16 sgl[8];
+	union eth_sgl_or_raw_data sgl_or_raw_data;
 };
 
 
@@ -2510,11 +2161,10 @@ struct eth_halt_ramrod_data {
 	u32 reserved0;
 };
 
-
 /*
  * The data for statistics query ramrod
  */
-struct eth_query_ramrod_data {
+struct common_query_ramrod_data {
 #if defined(__BIG_ENDIAN)
 	u8 reserved0;
 	u8 collect_port;
@@ -2597,9 +2247,9 @@ struct spe_hdr {
 	__le16 type;
 #define SPE_HDR_CONN_TYPE (0xFF<<0)
 #define SPE_HDR_CONN_TYPE_SHIFT 0
-#define SPE_HDR_COMMON_RAMROD (0xFF<<8)
-#define SPE_HDR_COMMON_RAMROD_SHIFT 8
-	__le16 reserved;
+#define SPE_HDR_FUNCTION_ID (0xFF<<8)
+#define SPE_HDR_FUNCTION_ID_SHIFT 8
+	__le16 reserved1;
 };
 
 /*
@@ -2607,12 +2257,10 @@ struct spe_hdr {
  */
 union eth_specific_data {
 	u8 protocol_data[8];
-	struct regpair mac_config_addr;
-	struct eth_client_setup_ramrod_data client_setup_ramrod_data;
+	struct regpair client_init_ramrod_init_data;
 	struct eth_halt_ramrod_data halt_ramrod_data;
-	struct regpair leading_cqe_addr;
 	struct regpair update_data_addr;
-	struct eth_query_ramrod_data query_ramrod_data;
+	struct eth_common_ramrod_data common_ramrod_data;
 };
 
 /*
@@ -2637,7 +2285,7 @@ struct eth_tx_bds_array {
  */
 struct tstorm_eth_function_common_config {
 #if defined(__BIG_ENDIAN)
-	u8 leading_client_id;
+	u8 reserved1;
 	u8 rss_result_mask;
 	u16 config_flags;
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY (0x1<<0)
@@ -2650,16 +2298,12 @@ struct tstorm_eth_function_common_config {
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY_SHIFT 3
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE (0x7<<4)
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT 4
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE (0x1<<7)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE_SHIFT 7
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM (0x1<<8)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM_SHIFT 8
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM (0x1<<9)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM_SHIFT 9
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA (0x1<<10)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA_SHIFT 10
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x1F<<11)
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 11
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA (0x1<<7)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA_SHIFT 7
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_FILTERING_ENABLE (0x1<<8)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_FILTERING_ENABLE_SHIFT 8
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x7F<<9)
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 9
 #elif defined(__LITTLE_ENDIAN)
 	u16 config_flags;
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY (0x1<<0)
@@ -2672,18 +2316,14 @@ struct tstorm_eth_function_common_config {
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY_SHIFT 3
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE (0x7<<4)
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT 4
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE (0x1<<7)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE_SHIFT 7
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM (0x1<<8)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM_SHIFT 8
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM (0x1<<9)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM_SHIFT 9
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA (0x1<<10)
-#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA_SHIFT 10
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x1F<<11)
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 11
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA (0x1<<7)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA_SHIFT 7
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_FILTERING_ENABLE (0x1<<8)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_FILTERING_ENABLE_SHIFT 8
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x7F<<9)
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 9
 	u8 rss_result_mask;
-	u8 leading_client_id;
+	u8 reserved1;
 #endif
 	u16 vlan_id[2];
 };
@@ -2731,90 +2371,42 @@ struct mac_configuration_hdr {
 	u8 length;
 	u8 offset;
 	u16 client_id;
-	u32 reserved1;
-};
-
-/*
- * MAC address in list for ramrod
- */
-struct tstorm_cam_entry {
-	__le16 lsb_mac_addr;
-	__le16 middle_mac_addr;
-	__le16 msb_mac_addr;
-	__le16 flags;
-#define TSTORM_CAM_ENTRY_PORT_ID (0x1<<0)
-#define TSTORM_CAM_ENTRY_PORT_ID_SHIFT 0
-#define TSTORM_CAM_ENTRY_RSRVVAL0 (0x7<<1)
-#define TSTORM_CAM_ENTRY_RSRVVAL0_SHIFT 1
-#define TSTORM_CAM_ENTRY_RESERVED0 (0xFFF<<4)
-#define TSTORM_CAM_ENTRY_RESERVED0_SHIFT 4
-};
-
-/*
- * MAC filtering: CAM target table entry
- */
-struct tstorm_cam_target_table_entry {
-	u8 flags;
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST (0x1<<0)
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST_SHIFT 0
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_OVERRIDE_VLAN_REMOVAL (0x1<<1)
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_OVERRIDE_VLAN_REMOVAL_SHIFT 1
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE (0x1<<2)
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE_SHIFT 2
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_RDMA_MAC (0x1<<3)
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_RDMA_MAC_SHIFT 3
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_RESERVED0 (0xF<<4)
-#define TSTORM_CAM_TARGET_TABLE_ENTRY_RESERVED0_SHIFT 4
-	u8 reserved1;
-	u16 vlan_id;
-	u32 clients_bit_vector;
+	u16 echo;
+	u16 reserved1;
 };
 
 /*
  * MAC address in list for ramrod
  */
 struct mac_configuration_entry {
-	struct tstorm_cam_entry cam_entry;
-	struct tstorm_cam_target_table_entry target_table_entry;
-};
-
-/*
- * MAC filtering configuration command
- */
-struct mac_configuration_cmd {
-	struct mac_configuration_hdr hdr;
-	struct mac_configuration_entry config_table[64];
-};
-
-
-/*
- * MAC address in list for ramrod
- */
-struct mac_configuration_entry_e1h {
 	__le16 lsb_mac_addr;
 	__le16 middle_mac_addr;
 	__le16 msb_mac_addr;
 	__le16 vlan_id;
-	__le16 e1hov_id;
-	u8 reserved0;
+	u8 pf_id;
 	u8 flags;
-#define MAC_CONFIGURATION_ENTRY_E1H_PORT (0x1<<0)
-#define MAC_CONFIGURATION_ENTRY_E1H_PORT_SHIFT 0
-#define MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE (0x1<<1)
-#define MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE_SHIFT 1
-#define MAC_CONFIGURATION_ENTRY_E1H_RDMA_MAC (0x1<<2)
-#define MAC_CONFIGURATION_ENTRY_E1H_RDMA_MAC_SHIFT 2
-#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED1 (0x1F<<3)
-#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED1_SHIFT 3
+#define MAC_CONFIGURATION_ENTRY_ACTION_TYPE (0x1<<0)
+#define MAC_CONFIGURATION_ENTRY_ACTION_TYPE_SHIFT 0
+#define MAC_CONFIGURATION_ENTRY_RDMA_MAC (0x1<<1)
+#define MAC_CONFIGURATION_ENTRY_RDMA_MAC_SHIFT 1
+#define MAC_CONFIGURATION_ENTRY_VLAN_FILTERING_MODE (0x3<<2)
+#define MAC_CONFIGURATION_ENTRY_VLAN_FILTERING_MODE_SHIFT 2
+#define MAC_CONFIGURATION_ENTRY_OVERRIDE_VLAN_REMOVAL (0x1<<4)
+#define MAC_CONFIGURATION_ENTRY_OVERRIDE_VLAN_REMOVAL_SHIFT 4
+#define MAC_CONFIGURATION_ENTRY_BROADCAST (0x1<<5)
+#define MAC_CONFIGURATION_ENTRY_BROADCAST_SHIFT 5
+#define MAC_CONFIGURATION_ENTRY_RESERVED1 (0x3<<6)
+#define MAC_CONFIGURATION_ENTRY_RESERVED1_SHIFT 6
+	u16 reserved0;
 	u32 clients_bit_vector;
 };
 
 /*
  * MAC filtering configuration command
  */
-struct mac_configuration_cmd_e1h {
+struct mac_configuration_cmd {
 	struct mac_configuration_hdr hdr;
-	struct mac_configuration_entry_e1h config_table[32];
+	struct mac_configuration_entry config_table[64];
 };
 
 
@@ -2827,65 +2419,6 @@ struct tstorm_eth_approximate_match_multicast_filtering {
 
 
 /*
- * Configuration parameters per client in Tstorm
- */
-struct tstorm_eth_client_config {
-#if defined(__BIG_ENDIAN)
-	u8 reserved0;
-	u8 statistics_counter_id;
-	u16 mtu;
-#elif defined(__LITTLE_ENDIAN)
-	u16 mtu;
-	u8 statistics_counter_id;
-	u8 reserved0;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 drop_flags;
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR (0x1<<0)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR_SHIFT 0
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR (0x1<<1)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR_SHIFT 1
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0 (0x1<<2)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 2
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<3)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 3
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2 (0xFFF<<4)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2_SHIFT 4
-	u16 config_flags;
-#define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE (0x1<<0)
-#define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE_SHIFT 0
-#define TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE (0x1<<1)
-#define TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE_SHIFT 1
-#define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE (0x1<<2)
-#define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE_SHIFT 2
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0x1FFF<<3)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 3
-#elif defined(__LITTLE_ENDIAN)
-	u16 config_flags;
-#define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE (0x1<<0)
-#define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE_SHIFT 0
-#define TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE (0x1<<1)
-#define TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE_SHIFT 1
-#define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE (0x1<<2)
-#define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE_SHIFT 2
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0x1FFF<<3)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 3
-	u16 drop_flags;
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR (0x1<<0)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR_SHIFT 0
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR (0x1<<1)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR_SHIFT 1
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0 (0x1<<2)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 2
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<3)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 3
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2 (0xFFF<<4)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2_SHIFT 4
-#endif
-};
-
-
-/*
  * MAC filtering configuration parameters per port in Tstorm
  */
 struct tstorm_eth_mac_filter_config {
@@ -2895,8 +2428,8 @@ struct tstorm_eth_mac_filter_config {
 	u32 mcast_accept_all;
 	u32 bcast_drop_all;
 	u32 bcast_accept_all;
-	u32 strict_vlan;
 	u32 vlan_filter[2];
+	u32 unmatched_unicast;
 	u32 reserved;
 };
 
@@ -2919,41 +2452,6 @@ struct tstorm_eth_tpa_exist {
 
 
 /*
- * rx rings pause data for E1h only
- */
-struct ustorm_eth_rx_pause_data_e1h {
-#if defined(__BIG_ENDIAN)
-	u16 bd_thr_low;
-	u16 cqe_thr_low;
-#elif defined(__LITTLE_ENDIAN)
-	u16 cqe_thr_low;
-	u16 bd_thr_low;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 cos;
-	u16 sge_thr_low;
-#elif defined(__LITTLE_ENDIAN)
-	u16 sge_thr_low;
-	u16 cos;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 bd_thr_high;
-	u16 cqe_thr_high;
-#elif defined(__LITTLE_ENDIAN)
-	u16 cqe_thr_high;
-	u16 bd_thr_high;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 reserved0;
-	u16 sge_thr_high;
-#elif defined(__LITTLE_ENDIAN)
-	u16 sge_thr_high;
-	u16 reserved0;
-#endif
-};
-
-
-/*
  * Three RX producers for ETH
  */
 struct ustorm_eth_rx_producers {
@@ -2975,6 +2473,18 @@ struct ustorm_eth_rx_producers {
 
 
 /*
+ * cfc delete event data
+ */
+struct cfc_del_event_data {
+	u32 cid;
+	u8 error;
+	u8 reserved0;
+	u16 reserved1;
+	u32 reserved2;
+};
+
+
+/*
  * per-port SAFC demo variables
  */
 struct cmng_flags_per_port {
@@ -2990,8 +2500,10 @@ struct cmng_flags_per_port {
 #define CMNG_FLAGS_PER_PORT_RATE_SHAPING_PROTOCOL_SHIFT 3
 #define CMNG_FLAGS_PER_PORT_FAIRNESS_COS (0x1<<4)
 #define CMNG_FLAGS_PER_PORT_FAIRNESS_COS_SHIFT 4
-#define __CMNG_FLAGS_PER_PORT_RESERVED0 (0x7FFFFFF<<5)
-#define __CMNG_FLAGS_PER_PORT_RESERVED0_SHIFT 5
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_COS_MODE (0x1<<5)
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_COS_MODE_SHIFT 5
+#define __CMNG_FLAGS_PER_PORT_RESERVED0 (0x3FFFFFF<<6)
+#define __CMNG_FLAGS_PER_PORT_RESERVED0_SHIFT 6
 };
 
 
@@ -3025,30 +2537,92 @@ struct safc_struct_per_port {
 	u8 __reserved0;
 	u16 __reserved1;
 #endif
+	u8 cos_to_traffic_types[MAX_COS_NUMBER];
+	u32 __reserved2;
 	u16 cos_to_pause_mask[NUM_OF_SAFC_BITS];
 };
 
 /*
+ * per-port PFC variables
+ */
+struct pfc_struct_per_port {
+	u8 priority_to_traffic_types[MAX_PFC_PRIORITIES];
+#if defined(__BIG_ENDIAN)
+	u16 pfc_pause_quanta_in_nanosec;
+	u8 __reserved0;
+	u8 priority_non_pausable_mask;
+#elif defined(__LITTLE_ENDIAN)
+	u8 priority_non_pausable_mask;
+	u8 __reserved0;
+	u16 pfc_pause_quanta_in_nanosec;
+#endif
+};
+
+/*
+ * Priority and cos
+ */
+struct priority_cos {
+#if defined(__BIG_ENDIAN)
+	u16 reserved1;
+	u8 cos;
+	u8 priority;
+#elif defined(__LITTLE_ENDIAN)
+	u8 priority;
+	u8 cos;
+	u16 reserved1;
+#endif
+	u32 reserved2;
+};
+
+/*
  * Per-port congestion management variables
  */
 struct cmng_struct_per_port {
 	struct rate_shaping_vars_per_port rs_vars;
 	struct fairness_vars_per_port fair_vars;
 	struct safc_struct_per_port safc_vars;
+	struct pfc_struct_per_port pfc_vars;
+#if defined(__BIG_ENDIAN)
+	u16 __reserved1;
+	u8 dcb_enabled;
+	u8 llfc_mode;
+#elif defined(__LITTLE_ENDIAN)
+	u8 llfc_mode;
+	u8 dcb_enabled;
+	u16 __reserved1;
+#endif
+	struct priority_cos
+		traffic_type_to_priority_cos[MAX_PFC_TRAFFIC_TYPES];
 	struct cmng_flags_per_port flags;
 };
 
 
+
+/*
+ * Dynamic HC counters set by the driver
+ */
+struct hc_dynamic_drv_counter {
+	u32 val[HC_SB_MAX_DYNAMIC_INDICES];
+};
+
+/*
+ * zone A per-queue data
+ */
+struct cstorm_queue_zone_data {
+	struct hc_dynamic_drv_counter hc_dyn_drv_cnt;
+	struct regpair reserved[2];
+};
+
 /*
  * Dynamic host coalescing init parameters
  */
 struct dynamic_hc_config {
 	u32 threshold[3];
-	u8 shift_per_protocol[HC_USTORM_SB_NUM_INDICES];
-	u8 hc_timeout0[HC_USTORM_SB_NUM_INDICES];
-	u8 hc_timeout1[HC_USTORM_SB_NUM_INDICES];
-	u8 hc_timeout2[HC_USTORM_SB_NUM_INDICES];
-	u8 hc_timeout3[HC_USTORM_SB_NUM_INDICES];
+	u8 shift_per_protocol[HC_SB_MAX_DYNAMIC_INDICES];
+	u8 hc_timeout0[HC_SB_MAX_DYNAMIC_INDICES];
+	u8 hc_timeout1[HC_SB_MAX_DYNAMIC_INDICES];
+	u8 hc_timeout2[HC_SB_MAX_DYNAMIC_INDICES];
+	u8 hc_timeout3[HC_SB_MAX_DYNAMIC_INDICES];
 };
 
 
@@ -3072,7 +2646,7 @@ struct xstorm_per_client_stats {
  * Common statistics collected by the Xstorm (per port)
  */
 struct xstorm_common_stats {
- struct xstorm_per_client_stats client_statistics[MAX_X_STAT_COUNTER_ID];
+	struct xstorm_per_client_stats client_statistics[MAX_STAT_COUNTER_ID];
 };
 
 /*
@@ -3109,7 +2683,7 @@ struct tstorm_per_client_stats {
  */
 struct tstorm_common_stats {
 	struct tstorm_per_port_stats port_statistics;
- struct tstorm_per_client_stats client_statistics[MAX_T_STAT_COUNTER_ID];
+	struct tstorm_per_client_stats client_statistics[MAX_STAT_COUNTER_ID];
 };
 
 /*
@@ -3130,7 +2704,7 @@ struct ustorm_per_client_stats {
  * Protocol-common statistics collected by the Ustorm
  */
 struct ustorm_common_stats {
- struct ustorm_per_client_stats client_statistics[MAX_U_STAT_COUNTER_ID];
+	struct ustorm_per_client_stats client_statistics[MAX_STAT_COUNTER_ID];
 };
 
 /*
@@ -3144,6 +2718,70 @@ struct eth_stats_query {
 
 
 /*
+ * set mac event data
+ */
+struct set_mac_event_data {
+	u16 echo;
+	u16 reserved0;
+	u32 reserved1;
+	u32 reserved2;
+};
+
+/*
+ * union for all event ring message types
+ */
+union event_data {
+	struct set_mac_event_data set_mac_event;
+	struct cfc_del_event_data cfc_del_event;
+};
+
+
+/*
+ * per PF event ring data
+ */
+struct event_ring_data {
+	struct regpair base_addr;
+#if defined(__BIG_ENDIAN)
+	u8 index_id;
+	u8 sb_id;
+	u16 producer;
+#elif defined(__LITTLE_ENDIAN)
+	u16 producer;
+	u8 sb_id;
+	u8 index_id;
+#endif
+	u32 reserved0;
+};
+
+
+/*
+ * event ring message element (each element is 128 bits)
+ */
+struct event_ring_msg {
+	u8 opcode;
+	u8 reserved0;
+	u16 reserved1;
+	union event_data data;
+};
+
+/*
+ * event ring next page element (128 bits)
+ */
+struct event_ring_next {
+	struct regpair addr;
+	u32 reserved[2];
+};
+
+/*
+ * union for event ring element types (each element is 128 bits)
+ */
+union event_ring_elem {
+	struct event_ring_msg message;
+	struct event_ring_next next_page;
+};
+
+
+/*
  * per-vnic fairness variables
  */
 struct fairness_vars_per_vn {
@@ -3182,6 +2820,137 @@ struct fw_version {
 
 
 /*
+ * Dynamic Host-Coalescing - Driver(host) counters
+ */
+struct hc_dynamic_sb_drv_counters {
+	u32 dynamic_hc_drv_counter[HC_SB_MAX_DYNAMIC_INDICES];
+};
+
+
+/*
+ * 2 bytes. configuration/state parameters for a single protocol index
+ */
+struct hc_index_data {
+#if defined(__BIG_ENDIAN)
+	u8 flags;
+#define HC_INDEX_DATA_SM_ID (0x1<<0)
+#define HC_INDEX_DATA_SM_ID_SHIFT 0
+#define HC_INDEX_DATA_HC_ENABLED (0x1<<1)
+#define HC_INDEX_DATA_HC_ENABLED_SHIFT 1
+#define HC_INDEX_DATA_DYNAMIC_HC_ENABLED (0x1<<2)
+#define HC_INDEX_DATA_DYNAMIC_HC_ENABLED_SHIFT 2
+#define HC_INDEX_DATA_RESERVE (0x1F<<3)
+#define HC_INDEX_DATA_RESERVE_SHIFT 3
+	u8 timeout;
+#elif defined(__LITTLE_ENDIAN)
+	u8 timeout;
+	u8 flags;
+#define HC_INDEX_DATA_SM_ID (0x1<<0)
+#define HC_INDEX_DATA_SM_ID_SHIFT 0
+#define HC_INDEX_DATA_HC_ENABLED (0x1<<1)
+#define HC_INDEX_DATA_HC_ENABLED_SHIFT 1
+#define HC_INDEX_DATA_DYNAMIC_HC_ENABLED (0x1<<2)
+#define HC_INDEX_DATA_DYNAMIC_HC_ENABLED_SHIFT 2
+#define HC_INDEX_DATA_RESERVE (0x1F<<3)
+#define HC_INDEX_DATA_RESERVE_SHIFT 3
+#endif
+};
+
+
+/*
+ * HC state-machine
+ */
+struct hc_status_block_sm {
+#if defined(__BIG_ENDIAN)
+	u8 igu_seg_id;
+	u8 igu_sb_id;
+	u8 timer_value;
+	u8 __flags;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __flags;
+	u8 timer_value;
+	u8 igu_sb_id;
+	u8 igu_seg_id;
+#endif
+	u32 time_to_expire;
+};
+
+/*
+ * hold PCI identification variables- used in various places in firmware
+ */
+struct pci_entity {
+#if defined(__BIG_ENDIAN)
+	u8 vf_valid;
+	u8 vf_id;
+	u8 vnic_id;
+	u8 pf_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 pf_id;
+	u8 vnic_id;
+	u8 vf_id;
+	u8 vf_valid;
+#endif
+};
+
+/*
+ * The fast-path status block meta-data, common to all chips
+ */
+struct hc_sb_data {
+	struct regpair host_sb_addr;
+	struct hc_status_block_sm state_machine[HC_SB_MAX_SM];
+	struct pci_entity p_func;
+#if defined(__BIG_ENDIAN)
+	u8 rsrv0;
+	u8 dhc_qzone_id;
+	u8 __dynamic_hc_level;
+	u8 same_igu_sb_1b;
+#elif defined(__LITTLE_ENDIAN)
+	u8 same_igu_sb_1b;
+	u8 __dynamic_hc_level;
+	u8 dhc_qzone_id;
+	u8 rsrv0;
+#endif
+	struct regpair rsrv1[2];
+};
+
+
+/*
+ * The fast-path status block meta-data
+ */
+struct hc_sp_status_block_data {
+	struct regpair host_sb_addr;
+#if defined(__BIG_ENDIAN)
+	u16 rsrv;
+	u8 igu_seg_id;
+	u8 igu_sb_id;
+#elif defined(__LITTLE_ENDIAN)
+	u8 igu_sb_id;
+	u8 igu_seg_id;
+	u16 rsrv;
+#endif
+	struct pci_entity p_func;
+};
+
+
+/*
+ * The fast-path status block meta-data
+ */
+struct hc_status_block_data_e1x {
+	struct hc_index_data index_data[HC_SB_MAX_INDICES_E1X];
+	struct hc_sb_data common;
+};
+
+
+/*
+ * The fast-path status block meta-data
+ */
+struct hc_status_block_data_e2 {
+	struct hc_index_data index_data[HC_SB_MAX_INDICES_E2];
+	struct hc_sb_data common;
+};
+
+
+/*
  * FW version stored in first line of pram
  */
 struct pram_fw_version {
@@ -3204,11 +2973,21 @@ struct pram_fw_version {
 
 
 /*
+ * Ethernet slow path element
+ */
+union protocol_common_specific_data {
+	u8 protocol_data[8];
+	struct regpair phy_address;
+	struct regpair mac_config_addr;
+	struct common_query_ramrod_data query_ramrod_data;
+};
+
+/*
  * The send queue element
  */
 struct protocol_common_spe {
 	struct spe_hdr hdr;
-	struct regpair phy_address;
+	union protocol_common_specific_data data;
 };
 
 
@@ -3241,7 +3020,7 @@ struct rate_shaping_vars_per_vn {
  */
 struct slow_path_element {
 	struct spe_hdr hdr;
-	u8 protocol_data[8];
+	struct regpair protocol_data;
 };
 
 
@@ -3254,3 +3033,97 @@ struct stats_indication_flags {
 };
 
 
+/*
+ * per-port PFC variables
+ */
+struct storm_pfc_struct_per_port {
+#if defined(__BIG_ENDIAN)
+	u16 mid_mac_addr;
+	u16 msb_mac_addr;
+#elif defined(__LITTLE_ENDIAN)
+	u16 msb_mac_addr;
+	u16 mid_mac_addr;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 pfc_pause_quanta_in_nanosec;
+	u16 lsb_mac_addr;
+#elif defined(__LITTLE_ENDIAN)
+	u16 lsb_mac_addr;
+	u16 pfc_pause_quanta_in_nanosec;
+#endif
+};
+
+/*
+ * Per-port congestion management variables
+ */
+struct storm_cmng_struct_per_port {
+	struct storm_pfc_struct_per_port pfc_vars;
+};
+
+
+/*
+ * zone A per-queue data
+ */
+struct tstorm_queue_zone_data {
+	struct regpair reserved[4];
+};
+
+
+/*
+ * zone B per-VF data
+ */
+struct tstorm_vf_zone_data {
+	struct regpair reserved;
+};
+
+
+/*
+ * zone A per-queue data
+ */
+struct ustorm_queue_zone_data {
+	struct ustorm_eth_rx_producers eth_rx_producers;
+	struct regpair reserved[3];
+};
+
+
+/*
+ * zone B per-VF data
+ */
+struct ustorm_vf_zone_data {
+	struct regpair reserved;
+};
+
+
+/*
+ * data per VF-PF channel
+ */
+struct vf_pf_channel_data {
+#if defined(__BIG_ENDIAN)
+	u16 reserved0;
+	u8 valid;
+	u8 state;
+#elif defined(__LITTLE_ENDIAN)
+	u8 state;
+	u8 valid;
+	u16 reserved0;
+#endif
+	u32 reserved1;
+};
+
+
+/*
+ * zone A per-queue data
+ */
+struct xstorm_queue_zone_data {
+	struct regpair reserved[4];
+};
+
+
+/*
+ * zone B per-VF data
+ */
+struct xstorm_vf_zone_data {
+	struct regpair reserved;
+};
+
+#endif /* BNX2X_HSI_H */
diff --git a/drivers/net/bnx2x/bnx2x_init.h b/drivers/net/bnx2x/bnx2x_init.h
index 65b26cb..5ae22e0 100644
--- a/drivers/net/bnx2x/bnx2x_init.h
+++ b/drivers/net/bnx2x/bnx2x_init.h
@@ -148,5 +148,46 @@ union init_op {
 	struct raw_op		raw;
 };
 
+#define INITOP_SET		0	/* set the HW directly */
+#define INITOP_CLEAR		1	/* clear the HW directly */
+#define INITOP_INIT		2	/* set the init-value array */
+
+/****************************************************************************
+* ILT management
+****************************************************************************/
+struct ilt_line {
+	dma_addr_t page_mapping;
+	void *page;
+	u32 size;
+};
+
+struct ilt_client_info {
+	u32 page_size;
+	u16 start;
+	u16 end;
+	u16 client_num;
+	u16 flags;
+#define ILT_CLIENT_SKIP_INIT	0x1
+#define ILT_CLIENT_SKIP_MEM	0x2
+};
+
+struct bnx2x_ilt {
+	u32 start_line;
+	struct ilt_line		*lines;
+	struct ilt_client_info	clients[4];
+#define ILT_CLIENT_CDU	0
+#define ILT_CLIENT_QM	1
+#define ILT_CLIENT_SRC	2
+#define ILT_CLIENT_TM	3
+};
+
+/****************************************************************************
+* SRC configuration
+****************************************************************************/
+struct src_ent {
+	u8 opaque[56];
+	u64 next;
+};
+
 #endif /* BNX2X_INIT_H */
 
diff --git a/drivers/net/bnx2x/bnx2x_init_ops.h b/drivers/net/bnx2x/bnx2x_init_ops.h
index 2b1363a..aae7fea 100644
--- a/drivers/net/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/bnx2x/bnx2x_init_ops.h
@@ -151,6 +151,15 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 		bnx2x_init_ind_wr(bp, addr, data, len);
 }
 
+static void bnx2x_wr_64(struct bnx2x *bp, u32 reg, u32 val_lo, u32 val_hi)
+{
+	u32 wb_write[2];
+
+	wb_write[0] = val_lo;
+	wb_write[1] = val_hi;
+	REG_WR_DMAE_LEN(bp, reg, wb_write, 2);
+}
+
 static void bnx2x_init_wr_zp(struct bnx2x *bp, u32 addr, u32 len, u32 blob_off)
 {
 	const u8 *data = NULL;
@@ -503,4 +512,333 @@ static void bnx2x_init_pxp_arb(struct bnx2x *bp, int r_order, int w_order)
 	}
 }
 
+/****************************************************************************
+* ILT management
+****************************************************************************/
+/*
+ * This codes hides the low level HW interaction for ILT management and
+ * configuration. The API consists of a shadow ILT table which is set by the
+ * driver and a set of routines to use it to configure the HW.
+ *
+ */
+
+/* ILT HW init operations */
+
+/* ILT memory management operations */
+#define ILT_MEMOP_ALLOC		0
+#define ILT_MEMOP_FREE		1
+
+/* the phys address is shifted right 12 bits and has an added
+ * 1=valid bit added to the 53rd bit
+ * then since this is a wide register(TM)
+ * we split it into two 32 bit writes
+ */
+#define ILT_ADDR1(x)		((u32)(((u64)x >> 12) & 0xFFFFFFFF))
+#define ILT_ADDR2(x)		((u32)((1 << 20) | ((u64)x >> 44)))
+#define ILT_RANGE(f, l)		(((l) << 10) | f)
+
+static int bnx2x_ilt_line_mem_op(struct bnx2x *bp, struct ilt_line *line,
+				 u32 size, u8 memop)
+{
+	if (memop == ILT_MEMOP_FREE) {
+		BNX2X_ILT_FREE(line->page, line->page_mapping, line->size);
+		return 0;
+	}
+	BNX2X_ILT_ZALLOC(line->page, &line->page_mapping, size);
+	if (!line->page)
+		return -1;
+	line->size = size;
+	return 0;
+}
+
+
+static int bnx2x_ilt_client_mem_op(struct bnx2x *bp, int cli_num, u8 memop)
+{
+	int i, rc;
+	struct bnx2x_ilt *ilt = BP_ILT(bp);
+	struct ilt_client_info *ilt_cli = &ilt->clients[cli_num];
+
+	if (!ilt || !ilt->lines)
+		return -1;
+
+	if (ilt_cli->flags & (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM))
+		return 0;
+
+	for (rc = 0, i = ilt_cli->start; i <= ilt_cli->end && !rc; i++) {
+		rc = bnx2x_ilt_line_mem_op(bp, &ilt->lines[i],
+					   ilt_cli->page_size, memop);
+	}
+	return rc;
+}
+
+int bnx2x_ilt_mem_op(struct bnx2x *bp, u8 memop)
+{
+	int rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_CDU, memop);
+	if (!rc)
+		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_QM, memop);
+	if (!rc)
+		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_SRC, memop);
+	if (!rc)
+		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_TM, memop);
+
+	return rc;
+}
+
+static void bnx2x_ilt_line_wr(struct bnx2x *bp, int abs_idx,
+			      dma_addr_t page_mapping)
+{
+	u32 reg;
+
+	if (CHIP_IS_E1(bp))
+		reg = PXP2_REG_RQ_ONCHIP_AT + abs_idx*8;
+	else
+		reg = PXP2_REG_RQ_ONCHIP_AT_B0 + abs_idx*8;
+
+	bnx2x_wr_64(bp, reg, ILT_ADDR1(page_mapping), ILT_ADDR2(page_mapping));
+}
+
+static void bnx2x_ilt_line_init_op(struct bnx2x *bp, struct bnx2x_ilt *ilt,
+				   int idx, u8 initop)
+{
+	dma_addr_t	null_mapping;
+	int abs_idx = ilt->start_line + idx;
+
+
+	switch (initop) {
+	case INITOP_INIT:
+		/* set in the init-value array */
+	case INITOP_SET:
+		bnx2x_ilt_line_wr(bp, abs_idx, ilt->lines[idx].page_mapping);
+		break;
+	case INITOP_CLEAR:
+		null_mapping = 0;
+		bnx2x_ilt_line_wr(bp, abs_idx, null_mapping);
+		break;
+	}
+}
+
+void bnx2x_ilt_boundry_init_op(struct bnx2x *bp,
+				      struct ilt_client_info *ilt_cli,
+				      u32 ilt_start, u8 initop)
+{
+	u32 start_reg = 0;
+	u32 end_reg = 0;
+
+	/* The boundary is either SET or INIT,
+	   CLEAR => SET and for now SET ~~ INIT */
+
+	/* find the appropriate regs */
+	if (CHIP_IS_E1(bp)) {
+		switch (ilt_cli->client_num) {
+		case ILT_CLIENT_CDU:
+			start_reg = PXP2_REG_PSWRQ_CDU0_L2P;
+			break;
+		case ILT_CLIENT_QM:
+			start_reg = PXP2_REG_PSWRQ_QM0_L2P;
+			break;
+		case ILT_CLIENT_SRC:
+			start_reg = PXP2_REG_PSWRQ_SRC0_L2P;
+			break;
+		case ILT_CLIENT_TM:
+			start_reg = PXP2_REG_PSWRQ_TM0_L2P;
+			break;
+		}
+		REG_WR(bp, start_reg + BP_FUNC(bp)*4,
+		       ILT_RANGE((ilt_start + ilt_cli->start),
+				 (ilt_start + ilt_cli->end)));
+	} else {
+		switch (ilt_cli->client_num) {
+		case ILT_CLIENT_CDU:
+			start_reg = PXP2_REG_RQ_CDU_FIRST_ILT;
+			end_reg = PXP2_REG_RQ_CDU_LAST_ILT;
+			break;
+		case ILT_CLIENT_QM:
+			start_reg = PXP2_REG_RQ_QM_FIRST_ILT;
+			end_reg = PXP2_REG_RQ_QM_LAST_ILT;
+			break;
+		case ILT_CLIENT_SRC:
+			start_reg = PXP2_REG_RQ_SRC_FIRST_ILT;
+			end_reg = PXP2_REG_RQ_SRC_LAST_ILT;
+			break;
+		case ILT_CLIENT_TM:
+			start_reg = PXP2_REG_RQ_TM_FIRST_ILT;
+			end_reg = PXP2_REG_RQ_TM_LAST_ILT;
+			break;
+		}
+		REG_WR(bp, start_reg, (ilt_start + ilt_cli->start));
+		REG_WR(bp, end_reg, (ilt_start + ilt_cli->end));
+	}
+}
+
+void bnx2x_ilt_client_init_op_ilt(struct bnx2x *bp, struct bnx2x_ilt *ilt,
+				  struct ilt_client_info *ilt_cli, u8 initop)
+{
+	int i;
+
+	if (ilt_cli->flags & ILT_CLIENT_SKIP_INIT)
+		return;
+
+	for (i = ilt_cli->start; i <= ilt_cli->end; i++)
+		bnx2x_ilt_line_init_op(bp, ilt, i, initop);
+
+	/* init/clear the ILT boundries */
+	bnx2x_ilt_boundry_init_op(bp, ilt_cli, ilt->start_line, initop);
+}
+
+void bnx2x_ilt_client_init_op(struct bnx2x *bp,
+			      struct ilt_client_info *ilt_cli, u8 initop)
+{
+	struct bnx2x_ilt *ilt = BP_ILT(bp);
+
+	bnx2x_ilt_client_init_op_ilt(bp, ilt, ilt_cli, initop);
+}
+
+static void bnx2x_ilt_client_id_init_op(struct bnx2x *bp,
+					int cli_num, u8 initop)
+{
+	struct bnx2x_ilt *ilt = BP_ILT(bp);
+	struct ilt_client_info *ilt_cli = &ilt->clients[cli_num];
+
+	bnx2x_ilt_client_init_op(bp, ilt_cli, initop);
+}
+
+void bnx2x_ilt_init_op(struct bnx2x *bp, u8 initop)
+{
+	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_CDU, initop);
+	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_QM, initop);
+	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_SRC, initop);
+	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_TM, initop);
+}
+
+static void bnx2x_ilt_init_client_psz(struct bnx2x *bp, int cli_num,
+					    u32 psz_reg, u8 initop)
+{
+	struct bnx2x_ilt *ilt = BP_ILT(bp);
+	struct ilt_client_info *ilt_cli = &ilt->clients[cli_num];
+
+	if (ilt_cli->flags & ILT_CLIENT_SKIP_INIT)
+		return;
+
+	switch (initop) {
+	case INITOP_INIT:
+		/* set in the init-value array */
+	case INITOP_SET:
+		REG_WR(bp, psz_reg, ILOG2(ilt_cli->page_size >> 12));
+		break;
+	case INITOP_CLEAR:
+		break;
+	}
+}
+
+/*
+ * called during init common stage, ilt clients should be initialized
+ * prioir to calling this function
+ */
+void bnx2x_ilt_init_page_size(struct bnx2x *bp, u8 initop)
+{
+	bnx2x_ilt_init_client_psz(bp, ILT_CLIENT_CDU,
+				  PXP2_REG_RQ_CDU_P_SIZE, initop);
+	bnx2x_ilt_init_client_psz(bp, ILT_CLIENT_QM,
+				  PXP2_REG_RQ_QM_P_SIZE, initop);
+	bnx2x_ilt_init_client_psz(bp, ILT_CLIENT_SRC,
+				  PXP2_REG_RQ_SRC_P_SIZE, initop);
+	bnx2x_ilt_init_client_psz(bp, ILT_CLIENT_TM,
+				  PXP2_REG_RQ_TM_P_SIZE, initop);
+}
+
+/****************************************************************************
+* QM initializations
+****************************************************************************/
+#define QM_QUEUES_PER_FUNC	16 /* E1 has 32, but only 16 are used */
+#define QM_INIT_MIN_CID_COUNT	31
+#define QM_INIT(cid_cnt)	(cid_cnt > QM_INIT_MIN_CID_COUNT)
+
+/* called during init port stage */
+void bnx2x_qm_init_cid_count(struct bnx2x *bp, int qm_cid_count,
+			     u8 initop)
+{
+	int port = BP_PORT(bp);
+
+	if (QM_INIT(qm_cid_count)) {
+		switch (initop) {
+		case INITOP_INIT:
+			/* set in the init-value array */
+		case INITOP_SET:
+			REG_WR(bp, QM_REG_CONNNUM_0 + port*4,
+			       qm_cid_count/16 - 1);
+			break;
+		case INITOP_CLEAR:
+			break;
+		}
+	}
+}
+
+static void bnx2x_qm_set_ptr_table(struct bnx2x *bp, int qm_cid_count)
+{
+	int i;
+	u32 wb_data[2];
+
+	wb_data[0] = wb_data[1] = 0;
+
+	for (i = 0; i < 4 * QM_QUEUES_PER_FUNC; i++) {
+		REG_WR(bp, QM_REG_BASEADDR + i*4,
+		       qm_cid_count * 4 * (i % QM_QUEUES_PER_FUNC));
+		bnx2x_init_ind_wr(bp, QM_REG_PTRTBL + i*8,
+				  wb_data, 2);
+
+		if (CHIP_IS_E1H(bp)) {
+			REG_WR(bp, QM_REG_BASEADDR_EXT_A + i*4,
+			       qm_cid_count * 4 * (i % QM_QUEUES_PER_FUNC));
+			bnx2x_init_ind_wr(bp, QM_REG_PTRTBL_EXT_A + i*8,
+					  wb_data, 2);
+		}
+	}
+}
+
+/* called during init common stage */
+void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
+			     u8 initop)
+{
+	if (!QM_INIT(qm_cid_count))
+		return;
+
+	switch (initop) {
+	case INITOP_INIT:
+		/* set in the init-value array */
+	case INITOP_SET:
+		bnx2x_qm_set_ptr_table(bp, qm_cid_count);
+		break;
+	case INITOP_CLEAR:
+		break;
+	}
+}
+
+/****************************************************************************
+* SRC initializations
+****************************************************************************/
+
+/* called during init func stage */
+void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
+		       dma_addr_t t2_mapping, int src_cid_count)
+{
+	int i;
+	int port = BP_PORT(bp);
+
+	/* Initialize T2 */
+	for (i = 0; i < src_cid_count-1; i++)
+		t2[i].next = (u64)(t2_mapping + (i+1)*sizeof(struct src_ent));
+
+	/* tell the searcher where the T2 table is */
+	REG_WR(bp, SRC_REG_COUNTFREE0 + port*4, src_cid_count);
+
+	bnx2x_wr_64(bp, SRC_REG_FIRSTFREE0 + port*16,
+		    U64_LO(t2_mapping), U64_HI(t2_mapping));
+
+	bnx2x_wr_64(bp, SRC_REG_LASTFREE0 + port*16,
+		    U64_LO((u64)t2_mapping +
+			   (src_cid_count-1) * sizeof(struct src_ent)),
+		    U64_HI((u64)t2_mapping +
+			   (src_cid_count-1) * sizeof(struct src_ent)));
+}
+
 #endif /* BNX2X_INIT_OPS_H */
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index a07a3a6..51d468d 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -28,7 +28,7 @@
 
 /********************************************************/
 #define ETH_HLEN			14
-#define ETH_OVREHEAD		(ETH_HLEN + 8)/* 8 for CRC + VLAN*/
+#define ETH_OVREHEAD		(ETH_HLEN + 8 + 8)/* 16 for CRC + VLAN + LLC */
 #define ETH_MIN_PACKET_SIZE		60
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
@@ -4066,6 +4066,7 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 			  "verification\n");
 		return -EINVAL;
 	}
+
 	fw_cmd_param = FW_PARAM_SET(phy->addr, phy->type, phy->mdio_ctrl);
 	fw_resp = bnx2x_fw_command(bp, cmd, fw_cmd_param);
 	if (fw_resp == FW_MSG_CODE_VRFY_OPT_MDL_SUCCESS) {
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 3696a4b..119ca87 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -149,6 +149,242 @@ MODULE_DEVICE_TABLE(pci, bnx2x_pci_tbl);
 * General service functions
 ****************************************************************************/
 
+static inline void __storm_memset_dma_mapping(struct bnx2x *bp,
+				       u32 addr, dma_addr_t mapping)
+{
+	REG_WR(bp,  addr, U64_LO(mapping));
+	REG_WR(bp,  addr + 4, U64_HI(mapping));
+}
+
+static inline void __storm_memset_fill(struct bnx2x *bp,
+				       u32 addr, size_t size, u32 val)
+{
+	int i;
+	for (i = 0; i < size/4; i++)
+		REG_WR(bp,  addr + (i * 4), val);
+}
+
+static inline void storm_memset_ustats_zero(struct bnx2x *bp,
+					    u8 port, u16 stat_id)
+{
+	size_t size = sizeof(struct ustorm_per_client_stats);
+
+	u32 addr = BAR_USTRORM_INTMEM +
+			USTORM_PER_COUNTER_ID_STATS_OFFSET(port, stat_id);
+
+	__storm_memset_fill(bp, addr, size, 0);
+}
+
+static inline void storm_memset_tstats_zero(struct bnx2x *bp,
+					    u8 port, u16 stat_id)
+{
+	size_t size = sizeof(struct tstorm_per_client_stats);
+
+	u32 addr = BAR_TSTRORM_INTMEM +
+			TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stat_id);
+
+	__storm_memset_fill(bp, addr, size, 0);
+}
+
+static inline void storm_memset_xstats_zero(struct bnx2x *bp,
+					    u8 port, u16 stat_id)
+{
+	size_t size = sizeof(struct xstorm_per_client_stats);
+
+	u32 addr = BAR_XSTRORM_INTMEM +
+			XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stat_id);
+
+	__storm_memset_fill(bp, addr, size, 0);
+}
+
+
+static inline void storm_memset_spq_addr(struct bnx2x *bp,
+					 dma_addr_t mapping, u16 abs_fid)
+{
+	u32 addr = XSEM_REG_FAST_MEMORY +
+			XSTORM_SPQ_PAGE_BASE_OFFSET(abs_fid);
+
+	__storm_memset_dma_mapping(bp, addr, mapping);
+}
+
+static inline void storm_memset_ov(struct bnx2x *bp, u16 ov, u16 abs_fid)
+{
+	REG_WR16(bp, BAR_XSTRORM_INTMEM + XSTORM_E1HOV_OFFSET(abs_fid), ov);
+}
+
+static inline void storm_memset_func_cfg(struct bnx2x *bp,
+				struct tstorm_eth_function_common_config *tcfg,
+				u16 abs_fid)
+{
+	size_t size = sizeof(struct tstorm_eth_function_common_config);
+
+	u32 addr = BAR_TSTRORM_INTMEM +
+			TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)tcfg);
+}
+
+static inline void storm_memset_xstats_flags(struct bnx2x *bp,
+				struct stats_indication_flags *flags,
+				u16 abs_fid)
+{
+	size_t size = sizeof(struct stats_indication_flags);
+
+	u32 addr = BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)flags);
+}
+
+static inline void storm_memset_tstats_flags(struct bnx2x *bp,
+				struct stats_indication_flags *flags,
+				u16 abs_fid)
+{
+	size_t size = sizeof(struct stats_indication_flags);
+
+	u32 addr = BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)flags);
+}
+
+static inline void storm_memset_ustats_flags(struct bnx2x *bp,
+				struct stats_indication_flags *flags,
+				u16 abs_fid)
+{
+	size_t size = sizeof(struct stats_indication_flags);
+
+	u32 addr = BAR_USTRORM_INTMEM + USTORM_STATS_FLAGS_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)flags);
+}
+
+static inline void storm_memset_cstats_flags(struct bnx2x *bp,
+				struct stats_indication_flags *flags,
+				u16 abs_fid)
+{
+	size_t size = sizeof(struct stats_indication_flags);
+
+	u32 addr = BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(abs_fid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)flags);
+}
+
+static inline void storm_memset_xstats_addr(struct bnx2x *bp,
+					   dma_addr_t mapping, u16 abs_fid)
+{
+	u32 addr = BAR_XSTRORM_INTMEM +
+		XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(abs_fid);
+
+	__storm_memset_dma_mapping(bp, addr, mapping);
+}
+
+static inline void storm_memset_tstats_addr(struct bnx2x *bp,
+					   dma_addr_t mapping, u16 abs_fid)
+{
+	u32 addr = BAR_TSTRORM_INTMEM +
+		TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(abs_fid);
+
+	__storm_memset_dma_mapping(bp, addr, mapping);
+}
+
+static inline void storm_memset_ustats_addr(struct bnx2x *bp,
+					   dma_addr_t mapping, u16 abs_fid)
+{
+	u32 addr = BAR_USTRORM_INTMEM +
+		USTORM_ETH_STATS_QUERY_ADDR_OFFSET(abs_fid);
+
+	__storm_memset_dma_mapping(bp, addr, mapping);
+}
+
+static inline void storm_memset_cstats_addr(struct bnx2x *bp,
+					   dma_addr_t mapping, u16 abs_fid)
+{
+	u32 addr = BAR_CSTRORM_INTMEM +
+		CSTORM_ETH_STATS_QUERY_ADDR_OFFSET(abs_fid);
+
+	__storm_memset_dma_mapping(bp, addr, mapping);
+}
+
+static inline void storm_memset_vf_to_pf(struct bnx2x *bp, u16 abs_fid,
+					 u16 pf_id)
+{
+	REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_VF_TO_PF_OFFSET(abs_fid),
+		pf_id);
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_VF_TO_PF_OFFSET(abs_fid),
+		pf_id);
+	REG_WR8(bp, BAR_TSTRORM_INTMEM + TSTORM_VF_TO_PF_OFFSET(abs_fid),
+		pf_id);
+	REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_VF_TO_PF_OFFSET(abs_fid),
+		pf_id);
+}
+
+static inline void storm_memset_func_en(struct bnx2x *bp, u16 abs_fid,
+					u8 enable)
+{
+	REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNC_EN_OFFSET(abs_fid),
+		enable);
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_FUNC_EN_OFFSET(abs_fid),
+		enable);
+	REG_WR8(bp, BAR_TSTRORM_INTMEM + TSTORM_FUNC_EN_OFFSET(abs_fid),
+		enable);
+	REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_FUNC_EN_OFFSET(abs_fid),
+		enable);
+}
+
+static inline void storm_memset_eq_data(struct bnx2x *bp,
+				struct event_ring_data *eq_data,
+				u16 pfid)
+{
+	size_t size = sizeof(struct event_ring_data);
+
+	u32 addr = BAR_CSTRORM_INTMEM + CSTORM_EVENT_RING_DATA_OFFSET(pfid);
+
+	__storm_memset_struct(bp, addr, size, (u32 *)eq_data);
+}
+
+static inline void storm_memset_eq_prod(struct bnx2x *bp, u16 eq_prod,
+					u16 pfid)
+{
+	u32 addr = BAR_CSTRORM_INTMEM + CSTORM_EVENT_RING_PROD_OFFSET(pfid);
+	REG_WR16(bp, addr, eq_prod);
+}
+
+static inline void storm_memset_hc_timeout(struct bnx2x *bp, u8 port,
+					     u16 fw_sb_id, u8 sb_index,
+					     u8 ticks)
+{
+
+	int index_offset =
+		offsetof(struct hc_status_block_data_e1x, index_data);
+	u32 addr = BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_OFFSET(fw_sb_id) +
+			index_offset +
+			sizeof(struct hc_index_data)*sb_index +
+			offsetof(struct hc_index_data, timeout);
+	REG_WR8(bp, addr, ticks);
+	DP(NETIF_MSG_HW, "port %x fw_sb_id %d sb_index %d ticks %d\n",
+			  port, fw_sb_id, sb_index, ticks);
+}
+static inline void storm_memset_hc_disable(struct bnx2x *bp, u8 port,
+					     u16 fw_sb_id, u8 sb_index,
+					     u8 disable)
+{
+	u32 enable_flag = disable ? 0 : (1 << HC_INDEX_DATA_HC_ENABLED_SHIFT);
+	int index_offset =
+		offsetof(struct hc_status_block_data_e1x, index_data);
+	u32 addr = BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_OFFSET(fw_sb_id) +
+			index_offset +
+			sizeof(struct hc_index_data)*sb_index +
+			offsetof(struct hc_index_data, flags);
+	u16 flags = REG_RD16(bp, addr);
+	/* clear and set */
+	flags &= ~HC_INDEX_DATA_HC_ENABLED;
+	flags |= enable_flag;
+	REG_WR16(bp, addr, flags);
+	DP(NETIF_MSG_HW, "port %x fw_sb_id %d sb_index %d disable %d\n",
+			  port, fw_sb_id, sb_index, disable);
+}
+
 /* used only at init
  * locking is done by mcp
  */
@@ -538,7 +774,12 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 void bnx2x_panic_dump(struct bnx2x *bp)
 {
 	int i;
-	u16 j, start, end;
+	u16 j;
+	struct hc_sp_status_block_data sp_sb_data;
+	int func = BP_FUNC(bp);
+#ifdef BNX2X_STOP_ON_ERROR
+	u16 start = 0, end = 0;
+#endif
 
 	bp->stats_state = STATS_STATE_DISABLED;
 	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
@@ -547,44 +788,124 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 
 	/* Indices */
 	/* Common */
-	BNX2X_ERR("def_c_idx(0x%x)  def_u_idx(0x%x)  def_x_idx(0x%x)"
-		  "  def_t_idx(0x%x)  def_att_idx(0x%x)  attn_state(0x%x)"
+	BNX2X_ERR("def_idx(0x%x)  def_att_idx(0x%x)  attn_state(0x%x)"
 		  "  spq_prod_idx(0x%x)\n",
-		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
-		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
+		  bp->def_idx, bp->def_att_idx,
+		  bp->attn_state, bp->spq_prod_idx);
+	BNX2X_ERR("DSB: attn bits(0x%x)  ack(0x%x)  id(0x%x)  idx(0x%x)\n",
+		  bp->def_status_blk->atten_status_block.attn_bits,
+		  bp->def_status_blk->atten_status_block.attn_bits_ack,
+		  bp->def_status_blk->atten_status_block.status_block_id,
+		  bp->def_status_blk->atten_status_block.attn_bits_index);
+	BNX2X_ERR("     def (");
+	for (i = 0; i < HC_SP_SB_MAX_INDICES; i++)
+		pr_cont("0x%x%s",
+		       bp->def_status_blk->sp_sb.index_values[i],
+		       (i == HC_SP_SB_MAX_INDICES - 1) ? ")  " : " ");
+
+	for (i = 0; i < sizeof(struct hc_sp_status_block_data)/sizeof(u32); i++)
+		*((u32 *)&sp_sb_data + i) = REG_RD(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(func) +
+			i*sizeof(u32));
+
+	pr_cont("igu_sb_id(0x%x)  igu_seg_id (0x%x) "
+			 "pf_id(0x%x)  vnic_id(0x%x)  "
+			 "vf_id(0x%x)  vf_valid (0x%x)\n",
+	       sp_sb_data.igu_sb_id,
+	       sp_sb_data.igu_seg_id,
+	       sp_sb_data.p_func.pf_id,
+	       sp_sb_data.p_func.vnic_id,
+	       sp_sb_data.p_func.vf_id,
+	       sp_sb_data.p_func.vf_valid);
+
 
-	/* Rx */
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
-
+		int loop;
+		struct hc_status_block_data_e1x sb_data_e1x;
+		struct hc_status_block_sm  *hc_sm_p =
+			sb_data_e1x.common.state_machine;
+		struct hc_index_data *hc_index_p =
+			sb_data_e1x.index_data;
+		int data_size;
+		u32 *sb_data_p;
+
+		/* Rx */
 		BNX2X_ERR("fp%d: rx_bd_prod(0x%x)  rx_bd_cons(0x%x)"
-			  "  *rx_bd_cons_sb(0x%x)  rx_comp_prod(0x%x)"
+			  "  rx_comp_prod(0x%x)"
 			  "  rx_comp_cons(0x%x)  *rx_cons_sb(0x%x)\n",
 			  i, fp->rx_bd_prod, fp->rx_bd_cons,
-			  le16_to_cpu(*fp->rx_bd_cons_sb), fp->rx_comp_prod,
+			  fp->rx_comp_prod,
 			  fp->rx_comp_cons, le16_to_cpu(*fp->rx_cons_sb));
 		BNX2X_ERR("     rx_sge_prod(0x%x)  last_max_sge(0x%x)"
-			  "  fp_u_idx(0x%x) *sb_u_idx(0x%x)\n",
+			  "  fp_hc_idx(0x%x)\n",
 			  fp->rx_sge_prod, fp->last_max_sge,
-			  le16_to_cpu(fp->fp_u_idx),
-			  fp->status_blk->u_status_block.status_block_index);
-	}
-
-	/* Tx */
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
+			  le16_to_cpu(fp->fp_hc_idx));
 
+		/* Tx */
 		BNX2X_ERR("fp%d: tx_pkt_prod(0x%x)  tx_pkt_cons(0x%x)"
 			  "  tx_bd_prod(0x%x)  tx_bd_cons(0x%x)"
 			  "  *tx_cons_sb(0x%x)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
-		BNX2X_ERR("     fp_c_idx(0x%x)  *sb_c_idx(0x%x)"
-			  "  tx_db_prod(0x%x)\n", le16_to_cpu(fp->fp_c_idx),
-			  fp->status_blk->c_status_block.status_block_index,
-			  fp->tx_db.data.prod);
+
+		loop = HC_SB_MAX_INDICES_E1X;
+
+		/* host sb data */
+
+		BNX2X_ERR("     run indexes (");
+		for (j = 0; j < HC_SB_MAX_SM; j++)
+			pr_cont("0x%x%s",
+			       fp->sb_running_index[j],
+			       (j == HC_SB_MAX_SM - 1) ? ")" : " ");
+
+		BNX2X_ERR("     indexes (");
+		for (j = 0; j < loop; j++)
+			pr_cont("0x%x%s",
+			       fp->sb_index_values[j],
+			       (j == loop - 1) ? ")" : " ");
+		/* fw sb data */
+		data_size =
+			sizeof(struct hc_status_block_data_e1x);
+		data_size /= sizeof(u32);
+		sb_data_p = (u32 *)&sb_data_e1x;
+		/* copy sb data in here */
+		for (j = 0; j < data_size; j++)
+			*(sb_data_p + j) = REG_RD(bp, BAR_CSTRORM_INTMEM +
+				CSTORM_STATUS_BLOCK_DATA_OFFSET(fp->fw_sb_id) +
+				j * sizeof(u32));
+
+		pr_cont("pf_id(0x%x)  vf_id (0x%x)  vf_valid(0x%x) "
+			"vnic_id(0x%x)  same_igu_sb_1b(0x%x)\n",
+			sb_data_e1x.common.p_func.pf_id,
+			sb_data_e1x.common.p_func.vf_id,
+			sb_data_e1x.common.p_func.vf_valid,
+			sb_data_e1x.common.p_func.vnic_id,
+			sb_data_e1x.common.same_igu_sb_1b);
+
+		/* SB_SMs data */
+		for (j = 0; j < HC_SB_MAX_SM; j++) {
+			pr_cont("SM[%d] __flags (0x%x) "
+			       "igu_sb_id (0x%x)  igu_seg_id(0x%x) "
+			       "time_to_expire (0x%x) "
+			       "timer_value(0x%x)\n", j,
+			       hc_sm_p[j].__flags,
+			       hc_sm_p[j].igu_sb_id,
+			       hc_sm_p[j].igu_seg_id,
+			       hc_sm_p[j].time_to_expire,
+			       hc_sm_p[j].timer_value);
+		}
+
+		/* Indecies data */
+		for (j = 0; j < loop; j++) {
+			pr_cont("INDEX[%d] flags (0x%x) "
+					 "timeout (0x%x)\n", j,
+			       hc_index_p[j].flags,
+			       hc_index_p[j].timeout);
+		}
 	}
 
+#ifdef BNX2X_STOP_ON_ERROR
 	/* Rings */
 	/* Rx */
 	for_each_queue(bp, i) {
@@ -642,7 +963,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 				  i, j, tx_bd[0], tx_bd[1], tx_bd[2], tx_bd[3]);
 		}
 	}
-
+#endif
 	bnx2x_fw_dump(bp);
 	bnx2x_mc_assert(bp);
 	BNX2X_ERR("end crash dump -----------------\n");
@@ -708,7 +1029,7 @@ void bnx2x_int_enable(struct bnx2x *bp)
 	mmiowb();
 }
 
-static void bnx2x_int_disable(struct bnx2x *bp)
+void bnx2x_int_disable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -817,76 +1138,35 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 	   fp->index, cid, command, bp->state,
 	   rr_cqe->ramrod_cqe.ramrod_type);
 
-	bp->spq_left++;
-
-	if (fp->index) {
-		switch (command | fp->state) {
-		case (RAMROD_CMD_ID_ETH_CLIENT_SETUP |
-						BNX2X_FP_STATE_OPENING):
-			DP(NETIF_MSG_IFUP, "got MULTI[%d] setup ramrod\n",
-			   cid);
-			fp->state = BNX2X_FP_STATE_OPEN;
-			break;
-
-		case (RAMROD_CMD_ID_ETH_HALT | BNX2X_FP_STATE_HALTING):
-			DP(NETIF_MSG_IFDOWN, "got MULTI[%d] halt ramrod\n",
-			   cid);
-			fp->state = BNX2X_FP_STATE_HALTED;
-			break;
-
-		default:
-			BNX2X_ERR("unexpected MC reply (%d)  "
-				  "fp[%d] state is %x\n",
-				  command, fp->index, fp->state);
-			break;
-		}
-		mb(); /* force bnx2x_wait_ramrod() to see the change */
-		return;
-	}
-
-	switch (command | bp->state) {
-	case (RAMROD_CMD_ID_ETH_PORT_SETUP | BNX2X_STATE_OPENING_WAIT4_PORT):
-		DP(NETIF_MSG_IFUP, "got setup ramrod\n");
-		bp->state = BNX2X_STATE_OPEN;
+	switch (command | fp->state) {
+	case (RAMROD_CMD_ID_ETH_CLIENT_SETUP | BNX2X_FP_STATE_OPENING):
+		DP(NETIF_MSG_IFUP, "got MULTI[%d] setup ramrod\n", cid);
+		fp->state = BNX2X_FP_STATE_OPEN;
 		break;
 
-	case (RAMROD_CMD_ID_ETH_HALT | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFDOWN, "got halt ramrod\n");
-		bp->state = BNX2X_STATE_CLOSING_WAIT4_DELETE;
+	case (RAMROD_CMD_ID_ETH_HALT | BNX2X_FP_STATE_HALTING):
+		DP(NETIF_MSG_IFDOWN, "got MULTI[%d] halt ramrod\n", cid);
 		fp->state = BNX2X_FP_STATE_HALTED;
 		break;
 
-	case (RAMROD_CMD_ID_ETH_CFC_DEL | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n", cid);
-		bnx2x_fp(bp, cid, state) = BNX2X_FP_STATE_CLOSED;
+	case (RAMROD_CMD_ID_ETH_TERMINATE | BNX2X_FP_STATE_TERMINATING):
+		DP(NETIF_MSG_IFDOWN, "got MULTI[%d] teminate ramrod\n", cid);
+		fp->state = BNX2X_FP_STATE_TERMINATED;
 		break;
 
-#ifdef BCM_CNIC
-	case (RAMROD_CMD_ID_ETH_CFC_DEL | BNX2X_STATE_OPEN):
-		DP(NETIF_MSG_IFDOWN, "got delete ramrod for CID %d\n", cid);
-		bnx2x_cnic_cfc_comp(bp, cid);
+	default:
+		BNX2X_ERR("unexpected MC reply (%d)  "
+			  "fp[%d] state is %x\n",
+			  command, fp->index, fp->state);
 		break;
-#endif
+	}
 
-	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
-	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
-		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
-		bp->set_mac_pending--;
-		smp_wmb();
-		break;
+	bp->spq_left++;
 
-	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
-		bp->set_mac_pending--;
-		smp_wmb();
-		break;
+	/* push the change in fp->state and towards the memory */
+	smp_wmb();
 
-	default:
-		BNX2X_ERR("unexpected MC reply (%d)  bp->state is %x\n",
-			  command, bp->state);
-		break;
-	}
-	mb(); /* force bnx2x_wait_ramrod() to see the change */
+	return;
 }
 
 irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
@@ -917,22 +1197,19 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	for (i = 0; i < BNX2X_NUM_QUEUES(bp); i++) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		mask = 0x2 << fp->sb_id;
+		mask = 0x2 << (fp->index + CNIC_CONTEXT_USE);
 		if (status & mask) {
 			/* Handle Rx and Tx according to SB id */
 			prefetch(fp->rx_cons_sb);
-			prefetch(&fp->status_blk->u_status_block.
-						status_block_index);
 			prefetch(fp->tx_cons_sb);
-			prefetch(&fp->status_blk->c_status_block.
-						status_block_index);
+			prefetch(&fp->sb_running_index[SM_RX_ID]);
 			napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 			status &= ~mask;
 		}
 	}
 
 #ifdef BCM_CNIC
-	mask = 0x2 << CNIC_SB_ID(bp);
+	mask = 0x2;
 	if (status & (mask | 0x1)) {
 		struct cnic_ops *c_ops = NULL;
 
@@ -1422,7 +1699,7 @@ static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
 	bp->vn_weight_sum = 0;
 	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
 		int func = 2*vn + port;
-		u32 vn_cfg = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+		u32 vn_cfg = MF_CFG_RD(bp, func_mf_config[func].config);
 		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				   FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
 
@@ -1454,7 +1731,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 {
 	struct rate_shaping_vars_per_vn m_rs_vn;
 	struct fairness_vars_per_vn m_fair_vn;
-	u32 vn_cfg = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+	u32 vn_cfg = MF_CFG_RD(bp, func_mf_config[func].config);
 	u16 vn_min_rate, vn_max_rate;
 	int i;
 
@@ -1511,7 +1788,83 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 		       XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(func) + i * 4,
 		       ((u32 *)(&m_fair_vn))[i]);
 }
+static int bnx2x_get_cmng_fns_mode(struct bnx2x *bp)
+{
+	if (CHIP_REV_IS_SLOW(bp))
+		return CMNG_FNS_NONE;
+	if (IS_E1HMF(bp))
+		return CMNG_FNS_MINMAX;
+
+	return CMNG_FNS_NONE;
+}
+
+static void bnx2x_read_mf_cfg(struct bnx2x *bp)
+{
+	int vn;
+
+	if (BP_NOMCP(bp))
+		return; /* what should be the default bvalue in this case */
+
+	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
+		int /*abs*/func = 2*vn + BP_PORT(bp);
+		bp->mf_config =
+			MF_CFG_RD(bp, func_mf_config[func].config);
+	}
+}
+
+static void bnx2x_cmng_fns_init(struct bnx2x *bp, u8 read_cfg, u8 cmng_type)
+{
+
+	if (cmng_type == CMNG_FNS_MINMAX) {
+		int vn;
+
+		/* clear cmng_enables */
+		bp->cmng.flags.cmng_enables = 0;
+
+		/* read mf conf from shmem */
+		if (read_cfg)
+			bnx2x_read_mf_cfg(bp);
+
+		/* Init rate shaping and fairness contexts */
+		bnx2x_init_port_minmax(bp);
+
+		/* vn_weight_sum and enable fairness if not 0 */
+		bnx2x_calc_vn_weight_sum(bp);
+
+		/* calculate and set min-max rate for each vn */
+		for (vn = VN_0; vn < E1HVN_MAX; vn++)
+			bnx2x_init_vn_minmax(bp, vn);
+
+		/* always enable rate shaping and fairness */
+		bp->cmng.flags.cmng_enables |=
+					CMNG_FLAGS_PER_PORT_RATE_SHAPING_VN;
+		if (!bp->vn_weight_sum)
+			DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
+				   "  fairness will be disabled\n");
+		return;
+	}
+
+	/* rate shaping and fairness are disabled */
+	DP(NETIF_MSG_IFUP,
+	   "rate shaping and fairness are disabled\n");
+}
+
+static inline void bnx2x_link_sync_notify(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int func;
+	int vn;
 
+	/* Set the attention towards other drivers on the same port */
+	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
+		if (vn == BP_E1HVN(bp))
+			continue;
+
+		func = ((vn << 1) | port);
+		REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
+		       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
+	}
+}
 
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
@@ -1669,6 +2022,308 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 	return rc;
 }
 
+/* must be called under rtnl_lock */
+void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
+{
+	u32 mask = (1 << cl_id);
+
+	/* initial seeting is BNX2X_ACCEPT_NONE */
+	u8 drop_all_ucast = 1, drop_all_bcast = 1, drop_all_mcast = 1;
+	u8 accp_all_ucast = 0, accp_all_bcast = 0, accp_all_mcast = 0;
+	u8 unmatched_unicast = 0;
+
+	if (filters & BNX2X_PROMISCUOUS_MODE) {
+		/* promiscious - accept all, drop none */
+		drop_all_ucast = drop_all_bcast = drop_all_mcast = 0;
+		accp_all_ucast = accp_all_bcast = accp_all_mcast = 1;
+	}
+	if (filters & BNX2X_ACCEPT_UNICAST) {
+		/* accept matched ucast */
+		drop_all_ucast = 0;
+	}
+	if (filters & BNX2X_ACCEPT_MULTICAST) {
+		/* accept matched mcast */
+		drop_all_mcast = 0;
+	}
+	if (filters & BNX2X_ACCEPT_ALL_UNICAST) {
+		/* accept all mcast */
+		drop_all_ucast = 0;
+		accp_all_ucast = 1;
+	}
+	if (filters & BNX2X_ACCEPT_ALL_MULTICAST) {
+		/* accept all mcast */
+		drop_all_mcast = 0;
+		accp_all_mcast = 1;
+	}
+	if (filters & BNX2X_ACCEPT_BROADCAST) {
+		/* accept (all) bcast */
+		drop_all_bcast = 0;
+		accp_all_bcast = 1;
+	}
+
+	bp->mac_filters.ucast_drop_all = drop_all_ucast ?
+		bp->mac_filters.ucast_drop_all | mask :
+		bp->mac_filters.ucast_drop_all & ~mask;
+
+	bp->mac_filters.mcast_drop_all = drop_all_mcast ?
+		bp->mac_filters.mcast_drop_all | mask :
+		bp->mac_filters.mcast_drop_all & ~mask;
+
+	bp->mac_filters.bcast_drop_all = drop_all_bcast ?
+		bp->mac_filters.bcast_drop_all | mask :
+		bp->mac_filters.bcast_drop_all & ~mask;
+
+	bp->mac_filters.ucast_accept_all = accp_all_ucast ?
+		bp->mac_filters.ucast_accept_all | mask :
+		bp->mac_filters.ucast_accept_all & ~mask;
+
+	bp->mac_filters.mcast_accept_all = accp_all_mcast ?
+		bp->mac_filters.mcast_accept_all | mask :
+		bp->mac_filters.mcast_accept_all & ~mask;
+
+	bp->mac_filters.bcast_accept_all = accp_all_bcast ?
+		bp->mac_filters.bcast_accept_all | mask :
+		bp->mac_filters.bcast_accept_all & ~mask;
+
+	bp->mac_filters.unmatched_unicast = unmatched_unicast ?
+		bp->mac_filters.unmatched_unicast | mask :
+		bp->mac_filters.unmatched_unicast & ~mask;
+}
+
+void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *p)
+{
+	if (FUNC_CONFIG(p->func_flgs)) {
+		struct tstorm_eth_function_common_config tcfg = {0};
+
+		/* tpa */
+		if (p->func_flgs & FUNC_FLG_TPA)
+			tcfg.config_flags |=
+			TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA;
+
+		/* set rss flags */
+		if (p->func_flgs & FUNC_FLG_RSS) {
+			u16 rss_flgs = (p->rss->mode <<
+			TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT);
+
+			if (p->rss->cap & RSS_IPV4_CAP)
+				rss_flgs |= RSS_IPV4_CAP_MASK;
+			if (p->rss->cap & RSS_IPV4_TCP_CAP)
+				rss_flgs |= RSS_IPV4_TCP_CAP_MASK;
+			if (p->rss->cap & RSS_IPV6_CAP)
+				rss_flgs |= RSS_IPV6_CAP_MASK;
+			if (p->rss->cap & RSS_IPV6_TCP_CAP)
+				rss_flgs |= RSS_IPV6_TCP_CAP_MASK;
+
+			tcfg.config_flags |= rss_flgs;
+			tcfg.rss_result_mask = p->rss->result_mask;
+
+		}
+
+		storm_memset_func_cfg(bp, &tcfg, p->func_id);
+	}
+
+	/* Enable the function in the FW */
+	storm_memset_vf_to_pf(bp, p->func_id, p->pf_id);
+	storm_memset_func_en(bp, p->func_id, 1);
+
+	/* statistics */
+	if (p->func_flgs & FUNC_FLG_STATS) {
+		struct stats_indication_flags stats_flags = {0};
+		stats_flags.collect_eth = 1;
+
+		storm_memset_xstats_flags(bp, &stats_flags, p->func_id);
+		storm_memset_xstats_addr(bp, p->fw_stat_map, p->func_id);
+
+		storm_memset_tstats_flags(bp, &stats_flags, p->func_id);
+		storm_memset_tstats_addr(bp, p->fw_stat_map, p->func_id);
+
+		storm_memset_ustats_flags(bp, &stats_flags, p->func_id);
+		storm_memset_ustats_addr(bp, p->fw_stat_map, p->func_id);
+
+		storm_memset_cstats_flags(bp, &stats_flags, p->func_id);
+		storm_memset_cstats_addr(bp, p->fw_stat_map, p->func_id);
+	}
+
+	/* spq */
+	if (p->func_flgs & FUNC_FLG_SPQ) {
+		storm_memset_spq_addr(bp, p->spq_map, p->func_id);
+		REG_WR(bp, XSEM_REG_FAST_MEMORY +
+		       XSTORM_SPQ_PROD_OFFSET(p->func_id), p->spq_prod);
+	}
+}
+
+static inline u16 bnx2x_get_cl_flags(struct bnx2x *bp,
+				     struct bnx2x_fastpath *fp)
+{
+	u16 flags = 0;
+
+	/* calculate queue flags */
+	flags |= QUEUE_FLG_CACHE_ALIGN;
+	flags |= QUEUE_FLG_HC;
+	flags |= IS_E1HMF(bp) ? QUEUE_FLG_OV : 0;
+
+#ifdef BCM_VLAN
+	flags |= QUEUE_FLG_VLAN;
+	DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
+#endif
+
+	if (!fp->disable_tpa)
+		flags |= QUEUE_FLG_TPA;
+
+	flags |= QUEUE_FLG_STATS;
+
+	return flags;
+}
+
+static void bnx2x_pf_rx_cl_prep(struct bnx2x *bp,
+	struct bnx2x_fastpath *fp, struct rxq_pause_params *pause,
+	struct bnx2x_rxq_init_params *rxq_init)
+{
+	u16 max_sge = 0;
+	u16 sge_sz = 0;
+	u16 tpa_agg_size = 0;
+
+	/* calculate queue flags */
+	u16 flags = bnx2x_get_cl_flags(bp, fp);
+
+	if (!fp->disable_tpa) {
+		pause->sge_th_hi = 250;
+		pause->sge_th_lo = 150;
+		tpa_agg_size = min_t(u32,
+			(min_t(u32, 8, MAX_SKB_FRAGS) *
+			SGE_PAGE_SIZE * PAGES_PER_SGE), 0xffff);
+		max_sge = SGE_PAGE_ALIGN(bp->dev->mtu) >>
+			SGE_PAGE_SHIFT;
+		max_sge = ((max_sge + PAGES_PER_SGE - 1) &
+			  (~(PAGES_PER_SGE-1))) >> PAGES_PER_SGE_SHIFT;
+		sge_sz = (u16)min_t(u32, SGE_PAGE_SIZE * PAGES_PER_SGE,
+				    0xffff);
+	}
+
+	/* pause - not for e1 */
+	if (!CHIP_IS_E1(bp)) {
+		pause->bd_th_hi = 350;
+		pause->bd_th_lo = 250;
+		pause->rcq_th_hi = 350;
+		pause->rcq_th_lo = 250;
+		pause->sge_th_hi = 0;
+		pause->sge_th_lo = 0;
+		pause->pri_map = 1;
+	}
+
+	/* rxq setup */
+	rxq_init->flags = flags;
+	rxq_init->cxt = &bp->context.vcxt[fp->cid].eth;
+	rxq_init->dscr_map = fp->rx_desc_mapping;
+	rxq_init->sge_map = fp->rx_sge_mapping;
+	rxq_init->rcq_map = fp->rx_comp_mapping;
+	rxq_init->rcq_np_map = fp->rx_comp_mapping + BCM_PAGE_SIZE;
+	rxq_init->mtu = bp->dev->mtu;
+	rxq_init->buf_sz = bp->rx_buf_size;
+	rxq_init->cl_qzone_id = fp->cl_qzone_id;
+	rxq_init->cl_id = fp->cl_id;
+	rxq_init->spcl_id = fp->cl_id;
+	rxq_init->stat_id = fp->cl_id;
+	rxq_init->tpa_agg_sz = tpa_agg_size;
+	rxq_init->sge_buf_sz = sge_sz;
+	rxq_init->max_sges_pkt = max_sge;
+	rxq_init->cache_line_log = BNX2X_RX_ALIGN_SHIFT;
+	rxq_init->fw_sb_id = fp->fw_sb_id;
+
+	rxq_init->sb_cq_index = U_SB_ETH_RX_CQ_INDEX;
+
+	rxq_init->cid = HW_CID(bp, fp->cid);
+
+	rxq_init->hc_rate = bp->rx_ticks ? (1000000 / bp->rx_ticks) : 0;
+}
+
+static void bnx2x_pf_tx_cl_prep(struct bnx2x *bp,
+	struct bnx2x_fastpath *fp, struct bnx2x_txq_init_params *txq_init)
+{
+	u16 flags = bnx2x_get_cl_flags(bp, fp);
+
+	txq_init->flags = flags;
+	txq_init->cxt = &bp->context.vcxt[fp->cid].eth;
+	txq_init->dscr_map = fp->tx_desc_mapping;
+	txq_init->stat_id = fp->cl_id;
+	txq_init->cid = HW_CID(bp, fp->cid);
+	txq_init->sb_cq_index = C_SB_ETH_TX_CQ_INDEX;
+	txq_init->traffic_type = LLFC_TRAFFIC_TYPE_NW;
+	txq_init->fw_sb_id = fp->fw_sb_id;
+	txq_init->hc_rate = bp->tx_ticks ? (1000000 / bp->tx_ticks) : 0;
+}
+
+void bnx2x_pf_init(struct bnx2x *bp)
+{
+	struct bnx2x_func_init_params func_init = {0};
+	struct bnx2x_rss_params rss = {0};
+	struct event_ring_data eq_data = { {0} };
+	u16 flags;
+
+	/* pf specific setups */
+	if (!CHIP_IS_E1(bp))
+		storm_memset_ov(bp, bp->e1hov, BP_FUNC(bp));
+
+	/* function setup flags */
+	flags = (FUNC_FLG_STATS | FUNC_FLG_LEADING | FUNC_FLG_SPQ);
+
+	flags |= (bp->flags & TPA_ENABLE_FLAG) ? FUNC_FLG_TPA : 0;
+
+	/**
+	 * Although RSS is meaningless when there is a single HW queue we
+	 * still need it enabled in order to have HW Rx hash generated.
+	 *
+	 * if (is_eth_multi(bp))
+	 *	flags |= FUNC_FLG_RSS;
+	 */
+
+	/* function setup */
+	if (flags & FUNC_FLG_RSS) {
+		rss.cap = (RSS_IPV4_CAP | RSS_IPV4_TCP_CAP |
+			   RSS_IPV6_CAP | RSS_IPV6_TCP_CAP);
+		rss.mode = bp->multi_mode;
+		rss.result_mask = MULTI_MASK;
+		func_init.rss = &rss;
+	}
+
+	func_init.func_flgs = flags;
+	func_init.pf_id = BP_FUNC(bp);
+	func_init.func_id = BP_FUNC(bp);
+	func_init.fw_stat_map = bnx2x_sp_mapping(bp, fw_stats);
+	func_init.spq_map = bp->spq_mapping;
+	func_init.spq_prod = bp->spq_prod_idx;
+
+	bnx2x_func_init(bp, &func_init);
+
+	memset(&(bp->cmng), 0, sizeof(struct cmng_struct_per_port));
+
+	/*
+	Congestion management values depend on the link rate
+	There is no active link so initial link rate is set to 10 Gbps.
+	When the link comes up The congestion management values are
+	re-calculated according to the actual link rate.
+	*/
+	bp->link_vars.line_speed = SPEED_10000;
+	bnx2x_cmng_fns_init(bp, true, bnx2x_get_cmng_fns_mode(bp));
+
+	/* Only the PMF sets the HW */
+	if (bp->port.pmf)
+		storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
+
+	/* no rx until link is up */
+	bp->rx_mode = BNX2X_RX_MODE_NONE;
+	bnx2x_set_storm_rx_mode(bp);
+
+	/* init Event Queue */
+	eq_data.base_addr.hi = U64_HI(bp->eq_mapping);
+	eq_data.base_addr.lo = U64_LO(bp->eq_mapping);
+	eq_data.producer = bp->eq_prod;
+	eq_data.index_id = HC_SP_INDEX_EQ_CONS;
+	eq_data.sb_id = DEF_SB_ID;
+	storm_memset_eq_data(bp, &eq_data, BP_FUNC(bp));
+}
+
+
 static void bnx2x_e1h_disable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
@@ -1695,40 +2350,6 @@ static void bnx2x_e1h_enable(struct bnx2x *bp)
 	 */
 }
 
-static void bnx2x_update_min_max(struct bnx2x *bp)
-{
-	int port = BP_PORT(bp);
-	int vn, i;
-
-	/* Init rate shaping and fairness contexts */
-	bnx2x_init_port_minmax(bp);
-
-	bnx2x_calc_vn_weight_sum(bp);
-
-	for (vn = VN_0; vn < E1HVN_MAX; vn++)
-		bnx2x_init_vn_minmax(bp, 2*vn + port);
-
-	if (bp->port.pmf) {
-		int func;
-
-		/* Set the attention towards other drivers on the same port */
-		for (vn = VN_0; vn < E1HVN_MAX; vn++) {
-			if (vn == BP_E1HVN(bp))
-				continue;
-
-			func = ((vn << 1) | port);
-			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
-			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
-		}
-
-		/* Store it to internal memory */
-		for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
-			REG_WR(bp, BAR_XSTRORM_INTMEM +
-			       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i*4,
-			       ((u32 *)(&bp->cmng))[i]);
-	}
-}
-
 static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 {
 	DP(BNX2X_MSG_MCP, "dcc_event 0x%x\n", dcc_event);
@@ -1755,7 +2376,9 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 	}
 	if (dcc_event & DRV_STATUS_DCC_BANDWIDTH_ALLOCATION) {
 
-		bnx2x_update_min_max(bp);
+		bnx2x_cmng_fns_init(bp, true, CMNG_FNS_MINMAX);
+		bnx2x_link_sync_notify(bp);
+		storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
 		dcc_event &= ~DRV_STATUS_DCC_BANDWIDTH_ALLOCATION;
 	}
 
@@ -1790,7 +2413,7 @@ static inline void bnx2x_sp_prod_update(struct bnx2x *bp)
 	/* Make sure that BD data is updated before writing the producer */
 	wmb();
 
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
+	REG_WR16(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
 	       bp->spq_prod_idx);
 	mmiowb();
 }
@@ -1800,6 +2423,7 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 			 u32 data_hi, u32 data_lo, int common)
 {
 	struct eth_spe *spe;
+	u16 type;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -1821,22 +2445,42 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 	spe->hdr.conn_and_cmd_data =
 			cpu_to_le32((command << SPE_HDR_CMD_ID_SHIFT) |
 				    HW_CID(bp, cid));
-	spe->hdr.type = cpu_to_le16(ETH_CONNECTION_TYPE);
+
 	if (common)
-		spe->hdr.type |=
-			cpu_to_le16((1 << SPE_HDR_COMMON_RAMROD_SHIFT));
+		/* Common ramrods:
+		 *	FUNC_START, FUNC_STOP, CFC_DEL, STATS, SET_MAC
+		 *	TRAFFIC_STOP, TRAFFIC_START
+		 */
+		type = (NONE_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
+			& SPE_HDR_CONN_TYPE;
+	else
+		/* ETH ramrods: SETUP, HALT */
+		type = (ETH_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
+			& SPE_HDR_CONN_TYPE;
+
+	type |= ((BP_FUNC(bp) << SPE_HDR_FUNCTION_ID_SHIFT) &
+		 SPE_HDR_FUNCTION_ID);
 
-	spe->data.mac_config_addr.hi = cpu_to_le32(data_hi);
-	spe->data.mac_config_addr.lo = cpu_to_le32(data_lo);
+	spe->hdr.type = cpu_to_le16(type);
 
-	bp->spq_left--;
+	spe->data.update_data_addr.hi = cpu_to_le32(data_hi);
+	spe->data.update_data_addr.lo = cpu_to_le32(data_lo);
+
+	/* stats ramrod has it's own slot on the spq */
+	if (command != RAMROD_CMD_ID_COMMON_STAT_QUERY)
+		/* It's ok if the actual decrement is issued towards the memory
+		 * somewhere between the spin_lock and spin_unlock. Thus no
+		 * more explict memory barrier is needed.
+		 */
+		bp->spq_left--;
 
 	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
-	   "SPQE[%x] (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
+	   "SPQE[%x] (%x:%x)  command %d  hw_cid %x  data (%x:%x) "
+	   "type(0x%x) left %x\n",
 	   bp->spq_prod_idx, (u32)U64_HI(bp->spq_mapping),
 	   (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
-	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
+	   HW_CID(bp, cid), data_hi, data_lo, type, bp->spq_left);
 
 	bnx2x_sp_prod_update(bp);
 	spin_unlock_bh(&bp->spq_lock);
@@ -1873,32 +2517,27 @@ static void bnx2x_release_alr(struct bnx2x *bp)
 	REG_WR(bp, GRCBASE_MCP + 0x9c, 0);
 }
 
+#define BNX2X_DEF_SB_ATT_IDX	0x0001
+#define BNX2X_DEF_SB_IDX	0x0002
+
 static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 {
-	struct host_def_status_block *def_sb = bp->def_status_blk;
+	struct host_sp_status_block *def_sb = bp->def_status_blk;
 	u16 rc = 0;
 
 	barrier(); /* status block is written to by the chip */
 	if (bp->def_att_idx != def_sb->atten_status_block.attn_bits_index) {
 		bp->def_att_idx = def_sb->atten_status_block.attn_bits_index;
-		rc |= 1;
-	}
-	if (bp->def_c_idx != def_sb->c_def_status_block.status_block_index) {
-		bp->def_c_idx = def_sb->c_def_status_block.status_block_index;
-		rc |= 2;
+		rc |= BNX2X_DEF_SB_ATT_IDX;
 	}
-	if (bp->def_u_idx != def_sb->u_def_status_block.status_block_index) {
-		bp->def_u_idx = def_sb->u_def_status_block.status_block_index;
-		rc |= 4;
-	}
-	if (bp->def_x_idx != def_sb->x_def_status_block.status_block_index) {
-		bp->def_x_idx = def_sb->x_def_status_block.status_block_index;
-		rc |= 8;
-	}
-	if (bp->def_t_idx != def_sb->t_def_status_block.status_block_index) {
-		bp->def_t_idx = def_sb->t_def_status_block.status_block_index;
-		rc |= 16;
+
+	if (bp->def_idx != def_sb->sp_sb.running_index) {
+		bp->def_idx = def_sb->sp_sb.running_index;
+		rc |= BNX2X_DEF_SB_IDX;
 	}
+
+	/* Do not reorder: indecies reading should complete before handling */
+	barrier();
 	return rc;
 }
 
@@ -2144,8 +2783,8 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			int func = BP_FUNC(bp);
 
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
-			bp->mf_config = SHMEM_RD(bp,
-					   mf_cfg.func_mf_config[func].config);
+			bp->mf_config =
+				MF_CFG_RD(bp, func_mf_config[func].config);
 			val = SHMEM_RD(bp, func_mb[func].drv_status);
 			if (val & DRV_STATUS_DCC_EVENT_MASK)
 				bnx2x_dcc_event(bp,
@@ -2598,6 +3237,140 @@ static void bnx2x_attn_int(struct bnx2x *bp)
 		bnx2x_attn_int_deasserted(bp, deasserted);
 }
 
+static inline void bnx2x_update_eq_prod(struct bnx2x *bp, u16 prod)
+{
+	/* No memory barriers */
+	storm_memset_eq_prod(bp, prod, BP_FUNC(bp));
+	mmiowb(); /* keep prod updates ordered */
+}
+
+#ifdef BCM_CNIC
+static int  bnx2x_cnic_handle_cfc_del(struct bnx2x *bp, u32 cid,
+				      union event_ring_elem *elem)
+{
+	if (!bp->cnic_eth_dev.starting_cid  ||
+	    cid < bp->cnic_eth_dev.starting_cid)
+		return 1;
+
+	DP(BNX2X_MSG_SP, "got delete ramrod for CNIC CID %d\n", cid);
+
+	if (unlikely(elem->message.data.cfc_del_event.error)) {
+		BNX2X_ERR("got delete ramrod for CNIC CID %d with error!\n",
+			  cid);
+		bnx2x_panic_dump(bp);
+	}
+	bnx2x_cnic_cfc_comp(bp, cid);
+	return 0;
+}
+#endif
+
+static void bnx2x_eq_int(struct bnx2x *bp)
+{
+	u16 hw_cons, sw_cons, sw_prod;
+	union event_ring_elem *elem;
+	u32 cid;
+	u8 opcode;
+	int spqe_cnt = 0;
+
+	hw_cons = le16_to_cpu(*bp->eq_cons_sb);
+
+	/* The hw_cos range is 1-255, 257 - the sw_cons range is 0-254, 256.
+	 * when we get the the next-page we nned to adjust so the loop
+	 * condition below will be met. The next element is the size of a
+	 * regular element and hence incrementing by 1
+	 */
+	if ((hw_cons & EQ_DESC_MAX_PAGE) == EQ_DESC_MAX_PAGE)
+		hw_cons++;
+
+	/* This function may never run in parralel with itself for a
+	 * specific bp, thus there is no need in "paired" read memory
+	 * barrier here.
+	 */
+	sw_cons = bp->eq_cons;
+	sw_prod = bp->eq_prod;
+
+	DP(BNX2X_MSG_SP, "EQ:  hw_cons %u  sw_cons %u bp->spq_left %u\n",
+			hw_cons, sw_cons, bp->spq_left);
+
+	for (; sw_cons != hw_cons;
+	      sw_prod = NEXT_EQ_IDX(sw_prod), sw_cons = NEXT_EQ_IDX(sw_cons)) {
+
+
+		elem = &bp->eq_ring[EQ_DESC(sw_cons)];
+
+		cid = SW_CID(elem->message.data.cfc_del_event.cid);
+		opcode = elem->message.opcode;
+
+
+		/* handle eq element */
+		switch (opcode) {
+		case EVENT_RING_OPCODE_STAT_QUERY:
+			DP(NETIF_MSG_TIMER, "got statistics comp event\n");
+			/* nothing to do with stats comp */
+			continue;
+
+		case EVENT_RING_OPCODE_CFC_DEL:
+			/* handle according to cid range */
+			/*
+			 * we may want to verify here that the bp state is
+			 * HALTING
+			 */
+			DP(NETIF_MSG_IFDOWN,
+			   "got delete ramrod for MULTI[%d]\n", cid);
+#ifdef BCM_CNIC
+			if (!bnx2x_cnic_handle_cfc_del(bp, cid, elem))
+				goto next_spqe;
+#endif
+			bnx2x_fp(bp, cid, state) =
+						BNX2X_FP_STATE_CLOSED;
+
+			goto next_spqe;
+		}
+
+		switch (opcode | bp->state) {
+		case (EVENT_RING_OPCODE_FUNCTION_START |
+		      BNX2X_STATE_OPENING_WAIT4_PORT):
+			DP(NETIF_MSG_IFUP, "got setup ramrod\n");
+			bp->state = BNX2X_STATE_FUNC_STARTED;
+			break;
+
+		case (EVENT_RING_OPCODE_FUNCTION_STOP |
+		      BNX2X_STATE_CLOSING_WAIT4_HALT):
+			DP(NETIF_MSG_IFDOWN, "got halt ramrod\n");
+			bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
+			break;
+
+		case (EVENT_RING_OPCODE_SET_MAC | BNX2X_STATE_OPEN):
+		case (EVENT_RING_OPCODE_SET_MAC | BNX2X_STATE_DIAG):
+			DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
+			bp->set_mac_pending = 0;
+			break;
+
+		case (EVENT_RING_OPCODE_SET_MAC |
+		      BNX2X_STATE_CLOSING_WAIT4_HALT):
+			DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
+			bp->set_mac_pending = 0;
+			break;
+		default:
+			/* unknown event log error and continue */
+			BNX2X_ERR("Unknown EQ event %d\n",
+				  elem->message.opcode);
+		}
+next_spqe:
+		spqe_cnt++;
+	} /* for */
+
+	bp->spq_left++;
+
+	bp->eq_cons = sw_cons;
+	bp->eq_prod = sw_prod;
+	/* Make sure that above mem writes were issued towards the memory */
+	smp_wmb();
+
+	/* update producer */
+	bnx2x_update_eq_prod(bp, bp->eq_prod);
+}
+
 static void bnx2x_sp_task(struct work_struct *work)
 {
 	struct bnx2x *bp = container_of(work, struct bnx2x, sp_task.work);
@@ -2616,31 +3389,29 @@ static void bnx2x_sp_task(struct work_struct *work)
 	DP(NETIF_MSG_INTR, "got a slowpath interrupt (status 0x%x)\n", status);
 
 	/* HW attentions */
-	if (status & 0x1) {
+	if (status & BNX2X_DEF_SB_ATT_IDX) {
 		bnx2x_attn_int(bp);
-		status &= ~0x1;
+		status &= ~BNX2X_DEF_SB_ATT_IDX;
 	}
 
-	/* CStorm events: STAT_QUERY */
-	if (status & 0x2) {
-		DP(BNX2X_MSG_SP, "CStorm events: STAT_QUERY\n");
-		status &= ~0x2;
+	/* SP events: STAT_QUERY and others */
+	if (status & BNX2X_DEF_SB_IDX) {
+
+		/* Handle EQ completions */
+		bnx2x_eq_int(bp);
+
+		bnx2x_ack_sb(bp, bp->igu_dsb_id, USTORM_ID,
+			le16_to_cpu(bp->def_idx), IGU_INT_NOP, 1);
+
+		status &= ~BNX2X_DEF_SB_IDX;
 	}
 
 	if (unlikely(status))
 		DP(NETIF_MSG_INTR, "got an unknown interrupt! (status 0x%x)\n",
 		   status);
 
-	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, le16_to_cpu(bp->def_att_idx),
-		     IGU_INT_NOP, 1);
-	bnx2x_ack_sb(bp, DEF_SB_ID, USTORM_ID, le16_to_cpu(bp->def_u_idx),
-		     IGU_INT_NOP, 1);
-	bnx2x_ack_sb(bp, DEF_SB_ID, CSTORM_ID, le16_to_cpu(bp->def_c_idx),
-		     IGU_INT_NOP, 1);
-	bnx2x_ack_sb(bp, DEF_SB_ID, XSTORM_ID, le16_to_cpu(bp->def_x_idx),
-		     IGU_INT_NOP, 1);
-	bnx2x_ack_sb(bp, DEF_SB_ID, TSTORM_ID, le16_to_cpu(bp->def_t_idx),
-		     IGU_INT_ENABLE, 1);
+	bnx2x_ack_sb(bp, bp->igu_dsb_id, ATTENTION_ID,
+	     le16_to_cpu(bp->def_att_idx), IGU_INT_ENABLE, 1);
 }
 
 irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
@@ -2654,7 +3425,8 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 	}
 
-	bnx2x_ack_sb(bp, DEF_SB_ID, TSTORM_ID, 0, IGU_INT_DISABLE, 0);
+	bnx2x_ack_sb(bp, bp->igu_dsb_id, USTORM_ID, 0,
+		     IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -2736,232 +3508,234 @@ timer_restart:
  * nic init service functions
  */
 
-static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
+static inline void bnx2x_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
 {
-	int port = BP_PORT(bp);
+	u32 i;
+	if (!(len%4) && !(addr%4))
+		for (i = 0; i < len; i += 4)
+			REG_WR(bp, addr + i, fill);
+	else
+		for (i = 0; i < len; i++)
+			REG_WR8(bp, addr + i, fill);
 
-	/* "CSTORM" */
-	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
-			CSTORM_SB_HOST_STATUS_BLOCK_U_OFFSET(port, sb_id), 0,
-			CSTORM_SB_STATUS_BLOCK_U_SIZE / 4);
-	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
-			CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id), 0,
-			CSTORM_SB_STATUS_BLOCK_C_SIZE / 4);
 }
 
-void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
-			  dma_addr_t mapping, int sb_id)
+/* helper: writes FP SP data to FW - data_size in dwords */
+static inline void bnx2x_wr_fp_sb_data(struct bnx2x *bp,
+				       int fw_sb_id,
+				       u32 *sb_data_p,
+				       u32 data_size)
 {
-	int port = BP_PORT(bp);
-	int func = BP_FUNC(bp);
 	int index;
-	u64 section;
+	for (index = 0; index < data_size; index++)
+		REG_WR(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_OFFSET(fw_sb_id) +
+			sizeof(u32)*index,
+			*(sb_data_p + index));
+}
 
-	/* USTORM */
-	section = ((u64)mapping) + offsetof(struct host_status_block,
-					    u_status_block);
-	sb->u_status_block.status_block_id = sb_id;
-
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_SB_HOST_SB_ADDR_U_OFFSET(port, sb_id), U64_LO(section));
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_SB_HOST_SB_ADDR_U_OFFSET(port, sb_id)) + 4),
-	       U64_HI(section));
-	REG_WR8(bp, BAR_CSTRORM_INTMEM + FP_USB_FUNC_OFF +
-		CSTORM_SB_HOST_STATUS_BLOCK_U_OFFSET(port, sb_id), func);
-
-	for (index = 0; index < HC_USTORM_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_U_OFFSET(port, sb_id, index), 1);
+static inline void bnx2x_zero_fp_sb(struct bnx2x *bp, int fw_sb_id)
+{
+	u32 *sb_data_p;
+	u32 data_size = 0;
+	struct hc_status_block_data_e1x sb_data_e1x;
 
-	/* CSTORM */
-	section = ((u64)mapping) + offsetof(struct host_status_block,
-					    c_status_block);
-	sb->c_status_block.status_block_id = sb_id;
+	/* disable the function first */
+	memset(&sb_data_e1x, 0,
+	       sizeof(struct hc_status_block_data_e1x));
+	sb_data_e1x.common.p_func.pf_id = HC_FUNCTION_DISABLED;
+	sb_data_e1x.common.p_func.vf_id = HC_FUNCTION_DISABLED;
+	sb_data_e1x.common.p_func.vf_valid = false;
+	sb_data_p = (u32 *)&sb_data_e1x;
+	data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
 
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_SB_HOST_SB_ADDR_C_OFFSET(port, sb_id), U64_LO(section));
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_SB_HOST_SB_ADDR_C_OFFSET(port, sb_id)) + 4),
-	       U64_HI(section));
-	REG_WR8(bp, BAR_CSTRORM_INTMEM + FP_CSB_FUNC_OFF +
-		CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id), func);
+	bnx2x_wr_fp_sb_data(bp, fw_sb_id, sb_data_p, data_size);
 
-	for (index = 0; index < HC_CSTORM_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id, index), 1);
+	bnx2x_fill(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_OFFSET(fw_sb_id), 0,
+			CSTORM_STATUS_BLOCK_SIZE);
+	bnx2x_fill(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SYNC_BLOCK_OFFSET(fw_sb_id), 0,
+			CSTORM_SYNC_BLOCK_SIZE);
+}
 
-	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+/* helper:  writes SP SB data to FW */
+static inline void bnx2x_wr_sp_sb_data(struct bnx2x *bp,
+		struct hc_sp_status_block_data *sp_sb_data)
+{
+	int func = BP_FUNC(bp);
+	int i;
+	for (i = 0; i < sizeof(struct hc_sp_status_block_data)/sizeof(u32); i++)
+		REG_WR(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(func) +
+			i*sizeof(u32),
+			*((u32 *)sp_sb_data + i));
 }
 
-static void bnx2x_zero_def_sb(struct bnx2x *bp)
+static inline void bnx2x_zero_sp_sb(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
+	struct hc_sp_status_block_data sp_sb_data;
+	memset(&sp_sb_data, 0, sizeof(struct hc_sp_status_block_data));
+
+	sp_sb_data.p_func.pf_id = HC_FUNCTION_DISABLED;
+	sp_sb_data.p_func.vf_id = HC_FUNCTION_DISABLED;
+	sp_sb_data.p_func.vf_valid = false;
+
+	bnx2x_wr_sp_sb_data(bp, &sp_sb_data);
+
+	bnx2x_fill(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SP_STATUS_BLOCK_OFFSET(func), 0,
+			CSTORM_SP_STATUS_BLOCK_SIZE);
+	bnx2x_fill(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SP_SYNC_BLOCK_OFFSET(func), 0,
+			CSTORM_SP_SYNC_BLOCK_SIZE);
+
+}
+
+
+static inline
+void bnx2x_setup_ndsb_state_machine(struct hc_status_block_sm *hc_sm,
+					   int igu_sb_id, int igu_seg_id)
+{
+	hc_sm->igu_sb_id = igu_sb_id;
+	hc_sm->igu_seg_id = igu_seg_id;
+	hc_sm->timer_value = 0xFF;
+	hc_sm->time_to_expire = 0xFFFFFFFF;
+}
+
+void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
+			  u8 vf_valid, int fw_sb_id, int igu_sb_id)
+{
+	int igu_seg_id;
+
+	struct hc_status_block_data_e1x sb_data_e1x;
+	struct hc_status_block_sm  *hc_sm_p;
+	struct hc_index_data *hc_index_p;
+	int data_size;
+	u32 *sb_data_p;
+
+	igu_seg_id = HC_SEG_ACCESS_NORM;
+
+	bnx2x_zero_fp_sb(bp, fw_sb_id);
+
+	memset(&sb_data_e1x, 0,
+	       sizeof(struct hc_status_block_data_e1x));
+	sb_data_e1x.common.p_func.pf_id = BP_FUNC(bp);
+	sb_data_e1x.common.p_func.vf_id = 0xff;
+	sb_data_e1x.common.p_func.vf_valid = false;
+	sb_data_e1x.common.p_func.vnic_id = BP_E1HVN(bp);
+	sb_data_e1x.common.same_igu_sb_1b = true;
+	sb_data_e1x.common.host_sb_addr.hi = U64_HI(mapping);
+	sb_data_e1x.common.host_sb_addr.lo = U64_LO(mapping);
+	hc_sm_p = sb_data_e1x.common.state_machine;
+	hc_index_p = sb_data_e1x.index_data;
+	sb_data_p = (u32 *)&sb_data_e1x;
+	data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
+
+
+	bnx2x_setup_ndsb_state_machine(&hc_sm_p[SM_RX_ID],
+				       igu_sb_id, igu_seg_id);
+	bnx2x_setup_ndsb_state_machine(&hc_sm_p[SM_TX_ID],
+				       igu_sb_id, igu_seg_id);
+
+	DP(NETIF_MSG_HW, "Init FW SB %d\n", fw_sb_id);
+
+	/* write indecies to HW */
+	bnx2x_wr_fp_sb_data(bp, fw_sb_id, sb_data_p, data_size);
+}
+
+static void bnx2x_update_coalesce_sb_index(struct bnx2x *bp, u16 fw_sb_id,
+					u8 sb_index, u8 disable, u16 usec)
+{
+	int port = BP_PORT(bp);
+	u8 ticks = usec / BNX2X_BTR;
 
-	bnx2x_init_fill(bp, TSEM_REG_FAST_MEMORY +
-			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
-			sizeof(struct tstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
-			CSTORM_DEF_SB_HOST_STATUS_BLOCK_U_OFFSET(func), 0,
-			sizeof(struct cstorm_def_status_block_u)/4);
-	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
-			CSTORM_DEF_SB_HOST_STATUS_BLOCK_C_OFFSET(func), 0,
-			sizeof(struct cstorm_def_status_block_c)/4);
-	bnx2x_init_fill(bp, XSEM_REG_FAST_MEMORY +
-			XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
-			sizeof(struct xstorm_def_status_block)/4);
+	storm_memset_hc_timeout(bp, port, fw_sb_id, sb_index, ticks);
+
+	disable = disable ? 1 : (usec ? 0 : 1);
+	storm_memset_hc_disable(bp, port, fw_sb_id, sb_index, disable);
 }
 
-static void bnx2x_init_def_sb(struct bnx2x *bp,
-			      struct host_def_status_block *def_sb,
-			      dma_addr_t mapping, int sb_id)
+static void bnx2x_update_coalesce_sb(struct bnx2x *bp, u16 fw_sb_id,
+				     u16 tx_usec, u16 rx_usec)
 {
+	bnx2x_update_coalesce_sb_index(bp, fw_sb_id, U_SB_ETH_RX_CQ_INDEX,
+				    false, rx_usec);
+	bnx2x_update_coalesce_sb_index(bp, fw_sb_id, C_SB_ETH_TX_CQ_INDEX,
+				    false, tx_usec);
+}
+static void bnx2x_init_def_sb(struct bnx2x *bp)
+{
+	struct host_sp_status_block *def_sb = bp->def_status_blk;
+	dma_addr_t mapping = bp->def_status_blk_mapping;
+	int igu_sp_sb_index;
+	int igu_seg_id;
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
-	int index, val, reg_offset;
+	int reg_offset;
 	u64 section;
+	int index;
+	struct hc_sp_status_block_data sp_sb_data;
+	memset(&sp_sb_data, 0, sizeof(struct hc_sp_status_block_data));
+
+	igu_sp_sb_index = DEF_SB_IGU_ID;
+	igu_seg_id = HC_SEG_ACCESS_DEF;
 
 	/* ATTN */
-	section = ((u64)mapping) + offsetof(struct host_def_status_block,
+	section = ((u64)mapping) + offsetof(struct host_sp_status_block,
 					    atten_status_block);
-	def_sb->atten_status_block.status_block_id = sb_id;
+	def_sb->atten_status_block.status_block_id = igu_sp_sb_index;
 
 	bp->attn_state = 0;
 
 	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
-
 	for (index = 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
-		bp->attn_group[index].sig[0] = REG_RD(bp,
-						     reg_offset + 0x10*index);
-		bp->attn_group[index].sig[1] = REG_RD(bp,
-					       reg_offset + 0x4 + 0x10*index);
-		bp->attn_group[index].sig[2] = REG_RD(bp,
-					       reg_offset + 0x8 + 0x10*index);
-		bp->attn_group[index].sig[3] = REG_RD(bp,
-					       reg_offset + 0xc + 0x10*index);
+		int sindex;
+		/* take care of sig[0]..sig[4] */
+		for (sindex = 0; sindex < 4; sindex++)
+			bp->attn_group[index].sig[sindex] =
+			   REG_RD(bp, reg_offset + sindex*0x4 + 0x10*index);
 	}
 
 	reg_offset = (port ? HC_REG_ATTN_MSG1_ADDR_L :
 			     HC_REG_ATTN_MSG0_ADDR_L);
-
 	REG_WR(bp, reg_offset, U64_LO(section));
 	REG_WR(bp, reg_offset + 4, U64_HI(section));
 
-	reg_offset = (port ? HC_REG_ATTN_NUM_P1 : HC_REG_ATTN_NUM_P0);
-
-	val = REG_RD(bp, reg_offset);
-	val |= sb_id;
-	REG_WR(bp, reg_offset, val);
-
-	/* USTORM */
-	section = ((u64)mapping) + offsetof(struct host_def_status_block,
-					    u_def_status_block);
-	def_sb->u_def_status_block.status_block_id = sb_id;
-
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_DEF_SB_HOST_SB_ADDR_U_OFFSET(func), U64_LO(section));
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_DEF_SB_HOST_SB_ADDR_U_OFFSET(func)) + 4),
-	       U64_HI(section));
-	REG_WR8(bp, BAR_CSTRORM_INTMEM + DEF_USB_FUNC_OFF +
-		CSTORM_DEF_SB_HOST_STATUS_BLOCK_U_OFFSET(func), func);
-
-	for (index = 0; index < HC_USTORM_DEF_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_DEF_SB_HC_DISABLE_U_OFFSET(func, index), 1);
+	section = ((u64)mapping) + offsetof(struct host_sp_status_block,
+					    sp_sb);
 
-	/* CSTORM */
-	section = ((u64)mapping) + offsetof(struct host_def_status_block,
-					    c_def_status_block);
-	def_sb->c_def_status_block.status_block_id = sb_id;
-
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_DEF_SB_HOST_SB_ADDR_C_OFFSET(func), U64_LO(section));
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_DEF_SB_HOST_SB_ADDR_C_OFFSET(func)) + 4),
-	       U64_HI(section));
-	REG_WR8(bp, BAR_CSTRORM_INTMEM + DEF_CSB_FUNC_OFF +
-		CSTORM_DEF_SB_HOST_STATUS_BLOCK_C_OFFSET(func), func);
-
-	for (index = 0; index < HC_CSTORM_DEF_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_DEF_SB_HC_DISABLE_C_OFFSET(func, index), 1);
+	bnx2x_zero_sp_sb(bp);
 
-	/* TSTORM */
-	section = ((u64)mapping) + offsetof(struct host_def_status_block,
-					    t_def_status_block);
-	def_sb->t_def_status_block.status_block_id = sb_id;
-
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       ((TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
-	       U64_HI(section));
-	REG_WR8(bp, BAR_TSTRORM_INTMEM + DEF_TSB_FUNC_OFF +
-		TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
-
-	for (index = 0; index < HC_TSTORM_DEF_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_TSTRORM_INTMEM +
-			 TSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
+	sp_sb_data.host_sb_addr.lo	= U64_LO(section);
+	sp_sb_data.host_sb_addr.hi	= U64_HI(section);
+	sp_sb_data.igu_sb_id		= igu_sp_sb_index;
+	sp_sb_data.igu_seg_id		= igu_seg_id;
+	sp_sb_data.p_func.pf_id		= func;
+	sp_sb_data.p_func.vnic_id	= BP_E1HVN(bp);
+	sp_sb_data.p_func.vf_id		= 0xff;
 
-	/* XSTORM */
-	section = ((u64)mapping) + offsetof(struct host_def_status_block,
-					    x_def_status_block);
-	def_sb->x_def_status_block.status_block_id = sb_id;
-
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       ((XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
-	       U64_HI(section));
-	REG_WR8(bp, BAR_XSTRORM_INTMEM + DEF_XSB_FUNC_OFF +
-		XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
-
-	for (index = 0; index < HC_XSTORM_DEF_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_XSTRORM_INTMEM +
-			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
+	bnx2x_wr_sp_sb_data(bp, &sp_sb_data);
 
 	bp->stats_pending = 0;
 	bp->set_mac_pending = 0;
 
-	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, bp->igu_dsb_id, USTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
 
 void bnx2x_update_coalesce(struct bnx2x *bp)
 {
-	int port = BP_PORT(bp);
 	int i;
 
-	for_each_queue(bp, i) {
-		int sb_id = bp->fp[i].sb_id;
-
-		/* HC_INDEX_U_ETH_RX_CQ_CONS */
-		REG_WR8(bp, BAR_CSTRORM_INTMEM +
-			CSTORM_SB_HC_TIMEOUT_U_OFFSET(port, sb_id,
-						      U_SB_ETH_RX_CQ_INDEX),
-			bp->rx_ticks/(4 * BNX2X_BTR));
-		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_U_OFFSET(port, sb_id,
-						       U_SB_ETH_RX_CQ_INDEX),
-			 (bp->rx_ticks/(4 * BNX2X_BTR)) ? 0 : 1);
-
-		/* HC_INDEX_C_ETH_TX_CQ_CONS */
-		REG_WR8(bp, BAR_CSTRORM_INTMEM +
-			CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, sb_id,
-						      C_SB_ETH_TX_CQ_INDEX),
-			bp->tx_ticks/(4 * BNX2X_BTR));
-		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id,
-						       C_SB_ETH_TX_CQ_INDEX),
-			 (bp->tx_ticks/(4 * BNX2X_BTR)) ? 0 : 1);
-	}
+	for_each_queue(bp, i)
+		bnx2x_update_coalesce_sb(bp, bp->fp[i].fw_sb_id,
+					 bp->rx_ticks, bp->tx_ticks);
 }
 
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
 {
-	int func = BP_FUNC(bp);
-
 	spin_lock_init(&bp->spq_lock);
 
 	bp->spq_left = MAX_SPQ_PENDING;
@@ -2969,91 +3743,25 @@ static void bnx2x_init_sp_ring(struct bnx2x *bp)
 	bp->dsb_sp_prod = BNX2X_SP_DSB_INDEX;
 	bp->spq_prod_bd = bp->spq;
 	bp->spq_last_bd = bp->spq_prod_bd + MAX_SP_DESC_CNT;
-
-	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PAGE_BASE_OFFSET(func),
-	       U64_LO(bp->spq_mapping));
-	REG_WR(bp,
-	       XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PAGE_BASE_OFFSET(func) + 4,
-	       U64_HI(bp->spq_mapping));
-
-	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PROD_OFFSET(func),
-	       bp->spq_prod_idx);
 }
 
-static void bnx2x_init_context(struct bnx2x *bp)
+static void bnx2x_init_eq_ring(struct bnx2x *bp)
 {
 	int i;
+	for (i = 1; i <= NUM_EQ_PAGES; i++) {
+		union event_ring_elem *elem =
+			&bp->eq_ring[EQ_DESC_CNT_PAGE * i - 1];
 
-	/* Rx */
-	for_each_queue(bp, i) {
-		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-		u8 cl_id = fp->cl_id;
-
-		context->ustorm_st_context.common.sb_index_numbers =
-						BNX2X_RX_SB_INDEX_NUM;
-		context->ustorm_st_context.common.clientId = cl_id;
-		context->ustorm_st_context.common.status_block_id = fp->sb_id;
-		context->ustorm_st_context.common.flags =
-			(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT |
-			 USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS);
-		context->ustorm_st_context.common.statistics_counter_id =
-						cl_id;
-		context->ustorm_st_context.common.mc_alignment_log_size =
-						BNX2X_RX_ALIGN_SHIFT;
-		context->ustorm_st_context.common.bd_buff_size =
-						bp->rx_buf_size;
-		context->ustorm_st_context.common.bd_page_base_hi =
-						U64_HI(fp->rx_desc_mapping);
-		context->ustorm_st_context.common.bd_page_base_lo =
-						U64_LO(fp->rx_desc_mapping);
-		if (!fp->disable_tpa) {
-			context->ustorm_st_context.common.flags |=
-				USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA;
-			context->ustorm_st_context.common.sge_buff_size =
-				(u16)min_t(u32, SGE_PAGE_SIZE*PAGES_PER_SGE,
-					   0xffff);
-			context->ustorm_st_context.common.sge_page_base_hi =
-						U64_HI(fp->rx_sge_mapping);
-			context->ustorm_st_context.common.sge_page_base_lo =
-						U64_LO(fp->rx_sge_mapping);
-
-			context->ustorm_st_context.common.max_sges_for_packet =
-				SGE_PAGE_ALIGN(bp->dev->mtu) >> SGE_PAGE_SHIFT;
-			context->ustorm_st_context.common.max_sges_for_packet =
-				((context->ustorm_st_context.common.
-				  max_sges_for_packet + PAGES_PER_SGE - 1) &
-				 (~(PAGES_PER_SGE - 1))) >> PAGES_PER_SGE_SHIFT;
-		}
-
-		context->ustorm_ag_context.cdu_usage =
-			CDU_RSRVD_VALUE_TYPE_A(HW_CID(bp, i),
-					       CDU_REGION_NUMBER_UCM_AG,
-					       ETH_CONNECTION_TYPE);
-
-		context->xstorm_ag_context.cdu_reserved =
-			CDU_RSRVD_VALUE_TYPE_A(HW_CID(bp, i),
-					       CDU_REGION_NUMBER_XCM_AG,
-					       ETH_CONNECTION_TYPE);
-	}
-
-	/* Tx */
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-		struct eth_context *context =
-			bnx2x_sp(bp, context[i].eth);
-
-		context->cstorm_st_context.sb_index_number =
-						C_SB_ETH_TX_CQ_INDEX;
-		context->cstorm_st_context.status_block_id = fp->sb_id;
-
-		context->xstorm_st_context.tx_bd_page_base_hi =
-						U64_HI(fp->tx_desc_mapping);
-		context->xstorm_st_context.tx_bd_page_base_lo =
-						U64_LO(fp->tx_desc_mapping);
-		context->xstorm_st_context.statistics_data = (fp->cl_id |
-				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
+		elem->next_page.addr.hi =
+			cpu_to_le32(U64_HI(bp->eq_mapping +
+				   BCM_PAGE_SIZE * (i % NUM_EQ_PAGES)));
+		elem->next_page.addr.lo =
+			cpu_to_le32(U64_LO(bp->eq_mapping +
+				   BCM_PAGE_SIZE*(i % NUM_EQ_PAGES)));
 	}
+	bp->eq_cons = 0;
+	bp->eq_prod = NUM_EQ_DESC;
+	bp->eq_cons_sb = BNX2X_EQ_INDEX;
 }
 
 static void bnx2x_init_ind_table(struct bnx2x *bp)
@@ -3072,47 +3780,11 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 			bp->fp->cl_id + (i % bp->num_queues));
 }
 
-void bnx2x_set_client_config(struct bnx2x *bp)
-{
-	struct tstorm_eth_client_config tstorm_client = {0};
-	int port = BP_PORT(bp);
-	int i;
-
-	tstorm_client.mtu = bp->dev->mtu;
-	tstorm_client.config_flags =
-				(TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE |
-				 TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE);
-#ifdef BCM_VLAN
-	if (bp->rx_mode && bp->vlgrp && (bp->flags & HW_VLAN_RX_FLAG)) {
-		tstorm_client.config_flags |=
-				TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE;
-		DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
-	}
-#endif
-
-	for_each_queue(bp, i) {
-		tstorm_client.statistics_counter_id = bp->fp[i].cl_id;
-
-		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id),
-		       ((u32 *)&tstorm_client)[0]);
-		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id) + 4,
-		       ((u32 *)&tstorm_client)[1]);
-	}
-
-	DP(BNX2X_MSG_OFF, "tstorm_client: 0x%08x 0x%08x\n",
-	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]);
-}
-
 void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
-	struct tstorm_eth_mac_filter_config tstorm_mac_filter = {0};
 	int mode = bp->rx_mode;
-	int mask = bp->rx_mode_cl_mask;
-	int func = BP_FUNC(bp);
-	int port = BP_PORT(bp);
-	int i;
+	u16 cl_id;
+
 	/* All but management unicast packets should pass to the host as well */
 	u32 llh_mask =
 		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_BRCST |
@@ -3120,28 +3792,32 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_VLAN |
 		NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_NO_VLAN;
 
-	DP(NETIF_MSG_IFUP, "rx mode %d  mask 0x%x\n", mode, mask);
-
 	switch (mode) {
 	case BNX2X_RX_MODE_NONE: /* no Rx */
-		tstorm_mac_filter.ucast_drop_all = mask;
-		tstorm_mac_filter.mcast_drop_all = mask;
-		tstorm_mac_filter.bcast_drop_all = mask;
+		cl_id = BP_L_ID(bp);
+		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_NONE);
 		break;
 
 	case BNX2X_RX_MODE_NORMAL:
-		tstorm_mac_filter.bcast_accept_all = mask;
+		cl_id = BP_L_ID(bp);
+		bnx2x_rxq_set_mac_filters(bp, cl_id,
+			BNX2X_ACCEPT_UNICAST |
+			BNX2X_ACCEPT_BROADCAST |
+			BNX2X_ACCEPT_MULTICAST);
 		break;
 
 	case BNX2X_RX_MODE_ALLMULTI:
-		tstorm_mac_filter.mcast_accept_all = mask;
-		tstorm_mac_filter.bcast_accept_all = mask;
+		cl_id = BP_L_ID(bp);
+		bnx2x_rxq_set_mac_filters(bp, cl_id,
+			BNX2X_ACCEPT_UNICAST |
+			BNX2X_ACCEPT_BROADCAST |
+			BNX2X_ACCEPT_ALL_MULTICAST);
 		break;
 
 	case BNX2X_RX_MODE_PROMISC:
-		tstorm_mac_filter.ucast_accept_all = mask;
-		tstorm_mac_filter.mcast_accept_all = mask;
-		tstorm_mac_filter.bcast_accept_all = mask;
+		cl_id = BP_L_ID(bp);
+		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_PROMISCUOUS_MODE);
+
 		/* pass management unicast packets as well */
 		llh_mask |= NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_UNCST;
 		break;
@@ -3152,256 +3828,52 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 	}
 
 	REG_WR(bp,
-	       (port ? NIG_REG_LLH1_BRB1_DRV_MASK : NIG_REG_LLH0_BRB1_DRV_MASK),
+	       BP_PORT(bp) ? NIG_REG_LLH1_BRB1_DRV_MASK :
+			     NIG_REG_LLH0_BRB1_DRV_MASK,
 	       llh_mask);
 
-	for (i = 0; i < sizeof(struct tstorm_eth_mac_filter_config)/4; i++) {
-		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_MAC_FILTER_CONFIG_OFFSET(func) + i * 4,
-		       ((u32 *)&tstorm_mac_filter)[i]);
+	DP(NETIF_MSG_IFUP, "rx mode %d\n"
+		"drop_ucast 0x%x\ndrop_mcast 0x%x\ndrop_bcast 0x%x\n"
+		"accp_ucast 0x%x\naccp_mcast 0x%x\naccp_bcast 0x%x\n", mode,
+		bp->mac_filters.ucast_drop_all,
+		bp->mac_filters.mcast_drop_all,
+		bp->mac_filters.bcast_drop_all,
+		bp->mac_filters.ucast_accept_all,
+		bp->mac_filters.mcast_accept_all,
+		bp->mac_filters.bcast_accept_all
+	);
 
-/*		DP(NETIF_MSG_IFUP, "tstorm_mac_filter[%d]: 0x%08x\n", i,
-		   ((u32 *)&tstorm_mac_filter)[i]); */
-	}
-
-	if (mode != BNX2X_RX_MODE_NONE)
-		bnx2x_set_client_config(bp);
+	storm_memset_mac_filters(bp, &bp->mac_filters, BP_FUNC(bp));
 }
 
 static void bnx2x_init_internal_common(struct bnx2x *bp)
 {
 	int i;
 
-	/* Zero this manually as its initialization is
-	   currently missing in the initTool */
-	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_AGG_DATA_OFFSET + i * 4, 0);
-}
-
-static void bnx2x_init_internal_port(struct bnx2x *bp)
-{
-	int port = BP_PORT(bp);
-
-	REG_WR(bp,
-	       BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_U_OFFSET(port), BNX2X_BTR);
-	REG_WR(bp,
-	       BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_C_OFFSET(port), BNX2X_BTR);
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
-}
-
-static void bnx2x_init_internal_func(struct bnx2x *bp)
-{
-	struct tstorm_eth_function_common_config tstorm_config = {0};
-	struct stats_indication_flags stats_flags = {0};
-	int port = BP_PORT(bp);
-	int func = BP_FUNC(bp);
-	int i, j;
-	u32 offset;
-	u16 max_agg_size;
-
-	tstorm_config.config_flags = RSS_FLAGS(bp);
-
-	if (is_multi(bp))
-		tstorm_config.rss_result_mask = MULTI_MASK;
-
-	/* Enable TPA if needed */
-	if (bp->flags & TPA_ENABLE_FLAG)
-		tstorm_config.config_flags |=
-			TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA;
-
-	if (IS_E1HMF(bp))
-		tstorm_config.config_flags |=
-				TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM;
-
-	tstorm_config.leading_client_id = BP_L_ID(bp);
-
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(func),
-	       (*(u32 *)&tstorm_config));
-
-	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
-	bp->rx_mode_cl_mask = (1 << BP_L_ID(bp));
-	bnx2x_set_storm_rx_mode(bp);
-
-	for_each_queue(bp, i) {
-		u8 cl_id = bp->fp[i].cl_id;
-
-		/* reset xstorm per client statistics */
-		offset = BAR_XSTRORM_INTMEM +
-			 XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cl_id);
-		for (j = 0;
-		     j < sizeof(struct xstorm_per_client_stats) / 4; j++)
-			REG_WR(bp, offset + j*4, 0);
-
-		/* reset tstorm per client statistics */
-		offset = BAR_TSTRORM_INTMEM +
-			 TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cl_id);
-		for (j = 0;
-		     j < sizeof(struct tstorm_per_client_stats) / 4; j++)
-			REG_WR(bp, offset + j*4, 0);
-
-		/* reset ustorm per client statistics */
-		offset = BAR_USTRORM_INTMEM +
-			 USTORM_PER_COUNTER_ID_STATS_OFFSET(port, cl_id);
-		for (j = 0;
-		     j < sizeof(struct ustorm_per_client_stats) / 4; j++)
-			REG_WR(bp, offset + j*4, 0);
-	}
-
-	/* Init statistics related context */
-	stats_flags.collect_eth = 1;
-
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(func),
-	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(func) + 4,
-	       ((u32 *)&stats_flags)[1]);
-
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(func),
-	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(func) + 4,
-	       ((u32 *)&stats_flags)[1]);
-
-	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_STATS_FLAGS_OFFSET(func),
-	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_STATS_FLAGS_OFFSET(func) + 4,
-	       ((u32 *)&stats_flags)[1]);
-
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func),
-	       ((u32 *)&stats_flags)[0]);
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func) + 4,
-	       ((u32 *)&stats_flags)[1]);
-
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
-	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
-	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
-
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
-	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
-	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
-
-	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
-	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
-	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
-	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+	if (!CHIP_IS_E1(bp)) {
 
-	if (CHIP_IS_E1H(bp)) {
+		/* xstorm needs to know whether to add  ovlan to packets or not,
+		 * in switch-independent we'll write 0 to here... */
 		REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNCTION_MODE_OFFSET,
-			IS_E1HMF(bp));
+			bp->e1hmf);
 		REG_WR8(bp, BAR_TSTRORM_INTMEM + TSTORM_FUNCTION_MODE_OFFSET,
-			IS_E1HMF(bp));
+			bp->e1hmf);
 		REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_FUNCTION_MODE_OFFSET,
-			IS_E1HMF(bp));
+			bp->e1hmf);
 		REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_FUNCTION_MODE_OFFSET,
-			IS_E1HMF(bp));
-
-		REG_WR16(bp, BAR_XSTRORM_INTMEM + XSTORM_E1HOV_OFFSET(func),
-			 bp->e1hov);
+			bp->e1hmf);
 	}
 
-	/* Init CQ ring mapping and aggregation size, the FW limit is 8 frags */
-	max_agg_size = min_t(u32, (min_t(u32, 8, MAX_SKB_FRAGS) *
-				   SGE_PAGE_SIZE * PAGES_PER_SGE), 0xffff);
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id),
-		       U64_LO(fp->rx_comp_mapping));
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id) + 4,
-		       U64_HI(fp->rx_comp_mapping));
-
-		/* Next page */
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_NEXT_OFFSET(port, fp->cl_id),
-		       U64_LO(fp->rx_comp_mapping + BCM_PAGE_SIZE));
+	/* Zero this manually as its initialization is
+	   currently missing in the initTool */
+	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_NEXT_OFFSET(port, fp->cl_id) + 4,
-		       U64_HI(fp->rx_comp_mapping + BCM_PAGE_SIZE));
-
-		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_MAX_AGG_SIZE_OFFSET(port, fp->cl_id),
-			 max_agg_size);
-	}
-
-	/* dropless flow control */
-	if (CHIP_IS_E1H(bp)) {
-		struct ustorm_eth_rx_pause_data_e1h rx_pause = {0};
-
-		rx_pause.bd_thr_low = 250;
-		rx_pause.cqe_thr_low = 250;
-		rx_pause.cos = 1;
-		rx_pause.sge_thr_low = 0;
-		rx_pause.bd_thr_high = 350;
-		rx_pause.cqe_thr_high = 350;
-		rx_pause.sge_thr_high = 0;
-
-		for_each_queue(bp, i) {
-			struct bnx2x_fastpath *fp = &bp->fp[i];
-
-			if (!fp->disable_tpa) {
-				rx_pause.sge_thr_low = 150;
-				rx_pause.sge_thr_high = 250;
-			}
-
-
-			offset = BAR_USTRORM_INTMEM +
-				 USTORM_ETH_RING_PAUSE_DATA_OFFSET(port,
-								   fp->cl_id);
-			for (j = 0;
-			     j < sizeof(struct ustorm_eth_rx_pause_data_e1h)/4;
-			     j++)
-				REG_WR(bp, offset + j*4,
-				       ((u32 *)&rx_pause)[j]);
-		}
-	}
-
-	memset(&(bp->cmng), 0, sizeof(struct cmng_struct_per_port));
-
-	/* Init rate shaping and fairness contexts */
-	if (IS_E1HMF(bp)) {
-		int vn;
-
-		/* During init there is no active link
-		   Until link is up, set link rate to 10Gbps */
-		bp->link_vars.line_speed = SPEED_10000;
-		bnx2x_init_port_minmax(bp);
-
-		if (!BP_NOMCP(bp))
-			bp->mf_config =
-			      SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
-		bnx2x_calc_vn_weight_sum(bp);
-
-		for (vn = VN_0; vn < E1HVN_MAX; vn++)
-			bnx2x_init_vn_minmax(bp, 2*vn + port);
-
-		/* Enable rate shaping and fairness */
-		bp->cmng.flags.cmng_enables |=
-					CMNG_FLAGS_PER_PORT_RATE_SHAPING_VN;
-
-	} else {
-		/* rate shaping and fairness are disabled */
-		DP(NETIF_MSG_IFUP,
-		   "single function mode  minmax will be disabled\n");
-	}
-
+		       USTORM_AGG_DATA_OFFSET + i * 4, 0);
+}
 
-	/* Store cmng structures to internal memory */
-	if (bp->port.pmf)
-		for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
-			REG_WR(bp, BAR_XSTRORM_INTMEM +
-			       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i * 4,
-			       ((u32 *)(&bp->cmng))[i]);
+static void bnx2x_init_internal_port(struct bnx2x *bp)
+{
+	/* port */
 }
 
 static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
@@ -3416,7 +3888,8 @@ static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
 		/* no break */
 
 	case FW_MSG_CODE_DRV_LOAD_FUNCTION:
-		bnx2x_init_internal_func(bp);
+		/* internal memory per function is
+		   initialized inside bnx2x_pf_init */
 		break;
 
 	default:
@@ -3425,43 +3898,61 @@ static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
 	}
 }
 
+static void bnx2x_init_fp_sb(struct bnx2x *bp, int fp_idx)
+{
+	struct bnx2x_fastpath *fp = &bp->fp[fp_idx];
+
+	fp->state = BNX2X_FP_STATE_CLOSED;
+
+	fp->index = fp->cid = fp_idx;
+	fp->cl_id = BP_L_ID(bp) + fp_idx;
+	fp->fw_sb_id = bp->base_fw_ndsb + fp->cl_id + CNIC_CONTEXT_USE;
+	fp->igu_sb_id = bp->igu_base_sb + fp_idx + CNIC_CONTEXT_USE;
+	/* qZone id equals to FW (per path) client id */
+	fp->cl_qzone_id  = fp->cl_id +
+			   BP_PORT(bp)*(ETH_MAX_RX_CLIENTS_E1H);
+	/* init shortcut */
+	fp->ustorm_rx_prods_offset =
+			    USTORM_RX_PRODS_E1X_OFFSET(BP_PORT(bp), fp->cl_id);
+	/* Setup SB indicies */
+	fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
+	fp->tx_cons_sb = BNX2X_TX_SB_INDEX;
+
+	DP(NETIF_MSG_IFUP, "queue[%d]:  bnx2x_init_sb(%p,%p)  "
+				   "cl_id %d  fw_sb %d  igu_sb %d\n",
+		   fp_idx, bp, fp->status_blk.e1x_sb, fp->cl_id, fp->fw_sb_id,
+		   fp->igu_sb_id);
+	bnx2x_init_sb(bp, fp->status_blk_mapping, BNX2X_VF_ID_INVALID, false,
+		      fp->fw_sb_id, fp->igu_sb_id);
+
+	bnx2x_update_fpsb_idx(fp);
+}
+
 void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 {
 	int i;
 
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-
-		fp->bp = bp;
-		fp->state = BNX2X_FP_STATE_CLOSED;
-		fp->index = i;
-		fp->cl_id = BP_L_ID(bp) + i;
+	for_each_queue(bp, i)
+		bnx2x_init_fp_sb(bp, i);
 #ifdef BCM_CNIC
-		fp->sb_id = fp->cl_id + 1;
-#else
-		fp->sb_id = fp->cl_id;
+
+	bnx2x_init_sb(bp, bp->cnic_sb_mapping,
+		      BNX2X_VF_ID_INVALID, false,
+		      CNIC_SB_ID(bp), CNIC_IGU_SB_ID(bp));
+
 #endif
-		DP(NETIF_MSG_IFUP,
-		   "queue[%d]:  bnx2x_init_sb(%p,%p)  cl_id %d  sb %d\n",
-		   i, bp, fp->status_blk, fp->cl_id, fp->sb_id);
-		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping,
-			      fp->sb_id);
-		bnx2x_update_fpsb_idx(fp);
-	}
 
 	/* ensure status block indices were read */
 	rmb();
 
-
-	bnx2x_init_def_sb(bp, bp->def_status_blk, bp->def_status_blk_mapping,
-			  DEF_SB_ID);
+	bnx2x_init_def_sb(bp);
 	bnx2x_update_dsb_idx(bp);
-	bnx2x_update_coalesce(bp);
 	bnx2x_init_rx_rings(bp);
-	bnx2x_init_tx_ring(bp);
+	bnx2x_init_tx_rings(bp);
 	bnx2x_init_sp_ring(bp);
-	bnx2x_init_context(bp);
+	bnx2x_init_eq_ring(bp);
 	bnx2x_init_internal(bp, load_code);
+	bnx2x_pf_init(bp);
 	bnx2x_init_ind_table(bp);
 	bnx2x_stats_init(bp);
 
@@ -3620,8 +4111,6 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	else
 		factor = 1;
 
-	DP(NETIF_MSG_HW, "start part1\n");
-
 	/* Disable inputs of parser neighbor blocks */
 	REG_WR(bp, TSDM_REG_ENABLE_IN1, 0x0);
 	REG_WR(bp, TCM_REG_PRS_IFEN, 0x0);
@@ -3917,12 +4406,9 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 	REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
 }
 
-static int bnx2x_init_common(struct bnx2x *bp)
+static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 {
 	u32 val, i;
-#ifdef BCM_CNIC
-	u32 wb_write[2];
-#endif
 
 	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
 
@@ -3964,12 +4450,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, 1);
 #endif
 
-	REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 2);
-#ifdef BCM_CNIC
-	REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
-	REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
-	REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
-#endif
+	bnx2x_ilt_init_page_size(bp, INITOP_SET);
+
 
 	if (CHIP_REV_IS_FPGA(bp) && CHIP_IS_E1H(bp))
 		REG_WR(bp, PXP2_REG_PGL_TAGS_LIMIT, 0x1);
@@ -4009,20 +4491,9 @@ static int bnx2x_init_common(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, QM_BLOCK, COMMON_STAGE);
 
-#ifdef BCM_CNIC
-	wb_write[0] = 0;
-	wb_write[1] = 0;
-	for (i = 0; i < 64; i++) {
-		REG_WR(bp, QM_REG_BASEADDR + i*4, 1024 * 4 * (i%16));
-		bnx2x_init_ind_wr(bp, QM_REG_PTRTBL + i*8, wb_write, 2);
-
-		if (CHIP_IS_E1H(bp)) {
-			REG_WR(bp, QM_REG_BASEADDR_EXT_A + i*4, 1024*4*(i%16));
-			bnx2x_init_ind_wr(bp, QM_REG_PTRTBL_EXT_A + i*8,
-					  wb_write, 2);
-		}
-	}
-#endif
+	/* QM queues pointers table */
+	bnx2x_qm_init_ptr_table(bp, bp->qm_cid_count, INITOP_SET);
+
 	/* soft reset pulse */
 	REG_WR(bp, QM_REG_SOFT_RESET, 1);
 	REG_WR(bp, QM_REG_SOFT_RESET, 0);
@@ -4032,7 +4503,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 #endif
 
 	bnx2x_init_block(bp, DQ_BLOCK, COMMON_STAGE);
-	REG_WR(bp, DORQ_REG_DPM_CID_OFST, BCM_PAGE_SHIFT);
+	REG_WR(bp, DORQ_REG_DPM_CID_OFST, BNX2X_DB_SHIFT);
+
 	if (!CHIP_REV_IS_SLOW(bp)) {
 		/* enable hw interrupt from doorbell Q */
 		REG_WR(bp, DORQ_REG_DORQ_INT_MASK, 0);
@@ -4184,7 +4656,7 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	return 0;
 }
 
-static int bnx2x_init_port(struct bnx2x *bp)
+static int bnx2x_init_hw_port(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int init_stage = port ? PORT1_STAGE : PORT0_STAGE;
@@ -4203,9 +4675,10 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, CCM_BLOCK, init_stage);
 	bnx2x_init_block(bp, XCM_BLOCK, init_stage);
 
-#ifdef BCM_CNIC
-	REG_WR(bp, QM_REG_CONNNUM_0 + port*4, 1024/16 - 1);
+	/* QM cid (connection) count */
+	bnx2x_qm_init_cid_count(bp, bp->qm_cid_count, INITOP_SET);
 
+#ifdef BCM_CNIC
 	bnx2x_init_block(bp, TIMERS_BLOCK, init_stage);
 	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
 	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
@@ -4327,25 +4800,6 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	return 0;
 }
 
-#define ILT_PER_FUNC		(768/2)
-#define FUNC_ILT_BASE(func)	(func * ILT_PER_FUNC)
-/* the phys address is shifted right 12 bits and has an added
-   1=valid bit added to the 53rd bit
-   then since this is a wide register(TM)
-   we split it into two 32 bit writes
- */
-#define ONCHIP_ADDR1(x)		((u32)(((u64)x >> 12) & 0xFFFFFFFF))
-#define ONCHIP_ADDR2(x)		((u32)((1 << 20) | ((u64)x >> 44)))
-#define PXP_ONE_ILT(x)		(((x) << 10) | x)
-#define PXP_ILT_RANGE(f, l)	(((l) << 10) | f)
-
-#ifdef BCM_CNIC
-#define CNIC_ILT_LINES		127
-#define CNIC_CTX_PER_ILT	16
-#else
-#define CNIC_ILT_LINES		0
-#endif
-
 static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
 {
 	int reg;
@@ -4358,10 +4812,12 @@ static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
 	bnx2x_wb_wr(bp, reg, ONCHIP_ADDR1(addr), ONCHIP_ADDR2(addr));
 }
 
-static int bnx2x_init_func(struct bnx2x *bp)
+static int bnx2x_init_hw_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
+	struct bnx2x_ilt *ilt = BP_ILT(bp);
+	u16 cdu_ilt_start;
 	u32 addr, val;
 	int i;
 
@@ -4373,72 +4829,67 @@ static int bnx2x_init_func(struct bnx2x *bp)
 	val |= HC_CONFIG_0_REG_MSI_ATTN_EN_0;
 	REG_WR(bp, addr, val);
 
-	i = FUNC_ILT_BASE(func);
-
-	bnx2x_ilt_wr(bp, i, bnx2x_sp_mapping(bp, context));
-	if (CHIP_IS_E1H(bp)) {
-		REG_WR(bp, PXP2_REG_RQ_CDU_FIRST_ILT, i);
-		REG_WR(bp, PXP2_REG_RQ_CDU_LAST_ILT, i + CNIC_ILT_LINES);
-	} else /* E1 */
-		REG_WR(bp, PXP2_REG_PSWRQ_CDU0_L2P + func*4,
-		       PXP_ILT_RANGE(i, i + CNIC_ILT_LINES));
-
-#ifdef BCM_CNIC
-	i += 1 + CNIC_ILT_LINES;
-	bnx2x_ilt_wr(bp, i, bp->timers_mapping);
-	if (CHIP_IS_E1(bp))
-		REG_WR(bp, PXP2_REG_PSWRQ_TM0_L2P + func*4, PXP_ONE_ILT(i));
-	else {
-		REG_WR(bp, PXP2_REG_RQ_TM_FIRST_ILT, i);
-		REG_WR(bp, PXP2_REG_RQ_TM_LAST_ILT, i);
-	}
-
-	i++;
-	bnx2x_ilt_wr(bp, i, bp->qm_mapping);
-	if (CHIP_IS_E1(bp))
-		REG_WR(bp, PXP2_REG_PSWRQ_QM0_L2P + func*4, PXP_ONE_ILT(i));
-	else {
-		REG_WR(bp, PXP2_REG_RQ_QM_FIRST_ILT, i);
-		REG_WR(bp, PXP2_REG_RQ_QM_LAST_ILT, i);
-	}
+	ilt = BP_ILT(bp);
+	cdu_ilt_start = ilt->clients[ILT_CLIENT_CDU].start;
 
-	i++;
-	bnx2x_ilt_wr(bp, i, bp->t1_mapping);
-	if (CHIP_IS_E1(bp))
-		REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
-	else {
-		REG_WR(bp, PXP2_REG_RQ_SRC_FIRST_ILT, i);
-		REG_WR(bp, PXP2_REG_RQ_SRC_LAST_ILT, i);
+	for (i = 0; i < L2_ILT_LINES(bp); i++) {
+		ilt->lines[cdu_ilt_start + i].page =
+			bp->context.vcxt + (ILT_PAGE_CIDS * i);
+		ilt->lines[cdu_ilt_start + i].page_mapping =
+			bp->context.cxt_mapping + (CDU_ILT_PAGE_SZ * i);
+		/* cdu ilt pages are allocated manually so there's no need to
+		set the size */
 	}
+	bnx2x_ilt_init_op(bp, INITOP_SET);
+#ifdef BCM_CNIC
+	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
 
-	/* tell the searcher where the T2 table is */
-	REG_WR(bp, SRC_REG_COUNTFREE0 + port*4, 16*1024/64);
-
-	bnx2x_wb_wr(bp, SRC_REG_FIRSTFREE0 + port*16,
-		    U64_LO(bp->t2_mapping), U64_HI(bp->t2_mapping));
+	/* T1 hash bits value determines the T1 number of entries */
+	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, SRC_HASH_BITS);
+#endif
 
-	bnx2x_wb_wr(bp, SRC_REG_LASTFREE0 + port*16,
-		    U64_LO((u64)bp->t2_mapping + 16*1024 - 64),
-		    U64_HI((u64)bp->t2_mapping + 16*1024 - 64));
+#ifndef BCM_CNIC
+	/* set NIC mode */
+	REG_WR(bp, PRS_REG_NIC_MODE, 1);
+#endif  /* BCM_CNIC */
 
-	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, 10);
-#endif
+	bp->dmae_ready = 1;
 
-	if (CHIP_IS_E1H(bp)) {
-		bnx2x_init_block(bp, MISC_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, TCM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, UCM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, CCM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, XCM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, TSEM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, USEM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, CSEM_BLOCK, FUNC0_STAGE + func);
-		bnx2x_init_block(bp, XSEM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, PGLUE_B_BLOCK, FUNC0_STAGE + func);
+
+	bnx2x_init_block(bp, MISC_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, TCM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, UCM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, CCM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, XCM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, TSEM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, USEM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, CSEM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, XSEM_BLOCK, FUNC0_STAGE + func);
+
+	bnx2x_init_block(bp, QM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, TIMERS_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, DQ_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, BRB1_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, PRS_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, TSDM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, CSDM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, USDM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, XSDM_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, UPB_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, XPB_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, PBF_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, CDU_BLOCK, FUNC0_STAGE + func);
+
+	bnx2x_init_block(bp, CFC_BLOCK, FUNC0_STAGE + func);
 
+	if (IS_E1HMF(bp)) {
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
 		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->e1hov);
 	}
 
+	bnx2x_init_block(bp, MISC_AEU_BLOCK, FUNC0_STAGE + func);
+
 	/* HC init per function */
 	if (CHIP_IS_E1H(bp)) {
 		REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
@@ -4451,13 +4902,21 @@ static int bnx2x_init_func(struct bnx2x *bp)
 	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
 	REG_WR(bp, 0x2120, 0xffffffff);
+
+	bnx2x_init_block(bp, EMAC0_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, EMAC1_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, DBU_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, DBG_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, MCP_BLOCK, FUNC0_STAGE + func);
+	bnx2x_init_block(bp, DMAE_BLOCK, FUNC0_STAGE + func);
+
 	bnx2x_phy_probe(&bp->link_params);
 	return 0;
 }
 
 int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 {
-	int i, rc = 0;
+	int rc = 0;
 
 	DP(BNX2X_MSG_MCP, "function %d  load_code %x\n",
 	   BP_FUNC(bp), load_code);
@@ -4470,21 +4929,19 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 
 	switch (load_code) {
 	case FW_MSG_CODE_DRV_LOAD_COMMON:
-		rc = bnx2x_init_common(bp);
+		rc = bnx2x_init_hw_common(bp, load_code);
 		if (rc)
 			goto init_hw_err;
 		/* no break */
 
 	case FW_MSG_CODE_DRV_LOAD_PORT:
-		bp->dmae_ready = 1;
-		rc = bnx2x_init_port(bp);
+		rc = bnx2x_init_hw_port(bp);
 		if (rc)
 			goto init_hw_err;
 		/* no break */
 
 	case FW_MSG_CODE_DRV_LOAD_FUNCTION:
-		bp->dmae_ready = 1;
-		rc = bnx2x_init_func(bp);
+		rc = bnx2x_init_hw_func(bp);
 		if (rc)
 			goto init_hw_err;
 		break;
@@ -4503,14 +4960,6 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
 	}
 
-	/* this needs to be done before gunzip end */
-	bnx2x_zero_def_sb(bp);
-	for_each_queue(bp, i)
-		bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
-#ifdef BCM_CNIC
-	bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
-#endif
-
 init_hw_err:
 	bnx2x_gunzip_end(bp);
 
@@ -4523,7 +4972,7 @@ void bnx2x_free_mem(struct bnx2x *bp)
 #define BNX2X_PCI_FREE(x, y, size) \
 	do { \
 		if (x) { \
-			dma_free_coherent(&bp->pdev->dev, size, x, y); \
+			dma_free_coherent(&bp->pdev->dev, size, (void *)x, y); \
 			x = NULL; \
 			y = 0; \
 		} \
@@ -4532,7 +4981,7 @@ void bnx2x_free_mem(struct bnx2x *bp)
 #define BNX2X_FREE(x) \
 	do { \
 		if (x) { \
-			vfree(x); \
+			kfree((void *)x); \
 			x = NULL; \
 		} \
 	} while (0)
@@ -4542,11 +4991,10 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	/* fastpath */
 	/* Common */
 	for_each_queue(bp, i) {
-
 		/* status blocks */
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk),
+		BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e1x_sb),
 			       bnx2x_fp(bp, i, status_blk_mapping),
-			       sizeof(struct host_status_block));
+			       sizeof(struct host_hc_status_block_e1x));
 	}
 	/* Rx */
 	for_each_queue(bp, i) {
@@ -4580,21 +5028,28 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	/* end of fastpath */
 
 	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
-		       sizeof(struct host_def_status_block));
+		       sizeof(struct host_sp_status_block));
 
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
 		       sizeof(struct bnx2x_slowpath));
 
+	BNX2X_PCI_FREE(bp->context.vcxt, bp->context.cxt_mapping,
+		       bp->context.size);
+
+	bnx2x_ilt_mem_op(bp, ILT_MEMOP_FREE);
+
+	BNX2X_FREE(bp->ilt->lines);
 #ifdef BCM_CNIC
-	BNX2X_PCI_FREE(bp->t1, bp->t1_mapping, 64*1024);
-	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, 16*1024);
-	BNX2X_PCI_FREE(bp->timers, bp->timers_mapping, 8*1024);
-	BNX2X_PCI_FREE(bp->qm, bp->qm_mapping, 128*1024);
-	BNX2X_PCI_FREE(bp->cnic_sb, bp->cnic_sb_mapping,
-		       sizeof(struct host_status_block));
+
+	BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
+		       sizeof(struct host_hc_status_block_e1x));
+	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
 #endif
 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, BCM_PAGE_SIZE);
 
+	BNX2X_PCI_FREE(bp->eq_ring, bp->eq_mapping,
+		       BCM_PAGE_SIZE * NUM_EQ_PAGES);
+
 #undef BNX2X_PCI_FREE
 #undef BNX2X_KFREE
 }
@@ -4612,13 +5067,13 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 
 #define BNX2X_ALLOC(x, size) \
 	do { \
-		x = vmalloc(size); \
+		x = kzalloc(size, GFP_KERNEL); \
 		if (x == NULL) \
 			goto alloc_mem_err; \
-		memset(x, 0, size); \
 	} while (0)
 
 	int i;
+	void *p;
 
 	/* fastpath */
 	/* Common */
@@ -4626,9 +5081,17 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 		bnx2x_fp(bp, i, bp) = bp;
 
 		/* status blocks */
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, status_blk),
+		BNX2X_PCI_ALLOC(p,
 				&bnx2x_fp(bp, i, status_blk_mapping),
-				sizeof(struct host_status_block));
+				sizeof(struct host_hc_status_block_e1x));
+
+		bnx2x_fp(bp, i, status_blk.e1x_sb) =
+				(struct host_hc_status_block_e1x *)p;
+
+		bnx2x_fp(bp, i, sb_index_values) = (__le16 *)
+			(bnx2x_fp(bp, i, status_blk.e1x_sb)->sb.index_values);
+		bnx2x_fp(bp, i, sb_running_index) = (__le16 *)
+			(bnx2x_fp(bp, i, status_blk.e1x_sb)->sb.running_index);
 	}
 	/* Rx */
 	for_each_queue(bp, i) {
@@ -4664,37 +5127,36 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	}
 	/* end of fastpath */
 
-	BNX2X_PCI_ALLOC(bp->def_status_blk, &bp->def_status_blk_mapping,
-			sizeof(struct host_def_status_block));
+#ifdef BCM_CNIC
+	BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb, &bp->cnic_sb_mapping,
+			sizeof(struct host_hc_status_block_e1x));
 
-	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
-			sizeof(struct bnx2x_slowpath));
+	/* allocate searcher T2 table */
+	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
+#endif
 
-#ifdef BCM_CNIC
-	BNX2X_PCI_ALLOC(bp->t1, &bp->t1_mapping, 64*1024);
 
-	/* allocate searcher T2 table
-	   we allocate 1/4 of alloc num for T2
-	  (which is not entered into the ILT) */
-	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, 16*1024);
+	BNX2X_PCI_ALLOC(bp->def_status_blk, &bp->def_status_blk_mapping,
+			sizeof(struct host_sp_status_block));
 
-	/* Initialize T2 (for 1024 connections) */
-	for (i = 0; i < 16*1024; i += 64)
-		*(u64 *)((char *)bp->t2 + i + 56) = bp->t2_mapping + i + 64;
+	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
+			sizeof(struct bnx2x_slowpath));
 
-	/* Timer block array (8*MAX_CONN) phys uncached for now 1024 conns */
-	BNX2X_PCI_ALLOC(bp->timers, &bp->timers_mapping, 8*1024);
+	bp->context.size = sizeof(union cdu_context) * bp->l2_cid_count;
+	BNX2X_PCI_ALLOC(bp->context.vcxt, &bp->context.cxt_mapping,
+			bp->context.size);
 
-	/* QM queues (128*MAX_CONN) */
-	BNX2X_PCI_ALLOC(bp->qm, &bp->qm_mapping, 128*1024);
+	BNX2X_ALLOC(bp->ilt->lines, sizeof(struct ilt_line) * ILT_MAX_LINES);
 
-	BNX2X_PCI_ALLOC(bp->cnic_sb, &bp->cnic_sb_mapping,
-			sizeof(struct host_status_block));
-#endif
+	if (bnx2x_ilt_mem_op(bp, ILT_MEMOP_ALLOC))
+		goto alloc_mem_err;
 
 	/* Slow path ring */
 	BNX2X_PCI_ALLOC(bp->spq, &bp->spq_mapping, BCM_PAGE_SIZE);
 
+	/* EQ */
+	BNX2X_PCI_ALLOC(bp->eq_ring, &bp->eq_mapping,
+			BCM_PAGE_SIZE * NUM_EQ_PAGES);
 	return 0;
 
 alloc_mem_err:
@@ -4705,97 +5167,52 @@ alloc_mem_err:
 #undef BNX2X_ALLOC
 }
 
-
 /*
  * Init service functions
  */
-
-/**
- * Sets a MAC in a CAM for a few L2 Clients for E1 chip
- *
- * @param bp driver descriptor
- * @param set set or clear an entry (1 or 0)
- * @param mac pointer to a buffer containing a MAC
- * @param cl_bit_vec bit vector of clients to register a MAC for
- * @param cam_offset offset in a CAM to use
- * @param with_bcast set broadcast MAC as well
- */
-static void bnx2x_set_mac_addr_e1_gen(struct bnx2x *bp, int set, u8 *mac,
-				      u32 cl_bit_vec, u8 cam_offset,
-				      u8 with_bcast)
+int bnx2x_func_start(struct bnx2x *bp)
 {
-	struct mac_configuration_cmd *config = bnx2x_sp(bp, mac_config);
-	int port = BP_PORT(bp);
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_FUNCTION_START, 0, 0, 0, 1);
 
-	/* CAM allocation
-	 * unicasts 0-31:port0 32-63:port1
-	 * multicast 64-127:port0 128-191:port1
-	 */
-	config->hdr.length = 1 + (with_bcast ? 1 : 0);
-	config->hdr.offset = cam_offset;
-	config->hdr.client_id = 0xff;
-	config->hdr.reserved1 = 0;
-
-	/* primary MAC */
-	config->config_table[0].cam_entry.msb_mac_addr =
-					swab16(*(u16 *)&mac[0]);
-	config->config_table[0].cam_entry.middle_mac_addr =
-					swab16(*(u16 *)&mac[2]);
-	config->config_table[0].cam_entry.lsb_mac_addr =
-					swab16(*(u16 *)&mac[4]);
-	config->config_table[0].cam_entry.flags = cpu_to_le16(port);
-	if (set)
-		config->config_table[0].target_table_entry.flags = 0;
-	else
-		CAM_INVALIDATE(config->config_table[0]);
-	config->config_table[0].target_table_entry.clients_bit_vector =
-						cpu_to_le32(cl_bit_vec);
-	config->config_table[0].target_table_entry.vlan_id = 0;
+	/* Wait for completion */
+	return bnx2x_wait_ramrod(bp, BNX2X_STATE_FUNC_STARTED, 0, &(bp->state),
+				 WAIT_RAMROD_COMMON);
+}
 
-	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)\n",
-	   (set ? "setting" : "clearing"),
-	   config->config_table[0].cam_entry.msb_mac_addr,
-	   config->config_table[0].cam_entry.middle_mac_addr,
-	   config->config_table[0].cam_entry.lsb_mac_addr);
-
-	/* broadcast */
-	if (with_bcast) {
-		config->config_table[1].cam_entry.msb_mac_addr =
-			cpu_to_le16(0xffff);
-		config->config_table[1].cam_entry.middle_mac_addr =
-			cpu_to_le16(0xffff);
-		config->config_table[1].cam_entry.lsb_mac_addr =
-			cpu_to_le16(0xffff);
-		config->config_table[1].cam_entry.flags = cpu_to_le16(port);
-		if (set)
-			config->config_table[1].target_table_entry.flags =
-					TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
-		else
-			CAM_INVALIDATE(config->config_table[1]);
-		config->config_table[1].target_table_entry.clients_bit_vector =
-							cpu_to_le32(cl_bit_vec);
-		config->config_table[1].target_table_entry.vlan_id = 0;
-	}
+int bnx2x_func_stop(struct bnx2x *bp)
+{
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_FUNCTION_STOP, 0, 0, 0, 1);
 
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
-		      U64_HI(bnx2x_sp_mapping(bp, mac_config)),
-		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
+	/* Wait for completion */
+	return bnx2x_wait_ramrod(bp, BNX2X_STATE_CLOSING_WAIT4_UNLOAD,
+				      0, &(bp->state), WAIT_RAMROD_COMMON);
 }
 
 /**
- * Sets a MAC in a CAM for a few L2 Clients for E1H chip
+ * Sets a MAC in a CAM for a few L2 Clients for E1x chip
  *
  * @param bp driver descriptor
  * @param set set or clear an entry (1 or 0)
  * @param mac pointer to a buffer containing a MAC
  * @param cl_bit_vec bit vector of clients to register a MAC for
  * @param cam_offset offset in a CAM to use
+ * @param is_bcast is the set MAC a broadcast address (for E1 only)
  */
-static void bnx2x_set_mac_addr_e1h_gen(struct bnx2x *bp, int set, u8 *mac,
-				       u32 cl_bit_vec, u8 cam_offset)
+static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, u8 *mac,
+				      u32 cl_bit_vec, u8 cam_offset,
+				      u8 is_bcast)
 {
-	struct mac_configuration_cmd_e1h *config =
-		(struct mac_configuration_cmd_e1h *)bnx2x_sp(bp, mac_config);
+	struct mac_configuration_cmd *config =
+		(struct mac_configuration_cmd *)bnx2x_sp(bp, mac_config);
+	int ramrod_flags = WAIT_RAMROD_COMMON;
+
+	bp->set_mac_pending = 1;
+	smp_wmb();
+
+	config->hdr.length = 1 + (is_bcast ? 1 : 0);
+	config->hdr.offset = cam_offset;
+	config->hdr.client_id = 0xff;
+	config->hdr.reserved1 = 0;
 
 	config->hdr.length = 1;
 	config->hdr.offset = cam_offset;
@@ -4812,29 +5229,42 @@ static void bnx2x_set_mac_addr_e1h_gen(struct bnx2x *bp, int set, u8 *mac,
 	config->config_table[0].clients_bit_vector =
 					cpu_to_le32(cl_bit_vec);
 	config->config_table[0].vlan_id = 0;
-	config->config_table[0].e1hov_id = cpu_to_le16(bp->e1hov);
+	config->config_table[0].pf_id = BP_FUNC(bp);
 	if (set)
-		config->config_table[0].flags = BP_PORT(bp);
+		SET_FLAG(config->config_table[0].flags,
+			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+			T_ETH_MAC_COMMAND_SET);
 	else
-		config->config_table[0].flags =
-				MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE;
+		SET_FLAG(config->config_table[0].flags,
+			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+			T_ETH_MAC_COMMAND_INVALIDATE);
+
+	if (is_bcast)
+		SET_FLAG(config->config_table[0].flags,
+			MAC_CONFIGURATION_ENTRY_BROADCAST, 1);
 
-	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)  E1HOV %d  CLID mask %d\n",
+	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)  PF_ID %d  CLID mask %d\n",
 	   (set ? "setting" : "clearing"),
 	   config->config_table[0].msb_mac_addr,
 	   config->config_table[0].middle_mac_addr,
-	   config->config_table[0].lsb_mac_addr, bp->e1hov, cl_bit_vec);
+	   config->config_table[0].lsb_mac_addr, BP_FUNC(bp), cl_bit_vec);
 
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
 		      U64_HI(bnx2x_sp_mapping(bp, mac_config)),
-		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
+		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 1);
+
+	/* Wait for a completion */
+	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, ramrod_flags);
 }
 
-static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
-			     int *state_p, int poll)
+
+int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
+			     int *state_p, int flags)
 {
 	/* can take a while if any port is running */
 	int cnt = 5000;
+	u8 poll = flags & WAIT_RAMROD_POLL;
+	u8 common = flags & WAIT_RAMROD_COMMON;
 
 	DP(NETIF_MSG_IFUP, "%s for state to become %x on IDX [%d]\n",
 	   poll ? "polling" : "waiting", state, idx);
@@ -4842,13 +5272,17 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	might_sleep();
 	while (cnt--) {
 		if (poll) {
-			bnx2x_rx_int(bp->fp, 10);
-			/* if index is different from 0
-			 * the reply for some commands will
-			 * be on the non default queue
-			 */
-			if (idx)
-				bnx2x_rx_int(&bp->fp[idx], 10);
+			if (common)
+				bnx2x_eq_int(bp);
+			else {
+				bnx2x_rx_int(bp->fp, 10);
+				/* if index is different from 0
+				 * the reply for some commands will
+				 * be on the non default queue
+				 */
+				if (idx)
+					bnx2x_rx_int(&bp->fp[idx], 10);
+			}
 		}
 
 		mb(); /* state is changed by bnx2x_sp_event() */
@@ -4875,31 +5309,110 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	return -EBUSY;
 }
 
-void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set)
+u8 bnx2x_e1h_cam_offset(struct bnx2x *bp, u8 rel_offset)
 {
-	bp->set_mac_pending++;
-	smp_wmb();
+	return E1H_FUNC_MAX * rel_offset + BP_FUNC(bp);
+}
+
+void bnx2x_set_eth_mac(struct bnx2x *bp, int set)
+{
+	u8 cam_offset = (CHIP_IS_E1(bp) ? (BP_PORT(bp) ? 32 : 0) :
+			 bnx2x_e1h_cam_offset(bp, CAM_ETH_LINE));
 
-	bnx2x_set_mac_addr_e1h_gen(bp, set, bp->dev->dev_addr,
-				   (1 << bp->fp->cl_id), BP_FUNC(bp));
+	/* networking  MAC */
+	bnx2x_set_mac_addr_gen(bp, set, bp->dev->dev_addr,
+			       (1 << bp->fp->cl_id), cam_offset , 0);
 
-	/* Wait for a completion */
-	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
+	if (CHIP_IS_E1(bp)) {
+		/* broadcast MAC */
+		u8 bcast[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+		bnx2x_set_mac_addr_gen(bp, set, bcast, 0, cam_offset + 1, 1);
+	}
 }
+static void bnx2x_set_e1_mc_list(struct bnx2x *bp, u8 offset)
+{
+	int i = 0, old;
+	struct net_device *dev = bp->dev;
+	struct netdev_hw_addr *ha;
+	struct mac_configuration_cmd *config_cmd = bnx2x_sp(bp, mcast_config);
+	dma_addr_t config_cmd_map = bnx2x_sp_mapping(bp, mcast_config);
+
+	netdev_for_each_mc_addr(ha, dev) {
+		/* copy mac */
+		config_cmd->config_table[i].msb_mac_addr =
+			swab16(*(u16 *)&bnx2x_mc_addr(ha)[0]);
+		config_cmd->config_table[i].middle_mac_addr =
+			swab16(*(u16 *)&bnx2x_mc_addr(ha)[2]);
+		config_cmd->config_table[i].lsb_mac_addr =
+			swab16(*(u16 *)&bnx2x_mc_addr(ha)[4]);
+
+		config_cmd->config_table[i].vlan_id = 0;
+		config_cmd->config_table[i].pf_id = BP_FUNC(bp);
+		config_cmd->config_table[i].clients_bit_vector =
+			cpu_to_le32(1 << BP_L_ID(bp));
+
+		SET_FLAG(config_cmd->config_table[i].flags,
+			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+			T_ETH_MAC_COMMAND_SET);
+
+		DP(NETIF_MSG_IFUP,
+		   "setting MCAST[%d] (%04x:%04x:%04x)\n", i,
+		   config_cmd->config_table[i].msb_mac_addr,
+		   config_cmd->config_table[i].middle_mac_addr,
+		   config_cmd->config_table[i].lsb_mac_addr);
+		i++;
+	}
+	old = config_cmd->hdr.length;
+	if (old > i) {
+		for (; i < old; i++) {
+			if (CAM_IS_INVALID(config_cmd->
+					   config_table[i])) {
+				/* already invalidated */
+				break;
+			}
+			/* invalidate */
+			SET_FLAG(config_cmd->config_table[i].flags,
+				MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+				T_ETH_MAC_COMMAND_INVALIDATE);
+		}
+	}
+
+	config_cmd->hdr.length = i;
+	config_cmd->hdr.offset = offset;
+	config_cmd->hdr.client_id = 0xff;
+	config_cmd->hdr.reserved1 = 0;
+
+	bp->set_mac_pending = 1;
+	smp_wmb();
 
-void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
+		   U64_HI(config_cmd_map), U64_LO(config_cmd_map), 1);
+}
+static void bnx2x_invlidate_e1_mc_list(struct bnx2x *bp)
 {
-	bp->set_mac_pending++;
+	int i;
+	struct mac_configuration_cmd *config_cmd = bnx2x_sp(bp, mcast_config);
+	dma_addr_t config_cmd_map = bnx2x_sp_mapping(bp, mcast_config);
+	int ramrod_flags = WAIT_RAMROD_COMMON;
+
+	bp->set_mac_pending = 1;
 	smp_wmb();
 
-	bnx2x_set_mac_addr_e1_gen(bp, set, bp->dev->dev_addr,
-				  (1 << bp->fp->cl_id), (BP_PORT(bp) ? 32 : 0),
-				  1);
+	for (i = 0; i < config_cmd->hdr.length; i++)
+		SET_FLAG(config_cmd->config_table[i].flags,
+			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+			T_ETH_MAC_COMMAND_INVALIDATE);
+
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
+		      U64_HI(config_cmd_map), U64_LO(config_cmd_map), 1);
 
 	/* Wait for a completion */
-	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
+	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending,
+				ramrod_flags);
+
 }
 
+
 #ifdef BCM_CNIC
 /**
  * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
@@ -4913,65 +5426,181 @@ void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
  */
 int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 {
-	u32 cl_bit_vec = (1 << BCM_ISCSI_ETH_CL_ID);
-
-	bp->set_mac_pending++;
-	smp_wmb();
+	u8 cam_offset = (CHIP_IS_E1(bp) ? ((BP_PORT(bp) ? 32 : 0) + 2) :
+			 bnx2x_e1h_cam_offset(bp, CAM_ISCSI_ETH_LINE));
+	u32 iscsi_l2_cl_id = BNX2X_ISCSI_ETH_CL_ID;
+	u32 cl_bit_vec = (1 << iscsi_l2_cl_id);
 
 	/* Send a SET_MAC ramrod */
-	if (CHIP_IS_E1(bp))
-		bnx2x_set_mac_addr_e1_gen(bp, set, bp->iscsi_mac,
-				  cl_bit_vec, (BP_PORT(bp) ? 32 : 0) + 2,
-				  1);
-	else
-		/* CAM allocation for E1H
-		* unicasts: by func number
-		* multicast: 20+FUNC*20, 20 each
-		*/
-		bnx2x_set_mac_addr_e1h_gen(bp, set, bp->iscsi_mac,
-				   cl_bit_vec, E1H_FUNC_MAX + BP_FUNC(bp));
-
-	/* Wait for a completion when setting */
-	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
-
+	bnx2x_set_mac_addr_gen(bp, set, bp->iscsi_mac, cl_bit_vec,
+			       cam_offset, 0);
 	return 0;
 }
 #endif
 
-int bnx2x_setup_leading(struct bnx2x *bp)
-{
-	int rc;
+static void bnx2x_fill_cl_init_data(struct bnx2x *bp,
+				    struct bnx2x_client_init_params *params,
+				    u8 activate,
+				    struct client_init_ramrod_data *data)
+{
+	/* Clear the buffer */
+	memset(data, 0, sizeof(*data));
+
+	/* general */
+	data->general.client_id = params->rxq_params.cl_id;
+	data->general.statistics_counter_id = params->rxq_params.stat_id;
+	data->general.statistics_en_flg =
+		(params->rxq_params.flags & QUEUE_FLG_STATS) ? 1 : 0;
+	data->general.activate_flg = activate;
+	data->general.sp_client_id = params->rxq_params.spcl_id;
+
+	/* Rx data */
+	data->rx.tpa_en_flg =
+		(params->rxq_params.flags & QUEUE_FLG_TPA) ? 1 : 0;
+	data->rx.vmqueue_mode_en_flg = 0;
+	data->rx.cache_line_alignment_log_size =
+		params->rxq_params.cache_line_log;
+	data->rx.enable_dynamic_hc =
+		(params->rxq_params.flags & QUEUE_FLG_DHC) ? 1 : 0;
+	data->rx.max_sges_for_packet = params->rxq_params.max_sges_pkt;
+	data->rx.client_qzone_id = params->rxq_params.cl_qzone_id;
+	data->rx.max_agg_size = params->rxq_params.tpa_agg_sz;
+
+	/* We don't set drop flags */
+	data->rx.drop_ip_cs_err_flg = 0;
+	data->rx.drop_tcp_cs_err_flg = 0;
+	data->rx.drop_ttl0_flg = 0;
+	data->rx.drop_udp_cs_err_flg = 0;
+
+	data->rx.inner_vlan_removal_enable_flg =
+		(params->rxq_params.flags & QUEUE_FLG_VLAN) ? 1 : 0;
+	data->rx.outer_vlan_removal_enable_flg =
+		(params->rxq_params.flags & QUEUE_FLG_OV) ? 1 : 0;
+	data->rx.status_block_id = params->rxq_params.fw_sb_id;
+	data->rx.rx_sb_index_number = params->rxq_params.sb_cq_index;
+	data->rx.bd_buff_size = cpu_to_le16(params->rxq_params.buf_sz);
+	data->rx.sge_buff_size = cpu_to_le16(params->rxq_params.sge_buf_sz);
+	data->rx.mtu = cpu_to_le16(params->rxq_params.mtu);
+	data->rx.bd_page_base.lo =
+		cpu_to_le32(U64_LO(params->rxq_params.dscr_map));
+	data->rx.bd_page_base.hi =
+		cpu_to_le32(U64_HI(params->rxq_params.dscr_map));
+	data->rx.sge_page_base.lo =
+		cpu_to_le32(U64_LO(params->rxq_params.sge_map));
+	data->rx.sge_page_base.hi =
+		cpu_to_le32(U64_HI(params->rxq_params.sge_map));
+	data->rx.cqe_page_base.lo =
+		cpu_to_le32(U64_LO(params->rxq_params.rcq_map));
+	data->rx.cqe_page_base.hi =
+		cpu_to_le32(U64_HI(params->rxq_params.rcq_map));
+	data->rx.is_leading_rss =
+		(params->ramrod_params.flags & CLIENT_IS_LEADING_RSS) ? 1 : 0;
+	data->rx.is_approx_mcast = data->rx.is_leading_rss;
+
+	/* Tx data */
+	data->tx.enforce_security_flg = 0; /* VF specific */
+	data->tx.tx_status_block_id = params->txq_params.fw_sb_id;
+	data->tx.tx_sb_index_number = params->txq_params.sb_cq_index;
+	data->tx.mtu = 0; /* VF specific */
+	data->tx.tx_bd_page_base.lo =
+		cpu_to_le32(U64_LO(params->txq_params.dscr_map));
+	data->tx.tx_bd_page_base.hi =
+		cpu_to_le32(U64_HI(params->txq_params.dscr_map));
+
+	/* flow control data */
+	data->fc.cqe_pause_thr_low = cpu_to_le16(params->pause.rcq_th_lo);
+	data->fc.cqe_pause_thr_high = cpu_to_le16(params->pause.rcq_th_hi);
+	data->fc.bd_pause_thr_low = cpu_to_le16(params->pause.bd_th_lo);
+	data->fc.bd_pause_thr_high = cpu_to_le16(params->pause.bd_th_hi);
+	data->fc.sge_pause_thr_low = cpu_to_le16(params->pause.sge_th_lo);
+	data->fc.sge_pause_thr_high = cpu_to_le16(params->pause.sge_th_hi);
+	data->fc.rx_cos_mask = cpu_to_le16(params->pause.pri_map);
+
+	data->fc.safc_group_num = params->txq_params.cos;
+	data->fc.safc_group_en_flg =
+		(params->txq_params.flags & QUEUE_FLG_COS) ? 1 : 0;
+	data->fc.traffic_type = LLFC_TRAFFIC_TYPE_NW;
+}
+
+static inline void bnx2x_set_ctx_validation(struct eth_context *cxt, u32 cid)
+{
+	/* ustorm cxt validation */
+	cxt->ustorm_ag_context.cdu_usage =
+		CDU_RSRVD_VALUE_TYPE_A(cid, CDU_REGION_NUMBER_UCM_AG,
+				       ETH_CONNECTION_TYPE);
+	/* xcontext validation */
+	cxt->xstorm_ag_context.cdu_reserved =
+		CDU_RSRVD_VALUE_TYPE_A(cid, CDU_REGION_NUMBER_XCM_AG,
+				       ETH_CONNECTION_TYPE);
+}
+
+int bnx2x_setup_fw_client(struct bnx2x *bp,
+			  struct bnx2x_client_init_params *params,
+			  u8 activate,
+			  struct client_init_ramrod_data *data,
+			  dma_addr_t data_mapping)
+{
+	u16 hc_usec;
+	int ramrod = RAMROD_CMD_ID_ETH_CLIENT_SETUP;
+	int ramrod_flags = 0, rc;
+
+	/* HC and context validation values */
+	hc_usec = params->txq_params.hc_rate ?
+		1000000 / params->txq_params.hc_rate : 0;
+	bnx2x_update_coalesce_sb_index(bp,
+			params->txq_params.fw_sb_id,
+			params->txq_params.sb_cq_index,
+			!(params->txq_params.flags & QUEUE_FLG_HC),
+			hc_usec);
+
+	*(params->ramrod_params.pstate) = BNX2X_FP_STATE_OPENING;
+
+	hc_usec = params->rxq_params.hc_rate ?
+		1000000 / params->rxq_params.hc_rate : 0;
+	bnx2x_update_coalesce_sb_index(bp,
+			params->rxq_params.fw_sb_id,
+			params->rxq_params.sb_cq_index,
+			!(params->rxq_params.flags & QUEUE_FLG_HC),
+			hc_usec);
+
+	bnx2x_set_ctx_validation(params->rxq_params.cxt,
+				 params->rxq_params.cid);
+
+	/* zero stats */
+	if (params->txq_params.flags & QUEUE_FLG_STATS)
+		storm_memset_xstats_zero(bp, BP_PORT(bp),
+					 params->txq_params.stat_id);
+
+	if (params->rxq_params.flags & QUEUE_FLG_STATS) {
+		storm_memset_ustats_zero(bp, BP_PORT(bp),
+					 params->rxq_params.stat_id);
+		storm_memset_tstats_zero(bp, BP_PORT(bp),
+					 params->rxq_params.stat_id);
+	}
+
+	/* Fill the ramrod data */
+	bnx2x_fill_cl_init_data(bp, params, activate, data);
+
+	/* SETUP ramrod.
+	 *
+	 * bnx2x_sp_post() takes a spin_lock thus no other explict memory
+	 * barrier except from mmiowb() is needed to impose a
+	 * proper ordering of memory operations.
+	 */
+	mmiowb();
 
-	/* reset IGU state */
-	bnx2x_ack_sb(bp, bp->fp[0].sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
-	/* SETUP ramrod */
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_SETUP, 0, 0, 0, 0);
+	bnx2x_sp_post(bp, ramrod, params->ramrod_params.cid,
+		      U64_HI(data_mapping), U64_LO(data_mapping), 0);
 
 	/* Wait for completion */
-	rc = bnx2x_wait_ramrod(bp, BNX2X_STATE_OPEN, 0, &(bp->state), 0);
-
+	rc = bnx2x_wait_ramrod(bp, params->ramrod_params.state,
+				 params->ramrod_params.index,
+				 params->ramrod_params.pstate,
+				 ramrod_flags);
 	return rc;
 }
 
-int bnx2x_setup_multi(struct bnx2x *bp, int index)
-{
-	struct bnx2x_fastpath *fp = &bp->fp[index];
-
-	/* reset IGU state */
-	bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
-
-	/* SETUP ramrod */
-	fp->state = BNX2X_FP_STATE_OPENING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CLIENT_SETUP, index, 0,
-		      fp->cl_id, 0);
-
-	/* Wait for completion */
-	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_OPEN, index,
-				 &(fp->state), 0);
-}
-
-
 void bnx2x_set_num_queues_msix(struct bnx2x *bp)
 {
 
@@ -4996,87 +5625,217 @@ void bnx2x_set_num_queues_msix(struct bnx2x *bp)
 	}
 }
 
+void bnx2x_ilt_set_info(struct bnx2x *bp)
+{
+	struct ilt_client_info *ilt_client;
+	struct bnx2x_ilt *ilt = BP_ILT(bp);
+	u16 line = 0;
+
+	ilt->start_line = FUNC_ILT_BASE(BP_FUNC(bp));
+	DP(BNX2X_MSG_SP, "ilt starts at line %d\n", ilt->start_line);
+
+	/* CDU */
+	ilt_client = &ilt->clients[ILT_CLIENT_CDU];
+	ilt_client->client_num = ILT_CLIENT_CDU;
+	ilt_client->page_size = CDU_ILT_PAGE_SZ;
+	ilt_client->flags = ILT_CLIENT_SKIP_MEM;
+	ilt_client->start = line;
+	line += L2_ILT_LINES(bp);
+#ifdef BCM_CNIC
+	line += CNIC_ILT_LINES;
+#endif
+	ilt_client->end = line - 1;
+
+	DP(BNX2X_MSG_SP, "ilt client[CDU]: start %d, end %d, psz 0x%x, "
+					 "flags 0x%x, hw psz %d\n",
+	   ilt_client->start,
+	   ilt_client->end,
+	   ilt_client->page_size,
+	   ilt_client->flags,
+	   ilog2(ilt_client->page_size >> 12));
+
+	/* QM */
+	if (QM_INIT(bp->qm_cid_count)) {
+		ilt_client = &ilt->clients[ILT_CLIENT_QM];
+		ilt_client->client_num = ILT_CLIENT_QM;
+		ilt_client->page_size = QM_ILT_PAGE_SZ;
+		ilt_client->flags = 0;
+		ilt_client->start = line;
+
+		/* 4 bytes for each cid */
+		line += DIV_ROUND_UP(bp->qm_cid_count * QM_QUEUES_PER_FUNC * 4,
+							 QM_ILT_PAGE_SZ);
+
+		ilt_client->end = line - 1;
+
+		DP(BNX2X_MSG_SP, "ilt client[QM]: start %d, end %d, psz 0x%x, "
+						 "flags 0x%x, hw psz %d\n",
+		   ilt_client->start,
+		   ilt_client->end,
+		   ilt_client->page_size,
+		   ilt_client->flags,
+		   ilog2(ilt_client->page_size >> 12));
+
+	}
+	/* SRC */
+	ilt_client = &ilt->clients[ILT_CLIENT_SRC];
+#ifdef BCM_CNIC
+	ilt_client->client_num = ILT_CLIENT_SRC;
+	ilt_client->page_size = SRC_ILT_PAGE_SZ;
+	ilt_client->flags = 0;
+	ilt_client->start = line;
+	line += SRC_ILT_LINES;
+	ilt_client->end = line - 1;
+
+	DP(BNX2X_MSG_SP, "ilt client[SRC]: start %d, end %d, psz 0x%x, "
+					 "flags 0x%x, hw psz %d\n",
+	   ilt_client->start,
+	   ilt_client->end,
+	   ilt_client->page_size,
+	   ilt_client->flags,
+	   ilog2(ilt_client->page_size >> 12));
+
+#else
+	ilt_client->flags = (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM);
+#endif
 
+	/* TM */
+	ilt_client = &ilt->clients[ILT_CLIENT_TM];
+#ifdef BCM_CNIC
+	ilt_client->client_num = ILT_CLIENT_TM;
+	ilt_client->page_size = TM_ILT_PAGE_SZ;
+	ilt_client->flags = 0;
+	ilt_client->start = line;
+	line += TM_ILT_LINES;
+	ilt_client->end = line - 1;
+
+	DP(BNX2X_MSG_SP, "ilt client[TM]: start %d, end %d, psz 0x%x, "
+					 "flags 0x%x, hw psz %d\n",
+	   ilt_client->start,
+	   ilt_client->end,
+	   ilt_client->page_size,
+	   ilt_client->flags,
+	   ilog2(ilt_client->page_size >> 12));
 
-static int bnx2x_stop_multi(struct bnx2x *bp, int index)
+#else
+	ilt_client->flags = (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM);
+#endif
+}
+int bnx2x_setup_client(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+		       int is_leading)
 {
-	struct bnx2x_fastpath *fp = &bp->fp[index];
+	struct bnx2x_client_init_params params = { {0} };
 	int rc;
 
-	/* halt the connection */
-	fp->state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, fp->cl_id, 0);
+	bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0,
+			     IGU_INT_ENABLE, 0);
 
-	/* Wait for completion */
-	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
-			       &(fp->state), 1);
-	if (rc) /* timeout */
-		return rc;
+	params.ramrod_params.pstate = &fp->state;
+	params.ramrod_params.state = BNX2X_FP_STATE_OPEN;
+	params.ramrod_params.index = fp->index;
+	params.ramrod_params.cid = fp->cid;
 
-	/* delete cfc entry */
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CFC_DEL, index, 0, 0, 1);
+	if (is_leading)
+		params.ramrod_params.flags |= CLIENT_IS_LEADING_RSS;
 
-	/* Wait for completion */
-	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
-			       &(fp->state), 1);
+	bnx2x_pf_rx_cl_prep(bp, fp, &params.pause, &params.rxq_params);
+
+	bnx2x_pf_tx_cl_prep(bp, fp, &params.txq_params);
+
+	rc = bnx2x_setup_fw_client(bp, &params, 1,
+				     bnx2x_sp(bp, client_init_data),
+				     bnx2x_sp_mapping(bp, client_init_data));
 	return rc;
 }
 
-static int bnx2x_stop_leading(struct bnx2x *bp)
+int bnx2x_stop_fw_client(struct bnx2x *bp, struct bnx2x_client_ramrod_params *p)
 {
-	__le16 dsb_sp_prod_idx;
-	/* if the other port is handling traffic,
-	   this can take a lot of time */
-	int cnt = 500;
 	int rc;
 
-	might_sleep();
+	int poll_flag = p->poll ? WAIT_RAMROD_POLL : 0;
 
-	/* Send HALT ramrod */
-	bp->fp[0].state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, bp->fp->cl_id, 0);
+	/* halt the connection */
+	*p->pstate = BNX2X_FP_STATE_HALTING;
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, p->cid, 0,
+						  p->cl_id, 0);
 
 	/* Wait for completion */
-	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
-			       &(bp->fp[0].state), 1);
+	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, p->index,
+			       p->pstate, poll_flag);
 	if (rc) /* timeout */
 		return rc;
 
-	dsb_sp_prod_idx = *bp->dsb_sp_prod;
+	*p->pstate = BNX2X_FP_STATE_TERMINATING;
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_TERMINATE, p->cid, 0,
+						       p->cl_id, 0);
+	/* Wait for completion */
+	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_TERMINATED, p->index,
+			       p->pstate, poll_flag);
+	if (rc) /* timeout */
+		return rc;
 
-	/* Send PORT_DELETE ramrod */
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_DEL, 0, 0, 0, 1);
 
-	/* Wait for completion to arrive on default status block
-	   we are going to reset the chip anyway
-	   so there is not much to do if this times out
-	 */
-	while (dsb_sp_prod_idx == *bp->dsb_sp_prod) {
-		if (!cnt) {
-			DP(NETIF_MSG_IFDOWN, "timeout waiting for port del "
-			   "dsb_sp_prod 0x%x != dsb_sp_prod_idx 0x%x\n",
-			   *bp->dsb_sp_prod, dsb_sp_prod_idx);
-#ifdef BNX2X_STOP_ON_ERROR
-			bnx2x_panic();
-#endif
-			rc = -EBUSY;
-			break;
-		}
-		cnt--;
-		msleep(1);
-		rmb(); /* Refresh the dsb_sp_prod */
-	}
-	bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
-	bp->fp[0].state = BNX2X_FP_STATE_CLOSED;
+	/* delete cfc entry */
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_CFC_DEL, p->cid, 0, 0, 1);
 
+	/* Wait for completion */
+	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, p->index,
+			       p->pstate, WAIT_RAMROD_COMMON);
 	return rc;
 }
 
+static int bnx2x_stop_client(struct bnx2x *bp, int index)
+{
+	struct bnx2x_client_ramrod_params client_stop = {0};
+	struct bnx2x_fastpath *fp = &bp->fp[index];
+
+	client_stop.index = index;
+	client_stop.cid = fp->cid;
+	client_stop.cl_id = fp->cl_id;
+	client_stop.pstate = &(fp->state);
+	client_stop.poll = 0;
+
+	return bnx2x_stop_fw_client(bp, &client_stop);
+}
+
+
 static void bnx2x_reset_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
 	int base, i;
+	int pfunc_offset_fp = offsetof(struct hc_sb_data, p_func) +
+			 offsetof(struct hc_status_block_data_e1x, common);
+	int pfunc_offset_sp = offsetof(struct hc_sp_status_block_data, p_func);
+	int pfid_offset = offsetof(struct pci_entity, pf_id);
+
+	/* Disable the function in the FW */
+	REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNC_EN_OFFSET(func), 0);
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_FUNC_EN_OFFSET(func), 0);
+	REG_WR8(bp, BAR_TSTRORM_INTMEM + TSTORM_FUNC_EN_OFFSET(func), 0);
+	REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_FUNC_EN_OFFSET(func), 0);
+
+	/* FP SBs */
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+		REG_WR8(bp,
+			BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_OFFSET(fp->fw_sb_id)
+			+ pfunc_offset_fp + pfid_offset,
+			HC_FUNCTION_DISABLED);
+	}
+
+	/* SP SB */
+	REG_WR8(bp,
+		BAR_CSTRORM_INTMEM +
+		CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(func) +
+		pfunc_offset_sp + pfid_offset,
+		HC_FUNCTION_DISABLED);
+
+
+	for (i = 0; i < XSTORM_SPQ_DATA_SIZE / 4; i++)
+		REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_DATA_OFFSET(func),
+		       0);
 
 	/* Configure IGU */
 	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
@@ -5099,6 +5858,8 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 	base = FUNC_ILT_BASE(func);
 	for (i = base; i < base + ILT_PER_FUNC; i++)
 		bnx2x_ilt_wr(bp, i, 0);
+
+	bp->dmae_ready = 0;
 }
 
 static void bnx2x_reset_port(struct bnx2x *bp)
@@ -5167,7 +5928,6 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 		cnt = 1000;
 		while (bnx2x_has_tx_work_unload(fp)) {
 
-			bnx2x_tx_int(fp);
 			if (!cnt) {
 				BNX2X_ERR("timeout waiting for queue[%d]\n",
 					  i);
@@ -5186,39 +5946,21 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 	msleep(1);
 
 	if (CHIP_IS_E1(bp)) {
-		struct mac_configuration_cmd *config =
-						bnx2x_sp(bp, mcast_config);
-
-		bnx2x_set_eth_mac_addr_e1(bp, 0);
-
-		for (i = 0; i < config->hdr.length; i++)
-			CAM_INVALIDATE(config->config_table[i]);
-
-		config->hdr.length = i;
-		if (CHIP_REV_IS_SLOW(bp))
-			config->hdr.offset = BNX2X_MAX_EMUL_MULTI*(1 + port);
-		else
-			config->hdr.offset = BNX2X_MAX_MULTICAST*(1 + port);
-		config->hdr.client_id = bp->fp->cl_id;
-		config->hdr.reserved1 = 0;
-
-		bp->set_mac_pending++;
-		smp_wmb();
-
-		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
-			      U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
-			      U64_LO(bnx2x_sp_mapping(bp, mcast_config)), 0);
+		/* invalidate mc list,
+		 * wait and poll (interrupts are off)
+		 */
+		bnx2x_invlidate_e1_mc_list(bp);
+		bnx2x_set_eth_mac(bp, 0);
 
-	} else { /* E1H */
+	} else {
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 
-		bnx2x_set_eth_mac_addr_e1h(bp, 0);
+		bnx2x_set_eth_mac(bp, 0);
 
 		for (i = 0; i < MC_HASH_SIZE; i++)
 			REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
-
-		REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
 	}
+
 #ifdef BCM_CNIC
 	/* Clear iSCSI L2 MAC */
 	mutex_lock(&bp->cnic_mutex);
@@ -5257,21 +5999,27 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 
 	/* Close multi and leading connections
 	   Completions for ramrods are collected in a synchronous way */
-	for_each_nondefault_queue(bp, i)
-		if (bnx2x_stop_multi(bp, i))
+	for_each_queue(bp, i)
+
+		if (bnx2x_stop_client(bp, i))
+#ifdef BNX2X_STOP_ON_ERROR
+			return;
+#else
 			goto unload_error;
+#endif
 
-	rc = bnx2x_stop_leading(bp);
+	rc = bnx2x_func_stop(bp);
 	if (rc) {
-		BNX2X_ERR("Stop leading failed!\n");
+		BNX2X_ERR("Function stop failed!\n");
 #ifdef BNX2X_STOP_ON_ERROR
-		return -EBUSY;
+		return;
 #else
 		goto unload_error;
 #endif
 	}
-
+#ifndef BNX2X_STOP_ON_ERROR
 unload_error:
+#endif
 	if (!BP_NOMCP(bp))
 		reset_code = bnx2x_fw_command(bp, reset_code, 0);
 	else {
@@ -5293,6 +6041,12 @@ unload_error:
 	    (reset_code == FW_MSG_CODE_DRV_UNLOAD_PORT))
 		bnx2x__link_reset(bp);
 
+	/* Disable HW interrupts, NAPI */
+	bnx2x_netif_stop(bp, 1);
+
+	/* Release IRQs */
+	bnx2x_free_irq(bp, false);
+
 	/* Reset the chip */
 	bnx2x_reset_chip(bp, reset_code);
 
@@ -5953,6 +6707,18 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	bp->link_params.chip_id = bp->common.chip_id;
 	BNX2X_DEV_INFO("chip ID is 0x%x\n", id);
 
+	bp->common.chip_port_mode = CHIP_PORT_MODE_NONE; /* N/A */
+
+	/* Set doorbell size */
+	bp->db_size = (1 << BNX2X_DB_SHIFT);
+
+	/*
+	 * set base FW non-default (fast path) status block id, this value is
+	 * used to initialize the fw_sb_id saved on the fp/queue structure to
+	 * determine the id used by the FW.
+	 */
+	bp->base_fw_ndsb = BP_PORT(bp) * FP_SB_MAX_E1x;
+
 	val = (REG_RD(bp, 0x2874) & 0x55);
 	if ((bp->common.chip_id & 0x1) ||
 	    (CHIP_IS_E1(bp) && val) || (CHIP_IS_E1H(bp) && (val == 0x55))) {
@@ -6417,13 +7183,23 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	bnx2x_get_common_hwinfo(bp);
 
+	bp->common.int_block = INT_BLOCK_HC;
+
+	bp->igu_dsb_id = DEF_SB_IGU_ID;
+	bp->igu_base_sb = 0;
+	bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x, bp->l2_cid_count);
+
 	bp->e1hov = 0;
 	bp->e1hmf = 0;
 	if (CHIP_IS_E1H(bp) && !BP_NOMCP(bp)) {
+
+		bp->common.mf_cfg_base = bp->common.shmem_base +
+				offsetof(struct shmem_region, func_mb) +
+				E1H_FUNC_MAX * sizeof(struct drv_func_mb);
 		bp->mf_config =
-			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+			MF_CFG_RD(bp, func_mf_config[func].config);
 
-		val = (SHMEM_RD(bp, mf_cfg.func_mf_config[FUNC_0].e1hov_tag) &
+		val = (MF_CFG_RD(bp, func_mf_config[FUNC_0].e1hov_tag) &
 		       FUNC_MF_CFG_E1HOV_TAG_MASK);
 		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT)
 			bp->e1hmf = 1;
@@ -6431,7 +7207,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 			       IS_E1HMF(bp) ? "multi" : "single");
 
 		if (IS_E1HMF(bp)) {
-			val = (SHMEM_RD(bp, mf_cfg.func_mf_config[func].
+			val = (MF_CFG_RD(bp, func_mf_config[func].
 								e1hov_tag) &
 			       FUNC_MF_CFG_E1HOV_TAG_MASK);
 			if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
@@ -6453,6 +7229,10 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		}
 	}
 
+	/* adjust igu_sb_cnt to MF */
+	if (IS_E1HMF(bp))
+		bp->igu_sb_cnt /= E1HVN_MAX;
+
 	if (!BP_NOMCP(bp)) {
 		bnx2x_get_port_hwinfo(bp);
 
@@ -6462,8 +7242,8 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	}
 
 	if (IS_E1HMF(bp)) {
-		val2 = SHMEM_RD(bp, mf_cfg.func_mf_config[func].mac_upper);
-		val = SHMEM_RD(bp,  mf_cfg.func_mf_config[func].mac_lower);
+		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
+		val = MF_CFG_RD(bp,  func_mf_config[func].mac_lower);
 		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
 		    (val != FUNC_MF_CFG_LOWERMAC_DEFAULT)) {
 			bp->dev->dev_addr[0] = (u8)(val2 >> 8 & 0xff);
@@ -6577,6 +7357,9 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	rc = bnx2x_get_hwinfo(bp);
 
+	if (!rc)
+		rc = bnx2x_alloc_mem_bp(bp);
+
 	bnx2x_read_fwinfo(bp);
 	/* need to reset chip if undi was active */
 	if (!BP_NOMCP(bp))
@@ -6623,8 +7406,8 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->rx_csum = 1;
 
 	/* make sure that the numbers are in the right granularity */
-	bp->tx_ticks = (50 / (4 * BNX2X_BTR)) * (4 * BNX2X_BTR);
-	bp->rx_ticks = (25 / (4 * BNX2X_BTR)) * (4 * BNX2X_BTR);
+	bp->tx_ticks = (50 / BNX2X_BTR) * BNX2X_BTR;
+	bp->rx_ticks = (25 / BNX2X_BTR) * BNX2X_BTR;
 
 	timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
 	bp->current_interval = (poll ? poll : timer_interval);
@@ -6724,73 +7507,16 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 
 	else { /* some multicasts */
 		if (CHIP_IS_E1(bp)) {
-			int i, old, offset;
-			struct netdev_hw_addr *ha;
-			struct mac_configuration_cmd *config =
-						bnx2x_sp(bp, mcast_config);
-
-			i = 0;
-			netdev_for_each_mc_addr(ha, dev) {
-				config->config_table[i].
-					cam_entry.msb_mac_addr =
-					swab16(*(u16 *)&ha->addr[0]);
-				config->config_table[i].
-					cam_entry.middle_mac_addr =
-					swab16(*(u16 *)&ha->addr[2]);
-				config->config_table[i].
-					cam_entry.lsb_mac_addr =
-					swab16(*(u16 *)&ha->addr[4]);
-				config->config_table[i].cam_entry.flags =
-							cpu_to_le16(port);
-				config->config_table[i].
-					target_table_entry.flags = 0;
-				config->config_table[i].target_table_entry.
-					clients_bit_vector =
-						cpu_to_le32(1 << BP_L_ID(bp));
-				config->config_table[i].
-					target_table_entry.vlan_id = 0;
-
-				DP(NETIF_MSG_IFUP,
-				   "setting MCAST[%d] (%04x:%04x:%04x)\n", i,
-				   config->config_table[i].
-						cam_entry.msb_mac_addr,
-				   config->config_table[i].
-						cam_entry.middle_mac_addr,
-				   config->config_table[i].
-						cam_entry.lsb_mac_addr);
-				i++;
-			}
-			old = config->hdr.length;
-			if (old > i) {
-				for (; i < old; i++) {
-					if (CAM_IS_INVALID(config->
-							   config_table[i])) {
-						/* already invalidated */
-						break;
-					}
-					/* invalidate */
-					CAM_INVALIDATE(config->
-						       config_table[i]);
-				}
-			}
-
-			if (CHIP_REV_IS_SLOW(bp))
-				offset = BNX2X_MAX_EMUL_MULTI*(1 + port);
-			else
-				offset = BNX2X_MAX_MULTICAST*(1 + port);
-
-			config->hdr.length = i;
-			config->hdr.offset = offset;
-			config->hdr.client_id = bp->fp->cl_id;
-			config->hdr.reserved1 = 0;
-
-			bp->set_mac_pending++;
-			smp_wmb();
+			/*
+			 * set mc list, do not wait as wait implies sleep
+			 * and set_rx_mode can be invoked from non-sleepable
+			 * context
+			 */
+			u8 offset = (CHIP_REV_IS_SLOW(bp) ?
+				     BNX2X_MAX_EMUL_MULTI*(1 + port) :
+				     BNX2X_MAX_MULTICAST*(1 + port));
 
-			bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
-				   U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
-				   U64_LO(bnx2x_sp_mapping(bp, mcast_config)),
-				      0);
+			bnx2x_set_e1_mc_list(bp, offset);
 		} else { /* E1H */
 			/* Accept one or more multicasts */
 			struct netdev_hw_addr *ha;
@@ -6802,9 +7528,10 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 
 			netdev_for_each_mc_addr(ha, dev) {
 				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
-				   ha->addr);
+				   bnx2x_mc_addr(ha));
 
-				crc = crc32c_le(0, ha->addr, ETH_ALEN);
+				crc = crc32c_le(0, bnx2x_mc_addr(ha),
+						ETH_ALEN);
 				bit = (crc >> 24) & 0xff;
 				regidx = bit >> 5;
 				bit &= 0x1f;
@@ -6817,6 +7544,7 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 		}
 	}
 
+
 	bp->rx_mode = rx_mode;
 	bnx2x_set_storm_rx_mode(bp);
 }
@@ -7003,7 +7731,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	}
 
 	bp->doorbells = ioremap_nocache(pci_resource_start(pdev, 2),
-					min_t(u64, BNX2X_DB_SIZE,
+					min_t(u64, BNX2X_DB_SIZE(bp),
 					      pci_resource_len(pdev, 2)));
 	if (!bp->doorbells) {
 		dev_err(&bp->pdev->dev,
@@ -7179,6 +7907,30 @@ static inline void bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 n)
 	}
 }
 
+/**
+ * IRO array is stored in the following format:
+ * {base(24bit), m1(16bit), m2(16bit), m3(16bit), size(16bit) }
+ */
+static inline void bnx2x_prep_iro(const u8 *_source, u8 *_target, u32 n)
+{
+	const __be32 *source = (const __be32 *)_source;
+	struct iro *target = (struct iro *)_target;
+	u32 i, j, tmp;
+
+	for (i = 0, j = 0; i < n/sizeof(struct iro); i++) {
+		target[i].base = be32_to_cpu(source[j]);
+		j++;
+		tmp = be32_to_cpu(source[j]);
+		target[i].m1 = (tmp >> 16) & 0xffff;
+		target[i].m2 = tmp & 0xffff;
+		j++;
+		tmp = be32_to_cpu(source[j]);
+		target[i].m3 = (tmp >> 16) & 0xffff;
+		target[i].size = tmp & 0xffff;
+		j++;
+	}
+}
+
 static inline void be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 {
 	const __be16 *source = (const __be16 *)_source;
@@ -7260,9 +8012,13 @@ int bnx2x_init_firmware(struct bnx2x *bp)
 			be32_to_cpu(fw_hdr->csem_int_table_data.offset);
 	INIT_CSEM_PRAM_DATA(bp)      = bp->firmware->data +
 			be32_to_cpu(fw_hdr->csem_pram_data.offset);
+	/* IRO */
+	BNX2X_ALLOC_AND_SET(iro_arr, iro_alloc_err, bnx2x_prep_iro);
 
 	return 0;
 
+iro_alloc_err:
+	kfree(bp->init_ops_offsets);
 init_offsets_alloc_err:
 	kfree(bp->init_ops);
 init_ops_alloc_err:
@@ -7273,17 +8029,27 @@ request_firmware_exit:
 	return rc;
 }
 
+static inline int bnx2x_set_qm_cid_count(struct bnx2x *bp, int l2_cid_count)
+{
+	int cid_count = L2_FP_COUNT(l2_cid_count);
 
+#ifdef BCM_CNIC
+	cid_count += CNIC_CID_MAX;
+#endif
+	return roundup(cid_count, QM_CID_ROUND);
+}
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
 	int pcie_width, pcie_speed;
-	int rc;
+	int rc, cid_count;
+
+	cid_count = FP_SB_MAX_E1x + CNIC_CONTEXT_USE;
 
 	/* dev zeroed in init_etherdev */
-	dev = alloc_etherdev_mq(sizeof(*bp), MAX_CONTEXT);
+	dev = alloc_etherdev_mq(sizeof(*bp), cid_count);
 	if (!dev) {
 		dev_err(&pdev->dev, "Cannot allocate net device\n");
 		return -ENOMEM;
@@ -7294,6 +8060,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, dev);
 
+	bp->l2_cid_count = cid_count;
+
 	rc = bnx2x_init_dev(pdev, dev);
 	if (rc < 0) {
 		free_netdev(dev);
@@ -7304,6 +8072,9 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	if (rc)
 		goto init_one_exit;
 
+	/* calc qm_cid_count */
+	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp, cid_count);
+
 	rc = register_netdev(dev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
@@ -7360,6 +8131,8 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	if (bp->doorbells)
 		iounmap(bp->doorbells);
 
+	bnx2x_free_mem_bp(bp);
+
 	free_netdev(dev);
 
 	if (atomic_read(&pdev->enable_cnt) == 1)
@@ -7387,16 +8160,9 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	/* Release IRQs */
 	bnx2x_free_irq(bp, false);
 
-	if (CHIP_IS_E1(bp)) {
-		struct mac_configuration_cmd *config =
-						bnx2x_sp(bp, mcast_config);
-
-		for (i = 0; i < config->hdr.length; i++)
-			CAM_INVALIDATE(config->config_table[i]);
-	}
-
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
+
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 	for_each_queue(bp, i)
@@ -7641,8 +8407,8 @@ static int bnx2x_cnic_sp_queue(struct net_device *dev,
 
 		DP(NETIF_MSG_TIMER, "L5 SPQE %x %x %x:%x pos %d\n",
 		   spe->hdr.conn_and_cmd_data, spe->hdr.type,
-		   spe->data.mac_config_addr.hi,
-		   spe->data.mac_config_addr.lo,
+		   spe->data.update_data_addr.hi,
+		   spe->data.update_data_addr.lo,
 		   bp->cnic_kwq_pending);
 
 		if (bp->cnic_kwq_prod == bp->cnic_kwq_last)
@@ -7736,8 +8502,24 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 	case DRV_CTL_START_L2_CMD: {
 		u32 cli = ctl->data.ring.client_id;
 
-		bp->rx_mode_cl_mask |= (1 << cli);
-		bnx2x_set_storm_rx_mode(bp);
+		/* Set iSCSI MAC address */
+		bnx2x_set_iscsi_eth_mac_addr(bp, 1);
+
+		mmiowb();
+		barrier();
+
+		/* Start accepting on iSCSI L2 ring. Accept all multicasts
+		 * because it's the only way for UIO Client to accept
+		 * multicasts (in non-promiscuous mode only one Client per
+		 * function will receive multicast packets (leading in our
+		 * case).
+		 */
+		bnx2x_rxq_set_mac_filters(bp, cli,
+			BNX2X_ACCEPT_UNICAST |
+			BNX2X_ACCEPT_BROADCAST |
+			BNX2X_ACCEPT_ALL_MULTICAST);
+		storm_memset_mac_filters(bp, &bp->mac_filters, BP_FUNC(bp));
+
 		break;
 	}
 
@@ -7745,8 +8527,15 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 	case DRV_CTL_STOP_L2_CMD: {
 		u32 cli = ctl->data.ring.client_id;
 
-		bp->rx_mode_cl_mask &= ~(1 << cli);
-		bnx2x_set_storm_rx_mode(bp);
+		/* Stop accepting on iSCSI L2 ring */
+		bnx2x_rxq_set_mac_filters(bp, cli, BNX2X_ACCEPT_NONE);
+		storm_memset_mac_filters(bp, &bp->mac_filters, BP_FUNC(bp));
+
+		mmiowb();
+		barrier();
+
+		/* Unset iSCSI L2 MAC */
+		bnx2x_set_iscsi_eth_mac_addr(bp, 0);
 		break;
 	}
 
@@ -7770,10 +8559,12 @@ void bnx2x_setup_cnic_irq_info(struct bnx2x *bp)
 		cp->drv_state &= ~CNIC_DRV_STATE_USING_MSIX;
 		cp->irq_arr[0].irq_flags &= ~CNIC_IRQ_FL_MSIX;
 	}
-	cp->irq_arr[0].status_blk = bp->cnic_sb;
+	cp->irq_arr[0].status_blk = (void *)bp->cnic_sb.e1x_sb;
 	cp->irq_arr[0].status_blk_num = CNIC_SB_ID(bp);
+	cp->irq_arr[0].status_blk_num2 = CNIC_IGU_SB_ID(bp);
 	cp->irq_arr[1].status_blk = bp->def_status_blk;
 	cp->irq_arr[1].status_blk_num = DEF_SB_ID;
+	cp->irq_arr[1].status_blk_num2 = DEF_SB_IGU_ID;
 
 	cp->num_irq = 2;
 }
@@ -7805,8 +8596,11 @@ static int bnx2x_register_cnic(struct net_device *dev, struct cnic_ops *ops,
 
 	cp->num_irq = 0;
 	cp->drv_state = CNIC_DRV_STATE_REGD;
+	cp->iro_arr = bp->iro_arr;
 
-	bnx2x_init_sb(bp, bp->cnic_sb, bp->cnic_sb_mapping, CNIC_SB_ID(bp));
+	bnx2x_init_sb(bp, bp->cnic_sb_mapping,
+		      BNX2X_VF_ID_INVALID, false,
+		      CNIC_SB_ID(bp), CNIC_IGU_SB_ID(bp));
 
 	bnx2x_setup_cnic_irq_info(bp);
 	bnx2x_set_iscsi_eth_mac_addr(bp, 1);
@@ -7847,7 +8641,7 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	cp->io_base = bp->regview;
 	cp->io_base2 = bp->doorbells;
 	cp->max_kwqe_pending = 8;
-	cp->ctx_blk_size = CNIC_CTX_PER_ILT * sizeof(union cdu_context);
+	cp->ctx_blk_size = CDU_ILT_PAGE_SZ;
 	cp->ctx_tbl_offset = FUNC_ILT_BASE(BP_FUNC(bp)) + 1;
 	cp->ctx_tbl_len = CNIC_ILT_LINES;
 	cp->starting_cid = BCM_CNIC_CID_START;
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index efa1403..1256f62 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -153,7 +153,7 @@ static inline long bnx2x_hilo(u32 *hiref)
 static void bnx2x_storm_stats_post(struct bnx2x *bp)
 {
 	if (!bp->stats_pending) {
-		struct eth_query_ramrod_data ramrod_data = {0};
+		struct common_query_ramrod_data ramrod_data = {0};
 		int i, rc;
 
 		spin_lock_bh(&bp->stats_lock);
@@ -163,9 +163,9 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 		for_each_queue(bp, i)
 			ramrod_data.ctr_id_vector |= (1 << bp->fp[i].cl_id);
 
-		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_STAT_QUERY, 0,
+		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STAT_QUERY, 0,
 				   ((u32 *)&ramrod_data)[1],
-				   ((u32 *)&ramrod_data)[0], 0);
+				   ((u32 *)&ramrod_data)[0], 1);
 		if (rc == 0) {
 			/* stats ramrod has it's own slot on the spq */
 			bp->spq_left++;
@@ -398,9 +398,9 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 				     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
 		dmae->src_addr_hi = 0;
 		dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
-				offsetof(struct bmac_stats, rx_stat_gr64_lo));
+				offsetof(struct bmac1_stats, rx_stat_gr64_lo));
 		dmae->dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
-				offsetof(struct bmac_stats, rx_stat_gr64_lo));
+				offsetof(struct bmac1_stats, rx_stat_gr64_lo));
 		dmae->len = (8 + BIGMAC_REGISTER_RX_STAT_GRIPJ -
 			     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
 		dmae->comp_addr_lo = dmae_reg_go_c[loader_idx] >> 2;
@@ -571,7 +571,7 @@ static void bnx2x_stats_restart(struct bnx2x *bp)
 
 static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 {
-	struct bmac_stats *new = bnx2x_sp(bp, mac_stats.bmac_stats);
+	struct bmac1_stats *new = bnx2x_sp(bp, mac_stats.bmac1_stats);
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct {
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4e9d4ae..8025981 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -942,7 +942,7 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
 		uinfo->mem[1].addr = (unsigned long) cp->bnx2x_def_status_blk &
 			PAGE_MASK;
-		uinfo->mem[1].size = sizeof(struct host_def_status_block);
+		uinfo->mem[1].size = sizeof(*cp->bnx2x_def_status_blk);
 
 		uinfo->name = "bnx2x_cnic";
 	}
@@ -1063,6 +1063,8 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	int i, j, n, ret, pages;
 	struct cnic_dma *kwq_16_dma = &cp->kwq_16_data_info;
 
+	cp->iro_arr = ethdev->iro_arr;
+
 	cp->max_cid_space = MAX_ISCSI_TBL_SZ;
 	cp->iscsi_start_cid = start_cid;
 	if (start_cid < BNX2X_ISCSI_START_CID) {
@@ -1127,8 +1129,6 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 
 	cp->bnx2x_def_status_blk = cp->ethdev->irq_arr[1].status_blk;
 
-	memset(cp->status_blk.bnx2x, 0, sizeof(*cp->status_blk.bnx2x));
-
 	cp->l2_rx_ring_size = 15;
 
 	ret = cnic_alloc_l2_rings(dev, 4);
@@ -1211,7 +1211,7 @@ static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
 		cpu_to_le32(((cmd << SPE_HDR_CMD_ID_SHIFT) |
 			     BNX2X_HW_CID(cp, cid)));
 	kwqe.hdr.type = cpu_to_le16(type);
-	kwqe.hdr.reserved = 0;
+	kwqe.hdr.reserved1 = 0;
 	kwqe.data.phy_address.lo = cpu_to_le32(l5_data->phy_address.lo);
 	kwqe.data.phy_address.hi = cpu_to_le32(l5_data->phy_address.hi);
 
@@ -1527,8 +1527,10 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	ictx->tstorm_st_context.tcp.cwnd = 0x5A8;
 	ictx->tstorm_st_context.tcp.flags2 |=
 		TSTORM_TCP_ST_CONTEXT_SECTION_DA_EN;
+	ictx->tstorm_st_context.tcp.ooo_support_mode =
+		TCP_TSTORM_OOO_DROP_AND_PROC_ACK;
 
-	ictx->timers_context.flags |= ISCSI_TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG;
+	ictx->timers_context.flags |= TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG;
 
 	ictx->ustorm_st_context.ring.rq.pbl_base.lo =
 		req2->rq_page_table_addr_lo;
@@ -1717,6 +1719,7 @@ static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	int ret = 0;
 	struct iscsi_kcqe kcqe;
 	struct kcqe *cqes[1];
+	u32 hw_cid, type;
 
 	if (!(ctx->ctx_flags & CTX_FL_OFFLD_START))
 		goto skip_cfc_delete;
@@ -1727,11 +1730,15 @@ static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	init_waitqueue_head(&ctx->waitq);
 	ctx->wait_cond = 0;
 	memset(&l5_data, 0, sizeof(l5_data));
-	ret = cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CFC_DEL,
-				  req->context_id,
-				  ETH_CONNECTION_TYPE |
-				  (1 << SPE_HDR_COMMON_RAMROD_SHIFT),
-				  &l5_data);
+	hw_cid = BNX2X_HW_CID(cp, ctx->cid);
+	type = (NONE_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
+		& SPE_HDR_CONN_TYPE;
+	type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
+		 SPE_HDR_FUNCTION_ID);
+
+	ret = cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_COMMON_CFC_DEL,
+				  hw_cid, type, &l5_data);
+
 	if (ret == 0)
 		wait_event(ctx->waitq, ctx->wait_cond);
 
@@ -2322,7 +2329,7 @@ static void cnic_ack_bnx2x_msix(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 
-	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID, 0,
+	cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, CSTORM_ID, 0,
 			   IGU_INT_DISABLE, 0);
 }
 
@@ -2357,7 +2364,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 	status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq1);
 
 	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
-	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID,
+	cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
 			   status_idx, IGU_INT_ENABLE, 1);
 }
 
@@ -3285,6 +3292,7 @@ static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	u32 pfid = cp->pfid;
+	u32 port = CNIC_PORT(cp);
 
 	cnic_init_bnx2x_mac(dev);
 	cnic_bnx2x_set_tcp_timestamp(dev, 1);
@@ -3293,9 +3301,9 @@ static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(pfid), 0);
 
 	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
-		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(pfid), 1);
+		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(port), 1);
 	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
-		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(pfid),
+		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(port),
 		DEF_MAX_DA_COUNT);
 
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
@@ -3859,32 +3867,48 @@ static int cnic_init_bnx2x_irq(struct cnic_dev *dev)
 	return err;
 }
 
+static inline void cnic_storm_memset_hc_disable(struct cnic_dev *dev,
+						u16 sb_id, u8 sb_index,
+						u8 disable)
+{
+
+	u32 addr = BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_OFFSET(sb_id) +
+			offsetof(struct hc_status_block_data_e1x, index_data) +
+			sizeof(struct hc_index_data)*sb_index +
+			offsetof(struct hc_index_data, flags);
+	u16 flags = CNIC_RD16(dev, addr);
+	/* clear and set */
+	flags &= ~HC_INDEX_DATA_HC_ENABLED;
+	flags |= (((~disable) << HC_INDEX_DATA_HC_ENABLED_SHIFT) &
+		  HC_INDEX_DATA_HC_ENABLED);
+	CNIC_WR16(dev, addr, flags);
+}
+
 static void cnic_enable_bnx2x_int(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	u8 sb_id = cp->status_blk_num;
-	int port = CNIC_PORT(cp);
 
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
-		 CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, sb_id,
-					       HC_INDEX_C_ISCSI_EQ_CONS),
-		 64 / 12);
-	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
-		  CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id,
-						HC_INDEX_C_ISCSI_EQ_CONS), 0);
+			CSTORM_STATUS_BLOCK_DATA_OFFSET(sb_id) +
+			offsetof(struct hc_status_block_data_e1x, index_data) +
+			sizeof(struct hc_index_data)*HC_INDEX_ISCSI_EQ_CONS +
+			offsetof(struct hc_index_data, timeout), 64 / 12);
+	cnic_storm_memset_hc_disable(dev, sb_id, HC_INDEX_ISCSI_EQ_CONS, 0);
 }
 
 static void cnic_disable_bnx2x_int_sync(struct cnic_dev *dev)
 {
 }
 
-static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
+static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
+				    struct client_init_ramrod_data *data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	union eth_tx_bd_types *txbd = (union eth_tx_bd_types *) cp->l2_ring;
-	struct eth_context *context;
-	struct regpair context_addr;
-	dma_addr_t buf_map;
+	dma_addr_t buf_map, ring_map = cp->l2_ring_map;
+	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int port = CNIC_PORT(cp);
 	int i;
 	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
@@ -3909,33 +3933,23 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
 		start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
 
 	}
-	context = cnic_get_bnx2x_ctx(dev, BNX2X_ISCSI_L2_CID, 1, &context_addr);
 
-	val = (u64) cp->l2_ring_map >> 32;
+	val = (u64) ring_map >> 32;
 	txbd->next_bd.addr_hi = cpu_to_le32(val);
 
-	context->xstorm_st_context.tx_bd_page_base_hi = val;
+	data->tx.tx_bd_page_base.hi = cpu_to_le32(val);
 
-	val = (u64) cp->l2_ring_map & 0xffffffff;
+	val = (u64) ring_map & 0xffffffff;
 	txbd->next_bd.addr_lo = cpu_to_le32(val);
 
-	context->xstorm_st_context.tx_bd_page_base_lo = val;
-
-	context->cstorm_st_context.sb_index_number =
-		HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS;
-	context->cstorm_st_context.status_block_id = BNX2X_DEF_SB_ID;
-
-	if (cli < MAX_X_STAT_COUNTER_ID)
-		context->xstorm_st_context.statistics_data = cli |
-				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE;
+	data->tx.tx_bd_page_base.lo = cpu_to_le32(val);
 
-	context->xstorm_ag_context.cdu_reserved =
-		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(cp, BNX2X_ISCSI_L2_CID),
-					CDU_REGION_NUMBER_XCM_AG,
-					ETH_CONNECTION_TYPE);
+	/* Other ramrod params */
+	data->tx.tx_sb_index_number = HC_SP_INDEX_ETH_ISCSI_CQ_CONS;
+	data->tx.tx_status_block_id = BNX2X_DEF_SB_ID;
 
 	/* reset xstorm per client statistics */
-	if (cli < MAX_X_STAT_COUNTER_ID) {
+	if (cli < MAX_STAT_COUNTER_ID) {
 		val = BAR_XSTRORM_INTMEM +
 		      XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
 		for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++)
@@ -3943,24 +3957,31 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
 	}
 
 	cp->tx_cons_ptr =
-		&cp->bnx2x_def_status_blk->c_def_status_block.index_values[
-			HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS];
+		&sb->sp_sb.index_values[HC_SP_INDEX_ETH_ISCSI_CQ_CONS];
 }
 
-static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
+static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
+				    struct client_init_ramrod_data *data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct eth_rx_bd *rxbd = (struct eth_rx_bd *) (cp->l2_ring +
 				BCM_PAGE_SIZE);
 	struct eth_rx_cqe_next_page *rxcqe = (struct eth_rx_cqe_next_page *)
 				(cp->l2_ring + (2 * BCM_PAGE_SIZE));
-	struct eth_context *context;
-	struct regpair context_addr;
+	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int i;
 	int port = CNIC_PORT(cp);
 	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+	int cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
 	u32 val;
-	struct tstorm_eth_client_config tstorm_client = {0};
+	dma_addr_t ring_map = cp->l2_ring_map;
+
+	/* General data */
+	data->general.client_id = cli;
+	data->general.statistics_en_flg = 1;
+	data->general.statistics_counter_id = cli;
+	data->general.activate_flg = 1;
+	data->general.sp_client_id = cli;
 
 	for (i = 0; i < BNX2X_MAX_RX_DESC_CNT; i++, rxbd++) {
 		dma_addr_t buf_map;
@@ -3970,83 +3991,42 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 		rxbd->addr_hi = cpu_to_le32((u64) buf_map >> 32);
 		rxbd->addr_lo = cpu_to_le32(buf_map & 0xffffffff);
 	}
-	context = cnic_get_bnx2x_ctx(dev, BNX2X_ISCSI_L2_CID, 0, &context_addr);
 
-	val = (u64) (cp->l2_ring_map + BCM_PAGE_SIZE) >> 32;
+	val = (u64) (ring_map + BCM_PAGE_SIZE) >> 32;
 	rxbd->addr_hi = cpu_to_le32(val);
+	data->rx.bd_page_base.hi = cpu_to_le32(val);
 
-	context->ustorm_st_context.common.bd_page_base_hi = val;
-
-	val = (u64) (cp->l2_ring_map + BCM_PAGE_SIZE) & 0xffffffff;
+	val = (u64) (ring_map + BCM_PAGE_SIZE) & 0xffffffff;
 	rxbd->addr_lo = cpu_to_le32(val);
-
-	context->ustorm_st_context.common.bd_page_base_lo = val;
-
-	context->ustorm_st_context.common.sb_index_numbers =
-						BNX2X_ISCSI_RX_SB_INDEX_NUM;
-	context->ustorm_st_context.common.clientId = cli;
-	context->ustorm_st_context.common.status_block_id = BNX2X_DEF_SB_ID;
-	if (cli < MAX_U_STAT_COUNTER_ID) {
-		context->ustorm_st_context.common.flags =
-			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS;
-		context->ustorm_st_context.common.statistics_counter_id = cli;
-	}
-	context->ustorm_st_context.common.mc_alignment_log_size = 0;
-	context->ustorm_st_context.common.bd_buff_size =
-						cp->l2_single_buf_size;
-
-	context->ustorm_ag_context.cdu_usage =
-		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(cp, BNX2X_ISCSI_L2_CID),
-					CDU_REGION_NUMBER_UCM_AG,
-					ETH_CONNECTION_TYPE);
+	data->rx.bd_page_base.lo = cpu_to_le32(val);
 
 	rxcqe += BNX2X_MAX_RCQ_DESC_CNT;
-	val = (u64) (cp->l2_ring_map + (2 * BCM_PAGE_SIZE)) >> 32;
+	val = (u64) (ring_map + (2 * BCM_PAGE_SIZE)) >> 32;
 	rxcqe->addr_hi = cpu_to_le32(val);
+	data->rx.cqe_page_base.hi = cpu_to_le32(val);
 
-	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_CQE_PAGE_BASE_OFFSET(port, cli) + 4, val);
-
-	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_CQE_PAGE_NEXT_OFFSET(port, cli) + 4, val);
-
-	val = (u64) (cp->l2_ring_map + (2 * BCM_PAGE_SIZE)) & 0xffffffff;
+	val = (u64) (ring_map + (2 * BCM_PAGE_SIZE)) & 0xffffffff;
 	rxcqe->addr_lo = cpu_to_le32(val);
+	data->rx.cqe_page_base.lo = cpu_to_le32(val);
 
-	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_CQE_PAGE_BASE_OFFSET(port, cli), val);
-
-	CNIC_WR(dev, BAR_USTRORM_INTMEM +
-		USTORM_CQE_PAGE_NEXT_OFFSET(port, cli), val);
-
-	/* client tstorm info */
-	tstorm_client.mtu = cp->l2_single_buf_size - 14;
-	tstorm_client.config_flags = TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE;
-
-	if (cli < MAX_T_STAT_COUNTER_ID) {
-		tstorm_client.config_flags |=
-				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
-		tstorm_client.statistics_counter_id = cli;
-	}
+	/* Other ramrod params */
+	data->rx.client_qzone_id = cl_qzone_id;
+	data->rx.rx_sb_index_number = HC_SP_INDEX_ETH_ISCSI_RX_CQ_CONS;
+	data->rx.status_block_id = BNX2X_DEF_SB_ID;
 
-	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
-		   TSTORM_CLIENT_CONFIG_OFFSET(port, cli),
-		   ((u32 *)&tstorm_client)[0]);
-	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
-		   TSTORM_CLIENT_CONFIG_OFFSET(port, cli) + 4,
-		   ((u32 *)&tstorm_client)[1]);
+	data->rx.cache_line_alignment_log_size = L1_CACHE_SHIFT;
+	data->rx.bd_buff_size =	cpu_to_le16(cp->l2_single_buf_size);
 
-	/* reset tstorm per client statistics */
-	if (cli < MAX_T_STAT_COUNTER_ID) {
+	data->rx.mtu = cpu_to_le16(cp->l2_single_buf_size - 14);
+	data->rx.outer_vlan_removal_enable_flg = 1;
 
+	/* reset tstorm and ustorm per client statistics */
+	if (cli < MAX_STAT_COUNTER_ID) {
 		val = BAR_TSTRORM_INTMEM +
 		      TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
 		for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++)
 			CNIC_WR(dev, val + i * 4, 0);
-	}
 
-	/* reset ustorm per client statistics */
-	if (cli < MAX_U_STAT_COUNTER_ID) {
 		val = BAR_USTRORM_INTMEM +
 		      USTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
 		for (i = 0; i < sizeof(struct ustorm_per_client_stats) / 4; i++)
@@ -4054,8 +4034,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
 	}
 
 	cp->rx_cons_ptr =
-		&cp->bnx2x_def_status_blk->u_def_status_block.index_values[
-			HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS];
+		&sb->sp_sb.index_values[HC_SP_INDEX_ETH_ISCSI_RX_CQ_CONS];
 }
 
 static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
@@ -4066,7 +4045,7 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 
 	dev->max_iscsi_conn = 0;
 	base = CNIC_RD(dev, MISC_REG_SHARED_MEM_ADDR);
-	if (base < 0xa0000 || base >= 0xc0000)
+	if (base == 0)
 		return;
 
 	addr = BNX2X_SHMEM_ADDR(base,
@@ -4103,14 +4082,19 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 	}
 	if (BNX2X_CHIP_IS_E1H(cp->chip_id)) {
 		int func = CNIC_FUNC(cp);
+		u32 mf_cfg_addr;
+
+		mf_cfg_addr = base + BNX2X_SHMEM_MF_BLK_OFFSET;
+
+		addr = mf_cfg_addr +
+			offsetof(struct mf_cfg, func_mf_config[func].e1hov_tag);
 
-		addr = BNX2X_SHMEM_ADDR(base,
-				mf_cfg.func_mf_config[func].e1hov_tag);
 		val = CNIC_RD(dev, addr);
 		val &= FUNC_MF_CFG_E1HOV_TAG_MASK;
 		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
-			addr = BNX2X_SHMEM_ADDR(base,
-				mf_cfg.func_mf_config[func].config);
+			addr = mf_cfg_addr +
+				offsetof(struct mf_cfg,
+					 func_mf_config[func].config);
 			val = CNIC_RD(dev, addr);
 			val &= FUNC_MF_CFG_PROTOCOL_MASK;
 			if (val != FUNC_MF_CFG_PROTOCOL_ISCSI)
@@ -4122,11 +4106,10 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
 	int func = CNIC_FUNC(cp), ret, i;
-	int port = CNIC_PORT(cp);
 	u32 pfid;
-	u16 eq_idx;
-	u8 sb_id = cp->status_blk_num;
+	struct host_hc_status_block_e1x *sb = cp->status_blk.gen;
 
 	cp->pfid = func;
 	pfid = cp->pfid;
@@ -4137,15 +4120,16 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (ret)
 		return -ENOMEM;
 
+	cp->bnx2x_igu_sb_id = ethdev->irq_arr[0].status_blk_num2;
+
 	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
 			  CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
 	cp->kcq1.sw_prod_idx = 0;
 
 	cp->kcq1.hw_prod_idx_ptr =
-		&cp->status_blk.bnx2x->c_status_block.index_values[
-			HC_INDEX_C_ISCSI_EQ_CONS];
+		&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
 	cp->kcq1.status_idx_ptr =
-		&cp->status_blk.bnx2x->c_status_block.status_block_index;
+		&sb->sb.running_index[SM_RX_ID];
 
 	cnic_get_bnx2x_iscsi_info(dev);
 
@@ -4171,7 +4155,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 		CSTORM_ISCSI_EQ_SB_NUM_OFFSET(pfid, 0), cp->status_blk_num);
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(pfid, 0),
-		HC_INDEX_C_ISCSI_EQ_CONS);
+		HC_INDEX_ISCSI_EQ_CONS);
 
 	for (i = 0; i < cp->conn_buf_info.num_pages; i++) {
 		CNIC_WR(dev, BAR_TSTRORM_INTMEM +
@@ -4189,16 +4173,11 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(pfid) + 4,
 		(u64) cp->gbl_buf_info.pg_map_arr[0] >> 32);
 
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+		TSTORM_ISCSI_TCP_LOCAL_ADV_WND_OFFSET(pfid), DEF_RCV_BUF);
+
 	cnic_setup_bnx2x_context(dev);
 
-	eq_idx = CNIC_RD16(dev, BAR_CSTRORM_INTMEM +
-			   CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id) +
-			   offsetof(struct cstorm_status_block_c,
-				    index_values[HC_INDEX_C_ISCSI_EQ_CONS]));
-	if (eq_idx != 0) {
-		netdev_err(dev->netdev, "EQ cons index %x != 0\n", eq_idx);
-		return -EBUSY;
-	}
 	ret = cnic_init_bnx2x_irq(dev);
 	if (ret)
 		return ret;
@@ -4218,8 +4197,9 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		cnic_init_bnx2_rx_ring(dev);
 		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
-		struct cnic_local *cp = dev->cnic_priv;
 		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+		u32 cl_qzone_id, type;
+		struct client_init_ramrod_data *data;
 		union l5cm_specific_data l5_data;
 		struct ustorm_eth_rx_producers rx_prods = {0};
 		u32 off, i;
@@ -4228,23 +4208,36 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		rx_prods.cqe_prod = BNX2X_MAX_RCQ_DESC_CNT;
 		barrier();
 
+		cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
+
 		off = BAR_USTRORM_INTMEM +
-			USTORM_RX_PRODS_OFFSET(CNIC_PORT(cp), cli);
+			 USTORM_RX_PRODS_E1X_OFFSET(CNIC_PORT(cp), cli);
 
 		for (i = 0; i < sizeof(struct ustorm_eth_rx_producers) / 4; i++)
 			CNIC_WR(dev, off + i * 4, ((u32 *) &rx_prods)[i]);
 
 		set_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
 
-		cnic_init_bnx2x_tx_ring(dev);
-		cnic_init_bnx2x_rx_ring(dev);
+		data = cp->l2_buf;
+
+		memset(data, 0, sizeof(*data));
+
+		cnic_init_bnx2x_tx_ring(dev, data);
+		cnic_init_bnx2x_rx_ring(dev, data);
+
+		l5_data.phy_address.lo = cp->l2_buf_map & 0xffffffff;
+		l5_data.phy_address.hi = (u64) cp->l2_buf_map >> 32;
+
+		type = (ETH_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
+			& SPE_HDR_CONN_TYPE;
+		type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
+			SPE_HDR_FUNCTION_ID);
 
 		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 
-		l5_data.phy_address.lo = cli;
-		l5_data.phy_address.hi = 0;
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CLIENT_SETUP,
-			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
+			BNX2X_ISCSI_L2_CID, type, &l5_data);
+
 		i = 0;
 		while (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags) &&
 		       ++i < 10)
@@ -4272,6 +4265,7 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
 		union l5cm_specific_data l5_data;
 		int i;
+		u32 type;
 
 		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 0);
 
@@ -4292,9 +4286,12 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		cnic_kwq_completion(dev, 1);
 
 		memset(&l5_data, 0, sizeof(l5_data));
-		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CFC_DEL,
-			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE |
-			(1 << SPE_HDR_COMMON_RAMROD_SHIFT), &l5_data);
+		type = (NONE_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
+			& SPE_HDR_CONN_TYPE;
+		type |= ((cp->pfid << SPE_HDR_FUNCTION_ID_SHIFT) &
+			 SPE_HDR_FUNCTION_ID);
+		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_COMMON_CFC_DEL,
+			BNX2X_ISCSI_L2_CID, type, &l5_data);
 		msleep(10);
 	}
 	clear_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
@@ -4392,15 +4389,9 @@ static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
 static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	u8 sb_id = cp->status_blk_num;
-	int port = CNIC_PORT(cp);
 
 	cnic_free_irq(dev);
-	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
-		  CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id) +
-		  offsetof(struct cstorm_status_block_c,
-			   index_values[HC_INDEX_C_ISCSI_EQ_CONS]),
-		  0);
+	*cp->kcq1.hw_prod_idx_ptr = 0;
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->pfid, 0), 0);
 	CNIC_WR16(dev, cp->kcq1.io_addr, 0);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 4816183..676d008 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -12,6 +12,13 @@
 #ifndef CNIC_H
 #define CNIC_H
 
+#define HC_INDEX_ISCSI_EQ_CONS			6
+
+#define HC_INDEX_FCOE_EQ_CONS			3
+
+#define HC_SP_INDEX_ETH_ISCSI_CQ_CONS		5
+#define HC_SP_INDEX_ETH_ISCSI_RX_CQ_CONS	1
+
 #define KWQ_PAGE_CNT	4
 #define KCQ_PAGE_CNT	16
 
@@ -179,6 +186,14 @@ struct kcq_info {
 	u32		io_addr;
 };
 
+struct iro {
+	u32 base;
+	u16 m1;
+	u16 m2;
+	u16 m3;
+	u16 size;
+};
+
 struct cnic_local {
 
 	spinlock_t cnic_ulp_lock;
@@ -213,6 +228,9 @@ struct cnic_local {
 	u16		rx_cons;
 	u16		tx_cons;
 
+	struct iro		*iro_arr;
+#define IRO (((struct cnic_local *) dev->cnic_priv)->iro_arr)
+
 	struct cnic_dma		kwq_info;
 	struct kwqe		**kwq;
 
@@ -231,12 +249,16 @@ struct cnic_local {
 	union {
 		void				*gen;
 		struct status_block_msix	*bnx2;
-		struct host_status_block	*bnx2x;
+		struct host_hc_status_block_e1x	*bnx2x_e1x;
+		/* index values - which counter to update */
+		#define SM_RX_ID		0
+		#define SM_TX_ID		1
 	} status_blk;
 
-	struct host_def_status_block	*bnx2x_def_status_blk;
+	struct host_sp_status_block	*bnx2x_def_status_blk;
 
 	u32				status_blk_num;
+	u32				bnx2x_igu_sb_id;
 	u32				int_num;
 	u32				last_status_idx;
 	struct tasklet_struct		cnic_irq_task;
@@ -358,24 +380,33 @@ struct bnx2x_bd_chain_next {
 		(BNX2X_MAX_RCQ_DESC_CNT - 1)) ?				\
 		((x) + 2) : ((x) + 1)
 
-#define BNX2X_DEF_SB_ID			16
+#define BNX2X_DEF_SB_ID			HC_SP_SB_ID
 
-#define BNX2X_ISCSI_RX_SB_INDEX_NUM					\
-		((HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS << \
-		  USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT) & \
-		 USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER)
+#define BNX2X_SHMEM_MF_BLK_OFFSET	0x7e4
 
 #define BNX2X_SHMEM_ADDR(base, field)	(base + \
 					 offsetof(struct shmem_region, field))
 
-#define CNIC_PORT(cp)			((cp)->func % PORT_MAX)
+#define BNX2X_SHMEM2_ADDR(base, field)	(base + \
+					 offsetof(struct shmem2_region, field))
+
+#define BNX2X_SHMEM2_HAS(base, field)				\
+		((base) &&					\
+		 (CNIC_RD(dev, BNX2X_SHMEM2_ADDR(base, size)) >	\
+		  offsetof(struct shmem2_region, field)))
+
+#define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
-#define CNIC_E1HVN(cp)			((cp)->func >> 1)
+#define CNIC_E1HVN(cp)			((cp)->pfid >> 1)
 
-#define BNX2X_HW_CID(cp, x)		(((CNIC_FUNC(cp) % PORT_MAX) << 23) | \
+#define BNX2X_HW_CID(cp, x)		((CNIC_PORT(cp) << 23) | \
 					 (CNIC_E1HVN(cp) << 17) | (x))
 
 #define BNX2X_SW_CID(x)			(x & 0x1ffff)
 
+#define BNX2X_CL_QZONE_ID(cp, cli)					\
+		(cli + (CNIC_PORT(cp) * ETH_MAX_RX_CLIENTS_E1H))
+
+#define TCP_TSTORM_OOO_DROP_AND_PROC_ACK	(0<<4)
 #endif
 
diff --git a/drivers/net/cnic_defs.h b/drivers/net/cnic_defs.h
index 7ce694d..328e8b2 100644
--- a/drivers/net/cnic_defs.h
+++ b/drivers/net/cnic_defs.h
@@ -14,6 +14,7 @@
 
 /* KWQ (kernel work queue) request op codes */
 #define L2_KWQE_OPCODE_VALUE_FLUSH                  (4)
+#define L2_KWQE_OPCODE_VALUE_VM_FREE_RX_QUEUE       (8)
 
 #define L4_KWQE_OPCODE_VALUE_CONNECT1               (50)
 #define L4_KWQE_OPCODE_VALUE_CONNECT2               (51)
@@ -48,11 +49,14 @@
 #define L4_KCQE_OPCODE_VALUE_UPLOAD_PG              (14)
 
 /* KCQ (kernel completion queue) completion status */
-#define L4_KCQE_COMPLETION_STATUS_SUCCESS		    (0)
-#define L4_KCQE_COMPLETION_STATUS_TIMEOUT        (0x93)
+#define L4_KCQE_COMPLETION_STATUS_SUCCESS           (0)
+#define L4_KCQE_COMPLETION_STATUS_TIMEOUT           (0x93)
 
-#define L4_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAIL (0x83)
-#define L4_KCQE_COMPLETION_STATUS_OFFLOADED_PG   (0x89)
+#define L4_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAIL    (0x83)
+#define L4_KCQE_COMPLETION_STATUS_OFFLOADED_PG      (0x89)
+
+#define L4_KCQE_OPCODE_VALUE_OOO_EVENT_NOTIFICATION (0xa0)
+#define L4_KCQE_OPCODE_VALUE_OOO_FLUSH              (0xa1)
 
 #define L4_LAYER_CODE (4)
 #define L2_LAYER_CODE (2)
@@ -585,6 +589,100 @@ struct l4_kwq_upload {
  */
 
 /*
+ * The iscsi aggregative context of Cstorm
+ */
+struct cstorm_iscsi_ag_context {
+	u32 agg_vars1;
+#define CSTORM_ISCSI_AG_CONTEXT_STATE (0xFF<<0)
+#define CSTORM_ISCSI_AG_CONTEXT_STATE_SHIFT 0
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<8)
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 8
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<9)
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 9
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM2 (0x1<<10)
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 10
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<11)
+#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 11
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_SE_CF_EN (0x1<<12)
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_SE_CF_EN_SHIFT 12
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_INV_CF_EN (0x1<<13)
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_INV_CF_EN_SHIFT 13
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF (0x3<<14)
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF_SHIFT 14
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED66 (0x3<<16)
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED66_SHIFT 16
+#define __CSTORM_ISCSI_AG_CONTEXT_FIN_RECEIVED_CF_EN (0x1<<18)
+#define __CSTORM_ISCSI_AG_CONTEXT_FIN_RECEIVED_CF_EN_SHIFT 18
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION0_CF_EN (0x1<<19)
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION0_CF_EN_SHIFT 19
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION1_CF_EN (0x1<<20)
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION1_CF_EN_SHIFT 20
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION2_CF_EN (0x1<<21)
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION2_CF_EN_SHIFT 21
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF_EN (0x1<<22)
+#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF_EN_SHIFT 22
+#define __CSTORM_ISCSI_AG_CONTEXT_REL_SEQ_RULE (0x7<<23)
+#define __CSTORM_ISCSI_AG_CONTEXT_REL_SEQ_RULE_SHIFT 23
+#define CSTORM_ISCSI_AG_CONTEXT_HQ_PROD_RULE (0x3<<26)
+#define CSTORM_ISCSI_AG_CONTEXT_HQ_PROD_RULE_SHIFT 26
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED52 (0x3<<28)
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED52_SHIFT 28
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED53 (0x3<<30)
+#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED53_SHIFT 30
+#if defined(__BIG_ENDIAN)
+	u8 __aux1_th;
+	u8 __aux1_val;
+	u16 __agg_vars2;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __agg_vars2;
+	u8 __aux1_val;
+	u8 __aux1_th;
+#endif
+	u32 rel_seq;
+	u32 rel_seq_th;
+#if defined(__BIG_ENDIAN)
+	u16 hq_cons;
+	u16 hq_prod;
+#elif defined(__LITTLE_ENDIAN)
+	u16 hq_prod;
+	u16 hq_cons;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 __reserved62;
+	u8 __reserved61;
+	u8 __reserved60;
+	u8 __reserved59;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __reserved59;
+	u8 __reserved60;
+	u8 __reserved61;
+	u8 __reserved62;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __reserved64;
+	u16 __cq_u_prod0;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __cq_u_prod0;
+	u16 __reserved64;
+#endif
+	u32 __cq_u_prod1;
+#if defined(__BIG_ENDIAN)
+	u16 __agg_vars3;
+	u16 __cq_u_prod2;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __cq_u_prod2;
+	u16 __agg_vars3;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __aux2_th;
+	u16 __cq_u_prod3;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __cq_u_prod3;
+	u16 __aux2_th;
+#endif
+};
+
+/*
  * iSCSI context region, used only in iSCSI
  */
 struct ustorm_iscsi_rq_db {
@@ -696,7 +794,7 @@ struct ustorm_iscsi_st_context {
 	struct regpair task_pbl_base;
 	struct regpair tce_phy_addr;
 	struct ustorm_iscsi_placement_db place_db;
-	u32 data_rcv_seq;
+	u32 reserved8;
 	u32 rem_rcv_len;
 #if defined(__BIG_ENDIAN)
 	u16 hdr_itt;
@@ -713,8 +811,10 @@ struct ustorm_iscsi_st_context {
 #define USTORM_ISCSI_ST_CONTEXT_BMIDDLEOFPDU_SHIFT 0
 #define USTORM_ISCSI_ST_CONTEXT_BFENCECQE (0x1<<1)
 #define USTORM_ISCSI_ST_CONTEXT_BFENCECQE_SHIFT 1
-#define USTORM_ISCSI_ST_CONTEXT_RESERVED1 (0x3F<<2)
-#define USTORM_ISCSI_ST_CONTEXT_RESERVED1_SHIFT 2
+#define USTORM_ISCSI_ST_CONTEXT_BRESETCRC (0x1<<2)
+#define USTORM_ISCSI_ST_CONTEXT_BRESETCRC_SHIFT 2
+#define USTORM_ISCSI_ST_CONTEXT_RESERVED1 (0x1F<<3)
+#define USTORM_ISCSI_ST_CONTEXT_RESERVED1_SHIFT 3
 	u8 task_pdu_cache_index;
 	u8 task_pbe_cache_index;
 #elif defined(__LITTLE_ENDIAN)
@@ -725,8 +825,10 @@ struct ustorm_iscsi_st_context {
 #define USTORM_ISCSI_ST_CONTEXT_BMIDDLEOFPDU_SHIFT 0
 #define USTORM_ISCSI_ST_CONTEXT_BFENCECQE (0x1<<1)
 #define USTORM_ISCSI_ST_CONTEXT_BFENCECQE_SHIFT 1
-#define USTORM_ISCSI_ST_CONTEXT_RESERVED1 (0x3F<<2)
-#define USTORM_ISCSI_ST_CONTEXT_RESERVED1_SHIFT 2
+#define USTORM_ISCSI_ST_CONTEXT_BRESETCRC (0x1<<2)
+#define USTORM_ISCSI_ST_CONTEXT_BRESETCRC_SHIFT 2
+#define USTORM_ISCSI_ST_CONTEXT_RESERVED1 (0x1F<<3)
+#define USTORM_ISCSI_ST_CONTEXT_RESERVED1_SHIFT 3
 	u8 hdr_second_byte_union;
 #endif
 #if defined(__BIG_ENDIAN)
@@ -777,14 +879,14 @@ struct ustorm_iscsi_st_context {
  */
 struct tstorm_tcp_st_context_section {
 	u32 flags1;
-#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_SRTT_20B (0xFFFFFF<<0)
-#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_SRTT_20B_SHIFT 0
+#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_SRTT (0xFFFFFF<<0)
+#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_SRTT_SHIFT 0
 #define TSTORM_TCP_ST_CONTEXT_SECTION_PAWS_INVALID (0x1<<24)
 #define TSTORM_TCP_ST_CONTEXT_SECTION_PAWS_INVALID_SHIFT 24
 #define TSTORM_TCP_ST_CONTEXT_SECTION_TIMESTAMP_EXISTS (0x1<<25)
 #define TSTORM_TCP_ST_CONTEXT_SECTION_TIMESTAMP_EXISTS_SHIFT 25
-#define TSTORM_TCP_ST_CONTEXT_SECTION_ISLE_EXISTS (0x1<<26)
-#define TSTORM_TCP_ST_CONTEXT_SECTION_ISLE_EXISTS_SHIFT 26
+#define TSTORM_TCP_ST_CONTEXT_SECTION_RESERVED0 (0x1<<26)
+#define TSTORM_TCP_ST_CONTEXT_SECTION_RESERVED0_SHIFT 26
 #define TSTORM_TCP_ST_CONTEXT_SECTION_STOP_RX_PAYLOAD (0x1<<27)
 #define TSTORM_TCP_ST_CONTEXT_SECTION_STOP_RX_PAYLOAD_SHIFT 27
 #define TSTORM_TCP_ST_CONTEXT_SECTION_KA_ENABLED (0x1<<28)
@@ -793,11 +895,11 @@ struct tstorm_tcp_st_context_section {
 #define TSTORM_TCP_ST_CONTEXT_SECTION_FIRST_RTO_ESTIMATE_SHIFT 29
 #define TSTORM_TCP_ST_CONTEXT_SECTION_MAX_SEG_RETRANSMIT_EN (0x1<<30)
 #define TSTORM_TCP_ST_CONTEXT_SECTION_MAX_SEG_RETRANSMIT_EN_SHIFT 30
-#define TSTORM_TCP_ST_CONTEXT_SECTION_RESERVED3 (0x1<<31)
-#define TSTORM_TCP_ST_CONTEXT_SECTION_RESERVED3_SHIFT 31
+#define TSTORM_TCP_ST_CONTEXT_SECTION_LAST_ISLE_HAS_FIN (0x1<<31)
+#define TSTORM_TCP_ST_CONTEXT_SECTION_LAST_ISLE_HAS_FIN_SHIFT 31
 	u32 flags2;
-#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_VARIATION_20B (0xFFFFFF<<0)
-#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_VARIATION_20B_SHIFT 0
+#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_VARIATION (0xFFFFFF<<0)
+#define TSTORM_TCP_ST_CONTEXT_SECTION_RTT_VARIATION_SHIFT 0
 #define TSTORM_TCP_ST_CONTEXT_SECTION_DA_EN (0x1<<24)
 #define TSTORM_TCP_ST_CONTEXT_SECTION_DA_EN_SHIFT 24
 #define TSTORM_TCP_ST_CONTEXT_SECTION_DA_COUNTER_EN (0x1<<25)
@@ -810,18 +912,18 @@ struct tstorm_tcp_st_context_section {
 #define TSTORM_TCP_ST_CONTEXT_SECTION_UPDATE_L2_STATSTICS_SHIFT 28
 #define TSTORM_TCP_ST_CONTEXT_SECTION_UPDATE_L4_STATSTICS (0x1<<29)
 #define TSTORM_TCP_ST_CONTEXT_SECTION_UPDATE_L4_STATSTICS_SHIFT 29
-#define __TSTORM_TCP_ST_CONTEXT_SECTION_SECOND_ISLE_DROPPED (0x1<<30)
-#define __TSTORM_TCP_ST_CONTEXT_SECTION_SECOND_ISLE_DROPPED_SHIFT 30
-#define __TSTORM_TCP_ST_CONTEXT_SECTION_DONT_SUPPORT_OOO (0x1<<31)
-#define __TSTORM_TCP_ST_CONTEXT_SECTION_DONT_SUPPORT_OOO_SHIFT 31
+#define __TSTORM_TCP_ST_CONTEXT_SECTION_IN_WINDOW_RST_ATTACK (0x1<<30)
+#define __TSTORM_TCP_ST_CONTEXT_SECTION_IN_WINDOW_RST_ATTACK_SHIFT 30
+#define __TSTORM_TCP_ST_CONTEXT_SECTION_IN_WINDOW_SYN_ATTACK (0x1<<31)
+#define __TSTORM_TCP_ST_CONTEXT_SECTION_IN_WINDOW_SYN_ATTACK_SHIFT 31
 #if defined(__BIG_ENDIAN)
-	u16 reserved_slowpath;
-	u8 tcp_sm_state_3b;
-	u8 rto_exp_3b;
+	u16 mss;
+	u8 tcp_sm_state;
+	u8 rto_exp;
 #elif defined(__LITTLE_ENDIAN)
-	u8 rto_exp_3b;
-	u8 tcp_sm_state_3b;
-	u16 reserved_slowpath;
+	u8 rto_exp;
+	u8 tcp_sm_state;
+	u16 mss;
 #endif
 	u32 rcv_nxt;
 	u32 timestamp_recent;
@@ -846,11 +948,11 @@ struct tstorm_tcp_st_context_section {
 #if defined(__BIG_ENDIAN)
 	u8 statistics_counter_id;
 	u8 ooo_support_mode;
-	u8 snd_wnd_scale_4b;
+	u8 snd_wnd_scale;
 	u8 dup_ack_count;
 #elif defined(__LITTLE_ENDIAN)
 	u8 dup_ack_count;
-	u8 snd_wnd_scale_4b;
+	u8 snd_wnd_scale;
 	u8 ooo_support_mode;
 	u8 statistics_counter_id;
 #endif
@@ -860,13 +962,21 @@ struct tstorm_tcp_st_context_section {
 	u32 isle_start_seq;
 	u32 isle_end_seq;
 #if defined(__BIG_ENDIAN)
-	u16 mss;
+	u16 second_isle_address;
 	u16 recent_seg_wnd;
 #elif defined(__LITTLE_ENDIAN)
 	u16 recent_seg_wnd;
-	u16 mss;
+	u16 second_isle_address;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 max_isles_ever_happened;
+	u8 isles_number;
+	u16 last_isle_address;
+#elif defined(__LITTLE_ENDIAN)
+	u16 last_isle_address;
+	u8 isles_number;
+	u8 max_isles_ever_happened;
 #endif
-	u32 reserved4;
 	u32 max_rt_time;
 #if defined(__BIG_ENDIAN)
 	u16 lsb_mac_address;
@@ -876,7 +986,7 @@ struct tstorm_tcp_st_context_section {
 	u16 lsb_mac_address;
 #endif
 	u32 msb_mac_address;
-	u32 reserved2;
+	u32 rightmost_received_seq;
 };
 
 /*
@@ -951,7 +1061,7 @@ struct tstorm_iscsi_st_context_section {
 	u8 scratchpad_idx;
 	struct iscsi_term_vars term_vars;
 #endif
-	u32 reserved2;
+	u32 process_nxt;
 };
 
 /*
@@ -1174,24 +1284,12 @@ struct xstorm_iscsi_ag_context {
 #endif
 #if defined(__BIG_ENDIAN)
 	u8 cdu_reserved;
-	u8 agg_vars4;
-#define XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF (0x3<<0)
-#define XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF_SHIFT 0
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF (0x3<<2)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF_SHIFT 2
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX18_CF_EN (0x1<<4)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX18_CF_EN_SHIFT 4
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF_EN (0x1<<5)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF_EN_SHIFT 5
-#define __XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF_EN (0x1<<6)
-#define __XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF_EN_SHIFT 6
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF_EN (0x1<<7)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF_EN_SHIFT 7
+	u8 __agg_vars4;
 	u8 agg_vars3;
 #define XSTORM_ISCSI_AG_CONTEXT_PHYSICAL_QUEUE_NUM2 (0x3F<<0)
 #define XSTORM_ISCSI_AG_CONTEXT_PHYSICAL_QUEUE_NUM2_SHIFT 0
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF (0x3<<6)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF_SHIFT 6
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_TS_EN_CF (0x3<<6)
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_TS_EN_CF_SHIFT 6
 	u8 agg_vars2;
 #define __XSTORM_ISCSI_AG_CONTEXT_DQ_CF (0x3<<0)
 #define __XSTORM_ISCSI_AG_CONTEXT_DQ_CF_SHIFT 0
@@ -1222,21 +1320,9 @@ struct xstorm_iscsi_ag_context {
 	u8 agg_vars3;
 #define XSTORM_ISCSI_AG_CONTEXT_PHYSICAL_QUEUE_NUM2 (0x3F<<0)
 #define XSTORM_ISCSI_AG_CONTEXT_PHYSICAL_QUEUE_NUM2_SHIFT 0
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF (0x3<<6)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF_SHIFT 6
-	u8 agg_vars4;
-#define XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF (0x3<<0)
-#define XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF_SHIFT 0
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF (0x3<<2)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF_SHIFT 2
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX18_CF_EN (0x1<<4)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX18_CF_EN_SHIFT 4
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF_EN (0x1<<5)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX19_CF_EN_SHIFT 5
-#define __XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF_EN (0x1<<6)
-#define __XSTORM_ISCSI_AG_CONTEXT_R2TQ_PROD_CF_EN_SHIFT 6
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF_EN (0x1<<7)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX21_CF_EN_SHIFT 7
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_TS_EN_CF (0x3<<6)
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_TS_EN_CF_SHIFT 6
+	u8 __agg_vars4;
 	u8 cdu_reserved;
 #endif
 	u32 more_to_send;
@@ -1270,8 +1356,8 @@ struct xstorm_iscsi_ag_context {
 #define __XSTORM_ISCSI_AG_CONTEXT_AGG_VAL11_DECISION_RULE_SHIFT 0
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX13_FLAG (0x1<<3)
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX13_FLAG_SHIFT 3
-#define XSTORM_ISCSI_AG_CONTEXT_AUX18_CF (0x3<<4)
-#define XSTORM_ISCSI_AG_CONTEXT_AUX18_CF_SHIFT 4
+#define __XSTORM_ISCSI_AG_CONTEXT_STORMS_SYNC_CF (0x3<<4)
+#define __XSTORM_ISCSI_AG_CONTEXT_STORMS_SYNC_CF_SHIFT 4
 #define XSTORM_ISCSI_AG_CONTEXT_DECISION_RULE3 (0x3<<6)
 #define XSTORM_ISCSI_AG_CONTEXT_DECISION_RULE3_SHIFT 6
 #define XSTORM_ISCSI_AG_CONTEXT_AUX1_CF (0x3<<8)
@@ -1286,8 +1372,8 @@ struct xstorm_iscsi_ag_context {
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX11_FLAG_SHIFT 13
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX12_FLAG (0x1<<14)
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX12_FLAG_SHIFT 14
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX2_FLAG (0x1<<15)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX2_FLAG_SHIFT 15
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_WND_SCL_EN (0x1<<15)
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_WND_SCL_EN_SHIFT 15
 	u8 agg_val3_th;
 	u8 agg_vars6;
 #define XSTORM_ISCSI_AG_CONTEXT_DECISION_RULE6 (0x7<<0)
@@ -1310,8 +1396,8 @@ struct xstorm_iscsi_ag_context {
 #define __XSTORM_ISCSI_AG_CONTEXT_AGG_VAL11_DECISION_RULE_SHIFT 0
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX13_FLAG (0x1<<3)
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX13_FLAG_SHIFT 3
-#define XSTORM_ISCSI_AG_CONTEXT_AUX18_CF (0x3<<4)
-#define XSTORM_ISCSI_AG_CONTEXT_AUX18_CF_SHIFT 4
+#define __XSTORM_ISCSI_AG_CONTEXT_STORMS_SYNC_CF (0x3<<4)
+#define __XSTORM_ISCSI_AG_CONTEXT_STORMS_SYNC_CF_SHIFT 4
 #define XSTORM_ISCSI_AG_CONTEXT_DECISION_RULE3 (0x3<<6)
 #define XSTORM_ISCSI_AG_CONTEXT_DECISION_RULE3_SHIFT 6
 #define XSTORM_ISCSI_AG_CONTEXT_AUX1_CF (0x3<<8)
@@ -1326,14 +1412,14 @@ struct xstorm_iscsi_ag_context {
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX11_FLAG_SHIFT 13
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX12_FLAG (0x1<<14)
 #define __XSTORM_ISCSI_AG_CONTEXT_AUX12_FLAG_SHIFT 14
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX2_FLAG (0x1<<15)
-#define __XSTORM_ISCSI_AG_CONTEXT_AUX2_FLAG_SHIFT 15
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_WND_SCL_EN (0x1<<15)
+#define __XSTORM_ISCSI_AG_CONTEXT_RX_WND_SCL_EN_SHIFT 15
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 __agg_val11_th;
-	u16 __agg_val11;
+	u16 __gen_data;
 #elif defined(__LITTLE_ENDIAN)
-	u16 __agg_val11;
+	u16 __gen_data;
 	u16 __agg_val11_th;
 #endif
 #if defined(__BIG_ENDIAN)
@@ -1384,7 +1470,7 @@ struct xstorm_iscsi_ag_context {
 #endif
 	u32 hq_cons_tcp_seq;
 	u32 exp_stat_sn;
-	u32 agg_misc5;
+	u32 rst_seq_num;
 };
 
 /*
@@ -1478,12 +1564,12 @@ struct tstorm_iscsi_ag_context {
 #define TSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 2
 #define TSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<3)
 #define TSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 3
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX3_CF (0x3<<4)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX3_CF_SHIFT 4
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF (0x3<<4)
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF_SHIFT 4
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX3_FLAG (0x1<<6)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX3_FLAG_SHIFT 6
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_FLAG (0x1<<7)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_FLAG_SHIFT 7
+#define __TSTORM_ISCSI_AG_CONTEXT_ACK_ON_FIN_SENT_FLAG (0x1<<7)
+#define __TSTORM_ISCSI_AG_CONTEXT_ACK_ON_FIN_SENT_FLAG_SHIFT 7
 	u8 state;
 #elif defined(__LITTLE_ENDIAN)
 	u8 state;
@@ -1496,63 +1582,63 @@ struct tstorm_iscsi_ag_context {
 #define TSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 2
 #define TSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<3)
 #define TSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 3
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX3_CF (0x3<<4)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX3_CF_SHIFT 4
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF (0x3<<4)
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF_SHIFT 4
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX3_FLAG (0x1<<6)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX3_FLAG_SHIFT 6
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_FLAG (0x1<<7)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_FLAG_SHIFT 7
+#define __TSTORM_ISCSI_AG_CONTEXT_ACK_ON_FIN_SENT_FLAG (0x1<<7)
+#define __TSTORM_ISCSI_AG_CONTEXT_ACK_ON_FIN_SENT_FLAG_SHIFT 7
 	u16 ulp_credit;
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 __agg_val4;
 	u16 agg_vars2;
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_FLAG (0x1<<0)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_FLAG_SHIFT 0
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX6_FLAG (0x1<<1)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX6_FLAG_SHIFT 1
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_CF (0x3<<2)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_CF_SHIFT 2
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_CF (0x3<<4)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_CF_SHIFT 4
+#define __TSTORM_ISCSI_AG_CONTEXT_MSL_TIMER_SET_FLAG (0x1<<0)
+#define __TSTORM_ISCSI_AG_CONTEXT_MSL_TIMER_SET_FLAG_SHIFT 0
+#define __TSTORM_ISCSI_AG_CONTEXT_FIN_SENT_FIRST_FLAG (0x1<<1)
+#define __TSTORM_ISCSI_AG_CONTEXT_FIN_SENT_FIRST_FLAG_SHIFT 1
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF (0x3<<2)
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF_SHIFT 2
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF (0x3<<4)
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF_SHIFT 4
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX6_CF (0x3<<6)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX6_CF_SHIFT 6
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_CF (0x3<<8)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_CF_SHIFT 8
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_FLAG (0x1<<10)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_FLAG_SHIFT 10
-#define TSTORM_ISCSI_AG_CONTEXT_AUX3_CF_EN (0x1<<11)
-#define TSTORM_ISCSI_AG_CONTEXT_AUX3_CF_EN_SHIFT 11
-#define TSTORM_ISCSI_AG_CONTEXT_AUX4_CF_EN (0x1<<12)
-#define TSTORM_ISCSI_AG_CONTEXT_AUX4_CF_EN_SHIFT 12
-#define TSTORM_ISCSI_AG_CONTEXT_AUX5_CF_EN (0x1<<13)
-#define TSTORM_ISCSI_AG_CONTEXT_AUX5_CF_EN_SHIFT 13
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF_EN (0x1<<11)
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF_EN_SHIFT 11
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF_EN (0x1<<12)
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF_EN_SHIFT 12
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF_EN (0x1<<13)
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF_EN_SHIFT 13
 #define TSTORM_ISCSI_AG_CONTEXT_AUX6_CF_EN (0x1<<14)
 #define TSTORM_ISCSI_AG_CONTEXT_AUX6_CF_EN_SHIFT 14
 #define TSTORM_ISCSI_AG_CONTEXT_AUX7_CF_EN (0x1<<15)
 #define TSTORM_ISCSI_AG_CONTEXT_AUX7_CF_EN_SHIFT 15
 #elif defined(__LITTLE_ENDIAN)
 	u16 agg_vars2;
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_FLAG (0x1<<0)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_FLAG_SHIFT 0
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX6_FLAG (0x1<<1)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX6_FLAG_SHIFT 1
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_CF (0x3<<2)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX4_CF_SHIFT 2
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_CF (0x3<<4)
-#define __TSTORM_ISCSI_AG_CONTEXT_AUX5_CF_SHIFT 4
+#define __TSTORM_ISCSI_AG_CONTEXT_MSL_TIMER_SET_FLAG (0x1<<0)
+#define __TSTORM_ISCSI_AG_CONTEXT_MSL_TIMER_SET_FLAG_SHIFT 0
+#define __TSTORM_ISCSI_AG_CONTEXT_FIN_SENT_FIRST_FLAG (0x1<<1)
+#define __TSTORM_ISCSI_AG_CONTEXT_FIN_SENT_FIRST_FLAG_SHIFT 1
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF (0x3<<2)
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF_SHIFT 2
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF (0x3<<4)
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF_SHIFT 4
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX6_CF (0x3<<6)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX6_CF_SHIFT 6
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_CF (0x3<<8)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_CF_SHIFT 8
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_FLAG (0x1<<10)
 #define __TSTORM_ISCSI_AG_CONTEXT_AUX7_FLAG_SHIFT 10
-#define TSTORM_ISCSI_AG_CONTEXT_AUX3_CF_EN (0x1<<11)
-#define TSTORM_ISCSI_AG_CONTEXT_AUX3_CF_EN_SHIFT 11
-#define TSTORM_ISCSI_AG_CONTEXT_AUX4_CF_EN (0x1<<12)
-#define TSTORM_ISCSI_AG_CONTEXT_AUX4_CF_EN_SHIFT 12
-#define TSTORM_ISCSI_AG_CONTEXT_AUX5_CF_EN (0x1<<13)
-#define TSTORM_ISCSI_AG_CONTEXT_AUX5_CF_EN_SHIFT 13
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF_EN (0x1<<11)
+#define __TSTORM_ISCSI_AG_CONTEXT_QUEUES_FLUSH_Q0_CF_EN_SHIFT 11
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF_EN (0x1<<12)
+#define __TSTORM_ISCSI_AG_CONTEXT_RST_SENT_CF_EN_SHIFT 12
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF_EN (0x1<<13)
+#define __TSTORM_ISCSI_AG_CONTEXT_WAKEUP_CALL_CF_EN_SHIFT 13
 #define TSTORM_ISCSI_AG_CONTEXT_AUX6_CF_EN (0x1<<14)
 #define TSTORM_ISCSI_AG_CONTEXT_AUX6_CF_EN_SHIFT 14
 #define TSTORM_ISCSI_AG_CONTEXT_AUX7_CF_EN (0x1<<15)
@@ -1563,100 +1649,6 @@ struct tstorm_iscsi_ag_context {
 };
 
 /*
- * The iscsi aggregative context of Cstorm
- */
-struct cstorm_iscsi_ag_context {
-	u32 agg_vars1;
-#define CSTORM_ISCSI_AG_CONTEXT_STATE (0xFF<<0)
-#define CSTORM_ISCSI_AG_CONTEXT_STATE_SHIFT 0
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM0 (0x1<<8)
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM0_SHIFT 8
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM1 (0x1<<9)
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM1_SHIFT 9
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM2 (0x1<<10)
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM2_SHIFT 10
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3 (0x1<<11)
-#define __CSTORM_ISCSI_AG_CONTEXT_EXISTS_IN_QM3_SHIFT 11
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_SE_CF_EN (0x1<<12)
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_SE_CF_EN_SHIFT 12
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_INV_CF_EN (0x1<<13)
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED_ULP_RX_INV_CF_EN_SHIFT 13
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF (0x3<<14)
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF_SHIFT 14
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED66 (0x3<<16)
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED66_SHIFT 16
-#define __CSTORM_ISCSI_AG_CONTEXT_FIN_RECEIVED_CF_EN (0x1<<18)
-#define __CSTORM_ISCSI_AG_CONTEXT_FIN_RECEIVED_CF_EN_SHIFT 18
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION0_CF_EN (0x1<<19)
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION0_CF_EN_SHIFT 19
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION1_CF_EN (0x1<<20)
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION1_CF_EN_SHIFT 20
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION2_CF_EN (0x1<<21)
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION2_CF_EN_SHIFT 21
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF_EN (0x1<<22)
-#define __CSTORM_ISCSI_AG_CONTEXT_PENDING_COMPLETION3_CF_EN_SHIFT 22
-#define __CSTORM_ISCSI_AG_CONTEXT_REL_SEQ_RULE (0x7<<23)
-#define __CSTORM_ISCSI_AG_CONTEXT_REL_SEQ_RULE_SHIFT 23
-#define CSTORM_ISCSI_AG_CONTEXT_HQ_PROD_RULE (0x3<<26)
-#define CSTORM_ISCSI_AG_CONTEXT_HQ_PROD_RULE_SHIFT 26
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED52 (0x3<<28)
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED52_SHIFT 28
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED53 (0x3<<30)
-#define __CSTORM_ISCSI_AG_CONTEXT_RESERVED53_SHIFT 30
-#if defined(__BIG_ENDIAN)
-	u8 __aux1_th;
-	u8 __aux1_val;
-	u16 __agg_vars2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __agg_vars2;
-	u8 __aux1_val;
-	u8 __aux1_th;
-#endif
-	u32 rel_seq;
-	u32 rel_seq_th;
-#if defined(__BIG_ENDIAN)
-	u16 hq_cons;
-	u16 hq_prod;
-#elif defined(__LITTLE_ENDIAN)
-	u16 hq_prod;
-	u16 hq_cons;
-#endif
-#if defined(__BIG_ENDIAN)
-	u8 __reserved62;
-	u8 __reserved61;
-	u8 __reserved60;
-	u8 __reserved59;
-#elif defined(__LITTLE_ENDIAN)
-	u8 __reserved59;
-	u8 __reserved60;
-	u8 __reserved61;
-	u8 __reserved62;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __reserved64;
-	u16 __cq_u_prod0;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __cq_u_prod0;
-	u16 __reserved64;
-#endif
-	u32 __cq_u_prod1;
-#if defined(__BIG_ENDIAN)
-	u16 __agg_vars3;
-	u16 __cq_u_prod2;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __cq_u_prod2;
-	u16 __agg_vars3;
-#endif
-#if defined(__BIG_ENDIAN)
-	u16 __aux2_th;
-	u16 __cq_u_prod3;
-#elif defined(__LITTLE_ENDIAN)
-	u16 __cq_u_prod3;
-	u16 __aux2_th;
-#endif
-};
-
-/*
  * The iscsi aggregative context of Ustorm
  */
 struct ustorm_iscsi_ag_context {
@@ -1746,8 +1738,8 @@ struct ustorm_iscsi_ag_context {
 #define USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_RULE_SHIFT 0
 #define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL3_RULE (0x7<<3)
 #define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL3_RULE_SHIFT 3
-#define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG (0x1<<6)
-#define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG_SHIFT 6
+#define USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG (0x1<<6)
+#define USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG_SHIFT 6
 #define __USTORM_ISCSI_AG_CONTEXT_RESERVED1 (0x1<<7)
 #define __USTORM_ISCSI_AG_CONTEXT_RESERVED1_SHIFT 7
 	u8 decision_rule_enable_bits;
@@ -1790,8 +1782,8 @@ struct ustorm_iscsi_ag_context {
 #define USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_RULE_SHIFT 0
 #define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL3_RULE (0x7<<3)
 #define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL3_RULE_SHIFT 3
-#define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG (0x1<<6)
-#define __USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG_SHIFT 6
+#define USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG (0x1<<6)
+#define USTORM_ISCSI_AG_CONTEXT_AGG_VAL2_ARM_N_FLAG_SHIFT 6
 #define __USTORM_ISCSI_AG_CONTEXT_RESERVED1 (0x1<<7)
 #define __USTORM_ISCSI_AG_CONTEXT_RESERVED1_SHIFT 7
 	u16 __reserved2;
@@ -1799,22 +1791,6 @@ struct ustorm_iscsi_ag_context {
 };
 
 /*
- * Timers connection context
- */
-struct iscsi_timers_block_context {
-	u32 __reserved_0;
-	u32 __reserved_1;
-	u32 __reserved_2;
-	u32 flags;
-#define __ISCSI_TIMERS_BLOCK_CONTEXT_NUM_OF_ACTIVE_TIMERS (0x3<<0)
-#define __ISCSI_TIMERS_BLOCK_CONTEXT_NUM_OF_ACTIVE_TIMERS_SHIFT 0
-#define ISCSI_TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG (0x1<<2)
-#define ISCSI_TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG_SHIFT 2
-#define __ISCSI_TIMERS_BLOCK_CONTEXT_RESERVED0 (0x1FFFFFFF<<3)
-#define __ISCSI_TIMERS_BLOCK_CONTEXT_RESERVED0_SHIFT 3
-};
-
-/*
  * Ethernet context section, shared in TOE, RDMA and ISCSI
  */
 struct xstorm_eth_context_section {
@@ -1963,7 +1939,7 @@ struct xstorm_tcp_context_section {
 #endif
 #if defined(__BIG_ENDIAN)
 	u8 original_nagle_1b;
-	u8 ts_enabled_1b;
+	u8 ts_enabled;
 	u16 tcp_params;
 #define XSTORM_TCP_CONTEXT_SECTION_TOTAL_HEADER_SIZE (0xFF<<0)
 #define XSTORM_TCP_CONTEXT_SECTION_TOTAL_HEADER_SIZE_SHIFT 0
@@ -1973,8 +1949,8 @@ struct xstorm_tcp_context_section {
 #define __XSTORM_TCP_CONTEXT_SECTION_ECN_ENABLED_SHIFT 9
 #define XSTORM_TCP_CONTEXT_SECTION_SACK_ENABLED (0x1<<10)
 #define XSTORM_TCP_CONTEXT_SECTION_SACK_ENABLED_SHIFT 10
-#define XSTORM_TCP_CONTEXT_SECTION_KA_STATE (0x1<<11)
-#define XSTORM_TCP_CONTEXT_SECTION_KA_STATE_SHIFT 11
+#define XSTORM_TCP_CONTEXT_SECTION_SMALL_WIN_ADV (0x1<<11)
+#define XSTORM_TCP_CONTEXT_SECTION_SMALL_WIN_ADV_SHIFT 11
 #define XSTORM_TCP_CONTEXT_SECTION_FIN_SENT_FLAG (0x1<<12)
 #define XSTORM_TCP_CONTEXT_SECTION_FIN_SENT_FLAG_SHIFT 12
 #define XSTORM_TCP_CONTEXT_SECTION_WINDOW_SATURATED (0x1<<13)
@@ -1991,15 +1967,15 @@ struct xstorm_tcp_context_section {
 #define __XSTORM_TCP_CONTEXT_SECTION_ECN_ENABLED_SHIFT 9
 #define XSTORM_TCP_CONTEXT_SECTION_SACK_ENABLED (0x1<<10)
 #define XSTORM_TCP_CONTEXT_SECTION_SACK_ENABLED_SHIFT 10
-#define XSTORM_TCP_CONTEXT_SECTION_KA_STATE (0x1<<11)
-#define XSTORM_TCP_CONTEXT_SECTION_KA_STATE_SHIFT 11
+#define XSTORM_TCP_CONTEXT_SECTION_SMALL_WIN_ADV (0x1<<11)
+#define XSTORM_TCP_CONTEXT_SECTION_SMALL_WIN_ADV_SHIFT 11
 #define XSTORM_TCP_CONTEXT_SECTION_FIN_SENT_FLAG (0x1<<12)
 #define XSTORM_TCP_CONTEXT_SECTION_FIN_SENT_FLAG_SHIFT 12
 #define XSTORM_TCP_CONTEXT_SECTION_WINDOW_SATURATED (0x1<<13)
 #define XSTORM_TCP_CONTEXT_SECTION_WINDOW_SATURATED_SHIFT 13
 #define XSTORM_TCP_CONTEXT_SECTION_SLOWPATH_QUEUES_FLUSH_COUNTER (0x3<<14)
 #define XSTORM_TCP_CONTEXT_SECTION_SLOWPATH_QUEUES_FLUSH_COUNTER_SHIFT 14
-	u8 ts_enabled_1b;
+	u8 ts_enabled;
 	u8 original_nagle_1b;
 #endif
 #if defined(__BIG_ENDIAN)
@@ -2030,8 +2006,8 @@ struct xstorm_common_context_section {
 #define XSTORM_COMMON_CONTEXT_SECTION_UPDATE_L4_STATSTICS_SHIFT 1
 #define XSTORM_COMMON_CONTEXT_SECTION_STATISTICS_COUNTER_ID (0x1F<<2)
 #define XSTORM_COMMON_CONTEXT_SECTION_STATISTICS_COUNTER_ID_SHIFT 2
-#define XSTORM_COMMON_CONTEXT_SECTION_RESERVED0 (0x1<<7)
-#define XSTORM_COMMON_CONTEXT_SECTION_RESERVED0_SHIFT 7
+#define XSTORM_COMMON_CONTEXT_SECTION_DCB_EXISTS (0x1<<7)
+#define XSTORM_COMMON_CONTEXT_SECTION_DCB_EXISTS_SHIFT 7
 	u8 ip_version_1b;
 #elif defined(__LITTLE_ENDIAN)
 	u8 ip_version_1b;
@@ -2042,8 +2018,8 @@ struct xstorm_common_context_section {
 #define XSTORM_COMMON_CONTEXT_SECTION_UPDATE_L4_STATSTICS_SHIFT 1
 #define XSTORM_COMMON_CONTEXT_SECTION_STATISTICS_COUNTER_ID (0x1F<<2)
 #define XSTORM_COMMON_CONTEXT_SECTION_STATISTICS_COUNTER_ID_SHIFT 2
-#define XSTORM_COMMON_CONTEXT_SECTION_RESERVED0 (0x1<<7)
-#define XSTORM_COMMON_CONTEXT_SECTION_RESERVED0_SHIFT 7
+#define XSTORM_COMMON_CONTEXT_SECTION_DCB_EXISTS (0x1<<7)
+#define XSTORM_COMMON_CONTEXT_SECTION_DCB_EXISTS_SHIFT 7
 	u16 reserved;
 #endif
 };
@@ -2284,7 +2260,7 @@ struct iscsi_context {
 	struct tstorm_iscsi_ag_context tstorm_ag_context;
 	struct cstorm_iscsi_ag_context cstorm_ag_context;
 	struct ustorm_iscsi_ag_context ustorm_ag_context;
-	struct iscsi_timers_block_context timers_context;
+	struct timers_block_context timers_context;
 	struct regpair upb_context;
 	struct xstorm_iscsi_st_context xstorm_st_context;
 	struct regpair xpb_context;
@@ -2434,16 +2410,16 @@ struct l5cm_packet_size {
  * l5cm connection parameters
  */
 union l5cm_reduce_param_union {
-	u32 passive_side_scramble_key;
-	u32 pcs_id;
+	u32 opaque1;
+	u32 opaque2;
 };
 
 /*
  * l5cm connection parameters
  */
 struct l5cm_reduce_conn {
-	union l5cm_reduce_param_union param;
-	u32 isn;
+	union l5cm_reduce_param_union opaque1;
+	u32 opaque2;
 };
 
 /*
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 344c842..4018de1 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -138,6 +138,7 @@ struct cnic_irq {
 	unsigned int	vector;
 	void		*status_blk;
 	u32		status_blk_num;
+	u32		status_blk_num2;
 	u32		irq_flags;
 #define CNIC_IRQ_FL_MSIX		0x00000001
 };
@@ -152,6 +153,7 @@ struct cnic_eth_dev {
 	struct pci_dev	*pdev;
 	void __iomem	*io_base;
 	void __iomem	*io_base2;
+	void		*iro_arr;
 
 	u32		ctx_tbl_offset;
 	u32		ctx_tbl_len;
diff --git a/drivers/scsi/bnx2i/bnx2i.h b/drivers/scsi/bnx2i/bnx2i.h
index 00c0335..99568cb 100644
--- a/drivers/scsi/bnx2i/bnx2i.h
+++ b/drivers/scsi/bnx2i/bnx2i.h
@@ -58,6 +58,8 @@
 #define MAX_PAGES_PER_CTRL_STRUCT_POOL	8
 #define BNX2I_RESERVED_SLOW_PATH_CMD_SLOTS	4
 
+#define BNX2I_5771X_DBELL_PAGE_SIZE	128
+
 /* 5706/08 hardware has limit on maximum buffer size per BD it can handle */
 #define MAX_BD_LENGTH			65535
 #define BD_SPLIT_SIZE			32768
diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
index d23fc25..99c71e6 100644
--- a/drivers/scsi/bnx2i/bnx2i_hwi.c
+++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
@@ -2405,7 +2405,8 @@ int bnx2i_map_ep_dbell_regs(struct bnx2i_endpoint *ep)
 	if (test_bit(BNX2I_NX2_DEV_57710, &ep->hba->cnic_dev_type)) {
 		reg_base = pci_resource_start(ep->hba->pcidev,
 					      BNX2X_DOORBELL_PCI_BAR);
-		reg_off = PAGE_SIZE * (cid_num & 0x1FFFF) + DPM_TRIGER_TYPE;
+		reg_off = BNX2I_5771X_DBELL_PAGE_SIZE * (cid_num & 0x1FFFF) +
+			  DPM_TRIGER_TYPE;
 		ep->qp.ctx_base = ioremap_nocache(reg_base + reg_off, 4);
 		goto arm_cq;
 	}
diff --git a/firmware/Makefile b/firmware/Makefile
index 44b3aae..e0a3439 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -32,8 +32,8 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
-fw-shipped-$(CONFIG_BNX2X) += bnx2x/bnx2x-e1-5.2.13.0.fw \
-			      bnx2x/bnx2x-e1h-5.2.13.0.fw
+fw-shipped-$(CONFIG_BNX2X) += bnx2x/bnx2x-e1-6.0.34.0.fw \
+			      bnx2x/bnx2x-e1h-6.0.34.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-5.0.0.j15.fw \
 			     bnx2/bnx2-rv2p-09-5.0.0.j10.fw \
 			     bnx2/bnx2-rv2p-09ax-5.0.0.j10.fw \
-- 
1.7.1




