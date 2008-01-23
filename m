From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 'upstream' 2008-01-22
Date: Tue, 22 Jan 2008 20:45:21 -0500
Message-ID: <20080123014521.GG3206@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3952 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbYAWCCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 21:02:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is another collection of updates intended for 2.6.25.  There are
some ath5k cleanups, some b43 stuff, some mac80211 bits, and a few other
miscellaneous patches.

Let me know if there are problems!

Thanks!

John

---

Individual patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream

---

The following changes since commit bae4a7effd59ef0d521de2bc97902fa0a243b544:
  David S. Miller (1):
        Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Bruno Randolf (6):
      ath5k: use 3 instead of 0x00000003
      ath5k: beacon interval is in TU
      ath5k: better beacon timer calculation
      ath5k: use SWBA to detect IBSS HW merges
      ath5k: configure backoff for IBSS beacon queue
      ath5k: always extend rx timestamp with tsf

Guy Cohen (1):
      mac80211: Assign correct TID for local bridged packets

Johannes Berg (1):
      mac80211: fix RCU locking in __ieee80211_rx_handle_packet

John W. Linville (2):
      ath5k: use AR5K_KEYTABLE_SIZE when initializing key table
      ath5k: reset key cache after resume

Masakazu Mokuno (1):
      WEXT: remove unused variable

Michael Buesch (4):
      b43legacy: Remove the PHY spinlock
      b43: Add more N-PHY init code
      b43: Fix firmware caching
      b43: Fix MAC control and microcode init

Ron Rindjunsky (2):
      mac80211: fixing ieee80211_bar types
      mac80211: fix rx flow sparse errors, make functions static

Stefano Brivio (1):
      rc80211-pid: fix last_sample initialization

 drivers/net/wireless/ath5k/ath5k.h         |    4 +-
 drivers/net/wireless/ath5k/base.c          |  240 +++++++++++++++++++----
 drivers/net/wireless/ath5k/base.h          |    3 +-
 drivers/net/wireless/ath5k/hw.c            |    6 +-
 drivers/net/wireless/b43/b43.h             |   15 +-
 drivers/net/wireless/b43/main.c            |  290 ++++++++++++++++-----------
 drivers/net/wireless/b43/nphy.c            |  292 +++++++++++++++++++++++++++-
 drivers/net/wireless/b43/nphy.h            |   52 +++---
 drivers/net/wireless/b43legacy/b43legacy.h |   16 +-
 drivers/net/wireless/b43legacy/main.c      |    4 -
 drivers/net/wireless/b43legacy/phy.c       |   35 ++--
 drivers/net/wireless/b43legacy/phy.h       |   14 +--
 drivers/net/wireless/b43legacy/radio.c     |    7 +-
 include/linux/ieee80211.h                  |    4 +-
 net/mac80211/ieee80211_sta.c               |    4 +-
 net/mac80211/rc80211_pid_algo.c            |    2 +
 net/mac80211/rx.c                          |   13 +-
 net/mac80211/wme.c                         |    9 +-
 net/wireless/wext.c                        |   14 --
 19 files changed, 752 insertions(+), 272 deletions(-)

diff --git a/drivers/net/wireless/ath5k/ath5k.h b/drivers/net/wireless/ath5k/ath5k.h
index 878609f..c79066b 100644
--- a/drivers/net/wireless/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath5k/ath5k.h
@@ -486,8 +486,8 @@ struct ath5k_beacon_state {
  * TSF to TU conversion:
  *
  * TSF is a 64bit value in usec (microseconds).
- * TU is a 32bit value in roughly msec (milliseconds): usec / 1024
- * (1000ms equals 976 TU)
+ * TU is a 32bit value and defined by IEEE802.11 (page 6) as "A measurement of
+ * time equal to 1024 usec", so it's roughly milliseconds (usec / 1024).
  */
 #define TSF_TO_TU(_tsf) (u32)((_tsf) >> 10)
 
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index 742616a..72bcf32 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -290,6 +290,7 @@ static int 	ath5k_beacon_setup(struct ath5k_softc *sc,
 				struct ieee80211_tx_control *ctl);
 static void 	ath5k_beacon_send(struct ath5k_softc *sc);
 static void 	ath5k_beacon_config(struct ath5k_softc *sc);
+static void	ath5k_beacon_update_timers(struct ath5k_softc *sc, u64 bc_tsf);
 
 static inline u64 ath5k_extend_tsf(struct ath5k_hw *ah, u32 rstamp)
 {
@@ -604,7 +605,8 @@ ath5k_pci_resume(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct ath5k_softc *sc = hw->priv;
-	int err;
+	struct ath5k_hw *ah = sc->ah;
+	int i, err;
 
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
@@ -624,10 +626,20 @@ ath5k_pci_resume(struct pci_dev *pdev)
 
 	ath5k_init(sc);
 	if (test_bit(ATH_STAT_LEDSOFT, sc->status)) {
-		ath5k_hw_set_gpio_output(sc->ah, sc->led_pin);
-		ath5k_hw_set_gpio(sc->ah, sc->led_pin, 0);
+		ath5k_hw_set_gpio_output(ah, sc->led_pin);
+		ath5k_hw_set_gpio(ah, sc->led_pin, 0);
 	}
 
+	/*
+	 * Reset the key cache since some parts do not
+	 * reset the contents on initial power up or resume.
+	 *
+	 * FIXME: This may need to be revisited when mac80211 becomes
+	 *        aware of suspend/resume.
+	 */
+	for (i = 0; i < AR5K_KEYTABLE_SIZE; i++)
+		ath5k_hw_reset_key(ah, i);
+
 	return 0;
 }
 #endif /* CONFIG_PM */
@@ -663,7 +675,7 @@ ath5k_attach(struct pci_dev *pdev, struct ieee80211_hw *hw)
 	 * Reset the key cache since some parts do not
 	 * reset the contents on initial power up.
 	 */
-	for (i = 0; i < AR5K_KEYCACHE_SIZE; i++)
+	for (i = 0; i < AR5K_KEYTABLE_SIZE; i++)
 		ath5k_hw_reset_key(ah, i);
 
 	/*
@@ -1446,8 +1458,7 @@ ath5k_beaconq_config(struct ath5k_softc *sc)
 	ret = ath5k_hw_get_tx_queueprops(ah, sc->bhalq, &qi);
 	if (ret)
 		return ret;
-	if (sc->opmode == IEEE80211_IF_TYPE_AP ||
-	    sc->opmode == IEEE80211_IF_TYPE_IBSS) {
+	if (sc->opmode == IEEE80211_IF_TYPE_AP) {
 		/*
 		 * Always burst out beacon and CAB traffic
 		 * (aifs = cwmin = cwmax = 0)
@@ -1455,8 +1466,19 @@ ath5k_beaconq_config(struct ath5k_softc *sc)
 		qi.tqi_aifs = 0;
 		qi.tqi_cw_min = 0;
 		qi.tqi_cw_max = 0;
+	} else if (sc->opmode == IEEE80211_IF_TYPE_IBSS) {
+		/*
+		 * Adhoc mode; backoff between 0 and (2 * cw_min).
+		 */
+		qi.tqi_aifs = 0;
+		qi.tqi_cw_min = 0;
+		qi.tqi_cw_max = 2 * ah->ah_cw_min;
 	}
 
+	ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
+		"beacon queueprops tqi_aifs:%d tqi_cw_min:%d tqi_cw_max:%d\n",
+		qi.tqi_aifs, qi.tqi_cw_min, qi.tqi_cw_max);
+
 	ret = ath5k_hw_setup_tx_queueprops(ah, sc->bhalq, &qi);
 	if (ret) {
 		ATH5K_ERR(sc, "%s: unable to update parameters for beacon "
@@ -1628,6 +1650,34 @@ ath5k_rx_decrypted(struct ath5k_softc *sc, struct ath5k_desc *ds,
 	return 0;
 }
 
+
+static void
+ath5k_check_ibss_hw_merge(struct ath5k_softc *sc, struct sk_buff *skb)
+{
+	u32 hw_tu;
+	struct ieee80211_mgmt *mgmt = (struct ieee80211_mgmt *)skb->data;
+
+	if ((mgmt->frame_control & IEEE80211_FCTL_FTYPE) ==
+		IEEE80211_FTYPE_MGMT &&
+	    (mgmt->frame_control & IEEE80211_FCTL_STYPE) ==
+		IEEE80211_STYPE_BEACON &&
+	    mgmt->u.beacon.capab_info & WLAN_CAPABILITY_IBSS &&
+	    memcmp(mgmt->bssid, sc->ah->ah_bssid, ETH_ALEN) == 0) {
+		/*
+		 * Received an IBSS beacon with the same BSSID. Hardware might
+		 * have updated the TSF, check if we need to update timers.
+		 */
+		hw_tu = TSF_TO_TU(ath5k_hw_get_tsf64(sc->ah));
+		if (hw_tu >= sc->nexttbtt) {
+			ath5k_beacon_update_timers(sc,
+				mgmt->u.beacon.timestamp);
+			ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
+				"detected HW merge from received beacon\n");
+		}
+	}
+}
+
+
 static void
 ath5k_tasklet_rx(unsigned long data)
 {
@@ -1725,11 +1775,18 @@ accept:
 			skb_pull(skb, pad);
 		}
 
-		if (sc->opmode == IEEE80211_IF_TYPE_MNTR)
-			rxs.mactime = ath5k_extend_tsf(sc->ah,
-					ds->ds_rxstat.rs_tstamp);
-		else
-			rxs.mactime = ds->ds_rxstat.rs_tstamp;
+		/*
+		 * always extend the mac timestamp, since this information is
+		 * also needed for proper IBSS merging.
+		 *
+		 * XXX: it might be too late to do it here, since rs_tstamp is
+		 * 15bit only. that means TSF extension has to be done within
+		 * 32768usec (about 32ms). it might be necessary to move this to
+		 * the interrupt handler, like it is done in madwifi.
+		 */
+		rxs.mactime = ath5k_extend_tsf(sc->ah, ds->ds_rxstat.rs_tstamp);
+		rxs.flag |= RX_FLAG_TSFT;
+
 		rxs.freq = sc->curchan->freq;
 		rxs.channel = sc->curchan->chan;
 		rxs.phymode = sc->curmode;
@@ -1755,6 +1812,10 @@ accept:
 
 		ath5k_debug_dump_skb(sc, skb, "RX  ", 0);
 
+		/* check beacons in IBSS mode */
+		if (sc->opmode == IEEE80211_IF_TYPE_IBSS)
+			ath5k_check_ibss_hw_merge(sc, skb);
+
 		__ieee80211_rx(sc->hw, skb, &rxs);
 		sc->led_rxrate = ds->ds_rxstat.rs_rate;
 		ath5k_led_event(sc, ATH_LED_RX);
@@ -1973,47 +2034,120 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 }
 
 
+/**
+ * ath5k_beacon_update_timers - update beacon timers
+ *
+ * @sc: struct ath5k_softc pointer we are operating on
+ * @bc_tsf: the timestamp of the beacon. 0 to reset the TSF. -1 to perform a
+ *          beacon timer update based on the current HW TSF.
+ *
+ * Calculate the next target beacon transmit time (TBTT) based on the timestamp
+ * of a received beacon or the current local hardware TSF and write it to the
+ * beacon timer registers.
+ *
+ * This is called in a variety of situations, e.g. when a beacon is received,
+ * when a HW merge has been detected, but also when an new IBSS is created or
+ * when we otherwise know we have to update the timers, but we keep it in this
+ * function to have it all together in one place.
+ */
 static void
