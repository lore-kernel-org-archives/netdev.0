From: Cedric DEBARGE <cedric.debarge@acksys.fr>
Subject: [RFC 1/2] cfg80211: add support for ht_caps mcs rxmask override
Date: Fri,  5 Feb 2016 16:41:59 +0100
Message-ID: <790ecd44db382115b7af01bf89d72500c4de1741.1454685673.git.cedric.debarge@acksys.fr>
References: <cover.1454685673.git.cedric.debarge@acksys.fr>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Cedric DEBARGE <cedric.debarge@acksys.fr>
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out05.msg.oleane.net ([62.161.7.3]:38412 "EHLO
	smtp-out05.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbcBESbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 13:31:07 -0500
In-Reply-To: <cover.1454685673.git.cedric.debarge@acksys.fr>
In-Reply-To: <cover.1454685673.git.cedric.debarge@acksys.fr>
References: <cover.1454685673.git.cedric.debarge@acksys.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows the ht_caps mcs rxmask to be defined on the fly.
In this implementation, the given rxmask is applied to
every band available.
This is only applicable for radio cards without internal rc.

Signed-off-by: Cedric Debarge <cedric.debarge@acksys.fr>
---
 include/net/cfg80211.h |  7 +++++++
 net/mac80211/cfg.c     | 48 +++++++++++++++++++++++++++++++++++++++++++++
 net/mac80211/main.c    | 53 ++++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 100 insertions(+), 8 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 9e1b24c..257404b 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2500,6 +2500,8 @@ struct cfg80211_qos_map {
  *	and returning to the base channel for communication with the AP.
  * @tdls_cancel_channel_switch: Stop channel-switching with a TDLS peer. Both
  *	peers must be on the base channel when the call completes.
+ *
+ * @set_htcap_rxmask: Override hardware capabilities for ht_caps mcs rxmask.
  */
 struct cfg80211_ops {
 	int	(*suspend)(struct wiphy *wiphy, struct cfg80211_wowlan *wow);
@@ -2765,6 +2767,8 @@ struct cfg80211_ops {
 	void	(*tdls_cancel_channel_switch)(struct wiphy *wiphy,
 					      struct net_device *dev,
 					      const u8 *addr);
+
+	int (*set_htcap_rxmask)(struct wiphy *wiphy, uint8_t *rxmask);
 };
 
 /*
@@ -3121,6 +3125,8 @@ struct wiphy_vendor_command {
  *	wiphy is theirs, e.g. in global notifiers
  * @bands: information about bands/channels supported by this device
  *
+ * @init_bands: save of the originals information about bands.
+ *
  * @mgmt_stypes: bitmasks of frame subtypes that can be subscribed to or
  *	transmitted through nl80211, points to an array indexed by interface
  *	type
@@ -3266,6 +3272,7 @@ struct wiphy {
 	const void *privid;
 
 	struct ieee80211_supported_band *bands[IEEE80211_NUM_BANDS];
+	struct ieee80211_supported_band *init_bands[IEEE80211_NUM_BANDS];
 
 	/* Lets us get back the wiphy on the callback */
 	void (*reg_notifier)(struct wiphy *wiphy,
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 66d22de..daa415b 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -3350,6 +3350,53 @@ static int ieee80211_del_tx_ts(struct wiphy *wiphy, struct net_device *dev,
 	return -ENOENT;
 }
 
+static int ieee80211_set_htcap_rxmask(struct wiphy *wiphy, uint8_t *rxmask)
+{
+	struct ieee80211_local *local = wiphy_priv(wiphy);
+	struct ieee80211_supported_band *sband;
+	struct ieee80211_supported_band *iband;
+	int blank = 1;
+	int empty;
+	int i;
+
+	if (ieee80211_hw_check(&local->hw, HAS_RATE_CONTROL))
+		return -EINVAL;
+
+	mutex_lock(&local->iflist_mtx);
+	empty = list_empty(&local->interfaces);
+	mutex_unlock(&local->iflist_mtx);
+
+	if (!empty)
+		return -EBUSY;
+
+	for (i = 0; i < IEEE80211_HT_MCS_MASK_LEN; i++)
+		if (rxmask[i]) {
+			blank = 0;
+			break;
+		}
+
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
+		int j;
+
+		sband = wiphy->bands[i];
+		iband = wiphy->init_bands[i];
+
+		if (!iband)
+			continue;
+
+		for (j = 0; j < IEEE80211_HT_MCS_MASK_LEN; j++) {
+			if (blank)
+				sband->ht_cap.mcs.rx_mask[j] =
+						iband->ht_cap.mcs.rx_mask[j];
+			else
+				sband->ht_cap.mcs.rx_mask[j] = rxmask[j] &
+						iband->ht_cap.mcs.rx_mask[j];
+		}
+	}
+
+	return 0;
+}
+
 const struct cfg80211_ops mac80211_config_ops = {
 	.add_virtual_intf = ieee80211_add_iface,
 	.del_virtual_intf = ieee80211_del_iface,
@@ -3435,4 +3482,5 @@ const struct cfg80211_ops mac80211_config_ops = {
 	.set_ap_chanwidth = ieee80211_set_ap_chanwidth,
 	.add_tx_ts = ieee80211_add_tx_ts,
 	.del_tx_ts = ieee80211_del_tx_ts,
+	.set_htcap_rxmask = ieee80211_set_htcap_rxmask,
 };
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 6bcf0fa..138f1e4 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -789,15 +789,37 @@ static int ieee80211_init_cipher_suites(struct ieee80211_local *local)
 	return 0;
 }
 
+static int ieee80211_alloc_init_bands(struct wiphy *wiphy)
+{
+	int i;
+
+	memset(wiphy->init_bands, 0, IEEE80211_NUM_BANDS);
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
+		if (!wiphy->bands[i])
+			continue;
+
+		wiphy->init_bands[i] = kzalloc(sizeof(*wiphy->init_bands[i]),
+					       GFP_KERNEL);
+		if (!wiphy->init_bands[i])
+			return -ENOMEM;
+
+		memcpy(wiphy->init_bands[i], wiphy->bands[i],
+		       sizeof(struct ieee80211_supported_band));
+	}
+
+	return 0;
+}
+
 int ieee80211_register_hw(struct ieee80211_hw *hw)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
-	int result, i;
-	enum ieee80211_band band;
+	struct cfg80211_chan_def dflt_chandef = {};
+	netdev_features_t feature_whitelist;
 	int channels, max_bitrates;
+	enum ieee80211_band band;
 	bool supp_ht, supp_vht;
-	netdev_features_t feature_whitelist;
-	struct cfg80211_chan_def dflt_chandef = {};
+	int result = 0;
+	int i;
 
 	if (ieee80211_hw_check(hw, QUEUE_CONTROL) &&
 	    (local->hw.offchannel_tx_hw_queue == IEEE80211_INVAL_HW_QUEUE ||
@@ -857,6 +879,11 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	local->rx_chains = 1;
 
+	if (ieee80211_alloc_init_bands(hw->wiphy)) {
+		result = -ENOMEM;
+		goto fail_sband_init;
+	}
+
 	/*
 	 * generic code guarantees at least one band,
 	 * set this very early because much code assumes
@@ -919,14 +946,18 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 		for (j = 0; j < c->n_limits; j++)
 			if ((c->limits[j].types & BIT(NL80211_IFTYPE_ADHOC)) &&
-			    c->limits[j].max > 1)
-				return -EINVAL;
+			    c->limits[j].max > 1) {
+				result = -EINVAL;
+				goto fail_sband_init;
+			}
 	}
 
 	local->int_scan_req = kzalloc(sizeof(*local->int_scan_req) +
 				      sizeof(void *) * channels, GFP_KERNEL);
-	if (!local->int_scan_req)
-		return -ENOMEM;
+	if (!local->int_scan_req) {
+		result = -ENOMEM;
+		goto fail_sband_init;
+	}
 
 	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
 		if (!local->hw.wiphy->bands[band])
@@ -1120,6 +1151,9 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	if (local->wiphy_ciphers_allocated)
 		kfree(local->hw.wiphy->cipher_suites);
 	kfree(local->int_scan_req);
+ fail_sband_init:
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++)
+		kfree(hw->wiphy->init_bands[i]);
 	return result;
 }
 EXPORT_SYMBOL(ieee80211_register_hw);
@@ -1127,6 +1161,7 @@ EXPORT_SYMBOL(ieee80211_register_hw);
 void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
+	int i;
 
 	tasklet_kill(&local->tx_pending_tasklet);
 	tasklet_kill(&local->tasklet);
@@ -1170,6 +1205,8 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 	ieee80211_wep_free(local);
 	ieee80211_led_exit(local);
 	kfree(local->int_scan_req);
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++)
+		kfree(hw->wiphy->init_bands[i]);
 }
 EXPORT_SYMBOL(ieee80211_unregister_hw);
 
-- 
1.9.1
