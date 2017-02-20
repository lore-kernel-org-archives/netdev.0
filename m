From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH net-next v3 4/4] net: mvneta: Use cacheable memory to store the rx buffer DMA address
Date: Mon, 20 Feb 2017 20:53:44 +0800
Message-ID: <20170220125344.3555-5-jszhang@marvell.com>
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

In hot code path such as mvneta_rx_swbm(), the buf_phys_addr field of
rx_dec is accessed. The rx_desc is allocated by dma_alloc_coherent,
it's uncacheable if the device isn't cache coherent, reading from
uncached memory is fairly slow. This patch uses cacheable memory to
store the rx buffer DMA address. We get the following performance data
on Marvell BG4CT Platforms (tested with iperf):

before the patch:
recving 1GB in mvneta_rx_swbm() costs 1492659600 ns

after the patch:
recving 1GB in mvneta_rx_swbm() costs 1421565640 ns

We saved 4.76% time.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Suggested-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/mvneta.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b6cda4131c78..ccd3f2601446 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -580,6 +580,9 @@ struct mvneta_rx_queue {
 	/* Virtual address of the RX buffer */
 	void  **buf_virt_addr;
 
+	/* DMA address of the RX buffer */
+	dma_addr_t *buf_dma_addr;
+
 	/* Virtual address of the RX DMA descriptors array */
 	struct mvneta_rx_desc *descs;
 
@@ -1617,6 +1620,7 @@ static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
 
 	rx_desc->buf_phys_addr = phys_addr;
 	i = rx_desc - rxq->descs;
+	rxq->buf_dma_addr[i] = phys_addr;
 	rxq->buf_virt_addr[i] = virt_addr;
 }
 
@@ -1912,10 +1916,9 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 	}
 
 	for (i = 0; i < rxq->size; i++) {
-		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
 		void *data = rxq->buf_virt_addr[i];
 
-		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
+		dma_unmap_single(pp->dev->dev.parent, rxq->buf_dma_addr[i],
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 		mvneta_frag_free(pp->frag_size, data);
 	}
@@ -1953,7 +1956,7 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
 		index = rx_desc - rxq->descs;
 		data = rxq->buf_virt_addr[index];
-		phys_addr = rx_desc->buf_phys_addr;
+		phys_addr = rxq->buf_dma_addr[index];
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
 		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
@@ -4019,7 +4022,10 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 		rxq->buf_virt_addr = devm_kmalloc(pp->dev->dev.parent,
 						  rxq->size * sizeof(void *),
 						  GFP_KERNEL);
-		if (!rxq->buf_virt_addr)
+		rxq->buf_dma_addr = devm_kmalloc(pp->dev->dev.parent,
+						 rxq->size * sizeof(dma_addr_t),
+						 GFP_KERNEL);
+		if (!rxq->buf_virt_addr || !rxq->buf_dma_addr)
 			return -ENOMEM;
 	}
 
-- 
2.11.0
