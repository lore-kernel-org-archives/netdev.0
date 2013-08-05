From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v4 2/6] bnx2x: protect different statistics flows
Date: Tue, 6 Aug 2013 00:35:40 +0300
Message-ID: <1375738544-8695-3-git-send-email-dmitry@broadcom.com>
References: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2678 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126Ab3HEVf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:35:58 -0400
In-Reply-To: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add locking to protect different statistics flows from
running simultaneously.
This in order to serialize statistics requests sent to FW,
otherwise two outstanding queries may cause FW assert.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 88 +++++++++++++++++++----
 2 files changed, 79 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index d80e34b..c7ffff3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1830,6 +1830,9 @@ struct bnx2x {
 
 	int fp_array_size;
 	u32 dump_preset_idx;
+	bool					stats_started;
+	unsigned long				stats_flags;
+#define BNX2X_STATS_UPDATE_BIT			0
 };
 
 /* Tx queues may be less or equal to Rx queues */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index a22ad61..bf7f9a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -221,7 +221,8 @@ static int bnx2x_stats_comp(struct bnx2x *bp)
  * Statistics service functions
  */
 
-static void bnx2x_stats_pmf_update(struct bnx2x *bp)
+/* should be called under bnx2x_lock_stat_transition */
+static void __bnx2x_stats_pmf_update(struct bnx2x *bp)
 {
 	struct dmae_command *dmae;
 	u32 opcode;
@@ -518,7 +519,8 @@ static void bnx2x_func_stats_init(struct bnx2x *bp)
 	*stats_comp = 0;
 }
 
-static void bnx2x_stats_start(struct bnx2x *bp)
+/* should be called under bnx2x_lock_stat_transition */
+static void __bnx2x_stats_start(struct bnx2x *bp)
 {
 	/* vfs travel through here as part of the statistics FSM, but no action
 	 * is required
@@ -534,13 +536,58 @@ static void bnx2x_stats_start(struct bnx2x *bp)
 
 	bnx2x_hw_stats_post(bp);
 	bnx2x_storm_stats_post(bp);
+
+	bp->stats_started = true;
+}
+
+static bool bnx2x_trylock_stat_transition(struct bnx2x *bp)
+{
+	return !test_and_set_bit(BNX2X_STATS_UPDATE_BIT, &bp->stats_flags);
+}
+
+static void bnx2x_lock_stat_transition(struct bnx2x *bp)
+{
+	int cnt = 10; /* 10-20mSec */
+
+	while (test_and_set_bit(BNX2X_STATS_UPDATE_BIT, &bp->stats_flags)) {
+		if (!cnt) {
+			BNX2X_ERR("timeout waiting for stats lock\n");
+			bnx2x_panic();
+			break;
+		}
+		cnt--;
+		usleep_range(1000, 2000);
+	}
+}
+
+static void bnx2x_unlock_stat_transition(struct bnx2x *bp)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(BNX2X_STATS_UPDATE_BIT, &bp->stats_flags);
+	smp_mb__after_clear_bit();
+}
+
+static void bnx2x_stats_start(struct bnx2x *bp)
+{
+	bnx2x_lock_stat_transition(bp);
+	__bnx2x_stats_start(bp);
+	bnx2x_unlock_stat_transition(bp);
 }
 
 static void bnx2x_stats_pmf_start(struct bnx2x *bp)
 {
+	bnx2x_lock_stat_transition(bp);
 	bnx2x_stats_comp(bp);
-	bnx2x_stats_pmf_update(bp);
-	bnx2x_stats_start(bp);
+	__bnx2x_stats_pmf_update(bp);
+	__bnx2x_stats_start(bp);
+	bnx2x_unlock_stat_transition(bp);
+}
+
+static void bnx2x_stats_pmf_update(struct bnx2x *bp)
+{
+	bnx2x_lock_stat_transition(bp);
+	__bnx2x_stats_pmf_update(bp);
+	bnx2x_unlock_stat_transition(bp);
 }
 
 static void bnx2x_stats_restart(struct bnx2x *bp)
