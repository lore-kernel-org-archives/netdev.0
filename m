From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Remove dead code
Date: Fri, 19 Aug 2011 16:58:19 -0700
Message-ID: <1313798304-26171-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1769 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622Ab1HSXvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 19:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that CPMU devices don't do MAC loopback, all the CPMU power saving
mode adjustments are unneeded.  This patch removes the dead code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   35 +----------------------------------
 1 files changed, 1 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dc3fbf6..756e2bb 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11527,7 +11527,7 @@ out:
 static int tg3_test_loopback(struct tg3 *tp)
 {
 	int err = 0;
-	u32 eee_cap, cpmuctrl = 0;
+	u32 eee_cap;
 
 	if (!netif_running(tp->dev))
 		return TG3_LOOPBACK_FAILED;
@@ -11554,32 +11554,6 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 		tg3_phy_toggle_apd(tp, false);
 
-	if (tg3_flag(tp, CPMU_PRESENT)) {
-		int i;
-		u32 status;
-
-		tw32(TG3_CPMU_MUTEX_REQ, CPMU_MUTEX_REQ_DRIVER);
-
-		/* Wait for up to 40 microseconds to acquire lock. */
-		for (i = 0; i < 4; i++) {
-			status = tr32(TG3_CPMU_MUTEX_GNT);
-			if (status == CPMU_MUTEX_GNT_DRIVER)
-				break;
-			udelay(10);
-		}
-
-		if (status != CPMU_MUTEX_GNT_DRIVER) {
-			err = TG3_LOOPBACK_FAILED;
-			goto done;
-		}
-
-		/* Turn off link-based power management. */
-		cpmuctrl = tr32(TG3_CPMU_CTRL);
-		tw32(TG3_CPMU_CTRL,
-		     cpmuctrl & ~(CPMU_CTRL_LINK_SPEED_MODE |
-				  CPMU_CTRL_LINK_AWARE_MODE));
-	}
-
 	if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
 		err |= TG3_STD_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
 
@@ -11587,13 +11561,6 @@ static int tg3_test_loopback(struct tg3 *tp)
 	    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
 		err |= TG3_JMB_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
 
-	if (tg3_flag(tp, CPMU_PRESENT)) {
-		tw32(TG3_CPMU_CTRL, cpmuctrl);
-
-		/* Release the mutex */
-		tw32(TG3_CPMU_MUTEX_GNT, CPMU_MUTEX_GNT_DRIVER);
-	}
-
 	if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    !tg3_flag(tp, USE_PHYLIB)) {
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
-- 
1.7.3.4


