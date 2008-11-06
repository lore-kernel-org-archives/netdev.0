From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-11-06
Date: Thu, 6 Nov 2008 17:49:04 -0500
Message-ID: <20081106224904.GA30233@tuxdriver.com>
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

Here is the latest round of wireless bits intended for 2.6.28.  It
includes a revert of an earlier fix that greatly reduced interrupts
handled by ath5k -- testing showed that it resulted in a greater number
of dropped associations.

Also included is an iwlwifi patch ("iwlwifi: clear scanning bits upon
failure") that is already in -next.  It does not seem to be a strict
regression, but since it is simple and can leave the device unable to
scan (i.e. effectively inoperative) I think it is worth having now.
There are also iwl3945 versions of some iwlwifi fixes as well as an
iwl3945-specific one related to firmware errors.

Further, there is a WARN_ON fix for ath5k and another iwlwifi fix from
me to avoid a possible sleep in softirq context.  Just for fun I've
thrown-in a couple of zd1211rw USB ID additions as well.

Please let me know if there are problems!  Any mistakes I blame on my
recent bout of pneumonia...

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit bbb770e7ab9a436752babfc8765e422d7481be1f:
  Alexey Dobriyan (1):
        xfrm: Fix xfrm_policy_gc_lock handling.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (1):
      ath5k: correct handling of rx status fields

Daniel Drake (1):
      zd1211rw: Add 2 device IDs

John W. Linville (2):
      Revert "ath5k: honor FIF_BCN_PRBRESP_PROMISC in STA mode"
      iwlagn: avoid sleep in softirq context

Jonathan McDowell (1):
      Fix logic error in rfkill_check_duplicity

Mohamed Abbas (2):
      iwlwifi: clear scanning bits upon failure
      iwl3945: clear scanning bits upon failure

Reinette Chatre (1):
      iwl3945: do not send scan command if channel count zero

Zhu, Yi (1):
      iwl3945: fix deadlock on suspend

 drivers/net/wireless/ath5k/base.c           |    4 +++-
 drivers/net/wireless/ath5k/desc.c           |   16 ++++++++--------
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 +++++-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    7 +++++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   15 ++++++++++++++-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    2 ++
 net/rfkill/rfkill.c                         |    2 +-
 7 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index 9e47d72..cfd4d05 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -2942,8 +2942,10 @@ static void ath5k_configure_filter(struct ieee80211_hw *hw,
 		sc->opmode != NL80211_IFTYPE_MESH_POINT &&
 		test_bit(ATH_STAT_PROMISC, sc->status))
 		rfilt |= AR5K_RX_FILTER_PROM;
-	if (sc->opmode == NL80211_IFTYPE_ADHOC)
+	if (sc->opmode == NL80211_IFTYPE_STATION ||
+		sc->opmode == NL80211_IFTYPE_ADHOC) {
 		rfilt |= AR5K_RX_FILTER_BEACON;
+	}
 
 	/* Set filters */
 	ath5k_hw_set_rx_filter(ah,rfilt);
diff --git a/drivers/net/wireless/ath5k/desc.c b/drivers/net/wireless/ath5k/desc.c
index dd13740..5e362a7 100644
--- a/drivers/net/wireless/ath5k/desc.c
+++ b/drivers/net/wireless/ath5k/desc.c
@@ -531,10 +531,10 @@ static int ath5k_hw_proc_5210_rx_status(struct ath5k_hw *ah,
 		AR5K_5210_RX_DESC_STATUS0_RECEIVE_SIGNAL);
 	rs->rs_rate = AR5K_REG_MS(rx_status->rx_status_0,
 		AR5K_5210_RX_DESC_STATUS0_RECEIVE_RATE);
-	rs->rs_antenna = rx_status->rx_status_0 &
-		AR5K_5210_RX_DESC_STATUS0_RECEIVE_ANTENNA;
-	rs->rs_more = rx_status->rx_status_0 &
-		AR5K_5210_RX_DESC_STATUS0_MORE;
+	rs->rs_antenna = AR5K_REG_MS(rx_status->rx_status_0,
+		AR5K_5210_RX_DESC_STATUS0_RECEIVE_ANTENNA);
+	rs->rs_more = !!(rx_status->rx_status_0 &
+		AR5K_5210_RX_DESC_STATUS0_MORE);
 	/* TODO: this timestamp is 13 bit, later on we assume 15 bit */
 	rs->rs_tstamp = AR5K_REG_MS(rx_status->rx_status_1,
 		AR5K_5210_RX_DESC_STATUS1_RECEIVE_TIMESTAMP);
@@ -607,10 +607,10 @@ static int ath5k_hw_proc_5212_rx_status(struct ath5k_hw *ah,
 		AR5K_5212_RX_DESC_STATUS0_RECEIVE_SIGNAL);
 	rs->rs_rate = AR5K_REG_MS(rx_status->rx_status_0,
 		AR5K_5212_RX_DESC_STATUS0_RECEIVE_RATE);
-	rs->rs_antenna = rx_status->rx_status_0 &
-		AR5K_5212_RX_DESC_STATUS0_RECEIVE_ANTENNA;
-	rs->rs_more = rx_status->rx_status_0 &
-		AR5K_5212_RX_DESC_STATUS0_MORE;
+	rs->rs_antenna = AR5K_REG_MS(rx_status->rx_status_0,
+		AR5K_5212_RX_DESC_STATUS0_RECEIVE_ANTENNA);
+	rs->rs_more = !!(rx_status->rx_status_0 &
+		AR5K_5212_RX_DESC_STATUS0_MORE);
 	rs->rs_tstamp = AR5K_REG_MS(rx_status->rx_status_1,
 		AR5K_5212_RX_DESC_STATUS1_RECEIVE_TIMESTAMP);
 	rs->rs_status = 0;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 321dbc8..8d690a0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3252,7 +3252,11 @@ static void iwl4965_mac_update_tkip_key(struct ieee80211_hw *hw,
 		return;
 	}
 
-	iwl_scan_cancel_timeout(priv, 100);
+	if (iwl_scan_cancel(priv)) {
+		/* cancel scan failed, just live w/ bad key and rely
+		   briefly on SW decryption */
+		return;
+	}
 
 	key_flags |= (STA_KEY_FLG_TKIP | STA_KEY_FLG_MAP_KEY_MSK);
 	key_flags |= cpu_to_le16(keyconf->keyidx << STA_KEY_FLG_KEYID_POS);
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 3b0bee3..c89365e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -896,6 +896,13 @@ static void iwl_bg_request_scan(struct work_struct *data)
 	return;
 
  done:
+	/* Cannot perform scan. Make sure we clear scanning
+	* bits from status so next scan request can be performed.
+	* If we don't clear scanning status bit here all next scan
+	* will fail
+	*/
+	clear_bit(STATUS_SCAN_HW, &priv->status);
+	clear_bit(STATUS_SCANNING, &priv->status);
 	/* inform mac80211 scan aborted */
 	queue_work(priv->workqueue, &priv->scan_completed);
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index d15a2c9..285b53e 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -5768,7 +5768,6 @@ static void iwl3945_alive_start(struct iwl3945_priv *priv)
 	if (priv->error_recovering)
 		iwl3945_error_recovery(priv);
 
-	ieee80211_notify_mac(priv->hw, IEEE80211_NOTIFY_RE_ASSOC);
 	return;
 
  restart:
@@ -6013,6 +6012,7 @@ static void iwl3945_bg_alive_start(struct work_struct *data)
 	mutex_lock(&priv->mutex);
 	iwl3945_alive_start(priv);
 	mutex_unlock(&priv->mutex);
+	ieee80211_notify_mac(priv->hw, IEEE80211_NOTIFY_RE_ASSOC);
 }
 
 static void iwl3945_bg_rf_kill(struct work_struct *work)
