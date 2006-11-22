From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] cfg80211: handle wiphy, use wiphy in netdev, do
	wiphy sysfs
Date: Wed, 22 Nov 2006 20:22:44 +0100
Message-ID: <1164223364.5934.23.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163979143.9216.14.camel@johannes.berg>
	 <20061120201402.76e69e46@griffin.suse.cz>
	 <1164223133.5934.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:15577 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756668AbWKVTYn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 14:24:43 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <1164223133.5934.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes cfg80211 handle wiphy related stuff. I introduced
struct wiphy, put a pointer to it into net_dev->ieee80211_ptr instead of
letting everyone do their own (last hunk of this patch; this gets us
free net_dev -> wiphy mapping) and generally added code here that was
similar in d80211.

--- wireless-dev.orig/include/net/cfg80211.h	2006-11-22 01:11:09.403927956 +0100
+++ wireless-dev/include/net/cfg80211.h	2006-11-22 20:02:14.889711991 +0100
@@ -7,14 +7,44 @@
 #include <linux/netdevice.h>
 #include <net/genetlink.h>
 #include <linux/wireless.h>
+#include <linux/device.h>
 
 /*
- * 802.11 configuration in-kernel interface
+ * 802.11 configuration and wiphy management in-kernel interface
  *
  * Copyright 2006 Johannes Berg <johannes@sipsolutions.net>
  */
 
 /**
+ * struct wiphy
+ *
+ * @wiphy_index: the wiphy index assigned to this item
+ * @class_dev: the class device representing /sys/class/ieee80211/<wiphy-name>
+ * @name: name of this wiphy
+ */
+struct wiphy {
+	/* assign these fields before you register the wiphy */
+
+	/* permanent MAC address */
+	u8 perm_addr[ETH_ALEN];
+
+	/* the actual hardware */
+	struct device *dev;
+
+	/* fields below are read-only, assigned by cfg80211 */
+
+	/* index assigned to this wiphy */
+	int wiphy_index;
+	/* dir in /sys/class/ieee80211/ */
+	struct class_device class_dev;
+	/* pointer to priv */
+	void *priv;
+};
+
+#define WIPHY_PRIV_ALIGN	32
+#define WIPHY_PRIV_ALIGN_CONST	(WIPHY_PRIV_ALIGN-1)
+
+/**
  * struct cfg80211_config - description of a configuration (request)
  */
 struct cfg80211_config {
@@ -118,74 +148,97 @@ struct scan_params {
  *		   is to be passed to that callback
  */
 struct cfg80211_ops {
-	int	(*list_interfaces)(void *priv, void *data,
+	int	(*list_interfaces)(struct wiphy *wiphy, void *data,
 				   int (*one)(void *data, int ifindex));
 
 
-	int	(*inject_packet)(void *priv, void *frame, int framelen,
+	int	(*inject_packet)(struct wiphy *wiphy, void *frame, int framelen,
 				 u32 flags, int queue);
 
 
-	int	(*add_virtual_intf)(void *priv, char *name,
+	int	(*add_virtual_intf)(struct wiphy *wiphy, char *name,
 				    unsigned int type);
-	int	(*del_virtual_intf)(void *priv, int ifindex);
+	int	(*del_virtual_intf)(struct wiphy *wiphy, int ifindex);
 
 
-	int	(*configure)(void *priv, struct net_device *dev,
+	int	(*configure)(struct wiphy *wiphy, struct net_device *dev,
 			     struct cfg80211_config *cfg);
-	void	(*get_config)(void *priv, struct net_device *dev,
+	void	(*get_config)(struct wiphy *wiphy, struct net_device *dev,
 			      struct cfg80211_config *cfg);
-	u32	(*get_config_valid)(void *priv, struct net_device *dev);
+	u32	(*get_config_valid)(struct wiphy *wiphy,
+				    struct net_device *dev);
 
 
-	int	(*reassociate)(void *priv, struct net_device *dev);
-	int	(*disassociate)(void *priv, struct net_device *dev);
-	int	(*deauth)(void *priv, struct net_device *dev);
+	int	(*reassociate)(struct wiphy *wiphy, struct net_device *dev);
+	int	(*disassociate)(struct wiphy *wiphy, struct net_device *dev);
+	int	(*deauth)(struct wiphy *wiphy, struct net_device *dev);
 
 
-	int	(*initiate_scan)(void *priv, struct net_device *dev,
+	int	(*initiate_scan)(struct wiphy *wiphy, struct net_device *dev,
 				 struct scan_params *params);
 
 
-	int	(*set_roaming)(void *priv, struct net_device *dev,
+	int	(*set_roaming)(struct wiphy *wiphy, struct net_device *dev,
 			       int roaming_control);
-	int	(*get_roaming)(void *priv, struct net_device *dev);
-	int	(*set_fixed_bssid)(void *priv, struct net_device *dev,
+	int	(*get_roaming)(struct wiphy *wiphy, struct net_device *dev);
+	int	(*set_fixed_bssid)(struct wiphy *wiphy, struct net_device *dev,
 				   u8 *bssid);
-	int	(*get_fixed_bssid)(void *priv, struct net_device *dev,
+	int	(*get_fixed_bssid)(struct wiphy *wiphy, struct net_device *dev,
 				   u8 *bssid);
 
 
-	int	(*get_association)(void *priv, struct net_device *dev,
+	int	(*get_association)(struct wiphy *wiphy, struct net_device *dev,
 				   u8 *bssid);
 
-	int	(*get_auth_list)(void *priv, struct net_device *dev,
+	int	(*get_auth_list)(struct wiphy *wiphy, struct net_device *dev,
 				 void *data,
 				 int (*next_bssid)(void *data, u8 *bssid));
 };
 
 /**
- * cfg80211_register - register a wiphy with cfg80211
+ * wiphy_priv - return priv from wiphy
+ */
+static inline void *wiphy_priv(struct wiphy *wiphy)
+{
+	return (char *)wiphy +
+		((sizeof(struct wiphy)+WIPHY_PRIV_ALIGN_CONST)
+			& ~WIPHY_PRIV_ALIGN_CONST);
+}
+
+/**
+ * wiphy_new - create a new wiphy for use with cfg80211
  *
- * register a given method structure with the cfg80211 system
- * and associate the 'priv' pointer with it.
+ * create a new wiphy and associate the given operations with it.
+ * @sizeof_priv bytes are allocated for private use.
  *
- * Returns a non-negative wiphy index or a negative error code.
+ * the returned structure's driver-private pointer must be assigned
+ * to each netdev's ieee80211_ptr for proper operation.
+ */
+struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv);
+
+/**
+ * wiphy_register - register a wiphy with cfg80211
  *
- * NOTE: for proper operation, this priv pointer MUST also be
- * assigned to each &struct net_device's @ieee80211_ptr member!
+ * register the given wiphy
+ *
+ * Returns a non-negative wiphy index or a negative error code.
  */
-extern int cfg80211_register(struct cfg80211_ops *ops, void *priv);
+extern int wiphy_register(struct wiphy *wiphy);
 
 /**
- * cfg80211_unregister - deregister a wiphy from cfg80211
+ * wiphy_unregister - deregister a wiphy from cfg80211
  *
  * unregister a device with the given priv pointer.
  * After this call, no more requests can be made with this priv
  * pointer, but the call may sleep to wait for an outstanding
  * request that is being handled.
  */
-extern void cfg80211_unregister(void *priv);
+extern void wiphy_unregister(struct wiphy *wiphy);
+
+/**
+ * cfg80211_free - free wiphy
+ */
+extern void wiphy_free(struct wiphy *wiphy);
 
 /* helper functions specific to nl80211 */
 extern void *nl80211hdr_put(struct sk_buff *skb, u32 pid,
--- wireless-dev.orig/net/wireless/core.c	2006-11-22 01:11:09.463927956 +0100
+++ wireless-dev/net/wireless/core.c	2006-11-22 20:00:34.869711991 +0100
@@ -14,41 +14,22 @@
 #include <linux/mutex.h>
 #include <linux/list.h>
 
+#include "sysfs.h"
+
 MODULE_AUTHOR("Johannes Berg");
 MODULE_LICENSE("GPL");
 
-/* RCU might be appropriate here since we usually
- * only read the list, and that can happen quite
- * often because we need to do it for each command */
 LIST_HEAD(cfg80211_drv_list);
 DEFINE_MUTEX(cfg80211_drv_mutex);
 static int wiphy_counter;
 
-/* requires nl80211_drv_mutex to be held! */
-static struct cfg80211_registered_driver *cfg80211_drv_by_priv(void *priv)
-{
-	struct cfg80211_registered_driver *result = NULL, *drv;
-
-	if (!priv)
-		return NULL;
-
-	list_for_each_entry(drv, &cfg80211_drv_list, list) {
-		if (drv->priv == priv) {
-			result = drv;
-			break;
-		}
-	}
-
-	return result;
-}
-
 /* requires cfg80211_drv_mutex to be held! */
 static struct cfg80211_registered_driver *cfg80211_drv_by_wiphy(int wiphy)
 {
 	struct cfg80211_registered_driver *result = NULL, *drv;
 
 	list_for_each_entry(drv, &cfg80211_drv_list, list) {
-		if (drv->wiphy == wiphy) {
+		if (drv->wiphy.wiphy_index == wiphy) {
 			result = drv;
 			break;
 		}
@@ -75,8 +56,8 @@ __cfg80211_drv_from_info(struct genl_inf
 	if (info->attrs[NL80211_ATTR_IFINDEX]) {
 		ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
 		dev = dev_get_by_index(ifindex);
-		if (dev) {
-			byifidx = cfg80211_drv_by_priv(dev->ieee80211_ptr);
+		if (dev && dev->ieee80211_ptr) {
+			byifidx = wiphy_to_drv(dev->ieee80211_ptr);
 			dev_put(dev);
 		}
 		err = -ENODEV;
@@ -127,11 +108,13 @@ cfg80211_get_drv_from_ifindex(int ifinde
 	dev = dev_get_by_index(ifindex);
 	if (!dev)
 		goto out;
-	drv = cfg80211_drv_by_priv(dev->ieee80211_ptr);
-	if (drv)
+
+	if (dev->ieee80211_ptr) {
+		drv = wiphy_to_drv(dev->ieee80211_ptr);
 		mutex_lock(&drv->mtx);
-	else
+	} else {
 		drv = ERR_PTR(-ENODEV);
+	}
 	dev_put(dev);
  out:
 	mutex_unlock(&cfg80211_drv_mutex);
@@ -146,63 +129,78 @@ void cfg80211_put_drv(struct cfg80211_re
 
 /* exported functions */
 
-int cfg80211_register(struct cfg80211_ops *ops, void *priv)
+struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv)
 {
-	struct cfg80211_registered_driver *drv;
-	int res;
+	struct cfg80211_registered_driver *result;
+	int alloc_size;
+	void *p;
 
-	if (!priv || !ops->list_interfaces)
-		return -EINVAL;
+	if (!ops->list_interfaces)
+		return NULL;
 
-	mutex_lock(&cfg80211_drv_mutex);
+	/* ensure 32-byte alignment of result and priv */
+	alloc_size = (sizeof(*result) + WIPHY_PRIV_ALIGN_CONST)
+			& ~WIPHY_PRIV_ALIGN_CONST;
+	alloc_size += sizeof_priv + WIPHY_PRIV_ALIGN_CONST;
 
-	if (cfg80211_drv_by_priv(priv)) {
-		res = -EALREADY;
-		goto out_unlock;
-	}
+	p = kzalloc(alloc_size, GFP_KERNEL);
+	if (!p)
+		return NULL;
 
-	drv = kzalloc(sizeof(struct cfg80211_registered_driver), GFP_KERNEL);
-	if (!drv) {
-		res = -ENOMEM;
-		goto out_unlock;
-	}
+	result = (struct cfg80211_registered_driver *)
+		     (((long)p + WIPHY_PRIV_ALIGN_CONST) &
+			~WIPHY_PRIV_ALIGN_CONST);
+
+	result->padded = (char *)result - (char *)p;
+	result->wiphy.priv = wiphy_priv(&result->wiphy);
 
-	drv->ops = ops;
-	drv->priv = priv;
+	result->ops = ops;
+	mutex_init(&result->mtx);
+
+	return &result->wiphy;
+}
+EXPORT_SYMBOL_GPL(wiphy_new);
+
+int wiphy_register(struct wiphy *wiphy)
+{
+	struct cfg80211_registered_driver *drv = wiphy_to_drv(wiphy);
+	int res;
+
+	mutex_lock(&cfg80211_drv_mutex);
 
 	if (unlikely(wiphy_counter<0)) {
 		/* ugh, wrapped! */
-		kfree(drv);
 		res = -ENOSPC;
 		goto out_unlock;
 	}
-	mutex_init(&drv->mtx);
-	drv->wiphy = wiphy_counter;
+	drv->wiphy.wiphy_index = wiphy_counter;
 	list_add(&drv->list, &cfg80211_drv_list);
-	/* return wiphy number */
-	res = drv->wiphy;
+
+	/* give it a proper name */
+	snprintf(drv->wiphy.class_dev.class_id, BUS_ID_SIZE,
+		 "wiphy%d", drv->wiphy.wiphy_index);
+
+	res = wiphy_sysfs_add(&drv->wiphy);
+	if (res)
+		goto out_unlock;
 
 	/* now increase counter for the next time */
 	wiphy_counter++;
 
+	/* return wiphy number */
+	res = drv->wiphy.wiphy_index;
+
  out_unlock:
 	mutex_unlock(&cfg80211_drv_mutex);
 	return res;
 }
-EXPORT_SYMBOL_GPL(cfg80211_register);
+EXPORT_SYMBOL_GPL(wiphy_register);
 
-void cfg80211_unregister(void *priv)
+void wiphy_unregister(struct wiphy *wiphy)
 {
-	struct cfg80211_registered_driver *drv;
+	struct cfg80211_registered_driver *drv = wiphy_to_drv(wiphy);
 
 	mutex_lock(&cfg80211_drv_mutex);
-	drv = cfg80211_drv_by_priv(priv);
-	if (!drv) {
-		printk(KERN_ERR "deregistering cfg80211 backend that "
-		       " was never registered!\n");
-		mutex_unlock(&cfg80211_drv_mutex);
-		return;
-	}
 
 	/* hold registered driver mutex during list removal as well
 	 * to make sure no commands are in progress at the moment */
@@ -210,24 +208,43 @@ void cfg80211_unregister(void *priv)
 	list_del(&drv->list);
 	mutex_unlock(&drv->mtx);
 
+	wiphy_sysfs_del(&drv->wiphy);
+
 	mutex_unlock(&cfg80211_drv_mutex);
+}
+EXPORT_SYMBOL_GPL(wiphy_unregister);
 
-	mutex_destroy(&drv->mtx);
-	kfree(drv);
+void wiphy_free(struct wiphy *wiphy)
+{
+	class_device_put(&wiphy->class_dev);
 }
-EXPORT_SYMBOL_GPL(cfg80211_unregister);
+EXPORT_SYMBOL_GPL(wiphy_free);
 
 /* module initialisation/exit functions */
 
 static int cfg80211_init(void)
 {
+	int err;
+
 #ifdef CONFIG_CFG80211_WEXT_COMPAT
 	cfg80211_core_ops.get_drv_from_ifidx = cfg80211_get_drv_from_ifindex;
 	cfg80211_core_ops.put_drv = cfg80211_put_drv;
 	cfg80211_core_ops.module = THIS_MODULE;
 	cfg80211_core_ops.loaded = 1;
 #endif
-	return nl80211_init();
+	err = nl80211_init();
+	if (err)
+		return err;
+
+	err = wiphy_sysfs_init();
+	if (err)
+		goto out_fail_sysfs;
+
+	return 0;
+
+ out_fail_sysfs:
+	nl80211_exit();
+	return err;
 }
 
 static void cfg80211_exit(void)
@@ -238,6 +255,7 @@ static void cfg80211_exit(void)
 	cfg80211_core_ops.get_drv_from_ifidx = NULL;
 	cfg80211_core_ops.put_drv = NULL;
 #endif
+	wiphy_sysfs_exit();
 	nl80211_exit();
 }
 
--- wireless-dev.orig/net/wireless/core.h	2006-11-22 01:11:09.493927956 +0100
+++ wireless-dev/net/wireless/core.h	2006-11-22 01:11:48.113927956 +0100
@@ -13,16 +13,21 @@
 
 struct cfg80211_registered_driver {
 	struct cfg80211_ops *ops;
-	int wiphy;
-	void *priv;
+	int padded;
 	struct list_head list;
 	/* we hold this mutex during any call so that
 	 * we cannot do multiple calls at once, and also
 	 * to avoid the deregister call to proceed while
 	 * any call is in progress */
 	struct mutex mtx;
+	struct wiphy wiphy;
 };
 
+static inline struct cfg80211_registered_driver *wiphy_to_drv(struct wiphy *wiphy)
+{
+	return container_of(wiphy, struct cfg80211_registered_driver, wiphy);
+}
+
 extern struct mutex cfg80211_drv_mutex;
 extern struct list_head cfg80211_drv_list;
 
--- wireless-dev.orig/net/wireless/nl80211.c	2006-11-22 01:11:09.543927956 +0100
+++ wireless-dev/net/wireless/nl80211.c	2006-11-22 01:11:48.123927956 +0100
@@ -112,7 +112,7 @@ static int nl80211_get_cmdlist(struct sk
 		goto put_drv;
 	}
 
-	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
+	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy.wiphy_index);
 
 	start = nla_nest_start(msg, NL80211_ATTR_CMDS);
 	if (!start)
@@ -178,7 +178,7 @@ static int nl80211_get_wiphys(struct sk_
 		indexstart = nla_nest_start(msg, idx++);
 		if (!indexstart)
 			goto nla_put_failure;
-		NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
+		NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy.wiphy_index);
 		nla_nest_end(msg, indexstart);
 	}
 	mutex_unlock(&cfg80211_drv_mutex);
@@ -248,7 +248,7 @@ static int nl80211_get_intfs(struct sk_b
 		goto put_drv;
 	}
 
-	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
+	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy.wiphy_index);
 
 	start = nla_nest_start(msg, NL80211_ATTR_INTERFACE_LIST);
 	if (!start) {
@@ -258,7 +258,7 @@ static int nl80211_get_intfs(struct sk_b
 
 	cb.skb = msg;
 	cb.idx = 1;
-	err = drv->ops->list_interfaces(drv->priv, &cb, addifidx);
+	err = drv->ops->list_interfaces(&drv->wiphy, &cb, addifidx);
 	if (err)
 		goto msg_free;
 
@@ -300,7 +300,7 @@ static int nl80211_do_inject(struct sk_b
 		goto unlock;
 	}
 
-	err = drv->ops->inject_packet(drv->priv,
+	err = drv->ops->inject_packet(&drv->wiphy,
 		nla_data(info->attrs[NL80211_ATTR_FRAME]),
 		nla_len(info->attrs[NL80211_ATTR_FRAME]),
 		flags,
@@ -334,7 +334,7 @@ static int nl80211_add_virt_intf(struct 
 		goto unlock;
 	}
 
-	err = drv->ops->add_virtual_intf(drv->priv,
+	err = drv->ops->add_virtual_intf(&drv->wiphy,
 		nla_data(info->attrs[NL80211_ATTR_IFNAME]), type);
 
  unlock:
@@ -359,7 +359,7 @@ static int nl80211_del_virt_intf(struct 
 		goto out;
 	}
 
-	err = drv->ops->del_virtual_intf(drv->priv, ifindex);
+	err = drv->ops->del_virtual_intf(&drv->wiphy, ifindex);
 
  out:
 	cfg80211_put_drv(drv);
@@ -421,7 +421,7 @@ static int nl80211_configure(struct sk_b
 		config.channel = nla_get_u32(attr);
 	}
 
-	err = drv->ops->configure(drv->priv, dev, &config);
+	err = drv->ops->configure(&drv->wiphy, dev, &config);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -448,7 +448,7 @@ static int nl80211_get_config(struct sk_
 
 	memset(&config, 0, sizeof(config));
 
-	drv->ops->get_config(drv->priv, dev, &config);
+	drv->ops->get_config(&drv->wiphy, dev, &config);
 
 	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_NEW_CONFIG);
@@ -514,7 +514,7 @@ static int nl80211_set_roaming(struct sk
 		goto out;
 	}
 
-	err = drv->ops->set_roaming(drv->priv, dev, roaming_control);
+	err = drv->ops->set_roaming(&drv->wiphy, dev, roaming_control);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -538,7 +538,7 @@ static int nl80211_get_roaming(struct sk
 		goto out_put_drv;
 	}
 
-	err = drv->ops->get_roaming(drv->priv, dev);
+	err = drv->ops->get_roaming(&drv->wiphy, dev);
 	if (err < 0)
 		goto out_put_drv;
 
@@ -586,7 +586,7 @@ static int nl80211_set_fixed_bssid(struc
 		goto out;
 	}
 
-	err = drv->ops->set_fixed_bssid(drv->priv, dev, bssid);
+	err = drv->ops->set_fixed_bssid(&drv->wiphy, dev, bssid);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -611,7 +611,7 @@ static int nl80211_get_fixed_bssid(struc
 		goto out_put_drv;
 	}
 
-	err = drv->ops->get_fixed_bssid(drv->priv, dev, bssid);
+	err = drv->ops->get_fixed_bssid(&drv->wiphy, dev, bssid);
 	if (err < 0)
 		goto out_put_drv;
 
@@ -657,7 +657,7 @@ static int nl80211_get_association(struc
 		goto out_put_drv;
 	}
 
-	err = drv->ops->get_association(drv->priv, dev, bssid);
+	err = drv->ops->get_association(&drv->wiphy, dev, bssid);
 	if (err < 0)
 		goto out_put_drv;
 
@@ -691,7 +691,7 @@ static int nl80211_assoc_deauth(struct s
 	struct cfg80211_registered_driver *drv;
 	int err;
 	struct net_device *dev;
-	int (*act)(void *priv, struct net_device *dev);
+	int (*act)(struct wiphy *wiphy, struct net_device *dev);
 
 	err = get_drv_dev_by_info_ifindex(info, &drv, &dev);
 	if (err)
@@ -716,7 +716,7 @@ static int nl80211_assoc_deauth(struct s
 		goto out;
 	}
 
-	err = act(drv->priv, dev);
+	err = act(&drv->wiphy, dev);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -778,7 +778,7 @@ static int nl80211_get_auth_list(struct 
 
 	cb.skb = msg;
 	cb.idx = 1;
-	err = drv->ops->get_auth_list(drv->priv, dev, &cb, add_bssid);
+	err = drv->ops->get_auth_list(&drv->wiphy, dev, &cb, add_bssid);
 	if (err)
 		goto msg_free;
 
@@ -874,7 +874,7 @@ static int nl80211_initiate_scan(struct 
 	params.channels = channels;
 	params.n_channels = count;
 
-	err = drv->ops->initiate_scan(drv->priv, dev, &params);
+	err = drv->ops->initiate_scan(&drv->wiphy, dev, &params);
 
 	kfree(channels);
  out:
--- wireless-dev.orig/net/wireless/wext-compat.c	2006-11-22 01:11:09.593927956 +0100
+++ wireless-dev/net/wireless/wext-compat.c	2006-11-22 01:11:48.123927956 +0100
@@ -121,7 +121,7 @@ static int cfg80211_wx_set_commit(struct
 		goto out;
 	}
 
-	err = drv->ops->configure(drv->priv, net_dev,
+	err = drv->ops->configure(&drv->wiphy, net_dev,
 				  net_dev->cfg80211_wext_pending_config);
 
 	kfree(net_dev->cfg80211_wext_pending_config);
@@ -532,7 +532,7 @@ static int cfg80211_wx_set_essid(struct 
 	err = -ENOSYS;
 	if (!drv->ops->configure || !drv->ops->get_config_valid)
 		goto out;
-	if (!(drv->ops->get_config_valid(drv->priv, net_dev)
+	if (!(drv->ops->get_config_valid(&drv->wiphy, net_dev)
 			& CFG80211_CFG_VALID_SSID))
 		goto out;
 
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/sysfs.c	2006-11-22 01:11:48.123927956 +0100
@@ -0,0 +1,63 @@
+/*
+ * This file provides /sys/class/ieee80211/<wiphy name>/
+ * and some default attributes.
+ *
+ * Copyright 2005-2006	Jiri Benc <jbenc@suse.cz>
+ * Copyright 2006	Johannes Berg <johannes@sipsolutions.net>
+ *
+ * This file is GPLv2 as found in COPYING.
+ */
+
+#include <net/cfg80211.h>
+#include <linux/device.h>
+#include "core.h"
+static inline struct cfg80211_registered_driver *cdev_to_drv(
+	struct class_device *cdev)
+{
+	return container_of(cdev, struct cfg80211_registered_driver, wiphy.class_dev);
+}
+
+static void wiphy_class_dev_release(struct class_device *cdev)
+{
+	struct cfg80211_registered_driver *drv = cdev_to_drv(cdev);
+
+	mutex_destroy(&drv->mtx);
+	kfree((char*)drv - drv->padded);
+}
+
+static int wiphy_uevent(struct class_device *cdev, char **envp,
+			int num_envp, char *buf, int size)
+{
+	return 0;
+}
+
+static struct class ieee80211_class = {
+	.name = "ieee80211",
+	.release = wiphy_class_dev_release,
+#ifdef CONFIG_HOTPLUG
+	.uevent = wiphy_uevent,
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
+
+int wiphy_sysfs_add(struct wiphy *wiphy)
+{
+	wiphy->class_dev.class = &ieee80211_class;
+	wiphy->class_dev.class_data = wiphy;
+	class_device_initialize(&wiphy->class_dev);
+	return class_device_add(&wiphy->class_dev);
+}
+
+void wiphy_sysfs_del(struct wiphy *wiphy)
+{
+	class_device_del(&wiphy->class_dev);
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/wireless/sysfs.h	2006-11-22 01:11:48.133927956 +0100
@@ -0,0 +1,10 @@
+#ifndef __WIRELESS_SYSFS_H
+#define __WIRELESS_SYSFS_H
+
+extern int wiphy_sysfs_init(void);
+extern void wiphy_sysfs_exit(void);
+
+extern int wiphy_sysfs_add(struct wiphy *wiphy);
+extern void wiphy_sysfs_del(struct wiphy *wiphy);
+
+#endif /* __WIRELESS_SYSFS_H */
--- wireless-dev.orig/net/wireless/Makefile	2006-11-22 01:11:09.743927956 +0100
+++ wireless-dev/net/wireless/Makefile	2006-11-22 01:11:48.133927956 +0100
@@ -1,7 +1,7 @@
 obj-$(CONFIG_CFG80211) += cfg80211.o
 
 cfg80211-objs := \
-	core.o nl80211.o
+	core.o nl80211.o sysfs.o
 
 obj-$(CONFIG_WIRELESS_EXT) += wext-old.o
 
--- wireless-dev.orig/include/linux/netdevice.h	2006-11-22 19:56:00.209711991 +0100
+++ wireless-dev/include/linux/netdevice.h	2006-11-22 19:56:37.529711991 +0100
@@ -42,6 +42,8 @@ struct divert_blk;
 struct vlan_group;
 struct ethtool_ops;
 struct netpoll_info;
+/* 802.11 specific */
+struct wiphy;
 					/* source back-compat hooks */
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
@@ -390,7 +392,7 @@ struct net_device
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
 	void			*ax25_ptr;	/* AX.25 specific data */
-	void			*ieee80211_ptr;	/* IEEE 802.11 specific data */
+	struct wiphy		*ieee80211_ptr;	/* IEEE 802.11 specific data */
 
 /*
  * Cache line mostly used on receive path (including eth_type_trans())


