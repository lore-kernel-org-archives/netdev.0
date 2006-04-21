From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/10] d80211: add one default interface
Date: Fri, 21 Apr 2006 22:53:30 +0200 (CEST)
Message-ID: <20060421205330.491F9482C2@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47489 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932452AbWDUUxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:53:02 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The wireless card is useless with master interface (wmasterX) only. Adding
at least one virtual interface is necessity for every user. To save users
a lot of pain (and to maintain backward compatibility) we should add one
virtual interface by default. It is called wlanX (hopefully the name users
are used to) and set to STA mode.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    9 +++++++++
 net/d80211/ieee80211_i.h     |    2 +-
 net/d80211/ieee80211_iface.c |   18 ++++++++++++------
 net/d80211/ieee80211_ioctl.c |    8 ++++----
 net/d80211/ieee80211_sysfs.c |    2 +-
 5 files changed, 27 insertions(+), 12 deletions(-)

a808727dea7cd4e8bf1185246e37a2780fb58292
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 1fd13dd..a03ab09 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4215,6 +4215,7 @@ struct net_device *ieee80211_alloc_hw(si
 int ieee80211_register_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
         struct ieee80211_local *local = dev->priv;
+	struct net_device *sta_dev;
 	int result;
 
 	if (!hw)
@@ -4259,6 +4260,14 @@ int ieee80211_register_hw(struct net_dev
 
         ieee80211_wep_init(local);
 	ieee80211_proc_init_interface(local);
+
+	/* add one default STA interface */
+	rtnl_lock();
+	result = ieee80211_if_add(dev, "wlan%d", 1, &sta_dev);
+	if (result == 0)
+		ieee80211_if_set_type(sta_dev, IEEE80211_IF_TYPE_STA);
+	rtnl_unlock();
+
 	return 0;
 
 fail_rate:
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 3580d1e..422d198 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -587,7 +587,7 @@ int ieee80211_dev_find_index(struct ieee
 
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
-		     struct net_device **new_dev);
+		     int format, struct net_device **new_dev);
 int ieee80211_if_set_type(struct net_device *dev, int type);
 void ieee80211_if_reinit(struct net_device *dev);
 void __ieee80211_if_del(struct ieee80211_local *local,
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index d71d4f9..4398567 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -26,7 +26,7 @@ void ieee80211_if_sdata_init(struct ieee
 
 /* Must be called with rtnl lock held. */
 int ieee80211_if_add(struct net_device *dev, const char *name,
-		     struct net_device **new_dev)
+		     int format, struct net_device **new_dev)
 {
 	struct net_device *ndev, *tmp_dev;
 	struct ieee80211_local *local = dev->priv;
@@ -54,6 +54,10 @@ int ieee80211_if_add(struct net_device *
 				break;
 			dev_put(tmp_dev);
 		} while (i < 10000);
+	} else if (format) {
+		ret = dev_alloc_name(ndev, name);
+		if (ret)
+			goto fail;
 	} else {
 		snprintf(ndev->name, IFNAMSIZ, "%s", name);
 	}
@@ -75,16 +79,18 @@ int ieee80211_if_add(struct net_device *
 	ieee80211_if_sdata_init(sdata);
 
 	ret = register_netdevice(ndev);
-	if (ret) {
-		kfree(ndev);
-		*new_dev = NULL;
-		return ret;
-	}
+	if (ret)
+		goto fail;
 
 	list_add(&sdata->list, &local->sub_if_list);
 	ieee80211_proc_init_virtual(ndev);
 
 	return 0;
+
+fail:
+	kfree(ndev);
+	*new_dev = NULL;
+	return ret;
 }
 
 static int ieee80211_if_add_apdev(struct net_device *dev)
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 1d3f5cf..5d31a8f 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -931,7 +931,7 @@ static int ieee80211_ioctl_add_if(struct
                 if (left < sizeof(struct hostapd_if_wds))
                         return -EPROTO;
 
-		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		res = ieee80211_if_add(dev, param->u.if_info.name, 0, &new_dev);
 		if (res)
 			return res;
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_WDS);
@@ -943,7 +943,7 @@ static int ieee80211_ioctl_add_if(struct
 		if (left < sizeof(struct hostapd_if_vlan))
 			return -EPROTO;
 
-		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		res = ieee80211_if_add(dev, param->u.if_info.name, 0, &new_dev);
 		if (res)
 			return res;
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_VLAN);
@@ -960,7 +960,7 @@ #endif
                 if (left < sizeof(struct hostapd_if_bss))
                         return -EPROTO;
 
-		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		res = ieee80211_if_add(dev, param->u.if_info.name, 0, &new_dev);
 		if (res)
 			return res;
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_AP);
@@ -975,7 +975,7 @@ #endif
                 if (left < sizeof(struct hostapd_if_sta))
                         return -EPROTO;
 
-		res = ieee80211_if_add(dev, param->u.if_info.name, &new_dev);
+		res = ieee80211_if_add(dev, param->u.if_info.name, 0, &new_dev);
 		if (res)
 			return res;
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 546e2b7..463f9aa 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -30,7 +30,7 @@ static ssize_t store_add_iface(struct cl
 	if (len > IFNAMSIZ)
 		return -EINVAL;
 	rtnl_lock();
-	res = ieee80211_if_add(local->mdev, buf, &new_dev);
+	res = ieee80211_if_add(local->mdev, buf, 0, &new_dev);
 	if (res == 0)
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
 	rtnl_unlock();
-- 
1.3.0

