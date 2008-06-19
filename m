From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/8] bnx2: Turn on multi rx rings.
Date: Wed, 18 Jun 2008 17:25:30 -0700
Message-ID: <1213835132-5698-7-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3946 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756544AbYFSAXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:52 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable multiple rx rings if MSI-X vectors are available.  We enable
up to 7 rx rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   71 ++++++++++++++++++++++++++++++++++++++++-----------
 drivers/net/bnx2.h |   26 ++++++++++++++++++-
 2 files changed, 80 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 587d6bc..9a722bf 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4542,15 +4542,25 @@ bnx2_init_chip(struct bnx2 *bp)
 		      BNX2_HC_CONFIG_COLLECT_STATS;
 	}
 
-	if (bp->flags & BNX2_FLAG_USING_MSIX) {
-		u32 base = ((BNX2_TX_VEC - 1) * BNX2_HC_SB_CONFIG_SIZE) +
-			   BNX2_HC_SB_CONFIG_1;
-
+	if (bp->irq_nvecs > 1) {
 		REG_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
 		       BNX2_HC_MSIX_BIT_VECTOR_VAL);
 
+		val |= BNX2_HC_CONFIG_SB_ADDR_INC_128B;
+	}
+
+	if (bp->flags & BNX2_FLAG_ONE_SHOT_MSI)
+		val |= BNX2_HC_CONFIG_ONE_SHOT;
+
+	REG_WR(bp, BNX2_HC_CONFIG, val);
+
+	for (i = 1; i < bp->irq_nvecs; i++) {
+		u32 base = ((i - 1) * BNX2_HC_SB_CONFIG_SIZE) +
+			   BNX2_HC_SB_CONFIG_1;
+
 		REG_WR(bp, base,
 			BNX2_HC_SB_CONFIG_1_TX_TMR_MODE |
+			BNX2_HC_SB_CONFIG_1_RX_TMR_MODE |
 			BNX2_HC_SB_CONFIG_1_ONE_SHOT);
 
 		REG_WR(bp, base + BNX2_HC_TX_QUICK_CONS_TRIP_OFF,
@@ -4560,13 +4570,13 @@ bnx2_init_chip(struct bnx2 *bp)
 		REG_WR(bp, base + BNX2_HC_TX_TICKS_OFF,
 			(bp->tx_ticks_int << 16) | bp->tx_ticks);
 
-		val |= BNX2_HC_CONFIG_SB_ADDR_INC_128B;
-	}
-
-	if (bp->flags & BNX2_FLAG_ONE_SHOT_MSI)
-		val |= BNX2_HC_CONFIG_ONE_SHOT;
+		REG_WR(bp, base + BNX2_HC_RX_QUICK_CONS_TRIP_OFF,
+		       (bp->rx_quick_cons_trip_int << 16) |
+			bp->rx_quick_cons_trip);
 
-	REG_WR(bp, BNX2_HC_CONFIG, val);
+		REG_WR(bp, base + BNX2_HC_RX_TICKS_OFF,
+			(bp->rx_ticks_int << 16) | bp->rx_ticks);
+	}
 
 	/* Clear internal stats counters. */
 	REG_WR(bp, BNX2_HC_COMMAND, BNX2_HC_COMMAND_CLR_STAT_NOW);
@@ -4737,7 +4747,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 		val = (bp->rx_buf_use_size << 16) | PAGE_SIZE;
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, val);
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_RBDC_KEY,
-		       BNX2_L2CTX_RBDC_JUMBO_KEY);
+		       BNX2_L2CTX_RBDC_JUMBO_KEY - ring_num);
 
 		val = (u64) rxr->rx_pg_desc_mapping[0] >> 32;
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_HI, val);
@@ -4787,6 +4797,7 @@ static void
 bnx2_init_all_rings(struct bnx2 *bp)
 {
 	int i;
+	u32 val;
 
 	bnx2_clear_ring_states(bp);
 
@@ -4798,8 +4809,33 @@ bnx2_init_all_rings(struct bnx2 *bp)
 		REG_WR(bp, BNX2_TSCH_TSS_CFG, ((bp->num_tx_rings - 1) << 24) |
 		       (TX_TSS_CID << 7));
 
+	REG_WR(bp, BNX2_RLUP_RSS_CONFIG, 0);
+	bnx2_reg_wr_ind(bp, BNX2_RXP_SCRATCH_RSS_TBL_SZ, 0);
+
 	for (i = 0; i < bp->num_rx_rings; i++)
 		bnx2_init_rx_ring(bp, i);
+
+	if (bp->num_rx_rings > 1) {
+		u32 tbl_32;
+		u8 *tbl = (u8 *) &tbl_32;
+
+		bnx2_reg_wr_ind(bp, BNX2_RXP_SCRATCH_RSS_TBL_SZ,
+				BNX2_RXP_SCRATCH_RSS_TBL_MAX_ENTRIES);
+
+		for (i = 0; i < BNX2_RXP_SCRATCH_RSS_TBL_MAX_ENTRIES; i++) {
+			tbl[i % 4] = i % (bp->num_rx_rings - 1);
+			if ((i % 4) == 3)
+				bnx2_reg_wr_ind(bp,
+						BNX2_RXP_SCRATCH_RSS_TBL + i,
+						cpu_to_be32(tbl_32));
+		}
+
+		val = BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_ALL_XI |
+		      BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_ALL_XI;
+
+		REG_WR(bp, BNX2_RLUP_RSS_CONFIG, val);
+
+	}
 }
 
 static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
