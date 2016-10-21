From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 1/9] alx: refactor descriptor allocation
Date: Fri, 21 Oct 2016 12:49:44 +0200
Message-ID: <4118b3b705404f4ce27aaa389697c12f5319aaef.1477044918.git.tobias.regnery@gmail.com>
References: <cover.1477044917.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35092 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754266AbcJUKu1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:50:27 -0400
Received: by mail-lf0-f67.google.com with SMTP id x79so5002895lff.2
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 03:50:26 -0700 (PDT)
In-Reply-To: <cover.1477044917.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1477044917.git.tobias.regnery@gmail.com>
References: <cover.1477044917.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the allocation of descriptor memory and the buffer allocation into a
tx and rx function. This is in preparation for multiple queues where we
need to iterate over the new functions.

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 97 ++++++++++++++++++---------------
 1 file changed, 53 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index eccbacd96201..b7e67dd3d995 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -573,19 +573,41 @@ static int alx_set_mac_address(struct net_device *netdev, void *data)
 	return 0;
 }
 
-static int alx_alloc_descriptors(struct alx_priv *alx)
+static int alx_alloc_tx_ring(struct alx_priv *alx, struct alx_tx_queue *txq,
+			     int offset)
 {
-	alx->txq.bufs = kcalloc(alx->tx_ringsz,
-				sizeof(struct alx_buffer),
-				GFP_KERNEL);
-	if (!alx->txq.bufs)
+	txq->bufs = kcalloc(alx->tx_ringsz, sizeof(struct alx_buffer), GFP_KERNEL);
+	if (!txq->bufs)
 		return -ENOMEM;
 
-	alx->rxq.bufs = kcalloc(alx->rx_ringsz,
-				sizeof(struct alx_buffer),
-				GFP_KERNEL);
-	if (!alx->rxq.bufs)
-		goto out_free;
+	txq->tpd = alx->descmem.virt + offset;
+	txq->tpd_dma = alx->descmem.dma + offset;
+	offset += sizeof(struct alx_txd) * alx->tx_ringsz;
+
+	return offset;
+}
+
+static int alx_alloc_rx_ring(struct alx_priv *alx, struct alx_rx_queue *rxq,
+			     int offset)
+{
+	rxq->bufs = kcalloc(alx->rx_ringsz, sizeof(struct alx_buffer), GFP_KERNEL);
+	if (!rxq->bufs)
+		return -ENOMEM;
+
+	rxq->rrd = (void *)((u8 *)alx->descmem.virt + offset);
+	rxq->rrd_dma = alx->descmem.dma + offset;
+	offset += sizeof(struct alx_rrd) * alx->rx_ringsz;
+
+	rxq->rfd = (void *)((u8 *)alx->descmem.virt + offset);
+	rxq->rfd_dma = alx->descmem.dma + offset;
+	offset += sizeof(struct alx_rfd) * alx->rx_ringsz;
+
+	return offset;
+}
+
+static int alx_alloc_rings(struct alx_priv *alx)
+{
+	int offset = 0;
 
 	/* physical tx/rx ring descriptors
 	 *
@@ -601,45 +623,23 @@ static int alx_alloc_descriptors(struct alx_priv *alx)
 						&alx->descmem.dma,
 						GFP_KERNEL);
 	if (!alx->descmem.virt)
-		goto out_free;
-
-	alx->txq.tpd = alx->descmem.virt;
-	alx->txq.tpd_dma = alx->descmem.dma;
+		return -ENOMEM;
 
-	/* alignment requirement for next block */
+	/* alignment requirements */
 	BUILD_BUG_ON(sizeof(struct alx_txd) % 8);
-
-	alx->rxq.rrd =
-		(void *)((u8 *)alx->descmem.virt +
-			 sizeof(struct alx_txd) * alx->tx_ringsz);
-	alx->rxq.rrd_dma = alx->descmem.dma +
-			   sizeof(struct alx_txd) * alx->tx_ringsz;
-
-	/* alignment requirement for next block */
 	BUILD_BUG_ON(sizeof(struct alx_rrd) % 8);
 
-	alx->rxq.rfd =
-		(void *)((u8 *)alx->descmem.virt +
-			 sizeof(struct alx_txd) * alx->tx_ringsz +
-			 sizeof(struct alx_rrd) * alx->rx_ringsz);
-	alx->rxq.rfd_dma = alx->descmem.dma +
-			   sizeof(struct alx_txd) * alx->tx_ringsz +
-			   sizeof(struct alx_rrd) * alx->rx_ringsz;
-
-	return 0;
-out_free:
-	kfree(alx->txq.bufs);
-	kfree(alx->rxq.bufs);
-	return -ENOMEM;
-}
-
-static int alx_alloc_rings(struct alx_priv *alx)
-{
-	int err;
+	offset = alx_alloc_tx_ring(alx, &alx->txq, offset);
+	if (offset < 0) {
+		netdev_err(alx->dev, "Allocation of tx buffer failed!\n");
+		goto out_free;
+	}
 
-	err = alx_alloc_descriptors(alx);
-	if (err)
-		return err;
+	offset = alx_alloc_rx_ring(alx, &alx->rxq, offset);
+	if (offset < 0) {
+		netdev_err(alx->dev, "Allocation of rx buffer failed!\n");
+		goto out_free;
+	}
 
 	alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
 	alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
@@ -647,7 +647,16 @@ static int alx_alloc_rings(struct alx_priv *alx)
 	netif_napi_add(alx->dev, &alx->napi, alx_poll, 64);
 
 	alx_reinit_rings(alx);
+
 	return 0;
+out_free:
+	kfree(alx->txq.bufs);
+	kfree(alx->rxq.bufs);
+	dma_free_coherent(&alx->hw.pdev->dev,
+			  alx->descmem.size,
+			  alx->descmem.virt,
+			  alx->descmem.dma);
+	return -ENOMEM;
 }
 
 static void alx_free_rings(struct alx_priv *alx)
-- 
2.7.4
