From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/17] d80211: allow WDS remote to by set by WE
Date: Fri, 21 Apr 2006 22:11:34 +0200 (CEST)
Message-ID: <20060421201134.33579482C3@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11143 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932393AbWDUULG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:06 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting of address of WDS remote peer wasn't possible by a WE call. Remote
WDS peer can be understood as a remote AP and SIOCSIWAP/SIOCGIWAP are unused
in WDS mode, so let's use them.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   25 +++++--------------------
 net/d80211/ieee80211_i.h     |    3 +--
 net/d80211/ieee80211_ioctl.c |   27 +++++++++++++++++++++++----
 3 files changed, 29 insertions(+), 26 deletions(-)

7ced2ee797d78b7b568be06a02ff3c1c06b25b9d
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index d0bc0bc..f80dffa 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3944,25 +3944,11 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 }
 
 
-int ieee80211_if_update_wds(struct net_device *dev, char *name,
-			    struct ieee80211_if_wds *wds, int locked)
+int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr)
 {
-	struct net_device *wds_dev = NULL;
 	struct ieee80211_local *local = dev->priv;
-	struct ieee80211_sub_if_data *sdata = NULL;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct sta_info *sta;
-	struct list_head *ptr;
-
-	list_for_each(ptr, &local->sub_if_list) {
-		sdata = list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (strcmp(name, sdata->dev->name) == 0) {
-			wds_dev = sdata->dev;
-			break;
-		}
-	}
-
-	if (wds_dev == NULL || sdata->type != IEEE80211_SUB_IF_TYPE_WDS)
-		return -ENODEV;
 
 	/* Remove STA entry for the old peer */
 	sta = sta_info_get(local, sdata->u.wds.remote_addr);
@@ -3971,13 +3957,12 @@ int ieee80211_if_update_wds(struct net_d
 		sta_info_free(local, sta, 0);
 	} else {
 		printk(KERN_DEBUG "%s: could not find STA entry for WDS link "
-		       "%s peer " MACSTR "\n",
-		       dev->name, wds_dev->name,
-		       MAC2STR(sdata->u.wds.remote_addr));
+		       "peer " MACSTR "\n",
+		       dev->name, MAC2STR(sdata->u.wds.remote_addr));
 	}
 
 	/* Update WDS link data */
-        memcpy(&sdata->u.wds, wds, sizeof(struct ieee80211_if_wds));
+	memcpy(&sdata->u.wds.remote_addr, remote_addr, ETH_ALEN);
 
 	return 0;
 }
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index c217104..ba72466 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -517,8 +517,7 @@ int ieee80211_if_remove_wds(struct net_d
 int ieee80211_if_remove_vlan(struct net_device *dev, const char *name, int locked);
 int ieee80211_if_remove_ap(struct net_device *dev, const char *name, int locked);
 int ieee80211_if_flush(struct net_device *dev, int locked);
-int ieee80211_if_update_wds(struct net_device *dev, char *name,
-			    struct ieee80211_if_wds *wds, int locked);
+int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 987f761..71b72fe 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -997,17 +997,27 @@ static int ieee80211_ioctl_update_if(str
         int left = param_len - ((u8 *) pos - (u8 *) param);
 
 	if (param->u.if_info.type == HOSTAP_IF_WDS) {
-		struct ieee80211_if_wds iwds;
 		struct hostapd_if_wds *wds =
 			(struct hostapd_if_wds *) param->u.if_info.data;
+		struct ieee80211_local *local = dev->priv;
+		struct net_device *wds_dev = NULL;
+		struct ieee80211_sub_if_data *sdata;
 
 		if (left < sizeof(struct ieee80211_if_wds))
 			return -EPROTO;
 
-		memcpy(iwds.remote_addr, wds->remote_addr, ETH_ALEN);
+		list_for_each_entry(sdata, &local->sub_if_list, list) {
+			if (strcmp(param->u.if_info.name,
+				   sdata->dev->name) == 0) {
+				wds_dev = sdata->dev;
+				break;
+			}
+		}
 
-		return ieee80211_if_update_wds(dev, param->u.if_info.name,
-					       &iwds, 1);
+		if (wds_dev == NULL || sdata->type != IEEE80211_SUB_IF_TYPE_WDS)
+			return -ENODEV;
+
+		return ieee80211_if_update_wds(wds_dev, wds->remote_addr);
 	} else {
 		return -EOPNOTSUPP;
 	}
@@ -1842,6 +1852,11 @@ static int ieee80211_ioctl_siwap(struct 
 			       "the low-level driver\n", dev->name);
 		}
 		return ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
+	} else if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS) {
+		if (memcmp(sdata->u.wds.remote_addr, (u8 *) &ap_addr->sa_data,
+			   ETH_ALEN) == 0)
+			return 0;
+		return ieee80211_if_update_wds(dev, (u8 *) &ap_addr->sa_data);
 	}
 
 	return -EOPNOTSUPP;
@@ -1859,6 +1874,10 @@ static int ieee80211_ioctl_giwap(struct 
 		ap_addr->sa_family = ARPHRD_ETHER;
 		memcpy(&ap_addr->sa_data, sdata->u.sta.bssid, ETH_ALEN);
 		return 0;
+	} else if (sdata->type == IEEE80211_SUB_IF_TYPE_WDS) {
+		ap_addr->sa_family = ARPHRD_ETHER;
+		memcpy(&ap_addr->sa_data, sdata->u.wds.remote_addr, ETH_ALEN);
+		return 0;
 	}
 
 	return -EOPNOTSUPP;
-- 
1.3.0