@@ -5663,7 +5699,7 @@ bnx2_free_irq(struct bnx2 *bp)
 }
 
 static void
-bnx2_enable_msix(struct bnx2 *bp)
+bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 {
 	int i, rc;
 	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
@@ -5685,7 +5721,7 @@ bnx2_enable_msix(struct bnx2 *bp)
 	if (rc != 0)
 		return;
 
-	bp->irq_nvecs = BNX2_MAX_MSIX_VEC;
+	bp->irq_nvecs = msix_vecs;
 	bp->flags |= BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
 		bp->irq_tbl[i].vector = msix_ent[i].vector;
@@ -5694,13 +5730,16 @@ bnx2_enable_msix(struct bnx2 *bp)
 static void
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
+	int cpus = num_online_cpus();
+	int msix_vecs = min(cpus + 1, RX_MAX_RSS_RINGS);
+
 	bp->irq_tbl[0].handler = bnx2_interrupt;
 	strcpy(bp->irq_tbl[0].name, bp->dev->name);
 	bp->irq_nvecs = 1;
 	bp->irq_tbl[0].vector = bp->pdev->irq;
 
-	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !dis_msi)
-		bnx2_enable_msix(bp);
+	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !dis_msi && cpus > 1)
+		bnx2_enable_msix(bp, msix_vecs);
 
 	if ((bp->flags & BNX2_FLAG_MSI_CAP) && !dis_msi &&
 	    !(bp->flags & BNX2_FLAG_USING_MSIX)) {
@@ -5716,7 +5755,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 		}
 	}
 	bp->num_tx_rings = 1;
-	bp->num_rx_rings = 1;
+	bp->num_rx_rings = bp->irq_nvecs;
 }
 
 /* Called with rtnl_lock */
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 362bef6..efa0ca9 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -4158,6 +4158,23 @@ struct l2_fhdr {
 
 
 /*
+ *  rlup_reg definition
+ *  offset: 0x2000
+ */
+#define BNX2_RLUP_RSS_CONFIG				0x0000201c
+#define BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_XI		 (0x3L<<0)
+#define BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_OFF_XI	 (0L<<0)
+#define BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_ALL_XI	 (1L<<0)
+#define BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_IP_ONLY_XI	 (2L<<0)
+#define BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_RES_XI	 (3L<<0)
+#define BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_XI		 (0x3L<<2)
+#define BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_OFF_XI	 (0L<<2)
+#define BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_ALL_XI	 (1L<<2)
+#define BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_IP_ONLY_XI	 (2L<<2)
+#define BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_RES_XI	 (3L<<2)
+
+
+/*
  *  rbuf_reg definition
  *  offset: 0x200000
  */
@@ -5528,6 +5545,9 @@ struct l2_fhdr {
 #define BNX2_HC_TX_QUICK_CONS_TRIP_OFF	(BNX2_HC_TX_QUICK_CONS_TRIP_1 -	\
 					 BNX2_HC_SB_CONFIG_1)
 #define BNX2_HC_TX_TICKS_OFF	(BNX2_HC_TX_TICKS_1 - BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_RX_QUICK_CONS_TRIP_OFF	(BNX2_HC_RX_QUICK_CONS_TRIP_1 - \
+					 BNX2_HC_SB_CONFIG_1)
+#define BNX2_HC_RX_TICKS_OFF	(BNX2_HC_RX_TICKS_1 - BNX2_HC_SB_CONFIG_1)
 
 
 /*
@@ -5856,6 +5876,9 @@ struct l2_fhdr {
 #define BNX2_RXP_FTQ_CTL_CUR_DEPTH			 (0x3ffL<<22)
 
 #define BNX2_RXP_SCRATCH				0x000e0000
+#define BNX2_RXP_SCRATCH_RSS_TBL_SZ			 0x000e0038
+#define BNX2_RXP_SCRATCH_RSS_TBL			 0x000e003c
+#define BNX2_RXP_SCRATCH_RSS_TBL_MAX_ENTRIES		 128
 
 
 /*
@@ -6480,6 +6503,7 @@ struct l2_fhdr {
 #define TX_TSS_CID	32
 #define RX_CID		0
 #define RX_RSS_CID	4
+#define RX_MAX_RSS_RINGS	7
 
 #define MB_TX_CID_ADDR	MB_GET_CID_ADDR(TX_CID)
 #define MB_RX_CID_ADDR	MB_GET_CID_ADDR(RX_CID)
@@ -6558,7 +6582,7 @@ struct flash_spec {
 };
 
 #define BNX2_MAX_MSIX_HW_VEC	9
-#define BNX2_MAX_MSIX_VEC	2
+#define BNX2_MAX_MSIX_VEC	9
 #define BNX2_BASE_VEC		0
 #define BNX2_TX_VEC		1
 #define BNX2_TX_INT_NUM	(BNX2_TX_VEC << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT)
-- 
1.5.5.GIT



