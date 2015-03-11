From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 1/3] net/mlx4_core: Add configfs entries for setting device specific parameters
Date: Wed, 11 Mar 2015 11:08:51 +0200
Message-ID: <1426064933-29072-2-git-send-email-amirv@mellanox.com>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Received: from mailp.voltaire.com ([193.47.165.129]:48107 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752221AbbCKJJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 05:09:56 -0400
In-Reply-To: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hadar Hen Zion <hadarh@mellanox.com>

Introducing a new mlx4_core infrastructure using the configfs to allow
set and commit specific mlx4_core low-level device configurations.

The initialization in this code creates "mlx4_core" entry in the
configfs system. After that, the user needs to use mkdir to create
configurations for specific pci device; for example "mkdir 0000:04:00.0=
".
This code will verify that such device exists and that
it is owned by mlx4_core.

Configfs Sub-tree Example:
-------------------------
$ tree  /sys/kernel/config/mlx4_core/
/sys/kernel/config/mlx4_core/
=E2=94=9C=E2=94=80=E2=94=80 0000:04:00.0
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 commit
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 dmfs_mode
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ports
=E2=94=82=C2=A0=C2=A0     =E2=94=9C=E2=94=80=E2=94=80 1
=E2=94=82=C2=A0=C2=A0     =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=
=80 type
=E2=94=82=C2=A0=C2=A0     =E2=94=94=E2=94=80=E2=94=80 2
=E2=94=82=C2=A0=C2=A0         =E2=94=94=E2=94=80=E2=94=80 type
=E2=94=94=E2=94=80=E2=94=80 0000:24:00.0
    =E2=94=9C=E2=94=80=E2=94=80 commit
    =E2=94=9C=E2=94=80=E2=94=80 dmfs_mode
    =E2=94=94=E2=94=80=E2=94=80 ports
    	=E2=94=9C=E2=94=80=E2=94=80 1
    	=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 type
    	=E2=94=94=E2=94=80=E2=94=80 2
    	    =E2=94=94=E2=94=80=E2=94=80 type

In this patch we export the 'commit' control, a control that accepts
only a value of 1 and triggers a device restart that causes the
settings to be permanently committed.

In the next coming patches we'll export low-level device
controls of mlx4_core that will be configured through the configfs.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig  |   8 +
 drivers/net/ethernet/mellanox/mlx4/Makefile |   2 +-
 drivers/net/ethernet/mellanox/mlx4/catas.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx4/conf.c   | 283 ++++++++++++++++++++=
++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c   |  40 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h   |  23 ++-
 6 files changed, 345 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/conf.c

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/e=
thernet/mellanox/mlx4/Kconfig
index 1486ce9..16eb897 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -35,6 +35,14 @@ config MLX4_CORE
 	depends on PCI
 	default n
=20
+config MLX4_CONFIGFS_FS
+	bool "Config File System Support (configfs)"
+	default y
+	depends on MLX4_CORE && CONFIGFS_FS && !(MLX4_CORE=3Dy && CONFIGFS_FS=
=3Dm)
+	---help---
+	Provides support for the configfs file system for driver configuratio=
n.
+
+
 config MLX4_DEBUG
 	bool "Verbose debugging output" if (MLX4_CORE && EXPERT)
 	depends on MLX4_CORE
diff --git a/drivers/net/ethernet/mellanox/mlx4/Makefile b/drivers/net/=
ethernet/mellanox/mlx4/Makefile
index 3e9c70f..1995873 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx4/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_MLX4_CORE)		+=3D mlx4_core.o
=20
 mlx4_core-y :=3D	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o mai=
n.o mcg.o \
-		mr.o pd.o port.o profile.o qp.o reset.o sense.o srq.o resource_track=
er.o
+		mr.o pd.o port.o profile.o qp.o reset.o sense.o srq.o resource_track=
er.o conf.o
=20
 obj-$(CONFIG_MLX4_EN)               +=3D mlx4_en.o
