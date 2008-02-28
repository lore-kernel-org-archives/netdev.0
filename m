From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-02-27
Date: Wed, 27 Feb 2008 20:41:25 -0500
Message-ID: <20080228014125.GI3078@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2466 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754884AbYB1CCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 21:02:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are some fixes intended for 2.6.25.  Please let me know if there
are problems!

Thanks,

John

P.S. This will create a merge conflict with the code I already
requested that you pull for net-2.6.26.  The merge is easily resolved,
since it is two "comment block + single statement" additions at the
same place in the file.  Just take both sets of changes, and order
the "Evalue antenna setup" group _after_ the "Send a signal to the
led" group.  I have the conflict corrected in my wireless-testing
tree for reference if you need it.

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit d9595a7b9c777d45a74774f1428c263a0a47f4c0:
  David S. Miller (1):
        [AF_KEY]: Fix oops by converting to proc_net_*().

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Alexey Zaytsev (2):
      Use a separate config option for the b43 pci to ssb bridge.
      Don't build bcm43xx if SSB is static and b43 PCI-SSB bridge is enabled.

Gordon Farquharson (1):
      Fix b43 driver build for arm

Ivo van Doorn (4):
      rt2x00: Fix antenna diversity
      rt2x00: Add link tuner safe RX toggle states
      rt2x00: Don't switch to antenna with low rssi
      rt2x00: Fix rt2x00lib_reset_link_tuner()

Johannes Berg (2):
      rndis_wlan: fix sparse warnings
      mac80211: fix kmalloc vs. net_ratelimit

Masakazu Mokuno (1):
      PS3: gelic: Link the wireless net_device structure to the corresponding device structure

Roland Dreier (1):
      libertas: Remove unused exports

Sebastian Siewior (1):
      gelic wireless driver needs WIRELESS_EXT support

 drivers/net/Kconfig                        |    1 +
 drivers/net/ps3_gelic_wireless.c           |    1 +
 drivers/net/wireless/b43/Kconfig           |    1 +
 drivers/net/wireless/b43legacy/Kconfig     |    1 +
 drivers/net/wireless/bcm43xx/Kconfig       |    2 +-
 drivers/net/wireless/libertas/cmd.c        |    2 -
 drivers/net/wireless/libertas/decl.h       |    1 -
 drivers/net/wireless/libertas/main.c       |   17 -------
 drivers/net/wireless/rndis_wlan.c          |   14 +++---
 drivers/net/wireless/rt2x00/rt2400pci.c    |    6 ++-
 drivers/net/wireless/rt2x00/rt2500pci.c    |    6 ++-
 drivers/net/wireless/rt2x00/rt2500usb.c    |    6 ++-
 drivers/net/wireless/rt2x00/rt2x00config.c |    8 ++-
 drivers/net/wireless/rt2x00/rt2x00dev.c    |   73 ++++++++++++++-------------
 drivers/net/wireless/rt2x00/rt2x00reg.h    |    2 +
 drivers/net/wireless/rt2x00/rt61pci.c      |    6 ++-
 drivers/net/wireless/rt2x00/rt73usb.c      |    6 ++-
 drivers/ssb/Kconfig                        |    5 ++
 drivers/ssb/Makefile                       |    2 +-
 drivers/ssb/ssb_private.h                  |    4 +-
 include/linux/mod_devicetable.h            |    8 +++-
 net/mac80211/ieee80211_sta.c               |    7 ++-
 22 files changed, 102 insertions(+), 77 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a20e72f..a0f0e60 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2368,6 +2368,7 @@ config GELIC_NET
 config GELIC_WIRELESS
        bool "PS3 Wireless support"
        depends on GELIC_NET
+       select WIRELESS_EXT
        help
         This option adds the support for the wireless feature of PS3.
         If you have the wireless-less model of PS3 or have no plan to
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 750d2a9..daf5aba 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2690,6 +2690,7 @@ int gelic_wl_driver_probe(struct gelic_card *card)
 		return -ENOMEM;
 
 	/* setup net_device structure */
+	SET_NETDEV_DEV(netdev, &card->dev->core);
 	gelic_wl_setup_netdev_ops(netdev);
 
 	/* setup some of net_device and register it */
diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kconfig
index 1a2141d..8bc4bc4 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -32,6 +32,7 @@ config B43_PCI_AUTOSELECT
 	bool
 	depends on B43 && SSB_PCIHOST_POSSIBLE
 	select SSB_PCIHOST
