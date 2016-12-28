From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 10/11] net: mvpp2: switch to build_skb() in the RX path
Date: Wed, 28 Dec 2016 17:46:06 +0100
Message-ID: <1482943567-12483-11-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47567 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbcL1Qq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:46:26 -0500
In-Reply-To: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adapts the mvpp2 RX path to use the build_skb() method. Not
only build_skb() is now the recommended mechanism, but it also
simplifies the addition of support for the PPv2.2 variant.

Indeed, without build_skb(), we have to keep track for each RX
descriptor of the physical address of the packet buffer, and the virtual
address of the SKB. However, in PPv2.2 running on 64 bits platform,
there is not enough space in the descriptor to store the virtual address
of the SKB. So having to take care only of the address of the packet
buffer, and building the SKB upon reception helps in supporting PPv2.2.

The implementation is fairly straightforward:

 - mvpp2_skb_alloc() is renamed to mvpp2_buf_alloc() and no longer
   allocates a SKB. Instead, it allocates a buffer using the new
   mvpp2_frag_alloc() function, with enough space for the data and SKB.

 - The initialization of the RX buffers in mvpp2_bm_bufs_add() as well
   as the refill of the RX buffers in mvpp2_rx_refill() is adjusted
   accordingly.

 - Finally, the mvpp2_rx() is modified to use build_skb().

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 77 +++++++++++++++++++++++++-----------
 1 file changed, 55 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 58cf9af..1e08e8f 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -918,6 +918,7 @@ struct mvpp2_bm_pool {
 	int buf_size;
 	/* Packet size */
 	int pkt_size;
+	int frag_size;
 
 	/* BPPE virtual base address */
 	u32 *virt_addr;
@@ -3354,6 +3355,22 @@ static void mvpp2_cls_oversize_rxq_set(struct mvpp2_port *port)
 	mvpp2_write(port->priv, MVPP2_CLS_SWFWD_PCTRL_REG, val);
 }
 
+static void *mvpp2_frag_alloc(const struct mvpp2_bm_pool *pool)
+{
+	if (likely(pool->frag_size <= PAGE_SIZE))
+		return netdev_alloc_frag(pool->frag_size);
+	else
+		return kmalloc(pool->frag_size, GFP_ATOMIC);
+}
+
+static void mvpp2_frag_free(const struct mvpp2_bm_pool *pool, void *data)
+{
+	if (likely(pool->frag_size <= PAGE_SIZE))
+		skb_free_frag(data);
+	else
+		kfree(data);
+}
+
 /* Buffer Manager configuration routines */
 
 /* Create pool */
@@ -3428,7 +3445,8 @@ static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
 
 		if (!vaddr)
 			break;
-		dev_kfree_skb_any((struct sk_buff *)vaddr);
+
+		mvpp2_frag_free(bm_pool, (void *)vaddr);
 	}
 
 	/* Update BM driver with number of buffers removed from pool */
@@ -3542,29 +3560,28 @@ static void mvpp2_rxq_short_pool_set(struct mvpp2_port *port,
 	mvpp2_write(port->priv, MVPP2_RXQ_CONFIG_REG(prxq), val);
 }
 
-/* Allocate skb for BM pool */
-static struct sk_buff *mvpp2_skb_alloc(struct mvpp2_port *port,
-				       struct mvpp2_bm_pool *bm_pool,
-				       dma_addr_t *buf_phys_addr,
-				       gfp_t gfp_mask)
+static void *mvpp2_buf_alloc(struct mvpp2_port *port,
+			     struct mvpp2_bm_pool *bm_pool,
+			     dma_addr_t *buf_phys_addr,
+			     gfp_t gfp_mask)
 {
-	struct sk_buff *skb;
 	dma_addr_t phys_addr;
+	void *data;
 
-	skb = __dev_alloc_skb(bm_pool->pkt_size, gfp_mask);
-	if (!skb)
+	data = mvpp2_frag_alloc(bm_pool);
+	if (!data)
 		return NULL;
 
-	phys_addr = dma_map_single(port->dev->dev.parent, skb->head,
+	phys_addr = dma_map_single(port->dev->dev.parent, data,
 				   MVPP2_RX_BUF_SIZE(bm_pool->pkt_size),
 				    DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(port->dev->dev.parent, phys_addr))) {
-		dev_kfree_skb_any(skb);
+		mvpp2_frag_free(bm_pool, data);
 		return NULL;
 	}
 	*buf_phys_addr = phys_addr;
 
-	return skb;
+	return data;
 }
 
 /* Set pool number in a BM cookie */
