From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 02/41]bnx2x: Multi-queue
Date: Thu, 12 Feb 2009 20:36:11 +0200
Message-ID: <1234463771.1863.133.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757247AbZBLSgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:36:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 02/41]bnx2x: Multi-queue
Adding Tx multi-queue and enabling multi-queue by default

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |   33 ++++--
 drivers/net/bnx2x_fw_defs.h |    4 +
 drivers/net/bnx2x_main.c    |  254 ++++++++++++++++++++++++++-----------------
 3 files changed, 178 insertions(+), 113 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index de094d4..7edad1f 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -25,6 +25,10 @@
 #endif
 
 
+#define BNX2X_MULTI_QUEUE
+
+#define BNX2X_NEW_NAPI
+
 /* error/debug prints */
 
 #define DRV_MODULE_NAME		"bnx2x"
@@ -266,6 +270,7 @@ struct bnx2x_fastpath {
 	u64			tpa_queue_used;
 #endif
 
+	char			name[IFNAMSIZ];
 	struct bnx2x		*bp; /* parent */
 };
 
@@ -680,11 +685,7 @@ struct bnx2x_eth_stats {
 			(offsetof(struct bnx2x_eth_stats, stat_name) / 4)
 
 
-#ifdef BNX2X_MULTI
 #define MAX_CONTEXT			16
-#else
-#define MAX_CONTEXT			1
-#endif
 
 union cdu_context {
 	struct eth_context eth;
@@ -859,8 +860,9 @@ struct bnx2x {
 #define BNX2X_STATE_DIAG		0xe000
 #define BNX2X_STATE_ERROR		0xf000
 
-	int			num_queues;
-#define BP_MAX_QUEUES(bp)		(IS_E1HMF(bp) ? 4 : 16)
+	int			multi_mode;
+	int			num_rx_queues;
+	int			num_tx_queues;
 
 	u32			rx_mode;
 #define BNX2X_RX_MODE_NONE		0
@@ -911,11 +913,19 @@ struct bnx2x {
 };
 
 
-#define for_each_queue(bp, var)	for (var = 0; var < bp->num_queues; var++)
+#define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT / E1HVN_MAX) : \
+						 MAX_CONTEXT)
+#define BNX2X_NUM_QUEUES(bp)	max(bp->num_rx_queues, bp->num_tx_queues)
+#define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
 
+#define for_each_rx_queue(bp, var) \
+			for (var = 0; var < bp->num_rx_queues; var++)
+#define for_each_tx_queue(bp, var) \
+			for (var = 0; var < bp->num_tx_queues; var++)
+#define for_each_queue(bp, var) \
+			for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++)
 #define for_each_nondefault_queue(bp, var) \
-				for (var = 1; var < bp->num_queues; var++)
-#define is_multi(bp)		(bp->num_queues > 1)
+			for (var = 1; var < BNX2X_NUM_QUEUES(bp); var++)
 
 
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
@@ -1120,12 +1130,13 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 				 AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR)
 
 
-#define MULTI_FLAGS \
+#define MULTI_FLAGS(bp) \
 		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY | \
-		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE)
+		 (bp->multi_mode << \
+		  TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT))
 
 #define MULTI_MASK			0x7f
 
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 2fe14a2..9eb1d13 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -259,6 +259,10 @@
 #define ETH_MAX_AGGREGATION_QUEUES_E1 (32)
 #define ETH_MAX_AGGREGATION_QUEUES_E1H (64)
 
+/* ETH RSS modes */
+#define ETH_RSS_MODE_DISABLED 0
+#define ETH_RSS_MODE_REGULAR 1
+
 
 /**
 * This file defines HSI constatnts common to all microcode flows
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3ca9c96..60762f7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -73,12 +73,14 @@ MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710/57711/57711E Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
+static int multi_mode = 1;
+module_param(multi_mode, int, 0);
+
 static int disable_tpa;
 static int use_inta;
 static int poll;
 static int debug;
 static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
-static int use_multi;
 
 module_param(disable_tpa, int, 0);
 module_param(use_inta, int, 0);
@@ -89,10 +91,6 @@ MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
 MODULE_PARM_DESC(debug, "default debug msglevel");
 
-#ifdef BNX2X_MULTI
-module_param(use_multi, int, 0);
-MODULE_PARM_DESC(use_multi, "use per-CPU queues");
-#endif
 static struct workqueue_struct *bnx2x_wq;
 
 enum bnx2x_board_type {
@@ -845,6 +843,7 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 {
 	struct bnx2x *bp = fp->bp;
+	struct netdev_queue *txq;
 	u16 hw_cons, sw_cons, bd_cons = fp->tx_bd_cons;
 	int done = 0;
 
@@ -853,6 +852,7 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 		return;
 #endif
 
+	txq = netdev_get_tx_queue(bp->dev, fp->index);
 	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
 	sw_cons = fp->tx_pkt_cons;
 
@@ -882,24 +882,24 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 	fp->tx_pkt_cons = sw_cons;
 	fp->tx_bd_cons = bd_cons;
 
-	/* Need to make the tx_cons update visible to start_xmit()
-	 * before checking for netif_queue_stopped().  Without the
+	/* Need to make the tx_bd_cons update visible to start_xmit()
+	 * before checking for netif_tx_queue_stopped().  Without the
 	 * memory barrier, there is a small possibility that start_xmit()
 	 * will miss it and cause the queue to be stopped forever.
 	 */
 	smp_mb();
 
 	/* TBD need a thresh? */
