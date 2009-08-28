From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/17] tg3: Create rx producer ring setup routines
Date: Fri, 28 Aug 2009 16:59:57 -0700
Message-ID: <1251585284.29681@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2517 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752611AbZH2Wer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later patches are going to complicate the ring initialization routines.
This patch breaks out the setup and teardown of the rx producer rings
into separate functions to make the code more readable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |  231 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 144 insertions(+), 87 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a2a5f31..5d0a1e6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5517,14 +5517,7 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 	return err;
 }
 
-/* Free up pending packets in all rx/tx rings.
- *
- * The chip has been shut down and the driver detached from
- * the networking, so no interrupts or new tx packets will
- * end up in the driver.  tp->{tx,}lock is not held and we are not
- * in an interrupt context and thus may sleep.
- */
-static void tg3_free_rings(struct tg3 *tp)
+static void tg3_rx_prodring_free(struct tg3 *tp)
 {
 	struct ring_info *rxp;
 	int i;
@@ -5534,46 +5527,29 @@ static void tg3_free_rings(struct tg3 *tp)
 
 		if (rxp->skb == NULL)
 			continue;
-		pci_unmap_single(tp->pdev,
-				 pci_unmap_addr(rxp, mapping),
-				 tp->rx_pkt_map_sz,
-				 PCI_DMA_FROMDEVICE);
-		dev_kfree_skb_any(rxp->skb);
-		rxp->skb = NULL;
-	}
-
-	for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
-		rxp = &tp->rx_jumbo_buffers[i];
 
-		if (rxp->skb == NULL)
-			continue;
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(rxp, mapping),
-				 TG3_RX_JMB_MAP_SZ,
+				 tp->rx_pkt_map_sz,
 				 PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_any(rxp->skb);
 		rxp->skb = NULL;
 	}
 
-	for (i = 0; i < TG3_TX_RING_SIZE; ) {
-		struct tx_ring_info *txp;
-		struct sk_buff *skb;
+	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
+			rxp = &tp->rx_jumbo_buffers[i];
 
-		txp = &tp->tx_buffers[i];
-		skb = txp->skb;
+			if (rxp->skb == NULL)
+				continue;
 
-		if (skb == NULL) {
-			i++;
-			continue;
+			pci_unmap_single(tp->pdev,
+					 pci_unmap_addr(rxp, mapping),
+					 TG3_RX_JMB_MAP_SZ,
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb_any(rxp->skb);
+			rxp->skb = NULL;
 		}
-
-		skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
-
-		txp->skb = NULL;
-
-		i += skb_shinfo(skb)->nr_frags + 1;
-
-		dev_kfree_skb_any(skb);
 	}
 }
 
@@ -5584,18 +5560,12 @@ static void tg3_free_rings(struct tg3 *tp)
  * end up in the driver.  tp->{tx,}lock are held and thus
  * we may not sleep.
  */
-static int tg3_init_rings(struct tg3 *tp)
+static int tg3_rx_prodring_alloc(struct tg3 *tp)
 {
 	u32 i, rx_pkt_dma_sz;
 
-	/* Free up all the SKBs. */
-	tg3_free_rings(tp);
-
 	/* Zero out all descriptors. */
 	memset(tp->rx_std, 0, TG3_RX_RING_BYTES);
-	memset(tp->rx_jumbo, 0, TG3_RX_JUMBO_RING_BYTES);
-	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
-	memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
 
 	rx_pkt_dma_sz = TG3_RX_STD_DMA_SZ;
 	if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) &&
