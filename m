From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch] bnx2x: Add run-time CNIC support
Date: Sun, 8 Jul 2012 12:48:34 +0300
Message-ID: <1341740914-3181-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4344 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab2GHJt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2012 05:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the BCM_CNIC compilation flag with a run-time flag.
This is mainly important for the SR-IOV driver, as this driver will share the
same code with the PF/hypervisor driver. Since storage is not supported in
SR-IOV (while is usually enabled in the non-SR-IOV driver), we don't want to
waste resources on it.
In addition this change makes the code prettier.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this patch to net-next.

Thanks,
Merav

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   74 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  179 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   17 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    9 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |    2 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  579 ++++++++++----------
 7 files changed, 396 insertions(+), 468 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 362d16f..53f2cb8 100644
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

@@ -251,20 +243,13 @@ enum {

 #define BNX2X_CNIC_START_ETH_CID(bp)	(BNX2X_NUM_NON_CNIC_QUEUES(bp) *\
 					 (bp)->max_cos)
+
 	/* iSCSI L2 */
 #define	BNX2X_ISCSI_ETH_CID(bp)		(BNX2X_CNIC_START_ETH_CID(bp))
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
+#define CNIC_ENABLED(bp)		((bp)->cnic_enabled)

 #define AEU_IN_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR \
 	AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR
@@ -297,9 +282,7 @@ enum {
 	OOO_TXQ_IDX_OFFSET,
 };
 #define MAX_ETH_TXQ_IDX(bp)	(BNX2X_NUM_NON_CNIC_QUEUES(bp) * (bp)->max_cos)
-#ifdef BCM_CNIC
 #define FCOE_TXQ_IDX(bp)	(MAX_ETH_TXQ_IDX(bp) + FCOE_TXQ_IDX_OFFSET)
-#endif

 /* fast path */
 /*
@@ -584,15 +567,10 @@ struct bnx2x_fastpath {
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
+#define IS_FCOE_FP(fp)		((fp)->index == FCOE_IDX((fp)->bp) && \
+					       CNIC_ENABLED((fp)->bp))
+#define IS_FCOE_IDX(idx)	(CNIC_ENABLED(bp) && ((idx) == FCOE_IDX(bp)))


 /* MC hsi */
@@ -979,18 +957,15 @@ union cdu_context {
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
@@ -1008,8 +983,6 @@ union cdu_context {
 #define SRC_T2_SZ		SRC_ILT_SZ
 #define SRC_ILT_LINES		DIV_ROUND_UP(SRC_ILT_SZ, SRC_ILT_PAGE_SZ)

-#endif
-
 #define MAX_DMAE_C		8

 /* DMA memory not used in fastpath */
@@ -1203,7 +1176,6 @@ struct bnx2x {
 	struct bnx2x_sp_objs	*sp_objs;
 	struct bnx2x_fp_stats	*fp_stats;
 	struct bnx2x_fp_txdata	*bnx2x_txq;
-	int			bnx2x_txq_size;
 	void __iomem		*regview;
 	void __iomem		*doorbells;
 	u16			db_size;
@@ -1326,6 +1298,8 @@ struct bnx2x {
 #define NO_ISCSI_OOO(bp)	((bp)->flags & NO_ISCSI_OOO_FLAG)
 #define NO_FCOE(bp)		((bp)->flags & NO_FCOE_FLAG)

+	int			cnic_enabled;
+
 	int			pm_cap;
 	int			mrrs;

@@ -1396,6 +1370,9 @@ struct bnx2x {
 #define BNX2X_MAX_COS			3
 #define BNX2X_MAX_TX_COS		2
 	int			num_queues;
+	uint			num_ethernet_queues;
+	uint			num_cnic_queues;
+	/* The number of queues to whom MSI-X vector and napi was allocated */
 	int			num_napi_queues;
 	int			disable_tpa;

@@ -1409,6 +1386,7 @@ struct bnx2x {
 	u8			igu_dsb_id;
 	u8			igu_base_sb;
 	u8			igu_sb_cnt;
+	u8			min_msix_vec_cnt;

 	dma_addr_t		def_status_blk_mapping;

@@ -1454,16 +1432,16 @@ struct bnx2x {
  * Maximum supported number of RSS queues: number of IGU SBs minus one that goes
  * to CNIC.
  */
-#define BNX2X_MAX_RSS_COUNT(bp)	((bp)->igu_sb_cnt - CNIC_PRESENT)
+#define BNX2X_MAX_RSS_COUNT(bp)	((bp)->igu_sb_cnt - CNIC_ENABLED(bp))

 /*
  * Maximum CID count that might be required by the bnx2x:
  * Max RSS * Max_Tx_Multi_Cos + FCoE + iSCSI
  */
 #define BNX2X_L2_CID_COUNT(bp)	(BNX2X_NUM_ETH_QUEUES(bp) * BNX2X_MULTI_TX_COS \
-				+ NON_ETH_CONTEXT_USE + CNIC_PRESENT)
+				+ 2 * CNIC_ENABLED(bp))
 #define BNX2X_L2_MAX_CID(bp)	(BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS \
-				+ NON_ETH_CONTEXT_USE + CNIC_PRESENT)
+				+ 2 * CNIC_ENABLED(bp))
 #define L2_ILT_LINES(bp)	(DIV_ROUND_UP(BNX2X_L2_CID_COUNT(bp),\
 					ILT_PAGE_CIDS))

@@ -1471,9 +1449,6 @@ struct bnx2x {

 	int			dropless_fc;

-#ifdef BCM_CNIC
-	u32			cnic_flags;
-#define BNX2X_CNIC_FLAG_MAC_SET		1
 	void			*t2;
 	dma_addr_t		t2_mapping;
 	struct cnic_ops	__rcu	*cnic_ops;
@@ -1494,7 +1469,6 @@ struct bnx2x {

 	/* Start index of the "special" (CNIC related) L2 cleints */
 	u8				cnic_base_cl_id;
-#endif

 	int			dmae_ready;
 	/* used to synchronize dmae accesses */
@@ -1623,9 +1597,10 @@ struct bnx2x {
 /* Tx queues may be less or equal to Rx queues */
 extern int num_queues;
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
-#define BNX2X_NUM_ETH_QUEUES(bp) (BNX2X_NUM_QUEUES(bp) - NON_ETH_CONTEXT_USE)
+#define BNX2X_INIT_NUM_QUEUES(bp)	((bp)->init_num_queues)
+#define BNX2X_NUM_ETH_QUEUES(bp) ((bp)->num_ethernet_queues)
 #define BNX2X_NUM_NON_CNIC_QUEUES(bp)	(BNX2X_NUM_QUEUES(bp) - \
-					 NON_ETH_CONTEXT_USE)
+					 (bp)->num_cnic_queues)
 #define BNX2X_NUM_RX_QUEUES(bp)	BNX2X_NUM_QUEUES(bp)

 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
@@ -2167,7 +2142,6 @@ void bnx2x_notify_link_changed(struct bnx2x *bp);
 #define BNX2X_MF_SD_PROTOCOL(bp) \
 	((bp)->mf_config[BP_VN(bp)] & FUNC_MF_CFG_PROTOCOL_MASK)

-#ifdef BCM_CNIC
 #define BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) \
 	(BNX2X_MF_SD_PROTOCOL(bp) == FUNC_MF_CFG_PROTOCOL_ISCSI)

@@ -2180,13 +2154,13 @@ void bnx2x_notify_link_changed(struct bnx2x *bp);
 #define BNX2X_MF_EXT_PROTOCOL_FCOE(bp)  ((bp)->mf_ext_config & \
 					 MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)

-#define IS_MF_FCOE_AFEX(bp) (IS_MF_AFEX(bp) && BNX2X_MF_EXT_PROTOCOL_FCOE(bp))
+#define IS_MF_FCOE_AFEX(bp) (IS_MF_AFEX(bp) && \
+			     BNX2X_MF_EXT_PROTOCOL_FCOE(bp) && CNIC_ENABLED(bp))
+
 #define IS_MF_STORAGE_SD(bp) (IS_MF_SD(bp) && \
 				(BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) || \
 				 BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)))
