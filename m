From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 5/6] bnx2x: allow nvram test to run when
 device is down
Date: Mon, 22 Apr 2013 13:15:07 +0300
Message-ID: <1366625708-5678-6-git-send-email-dmitry@broadcom.com>
References: <1366625708-5678-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romueu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4196 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921Ab3DVKPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 06:15:31 -0400
In-Reply-To: <1366625708-5678-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 14900ee..541becc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2863,9 +2863,16 @@ static void bnx2x_self_test(struct net_device *dev,
 
 	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS(bp));
 
+	if (bnx2x_test_nvram(bp) != 0) {
+		if (!IS_MF(bp))
+			buf[4] = 1;
+		else
+			buf[0] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
+
 	if (!netif_running(dev)) {
-		DP(BNX2X_MSG_ETHTOOL,
-		   "Can't perform self-test when interface is down\n");
+		DP(BNX2X_MSG_ETHTOOL, "Interface is down\n");
 		return;
 	}
 
@@ -2927,13 +2934,7 @@ static void bnx2x_self_test(struct net_device *dev,
 		/* wait until link state is restored */
 		bnx2x_wait_for_link(bp, link_up, is_serdes);
 	}
-	if (bnx2x_test_nvram(bp) != 0) {
-		if (!IS_MF(bp))
-			buf[4] = 1;
-		else
-			buf[0] = 1;
-		etest->flags |= ETH_TEST_FL_FAILED;
-	}
+
 	if (bnx2x_test_intr(bp) != 0) {
 		if (!IS_MF(bp))
 			buf[5] = 1;
-- 
1.8.1.4
