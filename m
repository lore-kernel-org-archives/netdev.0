From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 2/2] bnx2x: Support loading cnic resources at
 run-time
Date: Wed, 7 Nov 2012 12:45:48 +0200
Message-ID: <1352285148-21784-3-git-send-email-meravs@broadcom.com>
References: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	"Merav Sicron" <meravs@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2916 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871Ab2KGHgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 02:36:01 -0500
In-Reply-To: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the BCM_CNIC define with a flag which can change at run-time
and which does not use the CONFIG_CNIC kconfig option.
For the PF/hypervisor driver cnic is always supported, however allocation of
cnic resources and configuration of the HW for offload mode is done only when
the cnic module registers bnx2x.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  132 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  460 +++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   87 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    8 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |   29 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  837 ++++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |   16 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |   59 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |   12 +
 12 files changed, 1084 insertions(+), 565 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 72897c4..de121cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -34,18 +34,10 @@

 #include "bnx2x_hsi.h"

-#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
-#define BCM_CNIC 1
 #include "../cnic_if.h"
-#endif

-#ifdef BCM_CNIC
-#define BNX2X_MIN_MSIX_VEC_CNT 3
-#define BNX2X_MSIX_VEC_FP_START 2
-#else
-#define BNX2X_MIN_MSIX_VEC_CNT 2
-#define BNX2X_MSIX_VEC_FP_START 1
-#endif
+
+#define BNX2X_MIN_MSIX_VEC_CNT(bp)		((bp)->min_msix_vec_cnt)

 #include <linux/mdio.h>

@@ -256,15 +248,10 @@ enum {
 	/* FCoE L2 */
 #define	BNX2X_FCOE_ETH_CID(bp)		(BNX2X_CNIC_START_ETH_CID(bp) + 1)

-/** Additional rings budgeting */
-#ifdef BCM_CNIC
-#define CNIC_PRESENT			1
-#define FCOE_PRESENT			1
-#else
-#define CNIC_PRESENT			0
-#define FCOE_PRESENT			0
-#endif /* BCM_CNIC */
-#define NON_ETH_CONTEXT_USE	(FCOE_PRESENT)
+#define CNIC_SUPPORT(bp)		((bp)->cnic_support)
+#define CNIC_ENABLED(bp)		((bp)->cnic_enabled)
+#define CNIC_LOADED(bp)			((bp)->cnic_loaded)
+#define FCOE_INIT(bp)			((bp)->fcoe_init)

 #define AEU_IN_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR \
 	AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR
@@ -297,9 +284,7 @@ enum {
 	OOO_TXQ_IDX_OFFSET,
 };
 #define MAX_ETH_TXQ_IDX(bp)	(BNX2X_NUM_NON_CNIC_QUEUES(bp) * (bp)->max_cos)
-#ifdef BCM_CNIC
 #define FCOE_TXQ_IDX(bp)	(MAX_ETH_TXQ_IDX(bp) + FCOE_TXQ_IDX_OFFSET)
-#endif

 /* fast path */
 /*
@@ -585,15 +570,9 @@ struct bnx2x_fastpath {
 						->var)


-#define IS_ETH_FP(fp)			(fp->index < \
-					 BNX2X_NUM_ETH_QUEUES(fp->bp))
-#ifdef BCM_CNIC
-#define IS_FCOE_FP(fp)			(fp->index == FCOE_IDX(fp->bp))
-#define IS_FCOE_IDX(idx)		((idx) == FCOE_IDX(bp))
-#else
-#define IS_FCOE_FP(fp)		false
-#define IS_FCOE_IDX(idx)	false
-#endif
+#define IS_ETH_FP(fp)		((fp)->index < BNX2X_NUM_ETH_QUEUES((fp)->bp))
+#define IS_FCOE_FP(fp)		((fp)->index == FCOE_IDX((fp)->bp))
+#define IS_FCOE_IDX(idx)	((idx) == FCOE_IDX(bp))


 /* MC hsi */
@@ -886,6 +865,18 @@ struct bnx2x_common {
 					 (CHIP_REV(bp) == CHIP_REV_Bx))
 #define CHIP_IS_E3A0(bp)		(CHIP_IS_E3(bp) && \
 					 (CHIP_REV(bp) == CHIP_REV_Ax))
+/* This define is used in two main places:
+ * 1. In the early stages of nic_load, to know if to configrue Parser / Searcher
+ * to nic-only mode or to offload mode. Offload mode is configured if either the
+ * chip is E1x (where MIC_MODE register is not applicable), or if cnic already
+ * registered for this port (which means that the user wants storage services).
+ * 2. During cnic-related load, to know if offload mode is already configured in
+ * the HW or needs to be configrued.
+ * Since the transition from nic-mode to offload-mode in HW causes traffic
+ * coruption, nic-mode is configured only in ports on which storage services
+ * where never requested.
+ */
+#define CONFIGURE_NIC_MODE(bp)		(!CHIP_IS_E1x(bp) && !CNIC_ENABLED(bp))

 	int			flash_size;
 #define BNX2X_NVRAM_1MB_SIZE			0x20000	/* 1M bit in bytes */
@@ -1003,18 +994,15 @@ union cdu_context {
 #define CDU_ILT_PAGE_SZ		(8192 << CDU_ILT_PAGE_SZ_HW) /* 32K */
 #define ILT_PAGE_CIDS		(CDU_ILT_PAGE_SZ / sizeof(union cdu_context))

-#ifdef BCM_CNIC
 #define CNIC_ISCSI_CID_MAX	256
 #define CNIC_FCOE_CID_MAX	2048
 #define CNIC_CID_MAX		(CNIC_ISCSI_CID_MAX + CNIC_FCOE_CID_MAX)
 #define CNIC_ILT_LINES		DIV_ROUND_UP(CNIC_CID_MAX, ILT_PAGE_CIDS)
-#endif

 #define QM_ILT_PAGE_SZ_HW	0
 #define QM_ILT_PAGE_SZ		(4096 << QM_ILT_PAGE_SZ_HW) /* 4K */
 #define QM_CID_ROUND		1024

-#ifdef BCM_CNIC
 /* TM (timers) host DB constants */
 #define TM_ILT_PAGE_SZ_HW	0
 #define TM_ILT_PAGE_SZ		(4096 << TM_ILT_PAGE_SZ_HW) /* 4K */
@@ -1032,8 +1020,6 @@ union cdu_context {
 #define SRC_T2_SZ		SRC_ILT_SZ
 #define SRC_ILT_LINES		DIV_ROUND_UP(SRC_ILT_SZ, SRC_ILT_PAGE_SZ)

-#endif
-
 #define MAX_DMAE_C		8

 /* DMA memory not used in fastpath */
@@ -1227,7 +1213,6 @@ struct bnx2x {
 	struct bnx2x_sp_objs	*sp_objs;
 	struct bnx2x_fp_stats	*fp_stats;
 	struct bnx2x_fp_txdata	*bnx2x_txq;
-	int			bnx2x_txq_size;
 	void __iomem		*regview;
 	void __iomem		*doorbells;
 	u16			db_size;
@@ -1350,6 +1335,15 @@ struct bnx2x {
 #define NO_ISCSI_OOO(bp)	((bp)->flags & NO_ISCSI_OOO_FLAG)
 #define NO_FCOE(bp)		((bp)->flags & NO_FCOE_FLAG)

+	u8			cnic_support;
+	bool			cnic_enabled;
+	bool			cnic_loaded;
+
+	/* Flag that indicates that we can start looking for FCoE L2 queue
+	 * completions in the default status block.
+	 */
+	bool			fcoe_init;
+
 	int			pm_cap;
 	int			mrrs;

@@ -1420,6 +1414,8 @@ struct bnx2x {
 #define BNX2X_MAX_COS			3
 #define BNX2X_MAX_TX_COS		2
 	int			num_queues;
+	uint			num_ethernet_queues;
+	uint			num_cnic_queues;
 	int			num_napi_queues;
 	int			disable_tpa;

@@ -1433,6 +1429,7 @@ struct bnx2x {
 	u8			igu_dsb_id;
 	u8			igu_base_sb;
 	u8			igu_sb_cnt;
+	u8			min_msix_vec_cnt;

 	dma_addr_t		def_status_blk_mapping;

@@ -1478,16 +1475,16 @@ struct bnx2x {
  * Maximum supported number of RSS queues: number of IGU SBs minus one that goes
  * to CNIC.
  */
-#define BNX2X_MAX_RSS_COUNT(bp)	((bp)->igu_sb_cnt - CNIC_PRESENT)
+#define BNX2X_MAX_RSS_COUNT(bp)	((bp)->igu_sb_cnt - CNIC_SUPPORT(bp))

 /*
  * Maximum CID count that might be required by the bnx2x:
  * Max RSS * Max_Tx_Multi_Cos + FCoE + iSCSI
  */
 #define BNX2X_L2_CID_COUNT(bp)	(BNX2X_NUM_ETH_QUEUES(bp) * BNX2X_MULTI_TX_COS \
-				+ NON_ETH_CONTEXT_USE + CNIC_PRESENT)
+				+ 2 * CNIC_SUPPORT(bp))
 #define BNX2X_L2_MAX_CID(bp)	(BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS \
-				+ NON_ETH_CONTEXT_USE + CNIC_PRESENT)
+				+ 2 * CNIC_SUPPORT(bp))
 #define L2_ILT_LINES(bp)	(DIV_ROUND_UP(BNX2X_L2_CID_COUNT(bp),\
 					ILT_PAGE_CIDS))

@@ -1495,9 +1492,6 @@ struct bnx2x {

 	int			dropless_fc;

-#ifdef BCM_CNIC
-	u32			cnic_flags;
-#define BNX2X_CNIC_FLAG_MAC_SET		1
 	void			*t2;
 	dma_addr_t		t2_mapping;
 	struct cnic_ops	__rcu	*cnic_ops;
@@ -1518,7 +1512,6 @@ struct bnx2x {

 	/* Start index of the "special" (CNIC related) L2 cleints */
 	u8				cnic_base_cl_id;
-#endif

 	int			dmae_ready;
 	/* used to synchronize dmae accesses */
@@ -1647,9 +1640,9 @@ struct bnx2x {
 /* Tx queues may be less or equal to Rx queues */
 extern int num_queues;
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
-#define BNX2X_NUM_ETH_QUEUES(bp) (BNX2X_NUM_QUEUES(bp) - NON_ETH_CONTEXT_USE)
+#define BNX2X_NUM_ETH_QUEUES(bp) ((bp)->num_ethernet_queues)
 #define BNX2X_NUM_NON_CNIC_QUEUES(bp)	(BNX2X_NUM_QUEUES(bp) - \
-					 NON_ETH_CONTEXT_USE)
+					 (bp)->num_cnic_queues)
 #define BNX2X_NUM_RX_QUEUES(bp)	BNX2X_NUM_QUEUES(bp)

 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
@@ -1689,6 +1682,13 @@ struct bnx2x_func_init_params {
 	u16		spq_prod;	/* valid iff FUNC_FLG_SPQ */
 };

+#define for_each_cnic_queue(bp, var) \
+	for ((var) = BNX2X_NUM_ETH_QUEUES(bp); (var) < BNX2X_NUM_QUEUES(bp); \
+	     (var)++) \
+		if (skip_queue(bp, var))	\
+			continue;		\
+		else
+
 #define for_each_eth_queue(bp, var) \
 	for ((var) = 0; (var) < BNX2X_NUM_ETH_QUEUES(bp); (var)++)

@@ -1702,6 +1702,22 @@ struct bnx2x_func_init_params {
 		else

 /* Skip forwarding FP */
+#define for_each_valid_rx_queue(bp, var)			\
+	for ((var) = 0;						\
+	     (var) < (CNIC_LOADED(bp) ? BNX2X_NUM_QUEUES(bp) :	\
+		      BNX2X_NUM_ETH_QUEUES(bp));		\
+	     (var)++)						\
+		if (skip_rx_queue(bp, var))			\
+			continue;				\
+		else
+
+#define for_each_rx_queue_cnic(bp, var) \
+	for ((var) = BNX2X_NUM_ETH_QUEUES(bp); (var) < BNX2X_NUM_QUEUES(bp); \
+	     (var)++) \
+		if (skip_rx_queue(bp, var))	\
+			continue;		\
+		else
+
 #define for_each_rx_queue(bp, var) \
 	for ((var) = 0; (var) < BNX2X_NUM_QUEUES(bp); (var)++) \
 		if (skip_rx_queue(bp, var))	\
@@ -1709,6 +1725,22 @@ struct bnx2x_func_init_params {
 		else

 /* Skip OOO FP */
+#define for_each_valid_tx_queue(bp, var)			\
+	for ((var) = 0;						\
+	     (var) < (CNIC_LOADED(bp) ? BNX2X_NUM_QUEUES(bp) :	\
+		      BNX2X_NUM_ETH_QUEUES(bp));		\
+	     (var)++)						\
+		if (skip_tx_queue(bp, var))			\
+			continue;				\
+		else
+
+#define for_each_tx_queue_cnic(bp, var) \
+	for ((var) = BNX2X_NUM_ETH_QUEUES(bp); (var) < BNX2X_NUM_QUEUES(bp); \
+	     (var)++) \
+		if (skip_tx_queue(bp, var))	\
+			continue;		\
+		else
+
 #define for_each_tx_queue(bp, var) \
 	for ((var) = 0; (var) < BNX2X_NUM_QUEUES(bp); (var)++) \
 		if (skip_tx_queue(bp, var))	\
@@ -2179,7 +2211,6 @@ void bnx2x_notify_link_changed(struct bnx2x *bp);
 #define BNX2X_MF_SD_PROTOCOL(bp) \
 	((bp)->mf_config[BP_VN(bp)] & FUNC_MF_CFG_PROTOCOL_MASK)

-#ifdef BCM_CNIC
 #define BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) \
 	(BNX2X_MF_SD_PROTOCOL(bp) == FUNC_MF_CFG_PROTOCOL_ISCSI)

@@ -2196,9 +2227,12 @@ void bnx2x_notify_link_changed(struct bnx2x *bp);
 #define IS_MF_STORAGE_SD(bp) (IS_MF_SD(bp) && \
 				(BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) || \
 				 BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)))
-#else
-#define IS_MF_FCOE_AFEX(bp)	false
-#endif

+enum {
+	SWITCH_UPDATE,
+	AFEX_UPDATE,
+};
+
+#define NUM_MACS	8

 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4833b6a..54d522d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1152,6 +1152,25 @@ static void bnx2x_free_tpa_pool(struct bnx2x *bp,
 	}
 }

+void bnx2x_init_rx_rings_cnic(struct bnx2x *bp)
+{
+	int j;
+
+	for_each_rx_queue_cnic(bp, j) {
+		struct bnx2x_fastpath *fp = &bp->fp[j];
+
+		fp->rx_bd_cons = 0;
+
+		/* Activate BD ring */
+		/* Warning!
+		 * this will generate an interrupt (to the TSTORM)
+		 * must only be done after chip is initialized
+		 */
+		bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
+				     fp->rx_sge_prod);
+	}
+}
+
 void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
@@ -1159,7 +1178,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 	int i, j;

 	/* Allocate TPA resources */
-	for_each_rx_queue(bp, j) {
+	for_each_eth_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];

 		DP(NETIF_MSG_IFUP,
@@ -1217,7 +1236,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		}
 	}

-	for_each_rx_queue(bp, j) {
+	for_each_eth_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];

 		fp->rx_bd_cons = 0;
