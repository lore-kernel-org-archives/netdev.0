From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] igb: retire the RX_CSUM flag and use the netdev flag instead
Date: Fri,  7 Oct 2011 23:47:37 -0700
Message-ID: <1318056461-19562-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:16687 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751450Ab1JHGrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 02:47:48 -0400
In-Reply-To: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since the netdev now has its' own checksum flag to indicate if Rx checksum
is enabled we might as well use that instead of using the ring flag.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    1 -
 drivers/net/ethernet/intel/igb/igb_main.c |   22 ++++++----------------
 2 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 91f90fe..fde381a 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -245,7 +245,6 @@ struct igb_ring {
 };
 
 enum e1000_ring_flags_t {
-	IGB_RING_FLAG_RX_CSUM,
 	IGB_RING_FLAG_RX_SCTP_CSUM,
 	IGB_RING_FLAG_TX_CTX_IDX,
 	IGB_RING_FLAG_TX_DETECT_HANG
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ec715f4..cae4abb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -732,8 +732,6 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
 		ring->numa_node = adapter->node;
-		/* enable rx checksum */
-		set_bit(IGB_RING_FLAG_RX_CSUM, &ring->flags);
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
 			set_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags);
@@ -1811,19 +1809,8 @@ static u32 igb_fix_features(struct net_device *netdev, u32 features)
 
 static int igb_set_features(struct net_device *netdev, u32 features)
 {
-	struct igb_adapter *adapter = netdev_priv(netdev);
-	int i;
 	u32 changed = netdev->features ^ features;
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		if (features & NETIF_F_RXCSUM)
-			set_bit(IGB_RING_FLAG_RX_CSUM,
-				&adapter->rx_ring[i]->flags);
-		else
-			clear_bit(IGB_RING_FLAG_RX_CSUM,
-				  &adapter->rx_ring[i]->flags);
-	}
-
 	if (changed & NETIF_F_HW_VLAN_RX)
 		igb_vlan_mode(netdev, features);
 
@@ -5807,9 +5794,12 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 {
 	skb_checksum_none_assert(skb);
 
-	/* Ignore Checksum bit is set or checksum is disabled through ethtool */
-	if (!test_bit(IGB_RING_FLAG_RX_CSUM, &ring->flags) ||
-	     (status_err & E1000_RXD_STAT_IXSM))
+	/* Ignore Checksum bit is set */
+	if (status_err & E1000_RXD_STAT_IXSM)
+		return;
+
+	/* Rx checksum disabled via ethtool */
+	if (!(ring->netdev->features & NETIF_F_RXCSUM))
 		return;
 
 	/* TCP/UDP checksum error bit is set */
-- 
1.7.6.4
