From: alexander.duyck@gmail.com
Subject: [PATCH] fm10k: Add skb->xmit_more support
Date: Fri, 10 Oct 2014 13:17:40 -0700
Message-ID: <20141010201714.20593.67813.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: matthew.vick@intel.com
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:60147 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbaJJURl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 16:17:41 -0400
Received: by mail-pd0-f170.google.com with SMTP id p10so2259499pdj.15
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 13:17:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change adds suport for skb->xmit_more based on the changes that were
made to igb to support the feature.  The main changes are moving up the
check for maybe_stop_tx so that we can check netif_xmit_stopped to determine
if we must write the tail because we can add no further buffers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |   65 +++++++++++++------------
 1 file changed, 34 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 6c800a3..8ad7ff4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -930,6 +930,30 @@ static bool fm10k_tx_desc_push(struct fm10k_ring *tx_ring,
 	return i == tx_ring->count;
 }
 
+static int __fm10k_maybe_stop_tx(struct fm10k_ring *tx_ring, u16 size)
+{
+	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (likely(fm10k_desc_unused(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! - use start_queue because it doesn't call schedule */
+	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	++tx_ring->tx_stats.restart_queue;
+	return 0;
+}
+
+static inline int fm10k_maybe_stop_tx(struct fm10k_ring *tx_ring, u16 size)
+{
+	if (likely(fm10k_desc_unused(tx_ring) >= size))
+		return 0;
+	return __fm10k_maybe_stop_tx(tx_ring, size);
+}
+
 static void fm10k_tx_map(struct fm10k_ring *tx_ring,
 			 struct fm10k_tx_buffer *first)
 {
@@ -1023,13 +1047,18 @@ static void fm10k_tx_map(struct fm10k_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
+	/* Make sure there is space in the ring for the next send. */
+	fm10k_maybe_stop_tx(tx_ring, DESC_NEEDED);
+
 	/* notify HW of packet */
-	writel(i, tx_ring->tail);
+	if (netif_xmit_stopped(txring_txq(tx_ring)) || !skb->xmit_more) {
+		writel(i, tx_ring->tail);
 
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it synchronizes IO on IA64/Altix systems
-	 */
-	mmiowb();
+		/* we need this if more than one processor can write to our tail
+		 * at a time, it synchronizes IO on IA64/Altix systems
+		 */
+		mmiowb();
+	}
 
 	return;
 dma_error:
@@ -1049,30 +1078,6 @@ dma_error:
 	tx_ring->next_to_use = i;
 }
 
-static int __fm10k_maybe_stop_tx(struct fm10k_ring *tx_ring, u16 size)
-{
-	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
-
-	smp_mb();
-
-	/* We need to check again in a case another CPU has just
-	 * made room available. */
-	if (likely(fm10k_desc_unused(tx_ring) < size))
-		return -EBUSY;
-
-	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
-	++tx_ring->tx_stats.restart_queue;
-	return 0;
-}
-
-static inline int fm10k_maybe_stop_tx(struct fm10k_ring *tx_ring, u16 size)
-{
-	if (likely(fm10k_desc_unused(tx_ring) >= size))
-		return 0;
-	return __fm10k_maybe_stop_tx(tx_ring, size);
-}
-
 netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring)
 {
@@ -1117,8 +1122,6 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 
 	fm10k_tx_map(tx_ring, first);
 
-	fm10k_maybe_stop_tx(tx_ring, DESC_NEEDED);
-
 	return NETDEV_TX_OK;
 
 out_drop:
