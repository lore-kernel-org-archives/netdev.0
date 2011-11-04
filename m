From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/8] tg3: Schedule at most one tg3_reset_task run
Date: Fri, 4 Nov 2011 12:15:03 -0700
Message-ID: <1320434105-12898-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3465 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755873Ab1KDTN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:13:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for multiple threads in the tg3 driver to each attempt to
schedule a run of tg3_reset_task().  The multiple tg3_reset_task
executions could all wind up on the same queue (and execute serially) or
wind up on the queues of another processor (which could execute in
parallel).  Either scenario is not what was truly desired.

This patch adds a new flag, TG3_FLAG_RESET_TASK_PENDING, and uses it to
determine whether or not to schedule another run of tg3_reset_task().
With the new flag comes two new functions to facilitate scheduling and
descheduling of tg3_reset_task().

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   33 ++++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6973d01..d4a85b7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5929,6 +5929,18 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	return work_done;
 }
 
+static inline void tg3_reset_task_schedule(struct tg3 *tp)
+{
+	if (!test_and_set_bit(TG3_FLAG_RESET_TASK_PENDING, tp->tg3_flags))
+		schedule_work(&tp->reset_task);
+}
+
+static inline void tg3_reset_task_cancel(struct tg3 *tp)
+{
+	cancel_work_sync(&tp->reset_task);
+	tg3_flag_clear(tp, RESET_TASK_PENDING);
+}
+
 static int tg3_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
@@ -5969,7 +5981,7 @@ static int tg3_poll_msix(struct napi_struct *napi, int budget)
 tx_recovery:
 	/* work_done is guaranteed to be less than budget. */
 	napi_complete(napi);
-	schedule_work(&tp->reset_task);
+	tg3_reset_task_schedule(tp);
 	return work_done;
 }
 
@@ -6004,7 +6016,7 @@ static void tg3_process_error(struct tg3 *tp)
 	tg3_dump_state(tp);
 
 	tg3_flag_set(tp, ERROR_PROCESSED);
-	schedule_work(&tp->reset_task);
+	tg3_reset_task_schedule(tp);
 }
 
 static int tg3_poll(struct napi_struct *napi, int budget)
@@ -6051,7 +6063,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 tx_recovery:
 	/* work_done is guaranteed to be less than budget. */
 	napi_complete(napi);
-	schedule_work(&tp->reset_task);
+	tg3_reset_task_schedule(tp);
 	return work_done;
 }
 
@@ -6345,6 +6357,7 @@ static void tg3_reset_task(struct work_struct *work)
 	tg3_full_lock(tp, 0);
 
 	if (!netif_running(tp->dev)) {
+		tg3_flag_clear(tp, RESET_TASK_PENDING);
 		tg3_full_unlock(tp);
 		return;
 	}
@@ -6382,6 +6395,8 @@ out:
 
 	if (!err)
 		tg3_phy_start(tp);
+
+	tg3_flag_clear(tp, RESET_TASK_PENDING);
 }
 
 static void tg3_tx_timeout(struct net_device *dev)
@@ -6393,7 +6408,7 @@ static void tg3_tx_timeout(struct net_device *dev)
 		tg3_dump_state(tp);
 	}
 
-	schedule_work(&tp->reset_task);
+	tg3_reset_task_schedule(tp);
 }
 
 /* Test for DMA buffers crossing any 4GB boundaries: 4G, 8G, etc */
@@ -9228,7 +9243,7 @@ static void tg3_timer(unsigned long __opaque)
 		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
 			tg3_flag_set(tp, RESTART_TIMER);
 			spin_unlock(&tp->lock);
-			schedule_work(&tp->reset_task);
+			tg3_reset_task_schedule(tp);
 			return;
 		}
 	}
@@ -9785,7 +9800,7 @@ static int tg3_close(struct net_device *dev)
 	struct tg3 *tp = netdev_priv(dev);
 
 	tg3_napi_disable(tp);
-	cancel_work_sync(&tp->reset_task);
+	tg3_reset_task_cancel(tp);
 
 	netif_tx_stop_all_queues(dev);
 
@@ -15685,7 +15700,7 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 		if (tp->fw)
 			release_firmware(tp->fw);
 
-		cancel_work_sync(&tp->reset_task);
+		tg3_reset_task_cancel(tp);
 
 		if (tg3_flag(tp, USE_PHYLIB)) {
 			tg3_phy_fini(tp);
@@ -15719,7 +15734,7 @@ static int tg3_suspend(struct device *device)
 	if (!netif_running(dev))
 		return 0;
 
-	flush_work_sync(&tp->reset_task);
+	tg3_reset_task_cancel(tp);
 	tg3_phy_stop(tp);
 	tg3_netif_stop(tp);
 
@@ -15835,7 +15850,7 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 	tg3_flag_clear(tp, RESTART_TIMER);
 
 	/* Want to make sure that the reset task doesn't run */
-	cancel_work_sync(&tp->reset_task);
+	tg3_reset_task_cancel(tp);
 	tg3_flag_clear(tp, TX_RECOVERY_PENDING);
 	tg3_flag_clear(tp, RESTART_TIMER);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index acfa265..610fd84 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2922,6 +2922,7 @@ enum TG3_FLAGS {
 	TG3_FLAG_APE_HAS_NCSI,
 	TG3_FLAG_5717_PLUS,
 	TG3_FLAG_4K_FIFO_LIMIT,
+	TG3_FLAG_RESET_TASK_PENDING,
 
 	/* Add new flags before this comment and TG3_FLAG_NUMBER_OF_FLAGS */
 	TG3_FLAG_NUMBER_OF_FLAGS,	/* Last entry in enum TG3_FLAGS */
-- 
1.7.3.4
