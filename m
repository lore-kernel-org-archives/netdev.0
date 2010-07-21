From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 2/3 net-2.6] bnx2x: Protect statistics ramrod and
 sequence number
Date: Wed, 21 Jul 2010 18:59:14 +0300
Message-ID: <1279727954.14094.43.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2805 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755657Ab0GUP72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 11:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix: Protect statistics ramrod sending code and a statistics counter update
with a spinlock. Otherwise there was a race condition that would allow sending
a statistics ramrods with the same sequence number or with sequence numbers not
in a natural order, which would cause a FW assert.

 Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
 Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
 Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3dc876c..b86e47b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -3789,6 +3789,8 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 		struct eth_query_ramrod_data ramrod_data = {0};
 		int i, rc;
 
+		spin_lock_bh(&bp->stats_lock);
+
 		ramrod_data.drv_counter = bp->stats_counter++;
 		ramrod_data.collect_port = bp->port.pmf ? 1 : 0;
 		for_each_queue(bp, i)
@@ -3802,6 +3804,8 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 			bp->spq_left++;
 			bp->stats_pending = 1;
 		}
+
+		spin_unlock_bh(&bp->stats_lock);
 	}
 }
 
@@ -4367,6 +4371,14 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 	struct host_func_stats *fstats = bnx2x_sp(bp, func_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	int i;
+	u16 cur_stats_counter;
+
+	/* Make sure we use the value of the counter
+	 * used for sending the last stats ramrod.
+	 */
+	spin_lock_bh(&bp->stats_lock);
+	cur_stats_counter = bp->stats_counter - 1;
+	spin_unlock_bh(&bp->stats_lock);
 
 	memcpy(&(fstats->total_bytes_received_hi),
 	       &(bnx2x_sp(bp, func_stats_base)->total_bytes_received_hi),
@@ -4394,25 +4406,22 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 		u32 diff;
 
 		/* are storm stats valid? */
-		if ((u16)(le16_to_cpu(xclient->stats_counter) + 1) !=
-							bp->stats_counter) {
+		if (le16_to_cpu(xclient->stats_counter) != cur_stats_counter) {
 			DP(BNX2X_MSG_STATS, "[%d] stats not updated by xstorm"
 			   "  xstorm counter (0x%x) != stats_counter (0x%x)\n",
-			   i, xclient->stats_counter, bp->stats_counter);
+			   i, xclient->stats_counter, cur_stats_counter + 1);
 			return -1;
 		}
-		if ((u16)(le16_to_cpu(tclient->stats_counter) + 1) !=
-							bp->stats_counter) {
+		if (le16_to_cpu(tclient->stats_counter) != cur_stats_counter) {
 			DP(BNX2X_MSG_STATS, "[%d] stats not updated by tstorm"
 			   "  tstorm counter (0x%x) != stats_counter (0x%x)\n",
-			   i, tclient->stats_counter, bp->stats_counter);
+			   i, tclient->stats_counter, cur_stats_counter + 1);
 			return -2;
 		}
-		if ((u16)(le16_to_cpu(uclient->stats_counter) + 1) !=
-							bp->stats_counter) {
+		if (le16_to_cpu(uclient->stats_counter) != cur_stats_counter) {
 			DP(BNX2X_MSG_STATS, "[%d] stats not updated by ustorm"
 			   "  ustorm counter (0x%x) != stats_counter (0x%x)\n",
-			   i, uclient->stats_counter, bp->stats_counter);
+			   i, uclient->stats_counter, cur_stats_counter + 1);
 			return -4;
 		}
 
-- 
1.7.1




