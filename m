From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx4_core: Refactor mlx4_cmd_init and mlx4_cmd_cleanup
Date: Thu, 13 Nov 2014 14:45:29 +0200
Message-ID: <1415882733-3084-4-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46589 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932721AbaKMMpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:42 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Refactoring mlx4_cmd_init and mlx4_cmd_cleanup such that partial init
and cleanup are possible. After this refactoring, calling mlx4_cmd_init
several times is safe.

This is necessary in the VF init flow when mlx4_init_hca returns -EACCESS,
we need to issue cleanup and re-attempt to call it with the slave flag.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |   76 +++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |   11 ++++-
 3 files changed, 57 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 3c05e58..5c93d14 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2117,50 +2117,52 @@ err_vhcr:
 int mlx4_cmd_init(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	int flags = 0;
+
+	if (!priv->cmd.initialized) {
+		mutex_init(&priv->cmd.hcr_mutex);
+		mutex_init(&priv->cmd.slave_cmd_mutex);
+		sema_init(&priv->cmd.poll_sem, 1);
+		priv->cmd.use_events = 0;
+		priv->cmd.toggle     = 1;
+		priv->cmd.initialized = 1;
+		flags |= MLX4_CMD_CLEANUP_STRUCT;
+	}
 
-	mutex_init(&priv->cmd.hcr_mutex);
-	mutex_init(&priv->cmd.slave_cmd_mutex);
-	sema_init(&priv->cmd.poll_sem, 1);
-	priv->cmd.use_events = 0;
-	priv->cmd.toggle     = 1;
-
-	priv->cmd.hcr = NULL;
-	priv->mfunc.vhcr = NULL;
-
-	if (!mlx4_is_slave(dev)) {
+	if (!mlx4_is_slave(dev) && !priv->cmd.hcr) {
 		priv->cmd.hcr = ioremap(pci_resource_start(dev->pdev, 0) +
 					MLX4_HCR_BASE, MLX4_HCR_SIZE);
 		if (!priv->cmd.hcr) {
 			mlx4_err(dev, "Couldn't map command register\n");
-			return -ENOMEM;
+			goto err;
 		}
+		flags |= MLX4_CMD_CLEANUP_HCR;
 	}
 
-	if (mlx4_is_mfunc(dev)) {
+	if (mlx4_is_mfunc(dev) && !priv->mfunc.vhcr) {
 		priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
 						      &priv->mfunc.vhcr_dma,
 						      GFP_KERNEL);
 		if (!priv->mfunc.vhcr)
-			goto err_hcr;
+			goto err;
+
+		flags |= MLX4_CMD_CLEANUP_VHCR;
 	}
 
-	priv->cmd.pool = pci_pool_create("mlx4_cmd", dev->pdev,
-					 MLX4_MAILBOX_SIZE,
-					 MLX4_MAILBOX_SIZE, 0);
-	if (!priv->cmd.pool)
-		goto err_vhcr;
+	if (!priv->cmd.pool) {
+		priv->cmd.pool = pci_pool_create("mlx4_cmd", dev->pdev,
+						 MLX4_MAILBOX_SIZE,
+						 MLX4_MAILBOX_SIZE, 0);
+		if (!priv->cmd.pool)
+			goto err;
 
-	return 0;
+		flags |= MLX4_CMD_CLEANUP_POOL;
+	}
 
-err_vhcr:
-	if (mlx4_is_mfunc(dev))
-		dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
-				  priv->mfunc.vhcr, priv->mfunc.vhcr_dma);
-	priv->mfunc.vhcr = NULL;
+	return 0;
 
-err_hcr:
-	if (!mlx4_is_slave(dev))
-		iounmap(priv->cmd.hcr);
+err:
+	mlx4_cmd_cleanup(dev, flags);
 	return -ENOMEM;
 }
 
@@ -2184,18 +2186,28 @@ void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
 	iounmap(priv->mfunc.comm);
 }
 
