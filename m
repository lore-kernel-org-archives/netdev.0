From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 7/9] bnx2x: NAPI and interrupts enable/disable
Date: Mon, 25 Aug 2008 17:25:00 +0300
Message-ID: <1219674300.19456.33.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754135AbYHYO0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:26:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAPI and interrupts enable/disable
Fixing the order of enabling and disabling NAPI and the interrupts

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  149 ++++++++++++++++++++++-----------------------
 1 files changed, 73 insertions(+), 76 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 1c81da4..f0b04c9 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6058,6 +6058,44 @@ static int bnx2x_req_irq(struct bnx2x *bp)
 	return rc;
 }
 
+static void bnx2x_napi_enable(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i)
+		napi_enable(&bnx2x_fp(bp, i, napi));
+}
+
+static void bnx2x_napi_disable(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i)
+		napi_disable(&bnx2x_fp(bp, i, napi));
+}
+
+static void bnx2x_netif_start(struct bnx2x *bp)
+{
+	if (atomic_dec_and_test(&bp->intr_sem)) {
+		if (netif_running(bp->dev)) {
+			if (bp->state == BNX2X_STATE_OPEN)
+				netif_wake_queue(bp->dev);
+			bnx2x_napi_enable(bp);
+			bnx2x_int_enable(bp);
+		}
+	}
+}
+
+static void bnx2x_netif_stop(struct bnx2x *bp)
+{
+	bnx2x_int_disable_sync(bp);
+	if (netif_running(bp->dev)) {
+		bnx2x_napi_disable(bp);
+		netif_tx_disable(bp->dev);
+		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	}
+}
+
 /*
  * Init service functions
  */
@@ -6363,8 +6401,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	/* Enable Rx interrupt handling before sending the ramrod
 	   as it's completed on Rx FP queue */
-	for_each_queue(bp, i)
-		napi_enable(&bnx2x_fp(bp, i, napi));
+	bnx2x_napi_enable(bp);
 
 	/* Enable interrupt handling */
 	atomic_set(&bp->intr_sem, 0);
@@ -6431,8 +6468,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	return 0;
 
 load_netif_stop:
-	for_each_queue(bp, i)
-		napi_disable(&bnx2x_fp(bp, i, napi));
+	bnx2x_napi_disable(bp);
 load_rings_free:
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
@@ -6614,11 +6650,9 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
 
-	if (netif_running(bp->dev)) {
-		netif_tx_disable(bp->dev);
-		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	}
-
+	bnx2x_netif_stop(bp);
+	if (!netif_running(bp->dev))
+		bnx2x_napi_disable(bp);
 	del_timer_sync(&bp->timer);
 	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
@@ -6632,9 +6666,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		smp_rmb();
 		while (BNX2X_HAS_TX_WORK(fp)) {
 
-			if (!netif_running(bp->dev))
-				bnx2x_tx_int(fp, 1000);
-
+			bnx2x_tx_int(fp, 1000);
 			if (!cnt) {
 				BNX2X_ERR("timeout waiting for queue[%d]\n",
 					  i);
@@ -6650,46 +6682,12 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 			smp_rmb();
 		}
 	}
-
 	/* Give HW time to discard old tx messages */
 	msleep(1);
 
-	for_each_queue(bp, i)
-		napi_disable(&bnx2x_fp(bp, i, napi));
-	/* Disable interrupts after Tx and Rx are disabled on stack level */
-	bnx2x_int_disable_sync(bp);
-
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 
-	if (unload_mode == UNLOAD_NORMAL)
-		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
-
-	else if (bp->flags & NO_WOL_FLAG) {
-		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
-		if (CHIP_IS_E1H(bp))
-			REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
-
-	} else if (bp->wol) {
-		u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-		u8 *mac_addr = bp->dev->dev_addr;
-		u32 val;
-		/* The mac address is written to entries 1-4 to
-		   preserve entry 0 which is used by the PMF */
-		u8 entry = (BP_E1HVN(bp) + 1)*8;
-
-		val = (mac_addr[0] << 8) | mac_addr[1];
-		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry, val);
-
-		val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
-		      (mac_addr[4] << 8) | mac_addr[5];
-		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
-
-		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
-
-	} else
-		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
-
 	if (CHIP_IS_E1(bp)) {
 		struct mac_configuration_cmd *config =
 						bnx2x_sp(bp, mcast_config);
@@ -6712,14 +6710,41 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 			      U64_LO(bnx2x_sp_mapping(bp, mcast_config)), 0);
 
 	} else { /* E1H */
+		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
+
 		bnx2x_set_mac_addr_e1h(bp, 0);
 
 		for (i = 0; i < MC_HASH_SIZE; i++)
 			REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
 	}
 
-	if (CHIP_IS_E1H(bp))
-		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
+	if (unload_mode == UNLOAD_NORMAL)
+		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
+
+	else if (bp->flags & NO_WOL_FLAG) {
+		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
+		if (CHIP_IS_E1H(bp))
+			REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
+
+	} else if (bp->wol) {
+		u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+		u8 *mac_addr = bp->dev->dev_addr;
+		u32 val;
+		/* The mac address is written to entries 1-4 to
+		   preserve entry 0 which is used by the PMF */
+		u8 entry = (BP_E1HVN(bp) + 1)*8;
+
+		val = (mac_addr[0] << 8) | mac_addr[1];
+		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry, val);
+
+		val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
+		      (mac_addr[4] << 8) | mac_addr[5];
+		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
+
+		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
+
+	} else
+		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
 	/* Close multi and leading connections
 	   Completions for ramrods are collected in a synchronous way */
@@ -8621,34 +8646,6 @@ test_mem_exit:
 	return rc;
 }
 
-static void bnx2x_netif_start(struct bnx2x *bp)
-{
-	int i;
-
-	if (atomic_dec_and_test(&bp->intr_sem)) {
-		if (netif_running(bp->dev)) {
-			bnx2x_int_enable(bp);
-			for_each_queue(bp, i)
-				napi_enable(&bnx2x_fp(bp, i, napi));
-			if (bp->state == BNX2X_STATE_OPEN)
-				netif_wake_queue(bp->dev);
-		}
-	}
-}
-
-static void bnx2x_netif_stop(struct bnx2x *bp)
-{
-	int i;
-
-	if (netif_running(bp->dev)) {
-		netif_tx_disable(bp->dev);
-		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
-		for_each_queue(bp, i)
-			napi_disable(&bnx2x_fp(bp, i, napi));
-	}
-	bnx2x_int_disable_sync(bp);
-}
-
 static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up)
 {
 	int cnt = 1000;
-- 
1.5.3.2




