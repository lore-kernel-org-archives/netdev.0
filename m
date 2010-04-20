From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-04-20
Date: Tue, 20 Apr 2010 14:30:14 -0400
Message-ID: <20100420183013.GC6472@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few more intended for 2.6.34, mostly from the iwlwifi team.
They fix a couple of potential crashes, an incorrect EEPROM offset
related to regulatory information, and a connectivity failure relating
to 802.11n and the 4965.  The "iwlwifi: fix scan races" seems a little
long, but much of it is the fallout from renaming a goto label.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b91ecb0027c7171c83d7cf443a22c39b1fde6d83:
  Tilman Schmidt (1):
        gigaset: include cleanup cleanup

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (2):
      iwlwifi: fix scan races
      mac80211: remove bogus TX agg state assignment

Reinette Chatre (1):
      mac80211: pass HT changes to driver when off channel

Shanyu Zhao (1):
      iwlwifi: correct 6000 EEPROM regulatory address

 drivers/net/wireless/iwlwifi/iwl-6000.c   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c    |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.c   |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h    |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h |    4 +++
 drivers/net/wireless/iwlwifi/iwl-scan.c   |   31 ++++++++++++++++++----------
 net/mac80211/agg-tx.c                     |    1 -
 net/mac80211/mlme.c                       |    2 +
 9 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index c4844ad..92b3e64 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -259,7 +259,7 @@ static struct iwl_lib_ops iwl6000_lib = {
 			EEPROM_5000_REG_BAND_3_CHANNELS,
 			EEPROM_5000_REG_BAND_4_CHANNELS,
 			EEPROM_5000_REG_BAND_5_CHANNELS,
-			EEPROM_5000_REG_BAND_24_HT40_CHANNELS,
+			EEPROM_6000_REG_BAND_24_HT40_CHANNELS,
 			EEPROM_5000_REG_BAND_52_HT40_CHANNELS
 		},
 		.verify_signature  = iwlcore_eeprom_verify_signature,
@@ -323,7 +323,7 @@ static struct iwl_lib_ops iwl6050_lib = {
 			EEPROM_5000_REG_BAND_3_CHANNELS,
 			EEPROM_5000_REG_BAND_4_CHANNELS,
 			EEPROM_5000_REG_BAND_5_CHANNELS,
-			EEPROM_5000_REG_BAND_24_HT40_CHANNELS,
+			EEPROM_6000_REG_BAND_24_HT40_CHANNELS,
 			EEPROM_5000_REG_BAND_52_HT40_CHANNELS
 		},
 		.verify_signature  = iwlcore_eeprom_verify_signature,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index e4c2e1e..ba0fdba 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3330,6 +3330,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
 
 	cancel_delayed_work_sync(&priv->init_alive_start);
 	cancel_delayed_work(&priv->scan_check);
+	cancel_work_sync(&priv->start_internal_scan);
 	cancel_delayed_work(&priv->alive_start);
 	cancel_work_sync(&priv->beacon_update);
 	del_timer_sync(&priv->statistics_periodic);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 894bcb8..1459cdb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -3357,7 +3357,6 @@ static void iwl_force_rf_reset(struct iwl_priv *priv)
 	 */
 	IWL_DEBUG_INFO(priv, "perform radio reset.\n");
 	iwl_internal_short_hw_scan(priv);
-	return;
 }
 
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 732590f..36940a9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -506,7 +506,7 @@ void iwl_init_scan_params(struct iwl_priv *priv);
 int iwl_scan_cancel(struct iwl_priv *priv);
 int iwl_scan_cancel_timeout(struct iwl_priv *priv, unsigned long ms);
 int iwl_mac_hw_scan(struct ieee80211_hw *hw, struct cfg80211_scan_request *req);
