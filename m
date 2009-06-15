From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-06-15
Date: Mon, 15 Jun 2009 16:36:44 -0400
Message-ID: <20090615203643.GJ2729@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49123 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbZFOUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 16:45:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is a batch of (mostly) fixes instended for 2.6.31.  Most of them
are fixes, many with references to bug reports.  Most of the rest is
fall-out and stragglers related to the rfkill rework.  There is also
the addition of a debugfs file to aid debugging.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 9cbc1cb8cd46ce1f7645b9de249b2ce8460129bb:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (1):
      iwlwifi/iwl3945: fix suspend resume association bug

Andrey Yurovsky (1):
      libertas: fix IEEE PS mode in GSPI driver

Gabor Juhos (3):
      ath9k: restore power mode on error path
      ath9k: prevent sleeping while we are waiting for CAB
      ath9k: process rx packet if we are waiting for CAB

Johannes Berg (8):
      sony: fix rfkill code again
      iwlwifi: revamp bss_info_changed
      ath9k: port to cfg80211 rfkill
      mac80211: add queue debugfs file
      mac80211: disconnect when user changes channel
      rfkill: improve docs
      dell-laptop: fix rfkill conversion
      mac80211: fix wext bssid/ssid setting

Jouni Malinen (1):
      mac80211: Do not try to associate with an empty SSID

Nick Kossifidis (1):
      ath5k: fix mesh beaconing

Sebastian Andrzej Siewior (1):
      net/libertas: don't recursive spin lock in if_spi_e2h()

Vasanthakumar Thiagarajan (2):
      ath9k: Add helper to get ath9k specific current channel
      ath9k: Make sure we have current channel in ah_curchan before rf disable/enable

Wey-Yi Guy (3):
      iwlwifi: checking for 40MHz mode
      iwlwifi: check control channel for pure 40MHz
      iwlwifi: check for channel location for 40MHz

 Documentation/rfkill.txt                    |  137 +++++++++++++-------------
 drivers/net/wireless/ath/ath5k/pcu.c        |    5 +-
 drivers/net/wireless/ath/ath9k/Kconfig      |    1 -
 drivers/net/wireless/ath/ath9k/ath9k.h      |   10 +--
 drivers/net/wireless/ath/ath9k/hw.c         |   29 +++---
 drivers/net/wireless/ath/ath9k/hw.h         |    3 -
 drivers/net/wireless/ath/ath9k/main.c       |  130 ++++++++-----------------
 drivers/net/wireless/ath/ath9k/recv.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.c     |  141 ++++++++++++++++-----------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/libertas/if_spi.c      |   11 +-
 drivers/platform/x86/dell-laptop.c          |    2 +-
 drivers/platform/x86/sony-laptop.c          |    5 +-
 net/mac80211/debugfs.c                      |   25 +++++
 net/mac80211/ieee80211_i.h                  |    2 +-
 net/mac80211/mlme.c                         |   38 +++++---
 net/mac80211/util.c                         |   25 -----
 net/mac80211/wext.c                         |   31 +++++-
 19 files changed, 304 insertions(+), 297 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 1b74b5f..c8acd86 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -3,9 +3,8 @@ rfkill - RF kill switch support
 
 1. Introduction
 2. Implementation details
-3. Kernel driver guidelines
-4. Kernel API
-5. Userspace support
+3. Kernel API
+4. Userspace support
 
 
 1. Introduction
@@ -19,82 +18,62 @@ disable all transmitters of a certain type (or all). This is intended for
 situations where transmitters need to be turned off, for example on
 aircraft.
 
+The rfkill subsystem has a concept of "hard" and "soft" block, which
+differ little in their meaning (block == transmitters off) but rather in
+whether they can be changed or not:
+ - hard block: read-only radio block that cannot be overriden by software
+ - soft block: writable radio block (need not be readable) that is set by
+               the system software.
 
 
 2. Implementation details
 
-The rfkill subsystem is composed of various components: the rfkill class, the
-rfkill-input module (an input layer handler), and some specific input layer
-events.
-
-The rfkill class is provided for kernel drivers to register their radio
-transmitter with the kernel, provide methods for turning it on and off and,
-optionally, letting the system know about hardware-disabled states that may
-be implemented on the device. This code is enabled with the CONFIG_RFKILL
-Kconfig option, which drivers can "select".
-
-The rfkill class code also notifies userspace of state changes, this is
-achieved via uevents. It also provides some sysfs files for userspace to
-check the status of radio transmitters. See the "Userspace support" section
-below.
+The rfkill subsystem is composed of three main components:
+ * the rfkill core,
+ * the deprecated rfkill-input module (an input layer handler, being
+   replaced by userspace policy code) and
+ * the rfkill drivers.
 
+The rfkill core provides API for kernel drivers to register their radio
+transmitter with the kernel, methods for turning it on and off and, letting
+the system know about hardware-disabled states that may be implemented on
+the device.
 
-The rfkill-input code implements a basic response to rfkill buttons -- it
-implements turning on/off all devices of a certain class (or all).
+The rfkill core code also notifies userspace of state changes, and provides
+ways for userspace to query the current states. See the "Userspace support"
+section below.
 
 When the device is hard-blocked (either by a call to rfkill_set_hw_state()
-or from query_hw_block) set_block() will be invoked but drivers can well
-ignore the method call since they can use the return value of the function
-rfkill_set_hw_state() to sync the software state instead of keeping track
-of calls to set_block().
-
-
-The entire functionality is spread over more than one subsystem:
-
- * The kernel input layer generates KEY_WWAN, KEY_WLAN etc. and
-   SW_RFKILL_ALL -- when the user presses a button. Drivers for radio
-   transmitters generally do not register to the input layer, unless the
-   device really provides an input device (i.e. a button that has no
-   effect other than generating a button press event)
-
- * The rfkill-input code hooks up to these events and switches the soft-block
-   of the various radio transmitters, depending on the button type.
-
- * The rfkill drivers turn off/on their transmitters as requested.
-
- * The rfkill class will generate userspace notifications (uevents) to tell
-   userspace what the current state is.
+or from query_hw_block) set_block() will be invoked for additional software
+block, but drivers can ignore the method call since they can use the return
+value of the function rfkill_set_hw_state() to sync the software state
+instead of keeping track of calls to set_block(). In fact, drivers should
+use the return value of rfkill_set_hw_state() unless the hardware actually
+keeps track of soft and hard block separately.
 
 
+3. Kernel API
 
