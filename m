From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: [PATCH v2 2/6] ath6kl: unify cfg80211 init/cleanup functions
Date: Thu, 05 Jan 2012 15:26:58 +0200
Message-ID: <20120105132658.22281.85945.stgit@x201>
References: <20120105132523.22281.95999.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, ath6kl-devel@qualcomm.com,
	davem@davemloft.net
To: linville@tuxdriver.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120105132523.22281.95999.stgit@x201>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Group them together and change the naming to follow the common style in
ath6kl. No functional changes.

Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c |  109 +++++++++++++++-------------
 drivers/net/wireless/ath/ath6kl/cfg80211.h |    6 +-
 drivers/net/wireless/ath/ath6kl/init.c     |    4 +
 3 files changed, 62 insertions(+), 57 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index cd67cb6..5f2c137 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -2691,57 +2691,6 @@ struct ath6kl *ath6kl_core_alloc(struct device *dev)
 	return ar;
 }
 
-int ath6kl_register_ieee80211_hw(struct ath6kl *ar)
-{
-	struct wiphy *wiphy = ar->wiphy;
-	int ret;
-
-	wiphy->mgmt_stypes = ath6kl_mgmt_stypes;
-
-	wiphy->max_remain_on_channel_duration = 5000;
-
-	/* set device pointer for wiphy */
-	set_wiphy_dev(wiphy, ar->dev);
-
-	wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION) |
-				 BIT(NL80211_IFTYPE_ADHOC) |
-				 BIT(NL80211_IFTYPE_AP);
-	if (ar->p2p) {
-		wiphy->interface_modes |= BIT(NL80211_IFTYPE_P2P_GO) |
-					  BIT(NL80211_IFTYPE_P2P_CLIENT);
-	}
-
-	/* max num of ssids that can be probed during scanning */
-	wiphy->max_scan_ssids = MAX_PROBED_SSID_INDEX;
-	wiphy->max_scan_ie_len = 1000; /* FIX: what is correct limit? */
-	wiphy->bands[IEEE80211_BAND_2GHZ] = &ath6kl_band_2ghz;
-	wiphy->bands[IEEE80211_BAND_5GHZ] = &ath6kl_band_5ghz;
-	wiphy->signal_type = CFG80211_SIGNAL_TYPE_MBM;
-
-	wiphy->cipher_suites = cipher_suites;
-	wiphy->n_cipher_suites = ARRAY_SIZE(cipher_suites);
-
-	wiphy->wowlan.flags = WIPHY_WOWLAN_MAGIC_PKT |
-			      WIPHY_WOWLAN_DISCONNECT |
-			      WIPHY_WOWLAN_GTK_REKEY_FAILURE  |
-			      WIPHY_WOWLAN_SUPPORTS_GTK_REKEY |
-			      WIPHY_WOWLAN_EAP_IDENTITY_REQ   |
-			      WIPHY_WOWLAN_4WAY_HANDSHAKE;
-	wiphy->wowlan.n_patterns = WOW_MAX_FILTERS_PER_LIST;
-	wiphy->wowlan.pattern_min_len = 1;
-	wiphy->wowlan.pattern_max_len = WOW_PATTERN_SIZE;
-
-	wiphy->max_sched_scan_ssids = 10;
-
-	ret = wiphy_register(wiphy);
-	if (ret < 0) {
-		ath6kl_err("couldn't register wiphy device\n");
-		return ret;
-	}
-
-	return 0;
-}
-
 static int ath6kl_cfg80211_vif_init(struct ath6kl_vif *vif)
 {
 	vif->aggr_cntxt = aggr_init(vif->ndev);
@@ -2835,8 +2784,64 @@ err:
 	return NULL;
 }
 