@@ -1244,29 +1263,45 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 	}
 }

-static void bnx2x_free_tx_skbs(struct bnx2x *bp)
+static void bnx2x_free_tx_skbs_queue(struct bnx2x_fastpath *fp)
 {
-	int i;
 	u8 cos;
+	struct bnx2x *bp = fp->bp;

-	for_each_tx_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-		for_each_cos_in_tx_queue(fp, cos) {
-			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
-			unsigned pkts_compl = 0, bytes_compl = 0;
+	for_each_cos_in_tx_queue(fp, cos) {
+		struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
+		unsigned pkts_compl = 0, bytes_compl = 0;

-			u16 sw_prod = txdata->tx_pkt_prod;
-			u16 sw_cons = txdata->tx_pkt_cons;
+		u16 sw_prod = txdata->tx_pkt_prod;
+		u16 sw_cons = txdata->tx_pkt_cons;

-			while (sw_cons != sw_prod) {
-				bnx2x_free_tx_pkt(bp, txdata, TX_BD(sw_cons),
-				    &pkts_compl, &bytes_compl);
-				sw_cons++;
-			}
-			netdev_tx_reset_queue(
-				netdev_get_tx_queue(bp->dev,
-						    txdata->txq_index));
+		while (sw_cons != sw_prod) {
+			bnx2x_free_tx_pkt(bp, txdata, TX_BD(sw_cons),
+					  &pkts_compl, &bytes_compl);
+			sw_cons++;
 		}
+
+		netdev_tx_reset_queue(
+			netdev_get_tx_queue(bp->dev,
+					    txdata->txq_index));
+	}
+}
+
+static void bnx2x_free_tx_skbs_cnic(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_tx_queue_cnic(bp, i) {
+		bnx2x_free_tx_skbs_queue(&bp->fp[i]);
+	}
+}
+
+static void bnx2x_free_tx_skbs(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_eth_queue(bp, i) {
+		bnx2x_free_tx_skbs_queue(&bp->fp[i]);
 	}
 }

@@ -1294,11 +1329,20 @@ static void bnx2x_free_rx_bds(struct bnx2x_fastpath *fp)
 	}
 }

+static void bnx2x_free_rx_skbs_cnic(struct bnx2x *bp)
+{
+	int j;
+
+	for_each_rx_queue_cnic(bp, j) {
+		bnx2x_free_rx_bds(&bp->fp[j]);
+	}
+}
+
 static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 {
 	int j;

-	for_each_rx_queue(bp, j) {
+	for_each_eth_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];

 		bnx2x_free_rx_bds(fp);
@@ -1308,6 +1352,12 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 	}
 }

+void bnx2x_free_skbs_cnic(struct bnx2x *bp)
+{
+	bnx2x_free_tx_skbs_cnic(bp);
+	bnx2x_free_rx_skbs_cnic(bp);
+}
+
 void bnx2x_free_skbs(struct bnx2x *bp)
 {
 	bnx2x_free_tx_skbs(bp);
@@ -1347,11 +1397,12 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp, int nvecs)
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
 	   bp->msix_table[offset].vector);
 	offset++;
-#ifdef BCM_CNIC
-	if (nvecs == offset)
-		return;
-	offset++;
-#endif
+
+	if (CNIC_SUPPORT(bp)) {
+		if (nvecs == offset)
+			return;
+		offset++;
+	}

 	for_each_eth_queue(bp, i) {
 		if (nvecs == offset)
@@ -1368,7 +1419,7 @@ void bnx2x_free_irq(struct bnx2x *bp)
 	if (bp->flags & USING_MSIX_FLAG &&
 	    !(bp->flags & USING_SINGLE_MSIX_FLAG))
 		bnx2x_free_msix_irqs(bp, BNX2X_NUM_ETH_QUEUES(bp) +
-				     CNIC_PRESENT + 1);
+				     CNIC_SUPPORT(bp) + 1);
 	else
 		free_irq(bp->dev->irq, bp->dev);
 }
@@ -1382,12 +1433,14 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 	   bp->msix_table[0].entry);
 	msix_vec++;

-#ifdef BCM_CNIC
-	bp->msix_table[msix_vec].entry = msix_vec;
-	BNX2X_DEV_INFO("msix_table[%d].entry = %d (CNIC)\n",
-	   bp->msix_table[msix_vec].entry, bp->msix_table[msix_vec].entry);
-	msix_vec++;
-#endif
+	/* Cnic requires an msix vector for itself */
+	if (CNIC_SUPPORT(bp)) {
+		bp->msix_table[msix_vec].entry = msix_vec;
+		BNX2X_DEV_INFO("msix_table[%d].entry = %d (CNIC)\n",
+			       msix_vec, bp->msix_table[msix_vec].entry);
+		msix_vec++;
+	}
+
 	/* We need separate vectors for ETH queues only (not FCoE) */
 	for_each_eth_queue(bp, i) {
 		bp->msix_table[msix_vec].entry = msix_vec;
@@ -1396,7 +1449,7 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		msix_vec++;
 	}

-	req_cnt = BNX2X_NUM_ETH_QUEUES(bp) + CNIC_PRESENT + 1;
+	req_cnt = BNX2X_NUM_ETH_QUEUES(bp) + CNIC_SUPPORT(bp) + 1;

 	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], req_cnt);

@@ -1404,7 +1457,7 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 	 * reconfigure number of tx/rx queues according to available
 	 * MSI-X vectors
 	 */
-	if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
+	if (rc >= BNX2X_MIN_MSIX_VEC_CNT(bp)) {
 		/* how less vectors we will have? */
 		int diff = req_cnt - rc;

@@ -1419,7 +1472,8 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		/*
 		 * decrease number of queues by number of unallocated entries
 		 */
-		bp->num_queues -= diff;
+		bp->num_ethernet_queues -= diff;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;

 		BNX2X_DEV_INFO("New queue configuration set: %d\n",
 			       bp->num_queues);
@@ -1435,6 +1489,9 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		BNX2X_DEV_INFO("Using single MSI-X vector\n");
 		bp->flags |= USING_SINGLE_MSIX_FLAG;

+		BNX2X_DEV_INFO("set number of queues to 1\n");
+		bp->num_ethernet_queues = 1;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
 	} else if (rc < 0) {
 		BNX2X_DEV_INFO("MSI-X is not attainable  rc %d\n", rc);
 		goto no_msix;
@@ -1464,9 +1521,9 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		return -EBUSY;
 	}

-#ifdef BCM_CNIC
-	offset++;
-#endif
+	if (CNIC_SUPPORT(bp))
+		offset++;
+
 	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
@@ -1485,7 +1542,7 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	}

 	i = BNX2X_NUM_ETH_QUEUES(bp);
-	offset = 1 + CNIC_PRESENT;
+	offset = 1 + CNIC_SUPPORT(bp);
 	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d ... fp[%d] %d\n",
 	       bp->msix_table[0].vector,
 	       0, bp->msix_table[offset].vector,
@@ -1556,19 +1613,35 @@ static int bnx2x_setup_irqs(struct bnx2x *bp)
 	return 0;
 }

+static void bnx2x_napi_enable_cnic(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_rx_queue_cnic(bp, i)
+		napi_enable(&bnx2x_fp(bp, i, napi));
+}
+
 static void bnx2x_napi_enable(struct bnx2x *bp)
 {
 	int i;

-	for_each_rx_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 }

+static void bnx2x_napi_disable_cnic(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_rx_queue_cnic(bp, i)
+		napi_disable(&bnx2x_fp(bp, i, napi));
+}
+
 static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;

-	for_each_rx_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
 }

@@ -1576,6 +1649,8 @@ void bnx2x_netif_start(struct bnx2x *bp)
 {
 	if (netif_running(bp->dev)) {
 		bnx2x_napi_enable(bp);
+		if (CNIC_LOADED(bp))
+			bnx2x_napi_enable_cnic(bp);
 		bnx2x_int_enable(bp);
 		if (bp->state == BNX2X_STATE_OPEN)
 			netif_tx_wake_all_queues(bp->dev);
@@ -1586,14 +1661,15 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 {
 	bnx2x_int_disable_sync(bp, disable_hw);
 	bnx2x_napi_disable(bp);
+	if (CNIC_LOADED(bp))
+		bnx2x_napi_disable_cnic(bp);
 }

 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct bnx2x *bp = netdev_priv(dev);

-#ifdef BCM_CNIC
-	if (!NO_FCOE(bp)) {
+	if (CNIC_LOADED(bp) && !NO_FCOE(bp)) {
 		struct ethhdr *hdr = (struct ethhdr *)skb->data;
 		u16 ether_type = ntohs(hdr->h_proto);

@@ -1609,7 +1685,7 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 		if ((ether_type == ETH_P_FCOE) || (ether_type == ETH_P_FIP))
 			return bnx2x_fcoe_tx(bp, txq_index);
 	}
-#endif
+
 	/* select a non-FCoE queue */
 	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp));
 }
@@ -1618,15 +1694,15 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 void bnx2x_set_num_queues(struct bnx2x *bp)
 {
 	/* RSS queues */
-	bp->num_queues = bnx2x_calc_num_queues(bp);
+	bp->num_ethernet_queues = bnx2x_calc_num_queues(bp);

-#ifdef BCM_CNIC
 	/* override in STORAGE SD modes */
 	if (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))
-		bp->num_queues = 1;
-#endif
+		bp->num_ethernet_queues = 1;
+
 	/* Add special queues */
-	bp->num_queues += NON_ETH_CONTEXT_USE;
+	bp->num_cnic_queues = CNIC_SUPPORT(bp); /* For FCOE */
+	bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;

 	BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
 }
@@ -1653,20 +1729,18 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
  * bnx2x_setup_tc() takes care of the proper TC mappings so that __skb_tx_hash()
  * will return a proper Tx index if TC is enabled (netdev->num_tc > 0).
  */
-static int bnx2x_set_real_num_queues(struct bnx2x *bp)
+static int bnx2x_set_real_num_queues(struct bnx2x *bp, int include_cnic)
 {
 	int rc, tx, rx;

 	tx = BNX2X_NUM_ETH_QUEUES(bp) * bp->max_cos;
-	rx = BNX2X_NUM_QUEUES(bp) - NON_ETH_CONTEXT_USE;
+	rx = BNX2X_NUM_ETH_QUEUES(bp);

 /* account for fcoe queue */
-#ifdef BCM_CNIC
-	if (!NO_FCOE(bp)) {
-		rx += FCOE_PRESENT;
-		tx += FCOE_PRESENT;
+	if (include_cnic && !NO_FCOE(bp)) {
+		rx++;
+		tx++;
 	}
-#endif

 	rc = netif_set_real_num_tx_queues(bp->dev, tx);
 	if (rc) {
@@ -1859,14 +1933,26 @@ static void bnx2x_squeeze_objects(struct bnx2x *bp)
 		(bp)->state = BNX2X_STATE_ERROR; \
 		goto label; \
 	} while (0)
-#else
+
+#define LOAD_ERROR_EXIT_CNIC(bp, label) \
+	do { \
+		bp->cnic_loaded = false; \
+		goto label; \
+	} while (0)
+#else /*BNX2X_STOP_ON_ERROR*/
 #define LOAD_ERROR_EXIT(bp, label) \
 	do { \
 		(bp)->state = BNX2X_STATE_ERROR; \
 		(bp)->panic = 1; \
 		return -EBUSY; \
 	} while (0)
-#endif
+#define LOAD_ERROR_EXIT_CNIC(bp, label) \
+	do { \
+		bp->cnic_loaded = false; \
+		(bp)->panic = 1; \
+		return -EBUSY; \
+	} while (0)
+#endif /*BNX2X_STOP_ON_ERROR*/

 bool bnx2x_test_firmware_version(struct bnx2x *bp, bool is_err)
 {
@@ -1959,10 +2045,8 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 		fp->max_cos = 1;

 	/* Init txdata pointers */
-#ifdef BCM_CNIC
 	if (IS_FCOE_FP(fp))
 		fp->txdata_ptr[0] = &bp->bnx2x_txq[FCOE_TXQ_IDX(bp)];
-#endif
 	if (IS_ETH_FP(fp))
 		for_each_cos_in_tx_queue(fp, cos)
 			fp->txdata_ptr[cos] = &bp->bnx2x_txq[cos *
@@ -1980,11 +2064,95 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	else if (bp->flags & GRO_ENABLE_FLAG)
 		fp->mode = TPA_MODE_GRO;

-#ifdef BCM_CNIC
 	/* We don't want TPA on an FCoE L2 ring */
 	if (IS_FCOE_FP(fp))
 		fp->disable_tpa = 1;
-#endif
+}
+
+int bnx2x_load_cnic(struct bnx2x *bp)
+{
+	int i, rc, port = BP_PORT(bp);
+
+	DP(NETIF_MSG_IFUP, "Starting CNIC-related load\n");
+
+	mutex_init(&bp->cnic_mutex);
+
+	rc = bnx2x_alloc_mem_cnic(bp);
+	if (rc) {
+		BNX2X_ERR("Unable to allocate bp memory for cnic\n");
+		LOAD_ERROR_EXIT_CNIC(bp, load_error_cnic0);
+	}
+
+	rc = bnx2x_alloc_fp_mem_cnic(bp);
+	if (rc) {
+		BNX2X_ERR("Unable to allocate memory for cnic fps\n");
+		LOAD_ERROR_EXIT_CNIC(bp, load_error_cnic0);
+	}
+
+	/* Update the number of queues with the cnic queues */
+	rc = bnx2x_set_real_num_queues(bp, 1);
+	if (rc) {
+		BNX2X_ERR("Unable to set real_num_queues including cnic\n");
+		LOAD_ERROR_EXIT_CNIC(bp, load_error_cnic0);
+	}
+
+	/* Add all CNIC NAPI objects */
+	bnx2x_add_all_napi_cnic(bp);
+	DP(NETIF_MSG_IFUP, "cnic napi added\n");
+	bnx2x_napi_enable_cnic(bp);
+
+	rc = bnx2x_init_hw_func_cnic(bp);
+	if (rc)
+		LOAD_ERROR_EXIT_CNIC(bp, load_error_cnic1);
+
+	bnx2x_nic_init_cnic(bp);
+
+	/* Enable Timer scan */
+	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 1);
+
+	for_each_cnic_queue(bp, i) {
+		rc = bnx2x_setup_queue(bp, &bp->fp[i], 0);
+		if (rc) {
+			BNX2X_ERR("Queue setup failed\n");
+			LOAD_ERROR_EXIT(bp, load_error_cnic2);
+		}
+	}
+
+	/* Initialize Rx filter. */
+	netif_addr_lock_bh(bp->dev);
+	bnx2x_set_rx_mode(bp->dev);
+	netif_addr_unlock_bh(bp->dev);
+
+	/* re-read iscsi info */
+	bnx2x_get_iscsi_info(bp);
+	bnx2x_setup_cnic_irq_info(bp);
+	bnx2x_setup_cnic_info(bp);
+	bp->cnic_loaded = true;
+	if (bp->state == BNX2X_STATE_OPEN)
+		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
+
+
+	DP(NETIF_MSG_IFUP, "Ending successfully CNIC-related load\n");
+
+	return 0;
+
+#ifndef BNX2X_STOP_ON_ERROR
+load_error_cnic2:
+	/* Disable Timer scan */
+	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
+
+load_error_cnic1:
+	bnx2x_napi_disable_cnic(bp);
+	/* Update the number of queues without the cnic queues */
+	rc = bnx2x_set_real_num_queues(bp, 0);
+	if (rc)
+		BNX2X_ERR("Unable to set real_num_queues not including cnic\n");
+load_error_cnic0:
+	BNX2X_ERR("CNIC-related load failed\n");
+	bnx2x_free_fp_mem_cnic(bp);
+	bnx2x_free_mem_cnic(bp);
+	return rc;
+#endif /* ! BNX2X_STOP_ON_ERROR */
 }


@@ -1995,6 +2163,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	u32 load_code;
 	int i, rc;

+	DP(NETIF_MSG_IFUP, "Starting NIC load\n");
+	DP(NETIF_MSG_IFUP,
+	   "CNIC is %s\n", CNIC_ENABLED(bp) ? "enabled" : "disabled");
+
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic)) {
 		BNX2X_ERR("Can't load NIC when there is panic\n");
@@ -2022,9 +2194,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	DP(NETIF_MSG_IFUP, "num queues: %d", bp->num_queues);
 	for_each_queue(bp, i)
 		bnx2x_bz_fp(bp, i);
-	memset(bp->bnx2x_txq, 0, bp->bnx2x_txq_size *
-	       sizeof(struct bnx2x_fp_txdata));
+	memset(bp->bnx2x_txq, 0, (BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS +
+				  bp->num_cnic_queues) *
+				  sizeof(struct bnx2x_fp_txdata));

+	bp->fcoe_init = false;

 	/* Set the receive queues buffer size */
 	bnx2x_set_rx_buf_size(bp);
@@ -2034,9 +2208,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)

 	/* As long as bnx2x_alloc_mem() may possibly update
 	 * bp->num_queues, bnx2x_set_real_num_queues() should always
-	 * come after it.
+	 * come after it. At this stage cnic queues are not counted.
 	 */