-#else
-#define IS_MF_FCOE_AFEX(bp)	false
-#endif
+


 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 00951b3..8ac94b8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1334,11 +1334,11 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp, int nvecs)
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
 	   bp->msix_table[offset].vector);
 	offset++;
-#ifdef BCM_CNIC
-	if (nvecs == offset)
-		return;
-	offset++;
-#endif
+	if (CNIC_ENABLED(bp)) {
+		if (nvecs == offset)
+			return;
+		offset++;
+	}

 	for_each_eth_queue(bp, i) {
 		if (nvecs == offset)
@@ -1355,7 +1355,7 @@ void bnx2x_free_irq(struct bnx2x *bp)
 	if (bp->flags & USING_MSIX_FLAG &&
 	    !(bp->flags & USING_SINGLE_MSIX_FLAG))
 		bnx2x_free_msix_irqs(bp, BNX2X_NUM_ETH_QUEUES(bp) +
-				     CNIC_PRESENT + 1);
+				     CNIC_ENABLED(bp) + 1);
 	else
 		free_irq(bp->dev->irq, bp->dev);
 }
@@ -1369,12 +1369,14 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 	   bp->msix_table[0].entry);
 	msix_vec++;

-#ifdef BCM_CNIC
-	bp->msix_table[msix_vec].entry = msix_vec;
-	BNX2X_DEV_INFO("msix_table[%d].entry = %d (CNIC)\n",
-	   bp->msix_table[msix_vec].entry, bp->msix_table[msix_vec].entry);
-	msix_vec++;
-#endif
+
+	if (CNIC_ENABLED(bp)) {
+		bp->msix_table[msix_vec].entry = msix_vec;
+		BNX2X_DEV_INFO("msix_table[%d].entry = %d (CNIC)\n",
+			       msix_vec, bp->msix_table[msix_vec].entry);
+		msix_vec++;
+	}
+
 	/* We need separate vectors for ETH queues only (not FCoE) */
 	for_each_eth_queue(bp, i) {
 		bp->msix_table[msix_vec].entry = msix_vec;
@@ -1383,7 +1385,7 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		msix_vec++;
 	}

-	req_cnt = BNX2X_NUM_ETH_QUEUES(bp) + CNIC_PRESENT + 1;
+	req_cnt = BNX2X_NUM_ETH_QUEUES(bp) + CNIC_ENABLED(bp) + 1;

 	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], req_cnt);

@@ -1391,7 +1393,7 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 	 * reconfigure number of tx/rx queues according to available
 	 * MSI-X vectors
 	 */
-	if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
+	if (rc >= BNX2X_MIN_MSIX_VEC_CNT(bp)) {
 		/* how less vectors we will have? */
 		int diff = req_cnt - rc;

@@ -1406,7 +1408,8 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 		/*
 		 * decrease number of queues by number of unallocated entries
 		 */
-		bp->num_queues -= diff;
+		bp->num_ethernet_queues -= diff;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;

 		BNX2X_DEV_INFO("New queue configuration set: %d\n",
 			       bp->num_queues);
@@ -1451,9 +1454,9 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		return -EBUSY;
 	}

-#ifdef BCM_CNIC
-	offset++;
-#endif
+	if (CNIC_ENABLED(bp))
+		offset++;
+
 	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
@@ -1472,7 +1475,7 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	}

 	i = BNX2X_NUM_ETH_QUEUES(bp);
-	offset = 1 + CNIC_PRESENT;
+	offset = 1 + CNIC_ENABLED(bp);
 	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d ... fp[%d] %d\n",
 	       bp->msix_table[0].vector,
 	       0, bp->msix_table[offset].vector,
@@ -1579,7 +1582,6 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct bnx2x *bp = netdev_priv(dev);

-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp)) {
 		struct ethhdr *hdr = (struct ethhdr *)skb->data;
 		u16 ether_type = ntohs(hdr->h_proto);
@@ -1596,7 +1598,7 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 		if ((ether_type == ETH_P_FCOE) || (ether_type == ETH_P_FIP))
 			return bnx2x_fcoe_tx(bp, txq_index);
 	}
-#endif
+
 	/* select a non-FCoE queue */
 	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp));
 }
@@ -1605,15 +1607,16 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 void bnx2x_set_num_queues(struct bnx2x *bp)
 {
 	/* RSS queues */
-	bp->num_queues = bnx2x_calc_num_queues(bp);
+	bp->num_ethernet_queues = bnx2x_calc_num_queues(bp);

-#ifdef BCM_CNIC
 	/* override in STORAGE SD modes */
-	if (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))
-		bp->num_queues = 1;
-#endif
+	if (CNIC_ENABLED(bp) && (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)))
+		bp->num_ethernet_queues = 1;
+
 	/* Add special queues */
-	bp->num_queues += NON_ETH_CONTEXT_USE;
+	bp->num_cnic_queues = CNIC_ENABLED(bp); /* For FCOE */
+
+	bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;

 	BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
 }
@@ -1645,15 +1648,13 @@ static int bnx2x_set_real_num_queues(struct bnx2x *bp)
 	int rc, tx, rx;

 	tx = BNX2X_NUM_ETH_QUEUES(bp) * bp->max_cos;
-	rx = BNX2X_NUM_QUEUES(bp) - NON_ETH_CONTEXT_USE;
+	rx = BNX2X_NUM_ETH_QUEUES(bp);

 /* account for fcoe queue */
-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp)) {
-		rx += FCOE_PRESENT;
-		tx += FCOE_PRESENT;
+		rx++;
+		tx++;
 	}
-#endif

 	rc = netif_set_real_num_tx_queues(bp->dev, tx);
 	if (rc) {
@@ -1946,10 +1947,8 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 		fp->max_cos = 1;

 	/* Init txdata pointers */
-#ifdef BCM_CNIC
 	if (IS_FCOE_FP(fp))
 		fp->txdata_ptr[0] = &bp->bnx2x_txq[FCOE_TXQ_IDX(bp)];
-#endif
 	if (IS_ETH_FP(fp))
 		for_each_cos_in_tx_queue(fp, cos)
 			fp->txdata_ptr[cos] = &bp->bnx2x_txq[cos *
@@ -1967,14 +1966,12 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	else if (bp->flags & GRO_ENABLE_FLAG)
 		fp->mode = TPA_MODE_GRO;

-#ifdef BCM_CNIC
+
 	/* We don't want TPA on an FCoE L2 ring */
 	if (IS_FCOE_FP(fp))
 		fp->disable_tpa = 1;
-#endif
 }

-
 /* must be called with rtnl_lock */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
@@ -2009,8 +2006,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	DP(NETIF_MSG_IFUP, "num queues: %d", bp->num_queues);
 	for_each_queue(bp, i)
 		bnx2x_bz_fp(bp, i);
-	memset(bp->bnx2x_txq, 0, bp->bnx2x_txq_size *
-	       sizeof(struct bnx2x_fp_txdata));
+	memset(bp->bnx2x_txq, 0, (BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS +
+				  bp->num_cnic_queues) *
+				  sizeof(struct bnx2x_fp_txdata));


 	/* Set the receive queues buffer size */
@@ -2176,10 +2174,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		LOAD_ERROR_EXIT(bp, load_error3);
 	}