@@ -550,8 +597,10 @@ static void bnx2x_stats_restart(struct bnx2x *bp)
 	 */
 	if (IS_VF(bp))
 		return;
+	bnx2x_lock_stat_transition(bp);
 	bnx2x_stats_comp(bp);
-	bnx2x_stats_start(bp);
+	__bnx2x_stats_start(bp);
+	bnx2x_unlock_stat_transition(bp);
 }
 
 static void bnx2x_bmac_stats_update(struct bnx2x *bp)
@@ -888,9 +937,7 @@ static int bnx2x_storm_stats_validate_counters(struct bnx2x *bp)
 	/* Make sure we use the value of the counter
 	 * used for sending the last stats ramrod.
 	 */
-	spin_lock_bh(&bp->stats_lock);
 	cur_stats_counter = bp->stats_counter - 1;
-	spin_unlock_bh(&bp->stats_lock);
 
 	/* are storm stats valid? */
 	if (le16_to_cpu(counters->xstats_counter) != cur_stats_counter) {
@@ -1227,12 +1274,18 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 {
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
 
-	if (bnx2x_edebug_stats_stopped(bp))
+	/* we run update from timer context, so give up
+	 * if somebody in the middle of transition
+	 */
+	if (!bnx2x_trylock_stat_transition(bp))
 		return;
 
+	if (bnx2x_edebug_stats_stopped(bp) || !bp->stats_started)
+		goto out;
+
 	if (IS_PF(bp)) {
 		if (*stats_comp != DMAE_COMP_VAL)
-			return;
+			goto out;
 
 		if (bp->port.pmf)
 			bnx2x_hw_stats_update(bp);
@@ -1242,7 +1295,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 				BNX2X_ERR("storm stats were not updated for 3 times\n");
 				bnx2x_panic();
 			}
-			return;
+			goto out;
 		}
 	} else {
 		/* vf doesn't collect HW statistics, and doesn't get completions
@@ -1256,7 +1309,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 
 	/* vf is done */
 	if (IS_VF(bp))
-		return;
+		goto out;
 
 	if (netif_msg_timer(bp)) {
 		struct bnx2x_eth_stats *estats = &bp->eth_stats;
@@ -1267,6 +1320,9 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 
 	bnx2x_hw_stats_post(bp);
 	bnx2x_storm_stats_post(bp);
+
+out:
+	bnx2x_unlock_stat_transition(bp);
 }
 
 static void bnx2x_port_stats_stop(struct bnx2x *bp)
@@ -1332,6 +1388,10 @@ static void bnx2x_stats_stop(struct bnx2x *bp)
 {
 	int update = 0;
 
+	bnx2x_lock_stat_transition(bp);
+
+	bp->stats_started = false;
+
 	bnx2x_stats_comp(bp);
 
 	if (bp->port.pmf)
@@ -1348,6 +1408,8 @@ static void bnx2x_stats_stop(struct bnx2x *bp)
 		bnx2x_hw_stats_post(bp);
 		bnx2x_stats_comp(bp);
 	}
+
+	bnx2x_unlock_stat_transition(bp);
 }
 
 static void bnx2x_stats_do_nothing(struct bnx2x *bp)
@@ -1376,15 +1438,17 @@ static const struct {
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 {
 	enum bnx2x_stats_state state;
+	void (*action)(struct bnx2x *bp);
 	if (unlikely(bp->panic))
 		return;
 
 	spin_lock_bh(&bp->stats_lock);
 	state = bp->stats_state;
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
+	action = bnx2x_stats_stm[state][event].action;
 	spin_unlock_bh(&bp->stats_lock);
 
-	bnx2x_stats_stm[state][event].action(bp);
+	action(bp);
 
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
-- 
1.8.1.4