=20
diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/e=
thernet/mellanox/mlx4/catas.c
index 715de8a..e0ceb29 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -205,7 +205,7 @@ static void mlx4_handle_error_state(struct mlx4_dev=
_persistent *persist)
 	mutex_lock(&persist->interface_state_mutex);
 	if (persist->interface_state & MLX4_INTERFACE_STATE_UP &&
 	    !(persist->interface_state & MLX4_INTERFACE_STATE_DELETION)) {
-		err =3D mlx4_restart_one(persist->pdev);
+		err =3D mlx4_restart_one(persist->pdev, 1);
 		mlx4_info(persist->dev, "mlx4_restart_one was ended, ret=3D%d\n",
 			  err);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/conf.c b/drivers/net/et=
hernet/mellanox/mlx4/conf.c
new file mode 100644
index 0000000..abbe18a
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/conf.c
@@ -0,0 +1,283 @@
+/*
+ * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/pci.h>
+#include <linux/string.h>
+
+#include <linux/configfs.h>
+#include <linux/mlx4/device.h>
+
+#include "mlx4.h"
+
+#if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+
+/**
+ * configfs entries for mlx4_core
+ *
+ * This file adds code for configfs support for mlx4_core driver. This=
 sets
+ * up a filesystem under /sys/kernel/config in which configuration cha=
nges
+ * can be made for the driver's pci devices.
+ *
+ * The initialization of this code creates the "mlx4_core" entry in th=
e configfs
+ * system.  After that, the user needs to use mkdir to create configur=
ations
+ * for specific pci device; for example "mkdir 0000:04:00.0". This cod=
e will
+ * verify that such a device exists and that it is owned by mlx4_core.
+ *
+ **/
+
+#define MLX4_CFG_CONFIGFS_ATTR(struct_name, name)			\
+	static struct struct_name##_attribute struct_name##_##name =3D	\
+		__CONFIGFS_ATTR(name,  S_IRUGO | S_IWUSR,		\
+				struct_name##_##name##_show,		\
+				struct_name##_##name##_store)
+
+/* Defines item_ops for 'struct_in'
+ */
+#define MLX4_CONFIG_ITEM_TYPE(struct_in)				\
+									\
+static struct configfs_item_operations struct_in##_item_ops =3D {		\
+	.release                =3D struct_in##_release,			\
+	.show_attribute         =3D struct_in##_attr_show,		\
+	.store_attribute        =3D struct_in##_attr_store,		\
+};									\
+									\
+static struct config_item_type struct_in##_item_type =3D {		\
+	.ct_item_ops	=3D &struct_in##_item_ops,			\
+	.ct_attrs	=3D struct_in##_attrs,				\
+	.ct_owner	=3D THIS_MODULE,					\
+}
+
+static ssize_t pdev_config_commit_store(struct pdev_config *cfg,
+					const char *page, size_t len)
+{
+	int err;
+	unsigned long res;
+	int active_vfs =3D 0;
+	struct mlx4_dev_persistent *persist =3D pci_get_drvdata(cfg->pdev);
+	struct mlx4_dev *dev =3D persist->dev;
+	char *pdev_name =3D cfg->group.cg_item.ci_name;
+
+	err =3D kstrtoul(page, 10, &res);
+	if (err)
+		return err;
+
+	if ((res !=3D 1) && (res !=3D 0)) {
+		pr_err("mlx4_core %s: Illegal value for commit: %lu, can't apply con=
figurations.\n",
+		       pdev_name, res);
+		return -EINVAL;
+	}
+	if (res) {
+		if (mlx4_is_master(dev) && dev->flags & MLX4_FLAG_SRIOV)
+			active_vfs =3D mlx4_how_many_lives_vf(dev);
+		if (active_vfs) {
+			pr_warn("Can't restart device %s, unload active VFs before committi=
ng your changes.\n",
+				pdev_name);
+			return -EINVAL;
+
+		} else {
+			pr_warn("Restart device %s and allow setting of pre-load configurat=
ions.\n",
+				pdev_name);
+			err =3D mlx4_restart_one(cfg->pdev, 0);
+		}
+	}
+	cfg->commit =3D res;
+
+	return len;
+}
+
+static ssize_t pdev_config_commit_show(struct pdev_config *pdev_cfg, c=
har *page)
+{
+		return sprintf(page, "%d\n", pdev_cfg->commit);
+}
+
+CONFIGFS_ATTR_STRUCT(pdev_config);
+CONFIGFS_ATTR_OPS(pdev_config);
+MLX4_CFG_CONFIGFS_ATTR(pdev_config, commit);
+
+static void pdev_config_release(struct config_item *item)
+{
+	struct pdev_config *pdev_cfg =3D to_pdev_config(item);
+
+	pci_dev_put(pdev_cfg->pdev);
+	kfree(pdev_cfg);
+}
+
+static struct configfs_attribute *pdev_config_attrs[] =3D {
+	&pdev_config_commit.attr,
+	NULL,
+};
+
+MLX4_CONFIG_ITEM_TYPE(pdev_config);
+
+static struct pci_dev *find_pdev_by_name(const char *name)
+{
+	struct pci_dev *pdev;
+	char *pdev_name;
+	char *tmp_p;
+	unsigned long int domain;
+	unsigned long int bus;
+	unsigned long int dev;
+	unsigned long int func;
+	int err;
+
+	tmp_p =3D kzalloc(sizeof(*name), GFP_KERNEL);
+	if (!tmp_p)
+		return ERR_PTR(-ENOMEM);
+	strcpy(tmp_p, name);
+	pdev_name =3D tmp_p;
+
+	err =3D kstrtoul(strsep(&pdev_name, ":"), 16, &domain);
+	if (err)
+		goto format_err;
+
+	err =3D kstrtoul(strsep(&pdev_name, ":"), 16, &bus);
+	if (err)
+		goto format_err;
+
+	err =3D kstrtoul(strsep(&pdev_name, "."), 16, &dev);
+	if (err)
+		goto format_err;
+
+	err =3D kstrtoul(pdev_name, 16, &func);
+	if (err)
+		goto format_err;
+
+	pdev =3D pci_get_domain_bus_and_slot(domain, bus, (dev << 3) | func);
+	if (!pdev) {
+		pr_err("mlx4_core: Couldn't find pci device: %s\n", name);
+		err =3D -EINVAL;
+		goto out_err;
+	}
+	if (pdev->is_virtfn) {
+		pr_err("mlx4_core: Couldn't set configuration for a virtual function=
=2E bdf name %s\n",
+		       name);
+		err =3D -EINVAL;
+		pci_dev_put(pdev);
+		goto out_err;
+	}
+	if (strcmp(pdev->driver->name, DRV_NAME)) {
+		pr_err("mlx4_core: pci device %s is not mlx4 device. Can't set confi=
gurations.\n",
+		       name);
+		err =3D -EINVAL;
+		pci_dev_put(pdev);
+		goto out_err;
+	}
+
+	kfree(tmp_p);
+	return pdev;
+
+format_err:
+	pr_err("mlx4_core: Wrong pci device format: %s, use: wwww:xx:yy.x, do=
main:bus:device.function\n",
+	       name);
+out_err:
+	kfree(tmp_p);
+	return ERR_PTR(err);
+}
+
+static struct config_group *mlx4_set_config(struct config_group *group=
,
+					    const char *name)
+{
+	struct pdev_config *pdev_config;
+	struct pci_dev *pdev;
+	int err;
+
+	pdev =3D find_pdev_by_name(name);
+	if (IS_ERR(pdev))
+		return ERR_PTR(PTR_ERR(pdev));
+
+	pdev_config =3D kzalloc(sizeof(*pdev_config), GFP_KERNEL);
+	if (!pdev_config) {
+		err =3D -ENOMEM;
+		goto out_err;
+	}
+
+	config_group_init_type_name(&pdev_config->group, name,
+				    &pdev_config_item_type);
+	pdev_config->pdev =3D pdev;
+	return &pdev_config->group;
+
+out_err:
+	pci_dev_put(pdev);
+	return ERR_PTR(err);
+}
+
+static struct config_group *device_driver_make(struct config_group *gr=
oup,
+					       const char *name)
+{
+	return mlx4_set_config(group, name);
+}
+
+static struct configfs_group_operations mlx4_group_ops =3D {
+	.make_group	=3D device_driver_make,
+};
+
+static struct config_item_type mlx4_type =3D {
+	.ct_group_ops	=3D &mlx4_group_ops,
+	.ct_owner	=3D THIS_MODULE,
+};
+
+static struct configfs_subsystem mlx4_subsys =3D {
+	.su_group =3D {
+		.cg_item =3D {
+			.ci_namebuf =3D DRV_NAME,
+			.ci_type =3D &mlx4_type,
+		},
+	},
+};
+
+int mlx4_configfs_init(void)
+{
+	int ret;
+	struct configfs_subsystem *subsys =3D &mlx4_subsys;
+
+	config_group_init(&subsys->su_group);
+	mutex_init(&subsys->su_mutex);
+	ret =3D configfs_register_subsystem(subsys);
+	if (ret) {
+		pr_err("Error %d while registering subsystem %s\n",
+		       ret, subsys->su_group.cg_item.ci_namebuf);
+		return ret;
+	}
+	return 0;
+}
+
+void mlx4_configfs_exit(void)
+{
+	configfs_unregister_subsystem(&mlx4_subsys);
+}
+
+MODULE_LICENSE("GPL");
+
+#endif /* IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS) */
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/et=
hernet/mellanox/mlx4/main.c
index 7e48722..c81217e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -613,7 +613,7 @@ static void mlx4_check_pcie_caps(struct mlx4_dev *d=
ev)
 }
