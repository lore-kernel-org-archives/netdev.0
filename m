From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/2] igb: Implement reading of reg RQDPC (Receive Queue
	Drop Packet Count)
Date: Thu, 07 May 2009 15:37:11 +0200
Message-ID: <1241703431.18487.25.camel@localhost.localdomain>
References: <1241703346.18487.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:54210 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbZEGNhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 09:37:12 -0400
In-Reply-To: <1241703346.18487.22.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Implement reading the per queue drop stats register
RQDPC (Receive Queue Drop Packet Count).  It counts the number of
packets dropped by a queue due to lack of descriptors available.

Notice RQDPC (Receive Queue Drop Packet Count) stats only gets
incremented, if the DROP_EN bit it set (in the SRRCTL register
for that queue). If DROP_EN bit is NOT set, then the some what
equivalent count is stored in RNBC (not per queue basis).

The RQDPC register is only 12 bit, thus the precision might
suffer due to overrun in-between the watchdog polling interval.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/e1000_regs.h  |    2 ++
 drivers/net/igb/igb.h         |   13 ++++++++++---
 drivers/net/igb/igb_ethtool.c |   16 ++++++++++------
 drivers/net/igb/igb_main.c    |   14 ++++++++++++++
 4 files changed, 36 insertions(+), 9 deletions(-)


diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 0bd7728..85683e2 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -165,6 +165,8 @@ enum {
 				    : (0x0C018 + ((_n) * 0x40)))
 #define E1000_RXDCTL(_n)  ((_n) < 4 ? (0x02828 + ((_n) * 0x100)) \
 				    : (0x0C028 + ((_n) * 0x40)))
+#define E1000_RQDPC(_n)   ((_n) < 4 ? (0x02830 + ((_n) * 0x100)) \
+				    : (0x0C030 + ((_n) * 0x40)))
 #define E1000_TDBAL(_n)   ((_n) < 4 ? (0x03800 + ((_n) * 0x100)) \
 				    : (0x0E000 + ((_n) * 0x40)))
 #define E1000_TDBAH(_n)   ((_n) < 4 ? (0x03804 + ((_n) * 0x100)) \
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
index b8551a5..f0bf6f1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -96,9 +96,10 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues + \
-	 ((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues) * \
-	(sizeof(struct igb_queue_stats) / sizeof(u64)))
+	(((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues) * \
+	  (sizeof(struct igb_rx_queue_stats) / sizeof(u64))) +		 \
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
index 8de8629..06b01fc 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3495,6 +3495,8 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_tmp;
+	u32 rqdpc_tmp;
+	int i;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -3586,6 +3588,18 @@ void igb_update_stats(struct igb_adapter *adapter)
 
 	/* Rx Errors */
 
+	/* Read out drops stats per RX queue. Notice RQDPC (Receive
+	 * Queue Drop Packet Count) stats only gets incremented, if
+	 * the DROP_EN bit it set (in the SRRCTL register for that
+	 * queue). If DROP_EN bit is NOT set, then the some what
+	 * equivalent count is stored in RNBC (not per queue basis).
+	 * Also note the drop count is due to lack of available descriptors.
+	 */
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0xFFF;
+		adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
+	}
+
 	/* RLEC on some newer hardware can be incorrect so build
 	* our own version based on RUC and ROC */
 	adapter->net_stats.rx_errors = adapter->stats.rxerrc +