+	select SSB_B43_PCI_BRIDGE
 	default y
 
 # Auto-select SSB PCICORE driver, if possible
diff --git a/drivers/net/wireless/b43legacy/Kconfig b/drivers/net/wireless/b43legacy/Kconfig
index 6745579..13c65fa 100644
--- a/drivers/net/wireless/b43legacy/Kconfig
+++ b/drivers/net/wireless/b43legacy/Kconfig
@@ -25,6 +25,7 @@ config B43LEGACY_PCI_AUTOSELECT
 	bool
 	depends on B43LEGACY && SSB_PCIHOST_POSSIBLE
 	select SSB_PCIHOST
+	select SSB_B43_PCI_BRIDGE
 	default y
 
 # Auto-select SSB PCICORE driver, if possible
diff --git a/drivers/net/wireless/bcm43xx/Kconfig b/drivers/net/wireless/bcm43xx/Kconfig
index 0159701..afb8f43 100644
--- a/drivers/net/wireless/bcm43xx/Kconfig
+++ b/drivers/net/wireless/bcm43xx/Kconfig
@@ -1,6 +1,6 @@
 config BCM43XX
 	tristate "Broadcom BCM43xx wireless support (DEPRECATED)"
-	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && WLAN_80211 && EXPERIMENTAL
+	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && WLAN_80211 && (!SSB_B43_PCI_BRIDGE || SSB != y) && EXPERIMENTAL
 	select WIRELESS_EXT
 	select FW_LOADER
 	select HW_RANDOM
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index eab0203..b3c1acb 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -1040,7 +1040,6 @@ int lbs_mesh_access(struct lbs_private *priv, uint16_t cmd_action,
 	lbs_deb_leave(LBS_DEB_CMD);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(lbs_mesh_access);
 
 int lbs_mesh_config(struct lbs_private *priv, uint16_t enable, uint16_t chan)
 {
@@ -1576,7 +1575,6 @@ done:
 	lbs_deb_leave_args(LBS_DEB_HOST, "ret %d", ret);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(lbs_prepare_and_send_command);
 
 /**
  *  @brief This function allocates the command buffer and link
diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/libertas/decl.h
index aaacd9b..4e22341 100644
--- a/drivers/net/wireless/libertas/decl.h
+++ b/drivers/net/wireless/libertas/decl.h
@@ -69,7 +69,6 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev);
 int lbs_remove_card(struct lbs_private *priv);
 int lbs_start_card(struct lbs_private *priv);
 int lbs_stop_card(struct lbs_private *priv);
-int lbs_reset_device(struct lbs_private *priv);
 void lbs_host_to_card_done(struct lbs_private *priv);
 
 int lbs_update_channel(struct lbs_private *priv);
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 84fb49c..4d4e2f3 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1351,8 +1351,6 @@ done:
 	lbs_deb_leave_args(LBS_DEB_MESH, "ret %d", ret);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(lbs_add_mesh);
-
 
 static void lbs_remove_mesh(struct lbs_private *priv)
 {
@@ -1372,7 +1370,6 @@ static void lbs_remove_mesh(struct lbs_private *priv)
 	free_netdev(mesh_dev);
 	lbs_deb_leave(LBS_DEB_MESH);
 }
-EXPORT_SYMBOL_GPL(lbs_remove_mesh);
 
 /**
  *  @brief This function finds the CFP in
@@ -1458,20 +1455,6 @@ void lbs_interrupt(struct lbs_private *priv)
 }
 EXPORT_SYMBOL_GPL(lbs_interrupt);
 
-int lbs_reset_device(struct lbs_private *priv)
-{
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_MAIN);
-	ret = lbs_prepare_and_send_command(priv, CMD_802_11_RESET,
-				    CMD_ACT_HALT, 0, 0, NULL);
-	msleep_interruptible(10);
-
-	lbs_deb_leave_args(LBS_DEB_MAIN, "ret %d", ret);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(lbs_reset_device);
-
 static int __init lbs_init_module(void)
 {
 	lbs_deb_enter(LBS_DEB_MAIN);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 8ce2ddf..d9460ae 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -228,9 +228,9 @@ struct NDIS_WLAN_BSSID_EX {
 	struct NDIS_802_11_SSID Ssid;
 	__le32 Privacy;
 	__le32 Rssi;
-	enum NDIS_802_11_NETWORK_TYPE NetworkTypeInUse;
+	__le32 NetworkTypeInUse;
 	struct NDIS_802_11_CONFIGURATION Configuration;
-	enum NDIS_802_11_NETWORK_INFRASTRUCTURE InfrastructureMode;
+	__le32 InfrastructureMode;
 	u8 SupportedRates[NDIS_802_11_LENGTH_RATES_EX];
 	__le32 IELength;
 	u8 IEs[0];
@@ -279,11 +279,11 @@ struct RNDIS_CONFIG_PARAMETER_INFOBUFFER {
 } __attribute__((packed));
 
 /* these have to match what is in wpa_supplicant */
-enum { WPA_ALG_NONE, WPA_ALG_WEP, WPA_ALG_TKIP, WPA_ALG_CCMP } wpa_alg;
-enum { CIPHER_NONE, CIPHER_WEP40, CIPHER_TKIP, CIPHER_CCMP, CIPHER_WEP104 }
-	wpa_cipher;
-enum { KEY_MGMT_802_1X, KEY_MGMT_PSK, KEY_MGMT_NONE, KEY_MGMT_802_1X_NO_WPA,
-	KEY_MGMT_WPA_NONE } wpa_key_mgmt;
+enum wpa_alg { WPA_ALG_NONE, WPA_ALG_WEP, WPA_ALG_TKIP, WPA_ALG_CCMP };
+enum wpa_cipher { CIPHER_NONE, CIPHER_WEP40, CIPHER_TKIP, CIPHER_CCMP,
+		  CIPHER_WEP104 };
+enum wpa_key_mgmt { KEY_MGMT_802_1X, KEY_MGMT_PSK, KEY_MGMT_NONE,
+		    KEY_MGMT_802_1X_NO_WPA, KEY_MGMT_WPA_NONE };
 
 /*
  *  private data
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index d6cba13..c69f85e 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -960,8 +960,12 @@ static int rt2400pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 		rt2400pci_disable_radio(rt2x00dev);
 		break;
 	case STATE_RADIO_RX_ON:
+	case STATE_RADIO_RX_ON_LINK:
+		rt2400pci_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON);
+		break;
 	case STATE_RADIO_RX_OFF:
-		rt2400pci_toggle_rx(rt2x00dev, state);
+	case STATE_RADIO_RX_OFF_LINK:
+		rt2400pci_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
 		break;
 	case STATE_DEEP_SLEEP:
 	case STATE_SLEEP:
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index e874fdc..91e87b5 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1112,8 +1112,12 @@ static int rt2500pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 		rt2500pci_disable_radio(rt2x00dev);
 		break;
 	case STATE_RADIO_RX_ON:
+	case STATE_RADIO_RX_ON_LINK:
+		rt2500pci_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON);
+		break;
 	case STATE_RADIO_RX_OFF:
-		rt2500pci_toggle_rx(rt2x00dev, state);
+	case STATE_RADIO_RX_OFF_LINK:
+		rt2500pci_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
 		break;
 	case STATE_DEEP_SLEEP:
 	case STATE_SLEEP:
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 4ca9730..638c3d2 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1001,8 +1001,12 @@ static int rt2500usb_set_device_state(struct rt2x00_dev *rt2x00dev,
 		rt2500usb_disable_radio(rt2x00dev);
 		break;
 	case STATE_RADIO_RX_ON:
+	case STATE_RADIO_RX_ON_LINK:
+		rt2500usb_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON);
+		break;
 	case STATE_RADIO_RX_OFF:
-		rt2500usb_toggle_rx(rt2x00dev, state);
+	case STATE_RADIO_RX_OFF_LINK:
+		rt2500usb_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
 		break;
 	case STATE_DEEP_SLEEP:
 	case STATE_SLEEP:
diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/rt2x00/rt2x00config.c
index 72cfe00..07adc57 100644
--- a/drivers/net/wireless/rt2x00/rt2x00config.c
+++ b/drivers/net/wireless/rt2x00/rt2x00config.c
@@ -97,12 +97,16 @@ void rt2x00lib_config_antenna(struct rt2x00_dev *rt2x00dev,
 	libconf.ant.rx = rx;
 	libconf.ant.tx = tx;
 
+	if (rx == rt2x00dev->link.ant.active.rx &&
+	    tx == rt2x00dev->link.ant.active.tx)
+		return;
+
 	/*
 	 * Antenna setup changes require the RX to be disabled,
 	 * else the changes will be ignored by the device.
 	 */
 	if (test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags))
-		rt2x00lib_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
+		rt2x00lib_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF_LINK);
 
 	/*
 	 * Write new antenna setup to device and reset the link tuner.
@@ -116,7 +120,7 @@ void rt2x00lib_config_antenna(struct rt2x00_dev *rt2x00dev,
 	rt2x00dev->link.ant.active.tx = libconf.ant.tx;
 
 	if (test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags))
-		rt2x00lib_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON);
+		rt2x00lib_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON_LINK);
 }
 
 void rt2x00lib_config(struct rt2x00_dev *rt2x00dev,
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index c4be2ac..0d51f47 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -61,11 +61,33 @@ EXPORT_SYMBOL_GPL(rt2x00lib_get_ring);
 /*
  * Link tuning handlers
  */
