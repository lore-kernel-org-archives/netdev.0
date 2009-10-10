From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/7] bnx2x: Add hw init code to support iSCSI.
Date: Sat, 10 Oct 2009 16:46:55 -0700
Message-ID: <1255218419-17320-3-git-send-email-mchan@broadcom.com>
References: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	shmulikr@broadcom.com, eilong@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2221 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758035AbZJJXjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 19:39:11 -0400
In-Reply-To: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code to initialize hardware blocks used for iSCSI.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Shmulik Ravid - Rabinovitz <shmulikr@broadcom.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   59 +++++++++++---
 drivers/net/bnx2x_main.c |  210 +++++++++++++++++++++++++++++++++-------------
 2 files changed, 200 insertions(+), 69 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 1f07063..e94ce83 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -762,7 +762,11 @@ struct bnx2x_eth_stats {
 			(offsetof(struct bnx2x_eth_stats, stat_name) / 4)
 
 
+#ifdef BCM_CNIC
+#define MAX_CONTEXT			15
+#else
 #define MAX_CONTEXT			16
+#endif
 
 union cdu_context {
 	struct eth_context eth;
@@ -811,13 +815,21 @@ struct bnx2x {
 	struct bnx2x_fastpath	fp[MAX_CONTEXT];
 	void __iomem		*regview;
 	void __iomem		*doorbells;
+#ifdef BCM_CNIC
+#define BNX2X_DB_SIZE		(18*BCM_PAGE_SIZE)
+#else
 #define BNX2X_DB_SIZE		(16*BCM_PAGE_SIZE)
+#endif
 
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
 
 	atomic_t		intr_sem;
+#ifdef BCM_CNIC
+	struct msix_entry	msix_table[MAX_CONTEXT+2];
+#else
 	struct msix_entry	msix_table[MAX_CONTEXT+1];
+#endif
 #define INT_MODE_INTx			1
 #define INT_MODE_MSI			2
 #define INT_MODE_MSIX			3
@@ -891,6 +903,11 @@ struct bnx2x {
 #define BP_E1HVN(bp)			(bp->func >> 1)
 #define BP_L_ID(bp)			(BP_E1HVN(bp) << 2)
 
+#ifdef BCM_CNIC
+#define BCM_CNIC_CID_START		16
+#define BCM_ISCSI_ETH_CL_ID		17
+#endif
+
 	int			pm_cap;
 	int			pcie_cap;
 	int			mrrs;
@@ -960,24 +977,44 @@ struct bnx2x {
 #define BNX2X_MAX_MULTICAST		64
 #define BNX2X_MAX_EMUL_MULTI		16
 
+	u32 			rx_mode_cl_mask;
+
 	dma_addr_t		def_status_blk_mapping;
 
 	struct bnx2x_slowpath	*slowpath;
 	dma_addr_t		slowpath_mapping;
 
-#ifdef BCM_ISCSI
-	void    		*t1;
-	dma_addr_t      	t1_mapping;
-	void    		*t2;
-	dma_addr_t      	t2_mapping;
-	void    		*timers;
-	dma_addr_t      	timers_mapping;
-	void    		*qm;
-	dma_addr_t      	qm_mapping;
-#endif
-
 	int			dropless_fc;
 
+#ifdef BCM_CNIC
+	u32			cnic_flags;
+#define BNX2X_CNIC_FLAG_MAC_SET		1
+
+	void			*t1;
+	dma_addr_t		t1_mapping;
+	void			*t2;
+	dma_addr_t		t2_mapping;
+	void			*timers;
+	dma_addr_t		timers_mapping;
+	void			*qm;
+	dma_addr_t		qm_mapping;
+	struct cnic_ops		*cnic_ops;
+	void			*cnic_data;
+	u32			cnic_tag;
+	struct cnic_eth_dev	cnic_eth_dev;
+	struct host_status_block *cnic_sb;
+	dma_addr_t		cnic_sb_mapping;
+#define CNIC_SB_ID(bp)			BP_L_ID(bp)
+	struct eth_spe		*cnic_kwq;
+	struct eth_spe		*cnic_kwq_prod;
+	struct eth_spe		*cnic_kwq_cons;
+	struct eth_spe		*cnic_kwq_last;
+	u16			cnic_kwq_pending;
+	u16			cnic_spq_pending;
+	struct mutex		cnic_mutex;
+	u8			iscsi_mac[6];
+#endif
+
 	int			dmae_ready;
 	/* used to synchronize dmae accesses */
 	struct mutex		dmae_mutex;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 02ce3b3..f7b7110 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -742,6 +742,9 @@ static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 	if (msix) {
 		synchronize_irq(bp->msix_table[0].vector);
 		offset = 1;
+#ifdef BCM_CNIC
+		offset++;
+#endif
 		for_each_queue(bp, i)
 			synchronize_irq(bp->msix_table[i + offset].vector);
 	} else
@@ -5252,7 +5255,7 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
 	struct tstorm_eth_mac_filter_config tstorm_mac_filter = {0};
 	int mode = bp->rx_mode;
-	int mask = (1 << BP_L_ID(bp));
+	int mask = bp->rx_mode_cl_mask;
 	int func = BP_FUNC(bp);
 	int port = BP_PORT(bp);
 	int i;
@@ -5365,6 +5368,7 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	       (*(u32 *)&tstorm_config));
 
 	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
+	bp->rx_mode_cl_mask = (1 << BP_L_ID(bp));
 	bnx2x_set_storm_rx_mode(bp);
 
 	for_each_queue(bp, i) {
@@ -5582,7 +5586,11 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		fp->state = BNX2X_FP_STATE_CLOSED;
 		fp->index = i;
 		fp->cl_id = BP_L_ID(bp) + i;
+#ifdef BCM_CNIC
+		fp->sb_id = fp->cl_id + 1;
+#else
 		fp->sb_id = fp->cl_id;
+#endif
 		/* Suitable Rx and Tx SBs are served by the same client */
 		if (i >= bp->num_rx_queues)
 			fp->cl_id -= bp->num_rx_queues;
@@ -5884,7 +5892,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	msleep(50);
 	bnx2x_init_block(bp, BRB1_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, PRS_BLOCK, COMMON_STAGE);
-#ifndef BCM_ISCSI
+#ifndef BCM_CNIC
 	/* set NIC mode */
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif
@@ -6023,6 +6031,9 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 static int bnx2x_init_common(struct bnx2x *bp)
 {
 	u32 val, i;
+#ifdef BCM_CNIC
+	u32 wb_write[2];
+#endif
 
 	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
 
@@ -6065,7 +6076,7 @@ static int bnx2x_init_common(struct bnx2x *bp)
 #endif
 
 	REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 2);
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
 	REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
 	REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
@@ -6108,11 +6119,26 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_read_dmae(bp, USEM_REG_PASSIVE_BUFFER, 3);
 
 	bnx2x_init_block(bp, QM_BLOCK, COMMON_STAGE);
+
+#ifdef BCM_CNIC
+	wb_write[0] = 0;
+	wb_write[1] = 0;
+	for (i = 0; i < 64; i++) {
+		REG_WR(bp, QM_REG_BASEADDR + i*4, 1024 * 4 * (i%16));
+		bnx2x_init_ind_wr(bp, QM_REG_PTRTBL + i*8, wb_write, 2);
+
+		if (CHIP_IS_E1H(bp)) {
+			REG_WR(bp, QM_REG_BASEADDR_EXT_A + i*4, 1024*4*(i%16));
+			bnx2x_init_ind_wr(bp, QM_REG_PTRTBL_EXT_A + i*8,
+					  wb_write, 2);
+		}
+	}
+#endif
 	/* soft reset pulse */
 	REG_WR(bp, QM_REG_SOFT_RESET, 1);
 	REG_WR(bp, QM_REG_SOFT_RESET, 0);
 
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	bnx2x_init_block(bp, TIMERS_BLOCK, COMMON_STAGE);
 #endif
 
@@ -6126,8 +6152,10 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, BRB1_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, PRS_BLOCK, COMMON_STAGE);
 	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
+#ifndef BCM_CNIC
 	/* set NIC mode */
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
+#endif
 	if (CHIP_IS_E1H(bp))
 		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_E1HMF(bp));
 
@@ -6162,6 +6190,18 @@ static int bnx2x_init_common(struct bnx2x *bp)
 		/* TODO: replace with something meaningful */
 	}
 	bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
+#ifdef BCM_CNIC
+	REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
+	REG_WR(bp, SRC_REG_KEYSEARCH_1, 0x24b8f2cc);
+	REG_WR(bp, SRC_REG_KEYSEARCH_2, 0x223aef9b);
+	REG_WR(bp, SRC_REG_KEYSEARCH_3, 0x26001e3a);
+	REG_WR(bp, SRC_REG_KEYSEARCH_4, 0x7ae91116);
+	REG_WR(bp, SRC_REG_KEYSEARCH_5, 0x5ce5230b);
+	REG_WR(bp, SRC_REG_KEYSEARCH_6, 0x298d8adf);
+	REG_WR(bp, SRC_REG_KEYSEARCH_7, 0x6eb0ff09);
+	REG_WR(bp, SRC_REG_KEYSEARCH_8, 0x1830f82f);
+	REG_WR(bp, SRC_REG_KEYSEARCH_9, 0x01e46be7);
+#endif
 	REG_WR(bp, SRC_REG_SOFT_RST, 0);
 
 	if (sizeof(union cdu_context) != 1024)
@@ -6278,38 +6318,14 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, TCM_BLOCK, init_stage);
 	bnx2x_init_block(bp, UCM_BLOCK, init_stage);
 	bnx2x_init_block(bp, CCM_BLOCK, init_stage);
-#ifdef BCM_ISCSI
-	/* Port0  1
-	 * Port1  385 */
-	i++;
-	wb_write[0] = ONCHIP_ADDR1(bp->timers_mapping);
-	wb_write[1] = ONCHIP_ADDR2(bp->timers_mapping);
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-	REG_WR(bp, PXP2_REG_PSWRQ_TM0_L2P + func*4, PXP_ONE_ILT(i));
-
-	/* Port0  2
-	 * Port1  386 */
-	i++;
-	wb_write[0] = ONCHIP_ADDR1(bp->qm_mapping);
-	wb_write[1] = ONCHIP_ADDR2(bp->qm_mapping);
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-	REG_WR(bp, PXP2_REG_PSWRQ_QM0_L2P + func*4, PXP_ONE_ILT(i));
-
-	/* Port0  3
-	 * Port1  387 */
-	i++;
-	wb_write[0] = ONCHIP_ADDR1(bp->t1_mapping);
-	wb_write[1] = ONCHIP_ADDR2(bp->t1_mapping);
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-	REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
-#endif
 	bnx2x_init_block(bp, XCM_BLOCK, init_stage);
 
-#ifdef BCM_ISCSI
-	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + func*4, 1024/64*20);
-	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + func*4, 31);
+#ifdef BCM_CNIC
+	REG_WR(bp, QM_REG_CONNNUM_0 + port*4, 1024/16 - 1);
 
 	bnx2x_init_block(bp, TIMERS_BLOCK, init_stage);