-#ifdef BCM_CNIC
-	/* Enable Timer scan */
-	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 1);
-#endif
+	if (CNIC_ENABLED(bp))
+		/* Enable Timer scan */
+		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 1);

 	for_each_nondefault_queue(bp, i) {
 		rc = bnx2x_setup_queue(bp, &bp->fp[i], 0);
@@ -2249,14 +2246,14 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
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
+	if (CNIC_ENABLED(bp)) {
+		/* re-read iscsi info */
+		bnx2x_get_iscsi_info(bp);
+		bnx2x_setup_cnic_irq_info(bp);
+		bnx2x_setup_cnic_info(bp);
+		if (bp->state == BNX2X_STATE_OPEN)
+			bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
+	}

 	/* mark driver is loaded in shmem2 */
 	if (SHMEM2_HAS(bp, drv_capabilities_flag)) {
@@ -2282,10 +2279,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)

 #ifndef BNX2X_STOP_ON_ERROR
 load_error4:
-#ifdef BCM_CNIC
-	/* Disable Timer scan */
-	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
-#endif
+	if (CNIC_ENABLED(bp))
+		/* Disable Timer scan */
+		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
 load_error3:
 	bnx2x_int_disable_sync(bp, 1);

@@ -2362,9 +2358,8 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bnx2x_tx_disable(bp);
 	netdev_reset_tc(bp->dev);

-#ifdef BCM_CNIC
-	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
-#endif
+	if (CNIC_ENABLED(bp))
+		bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);

 	bp->rx_mode = BNX2X_RX_MODE_NONE;

@@ -2533,7 +2528,7 @@ int bnx2x_poll(struct napi_struct *napi, int budget)

 		/* Fall out from the NAPI loop if needed */
 		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
-#ifdef BCM_CNIC
+
 			/* No need to update SB for FCoE L2 ring as long as
 			 * it's connected to the default SB and the SB
 			 * has been updated when NAPI was scheduled.
@@ -2542,7 +2537,6 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 				napi_complete(napi);
 				break;
 			}
-#endif

 			bnx2x_update_fpsb_idx(fp);
 			/* bnx2x_has_rx_work() reads the status block,
@@ -2923,7 +2917,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq_index = skb_get_queue_mapping(skb);
 	txq = netdev_get_tx_queue(dev, txq_index);

-	BUG_ON(txq_index >= MAX_ETH_TXQ_IDX(bp) + FCOE_PRESENT);
+	BUG_ON(txq_index >= MAX_ETH_TXQ_IDX(bp) + CNIC_ENABLED(bp));

 	txdata = &bp->bnx2x_txq[txq_index];

@@ -3308,13 +3302,11 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 		return -EINVAL;
 	}

-#ifdef BCM_CNIC
-	if ((IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)) &&
+	if (CNIC_ENABLED(bp) && (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)) &&
 	    !is_zero_ether_addr(addr->sa_data)) {
 		BNX2X_ERR("Can't configure non-zero address on iSCSI or FCoE functions in MF-SD mode\n");
 		return -EINVAL;
 	}
-#endif

 	if (netif_running(dev))  {
 		rc = bnx2x_set_eth_mac(bp, false);
@@ -3338,13 +3330,11 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
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
@@ -3356,9 +3346,8 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
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
@@ -3488,14 +3477,11 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	u8 cos;
 	int rx_ring_size = 0;

-#ifdef BCM_CNIC
-	if (!bp->rx_ring_size &&
+	if (CNIC_ENABLED(bp) && !bp->rx_ring_size &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
 		rx_ring_size = MIN_RX_SIZE_NONTPA;
 		bp->rx_ring_size = rx_ring_size;
-	} else
-#endif
-	if (!bp->rx_ring_size) {
+	} else if (!bp->rx_ring_size) {
 		u32 cfg = SHMEM_RD(bp,
 			     dev_info.port_hw_config[BP_PORT(bp)].default_cfg);

@@ -3516,9 +3502,8 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)

 	/* Common */
 	sb = &bnx2x_fp(bp, index, status_blk);
-#ifdef BCM_CNIC
+
 	if (!IS_FCOE_IDX(index)) {
-#endif
 		/* status blocks */
 		if (!CHIP_IS_E1x(bp))
 			BNX2X_PCI_ALLOC(sb->e2_sb,
@@ -3528,9 +3513,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 			BNX2X_PCI_ALLOC(sb->e1x_sb,
 				&bnx2x_fp(bp, index, status_blk_mapping),
 			    sizeof(struct host_hc_status_block_e1x));
-#ifdef BCM_CNIC
 	}
-#endif

 	/* FCoE Queue uses Default SB and doesn't ACK the SB, thus no need to
 	 * set shortcuts for it.
@@ -3622,7 +3605,6 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 	if (bnx2x_alloc_fp_mem_at(bp, 0))
 		return -ENOMEM;

-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp))
 		/* FCoE */
 		if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX(bp)))
@@ -3630,7 +3612,6 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 			 * NO_FCOE_FLAG
 			 */
 			return -ENOMEM;
-#endif

 	/* RSS */
 	for_each_nondefault_eth_queue(bp, i)
@@ -3642,17 +3623,18 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 		int delta = BNX2X_NUM_ETH_QUEUES(bp) - i;

 		WARN_ON(delta < 0);
-#ifdef BCM_CNIC
-		/**
-		 * move non eth FPs next to last eth FP
-		 * must be done in that order
-		 * FCOE_IDX < FWD_IDX < OOO_IDX
-		 */
+		if (CNIC_ENABLED(bp))
+			/**
+			 * move non eth FPs next to last eth FP
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
@@ -3677,7 +3659,7 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 	struct msix_entry *tbl;
 	struct bnx2x_ilt *ilt;
 	int msix_table_size = 0;
-	int fp_array_size;
+	int fp_array_size, txq_array_size;
 	int i;

 	/*
@@ -3687,8 +3669,7 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 	msix_table_size = bp->igu_sb_cnt + 1;

 	/* fp array: RSS plus CNIC related L2 queues */
-	fp_array_size = BNX2X_MAX_RSS_COUNT(bp) + NON_ETH_CONTEXT_USE;
-	BNX2X_DEV_INFO("fp_array_size %d", fp_array_size);
+	fp_array_size = BNX2X_MAX_RSS_COUNT(bp) + CNIC_ENABLED(bp);

 	fp = kcalloc(fp_array_size, sizeof(*fp), GFP_KERNEL);
 	if (!fp)
@@ -3716,12 +3697,10 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 		goto alloc_err;

 	/* Allocate memory for the transmission queues array */
-	bp->bnx2x_txq_size = BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS;
-#ifdef BCM_CNIC
-	bp->bnx2x_txq_size++;
-#endif
-	bp->bnx2x_txq = kcalloc(bp->bnx2x_txq_size,
-				sizeof(struct bnx2x_fp_txdata), GFP_KERNEL);
+	txq_array_size = BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS +
+			 CNIC_ENABLED(bp);
+	bp->bnx2x_txq = kcalloc(txq_array_size, sizeof(struct bnx2x_fp_txdata),
+				GFP_KERNEL);
 	if (!bp->bnx2x_txq)
 		goto alloc_err;

@@ -3804,7 +3783,7 @@ int bnx2x_get_link_cfg_idx(struct bnx2x *bp)
 	return LINK_CONFIG_IDX(sel_phy_idx);
 }

-#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
+#ifdef NETDEV_FCOE_WWNN
 int bnx2x_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
 {
 	struct bnx2x *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 53659f3..46068e5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -229,7 +229,6 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance);
  * @dev_instance:	private instance
  */
 irqreturn_t bnx2x_interrupt(int irq, void *dev_instance);
