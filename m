From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v3 net] bnx2x: Fix statistics locking scheme
Date: Mon, 23 Mar 2015 10:56:14 +0200
Message-ID: <1427100974-17338-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avcashub2.qlogic.com ([198.70.193.116]:35379 "EHLO
	avcashub1.qlogic.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752055AbbCWI4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 04:56:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Statistics' state-machine in bnx2x driver must be synced with various driver
flows, but its current locking scheme manages to be wasteful [using 2 locks +
additional local variable] and prone to race-conditions at the same time,
as the state-machine and 'action' are being accessed under different locks.

In addition, current 'safe exec' isn't in fact safe, since the only guarantee
it gives is that DMA transactions are over, but ramrods might still be running.

This patch cleans up said logic, leaving us with a single lock for the entire
flow and removing the possible races.

Changes from v2:
	- Switched into mutex locking from semaphore locking.
	- Release locks on error flows.

Changes from v1:
	Failure to acquire lock fails flow instead of printing a warning and
	allowing access to the critical section.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 162 ++++++++++------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h |   6 +-
 5 files changed, 83 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 756053c..4085c4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1811,7 +1811,7 @@ struct bnx2x {
 	int			stats_state;
 
 	/* used for synchronization of concurrent threads statistics handling */
-	spinlock_t		stats_lock;
+	struct mutex		stats_lock;
 
 	/* used by dmae command loader */
 	struct dmae_command	stats_dmae;
@@ -1935,8 +1935,6 @@ struct bnx2x {
 
 	int fp_array_size;
 	u32 dump_preset_idx;
-	bool					stats_started;
-	struct semaphore			stats_sema;
 
 	u8					phys_port_id[ETH_ALEN];
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 996e215..ae571a1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12037,9 +12037,8 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	mutex_init(&bp->drv_info_mutex);
+	mutex_init(&bp->stats_lock);
 	bp->drv_info_mng_owner = false;
-	spin_lock_init(&bp->stats_lock);
-	sema_init(&bp->stats_sema, 1);
 
 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
 	INIT_DELAYED_WORK(&bp->sp_rtnl_task, bnx2x_sp_rtnl_task);
@@ -13668,9 +13667,9 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	cancel_delayed_work_sync(&bp->sp_task);
 	cancel_delayed_work_sync(&bp->period_task);
 
-	spin_lock_bh(&bp->stats_lock);
+	mutex_lock(&bp->stats_lock);
 	bp->stats_state = STATS_STATE_DISABLED;
-	spin_unlock_bh(&bp->stats_lock);
+	mutex_unlock(&bp->stats_lock);
 
 	bnx2x_save_statistics(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index e5aca2d..cfe3c769 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2238,7 +2238,9 @@ int bnx2x_vf_close(struct bnx2x *bp, struct bnx2x_virtf *vf)
 
 		cookie.vf = vf;
 		cookie.state = VF_ACQUIRED;
-		bnx2x_stats_safe_exec(bp, bnx2x_set_vf_state, &cookie);
+		rc = bnx2x_stats_safe_exec(bp, bnx2x_set_vf_state, &cookie);
+		if (rc)
+			goto op_err;
 	}
 
 	DP(BNX2X_MSG_IOV, "set state to acquired\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index d160829..b98ccc3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -123,36 +123,28 @@ static void bnx2x_dp_stats(struct bnx2x *bp)
  */
 static void bnx2x_storm_stats_post(struct bnx2x *bp)
 {
-	if (!bp->stats_pending) {
-		int rc;
+	int rc;
 
-		spin_lock_bh(&bp->stats_lock);
-
-		if (bp->stats_pending) {
-			spin_unlock_bh(&bp->stats_lock);
-			return;
-		}
-
-		bp->fw_stats_req->hdr.drv_stats_counter =
-			cpu_to_le16(bp->stats_counter++);
+	if (bp->stats_pending)
+		return;
 
-		DP(BNX2X_MSG_STATS, "Sending statistics ramrod %d\n",
-		   le16_to_cpu(bp->fw_stats_req->hdr.drv_stats_counter));
+	bp->fw_stats_req->hdr.drv_stats_counter =
+		cpu_to_le16(bp->stats_counter++);
 
-		/* adjust the ramrod to include VF queues statistics */
-		bnx2x_iov_adjust_stats_req(bp);
-		bnx2x_dp_stats(bp);
+	DP(BNX2X_MSG_STATS, "Sending statistics ramrod %d\n",
+	   le16_to_cpu(bp->fw_stats_req->hdr.drv_stats_counter));
 
-		/* send FW stats ramrod */
-		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STAT_QUERY, 0,
-				   U64_HI(bp->fw_stats_req_mapping),
-				   U64_LO(bp->fw_stats_req_mapping),
-				   NONE_CONNECTION_TYPE);
-		if (rc == 0)
-			bp->stats_pending = 1;
+	/* adjust the ramrod to include VF queues statistics */
+	bnx2x_iov_adjust_stats_req(bp);
+	bnx2x_dp_stats(bp);
 
-		spin_unlock_bh(&bp->stats_lock);
-	}
+	/* send FW stats ramrod */
+	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STAT_QUERY, 0,
+			   U64_HI(bp->fw_stats_req_mapping),
+			   U64_LO(bp->fw_stats_req_mapping),
+			   NONE_CONNECTION_TYPE);
+	if (rc == 0)
+		bp->stats_pending = 1;
 }
 
 static void bnx2x_hw_stats_post(struct bnx2x *bp)
@@ -221,7 +213,7 @@ static void bnx2x_stats_comp(struct bnx2x *bp)
  */
 
 /* should be called under stats_sema */
-static void __bnx2x_stats_pmf_update(struct bnx2x *bp)
+static void bnx2x_stats_pmf_update(struct bnx2x *bp)
 {
 	struct dmae_command *dmae;
 	u32 opcode;
@@ -519,7 +511,7 @@ static void bnx2x_func_stats_init(struct bnx2x *bp)
 }
 
 /* should be called under stats_sema */
-static void __bnx2x_stats_start(struct bnx2x *bp)
+static void bnx2x_stats_start(struct bnx2x *bp)
 {
 	if (IS_PF(bp)) {
 		if (bp->port.pmf)
@@ -531,34 +523,13 @@ static void __bnx2x_stats_start(struct bnx2x *bp)
 		bnx2x_hw_stats_post(bp);
 		bnx2x_storm_stats_post(bp);
 	}
-
-	bp->stats_started = true;
-}
-
-static void bnx2x_stats_start(struct bnx2x *bp)
-{
-	if (down_timeout(&bp->stats_sema, HZ/10))
-		BNX2X_ERR("Unable to acquire stats lock\n");
-	__bnx2x_stats_start(bp);
-	up(&bp->stats_sema);
 }
 
 static void bnx2x_stats_pmf_start(struct bnx2x *bp)
 {
-	if (down_timeout(&bp->stats_sema, HZ/10))
-		BNX2X_ERR("Unable to acquire stats lock\n");
 	bnx2x_stats_comp(bp);
-	__bnx2x_stats_pmf_update(bp);
-	__bnx2x_stats_start(bp);
-	up(&bp->stats_sema);
-}
-
-static void bnx2x_stats_pmf_update(struct bnx2x *bp)
-{
-	if (down_timeout(&bp->stats_sema, HZ/10))
-		BNX2X_ERR("Unable to acquire stats lock\n");
-	__bnx2x_stats_pmf_update(bp);
-	up(&bp->stats_sema);
+	bnx2x_stats_pmf_update(bp);
+	bnx2x_stats_start(bp);
 }
 
 static void bnx2x_stats_restart(struct bnx2x *bp)
@@ -568,11 +539,9 @@ static void bnx2x_stats_restart(struct bnx2x *bp)
 	 */
 	if (IS_VF(bp))
 		return;
-	if (down_timeout(&bp->stats_sema, HZ/10))
-		BNX2X_ERR("Unable to acquire stats lock\n");
+
 	bnx2x_stats_comp(bp);
-	__bnx2x_stats_start(bp);
-	up(&bp->stats_sema);
+	bnx2x_stats_start(bp);
 }
 
 static void bnx2x_bmac_stats_update(struct bnx2x *bp)
@@ -1246,18 +1215,12 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 {
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
 
-	/* we run update from timer context, so give up
-	 * if somebody is in the middle of transition
-	 */
-	if (down_trylock(&bp->stats_sema))
+	if (bnx2x_edebug_stats_stopped(bp))
 		return;
 
-	if (bnx2x_edebug_stats_stopped(bp) || !bp->stats_started)
-		goto out;
-
 	if (IS_PF(bp)) {
 		if (*stats_comp != DMAE_COMP_VAL)
-			goto out;
+			return;
 
 		if (bp->port.pmf)
 			bnx2x_hw_stats_update(bp);
@@ -1267,7 +1230,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 				BNX2X_ERR("storm stats were not updated for 3 times\n");
 				bnx2x_panic();
 			}
-			goto out;
+			return;
 		}
 	} else {
 		/* vf doesn't collect HW statistics, and doesn't get completions
@@ -1281,7 +1244,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 
 	/* vf is done */
 	if (IS_VF(bp))
-		goto out;
+		return;
 
 	if (netif_msg_timer(bp)) {
 		struct bnx2x_eth_stats *estats = &bp->eth_stats;
@@ -1292,9 +1255,6 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 
 	bnx2x_hw_stats_post(bp);
 	bnx2x_storm_stats_post(bp);
-
-out:
-	up(&bp->stats_sema);
 }
 
 static void bnx2x_port_stats_stop(struct bnx2x *bp)
@@ -1358,12 +1318,7 @@ static void bnx2x_port_stats_stop(struct bnx2x *bp)
 
 static void bnx2x_stats_stop(struct bnx2x *bp)
 {
-	int update = 0;
-
-	if (down_timeout(&bp->stats_sema, HZ/10))
-		BNX2X_ERR("Unable to acquire stats lock\n");
-
-	bp->stats_started = false;
+	bool update = false;
 
 	bnx2x_stats_comp(bp);
 
@@ -1381,8 +1336,6 @@ static void bnx2x_stats_stop(struct bnx2x *bp)
 		bnx2x_hw_stats_post(bp);
 		bnx2x_stats_comp(bp);
 	}
-
-	up(&bp->stats_sema);
 }
 
 static void bnx2x_stats_do_nothing(struct bnx2x *bp)
