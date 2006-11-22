From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 2/3] d80211: use new wiphy stuff from cfg80211
Date: Wed, 22 Nov 2006 20:24:48 +0100
Message-ID: <1164223488.5934.27.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:43414 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756704AbWKVT06
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 14:26:58 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <1164223133.5934.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch lets d80211 use the new wiphy stuff from cfg80211.

Patch is large because cfg80211 requires the net_dev->ieee80211_ptr now.

--- wireless-dev.orig/include/net/d80211.h	2006-11-22 20:10:20.029711991 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-22 20:11:11.659711991 +0100
@@ -15,6 +15,7 @@
 #include <linux/skbuff.h>
 #include <linux/wireless.h>
 #include <linux/device.h>
+#include <net/cfg80211.h>
 #include "d80211_shared.h"
 
 /* Note! Only ieee80211_tx_status_irqsafe() and ieee80211_rx_irqsafe() can be
@@ -425,21 +426,20 @@ typedef enum {
  * If you change something in here, call ieee80211_update_hw() to
  * notify the stack about the change. */
 struct ieee80211_hw {
-	/* these are assigned by d80211, don't write */
-	int index;
+	/* points to the cfg80211 wiphy for this piece.
+	 * Note that you must fill in the perm_addr and dev
+	 * fields of this structure. */
+	struct wiphy *wiphy;
+
+	/* assigned by d80211, don't write */
 	struct ieee80211_conf conf;
 
 	/* Pointer to the private area that was
-	 * allocated with this struct for you. */
+	 * allocated with this struct for you.*/
 	void *priv;
 
 	/* The rest is information about your hardware */
 
-	struct device *dev;
-
-	/* permanent mac address */
-	u8 perm_addr[ETH_ALEN];
-
 	/* TODO: frame_type 802.11/802.3, sw_encryption requirements */
 
 	/* Some wireless LAN chipsets generate beacons in the hardware/firmware
@@ -521,6 +521,16 @@ struct ieee80211_hw {
 	int queues;
 };
 
+static inline void SET_IEEE80211_DEV(struct ieee80211_hw *hw, struct device *dev)
+{
+	hw->wiphy->dev = dev;
+}
+
+static inline void SET_IEEE80211_PERM_ADDR(struct ieee80211_hw *hw, u8 *addr)
+{
+	memcpy(hw->wiphy->perm_addr, addr, ETH_ALEN);
+}
+
 /* Configuration block used by the low-level driver to tell the 802.11 code
  * about supported hardware features and to pass function pointers to callback
  * functions. */
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-22 20:10:20.089711991 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-22 20:11:11.669711991 +0100
@@ -21,6 +21,7 @@
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
 #include <linux/bitmap.h>
+#include <net/cfg80211.h>
 
 #include <net/d80211_common.h>
 #include <net/d80211_mgmt.h>
@@ -32,6 +33,8 @@
 #include "wme.h"
 #include "aes_ccm.h"
 #include "ieee80211_led.h"
+#include "ieee80211_cfg.h"
+#include "ieee80211_sysfs.h"
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
@@ -210,7 +213,7 @@ static void ieee80211_key_threshold_noti
 					   struct ieee80211_key *key,
 					   struct sta_info *sta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sk_buff *skb;
 	struct ieee80211_msg_key_notification *msg;
 
@@ -1057,7 +1060,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		       struct net_device *dev,
 		       struct ieee80211_tx_control *control)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	int hdrlen;
 