-#ifdef BCM_CNIC

 /**
  * bnx2x_cnic_notify - send command to cnic driver
@@ -253,8 +252,6 @@ void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
  */
 void bnx2x_setup_cnic_info(struct bnx2x *bp);

-#endif
-
 /**
  * bnx2x_int_enable - enable HW interrupts.
  *
@@ -537,7 +534,7 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
  */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu);

-#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
+#ifdef NETDEV_FCOE_WWNN
 /**
  * bnx2x_fcoe_get_wwn - return the requested WWN value for this port
  *
@@ -971,11 +968,9 @@ static inline u8 bnx2x_stats_id(struct bnx2x_fastpath *fp)
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
@@ -1093,7 +1088,6 @@ static inline void bnx2x_init_txdata(struct bnx2x *bp,
 	   txdata->cid, txdata->txq_index);
 }

-#ifdef BCM_CNIC
 static inline u8 bnx2x_cnic_eth_cl_id(struct bnx2x *bp, u8 cl_idx)
 {
 	return bp->cnic_base_cl_id + cl_idx +
@@ -1153,7 +1147,6 @@ static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 	   fp->index, bp, fp->status_blk.e2_sb, fp->cl_id, fp->fw_sb_id,
 	   fp->igu_sb_id);
 }
-#endif

 static inline int bnx2x_clean_tx_queue(struct bnx2x *bp,
 				       struct bnx2x_fp_txdata *txdata)
@@ -1271,7 +1264,7 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
 	 */
 	return mtu <= SGE_PAGE_SIZE && (U_ETH_SGL_SIZE * fpp) <= MAX_SKB_FRAGS;
 }
-#ifdef BCM_CNIC
+
 /**
  * bnx2x_get_iscsi_info - update iSCSI params according to licensing info.
  *
@@ -1279,7 +1272,6 @@ static inline bool bnx2x_mtu_allows_gro(int mtu)
  *
  */
 void bnx2x_get_iscsi_info(struct bnx2x *bp);
-#endif

 /**
  * bnx2x_link_sync_notify - send notification to other functions.
@@ -1333,11 +1325,10 @@ static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
 {
 	if (is_valid_ether_addr(addr))
 		return true;
-#ifdef BCM_CNIC
-	if (is_zero_ether_addr(addr) &&
+	if (CNIC_ENABLED(bp) && is_zero_ether_addr(addr) &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)))
 		return true;
-#endif
+
 	return false;
 }

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 8a73374..c0f4432 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1912,10 +1912,11 @@ static void bnx2x_dcbnl_get_perm_hw_addr(struct net_device *netdev,
 	/* first the HW mac address */
 	memcpy(perm_addr, netdev->dev_addr, netdev->addr_len);

-#ifdef BCM_CNIC
-	/* second SAN address */
-	memcpy(perm_addr+netdev->addr_len, bp->fip_mac, netdev->addr_len);
-#endif
+
+	if (CNIC_ENABLED(bp))
+		/* second SAN address */
+		memcpy(perm_addr+netdev->addr_len, bp->fip_mac,
+		       netdev->addr_len);
 }

 static void bnx2x_dcbnl_set_pg_tccfg_tx(struct net_device *netdev, int prio,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index bff3129..a384a8d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2890,7 +2890,9 @@ static void bnx2x_change_num_queues(struct bnx2x *bp, int num_rss)
 {
 	bnx2x_del_all_napi(bp);
 	bnx2x_disable_msi(bp);
-	BNX2X_NUM_QUEUES(bp) = num_rss + NON_ETH_CONTEXT_USE;
+	bp->num_ethernet_queues = num_rss;
+	bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
+	BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
 	bnx2x_set_int_mode(bp);
 	bnx2x_add_all_napi(bp);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index fe66d90..e1e66f0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -890,7 +890,6 @@ static void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
 /****************************************************************************
 * SRC initializations
 ****************************************************************************/
-#ifdef BCM_CNIC
 /* called during init func stage */
 static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
 			      dma_addr_t t2_mapping, int src_cid_count)
@@ -915,5 +914,4 @@ static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
 		    U64_HI((u64)t2_mapping +
 			   (src_cid_count-1) * sizeof(struct src_ent)));
 }
-#endif
 #endif /* BNX2X_INIT_OPS_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5b8b521..22912ca 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -773,10 +773,9 @@ void bnx2x_panic_dump(struct bnx2x *bp)

 		/* host sb data */

-#ifdef BCM_CNIC
 		if (IS_FCOE_FP(fp))
 			continue;
-#endif
+
 		BNX2X_ERR("     run indexes (");
 		for (j = 0; j < HC_SB_MAX_SM; j++)
 			pr_cont("0x%x%s",
@@ -1491,9 +1490,9 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 	if (msix) {
 		synchronize_irq(bp->msix_table[0].vector);
 		offset = 1;
-#ifdef BCM_CNIC
-		offset++;
-#endif
+
+		if (CNIC_ENABLED(bp))
+			offset++;
 		for_each_eth_queue(bp, i)
 			synchronize_irq(bp->msix_table[offset++].vector);
 	} else
@@ -1575,9 +1574,7 @@ static bool bnx2x_trylock_leader_lock(struct bnx2x *bp)
 	return bnx2x_trylock_hw_lock(bp, bnx2x_get_leader_lock_resource(bp));
 }

-#ifdef BCM_CNIC
 static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid, u8 err);
-#endif

 void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe)
 {
@@ -1707,7 +1704,7 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];

-		mask = 0x2 << (fp->index + CNIC_PRESENT);
+		mask = 0x2 << (fp->index + CNIC_ENABLED(bp));
 		if (status & mask) {
 			/* Handle Rx or Tx according to SB id */
 			prefetch(fp->rx_cons_sb);
@@ -1719,22 +1716,23 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		}
 	}

-#ifdef BCM_CNIC
-	mask = 0x2;
-	if (status & (mask | 0x1)) {
-		struct cnic_ops *c_ops = NULL;
+	if (CNIC_ENABLED(bp)) {
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
@@ -3057,11 +3055,13 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)

 static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 {
-#ifdef BCM_CNIC
 	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
 	struct fcoe_stats_info *fcoe_stat =
 		&bp->slowpath->drv_info_to_mcp.fcoe_stat;

+	if (!CNIC_ENABLED(bp))
+		return;
+
 	memcpy(fcoe_stat->mac_local + MAC_LEADING_ZERO_CNT,
 	       bp->fip_mac, ETH_ALEN);

@@ -3144,16 +3144,17 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)

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

+	if (!CNIC_ENABLED(bp))
+		return;
+
 	memcpy(iscsi_stat->mac_local + MAC_LEADING_ZERO_CNT,
 	       bp->cnic_eth_dev.iscsi_mac, ETH_ALEN);

@@ -3162,7 +3163,6 @@ static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)

 	/* ask L5 driver to add data to the struct */
 	bnx2x_cnic_notify(bp, CNIC_CTL_ISCSI_STATS_GET_CMD);
-#endif
 }

 /* called due to MCP event (on pmf):
@@ -4568,7 +4568,6 @@ static void bnx2x_update_eq_prod(struct bnx2x *bp, u16 prod)
 	mmiowb(); /* keep prod updates ordered */
 }

