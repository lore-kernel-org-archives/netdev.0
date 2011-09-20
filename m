From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] igb: drop the "adv" off function names relating to descriptors
Date: Tue, 20 Sep 2011 00:11:28 -0700
Message-ID: <1316502690-25488-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19158 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288Ab1ITHLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 03:11:36 -0400
In-Reply-To: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Many of the function names in the hot path are carrying an extra "_adv"
suffix on the end of them to represent the fact that they are using
advanced descriptors instead of legacy descriptors.  However since all igb
uses are advanced descriptors adding the extra suffix doesn't really add
any additional data.  Since this is the case it is easiest to just drop the
suffix and save us from having to store the extra characters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |    4 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    6 +-
 drivers/net/ethernet/intel/igb/igb_main.c    |   62 +++++++++++++-------------
 3 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 7036fd5..b1ca8ea 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -374,10 +374,10 @@ extern void igb_configure_tx_ring(struct igb_adapter *, struct igb_ring *);
 extern void igb_configure_rx_ring(struct igb_adapter *, struct igb_ring *);
 extern void igb_setup_tctl(struct igb_adapter *);
 extern void igb_setup_rctl(struct igb_adapter *);
-extern netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *, struct igb_ring *);
+extern netdev_tx_t igb_xmit_frame_ring(struct sk_buff *, struct igb_ring *);
 extern void igb_unmap_and_free_tx_resource(struct igb_ring *,
 					   struct igb_buffer *);
-extern void igb_alloc_rx_buffers_adv(struct igb_ring *, u16);
+extern void igb_alloc_rx_buffers(struct igb_ring *, u16);
 extern void igb_update_stats(struct igb_adapter *, struct rtnl_link_stats64 *);
 extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 04bc7a5..67eee0a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1382,7 +1382,7 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 	igb_setup_rctl(adapter);
 	igb_configure_rx_ring(adapter, rx_ring);
 
-	igb_alloc_rx_buffers_adv(rx_ring, igb_desc_unused(rx_ring));
+	igb_alloc_rx_buffers(rx_ring, igb_desc_unused(rx_ring));
 
 	return 0;
 
@@ -1622,7 +1622,7 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 	}
 
 	/* re-map buffers to ring, store next to clean values */
-	igb_alloc_rx_buffers_adv(rx_ring, count);
+	igb_alloc_rx_buffers(rx_ring, count);
 	rx_ring->next_to_clean = rx_ntc;
 	tx_ring->next_to_clean = tx_ntc;
 
@@ -1665,7 +1665,7 @@ static int igb_run_loopback_test(struct igb_adapter *adapter)
 		/* place 64 packets on the transmit queue*/
 		for (i = 0; i < 64; i++) {
 			skb_get(skb);
-			tx_ret_val = igb_xmit_frame_ring_adv(skb, tx_ring);
+			tx_ret_val = igb_xmit_frame_ring(skb, tx_ring);
 			if (tx_ret_val == NETDEV_TX_OK)
 				good_cnt++;
 		}
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index dd85df0..9a0cfd6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -122,7 +122,7 @@ static void igb_set_rx_mode(struct net_device *);
 static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
-static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *);
+static netdev_tx_t igb_xmit_frame(struct sk_buff *skb, struct net_device *);
 static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *dev,
 						 struct rtnl_link_stats64 *stats);
 static int igb_change_mtu(struct net_device *, int);
@@ -138,7 +138,7 @@ static void igb_setup_dca(struct igb_adapter *);
 #endif /* CONFIG_IGB_DCA */
 static bool igb_clean_tx_irq(struct igb_q_vector *);
 static int igb_poll(struct napi_struct *, int);
-static bool igb_clean_rx_irq_adv(struct igb_q_vector *, int);
+static bool igb_clean_rx_irq(struct igb_q_vector *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -1436,7 +1436,7 @@ static void igb_configure(struct igb_adapter *adapter)
 	 * next_to_use != next_to_clean */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = adapter->rx_ring[i];
-		igb_alloc_rx_buffers_adv(ring, igb_desc_unused(ring));
+		igb_alloc_rx_buffers(ring, igb_desc_unused(ring));
 	}
 }
 
@@ -1784,7 +1784,7 @@ static int igb_set_features(struct net_device *netdev, u32 features)
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
-	.ndo_start_xmit		= igb_xmit_frame_adv,
+	.ndo_start_xmit		= igb_xmit_frame,
 	.ndo_get_stats64	= igb_get_stats64,
 	.ndo_set_rx_mode	= igb_set_rx_mode,
 	.ndo_set_mac_address	= igb_set_mac,
@@ -3955,8 +3955,8 @@ set_itr_now:
 #define IGB_TX_FLAGS_VLAN_MASK		0xffff0000
 #define IGB_TX_FLAGS_VLAN_SHIFT		        16
 
