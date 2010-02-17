From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/18] igb: Allocate rings seperately instead of
	as a block
Date: Wed, 17 Feb 2010 03:02:39 -0800
Message-ID: <20100217110237.17723.55613.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:60348
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753021Ab0BQLC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:02:57 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the rings are allocated seperately.  As a
result we can allocate them on seperate nodes at some point in the future
if we so desire.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    5 +-
 drivers/net/igb/igb_ethtool.c |   46 +++++++++--------
 drivers/net/igb/igb_main.c    |  113 +++++++++++++++++++++--------------------
 3 files changed, 83 insertions(+), 81 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 0e0800d..8f07bc0 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -240,7 +240,6 @@ static inline int igb_desc_unused(struct igb_ring *ring)
 }
 
 /* board specific private data structure */
-
 struct igb_adapter {
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
@@ -266,12 +265,12 @@ struct igb_adapter {
 	unsigned long led_status;
 
 	/* TX */
-	struct igb_ring *tx_ring;      /* One per active queue */
+	struct igb_ring *tx_ring[16];
 	unsigned long tx_queue_len;
 	u32 tx_timeout_count;
 
 	/* RX */
-	struct igb_ring *rx_ring;      /* One per active queue */
+	struct igb_ring *rx_ring[16];
 	int num_tx_queues;
 	int num_rx_queues;
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 4852883..a4cead1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -314,7 +314,7 @@ static int igb_set_pauseparam(struct net_device *netdev,
 static u32 igb_get_rx_csum(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	return !!(adapter->rx_ring[0].flags & IGB_RING_FLAG_RX_CSUM);
+	return !!(adapter->rx_ring[0]->flags & IGB_RING_FLAG_RX_CSUM);
 }
 
 static int igb_set_rx_csum(struct net_device *netdev, u32 data)
@@ -324,9 +324,9 @@ static int igb_set_rx_csum(struct net_device *netdev, u32 data)
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		if (data)
-			adapter->rx_ring[i].flags |= IGB_RING_FLAG_RX_CSUM;
+			adapter->rx_ring[i]->flags |= IGB_RING_FLAG_RX_CSUM;
 		else
-			adapter->rx_ring[i].flags &= ~IGB_RING_FLAG_RX_CSUM;
+			adapter->rx_ring[i]->flags &= ~IGB_RING_FLAG_RX_CSUM;
 	}
 
 	return 0;
@@ -789,9 +789,9 @@ static int igb_set_ringparam(struct net_device *netdev,
 
 	if (!netif_running(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].count = new_tx_count;
+			adapter->tx_ring[i]->count = new_tx_count;
 		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].count = new_rx_count;
+			adapter->rx_ring[i]->count = new_rx_count;
 		adapter->tx_ring_count = new_tx_count;
 		adapter->rx_ring_count = new_rx_count;
 		goto clear_reset;
@@ -815,10 +815,10 @@ static int igb_set_ringparam(struct net_device *netdev,
 	 * to the tx and rx ring structs.
 	 */
 	if (new_tx_count != adapter->tx_ring_count) {
-		memcpy(temp_ring, adapter->tx_ring,
-		       adapter->num_tx_queues * sizeof(struct igb_ring));
-
 		for (i = 0; i < adapter->num_tx_queues; i++) {
+			memcpy(&temp_ring[i], adapter->tx_ring[i],
+			       sizeof(struct igb_ring));
+
 			temp_ring[i].count = new_tx_count;
 			err = igb_setup_tx_resources(&temp_ring[i]);
 			if (err) {
@@ -830,20 +830,21 @@ static int igb_set_ringparam(struct net_device *netdev,
 			}
 		}
 
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			igb_free_tx_resources(&adapter->tx_ring[i]);
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			igb_free_tx_resources(adapter->tx_ring[i]);
 
-		memcpy(adapter->tx_ring, temp_ring,
-		       adapter->num_tx_queues * sizeof(struct igb_ring));
+			memcpy(adapter->tx_ring[i], &temp_ring[i],
+			       sizeof(struct igb_ring));
+		}
 
 		adapter->tx_ring_count = new_tx_count;
 	}
 
-	if (new_rx_count != adapter->rx_ring->count) {
-		memcpy(temp_ring, adapter->rx_ring,
-		       adapter->num_rx_queues * sizeof(struct igb_ring));
-
+	if (new_rx_count != adapter->rx_ring_count) {
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			memcpy(&temp_ring[i], adapter->rx_ring[i],
+			       sizeof(struct igb_ring));
+
 			temp_ring[i].count = new_rx_count;
 			err = igb_setup_rx_resources(&temp_ring[i]);
 			if (err) {
@@ -856,11 +857,12 @@ static int igb_set_ringparam(struct net_device *netdev,
 
 		}
 
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			igb_free_rx_resources(&adapter->rx_ring[i]);
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			igb_free_rx_resources(adapter->rx_ring[i]);
 
-		memcpy(adapter->rx_ring, temp_ring,
-		       adapter->num_rx_queues * sizeof(struct igb_ring));
+			memcpy(adapter->rx_ring[i], &temp_ring[i],
+			       sizeof(struct igb_ring));
+		}
 
 		adapter->rx_ring_count = new_rx_count;
 	}
@@ -2036,12 +2038,12 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j = 0; j < adapter->num_tx_queues; j++) {
-		queue_stat = (u64 *)&adapter->tx_ring[j].tx_stats;
+		queue_stat = (u64 *)&adapter->tx_ring[j]->tx_stats;
 		for (k = 0; k < IGB_TX_QUEUE_STATS_LEN; k++, i++)
 			data[i] = queue_stat[k];
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
-		queue_stat = (u64 *)&adapter->rx_ring[j].rx_stats;
+		queue_stat = (u64 *)&adapter->rx_ring[j]->rx_stats;
 		for (k = 0; k < IGB_RX_QUEUE_STATS_LEN; k++, i++)
 			data[i] = queue_stat[k];
 	}
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 089a7c3..30fb5a8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -318,31 +318,35 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 		 */
 		if (adapter->vfs_allocated_count) {
 			for (; i < adapter->rss_queues; i++)
-				adapter->rx_ring[i].reg_idx = rbase_offset +
-				                              Q_IDX_82576(i);
+				adapter->rx_ring[i]->reg_idx = rbase_offset +
+				                               Q_IDX_82576(i);
 			for (; j < adapter->rss_queues; j++)
-				adapter->tx_ring[j].reg_idx = rbase_offset +
-				                              Q_IDX_82576(j);
+				adapter->tx_ring[j]->reg_idx = rbase_offset +
+				                               Q_IDX_82576(j);
 		}
 	case e1000_82575:
 	case e1000_82580:
 	default:
 		for (; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].reg_idx = rbase_offset + i;
+			adapter->rx_ring[i]->reg_idx = rbase_offset + i;
 		for (; j < adapter->num_tx_queues; j++)
-			adapter->tx_ring[j].reg_idx = rbase_offset + j;
+			adapter->tx_ring[j]->reg_idx = rbase_offset + j;
 		break;
 	}
 }
 
 static void igb_free_queues(struct igb_adapter *adapter)
 {
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-
-	adapter->tx_ring = NULL;
-	adapter->rx_ring = NULL;
+	int i;
 
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		kfree(adapter->tx_ring[i]);
+		adapter->tx_ring[i] = NULL;
+	}
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		kfree(adapter->rx_ring[i]);
+		adapter->rx_ring[i] = NULL;
+	}
 	adapter->num_rx_queues = 0;
 	adapter->num_tx_queues = 0;
 }
