From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-11-10
Date: Wed, 10 Nov 2010 13:58:43 -0500
Message-ID: <20101110185843.GC2714@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Here is a batch of fixes intended for 2.6.37.  Also mixed-in are a few
device ID updates.  I think the changelog entries are reasonably
documentary of the issues being fixed, so I won't belabor them. ;-)

This also includes a round of Bluetooth fixes from Gustavo:

"The following batch contains some bugfixes for 2.6.37. A fix for unaligned
access in L2CAP, a Kconfig error, two fixes related to security of
the Bluetooth links, and support for the a MacBook Air Bluetooth device.
There is also a one line patch from Matthew Garret, that enables USB
autosuspend for btusb module, which shall be completely safe. Please
pull, thanks."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 88f8a5e3e7defccd3925cabb1ee4d3994e5cdb52:

  net: tipc: fix information leak to userland (2010-11-09 09:25:46 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Brian Cavagnolo (1):
      mac80211: unset SDATA_STATE_OFFCHANNEL when cancelling a scan

Christian Lamparter (1):
      carl9170: usbid table updates

Daniel Drake (1):
      libertas: terminate scan when stopping interface

Edgar (gimli) Hucek (1):
      Bluetooth: Add MacBookAir3,1(2) support

Felix Fietkau (2):
      cfg80211: fix a crash in dev lookup on dump commands
      ath9k: check old power mode before clearing cycle counters

Gustavo F. Padovan (1):
      Bluetooth: fix endianness conversion in L2CAP

Haitao Zhang (1):
      ath9k_htc: Add support for device ID 3346

Johan Hedberg (1):
      Bluetooth: Fix non-SSP auth request for HIGH security level sockets

Linus Torvalds (1):
      libipw: fix proc entry removal

Luiz Augusto von Dentz (1):
      Bluetooth: fix not setting security level when creating a rfcomm session

Matthew Garrett (1):
      Bluetooth: Enable USB autosuspend by default on btusb

Rajkumar Manoharan (3):
      ath9k: Avoid HW opmode overridden on monitor mode changes
      ath9k_htc: Fix probe failure if CONFIG_USB_DEBUG enabled
      ath9k_hw: Fix memory leak on ath9k_hw_rf_alloc_ext_banks failure

Randy Dunlap (1):
      Bluetooth: fix hidp kconfig dependency warning

Vasanthakumar Thiagarajan (1):
      ath9k_hw: Fix AR9280 surprise removal during frequent idle on/off

Vivek Natarajan (1):
      ath9k: Fix a DMA latency issue for Intel Pinetrail platforms.

Wey-Yi Guy (1):
      iwlwifi: dont use pci_dev before it being assign

steven miao (1):
      Bluetooth: fix unaligned access to l2cap conf data

 drivers/bluetooth/btusb.c                    |    5 ++++
 drivers/net/wireless/ath/ath9k/ar9002_hw.c   |    3 ++
 drivers/net/wireless/ath/ath9k/ath9k.h       |    1 +
 drivers/net/wireless/ath/ath9k/hif_usb.c     |   31 ++++++++++++-------------
 drivers/net/wireless/ath/ath9k/hw.c          |   15 +++++++++++-
 drivers/net/wireless/ath/ath9k/hw.h          |    1 +
 drivers/net/wireless/ath/ath9k/init.c        |    8 ++++++
 drivers/net/wireless/ath/ath9k/main.c        |   29 +++++++++++++++++------
 drivers/net/wireless/ath/ath9k/recv.c        |    4 +-
 drivers/net/wireless/ath/ath9k/reg.h         |    1 +
 drivers/net/wireless/ath/carl9170/usb.c      |    4 ++-
 drivers/net/wireless/ipw2x00/libipw_module.c |    9 ++++---
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    3 +-
 drivers/net/wireless/libertas/cfg.c          |    5 ++-
 drivers/net/wireless/libertas/dev.h          |    1 +
 drivers/net/wireless/libertas/main.c         |    7 ++++++
 net/bluetooth/hci_event.c                    |    6 +++++
 net/bluetooth/hidp/Kconfig                   |    2 +-
 net/bluetooth/l2cap.c                        |    8 +++---
 net/bluetooth/rfcomm/core.c                  |   13 ++++++++--
 net/mac80211/iface.c                         |    6 ++--
 net/wireless/nl80211.c                       |    4 +-
 22 files changed, 117 insertions(+), 49 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index d120a5c..ab3894f 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -68,6 +68,9 @@ static struct usb_device_id btusb_table[] = {
 	/* Apple MacBookPro6,2 */
 	{ USB_DEVICE(0x05ac, 0x8218) },
 
+	/* Apple MacBookAir3,1, MacBookAir3,2 */
+	{ USB_DEVICE(0x05ac, 0x821b) },
+
 	/* AVM BlueFRITZ! USB v2.0 */
 	{ USB_DEVICE(0x057c, 0x3800) },
 
@@ -1029,6 +1032,8 @@ static int btusb_probe(struct usb_interface *intf,
 
 	usb_set_intfdata(intf, data);
 
+	usb_enable_autosuspend(interface_to_usbdev(intf));
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
index a0471f2..48261b7 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -410,6 +410,9 @@ static void ar9002_hw_configpcipowersave(struct ath_hw *ah,
 			val &= ~(AR_WA_BIT6 | AR_WA_BIT7);
 		}
 
+		if (AR_SREV_9280(ah))
+			val |= AR_WA_BIT22;
+
 		if (AR_SREV_9285E_20(ah))
 			val |= AR_WA_BIT23;
 
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 9b8e7e3..170d44a 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -675,6 +675,7 @@ static inline void ath_read_cachesize(struct ath_common *common, int *csz)
 }
 
 extern struct ieee80211_ops ath9k_ops;
+extern struct pm_qos_request_list ath9k_pm_qos_req;
 extern int modparam_nohwcrypt;
 extern int led_blink;
 
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 6576f68..f7ec31b 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -35,6 +35,7 @@ static struct usb_device_id ath9k_hif_usb_ids[] = {
 	{ USB_DEVICE(0x07D1, 0x3A10) }, /* Dlink Wireless 150 */
 	{ USB_DEVICE(0x13D3, 0x3327) }, /* Azurewave */
 	{ USB_DEVICE(0x13D3, 0x3328) }, /* Azurewave */
+	{ USB_DEVICE(0x13D3, 0x3346) }, /* IMC Networks */
 	{ USB_DEVICE(0x04CA, 0x4605) }, /* Liteon */
 	{ USB_DEVICE(0x083A, 0xA704) }, /* SMC Networks */
 	{ },
@@ -540,11 +541,11 @@ static void ath9k_hif_usb_reg_in_cb(struct urb *urb)
 			return;
 		}
 
-		usb_fill_int_urb(urb, hif_dev->udev,
+		usb_fill_bulk_urb(urb, hif_dev->udev,
 				 usb_rcvbulkpipe(hif_dev->udev,
 						 USB_REG_IN_PIPE),
 				 nskb->data, MAX_REG_IN_BUF_SIZE,
-				 ath9k_hif_usb_reg_in_cb, nskb, 1);
+				 ath9k_hif_usb_reg_in_cb, nskb);
 
 		ret = usb_submit_urb(urb, GFP_ATOMIC);
 		if (ret) {
@@ -720,11 +721,11 @@ static int ath9k_hif_usb_alloc_reg_in_urb(struct hif_device_usb *hif_dev)
 	if (!skb)
 		goto err;
 
-	usb_fill_int_urb(hif_dev->reg_in_urb, hif_dev->udev,
+	usb_fill_bulk_urb(hif_dev->reg_in_urb, hif_dev->udev,
 			 usb_rcvbulkpipe(hif_dev->udev,
 					 USB_REG_IN_PIPE),
 			 skb->data, MAX_REG_IN_BUF_SIZE,
-			 ath9k_hif_usb_reg_in_cb, skb, 1);
+			 ath9k_hif_usb_reg_in_cb, skb);
 
 	if (usb_submit_urb(hif_dev->reg_in_urb, GFP_KERNEL) != 0)
 		goto err;
@@ -843,14 +844,6 @@ static int ath9k_hif_usb_dev_init(struct hif_device_usb *hif_dev)
 		goto err_fw_req;
 	}
 
-	/* Alloc URBs */
-	ret = ath9k_hif_usb_alloc_urbs(hif_dev);
-	if (ret) {
-		dev_err(&hif_dev->udev->dev,
-			"ath9k_htc: Unable to allocate URBs\n");
-		goto err_urb;
-	}
-
 	/* Download firmware */
 	ret = ath9k_hif_usb_download_fw(hif_dev);
 	if (ret) {
@@ -866,16 +859,22 @@ static int ath9k_hif_usb_dev_init(struct hif_device_usb *hif_dev)
 	 */
 	for (idx = 0; idx < alt->desc.bNumEndpoints; idx++) {
 		endp = &alt->endpoint[idx].desc;
-		if (((endp->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK)
-				== 0x04) &&
-		    ((endp->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
-				== USB_ENDPOINT_XFER_INT)) {
+		if ((endp->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
+				== USB_ENDPOINT_XFER_INT) {
 			endp->bmAttributes &= ~USB_ENDPOINT_XFERTYPE_MASK;
 			endp->bmAttributes |= USB_ENDPOINT_XFER_BULK;
 			endp->bInterval = 0;
 		}
 	}
 
+	/* Alloc URBs */
+	ret = ath9k_hif_usb_alloc_urbs(hif_dev);
+	if (ret) {
+		dev_err(&hif_dev->udev->dev,
+			"ath9k_htc: Unable to allocate URBs\n");
+		goto err_urb;
+	}
+
 	return 0;
 
 err_fw_download:
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index cc13ee1..6ebc68b 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -484,6 +484,7 @@ static int ath9k_hw_post_init(struct ath_hw *ah)
 		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Failed allocating banks for "
 			  "external radio\n");
+		ath9k_hw_rf_free_ext_banks(ah);
 		return ecode;
 	}
 
@@ -952,9 +953,12 @@ static void ath9k_hw_set_operating_mode(struct ath_hw *ah, int opmode)
 		REG_SET_BIT(ah, AR_CFG, AR_CFG_AP_ADHOC_INDICATION);
 		break;
 	case NL80211_IFTYPE_STATION:
-	case NL80211_IFTYPE_MONITOR:
 		REG_WRITE(ah, AR_STA_ID1, val | AR_STA_ID1_KSRCH_MODE);
 		break;
+	default:
+		if (ah->is_monitoring)
+			REG_WRITE(ah, AR_STA_ID1, val | AR_STA_ID1_KSRCH_MODE);
+		break;
 	}
 }
 
@@ -1634,7 +1638,6 @@ void ath9k_hw_beaconinit(struct ath_hw *ah, u32 next_beacon, u32 beacon_period)
 
 	switch (ah->opmode) {
 	case NL80211_IFTYPE_STATION:
-	case NL80211_IFTYPE_MONITOR:
 		REG_WRITE(ah, AR_NEXT_TBTT_TIMER, TU_TO_USEC(next_beacon));
 		REG_WRITE(ah, AR_NEXT_DMA_BEACON_ALERT, 0xffff);
 		REG_WRITE(ah, AR_NEXT_SWBA, 0x7ffff);
@@ -1663,6 +1666,14 @@ void ath9k_hw_beaconinit(struct ath_hw *ah, u32 next_beacon, u32 beacon_period)
 			AR_TBTT_TIMER_EN | AR_DBA_TIMER_EN | AR_SWBA_TIMER_EN;
 		break;
 	default:
+		if (ah->is_monitoring) {
+			REG_WRITE(ah, AR_NEXT_TBTT_TIMER,
+					TU_TO_USEC(next_beacon));
+			REG_WRITE(ah, AR_NEXT_DMA_BEACON_ALERT, 0xffff);
+			REG_WRITE(ah, AR_NEXT_SWBA, 0x7ffff);
+			flags |= AR_TBTT_TIMER_EN;
+			break;
+		}
 		ath_print(ath9k_hw_common(ah), ATH_DBG_BEACON,
 			  "%s: unsupported opmode: %d\n",
 			  __func__, ah->opmode);
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index d032939..d47d1b4 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -622,6 +622,7 @@ struct ath_hw {
 
 	bool sw_mgmt_crypto;
 	bool is_pciexpress;
+	bool is_monitoring;
 	bool need_an_top2_fixup;
 	u16 tx_trig_level;
 
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 95b41db..6a0d99e 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -15,6 +15,7 @@
  */
 
 #include <linux/slab.h>
+#include <linux/pm_qos_params.h>
 
 #include "ath9k.h"
 
@@ -179,6 +180,8 @@ static const struct ath_ops ath9k_common_ops = {
 	.write = ath9k_iowrite32,
 };
 
+struct pm_qos_request_list ath9k_pm_qos_req;
+
 /**************************/
 /*     Initialization     */
 /**************************/
@@ -756,6 +759,9 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc, u16 subsysid,
 	ath_init_leds(sc);
 	ath_start_rfkill_poll(sc);
 
+	pm_qos_add_request(&ath9k_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+			   PM_QOS_DEFAULT_VALUE);
+
 	return 0;
 
 error_world:
@@ -811,6 +817,8 @@ void ath9k_deinit_device(struct ath_softc *sc)
 
 	ath9k_ps_wakeup(sc);
 
+	pm_qos_remove_request(&ath9k_pm_qos_req);
+
 	wiphy_rfkill_stop_polling(sc->hw->wiphy);
 	ath_deinit_leds(sc);
 
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index b52f1cf..25d3ef4 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -15,6 +15,7 @@
  */
 
 #include <linux/nl80211.h>
+#include <linux/pm_qos_params.h>
 #include "ath9k.h"
 #include "btcoex.h"
 
@@ -93,11 +94,13 @@ void ath9k_ps_wakeup(struct ath_softc *sc)
 {
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	unsigned long flags;
+	enum ath9k_power_mode power_mode;
 
 	spin_lock_irqsave(&sc->sc_pm_lock, flags);
 	if (++sc->ps_usecount != 1)
 		goto unlock;
 
+	power_mode = sc->sc_ah->power_mode;
 	ath9k_hw_setpower(sc->sc_ah, ATH9K_PM_AWAKE);
 
 	/*
@@ -105,10 +108,12 @@ void ath9k_ps_wakeup(struct ath_softc *sc)
 	 * useful data. Better clear them now so that they don't mess up
 	 * survey data results.
 	 */
-	spin_lock(&common->cc_lock);
-	ath_hw_cycle_counters_update(common);
-	memset(&common->cc_survey, 0, sizeof(common->cc_survey));
-	spin_unlock(&common->cc_lock);
+	if (power_mode != ATH9K_PM_AWAKE) {
+		spin_lock(&common->cc_lock);
+		ath_hw_cycle_counters_update(common);
+		memset(&common->cc_survey, 0, sizeof(common->cc_survey));
+		spin_unlock(&common->cc_lock);
+	}
 
  unlock:
 	spin_unlock_irqrestore(&sc->sc_pm_lock, flags);
@@ -1217,6 +1222,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 		ah->imask |= ATH9K_INT_CST;
 
 	sc->sc_flags &= ~SC_OP_INVALID;
+	sc->sc_ah->is_monitoring = false;
 
 	/* Disable BMISS interrupt when we're not associated */
 	ah->imask &= ~(ATH9K_INT_SWBA | ATH9K_INT_BMISS);
@@ -1238,6 +1244,8 @@ static int ath9k_start(struct ieee80211_hw *hw)
 			ath9k_btcoex_timer_resume(sc);
 	}
 
+	pm_qos_update_request(&ath9k_pm_qos_req, 55);
+
 mutex_unlock:
 	mutex_unlock(&sc->mutex);
 
@@ -1415,6 +1423,8 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	sc->sc_flags |= SC_OP_INVALID;
 
+	pm_qos_update_request(&ath9k_pm_qos_req, PM_QOS_DEFAULT_VALUE);
+
 	mutex_unlock(&sc->mutex);
 
 	ath_print(common, ATH_DBG_CONFIG, "Driver halt\n");
@@ -1493,8 +1503,7 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 	ath9k_hw_set_interrupts(ah, ah->imask);
 
 	if (vif->type == NL80211_IFTYPE_AP    ||
-	    vif->type == NL80211_IFTYPE_ADHOC ||
-	    vif->type == NL80211_IFTYPE_MONITOR) {
+	    vif->type == NL80211_IFTYPE_ADHOC) {
 		sc->sc_flags |= SC_OP_ANI_RUN;
 		ath_start_ani(common);
 	}
@@ -1644,8 +1653,12 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
 		if (conf->flags & IEEE80211_CONF_MONITOR) {
 			ath_print(common, ATH_DBG_CONFIG,
-				  "HW opmode set to Monitor mode\n");
-			sc->sc_ah->opmode = NL80211_IFTYPE_MONITOR;
+				  "Monitor mode is enabled\n");
+			sc->sc_ah->is_monitoring = true;
+		} else {
+			ath_print(common, ATH_DBG_CONFIG,
+				  "Monitor mode is disabled\n");
+			sc->sc_ah->is_monitoring = false;
 		}
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index fddb012..c76ea53 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -441,7 +441,7 @@ u32 ath_calcrxfilter(struct ath_softc *sc)
 	 */
 	if (((sc->sc_ah->opmode != NL80211_IFTYPE_AP) &&
 	     (sc->rx.rxfilter & FIF_PROMISC_IN_BSS)) ||
-	    (sc->sc_ah->opmode == NL80211_IFTYPE_MONITOR))
+	    (sc->sc_ah->is_monitoring))
 		rfilt |= ATH9K_RX_FILTER_PROM;
 
 	if (sc->rx.rxfilter & FIF_CONTROL)
@@ -897,7 +897,7 @@ static bool ath9k_rx_accept(struct ath_common *common,
 		 * decryption and MIC failures. For monitor mode,
 		 * we also ignore the CRC error.
 		 */
-		if (ah->opmode == NL80211_IFTYPE_MONITOR) {
+		if (ah->is_monitoring) {
 			if (rx_stats->rs_status &
 			    ~(ATH9K_RXERR_DECRYPT | ATH9K_RXERR_MIC |
 			      ATH9K_RXERR_CRC))
diff --git a/drivers/net/wireless/ath/ath9k/reg.h b/drivers/net/wireless/ath/ath9k/reg.h
index 42976b0..fa05b71 100644
--- a/drivers/net/wireless/ath/ath9k/reg.h
+++ b/drivers/net/wireless/ath/ath9k/reg.h
@@ -703,6 +703,7 @@
 #define AR_WA_RESET_EN                  (1 << 18) /* Sw Control to enable PCI-Reset to POR (bit 15) */
 #define AR_WA_ANALOG_SHIFT              (1 << 20)
 #define AR_WA_POR_SHORT                 (1 << 21) /* PCI-E Phy reset control */
+#define AR_WA_BIT22			(1 << 22)
 #define AR9285_WA_DEFAULT		0x004a050b
 #define AR9280_WA_DEFAULT           	0x0040073b
 #define AR_WA_DEFAULT               	0x0000073f
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index d8607f4..3317039 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -82,9 +82,11 @@ static struct usb_device_id carl9170_usb_ids[] = {
 	{ USB_DEVICE(0x07d1, 0x3c10) },
 	/* D-Link DWA 160 A2 */
 	{ USB_DEVICE(0x07d1, 0x3a09) },
+	/* D-Link DWA 130 D */
+	{ USB_DEVICE(0x07d1, 0x3a0f) },
 	/* Netgear WNA1000 */
 	{ USB_DEVICE(0x0846, 0x9040) },
-	/* Netgear WNDA3100 */
+	/* Netgear WNDA3100 (v1) */
 	{ USB_DEVICE(0x0846, 0x9010) },
 	/* Netgear WN111 v2 */
 	{ USB_DEVICE(0x0846, 0x9001), .driver_info = CARL9170_ONE_LED },
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index 32dee2c..d5ef696 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -54,6 +54,7 @@
 
 #define DRV_DESCRIPTION "802.11 data/management/control stack"
 #define DRV_NAME        "libipw"
+#define DRV_PROCNAME	"ieee80211"
 #define DRV_VERSION	LIBIPW_VERSION
 #define DRV_COPYRIGHT   "Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>"
 
@@ -293,16 +294,16 @@ static int __init libipw_init(void)
 	struct proc_dir_entry *e;
 
 	libipw_debug_level = debug;
-	libipw_proc = proc_mkdir("ieee80211", init_net.proc_net);
+	libipw_proc = proc_mkdir(DRV_PROCNAME, init_net.proc_net);
 	if (libipw_proc == NULL) {
-		LIBIPW_ERROR("Unable to create " DRV_NAME
+		LIBIPW_ERROR("Unable to create " DRV_PROCNAME
 				" proc directory\n");
 		return -EIO;
 	}
 	e = proc_create("debug_level", S_IRUGO | S_IWUSR, libipw_proc,
 			&debug_level_proc_fops);
 	if (!e) {
-		remove_proc_entry(DRV_NAME, init_net.proc_net);
+		remove_proc_entry(DRV_PROCNAME, init_net.proc_net);
 		libipw_proc = NULL;
 		return -EIO;
 	}
@@ -319,7 +320,7 @@ static void __exit libipw_exit(void)
 #ifdef CONFIG_LIBIPW_DEBUG
 	if (libipw_proc) {
 		remove_proc_entry("debug_level", libipw_proc);
-		remove_proc_entry(DRV_NAME, init_net.proc_net);
+		remove_proc_entry(DRV_PROCNAME, init_net.proc_net);
 		libipw_proc = NULL;
 	}
 #endif				/* CONFIG_LIBIPW_DEBUG */
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 8f8c4b7..7edf8c2 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4000,7 +4000,8 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	 * "the hard way", rather than using device's scan.
 	 */
 	if (iwl3945_mod_params.disable_hw_scan) {
-		IWL_ERR(priv, "sw scan support is deprecated\n");
+		dev_printk(KERN_DEBUG, &(pdev->dev),
+			"sw scan support is deprecated\n");
 		iwl3945_hw_ops.hw_scan = NULL;
 	}
 
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 5046a00..373930a 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -700,8 +700,9 @@ static void lbs_scan_worker(struct work_struct *work)
 
 	if (priv->scan_channel < priv->scan_req->n_channels) {
 		cancel_delayed_work(&priv->scan_work);
-		queue_delayed_work(priv->work_thread, &priv->scan_work,
-			msecs_to_jiffies(300));
+		if (!priv->stopping)
+			queue_delayed_work(priv->work_thread, &priv->scan_work,
+				msecs_to_jiffies(300));
 	}
 
 	/* This is the final data we are about to send */
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index f062ed5..cb14c38 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -36,6 +36,7 @@ struct lbs_private {
 	/* CFG80211 */
 	struct wireless_dev *wdev;
 	bool wiphy_registered;
+	bool stopping;
 	struct cfg80211_scan_request *scan_req;
 	u8 assoc_bss[ETH_ALEN];
 	u8 disassoc_reason;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 47ce5a6..46b88b1 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -104,6 +104,7 @@ static int lbs_dev_open(struct net_device *dev)
 	lbs_deb_enter(LBS_DEB_NET);
 
 	spin_lock_irq(&priv->driver_lock);
+	priv->stopping = false;
 
 	if (priv->connect_status == LBS_CONNECTED)
 		netif_carrier_on(dev);
@@ -131,10 +132,16 @@ static int lbs_eth_stop(struct net_device *dev)
 	lbs_deb_enter(LBS_DEB_NET);
 
 	spin_lock_irq(&priv->driver_lock);
+	priv->stopping = true;
 	netif_stop_queue(dev);
 	spin_unlock_irq(&priv->driver_lock);
 
 	schedule_work(&priv->mcast_work);
+	cancel_delayed_work_sync(&priv->scan_work);
+	if (priv->scan_req) {
+		cfg80211_scan_done(priv->scan_req, false);
+		priv->scan_req = NULL;
+	}
 
 	lbs_deb_leave(LBS_DEB_NET);
 	return 0;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index bfef5ba..84093b0 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1175,6 +1175,12 @@ static inline void hci_remote_features_evt(struct hci_dev *hdev, struct sk_buff
 				hci_send_cmd(hdev,
 					HCI_OP_READ_REMOTE_EXT_FEATURES,
 							sizeof(cp), &cp);
+			} else if (!ev->status && conn->out &&
+					conn->sec_level == BT_SECURITY_HIGH) {
+				struct hci_cp_auth_requested cp;
+				cp.handle = ev->handle;
+				hci_send_cmd(hdev, HCI_OP_AUTH_REQUESTED,
+							sizeof(cp), &cp);
 			} else {
 				conn->state = BT_CONNECTED;
 				hci_proto_connect_cfm(conn, ev->status);
diff --git a/net/bluetooth/hidp/Kconfig b/net/bluetooth/hidp/Kconfig
index 98fdfa1..86a9154 100644
--- a/net/bluetooth/hidp/Kconfig
+++ b/net/bluetooth/hidp/Kconfig
@@ -1,6 +1,6 @@
 config BT_HIDP
 	tristate "HIDP protocol support"
-	depends on BT && BT_L2CAP && INPUT
+	depends on BT && BT_L2CAP && INPUT && HID_SUPPORT
 	select HID
 	help
 	  HIDP (Human Interface Device Protocol) is a transport layer
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index daa7a98..cd8f6ea 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2421,11 +2421,11 @@ static inline int l2cap_get_conf_opt(void **ptr, int *type, int *olen, unsigned
 		break;
 
 	case 2:
-		*val = __le16_to_cpu(*((__le16 *) opt->val));
+		*val = get_unaligned_le16(opt->val);
 		break;
 
 	case 4:
-		*val = __le32_to_cpu(*((__le32 *) opt->val));
+		*val = get_unaligned_le32(opt->val);
 		break;
 
 	default:
@@ -2452,11 +2452,11 @@ static void l2cap_add_conf_opt(void **ptr, u8 type, u8 len, unsigned long val)
 		break;
 
 	case 2:
-		*((__le16 *) opt->val) = cpu_to_le16(val);
+		put_unaligned_le16(val, opt->val);
 		break;
 
 	case 4:
-		*((__le32 *) opt->val) = cpu_to_le32(val);
+		put_unaligned_le32(val, opt->val);
 		break;
 
 	default:
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 39a5d87..fa642aa 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -79,7 +79,10 @@ static void rfcomm_make_uih(struct sk_buff *skb, u8 addr);
 
 static void rfcomm_process_connect(struct rfcomm_session *s);
 
-static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst, int *err);
+static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src,
+							bdaddr_t *dst,
+							u8 sec_level,
+							int *err);
 static struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst);
 static void rfcomm_session_del(struct rfcomm_session *s);
 
@@ -401,7 +404,7 @@ static int __rfcomm_dlc_open(struct rfcomm_dlc *d, bdaddr_t *src, bdaddr_t *dst,
 
 	s = rfcomm_session_get(src, dst);
 	if (!s) {
-		s = rfcomm_session_create(src, dst, &err);
+		s = rfcomm_session_create(src, dst, d->sec_level, &err);
 		if (!s)
 			return err;
 	}
@@ -679,7 +682,10 @@ static void rfcomm_session_close(struct rfcomm_session *s, int err)
 	rfcomm_session_put(s);
 }
 
-static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst, int *err)
+static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src,
+							bdaddr_t *dst,
+							u8 sec_level,
+							int *err)
 {
 	struct rfcomm_session *s = NULL;
 	struct sockaddr_l2 addr;
@@ -704,6 +710,7 @@ static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst
 	sk = sock->sk;
 	lock_sock(sk);
 	l2cap_pi(sk)->imtu = l2cap_mtu;
+	l2cap_pi(sk)->sec_level = sec_level;
 	if (l2cap_ertm)
 		l2cap_pi(sk)->mode = L2CAP_MODE_ERTM;
 	release_sock(sk);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index f9163b1..7aa8559 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -391,6 +391,9 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 	u32 hw_reconf_flags = 0;
 	int i;
 
+	if (local->scan_sdata == sdata)
+		ieee80211_scan_cancel(local);
+
 	clear_bit(SDATA_STATE_RUNNING, &sdata->state);
 
 	/*
@@ -523,9 +526,6 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 		synchronize_rcu();
 		skb_queue_purge(&sdata->skb_queue);
 
-		if (local->scan_sdata == sdata)
-			ieee80211_scan_cancel(local);
-
 		/*
 		 * Disable beaconing here for mesh only, AP and IBSS
 		 * are already taken care of.
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index c506241..4e78e3f 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -224,8 +224,8 @@ static int nl80211_prepare_netdev_dump(struct sk_buff *skb,
 	}
 
 	*rdev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
-	if (IS_ERR(dev)) {
-		err = PTR_ERR(dev);
+	if (IS_ERR(*rdev)) {
+		err = PTR_ERR(*rdev);
 		goto out_rtnl;
 	}
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
