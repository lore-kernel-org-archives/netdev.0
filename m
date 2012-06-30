From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 08/10] ixgbe: Update ixgbe driver to use __dev_pick_tx in
	ixgbe_select_queue
Date: Fri, 29 Jun 2012 17:16:54 -0700
Message-ID: <20120630001654.29939.18661.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1752 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755693Ab2F3AQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:16:35 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change updates the ixgbe driver to use __dev_pick_tx instead of the
current logic it is using to select a queue.  The main result of this
change is that ixgbe can now fully support XPS.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 06641ea..0b35ec3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6336,18 +6336,18 @@ static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 	return __ixgbe_maybe_stop_tx(tx_ring, size);
 }
 
+#ifdef IXGBE_FCOE
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
-					       smp_processor_id();
-#ifdef IXGBE_FCOE
 	__be16 protocol = vlan_get_protocol(skb);
 
 	if (((protocol == htons(ETH_P_FCOE)) ||
 	    (protocol == htons(ETH_P_FIP))) &&
 	    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
 		struct ixgbe_ring_feature *f;
+		int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
+						       smp_processor_id();
 
 		f = &adapter->ring_feature[RING_F_FCOE];
 
@@ -6357,17 +6357,11 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 
 		return txq;
 	}
-#endif
-
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-		while (unlikely(txq >= dev->real_num_tx_queues))
-			txq -= dev->real_num_tx_queues;
-		return txq;
-	}
 
-	return skb_tx_hash(dev, skb);
+	return __dev_pick_tx(dev, skb);
 }
 
+#endif
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
@@ -7013,7 +7007,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
+#ifdef IXGBE_FCOE
 	.ndo_select_queue	= ixgbe_select_queue,
+#endif
 	.ndo_set_rx_mode	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbe_set_mac,
