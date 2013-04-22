From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v4 net-next 5/6] bnx2x: allow nvram test to run when
 device is down
Date: Mon, 22 Apr 2013 16:48:10 +0300
Message-ID: <1366638491-27184-6-git-send-email-dmitry@broadcom.com>
References: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4004 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075Ab3DVNsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:48:32 -0400
In-Reply-To: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index f07021b..88e9b47 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2864,9 +2864,16 @@ static void bnx2x_self_test(struct net_device *dev,
 
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
 
@@ -2928,13 +2935,7 @@ static void bnx2x_self_test(struct net_device *dev,
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
