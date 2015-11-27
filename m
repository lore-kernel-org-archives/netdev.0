From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/6] mlxsw: core: Implement temperature hwmon interface
Date: Fri, 27 Nov 2015 13:45:57 +0100
Message-ID: <1448628359-20077-5-git-send-email-jiri@resnulli.us>
References: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34495 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbK0MqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 07:46:08 -0500
Received: by wmvv187 with SMTP id v187so69449604wmv.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 04:46:07 -0800 (PST)
In-Reply-To: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

ASIC provides access to temperature sensors. Implement their exposure to
userspace using hwmon.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- fixed hwmon compile error when it is not set reported by lkp@intel.com
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig      |   8 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/core.c       |   8 +
 drivers/net/ethernet/mellanox/mlxsw/core.h       |  24 +++
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 223 +++++++++++++++++++++++
 5 files changed, 264 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index e36e122..ec8caf8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -10,6 +10,14 @@ config MLXSW_CORE
 	  To compile this driver as a module, choose M here: the
 	  module will be called mlxsw_core.
 
+config MLXSW_CORE_HWMON
+	bool "HWMON support for Mellanox Technologies Switch ASICs"
+	depends on MLXSW_CORE && HWMON
+	depends on !(MLXSW_CORE=y && HWMON=m)
+	default y
+	---help---
+	  Say Y here if you want to expose HWMON interface on mlxsw devices.
+
 config MLXSW_PCI
 	tristate "PCI bus implementation for Mellanox Technologies Switch ASICs"
 	depends on PCI && HAS_DMA && HAS_IOMEM && MLXSW_CORE
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index af01581..584cac4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_MLXSW_CORE)	+= mlxsw_core.o
 mlxsw_core-objs			:= core.o
+mlxsw_core-$(CONFIG_MLXSW_CORE_HWMON) += core_hwmon.o
 obj-$(CONFIG_MLXSW_PCI)		+= mlxsw_pci.o
 mlxsw_pci-objs			:= pci.o
 obj-$(CONFIG_MLXSW_SWITCHX2)	+= mlxsw_switchx2.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 97f0d93..1ecb4aa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -105,6 +105,7 @@ struct mlxsw_core {
 		struct debugfs_blob_wrapper vsd_blob;
 		struct debugfs_blob_wrapper psid_blob;
 	} dbg;
+	struct mlxsw_hwmon *hwmon;
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
 };
@@ -822,6 +823,10 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_emad_init;
 
+	err = mlxsw_hwmon_init(mlxsw_core, mlxsw_bus_info, &mlxsw_core->hwmon);
+	if (err)
+		goto err_hwmon_init;
+
 	err = mlxsw_driver->init(mlxsw_core->driver_priv, mlxsw_core,
 				 mlxsw_bus_info);
 	if (err)
@@ -836,6 +841,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_debugfs_init:
 	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
 err_driver_init:
+	mlxsw_hwmon_fini(mlxsw_core->hwmon);
+err_hwmon_init:
 	mlxsw_emad_fini(mlxsw_core);
 err_emad_init:
 	mlxsw_bus->fini(bus_priv);
@@ -855,6 +862,7 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 
 	mlxsw_core_debugfs_fini(mlxsw_core);
 	mlxsw_core->driver->fini(mlxsw_core->driver_priv);
+	mlxsw_hwmon_fini(mlxsw_core->hwmon);
 	mlxsw_emad_fini(mlxsw_core);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	free_percpu(mlxsw_core->pcpu_stats);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 8078273..5ac9529 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -209,4 +209,28 @@ struct mlxsw_bus_info {
 	u8 psid[MLXSW_CMD_BOARDINFO_PSID_LEN];
 };
 
