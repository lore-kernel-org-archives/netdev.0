From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 2/3] net/mlx4_core: Set port_type value according to configfs configuration
Date: Wed, 11 Mar 2015 11:08:52 +0200
Message-ID: <1426064933-29072-3-git-send-email-amirv@mellanox.com>
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
Received: from mailp.voltaire.com ([193.47.165.129]:48139 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751694AbbCKJKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 05:10:05 -0400
In-Reply-To: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

port_type_array is a module parameter which sets mlx4_core ports type.
Since module parameter can't be set per device, few Mellanox NICs using
the same driver, will have to be configured with the same ports type.

Using the new mlx4_core configfs infrastructure allows setting different
ports type per device. Port type attribute can take 2 strings "ib" or
"eth".

In case the configfs configuration is missing, the ports type of each
device will be set as before, according to port_type_array value.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/conf.c | 203 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c |  11 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |  23 ++++
 include/linux/mlx4/device.h               |   5 +
 4 files changed, 241 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/conf.c b/drivers/net/ethernet/mellanox/mlx4/conf.c
index abbe18a..678979a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/conf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/conf.c
@@ -57,6 +57,33 @@
  *
  **/
 
+/* Defines item_ops and group_ops for 'struct_in'
+ * Creates new group type 'new_memeber'
+ */
+#define MLX4_CONFIG_GROUPS(struct_in, new_member)			\
+	static struct config_group *					\
+	struct_in##_make_group(struct config_group *group,		\
+				const char *name)			\
+	{								\
+	struct new_member *new;						\
+									\
+	if (new_member##_verify_name(to_##struct_in(&group->cg_item), name))\
+		return ERR_PTR(-EINVAL);				\
+									\
+	new = kzalloc(sizeof(*new), GFP_KERNEL);			\
+	if (!new)							\
+		return ERR_PTR(-ENOMEM);				\
+									\
+	config_group_init_type_name(&new->group, name,			\
+				    &new_member##_item_type);		\
+									\
+	return &new->group;						\
+}									\
+									\
+static struct configfs_group_operations struct_in##_group_ops = {	\
+	.make_group     = &struct_in##_make_group,			\
+}									\
+
 #define MLX4_CFG_CONFIGFS_ATTR(struct_name, name)			\
 	static struct struct_name##_attribute struct_name##_##name =	\
 		__CONFIGFS_ATTR(name,  S_IRUGO | S_IWUSR,		\
@@ -75,10 +102,139 @@ static struct configfs_item_operations struct_in##_item_ops = {		\
 									\
 static struct config_item_type struct_in##_item_type = {		\
 	.ct_item_ops	= &struct_in##_item_ops,			\
+	.ct_group_ops   = &struct_in##_group_ops,			\
 	.ct_attrs	= struct_in##_attrs,				\
 	.ct_owner	= THIS_MODULE,					\
 }
 
+static ssize_t port_config_type_store(struct port_config *port_cfg,
+				      const char *page, size_t len)
+{
+	struct config_item *item = port_cfg->group.cg_item.ci_parent->ci_parent;
+	struct pdev_config *pdev_cfg = to_pdev_config(item);
+	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev_cfg->pdev);
+	struct mlx4_dev *dev = persist->dev;
+	unsigned long port;
+	int err;
+
+	err = kstrtoul(port_cfg->group.cg_item.ci_name, 10, &port);
+	if (err)
+		return -EINVAL;
+
+	if (!strcmp(page, "ib\n")) {
+		if (dev->caps.supported_type[port] & MLX4_PORT_TYPE_IB)
+			port_cfg->type = MLX4_PORT_TYPE_IB;
+		else
+			goto out_err;
+	} else if (!strcmp(page, "eth\n")) {
+		if (dev->caps.supported_type[port] & MLX4_PORT_TYPE_ETH)
+			port_cfg->type = MLX4_PORT_TYPE_ETH;
+		else
+			goto out_err;
+	} else {
+		pr_err("mlx4_core %s: Unsupported port type: %s, use 'ib' or 'eth'\n",
+		       item->ci_name, page);
+		return -EINVAL;
+	}
+	return len;
+
+out_err:
+	pr_err("mlx4_core %s: port type %s isn't supported.\n",
+	       item->ci_name, page);
+	return -EINVAL;
+}
+
+static ssize_t port_config_type_show(struct port_config *port_cfg, char *page)
+{
+	if (port_cfg->type == MLX4_PORT_TYPE_IB)
+		return sprintf(page, "%s\n", "ib");
+	else if (port_cfg->type == MLX4_PORT_TYPE_ETH)
+		return sprintf(page, "%s\n", "eth");
+	else if (port_cfg->type == MLX4_PORT_TYPE_AUTO)
+		return sprintf(page, "%s\n", "auto");
+	else if (port_cfg->type == MLX4_PORT_TYPE_NONE)
+		return sprintf(page, "%s\n", "port type wasn't set");
+	else
+		return sprintf(page, "%s\n", "unsupported port type");
+}
+
+CONFIGFS_ATTR_STRUCT(port_config);
+CONFIGFS_ATTR_OPS(port_config);
+MLX4_CFG_CONFIGFS_ATTR(port_config, type);
+
+static struct configfs_group_operations port_config_group_ops = {
+	NULL,
+};
+
+static struct configfs_attribute *port_config_attrs[] = {
+	&port_config_type.attr,
+	NULL,
+};
+
+static void port_config_release(struct config_item *item)
+{
+	kfree(to_port_config(item));
+}
+
+MLX4_CONFIG_ITEM_TYPE(port_config);
+
+static int port_config_verify_name(struct ports_config *ports_cfg,
+				   const char *name)
+{
+	struct config_item *pdev_item;
+	struct pdev_config *pdev_cfg;
+	struct mlx4_dev_persistent *persist;
+
+	pdev_item = ports_cfg->group.cg_item.ci_parent;
+
+	pdev_cfg = to_pdev_config(pdev_item);
+	persist = pci_get_drvdata(pdev_cfg->pdev);
+
+	if (!strcmp(name, "1")) {
+		return 0;
+	} else if (!strcmp(name, "2")) {
+		if (persist->dev->caps.num_ports == MLX4_MAX_PORTS)
+			return 0;
+		if (persist->dev->caps.num_ports != MLX4_MAX_PORTS)
+			pr_err("mlx4_core %s: Invalid directory name: %s, device has only one port\n",
+			       pdev_cfg->group.cg_item.ci_name, name);
+	} else {
+		pr_err("mlx4_core %s: Invalid directory name: %s, Directory name should be '1' or '2'.\n",
+		       pdev_cfg->group.cg_item.ci_name, name);
+	}
+	return -EINVAL;
+}
+
+MLX4_CONFIG_GROUPS(ports_config, port_config);
+
+static void ports_config_release(struct config_item *item)
+{
+	kfree(to_ports_config(item));
+}
+
+static struct configfs_item_operations ports_config_item_ops = {
+	.release		= ports_config_release,
+};
+
+static struct config_item_type ports_config_item_type = {
+	.ct_item_ops    = &ports_config_item_ops,
+	.ct_group_ops   = &ports_config_group_ops,
+	.ct_owner       = THIS_MODULE,
+};
+
+static int ports_config_verify_name(struct pdev_config *pdev_cfg,
+				    const char *name)
+{
+	char *pdev_name = pdev_cfg->group.cg_item.ci_name;
+
+	if (strcmp(name, MLX4_CONFIGFS_PORTS)) {
+		pr_err("mlx4_core %s: Invalid directory name: %s, directory name should be %s.\n",
+		       pdev_name, name, MLX4_CONFIGFS_PORTS);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static ssize_t pdev_config_commit_store(struct pdev_config *cfg,
 					const char *page, size_t len)
 {
@@ -139,6 +295,7 @@ static struct configfs_attribute *pdev_config_attrs[] = {
 	NULL,
 };
 
+MLX4_CONFIG_GROUPS(pdev_config, ports_config);
 MLX4_CONFIG_ITEM_TYPE(pdev_config);
 
 static struct pci_dev *find_pdev_by_name(const char *name)
@@ -233,6 +390,18 @@ out_err:
 	return ERR_PTR(err);
 }
 
+static struct config_group *mlx4_get_config_group(struct config_group *group,
+						  const char *name)
+{
+	struct config_item *item = NULL;
+
+	mutex_lock(&group->cg_subsys->su_mutex);
+	item = config_group_find_item(group, name);
+	mutex_unlock(&group->cg_subsys->su_mutex);
+
+	return to_config_group(item);
+}
+
 static struct config_group *device_driver_make(struct config_group *group,
 					       const char *name)
 {
@@ -257,6 +426,40 @@ static struct configfs_subsystem mlx4_subsys = {
 	},
 };
 
+int mlx4_conf_get_config(struct mlx4_dev *dev, struct pci_dev *pdev)
+{
+#define PORT_NAME_SIZE 2
+	struct config_group *pdev_group, *ports_group, *port_group;
+	char port_num[PORT_NAME_SIZE];
+	struct port_config *port_cfg;
+	int i;
+	struct mlx4_conf *mlx4_config = &dev->persist->mlx4_config;
+
+	pdev_group = mlx4_get_config_group(&mlx4_subsys.su_group,
+					   pci_name(pdev));
+	if (!pdev_group)
+		return -ENOENT;
+
+	ports_group = mlx4_get_config_group(pdev_group, MLX4_CONFIGFS_PORTS);
+	if (!ports_group) {
+		config_item_put(&pdev_group->cg_item);
+		return 0;
+	}
+
+	for (i = 1; i < (MLX4_MAX_PORTS + 1); i++) {
+		snprintf(port_num, PORT_NAME_SIZE, "%d", i);
+		port_group = mlx4_get_config_group(ports_group, port_num);
+		if (port_group) {
+			port_cfg = to_port_config(&port_group->cg_item);
+			mlx4_config->port_type[i] = port_cfg->type;
+			config_item_put(&port_group->cg_item);
+		}
+	}
+	config_item_put(&ports_group->cg_item);
+	config_item_put(&pdev_group->cg_item);
+	return 0;
+}
+
 int mlx4_configfs_init(void)
 {
 	int ret;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index c81217e..b3a42c8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -415,7 +415,10 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 				/* if IB and ETH are supported, we set the port
 				 * type according to user selection of port type;
 				 * if user selected none, take the FW hint */
-				if (port_type_array[i - 1] == MLX4_PORT_TYPE_NONE)
+				if (dev->persist->mlx4_config.port_type[i])
+					dev->caps.port_type[i] =
+						dev->persist->mlx4_config.port_type[i];
+				else if (port_type_array[i - 1] == MLX4_PORT_TYPE_NONE)
 					dev->caps.port_type[i] = dev->caps.suggested_type[i] ?
 						MLX4_PORT_TYPE_ETH : MLX4_PORT_TYPE_IB;
 				else
@@ -2735,6 +2738,12 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 	dev->rev_id = pdev->revision;
 	dev->numa_node = dev_to_node(&pdev->dev);
 
+#if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+	err = mlx4_conf_get_config(dev, pdev);
+	if (!err)
+		mlx4_info(dev, "Using device configuration from configfs.\n");
+#endif
+
 	/* Detect if this device is a virtual function */
 	if (pci_dev_data & MLX4_PCI_DEV_IS_VF) {
 		mlx4_warn(dev, "Detected virtual function - running in slave mode\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index ee43c0a..aad3db4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1441,6 +1441,17 @@ u32 mlx4_zone_free_entries_unique(struct mlx4_zone_allocator *zones, u32 obj, u3
 struct mlx4_bitmap *mlx4_zone_get_bitmap(struct mlx4_zone_allocator *zones, u32 uid);
 
 #if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+#define MLX4_CONFIGFS_PORTS "ports"
+
+struct port_config {
+	struct config_group group;
+	int type;
+};
+
+struct ports_config {
+	struct config_group group;
+};
+
 struct pdev_config {
 	struct config_group group;
 	struct pci_dev *pdev;
@@ -1453,6 +1464,18 @@ static inline struct pdev_config *to_pdev_config(struct config_item *item)
 				   struct pdev_config, group) : NULL;
 }
 
+static inline struct ports_config *to_ports_config(struct config_item *item)
+{
+	return item ? container_of(to_config_group(item),
+				   struct ports_config, group) : NULL;
+}
+
+static inline struct port_config *to_port_config(struct config_item *item)
+{
+	return item ? container_of(to_config_group(item),
+				   struct port_config, group) : NULL;
+}
+
 int mlx4_configfs_init(void);
 void mlx4_configfs_exit(void);
 int mlx4_conf_get_config(struct mlx4_dev *dev, struct pci_dev *pdev);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1cc5482..e86ccc1 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -776,6 +776,10 @@ struct mlx4_vf_dev {
 	u8			n_ports;
 };
 
+struct mlx4_conf {
+	int port_type[MLX4_MAX_PORTS + 1];
+};
+
 struct mlx4_dev_persistent {
 	struct pci_dev	       *pdev;
 	struct mlx4_dev	       *dev;
@@ -789,6 +793,7 @@ struct mlx4_dev_persistent {
 	u8		state;
 	struct mutex	interface_state_mutex; /* protect SW state */
 	u8	interface_state;
+	struct mlx4_conf	mlx4_config;
 };
 
 struct mlx4_dev {
-- 
1.9.3
