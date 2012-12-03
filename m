From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: increase RX buffer size for GEM
Date: Mon, 3 Dec 2012 13:15:43 +0100
Message-ID: <1354536943-6356-1-git-send-email-nicolas.ferre@atmel.com>
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

Macb Ethernet controller requires a RX buffer of 128 bytes. It is
highly sub-optimal for Gigabit-capable GEM that is able to use
a bigger DMA buffer. Change this constant and associated macros
with data stored in the private structure.
I also kept the result of buffers per page calculation to lower the
impact of this move to a variable rx buffer size on rx hot path.
RX DMA buffer size has to be multiple of 64 bytes as indicated in
DMA Configuration Register specification.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 61 ++++++++++++++++++++++++++++---------
 drivers/net/ethernet/cadence/macb.h |  2 ++
 2 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4b541a3..b4f45f4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -34,11 +34,11 @@
 
 #include "macb.h"
 
-#define RX_BUFFER_SIZE		128
+#define MACB_RX_BUFFER_SIZE	128
+#define GEM_RX_BUFFER_SIZE	2048
+#define RX_BUFFER_MULTIPLE	64  /* bytes */
 #define RX_RING_SIZE		512 /* must be power of 2 */
 #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
-#define RX_BUFFERS_PER_PAGE	(PAGE_SIZE / RX_BUFFER_SIZE)
-#define RX_RING_PAGES		(RX_RING_SIZE / RX_BUFFERS_PER_PAGE)
 
 #define TX_RING_SIZE		128 /* must be power of 2 */
 #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
@@ -98,12 +98,17 @@ static struct macb_rx_page *macb_rx_page(struct macb *bp, unsigned int index)
 {
 	unsigned int entry = macb_rx_ring_wrap(index);
 
-	return &bp->rx_page[entry / RX_BUFFERS_PER_PAGE];
+	return &bp->rx_page[entry / bp->rx_buffers_per_page];
 }
 
 static unsigned int macb_rx_page_offset(struct macb *bp, unsigned int index)
 {
-	return (index % RX_BUFFERS_PER_PAGE) * RX_BUFFER_SIZE;
+	return (index % bp->rx_buffers_per_page) * bp->rx_buffer_size;
+}
+
+static unsigned int rx_ring_pages(struct macb *bp)
+{
+	return RX_RING_SIZE / bp->rx_buffers_per_page;
 }
 
 void macb_set_hwaddr(struct macb *bp)
@@ -587,7 +592,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	skb_put(skb, len);
 
 	for (frag = first_frag; ; frag++) {
-		unsigned int frag_len = RX_BUFFER_SIZE;
+		unsigned int frag_len = bp->rx_buffer_size;
 
 		if (skb_offset + frag_len > len) {
 			BUG_ON(frag != last_frag);
@@ -931,11 +936,36 @@ static u32 macb_dbw(struct macb *bp)
 	}
 }
 
+static void macb_init_rx_buffer_size(struct macb *bp)
+{
+	if (!macb_is_gem(bp)) {
+		bp->rx_buffer_size = MACB_RX_BUFFER_SIZE;
+	} else {
+		bp->rx_buffer_size = GEM_RX_BUFFER_SIZE;
+
+		if (bp->rx_buffer_size > PAGE_SIZE) {
+			netdev_warn(bp->dev,
+				    "RX buffer cannot be bigger than PAGE_SIZE, shrinking\n");
+			bp->rx_buffer_size = PAGE_SIZE;
+		}
+		if (bp->rx_buffer_size % RX_BUFFER_MULTIPLE) {
+			netdev_warn(bp->dev,
+				    "RX buffer must be multiple of %d bytes, shrinking\n",
+				    RX_BUFFER_MULTIPLE);
+			bp->rx_buffer_size =
+				rounddown(bp->rx_buffer_size, RX_BUFFER_MULTIPLE);
+		}
+		bp->rx_buffer_size = max(RX_BUFFER_MULTIPLE, GEM_RX_BUFFER_SIZE);
+	}
+
+	bp->rx_buffers_per_page = PAGE_SIZE / bp->rx_buffer_size;
+}
+
 static void macb_free_rings(struct macb *bp)
 {
 	int i;
 
-	for (i = 0; i < RX_RING_PAGES; i++) {
+	for (i = 0; i < rx_ring_pages(bp); i++) {
 		struct macb_rx_page *rx_page = &bp->rx_page[i];
 
 		if (!rx_page->page)
@@ -989,7 +1019,10 @@ static int macb_init_rings(struct macb *bp)
 		   "Allocated TX ring of %d bytes at 0x%08lx (mapped %p)\n",
 		   TX_RING_BYTES, (unsigned long)bp->tx_ring_dma, bp->tx_ring);
 
-	bp->rx_page = kcalloc(RX_RING_PAGES, sizeof(struct macb_rx_page),
+	/* RX buffers initialization */
+	macb_init_rx_buffer_size(bp);
+
+	bp->rx_page = kcalloc(rx_ring_pages(bp), sizeof(struct macb_rx_page),
 			      GFP_KERNEL);
 	if (!bp->rx_page)
 		goto err_alloc_rx_page;
@@ -999,7 +1032,7 @@ static int macb_init_rings(struct macb *bp)
 	if (!bp->tx_skb)
 		goto err_alloc_tx_skb;
 
-	for (page_idx = 0, ring_idx = 0; page_idx < RX_RING_PAGES; page_idx++) {
+	for (page_idx = 0, ring_idx = 0; page_idx < rx_ring_pages(bp); page_idx++) {
 		page = alloc_page(GFP_KERNEL);
 		if (!page)
 			goto err_alloc_page;
@@ -1012,16 +1045,16 @@ static int macb_init_rings(struct macb *bp)
 		bp->rx_page[page_idx].page = page;
 		bp->rx_page[page_idx].phys = phys;
 
-		for (i = 0; i < RX_BUFFERS_PER_PAGE; i++, ring_idx++) {
+		for (i = 0; i < bp->rx_buffers_per_page; i++, ring_idx++) {
 			bp->rx_ring[ring_idx].addr = phys;
 			bp->rx_ring[ring_idx].ctrl = 0;
-			phys += RX_BUFFER_SIZE;
+			phys += bp->rx_buffer_size;
 		}
 	}
 	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
 
-	netdev_dbg(bp->dev, "Allocated %u RX buffers (%lu pages)\n",
-		   RX_RING_SIZE, RX_RING_PAGES);
+	netdev_dbg(bp->dev, "Allocated %u RX buffers of size %u (%u pages)\n",
+		   RX_RING_SIZE, bp->rx_buffer_size, rx_ring_pages(bp));
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		bp->tx_ring[i].addr = 0;
@@ -1134,7 +1167,7 @@ static void macb_configure_dma(struct macb *bp)
 
 	if (macb_is_gem(bp)) {
 		dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
-		dmacfg |= GEM_BF(RXBS, RX_BUFFER_SIZE / 64);
+		dmacfg |= GEM_BF(RXBS, bp->rx_buffer_size / RX_BUFFER_MULTIPLE);
 		dmacfg |= GEM_BF(FBLDO, 16);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		gem_writel(bp, DMACFG, dmacfg);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index b4c9515..88780e2 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -562,6 +562,8 @@ struct macb {
 	struct macb_dma_desc	*rx_ring;
 	struct macb_rx_page	*rx_page;
 	void			*rx_buffers;
+	size_t			rx_buffer_size;
+	unsigned int		rx_buffers_per_page;
 
 	unsigned int		tx_head, tx_tail;
 	struct macb_dma_desc	*tx_ring;
-- 
1.8.0
