From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: use netdev_alloc_frag()
Date: Mon, 10 Dec 2012 14:16:06 -0800
Message-ID: <1355177766.27891.68.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48818 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab2LJWQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 17:16:09 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so2206356pbc.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 14:16:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using netdev_alloc_frag() instead of kmalloc() permits better GRO or
TCP coalescing behavior, as skb_gro_receive() doesn't have to fallback
to frag_list overhead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   43 ++++++++++----
 2 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 9a3b81e..e8d4db1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -489,7 +489,7 @@ struct bnx2x_fastpath {
 	u32			ustorm_rx_prods_offset;
 
 	u32			rx_buf_size;
-
+	u32			rx_frag_size; /* 0 if kmalloced(), or rx_buf_size + NET_SKB_PAD */
 	dma_addr_t		status_blk_mapping;
 
 	enum bnx2x_tpa_mode_t	mode;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 67baddd..c9f8ae0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -552,6 +552,23 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	return 0;
 }
 
+static void bnx2x_frag_free(const struct bnx2x_fastpath *fp, void *data)
+{
+	if (fp->rx_frag_size)
+		put_page(virt_to_head_page(data));
+	else
+		kfree(data);
+}
+
+static void *bnx2x_frag_alloc(const struct bnx2x_fastpath *fp)
+{
+	if (fp->rx_frag_size)
+		return netdev_alloc_frag(fp->rx_frag_size);
+
+	return kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
+}
+
+
 static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			   struct bnx2x_agg_info *tpa_info,
 			   u16 pages,
@@ -574,15 +591,14 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		goto drop;
 
 	/* Try to allocate the new data */
-	new_data = kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
-
+	new_data = bnx2x_frag_alloc(fp);
 	/* Unmap skb in the pool anyway, as we are going to change
 	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
 	   fails. */
 	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
 			 fp->rx_buf_size, DMA_FROM_DEVICE);
 	if (likely(new_data))
-		skb = build_skb(data, 0);
+		skb = build_skb(data, fp->rx_frag_size);
 
 	if (likely(skb)) {
 #ifdef BNX2X_STOP_ON_ERROR
@@ -619,7 +635,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		return;
 	}
-	kfree(new_data);
+	bnx2x_frag_free(fp, new_data);
 drop:
 	/* drop the packet and keep the buffer in the bin */
 	DP(NETIF_MSG_RX_STATUS,
@@ -635,7 +651,7 @@ static int bnx2x_alloc_rx_data(struct bnx2x *bp,
 	struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
 	dma_addr_t mapping;
 
-	data = kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
+	data = bnx2x_frag_alloc(fp);
 	if (unlikely(data == NULL))
 		return -ENOMEM;
 
@@ -643,7 +659,7 @@ static int bnx2x_alloc_rx_data(struct bnx2x *bp,
 				 fp->rx_buf_size,
 				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		kfree(data);
+		bnx2x_frag_free(fp, data);
 		BNX2X_ERR("Can't map rx data\n");
 		return -ENOMEM;
 	}
@@ -845,9 +861,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 						 dma_unmap_addr(rx_buf, mapping),
 						 fp->rx_buf_size,
 						 DMA_FROM_DEVICE);
-				skb = build_skb(data, 0);
+				skb = build_skb(data, fp->rx_frag_size);
 				if (unlikely(!skb)) {
-					kfree(data);
+					bnx2x_frag_free(fp, data);
 					bnx2x_fp_qstats(bp, fp)->
 							rx_skb_alloc_failed++;
 					goto next_rx;
@@ -1145,7 +1161,7 @@ static void bnx2x_free_tpa_pool(struct bnx2x *bp,
 			dma_unmap_single(&bp->pdev->dev,
 					 dma_unmap_addr(first_buf, mapping),
 					 fp->rx_buf_size, DMA_FROM_DEVICE);
-		kfree(data);
+		bnx2x_frag_free(fp, data);
 		first_buf->data = NULL;
 	}
 }
@@ -1190,8 +1206,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 				struct sw_rx_bd *first_buf =
 					&tpa_info->first_buf;
 
-				first_buf->data = kmalloc(fp->rx_buf_size + NET_SKB_PAD,
-							  GFP_ATOMIC);
+				first_buf->data = bnx2x_frag_alloc(fp);
 				if (!first_buf->data) {
 					BNX2X_ERR("Failed to allocate TPA skb pool for queue[%d] - disabling TPA on this queue!\n",
 						  j);
@@ -1323,7 +1338,7 @@ static void bnx2x_free_rx_bds(struct bnx2x_fastpath *fp)
 				 fp->rx_buf_size, DMA_FROM_DEVICE);
 
 		rx_buf->data = NULL;
-		kfree(data);
+		bnx2x_frag_free(fp, data);
 	}
 }
 
@@ -1782,6 +1797,10 @@ static void bnx2x_set_rx_buf_size(struct bnx2x *bp)
 				  mtu +
 				  BNX2X_FW_RX_ALIGN_END;
 		/* Note : rx_buf_size doesnt take into account NET_SKB_PAD */
+		if (fp->rx_buf_size + NET_SKB_PAD <= PAGE_SIZE)
+			fp->rx_frag_size = fp->rx_buf_size + NET_SKB_PAD;
+		else
+			fp->rx_frag_size = 0;
 	}
 }
 
