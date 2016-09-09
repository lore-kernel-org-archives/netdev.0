From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 02/11] net/mlx5: SRIOV core code refactoring
Date: Fri,  9 Sep 2016 17:35:18 +0300
Message-ID: <1473431727-20150-3-git-send-email-saeedm@mellanox.com>
References: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35498 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752834AbcIIOhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:37:00 -0400
In-Reply-To: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Simplify the code and makes it look modular and symmetric.
Split sriov enable/disable to two levels: device level and pci level.
When user enable/disable sriov (via sriov_configure driver callback) we
will enable/disable both device and pci sriov.
When driver load/unload we will enable/disable (on demand) only device
sriov while keeping the PCI sriov enabled for next driver load.
On internal/pci error, VFs will be kept enabled on PCI and the reset
is done only in device level.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  12 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    | 216 +++++++++------------
 include/linux/mlx5/driver.h                        |   2 -
 4 files changed, 101 insertions(+), 131 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c132ef1..baba53f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1180,8 +1180,7 @@ out:
 	return 0;
 
 err_sriov:
-	if (mlx5_sriov_cleanup(dev))
-		dev_err(&dev->pdev->dev, "sriov cleanup failed\n");
+	mlx5_sriov_cleanup(dev);
 
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
@@ -1241,19 +1240,14 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 {
 	int err = 0;
 
-	err = mlx5_sriov_cleanup(dev);
-	if (err) {
-		dev_warn(&dev->pdev->dev, "%s: sriov cleanup failed - abort\n",
-			 __func__);
-		return err;
-	}
-
 	mutex_lock(&dev->intf_state_mutex);
 	if (test_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state)) {
 		dev_warn(&dev->pdev->dev, "%s: interface is down, NOP\n",
 			 __func__);
 		goto out;
 	}
+
+	mlx5_sriov_cleanup(dev);
 	mlx5_unregister_device(dev);
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 714b71b..7dd14cf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -89,6 +89,8 @@ void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param);
 void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
+int mlx5_sriov_init(struct mlx5_core_dev *dev);
+void mlx5_sriov_cleanup(struct mlx5_core_dev *dev);
 int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
 bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev);
 int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index 78e7892..72a8215 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -44,108 +44,132 @@ bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev)
 	return !!sriov->num_vfs;
 }
 
