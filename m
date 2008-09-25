From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/4] [NET] Distributed Switch Architecture protocol support
Date: Thu, 25 Sep 2008 18:38:45 +0200
Message-ID: <20080925163845.GB25190@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:36108 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979AbYIYQit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 12:38:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Distributed Switch Architecture is a protocol for managing hardware
switch chips.  It consists of a set of MII management registers and
commands to configure the switch, and an ethernet header format to
signal which of the ports of the switch a packet was received from
or is intended to be sent to.

The switches that this driver supports are typically embedded in
access points and routers, and a typical setup with a DSA switch
looks something like this:

	+-----------+       +-----------+
	|           | RGMII |           |
	|           +-------+           +------ 1000baseT MDI ("WAN")
	|           |       |  6-port   +------ 1000baseT MDI ("LAN1")
	|    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
	|           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
	|           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
	|           |       |           |
	+-----------+       +-----------+

The switch driver presents each port on the switch as a separate
network interface to Linux, polls the switch to maintain software
link state of those ports, forwards MII management interface
accesses to those network interfaces (e.g. as done by ethtool) to
the switch, and exposes the switch's hardware statistics counters
via the appropriate Linux kernel interfaces.

This initial patch supports the MII management interface register
layout of the Marvell 88E6123, 88E6161 and 88E6165 switch chips, and
supports the "Ethertype DSA" packet tagging format.

