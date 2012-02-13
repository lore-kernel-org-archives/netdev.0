From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/8] tg3: Relocate tg3_reset_task
Date: Mon, 13 Feb 2012 12:20:06 -0800
Message-ID: <1329164412-24566-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3675 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757970Ab2BMUVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:21:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves tg3_reset_task further down in the file where it makes
more sense to be.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   92 +++++++++++++++++------------------
 1 files changed, 45 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a352c44..3ab1af6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6303,53 +6303,6 @@ static void tg3_poll_controller(struct net_device *dev)
 }
 #endif
 
-static int tg3_init_hw(struct tg3 *, int);
-static int tg3_halt(struct tg3 *, int, int);
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
 static void tg3_tx_timeout(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -6991,6 +6944,7 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 }
 
 static int tg3_restart_hw(struct tg3 *tp, int reset_phy);
+static int tg3_halt(struct tg3 *, int, int);
 
 static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -9137,6 +9091,50 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 	return err;
 }
 
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
 #define TG3_STAT_ADD32(PSTAT, REG) \
 do {	u32 __val = tr32(REG); \
 	(PSTAT)->low += __val; \
-- 
1.7.3.4