-	if (unlikely(netif_queue_stopped(bp->dev))) {
+	if (unlikely(netif_tx_queue_stopped(txq))) {
 
-		netif_tx_lock(bp->dev);
+		__netif_tx_lock(txq, smp_processor_id());
 
-		if (netif_queue_stopped(bp->dev) &&
+		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
-			netif_wake_queue(bp->dev);
+			netif_tx_wake_queue(txq);
 
-		netif_tx_unlock(bp->dev);
+		__netif_tx_unlock(txq);
 	}
 }
 
@@ -1403,8 +1403,8 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 	mmiowb(); /* keep prod updates ordered */
 
 	DP(NETIF_MSG_RX_STATUS,
-	   "Wrote: bd_prod %u  cqe_prod %u  sge_prod %u\n",
-	   bd_prod, rx_comp_prod, rx_sge_prod);
+	   "queue[%d]:  wrote  bd_prod %u  cqe_prod %u  sge_prod %u\n",
+	   fp->index, bd_prod, rx_comp_prod, rx_sge_prod);
 }
 
 static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
@@ -1662,8 +1662,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 
 static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 {
-	struct net_device *dev = dev_instance;
-	struct bnx2x *bp = netdev_priv(dev);
+	struct bnx2x *bp = netdev_priv(dev_instance);
 	u16 status = bnx2x_ack_int(bp);
 	u16 mask;
 
@@ -4295,7 +4294,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		   "rx_buf_size %d  effective_mtu %d\n",
 		   bp->rx_buf_size, bp->dev->mtu + ETH_OVREHEAD);
 
-		for_each_queue(bp, j) {
+		for_each_rx_queue(bp, j) {
 			struct bnx2x_fastpath *fp = &bp->fp[j];
 
 			for (i = 0; i < max_agg_queues; i++) {
@@ -4318,7 +4317,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		}
 	}
 
-	for_each_queue(bp, j) {
+	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		fp->rx_bd_cons = 0;
@@ -4430,7 +4429,7 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 {
 	int i, j;
 
-	for_each_queue(bp, j) {
+	for_each_tx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 1; i <= NUM_TX_RINGS; i++) {
@@ -4543,14 +4542,15 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	int func = BP_FUNC(bp);
 	int i;
 
-	if (!is_multi(bp))
+	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
 		return;
 
-	DP(NETIF_MSG_IFUP, "Initializing indirection table\n");
+	DP(NETIF_MSG_IFUP,
+	   "Initializing indirection table  multi_mode %d\n", bp->multi_mode);
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			BP_CL_ID(bp) + (i % bp->num_queues));
+			BP_CL_ID(bp) + (i % bp->num_rx_queues));
 }
 
 static void bnx2x_set_client_config(struct bnx2x *bp)
@@ -4684,7 +4684,7 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	u16 max_agg_size;
 
 	if (is_multi(bp)) {
-		tstorm_config.config_flags = MULTI_FLAGS;
+		tstorm_config.config_flags = MULTI_FLAGS(bp);
 		tstorm_config.rss_result_mask = MULTI_MASK;
 	}
 	if (IS_E1HMF(bp))
@@ -4764,7 +4764,7 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		min((u32)(min((u32)8, (u32)MAX_SKB_FRAGS) *
 			  SGE_PAGE_SIZE * PAGES_PER_SGE),
 		    (u32)0xffff);
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		REG_WR(bp, BAR_USTRORM_INTMEM +
@@ -5809,20 +5809,19 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 	int i;
 
 	/* fastpath */
+	/* Common */
 	for_each_queue(bp, i) {
 
-		/* Status blocks */
+		/* status blocks */
 		BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk),
 			       bnx2x_fp(bp, i, status_blk_mapping),
 			       sizeof(struct host_status_block) +
 			       sizeof(struct eth_tx_db_data));
+	}
+	/* Rx */
+	for_each_rx_queue(bp, i) {
 
-		/* fast path rings: tx_buf tx_desc rx_buf rx_desc rx_comp */
-		BNX2X_FREE(bnx2x_fp(bp, i, tx_buf_ring));
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, tx_desc_ring),
-			       bnx2x_fp(bp, i, tx_desc_mapping),
-			       sizeof(struct eth_tx_bd) * NUM_TX_BD);
-
+		/* fastpath rx rings: rx_buf rx_desc rx_comp */
 		BNX2X_FREE(bnx2x_fp(bp, i, rx_buf_ring));
 		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_desc_ring),
 			       bnx2x_fp(bp, i, rx_desc_mapping),
