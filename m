From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/18] tg3: Add tx and rx ring resource tracking
Date: Tue, 1 Sep 2009 16:04:37 -0700
Message-ID: <1251867305.5932@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2530 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106AbZIBEzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to assign status block, tx producer ring and rx
return ring resources needed for the other interrupt vectors.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  242 ++++++++++++++++++++++++++++++++++------------------
 drivers/net/tg3.h |    3 +-
 2 files changed, 160 insertions(+), 85 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4d16ce0..58a8986 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5722,28 +5722,31 @@ err_out:
  */
 static void tg3_free_rings(struct tg3 *tp)
 {
-	struct tg3_napi *tnapi = &tp->napi[0];
-	int i;
+	int i, j;
 
-	for (i = 0; i < TG3_TX_RING_SIZE; ) {
-		struct tx_ring_info *txp;
-		struct sk_buff *skb;
+	for (j = 0; j < tp->irq_cnt; j++) {
+		struct tg3_napi *tnapi = &tp->napi[j];
 
-		txp = &tnapi->tx_buffers[i];
-		skb = txp->skb;
+		for (i = 0; i < TG3_TX_RING_SIZE; ) {
+			struct tx_ring_info *txp;
+			struct sk_buff *skb;
 
-		if (skb == NULL) {
-			i++;
-			continue;
-		}
+			txp = &tnapi->tx_buffers[i];
+			skb = txp->skb;
 
-		skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
+			if (skb == NULL) {
+				i++;
+				continue;
+			}
 
-		txp->skb = NULL;
+			skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
 
-		i += skb_shinfo(skb)->nr_frags + 1;
+			txp->skb = NULL;
 
-		dev_kfree_skb_any(skb);
+			i += skb_shinfo(skb)->nr_frags + 1;
+
+			dev_kfree_skb_any(skb);
+		}
 	}
 
 	tg3_rx_prodring_free(tp, &tp->prodring[0]);
@@ -5758,16 +5761,27 @@ static void tg3_free_rings(struct tg3 *tp)
  */
 static int tg3_init_rings(struct tg3 *tp)
 {
-	struct tg3_napi *tnapi = &tp->napi[0];
+	int i;
 
 	/* Free up all the SKBs. */
 	tg3_free_rings(tp);
 
-	/* Zero out all descriptors. */
-	memset(tnapi->tx_ring, 0, TG3_TX_RING_BYTES);
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
 
-	tnapi->rx_rcb_ptr = 0;
-	memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+		tnapi->last_tag = 0;
+		tnapi->last_irq_tag = 0;
+		tnapi->hw_status->status = 0;
+		tnapi->hw_status->status_tag = 0;
+		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+
+		tnapi->tx_prod = 0;
+		tnapi->tx_cons = 0;
+		memset(tnapi->tx_ring, 0, TG3_TX_RING_BYTES);
+
+		tnapi->rx_rcb_ptr = 0;
+		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+	}
 
 	return tg3_rx_prodring_alloc(tp, &tp->prodring[0]);
 }
@@ -5778,31 +5792,41 @@ static int tg3_init_rings(struct tg3 *tp)
  */
 static void tg3_free_consistent(struct tg3 *tp)
 {
-	struct tg3_napi *tnapi = &tp->napi[0];
+	int i;
 
-	kfree(tnapi->tx_buffers);
-	tnapi->tx_buffers = NULL;
-	if (tnapi->tx_ring) {
-		pci_free_consistent(tp->pdev, TG3_TX_RING_BYTES,
-			tnapi->tx_ring, tnapi->tx_desc_mapping);
-		tnapi->tx_ring = NULL;
-	}
-	if (tnapi->rx_rcb) {
-		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
-				    tnapi->rx_rcb, tnapi->rx_rcb_mapping);
-		tnapi->rx_rcb = NULL;
-	}
-	if (tnapi->hw_status) {
-		pci_free_consistent(tp->pdev, TG3_HW_STATUS_SIZE,
-				    tnapi->hw_status,
-				    tnapi->status_mapping);
-		tnapi->hw_status = NULL;
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
+		if (tnapi->tx_ring) {
+			pci_free_consistent(tp->pdev, TG3_TX_RING_BYTES,
+				tnapi->tx_ring, tnapi->tx_desc_mapping);
+			tnapi->tx_ring = NULL;
+		}
+
+		kfree(tnapi->tx_buffers);
+		tnapi->tx_buffers = NULL;
+
+		if (tnapi->rx_rcb) {
+			pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
+					    tnapi->rx_rcb,
+					    tnapi->rx_rcb_mapping);
+			tnapi->rx_rcb = NULL;
+		}
+
+		if (tnapi->hw_status) {
+			pci_free_consistent(tp->pdev, TG3_HW_STATUS_SIZE,
+					    tnapi->hw_status,
+					    tnapi->status_mapping);
+			tnapi->hw_status = NULL;
+		}
 	}