+struct mlxsw_hwmon;
+
+#ifdef CONFIG_MLXSW_CORE_HWMON
+
+int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
+		     const struct mlxsw_bus_info *mlxsw_bus_info,
+		     struct mlxsw_hwmon **p_hwmon);
+void mlxsw_hwmon_fini(struct mlxsw_hwmon *mlxsw_hwmon);
+
+#else
+
+static inline int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
+				   const struct mlxsw_bus_info *mlxsw_bus_info,
+				   struct mlxsw_hwmon **p_hwmon)
+{
+	return 0;
+}
+
+static inline void mlxsw_hwmon_fini(struct mlxsw_hwmon *mlxsw_hwmon)
+{
+}
+
+#endif
+
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
new file mode 100644
index 0000000..ec48c28
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -0,0 +1,223 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/device.h>
+#include <linux/sysfs.h>
+#include <linux/hwmon.h>
+#include <linux/err.h>
+
+#include "core.h"
+
+#define MLXSW_HWMON_TEMP_SENSOR_MAX_COUNT 127
+#define MLXSW_HWMON_ATTR_COUNT (MLXSW_HWMON_TEMP_SENSOR_MAX_COUNT * 4)
+
+struct mlxsw_hwmon_attr {
+	struct device_attribute dev_attr;
+	struct mlxsw_hwmon *hwmon;
+	unsigned int type_index;
+	char name[16];
+};
+
+struct mlxsw_hwmon {
+	struct mlxsw_core *core;
+	const struct mlxsw_bus_info *bus_info;
+	struct device *hwmon_dev;
+	struct attribute_group group;
+	const struct attribute_group *groups[2];
+	struct attribute *attrs[MLXSW_HWMON_ATTR_COUNT + 1];
+	struct mlxsw_hwmon_attr hwmon_attrs[MLXSW_HWMON_ATTR_COUNT];
+	unsigned int attrs_count;
+};
+
+static ssize_t mlxsw_hwmon_temp_show(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct mlxsw_hwmon_attr *mlwsw_hwmon_attr =
+			container_of(attr, struct mlxsw_hwmon_attr, dev_attr);
+	struct mlxsw_hwmon *mlxsw_hwmon = mlwsw_hwmon_attr->hwmon;
+	char mtmp_pl[MLXSW_REG_MTMP_LEN];
+	unsigned int temp;
+	int err;
+
+	mlxsw_reg_mtmp_pack(mtmp_pl, mlwsw_hwmon_attr->type_index,
+			    false, false);
+	err = mlxsw_reg_query(mlxsw_hwmon->core, MLXSW_REG(mtmp), mtmp_pl);
+	if (err) {
+		dev_err(mlxsw_hwmon->bus_info->dev, "Failed to query temp sensor\n");
+		return err;
+	}
+	mlxsw_reg_mtmp_unpack(mtmp_pl, &temp, NULL, NULL);
+	return sprintf(buf, "%u\n", temp);
+}
+
+static ssize_t mlxsw_hwmon_temp_max_show(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct mlxsw_hwmon_attr *mlwsw_hwmon_attr =
+			container_of(attr, struct mlxsw_hwmon_attr, dev_attr);
+	struct mlxsw_hwmon *mlxsw_hwmon = mlwsw_hwmon_attr->hwmon;
+	char mtmp_pl[MLXSW_REG_MTMP_LEN];
+	unsigned int temp_max;
+	int err;
+
+	mlxsw_reg_mtmp_pack(mtmp_pl, mlwsw_hwmon_attr->type_index,
+			    false, false);
+	err = mlxsw_reg_query(mlxsw_hwmon->core, MLXSW_REG(mtmp), mtmp_pl);
+	if (err) {
+		dev_err(mlxsw_hwmon->bus_info->dev, "Failed to query temp sensor\n");
+		return err;
+	}
+	mlxsw_reg_mtmp_unpack(mtmp_pl, NULL, &temp_max, NULL);
+	return sprintf(buf, "%u\n", temp_max);
+}
+
+enum mlxsw_hwmon_attr_type {
+	MLXSW_HWMON_ATTR_TYPE_TEMP,
+	MLXSW_HWMON_ATTR_TYPE_TEMP_MAX,
+};
+
+static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
+				 enum mlxsw_hwmon_attr_type attr_type,
+				 unsigned int type_index, unsigned int num) {
+	struct mlxsw_hwmon_attr *mlxsw_hwmon_attr;
+	unsigned int attr_index;
+
+	attr_index = mlxsw_hwmon->attrs_count;
+	mlxsw_hwmon_attr = &mlxsw_hwmon->hwmon_attrs[attr_index];
+
+	switch (attr_type) {
+	case MLXSW_HWMON_ATTR_TYPE_TEMP:
+		mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_show;
+		mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
+		snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
+			 "temp%u_input", num + 1);
+		break;
+	case MLXSW_HWMON_ATTR_TYPE_TEMP_MAX:
+		mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_max_show;
+		mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
+		snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
+			 "temp%u_highest", num + 1);
+		break;
+	default:
+		BUG();
+	}
+
+	mlxsw_hwmon_attr->type_index = type_index;
+	mlxsw_hwmon_attr->hwmon = mlxsw_hwmon;
+	mlxsw_hwmon_attr->dev_attr.attr.name = mlxsw_hwmon_attr->name;
+	sysfs_attr_init(&mlxsw_hwmon_attr->dev_attr.attr);
+
+	mlxsw_hwmon->attrs[attr_index] = &mlxsw_hwmon_attr->dev_attr.attr;
+	mlxsw_hwmon->attrs_count++;
+}
+
+static int mlxsw_hwmon_temp_init(struct mlxsw_hwmon *mlxsw_hwmon)
+{
+	char mtcap_pl[MLXSW_REG_MTCAP_LEN];
+	char mtmp_pl[MLXSW_REG_MTMP_LEN];
+	u8 sensor_count;
+	int i;
+	int err;
+
+	err = mlxsw_reg_query(mlxsw_hwmon->core, MLXSW_REG(mtcap), mtcap_pl);
+	if (err) {
+		dev_err(mlxsw_hwmon->bus_info->dev, "Failed to get number of temp sensors\n");
+		return err;
+	}
+	sensor_count = mlxsw_reg_mtcap_sensor_count_get(mtcap_pl);
+	for (i = 0; i < sensor_count; i++) {
+		mlxsw_reg_mtmp_pack(mtmp_pl, 0, true, true);
+		err = mlxsw_reg_write(mlxsw_hwmon->core,
+				      MLXSW_REG(mtmp), mtmp_pl);
+		if (err) {
+			dev_err(mlxsw_hwmon->bus_info->dev, "Failed to setup temp sensor number %d\n",
+				i);
+			return err;
+		}
+		mlxsw_hwmon_attr_add(mlxsw_hwmon,
+				     MLXSW_HWMON_ATTR_TYPE_TEMP, i, i);
+		mlxsw_hwmon_attr_add(mlxsw_hwmon,
+				     MLXSW_HWMON_ATTR_TYPE_TEMP_MAX, i, i);
+	}
+	return 0;
+}
+
+int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
+		     const struct mlxsw_bus_info *mlxsw_bus_info,
+		     struct mlxsw_hwmon **p_hwmon)
+{
+	struct mlxsw_hwmon *mlxsw_hwmon;
+	struct device *hwmon_dev;
+	int err;
+
+	mlxsw_hwmon = kzalloc(sizeof(*mlxsw_hwmon), GFP_KERNEL);
+	if (!mlxsw_hwmon)
+		return -ENOMEM;
+	mlxsw_hwmon->core = mlxsw_core;
+	mlxsw_hwmon->bus_info = mlxsw_bus_info;
+
+	err = mlxsw_hwmon_temp_init(mlxsw_hwmon);
+	if (err)
+		goto err_temp_init;
+
+	mlxsw_hwmon->groups[0] = &mlxsw_hwmon->group;
+	mlxsw_hwmon->group.attrs = mlxsw_hwmon->attrs;
+
+	hwmon_dev = devm_hwmon_device_register_with_groups(mlxsw_bus_info->dev,
+							   "mlxsw",
+							   mlxsw_hwmon,
+							   mlxsw_hwmon->groups);
+	if (IS_ERR(hwmon_dev)) {
+		err = PTR_ERR(hwmon_dev);
+		goto err_hwmon_register;
+	}
+
+	mlxsw_hwmon->hwmon_dev = hwmon_dev;
+	*p_hwmon = mlxsw_hwmon;
+	return 0;
+
+err_hwmon_register:
+err_temp_init:
+	kfree(mlxsw_hwmon);
+	return err;
+}
+
+void mlxsw_hwmon_fini(struct mlxsw_hwmon *mlxsw_hwmon)
+{
+	kfree(mlxsw_hwmon);
+}
-- 
1.9.3
