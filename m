From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 06/18] d80211:  rework rate control registration
Date: Mon, 21 Aug 2006 09:41:13 +0200
Message-ID: <20060821075159.839042963@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53696 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030312AbWHUICI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:08 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-rate-control-rework.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Contrary to what Jiri said, proper rate control module refcounting
is much easier than allowing rate control changes on-the-fly...
This patch implements only the former along with cleanups.
Note that the diff between rate_control.c and rate_control_simple.c
is small (modulo fixing indenting etc.), but I wanted to rename the
file to more accurately reflect what it is.
---
This patch reworks rate control module registration, gets rid of the
linked list implementation that was there, and as an added bonus adds
rate control module refcounting.
It moves rate_control.c to rate_control_simple.c and Lindents
(+manual cleanups) it in the process.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/rate_control.c	2006-08-20 14:56:18.438192788 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,396 +0,0 @@
-/*
- * Copyright 2002-2005, Instant802 Networks, Inc.
- * Copyright 2005, Devicescape Software, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/netdevice.h>
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/skbuff.h>
-#include <linux/compiler.h>
-
-#include <net/d80211.h>
-#include "ieee80211_i.h"
-#include "rate_control.h"
-
-
-/* This is a minimal implementation of TX rate controlling that can be used
- * as the default when no improved mechanisms are available. */
-
-
-#define RATE_CONTROL_EMERG_DEC 2
-#define RATE_CONTROL_INTERVAL (HZ / 20)
-#define RATE_CONTROL_MIN_TX 10
-
-MODULE_ALIAS("ieee80211_rate_control");
-
-static void rate_control_rate_inc(struct ieee80211_local *local,
-				  struct sta_info *sta)
-{
-        struct ieee80211_sub_if_data *sdata;
-	int i = sta->txrate;
-	int maxrate;
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
-	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
-		/* forced unicast rate - do not change STA rate */
-		return;
-	}
-
-	maxrate = sdata->bss ? sdata->bss->max_ratectrl_rateidx : -1;
-
-	if (i > local->num_curr_rates)
-		i = local->num_curr_rates - 2;
-
-	while (i + 1 < local->num_curr_rates) {
-		i++;
-		if (sta->supp_rates & BIT(i) &&
-		    local->curr_rates[i].flags & IEEE80211_RATE_SUPPORTED &&
-		    (maxrate < 0 || i <= maxrate)) {
-			sta->txrate = i;
-			break;
-		}
-	}
-}
-
-
-static void rate_control_rate_dec(struct ieee80211_local *local,
-				  struct sta_info *sta)
-{
-        struct ieee80211_sub_if_data *sdata;
-	int i = sta->txrate;
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
-	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
-		/* forced unicast rate - do not change STA rate */
-		return;
-	}
-
-	if (i > local->num_curr_rates)
-		i = local->num_curr_rates;
-
-	while (i > 0) {
-		i--;
-		if (sta->supp_rates & BIT(i) &&
-		    local->curr_rates[i].flags & IEEE80211_RATE_SUPPORTED) {
-			sta->txrate = i;
-			break;
-		}
-	}
-}
-
-
-static struct ieee80211_rate *
-rate_control_lowest_rate(struct ieee80211_local *local)
-{
-	int i;
-
-	for (i = 0; i < local->num_curr_rates; i++) {
-		struct ieee80211_rate *rate = &local->curr_rates[i];
-
-		if (rate->flags & IEEE80211_RATE_SUPPORTED
-			)
-			return rate;
-	}
-
-	printk(KERN_DEBUG "rate_control_lowest_rate - no supported rates "
-	       "found\n");
-	return &local->curr_rates[0];
-}
-
-
-struct global_rate_control {
-	int dummy;
-};
-
-struct sta_rate_control {
-        unsigned long last_rate_change;
-        u32 tx_num_failures;
-        u32 tx_num_xmit;
-
-        unsigned long avg_rate_update;
-        u32 tx_avg_rate_sum;
-        u32 tx_avg_rate_num;
-};
-
-
-static void rate_control_simple_tx_status(struct net_device *dev,
-					  struct sk_buff *skb,
-					  struct ieee80211_tx_status *status)
-{
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-	struct sta_info *sta;
-	struct sta_rate_control *srctrl;
-
-        sta = sta_info_get(local, hdr->addr1);
-
-	if (!sta)
-            return;
-
-	srctrl = sta->rate_ctrl_priv;
-	srctrl->tx_num_xmit++;
-	if (status->excessive_retries) {
-		sta->antenna_sel = sta->antenna_sel == 1 ? 2 : 1;
-		if (local->sta_antenna_sel == STA_ANTENNA_SEL_SW_CTRL_DEBUG) {
-			printk(KERN_DEBUG "%s: " MAC_FMT " TX antenna --> %d "
-			       "(@%lu)\n",
-			       dev->name, MAC_ARG(hdr->addr1),
-			       sta->antenna_sel, jiffies);
-		}
-		srctrl->tx_num_failures++;
-		sta->tx_retry_failed++;
-		sta->tx_num_consecutive_failures++;
-		sta->tx_num_mpdu_fail++;
-	} else {
-		sta->last_ack_rssi[0] = sta->last_ack_rssi[1];
-		sta->last_ack_rssi[1] = sta->last_ack_rssi[2];
-		sta->last_ack_rssi[2] = status->ack_signal;
-		sta->tx_num_consecutive_failures = 0;
-		sta->tx_num_mpdu_ok++;
-	}
-	sta->tx_retry_count += status->retry_count;
-	sta->tx_num_mpdu_fail += status->retry_count;
-
-	if (time_after(jiffies,
-		       srctrl->last_rate_change + RATE_CONTROL_INTERVAL) &&
-		srctrl->tx_num_xmit > RATE_CONTROL_MIN_TX) {
-		u32 per_failed;
-		srctrl->last_rate_change = jiffies;
-
-		per_failed = (100 * sta->tx_num_mpdu_fail) /
-			(sta->tx_num_mpdu_fail + sta->tx_num_mpdu_ok);
-		/* TODO: calculate average per_failed to make adjusting
-		 * parameters easier */
-#if 0
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "MPDU fail=%d ok=%d per_failed=%d\n",
-			       sta->tx_num_mpdu_fail, sta->tx_num_mpdu_ok,
-			       per_failed);
-		}
-#endif
-
-		if (per_failed > local->rate_ctrl_num_down) {
-			rate_control_rate_dec(local, sta);
-		} else if (per_failed < local->rate_ctrl_num_up) {
-			rate_control_rate_inc(local, sta);
-		}
-		srctrl->tx_avg_rate_sum += local->curr_rates[sta->txrate].rate;
-		srctrl->tx_avg_rate_num++;
-		srctrl->tx_num_failures = 0;
-		srctrl->tx_num_xmit = 0;
-	} else if (sta->tx_num_consecutive_failures >=
-		   RATE_CONTROL_EMERG_DEC) {
-		rate_control_rate_dec(local, sta);
-	}
-
-	if (srctrl->avg_rate_update + 60 * HZ < jiffies) {
-		srctrl->avg_rate_update = jiffies;
-		if (srctrl->tx_avg_rate_num > 0) {
-#ifdef CONFIG_D80211_VERBOSE_DEBUG
-			printk(KERN_DEBUG "%s: STA " MAC_FMT " Average rate: "
-			       "%d (%d/%d)\n",
-			       dev->name, MAC_ARG(sta->addr),
-			       srctrl->tx_avg_rate_sum /
-			       srctrl->tx_avg_rate_num,
-			       srctrl->tx_avg_rate_sum,
-			       srctrl->tx_avg_rate_num);
-#endif /* CONFIG_D80211_VERBOSE_DEBUG */
-			srctrl->tx_avg_rate_sum = 0;
-			srctrl->tx_avg_rate_num = 0;
-		}
-	}
-
-	sta_info_put(sta);
-}
-
-
-static struct ieee80211_rate *
-rate_control_simple_get_rate(struct net_device *dev, struct sk_buff *skb,
-			     struct rate_control_extra *extra)
-{
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-	struct sta_info *sta;
-	int rateidx, nonerp_idx;
-	u16 fc;
-
-	memset(extra, 0, sizeof(*extra));
-
-	fc = le16_to_cpu(hdr->frame_control);
-	if ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
-	    (hdr->addr1[0] & 0x01)) {
-		/* Send management frames and broadcast/multicast data using
-		 * lowest rate. */
-		/* TODO: this could probably be improved.. */
-		return rate_control_lowest_rate(local);
-	}
-
-	sta = sta_info_get(local, hdr->addr1);
-
-	if (!sta)
-		return rate_control_lowest_rate(local);
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1)
-		sta->txrate = sdata->bss->force_unicast_rateidx;
-
-	rateidx = sta->txrate;
-
-	if (rateidx >= local->num_curr_rates)
-		rateidx = local->num_curr_rates - 1;
-
-	sta->last_txrate = rateidx;
-	nonerp_idx = rateidx;
-	while (nonerp_idx > 0 &&
-	       ((local->curr_rates[nonerp_idx].flags & IEEE80211_RATE_ERP) ||
-		!(local->curr_rates[nonerp_idx].flags &
-		  IEEE80211_RATE_SUPPORTED) ||
-		!(sta->supp_rates & BIT(nonerp_idx))))
-		nonerp_idx--;
-	extra->nonerp_idx = nonerp_idx;
-	extra->nonerp = &local->curr_rates[extra->nonerp_idx];
-
-	sta_info_put(sta);
-
-	return &local->curr_rates[rateidx];
-}
-
-
-static void rate_control_simple_rate_init(struct ieee80211_local *local,
-					  struct sta_info *sta)
-{
-	int i;
-	sta->txrate = 0;
-	/* TODO: what is a good starting rate for STA? About middle? Maybe not
-	 * the lowest or the highest rate.. Could consider using RSSI from
-	 * previous packets? Need to have IEEE 802.1X auth succeed immediately
-	 * after assoc.. */
-	for (i = 0; i < local->num_curr_rates; i++) {
-		if ((sta->supp_rates & BIT(i)) &&
-		    (local->curr_rates[i].flags & IEEE80211_RATE_SUPPORTED))
-			sta->txrate = i;
-	}
-}
-
-
-static void * rate_control_simple_alloc(struct ieee80211_local *local)
-{
-	struct global_rate_control *rctrl;
-
-	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
-
-	return rctrl;
-}
-
-
-static void rate_control_simple_free(void *priv)
-{
-	struct global_rate_control *rctrl = priv;
-	kfree(rctrl);
-}
-
-
-static void rate_control_simple_clear(void *priv)
-{
-}
-
-
-static void * rate_control_simple_alloc_sta(void)
-{
-	struct sta_rate_control *rctrl;
-
-	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
-
-	return rctrl;
-}
-
-
-static void rate_control_simple_free_sta(void *priv)
-{
-	struct sta_rate_control *rctrl = priv;
-	kfree(rctrl);
-}
-
-static ssize_t show_sta_tx_avg_rate_sum(const struct sta_info *sta, char *buf)
-{
-	struct sta_rate_control *srctrl = sta->rate_ctrl_priv;
-
-	return sprintf(buf, "%d\n", srctrl->tx_avg_rate_sum);
-}
-
-static ssize_t show_sta_tx_avg_rate_num(const struct sta_info *sta, char *buf)
-{
-	struct sta_rate_control *srctrl = sta->rate_ctrl_priv;
-
-	return sprintf(buf, "%d\n", srctrl->tx_avg_rate_num);
-}
-
-static struct sta_attribute sta_attr_tx_avg_rate_sum =
-	__ATTR(tx_avg_rate_sum, S_IRUSR, show_sta_tx_avg_rate_sum, NULL);
-static struct sta_attribute sta_attr_tx_avg_rate_num =
-	__ATTR(tx_avg_rate_num, S_IRUSR, show_sta_tx_avg_rate_num, NULL);
-
-static struct attribute *rate_control_simple_sta_attrs[] = {
-	&sta_attr_tx_avg_rate_sum.attr,
-	&sta_attr_tx_avg_rate_num.attr,
-	NULL,
-};
-
-static struct attribute_group rate_control_simple_sta_group = {
-	.name = "rate_control_simple",
-	.attrs = rate_control_simple_sta_attrs,
-};
-
-static int rate_control_simple_add_sta_attrs(void *priv, struct kobject *kobj)
-{
-	return sysfs_create_group(kobj, &rate_control_simple_sta_group);
-}
-
-static void rate_control_simple_remove_sta_attrs(void *priv,
-						 struct kobject *kobj)
-{
-	sysfs_remove_group(kobj, &rate_control_simple_sta_group);
-}
-
-static struct rate_control_ops rate_control_simple = {
-	.name = "simple",
-	.tx_status = rate_control_simple_tx_status,
-	.get_rate = rate_control_simple_get_rate,
-	.rate_init = rate_control_simple_rate_init,
-	.clear = rate_control_simple_clear,
-	.alloc = rate_control_simple_alloc,
-	.free = rate_control_simple_free,
-	.alloc_sta = rate_control_simple_alloc_sta,
-	.free_sta = rate_control_simple_free_sta,
-	.add_sta_attrs = rate_control_simple_add_sta_attrs,
-	.remove_sta_attrs = rate_control_simple_remove_sta_attrs,
-};
-
-
-int __init rate_control_simple_init(void)
-{
-	return ieee80211_rate_control_register(&rate_control_simple);
-}
-
-
-static void __exit rate_control_simple_exit(void)
-{
-	ieee80211_rate_control_unregister(&rate_control_simple);
-}
-
-
-module_init(rate_control_simple_init);
-module_exit(rate_control_simple_exit);
-
-MODULE_DESCRIPTION("Simple rate control algorithm for ieee80211");
-MODULE_LICENSE("GPL");
--- wireless-dev.orig/net/d80211/rate_control.h	2006-08-20 14:56:17.418192788 +0200
+++ wireless-dev/net/d80211/rate_control.h	2006-08-20 14:56:19.758192788 +0200
@@ -10,9 +10,12 @@
 #ifndef RATE_CONTROL
 #define RATE_CONTROL
 
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/types.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "sta_info.h"
@@ -38,6 +41,7 @@ struct rate_control_extra {
 
 struct rate_control_ops {
 	const char *name;
+	struct module *owner;
 	void (*tx_status)(struct net_device *dev, struct sk_buff *skb,
 			  struct ieee80211_tx_status *status);
 	struct ieee80211_rate *
@@ -55,11 +59,14 @@ struct rate_control_ops {
 	void (*remove_attrs)(void *priv, struct kobject *kobj);
 	int (*add_sta_attrs)(void *priv, struct kobject *kobj);
 	void (*remove_sta_attrs)(void *priv, struct kobject *kobj);
+
+	/* private: */
+	struct list_head list;
 };
 
 
-int ieee80211_rate_control_register(struct rate_control_ops *ops);
-void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
+extern int ieee80211_rate_control_register(struct rate_control_ops *ops);
+extern void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
 
 
 static inline void rate_control_tx_status(struct net_device *dev,
@@ -93,9 +100,14 @@ static inline void rate_control_clear(st
 }
 
 
-static inline void * rate_control_alloc(struct ieee80211_local *local)
+static inline void rate_control_alloc(struct ieee80211_local *local,
+				      struct rate_control_ops *ops)
 {
-	return local->rate_ctrl->alloc(local);
+	if (!try_module_get(ops->owner))
+		return;
+	local->rate_ctrl_priv = ops->alloc(local);
+	if (local->rate_ctrl_priv)
+		local->rate_ctrl = ops;
 }
 
 
@@ -103,6 +115,7 @@ static inline void rate_control_free(str
 {
 	if (!local->rate_ctrl || !local->rate_ctrl_priv)
 		return;
+	module_put(local->rate_ctrl->owner);
 	local->rate_ctrl->free(local->rate_ctrl_priv);
 	local->rate_ctrl_priv = NULL;
 }
@@ -151,4 +164,7 @@ static inline void rate_control_remove_s
 		local->rate_ctrl->remove_sta_attrs(priv, kobj);
 }
 
+extern struct list_head ieee80211_rate_ctrl_algs;
+extern struct mutex ieee80211_rate_ctrl_mtx;
+
 #endif /* RATE_CONTROL */
--- wireless-dev.orig/net/d80211/Makefile	2006-08-20 14:56:15.978192788 +0200
+++ wireless-dev/net/d80211/Makefile	2006-08-20 14:56:19.758192788 +0200
@@ -1,4 +1,4 @@
-obj-$(CONFIG_D80211) += 80211.o rate_control.o
+obj-$(CONFIG_D80211) += 80211.o rate_control_simple.o
 
 80211-objs-$(CONFIG_D80211_LEDS) += ieee80211_led.o
 
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:19.058192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:19.768192788 +0200
@@ -19,6 +19,7 @@
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <linux/rtnetlink.h>
+#include <linux/mutex.h>
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
 
@@ -47,12 +48,8 @@ static unsigned char eapol_header[] =
 { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
 
 
-struct rate_control_algs {
-	struct rate_control_algs *next;
-	struct rate_control_ops *ops;
-};
-
-static struct rate_control_algs *ieee80211_rate_ctrl_algs;
+LIST_HEAD(ieee80211_rate_ctrl_algs);
+DEFINE_MUTEX(ieee80211_rate_ctrl_mtx);
 
 static int rate_control_initialize(struct ieee80211_local *local);
 
@@ -4452,8 +4449,8 @@ int ieee80211_register_hw(struct net_dev
 
 	result = rate_control_initialize(local);
 	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to initialize rate control "
-		       "algorithm\n", dev->name);
+		printk(KERN_DEBUG "%s: Failed to initialize default rate "
+		       "control algorithm\n", dev->name);
 		goto fail_rate;
 	}
 	result = rate_control_add_attrs(local, local->rate_ctrl_priv,
@@ -4693,61 +4690,56 @@ void * ieee80211_dev_stats(struct net_de
 
 int ieee80211_rate_control_register(struct rate_control_ops *ops)
 {
-	struct rate_control_algs *alg;
-
-	alg = kzalloc(sizeof(*alg), GFP_KERNEL);
-	if (!alg)
-		return -1;
-
-	alg->next = ieee80211_rate_ctrl_algs;
-	alg->ops = ops;
-	ieee80211_rate_ctrl_algs = alg;
+	struct rate_control_ops *i;
 
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	list_for_each_entry(i, &ieee80211_rate_ctrl_algs, list) {
+		if (strcmp(i->name, ops->name) == 0) {
+			mutex_unlock(&ieee80211_rate_ctrl_mtx);
+			return -EALREADY;
+		}
+	}
+	list_add(&ops->list, &ieee80211_rate_ctrl_algs);
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
 	return 0;
 }
 
 
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
 {
-	struct rate_control_algs *alg, *prev;
-
-	prev = NULL;
-	alg = ieee80211_rate_ctrl_algs;
-	while (alg) {
-		if (alg->ops == ops) {
-			if (prev)
-				prev->next = alg->next;
-			else
-				ieee80211_rate_ctrl_algs = alg->next;
-			kfree(alg);
-			break;
-		}
-		prev = alg;
-		alg = alg->next;
-	}
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	list_del(&ops->list);
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
 }
 
 
 static int rate_control_initialize(struct ieee80211_local *local)
 {
-	struct rate_control_algs *algs;
+	struct rate_control_ops *rctrl;
+
+	BUG_ON(local->rate_ctrl);
 
-	if (!ieee80211_rate_ctrl_algs)
-		request_module("ieee80211_rate_control");
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	if (list_empty(&ieee80211_rate_ctrl_algs)) {
+		mutex_unlock(&ieee80211_rate_ctrl_mtx);
+		request_module("ieee80211_rate_control_simple");
+		mutex_lock(&ieee80211_rate_ctrl_mtx);
+	}
 
-	for (algs = ieee80211_rate_ctrl_algs; algs; algs = algs->next) {
-		local->rate_ctrl = algs->ops;
-		local->rate_ctrl_priv = rate_control_alloc(local);
-		if (local->rate_ctrl_priv) {
+	list_for_each_entry(rctrl, &ieee80211_rate_ctrl_algs, list) {
+		rate_control_alloc(local, rctrl);
+		if (local->rate_ctrl) {
 			printk(KERN_DEBUG "%s: Selected rate control "
 			       "algorithm '%s'\n", local->mdev->name,
 			       local->rate_ctrl->name);
+			mutex_unlock(&ieee80211_rate_ctrl_mtx);
 			return 0;
 		}
 	}
 
 	printk(KERN_WARNING "%s: Failed to select rate control algorithm\n",
 	       local->mdev->name);
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
 	return -1;
 }
 
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-08-20 14:56:08.768192788 +0200
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-08-20 14:56:19.768192788 +0200
@@ -12,6 +12,8 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "rate_control.h"
@@ -188,12 +190,53 @@ __IEEE80211_LOCAL_SHOW(modes);
 static ssize_t ieee80211_local_fmt_rate_ctrl_alg(struct ieee80211_local *local,
 						 char *buf)
 {
-	if (local->rate_ctrl && local->rate_ctrl_priv)
-		return sprintf(buf, "%s\n", local->rate_ctrl->name);
-	return 0;
+	struct rate_control_ops *ops;
+	ssize_t len = 0;
+
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	list_for_each_entry(ops, &ieee80211_rate_ctrl_algs, list)
+		if (local->rate_ctrl == ops)
+			len += sprintf(buf+len, "[%s] ", ops->name);
+		else
+			len += sprintf(buf+len, "%s ", ops->name);
+
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
+
+	len += sprintf(buf+len, "\n");
+	return len;
 }
 __IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
 
+#ifdef _WRITE_RATE_CTRL_NOT_YET
+static ssize_t ieee80211_local_store_rate_ctrl_alg(struct class_device *dev,
+						   const char *buf, size_t len)
+{
+        struct ieee80211_local *local = to_ieee80211_local(dev);
+        struct rate_control_ops *ops;
+        int res = 0;
+
+        if (!capable(CAP_NET_ADMIN))
+                return -EPERM;
+
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	list_for_each_entry(ops, &ieee80211_rate_ctrl_algs, list) {
+		if (strncmp(ops->name, buf, len) == 0) {
+			/* ok, this part is hard.
+			 * we not only need to replace the running
+			 * rate control algorithm and it's priv,
+			 * which would be easy by just locking around
+			 * every use, but we also need to
+			 * replace it in ever sta_info!!
+			 */
+		}
+	}
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
+
+        return res < 0 ? res : len;
+}
+#endif /* _WRITE_RATE_CTRL_NOT_YET */
+
+
 static struct class_device_attribute ieee80211_class_dev_attrs[] = {
 	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
 	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/rate_control_simple.c	2006-08-20 14:56:19.768192788 +0200
@@ -0,0 +1,382 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005, Devicescape Software, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/compiler.h>
+
+#include <net/d80211.h>
+#include "ieee80211_i.h"
+#include "rate_control.h"
+
+/* This is a minimal implementation of TX rate controlling that can be used
+ * as the default when no improved mechanisms are available. */
+
+#define RATE_CONTROL_EMERG_DEC 2
+#define RATE_CONTROL_INTERVAL (HZ / 20)
+#define RATE_CONTROL_MIN_TX 10
+
+MODULE_ALIAS("ieee80211_rate_control_simple");
+
+static void rate_control_rate_inc(struct ieee80211_local *local,
+				  struct sta_info *sta)
+{
+	struct ieee80211_sub_if_data *sdata;
+	int i = sta->txrate;
+	int maxrate;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
+	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
+		/* forced unicast rate - do not change STA rate */
+		return;
+	}
+
+	maxrate = sdata->bss ? sdata->bss->max_ratectrl_rateidx : -1;
+
+	if (i > local->num_curr_rates)
+		i = local->num_curr_rates - 2;
+
+	while (i + 1 < local->num_curr_rates) {
+		i++;
+		if (sta->supp_rates & BIT(i) &&
+		    local->curr_rates[i].flags & IEEE80211_RATE_SUPPORTED &&
+		    (maxrate < 0 || i <= maxrate)) {
+			sta->txrate = i;
+			break;
+		}
+	}
+}
+
+static void rate_control_rate_dec(struct ieee80211_local *local,
+				  struct sta_info *sta)
+{
+	struct ieee80211_sub_if_data *sdata;
+	int i = sta->txrate;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
+	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1) {
+		/* forced unicast rate - do not change STA rate */
+		return;
+	}
+
+	if (i > local->num_curr_rates)
+		i = local->num_curr_rates;
+
+	while (i > 0) {
+		i--;
+		if (sta->supp_rates & BIT(i) &&
+		    local->curr_rates[i].flags & IEEE80211_RATE_SUPPORTED) {
+			sta->txrate = i;
+			break;
+		}
+	}
+}
+
+static struct ieee80211_rate *rate_control_lowest_rate(struct ieee80211_local
+						       *local)
+{
+	int i;
+
+	for (i = 0; i < local->num_curr_rates; i++) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+
+		if (rate->flags & IEEE80211_RATE_SUPPORTED)
+			return rate;
+	}
+
+	printk(KERN_DEBUG "rate_control_lowest_rate - no supported rates "
+	       "found\n");
+	return &local->curr_rates[0];
+}
+
+struct global_rate_control {
+	int dummy;
+};
+
+struct sta_rate_control {
+	unsigned long last_rate_change;
+	u32 tx_num_failures;
+	u32 tx_num_xmit;
+
+	unsigned long avg_rate_update;
+	u32 tx_avg_rate_sum;
+	u32 tx_avg_rate_num;
+};
+
+static void rate_control_simple_tx_status(struct net_device *dev,
+					  struct sk_buff *skb,
+					  struct ieee80211_tx_status *status)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	struct sta_info *sta;
+	struct sta_rate_control *srctrl;
+
+	sta = sta_info_get(local, hdr->addr1);
+
+	if (!sta)
+		return;
+
+	srctrl = sta->rate_ctrl_priv;
+	srctrl->tx_num_xmit++;
+	if (status->excessive_retries) {
+		sta->antenna_sel = sta->antenna_sel == 1 ? 2 : 1;
+		if (local->sta_antenna_sel == STA_ANTENNA_SEL_SW_CTRL_DEBUG) {
+			printk(KERN_DEBUG "%s: " MAC_FMT " TX antenna --> %d "
+			       "(@%lu)\n",
+			       dev->name, MAC_ARG(hdr->addr1),
+			       sta->antenna_sel, jiffies);
+		}
+		srctrl->tx_num_failures++;
+		sta->tx_retry_failed++;
+		sta->tx_num_consecutive_failures++;
+		sta->tx_num_mpdu_fail++;
+	} else {
+		sta->last_ack_rssi[0] = sta->last_ack_rssi[1];
+		sta->last_ack_rssi[1] = sta->last_ack_rssi[2];
+		sta->last_ack_rssi[2] = status->ack_signal;
+		sta->tx_num_consecutive_failures = 0;
+		sta->tx_num_mpdu_ok++;
+	}
+	sta->tx_retry_count += status->retry_count;
+	sta->tx_num_mpdu_fail += status->retry_count;
+
+	if (time_after(jiffies,
+		       srctrl->last_rate_change + RATE_CONTROL_INTERVAL) &&
+	    srctrl->tx_num_xmit > RATE_CONTROL_MIN_TX) {
+		u32 per_failed;
+		srctrl->last_rate_change = jiffies;
+
+		per_failed = (100 * sta->tx_num_mpdu_fail) /
+			     (sta->tx_num_mpdu_fail + sta->tx_num_mpdu_ok);
+		/* TODO: calculate average per_failed to make adjusting
+		 * parameters easier */
+#if 0
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "MPDU fail=%d ok=%d per_failed=%d\n",
+			       sta->tx_num_mpdu_fail, sta->tx_num_mpdu_ok,
+			       per_failed);
+		}
+#endif
+
+		if (per_failed > local->rate_ctrl_num_down) {
+			rate_control_rate_dec(local, sta);
+		} else if (per_failed < local->rate_ctrl_num_up) {
+			rate_control_rate_inc(local, sta);
+		}
+		srctrl->tx_avg_rate_sum += local->curr_rates[sta->txrate].rate;
+		srctrl->tx_avg_rate_num++;
+		srctrl->tx_num_failures = 0;
+		srctrl->tx_num_xmit = 0;
+	} else if (sta->tx_num_consecutive_failures >= RATE_CONTROL_EMERG_DEC) {
+		rate_control_rate_dec(local, sta);
+	}
+
+	if (srctrl->avg_rate_update + 60 * HZ < jiffies) {
+		srctrl->avg_rate_update = jiffies;
+		if (srctrl->tx_avg_rate_num > 0) {
+#ifdef CONFIG_D80211_VERBOSE_DEBUG
+			printk(KERN_DEBUG "%s: STA " MAC_FMT " Average rate: "
+			       "%d (%d/%d)\n",
+			       dev->name, MAC_ARG(sta->addr),
+			       srctrl->tx_avg_rate_sum /
+			       srctrl->tx_avg_rate_num,
+			       srctrl->tx_avg_rate_sum,
+			       srctrl->tx_avg_rate_num);
+#endif /* CONFIG_D80211_VERBOSE_DEBUG */
+			srctrl->tx_avg_rate_sum = 0;
+			srctrl->tx_avg_rate_num = 0;
+		}
+	}
+
+	sta_info_put(sta);
+}
+
+static struct ieee80211_rate *rate_control_simple_get_rate(struct net_device
+							   *dev,
+							   struct sk_buff *skb,
+							   struct
+							   rate_control_extra
+							   *extra)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	struct sta_info *sta;
+	int rateidx, nonerp_idx;
+	u16 fc;
+
+	memset(extra, 0, sizeof(*extra));
+
+	fc = le16_to_cpu(hdr->frame_control);
+	if ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
+	    (hdr->addr1[0] & 0x01)) {
+		/* Send management frames and broadcast/multicast data using
+		 * lowest rate. */
+		/* TODO: this could probably be improved.. */
+		return rate_control_lowest_rate(local);
+	}
+
+	sta = sta_info_get(local, hdr->addr1);
+
+	if (!sta)
+		return rate_control_lowest_rate(local);
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (sdata->bss && sdata->bss->force_unicast_rateidx > -1)
+		sta->txrate = sdata->bss->force_unicast_rateidx;
+
+	rateidx = sta->txrate;
+
+	if (rateidx >= local->num_curr_rates)
+		rateidx = local->num_curr_rates - 1;
+
+	sta->last_txrate = rateidx;
+	nonerp_idx = rateidx;
+	while (nonerp_idx > 0 &&
+	       ((local->curr_rates[nonerp_idx].flags & IEEE80211_RATE_ERP) ||
+		!(local->curr_rates[nonerp_idx].flags &
+		  IEEE80211_RATE_SUPPORTED) ||
+		!(sta->supp_rates & BIT(nonerp_idx))))
+		nonerp_idx--;
+	extra->nonerp_idx = nonerp_idx;
+	extra->nonerp = &local->curr_rates[extra->nonerp_idx];
+
+	sta_info_put(sta);
+
+	return &local->curr_rates[rateidx];
+}
+
+static void rate_control_simple_rate_init(struct ieee80211_local *local,
+					  struct sta_info *sta)
+{
+	int i;
+	sta->txrate = 0;
+	/* TODO: what is a good starting rate for STA? About middle? Maybe not
+	 * the lowest or the highest rate.. Could consider using RSSI from
+	 * previous packets? Need to have IEEE 802.1X auth succeed immediately
+	 * after assoc.. */
+	for (i = 0; i < local->num_curr_rates; i++) {
+		if ((sta->supp_rates & BIT(i)) &&
+		    (local->curr_rates[i].flags & IEEE80211_RATE_SUPPORTED))
+			sta->txrate = i;
+	}
+}
+
+static void *rate_control_simple_alloc(struct ieee80211_local *local)
+{
+	struct global_rate_control *rctrl;
+
+	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
+
+	return rctrl;
+}
+
+static void rate_control_simple_free(void *priv)
+{
+	struct global_rate_control *rctrl = priv;
+	kfree(rctrl);
+}
+
+static void rate_control_simple_clear(void *priv)
+{
+}
+
+static void *rate_control_simple_alloc_sta(void)
+{
+	struct sta_rate_control *rctrl;
+
+	rctrl = kzalloc(sizeof(*rctrl), GFP_ATOMIC);
+
+	return rctrl;
+}
+
+static void rate_control_simple_free_sta(void *priv)
+{
+	struct sta_rate_control *rctrl = priv;
+	kfree(rctrl);
+}
+
+static ssize_t show_sta_tx_avg_rate_sum(const struct sta_info *sta, char *buf)
+{
+	struct sta_rate_control *srctrl = sta->rate_ctrl_priv;
+
+	return sprintf(buf, "%d\n", srctrl->tx_avg_rate_sum);
+}
+
+static ssize_t show_sta_tx_avg_rate_num(const struct sta_info *sta, char *buf)
+{
+	struct sta_rate_control *srctrl = sta->rate_ctrl_priv;
+
+	return sprintf(buf, "%d\n", srctrl->tx_avg_rate_num);
+}
+
+static struct sta_attribute sta_attr_tx_avg_rate_sum =
+	__ATTR(tx_avg_rate_sum, S_IRUSR, show_sta_tx_avg_rate_sum, NULL);
+static struct sta_attribute sta_attr_tx_avg_rate_num =
+	__ATTR(tx_avg_rate_num, S_IRUSR, show_sta_tx_avg_rate_num, NULL);
+
+static struct attribute *rate_control_simple_sta_attrs[] = {
+	&sta_attr_tx_avg_rate_sum.attr,
+	&sta_attr_tx_avg_rate_num.attr,
+	NULL,
+};
+
+static struct attribute_group rate_control_simple_sta_group = {
+	.name = "rate_control_simple",
+	.attrs = rate_control_simple_sta_attrs,
+};
+
+static int rate_control_simple_add_sta_attrs(void *priv, struct kobject *kobj)
+{
+	return sysfs_create_group(kobj, &rate_control_simple_sta_group);
+}
+
+static void rate_control_simple_remove_sta_attrs(void *priv,
+						 struct kobject *kobj)
+{
+	sysfs_remove_group(kobj, &rate_control_simple_sta_group);
+}
+
+static struct rate_control_ops rate_control_simple = {
+	.name = "simple",
+	.owner = THIS_MODULE,
+	.tx_status = rate_control_simple_tx_status,
+	.get_rate = rate_control_simple_get_rate,
+	.rate_init = rate_control_simple_rate_init,
+	.clear = rate_control_simple_clear,
+	.alloc = rate_control_simple_alloc,
+	.free = rate_control_simple_free,
+	.alloc_sta = rate_control_simple_alloc_sta,
+	.free_sta = rate_control_simple_free_sta,
+	.add_sta_attrs = rate_control_simple_add_sta_attrs,
+	.remove_sta_attrs = rate_control_simple_remove_sta_attrs,
+};
+
+int __init rate_control_simple_init(void)
+{
+	return ieee80211_rate_control_register(&rate_control_simple);
+}
+
+static void __exit rate_control_simple_exit(void)
+{
+	ieee80211_rate_control_unregister(&rate_control_simple);
+}
+
+module_init(rate_control_simple_init);
+module_exit(rate_control_simple_exit);
+
+MODULE_DESCRIPTION("Simple rate control algorithm for ieee80211");
+MODULE_LICENSE("GPL");

--
