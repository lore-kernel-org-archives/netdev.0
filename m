From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: fix stats handling
Date: Fri, 15 Oct 2010 20:27:10 -0700
Message-ID: <20101016032707.1925.10161.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:39682 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752682Ab0JPD13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 23:27:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

There are currently some problems with igb.

- On 32bit arches, maintaining 64bit counters without proper
synchronization between writers and readers.

- Stats updated every two seconds, as reported by Jesper.
   (Jesper provided a patch for this)

- Potential problem between worker thread and ethtool -S

This patch uses u64_stats_sync, and convert everything to be 64bit safe,
SMP safe, even on 32bit arches. It integrates Jesper idea of providing
accurate stats at the time user reads them.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    9 +++
 drivers/net/igb/igb_ethtool.c |   52 ++++++++++++++-----
 drivers/net/igb/igb_main.c    |  113 ++++++++++++++++++++++++++++++-----------
 3 files changed, 129 insertions(+), 45 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 44e0ff1..edab9c4 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -159,6 +159,7 @@ struct igb_tx_queue_stats {
 	u64 packets;
 	u64 bytes;
 	u64 restart_queue;
+	u64 restart_queue2;
 };
 
 struct igb_rx_queue_stats {
@@ -210,11 +211,14 @@ struct igb_ring {
 		/* TX */
 		struct {
 			struct igb_tx_queue_stats tx_stats;
+			struct u64_stats_sync tx_syncp;
+			struct u64_stats_sync tx_syncp2;
 			bool detect_tx_hung;
 		};
 		/* RX */
 		struct {
 			struct igb_rx_queue_stats rx_stats;
+			struct u64_stats_sync rx_syncp;
 			u32 rx_buffer_len;
 		};
 	};
@@ -288,6 +292,9 @@ struct igb_adapter {
 	struct timecompare compare;
 	struct hwtstamp_config hwtstamp_config;
 
+	spinlock_t stats64_lock;
+	struct rtnl_link_stats64 stats64;
+
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 	struct e1000_hw_stats stats;
@@ -357,7 +364,7 @@ extern netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *, struct igb_ring *);
 extern void igb_unmap_and_free_tx_resource(struct igb_ring *,
 					   struct igb_buffer *);
 extern void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
-extern void igb_update_stats(struct igb_adapter *);
+extern void igb_update_stats(struct igb_adapter *, struct rtnl_link_stats64 *);
 extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
 extern void igb_power_up_link(struct igb_adapter *);
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 26bf6a1..a70e16b 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -90,8 +90,8 @@ static const struct igb_stats igb_gstrings_stats[] = {
 
 #define IGB_NETDEV_STAT(_net_stat) { \
 	.stat_string = __stringify(_net_stat), \
-	.sizeof_stat = FIELD_SIZEOF(struct net_device_stats, _net_stat), \
-	.stat_offset = offsetof(struct net_device_stats, _net_stat) \
+	.sizeof_stat = FIELD_SIZEOF(struct rtnl_link_stats64, _net_stat), \
+	.stat_offset = offsetof(struct rtnl_link_stats64, _net_stat) \
 }
 static const struct igb_stats igb_gstrings_net_stats[] = {
 	IGB_NETDEV_STAT(rx_errors),
@@ -111,8 +111,9 @@ static const struct igb_stats igb_gstrings_net_stats[] = {
 	(sizeof(igb_gstrings_net_stats) / sizeof(struct igb_stats))
 #define IGB_RX_QUEUE_STATS_LEN \
 	(sizeof(struct igb_rx_queue_stats) / sizeof(u64))
-#define IGB_TX_QUEUE_STATS_LEN \
-	(sizeof(struct igb_tx_queue_stats) / sizeof(u64))
+
+#define IGB_TX_QUEUE_STATS_LEN 3 /* packets, bytes, restart_queue */
+
 #define IGB_QUEUE_STATS_LEN \
 	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues * \
 	  IGB_RX_QUEUE_STATS_LEN) + \
@@ -2070,12 +2071,14 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct net_device_stats *net_stats = &netdev->stats;
-	u64 *queue_stat;
-	int i, j, k;
+	struct rtnl_link_stats64 *net_stats = &adapter->stats64;
+	unsigned int start;
+	struct igb_ring *ring;
+	int i, j;
 	char *p;
 
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, net_stats);
 
 	for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
 		p = (char *)adapter + igb_gstrings_stats[i].stat_offset;
@@ -2088,15 +2091,36 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j = 0; j < adapter->num_tx_queues; j++) {
-		queue_stat = (u64 *)&adapter->tx_ring[j]->tx_stats;
-		for (k = 0; k < IGB_TX_QUEUE_STATS_LEN; k++, i++)
-			data[i] = queue_stat[k];
+		u64	restart2;
+
+		ring = adapter->tx_ring[j];
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->tx_syncp);
+			data[i]   = ring->tx_stats.packets;
+			data[i+1] = ring->tx_stats.bytes;
+			data[i+2] = ring->tx_stats.restart_queue;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp, start));
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->tx_syncp2);
+			restart2  = ring->tx_stats.restart_queue2;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp2, start));
+		data[i+2] += restart2;
+
+		i += IGB_TX_QUEUE_STATS_LEN;
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
-		queue_stat = (u64 *)&adapter->rx_ring[j]->rx_stats;
-		for (k = 0; k < IGB_RX_QUEUE_STATS_LEN; k++, i++)
-			data[i] = queue_stat[k];
+		ring = adapter->rx_ring[j];
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->rx_syncp);
+			data[i]   = ring->rx_stats.packets;
+			data[i+1] = ring->rx_stats.bytes;
+			data[i+2] = ring->rx_stats.drops;
+			data[i+3] = ring->rx_stats.csum_err;
+			data[i+4] = ring->rx_stats.alloc_failed;
+		} while (u64_stats_fetch_retry_bh(&ring->rx_syncp, start));
+		i += IGB_RX_QUEUE_STATS_LEN;
 	}