-ath5k_beacon_update_timers(struct ath5k_softc *sc)
+ath5k_beacon_update_timers(struct ath5k_softc *sc, u64 bc_tsf)
 {
 	struct ath5k_hw *ah = sc->ah;
-	u32 uninitialized_var(nexttbtt), intval, tsftu;
-	u64 tsf;
+	u32 nexttbtt, intval, hw_tu, bc_tu;
+	u64 hw_tsf;
 
 	intval = sc->bintval & AR5K_BEACON_PERIOD;
 	if (WARN_ON(!intval))
 		return;
 
+	/* beacon TSF converted to TU */
+	bc_tu = TSF_TO_TU(bc_tsf);
+
 	/* current TSF converted to TU */
-	tsf = ath5k_hw_get_tsf64(ah);
-	tsftu = TSF_TO_TU(tsf);
+	hw_tsf = ath5k_hw_get_tsf64(ah);
+	hw_tu = TSF_TO_TU(hw_tsf);
 
-	/*
-	 * Pull nexttbtt forward to reflect the current
-	 * TSF. Add one intval otherwise the timespan
-	 * can be too short for ibss merges.
-	 */
-	nexttbtt = tsftu + 2 * intval;
+#define FUDGE 3
+	/* we use FUDGE to make sure the next TBTT is ahead of the current TU */
+	if (bc_tsf == -1) {
+		/*
+		 * no beacons received, called internally.
+		 * just need to refresh timers based on HW TSF.
+		 */
+		nexttbtt = roundup(hw_tu + FUDGE, intval);
+	} else if (bc_tsf == 0) {
+		/*
+		 * no beacon received, probably called by ath5k_reset_tsf().
+		 * reset TSF to start with 0.
+		 */
+		nexttbtt = intval;
+		intval |= AR5K_BEACON_RESET_TSF;
+	} else if (bc_tsf > hw_tsf) {
+		/*
+		 * beacon received, SW merge happend but HW TSF not yet updated.
+		 * not possible to reconfigure timers yet, but next time we
+		 * receive a beacon with the same BSSID, the hardware will
+		 * automatically update the TSF and then we need to reconfigure
+		 * the timers.
+		 */
+		ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
+			"need to wait for HW TSF sync\n");
+		return;
+	} else {
+		/*
+		 * most important case for beacon synchronization between STA.
+		 *
+		 * beacon received and HW TSF has been already updated by HW.
+		 * update next TBTT based on the TSF of the beacon, but make
+		 * sure it is ahead of our local TSF timer.
+		 */
+		nexttbtt = bc_tu + roundup(hw_tu + FUDGE - bc_tu, intval);
+	}
+#undef FUDGE
 
-	ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
-		"hw tsftu %u nexttbtt %u intval %u\n", tsftu, nexttbtt, intval);
+	sc->nexttbtt = nexttbtt;
 
 	intval |= AR5K_BEACON_ENA;
-
 	ath5k_hw_init_beacon(ah, nexttbtt, intval);
+
+	/*
+	 * debugging output last in order to preserve the time critical aspect
+	 * of this function
+	 */
+	if (bc_tsf == -1)
+		ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
+			"reconfigured timers based on HW TSF\n");
+	else if (bc_tsf == 0)
+		ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
+			"reset HW TSF and timers\n");
+	else
+		ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
+			"updated timers based on beacon TSF\n");
+
+	ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
+		"bc_tsf %llx hw_tsf %llx bc_tu %u hw_tu %u nexttbtt %u\n",
+		bc_tsf, hw_tsf, bc_tu, hw_tu, nexttbtt);
+	ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON, "intval %u %s %s\n",
+		intval & AR5K_BEACON_PERIOD,
+		intval & AR5K_BEACON_ENA ? "AR5K_BEACON_ENA" : "",
+		intval & AR5K_BEACON_RESET_TSF ? "AR5K_BEACON_RESET_TSF" : "");
 }
 
 
-/*
- * Configure the beacon timers and interrupts based on the operating mode
+/**
+ * ath5k_beacon_config - Configure the beacon queues and interrupts
+ *
+ * @sc: struct ath5k_softc pointer we are operating on
  *
  * When operating in station mode we want to receive a BMISS interrupt when we
  * stop seeing beacons from the AP we've associated with so we can look for
  * another AP to associate with.
  *
- * In IBSS mode we need to configure the beacon timers and use a self-linked tx
- * descriptor if possible. If the hardware cannot deal with that we enable SWBA
- * interrupts to send the beacons from the interrupt handler.
+ * In IBSS mode we use a self-linked tx descriptor if possible. We enable SWBA
+ * interrupts to detect HW merges only.
+ *
+ * AP mode is missing.
  */
 static void
 ath5k_beacon_config(struct ath5k_softc *sc)
@@ -2027,18 +2161,17 @@ ath5k_beacon_config(struct ath5k_softc *sc)
 		sc->imask |= AR5K_INT_BMISS;
 	} else if (sc->opmode == IEEE80211_IF_TYPE_IBSS) {
 		/*
-		 * In IBSS mode enable the beacon timers but only enable SWBA
-		 * interrupts if we need to manually prepare beacon frames.
-		 * Otherwise we use a self-linked tx descriptor and let the
-		 * hardware deal with things. In that case we have to load it
+		 * In IBSS mode we use a self-linked tx descriptor and let the
+		 * hardware send the beacons automatically. We have to load it
 		 * only once here.
+		 * We use the SWBA interrupt only to keep track of the beacon
+		 * timers in order to detect HW merges (automatic TSF updates).
 		 */
 		ath5k_beaconq_config(sc);
-		ath5k_beacon_update_timers(sc);
 
-		if (!ath5k_hw_hasveol(ah))
-			sc->imask |= AR5K_INT_SWBA;
-		else
+		sc->imask |= AR5K_INT_SWBA;
+
+		if (ath5k_hw_hasveol(ah))
 			ath5k_beacon_send(sc);
 	}
 	/* TODO else AP */
@@ -2241,8 +2374,24 @@ ath5k_intr(int irq, void *dev_id)
 				* Handle beacon transmission directly; deferring
 				* this is too slow to meet timing constraints
 				* under load.
+				*
+				* In IBSS mode we use this interrupt just to
+				* keep track of the next TBTT (target beacon
+				* transmission time) in order to detect hardware
+				* merges (TSF updates).
 				*/
-				ath5k_beacon_send(sc);
+				if (sc->opmode == IEEE80211_IF_TYPE_IBSS) {
+					 /* XXX: only if VEOL suppported */
+					u64 tsf = ath5k_hw_get_tsf64(ah);
+					sc->nexttbtt += sc->bintval;
+					ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
+						"SWBA nexttbtt: %x hw_tu: %x "
+						"TSF: %llx\n",
+						sc->nexttbtt,
+						TSF_TO_TU(tsf), tsf);
+				} else {
+					ath5k_beacon_send(sc);
+				}
 			}
 			if (status & AR5K_INT_RXEOL) {
 				/*
@@ -2543,7 +2692,7 @@ ath5k_config(struct ieee80211_hw *hw,
 {
 	struct ath5k_softc *sc = hw->priv;
 
-	sc->bintval = conf->beacon_int * 1000 / 1024;
+	sc->bintval = conf->beacon_int;
 	ath5k_setcurmode(sc, conf->phymode);
 
 	return ath5k_chan_set(sc, conf->chan);
@@ -2559,7 +2708,7 @@ ath5k_config_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 
 	/* Set to a reasonable value. Note that this will
 	 * be set to mac80211's value at ath5k_config(). */
-	sc->bintval = 1000 * 1000 / 1024;
+	sc->bintval = 1000;
 	mutex_lock(&sc->lock);
 	if (sc->vif != vif) {
 		ret = -EIO;
@@ -2784,7 +2933,14 @@ ath5k_reset_tsf(struct ieee80211_hw *hw)
 {
 	struct ath5k_softc *sc = hw->priv;
 
-	ath5k_hw_reset_tsf(sc->ah);
+	/*
+	 * in IBSS mode we need to update the beacon timers too.
+	 * this will also reset the TSF if we call it with 0
+	 */
+	if (sc->opmode == IEEE80211_IF_TYPE_IBSS)
+		ath5k_beacon_update_timers(sc, 0);
+	else
+		ath5k_hw_reset_tsf(sc->ah);
 }
 
 static int
diff --git a/drivers/net/wireless/ath5k/base.h b/drivers/net/wireless/ath5k/base.h
index 7ba2223..8287ae7 100644
--- a/drivers/net/wireless/ath5k/base.h
+++ b/drivers/net/wireless/ath5k/base.h
@@ -164,8 +164,9 @@ struct ath5k_softc {
 	struct ath5k_buf	*bbuf;		/* beacon buffer */
 	unsigned int		bhalq,		/* SW q for outgoing beacons */
 				bmisscount,	/* missed beacon transmits */
-				bintval,	/* beacon interval */
+				bintval,	/* beacon interval in TU */
 				bsent;
+	unsigned int		nexttbtt;	/* next beacon time in TU */
 
 	struct timer_list	calib_tim;	/* calibration timer */
 };
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index eb00818..3a4bf40 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -2605,10 +2605,8 @@ void ath5k_hw_init_beacon(struct ath5k_hw *ah, u32 next_beacon, u32 interval)
 		break;
 
 	default:
-		timer1 = (next_beacon - AR5K_TUNE_DMA_BEACON_RESP) <<
-		    0x00000003;
-		timer2 = (next_beacon - AR5K_TUNE_SW_BEACON_RESP) <<
-		    0x00000003;
+		timer1 = (next_beacon - AR5K_TUNE_DMA_BEACON_RESP) << 3;
+		timer2 = (next_beacon - AR5K_TUNE_SW_BEACON_RESP) << 3;
 	}
 
 	timer3 = next_beacon + (ah->ah_atim_window ? ah->ah_atim_window : 1);
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index c7eea30..32a24f5 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -665,16 +665,23 @@ struct b43_wl {
 	bool beacon1_uploaded;
 };
 
+/* In-memory representation of a cached microcode file. */
+struct b43_firmware_file {
+	const char *filename;
+	const struct firmware *data;
+};
+
 /* Pointers to the firmware data and meta information about it. */
 struct b43_firmware {
 	/* Microcode */
-	const struct firmware *ucode;
+	struct b43_firmware_file ucode;
 	/* PCM code */
-	const struct firmware *pcm;
+	struct b43_firmware_file pcm;
 	/* Initial MMIO values for the firmware */
-	const struct firmware *initvals;
+	struct b43_firmware_file initvals;
 	/* Initial MMIO values for the firmware, band-specific */
-	const struct firmware *initvals_band;
+	struct b43_firmware_file initvals_band;
+
 	/* Firmware revision */
 	u16 rev;
 	/* Firmware patchlevel */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 0d9824c..88d2c15 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1557,16 +1557,19 @@ static irqreturn_t b43_interrupt_handler(int irq, void *dev_id)
 	return ret;
 }
 
+static void do_release_fw(struct b43_firmware_file *fw)
+{
+	release_firmware(fw->data);
+	fw->data = NULL;
+	fw->filename = NULL;
+}
+
 static void b43_release_firmware(struct b43_wldev *dev)
 {
-	release_firmware(dev->fw.ucode);
-	dev->fw.ucode = NULL;
-	release_firmware(dev->fw.pcm);
-	dev->fw.pcm = NULL;
-	release_firmware(dev->fw.initvals);
-	dev->fw.initvals = NULL;
-	release_firmware(dev->fw.initvals_band);
-	dev->fw.initvals_band = NULL;
+	do_release_fw(&dev->fw.ucode);
+	do_release_fw(&dev->fw.pcm);
+	do_release_fw(&dev->fw.initvals);
+	do_release_fw(&dev->fw.initvals_band);
 }
 
 static void b43_print_fw_helptext(struct b43_wl *wl, bool error)
@@ -1584,33 +1587,43 @@ static void b43_print_fw_helptext(struct b43_wl *wl, bool error)
 
 static int do_request_fw(struct b43_wldev *dev,
 			 const char *name,
-			 const struct firmware **fw)
+			 struct b43_firmware_file *fw)
 {
 	char path[sizeof(modparam_fwpostfix) + 32];
+	const struct firmware *blob;
 	struct b43_fw_header *hdr;
 	u32 size;
 	int err;
 
-	if (!name)
+	if (!name) {
+		/* Don't fetch anything. Free possibly cached firmware. */
+		do_release_fw(fw);
 		return 0;
+	}
+	if (fw->filename) {
+		if (strcmp(fw->filename, name) == 0)
+			return 0; /* Already have this fw. */
+		/* Free the cached firmware first. */
+		do_release_fw(fw);
+	}
 
 	snprintf(path, ARRAY_SIZE(path),
 		 "b43%s/%s.fw",
 		 modparam_fwpostfix, name);
-	err = request_firmware(fw, path, dev->dev->dev);
+	err = request_firmware(&blob, path, dev->dev->dev);
 	if (err) {
 		b43err(dev->wl, "Firmware file \"%s\" not found "
 		       "or load failed.\n", path);
 		return err;
 	}
-	if ((*fw)->size < sizeof(struct b43_fw_header))
+	if (blob->size < sizeof(struct b43_fw_header))
 		goto err_format;
-	hdr = (struct b43_fw_header *)((*fw)->data);
+	hdr = (struct b43_fw_header *)(blob->data);
 	switch (hdr->type) {
 	case B43_FW_TYPE_UCODE:
 	case B43_FW_TYPE_PCM:
 		size = be32_to_cpu(hdr->size);
-		if (size != (*fw)->size - sizeof(struct b43_fw_header))
+		if (size != blob->size - sizeof(struct b43_fw_header))
 			goto err_format;
 		/* fallthrough */
 	case B43_FW_TYPE_IV:
@@ -1621,10 +1634,15 @@ static int do_request_fw(struct b43_wldev *dev,
 		goto err_format;
 	}
 
-	return err;
+	fw->data = blob;
+	fw->filename = name;
+
+	return 0;
 
 err_format:
 	b43err(dev->wl, "Firmware file \"%s\" format error.\n", path);
+	release_firmware(blob);
+
 	return -EPROTO;
 }
 
@@ -1636,97 +1654,96 @@ static int b43_request_firmware(struct b43_wldev *dev)
 	u32 tmshigh;
 	int err;
 
+	/* Get microcode */
 	tmshigh = ssb_read32(dev->dev, SSB_TMSHIGH);
-	if (!fw->ucode) {
+	if ((rev >= 5) && (rev <= 10))
+		filename = "ucode5";
+	else if ((rev >= 11) && (rev <= 12))
+		filename = "ucode11";
+	else if (rev >= 13)
+		filename = "ucode13";
+	else
+		goto err_no_ucode;
+	err = do_request_fw(dev, filename, &fw->ucode);
+	if (err)
+		goto err_load;
+
+	/* Get PCM code */
+	if ((rev >= 5) && (rev <= 10))
+		filename = "pcm5";
+	else if (rev >= 11)
+		filename = NULL;
+	else
+		goto err_no_pcm;
+	err = do_request_fw(dev, filename, &fw->pcm);
+	if (err)
+		goto err_load;
+
+	/* Get initvals */
+	switch (dev->phy.type) {
+	case B43_PHYTYPE_A:
+		if ((rev >= 5) && (rev <= 10)) {
+			if (tmshigh & B43_TMSHIGH_HAVE_2GHZ_PHY)
+				filename = "a0g1initvals5";
+			else
+				filename = "a0g0initvals5";
+		} else
+			goto err_no_initvals;
+		break;
+	case B43_PHYTYPE_G:
 		if ((rev >= 5) && (rev <= 10))
-			filename = "ucode5";
-		else if ((rev >= 11) && (rev <= 12))
-			filename = "ucode11";
+			filename = "b0g0initvals5";
 		else if (rev >= 13)
-			filename = "ucode13";
+			filename = "lp0initvals13";
 		else
-			goto err_no_ucode;
-		err = do_request_fw(dev, filename, &fw->ucode);
-		if (err)
-			goto err_load;
+			goto err_no_initvals;
+		break;
+	case B43_PHYTYPE_N:
+		if ((rev >= 11) && (rev <= 12))
+			filename = "n0initvals11";
+		else
+			goto err_no_initvals;
+		break;
+	default:
+		goto err_no_initvals;
 	}
-	if (!fw->pcm) {
+	err = do_request_fw(dev, filename, &fw->initvals);
+	if (err)
+		goto err_load;
+
+	/* Get bandswitch initvals */
+	switch (dev->phy.type) {
+	case B43_PHYTYPE_A:
+		if ((rev >= 5) && (rev <= 10)) {
+			if (tmshigh & B43_TMSHIGH_HAVE_2GHZ_PHY)
+				filename = "a0g1bsinitvals5";
+			else
+				filename = "a0g0bsinitvals5";
+		} else if (rev >= 11)
+			filename = NULL;
+		else
+			goto err_no_initvals;
+		break;
+	case B43_PHYTYPE_G:
 		if ((rev >= 5) && (rev <= 10))
-			filename = "pcm5";
+			filename = "b0g0bsinitvals5";
 		else if (rev >= 11)
 			filename = NULL;
 		else
-			goto err_no_pcm;
-		err = do_request_fw(dev, filename, &fw->pcm);
-		if (err)
-			goto err_load;
-	}
-	if (!fw->initvals) {
-		switch (dev->phy.type) {
-		case B43_PHYTYPE_A:
-			if ((rev >= 5) && (rev <= 10)) {
-				if (tmshigh & B43_TMSHIGH_HAVE_2GHZ_PHY)
-					filename = "a0g1initvals5";
-				else
-					filename = "a0g0initvals5";
-			} else
-				goto err_no_initvals;
-			break;
-		case B43_PHYTYPE_G:
-			if ((rev >= 5) && (rev <= 10))
-				filename = "b0g0initvals5";
-			else if (rev >= 13)
-				filename = "lp0initvals13";
-			else
-				goto err_no_initvals;
-			break;
-		case B43_PHYTYPE_N:
-			if ((rev >= 11) && (rev <= 12))
-				filename = "n0initvals11";
-			else
-				goto err_no_initvals;
-			break;
-		default:
 			goto err_no_initvals;
-		}
-		err = do_request_fw(dev, filename, &fw->initvals);
-		if (err)
-			goto err_load;
-	}
-	if (!fw->initvals_band) {
-		switch (dev->phy.type) {
-		case B43_PHYTYPE_A:
-			if ((rev >= 5) && (rev <= 10)) {
-				if (tmshigh & B43_TMSHIGH_HAVE_2GHZ_PHY)
-					filename = "a0g1bsinitvals5";
-				else
-					filename = "a0g0bsinitvals5";
-			} else if (rev >= 11)
-				filename = NULL;
-			else
-				goto err_no_initvals;
-			break;
-		case B43_PHYTYPE_G:
-			if ((rev >= 5) && (rev <= 10))
-				filename = "b0g0bsinitvals5";
-			else if (rev >= 11)
-				filename = NULL;
-			else
-				goto err_no_initvals;
-			break;
-		case B43_PHYTYPE_N:
-			if ((rev >= 11) && (rev <= 12))
-				filename = "n0bsinitvals11";
-			else
-				goto err_no_initvals;
-			break;
-		default:
+		break;
+	case B43_PHYTYPE_N:
+		if ((rev >= 11) && (rev <= 12))
+			filename = "n0bsinitvals11";
+		else
 			goto err_no_initvals;
-		}
-		err = do_request_fw(dev, filename, &fw->initvals_band);
-		if (err)
-			goto err_load;
+		break;
+	default:
+		goto err_no_initvals;
 	}
+	err = do_request_fw(dev, filename, &fw->initvals_band);
+	if (err)
+		goto err_load;
 
 	return 0;
 
@@ -1761,22 +1778,33 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 	const __be32 *data;
 	unsigned int i, len;
 	u16 fwrev, fwpatch, fwdate, fwtime;
-	u32 tmp;
+	u32 tmp, macctl;
 	int err = 0;
 
+	/* Jump the microcode PSM to offset 0 */
+	macctl = b43_read32(dev, B43_MMIO_MACCTL);
+	B43_WARN_ON(macctl & B43_MACCTL_PSM_RUN);
+	macctl |= B43_MACCTL_PSM_JMP0;
+	b43_write32(dev, B43_MMIO_MACCTL, macctl);
+	/* Zero out all microcode PSM registers and shared memory. */
+	for (i = 0; i < 64; i++)
+		b43_shm_write16(dev, B43_SHM_SCRATCH, i, 0);
+	for (i = 0; i < 4096; i += 2)
+		b43_shm_write16(dev, B43_SHM_SHARED, i, 0);
+
 	/* Upload Microcode. */
-	data = (__be32 *) (dev->fw.ucode->data + hdr_len);
-	len = (dev->fw.ucode->size - hdr_len) / sizeof(__be32);
+	data = (__be32 *) (dev->fw.ucode.data->data + hdr_len);
+	len = (dev->fw.ucode.data->size - hdr_len) / sizeof(__be32);
 	b43_shm_control_word(dev, B43_SHM_UCODE | B43_SHM_AUTOINC_W, 0x0000);
 	for (i = 0; i < len; i++) {
 		b43_write32(dev, B43_MMIO_SHM_DATA, be32_to_cpu(data[i]));
 		udelay(10);
 	}
 
-	if (dev->fw.pcm) {
+	if (dev->fw.pcm.data) {
 		/* Upload PCM data. */
-		data = (__be32 *) (dev->fw.pcm->data + hdr_len);
-		len = (dev->fw.pcm->size - hdr_len) / sizeof(__be32);
+		data = (__be32 *) (dev->fw.pcm.data->data + hdr_len);
+		len = (dev->fw.pcm.data->size - hdr_len) / sizeof(__be32);
 		b43_shm_control_word(dev, B43_SHM_HW, 0x01EA);
 		b43_write32(dev, B43_MMIO_SHM_DATA, 0x00004000);
 		/* No need for autoinc bit in SHM_HW */
@@ -1788,9 +1816,12 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 	}
 
 	b43_write32(dev, B43_MMIO_GEN_IRQ_REASON, B43_IRQ_ALL);
-	b43_write32(dev, B43_MMIO_MACCTL,
-		    B43_MACCTL_PSM_RUN |
-		    B43_MACCTL_IHR_ENABLED | B43_MACCTL_INFRA);
+
+	/* Start the microcode PSM */
+	macctl = b43_read32(dev, B43_MMIO_MACCTL);
+	macctl &= ~B43_MACCTL_PSM_JMP0;
+	macctl |= B43_MACCTL_PSM_RUN;
+	b43_write32(dev, B43_MMIO_MACCTL, macctl);
 
 	/* Wait for the microcode to load and respond */
 	i = 0;
@@ -1799,13 +1830,17 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 		if (tmp == B43_IRQ_MAC_SUSPENDED)
 			break;
 		i++;
-		if (i >= 50) {
+		if (i >= 20) {
 			b43err(dev->wl, "Microcode not responding\n");
 			b43_print_fw_helptext(dev->wl, 1);
 			err = -ENODEV;
-			goto out;
+			goto error;
+		}
+		msleep_interruptible(50);
+		if (signal_pending(current)) {
+			err = -EINTR;
+			goto error;
 		}
-		udelay(10);
 	}
 	b43_read32(dev, B43_MMIO_GEN_IRQ_REASON);	/* dummy read */
 
@@ -1820,9 +1855,8 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 		       "binary drivers older than version 4.x is unsupported. "
 		       "You must upgrade your firmware files.\n");
 		b43_print_fw_helptext(dev->wl, 1);
-		b43_write32(dev, B43_MMIO_MACCTL, 0);
 		err = -EOPNOTSUPP;
-		goto out;
+		goto error;
 	}
 	b43dbg(dev->wl, "Loading firmware version %u.%u "
 	       "(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n",
@@ -1839,7 +1873,14 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 		b43_print_fw_helptext(dev->wl, 0);
 	}
 
-out:
+	return 0;
+
+error:
+	macctl = b43_read32(dev, B43_MMIO_MACCTL);
+	macctl &= ~B43_MACCTL_PSM_RUN;
+	macctl |= B43_MACCTL_PSM_JMP0;
+	b43_write32(dev, B43_MMIO_MACCTL, macctl);
+
 	return err;
 }
 
@@ -1913,19 +1954,19 @@ static int b43_upload_initvals(struct b43_wldev *dev)
 	size_t count;
 	int err;
 
-	hdr = (const struct b43_fw_header *)(fw->initvals->data);
-	ivals = (const struct b43_iv *)(fw->initvals->data + hdr_len);
+	hdr = (const struct b43_fw_header *)(fw->initvals.data->data);
+	ivals = (const struct b43_iv *)(fw->initvals.data->data + hdr_len);
 	count = be32_to_cpu(hdr->size);
 	err = b43_write_initvals(dev, ivals, count,
-				 fw->initvals->size - hdr_len);
+				 fw->initvals.data->size - hdr_len);
 	if (err)
 		goto out;
