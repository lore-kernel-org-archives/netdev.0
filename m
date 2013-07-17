From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v3 2/6] bnx2x: prevent statistics update flow to act
 before statistics are started
Date: Thu, 18 Jul 2013 01:00:36 +0300
Message-ID: <1374098440-27877-3-git-send-email-dmitry@broadcom.com>
References: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4692 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433Ab3GQWBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 18:01:11 -0400
In-Reply-To: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This in order to serialize statistics requests sent to FW,
otherwise two outstanding queries may cause FW assert.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       | 1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 6 +++++-
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index dedbd76..bdbd87e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1830,6 +1830,7 @@ struct bnx2x {
 
 	int fp_array_size;
 	u32 dump_preset_idx;
+	atomic_t				stats_started;
 };
 
 /* Tx queues may be less or equal to Rx queues */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e5da078..7e9681f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11524,6 +11524,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	spin_lock_init(&bp->stats_lock);
+	atomic_set(&bp->stats_started, 0);
 
 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
 	INIT_DELAYED_WORK(&bp->sp_rtnl_task, bnx2x_sp_rtnl_task);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 7b39424..b117afe 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -534,6 +534,8 @@ static void bnx2x_stats_start(struct bnx2x *bp)
 
 	bnx2x_hw_stats_post(bp);
 	bnx2x_storm_stats_post(bp);
+
+	atomic_set(&bp->stats_started, 1);
 }
 
 static void bnx2x_stats_pmf_start(struct bnx2x *bp)
@@ -1227,7 +1229,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 {
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
 
-	if (bnx2x_edebug_stats_stopped(bp))
+	if (bnx2x_edebug_stats_stopped(bp) || !atomic_read(&bp->stats_started))
 		return;
 
 	if (IS_PF(bp)) {
@@ -1332,6 +1334,8 @@ static void bnx2x_stats_stop(struct bnx2x *bp)
 {
 	int update = 0;
 
+	atomic_set(&bp->stats_started, 0);
+
 	bnx2x_stats_comp(bp);
 
 	if (bp->port.pmf)
-- 
1.8.1.4