-3. Kernel driver guidelines
 
-
-Drivers for radio transmitters normally implement only the rfkill class.
-These drivers may not unblock the transmitter based on own decisions, they
-should act on information provided by the rfkill class only.
+Drivers for radio transmitters normally implement an rfkill driver.
 
 Platform drivers might implement input devices if the rfkill button is just
 that, a button. If that button influences the hardware then you need to
-implement an rfkill class instead. This also applies if the platform provides
+implement an rfkill driver instead. This also applies if the platform provides
 a way to turn on/off the transmitter(s).
 
-During suspend/hibernation, transmitters should only be left enabled when
-wake-on wlan or similar functionality requires it and the device wasn't
-blocked before suspend/hibernate. Note that it may be necessary to update
-the rfkill subsystem's idea of what the current state is at resume time if
-the state may have changed over suspend.
-
+For some platforms, it is possible that the hardware state changes during
+suspend/hibernation, in which case it will be necessary to update the rfkill
+core with the current state is at resume time.
 
+To create an rfkill driver, driver's Kconfig needs to have
 
-4. Kernel API
+	depends on RFKILL || !RFKILL
 
-To build a driver with rfkill subsystem support, the driver should depend on
-(or select) the Kconfig symbol RFKILL.
-
-The hardware the driver talks to may be write-only (where the current state
-of the hardware is unknown), or read-write (where the hardware can be queried
-about its current state).
+to ensure the driver cannot be built-in when rfkill is modular. The !RFKILL
+case allows the driver to be built when rfkill is not configured, which which
+case all rfkill API can still be used but will be provided by static inlines
+which compile to almost nothing.
 
 Calling rfkill_set_hw_state() when a state change happens is required from
 rfkill drivers that control devices that can be hard-blocked unless they also
@@ -105,10 +84,33 @@ device). Don't do this unless you cannot get the event in any other way.
 
 5. Userspace support
 
-The following sysfs entries exist for every rfkill device:
+The recommended userspace interface to use is /dev/rfkill, which is a misc
+character device that allows userspace to obtain and set the state of rfkill
+devices and sets of devices. It also notifies userspace about device addition
+and removal. The API is a simple read/write API that is defined in
+linux/rfkill.h, with one ioctl that allows turning off the deprecated input
+handler in the kernel for the transition period.
+
+Except for the one ioctl, communication with the kernel is done via read()
+and write() of instances of 'struct rfkill_event'. In this structure, the
+soft and hard block are properly separated (unlike sysfs, see below) and
+userspace is able to get a consistent snapshot of all rfkill devices in the
+system. Also, it is possible to switch all rfkill drivers (or all drivers of
+a specified type) into a state which also updates the default state for
+hotplugged devices.
+
+After an application opens /dev/rfkill, it can read the current state of
+all devices, and afterwards can poll the descriptor for hotplug or state
+change events.
+
+Applications must ignore operations (the "op" field) they do not handle,
+this allows the API to be extended in the future.
+
+Additionally, each rfkill device is registered in sysfs and there has the
+following attributes:
 
 	name: Name assigned by driver to this key (interface or driver name).
-	type: Name of the key type ("wlan", "bluetooth", etc).
+	type: Driver type string ("wlan", "bluetooth", etc).
 	state: Current state of the transmitter
 		0: RFKILL_STATE_SOFT_BLOCKED
 			transmitter is turned off by software
@@ -117,7 +119,12 @@ The following sysfs entries exist for every rfkill device:
 		2: RFKILL_STATE_HARD_BLOCKED
 			transmitter is forced off by something outside of
 			the driver's control.
-	claim: 0: Kernel handles events (currently always reads that value)
+	       This file is deprecated because it can only properly show
+	       three of the four possible states, soft-and-hard-blocked is
+	       missing.
+	claim: 0: Kernel handles events
+	       This file is deprecated because there no longer is a way to
+	       claim just control over a single rfkill instance.
 
 rfkill devices also issue uevents (with an action of "change"), with the
 following environment variables set:
@@ -128,9 +135,3 @@ RFKILL_TYPE
 
 The contents of these variables corresponds to the "name", "state" and
 "type" sysfs files explained above.
-
-An alternative userspace interface exists as a misc device /dev/rfkill,
-which allows userspace to obtain and set the state of rfkill devices and
-sets of devices. It also notifies userspace about device addition and
-removal. The API is a simple read/write API that is defined in
-linux/rfkill.h.
diff --git a/drivers/net/wireless/ath/ath5k/pcu.c b/drivers/net/wireless/ath/ath5k/pcu.c
index ec35503..2942f13 100644
--- a/drivers/net/wireless/ath/ath5k/pcu.c
+++ b/drivers/net/wireless/ath/ath5k/pcu.c
@@ -733,8 +733,9 @@ void ath5k_hw_init_beacon(struct ath5k_hw *ah, u32 next_beacon, u32 interval)
 	/*
 	 * Set the beacon register and enable all timers.
 	 */
-	/* When in AP mode zero timer0 to start TSF */
-	if (ah->ah_op_mode == NL80211_IFTYPE_AP)
+	/* When in AP or Mesh Point mode zero timer0 to start TSF */
+	if (ah->ah_op_mode == NL80211_IFTYPE_AP ||
+	    ah->ah_op_mode == NL80211_IFTYPE_MESH_POINT)
 		ath5k_hw_reg_write(ah, 0, AR5K_TIMER0);
 
 	ath5k_hw_reg_write(ah, next_beacon, AR5K_TIMER0);
diff --git a/drivers/net/wireless/ath/ath9k/Kconfig b/drivers/net/wireless/ath/ath9k/Kconfig
index 0ed1ac3..2d79610 100644
--- a/drivers/net/wireless/ath/ath9k/Kconfig
+++ b/drivers/net/wireless/ath/ath9k/Kconfig
@@ -1,7 +1,6 @@
 config ATH9K
 	tristate "Atheros 802.11n wireless cards support"
 	depends on PCI && MAC80211 && WLAN_80211
-	depends on RFKILL || RFKILL=n
 	select ATH_COMMON
 	select MAC80211_LEDS
 	select LEDS_CLASS
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 515880a..5efc934 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -21,7 +21,6 @@
 #include <linux/device.h>
 #include <net/mac80211.h>
 #include <linux/leds.h>
-#include <linux/rfkill.h>
 
 #include "hw.h"
 #include "rc.h"
@@ -460,12 +459,6 @@ struct ath_led {
 	bool registered;
 };
 