-	rc = bnx2x_set_real_num_queues(bp);
+	rc = bnx2x_set_real_num_queues(bp, 0);
 	if (rc) {
 		BNX2X_ERR("Unable to set real_num_queues\n");
 		LOAD_ERROR_EXIT(bp, load_error0);
@@ -2050,6 +2224,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)

 	/* Add all NAPI objects */
 	bnx2x_add_all_napi(bp);
+	DP(NETIF_MSG_IFUP, "napi added\n");
 	bnx2x_napi_enable(bp);

 	/* set pf load just before approaching the MCP */
@@ -2191,23 +2366,18 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		LOAD_ERROR_EXIT(bp, load_error3);
 	}

-#ifdef BCM_CNIC
-	/* Enable Timer scan */
-	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 1);
-#endif
-
-	for_each_nondefault_queue(bp, i) {
+	for_each_nondefault_eth_queue(bp, i) {
 		rc = bnx2x_setup_queue(bp, &bp->fp[i], 0);
 		if (rc) {
 			BNX2X_ERR("Queue setup failed\n");
-			LOAD_ERROR_EXIT(bp, load_error4);
+			LOAD_ERROR_EXIT(bp, load_error3);
 		}
 	}

 	rc = bnx2x_init_rss_pf(bp);
 	if (rc) {
 		BNX2X_ERR("PF RSS init failed\n");
-		LOAD_ERROR_EXIT(bp, load_error4);
+		LOAD_ERROR_EXIT(bp, load_error3);
 	}

 	/* Now when Clients are configured we are ready to work */
@@ -2217,7 +2387,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_set_eth_mac(bp, true);
 	if (rc) {
 		BNX2X_ERR("Setting Ethernet MAC failed\n");
-		LOAD_ERROR_EXIT(bp, load_error4);
+		LOAD_ERROR_EXIT(bp, load_error3);
 	}

 	if (bp->pending_max) {
@@ -2264,14 +2434,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* start the timer */
 	mod_timer(&bp->timer, jiffies + bp->current_interval);

-#ifdef BCM_CNIC
-	/* re-read iscsi info */
-	bnx2x_get_iscsi_info(bp);
-	bnx2x_setup_cnic_irq_info(bp);
-	bnx2x_setup_cnic_info(bp);
-	if (bp->state == BNX2X_STATE_OPEN)
-		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
-#endif
+	if (CNIC_ENABLED(bp))
+		bnx2x_load_cnic(bp);

 	/* mark driver is loaded in shmem2 */
 	if (SHMEM2_HAS(bp, drv_capabilities_flag)) {
@@ -2293,14 +2457,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (bp->port.pmf && (bp->state != BNX2X_STATE_DIAG))
 		bnx2x_dcbx_init(bp, false);

+	DP(NETIF_MSG_IFUP, "Ending successfully NIC load\n");
+
 	return 0;

 #ifndef BNX2X_STOP_ON_ERROR
-load_error4:
-#ifdef BCM_CNIC
-	/* Disable Timer scan */
-	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
-#endif
 load_error3:
 	bnx2x_int_disable_sync(bp, 1);

@@ -2338,6 +2499,8 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 	int i;
 	bool global = false;

+	DP(NETIF_MSG_IFUP, "Starting NIC unload\n");
+
 	/* mark driver is unloaded in shmem2 */
 	if (SHMEM2_HAS(bp, drv_capabilities_flag)) {
 		u32 val;
@@ -2373,14 +2536,13 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 	smp_mb();

+	if (CNIC_LOADED(bp))
+		bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
+
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);
 	netdev_reset_tc(bp->dev);

-#ifdef BCM_CNIC
-	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
-#endif
-
 	bp->rx_mode = BNX2X_RX_MODE_NONE;

 	del_timer_sync(&bp->timer);
@@ -2414,7 +2576,8 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 		bnx2x_netif_stop(bp, 1);
 		/* Delete all NAPI objects */
 		bnx2x_del_all_napi(bp);
-
+		if (CNIC_LOADED(bp))
+			bnx2x_del_all_napi_cnic(bp);
 		/* Release IRQs */
 		bnx2x_free_irq(bp);

@@ -2435,12 +2598,19 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)

 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
+	if (CNIC_LOADED(bp))
+		bnx2x_free_skbs_cnic(bp);
 	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);

+	if (CNIC_LOADED(bp)) {
+		bnx2x_free_fp_mem_cnic(bp);
+		bnx2x_free_mem_cnic(bp);
+	}
 	bnx2x_free_mem(bp);

 	bp->state = BNX2X_STATE_CLOSED;
+	bp->cnic_loaded = false;

 	/* Check if there are pending parity attentions. If there are - set
 	 * RECOVERY_IN_PROGRESS.
@@ -2460,6 +2630,8 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 	if (!bnx2x_clear_pf_load(bp) && bnx2x_reset_is_done(bp, BP_PATH(bp)))
 		bnx2x_disable_close_the_gate(bp);

+	DP(NETIF_MSG_IFUP, "Ending NIC unload\n");
+
 	return 0;
 }

@@ -2550,7 +2722,7 @@ int bnx2x_poll(struct napi_struct *napi, int budget)

 		/* Fall out from the NAPI loop if needed */
 		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
-#ifdef BCM_CNIC
+
 			/* No need to update SB for FCoE L2 ring as long as
 			 * it's connected to the default SB and the SB
 			 * has been updated when NAPI was scheduled.
@@ -2559,8 +2731,6 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 				napi_complete(napi);
 				break;
 			}
-#endif
-
 			bnx2x_update_fpsb_idx(fp);
 			/* bnx2x_has_rx_work() reads the status block,
 			 * thus we need to ensure that status block indices
@@ -2940,7 +3110,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq_index = skb_get_queue_mapping(skb);
 	txq = netdev_get_tx_queue(dev, txq_index);

-	BUG_ON(txq_index >= MAX_ETH_TXQ_IDX(bp) + FCOE_PRESENT);
+	BUG_ON(txq_index >= MAX_ETH_TXQ_IDX(bp) + (CNIC_LOADED(bp) ? 1 : 0));

 	txdata = &bp->bnx2x_txq[txq_index];

@@ -3339,13 +3509,11 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 		return -EINVAL;
 	}

-#ifdef BCM_CNIC
 	if ((IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)) &&
 	    !is_zero_ether_addr(addr->sa_data)) {
 		BNX2X_ERR("Can't configure non-zero address on iSCSI or FCoE functions in MF-SD mode\n");
 		return -EINVAL;
 	}
-#endif

 	if (netif_running(dev))  {
 		rc = bnx2x_set_eth_mac(bp, false);
@@ -3369,13 +3537,11 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
 	u8 cos;

 	/* Common */
-#ifdef BCM_CNIC
+
 	if (IS_FCOE_IDX(fp_index)) {
 		memset(sb, 0, sizeof(union host_hc_status_block));
 		fp->status_blk_mapping = 0;
-
 	} else {
-#endif
 		/* status blocks */
 		if (!CHIP_IS_E1x(bp))
 			BNX2X_PCI_FREE(sb->e2_sb,
@@ -3387,9 +3553,8 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
 				       bnx2x_fp(bp, fp_index,
 						status_blk_mapping),
 				       sizeof(struct host_hc_status_block_e1x));
-#ifdef BCM_CNIC
 	}
-#endif
+
 	/* Rx */
 	if (!skip_rx_queue(bp, fp_index)) {
 		bnx2x_free_rx_bds(fp);
@@ -3431,10 +3596,17 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
 	/* end of fastpath */
 }

+void bnx2x_free_fp_mem_cnic(struct bnx2x *bp)
+{
+	int i;
+	for_each_cnic_queue(bp, i)
+		bnx2x_free_fp_mem_at(bp, i);
+}
+
 void bnx2x_free_fp_mem(struct bnx2x *bp)
 {
 	int i;
-	for_each_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		bnx2x_free_fp_mem_at(bp, i);
 }

@@ -3519,14 +3691,11 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	u8 cos;
 	int rx_ring_size = 0;

-#ifdef BCM_CNIC
 	if (!bp->rx_ring_size &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
 		rx_ring_size = MIN_RX_SIZE_NONTPA;
 		bp->rx_ring_size = rx_ring_size;
-	} else
-#endif
-	if (!bp->rx_ring_size) {
+	} else if (!bp->rx_ring_size) {
 		rx_ring_size = MAX_RX_AVAIL/BNX2X_NUM_RX_QUEUES(bp);

 		if (CHIP_IS_E3(bp)) {
@@ -3550,9 +3719,8 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)

 	/* Common */
 	sb = &bnx2x_fp(bp, index, status_blk);
-#ifdef BCM_CNIC
+
 	if (!IS_FCOE_IDX(index)) {
-#endif
 		/* status blocks */
 		if (!CHIP_IS_E1x(bp))
 			BNX2X_PCI_ALLOC(sb->e2_sb,
@@ -3562,9 +3730,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 			BNX2X_PCI_ALLOC(sb->e1x_sb,
 				&bnx2x_fp(bp, index, status_blk_mapping),
 			    sizeof(struct host_hc_status_block_e1x));
-#ifdef BCM_CNIC
 	}
-#endif

 	/* FCoE Queue uses Default SB and doesn't ACK the SB, thus no need to
 	 * set shortcuts for it.
@@ -3641,31 +3807,31 @@ alloc_mem_err:
 	return 0;
 }

+int bnx2x_alloc_fp_mem_cnic(struct bnx2x *bp)
+{
+	if (!NO_FCOE(bp))
+		/* FCoE */
+		if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX(bp)))
+			/* we will fail load process instead of mark
+			 * NO_FCOE_FLAG
+			 */
+			return -ENOMEM;
+
+	return 0;
+}
+
 int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 {
 	int i;

-	/**
-	 * 1. Allocate FP for leading - fatal if error
-	 * 2. {CNIC} Allocate FCoE FP - fatal if error
-	 * 3. {CNIC} Allocate OOO + FWD - disable OOO if error
-	 * 4. Allocate RSS - fix number of queues if error
+	/* 1. Allocate FP for leading - fatal if error
+	 * 2. Allocate RSS - fix number of queues if error
 	 */

 	/* leading */
 	if (bnx2x_alloc_fp_mem_at(bp, 0))
 		return -ENOMEM;

-#ifdef BCM_CNIC
-	if (!NO_FCOE(bp))
-		/* FCoE */
-		if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX(bp)))
-			/* we will fail load process instead of mark
-			 * NO_FCOE_FLAG
-			 */
-			return -ENOMEM;
-#endif
-
 	/* RSS */
 	for_each_nondefault_eth_queue(bp, i)
 		if (bnx2x_alloc_fp_mem_at(bp, i))
@@ -3676,17 +3842,17 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 		int delta = BNX2X_NUM_ETH_QUEUES(bp) - i;

 		WARN_ON(delta < 0);
-#ifdef BCM_CNIC
-		/**
-		 * move non eth FPs next to last eth FP
-		 * must be done in that order
-		 * FCOE_IDX < FWD_IDX < OOO_IDX
-		 */
+		if (CNIC_SUPPORT(bp))
+			/* move non eth FPs next to last eth FP
+			 * must be done in that order
+			 * FCOE_IDX < FWD_IDX < OOO_IDX
+			 */

-		/* move FCoE fp even NO_FCOE_FLAG is on */
-		bnx2x_move_fp(bp, FCOE_IDX(bp), FCOE_IDX(bp) - delta);
-#endif
-		bp->num_queues -= delta;
+			/* move FCoE fp even NO_FCOE_FLAG is on */
+			bnx2x_move_fp(bp, FCOE_IDX(bp), FCOE_IDX(bp) - delta);
+		bp->num_ethernet_queues -= delta;
+		bp->num_queues = bp->num_ethernet_queues +
+				 bp->num_cnic_queues;
 		BNX2X_ERR("Adjusted num of queues from %d to %d\n",
 			  bp->num_queues + delta, bp->num_queues);
 	}
@@ -3711,7 +3877,7 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 	struct msix_entry *tbl;
 	struct bnx2x_ilt *ilt;
 	int msix_table_size = 0;
-	int fp_array_size;
+	int fp_array_size, txq_array_size;
 	int i;

 	/*
@@ -3721,7 +3887,7 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 	msix_table_size = bp->igu_sb_cnt + 1;

 	/* fp array: RSS plus CNIC related L2 queues */
-	fp_array_size = BNX2X_MAX_RSS_COUNT(bp) + NON_ETH_CONTEXT_USE;
+	fp_array_size = BNX2X_MAX_RSS_COUNT(bp) + CNIC_SUPPORT(bp);
 	BNX2X_DEV_INFO("fp_array_size %d", fp_array_size);

 	fp = kcalloc(fp_array_size, sizeof(*fp), GFP_KERNEL);
@@ -3750,12 +3916,12 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 		goto alloc_err;

 	/* Allocate memory for the transmission queues array */
-	bp->bnx2x_txq_size = BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS;
-#ifdef BCM_CNIC
-	bp->bnx2x_txq_size++;
-#endif
-	bp->bnx2x_txq = kcalloc(bp->bnx2x_txq_size,
-				sizeof(struct bnx2x_fp_txdata), GFP_KERNEL);
+	txq_array_size =
+		BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS + CNIC_SUPPORT(bp);
+	BNX2X_DEV_INFO("txq_array_size %d", txq_array_size);
+
+	bp->bnx2x_txq = kcalloc(txq_array_size, sizeof(struct bnx2x_fp_txdata),
+				GFP_KERNEL);
 	if (!bp->bnx2x_txq)
 		goto alloc_err;

@@ -3838,7 +4004,7 @@ int bnx2x_get_link_cfg_idx(struct bnx2x *bp)
 	return LINK_CONFIG_IDX(sel_phy_idx);
 }