-	if (fw->initvals_band) {
-		hdr = (const struct b43_fw_header *)(fw->initvals_band->data);
-		ivals = (const struct b43_iv *)(fw->initvals_band->data + hdr_len);
+	if (fw->initvals_band.data) {
+		hdr = (const struct b43_fw_header *)(fw->initvals_band.data->data);
+		ivals = (const struct b43_iv *)(fw->initvals_band.data->data + hdr_len);
 		count = be32_to_cpu(hdr->size);
 		err = b43_write_initvals(dev, ivals, count,
-					 fw->initvals_band->size - hdr_len);
+					 fw->initvals_band.data->size - hdr_len);
 		if (err)
 			goto out;
 	}
@@ -2211,11 +2252,15 @@ static int b43_chip_init(struct b43_wldev *dev)
 {
 	struct b43_phy *phy = &dev->phy;
 	int err, tmp;
-	u32 value32;
+	u32 value32, macctl;
 	u16 value16;
 
-	b43_write32(dev, B43_MMIO_MACCTL,
-		    B43_MACCTL_PSM_JMP0 | B43_MACCTL_IHR_ENABLED);
+	/* Initialize the MAC control */
+	macctl = B43_MACCTL_IHR_ENABLED | B43_MACCTL_SHM_ENABLED;
+	if (dev->phy.gmode)
+		macctl |= B43_MACCTL_GMODE;
+	macctl |= B43_MACCTL_INFRA;
+	b43_write32(dev, B43_MMIO_MACCTL, macctl);
 
 	err = b43_request_firmware(dev);
 	if (err)
@@ -3359,12 +3404,19 @@ static void b43_set_retry_limits(struct b43_wldev *dev,
 static void b43_wireless_core_exit(struct b43_wldev *dev)
 {
 	struct b43_phy *phy = &dev->phy;
+	u32 macctl;
 
 	B43_WARN_ON(b43_status(dev) > B43_STAT_INITIALIZED);
 	if (b43_status(dev) != B43_STAT_INITIALIZED)
 		return;
 	b43_set_status(dev, B43_STAT_UNINIT);
 
+	/* Stop the microcode PSM. */
+	macctl = b43_read32(dev, B43_MMIO_MACCTL);
+	macctl &= ~B43_MACCTL_PSM_RUN;
+	macctl |= B43_MACCTL_PSM_JMP0;
+	b43_write32(dev, B43_MMIO_MACCTL, macctl);
+
 	b43_leds_exit(dev);
 	b43_rng_exit(dev->wl);
 	b43_dma_free(dev);
diff --git a/drivers/net/wireless/b43/nphy.c b/drivers/net/wireless/b43/nphy.c
index 0b421b1..705131e 100644
--- a/drivers/net/wireless/b43/nphy.c
+++ b/drivers/net/wireless/b43/nphy.c
@@ -29,6 +29,8 @@
 #include "nphy.h"
 #include "tables_nphy.h"
 
+#include <linux/delay.h>
+
 
 void b43_nphy_set_rxantenna(struct b43_wldev *dev, int antenna)
 {//TODO
@@ -191,9 +193,297 @@ void b43_nphy_radio_turn_off(struct b43_wldev *dev)
 		     ~B43_NPHY_RFCTL_CMD_EN);
 }
 
+#define ntab_upload(dev, offset, data) do { \
+		unsigned int i;						\
+		for (i = 0; i < (offset##_SIZE); i++)			\
+			b43_ntab_write(dev, (offset) + i, (data)[i]);	\
+	} while (0)
+
+/* Upload the N-PHY tables. */
+static void b43_nphy_tables_init(struct b43_wldev *dev)
+{
+	/* Static tables */
+	ntab_upload(dev, B43_NTAB_FRAMESTRUCT, b43_ntab_framestruct);
+	ntab_upload(dev, B43_NTAB_FRAMELT, b43_ntab_framelookup);
+	ntab_upload(dev, B43_NTAB_TMAP, b43_ntab_tmap);
+	ntab_upload(dev, B43_NTAB_TDTRN, b43_ntab_tdtrn);
+	ntab_upload(dev, B43_NTAB_INTLEVEL, b43_ntab_intlevel);
+	ntab_upload(dev, B43_NTAB_PILOT, b43_ntab_pilot);
+	ntab_upload(dev, B43_NTAB_PILOTLT, b43_ntab_pilotlt);
+	ntab_upload(dev, B43_NTAB_TDI20A0, b43_ntab_tdi20a0);
+	ntab_upload(dev, B43_NTAB_TDI20A1, b43_ntab_tdi20a1);
+	ntab_upload(dev, B43_NTAB_TDI40A0, b43_ntab_tdi40a0);
+	ntab_upload(dev, B43_NTAB_TDI40A1, b43_ntab_tdi40a1);
+	ntab_upload(dev, B43_NTAB_BDI, b43_ntab_bdi);
+	ntab_upload(dev, B43_NTAB_CHANEST, b43_ntab_channelest);
+	ntab_upload(dev, B43_NTAB_MCS, b43_ntab_mcs);
+
+	/* Volatile tables */
+	ntab_upload(dev, B43_NTAB_NOISEVAR10, b43_ntab_noisevar10);
+	ntab_upload(dev, B43_NTAB_NOISEVAR11, b43_ntab_noisevar11);
+	ntab_upload(dev, B43_NTAB_C0_ESTPLT, b43_ntab_estimatepowerlt0);
+	ntab_upload(dev, B43_NTAB_C1_ESTPLT, b43_ntab_estimatepowerlt1);
+	ntab_upload(dev, B43_NTAB_C0_ADJPLT, b43_ntab_adjustpower0);
+	ntab_upload(dev, B43_NTAB_C1_ADJPLT, b43_ntab_adjustpower1);
+	ntab_upload(dev, B43_NTAB_C0_GAINCTL, b43_ntab_gainctl0);
+	ntab_upload(dev, B43_NTAB_C1_GAINCTL, b43_ntab_gainctl1);
+	ntab_upload(dev, B43_NTAB_C0_IQLT, b43_ntab_iqlt0);
+	ntab_upload(dev, B43_NTAB_C1_IQLT, b43_ntab_iqlt1);
+	ntab_upload(dev, B43_NTAB_C0_LOFEEDTH, b43_ntab_loftlt0);
+	ntab_upload(dev, B43_NTAB_C1_LOFEEDTH, b43_ntab_loftlt1);
+}
+
+static void b43_nphy_workarounds(struct b43_wldev *dev)
+{
+	struct b43_phy *phy = &dev->phy;
+	unsigned int i;
+
+	b43_phy_set(dev, B43_NPHY_IQFLIP,
+		    B43_NPHY_IQFLIP_ADC1 | B43_NPHY_IQFLIP_ADC2);
+	//FIXME the following condition is different in the specs.
+	if (1 /* FIXME band is 2.4GHz */) {
+		b43_phy_set(dev, B43_NPHY_CLASSCTL,
+			    B43_NPHY_CLASSCTL_CCKEN);
+	} else {
+		b43_phy_mask(dev, B43_NPHY_CLASSCTL,
+			     ~B43_NPHY_CLASSCTL_CCKEN);
+	}
+	b43_radio_set(dev, B2055_C1_TX_RF_SPARE, 0x8);
+	b43_phy_write(dev, B43_NPHY_TXFRAMEDELAY, 8);
+
+	/* Fixup some tables */
+	b43_ntab_write(dev, B43_NTAB16(8, 0x00), 0xA);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x10), 0xA);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x02), 0xCDAA);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x12), 0xCDAA);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x08), 0);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x18), 0);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x07), 0x7AAB);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x17), 0x7AAB);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x06), 0x800);
+	b43_ntab_write(dev, B43_NTAB16(8, 0x16), 0x800);
+
+	b43_phy_write(dev, B43_NPHY_RFCTL_LUT_TRSW_LO1, 0x2D8);
+	b43_phy_write(dev, B43_NPHY_RFCTL_LUT_TRSW_UP1, 0x301);
+	b43_phy_write(dev, B43_NPHY_RFCTL_LUT_TRSW_LO2, 0x2D8);
+	b43_phy_write(dev, B43_NPHY_RFCTL_LUT_TRSW_UP2, 0x301);
+
+	//TODO set RF sequence
+
+	/* Set narrowband clip threshold */
+	b43_phy_write(dev, B43_NPHY_C1_NBCLIPTHRES, 66);
+	b43_phy_write(dev, B43_NPHY_C2_NBCLIPTHRES, 66);
+
+	/* Set wideband clip 2 threshold */
+	b43_phy_maskset(dev, B43_NPHY_C1_CLIPWBTHRES,
+			~B43_NPHY_C1_CLIPWBTHRES_CLIP2,
+			21 << B43_NPHY_C1_CLIPWBTHRES_CLIP2_SHIFT);
+	b43_phy_maskset(dev, B43_NPHY_C2_CLIPWBTHRES,
+			~B43_NPHY_C2_CLIPWBTHRES_CLIP2,
+			21 << B43_NPHY_C2_CLIPWBTHRES_CLIP2_SHIFT);
+
+	/* Set Clip 2 detect */
+	b43_phy_set(dev, B43_NPHY_C1_CGAINI,
+		    B43_NPHY_C1_CGAINI_CL2DETECT);
+	b43_phy_set(dev, B43_NPHY_C2_CGAINI,
+		    B43_NPHY_C2_CGAINI_CL2DETECT);
+
+	if (0 /*FIXME*/) {
+		/* Set dwell lengths */
+		b43_phy_write(dev, B43_NPHY_CLIP1_NBDWELL_LEN, 43);
+		b43_phy_write(dev, B43_NPHY_CLIP2_NBDWELL_LEN, 43);
+		b43_phy_write(dev, B43_NPHY_W1CLIP1_DWELL_LEN, 9);
+		b43_phy_write(dev, B43_NPHY_W1CLIP2_DWELL_LEN, 9);
+
+		/* Set gain backoff */
+		b43_phy_maskset(dev, B43_NPHY_C1_CGAINI,
+				~B43_NPHY_C1_CGAINI_GAINBKOFF,
+				1 << B43_NPHY_C1_CGAINI_GAINBKOFF_SHIFT);
+		b43_phy_maskset(dev, B43_NPHY_C2_CGAINI,
+				~B43_NPHY_C2_CGAINI_GAINBKOFF,
+				1 << B43_NPHY_C2_CGAINI_GAINBKOFF_SHIFT);
+
+		/* Set HPVGA2 index */
+		b43_phy_maskset(dev, B43_NPHY_C1_INITGAIN,
+				~B43_NPHY_C1_INITGAIN_HPVGA2,
+				6 << B43_NPHY_C1_INITGAIN_HPVGA2_SHIFT);
+		b43_phy_maskset(dev, B43_NPHY_C2_INITGAIN,
+				~B43_NPHY_C2_INITGAIN_HPVGA2,
+				6 << B43_NPHY_C2_INITGAIN_HPVGA2_SHIFT);
+
+		//FIXME verify that the specs really mean to use autoinc here.
+		for (i = 0; i < 3; i++)
+			b43_ntab_write(dev, B43_NTAB16(7, 0x106) + i, 0x673);
+	}
+
+	/* Set minimum gain value */
+	b43_phy_maskset(dev, B43_NPHY_C1_MINMAX_GAIN,
+			~B43_NPHY_C1_MINGAIN,
+			23 << B43_NPHY_C1_MINGAIN_SHIFT);
+	b43_phy_maskset(dev, B43_NPHY_C2_MINMAX_GAIN,
+			~B43_NPHY_C2_MINGAIN,
+			23 << B43_NPHY_C2_MINGAIN_SHIFT);
+
+	if (phy->rev < 2) {
+		b43_phy_mask(dev, B43_NPHY_SCRAM_SIGCTL,
+			     ~B43_NPHY_SCRAM_SIGCTL_SCM);
+	}
+
+	/* Set phase track alpha and beta */
+	b43_phy_write(dev, B43_NPHY_PHASETR_A0, 0x125);
+	b43_phy_write(dev, B43_NPHY_PHASETR_A1, 0x1B3);
+	b43_phy_write(dev, B43_NPHY_PHASETR_A2, 0x105);
+	b43_phy_write(dev, B43_NPHY_PHASETR_B0, 0x16E);
+	b43_phy_write(dev, B43_NPHY_PHASETR_B1, 0xCD);
+	b43_phy_write(dev, B43_NPHY_PHASETR_B2, 0x20);
+}
+
+static void b43_nphy_reset_cca(struct b43_wldev *dev)
+{
+	u16 bbcfg;
+
+	ssb_write32(dev->dev, SSB_TMSLOW,
+		    ssb_read32(dev->dev, SSB_TMSLOW) | SSB_TMSLOW_FGC);
+	bbcfg = b43_phy_read(dev, B43_NPHY_BBCFG);
+	b43_phy_set(dev, B43_NPHY_BBCFG, B43_NPHY_BBCFG_RSTCCA);
+	b43_phy_write(dev, B43_NPHY_BBCFG,
+		      bbcfg & ~B43_NPHY_BBCFG_RSTCCA);
+	ssb_write32(dev->dev, SSB_TMSLOW,
+		    ssb_read32(dev->dev, SSB_TMSLOW) & ~SSB_TMSLOW_FGC);
+}
+
+enum b43_nphy_rf_sequence {
+	B43_RFSEQ_RX2TX,
+	B43_RFSEQ_TX2RX,
+	B43_RFSEQ_RESET2RX,
+	B43_RFSEQ_UPDATE_GAINH,
+	B43_RFSEQ_UPDATE_GAINL,
+	B43_RFSEQ_UPDATE_GAINU,
+};
+
+static void b43_nphy_force_rf_sequence(struct b43_wldev *dev,
+				       enum b43_nphy_rf_sequence seq)
+{
+	static const u16 trigger[] = {
+		[B43_RFSEQ_RX2TX]		= B43_NPHY_RFSEQTR_RX2TX,
+		[B43_RFSEQ_TX2RX]		= B43_NPHY_RFSEQTR_TX2RX,
+		[B43_RFSEQ_RESET2RX]		= B43_NPHY_RFSEQTR_RST2RX,
+		[B43_RFSEQ_UPDATE_GAINH]	= B43_NPHY_RFSEQTR_UPGH,
+		[B43_RFSEQ_UPDATE_GAINL]	= B43_NPHY_RFSEQTR_UPGL,
+		[B43_RFSEQ_UPDATE_GAINU]	= B43_NPHY_RFSEQTR_UPGU,
+	};
+	int i;
+
+	B43_WARN_ON(seq >= ARRAY_SIZE(trigger));
+
+	b43_phy_set(dev, B43_NPHY_RFSEQMODE,
+		    B43_NPHY_RFSEQMODE_CAOVER | B43_NPHY_RFSEQMODE_TROVER);
+	b43_phy_set(dev, B43_NPHY_RFSEQTR, trigger[seq]);
+	for (i = 0; i < 200; i++) {
+		if (!(b43_phy_read(dev, B43_NPHY_RFSEQST) & trigger[seq]))
+			goto ok;
+		msleep(1);
+	}
+	b43err(dev->wl, "RF sequence status timeout\n");
+ok:
+	b43_phy_mask(dev, B43_NPHY_RFSEQMODE,
+		     ~(B43_NPHY_RFSEQMODE_CAOVER | B43_NPHY_RFSEQMODE_TROVER));
+}
+
+static void b43_nphy_bphy_init(struct b43_wldev *dev)
+{
+	unsigned int i;
+	u16 val;
+
+	val = 0x1E1F;
+	for (i = 0; i < 14; i++) {
+		b43_phy_write(dev, B43_PHY_N_BMODE(0x88 + i), val);
+		val -= 0x202;
+	}
+	val = 0x3E3F;
+	for (i = 0; i < 16; i++) {
+		b43_phy_write(dev, B43_PHY_N_BMODE(0x97 + i), val);
+		val -= 0x202;
+	}
+	b43_phy_write(dev, B43_PHY_N_BMODE(0x38), 0x668);
+}
+
+/* RSSI Calibration */
+static void b43_nphy_rssi_cal(struct b43_wldev *dev, u8 type)
+{
+	//TODO
+}
+
 int b43_phy_initn(struct b43_wldev *dev)
 {
-	b43err(dev->wl, "IEEE 802.11n devices are not supported, yet.\n");
+	struct b43_phy *phy = &dev->phy;
+	u16 tmp;
+
+	//TODO: Spectral management
+	b43_nphy_tables_init(dev);
+
+	/* Clear all overrides */
+	b43_phy_write(dev, B43_NPHY_RFCTL_OVER, 0);
+	b43_phy_write(dev, B43_NPHY_RFCTL_INTC1, 0);
+	b43_phy_write(dev, B43_NPHY_RFCTL_INTC2, 0);
+	b43_phy_write(dev, B43_NPHY_RFCTL_INTC3, 0);
+	b43_phy_write(dev, B43_NPHY_RFCTL_INTC4, 0);
+	b43_phy_mask(dev, B43_NPHY_RFSEQMODE,
+		     ~(B43_NPHY_RFSEQMODE_CAOVER |
+		       B43_NPHY_RFSEQMODE_TROVER));
+	b43_phy_write(dev, B43_NPHY_AFECTL_OVER, 0);
+
+	tmp = (phy->rev < 2) ? 64 : 59;
+	b43_phy_maskset(dev, B43_NPHY_BPHY_CTL3,
+			~B43_NPHY_BPHY_CTL3_SCALE,
+			tmp << B43_NPHY_BPHY_CTL3_SCALE_SHIFT);
+
+	b43_phy_write(dev, B43_NPHY_AFESEQ_TX2RX_PUD_20M, 0x20);
+	b43_phy_write(dev, B43_NPHY_AFESEQ_TX2RX_PUD_40M, 0x20);
+
+	b43_phy_write(dev, B43_NPHY_TXREALFD, 184);
+	b43_phy_write(dev, B43_NPHY_MIMO_CRSTXEXT, 200);
+	b43_phy_write(dev, B43_NPHY_PLOAD_CSENSE_EXTLEN, 80);
+	b43_phy_write(dev, B43_NPHY_C2_BCLIPBKOFF, 511);
 
+	//TODO MIMO-Config
+	//TODO Update TX/RX chain
+
+	if (phy->rev < 2) {
+		b43_phy_write(dev, B43_NPHY_DUP40_GFBL, 0xAA8);
+		b43_phy_write(dev, B43_NPHY_DUP40_BL, 0x9A4);
+	}
+	b43_nphy_workarounds(dev);
+	b43_nphy_reset_cca(dev);
+
+	ssb_write32(dev->dev, SSB_TMSLOW,
+		    ssb_read32(dev->dev, SSB_TMSLOW) | B43_TMSLOW_MACPHYCLKEN);
+	b43_nphy_force_rf_sequence(dev, B43_RFSEQ_RX2TX);
+	b43_nphy_force_rf_sequence(dev, B43_RFSEQ_RESET2RX);
+
+	b43_phy_read(dev, B43_NPHY_CLASSCTL); /* dummy read */
+	//TODO read core1/2 clip1 thres regs
+
+	if (1 /* FIXME Band is 2.4GHz */)
+		b43_nphy_bphy_init(dev);
+	//TODO disable TX power control
+	//TODO Fix the TX power settings
+	//TODO Init periodic calibration with reason 3
+	b43_nphy_rssi_cal(dev, 2);
+	b43_nphy_rssi_cal(dev, 0);
+	b43_nphy_rssi_cal(dev, 1);
+	//TODO get TX gain
+	//TODO init superswitch
+	//TODO calibrate LO
+	//TODO idle TSSI TX pctl
+	//TODO TX power control power setup
+	//TODO table writes
+	//TODO TX power control coefficients
+	//TODO enable TX power control
+	//TODO control antenna selection
+	//TODO init radar detection
+	//TODO reset channel if changed
+
+	b43err(dev->wl, "IEEE 802.11n devices are not supported, yet.\n");
 	return 0;
 }
