From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Move statistics implementation into semaphores
Date: Mon, 1 Jun 2015 15:08:18 +0300
Message-ID: <1433160498-22539-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nikola.ciprich@linuxbox.cz>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:17339 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752585AbbFAMJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 08:09:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit dff173de84958 ("bnx2x: Fix statistics locking scheme") changed the
bnx2x locking around statistics state into using a mutex - but the lock
is being accessed via a timer which is forbidden.

[If compiled with CONFIG_DEBUG_MUTEXES, logs show a warning about
accessing the mutex in interrupt context]

This moves the implementation into using a semaphore [with size '1']
instead.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  9 +++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 20 ++++++++++++++------
 3 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a3b0f7a..1f82a04 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1774,7 +1774,7 @@ struct bnx2x {
 	int			stats_state;
 
 	/* used for synchronization of concurrent threads statistics handling */
-	struct mutex		stats_lock;
+	struct semaphore	stats_lock;
 
 	/* used by dmae command loader */
 	struct dmae_command	stats_dmae;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fd52ce9..33501bc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12054,7 +12054,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	mutex_init(&bp->drv_info_mutex);
-	mutex_init(&bp->stats_lock);
+	sema_init(&bp->stats_lock, 1);
 	bp->drv_info_mng_owner = false;
 
 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
@@ -13690,9 +13690,10 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	cancel_delayed_work_sync(&bp->sp_task);
 	cancel_delayed_work_sync(&bp->period_task);
 
-	mutex_lock(&bp->stats_lock);
-	bp->stats_state = STATS_STATE_DISABLED;
-	mutex_unlock(&bp->stats_lock);
+	if (!down_timeout(&bp->stats_lock, HZ / 10)) {
+		bp->stats_state = STATS_STATE_DISABLED;
+		up(&bp->stats_lock);
+	}
 
 	bnx2x_save_statistics(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 266b055..69d699f0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1372,19 +1372,23 @@ void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 	 * that context in case someone is in the middle of a transition.
 	 * For other events, wait a bit until lock is taken.
 	 */
-	if (!mutex_trylock(&bp->stats_lock)) {
+	if (down_trylock(&bp->stats_lock)) {
 		if (event == STATS_EVENT_UPDATE)
 			return;
 
 		DP(BNX2X_MSG_STATS,
 		   "Unlikely stats' lock contention [event %d]\n", event);
-		mutex_lock(&bp->stats_lock);
+		if (unlikely(down_timeout(&bp->stats_lock, HZ / 10))) {
+			BNX2X_ERR("Failed to take stats lock [event %d]\n",
+				  event);
+			return;
+		}
 	}
 
 	bnx2x_stats_stm[state][event].action(bp);
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
 
-	mutex_unlock(&bp->stats_lock);
+	up(&bp->stats_lock);
 
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
@@ -1970,7 +1974,11 @@ int bnx2x_stats_safe_exec(struct bnx2x *bp,
 	/* Wait for statistics to end [while blocking further requests],
 	 * then run supplied function 'safely'.
 	 */
-	mutex_lock(&bp->stats_lock);
+	rc = down_timeout(&bp->stats_lock, HZ / 10);
+	if (unlikely(rc)) {
+		BNX2X_ERR("Failed to take statistics lock for safe execution\n");
+		goto out_no_lock;
+	}
 
 	bnx2x_stats_comp(bp);
 	while (bp->stats_pending && cnt--)
@@ -1988,7 +1996,7 @@ out:
 	/* No need to restart statistics - if they're enabled, the timer
 	 * will restart the statistics.
 	 */
-	mutex_unlock(&bp->stats_lock);
-
+	up(&bp->stats_lock);
+out_no_lock:
 	return rc;
 }
-- 
1.8.3.1