-void ath6kl_deinit_ieee80211_hw(struct ath6kl *ar)
+int ath6kl_cfg80211_init(struct ath6kl *ar)
+{
+	struct wiphy *wiphy = ar->wiphy;
+	int ret;
+
+	wiphy->mgmt_stypes = ath6kl_mgmt_stypes;
+
+	wiphy->max_remain_on_channel_duration = 5000;
+
+	/* set device pointer for wiphy */
+	set_wiphy_dev(wiphy, ar->dev);
+
+	wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION) |
+				 BIT(NL80211_IFTYPE_ADHOC) |
+				 BIT(NL80211_IFTYPE_AP);
+	if (ar->p2p) {
+		wiphy->interface_modes |= BIT(NL80211_IFTYPE_P2P_GO) |
+					  BIT(NL80211_IFTYPE_P2P_CLIENT);
+	}
+
+	/* max num of ssids that can be probed during scanning */
+	wiphy->max_scan_ssids = MAX_PROBED_SSID_INDEX;
+	wiphy->max_scan_ie_len = 1000; /* FIX: what is correct limit? */
+	wiphy->bands[IEEE80211_BAND_2GHZ] = &ath6kl_band_2ghz;
+	wiphy->bands[IEEE80211_BAND_5GHZ] = &ath6kl_band_5ghz;
+	wiphy->signal_type = CFG80211_SIGNAL_TYPE_MBM;
+
+	wiphy->cipher_suites = cipher_suites;
+	wiphy->n_cipher_suites = ARRAY_SIZE(cipher_suites);
+
+	wiphy->wowlan.flags = WIPHY_WOWLAN_MAGIC_PKT |
+			      WIPHY_WOWLAN_DISCONNECT |
+			      WIPHY_WOWLAN_GTK_REKEY_FAILURE  |
+			      WIPHY_WOWLAN_SUPPORTS_GTK_REKEY |
+			      WIPHY_WOWLAN_EAP_IDENTITY_REQ   |
+			      WIPHY_WOWLAN_4WAY_HANDSHAKE;
+	wiphy->wowlan.n_patterns = WOW_MAX_FILTERS_PER_LIST;
+	wiphy->wowlan.pattern_min_len = 1;
+	wiphy->wowlan.pattern_max_len = WOW_PATTERN_SIZE;
+
+	wiphy->max_sched_scan_ssids = 10;
+
+	ret = wiphy_register(wiphy);
+	if (ret < 0) {
+		ath6kl_err("couldn't register wiphy device\n");
+		return ret;
+	}
+
+	return 0;
+}
+
+void ath6kl_cfg80211_cleanup(struct ath6kl *ar)
 {
 	wiphy_unregister(ar->wiphy);
+
+	/*
+	 * FIXME: should be removed as we remove wiphy in
+	 * ath6kl_core_free(). Most likely this causes a use after free.
+	 */
 	wiphy_free(ar->wiphy);
 }
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.h b/drivers/net/wireless/ath/ath6kl/cfg80211.h
index aa96169..08d9769 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.h
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.h
@@ -27,10 +27,7 @@ enum ath6kl_cfg_suspend_mode {
 struct net_device *ath6kl_interface_add(struct ath6kl *ar, char *name,
 					enum nl80211_iftype type,
 					u8 fw_vif_idx, u8 nw_type);
-int ath6kl_register_ieee80211_hw(struct ath6kl *ar);
 struct ath6kl *ath6kl_core_alloc(struct device *dev);
-void ath6kl_deinit_ieee80211_hw(struct ath6kl *ar);
-
 void ath6kl_cfg80211_scan_complete_event(struct ath6kl_vif *vif, bool aborted);
 
 void ath6kl_cfg80211_connect_event(struct ath6kl_vif *vif, u16 channel,
@@ -58,4 +55,7 @@ void ath6kl_cfg80211_vif_cleanup(struct ath6kl_vif *vif);
 void ath6kl_cfg80211_stop(struct ath6kl_vif *vif);
 void ath6kl_cfg80211_stop_all(struct ath6kl *ar);
 
+int ath6kl_cfg80211_init(struct ath6kl *ar);
+void ath6kl_cfg80211_cleanup(struct ath6kl *ar);
+
 #endif /* ATH6KL_CFG80211_H */
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index ffe6254..32bd111 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -600,7 +600,7 @@ void ath6kl_core_cleanup(struct ath6kl *ar)
 	kfree(ar->fw);
 	kfree(ar->fw_patch);
 
-	ath6kl_deinit_ieee80211_hw(ar);
+	ath6kl_cfg80211_cleanup(ar);
 }
 
 /* firmware upload */
@@ -1608,7 +1608,7 @@ int ath6kl_core_init(struct ath6kl *ar)
 
 	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: got wmi @ 0x%p.\n", __func__, ar->wmi);
 
-	ret = ath6kl_register_ieee80211_hw(ar);
+	ret = ath6kl_cfg80211_init(ar);
 	if (ret)
 		goto err_node_cleanup;
 
