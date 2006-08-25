From: Hong Liu <hong.liu@intel.com>
Subject: [PATCH 1/2]d80211: fix wpa_supplicant reassoc problem
Date: Fri, 25 Aug 2006 16:32:08 +0800
Message-ID: <1156494728.21483.12.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-4HMDnu2RPPWJJLbL0Oag"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65093 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932197AbWHYIgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 04:36:01 -0400
To: jbenc@suse.cz
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-4HMDnu2RPPWJJLbL0Oag
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

After key negotiation completed using wpa_supplicant, wpa_supplicant
can't reassoc with the AP if we reboot the AP. It always fails at the
4-way handshake.
The problem is the key info is not cleared correctly. Thus when
wpa_supplicant send the EAPOL-KEY packet, the d80211 stack finds the old
key and uses it to encrypt the packet.

The patch removes the sta_info when we disassociate with AP.

Thanks,
Hong

--=-4HMDnu2RPPWJJLbL0Oag
Content-Disposition: attachment; filename=d80211-fix-wpa-reassoc-problem-git.patch
Content-Type: text/x-patch; name=d80211-fix-wpa-reassoc-problem-git.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 8caf352..2144b34 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -739,6 +739,14 @@ static void ieee80211_associated(struct 
 		wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
 		mod_timer(&ifsta->timer,
 			  jiffies + IEEE80211_MONITORING_INTERVAL + 30 * HZ);
+
+		sta = sta_info_get(local, ifsta->bssid);
+		if (sta) {
+			sta_info_free(sta, 0);
+			sta_info_put(sta);
+		}
+
+		ifsta->probereq_poll = 0;
 	} else {
 		mod_timer(&ifsta->timer,
 			  jiffies + IEEE80211_MONITORING_INTERVAL);
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 7f5febe..8902816 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -197,6 +197,12 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	       local->mdev->name, MAC_ARG(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
+	if (sta->key) {
+		ieee80211_key_sysfs_remove(sta->key);
+		ieee80211_key_free(sta->key);
+		sta->key = NULL;
+	}
+
 	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
 	ieee80211_sta_sysfs_remove(sta);
 
@@ -244,8 +250,6 @@ void sta_info_free(struct sta_info *sta,
 				kfree(key);
 			}
 		}
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
 	} else if (sta->key_idx_compression != HW_KEY_IDX_INVALID) {
 		struct ieee80211_key_conf conf;
 		memset(&conf, 0, sizeof(conf));

--=-4HMDnu2RPPWJJLbL0Oag--
