From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 12/12] net/mlx5: Avoid passing dma address 0 to firmware
Date: Tue, 25 Oct 2016 18:36:35 +0300
Message-ID: <1477409795-28807-13-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Noa Osherovich <noaos@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40965 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932696AbcJYPi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:29 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noa Osherovich <noaos@mellanox.com>

Currently the firmware can't work with a page with dma address 0.
Passing such an address to the firmware will cause the give_pages
command to fail.

To avoid this, in case we get a 0 dma address of a page from the
dma engine, we avoid passing it to FW by remapping to get an address
other than 0.

Fixes: bf0bf77f6519 ('mlx5: Support communicating arbitrary host...')
Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    | 26 +++++++++++++++-------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index cc4fd61..a57d5a8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -209,6 +209,7 @@ static void free_4k(struct mlx5_core_dev *dev, u64 addr)
 static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
 {
 	struct page *page;
+	u64 zero_addr = 1;
 	u64 addr;
 	int err;
 	int nid = dev_to_node(&dev->pdev->dev);
@@ -218,26 +219,35 @@ static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
 		mlx5_core_warn(dev, "failed to allocate page\n");
 		return -ENOMEM;
 	}
+map:
 	addr = dma_map_page(&dev->pdev->dev, page, 0,
 			    PAGE_SIZE, DMA_BIDIRECTIONAL);
 	if (dma_mapping_error(&dev->pdev->dev, addr)) {
 		mlx5_core_warn(dev, "failed dma mapping page\n");
 		err = -ENOMEM;
-		goto out_alloc;
+		goto err_mapping;
 	}
+
+	/* Firmware doesn't support page with physical address 0 */
+	if (addr == 0) {
+		zero_addr = addr;
+		goto map;
+	}
+
 	err = insert_page(dev, addr, page, func_id);
 	if (err) {
 		mlx5_core_err(dev, "failed to track allocated page\n");
-		goto out_mapping;
+		dma_unmap_page(&dev->pdev->dev, addr, PAGE_SIZE,
+			       DMA_BIDIRECTIONAL);
 	}
 
-	return 0;
-
-out_mapping:
-	dma_unmap_page(&dev->pdev->dev, addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
+err_mapping:
+	if (err)
+		__free_page(page);
 
-out_alloc:
-	__free_page(page);
+	if (zero_addr == 0)
+		dma_unmap_page(&dev->pdev->dev, zero_addr, PAGE_SIZE,
+			       DMA_BIDIRECTIONAL);
 
 	return err;
 }
-- 
2.7.4
