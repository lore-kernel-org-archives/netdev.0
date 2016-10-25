From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 11/12] net/mlx5: PCI error recovery health care simulation
Date: Tue, 25 Oct 2016 18:36:34 +0300
Message-ID: <1477409795-28807-12-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40969 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936501AbcJYPi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:29 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

In case that the kernel PCI error handlers are not called, we will
trigger our own recovery flow.

The health work will give priority to the kernel pci error handlers to
recover the PCI by waiting for a small period, if the pci error handlers
are not triggered the manual recovery flow will be executed.

We don't save pci state in case of manual recovery because it will ruin the
pci configuration space and we will lose dma sync.

Fixes: 89d44f0a6c73 ('net/mlx5_core: Add pci error handlers to mlx5_core driver')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c   | 45 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 18 ++++++---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  1 +
 include/linux/mlx5/driver.h                        |  1 +
 4 files changed, 56 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 2d00022..5bcf934 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -61,14 +61,15 @@ enum {
 enum {
 	MLX5_NIC_IFC_FULL		= 0,
 	MLX5_NIC_IFC_DISABLED		= 1,
-	MLX5_NIC_IFC_NO_DRAM_NIC	= 2
+	MLX5_NIC_IFC_NO_DRAM_NIC	= 2,
+	MLX5_NIC_IFC_INVALID		= 3
 };
 
 enum {
 	MLX5_DROP_NEW_HEALTH_WORK,
 };
 
-static u8 get_nic_interface(struct mlx5_core_dev *dev)
+static u8 get_nic_state(struct mlx5_core_dev *dev)
 {
 	return (ioread32be(&dev->iseg->cmdq_addr_l_sz) >> 8) & 3;
 }
@@ -101,7 +102,7 @@ static int in_fatal(struct mlx5_core_dev *dev)
 	struct mlx5_core_health *health = &dev->priv.health;
 	struct health_buffer __iomem *h = health->health;
 
-	if (get_nic_interface(dev) == MLX5_NIC_IFC_DISABLED)
+	if (get_nic_state(dev) == MLX5_NIC_IFC_DISABLED)
 		return 1;
 
 	if (ioread32be(&h->fw_ver) == 0xffffffff)
@@ -131,7 +132,7 @@ void mlx5_enter_error_state(struct mlx5_core_dev *dev)
 
 static void mlx5_handle_bad_state(struct mlx5_core_dev *dev)
 {
-	u8 nic_interface = get_nic_interface(dev);
+	u8 nic_interface = get_nic_state(dev);
 
 	switch (nic_interface) {
 	case MLX5_NIC_IFC_FULL:
@@ -153,8 +154,34 @@ static void mlx5_handle_bad_state(struct mlx5_core_dev *dev)
 	mlx5_disable_device(dev);
 }
 
+static void health_recover(struct work_struct *work)
+{
+	struct mlx5_core_health *health;
+	struct delayed_work *dwork;
+	struct mlx5_core_dev *dev;
+	struct mlx5_priv *priv;
+	u8 nic_state;
+
+	dwork = container_of(work, struct delayed_work, work);
+	health = container_of(dwork, struct mlx5_core_health, recover_work);
+	priv = container_of(health, struct mlx5_priv, health);
+	dev = container_of(priv, struct mlx5_core_dev, priv);
+
+	nic_state = get_nic_state(dev);
+	if (nic_state == MLX5_NIC_IFC_INVALID) {
+		dev_err(&dev->pdev->dev, "health recovery flow aborted since the nic state is invalid\n");
+		return;
+	}
+
+	dev_err(&dev->pdev->dev, "starting health recovery flow\n");
+	mlx5_recover_device(dev);
+}
+
+/* How much time to wait until health resetting the driver (in msecs) */
+#define MLX5_RECOVERY_DELAY_MSECS 60000
 static void health_care(struct work_struct *work)
 {
+	unsigned long recover_delay = msecs_to_jiffies(MLX5_RECOVERY_DELAY_MSECS);
 	struct mlx5_core_health *health;
 	struct mlx5_core_dev *dev;
 	struct mlx5_priv *priv;
@@ -164,6 +191,14 @@ static void health_care(struct work_struct *work)
 	dev = container_of(priv, struct mlx5_core_dev, priv);
 	mlx5_core_warn(dev, "handling bad device here\n");
 	mlx5_handle_bad_state(dev);
+
+	spin_lock(&health->wq_lock);
+	if (!test_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags))
+		schedule_delayed_work(&health->recover_work, recover_delay);
+	else
+		dev_err(&dev->pdev->dev,
+			"new health works are not permitted at this stage\n");
+	spin_unlock(&health->wq_lock);
 }
 
 static const char *hsynd_str(u8 synd)
@@ -316,6 +351,7 @@ void mlx5_drain_health_wq(struct mlx5_core_dev *dev)
 	spin_lock(&health->wq_lock);
 	set_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags);
 	spin_unlock(&health->wq_lock);
+	cancel_delayed_work_sync(&health->recover_work);
 	cancel_work_sync(&health->work);
 }
 
@@ -344,6 +380,7 @@ int mlx5_health_init(struct mlx5_core_dev *dev)
 		return -ENOMEM;
 	spin_lock_init(&health->wq_lock);
 	INIT_WORK(&health->work, health_care);
+	INIT_DELAYED_WORK(&health->recover_work, health_recover);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 9f90226..d5433c4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1313,6 +1313,7 @@ static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
 	struct mlx5_priv *priv = &dev->priv;
 
 	dev_info(&pdev->dev, "%s was called\n", __func__);
+
 	mlx5_enter_error_state(dev);
 	mlx5_unload_one(dev, priv, false);
 	/* In case of kernel call save the pci state and drain health wq */
@@ -1378,11 +1379,6 @@ static pci_ers_result_t mlx5_pci_slot_reset(struct pci_dev *pdev)
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
-void mlx5_disable_device(struct mlx5_core_dev *dev)
-{
-	mlx5_pci_err_detected(dev->pdev, 0);
-}
-
 static void mlx5_pci_resume(struct pci_dev *pdev)
 {
 	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
@@ -1432,6 +1428,18 @@ static const struct pci_device_id mlx5_core_pci_table[] = {
 
 MODULE_DEVICE_TABLE(pci, mlx5_core_pci_table);
 
+void mlx5_disable_device(struct mlx5_core_dev *dev)
+{
+	mlx5_pci_err_detected(dev->pdev, 0);
+}
+
+void mlx5_recover_device(struct mlx5_core_dev *dev)
+{
+	mlx5_pci_disable_device(dev);
+	if (mlx5_pci_slot_reset(dev->pdev) == PCI_ERS_RESULT_RECOVERED)
+		mlx5_pci_resume(dev->pdev);
+}
+
 static struct pci_driver mlx5_core_driver = {
 	.name           = DRIVER_NAME,
 	.id_table       = mlx5_core_pci_table,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 3d0cfb9..187662c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -83,6 +83,7 @@ void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param);
 void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
+void mlx5_recover_device(struct mlx5_core_dev *dev);
 int mlx5_sriov_init(struct mlx5_core_dev *dev);
 void mlx5_sriov_cleanup(struct mlx5_core_dev *dev);
 int mlx5_sriov_attach(struct mlx5_core_dev *dev);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 7d9a5d0..ecc451d 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -423,6 +423,7 @@ struct mlx5_core_health {
 	struct workqueue_struct	       *wq;
 	unsigned long			flags;
 	struct work_struct		work;
+	struct delayed_work		recover_work;
 };
 
 struct mlx5_cq_table {
-- 
2.7.4
