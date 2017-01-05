From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing rings
Date: Thu,  5 Jan 2017 11:43:20 +0100
Message-ID: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56091 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762039AbdAEKnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 05:43:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

"swiotlb buffer is full" errors occur after repeated initialisation of a
device - f.e. suspend/resume or ip link set up/down. This is because memory
mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
is not released.  Resolve this problem by unmapping descriptors when
freeing rings.

Note, ravb_tx_free() is moved but not otherwise modified by this patch.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
[simon: reworked]
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
--
v1 [Kazuya Mizuguchi]

v2 [Simon Horman]
* As suggested by Sergei Shtylyov
  - Use dma_mapping_error() and rx_desc->ds_cc when unmapping RX descriptors;
    this is consistent with the way that they are mapped
  - Use ravb_tx_free() to clear TX descriptors
* Reduce scope of new local variable
---
 drivers/net/ethernet/renesas/ravb_main.c | 89 ++++++++++++++++++--------------
 1 file changed, 51 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 92d7692c840d..1797c48e3176 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -179,6 +179,44 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = ravb_get_mdio_data,
 };
 
+/* Free TX skb function for AVB-IP */
+static int ravb_tx_free(struct net_device *ndev, int q)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &priv->stats[q];
+	struct ravb_tx_desc *desc;
+	int free_num = 0;
+	int entry;
+	u32 size;
+
+	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
+		entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
+					     NUM_TX_DESC);
+		desc = &priv->tx_ring[q][entry];
+		if (desc->die_dt != DT_FEMPTY)
+			break;
+		/* Descriptor type must be checked before all other reads */
+		dma_rmb();
+		size = le16_to_cpu(desc->ds_tagl) & TX_DS;
+		/* Free the original skb. */
+		if (priv->tx_skb[q][entry / NUM_TX_DESC]) {
+			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
+					 size, DMA_TO_DEVICE);
+			/* Last packet descriptor? */
+			if (entry % NUM_TX_DESC == NUM_TX_DESC - 1) {
+				entry /= NUM_TX_DESC;
+				dev_kfree_skb_any(priv->tx_skb[q][entry]);
+				priv->tx_skb[q][entry] = NULL;
+				stats->tx_packets++;
+			}
+			free_num++;
+		}
+		stats->tx_bytes += size;
+		desc->die_dt = DT_EEMPTY;
+	}
+	return free_num;
+}
+
 /* Free skb's and DMA buffers for Ethernet AVB */
 static void ravb_ring_free(struct net_device *ndev, int q)
 {
@@ -207,6 +245,18 @@ static void ravb_ring_free(struct net_device *ndev, int q)
 	priv->tx_align[q] = NULL;
 
 	if (priv->rx_ring[q]) {
+		for (i = 0; i < priv->num_rx_ring[q]; i++) {
+			struct ravb_ex_rx_desc *rx_desc = &priv->rx_ring[q][i];
+
+			if (!dma_mapping_error(ndev->dev.parent,
+					       rx_desc->dptr)) {
+				dma_unmap_single(ndev->dev.parent,
+						 le32_to_cpu(rx_desc->dptr),
+						 PKT_BUF_SZ,
+						 DMA_FROM_DEVICE);
+				rx_desc->ds_cc = cpu_to_le16(0);
+			}
+		}
 		ring_size = sizeof(struct ravb_ex_rx_desc) *
 			    (priv->num_rx_ring[q] + 1);
 		dma_free_coherent(ndev->dev.parent, ring_size, priv->rx_ring[q],
@@ -215,6 +265,7 @@ static void ravb_ring_free(struct net_device *ndev, int q)
 	}
 
 	if (priv->tx_ring[q]) {
+		ravb_tx_free(ndev, q);
 		ring_size = sizeof(struct ravb_tx_desc) *
 			    (priv->num_tx_ring[q] * NUM_TX_DESC + 1);
 		dma_free_coherent(ndev->dev.parent, ring_size, priv->tx_ring[q],
@@ -431,44 +482,6 @@ static int ravb_dmac_init(struct net_device *ndev)
 	return 0;
 }
 
-/* Free TX skb function for AVB-IP */
-static int ravb_tx_free(struct net_device *ndev, int q)
-{
-	struct ravb_private *priv = netdev_priv(ndev);
-	struct net_device_stats *stats = &priv->stats[q];
-	struct ravb_tx_desc *desc;
-	int free_num = 0;
-	int entry;
-	u32 size;
-
-	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
-		entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
-					     NUM_TX_DESC);
-		desc = &priv->tx_ring[q][entry];
-		if (desc->die_dt != DT_FEMPTY)
-			break;
-		/* Descriptor type must be checked before all other reads */
-		dma_rmb();
-		size = le16_to_cpu(desc->ds_tagl) & TX_DS;
-		/* Free the original skb. */
-		if (priv->tx_skb[q][entry / NUM_TX_DESC]) {
-			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
-					 size, DMA_TO_DEVICE);
-			/* Last packet descriptor? */
-			if (entry % NUM_TX_DESC == NUM_TX_DESC - 1) {
-				entry /= NUM_TX_DESC;
-				dev_kfree_skb_any(priv->tx_skb[q][entry]);
-				priv->tx_skb[q][entry] = NULL;
-				stats->tx_packets++;
-			}
-			free_num++;
-		}
-		stats->tx_bytes += size;
-		desc->die_dt = DT_EEMPTY;
-	}
-	return free_num;
-}
-
 static void ravb_get_tx_tstamp(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-- 
2.7.0.rc3.207.g0ac5344