-static void rt2x00lib_start_link_tuner(struct rt2x00_dev *rt2x00dev)
+void rt2x00lib_reset_link_tuner(struct rt2x00_dev *rt2x00dev)
 {
+	if (!test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags))
+		return;
+
+	/*
+	 * Reset link information.
+	 * Both the currently active vgc level as well as
+	 * the link tuner counter should be reset. Resetting
+	 * the counter is important for devices where the
+	 * device should only perform link tuning during the
+	 * first minute after being enabled.
+	 */
 	rt2x00dev->link.count = 0;
 	rt2x00dev->link.vgc_level = 0;
 
+	/*
+	 * Reset the link tuner.
+	 */
+	rt2x00dev->ops->lib->reset_tuner(rt2x00dev);
+}
+
+static void rt2x00lib_start_link_tuner(struct rt2x00_dev *rt2x00dev)
+{
+	/*
+	 * Clear all (possibly) pre-existing quality statistics.
+	 */
 	memset(&rt2x00dev->link.qual, 0, sizeof(rt2x00dev->link.qual));
 
 	/*
@@ -79,10 +101,7 @@ static void rt2x00lib_start_link_tuner(struct rt2x00_dev *rt2x00dev)
 	rt2x00dev->link.qual.rx_percentage = 50;
 	rt2x00dev->link.qual.tx_percentage = 50;
 
-	/*
-	 * Reset the link tuner.
-	 */
-	rt2x00dev->ops->lib->reset_tuner(rt2x00dev);
+	rt2x00lib_reset_link_tuner(rt2x00dev);
 
 	queue_delayed_work(rt2x00dev->hw->workqueue,
 			   &rt2x00dev->link.work, LINK_TUNE_INTERVAL);
@@ -93,15 +112,6 @@ static void rt2x00lib_stop_link_tuner(struct rt2x00_dev *rt2x00dev)
 	cancel_delayed_work_sync(&rt2x00dev->link.work);
 }
 