diff --git a/drivers/net/wireless/b43/nphy.h b/drivers/net/wireless/b43/nphy.h
index 896b468..5d95118 100644
--- a/drivers/net/wireless/b43/nphy.h
+++ b/drivers/net/wireless/b43/nphy.h
@@ -25,8 +25,11 @@
 #define B43_NPHY_C1_CCK_BCLIPBKOFF		B43_PHY_N(0x01B) /* Core 1 CCK barely clip backoff */
 #define B43_NPHY_C1_CGAINI			B43_PHY_N(0x01C) /* Core 1 compute gain info */
 #define  B43_NPHY_C1_CGAINI_GAINBKOFF		0x001F /* Gain backoff */
+#define  B43_NPHY_C1_CGAINI_GAINBKOFF_SHIFT	0
 #define  B43_NPHY_C1_CGAINI_CLIPGBKOFF		0x03E0 /* Clip gain backoff */
+#define  B43_NPHY_C1_CGAINI_CLIPGBKOFF_SHIFT	5
 #define  B43_NPHY_C1_CGAINI_GAINSTEP		0x1C00 /* Gain step */
+#define  B43_NPHY_C1_CGAINI_GAINSTEP_SHIFT	10
 #define  B43_NPHY_C1_CGAINI_CL2DETECT		0x2000 /* Clip 2 detect mask */
 #define B43_NPHY_C1_CCK_CGAINI			B43_PHY_N(0x01D) /* Core 1 CCK compute gain info */
 #define  B43_NPHY_C1_CCK_CGAINI_GAINBKOFF	0x001F /* Gain backoff */
