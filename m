From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/16] net/mlx5: FPGA, Move FPGA init/cleanup to init_once
Date: Tue, 27 Jun 2017 17:28:47 +0300
Message-ID: <20170627142856.9448-8-saeedm@mellanox.com>
References: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50414 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753140AbdF0OaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:12 -0400
In-Reply-To: <20170627142856.9448-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

The FPGA init and cleanup routines should be called just once per
device.
Move them to the init_once and cleanup_once routines.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.h |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/main.c      | 21 ++++++++++-----------
 3 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
index 92d8b1b6e598..c3bb4b865f01 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c
@@ -135,7 +135,7 @@ int mlx5_fpga_device_start(struct mlx5_core_dev *mdev)
 	return err;
 }
 
-int mlx5_fpga_device_init(struct mlx5_core_dev *mdev)
+int mlx5_fpga_init(struct mlx5_core_dev *mdev)
 {
 	struct mlx5_fpga_device *fdev = NULL;
 
@@ -177,7 +177,7 @@ void mlx5_fpga_device_stop(struct mlx5_core_dev *mdev)
 	mlx5_core_unreserve_gids(mdev, max_num_qps);
 }
 
-void mlx5_fpga_device_cleanup(struct mlx5_core_dev *mdev)
+void mlx5_fpga_cleanup(struct mlx5_core_dev *mdev)
 {
 	struct mlx5_fpga_device *fdev = mdev->fpga;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.h b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.h
index 557d83973ade..db1d22c356e0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/core.h
@@ -68,20 +68,20 @@ struct mlx5_fpga_device {
 #define mlx5_fpga_info(__adev, format, ...) \
 	dev_info(&(__adev)->mdev->pdev->dev, "FPGA: " format, ##__VA_ARGS__)
 
-int mlx5_fpga_device_init(struct mlx5_core_dev *mdev);
-void mlx5_fpga_device_cleanup(struct mlx5_core_dev *mdev);
+int mlx5_fpga_init(struct mlx5_core_dev *mdev);
+void mlx5_fpga_cleanup(struct mlx5_core_dev *mdev);
 int mlx5_fpga_device_start(struct mlx5_core_dev *mdev);
 void mlx5_fpga_device_stop(struct mlx5_core_dev *mdev);
 void mlx5_fpga_event(struct mlx5_core_dev *mdev, u8 event, void *data);
 
 #else
 
-static inline int mlx5_fpga_device_init(struct mlx5_core_dev *mdev)
+static inline int mlx5_fpga_init(struct mlx5_core_dev *mdev)
 {
 	return 0;
 }
 
-static inline void mlx5_fpga_device_cleanup(struct mlx5_core_dev *mdev)
+static inline void mlx5_fpga_cleanup(struct mlx5_core_dev *mdev)
 {
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 55f9fccfc394..684612778677 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -959,8 +959,16 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto err_eswitch_cleanup;
 	}
 
+	err = mlx5_fpga_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init fpga device %d\n", err);
+		goto err_sriov_cleanup;
+	}
+
 	return 0;
 
+err_sriov_cleanup:
+	mlx5_sriov_cleanup(dev);
 err_eswitch_cleanup:
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
@@ -984,6 +992,7 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 
 static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
 {
+	mlx5_fpga_cleanup(dev);
 	mlx5_sriov_cleanup(dev);
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
@@ -1121,16 +1130,10 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto err_disable_msix;
 	}
 
-	err = mlx5_fpga_device_init(dev);
-	if (err) {
-		dev_err(&pdev->dev, "fpga device init failed %d\n", err);
-		goto err_put_uars;
-	}
-
 	err = mlx5_start_eqs(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to start pages and async EQs\n");
-		goto err_fpga_init;
+		goto err_put_uars;
 	}
 
 	err = alloc_comp_eqs(dev);
@@ -1205,9 +1208,6 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 err_stop_eqs:
 	mlx5_stop_eqs(dev);
 
-err_fpga_init:
-	mlx5_fpga_device_cleanup(dev);
-
 err_put_uars:
 	mlx5_put_uars_page(dev, priv->uar);
 
@@ -1277,7 +1277,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_irq_clear_affinity_hints(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
-	mlx5_fpga_device_cleanup(dev);
 	mlx5_put_uars_page(dev, priv->uar);
 	mlx5_disable_msix(dev);
 	if (cleanup)
-- 
2.11.0
