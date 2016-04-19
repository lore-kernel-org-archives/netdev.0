From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 8/9] net/mlx5: Add pci shutdown callback
Date: Tue, 19 Apr 2016 15:33:41 +0300
Message-ID: <1461069222-27076-9-git-send-email-saeedm@mellanox.com>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Haggai Abramovsky <hagaya@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48460 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754078AbcDSMfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:35:04 -0400
In-Reply-To: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

This patch introduces kexec support for mlx5.
When switching kernels, kexec() calls shutdown, which unloads
the driver and cleans its resources.

In addition, remove unregister netdev from shutdown flow. This will
allow a clean shutdown, even if some netdev clients did not release their
reference from this netdev. Releasing The HW resources only is enough as
the kernel is shutting down

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   15 +++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |   23 +++++++++++++++++---
 include/linux/mlx5/driver.h                       |    7 +++--
 3 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 85773f8..67d548b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2633,7 +2633,16 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	schedule_work(&priv->set_rx_mode_work);
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
-	unregister_netdev(netdev);
+	if (test_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &mdev->intf_state)) {
+		netif_device_detach(netdev);
+		mutex_lock(&priv->state_lock);
+		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+			mlx5e_close_locked(netdev);
+		mutex_unlock(&priv->state_lock);
+	} else {
+		unregister_netdev(netdev);
+	}
+
 	mlx5e_tc_cleanup(priv);
 	mlx5e_vxlan_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
@@ -2646,7 +2655,9 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5_core_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
 	mlx5_unmap_free_uar(priv->mdev, &priv->cq_uar);
-	free_netdev(netdev);
+
+	if (!test_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &mdev->intf_state))
+		free_netdev(netdev);
 }
 
 static void *mlx5e_get_netdev(void *vpriv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index ddd352a..6892746 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -966,7 +966,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	int err;
 
 	mutex_lock(&dev->intf_state_mutex);
-	if (dev->interface_state == MLX5_INTERFACE_STATE_UP) {
+	if (test_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state)) {
 		dev_warn(&dev->pdev->dev, "%s: interface is up, NOP\n",
 			 __func__);
 		goto out;
@@ -1133,7 +1133,8 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	if (err)
 		pr_info("failed request module on %s\n", MLX5_IB_MOD);
 
-	dev->interface_state = MLX5_INTERFACE_STATE_UP;
+	clear_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state);
+	set_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state);
 out:
 	mutex_unlock(&dev->intf_state_mutex);
 
@@ -1207,7 +1208,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	}
 
 	mutex_lock(&dev->intf_state_mutex);
-	if (dev->interface_state == MLX5_INTERFACE_STATE_DOWN) {
+	if (test_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state)) {
 		dev_warn(&dev->pdev->dev, "%s: interface is down, NOP\n",
 			 __func__);
 		goto out;
@@ -1241,7 +1242,8 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_cmd_cleanup(dev);
 
 out:
-	dev->interface_state = MLX5_INTERFACE_STATE_DOWN;
+	clear_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state);
+	set_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state);
 	mutex_unlock(&dev->intf_state_mutex);
 	return err;
 }
@@ -1452,6 +1454,18 @@ static const struct pci_error_handlers mlx5_err_handler = {
 	.resume		= mlx5_pci_resume
 };
 
+static void shutdown(struct pci_dev *pdev)
+{
+	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
+	struct mlx5_priv *priv = &dev->priv;
+
+	dev_info(&pdev->dev, "Shutdown was called\n");
+	/* Notify mlx5 clients that the kernel is being shut down */
+	set_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &dev->intf_state);
+	mlx5_unload_one(dev, priv);
+	mlx5_pci_disable_device(dev);
+}
+
 static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x1011) },			/* Connect-IB */
 	{ PCI_VDEVICE(MELLANOX, 0x1012), MLX5_PCI_DEV_IS_VF},	/* Connect-IB VF */
@@ -1471,6 +1485,7 @@ static struct pci_driver mlx5_core_driver = {
 	.id_table       = mlx5_core_pci_table,
 	.probe          = init_one,
 	.remove         = remove_one,
+	.shutdown	= shutdown,
 	.err_handler	= &mlx5_err_handler,
 	.sriov_configure   = mlx5_core_sriov_configure,
 };
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index dcd5ac8..369c837 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -519,8 +519,9 @@ enum mlx5_device_state {
 };
 
 enum mlx5_interface_state {
-	MLX5_INTERFACE_STATE_DOWN,
-	MLX5_INTERFACE_STATE_UP,
+	MLX5_INTERFACE_STATE_DOWN = BIT(0),
+	MLX5_INTERFACE_STATE_UP = BIT(1),
+	MLX5_INTERFACE_STATE_SHUTDOWN = BIT(2),
 };
 
 enum mlx5_pci_status {
@@ -544,7 +545,7 @@ struct mlx5_core_dev {
 	enum mlx5_device_state	state;
 	/* sync interface state */
 	struct mutex		intf_state_mutex;
-	enum mlx5_interface_state interface_state;
+	unsigned long		intf_state;
 	void			(*event) (struct mlx5_core_dev *dev,
 					  enum mlx5_dev_event event,
 					  unsigned long param);
-- 
1.7.1