@@ -5839,6 +5838,15 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       bnx2x_fp(bp, i, rx_sge_mapping),
 			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
+	/* Tx */
+	for_each_tx_queue(bp, i) {
+
+		/* fastpath tx rings: tx_buf tx_desc */
+		BNX2X_FREE(bnx2x_fp(bp, i, tx_buf_ring));
+		BNX2X_PCI_FREE(bnx2x_fp(bp, i, tx_desc_ring),
+			       bnx2x_fp(bp, i, tx_desc_mapping),
+			       sizeof(struct eth_tx_bd) * NUM_TX_BD);
+	}
 	/* end of fastpath */
 
 	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
@@ -5881,29 +5889,20 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	int i;
 
 	/* fastpath */
+	/* Common */
 	for_each_queue(bp, i) {
 		bnx2x_fp(bp, i, bp) = bp;
 
-		/* Status blocks */
+		/* status blocks */
 		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, status_blk),
 				&bnx2x_fp(bp, i, status_blk_mapping),
 				sizeof(struct host_status_block) +
 				sizeof(struct eth_tx_db_data));
+	}
+	/* Rx */
+	for_each_rx_queue(bp, i) {
 
-		bnx2x_fp(bp, i, hw_tx_prods) =
-				(void *)(bnx2x_fp(bp, i, status_blk) + 1);
-
-		bnx2x_fp(bp, i, tx_prods_mapping) =
-				bnx2x_fp(bp, i, status_blk_mapping) +
-				sizeof(struct host_status_block);
-
-		/* fast path rings: tx_buf tx_desc rx_buf rx_desc rx_comp */
-		BNX2X_ALLOC(bnx2x_fp(bp, i, tx_buf_ring),
-				sizeof(struct sw_tx_bd) * NUM_TX_BD);
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, tx_desc_ring),
-				&bnx2x_fp(bp, i, tx_desc_mapping),
-				sizeof(struct eth_tx_bd) * NUM_TX_BD);
-
+		/* fastpath rx rings: rx_buf rx_desc rx_comp */
 		BNX2X_ALLOC(bnx2x_fp(bp, i, rx_buf_ring),
 				sizeof(struct sw_rx_bd) * NUM_RX_BD);
 		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_desc_ring),
@@ -5922,6 +5921,23 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 				&bnx2x_fp(bp, i, rx_sge_mapping),
 				BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
+	/* Tx */
+	for_each_tx_queue(bp, i) {
+
+		bnx2x_fp(bp, i, hw_tx_prods) =
+				(void *)(bnx2x_fp(bp, i, status_blk) + 1);
+
+		bnx2x_fp(bp, i, tx_prods_mapping) =
+				bnx2x_fp(bp, i, status_blk_mapping) +
+				sizeof(struct host_status_block);
+
+		/* fastpath tx rings: tx_buf tx_desc */
+		BNX2X_ALLOC(bnx2x_fp(bp, i, tx_buf_ring),
+				sizeof(struct sw_tx_bd) * NUM_TX_BD);
+		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, tx_desc_ring),
+				&bnx2x_fp(bp, i, tx_desc_mapping),
+				sizeof(struct eth_tx_bd) * NUM_TX_BD);
+	}
 	/* end of fastpath */
 
 	BNX2X_PCI_ALLOC(bp->def_status_blk, &bp->def_status_blk_mapping,
@@ -5975,7 +5991,7 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i) {
+	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		u16 bd_cons = fp->tx_bd_cons;
@@ -5993,7 +6009,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 {
 	int i, j;
 
-	for_each_queue(bp, j) {
+	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 0; i < NUM_RX_BD; i++) {
@@ -6073,7 +6089,7 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 	}
 
 	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
-			     bp->num_queues + offset);
+			     BNX2X_NUM_QUEUES(bp) + offset);
 	if (rc) {
 		DP(NETIF_MSG_IFUP, "MSI-X is not attainable\n");
 		return -1;
@@ -6095,19 +6111,32 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	}
 
 	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		sprintf(fp->name, "%s.fp%d", bp->dev->name, i);
 		rc = request_irq(bp->msix_table[i + offset].vector,
-				 bnx2x_msix_fp_int, 0,
-				 bp->dev->name, &bp->fp[i]);
+				 bnx2x_msix_fp_int, 0, fp->name, fp);
 		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed  rc -%d\n",
