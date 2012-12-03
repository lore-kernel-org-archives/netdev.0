From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: Use dmapool to align descriptors on 64bits
Date: Mon, 3 Dec 2012 13:15:14 +0100
Message-ID: <1354536914-6315-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Depending on datapath, some revisions of GEM need
64bits aligned descriptors. Use dmapool to allocate
these descriptors.
Note that different size between RX and TX rings
leads to the creation of two pools.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 99 ++++++++++++++++++++++++-------------
 drivers/net/ethernet/cadence/macb.h |  3 ++
 2 files changed, 69 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c2955da..4b541a3 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -22,6 +22,7 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/dmapool.h>
 #include <linux/dma-mapping.h>
 #include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
@@ -889,6 +890,47 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+/*
+ * Retrieve the maximum supported data bus width from decoding the
+ * design configuration register.
+ *
+ * Result in bytes.
+ */
+static u32 macb_dma_bus_width(struct macb *bp)
+{
+	u32 dbwdef;
+
+	if (!macb_is_gem(bp))
+		return 4;
+
+	dbwdef = GEM_BFEXT(DBWDEF, gem_readl(bp, DCFG1));
+	switch (dbwdef) {
+	case 4:
+	case 2:
+		return dbwdef * 4;
+	case 1:
+	default:
+		return 4;
+	}
+}
+
+/*
+ * Get the DMA bus width field of the network configuration register that we
+ * should program.
+ */
+static u32 macb_dbw(struct macb *bp)
+{
+	switch (macb_dma_bus_width(bp)) {
+	case 16:
+		return GEM_BF(DBW, GEM_DBW128);
+	case 8:
+		return GEM_BF(DBW, GEM_DBW64);
+	case 4:
+	default:
+		return GEM_BF(DBW, GEM_DBW32);
+	}
+}
+
 static void macb_free_rings(struct macb *bp)
 {
 	int i;
@@ -907,10 +949,12 @@ static void macb_free_rings(struct macb *bp)
 
 	kfree(bp->tx_skb);
 	kfree(bp->rx_page);
-	dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES, bp->tx_ring,
-			  bp->tx_ring_dma);
-	dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES, bp->rx_ring,
-			  bp->rx_ring_dma);
+	dma_pool_free(bp->tx_pool, bp->tx_ring, bp->tx_ring_dma);
+	dma_pool_free(bp->rx_pool, bp->rx_ring, bp->rx_ring_dma);
+	dma_pool_destroy(bp->tx_pool);
+	dma_pool_destroy(bp->rx_pool);
+	bp->tx_pool = NULL;
+	bp->rx_pool = NULL;
 }
 
 static int macb_init_rings(struct macb *bp)
@@ -920,9 +964,16 @@ static int macb_init_rings(struct macb *bp)
 	unsigned int	page_idx;
 	unsigned int	ring_idx;
 	unsigned int	i;
+	unsigned int	dma_bw = macb_dma_bus_width(bp);
+
+	bp->rx_pool = dma_pool_create(bp->pdev->name, &bp->pdev->dev,
+				      RX_RING_BYTES, dma_bw, 0);
+	bp->tx_pool = dma_pool_create(bp->pdev->name, &bp->pdev->dev,
+				      TX_RING_BYTES, dma_bw, 0);
+	if (!bp->rx_pool || !bp->tx_pool)
+		goto err_alloc_rx_ring;
 
-	bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, RX_RING_BYTES,
-					 &bp->rx_ring_dma, GFP_KERNEL);
+	bp->rx_ring = dma_pool_alloc(bp->rx_pool, GFP_KERNEL, &bp->rx_ring_dma);
 	if (!bp->rx_ring)
 		goto err_alloc_rx_ring;
 
@@ -930,8 +981,7 @@ static int macb_init_rings(struct macb *bp)
 		   "Allocated RX ring of %d bytes at %08lx (mapped %p)\n",
 		   RX_RING_BYTES, (unsigned long)bp->rx_ring_dma, bp->rx_ring);
 
-	bp->tx_ring = dma_alloc_coherent(&bp->pdev->dev, TX_RING_BYTES,
-					 &bp->tx_ring_dma, GFP_KERNEL);
+	bp->tx_ring = dma_pool_alloc(bp->tx_pool, GFP_KERNEL, &bp->tx_ring_dma);
 	if (!bp->tx_ring)
 		goto err_alloc_tx_ring;
 
@@ -995,12 +1045,16 @@ err_alloc_page:
 err_alloc_tx_skb:
 	kfree(bp->rx_page);
 err_alloc_rx_page:
-	dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES, bp->tx_ring,
-			  bp->tx_ring_dma);
+	dma_pool_free(bp->tx_pool, bp->tx_ring, bp->tx_ring_dma);
 err_alloc_tx_ring:
-	dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES, bp->rx_ring,
-			  bp->rx_ring_dma);
+	dma_pool_free(bp->rx_pool, bp->rx_ring, bp->rx_ring_dma);
 err_alloc_rx_ring:
+	if (bp->tx_pool)
+		dma_pool_destroy(bp->tx_pool);
+	if (bp->rx_pool)
+		dma_pool_destroy(bp->rx_pool);
+	bp->rx_pool = NULL;
+	bp->tx_pool = NULL;
 	return -ENOMEM;
 }
 
@@ -1067,27 +1121,6 @@ static u32 macb_mdc_clk_div(struct macb *bp)
 }
 
 /*
- * Get the DMA bus width field of the network configuration register that we
- * should program.  We find the width from decoding the design configuration
- * register to find the maximum supported data bus width.
- */
-static u32 macb_dbw(struct macb *bp)
-{
-	if (!macb_is_gem(bp))
-		return 0;
-
-	switch (GEM_BFEXT(DBWDEF, gem_readl(bp, DCFG1))) {
-	case 4:
-		return GEM_BF(DBW, GEM_DBW128);
-	case 2:
-		return GEM_BF(DBW, GEM_DBW64);
-	case 1:
-	default:
-		return GEM_BF(DBW, GEM_DBW32);
-	}
-}
-
-/*
  * Configure the receive DMA engine
  * - use the correct receive buffer size
  * - set the possibility to use INCR16 bursts
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index e82242b..b4c9515 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -584,6 +584,9 @@ struct macb {
 	dma_addr_t		tx_ring_dma;
 	dma_addr_t		rx_buffers_dma;
 
+	struct dma_pool		*rx_pool;
+	struct dma_pool		*tx_pool;
+
 	struct mii_bus		*mii_bus;
 	struct phy_device	*phy_dev;
 	unsigned int 		link;
-- 
1.8.0
