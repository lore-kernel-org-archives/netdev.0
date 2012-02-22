From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/4] tg3: Create timer helper functions
Date: Wed, 22 Feb 2012 14:35:21 -0800
Message-ID: <1329950121-18577-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3337 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab2BVWgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 17:36:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch seeks to clean up the timer related code.  It begins by
moving one-time timer setup code from tg3_open() to tg3_init_one().
It then creates a function that encapsulates the code needed to start
the timer.  A tg3_timer_stop() function was added for parity.  Finally,
this patch moves all the timer functions to a more suitable location.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  208 +++++++++++++++++++----------------
 1 files changed, 112 insertions(+), 96 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 1f82514..52dd457 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -204,6 +204,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 #define TG3_RAW_IP_ALIGN 2
 
 #define TG3_FW_UPDATE_TIMEOUT_SEC	5
+#define TG3_FW_UPDATE_FREQ_SEC		(TG3_FW_UPDATE_TIMEOUT_SEC / 2)
 
 #define FIRMWARE_TG3		"tigon/tg3.bin"
 #define FIRMWARE_TG3TSO		"tigon/tg3_tso.bin"
@@ -9328,74 +9329,6 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
-/* Restart hardware after configuration changes, self-test, etc.
- * Invoked with tp->lock held.
- */
-static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
-	__releases(tp->lock)
-	__acquires(tp->lock)
-{
-	int err;
-
-	err = tg3_init_hw(tp, reset_phy);
-	if (err) {
-		netdev_err(tp->dev,
-			   "Failed to re-initialize device, aborting\n");
-		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_full_unlock(tp);
-		del_timer_sync(&tp->timer);
-		tp->irq_sync = 0;
-		tg3_napi_enable(tp);
-		dev_close(tp->dev);
-		tg3_full_lock(tp, 0);
-	}
-	return err;
-}
-
-static void tg3_reset_task(struct work_struct *work)
-{
-	struct tg3 *tp = container_of(work, struct tg3, reset_task);
-	int err;
-
-	tg3_full_lock(tp, 0);
-
-	if (!netif_running(tp->dev)) {
-		tg3_flag_clear(tp, RESET_TASK_PENDING);
-		tg3_full_unlock(tp);
-		return;
-	}
-
-	tg3_full_unlock(tp);
-
-	tg3_phy_stop(tp);
-
-	tg3_netif_stop(tp);
-
-	tg3_full_lock(tp, 1);
-
-	if (tg3_flag(tp, TX_RECOVERY_PENDING)) {
-		tp->write32_tx_mbox = tg3_write32_tx_mbox;
-		tp->write32_rx_mbox = tg3_write_flush_reg32;
-		tg3_flag_set(tp, MBOX_WRITE_REORDER);
-		tg3_flag_clear(tp, TX_RECOVERY_PENDING);
-	}
-
-	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
-	err = tg3_init_hw(tp, 1);
-	if (err)
-		goto out;
-
-	tg3_netif_start(tp);
-
-out:
-	tg3_full_unlock(tp);
-
-	if (!err)
-		tg3_phy_start(tp);
-
-	tg3_flag_clear(tp, RESET_TASK_PENDING);
-}
-
 #define TG3_STAT_ADD32(PSTAT, REG) \
 do {	u32 __val = tr32(REG); \
 	(PSTAT)->low += __val; \
@@ -9608,6 +9541,108 @@ restart_timer:
 	add_timer(&tp->timer);
 }
 