+
 	if (tp->hw_stats) {
 		pci_free_consistent(tp->pdev, sizeof(struct tg3_hw_stats),
 				    tp->hw_stats, tp->stats_mapping);
 		tp->hw_stats = NULL;
 	}
+
 	tg3_rx_prodring_fini(tp, &tp->prodring[0]);
 }
 
@@ -5812,44 +5836,49 @@ static void tg3_free_consistent(struct tg3 *tp)
  */
 static int tg3_alloc_consistent(struct tg3 *tp)
 {
-	struct tg3_napi *tnapi = &tp->napi[0];
+	int i;
 
 	if (tg3_rx_prodring_init(tp, &tp->prodring[0]))
 		return -ENOMEM;
 
-	tnapi->tx_buffers = kzalloc(sizeof(struct tx_ring_info) *
-				    TG3_TX_RING_SIZE, GFP_KERNEL);
-	if (!tnapi->tx_buffers)
+	tp->hw_stats = pci_alloc_consistent(tp->pdev,
+					    sizeof(struct tg3_hw_stats),
+					    &tp->stats_mapping);
+	if (!tp->hw_stats)
 		goto err_out;
 
-	tnapi->tx_ring = pci_alloc_consistent(tp->pdev, TG3_TX_RING_BYTES,
-					      &tnapi->tx_desc_mapping);
-	if (!tnapi->tx_ring)
-		goto err_out;
+	memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
 
-	tnapi->hw_status = pci_alloc_consistent(tp->pdev,
-						TG3_HW_STATUS_SIZE,
-						&tnapi->status_mapping);
-	if (!tnapi->hw_status)
-		goto err_out;
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
 
-	memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+		tnapi->hw_status = pci_alloc_consistent(tp->pdev,
+							TG3_HW_STATUS_SIZE,
+							&tnapi->status_mapping);
+		if (!tnapi->hw_status)
+			goto err_out;
 
-	tnapi->rx_rcb = pci_alloc_consistent(tp->pdev,
-					     TG3_RX_RCB_RING_BYTES(tp),
-					     &tnapi->rx_rcb_mapping);
-	if (!tnapi->rx_rcb)
-		goto err_out;
+		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 
-	memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+		tnapi->rx_rcb = pci_alloc_consistent(tp->pdev,
+						     TG3_RX_RCB_RING_BYTES(tp),
+						     &tnapi->rx_rcb_mapping);
+		if (!tnapi->rx_rcb)
+			goto err_out;
 
-	tp->hw_stats = pci_alloc_consistent(tp->pdev,
-					    sizeof(struct tg3_hw_stats),
-					    &tp->stats_mapping);
-	if (!tp->hw_stats)
-		goto err_out;
+		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 
-	memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
+		tnapi->tx_buffers = kzalloc(sizeof(struct tx_ring_info) *
+					    TG3_TX_RING_SIZE, GFP_KERNEL);
+		if (!tnapi->tx_buffers)
+			goto err_out;
+
+		tnapi->tx_ring = pci_alloc_consistent(tp->pdev,
+						      TG3_TX_RING_BYTES,
+						      &tnapi->tx_desc_mapping);
+		if (!tnapi->tx_ring)
+			goto err_out;
+	}
 
 	return 0;
 
@@ -5910,7 +5939,6 @@ static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, int
 static int tg3_abort_hw(struct tg3 *tp, int silent)
 {
 	int i, err;
-	struct tg3_napi *tnapi = &tp->napi[0];
 
 	tg3_disable_ints(tp);
 
@@ -5962,8 +5990,11 @@ static int tg3_abort_hw(struct tg3 *tp, int silent)
 	err |= tg3_stop_block(tp, BUFMGR_MODE, BUFMGR_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, MEMARB_MODE, MEMARB_MODE_ENABLE, silent);
 
-	if (tnapi->hw_status)
-		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+		if (tnapi->hw_status)
+			memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+	}
 	if (tp->hw_stats)
 		memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
 
@@ -6290,12 +6321,15 @@ static int tg3_chip_reset(struct tg3 *tp)
 	 * sharing or irqpoll.
 	 */
 	tp->tg3_flags |= TG3_FLAG_CHIP_RESETTING;
-	if (tp->napi[0].hw_status) {
-		tp->napi[0].hw_status->status = 0;
-		tp->napi[0].hw_status->status_tag = 0;
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+		if (tnapi->hw_status) {
+			tnapi->hw_status->status = 0;
+			tnapi->hw_status->status_tag = 0;
+		}
+		tnapi->last_tag = 0;
+		tnapi->last_irq_tag = 0;
 	}
