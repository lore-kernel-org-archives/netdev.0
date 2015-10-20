From: greearb@candelatech.com
Subject: [PATCH-v2 1/2] mac80211: Take bitrates into account when building IEs.
Date: Tue, 20 Oct 2015 10:22:29 -0700
Message-ID: <1445361750-24707-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58207 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbJTRWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 13:22:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

If a user restricts the rateset for some reason, then the
probe requests should not advertise rates that are not
selected by the user.

To implement this, we save the requested bitrates at
the mac80211 level and take it into account when building
the IEs.

This allows one to create a more realistic /b mode
station on modern hardware, for instance.  Good for
testing, and likely good for other things as well.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
v2:  Only save rates when given explicit flag from user-space.

 drivers/net/wireless/ath/ath6kl/cfg80211.c |  3 +-
 drivers/net/wireless/mwifiex/cfg80211.c    |  3 +-
 include/net/cfg80211.h                     |  3 +-
 include/net/mac80211.h                     |  4 ++
 include/uapi/linux/nl80211.h               |  2 +
 net/mac80211/cfg.c                         |  9 ++-
 net/mac80211/ieee80211_i.h                 | 18 +++++-
 net/mac80211/scan.c                        | 26 +++++++-
 net/mac80211/util.c                        | 97 +++++++++++++++++++++++++++---
 net/wireless/nl80211.c                     |  5 +-
 net/wireless/rdev-ops.h                    |  6 +-
 net/wireless/wext-compat.c                 |  2 +-
 12 files changed, 160 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index a511ef3..5b3d79e 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -3354,7 +3354,8 @@ static int ath6kl_cfg80211_sscan_stop(struct wiphy *wiphy,
 static int ath6kl_cfg80211_set_bitrate(struct wiphy *wiphy,
 				       struct net_device *dev,
 				       const u8 *addr,
-				       const struct cfg80211_bitrate_mask *mask)
+				       const struct cfg80211_bitrate_mask *mask,
+				       bool is_advert_mask)
 {
 	struct ath6kl *ar = ath6kl_priv(dev);
 	struct ath6kl_vif *vif = netdev_priv(dev);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index b15e4c7..7888916 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1542,7 +1542,8 @@ mwifiex_mgmt_stypes[NUM_NL80211_IFTYPES] = {
 static int mwifiex_cfg80211_set_bitrate_mask(struct wiphy *wiphy,
 				struct net_device *dev,
 				const u8 *peer,
-				const struct cfg80211_bitrate_mask *mask)
+				const struct cfg80211_bitrate_mask *mask,
+				bool is_advert_mask)
 {
 	struct mwifiex_private *priv = mwifiex_netdev_get_priv(dev);
 	u16 bitmap_rates[MAX_BITMAP_RATES_SIZE];
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 038de33..0804268 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2594,7 +2594,8 @@ struct cfg80211_ops {
 	int	(*set_bitrate_mask)(struct wiphy *wiphy,
 				    struct net_device *dev,
 				    const u8 *peer,
-				    const struct cfg80211_bitrate_mask *mask);
+				    const struct cfg80211_bitrate_mask *mask,
+				    bool is_advert_bitmask);
 
 	int	(*dump_survey)(struct wiphy *wiphy, struct net_device *netdev,
 			int idx, struct survey_info *info);
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 6b1077c..970372d 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -2073,10 +2073,14 @@ static inline void _ieee80211_hw_set(struct ieee80211_hw *hw,
  * struct ieee80211_scan_request - hw scan request
  *
  * @ies: pointers different parts of IEs (in req.ie)
+ * @disable_ht: Ensure nothing related to HT is in the probe request
+ * @disable_vht: Ensure nothing related to VHT is in the probe request
  * @req: cfg80211 request.
  */
 struct ieee80211_scan_request {
 	struct ieee80211_scan_ies ies;
+	bool disable_ht[IEEE80211_NUM_BANDS];
+	bool disable_vht[IEEE80211_NUM_BANDS];
 
 	/* Keep last */
 	struct cfg80211_scan_request req;
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index c0ab6b0..4573f87 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -2130,6 +2130,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_REG_INDOOR,
 
+	NL80211_ATTR_TX_ADVERT_RATEMASK,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index bf7023f..0c0c5cf 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2457,12 +2457,19 @@ static int ieee80211_set_cqm_rssi_config(struct wiphy *wiphy,
 static int ieee80211_set_bitrate_mask(struct wiphy *wiphy,
 				      struct net_device *dev,
 				      const u8 *addr,
-				      const struct cfg80211_bitrate_mask *mask)
+				      const struct cfg80211_bitrate_mask *mask,
+				      bool is_advert_bitmask)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	int i, ret;
 
+	if (is_advert_bitmask) {
+		memcpy(&sdata->cfg_advert_bitrate_mask, mask, sizeof(*mask));
+		sdata->cfg_advert_bitrate_mask_set = true;
+		return 0;
+	}
+
 	if (!ieee80211_sdata_running(sdata))
 		return -ENETDOWN;
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index b15559c..5e43e99 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -904,6 +904,13 @@ struct ieee80211_sub_if_data {
 	bool rc_has_mcs_mask[IEEE80211_NUM_BANDS];
 	u8  rc_rateidx_mcs_mask[IEEE80211_NUM_BANDS][IEEE80211_HT_MCS_MASK_LEN];
 
+	/* Store bitrate mask configured from user-space.  This is for
+	 * rates that should be advertised in probe requests, etc.  This
+	 * is NOT directly related to the tx-rate-ctrl logic configuration.
+	 */
+	struct cfg80211_bitrate_mask cfg_advert_bitrate_mask;
+	bool cfg_advert_bitrate_mask_set; /* Has user set the mask? */
+
 	union {
 		struct ieee80211_if_ap ap;
 		struct ieee80211_if_wds wds;
@@ -1549,6 +1556,14 @@ int ieee80211_mesh_csa_beacon(struct ieee80211_sub_if_data *sdata,
 int ieee80211_mesh_finish_csa(struct ieee80211_sub_if_data *sdata);
 
 /* scan/BSS handling */
+void ieee80211_check_disabled_rates(struct ieee80211_sub_if_data *sdata,
+				    bool *disable_ht,
+				    bool *disable_vht);
+void ieee80211_check_all_rates_disabled(u8 bands_used,
+					bool *disable_ht_cfg,
+					bool *disable_vht_cfg,
+					bool *disable_ht,
+					bool *disable_vht);
 void ieee80211_scan_work(struct work_struct *work);
 int ieee80211_request_ibss_scan(struct ieee80211_sub_if_data *sdata,
 				const u8 *ssid, u8 ssid_len,
@@ -1937,7 +1952,8 @@ int ieee80211_build_preq_ies(struct ieee80211_local *local, u8 *buffer,
 			     struct ieee80211_scan_ies *ie_desc,
 			     const u8 *ie, size_t ie_len,
 			     u8 bands_used, u32 *rate_masks,
-			     struct cfg80211_chan_def *chandef);
+			     struct cfg80211_chan_def *chandef,
+			     bool disable_ht, bool disable_vht);
 struct sk_buff *ieee80211_build_probe_req(struct ieee80211_sub_if_data *sdata,
 					  const u8 *src, const u8 *dst,
 					  u32 ratemask,
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 6e857d1..6ff1138 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -262,6 +262,8 @@ static bool ieee80211_prep_hw_scan(struct ieee80211_local *local)
 	struct cfg80211_chan_def chandef;
 	u8 bands_used = 0;
 	int i, ielen, n_chans;
+	bool disable_ht;
+	bool disable_vht;
 
 	req = rcu_dereference_protected(local->scan_req,
 					lockdep_is_held(&local->mtx));
@@ -297,6 +299,11 @@ static bool ieee80211_prep_hw_scan(struct ieee80211_local *local)
 		} while (!n_chans);
 	}
 
+	ieee80211_check_all_rates_disabled(bands_used,
+					   local->hw_scan_req->disable_ht,
+					   local->hw_scan_req->disable_vht,
+					   &disable_ht, &disable_vht);
+
 	local->hw_scan_req->req.n_channels = n_chans;
 	ieee80211_prepare_scan_chandef(&chandef, req->scan_width);
 
@@ -305,7 +312,8 @@ static bool ieee80211_prep_hw_scan(struct ieee80211_local *local)
 					 local->hw_scan_ies_bufsize,
 					 &local->hw_scan_req->ies,
 					 req->ie, req->ie_len,
-					 bands_used, req->rates, &chandef);
+					 bands_used, req->rates, &chandef,
+					 disable_ht, disable_vht);
 	local->hw_scan_req->req.ie_len = ielen;
 	local->hw_scan_req->req.no_cck = req->no_cck;
 	ether_addr_copy(local->hw_scan_req->req.mac_addr, req->mac_addr);
@@ -563,6 +571,10 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 
 		local->hw_scan_band = 0;
 
+		ieee80211_check_disabled_rates(sdata,
+					       local->hw_scan_req->disable_ht,
+					       local->hw_scan_req->disable_vht);
+
 		/*
 		 * After allocating local->hw_scan_req, we must
 		 * go through until ieee80211_prep_hw_scan(), so
@@ -1079,6 +1091,10 @@ int __ieee80211_request_sched_scan_start(struct ieee80211_sub_if_data *sdata,
 	struct cfg80211_chan_def chandef;
 	int ret, i, iebufsz, num_bands = 0;
 	u32 rate_masks[IEEE80211_NUM_BANDS] = {};
+	bool disable_ht_cfg[IEEE80211_NUM_BANDS];
+	bool disable_vht_cfg[IEEE80211_NUM_BANDS];
+	bool disable_ht;
+	bool disable_vht;
 	u8 bands_used = 0;
 	u8 *ie;
 	size_t len;
@@ -1106,10 +1122,16 @@ int __ieee80211_request_sched_scan_start(struct ieee80211_sub_if_data *sdata,
 
 	ieee80211_prepare_scan_chandef(&chandef, req->scan_width);
 
+	ieee80211_check_disabled_rates(sdata, disable_ht_cfg, disable_vht_cfg);
+	ieee80211_check_all_rates_disabled(bands_used, disable_ht_cfg,
+					   disable_vht_cfg,
+					   &disable_ht, &disable_vht);
+
 	len = ieee80211_build_preq_ies(local, ie, num_bands * iebufsz,
 				       &sched_scan_ies, req->ie,
 				       req->ie_len, bands_used,
-				       rate_masks, &chandef);
+				       rate_masks, &chandef, disable_ht,
+				       disable_vht);
 
 	ret = drv_sched_scan_start(local, sdata, req, &sched_scan_ies);
 	if (ret == 0) {
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index b75925a..2ac75d6 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -47,6 +47,72 @@ struct ieee80211_hw *wiphy_to_ieee80211_hw(struct wiphy *wiphy)
 }
 EXPORT_SYMBOL(wiphy_to_ieee80211_hw);
 
+/**
+ * ieee80211_check_disabled_rates: Calculate which rate-sets are disabled
+ *    in all bands.
+ * @disable_ht_cfg  Holds array of enable/disable values for each band.
+ * @disable_vht_cfg  Holds array of enable/disable values for each band.
+ * @disable_ht  Return value:  is HT disabled for all bands.
+ * @disable_vht  Return value:  is VHT disabled for all bands.
+ */
+void ieee80211_check_all_rates_disabled(u8 bands_used,
+					bool *disable_ht_cfg,
+					bool *disable_vht_cfg,
+					bool *disable_ht,
+					bool *disable_vht)
+{
+	int i;
+
+	*disable_ht = true;
+	*disable_vht = true;
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
+		if (bands_used & (1 << i)) {
+			if (!disable_ht_cfg[i])
+				*disable_ht = false;
+			if (!disable_vht_cfg[i])
+				*disable_vht = false;
+		}
+	}
+}
+
+/**
+ * ieee80211_check_disabled_rates: Calculate which bands have zero rates
+ *  configured for HT and VHT.
+ * @disable_ht  Holds return value, array of length IEEE80211_NUM_BANDS.
+ * @disable_vht  Holds return value, array of length IEEE80211_NUM_BANDS.
+ */
+void ieee80211_check_disabled_rates(struct ieee80211_sub_if_data *sdata,
+				    bool *disable_ht,
+				    bool *disable_vht)
+{
+	int i;
+	int j;
+
+	/* Disable HT, VHT where we have no rates set. */
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
+		disable_ht[i] = false;
+		disable_vht[i] = false;
+		if (!sdata->cfg_advert_bitrate_mask_set)
+			break;
+
+		disable_ht[i] = true;
+		disable_vht[i] = true;
+		for (j = 0; j < IEEE80211_HT_MCS_MASK_LEN; j++) {
+			if (sdata->cfg_advert_bitrate_mask.control[i].ht_mcs[j]) {
+				disable_ht[i] = false;
+				break;
+			}
+		}
+
+		for (j = 0; j < NL80211_VHT_NSS_MAX; j++) {
+			if (sdata->cfg_advert_bitrate_mask.control[i].vht_mcs[j]) {
+				disable_vht[i] = false;
+				break;
+			}
+		}
+	}
+}
+
 u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len,
 			enum nl80211_iftype type)
 {
@@ -1414,7 +1480,8 @@ static int ieee80211_build_preq_ies_band(struct ieee80211_local *local,
 					 enum ieee80211_band band,
 					 u32 rate_mask,
 					 struct cfg80211_chan_def *chandef,
-					 size_t *offset)
+					 size_t *offset, bool disable_ht,
+					 bool disable_vht)
 {
 	struct ieee80211_supported_band *sband;
 	u8 *pos = buffer, *end = buffer + buffer_len;
@@ -1514,7 +1581,7 @@ static int ieee80211_build_preq_ies_band(struct ieee80211_local *local,
 		*offset = noffset;
 	}
 
-	if (sband->ht_cap.ht_supported) {
+	if (sband->ht_cap.ht_supported && !disable_ht) {
 		if (end - pos < 2 + sizeof(struct ieee80211_ht_cap))
 			goto out_err;
 		pos = ieee80211_ie_build_ht_cap(pos, &sband->ht_cap,
@@ -1564,7 +1631,7 @@ static int ieee80211_build_preq_ies_band(struct ieee80211_local *local,
 		break;
 	}
 
-	if (sband->vht_cap.vht_supported && have_80mhz) {
+	if (sband->vht_cap.vht_supported && have_80mhz && !disable_vht) {
 		if (end - pos < 2 + sizeof(struct ieee80211_vht_cap))
 			goto out_err;
 		pos = ieee80211_ie_build_vht_cap(pos, &sband->vht_cap,
@@ -1582,7 +1649,8 @@ int ieee80211_build_preq_ies(struct ieee80211_local *local, u8 *buffer,
 			     struct ieee80211_scan_ies *ie_desc,
 			     const u8 *ie, size_t ie_len,
 			     u8 bands_used, u32 *rate_masks,
-			     struct cfg80211_chan_def *chandef)
+			     struct cfg80211_chan_def *chandef,
+			     bool disable_ht, bool disable_vht)
 {
 	size_t pos = 0, old_pos = 0, custom_ie_offset = 0;
 	int i;
@@ -1597,7 +1665,9 @@ int ieee80211_build_preq_ies(struct ieee80211_local *local, u8 *buffer,
 							     ie, ie_len, i,
 							     rate_masks[i],
 							     chandef,
-							     &custom_ie_offset);
+							     &custom_ie_offset,
+							     disable_ht,
+							     disable_vht);
 			ie_desc->ies[i] = buffer + old_pos;
 			ie_desc->len[i] = pos - old_pos;
 			old_pos = pos;
@@ -1633,6 +1703,11 @@ struct sk_buff *ieee80211_build_probe_req(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_mgmt *mgmt;
 	int ies_len;
 	u32 rate_masks[IEEE80211_NUM_BANDS] = {};
+	bool disable_ht_cfg[IEEE80211_NUM_BANDS];
+	bool disable_vht_cfg[IEEE80211_NUM_BANDS];
+	bool disable_ht;
+	bool disable_vht;
+	u8 bands_used;
 	struct ieee80211_scan_ies dummy_ie_desc;
 
 	/*
@@ -1652,10 +1727,18 @@ struct sk_buff *ieee80211_build_probe_req(struct ieee80211_sub_if_data *sdata,
 		return NULL;
 
 	rate_masks[chan->band] = ratemask;
+	bands_used = BIT(chan->band);
+
+	ieee80211_check_disabled_rates(sdata, disable_ht_cfg, disable_vht_cfg);
+	ieee80211_check_all_rates_disabled(bands_used, disable_ht_cfg,
+					   disable_vht_cfg,
+					   &disable_ht, &disable_vht);
+
 	ies_len = ieee80211_build_preq_ies(local, skb_tail_pointer(skb),
 					   skb_tailroom(skb), &dummy_ie_desc,
-					   ie, ie_len, BIT(chan->band),
-					   rate_masks, &chandef);
+					   ie, ie_len, bands_used,
+					   rate_masks, &chandef, disable_ht,
+					   disable_vht);
 	skb_put(skb, ies_len);
 
 	if (dst) {
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 24fac43..7b0a82b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -400,6 +400,7 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 	[NL80211_ATTR_NETNS_FD] = { .type = NLA_U32 },
 	[NL80211_ATTR_SCHED_SCAN_DELAY] = { .type = NLA_U32 },
 	[NL80211_ATTR_REG_INDOOR] = { .type = NLA_FLAG },
+	[NL80211_ATTR_TX_ADVERT_RATEMASK] = { .type = NLA_FLAG },
 };
 
 /* policy for the key attributes */
@@ -8284,6 +8285,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 	struct nlattr *tx_rates;
 	struct ieee80211_supported_band *sband;
 	u16 vht_tx_mcs_map;
+	bool is_advert_mask;
 
 	if (!rdev->ops->set_bitrate_mask)
 		return -EOPNOTSUPP;
@@ -8312,6 +8314,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 	if (!info->attrs[NL80211_ATTR_TX_RATES])
 		goto out;
 
+	is_advert_mask = nla_get_flag(info->attrs[NL80211_ATTR_TX_ADVERT_RATEMASK]);
 	/*
 	 * The nested attribute uses enum nl80211_band as the index. This maps
 	 * directly to the enum ieee80211_band values used in cfg80211.
@@ -8404,7 +8407,7 @@ static int nl80211_set_tx_bitrate_mask(struct sk_buff *skb,
 	}
 
 out:
-	return rdev_set_bitrate_mask(rdev, dev, NULL, &mask);
+	return rdev_set_bitrate_mask(rdev, dev, NULL, &mask, is_advert_mask);
 }
 
 static int nl80211_register_mgmt(struct sk_buff *skb, struct genl_info *info)
diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
index c6e83a7..2531881 100644
--- a/net/wireless/rdev-ops.h
+++ b/net/wireless/rdev-ops.h
@@ -590,11 +590,13 @@ static inline int rdev_testmode_dump(struct cfg80211_registered_device *rdev,
 static inline int
 rdev_set_bitrate_mask(struct cfg80211_registered_device *rdev,
 		      struct net_device *dev, const u8 *peer,
-		      const struct cfg80211_bitrate_mask *mask)
+		      const struct cfg80211_bitrate_mask *mask,
+		      bool is_advert_mask)
 {
 	int ret;
 	trace_rdev_set_bitrate_mask(&rdev->wiphy, dev, peer, mask);
-	ret = rdev->ops->set_bitrate_mask(&rdev->wiphy, dev, peer, mask);
+	ret = rdev->ops->set_bitrate_mask(&rdev->wiphy, dev, peer, mask,
+					  is_advert_mask);
 	trace_rdev_return_int(&rdev->wiphy, ret);
 	return ret;
 }
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index fd68283..7874f4f 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -1266,7 +1266,7 @@ static int cfg80211_wext_siwrate(struct net_device *dev,
 	if (!match)
 		return -EINVAL;
 
-	return rdev_set_bitrate_mask(rdev, dev, NULL, &mask);
+	return rdev_set_bitrate_mask(rdev, dev, NULL, &mask, false);
 }
 
 static int cfg80211_wext_giwrate(struct net_device *dev,
-- 
2.4.3
