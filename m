From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: Use non-coherent memory for rx buffers
Date: Fri, 23 Nov 2012 14:50:01 +0100
Message-ID: <1353678601-26888-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Havard Skinnemoen <havard@skinnemoen.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Havard Skinnemoen <havard@skinnemoen.net>

Allocate regular pages to use as backing for the RX ring and use the
DMA API to sync the caches. This should give a bit better performance
since it allows the CPU to do burst transfers from memory. It is also
a necessary step on the way to reduce the amount of copying done by
the driver.

Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
[nicolas.ferre@atmel.com: adapt to newer kernel]
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 206 +++++++++++++++++++++++-------------
 drivers/net/ethernet/cadence/macb.h |  20 +++-
 2 files changed, 148 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6a59bce..c2955da 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -10,6 +10,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/clk.h>
+#include <linux/highmem.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -35,6 +36,8 @@
 #define RX_BUFFER_SIZE		128
 #define RX_RING_SIZE		512 /* must be power of 2 */
 #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
+#define RX_BUFFERS_PER_PAGE	(PAGE_SIZE / RX_BUFFER_SIZE)
+#define RX_RING_PAGES		(RX_RING_SIZE / RX_BUFFERS_PER_PAGE)
 
 #define TX_RING_SIZE		128 /* must be power of 2 */
 #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
@@ -90,9 +93,16 @@ static struct macb_dma_desc *macb_rx_desc(struct macb *bp, unsigned int index)
 	return &bp->rx_ring[macb_rx_ring_wrap(index)];
 }
 
-static void *macb_rx_buffer(struct macb *bp, unsigned int index)
+static struct macb_rx_page *macb_rx_page(struct macb *bp, unsigned int index)
 {
-	return bp->rx_buffers + RX_BUFFER_SIZE * macb_rx_ring_wrap(index);
+	unsigned int entry = macb_rx_ring_wrap(index);
+
+	return &bp->rx_page[entry / RX_BUFFERS_PER_PAGE];
+}
+
+static unsigned int macb_rx_page_offset(struct macb *bp, unsigned int index)
+{
+	return (index % RX_BUFFERS_PER_PAGE) * RX_BUFFER_SIZE;
 }
 
 void macb_set_hwaddr(struct macb *bp)
@@ -528,11 +538,15 @@ static void macb_tx_interrupt(struct macb *bp)
 static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 			 unsigned int last_frag)
 {
-	unsigned int len;
-	unsigned int frag;
-	unsigned int offset;
-	struct sk_buff *skb;
-	struct macb_dma_desc *desc;
+	unsigned int		len;
+	unsigned int		frag;
+	unsigned int		skb_offset;
+	unsigned int		pg_offset;
+	struct macb_rx_page	*rx_page;
+	dma_addr_t		phys;
+	void			*buf;
+	struct sk_buff		*skb;
+	struct macb_dma_desc	*desc;
 
 	desc = macb_rx_desc(bp, last_frag);
 	len = MACB_BFEXT(RX_FRMLEN, desc->ctrl);
@@ -566,7 +580,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		return 1;
 	}
 
-	offset = 0;
+	skb_offset = 0;
 	len += NET_IP_ALIGN;
 	skb_checksum_none_assert(skb);
 	skb_put(skb, len);
