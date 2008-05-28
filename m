From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-05-28
Date: Wed, 28 May 2008 17:38:31 -0400
Message-ID: <20080528213831.GA3133@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Another round of fixes for 2.6.26 follows...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 289c79a4bd350e8a25065102563ad1a183d1b402:
  Patrick McHardy (1):
        vlan: Use bitmask of feature flags instead of seperate feature bits

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Fixes the status message for iwconfig

Andrea Merello (3):
      rtl8180: fix wrong parameter in sa2400_rf_set_channel
      rtl8180: fix wrong parameter in max2820_rf_set_channel
      rtl8180: fix wrong parameter in grf5101_rf_set_channel

Guy Cohen (2):
      iwlwifi: fix exit from stay_in_table state
      iwlwifi: fix rate scale TLC column selection bug

Ivo van Doorn (4):
      rt2x00: Fix memleak in tx() path
      rt2x00: Don't count retries as failure
      rt2x00: Reset antenna RSSI after switch
      rt2x00: Use atomic interface iteration in irq context

John W. Linville (1):
      rtl8180: avoid NULL dereference in max2820_rf_set_channel

Jussi Kivilinna (1):
      rndis_wlan: add missing range check for power_output modparam

Michael Buesch (2):
      b43: Upload both beacon templates on initial load
      b43: Fix controller restart crash

Nicolas Kaiser (1):
      net/mac80211: always true conditionals

Scott Ashcroft (1):
      rndis_wlan: Make connections to TKIP PSK networks work

Senthil Balasubramanian (2):
      mac80211: Fix for NULL pointer dereference in sta_info_get()
      mac80211: fix alignment issue with compare_ether_addr()

Tomas Winkler (2):
      mac80211: fix ieee80211_rx_bss_put/get imbalance
      mac80211: reorder channel and freq reporting in wext scan report

Yi Zhu (1):
      mac80211: fix a typo in ieee80211_handle_filtered_frame comment

 drivers/net/wireless/b43/b43.h             |    1 +
 drivers/net/wireless/b43/main.c            |   70 +++++++++++++++++++++------
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c |    3 +-
 drivers/net/wireless/rndis_wlan.c          |   65 +++++++++++++++++++++++++-
 drivers/net/wireless/rt2x00/rt2x00.h       |    5 ++
 drivers/net/wireless/rt2x00/rt2x00config.c |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c    |    8 ++--
 drivers/net/wireless/rt2x00/rt2x00mac.c    |    1 +
 drivers/net/wireless/rtl8180_grf5101.c     |    2 +-
 drivers/net/wireless/rtl8180_max2820.c     |    5 +-
 drivers/net/wireless/rtl8180_sa2400.c      |    2 +-
 net/mac80211/cfg.c                         |    4 +-
 net/mac80211/main.c                        |    2 +-
 net/mac80211/mlme.c                        |   29 ++++++-----
 net/mac80211/rx.c                          |    4 +-
 net/mac80211/util.c                        |    4 +-
 net/mac80211/wext.c                        |   11 +++-
 17 files changed, 166 insertions(+), 51 deletions(-)

diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index 37783cd..dfa4bdd 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -737,6 +737,7 @@ struct b43_wl {
 	struct ieee80211_tx_control beacon_txctl;
 	bool beacon0_uploaded;
 	bool beacon1_uploaded;
+	bool beacon_templates_virgin; /* Never wrote the templates? */
 	struct work_struct beacon_update_trigger;
 
 	/* The current QOS parameters for the 4 queues.
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 8fdba94..6c3d9ea 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1544,6 +1544,30 @@ static void b43_write_probe_resp_template(struct b43_wldev *dev,
 	kfree(probe_resp_data);
 }
 
+static void b43_upload_beacon0(struct b43_wldev *dev)
+{
+	struct b43_wl *wl = dev->wl;
+
+	if (wl->beacon0_uploaded)
+		return;
+	b43_write_beacon_template(dev, 0x68, 0x18);
+	/* FIXME: Probe resp upload doesn't really belong here,
+	 *        but we don't use that feature anyway. */
+	b43_write_probe_resp_template(dev, 0x268, 0x4A,
+				      &__b43_ratetable[3]);
+	wl->beacon0_uploaded = 1;
+}
+
+static void b43_upload_beacon1(struct b43_wldev *dev)
+{
+	struct b43_wl *wl = dev->wl;
+
+	if (wl->beacon1_uploaded)
+		return;
+	b43_write_beacon_template(dev, 0x468, 0x1A);
+	wl->beacon1_uploaded = 1;
+}
+
 static void handle_irq_beacon(struct b43_wldev *dev)
 {
 	struct b43_wl *wl = dev->wl;
@@ -1568,24 +1592,27 @@ static void handle_irq_beacon(struct b43_wldev *dev)
 		return;
 	}
 