-void rt2x00lib_reset_link_tuner(struct rt2x00_dev *rt2x00dev)
-{
-	if (!test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags))
-		return;
-
-	rt2x00lib_stop_link_tuner(rt2x00dev);
-	rt2x00lib_start_link_tuner(rt2x00dev);
-}
-
 /*
  * Ring initialization
  */
@@ -260,19 +270,11 @@ static void rt2x00lib_evaluate_antenna_sample(struct rt2x00_dev *rt2x00dev)
 	if (sample_a == sample_b)
 		return;
 
-	if (rt2x00dev->link.ant.flags & ANTENNA_RX_DIVERSITY) {
-		if (sample_a > sample_b && rx == ANTENNA_B)
-			rx = ANTENNA_A;
-		else if (rx == ANTENNA_A)
-			rx = ANTENNA_B;
-	}
+	if (rt2x00dev->link.ant.flags & ANTENNA_RX_DIVERSITY)
+		rx = (sample_a > sample_b) ? ANTENNA_A : ANTENNA_B;
 
-	if (rt2x00dev->link.ant.flags & ANTENNA_TX_DIVERSITY) {
-		if (sample_a > sample_b && tx == ANTENNA_B)
-			tx = ANTENNA_A;
-		else if (tx == ANTENNA_A)
-			tx = ANTENNA_B;
-	}
+	if (rt2x00dev->link.ant.flags & ANTENNA_TX_DIVERSITY)
+		tx = (sample_a > sample_b) ? ANTENNA_A : ANTENNA_B;
 
 	rt2x00lib_config_antenna(rt2x00dev, rx, tx);
 }
