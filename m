From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 6/6] mlx4: Implement port type setting via devlink interface
Date: Wed,  3 Feb 2016 11:48:02 +0100
Message-ID: <1454496482-13961-7-git-send-email-jiri@resnulli.us>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34885 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbcBCKsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:48:13 -0500
Received: by mail-wm0-f53.google.com with SMTP id r129so158618486wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:48:12 -0800 (PST)
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

So far, there has been an mlx4-specific sysfs file allowing user to
change port type to either Ethernet of InfiniBand. This is very
inconvenient.

Allow to expose the same ability to set port type in a generic way
using devlink interface.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 86 +++++++++++++++++++++++--------
 1 file changed, 65 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index a5f54a5..4bac714 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1052,36 +1052,20 @@ static ssize_t show_port_type(struct device *dev,
 	return strlen(buf);
 }
 
-static ssize_t set_port_type(struct device *dev,
-			     struct device_attribute *attr,
-			     const char *buf, size_t count)
+static int __set_port_type(struct mlx4_port_info *info,
+			   enum mlx4_port_type port_type)
 {
-	struct mlx4_port_info *info = container_of(attr, struct mlx4_port_info,
-						   port_attr);
 	struct mlx4_dev *mdev = info->dev;
 	struct mlx4_priv *priv = mlx4_priv(mdev);
 	enum mlx4_port_type types[MLX4_MAX_PORTS];
 	enum mlx4_port_type new_types[MLX4_MAX_PORTS];
-	static DEFINE_MUTEX(set_port_type_mutex);
 	int i;
 	int err = 0;
 
-	mutex_lock(&set_port_type_mutex);
-
-	if (!strcmp(buf, "ib\n"))
-		info->tmp_type = MLX4_PORT_TYPE_IB;
-	else if (!strcmp(buf, "eth\n"))
-		info->tmp_type = MLX4_PORT_TYPE_ETH;
-	else if (!strcmp(buf, "auto\n"))
-		info->tmp_type = MLX4_PORT_TYPE_AUTO;
-	else {
-		mlx4_err(mdev, "%s is not supported port type\n", buf);
-		err = -EINVAL;
-		goto err_out;
-	}
-
 	mlx4_stop_sense(mdev);
 	mutex_lock(&priv->port_mutex);
+	info->tmp_type = port_type;
+
 	/* Possible type is always the one that was delivered */
 	mdev->caps.possible_type[info->port] = info->tmp_type;
 
@@ -1123,6 +1107,37 @@ static ssize_t set_port_type(struct device *dev,
 out:
 	mlx4_start_sense(mdev);
 	mutex_unlock(&priv->port_mutex);
+
+	return err;
+}
+
+static ssize_t set_port_type(struct device *dev,
+			     struct device_attribute *attr,
+			     const char *buf, size_t count)
+{
+	struct mlx4_port_info *info = container_of(attr, struct mlx4_port_info,
+						   port_attr);
+	struct mlx4_dev *mdev = info->dev;
+	enum mlx4_port_type port_type;
+	static DEFINE_MUTEX(set_port_type_mutex);
+	int err;
+
+	mutex_lock(&set_port_type_mutex);
+
+	if (!strcmp(buf, "ib\n")) {
+		port_type = MLX4_PORT_TYPE_IB;
+	} else if (!strcmp(buf, "eth\n")) {
+		port_type = MLX4_PORT_TYPE_ETH;
+	} else if (!strcmp(buf, "auto\n")) {
+		port_type = MLX4_PORT_TYPE_AUTO;
+	} else {
+		mlx4_err(mdev, "%s is not supported port type\n", buf);
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	err = __set_port_type(info, port_type);
+
 err_out:
 	mutex_unlock(&set_port_type_mutex);
 
@@ -3651,6 +3666,35 @@ err_disable_pdev:
 	return err;
 }
 
+static int mlx4_devlink_port_type_set(struct devlink_port *devlink_port,
+				      enum devlink_port_type port_type)
+{
+	struct mlx4_port_info *info = container_of(devlink_port,
+						   struct mlx4_port_info,
+						   devlink_port);
+	enum mlx4_port_type mlx4_port_type;
+
+	switch (port_type) {
+	case DEVLINK_PORT_TYPE_AUTO:
+		mlx4_port_type = MLX4_PORT_TYPE_AUTO;
+		break;
+	case DEVLINK_PORT_TYPE_ETH:
+		mlx4_port_type = MLX4_PORT_TYPE_ETH;
+		break;
+	case DEVLINK_PORT_TYPE_IB:
+		mlx4_port_type = MLX4_PORT_TYPE_IB;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return __set_port_type(info, mlx4_port_type);
+}
+
+static const struct devlink_ops mlx4_devlink_ops = {
+	.port_type_set	= mlx4_devlink_port_type_set,
+};
+
 static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct devlink *devlink;
@@ -3660,7 +3704,7 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	printk_once(KERN_INFO "%s", mlx4_version);
 
-	devlink = devlink_alloc(NULL, sizeof(*priv));
+	devlink = devlink_alloc(&mlx4_devlink_ops, sizeof(*priv));
 	if (!devlink)
 		return -ENOMEM;
 	priv = devlink_priv(devlink);
-- 
1.9.3
