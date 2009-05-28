From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] net: replace dma_sync_single with dma_sync_single_for_cpu
Date: Thu, 28 May 2009 10:10:42 +0900
Message-ID: <20090528100925H.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:56485 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbZE1BKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 21:10:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces dma_sync_single() with dma_sync_single_for_cpu() because
dma_sync_single() is an obsolete API; include/linux/dma-mapping.h says:

/* Backwards compat, remove in 2.7.x */
#define dma_sync_single		dma_sync_single_for_cpu
#define dma_sync_sg		dma_sync_sg_for_cpu

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/arm/ep93xx_eth.c |    4 ++--
 drivers/net/arm/ixp4xx_eth.c |    4 ++--
 drivers/net/mlx4/mr.c        |    7 ++++---
 drivers/net/wan/ixp4xx_hss.c |    4 ++--
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index b72b3d6..fbf4645 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -253,7 +253,7 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 		skb = dev_alloc_skb(length + 2);
 		if (likely(skb != NULL)) {
 			skb_reserve(skb, 2);
-			dma_sync_single(NULL, ep->descs->rdesc[entry].buf_addr,
+			dma_sync_single_for_cpu(NULL, ep->descs->rdesc[entry].buf_addr,
 						length, DMA_FROM_DEVICE);
 			skb_copy_to_linear_data(skb, ep->rx_buf[entry], length);
 			skb_put(skb, length);
@@ -331,7 +331,7 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 	ep->descs->tdesc[entry].tdesc1 =
 		TDESC1_EOF | (entry << 16) | (skb->len & 0xfff);
 	skb_copy_and_csum_dev(skb, ep->tx_buf[entry]);
-	dma_sync_single(NULL, ep->descs->tdesc[entry].buf_addr,
+	dma_sync_single_for_cpu(NULL, ep->descs->tdesc[entry].buf_addr,
 				skb->len, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index b6d1881..6d346be 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -562,8 +562,8 @@ static int eth_poll(struct napi_struct *napi, int budget)
 		dma_unmap_single(&dev->dev, desc->data - NET_IP_ALIGN,
 				 RX_BUFF_SIZE, DMA_FROM_DEVICE);
 #else
-		dma_sync_single(&dev->dev, desc->data - NET_IP_ALIGN,
-				RX_BUFF_SIZE, DMA_FROM_DEVICE);
+		dma_sync_single_for_cpu(&dev->dev, desc->data - NET_IP_ALIGN,
+					RX_BUFF_SIZE, DMA_FROM_DEVICE);
 		memcpy_swab32((u32 *)skb->data, (u32 *)port->rx_buff_tab[n],
 			      ALIGN(NET_IP_ALIGN + desc->pkt_len, 4) / 4);
 #endif
diff --git a/drivers/net/mlx4/mr.c b/drivers/net/mlx4/mr.c
index 0caf74c..0a46778 100644
--- a/drivers/net/mlx4/mr.c
+++ b/drivers/net/mlx4/mr.c
@@ -402,7 +402,8 @@ static int mlx4_write_mtt_chunk(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 	for (i = 0; i < npages; ++i)
 		mtts[i] = cpu_to_be64(page_list[i] | MLX4_MTT_FLAG_PRESENT);
 
-	dma_sync_single(&dev->pdev->dev, dma_handle, npages * sizeof (u64), DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(&dev->pdev->dev, dma_handle,
+				npages * sizeof (u64), DMA_TO_DEVICE);
 
 	return 0;
 }
@@ -549,8 +550,8 @@ int mlx4_map_phys_fmr(struct mlx4_dev *dev, struct mlx4_fmr *fmr, u64 *page_list
 	for (i = 0; i < npages; ++i)
 		fmr->mtts[i] = cpu_to_be64(page_list[i] | MLX4_MTT_FLAG_PRESENT);
 
-	dma_sync_single(&dev->pdev->dev, fmr->dma_handle,
-			npages * sizeof(u64), DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(&dev->pdev->dev, fmr->dma_handle,
+				npages * sizeof(u64), DMA_TO_DEVICE);
 
 	fmr->mpt->key    = cpu_to_be32(key);
 	fmr->mpt->lkey   = cpu_to_be32(key);
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index a6dc317..bb719b6 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -732,8 +732,8 @@ static int hss_hdlc_poll(struct napi_struct *napi, int budget)
 		dma_unmap_single(&dev->dev, desc->data,
 				 RX_SIZE, DMA_FROM_DEVICE);
 #else
-		dma_sync_single(&dev->dev, desc->data,
-				RX_SIZE, DMA_FROM_DEVICE);
+		dma_sync_single_for_cpu(&dev->dev, desc->data,
+					RX_SIZE, DMA_FROM_DEVICE);
 		memcpy_swab32((u32 *)skb->data, (u32 *)port->rx_buff_tab[n],
 			      ALIGN(desc->pkt_len, 4) / 4);
 #endif
-- 
1.6.0.6