@@ -69,29 +72,32 @@
 #define B43_NPHY_C1_CLIP1THRES			B43_PHY_N(0x02C) /* Core 1 clip1 threshold */
 #define B43_NPHY_C1_CLIP2THRES			B43_PHY_N(0x02D) /* Core 1 clip2 threshold */
 
-#define B43_NPHY_C2_DESPWR			B43_PHY_N(0x018 + 22) /* Core 2 desired power */
-#define B43_NPHY_C2_CCK_DESPWR			B43_PHY_N(0x019 + 22) /* Core 2 CCK desired power */
-#define B43_NPHY_C2_BCLIPBKOFF			B43_PHY_N(0x01A + 22) /* Core 2 barely clip backoff */
-#define B43_NPHY_C2_CCK_BCLIPBKOFF		B43_PHY_N(0x01B + 22) /* Core 2 CCK barely clip backoff */
-#define B43_NPHY_C2_CGAINI			B43_PHY_N(0x01C + 22) /* Core 2 compute gain info */
+#define B43_NPHY_C2_DESPWR			B43_PHY_N(0x02E) /* Core 2 desired power */
+#define B43_NPHY_C2_CCK_DESPWR			B43_PHY_N(0x02F) /* Core 2 CCK desired power */
+#define B43_NPHY_C2_BCLIPBKOFF			B43_PHY_N(0x030) /* Core 2 barely clip backoff */
+#define B43_NPHY_C2_CCK_BCLIPBKOFF		B43_PHY_N(0x031) /* Core 2 CCK barely clip backoff */
+#define B43_NPHY_C2_CGAINI			B43_PHY_N(0x032) /* Core 2 compute gain info */
 #define  B43_NPHY_C2_CGAINI_GAINBKOFF		0x001F /* Gain backoff */
+#define  B43_NPHY_C2_CGAINI_GAINBKOFF_SHIFT	0
 #define  B43_NPHY_C2_CGAINI_CLIPGBKOFF		0x03E0 /* Clip gain backoff */
+#define  B43_NPHY_C2_CGAINI_CLIPGBKOFF_SHIFT	5
 #define  B43_NPHY_C2_CGAINI_GAINSTEP		0x1C00 /* Gain step */
+#define  B43_NPHY_C2_CGAINI_GAINSTEP_SHIFT	10
 #define  B43_NPHY_C2_CGAINI_CL2DETECT		0x2000 /* Clip 2 detect mask */
-#define B43_NPHY_C2_CCK_CGAINI			B43_PHY_N(0x01D + 22) /* Core 2 CCK compute gain info */
+#define B43_NPHY_C2_CCK_CGAINI			B43_PHY_N(0x033) /* Core 2 CCK compute gain info */
 #define  B43_NPHY_C2_CCK_CGAINI_GAINBKOFF	0x001F /* Gain backoff */
 #define  B43_NPHY_C2_CCK_CGAINI_CLIPGBKOFF	0x01E0 /* CCK barely clip gain backoff */
-#define B43_NPHY_C2_MINMAX_GAIN			B43_PHY_N(0x01E + 22) /* Core 2 min/max gain */
+#define B43_NPHY_C2_MINMAX_GAIN			B43_PHY_N(0x034) /* Core 2 min/max gain */
 #define  B43_NPHY_C2_MINGAIN			0x00FF /* Minimum gain */
 #define  B43_NPHY_C2_MINGAIN_SHIFT		0
 #define  B43_NPHY_C2_MAXGAIN			0xFF00 /* Maximum gain */
 #define  B43_NPHY_C2_MAXGAIN_SHIFT		8
-#define B43_NPHY_C2_CCK_MINMAX_GAIN		B43_PHY_N(0x01F + 22) /* Core 2 CCK min/max gain */
+#define B43_NPHY_C2_CCK_MINMAX_GAIN		B43_PHY_N(0x035) /* Core 2 CCK min/max gain */
 #define  B43_NPHY_C2_CCK_MINGAIN		0x00FF /* Minimum gain */
 #define  B43_NPHY_C2_CCK_MINGAIN_SHIFT		0
 #define  B43_NPHY_C2_CCK_MAXGAIN		0xFF00 /* Maximum gain */
 #define  B43_NPHY_C2_CCK_MAXGAIN_SHIFT		8
-#define B43_NPHY_C2_INITGAIN			B43_PHY_N(0x020 + 22) /* Core 2 initial gain code */
+#define B43_NPHY_C2_INITGAIN			B43_PHY_N(0x036) /* Core 2 initial gain code */
 #define  B43_NPHY_C2_INITGAIN_EXTLNA		0x0001 /* External LNA index */
 #define  B43_NPHY_C2_INITGAIN_LNA		0x0006 /* LNA index */
 #define  B43_NPHY_C2_INITGAIN_LNAIDX_SHIFT	1
