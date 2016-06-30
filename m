From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 09/16] net/mlx5: Add devlink interface
Date: Thu, 30 Jun 2016 18:23:28 +0300
Message-ID: <1467300215-14199-10-git-send-email-saeedm@mellanox.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44333 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932133AbcF3Pha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 11:37:30 -0400
In-Reply-To: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The devlink interface is initially used to set/get the mode of the SRIOV e-switch.

Currently, these are only stubs for get/set, down-stream patch will actually
fill them out.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  4 ++++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 10 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 26 ++++++++++++++++++----
 4 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 1cf722e..aae4688 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -4,6 +4,7 @@
 
 config MLX5_CORE
 	tristate "Mellanox Technologies ConnectX-4 and Connect-IB core driver"
+	depends on MAY_USE_DEVLINK
 	depends on PCI
 	default n
 	---help---
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index cf959f7..7843f98 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -35,6 +35,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_link.h>
+#include <net/devlink.h>
 #include <linux/mlx5/device.h>
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
@@ -205,6 +206,9 @@ mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn
 struct mlx5_flow_rule *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
+int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode);
+int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
+
 #define MLX5_DEBUG_ESWITCH_MASK BIT(3)
 
 #define esw_info(dev, format, ...)				\
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 7aad367..e1727a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -328,3 +328,13 @@ out:
 	kfree(match_c);
 	return flow_rule;
 }
+
+int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
+{
+	return -EOPNOTSUPP;
+}
+
+int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
+{
+	return -EOPNOTSUPP;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 08cae34..2abd387 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -51,6 +51,7 @@
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
 #endif
+#include <net/devlink.h>
 #include "mlx5_core.h"
 #include "fs_core.h"
 #ifdef CONFIG_MLX5_CORE_EN
@@ -1315,19 +1316,28 @@ struct mlx5_core_event_handler {
 		      void *data);
 };
 
+static const struct devlink_ops mlx5_devlink_ops = {
+#ifdef CONFIG_MLX5_CORE_EN
+	.eswitch_mode_set = mlx5_devlink_eswitch_mode_set,
+	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
+#endif
+};
 
 static int init_one(struct pci_dev *pdev,
 		    const struct pci_device_id *id)
 {
 	struct mlx5_core_dev *dev;
+	struct devlink *devlink;
 	struct mlx5_priv *priv;
 	int err;
 
-	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
-	if (!dev) {
+	devlink = devlink_alloc(&mlx5_devlink_ops, sizeof(*dev));
+	if (!devlink) {
 		dev_err(&pdev->dev, "kzalloc failed\n");
 		return -ENOMEM;
 	}
+
+	dev = devlink_priv(devlink);
 	priv = &dev->priv;
 	priv->pci_dev_data = id->driver_data;
 
@@ -1364,15 +1374,21 @@ static int init_one(struct pci_dev *pdev,
 		goto clean_health;
 	}
 
+	err = devlink_register(devlink, &pdev->dev);
+	if (err)
+		goto clean_load;
+
 	return 0;
 
+clean_load:
+	mlx5_unload_one(dev, priv);
 clean_health:
 	mlx5_health_cleanup(dev);
 close_pci:
 	mlx5_pci_close(dev, priv);
 clean_dev:
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	devlink_free(devlink);
 
 	return err;
 }
@@ -1380,8 +1396,10 @@ clean_dev:
 static void remove_one(struct pci_dev *pdev)
 {
 	struct mlx5_core_dev *dev  = pci_get_drvdata(pdev);
+	struct devlink *devlink = priv_to_devlink(dev);
 	struct mlx5_priv *priv = &dev->priv;
 
+	devlink_unregister(devlink);
 	if (mlx5_unload_one(dev, priv)) {
 		dev_err(&dev->pdev->dev, "mlx5_unload_one failed\n");
 		mlx5_health_cleanup(dev);
@@ -1390,7 +1408,7 @@ static void remove_one(struct pci_dev *pdev)
 	mlx5_health_cleanup(dev);
 	mlx5_pci_close(dev, priv);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	devlink_free(devlink);
 }
 
 static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
-- 
2.8.0
