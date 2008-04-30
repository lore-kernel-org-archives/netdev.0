From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/6] [BNX2]: Fix remote PHY initial link state.
Date: Wed, 30 Apr 2008 15:51:01 -0700
Message-ID: <1209595861.7941.61.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, andy@greyhouse.net
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3319 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760281AbYD3Vqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 17:46:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Fix remote PHY initial link state.

On some remote PHY blade systems, the driver receives no initial link
interrupt.  As a result, the GMII/MII MAC mode does not get setup properly.
To fix this problem, we add an initial poll of the link state after chip
reset.

With this change, the setting of the initial carrier state in the init
code can be eliminated.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 284dda2..9c6f21f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4214,13 +4214,6 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 		if (netif_running(bp->dev)) {
 			u32 sig;
 
-			if (val & BNX2_LINK_STATUS_LINK_UP) {
-				bp->link_up = 1;
-				netif_carrier_on(bp->dev);
-			} else {
-				bp->link_up = 0;
-				netif_carrier_off(bp->dev);
-			}
 			sig = BNX2_DRV_ACK_CAP_SIGNATURE |
 			      BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
 			bnx2_shmem_wr(bp, BNX2_DRV_ACK_CAP_MB, sig);
@@ -4877,6 +4870,8 @@ bnx2_init_nic(struct bnx2 *bp)
 	spin_lock_bh(&bp->phy_lock);
 	bnx2_init_phy(bp);
 	bnx2_set_link(bp);
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
+		bnx2_remote_phy_event(bp);
 	spin_unlock_bh(&bp->phy_lock);
 	return 0;
 }
-- 
1.5.5.GIT