@@ -3620,9 +3637,9 @@ static void mvpp2_pool_refill(struct mvpp2_port *port, u32 bm,
 static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 			     struct mvpp2_bm_pool *bm_pool, int buf_num)
 {
-	struct sk_buff *skb;
 	int i, buf_size, total_size;
 	dma_addr_t phys_addr;
+	void *buf;
 
 	buf_size = MVPP2_RX_BUF_SIZE(bm_pool->pkt_size);
 	total_size = MVPP2_RX_TOTAL_SIZE(buf_size);
@@ -3636,11 +3653,11 @@ static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 	}
 
 	for (i = 0; i < buf_num; i++) {
-		skb = mvpp2_skb_alloc(port, bm_pool, &phys_addr, GFP_KERNEL);
-		if (!skb)
+		buf = mvpp2_buf_alloc(port, bm_pool, &phys_addr, GFP_KERNEL);
+		if (!buf)
 			break;
 
-		mvpp2_bm_pool_put(port, bm_pool->id, (u32)phys_addr, (u32)skb);
+		mvpp2_bm_pool_put(port, bm_pool->id, (u32)phys_addr, (u32)buf);
 	}
 
 	/* Update BM driver with number of buffers added to pool */
@@ -3696,6 +3713,9 @@ mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 					   port->priv, new_pool);
 
 		new_pool->pkt_size = pkt_size;
+		new_pool->frag_size =
+			SKB_DATA_ALIGN(MVPP2_RX_BUF_SIZE(pkt_size)) +
+			MVPP2_SKB_SHINFO_SIZE;
 
 		/* Allocate buffers for this pool */
 		num = mvpp2_bm_bufs_add(port, new_pool, pkts_num);
@@ -4987,15 +5007,15 @@ static void mvpp2_rx_csum(struct mvpp2_port *port, u32 status,
 static int mvpp2_rx_refill(struct mvpp2_port *port,
 			   struct mvpp2_bm_pool *bm_pool, u32 bm)
 {
-	struct sk_buff *skb;
 	dma_addr_t phys_addr;
+	void *buf;
 
 	/* No recycle or too many buffers are in use, so allocate a new skb */
-	skb = mvpp2_skb_alloc(port, bm_pool, &phys_addr, GFP_ATOMIC);
-	if (!skb)
+	buf = mvpp2_buf_alloc(port, bm_pool, &phys_addr, GFP_ATOMIC);
+	if (!buf)
 		return -ENOMEM;
 
-	mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)skb);
+	mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)buf);
 
 	return 0;
 }
@@ -5087,14 +5107,17 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		struct mvpp2_rx_desc *rx_desc = mvpp2_rxq_next_desc_get(rxq);
 		struct mvpp2_bm_pool *bm_pool;
 		struct sk_buff *skb;
+		unsigned int frag_size;
 		dma_addr_t phys_addr;
 		u32 bm, rx_status;
 		int pool, rx_bytes, err;
+		void *data;
 
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - MVPP2_MH_SIZE;
 		phys_addr = rx_desc->buf_phys_addr;
+		data = (void *)rx_desc->buf_cookie;
 
 		bm = mvpp2_bm_cookie_build(rx_desc);
 		pool = mvpp2_bm_cookie_pool_get(bm);
@@ -5115,12 +5138,22 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
+
 			mvpp2_pool_refill(port, bm, rx_desc->buf_phys_addr,
 					  rx_desc->buf_cookie);
 			continue;
 		}
 
-		skb = (struct sk_buff *)rx_desc->buf_cookie;
+		if (bm_pool->frag_size > PAGE_SIZE)
+			frag_size = 0;
+		else
+			frag_size = bm_pool->frag_size;
+
+		skb = build_skb(data, frag_size);
+		if (!skb) {
+			netdev_warn(port->dev, "skb build failed\n");
+			goto err_drop_frame;
+		}
 
 		err = mvpp2_rx_refill(port, bm_pool, bm);
 		if (err) {
@@ -5134,7 +5167,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		rcvd_pkts++;
 		rcvd_bytes += rx_bytes;
 
-		skb_reserve(skb, MVPP2_MH_SIZE);
+		skb_reserve(skb, MVPP2_MH_SIZE + NET_SKB_PAD);
 		skb_put(skb, rx_bytes);
 		skb->protocol = eth_type_trans(skb, dev);
 		mvpp2_rx_csum(port, rx_status, skb);
-- 
2.7.4
