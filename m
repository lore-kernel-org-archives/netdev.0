From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/12] d80211: fix Oops when writing to add_ and remove_iface
Date: Thu,  8 Jun 2006 09:49:08 +0200 (CEST)
Message-ID: <20060608074908.3537448392@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51608 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964779AbWFHHr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:57 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When add_iface or remove_iface sysfs attribute is opened just before device
is unregistered and some data is written there afterwards, their handlers
try to access master net_device which is released at that point.

A similar problem can happen when ioctl is invoked during unregistering - it
is possible that interface the ioctl was called on is still there but master
interface has been already freed.

Fix these problems by:
- checking if the device is unregistered in sysfs handlers and
- releasing all interfaces under single rtnl lock.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    9 +++++++--
 net/d80211/ieee80211_i.h     |    6 ++++++
 net/d80211/ieee80211_sysfs.c |   17 +++++++++++++++--
 3 files changed, 28 insertions(+), 4 deletions(-)

25dd82745a86401267b9954098b99ba4a60a71f6
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 4fc2e7d..c983d70 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4225,6 +4225,8 @@ int ieee80211_register_hw(struct net_dev
 	result = ieee80211_if_add(dev, "wlan%d", 1, &sta_dev);
 	if (result == 0)
 		ieee80211_if_set_type(sta_dev, IEEE80211_IF_TYPE_STA);
+
+	local->reg_state = IEEE80211_DEV_REGISTERED;
 	rtnl_unlock();
 
 	return 0;
@@ -4290,14 +4292,17 @@ void ieee80211_unregister_hw(struct net_
 		del_timer_sync(&local->scan_timer);
 	ieee80211_rx_bss_list_deinit(dev);
 
+	rtnl_lock();
+	local->reg_state = IEEE80211_DEV_UNREGISTERED;
 	if (local->apdev)
-		ieee80211_if_del(local->apdev);
+		ieee80211_if_del_mgmt(local->apdev);
 
 	list_for_each_safe(ptr, n, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		ieee80211_if_del(sdata->dev);
+		__ieee80211_if_del(local, sdata);
 	}
+	rtnl_unlock();
 
 	sta_info_stop(local);
 	ieee80211_dev_sysfs_del(local);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 84cc50e..9fabf17 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -321,6 +321,12 @@ struct ieee80211_local {
 	int dev_index;
 	struct class_device class_dev;
 
+	enum {
+		IEEE80211_DEV_UNITIALIZED = 0,
+		IEEE80211_DEV_REGISTERED,
+		IEEE80211_DEV_UNREGISTERED,
+	} reg_state;
+
 	/* Tasklet and skb queue to process calls from IRQ mode. All frames
 	 * added to skb_queue will be processed, but frames in
 	 * skb_queue_unreliable may be dropped if the total length of these
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index fb95e96..e799506 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -17,6 +17,15 @@ #include "ieee80211_i.h"
 
 #define to_ieee80211_local(class)	container_of(class, struct ieee80211_local, class_dev)
 
+static inline int rtnl_lock_local(struct ieee80211_local *local)
+{
+	rtnl_lock();
+	if (unlikely(local->reg_state != IEEE80211_DEV_REGISTERED)) {
+		rtnl_unlock();
+		return -ENODEV;
+	}
+	return 0;
+}
 
 static ssize_t store_add_iface(struct class_device *dev,
 			       const char *buf, size_t len)
@@ -29,7 +38,9 @@ static ssize_t store_add_iface(struct cl
 		return -EPERM;
 	if (len > IFNAMSIZ)
 		return -EINVAL;
-	rtnl_lock();
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
 	res = ieee80211_if_add(local->mdev, buf, 0, &new_dev);
 	if (res == 0)
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
@@ -47,7 +58,9 @@ static ssize_t store_remove_iface(struct
 		return -EPERM;
 	if (len > IFNAMSIZ)
 		return -EINVAL;
-	rtnl_lock();
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
 	res = ieee80211_if_remove(local->mdev, buf, -1);
 	rtnl_unlock();
 	return res < 0 ? res : len;
-- 
1.3.0