@@ -356,20 +360,13 @@ static void igb_free_queues(struct igb_adapter *adapter)
  **/
 static int igb_alloc_queues(struct igb_adapter *adapter)
 {
+	struct igb_ring *ring;
 	int i;
 
-	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
-				   sizeof(struct igb_ring), GFP_KERNEL);
-	if (!adapter->tx_ring)
-		goto err;
-
-	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
-				   sizeof(struct igb_ring), GFP_KERNEL);
-	if (!adapter->rx_ring)
-		goto err;
-
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct igb_ring *ring = &(adapter->tx_ring[i]);
+		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
+		if (!ring)
+			goto err;
 		ring->count = adapter->tx_ring_count;
 		ring->queue_index = i;
 		ring->pdev = adapter->pdev;
@@ -377,10 +374,13 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		/* For 82575, context index must be unique per ring. */
 		if (adapter->hw.mac.type == e1000_82575)
 			ring->flags = IGB_RING_FLAG_TX_CTX_IDX;
+		adapter->tx_ring[i] = ring;
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct igb_ring *ring = &(adapter->rx_ring[i]);
+		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
+		if (!ring)
+			goto err;
 		ring->count = adapter->rx_ring_count;
 		ring->queue_index = i;
 		ring->pdev = adapter->pdev;