(There is no officially registered ethertype for the Ethertype DSA
packet format, so we just grab a random one.  The ethertype to use
is programmed into the switch, and the switch driver uses the value
of ETH_P_EDSA for this, so this define can be changed at any time in
the future if the one we chose is allocated to another protocol or
if Ethertype DSA gets its own officially registered ethertype, and
everything will continue to work.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 include/linux/if_ether.h  |    1 +
 include/linux/netdevice.h |    5 +
 include/net/dsa.h         |   24 ++
 net/Kconfig               |    1 +
 net/Makefile              |    1 +
 net/dsa/Kconfig           |   31 ++
 net/dsa/Makefile          |    8 +
 net/dsa/dsa.c             |  359 +++++++++++++++++
 net/dsa/dsa_priv.h        |   98 +++++
 net/dsa/marvell.c         |  961 +++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c           |  279 +++++++++++++
 net/dsa/tag_edsa.c        |  222 +++++++++++
 12 files changed, 1990 insertions(+), 0 deletions(-)
 create mode 100644 include/net/dsa.h
 create mode 100644 net/dsa/Kconfig
 create mode 100644 net/dsa/Makefile
 create mode 100644 net/dsa/dsa.c
 create mode 100644 net/dsa/dsa_priv.h
 create mode 100644 net/dsa/marvell.c
 create mode 100644 net/dsa/slave.c
 create mode 100644 net/dsa/tag_edsa.c

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index e157c13..a85f5a2 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -76,6 +76,7 @@
 					 */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*
  *	Non DIX types. Won't clash for 1500 types.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..f67435d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -725,6 +725,11 @@ struct net_device
 	struct net		*nd_net;
 #endif
 
+#ifdef CONFIG_NET_DSA
+	/* dsa private data */
+	void			*dsa_ptr;
+#endif
+
 	/* mid-layer private */
 	void			*ml_priv;
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
new file mode 100644
index 0000000..4839894
--- /dev/null
+++ b/include/net/dsa.h
@@ -0,0 +1,24 @@
+/*
+ * include/net/dsa.h - Driver for Distributed Switch Architecture switch chips
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_NET_DSA_H
+#define __LINUX_NET_DSA_H
+
+#define DSA_MAX_PORTS	8
+
+struct dsa_platform_data {
+	struct device	*mii_bus;
+	int		sw_addr;
+	struct device	*netdev;
+	char		*port_names[DSA_MAX_PORTS];
+};
+
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index 7612cc8..4c52f1a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -180,6 +180,7 @@ source "net/tipc/Kconfig"
 source "net/atm/Kconfig"
 source "net/802/Kconfig"
 source "net/bridge/Kconfig"
+source "net/dsa/Kconfig"
 source "net/8021q/Kconfig"
 source "net/decnet/Kconfig"
 source "net/llc/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 4f43e7f..9d47389 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_NET_SCHED)		+= sched/
 obj-$(CONFIG_BRIDGE)		+= bridge/
+obj-$(CONFIG_NET_DSA)		+= dsa/
 obj-$(CONFIG_IPX)		+= ipx/
 obj-$(CONFIG_ATALK)		+= appletalk/
 obj-$(CONFIG_WAN_ROUTER)	+= wanrouter/
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
new file mode 100644
index 0000000..8618508
--- /dev/null
+++ b/net/dsa/Kconfig
@@ -0,0 +1,31 @@
+menuconfig NET_DSA
+	bool "Distributed Switch Architecture support"
+	default n
+	depends on EXPERIMENTAL
+	---help---
+	  This allows you to use hardware switch chips that use
+	  the Distributed Switch Architecture.
+
+
+if NET_DSA
+
+# tagging formats
+config NET_DSA_TAG_EDSA
+	bool
+	default n
+
+
+# switch drivers
+config NET_DSA_MARVELL
+	bool
+	default n
+
+config NET_DSA_EMERALD
+	bool "Marvell 88E6123/6161/6165 ethernet switch chip support"
+	select NET_DSA_TAG_EDSA
+	select NET_DSA_MARVELL
+	---help---
+	  This enables support for the Marvell 88E6123/6161/6165
+	  ethernet switch chips.
+
+endif
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
new file mode 100644
index 0000000..6c36d10
--- /dev/null
+++ b/net/dsa/Makefile
@@ -0,0 +1,8 @@
+# tagging formats
+obj-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
+
+# switch drivers
+obj-$(CONFIG_NET_DSA_MARVELL) += marvell.o
+
+# the core
+obj-$(CONFIG_NET_DSA) += dsa.o slave.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
new file mode 100644
index 0000000..e94bfe6
--- /dev/null
+++ b/net/dsa/dsa.c
@@ -0,0 +1,359 @@
+/*
+ * net/dsa/dsa.c - Hardware switch handling
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/rtnetlink.h>
+#include <net/dsa.h>
+#include "dsa_priv.h"
+
+char dsa_driver_version[] = "0.1";
+
+
+/* switch driver registration ***********************************************/
+static DEFINE_MUTEX(dsa_switch_drivers_mutex);
+static LIST_HEAD(dsa_switch_drivers);
+
+void register_switch_driver(struct dsa_switch_driver *drv)
+{
+	mutex_lock(&dsa_switch_drivers_mutex);
+	list_add_tail(&drv->list, &dsa_switch_drivers);
+	mutex_unlock(&dsa_switch_drivers_mutex);
+}
+
+void unregister_switch_driver(struct dsa_switch_driver *drv)
+{
+	mutex_lock(&dsa_switch_drivers_mutex);
+	list_del_init(&drv->list);
+	mutex_unlock(&dsa_switch_drivers_mutex);
+}
+
+static struct dsa_switch_driver *
+dsa_switch_probe(struct mii_bus *bus, int sw_addr)
+{
+	struct dsa_switch_driver *ret;
+	struct list_head *list;
+
+	ret = NULL;
+
+	mutex_lock(&dsa_switch_drivers_mutex);
+	list_for_each(list, &dsa_switch_drivers) {
+		struct dsa_switch_driver *drv;
+
+		drv = list_entry(list, struct dsa_switch_driver, list);
+		if (drv->probe(bus, sw_addr)) {
+			ret = drv;
+			break;
+		}
+	}
+	mutex_unlock(&dsa_switch_drivers_mutex);
+
+	return ret;
+}
+
+
+/* basic switch operations **************************************************/
+static struct dsa_switch *
+dsa_switch_setup(struct dsa_platform_data *pd,
+		 struct mii_bus *bus, struct net_device *dev)
+{
+	struct dsa_switch *ds;
+	int ret;
+	struct dsa_switch_driver *drv;
+	int i;
+
+	/*
+	 * Probe for switch model.
+	 */
+	drv = dsa_switch_probe(bus, pd->sw_addr);
+	if (drv == NULL) {
+		printk(KERN_ERR "%s: could not detect attached switch\n",
+		       dev->name);
+		return ERR_PTR(-EINVAL);
+	}
+	printk(KERN_INFO "%s: detected a %s switch\n", dev->name, drv->name);
+
+
+	/*
+	 * Allocate memory and initialise switch state.
+	 */
+	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	if (ds == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	ds->pdata = pd;
+	ds->mii_bus = bus;
+	ds->sw_addr = pd->sw_addr;
+	ds->master_dev = dev;
+
+	ds->drv = drv;
+	ds->tag_type = 1 << (fls(drv->tag_methods) - 1);
+
+
+	/*
+	 * Enumerate the switch ports.
+	 */
+	ds->cpu_port = 0xff;
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		char *name;
+
+		name = pd->port_names[i];
+		if (name == NULL)
+			continue;
+
+		if (!strcmp(name, "cpu")) {
+			if (ds->cpu_port != 0xff) {
+				printk(KERN_ERR "multiple cpu ports?!\n");
+				ret = -EINVAL;
+				goto out;
+			}
+			ds->cpu_port = i;
+		} else {
+			ds->valid_port_mask |= 1 << i;
+		}
+	}
+
+	if (ds->cpu_port == 0xff) {
+		printk(KERN_ERR "no cpu port?!\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+
+	/*
+	 * Do basic register setup.
+	 */
+	ret = drv->setup(ds);
+	if (ret < 0)
+		goto out;
+
+	ret = drv->set_addr(ds, dev->dev_addr);
+	if (ret < 0)
+		goto out;
+
+	dsa_slave_mii_bus_init(ds);
+	ret = mdiobus_register(&ds->slave_mii_bus);
+	if (ret < 0)
+		goto out;
+
+	/*
+	 * Create network devices for physical switch ports.
+	 */
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		char *name;
+		struct net_device *slave_dev;
+
+		name = pd->port_names[i];
+		if (name == NULL || !strcmp(name, "cpu"))
+			continue;
+
+		slave_dev = dsa_slave_create(ds, i);
+		if (slave_dev == NULL) {
+			printk(KERN_ERR "%s: can't create dsa slave "
+			       "device for port %d(%s)\n",
+			       dev->name, i, name);
+			continue;
+		}
+
+		ds->ports[i] = slave_dev;
+	}
+
+	/*
+	 * Enable reception of tagged frames.
+	 */
+	wmb();
+	dev->dsa_ptr = (void *)ds;
+
+	return ds;
+
+out:
+	kfree(ds);
+	return ERR_PTR(ret);
+}
+
+static void dsa_switch_destroy(struct dsa_switch *ds)
+{
+	BUG();
+}
+
+
+/* link polling *************************************************************/
+static void dsa_link_poll_work(struct work_struct *ugly)
+{
+	struct dsa_switch *ds;
+
+	ds = container_of(ugly, struct dsa_switch, link_poll_work);
+
+	ds->drv->poll_link(ds);
+	mod_timer(&ds->link_poll_timer, jiffies + (HZ / 2));
+}
+
+static void dsa_link_poll_timer(unsigned long _ds)
+{
+	struct dsa_switch *ds = (void *)_ds;
+
+	schedule_work(&ds->link_poll_work);
+}
+
+
+/* platform driver init and cleanup *****************************************/
+static int dev_is_class(struct device *dev, void *class)
+{
+	if (dev->class != NULL && !strcmp(dev->class->name, class))
+		return 1;
+
+	return 0;
+}
+
+static struct device *dev_find_class(struct device *parent, char *class)
+{
+	if (dev_is_class(parent, class)) {
+		get_device(parent);
+		return parent;
+	}
+
+	return device_find_child(parent, class, dev_is_class);
+}
+
+static struct net_device *dev_to_net_device(struct device *dev)
+{
+	struct device *d;
+
+	d = dev_find_class(dev, "net");
+	if (d != NULL) {
+		struct net_device *nd;
+
+		nd = to_net_dev(d);
+		dev_hold(nd);
+		put_device(d);
+
+		return nd;
+	}
+
+	return NULL;
+}
+
+#define to_mii_bus(d) container_of(d, struct mii_bus, dev)
+
+static struct mii_bus *dev_to_mii_bus(struct device *dev)
+{
+	struct device *d;
+
+	d = dev_find_class(dev, "mdio_bus");
+	if (d != NULL) {
+		struct mii_bus *bus;
+
+		bus = to_mii_bus(d);
+		put_device(d);
+
+		return bus;
+	}
+
+	return NULL;
+}
+
+static int dsa_probe(struct platform_device *pdev)
+{
+	static int dsa_version_printed;
+	struct dsa_platform_data *pd = pdev->dev.platform_data;
+	struct net_device *dev;
+	struct mii_bus *bus;
+	struct dsa_switch *ds;
+
+	if (!dsa_version_printed++)
+		printk(KERN_NOTICE "Distributed Switch Architecture "
+			"driver version %s\n", dsa_driver_version);
+
+	if (pd == NULL || pd->mii_bus == NULL || pd->netdev == NULL)
+		return -EINVAL;
+
+	dev = dev_to_net_device(pd->netdev);
+	if (dev == NULL)
+		return -EINVAL;
+
+	bus = dev_to_mii_bus(pd->mii_bus);
+	if (bus == NULL) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+
+	if (dev->dsa_ptr != NULL) {
+		dev_put(dev);
+		return -EEXIST;
+	}
+
+	ds = dsa_switch_setup(pd, bus, dev);
+	if (IS_ERR(ds)) {
+		dev_put(dev);
+		return PTR_ERR(ds);
+	}
+
+	if (ds->drv->poll_link != NULL) {
+		INIT_WORK(&ds->link_poll_work, dsa_link_poll_work);
+		init_timer(&ds->link_poll_timer);
+		ds->link_poll_timer.data = (unsigned long)ds;
+		ds->link_poll_timer.function = dsa_link_poll_timer;
+		ds->link_poll_timer.expires = jiffies + (HZ / 2);
+		add_timer(&ds->link_poll_timer);
+	}
+
+	platform_set_drvdata(pdev, ds);
+
+	return 0;
+}
+
+static int dsa_remove(struct platform_device *pdev)
+{
+	struct dsa_switch *ds = platform_get_drvdata(pdev);
+
+	if (ds->drv->poll_link != NULL)
+		del_timer_sync(&ds->link_poll_timer);
+
+	flush_scheduled_work();
+
+	dsa_switch_destroy(ds);
+
+	return 0;
+}
+
+static void dsa_shutdown(struct platform_device *pdev)
+{
+}
+
+static struct platform_driver dsa_driver = {
+	.probe		= dsa_probe,
+	.remove		= dsa_remove,
+	.shutdown	= dsa_shutdown,
+	.driver = {
+		.name	= "dsa",
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init dsa_init_module(void)
+{
+	return platform_driver_register(&dsa_driver);
+}
+module_init(dsa_init_module);
+
+static void __exit dsa_cleanup_module(void)
+{
+	platform_driver_unregister(&dsa_driver);
+}
+module_exit(dsa_cleanup_module);
+
+MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>")
+MODULE_DESCRIPTION("Driver for Distributed Switch Architecture switch chips");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:dsa");
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
new file mode 100644
index 0000000..78246bf
--- /dev/null
+++ b/net/dsa/dsa_priv.h
@@ -0,0 +1,98 @@
+#ifndef __DSA_PRIVATE_H
+#define __DSA_PRIVATE_H
+
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/netdevice.h>
+
+enum dsa_tag_type {
+	TAG_EDSA_MASK = 1,
+};
+
+struct dsa_switch {
+	/*
+	 * Configuration data for this platform.
+	 */
+	struct dsa_platform_data	*pdata;
+	struct mii_bus			*mii_bus;
+	int				sw_addr;
+	struct net_device		*master_dev;
+
+	/*
+	 * The used switch driver and frame tagging type.
+	 */
+	struct dsa_switch_driver	*drv;
+	enum dsa_tag_type		tag_type;
+
+	/*
+	 * Slave mii_bus and devices for the individual ports.
+	 */
+	int				cpu_port;
+	u32				valid_port_mask;
+	struct mii_bus			slave_mii_bus;
+	struct net_device		*ports[DSA_MAX_PORTS];
+
+	/*
+	 * Link state polling.
+	 */
+	struct work_struct		link_poll_work;
+	struct timer_list		link_poll_timer;
+};
+
+struct dsa_slave_priv {
+	struct net_device	*dev;
+	struct dsa_switch	*parent;
+	int			port;
+	struct phy_device	*phy;
+};
+
+struct dsa_switch_driver {
+	struct list_head	list;
+
+	char	*name;
+	u32	tag_methods;
+	int	priv_size;
+	int	priv_port_size;
+
+	/*
+	 * Probing and setup.
+	 */
+	int	(*probe)(struct mii_bus *bus, int sw_addr);
+	int	(*setup)(struct dsa_switch *ds);
+	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
+
+	/*
+	 * Access to the switch's PHY registers.
+	 */
+	int	(*mii_read)(struct dsa_switch *ds, int port, int regnum);
+	int	(*mii_write)(struct dsa_switch *ds, int port,
+			     int regnum, u16 val);
+
+	/*
+	 * Link state polling and IRQ handling.
+	 */
+	void	(*poll_link)(struct dsa_switch *ds);
+
+	/*
+	 * ethtool hardware statistics.
+	 */
+	void	(*get_strings)(struct dsa_switch *ds, int port, uint8_t *data);
+	void	(*get_ethtool_stats)(struct dsa_switch *ds,
+				     int port, uint64_t *data);
+	int	(*get_sset_count)(struct dsa_switch *ds);
+};
+
+/* dsa.c */
+extern char dsa_driver_version[];
+void register_switch_driver(struct dsa_switch_driver *type);
+void unregister_switch_driver(struct dsa_switch_driver *type);
+
+/* slave.c */
+void dsa_slave_mii_bus_init(struct dsa_switch *ds);
+struct net_device *dsa_slave_create(struct dsa_switch *ds, int port);
+
+/* tag_edsa.c */
+int edsa_xmit(struct sk_buff *skb, struct net_device *dev);
+
+
+#endif
diff --git a/net/dsa/marvell.c b/net/dsa/marvell.c
new file mode 100644
index 0000000..7f571ab
--- /dev/null
+++ b/net/dsa/marvell.c
@@ -0,0 +1,961 @@
+/*
+ * net/dsa/marvell.c - Low-level driver for Marvell DSA switch chips
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <net/dsa.h>
+#include "dsa_priv.h"
+
+struct priv_state {
+	/*
+	 * When using multi-chip addressing, this mutex protects
+	 * access to the indirect access registers.  (In single-chip
+	 * mode, this mutex is effectively useless.)
+	 */
+	struct mutex	smi_mutex;
+
+	/*
+	 * This mutex serialises access to the statistics unit.
+	 * Hold this mutex over snapshot + dump sequences.
+	 */
+	struct mutex	stats_mutex;
+};
+
+#define REG_PORT(p)		(0x10 + (p))
+#define REG_GLOBAL		0x1b
+#define REG_GLOBAL2		0x1c
+
+
+/* mdio accessors ***********************************************************/
+/*
+ * If the switch's ADDR[4:0] strap pins are strapped to zero, it will
+ * use all 32 SMI bus addresses on its SMI bus, and all switch registers
+ * will be directly accessible on some {device address,register address}
+ * pair.  If the ADDR[4:0] pins are not strapped to zero, the switch
+ * will only respond to SMI transactions to that specific address, and
+ * an indirect addressing mechanism needs to be used to access its
+ * registers.
+ */
+int reg_wait_ready(struct mii_bus *bus, int sw_addr)
+{
+	int ret;
+	int i;
+
+	for (i = 0; i < 16; i++) {
+		ret = mdiobus_read(bus, sw_addr, 0);
+		if (ret < 0)
+			return ret;
+
+		if ((ret & 0x8000) == 0)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int
+__reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
+{
+	int ret;
+
+	if (sw_addr == 0)
+		return mdiobus_read(bus, addr, reg);
+
+	/*
+	 * Wait for the bus to become free.
+	 */
+	ret = reg_wait_ready(bus, sw_addr);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Transmit the read command.
+	 */
+	ret = mdiobus_write(bus, sw_addr, 0, 0x9800 | (addr << 5) | reg);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Wait for the read command to complete.
+	 */
+	ret = reg_wait_ready(bus, sw_addr);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Read the data.
+	 */
+	ret = mdiobus_read(bus, sw_addr, 1);
+	if (ret < 0)
+		return ret;
+
+	return ret & 0xffff;
+}
+
+static int reg_read(struct dsa_switch *ds, int addr, int reg)
+{
+	struct priv_state *ps = (void *)(ds + 1);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = __reg_read(ds->mii_bus, ds->sw_addr, addr, reg);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+static int
+__reg_write(struct mii_bus *bus, int sw_addr, int addr, int reg, u16 val)
+{
+	int ret;
+
+	if (sw_addr == 0)
+		return mdiobus_write(bus, addr, reg, val);
+
+	/*
+	 * Wait for the bus to become free.
+	 */
+	ret = reg_wait_ready(bus, sw_addr);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Transmit the data to write.
+	 */
+	ret = mdiobus_write(bus, sw_addr, 1, val);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Transmit the write command.
+	 */
+	ret = mdiobus_write(bus, sw_addr, 0, 0x9400 | (addr << 5) | reg);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Wait for the write command to complete.
+	 */
+	ret = reg_wait_ready(bus, sw_addr);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
+{
+	struct priv_state *ps = (void *)(ds + 1);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = __reg_write(ds->mii_bus, ds->sw_addr, addr, reg, val);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+
+/* mii access ***************************************************************/
+static int mii_read(struct dsa_switch *ds, int addr, int regnum)
+{
+	return reg_read(ds, addr, regnum);
+}
+
+static int mii_write(struct dsa_switch *ds, int addr, int regnum, u16 val)
+{
+	return reg_write(ds, addr, regnum, val);
+}
+
+
+/* shared functions *********************************************************/
+static int marvell_switch_reset(struct dsa_switch *ds)
+{
+	int i;
+	int ret;
+
+	/*
+	 * Set all ports to the disabled state.
+	 */
+	for (i = 0; i < 8; i++) {
+		ret = reg_read(ds, REG_PORT(i), 0x04);
+		if (ret < 0)
+			return ret;
+
+		ret = reg_write(ds, REG_PORT(i), 0x04, ret & 0xfffc);
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Wait for transmit queues to drain.
+	 */
+	msleep(2);
+
+	/*
+	 * Reset the switch.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x04, 0xc400);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Wait up to one second for reset to complete.
+	 */
+	for (i = 0; i < 1000; i++) {
+		ret = reg_read(ds, REG_GLOBAL, 0x00);
+		if (ret < 0)
+			return ret;
+
+		if ((ret & 0xc800) == 0xc800)
+			break;
+
+		msleep(1);
+	}
+	if (i == 1000)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int marvell_config_prio(struct dsa_switch *ds)
+{
+	int ret;
+
+	/*
+	 * Configure the IP ToS mapping registers.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x10, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x11, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x12, 0x5555);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x13, 0x5555);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x14, 0xaaaa);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x15, 0xaaaa);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x16, 0xffff);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x17, 0xffff);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Configure the IEEE 802.1p priority mapping register.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x18, 0xfa41);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static void marvell_poll_link(struct dsa_switch *ds)
+{
+	int i;
+
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		struct net_device *dev;
+		int port_status;
+		int link;
+		int speed;
+		int duplex;
+		int fc;
+
+		dev = ds->ports[i];
+		if (dev == NULL)
+			continue;
+
+		link = 0;
+		if (dev->flags & IFF_UP) {
+			port_status = reg_read(ds, REG_PORT(i), 0x00);
+			if (port_status < 0)
+				continue;
+
+			link = !!(port_status & 0x0800);
+		}
+
+		if (!link) {
+			if (netif_carrier_ok(dev)) {
+				printk(KERN_INFO "%s: link down\n", dev->name);
+				netif_carrier_off(dev);
+			}
+			continue;
+		}
+
+		switch (port_status & 0x0300) {
+		case 0x0000:
+			speed = 10;
+			break;
+		case 0x0100:
+			speed = 100;
+			break;
+		case 0x0200:
+			speed = 1000;
+			break;
+		default:
+			speed = -1;
+			break;
+		}
+		duplex = (port_status & 0x0400) ? 1 : 0;
+		fc = (port_status & 0x8000) ? 1 : 0;
+
+		if (!netif_carrier_ok(dev)) {
+			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
+					 "flow control %sabled\n", dev->name,
+					 speed, duplex ? "full" : "half",
+					 fc ? "en" : "dis");
+			netif_carrier_on(dev);
+		}
+	}
+}
+
+
+/* hardware statistics ******************************************************/
+struct hwstat {
+	char string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int reg;
+};
+
+static struct hwstat hwstats[] = {
+	{ "in_good_octets", 8, 0x00, },
+	{ "in_bad_octets", 4, 0x02, },
+	{ "in_unicast", 4, 0x04, },
+	{ "in_broadcasts", 4, 0x06, },
+	{ "in_multicasts", 4, 0x07, },
+	{ "in_pause", 4, 0x16, },
+	{ "in_undersize", 4, 0x18, },
+	{ "in_fragments", 4, 0x19, },
+	{ "in_oversize", 4, 0x1a, },
+	{ "in_jabber", 4, 0x1b, },
+	{ "in_rx_error", 4, 0x1c, },
+	{ "in_fcs_error", 4, 0x1d, },
+	{ "out_octets", 8, 0x0e, },
+	{ "out_unicast", 4, 0x10, },
+	{ "out_broadcasts", 4, 0x13, },
+	{ "out_multicasts", 4, 0x12, },
+	{ "out_pause", 4, 0x15, },
+	{ "excessive", 4, 0x11, },
+	{ "collisions", 4, 0x1e, },
+	{ "deferred", 4, 0x05, },
+	{ "single", 4, 0x14, },
+	{ "multiple", 4, 0x17, },
+	{ "out_fcs_error", 4, 0x03, },
+	{ "late", 4, 0x1f, },
+	{ "hist_64bytes", 4, 0x08, },
+	{ "hist_65_127bytes", 4, 0x09, },
+	{ "hist_128_255bytes", 4, 0x0a, },
+	{ "hist_256_511bytes", 4, 0x0b, },
+	{ "hist_512_1023bytes", 4, 0x0c, },
+	{ "hist_1024_max_bytes", 4, 0x0d, },
+};
+
+static void marvell_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(hwstats); i++) {
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       hwstats[i].string, ETH_GSTRING_LEN);
+	}
+}
+
+static int stats_wait(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	for (i = 0; i < 10; i++) {
+		ret = reg_read(ds, REG_GLOBAL2, 0x1d);
+		if (ret < 0)
+			return ret;
+
+		if ((ret & 0x8000) == 0)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static void stat_read(struct dsa_switch *ds, int stat, u32 *_val)
+{
+	u32 val;
+	int ret;
+
+	*_val = 0;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x1d, 0xcc00 | stat);
+	if (ret < 0)
+		return;
+
+	ret = stats_wait(ds);
+	if (ret < 0)
+		return;
+
+	ret = reg_read(ds, REG_GLOBAL, 0x1e);
+	if (ret < 0)
+		return;
+
+	val = ret << 16;
+
+	ret = reg_read(ds, REG_GLOBAL, 0x1f);
+	if (ret < 0)
+		return;
+
+	*_val = val | ret;
+}
+
+static void
+marvell_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data)
+{
+	struct priv_state *ps = (void *)(ds + 1);
+	int ret;
+	int i;
+
+	mutex_lock(&ps->stats_mutex);
+
+	/*
+	 * Snapshot the hardware statistics counters for this port.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x1d, 0xdc00 | port);
+	if (ret < 0)
+		return;
+
+	/*
+	 * Wait for the snapshotting to complete.
+	 */
+	ret = stats_wait(ds);
+	if (ret < 0)
+		return;
+
+	/*
+	 * Read each of the counters.
+	 */
+	for (i = 0; i < ARRAY_SIZE(hwstats); i++) {
+		struct hwstat *s = hwstats + i;
+		u32 low;
+		u32 high;
+
+		stat_read(ds, s->reg, &low);
+		if (s->sizeof_stat == 8)
+			stat_read(ds, s->reg + 1, &high);
+		else
+			high = 0;
+
+		data[i] = (((u64)high) << 32) | low;
+	}
+
+	mutex_unlock(&ps->stats_mutex);
+}
+
+static int marvell_get_sset_count(struct dsa_switch *ds)
+{
+	return ARRAY_SIZE(hwstats);
+}
+
+
+#ifdef CONFIG_NET_DSA_EMERALD
+/* emerald ******************************************************************/
+static int emerald6123_probe(struct mii_bus *bus, int sw_addr)
+{
+	if ((__reg_read(bus, sw_addr, REG_PORT(0), 0x03) & 0xfff0) == 0x1210)
+		return 1;
+
+	return 0;
+}
+
+static int emerald6161_probe(struct mii_bus *bus, int sw_addr)
+{
+	if ((__reg_read(bus, sw_addr, REG_PORT(0), 0x03) & 0xfff0) == 0x1610)
+		return 1;
+
+	return 0;
+}
+
+static int emerald6165_probe(struct mii_bus *bus, int sw_addr)
+{
+	if ((__reg_read(bus, sw_addr, REG_PORT(0), 0x03) & 0xfff0) == 0x1650)
+		return 1;
+
+	return 0;
+}
+
+static int emerald_setup_global(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	/*
+	 * Disable the PHY polling unit (since there won't be any
+	 * external PHYs to poll), don't discard packets with
+	 * excessive collisions, and mask all interrupt sources.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x04, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Set the default address aging time to 5 minutes, and
+	 * enable address learn messages to be sent to all message
+	 * ports.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x0a, 0x0148);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Configure the priority mapping registers.
+	 */
+	ret = marvell_config_prio(ds);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Configure the cpu port, and configure the cpu port as the
+	 * port to which ingress and egress monitor frames are to be
+	 * sent.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1110));
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Disable remote management for now, and set the switch's
+	 * DSA device number to zero.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x1c, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Send all frames with destination addresses matching
+	 * 01:80:c2:00:00:2x to the CPU port.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x02, 0xffff);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Send all frames with destination addresses matching
+	 * 01:80:c2:00:00:0x to the CPU port.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x03, 0xffff);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Disable the loopback filter, disable flow control
+	 * messages, disable flood broadcast override, disable
+	 * removing of provider tags, disable ATU age violation
+	 * interrupts, disable tag flow control, force flow
+	 * control priority to the highest, and send all special
+	 * multicast frames to the CPU at the highest priority.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x05, 0x00ff);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Map all DSA device IDs to the CPU port.
+	 */
+	for (i = 0; i < 32; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x06,
+				0x8000 | (i << 8) | ds->cpu_port);
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Clear all trunk masks.
+	 */
+	for (i = 0; i < 8; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x07,
+				0x8000 | (i << 12) | 0xff);
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Clear all trunk mappings.
+	 */
+	for (i = 0; i < 16; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Disable ingress rate limiting by resetting all ingress
+	 * rate limit registers to their initial state.
+	 */
+	for (i = 0; i < 6; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x09, 0x9000 | (i << 8));
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Initialise cross-chip port VLAN table to reset defaults.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x0b, 0x9000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Clear the priority override table.
+	 */
+	for (i = 0; i < 16; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x0f, 0x8000 | (i << 8));
+		if (ret < 0)
+			return ret;
+	}
+
+	/* @@@ initialise AVB (22/23) watchdog (27) sdet (29) registers */
+
+	return 0;
+}
+
+static int emerald_setup_port(struct dsa_switch *ds, int p)
+{
+	int addr = REG_PORT(p);
+	int ret;
+
+	/*
+	 * MAC Forcing register: don't force link, speed, duplex
+	 * or flow control state to any particular values.
+	 */
+	ret = reg_write(ds, addr, 0x01, 0x0003);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Do not limit the period of time that this port can be
+	 * paused for by the remote end or the period of time that
+	 * this port can pause the remote end.
+	 */
+	ret = reg_write(ds, addr, 0x02, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
+	 * configure the EDSA tagging mode if this is the CPU port,
+	 * disable Header mode, enable IGMP/MLD snooping, disable VLAN
+	 * tunneling, determine priority by looking at 802.1p and IP
+	 * priority fields (IP prio has precedence), and set STP state
+	 * to Forwarding.  Finally, if this is the CPU port, additionally
+	 * enable forwarding of unknown unicast and multicast addresses.
+	 */
+	ret = reg_write(ds, addr, 0x04,
+			(p == ds->cpu_port) ? 0x373f : 0x0433);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Control 1: disable trunking.  Also, if this is the
+	 * CPU port, enable learn messages to be sent to this port.
+	 */
+	ret = reg_write(ds, addr, 0x05, (p == ds->cpu_port) ? 0x8000 : 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port based VLAN map: give each port its own address
+	 * database, allow the CPU port to talk to each of the 'real'
+	 * ports, and allow each of the 'real' ports to only talk to
+	 * the CPU port.
+	 */
+	ret = reg_write(ds, addr, 0x06,
+			((p & 0xf) << 12) |
+			 ((p == ds->cpu_port) ?
+				ds->valid_port_mask :
+				(1 << ds->cpu_port)));
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Default VLAN ID and priority: don't set a default VLAN
+	 * ID, and set the default packet priority to zero.
+	 */
+	ret = reg_write(ds, addr, 0x07, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Control 2: don't force a good FCS, set the maximum
+	 * frame size to 10240 bytes, don't let the switch add or
+	 * strip 802.1q tags, don't discard tagged or untagged frames
+	 * on this port, do a destination address lookup on all
+	 * received packets as usual, disable ARP mirroring and don't
+	 * send a copy of all transmitted/received frames on this port
+	 * to the CPU.
+	 */
+	ret = reg_write(ds, addr, 0x08, 0x2080);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Egress rate control: disable egress rate control.
+	 */
+	ret = reg_write(ds, addr, 0x09, 0x0001);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Egress rate control 2: disable egress rate control.
+	 */
+	ret = reg_write(ds, addr, 0x0a, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Association Vector: when learning source addresses
+	 * of packets, add the address to the address database using
+	 * a port bitmap that has only the bit for this port set and
+	 * the other bits clear.
+	 */
+	ret = reg_write(ds, addr, 0x0b, 1 << p);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port ATU control: disable limiting the number of address
+	 * database entries that this port is allowed to use.
+	 */
+	ret = reg_write(ds, addr, 0x0c, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Priorit Override: disable DA, SA and VTU priority override.
+	 */
+	ret = reg_write(ds, addr, 0x0d, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Ethertype: use the Ethertype DSA Ethertype value.
+	 */
+	ret = reg_write(ds, addr, 0x0f, ETH_P_EDSA);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Tag Remap: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	ret = reg_write(ds, addr, 0x18, 0x3210);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Tag Remap 2: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	ret = reg_write(ds, addr, 0x19, 0x7654);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int emerald_setup(struct dsa_switch *ds)
+{
+	struct priv_state *ps = (void *)(ds + 1);
+	int i;
+	int ret;
+
+	mutex_init(&ps->smi_mutex);
+	mutex_init(&ps->ppu_mutex);
+	mutex_init(&ps->stats_mutex);
+
+	ret = marvell_switch_reset(ds);
+	if (ret < 0)
+		return ret;
+
+	/* @@@ initialise vtu and atu */
+
+	ret = emerald_setup_global(ds);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < 6; i++) {
+		ret = emerald_setup_port(ds, i);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int emerald_port_to_phy_addr(int port)
+{
+	if (port >= 0 && port <= 4)
+		return port;
+	return -1;
+}
+
+static int emerald_mii_read(struct dsa_switch *ds, int port, int regnum)
+{
+	int addr;
+
+	addr = emerald_port_to_phy_addr(port);
+	if (addr == -1)
+		return 0xffff;
+
+	return mii_read(ds, addr, regnum);
+}
+
+static int
+emerald_mii_write(struct dsa_switch *ds, int port, int regnum, u16 val)
+{
+	int addr;
+
+	addr = emerald_port_to_phy_addr(port);
+	if (addr == -1)
+		return 0xffff;
+
+	return mii_write(ds, addr, regnum, val);
+}
+
+static int emerald_set_addr_byte(struct dsa_switch *ds, int num, u8 byte)
+{
+	int ret;
+	int i;
+
+	/*
+	 * Write the MAC address byte.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x0d, 0x8000 | (num << 8) | byte);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Wait for the write to complete.
+	 */
+	for (i = 0; i < 16; i++) {
+		ret = reg_read(ds, REG_GLOBAL2, 0x0d);
+		if (ret < 0)
+			return ret;
+
+		if ((ret & 0x8000) == 0)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int emerald_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	int i;
+	int ret;
+
+	for (i = 0; i < 6; i++) {
+		ret = emerald_set_addr_byte(ds, i, addr[i]);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+#endif
+
+
+/* main *********************************************************************/
+static struct dsa_switch_driver marvell_switch_drivers[] = {
+#ifdef CONFIG_NET_DSA_EMERALD
+	{
+		.name			= "Marvell 88E6123",
+		.tag_methods		= TAG_EDSA_MASK,
+		.priv_size		= sizeof(struct priv_state),
+		.probe			= emerald6123_probe,
+		.setup			= emerald_setup,
+		.set_addr		= emerald_set_addr,
+		.mii_read		= emerald_mii_read,
+		.mii_write		= emerald_mii_write,
+		.poll_link		= marvell_poll_link,
+		.get_strings		= marvell_get_strings,
+		.get_ethtool_stats	= marvell_get_ethtool_stats,
+		.get_sset_count		= marvell_get_sset_count,
+	}, {
+		.name			= "Marvell 88E6161",
+		.tag_methods		= TAG_EDSA_MASK,
+		.priv_size		= sizeof(struct priv_state),
+		.probe			= emerald6161_probe,
+		.setup			= emerald_setup,
+		.set_addr		= emerald_set_addr,
+		.mii_read		= emerald_mii_read,
+		.mii_write		= emerald_mii_write,
+		.poll_link		= marvell_poll_link,
+		.get_strings		= marvell_get_strings,
+		.get_ethtool_stats	= marvell_get_ethtool_stats,
+		.get_sset_count		= marvell_get_sset_count,
+	}, {
+		.name			= "Marvell 88E6165",
+		.tag_methods		= TAG_EDSA_MASK,
+		.priv_size		= sizeof(struct priv_state),
+		.probe			= emerald6165_probe,
+		.setup			= emerald_setup,
+		.set_addr		= emerald_set_addr,
+		.mii_read		= emerald_mii_read,
+		.mii_write		= emerald_mii_write,
+		.poll_link		= marvell_poll_link,
+		.get_strings		= marvell_get_strings,
+		.get_ethtool_stats	= marvell_get_ethtool_stats,
+		.get_sset_count		= marvell_get_sset_count,
+	},
+#endif
+};
+
+int __init marvell_init(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(marvell_switch_drivers); i++)
+		register_switch_driver(&marvell_switch_drivers[i]);
+
+	return 0;
+}
+module_init(marvell_init);
+
+void __exit marvell_cleanup(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(marvell_switch_drivers); i++)
+		unregister_switch_driver(&marvell_switch_drivers[i]);
+}
+module_exit(marvell_cleanup);
+
+MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>")
+MODULE_DESCRIPTION("Driver for Marvell switch chips");
+MODULE_LICENSE("GPL");
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
new file mode 100644
index 0000000..8273e15
--- /dev/null
+++ b/net/dsa/slave.c
@@ -0,0 +1,279 @@
+/*
+ * net/dsa/slave.c - Slave device handling
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/rtnetlink.h>
+#include <net/dsa.h>
+#include "dsa_priv.h"
+
+/* slave mii_bus handling ***************************************************/
+static int dsa_slave_mii_read(struct mii_bus *bus, int addr, int reg)
+{
+	struct dsa_switch *ds = bus->priv;
+
+	if (ds->valid_port_mask & (1 << addr))
+		return ds->drv->mii_read(ds, addr, reg);
+
+	return 0xffff;
+}
+
+static int dsa_slave_mii_write(struct mii_bus *bus, int addr, int reg, u16 val)
+{
+	struct dsa_switch *ds = bus->priv;
+
+	if (ds->valid_port_mask & (1 << addr))
+		return ds->drv->mii_write(ds, addr, reg, val);
+
+	return 0;
+}
+
+void dsa_slave_mii_bus_init(struct dsa_switch *ds)
+{
+	ds->slave_mii_bus.priv = (void *)ds;
+	ds->slave_mii_bus.name = "dsa slave smi";
+	ds->slave_mii_bus.read = dsa_slave_mii_read;
+	ds->slave_mii_bus.write = dsa_slave_mii_write;
+	snprintf(ds->slave_mii_bus.id, MII_BUS_ID_SIZE, "%s:%.2x",
+			ds->mii_bus->id, ds->sw_addr);
+	ds->slave_mii_bus.parent = &(ds->mii_bus->dev);
+}
+
+
+/* slave device handling ****************************************************/
+static int dsa_slave_open(struct net_device *dev)
+{
+	return 0;
+}
+
+static int dsa_slave_close(struct net_device *dev)
+{
+	return 0;
+}
+
+static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = p->parent->master_dev;
+
+	if (change & IFF_ALLMULTI)
+		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
+	if (change & IFF_PROMISC)
+		dev_set_promiscuity(master, dev->flags & IFF_PROMISC ? 1 : -1);
+}
+
+static void dsa_slave_set_rx_mode(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = p->parent->master_dev;
+
+	dev_mc_sync(master, dev);
+	dev_unicast_sync(master, dev);
+}
+
+static int dsa_slave_set_mac_address(struct net_device *dev, void *addr)
+{
+	memcpy(dev->dev_addr, addr + 2, 6);
+
+	return 0;
+}
+
+static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct mii_ioctl_data *mii_data = if_mii(ifr);
+
+	if (p->phy != NULL)
+		return phy_mii_ioctl(p->phy, mii_data, cmd);
+
+	return -EOPNOTSUPP;
+}
+
+
+/* ethtool operations *******************************************************/
+static int
+dsa_slave_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	int err;
+
+	err = -EOPNOTSUPP;
+	if (p->phy != NULL) {
+		err = phy_read_status(p->phy);
+		if (err == 0)
+			err = phy_ethtool_gset(p->phy, cmd);
+	}
+
+	return err;
+}
+
+static int
+dsa_slave_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (p->phy != NULL)
+		return phy_ethtool_sset(p->phy, cmd);
+
+	return -EOPNOTSUPP;
+}
+
+static void dsa_slave_get_drvinfo(struct net_device *dev,
+				  struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver, "dsa", 32);
+	strncpy(drvinfo->version, dsa_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "platform", 32);
+}
+
+static int dsa_slave_nway_reset(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (p->phy != NULL)
+		return genphy_restart_aneg(p->phy);
+
+	return -EOPNOTSUPP;
+}
+
+static u32 dsa_slave_get_link(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (p->phy != NULL) {
+		genphy_update_link(p->phy);
+		return p->phy->link;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static void dsa_slave_get_strings(struct net_device *dev,
+				  uint32_t stringset, uint8_t *data)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (stringset == ETH_SS_STATS) {
+		int len = ETH_GSTRING_LEN;
+
+		strncpy(data, "tx_packets", len);
+		strncpy(data + len, "tx_bytes", len);
+		strncpy(data + 2 * len, "rx_packets", len);
+		strncpy(data + 3 * len, "rx_bytes", len);
+		p->parent->drv->get_strings(p->parent, p->port, data + 4 * len);
+	}
+}
+
+static void dsa_slave_get_ethtool_stats(struct net_device *dev,
+					struct ethtool_stats *stats,
+					uint64_t *data)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	data[0] = p->dev->stats.tx_packets;
+	data[1] = p->dev->stats.tx_bytes;
+	data[2] = p->dev->stats.rx_packets;
+	data[3] = p->dev->stats.rx_bytes;
+	p->parent->drv->get_ethtool_stats(p->parent, p->port, data + 4);
+}
+
+static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (sset == ETH_SS_STATS)
+		return p->parent->drv->get_sset_count(p->parent) + 4;
+
+	return -EOPNOTSUPP;
+}
+
+static const struct ethtool_ops dsa_slave_ethtool_ops = {
+	.get_settings		= dsa_slave_get_settings,
+	.set_settings		= dsa_slave_set_settings,
+	.get_drvinfo		= dsa_slave_get_drvinfo,
+	.nway_reset		= dsa_slave_nway_reset,
+	.get_link		= dsa_slave_get_link,
+	.set_sg			= ethtool_op_set_sg,
+	.get_strings		= dsa_slave_get_strings,
+	.get_ethtool_stats	= dsa_slave_get_ethtool_stats,
+	.get_sset_count		= dsa_slave_get_sset_count,
+};
+
+
+/* slave device setup *******************************************************/
+struct net_device *dsa_slave_create(struct dsa_switch *ds, int port)
+{
+	struct net_device *master = ds->master_dev;
+	struct net_device *slave_dev;
+	struct dsa_slave_priv *p;
+	int ret;
+
+	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv) +
+					ds->drv->priv_port_size,
+				 ds->pdata->port_names[port], ether_setup);
+	if (slave_dev == NULL)
+		return slave_dev;
+
+	slave_dev->features = master->vlan_features;
+	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
+	slave_dev->tx_queue_len = 0;
+	slave_dev->open = dsa_slave_open;
+	slave_dev->stop = dsa_slave_close;
+	switch (ds->tag_type) {
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+	case TAG_EDSA_MASK:
+		slave_dev->hard_start_xmit = edsa_xmit;
+		break;
+#endif
+	default:
+		BUG();
+	}
+	slave_dev->change_rx_flags = dsa_slave_change_rx_flags;
+	slave_dev->set_rx_mode = dsa_slave_set_rx_mode;
+	slave_dev->set_multicast_list = dsa_slave_set_rx_mode;
+	slave_dev->set_mac_address = dsa_slave_set_mac_address;
+	slave_dev->do_ioctl = dsa_slave_ioctl;
+	slave_dev->vlan_features = master->vlan_features;
+	SET_ETHTOOL_OPS(slave_dev, &dsa_slave_ethtool_ops);
+
+	p = netdev_priv(slave_dev);
+	p->dev = slave_dev;
+	p->parent = ds;
+	p->port = port;
+	p->phy = ds->slave_mii_bus.phy_map[port];
+
+	ret = register_netdev(slave_dev);
+	if (ret) {
+		printk(KERN_ERR "%s: error %d registering interface %s\n",
+				master->name, ret, slave_dev->name);
+		free_netdev(slave_dev);
+		return NULL;
+	}
+
+	netif_carrier_off(slave_dev);
+
+	if (p->phy != NULL) {
+		phy_attach(slave_dev, p->phy->dev.bus_id,
+			   0, PHY_INTERFACE_MODE_GMII);
+
+		p->phy->autoneg = AUTONEG_ENABLE;
+		p->phy->speed = 0;
+		p->phy->duplex = 0;
+		p->phy->advertising = p->phy->supported | ADVERTISED_Autoneg;
+		phy_start_aneg(p->phy);
+	}
+
+	return slave_dev;
+}
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
new file mode 100644
index 0000000..c3b3855
--- /dev/null
+++ b/net/dsa/tag_edsa.c
@@ -0,0 +1,222 @@
+/*
+ * net/dsa/edsa.c - Ethertype DSA tagging
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/rtnetlink.h>
+#include <net/dsa.h>
+#include "dsa_priv.h"
+
+#define DSA_HLEN	4
+#define EDSA_HLEN	8
+
+int edsa_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	char *edsa_header;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	/*
+	 * Convert the outermost 802.1q tag to a DSA tag and prepend
+	 * a DSA ethertype field is the packet is tagged, or insert
+	 * a DSA ethertype plus DSA tag between the addresses and the
+	 * current ethertype field if the packet is untagged.
+	 */
+	if (skb->protocol == htons(ETH_P_8021Q)) {
+		if (skb_cow_head(skb, DSA_HLEN) < 0)
+			goto out_free;
+		skb_push(skb, DSA_HLEN);
+
+		memmove(skb->data, skb->data + DSA_HLEN, 2 * ETH_ALEN);
+
+		/*
+		 * Construct tagged FROM_CPU DSA tag from 802.1q tag.
+		 */
+		edsa_header = skb->data + 2 * ETH_ALEN;
+		edsa_header[0] = (ETH_P_EDSA >> 8) & 0xff;
+		edsa_header[1] = ETH_P_EDSA & 0xff;
+		edsa_header[2] = 0x00;
+		edsa_header[3] = 0x00;
+		edsa_header[4] = 0x60;
+		edsa_header[5] = p->port << 3;
+
+		/*
+		 * Move CFI field from byte 6 to byte 5.
+		 */
+		if (edsa_header[6] & 0x10) {
+			edsa_header[5] |= 0x01;
+			edsa_header[6] &= ~0x10;
+		}
+	} else {
+		if (skb_cow_head(skb, EDSA_HLEN) < 0)
+			goto out_free;
+		skb_push(skb, EDSA_HLEN);
+
+		memmove(skb->data, skb->data + EDSA_HLEN, 2 * ETH_ALEN);
+
+		/*
+		 * Construct untagged FROM_CPU DSA tag.
+		 */
+		edsa_header = skb->data + 2 * ETH_ALEN;
+		edsa_header[0] = (ETH_P_EDSA >> 8) & 0xff;
+		edsa_header[1] = ETH_P_EDSA & 0xff;
+		edsa_header[2] = 0x00;
+		edsa_header[3] = 0x00;
+		edsa_header[4] = 0x40;
+		edsa_header[5] = p->port << 3;
+		edsa_header[6] = 0x00;
+		edsa_header[7] = 0x00;
+	}
+
+	skb->protocol = htons(ETH_P_EDSA);
+
+	skb->dev = p->parent->master_dev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+
+out_free:
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
+		    struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct dsa_switch *ds = dev->dsa_ptr;
+	u8 *edsa_header;
+	int source_port;
+
+	if (unlikely(ds == NULL))
+		goto out_drop;
+
+	skb = skb_unshare(skb, GFP_ATOMIC);
+	if (skb == NULL)
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, EDSA_HLEN)))
+		goto out_drop;
+
+	/*
+	 * Skip the two null bytes after the ethertype.
+	 */
+	edsa_header = skb->data + 2;
+
+	/*
+	 * Check that frame type is either TO_CPU or FORWARD, and
+	 * that the source device is zero.
+	 */
+	if ((edsa_header[0] & 0xdf) != 0x00 && (edsa_header[0] & 0xdf) != 0xc0)
+		goto out_drop;
+
+	/*
+	 * Check that the source port is a registered DSA port.
+	 */
+	source_port = (edsa_header[1] >> 3) & 0x1f;
+	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+		goto out_drop;
+
+	/*
+	 * If the 'tagged' bit is set, convert the DSA tag to a 802.1q
+	 * tag and delete the ethertype part.  If the 'tagged' bit is
+	 * clear, delete the ethertype and the DSA tag parts.
+	 */
+	if (edsa_header[0] & 0x20) {
+		u8 new_header[4];
+
+		/*
+		 * Insert 802.1q ethertype and copy the VLAN-related
+		 * fields, but clear the bit that will hold CFI (since
+		 * DSA uses that bit location for another purpose).
+		 */
+		new_header[0] = (ETH_P_8021Q >> 8) & 0xff;
+		new_header[1] = ETH_P_8021Q & 0xff;
+		new_header[2] = edsa_header[2] & ~0x10;
+		new_header[3] = edsa_header[3];
+
+		/*
+		 * Move CFI bit from its place in the DSA header to
+		 * its 802.1q-designated place.
+		 */
+		if (edsa_header[1] & 0x01)
+			new_header[2] |= 0x10;
+
+		skb_pull_rcsum(skb, DSA_HLEN);
+
+		/*
+		 * Update packet checksum if skb is CHECKSUM_COMPLETE.
+		 */
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			__wsum c = skb->csum;
+			c = csum_add(c, csum_partial(new_header + 2, 2, 0));
+			c = csum_sub(c, csum_partial(edsa_header + 2, 2, 0));
+			skb->csum = c;
+		}
+
+		memcpy(edsa_header, new_header, DSA_HLEN);
+
+		memmove(skb->data - ETH_HLEN,
+			skb->data - ETH_HLEN - DSA_HLEN,
+			2 * ETH_ALEN);
+	} else {
+		/*
+		 * Remove DSA tag and update checksum.
+		 */
+		skb_pull_rcsum(skb, EDSA_HLEN);
+		memmove(skb->data - ETH_HLEN,
+			skb->data - ETH_HLEN - EDSA_HLEN,
+			2 * ETH_ALEN);
+	}
+
+	skb->dev = ds->ports[source_port];
+	skb_push(skb, ETH_HLEN);
+	skb->protocol = eth_type_trans(skb, skb->dev);
+
+	skb->dev->last_rx = jiffies;
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
+
+	netif_receive_skb(skb);
+
+	return 0;
+
+out_drop:
+	kfree_skb(skb);
+out:
+	return 0;
+}
+
+static struct packet_type edsa_packet_type = {
+	.type	= __constant_htons(ETH_P_EDSA),
+	.func	= edsa_rcv,
+};
+
+static int __init edsa_init_module(void)
+{
+	dev_add_pack(&edsa_packet_type);
+	return 0;
+}
+module_init(edsa_init_module);
+
+static void __exit edsa_cleanup_module(void)
+{
+	dev_remove_pack(&edsa_packet_type);
+}
+module_exit(edsa_cleanup_module);
+
+MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
+MODULE_DESCRIPTION("Ethertype DSA tagging");
+MODULE_LICENSE("GPL");
-- 
1.5.6.4