-static inline int igb_tso_adv(struct igb_ring *tx_ring,
-			      struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+static inline int igb_tso(struct igb_ring *tx_ring,
+			  struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -4035,8 +4035,8 @@ static inline int igb_tso_adv(struct igb_ring *tx_ring,
 	return true;
 }
 
-static inline bool igb_tx_csum_adv(struct igb_ring *tx_ring,
-				   struct sk_buff *skb, u32 tx_flags)
+static inline bool igb_tx_csum(struct igb_ring *tx_ring,
+			       struct sk_buff *skb, u32 tx_flags)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	struct device *dev = tx_ring->dev;
@@ -4120,8 +4120,8 @@ static inline bool igb_tx_csum_adv(struct igb_ring *tx_ring,
 #define IGB_MAX_TXD_PWR	16
 #define IGB_MAX_DATA_PER_TXD	(1<<IGB_MAX_TXD_PWR)
 
-static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
-				 unsigned int first)
+static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
+			     unsigned int first)
 {
 	struct igb_buffer *buffer_info;
 	struct device *dev = tx_ring->dev;
@@ -4196,9 +4196,9 @@ dma_error:
 	return 0;
 }
 
-static inline void igb_tx_queue_adv(struct igb_ring *tx_ring,
-				    u32 tx_flags, int count, u32 paylen,
-				    u8 hdr_len)
+static inline void igb_tx_queue(struct igb_ring *tx_ring,
+				u32 tx_flags, int count, u32 paylen,
+				u8 hdr_len)
 {
 	union e1000_adv_tx_desc *tx_desc;
 	struct igb_buffer *buffer_info;
@@ -4296,8 +4296,8 @@ static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 	return __igb_maybe_stop_tx(tx_ring, size);
 }
 
-netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
-				    struct igb_ring *tx_ring)
+netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
+				struct igb_ring *tx_ring)
 {
 	int tso = 0, count;
 	u32 tx_flags = 0;
@@ -4329,7 +4329,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 
 	first = tx_ring->next_to_use;
 	if (skb_is_gso(skb)) {
-		tso = igb_tso_adv(tx_ring, skb, tx_flags, &hdr_len);
+		tso = igb_tso(tx_ring, skb, tx_flags, &hdr_len);
 
 		if (tso < 0) {
 			dev_kfree_skb_any(skb);
@@ -4339,7 +4339,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 
 	if (tso)
 		tx_flags |= IGB_TX_FLAGS_TSO;
-	else if (igb_tx_csum_adv(tx_ring, skb, tx_flags) &&
+	else if (igb_tx_csum(tx_ring, skb, tx_flags) &&
 	         (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IGB_TX_FLAGS_CSUM;
 
@@ -4347,7 +4347,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	 * count reflects descriptors mapped, if 0 or less then mapping error
 	 * has occurred and we need to rewind the descriptor queue
 	 */
-	count = igb_tx_map_adv(tx_ring, skb, first);
+	count = igb_tx_map(tx_ring, skb, first);
 	if (!count) {
 		dev_kfree_skb_any(skb);
 		tx_ring->buffer_info[first].time_stamp = 0;
@@ -4355,7 +4355,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	igb_tx_queue_adv(tx_ring, tx_flags, count, skb->len, hdr_len);
+	igb_tx_queue(tx_ring, tx_flags, count, skb->len, hdr_len);
 
 	/* Make sure there is space in the ring for the next send. */
 	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS + 4);
@@ -4363,8 +4363,8 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
-				      struct net_device *netdev)
+static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
+				  struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct igb_ring *tx_ring;
@@ -4387,7 +4387,7 @@ static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
 	 * to a flow.  Right now, performance is impacted slightly negatively
 	 * if using multiple tx queues.  If the stack breaks away from a
 	 * single qdisc implementation, we can look at this again. */
-	return igb_xmit_frame_ring_adv(skb, tx_ring);
+	return igb_xmit_frame_ring(skb, tx_ring);
 }
 
 /**
@@ -5491,7 +5491,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 		clean_complete = !!igb_clean_tx_irq(q_vector);
 
 	if (q_vector->rx_ring)
-		clean_complete &= igb_clean_rx_irq_adv(q_vector, budget);
+		clean_complete &= igb_clean_rx_irq(q_vector, budget);
 
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
@@ -5670,8 +5670,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	return count < tx_ring->count;
 }
 
-static inline void igb_rx_checksum_adv(struct igb_ring *ring,
-				       u32 status_err, struct sk_buff *skb)
+static inline void igb_rx_checksum(struct igb_ring *ring,
+				   u32 status_err, struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
 
@@ -5750,7 +5750,7 @@ static inline u16 igb_get_hlen(union e1000_adv_rx_desc *rx_desc)
 	return hlen;
 }
 
-static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector, int budget)
+static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 {
 	struct igb_ring *rx_ring = q_vector->rx_ring;
 	union e1000_adv_rx_desc *rx_desc;
@@ -5836,7 +5836,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector, int budget)
 		total_bytes += skb->len;
 		total_packets++;
 
-		igb_rx_checksum_adv(rx_ring, staterr, skb);
+		igb_rx_checksum(rx_ring, staterr, skb);
 
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 
@@ -5855,7 +5855,7 @@ next_desc:
 		cleaned_count++;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IGB_RX_BUFFER_WRITE) {
-			igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
+			igb_alloc_rx_buffers(rx_ring, cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -5873,7 +5873,7 @@ next_desc:
 	rx_ring->total_bytes += total_bytes;
 
 	if (cleaned_count)
-		igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
+		igb_alloc_rx_buffers(rx_ring, cleaned_count);
 
 	return !!budget;
 }
@@ -5946,10 +5946,10 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 }
 
 /**
- * igb_alloc_rx_buffers_adv - Replace used receive buffers; packet split
+ * igb_alloc_rx_buffers - Replace used receive buffers; packet split
  * @adapter: address of board private structure
  **/
-void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, u16 cleaned_count)
+void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 {
 	union e1000_adv_rx_desc *rx_desc;
 	struct igb_buffer *bi;
-- 
1.7.6.2
