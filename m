From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] cfg80211: new wireless config infrastructure
Date: Mon, 23 Apr 2007 14:36:34 -0400
Message-ID: <20070423183634.GE5883@tuxdriver.com>
References: <20070423183334.GC5883@tuxdriver.com> <20070423183443.GD5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070423183443.GD5883-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

This patch creates the core cfg80211 code along with some sysfs bits.
This is a stripped down version to allow mac80211 to function, but
doesn't include any configuration yet except for creating and removing
virtual interfaces.

This patch includes the nl80211 header file but it only contains the
interface types which the cfg80211 interface for creating virtual
interfaces relies on.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 CREDITS                   |    6 ++
 MAINTAINERS               |    6 ++
 include/linux/Kbuild      |    1 +
 include/linux/netdevice.h |    4 +
 include/linux/nl80211.h   |   38 ++++++++
 include/net/cfg80211.h    |   36 ++++++++
 include/net/wireless.h    |  139 ++++++++++++++++++++++++++++++
 net/wireless/Kconfig      |    3 +
 net/wireless/Makefile     |    4 +-
 net/wireless/core.c       |  209 +++++++++++++++++++++++++++++++++++++++++++++
 net/wireless/core.h       |   49 +++++++++++
 net/wireless/sysfs.c      |   80 +++++++++++++++++
 net/wireless/sysfs.h      |    9 ++
 13 files changed, 583 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/nl80211.h
 create mode 100644 include/net/cfg80211.h
 create mode 100644 include/net/wireless.h
 create mode 100644 net/wireless/core.c
 create mode 100644 net/wireless/core.h
 create mode 100644 net/wireless/sysfs.c
 create mode 100644 net/wireless/sysfs.h

diff --git a/CREDITS b/CREDITS
index e3e7271..dede114 100644
--- a/CREDITS
+++ b/CREDITS
@@ -317,6 +317,12 @@ S: 2322 37th Ave SW
 S: Seattle, Washington 98126-2010
 S: USA
 
+N: Johannes Berg
+E: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
+W: http://johannes.sipsolutions.net/
+P: 1024D/9AB78CA5 AD02 0176 4E29 C137 1DF6 08D2 FC44 CF86 9AB7 8CA5
+D: powerpc & 802.11 hacker
+
 N: Stephen R. van den Berg (AKA BuGless)
 E: berg-C+EoYKesnrCVdxy9aTz+TbwNW4aj8/RQWV23jfQ1LcY@public.gmane.org
 D: General kernel, gcc, and libc hacker
diff --git a/MAINTAINERS b/MAINTAINERS
index a15ec1a..3994eee 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -894,6 +894,12 @@ M:	maxextreme-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
 L:	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Maintained
 
+CFG80211 and NL80211
+P:	Johannes Berg
+M:	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
+L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Maintained
+
 COMMON INTERNET FILE SYSTEM (CIFS)
 P:	Steve French
 M:	sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index ea86f2e..4ff0f57 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -113,6 +113,7 @@ header-y += netrom.h
 header-y += nfs2.h
 header-y += nfs4_mount.h
 header-y += nfs_mount.h
+header-y += nl80211.h
 header-y += oom.h
 header-y += param.h
 header-y += pci_regs.h
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 71fc8ff..584c199 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -42,6 +42,8 @@
 struct vlan_group;
 struct ethtool_ops;
 struct netpoll_info;
+/* 802.11 specific */
+struct wireless_dev;
 					/* source back-compat hooks */
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
@@ -400,6 +402,8 @@ struct net_device
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
 	void			*ax25_ptr;	/* AX.25 specific data */