-#ifdef BCM_CNIC
 static int  bnx2x_cnic_handle_cfc_del(struct bnx2x *bp, u32 cid,
 				      union event_ring_elem *elem)
 {
@@ -4590,7 +4589,6 @@ static int  bnx2x_cnic_handle_cfc_del(struct bnx2x *bp, u32 cid,
 	bnx2x_cnic_cfc_comp(bp, cid, err);
 	return 0;
 }
-#endif

 static void bnx2x_handle_mcast_eqe(struct bnx2x *bp)
 {
@@ -4631,11 +4629,9 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,
 	switch (elem->message.data.eth_event.echo >> BNX2X_SWCID_SHIFT) {
 	case BNX2X_FILTER_MAC_PENDING:
 		DP(BNX2X_MSG_SP, "Got SETUP_MAC completions\n");
-#ifdef BCM_CNIC
-		if (cid == BNX2X_ISCSI_ETH_CID(bp))
+		if (CNIC_ENABLED(bp) && (cid == BNX2X_ISCSI_ETH_CID(bp)))
 			vlan_mac_obj = &bp->iscsi_l2_mac_obj;
 		else
-#endif
 			vlan_mac_obj = &bp->sp_objs[cid].mac_obj;

 		break;
@@ -4661,9 +4657,7 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,

 }

-#ifdef BCM_CNIC
 static void bnx2x_set_iscsi_eth_rx_mode(struct bnx2x *bp, bool start);
-#endif

 static void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
 {
@@ -4674,14 +4668,12 @@ static void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
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
@@ -4743,7 +4735,6 @@ static void bnx2x_after_function_update(struct bnx2x *bp)
 				  q);
 	}

-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp)) {
 		fp = &bp->fp[FCOE_IDX(bp)];
 		queue_params.q_obj = &bnx2x_sp_obj(bp, fp).q_obj;
@@ -4766,22 +4757,16 @@ static void bnx2x_after_function_update(struct bnx2x *bp)
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
+	if (CNIC_ENABLED(bp) && (cid == BNX2X_FCOE_ETH_CID(bp)))
 		return &bnx2x_fcoe_sp_obj(bp, q_obj);
 	else
-#endif
 		return &bp->sp_objs[CID_TO_FP(cid, bp)].q_obj;
 }

@@ -4843,10 +4828,11 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			 */
 			DP(BNX2X_MSG_SP,
 			   "got delete ramrod for MULTI[%d]\n", cid);
-#ifdef BCM_CNIC
-			if (!bnx2x_cnic_handle_cfc_del(bp, cid, elem))
+
+			if (CNIC_ENABLED(bp) &&
+			    !bnx2x_cnic_handle_cfc_del(bp, cid, elem))
 				goto next_spqe;
-#endif
+
 			q_obj = bnx2x_cid_to_q_obj(bp, cid);

 			if (q_obj->complete_cmd(bp, q_obj, BNX2X_Q_CMD_CFC_DEL))
@@ -4995,11 +4981,10 @@ static void bnx2x_sp_task(struct work_struct *work)

 	/* SP events: STAT_QUERY and others */
 	if (status & BNX2X_DEF_SB_IDX) {
-#ifdef BCM_CNIC
 		struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);

-		if ((!NO_FCOE(bp)) &&
-			(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+		if (!NO_FCOE(bp) &&
+		    (bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 			/*
 			 * Prevent local bottom-halves from running as
 			 * we are going to change the local NAPI list.
@@ -5008,7 +4993,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 			napi_schedule(&bnx2x_fcoe(bp, napi));
 			local_bh_enable();
 		}
-#endif
+
 		/* Handle EQ completions */
 		bnx2x_eq_int(bp);

@@ -5046,8 +5031,7 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif

-#ifdef BCM_CNIC
-	{
+	if (CNIC_ENABLED(bp)) {
 		struct cnic_ops *c_ops;

 		rcu_read_lock();
@@ -5056,7 +5040,6 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 			c_ops->cnic_handler(bp->cnic_data, NULL);
 		rcu_read_unlock();
 	}
-#endif
 	queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);

 	return IRQ_HANDLED;
@@ -5494,12 +5477,10 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 	unsigned long rx_mode_flags = 0, ramrod_flags = 0;
 	unsigned long rx_accept_flags = 0, tx_accept_flags = 0;

-#ifdef BCM_CNIC
 	if (!NO_FCOE(bp))

 		/* Configure rx_mode of FCoE Queue */
 		__set_bit(BNX2X_RX_MODE_FCOE_ETH, &rx_mode_flags);
-#endif

 	switch (bp->rx_mode) {
 	case BNX2X_RX_MODE_NONE:
@@ -5620,12 +5601,12 @@ static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)

 static inline u8 bnx2x_fp_igu_sb_id(struct bnx2x_fastpath *fp)
 {
-	return fp->bp->igu_base_sb + fp->index + CNIC_PRESENT;
+	return fp->bp->igu_base_sb + fp->index + CNIC_ENABLED(fp->bp);
 }

 static inline u8 bnx2x_fp_fw_sb_id(struct bnx2x_fastpath *fp)
 {
-	return fp->bp->base_fw_ndsb + fp->index + CNIC_PRESENT;
+	return fp->bp->base_fw_ndsb + fp->index + CNIC_ENABLED(fp->bp);
 }

 static u8 bnx2x_fp_cl_id(struct bnx2x_fastpath *fp)
@@ -5732,15 +5713,16 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)

 	for_each_eth_queue(bp, i)
 		bnx2x_init_eth_fp(bp, i);
-#ifdef BCM_CNIC
-	if (!NO_FCOE(bp))
-		bnx2x_init_fcoe_fp(bp);

-	bnx2x_init_sb(bp, bp->cnic_sb_mapping,
-		      BNX2X_VF_ID_INVALID, false,
-		      bnx2x_cnic_fw_sb_id(bp), bnx2x_cnic_igu_sb_id(bp));
+	if (CNIC_ENABLED(bp)) {
+		if (!NO_FCOE(bp))
+			bnx2x_init_fcoe_fp(bp);

-#endif
+		bnx2x_init_sb(bp, bp->cnic_sb_mapping,
+			      BNX2X_VF_ID_INVALID, false,
+			      bnx2x_cnic_fw_sb_id(bp),
+			      bnx2x_cnic_igu_sb_id(bp));
+	}

 	/* Initialize MOD_ABS interrupts */
 	bnx2x_init_mod_abs_int(bp, &bp->link_vars, bp->common.chip_id,
@@ -6027,10 +6009,10 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	msleep(50);
 	bnx2x_init_block(bp, BLOCK_BRB1, PHASE_COMMON);
 	bnx2x_init_block(bp, BLOCK_PRS, PHASE_COMMON);
-#ifndef BCM_CNIC
-	/* set NIC mode */
-	REG_WR(bp, PRS_REG_NIC_MODE, 1);
-#endif
+	if (!CNIC_ENABLED(bp)) {
+		/* set NIC mode */
+		REG_WR(bp, PRS_REG_NIC_MODE, 1);
+	}

 	/* Enable inputs of parser neighbor blocks */
 	REG_WR(bp, TSDM_REG_ENABLE_IN1, 0x7fffffff);
@@ -6519,9 +6501,8 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)
 	REG_WR(bp, QM_REG_SOFT_RESET, 1);
 	REG_WR(bp, QM_REG_SOFT_RESET, 0);

-#ifdef BCM_CNIC
-	bnx2x_init_block(bp, BLOCK_TM, PHASE_COMMON);
-#endif
+	if (CNIC_ENABLED(bp))
+		bnx2x_init_block(bp, BLOCK_TM, PHASE_COMMON);

 	bnx2x_init_block(bp, BLOCK_DORQ, PHASE_COMMON);
 	REG_WR(bp, DORQ_REG_DPM_CID_OFST, BNX2X_DB_SHIFT);
@@ -6608,18 +6589,18 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)

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
+	if (CNIC_ENABLED(bp)) {
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
@@ -6784,11 +6765,11 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	/* QM cid (connection) count */
 	bnx2x_qm_init_cid_count(bp, bp->qm_cid_count, INITOP_SET);

-#ifdef BCM_CNIC
-	bnx2x_init_block(bp, BLOCK_TM, init_phase);
-	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
-	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
-#endif
+	if (CNIC_ENABLED(bp)) {
+		bnx2x_init_block(bp, BLOCK_TM, init_phase);
+		REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
+		REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
+	}

 	bnx2x_init_block(bp, BLOCK_DORQ, init_phase);

@@ -6874,9 +6855,8 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 		REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
 	}

-#ifdef BCM_CNIC
-	bnx2x_init_block(bp, BLOCK_SRC, init_phase);
-#endif
+	if (CNIC_ENABLED(bp))
+		bnx2x_init_block(bp, BLOCK_SRC, init_phase);
 	bnx2x_init_block(bp, BLOCK_CDU, init_phase);
 	bnx2x_init_block(bp, BLOCK_CFC, init_phase);

@@ -7079,18 +7059,15 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	}
 	bnx2x_ilt_init_op(bp, INITOP_SET);

-#ifdef BCM_CNIC
-	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
-
-	/* T1 hash bits value determines the T1 number of entries */
-	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, SRC_HASH_BITS);
-#endif
-
-#ifndef BCM_CNIC
-	/* set NIC mode */
-	REG_WR(bp, PRS_REG_NIC_MODE, 1);
-#endif  /* BCM_CNIC */
+	if (CNIC_ENABLED(bp)) {
+		bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);