-int iwl_internal_short_hw_scan(struct iwl_priv *priv);
+void iwl_internal_short_hw_scan(struct iwl_priv *priv);
 int iwl_force_reset(struct iwl_priv *priv, int mode);
 u16 iwl_fill_probe_req(struct iwl_priv *priv, struct ieee80211_mgmt *frame,
 		       const u8 *ie, int ie_len, int left);
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index 6054c5f..ef1720a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -1296,6 +1296,7 @@ struct iwl_priv {
 	struct work_struct tt_work;
 	struct work_struct ct_enter;
 	struct work_struct ct_exit;
+	struct work_struct start_internal_scan;
 
 	struct tasklet_struct irq_tasklet;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
index 4e1ba82..8171c70 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
@@ -203,6 +203,10 @@ struct iwl_eeprom_enhanced_txpwr {
 #define EEPROM_5000_REG_BAND_52_HT40_CHANNELS  ((0x92)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 22  bytes */
 
+/* 6000 regulatory - indirect access */
+#define EEPROM_6000_REG_BAND_24_HT40_CHANNELS  ((0x80)\
+		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 14  bytes */
+
 /* 6000 and up regulatory tx power - indirect access */
 /* max. elements per section */
 #define EEPROM_MAX_TXPOWER_SECTION_ELEMENTS	(8)
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index bd2f7c4..5062f4e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -469,6 +469,8 @@ EXPORT_SYMBOL(iwl_init_scan_params);
 
 static int iwl_scan_initiate(struct iwl_priv *priv)
 {
+	WARN_ON(!mutex_is_locked(&priv->mutex));
+
 	IWL_DEBUG_INFO(priv, "Starting scan...\n");
 	set_bit(STATUS_SCANNING, &priv->status);
 	priv->is_internal_short_scan = false;
@@ -546,24 +548,31 @@ EXPORT_SYMBOL(iwl_mac_hw_scan);
  * internal short scan, this function should only been called while associated.
  * It will reset and tune the radio to prevent possible RF related problem
  */
-int iwl_internal_short_hw_scan(struct iwl_priv *priv)
+void iwl_internal_short_hw_scan(struct iwl_priv *priv)
 {
-	int ret = 0;
+	queue_work(priv->workqueue, &priv->start_internal_scan);
+}
+
+static void iwl_bg_start_internal_scan(struct work_struct *work)
+{
+	struct iwl_priv *priv =
+		container_of(work, struct iwl_priv, start_internal_scan);
+
+	mutex_lock(&priv->mutex);
 
 	if (!iwl_is_ready_rf(priv)) {
-		ret = -EIO;
 		IWL_DEBUG_SCAN(priv, "not ready or exit pending\n");
-		goto out;
+		goto unlock;
 	}
+
 	if (test_bit(STATUS_SCANNING, &priv->status)) {
 		IWL_DEBUG_SCAN(priv, "Scan already in progress.\n");
-		ret = -EAGAIN;
-		goto out;
+		goto unlock;
 	}
+
 	if (test_bit(STATUS_SCAN_ABORTING, &priv->status)) {
 		IWL_DEBUG_SCAN(priv, "Scan request while abort pending\n");
-		ret = -EAGAIN;
-		goto out;
+		goto unlock;
 	}
 
 	priv->scan_bands = 0;
@@ -576,9 +585,8 @@ int iwl_internal_short_hw_scan(struct iwl_priv *priv)
 	set_bit(STATUS_SCANNING, &priv->status);
 	priv->is_internal_short_scan = true;
 	queue_work(priv->workqueue, &priv->request_scan);
-
-out:
-	return ret;
+ unlock:
+	mutex_unlock(&priv->mutex);
 }
 EXPORT_SYMBOL(iwl_internal_short_hw_scan);
 
@@ -964,6 +972,7 @@ void iwl_setup_scan_deferred_work(struct iwl_priv *priv)
 	INIT_WORK(&priv->scan_completed, iwl_bg_scan_completed);
 	INIT_WORK(&priv->request_scan, iwl_bg_request_scan);
 	INIT_WORK(&priv->abort_scan, iwl_bg_abort_scan);
+	INIT_WORK(&priv->start_internal_scan, iwl_bg_start_internal_scan);
 	INIT_DELAYED_WORK(&priv->scan_check, iwl_bg_scan_check);
 }
 EXPORT_SYMBOL(iwl_setup_scan_deferred_work);
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 5538e1b..944a8a9 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -183,7 +183,6 @@ static void sta_addba_resp_timer_expired(unsigned long data)
 		       HT_AGG_STATE_REQ_STOP_BA_MSK)) !=
 						HT_ADDBA_REQUESTED_MSK) {
 		spin_unlock_bh(&sta->lock);
-		*state = HT_AGG_STATE_IDLE;
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		printk(KERN_DEBUG "timer expired on tid %d but we are not "
 				"(or no longer) expecting addBA response there",
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index be5f723..8a96503 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -167,6 +167,8 @@ static u32 ieee80211_enable_ht(struct ieee80211_sub_if_data *sdata,
 	ht_changed = conf_is_ht(&local->hw.conf) != enable_ht ||
 		     channel_type != local->hw.conf.channel_type;
 
+	if (local->tmp_channel)
+		local->tmp_channel_type = channel_type;
 	local->oper_channel_type = channel_type;
 
 	if (ht_changed) {
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