@@ -390,6 +390,7 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
 			ring->flags |= IGB_RING_FLAG_RX_SCTP_CSUM;
+		adapter->rx_ring[i] = ring;
 	}
 
 	igb_cache_ring_register(adapter);
@@ -780,10 +781,9 @@ err_out:
 static void igb_map_rx_ring_to_vector(struct igb_adapter *adapter,
                                       int ring_idx, int v_idx)
 {
-	struct igb_q_vector *q_vector;
+	struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
 
-	q_vector = adapter->q_vector[v_idx];
-	q_vector->rx_ring = &adapter->rx_ring[ring_idx];
+	q_vector->rx_ring = adapter->rx_ring[ring_idx];
 	q_vector->rx_ring->q_vector = q_vector;
 	q_vector->itr_val = adapter->rx_itr_setting;
 	if (q_vector->itr_val && q_vector->itr_val <= 3)
@@ -793,10 +793,9 @@ static void igb_map_rx_ring_to_vector(struct igb_adapter *adapter,
 static void igb_map_tx_ring_to_vector(struct igb_adapter *adapter,
                                       int ring_idx, int v_idx)
 {
-	struct igb_q_vector *q_vector;
+	struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
 
-	q_vector = adapter->q_vector[v_idx];
-	q_vector->tx_ring = &adapter->tx_ring[ring_idx];
+	q_vector->tx_ring = adapter->tx_ring[ring_idx];
 	q_vector->tx_ring->q_vector = q_vector;
 	q_vector->itr_val = adapter->tx_itr_setting;
 	if (q_vector->itr_val && q_vector->itr_val <= 3)
@@ -1106,7 +1105,7 @@ static void igb_configure(struct igb_adapter *adapter)
 	 * at least 1 descriptor unused to make sure
 	 * next_to_use != next_to_clean */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct igb_ring *ring = &adapter->rx_ring[i];
+		struct igb_ring *ring = adapter->rx_ring[i];
 		igb_alloc_rx_buffers_adv(ring, igb_desc_unused(ring));
 	}
 
@@ -2148,19 +2147,19 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		err = igb_setup_tx_resources(&adapter->tx_ring[i]);
+		err = igb_setup_tx_resources(adapter->tx_ring[i]);
 		if (err) {
 			dev_err(&pdev->dev,
 				"Allocation for Tx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
-				igb_free_tx_resources(&adapter->tx_ring[i]);
+				igb_free_tx_resources(adapter->tx_ring[i]);
 			break;
 		}
 	}
 
 	for (i = 0; i < IGB_ABS_MAX_TX_QUEUES; i++) {
 		int r_idx = i % adapter->num_tx_queues;
-		adapter->multi_tx_table[i] = &adapter->tx_ring[r_idx];
+		adapter->multi_tx_table[i] = adapter->tx_ring[r_idx];
 	}
 	return err;
 }
@@ -2243,7 +2242,7 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_configure_tx_ring(adapter, &adapter->tx_ring[i]);
+		igb_configure_tx_ring(adapter, adapter->tx_ring[i]);
 }
 
 /**
@@ -2301,12 +2300,12 @@ static int igb_setup_all_rx_resources(struct igb_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = igb_setup_rx_resources(&adapter->rx_ring[i]);
+		err = igb_setup_rx_resources(adapter->rx_ring[i]);
 		if (err) {
 			dev_err(&pdev->dev,
 				"Allocation for Rx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
-				igb_free_rx_resources(&adapter->rx_ring[i]);
+				igb_free_rx_resources(adapter->rx_ring[i]);
 			break;
 		}
 	}
@@ -2634,7 +2633,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_configure_rx_ring(adapter, &adapter->rx_ring[i]);
+		igb_configure_rx_ring(adapter, adapter->rx_ring[i]);
 }
 
 /**
@@ -2671,7 +2670,7 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_free_tx_resources(&adapter->tx_ring[i]);
+		igb_free_tx_resources(adapter->tx_ring[i]);
 }
 
 void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
@@ -2738,7 +2737,7 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_ring(&adapter->tx_ring[i]);
+		igb_clean_tx_ring(adapter->tx_ring[i]);
 }
 
 /**
@@ -2775,7 +2774,7 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_free_rx_resources(&adapter->rx_ring[i]);
+		igb_free_rx_resources(adapter->rx_ring[i]);
 }
 
 /**
@@ -2839,7 +2838,7 @@ static void igb_clean_all_rx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_ring(&adapter->rx_ring[i]);
+		igb_clean_rx_ring(adapter->rx_ring[i]);
 }
 
 /**
@@ -3163,7 +3162,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	igb_update_adaptive(hw);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct igb_ring *tx_ring = &adapter->tx_ring[i];
+		struct igb_ring *tx_ring = adapter->tx_ring[i];
 		if (!netif_carrier_ok(netdev)) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
@@ -3359,13 +3358,13 @@ static void igb_set_itr(struct igb_adapter *adapter)
 
 	adapter->rx_itr = igb_update_itr(adapter,
 				    adapter->rx_itr,
-				    adapter->rx_ring->total_packets,
-				    adapter->rx_ring->total_bytes);
+				    q_vector->rx_ring->total_packets,
+				    q_vector->rx_ring->total_bytes);
 
 	adapter->tx_itr = igb_update_itr(adapter,
 				    adapter->tx_itr,
-				    adapter->tx_ring->total_packets,
-				    adapter->tx_ring->total_bytes);
+				    q_vector->tx_ring->total_packets,
+				    q_vector->tx_ring->total_bytes);
 	current_itr = max(adapter->rx_itr, adapter->tx_itr);
 
 	/* conservative mode (itr 3) eliminates the lowest_latency setting */
