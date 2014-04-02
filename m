From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v6 2/4] mac80211: set NET_NAME_USER for user-space created ifs
Date: Wed,  2 Apr 2014 11:58:24 +0200
Message-ID: <1396432706-14470-3-git-send-email-dh.herrmann@gmail.com>
References: <1396432706-14470-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kay Sievers <kay.sievers@vrfy.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396432706-14470-1-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nl80211 interface allows creating new netdevs from user-space. The
name is *always* provided by user-space, so we should set NET_NAME_USER to
provide that information via sysfs. But we must not set it for the default
wlan%d names as these are kernel-provided names.

This allows udev to not rename dynamically created wifi devices (like wifi
P2P devices).

Cc: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
Acked-by: Tom Gundersen <teg@jklm.no>
Acked-by: Kay Sievers <kay.sievers@vrfy.org>
---
 net/mac80211/cfg.c         | 2 +-
 net/mac80211/ieee80211_i.h | 1 +
 net/mac80211/iface.c       | 2 ++
 net/mac80211/main.c        | 2 +-
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index aaa59d7..804cf0a 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -31,7 +31,7 @@ static struct wireless_dev *ieee80211_add_iface(struct wiphy *wiphy,
 	struct ieee80211_sub_if_data *sdata;
 	int err;
 
-	err = ieee80211_if_add(local, name, &wdev, type, params);
+	err = ieee80211_if_add(local, name, NET_NAME_USER, &wdev, type, params);
 	if (err)
 		return ERR_PTR(err);
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 222c28b..1a938c3 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1470,6 +1470,7 @@ int ieee80211_channel_switch(struct wiphy *wiphy, struct net_device *dev,
 int ieee80211_iface_init(void);
 void ieee80211_iface_exit(void);
 int ieee80211_if_add(struct ieee80211_local *local, const char *name,
+		     unsigned char name_assign_type,
 		     struct wireless_dev **new_wdev, enum nl80211_iftype type,
 		     struct vif_params *params);
 int ieee80211_if_change_type(struct ieee80211_sub_if_data *sdata,
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index b8d331e..fe84853 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1574,6 +1574,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 }
 
 int ieee80211_if_add(struct ieee80211_local *local, const char *name,
+		     unsigned char name_assign_type,
 		     struct wireless_dev **new_wdev, enum nl80211_iftype type,
 		     struct vif_params *params)
 {
@@ -1617,6 +1618,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 					+ IEEE80211_ENCRYPT_HEADROOM;
 		ndev->needed_tailroom = IEEE80211_ENCRYPT_TAILROOM;
 
+		ndev->name_assign_type = name_assign_type;
 		ret = dev_alloc_name(ndev, ndev->name);
 		if (ret < 0) {
 			free_netdev(ndev);
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b055f6a5..ee32a83 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1012,7 +1012,7 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	/* add one default STA interface if supported */
 	if (local->hw.wiphy->interface_modes & BIT(NL80211_IFTYPE_STATION)) {
-		result = ieee80211_if_add(local, "wlan%d", NULL,
+		result = ieee80211_if_add(local, "wlan%d", NET_NAME_ENUM, NULL,
 					  NL80211_IFTYPE_STATION, NULL);
 		if (result)
 			wiphy_warn(local->hw.wiphy,
-- 
1.9.1
