From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/5] igb: remove IGB_DESC_UNUSED since it is better
	handled by a function call
Date: Fri, 20 Mar 2009 03:16:50 -0700
Message-ID: <20090320101650.17663.62516.stgit@lost.foo-projects.org>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:39011 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753745AbZCTKW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:22:57 -0400
In-Reply-To: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes IGB_DESC_UNUSED and replaces it with a function call
instead in order to cleanup some of the ugliness introduced by the macro.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    4 ----
 drivers/net/igb/igb_main.c |   25 ++++++++++++++++++-------
 2 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index e18ac1b..4e8464b 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -182,10 +182,6 @@ struct igb_ring {
 	char name[IFNAMSIZ + 5];
 };
 
-#define IGB_DESC_UNUSED(R) \
-	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
-	(R)->next_to_clean - (R)->next_to_use - 1)
-
 #define E1000_RX_DESC_ADV(R, i)	    \
 	(&(((union e1000_adv_rx_desc *)((R).desc))[i]))
 #define E1000_TX_DESC_ADV(R, i)	    \
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c14d569..05bb7a7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -278,6 +278,17 @@ static char *igb_get_time_str(struct igb_adapter *adapter,
 #endif
 
 /**
+ * igb_desc_unused - calculate if we have unused descriptors
+ **/
+static int igb_desc_unused(struct igb_ring *ring)
+{
+	if (ring->next_to_clean > ring->next_to_use)
+		return ring->next_to_clean - ring->next_to_use - 1;
+
+	return ring->count + ring->next_to_clean - ring->next_to_use - 1;
+}
+
+/**
  * igb_init_module - Driver Registration Routine
  *
  * igb_init_module is the first routine called when the driver is
@@ -873,12 +884,12 @@ static void igb_configure(struct igb_adapter *adapter)
 
 	igb_rx_fifo_flush_82575(&adapter->hw);
 
-	/* call IGB_DESC_UNUSED which always leaves
+	/* call igb_desc_unused which always leaves
 	 * at least 1 descriptor unused to make sure
 	 * next_to_use != next_to_clean */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &adapter->rx_ring[i];
-		igb_alloc_rx_buffers_adv(ring, IGB_DESC_UNUSED(ring));
+		igb_alloc_rx_buffers_adv(ring, igb_desc_unused(ring));
 	}
 
 
@@ -2661,7 +2672,7 @@ link_up:
 	igb_update_adaptive(&adapter->hw);
 
 	if (!netif_carrier_ok(netdev)) {
-		if (IGB_DESC_UNUSED(tx_ring) + 1 < tx_ring->count) {
+		if (igb_desc_unused(tx_ring) + 1 < tx_ring->count) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
@@ -3199,7 +3210,7 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 
 	/* We need to check again in a case another CPU has just
 	 * made room available. */
-	if (IGB_DESC_UNUSED(tx_ring) < size)
+	if (igb_desc_unused(tx_ring) < size)
 		return -EBUSY;
 
 	/* A reprieve! */
@@ -3211,7 +3222,7 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 static int igb_maybe_stop_tx(struct net_device *netdev,
 			     struct igb_ring *tx_ring, int size)
 {
-	if (IGB_DESC_UNUSED(tx_ring) >= size)
+	if (igb_desc_unused(tx_ring) >= size)
 		return 0;
 	return __igb_maybe_stop_tx(netdev, tx_ring, size);
 }
@@ -4310,7 +4321,7 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 
 	if (unlikely(count &&
 		     netif_carrier_ok(netdev) &&
-		     IGB_DESC_UNUSED(tx_ring) >= IGB_TX_QUEUE_WAKE)) {
+		     igb_desc_unused(tx_ring) >= IGB_TX_QUEUE_WAKE)) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
@@ -4587,7 +4598,7 @@ next_desc:
 	}
 
 	rx_ring->next_to_clean = i;
-	cleaned_count = IGB_DESC_UNUSED(rx_ring);
+	cleaned_count = igb_desc_unused(rx_ring);
 
 	if (cleaned_count)
 		igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);