@@ -3388,10 +3387,10 @@ static void igb_set_itr(struct igb_adapter *adapter)
 	}
 
 set_itr_now:
-	adapter->rx_ring->total_bytes = 0;
-	adapter->rx_ring->total_packets = 0;
-	adapter->tx_ring->total_bytes = 0;
-	adapter->tx_ring->total_packets = 0;
+	q_vector->rx_ring->total_bytes = 0;
+	q_vector->rx_ring->total_packets = 0;
+	q_vector->tx_ring->total_bytes = 0;
+	q_vector->tx_ring->total_packets = 0;
 
 	if (new_itr != q_vector->itr_val) {
 		/* this attempts to bias the interrupt rate towards Bulk
@@ -3950,7 +3949,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->rx_ring[i].rx_buffer_len = rx_buffer_len;
+		adapter->rx_ring[i]->rx_buffer_len = rx_buffer_len;
 
 	if (netif_running(netdev))
 		igb_up(adapter);
@@ -3992,10 +3991,11 @@ void igb_update_stats(struct igb_adapter *adapter)
 	packets = 0;
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		u32 rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0x0FFF;
-		adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
+		struct igb_ring *ring = adapter->rx_ring[i];
+		ring->rx_stats.drops += rqdpc_tmp;
 		net_stats->rx_fifo_errors += rqdpc_tmp;
-		bytes += adapter->rx_ring[i].rx_stats.bytes;
-		packets += adapter->rx_ring[i].rx_stats.packets;
+		bytes += ring->rx_stats.bytes;
+		packets += ring->rx_stats.packets;
 	}
 
 	net_stats->rx_bytes = bytes;
@@ -4004,8 +4004,9 @@ void igb_update_stats(struct igb_adapter *adapter)
 	bytes = 0;
 	packets = 0;
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		bytes += adapter->tx_ring[i].tx_stats.bytes;
-		packets += adapter->tx_ring[i].tx_stats.packets;
+		struct igb_ring *ring = adapter->tx_ring[i];
+		bytes += ring->tx_stats.bytes;
+		packets += ring->tx_stats.packets;
 	}
 	net_stats->tx_bytes = bytes;
 	net_stats->tx_packets = packets;

