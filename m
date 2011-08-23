From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap around
Date: Tue, 23 Aug 2011 11:11:53 +0530
Message-ID: <1314078115-8121-4-git-send-email-sathya.perla@emulex.com>
References: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27624 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752701Ab1HWFmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 01:42:51 -0400
In-Reply-To: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx_drops_no_frags HW counter for RSS rings is 16bits in HW and can
wraparound often. Maintain a 32-bit accumulator in the driver to prevent
frequent wraparound.

Also, incorporated Eric's feedback to use ACCESS_ONCE() for the accumulator
write.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2375c0c..fb2eda0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -378,6 +378,18 @@ static void populate_lancer_stats(struct be_adapter *adapter)
 				pport_stats->rx_drops_too_many_frags_lo;
 }
 
+static void accumulate_16bit_val(u32 *acc, u16 val)
+{
+#define lo(x)			(x & 0xFFFF)
+#define hi(x)			(x & 0xFFFF0000)
+	bool wrapped = val < lo(*acc);
+	u32 newacc = hi(*acc) + val;
+
+	if (wrapped)
+		newacc += 65536;
+	ACCESS_ONCE(*acc) = newacc;
+}
+
 void be_parse_stats(struct be_adapter *adapter)
 {
 	struct be_erx_stats_v1 *erx = be_erx_stats_from_cmd(adapter);
@@ -394,9 +406,13 @@ void be_parse_stats(struct be_adapter *adapter)
 	}
 
 	/* as erx_v1 is longer than v0, ok to use v1 defn for v0 access */
-	for_all_rx_queues(adapter, rxo, i)
-		rx_stats(rxo)->rx_drops_no_frags =
-			erx->rx_drops_no_fragments[rxo->q.id];
+	for_all_rx_queues(adapter, rxo, i) {
+		/* below erx HW counter can actually wrap around after
+		 * 65535. Driver accumulates a 32-bit value
+		 */
+		accumulate_16bit_val(&rx_stats(rxo)->rx_drops_no_frags,
+				(u16)erx->rx_drops_no_fragments[rxo->q.id]);
+	}
 }
 
 static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
-- 
1.7.4