@@ -101,23 +107,23 @@
 #define  B43_NPHY_C2_INITGAIN_HPVGA2_SHIFT	7
 #define  B43_NPHY_C2_INITGAIN_TRRX		0x1000 /* TR RX index */
 #define  B43_NPHY_C2_INITGAIN_TRTX		0x2000 /* TR TX index */
-#define B43_NPHY_C2_CLIP1_HIGAIN		B43_PHY_N(0x021 + 22) /* Core 2 clip1 high gain code */
-#define B43_NPHY_C2_CLIP1_MEDGAIN		B43_PHY_N(0x022 + 22) /* Core 2 clip1 medium gain code */
-#define B43_NPHY_C2_CLIP1_LOGAIN		B43_PHY_N(0x023 + 22) /* Core 2 clip1 low gain code */
-#define B43_NPHY_C2_CLIP2_GAIN			B43_PHY_N(0x024 + 22) /* Core 2 clip2 gain code */
-#define B43_NPHY_C2_FILTERGAIN			B43_PHY_N(0x025 + 22) /* Core 2 filter gain */
-#define B43_NPHY_C2_LPF_QHPF_BW			B43_PHY_N(0x026 + 22) /* Core 2 LPF Q HP F bandwidth */
-#define B43_NPHY_C2_CLIPWBTHRES			B43_PHY_N(0x027 + 22) /* Core 2 clip wideband threshold */
+#define B43_NPHY_C2_CLIP1_HIGAIN		B43_PHY_N(0x037) /* Core 2 clip1 high gain code */
+#define B43_NPHY_C2_CLIP1_MEDGAIN		B43_PHY_N(0x038) /* Core 2 clip1 medium gain code */
+#define B43_NPHY_C2_CLIP1_LOGAIN		B43_PHY_N(0x039) /* Core 2 clip1 low gain code */
+#define B43_NPHY_C2_CLIP2_GAIN			B43_PHY_N(0x03A) /* Core 2 clip2 gain code */
+#define B43_NPHY_C2_FILTERGAIN			B43_PHY_N(0x03B) /* Core 2 filter gain */
+#define B43_NPHY_C2_LPF_QHPF_BW			B43_PHY_N(0x03C) /* Core 2 LPF Q HP F bandwidth */
+#define B43_NPHY_C2_CLIPWBTHRES			B43_PHY_N(0x03D) /* Core 2 clip wideband threshold */
 #define  B43_NPHY_C2_CLIPWBTHRES_CLIP2		0x003F /* Clip 2 */
 #define  B43_NPHY_C2_CLIPWBTHRES_CLIP2_SHIFT	0
 #define  B43_NPHY_C2_CLIPWBTHRES_CLIP1		0x0FC0 /* Clip 1 */
 #define  B43_NPHY_C2_CLIPWBTHRES_CLIP1_SHIFT	6
-#define B43_NPHY_C2_W1THRES			B43_PHY_N(0x028 + 22) /* Core 2 W1 threshold */
-#define B43_NPHY_C2_EDTHRES			B43_PHY_N(0x029 + 22) /* Core 2 ED threshold */
-#define B43_NPHY_C2_SMSIGTHRES			B43_PHY_N(0x02A + 22) /* Core 2 small sig threshold */
-#define B43_NPHY_C2_NBCLIPTHRES			B43_PHY_N(0x02B + 22) /* Core 2 NB clip threshold */
-#define B43_NPHY_C2_CLIP1THRES			B43_PHY_N(0x02C + 22) /* Core 2 clip1 threshold */
-#define B43_NPHY_C2_CLIP2THRES			B43_PHY_N(0x02D + 22) /* Core 2 clip2 threshold */
+#define B43_NPHY_C2_W1THRES			B43_PHY_N(0x03E) /* Core 2 W1 threshold */
+#define B43_NPHY_C2_EDTHRES			B43_PHY_N(0x03F) /* Core 2 ED threshold */
+#define B43_NPHY_C2_SMSIGTHRES			B43_PHY_N(0x040) /* Core 2 small sig threshold */
+#define B43_NPHY_C2_NBCLIPTHRES			B43_PHY_N(0x041) /* Core 2 NB clip threshold */
+#define B43_NPHY_C2_CLIP1THRES			B43_PHY_N(0x042) /* Core 2 clip1 threshold */
+#define B43_NPHY_C2_CLIP2THRES			B43_PHY_N(0x043) /* Core 2 clip2 threshold */
 
 #define B43_NPHY_CRS_THRES1			B43_PHY_N(0x044) /* CRS threshold 1 */
 #define B43_NPHY_CRS_THRES2			B43_PHY_N(0x045) /* CRS threshold 2 */
@@ -225,7 +231,7 @@
 #define B43_NPHY_C2_TXIQ_COMP_OFF		B43_PHY_N(0x088) /* Core 2 TX I/Q comp offset */
 #define B43_NPHY_C1_TXCTL			B43_PHY_N(0x08B) /* Core 1 TX control */
 #define B43_NPHY_C2_TXCTL			B43_PHY_N(0x08C) /* Core 2 TX control */
-#define B43_NPHY_SCRAM_SIGCTL			B43_PHY_N(0x090) /* Scran signal control */
+#define B43_NPHY_SCRAM_SIGCTL			B43_PHY_N(0x090) /* Scram signal control */
 #define  B43_NPHY_SCRAM_SIGCTL_INITST		0x007F /* Initial state value */
 #define  B43_NPHY_SCRAM_SIGCTL_INITST_SHIFT	0
 #define  B43_NPHY_SCRAM_SIGCTL_SCM		0x0080 /* Scram control mode */
diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/wireless/b43legacy/b43legacy.h
index 8352a4e..93419ad 100644
--- a/drivers/net/wireless/b43legacy/b43legacy.h
+++ b/drivers/net/wireless/b43legacy/b43legacy.h
@@ -415,7 +415,6 @@ struct b43legacy_phy {
 	u8 calibrated:1;
 	u8 radio_rev;		/* Radio revision */
 
-	bool locked;		/* Only used in b43legacy_phy_{un}lock() */
 	bool dyn_tssi_tbl;	/* tssi2dbm is kmalloc()ed. */
 
 	/* ACI (adjacent channel interference) flags. */
@@ -458,11 +457,6 @@ struct b43legacy_phy {
 	s16 lna_gain;		/* LNA */
 	s16 pga_gain;		/* PGA */
 
-	/* PHY lock for core.rev < 3
-	 * This lock is only used by b43legacy_phy_{un}lock()
-	 */
-	spinlock_t lock;
-
 	/* Desired TX power level (in dBm). This is set by the user and
 	 * adjusted in b43legacy_phy_xmitpower(). */
 	u8 power_level;
@@ -486,9 +480,6 @@ struct b43legacy_phy {
 		u16 txpwr_offset;
 	};
 
-#ifdef CONFIG_B43LEGACY_DEBUG
-	bool manual_txpower_control; /* Manual TX-power control enabled? */
-#endif
 	/* Current Interference Mitigation mode */
 	int interfmode;
 	/* Stack of saved values from the Interference Mitigation code.
@@ -516,6 +507,13 @@ struct b43legacy_phy {
 
 	/* PHY TX errors counter. */
 	atomic_t txerr_cnt;
+
+#if B43legacy_DEBUG
+	/* Manual TX-power control enabled? */
+	bool manual_txpower_control;
+	/* PHY registers locked by b43legacy_phy_lock()? */
+	bool phy_locked;
+#endif /* B43legacy_DEBUG */
 };
 
 /* Data structures for DMA transmission, per 80211 core. */
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 2d5735d..4ed4243 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2847,8 +2847,6 @@ static void setup_struct_phy_for_init(struct b43legacy_wldev *dev,
 	memset(phy->minlowsig, 0xFF, sizeof(phy->minlowsig));
 	memset(phy->minlowsigpos, 0, sizeof(phy->minlowsigpos));
 
-	/* Flags */
-	phy->locked = 0;
 	/* Assume the radio is enabled. If it's not enabled, the state will
 	 * immediately get fixed on the first periodic work run. */
 	dev->radio_hw_enable = 1;
@@ -2881,7 +2879,6 @@ static void setup_struct_phy_for_init(struct b43legacy_wldev *dev,
 	phy->lofcal = 0xFFFF;
 	phy->initval = 0xFFFF;
 
-	spin_lock_init(&phy->lock);
 	phy->interfmode = B43legacy_INTERFMODE_NONE;
 	phy->channel = 0xFF;
 }
@@ -3013,7 +3010,6 @@ static void prepare_phy_data_for_init(struct b43legacy_wldev *dev)
 
 	/* Flags */
 	phy->calibrated = 0;
-	phy->locked = 0;
 
 	if (phy->_lo_pairs)
 		memset(phy->_lo_pairs, 0,
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireless/b43legacy/phy.c
index 57c668f..c16febb 100644
--- a/drivers/net/wireless/b43legacy/phy.c
+++ b/drivers/net/wireless/b43legacy/phy.c
@@ -91,40 +91,36 @@ void b43legacy_voluntary_preempt(void)
 #endif /* CONFIG_PREEMPT */
 }
 
-void b43legacy_raw_phy_lock(struct b43legacy_wldev *dev)
+/* Lock the PHY registers against concurrent access from the microcode.
+ * This lock is nonrecursive. */
+void b43legacy_phy_lock(struct b43legacy_wldev *dev)
 {
-	struct b43legacy_phy *phy = &dev->phy;
+#if B43legacy_DEBUG
+	B43legacy_WARN_ON(dev->phy.phy_locked);
+	dev->phy.phy_locked = 1;
+#endif
 
-	B43legacy_WARN_ON(!irqs_disabled());
-	if (b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD) == 0) {
-		phy->locked = 0;
-		return;
-	}
 	if (dev->dev->id.revision < 3) {
 		b43legacy_mac_suspend(dev);
-		spin_lock(&phy->lock);
 	} else {
 		if (!b43legacy_is_mode(dev->wl, IEEE80211_IF_TYPE_AP))
 			b43legacy_power_saving_ctl_bits(dev, -1, 1);
 	}
-	phy->locked = 1;
 }
 
-void b43legacy_raw_phy_unlock(struct b43legacy_wldev *dev)
+void b43legacy_phy_unlock(struct b43legacy_wldev *dev)
 {
-	struct b43legacy_phy *phy = &dev->phy;
+#if B43legacy_DEBUG
+	B43legacy_WARN_ON(!dev->phy.phy_locked);
+	dev->phy.phy_locked = 0;
+#endif
 
-	B43legacy_WARN_ON(!irqs_disabled());
 	if (dev->dev->id.revision < 3) {
-		if (phy->locked) {
-			spin_unlock(&phy->lock);
-			b43legacy_mac_enable(dev);
-		}
+		b43legacy_mac_enable(dev);
 	} else {
 		if (!b43legacy_is_mode(dev->wl, IEEE80211_IF_TYPE_AP))
 			b43legacy_power_saving_ctl_bits(dev, -1, -1);
 	}
-	phy->locked = 0;
 }
 
 u16 b43legacy_phy_read(struct b43legacy_wldev *dev, u16 offset)
@@ -1789,7 +1785,6 @@ void b43legacy_phy_xmitpower(struct b43legacy_wldev *dev)
 	s16 baseband_att_delta;
 	s16 radio_attenuation;
 	s16 baseband_attenuation;
-	unsigned long phylock_flags;
 
 	if (phy->savedpctlreg == 0xFFFF)
 		return;
@@ -1944,13 +1939,13 @@ void b43legacy_phy_xmitpower(struct b43legacy_wldev *dev)
 	phy->bbatt = baseband_attenuation;
 
 	/* Adjust the hardware */
-	b43legacy_phy_lock(dev, phylock_flags);
+	b43legacy_phy_lock(dev);
 	b43legacy_radio_lock(dev);
 	b43legacy_radio_set_txpower_bg(dev, baseband_attenuation,
 				       radio_attenuation, txpower);
 	b43legacy_phy_lo_mark_current_used(dev);
 	b43legacy_radio_unlock(dev);
-	b43legacy_phy_unlock(dev, phylock_flags);
+	b43legacy_phy_unlock(dev);
 }
 
 static inline