+	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
+	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
 #endif
 	bnx2x_init_block(bp, DQ_BLOCK, init_stage);
 
@@ -6367,18 +6383,8 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	msleep(5);
 	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
 
-#ifdef BCM_ISCSI
-	/* tell the searcher where the T2 table is */
-	REG_WR(bp, SRC_REG_COUNTFREE0 + func*4, 16*1024/64);
-
-	wb_write[0] = U64_LO(bp->t2_mapping);
-	wb_write[1] = U64_HI(bp->t2_mapping);
-	REG_WR_DMAE(bp, SRC_REG_FIRSTFREE0 + func*4, wb_write, 2);
-	wb_write[0] = U64_LO((u64)bp->t2_mapping + 16*1024 - 64);
-	wb_write[1] = U64_HI((u64)bp->t2_mapping + 16*1024 - 64);
-	REG_WR_DMAE(bp, SRC_REG_LASTFREE0 + func*4, wb_write, 2);
-
-	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + func*4, 10);
+#ifdef BCM_CNIC
+	bnx2x_init_block(bp, SRCH_BLOCK, init_stage);
 #endif
 	bnx2x_init_block(bp, CDU_BLOCK, init_stage);
 	bnx2x_init_block(bp, CFC_BLOCK, init_stage);
@@ -6487,7 +6493,12 @@ static int bnx2x_init_port(struct bnx2x *bp)
 #define PXP_ONE_ILT(x)		(((x) << 10) | x)
 #define PXP_ILT_RANGE(f, l)	(((l) << 10) | f)
 
