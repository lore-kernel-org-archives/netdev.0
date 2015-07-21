From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] ravb: fix ring memory allocation
Date: Wed, 22 Jul 2015 01:31:59 +0300
Message-ID: <1836998.fscmK2EJWV@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver is written as if it can adapt to a low memory situation  allocating
less RX  skbs and TX aligned buffers than the respective RX/TX ring sizes.  In
reality  though  the driver  would malfunction in this case. Stop being overly
smart and just fail in such situation -- this is achieved by moving the memory
allocation from ravb_ring_format() to ravb_ring_init().

We leave dma_map_single() calls in place but make their failure non-fatal
by marking the corresponding RX descriptors  with zero data size which should
prevent DMA to an invalid addresses.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo.

drivers/net/ethernet/renesas/ravb_main.c |   59 +++++++++++++++++--------------
 1 file changed, 34 insertions(+), 25 deletions(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -228,9 +228,7 @@ static void ravb_ring_format(struct net_
 	struct ravb_desc *desc = NULL;
 	int rx_ring_size = sizeof(*rx_desc) * priv->num_rx_ring[q];
 	int tx_ring_size = sizeof(*tx_desc) * priv->num_tx_ring[q];
-	struct sk_buff *skb;
 	dma_addr_t dma_addr;
-	void *buffer;
 	int i;
 
 	priv->cur_rx[q] = 0;
@@ -241,41 +239,28 @@ static void ravb_ring_format(struct net_
 	memset(priv->rx_ring[q], 0, rx_ring_size);
 	/* Build RX ring buffer */
 	for (i = 0; i < priv->num_rx_ring[q]; i++) {
-		priv->rx_skb[q][i] = NULL;
-		skb = netdev_alloc_skb(ndev, PKT_BUF_SZ + RAVB_ALIGN - 1);
-		if (!skb)
-			break;
-		ravb_set_buffer_align(skb);
 		/* RX descriptor */
 		rx_desc = &priv->rx_ring[q][i];
 		/* The size of the buffer should be on 16-byte boundary. */
 		rx_desc->ds_cc = cpu_to_le16(ALIGN(PKT_BUF_SZ, 16));
-		dma_addr = dma_map_single(&ndev->dev, skb->data,
+		dma_addr = dma_map_single(&ndev->dev, priv->rx_skb[q][i]->data,
 					  ALIGN(PKT_BUF_SZ, 16),
 					  DMA_FROM_DEVICE);
-		if (dma_mapping_error(&ndev->dev, dma_addr)) {
-			dev_kfree_skb(skb);
-			break;
-		}
-		priv->rx_skb[q][i] = skb;
+		/* We just set the data size to 0 for a failed mapping which
+		 * should prevent DMA from happening...
+		 */
+		if (dma_mapping_error(&ndev->dev, dma_addr))
+			rx_desc->ds_cc = cpu_to_le16(0);
 		rx_desc->dptr = cpu_to_le32(dma_addr);
 		rx_desc->die_dt = DT_FEMPTY;
 	}
 	rx_desc = &priv->rx_ring[q][i];
 	rx_desc->dptr = cpu_to_le32((u32)priv->rx_desc_dma[q]);
 	rx_desc->die_dt = DT_LINKFIX; /* type */
-	priv->dirty_rx[q] = (u32)(i - priv->num_rx_ring[q]);
 
 	memset(priv->tx_ring[q], 0, tx_ring_size);
 	/* Build TX ring buffer */
 	for (i = 0; i < priv->num_tx_ring[q]; i++) {
-		priv->tx_skb[q][i] = NULL;
-		priv->tx_buffers[q][i] = NULL;
-		buffer = kmalloc(PKT_BUF_SZ + RAVB_ALIGN - 1, GFP_KERNEL);
-		if (!buffer)
-			break;
-		/* Aligned TX buffer */
-		priv->tx_buffers[q][i] = buffer;
 		tx_desc = &priv->tx_ring[q][i];
 		tx_desc->die_dt = DT_EEMPTY;
 	}
@@ -298,7 +283,10 @@ static void ravb_ring_format(struct net_
 static int ravb_ring_init(struct net_device *ndev, int q)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
+	struct sk_buff *skb;
 	int ring_size;
+	void *buffer;
+	int i;
 
 	/* Allocate RX and TX skb rings */
 	priv->rx_skb[q] = kcalloc(priv->num_rx_ring[q],
@@ -308,12 +296,28 @@ static int ravb_ring_init(struct net_dev
 	if (!priv->rx_skb[q] || !priv->tx_skb[q])
 		goto error;
 
+	for (i = 0; i < priv->num_rx_ring[q]; i++) {
+		skb = netdev_alloc_skb(ndev, PKT_BUF_SZ + RAVB_ALIGN - 1);
+		if (!skb)
+			goto error;
+		ravb_set_buffer_align(skb);
+		priv->rx_skb[q][i] = skb;
+	}
+
 	/* Allocate rings for the aligned buffers */
 	priv->tx_buffers[q] = kcalloc(priv->num_tx_ring[q],
 				      sizeof(*priv->tx_buffers[q]), GFP_KERNEL);
 	if (!priv->tx_buffers[q])
 		goto error;
 
+	for (i = 0; i < priv->num_tx_ring[q]; i++) {
+		buffer = kmalloc(PKT_BUF_SZ + RAVB_ALIGN - 1, GFP_KERNEL);
+		if (!buffer)
+			goto error;
+		/* Aligned TX buffer */
+		priv->tx_buffers[q][i] = buffer;
+	}
+
 	/* Allocate all RX descriptors. */
 	ring_size = sizeof(struct ravb_ex_rx_desc) * (priv->num_rx_ring[q] + 1);
 	priv->rx_ring[q] = dma_alloc_coherent(NULL, ring_size,
@@ -524,6 +528,10 @@ static bool ravb_rx(struct net_device *n
 		if (--boguscnt < 0)
 			break;
 
+		/* We use 0-byte descriptors to mark the DMA mapping errors */
+		if (!pkt_len)
+			continue;
+
 		if (desc_status & MSC_MC)
 			stats->multicast++;
 
@@ -587,10 +595,11 @@ static bool ravb_rx(struct net_device *n
 						  le16_to_cpu(desc->ds_cc),
 						  DMA_FROM_DEVICE);
 			skb_checksum_none_assert(skb);
-			if (dma_mapping_error(&ndev->dev, dma_addr)) {
-				dev_kfree_skb_any(skb);
-				break;
-			}
+			/* We just set the data size to 0 for a failed mapping
+			 * which should prevent DMA  from happening...
+			 */
+			if (dma_mapping_error(&ndev->dev, dma_addr))
+				desc->ds_cc = cpu_to_le16(0);
 			desc->dptr = cpu_to_le32(dma_addr);
 			priv->rx_skb[q][entry] = skb;
 		}

