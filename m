From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] Revert
 "bnx2x: allow nvram test to run when device is down"
Date: Tue, 30 Apr 2013 12:34:07 +0300
Message-ID: <1367314447-10518-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4231 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898Ab3D3JeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 05:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit d2d2d87dfd1a25ee270994c5b9e3eb4690428d32.
Since it makes access to the device in D3 state possible.
More work is required to make sure device is not set to D3
during ifdown. Until this is done the nvram-test should simply
exit if device is down like it did before.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
This will be done in another patch-series after the current merge window.
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 397537b..ce1a916 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2867,16 +2867,9 @@ static void bnx2x_self_test(struct net_device *dev,
 
 	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS(bp));
 
-	if (bnx2x_test_nvram(bp) != 0) {
-		if (!IS_MF(bp))
-			buf[4] = 1;
-		else
-			buf[0] = 1;
-		etest->flags |= ETH_TEST_FL_FAILED;
-	}
-
 	if (!netif_running(dev)) {
-		DP(BNX2X_MSG_ETHTOOL, "Interface is down\n");
+		DP(BNX2X_MSG_ETHTOOL,
+		   "Can't perform self-test when interface is down\n");
 		return;
 	}
 
@@ -2938,7 +2931,13 @@ static void bnx2x_self_test(struct net_device *dev,
 		/* wait until link state is restored */
 		bnx2x_wait_for_link(bp, link_up, is_serdes);
 	}
-
+	if (bnx2x_test_nvram(bp) != 0) {
+		if (!IS_MF(bp))
+			buf[4] = 1;
+		else
+			buf[0] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
 	if (bnx2x_test_intr(bp) != 0) {
 		if (!IS_MF(bp))
 			buf[5] = 1;
-- 
1.8.1.4