-struct ath_rfkill {
-	struct rfkill *rfkill;
-	struct rfkill_ops ops;
-	char rfkill_name[32];
-};
-
 /********************/
 /* Main driver core */
 /********************/
@@ -505,7 +498,6 @@ struct ath_rfkill {
 #define SC_OP_PROTECT_ENABLE    BIT(6)
 #define SC_OP_RXFLUSH           BIT(7)
 #define SC_OP_LED_ASSOCIATED    BIT(8)
-#define SC_OP_RFKILL_REGISTERED BIT(9)
 #define SC_OP_WAIT_FOR_BEACON   BIT(12)
 #define SC_OP_LED_ON            BIT(13)
 #define SC_OP_SCANNING          BIT(14)
@@ -591,7 +583,6 @@ struct ath_softc {
 
 	int beacon_interval;
 
-	struct ath_rfkill rf_kill;
 	struct ath_ani ani;
 	struct ath9k_node_stats nodestats;
 #ifdef CONFIG_ATH9K_DEBUG
@@ -677,6 +668,7 @@ static inline void ath9k_ps_restore(struct ath_softc *sc)
 	if (atomic_dec_and_test(&sc->ps_usecount))
 		if ((sc->hw->conf.flags & IEEE80211_CONF_PS) &&
 		    !(sc->sc_flags & (SC_OP_WAIT_FOR_BEACON |
+				      SC_OP_WAIT_FOR_CAB |
 				      SC_OP_WAIT_FOR_PSPOLL_DATA |
 				      SC_OP_WAIT_FOR_TX_ACK)))
 			ath9k_hw_setpower(sc->sc_ah,
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 1579c94..34935a8 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2186,6 +2186,18 @@ static void ath9k_hw_spur_mitigate(struct ath_hw *ah, struct ath9k_channel *chan
 	REG_WRITE(ah, AR_PHY_MASK2_P_61_45, tmp_mask);
 }
 
+static void ath9k_enable_rfkill(struct ath_hw *ah)
+{
+	REG_SET_BIT(ah, AR_GPIO_INPUT_EN_VAL,
+		    AR_GPIO_INPUT_EN_VAL_RFSILENT_BB);
+
+	REG_CLR_BIT(ah, AR_GPIO_INPUT_MUX2,
+		    AR_GPIO_INPUT_MUX2_RFSILENT);
+
+	ath9k_hw_cfg_gpio_input(ah, ah->rfkill_gpio);
+	REG_SET_BIT(ah, AR_PHY_TEST, RFSILENT_BB);
+}
+
 int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 		    bool bChannelChange)
 {
@@ -2313,10 +2325,9 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	ath9k_hw_init_interrupt_masks(ah, ah->opmode);
 	ath9k_hw_init_qos(ah);
 
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
 	if (ah->caps.hw_caps & ATH9K_HW_CAP_RFSILENT)
 		ath9k_enable_rfkill(ah);
-#endif
+
 	ath9k_hw_init_user_settings(ah);
 
 	REG_WRITE(ah, AR_STA_ID1,
@@ -3613,20 +3624,6 @@ void ath9k_hw_set_gpio(struct ath_hw *ah, u32 gpio, u32 val)
 		AR_GPIO_BIT(gpio));
 }
 
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
-void ath9k_enable_rfkill(struct ath_hw *ah)
-{
-	REG_SET_BIT(ah, AR_GPIO_INPUT_EN_VAL,
-		    AR_GPIO_INPUT_EN_VAL_RFSILENT_BB);
-
-	REG_CLR_BIT(ah, AR_GPIO_INPUT_MUX2,
-		    AR_GPIO_INPUT_MUX2_RFSILENT);
-
-	ath9k_hw_cfg_gpio_input(ah, ah->rfkill_gpio);
-	REG_SET_BIT(ah, AR_PHY_TEST, RFSILENT_BB);
-}
-#endif
-
 u32 ath9k_hw_getdefantenna(struct ath_hw *ah)
 {
 	return REG_READ(ah, AR_DEF_ANTENNA) & 0x7;
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index dd8508e..9d0b31a 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -565,9 +565,6 @@ u32 ath9k_hw_gpio_get(struct ath_hw *ah, u32 gpio);
 void ath9k_hw_cfg_output(struct ath_hw *ah, u32 gpio,
 			 u32 ah_signal_type);
 void ath9k_hw_set_gpio(struct ath_hw *ah, u32 gpio, u32 val);
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
-void ath9k_enable_rfkill(struct ath_hw *ah);
-#endif
 u32 ath9k_hw_getdefantenna(struct ath_hw *ah);
 void ath9k_hw_setantenna(struct ath_hw *ah, u32 antenna);
 bool ath9k_hw_setantennaswitch(struct ath_hw *ah,
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index f7baa40..9f49a32 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -231,6 +231,19 @@ static void ath_setup_rates(struct ath_softc *sc, enum ieee80211_band band)
 	}
 }
 
+static struct ath9k_channel *ath_get_curchannel(struct ath_softc *sc,
+						struct ieee80211_hw *hw)
+{
+	struct ieee80211_channel *curchan = hw->conf.channel;
+	struct ath9k_channel *channel;
+	u8 chan_idx;
+
+	chan_idx = curchan->hw_value;
+	channel = &sc->sc_ah->channels[chan_idx];
+	ath9k_update_ichannel(sc, hw, channel);
+	return channel;
+}
+
 /*
  * Set/change channels.  If the channel is really being changed, it's done
  * by reseting the chip.  To accomplish this we must first cleanup any pending
@@ -283,7 +296,7 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 			"reset status %d\n",
 			channel->center_freq, r);
 		spin_unlock_bh(&sc->sc_resetlock);
-		return r;
+		goto ps_restore;
 	}
 	spin_unlock_bh(&sc->sc_resetlock);
 
@@ -292,14 +305,17 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	if (ath_startrecv(sc) != 0) {
 		DPRINTF(sc, ATH_DBG_FATAL,
 			"Unable to restart recv logic\n");
-		return -EIO;
+		r = -EIO;
+		goto ps_restore;
 	}
 
 	ath_cache_conf_rate(sc, &hw->conf);
 	ath_update_txpow(sc);
 	ath9k_hw_set_interrupts(ah, sc->imask);
+
+ ps_restore:
 	ath9k_ps_restore(sc);
-	return 0;
+	return r;
 }
 
 /*
@@ -1110,6 +1126,9 @@ void ath_radio_enable(struct ath_softc *sc)
 	ath9k_ps_wakeup(sc);
 	ath9k_hw_configpcipowersave(ah, 0);
 
+	if (!ah->curchan)
+		ah->curchan = ath_get_curchannel(sc, sc->hw);
+
 	spin_lock_bh(&sc->sc_resetlock);
 	r = ath9k_hw_reset(ah, ah->curchan, false);
 	if (r) {
@@ -1162,6 +1181,9 @@ void ath_radio_disable(struct ath_softc *sc)
 	ath_stoprecv(sc);		/* turn off frame recv */
 	ath_flushrecv(sc);		/* flush recv queue */
 
+	if (!ah->curchan)
+		ah->curchan = ath_get_curchannel(sc, sc->hw);
+
 	spin_lock_bh(&sc->sc_resetlock);
 	r = ath9k_hw_reset(ah, ah->curchan, false);
 	if (r) {
@@ -1178,8 +1200,6 @@ void ath_radio_disable(struct ath_softc *sc)
 	ath9k_ps_restore(sc);
 }
 
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
-
 /*******************/
 /*	Rfkill	   */
 /*******************/
@@ -1192,81 +1212,27 @@ static bool ath_is_rfkill_set(struct ath_softc *sc)
 				  ah->rfkill_polarity;
 }
 
-/* s/w rfkill handlers */
-static int ath_rfkill_set_block(void *data, bool blocked)
+static void ath9k_rfkill_poll_state(struct ieee80211_hw *hw)
 {
-	struct ath_softc *sc = data;
-
-	if (blocked)
-		ath_radio_disable(sc);
-	else
-		ath_radio_enable(sc);
-
-	return 0;
-}
-
-static void ath_rfkill_poll_state(struct rfkill *rfkill, void *data)
-{
-	struct ath_softc *sc = data;
+	struct ath_wiphy *aphy = hw->priv;
+	struct ath_softc *sc = aphy->sc;
 	bool blocked = !!ath_is_rfkill_set(sc);
 
-	if (rfkill_set_hw_state(rfkill, blocked))
+	wiphy_rfkill_set_hw_state(hw->wiphy, blocked);
+
+	if (blocked)
 		ath_radio_disable(sc);
 	else
 		ath_radio_enable(sc);
 }
 
-/* Init s/w rfkill */
-static int ath_init_sw_rfkill(struct ath_softc *sc)
-{
-	sc->rf_kill.ops.set_block = ath_rfkill_set_block;
-	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_RFSILENT)
-		sc->rf_kill.ops.poll = ath_rfkill_poll_state;
-
-	snprintf(sc->rf_kill.rfkill_name, sizeof(sc->rf_kill.rfkill_name),
-		"ath9k-%s::rfkill", wiphy_name(sc->hw->wiphy));
-
-	sc->rf_kill.rfkill = rfkill_alloc(sc->rf_kill.rfkill_name,
-					  wiphy_dev(sc->hw->wiphy),
-					  RFKILL_TYPE_WLAN,
-					  &sc->rf_kill.ops, sc);
-	if (!sc->rf_kill.rfkill) {
-		DPRINTF(sc, ATH_DBG_FATAL, "Failed to allocate rfkill\n");
-		return -ENOMEM;
-	}
-
-	return 0;
-}
-
-/* Deinitialize rfkill */
-static void ath_deinit_rfkill(struct ath_softc *sc)
-{
-	if (sc->sc_flags & SC_OP_RFKILL_REGISTERED) {
-		rfkill_unregister(sc->rf_kill.rfkill);
-		rfkill_destroy(sc->rf_kill.rfkill);
-		sc->sc_flags &= ~SC_OP_RFKILL_REGISTERED;
-	}
-}
-
-static int ath_start_rfkill_poll(struct ath_softc *sc)
+static void ath_start_rfkill_poll(struct ath_softc *sc)
 {
-	if (!(sc->sc_flags & SC_OP_RFKILL_REGISTERED)) {
-		if (rfkill_register(sc->rf_kill.rfkill)) {
-			DPRINTF(sc, ATH_DBG_FATAL,
-				"Unable to register rfkill\n");
-			rfkill_destroy(sc->rf_kill.rfkill);
-
-			/* Deinitialize the device */
-			ath_cleanup(sc);
-			return -EIO;
-		} else {
-			sc->sc_flags |= SC_OP_RFKILL_REGISTERED;
-		}
-	}
+	struct ath_hw *ah = sc->sc_ah;
 
-	return 0;
+	if (ah->caps.hw_caps & ATH9K_HW_CAP_RFSILENT)
+		wiphy_rfkill_start_polling(sc->hw->wiphy);
 }