+#ifdef BCM_CNIC
+#define CNIC_ILT_LINES		127
+#define CNIC_CTX_PER_ILT	16
+#else
 #define CNIC_ILT_LINES		0
+#endif
 
 static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
 {
@@ -6526,6 +6537,46 @@ static int bnx2x_init_func(struct bnx2x *bp)
 		REG_WR(bp, PXP2_REG_PSWRQ_CDU0_L2P + func*4,
 		       PXP_ILT_RANGE(i, i + CNIC_ILT_LINES));
 
+#ifdef BCM_CNIC
+	i += 1 + CNIC_ILT_LINES;
+	bnx2x_ilt_wr(bp, i, bp->timers_mapping);
+	if (CHIP_IS_E1(bp))
+		REG_WR(bp, PXP2_REG_PSWRQ_TM0_L2P + func*4, PXP_ONE_ILT(i));
+	else {
+		REG_WR(bp, PXP2_REG_RQ_TM_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_TM_LAST_ILT, i);
+	}
+
+	i++;
+	bnx2x_ilt_wr(bp, i, bp->qm_mapping);
+	if (CHIP_IS_E1(bp))
+		REG_WR(bp, PXP2_REG_PSWRQ_QM0_L2P + func*4, PXP_ONE_ILT(i));
+	else {
+		REG_WR(bp, PXP2_REG_RQ_QM_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_QM_LAST_ILT, i);
+	}
+
+	i++;
+	bnx2x_ilt_wr(bp, i, bp->t1_mapping);
+	if (CHIP_IS_E1(bp))
+		REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
+	else {
+		REG_WR(bp, PXP2_REG_RQ_SRC_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_SRC_LAST_ILT, i);
+	}
+
+	/* tell the searcher where the T2 table is */
+	REG_WR(bp, SRC_REG_COUNTFREE0 + port*4, 16*1024/64);
+
+	bnx2x_wb_wr(bp, SRC_REG_FIRSTFREE0 + port*16,
+		    U64_LO(bp->t2_mapping), U64_HI(bp->t2_mapping));
+
+	bnx2x_wb_wr(bp, SRC_REG_LASTFREE0 + port*16,
+		    U64_LO((u64)bp->t2_mapping + 16*1024 - 64),
+		    U64_HI((u64)bp->t2_mapping + 16*1024 - 64));
+
+	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + port*4, 10);
+#endif
 
 	if (CHIP_IS_E1H(bp)) {
 		bnx2x_init_block(bp, MISC_BLOCK, FUNC0_STAGE + func);
@@ -6610,6 +6661,9 @@ static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 	bnx2x_zero_def_sb(bp);
 	for_each_queue(bp, i)
 		bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
+#ifdef BCM_CNIC
+	bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
+#endif
 
 init_hw_err:
 	bnx2x_gunzip_end(bp);
@@ -6685,11 +6739,13 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
 		       sizeof(struct bnx2x_slowpath));
 
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	BNX2X_PCI_FREE(bp->t1, bp->t1_mapping, 64*1024);
 	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, 16*1024);
 	BNX2X_PCI_FREE(bp->timers, bp->timers_mapping, 8*1024);
 	BNX2X_PCI_FREE(bp->qm, bp->qm_mapping, 128*1024);
