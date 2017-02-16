From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] ixgbe: Use length to determine if descriptor is done
Date: Thu, 16 Feb 2017 04:50:36 -0800
Message-ID: <20170216125041.46668-10-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29436 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754715AbdBPMur (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:47 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we use the length of the packet instead of the
DD status bit to determine if a new descriptor is ready to be processed.
The obvious advantage is that it cuts down on reads as we don't really even
need the DD bit if going from a 0 to a non-zero value on size is enough to
inform us that the packet has been completed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 14 ++++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 04f15092ae31..51a1695a75ee 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1868,7 +1868,7 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 	tx_ntc = tx_ring->next_to_clean;
 	rx_desc = IXGBE_RX_DESC(rx_ring, rx_ntc);
 
-	while (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_DD)) {
+	while (rx_desc->wb.upper.length) {
 		/* check Rx buffer */
 		rx_buffer = &rx_ring->rx_buffer_info[rx_ntc];
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 415e5ad1485a..6fc26cdacba2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1640,8 +1640,8 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 			i -= rx_ring->count;
 		}
 
-		/* clear the status bits for the next_to_use descriptor */
-		rx_desc->wb.upper.status_error = 0;
+		/* clear the length for the next_to_use descriptor */
+		rx_desc->wb.upper.length = 0;
 
 		cleaned_count--;
 	} while (cleaned_count);
@@ -2154,7 +2154,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
-		if (!rx_desc->wb.upper.status_error)
+		if (!rx_desc->wb.upper.length)
 			break;
 
 		/* This memory barrier is needed to keep us from reading
@@ -3698,6 +3698,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 			     struct ixgbe_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	union ixgbe_adv_rx_desc *rx_desc;
 	u64 rdba = ring->dma;
 	u32 rxdctl;
 	u8 reg_idx = ring->reg_idx;
@@ -3732,6 +3733,10 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 		rxdctl |=  0x080420;
 	}
 
+	/* initialize Rx descriptor 0 */
+	rx_desc = IXGBE_RX_DESC(ring, 0);
+	rx_desc->wb.upper.length = 0;
+
 	/* enable receive descriptor ring */
 	rxdctl |= IXGBE_RXDCTL_ENABLE;
 	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
@@ -4940,9 +4945,6 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
 	memset(rx_ring->rx_buffer_info, 0, size);
 
-	/* Zero out the descriptor ring */
-	memset(rx_ring->desc, 0, rx_ring->size);
-
 	rx_ring->next_to_alloc = 0;
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
-- 
2.11.0
