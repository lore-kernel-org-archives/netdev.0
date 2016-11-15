From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 4/9] alx: switch to per queue data structures
Date: Tue, 15 Nov 2016 12:43:11 +0100
Message-ID: <4be5821e8bbe30cd9ce6610e844f9965bb969334.1479208628.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36318 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752305AbcKOLng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:36 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so24865514wma.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:35 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the tx and rx queue structures from the alx_priv structure and switch
everything over to the queue pointers in the alx_napi structure.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/alx.h  |   5 -
 drivers/net/ethernet/atheros/alx/main.c | 183 ++++++++++++++++----------------
 2 files changed, 93 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index 0859053525de..d4a409139ea2 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -113,7 +113,6 @@ struct alx_priv {
 	/* msi-x vectors */
 	int num_vec;
 	struct msix_entry *msix_entries;
-	char irq_lbl[IFNAMSIZ + 8];
 
 	/* all descriptor memory */
 	struct {
@@ -135,10 +134,6 @@ struct alx_priv {
 	unsigned int rx_ringsz;
 	unsigned int rxbuf_size;
 
-	struct napi_struct napi;
-	struct alx_tx_queue txq;
-	struct alx_rx_queue rxq;
-
 	struct work_struct link_check_wk;
 	struct work_struct reset_wk;
 
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 193da6799979..a9fc44611b8a 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -55,12 +55,12 @@ static bool msix = false;
 module_param(msix, bool, 0);
 MODULE_PARM_DESC(msix, "Enable msi-x interrupt support");
 
-static void alx_free_txbuf(struct alx_priv *alx, int entry)
+static void alx_free_txbuf(struct alx_tx_queue *txq, int entry)
 {
-	struct alx_buffer *txb = &alx->txq.bufs[entry];
+	struct alx_buffer *txb = &txq->bufs[entry];
 
 	if (dma_unmap_len(txb, size)) {
-		dma_unmap_single(&alx->hw.pdev->dev,
+		dma_unmap_single(txq->dev,
 				 dma_unmap_addr(txb, dma),
 				 dma_unmap_len(txb, size),
 				 DMA_TO_DEVICE);
@@ -75,7 +75,7 @@ static void alx_free_txbuf(struct alx_priv *alx, int entry)
 
 static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 {
-	struct alx_rx_queue *rxq = &alx->rxq;
+	struct alx_rx_queue *rxq = alx->qnapi[0]->rxq;
 	struct sk_buff *skb;
 	struct alx_buffer *cur_buf;
 	dma_addr_t dma;
@@ -143,22 +143,22 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 	return count;
 }
 
-static inline int alx_tpd_avail(struct alx_priv *alx)
+static inline int alx_tpd_avail(struct alx_tx_queue *txq)
 {
-	struct alx_tx_queue *txq = &alx->txq;
-
 	if (txq->write_idx >= txq->read_idx)
-		return alx->tx_ringsz + txq->read_idx - txq->write_idx - 1;
+		return txq->count + txq->read_idx - txq->write_idx - 1;
 	return txq->read_idx - txq->write_idx - 1;
 }
 
-static bool alx_clean_tx_irq(struct alx_priv *alx)
+static bool alx_clean_tx_irq(struct alx_tx_queue *txq)
 {
-	struct alx_tx_queue *txq = &alx->txq;
+	struct alx_priv *alx;
 	u16 hw_read_idx, sw_read_idx;
 	unsigned int total_bytes = 0, total_packets = 0;
 	int budget = ALX_DEFAULT_TX_WORK;
 
+	alx = netdev_priv(txq->netdev);
+
 	sw_read_idx = txq->read_idx;
 	hw_read_idx = alx_read_mem16(&alx->hw, ALX_TPD_PRI0_CIDX);
 
@@ -173,19 +173,19 @@ static bool alx_clean_tx_irq(struct alx_priv *alx)
 				budget--;
 			}
 
-			alx_free_txbuf(alx, sw_read_idx);
+			alx_free_txbuf(txq, sw_read_idx);
 
-			if (++sw_read_idx == alx->tx_ringsz)
+			if (++sw_read_idx == txq->count)
 				sw_read_idx = 0;
 		}
 		txq->read_idx = sw_read_idx;
 
-		netdev_completed_queue(alx->dev, total_packets, total_bytes);
+		netdev_completed_queue(txq->netdev, total_packets, total_bytes);
 	}
 
-	if (netif_queue_stopped(alx->dev) && netif_carrier_ok(alx->dev) &&
-	    alx_tpd_avail(alx) > alx->tx_ringsz/4)
-		netif_wake_queue(alx->dev);
+	if (netif_queue_stopped(txq->netdev) && netif_carrier_ok(txq->netdev) &&
+	    alx_tpd_avail(txq) > txq->count / 4)
+		netif_wake_queue(txq->netdev);
 
 	return sw_read_idx == hw_read_idx;
 }
@@ -200,15 +200,17 @@ static void alx_schedule_reset(struct alx_priv *alx)
 	schedule_work(&alx->reset_wk);
 }
 
-static int alx_clean_rx_irq(struct alx_priv *alx, int budget)
+static int alx_clean_rx_irq(struct alx_rx_queue *rxq, int budget)
 {
-	struct alx_rx_queue *rxq = &alx->rxq;
+	struct alx_priv *alx;
 	struct alx_rrd *rrd;
 	struct alx_buffer *rxb;
 	struct sk_buff *skb;
 	u16 length, rfd_cleaned = 0;
 	int work = 0;
 
+	alx = netdev_priv(rxq->netdev);
+
 	while (work < budget) {
 		rrd = &rxq->rrd[rxq->rrd_read_idx];
 		if (!(rrd->word3 & cpu_to_le32(1 << RRD_UPDATED_SHIFT)))
@@ -224,7 +226,7 @@ static int alx_clean_rx_irq(struct alx_priv *alx, int budget)
 		}
 
 		rxb = &rxq->bufs[rxq->read_idx];
-		dma_unmap_single(&alx->hw.pdev->dev,
+		dma_unmap_single(rxq->dev,
 				 dma_unmap_addr(rxb, dma),
 				 dma_unmap_len(rxb, size),
 				 DMA_FROM_DEVICE);
@@ -242,7 +244,7 @@ static int alx_clean_rx_irq(struct alx_priv *alx, int budget)
 		length = ALX_GET_FIELD(le32_to_cpu(rrd->word3),
 				       RRD_PKTLEN) - ETH_FCS_LEN;
 		skb_put(skb, length);
-		skb->protocol = eth_type_trans(skb, alx->dev);
+		skb->protocol = eth_type_trans(skb, rxq->netdev);
 
 		skb_checksum_none_assert(skb);
 		if (alx->dev->features & NETIF_F_RXCSUM &&
@@ -259,13 +261,13 @@ static int alx_clean_rx_irq(struct alx_priv *alx, int budget)
 			}
 		}
 
-		napi_gro_receive(&alx->napi, skb);
+		napi_gro_receive(&rxq->np->napi, skb);
 		work++;
 
 next_pkt:
-		if (++rxq->read_idx == alx->rx_ringsz)
+		if (++rxq->read_idx == rxq->count)
 			rxq->read_idx = 0;
-		if (++rxq->rrd_read_idx == alx->rx_ringsz)
+		if (++rxq->rrd_read_idx == rxq->count)
 			rxq->rrd_read_idx = 0;
 
 		if (++rfd_cleaned > ALX_RX_ALLOC_THRESH)
@@ -280,19 +282,20 @@ static int alx_clean_rx_irq(struct alx_priv *alx, int budget)
 
 static int alx_poll(struct napi_struct *napi, int budget)
 {
-	struct alx_priv *alx = container_of(napi, struct alx_priv, napi);
+	struct alx_napi *np = container_of(napi, struct alx_napi, napi);
+	struct alx_priv *alx = np->alx;
 	struct alx_hw *hw = &alx->hw;
 	unsigned long flags;
 	bool tx_complete;
 	int work;
 
-	tx_complete = alx_clean_tx_irq(alx);
-	work = alx_clean_rx_irq(alx, budget);
+	tx_complete = alx_clean_tx_irq(np->txq);
+	work = alx_clean_rx_irq(np->rxq, budget);
 
 	if (!tx_complete || work == budget)
 		return budget;
 
-	napi_complete(&alx->napi);
+	napi_complete(&np->napi);
 
 	/* enable interrupt */
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
@@ -350,7 +353,7 @@ static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
 		goto out;
 
 	if (intr & (ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0)) {
-		napi_schedule(&alx->napi);
+		napi_schedule(&alx->qnapi[0]->napi);
 		/* mask rx/tx interrupt, enable them when napi complete */
 		alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
 		alx_write_mem32(hw, ALX_IMR, alx->int_mask);
@@ -365,15 +368,15 @@ static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
 
 static irqreturn_t alx_intr_msix_ring(int irq, void *data)
 {
-	struct alx_priv *alx = data;
-	struct alx_hw *hw = &alx->hw;
+	struct alx_napi *np = data;
+	struct alx_hw *hw = &np->alx->hw;
 
 	/* mask interrupt to ACK chip */
 	alx_mask_msix(hw, 1, true);
 	/* clear interrupt status */
 	alx_write_mem32(hw, ALX_ISR, (ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0));
 
-	napi_schedule(&alx->napi);
+	napi_schedule(&np->napi);
 
 	return IRQ_HANDLED;
 }
@@ -428,59 +431,58 @@ static void alx_init_ring_ptrs(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
 	u32 addr_hi = ((u64)alx->descmem.dma) >> 32;
+	struct alx_napi *np = alx->qnapi[0];
 
-	alx->rxq.read_idx = 0;
-	alx->rxq.write_idx = 0;
-	alx->rxq.rrd_read_idx = 0;
+	np->rxq->read_idx = 0;
+	np->rxq->write_idx = 0;
+	np->rxq->rrd_read_idx = 0;
 	alx_write_mem32(hw, ALX_RX_BASE_ADDR_HI, addr_hi);
-	alx_write_mem32(hw, ALX_RRD_ADDR_LO, alx->rxq.rrd_dma);
+	alx_write_mem32(hw, ALX_RRD_ADDR_LO, np->rxq->rrd_dma);
 	alx_write_mem32(hw, ALX_RRD_RING_SZ, alx->rx_ringsz);
-	alx_write_mem32(hw, ALX_RFD_ADDR_LO, alx->rxq.rfd_dma);
+	alx_write_mem32(hw, ALX_RFD_ADDR_LO, np->rxq->rfd_dma);
 	alx_write_mem32(hw, ALX_RFD_RING_SZ, alx->rx_ringsz);
 	alx_write_mem32(hw, ALX_RFD_BUF_SZ, alx->rxbuf_size);
 
-	alx->txq.read_idx = 0;
-	alx->txq.write_idx = 0;
+	np->txq->read_idx = 0;
+	np->txq->write_idx = 0;
 	alx_write_mem32(hw, ALX_TX_BASE_ADDR_HI, addr_hi);
-	alx_write_mem32(hw, ALX_TPD_PRI0_ADDR_LO, alx->txq.tpd_dma);
+	alx_write_mem32(hw, ALX_TPD_PRI0_ADDR_LO, np->txq->tpd_dma);
 	alx_write_mem32(hw, ALX_TPD_RING_SZ, alx->tx_ringsz);
 
 	/* load these pointers into the chip */
 	alx_write_mem32(hw, ALX_SRAM9, ALX_SRAM_LOAD_PTR);
 }
 
-static void alx_free_txring_buf(struct alx_priv *alx)
+static void alx_free_txring_buf(struct alx_tx_queue *txq)
 {
-	struct alx_tx_queue *txq = &alx->txq;
 	int i;
 
 	if (!txq->bufs)
 		return;
 
-	for (i = 0; i < alx->tx_ringsz; i++)
-		alx_free_txbuf(alx, i);
+	for (i = 0; i < txq->count; i++)
+		alx_free_txbuf(txq, i);
 
-	memset(txq->bufs, 0, alx->tx_ringsz * sizeof(struct alx_buffer));
-	memset(txq->tpd, 0, alx->tx_ringsz * sizeof(struct alx_txd));
+	memset(txq->bufs, 0, txq->count * sizeof(struct alx_buffer));
+	memset(txq->tpd, 0, txq->count * sizeof(struct alx_txd));
 	txq->write_idx = 0;
 	txq->read_idx = 0;
 
-	netdev_reset_queue(alx->dev);
+	netdev_reset_queue(txq->netdev);
 }
 
-static void alx_free_rxring_buf(struct alx_priv *alx)
+static void alx_free_rxring_buf(struct alx_rx_queue *rxq)
 {
-	struct alx_rx_queue *rxq = &alx->rxq;
 	struct alx_buffer *cur_buf;
 	u16 i;
 
 	if (rxq == NULL)
 		return;
 
-	for (i = 0; i < alx->rx_ringsz; i++) {
+	for (i = 0; i < rxq->count; i++) {
 		cur_buf = rxq->bufs + i;
 		if (cur_buf->skb) {
-			dma_unmap_single(&alx->hw.pdev->dev,
+			dma_unmap_single(rxq->dev,
 					 dma_unmap_addr(cur_buf, dma),
 					 dma_unmap_len(cur_buf, size),
 					 DMA_FROM_DEVICE);
@@ -498,8 +500,8 @@ static void alx_free_rxring_buf(struct alx_priv *alx)
 
 static void alx_free_buffers(struct alx_priv *alx)
 {
-	alx_free_txring_buf(alx);
-	alx_free_rxring_buf(alx);
+	alx_free_txring_buf(alx->qnapi[0]->txq);
+	alx_free_rxring_buf(alx->qnapi[0]->rxq);
 }
 
 static int alx_reinit_rings(struct alx_priv *alx)
@@ -576,13 +578,13 @@ static int alx_set_mac_address(struct net_device *netdev, void *data)
 static int alx_alloc_tx_ring(struct alx_priv *alx, struct alx_tx_queue *txq,
 			     int offset)
 {
-	txq->bufs = kcalloc(alx->tx_ringsz, sizeof(struct alx_buffer), GFP_KERNEL);
+	txq->bufs = kcalloc(txq->count, sizeof(struct alx_buffer), GFP_KERNEL);
 	if (!txq->bufs)
 		return -ENOMEM;
 
 	txq->tpd = alx->descmem.virt + offset;
 	txq->tpd_dma = alx->descmem.dma + offset;
-	offset += sizeof(struct alx_txd) * alx->tx_ringsz;
+	offset += sizeof(struct alx_txd) * txq->count;
 
 	return offset;
 }
@@ -590,17 +592,17 @@ static int alx_alloc_tx_ring(struct alx_priv *alx, struct alx_tx_queue *txq,
 static int alx_alloc_rx_ring(struct alx_priv *alx, struct alx_rx_queue *rxq,
 			     int offset)
 {
-	rxq->bufs = kcalloc(alx->rx_ringsz, sizeof(struct alx_buffer), GFP_KERNEL);
+	rxq->bufs = kcalloc(rxq->count, sizeof(struct alx_buffer), GFP_KERNEL);
 	if (!rxq->bufs)
 		return -ENOMEM;
 
 	rxq->rrd = alx->descmem.virt + offset;
 	rxq->rrd_dma = alx->descmem.dma + offset;
-	offset += sizeof(struct alx_rrd) * alx->rx_ringsz;
+	offset += sizeof(struct alx_rrd) * rxq->count;
 
 	rxq->rfd = alx->descmem.virt + offset;
 	rxq->rfd_dma = alx->descmem.dma + offset;
-	offset += sizeof(struct alx_rfd) * alx->rx_ringsz;
+	offset += sizeof(struct alx_rfd) * rxq->count;
 
 	return offset;
 }
@@ -629,13 +631,13 @@ static int alx_alloc_rings(struct alx_priv *alx)
 	BUILD_BUG_ON(sizeof(struct alx_txd) % 8);
 	BUILD_BUG_ON(sizeof(struct alx_rrd) % 8);
 
-	offset = alx_alloc_tx_ring(alx, &alx->txq, offset);
+	offset = alx_alloc_tx_ring(alx, alx->qnapi[0]->txq, offset);
 	if (offset < 0) {
 		netdev_err(alx->dev, "Allocation of tx buffer failed!\n");
 		return -ENOMEM;
 	}
 
-	offset = alx_alloc_rx_ring(alx, &alx->rxq, offset);
+	offset = alx_alloc_rx_ring(alx, alx->qnapi[0]->rxq, offset);
 	if (offset < 0) {
 		netdev_err(alx->dev, "Allocation of rx buffer failed!\n");
 		return -ENOMEM;
@@ -648,10 +650,11 @@ static int alx_alloc_rings(struct alx_priv *alx)
 
 static void alx_free_rings(struct alx_priv *alx)
 {
+
 	alx_free_buffers(alx);
 
-	kfree(alx->txq.bufs);
-	kfree(alx->rxq.bufs);
+	kfree(alx->qnapi[0]->txq->bufs);
+	kfree(alx->qnapi[0]->rxq->bufs);
 
 	if (!alx->descmem.virt)
 		dma_free_coherent(&alx->hw.pdev->dev,
@@ -668,7 +671,7 @@ static void alx_free_napis(struct alx_priv *alx)
 	if (!np)
 		return;
 
-	netif_napi_del(&alx->napi);
+	netif_napi_del(&np->napi);
 	kfree(np->txq);
 	kfree(np->rxq);
 	kfree(np);
@@ -690,7 +693,7 @@ static int alx_alloc_napis(struct alx_priv *alx)
 		goto err_out;
 
 	np->alx = alx;
-	netif_napi_add(alx->dev, &alx->napi, alx_poll, 64);
+	netif_napi_add(alx->dev, &np->napi, alx_poll, 64);
 	alx->qnapi[0] = np;
 
 	/* allocate tx queues */
@@ -768,6 +771,7 @@ static int alx_request_msix(struct alx_priv *alx)
 {
 	struct net_device *netdev = alx->dev;
 	int i, err, vector = 0, free_vector = 0;
+	struct alx_napi *np = alx->qnapi[0];
 
 	err = request_irq(alx->msix_entries[0].vector, alx_intr_msix_misc,
 			  0, netdev->name, alx);
@@ -775,10 +779,10 @@ static int alx_request_msix(struct alx_priv *alx)
 		goto out_err;
 
 	vector++;
-	sprintf(alx->irq_lbl, "%s-TxRx-0", netdev->name);
+	sprintf(np->irq_lbl, "%s-TxRx-0", netdev->name);
 
 	err = request_irq(alx->msix_entries[vector].vector,
-			  alx_intr_msix_ring, 0, alx->irq_lbl, alx);
+			  alx_intr_msix_ring, 0, np->irq_lbl, np);
 		if (err)
 			goto out_free;
 
@@ -789,7 +793,7 @@ static int alx_request_msix(struct alx_priv *alx)
 
 	vector--;
 	for (i = 0; i < vector; i++)
-		free_irq(alx->msix_entries[free_vector++].vector, alx);
+		free_irq(alx->msix_entries[free_vector++].vector, alx->qnapi[0]);
 
 out_err:
 	return err;
@@ -905,12 +909,12 @@ static int alx_request_irq(struct alx_priv *alx)
 static void alx_free_irq(struct alx_priv *alx)
 {
 	struct pci_dev *pdev = alx->hw.pdev;
-	int i;
+	int i, vector = 0;
 
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
 		/* we have only 2 vectors without multi queue support */
-		for (i = 0; i < 2; i++)
-			free_irq(alx->msix_entries[i].vector, alx);
+		free_irq(alx->msix_entries[vector++].vector, alx);
+		free_irq(alx->msix_entries[vector++].vector, alx->qnapi[0]);
 	} else {
 		free_irq(pdev->irq, alx);
 	}
@@ -999,7 +1003,7 @@ static void alx_netif_stop(struct alx_priv *alx)
 	if (netif_carrier_ok(alx->dev)) {
 		netif_carrier_off(alx->dev);
 		netif_tx_disable(alx->dev);
-		napi_disable(&alx->napi);
+		napi_disable(&alx->qnapi[0]->napi);
 	}
 }
 
@@ -1069,7 +1073,7 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
 static void alx_netif_start(struct alx_priv *alx)
 {
 	netif_tx_wake_all_queues(alx->dev);
-	napi_enable(&alx->napi);
+	napi_enable(&alx->qnapi[0]->napi);
 	netif_carrier_on(alx->dev);
 }
 
@@ -1303,9 +1307,8 @@ static int alx_tso(struct sk_buff *skb, struct alx_txd *first)
 	return 1;
 }
 
-static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
+static int alx_map_tx_skb(struct alx_tx_queue *txq, struct sk_buff *skb)
 {
-	struct alx_tx_queue *txq = &alx->txq;
 	struct alx_txd *tpd, *first_tpd;
 	dma_addr_t dma;
 	int maplen, f, first_idx = txq->write_idx;
@@ -1314,7 +1317,7 @@ static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 	tpd = first_tpd;
 
 	if (tpd->word1 & (1 << TPD_LSO_V2_SHIFT)) {
-		if (++txq->write_idx == alx->tx_ringsz)
+		if (++txq->write_idx == txq->count)
 			txq->write_idx = 0;
 
 		tpd = &txq->tpd[txq->write_idx];
@@ -1324,9 +1327,9 @@ static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 	}
 
 	maplen = skb_headlen(skb);
-	dma = dma_map_single(&alx->hw.pdev->dev, skb->data, maplen,
+	dma = dma_map_single(txq->dev, skb->data, maplen,
 			     DMA_TO_DEVICE);
-	if (dma_mapping_error(&alx->hw.pdev->dev, dma))
+	if (dma_mapping_error(txq->dev, dma))
 		goto err_dma;
 
 	dma_unmap_len_set(&txq->bufs[txq->write_idx], size, maplen);
@@ -1340,16 +1343,16 @@ static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 
 		frag = &skb_shinfo(skb)->frags[f];
 
-		if (++txq->write_idx == alx->tx_ringsz)
+		if (++txq->write_idx == txq->count)
 			txq->write_idx = 0;
 		tpd = &txq->tpd[txq->write_idx];
 
 		tpd->word1 = first_tpd->word1;
 
 		maplen = skb_frag_size(frag);
-		dma = skb_frag_dma_map(&alx->hw.pdev->dev, frag, 0,
+		dma = skb_frag_dma_map(txq->dev, frag, 0,
 				       maplen, DMA_TO_DEVICE);
-		if (dma_mapping_error(&alx->hw.pdev->dev, dma))
+		if (dma_mapping_error(txq->dev, dma))
 			goto err_dma;
 		dma_unmap_len_set(&txq->bufs[txq->write_idx], size, maplen);
 		dma_unmap_addr_set(&txq->bufs[txq->write_idx], dma, dma);
@@ -1362,7 +1365,7 @@ static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 	tpd->word1 |= cpu_to_le32(1 << TPD_EOP_SHIFT);
 	txq->bufs[txq->write_idx].skb = skb;
 
-	if (++txq->write_idx == alx->tx_ringsz)
+	if (++txq->write_idx == txq->count)
 		txq->write_idx = 0;
 
 	return 0;
@@ -1370,8 +1373,8 @@ static int alx_map_tx_skb(struct alx_priv *alx, struct sk_buff *skb)
 err_dma:
 	f = first_idx;
 	while (f != txq->write_idx) {
-		alx_free_txbuf(alx, f);
-		if (++f == alx->tx_ringsz)
+		alx_free_txbuf(txq, f);
+		if (++f == txq->count)
 			f = 0;
 	}
 	return -ENOMEM;
@@ -1381,12 +1384,12 @@ static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
 				  struct net_device *netdev)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
-	struct alx_tx_queue *txq = &alx->txq;
+	struct alx_tx_queue *txq = alx->qnapi[0]->txq;
 	struct alx_txd *first;
 	int tso;
 
-	if (alx_tpd_avail(alx) < alx_tpd_req(skb)) {
-		netif_stop_queue(alx->dev);
+	if (alx_tpd_avail(txq) < alx_tpd_req(skb)) {
+		netif_stop_queue(txq->netdev);
 		goto drop;
 	}
 
@@ -1399,17 +1402,17 @@ static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
 	else if (!tso && alx_tx_csum(skb, first))
 		goto drop;
 
-	if (alx_map_tx_skb(alx, skb) < 0)
+	if (alx_map_tx_skb(txq, skb) < 0)
 		goto drop;
 
-	netdev_sent_queue(alx->dev, skb->len);
+	netdev_sent_queue(txq->netdev, skb->len);
 
 	/* flush updates before updating hardware */
 	wmb();
 	alx_write_mem16(&alx->hw, ALX_TPD_PRI0_PIDX, txq->write_idx);
 
-	if (alx_tpd_avail(alx) < alx->tx_ringsz/8)
-		netif_stop_queue(alx->dev);
+	if (alx_tpd_avail(txq) < txq->count / 8)
+		netif_stop_queue(txq->netdev);
 
 	return NETDEV_TX_OK;
 
@@ -1478,7 +1481,7 @@ static void alx_poll_controller(struct net_device *netdev)
 
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
 		alx_intr_msix_misc(0, alx);
-		alx_intr_msix_ring(0, alx);
+		alx_intr_msix_ring(0, alx->qnapi[0]);
 	} else if (alx->flags & ALX_FLAG_USING_MSI)
 		alx_intr_msi(0, alx);
 	else
-- 
2.7.4
