From: Alexander Dahl <ada@thorsis.com>
Subject: [RFC 3/3] net: macb: Use sram for rx buffers
Date: Wed, 12 Jul 2017 18:28:12 +0200
Message-ID: <1499876892-14423-4-git-send-email-ada@thorsis.com>
References: <1499876892-14423-1-git-send-email-ada@thorsis.com>
Cc: Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499876892-14423-1-git-send-email-ada@thorsis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The default way for the driver is to use system memory for RX/TX DMA
buffers and rings. For the AT91SAM9G20 this is SDRAM which is connected
through the EBI bus, together with other memories like NAND-Flash or
external SRAM. If a memory access to external SRAM using the NWAIT
signal takes too long, the EMAC on the SoC throws receive overrun (ROVR)
errors which means it can not put incoming packets into SDRAM (through
DMA). Those errors add up in /proc/net/dev

To circumvent those "dropped" ethernet frames, we put the RX buffers and
rings into the small internal SRAM of the SoC, which are also usable for
DMA but directly connected through the AHB without the path through the
EBI. This way there are no lost ethernet frames anymore. (If there's too
much load however packets can still be dropped by the kernel.)

Signed-off-by: Alexander Dahl <ada@thorsis.com>
---
 drivers/net/ethernet/cadence/macb.c | 66 ++++++++++++++++++++++++++++++-------
 drivers/net/ethernet/cadence/macb.h |  2 ++
 2 files changed, 57 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 91f7492..8dacd9c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -23,6 +23,7 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/genalloc.h>
 #include <linux/dma-mapping.h>
 #include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
@@ -40,9 +41,9 @@
 #define MACB_RX_BUFFER_SIZE	128
 #define RX_BUFFER_MULTIPLE	64  /* bytes */
 
-#define DEFAULT_RX_RING_SIZE	512 /* must be power of 2 */
+#define DEFAULT_RX_RING_SIZE	128 /* must be power of 2 */
 #define MIN_RX_RING_SIZE	64
-#define MAX_RX_RING_SIZE	8192
+#define MAX_RX_RING_SIZE	128
 #define RX_RING_BYTES(bp)	(macb_dma_desc_get_size(bp)	\
 				 * (bp)->rx_ring_size)
 
@@ -1660,9 +1661,14 @@ static void gem_free_rx_buffers(struct macb *bp)
 static void macb_free_rx_buffers(struct macb *bp)
 {
 	if (bp->rx_buffers) {
-		dma_free_coherent(&bp->pdev->dev,
-				  bp->rx_ring_size * bp->rx_buffer_size,
-				  bp->rx_buffers, bp->rx_buffers_dma);
+		if (bp->sram_pool)
+			gen_pool_free(bp->sram_pool,
+				      (unsigned long)bp->rx_buffers,
+				      bp->rx_ring_size * bp->rx_buffer_size);
+		else
+			dma_free_coherent(&bp->pdev->dev,
+					  bp->rx_ring_size * bp->rx_buffer_size,
+					  bp->rx_buffers, bp->rx_buffers_dma);
 		bp->rx_buffers = NULL;
 	}
 }
@@ -1674,8 +1680,12 @@ static void macb_free_consistent(struct macb *bp)
 
 	bp->macbgem_ops.mog_free_rx_buffers(bp);
 	if (bp->rx_ring) {
-		dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES(bp),
-				  bp->rx_ring, bp->rx_ring_dma);
+		if (bp->sram_pool)
+			gen_pool_free(bp->sram_pool, (unsigned long)bp->rx_ring,
+				      RX_RING_BYTES(bp));
+		else
+			dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES(bp),
+					  bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 	}
 
@@ -1690,6 +1700,28 @@ static void macb_free_consistent(struct macb *bp)
 	}
 }
 
+static void macb_init_sram(struct macb *bp)
+{
+	struct device_node *node;
+	struct platform_device *pdev = NULL;
+
+	for_each_compatible_node(node, NULL, "mmio-sram") {
+		pdev = of_find_device_by_node(node);
+		if (pdev) {
+			of_node_put(node);
+			break;
+		}
+	}
+
+	if (!pdev) {
+		netdev_warn(bp->dev, "Failed to find sram device!\n");
+		bp->sram_pool = NULL;
+		return;
+	}
+
+	bp->sram_pool = gen_pool_get(&pdev->dev, NULL);
+}
+
 static int gem_alloc_rx_buffers(struct macb *bp)
 {
 	int size;
@@ -1710,14 +1742,20 @@ static int macb_alloc_rx_buffers(struct macb *bp)
 	int size;
 
 	size = bp->rx_ring_size * bp->rx_buffer_size;
-	bp->rx_buffers = dma_alloc_coherent(&bp->pdev->dev, size,
-					    &bp->rx_buffers_dma, GFP_KERNEL);
+	if (bp->sram_pool)
+		bp->rx_buffers = gen_pool_dma_alloc(bp->sram_pool, size,
+						    &bp->rx_buffers_dma);
+	else
+		bp->rx_buffers = dma_alloc_coherent(&bp->pdev->dev, size,
+						    &bp->rx_buffers_dma,
+						    GFP_KERNEL);
 	if (!bp->rx_buffers)
 		return -ENOMEM;
 
 	netdev_dbg(bp->dev,
 		   "Allocated RX buffers of %d bytes at %08lx (mapped %p)\n",
 		   size, (unsigned long)bp->rx_buffers_dma, bp->rx_buffers);
+
 	return 0;
 }
 
@@ -1746,8 +1784,12 @@ static int macb_alloc_consistent(struct macb *bp)
 	}
 
 	size = RX_RING_BYTES(bp);
-	bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
-					 &bp->rx_ring_dma, GFP_KERNEL);
+	if (bp->sram_pool)
+		bp->rx_ring = gen_pool_dma_alloc(bp->sram_pool, size,
+						 &bp->rx_ring_dma);
+	else
+		bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
+						 &bp->rx_ring_dma, GFP_KERNEL);
 	if (!bp->rx_ring)
 		goto out_err;
 	netdev_dbg(bp->dev,
@@ -2698,6 +2740,8 @@ static int macb_init(struct platform_device *pdev)
 	int err;
 	u32 val;
 
+	macb_init_sram(bp);
+
 	bp->tx_ring_size = DEFAULT_TX_RING_SIZE;
 	bp->rx_ring_size = DEFAULT_RX_RING_SIZE;
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 567c72d..d352181 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -957,6 +957,8 @@ struct macb {
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 	enum macb_hw_dma_cap hw_dma_cap;
 #endif
+
+	struct gen_pool		*sram_pool;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
2.1.4
