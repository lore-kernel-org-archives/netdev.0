From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 05/25] bnx2x: Load/Unload under traffic
Date: Wed, 13 Aug 2008 17:13:16 +0300
Message-ID: <1218636796.547.80.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4492 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753124AbYHMONj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:13:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Load/Unload under traffic
Few issues were found when loading and unloading under traffic:
- When receiving Tx interrupt call netif_wake_queue if the queue is
  stopped but the state is open 
- Check that interrupts are enabled before doing anything else on the
  msix_fp_int function
- In nic_load, enable the interrupts only when needed and ready for it
- Function stop_leading returns status since it can fail
- Add 1ms delay when unloading the driver to validate that there are no
  open transactions that already started by the FW
- Splitting the "has work" function into Tx and Rx so the same function
  will be used on unload and interrupts
- Do not request for WoL if only resetting the device (save the time
  that it takes the FW to set the link after reset)
- Fixing the device reset after iSCSI boot and before driver load - all
  internal buffers must be cleared before the driver is loaded

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    9 ++
 drivers/net/bnx2x_main.c |  221 +++++++++++++++++++++++++--------------------
 drivers/net/bnx2x_reg.h  |    3 +
 3 files changed, 135 insertions(+), 98 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 9cbf0e8..b9aa6f4 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -274,6 +274,15 @@ struct bnx2x_fastpath {
 
 #define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
 
+#define BNX2X_HAS_TX_WORK(fp) \
+			((fp->tx_pkt_prod != le16_to_cpu(*fp->tx_cons_sb)) || \
+			 (fp->tx_pkt_prod != fp->tx_pkt_cons))
+
+#define BNX2X_HAS_RX_WORK(fp) \
+			(fp->rx_comp_cons != le16_to_cpu(*fp->rx_cons_sb))
+
+#define BNX2X_HAS_WORK(fp)	(BNX2X_HAS_RX_WORK(fp) || BNX2X_HAS_TX_WORK(fp))
+
 
 /* MC hsi */
 #define MAX_FETCH_BD			13	/* HW max BDs per packet */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6115161..dfa8c7b 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -717,21 +717,6 @@ static inline u16 bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 	return rc;
 }
 
-static inline int bnx2x_has_work(struct bnx2x_fastpath *fp)
-{
-	u16 rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
-
-	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		rx_cons_sb++;
-
-	if ((fp->rx_comp_cons != rx_cons_sb) ||
-	    (fp->tx_pkt_prod != le16_to_cpu(*fp->tx_cons_sb)) ||
-	    (fp->tx_pkt_prod != fp->tx_pkt_cons))
-		return 1;
-
-	return 0;
-}
-
 static u16 bnx2x_ack_int(struct bnx2x *bp)
 {
 	u32 igu_addr = (IGU_ADDR_SIMD_MASK + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
@@ -899,6 +884,7 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 		netif_tx_lock(bp->dev);
 
 		if (netif_queue_stopped(bp->dev) &&
+		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_wake_queue(bp->dev);
 
@@ -1617,6 +1603,12 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	struct net_device *dev = bp->dev;
 	int index = FP_IDX(fp);
 
+	/* Return here if interrupt is disabled */
+	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
+		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
+		return IRQ_HANDLED;
+	}
+
 	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
 	   index, FP_SB_ID(fp));
 	bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID, 0, IGU_INT_DISABLE, 0);
