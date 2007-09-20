From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'nl80211' branch of wireless-2.6
Date: Thu, 20 Sep 2007 15:12:45 -0400
Message-ID: <20070920191245.GJ6748@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3974 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbXITTjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 15:39:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

This patch adds the basic nl80211 infrastructure.

Thanks!

John

---

Patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/nl80211/0001-nl80211-add-netlink-interface-to-cfg80211.patch

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git nl80211

Johannes Berg (1):
      nl80211: add netlink interface to cfg80211

 include/linux/nl80211.h      |   97 +++++++++-
 include/net/cfg80211.h       |   11 +-
 include/net/iw_handler.h     |    8 +-
 net/mac80211/ieee80211_cfg.c |    2 +-
 net/wireless/Kconfig         |   17 ++-
 net/wireless/Makefile        |    1 +
 net/wireless/core.c          |  148 +++++++++++++++
 net/wireless/core.h          |   32 +++
 net/wireless/nl80211.c       |  431 ++++++++++++++++++++++++++++++++++++++++++
 net/wireless/nl80211.h       |   24 +++
 10 files changed, 762 insertions(+), 9 deletions(-)
 create mode 100644 net/wireless/nl80211.c
 create mode 100644 net/wireless/nl80211.h

diff --git a/include/linux/nl80211.h b/include/linux/nl80211.h
index 9a30ba2..a5dd030 100644
--- a/include/linux/nl80211.h
+++ b/include/linux/nl80211.h
@@ -7,7 +7,97 @@
  */
 
 /**
+ * enum nl80211_commands - supported nl80211 commands
+ *
+ * @NL80211_CMD_UNSPEC: unspecified command to catch errors
+ *
+ * @NL80211_CMD_GET_WIPHY: request information about a wiphy or dump request
+ *	to get a list of all present wiphys.
+ * @NL80211_CMD_SET_WIPHY: set wiphy name, needs %NL80211_ATTR_WIPHY and
+ *	%NL80211_ATTR_WIPHY_NAME.
+ * @NL80211_CMD_NEW_WIPHY: Newly created wiphy, response to get request
+ *	or rename notification. Has attributes %NL80211_ATTR_WIPHY and
+ *	%NL80211_ATTR_WIPHY_NAME.
+ * @NL80211_CMD_DEL_WIPHY: Wiphy deleted. Has attributes
+ *	%NL80211_ATTR_WIPHY and %NL80211_ATTR_WIPHY_NAME.
+ *
+ * @NL80211_CMD_GET_INTERFACE: Request an interface's configuration;
+ *	either a dump request on a %NL80211_ATTR_WIPHY or a specific get
+ *	on an %NL80211_ATTR_IFINDEX is supported.
+ * @NL80211_CMD_SET_INTERFACE: Set type of a virtual interface, requires
+ 	%NL80211_ATTR_IFINDEX and %NL80211_ATTR_IFTYPE.
+ * @NL80211_CMD_NEW_INTERFACE: Newly created virtual interface or response
+ *	to %NL80211_CMD_GET_INTERFACE. Has %NL80211_ATTR_IFINDEX,
+ *	%NL80211_ATTR_WIPHY and %NL80211_ATTR_IFTYPE attributes. Can also
+ *	be sent from userspace to request creation of a new virtual interface,
+ *	then requires attributes %NL80211_ATTR_WIPHY, %NL80211_ATTR_IFTYPE and
+ *	%NL80211_ATTR_IFNAME.
+ * @NL80211_CMD_DEL_INTERFACE: Virtual interface was deleted, has attributes
+ *	%NL80211_ATTR_IFINDEX and %NL80211_ATTR_WIPHY. Can also be sent from
+ *	userspace to request deletion of a virtual interface, then requires
+ *	attribute %NL80211_ATTR_IFINDEX.
+ *
+ * @NL80211_CMD_MAX: highest used command number
+ * @__NL80211_CMD_AFTER_LAST: internal use
+ */
+enum nl80211_commands {
+/* don't change the order or add anything inbetween, this is ABI! */
+	NL80211_CMD_UNSPEC,
+
+	NL80211_CMD_GET_WIPHY,		/* can dump */
+	NL80211_CMD_SET_WIPHY,
+	NL80211_CMD_NEW_WIPHY,
+	NL80211_CMD_DEL_WIPHY,
+
+	NL80211_CMD_GET_INTERFACE,	/* can dump */
+	NL80211_CMD_SET_INTERFACE,
+	NL80211_CMD_NEW_INTERFACE,
+	NL80211_CMD_DEL_INTERFACE,
+
+	/* add commands here */
+
+	/* used to define NL80211_CMD_MAX below */
+	__NL80211_CMD_AFTER_LAST,
+	NL80211_CMD_MAX = __NL80211_CMD_AFTER_LAST - 1
+};
+
+
+/**
+ * enum nl80211_attrs - nl80211 netlink attributes
+ *
+ * @NL80211_ATTR_UNSPEC: unspecified attribute to catch errors
+ *
+ * @NL80211_ATTR_WIPHY: index of wiphy to operate on, cf.
+ *	/sys/class/ieee80211/<phyname>/index
+ * @NL80211_ATTR_WIPHY_NAME: wiphy name (used for renaming)
+ *
+ * @NL80211_ATTR_IFINDEX: network interface index of the device to operate on
+ * @NL80211_ATTR_IFNAME: network interface name
+ * @NL80211_ATTR_IFTYPE: type of virtual interface, see &enum nl80211_iftype
+ *
+ * @NL80211_ATTR_MAX: highest attribute number currently defined
+ * @__NL80211_ATTR_AFTER_LAST: internal use
+ */
+enum nl80211_attrs {
+/* don't change the order or add anything inbetween, this is ABI! */
+	NL80211_ATTR_UNSPEC,
+
+	NL80211_ATTR_WIPHY,
+	NL80211_ATTR_WIPHY_NAME,
+
+	NL80211_ATTR_IFINDEX,
+	NL80211_ATTR_IFNAME,
+	NL80211_ATTR_IFTYPE,
+
+	/* add attributes here, update the policy in nl80211.c */
+
+	__NL80211_ATTR_AFTER_LAST,
+	NL80211_ATTR_MAX = __NL80211_ATTR_AFTER_LAST - 1
+};
+
+/**
  * enum nl80211_iftype - (virtual) interface types
+ *
  * @NL80211_IFTYPE_UNSPECIFIED: unspecified type, driver decides
  * @NL80211_IFTYPE_ADHOC: independent BSS member
  * @NL80211_IFTYPE_STATION: managed BSS member
@@ -15,9 +105,10 @@
  * @NL80211_IFTYPE_AP_VLAN: VLAN interface for access points
  * @NL80211_IFTYPE_WDS: wireless distribution interface
  * @NL80211_IFTYPE_MONITOR: monitor interface receiving all frames
+ * @NL80211_IFTYPE_MAX: highest interface type number currently defined
  * @__NL80211_IFTYPE_AFTER_LAST: internal use
  *
- * These values are used with the NL80211_ATTR_IFTYPE
+ * These values are used with the %NL80211_ATTR_IFTYPE
  * to set the type of an interface.
  *
  */