-				  i + offset, -rc);
+			BNX2X_ERR("request fp #%d irq failed  rc %d\n", i, rc);
 			bnx2x_free_msix_irqs(bp);
 			return -EBUSY;
 		}
 
-		bnx2x_fp(bp, i, state) = BNX2X_FP_STATE_IRQ;
+		fp->state = BNX2X_FP_STATE_IRQ;
 	}
 
+	i = BNX2X_NUM_QUEUES(bp);
+	if (is_multi(bp))
+		printk(KERN_INFO PFX
+		       "%s: using MSI-X  IRQs: sp %d  fp %d - %d\n",
+		       bp->dev->name, bp->msix_table[0].vector,
+		       bp->msix_table[offset].vector,
+		       bp->msix_table[offset + i - 1].vector);
+	else
+		printk(KERN_INFO PFX "%s: using MSI-X  IRQs: sp %d  fp %d\n",
+		       bp->dev->name, bp->msix_table[0].vector,
+		       bp->msix_table[offset + i - 1].vector);
+
 	return 0;
 }
 
@@ -6127,7 +6156,7 @@ static void bnx2x_napi_enable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 }
 
@@ -6135,7 +6164,7 @@ static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
 }
 
@@ -6143,10 +6172,10 @@ static void bnx2x_netif_start(struct bnx2x *bp)
 {
 	if (atomic_dec_and_test(&bp->intr_sem)) {
 		if (netif_running(bp->dev)) {
-			if (bp->state == BNX2X_STATE_OPEN)
-				netif_wake_queue(bp->dev);
 			bnx2x_napi_enable(bp);
 			bnx2x_int_enable(bp);
+			if (bp->state == BNX2X_STATE_OPEN)
+				netif_tx_wake_all_queues(bp->dev);
 		}
 	}
 }
@@ -6320,16 +6349,19 @@ static int bnx2x_setup_leading(struct bnx2x *bp)
 
 static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 {
+	struct bnx2x_fastpath *fp = &bp->fp[index];
+
 	/* reset IGU state */
-	bnx2x_ack_sb(bp, bp->fp[index].sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
 	/* SETUP ramrod */
-	bp->fp[index].state = BNX2X_FP_STATE_OPENING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CLIENT_SETUP, index, 0, index, 0);
+	fp->state = BNX2X_FP_STATE_OPENING;
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CLIENT_SETUP, index, 0,
+		      fp->cl_id, 0);
 
 	/* Wait for completion */
 	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_OPEN, index,
-				 &(bp->fp[index].state), 0);
+				 &(fp->state), 0);
 }
 
 static int bnx2x_poll(struct napi_struct *napi, int budget);
@@ -6340,6 +6372,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
 	u32 load_code;
 	int i, rc = 0;
+	int num_queues;
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return -EPERM;
@@ -6348,22 +6381,22 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
 	if (use_inta) {
-		bp->num_queues = 1;
-
+		num_queues = 1;
+		bp->num_rx_queues = num_queues;
+		bp->num_tx_queues = num_queues;
+		DP(NETIF_MSG_IFUP,
+		   "set number of queues to %d\n", num_queues);
 	} else {
-		if ((use_multi > 1) && (use_multi <= BP_MAX_QUEUES(bp)))
-			/* user requested number */
-			bp->num_queues = use_multi;
-
-		else if (use_multi)
-			bp->num_queues = min_t(u32, num_online_cpus(),
-					       BP_MAX_QUEUES(bp));
+		if (bp->multi_mode == ETH_RSS_MODE_REGULAR)
+			num_queues = min_t(u32, num_online_cpus(),
+					   BNX2X_MAX_QUEUES(bp));
 		else
-			bp->num_queues = 1;
-
-		DP(NETIF_MSG_IFUP,
-		   "set number of queues to %d\n", bp->num_queues);
-
+			num_queues = 1;
+		bp->num_rx_queues = num_queues;
+		bp->num_tx_queues = num_queues;
+		DP(NETIF_MSG_IFUP, "set number of rx queues to %d"
+		   "  number of tx queues to %d\n",
+		   bp->num_rx_queues, bp->num_tx_queues);
 		/* if we can't use MSI-X we only need one fp,
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
@@ -6371,26 +6404,30 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		rc = bnx2x_enable_msix(bp);
 		if (rc) {
 			/* failed to enable MSI-X */
-			bp->num_queues = 1;
-			if (use_multi)
-				BNX2X_ERR("Multi requested but failed"
-					  " to enable MSI-X\n");
+			num_queues = 1;
+			bp->num_rx_queues = num_queues;
+			bp->num_tx_queues = num_queues;
+			if (bp->multi_mode)
+				BNX2X_ERR("Multi requested but failed to "
+					  "enable MSI-X  set number of "
+					  "queues to %d\n", num_queues);
 		}
 	}
