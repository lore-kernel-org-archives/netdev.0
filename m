From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 6/9] alx: prepare resource allocation for multi queue support
Date: Tue, 15 Nov 2016 12:43:13 +0100
Message-ID: <15019632da0d20b0ee026f82dcca118f504d38e8.1479208629.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33411 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbcKOLni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:38 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so24870198wmu.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:38 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate, initialise and free alx_tx_queue structs based on the number of
alx_napi structures. Also increase the size of the descriptor memory based
on the number of tx queues in use.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 149 +++++++++++++++++++++-----------
 1 file changed, 97 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index aeb42120910d..c5f09d2616a4 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -429,28 +429,45 @@ static irqreturn_t alx_intr_legacy(int irq, void *data)
 	return alx_intr_handle(alx, intr);
 }
 
+static const u16 txring_header_reg[] = {ALX_TPD_PRI0_ADDR_LO,
+					ALX_TPD_PRI1_ADDR_LO,
+					ALX_TPD_PRI2_ADDR_LO,
+					ALX_TPD_PRI3_ADDR_LO};
+
 static void alx_init_ring_ptrs(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
 	u32 addr_hi = ((u64)alx->descmem.dma) >> 32;
-	struct alx_napi *np = alx->qnapi[0];
+	struct alx_napi *np;
+	int i;
+
+	for (i = 0; i < alx->num_napi; i++) {
+		np = alx->qnapi[i];
+		if (np->txq) {
+			np->txq->read_idx = 0;
+			np->txq->write_idx = 0;
+			alx_write_mem32(hw,
+					txring_header_reg[np->txq->queue_idx],
+					np->txq->tpd_dma);
+		}
+
+		if (np->rxq) {
+			np->rxq->read_idx = 0;
+			np->rxq->write_idx = 0;
+			np->rxq->rrd_read_idx = 0;
+			alx_write_mem32(hw, ALX_RRD_ADDR_LO, np->rxq->rrd_dma);
+			alx_write_mem32(hw, ALX_RFD_ADDR_LO, np->rxq->rfd_dma);
+		}
+	}
+
+	alx_write_mem32(hw, ALX_TX_BASE_ADDR_HI, addr_hi);
+	alx_write_mem32(hw, ALX_TPD_RING_SZ, alx->tx_ringsz);
 
-	np->rxq->read_idx = 0;
-	np->rxq->write_idx = 0;
-	np->rxq->rrd_read_idx = 0;
 	alx_write_mem32(hw, ALX_RX_BASE_ADDR_HI, addr_hi);
-	alx_write_mem32(hw, ALX_RRD_ADDR_LO, np->rxq->rrd_dma);
 	alx_write_mem32(hw, ALX_RRD_RING_SZ, alx->rx_ringsz);
-	alx_write_mem32(hw, ALX_RFD_ADDR_LO, np->rxq->rfd_dma);
 	alx_write_mem32(hw, ALX_RFD_RING_SZ, alx->rx_ringsz);
 	alx_write_mem32(hw, ALX_RFD_BUF_SZ, alx->rxbuf_size);
 
-	np->txq->read_idx = 0;
-	np->txq->write_idx = 0;
-	alx_write_mem32(hw, ALX_TX_BASE_ADDR_HI, addr_hi);
-	alx_write_mem32(hw, ALX_TPD_PRI0_ADDR_LO, np->txq->tpd_dma);
-	alx_write_mem32(hw, ALX_TPD_RING_SZ, alx->tx_ringsz);
-
 	/* load these pointers into the chip */
 	alx_write_mem32(hw, ALX_SRAM9, ALX_SRAM_LOAD_PTR);
 }
@@ -478,7 +495,7 @@ static void alx_free_rxring_buf(struct alx_rx_queue *rxq)
 	struct alx_buffer *cur_buf;
 	u16 i;
 
