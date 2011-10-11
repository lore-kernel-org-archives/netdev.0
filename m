From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] igb: retire the RX_CSUM flag and use the netdev flag instead
Date: Tue, 11 Oct 2011 08:45:48 -0700
Message-ID: <1318347952-25068-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33975 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754884Ab1JKPp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:45:57 -0400
In-Reply-To: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index e0dea22..8a15d43 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -243,7 +243,6 @@ struct igb_ring {
 };
 
 enum e1000_ring_flags_t {
-	IGB_RING_FLAG_RX_CSUM,
 	IGB_RING_FLAG_RX_SCTP_CSUM,
 	IGB_RING_FLAG_TX_CTX_IDX,
 	IGB_RING_FLAG_TX_DETECT_HANG
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bcc1c28..33b250f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -709,8 +709,6 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		ring->queue_index = i;
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
-		/* enable rx checksum */
-		set_bit(IGB_RING_FLAG_RX_CSUM, &ring->flags);
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
 			set_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags);
@@ -1764,19 +1762,8 @@ static u32 igb_fix_features(struct net_device *netdev, u32 features)
 
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
 
@@ -5737,9 +5724,12 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
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
