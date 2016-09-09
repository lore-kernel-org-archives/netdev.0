From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/11] net/mlx5: Implement SRIOV attach/detach flows
Date: Fri,  9 Sep 2016 17:35:21 +0300
Message-ID: <1473431727-20150-6-git-send-email-saeedm@mellanox.com>
References: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35513 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752789AbcIIOhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:37:05 -0400
In-Reply-To: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Needed for lightweight and modular internal/pci error handling.
Implement sriov attach function which enables pre-saved number of vfs on
the device side.
Implement sriov detach function which disable the current vfs on the
device side.
Init/cleanup function only handles sriov software context allocation and
destruction.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    | 29 ++++++++++++++++------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 7dd14cf..04b719a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -91,6 +91,8 @@ void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
 int mlx5_sriov_init(struct mlx5_core_dev *dev);
 void mlx5_sriov_cleanup(struct mlx5_core_dev *dev);
+int mlx5_sriov_attach(struct mlx5_core_dev *dev);
+void mlx5_sriov_detach(struct mlx5_core_dev *dev);
 int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
 bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev);
 int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index 72a8215..f4f02b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -188,6 +188,25 @@ int mlx5_core_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	return err ? err : num_vfs;
 }
 
+int mlx5_sriov_attach(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
+
+	if (!mlx5_core_is_pf(dev) || !sriov->num_vfs)
+		return 0;
+
+	/* If sriov VFs exist in PCI level, enable them in device level */
+	return mlx5_device_enable_sriov(dev, sriov->num_vfs);
+}
+
+void mlx5_sriov_detach(struct mlx5_core_dev *dev)
+{
+	if (!mlx5_core_is_pf(dev))
+		return;
+
+	mlx5_device_disable_sriov(dev);
+}
+
 int mlx5_sriov_init(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
@@ -203,12 +222,7 @@ int mlx5_sriov_init(struct mlx5_core_dev *dev)
 	if (!sriov->vfs_ctx)
 		return -ENOMEM;
 
-	/* If sriov VFs exist in PCI level, enable them in device level */
-	if (!sriov->num_vfs)
-		return 0;
-
-	mlx5_device_enable_sriov(dev, sriov->num_vfs);
-	return 0;
+	return mlx5_sriov_attach(dev);
 }
 
 void mlx5_sriov_cleanup(struct mlx5_core_dev *dev)
@@ -217,7 +231,6 @@ void mlx5_sriov_cleanup(struct mlx5_core_dev *dev)
 
 	if (!mlx5_core_is_pf(dev))
 		return;
-
-	mlx5_device_disable_sriov(dev);
+	mlx5_sriov_detach(dev);
 	kfree(sriov->vfs_ctx);
 }
-- 
2.7.4