-#endif /* CONFIG_RFKILL */
 
 void ath_cleanup(struct ath_softc *sc)
 {
@@ -1286,9 +1252,6 @@ void ath_detach(struct ath_softc *sc)
 
 	DPRINTF(sc, ATH_DBG_CONFIG, "Detach ATH hw\n");
 
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
-	ath_deinit_rfkill(sc);
-#endif
 	ath_deinit_leds(sc);
 	cancel_work_sync(&sc->chan_work);
 	cancel_delayed_work_sync(&sc->wiphy_work);
@@ -1626,13 +1589,6 @@ int ath_attach(u16 devid, struct ath_softc *sc)
 	if (error != 0)
 		goto error_attach;
 
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
-	/* Initialize s/w rfkill */
-	error = ath_init_sw_rfkill(sc);
-	if (error)
-		goto error_attach;
-#endif
-
 	INIT_WORK(&sc->chan_work, ath9k_wiphy_chan_work);
 	INIT_DELAYED_WORK(&sc->wiphy_work, ath9k_wiphy_work);
 	sc->wiphy_scheduler_int = msecs_to_jiffies(500);
@@ -1648,6 +1604,7 @@ int ath_attach(u16 devid, struct ath_softc *sc)
 	/* Initialize LED control */
 	ath_init_leds(sc);
 
+	ath_start_rfkill_poll(sc);
 
 	return 0;
 
@@ -1920,7 +1877,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	struct ath_softc *sc = aphy->sc;
 	struct ieee80211_channel *curchan = hw->conf.channel;
 	struct ath9k_channel *init_channel;
-	int r, pos;
+	int r;
 
 	DPRINTF(sc, ATH_DBG_CONFIG, "Starting driver with "
 		"initial channel: %d MHz\n", curchan->center_freq);
@@ -1950,11 +1907,9 @@ static int ath9k_start(struct ieee80211_hw *hw)
 
 	/* setup initial channel */
 
-	pos = curchan->hw_value;
+	sc->chan_idx = curchan->hw_value;
 
-	sc->chan_idx = pos;
-	init_channel = &sc->sc_ah->channels[pos];
-	ath9k_update_ichannel(sc, hw, init_channel);
+	init_channel = ath_get_curchannel(sc, hw);
 
 	/* Reset SERDES registers */
 	ath9k_hw_configpcipowersave(sc->sc_ah, 0);
@@ -2018,10 +1973,6 @@ static int ath9k_start(struct ieee80211_hw *hw)
 
 	ieee80211_wake_queues(hw);
 
-#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
-	r = ath_start_rfkill_poll(sc);
-#endif
-
 mutex_unlock:
 	mutex_unlock(&sc->mutex);
 
@@ -2159,7 +2110,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 	} else
 		sc->rx.rxlink = NULL;
 
-	rfkill_pause_polling(sc->rf_kill.rfkill);
+	wiphy_rfkill_stop_polling(sc->hw->wiphy);
 
 	/* disable HAL and put h/w to sleep */
 	ath9k_hw_disable(sc->sc_ah);
@@ -2765,6 +2716,7 @@ struct ieee80211_ops ath9k_ops = {
 	.ampdu_action       = ath9k_ampdu_action,
 	.sw_scan_start      = ath9k_sw_scan_start,
 	.sw_scan_complete   = ath9k_sw_scan_complete,
+	.rfkill_poll        = ath9k_rfkill_poll_state,
 };
 
 static struct {
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 5014a19..f99f3a7 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -817,6 +817,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 		}
 
 		if (unlikely(sc->sc_flags & (SC_OP_WAIT_FOR_BEACON |
+					     SC_OP_WAIT_FOR_CAB |
 					     SC_OP_WAIT_FOR_PSPOLL_DATA)))
 			ath_rx_ps(sc, skb);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index a5637c4..6d1519e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2152,7 +2152,6 @@ static int iwl_mac_start(struct ieee80211_hw *hw)
 	/* we should be verifying the device is ready to be opened */
 	mutex_lock(&priv->mutex);
 
-	memset(&priv->staging_rxon, 0, sizeof(struct iwl_rxon_cmd));
 	/* fetch ucode file from disk, alloc and copy to bus-master buffers ...
 	 * ucode filename and max sizes are card-specific. */
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index f9d16ca..6ab0716 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -629,13 +629,9 @@ u8 iwl_is_fat_tx_allowed(struct iwl_priv *priv,
 		if (!sta_ht_inf->ht_supported)
 			return 0;
 	}
-
-	if (iwl_ht_conf->ht_protection & IEEE80211_HT_OP_MODE_PROTECTION_20MHZ)
-		return 1;
-	else
-		return iwl_is_channel_extension(priv, priv->band,
-				le16_to_cpu(priv->staging_rxon.channel),
-				iwl_ht_conf->extension_chan_offset);
+	return iwl_is_channel_extension(priv, priv->band,
+			le16_to_cpu(priv->staging_rxon.channel),
+			iwl_ht_conf->extension_chan_offset);
 }
 EXPORT_SYMBOL(iwl_is_fat_tx_allowed);
 
