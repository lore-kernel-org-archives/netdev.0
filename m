From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/8] d80211: allow changing of the rate control algorithm
Date: Mon,  2 Oct 2006 20:26:11 +0200 (CEST)
Message-ID: <20061002182611.6A61B3AA6B8@silver.suse.cz>
References: <20061002202530.235763132.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42183 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965247AbWJBSY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 14:24:59 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20061002202530.235763132.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow changing of the rate control algorithm.

This has some limitations:
- The rate control algorithm can be set per-wiphy only.
- All of network interfaces of the wiphy have to be down to change the
  algorithm.
- All sta entries are flushed when the algorithm is succesfully changed.
- The add_sta ioctl can be called only at a running interface from now.

Changing of the algorithm is possible by writing a new algorithm name into
/sys/class/ieee80211/phyX/rate_ctrl_alg. This will be most likely changed in
the future.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   50 +++++++++++++++++++++++++++++-------------
 net/d80211/ieee80211_i.h     |    2 ++
 net/d80211/ieee80211_ioctl.c |    4 +++
 net/d80211/ieee80211_sysfs.c |   18 ++++++++++++++-
 4 files changed, 57 insertions(+), 17 deletions(-)

7fc923b53c8689378512c6fe51b21e85224f860b
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 8d8149e..ce56fd3 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4303,22 +4303,44 @@ static void ieee80211_precalc_modes(stru
 	}
 }
 
-static int rate_control_initialize(struct ieee80211_local *local)
+int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
+				 const char *name)
 {
-	struct rate_control_ref *ref;
+	struct rate_control_ref *ref, *old;
+	int res;
+
+	ASSERT_RTNL();
+	if (local->open_count || netif_running(local->mdev) ||
+	    (local->apdev && netif_running(local->apdev)))
+		return -EBUSY;
 
-	ref = rate_control_alloc(NULL, local);
+	ref = rate_control_alloc(name, local);
 	if (!ref) {
 		printk(KERN_WARNING "%s: Failed to select rate control "
 		       "algorithm\n", local->mdev->name);
-		return -1;
+		return -ENOENT;
+	}
+	res = rate_control_add_attrs(ref, &local->class_dev.kobj);
+	if (res < 0) {
+		printk(KERN_DEBUG "%s: Failed to register sysfs attributes "
+		       "for rate control\n", local->mdev->name);
+		rate_control_put(ref);
+		return res;
 	}
+
+	old = local->rate_ctrl;
 	local->rate_ctrl = ref;
+	if (old) {
+		rate_control_remove_attrs(ref, &local->class_dev.kobj);
+		rate_control_put(old);
+		sta_info_flush(local, NULL);
+	}
 
 	printk(KERN_DEBUG "%s: Selected rate control "
 	       "algorithm '%s'\n", local->mdev->name,
 	       ref->ops->name);
 
+
 	return 0;
 }
 
@@ -4328,6 +4350,7 @@ static void rate_control_deinitialize(st
 
 	ref = local->rate_ctrl;
 	local->rate_ctrl = NULL;
+	rate_control_remove_attrs(ref, &local->class_dev.kobj);
 	rate_control_put(ref);
 }
 
@@ -4496,28 +4519,24 @@ int ieee80211_register_hw(struct net_dev
 		goto fail_masterlink;
 	}
 	result = ieee80211_sysfs_add_netdevice(dev);
-	rtnl_unlock();
-	if (result < 0)
+	if (result < 0) {
+		rtnl_unlock();
 		goto fail_if_sysfs;
+	}
 
-	result = rate_control_initialize(local);
+	result = ieee80211_init_rate_ctrl_alg(local, NULL);
+	rtnl_unlock();
 	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
 		       "algorithm\n", dev->name);
 		goto fail_rate;
 	}
-	result = rate_control_add_attrs(local->ref, &local->class_dev.kobj);
-	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to register sysfs attributes "
-		       "for rate control\n", dev->name);
-		goto fail_rate_attrs;
-	}
 
 	result = ieee80211_wep_init(local);
 
 	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize wep\n", dev->name);
-		goto fail_rate_attrs;
+		goto fail_wep;
 	}
 
 	/* TODO: add rtnl locking around device creation and qdisc install */
@@ -4536,7 +4555,7 @@ int ieee80211_register_hw(struct net_dev
 
 	return 0;
 
-fail_rate_attrs:
+fail_wep:
 	rate_control_deinitialize(local);
 fail_rate:
 	ieee80211_sysfs_remove_netdevice(dev);
@@ -4624,7 +4643,6 @@ void ieee80211_unregister_hw(struct net_
 	ieee80211_rx_bss_list_deinit(dev);
 	ieee80211_clear_tx_pending(local);
 	sta_info_stop(local);
-	rate_control_remove_attrs(local->ref, &local->class_dev.kobj);
 	rate_control_deinitialize(local);
 	ieee80211_dev_sysfs_del(local);
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 9c81c48..314235b 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -583,6 +583,8 @@ int ieee80211_if_update_wds(struct net_d
 void ieee80211_if_setup(struct net_device *dev);
 void ieee80211_if_mgmt_setup(struct net_device *dev);
 void ieee80211_if_shutdown(struct net_device *dev);
+int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
+				 const char *name);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 30390de..ff6718b 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -270,6 +270,10 @@ static int ieee80211_ioctl_add_sta(struc
         struct ieee80211_sub_if_data *sdata;
 	int add_key_entry = 1;
 
+	/* Prevent a race with changing the rate control algorithm */
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
 	sta = sta_info_get(local, param->sta_addr);
 
 	if (!sta) {
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index c0aab4a..2b74a7a 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -102,6 +102,22 @@ static ssize_t store_remove_iface(struct
 	return res < 0 ? res : len;
 }
 
+static ssize_t store_rate_ctrl_alg(struct class_device *dev,
+				   const char *buf, size_t len)
+{
+	struct ieee80211_local *local = to_ieee80211_local(dev);
+	int res;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
+	res = ieee80211_init_rate_ctrl_alg(local, buf);
+	rtnl_unlock();
+	return res < 0 ? res : len;
+}
+
 static ssize_t ieee80211_local_show(struct class_device *dev, char *buf,
 			ssize_t (*format)(struct ieee80211_local *, char *))
 {
@@ -214,7 +230,7 @@ static struct class_device_attribute iee
 	__ATTR(wep_iv, S_IRUGO, ieee80211_local_show_wep_iv, NULL),
 	__ATTR(tx_power_reduction, S_IRUGO, ieee80211_local_show_tx_power_reduction, NULL),
 	__ATTR(modes, S_IRUGO, ieee80211_local_show_modes, NULL),
-	__ATTR(rate_ctrl_alg, S_IRUGO, ieee80211_local_show_rate_ctrl_alg, NULL),
+	__ATTR(rate_ctrl_alg, S_IRUGO | S_IWUGO, ieee80211_local_show_rate_ctrl_alg, store_rate_ctrl_alg),
 	{}
 };
 
-- 
1.3.0