-#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
+#ifdef NETDEV_FCOE_WWNN
 int bnx2x_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
 {
 	struct bnx2x *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 9c5ea6c..ad28074 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -238,7 +238,6 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance);
  * @dev_instance:	private instance
  */
 irqreturn_t bnx2x_interrupt(int irq, void *dev_instance);
-#ifdef BCM_CNIC

 /**
  * bnx2x_cnic_notify - send command to cnic driver
@@ -262,8 +261,6 @@ void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
  */
 void bnx2x_setup_cnic_info(struct bnx2x *bp);

-#endif
-
 /**
  * bnx2x_int_enable - enable HW interrupts.
  *
@@ -283,7 +280,7 @@ void bnx2x_int_enable(struct bnx2x *bp);
 void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw);

 /**
- * bnx2x_nic_init - init driver internals.
+ * bnx2x_nic_init_cnic - init driver internals for cnic.
  *
  * @bp:		driver handle
  * @load_code:	COMMON, PORT or FUNCTION
@@ -293,9 +290,26 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw);
  *  - status blocks
  *  - etc.
  */
-void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
+void bnx2x_nic_init_cnic(struct bnx2x *bp);

 /**
+ * bnx2x_nic_init - init driver internals.
+ *
+ * @bp:		driver handle
+ *
+ * Initializes:
+ *  - rings
+ *  - status blocks
+ *  - etc.
+ */
+void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
+/**
+ * bnx2x_alloc_mem_cnic - allocate driver's memory for cnic.
+ *
+ * @bp:		driver handle
+ */
+int bnx2x_alloc_mem_cnic(struct bnx2x *bp);
+/**
  * bnx2x_alloc_mem - allocate driver's memory.
  *
  * @bp:		driver handle
@@ -303,6 +317,12 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
 int bnx2x_alloc_mem(struct bnx2x *bp);

 /**
+ * bnx2x_free_mem_cnic - release driver's memory for cnic.
+ *
+ * @bp:		driver handle
+ */
+void bnx2x_free_mem_cnic(struct bnx2x *bp);
+/**
  * bnx2x_free_mem - release driver's memory.
  *
  * @bp:		driver handle
@@ -407,6 +427,7 @@ bool bnx2x_reset_is_done(struct bnx2x *bp, int engine);
 void bnx2x_set_reset_in_progress(struct bnx2x *bp);
 void bnx2x_set_reset_global(struct bnx2x *bp);
 void bnx2x_disable_close_the_gate(struct bnx2x *bp);
+int bnx2x_init_hw_func_cnic(struct bnx2x *bp);

 /**
  * bnx2x_sp_event - handle ramrods completion.
@@ -424,6 +445,14 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe);
 void bnx2x_ilt_set_info(struct bnx2x *bp);

 /**
+ * bnx2x_ilt_set_cnic_info - prepare ILT configurations for SRC
+ * and TM.
+ *
+ * @bp:		driver handle
+ */
+void bnx2x_ilt_set_info_cnic(struct bnx2x *bp);
+
+/**
  * bnx2x_dcbx_init - initialize dcbx protocol.
  *
  * @bp:		driver handle
@@ -491,12 +520,17 @@ int bnx2x_resume(struct pci_dev *pdev);
 /* Release IRQ vectors */
 void bnx2x_free_irq(struct bnx2x *bp);

+void bnx2x_free_fp_mem_cnic(struct bnx2x *bp);
 void bnx2x_free_fp_mem(struct bnx2x *bp);
+int bnx2x_alloc_fp_mem_cnic(struct bnx2x *bp);
 int bnx2x_alloc_fp_mem(struct bnx2x *bp);
 void bnx2x_init_rx_rings(struct bnx2x *bp);
+void bnx2x_init_rx_rings_cnic(struct bnx2x *bp);
+void bnx2x_free_skbs_cnic(struct bnx2x *bp);
 void bnx2x_free_skbs(struct bnx2x *bp);
 void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
 void bnx2x_netif_start(struct bnx2x *bp);
+int bnx2x_load_cnic(struct bnx2x *bp);

 /**
  * bnx2x_enable_msix - set msix configuration.
@@ -547,7 +581,7 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
  */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu);

-#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
+#ifdef NETDEV_FCOE_WWNN
 /**
  * bnx2x_fcoe_get_wwn - return the requested WWN value for this port
  *
@@ -793,23 +827,39 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	sge->addr_lo = 0;
 }

-static inline void bnx2x_add_all_napi(struct bnx2x *bp)
+static inline void bnx2x_add_all_napi_cnic(struct bnx2x *bp)
 {
 	int i;

-	bp->num_napi_queues = bp->num_queues;
+	/* Add NAPI objects */
+	for_each_rx_queue_cnic(bp, i)
+		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
+			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
+}
+
+static inline void bnx2x_add_all_napi(struct bnx2x *bp)
+{
+	int i;

 	/* Add NAPI objects */
-	for_each_rx_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
 }

+static inline void bnx2x_del_all_napi_cnic(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_rx_queue_cnic(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
+}
+
 static inline void bnx2x_del_all_napi(struct bnx2x *bp)
 {
 	int i;

-	for_each_rx_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 }

@@ -979,11 +1029,9 @@ static inline u8 bnx2x_stats_id(struct bnx2x_fastpath *fp)
 {
 	struct bnx2x *bp = fp->bp;
 	if (!CHIP_IS_E1x(bp)) {
-#ifdef BCM_CNIC
 		/* there are special statistics counters for FCoE 136..140 */
 		if (IS_FCOE_FP(fp))
 			return bp->cnic_base_cl_id + (bp->pf_num >> 1);
-#endif
 		return fp->cl_id;
 	}
 	return fp->cl_id + BP_PORT(bp) * FP_SB_MAX_E1x;
@@ -1102,7 +1150,6 @@ static inline void bnx2x_init_txdata(struct bnx2x *bp,
 	   txdata->cid, txdata->txq_index);
 }

-#ifdef BCM_CNIC
 static inline u8 bnx2x_cnic_eth_cl_id(struct bnx2x *bp, u8 cl_idx)
 {
 	return bp->cnic_base_cl_id + cl_idx +
@@ -1162,7 +1209,6 @@ static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 	   fp->index, bp, fp->status_blk.e2_sb, fp->cl_id, fp->fw_sb_id,
 	   fp->igu_sb_id);
 }
-#endif

 static inline int bnx2x_clean_tx_queue(struct bnx2x *bp,
 				       struct bnx2x_fp_txdata *txdata)
@@ -1280,7 +1326,7 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
 	 */
 	return mtu <= SGE_PAGE_SIZE && (U_ETH_SGL_SIZE * fpp) <= MAX_SKB_FRAGS;
 }
-#ifdef BCM_CNIC
+
 /**
  * bnx2x_get_iscsi_info - update iSCSI params according to licensing info.
  *
@@ -1288,7 +1334,6 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
  *
  */
 void bnx2x_get_iscsi_info(struct bnx2x *bp);
-#endif

 /**
  * bnx2x_link_sync_notify - send notification to other functions.
@@ -1340,13 +1385,11 @@ static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)

 static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
 {
-	if (is_valid_ether_addr(addr))
+	if (is_valid_ether_addr(addr) ||
+	    (is_zero_ether_addr(addr) &&
+	     (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))))
 		return true;
-#ifdef BCM_CNIC
-	if (is_zero_ether_addr(addr) &&
-	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)))
-		return true;
-#endif
+
 	return false;
 }

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 2245c38..cba4a16 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1908,10 +1908,10 @@ static void bnx2x_dcbnl_get_perm_hw_addr(struct net_device *netdev,
 	/* first the HW mac address */
 	memcpy(perm_addr, netdev->dev_addr, netdev->addr_len);

-#ifdef BCM_CNIC
-	/* second SAN address */
-	memcpy(perm_addr+netdev->addr_len, bp->fip_mac, netdev->addr_len);
-#endif
+	if (CNIC_LOADED(bp))
+		/* second SAN address */
+		memcpy(perm_addr+netdev->addr_len, bp->fip_mac,
+		       netdev->addr_len);
 }

 static void bnx2x_dcbnl_set_pg_tccfg_tx(struct net_device *netdev, int prio,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c65295d..ec3f9e5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2901,7 +2901,9 @@ static void bnx2x_get_channels(struct net_device *dev,
 static void bnx2x_change_num_queues(struct bnx2x *bp, int num_rss)
 {
 	bnx2x_disable_msi(bp);
-	BNX2X_NUM_QUEUES(bp) = num_rss + NON_ETH_CONTEXT_USE;
+	bp->num_ethernet_queues = num_rss;
+	bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
+	BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
 	bnx2x_set_int_mode(bp);
 }

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index fe66d90..d755acf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -648,15 +648,25 @@ static int bnx2x_ilt_client_mem_op(struct bnx2x *bp, int cli_num,
 	return rc;
 }

+static int bnx2x_ilt_mem_op_cnic(struct bnx2x *bp, u8 memop)
+{
+	int rc = 0;
+
+	if (CONFIGURE_NIC_MODE(bp))
+		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_SRC, memop);
+	if (!rc)
+		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_TM, memop);
+
+	return rc;
+}
+
 static int bnx2x_ilt_mem_op(struct bnx2x *bp, u8 memop)
 {
 	int rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_CDU, memop);
 	if (!rc)
 		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_QM, memop);
-	if (!rc)
+	if (!rc && CNIC_SUPPORT(bp) && !CONFIGURE_NIC_MODE(bp))
 		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_SRC, memop);
-	if (!rc)
-		rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_TM, memop);

 	return rc;
 }
@@ -781,12 +791,19 @@ static void bnx2x_ilt_client_id_init_op(struct bnx2x *bp,
 	bnx2x_ilt_client_init_op(bp, ilt_cli, initop);
 }

+static void bnx2x_ilt_init_op_cnic(struct bnx2x *bp, u8 initop)
+{
+	if (CONFIGURE_NIC_MODE(bp))
+		bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_SRC, initop);
+	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_TM, initop);
+}
+
 static void bnx2x_ilt_init_op(struct bnx2x *bp, u8 initop)
 {
 	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_CDU, initop);
 	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_QM, initop);
-	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_SRC, initop);
-	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_TM, initop);
+	if (CNIC_SUPPORT(bp) && !CONFIGURE_NIC_MODE(bp))
+		bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_SRC, initop);
 }

 static void bnx2x_ilt_init_client_psz(struct bnx2x *bp, int cli_num,
@@ -890,7 +907,6 @@ static void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
 /****************************************************************************
 * SRC initializations
 ****************************************************************************/
-#ifdef BCM_CNIC
 /* called during init func stage */
 static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
 			      dma_addr_t t2_mapping, int src_cid_count)
@@ -915,5 +931,4 @@ static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
 		    U64_HI((u64)t2_mapping +
 			   (src_cid_count-1) * sizeof(struct src_ent)));
 }
-#endif
 #endif /* BNX2X_INIT_OPS_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e2e45ee..a2b9465 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11998,7 +11998,7 @@ void bnx2x_init_xgxs_loopback(struct link_params *params,
 	bnx2x_set_led(params, vars, LED_MODE_OPER, vars->line_speed);
 }

-static void bnx2x_set_rx_filter(struct link_params *params, u8 en)
+void bnx2x_set_rx_filter(struct link_params *params, u8 en)
 {
 	struct bnx2x *bp = params->bp;
 	u8 val = en * 0x1F;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 9165b89..ba981ce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -432,7 +432,8 @@ int bnx2x_phy_probe(struct link_params *params);
 u8 bnx2x_fan_failure_det_req(struct bnx2x *bp, u32 shmem_base,
 			     u32 shmem2_base, u8 port);

-
+/* Open / close the gate between the NIG and the BRB */
+void bnx2x_set_rx_filter(struct link_params *params, u8 en);

 /* DCBX structs */

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d5648fc..0546cf4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -791,10 +791,9 @@ void bnx2x_panic_dump(struct bnx2x *bp)

 		/* host sb data */

-#ifdef BCM_CNIC
 		if (IS_FCOE_FP(fp))
 			continue;
-#endif
+
 		BNX2X_ERR("     run indexes (");
 		for (j = 0; j < HC_SB_MAX_SM; j++)
 			pr_cont("0x%x%s",
@@ -859,7 +858,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 #ifdef BNX2X_STOP_ON_ERROR
 	/* Rings */
 	/* Rx */
-	for_each_rx_queue(bp, i) {
+	for_each_valid_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];

 		start = RX_BD(le16_to_cpu(*fp->rx_cons_sb) - 10);
@@ -893,7 +892,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	}

 	/* Tx */
-	for_each_tx_queue(bp, i) {
+	for_each_valid_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		for_each_cos_in_tx_queue(fp, cos) {
 			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
@@ -1504,9 +1503,8 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 	if (msix) {
 		synchronize_irq(bp->msix_table[0].vector);
 		offset = 1;
-#ifdef BCM_CNIC
-		offset++;
-#endif
+		if (CNIC_SUPPORT(bp))
+			offset++;
 		for_each_eth_queue(bp, i)
 			synchronize_irq(bp->msix_table[offset++].vector);
 	} else
@@ -1588,9 +1586,8 @@ static bool bnx2x_trylock_leader_lock(struct bnx2x *bp)
 	return bnx2x_trylock_hw_lock(bp, bnx2x_get_leader_lock_resource(bp));
 }

-#ifdef BCM_CNIC
 static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid, u8 err);
-#endif
+

 void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe)
 {
@@ -1720,7 +1717,7 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];

-		mask = 0x2 << (fp->index + CNIC_PRESENT);
+		mask = 0x2 << (fp->index + CNIC_SUPPORT(bp));
 		if (status & mask) {
 			/* Handle Rx or Tx according to SB id */
 			prefetch(fp->rx_cons_sb);
@@ -1732,22 +1729,23 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		}
 	}

-#ifdef BCM_CNIC
-	mask = 0x2;
-	if (status & (mask | 0x1)) {
-		struct cnic_ops *c_ops = NULL;
+	if (CNIC_SUPPORT(bp)) {
+		mask = 0x2;
+		if (status & (mask | 0x1)) {
+			struct cnic_ops *c_ops = NULL;

-		if (likely(bp->state == BNX2X_STATE_OPEN)) {
-			rcu_read_lock();
-			c_ops = rcu_dereference(bp->cnic_ops);
-			if (c_ops)
-				c_ops->cnic_handler(bp->cnic_data, NULL);
-			rcu_read_unlock();
-		}
+			if (likely(bp->state == BNX2X_STATE_OPEN)) {
+				rcu_read_lock();
+				c_ops = rcu_dereference(bp->cnic_ops);
+				if (c_ops)
+					c_ops->cnic_handler(bp->cnic_data,
+							    NULL);
+				rcu_read_unlock();
+			}

-		status &= ~mask;
+			status &= ~mask;
+		}
 	}
-#endif

 	if (unlikely(status & 0x1)) {
 		queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);
@@ -3075,11 +3073,13 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)

 static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 {
-#ifdef BCM_CNIC
 	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
 	struct fcoe_stats_info *fcoe_stat =
 		&bp->slowpath->drv_info_to_mcp.fcoe_stat;

+	if (!CNIC_LOADED(bp))
+		return;
+
 	memcpy(fcoe_stat->mac_local + MAC_LEADING_ZERO_CNT,
 	       bp->fip_mac, ETH_ALEN);

@@ -3162,16 +3162,17 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)

 	/* ask L5 driver to add data to the struct */
 	bnx2x_cnic_notify(bp, CNIC_CTL_FCOE_STATS_GET_CMD);
