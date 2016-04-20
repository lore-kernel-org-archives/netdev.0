From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/4] net/mlx4_core: Avoid repeated calls to pci enable/disable
Date: Wed, 20 Apr 2016 16:01:16 +0300
Message-ID: <1461157278-18528-3-git-send-email-ogerlitz@mellanox.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51066 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753428AbcDTNBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:01:49 -0400
In-Reply-To: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Maintain the PCI status and provide wrappers for enabling and disabling
the PCI device.  Performing the actions more than once without doing
its opposite results in warning logs.

This occurred when EEH hotplugged the device causing a warning for
disabling an already disabled device.

Fixes: 2ba5fbd62b25 ('net/mlx4_core: Handle AER flow properly')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 39 +++++++++++++++++++++++++++----
 include/linux/mlx4/device.h               |  7 ++++++
 2 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5d45aa3..12c77a7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3172,6 +3172,34 @@ static int mlx4_check_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap
 	return 0;
 }
 
+static int mlx4_pci_enable_device(struct mlx4_dev *dev)
+{
+	struct pci_dev *pdev = dev->persist->pdev;
+	int err = 0;
+
+	mutex_lock(&dev->persist->pci_status_mutex);
+	if (dev->persist->pci_status == MLX4_PCI_STATUS_DISABLED) {
+		err = pci_enable_device(pdev);
+		if (!err)
+			dev->persist->pci_status = MLX4_PCI_STATUS_ENABLED;
+	}
+	mutex_unlock(&dev->persist->pci_status_mutex);
+
+	return err;
+}
+
+static void mlx4_pci_disable_device(struct mlx4_dev *dev)
+{
+	struct pci_dev *pdev = dev->persist->pdev;
+
+	mutex_lock(&dev->persist->pci_status_mutex);
+	if (dev->persist->pci_status == MLX4_PCI_STATUS_ENABLED) {
+		pci_disable_device(pdev);
+		dev->persist->pci_status = MLX4_PCI_STATUS_DISABLED;
+	}
+	mutex_unlock(&dev->persist->pci_status_mutex);
+}
+
 static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 			 int total_vfs, int *nvfs, struct mlx4_priv *priv,
 			 int reset_flow)
@@ -3582,7 +3610,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 
 	pr_info(DRV_NAME ": Initializing %s\n", pci_name(pdev));
 
-	err = pci_enable_device(pdev);
+	err = mlx4_pci_enable_device(&priv->dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
 		return err;
@@ -3715,7 +3743,7 @@ err_release_regions:
 	pci_release_regions(pdev);
 
 err_disable_pdev:
-	pci_disable_device(pdev);
+	mlx4_pci_disable_device(&priv->dev);
 	pci_set_drvdata(pdev, NULL);
 	return err;
 }
@@ -3775,6 +3803,7 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	priv->pci_dev_data = id->driver_data;
 	mutex_init(&dev->persist->device_state_mutex);
 	mutex_init(&dev->persist->interface_state_mutex);
+	mutex_init(&dev->persist->pci_status_mutex);
 
 	ret = devlink_register(devlink, &pdev->dev);
 	if (ret)
@@ -3923,7 +3952,7 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	}
 
 	pci_release_regions(pdev);
-	pci_disable_device(pdev);
+	mlx4_pci_disable_device(dev);
 	devlink_unregister(devlink);
 	kfree(dev->persist);
 	devlink_free(devlink);
@@ -4042,7 +4071,7 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 	if (state == pci_channel_io_perm_failure)
 		return PCI_ERS_RESULT_DISCONNECT;
 
-	pci_disable_device(pdev);
+	mlx4_pci_disable_device(persist->dev);
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
@@ -4053,7 +4082,7 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 	int err;
 
 	mlx4_err(dev, "mlx4_pci_slot_reset was called\n");
-	err = pci_enable_device(pdev);
+	err = mlx4_pci_enable_device(dev);
 	if (err) {
 		mlx4_err(dev, "Can not re-enable device, err=%d\n", err);
 		return PCI_ERS_RESULT_DISCONNECT;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 8541a91..d1f904c 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -828,6 +828,11 @@ struct mlx4_vf_dev {
 	u8			n_ports;
 };
 
+enum mlx4_pci_status {
+	MLX4_PCI_STATUS_DISABLED,
+	MLX4_PCI_STATUS_ENABLED,
+};
+
 struct mlx4_dev_persistent {
 	struct pci_dev	       *pdev;
 	struct mlx4_dev	       *dev;
@@ -841,6 +846,8 @@ struct mlx4_dev_persistent {
 	u8		state;
 	struct mutex	interface_state_mutex; /* protect SW state */
 	u8	interface_state;
+	struct mutex		pci_status_mutex; /* sync pci state */
+	enum mlx4_pci_status	pci_status;
 };
 
 struct mlx4_dev {
-- 
2.3.7
