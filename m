From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 1/7] bnx2x: Avoid sending multiple statistics
 queries
Date: Tue, 11 Sep 2012 17:34:08 +0300
Message-ID: <1347374054-16730-2-git-send-email-yuvalmin@broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1419 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759287Ab2IKO6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:58:40 -0400
In-Reply-To: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

During traffic when DCB is enabled, it is possible for multiple instances
of statistics queries to be sent to the chip - this may cause the FW to assert.

This patch prevents the sending of an additional instance of statistics query
while the previous query hasn't completed.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 332db64..d848dc9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1151,9 +1151,11 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 	if (bp->port.pmf)
 		bnx2x_hw_stats_update(bp);
 
-	if (bnx2x_storm_stats_update(bp) && (bp->stats_pending++ == 3)) {
-		BNX2X_ERR("storm stats were not updated for 3 times\n");
-		bnx2x_panic();
+	if (bnx2x_storm_stats_update(bp)) {
+		if (bp->stats_pending++ == 3) {
+			BNX2X_ERR("storm stats were not updated for 3 times\n");
+			bnx2x_panic();
+		}
 		return;
 	}
 
-- 
1.7.9.rc2
