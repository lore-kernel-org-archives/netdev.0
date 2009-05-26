From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] igb: Implement reading of reg RQDPC (Receive
	Queue Drop Packet Count)
Date: Tue, 26 May 2009 16:50:31 -0700
Message-ID: <20090526235030.28231.35089.stgit@localhost.localdomain>
References: <20090526234958.28231.16894.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:35390
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759451AbZEZXuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 19:50:46 -0400
In-Reply-To: <20090526234958.28231.16894.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>

Based on the previous patches from Jesper Dangaard Brouer <hawk@comx.dk>

Implement reading the per queue drop stats register
RQDPC (Receive Queue Drop Packet Count).  It counts the number of
packets dropped by a queue due to lack of descriptors available.

Notice RQDPC (Receive Queue Drop Packet Count) stats only gets
incremented, if the DROP_EN bit it set (in the SRRCTL register
for that queue).  If DROP_EN bit is NOT set, then the some what
equivalent count is stored in RNBC (not per queue basis).

The RQDPC register is only 12 bit, thus the precision might
suffer due to overrun in-netween the watchdog polling interval.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/igb.h         |   13 ++++++++++---
 drivers/net/igb/igb_ethtool.c |   16 ++++++++++------
 drivers/net/igb/igb_main.c    |   19 ++++++++++++++++++-
 3 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 154c5ac..b2c98de 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -137,11 +137,17 @@ struct igb_buffer {
 	};
 };
 
-struct igb_queue_stats {
+struct igb_tx_queue_stats {
 	u64 packets;
 	u64 bytes;
 };
 
+struct igb_rx_queue_stats {
+	u64 packets;
+	u64 bytes;
+	u64 drops;
+};
+
 struct igb_ring {
 	struct igb_adapter *adapter; /* backlink */
 	void *desc;                  /* descriptor ring memory */
@@ -167,12 +173,13 @@ struct igb_ring {
 	union {
 		/* TX */
 		struct {
-			struct igb_queue_stats tx_stats;
+			struct igb_tx_queue_stats tx_stats;
 			bool detect_tx_hung;
 		};
 		/* RX */
 		struct {
-			struct igb_queue_stats rx_stats;
+			struct igb_rx_queue_stats rx_stats;
+			u64 rx_queue_drops;
 			struct napi_struct napi;
 			int set_itr;
 			struct igb_ring *buddy;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index b8551a5..2ae98f9 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -96,9 +96,10 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues + \
-	 ((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues) * \
-	(sizeof(struct igb_queue_stats) / sizeof(u64)))
+	(((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues)* \
+	  (sizeof(struct igb_rx_queue_stats) / sizeof(u64))) + \
+	 ((((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues) * \
+	  (sizeof(struct igb_tx_queue_stats) / sizeof(u64))))
 #define IGB_GLOBAL_STATS_LEN	\
 	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
 #define IGB_STATS_LEN (IGB_GLOBAL_STATS_LEN + IGB_QUEUE_STATS_LEN)
@@ -1960,7 +1961,8 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	u64 *queue_stat;
-	int stat_count = sizeof(struct igb_queue_stats) / sizeof(u64);
+	int stat_count_tx = sizeof(struct igb_tx_queue_stats) / sizeof(u64);
+	int stat_count_rx = sizeof(struct igb_rx_queue_stats) / sizeof(u64);
 	int j;
 	int i;
 
@@ -1973,14 +1975,14 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	for (j = 0; j < adapter->num_tx_queues; j++) {
 		int k;
 		queue_stat = (u64 *)&adapter->tx_ring[j].tx_stats;
-		for (k = 0; k < stat_count; k++)
+		for (k = 0; k < stat_count_tx; k++)
 			data[i + k] = queue_stat[k];
 		i += k;
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
 		int k;
 		queue_stat = (u64 *)&adapter->rx_ring[j].rx_stats;
-		for (k = 0; k < stat_count; k++)
+		for (k = 0; k < stat_count_rx; k++)
 			data[i + k] = queue_stat[k];
 		i += k;
 	}
@@ -2014,6 +2016,8 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
+			sprintf(p, "rx_queue_%u_drops", i);
+			p += ETH_GSTRING_LEN;
 		}
 /*		BUG_ON(p - data != IGB_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2ec9809..4ae8133 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3588,8 +3588,25 @@ void igb_update_stats(struct igb_adapter *adapter)
 
 	/* Rx Errors */
 
+	if (hw->mac.type != e1000_82575) {
+		u32 rqdpc_tmp;
+		int i;
+		/* Read out drops stats per RX queue.  Notice RQDPC (Receive
+		 * Queue Drop Packet Count) stats only gets incremented, if
+		 * the DROP_EN but it set (in the SRRCTL register for that
+		 * queue).  If DROP_EN bit is NOT set, then the some what
+		 * equivalent count is stored in RNBC (not per queue basis).
+		 * Also note the drop count is due to lack of available
+		 * descriptors.
+		 */
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0xFFF;
+			adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
+		}
+	}
+
 	/* RLEC on some newer hardware can be incorrect so build
-	* our own version based on RUC and ROC */
+	 * our own version based on RUC and ROC */
 	adapter->net_stats.rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +

