From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx4_core: Refactor mlx4_load_one
Date: Thu, 13 Nov 2014 14:45:30 +0200
Message-ID: <1415882733-3084-5-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39848 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932622AbaKMMpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:42 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Refactor mlx4_load_one, as a preparation step for a new and
more complicated load function. The goal is to support both
newer firmware that required init_hca to be done before
enable_sriov and legacy firmwares that requires things to
be done the other way around.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |  141 ++++++++++++++++++++---------
 1 files changed, 99 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index b2732eb..43047b2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1473,6 +1473,12 @@ static void mlx4_close_hca(struct mlx4_dev *dev)
 	else {
 		mlx4_CLOSE_HCA(dev, 0);
 		mlx4_free_icms(dev);
+	}
+}
+
+static void mlx4_close_fw(struct mlx4_dev *dev)
+{
+	if (!mlx4_is_slave(dev)) {
 		mlx4_UNMAP_FA(dev);
 		mlx4_free_icm(dev, mlx4_priv(dev)->fw.fw_icm, 0);
 	}
@@ -1619,17 +1625,10 @@ static void choose_tunnel_offload_mode(struct mlx4_dev *dev,
 		 == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) ? "vxlan" : "none");
 }
 
-static int mlx4_init_hca(struct mlx4_dev *dev)
+static int mlx4_init_fw(struct mlx4_dev *dev)
 {
-	struct mlx4_priv	  *priv = mlx4_priv(dev);
-	struct mlx4_adapter	   adapter;
-	struct mlx4_dev_cap	   dev_cap;
 	struct mlx4_mod_stat_cfg   mlx4_cfg;
-	struct mlx4_profile	   profile;
-	struct mlx4_init_hca_param init_hca;
-	u64 icm_size;
-	int err;
-	struct mlx4_config_dev_params params;
+	int err = 0;
 
 	if (!mlx4_is_slave(dev)) {
 		err = mlx4_QUERY_FW(dev);
@@ -1652,7 +1651,23 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		err = mlx4_MOD_STAT_CFG(dev, &mlx4_cfg);
 		if (err)
 			mlx4_warn(dev, "Failed to override log_pg_sz parameter\n");
+	}
+
+	return err;
+}
+
+static int mlx4_init_hca(struct mlx4_dev *dev)
+{
+	struct mlx4_priv	  *priv = mlx4_priv(dev);
+	struct mlx4_adapter	   adapter;
+	struct mlx4_dev_cap	   dev_cap;
+	struct mlx4_profile	   profile;
+	struct mlx4_init_hca_param init_hca;
+	u64 icm_size;
+	struct mlx4_config_dev_params params;
+	int err;
 
+	if (!mlx4_is_slave(dev)) {
 		err = mlx4_dev_cap(dev, &dev_cap);
 		if (err) {
 			mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting\n");
@@ -2275,6 +2290,53 @@ static void mlx4_free_ownership(struct mlx4_dev *dev)
 	iounmap(owner);
 }
 
+#define SRIOV_VALID_STATE(flags) (!!((flags) & MLX4_FLAG_SRIOV)	==\
+				  !!((flags) & MLX4_FLAG_MASTER))
+
+static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
+			     u8 total_vfs, int existing_vfs)
+{
+	u64 dev_flags = dev->flags;
+
+	dev->dev_vfs = kzalloc(
+			total_vfs * sizeof(*dev->dev_vfs),
+			GFP_KERNEL);
+	if (NULL == dev->dev_vfs) {
+		mlx4_err(dev, "Failed to allocate memory for VFs\n");
+		goto disable_sriov;
+	} else if (!(dev->flags &  MLX4_FLAG_SRIOV)) {
+		int err = 0;
+
+		atomic_inc(&pf_loading);
+		if (existing_vfs) {
+			if (existing_vfs != total_vfs)
+				mlx4_err(dev, "SR-IOV was already enabled, but with num_vfs (%d) different than requested (%d)\n",
+					 existing_vfs, total_vfs);
+		} else {
+			mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", total_vfs);
+			err = pci_enable_sriov(pdev, total_vfs);
+		}
+		if (err) {
+			mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
+				 err);
+			atomic_dec(&pf_loading);
+			goto disable_sriov;
+		} else {
+			mlx4_warn(dev, "Running in master mode\n");
+			dev_flags |= MLX4_FLAG_SRIOV |
+				MLX4_FLAG_MASTER;
+			dev_flags &= ~MLX4_FLAG_SLAVE;
+			dev->num_vfs = total_vfs;
+		}
+	}
+	return dev_flags;
+
+disable_sriov:
+	dev->num_vfs = 0;
+	kfree(dev->dev_vfs);
+	return dev_flags & ~MLX4_FLAG_MASTER;
+}
+
 static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 			 int total_vfs, int *nvfs, struct mlx4_priv *priv)
 {
@@ -2320,37 +2382,12 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 		}
 
 		if (total_vfs) {
-			mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n",
-				  total_vfs);
-			dev->dev_vfs = kzalloc(
-				total_vfs * sizeof(*dev->dev_vfs),
-				GFP_KERNEL);
-			if (NULL == dev->dev_vfs) {
-				mlx4_err(dev, "Failed to allocate memory for VFs\n");
-				err = -ENOMEM;
-				goto err_free_own;
-			} else {
-				atomic_inc(&pf_loading);
-				existing_vfs = pci_num_vf(pdev);
-				if (existing_vfs) {
-					err = 0;
-					if (existing_vfs != total_vfs)
-						mlx4_err(dev, "SR-IOV was already enabled, but with num_vfs (%d) different than requested (%d)\n",
-							 existing_vfs, total_vfs);
-				} else {
-					err = pci_enable_sriov(pdev, total_vfs);
-				}
-				if (err) {
-					mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
-						 err);
-					atomic_dec(&pf_loading);
-				} else {
-					mlx4_warn(dev, "Running in master mode\n");
-					dev->flags |= MLX4_FLAG_SRIOV |
-						MLX4_FLAG_MASTER;
-					dev->num_vfs = total_vfs;
-				}
-			}
+			existing_vfs = pci_num_vf(pdev);
+			dev->flags = MLX4_FLAG_MASTER;
+			dev->flags = mlx4_enable_sriov(dev, pdev, total_vfs,
+						       existing_vfs);
+			if (!SRIOV_VALID_STATE(dev->flags))
+				goto err_sriov;
 		}
 
 		atomic_set(&priv->opreq_count, 0);
@@ -2391,17 +2428,33 @@ slave_start:
 		}
 	}
 
+	err = mlx4_init_fw(dev);
+	if (err) {
+		mlx4_err(dev, "Failed to init fw, aborting.\n");
+		goto err_mfunc;
+	}
+
 	err = mlx4_init_hca(dev);
 	if (err) {
 		if (err == -EACCES) {
 			/* Not primary Physical function
 			 * Running in slave mode */
 			mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
+			/* We're not a PF */
+			if (dev->flags & MLX4_FLAG_SRIOV) {
+				if (!existing_vfs)
+					pci_disable_sriov(pdev);
+				if (mlx4_is_master(dev))
+					atomic_dec(&pf_loading);
+				dev->flags &= ~MLX4_FLAG_SRIOV;
+			}
+			if (!mlx4_is_slave(dev))
+				mlx4_free_ownership(dev);
 			dev->flags |= MLX4_FLAG_SLAVE;
 			dev->flags &= ~MLX4_FLAG_MASTER;
 			goto slave_start;
 		} else
-			goto err_mfunc;
+			goto err_fw;
 	}
 
 	/* check if the device is functioning at its maximum possible speed.
@@ -2556,6 +2609,9 @@ err_master_mfunc:
 err_close:
 	mlx4_close_hca(dev);
 
+err_fw:
+	mlx4_close_fw(dev);
+
 err_mfunc:
 	if (mlx4_is_slave(dev))
 		mlx4_multi_func_cleanup(dev);
@@ -2572,7 +2628,6 @@ err_sriov:
 
 	kfree(priv->dev.dev_vfs);
 
-err_free_own:
 	if (!mlx4_is_slave(dev))
 		mlx4_free_ownership(dev);
 
@@ -2803,6 +2858,7 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	if (mlx4_is_master(dev))
 		mlx4_multi_func_cleanup(dev);
 	mlx4_close_hca(dev);
+	mlx4_close_fw(dev);
 	if (mlx4_is_slave(dev))
 		mlx4_multi_func_cleanup(dev);
 	mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
@@ -2812,6 +2868,7 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	if (dev->flags & MLX4_FLAG_SRIOV && !active_vfs) {
 		mlx4_warn(dev, "Disabling SR-IOV\n");
 		pci_disable_sriov(pdev);
+		dev->flags &= ~MLX4_FLAG_SRIOV;
 		dev->num_vfs = 0;
 	}
 
-- 
1.7.1