@@ -574,13 +588,28 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	for (frag = first_frag; ; frag++) {
 		unsigned int frag_len = RX_BUFFER_SIZE;
 
-		if (offset + frag_len > len) {
+		if (skb_offset + frag_len > len) {
 			BUG_ON(frag != last_frag);
-			frag_len = len - offset;
+			frag_len = len - skb_offset;
 		}
-		skb_copy_to_linear_data_offset(skb, offset,
-				macb_rx_buffer(bp, frag), frag_len);
-		offset += RX_BUFFER_SIZE;
+
+		rx_page = macb_rx_page(bp, frag);
+		pg_offset = macb_rx_page_offset(bp, frag);
+		phys = rx_page->phys;
+
+		dma_sync_single_range_for_cpu(&bp->pdev->dev, phys,
+				pg_offset, frag_len, DMA_FROM_DEVICE);
+
+		buf = kmap_atomic(rx_page->page);
+		skb_copy_to_linear_data_offset(skb, skb_offset,
+				buf + pg_offset, frag_len);
+		kunmap_atomic(buf);
+
+		skb_offset += frag_len;
+
+		dma_sync_single_range_for_device(&bp->pdev->dev, phys,
+				pg_offset, frag_len, DMA_FROM_DEVICE);
+
 		desc = macb_rx_desc(bp, frag);
 		desc->addr &= ~MACB_BIT(RX_USED);
 
@@ -860,86 +889,90 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static void macb_free_consistent(struct macb *bp)
+static void macb_free_rings(struct macb *bp)
 {
-	if (bp->tx_skb) {
-		kfree(bp->tx_skb);
-		bp->tx_skb = NULL;
-	}
-	if (bp->rx_ring) {
-		dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES,
-				  bp->rx_ring, bp->rx_ring_dma);
-		bp->rx_ring = NULL;
-	}
-	if (bp->tx_ring) {
-		dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES,
-				  bp->tx_ring, bp->tx_ring_dma);
-		bp->tx_ring = NULL;
-	}
-	if (bp->rx_buffers) {
-		dma_free_coherent(&bp->pdev->dev,
-				  RX_RING_SIZE * RX_BUFFER_SIZE,
-				  bp->rx_buffers, bp->rx_buffers_dma);
-		bp->rx_buffers = NULL;
+	int i;
+
+	for (i = 0; i < RX_RING_PAGES; i++) {
+		struct macb_rx_page *rx_page = &bp->rx_page[i];
+
+		if (!rx_page->page)
+			continue;
+
+		dma_unmap_page(&bp->pdev->dev, rx_page->phys,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+		put_page(rx_page->page);
+		rx_page->page = NULL;
 	}
+
+	kfree(bp->tx_skb);
+	kfree(bp->rx_page);
+	dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES, bp->tx_ring,
+			  bp->tx_ring_dma);
+	dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES, bp->rx_ring,
+			  bp->rx_ring_dma);
 }
 
-static int macb_alloc_consistent(struct macb *bp)
+static int macb_init_rings(struct macb *bp)
 {
-	int size;
+	struct page	*page;
+	dma_addr_t	phys;
+	unsigned int	page_idx;
+	unsigned int	ring_idx;
+	unsigned int	i;
 
-	size = TX_RING_SIZE * sizeof(struct macb_tx_skb);
-	bp->tx_skb = kmalloc(size, GFP_KERNEL);
-	if (!bp->tx_skb)
-		goto out_err;
-
-	size = RX_RING_BYTES;
-	bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
+	bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, RX_RING_BYTES,
 					 &bp->rx_ring_dma, GFP_KERNEL);
 	if (!bp->rx_ring)
-		goto out_err;
+		goto err_alloc_rx_ring;
+
 	netdev_dbg(bp->dev,
 		   "Allocated RX ring of %d bytes at %08lx (mapped %p)\n",
-		   size, (unsigned long)bp->rx_ring_dma, bp->rx_ring);
+		   RX_RING_BYTES, (unsigned long)bp->rx_ring_dma, bp->rx_ring);
 
-	size = TX_RING_BYTES;
-	bp->tx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
+	bp->tx_ring = dma_alloc_coherent(&bp->pdev->dev, TX_RING_BYTES,
 					 &bp->tx_ring_dma, GFP_KERNEL);
 	if (!bp->tx_ring)
-		goto out_err;
-	netdev_dbg(bp->dev,
-		   "Allocated TX ring of %d bytes at %08lx (mapped %p)\n",
-		   size, (unsigned long)bp->tx_ring_dma, bp->tx_ring);
-
-	size = RX_RING_SIZE * RX_BUFFER_SIZE;
-	bp->rx_buffers = dma_alloc_coherent(&bp->pdev->dev, size,
-					    &bp->rx_buffers_dma, GFP_KERNEL);
-	if (!bp->rx_buffers)
-		goto out_err;
+		goto err_alloc_tx_ring;
+
 	netdev_dbg(bp->dev,
-		   "Allocated RX buffers of %d bytes at %08lx (mapped %p)\n",
-		   size, (unsigned long)bp->rx_buffers_dma, bp->rx_buffers);
+		   "Allocated TX ring of %d bytes at 0x%08lx (mapped %p)\n",
+		   TX_RING_BYTES, (unsigned long)bp->tx_ring_dma, bp->tx_ring);
 
-	return 0;
+	bp->rx_page = kcalloc(RX_RING_PAGES, sizeof(struct macb_rx_page),
+			      GFP_KERNEL);
+	if (!bp->rx_page)
+		goto err_alloc_rx_page;
 
-out_err:
-	macb_free_consistent(bp);
-	return -ENOMEM;
-}
+	bp->tx_skb = kcalloc(TX_RING_SIZE, sizeof(struct macb_tx_skb),
+			     GFP_KERNEL);
+	if (!bp->tx_skb)
+		goto err_alloc_tx_skb;
 
