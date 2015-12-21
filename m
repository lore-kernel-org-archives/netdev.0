From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: core: Allow to reset temperature history via hwmon interface
Date: Mon, 21 Dec 2015 11:14:21 +0100
Message-ID: <1450692861-2567-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37924 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbbLUKOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 05:14:24 -0500
Received: by mail-wm0-f52.google.com with SMTP id l126so62922535wml.1
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 02:14:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add another sysfs hwmon attribute to expose possibility to reset
temperature sensors history.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 37 +++++++++++++++++++++++-
 1 file changed, 36 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
index b86db96..00ccf1c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -49,7 +49,7 @@ struct mlxsw_hwmon_attr {
 	struct device_attribute dev_attr;
 	struct mlxsw_hwmon *hwmon;
 	unsigned int type_index;
-	char name[16];
+	char name[32];
 };
 
 struct mlxsw_hwmon {
@@ -107,6 +107,32 @@ static ssize_t mlxsw_hwmon_temp_max_show(struct device *dev,
 	return sprintf(buf, "%u\n", temp_max);
 }
 
+static ssize_t mlxsw_hwmon_temp_rst_store(struct device *dev,
+					  struct device_attribute *attr,
+					  const char *buf, size_t len)
+{
+	struct mlxsw_hwmon_attr *mlwsw_hwmon_attr =
+			container_of(attr, struct mlxsw_hwmon_attr, dev_attr);
+	struct mlxsw_hwmon *mlxsw_hwmon = mlwsw_hwmon_attr->hwmon;
+	char mtmp_pl[MLXSW_REG_MTMP_LEN];
+	unsigned long val;
+	int err;
+
+	err = kstrtoul(buf, 10, &val);
+	if (err)
+		return err;
+	if (val != 1)
+		return -EINVAL;
+
+	mlxsw_reg_mtmp_pack(mtmp_pl, mlwsw_hwmon_attr->type_index, true, true);
+	err = mlxsw_reg_write(mlxsw_hwmon->core, MLXSW_REG(mtmp), mtmp_pl);
+	if (err) {
+		dev_err(mlxsw_hwmon->bus_info->dev, "Failed to reset temp sensor history\n");
+		return err;
+	}
+	return err ? err : len;
+}
+
 static ssize_t mlxsw_hwmon_fan_rpm_show(struct device *dev,
 					struct device_attribute *attr,
 					char *buf)
@@ -175,6 +201,7 @@ static ssize_t mlxsw_hwmon_pwm_store(struct device *dev,
 enum mlxsw_hwmon_attr_type {
 	MLXSW_HWMON_ATTR_TYPE_TEMP,
 	MLXSW_HWMON_ATTR_TYPE_TEMP_MAX,
+	MLXSW_HWMON_ATTR_TYPE_TEMP_RST,
 	MLXSW_HWMON_ATTR_TYPE_FAN_RPM,
 	MLXSW_HWMON_ATTR_TYPE_PWM,
 };
@@ -201,6 +228,12 @@ static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
 		snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
 			 "temp%u_highest", num + 1);
 		break;
+	case MLXSW_HWMON_ATTR_TYPE_TEMP_RST:
+		mlxsw_hwmon_attr->dev_attr.store = mlxsw_hwmon_temp_rst_store;
+		mlxsw_hwmon_attr->dev_attr.attr.mode = S_IWUSR;
+		snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
+			 "temp%u_reset_history", num + 1);
+		break;
 	case MLXSW_HWMON_ATTR_TYPE_FAN_RPM:
 		mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_fan_rpm_show;
 		mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
@@ -254,6 +287,8 @@ static int mlxsw_hwmon_temp_init(struct mlxsw_hwmon *mlxsw_hwmon)
 				     MLXSW_HWMON_ATTR_TYPE_TEMP, i, i);
 		mlxsw_hwmon_attr_add(mlxsw_hwmon,
 				     MLXSW_HWMON_ATTR_TYPE_TEMP_MAX, i, i);
+		mlxsw_hwmon_attr_add(mlxsw_hwmon,
+				     MLXSW_HWMON_ATTR_TYPE_TEMP_RST, i, i);
 	}
 	return 0;
 }
-- 
1.9.3
