From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH net-next v3 3/4] net: mvneta: avoid reading from tx_desc as much as possible
Date: Mon, 20 Feb 2017 20:53:43 +0800
Message-ID: <20170220125344.3555-4-jszhang@marvell.com>
References: <20170220125344.3555-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, <gregory.clement@free-electrons.com>,
        <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170220125344.3555-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In hot code path such as mvneta_tx(), mvneta_txq_bufs_free() etc. we
access tx_desc several times. The tx_desc is allocated by
dma_alloc_coherent, it's uncacheable if the device isn't cache-coherent,
reading from uncached memory is fairly slow. So use local variable to
store what we need to avoid extra reading from uncached memory.

We get the following performance data on Marvell BG4CT Platforms
(tested with iperf):

before the patch:
sending 1GB in mvneta_tx()(disabled TSO) costs 793553760ns

after the patch:
sending 1GB in mvneta_tx()(disabled TSO) costs 719953800ns

we saved 9.2% time.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 50 ++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index a25042801eec..b6cda4131c78 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1770,6 +1770,7 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 		struct mvneta_tx_desc *tx_desc = txq->descs +
 			txq->txq_get_index;
 		struct sk_buff *skb = txq->tx_skb[txq->txq_get_index];
+		u32 dma_addr = tx_desc->buf_phys_addr;
 
 		if (skb) {
 			bytes_compl += skb->len;
@@ -1778,9 +1779,8 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 
 		mvneta_txq_inc_get(txq);
 
-		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr))
-			dma_unmap_single(pp->dev->dev.parent,
-					 tx_desc->buf_phys_addr,
+		if (!IS_TSO_HEADER(txq, dma_addr))
+			dma_unmap_single(pp->dev->dev.parent, dma_addr,
 					 tx_desc->data_size, DMA_TO_DEVICE);
 		if (!skb)
 			continue;
@@ -2191,17 +2191,18 @@ mvneta_tso_put_data(struct net_device *dev, struct mvneta_tx_queue *txq,
 		    bool last_tcp, bool is_last)
 {
 	struct mvneta_tx_desc *tx_desc;
+	dma_addr_t dma_addr;
 
 	tx_desc = mvneta_txq_next_desc_get(txq);
 	tx_desc->data_size = size;
-	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, data,
-						size, DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(dev->dev.parent,
-		     tx_desc->buf_phys_addr))) {
+
+	dma_addr = dma_map_single(dev->dev.parent, data, size, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(dev->dev.parent, dma_addr))) {
 		mvneta_txq_desc_put(txq);
 		return -ENOMEM;
 	}
 
+	tx_desc->buf_phys_addr = dma_addr;
 	tx_desc->command = 0;
 	txq->tx_skb[txq->txq_put_index] = NULL;
 
@@ -2278,9 +2279,10 @@ static int mvneta_tx_tso(struct sk_buff *skb, struct net_device *dev,
 	 */
 	for (i = desc_count - 1; i >= 0; i--) {
 		struct mvneta_tx_desc *tx_desc = txq->descs + i;
-		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr))
+		u32 dma_addr = tx_desc->buf_phys_addr;
+		if (!IS_TSO_HEADER(txq, dma_addr))
 			dma_unmap_single(pp->dev->dev.parent,
-					 tx_desc->buf_phys_addr,
+					 dma_addr,
 					 tx_desc->data_size,
 					 DMA_TO_DEVICE);
 		mvneta_txq_desc_put(txq);
@@ -2296,21 +2298,20 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 
 	for (i = 0; i < nr_frags; i++) {
+		dma_addr_t dma_addr;
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		void *addr = page_address(frag->page.p) + frag->page_offset;
 
 		tx_desc = mvneta_txq_next_desc_get(txq);
 		tx_desc->data_size = frag->size;
 
-		tx_desc->buf_phys_addr =
-			dma_map_single(pp->dev->dev.parent, addr,
-				       tx_desc->data_size, DMA_TO_DEVICE);
-
-		if (dma_mapping_error(pp->dev->dev.parent,
-				      tx_desc->buf_phys_addr)) {
+		dma_addr = dma_map_single(pp->dev->dev.parent, addr,
+					  frag->size, DMA_TO_DEVICE);
+		if (dma_mapping_error(pp->dev->dev.parent, dma_addr)) {
 			mvneta_txq_desc_put(txq);
 			goto error;
 		}
+		tx_desc->buf_phys_addr = dma_addr;
 
 		if (i == nr_frags - 1) {
 			/* Last descriptor */
@@ -2351,7 +2352,8 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 	struct mvneta_tx_desc *tx_desc;
 	int len = skb->len;
 	int frags = 0;
-	u32 tx_cmd;
+	u32 tx_cmd, size;
+	dma_addr_t dma_addr;
 
 	if (!netif_running(dev))
 		goto out;
@@ -2368,17 +2370,17 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 
 	tx_cmd = mvneta_skb_tx_csum(pp, skb);
 
-	tx_desc->data_size = skb_headlen(skb);
+	size = skb_headlen(skb);
+	tx_desc->data_size = size;
 
-	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, skb->data,
-						tx_desc->data_size,
-						DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(dev->dev.parent,
-				       tx_desc->buf_phys_addr))) {
+	dma_addr = dma_map_single(dev->dev.parent, skb->data,
+				  size, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(dev->dev.parent, dma_addr))) {
 		mvneta_txq_desc_put(txq);
 		frags = 0;
 		goto out;
 	}
+	tx_desc->buf_phys_addr = dma_addr;
 
 	if (frags == 1) {
 		/* First and Last descriptor */
@@ -2395,8 +2397,8 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 		/* Continue with other skb fragments */
 		if (mvneta_tx_frag_process(pp, skb, txq)) {
 			dma_unmap_single(dev->dev.parent,
-					 tx_desc->buf_phys_addr,
-					 tx_desc->data_size,
+					 dma_addr,
+					 size,
 					 DMA_TO_DEVICE);
 			mvneta_txq_desc_put(txq);
 			frags = 0;
-- 
2.11.0
