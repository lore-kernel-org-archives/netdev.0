From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] igb: Consolidate all of the ring feature flags into a single value
Date: Fri,  7 Oct 2011 23:47:34 -0700
Message-ID: <1318056461-19562-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6789 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554Ab1JHGrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 02:47:46 -0400
In-Reply-To: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves all of the ring flags into a single value.  The advantage
to this is that there is one central area for all of these flags and they
can all make use of the set/test bit operations.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |   10 ++++++----
 drivers/net/ethernet/intel/igb/igb_main.c |   23 +++++++++++++----------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9e4bed3..0df040a 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -237,10 +237,12 @@ struct igb_ring {
 	int numa_node;                  /* node to alloc ring memory on */
 };
 
-#define IGB_RING_FLAG_RX_CSUM        0x00000001 /* RX CSUM enabled */
-#define IGB_RING_FLAG_RX_SCTP_CSUM   0x00000002 /* SCTP CSUM offload enabled */
-
-#define IGB_RING_FLAG_TX_CTX_IDX     0x00000001 /* HW requires context index */
+enum e1000_ring_flags_t {
+	IGB_RING_FLAG_RX_CSUM,
+	IGB_RING_FLAG_RX_SCTP_CSUM,
+	IGB_RING_FLAG_TX_CTX_IDX,
+	IGB_RING_FLAG_TX_DETECT_HANG
+};
 
 #define IGB_TXD_DCMD (E1000_ADVTXD_DCMD_EOP | E1000_ADVTXD_DCMD_RS)
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3a5c75d..f339de9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -708,7 +708,7 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		ring->numa_node = adapter->node;
 		/* For 82575, context index must be unique per ring. */
 		if (adapter->hw.mac.type == e1000_82575)
-			ring->flags = IGB_RING_FLAG_TX_CTX_IDX;
+			set_bit(IGB_RING_FLAG_TX_CTX_IDX, &ring->flags);
 		adapter->tx_ring[i] = ring;
 	}
 	/* Restore the adapter's original node */
@@ -732,10 +732,11 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
 		ring->numa_node = adapter->node;
-		ring->flags = IGB_RING_FLAG_RX_CSUM; /* enable rx checksum */
+		/* enable rx checksum */
+		set_bit(IGB_RING_FLAG_RX_CSUM, &ring->flags);
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
-			ring->flags |= IGB_RING_FLAG_RX_SCTP_CSUM;
+			set_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags);
 		adapter->rx_ring[i] = ring;
 	}
 	/* Restore the adapter's original node */
@@ -1822,9 +1823,11 @@ static int igb_set_features(struct net_device *netdev, u32 features)
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		if (features & NETIF_F_RXCSUM)
-			adapter->rx_ring[i]->flags |= IGB_RING_FLAG_RX_CSUM;
+			set_bit(IGB_RING_FLAG_RX_CSUM,
+				&adapter->rx_ring[i]->flags);
 		else
-			adapter->rx_ring[i]->flags &= ~IGB_RING_FLAG_RX_CSUM;
+			clear_bit(IGB_RING_FLAG_RX_CSUM,
+				  &adapter->rx_ring[i]->flags);
 	}
 
 	if (changed & NETIF_F_HW_VLAN_RX)
@@ -4035,7 +4038,7 @@ void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
 	type_tucmd |= E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT;
 
 	/* For 82575, context index must be unique per ring. */
-	if (tx_ring->flags & IGB_RING_FLAG_TX_CTX_IDX)
+	if (test_bit(IGB_RING_FLAG_TX_CTX_IDX, &tx_ring->flags))
 		mss_l4len_idx |= tx_ring->reg_idx << 4;
 
 	context_desc->vlan_macip_lens	= cpu_to_le32(vlan_macip_lens);
@@ -4202,7 +4205,7 @@ static void igb_tx_olinfo_status(struct igb_ring *tx_ring,
 
 	/* 82575 requires a unique index per ring if any offload is enabled */
 	if ((tx_flags & (IGB_TX_FLAGS_CSUM | IGB_TX_FLAGS_VLAN)) &&
-	    (tx_ring->flags & IGB_RING_FLAG_TX_CTX_IDX))
+	    test_bit(IGB_RING_FLAG_TX_CTX_IDX, &tx_ring->flags))
 		olinfo_status |= tx_ring->reg_idx << 4;
 
 	/* insert L4 checksum */
@@ -5828,7 +5831,7 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 	skb_checksum_none_assert(skb);
 
 	/* Ignore Checksum bit is set or checksum is disabled through ethtool */
-	if (!(ring->flags & IGB_RING_FLAG_RX_CSUM) ||
+	if (!test_bit(IGB_RING_FLAG_RX_CSUM, &ring->flags) ||
 	     (status_err & E1000_RXD_STAT_IXSM))
 		return;
 
@@ -5840,8 +5843,8 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 		 * L4E bit is set incorrectly on 64 byte (60 byte w/o crc)
 		 * packets, (aka let the stack check the crc32c)
 		 */
-		if ((skb->len == 60) &&
-		    (ring->flags & IGB_RING_FLAG_RX_SCTP_CSUM)) {
+		if (!((skb->len == 60) &&
+		      test_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags))) {
 			u64_stats_update_begin(&ring->rx_syncp);
 			ring->rx_stats.csum_err++;
 			u64_stats_update_end(&ring->rx_syncp);
-- 
1.7.6.4