-	if (!beacon0_valid) {
-		if (!wl->beacon0_uploaded) {
-			b43_write_beacon_template(dev, 0x68, 0x18);
-			b43_write_probe_resp_template(dev, 0x268, 0x4A,
-						      &__b43_ratetable[3]);
-			wl->beacon0_uploaded = 1;
-		}
+	if (unlikely(wl->beacon_templates_virgin)) {
+		/* We never uploaded a beacon before.
+		 * Upload both templates now, but only mark one valid. */
+		wl->beacon_templates_virgin = 0;
+		b43_upload_beacon0(dev);
+		b43_upload_beacon1(dev);
 		cmd = b43_read32(dev, B43_MMIO_MACCMD);
 		cmd |= B43_MACCMD_BEACON0_VALID;
 		b43_write32(dev, B43_MMIO_MACCMD, cmd);
-	} else if (!beacon1_valid) {
-		if (!wl->beacon1_uploaded) {
-			b43_write_beacon_template(dev, 0x468, 0x1A);
-			wl->beacon1_uploaded = 1;
+	} else {
+		if (!beacon0_valid) {
+			b43_upload_beacon0(dev);
+			cmd = b43_read32(dev, B43_MMIO_MACCMD);
+			cmd |= B43_MACCMD_BEACON0_VALID;
+			b43_write32(dev, B43_MMIO_MACCMD, cmd);
+		} else if (!beacon1_valid) {
+			b43_upload_beacon1(dev);
+			cmd = b43_read32(dev, B43_MMIO_MACCMD);
+			cmd |= B43_MACCMD_BEACON1_VALID;
+			b43_write32(dev, B43_MMIO_MACCMD, cmd);
 		}
-		cmd = b43_read32(dev, B43_MMIO_MACCMD);
-		cmd |= B43_MACCMD_BEACON1_VALID;
-		b43_write32(dev, B43_MMIO_MACCMD, cmd);
 	}
 }
 
@@ -4073,6 +4100,9 @@ static int b43_op_start(struct ieee80211_hw *hw)
 	wl->filter_flags = 0;
 	wl->radiotap_enabled = 0;
 	b43_qos_clear(wl);
+	wl->beacon0_uploaded = 0;
+	wl->beacon1_uploaded = 0;
+	wl->beacon_templates_virgin = 1;
 
 	/* First register RFkill.
 	 * LEDs that are registered later depend on it. */
@@ -4241,7 +4271,9 @@ static void b43_chip_reset(struct work_struct *work)
 			goto out;
 		}
 	}
-      out:
+out:
+	if (err)
+		wl->current_dev = NULL; /* Failed to init the dev. */
 	mutex_unlock(&wl->mutex);
 	if (err)
 		b43err(wl, "Controller restart FAILED\n");
@@ -4382,9 +4414,11 @@ static void b43_one_core_detach(struct ssb_device *dev)
 	struct b43_wldev *wldev;
 	struct b43_wl *wl;
 
+	/* Do not cancel ieee80211-workqueue based work here.
+	 * See comment in b43_remove(). */
+
 	wldev = ssb_get_drvdata(dev);
 	wl = wldev->wl;
