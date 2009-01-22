From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 3/4]bnx2x: loopback test failure
Date: Thu, 22 Jan 2009 18:01:32 +0200
Message-ID: <1232640092.29087.54.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Harvey Harrison" <harvey.harrison@gmail.com>,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4815 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045AbZAVQCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 11:02:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A link change interrupt might be queued and activated after the loopback was set
and it will cause the loopback to fail. The PHY lock should be kept until the
loopback test is over.

That implies that the bnx2x_test_link should used within the loopback function
and not bnx2x_wait_for_link since that function also takes the PHY link

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 8b0513b..4b84f6c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8750,18 +8750,17 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	if (loopback_mode == BNX2X_MAC_LOOPBACK) {
 		bp->link_params.loopback_mode = LOOPBACK_BMAC;
-		bnx2x_acquire_phy_lock(bp);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		bnx2x_release_phy_lock(bp);
 
 	} else if (loopback_mode == BNX2X_PHY_LOOPBACK) {
+		u16 cnt = 1000;
 		bp->link_params.loopback_mode = LOOPBACK_XGXS_10;
-		bnx2x_acquire_phy_lock(bp);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		bnx2x_release_phy_lock(bp);
 		/* wait until link state is restored */
-		bnx2x_wait_for_link(bp, link_up);
-
+		if (link_up)
+			while (cnt-- && bnx2x_test_link(&bp->link_params,
+							&bp->link_vars))
+				msleep(10);
 	} else
 		return -EINVAL;
 
@@ -8867,6 +8866,7 @@ static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
 		return BNX2X_LOOPBACK_FAILED;
 
 	bnx2x_netif_stop(bp, 1);
+	bnx2x_acquire_phy_lock(bp);
 
 	if (bnx2x_run_loopback(bp, BNX2X_MAC_LOOPBACK, link_up)) {
 		DP(NETIF_MSG_PROBE, "MAC loopback failed\n");
@@ -8878,6 +8878,7 @@ static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
 		rc |= BNX2X_PHY_LOOPBACK_FAILED;
 	}
 
+	bnx2x_release_phy_lock(bp);
 	bnx2x_netif_start(bp);
 
 	return rc;
-- 
1.5.4.3