=20
 /*The function checks if there are live vf, return the num of them*/
-static int mlx4_how_many_lives_vf(struct mlx4_dev *dev)
+int mlx4_how_many_lives_vf(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv =3D mlx4_priv(dev);
 	struct mlx4_slave_state *s_state;
@@ -3449,7 +3449,7 @@ static int restore_current_port_types(struct mlx4=
_dev *dev,
 	return err;
 }
=20
-int mlx4_restart_one(struct pci_dev *pdev)
+int mlx4_restart_one(struct pci_dev *pdev, int restore)
 {
 	struct mlx4_dev_persistent *persist =3D pci_get_drvdata(pdev);
 	struct mlx4_dev	 *dev  =3D persist->dev;
@@ -3469,12 +3469,14 @@ int mlx4_restart_one(struct pci_dev *pdev)
 		return err;
 	}
=20
-	err =3D restore_current_port_types(dev, dev->persist->curr_port_type,
-					 dev->persist->curr_port_poss_type);
-	if (err)
-		mlx4_err(dev, "could not restore original port types (%d)\n",
-			 err);
-
+	if (restore) {
+		err =3D restore_current_port_types(dev,
+						 dev->persist->curr_port_type,
+						 dev->persist->curr_port_poss_type);
+		if (err)
+			mlx4_err(dev, "could not restore original port types (%d)\n",
+				 err);
+	}
 	return err;
 }
