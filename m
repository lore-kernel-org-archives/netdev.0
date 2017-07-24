From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/10] bnxt_en: Allow the user to set ethtool stats-block-usecs to 0.
Date: Mon, 24 Jul 2017 12:34:24 -0400
Message-ID: <1500914069-15724-6-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:38289 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753875AbdGXQeu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:50 -0400
Received: by mail-qk0-f175.google.com with SMTP id g6so58269331qkf.5
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:49 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For debugging purpose, it is sometimes useful to disable periodic
port statistics updates, so that the firmware logs will not be
filled with statistics update messages.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 8 +++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4acaeaf..5df9670 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6843,7 +6843,8 @@ static void bnxt_timer(unsigned long data)
 	if (atomic_read(&bp->intr_sem) != 0)
 		goto bnxt_restart_timer;
 
-	if (bp->link_info.link_up && (bp->flags & BNXT_FLAG_PORT_STATS)) {
+	if (bp->link_info.link_up && (bp->flags & BNXT_FLAG_PORT_STATS) &&
+	    bp->stats_coal_ticks) {
 		set_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event);
 		schedule_work(&bp->sp_task);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 4661b11..140e769 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -86,9 +86,11 @@ static int bnxt_set_coalesce(struct net_device *dev,
 	if (bp->stats_coal_ticks != coal->stats_block_coalesce_usecs) {
 		u32 stats_ticks = coal->stats_block_coalesce_usecs;
 
-		stats_ticks = clamp_t(u32, stats_ticks,
-				      BNXT_MIN_STATS_COAL_TICKS,
-				      BNXT_MAX_STATS_COAL_TICKS);
+		/* Allow 0, which means disable. */
+		if (stats_ticks)
+			stats_ticks = clamp_t(u32, stats_ticks,
+					      BNXT_MIN_STATS_COAL_TICKS,
+					      BNXT_MAX_STATS_COAL_TICKS);
 		stats_ticks = rounddown(stats_ticks, BNXT_MIN_STATS_COAL_TICKS);
 		bp->stats_coal_ticks = stats_ticks;
 		update_stats = true;
-- 
1.8.3.1
