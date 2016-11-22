From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 1/4] net: mvneta: Convert to be 64 bits compatible
Date: Tue, 22 Nov 2016 17:48:41 +0100
Message-ID: <20161122164844.19566-2-gregory.clement@free-electrons.com>
References: <20161122164844.19566-1-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Marcin Wojtas <mw@semihalf.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161122164844.19566-1-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>

Prepare the mvneta driver in order to be usable on the 64 bits platform
such as the Armada 3700.

[gregory.clement@free-electrons.com]: this patch was extract from a larger
one to ease review and maintenance.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 77 ++++++++++++++++++++++++++++++++---
 1 file changed, 71 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 87274d4ab102..67f6465d96ba 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -296,6 +296,12 @@
 /* descriptor aligned size */
 #define MVNETA_DESC_ALIGNED_SIZE	32
 
+/* Number of bytes to be taken into account by HW when putting incoming data
+ * to the buffers. It is needed in case NET_SKB_PAD exceeds maximum packet
+ * offset supported in MVNETA_RXQ_CONFIG_REG(q) registers.
+ */
+#define MVNETA_RX_PKT_OFFSET_CORRECTION		64
+
 #define MVNETA_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVNETA_MH_SIZE + MVNETA_VLAN_TAG_LEN + \
 	      ETH_HLEN + ETH_FCS_LEN,			     \
@@ -416,8 +422,11 @@ struct mvneta_port {
 	u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
 
 	u32 indir[MVNETA_RSS_LU_TABLE_SIZE];
+#ifdef CONFIG_64BIT
+	u64 data_high;
+#endif
+	u16 rx_offset_correction;
 };
-
 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
  * layout of the transmit and reception DMA descriptors, and their
  * layout is therefore defined by the hardware design
@@ -1791,6 +1800,10 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 	if (!data)
 		return -ENOMEM;
 
+#ifdef CONFIG_64BIT
+	if (unlikely(pp->data_high != (u64)upper_32_bits((u64)data) << 32))
+		return -ENOMEM;
+#endif
 	phys_addr = dma_map_single(pp->dev->dev.parent, data,
 				   MVNETA_RX_BUF_SIZE(pp->pkt_size),
 				   DMA_FROM_DEVICE);
@@ -1799,7 +1812,8 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 		return -ENOMEM;
 	}
 
-	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
+	phys_addr += pp->rx_offset_correction;
+	mvneta_rx_desc_fill(rx_desc, phys_addr, (uintptr_t)data);
 	return 0;
 }
 
@@ -1861,8 +1875,16 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 
 	for (i = 0; i < rxq->size; i++) {
 		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
-		void *data = (void *)rx_desc->buf_cookie;
-
+		void *data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
+#ifdef CONFIG_64BIT
+		/* In Neta HW only 32 bits data is supported, so in
+		 * order to obtain whole 64 bits address from RX
+		 * descriptor, we store the upper 32 bits when
+		 * allocating buffer, and put it back when using
+		 * buffer cookie for accessing packet in memory.
+		 */
+		data = (u8 *)(pp->data_high | (u64)data);
+#endif
 		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 		mvneta_frag_free(pp->frag_size, data);
@@ -1899,7 +1921,17 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
+#ifdef CONFIG_64BIT
+		/* In Neta HW only 32 bits data is supported, so in
+		 * order to obtain whole 64 bits address from RX
+		 * descriptor, we store the upper 32 bits when
+		 * allocating buffer, and put it back when using
+		 * buffer cookie for accessing packet in memory.
+		 */
+		data = (u8 *)(pp->data_high | (u64)rx_desc->buf_cookie);
+#else
 		data = (unsigned char *)rx_desc->buf_cookie;
+#endif
 		phys_addr = rx_desc->buf_phys_addr;
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
@@ -2020,7 +2052,17 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
-		data = (unsigned char *)rx_desc->buf_cookie;
+#ifdef CONFIG_64BIT
+		/* In Neta HW only 32 bits data is supported, so in
+		 * order to obtain whole 64 bits address from RX
+		 * descriptor, we store the upper 32 bits when
+		 * allocating buffer, and put it back when using
+		 * buffer cookie for accessing packet in memory.
+		 */
+		data = (u8 *)(pp->data_high | (u64)rx_desc->buf_cookie);
+#else
+		data = (u8 *)rx_desc->buf_cookie;
+#endif
 		phys_addr = rx_desc->buf_phys_addr;
 		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
 		bm_pool = &pp->bm_priv->bm_pools[pool_id];
@@ -2773,7 +2815,7 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 	mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), rxq->size);
 
 	/* Set Offset */
-	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD);
+	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD - pp->rx_offset_correction);
 
 	/* Set coalescing pkts and time */
 	mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
@@ -2930,6 +2972,22 @@ static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
 static int mvneta_setup_rxqs(struct mvneta_port *pp)
 {
 	int queue;
+#ifdef CONFIG_64BIT
+	void *data_tmp;
+
+	/* In Neta HW only 32 bits data is supported, so in order to
+	 * obtain whole 64 bits address from RX descriptor, we store
+	 * the upper 32 bits when allocating buffer, and put it back
+	 * when using buffer cookie for accessing packet in memory.
+	 * Frags should be allocated from single 'memory' region,
+	 * hence common upper address half should be sufficient.
+	 */
+	data_tmp = mvneta_frag_alloc(pp->frag_size);
+	if (data_tmp) {
+		pp->data_high = (u64)upper_32_bits((u64)data_tmp) << 32;
+		mvneta_frag_free(pp->frag_size, data_tmp);
+	}
+#endif
 
 	for (queue = 0; queue < rxq_number; queue++) {
 		int err = mvneta_rxq_init(pp, &pp->rxqs[queue]);
@@ -4019,6 +4077,13 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	pp->rxq_def = rxq_def;
 
+	/* Set RX packet offset correction for platforms, whose
+	 * NET_SKB_PAD, exceeds 64B. It should be 64B for 64-bit
+	 * platforms and 0B for 32-bit ones.
+	 */
+	pp->rx_offset_correction =
+		max(0, NET_SKB_PAD - MVNETA_RX_PKT_OFFSET_CORRECTION);
+
 	pp->indir[0] = rxq_def;
 
 	pp->clk = devm_clk_get(&pdev->dev, "core");
-- 
2.10.2
