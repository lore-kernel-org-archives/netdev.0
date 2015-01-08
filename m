From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [RFC net-next 3/3] net/mlx4_core: Set port_type value according to configuration module
Date: Thu,  8 Jan 2015 17:17:00 +0200
Message-ID: <1420730220-20224-4-git-send-email-hadarh@mellanox.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, shannon.nelson@intel.com,
	Doug Ledford <dledford@redhat.com>, greearb@candelatech.com
To: "David S. Miller" <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54570 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754650AbbAHPSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 10:18:46 -0500
In-Reply-To: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

port_type_array is a module parameter which sets mlx4_core ports type
under SRIOV.
Since module parameter can't be set per device, few Mellanox NICs using
the same driver, will have to be configured with the same ports type.

Using the new devconf infrastructure allows setting different ports type
per device. In case mlx4_core configuration module is missing, the ports
type of each device will be set as before, according to port_type_array
value.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c  |   55 +++++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |    1 +
 3 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index fa135d3..ebdfaae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -33,6 +33,7 @@ config MLX4_EN_VXLAN
 config MLX4_CORE
 	tristate
 	depends on PCI
+	select DEVCONF
 	default n
 
 config MLX4_DEBUG
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 943cbd4..c2c1129 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -42,6 +42,7 @@
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
 #include <linux/kmod.h>
+#include <linux/devconf.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/doorbell.h>
@@ -55,6 +56,7 @@ MODULE_DESCRIPTION("Mellanox ConnectX HCA low-level driver");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(DRV_VERSION);
 
+static struct devconf_config_driver *mlx4_conf;
 struct workqueue_struct *mlx4_wq;
 
 #ifdef CONFIG_MLX4_DEBUG
@@ -255,6 +257,36 @@ static void mlx4_enable_cqe_eqe_stride(struct mlx4_dev *dev)
 	}
 }
 
+static int config_port_type(struct mlx4_priv *priv,
+			    int port_num,
+			    int *port_type)
+{
+	struct devconf_config_object *port, *ports;
+	int err;
+	char port_n[sizeof(int)];
+
+	if (!priv->config_obj)
+		return -ENOENT;
+
+	ports = devconf_get_config_object(&priv->config_obj->group, "ports");
+	if (!ports) {
+		pr_err("Fail to get ports configuration\n");
+		return -ENOENT;
+	}
+
+	sprintf(port_n, "%d", port_num);
+	port = devconf_get_config_object(&ports->group, port_n);
+	if (!port)
+		return -ENOENT;
+	err = devconf_get_int_attr(mlx4_conf, port, "type", port_type);
+	if (err < 0) {
+		pr_err("Fail to get port %d type from dev_c_mlx4 configuration module\n",
+		       port_num);
+		return err;
+	}
+	return 0;
+}
+
 static int _mlx4_dev_port(struct mlx4_dev *dev, int port,
 			  struct mlx4_port_cap *port_cap)
 {
@@ -297,6 +329,8 @@ static int mlx4_dev_port(struct mlx4_dev *dev, int port,
 #define MLX4_A0_STEERING_TABLE_SIZE	256
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port_type;
 	int err;
 	int i;
 
@@ -411,7 +445,11 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 				/* if IB and ETH are supported, we set the port
 				 * type according to user selection of port type;
 				 * if user selected none, take the FW hint */
-				if (port_type_array[i - 1] == MLX4_PORT_TYPE_NONE)
+				err = config_port_type(priv, i, &port_type);
+				if (!err)
+					dev->caps.port_type[i] = port_type;
+				else if (port_type_array[i - 1] ==
+					 MLX4_PORT_TYPE_NONE)
 					dev->caps.port_type[i] = dev->caps.suggested_type[i] ?
 						MLX4_PORT_TYPE_ETH : MLX4_PORT_TYPE_IB;
 				else
@@ -3072,6 +3110,7 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct mlx4_priv *priv;
 	struct mlx4_dev *dev;
+	struct devconf_config_object *pdevs;
 	int ret;
 
 	printk_once(KERN_INFO "%s", mlx4_version);
@@ -3085,6 +3124,20 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	pci_set_drvdata(pdev, dev);
 	priv->pci_dev_data = id->driver_data;
 
+	mlx4_conf = devconf_get_config_driver(DRV_NAME);
+	if (IS_ERR(mlx4_conf)) {
+		pr_warn("Configuration driver is missing for "
+			DRV_NAME ", using default vlaues.\n");
+	} else {
+		pdevs = devconf_get_config_object(&mlx4_conf->cobj.group,
+						  "pdevs");
+		if (!pdevs)
+			pr_err("Couldn't find 'pdevs' config object\n");
+		else
+			priv->config_obj =
+				devconf_get_config_object(&pdevs->group,
+							  pci_name(pdev));
+	}
 	ret =  __mlx4_init_one(pdev, id->driver_data, priv);
 	if (ret)
 		kfree(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index bdd4eea..81678a5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -881,6 +881,7 @@ struct mlx4_priv {
 
 	atomic_t		opreq_count;
 	struct work_struct	opreq_task;
+	struct devconf_config_object	*config_obj;
 };
 
 static inline struct mlx4_priv *mlx4_priv(struct mlx4_dev *dev)
-- 
1.7.8.2