@@ -6230,22 +6222,24 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (!BP_NOMCP(bp)) {
 		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
 		if (!load_code) {
-			BNX2X_ERR("MCP response failure, unloading\n");
+			BNX2X_ERR("MCP response failure, aborting\n");
 			return -EBUSY;
 		}
 		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED)
 			return -EBUSY; /* other port in diagnostic mode */
 
 	} else {
+		int port = BP_PORT(bp);
+
 		DP(NETIF_MSG_IFUP, "NO MCP load counts before us %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		load_count[0]++;
-		load_count[1 + BP_PORT(bp)]++;
+		load_count[1 + port]++;
 		DP(NETIF_MSG_IFUP, "NO MCP new load counts       %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		if (load_count[0] == 1)
 			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
-		else if (load_count[1 + BP_PORT(bp)] == 1)
+		else if (load_count[1 + port] == 1)
 			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
 		else
 			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
@@ -6294,9 +6288,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		bnx2x_fp(bp, i, disable_tpa) =
 					((bp->flags & TPA_ENABLE_FLAG) == 0);
 
-	/* Disable interrupt handling until HW is initialized */
-	atomic_set(&bp->intr_sem, 1);
-
 	if (bp->flags & USING_MSIX_FLAG) {
 		rc = bnx2x_req_msix_irqs(bp);
 		if (rc) {
@@ -6323,9 +6314,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		goto load_error;
 	}
 
-	/* Enable interrupt handling */
-	atomic_set(&bp->intr_sem, 0);
-
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp, load_code);
 
@@ -6333,7 +6321,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (!BP_NOMCP(bp)) {
 		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
 		if (!load_code) {
-			BNX2X_ERR("MCP response failure, unloading\n");
+			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
 			goto load_int_disable;
 		}
@@ -6348,11 +6336,12 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	for_each_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 
+	/* Enable interrupt handling */
+	atomic_set(&bp->intr_sem, 0);
+
 	rc = bnx2x_setup_leading(bp);
 	if (rc) {
-#ifdef BNX2X_STOP_ON_ERROR
-		bp->panic = 1;
-#endif
+		BNX2X_ERR("Setup leading failed!\n");
 		goto load_stop_netif;
 	}
 
@@ -6386,7 +6375,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		break;
 
 	case LOAD_OPEN:
-		/* IRQ is only requested from bnx2x_open */
 		netif_start_queue(bp->dev);
 		bnx2x_set_rx_mode(bp->dev);
 		if (bp->flags & USING_MSIX_FLAG)
@@ -6458,7 +6446,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 	return rc;
 }
 
-static void bnx2x_stop_leading(struct bnx2x *bp)
+static int bnx2x_stop_leading(struct bnx2x *bp)
 {
 	u16 dsb_sp_prod_idx;
 	/* if the other port is handling traffic,
@@ -6476,7 +6464,7 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
 			       &(bp->fp[0].state), 1);
 	if (rc) /* timeout */
-		return;
+		return rc;
 
 	dsb_sp_prod_idx = *bp->dsb_sp_prod;
 
@@ -6495,13 +6483,18 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 			   *bp->dsb_sp_prod, dsb_sp_prod_idx);
 #ifdef BNX2X_STOP_ON_ERROR
 			bnx2x_panic();
+#else
+			rc = -EBUSY;
 #endif
 			break;
 		}
 		cnt--;
+		msleep(1);
 	}
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
 	bp->fp[0].state = BNX2X_FP_STATE_CLOSED;
+
+	return rc;
 }
 
 static void bnx2x_reset_func(struct bnx2x *bp)
@@ -6586,8 +6579,9 @@ static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 /* msut be called with rtnl_lock */
 static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 {
+	int port = BP_PORT(bp);
 	u32 reset_code = 0;
-	int i, cnt;
+	int i, cnt, rc;
 
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
@@ -6604,22 +6598,17 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	/* Wait until all fast path tasks complete */
+	/* Wait until tx fast path tasks complete */
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-#ifdef BNX2X_STOP_ON_ERROR
-#ifdef __powerpc64__
-		DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
-#else
-		DP(NETIF_MSG_IFDOWN, "fp->tpa_queue_used = 0x%llx\n",
-#endif
-		   fp->tpa_queue_used);
-#endif
 		cnt = 1000;
 		smp_rmb();
-		while (bnx2x_has_work(fp)) {
-			msleep(1);
+		while (BNX2X_HAS_TX_WORK(fp)) {
+
+			if (!netif_running(bp->dev))
+				bnx2x_tx_int(fp, 1000);
+
 			if (!cnt) {
 				BNX2X_ERR("timeout waiting for queue[%d]\n",
 					  i);
@@ -6631,14 +6620,13 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 #endif
 			}
 			cnt--;
+			msleep(1);
 			smp_rmb();
 		}
 	}
 
-	/* Wait until all slow path tasks complete */
-	cnt = 1000;
-	while ((bp->spq_left != MAX_SPQ_PENDING) && cnt--)
-		msleep(1);
+	/* Give HW time to discard old tx messages */
+	msleep(1);
 
 	for_each_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
@@ -6648,52 +6636,51 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 
-	if (bp->flags & NO_WOL_FLAG)
+	if (unload_mode == UNLOAD_NORMAL)
+		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
+
+	else if (bp->flags & NO_WOL_FLAG) {
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
+		if (CHIP_IS_E1H(bp))
+			REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
 
-	else if (bp->wol) {
-		u32 emac_base = BP_PORT(bp) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	} else if (bp->wol) {
+		u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		u8 *mac_addr = bp->dev->dev_addr;
 		u32 val;
-
 		/* The mac address is written to entries 1-4 to
 		   preserve entry 0 which is used by the PMF */
+		u8 entry = (BP_E1HVN(bp) + 1)*8;
+
 		val = (mac_addr[0] << 8) | mac_addr[1];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + (BP_E1HVN(bp) + 1)*8, val);
+		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + entry, val);
 
 		val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
 		      (mac_addr[4] << 8) | mac_addr[5];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + (BP_E1HVN(bp) + 1)*8 + 4,
-			val);
+		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
 
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
 
 	} else
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
+
 	/* Close multi and leading connections
 	   Completions for ramrods are collected in a synchronous way */
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_stop_multi(bp, i))
 			goto unload_error;
 
