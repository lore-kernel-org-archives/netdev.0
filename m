From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/2] bonding: add sysfs /slave dir for bond
 slave devices.
Date: Tue, 21 Jan 2014 14:29:36 +0100
Message-ID: <20140121132936.GB3015@minipsycho.orion>
References: <20140117065749.3194.440.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, dingtianhong@huawei.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:47233 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbaAUN3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 08:29:39 -0500
Received: by mail-ee0-f52.google.com with SMTP id e53so4068681eek.39
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 05:29:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140117065749.3194.440.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Jan 17, 2014 at 07:57:49AM CET, sfeldma@cumulusnetworks.com wrot=
e:
>Add sub-directory under /sys/class/net/<interface>/slave with
>read-only attributes for slave.  Directory only appears when
><interface> is a slave.
>
>$ tree /sys/class/net/eth2/slave/

This should be either "bonding_slave" or

>/sys/class/net/eth2/slave/
>=E2=94=9C=E2=94=80=E2=94=80 ad_aggregator_id
>=E2=94=9C=E2=94=80=E2=94=80 link_failure_count
>=E2=94=9C=E2=94=80=E2=94=80 mii_status
>=E2=94=9C=E2=94=80=E2=94=80 perm_hwaddr
>=E2=94=9C=E2=94=80=E2=94=80 queue_id
>=E2=94=94=E2=94=80=E2=94=80 state

^ these should be prefixed by "bonding_"