+	spin_unlock(&adapter->stats64_lock);
 }
 
 static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5b04eff..b8dccc0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -96,7 +96,6 @@ static int igb_setup_all_rx_resources(struct igb_adapter *);
 static void igb_free_all_tx_resources(struct igb_adapter *);
 static void igb_free_all_rx_resources(struct igb_adapter *);
 static void igb_setup_mrqc(struct igb_adapter *);
-void igb_update_stats(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
@@ -113,7 +112,8 @@ static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
 static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *);
-static struct net_device_stats *igb_get_stats(struct net_device *);
+static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *dev,
+						 struct rtnl_link_stats64 *stats);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
 static void igb_set_uta(struct igb_adapter *adapter);
@@ -1536,7 +1536,9 @@ void igb_down(struct igb_adapter *adapter)
 	netif_carrier_off(netdev);
 
 	/* record the stats before reset*/
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, &adapter->stats64);
+	spin_unlock(&adapter->stats64_lock);
 
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -1689,7 +1691,7 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
 	.ndo_start_xmit		= igb_xmit_frame_adv,
-	.ndo_get_stats		= igb_get_stats,
+	.ndo_get_stats64	= igb_get_stats64,
 	.ndo_set_rx_mode	= igb_set_rx_mode,
 	.ndo_set_multicast_list	= igb_set_rx_mode,
 	.ndo_set_mac_address	= igb_set_mac,
@@ -2276,6 +2278,7 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
+	spin_lock_init(&adapter->stats64_lock);
 #ifdef CONFIG_PCI_IOV
 	if (hw->mac.type == e1000_82576)
 		adapter->vfs_allocated_count = (max_vfs > 7) ? 7 : max_vfs;
@@ -3483,7 +3486,9 @@ static void igb_watchdog_task(struct work_struct *work)
 		}
 	}
 
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, &adapter->stats64);
+	spin_unlock(&adapter->stats64_lock);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *tx_ring = adapter->tx_ring[i];
@@ -3550,6 +3555,8 @@ static void igb_update_ring_itr(struct igb_q_vector *q_vector)
 	int new_val = q_vector->itr_val;
 	int avg_wire_size = 0;
 	struct igb_adapter *adapter = q_vector->adapter;
