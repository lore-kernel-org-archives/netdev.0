From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Fri, 24 Jun 2011 13:43:25 +0530
Message-ID: <913f4373-e01f-4aa9-b8c7-d041d70f0945@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:15316 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753530Ab1FXIN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 04:13:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_stats_update() resets netdev->stats and then accumulates stats from
various rings. This is wrong as stats readers can sometimes catch zero values.
Use temporary variables instead for accumulating per-ring values.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c4f564c..5ca06b0 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -428,33 +428,38 @@ void netdev_stats_update(struct be_adapter *adapter)
 	struct net_device_stats *dev_stats = &adapter->netdev->stats;
 	struct be_rx_obj *rxo;
 	struct be_tx_obj *txo;
+	unsigned long pkts = 0, bytes = 0, mcast = 0, drops = 0;
 	int i;
 
-	memset(dev_stats, 0, sizeof(*dev_stats));
 	for_all_rx_queues(adapter, rxo, i) {
-		dev_stats->rx_packets += rx_stats(rxo)->rx_pkts;
-		dev_stats->rx_bytes += rx_stats(rxo)->rx_bytes;
-		dev_stats->multicast += rx_stats(rxo)->rx_mcast_pkts;
+		pkts += rx_stats(rxo)->rx_pkts;
+		bytes += rx_stats(rxo)->rx_bytes;
+		mcast += rx_stats(rxo)->rx_mcast_pkts;
 		/*  no space in linux buffers: best possible approximation */
 		if (adapter->generation == BE_GEN3) {
 			if (!(lancer_chip(adapter))) {
-				struct be_erx_stats_v1 *erx_stats =
+				struct be_erx_stats_v1 *erx =
 					be_erx_stats_from_cmd(adapter);
-				dev_stats->rx_dropped +=
-				erx_stats->rx_drops_no_fragments[rxo->q.id];
+				drops += erx->rx_drops_no_fragments[rxo->q.id];
 			}
 		} else {
-			struct be_erx_stats_v0 *erx_stats =
+			struct be_erx_stats_v0 *erx =
 					be_erx_stats_from_cmd(adapter);
-			dev_stats->rx_dropped +=
-				erx_stats->rx_drops_no_fragments[rxo->q.id];
+			drops += erx->rx_drops_no_fragments[rxo->q.id];
 		}
 	}
+	dev_stats->rx_packets = pkts;
+	dev_stats->rx_bytes = bytes;
+	dev_stats->multicast = mcast;
+	dev_stats->rx_dropped = drops;
 
+	pkts = bytes = 0;
 	for_all_tx_queues(adapter, txo, i) {
-		dev_stats->tx_packets += tx_stats(txo)->be_tx_pkts;
-		dev_stats->tx_bytes += tx_stats(txo)->be_tx_bytes;
+		pkts += tx_stats(txo)->be_tx_pkts;
+		bytes += tx_stats(txo)->be_tx_bytes;
 	}
+	dev_stats->tx_packets = pkts;
+	dev_stats->tx_bytes = bytes;
 
 	/* bad pkts received */
 	dev_stats->rx_errors = drvs->rx_crc_errors +
-- 
1.7.4

