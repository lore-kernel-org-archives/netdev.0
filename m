From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 04/10] bnx2x: Fix rare self-test failures
Date: Mon, 14 Jan 2013 17:11:44 +0200
Message-ID: <1358176310-31504-5-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1173 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757209Ab3ANQKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:10:05 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

On rare occasions, self test link may fail since the link is
being sampled while it's still being stabilized.
To correct this behaviour, try to sample the link for 2 seconds
prior to declaring a failure.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 292634f..23480da 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2379,8 +2379,8 @@ static void bnx2x_self_test(struct net_device *dev,
 			    struct ethtool_test *etest, u64 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	u8 is_serdes;
-	int rc;
+	u8 is_serdes, link_up;
+	int rc, cnt = 0;
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		netdev_err(bp->dev,
@@ -2402,20 +2402,17 @@ static void bnx2x_self_test(struct net_device *dev,
 	}
 
 	is_serdes = (bp->link_vars.link_status & LINK_STATUS_SERDES_LINK) > 0;
-
+	link_up = bp->link_vars.link_up;
 	/* offline tests are not supported in MF mode */
 	if ((etest->flags & ETH_TEST_FL_OFFLINE) && !IS_MF(bp)) {
 		int port = BP_PORT(bp);
 		u32 val;
-		u8 link_up;
 
 		/* save current value of input enable for TX port IF */
 		val = REG_RD(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4);
 		/* disable input for TX port IF */
 		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, 0);
 
-		link_up = bp->link_vars.link_up;
-
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL, false);
 		rc = bnx2x_nic_load(bp, LOAD_DIAG);
 		if (rc) {
@@ -2477,7 +2474,13 @@ static void bnx2x_self_test(struct net_device *dev,
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 
-	if (bnx2x_link_test(bp, is_serdes) != 0) {
+	if (link_up) {
+		cnt = 100;
+		while (bnx2x_link_test(bp, is_serdes) && --cnt)
+			msleep(20);
+	}
+
+	if (!cnt) {
 		if (!IS_MF(bp))
 			buf[6] = 1;
 		else
-- 
1.8.1.227.g44fe835
