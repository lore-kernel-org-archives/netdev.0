From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: cleanup IXGBE_DESC_UNUSED
Date: Fri,  1 Nov 2013 06:56:49 -0700
Message-ID: <1383314210-24289-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12204 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683Ab3KAN44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:56 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch just replaces the IXGBE_DESC_UNUSED macro with a like named
inline function ixgbevf_desc_unused. The inline function makes the logic
a bit more readable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 10 +++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 10 +++++-----
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index acf3806..8971e2d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -286,9 +286,13 @@ static inline bool ixgbevf_qv_disable(struct ixgbevf_q_vector *q_vector)
 	((_eitr) ? (1000000000 / ((_eitr) * 256)) : 8)
 #define EITR_REG_TO_INTS_PER_SEC EITR_INTS_PER_SEC_TO_REG
 
-#define IXGBE_DESC_UNUSED(R) \
-	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
-	(R)->next_to_clean - (R)->next_to_use - 1)
+static inline u16 ixgbevf_desc_unused(struct ixgbevf_ring *ring)
+{
+	u16 ntc = ring->next_to_clean;
+	u16 ntu = ring->next_to_use;
+
+	return ((ntc > ntu) ? 0 : ring->count) + ntc - ntu - 1;
+}
 
 #define IXGBEVF_RX_DESC(R, i)	    \
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 9685354..038bfc8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -251,7 +251,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
 	if (unlikely(count && netif_carrier_ok(tx_ring->netdev) &&
-		     (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
+		     (ixgbevf_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
@@ -529,7 +529,7 @@ next_desc:
 	}
 
 	rx_ring->next_to_clean = i;
-	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
+	cleaned_count = ixgbevf_desc_unused(rx_ring);
 
 	if (cleaned_count)
 		ixgbevf_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
@@ -1380,7 +1380,7 @@ static void ixgbevf_configure(struct ixgbevf_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct ixgbevf_ring *ring = &adapter->rx_ring[i];
 		ixgbevf_alloc_rx_buffers(adapter, ring,
-					 IXGBE_DESC_UNUSED(ring));
+					 ixgbevf_desc_unused(ring));
 	}
 }
 
@@ -3102,7 +3102,7 @@ static int __ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
 
 	/* We need to check again in a case another CPU has just
 	 * made room available. */
-	if (likely(IXGBE_DESC_UNUSED(tx_ring) < size))
+	if (likely(ixgbevf_desc_unused(tx_ring) < size))
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
@@ -3113,7 +3113,7 @@ static int __ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
 
 static int ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
 {
-	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
+	if (likely(ixgbevf_desc_unused(tx_ring) >= size))
 		return 0;
 	return __ixgbevf_maybe_stop_tx(tx_ring, size);
 }
-- 
1.8.3.1