+		/* T1 hash bits value determines the T1 number of entries */
+		REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, SRC_HASH_BITS);
+	} else {
+		/* set NIC mode */
+		REG_WR(bp, PRS_REG_NIC_MODE, 1);
+	}
 	if (!CHIP_IS_E1x(bp)) {
 		u32 pf_conf = IGU_PF_CONF_FUNC_EN;

@@ -7364,16 +7341,16 @@ void bnx2x_free_mem(struct bnx2x *bp)

 	BNX2X_FREE(bp->ilt->lines);

-#ifdef BCM_CNIC
-	if (!CHIP_IS_E1x(bp))
-		BNX2X_PCI_FREE(bp->cnic_sb.e2_sb, bp->cnic_sb_mapping,
-			       sizeof(struct host_hc_status_block_e2));
-	else
-		BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
-			       sizeof(struct host_hc_status_block_e1x));
+	if (CNIC_ENABLED(bp)) {
+		if (!CHIP_IS_E1x(bp))
+			BNX2X_PCI_FREE(bp->cnic_sb.e2_sb, bp->cnic_sb_mapping,
+				       sizeof(struct host_hc_status_block_e2));
+		else
+			BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
+				       sizeof(struct host_hc_status_block_e1x));

-	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
-#endif
+		BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
+	}

 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, BCM_PAGE_SIZE);

@@ -7447,19 +7424,20 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 {
 	int i, allocated, context_size;

-#ifdef BCM_CNIC
-	if (!CHIP_IS_E1x(bp))
-		/* size = the status block + ramrod buffers */
-		BNX2X_PCI_ALLOC(bp->cnic_sb.e2_sb, &bp->cnic_sb_mapping,
-				sizeof(struct host_hc_status_block_e2));
-	else
-		BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb, &bp->cnic_sb_mapping,
-				sizeof(struct host_hc_status_block_e1x));
-
-	/* allocate searcher T2 table */
-	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
-#endif
+	if (CNIC_ENABLED(bp)) {
+		if (!CHIP_IS_E1x(bp))
+			/* size = the status block + ramrod buffers */
+			BNX2X_PCI_ALLOC(bp->cnic_sb.e2_sb, &bp->cnic_sb_mapping,
+					sizeof(struct host_hc_status_block_e2));
+		else
+			BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb,
+					&bp->cnic_sb_mapping,
+					sizeof(struct
+					       host_hc_status_block_e1x));

+		/* allocate searcher T2 table */
+		BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
+	}

 	BNX2X_PCI_ALLOC(bp->def_status_blk, &bp->def_status_blk_mapping,
 			sizeof(struct host_sp_status_block));
@@ -7467,10 +7445,11 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
 			sizeof(struct bnx2x_slowpath));

-#ifdef BCM_CNIC
-	/* write address to which L5 should insert its values */
-	bp->cnic_eth_dev.addr_drv_info_to_mcp = &bp->slowpath->drv_info_to_mcp;
-#endif
+	if (CNIC_ENABLED(bp))
+		/* write address to which L5 should insert its values */
+		bp->cnic_eth_dev.addr_drv_info_to_mcp =
+			&bp->slowpath->drv_info_to_mcp;
+

 	/* Allocated memory for FW statistics  */
 	if (bnx2x_alloc_fw_stats_mem(bp))
@@ -7587,14 +7566,12 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 {
 	unsigned long ramrod_flags = 0;

-#ifdef BCM_CNIC
-	if (is_zero_ether_addr(bp->dev->dev_addr) &&
+	if (CNIC_ENABLED(bp) && is_zero_ether_addr(bp->dev->dev_addr) &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
 		DP(NETIF_MSG_IFUP | NETIF_MSG_IFDOWN,
 		   "Ignoring Zero MAC for STORAGE SD mode\n");
 		return 0;
 	}
-#endif

 	DP(NETIF_MSG_IFUP, "Adding Eth MAC\n");

@@ -7623,7 +7600,8 @@ void bnx2x_set_int_mode(struct bnx2x *bp)
 		bnx2x_enable_msi(bp);
 		/* falling through... */
 	case INT_MODE_INTx:
-		bp->num_queues = 1 + NON_ETH_CONTEXT_USE;
+		bp->num_ethernet_queues = 1;
+		bp->num_queues = bp->num_ethernet_queues + bp->num_cnic_queues;
 		BNX2X_DEV_INFO("set number of queues to 1\n");
 		break;
 	default:
@@ -7635,9 +7613,12 @@ void bnx2x_set_int_mode(struct bnx2x *bp)
 		    bp->flags & USING_SINGLE_MSIX_FLAG) {
 			/* failed to enable multiple MSI-X */
 			BNX2X_DEV_INFO("Failed to enable multiple MSI-X (%d), set number of queues to %d\n",
-				       bp->num_queues, 1 + NON_ETH_CONTEXT_USE);
+				       bp->num_queues,
+				       1 + bp->num_cnic_queues);

-			bp->num_queues = 1 + NON_ETH_CONTEXT_USE;
+			bp->num_ethernet_queues = 1;
+			bp->num_queues = bp->num_ethernet_queues +
+					 bp->num_cnic_queues;

 			/* Try to enable MSI */
 			if (!(bp->flags & USING_SINGLE_MSIX_FLAG) &&
@@ -7670,9 +7651,9 @@ void bnx2x_ilt_set_info(struct bnx2x *bp)
 	ilt_client->flags = ILT_CLIENT_SKIP_MEM;
 	ilt_client->start = line;
 	line += bnx2x_cid_ilt_lines(bp);
-#ifdef BCM_CNIC
-	line += CNIC_ILT_LINES;
-#endif
+
+	if (CNIC_ENABLED(bp))
+		line += CNIC_ILT_LINES;
 	ilt_client->end = line - 1;

 	DP(NETIF_MSG_IFUP, "ilt client[CDU]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
@@ -7707,47 +7688,47 @@ void bnx2x_ilt_set_info(struct bnx2x *bp)
 	}
 	/* SRC */
 	ilt_client = &ilt->clients[ILT_CLIENT_SRC];
-#ifdef BCM_CNIC
-	ilt_client->client_num = ILT_CLIENT_SRC;
-	ilt_client->page_size = SRC_ILT_PAGE_SZ;
-	ilt_client->flags = 0;
-	ilt_client->start = line;
-	line += SRC_ILT_LINES;
-	ilt_client->end = line - 1;
-
-	DP(NETIF_MSG_IFUP,
-	   "ilt client[SRC]: start %d, end %d, psz 0x%x, flags 0x%x, hw psz %d\n",
-	   ilt_client->start,
-	   ilt_client->end,
-	   ilt_client->page_size,
-	   ilt_client->flags,
-	   ilog2(ilt_client->page_size >> 12));
+	if (CNIC_ENABLED(bp)) {
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
+	} else
+		ilt_client->flags = (ILT_CLIENT_SKIP_INIT |
+				     ILT_CLIENT_SKIP_MEM);

 	/* TM */
 	ilt_client = &ilt->clients[ILT_CLIENT_TM];
-#ifdef BCM_CNIC
-	ilt_client->client_num = ILT_CLIENT_TM;
-	ilt_client->page_size = TM_ILT_PAGE_SZ;
-	ilt_client->flags = 0;
-	ilt_client->start = line;
-	line += TM_ILT_LINES;
-	ilt_client->end = line - 1;
+	if (CNIC_ENABLED(bp)) {
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
+
+	} else
+		ilt_client->flags = (ILT_CLIENT_SKIP_INIT |
+				     ILT_CLIENT_SKIP_MEM);

-#else
-	ilt_client->flags = (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM);
-#endif
 	BUG_ON(line > ILT_MAX_LINES);
 }

@@ -8028,12 +8009,12 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 			   SB_DISABLED);
 	}

