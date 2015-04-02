From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 07/16] net/mlx5_core: Use coherent memory for command interface page
Date: Thu,  2 Apr 2015 17:07:25 +0300
Message-ID: <1427983654-971-8-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36684 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDBOIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:00 -0400
Received: by wizk4 with SMTP id k4so16539429wiz.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:59 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use coherent memory for the commands descriptor page. Take measures to make
sure the page is aligned to MLX5_ADAPTER_PAGE_SIZE as required by the hardware.

Reported-by: Yevgeny Kliteynik <kliteyn@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 72 ++++++++++++++++++---------
 include/linux/mlx5/driver.h                   |  3 ++
 2 files changed, 52 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index a2853057c779..43a73d36b01d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1319,6 +1319,45 @@ ex_err:
 	return err;
 }
 
+static int alloc_cmd_page(struct mlx5_core_dev *dev, struct mlx5_cmd *cmd)
+{
+	struct device *ddev = &dev->pdev->dev;
+
+	cmd->cmd_alloc_buf = dma_zalloc_coherent(ddev, MLX5_ADAPTER_PAGE_SIZE,
+						 &cmd->alloc_dma, GFP_KERNEL);
+	if (!cmd->cmd_alloc_buf)
+		return -ENOMEM;
+
+	/* make sure it is aligned to 4K */
+	if (!((uintptr_t)cmd->cmd_alloc_buf & (MLX5_ADAPTER_PAGE_SIZE - 1))) {
+		cmd->cmd_buf = cmd->cmd_alloc_buf;
+		cmd->dma = cmd->alloc_dma;
+		cmd->alloc_size = MLX5_ADAPTER_PAGE_SIZE;
+		return 0;
+	}
+
+	dma_free_coherent(ddev, MLX5_ADAPTER_PAGE_SIZE, cmd->cmd_alloc_buf,
+			  cmd->alloc_dma);
+	cmd->cmd_alloc_buf = dma_zalloc_coherent(ddev,
+						 2 * MLX5_ADAPTER_PAGE_SIZE - 1,
+						 &cmd->alloc_dma, GFP_KERNEL);
+	if (!cmd->cmd_alloc_buf)
+		return -ENOMEM;
+
+	cmd->cmd_buf = PTR_ALIGN(cmd->cmd_alloc_buf, MLX5_ADAPTER_PAGE_SIZE);
+	cmd->dma = ALIGN(cmd->alloc_dma, MLX5_ADAPTER_PAGE_SIZE);
+	cmd->alloc_size = 2 * MLX5_ADAPTER_PAGE_SIZE - 1;
+	return 0;
+}
+
+static void free_cmd_page(struct mlx5_core_dev *dev, struct mlx5_cmd *cmd)
+{
+	struct device *ddev = &dev->pdev->dev;
+
+	dma_free_coherent(ddev, cmd->alloc_size, cmd->cmd_alloc_buf,
+			  cmd->alloc_dma);
+}
+
 int mlx5_cmd_init(struct mlx5_core_dev *dev)
 {
 	int size = sizeof(struct mlx5_cmd_prot_block);
@@ -1341,17 +1380,9 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	if (!cmd->pool)
 		return -ENOMEM;
 
-	cmd->cmd_buf = (void *)__get_free_pages(GFP_ATOMIC, 0);
-	if (!cmd->cmd_buf) {
-		err = -ENOMEM;
+	err = alloc_cmd_page(dev, cmd);
+	if (err)
 		goto err_free_pool;
-	}
-	cmd->dma = dma_map_single(&dev->pdev->dev, cmd->cmd_buf, PAGE_SIZE,
-				  DMA_BIDIRECTIONAL);
-	if (dma_mapping_error(&dev->pdev->dev, cmd->dma)) {
-		err = -ENOMEM;
-		goto err_free;
-	}
 
 	cmd_l = ioread32be(&dev->iseg->cmdq_addr_l_sz) & 0xff;
 	cmd->log_sz = cmd_l >> 4 & 0xf;
@@ -1360,13 +1391,13 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 		dev_err(&dev->pdev->dev, "firmware reports too many outstanding commands %d\n",
 			1 << cmd->log_sz);
 		err = -EINVAL;
-		goto err_map;
+		goto err_free_page;
 	}
 
 	if (cmd->log_sz + cmd->log_stride > MLX5_ADAPTER_PAGE_SHIFT) {
 		dev_err(&dev->pdev->dev, "command queue size overflow\n");
 		err = -EINVAL;
-		goto err_map;
+		goto err_free_page;
 	}
 
 	cmd->checksum_disabled = 1;
@@ -1378,7 +1409,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 		dev_err(&dev->pdev->dev, "driver does not support command interface version. driver %d, firmware %d\n",
 			CMD_IF_REV, cmd->cmdif_rev);
 		err = -ENOTSUPP;
-		goto err_map;
+		goto err_free_page;
 	}
 
 	spin_lock_init(&cmd->alloc_lock);
@@ -1394,7 +1425,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	if (cmd_l & 0xfff) {
 		dev_err(&dev->pdev->dev, "invalid command queue address\n");
 		err = -ENOMEM;
-		goto err_map;
+		goto err_free_page;
 	}
 
 	iowrite32be(cmd_h, &dev->iseg->cmdq_addr_h);
@@ -1410,7 +1441,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	err = create_msg_cache(dev);
 	if (err) {
 		dev_err(&dev->pdev->dev, "failed to create command cache\n");
-		goto err_map;
+		goto err_free_page;
 	}
 
 	set_wqname(dev);
@@ -1435,11 +1466,8 @@ err_wq:
 err_cache:
 	destroy_msg_cache(dev);
 
-err_map:
-	dma_unmap_single(&dev->pdev->dev, cmd->dma, PAGE_SIZE,
-			 DMA_BIDIRECTIONAL);
-err_free:
-	free_pages((unsigned long)cmd->cmd_buf, 0);
+err_free_page:
+	free_cmd_page(dev, cmd);
 
 err_free_pool:
 	pci_pool_destroy(cmd->pool);
@@ -1455,9 +1483,7 @@ void mlx5_cmd_cleanup(struct mlx5_core_dev *dev)
 	clean_debug_files(dev);
 	destroy_workqueue(cmd->wq);
 	destroy_msg_cache(dev);
-	dma_unmap_single(&dev->pdev->dev, cmd->dma, PAGE_SIZE,
-			 DMA_BIDIRECTIONAL);
-	free_pages((unsigned long)cmd->cmd_buf, 0);
+	free_cmd_page(dev, cmd);
 	pci_pool_destroy(cmd->pool);
 }
 EXPORT_SYMBOL(mlx5_cmd_cleanup);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 166d9315fe4b..8d8ca6d9b03b 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -232,6 +232,9 @@ struct mlx5_cmd_stats {
 };
 
 struct mlx5_cmd {
+	void	       *cmd_alloc_buf;
+	dma_addr_t	alloc_dma;
+	int		alloc_size;
 	void	       *cmd_buf;
 	dma_addr_t	dma;
 	u16		cmdif_rev;
-- 
2.3.1
