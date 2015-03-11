From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 3/3] net/mlx4_core: Set DMFS mode according to configfs configuration
Date: Wed, 11 Mar 2015 11:08:53 +0200
Message-ID: <1426064933-29072-4-git-send-email-amirv@mellanox.com>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, shannon.nelson@intel.com,
	dledford@redhat.com, greearb@candelatech.com,
	Rose Gregory V <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg K-H <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48172 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752361AbbCKJKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 05:10:21 -0400
In-Reply-To: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Today, in order to enable Device Managed Flow steering (DMFS), we use
log_num_mgm_entry_size parameter. If the value of the parameter is not
positive, we treat the absolute value of log_num_mgm_entry_size as a bit
field. DMFS mode will be determine according to which bits were set.

Using the new mlx4_core configfs infrastructure for configuring DMFS
mode is more "user friendly", allows us to set different DMFS mode per
device and easily add new and advanced DMFS modes.
Currently, dmfs_mode attribute can take 3 strings: "disable", "dmfs" or
"A0_static".

In case the configfs configuration is missing, the DMFS mode of each
device will be set as before, according to log_num_mgm_entry_size value.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/conf.c | 46 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c | 25 +++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  1 +
 include/linux/mlx4/device.h               |  7 +++++
 4 files changed, 73 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/conf.c b/drivers/net/ethernet/mellanox/mlx4/conf.c
index 678979a..437a0c1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/conf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/conf.c
@@ -235,6 +235,46 @@ static int ports_config_verify_name(struct pdev_config *pdev_cfg,
 	return 0;
 }
 
+static ssize_t pdev_config_dmfs_mode_store(struct pdev_config *pdev_cfg,
+					   const char *page, size_t len)
+{
+	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev_cfg->pdev);
+	struct mlx4_dev *dev = persist->dev;
+	char *pdev_name = pdev_cfg->group.cg_item.ci_name;
+
+	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FS_EN)) {
+		pr_err("mlx4_core %s: DMFS isn't supported by the device.\n",
+		       pdev_name);
+		return -EINVAL;
+	}
+
+	if (!strcmp(page, "disable\n")) {
+		pdev_cfg->dmfs_mode = MLX4_DMFS_MODE_DISABLE;
+	} else if (!strcmp(page, "dmfs\n")) {
+		pdev_cfg->dmfs_mode = MLX4_DMFS_MODE_ETH_IPOIB;
+	} else if (!strcmp(page, "A0_static\n")) {
+		pdev_cfg->dmfs_mode = MLX4_DMFS_MODE_STATIC_A0;
+	} else {
+		pr_err("mlx4_core %s: Unsupported DMFS mode: %s, use 'disable', 'dmfs' or 'A0_static'\n",
+		       pdev_name, page);
+		return -EINVAL;
+	}
+	return len;
+}
+
+static ssize_t pdev_config_dmfs_mode_show(struct pdev_config *pdev_cfg,
+					  char *page)
+{
+	if (pdev_cfg->dmfs_mode == MLX4_DMFS_MODE_DISABLE)
+		return sprintf(page, "%s\n", "disable");
+	else if (pdev_cfg->dmfs_mode == MLX4_DMFS_MODE_ETH_IPOIB)
+		return sprintf(page, "%s\n", "dmfs");
+	else if (pdev_cfg->dmfs_mode == MLX4_DMFS_MODE_STATIC_A0)
+		return sprintf(page, "%s\n", "A0_static");
+	else
+		return sprintf(page, "%s\n", "unsupported dmfs mode\n");
+}
+
 static ssize_t pdev_config_commit_store(struct pdev_config *cfg,
 					const char *page, size_t len)
 {
@@ -280,6 +320,7 @@ static ssize_t pdev_config_commit_show(struct pdev_config *pdev_cfg, char *page)
 
 CONFIGFS_ATTR_STRUCT(pdev_config);
 CONFIGFS_ATTR_OPS(pdev_config);
+MLX4_CFG_CONFIGFS_ATTR(pdev_config, dmfs_mode);
 MLX4_CFG_CONFIGFS_ATTR(pdev_config, commit);
 
 static void pdev_config_release(struct config_item *item)
@@ -291,6 +332,7 @@ static void pdev_config_release(struct config_item *item)
 }
 
 static struct configfs_attribute *pdev_config_attrs[] = {
+	&pdev_config_dmfs_mode.attr,
 	&pdev_config_commit.attr,
 	NULL,
 };
@@ -432,6 +474,7 @@ int mlx4_conf_get_config(struct mlx4_dev *dev, struct pci_dev *pdev)
 	struct config_group *pdev_group, *ports_group, *port_group;
 	char port_num[PORT_NAME_SIZE];
 	struct port_config *port_cfg;
