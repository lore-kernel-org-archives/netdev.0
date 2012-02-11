From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] ixgbe: Combine post-DMA processing of sk_buff fields into single function
Date: Fri, 10 Feb 2012 16:08:23 -0800
Message-ID: <1328918904-11511-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19397 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761180Ab2BKAIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:32 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change combines a number of post-DMA Rx packet processing functions
into a single function.  The advantage of this is that it combines most of
the Rx descriptor processing into one spot so it should all be warm in the
cache.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  127 +++++++++++++-----------
 2 files changed, 71 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 882a580..2807a25 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -190,6 +190,7 @@ struct ixgbe_rx_queue_stats {
 	u64 non_eop_descs;
 	u64 alloc_rx_page_failed;
 	u64 alloc_rx_buff_failed;
+	u64 csum_err;
 };
 
 enum ixbge_ring_state_t {
@@ -198,6 +199,7 @@ enum ixbge_ring_state_t {
 	__IXGBE_HANG_CHECK_ARMED,
 	__IXGBE_RX_PS_ENABLED,
 	__IXGBE_RX_RSC_ENABLED,
+	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
 };
 
 #define ring_is_ps_enabled(ring) \
@@ -379,7 +381,6 @@ struct ixgbe_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
 #define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 1)
 #define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 2)
 #define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 3)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 381d4dc..ac1d925 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -991,10 +991,12 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 }
 #endif /* CONFIG_IXGBE_DCA */
 
-static inline void ixgbe_rx_hash(union ixgbe_adv_rx_desc *rx_desc,
+static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
+				 union ixgbe_adv_rx_desc *rx_desc,
 				 struct sk_buff *skb)
 {
-	skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+	if (ring->netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
 }
 
 /**
@@ -1016,50 +1018,25 @@ static inline bool ixgbe_rx_is_fcoe(struct ixgbe_adapter *adapter,
 }
 
 /**
- * ixgbe_receive_skb - Send a completed packet up the stack
- * @adapter: board private structure
- * @skb: packet to send up
- * @rx_ring: rx descriptor ring (for a specific queue) to setup
- * @rx_desc: rx descriptor
- **/
-static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
-			      struct sk_buff *skb,
-			      struct ixgbe_ring *ring,
-			      union ixgbe_adv_rx_desc *rx_desc)
-{
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-
-	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
-		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
-		__vlan_hwaccel_put_tag(skb, vid);
-	}
-
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(&q_vector->napi, skb);
-	else
-		netif_rx(skb);
-}
-
-/**
  * ixgbe_rx_checksum - indicate in skb if hw indicated a good cksum
- * @adapter: address of board private structure
- * @status_err: hardware indication of status of receive
+ * @ring: structure containing ring specific data
+ * @rx_desc: current Rx descriptor being processed
  * @skb: skb currently being received and modified
  **/
-static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
+static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 				     union ixgbe_adv_rx_desc *rx_desc,
 				     struct sk_buff *skb)
 {
-	skb->ip_summed = CHECKSUM_NONE;
+	skb_checksum_none_assert(skb);
 
 	/* Rx csum disabled */
-	if (!(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
+	if (!(ring->netdev->features & NETIF_F_RXCSUM))
 		return;
 
 	/* if IP and error */
 	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_IPCS) &&
 	    ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_IPE)) {
-		adapter->hw_csum_rx_error++;
+		ring->rx_stats.csum_err++;
 		return;
 	}
 
@@ -1073,11 +1050,11 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 		 * 82599 errata, UDP frames with a 0 checksum can be marked as
 		 * checksum errors.
 		 */
-		if ((pkt_info & IXGBE_RXDADV_PKTTYPE_UDP) &&
-		    (adapter->hw.mac.type == ixgbe_mac_82599EB))
+		if ((pkt_info & cpu_to_le16(IXGBE_RXDADV_PKTTYPE_UDP)) &&
+		    test_bit(__IXGBE_RX_CSUM_UDP_ZERO_ERR, &ring->state))
 			return;
 
-		adapter->hw_csum_rx_error++;
+		ring->rx_stats.csum_err++;
 		return;
 	}
 
@@ -1115,9 +1092,6 @@ static bool ixgbe_alloc_mapped_skb(struct ixgbe_ring *rx_ring,
 			rx_ring->rx_stats.alloc_rx_buff_failed++;
 			return false;
 		}
