From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/8] tg3: Move tg3_restart_hw to a better location
Date: Mon, 13 Feb 2012 12:20:05 -0800
Message-ID: <1329164412-24566-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4235 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757923Ab2BMUUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch relocates tg3_restart_hw() to a better location.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   56 ++++++++++++++++++-----------------
 1 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3bf3adc..a352c44 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6292,33 +6292,6 @@ static irqreturn_t tg3_test_isr(int irq, void *dev_id)
 	return IRQ_RETVAL(0);
 }
 
-static int tg3_init_hw(struct tg3 *, int);
-static int tg3_halt(struct tg3 *, int, int);
-
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
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void tg3_poll_controller(struct net_device *dev)
 {
@@ -6330,6 +6303,9 @@ static void tg3_poll_controller(struct net_device *dev)
 }
 #endif
 
+static int tg3_init_hw(struct tg3 *, int);
+static int tg3_halt(struct tg3 *, int, int);
+
 static void tg3_reset_task(struct work_struct *work)
 {
 	struct tg3 *tp = container_of(work, struct tg3, reset_task);
@@ -7014,6 +6990,8 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 	}
 }
 
+static int tg3_restart_hw(struct tg3 *tp, int reset_phy);
+
 static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -9135,6 +9113,30 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
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
+		del_timer_sync(&tp->timer);
+		tp->irq_sync = 0;
+		tg3_napi_enable(tp);
+		dev_close(tp->dev);
+		tg3_full_lock(tp, 0);
+	}
+	return err;
+}
+
 #define TG3_STAT_ADD32(PSTAT, REG) \
 do {	u32 __val = tr32(REG); \
 	(PSTAT)->low += __val; \
-- 
1.7.3.4
