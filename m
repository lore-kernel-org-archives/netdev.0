From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH v2 08/10] ixgbe: Update ixgbe driver to use
 __netdev_pick_tx in ixgbe_select_queue
Date: Thu, 10 Jan 2013 10:58:30 -0800
Message-ID: <20130110185817.29578.27780.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35072 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754756Ab3AJTAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 14:00:05 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change updates the ixgbe driver to use __netdev_pick_tx instead of
the current logic it is using to select a queue.  The main result of this
change is that ixgbe can now fully support XPS, and in the case of non-FCoE
enabled configs it means we don't need to have our own ndo_select_queue.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   48 ++++++++++++++-----------
 1 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8ca9794..4c0bcd8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6363,38 +6363,40 @@ static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 	return __ixgbe_maybe_stop_tx(tx_ring, size);
 }
 
+#ifdef IXGBE_FCOE
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
-					       smp_processor_id();
-#ifdef IXGBE_FCOE
-	__be16 protocol = vlan_get_protocol(skb);
+	struct ixgbe_adapter *adapter;
+	struct ixgbe_ring_feature *f;
+	int txq;
 
-	if (((protocol == htons(ETH_P_FCOE)) ||
-	    (protocol == htons(ETH_P_FIP))) &&
-	    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
-		struct ixgbe_ring_feature *f;
+	/*
+	 * only execute the code below if protocol is FCoE
+	 * or FIP and we have FCoE enabled on the adapter
+	 */
+	switch (vlan_get_protocol(skb)) {
+	case __constant_htons(ETH_P_FCOE):
+	case __constant_htons(ETH_P_FIP):
+		adapter = netdev_priv(dev);
 
-		f = &adapter->ring_feature[RING_F_FCOE];
+		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+			break;
+	default:
+		return __netdev_pick_tx(dev, skb);
+	}
 
-		while (txq >= f->indices)
-			txq -= f->indices;
-		txq += adapter->ring_feature[RING_F_FCOE].offset;
+	f = &adapter->ring_feature[RING_F_FCOE];
 
-		return txq;
-	}
-#endif
+	txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
+					   smp_processor_id();
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-		while (unlikely(txq >= dev->real_num_tx_queues))
-			txq -= dev->real_num_tx_queues;
-		return txq;
-	}
+	while (txq >= f->indices)
+		txq -= f->indices;
 
-	return skb_tx_hash(dev, skb);
+	return txq + f->offset;
 }
 
+#endif
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
@@ -7092,7 +7094,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
+#ifdef IXGBE_FCOE
 	.ndo_select_queue	= ixgbe_select_queue,
+#endif
 	.ndo_set_rx_mode	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbe_set_mac,