+	bp->dev->real_num_tx_queues = bp->num_tx_queues;
 
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_fp(bp, i, disable_tpa) =
 					((bp->flags & TPA_ENABLE_FLAG) == 0);
 
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, 128);
 
 #ifdef BNX2X_STOP_ON_ERROR
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		fp->poll_no_work = 0;
@@ -6512,13 +6549,13 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	switch (load_mode) {
 	case LOAD_NORMAL:
 		/* Tx queue should be only reenabled */
-		netif_wake_queue(bp->dev);
+		netif_tx_wake_all_queues(bp->dev);
 		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
 
 	case LOAD_OPEN:
-		netif_start_queue(bp->dev);
+		netif_tx_start_all_queues(bp->dev);
 		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
@@ -6551,14 +6588,14 @@ load_error3:
 	bp->port.pmf = 0;
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 load_error2:
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 load_error1:
 	bnx2x_napi_disable(bp);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
@@ -6569,15 +6606,16 @@ load_error1:
 
 static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 {
+	struct bnx2x_fastpath *fp = &bp->fp[index];
 	int rc;
 
 	/* halt the connection */
-	bp->fp[index].state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, index, 0);
+	fp->state = BNX2X_FP_STATE_HALTING;
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, fp->cl_id, 0);
 
 	/* Wait for completion */
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
-			       &(bp->fp[index].state), 1);
+			       &(fp->state), 1);
 	if (rc) /* timeout */
 		return rc;
 
@@ -6586,7 +6624,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 
 	/* Wait for completion */
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
-			       &(bp->fp[index].state), 1);
+			       &(fp->state), 1);
 	return rc;
 }
 
@@ -6734,8 +6772,8 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 
-	/* Wait until tx fast path tasks complete */
-	for_each_queue(bp, i) {
+	/* Wait until tx fastpath tasks complete */
+	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		cnt = 1000;
@@ -6867,9 +6905,9 @@ unload_error:
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
@@ -7597,6 +7635,15 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		printk(KERN_ERR PFX
 		       "MCP disabled, must load devices in order!\n");
 
+	/* Set multi queue mode */
+	if ((multi_mode != ETH_RSS_MODE_DISABLED) && (!use_inta)) {
+		printk(KERN_ERR PFX
+		      "Multi disabled since INTA is requested\n");
+		multi_mode = ETH_RSS_MODE_DISABLED;
+	}
+	bp->multi_mode = multi_mode;
+
+
 	/* Set TPA flags */
 	if (disable_tpa) {
 		bp->flags &= ~TPA_ENABLE_FLAG;
@@ -9569,6 +9616,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	struct bnx2x_fastpath *fp;
+	struct netdev_queue *txq;
 	struct sw_tx_bd *tx_buf;
 	struct eth_tx_bd *tx_bd;
 	struct eth_tx_parse_bd *pbd = NULL;
@@ -9585,12 +9633,14 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 #endif
 
-	fp_index = (smp_processor_id() % bp->num_queues);
+	fp_index = skb_get_queue_mapping(skb);
+	txq = netdev_get_tx_queue(dev, fp_index);
+
 	fp = &bp->fp[fp_index];
 
 	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
 		bp->eth_stats.driver_xoff++,
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
@@ -9829,10 +9879,10 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
 		   if we put Tx into XOFF state. */
 		smp_mb();
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		bp->eth_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(txq);
 	}
 	fp->tx_pkt++;
 
@@ -10324,7 +10374,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		printk(KERN_INFO "%s", version);
 
 	/* dev zeroed in init_etherdev */
-	dev = alloc_etherdev(sizeof(*bp));
+	dev = alloc_etherdev_mq(sizeof(*bp), MAX_CONTEXT);
 	if (!dev) {
 		printk(KERN_ERR PFX "Cannot allocate net device\n");
 		return -ENOMEM;
@@ -10496,9 +10546,9 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
-- 
1.5.4.3