-	if (CHIP_IS_E1H(bp))
-		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + BP_PORT(bp)*8, 0);
-
-	bnx2x_stop_leading(bp);
-#ifdef BNX2X_STOP_ON_ERROR
-	/* If ramrod completion timed out - break here! */
-	if (bp->panic) {
+	rc = bnx2x_stop_leading(bp);
+	if (rc) {
 		BNX2X_ERR("Stop leading failed!\n");
+#ifdef BNX2X_STOP_ON_ERROR
 		return -EBUSY;
-	}
+#else
+		goto unload_error;
 #endif
-
-	if ((bp->state != BNX2X_STATE_CLOSING_WAIT4_UNLOAD) ||
-	    (bp->fp[0].state != BNX2X_FP_STATE_CLOSED)) {
-		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!  "
-		   "state 0x%x  fp[0].state 0x%x\n",
-		   bp->state, bp->fp[0].state);
 	}
 
 unload_error:
@@ -6703,12 +6690,12 @@ unload_error:
 		DP(NETIF_MSG_IFDOWN, "NO MCP load counts      %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		load_count[0]--;
-		load_count[1 + BP_PORT(bp)]--;
+		load_count[1 + port]--;
 		DP(NETIF_MSG_IFDOWN, "NO MCP new load counts  %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
 		if (load_count[0] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
-		else if (load_count[1 + BP_PORT(bp)] == 0)
+		else if (load_count[1 + port] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_PORT;
 		else
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_FUNCTION;
@@ -6780,50 +6767,86 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 		/* Check if it is the UNDI driver
 		 * UNDI driver initializes CID offset for normal bell to 0x7
 		 */
+		bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
 		if (val == 0x7) {
 			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
-			/* save our func and fw_seq */
+			/* save our func */
 			int func = BP_FUNC(bp);
-			u16 fw_seq = bp->fw_seq;
+			u32 swap_en;
+			u32 swap_val;
 
 			BNX2X_DEV_INFO("UNDI is active! reset device\n");
 
 			/* try unload UNDI on port 0 */
 			bp->func = 0;
-			bp->fw_seq = (SHMEM_RD(bp,
-					     func_mb[bp->func].drv_mb_header) &
-				      DRV_MSG_SEQ_NUMBER_MASK);
-
+			bp->fw_seq =
+			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
+				DRV_MSG_SEQ_NUMBER_MASK);
 			reset_code = bnx2x_fw_command(bp, reset_code);
-			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
 
 			/* if UNDI is loaded on the other port */
 			if (reset_code != FW_MSG_CODE_DRV_UNLOAD_COMMON) {
 
+				/* send "DONE" for previous unload */
+				bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+
+				/* unload UNDI on port 1 */
 				bp->func = 1;
-				bp->fw_seq = (SHMEM_RD(bp,
-					     func_mb[bp->func].drv_mb_header) &
-					      DRV_MSG_SEQ_NUMBER_MASK);
-
-				bnx2x_fw_command(bp,
-					     DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS);
-				bnx2x_fw_command(bp,
-						 DRV_MSG_CODE_UNLOAD_DONE);
-
-				/* restore our func and fw_seq */
-				bp->func = func;
-				bp->fw_seq = fw_seq;
+				bp->fw_seq =
+			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
+					DRV_MSG_SEQ_NUMBER_MASK);
+				reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
+
+				bnx2x_fw_command(bp, reset_code);
 			}
 
+			REG_WR(bp, (BP_PORT(bp) ? HC_REG_CONFIG_1 :
+				    HC_REG_CONFIG_0), 0x1000);
+
+			/* close input traffic and wait for it */
+			/* Do not rcv packets to BRB */
+			REG_WR(bp,
+			      (BP_PORT(bp) ? NIG_REG_LLH1_BRB1_DRV_MASK :
+					     NIG_REG_LLH0_BRB1_DRV_MASK), 0x0);
+			/* Do not direct rcv packets that are not for MCP to
+			 * the BRB */
+			REG_WR(bp,
+			       (BP_PORT(bp) ? NIG_REG_LLH1_BRB1_NOT_MCP :
+					      NIG_REG_LLH0_BRB1_NOT_MCP), 0x0);
+			/* clear AEU */
+			REG_WR(bp,
+			     (BP_PORT(bp) ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
+					    MISC_REG_AEU_MASK_ATTN_FUNC_0), 0);
+			msleep(10);
+
+			/* save NIG port swap info */
+			swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
+			swap_en = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
 			/* reset device */
 			REG_WR(bp,
 			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
-			       0xd3ffff7f);
+			       0xd3ffffff);
 			REG_WR(bp,
 			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 			       0x1403);
+			/* take the NIG out of reset and restore swap values */
+			REG_WR(bp,
+			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
+			       MISC_REGISTERS_RESET_REG_1_RST_NIG);
+			REG_WR(bp, NIG_REG_PORT_SWAP, swap_val);
+			REG_WR(bp, NIG_REG_STRAP_OVERRIDE, swap_en);
+
+			/* send unload done to the MCP */
+			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+
+			/* restore our func and fw_seq */
+			bp->func = func;
+			bp->fw_seq =
+			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
+				DRV_MSG_SEQ_NUMBER_MASK);
 		}
