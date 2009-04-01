From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 1/3] net/fec_mpc52xx: fix BUG on missing dma_ops
Date: Wed, 01 Apr 2009 00:16:52 -0600
Message-ID: <20090401061652.8641.95089.stgit@localhost.localdomain>
References: <20090401060117.8641.32252.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:45993 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142AbZDAGQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:16:58 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3442346rvb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 23:16:55 -0700 (PDT)
In-Reply-To: <20090401060117.8641.32252.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

The driver triggers a BUG_ON() when allocating DMA buffers because the
arch/powerpc dma_ops aren't in the net_device's struct device.  This
patch fixes the problem by using the parent of_device which does have
the correct dma_ops set.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Reviewed-by: Becky Bruce <beckyb@kernel.crashing.org>
---

 drivers/net/fec_mpc52xx.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)


diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 049b0a7..f99463f 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -129,7 +129,8 @@ static void mpc52xx_fec_free_rx_buffers(struct net_device *dev, struct bcom_task
 		struct sk_buff *skb;
 
 		skb = bcom_retrieve_buffer(s, NULL, (struct bcom_bd **)&bd);
-		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+		dma_unmap_single(dev->dev.parent, bd->skb_pa, skb->len,
+				 DMA_FROM_DEVICE);
 		kfree_skb(skb);
 	}
 }
@@ -150,7 +151,7 @@ static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task
 		bd = (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
 
 		bd->status = FEC_RX_BUFFER_SIZE;
-		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
+		bd->skb_pa = dma_map_single(dev->dev.parent, skb->data,
 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
 
 		bcom_submit_next_buffer(rxtsk, skb);
@@ -388,7 +389,8 @@ static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *d
 		bcom_prepare_next_buffer(priv->tx_dmatsk);
 
 	bd->status = skb->len | BCOM_FEC_TX_BD_TFD | BCOM_FEC_TX_BD_TC;
-	bd->skb_pa = dma_map_single(&dev->dev, skb->data, skb->len, DMA_TO_DEVICE);
+	bd->skb_pa = dma_map_single(dev->dev.parent, skb->data, skb->len,
+				    DMA_TO_DEVICE);
 
 	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
 
@@ -430,7 +432,8 @@ static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
 		struct bcom_fec_bd *bd;
 		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL,
 				(struct bcom_bd **)&bd);
-		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_TO_DEVICE);
+		dma_unmap_single(dev->dev.parent, bd->skb_pa, skb->len,
+				 DMA_TO_DEVICE);
 
 		dev_kfree_skb_irq(skb);
 	}
@@ -455,7 +458,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 
 		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
 				(struct bcom_bd **)&bd);
-		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len, DMA_FROM_DEVICE);
+		dma_unmap_single(dev->dev.parent, bd->skb_pa, rskb->len,
+				 DMA_FROM_DEVICE);
 
 		/* Test for errors in received frame */
 		if (status & BCOM_FEC_RX_BD_ERRORS) {
@@ -464,7 +468,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 				bcom_prepare_next_buffer(priv->rx_dmatsk);
 
 			bd->status = FEC_RX_BUFFER_SIZE;
-			bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
+			bd->skb_pa = dma_map_single(dev->dev.parent,
+					rskb->data,
 					FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
 
 			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
@@ -499,7 +504,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 			bcom_prepare_next_buffer(priv->rx_dmatsk);
 
 		bd->status = FEC_RX_BUFFER_SIZE;
-		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
+		bd->skb_pa = dma_map_single(dev->dev.parent, skb->data,
 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
 
 		bcom_submit_next_buffer(priv->rx_dmatsk, skb);