-static void enable_vfs(struct mlx5_core_dev *dev, int num_vfs)
+static int mlx5_device_enable_sriov(struct mlx5_core_dev *dev, int num_vfs)
 {
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
 	int err;
 	int vf;
 
-	for (vf = 1; vf <= num_vfs; vf++) {
-		err = mlx5_core_enable_hca(dev, vf);
+	if (sriov->enabled_vfs) {
+		mlx5_core_warn(dev,
+			       "failed to enable SRIOV on device, already enabled with %d vfs\n",
+			       sriov->enabled_vfs);
+		return -EBUSY;
+	}
+
+#ifdef CONFIG_MLX5_CORE_EN
+	err = mlx5_eswitch_enable_sriov(dev->priv.eswitch, num_vfs, SRIOV_LEGACY);
+	if (err) {
+		mlx5_core_warn(dev,
+			       "failed to enable eswitch SRIOV (%d)\n", err);
+		return err;
+	}
+#endif
+
+	for (vf = 0; vf < num_vfs; vf++) {
+		err = mlx5_core_enable_hca(dev, vf + 1);
 		if (err) {
-			mlx5_core_warn(dev, "failed to enable VF %d\n", vf - 1);
-		} else {
-			sriov->vfs_ctx[vf - 1].enabled = 1;
-			mlx5_core_dbg(dev, "successfully enabled VF %d\n", vf - 1);
+			mlx5_core_warn(dev, "failed to enable VF %d (%d)\n", vf, err);
+			continue;
 		}
+		sriov->vfs_ctx[vf].enabled = 1;
+		sriov->enabled_vfs++;
+		mlx5_core_dbg(dev, "successfully enabled VF* %d\n", vf);
+
 	}
+
+	return 0;
 }
 
-static void disable_vfs(struct mlx5_core_dev *dev, int num_vfs)
+static void mlx5_device_disable_sriov(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
+	int err;
 	int vf;
 
-	for (vf = 1; vf <= num_vfs; vf++) {
-		if (sriov->vfs_ctx[vf - 1].enabled) {
-			if (mlx5_core_disable_hca(dev, vf))
-				mlx5_core_warn(dev, "failed to disable VF %d\n", vf - 1);
-			else
-				sriov->vfs_ctx[vf - 1].enabled = 0;
+	if (!sriov->enabled_vfs)
+		return;
+
+	for (vf = 0; vf < sriov->num_vfs; vf++) {
+		if (!sriov->vfs_ctx[vf].enabled)
+			continue;
+		err = mlx5_core_disable_hca(dev, vf + 1);
+		if (err) {
+			mlx5_core_warn(dev, "failed to disable VF %d\n", vf);
+			continue;
 		}
+		sriov->vfs_ctx[vf].enabled = 0;
+		sriov->enabled_vfs--;
 	}
+
+#ifdef CONFIG_MLX5_CORE_EN
+	mlx5_eswitch_disable_sriov(dev->priv.eswitch);
+#endif
+
+	if (mlx5_wait_for_vf_pages(dev))
+		mlx5_core_warn(dev, "timeout reclaiming VFs pages\n");
 }
 
-static int mlx5_core_create_vfs(struct pci_dev *pdev, int num_vfs)
+static int mlx5_pci_enable_sriov(struct pci_dev *pdev, int num_vfs)
 {
 	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
-	int err;
-
-	if (pci_num_vf(pdev))
-		pci_disable_sriov(pdev);
-
-	enable_vfs(dev, num_vfs);
+	int err = 0;
 
-	err = pci_enable_sriov(pdev, num_vfs);
-	if (err) {
-		dev_warn(&pdev->dev, "enable sriov failed %d\n", err);
-		goto ex;
+	if (pci_num_vf(pdev)) {
+		mlx5_core_warn(dev, "Unable to enable pci sriov, already enabled\n");
+		return -EBUSY;
 	}
 
-	return 0;
+	err = pci_enable_sriov(pdev, num_vfs);
+	if (err)
+		mlx5_core_warn(dev, "pci_enable_sriov failed : %d\n", err);
 
-ex:
-	disable_vfs(dev, num_vfs);
 	return err;
 }
 
-static int mlx5_core_sriov_enable(struct pci_dev *pdev, int num_vfs)
+static void mlx5_pci_disable_sriov(struct pci_dev *pdev)
+{
+	pci_disable_sriov(pdev);
+}
+
+static int mlx5_sriov_enable(struct pci_dev *pdev, int num_vfs)
 {
 	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
-	int err;
+	int err = 0;
 
-	kfree(sriov->vfs_ctx);
-	sriov->vfs_ctx = kcalloc(num_vfs, sizeof(*sriov->vfs_ctx), GFP_ATOMIC);
-	if (!sriov->vfs_ctx)
-		return -ENOMEM;
+	err = mlx5_device_enable_sriov(dev, num_vfs);
+	if (err) {
+		mlx5_core_warn(dev, "mlx5_device_enable_sriov failed : %d\n", err);
+		return err;
+	}
 
-	sriov->enabled_vfs = num_vfs;
-	err = mlx5_core_create_vfs(pdev, num_vfs);
+	err = mlx5_pci_enable_sriov(pdev, num_vfs);
 	if (err) {
-		kfree(sriov->vfs_ctx);
-		sriov->vfs_ctx = NULL;
+		mlx5_core_warn(dev, "mlx5_pci_enable_sriov failed : %d\n", err);
+		mlx5_device_disable_sriov(dev);
 		return err;
 	}
 
+	sriov->num_vfs = num_vfs;
+
 	return 0;
 }
 
-static void mlx5_core_init_vfs(struct mlx5_core_dev *dev, int num_vfs)
+static void mlx5_sriov_disable(struct pci_dev *pdev)
 {
+	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
 
-	sriov->num_vfs = num_vfs;
-}
-
-static void mlx5_core_cleanup_vfs(struct mlx5_core_dev *dev)
-{
-	struct mlx5_core_sriov *sriov;
-
-	sriov = &dev->priv.sriov;
-	disable_vfs(dev, sriov->num_vfs);
-
-	if (mlx5_wait_for_vf_pages(dev))
-		mlx5_core_warn(dev, "timeout claiming VFs pages\n");
-
+	mlx5_pci_disable_sriov(pdev);
+	mlx5_device_disable_sriov(dev);
 	sriov->num_vfs = 0;
 }
 
 int mlx5_core_sriov_configure(struct pci_dev *pdev, int num_vfs)
 {
 	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
-	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
-	int err;
+	int err = 0;
 
 	mlx5_core_dbg(dev, "requested num_vfs %d\n", num_vfs);
 	if (!mlx5_core_is_pf(dev))
@@ -156,92 +180,44 @@ int mlx5_core_sriov_configure(struct pci_dev *pdev, int num_vfs)
 		return -EINVAL;
 	}
 
-	mlx5_core_cleanup_vfs(dev);
-
-	if (!num_vfs) {
-#ifdef CONFIG_MLX5_CORE_EN
-		mlx5_eswitch_disable_sriov(dev->priv.eswitch);
-#endif
-		kfree(sriov->vfs_ctx);
-		sriov->vfs_ctx = NULL;
-		if (!pci_vfs_assigned(pdev))
-			pci_disable_sriov(pdev);
-		else
-			mlx5_core_info(dev, "unloading PF driver while leaving orphan VFs\n");
-		return 0;
-	}
-
-	err = mlx5_core_sriov_enable(pdev, num_vfs);
-	if (err) {
-		mlx5_core_warn(dev, "mlx5_core_sriov_enable failed %d\n", err);
-		return err;
-	}
+	if (num_vfs)
+		err = mlx5_sriov_enable(pdev, num_vfs);
+	else
+		mlx5_sriov_disable(pdev);
 
-	mlx5_core_init_vfs(dev, num_vfs);
-#ifdef CONFIG_MLX5_CORE_EN
-	mlx5_eswitch_enable_sriov(dev->priv.eswitch, num_vfs, SRIOV_LEGACY);
-#endif
-
-	return num_vfs;
-}
-
-static int sync_required(struct pci_dev *pdev)
-{
-	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
-	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
-	int cur_vfs = pci_num_vf(pdev);
-
-	if (cur_vfs != sriov->num_vfs) {
-		mlx5_core_warn(dev, "current VFs %d, registered %d - sync needed\n",
-			       cur_vfs, sriov->num_vfs);
-		return 1;
-	}
-
-	return 0;
+	return err ? err : num_vfs;
 }
 
 int mlx5_sriov_init(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
 	struct pci_dev *pdev = dev->pdev;
-	int cur_vfs;
+	int total_vfs;
 
 	if (!mlx5_core_is_pf(dev))
 		return 0;
 
-	if (!sync_required(dev->pdev))
-		return 0;
-
-	cur_vfs = pci_num_vf(pdev);
-	sriov->vfs_ctx = kcalloc(cur_vfs, sizeof(*sriov->vfs_ctx), GFP_KERNEL);
+	total_vfs = pci_sriov_get_totalvfs(pdev);
+	sriov->num_vfs = pci_num_vf(pdev);
+	sriov->vfs_ctx = kcalloc(total_vfs, sizeof(*sriov->vfs_ctx), GFP_KERNEL);
 	if (!sriov->vfs_ctx)
 		return -ENOMEM;
 
-	sriov->enabled_vfs = cur_vfs;
-
-	mlx5_core_init_vfs(dev, cur_vfs);
-#ifdef CONFIG_MLX5_CORE_EN
-	if (cur_vfs)
-		mlx5_eswitch_enable_sriov(dev->priv.eswitch, cur_vfs,
-					  SRIOV_LEGACY);
-#endif
-
-	enable_vfs(dev, cur_vfs);
+	/* If sriov VFs exist in PCI level, enable them in device level */
+	if (!sriov->num_vfs)
+		return 0;
 
+	mlx5_device_enable_sriov(dev, sriov->num_vfs);
 	return 0;
 }
 
-int mlx5_sriov_cleanup(struct mlx5_core_dev *dev)
+void mlx5_sriov_cleanup(struct mlx5_core_dev *dev)
 {
-	struct pci_dev *pdev = dev->pdev;
-	int err;
+	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
 
 	if (!mlx5_core_is_pf(dev))
-		return 0;
+		return;
 
-	err = mlx5_core_sriov_configure(pdev, 0);
-	if (err)
-		return err;
-
-	return 0;
+	mlx5_device_disable_sriov(dev);
+	kfree(sriov->vfs_ctx);
 }
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 5cb9fa7..0d7aedf 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -828,8 +828,6 @@ void mlx5_pagealloc_init(struct mlx5_core_dev *dev);
 void mlx5_pagealloc_cleanup(struct mlx5_core_dev *dev);
 int mlx5_pagealloc_start(struct mlx5_core_dev *dev);
 void mlx5_pagealloc_stop(struct mlx5_core_dev *dev);
-int mlx5_sriov_init(struct mlx5_core_dev *dev);
-int mlx5_sriov_cleanup(struct mlx5_core_dev *dev);
 void mlx5_core_req_pages_handler(struct mlx5_core_dev *dev, u16 func_id,
 				 s32 npages);
 int mlx5_satisfy_startup_pages(struct mlx5_core_dev *dev, int boot);
-- 
2.7.4