+	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
+						   assign before registering */
 
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
diff --git a/include/linux/nl80211.h b/include/linux/nl80211.h
new file mode 100644
index 0000000..9a30ba2
--- /dev/null
+++ b/include/linux/nl80211.h
@@ -0,0 +1,38 @@
+#ifndef __LINUX_NL80211_H
+#define __LINUX_NL80211_H
+/*
+ * 802.11 netlink interface public header
+ *
+ * Copyright 2006, 2007 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ */
+
+/**
+ * enum nl80211_iftype - (virtual) interface types
+ * @NL80211_IFTYPE_UNSPECIFIED: unspecified type, driver decides
+ * @NL80211_IFTYPE_ADHOC: independent BSS member
+ * @NL80211_IFTYPE_STATION: managed BSS member
+ * @NL80211_IFTYPE_AP: access point
+ * @NL80211_IFTYPE_AP_VLAN: VLAN interface for access points
+ * @NL80211_IFTYPE_WDS: wireless distribution interface
+ * @NL80211_IFTYPE_MONITOR: monitor interface receiving all frames
+ * @__NL80211_IFTYPE_AFTER_LAST: internal use
+ *
+ * These values are used with the NL80211_ATTR_IFTYPE
+ * to set the type of an interface.
+ *
+ */
+enum nl80211_iftype {
+	NL80211_IFTYPE_UNSPECIFIED,
+	NL80211_IFTYPE_ADHOC,
+	NL80211_IFTYPE_STATION,
+	NL80211_IFTYPE_AP,
+	NL80211_IFTYPE_AP_VLAN,
+	NL80211_IFTYPE_WDS,
+	NL80211_IFTYPE_MONITOR,
+
+	/* keep last */
+	__NL80211_IFTYPE_AFTER_LAST
+};
+#define NL80211_IFTYPE_MAX (__NL80211_IFTYPE_AFTER_LAST - 1)
+
+#endif /* __LINUX_NL80211_H */
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
new file mode 100644
index 0000000..783a114
--- /dev/null
+++ b/include/net/cfg80211.h
@@ -0,0 +1,36 @@
+#ifndef __NET_CFG80211_H
+#define __NET_CFG80211_H
+
+#include <linux/netlink.h>
+#include <linux/skbuff.h>
+#include <net/genetlink.h>
+
+/*
+ * 802.11 configuration in-kernel interface
+ *
+ * Copyright 2006 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ */
+
+/* from net/wireless.h */
+struct wiphy;
+
+/**
+ * struct cfg80211_ops - backend description for wireless configuration
+ *
+ * This struct is registered by fullmac card drivers and/or wireless stacks
+ * in order to handle configuration requests on their interfaces.
+ *
+ * All callbacks except where otherwise noted should return 0
+ * on success or a negative error code.
+ *
+ * @add_virtual_intf: create a new virtual interface with the given name
+ *
+ * @del_virtual_intf: remove the virtual interface determined by ifindex.
+ */
+struct cfg80211_ops {
+	int	(*add_virtual_intf)(struct wiphy *wiphy, char *name,
+				    unsigned int type);
+	int	(*del_virtual_intf)(struct wiphy *wiphy, int ifindex);
+};
+
+#endif /* __NET_CFG80211_H */
diff --git a/include/net/wireless.h b/include/net/wireless.h
new file mode 100644
index 0000000..d30c4ba
--- /dev/null
+++ b/include/net/wireless.h
@@ -0,0 +1,139 @@
+#ifndef __NET_WIRELESS_H
+#define __NET_WIRELESS_H
+
+/*
+ * 802.11 device management
+ *
+ * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ */
+
+#include <linux/netdevice.h>
+#include <linux/debugfs.h>
+#include <linux/list.h>
+#include <net/cfg80211.h>
+
+/**
+ * struct wiphy - wireless hardware description
+ * @idx: the wiphy index assigned to this item
+ * @class_dev: the class device representing /sys/class/ieee80211/<wiphy-name>
+ */
+struct wiphy {
+	/* assign these fields before you register the wiphy */
+
+	/* permanent MAC address */
+	u8 perm_addr[ETH_ALEN];
+
+	/* If multiple wiphys are registered and you're handed e.g.
+	 * a regular netdev with assigned ieee80211_ptr, you won't
+	 * know whether it points to a wiphy your driver has registered
+	 * or not. Assign this to something global to your driver to
+	 * help determine whether you own this wiphy or not. */
+	void *privid;
+
+	/* fields below are read-only, assigned by cfg80211 */
+
+	/* the item in /sys/class/ieee80211/ points to this,
+	 * you need use set_wiphy_dev() (see below) */
+	struct device dev;
+
+	/* dir in debugfs: ieee80211/<wiphyname> */
+	struct dentry *debugfsdir;
+
+	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
+};
+
+/** struct wireless_dev - wireless per-netdev state
+ *
+ * This structure must be allocated by the driver/stack
+ * that uses the ieee80211_ptr field in struct net_device
+ * (this is intentional so it can be allocated along with
+ * the netdev.)
+ *
+ * @wiphy: pointer to hardware description
+ */
+struct wireless_dev {
+	struct wiphy *wiphy;
+
+	/* private to the generic wireless code */
+	struct list_head list;
+	struct net_device *netdev;
+};
+
+/**
+ * wiphy_priv - return priv from wiphy
+ */
+static inline void *wiphy_priv(struct wiphy *wiphy)
+{
+	BUG_ON(!wiphy);
+	return &wiphy->priv;
+}
+
+/**
+ * set_wiphy_dev - set device pointer for wiphy
+ */
+static inline void set_wiphy_dev(struct wiphy *wiphy, struct device *dev)
+{
+	wiphy->dev.parent = dev;
+}
+
+/**
+ * wiphy_dev - get wiphy dev pointer
+ */
+static inline struct device *wiphy_dev(struct wiphy *wiphy)
+{
+	return wiphy->dev.parent;
+}
+
+/**
+ * wiphy_name - get wiphy name
+ */
+static inline char *wiphy_name(struct wiphy *wiphy)
+{
+	return wiphy->dev.bus_id;
+}
+
+/**
+ * wdev_priv - return wiphy priv from wireless_dev
+ */
+static inline void *wdev_priv(struct wireless_dev *wdev)
+{
+	BUG_ON(!wdev);
+	return wiphy_priv(wdev->wiphy);
+}
+
+/**
+ * wiphy_new - create a new wiphy for use with cfg80211
+ *
+ * create a new wiphy and associate the given operations with it.
+ * @sizeof_priv bytes are allocated for private use.
+ *
+ * the returned pointer must be assigned to each netdev's
+ * ieee80211_ptr for proper operation.
+ */
+struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv);
+
+/**
+ * wiphy_register - register a wiphy with cfg80211
+ *
+ * register the given wiphy
+ *
+ * Returns a non-negative wiphy index or a negative error code.
+ */
+extern int wiphy_register(struct wiphy *wiphy);
+
+/**
+ * wiphy_unregister - deregister a wiphy from cfg80211
+ *
+ * unregister a device with the given priv pointer.
+ * After this call, no more requests can be made with this priv
+ * pointer, but the call may sleep to wait for an outstanding
+ * request that is being handled.
+ */
+extern void wiphy_unregister(struct wiphy *wiphy);
+
+/**
+ * wiphy_free - free wiphy
+ */
+extern void wiphy_free(struct wiphy *wiphy);
+
+#endif /* __NET_WIRELESS_H */
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index ca2f05c..1863c0b 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -1,3 +1,6 @@
+config CFG80211
+        tristate "Improved wireless configuration API"
+
 config WIRELESS_EXT
 	bool "Wireless extensions"
 	default n
diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index cf4e3d9..3f082ff 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -1 +1,3 @@
-# dummy file for now
+obj-$(CONFIG_CFG80211) += cfg80211.o
+
+cfg80211-y += core.o sysfs.o
diff --git a/net/wireless/core.c b/net/wireless/core.c
new file mode 100644
index 0000000..532e1e0
--- /dev/null
+++ b/net/wireless/core.c
@@ -0,0 +1,209 @@
+/*
+ * This is the linux wireless configuration interface.
+ *
+ * Copyright 2006, 2007		Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ */
+
+#include <linux/if.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/nl80211.h>
+#include <linux/debugfs.h>
+#include <linux/notifier.h>
+#include <linux/device.h>
+#include <net/genetlink.h>
+#include <net/cfg80211.h>
+#include <net/wireless.h>
+#include "core.h"
+#include "sysfs.h"
+
+/* name for sysfs, %d is appended */
+#define PHY_NAME "phy"
+
+MODULE_AUTHOR("Johannes Berg");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("wireless configuration support");
+
+/* RCU might be appropriate here since we usually
+ * only read the list, and that can happen quite
+ * often because we need to do it for each command */
+LIST_HEAD(cfg80211_drv_list);
+DEFINE_MUTEX(cfg80211_drv_mutex);
+static int wiphy_counter;
+
+/* for debugfs */
+static struct dentry *ieee80211_debugfs_dir;
+
+/* exported functions */
+
+struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv)
+{
+	struct cfg80211_registered_device *drv;
+	int alloc_size;
+
+	alloc_size = sizeof(*drv) + sizeof_priv;
+
+	drv = kzalloc(alloc_size, GFP_KERNEL);
+	if (!drv)
+		return NULL;
+
+	drv->ops = ops;
+
+	mutex_lock(&cfg80211_drv_mutex);
+
+	if (unlikely(wiphy_counter<0)) {
+		/* ugh, wrapped! */
+		kfree(drv);
+		return NULL;
+	}
+	drv->idx = wiphy_counter;
+
+	/* give it a proper name */
+	snprintf(drv->wiphy.dev.bus_id, BUS_ID_SIZE,
+		 PHY_NAME "%d", drv->idx);
+
+	/* now increase counter for the next time */
+	wiphy_counter++;
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	mutex_init(&drv->mtx);
+	mutex_init(&drv->devlist_mtx);
+	INIT_LIST_HEAD(&drv->netdev_list);
+
+	device_initialize(&drv->wiphy.dev);
+	drv->wiphy.dev.class = &ieee80211_class;
+	drv->wiphy.dev.platform_data = drv;
+
+	return &drv->wiphy;
+}
+EXPORT_SYMBOL(wiphy_new);
+
+int wiphy_register(struct wiphy *wiphy)
+{
+	struct cfg80211_registered_device *drv = wiphy_to_dev(wiphy);
+	int res;
+
+	mutex_lock(&cfg80211_drv_mutex);
+
+
+	res = device_add(&drv->wiphy.dev);
+	if (res)
+		goto out_unlock;
+
+	list_add(&drv->list, &cfg80211_drv_list);
+
+	/* add to debugfs */
+	drv->wiphy.debugfsdir =
+		debugfs_create_dir(wiphy_name(&drv->wiphy),
+				   ieee80211_debugfs_dir);
+
+	res = 0;
+out_unlock:
+	mutex_unlock(&cfg80211_drv_mutex);
+	return res;
+}
+EXPORT_SYMBOL(wiphy_register);
+
+void wiphy_unregister(struct wiphy *wiphy)
+{
+	struct cfg80211_registered_device *drv = wiphy_to_dev(wiphy);
+
+	mutex_lock(&cfg80211_drv_mutex);
+
+	/* hold registered driver mutex during list removal as well
+	 * to make sure no commands are in progress at the moment */
+	mutex_lock(&drv->mtx);
+	list_del(&drv->list);
+	mutex_unlock(&drv->mtx);
+
+	device_del(&drv->wiphy.dev);
+	debugfs_remove(drv->wiphy.debugfsdir);
+
+	mutex_unlock(&cfg80211_drv_mutex);
+}
+EXPORT_SYMBOL(wiphy_unregister);
+
+void cfg80211_dev_free(struct cfg80211_registered_device *drv)
+{
+	mutex_destroy(&drv->mtx);
+	mutex_destroy(&drv->devlist_mtx);
+	kfree(drv);
+}
+
+void wiphy_free(struct wiphy *wiphy)
+{
+	put_device(&wiphy->dev);
+}
+EXPORT_SYMBOL(wiphy_free);
+
+static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
+					 unsigned long state,
+					 void *ndev)
+{
+	struct net_device *dev = ndev;
+	struct cfg80211_registered_device *rdev;
+
+	if (!dev->ieee80211_ptr)
+		return 0;
+
+	rdev = wiphy_to_dev(dev->ieee80211_ptr->wiphy);
+
+	switch (state) {
+	case NETDEV_REGISTER:
+		mutex_lock(&rdev->devlist_mtx);
+		list_add(&dev->ieee80211_ptr->list, &rdev->netdev_list);
+		if (sysfs_create_link(&dev->dev.kobj, &rdev->wiphy.dev.kobj,
+				      "phy80211")) {
+			printk(KERN_ERR "wireless: failed to add phy80211 "
+				"symlink to netdev!\n");
+		}
+		dev->ieee80211_ptr->netdev = dev;
+		mutex_unlock(&rdev->devlist_mtx);
+		break;
+	case NETDEV_UNREGISTER:
+		mutex_lock(&rdev->devlist_mtx);
+		if (!list_empty(&dev->ieee80211_ptr->list)) {
+			sysfs_remove_link(&dev->dev.kobj, "phy80211");
+			list_del_init(&dev->ieee80211_ptr->list);
+		}
+		mutex_unlock(&rdev->devlist_mtx);
+		break;
+	}
+
+	return 0;
+}
+
+static struct notifier_block cfg80211_netdev_notifier = {
+	.notifier_call = cfg80211_netdev_notifier_call,
+};
+
+static int cfg80211_init(void)
+{
+	int err = wiphy_sysfs_init();
+	if (err)
+		goto out_fail_sysfs;
+
+	err = register_netdevice_notifier(&cfg80211_netdev_notifier);
+	if (err)
+		goto out_fail_notifier;
+
+	ieee80211_debugfs_dir = debugfs_create_dir("ieee80211", NULL);
+
+	return 0;
+
+out_fail_notifier:
+	wiphy_sysfs_exit();
+out_fail_sysfs:
+	return err;
+}
+module_init(cfg80211_init);
+
+static void cfg80211_exit(void)
+{
+	debugfs_remove(ieee80211_debugfs_dir);
+	unregister_netdevice_notifier(&cfg80211_netdev_notifier);
+	wiphy_sysfs_exit();
+}
+module_exit(cfg80211_exit);
diff --git a/net/wireless/core.h b/net/wireless/core.h
new file mode 100644
index 0000000..158db1e
--- /dev/null
+++ b/net/wireless/core.h
@@ -0,0 +1,49 @@
+/*
+ * Wireless configuration interface internals.
+ *
+ * Copyright 2006, 2007 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ */
+#ifndef __NET_WIRELESS_CORE_H
+#define __NET_WIRELESS_CORE_H
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <net/genetlink.h>
+#include <net/wireless.h>
+#include <net/cfg80211.h>
+
+struct cfg80211_registered_device {
+	struct cfg80211_ops *ops;
+	struct list_head list;
+	/* we hold this mutex during any call so that
+	 * we cannot do multiple calls at once, and also
+	 * to avoid the deregister call to proceed while
+	 * any call is in progress */
+	struct mutex mtx;
+
+	/* wiphy index, internal only */
+	int idx;
+
+	/* associate netdev list */
+	struct mutex devlist_mtx;
+	struct list_head netdev_list;
+
+	/* must be last because of the way we do wiphy_priv(),
+	 * and it should at least be aligned to NETDEV_ALIGN */
+	struct wiphy wiphy __attribute__((__aligned__(NETDEV_ALIGN)));
+};
+
+static inline
+struct cfg80211_registered_device *wiphy_to_dev(struct wiphy *wiphy)
+{
+	BUG_ON(!wiphy);
+	return container_of(wiphy, struct cfg80211_registered_device, wiphy);
+}
+
+extern struct mutex cfg80211_drv_mutex;
+extern struct list_head cfg80211_drv_list;
+
+/* free object */
+extern void cfg80211_dev_free(struct cfg80211_registered_device *drv);
+
+#endif /* __NET_WIRELESS_CORE_H */
diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
new file mode 100644
index 0000000..3ebae14
--- /dev/null
+++ b/net/wireless/sysfs.c
@@ -0,0 +1,80 @@
+/*
+ * This file provides /sys/class/ieee80211/<wiphy name>/
+ * and some default attributes.
+ *
+ * Copyright 2005-2006	Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
+ * Copyright 2006	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ *
+ * This file is GPLv2 as found in COPYING.
+ */
+
+#include <linux/device.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/nl80211.h>
+#include <linux/rtnetlink.h>
+#include <net/cfg80211.h>
+#include "sysfs.h"
+#include "core.h"
+
+static inline struct cfg80211_registered_device *dev_to_rdev(
+	struct device *dev)
+{
+	return container_of(dev, struct cfg80211_registered_device, wiphy.dev);
+}
+
+static ssize_t _show_index(struct device *dev, struct device_attribute *attr,
+			   char *buf)
+{
+	return sprintf(buf, "%d\n", dev_to_rdev(dev)->idx);
+}
+
+static ssize_t _show_permaddr(struct device *dev,
+			      struct device_attribute *attr,
+			      char *buf)
+{
+	char *addr = dev_to_rdev(dev)->wiphy.perm_addr;
+
+	return sprintf(buf, "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\n",
+		       addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+}
+
+static struct device_attribute ieee80211_dev_attrs[] = {
+	__ATTR(index, S_IRUGO, _show_index, NULL),
+	__ATTR(macaddress, S_IRUGO, _show_permaddr, NULL),
+	{}
+};
+
+static void wiphy_dev_release(struct device *dev)
+{
+	struct cfg80211_registered_device *rdev = dev_to_rdev(dev);
+
+	cfg80211_dev_free(rdev);
+}
+
+static int wiphy_uevent(struct device *dev, char **envp,
+			int num_envp, char *buf, int size)
+{
+	/* TODO, we probably need stuff here */
+	return 0;
+}
+
+struct class ieee80211_class = {
+	.name = "ieee80211",
+	.owner = THIS_MODULE,
+	.dev_release = wiphy_dev_release,
+	.dev_attrs = ieee80211_dev_attrs,
+#ifdef CONFIG_HOTPLUG
+	.dev_uevent = wiphy_uevent,
+#endif
+};
+
+int wiphy_sysfs_init(void)
+{
+	return class_register(&ieee80211_class);
+}
+
+void wiphy_sysfs_exit(void)
+{
+	class_unregister(&ieee80211_class);
+}
diff --git a/net/wireless/sysfs.h b/net/wireless/sysfs.h
new file mode 100644
index 0000000..65acbeb
--- /dev/null
+++ b/net/wireless/sysfs.h
@@ -0,0 +1,9 @@
+#ifndef __WIRELESS_SYSFS_H
+#define __WIRELESS_SYSFS_H
+
+extern int wiphy_sysfs_init(void);
+extern void wiphy_sysfs_exit(void);
+
+extern struct class ieee80211_class;
+
+#endif /* __WIRELESS_SYSFS_H */
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
