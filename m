From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/18] d80211: proper rate control structures freeing
Date: Wed, 18 Oct 2006 17:49:30 +0200 (CEST)
Message-ID: <20061018154930.BCC3E47F64@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13474 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161193AbWJRPtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:02 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a reference counting to the rate control algorithm structure. This
prevents unloading of the rate control module when there still exists a sta
entry which uses that module.

To achieve this some other things need to be done in this patch as well:

- The new rate_control_ref structure is introduced. It replaces the
  rate_ctrl and rate_ctrl_priv fields in the ieee80211_local.

- Parameters for most rate control callbacks are changed.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   37 +++++--------
 net/d80211/ieee80211_i.h     |    3 -
 net/d80211/ieee80211_ioctl.c |    2 -
 net/d80211/ieee80211_rate.c  |   54 +++++++++++++++++-
 net/d80211/ieee80211_rate.h  |  124 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_scan.c  |    2 -
 net/d80211/ieee80211_sta.c   |    6 +-
 net/d80211/ieee80211_sysfs.c |    5 +-
 net/d80211/rc80211_simple.c  |   19 ++++--
 net/d80211/sta_info.c        |   14 +++--
 net/d80211/sta_info.h        |    1 
 11 files changed, 158 insertions(+), 109 deletions(-)

a020fc0696485e6cf460060c7fc03c1066897ba0
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 8c4a6d6..8d8149e 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -351,7 +351,8 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 	extra.startidx  = 0;
 	extra.endidx    = tx->local->num_curr_rates;
 
-	tx->u.tx.rate = rate_control_get_rate(tx->dev, tx->skb, &extra);
+	tx->u.tx.rate = rate_control_get_rate(tx->local, tx->dev, tx->skb,
+					      &extra);
 	if (unlikely(extra.probe != NULL)) {
 		tx->u.tx.control->rate_ctrl_probe = 1;
 		tx->u.tx.probe_last_frag = 1;
@@ -1781,7 +1782,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		memset(&extra, 0, sizeof(extra));
 		extra.endidx = local->num_curr_rates;
 
-		rate = rate_control_get_rate(dev, skb, &extra);
+		rate = rate_control_get_rate(local, dev, skb, &extra);
 		if (!rate) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
@@ -4102,7 +4103,7 @@ void ieee80211_tx_status(struct net_devi
 			return;
 		}
 	} else {
-		rate_control_tx_status(dev, skb, status);
+		rate_control_tx_status(local, dev, skb, status);
 	}
 
 	ieee80211_led_tx(local, 0);
@@ -4304,36 +4305,30 @@ static void ieee80211_precalc_modes(stru
 
 static int rate_control_initialize(struct ieee80211_local *local)
 {
-	struct rate_control_ops *ops;
+	struct rate_control_ref *ref;
 
-	ops = ieee80211_rate_control_ops_get(NULL);
-	if (!ops) {
+	ref = rate_control_alloc(NULL, local);
+	if (!ref) {
 		printk(KERN_WARNING "%s: Failed to select rate control "
 		       "algorithm\n", local->mdev->name);
 		return -1;
 	}
-	local->rate_ctrl_priv = rate_control_alloc(ops, local);
-	if (!local->rate_ctrl_priv) {
-		ieee80211_rate_control_ops_put(ops);
-		return -1;
-	}
-	local->rate_ctrl = ops;
+	local->rate_ctrl = ref;
 
 	printk(KERN_DEBUG "%s: Selected rate control "
 	       "algorithm '%s'\n", local->mdev->name,
-	       local->rate_ctrl->name);
+	       ref->ops->name);
 
 	return 0;
 }
 
 static void rate_control_deinitialize(struct ieee80211_local *local)
 {
-	struct rate_control_ops *ops;
+	struct rate_control_ref *ref;
 
-	rate_control_free(local);
-	ops = local->rate_ctrl;
+	ref = local->rate_ctrl;
 	local->rate_ctrl = NULL;
-	ieee80211_rate_control_ops_put(ops);
+	rate_control_put(ref);
 }
 
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
@@ -4511,8 +4506,7 @@ int ieee80211_register_hw(struct net_dev
 		       "algorithm\n", dev->name);
 		goto fail_rate;
 	}
