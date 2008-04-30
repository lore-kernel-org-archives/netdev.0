From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/6][BNX2]: Refine remote PHY locking.
Date: Wed, 30 Apr 2008 15:50:29 -0700
Message-ID: <1209595829.7941.60.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, andy@greyhouse.net
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3235 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758693AbYD3Vqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 17:46:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Refine remote PHY locking.

bnx2_set_remote_link() should be called under bp->phy_lock to protect
against concurrent polling and interrupt calls.  This change is needed
by the next patch which will add one initial poll of the remote PHY
link status.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 15853be..284dda2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1715,7 +1715,6 @@ bnx2_remote_phy_event(struct bnx2 *bp)
 				break;
 		}
 
-		spin_lock(&bp->phy_lock);
 		bp->flow_ctrl = 0;
 		if ((bp->autoneg & (AUTONEG_SPEED | AUTONEG_FLOW_CTRL)) !=
 		    (AUTONEG_SPEED | AUTONEG_FLOW_CTRL)) {
@@ -1737,7 +1736,6 @@ bnx2_remote_phy_event(struct bnx2 *bp)
 		if (old_port != bp->phy_port)
 			bnx2_set_default_link(bp);
 
-		spin_unlock(&bp->phy_lock);
 	}
 	if (bp->link_up != link_up)
 		bnx2_report_link(bp);
@@ -2445,14 +2443,15 @@ bnx2_phy_event_is_set(struct bnx2 *bp, struct bnx2_napi *bnapi, u32 event)
 static void
 bnx2_phy_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 {
-	if (bnx2_phy_event_is_set(bp, bnapi, STATUS_ATTN_BITS_LINK_STATE)) {
-		spin_lock(&bp->phy_lock);
+	spin_lock(&bp->phy_lock);
+
+	if (bnx2_phy_event_is_set(bp, bnapi, STATUS_ATTN_BITS_LINK_STATE))
 		bnx2_set_link(bp);
-		spin_unlock(&bp->phy_lock);
-	}
 	if (bnx2_phy_event_is_set(bp, bnapi, STATUS_ATTN_BITS_TIMER_ABORT))
 		bnx2_set_remote_link(bp);
 
+	spin_unlock(&bp->phy_lock);
+
 }
 
 static inline u16
-- 
1.5.5.GIT