-
-		/* initialize skb for ring */
-		skb_record_rx_queue(skb, rx_ring->queue_index);
 	}
 
 	dma = dma_map_single(rx_ring->dev, skb->data,
@@ -1451,17 +1425,58 @@ static void ixgbe_update_rsc_stats(struct ixgbe_ring *rx_ring,
 	IXGBE_CB(skb)->append_cnt = 0;
 }
 
+/**
+ * ixgbe_process_skb_fields - Populate skb header fields from Rx descriptor
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being populated
+ *
+ * This function checks the ring, descriptor, and packet information in
+ * order to populate the hash, checksum, VLAN, timestamp, protocol, and
+ * other fields within the skb.
+ **/
+static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
+				     union ixgbe_adv_rx_desc *rx_desc,
+				     struct sk_buff *skb)
+{
+	ixgbe_update_rsc_stats(rx_ring, skb);
+
+	ixgbe_rx_hash(rx_ring, rx_desc, skb);
+
+	ixgbe_rx_checksum(rx_ring, rx_desc, skb);
+
+	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
+		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
+
+	skb_record_rx_queue(skb, rx_ring->queue_index);
+
+	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+}
+
+static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
+			 struct sk_buff *skb)
+{
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+
+	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+		napi_gro_receive(&q_vector->napi, skb);
+	else
+		netif_rx(skb);
+}
+
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *rx_ring,
 			       int budget)
 {
-	struct ixgbe_adapter *adapter = q_vector->adapter;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info;
 	struct sk_buff *skb;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	const int current_node = numa_node_id();
 #ifdef IXGBE_FCOE
+	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int ddp_bytes = 0;
 #endif /* IXGBE_FCOE */
 	u16 i;
@@ -1588,8 +1603,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbe_update_rsc_stats(rx_ring, skb);
-
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(ixgbe_test_staterr(rx_desc,
 					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
@@ -1597,15 +1610,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbe_rx_checksum(adapter, rx_desc, skb);
-		if (adapter->netdev->features & NETIF_F_RXHASH)
-			ixgbe_rx_hash(rx_desc, skb);
-
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+		/* populate checksum, timestamp, VLAN, and protocol */
+		ixgbe_process_skb_fields(rx_ring, rx_desc, skb);
+
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
 		if (ixgbe_rx_is_fcoe(adapter, rx_desc)) {
@@ -1616,7 +1627,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			}
 		}
 #endif /* IXGBE_FCOE */
-		ixgbe_receive_skb(q_vector, skb, rx_ring, rx_desc);
+		ixgbe_rx_skb(q_vector, skb);
 
 		budget--;
 next_desc:
@@ -4851,6 +4862,13 @@ static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
 
+		/*
+		 * 82599 errata, UDP frames with a 0 checksum can be marked as
+		 * checksum errors.
+		 */
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			set_bit(__IXGBE_RX_CSUM_UDP_ZERO_ERR, &ring->state);
+
 		adapter->rx_ring[rx] = ring;
 	}
 
@@ -5255,9 +5273,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
-	/* enable rx csum by default */
-	adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
-
 	/* get assigned NUMA node */
 	adapter->node = dev_to_node(&pdev->dev);
 
@@ -5748,7 +5763,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 	u64 non_eop_descs = 0, restart_queue = 0, tx_busy = 0;
 	u64 alloc_rx_page_failed = 0, alloc_rx_buff_failed = 0;
-	u64 bytes = 0, packets = 0;
+	u64 bytes = 0, packets = 0, hw_csum_rx_error = 0;
 #ifdef IXGBE_FCOE
 	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 	unsigned int cpu;
@@ -5778,12 +5793,14 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		non_eop_descs += rx_ring->rx_stats.non_eop_descs;
 		alloc_rx_page_failed += rx_ring->rx_stats.alloc_rx_page_failed;
 		alloc_rx_buff_failed += rx_ring->rx_stats.alloc_rx_buff_failed;
+		hw_csum_rx_error += rx_ring->rx_stats.csum_err;
 		bytes += rx_ring->stats.bytes;
 		packets += rx_ring->stats.packets;
 	}
 	adapter->non_eop_descs = non_eop_descs;
 	adapter->alloc_rx_page_failed = alloc_rx_page_failed;
 	adapter->alloc_rx_buff_failed = alloc_rx_buff_failed;
+	adapter->hw_csum_rx_error = hw_csum_rx_error;
 	netdev->stats.rx_bytes = bytes;
 	netdev->stats.rx_packets = packets;
 
@@ -7412,12 +7429,6 @@ static int ixgbe_set_features(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	bool need_reset = false;
 
-	/* If Rx checksum is disabled, then RSC/LRO should also be disabled */
-	if (!(data & NETIF_F_RXCSUM))
-		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
-
 	/* Make sure RSC matches LRO, reset if change */
 	if (!!(data & NETIF_F_LRO) !=
 	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
-- 
1.7.7.6
