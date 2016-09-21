From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 1/6] net/faraday: Separate rx page storage from rxdesc
Date: Thu, 22 Sep 2016 08:34:58 +0930
Message-ID: <20160921230503.23309-2-joel@jms.id.au>
References: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, Andrew Jeffery <andrew@aj.id.au>,
        gwshan@linux.vnet.ibm.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Jeffery <andrew@aj.id.au>

The ftgmac100 hardware revision in e.g. the Aspeed AST2500 no longer
reserves all bits in RXDES#2 but instead uses the bottom 16 bits to
store MAC frame metadata. Avoid corruption by shifting struct page
pointers out to their own member in struct ftgmac100.

Signed-off-by: Andrew Jeffery <andrew@aj.id.au>
Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 36361f8bf894..40622567159a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -60,6 +60,8 @@ struct ftgmac100 {
 	struct ftgmac100_descs *descs;
 	dma_addr_t descs_dma_addr;
 
+	struct page *rx_pages[RX_QUEUE_ENTRIES];
+
 	unsigned int rx_pointer;
 	unsigned int tx_clean_pointer;
 	unsigned int tx_pointer;
@@ -341,18 +343,27 @@ static bool ftgmac100_rxdes_ipcs_err(struct ftgmac100_rxdes *rxdes)
 	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_IP_CHKSUM_ERR);
 }
 
+static inline struct page **ftgmac100_rxdes_page_slot(struct ftgmac100 *priv,
+						      struct ftgmac100_rxdes *rxdes)
+{
+	return &priv->rx_pages[rxdes - priv->descs->rxdes];
+}
+
 /*
  * rxdes2 is not used by hardware. We use it to keep track of page.
  * Since hardware does not touch it, we can skip cpu_to_le32()/le32_to_cpu().
  */
-static void ftgmac100_rxdes_set_page(struct ftgmac100_rxdes *rxdes, struct page *page)
+static void ftgmac100_rxdes_set_page(struct ftgmac100 *priv,
+				     struct ftgmac100_rxdes *rxdes,
+				     struct page *page)
 {
-	rxdes->rxdes2 = (unsigned int)page;
+	*ftgmac100_rxdes_page_slot(priv, rxdes) = page;
 }
 
-static struct page *ftgmac100_rxdes_get_page(struct ftgmac100_rxdes *rxdes)
+static struct page *ftgmac100_rxdes_get_page(struct ftgmac100 *priv,
+					     struct ftgmac100_rxdes *rxdes)
 {
-	return (struct page *)rxdes->rxdes2;
+	return *ftgmac100_rxdes_page_slot(priv, rxdes);
 }
 
 /******************************************************************************
@@ -501,7 +512,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
 	do {
 		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
-		struct page *page = ftgmac100_rxdes_get_page(rxdes);
+		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
 		unsigned int size;
 
 		dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
@@ -779,7 +790,7 @@ static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 		return -ENOMEM;
 	}
 
-	ftgmac100_rxdes_set_page(rxdes, page);
+	ftgmac100_rxdes_set_page(priv, rxdes, page);
 	ftgmac100_rxdes_set_dma_addr(rxdes, map);
 	ftgmac100_rxdes_set_dma_own(rxdes);
 	return 0;
@@ -791,7 +802,7 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
-		struct page *page = ftgmac100_rxdes_get_page(rxdes);
+		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
 		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
 
 		if (!page)
-- 
2.9.3
