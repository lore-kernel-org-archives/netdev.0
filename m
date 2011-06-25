From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] ixgbe: Convert IXGBE_DESC_UNUSED from macro to static inline function
Date: Sat, 25 Jun 2011 00:22:19 -0700
Message-ID: <1308986546-12964-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab1FYHW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:29 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is a minor cleanup that converts the IXGBE_DESC_UNUSED macro
into a static inline function just for the case of the code being a bit
cleaner.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |   10 +++++++---
 drivers/net/ixgbe/ixgbe_main.c |   10 +++++-----
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d6bfb2f..b1d4b02 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -306,9 +306,13 @@ struct ixgbe_q_vector {
 	((_eitr) ? (1000000000 / ((_eitr) * 256)) : 8)
 #define EITR_REG_TO_INTS_PER_SEC EITR_INTS_PER_SEC_TO_REG
 
-#define IXGBE_DESC_UNUSED(R) \
-	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
-	(R)->next_to_clean - (R)->next_to_use - 1)
+static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
+{
+	u16 ntc = ring->next_to_clean;
+	u16 ntu = ring->next_to_use;
+
+	return ((ntc > ntu) ? 0 : ring->count) + ntc - ntu - 1;
+}
 
 #define IXGBE_RX_DESC_ADV(R, i)	    \
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b308571..f8a22eb 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -882,7 +882,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
 	if (unlikely(count && netif_carrier_ok(tx_ring->netdev) &&
-		     (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
+		     (ixgbe_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
@@ -1474,7 +1474,7 @@ next_desc:
 	}
 
 	rx_ring->next_to_clean = i;
-	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
+	cleaned_count = ixgbe_desc_unused(rx_ring);
 
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
@@ -3126,7 +3126,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
 
 	ixgbe_rx_desc_queue_enable(adapter, ring);
-	ixgbe_alloc_rx_buffers(ring, IXGBE_DESC_UNUSED(ring));
+	ixgbe_alloc_rx_buffers(ring, ixgbe_desc_unused(ring));
 }
 
 static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
@@ -6817,7 +6817,7 @@ static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
 
 	/* We need to check again in a case another CPU has just
 	 * made room available. */
-	if (likely(IXGBE_DESC_UNUSED(tx_ring) < size))
+	if (likely(ixgbe_desc_unused(tx_ring) < size))
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
@@ -6828,7 +6828,7 @@ static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
 
 static int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
 {
-	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
+	if (likely(ixgbe_desc_unused(tx_ring) >= size))
 		return 0;
 	return __ixgbe_maybe_stop_tx(tx_ring, size);
 }
-- 
1.7.5.4

