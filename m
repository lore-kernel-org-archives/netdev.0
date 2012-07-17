From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbevf: Prevent RX/TX statistics getting reset to zero
Date: Mon, 16 Jul 2012 18:24:41 -0700
Message-ID: <1342488281-8358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26651 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab2GQBYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 21:24:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narendra K <narendra_k@dell.com>

The commit 4197aa7bb81877ebb06e4f2cc1b5fea2da23a7bd implements 64 bit
per ring statistics. But the driver resets the 'total_bytes' and
'total_packets' from RX and TX rings in the RX and TX interrupt
handlers to zero. This results in statistics being lost and user space
reporting RX and TX statistics as zero. This patch addresses the
issue by preventing the resetting of RX and TX ring statistics to
zero.

Signed-off-by: Narendra K <narendra_k@dell.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f69ec42..8b304a4 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -969,8 +969,6 @@ static irqreturn_t ixgbevf_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
-		tx_ring->total_bytes = 0;
-		tx_ring->total_packets = 0;
 		ixgbevf_clean_tx_irq(adapter, tx_ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 				      r_idx + 1);
@@ -994,16 +992,6 @@ static irqreturn_t ixgbevf_msix_clean_rx(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbevf_ring  *rx_ring;
 	int r_idx;
-	int i;
-
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rxr_count; i++) {
-		rx_ring = &(adapter->rx_ring[r_idx]);
-		rx_ring->total_bytes = 0;
-		rx_ring->total_packets = 0;
-		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
-				      r_idx + 1);
-	}
 
 	if (!q_vector->rxr_count)
 		return IRQ_HANDLED;
-- 
1.7.10.4