@@ -31,8 +122,8 @@ enum nl80211_iftype {
 	NL80211_IFTYPE_MONITOR,
 
 	/* keep last */
-	__NL80211_IFTYPE_AFTER_LAST
+	__NL80211_IFTYPE_AFTER_LAST,
+	NL80211_IFTYPE_MAX = __NL80211_IFTYPE_AFTER_LAST - 1
 };
-#define NL80211_IFTYPE_MAX (__NL80211_IFTYPE_AFTER_LAST - 1)
 
 #endif /* __LINUX_NL80211_H */
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 7edaef6..d30960e 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -3,15 +3,15 @@
 
 #include <linux/netlink.h>
 #include <linux/skbuff.h>
+#include <linux/nl80211.h>
 #include <net/genetlink.h>
 
 /*
  * 802.11 configuration in-kernel interface
  *
- * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
+ * Copyright 2006, 2007	Johannes Berg <johannes@sipsolutions.net>
  */
 
-
 /* Radiotap header iteration
  *   implemented in net/wireless/radiotap.c
  *   docs in Documentation/networking/radiotap-headers.txt
@@ -68,11 +68,16 @@ struct wiphy;
  * @add_virtual_intf: create a new virtual interface with the given name
  *
  * @del_virtual_intf: remove the virtual interface determined by ifindex.
+ *
+ * @change_virtual_intf: change type of virtual interface
+ *
  */
 struct cfg80211_ops {
 	int	(*add_virtual_intf)(struct wiphy *wiphy, char *name,
-				    unsigned int type);
+				    enum nl80211_iftype type);
 	int	(*del_virtual_intf)(struct wiphy *wiphy, int ifindex);
+	int	(*change_virtual_intf)(struct wiphy *wiphy, int ifindex,
+				       enum nl80211_iftype type);
 };
 
 #endif /* __NET_CFG80211_H */
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index f23d07c..369d50e 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -431,7 +431,13 @@ struct iw_public_data {
  * Those may be called only within the kernel.
  */
 
-/* functions that may be called by driver modules */
+/* First : function strictly used inside the kernel */
+
+/* Handle /proc/net/wireless, called in net/code/dev.c */
+extern int dev_get_wireless_info(char * buffer, char **start, off_t offset,
+				 int length);
+
+/* Second : functions that may be called by driver modules */
 
 /* Send a single event to user space */
 extern void wireless_send_event(struct net_device *	dev,
diff --git a/net/mac80211/ieee80211_cfg.c b/net/mac80211/ieee80211_cfg.c
index 509096e..d920cda 100644
--- a/net/mac80211/ieee80211_cfg.c
+++ b/net/mac80211/ieee80211_cfg.c
@@ -13,7 +13,7 @@
 #include "ieee80211_cfg.h"
 
 static int ieee80211_add_iface(struct wiphy *wiphy, char *name,
-			       unsigned int type)
+			       enum nl80211_iftype type)
 {
 	struct ieee80211_local *local = wiphy_priv(wiphy);
 	int itype;
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index a228d56..6291f13 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -1,6 +1,19 @@
 config CFG80211
         tristate "Improved wireless configuration API"
 
+config NL80211
+	bool "nl80211 new netlink interface support"
+	depends CFG80211
+	default y
+	---help---
+         This option turns on the new netlink interface
+         (nl80211) support in cfg80211.
+
+         If =n, drivers using mac80211 will be configured via
+         wireless extension support provided by that subsystem.
+
+         If unsure, say Y.
+
 config WIRELESS_EXT
 	bool "Wireless extensions"
 	default n
@@ -10,7 +23,9 @@ config WIRELESS_EXT
 
 	  Wireless extensions will be replaced by cfg80211 and
 	  will be required only by legacy drivers that implement
-	  wireless extension handlers.
+	  wireless extension handlers. This option does not
+	  affect the wireless-extension backward compatibility
+	  code in cfg80211.
 
 	  Say N (if you can) unless you know you need wireless
 	  extensions for external modules.
diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index 092116e..65710a4 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_WIRELESS_EXT) += wext.o
 obj-$(CONFIG_CFG80211) += cfg80211.o
 
 cfg80211-y += core.o sysfs.o radiotap.o
+cfg80211-$(CONFIG_NL80211) += nl80211.o
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 7eabd55..5ddf7a9 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -16,6 +16,7 @@
 #include <net/genetlink.h>
 #include <net/cfg80211.h>
 #include <net/wireless.h>
+#include "nl80211.h"
 #include "core.h"
 #include "sysfs.h"
 
@@ -36,6 +37,146 @@ static int wiphy_counter;
 /* for debugfs */
 static struct dentry *ieee80211_debugfs_dir;
 
+/* requires cfg80211_drv_mutex to be held! */
+static struct cfg80211_registered_device *cfg80211_drv_by_wiphy(int wiphy)
+{
+	struct cfg80211_registered_device *result = NULL, *drv;
+
+	list_for_each_entry(drv, &cfg80211_drv_list, list) {
+		if (drv->idx == wiphy) {
+			result = drv;
+			break;
+		}
+	}
+
+	return result;
+}
+
+/* requires cfg80211_drv_mutex to be held! */
+static struct cfg80211_registered_device *
+__cfg80211_drv_from_info(struct genl_info *info)
+{
+	int ifindex;
+	struct cfg80211_registered_device *bywiphy = NULL, *byifidx = NULL;
+	struct net_device *dev;
+	int err = -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_WIPHY]) {
+		bywiphy = cfg80211_drv_by_wiphy(
+				nla_get_u32(info->attrs[NL80211_ATTR_WIPHY]));
+		err = -ENODEV;
+	}
+
+	if (info->attrs[NL80211_ATTR_IFINDEX]) {
+		ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+		dev = dev_get_by_index(&init_net, ifindex);
+		if (dev) {
+			if (dev->ieee80211_ptr)
+				byifidx =
+					wiphy_to_dev(dev->ieee80211_ptr->wiphy);
+			dev_put(dev);
+		}
+		err = -ENODEV;
+	}
+
+	if (bywiphy && byifidx) {
+		if (bywiphy != byifidx)
+			return ERR_PTR(-EINVAL);
+		else
+			return bywiphy; /* == byifidx */
+	}
+	if (bywiphy)
+		return bywiphy;
+
+	if (byifidx)
+		return byifidx;
+
+	return ERR_PTR(err);
+}
+
+struct cfg80211_registered_device *
+cfg80211_get_dev_from_info(struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	drv = __cfg80211_drv_from_info(info);
+
+	/* if it is not an error we grab the lock on
+	 * it to assure it won't be going away while
+	 * we operate on it */
+	if (!IS_ERR(drv))
+		mutex_lock(&drv->mtx);
+
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	return drv;
+}
+
+struct cfg80211_registered_device *
+cfg80211_get_dev_from_ifindex(int ifindex)
+{
+	struct cfg80211_registered_device *drv = ERR_PTR(-ENODEV);
+	struct net_device *dev;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	dev = dev_get_by_index(&init_net, ifindex);
+	if (!dev)
+		goto out;
+	if (dev->ieee80211_ptr) {
+		drv = wiphy_to_dev(dev->ieee80211_ptr->wiphy);
+		mutex_lock(&drv->mtx);
+	} else
+		drv = ERR_PTR(-ENODEV);
+	dev_put(dev);
+ out:
+	mutex_unlock(&cfg80211_drv_mutex);
+	return drv;
+}
+
+void cfg80211_put_dev(struct cfg80211_registered_device *drv)
+{
+	BUG_ON(IS_ERR(drv));
+	mutex_unlock(&drv->mtx);
+}
+
+int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
+			char *newname)
+{
+	int idx, taken = -1, result, digits;
+
+	/* prohibit calling the thing phy%d when %d is not its number */
+	sscanf(newname, PHY_NAME "%d%n", &idx, &taken);
+	if (taken == strlen(newname) && idx != rdev->idx) {
+		/* count number of places needed to print idx */
+		digits = 1;
+		while (idx /= 10)
+			digits++;
+		/*
+		 * deny the name if it is phy<idx> where <idx> is printed
+		 * without leading zeroes. taken == strlen(newname) here
+		 */
+		if (taken == strlen(PHY_NAME) + digits)
+			return -EINVAL;
+	}
+
+	/* this will check for collisions */
+	result = device_rename(&rdev->wiphy.dev, newname);
+	if (result)
+		return result;
+
+	if (!debugfs_rename(rdev->wiphy.debugfsdir->d_parent,
+			    rdev->wiphy.debugfsdir,
+			    rdev->wiphy.debugfsdir->d_parent,
+			    newname))
+		printk(KERN_ERR "cfg80211: failed to rename debugfs dir to %s!\n",
+		       newname);
+
+	nl80211_notify_dev_rename(rdev);
+
+	return 0;
+}
+
 /* exported functions */
 
 struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv)
@@ -204,10 +345,16 @@ static int cfg80211_init(void)
 	if (err)
 		goto out_fail_notifier;
 
+	err = nl80211_init();
+	if (err)
+		goto out_fail_nl80211;
+
 	ieee80211_debugfs_dir = debugfs_create_dir("ieee80211", NULL);
 
 	return 0;
 
+out_fail_nl80211:
+	unregister_netdevice_notifier(&cfg80211_netdev_notifier);
 out_fail_notifier:
 	wiphy_sysfs_exit();
 out_fail_sysfs:
@@ -218,6 +365,7 @@ module_init(cfg80211_init);
 static void cfg80211_exit(void)
 {
 	debugfs_remove(ieee80211_debugfs_dir);
+	nl80211_exit();
 	unregister_netdevice_notifier(&cfg80211_netdev_notifier);
 	wiphy_sysfs_exit();
 }
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 158db1e..eb0f846 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -43,7 +43,39 @@ struct cfg80211_registered_device *wiphy_to_dev(struct wiphy *wiphy)
 extern struct mutex cfg80211_drv_mutex;
 extern struct list_head cfg80211_drv_list;
 
+/*
+ * This function returns a pointer to the driver
+ * that the genl_info item that is passed refers to.
+ * If successful, it returns non-NULL and also locks
+ * the driver's mutex!
+ *
+ * This means that you need to call cfg80211_put_dev()
+ * before being allowed to acquire &cfg80211_drv_mutex!
+ *
+ * This is necessary because we need to lock the global
+ * mutex to get an item off the list safely, and then
+ * we lock the drv mutex so it doesn't go away under us.
+ *
+ * We don't want to keep cfg80211_drv_mutex locked
+ * for all the time in order to allow requests on
+ * other interfaces to go through at the same time.
+ *
+ * The result of this can be a PTR_ERR and hence must
+ * be checked with IS_ERR() for errors.
+ */
+extern struct cfg80211_registered_device *
+cfg80211_get_dev_from_info(struct genl_info *info);
+
+/* identical to cfg80211_get_dev_from_info but only operate on ifindex */
+extern struct cfg80211_registered_device *
+cfg80211_get_dev_from_ifindex(int ifindex);
+
+extern void cfg80211_put_dev(struct cfg80211_registered_device *drv);
+
 /* free object */
 extern void cfg80211_dev_free(struct cfg80211_registered_device *drv);
 