@@ -5617,19 +5587,6 @@ static int tg3_init_rings(struct tg3 *tp)
 			       (i << RXD_OPAQUE_INDEX_SHIFT));
 	}
 
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
-		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
-			struct tg3_rx_buffer_desc *rxd;
-
-			rxd = &tp->rx_jumbo[i];
-			rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
-			rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
-				RXD_FLAG_JUMBO;
-			rxd->opaque = (RXD_OPAQUE_RING_JUMBO |
-			       (i << RXD_OPAQUE_INDEX_SHIFT));
-		}
-	}
-
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
 		if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_STD, -1, i) < 0) {
@@ -5639,13 +5596,29 @@ static int tg3_init_rings(struct tg3 *tp)
 			       "successfully.\n",
 			       tp->dev->name, i, tp->rx_pending);
 			if (i == 0)
-				return -ENOMEM;
+				goto initfail;
 			tp->rx_pending = i;
 			break;
 		}
 	}
 
+	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE))
+		goto done;
+
+	memset(tp->rx_jumbo, 0, TG3_RX_JUMBO_RING_BYTES);
+
 	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
+		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
+			struct tg3_rx_buffer_desc *rxd;
+
+			rxd = &tp->rx_jumbo[i];
+			rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
+			rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
+				RXD_FLAG_JUMBO;
+			rxd->opaque = (RXD_OPAQUE_RING_JUMBO |
+			       (i << RXD_OPAQUE_INDEX_SHIFT));
+		}
+
 		for (i = 0; i < tp->rx_jumbo_pending; i++) {
 			if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_JUMBO,
 					     -1, i) < 0) {
@@ -5654,26 +5627,28 @@ static int tg3_init_rings(struct tg3 *tp)
 				       "only %d out of %d buffers were "
 				       "allocated successfully.\n",
 				       tp->dev->name, i, tp->rx_jumbo_pending);
-				if (i == 0) {
-					tg3_free_rings(tp);
-					return -ENOMEM;
-				}
+				if (i == 0)
+					goto initfail;
 				tp->rx_jumbo_pending = i;
 				break;
 			}
 		}
 	}
+
+done:
 	return 0;
+
+initfail:
+	tg3_rx_prodring_free(tp);
+	return -ENOMEM;
 }
 
-/*
- * Must not be invoked with interrupt sources disabled and
- * the hardware shutdown down.
- */
-static void tg3_free_consistent(struct tg3 *tp)
+static void tg3_rx_prodring_fini(struct tg3 *tp)
 {
 	kfree(tp->rx_std_buffers);
 	tp->rx_std_buffers = NULL;
+	kfree(tp->rx_jumbo_buffers);
+	tp->rx_jumbo_buffers = NULL;
 	if (tp->rx_std) {
 		pci_free_consistent(tp->pdev, TG3_RX_RING_BYTES,
 				    tp->rx_std, tp->rx_std_mapping);
@@ -5684,6 +5659,103 @@ static void tg3_free_consistent(struct tg3 *tp)
 				    tp->rx_jumbo, tp->rx_jumbo_mapping);
 		tp->rx_jumbo = NULL;
 	}
