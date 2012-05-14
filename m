From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx4_core: Fix potential kernel Oops in res tracker during Dom0 driver unload
Date: Mon, 14 May 2012 23:04:11 +0300
Message-ID: <1337025853-26685-7-git-send-email-ogerlitz@mellanox.com>
References: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:55319 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757738Ab2ENUEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:04:25 -0400
In-Reply-To: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Currently the slave and master resources are deleted after master freed
all bitmaps. If any resources were not properly cleaned up during the
shutdown process, an Oops would result.

Fix so that delete slave (only) resources during cleanup. Master resources
are cleaned up during unload process, and need not separately be cleaned.

Note that during cleanup, we need to split the resource-tracker freeing
functionality.

Before removing all the bitmaps, we free any leftover slave resources.
However, we can only remove the resource tracker linked list after
all bitmap frees, since some of the freeing functions (e.g.,
mlx4_cleanup_eq_table) use paravirtualized FW commands which expect
the resource tracker linked list to be present.

Found-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |    7 ++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    8 +++++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   17 ++++++++++++-----
 4 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 53b738b..1bcead1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1554,7 +1554,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 	return 0;
 
 err_resource:
-	mlx4_free_resource_tracker(dev);
+	mlx4_free_resource_tracker(dev, RES_TR_FREE_ALL);
 err_thread:
 	flush_workqueue(priv->mfunc.master.comm_wq);
 	destroy_workqueue(priv->mfunc.master.comm_wq);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8eed1f2..2e94f76 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2069,6 +2069,10 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 			mlx4_CLOSE_PORT(dev, p);
 		}
 
+		if (mlx4_is_master(dev))
+			mlx4_free_resource_tracker(dev,
+						   RES_TR_FREE_SLAVES_ONLY);
+
 		mlx4_cleanup_counters_table(dev);
 		mlx4_cleanup_mcg_table(dev);
 		mlx4_cleanup_qp_table(dev);
@@ -2081,7 +2085,8 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 		mlx4_cleanup_pd_table(dev);
 
 		if (mlx4_is_master(dev))
-			mlx4_free_resource_tracker(dev);
+			mlx4_free_resource_tracker(dev,
+						   RES_TR_FREE_STRUCTS_ONLY);
 
 		iounmap(priv->kar);
 		mlx4_uar_free(dev, &priv->driver_uar);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index cd56f1a..8767fbf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -146,6 +146,11 @@ enum mlx4_alloc_mode {
 	RES_OP_MAP_ICM,
 };
 
+enum mlx4_res_tracker_free_type {
+	RES_TR_FREE_ALL,
+	RES_TR_FREE_SLAVES_ONLY,
+	RES_TR_FREE_STRUCTS_ONLY,
+};
 
 /*
  *Virtual HCR structures.
@@ -1027,7 +1032,8 @@ int mlx4_get_slave_from_resource_id(struct mlx4_dev *dev,
 void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave_id);
 int mlx4_init_resource_tracker(struct mlx4_dev *dev);
 
-void mlx4_free_resource_tracker(struct mlx4_dev *dev);
+void mlx4_free_resource_tracker(struct mlx4_dev *dev,
+				enum mlx4_res_tracker_free_type type);
 
 int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_vhcr *vhcr,
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 66df9e1..e17d759 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -224,16 +224,23 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 	return 0 ;
 }
 
-void mlx4_free_resource_tracker(struct mlx4_dev *dev)
+void mlx4_free_resource_tracker(struct mlx4_dev *dev,
+				enum mlx4_res_tracker_free_type type)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int i;
 
 	if (priv->mfunc.master.res_tracker.slave_list) {
-		for (i = 0 ; i < dev->num_slaves; i++)
-			mlx4_delete_all_resources_for_slave(dev, i);
-
-		kfree(priv->mfunc.master.res_tracker.slave_list);
+		if (type != RES_TR_FREE_STRUCTS_ONLY)
+			for (i = 0 ; i < dev->num_slaves; i++)
+				if (type == RES_TR_FREE_ALL ||
+				    dev->caps.function != i)
+					mlx4_delete_all_resources_for_slave(dev, i);
+
+		if (type != RES_TR_FREE_SLAVES_ONLY) {
+			kfree(priv->mfunc.master.res_tracker.slave_list);
+			priv->mfunc.master.res_tracker.slave_list = NULL;
+		}
 	}
 }
 
-- 
1.7.1