+	BNX2X_PCI_FREE(bp->cnic_sb, bp->cnic_sb_mapping,
+		       sizeof(struct host_status_block));
 #endif
 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, BCM_PAGE_SIZE);
 
@@ -6768,32 +6824,26 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
 			sizeof(struct bnx2x_slowpath));
 
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	BNX2X_PCI_ALLOC(bp->t1, &bp->t1_mapping, 64*1024);
 
-	/* Initialize T1 */
-	for (i = 0; i < 64*1024; i += 64) {
-		*(u64 *)((char *)bp->t1 + i + 56) = 0x0UL;
-		*(u64 *)((char *)bp->t1 + i + 3) = 0x0UL;
-	}
-
 	/* allocate searcher T2 table
 	   we allocate 1/4 of alloc num for T2
 	  (which is not entered into the ILT) */
 	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, 16*1024);
 
-	/* Initialize T2 */
+	/* Initialize T2 (for 1024 connections) */
 	for (i = 0; i < 16*1024; i += 64)
-		* (u64 *)((char *)bp->t2 + i + 56) = bp->t2_mapping + i + 64;
-
-	/* now fixup the last line in the block to point to the next block */
-	*(u64 *)((char *)bp->t2 + 1024*16-8) = bp->t2_mapping;
+		*(u64 *)((char *)bp->t2 + i + 56) = bp->t2_mapping + i + 64;
 
