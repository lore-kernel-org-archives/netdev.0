From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/12] d80211: rate_control sysfs attributes
Date: Thu,  8 Jun 2006 09:49:14 +0200 (CEST)
Message-ID: <20060608074914.7D3B64838E@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53912 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964774AbWFHHsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:48:03 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for sysfs attributes for rate_control modules.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c    |   13 ++++++++++++-
 net/d80211/rate_control.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 net/d80211/rate_control.h |   36 ++++++++++++++++++++++++++++++++++++
 net/d80211/sta_info.c     |    4 ++++
 4 files changed, 94 insertions(+), 1 deletions(-)

9acfab1d1a4e4a82dace4055a089d605d5efa97f
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 75aaa99..e4ac701 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4215,6 +4215,13 @@ int ieee80211_register_hw(struct net_dev
 		       "algorithm\n", dev->name);
 		goto fail_rate;
 	}
+	result = rate_control_add_attrs(local, local->rate_ctrl_priv,
+					&local->class_dev.kobj);
+	if (result < 0) {
+		printk(KERN_DEBUG "%s: Failed to register sysfs attributes "
+		       "for rate control\n", dev->name);
+		goto fail_rate_attrs;
+	}
 
 	/* TODO: add rtnl locking around device creation and qdisc install */
 	ieee80211_install_qdisc(dev);
@@ -4233,6 +4240,8 @@ int ieee80211_register_hw(struct net_dev
 
 	return 0;
 
+fail_rate_attrs:
+	rate_control_free(local);
 fail_rate:
 	ieee80211_sysfs_remove_netdevice(dev);
 fail_if_sysfs:
@@ -4308,6 +4317,8 @@ void ieee80211_unregister_hw(struct net_
 	rtnl_unlock();
 
 	sta_info_stop(local);
+	rate_control_remove_attrs(local, local->rate_ctrl_priv,
+				  &local->class_dev.kobj);
 	ieee80211_dev_sysfs_del(local);
 
 	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
@@ -4327,7 +4338,6 @@ void ieee80211_unregister_hw(struct net_
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);
 
-	rate_control_free(local);
 	ieee80211_dev_free_index(local);
 }
 
@@ -4341,6 +4351,7 @@ void ieee80211_free_hw(struct net_device
 
 void ieee80211_release_hw(struct ieee80211_local *local)
 {
+	rate_control_free(local);
 	kfree(local);
 }
 
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index e7e6791..33ba8e2 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -350,6 +350,46 @@ static int rate_control_simple_status_gl
 	return 0;
 }
 
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
 
 static struct rate_control_ops rate_control_simple = {
 	.name = "simple",
@@ -363,6 +403,8 @@ static struct rate_control_ops rate_cont
 	.free = rate_control_simple_free,
 	.alloc_sta = rate_control_simple_alloc_sta,
 	.free_sta = rate_control_simple_free_sta,
+	.add_sta_attrs = rate_control_simple_add_sta_attrs,
+	.remove_sta_attrs = rate_control_simple_remove_sta_attrs,
 };
 
 
diff --git a/net/d80211/rate_control.h b/net/d80211/rate_control.h
index b509539..7705fb2 100644
--- a/net/d80211/rate_control.h
+++ b/net/d80211/rate_control.h
@@ -53,6 +53,11 @@ struct rate_control_ops {
 	void (*free)(void *priv);
 	void * (*alloc_sta)(void);
 	void (*free_sta)(void *priv);
+
+	int (*add_attrs)(void *priv, struct kobject *kobj);
+	void (*remove_attrs)(void *priv, struct kobject *kobj);
+	int (*add_sta_attrs)(void *priv, struct kobject *kobj);
+	void (*remove_sta_attrs)(void *priv, struct kobject *kobj);
 };
 
 
@@ -132,4 +137,35 @@ static inline void rate_control_free_sta
 	local->rate_ctrl->free_sta(priv);
 }
 
+static inline int rate_control_add_attrs(struct ieee80211_local *local,
+					 void *priv, struct kobject *kobj)
+{
+	if (local->rate_ctrl->add_attrs)
+		return local->rate_ctrl->add_attrs(priv, kobj);
+	return 0;
+}
+
+static inline void rate_control_remove_attrs(struct ieee80211_local *local,
+					     void *priv, struct kobject *kobj)
+{
+	if (local->rate_ctrl->remove_attrs)
+		local->rate_ctrl->remove_attrs(priv, kobj);
+}
+
+static inline int rate_control_add_sta_attrs(struct ieee80211_local *local,
+					     void *priv, struct kobject *kobj)
+{
+	if (local->rate_ctrl->add_sta_attrs)
+		return local->rate_ctrl->add_sta_attrs(priv, kobj);
+	return 0;
+}
+
+static inline void rate_control_remove_sta_attrs(struct ieee80211_local *local,
+						 void *priv,
+						 struct kobject *kobj)
+{
+	if (local->rate_ctrl->remove_sta_attrs)
+		local->rate_ctrl->remove_sta_attrs(priv, kobj);
+}
+
 #endif /* RATE_CONTROL */
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 9c6adaa..96e8dc4 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -178,6 +178,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	if (!in_interrupt()) {
 		sta->sysfs_registered = 1;
 		ieee80211_sta_sysfs_add(sta);
+		rate_control_add_sta_attrs(local, sta->rate_ctrl_priv,
+					   &sta->kobj);
 		ieee80211_proc_init_sta(local, sta);
 	} else {
 		/* procfs entry adding might sleep, so schedule process context
@@ -197,6 +199,7 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	       local->mdev->name, MAC2STR(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
+	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
 	ieee80211_proc_deinit_sta(local, sta);
 	ieee80211_sta_sysfs_remove(sta);
 
@@ -367,6 +370,7 @@ static void sta_info_proc_add_task(void 
 
 		sta->sysfs_registered = 1;
 		ieee80211_sta_sysfs_add(sta);
+		rate_control_add_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
 		ieee80211_proc_init_sta(local, sta);
 		sta_info_put(sta);
 	}
-- 
1.3.0

