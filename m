From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbevf: Add netdev to ring structure
Date: Wed, 18 Jul 2012 13:31:50 -0700
Message-ID: <1342643516-2696-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976Ab2GRUcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:01 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds the netdev to the ring structure.  This allows for a
quicker transition from ring to netdev without having to go from ring to
adapter to netdev.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    6 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   54 +++++++++------------
 3 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 15947c9..2c3b20ed 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -359,8 +359,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 		if (err) {
 			while (i) {
 				i--;
-				ixgbevf_free_tx_resources(adapter,
-							  &tx_ring[i]);
+				ixgbevf_free_tx_resources(adapter, &tx_ring[i]);
 			}
 			goto err_tx_ring_setup;
 		}
@@ -374,8 +373,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 		if (err) {
 			while (i) {
 				i--;
-				ixgbevf_free_rx_resources(adapter,
-							  &rx_ring[i]);
+				ixgbevf_free_rx_resources(adapter, &rx_ring[i]);
 			}
 				goto err_rx_ring_setup;
 		}
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 1f13765..e167d1b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -56,6 +56,8 @@ struct ixgbevf_rx_buffer {
 
 struct ixgbevf_ring {
 	struct ixgbevf_ring *next;
+	struct net_device *netdev;
+	struct device *dev;
 	struct ixgbevf_adapter *adapter;  /* backlink */
 	void *desc;			/* descriptor ring memory */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c27ce44..1c53e13 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -187,7 +187,6 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 				 struct ixgbevf_ring *tx_ring)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
-	struct net_device *netdev = adapter->netdev;
 	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
 	struct ixgbevf_tx_buffer *tx_buffer_info;
 	unsigned int i, eop, count = 0;
@@ -241,15 +240,17 @@ cont_loop:
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
-	if (unlikely(count && netif_carrier_ok(netdev) &&
+	if (unlikely(count && netif_carrier_ok(tx_ring->netdev) &&
 		     (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
+		if (__netif_subqueue_stopped(tx_ring->netdev,
+					     tx_ring->queue_index) &&
 		    !test_bit(__IXGBEVF_DOWN, &adapter->state)) {
-			netif_wake_subqueue(netdev, tx_ring->queue_index);
+			netif_wake_subqueue(tx_ring->netdev,
+					    tx_ring->queue_index);
 			++adapter->restart_queue;
 		}
 	}
@@ -292,12 +293,13 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
  * @skb: skb currently being received and modified
  **/
 static inline void ixgbevf_rx_checksum(struct ixgbevf_adapter *adapter,
+				       struct ixgbevf_ring *ring,
 				       u32 status_err, struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
 
 	/* Rx csum disabled */
-	if (!(adapter->netdev->features & NETIF_F_RXCSUM))
+	if (!(ring->netdev->features & NETIF_F_RXCSUM))
 		return;
 
 	/* if IP and error */
@@ -332,31 +334,21 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbevf_rx_buffer *bi;
 	struct sk_buff *skb;
-	unsigned int i;
-	unsigned int bufsz = rx_ring->rx_buf_len + NET_IP_ALIGN;
+	unsigned int i = rx_ring->next_to_use;
 
-	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
 
 	while (cleaned_count--) {
 		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
 		skb = bi->skb;
 		if (!skb) {
-			skb = netdev_alloc_skb(adapter->netdev,
-							       bufsz);
-
+			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+							rx_ring->rx_buf_len);
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
 				goto no_buffers;
 			}
 
-			/*
-			 * Make buffer alignment 2 beyond a 16 byte boundary
-			 * this will result in a 16 byte aligned IP header after
-			 * the 14 byte MAC header is removed
-			 */
-			skb_reserve(skb, NET_IP_ALIGN);
-
 			bi->skb = skb;
 		}
 		if (!bi->dma) {
@@ -449,7 +441,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbevf_rx_checksum(adapter, staterr, skb);
+		ixgbevf_rx_checksum(adapter, rx_ring, staterr, skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
@@ -464,7 +456,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			if (header_fixup_len < 14)
 				skb_push(skb, header_fixup_len);
 		}
-		skb->protocol = eth_type_trans(skb, adapter->netdev);
+		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 
 		ixgbevf_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
 
@@ -1669,12 +1661,16 @@ static int ixgbevf_alloc_queues(struct ixgbevf_adapter *adapter)
 		adapter->tx_ring[i].count = adapter->tx_ring_count;
 		adapter->tx_ring[i].queue_index = i;
 		adapter->tx_ring[i].reg_idx = i;
+		adapter->tx_ring[i].dev = &adapter->pdev->dev;
+		adapter->tx_ring[i].netdev = adapter->netdev;
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		adapter->rx_ring[i].count = adapter->rx_ring_count;
 		adapter->rx_ring[i].queue_index = i;
 		adapter->rx_ring[i].reg_idx = i;
+		adapter->rx_ring[i].dev = &adapter->pdev->dev;
+		adapter->rx_ring[i].netdev = adapter->netdev;
 	}
 
 	return 0;
@@ -2721,12 +2717,11 @@ static void ixgbevf_tx_queue(struct ixgbevf_adapter *adapter,
 	writel(i, adapter->hw.hw_addr + tx_ring->tail);
 }
 
-static int __ixgbevf_maybe_stop_tx(struct net_device *netdev,
-				   struct ixgbevf_ring *tx_ring, int size)
+static int __ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
 {
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbevf_adapter *adapter = netdev_priv(tx_ring->netdev);
 
-	netif_stop_subqueue(netdev, tx_ring->queue_index);
+	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -2738,17 +2733,16 @@ static int __ixgbevf_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(netdev, tx_ring->queue_index);
+	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
 	++adapter->restart_queue;
 	return 0;
 }
 
-static int ixgbevf_maybe_stop_tx(struct net_device *netdev,
-				 struct ixgbevf_ring *tx_ring, int size)
+static int ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
 {
 	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
 		return 0;
-	return __ixgbevf_maybe_stop_tx(netdev, tx_ring, size);
+	return __ixgbevf_maybe_stop_tx(tx_ring, size);
 }
 
 static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -2779,7 +2773,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 #else
 	count += skb_shinfo(skb)->nr_frags;
 #endif
-	if (ixgbevf_maybe_stop_tx(netdev, tx_ring, count + 3)) {
+	if (ixgbevf_maybe_stop_tx(tx_ring, count + 3)) {
 		adapter->tx_busy++;
 		return NETDEV_TX_BUSY;
 	}
@@ -2810,7 +2804,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			 ixgbevf_tx_map(adapter, tx_ring, skb, tx_flags, first),
 			 skb->len, hdr_len);
 
-	ixgbevf_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
+	ixgbevf_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