@@ -293,7 +295,7 @@ static void rt2x00lib_evaluate_antenna_eval(struct rt2x00_dev *rt2x00dev)
 	 * sample the rssi from the other antenna to make a valid
 	 * comparison between the 2 antennas.
 	 */
-	if ((rssi_curr - rssi_old) > -5 || (rssi_curr - rssi_old) < 5)
+	if (abs(rssi_curr - rssi_old) < 5)
 		return;
 
 	rt2x00dev->link.ant.flags |= ANTENNA_MODE_SAMPLE;
@@ -319,15 +321,15 @@ static void rt2x00lib_evaluate_antenna(struct rt2x00_dev *rt2x00dev)
 	rt2x00dev->link.ant.flags &= ~ANTENNA_TX_DIVERSITY;
 
 	if (rt2x00dev->hw->conf.antenna_sel_rx == 0 &&
-	    rt2x00dev->default_ant.rx != ANTENNA_SW_DIVERSITY)
+	    rt2x00dev->default_ant.rx == ANTENNA_SW_DIVERSITY)
 		rt2x00dev->link.ant.flags |= ANTENNA_RX_DIVERSITY;
 	if (rt2x00dev->hw->conf.antenna_sel_tx == 0 &&
-	    rt2x00dev->default_ant.tx != ANTENNA_SW_DIVERSITY)
+	    rt2x00dev->default_ant.tx == ANTENNA_SW_DIVERSITY)
 		rt2x00dev->link.ant.flags |= ANTENNA_TX_DIVERSITY;
 
 	if (!(rt2x00dev->link.ant.flags & ANTENNA_RX_DIVERSITY) &&
 	    !(rt2x00dev->link.ant.flags & ANTENNA_TX_DIVERSITY)) {
-		rt2x00dev->link.ant.flags &= ~ANTENNA_MODE_SAMPLE;
+		rt2x00dev->link.ant.flags = 0;
 		return;
 	}
 
@@ -441,17 +443,18 @@ static void rt2x00lib_link_tuner(struct work_struct *work)
 		rt2x00dev->ops->lib->link_tuner(rt2x00dev);
 
 	/*
-	 * Evaluate antenna setup.
-	 */
-	rt2x00lib_evaluate_antenna(rt2x00dev);
-
-	/*
 	 * Precalculate a portion of the link signal which is
 	 * in based on the tx/rx success/failure counters.
 	 */
 	rt2x00lib_precalculate_link_signal(&rt2x00dev->link.qual);
 
 	/*
+	 * Evaluate antenna setup, make this the last step since this could
+	 * possibly reset some statistics.
+	 */
+	rt2x00lib_evaluate_antenna(rt2x00dev);
+
+	/*
 	 * Increase tuner counter, and reschedule the next link tuner run.
 	 */
 	rt2x00dev->link.count++;
diff --git a/drivers/net/wireless/rt2x00/rt2x00reg.h b/drivers/net/wireless/rt2x00/rt2x00reg.h
index 8384212..b1915dc 100644
--- a/drivers/net/wireless/rt2x00/rt2x00reg.h
+++ b/drivers/net/wireless/rt2x00/rt2x00reg.h
@@ -85,6 +85,8 @@ enum dev_state {
 	STATE_RADIO_OFF,
 	STATE_RADIO_RX_ON,
 	STATE_RADIO_RX_OFF,
+	STATE_RADIO_RX_ON_LINK,
+	STATE_RADIO_RX_OFF_LINK,
 	STATE_RADIO_IRQ_ON,
 	STATE_RADIO_IRQ_OFF,
 };
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index b31f0c2..e808db9 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1482,8 +1482,12 @@ static int rt61pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 		rt61pci_disable_radio(rt2x00dev);
 		break;
 	case STATE_RADIO_RX_ON:
+	case STATE_RADIO_RX_ON_LINK:
+		rt61pci_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON);
+		break;
 	case STATE_RADIO_RX_OFF:
