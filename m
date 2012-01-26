From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 07/10] bnx2x: Track active PFs with bitmap
Date: Thu, 26 Jan 2012 18:01:51 +0200
Message-ID: <1327593714-18358-8-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4759 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab2AZQB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:59 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recovery register (to which a hardware lock has been added in previous
patch) is used amongst other things to track the active PFs. The old
implementation which used a per path counter is not viable in a virtualized
environment where a pf may increment the counter and then have the kernel
crash around it preventing the counter from ever reaching zero.
In the new implementation the scenario described will result in the PF timing
out against the mcp, which will clear the PF's bit in the bitmask allowing
recovery process to proceed.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    8 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   56 ++++++++++-----------
 3 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index b75c8ea..15db2d6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1767,6 +1767,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bnx2x_napi_enable(bp);
 
+	/* set pf load just before approaching the MCP */
+	bnx2x_set_pf_load(bp);
+
 	/* Send LOAD_REQUEST command to MCP
 	 * Returns the type of LOAD command:
 	 * if it is the first port to be initialized
@@ -1972,7 +1975,6 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (bp->state == BNX2X_STATE_OPEN)
 		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
 #endif
-	bnx2x_inc_load_cnt(bp);
 
 	/* Wait for all pending SP commands to complete */
 	if (!bnx2x_wait_sp_comp(bp, ~0x0UL)) {
@@ -2012,6 +2014,8 @@ load_error2:
 	bp->port.pmf = 0;
 load_error1:
 	bnx2x_napi_disable(bp);
+	/* clear pf_load status, as it was already set */
+	bnx2x_clear_pf_load(bp);
 load_error0:
 	bnx2x_free_mem(bp);
 
@@ -2132,7 +2136,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	/* The last driver must disable a "close the gate" if there is no
 	 * parity attention or "process kill" pending.
 	 */
-	if (!bnx2x_dec_load_cnt(bp) && bnx2x_reset_is_done(bp, BP_PATH(bp)))
+	if (!bnx2x_clear_pf_load(bp) && bnx2x_reset_is_done(bp, BP_PATH(bp)))
 		bnx2x_disable_close_the_gate(bp);
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index bd990c2..a6ef3ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -379,8 +379,8 @@ void bnx2x_set_q_rx_mode(struct bnx2x *bp, u8 cl_id,
 			 unsigned long ramrod_flags);
 
 /* Parity errors related */
-void bnx2x_inc_load_cnt(struct bnx2x *bp);
-u32 bnx2x_dec_load_cnt(struct bnx2x *bp);
+void bnx2x_set_pf_load(struct bnx2x *bp);
+bool bnx2x_clear_pf_load(struct bnx2x *bp);
 bool bnx2x_chk_parity_attn(struct bnx2x *bp, bool *global, bool print);
 bool bnx2x_reset_is_done(struct bnx2x *bp, int engine);
 void bnx2x_set_reset_in_progress(struct bnx2x *bp);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 4824b0f..f7f167a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3812,11 +3812,11 @@ bool bnx2x_reset_is_done(struct bnx2x *bp, int engine)
 }
 
 /*
- * Increment the load counter for the current engine.
+ * set pf load for the current pf.
  *
  * should be run under rtnl lock
  */
-void bnx2x_inc_load_cnt(struct bnx2x *bp)
+void bnx2x_set_pf_load(struct bnx2x *bp)
 {
 	u32 val1, val;
 	u32 mask = BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
@@ -3832,8 +3832,8 @@ void bnx2x_inc_load_cnt(struct bnx2x *bp)
 	/* get the current counter value */
 	val1 = (val & mask) >> shift;
 
-	/* increment... */
-	val1++;
+	/* set bit of that PF */
+	val1 |= (1 << bp->pf_num);
 
 	/* clear the old value */
 	val &= ~mask;
@@ -3846,15 +3846,15 @@ void bnx2x_inc_load_cnt(struct bnx2x *bp)
 }
 
 /**
- * bnx2x_dec_load_cnt - decrement the load counter
+ * bnx2x_clear_pf_load - clear pf load mark
  *
  * @bp:		driver handle
  *
  * Should be run under rtnl lock.
  * Decrements the load counter for the current engine. Returns
- * the new counter value.
+ * whether other functions are still loaded
  */