+		bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_UNDI);
 	}
 }
 
@@ -7384,6 +7407,9 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	int func = BP_FUNC(bp);
 	int rc;
 
+	/* Disable interrupt handling until HW is initialized */
+	atomic_set(&bp->intr_sem, 1);
+
 	mutex_init(&bp->port.phy_mutex);
 
 	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
@@ -9163,17 +9189,16 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 
 	bnx2x_update_fpsb_idx(fp);
 
-	if ((fp->tx_pkt_prod != le16_to_cpu(*fp->tx_cons_sb)) ||
-	    (fp->tx_pkt_prod != fp->tx_pkt_cons))
+	if (BNX2X_HAS_TX_WORK(fp))
 		bnx2x_tx_int(fp, budget);
 
-	if (le16_to_cpu(*fp->rx_cons_sb) != fp->rx_comp_cons)
+	if (BNX2X_HAS_RX_WORK(fp))
 		work_done = bnx2x_rx_int(fp, budget);
 
-	rmb(); /* bnx2x_has_work() reads the status block */
+	rmb(); /* BNX2X_HAS_WORK() reads the status block */
 
 	/* must not complete if we consumed full budget */
-	if ((work_done < budget) && !bnx2x_has_work(fp)) {
+	if ((work_done < budget) && !BNX2X_HAS_WORK(fp)) {
 
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
@@ -9408,7 +9433,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			DP(NETIF_MSG_TX_QUEUED, "SKB linearization failed - "
 			   "silently dropping this SKB\n");
 			dev_kfree_skb_any(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	}
 
@@ -10200,7 +10225,7 @@ static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	netif_device_detach(dev);
 
-	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
 
 	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
 
@@ -10233,7 +10258,7 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 
-	rc = bnx2x_nic_load(bp, LOAD_NORMAL);
+	rc = bnx2x_nic_load(bp, LOAD_OPEN);
 
 	rtnl_unlock();
 
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 40c3a77..b5313c2 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1677,6 +1677,7 @@
 /* [RW 8] init credit counter for port0 in LLH */
 #define NIG_REG_LLH0_XCM_INIT_CREDIT				 0x10554
 #define NIG_REG_LLH0_XCM_MASK					 0x10130
+#define NIG_REG_LLH1_BRB1_DRV_MASK				 0x10248
 /* [RW 1] send to BRB1 if no match on any of RMP rules. */
 #define NIG_REG_LLH1_BRB1_NOT_MCP				 0x102dc
 /* [RW 2] Determine the classification participants. 0: no classification.1:
@@ -4962,6 +4963,7 @@
 #define MISC_REGISTERS_GPIO_PORT_SHIFT				 4
 #define MISC_REGISTERS_GPIO_SET_POS				 8
 #define MISC_REGISTERS_RESET_REG_1_CLEAR			 0x588
+#define MISC_REGISTERS_RESET_REG_1_RST_NIG			 (0x1<<7)
 #define MISC_REGISTERS_RESET_REG_1_SET				 0x584
 #define MISC_REGISTERS_RESET_REG_2_CLEAR			 0x598
 #define MISC_REGISTERS_RESET_REG_2_RST_BMAC0			 (0x1<<0)
@@ -4997,6 +4999,7 @@
 #define HW_LOCK_RESOURCE_8072_MDIO				 0
 #define HW_LOCK_RESOURCE_GPIO					 1
 #define HW_LOCK_RESOURCE_SPIO					 2
+#define HW_LOCK_RESOURCE_UNDI					 5
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR		      (1<<18)
 #define AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT		      (1<<31)
 #define AEU_INPUTS_ATTN_BITS_CDU_HW_INTERRUPT		      (1<<9)
-- 
1.5.3.2