-		rt61pci_toggle_rx(rt2x00dev, state);
+	case STATE_RADIO_RX_OFF_LINK:
+		rt61pci_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
 		break;
 	case STATE_DEEP_SLEEP:
 	case STATE_SLEEP:
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 4d576ab..4fac2d4 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1208,8 +1208,12 @@ static int rt73usb_set_device_state(struct rt2x00_dev *rt2x00dev,
 		rt73usb_disable_radio(rt2x00dev);
 		break;
 	case STATE_RADIO_RX_ON:
+	case STATE_RADIO_RX_ON_LINK:
+		rt73usb_toggle_rx(rt2x00dev, STATE_RADIO_RX_ON);
+		break;
 	case STATE_RADIO_RX_OFF:
-		rt73usb_toggle_rx(rt2x00dev, state);
+	case STATE_RADIO_RX_OFF_LINK:
+		rt73usb_toggle_rx(rt2x00dev, STATE_RADIO_RX_OFF);
 		break;
 	case STATE_DEEP_SLEEP:
 	case STATE_SLEEP:
diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index 78fd331..adea792 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -35,6 +35,11 @@ config SSB_PCIHOST
 
 	  If unsure, say Y
 
+config SSB_B43_PCI_BRIDGE
+	bool
+	depends on SSB_PCIHOST
+	default n
+
 config SSB_PCMCIAHOST_POSSIBLE
 	bool
 	depends on SSB && (PCMCIA = y || PCMCIA = SSB) && EXPERIMENTAL
diff --git a/drivers/ssb/Makefile b/drivers/ssb/Makefile
index e235144..de94c2e 100644
--- a/drivers/ssb/Makefile
+++ b/drivers/ssb/Makefile
@@ -14,6 +14,6 @@ ssb-$(CONFIG_SSB_DRIVER_PCICORE)	+= driver_pcicore.o
 
 # b43 pci-ssb-bridge driver
 # Not strictly a part of SSB, but kept here for convenience
-ssb-$(CONFIG_SSB_PCIHOST)		+= b43_pci_bridge.o
+ssb-$(CONFIG_SSB_B43_PCI_BRIDGE)	+= b43_pci_bridge.o
 
 obj-$(CONFIG_SSB)			+= ssb.o
diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
index a789364..21eca2b 100644
--- a/drivers/ssb/ssb_private.h
+++ b/drivers/ssb/ssb_private.h
@@ -120,10 +120,10 @@ extern int ssb_devices_thaw(struct ssb_bus *bus);
 extern struct ssb_bus *ssb_pci_dev_to_bus(struct pci_dev *pdev);
 
 /* b43_pci_bridge.c */
-#ifdef CONFIG_SSB_PCIHOST
+#ifdef CONFIG_SSB_B43_PCI_BRIDGE
 extern int __init b43_pci_ssb_bridge_init(void);
 extern void __exit b43_pci_ssb_bridge_exit(void);
-#else /* CONFIG_SSB_PCIHOST */
+#else /* CONFIG_SSB_B43_PCI_BRIDGR */
 static inline int b43_pci_ssb_bridge_init(void)
 {
 	return 0;
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index 139d49d..fd217ae 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -351,7 +351,13 @@ struct sdio_device_id {
 struct ssb_device_id {
 	__u16	vendor;
 	__u16	coreid;
-	__u8	revision;
+	/* Explicit padding to support a broken sanity check in file2alias.c.
+	 * The check compares the size of the structure in the kernel
+	 * object file to the size of the structure reported in userspace for
+	 * the system on which the kernel is compiled. The check breaks on
+	 * cross-compilation, and the padding is a workaround for this. */
+	__u8	revision
+		__attribute__((aligned(sizeof(__u32))));
 };
 #define SSB_DEVICE(_vendor, _coreid, _revision)  \
 	{ .vendor = _vendor, .coreid = _coreid, .revision = _revision, }
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 2019b4f..9aeed53 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -1116,9 +1116,10 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
 	/* prepare reordering buffer */
 	tid_agg_rx->reorder_buf =
 		kmalloc(buf_size * sizeof(struct sk_buf *), GFP_ATOMIC);
-	if ((!tid_agg_rx->reorder_buf) && net_ratelimit()) {
-		printk(KERN_ERR "can not allocate reordering buffer "
-						"to tid %d\n", tid);
+	if (!tid_agg_rx->reorder_buf) {
+		if (net_ratelimit())
+			printk(KERN_ERR "can not allocate reordering buffer "
+			       "to tid %d\n", tid);
 		goto end;
 	}
 	memset(tid_agg_rx->reorder_buf, 0,
-- 
John W. Linville
linville@tuxdriver.com