-	if (rxq == NULL)
+	if (!rxq->bufs)
 		return;
 
 	for (i = 0; i < rxq->count; i++) {
@@ -502,8 +519,14 @@ static void alx_free_rxring_buf(struct alx_rx_queue *rxq)
 
 static void alx_free_buffers(struct alx_priv *alx)
 {
-	alx_free_txring_buf(alx->qnapi[0]->txq);
-	alx_free_rxring_buf(alx->qnapi[0]->rxq);
+	int i;
+
+	for (i = 0; i < alx->num_txq; i++)
+		if (alx->qnapi[i] && alx->qnapi[i]->txq)
+			alx_free_txring_buf(alx->qnapi[i]->txq);
+
+	if (alx->qnapi[0] && alx->qnapi[0]->rxq)
+		alx_free_rxring_buf(alx->qnapi[0]->rxq);
 }
 
 static int alx_reinit_rings(struct alx_priv *alx)
@@ -611,7 +634,7 @@ static int alx_alloc_rx_ring(struct alx_priv *alx, struct alx_rx_queue *rxq,
 
 static int alx_alloc_rings(struct alx_priv *alx)
 {
-	int offset = 0;
+	int i, offset = 0;
 
 	/* physical tx/rx ring descriptors
 	 *
@@ -619,7 +642,8 @@ static int alx_alloc_rings(struct alx_priv *alx)
 	 * 4G boundary (hardware has a single register for high 32 bits
 	 * of addresses only)
 	 */
-	alx->descmem.size = sizeof(struct alx_txd) * alx->tx_ringsz +
+	alx->descmem.size = sizeof(struct alx_txd) * alx->tx_ringsz *
+			    alx->num_txq +
 			    sizeof(struct alx_rrd) * alx->rx_ringsz +
 			    sizeof(struct alx_rfd) * alx->rx_ringsz;
 	alx->descmem.virt = dma_zalloc_coherent(&alx->hw.pdev->dev,
@@ -633,10 +657,12 @@ static int alx_alloc_rings(struct alx_priv *alx)
 	BUILD_BUG_ON(sizeof(struct alx_txd) % 8);
 	BUILD_BUG_ON(sizeof(struct alx_rrd) % 8);
 
-	offset = alx_alloc_tx_ring(alx, alx->qnapi[0]->txq, offset);
-	if (offset < 0) {
-		netdev_err(alx->dev, "Allocation of tx buffer failed!\n");
-		return -ENOMEM;
+	for (i = 0; i < alx->num_txq; i++) {
+		offset = alx_alloc_tx_ring(alx, alx->qnapi[i]->txq, offset);
+		if (offset < 0) {
+			netdev_err(alx->dev, "Allocation of tx buffer failed!\n");
+			return -ENOMEM;
+		}
 	}
 
 	offset = alx_alloc_rx_ring(alx, alx->qnapi[0]->rxq, offset);
@@ -652,11 +678,16 @@ static int alx_alloc_rings(struct alx_priv *alx)
 
 static void alx_free_rings(struct alx_priv *alx)
 {
+	int i;
 
 	alx_free_buffers(alx);
 
-	kfree(alx->qnapi[0]->txq->bufs);
-	kfree(alx->qnapi[0]->rxq->bufs);
+	for (i = 0; i < alx->num_txq; i++)
+		if (alx->qnapi[i] && alx->qnapi[i]->txq)
+			kfree(alx->qnapi[i]->txq->bufs);
+
+	if (alx->qnapi[0] && alx->qnapi[0]->rxq)
+		kfree(alx->qnapi[0]->rxq->bufs);
 
 	if (!alx->descmem.virt)
 		dma_free_coherent(&alx->hw.pdev->dev,
@@ -668,16 +699,19 @@ static void alx_free_rings(struct alx_priv *alx)
 static void alx_free_napis(struct alx_priv *alx)
 {
 	struct alx_napi *np;
+	int i;
 
-	np = alx->qnapi[0];
-	if (!np)
-		return;
-
-	netif_napi_del(&np->napi);
-	kfree(np->txq);
-	kfree(np->rxq);
-	kfree(np);
-	alx->qnapi[0] = NULL;
+	for (i = 0; i < alx->num_napi; i++) {
+		np = alx->qnapi[i];
+		if (!np)
+			continue;
+
+		netif_napi_del(&np->napi);
+		kfree(np->txq);
+		kfree(np->rxq);
+		kfree(np);
+		alx->qnapi[i] = NULL;
+	}
 }
 
 static const u32 tx_vect_mask[] = {ALX_ISR_TX_Q0, ALX_ISR_TX_Q1,
@@ -692,31 +726,36 @@ static int alx_alloc_napis(struct alx_priv *alx)
 	struct alx_napi *np;
 	struct alx_rx_queue *rxq;
 	struct alx_tx_queue *txq;
+	int i;
 
 	alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
 
 	/* allocate alx_napi structures */
-	np = kzalloc(sizeof(struct alx_napi), GFP_KERNEL);
-	if (!np)
-		goto err_out;
+	for (i = 0; i < alx->num_napi; i++) {
+		np = kzalloc(sizeof(struct alx_napi), GFP_KERNEL);
+		if (!np)
+			goto err_out;
 
-	np->alx = alx;
-	netif_napi_add(alx->dev, &np->napi, alx_poll, 64);
-	alx->qnapi[0] = np;
+		np->alx = alx;
+		netif_napi_add(alx->dev, &np->napi, alx_poll, 64);
+		alx->qnapi[i] = np;
+	}
 
 	/* allocate tx queues */
-	np = alx->qnapi[0];
-	txq = kzalloc(sizeof(*txq), GFP_KERNEL);
-	if (!txq)
-		goto err_out;
-
-	np->txq = txq;
-	txq->queue_idx = 0;
-	txq->count = alx->tx_ringsz;
-	txq->netdev = alx->dev;
-	txq->dev = &alx->hw.pdev->dev;
-	np->vec_mask |= tx_vect_mask[0];
-	alx->int_mask |= tx_vect_mask[0];
+	for (i = 0; i < alx->num_txq; i++) {
+		np = alx->qnapi[i];
+		txq = kzalloc(sizeof(*txq), GFP_KERNEL);
+		if (!txq)
+			goto err_out;
+
+		np->txq = txq;
+		txq->queue_idx = i;
+		txq->count = alx->tx_ringsz;
+		txq->netdev = alx->dev;
+		txq->dev = &alx->hw.pdev->dev;
+		np->vec_mask |= tx_vect_mask[i];
+		alx->int_mask |= tx_vect_mask[i];
+	}
 
 	/* allocate rx queues */
 	np = alx->qnapi[0];
@@ -1075,11 +1114,14 @@ static netdev_features_t alx_fix_features(struct net_device *netdev,
 
 static void alx_netif_stop(struct alx_priv *alx)
 {
+	int i;
+
 	netif_trans_update(alx->dev);
 	if (netif_carrier_ok(alx->dev)) {
 		netif_carrier_off(alx->dev);
 		netif_tx_disable(alx->dev);
-		napi_disable(&alx->qnapi[0]->napi);
+		for (i = 0; i < alx->num_napi; i++)
+			napi_disable(&alx->qnapi[i]->napi);
 	}
 }
 
@@ -1148,8 +1190,11 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
 
 static void alx_netif_start(struct alx_priv *alx)
 {
+	int i;
+
 	netif_tx_wake_all_queues(alx->dev);
-	napi_enable(&alx->qnapi[0]->napi);
+	for (i = 0; i < alx->num_napi; i++)
+		napi_enable(&alx->qnapi[i]->napi);
 	netif_carrier_on(alx->dev);
 }
 
-- 
2.7.4
