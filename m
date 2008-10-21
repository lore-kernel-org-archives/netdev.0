From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 1/2] igb: statistic optimization
Date: Tue, 21 Oct 2008 12:09:35 -0700
Message-ID: <20081021120935.1b3cea8d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffery.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The network statistics were being updated by multiple CPU's causing cache
line bounces. Since this driver already keeps statistics per ring, use
those to compute the bytes/packet statistics.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Compile tested only, evaluation in progress


--- a/drivers/net/igb/igb_main.c	2008-10-21 08:57:11.000000000 -0700
+++ b/drivers/net/igb/igb_main.c	2008-10-21 09:05:43.000000000 -0700
@@ -3029,9 +3029,27 @@ static struct net_device_stats *
 igb_get_stats(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct net_device_stats *stats = &adapter->net_stats;
+	int i;
+
+	stats->tx_bytes = 0;
+	stats->tx_packets = 0;
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct igb_ring *tx_ring = &adapter->tx_ring[i];
+		stats->tx_bytes += tx_ring->tx_stats.bytes;
+		stats->tx_packets += tx_ring->tx_stats.packets;
+	}
+	stats->rx_bytes = 0;
+	stats->rx_packets = 0;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct igb_ring *rx_ring = &adapter->rx_ring[i];
+		stats->rx_bytes += rx_ring->rx_stats.bytes;
+		stats->rx_packets += rx_ring->rx_stats.packets;
+	}
+
+	igb_update_stats(adapter);
 
-	/* only return the current stats */
-	return &adapter->net_stats;
+	return stats;
 }
 
 /**
@@ -3711,8 +3729,6 @@ done_cleaning:
 	tx_ring->total_packets += total_packets;
 	tx_ring->tx_stats.bytes += total_bytes;
 	tx_ring->tx_stats.packets += total_packets;
-	adapter->net_stats.tx_bytes += total_bytes;
-	adapter->net_stats.tx_packets += total_packets;
 	return retval;
 }
 
@@ -3953,8 +3969,6 @@ next_desc:
 	rx_ring->total_bytes += total_bytes;
 	rx_ring->rx_stats.packets += total_packets;
 	rx_ring->rx_stats.bytes += total_bytes;
-	adapter->net_stats.rx_bytes += total_bytes;
-	adapter->net_stats.rx_packets += total_packets;
 	return cleaned;
 }
 

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