=20
@@ -3668,15 +3670,33 @@ static int __init mlx4_init(void)
 	if (!mlx4_wq)
 		return -ENOMEM;
=20
+#if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+	ret =3D mlx4_configfs_init();
+	if (ret)
+		goto out_wq;
+#endif
+
 	ret =3D pci_register_driver(&mlx4_driver);
 	if (ret < 0)
-		destroy_workqueue(mlx4_wq);
-	return ret < 0 ? ret : 0;
+		goto out_unregister;
+
+	return 0;
+
+out_unregister:
+#if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+	mlx4_configfs_exit();
+out_wq:
+#endif
+	destroy_workqueue(mlx4_wq);
+	return ret;
 }
=20
 static void __exit mlx4_cleanup(void)
 {
 	pci_unregister_driver(&mlx4_driver);
+#if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+	mlx4_configfs_exit();
+#endif
 	destroy_workqueue(mlx4_wq);
 }
=20
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/et=
hernet/mellanox/mlx4/mlx4.h
index 0b16db0..ee43c0a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -45,6 +45,7 @@
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
+#include <linux/configfs.h>
=20
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/driver.h>
@@ -903,6 +904,8 @@ static inline struct mlx4_priv *mlx4_priv(struct ml=
x4_dev *dev)
=20
 extern struct workqueue_struct *mlx4_wq;
=20
+int mlx4_how_many_lives_vf(struct mlx4_dev *dev);
+
 u32 mlx4_bitmap_alloc(struct mlx4_bitmap *bitmap);
 void mlx4_bitmap_free(struct mlx4_bitmap *bitmap, u32 obj, int use_rr)=
;
 u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt,
@@ -1007,7 +1010,7 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev);
 void mlx4_stop_catas_poll(struct mlx4_dev *dev);
 int mlx4_catas_init(struct mlx4_dev *dev);
 void mlx4_catas_end(struct mlx4_dev *dev);
-int mlx4_restart_one(struct pci_dev *pdev);
+int mlx4_restart_one(struct pci_dev *pdev, int restore);
 int mlx4_register_device(struct mlx4_dev *dev);
 void mlx4_unregister_device(struct mlx4_dev *dev);
 void mlx4_dispatch_event(struct mlx4_dev *dev, enum mlx4_dev_event typ=
e,
@@ -1437,4 +1440,22 @@ u32 mlx4_zone_free_entries_unique(struct mlx4_zo=
ne_allocator *zones, u32 obj, u3
 /* Returns a pointer to mlx4_bitmap that was attached to <zones> with =
<uid> */
 struct mlx4_bitmap *mlx4_zone_get_bitmap(struct mlx4_zone_allocator *z=
ones, u32 uid);
=20
+#if IS_ENABLED(CONFIG_MLX4_CONFIGFS_FS)
+struct pdev_config {
+	struct config_group group;
+	struct pci_dev *pdev;
+	int commit;
+};
+
+static inline struct pdev_config *to_pdev_config(struct config_item *i=
tem)
+{
+	return item ? container_of(to_config_group(item),
+				   struct pdev_config, group) : NULL;
+}
+
+int mlx4_configfs_init(void);
+void mlx4_configfs_exit(void);
+int mlx4_conf_get_config(struct mlx4_dev *dev, struct pci_dev *pdev);
+#endif /* CONFIG_MLX4_CONFIGFS_FS */
+
 #endif /* MLX4_H */
--=20
1.9.3
