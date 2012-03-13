From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: add support for byte queue limits
Date: Mon, 12 Mar 2012 21:03:41 -0700
Message-ID: <1331611432-30109-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab2CMED5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:03:57 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This adds support for byte queue limits (BQL).

Based on patch from Eric Dumazet for igb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 +++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 2807a25..f05bfdb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -643,4 +643,9 @@ extern int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
 				  struct netdev_fcoe_hbainfo *info);
 #endif /* IXGBE_FCOE */
 
+static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
+{
+	return netdev_get_tx_queue(ring->netdev, ring->queue_index);
+}
+
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 23a4665..0609643 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -840,6 +840,9 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		return true;
 	}
 
+	netdev_tx_completed_queue(txring_txq(tx_ring),
+				  total_packets, total_bytes);
+
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
 	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
 		     (ixgbe_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
@@ -2617,6 +2620,8 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	/* enable queue */
 	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), txdctl);
 
+	netdev_tx_reset_queue(txring_txq(ring));
+
 	/* TXDCTL.EN will return 0 on 82598 if link is down, so skip it */
 	if (hw->mac.type == ixgbe_mac_82598EB &&
 	    !(IXGBE_READ_REG(hw, IXGBE_LINKS) & IXGBE_LINKS_UP))
@@ -6808,6 +6813,8 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	tx_buffer_info->gso_segs = gso_segs;
 	tx_buffer_info->skb = skb;
 
+	netdev_tx_sent_queue(txring_txq(tx_ring), tx_buffer_info->bytecount);
+
 	/* set the timestamp */
 	first->time_stamp = jiffies;
 
-- 
1.7.7.6
