From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/8] tg3: Eliminate timer race with reset_task
Date: Fri, 4 Nov 2011 12:15:04 -0700
Message-ID: <1320434105-12898-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3457 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755859Ab1KDTN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:13:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During shutdown, it is impossible to reliably disable the timer and
reset_task threads.  Each thread can schedule the other, which leads to
shutdown code that chases its tail.

To fix the problem, this patch removes the ability of tg3_reset_task to
schedule a new timer thread.  To support this change, tg3_timer no
longer terminates itself, but rather goes into a polling mode.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   14 ++------------
 drivers/net/ethernet/broadcom/tg3.h |    1 -
 2 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d4a85b7..cc7349f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6352,7 +6352,6 @@ static void tg3_reset_task(struct work_struct *work)
 {
 	struct tg3 *tp = container_of(work, struct tg3, reset_task);
 	int err;
-	unsigned int restart_timer;
 
 	tg3_full_lock(tp, 0);
 
@@ -6370,9 +6369,6 @@ static void tg3_reset_task(struct work_struct *work)
 
 	tg3_full_lock(tp, 1);
 
-	restart_timer = tg3_flag(tp, RESTART_TIMER);
-	tg3_flag_clear(tp, RESTART_TIMER);
-
 	if (tg3_flag(tp, TX_RECOVERY_PENDING)) {
 		tp->write32_tx_mbox = tg3_write32_tx_mbox;
 		tp->write32_rx_mbox = tg3_write_flush_reg32;
@@ -6387,9 +6383,6 @@ static void tg3_reset_task(struct work_struct *work)
 
 	tg3_netif_start(tp);
 
-	if (restart_timer)
-		mod_timer(&tp->timer, jiffies + 1);
-
 out:
 	tg3_full_unlock(tp);
 
@@ -9218,7 +9211,7 @@ static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
 
-	if (tp->irq_sync)
+	if (tp->irq_sync || tg3_flag(tp, RESET_TASK_PENDING))
 		goto restart_timer;
 
 	spin_lock(&tp->lock);
@@ -9241,10 +9234,9 @@ static void tg3_timer(unsigned long __opaque)
 		}
 
 		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
-			tg3_flag_set(tp, RESTART_TIMER);
 			spin_unlock(&tp->lock);
 			tg3_reset_task_schedule(tp);
-			return;
+			goto restart_timer;
 		}
 	}
 
@@ -15847,12 +15839,10 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 	tg3_netif_stop(tp);
 
 	del_timer_sync(&tp->timer);
-	tg3_flag_clear(tp, RESTART_TIMER);
 
 	/* Want to make sure that the reset task doesn't run */
 	tg3_reset_task_cancel(tp);
 	tg3_flag_clear(tp, TX_RECOVERY_PENDING);
-	tg3_flag_clear(tp, RESTART_TIMER);
 
 	netif_device_detach(netdev);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 610fd84..94b4bd0 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2879,7 +2879,6 @@ enum TG3_FLAGS {
 	TG3_FLAG_JUMBO_CAPABLE,
 	TG3_FLAG_CHIP_RESETTING,
 	TG3_FLAG_INIT_COMPLETE,
-	TG3_FLAG_RESTART_TIMER,
 	TG3_FLAG_TSO_BUG,
 	TG3_FLAG_IS_5788,
 	TG3_FLAG_MAX_RXPEND_64,
-- 
1.7.3.4
