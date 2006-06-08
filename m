From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/12] d80211: sysfs attributes for associated stations
Date: Thu,  8 Jun 2006 09:49:12 +0200 (CEST)
Message-ID: <20060608074912.6718A48395@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51608 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964782AbWFHHsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:48:01 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add /sys/class/ieee80211/phyX/sta/* attributes.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Makefile              |    1 
 net/d80211/ieee80211.c           |    5 +
 net/d80211/ieee80211_i.h         |   14 ++
 net/d80211/ieee80211_proc.c      |    3 -
 net/d80211/ieee80211_sysfs_sta.c |  228 ++++++++++++++++++++++++++++++++++++++
 net/d80211/sta_info.c            |  114 +++++++++++++------
 net/d80211/sta_info.h            |   11 +-
 7 files changed, 331 insertions(+), 45 deletions(-)
 create mode 100644 net/d80211/ieee80211_sysfs_sta.c

ed88547db8f143b83cf336c93221400edc2b3d81
diff --git a/net/d80211/Makefile b/net/d80211/Makefile
index 66bfcff..7d1ec29 100644
--- a/net/d80211/Makefile
+++ b/net/d80211/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	ieee80211_dev.o \
 	ieee80211_iface.o \
 	ieee80211_sysfs.o \
+	ieee80211_sysfs_sta.o \
 	michael.o \
 	tkip.o \
 	aes_ccm.o \
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 0c23607..15d43f8 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4188,7 +4188,9 @@ int ieee80211_register_hw(struct net_dev
 
 	ieee80211_update_hw(dev, hw);	/* Don't care about the result. */
 
-	sta_info_start(local);
+	result = sta_info_start(local);
+	if (result < 0)
+		goto fail_sta_info;
 
 	if (hw->fraglist)
 		dev->features |= NETIF_F_FRAGLIST;
@@ -4237,6 +4239,7 @@ fail_if_sysfs:
 	unregister_netdev(dev);
 fail_dev:
 	sta_info_stop(local);
+fail_sta_info:
 	ieee80211_dev_sysfs_del(local);
 fail_sysfs:
 	ieee80211_dev_free_index(local);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 7c1b621..212d12f 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -344,9 +344,11 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 
         spinlock_t generic_lock;
 	/* Station data structures */
+	struct kset sta_kset;
 	spinlock_t sta_lock; /* mutex for STA data structures */
 	int num_sta; /* number of stations in sta_list */
 	struct list_head sta_list;
+	struct list_head deleted_sta_list;
 	struct sta_info *sta_hash[STA_HASH_SIZE];
 	struct timer_list sta_cleanup;
 
@@ -511,6 +513,12 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 	int user_space_mlme;
 };
 
+struct sta_attribute {
+	struct attribute attr;
+	ssize_t (*show)(const struct sta_info *, char *buf);
+	ssize_t (*store)(struct sta_info *, const char *buf, size_t count);
+};
+
 
 /* ieee80211.c */
 void ieee80211_release_hw(struct ieee80211_local *local);
@@ -620,4 +628,10 @@ int ieee80211_sysfs_init(void);
 void ieee80211_sysfs_deinit(void);
 int ieee80211_sysfs_change_if_type(struct net_device *dev);
 
+/* ieee80211_sysfs_sta.c */
+int ieee80211_sta_kset_sysfs_register(struct ieee80211_local *local);
+void ieee80211_sta_kset_sysfs_unregister(struct ieee80211_local *local);
+int ieee80211_sta_sysfs_add(struct sta_info *sta);
+void ieee80211_sta_sysfs_remove(struct sta_info *sta);
+
 #endif /* IEEE80211_I_H */
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index 581b583..4bb3179 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -241,7 +241,6 @@ static int ieee80211_proc_sta_read(char 
 	if (!sta || !sta->dev)
 		return -1;
 
-	p += sprintf(p, "users=%d\n", atomic_read(&sta->users));
 	p += sprintf(p, "aid=%d\n", sta->aid);
 	p += sprintf(p, "flags=0x%x %s%s%s%s%s%s%s%s%s%s\n", sta->flags,
 		     sta->flags & WLAN_STA_AUTH ? "[AUTH]" : "",
@@ -656,7 +655,6 @@ void ieee80211_proc_init_sta(struct ieee
 				       ieee80211_proc_sta_read, sta);
 	if (entry) {
 		entry->mode &= ~(S_IRWXG | S_IRWXO);
-		sta->proc_entry_added = 1;
 	}
 }
 
@@ -668,7 +666,6 @@ void ieee80211_proc_deinit_sta(struct ie
 	sprintf(buf, MACSTR, MAC2STR(sta->addr));
 	if (local->proc_sta) {
 		remove_proc_entry(buf, local->proc_sta);
-		sta->proc_entry_added = 0;
 	}
 }
 
diff --git a/net/d80211/ieee80211_sysfs_sta.c b/net/d80211/ieee80211_sysfs_sta.c
new file mode 100644
index 0000000..07de564
--- /dev/null
+++ b/net/d80211/ieee80211_sysfs_sta.c
@@ -0,0 +1,228 @@
+/*
+ * Copyright 2003-2005, Devicescape Software, Inc.
+ * Copyright (c) 2006 Jiri Benc <jbenc@suse.cz>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+#include "ieee80211_i.h"
+#include "sta_info.h"
+
+static ssize_t sta_sysfs_show(struct kobject *, struct attribute *, char *);
+
+static struct sysfs_ops sta_ktype_ops = {
+	.show = sta_sysfs_show,
+};
+
+#define STA_SHOW(name, field, format_string)				\
+static ssize_t show_sta_##name(const struct sta_info *sta, char *buf)	\
+{									\
+	return sprintf(buf, format_string, sta->field);			\
+}
+#define STA_SHOW_D(name, field) STA_SHOW(name, field, "%d\n")
+#define STA_SHOW_U(name, field) STA_SHOW(name, field, "%u\n")
+#define STA_SHOW_LU(name, field) STA_SHOW(name, field, "%lu\n")
+#define STA_SHOW_S(name, field) STA_SHOW(name, field, "%s\n")
+
+#define STA_SHOW_RATE(name, field)					\
+static ssize_t show_sta_##name(const struct sta_info *sta, char *buf)	\
+{									\
+	struct ieee80211_local *local = sta->dev->ieee80211_ptr;	\
+	return sprintf(buf, "%d\n",					\
+		       (sta->field >= 0 &&				\
+			sta->field < local->num_curr_rates) ?		\
+		       local->curr_rates[sta->field].rate : -1);	\
+}
+
+#define __STA_ATTR(name)						\
+static struct sta_attribute sta_attr_##name =				\
+	__ATTR(name, S_IRUSR, show_sta_##name, NULL)
+
+#define STA_ATTR(name, field, format)					\
+		STA_SHOW_##format(name, field)				\
+		__STA_ATTR(name)
+
+STA_ATTR(aid, aid, D);
+STA_ATTR(key_idx_compression, key_idx_compression, D);
+STA_ATTR(dev, dev->name, S);
+STA_ATTR(vlan_id, vlan_id, D);
+STA_ATTR(rx_packets, rx_packets, LU);
+STA_ATTR(tx_packets, tx_packets, LU);
+STA_ATTR(rx_bytes, rx_bytes, LU);
+STA_ATTR(tx_bytes, tx_bytes, LU);
+STA_ATTR(rx_duplicates, num_duplicates, LU);
+STA_ATTR(rx_fragments, rx_fragments, LU);
+STA_ATTR(rx_dropped, rx_dropped, LU);
+STA_ATTR(tx_fragments, tx_fragments, LU);
+STA_ATTR(tx_filtered, tx_filtered_count, LU);
+STA_ATTR(txrate, txrate, RATE);
+STA_ATTR(last_txrate, last_txrate, RATE);
+STA_ATTR(tx_retry_failed, tx_retry_failed, LU);
+STA_ATTR(tx_retry_count, tx_retry_count, LU);
+STA_ATTR(last_rssi, last_rssi, D);
+STA_ATTR(channel_use, channel_use, D);
+STA_ATTR(wep_weak_iv_count, wep_weak_iv_count, D);
+
+static ssize_t show_sta_flags(const struct sta_info *sta, char *buf)
+{
+	return sprintf(buf, "%s%s%s%s%s%s%s%s%s%s",
+		       sta->flags & WLAN_STA_AUTH ? "AUTH\n" : "",
+		       sta->flags & WLAN_STA_ASSOC ? "ASSOC\n" : "",
+		       sta->flags & WLAN_STA_PS ? "PS\n" : "",
+		       sta->flags & WLAN_STA_TIM ? "TIM\n" : "",
+		       sta->flags & WLAN_STA_PERM ? "PERM\n" : "",
+		       sta->flags & WLAN_STA_AUTHORIZED ? "AUTHORIZED\n" : "",
+		       sta->flags & WLAN_STA_SHORT_PREAMBLE ?
+		       "SHORT PREAMBLE\n" : "",
+		       sta->flags & WLAN_STA_WME ? "WME\n" : "",
+		       sta->flags & WLAN_STA_WDS ? "WDS\n" : "",
+		       sta->flags & WLAN_STA_XR ? "XR\n" : "");
+}
+__STA_ATTR(flags);
+
+static ssize_t show_sta_num_ps_buf_frames(const struct sta_info *sta, char *buf)
+{
+	return sprintf(buf, "%u\n", skb_queue_len(&sta->ps_tx_buf));
+}
+__STA_ATTR(num_ps_buf_frames);
+
+static ssize_t show_sta_last_ack_rssi(const struct sta_info *sta, char *buf)
+{
+	return sprintf(buf, "%d %d %d\n", sta->last_ack_rssi[0],
+		       sta->last_ack_rssi[1], sta->last_ack_rssi[2]);
+}
+__STA_ATTR(last_ack_rssi);
+
+static ssize_t show_sta_last_ack_ms(const struct sta_info *sta, char *buf)
+{
+	return sprintf(buf, "%d\n", sta->last_ack ?
+		       jiffies_to_msecs(jiffies - sta->last_ack) : -1);
+}
+__STA_ATTR(last_ack_ms);
+
+static ssize_t show_sta_inactive_ms(const struct sta_info *sta, char *buf)
+{
+	return sprintf(buf, "%d\n", jiffies_to_msecs(jiffies - sta->last_rx));
+}
+__STA_ATTR(inactive_ms);
+
+static ssize_t show_sta_last_seq_ctrl(const struct sta_info *sta, char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += sprintf(p, "%x ", sta->last_seq_ctrl[i]);
+	p += sprintf(p, "\n");
+	return (p - buf);
+}
+__STA_ATTR(last_seq_ctrl);
+
+#ifdef CONFIG_D80211_DEBUG_COUNTERS
+static ssize_t show_sta_wme_rx_queue(const struct sta_info *sta, char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += sprintf(p, "%u ", sta->wme_rx_queue[i]);
+	p += sprintf(p, "\n");
+	return (p - buf);
+}
+__STA_ATTR(wme_rx_queue);
+
+static ssize_t show_sta_wme_tx_queue(const struct sta_info *sta, char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += sprintf(p, "%u ", sta->wme_tx_queue[i]);
+	p += sprintf(p, "\n");
+	return (p - buf);
+}
+__STA_ATTR(wme_tx_queue);
+#endif
+
+static struct attribute *sta_ktype_attrs[] = {
+	&sta_attr_aid.attr,
+	&sta_attr_key_idx_compression.attr,
+	&sta_attr_dev.attr,
+	&sta_attr_vlan_id.attr,
+	&sta_attr_rx_packets.attr,
+	&sta_attr_tx_packets.attr,
+	&sta_attr_rx_bytes.attr,
+	&sta_attr_tx_bytes.attr,
+	&sta_attr_rx_duplicates.attr,
+	&sta_attr_rx_fragments.attr,
+	&sta_attr_rx_dropped.attr,
+	&sta_attr_tx_fragments.attr,
+	&sta_attr_tx_filtered.attr,
+	&sta_attr_txrate.attr,
+	&sta_attr_last_txrate.attr,
+	&sta_attr_tx_retry_failed.attr,
+	&sta_attr_tx_retry_count.attr,
+	&sta_attr_last_rssi.attr,
+	&sta_attr_channel_use.attr,
+	&sta_attr_wep_weak_iv_count.attr,
+
+	&sta_attr_flags.attr,
+	&sta_attr_num_ps_buf_frames.attr,
+	&sta_attr_last_ack_rssi.attr,
+	&sta_attr_last_ack_ms.attr,
+	&sta_attr_inactive_ms.attr,
+	&sta_attr_last_seq_ctrl.attr,
+#ifdef CONFIG_D80211_DEBUG_COUNTERS
+	&sta_attr_wme_rx_queue.attr,
+	&sta_attr_wme_tx_queue.attr,
+#endif
+	NULL
+};
+
+static struct kobj_type sta_ktype = {
+	.release = sta_info_release,
+	.sysfs_ops = &sta_ktype_ops,
+	.default_attrs = sta_ktype_attrs,
+};
+
+static ssize_t sta_sysfs_show(struct kobject *kobj, struct attribute *attr,
+			      char *buf)
+{
+	struct sta_attribute *sta_attr;
+	struct sta_info *sta;
+
+	sta_attr = container_of(attr, struct sta_attribute, attr);
+	sta = container_of(kobj, struct sta_info, kobj);
+	return sta_attr->show(sta, buf);
+}
+
+int ieee80211_sta_kset_sysfs_register(struct ieee80211_local *local)
+{
+	int res;
+
+	res = kobject_set_name(&local->sta_kset.kobj, "sta");
+	if (res)
+		return res;
+	local->sta_kset.kobj.parent = &local->class_dev.kobj;
+	local->sta_kset.ktype = &sta_ktype;
+	return kset_register(&local->sta_kset);
+}
+
+void ieee80211_sta_kset_sysfs_unregister(struct ieee80211_local *local)
+{
+	kset_unregister(&local->sta_kset);
+}
+
+int ieee80211_sta_sysfs_add(struct sta_info *sta)
+{
+	return kobject_add(&sta->kobj);
+}
+
+void ieee80211_sta_sysfs_remove(struct sta_info *sta)
+{
+	kobject_del(&sta->kobj);
+}
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 9565c29..bba4771 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -10,6 +10,7 @@ #include <linux/config.h>
 #include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/kobject.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/slab.h>
@@ -55,6 +56,10 @@ static void sta_info_hash_del(struct iee
 		       "hash table\n", local->mdev->name, MAC2STR(sta->addr));
 }
 
+static inline struct sta_info *__sta_info_get(struct sta_info *sta)
+{
+	return kobject_get(&sta->kobj) ? sta : NULL;
+}
 
 struct sta_info * sta_info_get(struct ieee80211_local *local, u8 *addr)
 {
@@ -64,7 +69,7 @@ struct sta_info * sta_info_get(struct ie
 	sta = local->sta_hash[STA_HASH(addr)];
 	while (sta) {
 		if (memcmp(sta->addr, addr, ETH_ALEN) == 0) {
-			atomic_inc(&sta->users);
+			__sta_info_get(sta);
 			break;
 		}
 		sta = sta->hnext;
@@ -74,7 +79,6 @@ struct sta_info * sta_info_get(struct ie
 	return sta;
 }
 
-
 int sta_info_min_txrate_get(struct ieee80211_local *local)
 {
 	struct sta_info *sta;
@@ -100,10 +104,14 @@ int sta_info_min_txrate_get(struct ieee8
 
 void sta_info_put(struct ieee80211_local *local, struct sta_info *sta)
 {
-	struct sk_buff *skb;
+	kobject_put(&sta->kobj);
+}
 
-	if (!atomic_dec_and_test(&sta->users))
-		return;
+void sta_info_release(struct kobject *kobj)
+{
+	struct sta_info *sta = container_of(kobj, struct sta_info, kobj);
+	struct ieee80211_local *local = sta->local;
+	struct sk_buff *skb;
 
 	/* free sta structure; it has already been removed from
 	 * hash table etc. external structures. Make sure that all
@@ -132,20 +140,27 @@ struct sta_info * sta_info_add(struct ie
 
 	memset(sta, 0, sizeof(*sta));
 
+	if (kobject_set_name(&sta->kobj, MACSTR, MAC2STR(addr))) {
+		kfree(sta);
+		return NULL;
+	}
+	sta->kobj.kset = &local->sta_kset;
+	kobject_init(&sta->kobj);
+
 	sta->rate_ctrl_priv = rate_control_alloc_sta(local);
 	if (sta->rate_ctrl_priv == NULL) {
+		kobject_put(&sta->kobj);
 		kfree(sta);
 		return NULL;
 	}
 
         memcpy(sta->addr, addr, ETH_ALEN);
+	sta->local = local;
         sta->dev = dev;
 	skb_queue_head_init(&sta->ps_tx_buf);
 	skb_queue_head_init(&sta->tx_filtered);
-	atomic_inc(&sta->users); /* sta in hashlist etc, decremented by
-				  * sta_info_free() */
-	atomic_inc(&sta->users); /* sta used by caller, decremented by
-				  * sta_info_put() */
+	__sta_info_get(sta);	/* sta used by caller, decremented by
+				 * sta_info_put() */
 	spin_lock_bh(&local->sta_lock);
 	list_add(&sta->list, &local->sta_list);
 	local->num_sta++;
@@ -161,6 +176,8 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (!in_interrupt()) {
+		sta->sysfs_registered = 1;
+		ieee80211_sta_sysfs_add(sta);
 		ieee80211_proc_init_sta(local, sta);
 	} else {
 		/* procfs entry adding might sleep, so schedule process context
@@ -172,6 +189,19 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	return sta;
 }
 
+static void finish_sta_info_free(struct ieee80211_local *local,
+				 struct sta_info *sta)
+{
+#ifdef CONFIG_D80211_VERBOSE_DEBUG
+	printk(KERN_DEBUG "%s: Removed STA " MACSTR "\n",
+	       local->mdev->name, MAC2STR(sta->addr));
+#endif /* CONFIG_D80211_VERBOSE_DEBUG */
+
+	ieee80211_proc_deinit_sta(local, sta);
+	ieee80211_sta_sysfs_remove(sta);
+
+	sta_info_put(local, sta);
+}
 
 void sta_info_free(struct ieee80211_local *local, struct sta_info *sta,
 		   int locked)
@@ -227,23 +257,11 @@ void sta_info_free(struct ieee80211_loca
 		sta->key_idx_compression = HW_KEY_IDX_INVALID;
 	}
 
-#ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Removed STA " MACSTR "\n",
-	       local->mdev->name, MAC2STR(sta->addr));
-#endif /* CONFIG_D80211_VERBOSE_DEBUG */
-
-	ieee80211_proc_deinit_sta(local, sta);
-
-	if (atomic_read(&sta->users) != 1) {
-		/* This is OK, but printed for debugging. The station structure
-		 * will be removed when the other user of the data calls
-		 * sta_info_put(). */
-		printk(KERN_DEBUG "%s: STA " MACSTR " users count %d when "
-		       "removing it\n", local->mdev->name, MAC2STR(sta->addr),
-		       atomic_read(&sta->users));
-	}
-
-	sta_info_put(local, sta);
+	if (in_atomic()) {
+		list_add(&sta->list, &local->deleted_sta_list);
+		schedule_work(&local->sta_proc_add);
+	} else
+		finish_sta_info_free(local, sta);
 }
 
 
@@ -300,7 +318,7 @@ static void sta_info_cleanup(unsigned lo
 	ptr = local->sta_list.next;
 	while (ptr && ptr != &local->sta_list) {
 		struct sta_info *sta = (struct sta_info *) ptr;
-		atomic_inc(&sta->users);
+		__sta_info_get(sta);
 		sta_info_cleanup_expire_buffered(local, sta);
 		sta_info_put(local, sta);
 		ptr = ptr->next;
@@ -317,15 +335,27 @@ static void sta_info_proc_add_task(void 
 	struct ieee80211_local *local = data;
 	struct list_head *ptr;
 	struct sta_info *sta;
-	int max_adds = 100;
 
-	while (max_adds > 0) {
-		sta = NULL;
+	while (1) {
+		spin_lock_bh(&local->sta_lock);
+		if (!list_empty(&local->deleted_sta_list)) {
+			sta = list_entry(local->deleted_sta_list.next,
+					 struct sta_info, list);
+			list_del(local->deleted_sta_list.next);
+		} else
+			sta = NULL;
+		spin_unlock_bh(&local->sta_lock);
+		if (!sta)
+			break;
+		finish_sta_info_free(local, sta);
+	}
+
+	while (1) {
 		spin_lock_bh(&local->sta_lock);
 		list_for_each(ptr, &local->sta_list) {
 			sta = list_entry(ptr, struct sta_info, list);
-			if (!sta->proc_entry_added) {
-				atomic_inc(&sta->users);
+			if (!sta->sysfs_registered) {
+				__sta_info_get(sta);
 				break;
 			}
 			sta = NULL;
@@ -335,10 +365,10 @@ static void sta_info_proc_add_task(void 
 		if (!sta)
 			break;
 
+		sta->sysfs_registered = 1;
+		ieee80211_sta_sysfs_add(sta);
 		ieee80211_proc_init_sta(local, sta);
-		atomic_dec(&sta->users);
-
-		max_adds--;
+		sta_info_put(local, sta);
 	}
 }
 
@@ -347,6 +377,7 @@ void sta_info_init(struct ieee80211_loca
 {
 	spin_lock_init(&local->sta_lock);
 	INIT_LIST_HEAD(&local->sta_list);
+	INIT_LIST_HEAD(&local->deleted_sta_list);
 
 	init_timer(&local->sta_cleanup);
 	local->sta_cleanup.expires = jiffies + STA_INFO_CLEANUP_INTERVAL;
@@ -356,9 +387,15 @@ void sta_info_init(struct ieee80211_loca
 	INIT_WORK(&local->sta_proc_add, sta_info_proc_add_task, local);
 }
 
-void sta_info_start(struct ieee80211_local *local)
+int sta_info_start(struct ieee80211_local *local)
 {
+	int res;
+
+	res = ieee80211_sta_kset_sysfs_register(local);
+	if (res)
+		return res;
 	add_timer(&local->sta_cleanup);
+	return 0;
 }
 
 void sta_info_stop(struct ieee80211_local *local)
@@ -371,8 +408,13 @@ void sta_info_stop(struct ieee80211_loca
 	while (ptr && ptr != &local->sta_list) {
 		struct sta_info *sta = (struct sta_info *) ptr;
 		ptr = ptr->next;
+		/* sta_info_free must be called with 0 as the last
+		 * parameter to ensure all sysfs sta entries are
+		 * unregistered. We don't need locking at this
+		 * point. */
 		sta_info_free(local, sta, 0);
 	}
+	ieee80211_sta_kset_sysfs_unregister(local);
 }
 
 
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index fddc80e..ddfe50e 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -32,8 +32,10 @@ #define WLAN_STA_WDS BIT(27)
 
 struct sta_info {
 	struct list_head list;
+	struct kobject kobj;
 	struct sta_info *hnext; /* next entry in hash table list */
-	atomic_t users; /* number of users (do not remove if > 0) */
+
+	struct ieee80211_local *local;
 
 	u8 addr[ETH_ALEN];
 	u16 aid; /* STA's unique AID (1..2007), 0 = not yet assigned */
@@ -92,7 +94,7 @@ struct sta_info {
 				  * filtering; used only if sta->key is not
 				  * set */
 
-	int proc_entry_added:1;
+	int sysfs_registered:1;
 	int assoc_ap:1; /* whether this is an AP that we are associated with
 			 * as a client */
 
@@ -130,8 +132,6 @@ #define STA_TX_BUFFER_EXPIRE (10 * HZ)
  */
 #define STA_INFO_CLEANUP_INTERVAL (10 * HZ)
 
-struct ieee80211_local;
-
 struct sta_info * sta_info_get(struct ieee80211_local *local, u8 *addr);
 int sta_info_min_txrate_get(struct ieee80211_local *local);
 void sta_info_put(struct ieee80211_local *local, struct sta_info *sta);
@@ -139,8 +139,9 @@ struct sta_info * sta_info_add(struct ie
 			       struct net_device *dev, u8 *addr);
 void sta_info_free(struct ieee80211_local *local, struct sta_info *sta,
 		   int locked);
+void sta_info_release(struct kobject *kobj);
 void sta_info_init(struct ieee80211_local *local);
-void sta_info_start(struct ieee80211_local *local);
+int sta_info_start(struct ieee80211_local *local);
 void sta_info_stop(struct ieee80211_local *local);
 void sta_info_remove_aid_ptr(struct sta_info *sta);
 void sta_info_flush(struct ieee80211_local *local, struct net_device *dev);
-- 
1.3.0