diff --git a/drivers/net/wireless/b43legacy/phy.h b/drivers/net/wireless/b43legacy/phy.h
index efa4c5c..ecbe409 100644
--- a/drivers/net/wireless/b43legacy/phy.h
+++ b/drivers/net/wireless/b43legacy/phy.h
@@ -171,18 +171,8 @@ void b43legacy_put_attenuation_into_ranges(int *_bbatt, int *_rfatt);
 
 struct b43legacy_wldev;
 
-void b43legacy_raw_phy_lock(struct b43legacy_wldev *dev);
-#define b43legacy_phy_lock(bcm, flags) 		\
-	do {					\
-		local_irq_save(flags);		\
-		b43legacy_raw_phy_lock(bcm);	\
-	} while (0)
-void b43legacy_raw_phy_unlock(struct b43legacy_wldev *dev);
-#define b43legacy_phy_unlock(bcm, flags)	\
-	do {					\
-		b43legacy_raw_phy_unlock(bcm);	\
-		local_irq_restore(flags);	\
-	} while (0)
+void b43legacy_phy_lock(struct b43legacy_wldev *dev);
+void b43legacy_phy_unlock(struct b43legacy_wldev *dev);
 
 /* Card uses the loopback gain stuff */
 #define has_loopback_gain(phy)			 \
diff --git a/drivers/net/wireless/b43legacy/radio.c b/drivers/net/wireless/b43legacy/radio.c
index 1a72eb0..318a270 100644
--- a/drivers/net/wireless/b43legacy/radio.c
+++ b/drivers/net/wireless/b43legacy/radio.c
@@ -92,6 +92,7 @@ void b43legacy_radio_lock(struct b43legacy_wldev *dev)
 	u32 status;
 
 	status = b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
+	B43legacy_WARN_ON(status & B43legacy_SBF_RADIOREG_LOCK);
 	status |= B43legacy_SBF_RADIOREG_LOCK;
 	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
 	mmiowb();
@@ -104,6 +105,7 @@ void b43legacy_radio_unlock(struct b43legacy_wldev *dev)
 
 	b43legacy_read16(dev, B43legacy_MMIO_PHY_VER); /* dummy read */
 	status = b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
+	B43legacy_WARN_ON(!(status & B43legacy_SBF_RADIOREG_LOCK));
 	status &= ~B43legacy_SBF_RADIOREG_LOCK;
 	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
 	mmiowb();
@@ -284,12 +286,11 @@ u8 b43legacy_radio_aci_scan(struct b43legacy_wldev *dev)
 	unsigned int j;
 	unsigned int start;
 	unsigned int end;
-	unsigned long phylock_flags;
 
 	if (!((phy->type == B43legacy_PHYTYPE_G) && (phy->rev > 0)))
 		return 0;
 
-	b43legacy_phy_lock(dev, phylock_flags);
+	b43legacy_phy_lock(dev);
 	b43legacy_radio_lock(dev);
 	b43legacy_phy_write(dev, 0x0802,
 			    b43legacy_phy_read(dev, 0x0802) & 0xFFFC);
@@ -323,7 +324,7 @@ u8 b43legacy_radio_aci_scan(struct b43legacy_wldev *dev)
 			ret[j] = 1;
 	}
 	b43legacy_radio_unlock(dev);
-	b43legacy_phy_unlock(dev, phylock_flags);
+	b43legacy_phy_unlock(dev);
 
 	return ret[channel - 1];
 }
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 4d5a4c9..5de6d91 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -237,8 +237,8 @@ struct ieee80211_bar {
 	__le16 duration;
 	__u8 ra[6];
 	__u8 ta[6];
-	__u16 control;
-	__u16 start_seq_num;
+	__le16 control;
+	__le16 start_seq_num;
 } __attribute__((packed));
 
 /**
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index e7da1cd..2019b4f 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -1154,8 +1154,8 @@ end_no_lock:
 	sta_info_put(sta);
 }
 
-void ieee80211_send_delba(struct net_device *dev, const u8 *da, u16 tid,
-				u16 initiator, u16 reason_code)
+static void ieee80211_send_delba(struct net_device *dev, const u8 *da, u16 tid,
+				 u16 initiator, u16 reason_code)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index 962286d..554c4ba 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -496,6 +496,8 @@ static void *rate_control_pid_alloc_sta(void *priv, gfp_t gfp)
 	if (spinfo == NULL)
 		return NULL;
 
+	spinfo->last_sample = jiffies;
+
 #ifdef CONFIG_MAC80211_DEBUGFS
 	spin_lock_init(&spinfo->events.lock);
 	init_waitqueue_head(&spinfo->events.waitqueue);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 465fce0..89e1e30 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -295,7 +295,7 @@ ieee80211_rx_h_parse_qos(struct ieee80211_txrx_data *rx)
 }
 
 
-u32 ieee80211_rx_load_stats(struct ieee80211_local *local,
+static u32 ieee80211_rx_load_stats(struct ieee80211_local *local,
 			      struct sk_buff *skb,
 			      struct ieee80211_rx_status *status)
 {
@@ -1664,8 +1664,10 @@ static int prepare_for_handlers(struct ieee80211_sub_if_data *sdata,
  * This is the actual Rx frames handler. as it blongs to Rx path it must
  * be called with rcu_read_lock protection.
  */
-void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw, struct sk_buff *skb,
-			    struct ieee80211_rx_status *status, u32 load)
+static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
+					 struct sk_buff *skb,
+					 struct ieee80211_rx_status *status,
+					 u32 load)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata;
@@ -1730,7 +1732,6 @@ void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw, struct sk_buff *skb,
 		ieee80211_invoke_rx_handlers(local, local->rx_handlers, &rx,
 					     rx.sta);
 		sta_info_put(sta);
-		rcu_read_unlock();
 		return;
 	}
 
@@ -1920,8 +1921,8 @@ u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
 	return 1;
 }
 
-u8 ieee80211_rx_reorder_ampdu(struct ieee80211_local *local,
-			      struct sk_buff *skb)
+static u8 ieee80211_rx_reorder_ampdu(struct ieee80211_local *local,
+				     struct sk_buff *skb)
 {
 	struct ieee80211_hw *hw = &local->hw;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 455fadc..0245195 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -28,6 +28,7 @@ struct ieee80211_sched_data
 	struct sk_buff_head requeued[TC_80211_MAX_QUEUES];
 };
 
+static const char llc_ip_hdr[8] = {0xAA, 0xAA, 0x3, 0, 0, 0, 0x08, 0};
 
 /* given a data frame determine the 802.1p/1d tag to use */
 static inline unsigned classify_1d(struct sk_buff *skb, struct Qdisc *qd)
@@ -54,12 +55,12 @@ static inline unsigned classify_1d(struct sk_buff *skb, struct Qdisc *qd)
 		return skb->priority - 256;
 
 	/* check there is a valid IP header present */
-	offset = ieee80211_get_hdrlen_from_skb(skb) + 8 /* LLC + proto */;
-	if (skb->protocol != htons(ETH_P_IP) ||
-	    skb->len < offset + sizeof(*ip))
+	offset = ieee80211_get_hdrlen_from_skb(skb);
+	if (skb->len < offset + sizeof(llc_ip_hdr) + sizeof(*ip) ||
+	    memcmp(skb->data + offset, llc_ip_hdr, sizeof(llc_ip_hdr)))
 		return 0;
 
-	ip = (struct iphdr *) (skb->data + offset);
+	ip = (struct iphdr *) (skb->data + offset + sizeof(llc_ip_hdr));
 
 	dscp = ip->tos & 0xfc;
 	if (dscp & 0x1c)
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 1e4cf61..2c569b6 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -417,20 +417,6 @@ static const int event_type_size[] = {
 	IW_EV_QUAL_LEN,			/* IW_HEADER_TYPE_QUAL */
 };
 
-/* Size (in bytes) of various events, as packed */
-static const int event_type_pk_size[] = {
-	IW_EV_LCP_PK_LEN,		/* IW_HEADER_TYPE_NULL */
-	0,
-	IW_EV_CHAR_PK_LEN,		/* IW_HEADER_TYPE_CHAR */
-	0,
-	IW_EV_UINT_PK_LEN,		/* IW_HEADER_TYPE_UINT */
-	IW_EV_FREQ_PK_LEN,		/* IW_HEADER_TYPE_FREQ */
-	IW_EV_ADDR_PK_LEN,		/* IW_HEADER_TYPE_ADDR */
-	0,
-	IW_EV_POINT_PK_LEN,		/* Without variable payload */
-	IW_EV_PARAM_PK_LEN,		/* IW_HEADER_TYPE_PARAM */
-	IW_EV_QUAL_PK_LEN,		/* IW_HEADER_TYPE_QUAL */
-};
 
 /************************ COMMON SUBROUTINES ************************/
 /*
-- 
John W. Linville
linville@tuxdriver.com
