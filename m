From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ixgbe: Simplify transmit cleanup path
Date: Sun, 21 Aug 2011 00:29:12 -0700
Message-ID: <1313911761-11709-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61333 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab1HUH3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 03:29:25 -0400
In-Reply-To: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch helps to simplify the work being done by the transmit path by
removing the unnecessary compares between count and the work limit.  Instead
we can simplify this by just adding a budget value that will act as a count
down from the work limit value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e8aad76..e5a4eb6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -804,13 +804,13 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	struct ixgbe_tx_buffer *tx_buffer;
 	union ixgbe_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
+	u16 budget = q_vector->tx.work_limit;
 	u16 i = tx_ring->next_to_clean;
-	u16 count;
 
 	tx_buffer = &tx_ring->tx_buffer_info[i];
 	tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 
-	for (count = 0; count < q_vector->tx.work_limit; count++) {
+	for (; budget; budget--) {
 		union ixgbe_adv_tx_desc *eop_desc = tx_buffer->next_to_watch;
 
 		/* if next_to_watch is not set then there is no work pending */
@@ -891,11 +891,11 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		ixgbe_tx_timeout_reset(adapter);
 
 		/* the adapter is about to reset, no point in enabling stuff */
-		return true;
+		return budget;
 	}
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
-	if (unlikely(count && netif_carrier_ok(tx_ring->netdev) &&
+	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
 		     (ixgbe_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
@@ -908,7 +908,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		}
 	}
 
-	return count < q_vector->tx.work_limit;
+	return budget;
 }
 
 #ifdef CONFIG_IXGBE_DCA
-- 
1.7.6

