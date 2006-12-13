From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/14] d80211: set default_wep_only dynamically
Date: Wed, 13 Dec 2006 17:41:37 +0100 (CET)
Message-ID: <20061213164137.46FA43AA6BA@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57263 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965043AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Without this change d80211 relies on userspace to let it know when it can
configure default wep keys.  It is always safe to set default_wep_only if there
is a single station interface.  This allows for hardware accelleration for
the case of a single station interface.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_i.h     |    1 +
 net/d80211/ieee80211_iface.c |    4 ++++
 net/d80211/ieee80211_ioctl.c |   30 ++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 0 deletions(-)

3498e00a7cb36a9e309bf4aefd1a012a7971afb3
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ef303da..5615d6d 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -607,6 +607,7 @@ extern const struct iw_handler_def ieee8
 int ieee80211_set_hw_encryption(struct net_device *dev,
 				struct sta_info *sta, u8 addr[ETH_ALEN],
 				struct ieee80211_key *key);
+void ieee80211_update_default_wep_only(struct ieee80211_local *local);
 
 /* ieee80211_scan.c */
 void ieee80211_init_scan(struct ieee80211_local *local);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3e9d531..ae1fb9e 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -97,6 +97,7 @@ int ieee80211_if_add(struct net_device *
 	}
 
 	list_add(&sdata->list, &local->sub_if_list);
+	ieee80211_update_default_wep_only(local);
 
 	return 0;
 
@@ -164,6 +165,7 @@ void ieee80211_if_del_mgmt(struct ieee80
 void ieee80211_if_set_type(struct net_device *dev, int type)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	sdata->type = type;
 	switch (type) {
@@ -205,6 +207,7 @@ void ieee80211_if_set_type(struct net_de
 		       dev->name, __FUNCTION__, type);
 	}
 	ieee80211_sysfs_change_if_type(dev);
+	ieee80211_update_default_wep_only(local);
 }
 
 /* Must be called with rtnl lock held. */
@@ -329,6 +332,7 @@ int ieee80211_if_remove(struct net_devic
 		    strcmp(name, sdata->dev->name) == 0 &&
 		    sdata->dev != local->mdev) {
 			__ieee80211_if_del(local, sdata);
+			ieee80211_update_default_wep_only(local);
 			return 0;
 		}
 	}
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index ef373f7..7de1fee 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2357,6 +2357,36 @@ static int ieee80211_ioctl_default_wep_o
 }
 
 
+void ieee80211_update_default_wep_only(struct ieee80211_local *local)
+{
+	int i = 0;
+	struct ieee80211_sub_if_data *sdata;
+
+	spin_lock_bh(&local->sub_if_lock);
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
+
+		if (sdata->dev == local->mdev)
+			continue;
+
+		/* If there is an AP interface then depend on userspace to
+		   set default_wep_only correctly. */
+		if (sdata->type == IEEE80211_IF_TYPE_AP) {
+			spin_unlock_bh(&local->sub_if_lock);
+			return;
+		}
+
+		i++;
+	}
+
+	if (i <= 1)
+		ieee80211_ioctl_default_wep_only(local, 1);
+	else
+		ieee80211_ioctl_default_wep_only(local, 0);
+
+	spin_unlock_bh(&local->sub_if_lock);
+}
+
+
 static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 					struct iw_request_info *info,
 					void *wrqu, char *extra)
-- 
1.3.0

