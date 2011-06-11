From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] ixgbe: DCB, remove unneeded ixgbe_dcb_txq_to_tc() routine
Date: Fri, 10 Jun 2011 20:02:18 -0700
Message-ID: <1307761341-5267-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3248 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758553Ab1FKDC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 23:02:29 -0400
In-Reply-To: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The ixgbe_dcb_txq_to_tc() routine was used to map TX rings to
a DCB traffic class. Now that a tx_ring has a DCB traffic class
associated with it this routine is no longer needed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   58 +---------------------------------------
 1 files changed, 1 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5caf42a..295ab6d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -665,62 +665,6 @@ void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *tx_ring,
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
-/**
- * ixgbe_dcb_txq_to_tc - convert a reg index to a traffic class
- * @adapter: driver private struct
- * @index: reg idx of queue to query (0-127)
- *
- * Helper function to determine the traffic index for a particular
- * register index.
- *
- * Returns : a tc index for use in range 0-7, or 0-3
- */
-static u8 ixgbe_dcb_txq_to_tc(struct ixgbe_adapter *adapter, u8 reg_idx)
-{
-	int tc = -1;
-	int dcb_i = netdev_get_num_tc(adapter->netdev);
-
-	/* if DCB is not enabled the queues have no TC */
-	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-		return tc;
-
-	/* check valid range */
-	if (reg_idx >= adapter->hw.mac.max_tx_queues)
-		return tc;
-
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		tc = reg_idx >> 2;
-		break;
-	default:
-		if (dcb_i != 4 && dcb_i != 8)
-			break;
-
-		/* if VMDq is enabled the lowest order bits determine TC */
-		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
-				      IXGBE_FLAG_VMDQ_ENABLED)) {
-			tc = reg_idx & (dcb_i - 1);
-			break;
-		}
-
-		/*
-		 * Convert the reg_idx into the correct TC. This bitmask
-		 * targets the last full 32 ring traffic class and assigns
-		 * it a value of 1. From there the rest of the rings are
-		 * based on shifting the mask further up to include the
-		 * reg_idx / 16 and then reg_idx / 8. It assumes dcB_i
-		 * will only ever be 8 or 4 and that reg_idx will never
-		 * be greater then 128. The code without the power of 2
-		 * optimizations would be:
-		 * (((reg_idx % 32) + 32) * dcb_i) >> (9 - reg_idx / 32)
-		 */
-		tc = ((reg_idx & 0X1F) + 0x20) * dcb_i;
-		tc >>= 9 - (reg_idx >> 5);
-	}
-
-	return tc;
-}
-
 static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -766,7 +710,7 @@ static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 	/* disarm tx queues that have received xoff frames */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
-		u32 tc = ixgbe_dcb_txq_to_tc(adapter, tx_ring->reg_idx);
+		u8 tc = tx_ring->dcb_tc;
 
 		if (xoff[tc])
 			clear_bit(__IXGBE_HANG_CHECK_ARMED, &tx_ring->state);
-- 
1.7.5.2

