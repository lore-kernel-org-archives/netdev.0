From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/13] move d80211 away from netdev towards wiphy
Date: Mon, 20 Nov 2006 00:32:23 +0100
Message-ID: <1163979143.9216.14.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38590 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933772AbWKSXeM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 18:34:12 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alright, a bit more thought later :)

Michael noted that letting people rename their wiphys is probably a good
idea to have stable based on the permanent mac address or such. Will
actually require moving the perm_addr field from struct ieee80211_hw
into struct wiphy (as below) too so that it's possible to query it
generically :)

Since d80211 also should relinquish control of this to cfg80211 I
decided that it was a good idea to make cfg80211 handle the wiphy stuff.
Also, I think cfg80211 should create /sys/class/ieee80211/<wiphy> to
allow renaming to follow through in sysfs.

My plan would be to do this:

 struct ieee80211_hw {
-       /* these are assigned by d80211, don't write */
-       int index;
+       /* points to the cfg80211 wiphy for this piece */
+       struct wiphy *wiphy;
+
+       /* assigned by d80211, don't write */
        struct ieee80211_conf conf;

along with the patch below.

In d80211, I'd then allocate ieee80211_hw and ieee80211_local along with
struct wiphy by doing wiphy_new() with the right size instead of
allocating it along with the master dev.

Thoughts?

--- wireless-dev.orig/include/net/cfg80211.h	2006-11-20 00:16:34.999275208 +0100
+++ wireless-dev/include/net/cfg80211.h	2006-11-20 00:23:01.569275208 +0100
@@ -7,9 +7,10 @@
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
@@ -164,28 +165,65 @@ struct cfg80211_ops {
 				 int (*next_bssid)(void *data, u8 *bssid));
 };
 
+#define WIPHYNAMESIZE	16
+
 /**
- * cfg80211_register - register a wiphy with cfg80211
+ * struct wiphy
  *
- * register a given method structure with the cfg80211 system
- * and associate the 'priv' pointer with it.
+ * @wiphy_index: the wiphy index assigned to this item
+ * @class_dev: the class device representing /sys/class/ieee80211/<wiphy-name>
+ * @name: name of this wiphy
+ */
+struct wiphy {
+	int wiphy_index;
+	struct class_device class_dev;
+	char name[WIPHYNAMESIZE];
+	void *priv;
+};
+
+/**
+ * wiphy_priv - return priv from wiphy
+ */
+static inline void *wiphy_priv(struct wiphy *wiphy)
+{
+	/* no fancy alignment for now... should probably do that */
+	return (char *)wiphy + sizeof(struct wiphy);
+}
+
+/**
+ * wiphy_new - create a new wiphy for use with cfg80211
  *
- * Returns a non-negative wiphy index or a negative error code.
+ * create a new wiphy and associate the given operations with it.
+ * @sizeof_priv bytes are allocated for private use.
  *
- * NOTE: for proper operation, this priv pointer MUST also be
- * assigned to each &struct net_device's @ieee80211_ptr member!
+ * the returned structure's driver-private pointer must be assigned
+ * to each netdev's ieee80211_ptr for proper operation.
  */
-extern int cfg80211_register(struct cfg80211_ops *ops, void *priv);
+struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv);
 
 /**
- * cfg80211_unregister - deregister a wiphy from cfg80211
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
--- wireless-dev.orig/net/wireless/core.c	2006-11-20 00:16:35.059275208 +0100
+++ wireless-dev/net/wireless/core.c	2006-11-20 00:23:01.569275208 +0100
@@ -33,7 +33,7 @@ static struct cfg80211_registered_driver
 		return NULL;
 
 	list_for_each_entry(drv, &cfg80211_drv_list, list) {
-		if (drv->priv == priv) {
+		if (drv_priv(drv) == priv) {
 			result = drv;
 			break;
 		}
@@ -48,7 +48,7 @@ static struct cfg80211_registered_driver
 	struct cfg80211_registered_driver *result = NULL, *drv;
 
 	list_for_each_entry(drv, &cfg80211_drv_list, list) {
-		if (drv->wiphy == wiphy) {
+		if (drv->wiphy.wiphy_index == wiphy) {
 			result = drv;
 			break;
 		}
@@ -146,41 +146,56 @@ void cfg80211_put_drv(struct cfg80211_re
 
 /* exported functions */
 