-	result = rate_control_add_attrs(local, local->rate_ctrl_priv,
-					&local->class_dev.kobj);
+	result = rate_control_add_attrs(local->ref, &local->class_dev.kobj);
 	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to register sysfs attributes "
 		       "for rate control\n", dev->name);
@@ -4630,8 +4624,8 @@ void ieee80211_unregister_hw(struct net_
 	ieee80211_rx_bss_list_deinit(dev);
 	ieee80211_clear_tx_pending(local);
 	sta_info_stop(local);
-	rate_control_remove_attrs(local, local->rate_ctrl_priv,
-				  &local->class_dev.kobj);
+	rate_control_remove_attrs(local->ref, &local->class_dev.kobj);
+	rate_control_deinitialize(local);
 	ieee80211_dev_sysfs_del(local);
 
 	for (i = 0; i < NUM_IEEE80211_MODES; i++) {
@@ -4662,7 +4656,6 @@ EXPORT_SYMBOL(ieee80211_free_hw);
 
 void ieee80211_release_hw(struct ieee80211_local *local)
 {
-	rate_control_deinitialize(local);
 	kfree(local);
 }
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 6fd208e..9c81c48 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -382,8 +382,7 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	struct ieee80211_rate *curr_rates;
 	int num_curr_rates;
 
-	void *rate_ctrl_priv;
-	struct rate_control_ops *rate_ctrl;
+	struct rate_control_ref *rate_ctrl;
 
 	int next_mode; /* MODE_IEEE80211*
 			* The mode preference for next channel change. This is
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 36759e4..30390de 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -311,7 +311,7 @@ static int ieee80211_ioctl_add_sta(struc
 	}
 	sta->supp_rates = rates;
 
-	rate_control_rate_init(local, sta);
+	rate_control_rate_init(sta, local);
 
 	if (param->u.add_sta.wds_flags & 0x01)
 		sta->flags |= WLAN_STA_WDS;
diff --git a/net/d80211/ieee80211_rate.c b/net/d80211/ieee80211_rate.c
index 3ec370f..16e8508 100644
--- a/net/d80211/ieee80211_rate.c
+++ b/net/d80211/ieee80211_rate.c
@@ -55,7 +55,8 @@ void ieee80211_rate_control_unregister(s
 }
 EXPORT_SYMBOL(ieee80211_rate_control_unregister);
 
-static struct rate_control_ops *ieee80211_try_rate_control_ops_get(char *name)
+static struct rate_control_ops *
+ieee80211_try_rate_control_ops_get(const char *name)
 {
 	struct rate_control_alg *alg;
 	struct rate_control_ops *ops = NULL;
@@ -74,7 +75,8 @@ static struct rate_control_ops *ieee8021
 
 /* Get the rate control algorithm. If `name' is NULL, get the first
  * available algorithm. */
-struct rate_control_ops *ieee80211_rate_control_ops_get(char *name)
+static struct rate_control_ops *
+ieee80211_rate_control_ops_get(const char *name)
 {
 	struct rate_control_ops *ops;
 
@@ -86,7 +88,53 @@ struct rate_control_ops *ieee80211_rate_
 	return ops;
 }
 
-void ieee80211_rate_control_ops_put(struct rate_control_ops *ops)
+static void ieee80211_rate_control_ops_put(struct rate_control_ops *ops)
 {
 	module_put(ops->module);
 }
+
+struct rate_control_ref *rate_control_alloc(const char *name,
+					    struct ieee80211_local *local)
+{
+	struct rate_control_ref *ref;
+
+	ref = kmalloc(sizeof(struct rate_control_ref), GFP_KERNEL);
+	if (!ref)
+		goto fail_ref;
+	kref_init(&ref->kref);
+	ref->ops = ieee80211_rate_control_ops_get(name);
+	if (!ref->ops)
+		goto fail_ops;
+	ref->priv = ref->ops->alloc(local);
+	if (!ref->priv)
+		goto fail_priv;
+	return ref;
+
+fail_priv:
+	ieee80211_rate_control_ops_put(ref->ops);
+fail_ops:
+	kfree(ref);
+fail_ref:
+	return NULL;
+}
+
+static void rate_control_release(struct kref *kref)
+{
+	struct rate_control_ref *ctrl_ref;
+
+	ctrl_ref = container_of(kref, struct rate_control_ref, kref);
+	ctrl_ref->ops->free(ctrl_ref->priv);
+	ieee80211_rate_control_ops_put(ctrl_ref->ops);
+	kfree(ctrl_ref);
+}
+
+struct rate_control_ref *rate_control_get(struct rate_control_ref *ref)
+{
+	kref_get(&ref->kref);
+	return ref;
+}
+
+void rate_control_put(struct rate_control_ref *ref)
+{
+	kref_put(&ref->kref, rate_control_release);
+}
diff --git a/net/d80211/ieee80211_rate.h b/net/d80211/ieee80211_rate.h
index 2a4c662..60e4879 100644
--- a/net/d80211/ieee80211_rate.h
+++ b/net/d80211/ieee80211_rate.h
@@ -1,6 +1,7 @@
 /*
  * Copyright 2002-2005, Instant802 Networks, Inc.
  * Copyright 2005, Devicescape Software, Inc.
+ * Copyright (c) 2006 Jiri Benc <jbenc@suse.cz>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -39,120 +40,121 @@ struct rate_control_extra {
 struct rate_control_ops {
 	struct module *module;
 	const char *name;
-	void (*tx_status)(struct net_device *dev, struct sk_buff *skb,
+	void (*tx_status)(void *priv, struct net_device *dev,
+			  struct sk_buff *skb,
 			  struct ieee80211_tx_status *status);
-	struct ieee80211_rate *
-	(*get_rate)(struct net_device *dev, struct sk_buff *skb,
-		    struct rate_control_extra *extra);
-	void (*rate_init)(struct ieee80211_local *local, struct sta_info *sta);
+	struct ieee80211_rate *(*get_rate)(void *priv, struct net_device *dev,
+					   struct sk_buff *skb,
+					   struct rate_control_extra *extra);
+	void (*rate_init)(void *priv, void *priv_sta,
+			  struct ieee80211_local *local, struct sta_info *sta);
 	void (*clear)(void *priv);
 
-	void * (*alloc)(struct ieee80211_local *local);
+	void *(*alloc)(struct ieee80211_local *local);
 	void (*free)(void *priv);
-	void * (*alloc_sta)(void);
-	void (*free_sta)(void *priv);
+	void *(*alloc_sta)(void *priv);
+	void (*free_sta)(void *priv, void *priv_sta);
 
 	int (*add_attrs)(void *priv, struct kobject *kobj);
 	void (*remove_attrs)(void *priv, struct kobject *kobj);
-	int (*add_sta_attrs)(void *priv, struct kobject *kobj);
-	void (*remove_sta_attrs)(void *priv, struct kobject *kobj);
+	int (*add_sta_attrs)(void *priv, void *priv_sta,
+			     struct kobject *kobj);
+	void (*remove_sta_attrs)(void *priv, void *priv_sta,
+				 struct kobject *kobj);
 };
 
+struct rate_control_ref {
+	struct rate_control_ops *ops;
+	void *priv;
+	struct kref kref;
+};
 
 int ieee80211_rate_control_register(struct rate_control_ops *ops);
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops);
 
-struct rate_control_ops *ieee80211_rate_control_ops_get(char *name);
-void ieee80211_rate_control_ops_put(struct rate_control_ops *ops);
+/* Get a reference to the rate control algorithm. If `name' is NULL, get the
+ * first available algorithm. */
+struct rate_control_ref *rate_control_alloc(const char *name,
+					    struct ieee80211_local *local);
+struct rate_control_ref *rate_control_get(struct rate_control_ref *ref);
+void rate_control_put(struct rate_control_ref *ref);
 
-static inline void rate_control_tx_status(struct net_device *dev,
+static inline void rate_control_tx_status(struct ieee80211_local *local,
+					  struct net_device *dev,
 					  struct sk_buff *skb,
 					  struct ieee80211_tx_status *status)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	local->rate_ctrl->tx_status(dev, skb, status);
+	struct rate_control_ref *ref = local->rate_ctrl;
+	ref->ops->tx_status(ref->priv, dev, skb, status);
 }
 
 
 static inline struct ieee80211_rate *
-rate_control_get_rate(struct net_device *dev, struct sk_buff *skb,
-		      struct rate_control_extra *extra)
+rate_control_get_rate(struct ieee80211_local *local, struct net_device *dev,
+		      struct sk_buff *skb, struct rate_control_extra *extra)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	return local->rate_ctrl->get_rate(dev, skb, extra);
+	struct rate_control_ref *ref = local->rate_ctrl;
+	return ref->ops->get_rate(ref->priv, dev, skb, extra);
 }
 
 
-static inline void rate_control_rate_init(struct ieee80211_local *local,
-					  struct sta_info *sta)
+static inline void rate_control_rate_init(struct sta_info *sta,
+					  struct ieee80211_local *local)
 {
-	local->rate_ctrl->rate_init(local, sta);
+	struct rate_control_ref *ref = sta->rate_ctrl;
+	ref->ops->rate_init(ref->priv, sta->rate_ctrl_priv, local, sta);
 }
 
 
 static inline void rate_control_clear(struct ieee80211_local *local)
 {
-	local->rate_ctrl->clear(local->rate_ctrl_priv);
-}
-
-
-static inline void *rate_control_alloc(struct rate_control_ops *ops,
-				       struct ieee80211_local *local)
-{
-	return ops->alloc(local);
+	struct rate_control_ref *ref = local->rate_ctrl;
+	ref->ops->clear(ref->priv);
 }
 
-
-static inline void rate_control_free(struct ieee80211_local *local)
+static inline void *rate_control_alloc_sta(struct rate_control_ref *ref)
 {
-	if (!local->rate_ctrl || !local->rate_ctrl_priv)
-		return;
-	local->rate_ctrl->free(local->rate_ctrl_priv);
-	local->rate_ctrl_priv = NULL;
+	return ref->ops->alloc_sta(ref->priv);
 }
 
-
-static inline void * rate_control_alloc_sta(struct ieee80211_local *local)
-{
-	return local->rate_ctrl->alloc_sta();
-}
-
-
-static inline void rate_control_free_sta(struct ieee80211_local *local,
+static inline void rate_control_free_sta(struct rate_control_ref *ref,
 					 void *priv)
 {
-	local->rate_ctrl->free_sta(priv);
+	ref->ops->free_sta(ref->priv, priv);
 }
 
-static inline int rate_control_add_attrs(struct ieee80211_local *local,
-					 void *priv, struct kobject *kobj)
+static inline int rate_control_add_attrs(struct rate_control_ref *ref,
+					 struct kobject *kobj)
 {
-	if (local->rate_ctrl->add_attrs)
-		return local->rate_ctrl->add_attrs(priv, kobj);
+	if (ref->ops->add_attrs)
+		return ref->ops->add_attrs(ref->priv, kobj);
 	return 0;
 }
 
-static inline void rate_control_remove_attrs(struct ieee80211_local *local,
-					     void *priv, struct kobject *kobj)
+static inline void rate_control_remove_attrs(struct rate_control_ref *ref,
+					     struct kobject *kobj)
 {
-	if (local->rate_ctrl->remove_attrs)
-		local->rate_ctrl->remove_attrs(priv, kobj);
+	if (ref->ops->remove_attrs)
+		ref->ops->remove_attrs(ref->priv, kobj);
 }
 
-static inline int rate_control_add_sta_attrs(struct ieee80211_local *local,
-					     void *priv, struct kobject *kobj)
+static inline int rate_control_add_sta_attrs(struct sta_info *sta,
+					     struct kobject *kobj)
 {
-	if (local->rate_ctrl->add_sta_attrs)
-		return local->rate_ctrl->add_sta_attrs(priv, kobj);
+	struct rate_control_ref *ref = sta->rate_ctrl;
+	if (ref->ops->add_sta_attrs)
+		return ref->ops->add_sta_attrs(ref->priv, sta->rate_ctrl_priv,
+					       kobj);
 	return 0;
 }
 
-static inline void rate_control_remove_sta_attrs(struct ieee80211_local *local,
-						 void *priv,
+static inline void rate_control_remove_sta_attrs(struct sta_info *sta,
 						 struct kobject *kobj)
 {
-	if (local->rate_ctrl->remove_sta_attrs)
-		local->rate_ctrl->remove_sta_attrs(priv, kobj);
+	struct rate_control_ref *ref = sta->rate_ctrl;
+	if (ref->ops->remove_sta_attrs)
+		ref->ops->remove_sta_attrs(ref->priv, sta->rate_ctrl_priv,
+					   kobj);
 }
 
 #endif /* IEEE80211_RATE_H */
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index 0774e9a..add0bf3 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -333,7 +333,7 @@ void ieee80211_init_scan(struct net_devi
 	memset(&extra, 0, sizeof(extra));
 	extra.endidx = local->num_curr_rates;
 	local->scan.tx_control.tx_rate =
-		rate_control_get_rate(dev, local->scan.skb, &extra)->val;
+		rate_control_get_rate(local, dev, local->scan.skb, &extra)->val;
 	local->scan.tx_control.no_ack = 1;
 }
 
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 3ea75ee..ed6747a 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1189,7 +1189,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 	}
 	sta->supp_rates = rates;
 
-	rate_control_rate_init(local, sta);
+	rate_control_rate_init(sta, local);
 
 	if (elems.wmm_param && ifsta->wmm_enabled) {
 		sta->flags |= WLAN_STA_WME;
@@ -2054,7 +2054,7 @@ static int ieee80211_sta_join_ibss(struc
 		control.pkt_type = PKT_PROBE_RESP;
 		memset(&extra, 0, sizeof(extra));
 		extra.endidx = local->num_curr_rates;
-		rate = rate_control_get_rate(dev, skb, &extra);
+		rate = rate_control_get_rate(local, dev, skb, &extra);
 		if (!rate) {
 			printk(KERN_DEBUG "%s: Failed to determine TX rate "
 			       "for IBSS beacon\n", dev->name);
@@ -2839,7 +2839,7 @@ struct sta_info * ieee80211_ibss_add_sta
 	sta->dev = sta_dev;
 	sta->supp_rates = sdata->u.sta.supp_rates_bits;
 
-	rate_control_rate_init(local, sta);
+	rate_control_rate_init(sta, local);
 
 	return sta; /* caller will call sta_info_put() */
 }
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index f9d0e12..c0aab4a 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -188,8 +188,9 @@ __IEEE80211_LOCAL_SHOW(modes);
 static ssize_t ieee80211_local_fmt_rate_ctrl_alg(struct ieee80211_local *local,
 						 char *buf)
 {
-	if (local->rate_ctrl && local->rate_ctrl_priv)
-		return sprintf(buf, "%s\n", local->rate_ctrl->name);
+	struct rate_control_ref *ref = local->rate_ctrl;
+	if (ref)
+		return sprintf(buf, "%s\n", ref->ops->name);
 	return 0;
 }
 __IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
diff --git a/net/d80211/rc80211_simple.c b/net/d80211/rc80211_simple.c
index 6703931..055a167 100644
--- a/net/d80211/rc80211_simple.c
+++ b/net/d80211/rc80211_simple.c
@@ -120,7 +120,7 @@ struct sta_rate_control {
 };
 
 
-static void rate_control_simple_tx_status(struct net_device *dev,
+static void rate_control_simple_tx_status(void *priv, struct net_device *dev,
 					  struct sk_buff *skb,
 					  struct ieee80211_tx_status *status)
 {
@@ -212,7 +212,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 
 static struct ieee80211_rate *
-rate_control_simple_get_rate(struct net_device *dev, struct sk_buff *skb,
+rate_control_simple_get_rate(void *priv, struct net_device *dev,
+			     struct sk_buff *skb,
 			     struct rate_control_extra *extra)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -264,7 +265,8 @@ rate_control_simple_get_rate(struct net_
 }
 
 
-static void rate_control_simple_rate_init(struct ieee80211_local *local,
+static void rate_control_simple_rate_init(void *priv, void *priv_sta,
+					  struct ieee80211_local *local,
 					  struct sta_info *sta)
 {
 	int i;
@@ -303,7 +305,7 @@ static void rate_control_simple_clear(vo
 }
 
 
-static void * rate_control_simple_alloc_sta(void)
+static void * rate_control_simple_alloc_sta(void *priv)
 {
 	struct sta_rate_control *rctrl;
 
@@ -313,9 +315,9 @@ static void * rate_control_simple_alloc_
 }
 
 
-static void rate_control_simple_free_sta(void *priv)
+static void rate_control_simple_free_sta(void *priv, void *priv_sta)
 {
-	struct sta_rate_control *rctrl = priv;
+	struct sta_rate_control *rctrl = priv_sta;
 	kfree(rctrl);
 }
 
@@ -349,12 +351,13 @@ static struct attribute_group rate_contr
 	.attrs = rate_control_simple_sta_attrs,
 };
 
-static int rate_control_simple_add_sta_attrs(void *priv, struct kobject *kobj)
+static int rate_control_simple_add_sta_attrs(void *priv, void *priv_sta,
+					     struct kobject *kobj)
 {
 	return sysfs_create_group(kobj, &rate_control_simple_sta_group);
 }
 
-static void rate_control_simple_remove_sta_attrs(void *priv,
+static void rate_control_simple_remove_sta_attrs(void *priv, void *priv_sta,
 						 struct kobject *kobj)
 {
 	sysfs_remove_group(kobj, &rate_control_simple_sta_group);
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 6a1a466..a177d2f 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -123,7 +123,8 @@ void sta_info_release(struct kobject *ko
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		dev_kfree_skb_any(skb);
 	}
-	rate_control_free_sta(local, sta->rate_ctrl_priv);
+	rate_control_free_sta(sta->rate_ctrl, sta->rate_ctrl_priv);
+	rate_control_put(sta->rate_ctrl);
 	kfree(sta);
 }
 
@@ -146,8 +147,10 @@ struct sta_info * sta_info_add(struct ie
 	sta->kobj.kset = &local->sta_kset;
 	kobject_init(&sta->kobj);
 
-	sta->rate_ctrl_priv = rate_control_alloc_sta(local);
+	sta->rate_ctrl = rate_control_get(local->rate_ctrl);
+	sta->rate_ctrl_priv = rate_control_alloc_sta(sta->rate_ctrl);
 	if (!sta->rate_ctrl_priv) {
+		rate_control_put(sta->rate_ctrl);
 		kobject_put(&sta->kobj);
 		kfree(sta);
 		return NULL;
@@ -177,8 +180,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	if (!in_interrupt()) {
 		sta->sysfs_registered = 1;
 		ieee80211_sta_sysfs_add(sta);
-		rate_control_add_sta_attrs(local, sta->rate_ctrl_priv,
-					   &sta->kobj);
+		rate_control_add_sta_attrs(sta, &sta->kobj);
 	} else {
 		/* procfs entry adding might sleep, so schedule process context
 		 * task for adding proc entry for STAs that do not yet have
@@ -203,7 +205,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		sta->key = NULL;
 	}
 
-	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
+	rate_control_remove_sta_attrs(sta, &sta->kobj);
 	ieee80211_sta_sysfs_remove(sta);
 
 	sta_info_put(sta);
@@ -370,7 +372,7 @@ static void sta_info_proc_add_task(void 
 
 		sta->sysfs_registered = 1;
 		ieee80211_sta_sysfs_add(sta);
-		rate_control_add_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
+		rate_control_add_sta_attrs(sta, &sta->kobj);
 		sta_info_put(sta);
 	}
 }
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 8d23047..9bd7e0d 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -71,6 +71,7 @@ struct sta_info {
 	u32 tx_num_mpdu_ok;
 	u32 tx_num_mpdu_fail;
 
+	struct rate_control_ref *rate_ctrl;
 	void *rate_ctrl_priv;
 
 	/* last received seq/frag number from this STA (per RX queue) */
-- 
1.3.0

