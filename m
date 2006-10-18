From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/18] d80211: proper rate_control loading
Date: Wed, 18 Oct 2006 17:49:28 +0200 (CEST)
Message-ID: <20061018154928.9865747F61@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14498 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161190AbWJRPtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:01 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix locking issues with loading of rate_control modules. This still doesn't
allow changing of the modules on the fly.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Makefile         |    1 
 net/d80211/ieee80211.c      |  108 ++++++++++++++-----------------------------
 net/d80211/ieee80211_rate.c |   92 +++++++++++++++++++++++++++++++++++++
 net/d80211/ieee80211_rate.h |    8 ++-
 net/d80211/rate_control.c   |    3 +
 5 files changed, 136 insertions(+), 76 deletions(-)
 create mode 100644 net/d80211/ieee80211_rate.c

1e55cd13b3f20ac9560270a5455d58f0cbd2acd9
diff --git a/net/d80211/Makefile b/net/d80211/Makefile
index 2a2a0c6..27d90e5 100644
--- a/net/d80211/Makefile
+++ b/net/d80211/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	ieee80211_sta.o \
 	ieee80211_dev.o \
 	ieee80211_iface.o \
+	ieee80211_rate.o \
 	ieee80211_sysfs.o \
 	ieee80211_sysfs_sta.o \
 	michael.o \
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index b138eb0..8c4a6d6 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -46,16 +46,6 @@ static unsigned char eapol_header[] =
 { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
 
 
-struct rate_control_algs {
-	struct rate_control_algs *next;
-	struct rate_control_ops *ops;
-};
-
-static struct rate_control_algs *ieee80211_rate_ctrl_algs;
-
-static int rate_control_initialize(struct ieee80211_local *local);
-
-
 static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
 
 static int ieee80211_mgmt_start_xmit(struct sk_buff *skb,
@@ -4312,6 +4302,39 @@ static void ieee80211_precalc_modes(stru
 	}
 }
 
+static int rate_control_initialize(struct ieee80211_local *local)
+{
+	struct rate_control_ops *ops;
+
+	ops = ieee80211_rate_control_ops_get(NULL);
+	if (!ops) {
+		printk(KERN_WARNING "%s: Failed to select rate control "
+		       "algorithm\n", local->mdev->name);
+		return -1;
+	}
+	local->rate_ctrl_priv = rate_control_alloc(ops, local);
+	if (!local->rate_ctrl_priv) {
+		ieee80211_rate_control_ops_put(ops);
+		return -1;
+	}
+	local->rate_ctrl = ops;
+
+	printk(KERN_DEBUG "%s: Selected rate control "
+	       "algorithm '%s'\n", local->mdev->name,
+	       local->rate_ctrl->name);
+
+	return 0;
+}
+
+static void rate_control_deinitialize(struct ieee80211_local *local)
+{
+	struct rate_control_ops *ops;
+
+	rate_control_free(local);
+	ops = local->rate_ctrl;
+	local->rate_ctrl = NULL;
+	ieee80211_rate_control_ops_put(ops);
+}
 
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
@@ -4520,7 +4543,7 @@ int ieee80211_register_hw(struct net_dev
 	return 0;
 
 fail_rate_attrs:
-	rate_control_free(local);
+	rate_control_deinitialize(local);
 fail_rate:
 	ieee80211_sysfs_remove_netdevice(dev);
 fail_if_sysfs:
@@ -4639,7 +4662,7 @@ EXPORT_SYMBOL(ieee80211_free_hw);
 
 void ieee80211_release_hw(struct ieee80211_local *local)
 {
-	rate_control_free(local);
+	rate_control_deinitialize(local);
 	kfree(local);
 }
 
@@ -4742,67 +4765,6 @@ void * ieee80211_dev_stats(struct net_de
 }
 EXPORT_SYMBOL(ieee80211_dev_stats);
 
-int ieee80211_rate_control_register(struct rate_control_ops *ops)
-{
-	struct rate_control_algs *alg;
-
-	alg = kzalloc(sizeof(*alg), GFP_KERNEL);
-	if (!alg)
-		return -1;
-
-	alg->next = ieee80211_rate_ctrl_algs;
-	alg->ops = ops;
-	ieee80211_rate_ctrl_algs = alg;
-
-	return 0;
-}
-EXPORT_SYMBOL(ieee80211_rate_control_register);
-
-void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
-{
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
-}
-EXPORT_SYMBOL(ieee80211_rate_control_unregister);
-
-static int rate_control_initialize(struct ieee80211_local *local)
-{
-	struct rate_control_algs *algs;
-
-	if (!ieee80211_rate_ctrl_algs)
-		request_module("ieee80211_rate_control");
-
-	for (algs = ieee80211_rate_ctrl_algs; algs; algs = algs->next) {
-		local->rate_ctrl = algs->ops;
-		local->rate_ctrl_priv = rate_control_alloc(local);
-		if (local->rate_ctrl_priv) {
-			printk(KERN_DEBUG "%s: Selected rate control "
-			       "algorithm '%s'\n", local->mdev->name,
-			       local->rate_ctrl->name);
-			return 0;
-		}
-	}
-
-	printk(KERN_WARNING "%s: Failed to select rate control algorithm\n",
-	       local->mdev->name);
-	return -1;
-}
-
-
 static int __init ieee80211_init(void)
 {
 	struct sk_buff *skb;
diff --git a/net/d80211/ieee80211_rate.c b/net/d80211/ieee80211_rate.c
new file mode 100644
index 0000000..3ec370f
--- /dev/null
+++ b/net/d80211/ieee80211_rate.c
@@ -0,0 +1,92 @@
+/*
+ * Copyright 2002-2005, Instant802 Networks, Inc.
+ * Copyright 2005-2006, Devicescape Software, Inc.
+ * Copyright (c) 2006 Jiri Benc <jbenc@suse.cz>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include "ieee80211_rate.h"
+#include "ieee80211_i.h"
+
+struct rate_control_alg {
+	struct list_head list;
+	struct rate_control_ops *ops;
+};
+
+static LIST_HEAD(rate_ctrl_algs);
+static DEFINE_MUTEX(rate_ctrl_mutex);
+
+int ieee80211_rate_control_register(struct rate_control_ops *ops)
+{
+	struct rate_control_alg *alg;
+
+	alg = kmalloc(sizeof(*alg), GFP_KERNEL);
+	if (alg == NULL) {
+		return -ENOMEM;
+	}
+	memset(alg, 0, sizeof(*alg));
+	alg->ops = ops;
+
+	mutex_lock(&rate_ctrl_mutex);
+	list_add_tail(&alg->list, &rate_ctrl_algs);
+	mutex_unlock(&rate_ctrl_mutex);
+
+	return 0;
+}
+EXPORT_SYMBOL(ieee80211_rate_control_register);
+
+void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
+{
+	struct rate_control_alg *alg;
+
+	mutex_lock(&rate_ctrl_mutex);
+	list_for_each_entry(alg, &rate_ctrl_algs, list) {
+		if (alg->ops == ops) {
+			list_del(&alg->list);
+			break;
+		}
+	}
+	mutex_unlock(&rate_ctrl_mutex);
+	kfree(alg);
+}
+EXPORT_SYMBOL(ieee80211_rate_control_unregister);
+
+static struct rate_control_ops *ieee80211_try_rate_control_ops_get(char *name)
+{
+	struct rate_control_alg *alg;
+	struct rate_control_ops *ops = NULL;
+
+	mutex_lock(&rate_ctrl_mutex);
+	list_for_each_entry(alg, &rate_ctrl_algs, list) {
+		if (!name || !strcmp(alg->ops->name, name))
+			if (try_module_get(alg->ops->module)) {
+				ops = alg->ops;
+				break;
+			}
+	}
+	mutex_unlock(&rate_ctrl_mutex);
+	return ops;
+}
+
+/* Get the rate control algorithm. If `name' is NULL, get the first
+ * available algorithm. */
+struct rate_control_ops *ieee80211_rate_control_ops_get(char *name)
+{
+	struct rate_control_ops *ops;
+
+	ops = ieee80211_try_rate_control_ops_get(name);
+	if (!ops) {
+		request_module("rc80211_%s", name ? name : "default");
+		ops = ieee80211_try_rate_control_ops_get(name);
+	}
+	return ops;
+}
+
+void ieee80211_rate_control_ops_put(struct rate_control_ops *ops)
+{
+	module_put(ops->module);
+}
diff --git a/net/d80211/ieee80211_rate.h b/net/d80211/ieee80211_rate.h
index e1c9e05..2a4c662 100644
--- a/net/d80211/ieee80211_rate.h
+++ b/net/d80211/ieee80211_rate.h
@@ -37,6 +37,7 @@ struct rate_control_extra {
 
 
 struct rate_control_ops {
+	struct module *module;
 	const char *name;
 	void (*tx_status)(struct net_device *dev, struct sk_buff *skb,
 			  struct ieee80211_tx_status *status);
@@ -61,6 +62,8 @@ struct rate_control_ops {
 int ieee80211_rate_control_register(struct rate_control_ops *ops);
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
 
+struct rate_control_ops *ieee80211_rate_control_ops_get(char *name);
+void ieee80211_rate_control_ops_put(struct rate_control_ops *ops);
 
 static inline void rate_control_tx_status(struct net_device *dev,
 					  struct sk_buff *skb,
@@ -93,9 +96,10 @@ static inline void rate_control_clear(st
 }
 
 
-static inline void * rate_control_alloc(struct ieee80211_local *local)
+static inline void *rate_control_alloc(struct rate_control_ops *ops,
+				       struct ieee80211_local *local)
 {
-	return local->rate_ctrl->alloc(local);
+	return ops->alloc(local);
 }
 
 
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 90326a8..6703931 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -28,7 +28,7 @@ #define RATE_CONTROL_EMERG_DEC 2
 #define RATE_CONTROL_INTERVAL (HZ / 20)
 #define RATE_CONTROL_MIN_TX 10
 
-MODULE_ALIAS("ieee80211_rate_control");
+MODULE_ALIAS("rc80211_default");
 
 static void rate_control_rate_inc(struct ieee80211_local *local,
 				  struct sta_info *sta)
@@ -361,6 +361,7 @@ static void rate_control_simple_remove_s
 }
 
 static struct rate_control_ops rate_control_simple = {
+	.module = THIS_MODULE,
 	.name = "simple",
 	.tx_status = rate_control_simple_tx_status,
 	.get_rate = rate_control_simple_get_rate,
-- 
1.3.0

