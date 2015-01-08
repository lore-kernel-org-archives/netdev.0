From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [RFC net-next 1/3] net/dev_c_mlx4: Support mlx4_core pre-load configuration
Date: Thu,  8 Jan 2015 17:16:58 +0200
Message-ID: <1420730220-20224-2-git-send-email-hadarh@mellanox.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, shannon.nelson@intel.com,
	Doug Ledford <dledford@redhat.com>, greearb@candelatech.com
To: "David S. Miller" <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54517 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754650AbbAHPSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 10:18:31 -0500
In-Reply-To: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a configuration Module to mlx4_core to support setting of
pre-load parameters through configfs.

When dev_c_mlx4 module is loaded, it stores and validates the parameter=
s
sub-tree for mlx4_core driver under 'devices/mlx4_core' directory in co=
nfigfs.
The parameters sub-tree is a set of directories and files representing
mlx4_core variables that should be set before mlx4_core is loaded.

mlx4_core sub-tree includes directories per device, identified by a
'BDF' name, and under each directory/device its relevant parameters.

Example of optional mlx4_core hierarchy under configfs:
$ cd /sys/kernel/config/
$ tree devices/
devices/
=E2=94=94=E2=94=80=E2=94=80 mlx4_core
    =E2=94=94=E2=94=80=E2=94=80 pdevs
            =E2=94=9C=E2=94=80=E2=94=80 0000:00:04.0
	    =E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 dmfs
	    =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ports
	    =E2=94=82=C2=A0=C2=A0     =E2=94=9C=E2=94=80=E2=94=80 1
	    =E2=94=82=C2=A0=C2=A0     =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=
=E2=94=80 type
	    =E2=94=82=C2=A0=C2=A0     =E2=94=94=E2=94=80=E2=94=80 2
	    =E2=94=82=C2=A0=C2=A0 	=E2=94=94=E2=94=80=E2=94=80 type
	    =E2=94=94=E2=94=80=E2=94=80 0000:00:08.0
	    	=E2=94=9C=E2=94=80=E2=94=80 dmfs
	    	=E2=94=94=E2=94=80=E2=94=80 ports
	    	    =E2=94=9C=E2=94=80=E2=94=80 1
	    	    =E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 type
	    	    =E2=94=94=E2=94=80=E2=94=80 2
	    		=E2=94=94=E2=94=80=E2=94=80 type

systemd service executed by the OS will set a value to those files
according to the user configuration file (/etc/devconf.d/mlx4_core.conf=
)
before mlx4_core is loaded.
When mlx4_core is loaded, it asks devconf for 'dmfs' and 'type' values,
devconf retrieves the values stored in dev_c_mlx4 and passes them on to
mlx4_core.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig     |    5 +
 drivers/net/ethernet/mellanox/mlx4/Makefile    |    4 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_conf.c |  323 ++++++++++++++++=
++++++++
 3 files changed, 332 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/mlx4_conf.c

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/e=
thernet/mellanox/mlx4/Kconfig
index 1486ce9..fa135d3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -44,3 +44,8 @@ config MLX4_DEBUG
 	  mlx4_core driver.  The output can be turned on via the
 	  debug_level module parameter (which can also be set after
 	  the driver is loaded through sysfs).
+
+config MLX4_DEV_C
+	tristate "mlx4 driver pre-loading configuration module"
+	depends on DEVCONF
+	default m
diff --git a/drivers/net/ethernet/mellanox/mlx4/Makefile b/drivers/net/=
ethernet/mellanox/mlx4/Makefile
index 3e9c70f..33a1dc8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx4/Makefile
@@ -8,3 +8,7 @@ obj-$(CONFIG_MLX4_EN)               +=3D mlx4_en.o
 mlx4_en-y :=3D 	en_main.o en_tx.o en_rx.o en_ethtool.o en_port.o en_cq=
=2Eo \
 		en_resources.o en_netdev.o en_selftest.o en_clock.o
 mlx4_en-$(CONFIG_MLX4_EN_DCB) +=3D en_dcb_nl.o
+
+obj-$(CONFIG_MLX4_DEV_C)	+=3D dev_c_mlx4.o
+
+dev_c_mlx4-y :=3D mlx4_conf.o
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_conf.c b/drivers/n=
et/ethernet/mellanox/mlx4/mlx4_conf.c
new file mode 100644
index 0000000..c82924b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_conf.c
@@ -0,0 +1,323 @@
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
+
+#include <linux/configfs.h>
+#include <linux/devconf.h>
+#include <linux/mlx4/device.h>
+
+struct mlx4_port {
+	struct devconf_config_object cobj;
+	int type;
+};
+
+struct mlx4_bdf_config {
+	struct devconf_config_object cobj;
+	int dmfs;
+};
+
+static inline struct mlx4_bdf_config *to_bdf_config(struct config_item=
 *item)
