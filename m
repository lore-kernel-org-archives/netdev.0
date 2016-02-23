From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/9] mlx4: Implement devlink interface
Date: Tue, 23 Feb 2016 16:51:27 +0100
Message-ID: <1456242694-29463-3-git-send-email-jiri@resnulli.us>
References: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35351 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbcBWPvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:51:41 -0500
Received: by mail-wm0-f50.google.com with SMTP id c200so227330819wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:51:40 -0800 (PST)
In-Reply-To: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement newly introduced devlink interface. Add devlink port instances
for every port and set the port types accordingly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c              |  7 ++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  8 ++++-
 drivers/net/ethernet/mellanox/mlx4/intf.c      |  9 ++++++
 drivers/net/ethernet/mellanox/mlx4/main.c      | 45 +++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |  2 ++
 include/linux/mlx4/driver.h                    |  3 ++
 6 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 1c7ab6c..a15a7b3 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -41,6 +41,7 @@
 #include <linux/if_vlan.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
+#include <net/devlink.h>
 
 #include <rdma/ib_smi.h>
 #include <rdma/ib_user_verbs.h>
@@ -2519,6 +2520,9 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	}
 
 	ibdev->ib_active = true;
+	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
+		devlink_port_type_ib_set(mlx4_get_devlink_port(dev, i),
+					 &ibdev->ib_dev);
 
 	if (mlx4_is_mfunc(ibdev->dev))
 		init_pkeys(ibdev);
@@ -2643,7 +2647,10 @@ static void mlx4_ib_remove(struct mlx4_dev *dev, void *ibdev_ptr)
 {
 	struct mlx4_ib_dev *ibdev = ibdev_ptr;
 	int p;
+	int i;
 
+	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
+		devlink_port_type_clear(mlx4_get_devlink_port(dev, i));
 	ibdev->ib_active = false;
 	flush_workqueue(wq);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 96d95cb..e26b110 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -40,6 +40,7 @@
 #include <net/ip.h>
 #include <net/busy_poll.h>
 #include <net/vxlan.h>
+#include <net/devlink.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -2033,8 +2034,11 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
 
 	/* Unregister device - this will close the port if it was up */
-	if (priv->registered)
+	if (priv->registered) {
+		devlink_port_type_clear(mlx4_get_devlink_port(mdev->dev,
+							      priv->port));
 		unregister_netdev(dev);
+	}
 
 	if (priv->allocated)
 		mlx4_free_hwq_res(mdev->dev, &priv->res, MLX4_EN_PAGE_SIZE);
@@ -3051,6 +3055,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	priv->registered = 1;
+	devlink_port_type_eth_set(mlx4_get_devlink_port(mdev->dev, priv->port),
+				  dev);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 0472941..dec77d6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 #include <linux/errno.h>
+#include <net/devlink.h>
 
 #include "mlx4.h"
 
@@ -249,3 +250,11 @@ void *mlx4_get_protocol_dev(struct mlx4_dev *dev, enum mlx4_protocol proto, int
 	return result;
 }
 EXPORT_SYMBOL_GPL(mlx4_get_protocol_dev);
+
+struct devlink_port *mlx4_get_devlink_port(struct mlx4_dev *dev, int port)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+
+	return &info->devlink_port;
+}
+EXPORT_SYMBOL_GPL(mlx4_get_devlink_port);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2cc3c62..ca88f38 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -42,6 +42,7 @@
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
 #include <linux/kmod.h>
+#include <net/devlink.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/doorbell.h>
@@ -2881,8 +2882,13 @@ no_msi:
 
 static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 {
+	struct devlink *devlink = priv_to_devlink(mlx4_priv(dev));
 	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
-	int err = 0;
+	int err;
+
+	err = devlink_port_register(devlink, &info->devlink_port, port);
+	if (err)
+		return err;
 
 	info->dev = dev;
 	info->port = port;
@@ -2907,6 +2913,7 @@ static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 	err = device_create_file(&dev->persist->pdev->dev, &info->port_attr);
 	if (err) {
 		mlx4_err(dev, "Failed to create file for port %d\n", port);
+		devlink_port_unregister(&info->devlink_port);
 		info->port = -1;
 	}
 
@@ -3680,21 +3687,23 @@ err_disable_pdev:
 
 static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 {
+	struct devlink *devlink;
 	struct mlx4_priv *priv;
 	struct mlx4_dev *dev;
 	int ret;
 
 	printk_once(KERN_INFO "%s", mlx4_version);
 
-	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv)
+	devlink = devlink_alloc(NULL, sizeof(*priv));
+	if (!devlink)
 		return -ENOMEM;
+	priv = devlink_priv(devlink);
 
 	dev       = &priv->dev;
 	dev->persist = kzalloc(sizeof(*dev->persist), GFP_KERNEL);
 	if (!dev->persist) {
-		kfree(priv);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto err_devlink_free;
 	}
 	dev->persist->pdev = pdev;
 	dev->persist->dev = dev;
@@ -3703,14 +3712,24 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	mutex_init(&dev->persist->device_state_mutex);
 	mutex_init(&dev->persist->interface_state_mutex);
 
+	set_devlink_dev(devlink, &pdev->dev);
+	ret = devlink_register(devlink);
+	if (ret)
+		goto err_persist_free;
+
 	ret =  __mlx4_init_one(pdev, id->driver_data, priv);
-	if (ret) {
-		kfree(dev->persist);
-		kfree(priv);
-	} else {
-		pci_save_state(pdev);
-	}
+	if (ret)
+		goto err_devlink_unregister;
 
+	pci_save_state(pdev);
+	return 0;
+
+err_devlink_unregister:
+	devlink_unregister(devlink);
+err_persist_free:
+	kfree(dev->persist);
+err_devlink_free:
+	devlink_free(devlink);
 	return ret;
 }
 
@@ -3811,6 +3830,7 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
 	struct mlx4_dev  *dev  = persist->dev;
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct devlink *devlink = priv_to_devlink(priv);
 	int active_vfs = 0;
 
 	mutex_lock(&persist->interface_state_mutex);
@@ -3841,8 +3861,9 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
+	devlink_unregister(devlink);
 	kfree(dev->persist);
-	kfree(priv);
+	devlink_free(devlink);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 7baef52..ef96831 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -45,6 +45,7 @@
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
+#include <net/devlink.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/driver.h>
@@ -828,6 +829,7 @@ struct mlx4_port_info {
 	struct mlx4_roce_gid_table gid_table;
 	int			base_qpn;
 	struct cpu_rmap		*rmap;
+	struct devlink_port	devlink_port;
 };
 
 struct mlx4_sense {
diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
index 2e8af00..bd0e707 100644
--- a/include/linux/mlx4/driver.h
+++ b/include/linux/mlx4/driver.h
@@ -33,6 +33,7 @@
 #ifndef MLX4_DRIVER_H
 #define MLX4_DRIVER_H
 
+#include <net/devlink.h>
 #include <linux/mlx4/device.h>
 
 struct mlx4_dev;
@@ -89,6 +90,8 @@ int mlx4_port_map_set(struct mlx4_dev *dev, struct mlx4_port_map *v2p);
 
 void *mlx4_get_protocol_dev(struct mlx4_dev *dev, enum mlx4_protocol proto, int port);
 
+struct devlink_port *mlx4_get_devlink_port(struct mlx4_dev *dev, int port);
+
 static inline u64 mlx4_mac_to_u64(u8 *addr)
 {
 	u64 mac = 0;
-- 
2.5.0