-#endif
 }

 static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)
 {
-#ifdef BCM_CNIC
 	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
 	struct iscsi_stats_info *iscsi_stat =
 		&bp->slowpath->drv_info_to_mcp.iscsi_stat;

+	if (!CNIC_LOADED(bp))
+		return;
+
 	memcpy(iscsi_stat->mac_local + MAC_LEADING_ZERO_CNT,
 	       bp->cnic_eth_dev.iscsi_mac, ETH_ALEN);

@@ -3180,7 +3181,6 @@ static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)

 	/* ask L5 driver to add data to the struct */
 	bnx2x_cnic_notify(bp, CNIC_CTL_ISCSI_STATS_GET_CMD);
-#endif
 }

 /* called due to MCP event (on pmf):
@@ -4572,7 +4572,6 @@ static void bnx2x_update_eq_prod(struct bnx2x *bp, u16 prod)
 	mmiowb(); /* keep prod updates ordered */
 }

-#ifdef BCM_CNIC
 static int  bnx2x_cnic_handle_cfc_del(struct bnx2x *bp, u32 cid,
 				      union event_ring_elem *elem)
 {
@@ -4594,7 +4593,6 @@ static int  bnx2x_cnic_handle_cfc_del(struct bnx2x *bp, u32 cid,
 	bnx2x_cnic_cfc_comp(bp, cid, err);
 	return 0;
 }
-#endif

 static void bnx2x_handle_mcast_eqe(struct bnx2x *bp)
 {
@@ -4635,11 +4633,9 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,
 	switch (elem->message.data.eth_event.echo >> BNX2X_SWCID_SHIFT) {
 	case BNX2X_FILTER_MAC_PENDING:
 		DP(BNX2X_MSG_SP, "Got SETUP_MAC completions\n");
-#ifdef BCM_CNIC
-		if (cid == BNX2X_ISCSI_ETH_CID(bp))
+		if (CNIC_LOADED(bp) && (cid == BNX2X_ISCSI_ETH_CID(bp)))
 			vlan_mac_obj = &bp->iscsi_l2_mac_obj;
 		else
-#endif
 			vlan_mac_obj = &bp->sp_objs[cid].mac_obj;

 		break;
@@ -4665,9 +4661,7 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,

 }

-#ifdef BCM_CNIC
 static void bnx2x_set_iscsi_eth_rx_mode(struct bnx2x *bp, bool start);
-#endif

 static void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
 {
@@ -4678,14 +4672,12 @@ static void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
 	/* Send rx_mode command again if was requested */
 	if (test_and_clear_bit(BNX2X_FILTER_RX_MODE_SCHED, &bp->sp_state))
 		bnx2x_set_storm_rx_mode(bp);
-#ifdef BCM_CNIC
 	else if (test_and_clear_bit(BNX2X_FILTER_ISCSI_ETH_START_SCHED,
 				    &bp->sp_state))
 		bnx2x_set_iscsi_eth_rx_mode(bp, true);
 	else if (test_and_clear_bit(BNX2X_FILTER_ISCSI_ETH_STOP_SCHED,
 				    &bp->sp_state))
 		bnx2x_set_iscsi_eth_rx_mode(bp, false);
-#endif

 	netif_addr_unlock_bh(bp->dev);
 }
@@ -4747,7 +4739,6 @@ static void bnx2x_after_function_update(struct bnx2x *bp)
 				  q);
 	}

-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp)) {
 		fp = &bp->fp[FCOE_IDX(bp)];
 		queue_params.q_obj = &bnx2x_sp_obj(bp, fp).q_obj;
@@ -4770,22 +4761,16 @@ static void bnx2x_after_function_update(struct bnx2x *bp)
 		bnx2x_link_report(bp);
 		bnx2x_fw_command(bp, DRV_MSG_CODE_AFEX_VIFSET_ACK, 0);
 	}
-#else
-	/* If no FCoE ring - ACK MCP now */
-	bnx2x_link_report(bp);
-	bnx2x_fw_command(bp, DRV_MSG_CODE_AFEX_VIFSET_ACK, 0);
-#endif /* BCM_CNIC */
 }

 static struct bnx2x_queue_sp_obj *bnx2x_cid_to_q_obj(
 	struct bnx2x *bp, u32 cid)
 {
 	DP(BNX2X_MSG_SP, "retrieving fp from cid %d\n", cid);
-#ifdef BCM_CNIC
-	if (cid == BNX2X_FCOE_ETH_CID(bp))
+
+	if (CNIC_LOADED(bp) && (cid == BNX2X_FCOE_ETH_CID(bp)))
 		return &bnx2x_fcoe_sp_obj(bp, q_obj);
 	else
-#endif
 		return &bp->sp_objs[CID_TO_FP(cid, bp)].q_obj;
 }

@@ -4793,6 +4778,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 {
 	u16 hw_cons, sw_cons, sw_prod;
 	union event_ring_elem *elem;
+	u8 echo;
 	u32 cid;
 	u8 opcode;
 	int spqe_cnt = 0;
@@ -4847,10 +4833,11 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			 */
 			DP(BNX2X_MSG_SP,
 			   "got delete ramrod for MULTI[%d]\n", cid);
-#ifdef BCM_CNIC
-			if (!bnx2x_cnic_handle_cfc_del(bp, cid, elem))
+
+			if (CNIC_LOADED(bp) &&
+			    !bnx2x_cnic_handle_cfc_del(bp, cid, elem))
 				goto next_spqe;
-#endif
+
 			q_obj = bnx2x_cid_to_q_obj(bp, cid);

 			if (q_obj->complete_cmd(bp, q_obj, BNX2X_Q_CMD_CFC_DEL))
@@ -4875,21 +4862,34 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 				break;
 			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_RELEASED);
 			goto next_spqe;
+
 		case EVENT_RING_OPCODE_FUNCTION_UPDATE:
-			DP(BNX2X_MSG_SP | BNX2X_MSG_MCP,
-			   "AFEX: ramrod completed FUNCTION_UPDATE\n");
-			f_obj->complete_cmd(bp, f_obj, BNX2X_F_CMD_AFEX_UPDATE);
+			echo = elem->message.data.function_update_event.echo;
+			if (echo == SWITCH_UPDATE) {
+				DP(BNX2X_MSG_SP | NETIF_MSG_IFUP,
+				   "got FUNC_SWITCH_UPDATE ramrod\n");
+				if (f_obj->complete_cmd(
+					bp, f_obj, BNX2X_F_CMD_SWITCH_UPDATE))
+					break;

-			/* We will perform the Queues update from sp_rtnl task
-			 * as all Queue SP operations should run under
-			 * rtnl_lock.
-			 */
-			smp_mb__before_clear_bit();
-			set_bit(BNX2X_SP_RTNL_AFEX_F_UPDATE,
-				&bp->sp_rtnl_state);
-			smp_mb__after_clear_bit();
+			} else {
+				DP(BNX2X_MSG_SP | BNX2X_MSG_MCP,
+				   "AFEX: ramrod completed FUNCTION_UPDATE\n");
+				f_obj->complete_cmd(bp, f_obj,
+						    BNX2X_F_CMD_AFEX_UPDATE);
+
+				/* We will perform the Queues update from
+				 * sp_rtnl task as all Queue SP operations
+				 * should run under rtnl_lock.
+				 */
+				smp_mb__before_clear_bit();
+				set_bit(BNX2X_SP_RTNL_AFEX_F_UPDATE,
+					&bp->sp_rtnl_state);
+				smp_mb__after_clear_bit();
+
+				schedule_delayed_work(&bp->sp_rtnl_task, 0);
+			}

-			schedule_delayed_work(&bp->sp_rtnl_task, 0);
 			goto next_spqe;

 		case EVENT_RING_OPCODE_AFEX_VIF_LISTS:
@@ -4999,11 +4999,10 @@ static void bnx2x_sp_task(struct work_struct *work)

 	/* SP events: STAT_QUERY and others */
 	if (status & BNX2X_DEF_SB_IDX) {
-#ifdef BCM_CNIC
 		struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);

-		if ((!NO_FCOE(bp)) &&
-			(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+		if (FCOE_INIT(bp) &&
+		    (bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 			/*
 			 * Prevent local bottom-halves from running as
 			 * we are going to change the local NAPI list.
@@ -5012,7 +5011,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 			napi_schedule(&bnx2x_fcoe(bp, napi));
 			local_bh_enable();
 		}
-#endif
+
 		/* Handle EQ completions */
 		bnx2x_eq_int(bp);

@@ -5050,8 +5049,7 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif

-#ifdef BCM_CNIC
-	{
+	if (CNIC_LOADED(bp)) {
 		struct cnic_ops *c_ops;

 		rcu_read_lock();
@@ -5060,7 +5058,7 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 			c_ops->cnic_handler(bp->cnic_data, NULL);
 		rcu_read_unlock();
 	}
-#endif
+
 	queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);

 	return IRQ_HANDLED;
@@ -5498,12 +5496,10 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 	unsigned long rx_mode_flags = 0, ramrod_flags = 0;
 	unsigned long rx_accept_flags = 0, tx_accept_flags = 0;

-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp))

 		/* Configure rx_mode of FCoE Queue */
 		__set_bit(BNX2X_RX_MODE_FCOE_ETH, &rx_mode_flags);
-#endif

 	switch (bp->rx_mode) {
 	case BNX2X_RX_MODE_NONE:
@@ -5624,12 +5620,12 @@ static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)

 static inline u8 bnx2x_fp_igu_sb_id(struct bnx2x_fastpath *fp)
 {
-	return fp->bp->igu_base_sb + fp->index + CNIC_PRESENT;
+	return fp->bp->igu_base_sb + fp->index + CNIC_SUPPORT(fp->bp);
 }

 static inline u8 bnx2x_fp_fw_sb_id(struct bnx2x_fastpath *fp)
 {
-	return fp->bp->base_fw_ndsb + fp->index + CNIC_PRESENT;
+	return fp->bp->base_fw_ndsb + fp->index + CNIC_SUPPORT(fp->bp);
 }

 static u8 bnx2x_fp_cl_id(struct bnx2x_fastpath *fp)
@@ -5720,23 +5716,25 @@ static void bnx2x_init_tx_ring_one(struct bnx2x_fp_txdata *txdata)
 	txdata->tx_pkt = 0;
 }

+static void bnx2x_init_tx_rings_cnic(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_tx_queue_cnic(bp, i)
+		bnx2x_init_tx_ring_one(bp->fp[i].txdata_ptr[0]);
+}
 static void bnx2x_init_tx_rings(struct bnx2x *bp)
 {
 	int i;
 	u8 cos;

-	for_each_tx_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		for_each_cos_in_tx_queue(&bp->fp[i], cos)
 			bnx2x_init_tx_ring_one(bp->fp[i].txdata_ptr[cos]);
 }

-void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
+void bnx2x_nic_init_cnic(struct bnx2x *bp)
 {
-	int i;
-
-	for_each_eth_queue(bp, i)
-		bnx2x_init_eth_fp(bp, i);
-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp))
 		bnx2x_init_fcoe_fp(bp);

@@ -5744,8 +5742,22 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		      BNX2X_VF_ID_INVALID, false,
 		      bnx2x_cnic_fw_sb_id(bp), bnx2x_cnic_igu_sb_id(bp));

-#endif
+	/* ensure status block indices were read */
+	rmb();
+	bnx2x_init_rx_rings_cnic(bp);
+	bnx2x_init_tx_rings_cnic(bp);
+
+	/* flush all */
+	mb();
+	mmiowb();
+}

+void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
+{
+	int i;
+
+	for_each_eth_queue(bp, i)
+		bnx2x_init_eth_fp(bp, i);
 	/* Initialize MOD_ABS interrupts */
 	bnx2x_init_mod_abs_int(bp, &bp->link_vars, bp->common.chip_id,
 			       bp->common.shmem_base, bp->common.shmem2_base,
@@ -6031,10 +6043,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	msleep(50);
 	bnx2x_init_block(bp, BLOCK_BRB1, PHASE_COMMON);
 	bnx2x_init_block(bp, BLOCK_PRS, PHASE_COMMON);
-#ifndef BCM_CNIC
-	/* set NIC mode */
-	REG_WR(bp, PRS_REG_NIC_MODE, 1);
-#endif
+	if (!CNIC_SUPPORT(bp))
+		/* set NIC mode */
+		REG_WR(bp, PRS_REG_NIC_MODE, 1);

 	/* Enable inputs of parser neighbor blocks */
 	REG_WR(bp, TSDM_REG_ENABLE_IN1, 0x7fffffff);
@@ -6522,9 +6533,8 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)
 	REG_WR(bp, QM_REG_SOFT_RESET, 1);
 	REG_WR(bp, QM_REG_SOFT_RESET, 0);

-#ifdef BCM_CNIC
-	bnx2x_init_block(bp, BLOCK_TM, PHASE_COMMON);
-#endif
+	if (CNIC_SUPPORT(bp))
+		bnx2x_init_block(bp, BLOCK_TM, PHASE_COMMON);

 	bnx2x_init_block(bp, BLOCK_DORQ, PHASE_COMMON);
 	REG_WR(bp, DORQ_REG_DPM_CID_OFST, BNX2X_DB_SHIFT);
@@ -6611,18 +6621,18 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)

 	bnx2x_init_block(bp, BLOCK_SRC, PHASE_COMMON);

-#ifdef BCM_CNIC
-	REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
-	REG_WR(bp, SRC_REG_KEYSEARCH_1, 0x24b8f2cc);
-	REG_WR(bp, SRC_REG_KEYSEARCH_2, 0x223aef9b);
-	REG_WR(bp, SRC_REG_KEYSEARCH_3, 0x26001e3a);
-	REG_WR(bp, SRC_REG_KEYSEARCH_4, 0x7ae91116);
-	REG_WR(bp, SRC_REG_KEYSEARCH_5, 0x5ce5230b);
-	REG_WR(bp, SRC_REG_KEYSEARCH_6, 0x298d8adf);
-	REG_WR(bp, SRC_REG_KEYSEARCH_7, 0x6eb0ff09);
-	REG_WR(bp, SRC_REG_KEYSEARCH_8, 0x1830f82f);
-	REG_WR(bp, SRC_REG_KEYSEARCH_9, 0x01e46be7);
-#endif
+	if (CNIC_SUPPORT(bp)) {
+		REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
+		REG_WR(bp, SRC_REG_KEYSEARCH_1, 0x24b8f2cc);
+		REG_WR(bp, SRC_REG_KEYSEARCH_2, 0x223aef9b);
+		REG_WR(bp, SRC_REG_KEYSEARCH_3, 0x26001e3a);
+		REG_WR(bp, SRC_REG_KEYSEARCH_4, 0x7ae91116);
+		REG_WR(bp, SRC_REG_KEYSEARCH_5, 0x5ce5230b);
+		REG_WR(bp, SRC_REG_KEYSEARCH_6, 0x298d8adf);
+		REG_WR(bp, SRC_REG_KEYSEARCH_7, 0x6eb0ff09);
+		REG_WR(bp, SRC_REG_KEYSEARCH_8, 0x1830f82f);
+		REG_WR(bp, SRC_REG_KEYSEARCH_9, 0x01e46be7);
+	}
 	REG_WR(bp, SRC_REG_SOFT_RST, 0);

 	if (sizeof(union cdu_context) != 1024)
@@ -6786,11 +6796,11 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	/* QM cid (connection) count */
 	bnx2x_qm_init_cid_count(bp, bp->qm_cid_count, INITOP_SET);

-#ifdef BCM_CNIC
-	bnx2x_init_block(bp, BLOCK_TM, init_phase);
-	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
-	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
-#endif
+	if (CNIC_SUPPORT(bp)) {
+		bnx2x_init_block(bp, BLOCK_TM, init_phase);
+		REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
+		REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
+	}

 	bnx2x_init_block(bp, BLOCK_DORQ, init_phase);

@@ -6876,9 +6886,9 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 		REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
 	}

-#ifdef BCM_CNIC
-	bnx2x_init_block(bp, BLOCK_SRC, init_phase);
-#endif
+	if (CNIC_SUPPORT(bp))
+		bnx2x_init_block(bp, BLOCK_SRC, init_phase);
+
 	bnx2x_init_block(bp, BLOCK_CDU, init_phase);
 	bnx2x_init_block(bp, BLOCK_CFC, init_phase);

@@ -7039,6 +7049,130 @@ static void bnx2x_clear_func_ilt(struct bnx2x *bp, u32 func)
 		bnx2x_ilt_wr(bp, i, 0);
 }

+
+void bnx2x_init_searcher(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
+	/* T1 hash bits value determines the T1 number of entries */
+	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, SRC_HASH_BITS);
+}
+
+static inline int bnx2x_func_switch_update(struct bnx2x *bp, int suspend)
+{
+	int rc;
+	struct bnx2x_func_state_params func_params = {NULL};
+	struct bnx2x_func_switch_update_params *switch_update_params =
+		&func_params.params.switch_update;
+
+	/* Prepare parameters for function state transitions */
+	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
+	__set_bit(RAMROD_RETRY, &func_params.ramrod_flags);
+
+	func_params.f_obj = &bp->func_obj;
+	func_params.cmd = BNX2X_F_CMD_SWITCH_UPDATE;
+
+	/* Function parameters */
+	switch_update_params->suspend = suspend;
+
+	rc = bnx2x_func_state_change(bp, &func_params);
+
+	return rc;
+}
+
+int bnx2x_reset_nic_mode(struct bnx2x *bp)
+{
+	int rc, i, port = BP_PORT(bp);
+	int vlan_en = 0, mac_en[NUM_MACS];
+
+
+	/* Close input from network */
+	if (bp->mf_mode == SINGLE_FUNCTION) {
+		bnx2x_set_rx_filter(&bp->link_params, 0);
+	} else {
+		vlan_en = REG_RD(bp, port ? NIG_REG_LLH1_FUNC_EN :
+				   NIG_REG_LLH0_FUNC_EN);
+		REG_WR(bp, port ? NIG_REG_LLH1_FUNC_EN :
+			  NIG_REG_LLH0_FUNC_EN, 0);
+		for (i = 0; i < NUM_MACS; i++) {
+			mac_en[i] = REG_RD(bp, port ?
+					     (NIG_REG_LLH1_FUNC_MEM_ENABLE +
+					      4 * i) :
+					     (NIG_REG_LLH0_FUNC_MEM_ENABLE +
+					      4 * i));
+			REG_WR(bp, port ? (NIG_REG_LLH1_FUNC_MEM_ENABLE +
+					      4 * i) :
+				  (NIG_REG_LLH0_FUNC_MEM_ENABLE + 4 * i), 0);
+		}
+	}
+
+	/* Close BMC to host */
+	REG_WR(bp, port ? NIG_REG_P0_TX_MNG_HOST_ENABLE :
+	       NIG_REG_P1_TX_MNG_HOST_ENABLE, 0);
+
+	/* Suspend Tx switching to the PF. Completion of this ramrod
+	 * further guarantees that all the packets of that PF / child
+	 * VFs in BRB were processed by the Parser, so it is safe to
+	 * change the NIC_MODE register.
+	 */
+	rc = bnx2x_func_switch_update(bp, 1);
+	if (rc) {
+		BNX2X_ERR("Can't suspend tx-switching!\n");
+		return rc;
+	}
+
+	/* Change NIC_MODE register */
+	REG_WR(bp, PRS_REG_NIC_MODE, 0);
+
+	/* Open input from network */
+	if (bp->mf_mode == SINGLE_FUNCTION) {
+		bnx2x_set_rx_filter(&bp->link_params, 1);
+	} else {
+		REG_WR(bp, port ? NIG_REG_LLH1_FUNC_EN :
+			  NIG_REG_LLH0_FUNC_EN, vlan_en);
+		for (i = 0; i < NUM_MACS; i++) {
+			REG_WR(bp, port ? (NIG_REG_LLH1_FUNC_MEM_ENABLE +
+					      4 * i) :
+				  (NIG_REG_LLH0_FUNC_MEM_ENABLE + 4 * i),
+				  mac_en[i]);
+		}
+	}
+
+	/* Enable BMC to host */
+	REG_WR(bp, port ? NIG_REG_P0_TX_MNG_HOST_ENABLE :
+	       NIG_REG_P1_TX_MNG_HOST_ENABLE, 1);
+
+	/* Resume Tx switching to the PF */
+	rc = bnx2x_func_switch_update(bp, 0);
+	if (rc) {
+		BNX2X_ERR("Can't resume tx-switching!\n");
+		return rc;
+	}
+
+	DP(NETIF_MSG_IFUP, "NIC MODE disabled\n");
+	return 0;
+}
+
+int bnx2x_init_hw_func_cnic(struct bnx2x *bp)
+{
+	int rc;
+
+	bnx2x_ilt_init_op_cnic(bp, INITOP_SET);
+
+	if (CONFIGURE_NIC_MODE(bp)) {
+		/* Configrue searcher as part of function hw init */
+		bnx2x_init_searcher(bp);
+
+		/* Reset NIC mode */
+		rc = bnx2x_reset_nic_mode(bp);
+		if (rc)
+			BNX2X_ERR("Can't change NIC mode!\n");
+		return rc;
+	}
+
+	return 0;
+}
+
 static int bnx2x_init_hw_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
@@ -7081,17 +7215,16 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	}
 	bnx2x_ilt_init_op(bp, INITOP_SET);

-#ifdef BCM_CNIC
-	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
-
-	/* T1 hash bits value determines the T1 number of entries */
-	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, SRC_HASH_BITS);
-#endif
+	if (!CONFIGURE_NIC_MODE(bp)) {
+		bnx2x_init_searcher(bp);
+		REG_WR(bp, PRS_REG_NIC_MODE, 0);
+		DP(NETIF_MSG_IFUP, "NIC MODE disabled\n");
+	} else {
+		/* Set NIC mode */
+		REG_WR(bp, PRS_REG_NIC_MODE, 1);
+		DP(NETIF_MSG_IFUP, "NIC MODE configrued\n");

-#ifndef BCM_CNIC
-	/* set NIC mode */
-	REG_WR(bp, PRS_REG_NIC_MODE, 1);
-#endif  /* BCM_CNIC */
+	}

 	if (!CHIP_IS_E1x(bp)) {
 		u32 pf_conf = IGU_PF_CONF_FUNC_EN;
@@ -7342,6 +7475,20 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 }


+void bnx2x_free_mem_cnic(struct bnx2x *bp)
+{
+	bnx2x_ilt_mem_op_cnic(bp, ILT_MEMOP_FREE);
+
+	if (!CHIP_IS_E1x(bp))
+		BNX2X_PCI_FREE(bp->cnic_sb.e2_sb, bp->cnic_sb_mapping,
+			       sizeof(struct host_hc_status_block_e2));
+	else
+		BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
+			       sizeof(struct host_hc_status_block_e1x));
+
+	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
+}
+
 void bnx2x_free_mem(struct bnx2x *bp)
 {
 	int i;
@@ -7366,17 +7513,6 @@ void bnx2x_free_mem(struct bnx2x *bp)

 	BNX2X_FREE(bp->ilt->lines);

-#ifdef BCM_CNIC
-	if (!CHIP_IS_E1x(bp))
-		BNX2X_PCI_FREE(bp->cnic_sb.e2_sb, bp->cnic_sb_mapping,
-			       sizeof(struct host_hc_status_block_e2));
-	else
-		BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
-			       sizeof(struct host_hc_status_block_e1x));
-
-	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
-#endif
-
 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, BCM_PAGE_SIZE);

 	BNX2X_PCI_FREE(bp->eq_ring, bp->eq_mapping,
@@ -7444,24 +7580,44 @@ alloc_mem_err:
 	return -ENOMEM;
 }

-
-int bnx2x_alloc_mem(struct bnx2x *bp)
+int bnx2x_alloc_mem_cnic(struct bnx2x *bp)
 {
-	int i, allocated, context_size;
-
-#ifdef BCM_CNIC
 	if (!CHIP_IS_E1x(bp))
 		/* size = the status block + ramrod buffers */
 		BNX2X_PCI_ALLOC(bp->cnic_sb.e2_sb, &bp->cnic_sb_mapping,
 				sizeof(struct host_hc_status_block_e2));
 	else
-		BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb, &bp->cnic_sb_mapping,
-				sizeof(struct host_hc_status_block_e1x));
+		BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb,
+				&bp->cnic_sb_mapping,
+				sizeof(struct
+				       host_hc_status_block_e1x));

-	/* allocate searcher T2 table */
-	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
-#endif
+	if (CONFIGURE_NIC_MODE(bp))
+		/* allocate searcher T2 table, as it wan't allocated before */
+		BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
+
+	/* write address to which L5 should insert its values */
+	bp->cnic_eth_dev.addr_drv_info_to_mcp =
+		&bp->slowpath->drv_info_to_mcp;
+
+	if (bnx2x_ilt_mem_op_cnic(bp, ILT_MEMOP_ALLOC))
+		goto alloc_mem_err;
+
+	return 0;
+
+alloc_mem_err:
+	bnx2x_free_mem_cnic(bp);
+	BNX2X_ERR("Can't allocate memory\n");
+	return -ENOMEM;
+}
+
+int bnx2x_alloc_mem(struct bnx2x *bp)
+{
+	int i, allocated, context_size;

+	if (!CONFIGURE_NIC_MODE(bp))
+		/* allocate searcher T2 table */
+		BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);

 	BNX2X_PCI_ALLOC(bp->def_status_blk, &bp->def_status_blk_mapping,
 			sizeof(struct host_sp_status_block));
@@ -7469,11 +7625,6 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
 			sizeof(struct bnx2x_slowpath));

-#ifdef BCM_CNIC
-	/* write address to which L5 should insert its values */
-	bp->cnic_eth_dev.addr_drv_info_to_mcp = &bp->slowpath->drv_info_to_mcp;
-#endif
-
 	/* Allocated memory for FW statistics  */
 	if (bnx2x_alloc_fw_stats_mem(bp))
 		goto alloc_mem_err;
@@ -7595,14 +7746,12 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 {
 	unsigned long ramrod_flags = 0;

-#ifdef BCM_CNIC
 	if (is_zero_ether_addr(bp->dev->dev_addr) &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
 		DP(NETIF_MSG_IFUP | NETIF_MSG_IFDOWN,
 		   "Ignoring Zero MAC for STORAGE SD mode\n");
 		return 0;
 	}
-#endif

 	DP(NETIF_MSG_IFUP, "Adding Eth MAC\n");

@@ -7631,7 +7780,8 @@ void bnx2x_set_int_mode(struct bnx2x *bp)
 		bnx2x_enable_msi(bp);
 		/* falling through... */
 	case INT_MODE_INTx:
-		bp->num_queues = 1 + NON_ETH_CONTEXT_USE;
+		bp->num_ethernet_queues = 1;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
 		BNX2X_DEV_INFO("set number of queues to 1\n");
 		break;
 	default:
@@ -7643,9 +7793,10 @@ void bnx2x_set_int_mode(struct bnx2x *bp)
 		    bp->flags & USING_SINGLE_MSIX_FLAG) {
 			/* failed to enable multiple MSI-X */
 			BNX2X_DEV_INFO("Failed to enable multiple MSI-X (%d), set number of queues to %d\n",
-				       bp->num_queues, 1 + NON_ETH_CONTEXT_USE);
+				       bp->num_queues,
+				       1 + bp->num_cnic_queues);

-			bp->num_queues = 1 + NON_ETH_CONTEXT_USE;
+			bp->num_queues = 1 + bp->num_cnic_queues;

 			/* Try to enable MSI */
 			if (!(bp->flags & USING_SINGLE_MSIX_FLAG) &&
@@ -7678,9 +7829,9 @@ void bnx2x_ilt_set_info(struct bnx2x *bp)
 	ilt_client->flags = ILT_CLIENT_SKIP_MEM;
 	ilt_client->start = line;
 	line += bnx2x_cid_ilt_lines(bp);
-#ifdef BCM_CNIC
-	line += CNIC_ILT_LINES;
-#endif
+
+	if (CNIC_SUPPORT(bp))
+		line += CNIC_ILT_LINES;
 	ilt_client->end = line - 1;

 	DP(NETIF_MSG_IFUP, "ilt client[CDU]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
@@ -7713,49 +7864,43 @@ void bnx2x_ilt_set_info(struct bnx2x *bp)
 		   ilog2(ilt_client->page_size >> 12));

 	}
-	/* SRC */
-	ilt_client = &ilt->clients[ILT_CLIENT_SRC];
-#ifdef BCM_CNIC
-	ilt_client->client_num = ILT_CLIENT_SRC;
-	ilt_client->page_size = SRC_ILT_PAGE_SZ;
-	ilt_client->flags = 0;
-	ilt_client->start = line;
-	line += SRC_ILT_LINES;
-	ilt_client->end = line - 1;

-	DP(NETIF_MSG_IFUP,
-	   "ilt client[SRC]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
-	   ilt_client->start,
-	   ilt_client->end,
-	   ilt_client->page_size,
-	   ilt_client->flags,
-	   ilog2(ilt_client->page_size >> 12));
+	if (CNIC_SUPPORT(bp)) {
+		/* SRC */
+		ilt_client = &ilt->clients[ILT_CLIENT_SRC];
+		ilt_client->client_num = ILT_CLIENT_SRC;
+		ilt_client->page_size = SRC_ILT_PAGE_SZ;
+		ilt_client->flags = 0;
+		ilt_client->start = line;
+		line += SRC_ILT_LINES;
+		ilt_client->end = line - 1;

-#else
-	ilt_client->flags = (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM);
-#endif
+		DP(NETIF_MSG_IFUP,
+		   "ilt client[SRC]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
+		   ilt_client->start,
+		   ilt_client->end,
+		   ilt_client->page_size,
+		   ilt_client->flags,
+		   ilog2(ilt_client->page_size >> 12));

-	/* TM */
-	ilt_client = &ilt->clients[ILT_CLIENT_TM];
-#ifdef BCM_CNIC
-	ilt_client->client_num = ILT_CLIENT_TM;
-	ilt_client->page_size = TM_ILT_PAGE_SZ;
-	ilt_client->flags = 0;
-	ilt_client->start = line;
-	line += TM_ILT_LINES;
-	ilt_client->end = line - 1;
+		/* TM */
+		ilt_client = &ilt->clients[ILT_CLIENT_TM];
+		ilt_client->client_num = ILT_CLIENT_TM;
+		ilt_client->page_size = TM_ILT_PAGE_SZ;
+		ilt_client->flags = 0;
+		ilt_client->start = line;
+		line += TM_ILT_LINES;
+		ilt_client->end = line - 1;

-	DP(NETIF_MSG_IFUP,
-	   "ilt client[TM]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
-	   ilt_client->start,
-	   ilt_client->end,
-	   ilt_client->page_size,
-	   ilt_client->flags,
-	   ilog2(ilt_client->page_size >> 12));
+		DP(NETIF_MSG_IFUP,
+		   "ilt client[TM]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
+		   ilt_client->start,
+		   ilt_client->end,
+		   ilt_client->page_size,
+		   ilt_client->flags,
+		   ilog2(ilt_client->page_size >> 12));
+	}

