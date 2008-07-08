From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND NET-NEXT PATCH 09/20] igb: update ethtool stats to support
	multiqueue
Date: Tue, 08 Jul 2008 15:07:24 -0700
Message-ID: <20080708220656.1518.42888.stgit@localhost.localdomain>
References: <20080708220046.1518.88457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21248 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482AbYGHWH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:07:26 -0400
In-Reply-To: <20080708220046.1518.88457.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Addesses problems seen earlier with igb driver not correctly reporting rx
and tx stats.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    1 +
 drivers/net/igb/igb_ethtool.c |   13 +++++++++----
 drivers/net/igb/igb_main.c    |    2 ++
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a1431c8..5915efc 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -158,6 +158,7 @@ struct igb_ring {
 	union {
 		/* TX */
 		struct {
+			struct igb_queue_stats tx_stats;
 			bool detect_tx_hung;
 		};
 		/* RX */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 0447f9b..ed756c1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -96,10 +96,8 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	((((((struct igb_adapter *)netdev->priv)->num_rx_queues > 1) ? \
-	  ((struct igb_adapter *)netdev->priv)->num_rx_queues : 0) + \
-	 (((((struct igb_adapter *)netdev->priv)->num_tx_queues > 1) ? \
-	  ((struct igb_adapter *)netdev->priv)->num_tx_queues : 0))) * \
+	((((struct igb_adapter *)netdev->priv)->num_rx_queues + \
+	 ((struct igb_adapter *)netdev->priv)->num_tx_queues) * \
 	(sizeof(struct igb_queue_stats) / sizeof(u64)))
 #define IGB_GLOBAL_STATS_LEN	\
 	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
@@ -1842,6 +1840,13 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (igb_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
+	for (j = 0; j < adapter->num_tx_queues; j++) {
+		int k;
+		queue_stat = (u64 *)&adapter->tx_ring[j].tx_stats;
+		for (k = 0; k < stat_count; k++)
+			data[i + k] = queue_stat[k];
+		i += k;
+	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
 		int k;
 		queue_stat = (u64 *)&adapter->rx_ring[j].rx_stats;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e11a5da..f975bfe 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3431,6 +3431,8 @@ done_cleaning:
 	}
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
+	tx_ring->tx_stats.bytes += total_bytes;
+	tx_ring->tx_stats.packets += total_packets;
 	adapter->net_stats.tx_bytes += total_bytes;
 	adapter->net_stats.tx_packets += total_packets;
 	return retval;