+	struct igb_ring *ring;
+	unsigned int packets;
 
 	/* For non-gigabit speeds, just fix the interrupt rate at 4000
 	 * ints/sec - ITR timer value of 120 ticks.
@@ -3559,16 +3566,21 @@ static void igb_update_ring_itr(struct igb_q_vector *q_vector)
 		goto set_itr_val;
 	}
 
-	if (q_vector->rx_ring && q_vector->rx_ring->total_packets) {
-		struct igb_ring *ring = q_vector->rx_ring;
-		avg_wire_size = ring->total_bytes / ring->total_packets;
+	ring = q_vector->rx_ring;
+	if (ring) {
+		packets = ACCESS_ONCE(ring->total_packets);
+
+		if (packets)
+			avg_wire_size = ring->total_bytes / packets;
 	}
 
-	if (q_vector->tx_ring && q_vector->tx_ring->total_packets) {
-		struct igb_ring *ring = q_vector->tx_ring;
-		avg_wire_size = max_t(u32, avg_wire_size,
-		                      (ring->total_bytes /
-		                       ring->total_packets));
+	ring = q_vector->tx_ring;
+	if (ring) {
+		packets = ACCESS_ONCE(ring->total_packets);
+
+		if (packets)
+			avg_wire_size = max_t(u32, avg_wire_size,
+			                      ring->total_bytes / packets);
 	}
 
 	/* if avg_wire_size isn't set no work was done */
@@ -4077,7 +4089,11 @@ static int __igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 
 	/* A reprieve! */
 	netif_wake_subqueue(netdev, tx_ring->queue_index);
-	tx_ring->tx_stats.restart_queue++;
+
+	u64_stats_update_begin(&tx_ring->tx_syncp2);
+	tx_ring->tx_stats.restart_queue2++;
+	u64_stats_update_end(&tx_ring->tx_syncp2);
+
 	return 0;
 }
 
@@ -4214,16 +4230,22 @@ static void igb_reset_task(struct work_struct *work)
 }
 
 /**
- * igb_get_stats - Get System Network Statistics
+ * igb_get_stats64 - Get System Network Statistics
  * @netdev: network interface device structure
+ * @stats: rtnl_link_stats64 pointer
  *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
  **/
-static struct net_device_stats *igb_get_stats(struct net_device *netdev)
+static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *netdev,
+						 struct rtnl_link_stats64 *stats)
 {
-	/* only return the current stats */
-	return &netdev->stats;
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, &adapter->stats64);
+	memcpy(stats, &adapter->stats64, sizeof(*stats));
+	spin_unlock(&adapter->stats64_lock);
+
+	return stats;
 }
 
 /**
@@ -4305,15 +4327,17 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
  * @adapter: board private structure
  **/
 
-void igb_update_stats(struct igb_adapter *adapter)
+void igb_update_stats(struct igb_adapter *adapter,
+		      struct rtnl_link_stats64 *net_stats)
 {
-	struct net_device_stats *net_stats = igb_get_stats(adapter->netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 reg, mpc;
 	u16 phy_tmp;
 	int i;
 	u64 bytes, packets;
+	unsigned int start;
+	u64 _bytes, _packets;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -4331,10 +4355,17 @@ void igb_update_stats(struct igb_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		u32 rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0x0FFF;
 		struct igb_ring *ring = adapter->rx_ring[i];
+
 		ring->rx_stats.drops += rqdpc_tmp;
 		net_stats->rx_fifo_errors += rqdpc_tmp;
-		bytes += ring->rx_stats.bytes;
-		packets += ring->rx_stats.packets;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->rx_syncp);
+			_bytes = ring->rx_stats.bytes;
+			_packets = ring->rx_stats.packets;
+		} while (u64_stats_fetch_retry_bh(&ring->rx_syncp, start));
+		bytes += _bytes;
+		packets += _packets;
 	}
 
 	net_stats->rx_bytes = bytes;