-#else
-	ilt_client->flags = (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM);
-#endif
 	BUG_ON(line > ILT_MAX_LINES);
 }

@@ -7923,6 +8068,9 @@ int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	/* Set the command */
 	q_params.cmd = BNX2X_Q_CMD_SETUP;

+	if (IS_FCOE_FP(fp))
+		bp->fcoe_init = true;
+
 	/* Change the state to SETUP */
 	rc = bnx2x_queue_state_change(bp, &q_params);
 	if (rc) {
@@ -8036,12 +8184,12 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 			   SB_DISABLED);
 	}

-#ifdef BCM_CNIC
-	/* CNIC SB */
-	REG_WR8(bp, BAR_CSTRORM_INTMEM +
-		CSTORM_STATUS_BLOCK_DATA_STATE_OFFSET(bnx2x_cnic_fw_sb_id(bp)),
-		SB_DISABLED);
-#endif
+	if (CNIC_LOADED(bp))
+		/* CNIC SB */
+		REG_WR8(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_STATE_OFFSET
+			(bnx2x_cnic_fw_sb_id(bp)), SB_DISABLED);
+
 	/* SP SB */
 	REG_WR8(bp, BAR_CSTRORM_INTMEM +
 		   CSTORM_SP_STATUS_BLOCK_DATA_STATE_OFFSET(func),
@@ -8060,19 +8208,19 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 		REG_WR(bp, IGU_REG_TRAILING_EDGE_LATCH, 0);
 	}

-#ifdef BCM_CNIC
-	/* Disable Timer scan */
-	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
-	/*
-	 * Wait for at least 10ms and up to 2 second for the timers scan to
-	 * complete
-	 */
-	for (i = 0; i < 200; i++) {
-		msleep(10);
-		if (!REG_RD(bp, TM_REG_LIN0_SCAN_ON + port*4))
-			break;
+	if (CNIC_LOADED(bp)) {
+		/* Disable Timer scan */
+		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
+		/*
+		 * Wait for at least 10ms and up to 2 second for the timers
+		 * scan to complete
+		 */
+		for (i = 0; i < 200; i++) {
+			msleep(10);
+			if (!REG_RD(bp, TM_REG_LIN0_SCAN_ON + port*4))
+				break;
+		}
 	}
-#endif
 	/* Clear ILT */
 	bnx2x_clear_func_ilt(bp, func);

@@ -8408,13 +8556,24 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode, bool keep_link)
 	/* Close multi and leading connections
 	 * Completions for ramrods are collected in a synchronous way
 	 */
-	for_each_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		if (bnx2x_stop_queue(bp, i))
 #ifdef BNX2X_STOP_ON_ERROR
 			return;
 #else
 			goto unload_error;
 #endif
+
+	if (CNIC_LOADED(bp)) {
+		for_each_cnic_queue(bp, i)
+			if (bnx2x_stop_queue(bp, i))
+#ifdef BNX2X_STOP_ON_ERROR
+				return;
+#else
+				goto unload_error;
+#endif
+	}
+
 	/* If SP settings didn't get completed so far - something
 	 * very wrong has happen.
 	 */
@@ -8436,6 +8595,8 @@ unload_error:
 	bnx2x_netif_stop(bp, 1);
 	/* Delete all NAPI objects */
 	bnx2x_del_all_napi(bp);
+	if (CNIC_LOADED(bp))
+		bnx2x_del_all_napi_cnic(bp);

 	/* Release IRQs */
 	bnx2x_free_irq(bp);
@@ -10223,12 +10384,15 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 void bnx2x_get_iscsi_info(struct bnx2x *bp)
 {
 	u32 no_flags = NO_ISCSI_FLAG;
-#ifdef BCM_CNIC
 	int port = BP_PORT(bp);
-
 	u32 max_iscsi_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
 				drv_lic_key[port].max_iscsi_conn);

+	if (!CNIC_SUPPORT(bp)) {
+		bp->flags |= no_flags;
+		return;
+	}
+
 	/* Get the number of maximum allowed iSCSI connections */
 	bp->cnic_eth_dev.max_iscsi_conn =
 		(max_iscsi_conn & BNX2X_MAX_ISCSI_INIT_CONN_MASK) >>
@@ -10243,12 +10407,9 @@ void bnx2x_get_iscsi_info(struct bnx2x *bp)
 	 */
 	if (!bp->cnic_eth_dev.max_iscsi_conn)
 		bp->flags |= no_flags;
-#else
-	bp->flags |= no_flags;
-#endif
+
 }

-#ifdef BCM_CNIC
 static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
 {
 	/* Port info */
@@ -10263,16 +10424,18 @@ static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
 	bp->cnic_eth_dev.fcoe_wwn_node_name_lo =
 		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_node_name_lower);
 }
-#endif
 static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 {
-#ifdef BCM_CNIC
 	int port = BP_PORT(bp);
 	int func = BP_ABS_FUNC(bp);
-
 	u32 max_fcoe_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
 				drv_lic_key[port].max_fcoe_conn);

+	if (!CNIC_SUPPORT(bp)) {
+		bp->flags |= NO_FCOE_FLAG;
+		return;
+	}
+
 	/* Get the number of maximum allowed FCoE connections */
 	bp->cnic_eth_dev.max_fcoe_conn =
 		(max_fcoe_conn & BNX2X_MAX_FCOE_INIT_CONN_MASK) >>
@@ -10318,9 +10481,6 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 	 */
 	if (!bp->cnic_eth_dev.max_fcoe_conn)
 		bp->flags |= NO_FCOE_FLAG;
-#else
-	bp->flags |= NO_FCOE_FLAG;
-#endif
 }

 static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
@@ -10334,132 +10494,133 @@ static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
 	bnx2x_get_fcoe_info(bp);
 }

-static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
+static void __devinit bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2;
 	int func = BP_ABS_FUNC(bp);
 	int port = BP_PORT(bp);
-#ifdef BCM_CNIC
 	u8 *iscsi_mac = bp->cnic_eth_dev.iscsi_mac;
 	u8 *fip_mac = bp->fip_mac;
-#endif

-	/* Zero primary MAC configuration */
-	memset(bp->dev->dev_addr, 0, ETH_ALEN);
-
-	if (BP_NOMCP(bp)) {
-		BNX2X_ERROR("warning: random MAC workaround active\n");
-		eth_hw_addr_random(bp->dev);
-	} else if (IS_MF(bp)) {
-		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
-		val = MF_CFG_RD(bp, func_mf_config[func].mac_lower);
-		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
-		    (val != FUNC_MF_CFG_LOWERMAC_DEFAULT))
-			bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
-
-#ifdef BCM_CNIC
-		/*
-		 * iSCSI and FCoE NPAR MACs: if there is no either iSCSI or
+	if (IS_MF(bp)) {
+		/* iSCSI and FCoE NPAR MACs: if there is no either iSCSI or
 		 * FCoE MAC then the appropriate feature should be disabled.
-		 *
-		 * In non SD mode features configuration comes from
-		 * struct func_ext_config.
+		 * In non SD mode features configuration comes from struct
+		 * func_ext_config.
 		 */
-		if (!IS_MF_SD(bp)) {
+		if (!IS_MF_SD(bp) && !CHIP_IS_E1x(bp)) {
 			u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
 			if (cfg & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD) {
 				val2 = MF_CFG_RD(bp, func_ext_config[func].
-						     iscsi_mac_addr_upper);
+						 iscsi_mac_addr_upper);
 				val = MF_CFG_RD(bp, func_ext_config[func].
-						    iscsi_mac_addr_lower);
+						iscsi_mac_addr_lower);
 				bnx2x_set_mac_buf(iscsi_mac, val, val2);
-				BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
-					       iscsi_mac);
-			} else
+				BNX2X_DEV_INFO
+					("Read iSCSI MAC: %pM\n", iscsi_mac);
+			} else {
 				bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
+			}

 			if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD) {
 				val2 = MF_CFG_RD(bp, func_ext_config[func].
-						     fcoe_mac_addr_upper);
+						 fcoe_mac_addr_upper);
 				val = MF_CFG_RD(bp, func_ext_config[func].
-						    fcoe_mac_addr_lower);
+						fcoe_mac_addr_lower);
 				bnx2x_set_mac_buf(fip_mac, val, val2);
-				BNX2X_DEV_INFO("Read FCoE L2 MAC: %pM\n",
-					       fip_mac);
-
-			} else
+				BNX2X_DEV_INFO
+					("Read FCoE L2 MAC: %pM\n", fip_mac);
+			} else {
 				bp->flags |= NO_FCOE_FLAG;
+			}

 			bp->mf_ext_config = cfg;

 		} else { /* SD MODE */
-			if (IS_MF_STORAGE_SD(bp)) {
-				if (BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp)) {
-					/* use primary mac as iscsi mac */
-					memcpy(iscsi_mac, bp->dev->dev_addr,
-					       ETH_ALEN);
-
-					BNX2X_DEV_INFO("SD ISCSI MODE\n");
-					BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
-						       iscsi_mac);
-				} else { /* FCoE */
-					memcpy(fip_mac, bp->dev->dev_addr,
-					       ETH_ALEN);
-					BNX2X_DEV_INFO("SD FCoE MODE\n");
-					BNX2X_DEV_INFO("Read FIP MAC: %pM\n",
-						       fip_mac);
-				}
-				/* Zero primary MAC configuration */
-				memset(bp->dev->dev_addr, 0, ETH_ALEN);
+			if (BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp)) {
+				/* use primary mac as iscsi mac */
+				memcpy(iscsi_mac, bp->dev->dev_addr, ETH_ALEN);
+
+				BNX2X_DEV_INFO("SD ISCSI MODE\n");
+				BNX2X_DEV_INFO
+					("Read iSCSI MAC: %pM\n", iscsi_mac);
+			} else if (BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)) {
+				/* use primary mac as fip mac */
+				memcpy(fip_mac, bp->dev->dev_addr, ETH_ALEN);
+				BNX2X_DEV_INFO("SD FCoE MODE\n");
+				BNX2X_DEV_INFO
+					("Read FIP MAC: %pM\n", fip_mac);
 			}
 		}

+		if (IS_MF_STORAGE_SD(bp))
+			/* Zero primary MAC configuration */
+			memset(bp->dev->dev_addr, 0, ETH_ALEN);
+
 		if (IS_MF_FCOE_AFEX(bp))
 			/* use FIP MAC as primary MAC */
 			memcpy(bp->dev->dev_addr, fip_mac, ETH_ALEN);

-#endif
 	} else {
-		/* in SF read MACs from port configuration */
-		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
-		val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
-		bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
-
-#ifdef BCM_CNIC
 		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].
-				    iscsi_mac_upper);
+				iscsi_mac_upper);
 		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
-				   iscsi_mac_lower);
+			       iscsi_mac_lower);
 		bnx2x_set_mac_buf(iscsi_mac, val, val2);

 		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].
-				    fcoe_fip_mac_upper);
+				fcoe_fip_mac_upper);
 		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
-				   fcoe_fip_mac_lower);
+			       fcoe_fip_mac_lower);
 		bnx2x_set_mac_buf(fip_mac, val, val2);
-#endif
 	}

-	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
-	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
-
-#ifdef BCM_CNIC
-	/* Disable iSCSI if MAC configuration is
-	 * invalid.
-	 */
+	/* Disable iSCSI OOO if MAC configuration is invalid. */
 	if (!is_valid_ether_addr(iscsi_mac)) {
-		bp->flags |= NO_ISCSI_FLAG;
+		bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
 		memset(iscsi_mac, 0, ETH_ALEN);
 	}

-	/* Disable FCoE if MAC configuration is
-	 * invalid.
-	 */
+	/* Disable FCoE if MAC configuration is invalid. */
 	if (!is_valid_ether_addr(fip_mac)) {
 		bp->flags |= NO_FCOE_FLAG;
 		memset(bp->fip_mac, 0, ETH_ALEN);
 	}
-#endif
+}
+
+static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
+{
+	u32 val, val2;
+	int func = BP_ABS_FUNC(bp);
+	int port = BP_PORT(bp);
+
+	/* Zero primary MAC configuration */
+	memset(bp->dev->dev_addr, 0, ETH_ALEN);
+
+	if (BP_NOMCP(bp)) {
+		BNX2X_ERROR("warning: random MAC workaround active\n");
+		eth_hw_addr_random(bp->dev);
+	} else if (IS_MF(bp)) {
+		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
+		val = MF_CFG_RD(bp, func_mf_config[func].mac_lower);
+		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
+		    (val != FUNC_MF_CFG_LOWERMAC_DEFAULT))
+			bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
+
+		if (CNIC_SUPPORT(bp))
+			bnx2x_get_cnic_mac_hwinfo(bp);
+	} else {
+		/* in SF read MACs from port configuration */
+		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
+		val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
+		bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
+
+		if (CNIC_SUPPORT(bp))
+			bnx2x_get_cnic_mac_hwinfo(bp);
+	}
+
+	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
+	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);

 	if (!bnx2x_is_valid_ether_addr(bp, bp->dev->dev_addr))
 		dev_err(&bp->pdev->dev,
@@ -10836,9 +10997,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	spin_lock_init(&bp->stats_lock);
-#ifdef BCM_CNIC
-	mutex_init(&bp->cnic_mutex);
-#endif
+

 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
 	INIT_DELAYED_WORK(&bp->sp_rtnl_task, bnx2x_sp_rtnl_task);
@@ -10876,10 +11035,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		dev_err(&bp->pdev->dev, "MCP disabled, must load devices in order!\n");

 	bp->disable_tpa = disable_tpa;
-
-#ifdef BCM_CNIC
 	bp->disable_tpa |= IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp);
-#endif

 	/* Set TPA flags */
 	if (bp->disable_tpa) {
@@ -10913,12 +11069,10 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bnx2x_dcbx_set_state(bp, true, BNX2X_DCBX_ENABLED_ON_NEG_ON);
 	bnx2x_dcbx_init_params(bp);

-#ifdef BCM_CNIC
 	if (CHIP_IS_E1x(bp))
 		bp->cnic_base_cl_id = FP_SB_MAX_E1x;
 	else
 		bp->cnic_base_cl_id = FP_SB_MAX_E2;
-#endif

 	/* multiple tx priority */
 	if (CHIP_IS_E1x(bp))
@@ -10928,6 +11082,16 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (CHIP_IS_E3B0(bp))
 		bp->max_cos = BNX2X_MULTI_TX_COS_E3B0;

+	/* We need at least one default status block for slow-path events,
+	 * second status block for the L2 queue, and a third status block for
+	 * CNIC if supproted.
+	 */
+	if (CNIC_SUPPORT(bp))
+		bp->min_msix_vec_cnt = 3;
+	else
+		bp->min_msix_vec_cnt = 2;
+	BNX2X_DEV_INFO("bp->min_msix_vec_cnt %d", bp->min_msix_vec_cnt);
+
 	return rc;
 }

@@ -11164,11 +11328,9 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 	}

 	bp->rx_mode = rx_mode;
-#ifdef BCM_CNIC
 	/* handle ISCSI SD mode */
 	if (IS_MF_ISCSI_SD(bp))
 		bp->rx_mode = BNX2X_RX_MODE_NONE;
