From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: fix stats handling
Date: Thu, 21 Oct 2010 02:00:04 -0700
Message-ID: <20101021090001.12059.37088.stgit@localhost.localdomain>
References: <20101021085740.12059.20577.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:37560
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753608Ab0JUJA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 05:00:27 -0400
In-Reply-To: <20101021085740.12059.20577.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Current ixgbe stats have following problems :

- Not 64 bit safe (on 32bit arches)

- Not safe in ixgbe_clean_rx_irq() :
   All cpus dirty a common location (netdev->stats.rx_bytes &
netdev->stats.rx_packets) without proper synchronization.
   This slow down a bit multiqueue operations, and possibly miss some
updates.

Fixes :

Implement ndo_get_stats64() method to provide accurate 64bit rx|tx
bytes/packets counters, using 64bit safe infrastructure.

ixgbe_get_ethtool_stats() also use this infrastructure to provide 64bit
safe counters.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    3 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c |   29 ++++++++++++++++-----------
 drivers/net/ixgbe/ixgbe_main.c    |   40 ++++++++++++++++++++++++++++++++++---
 3 files changed, 56 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a8c47b0..944d9e2 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -180,8 +180,9 @@ struct ixgbe_ring {
 					 */
 
 	struct ixgbe_queue_stats stats;
-	unsigned long reinit_state;
+	struct u64_stats_sync syncp;
 	int numa_node;
+	unsigned long reinit_state;
 	u64 rsc_count;			/* stat for coalesced packets */
 	u64 rsc_flush;			/* stats for flushed packets */
 	u32 restart_queue;		/* track tx queue restarts */
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index d4ac943..3c7f15d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -999,12 +999,11 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
                                     struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u64 *queue_stat;
-	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
 	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *net_stats;
-	int j, k;
-	int i;
+	unsigned int start;
+	struct ixgbe_ring *ring;
+	int i, j;
 	char *p = NULL;
 
 	ixgbe_update_stats(adapter);
@@ -1025,16 +1024,22 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j = 0; j < adapter->num_tx_queues; j++) {
-		queue_stat = (u64 *)&adapter->tx_ring[j]->stats;
-		for (k = 0; k < stat_count; k++)
-			data[i + k] = queue_stat[k];
-		i += k;
+		ring = adapter->tx_ring[j];
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			data[i]   = ring->stats.packets;
+			data[i+1] = ring->stats.bytes;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		i += 2;
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
-		queue_stat = (u64 *)&adapter->rx_ring[j]->stats;
-		for (k = 0; k < stat_count; k++)
-			data[i + k] = queue_stat[k];
-		i += k;
+		ring = adapter->rx_ring[j];
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			data[i]   = ring->stats.packets;
+			data[i+1] = ring->stats.bytes;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		i += 2;
 	}
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		for (j = 0; j < MAX_TX_PACKET_BUFFERS; j++) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 790a0da..d066ba3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -824,8 +824,10 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
+	u64_stats_update_begin(&tx_ring->syncp);
 	tx_ring->stats.packets += total_packets;
 	tx_ring->stats.bytes += total_bytes;
+	u64_stats_update_end(&tx_ring->syncp);
 	return count < tx_ring->work_limit;
 }
 
@@ -1172,7 +1174,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       int *work_done, int work_to_do)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
@@ -1298,8 +1299,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 					rx_ring->rsc_count++;
 				rx_ring->rsc_flush++;
 			}
+			u64_stats_update_begin(&rx_ring->syncp);
 			rx_ring->stats.packets++;
 			rx_ring->stats.bytes += skb->len;
+			u64_stats_update_end(&rx_ring->syncp);
 		} else {
 			if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 				rx_buffer_info->skb = next_buffer->skb;
@@ -1375,8 +1378,6 @@ next_desc:
 
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
-	netdev->stats.rx_bytes += total_rx_bytes;
-	netdev->stats.rx_packets += total_rx_packets;
 
 	return cleaned;
 }
@@ -6558,6 +6559,38 @@ static void ixgbe_netpoll(struct net_device *netdev)
 }
 #endif
 
+static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
+						   struct rtnl_link_stats64 *stats)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	/* accurate rx/tx bytes/packets stats */
+	dev_txq_stats_fold(netdev, stats);
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct ixgbe_ring *ring = adapter->rx_ring[i];
+		u64 bytes, packets;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			packets = ring->stats.packets;
+			bytes   = ring->stats.bytes;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		stats->rx_packets += packets;
+		stats->rx_bytes   += bytes;
+	}
+
+	/* following stats updated by ixgbe_watchdog_task() */
+	stats->multicast	= netdev->stats.multicast;
+	stats->rx_errors	= netdev->stats.rx_errors;
+	stats->rx_length_errors	= netdev->stats.rx_length_errors;
+	stats->rx_crc_errors	= netdev->stats.rx_crc_errors;
+	stats->rx_missed_errors	= netdev->stats.rx_missed_errors;
+	return stats;
+}
+
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -6577,6 +6610,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
+	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif

