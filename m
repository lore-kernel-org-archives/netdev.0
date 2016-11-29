From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v4 net-next 3/7] net: mvneta: Use cacheable memory to store the rx buffer virtual address
Date: Tue, 29 Nov 2016 15:55:21 +0100
Message-ID: <bb2f1a61e9b912905f8390f7a06c36f9f1e7ab66.1480431285.git-series.gregory.clement@free-electrons.com>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:59159 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757692AbcK2Oza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:55:30 -0500
In-Reply-To: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now the virtual address of the received buffer were stored in the
cookie field of the rx descriptor. However, this field is 32-bits only
which prevents to use the driver on a 64-bits architecture.

With this patch the virtual address is stored in an array not shared with
the hardware (no more need to use the DMA API). Thanks to this, it is
possible to use cache contrary to the access of the rx descriptor member.

The change is done in the swbm path only because the hwbm uses the cookie
field, this also means that currently the hwbm is not usable in 64-bits.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 34 +++++++++++++++++++---------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f5319c50f8d9..b4810b0c0ffc 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -561,6 +561,9 @@ struct mvneta_rx_queue {
 	u32 pkts_coal;
 	u32 time_coal;
 
+	/* Virtual address of the RX buffer */
+	void  **buf_virt_addr;
+
 	/* Virtual address of the RX DMA descriptors array */
 	struct mvneta_rx_desc *descs;
 
@@ -1573,10 +1576,14 @@ static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
 
 /* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
 static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
-				u32 phys_addr, u32 cookie)
+				u32 phys_addr, void *virt_addr,
+				struct mvneta_rx_queue *rxq)
 {
-	rx_desc->buf_cookie = cookie;
+	int i;
+
 	rx_desc->buf_phys_addr = phys_addr;
+	i = rx_desc - rxq->descs;
+	rxq->buf_virt_addr[i] = virt_addr;
 }
 
 /* Decrement sent descriptors counter */
@@ -1781,7 +1788,8 @@ EXPORT_SYMBOL_GPL(mvneta_frag_free);
 
 /* Refill processing for SW buffer management */
 static int mvneta_rx_refill(struct mvneta_port *pp,
-			    struct mvneta_rx_desc *rx_desc)
+			    struct mvneta_rx_desc *rx_desc,
+			    struct mvneta_rx_queue *rxq)
 
 {
 	dma_addr_t phys_addr;
@@ -1799,7 +1807,7 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 		return -ENOMEM;
 	}
 
-	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
+	mvneta_rx_desc_fill(rx_desc, phys_addr, data, rxq);
 	return 0;
 }
 
@@ -1861,7 +1869,7 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 
 	for (i = 0; i < rxq->size; i++) {
 		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
-		void *data = (void *)rx_desc->buf_cookie;
+		void *data = rxq->buf_virt_addr[i];
 
 		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
@@ -1894,12 +1902,13 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 		unsigned char *data;
 		dma_addr_t phys_addr;
 		u32 rx_status, frag_size;
-		int rx_bytes, err;
+		int rx_bytes, err, index;
 
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
-		data = (unsigned char *)rx_desc->buf_cookie;
+		index = rx_desc - rxq->descs;
+		data = (unsigned char *)rxq->buf_virt_addr[index];
 		phys_addr = rx_desc->buf_phys_addr;
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
@@ -1938,7 +1947,7 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 		}
 
 		/* Refill processing */
-		err = mvneta_rx_refill(pp, rx_desc);
+		err = mvneta_rx_refill(pp, rx_desc, rxq);
 		if (err) {
 			netdev_err(dev, "Linux processing - Can't refill\n");
 			rxq->missed++;
@@ -2020,7 +2029,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
-		data = (unsigned char *)rx_desc->buf_cookie;
+		data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
 		phys_addr = rx_desc->buf_phys_addr;
 		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
 		bm_pool = &pp->bm_priv->bm_pools[pool_id];
@@ -2716,7 +2725,7 @@ static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 
 	for (i = 0; i < num; i++) {
 		memset(rxq->descs + i, 0, sizeof(struct mvneta_rx_desc));
-		if (mvneta_rx_refill(pp, rxq->descs + i) != 0) {
+		if (mvneta_rx_refill(pp, rxq->descs + i, rxq) != 0) {
 			netdev_err(pp->dev, "%s:rxq %d, %d of %d buffs  filled\n",
 				__func__, rxq->id, i, num);
 			break;
@@ -3865,6 +3874,11 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 		rxq->size = pp->rx_ring_size;
 		rxq->pkts_coal = MVNETA_RX_COAL_PKTS;
 		rxq->time_coal = MVNETA_RX_COAL_USEC;
+		rxq->buf_virt_addr = devm_kmalloc(pp->dev->dev.parent,
+						  rxq->size * sizeof(void *),
+						  GFP_KERNEL);
+		if (!rxq->buf_virt_addr)
+			return -ENOMEM;
 	}
 
 	return 0;
-- 
git-series 0.8.10