+static void __devinit tg3_timer_init(struct tg3 *tp)
+{
+	if (tg3_flag(tp, TAGGED_STATUS) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
+	    !tg3_flag(tp, 57765_CLASS))
+		tp->timer_offset = HZ;
+	else
+		tp->timer_offset = HZ / 10;
+
+	BUG_ON(tp->timer_offset > HZ);
+
+	tp->timer_multiplier = (HZ / tp->timer_offset);
+	tp->asf_multiplier = (HZ / tp->timer_offset) *
+			     TG3_FW_UPDATE_FREQ_SEC;
+
+	init_timer(&tp->timer);
+	tp->timer.data = (unsigned long) tp;
+	tp->timer.function = tg3_timer;
+}
+
+static void tg3_timer_start(struct tg3 *tp)
+{
+	tp->asf_counter   = tp->asf_multiplier;
+	tp->timer_counter = tp->timer_multiplier;
+
+	tp->timer.expires = jiffies + tp->timer_offset;
+	add_timer(&tp->timer);
+}
+
+static void tg3_timer_stop(struct tg3 *tp)
+{
+	del_timer_sync(&tp->timer);
+}
+
+/* Restart hardware after configuration changes, self-test, etc.
+ * Invoked with tp->lock held.
+ */
+static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
+	__releases(tp->lock)
+	__acquires(tp->lock)
+{
+	int err;
+
+	err = tg3_init_hw(tp, reset_phy);
+	if (err) {
+		netdev_err(tp->dev,
+			   "Failed to re-initialize device, aborting\n");
+		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+		tg3_full_unlock(tp);
+		tg3_timer_stop(tp);
+		tp->irq_sync = 0;
+		tg3_napi_enable(tp);
+		dev_close(tp->dev);
+		tg3_full_lock(tp, 0);
+	}
+	return err;
+}
+
+static void tg3_reset_task(struct work_struct *work)
+{
+	struct tg3 *tp = container_of(work, struct tg3, reset_task);
+	int err;
+
+	tg3_full_lock(tp, 0);
+
+	if (!netif_running(tp->dev)) {
+		tg3_flag_clear(tp, RESET_TASK_PENDING);
+		tg3_full_unlock(tp);
+		return;
+	}
+
+	tg3_full_unlock(tp);
+
+	tg3_phy_stop(tp);
+
+	tg3_netif_stop(tp);
+
+	tg3_full_lock(tp, 1);
+
+	if (tg3_flag(tp, TX_RECOVERY_PENDING)) {
+		tp->write32_tx_mbox = tg3_write32_tx_mbox;
+		tp->write32_rx_mbox = tg3_write_flush_reg32;
+		tg3_flag_set(tp, MBOX_WRITE_REORDER);
+		tg3_flag_clear(tp, TX_RECOVERY_PENDING);
+	}
+
+	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
+	err = tg3_init_hw(tp, 1);
+	if (err)
+		goto out;
+
+	tg3_netif_start(tp);
+
+out:
+	tg3_full_unlock(tp);
+
+	if (!err)
+		tg3_phy_start(tp);
+
+	tg3_flag_clear(tp, RESET_TASK_PENDING);
+}
+
 static int tg3_request_irq(struct tg3 *tp, int irq_num)
 {
 	irq_handler_t fn;
@@ -9973,24 +10008,6 @@ static int tg3_open(struct net_device *dev)
 	if (err) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		tg3_free_rings(tp);
-	} else {
-		if (tg3_flag(tp, TAGGED_STATUS) &&
-		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-		    !tg3_flag(tp, 57765_CLASS))
-			tp->timer_offset = HZ;
-		else
-			tp->timer_offset = HZ / 10;
-
-		BUG_ON(tp->timer_offset > HZ);
-		tp->timer_counter = tp->timer_multiplier =
-			(HZ / tp->timer_offset);
-		tp->asf_counter = tp->asf_multiplier =
-			((HZ / tp->timer_offset) * 2);
-
-		init_timer(&tp->timer);
-		tp->timer.expires = jiffies + tp->timer_offset;
-		tp->timer.data = (unsigned long) tp;
-		tp->timer.function = tg3_timer;
 	}
 
 	tg3_full_unlock(tp);
@@ -10022,7 +10039,7 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_lock(tp, 0);
 
-	add_timer(&tp->timer);
+	tg3_timer_start(tp);
 	tg3_flag_set(tp, INIT_COMPLETE);
 	tg3_enable_ints(tp);
 
@@ -10067,7 +10084,7 @@ static int tg3_close(struct net_device *dev)
 
 	netif_tx_stop_all_queues(dev);
 
-	del_timer_sync(&tp->timer);
+	tg3_timer_stop(tp);
 
 	tg3_phy_stop(tp);
 
@@ -15701,6 +15718,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tg3_frob_aux_power(tp, false);
 	}
 
+	tg3_timer_init(tp);
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
@@ -15826,7 +15845,7 @@ static int tg3_suspend(struct device *device)
 	tg3_phy_stop(tp);
 	tg3_netif_stop(tp);
 
-	del_timer_sync(&tp->timer);
+	tg3_timer_stop(tp);
 
 	tg3_full_lock(tp, 1);
 	tg3_disable_ints(tp);
@@ -15850,8 +15869,7 @@ static int tg3_suspend(struct device *device)
 		if (err2)
 			goto out;
 
-		tp->timer.expires = jiffies + tp->timer_offset;
-		add_timer(&tp->timer);
+		tg3_timer_start(tp);
 
 		netif_device_attach(dev);
 		tg3_netif_start(tp);
@@ -15885,8 +15903,7 @@ static int tg3_resume(struct device *device)
 	if (err)
 		goto out;
 
-	tp->timer.expires = jiffies + tp->timer_offset;
-	add_timer(&tp->timer);
+	tg3_timer_start(tp);
 
 	tg3_netif_start(tp);
 
@@ -15934,7 +15951,7 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 	tg3_netif_stop(tp);
 
-	del_timer_sync(&tp->timer);
+	tg3_timer_stop(tp);
 
 	/* Want to make sure that the reset task doesn't run */
 	tg3_reset_task_cancel(tp);
@@ -16030,8 +16047,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	tp->timer.expires = jiffies + tp->timer_offset;
-	add_timer(&tp->timer);
+	tg3_timer_start(tp);
 
 	tg3_netif_start(tp);
 
-- 
1.7.3.4