-	cancel_work_sync(&wldev->restart_work);
 	b43_debugfs_remove_device(wldev);
 	b43_wireless_core_detach(wldev);
 	list_del(&wldev->list);
@@ -4569,6 +4603,10 @@ static void b43_remove(struct ssb_device *dev)
 	struct b43_wl *wl = ssb_get_devtypedata(dev);
 	struct b43_wldev *wldev = ssb_get_drvdata(dev);
 
+	/* We must cancel any work here before unregistering from ieee80211,
+	 * as the ieee80211 unreg will destroy the workqueue. */
+	cancel_work_sync(&wldev->restart_work);
+
 	B43_WARN_ON(!wl);
 	if (wl->current_dev == wldev)
 		ieee80211_unregister_hw(wl->hw);
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
index c9847b1..3a7f0cb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
@@ -1162,7 +1162,6 @@ static s32 rs_get_best_rate(struct iwl_priv *priv,
 
 			/* Higher rate not available, use the original */
 			} else {
-				new_rate = rate;
 				break;
 			}
 		}
@@ -2009,7 +2008,7 @@ static void rs_rate_scale_perform(struct iwl_priv *priv,
 	 * 2)  Not just finishing up a search
 	 * 3)  Allowing a new search
 	 */
-	if (!update_lq && !done_search && !lq_sta->stay_in_tbl) {
+	if (!update_lq && !done_search && !lq_sta->stay_in_tbl && window->counter) {
 		/* Save current throughput to compare with "search" throughput*/
 		lq_sta->last_tpt = current_tpt;
 
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d0b1fb1..18c9931 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -116,6 +116,7 @@ MODULE_PARM_DESC(workaround_interval,
 #define OID_802_11_ENCRYPTION_STATUS		ccpu2(0x0d01011b)
 #define OID_802_11_ADD_KEY			ccpu2(0x0d01011d)
 #define OID_802_11_REMOVE_KEY			ccpu2(0x0d01011e)
+#define OID_802_11_ASSOCIATION_INFORMATION	ccpu2(0x0d01011f)
 #define OID_802_11_PMKID			ccpu2(0x0d010123)
 #define OID_802_11_NETWORK_TYPES_SUPPORTED	ccpu2(0x0d010203)
 #define OID_802_11_NETWORK_TYPE_IN_USE		ccpu2(0x0d010204)
@@ -271,6 +272,26 @@ struct ndis_config_param {
 	__le32 value_length;
 } __attribute__((packed));
 
+struct ndis_80211_assoc_info {
+	__le32 length;
+	__le16 req_ies;
+	struct req_ie {
+		__le16 capa;
+		__le16 listen_interval;
+		u8 cur_ap_address[6];
+	} req_ie;
+	__le32 req_ie_length;
+	__le32 offset_req_ies;
+	__le16 resp_ies;
+	struct resp_ie {
+		__le16 capa;
+		__le16 status_code;
+		__le16 assoc_id;
+	} resp_ie;
+	__le32 resp_ie_length;
+	__le32 offset_resp_ies;
+} __attribute__((packed));
+
 /* these have to match what is in wpa_supplicant */
 enum wpa_alg { WPA_ALG_NONE, WPA_ALG_WEP, WPA_ALG_TKIP, WPA_ALG_CCMP };
 enum wpa_cipher { CIPHER_NONE, CIPHER_WEP40, CIPHER_TKIP, CIPHER_CCMP,
@@ -674,6 +695,12 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 	return ret;
 }
 
+static int get_association_info(struct usbnet *usbdev,
+			struct ndis_80211_assoc_info *info, int len)
+{
+	return rndis_query_oid(usbdev, OID_802_11_ASSOCIATION_INFORMATION,
+				info, &len);
+}
 
 static int is_associated(struct usbnet *usbdev)
 {
@@ -2182,11 +2209,40 @@ static void rndis_wext_worker(struct work_struct *work)
 	struct usbnet *usbdev = priv->usbdev;
 	union iwreq_data evt;
 	unsigned char bssid[ETH_ALEN];
-	int ret;
+	struct ndis_80211_assoc_info *info;
+	int assoc_size = sizeof(*info) + IW_CUSTOM_MAX + 32;
+	int ret, offset;
 
 	if (test_and_clear_bit(WORK_CONNECTION_EVENT, &priv->work_pending)) {
-		ret = get_bssid(usbdev, bssid);
+		info = kzalloc(assoc_size, GFP_KERNEL);
+		if (!info)
+			goto get_bssid;
+
+		/* Get association info IEs from device and send them back to
+		 * userspace. */
+		ret = get_association_info(usbdev, info, assoc_size);
+		if (!ret) {
+			evt.data.length = le32_to_cpu(info->req_ie_length);
+			if (evt.data.length > 0) {
+				offset = le32_to_cpu(info->offset_req_ies);
+				wireless_send_event(usbdev->net,
+					IWEVASSOCREQIE, &evt,
+					(char *)info + offset);
+			}
+
+			evt.data.length = le32_to_cpu(info->resp_ie_length);
+			if (evt.data.length > 0) {
+				offset = le32_to_cpu(info->offset_resp_ies);
+				wireless_send_event(usbdev->net,
+					IWEVASSOCRESPIE, &evt,
+					(char *)info + offset);
+			}
+		}
+
+		kfree(info);
 
+get_bssid:
+		ret = get_bssid(usbdev, bssid);
 		if (!ret) {
 			evt.data.flags = 0;
 			evt.data.length = 0;
@@ -2414,6 +2470,11 @@ static int bcm4320_early_init(struct usbnet *dev)
 	else if (priv->param_power_save > 2)
 		priv->param_power_save = 2;
 
+	if (priv->param_power_output < 0)
+		priv->param_power_output = 0;
+	else if (priv->param_power_output > 3)
+		priv->param_power_output = 3;
+
 	if (priv->param_roamtrigger < -80)
 		priv->param_roamtrigger = -80;
 	else if (priv->param_roamtrigger > -60)
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 57bdc15..611d983 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -328,6 +328,11 @@ static inline int rt2x00_get_link_ant_rssi(struct link *link)
 	return DEFAULT_RSSI;
 }
 
+static inline void rt2x00_reset_link_ant_rssi(struct link *link)
+{
+	link->ant.rssi_ant = 0;
+}
+
 static inline int rt2x00_get_link_ant_rssi_history(struct link *link,
 						   enum antenna ant)
 {
diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/rt2x00/rt2x00config.c
index a9930a0..48608e8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00config.c
+++ b/drivers/net/wireless/rt2x00/rt2x00config.c
@@ -129,6 +129,7 @@ void rt2x00lib_config_antenna(struct rt2x00_dev *rt2x00dev,
 	 */
 	rt2x00dev->ops->lib->config(rt2x00dev, &libconf, CONFIG_UPDATE_ANTENNA);
 	rt2x00lib_reset_link_tuner(rt2x00dev);
+	rt2x00_reset_link_ant_rssi(&rt2x00dev->link);
 
 	rt2x00dev->link.ant.active.rx = libconf.ant.rx;
 	rt2x00dev->link.ant.active.tx = libconf.ant.tx;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index b22c027..2673d56 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -483,9 +483,9 @@ void rt2x00lib_beacondone(struct rt2x00_dev *rt2x00dev)
 	if (!test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags))
 		return;
 
-	ieee80211_iterate_active_interfaces(rt2x00dev->hw,
-					    rt2x00lib_beacondone_iter,
-					    rt2x00dev);
+	ieee80211_iterate_active_interfaces_atomic(rt2x00dev->hw,
+						   rt2x00lib_beacondone_iter,
+						   rt2x00dev);
 
 	queue_work(rt2x00dev->hw->workqueue, &rt2x00dev->intf_work);
 }
@@ -507,7 +507,7 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	 * Update TX statistics.
 	 */
 	rt2x00dev->link.qual.tx_success += success;
-	rt2x00dev->link.qual.tx_failed += txdesc->retry + fail;
+	rt2x00dev->link.qual.tx_failed += fail;
 
 	/*
 	 * Initialize TX status
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index c206b50..87e280a 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -93,6 +93,7 @@ int rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	 */
 	if (!test_bit(DEVICE_PRESENT, &rt2x00dev->flags)) {
 		ieee80211_stop_queues(hw);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
diff --git a/drivers/net/wireless/rtl8180_grf5101.c b/drivers/net/wireless/rtl8180_grf5101.c
index 5d47935..947ee55 100644
--- a/drivers/net/wireless/rtl8180_grf5101.c
+++ b/drivers/net/wireless/rtl8180_grf5101.c
@@ -88,7 +88,7 @@ static void grf5101_rf_set_channel(struct ieee80211_hw *dev,
 	write_grf5101(dev, 0x0B, chan);
 	write_grf5101(dev, 0x07, 0x1000);
 
-	grf5101_write_phy_antenna(dev, chan);
+	grf5101_write_phy_antenna(dev, channel);
 }
 
 static void grf5101_rf_stop(struct ieee80211_hw *dev)
diff --git a/drivers/net/wireless/rtl8180_max2820.c b/drivers/net/wireless/rtl8180_max2820.c
index a34dfd3..6c825fd 100644
--- a/drivers/net/wireless/rtl8180_max2820.c
+++ b/drivers/net/wireless/rtl8180_max2820.c
@@ -78,7 +78,8 @@ static void max2820_rf_set_channel(struct ieee80211_hw *dev,
 				   struct ieee80211_conf *conf)
 {
 	struct rtl8180_priv *priv = dev->priv;
-	int channel = ieee80211_frequency_to_channel(conf->channel->center_freq);
+	int channel = conf ?
+		ieee80211_frequency_to_channel(conf->channel->center_freq) : 1;
 	unsigned int chan_idx = channel - 1;
 	u32 txpw = priv->channels[chan_idx].hw_value & 0xFF;
 	u32 chan = max2820_chan[chan_idx];
@@ -87,7 +88,7 @@ static void max2820_rf_set_channel(struct ieee80211_hw *dev,
 	 * sa2400, for MAXIM we do this directly from BB */
 	rtl8180_write_phy(dev, 3, txpw);
 
-	max2820_write_phy_antenna(dev, chan);
+	max2820_write_phy_antenna(dev, channel);
 	write_max2820(dev, 3, chan);
 }
 
diff --git a/drivers/net/wireless/rtl8180_sa2400.c b/drivers/net/wireless/rtl8180_sa2400.c
index 0311b4e..cea4e0c 100644
--- a/drivers/net/wireless/rtl8180_sa2400.c
+++ b/drivers/net/wireless/rtl8180_sa2400.c
@@ -86,7 +86,7 @@ static void sa2400_rf_set_channel(struct ieee80211_hw *dev,
 
 	write_sa2400(dev, 7, txpw);
 
-	sa2400_write_phy_antenna(dev, chan);
+	sa2400_write_phy_antenna(dev, channel);
 
 	write_sa2400(dev, 0, chan);
 	write_sa2400(dev, 1, 0xbb50);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 699d97b..a9fce4a 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -672,7 +672,7 @@ static int ieee80211_add_station(struct wiphy *wiphy, struct net_device *dev,
 	if (params->vlan) {
 		sdata = IEEE80211_DEV_TO_SUB_IF(params->vlan);
 
-		if (sdata->vif.type != IEEE80211_IF_TYPE_VLAN ||
+		if (sdata->vif.type != IEEE80211_IF_TYPE_VLAN &&
 		    sdata->vif.type != IEEE80211_IF_TYPE_AP)
 			return -EINVAL;
 	} else
@@ -760,7 +760,7 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 	if (params->vlan && params->vlan != sta->sdata->dev) {
 		vlansdata = IEEE80211_DEV_TO_SUB_IF(params->vlan);
 
-		if (vlansdata->vif.type != IEEE80211_IF_TYPE_VLAN ||
+		if (vlansdata->vif.type != IEEE80211_IF_TYPE_VLAN &&
 		    vlansdata->vif.type != IEEE80211_IF_TYPE_AP) {
 			rcu_read_unlock();
 			return -EINVAL;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 915afad..5c87645 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1313,7 +1313,7 @@ static void ieee80211_handle_filtered_frame(struct ieee80211_local *local,
 	/*
 	 * Clear the TX filter mask for this STA when sending the next
 	 * packet. If the STA went to power save mode, this will happen
-	 * happen when it wakes up for the next time.
+	 * when it wakes up for the next time.
 	 */
 	sta->flags |= WLAN_STA_CLEAR_PS_FILT;
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 7cfd12e..841278f 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1325,7 +1325,7 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
 
 	/* prepare reordering buffer */
 	tid_agg_rx->reorder_buf =
-		kmalloc(buf_size * sizeof(struct sk_buf *), GFP_ATOMIC);
+		kmalloc(buf_size * sizeof(struct sk_buff *), GFP_ATOMIC);
 	if (!tid_agg_rx->reorder_buf) {
 		if (net_ratelimit())
 			printk(KERN_ERR "can not allocate reordering buffer "
@@ -1334,7 +1334,7 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
 		goto end;
 	}
 	memset(tid_agg_rx->reorder_buf, 0,
-		buf_size * sizeof(struct sk_buf *));
+		buf_size * sizeof(struct sk_buff *));
 
 	if (local->ops->ampdu_action)
 		ret = local->ops->ampdu_action(hw, IEEE80211_AMPDU_RX_START,
@@ -1614,7 +1614,7 @@ void sta_addba_resp_timer_expired(unsigned long data)
 	 * only one argument, and both sta_info and TID are needed, so init
 	 * flow in sta_info_create gives the TID as data, while the timer_to_id
 	 * array gives the sta through container_of */
-	u16 tid = *(int *)data;
+	u16 tid = *(u8 *)data;
 	struct sta_info *temp_sta = container_of((void *)data,
 		struct sta_info, timer_to_tid[tid]);
 
@@ -1662,7 +1662,7 @@ timer_expired_exit:
 void sta_rx_agg_session_timer_expired(unsigned long data)
 {
 	/* not an elegant detour, but there is no choice as the timer passes
-	 * only one argument, and verious sta_info are needed here, so init
+	 * only one argument, and various sta_info are needed here, so init
 	 * flow in sta_info_create gives the TID as data, while the timer_to_id
 	 * array gives the sta through container_of */
 	u8 *ptid = (u8 *)data;
@@ -2479,8 +2479,6 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 	ifsta->state = IEEE80211_IBSS_JOINED;
 	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
 
-	ieee80211_rx_bss_put(dev, bss);
-
 	return res;
 }
 
@@ -3523,6 +3521,7 @@ static int ieee80211_sta_create_ibss(struct net_device *dev,
 	struct ieee80211_supported_band *sband;
 	u8 bssid[ETH_ALEN], *pos;
 	int i;
+	int ret;
 	DECLARE_MAC_BUF(mac);
 
 #if 0
@@ -3567,7 +3566,9 @@ static int ieee80211_sta_create_ibss(struct net_device *dev,
 		*pos++ = (u8) (rate / 5);
 	}
 
-	return ieee80211_sta_join_ibss(dev, ifsta, bss);
+	ret = ieee80211_sta_join_ibss(dev, ifsta, bss);
+	ieee80211_rx_bss_put(dev, bss);
+	return ret;
 }
 
 
@@ -3615,10 +3616,13 @@ static int ieee80211_sta_find_ibss(struct net_device *dev,
 	    (bss = ieee80211_rx_bss_get(dev, bssid,
 					local->hw.conf.channel->center_freq,
 					ifsta->ssid, ifsta->ssid_len))) {
+		int ret;
 		printk(KERN_DEBUG "%s: Selected IBSS BSSID %s"
 		       " based on configured SSID\n",
 		       dev->name, print_mac(mac, bssid));
-		return ieee80211_sta_join_ibss(dev, ifsta, bss);
+		ret = ieee80211_sta_join_ibss(dev, ifsta, bss);
+		ieee80211_rx_bss_put(dev, bss);
+		return ret;
 	}
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
 	printk(KERN_DEBUG "   did not try to join ibss\n");
@@ -4095,18 +4099,17 @@ ieee80211_sta_scan_result(struct net_device *dev,
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
-	iwe.u.freq.m = bss->freq;
-	iwe.u.freq.e = 6;
+	iwe.u.freq.m = ieee80211_frequency_to_channel(bss->freq);
+	iwe.u.freq.e = 0;
 	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
 					  IW_EV_FREQ_LEN);
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
-	iwe.u.freq.m = ieee80211_frequency_to_channel(bss->freq);
-	iwe.u.freq.e = 0;
+	iwe.u.freq.m = bss->freq;
+	iwe.u.freq.e = 6;
 	current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
 					  IW_EV_FREQ_LEN);
-
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = IWEVQUAL;
 	iwe.u.qual.qual = bss->signal;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 1958bfb..0941e5d 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1091,7 +1091,7 @@ ieee80211_data_to_8023(struct ieee80211_rx_data *rx)
 	u16 fc, hdrlen, ethertype;
 	u8 *payload;
 	u8 dst[ETH_ALEN];
-	u8 src[ETH_ALEN];
+	u8 src[ETH_ALEN] __aligned(2);
 	struct sk_buff *skb = rx->skb;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	DECLARE_MAC_BUF(mac);
@@ -1234,7 +1234,7 @@ ieee80211_data_to_8023(struct ieee80211_rx_data *rx)
  */
 static bool ieee80211_frame_allowed(struct ieee80211_rx_data *rx)
 {
-	static const u8 pae_group_addr[ETH_ALEN]
+	static const u8 pae_group_addr[ETH_ALEN] __aligned(2)
 		= { 0x01, 0x80, 0xC2, 0x00, 0x00, 0x03 };
 	struct ethhdr *ehdr = (struct ethhdr *) rx->skb->data;
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 131e9e6..4e97b26 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -34,11 +34,11 @@ void *mac80211_wiphy_privid = &mac80211_wiphy_privid;
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
-const unsigned char rfc1042_header[] =
+const unsigned char rfc1042_header[] __aligned(2) =
 	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
 
 /* Bridge-Tunnel header (for EtherTypes ETH_P_AARP and ETH_P_IPX) */
-const unsigned char bridge_tunnel_header[] =
+const unsigned char bridge_tunnel_header[] __aligned(2) =
 	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
 
 
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index 457ebf9..8311bb2 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -489,9 +489,14 @@ static int ieee80211_ioctl_giwap(struct net_device *dev,
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->vif.type == IEEE80211_IF_TYPE_STA ||
 	    sdata->vif.type == IEEE80211_IF_TYPE_IBSS) {
-		ap_addr->sa_family = ARPHRD_ETHER;
-		memcpy(&ap_addr->sa_data, sdata->u.sta.bssid, ETH_ALEN);
-		return 0;
+		if (sdata->u.sta.state == IEEE80211_ASSOCIATED) {
+			ap_addr->sa_family = ARPHRD_ETHER;
+			memcpy(&ap_addr->sa_data, sdata->u.sta.bssid, ETH_ALEN);
+			return 0;
+		} else {
+			memset(&ap_addr->sa_data, 0, ETH_ALEN);
+			return 0;
+		}
 	} else if (sdata->vif.type == IEEE80211_IF_TYPE_WDS) {
 		ap_addr->sa_family = ARPHRD_ETHER;
 		memcpy(&ap_addr->sa_data, sdata->u.wds.remote_addr, ETH_ALEN);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
