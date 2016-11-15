From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 3/9] alx: add ability to allocate and free alx_napi structures
Date: Tue, 15 Nov 2016 12:43:10 +0100
Message-ID: <406ba04f4d5f814ee5f7ea495e3100bec53b5e27.1479208628.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34241 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbcKOLne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:34 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so24986663wme.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:33 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new functions to allocate and free the alx_napi structures and use them
in __alx_open and __alx_stop. We only allocate one of these structures for
now, as the rest of the driver is not yet ready for multiple queues.

We switch over the setup of the interrupt mask and the call to netif_napi_add
to the new function because we must adjust these later on a per queue basis.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 99 ++++++++++++++++++++++++++-------
 1 file changed, 78 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 8935766829b1..193da6799979 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -632,45 +632,96 @@ static int alx_alloc_rings(struct alx_priv *alx)
 	offset = alx_alloc_tx_ring(alx, &alx->txq, offset);
 	if (offset < 0) {
 		netdev_err(alx->dev, "Allocation of tx buffer failed!\n");
-		goto out_free;
+		return -ENOMEM;
 	}
 
 	offset = alx_alloc_rx_ring(alx, &alx->rxq, offset);
 	if (offset < 0) {
 		netdev_err(alx->dev, "Allocation of rx buffer failed!\n");
-		goto out_free;
+		return -ENOMEM;
 	}
 
-	alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
-	alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
-
-	netif_napi_add(alx->dev, &alx->napi, alx_poll, 64);
-
 	alx_reinit_rings(alx);
 
 	return 0;
-out_free:
-	kfree(alx->txq.bufs);
-	kfree(alx->rxq.bufs);
-	dma_free_coherent(&alx->hw.pdev->dev,
-			  alx->descmem.size,
-			  alx->descmem.virt,
-			  alx->descmem.dma);
-	return -ENOMEM;
 }
 
 static void alx_free_rings(struct alx_priv *alx)
 {
-	netif_napi_del(&alx->napi);
 	alx_free_buffers(alx);
 
 	kfree(alx->txq.bufs);
 	kfree(alx->rxq.bufs);
 
-	dma_free_coherent(&alx->hw.pdev->dev,
-			  alx->descmem.size,
-			  alx->descmem.virt,
-			  alx->descmem.dma);
+	if (!alx->descmem.virt)
+		dma_free_coherent(&alx->hw.pdev->dev,
+				  alx->descmem.size,
+				  alx->descmem.virt,
+				  alx->descmem.dma);
+}
+
+static void alx_free_napis(struct alx_priv *alx)
+{
+	struct alx_napi *np;
+
+	np = alx->qnapi[0];
+	if (!np)
+		return;
+
+	netif_napi_del(&alx->napi);
+	kfree(np->txq);
+	kfree(np->rxq);
+	kfree(np);
+	alx->qnapi[0] = NULL;
+}
+
+static int alx_alloc_napis(struct alx_priv *alx)
+{
+	struct alx_napi *np;
+	struct alx_rx_queue *rxq;
+	struct alx_tx_queue *txq;
+
+	alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
+	alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
+
+	/* allocate alx_napi structures */
+	np = kzalloc(sizeof(struct alx_napi), GFP_KERNEL);
+	if (!np)
+		goto err_out;
+
+	np->alx = alx;
+	netif_napi_add(alx->dev, &alx->napi, alx_poll, 64);
+	alx->qnapi[0] = np;
+
+	/* allocate tx queues */
+	np = alx->qnapi[0];
+	txq = kzalloc(sizeof(*txq), GFP_KERNEL);
+	if (!txq)
+		goto err_out;
+
+	np->txq = txq;
+	txq->count = alx->tx_ringsz;
+	txq->netdev = alx->dev;
+	txq->dev = &alx->hw.pdev->dev;
+
+	/* allocate rx queues */
+	np = alx->qnapi[0];
+	rxq = kzalloc(sizeof(*rxq), GFP_KERNEL);
+	if (!rxq)
+		goto err_out;
+
+	np->rxq = rxq;
+	rxq->np = alx->qnapi[0];
+	rxq->count = alx->rx_ringsz;
+	rxq->netdev = alx->dev;
+	rxq->dev = &alx->hw.pdev->dev;
+
+	return 0;
+
+err_out:
+	netdev_err(alx->dev, "error allocating internal structures\n");
+	alx_free_napis(alx);
+	return -ENOMEM;
 }
 
 static void alx_config_vector_mapping(struct alx_priv *alx)
@@ -1031,10 +1082,14 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 	if (!resume)
 		netif_carrier_off(alx->dev);
 
-	err = alx_alloc_rings(alx);
+	err = alx_alloc_napis(alx);
 	if (err)
 		goto out_disable_adv_intr;
 
+	err = alx_alloc_rings(alx);
+	if (err)
+		goto out_free_rings;
+
 	alx_configure(alx);
 
 	err = alx_request_irq(alx);
@@ -1054,6 +1109,7 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 
 out_free_rings:
 	alx_free_rings(alx);
+	alx_free_napis(alx);
 out_disable_adv_intr:
 	alx_disable_advanced_intr(alx);
 	return err;
@@ -1064,6 +1120,7 @@ static void __alx_stop(struct alx_priv *alx)
 	alx_halt(alx);
 	alx_free_irq(alx);
 	alx_free_rings(alx);
+	alx_free_napis(alx);
 }
 
 static const char *alx_speed_desc(struct alx_hw *hw)
-- 
2.7.4