-#ifdef BCM_CNIC
-	/* CNIC SB */
-	REG_WR8(bp, BAR_CSTRORM_INTMEM +
-		CSTORM_STATUS_BLOCK_DATA_STATE_OFFSET(bnx2x_cnic_fw_sb_id(bp)),
-		SB_DISABLED);
-#endif
+	if (CNIC_ENABLED(bp)) {
+		/* CNIC SB */
+		REG_WR8(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_STATUS_BLOCK_DATA_STATE_OFFSET
+			(bnx2x_cnic_fw_sb_id(bp)), SB_DISABLED);
+	}
 	/* SP SB */
 	REG_WR8(bp, BAR_CSTRORM_INTMEM +
 		   CSTORM_SP_STATUS_BLOCK_DATA_STATE_OFFSET(func),
@@ -8052,19 +8033,19 @@ static void bnx2x_reset_func(struct bnx2x *bp)
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
+	if (CNIC_ENABLED(bp)) {
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

@@ -10211,12 +10192,15 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 void bnx2x_get_iscsi_info(struct bnx2x *bp)
 {
 	u32 no_flags = NO_ISCSI_FLAG;
-#ifdef BCM_CNIC
 	int port = BP_PORT(bp);
-
 	u32 max_iscsi_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
 				drv_lic_key[port].max_iscsi_conn);

+	if (!CNIC_ENABLED(bp)) {
+		bp->flags |= no_flags;
+		return;
+	}
+
 	/* Get the number of maximum allowed iSCSI connections */
 	bp->cnic_eth_dev.max_iscsi_conn =
 		(max_iscsi_conn & BNX2X_MAX_ISCSI_INIT_CONN_MASK) >>
@@ -10231,12 +10215,8 @@ void bnx2x_get_iscsi_info(struct bnx2x *bp)
 	 */
 	if (!bp->cnic_eth_dev.max_iscsi_conn)
 		bp->flags |= no_flags;
-#else
-	bp->flags |= no_flags;
-#endif
 }

-#ifdef BCM_CNIC
 static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
 {
 	/* Port info */
@@ -10251,16 +10231,18 @@ static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
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

+	if (!CNIC_ENABLED(bp)) {
+		bp->flags |= NO_FCOE_FLAG;
+		return;
+	}
+
 	/* Get the number of maximum allowed FCoE connections */
 	bp->cnic_eth_dev.max_fcoe_conn =
 		(max_fcoe_conn & BNX2X_MAX_FCOE_INIT_CONN_MASK) >>
@@ -10270,37 +10252,33 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 	if (!IS_MF(bp)) {
 		/* Port info */
 		bp->cnic_eth_dev.fcoe_wwn_port_name_hi =
-			SHMEM_RD(bp,
-				dev_info.port_hw_config[port].
+			SHMEM_RD(bp, dev_info.port_hw_config[port].
 				 fcoe_wwn_port_name_upper);
 		bp->cnic_eth_dev.fcoe_wwn_port_name_lo =
-			SHMEM_RD(bp,
-				dev_info.port_hw_config[port].
+			SHMEM_RD(bp, dev_info.port_hw_config[port].
 				 fcoe_wwn_port_name_lower);

 		/* Node info */
 		bp->cnic_eth_dev.fcoe_wwn_node_name_hi =
-			SHMEM_RD(bp,
-				dev_info.port_hw_config[port].
+			SHMEM_RD(bp, dev_info.port_hw_config[port].
 				 fcoe_wwn_node_name_upper);
 		bp->cnic_eth_dev.fcoe_wwn_node_name_lo =
-			SHMEM_RD(bp,
-				dev_info.port_hw_config[port].
+			SHMEM_RD(bp, dev_info.port_hw_config[port].
 				 fcoe_wwn_node_name_lower);
 	} else if (!IS_MF_SD(bp)) {
-		u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
-
 		/*
-		 * Read the WWN info only if the FCoE feature is enabled for
-		 * this function.
+		 * Read the WWN info only if the FCoE feature is
+		 * enabled for this function.
 		 */
-		if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+		if (BNX2X_MF_EXT_PROTOCOL_FCOE(bp))
 			bnx2x_get_ext_wwn_info(bp, func);

-	} else if (IS_MF_FCOE_SD(bp))
+	} else if (IS_MF_FCOE_SD(bp)) {
 		bnx2x_get_ext_wwn_info(bp, func);
+	}

-	BNX2X_DEV_INFO("max_fcoe_conn 0x%x\n", bp->cnic_eth_dev.max_fcoe_conn);
+	BNX2X_DEV_INFO("max_fcoe_conn 0x%x\n",
+		       bp->cnic_eth_dev.max_fcoe_conn);

 	/*
 	 * If maximum allowed number of connections is zero -
@@ -10308,9 +10286,6 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 	 */
 	if (!bp->cnic_eth_dev.max_fcoe_conn)
 		bp->flags |= NO_FCOE_FLAG;
-#else
-	bp->flags |= NO_FCOE_FLAG;
-#endif
 }

 static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
@@ -10324,36 +10299,19 @@ static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
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
-
-	/* Zero primary MAC configuration */
-	memset(bp->dev->dev_addr, 0, ETH_ALEN);

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
 		if (!IS_MF_SD(bp)) {
 			u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
@@ -10365,8 +10323,9 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				bnx2x_set_mac_buf(iscsi_mac, val, val2);
 				BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
 					       iscsi_mac);
-			} else
+			} else {
 				bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
+			}

 			if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD) {
 				val2 = MF_CFG_RD(bp, func_ext_config[func].
@@ -10377,8 +10336,9 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				BNX2X_DEV_INFO("Read FCoE L2 MAC: %pM\n",
 					       fip_mac);

-			} else
+			} else {
 				bp->flags |= NO_FCOE_FLAG;
+			}

 			bp->mf_ext_config = cfg;

@@ -10408,14 +10368,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
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
 				    iscsi_mac_upper);
 		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
