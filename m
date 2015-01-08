From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [RFC net-next 2/3] devconf: Add configuration module for setting pre-load parameters
Date: Thu,  8 Jan 2015 17:16:59 +0200
Message-ID: <1420730220-20224-3-git-send-email-hadarh@mellanox.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, shannon.nelson@intel.com,
	Doug Ledford <dledford@redhat.com>, greearb@candelatech.com
To: "David S. Miller" <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54534 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754650AbbAHPSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 10:18:35 -0500
In-Reply-To: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introducing a new kernel infrastructure using configfs to allow the
configuration of low-level device functionality that needs to be sorted
out before a module is loaded. The suggested solution is generic and is
designed to suite any type of device.

The devconf module presented in this commit gives generic services for =
a
'dev_c_<driver name>' module. The 'dev_c_<driver name>' module will be
written by each vendor who wishes to implement a pre-load configuration
module for its driver.

Motivation and design for the devconf infrastructure is available under=
:
Documentation/filesystems/configfs/devconf.txt.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 Documentation/filesystems/configfs/devconf.txt |  135 ++++++++++++++++=
++++
 drivers/Kconfig                                |    2 +
 drivers/Makefile                               |    1 +
 drivers/devconf/Kconfig                        |    6 +
 drivers/devconf/Makefile                       |    3 +
 drivers/devconf/driver.c                       |  160 ++++++++++++++++=
++++++++
 drivers/devconf/main.c                         |  103 +++++++++++++++
 include/linux/devconf.h                        |   69 ++++++++++
 8 files changed, 479 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/filesystems/configfs/devconf.txt
 create mode 100644 drivers/devconf/Kconfig
 create mode 100644 drivers/devconf/Makefile
 create mode 100644 drivers/devconf/driver.c
 create mode 100644 drivers/devconf/main.c
 create mode 100644 include/linux/devconf.h

diff --git a/Documentation/filesystems/configfs/devconf.txt b/Documenta=
tion/filesystems/configfs/devconf.txt
new file mode 100644
index 0000000..a1b8039
--- /dev/null
+++ b/Documentation/filesystems/configfs/devconf.txt
@@ -0,0 +1,135 @@
+Configfs infrastructure for setting pre-load parameters for a module
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+When configuring a device at an early boot stage, most kernel drivers =
use
+module parameters (the parameters' settings can be determined in modpr=
obe.d
+config files.) These parameters are difficult to manage, and one of th=
e
+reasons is that module parameters are set per driver and not per devic=
e
+(NICs using the same driver cannot be set with different configuration=
s).
+Furthermore, using other existing configuration tools like ethtool, if=
config,
+ip link commands or sysfs entries is not applicable, since they all re=
ly on
+having a netdev already set up.
+
+In the past, 'request_firmware' solution for configuration parameters =
was
+suggested by Shannon Nelson from Intel[1]. The idea was rejected by Gr=
eg KH, who
+claimed it was abusive of the request_firmware mechanism. Greg suggest=
ed using
+configfs for device configuration instead (as done by the USB gadget d=
river).
+
+As a solution, we introduce a new kernel infrastructure using configfs=
 to