-void mlx4_cmd_cleanup(struct mlx4_dev *dev)
+void mlx4_cmd_cleanup(struct mlx4_dev *dev, int cleanup_mask)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
-	pci_pool_destroy(priv->cmd.pool);
+	if (priv->cmd.pool && (cleanup_mask & MLX4_CMD_CLEANUP_POOL)) {
+		pci_pool_destroy(priv->cmd.pool);
+		priv->cmd.pool = NULL;
+	}
 
-	if (!mlx4_is_slave(dev))
+	if (!mlx4_is_slave(dev) && priv->cmd.hcr &&
+	    (cleanup_mask & MLX4_CMD_CLEANUP_HCR)) {
 		iounmap(priv->cmd.hcr);
-	if (mlx4_is_mfunc(dev))
+		priv->cmd.hcr = NULL;
+	}
+	if (mlx4_is_mfunc(dev) && priv->mfunc.vhcr &&
+	    (cleanup_mask & MLX4_CMD_CLEANUP_VHCR)) {
 		dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
 				  priv->mfunc.vhcr, priv->mfunc.vhcr_dma);
-	priv->mfunc.vhcr = NULL;
+		priv->mfunc.vhcr = NULL;
+	}
+	if (priv->cmd.initialized && (cleanup_mask & MLX4_CMD_CLEANUP_STRUCT))
+		priv->cmd.initialized = 0;
 }
 
 /*
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 71f1f3b..b2732eb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2396,7 +2396,7 @@ slave_start:
 		if (err == -EACCES) {
 			/* Not primary Physical function
 			 * Running in slave mode */
-			mlx4_cmd_cleanup(dev);
+			mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 			dev->flags |= MLX4_FLAG_SLAVE;
 			dev->flags &= ~MLX4_FLAG_MASTER;
 			goto slave_start;
@@ -2561,7 +2561,7 @@ err_mfunc:
 		mlx4_multi_func_cleanup(dev);
 
 err_cmd:
-	mlx4_cmd_cleanup(dev);
+	mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 
 err_sriov:
 	if (dev->flags & MLX4_FLAG_SRIOV && !existing_vfs)
@@ -2805,7 +2805,7 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	mlx4_close_hca(dev);
 	if (mlx4_is_slave(dev))
 		mlx4_multi_func_cleanup(dev);
-	mlx4_cmd_cleanup(dev);
+	mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 
 	if (dev->flags & MLX4_FLAG_MSI_X)
 		pci_disable_msix(pdev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index f8fc7bd..f48e7c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -606,6 +606,7 @@ struct mlx4_cmd {
 	u8			use_events;
 	u8			toggle;
 	u8			comm_toggle;
+	u8			initialized;
 };
 
 enum {
@@ -1126,8 +1127,16 @@ int mlx4_QUERY_QP_wrapper(struct mlx4_dev *dev, int slave,
 
 int mlx4_GEN_EQE(struct mlx4_dev *dev, int slave, struct mlx4_eqe *eqe);
 
+enum {
+	MLX4_CMD_CLEANUP_STRUCT = 1UL << 0,
+	MLX4_CMD_CLEANUP_POOL	= 1UL << 1,
+	MLX4_CMD_CLEANUP_HCR	= 1UL << 2,
+	MLX4_CMD_CLEANUP_VHCR	= 1UL << 3,
+	MLX4_CMD_CLEANUP_ALL	= (MLX4_CMD_CLEANUP_VHCR << 1) - 1
+};
+
 int mlx4_cmd_init(struct mlx4_dev *dev);
-void mlx4_cmd_cleanup(struct mlx4_dev *dev);
+void mlx4_cmd_cleanup(struct mlx4_dev *dev, int cleanup_mask);
 int mlx4_multi_func_init(struct mlx4_dev *dev);
 void mlx4_multi_func_cleanup(struct mlx4_dev *dev);
 void mlx4_cmd_event(struct mlx4_dev *dev, u16 token, u8 status, u64 out_param);
-- 
1.7.1