+	struct pdev_config *pdev_cfg;
 	int i;
 	struct mlx4_conf *mlx4_config = &dev->persist->mlx4_config;
 
@@ -440,6 +483,9 @@ int mlx4_conf_get_config(struct mlx4_dev *dev, struct pci_dev *pdev)
 	if (!pdev_group)
 		return -ENOENT;
 
+	pdev_cfg = to_pdev_config(&pdev_group->cg_item);
+	mlx4_config->dmfs_mode = pdev_cfg->dmfs_mode;
+
 	ports_group = mlx4_get_config_group(pdev_group, MLX4_CONFIGFS_PORTS);
 	if (!ports_group) {
 		config_item_put(&pdev_group->cg_item);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index b3a42c8..cb40f0e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1842,7 +1842,15 @@ static const char *dmfs_high_rate_steering_mode_str(int dmfs_high_steer_mode)
 static void choose_steering_mode(struct mlx4_dev *dev,
 				 struct mlx4_dev_cap *dev_cap)
 {
-	if (mlx4_log_num_mgm_entry_size <= 0) {
+	if (dev->persist->mlx4_config.dmfs_mode == MLX4_DMFS_MODE_STATIC_A0) {
+		if (dev->caps.dmfs_high_steer_mode ==
+		    MLX4_STEERING_DMFS_A0_NOT_SUPPORTED)
+			mlx4_err(dev, "DMFS high rate mode not supported\n");
+		else
+			dev->caps.dmfs_high_steer_mode =
+				MLX4_STEERING_DMFS_A0_STATIC;
+
+	} else if (mlx4_log_num_mgm_entry_size <= 0) {
 		if ((-mlx4_log_num_mgm_entry_size) & MLX4_DMFS_A0_STEERING) {
 			if (dev->caps.dmfs_high_steer_mode ==
 			    MLX4_STEERING_DMFS_A0_NOT_SUPPORTED)
@@ -1853,7 +1861,8 @@ static void choose_steering_mode(struct mlx4_dev *dev,
 		}
 	}
 
-	if (mlx4_log_num_mgm_entry_size <= 0 &&
+	if ((mlx4_log_num_mgm_entry_size <= 0 ||
+	     dev->persist->mlx4_config.dmfs_mode) &&
 	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_FS_EN &&
 	    (!mlx4_is_mfunc(dev) ||
 	     (dev_cap->fs_max_num_qp_per_entry >=
@@ -1886,10 +1895,14 @@ static void choose_steering_mode(struct mlx4_dev *dev,
 			MLX4_DEFAULT_MGM_LOG_ENTRY_SIZE;
 		dev->caps.num_qp_per_mgm = mlx4_get_qp_per_mgm(dev);
 	}
-	mlx4_dbg(dev, "Steering mode is: %s, oper_log_mgm_entry_size = %d, modparam log_num_mgm_entry_size = %d\n",
-		 mlx4_steering_mode_str(dev->caps.steering_mode),
-		 dev->oper_log_mgm_entry_size,
-		 mlx4_log_num_mgm_entry_size);
+
+	mlx4_info(dev, "Steering mode is: %s %s, oper_log_mgm_entry_size = %d, modparam log_num_mgm_entry_size = %d\n",
+		  mlx4_steering_mode_str(dev->caps.steering_mode),
+		  (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED) ?
+		  dmfs_high_rate_steering_mode_str(dev->caps.dmfs_high_steer_mode) : "",
+		  dev->oper_log_mgm_entry_size,
+		  mlx4_log_num_mgm_entry_size);
+
 }
 
 static void choose_tunnel_offload_mode(struct mlx4_dev *dev,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index aad3db4..2ef902d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1455,6 +1455,7 @@ struct ports_config {
 struct pdev_config {
 	struct config_group group;
 	struct pci_dev *pdev;
+	int dmfs_mode;
 	int commit;
 };
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e86ccc1..f152039 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -126,6 +126,12 @@ enum {
 	MLX4_STEERING_DMFS_A0_NOT_SUPPORTED
 };
 
+enum {
+	MLX4_DMFS_MODE_DISABLE,
+	MLX4_DMFS_MODE_ETH_IPOIB,
+	MLX4_DMFS_MODE_STATIC_A0,
+};
+
 static inline const char *mlx4_steering_mode_str(int steering_mode)
 {
 	switch (steering_mode) {
@@ -777,6 +783,7 @@ struct mlx4_vf_dev {
 };
 
 struct mlx4_conf {
+	int dmfs_mode;
 	int port_type[MLX4_MAX_PORTS + 1];
 };
 
-- 
1.9.3
