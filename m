From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 06/11] net/mlx5e: Fix dangling page pointer on DMA mapping error
Date: Thu, 31 Aug 2017 01:21:05 +0300
Message-ID: <20170830222110.15737-7-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53240 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751323AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Function mlx5e_dealloc_rx_wqe is using page pointer value as an
indication to valid DMA mapping. In case that the mapping failed, we
released the page but kept the dangling pointer. Store the page pointer
only after the DMA mapping passed to avoid invalid page DMA unmap.

Fixes: bc77b240b3c5 ("net/mlx5e: Add fragmented memory support for RX multi packet WQE")
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 325b2c8c1c6d..7344433259fc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -222,13 +222,13 @@ static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	dma_info->page = page;
 	dma_info->addr = dma_map_page(rq->pdev, page, 0,
 				      RQ_PAGE_SIZE(rq), rq->buff.map_dir);
 	if (unlikely(dma_mapping_error(rq->pdev, dma_info->addr))) {
 		put_page(page);
 		return -ENOMEM;
 	}
+	dma_info->page = page;
 
 	return 0;
 }
-- 
2.13.0
