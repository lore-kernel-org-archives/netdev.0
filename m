From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 10/10] net/mlx4_en: Refactor mlx4_en_free_tx_desc
Date: Thu, 15 Jun 2017 14:35:40 +0300
Message-ID: <1497526540-30028-11-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36080 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752387AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some code re-ordering, functionally equivalent.

- The !tx_info->inl check is evaluated anyway in both flows
  (common case/end case). Run it first, this might finish
  the flows earlier.
- dma_unmap calls are identical in both flows, get it out
  of the if block into the common area.

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz

Gain is too small to be measurable, no degradation sensed.
Results are similar for IPv4 and IPv6.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 45 +++++++++++-------------------
 1 file changed, 16 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index efc4411b1e44..7d69d939ee2d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -289,20 +289,20 @@ u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 		skb_tstamp_tx(skb, &hwts);
 	}
 
-	/* Optimize the common case when there are no wraparounds */
-	if (likely((void *)tx_desc +
-		   (tx_info->nr_txbb << LOG_TXBB_SIZE) <= end)) {
-		if (!tx_info->inl) {
-			if (tx_info->linear)
-				dma_unmap_single(priv->ddev,
-						tx_info->map0_dma,
-						tx_info->map0_byte_count,
-						PCI_DMA_TODEVICE);
-			else
-				dma_unmap_page(priv->ddev,
-					       tx_info->map0_dma,
-					       tx_info->map0_byte_count,
-					       PCI_DMA_TODEVICE);
+	if (!tx_info->inl) {
+		if (tx_info->linear)
+			dma_unmap_single(priv->ddev,
+					 tx_info->map0_dma,
+					 tx_info->map0_byte_count,
+					 PCI_DMA_TODEVICE);
+		else
+			dma_unmap_page(priv->ddev,
+				       tx_info->map0_dma,
+				       tx_info->map0_byte_count,
+				       PCI_DMA_TODEVICE);
+		/* Optimize the common case when there are no wraparounds */
+		if (likely((void *)tx_desc +
+			   (tx_info->nr_txbb << LOG_TXBB_SIZE) <= end)) {
 			for (i = 1; i < nr_maps; i++) {
 				data++;
 				dma_unmap_page(priv->ddev,
@@ -310,23 +310,10 @@ u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 					be32_to_cpu(data->byte_count),
 					PCI_DMA_TODEVICE);
 			}
-		}
-	} else {
-		if (!tx_info->inl) {
-			if ((void *) data >= end) {
+		} else {
+			if ((void *)data >= end)
 				data = ring->buf + ((void *)data - end);
-			}
 
-			if (tx_info->linear)
-				dma_unmap_single(priv->ddev,
-						tx_info->map0_dma,
-						tx_info->map0_byte_count,
-						PCI_DMA_TODEVICE);
-			else
-				dma_unmap_page(priv->ddev,
-					       tx_info->map0_dma,
-					       tx_info->map0_byte_count,
-					       PCI_DMA_TODEVICE);
 			for (i = 1; i < nr_maps; i++) {
 				data++;
 				/* Check for wraparound before unmapping */
-- 
1.8.3.1