@@ -1100,7 +1103,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 static int inline is_ieee80211_device(struct net_device *dev,
 				      struct net_device *master)
 {
-	return (dev->ieee80211_ptr == master->ieee80211_ptr);
+	return (wiphy_priv(dev->ieee80211_ptr) == wiphy_priv(master->ieee80211_ptr));
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
@@ -1197,7 +1200,7 @@ static int __ieee80211_tx(struct ieee802
 static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 			struct ieee80211_tx_control *control, int mgmt)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 	ieee80211_tx_handler *handler;
 	struct ieee80211_txrx_data tx;
@@ -1427,7 +1430,7 @@ static int ieee80211_master_start_xmit(s
 static int ieee80211_subif_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_packet_data *pkt_data;
         struct ieee80211_sub_if_data *sdata;
 	int ret = 1, head_need;
@@ -1869,7 +1872,7 @@ static int __ieee80211_if_config(struct 
 				 struct sk_buff *beacon)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_if_conf conf;
 
 	if (!local->ops->config_interface || !netif_running(dev))
@@ -1902,7 +1905,7 @@ int ieee80211_if_config(struct net_devic
 
 int ieee80211_if_config_beacon(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sk_buff *skb;
 
 	if (!(local->hw.flags & IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE))
@@ -1981,7 +1984,7 @@ static int ieee80211_change_mtu_apdev(st
 
 static void ieee80211_tx_timeout(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	printk(KERN_WARNING "%s: resetting interface.\n", dev->name);
 
@@ -2005,7 +2008,7 @@ static int ieee80211_set_mac_address(str
 
 static void ieee80211_set_multicast_list(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	unsigned short flags;
 
@@ -2083,7 +2086,7 @@ static struct net_device_stats *ieee8021
 
 void ieee80211_if_shutdown(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	ASSERT_RTNL();
@@ -2123,7 +2126,7 @@ static inline int identical_mac_addr_all
 
 static int ieee80211_master_open(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 	int res = -EOPNOTSUPP;
 
@@ -2139,7 +2142,7 @@ static int ieee80211_master_open(struct 
 
 static int ieee80211_master_stop(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 
 	tasklet_disable(&local->tx_pending_tasklet);
@@ -2152,7 +2155,7 @@ static int ieee80211_master_stop(struct 
 
 static int ieee80211_mgmt_open(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (!netif_running(local->mdev))
 		return -EOPNOTSUPP;
@@ -2199,7 +2202,7 @@ static void ieee80211_start_hard_monitor
 static int ieee80211_open(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata, *nsdata;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_if_init_conf conf;
 	int res;
 
@@ -2279,7 +2282,7 @@ static int ieee80211_open(struct net_dev
 static int ieee80211_stop(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
@@ -2640,7 +2643,7 @@ void
 ieee80211_rx_monitor(struct net_device *dev, struct sk_buff *skb,
 		     struct ieee80211_rx_status *status)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_frame_info *fi;
 	struct ieee80211_sub_if_data *sdata;
 	const size_t hlen = sizeof(struct ieee80211_frame_info)
@@ -2747,7 +2750,7 @@ static void ap_sta_ps_start(struct net_d
 
 static int ap_sta_ps_end(struct net_device *dev, struct sta_info *sta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sk_buff *skb;
 	int sent = 0;
 	struct ieee80211_sub_if_data *sdata;
@@ -4297,7 +4300,7 @@ static ieee80211_tx_handler ieee80211_tx
 
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct sta_info *sta;
 
@@ -4386,7 +4389,7 @@ int ieee80211_init_rate_ctrl_alg(struct 
 		       "algorithm\n", local->mdev->name);
 		return -ENOENT;
 	}
-	res = rate_control_add_attrs(ref, &local->class_dev.kobj);
+	res = rate_control_add_attrs(ref, &local->hw.wiphy->class_dev.kobj);
 	if (res < 0) {
 		printk(KERN_DEBUG "%s: Failed to register sysfs attributes "
 		       "for rate control\n", local->mdev->name);
@@ -4397,7 +4400,7 @@ int ieee80211_init_rate_ctrl_alg(struct 
 	old = local->rate_ctrl;
 	local->rate_ctrl = ref;
 	if (old) {
-		rate_control_remove_attrs(ref, &local->class_dev.kobj);
+		rate_control_remove_attrs(ref, &local->hw.wiphy->class_dev.kobj);
 		rate_control_put(old);
 		sta_info_flush(local, NULL);
 	}
@@ -4416,51 +4419,61 @@ static void rate_control_deinitialize(st
 
 	ref = local->rate_ctrl;
 	local->rate_ctrl = NULL;
-	rate_control_remove_attrs(ref, &local->class_dev.kobj);
+	rate_control_remove_attrs(ref, &local->hw.wiphy->class_dev.kobj);
 	rate_control_put(ref);
 }
 
 struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
-					      struct ieee80211_ops *ops)
+					struct ieee80211_ops *ops)
 {
 	struct net_device *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
 	int priv_size;
-
-	local = ieee80211_dev_alloc(GFP_KERNEL);
-	if (!local)
-		return NULL;
-
-	local->ops = ops;
+	struct wiphy *wiphy;
 
 	/* Ensure 32-byte alignment of our private data and hw private data.
-	 * Each net_device is followed by a sub_if_data which is used for
-	 * interface specific information.
+	 * We use the wiphy priv data for both our ieee80211_local and for
+	 * the driver's private data
 	 *
-         * Sample memory map looks something like:
-         *
-         * 0000 *****************
-         *      * net_dev       *
-	 * 0160 *****************
-         *      * sub_if        *
-	 * 0b80 *****************
-         *      * hw_priv       *
-         * 1664 *****************
-         */
-	priv_size = ((sizeof(struct ieee80211_sub_if_data) +
+	 * In memory it'll be like this:
+	 *
+	 * +-------------------------+
+	 * | struct wiphy            |
+	 * +-------------------------+
+	 * | struct ieee80211_local  |
+	 * +-------------------------+
+	 * | driver's private data   |
+	 * +-------------------------+
+	 *
+	 */
+	priv_size = ((sizeof(struct ieee80211_local) +
 		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
 		    priv_data_len;
-	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
+
+	wiphy = wiphy_new(&d80211_config_ops, priv_size);
+
+	if (!wiphy)
+		return NULL;
+
+	local = wiphy->priv;
+	local->hw.wiphy = wiphy;
+
+	local->hw.priv = (char *)local +
+			 ((sizeof(struct ieee80211_local) +
+			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+
+	local->ops = ops;
+
+	/* for now, mdev needs sub_if_data :/ */
+	mdev = alloc_netdev(sizeof(struct ieee80211_sub_if_data),
+			    "wmaster%d", ether_setup);
 	if (!mdev) {
-		ieee80211_dev_free(local);
+		wiphy_free(wiphy);
 		return NULL;
 	}
 
-	mdev->ieee80211_ptr = local;
-	local->hw.priv = (char *)mdev->priv +
-			 ((sizeof(struct ieee80211_sub_if_data) +
-			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	mdev->ieee80211_ptr = wiphy;
 
 	local->mdev = mdev;
 	local->rx_pre_handlers = ieee80211_rx_pre_handlers;
@@ -4534,11 +4547,9 @@ int ieee80211_register_hw(struct ieee802
 	struct net_device *sta_dev;
 	int result;
 
-	result = ieee80211_dev_alloc_index(local);
+	result = wiphy_register(local->hw.wiphy);
 	if (result < 0)
-		return -1;
-
-	local->class_dev.dev = local->hw.dev;
+		return result;
 
 	result = ieee80211_dev_sysfs_add(local);
 	if (result < 0)
@@ -4562,21 +4573,14 @@ int ieee80211_register_hw(struct ieee802
 		goto fail_dev;
 	}
 
-	memcpy(local->mdev->dev_addr, local->hw.perm_addr, ETH_ALEN);
-	SET_NETDEV_DEV(local->mdev, local->hw.dev);
+	memcpy(local->mdev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
+	SET_NETDEV_DEV(local->mdev, local->hw.wiphy->dev);
 
 	result = register_netdevice(local->mdev);
 	if (result < 0) {
 		rtnl_unlock();
 		goto fail_dev;
 	}
-	result = sysfs_create_link(&local->class_dev.kobj,
-				   &local->mdev->class_dev.kobj,
-				   "master");
-	if (result < 0) {
-		rtnl_unlock();
-		goto fail_masterlink;
-	}
 	result = ieee80211_sysfs_add_netdevice(local->mdev);
 	if (result < 0) {
 		rtnl_unlock();
@@ -4620,15 +4624,13 @@ fail_wep:
 fail_rate:
 	ieee80211_sysfs_remove_netdevice(local->mdev);
 fail_if_sysfs:
-	sysfs_remove_link(&local->class_dev.kobj, "master");
-fail_masterlink:
 	unregister_netdev(local->mdev);
 fail_dev:
 	sta_info_stop(local);
 fail_sta_info:
 	ieee80211_dev_sysfs_del(local);
 fail_sysfs:
-	ieee80211_dev_free_index(local);
+	wiphy_unregister(local->hw.wiphy);
 	return result;
 }
 EXPORT_SYMBOL(ieee80211_register_hw);
@@ -4677,8 +4679,6 @@ void ieee80211_unregister_hw(struct ieee
 	if (local->apdev)
 		ieee80211_if_del_mgmt(local);
 
-	sysfs_remove_link(&local->class_dev.kobj, "master");
-
 	list_for_each_entry_safe(sdata, tmp, &local->sub_if_list, list)
 		__ieee80211_if_del(local, sdata);
 
@@ -4714,7 +4714,7 @@ void ieee80211_unregister_hw(struct ieee
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);
 
-	ieee80211_dev_free_index(local);
+	wiphy_unregister(local->hw.wiphy);
 	ieee80211_led_exit(local);
 }
 EXPORT_SYMBOL(ieee80211_unregister_hw);
@@ -4725,15 +4725,10 @@ void ieee80211_free_hw(struct ieee80211_
 
 	ieee80211_if_free(local->mdev);
 	ieee80211_wep_free(local);
-	ieee80211_dev_free(local);
+	wiphy_free(local->hw.wiphy);
 }
 EXPORT_SYMBOL(ieee80211_free_hw);
 
-void ieee80211_release_hw(struct ieee80211_local *local)
-{
-	kfree(local);
-}
-
 /* Perform netif operations on all configured interfaces */
 int ieee80211_netif_oper(struct ieee80211_hw *hw, Netif_Oper op)
 {
@@ -4831,22 +4826,13 @@ static int __init ieee80211_init(void)
 
 	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
 
-	if ((ret = ieee80211_sysfs_init())) {
-		printk(KERN_WARNING "ieee80211_init: sysfs initialization "
-		       "failed\n");
+	ret = ieee80211_wme_register();
+	if (ret) {
+		printk(KERN_DEBUG "ieee80211_init: failed to "
+		       "initialize WME (err=%d)\n", ret);
 		return ret;
 	}
 
-	{
-		ret = ieee80211_wme_register();
-		if (ret) {
-			printk(KERN_DEBUG "ieee80211_init: failed to "
-			       "initialize WME (err=%d)\n", ret);
-			ieee80211_sysfs_deinit();
-			return ret;
-		}
-	}
-
 	return 0;
 }
 
@@ -4854,7 +4840,6 @@ static int __init ieee80211_init(void)
 static void __exit ieee80211_exit(void)
 {
 	ieee80211_wme_unregister();
-	ieee80211_sysfs_deinit();
 }
 
 
--- wireless-dev.orig/net/d80211/Makefile	2006-11-22 20:10:20.109711991 +0100
+++ wireless-dev/net/d80211/Makefile	2006-11-22 20:11:11.669711991 +0100
@@ -10,7 +10,6 @@ obj-$(CONFIG_D80211) += 80211.o rc80211_
 	wpa.o \
 	ieee80211_scan.o \
 	ieee80211_sta.o \
-	ieee80211_dev.o \
 	ieee80211_iface.o \
 	ieee80211_rate.o \
 	ieee80211_sysfs.o \
@@ -19,6 +18,7 @@ obj-$(CONFIG_D80211) += 80211.o rc80211_
 	tkip.o \
 	aes_ccm.o \
 	wme.o \
+	ieee80211_cfg.o \
 	$(80211-objs-y)
 
 ifeq ($(CONFIG_NET_SCHED),)
--- wireless-dev.orig/net/d80211/ieee80211_dev.c	2006-11-22 20:10:20.119711991 +0100
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,117 +0,0 @@
-/*
- * Copyright (c) 2006 Jiri Benc <jbenc@suse.cz>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/kernel.h>
-#include <linux/interrupt.h>
-#include <linux/if.h>
-#include <linux/if_ether.h>
-#include <linux/netdevice.h>
-#include <net/d80211.h>
-#include "ieee80211_i.h"
-#include "ieee80211_led.h"
-
-struct ieee80211_dev_list {
-	struct list_head list;
-	int dev_index;
-	struct ieee80211_local *local;
-};
-
-static LIST_HEAD(dev_list);
-static DEFINE_SPINLOCK(dev_list_lock);
-
-
-/* Caller must hold dev_list_lock */
-static struct ieee80211_dev_list *__ieee80211_dev_find(int index)
-{
-	struct ieee80211_dev_list *dev_item;
-
-	list_for_each_entry(dev_item, &dev_list, list) {
-		if (dev_item->dev_index == index)
-			return dev_item;
-	}
-	return NULL;
-}
-
-int ieee80211_dev_alloc_index(struct ieee80211_local *local)
-{
-	struct ieee80211_dev_list *dev_item, *new;
-	int index = 0;
-
-	new = kmalloc(sizeof(struct ieee80211_dev_list), GFP_KERNEL);
-	if (!new)
-		return -ENOMEM;
-	new->local = local;
-	spin_lock(&dev_list_lock);
-	list_for_each_entry(dev_item, &dev_list, list) {
-		if (index < dev_item->dev_index)
-			break;
-		index++;
-	}
-	new->dev_index = index;
-	list_add_tail(&new->list, &dev_item->list);
-	spin_unlock(&dev_list_lock);
-	local->hw.index = index;
-	return index;
-}
-
-void ieee80211_dev_free_index(struct ieee80211_local *local)
-{
-	struct ieee80211_dev_list *dev_item;
-
-	spin_lock(&dev_list_lock);
-	dev_item = __ieee80211_dev_find(local->hw.index);
-	if (dev_item)
-		list_del(&dev_item->list);
-	spin_unlock(&dev_list_lock);
-	if (dev_item)
-		kfree(dev_item);
-	local->hw.index = -1;
-}
-
-struct ieee80211_local *ieee80211_dev_find(int index)
-{
-	struct ieee80211_dev_list *dev_item;
-
-	spin_lock(&dev_list_lock);
-	dev_item = __ieee80211_dev_find(index);
-	spin_unlock(&dev_list_lock);
-	return dev_item ? dev_item->local : NULL;
-}
-
-int ieee80211_dev_find_index(struct ieee80211_local *local)
-{
-	struct ieee80211_dev_list *dev_item;
-	int index = -1;
-
-	spin_lock(&dev_list_lock);
-	list_for_each_entry(dev_item, &dev_list, list) {
-		if (dev_item->local == local) {
-			index = dev_item->dev_index;
-			break;
-		}
-	}
-	spin_unlock(&dev_list_lock);
-	return index;
-}
-
-struct ieee80211_local *ieee80211_dev_alloc(gfp_t flags)
-{
-	struct ieee80211_local *local;
-
-	local = kzalloc(sizeof(struct ieee80211_local), flags);
-	if (!local)
-		return NULL;
-	local->hw.index = -1;
-	ieee80211_dev_sysfs_init(local);
-	return local;
-}
-
-void ieee80211_dev_free(struct ieee80211_local *local)
-{
-	ieee80211_dev_sysfs_put(local);
-}
--- wireless-dev.orig/net/d80211/ieee80211_iface.c	2006-11-22 20:10:20.159711991 +0100
+++ wireless-dev/net/d80211/ieee80211_iface.c	2006-11-22 20:11:11.669711991 +0100
@@ -15,6 +15,7 @@
 #include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "sta_info.h"
+#include "ieee80211_sysfs.h"
 
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
 {
@@ -41,7 +42,7 @@ int ieee80211_if_add(struct net_device *
 		     int format, struct net_device **new_dev)
 {
 	struct net_device *ndev, *tmp_dev;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
 	int ret;
 	int i;
@@ -52,7 +53,7 @@ int ieee80211_if_add(struct net_device *
 	if (!ndev)
 		return -ENOMEM;
 
-	ndev->ieee80211_ptr = local;
+	ndev->ieee80211_ptr = local->hw.wiphy;
 	if (strlen(name) == 0) {
 		i = 0;
 		do {
@@ -70,13 +71,13 @@ int ieee80211_if_add(struct net_device *
 		snprintf(ndev->name, IFNAMSIZ, "%s", name);
 	}
 
-	memcpy(ndev->dev_addr, local->hw.perm_addr, ETH_ALEN);
+	memcpy(ndev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
 	ndev->base_addr = dev->base_addr;
 	ndev->irq = dev->irq;
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
 	ndev->flags = dev->flags & IFF_MULTICAST;
-	SET_NETDEV_DEV(ndev, local->hw.dev);
+	SET_NETDEV_DEV(ndev, local->hw.wiphy->dev);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -122,9 +123,9 @@ int ieee80211_if_add_mgmt(struct ieee802
 	if (ret < 0)
 		goto fail;
 
-	ndev->ieee80211_ptr = local;
-	memcpy(ndev->dev_addr, local->hw.perm_addr, ETH_ALEN);
-	SET_NETDEV_DEV(ndev, local->hw.dev);
+	ndev->ieee80211_ptr = local->hw.wiphy;
+	memcpy(ndev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
+	SET_NETDEV_DEV(ndev, local->hw.wiphy->dev);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_MGMT;
@@ -210,7 +211,7 @@ void ieee80211_if_set_type(struct net_de
 /* Must be called with rtnl lock held. */
 void ieee80211_if_reinit(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct sta_info *sta;
 	int i;
@@ -319,7 +320,7 @@ void __ieee80211_if_del(struct ieee80211
 /* Must be called with rtnl lock held. */
 int ieee80211_if_remove(struct net_device *dev, const char *name, int id)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata, *n;
 
 	ASSERT_RTNL();
@@ -337,7 +338,7 @@ int ieee80211_if_remove(struct net_devic
 
 void ieee80211_if_free(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	/* local->apdev must be NULL when freeing management interface */
@@ -349,7 +350,7 @@ void ieee80211_if_free(struct net_device
 /* Must be called with rtnl lock held. */
 void ieee80211_if_flush(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata, *n;
 
 	ASSERT_RTNL();
@@ -360,7 +361,7 @@ void ieee80211_if_flush(struct net_devic
 
 void ieee80211_if_del(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	rtnl_lock();
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-11-22 20:10:20.199711991 +0100
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-11-22 20:11:11.679711991 +0100
@@ -342,8 +342,6 @@ struct ieee80211_local {
 	int monitors;
 	struct iw_statistics wstats;
 
-	struct class_device class_dev;
-
 	enum {
 		IEEE80211_DEV_UNITIALIZED = 0,
 		IEEE80211_DEV_REGISTERED,
@@ -575,7 +573,6 @@ static inline void bss_tim_clear(struct 
 }
 
 /* ieee80211.c */
-void ieee80211_release_hw(struct ieee80211_local *local);
 int ieee80211_hw_config(struct ieee80211_local *local);
 int ieee80211_if_config(struct net_device *dev);
 int ieee80211_if_config_beacon(struct net_device *dev);
@@ -657,14 +654,6 @@ struct sta_info * ieee80211_ibss_add_sta
 int ieee80211_sta_deauthenticate(struct net_device *dev, u16 reason);
 int ieee80211_sta_disassociate(struct net_device *dev, u16 reason);
 
-/* ieee80211_dev.c */
-int ieee80211_dev_alloc_index(struct ieee80211_local *local);
-void ieee80211_dev_free_index(struct ieee80211_local *local);
-struct ieee80211_local *ieee80211_dev_find(int index);
-int ieee80211_dev_find_index(struct ieee80211_local *local);
-struct ieee80211_local *ieee80211_dev_alloc(gfp_t flags);
-void ieee80211_dev_free(struct ieee80211_local *local);
-
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
 		     int format, struct net_device **new_dev);
@@ -680,17 +669,6 @@ void ieee80211_if_sdata_init(struct ieee
 int ieee80211_if_add_mgmt(struct ieee80211_local *local);
 void ieee80211_if_del_mgmt(struct ieee80211_local *local);
 
-/* ieee80211_sysfs.c */
-int ieee80211_sysfs_add_netdevice(struct net_device *dev);
-void ieee80211_sysfs_remove_netdevice(struct net_device *dev);
-void ieee80211_dev_sysfs_init(struct ieee80211_local *local);
-void ieee80211_dev_sysfs_put(struct ieee80211_local *local);
-int ieee80211_dev_sysfs_add(struct ieee80211_local *local);
-void ieee80211_dev_sysfs_del(struct ieee80211_local *local);
-int ieee80211_sysfs_init(void);
-void ieee80211_sysfs_deinit(void);
-int ieee80211_sysfs_change_if_type(struct net_device *dev);
-
 /* ieee80211_sysfs_sta.c */
 int ieee80211_sta_kset_sysfs_register(struct ieee80211_local *local);
 void ieee80211_sta_kset_sysfs_unregister(struct ieee80211_local *local);
--- wireless-dev.orig/net/d80211/ieee80211_led.c	2006-11-22 20:10:20.239711991 +0100
+++ wireless-dev/net/d80211/ieee80211_led.c	2006-11-22 20:11:11.679711991 +0100
@@ -39,7 +39,7 @@ void ieee80211_led_init(struct ieee80211
 	if (!local->rx_led)
 		return;
 	snprintf(local->rx_led_name, sizeof(local->rx_led_name),
-		 "wiphy%drx", local->hw.index);
+		 "wiphy%drx", local->hw.wiphy->wiphy_index);
 	local->rx_led->name = local->rx_led_name;
 	if (led_trigger_register(local->rx_led)) {
 		kfree(local->rx_led);
@@ -50,7 +50,7 @@ void ieee80211_led_init(struct ieee80211
 	if (!local->tx_led)
 		return;
 	snprintf(local->tx_led_name, sizeof(local->tx_led_name),
-		 "wiphy%dtx", local->hw.index);
+		 "wiphy%dtx", local->hw.wiphy->wiphy_index);
 	local->tx_led->name = local->tx_led_name;
 	if (led_trigger_register(local->tx_led)) {
 		kfree(local->tx_led);
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-11-22 20:10:20.279711991 +0100
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-11-22 20:11:11.679711991 +0100
@@ -13,11 +13,16 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
+#include <net/cfg80211.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 
-#define to_ieee80211_local(class) \
-	container_of(class, struct ieee80211_local, class_dev)
+static inline struct ieee80211_local *to_ieee80211_local(struct class_device *dev)
+{
+	struct wiphy *wiphy = container_of(dev, struct wiphy, class_dev);
+	return wiphy->priv;
+}
+
 #define to_net_dev(class) \
 	container_of(class, struct net_device, class_dev)
 
@@ -65,45 +70,6 @@ static const char *ieee80211_mode_str(in
 
 /* attributes in /sys/class/ieee80211/phyX/ */
 
-static ssize_t store_add_iface(struct class_device *dev,
-			       const char *buf, size_t len)
-{
-	struct ieee80211_local *local = to_ieee80211_local(dev);
-	struct net_device *new_dev;
-	int res;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-	if (len > IFNAMSIZ)
-		return -EINVAL;
-	res = rtnl_lock_local(local);
-	if (res)
-		return res;
-	res = ieee80211_if_add(local->mdev, buf, 0, &new_dev);
-	if (res == 0)
-		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
-	rtnl_unlock();
-	return res < 0 ? res : len;
-}
-
-static ssize_t store_remove_iface(struct class_device *dev,
-				  const char *buf, size_t len)
-{
-	struct ieee80211_local *local = to_ieee80211_local(dev);
-	int res;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-	if (len > IFNAMSIZ)
-		return -EINVAL;
-	res = rtnl_lock_local(local);
-	if (res)
-		return res;
-	res = ieee80211_if_remove(local->mdev, buf, -1);
-	rtnl_unlock();
-	return res < 0 ? res : len;
-}
-
 static ssize_t store_rate_ctrl_alg(struct class_device *dev,
 				   const char *buf, size_t len)
 {
@@ -213,8 +179,6 @@ static ssize_t ieee80211_local_fmt_rate_
 __IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
 
 static struct class_device_attribute ieee80211_class_dev_attrs[] = {
-	__ATTR(add_iface, S_IWUGO, NULL, store_add_iface),
-	__ATTR(remove_iface, S_IWUGO, NULL, store_remove_iface),
 	__ATTR(channel, S_IRUGO, ieee80211_local_show_channel, NULL),
 	__ATTR(frequency, S_IRUGO, ieee80211_local_show_frequency, NULL),
 	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),
@@ -231,7 +195,6 @@ static struct class_device_attribute iee
 	__ATTR(tx_power_reduction, S_IRUGO, ieee80211_local_show_tx_power_reduction, NULL),
 	__ATTR(modes, S_IRUGO, ieee80211_local_show_modes, NULL),
 	__ATTR(rate_ctrl_alg, S_IRUGO | S_IWUGO, ieee80211_local_show_rate_ctrl_alg, store_rate_ctrl_alg),
-	{}
 };
 
 /* attributes in /sys/class/ieee80211/phyX/statistics/ */
@@ -624,72 +587,52 @@ static struct attribute_group ieee80211_
 	.attrs = ieee80211_monitor_attrs,
 };
 
-/* /sys/class/ieee80211/phyX functions */
-
-static void ieee80211_class_dev_release(struct class_device *dev)
+int ieee80211_dev_sysfs_add(struct ieee80211_local *local)
 {
-	ieee80211_release_hw(to_ieee80211_local(dev));
-}
+	const struct class_device_attribute *attr;
+	int i, err;
 
-#ifdef CONFIG_HOTPLUG
-static int ieee80211_uevent(struct class_device *cd, char **envp,
-			    int num_envp, char *buf, int size)
-{
-	struct ieee80211_local *local = to_ieee80211_local(cd);
+	for (i = 0; i < ARRAY_SIZE(ieee80211_class_dev_attrs); i++) {
+		attr = &ieee80211_class_dev_attrs[i];
+		err = sysfs_create_file(&local->hw.wiphy->class_dev.kobj,
+					&attr->attr);
+		if (err)
+			goto unwind;
+	}
 
-	if (num_envp < 2)
-		return -ENOMEM;
-	envp[0] = buf;
-	if (snprintf(buf, size, "IEEE80211_DEV=phy%d",
-		     local->hw.index) + 1 >= size)
-		return -ENOMEM;
-	envp[1] = NULL;
-	return 0;
-}
-#endif
+	err = sysfs_create_group(&local->hw.wiphy->class_dev.kobj,
+				 &ieee80211_stats_group);
 
-static struct class ieee80211_class = {
-	.name = "ieee80211",
-	.class_dev_attrs = ieee80211_class_dev_attrs,
-	.release = ieee80211_class_dev_release,
-#ifdef CONFIG_HOTPLUG
-	.uevent = ieee80211_uevent,
-#endif
-};
+	if (err == 0)
+		return err;
 
-void ieee80211_dev_sysfs_init(struct ieee80211_local *local)
-{
-	local->class_dev.class = &ieee80211_class;
-	local->class_dev.class_data = local;
-	class_device_initialize(&local->class_dev);
+ unwind:
+ 	/* one after the failed/last one */
+ 	i--;
+	while (i >= 0) {
+		attr = &ieee80211_class_dev_attrs[i];
+		sysfs_remove_file(&local->hw.wiphy->class_dev.kobj,
+				  &attr->attr);
+		i--;
+	}
+	return err;
 }
 
-void ieee80211_dev_sysfs_put(struct ieee80211_local *local)
+void ieee80211_dev_sysfs_del(struct ieee80211_local *local)
 {
-	class_device_put(&local->class_dev);
-}
+	const struct class_device_attribute *attr;
+	int i;
 
-int ieee80211_dev_sysfs_add(struct ieee80211_local *local)
-{
-	int res;
+	sysfs_remove_group(&local->hw.wiphy->class_dev.kobj,
+			   &ieee80211_stats_group);
 
-	snprintf(local->class_dev.class_id, BUS_ID_SIZE,
-		 "phy%d", local->hw.index);
-	res = class_device_add(&local->class_dev);
-	if (res)
-		return res;
-	res = sysfs_create_group(&local->class_dev.kobj,
-				 &ieee80211_stats_group);
-	if (res)
-		class_device_del(&local->class_dev);
-	return res;
+	for (i = 0; i < ARRAY_SIZE(ieee80211_class_dev_attrs); i++) {
+		attr = &ieee80211_class_dev_attrs[i];
+		sysfs_remove_file(&local->hw.wiphy->class_dev.kobj,
+				  &attr->attr);
+	}
 }
 
-void ieee80211_dev_sysfs_del(struct ieee80211_local *local)
-{
-	sysfs_remove_group(&local->class_dev.kobj, &ieee80211_stats_group);
-	class_device_del(&local->class_dev);
-}
 
 /* /sys/class/net/X functions */
 
@@ -748,11 +691,12 @@ int ieee80211_sysfs_change_if_type(struc
 
 int ieee80211_sysfs_add_netdevice(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int res;
 
-	res = sysfs_create_link(&dev->class_dev.kobj, &local->class_dev.kobj,
-				"hw");
+	res = sysfs_create_link(&dev->class_dev.kobj,
+				&local->hw.wiphy->class_dev.kobj,
+				"wiphy");
 	if (res)
 		goto err_out;
 	res = ieee80211_add_if_group(&dev->class_dev.kobj, dev);
@@ -773,15 +717,3 @@ void ieee80211_sysfs_remove_netdevice(st
 	ieee80211_remove_if_group(&dev->class_dev.kobj, dev);
 	sysfs_remove_link(&dev->class_dev.kobj, "hw");
 }
-
-/* general module functions */
-
-int ieee80211_sysfs_init(void)
-{
-	return class_register(&ieee80211_class);
-}
-
-void ieee80211_sysfs_deinit(void)
-{
-	class_unregister(&ieee80211_class);
-}
--- wireless-dev.orig/net/d80211/Kconfig	2006-11-22 20:10:20.339711991 +0100
+++ wireless-dev/net/d80211/Kconfig	2006-11-22 20:11:11.679711991 +0100
@@ -3,6 +3,7 @@ config D80211
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select CFG80211
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.c	2006-11-22 20:11:11.689711991 +0100
@@ -0,0 +1,32 @@
+/*
+ * d80211 configuration hooks for cfg80211
+ *
+ * Copyright 2006	Johannes Berg <johannes@sipsolutions.net>
+ *
+ * This file is GPLv2 as found in COPYING.
+ */
+
+#include <net/cfg80211.h>
+#include "ieee80211_i.h"
+#include "ieee80211_cfg.h"
+
+static int ieee80211_list_interfaces(struct wiphy *wiphy, void *data,
+				     int (*one)(void *data, int ifindex))
+{
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_sub_if_data *subif;
+	int err;
+
+	spin_lock_bh(&local->sub_if_lock);
+	list_for_each_entry(subif, &local->sub_if_list, list) {
+		err = one(data, subif->dev->ifindex);
+		if (err)
+			break;
+	}
+	spin_unlock_bh(&local->sub_if_lock);
+	return err;
+}
+
+struct cfg80211_ops d80211_config_ops = {
+	.list_interfaces = ieee80211_list_interfaces,
+};
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_cfg.h	2006-11-22 20:11:11.689711991 +0100
@@ -0,0 +1,9 @@
+/*
+ * d80211 configuration hooks for cfg80211
+ */
+#ifndef __IEEE80211_CFG_H
+#define __IEEE80211_CFG_H
+
+extern struct cfg80211_ops d80211_config_ops;
+
+#endif /* __IEEE80211_CFG_H */
--- wireless-dev.orig/net/d80211/ieee80211_sysfs_sta.c	2006-11-22 20:10:20.439711991 +0100
+++ wireless-dev/net/d80211/ieee80211_sysfs_sta.c	2006-11-22 20:11:11.689711991 +0100
@@ -39,7 +39,7 @@ static ssize_t show_sta_##name(const str
 #define STA_SHOW_RATE(name, field)					\
 static ssize_t show_sta_##name(const struct sta_info *sta, char *buf)	\
 {									\
-	struct ieee80211_local *local = sta->dev->ieee80211_ptr;	\
+	struct ieee80211_local *local = wiphy_priv(sta->dev->ieee80211_ptr);\
 	return sprintf(buf, "%d\n",					\
 		       (sta->field >= 0 &&				\
 			sta->field < local->num_curr_rates) ?		\
@@ -370,7 +370,7 @@ int ieee80211_sta_kset_sysfs_register(st
 	res = kobject_set_name(&local->sta_kset.kobj, "sta");
 	if (res)
 		return res;
-	local->sta_kset.kobj.parent = &local->class_dev.kobj;
+	local->sta_kset.kobj.parent = &local->hw.wiphy->class_dev.kobj;
 	local->sta_kset.ktype = &sta_ktype;
 	return kset_register(&local->sta_kset);
 }
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_sysfs.h	2006-11-22 20:11:11.689711991 +0100
@@ -0,0 +1,12 @@
+/* routines exported for sysfs handling */
+
+#ifndef __IEEE80211_SYSFS_H
+#define __IEEE80211_SYSFS_H
+
+int ieee80211_sysfs_add_netdevice(struct net_device *dev);
+void ieee80211_sysfs_remove_netdevice(struct net_device *dev);
+int ieee80211_sysfs_change_if_type(struct net_device *dev);
+int ieee80211_dev_sysfs_add(struct ieee80211_local *local);
+void ieee80211_dev_sysfs_del(struct ieee80211_local *local);
+
+#endif /* __IEEE80211_SYSFS_H */
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-11-22 20:10:20.469711991 +0100
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-11-22 20:11:11.699711991 +0100
@@ -117,7 +117,7 @@ static int ieee80211_ioctl_get_hw_featur
 					   struct prism2_hostapd_param *param,
 					   int param_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	u8 *pos = param->u.hw_features.data;
 	int left = param_len - (pos - (u8 *) param);
 	int mode, i;
@@ -168,7 +168,7 @@ static int ieee80211_ioctl_get_hw_featur
 static int ieee80211_ioctl_scan(struct net_device *dev,
                                 struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (!local->ops->passive_scan)
 		return -EOPNOTSUPP;
@@ -208,7 +208,7 @@ static int ieee80211_ioctl_scan(struct n
 static int ieee80211_ioctl_flush(struct net_device *dev,
 				 struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	sta_info_flush(local, NULL);
 	return 0;
 }
@@ -263,7 +263,7 @@ static void ieee80211_send_layer2_update
 static int ieee80211_ioctl_add_sta(struct net_device *dev,
 				   struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 	u32 rates;
 	int i, j;
@@ -353,7 +353,7 @@ static int ieee80211_ioctl_add_sta(struc
 static int ieee80211_ioctl_remove_sta(struct net_device *dev,
 				      struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 
 	sta = sta_info_get(local, param->sta_addr);
@@ -369,7 +369,7 @@ static int ieee80211_ioctl_remove_sta(st
 static int ieee80211_ioctl_get_dot11counterstable(struct net_device *dev,
 					struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
         struct ieee80211_low_level_stats stats;
 
 	memset(&stats, 0, sizeof(stats));
@@ -401,7 +401,7 @@ static int ieee80211_ioctl_get_dot11coun
 static int ieee80211_ioctl_get_info_sta(struct net_device *dev,
 					struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 
 	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
@@ -452,7 +452,7 @@ static int ieee80211_ioctl_get_info_sta(
 static int ieee80211_ioctl_set_flags_sta(struct net_device *dev,
 					 struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 
 	sta = sta_info_get(local, param->sta_addr);
@@ -483,7 +483,7 @@ int ieee80211_set_hw_encryption(struct n
 				struct ieee80211_key *key)
 {
 	struct ieee80211_key_conf *keyconf = NULL;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int rc = 0;
 
 	/* default to sw encryption; this will be cleared by low-level
@@ -516,7 +516,7 @@ static int ieee80211_set_encryption(stru
 				    int idx, int alg, int set_tx_key, int *err,
 				    const u8 *_key, size_t key_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int ret = 0;
 	struct sta_info *sta;
 	struct ieee80211_key *key, *old_key;
@@ -789,7 +789,7 @@ static int ieee80211_ioctl_get_encryptio
 					  struct prism2_hostapd_param *param,
 					  int param_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int ret = 0;
 	struct sta_info *sta;
 	struct ieee80211_key **key;
@@ -907,7 +907,7 @@ static int ieee80211_ioctl_get_encryptio
 static int ieee80211_ioctl_wpa_trigger(struct net_device *dev,
 				       struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 
 	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
@@ -936,7 +936,7 @@ static int ieee80211_ioctl_set_rate_sets
 					 struct prism2_hostapd_param *param,
 					 int param_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	u16 *pos = (u16 *) param->u.set_rate_sets.data;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int i, mode, num_supp, num_basic, *supp, *basic, *prev;
@@ -1023,7 +1023,7 @@ static int ieee80211_ioctl_add_if(struct
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_WDS);
 		res = ieee80211_if_update_wds(new_dev, wds->remote_addr);
 		if (res)
-			__ieee80211_if_del(dev->ieee80211_ptr,
+			__ieee80211_if_del(wiphy_priv(dev->ieee80211_ptr),
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 		return res;
 	case HOSTAP_IF_VLAN:
@@ -1037,7 +1037,7 @@ static int ieee80211_ioctl_add_if(struct
 #if 0
 		res = ieee80211_if_update_vlan(new_dev, vlan->id);
 		if (res)
-			__ieee80211_if_del(dev->ieee80211_ptr,
+			__ieee80211_if_del(wiphy_priv(dev->ieee80211_ptr),
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 #endif
 		return res;
@@ -1104,7 +1104,7 @@ static int ieee80211_ioctl_update_if(str
 	if (param->u.if_info.type == HOSTAP_IF_WDS) {
 		struct hostapd_if_wds *wds =
 			(struct hostapd_if_wds *) param->u.if_info.data;
-		struct ieee80211_local *local = dev->ieee80211_ptr;
+		struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 		struct net_device *wds_dev = NULL;
 		struct ieee80211_sub_if_data *sdata;
 
@@ -1141,7 +1141,7 @@ static int ieee80211_ioctl_scan_req(stru
 				    struct prism2_hostapd_param *param,
 				    int param_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	u8 *pos = param->u.scan_req.ssid;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int len = param->u.scan_req.ssid_len;
@@ -1176,7 +1176,7 @@ static int ieee80211_ioctl_sta_get_state
 static int ieee80211_ioctl_mlme(struct net_device *dev,
 				struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 
 	if (local->user_space_mlme)
@@ -1199,7 +1199,7 @@ static int ieee80211_ioctl_mlme(struct n
 static int ieee80211_ioctl_get_load_stats(struct net_device *dev,
 					  struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	param->u.get_load_stats.channel_use = local->channel_use;
 /*	if (param->u.get_load_stats.flags & LOAD_STATS_CLEAR)
@@ -1212,7 +1212,7 @@ static int ieee80211_ioctl_get_load_stat
 static int ieee80211_ioctl_set_sta_vlan(struct net_device *dev,
                                         struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
         struct sta_info *sta;
 
         sta = sta_info_get(local, param->sta_addr);
@@ -1244,7 +1244,7 @@ static int ieee80211_ioctl_set_sta_vlan(
 static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 {
 	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (local->user_space_mlme)
 		return -EOPNOTSUPP;
@@ -1286,7 +1286,7 @@ ieee80211_ioctl_set_generic_info_elem(st
 static int ieee80211_ioctl_set_regulatory_domain(struct net_device *dev,
 					    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_conf *conf = &local->hw.conf;
         conf->regulatory_domain = param->u.set_regulatory_domain.rd;
         return 0;
@@ -1296,18 +1296,18 @@ static int ieee80211_ioctl_set_regulator
 static int ieee80211_ioctl_set_radio_enabled(struct net_device *dev,
 					     int val)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_conf *conf = &local->hw.conf;
 
 	conf->radio_enabled = val;
-	return ieee80211_hw_config(dev->ieee80211_ptr);
+	return ieee80211_hw_config(wiphy_priv(dev->ieee80211_ptr));
 }
 
 static int
 ieee80211_ioctl_set_tx_queue_params(struct net_device *dev,
 				    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_queue_params qparam;
 
 	if (!local->ops->conf_tx) {
@@ -1331,7 +1331,7 @@ ieee80211_ioctl_set_tx_queue_params(stru
 static int ieee80211_ioctl_get_tx_stats(struct net_device *dev,
 					struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_queue_stats stats;
 	int ret, i;
 
@@ -1356,7 +1356,7 @@ static int ieee80211_ioctl_get_tx_stats(
 static int ieee80211_ioctl_set_channel_flag(struct net_device *dev,
 					    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_hw_modes *mode = NULL;
 	struct ieee80211_channel *chan = NULL;
 	int i;
@@ -1392,7 +1392,7 @@ static int ieee80211_ioctl_set_channel_f
 static int ieee80211_ioctl_set_quiet_params(struct net_device *dev,
 					    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_conf *conf = &local->hw.conf;
 
 	conf->quiet_duration = param->u.quiet.duration;
@@ -1405,7 +1405,7 @@ static int ieee80211_ioctl_set_quiet_par
 static int ieee80211_ioctl_set_radar_params(struct net_device *dev,
 					    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_conf *conf = &local->hw.conf;
 
 	conf->radar_firpwr_threshold = param->u.radar.radar_firpwr_threshold;
@@ -1551,7 +1551,7 @@ static int ieee80211_ioctl_giwname(struc
 				   struct iw_request_info *info,
 				   char *name, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	switch (local->hw.conf.phymode) {
 	case MODE_IEEE80211A:
@@ -1705,7 +1705,7 @@ static void ieee80211_unmask_channel(str
 
 static int ieee80211_unmask_channels(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int m, c;
 
 	for (m = 0; m < local->hw.num_modes; m++) {
@@ -1806,7 +1806,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			    struct iw_request_info *info,
 			    struct iw_freq *freq, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int m, c, nfreq, set = 0;
 
 	/* freq->e == 0: freq->m = channel; otherwise freq = m * 10^e */
@@ -1859,7 +1859,7 @@ static int ieee80211_ioctl_giwfreq(struc
 				   struct iw_request_info *info,
 				   struct iw_freq *freq, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	/* TODO: in station mode (Managed/Ad-hoc) might need to poll low-level
 	 * driver for the current channel with firmware-based management */
@@ -1875,7 +1875,7 @@ static int ieee80211_ioctl_siwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
         size_t len = data->length;
 
@@ -1943,7 +1943,7 @@ static int ieee80211_ioctl_siwap(struct 
 				 struct iw_request_info *info,
 				 struct sockaddr *ap_addr, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1992,7 +1992,7 @@ static int ieee80211_ioctl_siwscan(struc
 				   struct iw_request_info *info,
 				   struct iw_point *data, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	u8 *ssid = NULL;
 	size_t ssid_len = 0;
@@ -2020,7 +2020,7 @@ static int ieee80211_ioctl_giwscan(struc
 				   struct iw_point *data, char *extra)
 {
 	int res;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	if (local->sta_scanning)
 		return -EAGAIN;
 	res = ieee80211_sta_scan_results(dev, extra, data->length);
@@ -2037,7 +2037,7 @@ static int ieee80211_ioctl_siwrts(struct
 				  struct iw_request_info *info,
 				  struct iw_param *rts, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (rts->disabled)
 		local->rts_threshold = IEEE80211_MAX_RTS_THRESHOLD;
@@ -2060,7 +2060,7 @@ static int ieee80211_ioctl_giwrts(struct
 				  struct iw_request_info *info,
 				  struct iw_param *rts, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	rts->value = local->rts_threshold;
 	rts->disabled = (rts->value >= IEEE80211_MAX_RTS_THRESHOLD);
@@ -2074,7 +2074,7 @@ static int ieee80211_ioctl_siwfrag(struc
 				   struct iw_request_info *info,
 				   struct iw_param *frag, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (frag->disabled)
 		local->fragmentation_threshold = IEEE80211_MAX_FRAG_THRESHOLD;
@@ -2101,7 +2101,7 @@ static int ieee80211_ioctl_giwfrag(struc
 				   struct iw_request_info *info,
 				   struct iw_param *frag, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	frag->value = local->fragmentation_threshold;
 	frag->disabled = (frag->value >= IEEE80211_MAX_RTS_THRESHOLD);
@@ -2115,7 +2115,7 @@ static int ieee80211_ioctl_siwretry(stru
 				    struct iw_request_info *info,
 				    struct iw_param *retry, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (retry->disabled ||
 	    (retry->flags & IW_RETRY_TYPE) != IW_RETRY_LIMIT)
@@ -2145,7 +2145,7 @@ static int ieee80211_ioctl_giwretry(stru
 				    struct iw_request_info *info,
 				    struct iw_param *retry, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	retry->disabled = 0;
 	if ((retry->flags & IW_RETRY_TYPE) != IW_RETRY_LIMIT)
@@ -2180,7 +2180,7 @@ static void ieee80211_ioctl_unmask_chann
 
 static int ieee80211_ioctl_test_mode(struct net_device *dev, int mode)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int ret = -EOPNOTSUPP;
 
 	if (mode == IEEE80211_TEST_UNMASK_CHANNELS) {
@@ -2197,7 +2197,7 @@ static int ieee80211_ioctl_test_mode(str
 
 static int ieee80211_ioctl_clear_keys(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_key_conf key;
 	int i;
 	u8 addr[ETH_ALEN];
@@ -2254,7 +2254,7 @@ ieee80211_ioctl_force_unicast_rate(struc
 				   struct ieee80211_sub_if_data *sdata,
 				   int rate)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int i;
 
 	if (sdata->type != IEEE80211_IF_TYPE_AP)
@@ -2280,7 +2280,7 @@ ieee80211_ioctl_max_ratectrl_rate(struct
 				  struct ieee80211_sub_if_data *sdata,
 				  int rate)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int i;
 
 	if (sdata->type != IEEE80211_IF_TYPE_AP)
@@ -2368,7 +2368,7 @@ static int ieee80211_ioctl_prism2_param(
 					struct iw_request_info *info,
 					void *wrqu, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 	int *i = (int *) extra;
 	int param = *i;
@@ -2619,7 +2619,7 @@ static int ieee80211_ioctl_get_prism2_pa
 					    struct iw_request_info *info,
 					    void *wrqu, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 	int *param = (int *) extra;
 	int ret = 0;
@@ -2799,7 +2799,7 @@ static int ieee80211_ioctl_test_param(st
 				      struct iw_request_info *info,
 				      void *wrqu, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int *i = (int *) extra;
 	int param = *i;
 	int value = *(i + 1);
@@ -2942,7 +2942,7 @@ static int ieee80211_ioctl_siwauth(struc
 				   struct iw_request_info *info,
 				   struct iw_param *data, char *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	int ret = 0;
 
@@ -2998,7 +2998,7 @@ static int ieee80211_ioctl_siwauth(struc
 /* Get wireless statistics.  Called by /proc/net/wireless and by SIOCGIWSTATS */
 static struct iw_statistics *ieee80211_get_wireless_stats(struct net_device *net_dev)
 {
-	struct ieee80211_local *local = net_dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(net_dev->ieee80211_ptr);
 	struct iw_statistics * wstats = &local->wstats;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(net_dev);
 	struct sta_info *sta;
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-22 20:10:20.509711991 +0100
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-22 20:11:11.709711991 +0100
@@ -230,7 +230,7 @@ static void ieee80211_sta_wmm_params(str
 				     struct ieee80211_if_sta *ifsta,
 				     u8 *wmm_param, size_t wmm_param_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_queue_params params;
 	size_t left;
 	int count;
@@ -464,7 +464,7 @@ static void ieee80211_authenticate(struc
 static void ieee80211_send_assoc(struct net_device *dev,
 				 struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 	u8 *pos, *ies;
@@ -684,7 +684,7 @@ static void ieee80211_associate(struct n
 static void ieee80211_associated(struct net_device *dev,
 				 struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 	int disassoc;
 
@@ -747,7 +747,7 @@ static void ieee80211_associated(struct 
 static void ieee80211_send_probe_req(struct net_device *dev, u8 *dst,
 				     u8 *ssid, size_t ssid_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 	u8 *pos, *supp_rates, *esupp_rates = NULL;
@@ -1077,7 +1077,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 					 struct ieee80211_rx_status *rx_status,
 					 int reassoc)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 	u32 rates;
 	u16 capab_info, status_code, aid;
@@ -1208,7 +1208,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 static void __ieee80211_rx_bss_hash_add(struct net_device *dev,
 					struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	bss->hnext = local->sta_bss_hash[STA_HASH(bss->bssid)];
 	local->sta_bss_hash[STA_HASH(bss->bssid)] = bss;
 }
@@ -1218,7 +1218,7 @@ static void __ieee80211_rx_bss_hash_add(
 static void __ieee80211_rx_bss_hash_del(struct net_device *dev,
 					struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *b, *prev = NULL;
 	b = local->sta_bss_hash[STA_HASH(bss->bssid)];
 	while (b) {
@@ -1239,7 +1239,7 @@ static void __ieee80211_rx_bss_hash_del(
 static struct ieee80211_sta_bss *
 ieee80211_rx_bss_add(struct net_device *dev, u8 *bssid)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
 
 	bss = kmalloc(sizeof(*bss), GFP_ATOMIC);
@@ -1262,7 +1262,7 @@ ieee80211_rx_bss_add(struct net_device *
 static struct ieee80211_sta_bss *
 ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
 
 	spin_lock_bh(&local->sta_bss_lock);
@@ -1291,7 +1291,7 @@ static void ieee80211_rx_bss_free(struct
 static void ieee80211_rx_bss_put(struct net_device *dev,
 				 struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	if (!atomic_dec_and_test(&bss->users))
 		return;
 
@@ -1305,7 +1305,7 @@ static void ieee80211_rx_bss_put(struct 
 
 void ieee80211_rx_bss_list_init(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	spin_lock_init(&local->sta_bss_lock);
 	INIT_LIST_HEAD(&local->sta_bss_list);
 }
@@ -1313,7 +1313,7 @@ void ieee80211_rx_bss_list_init(struct n
 
 void ieee80211_rx_bss_list_deinit(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss, *tmp;
 
 	list_for_each_entry_safe(bss, tmp, &local->sta_bss_list, list)
@@ -1327,7 +1327,7 @@ static void ieee80211_rx_bss_info(struct
 				  struct ieee80211_rx_status *rx_status,
 				  int beacon)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee802_11_elems elems;
 	size_t baselen;
 	int channel, invalid = 0, clen;
@@ -1573,7 +1573,7 @@ static void ieee80211_rx_mgmt_beacon(str
 				     size_t len,
 				     struct ieee80211_rx_status *rx_status)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
 	int use_protection;
@@ -1631,7 +1631,7 @@ static void ieee80211_rx_mgmt_probe_req(
 					size_t len,
 					struct ieee80211_rx_status *rx_status)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	int tx_last_beacon;
 	struct sk_buff *skb;
@@ -1784,7 +1784,7 @@ void ieee80211_sta_rx_scan(struct net_de
 
 static int ieee80211_sta_active_ibss(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int active = 0;
 	struct sta_info *sta;
 
@@ -1805,7 +1805,7 @@ static int ieee80211_sta_active_ibss(str
 
 static void ieee80211_sta_expire(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta, *tmp;
 
 	spin_lock_bh(&local->sta_lock);
@@ -1890,7 +1890,7 @@ void ieee80211_sta_work(void *ptr)
 static void ieee80211_sta_new_auth(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (sdata->type != IEEE80211_IF_TYPE_STA)
@@ -1951,7 +1951,7 @@ static int ieee80211_sta_join_ibss(struc
 				   struct ieee80211_if_sta *ifsta,
 				   struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct iw_freq rq;
 	int res, rates, i, j;
 	struct sk_buff *skb;
@@ -2112,7 +2112,7 @@ static int ieee80211_sta_join_ibss(struc
 static int ieee80211_sta_create_ibss(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
 	struct ieee80211_sub_if_data *sdata;
 	u8 bssid[ETH_ALEN], *pos;
@@ -2169,7 +2169,7 @@ static int ieee80211_sta_create_ibss(str
 static int ieee80211_sta_find_ibss(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
 	int found = 0;
 	u8 bssid[ETH_ALEN];
@@ -2259,7 +2259,7 @@ int ieee80211_sta_set_ssid(struct net_de
 {
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
@@ -2356,7 +2356,7 @@ int ieee80211_sta_set_bssid(struct net_d
 
 static void ieee80211_sta_save_oper_chan(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	local->scan_oper_channel = local->hw.conf.channel;
 	local->scan_oper_channel_val = local->hw.conf.channel_val;
 	local->scan_oper_power_level = local->hw.conf.power_level;
@@ -2368,7 +2368,7 @@ static void ieee80211_sta_save_oper_chan
 
 static int ieee80211_sta_restore_oper_chan(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	local->hw.conf.channel = local->scan_oper_channel;
 	local->hw.conf.channel_val = local->scan_oper_channel_val;
 	local->hw.conf.power_level = local->scan_oper_power_level;
@@ -2429,7 +2429,7 @@ EXPORT_SYMBOL(ieee80211_scan_completed);
 static void ieee80211_sta_scan_work(void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
@@ -2519,7 +2519,7 @@ static void ieee80211_sta_scan_work(void
 
 int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 
 	if (ssid_len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
@@ -2587,7 +2587,7 @@ ieee80211_sta_scan_result(struct net_dev
 			  struct ieee80211_sta_bss *bss,
 			  char *current_ev, char *end_buf)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct iw_event iwe;
 
 	if (time_after(jiffies,
@@ -2755,7 +2755,7 @@ ieee80211_sta_scan_result(struct net_dev
 
 int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	char *current_ev = buf;
 	char *end_buf = buf + len;
 	struct ieee80211_sta_bss *bss;
@@ -2802,7 +2802,7 @@ struct sta_info * ieee80211_ibss_add_sta
 					 struct sk_buff *skb, u8 *bssid,
 					 u8 *addr)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata = NULL;
 	struct net_device *sta_dev = NULL;
--- wireless-dev.orig/net/d80211/rc80211_simple.c	2006-11-22 20:10:20.549711991 +0100
+++ wireless-dev/net/d80211/rc80211_simple.c	2006-11-22 20:11:11.709711991 +0100
@@ -124,7 +124,7 @@ static void rate_control_simple_tx_statu
 					  struct sk_buff *skb,
 					  struct ieee80211_tx_status *status)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct sta_info *sta;
 	struct sta_rate_control *srctrl;
@@ -216,7 +216,7 @@ rate_control_simple_get_rate(void *priv,
 			     struct sk_buff *skb,
 			     struct rate_control_extra *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct sta_info *sta;
--- wireless-dev.orig/net/d80211/wme.c	2006-11-22 20:10:20.609711991 +0100
+++ wireless-dev/net/d80211/wme.c	2006-11-22 20:11:11.719711991 +0100
@@ -175,7 +175,7 @@ static inline int wme_downgrade_ac(struc
  * negative return value indicates to drop the frame */
 static inline int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 {
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_tx_packet_data *pkt_data =
 		(struct ieee80211_tx_packet_data *) skb->cb;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
@@ -226,7 +226,7 @@ static inline int classify80211(struct s
 
 static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 {
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct ieee80211_tx_packet_data *pkt_data =
 		(struct ieee80211_tx_packet_data *) skb->cb;
@@ -313,7 +313,7 @@ static struct sk_buff *wme_qdiscop_deque
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct net_device *dev = qd->dev;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	struct sk_buff *skb;
 	struct Qdisc *qdisc;
@@ -349,7 +349,7 @@ static struct sk_buff *wme_qdiscop_deque
 static void wme_qdiscop_reset(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	int queue;
 
@@ -366,7 +366,7 @@ static void wme_qdiscop_reset(struct Qdi
 static void wme_qdiscop_destroy(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	struct tcf_proto *tp;
 	int queue;
@@ -407,7 +407,7 @@ static int wme_qdiscop_init(struct Qdisc
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct net_device *dev = qd->dev;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(dev->ieee80211_ptr);
 	int queues = local->hw.queues;
 	int err = 0, i;
 
@@ -462,7 +462,7 @@ static int wme_classop_graft(struct Qdis
 			     struct Qdisc *new, struct Qdisc **old)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	unsigned long queue = arg - 1;
 
@@ -486,7 +486,7 @@ static struct Qdisc *
 wme_classop_leaf(struct Qdisc *qd, unsigned long arg)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	unsigned long queue = arg - 1;
 
@@ -499,7 +499,7 @@ wme_classop_leaf(struct Qdisc *qd, unsig
 
 static unsigned long wme_classop_get(struct Qdisc *qd, u32 classid)
 {
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	unsigned long queue = TC_H_MIN(classid);
 
@@ -527,7 +527,7 @@ static int wme_classop_change(struct Qdi
 			      struct rtattr **tca, unsigned long *arg)
 {
 	unsigned long cl = *arg;
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
 
@@ -545,7 +545,7 @@ static int wme_classop_change(struct Qdi
  * when we add WMM-SA support - TSPECs may be deleted here */
 static int wme_classop_delete(struct Qdisc *qd, unsigned long cl)
 {
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
 
@@ -559,7 +559,7 @@ static int wme_classop_dump_class(struct
 				  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
 
@@ -574,7 +574,7 @@ static int wme_classop_dump_class(struct
 
 static void wme_classop_walk(struct Qdisc *qd, struct qdisc_walker *arg)
 {
-	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
+	struct ieee80211_local *local = wiphy_priv(qd->dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	int queue;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */


