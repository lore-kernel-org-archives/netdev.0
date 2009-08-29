From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 15/17] tg3: Move per-int rx members to per-int struct
Date: Fri, 28 Aug 2009 17:03:01 -0700
Message-ID: <1251585292.29705@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2848 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690AbZH2Wez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the rx_rcb, rx_rcb_mapping, and rx_rcb_ptr return ring
device members to a per-interrupt structure.  It also adds a new return
ring consumer mailbox register member (consmbox) and converts the code
to use it rather than a preprocessor constant.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   57 +++++++++++++++++++++++++++++-----------------------
 drivers/net/tg3.h |    9 ++++---
 2 files changed, 37 insertions(+), 29 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5b8d6e0..939574c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -657,7 +657,7 @@ static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 	}
 	/* check for RX/TX work to do */
 	if (sblk->idx[0].tx_consumer != tp->tx_cons ||
-	    sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
+	    sblk->idx[0].rx_producer != tnapi->rx_rcb_ptr)
 		work_exists = 1;
 
 	return work_exists;
@@ -4480,7 +4480,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 {
 	struct tg3 *tp = tnapi->tp;
 	u32 work_mask, rx_std_posted = 0;
-	u32 sw_idx = tp->rx_rcb_ptr;
+	u32 sw_idx = tnapi->rx_rcb_ptr;
 	u16 hw_idx;
 	int received;
 	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
@@ -4494,7 +4494,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 	work_mask = 0;
 	received = 0;
 	while (sw_idx != hw_idx && budget > 0) {
-		struct tg3_rx_buffer_desc *desc = &tp->rx_rcb[sw_idx];
+		struct tg3_rx_buffer_desc *desc = &tnapi->rx_rcb[sw_idx];
 		unsigned int len;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
@@ -4622,8 +4622,8 @@ next_pkt_nopost:
 	}
 
 	/* ACK the status ring. */
-	tp->rx_rcb_ptr = sw_idx;
-	tw32_rx_mbox(MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW, sw_idx);
+	tnapi->rx_rcb_ptr = sw_idx;
+	tw32_rx_mbox(tnapi->consmbox, sw_idx);
 
 	/* Refill RX ring(s). */
 	if (work_mask & RXD_OPAQUE_RING_STD) {
@@ -4678,7 +4678,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with tg3->napi.poll()
 	 */
-	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
+	if (sblk->idx[0].rx_producer != tnapi->rx_rcb_ptr)
 		work_done += tg3_rx(tnapi, budget - work_done);
 
 	return work_done;
@@ -4768,7 +4768,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	struct tg3 *tp = tnapi->tp;
 
 	prefetch(tnapi->hw_status);
-	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+	prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
 		napi_schedule(&tnapi->napi);
@@ -4786,7 +4786,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	struct tg3 *tp = tnapi->tp;
 
 	prefetch(tnapi->hw_status);
-	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+	prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 	/*
 	 * Writing any value to intr-mbox-0 clears PCI INTA# and
 	 * chip-internal interrupt pending events.
@@ -4837,7 +4837,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 		goto out;
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tnapi))) {
-		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+		prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 		napi_schedule(&tnapi->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
@@ -4894,7 +4894,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	if (tg3_irq_sync(tp))
 		goto out;
 
-	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+	prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 
 	napi_schedule(&tnapi->napi);
 
@@ -5745,13 +5745,17 @@ static void tg3_free_rings(struct tg3 *tp)
  */
 static int tg3_init_rings(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
+
 	/* Free up all the SKBs. */
 	tg3_free_rings(tp);
 
 	/* Zero out all descriptors. */
-	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
 
+	tnapi->rx_rcb_ptr = 0;
+	memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+
 	return tg3_rx_prodring_alloc(tp, &tp->prodring[0]);
 }
 
@@ -5765,16 +5769,16 @@ static void tg3_free_consistent(struct tg3 *tp)
 
 	kfree(tp->tx_buffers);
 	tp->tx_buffers = NULL;
-	if (tp->rx_rcb) {
-		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
-				    tp->rx_rcb, tp->rx_rcb_mapping);
-		tp->rx_rcb = NULL;
-	}
 	if (tp->tx_ring) {
 		pci_free_consistent(tp->pdev, TG3_TX_RING_BYTES,
 			tp->tx_ring, tp->tx_desc_mapping);
 		tp->tx_ring = NULL;
 	}
+	if (tnapi->rx_rcb) {
+		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
+				    tnapi->rx_rcb, tnapi->rx_rcb_mapping);
+		tnapi->rx_rcb = NULL;
+	}
 	if (tnapi->hw_status) {
 		pci_free_consistent(tp->pdev, TG3_HW_STATUS_SIZE,
 				    tnapi->hw_status,
@@ -5805,11 +5809,6 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 	if (!tp->tx_buffers)
 		goto err_out;
 
-	tp->rx_rcb = pci_alloc_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
-					  &tp->rx_rcb_mapping);
-	if (!tp->rx_rcb)
-		goto err_out;
-
 	tp->tx_ring = pci_alloc_consistent(tp->pdev, TG3_TX_RING_BYTES,
 					   &tp->tx_desc_mapping);
 	if (!tp->tx_ring)
@@ -5823,6 +5822,14 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 
 	memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 
+	tnapi->rx_rcb = pci_alloc_consistent(tp->pdev,
+					     TG3_RX_RCB_RING_BYTES(tp),
+					     &tnapi->rx_rcb_mapping);
+	if (!tnapi->rx_rcb)
+		goto err_out;
+
+	memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+
 	tp->hw_stats = pci_alloc_consistent(tp->pdev,
 					    sizeof(struct tg3_hw_stats),
 					    &tp->stats_mapping);
@@ -7109,11 +7116,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		}
 	}
 
