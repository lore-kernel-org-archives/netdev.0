From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-12-05
Date: Mon, 5 Dec 2011 11:30:32 -0500
Message-ID: <20111205163032.GC2531@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit cbec0627ef1adf7afa448e8bbae3146ce910212a

Dave,

This batch of fixes is intended for 3.2.

Included is an iwlwifi fix to correctly set some flags related to packet
encryption, a couple of cfg80211 regulatory fixes (including one that
patches a hole created by the earlier "cfg80211: fix regulatory NULL
dereference"), a mac80211 fix to avoid sending probe requests with no
supported rates included, an iwlwifi fix to prevent reconfiguring HT40
after an association (prevents an assert in the firmware), and another
iwlwifi fix that customizes the watchdog timer enablement based on the
device type.

Also included is a reversion of a patch that was causing the iwlegacy
driver to throw WARNINGs.

Please let me know if there are problems!

John

---

The following changes since commit f61759e6b831a55b89e584b198c3da325e2bc379:

  ipv4: make sure RTO_ONLINK is saved in routing cache (2011-12-03 01:32:23 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Johannes Berg (1):
      iwlagn: fix HW crypto for TX-only keys

John W. Linville (2):
      Revert "mac80211: clear sta.drv_priv on reconfiguration"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Luis R. Rodriguez (2):
      cfg80211: fix race on init and driver registration
      cfg80211: amend regulatory NULL dereference fix

Simon Wunderlich (1):
      mac80211: fill rate filter for internal scan requests

Wey-Yi Guy (2):
      iwlwifi: do not re-configure HT40 after associated
      iwlwifi: change the default behavior of watchdog timer

 drivers/net/wireless/iwlwifi/iwl-1000.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |   36 ++++++++++++-------
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c  |    5 ---
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   34 +++++++++---------
 drivers/net/wireless/iwlwifi/iwl-agn.h      |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.c     |   22 +++++++++---
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-shared.h   |    4 +-
 net/mac80211/main.c                         |    6 +++
 net/mac80211/util.c                         |    1 -
 net/wireless/reg.c                          |   49 +++++++++++++++++----------
 12 files changed, 102 insertions(+), 61 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index e12b48c..dd008b0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -191,6 +191,7 @@ static struct iwl_base_params iwl1000_base_params = {
 	.chain_noise_scale = 1000,
 	.wd_timeout = IWL_DEF_WD_TIMEOUT,
 	.max_event_log_size = 128,
+	.wd_disable = true,
 };
 static struct iwl_ht_params iwl1000_ht_params = {
 	.ht_greenfield_support = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index c511c98..f55fb2d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -364,6 +364,7 @@ static struct iwl_base_params iwl5000_base_params = {
 	.wd_timeout = IWL_LONG_WD_TIMEOUT,
 	.max_event_log_size = 512,
 	.no_idle_support = true,
+	.wd_disable = true,
 };
 static struct iwl_ht_params iwl5000_ht_params = {
 	.ht_greenfield_support = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index 58a381c..a7a6def 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -528,6 +528,24 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *ctx)
 	return 0;
 }
 
+void iwlagn_config_ht40(struct ieee80211_conf *conf,
+	struct iwl_rxon_context *ctx)
+{
+	if (conf_is_ht40_minus(conf)) {
+		ctx->ht.extension_chan_offset =
+			IEEE80211_HT_PARAM_CHA_SEC_BELOW;
+		ctx->ht.is_40mhz = true;
+	} else if (conf_is_ht40_plus(conf)) {
+		ctx->ht.extension_chan_offset =
+			IEEE80211_HT_PARAM_CHA_SEC_ABOVE;
+		ctx->ht.is_40mhz = true;
+	} else {
+		ctx->ht.extension_chan_offset =
+			IEEE80211_HT_PARAM_CHA_SEC_NONE;
+		ctx->ht.is_40mhz = false;
+	}
+}
+
 int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct iwl_priv *priv = hw->priv;
@@ -586,19 +604,11 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 				ctx->ht.enabled = conf_is_ht(conf);
 
 			if (ctx->ht.enabled) {
-				if (conf_is_ht40_minus(conf)) {
-					ctx->ht.extension_chan_offset =
-						IEEE80211_HT_PARAM_CHA_SEC_BELOW;
-					ctx->ht.is_40mhz = true;
-				} else if (conf_is_ht40_plus(conf)) {
-					ctx->ht.extension_chan_offset =
-						IEEE80211_HT_PARAM_CHA_SEC_ABOVE;
-					ctx->ht.is_40mhz = true;
-				} else {
-					ctx->ht.extension_chan_offset =
-						IEEE80211_HT_PARAM_CHA_SEC_NONE;
-					ctx->ht.is_40mhz = false;
-				}
+				/* if HT40 is used, it should not change
+				 * after associated except channel switch */
+				if (iwl_is_associated_ctx(ctx) &&
+				     !ctx->ht.is_40mhz)
+					iwlagn_config_ht40(conf, ctx);
 			} else
 				ctx->ht.is_40mhz = false;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
index ed62836..4b2aa1d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
@@ -1268,9 +1268,6 @@ int iwl_set_dynamic_key(struct iwl_priv *priv,
 
 	switch (keyconf->cipher) {
 	case WLAN_CIPHER_SUITE_TKIP:
-		keyconf->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
-		keyconf->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
-
 		if (sta)
 			addr = sta->addr;
 		else /* station mode case only */
@@ -1283,8 +1280,6 @@ int iwl_set_dynamic_key(struct iwl_priv *priv,
 					  seq.tkip.iv32, p1k, CMD_SYNC);
 		break;
 	case WLAN_CIPHER_SUITE_CCMP:
-		keyconf->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
-		/* fall through */
 	case WLAN_CIPHER_SUITE_WEP40:
 	case WLAN_CIPHER_SUITE_WEP104:
 		ret = iwlagn_send_sta_key(priv, keyconf, sta_id,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index ccba69b..bacc06c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2316,6 +2316,17 @@ static int iwlagn_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		return -EOPNOTSUPP;
 	}
 
+	switch (key->cipher) {
+	case WLAN_CIPHER_SUITE_TKIP:
+		key->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
+		/* fall through */
+	case WLAN_CIPHER_SUITE_CCMP:
+		key->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
+		break;
+	default:
+		break;
+	}
+
 	/*
 	 * We could program these keys into the hardware as well, but we
 	 * don't expect much multicast traffic in IBSS and having keys
@@ -2599,21 +2610,9 @@ static void iwlagn_mac_channel_switch(struct ieee80211_hw *hw,
 
 	/* Configure HT40 channels */
 	ctx->ht.enabled = conf_is_ht(conf);
-	if (ctx->ht.enabled) {
-		if (conf_is_ht40_minus(conf)) {
-			ctx->ht.extension_chan_offset =
-				IEEE80211_HT_PARAM_CHA_SEC_BELOW;
-			ctx->ht.is_40mhz = true;
-		} else if (conf_is_ht40_plus(conf)) {
-			ctx->ht.extension_chan_offset =
-				IEEE80211_HT_PARAM_CHA_SEC_ABOVE;
-			ctx->ht.is_40mhz = true;
-		} else {
-			ctx->ht.extension_chan_offset =
-				IEEE80211_HT_PARAM_CHA_SEC_NONE;
-			ctx->ht.is_40mhz = false;
-		}
-	} else
+	if (ctx->ht.enabled)
+		iwlagn_config_ht40(conf, ctx);
+	else
 		ctx->ht.is_40mhz = false;
 
 	if ((le16_to_cpu(ctx->staging.channel) != ch))
@@ -3499,9 +3498,10 @@ MODULE_PARM_DESC(plcp_check, "Check plcp health (default: 1 [enabled])");
 module_param_named(ack_check, iwlagn_mod_params.ack_check, bool, S_IRUGO);
 MODULE_PARM_DESC(ack_check, "Check ack health (default: 0 [disabled])");
 
-module_param_named(wd_disable, iwlagn_mod_params.wd_disable, bool, S_IRUGO);
+module_param_named(wd_disable, iwlagn_mod_params.wd_disable, int, S_IRUGO);
 MODULE_PARM_DESC(wd_disable,
-		"Disable stuck queue watchdog timer (default: 0 [enabled])");
+		"Disable stuck queue watchdog timer 0=system default, "
+		"1=disable, 2=enable (default: 0)");
 
 /*
  * set bt_coex_active to true, uCode will do kill/defer
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.h b/drivers/net/wireless/iwlwifi/iwl-agn.h
index 5b936ec..3856aba 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.h
@@ -86,6 +86,8 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
 			     struct ieee80211_vif *vif,
 			     struct ieee80211_bss_conf *bss_conf,
 			     u32 changes);
+void iwlagn_config_ht40(struct ieee80211_conf *conf,
+			struct iwl_rxon_context *ctx);
 
 /* uCode */
 int iwlagn_rx_calib_result(struct iwl_priv *priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 001fdf1..fcf5416 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1810,11 +1810,23 @@ void iwl_setup_watchdog(struct iwl_priv *priv)
 {
 	unsigned int timeout = priv->cfg->base_params->wd_timeout;
 
-	if (timeout && !iwlagn_mod_params.wd_disable)
-		mod_timer(&priv->watchdog,
-			  jiffies + msecs_to_jiffies(IWL_WD_TICK(timeout)));
-	else
-		del_timer(&priv->watchdog);
+	if (!iwlagn_mod_params.wd_disable) {
+		/* use system default */
+		if (timeout && !priv->cfg->base_params->wd_disable)
+			mod_timer(&priv->watchdog,
+				jiffies +
+				msecs_to_jiffies(IWL_WD_TICK(timeout)));
+		else
+			del_timer(&priv->watchdog);
+	} else {
+		/* module parameter overwrite default configuration */
+		if (timeout && iwlagn_mod_params.wd_disable == 2)
+			mod_timer(&priv->watchdog,
+				jiffies +
+				msecs_to_jiffies(IWL_WD_TICK(timeout)));
+		else
+			del_timer(&priv->watchdog);
+	}
 }
 
 /**
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 137da33..f2fc288 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -113,6 +113,7 @@ struct iwl_lib_ops {
  * @shadow_reg_enable: HW shadhow register bit
  * @no_idle_support: do not support idle mode
  * @hd_v2: v2 of enhanced sensitivity value, used for 2000 series and up
+ * wd_disable: disable watchdog timer
  */
 struct iwl_base_params {
 	int eeprom_size;
@@ -134,6 +135,7 @@ struct iwl_base_params {
 	const bool shadow_reg_enable;
 	const bool no_idle_support;
 	const bool hd_v2;
+	const bool wd_disable;
 };
 /*
  * @advanced_bt_coexist: support advanced bt coexist
diff --git a/drivers/net/wireless/iwlwifi/iwl-shared.h b/drivers/net/wireless/iwlwifi/iwl-shared.h
index 1f7a93c..14eaf37 100644
--- a/drivers/net/wireless/iwlwifi/iwl-shared.h
+++ b/drivers/net/wireless/iwlwifi/iwl-shared.h
@@ -120,7 +120,7 @@ extern struct iwl_mod_params iwlagn_mod_params;
  * @restart_fw: restart firmware, default = 1
  * @plcp_check: enable plcp health check, default = true
  * @ack_check: disable ack health check, default = false
- * @wd_disable: enable stuck queue check, default = false
+ * @wd_disable: enable stuck queue check, default = 0
  * @bt_coex_active: enable bt coex, default = true
  * @led_mode: system default, default = 0
  * @no_sleep_autoadjust: disable autoadjust, default = true
@@ -141,7 +141,7 @@ struct iwl_mod_params {
 	int restart_fw;
 	bool plcp_check;
 	bool ack_check;
-	bool wd_disable;
+	int  wd_disable;
 	bool bt_coex_active;
 	int led_mode;
 	bool no_sleep_autoadjust;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index d999bf3..cae4435 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -757,6 +757,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	if (!local->int_scan_req)
 		return -ENOMEM;
 
+	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
+		if (!local->hw.wiphy->bands[band])
+			continue;
+		local->int_scan_req->rates[band] = (u32) -1;
+	}
+
 	/* if low-level driver supports AP, we also support VLAN */
 	if (local->hw.wiphy->interface_modes & BIT(NL80211_IFTYPE_AP)) {
 		hw->wiphy->interface_modes |= BIT(NL80211_IFTYPE_AP_VLAN);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index eca0fad..d5230ec 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1039,7 +1039,6 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 					     struct ieee80211_sub_if_data,
 					     u.ap);
 
-			memset(&sta->sta.drv_priv, 0, hw->sta_data_size);
 			WARN_ON(drv_sta_add(local, sdata, &sta->sta));
 		}
 	}
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 77e9267..3302c56 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -57,8 +57,17 @@
 #define REG_DBG_PRINT(args...)
 #endif
 
+static struct regulatory_request core_request_world = {
+	.initiator = NL80211_REGDOM_SET_BY_CORE,
+	.alpha2[0] = '0',
+	.alpha2[1] = '0',
+	.intersect = false,
+	.processed = true,
+	.country_ie_env = ENVIRON_ANY,
+};
+
 /* Receipt of information from last regulatory request */
-static struct regulatory_request *last_request;
+static struct regulatory_request *last_request = &core_request_world;
 
 /* To trigger userspace events */
 static struct platform_device *reg_pdev;
@@ -150,7 +159,7 @@ static char user_alpha2[2];
 module_param(ieee80211_regdom, charp, 0444);
 MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain code");
 
-static void reset_regdomains(void)
+static void reset_regdomains(bool full_reset)
 {
 	/* avoid freeing static information or freeing something twice */
 	if (cfg80211_regdomain == cfg80211_world_regdom)
@@ -165,6 +174,13 @@ static void reset_regdomains(void)
 
 	cfg80211_world_regdom = &world_regdom;
 	cfg80211_regdomain = NULL;
+
+	if (!full_reset)
+		return;
+
+	if (last_request != &core_request_world)
+		kfree(last_request);
+	last_request = &core_request_world;
 }
 
 /*
@@ -175,7 +191,7 @@ static void update_world_regdomain(const struct ieee80211_regdomain *rd)
 {
 	BUG_ON(!last_request);
 
-	reset_regdomains();
+	reset_regdomains(false);
 
 	cfg80211_world_regdom = rd;
 	cfg80211_regdomain = rd;
@@ -1407,7 +1423,8 @@ static int __regulatory_hint(struct wiphy *wiphy,
 	}
 
 new_request:
-	kfree(last_request);
+	if (last_request != &core_request_world)
+		kfree(last_request);
 
 	last_request = pending_request;
 	last_request->intersect = intersect;
@@ -1577,9 +1594,6 @@ static int regulatory_hint_core(const char *alpha2)
 {
 	struct regulatory_request *request;
 
-	kfree(last_request);
-	last_request = NULL;
-
 	request = kzalloc(sizeof(struct regulatory_request),
 			  GFP_KERNEL);
 	if (!request)
@@ -1777,7 +1791,7 @@ static void restore_regulatory_settings(bool reset_user)
 	mutex_lock(&cfg80211_mutex);
 	mutex_lock(&reg_mutex);
 
-	reset_regdomains();
+	reset_regdomains(true);
 	restore_alpha2(alpha2, reset_user);
 
 	/*
@@ -2037,8 +2051,10 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 	}
 
 	request_wiphy = wiphy_idx_to_wiphy(last_request->wiphy_idx);
-	if (!request_wiphy) {
-		reg_set_request_processed();
+	if (!request_wiphy &&
+	    (last_request->initiator == NL80211_REGDOM_SET_BY_DRIVER ||
+	     last_request->initiator == NL80211_REGDOM_SET_BY_COUNTRY_IE)) {
+		schedule_delayed_work(&reg_timeout, 0);
 		return -ENODEV;
 	}
 
@@ -2046,7 +2062,7 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 		int r;
 
 		if (last_request->initiator != NL80211_REGDOM_SET_BY_DRIVER) {
-			reset_regdomains();
+			reset_regdomains(false);
 			cfg80211_regdomain = rd;
 			return 0;
 		}
@@ -2067,7 +2083,7 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 		if (r)
 			return r;
 
-		reset_regdomains();
+		reset_regdomains(false);
 		cfg80211_regdomain = rd;
 		return 0;
 	}
@@ -2092,7 +2108,7 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 
 		rd = NULL;
 
-		reset_regdomains();
+		reset_regdomains(false);
 		cfg80211_regdomain = intersected_rd;
 
 		return 0;
@@ -2112,7 +2128,7 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 	kfree(rd);
 	rd = NULL;
 
-	reset_regdomains();
+	reset_regdomains(false);
 	cfg80211_regdomain = intersected_rd;
 
 	return 0;
@@ -2265,11 +2281,8 @@ void /* __init_or_exit */ regulatory_exit(void)
 	mutex_lock(&cfg80211_mutex);
 	mutex_lock(&reg_mutex);
 
-	reset_regdomains();
-
-	kfree(last_request);
+	reset_regdomains(true);
 
-	last_request = NULL;
 	dev_set_uevent_suppress(&reg_pdev->dev, true);
 
 	platform_device_unregister(reg_pdev);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
