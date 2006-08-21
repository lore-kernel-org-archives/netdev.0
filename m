From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 09/18] d80211:  move out rate control registration code
Date: Mon, 21 Aug 2006 09:41:16 +0200
Message-ID: <20060821075200.634948638@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51648 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030320AbWHUICE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:04 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-shuffle-out-ratecontrol.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves some common rate control code from ieee80211.c into a new
rate_control.c file.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/Makefile	2006-08-20 14:56:19.758192788 +0200
+++ wireless-dev/net/d80211/Makefile	2006-08-20 14:56:21.948192788 +0200
@@ -15,6 +15,7 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	ieee80211_sysfs.o \
 	ieee80211_sysfs_sta.o \
 	michael.o \
+	rate_control.o \
 	tkip.o \
 	aes_ccm.o \
 	wme.o \
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/rate_control.c	2006-08-20 14:56:21.948192788 +0200
@@ -0,0 +1,62 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005-2006, Devicescape Software, Inc.
+ * Copyright 2006, Johannes Berg <johannes@sipsolutions.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <net/d80211.h>
+#include "ieee80211_i.h"
+#include "rate_control.h"
+
+LIST_HEAD(ieee80211_rate_ctrl_algs);
+DEFINE_MUTEX(ieee80211_rate_ctrl_mtx);
+
+int ieee80211_rate_control_register(struct rate_control_ops *ops)
+{
+	struct rate_control_ops *i;
+
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	list_for_each_entry(i, &ieee80211_rate_ctrl_algs, list) {
+		if (strcmp(i->name, ops->name) == 0) {
+			mutex_unlock(&ieee80211_rate_ctrl_mtx);
+			return -EALREADY;
+		}
+	}
+	list_add(&ops->list, &ieee80211_rate_ctrl_algs);
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ieee80211_rate_control_register);
+
+void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
+{
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	list_del(&ops->list);
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
+}
+EXPORT_SYMBOL_GPL(ieee80211_rate_control_unregister);
+
+struct rate_control_ops *ieee80211_rate_control_select(char *name)
+{
+	struct rate_control_ops *rctl, *result = NULL;
+
+	mutex_lock(&ieee80211_rate_ctrl_mtx);
+	if (list_empty(&ieee80211_rate_ctrl_algs)) {
+		mutex_unlock(&ieee80211_rate_ctrl_mtx);
+		request_module("ieee80211_rate_control_%s", name?name:"simple");
+		mutex_lock(&ieee80211_rate_ctrl_mtx);
+	}
+	list_for_each_entry(rctl, &ieee80211_rate_ctrl_algs, list) {
+		if (!name || strcmp(rctl->name, name) == 0) {
+			result = rctl;
+			break;
+		}
+	}
+	mutex_unlock(&ieee80211_rate_ctrl_mtx);
+	return result;
+}
--- wireless-dev.orig/net/d80211/rate_control.h	2006-08-20 14:56:19.758192788 +0200
+++ wireless-dev/net/d80211/rate_control.h	2006-08-20 14:56:21.948192788 +0200
@@ -67,7 +67,7 @@ struct rate_control_ops {
 
 extern int ieee80211_rate_control_register(struct rate_control_ops *ops);
 extern void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
-
+extern struct rate_control_ops *ieee80211_rate_control_select(char *name);
 
 static inline void rate_control_tx_status(struct net_device *dev,
 					  struct sk_buff *skb,
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:21.308192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:22.008192788 +0200
@@ -19,7 +19,6 @@
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <linux/rtnetlink.h>
-#include <linux/mutex.h>
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
 #include <linux/bitmap.h>
@@ -48,10 +47,6 @@ static unsigned char bridge_tunnel_heade
 static unsigned char eapol_header[] =
 { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
 
-
-LIST_HEAD(ieee80211_rate_ctrl_algs);
-DEFINE_MUTEX(ieee80211_rate_ctrl_mtx);
-
 static int rate_control_initialize(struct ieee80211_local *local);
 
 
@@ -4713,31 +4708,6 @@ void * ieee80211_dev_stats(struct net_de
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	return &(sdata->stats);
 }
-
-
-int ieee80211_rate_control_register(struct rate_control_ops *ops)
-{
-	struct rate_control_ops *i;
-
-	mutex_lock(&ieee80211_rate_ctrl_mtx);
-	list_for_each_entry(i, &ieee80211_rate_ctrl_algs, list) {
-		if (strcmp(i->name, ops->name) == 0) {
-			mutex_unlock(&ieee80211_rate_ctrl_mtx);
-			return -EALREADY;
-		}
-	}
-	list_add(&ops->list, &ieee80211_rate_ctrl_algs);
-	mutex_unlock(&ieee80211_rate_ctrl_mtx);
-	return 0;
-}
-
-
-void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
-{
-	mutex_lock(&ieee80211_rate_ctrl_mtx);
-	list_del(&ops->list);
-	mutex_unlock(&ieee80211_rate_ctrl_mtx);
-}
 EXPORT_SYMBOL(ieee80211_dev_stats);
 
 
@@ -4747,27 +4717,19 @@ static int rate_control_initialize(struc
 
 	BUG_ON(local->rate_ctrl);
 
-	mutex_lock(&ieee80211_rate_ctrl_mtx);
-	if (list_empty(&ieee80211_rate_ctrl_algs)) {
-		mutex_unlock(&ieee80211_rate_ctrl_mtx);
-		request_module("ieee80211_rate_control_simple");
-		mutex_lock(&ieee80211_rate_ctrl_mtx);
-	}
-
-	list_for_each_entry(rctrl, &ieee80211_rate_ctrl_algs, list) {
+	rctrl = ieee80211_rate_control_select(NULL);
+	if (rctrl) {
 		rate_control_alloc(local, rctrl);
 		if (local->rate_ctrl) {
 			printk(KERN_DEBUG "%s: Selected rate control "
 			       "algorithm '%s'\n", local->mdev->name,
 			       local->rate_ctrl->name);
-			mutex_unlock(&ieee80211_rate_ctrl_mtx);
 			return 0;
 		}
 	}
 
 	printk(KERN_WARNING "%s: Failed to select rate control algorithm\n",
 	       local->mdev->name);
-	mutex_unlock(&ieee80211_rate_ctrl_mtx);
 	return -1;
 }
 

--