+extern int cfg80211_dev_rename(struct cfg80211_registered_device *drv,
+			       char *newname);
+
 #endif /* __NET_WIRELESS_CORE_H */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
new file mode 100644
index 0000000..48b0d45
--- /dev/null
+++ b/net/wireless/nl80211.c
@@ -0,0 +1,431 @@
+/*
+ * This is the new netlink-based wireless configuration interface.
+ *
+ * Copyright 2006, 2007	Johannes Berg <johannes@sipsolutions.net>
+ */
+
+#include <linux/if.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/if_ether.h>
+#include <linux/ieee80211.h>
+#include <linux/nl80211.h>
+#include <linux/rtnetlink.h>
+#include <linux/netlink.h>
+#include <net/genetlink.h>
+#include <net/cfg80211.h>
+#include "core.h"
+#include "nl80211.h"
+
+/* the netlink family */
+static struct genl_family nl80211_fam = {
+	.id = GENL_ID_GENERATE,	/* don't bother with a hardcoded ID */
+	.name = "nl80211",	/* have users key off the name instead */
+	.hdrsize = 0,		/* no private header */
+	.version = 1,		/* no particular meaning now */
+	.maxattr = NL80211_ATTR_MAX,
+};
+
+/* internal helper: get drv and dev */
+static int get_drv_dev_by_info_ifindex(struct genl_info *info,
+				       struct cfg80211_registered_device **drv,
+				       struct net_device **dev)
+{
+	int ifindex;
+
+	if (!info->attrs[NL80211_ATTR_IFINDEX])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
+	*dev = dev_get_by_index(&init_net, ifindex);
+	if (!*dev)
+		return -ENODEV;
+
+	*drv = cfg80211_get_dev_from_ifindex(ifindex);
+	if (IS_ERR(*drv)) {
+		dev_put(*dev);
+		return PTR_ERR(*drv);
+	}
+
+	return 0;
+}
+
+/* policy for the attributes */
+static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
+	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
+	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
+				      .len = BUS_ID_SIZE-1 },
+
+	[NL80211_ATTR_IFTYPE] = { .type = NLA_U32 },
+	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
+	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
+};
+
+/* message building helper */
+static inline void *nl80211hdr_put(struct sk_buff *skb, u32 pid, u32 seq,
+				   int flags, u8 cmd)
+{
+	/* since there is no private header just add the generic one */
+	return genlmsg_put(skb, pid, seq, &nl80211_fam, flags, cmd);
+}
+
+/* netlink command implementations */
+
+static int nl80211_send_wiphy(struct sk_buff *msg, u32 pid, u32 seq, int flags,
+			      struct cfg80211_registered_device *dev)
+{
+	void *hdr;
+
+	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_WIPHY);
+	if (!hdr)
+		return -1;
+
+	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, dev->idx);
+	NLA_PUT_STRING(msg, NL80211_ATTR_WIPHY_NAME, wiphy_name(&dev->wiphy));
+	return genlmsg_end(msg, hdr);
+
+ nla_put_failure:
+	return genlmsg_cancel(msg, hdr);
+}
+
+static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int idx = 0;
+	int start = cb->args[0];
+	struct cfg80211_registered_device *dev;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	list_for_each_entry(dev, &cfg80211_drv_list, list) {
+		if (++idx < start)
+			continue;
+		if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).pid,
+				       cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				       dev) < 0)
+			break;
+	}
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+static int nl80211_get_wiphy(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	struct cfg80211_registered_device *dev;
+
+	dev = cfg80211_get_dev_from_info(info);
+	if (IS_ERR(dev))
+		return PTR_ERR(dev);
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		goto out_err;
+
+	if (nl80211_send_wiphy(msg, info->snd_pid, info->snd_seq, 0, dev) < 0)
+		goto out_free;
+
+	cfg80211_put_dev(dev);
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+ out_free:
+	nlmsg_free(msg);
+ out_err:
+	cfg80211_put_dev(dev);
+	return -ENOBUFS;
+}
+
+static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *rdev;
+	int result;
+
+	if (!info->attrs[NL80211_ATTR_WIPHY_NAME])
+		return -EINVAL;
+
+	rdev = cfg80211_get_dev_from_info(info);
+	if (IS_ERR(rdev))
+		return PTR_ERR(rdev);
+
+	result = cfg80211_dev_rename(rdev, nla_data(info->attrs[NL80211_ATTR_WIPHY_NAME]));
+
+	cfg80211_put_dev(rdev);
+	return result;
+}
+
+
+static int nl80211_send_iface(struct sk_buff *msg, u32 pid, u32 seq, int flags,
+			      struct net_device *dev)
+{
+	void *hdr;
+
+	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_INTERFACE);
+	if (!hdr)
+		return -1;
+
+	NLA_PUT_U32(msg, NL80211_ATTR_IFINDEX, dev->ifindex);
+	NLA_PUT_STRING(msg, NL80211_ATTR_IFNAME, dev->name);
+	/* TODO: interface type */
+	return genlmsg_end(msg, hdr);
+
+ nla_put_failure:
+	return genlmsg_cancel(msg, hdr);
+}
+
+static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int wp_idx = 0;
+	int if_idx = 0;
+	int wp_start = cb->args[0];
+	int if_start = cb->args[1];
+	struct cfg80211_registered_device *dev;
+	struct wireless_dev *wdev;
+
+	mutex_lock(&cfg80211_drv_mutex);
+	list_for_each_entry(dev, &cfg80211_drv_list, list) {
+		if (++wp_idx < wp_start)
+			continue;
+		if_idx = 0;
+
+		mutex_lock(&dev->devlist_mtx);
+		list_for_each_entry(wdev, &dev->netdev_list, list) {
+			if (++if_idx < if_start)
+				continue;
+			if (nl80211_send_iface(skb, NETLINK_CB(cb->skb).pid,
+					       cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					       wdev->netdev) < 0)
+				break;
+		}
+		mutex_unlock(&dev->devlist_mtx);
+	}
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	cb->args[0] = wp_idx;
+	cb->args[1] = if_idx;
+
+	return skb->len;
+}
+
+static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	struct cfg80211_registered_device *dev;
+	struct net_device *netdev;
+	int err;
+
+	err = get_drv_dev_by_info_ifindex(info, &dev, &netdev);
+	if (err)
+		return err;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		goto out_err;
+
+	if (nl80211_send_iface(msg, info->snd_pid, info->snd_seq, 0, netdev) < 0)
+		goto out_free;
+
+	dev_put(netdev);
+	cfg80211_put_dev(dev);
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+ out_free:
+	nlmsg_free(msg);
+ out_err:
+	dev_put(netdev);
+	cfg80211_put_dev(dev);
+	return -ENOBUFS;
+}
+
+static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err, ifindex;
+	enum nl80211_iftype type;
+	struct net_device *dev;
+
+	if (info->attrs[NL80211_ATTR_IFTYPE]) {
+		type = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
+		if (type > NL80211_IFTYPE_MAX)
+			return -EINVAL;
+	} else
+		return -EINVAL;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+	ifindex = dev->ifindex;
+	dev_put(dev);
+
+	if (!drv->ops->change_virtual_intf) {
+		err = -EOPNOTSUPP;
+		goto unlock;
+	}
+
+	rtnl_lock();
+	err = drv->ops->change_virtual_intf(&drv->wiphy, ifindex, type);
+	rtnl_unlock();
+
+ unlock:
+	cfg80211_put_dev(drv);
+	return err;
+}
+
+static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int err;
+	enum nl80211_iftype type = NL80211_IFTYPE_UNSPECIFIED;
+
+	if (!info->attrs[NL80211_ATTR_IFNAME])
+		return -EINVAL;
+
+	if (info->attrs[NL80211_ATTR_IFTYPE]) {
+		type = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
+		if (type > NL80211_IFTYPE_MAX)
+			return -EINVAL;
+	}
+
+	drv = cfg80211_get_dev_from_info(info);
+	if (IS_ERR(drv))
+		return PTR_ERR(drv);
+
+	if (!drv->ops->add_virtual_intf) {
+		err = -EOPNOTSUPP;
+		goto unlock;
+	}
+
+	rtnl_lock();
+	err = drv->ops->add_virtual_intf(&drv->wiphy,
+		nla_data(info->attrs[NL80211_ATTR_IFNAME]), type);
+	rtnl_unlock();
+
+ unlock:
+	cfg80211_put_dev(drv);
+	return err;
+}
+
+static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
+{
+	struct cfg80211_registered_device *drv;
+	int ifindex, err;
+	struct net_device *dev;
+
+	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
+	if (err)
+		return err;
+	ifindex = dev->ifindex;
+	dev_put(dev);
+
+	if (!drv->ops->del_virtual_intf) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	rtnl_lock();
+	err = drv->ops->del_virtual_intf(&drv->wiphy, ifindex);
+	rtnl_unlock();
+
+ out:
+	cfg80211_put_dev(drv);
+	return err;
+}
+
+static struct genl_ops nl80211_ops[] = {
+	{
+		.cmd = NL80211_CMD_GET_WIPHY,
+		.doit = nl80211_get_wiphy,
+		.dumpit = nl80211_dump_wiphy,
+		.policy = nl80211_policy,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = NL80211_CMD_SET_WIPHY,
+		.doit = nl80211_set_wiphy,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_GET_INTERFACE,
+		.doit = nl80211_get_interface,
+		.dumpit = nl80211_dump_interface,
+		.policy = nl80211_policy,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = NL80211_CMD_SET_INTERFACE,
+		.doit = nl80211_set_interface,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_NEW_INTERFACE,
+		.doit = nl80211_new_interface,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NL80211_CMD_DEL_INTERFACE,
+		.doit = nl80211_del_interface,
+		.policy = nl80211_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+/* multicast groups */
+static struct genl_multicast_group nl80211_config_mcgrp = {
+	.name = "config",
+};
+
+/* notification functions */
+
+void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev)
+{
+	struct sk_buff *msg;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		return;
+
+	if (nl80211_send_wiphy(msg, 0, 0, 0, rdev) < 0) {
+		nlmsg_free(msg);
+		return;
+	}
+
+	genlmsg_multicast(msg, 0, nl80211_config_mcgrp.id, GFP_KERNEL);
+}
+
+/* initialisation/exit functions */
+
+int nl80211_init(void)
+{
+	int err, i;
+
+	err = genl_register_family(&nl80211_fam);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(nl80211_ops); i++) {
+		err = genl_register_ops(&nl80211_fam, &nl80211_ops[i]);
+		if (err)
+			goto err_out;
+	}
+
+	err = genl_register_mc_group(&nl80211_fam, &nl80211_config_mcgrp);
+	if (err)
+		goto err_out;
+
+	return 0;
+ err_out:
+	genl_unregister_family(&nl80211_fam);
+	return err;
+}
+
+void nl80211_exit(void)
+{
+	genl_unregister_family(&nl80211_fam);
+}
diff --git a/net/wireless/nl80211.h b/net/wireless/nl80211.h
new file mode 100644
index 0000000..f3ea5c0
--- /dev/null
+++ b/net/wireless/nl80211.h
@@ -0,0 +1,24 @@
+#ifndef __NET_WIRELESS_NL80211_H
+#define __NET_WIRELESS_NL80211_H
+
+#include "core.h"
+
+#ifdef CONFIG_NL80211
+extern int nl80211_init(void);
+extern void nl80211_exit(void);
+extern void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev);
+#else
+static inline int nl80211_init(void)
+{
+	return 0;
+}
+static inline void nl80211_exit(void)
+{
+}
+static inline void nl80211_notify_dev_rename(
+	struct cfg80211_registered_device *rdev)
+{
+}
+#endif /* CONFIG_NL80211 */
+
+#endif /* __NET_WIRELESS_NL80211_H */
-- 
1.5.2.4

-- 
John W. Linville
linville@tuxdriver.com