-static void macb_init_rings(struct macb *bp)
-{
-	int i;
-	dma_addr_t addr;
+	for (page_idx = 0, ring_idx = 0; page_idx < RX_RING_PAGES; page_idx++) {
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			goto err_alloc_page;
+
+		phys = dma_map_page(&bp->pdev->dev, page, 0, PAGE_SIZE,
+				    DMA_FROM_DEVICE);
+		if (dma_mapping_error(&bp->pdev->dev, phys))
+			goto err_map_page;
+
+		bp->rx_page[page_idx].page = page;
+		bp->rx_page[page_idx].phys = phys;
 
-	addr = bp->rx_buffers_dma;
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		bp->rx_ring[i].addr = addr;
-		bp->rx_ring[i].ctrl = 0;
-		addr += RX_BUFFER_SIZE;
+		for (i = 0; i < RX_BUFFERS_PER_PAGE; i++, ring_idx++) {
+			bp->rx_ring[ring_idx].addr = phys;
+			bp->rx_ring[ring_idx].ctrl = 0;
+			phys += RX_BUFFER_SIZE;
+		}
 	}
 	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
 
+	netdev_dbg(bp->dev, "Allocated %u RX buffers (%lu pages)\n",
+		   RX_RING_SIZE, RX_RING_PAGES);
+
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		bp->tx_ring[i].addr = 0;
 		bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
@@ -947,6 +980,28 @@ static void macb_init_rings(struct macb *bp)
 	bp->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
 
 	bp->rx_tail = bp->tx_head = bp->tx_tail = 0;
+
+	return 0;
+
+err_map_page:
+	__free_page(page);
+err_alloc_page:
+	while (page_idx--) {
+		dma_unmap_page(&bp->pdev->dev, bp->rx_page[page_idx].phys,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+		__free_page(bp->rx_page[page_idx].page);
+	}
+	kfree(bp->tx_skb);
+err_alloc_tx_skb:
+	kfree(bp->rx_page);
+err_alloc_rx_page:
+	dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES, bp->tx_ring,
+			  bp->tx_ring_dma);
+err_alloc_tx_ring:
+	dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES, bp->rx_ring,
+			  bp->rx_ring_dma);
+err_alloc_rx_ring:
+	return -ENOMEM;
 }
 
 static void macb_reset_hw(struct macb *bp)
@@ -1221,16 +1276,15 @@ static int macb_open(struct net_device *dev)
 	if (!bp->phy_dev)
 		return -EAGAIN;
 
-	err = macb_alloc_consistent(bp);
+	err = macb_init_rings(bp);
 	if (err) {
-		netdev_err(dev, "Unable to allocate DMA memory (error %d)\n",
+		netdev_err(dev, "Unable to allocate DMA rings (error %d)\n",
 			   err);
 		return err;
 	}
 
 	napi_enable(&bp->napi);
 
-	macb_init_rings(bp);
 	macb_init_hw(bp);
 
 	/* schedule a link state check */
@@ -1257,7 +1311,7 @@ static int macb_close(struct net_device *dev)
 	netif_carrier_off(dev);
 	spin_unlock_irqrestore(&bp->lock, flags);
 
-	macb_free_consistent(bp);
+	macb_free_rings(bp);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 570908b..74e68a3 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -453,6 +453,23 @@ struct macb_dma_desc {
 #define MACB_TX_USED_SIZE			1
 
 /**
+ * struct macb_rx_page - data associated with a page used as RX buffers
+ * @page: Physical page used as storage for the buffers
+ * @phys: DMA address of the page
+ *
+ * Each page is used to provide %MACB_RX_BUFFERS_PER_PAGE RX buffers.
+ * The page gets an initial reference when it is inserted into the
+ * ring, and an additional reference each time it is passed up the
+ * stack as a fragment. When all the buffers have been used, we drop
+ * the initial reference and allocate a new page. Any additional
+ * references are dropped when the higher layers free the skb.
+ */
+struct macb_rx_page {
+	struct page		*page;
+	dma_addr_t		phys;
+};
+
+/**
  * struct macb_tx_skb - data about an skb which is being transmitted
  * @skb: skb currently being transmitted
  * @mapping: DMA address of the skb's data buffer
@@ -543,7 +560,7 @@ struct macb {
 
 	unsigned int		rx_tail;
 	struct macb_dma_desc	*rx_ring;
-	void			*rx_buffers;
+	struct macb_rx_page	*rx_page;
 
 	unsigned int		tx_head, tx_tail;
 	struct macb_dma_desc	*tx_ring;
@@ -564,7 +581,6 @@ struct macb {
 
 	dma_addr_t		rx_ring_dma;
 	dma_addr_t		tx_ring_dma;
-	dma_addr_t		rx_buffers_dma;
 
 	struct mii_bus		*mii_bus;
 	struct phy_device	*phy_dev;
-- 
1.8.0