-	/* Timer block array (MAX_CONN*8) phys uncached for now 1024 conns */
+	/* Timer block array (8*MAX_CONN) phys uncached for now 1024 conns */
 	BNX2X_PCI_ALLOC(bp->timers, &bp->timers_mapping, 8*1024);
 
 	/* QM queues (128*MAX_CONN) */
 	BNX2X_PCI_ALLOC(bp->qm, &bp->qm_mapping, 128*1024);
+
+	BNX2X_PCI_ALLOC(bp->cnic_sb, &bp->cnic_sb_mapping,
+			sizeof(struct host_status_block));
 #endif
 
 	/* Slow path ring */
@@ -6869,6 +6919,9 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
 	   bp->msix_table[0].vector);
 
+#ifdef BCM_CNIC
+	offset++;
+#endif
 	for_each_queue(bp, i) {
 		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
 		   "state %x\n", i, bp->msix_table[i + offset].vector,
@@ -6902,6 +6955,12 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 	bp->msix_table[0].entry = igu_vec;
 	DP(NETIF_MSG_IFUP, "msix_table[0].entry = %d (slowpath)\n", igu_vec);
 
+#ifdef BCM_CNIC
+	igu_vec = BP_L_ID(bp) + offset;
+	bp->msix_table[1].entry = igu_vec;
+	DP(NETIF_MSG_IFUP, "msix_table[1].entry = %d (CNIC)\n", igu_vec);
+	offset++;
+#endif
 	for_each_queue(bp, i) {
 		igu_vec = BP_L_ID(bp) + offset + i;
 		bp->msix_table[i + offset].entry = igu_vec;
@@ -6932,6 +6991,9 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		return -EBUSY;
 	}
 
+#ifdef BCM_CNIC
+	offset++;
+#endif
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
@@ -7496,10 +7558,18 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 
 	if (bp->state == BNX2X_STATE_OPEN) {
+#ifdef BCM_CNIC
+		/* Enable Timer scan */
+		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 1);
+#endif
 		for_each_nondefault_queue(bp, i) {
 			rc = bnx2x_setup_multi(bp, i);
 			if (rc)
+#ifdef BCM_CNIC
+				goto load_error4;
+#else
 				goto load_error3;
+#endif
 		}
 
 		if (CHIP_IS_E1(bp))
@@ -7549,6 +7619,11 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	return 0;
 
+#ifdef BCM_CNIC
+load_error4:
+	/* Disable Timer scan */
+	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 0);
+#endif
 load_error3:
 	bnx2x_int_disable_sync(bp, 1);
 	if (!BP_NOMCP(bp)) {
@@ -7656,6 +7731,19 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
 	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
 
+#ifdef BCM_CNIC
+	/* Disable Timer scan */
+	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + port*4, 0);
+	/*
+	 * Wait for at least 10ms and up to 2 second for the timers scan to
+	 * complete
+	 */
+	for (i = 0; i < 200; i++) {
+		msleep(10);
+		if (!REG_RD(bp, TM_REG_LIN0_SCAN_ON + port*4))
+			break;
+	}
+#endif
 	/* Clear ILT */
 	base = FUNC_ILT_BASE(func);
 	for (i = base; i < base + ILT_PER_FUNC; i++)
@@ -8666,6 +8754,12 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
 	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
+
+#ifdef BCM_CNIC
+	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].iscsi_mac_upper);
+	val = SHMEM_RD(bp, dev_info.port_hw_config[port].iscsi_mac_lower);
+	bnx2x_set_mac_buf(bp->iscsi_mac, val, val2);
+#endif
 }
 
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
-- 
1.6.4.GIT


