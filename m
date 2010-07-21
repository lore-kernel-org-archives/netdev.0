From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 1/3 net-2.6] bnx2x: Protect a SM state change
Date: Wed, 21 Jul 2010 18:59:01 +0300
Message-ID: <1279727941.14094.42.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4745 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755572Ab0GUP7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 11:59:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix: Protect the statistics state machine state update with a spinlock.
Otherwise there was a race condition that would cause the statistics stay
enabled despite they were disabled in the LINK_DOWN event handler.

 Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
 Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
 Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    4 ++++
 drivers/net/bnx2x_main.c |   11 +++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 8bd2368..bb0872a 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1062,6 +1062,10 @@ struct bnx2x {
 
 	/* used to synchronize stats collecting */
 	int			stats_state;
+
+	/* used for synchronization of concurrent threads statistics handling */
+	spinlock_t		stats_lock;
+
 	/* used by dmae command loader */
 	struct dmae_command	stats_dmae;
 	int			executer_idx;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 57ff5b3..3dc876c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4849,16 +4849,18 @@ static const struct {
 
 static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 {
-	enum bnx2x_stats_state state = bp->stats_state;
+	enum bnx2x_stats_state state;
 
 	if (unlikely(bp->panic))
 		return;
 
-	bnx2x_stats_stm[state][event].action(bp);
+	/* Protect a state change flow */
+	spin_lock_bh(&bp->stats_lock);
+	state = bp->stats_state;
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
+	spin_unlock_bh(&bp->stats_lock);
 
-	/* Make sure the state has been "changed" */
-	smp_wmb();
+	bnx2x_stats_stm[state][event].action(bp);
 
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
@@ -9908,6 +9910,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
+	spin_lock_init(&bp->stats_lock);
 #ifdef BCM_CNIC
 	mutex_init(&bp->cnic_mutex);
 #endif
-- 
1.7.1