-	tp->napi[0].last_tag = 0;
-	tp->napi[0].last_irq_tag = 0;
 	smp_mb();
 
 	for (i = 0; i < tp->irq_cnt; i++)
@@ -6829,7 +6863,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 static void tg3_rings_reset(struct tg3 *tp)
 {
 	int i;
-	u32 txrcb, rxrcb, limit;
+	u32 stblk, txrcb, rxrcb, limit;
 	struct tg3_napi *tnapi = &tp->napi[0];
 
 	/* Disable all transmit rings but the first. */
@@ -6861,10 +6895,20 @@ static void tg3_rings_reset(struct tg3 *tp)
 	tw32_mailbox_f(tp->napi[0].int_mbox, 1);
 
 	/* Zero mailbox registers. */
-	tp->napi[0].tx_prod = 0;
-	tp->napi[0].tx_cons = 0;
-	tw32_mailbox(tp->napi[0].prodmbox, 0);
-	tw32_rx_mbox(tp->napi[0].consmbox, 0);
+	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX) {
+		for (i = 1; i < TG3_IRQ_MAX_VECS; i++) {
+			tp->napi[i].tx_prod = 0;
+			tp->napi[i].tx_cons = 0;
+			tw32_mailbox(tp->napi[i].prodmbox, 0);
+			tw32_rx_mbox(tp->napi[i].consmbox, 0);
+			tw32_mailbox_f(tp->napi[i].int_mbox, 1);
+		}
+	} else {
+		tp->napi[0].tx_prod = 0;
+		tp->napi[0].tx_cons = 0;
+		tw32_mailbox(tp->napi[0].prodmbox, 0);
+		tw32_rx_mbox(tp->napi[0].consmbox, 0);
+	}
 
 	/* Make sure the NIC-based send BD rings are disabled. */
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
@@ -6885,14 +6929,44 @@ static void tg3_rings_reset(struct tg3 *tp)
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tnapi->status_mapping & 0xffffffff));
 
-	tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
-		       (TG3_TX_RING_SIZE <<
-			BDINFO_FLAGS_MAXLEN_SHIFT),
-		       NIC_SRAM_TX_BUFFER_DESC);
+	if (tnapi->tx_ring) {
+		tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
+			       (TG3_TX_RING_SIZE <<
+				BDINFO_FLAGS_MAXLEN_SHIFT),
+			       NIC_SRAM_TX_BUFFER_DESC);
+		txrcb += TG3_BDINFO_SIZE;
+	}
 
-	tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
-		       (TG3_RX_RCB_RING_SIZE(tp) <<
-			BDINFO_FLAGS_MAXLEN_SHIFT), 0);
+	if (tnapi->rx_rcb) {
+		tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
+			       (TG3_RX_RCB_RING_SIZE(tp) <<
+				BDINFO_FLAGS_MAXLEN_SHIFT), 0);
+		rxrcb += TG3_BDINFO_SIZE;
+	}
+
+	stblk = HOSTCC_STATBLCK_RING1;
+
+	for (i = 1, tnapi++; i < tp->irq_cnt; i++, tnapi++) {
+		u64 mapping = (u64)tnapi->status_mapping;
+		tw32(stblk + TG3_64BIT_REG_HIGH, mapping >> 32);
+		tw32(stblk + TG3_64BIT_REG_LOW, mapping & 0xffffffff);
+
+		/* Clear status block in ram. */
+		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+
+		tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
+			       (TG3_TX_RING_SIZE <<
+				BDINFO_FLAGS_MAXLEN_SHIFT),
+			       NIC_SRAM_TX_BUFFER_DESC);
+
+		tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
+			       (TG3_RX_RCB_RING_SIZE(tp) <<
+				BDINFO_FLAGS_MAXLEN_SHIFT), 0);
+
+		stblk += 8;
+		txrcb += TG3_BDINFO_SIZE;
+		rxrcb += TG3_BDINFO_SIZE;
+	}
 }
 
 /* tp->lock is held. */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 65bbd77..6452d48 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1117,7 +1117,8 @@
 #define HOSTCC_SND_CON_IDX_13		0x00003cf4
 #define HOSTCC_SND_CON_IDX_14		0x00003cf8
 #define HOSTCC_SND_CON_IDX_15		0x00003cfc
-/* 0x3d00 --> 0x4000 unused */
+#define HOSTCC_STATBLCK_RING1		0x00003d00
+/* 0x3d04 --> 0x4000 unused */
 
 /* Memory arbiter control registers */
 #define MEMARB_MODE			0x00004000
-- 
1.6.3.3