-#endif

 	/* Schedule the rx_mode command */
 	if (test_bit(BNX2X_FILTER_RX_MODE_PENDING, &bp->sp_state)) {
@@ -11280,7 +11442,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #endif
 	.ndo_setup_tc		= bnx2x_setup_tc,

-#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
+#ifdef NETDEV_FCOE_WWNN
 	.ndo_fcoe_get_wwn	= bnx2x_fcoe_get_wwn,
 #endif
 };
@@ -11746,9 +11908,8 @@ static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
 {
 	int cid_count = BNX2X_L2_MAX_CID(bp);

-#ifdef BCM_CNIC
-	cid_count += CNIC_CID_MAX;
-#endif
+	if (CNIC_SUPPORT(bp))
+		cid_count += CNIC_CID_MAX;
 	return roundup(cid_count, QM_CID_ROUND);
 }

@@ -11758,7 +11919,8 @@ static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
  * @dev:	pci device
  *
  */
-static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
+static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
+				     int cnic_cnt)
 {
 	int pos;
 	u16 control;
@@ -11770,7 +11932,7 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
 	 * one fast path queue: one FP queue + SB for CNIC
 	 */
 	if (!pos)
-		return 1 + CNIC_PRESENT;
+		return 1 + cnic_cnt;

 	/*
 	 * The value in the PCI configuration space is the index of the last
@@ -11790,6 +11952,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	int pcie_width, pcie_speed;
 	int rc, max_non_def_sbs;
 	int rx_count, tx_count, rss_count, doorbell_size;
+	int cnic_cnt;
 	/*
 	 * An estimated maximum supported CoS number according to the chip
 	 * version.
@@ -11833,21 +11996,22 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return -ENODEV;
 	}

-	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev);
+	cnic_cnt = 1;
+	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev, cnic_cnt);

 	WARN_ON(!max_non_def_sbs);

 	/* Maximum number of RSS queues: one IGU SB goes to CNIC */
-	rss_count = max_non_def_sbs - CNIC_PRESENT;
+	rss_count = max_non_def_sbs - cnic_cnt;

 	/* Maximum number of netdev Rx queues: RSS + FCoE L2 */
-	rx_count = rss_count + FCOE_PRESENT;
+	rx_count = rss_count + cnic_cnt;

 	/*
 	 * Maximum number of netdev Tx queues:
 	 * Maximum TSS queues * Maximum supported number of CoS  + FCoE L2
 	 */
-	tx_count = rss_count * max_cos_est + FCOE_PRESENT;
+	tx_count = rss_count * max_cos_est + cnic_cnt;

 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mqs(sizeof(*bp), tx_count, rx_count);
@@ -11858,6 +12022,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,

 	bp->igu_sb_cnt = max_non_def_sbs;
 	bp->msg_enable = debug;
+	bp->cnic_support = cnic_cnt;
+
 	pci_set_drvdata(pdev, dev);

 	rc = bnx2x_init_dev(pdev, dev, ent->driver_data);
@@ -11866,6 +12032,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return rc;
 	}

+	BNX2X_DEV_INFO("Cnic support is %s\n", CNIC_SUPPORT(bp) ? "on" : "off");
 	BNX2X_DEV_INFO("max_non_def_sbs %d\n", max_non_def_sbs);

 	BNX2X_DEV_INFO("Allocated netdev with %d tx and %d rx queues\n",
@@ -11898,14 +12065,10 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* calc qm_cid_count */
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp);

-#ifdef BCM_CNIC
-	/* disable FCOE L2 queue for E1x */
+	/* disable FCOE L2 queue for E1x*/
 	if (CHIP_IS_E1x(bp))
 		bp->flags |= NO_FCOE_FLAG;

-#endif
-
-
 	/* Set bp->num_queues for MSI-X mode*/
 	bnx2x_set_num_queues(bp);

@@ -11920,14 +12083,13 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}

-#ifdef BCM_CNIC
+
 	if (!NO_FCOE(bp)) {
 		/* Add storage MAC address */
 		rtnl_lock();
 		dev_addr_add(bp->dev, bp->fip_mac, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
 	}
-#endif

 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);

@@ -11972,14 +12134,12 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	}
 	bp = netdev_priv(dev);

-#ifdef BCM_CNIC
 	/* Delete storage MAC address */
 	if (!NO_FCOE(bp)) {
 		rtnl_lock();
 		dev_addr_del(bp->dev, bp->fip_mac, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
 	}
-#endif

 #ifdef BCM_DCBNL
 	/* Delete app tlvs from dcbnl */
@@ -12027,15 +12187,17 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)

 	bp->rx_mode = BNX2X_RX_MODE_NONE;

-#ifdef BCM_CNIC
-	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
-#endif
+	if (CNIC_LOADED(bp))
+		bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
+
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);

 	bnx2x_netif_stop(bp, 0);
 	/* Delete all NAPI objects */
 	bnx2x_del_all_napi(bp);
+	if (CNIC_LOADED(bp))
+		bnx2x_del_all_napi_cnic(bp);

 	del_timer_sync(&bp->timer);

@@ -12226,7 +12388,6 @@ void bnx2x_notify_link_changed(struct bnx2x *bp)
 module_init(bnx2x_init);
 module_exit(bnx2x_cleanup);

-#ifdef BCM_CNIC
 /**
  * bnx2x_set_iscsi_eth_mac_addr - set iSCSI MAC(s).
  *
@@ -12679,12 +12840,31 @@ static int bnx2x_register_cnic(struct net_device *dev, struct cnic_ops *ops,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+	int rc;
+
+	DP(NETIF_MSG_IFUP, "Register_cnic called\n");

 	if (ops == NULL) {
 		BNX2X_ERR("NULL ops received\n");
 		return -EINVAL;
 	}

+	if (!CNIC_SUPPORT(bp)) {
+		BNX2X_ERR("Can't register CNIC when not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (!CNIC_LOADED(bp)) {
+		rc = bnx2x_load_cnic(bp);
+		if (rc) {
+			BNX2X_ERR("CNIC-related load failed\n");
+			return rc;
+		}
+
+	}
+
+	bp->cnic_enabled = true;
+
 	bp->cnic_kwq = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!bp->cnic_kwq)
 		return -ENOMEM;
@@ -12776,5 +12956,4 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 }
 EXPORT_SYMBOL(bnx2x_cnic_probe);

-#endif /* BCM_CNIC */

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 1b1999d..7d93adb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -2107,6 +2107,7 @@
 #define NIG_REG_LLH1_ERROR_MASK 				 0x10090
 /* [RW 8] event id for llh1 */
 #define NIG_REG_LLH1_EVENT_ID					 0x10088
+#define NIG_REG_LLH1_FUNC_EN					 0x16104
 #define NIG_REG_LLH1_FUNC_MEM					 0x161c0
 #define NIG_REG_LLH1_FUNC_MEM_ENABLE				 0x16160
 #define NIG_REG_LLH1_FUNC_MEM_SIZE				 16
@@ -2302,6 +2303,15 @@
  * set to 0x345678021. This is a new register (with 2_) added in E3 B0 to
  * accommodate the 9 input clients to ETS arbiter. */
 #define NIG_REG_P0_TX_ARB_PRIORITY_CLIENT2_MSB			 0x18684
+/* [RW 1] MCP-to-host path enable. Set this bit to enable the routing of MCP
+ * packets to BRB LB interface to forward the packet to the host. All
+ * packets from MCP are forwarded to the network when this bit is cleared -
+ * regardless of the configured destination in tx_mng_destination register.
+ * When MCP-to-host paths for both ports 0 and 1 are disabled - the arbiter
+ * for BRB LB interface is bypassed and PBF LB traffic is always selected to
+ * send to BRB LB.
+ */
+#define NIG_REG_P0_TX_MNG_HOST_ENABLE				 0x182f4
 #define NIG_REG_P1_HWPFC_ENABLE					 0x181d0
 #define NIG_REG_P1_MAC_IN_EN					 0x185c0
 /* [RW 1] Output enable for TX MAC interface */
@@ -2418,6 +2428,12 @@
 #define NIG_REG_P1_TX_ARB_PRIORITY_CLIENT2_MSB			 0x186e4
 /* [R 1] TX FIFO for transmitting data to MAC is empty. */
 #define NIG_REG_P1_TX_MACFIFO_EMPTY				 0x18594
+/* [RW 1] MCP-to-host path enable. Set this bit to enable the routing of MCP
+ * packets to BRB LB interface to forward the packet to the host. All
+ * packets from MCP are forwarded to the network when this bit is cleared -
+ * regardless of the configured destination in tx_mng_destination register.
+ */
+#define NIG_REG_P1_TX_MNG_HOST_ENABLE				 0x182f8
 /* [R 1] FIFO empty status of the MCP TX FIFO used for storing MCP packets
    forwarded to the host. */
 #define NIG_REG_P1_TX_MNG_HOST_FIFO_EMPTY			 0x182b8
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 614981c..b8b4b74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -5350,12 +5350,24 @@ static int bnx2x_func_chk_transition(struct bnx2x *bp,
 		else if ((cmd == BNX2X_F_CMD_AFEX_VIFLISTS) &&
 			 (!test_bit(BNX2X_F_CMD_STOP, &o->pending)))
 			next_state = BNX2X_F_STATE_STARTED;
+
+		/* Switch_update ramrod can be sent in either started or
+		 * tx_stopped state, and it doesn't change the state.
+		 */
+		else if ((cmd == BNX2X_F_CMD_SWITCH_UPDATE) &&
+			 (!test_bit(BNX2X_F_CMD_STOP, &o->pending)))
+			next_state = BNX2X_F_STATE_STARTED;
+
 		else if (cmd == BNX2X_F_CMD_TX_STOP)
 			next_state = BNX2X_F_STATE_TX_STOPPED;

 		break;
 	case BNX2X_F_STATE_TX_STOPPED:
-		if (cmd == BNX2X_F_CMD_TX_START)
+		if ((cmd == BNX2X_F_CMD_SWITCH_UPDATE) &&
+		    (!test_bit(BNX2X_F_CMD_STOP, &o->pending)))
+			next_state = BNX2X_F_STATE_TX_STOPPED;
+
+		else if (cmd == BNX2X_F_CMD_TX_START)
 			next_state = BNX2X_F_STATE_STARTED;

 		break;
@@ -5637,6 +5649,28 @@ static inline int bnx2x_func_send_start(struct bnx2x *bp,
 			     U64_LO(data_mapping), NONE_CONNECTION_TYPE);
 }

+static inline int bnx2x_func_send_switch_update(struct bnx2x *bp,
+					struct bnx2x_func_state_params *params)
+{
+	struct bnx2x_func_sp_obj *o = params->f_obj;
+	struct function_update_data *rdata =
+		(struct function_update_data *)o->rdata;
+	dma_addr_t data_mapping = o->rdata_mapping;
+	struct bnx2x_func_switch_update_params *switch_update_params =
+		&params->params.switch_update;
+
+	memset(rdata, 0, sizeof(*rdata));
+
+	/* Fill the ramrod data with provided parameters */
+	rdata->tx_switch_suspend_change_flg = 1;
+	rdata->tx_switch_suspend = switch_update_params->suspend;
+	rdata->echo = SWITCH_UPDATE;
+
+	return bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_FUNCTION_UPDATE, 0,
+			     U64_HI(data_mapping),
+			     U64_LO(data_mapping), NONE_CONNECTION_TYPE);
+}
+
 static inline int bnx2x_func_send_afex_update(struct bnx2x *bp,
 					 struct bnx2x_func_state_params *params)
 {
@@ -5657,6 +5691,7 @@ static inline int bnx2x_func_send_afex_update(struct bnx2x *bp,
 		cpu_to_le16(afex_update_params->afex_default_vlan);
 	rdata->allowed_priorities_change_flg = 1;
 	rdata->allowed_priorities = afex_update_params->allowed_priorities;
+	rdata->echo = AFEX_UPDATE;

 	/*  No need for an explicit memory barrier here as long we would
 	 *  need to ensure the ordering of writing to the SPQ element
@@ -5773,6 +5808,8 @@ static int bnx2x_func_send_cmd(struct bnx2x *bp,
 		return bnx2x_func_send_tx_stop(bp, params);
 	case BNX2X_F_CMD_TX_START:
 		return bnx2x_func_send_tx_start(bp, params);
+	case BNX2X_F_CMD_SWITCH_UPDATE:
+		return bnx2x_func_send_switch_update(bp, params);
 	default:
 		BNX2X_ERR("Unknown command: %d\n", params->cmd);
 		return -EINVAL;
@@ -5818,16 +5855,30 @@ int bnx2x_func_state_change(struct bnx2x *bp,
 			    struct bnx2x_func_state_params *params)
 {
 	struct bnx2x_func_sp_obj *o = params->f_obj;
-	int rc;
+	int rc, cnt = 300;
 	enum bnx2x_func_cmd cmd = params->cmd;
 	unsigned long *pending = &o->pending;

 	mutex_lock(&o->one_pending_mutex);

 	/* Check that the requested transition is legal */
-	if (o->check_transition(bp, o, params)) {
+	rc = o->check_transition(bp, o, params);
+	if ((rc == -EBUSY) &&
+	    (test_bit(RAMROD_RETRY, &params->ramrod_flags))) {
+		while ((rc == -EBUSY) && (--cnt > 0)) {
+			mutex_unlock(&o->one_pending_mutex);
+			msleep(10);
+			mutex_lock(&o->one_pending_mutex);
+			rc = o->check_transition(bp, o, params);
+		}
+		if (rc == -EBUSY) {
+			mutex_unlock(&o->one_pending_mutex);
+			BNX2X_ERR("timeout waiting for previous ramrod completion\n");
+			return rc;
+		}
+	} else if (rc) {
 		mutex_unlock(&o->one_pending_mutex);
-		return -EINVAL;
+		return rc;
 	}

 	/* Set "pending" bit */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index acf2fe4..adbd91b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -40,6 +40,12 @@ enum {
 	 * pending commands list.
 	 */
 	RAMROD_CONT,
+	/* If there is another pending ramrod, wait until it finishes and
+	 * re-try to submit this one. This flag can be set only in sleepable
+	 * context, and should not be set from the context that completes the
+	 * ramrods as deadlock will occur.
+	 */
+	RAMROD_RETRY,
 };

 typedef enum {
@@ -1061,6 +1067,7 @@ enum bnx2x_func_cmd {
 	BNX2X_F_CMD_AFEX_VIFLISTS,
 	BNX2X_F_CMD_TX_STOP,
 	BNX2X_F_CMD_TX_START,
+	BNX2X_F_CMD_SWITCH_UPDATE,
 	BNX2X_F_CMD_MAX,
 };

@@ -1103,6 +1110,10 @@ struct bnx2x_func_start_params {
 	u8 network_cos_mode;
 };

+struct bnx2x_func_switch_update_params {
+	u8 suspend;
+};
+
 struct bnx2x_func_afex_update_params {
 	u16 vif_id;
 	u16 afex_default_vlan;
@@ -1136,6 +1147,7 @@ struct bnx2x_func_state_params {
 		struct bnx2x_func_hw_init_params hw_init;
 		struct bnx2x_func_hw_reset_params hw_reset;
 		struct bnx2x_func_start_params start;
+		struct bnx2x_func_switch_update_params switch_update;
 		struct bnx2x_func_afex_update_params afex_update;
 		struct bnx2x_func_afex_viflists_params afex_viflists;
 		struct bnx2x_func_tx_start_params tx_start;
--
1.7.10
