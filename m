From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: sxgbe: fix error handling in init_rx_ring()
Date: Thu, 5 Feb 2015 11:00:42 +0300
Message-ID: <20150205080042.GC27855@mwanda>
References: <20150116071229.GH5520@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Girish K S <ks.giri@samsung.com>,
	Vipul Pandya <vipul.pandya@samsung.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>, kgene@kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116071229.GH5520@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a couple bugs with the error handling in this function.

1) If we can't allocate "rx_ring->rx_skbuff" then we should call
   dma_free_coherent() but we don't.
2) free_rx_ring() frees "rx_ring->rx_skbuff_dma" and "rx_ring->rx_skbuff"
   so calling it in a loop causes a double free.

Also it was a bit confusing how we sometimes freed things before doing
the goto.  I've cleaned it up so it does error handling in normal kernel
style.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 11288d4..c8a01ee 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -364,6 +364,26 @@ static int sxgbe_init_rx_buffers(struct net_device *dev,
 
 	return 0;
 }
+
+/**
+ * sxgbe_free_rx_buffers - free what sxgbe_init_rx_buffers() allocated
+ * @dev: net device structure
+ * @rx_ring: ring to be freed
+ * @rx_rsize: ring size
+ * Description:  this function initializes the DMA RX descriptor
+ */
+static void sxgbe_free_rx_buffers(struct net_device *dev,
+				  struct sxgbe_rx_norm_desc *p, int i,
+				  unsigned int dma_buf_sz,
+				  struct sxgbe_rx_queue *rx_ring)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	kfree_skb(rx_ring->rx_skbuff[i]);
+	dma_unmap_single(priv->device, rx_ring->rx_skbuff_dma[i],
+			 dma_buf_sz, DMA_FROM_DEVICE);
+}
+
 /**
  * init_tx_ring - init the TX descriptor ring
  * @dev: net device structure
@@ -456,7 +476,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 	/* RX ring is not allcoated */
 	if (rx_ring == NULL) {
 		netdev_err(dev, "No memory for RX queue\n");
-		goto error;
+		return -ENOMEM;
 	}
 
 	/* assign queue number */
@@ -468,23 +488,21 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 					      &rx_ring->dma_rx_phy, GFP_KERNEL);
 
 	if (rx_ring->dma_rx == NULL)
-		goto error;
+		return -ENOMEM;
 
 	/* allocate memory for RX skbuff array */
 	rx_ring->rx_skbuff_dma = kmalloc_array(rx_rsize,
 					       sizeof(dma_addr_t), GFP_KERNEL);
 	if (!rx_ring->rx_skbuff_dma) {
-		dma_free_coherent(priv->device,
-				  rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
-				  rx_ring->dma_rx, rx_ring->dma_rx_phy);
-		goto error;
+		ret = -ENOMEM;
+		goto err_free_dma_rx;
 	}
 
 	rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
 					   sizeof(struct sk_buff *), GFP_KERNEL);
 	if (!rx_ring->rx_skbuff) {
-		kfree(rx_ring->rx_skbuff_dma);
-		goto error;
+		ret = -ENOMEM;
+		goto err_free_skbuff_dma;
 	}
 
 	/* initialise the buffers */
@@ -494,7 +512,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 		ret = sxgbe_init_rx_buffers(dev, p, desc_index,
 					    bfsize, rx_ring);
 		if (ret)
-			goto err_init_rx_buffers;
+			goto err_free_rx_buffers;
 	}
 
 	/* initalise counters */
@@ -504,11 +522,22 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 
 	return 0;
 
-err_init_rx_buffers:
-	while (--desc_index >= 0)
-		free_rx_ring(priv->device, rx_ring, desc_index);
-error:
-	return -ENOMEM;
+err_free_rx_buffers:
+	while (--desc_index >= 0) {
+		struct sxgbe_rx_norm_desc *p;
+
+		p = rx_ring->dma_rx + desc_index;
+		sxgbe_free_rx_buffers(dev, p, desc_index, bfsize, rx_ring);
+	}
+	kfree(rx_ring->rx_skbuff);
+err_free_skbuff_dma:
+	kfree(rx_ring->rx_skbuff_dma);
+err_free_dma_rx:
+	dma_free_coherent(priv->device,
+			  rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
+			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
+
+	return ret;
 }
 /**
  * free_tx_ring - free the TX descriptor ring