-int cfg80211_register(struct cfg80211_ops *ops, void *priv)
+struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv)
 {
-	struct cfg80211_registered_driver *drv;
-	int res;
+	struct cfg80211_registered_driver *result;
 
-	if (!priv || !ops->list_interfaces)
-		return -EINVAL;
+	int size = sizeof(struct cfg80211_registered_driver)
+		 + sizeof_priv;
 
-	mutex_lock(&cfg80211_drv_mutex);
+	if (!ops->list_interfaces)
+		return NULL;
 
-	if (cfg80211_drv_by_priv(priv)) {
-		res = -EALREADY;
-		goto out_unlock;
-	}
+	result = kzalloc(size, GFP_KERNEL);
+	if (!result)
+		return NULL;
 
-	drv = kzalloc(sizeof(struct cfg80211_registered_driver), GFP_KERNEL);
-	if (!drv) {
-		res = -ENOMEM;
-		goto out_unlock;
-	}
+	result->wiphy.priv = drv_priv(result);
+
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
 
-	drv->ops = ops;
-	drv->priv = priv;
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
 	/* return wiphy number */
-	res = drv->wiphy;
+	res = drv->wiphy.wiphy_index;
+
+	/* give it a proper name */
+	snprintf(drv->wiphy.name, sizeof(drv->wiphy.name),
+		 "wiphy%d", drv->wiphy.wiphy_index);
+
+	/* TODO:
+	 * - allocate class device for /sys/class/ieee80211
+	 * - move code over from d80211 to do all that
+	 * - allow renaming of devices via netlink/whatever
+	 *   and keep name up to date
+	 */
 
 	/* now increase counter for the next time */
 	wiphy_counter++;
@@ -189,20 +204,13 @@ int cfg80211_register(struct cfg80211_op
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
@@ -211,11 +219,17 @@ void cfg80211_unregister(void *priv)
 	mutex_unlock(&drv->mtx);
 
 	mutex_unlock(&cfg80211_drv_mutex);
+}
+EXPORT_SYMBOL_GPL(wiphy_unregister);
+
+void wiphy_free(struct wiphy *wiphy)
+{
+	struct cfg80211_registered_driver *drv = wiphy_to_drv(wiphy);
 
 	mutex_destroy(&drv->mtx);
 	kfree(drv);
 }
-EXPORT_SYMBOL_GPL(cfg80211_unregister);
+EXPORT_SYMBOL_GPL(wiphy_free);
 
 /* module initialisation/exit functions */
 
--- wireless-dev.orig/net/wireless/core.h	2006-11-20 00:16:35.109275208 +0100
+++ wireless-dev/net/wireless/core.h	2006-11-20 00:23:01.569275208 +0100
@@ -13,16 +13,25 @@
 
 struct cfg80211_registered_driver {
 	struct cfg80211_ops *ops;
-	int wiphy;
-	void *priv;
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
+static inline void *drv_priv(struct cfg80211_registered_driver *drv)
+{
+	return wiphy_priv(&drv->wiphy);
+}
+
 extern struct mutex cfg80211_drv_mutex;
 extern struct list_head cfg80211_drv_list;
 
--- wireless-dev.orig/net/wireless/nl80211.c	2006-11-20 00:16:35.269275208 +0100
+++ wireless-dev/net/wireless/nl80211.c	2006-11-20 00:23:01.579275208 +0100
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
+	err = drv->ops->list_interfaces(drv_priv(drv), &cb, addifidx);
 	if (err)
 		goto msg_free;
 
@@ -300,7 +300,7 @@ static int nl80211_do_inject(struct sk_b
 		goto unlock;
 	}
 
-	err = drv->ops->inject_packet(drv->priv,
+	err = drv->ops->inject_packet(drv_priv(drv),
 		nla_data(info->attrs[NL80211_ATTR_FRAME]),
 		nla_len(info->attrs[NL80211_ATTR_FRAME]),
 		flags,
@@ -334,7 +334,7 @@ static int nl80211_add_virt_intf(struct 
 		goto unlock;
 	}
 
-	err = drv->ops->add_virtual_intf(drv->priv,
+	err = drv->ops->add_virtual_intf(drv_priv(drv),
 		nla_data(info->attrs[NL80211_ATTR_IFNAME]), type);
 
  unlock:
@@ -359,7 +359,7 @@ static int nl80211_del_virt_intf(struct 
 		goto out;
 	}
 
-	err = drv->ops->del_virtual_intf(drv->priv, ifindex);
+	err = drv->ops->del_virtual_intf(drv_priv(drv), ifindex);
 
  out:
 	cfg80211_put_drv(drv);
@@ -421,7 +421,7 @@ static int nl80211_configure(struct sk_b
 		config.channel = nla_get_u32(attr);
 	}
 
-	err = drv->ops->configure(drv->priv, dev, &config);
+	err = drv->ops->configure(drv_priv(drv), dev, &config);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -448,7 +448,7 @@ static int nl80211_get_config(struct sk_
 
 	memset(&config, 0, sizeof(config));
 
-	drv->ops->get_config(drv->priv, dev, &config);
+	drv->ops->get_config(drv_priv(drv), dev, &config);
 
 	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_NEW_CONFIG);
@@ -514,7 +514,7 @@ static int nl80211_set_roaming(struct sk
 		goto out;
 	}
 
-	err = drv->ops->set_roaming(drv->priv, dev, roaming_control);
+	err = drv->ops->set_roaming(drv_priv(drv), dev, roaming_control);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -538,7 +538,7 @@ static int nl80211_get_roaming(struct sk
 		goto out_put_drv;
 	}
 
-	err = drv->ops->get_roaming(drv->priv, dev);
+	err = drv->ops->get_roaming(drv_priv(drv), dev);
 	if (err < 0)
 		goto out_put_drv;
 
@@ -586,7 +586,7 @@ static int nl80211_set_fixed_bssid(struc
 		goto out;
 	}
 
-	err = drv->ops->set_fixed_bssid(drv->priv, dev, bssid);
+	err = drv->ops->set_fixed_bssid(drv_priv(drv), dev, bssid);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -611,7 +611,7 @@ static int nl80211_get_fixed_bssid(struc
 		goto out_put_drv;
 	}
 
-	err = drv->ops->get_fixed_bssid(drv->priv, dev, bssid);
+	err = drv->ops->get_fixed_bssid(drv_priv(drv), dev, bssid);
 	if (err < 0)
 		goto out_put_drv;
 
@@ -657,7 +657,7 @@ static int nl80211_get_association(struc
 		goto out_put_drv;
 	}
 
-	err = drv->ops->get_association(drv->priv, dev, bssid);
+	err = drv->ops->get_association(drv_priv(drv), dev, bssid);
 	if (err < 0)
 		goto out_put_drv;
 
@@ -716,7 +716,7 @@ static int nl80211_assoc_deauth(struct s
 		goto out;
 	}
 
-	err = act(drv->priv, dev);
+	err = act(drv_priv(drv), dev);
  out:
 	cfg80211_put_drv(drv);
 	dev_put(dev);
@@ -778,7 +778,7 @@ static int nl80211_get_auth_list(struct 
 
 	cb.skb = msg;
 	cb.idx = 1;
-	err = drv->ops->get_auth_list(drv->priv, dev, &cb, add_bssid);
+	err = drv->ops->get_auth_list(drv_priv(drv), dev, &cb, add_bssid);
 	if (err)
 		goto msg_free;
 
@@ -874,7 +874,7 @@ static int nl80211_initiate_scan(struct 
 	params.channels = channels;
 	params.n_channels = count;
 
-	err = drv->ops->initiate_scan(drv->priv, dev, &params);
+	err = drv->ops->initiate_scan(drv_priv(drv), dev, &params);
 
 	kfree(channels);
  out:
--- wireless-dev.orig/net/wireless/wext-compat.c	2006-11-20 00:16:35.169275208 +0100
+++ wireless-dev/net/wireless/wext-compat.c	2006-11-20 00:23:01.579275208 +0100
@@ -121,7 +121,7 @@ static int cfg80211_wx_set_commit(struct
 		goto out;
 	}
 
-	err = drv->ops->configure(drv->priv, net_dev,
+	err = drv->ops->configure(drv_priv(drv), net_dev,
 				  net_dev->cfg80211_wext_pending_config);
 
 	kfree(net_dev->cfg80211_wext_pending_config);
@@ -532,7 +532,7 @@ static int cfg80211_wx_set_essid(struct 
 	err = -ENOSYS;
 	if (!drv->ops->configure || !drv->ops->get_config_valid)
 		goto out;
-	if (!(drv->ops->get_config_valid(drv->priv, net_dev)
+	if (!(drv->ops->get_config_valid(drv_priv(drv), net_dev)
 			& CFG80211_CFG_VALID_SSID))
 		goto out;
 