+}
+
+static int tg3_rx_prodring_init(struct tg3 *tp)
+{
+	tp->rx_std_buffers = kzalloc(sizeof(struct ring_info) *
+				     TG3_RX_RING_SIZE, GFP_KERNEL);
+	if (!tp->rx_std_buffers)
+		return -ENOMEM;
+
+	tp->rx_std = pci_alloc_consistent(tp->pdev, TG3_RX_RING_BYTES,
+					  &tp->rx_std_mapping);
+	if (!tp->rx_std)
+		goto err_out;
+
+	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+		tp->rx_jumbo_buffers = kzalloc(sizeof(struct ring_info) *
+					       TG3_RX_JUMBO_RING_SIZE,
+					       GFP_KERNEL);
+		if (!tp->rx_jumbo_buffers)
+			goto err_out;
+
+		tp->rx_jumbo = pci_alloc_consistent(tp->pdev,
+						    TG3_RX_JUMBO_RING_BYTES,
+						    &tp->rx_jumbo_mapping);
+		if (!tp->rx_jumbo)
+			goto err_out;
+	}
+
+	return 0;
+
+err_out:
+	tg3_rx_prodring_fini(tp);
+	return -ENOMEM;
+}
+
+/* Free up pending packets in all rx/tx rings.
+ *
+ * The chip has been shut down and the driver detached from
+ * the networking, so no interrupts or new tx packets will
+ * end up in the driver.  tp->{tx,}lock is not held and we are not
+ * in an interrupt context and thus may sleep.
+ */
+static void tg3_free_rings(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < TG3_TX_RING_SIZE; ) {
+		struct tx_ring_info *txp;
+		struct sk_buff *skb;
+
+		txp = &tp->tx_buffers[i];
+		skb = txp->skb;
+
+		if (skb == NULL) {
+			i++;
+			continue;
+		}
+
+		skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
+
+		txp->skb = NULL;
+
+		i += skb_shinfo(skb)->nr_frags + 1;
+
+		dev_kfree_skb_any(skb);
+	}
+
+	tg3_rx_prodring_free(tp);
+}
+
+/* Initialize tx/rx rings for packet processing.
+ *
+ * The chip has been shut down and the driver detached from
+ * the networking, so no interrupts or new tx packets will
+ * end up in the driver.  tp->{tx,}lock are held and thus
+ * we may not sleep.
+ */
+static int tg3_init_rings(struct tg3 *tp)
+{
+	/* Free up all the SKBs. */
+	tg3_free_rings(tp);
+
+	/* Zero out all descriptors. */
+	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+	memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
+
+	return tg3_rx_prodring_alloc(tp);
+}
+
+/*
+ * Must not be invoked with interrupt sources disabled and
+ * the hardware shutdown down.
+ */
+static void tg3_free_consistent(struct tg3 *tp)
+{
+	kfree(tp->tx_buffers);
+	tp->tx_buffers = NULL;
 	if (tp->rx_rcb) {
 		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
 				    tp->rx_rcb, tp->rx_rcb_mapping);
@@ -5704,6 +5776,7 @@ static void tg3_free_consistent(struct tg3 *tp)
 				    tp->hw_stats, tp->stats_mapping);
 		tp->hw_stats = NULL;
 	}
+	tg3_rx_prodring_fini(tp);
 }
 
 /*
@@ -5712,28 +5785,12 @@ static void tg3_free_consistent(struct tg3 *tp)
  */
 static int tg3_alloc_consistent(struct tg3 *tp)
 {
-	tp->rx_std_buffers = kzalloc((sizeof(struct ring_info) *
-				      (TG3_RX_RING_SIZE +
-				       TG3_RX_JUMBO_RING_SIZE)) +
-				     (sizeof(struct tx_ring_info) *
-				      TG3_TX_RING_SIZE),
-				     GFP_KERNEL);
-	if (!tp->rx_std_buffers)
+	if (tg3_rx_prodring_init(tp))
 		return -ENOMEM;
 
-	tp->rx_jumbo_buffers = &tp->rx_std_buffers[TG3_RX_RING_SIZE];
-	tp->tx_buffers = (struct tx_ring_info *)
-		&tp->rx_jumbo_buffers[TG3_RX_JUMBO_RING_SIZE];
-
-	tp->rx_std = pci_alloc_consistent(tp->pdev, TG3_RX_RING_BYTES,
-					  &tp->rx_std_mapping);
-	if (!tp->rx_std)
-		goto err_out;
-
-	tp->rx_jumbo = pci_alloc_consistent(tp->pdev, TG3_RX_JUMBO_RING_BYTES,
-					    &tp->rx_jumbo_mapping);
-
-	if (!tp->rx_jumbo)
+	tp->tx_buffers = kzalloc(sizeof(struct tx_ring_info) *
+				 TG3_TX_RING_SIZE, GFP_KERNEL);
+	if (!tp->tx_buffers)
 		goto err_out;
 
 	tp->rx_rcb = pci_alloc_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
-- 
1.6.3.3


