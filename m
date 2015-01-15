From: Kukjin Kim <kgene@kernel.org>
Subject: [PATCH] [PATCH] net: sxgbe: Fix waring for double kfree()
Date: Thu, 15 Jan 2015 10:43:11 +0900
Message-ID: <1421286191-9550-1-git-send-email-kgene@kernel.org>
Cc: Dave Miller <davem@davemloft.ne>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Byungho An <bh74.an@samsung.com>, Kukjin Kim <kgene@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:27175 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbbAOBnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 20:43:08 -0500
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI700FYE3FVVB60@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 15 Jan 2015 10:43:07 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>

This patch fixes double kfree() calls at init_rx_ring() because
it causes static checker warning.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
Signed-off-by: Kukjin Kim <kgene@kernel.org>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 6984944..fe7538d 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -474,13 +474,19 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 	/* allocate memory for RX skbuff array */
 	rx_ring->rx_skbuff_dma = kmalloc_array(rx_rsize,
 					       sizeof(dma_addr_t), GFP_KERNEL);
-	if (rx_ring->rx_skbuff_dma == NULL)
-		goto dmamem_err;
+	if (!rx_ring->rx_skbuff_dma) {
+		dma_free_coherent(priv->device,
+				  rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
+				  rx_ring->dma_rx, rx_ring->dma_rx_phy);
+		goto error;
+	}
 
 	rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
 					   sizeof(struct sk_buff *), GFP_KERNEL);
-	if (rx_ring->rx_skbuff == NULL)
-		goto rxbuff_err;
+	if (!rx_ring->rx_skbuff) {
+		kfree(rx_ring->rx_skbuff_dma);
+		goto error;
+	}
 
 	/* initialise the buffers */
 	for (desc_index = 0; desc_index < rx_rsize; desc_index++) {
@@ -502,13 +508,6 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 err_init_rx_buffers:
 	while (--desc_index >= 0)
 		free_rx_ring(priv->device, rx_ring, desc_index);
-	kfree(rx_ring->rx_skbuff);
-rxbuff_err:
-	kfree(rx_ring->rx_skbuff_dma);
-dmamem_err:
-	dma_free_coherent(priv->device,
-			  rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
-			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
 error:
 	return -ENOMEM;
 }
-- 
2.0.0