+allow the configuration of the device. The goal is to set low-level de=
vice
+functionality that needs to be sorted out before a module is loaded.
+
+Configfs Solution
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+The implemented configfs solution is composed of one generic module ('=
devconf')
+that can load configuration modules per driver. The devconf should be =
loaded
+at a very early boot stage, before other kernel modules are loaded (or
+compiled as in-tree). After configfs is mounted, it creates a new dire=
ctory
+under configfs, called 'devices'.
+
+In the example presented below, systemd mechanism is being used, but t=
he
+configuration can also work with older init systems.
+
+1. A systemd service, scheduled by the OS to run before kernel modules
+are loaded, creates a directory under 'devices' with the name of the d=
river.
+The devconf module will try to load a configuration module for this dr=
iver (if
+exists).
+
+2. Drivers using this mechanism will be made of two parts: a
+configuration module and the driver itself.
+
+3. Later on, when the OS loads the driver, it uses the configuration
+sub-tree.
+
+To avoid dependencies between the modules, in case the configuration m=
odule
+does not exist or is not loaded, the driver will use default values.
+
+Example
+=3D=3D=3D=3D=3D=3D=3D
+The below mlx4_core configuration file is only an example. Since the
+infrastructure is generic, each vendor can choose how to identify its =
devices
+(for example: bdf, mac address, uuid etc.).
+
+If /etc/devconf.d/mlx4_core.conf is as follows (see below), systemd se=
rvice
+will use it to run the following commands (see below).
+
+mlx4_core.conf file:
+--------------------
+[pdevs]
+	[0000:00:08.0]
+		dmfs =3D 0
+		[ports]
+			[1]
+			type =3D 2
+			[2]
+			type =3D2
+	[0000:00:04.0]
+		dmfs =3D 0
+		[ports]
+			[1]
+			type =3D 5
+			[2]
+			type =3D1
+
+Systemd commands:
+-----------------
+$ mkdir /sys/kernel/config/devices/mlx4_core
+
+devconf module will try to load dev_c_mlx4.ko
+
+$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs
+$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/
+$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/ports
+$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/ports/=
1
+$ mkdir /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/ports/=
2
+
+$ echo 5 > /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/por=
ts/1/type
+$ echo 1 > /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/por=
ts/2/type
+$ echo 0 > /sys/kernel/config/devices/mlx4_core/pdevs/0000:00:08.0/dmf=
s
+[...]
+
+dev_c_mlx4 will reject the above configuration, printing a clear messa=
ge to
+dmesg:
+"mlx4_core: Unknown port type '5' for device 0000:00:08.0. Use 0 for a=
uto,
+1 for IB and 2 for ETH"
+
+The driver configuration module validates and prepares configfs sub-tr=
ee for
+the driver itself. A configuration sub-tree for a specific module will=
 be
+created under /sys/kernel/config/devices/<driver name>, and propagated=
 from a
+configuration file on the OS (located under: /etc/devconf.d/).
+
+Configfs Sub-tree Example (for mlx4_core):
+------------------------------------------
+$ cd /sys/kernel/config/
+$ tree devices/
+devices/
+ =E2=94=94=E2=94=80=E2=94=80 mlx4_core
+     =E2=94=94=E2=94=80=E2=94=80 pdevs
+           =E2=94=9C=E2=94=80=E2=94=80 0000:00:04.0
+ 	    =E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 dmfs
+ 	    =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ports
+ 	    =E2=94=82=C2=A0=C2=A0     =E2=94=9C=E2=94=80=E2=94=80 1
+ 	    =E2=94=82=C2=A0=C2=A0     =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=
=E2=94=80 type
+ 	    =E2=94=82=C2=A0=C2=A0     =E2=94=94=E2=94=80=E2=94=80 2
+ 	    =E2=94=82=C2=A0=C2=A0 	=E2=94=94=E2=94=80=E2=94=80 type
+ 	    =E2=94=94=E2=94=80=E2=94=80 0000:00:08.0
+ 	    	=E2=94=9C=E2=94=80=E2=94=80 dmfs
+ 	    	=E2=94=94=E2=94=80=E2=94=80 ports
+ 	    	    =E2=94=9C=E2=94=80=E2=94=80 1
+ 	    	    =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 type
+ 	    	    =E2=94=94=E2=94=80=E2=94=80 2
+ 	    		=E2=94=94=E2=94=80=E2=94=80 type
+
+The systemd service that populates configfs is part of the sysinit tar=
get.
+The service is executed after mounting configfs and before udev load k=
ernel
+modules.
+
+To use devconf infrastructure, the following should be included:
+1. Devconf systemd service
+2. Configuration file in the right format under: /etc/devconf.d/
+
+This suggested solution is generic and designed to suite any type of d=
evice.
+The goal is to make this solution generic enough so all kinds of drive=
rs
+are able to use it.
+
+[1] - https://lkml.org/lkml/2013/1/10/606
diff --git a/drivers/Kconfig b/drivers/Kconfig
index 694d5a7..5a489e3 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -186,4 +186,6 @@ source "drivers/thunderbolt/Kconfig"
=20
 source "drivers/android/Kconfig"
=20
+source "drivers/devconf/Kconfig"
+
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index 67d2334..05e0d48 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -163,3 +163,4 @@ obj-$(CONFIG_RAS)		+=3D ras/
 obj-$(CONFIG_THUNDERBOLT)	+=3D thunderbolt/
 obj-$(CONFIG_CORESIGHT)		+=3D coresight/
 obj-$(CONFIG_ANDROID)		+=3D android/
+obj-$(CONFIG_DEVCONF)		+=3D devconf/
diff --git a/drivers/devconf/Kconfig b/drivers/devconf/Kconfig
new file mode 100644
index 0000000..3a98617
--- /dev/null
+++ b/drivers/devconf/Kconfig
@@ -0,0 +1,6 @@
+config DEVCONF
+	tristate "Driver configuration module"
+	depends on CONFIGFS_FS
+	default n
+	---help---
+	 Allow Setting pre-load parameters for drivers using configfs file sy=
stem.
diff --git a/drivers/devconf/Makefile b/drivers/devconf/Makefile
new file mode 100644
index 0000000..f2a5f1f
--- /dev/null
+++ b/drivers/devconf/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_DEVCONF)  +=3D devconf.o
+
+devconf-y :=3D main.o driver.o
diff --git a/drivers/devconf/driver.c b/drivers/devconf/driver.c
new file mode 100644
index 0000000..230afa6
--- /dev/null
+++ b/drivers/devconf/driver.c
@@ -0,0 +1,160 @@
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
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/err.h>
+
+#include <linux/devconf.h>
+
+static LIST_HEAD(config_drivers_list);
+static DEFINE_MUTEX(drivers_lock);
+
+static struct devconf_config_driver *find_config_driver(const char *na=
me)
+{
+	struct devconf_config_driver *cd, *tmp;
+
+	cd =3D ERR_PTR(-ENOENT);
+	mutex_lock(&drivers_lock);
+	list_for_each_entry(tmp, &config_drivers_list, list) {
+		if (strcmp(name, tmp->name))
+			continue;
+		else
+			cd =3D tmp;
+		if (!try_module_get(cd->mod)) {
+			cd =3D ERR_PTR(-EBUSY);
+			break;
+		}
+		cd->set_config_object(cd, name);
+		break;
+	}
+	mutex_unlock(&drivers_lock);
+	return cd;
+}
+
+struct devconf_config_driver *devconf_create_config_driver(const char =
*name)
+{
+	struct devconf_config_driver *cdrv;
+	int ret;
+
+	cdrv =3D find_config_driver(name);
+	if (!IS_ERR(cdrv))
+		return cdrv;
+	if (PTR_ERR(cdrv) !=3D -ENOENT)
+		return cdrv;
+	ret =3D request_module("devconf:%s", name);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	return find_config_driver(name);
+}
+
+void devconf_put_config_driver(struct devconf_config_driver *cdrv)
+{
+	struct module *mod;
+
+	if (!cdrv)
+		return;
+
+	mod =3D cdrv->mod;
+	module_put(mod);
+}
+EXPORT_SYMBOL_GPL(devconf_put_config_driver);
+
+int devconf_device_register(struct devconf_config_driver *newd)
+{
+	struct devconf_config_driver *cd;
+	int ret =3D -EEXIST;
+
+	mutex_lock(&drivers_lock);
+	list_for_each_entry(cd, &config_drivers_list, list) {
+		if (!strcmp(cd->name, newd->name))
+			goto out;
+	}
+	ret =3D 0;
+	list_add_tail(&newd->list, &config_drivers_list);
+out:
+	mutex_unlock(&drivers_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(devconf_device_register);
+
+void devconf_device_unregister(struct devconf_config_driver *cd)
+{
+	mutex_lock(&drivers_lock);
+	list_del(&cd->list);
+	mutex_unlock(&drivers_lock);
+}
+EXPORT_SYMBOL_GPL(devconf_device_unregister);
+
+struct devconf_config_driver *devconf_get_config_driver(const char *na=
me)
+{
+	struct devconf_config_driver *cd, *tmp;
+
+	cd =3D ERR_PTR(-ENOENT);
+	mutex_lock(&drivers_lock);
+	list_for_each_entry(tmp, &config_drivers_list, list) {
+		if (!strcmp(name, tmp->name)) {
+			cd =3D tmp;
+			break;
+		}
+	}
+	mutex_unlock(&drivers_lock);
+	return cd;
+}
+EXPORT_SYMBOL(devconf_get_config_driver);
+
+struct devconf_config_object
+*devconf_get_config_object(struct config_group *group, const char *nam=
e)
+{
+	struct config_item *item;
+	struct devconf_config_object *cobj;
+
+	mutex_lock(&group->cg_subsys->su_mutex);
+	item =3D config_group_find_item(group, name);
+	mutex_unlock(&group->cg_subsys->su_mutex);
+
+	cobj =3D to_config_obj(item);
+	return cobj;
+}
+EXPORT_SYMBOL(devconf_get_config_object);
+
+ssize_t devconf_get_int_attr(struct devconf_config_driver *cdrv,
+			     struct devconf_config_object *cobj,
+			     const char *param, int *value)
+{
+	if (cdrv->get_int_attr)
+		return cdrv->get_int_attr(cobj, param, value);
+	else
+		return -ENOSYS;
+}
+EXPORT_SYMBOL(devconf_get_int_attr);
diff --git a/drivers/devconf/main.c b/drivers/devconf/main.c
new file mode 100644
index 0000000..e308d4b
--- /dev/null
+++ b/drivers/devconf/main.c
@@ -0,0 +1,103 @@
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
+#include <linux/configfs.h>
+
+#include <linux/devconf.h>
+
+#define MAX_NAME_LEN	40
+
+static struct config_group *device_driver_make(struct config_group *gr=
oup,
+					       const char *name)
+{
+	struct devconf_config_driver *cdrv;
+
+	cdrv =3D devconf_create_config_driver(name);
+	if (IS_ERR(cdrv))
+		return ERR_CAST(cdrv);
+
+	return &cdrv->cobj.group;
+}
+
+static struct configfs_group_operations devices_group_ops =3D {
+	.make_group	=3D device_driver_make,
+};
+
+static struct config_item_type devices_type =3D {
+	.ct_group_ops	=3D &devices_group_ops,
+	.ct_owner	=3D THIS_MODULE,
+};
+
+static struct configfs_subsystem devices_subsys =3D {
+	.su_group =3D {
+		.cg_item =3D {
+			.ci_namebuf =3D "devices",
+			.ci_type =3D &devices_type,
+		},
+	},
+};
+
+static int __init devconf_init(void)
+{
+	int ret;
+	struct configfs_subsystem *subsys =3D &devices_subsys;
+
+	config_group_init(&subsys->su_group);
+	mutex_init(&subsys->su_mutex);
+	ret =3D configfs_register_subsystem(subsys);
+	if (ret) {
+		pr_err("Error %d while registering subsystem %s\n",
+		       ret,
+		       subsys->su_group.cg_item.ci_namebuf);
+		goto out_unregister;
+	}
+	return 0;
+
+out_unregister:
+	configfs_unregister_subsystem(subsys);
+
+	return ret;
+}
+
+static void __exit devconf_exit(void)
+{
+	struct configfs_subsystem *subsys =3D &devices_subsys;
+
+	configfs_unregister_subsystem(subsys);
+}
+
+module_init(devconf_init);
+module_exit(devconf_exit);
+MODULE_LICENSE("GPL");
diff --git a/include/linux/devconf.h b/include/linux/devconf.h
new file mode 100644
index 0000000..ce78662
--- /dev/null
+++ b/include/linux/devconf.h
@@ -0,0 +1,69 @@
+#ifndef	__LINUX_DEVCONF_H
+#define	__LINUX_DEVCONF_H
+#include <linux/configfs.h>
+
+struct devconf_config_object {
+	struct config_group group;
+};
+
+struct devconf_config_driver {
+	struct list_head list;
+	struct devconf_config_object cobj;
+	const char *name;
+	struct module *mod;
+	void (*set_config_object)(struct devconf_config_driver *cdrv,
+				  const char *name);
+	int (*get_int_attr)(struct devconf_config_object *cobj,
+			    const char *attr_name, int *val);
+};
+
+struct devconf_config_driver *devconf_get_config_driver(const char *na=
me);
+
+struct devconf_config_object
+*devconf_get_config_object(struct config_group *group, const char *nam=
e);
+
+ssize_t devconf_get_int_attr(struct devconf_config_driver *cdrv,
+			     struct devconf_config_object *cobj,
+			     const char *param, int *value);
+void devconf_device_unregister(struct devconf_config_driver *cd);
+int devconf_device_register(struct devconf_config_driver *new_cd);
+struct devconf_config_driver *devconf_create_config_driver(const char =
*name);
+void devconf_put_config_driver(struct devconf_config_driver *cdrv);
+
+static inline struct devconf_config_object
+*to_config_obj(struct config_item *item)
+{
+	return item ? container_of(item, struct devconf_config_object,
+				   group.cg_item) : NULL;
+}
+
+static inline struct devconf_config_driver
+*to_config_driver(struct config_item *item)
+{
+	return item ? container_of(item, struct devconf_config_driver,
+				   cobj.group.cg_item) : NULL;
+}
+
+#define DECLARE_DEVCONF_DRIVER(_name, _set_obj, _get_int_attr)		\
+	static struct devconf_config_driver _name ## devconf_driver =3D {	\
+		.name =3D __stringify(_name),				\
+		.mod  =3D THIS_MODULE,					\
+		.set_config_object =3D _set_obj,				\
+		.get_int_attr =3D _get_int_attr,				\
+	};								\
+	MODULE_ALIAS("devconf:" __stringify(_name))
+
+#define DECLARE_DEVCONF_DRIVER_INIT(_name, _set_obj, _get_int_attr)	\
+	DECLARE_DEVCONF_DRIVER(_name, _set_obj, _get_int_attr);		\
+	static int __init _name ## mod_init(void)			\
+	{								\
+		return devconf_device_register(&_name ## devconf_driver);\
+	}								\
+	static void __exit _name ## mod_exit(void)			\
+	{								\
+		devconf_device_unregister(&_name ## devconf_driver);	\
+	}								\
+	module_init(_name ## mod_init);					\
+	module_exit(_name ## mod_exit)
+
+#endif
--=20
1.7.8.2