@@ -6256,6 +6256,11 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 					      n_probes,
 			(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)]);
 
+	if (scan->channel_count == 0) {
+		IWL_DEBUG_SCAN("channel count %d\n", scan->channel_count);
+		goto done;
+	}
+
 	cmd.len += le16_to_cpu(scan->tx_cmd.len) +
 	    scan->channel_count * sizeof(struct iwl3945_scan_channel);
 	cmd.data = scan;
@@ -6273,6 +6278,14 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 	return;
 
  done:
+	/* can not perform scan make sure we clear scanning
+	 * bits from status so next scan request can be performed.
+	 * if we dont clear scanning status bit here all next scan
+	 * will fail
+	*/
+	clear_bit(STATUS_SCAN_HW, &priv->status);
+	clear_bit(STATUS_SCANNING, &priv->status);
+
 	/* inform mac80211 scan aborted */
 	queue_work(priv->workqueue, &priv->scan_completed);
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index a60ae86..a3ccd8c 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -61,6 +61,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0105, 0x145f), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0ace, 0xb215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
@@ -82,6 +83,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0cde, 0x001a), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x340a), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1237), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x07fa, 0x1196), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index f949a48..25ba3bd 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -603,7 +603,7 @@ static int rfkill_check_duplicity(const struct rfkill *rfkill)
 	}
 
 	/* 0: first switch of its kind */
-	return test_bit(rfkill->type, seen);
+	return (test_bit(rfkill->type, seen)) ? 1 : 0;
 }
 
 static int rfkill_add_switch(struct rfkill *rfkill)
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