>
>$ cat /sys/class/net/eth2/slave/*
>2
>0
>up
>40:02:10:ef:06:01
>0
>active
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>---
> drivers/net/bonding/Makefile           |    2=20
> drivers/net/bonding/bond_main.c        |   27 ++++++
> drivers/net/bonding/bond_procfs.c      |   12 ---
> drivers/net/bonding/bond_sysfs_slave.c |  144 +++++++++++++++++++++++=
+++++++++
> drivers/net/bonding/bonding.h          |    4 +
> 5 files changed, 176 insertions(+), 13 deletions(-)
> create mode 100644 drivers/net/bonding/bond_sysfs_slave.c
>
>diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefi=
le
>index 5a5d720..6f4e808 100644
>--- a/drivers/net/bonding/Makefile
>+++ b/drivers/net/bonding/Makefile
>@@ -4,7 +4,7 @@
>=20
> obj-$(CONFIG_BONDING) +=3D bonding.o
>=20
>-bonding-objs :=3D bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond=
_debugfs.o bond_netlink.o bond_options.o
>+bonding-objs :=3D bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond=
_sysfs_slave.o bond_debugfs.o bond_netlink.o bond_options.o
>=20
> proc-$(CONFIG_PROC_FS) +=3D bond_procfs.o
> bonding-objs +=3D $(proc-y)
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bon=
d_main.c
>index f00dd45..df85cec 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -466,6 +466,22 @@ static void bond_update_speed_duplex(struct slave=
 *slave)
> 	return;
> }
>=20
>+const char *bond_slave_link_status(s8 link)
>+{
>+	switch (link) {
>+	case BOND_LINK_UP:
>+		return "up";
>+	case BOND_LINK_FAIL:
>+		return "going down";
>+	case BOND_LINK_DOWN:
>+		return "down";
>+	case BOND_LINK_BACK:
>+		return "going back";
>+	default:
>+		return "unknown";
>+	}
>+}
>+
> /*
>  * if <dev> supports MII link status reporting, check its link status=
=2E
>  *
>@@ -1576,6 +1592,12 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
> 		goto err_unregister;
> 	}
>=20
>+	res =3D bond_sysfs_slave_add(new_slave);
>+	if (res) {
>+		pr_debug("Error %d calling bond_sysfs_slave_add\n", res);
>+		goto err_upper_unlink;
>+	}
>+
> 	bond->slave_cnt++;
> 	bond_compute_features(bond);
> 	bond_set_carrier(bond);
>@@ -1595,6 +1617,9 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
> 	return 0;
>=20
> /* Undo stages on error */
>+err_upper_unlink:
>+	bond_upper_dev_unlink(bond_dev, slave_dev);
>+
> err_unregister:
> 	netdev_rx_handler_unregister(slave_dev);
>=20
>@@ -1687,6 +1712,8 @@ static int __bond_release_one(struct net_device =
*bond_dev,
> 	/* release the slave from its bond */
> 	bond->slave_cnt--;
>=20
>+	bond_sysfs_slave_del(slave);
>+
> 	bond_upper_dev_unlink(bond_dev, slave_dev);
> 	/* unregister rx_handler early so bond_handle_frame wouldn't be call=
ed
> 	 * for this slave anymore.
>diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/b=
ond_procfs.c
>index fb868d6..8515b344 100644
>--- a/drivers/net/bonding/bond_procfs.c
>+++ b/drivers/net/bonding/bond_procfs.c
>@@ -159,18 +159,6 @@ static void bond_info_show_master(struct seq_file=
 *seq)
> 	}
> }
>=20
>-static const char *bond_slave_link_status(s8 link)
>-{
>-	static const char * const status[] =3D {
>-		[BOND_LINK_UP] =3D "up",
>-		[BOND_LINK_FAIL] =3D "going down",
>-		[BOND_LINK_DOWN] =3D "down",
>-		[BOND_LINK_BACK] =3D "going back",
>-	};
>-
>-	return status[link];
>-}
>-
> static void bond_info_show_slave(struct seq_file *seq,
> 				 const struct slave *slave)
> {
>diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bond=
ing/bond_sysfs_slave.c
>new file mode 100644
>index 0000000..7cb97de
>--- /dev/null
>+++ b/drivers/net/bonding/bond_sysfs_slave.c
>@@ -0,0 +1,144 @@
>+/*	Sysfs attributes of bond slaves
>+ *
>+ *      Copyright (c) 2014 Scott Feldman <sfeldma@cumulusnetworks.com=
>
>+ *
>+ *	This program is free software; you can redistribute it and/or
>+ *	modify it under the terms of the GNU General Public License
>+ *	as published by the Free Software Foundation; either version
>+ *	2 of the License, or (at your option) any later version.
>+ */
>+
>+#include <linux/capability.h>
>+#include <linux/kernel.h>
>+#include <linux/netdevice.h>
>+
>+#include "bonding.h"
>+
>+struct slave_attribute {
>+	struct attribute attr;
>+	ssize_t (*show)(struct slave *, char *);
>+};
>+
>+#define SLAVE_ATTR(_name, _mode, _show)				\
>+const struct slave_attribute slave_attr_##_name =3D {		\
>+	.attr =3D {.name =3D __stringify(_name),			\
>+		 .mode =3D _mode },				\
>+	.show	=3D _show,					\
>+};
>+#define SLAVE_ATTR_RO(_name) \
>+	SLAVE_ATTR(_name, S_IRUGO, _name##_show)
>+
>+static ssize_t state_show(struct slave *slave, char *buf)
>+{
>+	switch (bond_slave_state(slave)) {
>+	case BOND_STATE_ACTIVE:
>+		return sprintf(buf, "active\n");
>+	case BOND_STATE_BACKUP:
>+		return sprintf(buf, "backup\n");
>+	default:
>+		return sprintf(buf, "UNKONWN\n");
>+	}
>+}
>+static SLAVE_ATTR_RO(state);
>+
>+static ssize_t mii_status_show(struct slave *slave, char *buf)
>+{
>+	return sprintf(buf, "%s\n", bond_slave_link_status(slave->link));
>+}
>+static SLAVE_ATTR_RO(mii_status);
>+
>+static ssize_t link_failure_count_show(struct slave *slave, char *buf=
)
>+{
>+	return sprintf(buf, "%d\n", slave->link_failure_count);
>+}
>+static SLAVE_ATTR_RO(link_failure_count);
>+
>+static ssize_t perm_hwaddr_show(struct slave *slave, char *buf)
>+{
>+	return sprintf(buf, "%pM\n", slave->perm_hwaddr);
>+}
>+static SLAVE_ATTR_RO(perm_hwaddr);
>+
>+static ssize_t queue_id_show(struct slave *slave, char *buf)
>+{
>+	return sprintf(buf, "%d\n", slave->queue_id);
>+}
>+static SLAVE_ATTR_RO(queue_id);
>+
>+static ssize_t ad_aggregator_id_show(struct slave *slave, char *buf)
>+{
>+	const struct aggregator *agg;
>+
>+	if (slave->bond->params.mode =3D=3D BOND_MODE_8023AD) {
>+		agg =3D SLAVE_AD_INFO(slave).port.aggregator;
>+		if (agg)
>+			return sprintf(buf, "%d\n",
>+				       agg->aggregator_identifier);
>+	}
>+
>+	return sprintf(buf, "N/A\n");
>+}
>+static SLAVE_ATTR_RO(ad_aggregator_id);
>+
>+static const struct slave_attribute *slave_attrs[] =3D {
>+	&slave_attr_state,
>+	&slave_attr_mii_status,
>+	&slave_attr_link_failure_count,
>+	&slave_attr_perm_hwaddr,
>+	&slave_attr_queue_id,
>+	&slave_attr_ad_aggregator_id,
>+	NULL
>+};
>+
>+#define to_slave_attr(_at) container_of(_at, struct slave_attribute, =
attr)
>+#define to_slave(obj)	container_of(obj, struct slave, kobj)
>+
>+static ssize_t slave_show(struct kobject *kobj,
>+			  struct attribute *attr, char *buf)
>+{
>+	struct slave_attribute *slave_attr =3D to_slave_attr(attr);
>+	struct slave *slave =3D to_slave(kobj);
>+
>+	return slave_attr->show(slave, buf);
>+}
>+
>+const struct sysfs_ops slave_sysfs_ops =3D {
>+	.show =3D slave_show,
>+};
>+
>+static struct kobj_type slave_ktype =3D {
>+#ifdef CONFIG_SYSFS
>+	.sysfs_ops =3D &slave_sysfs_ops,
>+#endif
>+};
>+
>+int bond_sysfs_slave_add(struct slave *slave)
>+{
>+	const struct slave_attribute **a;
>+	int err;
>+
>+	err =3D kobject_init_and_add(&slave->kobj, &slave_ktype,
>+				   &(slave->dev->dev.kobj), "slave");
>+	if (err)
>+		return err;
>+
>+	for (a =3D slave_attrs; *a; ++a) {
>+		err =3D sysfs_create_file(&slave->kobj, &((*a)->attr));
>+		if (err) {
>+			kobject_del(&slave->kobj);
>+			return err;
>+		}
>+	}
>+
>+	return 0;
>+}
>+
>+void bond_sysfs_slave_del(struct slave *slave)
>+{
>+	const struct slave_attribute **a;
>+
>+	for (a =3D slave_attrs; *a; ++a)
>+		sysfs_remove_file(&slave->kobj, &((*a)->attr));
>+
>+	kobject_del(&slave->kobj);
>+}
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondi=
ng.h
>index 955dc48..309757d 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -203,6 +203,7 @@ struct slave {
> #ifdef CONFIG_NET_POLL_CONTROLLER
> 	struct netpoll *np;
> #endif
>+	struct kobject kobj;
> };
>=20
> /*
>@@ -421,6 +422,8 @@ int bond_create(struct net *net, const char *name)=
;
> int bond_create_sysfs(struct bond_net *net);
> void bond_destroy_sysfs(struct bond_net *net);
> void bond_prepare_sysfs_group(struct bonding *bond);
>+int bond_sysfs_slave_add(struct slave *slave);
>+void bond_sysfs_slave_del(struct slave *slave);
> int bond_enslave(struct net_device *bond_dev, struct net_device *slav=
e_dev);
> int bond_release(struct net_device *bond_dev, struct net_device *slav=
e_dev);
> int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int cou=
nt);
>@@ -469,6 +472,7 @@ int bond_option_lacp_rate_set(struct bonding *bond=
, int lacp_rate);
> int bond_option_ad_select_set(struct bonding *bond, int ad_select);
> struct net_device *bond_option_active_slave_get_rcu(struct bonding *b=
ond);
> struct net_device *bond_option_active_slave_get(struct bonding *bond)=
;
>+const char *bond_slave_link_status(s8 link);
>=20
> struct bond_net {
> 	struct net *		net;	/* Associated network namespace */
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
