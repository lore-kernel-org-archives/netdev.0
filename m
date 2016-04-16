From: Sinan Kaya <okaya@codeaurora.org>
Subject: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Sat, 16 Apr 2016 18:23:32 -0400
Message-ID: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
Cc: Sinan Kaya <okaya@codeaurora.org>,
	Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-rdma@vger.kernel.org, timur@codeaurora.org,
	cov@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41093 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbcDPWXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 18:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code is assuming that the address returned by dma_alloc_coherent
is a logical address. This is not true on ARM/ARM64 systems. This patch
replaces dma_alloc_coherent with dma_map_page API. The address returned
can later by virtually mapped from the CPU side with vmap API.

Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
---
 drivers/net/ethernet/mellanox/mlx4/alloc.c | 37 ++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index 0c51c69..22a7ae7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -618,13 +618,26 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 			return -ENOMEM;
 
 		for (i = 0; i < buf->nbufs; ++i) {
-			buf->page_list[i].buf =
-				dma_alloc_coherent(&dev->persist->pdev->dev,
-						   PAGE_SIZE,
-						   &t, gfp);
-			if (!buf->page_list[i].buf)
+			struct page *page;
+
+			page = alloc_page(GFP_KERNEL);
+			if (!page)
 				goto err_free;
 
+			t = dma_map_page(&dev->persist->pdev->dev, page, 0,
+					 PAGE_SIZE, DMA_BIDIRECTIONAL);
+
+			if (dma_mapping_error(&dev->persist->pdev->dev, t)) {
+				__free_page(page);
+				goto err_free;
+			}
+
+			buf->page_list[i].buf = page_address(page);
+			if (!buf->page_list[i].buf) {
+				__free_page(page);
+				goto err_free;
+			}
+
 			buf->page_list[i].map = t;
 
 			memset(buf->page_list[i].buf, 0, PAGE_SIZE);
@@ -666,11 +679,15 @@ void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf)
 			vunmap(buf->direct.buf);
 
 		for (i = 0; i < buf->nbufs; ++i)
-			if (buf->page_list[i].buf)
-				dma_free_coherent(&dev->persist->pdev->dev,
-						  PAGE_SIZE,
-						  buf->page_list[i].buf,
-						  buf->page_list[i].map);
+			if (buf->page_list[i].buf) {
+				struct page *page;
+
+				page = virt_to_page(buf->page_list[i].buf);
+				dma_unmap_page(&dev->persist->pdev->dev,
+					       buf->page_list[i].map,
+					       PAGE_SIZE, DMA_BIDIRECTIONAL);
+				__free_page(page);
+			}
 		kfree(buf->page_list);
 	}
 }
-- 
1.8.2.1