@@ -1410,18 +1363,28 @@ static const struct {
 
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 {
-	enum bnx2x_stats_state state;
-	void (*action)(struct bnx2x *bp);
+	enum bnx2x_stats_state state = bp->stats_state;
+
 	if (unlikely(bp->panic))
 		return;
 
-	spin_lock_bh(&bp->stats_lock);
-	state = bp->stats_state;
+	/* Statistics update run from timer context, and we don't want to stop
+	 * that context in case someone is in the middle of a transition.
+	 * For other events, wait a bit until lock is taken.
+	 */
+	if (!mutex_trylock(&bp->stats_lock)) {
+		if (event == STATS_EVENT_UPDATE)
+			return;
+
+		DP(BNX2X_MSG_STATS,
+		   "Unlikely stats' lock contention [event %d]\n", event);
+		mutex_lock(&bp->stats_lock);
+	}
+
+	bnx2x_stats_stm[state][event].action(bp);
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
-	action = bnx2x_stats_stm[state][event].action;
-	spin_unlock_bh(&bp->stats_lock);
 
-	action(bp);
+	mutex_unlock(&bp->stats_lock);
 
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
@@ -1998,13 +1961,34 @@ void bnx2x_afex_collect_stats(struct bnx2x *bp, void *void_afex_stats,
 	}
 }
 
-void bnx2x_stats_safe_exec(struct bnx2x *bp,
-			   void (func_to_exec)(void *cookie),
-			   void *cookie){
-	if (down_timeout(&bp->stats_sema, HZ/10))
-		BNX2X_ERR("Unable to acquire stats lock\n");
+int bnx2x_stats_safe_exec(struct bnx2x *bp,
+			  void (func_to_exec)(void *cookie),
+			  void *cookie)
+{
+	int cnt = 10, rc = 0;
+
+	/* Wait for statistics to end [while blocking further requests],
+	 * then run supplied function 'safely'.
+	 */
+	mutex_lock(&bp->stats_lock);
+
 	bnx2x_stats_comp(bp);
+	while (bp->stats_pending && cnt--)
+		if (bnx2x_storm_stats_update(bp))
+			usleep_range(1000, 2000);
+	if (bp->stats_pending) {
+		BNX2X_ERR("Failed to wait for stats pending to clear [possibly FW is stuck]\n");
+		rc = -EBUSY;
+		goto out;
+	}
+
 	func_to_exec(cookie);
-	__bnx2x_stats_start(bp);
-	up(&bp->stats_sema);
+
+out:
+	/* No need to restart statistics - if they're enabled, the timer
+	 * will restart the statistics.
+	 */
+	mutex_unlock(&bp->stats_lock);
+
+	return rc;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 2beceae..965539a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -539,9 +539,9 @@ struct bnx2x;
 void bnx2x_memset_stats(struct bnx2x *bp);
 void bnx2x_stats_init(struct bnx2x *bp);
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
-void bnx2x_stats_safe_exec(struct bnx2x *bp,
-			   void (func_to_exec)(void *cookie),
-			   void *cookie);
+int bnx2x_stats_safe_exec(struct bnx2x *bp,
+			  void (func_to_exec)(void *cookie),
+			  void *cookie);
 
 /**
  * bnx2x_save_statistics - save statistics when unloading.
-- 
1.9.3