+{
+	struct devconf_config_object *cobj =3D to_config_obj(item);
+
+	return cobj ? container_of(cobj, struct mlx4_bdf_config, cobj) : NULL=
;
+}
+
+static inline struct mlx4_port *to_simple_port(struct config_item *ite=
m)
+{
+	struct devconf_config_object *cobj =3D to_config_obj(item);
+
+	return cobj ? container_of(cobj, struct mlx4_port, cobj) : NULL;
+}
+
+static inline struct mlx4_bdf_config
+*cobj_to_bdf_config(struct devconf_config_object *cobj)
+{
+	return cobj ? container_of(cobj, struct mlx4_bdf_config, cobj) : NULL=
;
+}
+
+static inline struct mlx4_port
+*cobj_to_port(struct devconf_config_object *cobj)
+{
+	return cobj ? container_of(cobj, struct mlx4_port, cobj) : NULL;
+}
+
+static struct configfs_attribute simple_port_attr_type =3D {
+	.ca_owner =3D THIS_MODULE,
+	.ca_name =3D "type",
+	.ca_mode =3D S_IRUGO | S_IWUSR,
+};
+
+static struct configfs_attribute *simple_port_attrs[] =3D {
+	&simple_port_attr_type,
+	NULL,
+};
+
+static ssize_t config_attr_show(struct config_item *item,
+				struct configfs_attribute *attr,
+				char *page)
+{
+	struct mlx4_bdf_config *bdf_config;
+	struct mlx4_port *simple_port;
+	ssize_t count =3D -ENOENT;
+
+	if (strcmp(attr->ca_name, "dmfs")) {
+		bdf_config =3D to_bdf_config(item);
+		count =3D sprintf(page, "%d\n", bdf_config->dmfs);
+	} else if (strcmp(attr->ca_name, "type")) {
+		simple_port =3D to_simple_port(item);
+		count =3D sprintf(page, "%d\n", simple_port->type);
+	}
+	return count;
+}
+
+static ssize_t config_attr_store(struct config_item *item,
+				 struct configfs_attribute *attr,
+				 const char *page, size_t count)
+{
+	struct mlx4_bdf_config *bdf_config;
+	struct mlx4_port *simple_port;
+	int err;
+	unsigned long res;
+
+	err =3D kstrtoul(page, 10, &res);
+	if (err)
+		return err;
+	if (strcmp(attr->ca_name, "dmfs")) {
+		bdf_config =3D to_bdf_config(item);
+		bdf_config->dmfs =3D res;
+	} else if (strcmp(attr->ca_name, "type")) {
+		simple_port =3D to_simple_port(item);
+		simple_port->type =3D res;
+	}
+
+	return count;
+}
+
+static void simple_port_release(struct config_item *item)
+{
+	kfree(to_simple_port(item));
+}
+
+static struct configfs_item_operations simple_port_item_ops =3D {
+	.release                =3D simple_port_release,
+	.show_attribute         =3D config_attr_show,
+	.store_attribute        =3D config_attr_store,
+};
+
+static struct config_item_type simple_port_config_type =3D {
+	.ct_item_ops    =3D &simple_port_item_ops,
+	.ct_attrs       =3D simple_port_attrs,
+	.ct_owner       =3D THIS_MODULE,
+};
+
+static struct config_item *simple_port_make_item(struct config_group *=
group,
+						 const char *name)
+{
+	struct mlx4_port *simple_port;
+
+	simple_port =3D kzalloc(sizeof(*simple_port), GFP_KERNEL);
+	if (!simple_port)
+		return ERR_PTR(-ENOMEM);
+
+	config_item_init_type_name(&simple_port->cobj.group.cg_item, name,
+				   &simple_port_config_type);
+
+	simple_port->type =3D 0;
+
+	return &simple_port->cobj.group.cg_item;
+}
+
+static struct configfs_group_operations ports_group_ops =3D {
+	.make_item =3D simple_port_make_item,
+};
+
+static void cobj_release(struct config_item *item)
+{
+	kfree(to_config_obj(item));
+}
+
+static struct configfs_item_operations ports_item_ops =3D {
+	.release =3D cobj_release,
+};
+
+static struct config_item_type ports_config_type =3D {
+	.ct_item_ops    =3D &ports_item_ops,
+	.ct_group_ops   =3D &ports_group_ops,
+	.ct_owner       =3D THIS_MODULE,
+};
+
+static struct config_group *bdf_make_group(struct config_group *group,
+					   const char *name)
+{
+	struct devconf_config_object *ports_config;
+
+	ports_config =3D kzalloc(sizeof(*ports_config), GFP_KERNEL);
+	if (!ports_config)
+		return ERR_PTR(-ENOMEM);
+
+	config_group_init_type_name(&ports_config->group, name,
+				    &ports_config_type);
+
+	return &ports_config->group;
+}
+
+static struct configfs_group_operations bdf_group_ops =3D {
+	.make_group =3D bdf_make_group,
+};
+
+static void bdf_config_release(struct config_item *item)
+{
+	kfree(to_bdf_config(item));
+}
+
+static struct configfs_item_operations bdf_item_ops =3D {
+	.release		=3D bdf_config_release,
+	.show_attribute		=3D config_attr_show,
+	.store_attribute	=3D config_attr_store,
+};
+
+static struct configfs_attribute config_attr_dmfs =3D {
+	.ca_owner =3D THIS_MODULE,
+	.ca_name =3D "dmfs",
+	.ca_mode =3D S_IRUGO | S_IWUSR,
+};
+
+static struct configfs_attribute *bdf_config_attrs[] =3D {
+	&config_attr_dmfs,
+	NULL,
+};
+
+static struct config_item_type bdf_config_type =3D {
+	.ct_item_ops    =3D &bdf_item_ops,
+	.ct_group_ops   =3D &bdf_group_ops,
+	.ct_attrs       =3D bdf_config_attrs,
+	.ct_owner       =3D THIS_MODULE,
+};
+
+static struct config_group *pdevs_make_group(struct config_group *grou=
p,
+					     const char *name)
+{
+	struct mlx4_bdf_config *bdf_config;
+
+	bdf_config =3D kzalloc(sizeof(*bdf_config), GFP_KERNEL);
+	if (!bdf_config)
+		return ERR_PTR(-ENOMEM);
+
+	config_group_init_type_name(&bdf_config->cobj.group, name,
+				    &bdf_config_type);
+
+	return &bdf_config->cobj.group;
+}
+
+static struct configfs_group_operations pdevs_group_ops =3D {
+	.make_group =3D pdevs_make_group,
+};
+
+static struct configfs_item_operations pdevs_item_ops =3D {
+	.release =3D cobj_release,
+};
+
+static struct config_item_type pdevs_config_type =3D {
+	.ct_item_ops    =3D &pdevs_item_ops,
+	.ct_group_ops   =3D &pdevs_group_ops,
+	.ct_owner       =3D THIS_MODULE,
+};
+
+static struct config_group *mlx4_make_group(struct config_group *group=
,
+					    const char *name)
+{
+	struct devconf_config_object *pdevs_cobj;
+
+	pdevs_cobj =3D kzalloc(sizeof(*pdevs_cobj), GFP_KERNEL);
+	if (!pdevs_cobj)
+		return ERR_PTR(-ENOMEM);
+
+	config_group_init_type_name(&pdevs_cobj->group, name,
+				    &pdevs_config_type);
+
+	return &pdevs_cobj->group;
+}
+
+static struct configfs_group_operations mlx4_group_ops =3D {
+	.make_group =3D mlx4_make_group,
+};
+
+static void mlx4_release(struct config_item *item)
+{
+	struct devconf_config_driver *cdrv =3D to_config_driver(item);
+
+	devconf_put_config_driver(cdrv);
+}
+
+static struct configfs_item_operations mlx4_item_ops =3D {
+	.release =3D mlx4_release,
+};
+
+static struct config_item_type mlx4_config_type =3D {
+	.ct_item_ops    =3D &mlx4_item_ops,
+	.ct_group_ops	=3D &mlx4_group_ops,
+	.ct_owner	=3D THIS_MODULE,
+};
+
+static int mlx4_get_int_attr(struct devconf_config_object *cobj,
+			     const char *attr_name, int *val)
+{
+	struct mlx4_port *simple_port;
+	struct mlx4_bdf_config *bdf_config;
+
+	if (strcmp(attr_name, "dmfs")) {
+		bdf_config =3D cobj_to_bdf_config(cobj);
+		*val =3D bdf_config->dmfs;
+	} else if (strcmp(attr_name, "type")) {
+		simple_port =3D cobj_to_port(cobj);
+		*val =3D simple_port->type;
+	} else {
+		return -ENOENT;
+	}
+	return 0;
+}
+
+static void mlx4_set_config_object(struct devconf_config_driver *cdrv,
+				   const char *name)
+{
+	config_group_init_type_name(&cdrv->cobj.group, name, &mlx4_config_typ=
e);
+}
+
+DECLARE_DEVCONF_DRIVER_INIT(mlx4_core,
+			    mlx4_set_config_object,
+			    mlx4_get_int_attr);
+
+MODULE_LICENSE("GPL");
--=20
1.7.8.2