-u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
+bool bnx2x_clear_pf_load(struct bnx2x *bp)
 {
 	u32 val1, val;
 	u32 mask = BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
@@ -3869,8 +3869,8 @@ u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
 	/* get the current counter value */
 	val1 = (val & mask) >> shift;
 
-	/* decrement... */
-	val1--;
+	/* clear bit of that PF */
+	val1 &= ~(1 << bp->pf_num);
 
 	/* clear the old value */
 	val &= ~mask;
@@ -3884,11 +3884,11 @@ u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
 }
 
 /*
- * Read the load counter for the current engine.
+ * Read the load status for the current engine.
  *
  * should be run under rtnl lock
  */
-static inline u32 bnx2x_get_load_cnt(struct bnx2x *bp, int engine)
+static inline bool bnx2x_get_load_status(struct bnx2x *bp, int engine)
 {
 	u32 mask = (engine ? BNX2X_PATH1_LOAD_CNT_MASK :
 			     BNX2X_PATH0_LOAD_CNT_MASK);
@@ -3900,17 +3900,15 @@ static inline u32 bnx2x_get_load_cnt(struct bnx2x *bp, int engine)
 
 	val = (val & mask) >> shift;
 
-	DP(NETIF_MSG_HW, "load_cnt for engine %d = %d\n", engine, val);
+	DP(NETIF_MSG_HW, "load mask for engine %d = 0x%x\n", engine, val);
 
-	return val;
+	return val != 0;
 }
 
 /*
- * Reset the load counter for the current engine.
- *
- * should be run under rtnl lock
+ * Reset the load status for the current engine.
  */
-static inline void bnx2x_clear_load_cnt(struct bnx2x *bp)
+static inline void bnx2x_clear_load_status(struct bnx2x *bp)
 {
 	u32 val;
 	u32 mask = (BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
@@ -8582,10 +8580,10 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 			DP(NETIF_MSG_HW, "State is BNX2X_RECOVERY_WAIT\n");
 			if (bp->is_leader) {
 				int other_engine = BP_PATH(bp) ? 0 : 1;
-				u32 other_load_counter =
-					bnx2x_get_load_cnt(bp, other_engine);
-				u32 load_counter =
-					bnx2x_get_load_cnt(bp, BP_PATH(bp));
+				bool other_load_status =
+					bnx2x_get_load_status(bp, other_engine);
+				bool load_status =
+					bnx2x_get_load_status(bp, BP_PATH(bp));
 				global = bnx2x_reset_is_global(bp);
 
 				/*
@@ -8596,8 +8594,8 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 				 * the the gates will remain closed for that
 				 * engine.
 				 */
-				if (load_counter ||
-				    (global && other_load_counter)) {
+				if (load_status ||
+				    (global && other_load_status)) {
 					/* Wait until all other functions get
 					 * down.
 					 */
@@ -10206,14 +10204,14 @@ static int bnx2x_open(struct net_device *dev)
 	struct bnx2x *bp = netdev_priv(dev);
 	bool global = false;
 	int other_engine = BP_PATH(bp) ? 0 : 1;
-	u32 other_load_counter, load_counter;
+	bool other_load_status, load_status;
 
 	netif_carrier_off(dev);
 
 	bnx2x_set_power_state(bp, PCI_D0);
 
-	other_load_counter = bnx2x_get_load_cnt(bp, other_engine);
-	load_counter = bnx2x_get_load_cnt(bp, BP_PATH(bp));
+	other_load_status = bnx2x_get_load_status(bp, other_engine);
+	load_status = bnx2x_get_load_status(bp, BP_PATH(bp));
 
 	/*
 	 * If parity had happen during the unload, then attentions
@@ -10239,8 +10237,8 @@ static int bnx2x_open(struct net_device *dev)
 			 * global blocks only the first in the chip should try
 			 * to recover.
 			 */
-			if ((!load_counter &&
-			     (!global || !other_load_counter)) &&
+			if ((!load_status &&
+			     (!global || !other_load_status)) &&
 			    bnx2x_trylock_leader_lock(bp) &&
 			    !bnx2x_leader_reset(bp)) {
 				netdev_info(bp->dev, "Recovered in open\n");
@@ -10680,7 +10678,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
 
 	/* Reset the load counter */
-	bnx2x_clear_load_cnt(bp);
+	bnx2x_clear_load_status(bp);
 
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-- 
1.7.1
