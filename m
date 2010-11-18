From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-11-18
Date: Thu, 18 Nov 2010 13:41:16 -0500
Message-ID: <20101118184116.GD2468@tuxdriver.com>
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

This is a batch of wireless fixes intended for 2.6.37.

Included is an build fix for b43legacy on ARM, a correction of a
misnumbered WIPHY_FLAG_* value, a fix for the units passed to
usb_wait_anchor_empty_timeout in carl9170, a relocation of ath9k's
pm_qos request to avoid a warning about an unknown object, some device
ID stuff for ath9k_htc, a corrected eeprom offset for AR9287 devices, a
regulatory fix for extension channels, a fix on top of the regulatory
fix that restores HT40 functionality, and an ath9k_htc fix for non-QoS
frame handling that avoids "severe data loss with some APs".

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 28cb6ccd2c7e86b3a4db94c7062cd27937bed424:

  gianfar: fix signedness issue (2010-11-17 12:39:54 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Arnd Hannemann (1):
      b43legacy: Fix compile on ARM architecture

Christian Lamparter (1):
      carl9170: fix usb anchor wait timeout

Jussi Kivilinna (1):
      cfg80211: fix WIPHY_FLAG_IBSS_RSN bit

Luis R. Rodriguez (1):
      cfg80211: fix extension channel checks to initiate communication

Mark Mentovai (1):
      cfg80211: fix can_beacon_sec_chan, reenable HT40

Rajkumar Manoharan (4):
      ath9k_htc: Update usb device ID list
      ath9k_htc: Add new devices into AR7010
      ath9k_hw: Set proper eeprom offset for AR9287 HTC devices
      ath9k_htc: Avoid setting QoS control for non-QoS frames

Vivek Natarajan (1):
      ath9k: Remove pm_qos request after hw unregister.

 drivers/net/wireless/ath/ath9k/eeprom_9287.c  |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    9 ++++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |    2 +-
 drivers/net/wireless/ath/ath9k/init.c         |    3 +-
 drivers/net/wireless/ath/ath9k/reg.h          |    8 +++-
 drivers/net/wireless/ath/carl9170/usb.c       |    4 +-
 include/net/cfg80211.h                        |    2 +-
 include/net/dst_ops.h                         |    1 +
 net/wireless/chan.c                           |   54 +++++++++++++++++++++++++
 10 files changed, 79 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 966b949..195406d 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -37,7 +37,7 @@ static bool ath9k_hw_ar9287_fill_eeprom(struct ath_hw *ah)
 	int addr, eep_start_loc;
 	eep_data = (u16 *)eep;
 
-	if (ah->hw_version.devid == 0x7015)
+	if (AR9287_HTC_DEVID(ah))
 		eep_start_loc = AR9287_HTC_EEP_START_LOC;
 	else
 		eep_start_loc = AR9287_EEP_START_LOC;
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index f7ec31b..dfb6560 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -36,8 +36,13 @@ static struct usb_device_id ath9k_hif_usb_ids[] = {
 	{ USB_DEVICE(0x13D3, 0x3327) }, /* Azurewave */
 	{ USB_DEVICE(0x13D3, 0x3328) }, /* Azurewave */
 	{ USB_DEVICE(0x13D3, 0x3346) }, /* IMC Networks */
+	{ USB_DEVICE(0x13D3, 0x3348) }, /* Azurewave */
+	{ USB_DEVICE(0x13D3, 0x3349) }, /* Azurewave */
+	{ USB_DEVICE(0x13D3, 0x3350) }, /* Azurewave */
 	{ USB_DEVICE(0x04CA, 0x4605) }, /* Liteon */
 	{ USB_DEVICE(0x083A, 0xA704) }, /* SMC Networks */
+	{ USB_DEVICE(0x040D, 0x3801) }, /* VIA */
+	{ USB_DEVICE(0x1668, 0x1200) }, /* Verizon */
 	{ },
 };
 
@@ -806,6 +811,8 @@ static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
 	case 0x7010:
 	case 0x7015:
 	case 0x9018:
+	case 0xA704:
+	case 0x1200:
 		firm_offset = AR7010_FIRMWARE_TEXT;
 		break;
 	default:
@@ -928,6 +935,8 @@ static int ath9k_hif_usb_probe(struct usb_interface *interface,
 	case 0x7010:
 	case 0x7015:
 	case 0x9018:
+	case 0xA704:
+	case 0x1200:
 		if (le16_to_cpu(udev->descriptor.bcdDevice) == 0x0202)
 			hif_dev->fw_name = FIRMWARE_AR7010_1_1;
 		else
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 3d7b97f..7c8a38d 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -249,6 +249,8 @@ static int ath9k_init_htc_services(struct ath9k_htc_priv *priv, u16 devid)
 	case 0x7010:
 	case 0x7015:
 	case 0x9018:
+	case 0xA704:
+	case 0x1200:
 		priv->htc->credits = 45;
 		break;
 	default:
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 3d19b5b..29d80ca 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -121,7 +121,7 @@ int ath9k_htc_tx_start(struct ath9k_htc_priv *priv, struct sk_buff *skb)
 			tx_hdr.data_type = ATH9K_HTC_NORMAL;
 		}
 
-		if (ieee80211_is_data(fc)) {
+		if (ieee80211_is_data_qos(fc)) {
 			qc = ieee80211_get_qos_ctl(hdr);
 			tx_hdr.tidno = qc[0] & IEEE80211_QOS_CTL_TID_MASK;
 		}
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 6a0d99e..92bc5c5 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -817,8 +817,6 @@ void ath9k_deinit_device(struct ath_softc *sc)
 
 	ath9k_ps_wakeup(sc);
 
-	pm_qos_remove_request(&ath9k_pm_qos_req);
-
 	wiphy_rfkill_stop_polling(sc->hw->wiphy);
 	ath_deinit_leds(sc);
 
@@ -832,6 +830,7 @@ void ath9k_deinit_device(struct ath_softc *sc)
 	}
 
 	ieee80211_unregister_hw(hw);
+	pm_qos_remove_request(&ath9k_pm_qos_req);
 	ath_rx_cleanup(sc);
 	ath_tx_cleanup(sc);
 	ath9k_deinit_softc(sc);
diff --git a/drivers/net/wireless/ath/ath9k/reg.h b/drivers/net/wireless/ath/ath9k/reg.h
index fa05b71..dddf579 100644
--- a/drivers/net/wireless/ath/ath9k/reg.h
+++ b/drivers/net/wireless/ath/ath9k/reg.h
@@ -866,7 +866,13 @@
 #define AR_DEVID_7010(_ah) \
 	(((_ah)->hw_version.devid == 0x7010) || \
 	 ((_ah)->hw_version.devid == 0x7015) || \
-	 ((_ah)->hw_version.devid == 0x9018))
+	 ((_ah)->hw_version.devid == 0x9018) || \
+	 ((_ah)->hw_version.devid == 0xA704) || \
+	 ((_ah)->hw_version.devid == 0x1200))
+
+#define AR9287_HTC_DEVID(_ah) \
+	(((_ah)->hw_version.devid == 0x7015) || \
+	 ((_ah)->hw_version.devid == 0x1200))
 
 #define AR_RADIO_SREV_MAJOR                   0xf0
 #define AR_RAD5133_SREV_MAJOR                 0xc0
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 3317039..7504ed1 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -553,12 +553,12 @@ static int carl9170_usb_flush(struct ar9170 *ar)
 		usb_free_urb(urb);
 	}
 
