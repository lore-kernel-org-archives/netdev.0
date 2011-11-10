From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 11/13] bnx2x: prevent race in statistics flow
Date: Thu, 10 Nov 2011 17:14:12 +0200
Message-ID: <1320938054-31288-12-git-send-email-dmitry@broadcom.com>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3995 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933924Ab1KJPOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 10:14:45 -0500
In-Reply-To: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The race may cause access of registers while MAC hw block is
in reset state. As a result syslog will show error messages.
We can prevent this by using state from local variable.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 02ac6a7..3034f0e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1349,12 +1349,14 @@ void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 	enum bnx2x_stats_state state;
 	if (unlikely(bp->panic))
 		return;
-	bnx2x_stats_stm[bp->stats_state][event].action(bp);
+
 	spin_lock_bh(&bp->stats_lock);
 	state = bp->stats_state;
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
 	spin_unlock_bh(&bp->stats_lock);
 
+	bnx2x_stats_stm[state][event].action(bp);
+
 	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
 		   state, event, bp->stats_state);
-- 
1.7.7.2
