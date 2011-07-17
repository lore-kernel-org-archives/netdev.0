From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] ath6kl: cfg80211: Add and use ath6kl_cfg80211_ready helper
Date: Sun, 17 Jul 2011 11:43:44 -0700
Message-ID: <46870c7654d2d0d10b44ee45097762c482eee1d0.1310927985.git.joe@perches.com>
References: <cover.1310927985.git.joe@perches.com>
Cc: devel@linuxdriverproject.org, gregkh@suse.de, error27@gmail.com,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4074 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab1GQSn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 14:43:59 -0400
In-Reply-To: <cover.1310927985.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce code duplication by using a helper function to
check if the device is ready.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c |  150 ++++++----------------------
 1 files changed, 30 insertions(+), 120 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 34df184..71515bb 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -217,6 +217,21 @@ static void ath6kl_set_key_mgmt(struct ath6kl *ar, u32 key_mgmt)
 	}
 }
 
+static bool ath6kl_cfg80211_ready(struct ath6kl *ar)
+{
+	if (!test_bit(WMI_READY, &ar->flag)) {
+		ath6kl_err("wmi is not ready\n");
+		return false;
+	}
+
+	if (ar->wlan_state == WLAN_DISABLED) {
+		ath6kl_err("wlan disabled\n");
+		return false;
+	}
+
+	return true;
+}
+
 static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 				   struct cfg80211_connect_params *sme)
 {
@@ -225,15 +240,8 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	ar->sme_state = SME_CONNECTING;
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready yet\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
-		return -EIO;
-	}
 
 	if (test_bit(DESTROY_IN_PROGRESS, &ar->flag)) {
 		ath6kl_err("destroy in progress\n");
@@ -575,15 +583,8 @@ static int ath6kl_cfg80211_disconnect(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: reason=%u\n", __func__,
 		   reason_code);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (test_bit(DESTROY_IN_PROGRESS, &ar->flag)) {
 		ath6kl_err("busy, destroy in progress\n");
@@ -781,15 +782,8 @@ static int ath6kl_cfg80211_scan(struct wiphy *wiphy, struct net_device *ndev,
 	int ret = 0;
 	u32 force_fg_scan = 0;
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
-		return -EIO;
-	}
 
 	if (!ar->usr_bss_filter) {
 		if (ath6kl_wmi_bssfilter_cmd(ar->wmi,
@@ -866,15 +860,8 @@ static int ath6kl_cfg80211_add_key(struct wiphy *wiphy, struct net_device *ndev,
 	u8 key_type;
 	int status = 0;
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
 		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
@@ -951,15 +938,8 @@ static int ath6kl_cfg80211_del_key(struct wiphy *wiphy, struct net_device *ndev,
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
 		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
@@ -991,15 +971,8 @@ static int ath6kl_cfg80211_get_key(struct wiphy *wiphy, struct net_device *ndev,
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
 		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
@@ -1033,15 +1006,8 @@ static int ath6kl_cfg80211_set_default_key(struct wiphy *wiphy,
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
 		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
@@ -1081,15 +1047,8 @@ static int ath6kl_cfg80211_set_default_mgmt_key(struct wiphy *wiphy,
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
-		return -EIO;
-	}
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: not supported\n", __func__);
 	return -ENOTSUPP;
@@ -1115,15 +1074,8 @@ static int ath6kl_cfg80211_set_wiphy_params(struct wiphy *wiphy, u32 changed)
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: changed 0x%x\n", __func__,
 		   changed);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (changed & WIPHY_PARAM_RTS_THRESHOLD) {
 		ret = ath6kl_wmi_set_rts_cmd(ar->wmi, wiphy->rts_threshold);
@@ -1150,15 +1102,8 @@ static int ath6kl_cfg80211_set_txpower(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: type 0x%x, dbm %d\n", __func__,
 		   type, dbm);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	switch (type) {
 	case NL80211_TX_POWER_AUTOMATIC:
@@ -1181,15 +1126,8 @@ static int ath6kl_cfg80211_get_txpower(struct wiphy *wiphy, int *dbm)
 {
 	struct ath6kl *ar = (struct ath6kl *)wiphy_priv(wiphy);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (test_bit(CONNECTED, &ar->flag)) {
 		ar->tx_pwr = 0;
@@ -1222,15 +1160,8 @@ static int ath6kl_cfg80211_set_power_mgmt(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: pmgmt %d, timeout %d\n",
 		   __func__, pmgmt, timeout);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (pmgmt) {
 		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: max perf\n", __func__);
@@ -1258,15 +1189,8 @@ static int ath6kl_cfg80211_change_iface(struct wiphy *wiphy,
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: type %u\n", __func__, type);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	switch (type) {
 	case NL80211_IFTYPE_STATION:
@@ -1292,15 +1216,8 @@ static int ath6kl_cfg80211_join_ibss(struct wiphy *wiphy,
 	struct ath6kl *ar = ath6kl_priv(dev);
 	int status;
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	if (!ibss_param->ssid_len ||
 	    IEEE80211_MAX_SSID_LEN < ibss_param->ssid_len) {
@@ -1367,15 +1284,8 @@ static int ath6kl_cfg80211_leave_ibss(struct wiphy *wiphy,
 {
 	struct ath6kl *ar = (struct ath6kl *)ath6kl_priv(dev);
 
-	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("wmi is not ready\n");
-		return -EIO;
-	}
-
-	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("wlan disabled\n");
+	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
-	}
 
 	ath6kl_disconnect(ar);
 	memset(ar->ssid, 0, sizeof(ar->ssid));
-- 
1.7.6.131.g99019

