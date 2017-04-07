From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v7 06/15] mlx5: Replace PCI pool old API
Date: Fri,  7 Apr 2017 09:25:34 +0200
Message-ID: <20170407072543.6936-7-romain.perier@collabora.com>
References: <20170407072543.6936-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407072543.6936-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Tested-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++++-----
 include/linux/mlx5/driver.h                   |  2 +-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 5bdaf3d..aae7d92 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1069,7 +1069,7 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
-	mailbox->buf = pci_pool_zalloc(dev->cmd.pool, flags,
+	mailbox->buf = dma_pool_zalloc(dev->cmd.pool, flags,
 				       &mailbox->dma);
 	if (!mailbox->buf) {
 		mlx5_core_dbg(dev, "failed allocation\n");
@@ -1084,7 +1084,7 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
 static void free_cmd_box(struct mlx5_core_dev *dev,
 			 struct mlx5_cmd_mailbox *mailbox)
 {
-	pci_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
+	dma_pool_free(dev->cmd.pool, mailbox->buf, mailbox->dma);
 	kfree(mailbox);
 }
 
@@ -1704,7 +1704,8 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 		return -EINVAL;
 	}
 
-	cmd->pool = pci_pool_create("mlx5_cmd", dev->pdev, size, align, 0);
+	cmd->pool = dma_pool_create("mlx5_cmd", &dev->pdev->dev, size, align,
+				    0);
 	if (!cmd->pool)
 		return -ENOMEM;
 
@@ -1794,7 +1795,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	free_cmd_page(dev, cmd);
 
 err_free_pool:
-	pci_pool_destroy(cmd->pool);
+	dma_pool_destroy(cmd->pool);
 
 	return err;
 }
@@ -1808,6 +1809,6 @@ void mlx5_cmd_cleanup(struct mlx5_core_dev *dev)
 	destroy_workqueue(cmd->wq);
 	destroy_msg_cache(dev);
 	free_cmd_page(dev, cmd);
-	pci_pool_destroy(cmd->pool);
+	dma_pool_destroy(cmd->pool);
 }
 EXPORT_SYMBOL(mlx5_cmd_cleanup);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 6cd000f..7ea19ae 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -284,7 +284,7 @@ struct mlx5_cmd {
 	struct semaphore pages_sem;
 	int	mode;
 	struct mlx5_cmd_work_ent *ent_arr[MLX5_MAX_COMMANDS];
-	struct pci_pool *pool;
+	struct dma_pool *pool;
 	struct mlx5_cmd_debug dbg;
 	struct cmd_msg_cache cache[MLX5_NUM_COMMAND_CACHES];
 	int checksum_disabled;
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
