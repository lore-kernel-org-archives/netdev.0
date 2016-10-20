From: Binoy Jayan <binoy.jayan@linaro.org>
Subject: [PATCH] bnx2x: Replace semaphore stats_lock with mutex
Date: Thu, 20 Oct 2016 14:22:12 +0530
Message-ID: <1476953532-2019-1-git-send-email-binoy.jayan@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Binoy Jayan <binoy.jayan@linaro.org>
To: Ariel Elior <ariel.elior@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

stats_lock is used as a simple mutex, so replace it with a mutex.
Semaphores are going away in the future.

Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
---
They following is a patch which removes semaphores from bnx2x.
Its part of a bigger effort to eliminate all semaphores
from the linux kernel.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 17 +++++++----------
 3 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7dd7490..fd5e5b8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -25,6 +25,7 @@
 #include <linux/ptp_clock_kernel.h>
 #include <linux/net_tstamp.h>
 #include <linux/timecounter.h>
+#include <linux/mutex.h>
 
 /* compilation time flags */
 
@@ -1698,7 +1699,7 @@ struct bnx2x {
 	int			stats_state;
 
 	/* used for synchronization of concurrent threads statistics handling */
-	struct semaphore	stats_lock;
+	struct mutex		stats_lock;
 
 	/* used by dmae command loader */
 	struct dmae_command	stats_dmae;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 20fe6a8..b323d69 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12340,7 +12340,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	mutex_init(&bp->drv_info_mutex);
-	sema_init(&bp->stats_lock, 1);
+	mutex_init(&bp->stats_lock);
 	bp->drv_info_mng_owner = false;
 	INIT_LIST_HEAD(&bp->vlan_reg);
 
@@ -14205,9 +14205,9 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	cancel_delayed_work_sync(&bp->sp_task);
 	cancel_delayed_work_sync(&bp->period_task);
 
-	if (!down_timeout(&bp->stats_lock, HZ / 10)) {
+	if (mutex_trylock(&bp->stats_lock)) {
 		bp->stats_state = STATS_STATE_DISABLED;
-		up(&bp->stats_lock);
+		mutex_unlock(&bp->stats_lock);
 	}
 
 	bnx2x_save_statistics(bp);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 7e0919a..ee6ffd8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1374,23 +1374,20 @@ void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 	 * that context in case someone is in the middle of a transition.
 	 * For other events, wait a bit until lock is taken.
 	 */
-	if (down_trylock(&bp->stats_lock)) {
+	if (!mutex_trylock(&bp->stats_lock)) {
 		if (event == STATS_EVENT_UPDATE)
 			return;
 
 		DP(BNX2X_MSG_STATS,
 		   "Unlikely stats' lock contention [event %d]\n", event);
-		if (unlikely(down_timeout(&bp->stats_lock, HZ / 10))) {
-			BNX2X_ERR("Failed to take stats lock [event %d]\n",
-				  event);
-			return;
-		}
+		BNX2X_ERR("Failed to take stats lock [event %d]\n", event);
+		return;
 	}
 
 	bnx2x_stats_stm[state][event].action(bp);
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
 
-	up(&bp->stats_lock);
+	mutex_unlock(&bp->stats_lock);
 
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
@@ -1976,8 +1973,8 @@ int bnx2x_stats_safe_exec(struct bnx2x *bp,
 	/* Wait for statistics to end [while blocking further requests],
 	 * then run supplied function 'safely'.
 	 */
-	rc = down_timeout(&bp->stats_lock, HZ / 10);
-	if (unlikely(rc)) {
+	rc = mutex_trylock(&bp->stats_lock);
+	if (unlikely(!rc)) {
 		BNX2X_ERR("Failed to take statistics lock for safe execution\n");
 		goto out_no_lock;
 	}
@@ -1998,7 +1995,7 @@ int bnx2x_stats_safe_exec(struct bnx2x *bp,
 	/* No need to restart statistics - if they're enabled, the timer
 	 * will restart the statistics.
 	 */
-	up(&bp->stats_lock);
+	mutex_unlock(&bp->stats_lock);
 out_no_lock:
 	return rc;
 }
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
