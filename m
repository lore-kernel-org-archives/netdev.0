From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v7 05/15] mlx4: Replace PCI pool old API
Date: Fri,  7 Apr 2017 09:25:33 +0200
Message-ID: <20170407072543.6936-6-romain.perier@collabora.com>
References: <20170407072543.6936-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:55813 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754152AbdDGH0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:26:20 -0400
In-Reply-To: <20170407072543.6936-1-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
Acked-by: Doug Ledford <dledford@redhat.com>
Tested-by: Doug Ledford <dledford@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0e0fa70..2d6ef79 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2527,8 +2527,8 @@ int mlx4_cmd_init(struct mlx4_dev *dev)
 	}
 
 	if (!priv->cmd.pool) {
-		priv->cmd.pool = pci_pool_create("mlx4_cmd",
-						 dev->persist->pdev,
+		priv->cmd.pool = dma_pool_create("mlx4_cmd",
+						 &dev->persist->pdev->dev,
 						 MLX4_MAILBOX_SIZE,
 						 MLX4_MAILBOX_SIZE, 0);
 		if (!priv->cmd.pool)
@@ -2599,7 +2599,7 @@ void mlx4_cmd_cleanup(struct mlx4_dev *dev, int cleanup_mask)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	if (priv->cmd.pool && (cleanup_mask & MLX4_CMD_CLEANUP_POOL)) {
-		pci_pool_destroy(priv->cmd.pool);
+		dma_pool_destroy(priv->cmd.pool);
 		priv->cmd.pool = NULL;
 	}
 
@@ -2691,7 +2691,7 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
-	mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
+	mailbox->buf = dma_pool_zalloc(mlx4_priv(dev)->cmd.pool, GFP_KERNEL,
 				       &mailbox->dma);
 	if (!mailbox->buf) {
 		kfree(mailbox);
@@ -2708,7 +2708,7 @@ void mlx4_free_cmd_mailbox(struct mlx4_dev *dev,
 	if (!mailbox)
 		return;
 
-	pci_pool_free(mlx4_priv(dev)->cmd.pool, mailbox->buf, mailbox->dma);
+	dma_pool_free(mlx4_priv(dev)->cmd.pool, mailbox->buf, mailbox->dma);
 	kfree(mailbox);
 }
 EXPORT_SYMBOL_GPL(mlx4_free_cmd_mailbox);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index b4f1bc5..69c8764 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -628,7 +628,7 @@ struct mlx4_mgm {
 };
 
 struct mlx4_cmd {
-	struct pci_pool	       *pool;
+	struct dma_pool	       *pool;
 	void __iomem	       *hcr;
 	struct mutex		slave_cmd_mutex;
 	struct semaphore	poll_sem;
-- 
2.9.3