@@ -826,9 +822,18 @@ void iwl_set_rxon_ht(struct iwl_priv *priv, struct iwl_ht_info *ht_info)
 			 RXON_FLG_CTRL_CHANNEL_LOC_HI_MSK);
 	if (iwl_is_fat_tx_allowed(priv, NULL)) {
 		/* pure 40 fat */
-		if (rxon->flags & RXON_FLG_FAT_PROT_MSK)
+		if (ht_info->ht_protection == IEEE80211_HT_OP_MODE_PROTECTION_20MHZ) {
 			rxon->flags |= RXON_FLG_CHANNEL_MODE_PURE_40;
-		else {
+			/* Note: control channel is opposite of extension channel */
+			switch (ht_info->extension_chan_offset) {
+			case IEEE80211_HT_PARAM_CHA_SEC_ABOVE:
+				rxon->flags &= ~RXON_FLG_CTRL_CHANNEL_LOC_HI_MSK;
+				break;
+			case IEEE80211_HT_PARAM_CHA_SEC_BELOW:
+				rxon->flags |= RXON_FLG_CTRL_CHANNEL_LOC_HI_MSK;
+				break;
+			}
+		} else {
 			/* Note: control channel is opposite of extension channel */
 			switch (ht_info->extension_chan_offset) {
 			case IEEE80211_HT_PARAM_CHA_SEC_ABOVE:
@@ -2390,39 +2395,46 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 		priv->ibss_beacon = ieee80211_beacon_get(hw, vif);
 	}
 
-	if ((changes & BSS_CHANGED_BSSID) && !iwl_is_rfkill(priv)) {
-		/* If there is currently a HW scan going on in the background
-		 * then we need to cancel it else the RXON below will fail. */
+	if (changes & BSS_CHANGED_BEACON_INT) {
+		priv->beacon_int = bss_conf->beacon_int;
+		/* TODO: in AP mode, do something to make this take effect */
+	}
+
+	if (changes & BSS_CHANGED_BSSID) {
+		IWL_DEBUG_MAC80211(priv, "BSSID %pM\n", bss_conf->bssid);
+
+		/*
+		 * If there is currently a HW scan going on in the
+		 * background then we need to cancel it else the RXON
+		 * below/in post_associate will fail.
+		 */
 		if (iwl_scan_cancel_timeout(priv, 100)) {
-			IWL_WARN(priv, "Aborted scan still in progress "
-				    "after 100ms\n");
+			IWL_WARN(priv, "Aborted scan still in progress after 100ms\n");
 			IWL_DEBUG_MAC80211(priv, "leaving - scan abort failed.\n");
 			mutex_unlock(&priv->mutex);
 			return;
 		}
-		memcpy(priv->staging_rxon.bssid_addr,
-		       bss_conf->bssid, ETH_ALEN);
-
-		/* TODO: Audit driver for usage of these members and see
-		 * if mac80211 deprecates them (priv->bssid looks like it
-		 * shouldn't be there, but I haven't scanned the IBSS code
-		 * to verify) - jpk */
-		memcpy(priv->bssid, bss_conf->bssid, ETH_ALEN);
-
-		if (priv->iw_mode == NL80211_IFTYPE_AP)
-			iwlcore_config_ap(priv);
-		else {
-			int rc = iwlcore_commit_rxon(priv);
-			if ((priv->iw_mode == NL80211_IFTYPE_STATION) && rc)
-				iwl_rxon_add_station(
-					priv, priv->active_rxon.bssid_addr, 1);
+
+		/* mac80211 only sets assoc when in STATION mode */
+		if (priv->iw_mode == NL80211_IFTYPE_ADHOC ||
+		    bss_conf->assoc) {
+			memcpy(priv->staging_rxon.bssid_addr,
+			       bss_conf->bssid, ETH_ALEN);
+
+			/* currently needed in a few places */
+			memcpy(priv->bssid, bss_conf->bssid, ETH_ALEN);
+		} else {
+			priv->staging_rxon.filter_flags &=
+				~RXON_FILTER_ASSOC_MSK;
 		}
-	} else if (!iwl_is_rfkill(priv)) {
-		iwl_scan_cancel_timeout(priv, 100);
-		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
-		iwlcore_commit_rxon(priv);
+
 	}
 
+	/*
+	 * This needs to be after setting the BSSID in case
+	 * mac80211 decides to do both changes at once because
+	 * it will invoke post_associate.
+	 */
 	if (priv->iw_mode == NL80211_IFTYPE_ADHOC &&
 	    changes & BSS_CHANGED_BEACON) {
 		struct sk_buff *beacon = ieee80211_beacon_get(hw, vif);
@@ -2431,8 +2443,6 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 			iwl_mac_beacon_update(hw, beacon);
 	}
 
-	mutex_unlock(&priv->mutex);
-
 	if (changes & BSS_CHANGED_ERP_PREAMBLE) {
 		IWL_DEBUG_MAC80211(priv, "ERP_PREAMBLE %d\n",
 				   bss_conf->use_short_preamble);
@@ -2450,6 +2460,23 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 			priv->staging_rxon.flags &= ~RXON_FLG_TGG_PROTECT_MSK;
 	}
 
+	if (changes & BSS_CHANGED_BASIC_RATES) {
+		/* XXX use this information
+		 *
+		 * To do that, remove code from iwl_set_rate() and put something
+		 * like this here:
+		 *
+		if (A-band)
+			priv->staging_rxon.ofdm_basic_rates =
+				bss_conf->basic_rates;
+		else
+			priv->staging_rxon.ofdm_basic_rates =
+				bss_conf->basic_rates >> 4;
+			priv->staging_rxon.cck_basic_rates =
+				bss_conf->basic_rates & 0xF;
+		 */
+	}
+
 	if (changes & BSS_CHANGED_HT) {
 		iwl_ht_conf(priv, bss_conf);
 
@@ -2459,10 +2486,6 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 
 	if (changes & BSS_CHANGED_ASSOC) {
 		IWL_DEBUG_MAC80211(priv, "ASSOC %d\n", bss_conf->assoc);
-		/* This should never happen as this function should
-		 * never be called from interrupt context. */
-		if (WARN_ON_ONCE(in_interrupt()))
-			return;
 		if (bss_conf->assoc) {
 			priv->assoc_id = bss_conf->aid;
 			priv->beacon_int = bss_conf->beacon_int;
@@ -2470,27 +2493,35 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 			priv->timestamp = bss_conf->timestamp;
 			priv->assoc_capability = bss_conf->assoc_capability;
 
-			/* we have just associated, don't start scan too early
-			 * leave time for EAPOL exchange to complete
+			/*
+			 * We have just associated, don't start scan too early
+			 * leave time for EAPOL exchange to complete.
+			 *
+			 * XXX: do this in mac80211
 			 */
 			priv->next_scan_jiffies = jiffies +
 					IWL_DELAY_NEXT_SCAN_AFTER_ASSOC;
-			mutex_lock(&priv->mutex);
-			priv->cfg->ops->lib->post_associate(priv);
-			mutex_unlock(&priv->mutex);
-		} else {
+			if (!iwl_is_rfkill(priv))
+				priv->cfg->ops->lib->post_associate(priv);
+		} else
 			priv->assoc_id = 0;
-			IWL_DEBUG_MAC80211(priv, "DISASSOC %d\n", bss_conf->assoc);
+
+	}
+
+	if (changes && iwl_is_associated(priv) && priv->assoc_id) {
+		IWL_DEBUG_MAC80211(priv, "Changes (%#x) while associated\n",
+				   changes);
+		ret = iwl_send_rxon_assoc(priv);
+		if (!ret) {
+			/* Sync active_rxon with latest change. */
+			memcpy((void *)&priv->active_rxon,
+				&priv->staging_rxon,
+				sizeof(struct iwl_rxon_cmd));
 		}
-	} else if (changes && iwl_is_associated(priv) && priv->assoc_id) {
-			IWL_DEBUG_MAC80211(priv, "Associated Changes %d\n", changes);
-			ret = iwl_send_rxon_assoc(priv);
-			if (!ret)
-				/* Sync active_rxon with latest change. */
-				memcpy((void *)&priv->active_rxon,
-					&priv->staging_rxon,
-					sizeof(struct iwl_rxon_cmd));
 	}
+
+	mutex_unlock(&priv->mutex);
+
 	IWL_DEBUG_MAC80211(priv, "leave\n");
 }
 EXPORT_SYMBOL(iwl_bss_info_changed);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 83d3160..cb9bd4c 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2498,8 +2498,7 @@ static void iwl3945_alive_start(struct iwl_priv *priv)
 		struct iwl3945_rxon_cmd *active_rxon =
 				(struct iwl3945_rxon_cmd *)(&priv->active_rxon);
 
-		memcpy(&priv->staging_rxon, &priv->active_rxon,
-		       sizeof(priv->staging_rxon));
+		priv->staging_rxon.filter_flags |= RXON_FILTER_ASSOC_MSK;
 		active_rxon->filter_flags &= ~RXON_FILTER_ASSOC_MSK;
 	} else {
 		/* Initialize our rx_config data */
@@ -3147,7 +3146,6 @@ static int iwl3945_mac_start(struct ieee80211_hw *hw)
 	/* we should be verifying the device is ready to be opened */
 	mutex_lock(&priv->mutex);
 
-	memset(&priv->staging_rxon, 0, sizeof(priv->staging_rxon));
 	/* fetch ucode file from disk, alloc and copy to bus-master buffers ...
 	 * ucode filename and max sizes are card-specific. */
 
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index f8c2898..923ed58 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -812,7 +812,6 @@ out:
 static void if_spi_e2h(struct if_spi_card *card)
 {
 	int err = 0;
-	unsigned long flags;
 	u32 cause;
 	struct lbs_private *priv = card->priv;
 
@@ -827,10 +826,7 @@ static void if_spi_e2h(struct if_spi_card *card)
 	/* generate a card interrupt */
 	spu_write_u16(card, IF_SPI_CARD_INT_CAUSE_REG, IF_SPI_CIC_HOST_EVENT);
 
-	spin_lock_irqsave(&priv->driver_lock, flags);
 	lbs_queue_event(priv, cause & 0xff);
-	spin_unlock_irqrestore(&priv->driver_lock, flags);
-
 out:
 	if (err)
 		lbs_pr_err("%s: error %d\n", __func__, err);
@@ -875,7 +871,12 @@ static int lbs_spi_thread(void *data)
 			err = if_spi_c2h_data(card);
 			if (err)
 				goto err;
-		if (hiStatus & IF_SPI_HIST_CMD_DOWNLOAD_RDY) {
+
+		/* workaround: in PS mode, the card does not set the Command
+		 * Download Ready bit, but it sets TX Download Ready. */
+		if (hiStatus & IF_SPI_HIST_CMD_DOWNLOAD_RDY ||
+		   (card->priv->psstate != PS_STATE_FULL_POWER &&
+		    (hiStatus & IF_SPI_HIST_TX_DOWNLOAD_RDY))) {
 			/* This means two things. First of all,
 			 * if there was a previous command sent, the card has
 			 * successfully received it.
diff --git a/drivers/platform/x86/dell-laptop.c b/drivers/platform/x86/dell-laptop.c
index 2faf0e1..74909c4 100644
--- a/drivers/platform/x86/dell-laptop.c
+++ b/drivers/platform/x86/dell-laptop.c
@@ -177,7 +177,7 @@ dell_send_request(struct calling_interface_buffer *buffer, int class,
 static int dell_rfkill_set(void *data, bool blocked)
 {
 	struct calling_interface_buffer buffer;
-	int disable = blocked ? 0 : 1;
+	int disable = blocked ? 1 : 0;
 	unsigned long radio = (unsigned long)data;
 
 	memset(&buffer, 0, sizeof(struct calling_interface_buffer));
diff --git a/drivers/platform/x86/sony-laptop.c b/drivers/platform/x86/sony-laptop.c
index e48d9a4..dafaa4a 100644
--- a/drivers/platform/x86/sony-laptop.c
+++ b/drivers/platform/x86/sony-laptop.c
@@ -1133,8 +1133,9 @@ static void sony_nc_rfkill_update()
 			continue;
 
 		if (hwblock) {
-			if (rfkill_set_hw_state(sony_rfkill_devices[i], true))
-				sony_nc_rfkill_set((void *)i, true);
+			if (rfkill_set_hw_state(sony_rfkill_devices[i], true)) {
+				/* we already know we're blocked */
+			}
 			continue;
 		}
 
diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index 11c7231..6c439cd 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -163,6 +163,29 @@ static const struct file_operations noack_ops = {
 	.open = mac80211_open_file_generic
 };
 
+static ssize_t queues_read(struct file *file, char __user *user_buf,
+			   size_t count, loff_t *ppos)
+{
+	struct ieee80211_local *local = file->private_data;
+	unsigned long flags;
+	char buf[IEEE80211_MAX_QUEUES * 20];
+	int q, res = 0;
+
+	spin_lock_irqsave(&local->queue_stop_reason_lock, flags);
+	for (q = 0; q < local->hw.queues; q++)
+		res += sprintf(buf + res, "%02d: %#.8lx/%d\n", q,
+				local->queue_stop_reasons[q],
+				__netif_subqueue_stopped(local->mdev, q));
+	spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
+
+	return simple_read_from_buffer(user_buf, count, ppos, buf, res);
+}
+
+static const struct file_operations queues_ops = {
+	.read = queues_read,
+	.open = mac80211_open_file_generic
+};
+
 /* statistics stuff */
 
 #define DEBUGFS_STATS_FILE(name, buflen, fmt, value...)			\
@@ -298,6 +321,7 @@ void debugfs_hw_add(struct ieee80211_local *local)
 	DEBUGFS_ADD(total_ps_buffered);
 	DEBUGFS_ADD(wep_iv);
 	DEBUGFS_ADD(tsf);
+	DEBUGFS_ADD(queues);
 	DEBUGFS_ADD_MODE(reset, 0200);
 	DEBUGFS_ADD(noack);
 
@@ -350,6 +374,7 @@ void debugfs_hw_del(struct ieee80211_local *local)
 	DEBUGFS_DEL(total_ps_buffered);
 	DEBUGFS_DEL(wep_iv);
 	DEBUGFS_DEL(tsf);
+	DEBUGFS_DEL(queues);
 	DEBUGFS_DEL(reset);
 	DEBUGFS_DEL(noack);
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 4dbc289..68eb505 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -783,6 +783,7 @@ struct ieee80211_local {
 		struct dentry *total_ps_buffered;
 		struct dentry *wep_iv;
 		struct dentry *tsf;
+		struct dentry *queues;
 		struct dentry *reset;
 		struct dentry *noack;
 		struct dentry *statistics;
@@ -1100,7 +1101,6 @@ void ieee802_11_parse_elems(u8 *start, size_t len,
 u32 ieee802_11_parse_elems_crc(u8 *start, size_t len,
 			       struct ieee802_11_elems *elems,
 			       u64 filter, u32 crc);
-int ieee80211_set_freq(struct ieee80211_sub_if_data *sdata, int freq);
 u32 ieee80211_mandatory_rates(struct ieee80211_local *local,
 			      enum ieee80211_band band);
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index d779c57..aca22b0 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1102,14 +1102,6 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 	struct sta_info *sta;
 	u32 changed = 0, config_changed = 0;
 
-	rcu_read_lock();
-
-	sta = sta_info_get(local, ifmgd->bssid);
-	if (!sta) {
-		rcu_read_unlock();
-		return;
-	}
-
 	if (deauth) {
 		ifmgd->direct_probe_tries = 0;
 		ifmgd->auth_tries = 0;
@@ -1120,7 +1112,11 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 	netif_tx_stop_all_queues(sdata->dev);
 	netif_carrier_off(sdata->dev);
 
-	ieee80211_sta_tear_down_BA_sessions(sta);
+	rcu_read_lock();
+	sta = sta_info_get(local, ifmgd->bssid);
+	if (sta)
+		ieee80211_sta_tear_down_BA_sessions(sta);
+	rcu_read_unlock();
 
 	bss = ieee80211_rx_bss_get(local, ifmgd->bssid,
 				   conf->channel->center_freq,
@@ -1156,8 +1152,6 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 				ifmgd->ssid, ifmgd->ssid_len);
 	}
 
-	rcu_read_unlock();
-
 	ieee80211_set_wmm_default(sdata);
 
 	ieee80211_recalc_idle(local);
@@ -2223,7 +2217,10 @@ static int ieee80211_sta_config_auth(struct ieee80211_sub_if_data *sdata)
 				       capa_mask, capa_val);
 
 	if (bss) {
-		ieee80211_set_freq(sdata, bss->cbss.channel->center_freq);
+		local->oper_channel = bss->cbss.channel;
+		local->oper_channel_type = NL80211_CHAN_NO_HT;
+		ieee80211_hw_config(local, 0);
+
 		if (!(ifmgd->flags & IEEE80211_STA_SSID_SET))
 			ieee80211_sta_set_ssid(sdata, bss->ssid,
 					       bss->ssid_len);
@@ -2445,6 +2442,14 @@ void ieee80211_sta_req_auth(struct ieee80211_sub_if_data *sdata)
 			ieee80211_set_disassoc(sdata, true, true,
 					       WLAN_REASON_DEAUTH_LEAVING);
 
+		if (ifmgd->ssid_len == 0) {
+			/*
+			 * Only allow association to be started if a valid SSID
+			 * is configured.
+			 */
+			return;
+		}
+
 		if (!(ifmgd->flags & IEEE80211_STA_EXT_SME) ||
 		    ifmgd->state != IEEE80211_STA_MLME_ASSOCIATE)
 			set_bit(IEEE80211_STA_REQ_AUTH, &ifmgd->request);
@@ -2476,6 +2481,10 @@ int ieee80211_sta_set_ssid(struct ieee80211_sub_if_data *sdata, char *ssid, size
 	ifmgd = &sdata->u.mgd;
 
 	if (ifmgd->ssid_len != len || memcmp(ifmgd->ssid, ssid, len) != 0) {
+		if (ifmgd->state == IEEE80211_STA_MLME_ASSOCIATED)
+			ieee80211_set_disassoc(sdata, true, true,
+					       WLAN_REASON_DEAUTH_LEAVING);
+
 		/*
 		 * Do not use reassociation if SSID is changed (different ESS).
 		 */
@@ -2500,6 +2509,11 @@ int ieee80211_sta_set_bssid(struct ieee80211_sub_if_data *sdata, u8 *bssid)
 {
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
 
+	if (compare_ether_addr(bssid, ifmgd->bssid) != 0 &&
+	    ifmgd->state == IEEE80211_STA_MLME_ASSOCIATED)
+		ieee80211_set_disassoc(sdata, true, true,
+				       WLAN_REASON_DEAUTH_LEAVING);
+
 	if (is_valid_ether_addr(bssid)) {
 		memcpy(ifmgd->bssid, bssid, ETH_ALEN);
 		ifmgd->flags |= IEEE80211_STA_BSSID_SET;
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 66ce96a..915e777 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -774,31 +774,6 @@ void ieee80211_tx_skb(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb,
 	dev_queue_xmit(skb);
 }
 
-int ieee80211_set_freq(struct ieee80211_sub_if_data *sdata, int freqMHz)
-{
-	int ret = -EINVAL;
-	struct ieee80211_channel *chan;
-	struct ieee80211_local *local = sdata->local;
-
-	chan = ieee80211_get_channel(local->hw.wiphy, freqMHz);
-
-	if (chan && !(chan->flags & IEEE80211_CHAN_DISABLED)) {
-		if (sdata->vif.type == NL80211_IFTYPE_ADHOC &&
-		    chan->flags & IEEE80211_CHAN_NO_IBSS)
-			return ret;
-		local->oper_channel = chan;
-		local->oper_channel_type = NL80211_CHAN_NO_HT;
-
-		if (local->sw_scanning || local->hw_scanning)
-			ret = 0;
-		else
-			ret = ieee80211_hw_config(
-				local, IEEE80211_CONF_CHANGE_CHANNEL);
-	}
-
-	return ret;
-}
-
 u32 ieee80211_mandatory_rates(struct ieee80211_local *local,
 			      enum ieee80211_band band)
 {
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index d2d81b1..1da81f4 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -55,6 +55,8 @@ static int ieee80211_ioctl_siwfreq(struct net_device *dev,
 				   struct iw_freq *freq, char *extra)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = sdata->local;
+	struct ieee80211_channel *chan;
 
 	if (sdata->vif.type == NL80211_IFTYPE_ADHOC)
 		return cfg80211_ibss_wext_siwfreq(dev, info, freq, extra);
@@ -69,17 +71,38 @@ static int ieee80211_ioctl_siwfreq(struct net_device *dev,
 					IEEE80211_STA_AUTO_CHANNEL_SEL;
 			return 0;
 		} else
-			return ieee80211_set_freq(sdata,
+			chan = ieee80211_get_channel(local->hw.wiphy,
 				ieee80211_channel_to_frequency(freq->m));
 	} else {
 		int i, div = 1000000;
 		for (i = 0; i < freq->e; i++)
 			div /= 10;
-		if (div > 0)
-			return ieee80211_set_freq(sdata, freq->m / div);
-		else
+		if (div <= 0)
 			return -EINVAL;
+		chan = ieee80211_get_channel(local->hw.wiphy, freq->m / div);
 	}
+
+	if (!chan)
+		return -EINVAL;
+
+	if (chan->flags & IEEE80211_CHAN_DISABLED)
+		return -EINVAL;
+
+	/*
+	 * no change except maybe auto -> fixed, ignore the HT
+	 * setting so you can fix a channel you're on already
+	 */
+	if (local->oper_channel == chan)
+		return 0;
+
+	if (sdata->vif.type == NL80211_IFTYPE_STATION)
+		ieee80211_sta_req_auth(sdata);
+
+	local->oper_channel = chan;
+	local->oper_channel_type = NL80211_CHAN_NO_HT;
+	ieee80211_hw_config(local, 0);
+
+	return 0;
 }
 
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
