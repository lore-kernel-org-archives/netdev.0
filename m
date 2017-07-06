From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v10 06/15] mlx5: Replace PCI pool old API
Date: Thu,  6 Jul 2017 10:13:01 +0200
Message-ID: <20170706081310.30964-7-romain.perier@collabora.com>
References: <20170706081310.30964-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170706081310.30964-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
Acked-by: Doug Ledford <dledford@redhat.com>
Tested-by: Doug Ledford <dledford@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
 include/linux/mlx5/driver.h                   |  2 +-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index f5a2c605749f..7a40e8790f75 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1095,7 +1095,7 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
-	mailbox->buf = pci_pool_zalloc(dev->cmd.pool, flags,
+	mailbox->buf = dma_pool_zalloc(dev->cmd.pool, flags,
 				       &mailbox->dma);
 	if (!mailbox->buf) {
 		mlx5_core_dbg(dev, "failed allocation\n");
@@ -1110,7 +1110,7 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
 static void free_cmd_box(struct mlx5_core_dev *dev,
 			 struct mlx5_cmd_mailbox *mailbox)
 {
-	pci_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
+	dma_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
 	kfree(mailbox);
 }
 
@@ -1759,7 +1759,8 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 		return -EINVAL;
 	}
 
-	cmd->pool = pci_pool_create("mlx5_cmd", dev->pdev, size, align, 0);
+	cmd->pool = dma_pool_create("mlx5_cmd", &dev->pdev->dev, size, align,
+				    0);
 	if (!cmd->pool)
 		return -ENOMEM;
 
@@ -1849,7 +1850,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	free_cmd_page(dev, cmd);
 
 err_free_pool:
-	pci_pool_destroy(cmd->pool);
+	dma_pool_destroy(cmd->pool);
 
 	return err;
 }
@@ -1863,6 +1864,6 @@ void mlx5_cmd_cleanup(struct mlx5_core_dev *dev)
 	destroy_workqueue(cmd->wq);
 	destroy_msg_cache(dev);
 	free_cmd_page(dev, cmd);
-	pci_pool_destroy(cmd->pool);
+	dma_pool_destroy(cmd->pool);
 }
 EXPORT_SYMBOL(mlx5_cmd_cleanup);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index df6ce59a1f95..a7174ca26ca8 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -291,7 +291,7 @@ struct mlx5_cmd {
 	struct semaphore pages_sem;
 	int	mode;
 	struct mlx5_cmd_work_ent *ent_arr[MLX5_MAX_COMMANDS];
-	struct pci_pool *pool;
+	struct dma_pool *pool;
 	struct mlx5_cmd_debug dbg;
 	struct cmd_msg_cache cache[MLX5_NUM_COMMAND_CACHES];
 	int checksum_disabled;
-- 
2.11.0