@@ -10427,29 +10380,54 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
 				   fcoe_fip_mac_lower);
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
 		bp->flags |= NO_ISCSI_FLAG;
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
+		if (CNIC_ENABLED(bp))
+			bnx2x_get_cnic_mac_hwinfo(bp);
+	} else {
+		/* in SF read MACs from port configuration */
+		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
+		val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
+		bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
+
+		if (CNIC_ENABLED(bp))
+			bnx2x_get_cnic_mac_hwinfo(bp);
+	}
+
+	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
+	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);

 	if (!bnx2x_is_valid_ether_addr(bp, bp->dev->dev_addr))
 		dev_err(&bp->pdev->dev,
@@ -10826,9 +10804,9 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	spin_lock_init(&bp->stats_lock);
-#ifdef BCM_CNIC
-	mutex_init(&bp->cnic_mutex);
-#endif
+	if (CNIC_ENABLED(bp))
+		mutex_init(&bp->cnic_mutex);
+

 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
 	INIT_DELAYED_WORK(&bp->sp_rtnl_task, bnx2x_sp_rtnl_task);
@@ -10867,9 +10845,8 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)

 	bp->disable_tpa = disable_tpa;

-#ifdef BCM_CNIC
-	bp->disable_tpa |= IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp);
-#endif
+	if (CNIC_ENABLED(bp))
+		bp->disable_tpa |= IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp);

 	/* Set TPA flags */
 	if (bp->disable_tpa) {
@@ -10903,12 +10880,10 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
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
@@ -10918,6 +10893,11 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (CHIP_IS_E3B0(bp))
 		bp->max_cos = BNX2X_MULTI_TX_COS_E3B0;

+	if (CNIC_ENABLED(bp))
+		bp->min_msix_vec_cnt = 3;
+	else
+		bp->min_msix_vec_cnt = 2;
+
 	return rc;
 }

@@ -11147,11 +11127,9 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 	}

 	bp->rx_mode = rx_mode;
-#ifdef BCM_CNIC
 	/* handle ISCSI SD mode */
-	if (IS_MF_ISCSI_SD(bp))
+	if (CNIC_ENABLED(bp) && IS_MF_ISCSI_SD(bp))
 		bp->rx_mode = BNX2X_RX_MODE_NONE;
-#endif

 	/* Schedule the rx_mode command */
 	if (test_bit(BNX2X_FILTER_RX_MODE_PENDING, &bp->sp_state)) {
@@ -11243,11 +11221,10 @@ static int bnx2x_validate_addr(struct net_device *dev)
 	return 0;
 }

-static const struct net_device_ops bnx2x_netdev_ops = {
+static struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_open		= bnx2x_open,
 	.ndo_stop		= bnx2x_close,
 	.ndo_start_xmit		= bnx2x_start_xmit,
-	.ndo_select_queue	= bnx2x_select_queue,
 	.ndo_set_rx_mode	= bnx2x_set_rx_mode,
 	.ndo_set_mac_address	= bnx2x_change_mac_addr,
 	.ndo_validate_addr	= bnx2x_validate_addr,
@@ -11261,9 +11238,6 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #endif
 	.ndo_setup_tc		= bnx2x_setup_tc,

-#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
-	.ndo_fcoe_get_wwn	= bnx2x_fcoe_get_wwn,
-#endif
 };

 static int bnx2x_set_coherency_mask(struct bnx2x *bp)
@@ -11415,6 +11389,12 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,

 	dev->watchdog_timeo = TX_TIMEOUT;

+	if (CNIC_ENABLED(bp))
+		bnx2x_netdev_ops.ndo_select_queue = bnx2x_select_queue;
+#if defined(NETDEV_FCOE_WWNN)
+	if (CNIC_ENABLED(bp))
+		bnx2x_netdev_ops.ndo_fcoe_get_wwn = bnx2x_fcoe_get_wwn;
+#endif
 	dev->netdev_ops = &bnx2x_netdev_ops;
 	bnx2x_set_ethtool_ops(dev);

@@ -11731,9 +11711,8 @@ static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
 {
 	int cid_count = BNX2X_L2_MAX_CID(bp);

-#ifdef BCM_CNIC
-	cid_count += CNIC_CID_MAX;
-#endif
+	if (CNIC_ENABLED(bp))
+		cid_count += CNIC_CID_MAX;
 	return roundup(cid_count, QM_CID_ROUND);
 }

@@ -11743,7 +11722,8 @@ static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
  * @dev:	pci device
  *
  */
-static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
+static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
+				     int cnic_enabled)
 {
 	int pos;
 	u16 control;
@@ -11755,7 +11735,7 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
 	 * one fast path queue: one FP queue + SB for CNIC
 	 */
 	if (!pos)
-		return 1 + CNIC_PRESENT;
+		return 1 + cnic_enabled;

 	/*
 	 * The value in the PCI configuration space is the index of the last
@@ -11767,6 +11747,15 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev)
 	return control & PCI_MSIX_FLAGS_QSIZE;
 }

+static int set_is_cnic_enabled(void)
+{
+#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
+	return 1;
+#else
+	return 0;
+#endif
+}
+
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -11775,6 +11764,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	int pcie_width, pcie_speed;
 	int rc, max_non_def_sbs;
 	int rx_count, tx_count, rss_count, doorbell_size;
+	int cnic_enabled;
 	/*
 	 * An estimated maximum supported CoS number according to the chip
 	 * version.
@@ -11815,21 +11805,22 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return -ENODEV;
 	}

-	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev);
+	cnic_enabled = set_is_cnic_enabled();
+	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev, cnic_enabled);

 	WARN_ON(!max_non_def_sbs);

 	/* Maximum number of RSS queues: one IGU SB goes to CNIC */
-	rss_count = max_non_def_sbs - CNIC_PRESENT;
+	rss_count = max_non_def_sbs - cnic_enabled;

 	/* Maximum number of netdev Rx queues: RSS + FCoE L2 */
-	rx_count = rss_count + FCOE_PRESENT;
+	rx_count = rss_count + cnic_enabled;

 	/*
 	 * Maximum number of netdev Tx queues:
 	 * Maximum TSS queues * Maximum supported number of CoS  + FCoE L2
 	 */
-	tx_count = rss_count * max_cos_est + FCOE_PRESENT;
+	tx_count = rss_count * max_cos_est + cnic_enabled;

 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mqs(sizeof(*bp), tx_count, rx_count);
@@ -11840,6 +11831,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,

 	bp->igu_sb_cnt = max_non_def_sbs;
 	bp->msg_enable = debug;
+	bp->cnic_enabled = cnic_enabled;
+
 	pci_set_drvdata(pdev, dev);

 	rc = bnx2x_init_dev(pdev, dev, ent->driver_data);
@@ -11880,14 +11873,10 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* calc qm_cid_count */
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp);

-#ifdef BCM_CNIC
 	/* disable FCOE L2 queue for E1x */
 	if (CHIP_IS_E1x(bp))
 		bp->flags |= NO_FCOE_FLAG;

-#endif
-
-
 	/* Set bp->num_queues for MSI-X mode*/
 	bnx2x_set_num_queues(bp);

@@ -11905,14 +11894,12 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}

-#ifdef BCM_CNIC
+	/* Add storage MAC address */
 	if (!NO_FCOE(bp)) {
-		/* Add storage MAC address */
 		rtnl_lock();
 		dev_addr_add(bp->dev, bp->fip_mac, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
 	}
-#endif

 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);

@@ -11957,14 +11944,12 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
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
@@ -12015,9 +12000,9 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)

 	bp->rx_mode = BNX2X_RX_MODE_NONE;

-#ifdef BCM_CNIC
-	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
-#endif
+	if (CNIC_ENABLED(bp))
+		bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
+
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);

@@ -12212,7 +12197,6 @@ void bnx2x_notify_link_changed(struct bnx2x *bp)
 module_init(bnx2x_init);
 module_exit(bnx2x_cleanup);

-#ifdef BCM_CNIC
 /**
  * bnx2x_set_iscsi_eth_mac_addr - set iSCSI MAC(s).
  *
@@ -12762,5 +12746,4 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 }
 EXPORT_SYMBOL(bnx2x_cnic_probe);

-#endif /* BCM_CNIC */

--
1.7.10
