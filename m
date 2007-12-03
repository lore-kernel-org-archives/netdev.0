From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Fix memory corruption in fec_mpc52xx
Date: Mon, 03 Dec 2007 22:38:10 +0000
Message-ID: <1196721490.13978.185.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Domen Puncer <domen.puncer@telargo.com>,
	Jon Smirl <jonsmirl@gmail.com>,
	Grant Likely <grant.likely@secretlab.ca>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59812 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbXLCWiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 17:38:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Smirl <jonsmirl@gmail.com>

The mpc5200 fec driver is corrupting memory. This patch fixes two bugs
where the wrong skb was being referenced.

Signed-off-by: Jon Smirl <jonsmirl@gmail.com>
Acked-by: Domen Puncer <domen.puncer@telargo.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: David Woodhouse <dwmw2@infradead.org>

--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -422,7 +422,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)

 		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
 				(struct bcom_bd **)&bd);
-		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len, DMA_FROM_DEVICE);

 		/* Test for errors in received frame */
 		if (status & BCOM_FEC_RX_BD_ERRORS) {
@@ -467,7 +467,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 			bcom_prepare_next_buffer(priv->rx_dmatsk);

 		bd->status = FEC_RX_BUFFER_SIZE;
-		bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
+		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);

 		bcom_submit_next_buffer(priv->rx_dmatsk, skb);


-- 
dwmw2