-	tp->rx_rcb_ptr = 0;
-	tw32_rx_mbox(MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW, 0);
+	tw32_rx_mbox(tp->napi[0].consmbox, 0);
 
 	tg3_set_bdinfo(tp, NIC_SRAM_RCV_RET_RCB,
-		       tp->rx_rcb_mapping,
+		       tp->napi[0].rx_rcb_mapping,
 		       (TG3_RX_RCB_RING_SIZE(tp) <<
 			BDINFO_FLAGS_MAXLEN_SHIFT),
 		       0);
@@ -9956,7 +9962,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	if (rx_idx != rx_start_idx + num_pkts)
 		goto out;
 
-	desc = &tp->rx_rcb[rx_start_idx];
+	desc = &rnapi->rx_rcb[rx_start_idx];
 	desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 	opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
 	if (opaque_key != RXD_OPAQUE_RING_STD)
@@ -13413,6 +13419,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tp->napi[0].tp = tp;
 	tp->napi[0].int_mbox = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
+	tp->napi[0].consmbox = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
 	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f46e619..b91ac29 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2497,8 +2497,13 @@ struct tg3_napi {
 	u32				last_tag;
 	u32				last_irq_tag;
 	u32				int_mbox;
+	u32				consmbox;
+	u32				rx_rcb_ptr;
+
+	struct tg3_rx_buffer_desc	*rx_rcb;
 
 	dma_addr_t			status_mapping;
+	dma_addr_t			rx_rcb_mapping;
 };
 
 struct tg3 {
@@ -2570,7 +2575,6 @@ struct tg3 {
 	struct tg3_napi			napi[TG3_IRQ_MAX_VECS];
 	void				(*write32_rx_mbox) (struct tg3 *, u32,
 							    u32);
-	u32				rx_rcb_ptr;
 	u32				rx_pending;
 	u32				rx_jumbo_pending;
 	u32				rx_std_max_post;
@@ -2579,9 +2583,6 @@ struct tg3 {
 	struct vlan_group		*vlgrp;
 #endif
 
-	struct tg3_rx_buffer_desc	*rx_rcb;
-	dma_addr_t			rx_rcb_mapping;
-
 	struct tg3_rx_prodring_set	prodring[1];
 
 
-- 
1.6.3.3