-	ret = usb_wait_anchor_empty_timeout(&ar->tx_cmd, HZ);
+	ret = usb_wait_anchor_empty_timeout(&ar->tx_cmd, 1000);
 	if (ret == 0)
 		err = -ETIMEDOUT;
 
 	/* lets wait a while until the tx - queues are dried out */
-	ret = usb_wait_anchor_empty_timeout(&ar->tx_anch, HZ);
+	ret = usb_wait_anchor_empty_timeout(&ar->tx_anch, 1000);
 	if (ret == 0)
 		err = -ETIMEDOUT;
 
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 2a7936d..97b8b7c 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1355,7 +1355,7 @@ enum wiphy_flags {
 	WIPHY_FLAG_4ADDR_AP			= BIT(5),
 	WIPHY_FLAG_4ADDR_STATION		= BIT(6),
 	WIPHY_FLAG_CONTROL_PORT_PROTOCOL	= BIT(7),
-	WIPHY_FLAG_IBSS_RSN			= BIT(7),
+	WIPHY_FLAG_IBSS_RSN			= BIT(8),
 };
 
 struct mac_address {
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 1fa5306..51665b3 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -2,6 +2,7 @@
 #define _NET_DST_OPS_H
 #include <linux/types.h>
 #include <linux/percpu_counter.h>
+#include <linux/cache.h>
 
 struct dst_entry;
 struct kmem_cachep;
diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index d0c92dd..17cd0c0 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -44,6 +44,38 @@ rdev_freq_to_chan(struct cfg80211_registered_device *rdev,
 	return chan;
 }
 
+static bool can_beacon_sec_chan(struct wiphy *wiphy,
+				struct ieee80211_channel *chan,
+				enum nl80211_channel_type channel_type)
+{
+	struct ieee80211_channel *sec_chan;
+	int diff;
+
+	switch (channel_type) {
+	case NL80211_CHAN_HT40PLUS:
+		diff = 20;
+		break;
+	case NL80211_CHAN_HT40MINUS:
+		diff = -20;
+		break;
+	default:
+		return false;
+	}
+
+	sec_chan = ieee80211_get_channel(wiphy, chan->center_freq + diff);
+	if (!sec_chan)
+		return false;
+
+	/* we'll need a DFS capability later */
+	if (sec_chan->flags & (IEEE80211_CHAN_DISABLED |
+			       IEEE80211_CHAN_PASSIVE_SCAN |
+			       IEEE80211_CHAN_NO_IBSS |
+			       IEEE80211_CHAN_RADAR))
+		return false;
+
+	return true;
+}
+
 int cfg80211_set_freq(struct cfg80211_registered_device *rdev,
 		      struct wireless_dev *wdev, int freq,
 		      enum nl80211_channel_type channel_type)
@@ -68,6 +100,28 @@ int cfg80211_set_freq(struct cfg80211_registered_device *rdev,
 	if (!chan)
 		return -EINVAL;
 
+	/* Both channels should be able to initiate communication */
+	if (wdev && (wdev->iftype == NL80211_IFTYPE_ADHOC ||
+		     wdev->iftype == NL80211_IFTYPE_AP ||
+		     wdev->iftype == NL80211_IFTYPE_AP_VLAN ||
+		     wdev->iftype == NL80211_IFTYPE_MESH_POINT ||
+		     wdev->iftype == NL80211_IFTYPE_P2P_GO)) {
+		switch (channel_type) {
+		case NL80211_CHAN_HT40PLUS:
+		case NL80211_CHAN_HT40MINUS:
+			if (!can_beacon_sec_chan(&rdev->wiphy, chan,
+						 channel_type)) {
+				printk(KERN_DEBUG
+				       "cfg80211: Secondary channel not "
+				       "allowed to initiate communication\n");
+				return -EINVAL;
+			}
+			break;
+		default:
+			break;
+		}
+	}
+
 	result = rdev->ops->set_channel(&rdev->wiphy,
 					wdev ? wdev->netdev : NULL,
 					chan, channel_type);
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
