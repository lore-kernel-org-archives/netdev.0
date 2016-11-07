From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC net-next] ravb: Add dma_unmap_single in ravb_ring_free
Date: Mon,  7 Nov 2016 16:27:31 +0100
Message-ID: <1478532451-7296-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53325 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbcKGP1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 10:27:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

The kernel panic occurs with "swiotlb buffer is full" message
after repeating suspend and resume, because dma_map_single of
ravb_ring_format and ravb_start_xmit is not released.
This patch adds dma_unmap_single in ravb_ring_free, and fixes
its problem.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
Sergei, this is a patch from the Gen3 3.3.2 BSP.
Please consider if it is appropriate for mainline.
---
 drivers/net/ethernet/renesas/ravb_main.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 27cfec3154c8..e44629b75c83 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -185,6 +185,9 @@ static void ravb_ring_free(struct net_device *ndev, int q)
 	struct ravb_private *priv = netdev_priv(ndev);
 	int ring_size;
 	int i;
+	struct ravb_ex_rx_desc *rx_desc;
+	struct ravb_tx_desc *tx_desc;
+	u32 size;
 
 	/* Free RX skb ringbuffer */
 	if (priv->rx_skb[q]) {
@@ -207,6 +210,16 @@ static void ravb_ring_free(struct net_device *ndev, int q)
 	priv->tx_align[q] = NULL;
 
 	if (priv->rx_ring[q]) {
+		for (i = 0; i < priv->num_rx_ring[q]; i++) {
+			rx_desc = &priv->rx_ring[q][i];
+			if (rx_desc->dptr != 0) {
+				dma_unmap_single(ndev->dev.parent,
+						 le32_to_cpu(rx_desc->dptr),
+						 PKT_BUF_SZ,
+						 DMA_FROM_DEVICE);
+				rx_desc->dptr = 0;
+			}
+		}
 		ring_size = sizeof(struct ravb_ex_rx_desc) *
 			    (priv->num_rx_ring[q] + 1);
 		dma_free_coherent(ndev->dev.parent, ring_size, priv->rx_ring[q],
@@ -215,6 +228,16 @@ static void ravb_ring_free(struct net_device *ndev, int q)
 	}
 
 	if (priv->tx_ring[q]) {
+		for (i = 0; i < priv->num_tx_ring[q]; i++) {
+			tx_desc = &priv->tx_ring[q][i];
+			size = le16_to_cpu(tx_desc->ds_tagl) & TX_DS;
+			if (tx_desc->dptr != 0) {
+				dma_unmap_single(ndev->dev.parent,
+						 le32_to_cpu(tx_desc->dptr),
+						 size, DMA_TO_DEVICE);
+				tx_desc->dptr = 0;
+			}
+		}
 		ring_size = sizeof(struct ravb_tx_desc) *
 			    (priv->num_tx_ring[q] * NUM_TX_DESC + 1);
 		dma_free_coherent(ndev->dev.parent, ring_size, priv->tx_ring[q],
-- 
2.7.0.rc3.207.g0ac5344
