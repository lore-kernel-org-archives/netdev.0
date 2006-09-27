From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/14] d80211: fix wpa_supplicant reassoc problem
Date: Wed, 27 Sep 2006 17:50:45 +0200 (CEST)
Message-ID: <20060927155045.C522B483B4@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:48268 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964963AbWI0Ptl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:41 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hong Liu <hong.liu@intel.com>

After key negotiation completed using wpa_supplicant, wpa_supplicant
can't reassoc with the AP if we reboot the AP. It always fails at the
4-way handshake.
The problem is the key info is not cleared correctly. Thus when
wpa_supplicant send the EAPOL-KEY packet, the d80211 stack finds the old
key and uses it to encrypt the packet.

The patch removes the sta_info when we disassociate with AP.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |    2 ++
 net/d80211/sta_info.c      |    8 ++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

25a49e579344602c14e4cf79fa95098b01e7cf27
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..557ba17 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -710,6 +710,8 @@ static void ieee80211_associated(struct 
 				       "range\n",
 				       dev->name, MAC_ARG(ifsta->bssid));
 				disassoc = 1;
+				sta_info_free(sta, 0);
+				ifsta->probereq_poll = 0;
 			} else {
 				ieee80211_send_probe_req(dev, ifsta->bssid,
 							 local->scan_ssid,
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 622b234..5edbd0c 100644
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
-- 
1.3.0