@@ -4344,8 +4375,13 @@ void igb_update_stats(struct igb_adapter *adapter)
 	packets = 0;
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *ring = adapter->tx_ring[i];
-		bytes += ring->tx_stats.bytes;
-		packets += ring->tx_stats.packets;
+		do {
+			start = u64_stats_fetch_begin_bh(&ring->tx_syncp);
+			_bytes = ring->tx_stats.bytes;
+			_packets = ring->tx_stats.packets;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp, start));
+		bytes += _bytes;
+		packets += _packets;
 	}
 	net_stats->tx_bytes = bytes;
 	net_stats->tx_packets = packets;
@@ -5397,7 +5433,10 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
 		    !(test_bit(__IGB_DOWN, &adapter->state))) {
 			netif_wake_subqueue(netdev, tx_ring->queue_index);
+
+			u64_stats_update_begin(&tx_ring->tx_syncp);
 			tx_ring->tx_stats.restart_queue++;
+			u64_stats_update_end(&tx_ring->tx_syncp);
 		}
 	}
 
@@ -5437,8 +5476,10 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	}
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
+	u64_stats_update_begin(&tx_ring->tx_syncp);
 	tx_ring->tx_stats.bytes += total_bytes;
 	tx_ring->tx_stats.packets += total_packets;
+	u64_stats_update_end(&tx_ring->tx_syncp);
 	return count < tx_ring->count;
 }
 
@@ -5480,9 +5521,11 @@ static inline void igb_rx_checksum_adv(struct igb_ring *ring,
 		 * packets, (aka let the stack check the crc32c)
 		 */
 		if ((skb->len == 60) &&
-		    (ring->flags & IGB_RING_FLAG_RX_SCTP_CSUM))
+		    (ring->flags & IGB_RING_FLAG_RX_SCTP_CSUM)) {
+			u64_stats_update_begin(&ring->rx_syncp);
 			ring->rx_stats.csum_err++;
-
+			u64_stats_update_end(&ring->rx_syncp);
+		}
 		/* let the stack verify checksum errors */
 		return;
 	}
@@ -5669,8 +5712,10 @@ next_desc:
 
 	rx_ring->total_packets += total_packets;
 	rx_ring->total_bytes += total_bytes;
+	u64_stats_update_begin(&rx_ring->rx_syncp);
 	rx_ring->rx_stats.packets += total_packets;
 	rx_ring->rx_stats.bytes += total_bytes;
+	u64_stats_update_end(&rx_ring->rx_syncp);
 	return cleaned;
 }
 
@@ -5698,8 +5743,10 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 		if ((bufsz < IGB_RXBUFFER_1024) && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
 				buffer_info->page = netdev_alloc_page(netdev);
-				if (!buffer_info->page) {
+				if (unlikely(!buffer_info->page)) {
+					u64_stats_update_begin(&rx_ring->rx_syncp);
 					rx_ring->rx_stats.alloc_failed++;
+					u64_stats_update_end(&rx_ring->rx_syncp);
 					goto no_buffers;
 				}
 				buffer_info->page_offset = 0;
@@ -5714,7 +5761,9 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 			if (dma_mapping_error(rx_ring->dev,
 					      buffer_info->page_dma)) {
 				buffer_info->page_dma = 0;
+				u64_stats_update_begin(&rx_ring->rx_syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_syncp);
 				goto no_buffers;
 			}
 		}
@@ -5722,8 +5771,10 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 		skb = buffer_info->skb;
 		if (!skb) {
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
-			if (!skb) {
+			if (unlikely(!skb)) {
+				u64_stats_update_begin(&rx_ring->rx_syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_syncp);
 				goto no_buffers;
 			}
 
@@ -5737,7 +5788,9 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 			if (dma_mapping_error(rx_ring->dev,
 					      buffer_info->dma)) {
 				buffer_info->dma = 0;
+				u64_stats_update_begin(&rx_ring->rx_syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_syncp);
 				goto no_buffers;
 			}
 		}

