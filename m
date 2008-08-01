From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-08-01
Date: Fri, 1 Aug 2008 16:58:30 -0400
Message-ID: <20080801205830.GA10071@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2463 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757775AbYHAVF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 17:05:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another big batch of wireless fixes for 2.6.27.  The ath5k series is
more than fixes, but I included it because it enables new ath5k
hardware.  (The ath5k.h changes in particular are documentation cleanups
for registers based on info gleaned from the newly posted ath9k driver.)
The others patches are fixes, some more obvious than others. :-)

Let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 00b1304c4ca81dd893973cc620b87a5c3ff3f660:
  Adam Langley (1):
        tcp: MD5: Fix IPv6 signatures

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrea Merello (1):
      Rtl8187 PATCH add usb ID for asus wireless link

Dan Williams (1):
      libertas: only enable rtap with mesh firmware

Dmitry Baryshkov (2):
      RFKILL: allow one to specify led trigger name
      RFKILL: set the status of the leds on activation.

Helmut Schaa (1):
      ath5k: remove obsolete declaration of struct ieee80211_hw_mode

Henrique de Moraes Holschuh (1):
      rfkill: query EV_SW states when rfkill-input (re)?connects to a input device

Ivo van Doorn (5):
      rt2x00: Fix access permissions on debugfs files
      rt2x00: Fix partial antenna configuration
      rt2x00: rt61pci needs another millisecond after firmware upload
      rt2x00: Fix VGC lower bound initialization
      rt2x00: Sequence counter should be protected in irqsave

Jiri Slaby (1):
      Ath5k: mask out unneeded interrupts

Larry Finger (1):
      rtl8187: Fix lockups due to concurrent access to config routine

Maxim Levitsky (1):
      iwl3945: Fix statistics in monitor mode

Nick Kossifidis (9):
      ath5k: Update register list
      ath5k: Restore saved initval after POST
      ath5k: Misc hw_attach fixes
      ath5k: Misc hw_reset updates
      ath5k: Do ADC test during reset
      ath5k: Reorder calibration calls during reset and update hw_set_power
      ath5k: Add RF2425 initial rfgain values
      ath5k: Update channel functions
      ath5k: Update phy calibration functions

Peter Chubb (1):
      rt2500pci: restoring missing line

Takashi Iwai (2):
      ipw2200 - Fix bad ipw_write8() macro
      prism54 - Use offsetof()

Tomas Winkler (2):
      mac80211: fix fragmentation kludge
      iwlwifi: don't stop queue in the middle of fragmented packet

 drivers/net/wireless/Kconfig               |    1 +
 drivers/net/wireless/ath5k/ath5k.h         |    8 +-
 drivers/net/wireless/ath5k/base.c          |    1 +
 drivers/net/wireless/ath5k/debug.c         |    2 +-
 drivers/net/wireless/ath5k/debug.h         |    1 -
 drivers/net/wireless/ath5k/hw.c            |  239 +++++---
 drivers/net/wireless/ath5k/initvals.c      |    4 +-
 drivers/net/wireless/ath5k/phy.c           |  185 +++++-
 drivers/net/wireless/ath5k/reg.h           |  934 +++++++++++++++++++++-------
 drivers/net/wireless/ipw2200.c             |    5 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c    |   10 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c      |    8 +-
 drivers/net/wireless/libertas/main.c       |   15 +-
 drivers/net/wireless/prism54/isl_ioctl.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c    |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c    |    6 +-
 drivers/net/wireless/rt2x00/rt2x00.h       |    6 +
 drivers/net/wireless/rt2x00/rt2x00config.c |    4 +
 drivers/net/wireless/rt2x00/rt2x00debug.c  |   17 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c    |    1 +
 drivers/net/wireless/rt2x00/rt2x00queue.c  |    5 +-
 drivers/net/wireless/rt2x00/rt61pci.c      |    5 +
 drivers/net/wireless/rtl8187.h             |    4 +
 drivers/net/wireless/rtl8187_dev.c         |   17 +-
 net/mac80211/ieee80211_i.h                 |    1 +
 net/mac80211/tx.c                          |   17 +-
 net/mac80211/util.c                        |    1 +
 net/rfkill/rfkill-input.c                  |   54 ++-
 net/rfkill/rfkill.c                        |   15 +-
 29 files changed, 1161 insertions(+), 408 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 91fc2c7..4c7ff61 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -649,6 +649,7 @@ config RTL8187
 	  Trendnet TEW-424UB
 	  ASUS P5B Deluxe
 	  Toshiba Satellite Pro series of laptops
+	  Asus Wireless Link
 
 	  Thanks to Realtek for their support!
 
diff --git a/drivers/net/wireless/ath5k/ath5k.h b/drivers/net/wireless/ath5k/ath5k.h
index ba35c30..9102eea 100644
--- a/drivers/net/wireless/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath5k/ath5k.h
@@ -186,11 +186,13 @@ struct ath5k_srev_name {
 #define AR5K_SREV_RAD_2111	0x20
 #define AR5K_SREV_RAD_5112	0x30
 #define AR5K_SREV_RAD_5112A	0x35
+#define	AR5K_SREV_RAD_5112B	0x36
 #define AR5K_SREV_RAD_2112	0x40
 #define AR5K_SREV_RAD_2112A	0x45
-#define AR5K_SREV_RAD_SC0	0x56	/* Found on 2413/2414 */
-#define AR5K_SREV_RAD_SC1	0x63	/* Found on 5413/5414 */
-#define AR5K_SREV_RAD_SC2	0xa2	/* Found on 2424-5/5424 */
+#define	AR5K_SREV_RAD_2112B	0x46
+#define AR5K_SREV_RAD_SC0	0x50	/* Found on 2413/2414 */
+#define AR5K_SREV_RAD_SC1	0x60	/* Found on 5413/5414 */
+#define AR5K_SREV_RAD_SC2	0xa0	/* Found on 2424-5/5424 */
 #define AR5K_SREV_RAD_5133	0xc0	/* MIMO found on 5418 */
 
 /* IEEE defs */
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index ff3fad7..ebf19bc 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -2170,6 +2170,7 @@ ath5k_beacon_config(struct ath5k_softc *sc)
 
 	ath5k_hw_set_intr(ah, 0);
 	sc->bmisscount = 0;
+	sc->imask &= ~(AR5K_INT_BMISS | AR5K_INT_SWBA);
 
 	if (sc->opmode == IEEE80211_IF_TYPE_STA) {
 		sc->imask |= AR5K_INT_BMISS;
diff --git a/drivers/net/wireless/ath5k/debug.c b/drivers/net/wireless/ath5k/debug.c
index 41d5fa3..6fa6c8e 100644
--- a/drivers/net/wireless/ath5k/debug.c
+++ b/drivers/net/wireless/ath5k/debug.c
@@ -129,7 +129,7 @@ static struct reg regs[] = {
 	REG_STRUCT_INIT(AR5K_CPC1),
 	REG_STRUCT_INIT(AR5K_CPC2),
 	REG_STRUCT_INIT(AR5K_CPC3),
-	REG_STRUCT_INIT(AR5K_CPCORN),
+	REG_STRUCT_INIT(AR5K_CPCOVF),
 	REG_STRUCT_INIT(AR5K_RESET_CTL),
 	REG_STRUCT_INIT(AR5K_SLEEP_CTL),
 	REG_STRUCT_INIT(AR5K_INTPEND),
diff --git a/drivers/net/wireless/ath5k/debug.h b/drivers/net/wireless/ath5k/debug.h
index 2cf8d18..ffc5293 100644
--- a/drivers/net/wireless/ath5k/debug.h
+++ b/drivers/net/wireless/ath5k/debug.h
@@ -63,7 +63,6 @@
 
 struct ath5k_softc;
 struct ath5k_hw;
-struct ieee80211_hw_mode;
 struct sk_buff;
 struct ath5k_buf;
 
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index 7ca87a5..ad1a5b4 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -139,6 +139,8 @@ static int ath5k_hw_post(struct ath5k_hw *ah)
 	for (c = 0; c < 2; c++) {
 
 		cur_reg = regs[c];
+
+		/* Save previous value */
 		init_val = ath5k_hw_reg_read(ah, cur_reg);
 
 		for (i = 0; i < 256; i++) {
@@ -170,6 +172,10 @@ static int ath5k_hw_post(struct ath5k_hw *ah)
 			var_pattern = 0x003b080f;
 			ath5k_hw_reg_write(ah, var_pattern, cur_reg);
 		}
+
+		/* Restore previous value */
+		ath5k_hw_reg_write(ah, init_val, cur_reg);
+
 	}
 
 	return 0;
@@ -287,67 +293,42 @@ struct ath5k_hw *ath5k_hw_attach(struct ath5k_softc *sc, u8 mac_version)
 	/* Identify the radio chip*/
 	if (ah->ah_version == AR5K_AR5210) {
 		ah->ah_radio = AR5K_RF5110;
+	/*
+	 * Register returns 0x0/0x04 for radio revision
+	 * so ath5k_hw_radio_revision doesn't parse the value
+	 * correctly. For now we are based on mac's srev to
+	 * identify RF2425 radio.
+	 */
+	} else if (srev == AR5K_SREV_VER_AR2425) {
+		ah->ah_radio = AR5K_RF2425;
+		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF2425;
 	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_5112) {
 		ah->ah_radio = AR5K_RF5111;
 		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5111;
 	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_SC0) {
-
 		ah->ah_radio = AR5K_RF5112;
-
-		if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_5112A) {
-			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112;
-		} else {
-			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
-		}
-
+		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112;
 	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_SC1) {
 		ah->ah_radio = AR5K_RF2413;
-		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
+		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF2413;
 	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_SC2) {
 		ah->ah_radio = AR5K_RF5413;
-		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
+		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5413;
 	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_5133) {
-
 		/* AR5424 */
 		if (srev >= AR5K_SREV_VER_AR5424) {
 			ah->ah_radio = AR5K_RF5413;
-			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5424;
+			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5413;
 		/* AR2424 */
 		} else {
 			ah->ah_radio = AR5K_RF2413; /* For testing */
-			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
+			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF2413;
 		}
-
-	/*
-	 * Register returns 0x4 for radio revision
-	 * so ath5k_hw_radio_revision doesn't parse the value
-	 * correctly. For now we are based on mac's srev to
-	 * identify RF2425 radio.
-	 */
-	} else if (srev == AR5K_SREV_VER_AR2425) {
-		ah->ah_radio = AR5K_RF2425;
-		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112;
 	}
-
 	ah->ah_phy = AR5K_PHY(0);
 
 	/*
-	 * Identify AR5212-based PCI-E cards
-	 * And write some initial settings.
-	 *
-	 * (doing a "strings" on ndis driver
-	 * -ar5211.sys- reveals the following
-	 * pci-e related functions:
-	 *
-	 * pcieClockReq
-	 * pcieRxErrNotify
-	 * pcieL1SKPEnable
-	 * pcieAspm
-	 * pcieDisableAspmOnRfWake
-	 * pciePowerSaveEnable
-	 *
-	 * I guess these point to ClockReq but
-	 * i'm not sure.)
+	 * Write PCI-E power save settings
 	 */
 	if ((ah->ah_version == AR5K_AR5212) && (pdev->is_pcie)) {
 		ath5k_hw_reg_write(ah, 0x9248fc00, 0x4080);
@@ -369,10 +350,15 @@ struct ath5k_hw *ath5k_hw_attach(struct ath5k_softc *sc, u8 mac_version)
 	if (ret)
 		goto err_free;
 
+	/* Write AR5K_PCICFG_UNK on 2112B and later chips */
+	if (ah->ah_radio_5ghz_revision > AR5K_SREV_RAD_2112B ||
+	srev > AR5K_SREV_VER_AR2413) {
+		ath5k_hw_reg_write(ah, AR5K_PCICFG_UNK, AR5K_PCICFG);
+	}
+
 	/*
 	 * Get card capabilities, values, ...
 	 */
-
 	ret = ath5k_eeprom_init(ah);
 	if (ret) {
 		ATH5K_ERR(sc, "unable to init EEPROM\n");
@@ -843,27 +829,41 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 		 * Write some more initial register settings
 		 */
 		if (ah->ah_version == AR5K_AR5212) {
-			ath5k_hw_reg_write(ah, 0x0002a002, AR5K_PHY(11));
+			ath5k_hw_reg_write(ah, 0x0002a002, 0x982c);
 
 			if (channel->hw_value == CHANNEL_G)
 				if (ah->ah_mac_srev < AR5K_SREV_VER_AR2413)
 					ath5k_hw_reg_write(ah, 0x00f80d80,
-						AR5K_PHY(83));
+								0x994c);
 				else if (ah->ah_mac_srev < AR5K_SREV_VER_AR2424)
 					ath5k_hw_reg_write(ah, 0x00380140,
-						AR5K_PHY(83));
+								0x994c);
 				else if (ah->ah_mac_srev < AR5K_SREV_VER_AR2425)
 					ath5k_hw_reg_write(ah, 0x00fc0ec0,
-						AR5K_PHY(83));
+								0x994c);
 				else /* 2425 */
 					ath5k_hw_reg_write(ah, 0x00fc0fc0,
-						AR5K_PHY(83));
+								0x994c);
 			else
-				ath5k_hw_reg_write(ah, 0x00000000,
-					AR5K_PHY(83));
-
-			ath5k_hw_reg_write(ah, 0x000009b5, 0xa228);
-			ath5k_hw_reg_write(ah, 0x0000000f, 0x8060);
+				ath5k_hw_reg_write(ah, 0x00000000, 0x994c);
+
+			/* Some bits are disabled here, we know nothing about
+			 * register 0xa228 yet, most of the times this ends up
+			 * with a value 0x9b5 -haven't seen any dump with
+			 * a different value- */
+			/* Got this from decompiling binary HAL */
+			data = ath5k_hw_reg_read(ah, 0xa228);
+			data &= 0xfffffdff;
+			ath5k_hw_reg_write(ah, data, 0xa228);
+
+			data = ath5k_hw_reg_read(ah, 0xa228);
+			data &= 0xfffe03ff;
+			ath5k_hw_reg_write(ah, data, 0xa228);
+			data = 0;
+
+			/* Just write 0x9b5 ? */
+			/* ath5k_hw_reg_write(ah, 0x000009b5, 0xa228); */
+			ath5k_hw_reg_write(ah, 0x0000000f, AR5K_SEQ_MASK);
 			ath5k_hw_reg_write(ah, 0x00000000, 0xa254);
 			ath5k_hw_reg_write(ah, 0x0000000e, AR5K_PHY_SCAL);
 		}
@@ -879,6 +879,7 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 			else
 				data = 0xffb80d20;
 			ath5k_hw_reg_write(ah, data, AR5K_PHY_FRAME_CTL);
+			data = 0;
 		}
 
 		/*
@@ -898,7 +899,6 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 
 		/*
 		 * Write RF registers
-		 * TODO:Does this work on 5211 (5111) ?
 		 */
 		ret = ath5k_hw_rfregs(ah, channel, mode);
 		if (ret)
@@ -935,7 +935,7 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 			return ret;
 
 		/* Set antenna mode */
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x44),
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_ANT_CTL,
 			ah->ah_antenna[ee_mode][0], 0xfffffc06);
 
 		/*
@@ -965,15 +965,15 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 
 		ath5k_hw_reg_write(ah,
 			AR5K_PHY_NF_SVAL(ee->ee_noise_floor_thr[ee_mode]),
-			AR5K_PHY(0x5a));
+			AR5K_PHY_NFTHRES);
 
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x11),
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_SETTLING,
 			(ee->ee_switch_settling[ee_mode] << 7) & 0x3f80,
 			0xffffc07f);
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x12),
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_GAIN,
 			(ee->ee_ant_tx_rx[ee_mode] << 12) & 0x3f000,
 			0xfffc0fff);
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x14),
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_DESIRED_SIZE,
 			(ee->ee_adc_desired_size[ee_mode] & 0x00ff) |
 			((ee->ee_pga_desired_size[ee_mode] << 8) & 0xff00),
 			0xffff0000);
@@ -982,13 +982,13 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 			(ee->ee_tx_end2xpa_disable[ee_mode] << 24) |
 			(ee->ee_tx_end2xpa_disable[ee_mode] << 16) |
 			(ee->ee_tx_frm2xpa_enable[ee_mode] << 8) |
-			(ee->ee_tx_frm2xpa_enable[ee_mode]), AR5K_PHY(0x0d));
+			(ee->ee_tx_frm2xpa_enable[ee_mode]), AR5K_PHY_RF_CTL4);
 
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x0a),
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_RF_CTL3,
 			ee->ee_tx_end2xlna_enable[ee_mode] << 8, 0xffff00ff);
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x19),
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_NF,
 			(ee->ee_thr_62[ee_mode] << 12) & 0x7f000, 0xfff80fff);
-		AR5K_REG_MASKED_BITS(ah, AR5K_PHY(0x49), 4, 0xffffff01);
+		AR5K_REG_MASKED_BITS(ah, AR5K_PHY_OFDM_SELFCORR, 4, 0xffffff01);
 
 		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ,
 		    AR5K_PHY_IQ_CORR_ENABLE |
@@ -1063,7 +1063,8 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 	ath5k_hw_reg_write(ah, AR5K_PHY_ACT_ENABLE, AR5K_PHY_ACT);
 
 	/*
-	 * 5111/5112 Specific
+	 * On 5211+ read activation -> rx delay
+	 * and use it.
 	 */
 	if (ah->ah_version != AR5K_AR5210) {
 		data = ath5k_hw_reg_read(ah, AR5K_PHY_RX_DELAY) &
@@ -1071,40 +1072,77 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 		data = (channel->hw_value & CHANNEL_CCK) ?
 			((data << 2) / 22) : (data / 10);
 
-		udelay(100 + data);
+		udelay(100 + (2 * data));
+		data = 0;
 	} else {
 		mdelay(1);
 	}
 
 	/*
-	 * Enable calibration and wait until completion
+	 * Perform ADC test (?)
+	 */
+	data = ath5k_hw_reg_read(ah, AR5K_PHY_TST1);
+	ath5k_hw_reg_write(ah, AR5K_PHY_TST1_TXHOLD, AR5K_PHY_TST1);
+	for (i = 0; i <= 20; i++) {
+		if (!(ath5k_hw_reg_read(ah, AR5K_PHY_ADC_TEST) & 0x10))
+			break;
+		udelay(200);
+	}
+	ath5k_hw_reg_write(ah, data, AR5K_PHY_TST1);
+	data = 0;
+
+	/*
+	 * Start automatic gain calibration
+	 *
+	 * During AGC calibration RX path is re-routed to
+	 * a signal detector so we don't receive anything.
+	 *
+	 * This method is used to calibrate some static offsets
+	 * used together with on-the fly I/Q calibration (the
+	 * one performed via ath5k_hw_phy_calibrate), that doesn't
+	 * interrupt rx path.
+	 *
+	 * If we are in a noisy environment AGC calibration may time
+	 * out.
 	 */
 	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_AGCCTL,
 				AR5K_PHY_AGCCTL_CAL);
 
+	/* At the same time start I/Q calibration for QAM constellation
+	 * -no need for CCK- */
+	ah->ah_calibration = false;
+	if (!(mode == AR5K_MODE_11B)) {
+		ah->ah_calibration = true;
+		AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ,
+				AR5K_PHY_IQ_CAL_NUM_LOG_MAX, 15);
+		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ,
+				AR5K_PHY_IQ_RUN);
+	}
+
+	/* Wait for gain calibration to finish (we check for I/Q calibration
+	 * during ath5k_phy_calibrate) */
 	if (ath5k_hw_register_timeout(ah, AR5K_PHY_AGCCTL,
 			AR5K_PHY_AGCCTL_CAL, 0, false)) {
-		ATH5K_ERR(ah->ah_sc, "calibration timeout (%uMHz)\n",
+		ATH5K_ERR(ah->ah_sc, "gain calibration timeout (%uMHz)\n",
 			channel->center_freq);
 		return -EAGAIN;
 	}
 
+	/*
+	 * Start noise floor calibration
+	 *
+	 * If we run NF calibration before AGC, it always times out.
+	 * Binary HAL starts NF and AGC calibration at the same time
+	 * and only waits for AGC to finish. I believe that's wrong because
+	 * during NF calibration, rx path is also routed to a detector, so if
+	 * it doesn't finish we won't have RX.
+	 *
+	 * XXX: Find an interval that's OK for all cards...
+	 */
 	ret = ath5k_hw_noise_floor_calibration(ah, channel->center_freq);
 	if (ret)
 		return ret;
 
-	ah->ah_calibration = false;
-
-	/* A and G modes can use QAM modulation which requires enabling
-	 * I and Q calibration. Don't bother in B mode. */
-	if (!(mode == AR5K_MODE_11B)) {
-		ah->ah_calibration = true;
-		AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ,
-				AR5K_PHY_IQ_CAL_NUM_LOG_MAX, 15);
-		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ,
-				AR5K_PHY_IQ_RUN);
-	}
-
 	/*
 	 * Reset queues and start beacon timers at the end of the reset routine
 	 */
@@ -1154,6 +1192,12 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 		ath5k_hw_reg_write(ah, AR5K_PHY_SCLOCK_32MHZ, AR5K_PHY_SCLOCK);
 		ath5k_hw_reg_write(ah, AR5K_PHY_SDELAY_32MHZ, AR5K_PHY_SDELAY);
 		ath5k_hw_reg_write(ah, ah->ah_phy_spending, AR5K_PHY_SPENDING);
+
+		data = ath5k_hw_reg_read(ah, AR5K_USEC_5211) & 0xffffc07f ;
+		data |= (ah->ah_phy_spending == AR5K_PHY_SPENDING_18) ?
+						0x00000f80 : 0x00001380 ;
+		ath5k_hw_reg_write(ah, data, AR5K_USEC_5211);
+		data = 0;
 	}
 
 	if (ah->ah_version == AR5K_AR5212) {
@@ -1226,7 +1270,7 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 		bool set_chip, u16 sleep_duration)
 {
 	unsigned int i;
-	u32 staid;
+	u32 staid, data;
 
 	ATH5K_TRACE(ah->ah_sc);
 	staid = ath5k_hw_reg_read(ah, AR5K_STA_ID1);
@@ -1238,7 +1282,8 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 	case AR5K_PM_NETWORK_SLEEP:
 		if (set_chip)
 			ath5k_hw_reg_write(ah,
-				AR5K_SLEEP_CTL_SLE | sleep_duration,
+				AR5K_SLEEP_CTL_SLE_ALLOW |
+				sleep_duration,
 				AR5K_SLEEP_CTL);
 
 		staid |= AR5K_STA_ID1_PWR_SV;
@@ -1253,13 +1298,24 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 		break;
 
 	case AR5K_PM_AWAKE:
+
+		staid &= ~AR5K_STA_ID1_PWR_SV;
+
 		if (!set_chip)
 			goto commit;
 
-		ath5k_hw_reg_write(ah, AR5K_SLEEP_CTL_SLE_WAKE,
-				AR5K_SLEEP_CTL);
+		/* Preserve sleep duration */
+		data = ath5k_hw_reg_read(ah, AR5K_SLEEP_CTL);
+		if( data & 0xffc00000 ){
+			data = 0;
+		} else {
+			data = data & 0xfffcffff;
+		}
+
+		ath5k_hw_reg_write(ah, data, AR5K_SLEEP_CTL);
+		udelay(15);
 
-		for (i = 5000; i > 0; i--) {
+		for (i = 50; i > 0; i--) {
 			/* Check if the chip did wake up */
 			if ((ath5k_hw_reg_read(ah, AR5K_PCICFG) &
 					AR5K_PCICFG_SPWR_DN) == 0)
@@ -1267,15 +1323,13 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 
 			/* Wait a bit and retry */
 			udelay(200);
-			ath5k_hw_reg_write(ah, AR5K_SLEEP_CTL_SLE_WAKE,
-				AR5K_SLEEP_CTL);
+			ath5k_hw_reg_write(ah, data, AR5K_SLEEP_CTL);
 		}
 
 		/* Fail if the chip didn't wake up */
 		if (i <= 0)
 			return -EIO;
 
-		staid &= ~AR5K_STA_ID1_PWR_SV;
 		break;
 
 	default:
@@ -1304,6 +1358,7 @@ void ath5k_hw_start_rx(struct ath5k_hw *ah)
 {
 	ATH5K_TRACE(ah->ah_sc);
 	ath5k_hw_reg_write(ah, AR5K_CR_RXE, AR5K_CR);
+	ath5k_hw_reg_read(ah, AR5K_CR);
 }
 
 /*
@@ -1390,6 +1445,7 @@ int ath5k_hw_tx_start(struct ath5k_hw *ah, unsigned int queue)
 		}
 		/* Start queue */
 		ath5k_hw_reg_write(ah, tx_queue, AR5K_CR);
+		ath5k_hw_reg_read(ah, AR5K_CR);
 	} else {
 		/* Return if queue is disabled */
 		if (AR5K_REG_READ_Q(ah, AR5K_QCU_TXD, queue))
@@ -1687,6 +1743,7 @@ enum ath5k_int ath5k_hw_set_intr(struct ath5k_hw *ah, enum ath5k_int new_mask)
 	 * (they will be re-enabled afterwards).
 	 */
 	ath5k_hw_reg_write(ah, AR5K_IER_DISABLE, AR5K_IER);
+	ath5k_hw_reg_read(ah, AR5K_IER);
 
 	old_mask = ah->ah_imr;
 
@@ -3363,11 +3420,13 @@ int ath5k_hw_reset_tx_queue(struct ath5k_hw *ah, unsigned int queue)
 		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			AR5K_INIT_PROTO_TIME_CNTRL_TURBO :
 			AR5K_INIT_PROTO_TIME_CNTRL, AR5K_IFS1);
-		/* Set PHY register 0x9844 (??) */
+		/* Set AR5K_PHY_SETTLING */
 		ath5k_hw_reg_write(ah, ah->ah_turbo ?
-			(ath5k_hw_reg_read(ah, AR5K_PHY(17)) & ~0x7F) | 0x38 :
-			(ath5k_hw_reg_read(ah, AR5K_PHY(17)) & ~0x7F) | 0x1C,
-			AR5K_PHY(17));
+			(ath5k_hw_reg_read(ah, AR5K_PHY_SETTLING) & ~0x7F)
+			| 0x38 :
+			(ath5k_hw_reg_read(ah, AR5K_PHY_SETTLING) & ~0x7F)
+			| 0x1C,
+			AR5K_PHY_SETTLING);
 		/* Set Frame Control Register */
 		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			(AR5K_PHY_FRAME_CTL_INI | AR5K_PHY_TURBO_MODE |
@@ -3488,7 +3547,7 @@ int ath5k_hw_reset_tx_queue(struct ath5k_hw *ah, unsigned int queue)
 			if (tq->tqi_flags & AR5K_TXQ_FLAG_RDYTIME_EXP_POLICY_ENABLE)
 				AR5K_REG_ENABLE_BITS(ah,
 					AR5K_QUEUE_MISC(queue),
-					AR5K_QCU_MISC_TXE);
+					AR5K_QCU_MISC_RDY_VEOL_POLICY);
 		}
 
 		if (tq->tqi_flags & AR5K_TXQ_FLAG_BACKOFF_DISABLE)
diff --git a/drivers/net/wireless/ath5k/initvals.c b/drivers/net/wireless/ath5k/initvals.c
index 04c84e9..2806b21 100644
--- a/drivers/net/wireless/ath5k/initvals.c
+++ b/drivers/net/wireless/ath5k/initvals.c
@@ -489,7 +489,7 @@ static const struct ath5k_ini ar5212_ini[] = {
 	{ AR5K_QUEUE_TXDP(9),	0x00000000 },
 	{ AR5K_DCU_FP,		0x00000000 },
 	{ AR5K_DCU_TXP,		0x00000000 },
-	{ AR5K_DCU_TX_FILTER,	0x00000000 },
+	{ AR5K_DCU_TX_FILTER_0_BASE,	0x00000000 },
 	/* Unknown table */
 	{ 0x1078, 0x00000000 },
 	{ 0x10b8, 0x00000000 },
@@ -679,7 +679,7 @@ static const struct ath5k_ini ar5212_ini[] = {
 	{ AR5K_PHY(645), 0x00106c10 },
 	{ AR5K_PHY(646), 0x009c4060 },
 	{ AR5K_PHY(647), 0x1483800a },
-	/* { AR5K_PHY(648), 0x018830c6 },*/ /* 2413 */
+	/* { AR5K_PHY(648), 0x018830c6 },*/ /* 2413/2425 */
 	{ AR5K_PHY(648), 0x01831061 },
 	{ AR5K_PHY(649), 0x00000400 },
 	/*{ AR5K_PHY(650), 0x000001b5 },*/
diff --git a/drivers/net/wireless/ath5k/phy.c b/drivers/net/wireless/ath5k/phy.c
index afd8689..fa0d47f 100644
--- a/drivers/net/wireless/ath5k/phy.c
+++ b/drivers/net/wireless/ath5k/phy.c
@@ -1020,6 +1020,74 @@ static const struct ath5k_ini_rfgain rfgain_2413[] = {
 	{ AR5K_RF_GAIN(63), { 0x000000f9 } },
 };
 
+/* Initial RF Gain settings for RF2425 */
+static const struct ath5k_ini_rfgain rfgain_2425[] = {
+	{ AR5K_RF_GAIN(0), { 0x00000000 } },
+	{ AR5K_RF_GAIN(1), { 0x00000040 } },
+	{ AR5K_RF_GAIN(2), { 0x00000080 } },
+	{ AR5K_RF_GAIN(3), { 0x00000181 } },
+	{ AR5K_RF_GAIN(4), { 0x000001c1 } },
+	{ AR5K_RF_GAIN(5), { 0x00000001 } },
+	{ AR5K_RF_GAIN(6), { 0x00000041 } },
+	{ AR5K_RF_GAIN(7), { 0x00000081 } },
+	{ AR5K_RF_GAIN(8), { 0x00000188 } },
+	{ AR5K_RF_GAIN(9), { 0x000001c8 } },
+	{ AR5K_RF_GAIN(10), { 0x00000008 } },
+	{ AR5K_RF_GAIN(11), { 0x00000048 } },
+	{ AR5K_RF_GAIN(12), { 0x00000088 } },
+	{ AR5K_RF_GAIN(13), { 0x00000189 } },
+	{ AR5K_RF_GAIN(14), { 0x000001c9 } },
+	{ AR5K_RF_GAIN(15), { 0x00000009 } },
+	{ AR5K_RF_GAIN(16), { 0x00000049 } },
+	{ AR5K_RF_GAIN(17), { 0x00000089 } },
+	{ AR5K_RF_GAIN(18), { 0x000001b0 } },
+	{ AR5K_RF_GAIN(19), { 0x000001f0 } },
+	{ AR5K_RF_GAIN(20), { 0x00000030 } },
+	{ AR5K_RF_GAIN(21), { 0x00000070 } },
+	{ AR5K_RF_GAIN(22), { 0x00000171 } },
+	{ AR5K_RF_GAIN(23), { 0x000001b1 } },
+	{ AR5K_RF_GAIN(24), { 0x000001f1 } },
+	{ AR5K_RF_GAIN(25), { 0x00000031 } },
+	{ AR5K_RF_GAIN(26), { 0x00000071 } },
+	{ AR5K_RF_GAIN(27), { 0x000001b8 } },
+	{ AR5K_RF_GAIN(28), { 0x000001f8 } },
+	{ AR5K_RF_GAIN(29), { 0x00000038 } },
+	{ AR5K_RF_GAIN(30), { 0x00000078 } },
+	{ AR5K_RF_GAIN(31), { 0x000000b8 } },
+	{ AR5K_RF_GAIN(32), { 0x000001b9 } },
+	{ AR5K_RF_GAIN(33), { 0x000001f9 } },
+	{ AR5K_RF_GAIN(34), { 0x00000039 } },
+	{ AR5K_RF_GAIN(35), { 0x00000079 } },
+	{ AR5K_RF_GAIN(36), { 0x000000b9 } },
+	{ AR5K_RF_GAIN(37), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(38), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(39), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(40), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(41), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(42), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(43), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(44), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(45), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(46), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(47), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(48), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(49), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(50), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(51), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(52), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(53), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(54), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(55), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(56), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(57), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(58), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(59), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(60), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(61), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(62), { 0x000000f9 } },
+	{ AR5K_RF_GAIN(63), { 0x000000f9 } },
+};
+
 static const struct ath5k_gain_opt rfgain_opt_5112 = {
 	1,
 	8,
@@ -1588,8 +1656,8 @@ int ath5k_hw_rfgain(struct ath5k_hw *ah, unsigned int freq)
 		freq = 0; /* only 2Ghz */
 		break;
 	case AR5K_RF2425:
-		ath5k_rfg = rfgain_2413;
-		size = ARRAY_SIZE(rfgain_2413);
+		ath5k_rfg = rfgain_2425;
+		size = ARRAY_SIZE(rfgain_2425);
 		freq = 0; /* only 2Ghz */
 		break;
 	default:
@@ -1830,9 +1898,6 @@ static int ath5k_hw_rf5112_channel(struct ath5k_hw *ah,
 	data = data0 = data1 = data2 = 0;
 	c = channel->center_freq;
 
-	/*
-	 * Set the channel on the RF5112 or newer
-	 */
 	if (c < 4800) {
 		if (!((c - 2224) % 5)) {
 			data0 = ((2 * (c - 704)) - 3040) / 10;
@@ -1844,7 +1909,7 @@ static int ath5k_hw_rf5112_channel(struct ath5k_hw *ah,
 			return -EINVAL;
 
 		data0 = ath5k_hw_bitswap((data0 << 2) & 0xff, 8);
-	} else {
+	} else if ((c - (c % 5)) != 2 || c > 5435) {
 		if (!(c % 20) && c >= 5120) {
 			data0 = ath5k_hw_bitswap(((c - 4800) / 20 << 2), 8);
 			data2 = ath5k_hw_bitswap(3, 2);
@@ -1856,6 +1921,9 @@ static int ath5k_hw_rf5112_channel(struct ath5k_hw *ah,
 			data2 = ath5k_hw_bitswap(1, 2);
 		} else
 			return -EINVAL;
+	} else {
+		data0 = ath5k_hw_bitswap((10 * (c - 2) - 4800) / 25 + 1, 8);
+		data2 = ath5k_hw_bitswap(0, 2);
 	}
 
 	data = (data0 << 4) | (data1 << 1) | (data2 << 2) | 0x1001;
@@ -1867,6 +1935,45 @@ static int ath5k_hw_rf5112_channel(struct ath5k_hw *ah,
 }
 
 /*
+ * Set the channel on the RF2425
+ */
+static int ath5k_hw_rf2425_channel(struct ath5k_hw *ah,
+		struct ieee80211_channel *channel)
+{
+	u32 data, data0, data2;
+	u16 c;
+
+	data = data0 = data2 = 0;
+	c = channel->center_freq;
+
+	if (c < 4800) {
+		data0 = ath5k_hw_bitswap((c - 2272), 8);
+		data2 = 0;
+	/* ? 5GHz ? */
+	} else if ((c - (c % 5)) != 2 || c > 5435) {
+		if (!(c % 20) && c < 5120)
+			data0 = ath5k_hw_bitswap(((c - 4800) / 20 << 2), 8);
+		else if (!(c % 10))
+			data0 = ath5k_hw_bitswap(((c - 4800) / 10 << 1), 8);
+		else if (!(c % 5))
+			data0 = ath5k_hw_bitswap((c - 4800) / 5, 8);
+		else
+			return -EINVAL;
+		data2 = ath5k_hw_bitswap(1, 2);
+	} else {
+		data0 = ath5k_hw_bitswap((10 * (c - 2) - 4800) / 25 + 1, 8);
+		data2 = ath5k_hw_bitswap(0, 2);
+	}
+
+	data = (data0 << 4) | data2 << 2 | 0x1001;
+
+	ath5k_hw_reg_write(ah, data & 0xff, AR5K_RF_BUFFER);
+	ath5k_hw_reg_write(ah, (data >> 8) & 0x7f, AR5K_RF_BUFFER_CONTROL_5);
+
+	return 0;
+}
+
+/*
  * Set a channel on the radio chip
  */
 int ath5k_hw_channel(struct ath5k_hw *ah, struct ieee80211_channel *channel)
@@ -1895,6 +2002,9 @@ int ath5k_hw_channel(struct ath5k_hw *ah, struct ieee80211_channel *channel)
 	case AR5K_RF5111:
 		ret = ath5k_hw_rf5111_channel(ah, channel);
 		break;
+	case AR5K_RF2425:
+		ret = ath5k_hw_rf2425_channel(ah, channel);
+		break;
 	default:
 		ret = ath5k_hw_rf5112_channel(ah, channel);
 		break;
@@ -1903,6 +2013,15 @@ int ath5k_hw_channel(struct ath5k_hw *ah, struct ieee80211_channel *channel)
 	if (ret)
 		return ret;
 
+	/* Set JAPAN setting for channel 14 */
+	if (channel->center_freq == 2484) {
+		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_CCKTXCTL,
+				AR5K_PHY_CCKTXCTL_JAPAN);
+	} else {
+		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_CCKTXCTL,
+				AR5K_PHY_CCKTXCTL_WORLD);
+	}
+
 	ah->ah_current_channel.center_freq = channel->center_freq;
 	ah->ah_current_channel.hw_value = channel->hw_value;
 	ah->ah_turbo = channel->hw_value == CHANNEL_T ? true : false;
@@ -1933,6 +2052,8 @@ int ath5k_hw_channel(struct ath5k_hw *ah, struct ieee80211_channel *channel)
  * http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL \
  * &p=1&u=%2Fnetahtml%2FPTO%2Fsrchnum.htm&r=1&f=G&l=50&s1=7245893.PN.&OS=PN/7
  *
+ * XXX: Since during noise floor calibration antennas are detached according to
+ * the patent, we should stop tx queues here.
  */
 int
 ath5k_hw_noise_floor_calibration(struct ath5k_hw *ah, short freq)
@@ -1942,7 +2063,7 @@ ath5k_hw_noise_floor_calibration(struct ath5k_hw *ah, short freq)
 	s32 noise_floor;
 
 	/*
-	 * Enable noise floor calibration and wait until completion
+	 * Enable noise floor calibration
 	 */
 	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_AGCCTL,
 				AR5K_PHY_AGCCTL_NF);
@@ -1952,7 +2073,7 @@ ath5k_hw_noise_floor_calibration(struct ath5k_hw *ah, short freq)
 	if (ret) {
 		ATH5K_ERR(ah->ah_sc,
 			"noise floor calibration timeout (%uMHz)\n", freq);
-		return ret;
+		return -EAGAIN;
 	}
 
 	/* Wait until the noise floor is calibrated and read the value */
@@ -1974,7 +2095,7 @@ ath5k_hw_noise_floor_calibration(struct ath5k_hw *ah, short freq)
 	if (noise_floor > AR5K_TUNE_NOISE_FLOOR) {
 		ATH5K_ERR(ah->ah_sc,
 			"noise floor calibration failed (%uMHz)\n", freq);
-		return -EIO;
+		return -EAGAIN;
 	}
 
 	ah->ah_noise_floor = noise_floor;
@@ -2087,38 +2208,66 @@ static int ath5k_hw_rf5110_calibrate(struct ath5k_hw *ah,
 }
 
 /*
- * Perform a PHY calibration on RF5111/5112
+ * Perform a PHY calibration on RF5111/5112 and newer chips
  */
 static int ath5k_hw_rf511x_calibrate(struct ath5k_hw *ah,
 		struct ieee80211_channel *channel)
 {
 	u32 i_pwr, q_pwr;
 	s32 iq_corr, i_coff, i_coffd, q_coff, q_coffd;
+	int i;
 	ATH5K_TRACE(ah->ah_sc);
 
 	if (!ah->ah_calibration ||
-			ath5k_hw_reg_read(ah, AR5K_PHY_IQ) & AR5K_PHY_IQ_RUN)
+		ath5k_hw_reg_read(ah, AR5K_PHY_IQ) & AR5K_PHY_IQ_RUN)
 		goto done;
 
-	ah->ah_calibration = false;
+	/* Calibration has finished, get the results and re-run */
+	for (i = 0; i <= 10; i++) {
+		iq_corr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_CORR);
+		i_pwr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_PWR_I);
+		q_pwr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_PWR_Q);
+	}
 
-	iq_corr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_CORR);
-	i_pwr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_PWR_I);
-	q_pwr = ath5k_hw_reg_read(ah, AR5K_PHY_IQRES_CAL_PWR_Q);
 	i_coffd = ((i_pwr >> 1) + (q_pwr >> 1)) >> 7;
-	q_coffd = q_pwr >> 6;
+	q_coffd = q_pwr >> 7;
 
+	/* No correction */
 	if (i_coffd == 0 || q_coffd == 0)
 		goto done;
 
 	i_coff = ((-iq_corr) / i_coffd) & 0x3f;
-	q_coff = (((s32)i_pwr / q_coffd) - 64) & 0x1f;
 
-	/* Commit new IQ value */
+	/* Boundary check */
+	if (i_coff > 31)
+		i_coff = 31;
+	if (i_coff < -32)
+		i_coff = -32;
+
+	q_coff = (((s32)i_pwr / q_coffd) - 128) & 0x1f;
+
+	/* Boundary check */
+	if (q_coff > 15)
+		q_coff = 15;
+	if (q_coff < -16)
+		q_coff = -16;
+
+	/* Commit new I/Q value */
 	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_CORR_ENABLE |
 		((u32)q_coff) | ((u32)i_coff << AR5K_PHY_IQ_CORR_Q_I_COFF_S));
 
+	/* Re-enable calibration -if we don't we'll commit
+	 * the same values again and again */
+	AR5K_REG_WRITE_BITS(ah, AR5K_PHY_IQ,
+			AR5K_PHY_IQ_CAL_NUM_LOG_MAX, 15);
+	AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_IQ, AR5K_PHY_IQ_RUN);
+
 done:
+
+	/* TODO: Separate noise floor calibration from I/Q calibration
+	 * since noise floor calibration interrupts rx path while I/Q
+	 * calibration doesn't. We don't need to run noise floor calibration
+	 * as often as I/Q calibration.*/
 	ath5k_hw_noise_floor_calibration(ah, channel->center_freq);
 
 	/* Request RF gain */
diff --git a/drivers/net/wireless/ath5k/reg.h b/drivers/net/wireless/ath5k/reg.h
index 30629b3..7562bf1 100644
--- a/drivers/net/wireless/ath5k/reg.h
+++ b/drivers/net/wireless/ath5k/reg.h
@@ -53,7 +53,7 @@
 #define AR5K_CR_TXD0	0x00000008	/* TX Disable for queue 0 on 5210 */
 #define AR5K_CR_TXD1	0x00000010	/* TX Disable for queue 1 on 5210 */
 #define	AR5K_CR_RXD	0x00000020	/* RX Disable */
-#define	AR5K_CR_SWI	0x00000040
+#define	AR5K_CR_SWI	0x00000040	/* Software Interrupt */
 
 /*
  * RX Descriptor Pointer register
@@ -65,19 +65,19 @@
  */
 #define	AR5K_CFG		0x0014			/* Register Address */
 #define	AR5K_CFG_SWTD		0x00000001	/* Byte-swap TX descriptor (for big endian archs) */
-#define	AR5K_CFG_SWTB		0x00000002	/* Byte-swap TX buffer (?) */
+#define	AR5K_CFG_SWTB		0x00000002	/* Byte-swap TX buffer */
 #define	AR5K_CFG_SWRD		0x00000004	/* Byte-swap RX descriptor */
-#define	AR5K_CFG_SWRB		0x00000008	/* Byte-swap RX buffer (?) */
-#define	AR5K_CFG_SWRG		0x00000010	/* Byte-swap Register values (?) */
-#define AR5K_CFG_ADHOC		0x00000020 	/* [5211+] */
+#define	AR5K_CFG_SWRB		0x00000008	/* Byte-swap RX buffer */
+#define	AR5K_CFG_SWRG		0x00000010	/* Byte-swap Register access */
+#define AR5K_CFG_ADHOC		0x00000020 	/* AP/Adhoc indication [5211+] */
 #define AR5K_CFG_PHY_OK		0x00000100	/* [5211+] */
 #define AR5K_CFG_EEBS		0x00000200	/* EEPROM is busy */
-#define	AR5K_CFG_CLKGD		0x00000400	/* Clock gated (?) */
+#define	AR5K_CFG_CLKGD		0x00000400	/* Clock gated (Disable dynamic clock) */
 #define AR5K_CFG_TXCNT		0x00007800	/* Tx frame count (?) [5210] */
 #define AR5K_CFG_TXCNT_S	11
 #define AR5K_CFG_TXFSTAT	0x00008000	/* Tx frame status (?) [5210] */
 #define AR5K_CFG_TXFSTRT	0x00010000	/* [5210] */
-#define	AR5K_CFG_PCI_THRES	0x00060000	/* [5211+] */
+#define	AR5K_CFG_PCI_THRES	0x00060000	/* PCI Master req q threshold [5211+] */
 #define	AR5K_CFG_PCI_THRES_S	17
 
 /*
@@ -162,35 +162,40 @@
 /*
  * Transmit configuration register
  */
-#define AR5K_TXCFG		0x0030			/* Register Address */
-#define AR5K_TXCFG_SDMAMR	0x00000007	/* DMA size */
-#define AR5K_TXCFG_SDMAMR_S	0
-#define AR5K_TXCFG_B_MODE	0x00000008	/* Set b mode for 5111 (enable 2111) */
-#define AR5K_TXCFG_TXFSTP	0x00000008	/* TX DMA full Stop [5210] */
-#define AR5K_TXCFG_TXFULL	0x000003f0	/* TX Triger level mask */
-#define AR5K_TXCFG_TXFULL_S	4
-#define AR5K_TXCFG_TXFULL_0B	0x00000000
-#define AR5K_TXCFG_TXFULL_64B	0x00000010
-#define AR5K_TXCFG_TXFULL_128B	0x00000020
-#define AR5K_TXCFG_TXFULL_192B	0x00000030
-#define AR5K_TXCFG_TXFULL_256B	0x00000040
-#define AR5K_TXCFG_TXCONT_EN	0x00000080
-#define AR5K_TXCFG_DMASIZE	0x00000100	/* Flag for passing DMA size [5210] */
-#define AR5K_TXCFG_JUMBO_TXE	0x00000400	/* Enable jumbo frames transmition (?) [5211+] */
-#define AR5K_TXCFG_RTSRND	0x00001000	/* [5211+] */
-#define AR5K_TXCFG_FRMPAD_DIS	0x00002000	/* [5211+] */
-#define AR5K_TXCFG_RDY_DIS	0x00004000	/* [5211+] */
+#define AR5K_TXCFG			0x0030			/* Register Address */
+#define AR5K_TXCFG_SDMAMR		0x00000007	/* DMA size (read) */
+#define AR5K_TXCFG_SDMAMR_S		0
+#define AR5K_TXCFG_B_MODE		0x00000008	/* Set b mode for 5111 (enable 2111) */
+#define AR5K_TXCFG_TXFSTP		0x00000008	/* TX DMA full Stop [5210] */
+#define AR5K_TXCFG_TXFULL		0x000003f0	/* TX Triger level mask */
+#define AR5K_TXCFG_TXFULL_S		4
+#define AR5K_TXCFG_TXFULL_0B		0x00000000
+#define AR5K_TXCFG_TXFULL_64B		0x00000010
+#define AR5K_TXCFG_TXFULL_128B		0x00000020
+#define AR5K_TXCFG_TXFULL_192B		0x00000030
+#define AR5K_TXCFG_TXFULL_256B		0x00000040
+#define AR5K_TXCFG_TXCONT_EN		0x00000080
+#define AR5K_TXCFG_DMASIZE		0x00000100	/* Flag for passing DMA size [5210] */
+#define AR5K_TXCFG_JUMBO_DESC_EN	0x00000400	/* Enable jumbo tx descriptors [5211+] */
+#define AR5K_TXCFG_ADHOC_BCN_ATIM	0x00000800	/* Adhoc Beacon ATIM Policy */
+#define AR5K_TXCFG_ATIM_WINDOW_DEF_DIS	0x00001000	/* Disable ATIM window defer [5211+] */
+#define AR5K_TXCFG_RTSRND		0x00001000	/* [5211+] */
+#define AR5K_TXCFG_FRMPAD_DIS		0x00002000	/* [5211+] */
+#define AR5K_TXCFG_RDY_CBR_DIS		0x00004000	/* Ready time CBR disable [5211+] */
+#define AR5K_TXCFG_JUMBO_FRM_MODE	0x00008000	/* Jumbo frame mode [5211+] */
+#define AR5K_TXCFG_DCU_CACHING_DIS	0x00010000	/* Disable DCU caching */
 
 /*
  * Receive configuration register
  */
 #define AR5K_RXCFG		0x0034			/* Register Address */
-#define AR5K_RXCFG_SDMAMW	0x00000007	/* DMA size */
+#define AR5K_RXCFG_SDMAMW	0x00000007	/* DMA size (write) */
 #define AR5K_RXCFG_SDMAMW_S	0
-#define	AR5K_RXCFG_DEF_ANTENNA	0x00000008	/* Default antenna */
-#define AR5K_RXCFG_ZLFDMA	0x00000010	/* Zero-length DMA */
-#define AR5K_RXCFG_JUMBO_RXE	0x00000020	/* Enable jumbo frames reception (?) [5211+] */
-#define AR5K_RXCFG_JUMBO_WRAP	0x00000040	/* Wrap jumbo frames (?) [5211+] */
+#define AR5K_RXCFG_ZLFDMA	0x00000008	/* Enable Zero-length frame DMA */
+#define	AR5K_RXCFG_DEF_ANTENNA	0x00000010	/* Default antenna (?) */
+#define AR5K_RXCFG_JUMBO_RXE	0x00000020	/* Enable jumbo rx descriptors [5211+] */
+#define AR5K_RXCFG_JUMBO_WRAP	0x00000040	/* Wrap jumbo frames [5211+] */
+#define AR5K_RXCFG_SLE_ENTRY	0x00000080	/* Sleep entry policy */
 
 /*
  * Receive jumbo descriptor last address register
@@ -202,35 +207,35 @@
  * MIB control register
  */
 #define AR5K_MIBC		0x0040			/* Register Address */
-#define AR5K_MIBC_COW		0x00000001
-#define AR5K_MIBC_FMC		0x00000002	/* Freeze Mib Counters (?) */
-#define AR5K_MIBC_CMC		0x00000004	/* Clean Mib Counters (?) */
-#define AR5K_MIBC_MCS		0x00000008
+#define AR5K_MIBC_COW		0x00000001	/* Warn test indicator */
+#define AR5K_MIBC_FMC		0x00000002	/* Freeze MIB Counters  */
+#define AR5K_MIBC_CMC		0x00000004	/* Clean MIB Counters  */
+#define AR5K_MIBC_MCS		0x00000008	/* MIB counter strobe */
 
 /*
  * Timeout prescale register
  */
 #define AR5K_TOPS		0x0044
-#define	AR5K_TOPS_M		0x0000ffff	/* [5211+] (?) */
+#define	AR5K_TOPS_M		0x0000ffff
 
 /*
  * Receive timeout register (no frame received)
  */
 #define AR5K_RXNOFRM		0x0048
-#define	AR5K_RXNOFRM_M		0x000003ff	/* [5211+] (?) */
+#define	AR5K_RXNOFRM_M		0x000003ff
 
 /*
  * Transmit timeout register (no frame sent)
  */
 #define AR5K_TXNOFRM		0x004c
-#define	AR5K_TXNOFRM_M		0x000003ff	/* [5211+] (?) */
-#define	AR5K_TXNOFRM_QCU	0x000ffc00	/* [5211+] (?) */
+#define	AR5K_TXNOFRM_M		0x000003ff
+#define	AR5K_TXNOFRM_QCU	0x000ffc00
 
 /*
  * Receive frame gap timeout register
  */
 #define AR5K_RPGTO		0x0050
-#define AR5K_RPGTO_M		0x000003ff	/* [5211+] (?) */
+#define AR5K_RPGTO_M		0x000003ff
 
 /*
  * Receive frame count limit register
@@ -241,6 +246,7 @@
 
 /*
  * Misc settings register
+ * (reserved0-3)
  */
 #define AR5K_MISC		0x0058			/* Register Address */
 #define	AR5K_MISC_DMA_OBS_M	0x000001e0
@@ -256,6 +262,7 @@
 
 /*
  * QCU/DCU clock gating register (5311)
+ * (reserved4-5)
  */
 #define	AR5K_QCUDCU_CLKGT	0x005c			/* Register Address (?) */
 #define	AR5K_QCUDCU_CLKGT_QCU	0x0000ffff	/* Mask for QCU clock */
@@ -284,18 +291,18 @@
 #define AR5K_ISR_TXEOL		0x00000400	/* Empty TX descriptor */
 #define AR5K_ISR_TXURN		0x00000800	/* Transmit FIFO underrun */
 #define AR5K_ISR_MIB		0x00001000	/* Update MIB counters */
-#define AR5K_ISR_SWI		0x00002000	/* Software interrupt (?) */
+#define AR5K_ISR_SWI		0x00002000	/* Software interrupt */
 #define AR5K_ISR_RXPHY		0x00004000	/* PHY error */
-#define AR5K_ISR_RXKCM		0x00008000
+#define AR5K_ISR_RXKCM		0x00008000	/* RX Key cache miss */
 #define AR5K_ISR_SWBA		0x00010000	/* Software beacon alert */
 #define AR5K_ISR_BRSSI		0x00020000
 #define AR5K_ISR_BMISS		0x00040000	/* Beacon missed */
 #define AR5K_ISR_HIUERR		0x00080000	/* Host Interface Unit error [5211+] */
 #define AR5K_ISR_BNR		0x00100000 	/* Beacon not ready [5211+] */
-#define AR5K_ISR_MCABT		0x00100000	/* [5210] */
-#define AR5K_ISR_RXCHIRP	0x00200000	/* [5212+] */
-#define AR5K_ISR_SSERR		0x00200000	/* [5210] */
-#define AR5K_ISR_DPERR		0x00400000	/* [5210] */
+#define AR5K_ISR_MCABT		0x00100000	/* Master Cycle Abort [5210] */
+#define AR5K_ISR_RXCHIRP	0x00200000	/* CHIRP Received [5212+] */
+#define AR5K_ISR_SSERR		0x00200000	/* Signaled System Error [5210] */
+#define AR5K_ISR_DPERR		0x00400000	/* Det par Error (?) [5210] */
 #define AR5K_ISR_TIM		0x00800000	/* [5210] */
 #define AR5K_ISR_BCNMISC	0x00800000	/* [5212+] */
 #define AR5K_ISR_GPIO		0x01000000	/* GPIO (rf kill)*/
@@ -320,14 +327,14 @@
 
 #define AR5K_SISR2		0x008c			/* Register Address [5211+] */
 #define AR5K_SISR2_QCU_TXURN	0x000003ff	/* Mask for QCU_TXURN */
-#define	AR5K_SISR2_MCABT	0x00100000
-#define	AR5K_SISR2_SSERR	0x00200000
-#define	AR5K_SISR2_DPERR	0x00400000
+#define	AR5K_SISR2_MCABT	0x00100000	/* Master Cycle Abort */
+#define	AR5K_SISR2_SSERR	0x00200000	/* Signaled System Error */
+#define	AR5K_SISR2_DPERR	0x00400000	/* Det par Error (?) */
 #define	AR5K_SISR2_TIM		0x01000000	/* [5212+] */
 #define	AR5K_SISR2_CAB_END	0x02000000	/* [5212+] */
-#define	AR5K_SISR2_DTIM_SYNC	0x04000000	/* [5212+] */
-#define	AR5K_SISR2_BCN_TIMEOUT	0x08000000	/* [5212+] */
-#define	AR5K_SISR2_CAB_TIMEOUT	0x10000000	/* [5212+] */
+#define	AR5K_SISR2_DTIM_SYNC	0x04000000	/* DTIM sync lost [5212+] */
+#define	AR5K_SISR2_BCN_TIMEOUT	0x08000000	/* Beacon Timeout [5212+] */
+#define	AR5K_SISR2_CAB_TIMEOUT	0x10000000	/* CAB Timeout [5212+] */
 #define	AR5K_SISR2_DTIM		0x20000000	/* [5212+] */
 
 #define AR5K_SISR3		0x0090			/* Register Address [5211+] */
@@ -368,18 +375,18 @@
 #define AR5K_IMR_TXEOL		0x00000400	/* Empty TX descriptor*/
 #define AR5K_IMR_TXURN		0x00000800	/* Transmit FIFO underrun*/
 #define AR5K_IMR_MIB		0x00001000	/* Update MIB counters*/
-#define AR5K_IMR_SWI		0x00002000
+#define AR5K_IMR_SWI		0x00002000	/* Software interrupt */
 #define AR5K_IMR_RXPHY		0x00004000	/* PHY error*/
-#define AR5K_IMR_RXKCM		0x00008000
+#define AR5K_IMR_RXKCM		0x00008000	/* RX Key cache miss */
 #define AR5K_IMR_SWBA		0x00010000	/* Software beacon alert*/
 #define AR5K_IMR_BRSSI		0x00020000
 #define AR5K_IMR_BMISS		0x00040000	/* Beacon missed*/
 #define AR5K_IMR_HIUERR		0x00080000	/* Host Interface Unit error [5211+] */
 #define AR5K_IMR_BNR		0x00100000 	/* Beacon not ready [5211+] */
-#define AR5K_IMR_MCABT		0x00100000	/* [5210] */
-#define AR5K_IMR_RXCHIRP	0x00200000	/* [5212+]*/
-#define AR5K_IMR_SSERR		0x00200000	/* [5210] */
-#define AR5K_IMR_DPERR		0x00400000	/* [5210] */
+#define AR5K_IMR_MCABT		0x00100000	/* Master Cycle Abort [5210] */
+#define AR5K_IMR_RXCHIRP	0x00200000	/* CHIRP Received [5212+]*/
+#define AR5K_IMR_SSERR		0x00200000	/* Signaled System Error [5210] */
+#define AR5K_IMR_DPERR		0x00400000	/* Det par Error (?) [5210] */
 #define AR5K_IMR_TIM		0x00800000	/* [5211+] */
 #define AR5K_IMR_BCNMISC	0x00800000	/* [5212+] */
 #define AR5K_IMR_GPIO		0x01000000	/* GPIO (rf kill)*/
@@ -405,14 +412,14 @@
 #define AR5K_SIMR2		0x00ac			/* Register Address [5211+] */
 #define AR5K_SIMR2_QCU_TXURN	0x000003ff	/* Mask for QCU_TXURN */
 #define AR5K_SIMR2_QCU_TXURN_S	0
-#define	AR5K_SIMR2_MCABT	0x00100000
-#define	AR5K_SIMR2_SSERR	0x00200000
-#define	AR5K_SIMR2_DPERR	0x00400000
+#define	AR5K_SIMR2_MCABT	0x00100000	/* Master Cycle Abort */
+#define	AR5K_SIMR2_SSERR	0x00200000	/* Signaled System Error */
+#define	AR5K_SIMR2_DPERR	0x00400000	/* Det par Error (?) */
 #define	AR5K_SIMR2_TIM		0x01000000	/* [5212+] */
 #define	AR5K_SIMR2_CAB_END	0x02000000	/* [5212+] */
-#define	AR5K_SIMR2_DTIM_SYNC	0x04000000	/* [5212+] */
-#define	AR5K_SIMR2_BCN_TIMEOUT	0x08000000	/* [5212+] */
-#define	AR5K_SIMR2_CAB_TIMEOUT	0x10000000	/* [5212+] */
+#define	AR5K_SIMR2_DTIM_SYNC	0x04000000	/* DTIM Sync lost [5212+] */
+#define	AR5K_SIMR2_BCN_TIMEOUT	0x08000000	/* Beacon Timeout [5212+] */
+#define	AR5K_SIMR2_CAB_TIMEOUT	0x10000000	/* CAB Timeout [5212+] */
 #define	AR5K_SIMR2_DTIM		0x20000000	/* [5212+] */
 
 #define AR5K_SIMR3		0x00b0			/* Register Address [5211+] */
@@ -425,23 +432,69 @@
 #define AR5K_SIMR4_QTRIG	0x000003ff	/* Mask for QTRIG */
 #define AR5K_SIMR4_QTRIG_S	0
 
+/*
+ * DMA Debug registers 0-7
+ * 0xe0 - 0xfc
+ */
 
 /*
  * Decompression mask registers [5212+]
  */
-#define AR5K_DCM_ADDR		0x0400		/*Decompression mask address (?)*/
-#define AR5K_DCM_DATA		0x0404		/*Decompression mask data (?)*/
+#define AR5K_DCM_ADDR		0x0400		/*Decompression mask address (index) */
+#define AR5K_DCM_DATA		0x0404		/*Decompression mask data */
+
+/*
+ * Wake On Wireless pattern control register [5212+]
+ */
+#define	AR5K_WOW_PCFG			0x0410			/* Register Address */
+#define	AR5K_WOW_PCFG_PAT_MATCH_EN	0x00000001	/* Pattern match enable */
+#define	AR5K_WOW_PCFG_LONG_FRAME_POL	0x00000002	/* Long frame policy */
+#define	AR5K_WOW_PCFG_WOBMISS		0x00000004	/* Wake on bea(con) miss (?) */
+#define	AR5K_WOW_PCFG_PAT_0_EN		0x00000100	/* Enable pattern 0 */
+#define	AR5K_WOW_PCFG_PAT_1_EN		0x00000200	/* Enable pattern 1 */
+#define	AR5K_WOW_PCFG_PAT_2_EN		0x00000400	/* Enable pattern 2 */
+#define	AR5K_WOW_PCFG_PAT_3_EN		0x00000800	/* Enable pattern 3 */
+#define	AR5K_WOW_PCFG_PAT_4_EN		0x00001000	/* Enable pattern 4 */
+#define	AR5K_WOW_PCFG_PAT_5_EN		0x00002000	/* Enable pattern 5 */
+
+/*
+ * Wake On Wireless pattern index register (?) [5212+]
+ */
+#define	AR5K_WOW_PAT_IDX	0x0414
+
+/*
+ * Wake On Wireless pattern data register [5212+]
+ */
+#define	AR5K_WOW_PAT_DATA	0x0418			/* Register Address */
+#define	AR5K_WOW_PAT_DATA_0_3_V	0x00000001	/* Pattern 0, 3 value */
+#define	AR5K_WOW_PAT_DATA_1_4_V	0x00000100	/* Pattern 1, 4 value */
+#define	AR5K_WOW_PAT_DATA_2_5_V	0x00010000	/* Pattern 2, 5 value */
+#define	AR5K_WOW_PAT_DATA_0_3_M	0x01000000	/* Pattern 0, 3 mask */
+#define	AR5K_WOW_PAT_DATA_1_4_M	0x04000000	/* Pattern 1, 4 mask */
+#define	AR5K_WOW_PAT_DATA_2_5_M	0x10000000	/* Pattern 2, 5 mask */
 
 /*
  * Decompression configuration registers [5212+]
  */
-#define AR5K_DCCFG		0x0420
+#define AR5K_DCCFG		0x0420			/* Register Address */
+#define AR5K_DCCFG_GLOBAL_EN	0x00000001	/* Enable decompression on all queues */
+#define AR5K_DCCFG_BYPASS_EN	0x00000002	/* Bypass decompression */
+#define AR5K_DCCFG_BCAST_EN	0x00000004	/* Enable decompression for bcast frames */
+#define AR5K_DCCFG_MCAST_EN	0x00000008	/* Enable decompression for mcast frames */
 
 /*
  * Compression configuration registers [5212+]
  */
-#define AR5K_CCFG		0x0600
-#define AR5K_CCFG_CUP		0x0604
+#define AR5K_CCFG		0x0600			/* Register Address */
+#define	AR5K_CCFG_WINDOW_SIZE	0x00000007	/* Compression window size */
+#define	AR5K_CCFG_CPC_EN	0x00000008	/* Enable performance counters */
+
+#define AR5K_CCFG_CCU		0x0604			/* Register Address */
+#define AR5K_CCFG_CCU_CUP_EN	0x00000001	/* CCU Catchup enable */
+#define AR5K_CCFG_CCU_CREDIT	0x00000002	/* CCU Credit (field) */
+#define AR5K_CCFG_CCU_CD_THRES	0x00000080	/* CCU Cyc(lic?) debt threshold (field) */
+#define AR5K_CCFG_CCU_CUP_LCNT	0x00010000	/* CCU Catchup lit(?) count */
+#define	AR5K_CCFG_CCU_INIT	0x00100200	/* Initial value during reset */
 
 /*
  * Compression performance counter registers [5212+]
@@ -450,7 +503,7 @@
 #define AR5K_CPC1		0x0614		/* Compression performance counter 1*/
 #define AR5K_CPC2		0x0618		/* Compression performance counter 2 */
 #define AR5K_CPC3		0x061c		/* Compression performance counter 3 */
-#define AR5K_CPCORN		0x0620		/* Compression performance overrun (?) */
+#define AR5K_CPCOVF		0x0620		/* Compression performance overflow */
 
 
 /*
@@ -466,8 +519,6 @@
  * set/clear, which contain status for all queues (we shift by 1 for each
  * queue). To access these registers easily we define some macros here
  * that are used inside HAL. For more infos check out *_tx_queue functs.
- *
- * TODO: Boundary checking on macros (here?)
  */
 
 /*
@@ -513,7 +564,6 @@
 #define	AR5K_QCU_RDYTIMECFG_BASE	0x0900	/* Register Address - Queue0 RDYTIMECFG */
 #define	AR5K_QCU_RDYTIMECFG_INTVAL	0x00ffffff	/* Ready time interval mask */
 #define AR5K_QCU_RDYTIMECFG_INTVAL_S	0
-#define	AR5K_QCU_RDYTIMECFG_DURATION	0x00ffffff	/* Ready time duration mask */
 #define	AR5K_QCU_RDYTIMECFG_ENABLE	0x01000000	/* Ready time enable mask */
 #define AR5K_QUEUE_RDYTIMECFG(_q)	AR5K_QUEUE_REG(AR5K_QCU_RDYTIMECFG_BASE, _q)
 
@@ -534,19 +584,20 @@
  */
 #define AR5K_QCU_MISC_BASE		0x09c0			/* Register Address -Queue0 MISC */
 #define	AR5K_QCU_MISC_FRSHED_M		0x0000000f	/* Frame sheduling mask */
-#define	AR5K_QCU_MISC_FRSHED_ASAP	0		/* ASAP */
-#define	AR5K_QCU_MISC_FRSHED_CBR	1		/* Constant Bit Rate */
-#define	AR5K_QCU_MISC_FRSHED_DBA_GT	2		/* DMA Beacon alert gated (?) */
-#define	AR5K_QCU_MISC_FRSHED_TIM_GT	3		/* Time gated (?) */
+#define	AR5K_QCU_MISC_FRSHED_ASAP		0	/* ASAP */
+#define	AR5K_QCU_MISC_FRSHED_CBR		1	/* Constant Bit Rate */
+#define	AR5K_QCU_MISC_FRSHED_DBA_GT		2	/* DMA Beacon alert gated (?) */
+#define	AR5K_QCU_MISC_FRSHED_TIM_GT		3	/* Time gated (?) */
 #define	AR5K_QCU_MISC_FRSHED_BCN_SENT_GT	4	/* Beacon sent gated (?) */
 #define	AR5K_QCU_MISC_ONESHOT_ENABLE	0x00000010	/* Oneshot enable */
 #define	AR5K_QCU_MISC_CBREXP		0x00000020	/* CBR expired (normal queue) */
 #define	AR5K_QCU_MISC_CBREXP_BCN	0x00000040	/* CBR expired (beacon queue) */
-#define	AR5K_QCU_MISC_BCN_ENABLE	0x00000080	/* Beacons enabled */
-#define	AR5K_QCU_MISC_CBR_THRES_ENABLE	0x00000100	/* CBR threshold enabled (?) */
-#define	AR5K_QCU_MISC_TXE		0x00000200	/* TXE reset when RDYTIME enalbed (?) */
-#define	AR5K_QCU_MISC_CBR		0x00000400	/* CBR threshold reset (?) */
-#define	AR5K_QCU_MISC_DCU_EARLY		0x00000800	/* DCU reset (?) */
+#define	AR5K_QCU_MISC_BCN_ENABLE	0x00000080	/* Enable Beacon use */
+#define	AR5K_QCU_MISC_CBR_THRES_ENABLE	0x00000100	/* CBR threshold enabled */
+#define	AR5K_QCU_MISC_RDY_VEOL_POLICY	0x00000200	/* TXE reset when RDYTIME enalbed */
+#define	AR5K_QCU_MISC_CBR_RESET_CNT	0x00000400	/* CBR threshold (counter) reset */
+#define	AR5K_QCU_MISC_DCU_EARLY		0x00000800	/* DCU early termination */
+#define AR5K_QCU_MISC_DCU_CMP_EN	0x00001000	/* Enable frame compression */
 #define AR5K_QUEUE_MISC(_q)		AR5K_QUEUE_REG(AR5K_QCU_MISC_BASE, _q)
 
 
@@ -555,7 +606,7 @@
  */
 #define AR5K_QCU_STS_BASE	0x0a00			/* Register Address - Queue0 STS */
 #define	AR5K_QCU_STS_FRMPENDCNT	0x00000003	/* Frames pending counter */
-#define	AR5K_QCU_STS_CBREXPCNT	0x0000ff00	/* CBR expired counter (?) */
+#define	AR5K_QCU_STS_CBREXPCNT	0x0000ff00	/* CBR expired counter */
 #define	AR5K_QUEUE_STATUS(_q)	AR5K_QUEUE_REG(AR5K_QCU_STS_BASE, _q)
 
 /*
@@ -569,9 +620,11 @@
  */
 #define AR5K_QCU_CBB_SELECT	0x0b00
 #define AR5K_QCU_CBB_ADDR	0x0b04
+#define AR5K_QCU_CBB_ADDR_S	9
 
 /*
  * QCU compression buffer configuration register [5212+]
+ * (buffer size)
  */
 #define AR5K_QCU_CBCFG		0x0b08
 
@@ -652,80 +705,100 @@
  * No lockout means there is no special handling.
  */
 #define AR5K_DCU_MISC_BASE		0x1100			/* Register Address -Queue0 DCU_MISC */
-#define	AR5K_DCU_MISC_BACKOFF		0x000007ff	/* Mask for backoff setting (?) */
+#define	AR5K_DCU_MISC_BACKOFF		0x000007ff	/* Mask for backoff threshold */
 #define AR5K_DCU_MISC_BACKOFF_FRAG	0x00000200	/* Enable backoff while bursting */
-#define	AR5K_DCU_MISC_HCFPOLL_ENABLE	0x00000800	/* CF - Poll (?) */
-#define	AR5K_DCU_MISC_BACKOFF_PERSIST	0x00001000	/* Persistent backoff (?) */
-#define	AR5K_DCU_MISC_FRMPRFTCH_ENABLE	0x00002000	/* Enable frame pre-fetch (?) */
+#define	AR5K_DCU_MISC_HCFPOLL_ENABLE	0x00000800	/* CF - Poll enable */
+#define	AR5K_DCU_MISC_BACKOFF_PERSIST	0x00001000	/* Persistent backoff */
+#define	AR5K_DCU_MISC_FRMPRFTCH_ENABLE	0x00002000	/* Enable frame pre-fetch */
 #define	AR5K_DCU_MISC_VIRTCOL		0x0000c000	/* Mask for Virtual Collision (?) */
-#define	AR5K_DCU_MISC_VIRTCOL_NORMAL	0
-#define	AR5K_DCU_MISC_VIRTCOL_MODIFIED	1
-#define	AR5K_DCU_MISC_VIRTCOL_IGNORE	2
-#define	AR5K_DCU_MISC_BCN_ENABLE	0x00010000	/* Beacon enable (?) */
+#define	AR5K_DCU_MISC_VIRTCOL_NORMAL		0
+#define	AR5K_DCU_MISC_VIRTCOL_MODIFIED		1
+#define	AR5K_DCU_MISC_VIRTCOL_IGNORE		2
+#define	AR5K_DCU_MISC_BCN_ENABLE	0x00010000	/* Enable Beacon use */
 #define	AR5K_DCU_MISC_ARBLOCK_CTL	0x00060000	/* Arbiter lockout control mask */
 #define	AR5K_DCU_MISC_ARBLOCK_CTL_S	17
-#define	AR5K_DCU_MISC_ARBLOCK_CTL_NONE	0		/* No arbiter lockout */
+#define	AR5K_DCU_MISC_ARBLOCK_CTL_NONE		0	/* No arbiter lockout */
 #define	AR5K_DCU_MISC_ARBLOCK_CTL_INTFRM	1	/* Intra-frame lockout */
 #define	AR5K_DCU_MISC_ARBLOCK_CTL_GLOBAL	2	/* Global lockout */
-#define	AR5K_DCU_MISC_ARBLOCK_IGNORE	0x00080000
-#define	AR5K_DCU_MISC_SEQ_NUM_INCR_DIS	0x00100000	/* Disable sequence number increment (?) */
-#define	AR5K_DCU_MISC_POST_FR_BKOFF_DIS	0x00200000	/* Disable post-frame backoff (?) */
-#define	AR5K_DCU_MISC_VIRT_COLL_POLICY	0x00400000	/* Virtual Collision policy (?) */
-#define	AR5K_DCU_MISC_BLOWN_IFS_POLICY	0x00800000
+#define	AR5K_DCU_MISC_ARBLOCK_IGNORE	0x00080000	/* Ignore Arbiter lockout */
+#define	AR5K_DCU_MISC_SEQ_NUM_INCR_DIS	0x00100000	/* Disable sequence number increment */
+#define	AR5K_DCU_MISC_POST_FR_BKOFF_DIS	0x00200000	/* Disable post-frame backoff */
+#define	AR5K_DCU_MISC_VIRT_COLL_POLICY	0x00400000	/* Virtual Collision cw policy */
+#define	AR5K_DCU_MISC_BLOWN_IFS_POLICY	0x00800000	/* Blown IFS policy (?) */
 #define	AR5K_DCU_MISC_SEQNUM_CTL	0x01000000	/* Sequence number control (?) */
 #define AR5K_QUEUE_DFS_MISC(_q)		AR5K_QUEUE_REG(AR5K_DCU_MISC_BASE, _q)
 
 /*
  * DCU frame sequence number registers
  */
-#define AR5K_DCU_SEQNUM_BASE	0x1140
-#define	AR5K_DCU_SEQNUM_M	0x00000fff
+#define AR5K_DCU_SEQNUM_BASE		0x1140
+#define	AR5K_DCU_SEQNUM_M		0x00000fff
 #define	AR5K_QUEUE_DFS_SEQNUM(_q)	AR5K_QUEUE_REG(AR5K_DCU_SEQNUM_BASE, _q)
 
 /*
- * DCU global IFS SIFS registers
+ * DCU global IFS SIFS register
  */
 #define AR5K_DCU_GBL_IFS_SIFS	0x1030
 #define AR5K_DCU_GBL_IFS_SIFS_M	0x0000ffff
 
 /*
- * DCU global IFS slot interval registers
+ * DCU global IFS slot interval register
  */
 #define AR5K_DCU_GBL_IFS_SLOT	0x1070
 #define AR5K_DCU_GBL_IFS_SLOT_M	0x0000ffff
 
 /*
- * DCU global IFS EIFS registers
+ * DCU global IFS EIFS register
  */
 #define AR5K_DCU_GBL_IFS_EIFS	0x10b0
 #define AR5K_DCU_GBL_IFS_EIFS_M	0x0000ffff
 
 /*
- * DCU global IFS misc registers
+ * DCU global IFS misc register
+ *
+ * LFSR stands for Linear Feedback Shift Register
+ * and it's used for generating pseudo-random
+ * number sequences.
+ *
+ * (If i understand corectly, random numbers are
+ * used for idle sensing -multiplied with cwmin/max etc-)
  */
 #define AR5K_DCU_GBL_IFS_MISC			0x10f0			/* Register Address */
-#define	AR5K_DCU_GBL_IFS_MISC_LFSR_SLICE	0x00000007
-#define	AR5K_DCU_GBL_IFS_MISC_TURBO_MODE	0x00000008	/* Turbo mode (?) */
-#define	AR5K_DCU_GBL_IFS_MISC_SIFS_DUR_USEC	0x000003f0	/* SIFS Duration mask (?) */
-#define	AR5K_DCU_GBL_IFS_MISC_USEC_DUR		0x000ffc00
-#define	AR5K_DCU_GBL_IFS_MISC_DCU_ARB_DELAY	0x00300000
+#define	AR5K_DCU_GBL_IFS_MISC_LFSR_SLICE	0x00000007	/* LFSR Slice Select */
+#define	AR5K_DCU_GBL_IFS_MISC_TURBO_MODE	0x00000008	/* Turbo mode */
+#define	AR5K_DCU_GBL_IFS_MISC_SIFS_DUR_USEC	0x000003f0	/* SIFS Duration mask */
+#define	AR5K_DCU_GBL_IFS_MISC_USEC_DUR		0x000ffc00	/* USEC Duration mask */
+#define	AR5K_DCU_GBL_IFS_MISC_DCU_ARB_DELAY	0x00300000	/* DCU Arbiter delay mask */
+#define AR5K_DCU_GBL_IFS_MISC_SIFS_CNT_RST	0x00400000	/* SIFC cnt reset policy (?) */
+#define AR5K_DCU_GBL_IFS_MISC_AIFS_CNT_RST	0x00800000	/* AIFS cnt reset policy (?) */
+#define AR5K_DCU_GBL_IFS_MISC_RND_LFSR_SL_DIS	0x01000000	/* Disable random LFSR slice */
 
 /*
  * DCU frame prefetch control register
  */
-#define AR5K_DCU_FP		0x1230
+#define AR5K_DCU_FP			0x1230			/* Register Address */
+#define AR5K_DCU_FP_NOBURST_DCU_EN	0x00000001	/* Enable non-burst prefetch on DCU (?) */
+#define AR5K_DCU_FP_NOBURST_EN		0x00000010	/* Enable non-burst prefetch (?) */
+#define AR5K_DCU_FP_BURST_DCU_EN	0x00000020	/* Enable burst prefetch on DCU (?) */
 
 /*
  * DCU transmit pause control/status register
  */
 #define AR5K_DCU_TXP		0x1270			/* Register Address */
-#define	AR5K_DCU_TXP_M		0x000003ff	/* Tx pause mask (?) */
-#define	AR5K_DCU_TXP_STATUS	0x00010000	/* Tx pause status (?) */
+#define	AR5K_DCU_TXP_M		0x000003ff	/* Tx pause mask */
+#define	AR5K_DCU_TXP_STATUS	0x00010000	/* Tx pause status */
+
+/*
+ * DCU transmit filter table 0 (32 entries)
+ */
+#define AR5K_DCU_TX_FILTER_0_BASE	0x1038
+#define	AR5K_DCU_TX_FILTER_0(_n)	(AR5K_DCU_TX_FILTER_0_BASE + (_n * 64))
 
 /*
- * DCU transmit filter register
+ * DCU transmit filter table 1 (16 entries)
  */
-#define AR5K_DCU_TX_FILTER	0x1038
+#define AR5K_DCU_TX_FILTER_1_BASE	0x103c
+#define	AR5K_DCU_TX_FILTER_1(_n)	(AR5K_DCU_TX_FILTER_1_BASE + ((_n - 32) * 64))
 
 /*
  * DCU clear transmit filter register
@@ -739,9 +812,6 @@
 
 /*
  * Reset control register
- *
- * 4 and 8 are not used in 5211/5212 and
- * 2 means "baseband reset" on 5211/5212.
  */
 #define AR5K_RESET_CTL		0x4000			/* Register Address */
 #define AR5K_RESET_CTL_PCU	0x00000001	/* Protocol Control Unit reset */
@@ -765,6 +835,7 @@
 #define AR5K_SLEEP_CTL_SLE_SLP		0x00010000	/* Force chip sleep */
 #define AR5K_SLEEP_CTL_SLE_ALLOW	0x00020000
 #define AR5K_SLEEP_CTL_SLE_UNITS	0x00000008	/* [5211+] */
+/* more bits */
 
 /*
  * Interrupt pending register
@@ -776,13 +847,14 @@
  * Sleep force register
  */
 #define AR5K_SFR	0x400c
-#define AR5K_SFR_M	0x00000001
+#define AR5K_SFR_EN	0x00000001
 
 /*
  * PCI configuration register
  */
 #define AR5K_PCICFG			0x4010			/* Register Address */
 #define AR5K_PCICFG_EEAE		0x00000001	/* Eeprom access enable [5210] */
+#define	AR5K_PCICFG_SLEEP_CLOCK_EN	0x00000002	/* Enable sleep clock (?) */
 #define AR5K_PCICFG_CLKRUNEN		0x00000004	/* CLKRUN enable [5211+] */
 #define AR5K_PCICFG_EESIZE		0x00000018	/* Mask for EEPROM size [5211+] */
 #define AR5K_PCICFG_EESIZE_S		3
@@ -798,19 +870,21 @@
 #define	AR5K_PCICFG_CBEFIX_DIS		0x00000400	/* Disable CBE fix (?) */
 #define AR5K_PCICFG_SL_INTEN		0x00000800	/* Enable interrupts when asleep (?) */
 #define AR5K_PCICFG_LED_BCTL		0x00001000	/* Led blink (?) [5210] */
-#define AR5K_PCICFG_SL_INPEN		0x00002800	/* Sleep even whith pending interrupts (?) */
+#define	AR5K_PCICFG_UNK			0x00001000	/* Passed on some parts durring attach (?) */
+#define AR5K_PCICFG_SL_INPEN		0x00002000	/* Sleep even whith pending interrupts (?) */
 #define AR5K_PCICFG_SPWR_DN		0x00010000	/* Mask for power status */
 #define AR5K_PCICFG_LEDMODE		0x000e0000	/* Ledmode [5211+] */
 #define AR5K_PCICFG_LEDMODE_PROP	0x00000000	/* Blink on standard traffic [5211+] */
 #define AR5K_PCICFG_LEDMODE_PROM	0x00020000	/* Default mode (blink on any traffic) [5211+] */
 #define AR5K_PCICFG_LEDMODE_PWR		0x00040000	/* Some other blinking mode  (?) [5211+] */
 #define AR5K_PCICFG_LEDMODE_RAND	0x00060000	/* Random blinking (?) [5211+] */
-#define AR5K_PCICFG_LEDBLINK		0x00700000
+#define AR5K_PCICFG_LEDBLINK		0x00700000	/* Led blink rate */
 #define AR5K_PCICFG_LEDBLINK_S		20
-#define AR5K_PCICFG_LEDSLOW		0x00800000	/* Slow led blink rate (?) [5211+] */
+#define AR5K_PCICFG_LEDSLOW		0x00800000	/* Slowest led blink rate [5211+] */
 #define AR5K_PCICFG_LEDSTATE				\
 	(AR5K_PCICFG_LED | AR5K_PCICFG_LEDMODE |	\
 	AR5K_PCICFG_LEDBLINK | AR5K_PCICFG_LEDSLOW)
+#define	AR5K_PCICFG_SLEEP_CLOCK_RATE	0x03000000	/* Sleep clock rate (field) */
 
 /*
  * "General Purpose Input/Output" (GPIO) control register
@@ -947,7 +1021,7 @@
 #define AR5K_EEPROM_VERSION_4_4		0x4004
 #define AR5K_EEPROM_VERSION_4_5		0x4005
 #define AR5K_EEPROM_VERSION_4_6		0x4006	/* has ee_scaled_cck_delta */
-#define AR5K_EEPROM_VERSION_4_7		0x3007
+#define AR5K_EEPROM_VERSION_4_7		0x4007
 
 #define AR5K_EEPROM_MODE_11A		0
 #define AR5K_EEPROM_MODE_11B		1
@@ -1023,10 +1097,14 @@
 #define AR5K_EEPROM_STAT_WRDONE	0x00000008	/* EEPROM write successful */
 
 /*
- * EEPROM config register (?)
+ * EEPROM config register
  */
-#define AR5K_EEPROM_CFG	0x6010
-
+#define AR5K_EEPROM_CFG			0x6010			/* Register Addres */
+#define AR5K_EEPROM_CFG_SIZE_OVR	0x00000001
+#define AR5K_EEPROM_CFG_WR_WAIT_DIS	0x00000004	/* Disable write wait */
+#define AR5K_EEPROM_CFG_CLK_RATE	0x00000018	/* Clock rate */
+#define AR5K_EEPROM_CFG_PROT_KEY	0x00ffff00	/* Protectio key */
+#define AR5K_EEPROM_CFG_LIND_EN		0x01000000	/* Enable length indicator (?) */
 
 
 /*
@@ -1050,7 +1128,7 @@
 #define AR5K_STA_ID1			0x8004			/* Register Address */
 #define AR5K_STA_ID1_AP			0x00010000	/* Set AP mode */
 #define AR5K_STA_ID1_ADHOC		0x00020000	/* Set Ad-Hoc mode */
-#define AR5K_STA_ID1_PWR_SV		0x00040000	/* Power save reporting (?) */
+#define AR5K_STA_ID1_PWR_SV		0x00040000	/* Power save reporting */
 #define AR5K_STA_ID1_NO_KEYSRCH		0x00080000	/* No key search */
 #define AR5K_STA_ID1_NO_PSPOLL		0x00100000	/* No power save polling [5210] */
 #define AR5K_STA_ID1_PCF_5211		0x00100000	/* Enable PCF on [5211+] */
@@ -1059,9 +1137,13 @@
 					AR5K_STA_ID1_PCF_5210 : AR5K_STA_ID1_PCF_5211)
 #define AR5K_STA_ID1_DEFAULT_ANTENNA	0x00200000	/* Use default antenna */
 #define AR5K_STA_ID1_DESC_ANTENNA	0x00400000	/* Update antenna from descriptor */
-#define AR5K_STA_ID1_RTS_DEF_ANTENNA	0x00800000	/* Use default antenna for RTS (?) */
-#define AR5K_STA_ID1_ACKCTS_6MB		0x01000000	/* Use 6Mbit/s for ACK/CTS (?) */
+#define AR5K_STA_ID1_RTS_DEF_ANTENNA	0x00800000	/* Use default antenna for RTS */
+#define AR5K_STA_ID1_ACKCTS_6MB		0x01000000	/* Use 6Mbit/s for ACK/CTS */
 #define AR5K_STA_ID1_BASE_RATE_11B	0x02000000	/* Use 11b base rate (for ACK/CTS ?) [5211+] */
+#define AR5K_STA_ID1_SELF_GEN_SECTORE	0x04000000	/* Self generate sectore (?) */
+#define AR5K_STA_ID1_CRYPT_MIC_EN	0x08000000	/* Enable MIC */
+#define AR5K_STA_ID1_KEYSRCH_MODE	0x10000000	/* Keysearch mode (?) */
+#define AR5K_STA_ID1_PRESERVE_SEQ_NUM	0x20000000	/* Preserve sequence number */
 
 /*
  * First BSSID register (MAC address, lower 32bits)
@@ -1117,7 +1199,7 @@
  *
  * Retry limit register for 5210 (no QCU/DCU so it's done in PCU)
  */
-#define AR5K_NODCU_RETRY_LMT		0x801c			/*Register Address */
+#define AR5K_NODCU_RETRY_LMT		0x801c			/* Register Address */
 #define AR5K_NODCU_RETRY_LMT_SH_RETRY	0x0000000f	/* Short retry limit mask */
 #define AR5K_NODCU_RETRY_LMT_SH_RETRY_S	0
 #define AR5K_NODCU_RETRY_LMT_LG_RETRY	0x000000f0	/* Long retry mask */
@@ -1136,9 +1218,9 @@
 #define AR5K_USEC_5211			0x801c			/* Register Address [5211+] */
 #define AR5K_USEC			(ah->ah_version == AR5K_AR5210 ? \
 					AR5K_USEC_5210 : AR5K_USEC_5211)
-#define AR5K_USEC_1			0x0000007f
+#define AR5K_USEC_1			0x0000007f	/* clock cycles for 1us */
 #define AR5K_USEC_1_S			0
-#define AR5K_USEC_32			0x00003f80
+#define AR5K_USEC_32			0x00003f80	/* clock cycles for 1us while on 32Mhz clock */
 #define AR5K_USEC_32_S			7
 #define AR5K_USEC_TX_LATENCY_5211	0x007fc000
 #define AR5K_USEC_TX_LATENCY_5211_S	14
@@ -1152,16 +1234,16 @@
 /*
  * PCU beacon control register
  */
-#define AR5K_BEACON_5210	0x8024
-#define AR5K_BEACON_5211	0x8020
+#define AR5K_BEACON_5210	0x8024			/*Register Address [5210] */
+#define AR5K_BEACON_5211	0x8020			/*Register Address [5211+] */
 #define AR5K_BEACON		(ah->ah_version == AR5K_AR5210 ? \
 				AR5K_BEACON_5210 : AR5K_BEACON_5211)
-#define AR5K_BEACON_PERIOD	0x0000ffff
+#define AR5K_BEACON_PERIOD	0x0000ffff	/* Mask for beacon period */
 #define AR5K_BEACON_PERIOD_S	0
-#define AR5K_BEACON_TIM		0x007f0000
+#define AR5K_BEACON_TIM		0x007f0000	/* Mask for TIM offset */
 #define AR5K_BEACON_TIM_S	16
-#define AR5K_BEACON_ENABLE	0x00800000
-#define AR5K_BEACON_RESET_TSF	0x01000000
+#define AR5K_BEACON_ENABLE	0x00800000	/* Enable beacons */
+#define AR5K_BEACON_RESET_TSF	0x01000000	/* Force TSF reset */
 
 /*
  * CFP period register
@@ -1234,7 +1316,6 @@
 
 /*
  * Receive filter register
- * TODO: Get these out of ar5xxx.h on ath5k
  */
 #define AR5K_RX_FILTER_5210	0x804c			/* Register Address [5210] */
 #define AR5K_RX_FILTER_5211	0x803c			/* Register Address [5211+] */
@@ -1307,11 +1388,11 @@
 #define AR5K_DIAG_SW_5211		0x8048			/* Register Address [5211+] */
 #define AR5K_DIAG_SW			(ah->ah_version == AR5K_AR5210 ? \
 					AR5K_DIAG_SW_5210 : AR5K_DIAG_SW_5211)
-#define AR5K_DIAG_SW_DIS_WEP_ACK	0x00000001
-#define AR5K_DIAG_SW_DIS_ACK		0x00000002	/* Disable ACKs (?) */
-#define AR5K_DIAG_SW_DIS_CTS		0x00000004	/* Disable CTSs (?) */
-#define AR5K_DIAG_SW_DIS_ENC		0x00000008	/* Disable encryption (?) */
-#define AR5K_DIAG_SW_DIS_DEC		0x00000010	/* Disable decryption (?) */
+#define AR5K_DIAG_SW_DIS_WEP_ACK	0x00000001	/* Disable ACKs if WEP key is invalid */
+#define AR5K_DIAG_SW_DIS_ACK		0x00000002	/* Disable ACKs */
+#define AR5K_DIAG_SW_DIS_CTS		0x00000004	/* Disable CTSs */
+#define AR5K_DIAG_SW_DIS_ENC		0x00000008	/* Disable encryption */
+#define AR5K_DIAG_SW_DIS_DEC		0x00000010	/* Disable decryption */
 #define AR5K_DIAG_SW_DIS_TX		0x00000020	/* Disable transmit [5210] */
 #define AR5K_DIAG_SW_DIS_RX_5210	0x00000040	/* Disable recieve */
 #define AR5K_DIAG_SW_DIS_RX_5211	0x00000020
@@ -1329,13 +1410,13 @@
 #define AR5K_DIAG_SW_CHAN_INFO_5211	0x00000100
 #define AR5K_DIAG_SW_CHAN_INFO		(ah->ah_version == AR5K_AR5210 ? \
 					AR5K_DIAG_SW_CHAN_INFO_5210 : AR5K_DIAG_SW_CHAN_INFO_5211)
-#define AR5K_DIAG_SW_EN_SCRAM_SEED_5211	0x00000200	/* Scrambler seed (?) */
+#define AR5K_DIAG_SW_EN_SCRAM_SEED_5211	0x00000200	/* Enable scrambler seed */
 #define AR5K_DIAG_SW_EN_SCRAM_SEED_5210	0x00000400
 #define AR5K_DIAG_SW_EN_SCRAM_SEED	(ah->ah_version == AR5K_AR5210 ? \
 					AR5K_DIAG_SW_EN_SCRAM_SEED_5210 : AR5K_DIAG_SW_EN_SCRAM_SEED_5211)
 #define AR5K_DIAG_SW_ECO_ENABLE		0x00000400	/* [5211+] */
 #define AR5K_DIAG_SW_SCVRAM_SEED	0x0003f800	/* [5210] */
-#define AR5K_DIAG_SW_SCRAM_SEED_M	0x0001fc00	/* Scrambler seed mask (?) */
+#define AR5K_DIAG_SW_SCRAM_SEED_M	0x0001fc00	/* Scrambler seed mask */
 #define AR5K_DIAG_SW_SCRAM_SEED_S	10
 #define AR5K_DIAG_SW_DIS_SEQ_INC	0x00040000	/* Disable seqnum increment (?)[5210] */
 #define AR5K_DIAG_SW_FRAME_NV0_5210	0x00080000
@@ -1344,6 +1425,7 @@
 					AR5K_DIAG_SW_FRAME_NV0_5210 : AR5K_DIAG_SW_FRAME_NV0_5211)
 #define AR5K_DIAG_SW_OBSPT_M		0x000c0000
 #define AR5K_DIAG_SW_OBSPT_S		18
+/* more bits */
 
 /*
  * TSF (clock) register (lower 32 bits)
@@ -1369,15 +1451,34 @@
 /*
  * ADDAC test register [5211+]
  */
-#define AR5K_ADDAC_TEST	0x8054
-#define AR5K_ADDAC_TEST_TXCONT 0x00000001
+#define AR5K_ADDAC_TEST			0x8054			/* Register Address */
+#define AR5K_ADDAC_TEST_TXCONT 		0x00000001	/* Test continuous tx */
+#define AR5K_ADDAC_TEST_TST_MODE	0x00000002	/* Test mode */
+#define AR5K_ADDAC_TEST_LOOP_EN		0x00000004	/* Enable loop */
+#define AR5K_ADDAC_TEST_LOOP_LEN	0x00000008	/* Loop length (field) */
+#define AR5K_ADDAC_TEST_USE_U8		0x00004000	/* Use upper 8 bits */
+#define AR5K_ADDAC_TEST_MSB		0x00008000	/* State of MSB */
+#define AR5K_ADDAC_TEST_TRIG_SEL	0x00010000	/* Trigger select */
+#define AR5K_ADDAC_TEST_TRIG_PTY	0x00020000	/* Trigger polarity */
+#define AR5K_ADDAC_TEST_RXCONT		0x00040000	/* Continuous capture */
+#define AR5K_ADDAC_TEST_CAPTURE		0x00080000	/* Begin capture */
+#define AR5K_ADDAC_TEST_TST_ARM		0x00100000	/* Test ARM (Adaptive Radio Mode ?) */
 
 /*
  * Default antenna register [5211+]
  */
 #define AR5K_DEFAULT_ANTENNA	0x8058
 
+/*
+ * Frame control QoS mask register (?) [5211+]
+ * (FC_QOS_MASK)
+ */
+#define AR5K_FRAME_CTL_QOSM	0x805c
 
+/*
+ * Seq mask register (?) [5211+]
+ */
+#define AR5K_SEQ_MASK	0x8060
 
 /*
  * Retry count register [5210]
@@ -1449,124 +1550,242 @@
 /*
  * XR (eXtended Range) mode register
  */
-#define AR5K_XRMODE			0x80c0
-#define	AR5K_XRMODE_POLL_TYPE_M		0x0000003f
+#define AR5K_XRMODE			0x80c0			/* Register Address */
+#define	AR5K_XRMODE_POLL_TYPE_M		0x0000003f	/* Mask for Poll type (?) */
 #define	AR5K_XRMODE_POLL_TYPE_S		0
-#define	AR5K_XRMODE_POLL_SUBTYPE_M	0x0000003c
+#define	AR5K_XRMODE_POLL_SUBTYPE_M	0x0000003c	/* Mask for Poll subtype (?) */
 #define	AR5K_XRMODE_POLL_SUBTYPE_S	2
-#define	AR5K_XRMODE_POLL_WAIT_ALL	0x00000080
-#define	AR5K_XRMODE_SIFS_DELAY		0x000fff00
-#define	AR5K_XRMODE_FRAME_HOLD_M	0xfff00000
+#define	AR5K_XRMODE_POLL_WAIT_ALL	0x00000080	/* Wait for poll */
+#define	AR5K_XRMODE_SIFS_DELAY		0x000fff00	/* Mask for SIFS delay */
+#define	AR5K_XRMODE_FRAME_HOLD_M	0xfff00000	/* Mask for frame hold (?) */
 #define	AR5K_XRMODE_FRAME_HOLD_S	20
 
 /*
  * XR delay register
  */
-#define AR5K_XRDELAY			0x80c4
-#define AR5K_XRDELAY_SLOT_DELAY_M	0x0000ffff
+#define AR5K_XRDELAY			0x80c4			/* Register Address */
+#define AR5K_XRDELAY_SLOT_DELAY_M	0x0000ffff	/* Mask for slot delay */
 #define AR5K_XRDELAY_SLOT_DELAY_S	0
-#define AR5K_XRDELAY_CHIRP_DELAY_M	0xffff0000
+#define AR5K_XRDELAY_CHIRP_DELAY_M	0xffff0000	/* Mask for CHIRP data delay */
 #define AR5K_XRDELAY_CHIRP_DELAY_S	16
 
 /*
  * XR timeout register
  */
-#define AR5K_XRTIMEOUT			0x80c8
-#define AR5K_XRTIMEOUT_CHIRP_M		0x0000ffff
+#define AR5K_XRTIMEOUT			0x80c8			/* Register Address */
+#define AR5K_XRTIMEOUT_CHIRP_M		0x0000ffff	/* Mask for CHIRP timeout */
 #define AR5K_XRTIMEOUT_CHIRP_S		0
-#define AR5K_XRTIMEOUT_POLL_M		0xffff0000
+#define AR5K_XRTIMEOUT_POLL_M		0xffff0000	/* Mask for Poll timeout */
 #define AR5K_XRTIMEOUT_POLL_S		16
 
 /*
  * XR chirp register
  */
-#define AR5K_XRCHIRP			0x80cc
-#define AR5K_XRCHIRP_SEND		0x00000001
-#define AR5K_XRCHIRP_GAP		0xffff0000
+#define AR5K_XRCHIRP			0x80cc			/* Register Address */
+#define AR5K_XRCHIRP_SEND		0x00000001	/* Send CHIRP */
+#define AR5K_XRCHIRP_GAP		0xffff0000	/* Mask for CHIRP gap (?) */
 
 /*
  * XR stomp register
  */
-#define AR5K_XRSTOMP			0x80d0
-#define AR5K_XRSTOMP_TX			0x00000001
-#define AR5K_XRSTOMP_RX_ABORT		0x00000002
-#define AR5K_XRSTOMP_RSSI_THRES		0x0000ff00
+#define AR5K_XRSTOMP			0x80d0			/* Register Address */
+#define AR5K_XRSTOMP_TX			0x00000001	/* Stomp Tx (?) */
+#define AR5K_XRSTOMP_RX			0x00000002	/* Stomp Rx (?) */
+#define AR5K_XRSTOMP_TX_RSSI		0x00000004	/* Stomp Tx RSSI (?) */
+#define AR5K_XRSTOMP_TX_BSSID		0x00000008	/* Stomp Tx BSSID (?) */
+#define AR5K_XRSTOMP_DATA		0x00000010	/* Stomp data (?)*/
+#define AR5K_XRSTOMP_RSSI_THRES		0x0000ff00	/* Mask for XR RSSI threshold */
 
 /*
  * First enhanced sleep register
  */
-#define AR5K_SLEEP0			0x80d4
-#define AR5K_SLEEP0_NEXT_DTIM		0x0007ffff
+#define AR5K_SLEEP0			0x80d4			/* Register Address */
+#define AR5K_SLEEP0_NEXT_DTIM		0x0007ffff	/* Mask for next DTIM (?) */
 #define AR5K_SLEEP0_NEXT_DTIM_S		0
-#define AR5K_SLEEP0_ASSUME_DTIM		0x00080000
-#define AR5K_SLEEP0_ENH_SLEEP_EN	0x00100000
-#define AR5K_SLEEP0_CABTO		0xff000000
+#define AR5K_SLEEP0_ASSUME_DTIM		0x00080000	/* Assume DTIM */
+#define AR5K_SLEEP0_ENH_SLEEP_EN	0x00100000	/* Enable enchanced sleep control */
+#define AR5K_SLEEP0_CABTO		0xff000000	/* Mask for CAB Time Out */
 #define AR5K_SLEEP0_CABTO_S		24
 
 /*
  * Second enhanced sleep register
  */
-#define AR5K_SLEEP1			0x80d8
-#define AR5K_SLEEP1_NEXT_TIM		0x0007ffff
+#define AR5K_SLEEP1			0x80d8			/* Register Address */
+#define AR5K_SLEEP1_NEXT_TIM		0x0007ffff	/* Mask for next TIM (?) */
 #define AR5K_SLEEP1_NEXT_TIM_S		0
-#define AR5K_SLEEP1_BEACON_TO		0xff000000
+#define AR5K_SLEEP1_BEACON_TO		0xff000000	/* Mask for Beacon Time Out */
 #define AR5K_SLEEP1_BEACON_TO_S		24
 
 /*
  * Third enhanced sleep register
  */
-#define AR5K_SLEEP2			0x80dc
-#define AR5K_SLEEP2_TIM_PER		0x0000ffff
+#define AR5K_SLEEP2			0x80dc			/* Register Address */
+#define AR5K_SLEEP2_TIM_PER		0x0000ffff	/* Mask for TIM period (?) */
 #define AR5K_SLEEP2_TIM_PER_S		0
-#define AR5K_SLEEP2_DTIM_PER		0xffff0000
+#define AR5K_SLEEP2_DTIM_PER		0xffff0000	/* Mask for DTIM period (?) */
 #define AR5K_SLEEP2_DTIM_PER_S		16
 
 /*
  * BSSID mask registers
  */
-#define AR5K_BSS_IDM0			0x80e0
-#define AR5K_BSS_IDM1			0x80e4
+#define AR5K_BSS_IDM0			0x80e0	/* Upper bits */
+#define AR5K_BSS_IDM1			0x80e4	/* Lower bits */
 
 /*
  * TX power control (TPC) register
+ *
+ * XXX: PCDAC steps (0.5dbm) or DBM ?
+ *
+ * XXX: Mask changes for newer chips to 7f
+ *      like tx power table ?
  */
-#define AR5K_TXPC			0x80e8
-#define AR5K_TXPC_ACK_M			0x0000003f
+#define AR5K_TXPC			0x80e8			/* Register Address */
+#define AR5K_TXPC_ACK_M			0x0000003f	/* Mask for ACK tx power */
 #define AR5K_TXPC_ACK_S			0
-#define AR5K_TXPC_CTS_M			0x00003f00
+#define AR5K_TXPC_CTS_M			0x00003f00	/* Mask for CTS tx power */
 #define AR5K_TXPC_CTS_S			8
-#define AR5K_TXPC_CHIRP_M		0x003f0000
+#define AR5K_TXPC_CHIRP_M		0x003f0000	/* Mask for CHIRP tx power */
 #define AR5K_TXPC_CHIRP_S		22
 
 /*
  * Profile count registers
  */
-#define AR5K_PROFCNT_TX			0x80ec
-#define AR5K_PROFCNT_RX			0x80f0
-#define AR5K_PROFCNT_RXCLR		0x80f4
-#define AR5K_PROFCNT_CYCLE		0x80f8
+#define AR5K_PROFCNT_TX			0x80ec	/* Tx count */
+#define AR5K_PROFCNT_RX			0x80f0	/* Rx count */
+#define AR5K_PROFCNT_RXCLR		0x80f4	/* Clear Rx count */
+#define AR5K_PROFCNT_CYCLE		0x80f8	/* Cycle count (?) */
+
+/*
+ * Quiet (period) control registers (?)
+ */
+#define AR5K_QUIET_CTL1			0x80fc			/* Register Address */
+#define AR5K_QUIET_CTL1_NEXT_QT		0x0000ffff	/* Mask for next quiet (period?) (?) */
+#define AR5K_QUIET_CTL1_QT_EN		0x00010000	/* Enable quiet (period?) */
+#define AR5K_QUIET_CTL2			0x8100			/* Register Address */
+#define AR5K_QUIET_CTL2_QT_PER		0x0000ffff	/* Mask for quiet period (?) */
+#define AR5K_QUIET_CTL2_QT_DUR		0xffff0000	/* Mask for quiet duration (?) */
 
 /*
  * TSF parameter register
  */
-#define AR5K_TSF_PARM			0x8104
-#define AR5K_TSF_PARM_INC_M		0x000000ff
+#define AR5K_TSF_PARM			0x8104			/* Register Address */
+#define AR5K_TSF_PARM_INC_M		0x000000ff	/* Mask for TSF increment */
 #define AR5K_TSF_PARM_INC_S		0
 
 /*
+ * QoS register (?)
+ */
+#define AR5K_QOS			0x8108			/* Register Address */
+#define AR5K_QOS_NOACK_2BIT_VALUES	0x00000000	/* (field) */
+#define AR5K_QOS_NOACK_BIT_OFFSET	0x00000020	/* (field) */
+#define AR5K_QOS_NOACK_BYTE_OFFSET	0x00000080	/* (field) */
+
+/*
  * PHY error filter register
  */
 #define AR5K_PHY_ERR_FIL		0x810c
-#define AR5K_PHY_ERR_FIL_RADAR		0x00000020
-#define AR5K_PHY_ERR_FIL_OFDM		0x00020000
-#define AR5K_PHY_ERR_FIL_CCK		0x02000000
+#define AR5K_PHY_ERR_FIL_RADAR		0x00000020	/* Radar signal */
+#define AR5K_PHY_ERR_FIL_OFDM		0x00020000	/* OFDM false detect (ANI) */
+#define AR5K_PHY_ERR_FIL_CCK		0x02000000	/* CCK false detect (ANI) */
+
+/*
+ * XR latency register
+ */
+#define AR5K_XRLAT_TX		0x8110
 
 /*
- * Rate duration register
+ * ACK SIFS register
+ */
+#define AR5K_ACKSIFS		0x8114			/* Register Address */
+#define AR5K_ACKSIFS_INC	0x00000000	/* ACK SIFS Increment (field) */
+
+/*
+ * MIC QoS control register (?)
+ */
+#define	AR5K_MIC_QOS_CTL	0x8118			/* Register Address */
+#define	AR5K_MIC_QOS_CTL_0	0x00000001	/* MIC QoS control 0 (?) */
+#define	AR5K_MIC_QOS_CTL_1	0x00000004	/* MIC QoS control 1 (?) */
+#define	AR5K_MIC_QOS_CTL_2	0x00000010	/* MIC QoS control 2 (?) */
+#define	AR5K_MIC_QOS_CTL_3	0x00000040	/* MIC QoS control 3 (?) */
+#define	AR5K_MIC_QOS_CTL_4	0x00000100	/* MIC QoS control 4 (?) */
+#define	AR5K_MIC_QOS_CTL_5	0x00000400	/* MIC QoS control 5 (?) */
+#define	AR5K_MIC_QOS_CTL_6	0x00001000	/* MIC QoS control 6 (?) */
+#define	AR5K_MIC_QOS_CTL_7	0x00004000	/* MIC QoS control 7 (?) */
+#define	AR5K_MIC_QOS_CTL_MQ_EN	0x00010000	/* Enable MIC QoS */
+
+/*
+ * MIC QoS select register (?)
+ */
+#define	AR5K_MIC_QOS_SEL	0x811c
+#define	AR5K_MIC_QOS_SEL_0	0x00000001
+#define	AR5K_MIC_QOS_SEL_1	0x00000010
+#define	AR5K_MIC_QOS_SEL_2	0x00000100
+#define	AR5K_MIC_QOS_SEL_3	0x00001000
+#define	AR5K_MIC_QOS_SEL_4	0x00010000
+#define	AR5K_MIC_QOS_SEL_5	0x00100000
+#define	AR5K_MIC_QOS_SEL_6	0x01000000
+#define	AR5K_MIC_QOS_SEL_7	0x10000000
+
+/*
+ * Misc mode control register (?)
+ */
+#define	AR5K_MISC_MODE			0x8120			/* Register Address */
+#define	AR5K_MISC_MODE_FBSSID_MATCH	0x00000001	/* Force BSSID match */
+#define	AR5K_MISC_MODE_ACKSIFS_MEM	0x00000002	/* ACK SIFS memory (?) */
+/* more bits */
+
+/*
+ * OFDM Filter counter
+ */
+#define	AR5K_OFDM_FIL_CNT		0x8124
+
+/*
+ * CCK Filter counter
+ */
+#define	AR5K_CCK_FIL_CNT		0x8128
+
+/*
+ * PHY Error Counters (?)
+ */
+#define	AR5K_PHYERR_CNT1		0x812c
+#define	AR5K_PHYERR_CNT1_MASK		0x8130
+
+#define	AR5K_PHYERR_CNT2		0x8134
+#define	AR5K_PHYERR_CNT2_MASK		0x8138
+
+/*
+ * TSF Threshold register (?)
+ */
+#define	AR5K_TSF_THRES			0x813c
+
+/*
+ * Rate -> ACK SIFS mapping table (32 entries)
+ */
+#define	AR5K_RATE_ACKSIFS_BASE		0x8680			/* Register Address */
+#define	AR5K_RATE_ACKSIFS(_n)		(AR5K_RATE_ACKSIFS_BSE + ((_n) << 2))
+#define	AR5K_RATE_ACKSIFS_NORMAL	0x00000001	/* Normal SIFS (field) */
+#define	AR5K_RATE_ACKSIFS_TURBO		0x00000400	/* Turbo SIFS (field) */
+
+/*
+ * Rate -> duration mapping table (32 entries)
  */
 #define AR5K_RATE_DUR_BASE		0x8700
 #define AR5K_RATE_DUR(_n)		(AR5K_RATE_DUR_BASE + ((_n) << 2))
 
+/*
+ * Rate -> db mapping table
+ * (8 entries, each one has 4 8bit fields)
+ */
+#define AR5K_RATE2DB_BASE		0x87c0
+#define AR5K_RATE2DB(_n)		(AR5K_RATE2DB_BASE + ((_n) << 2))
+
+/*
+ * db -> Rate mapping table
+ * (8 entries, each one has 4 8bit fields)
+ */
+#define AR5K_DB2RATE_BASE		0x87e0
+#define AR5K_DB2RATE(_n)		(AR5K_DB2RATE_BASE + ((_n) << 2))
+
 /*===5212 end===*/
 
 /*
@@ -1613,12 +1832,34 @@
 /*===PHY REGISTERS===*/
 
 /*
- * PHY register
+ * PHY registers start
  */
 #define	AR5K_PHY_BASE			0x9800
 #define	AR5K_PHY(_n)			(AR5K_PHY_BASE + ((_n) << 2))
-#define AR5K_PHY_SHIFT_2GHZ		0x00004007
-#define AR5K_PHY_SHIFT_5GHZ		0x00000007
+
+/*
+ * TST_2 (Misc config parameters)
+ */
+#define	AR5K_PHY_TST2			0x9800			/* Register Address */
+#define AR5K_PHY_TST2_TRIG_SEL		0x00000001	/* Trigger select (?) (field ?) */
+#define AR5K_PHY_TST2_TRIG		0x00000010	/* Trigger (?) (field ?) */
+#define AR5K_PHY_TST2_CBUS_MODE		0x00000100	/* Cardbus mode (?) */
+/* bit reserved */
+#define AR5K_PHY_TST2_CLK32		0x00000400	/* CLK_OUT is CLK32 (32Khz external) */
+#define AR5K_PHY_TST2_CHANCOR_DUMP_EN	0x00000800	/* Enable Chancor dump (?) */
+#define AR5K_PHY_TST2_EVEN_CHANCOR_DUMP	0x00001000	/* Even Chancor dump (?) */
+#define AR5K_PHY_TST2_RFSILENT_EN	0x00002000	/* Enable RFSILENT */
+#define AR5K_PHY_TST2_ALT_RFDATA	0x00004000	/* Alternate RFDATA (5-2GHz switch) */
+#define AR5K_PHY_TST2_MINI_OBS_EN	0x00008000	/* Enable mini OBS (?) */
+#define AR5K_PHY_TST2_RX2_IS_RX5_INV	0x00010000	/* 2GHz rx path is the 5GHz path inverted (?) */
+#define AR5K_PHY_TST2_SLOW_CLK160	0x00020000	/* Slow CLK160 (?) */
+#define AR5K_PHY_TST2_AGC_OBS_SEL_3	0x00040000	/* AGC OBS Select 3 (?) */
+#define AR5K_PHY_TST2_BBB_OBS_SEL	0x00080000	/* BB OBS Select (field ?) */
+#define AR5K_PHY_TST2_ADC_OBS_SEL	0x00800000	/* ADC OBS Select (field ?) */
+#define AR5K_PHY_TST2_RX_CLR_SEL	0x08000000	/* RX Clear Select (?) */
+#define AR5K_PHY_TST2_FORCE_AGC_CLR	0x10000000	/* Force AGC clear (?) */
+#define AR5K_PHY_SHIFT_2GHZ		0x00004007	/* Used to access 2GHz radios */
+#define AR5K_PHY_SHIFT_5GHZ		0x00000007	/* Used to access 5GHz radios (default) */
 
 /*
  * PHY frame control register [5110] /turbo mode register [5111+]
@@ -1630,18 +1871,21 @@
  * a "turbo mode register" for 5110. We treat this one as
  * a frame control register for 5110 below.
  */
-#define	AR5K_PHY_TURBO			0x9804
-#define	AR5K_PHY_TURBO_MODE		0x00000001
-#define	AR5K_PHY_TURBO_SHORT		0x00000002
+#define	AR5K_PHY_TURBO			0x9804			/* Register Address */
+#define	AR5K_PHY_TURBO_MODE		0x00000001	/* Enable turbo mode */
+#define	AR5K_PHY_TURBO_SHORT		0x00000002	/* Short mode (20Mhz channels) (?) */
 
 /*
  * PHY agility command register
+ * (aka TST_1)
  */
-#define	AR5K_PHY_AGC			0x9808
-#define	AR5K_PHY_AGC_DISABLE		0x08000000
+#define	AR5K_PHY_AGC			0x9808			/* Register Address */
+#define	AR5K_PHY_TST1			0x9808
+#define	AR5K_PHY_AGC_DISABLE		0x08000000	/* Disable AGC to A2 (?)*/
+#define	AR5K_PHY_TST1_TXHOLD		0x00003800	/* Set tx hold (?) */
 
 /*
- * PHY timing register [5112+]
+ * PHY timing register 3 [5112+]
  */
 #define	AR5K_PHY_TIMING_3		0x9814
 #define	AR5K_PHY_TIMING_3_DSC_MAN	0xfffe0000
@@ -1657,26 +1901,81 @@
 /*
  * PHY activation register
  */
-#define	AR5K_PHY_ACT			0x981c
-#define	AR5K_PHY_ACT_ENABLE		0x00000001
-#define	AR5K_PHY_ACT_DISABLE		0x00000002
+#define	AR5K_PHY_ACT			0x981c			/* Register Address */
+#define	AR5K_PHY_ACT_ENABLE		0x00000001	/* Activate PHY */
+#define	AR5K_PHY_ACT_DISABLE		0x00000002	/* Deactivate PHY */
+
+/*
+ * PHY RF control registers
+ * (i think these are delay times,
+ * these calibration values exist
+ * in EEPROM)
+ */
+#define AR5K_PHY_RF_CTL2		0x9824			/* Register Address */
+#define	AR5K_PHY_RF_CTL2_TXF2TXD_START	0x0000000f	/* Mask for TX frame to TX d(esc?) start */
+
+#define AR5K_PHY_RF_CTL3		0x9828			/* Register Address */
+#define AR5K_PHY_RF_CTL3_TXE2XLNA_ON	0x0000000f	/* Mask for TX end to XLNA on */
+
+#define AR5K_PHY_RF_CTL4		0x9834			/* Register Address */
+#define AR5K_PHY_RF_CTL4_TXF2XPA_A_ON	0x00000001	/* TX frame to XPA A on (field) */
+#define AR5K_PHY_RF_CTL4_TXF2XPA_B_ON	0x00000100	/* TX frame to XPA B on (field) */
+#define	AR5K_PHY_RF_CTL4_TXE2XPA_A_OFF	0x00010000	/* TX end to XPA A off (field) */
+#define AR5K_PHY_RF_CTL4_TXE2XPA_B_OFF	0x01000000	/* TX end to XPA B off (field) */
+
+/*
+ * Pre-Amplifier control register
+ * (XPA -> external pre-amplifier)
+ */
+#define	AR5K_PHY_PA_CTL			0x9838			/* Register Address */
+#define	AR5K_PHY_PA_CTL_XPA_A_HI	0x00000001	/* XPA A high (?) */
+#define	AR5K_PHY_PA_CTL_XPA_B_HI	0x00000002	/* XPA B high (?) */
+#define	AR5K_PHY_PA_CTL_XPA_A_EN	0x00000004	/* Enable XPA A */
+#define	AR5K_PHY_PA_CTL_XPA_B_EN	0x00000008	/* Enable XPA B */
+
+/*
+ * PHY settling register
+ */
+#define AR5K_PHY_SETTLING		0x9844			/* Register Address */
+#define	AR5K_PHY_SETTLING_AGC		0x0000007f	/* Mask for AGC settling time */
+#define	AR5K_PHY_SETTLING_SWITCH	0x00003f80	/* Mask for Switch settlig time */
+
+/*
+ * PHY Gain registers
+ */
+#define AR5K_PHY_GAIN			0x9848			/* Register Address */
+#define	AR5K_PHY_GAIN_TXRX_ATTEN	0x0003f000	/* Mask for TX-RX Attenuation */
+
+#define	AR5K_PHY_GAIN_OFFSET		0x984c			/* Register Address */
+#define	AR5K_PHY_GAIN_OFFSET_RXTX_FLAG	0x00020000	/* RX-TX flag (?) */
+
+/*
+ * Desired size register
+ * (for more infos read ANI patent)
+ */
+#define AR5K_PHY_DESIRED_SIZE		0x9850			/* Register Address */
+#define	AR5K_PHY_DESIRED_SIZE_ADC	0x000000ff	/* Mask for ADC desired size */
+#define	AR5K_PHY_DESIRED_SIZE_PGA	0x0000ff00	/* Mask for PGA desired size */
+#define	AR5K_PHY_DESIRED_SIZE_TOT	0x0ff00000	/* Mask for Total desired size (?) */
 
 /*
  * PHY signal register
+ * (for more infos read ANI patent)
  */
-#define	AR5K_PHY_SIG			0x9858
-#define	AR5K_PHY_SIG_FIRSTEP		0x0003f000
+#define	AR5K_PHY_SIG			0x9858			/* Register Address */
+#define	AR5K_PHY_SIG_FIRSTEP		0x0003f000	/* Mask for FIRSTEP */
 #define	AR5K_PHY_SIG_FIRSTEP_S		12
-#define	AR5K_PHY_SIG_FIRPWR		0x03fc0000
+#define	AR5K_PHY_SIG_FIRPWR		0x03fc0000	/* Mask for FIPWR */
 #define	AR5K_PHY_SIG_FIRPWR_S		18
 
 /*
  * PHY coarse agility control register
+ * (for more infos read ANI patent)
  */
-#define	AR5K_PHY_AGCCOARSE		0x985c
-#define	AR5K_PHY_AGCCOARSE_LO		0x00007f80
+#define	AR5K_PHY_AGCCOARSE		0x985c			/* Register Address */
+#define	AR5K_PHY_AGCCOARSE_LO		0x00007f80	/* Mask for AGC Coarse low */
 #define	AR5K_PHY_AGCCOARSE_LO_S		7
-#define	AR5K_PHY_AGCCOARSE_HI		0x003f8000
+#define	AR5K_PHY_AGCCOARSE_HI		0x003f8000	/* Mask for AGC Coarse high */
 #define	AR5K_PHY_AGCCOARSE_HI_S		15
 
 /*
@@ -1689,12 +1988,13 @@
 /*
  * PHY noise floor status register
  */
-#define AR5K_PHY_NF			0x9864
-#define AR5K_PHY_NF_M			0x000001ff
-#define AR5K_PHY_NF_ACTIVE		0x00000100
+#define AR5K_PHY_NF			0x9864			/* Register address */
+#define AR5K_PHY_NF_M			0x000001ff	/* Noise floor mask */
+#define AR5K_PHY_NF_ACTIVE		0x00000100	/* Noise floor calibration still active */
 #define AR5K_PHY_NF_RVAL(_n)		(((_n) >> 19) & AR5K_PHY_NF_M)
 #define AR5K_PHY_NF_AVAL(_n)		(-((_n) ^ AR5K_PHY_NF_M) + 1)
 #define AR5K_PHY_NF_SVAL(_n)		(((_n) & AR5K_PHY_NF_M) | (1 << 9))
+#define	AR5K_PHY_NF_THRESH62		0x00001000	/* Thresh62 -check ANI patent- (field) */
 
 /*
  * PHY ADC saturation register [5110]
@@ -1706,6 +2006,30 @@
 #define	AR5K_PHY_ADCSAT_THR_S		5
 
 /*
+ * PHY Weak ofdm signal detection threshold registers (ANI) [5212+]
+ */
+
+/* High thresholds */
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR		0x9868
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR_M2_COUNT	0x0000001f
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR_M2_COUNT_S	0
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR_M1		0x00fe0000
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR_M1_S	17
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR_M2		0x7f000000
+#define AR5K_PHY_WEAK_OFDM_HIGH_THR_M2_S	24
+
+/* Low thresholds */
+#define AR5K_PHY_WEAK_OFDM_LOW_THR 		0x986c
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_SELFCOR_EN	0x00000001
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_M2_COUNT	0x00003f00
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_M2_COUNT_S	8
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_M1		0x001fc000
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_M1_S		14
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_M2		0x0fe00000
+#define AR5K_PHY_WEAK_OFDM_LOW_THR_M2_S		21
+
+
+/*
  * PHY sleep registers [5112+]
  */
 #define AR5K_PHY_SCR			0x9870
@@ -1730,6 +2054,8 @@
 					AR5K_PHY_PLL_44MHZ_5211 : AR5K_PHY_PLL_44MHZ_5212)
 #define AR5K_PHY_PLL_RF5111		0x00000000
 #define AR5K_PHY_PLL_RF5112		0x00000040
+#define	AR5K_PHY_PLL_HALF_RATE		0x00000100
+#define	AR5K_PHY_PLL_QUARTER_RATE	0x00000200
 
 /*
  * RF Buffer register
@@ -1792,23 +2118,74 @@
 #define AR5K_PHY_RFSTG_DISABLE		0x00000021
 
 /*
+ * PHY Antenna control register
+ */
+#define AR5K_PHY_ANT_CTL		0x9910			/* Register Address */
+#define	AR5K_PHY_ANT_CTL_TXRX_EN	0x00000001	/* Enable TX/RX (?) */
+#define	AR5K_PHY_ANT_CTL_SECTORED_ANT	0x00000004	/* Sectored Antenna */
+#define	AR5K_PHY_ANT_CTL_HITUNE5	0x00000008	/* Hitune5 (?) */
+#define	AR5K_PHY_ANT_CTL_SWTABLE_IDLE	0x00000010	/* Switch table idle (?) */
+
+/*
  * PHY receiver delay register [5111+]
  */
-#define	AR5K_PHY_RX_DELAY		0x9914
-#define	AR5K_PHY_RX_DELAY_M		0x00003fff
+#define	AR5K_PHY_RX_DELAY		0x9914			/* Register Address */
+#define	AR5K_PHY_RX_DELAY_M		0x00003fff	/* Mask for RX activate to receive delay (/100ns) */
+
+/*
+ * PHY max rx length register (?) [5111]
+ */
+#define	AR5K_PHY_MAX_RX_LEN		0x991c
 
 /*
- * PHY timing I(nphase) Q(adrature) control register [5111+]
+ * PHY timing register 4
+ * I(nphase)/Q(adrature) calibration register [5111+]
  */
-#define	AR5K_PHY_IQ			0x9920		/* Register address */
+#define	AR5K_PHY_IQ			0x9920			/* Register Address */
 #define	AR5K_PHY_IQ_CORR_Q_Q_COFF	0x0000001f	/* Mask for q correction info */
 #define	AR5K_PHY_IQ_CORR_Q_I_COFF	0x000007e0	/* Mask for i correction info */
 #define	AR5K_PHY_IQ_CORR_Q_I_COFF_S	5
 #define	AR5K_PHY_IQ_CORR_ENABLE		0x00000800	/* Enable i/q correction */
-#define	AR5K_PHY_IQ_CAL_NUM_LOG_MAX	0x0000f000
+#define	AR5K_PHY_IQ_CAL_NUM_LOG_MAX	0x0000f000	/* Mask for max number of samples in log scale */
 #define	AR5K_PHY_IQ_CAL_NUM_LOG_MAX_S	12
 #define	AR5K_PHY_IQ_RUN			0x00010000	/* Run i/q calibration */
+#define	AR5K_PHY_IQ_USE_PT_DF		0x00020000	/* Use pilot track df (?) */
+#define	AR5K_PHY_IQ_EARLY_TRIG_THR	0x00200000	/* Early trigger threshold (?) (field) */
+#define	AR5K_PHY_IQ_PILOT_MASK_EN	0x10000000	/* Enable pilot mask (?) */
+#define	AR5K_PHY_IQ_CHAN_MASK_EN	0x20000000	/* Enable channel mask (?) */
+#define	AR5K_PHY_IQ_SPUR_FILT_EN	0x40000000	/* Enable spur filter */
+#define	AR5K_PHY_IQ_SPUR_RSSI_EN	0x80000000	/* Enable spur rssi */
 
+/*
+ * PHY timing register 5
+ * OFDM Self-correlator Cyclic RSSI threshold params
+ * (Check out bb_cycpwr_thr1 on ANI patent)
+ */
+#define	AR5K_PHY_OFDM_SELFCORR			0x9924			/* Register Address */
+#define	AR5K_PHY_OFDM_SELFCORR_CYPWR_THR1_EN	0x00000001	/* Enable cyclic RSSI thr 1 */
+#define	AR5K_PHY_OFDM_SELFCORR_CYPWR_THR1	0x000000fe	/* Mask for Cyclic RSSI threshold 1 */
+#define	AR5K_PHY_OFDM_SELFCORR_CYPWR_THR3	0x00000100	/* Cyclic RSSI threshold 3 (field) (?) */
+#define	AR5K_PHY_OFDM_SELFCORR_RSSI_1ATHR_EN	0x00008000	/* Enable 1A RSSI threshold (?) */
+#define	AR5K_PHY_OFDM_SELFCORR_RSSI_1ATHR	0x00010000	/* 1A RSSI threshold (field) (?) */
+#define	AR5K_PHY_OFDM_SELFCORR_LSCTHR_HIRSSI	0x00800000	/* Long sc threshold hi rssi (?) */
+
+/*
+ * PHY-only warm reset register
+ */
+#define	AR5K_PHY_WARM_RESET		0x9928
+
+/*
+ * PHY-only control register
+ */
+#define AR5K_PHY_CTL			0x992c			/* Register Address */
+#define	AR5K_PHY_CTL_RX_DRAIN_RATE	0x00000001	/* RX drain rate (?) */
+#define	AR5K_PHY_CTL_LATE_TX_SIG_SYM	0x00000002	/* Late tx signal symbol (?) */
+#define	AR5K_PHY_CTL_GEN_SCRAMBLER	0x00000004	/* Generate scrambler */
+#define	AR5K_PHY_CTL_TX_ANT_SEL		0x00000008	/* TX antenna select */
+#define	AR5K_PHY_CTL_TX_ANT_STATIC	0x00000010	/* Static TX antenna */
+#define	AR5K_PHY_CTL_RX_ANT_SEL		0x00000020	/* RX antenna select */
+#define	AR5K_PHY_CTL_RX_ANT_STATIC	0x00000040	/* Static RX antenna */
+#define	AR5K_PHY_CTL_LOW_FREQ_SLE_EN	0x00000080	/* Enable low freq sleep */
 
 /*
  * PHY PAPD probe register [5111+ (?)]
@@ -1816,9 +2193,13 @@
  * Because it's always 0 in 5211 initialization code
  */
 #define	AR5K_PHY_PAPD_PROBE		0x9930
+#define	AR5K_PHY_PAPD_PROBE_SH_HI_PAR	0x00000001
+#define	AR5K_PHY_PAPD_PROBE_PCDAC_BIAS	0x00000002
+#define	AR5K_PHY_PAPD_PROBE_COMP_GAIN	0x00000040
 #define	AR5K_PHY_PAPD_PROBE_TXPOWER	0x00007e00
 #define	AR5K_PHY_PAPD_PROBE_TXPOWER_S	9
 #define	AR5K_PHY_PAPD_PROBE_TX_NEXT	0x00008000
+#define	AR5K_PHY_PAPD_PROBE_PREDIST_EN	0x00010000
 #define	AR5K_PHY_PAPD_PROBE_TYPE	0x01800000	/* [5112+] */
 #define	AR5K_PHY_PAPD_PROBE_TYPE_S	23
 #define	AR5K_PHY_PAPD_PROBE_TYPE_OFDM	0
@@ -1848,15 +2229,16 @@
 #define	AR5K_PHY_FRAME_CTL		(ah->ah_version == AR5K_AR5210 ? \
 					AR5K_PHY_FRAME_CTL_5210 : AR5K_PHY_FRAME_CTL_5211)
 /*---[5111+]---*/
-#define	AR5K_PHY_FRAME_CTL_TX_CLIP	0x00000038
+#define	AR5K_PHY_FRAME_CTL_TX_CLIP	0x00000038	/* Mask for tx clip (?) */
 #define	AR5K_PHY_FRAME_CTL_TX_CLIP_S	3
+#define	AR5K_PHY_FRAME_CTL_PREP_CHINFO	0x00010000	/* Prepend chan info */
 /*---[5110/5111]---*/
-#define	AR5K_PHY_FRAME_CTL_TIMING_ERR	0x01000000
-#define	AR5K_PHY_FRAME_CTL_PARITY_ERR	0x02000000
-#define	AR5K_PHY_FRAME_CTL_ILLRATE_ERR	0x04000000	/* illegal rate */
-#define	AR5K_PHY_FRAME_CTL_ILLLEN_ERR	0x08000000	/* illegal length */
+#define	AR5K_PHY_FRAME_CTL_TIMING_ERR	0x01000000	/* PHY timing error */
+#define	AR5K_PHY_FRAME_CTL_PARITY_ERR	0x02000000	/* Parity error */
+#define	AR5K_PHY_FRAME_CTL_ILLRATE_ERR	0x04000000	/* Illegal rate */
+#define	AR5K_PHY_FRAME_CTL_ILLLEN_ERR	0x08000000	/* Illegal length */
 #define	AR5K_PHY_FRAME_CTL_SERVICE_ERR	0x20000000
-#define	AR5K_PHY_FRAME_CTL_TXURN_ERR	0x40000000	/* tx underrun */
+#define	AR5K_PHY_FRAME_CTL_TXURN_ERR	0x40000000	/* TX underrun */
 #define AR5K_PHY_FRAME_CTL_INI		AR5K_PHY_FRAME_CTL_SERVICE_ERR | \
 			AR5K_PHY_FRAME_CTL_TXURN_ERR | \
 			AR5K_PHY_FRAME_CTL_ILLLEN_ERR | \
@@ -1915,6 +2297,11 @@ after DFS is enabled */
 #define AR5K_PHY_ANT_SWITCH_TABLE_1	0x9964
 
 /*
+ * PHY Noise floor threshold
+ */
+#define AR5K_PHY_NFTHRES		0x9968
+
+/*
  * PHY clock sleep registers [5112+]
  */
 #define AR5K_PHY_SCLOCK			0x99f0
@@ -1922,56 +2309,116 @@ after DFS is enabled */
 #define AR5K_PHY_SDELAY			0x99f4
 #define AR5K_PHY_SDELAY_32MHZ		0x000000ff
 #define AR5K_PHY_SPENDING		0x99f8
+#define	AR5K_PHY_SPENDING_14		0x00000014
+#define	AR5K_PHY_SPENDING_18		0x00000018
 #define AR5K_PHY_SPENDING_RF5111	0x00000018
-#define AR5K_PHY_SPENDING_RF5112	0x00000014 /* <- i 've only seen this on 2425 dumps ! */
-#define AR5K_PHY_SPENDING_RF5112A	0x0000000e /* but since i only have 5112A-based chips */
-#define AR5K_PHY_SPENDING_RF5424	0x00000012 /* to test it might be also for old 5112.  */
+#define AR5K_PHY_SPENDING_RF5112	0x00000014
+/* #define AR5K_PHY_SPENDING_RF5112A	0x0000000e */
+/* #define AR5K_PHY_SPENDING_RF5424	0x00000012 */
+#define	AR5K_PHY_SPENDING_RF5413	0x00000014
+#define	AR5K_PHY_SPENDING_RF2413	0x00000014
+#define AR5K_PHY_SPENDING_RF2425	0x00000018
 
 /*
  * Misc PHY/radio registers [5110 - 5111]
  */
-#define	AR5K_BB_GAIN_BASE		0x9b00 /* BaseBand Amplifier Gain table base address */
+#define	AR5K_BB_GAIN_BASE		0x9b00	/* BaseBand Amplifier Gain table base address */
 #define AR5K_BB_GAIN(_n)		(AR5K_BB_GAIN_BASE + ((_n) << 2))
-#define	AR5K_RF_GAIN_BASE		0x9a00 /* RF Amplrifier Gain table base address */
+#define	AR5K_RF_GAIN_BASE		0x9a00	/* RF Amplrifier Gain table base address */
 #define AR5K_RF_GAIN(_n)		(AR5K_RF_GAIN_BASE + ((_n) << 2))
 
 /*
  * PHY timing IQ calibration result register [5111+]
  */
-#define	AR5K_PHY_IQRES_CAL_PWR_I	0x9c10 /* I (Inphase) power value */
-#define	AR5K_PHY_IQRES_CAL_PWR_Q	0x9c14 /* Q (Quadrature) power value */
+#define	AR5K_PHY_IQRES_CAL_PWR_I	0x9c10	/* I (Inphase) power value */
+#define	AR5K_PHY_IQRES_CAL_PWR_Q	0x9c14	/* Q (Quadrature) power value */
 #define	AR5K_PHY_IQRES_CAL_CORR		0x9c18	/* I/Q Correlation */
 
 /*
  * PHY current RSSI register [5111+]
  */
-#define	AR5K_PHY_CURRENT_RSSI		0x9c1c
+#define	AR5K_PHY_CURRENT_RSSI	0x9c1c
+
+/*
+ * PHY RF Bus grant register (?)
+ */
+#define	AR5K_PHY_RFBUS_GRANT	0x9c20
+
+/*
+ * PHY ADC test register
+ */
+#define	AR5K_PHY_ADC_TEST	0x9c24
+#define	AR5K_PHY_ADC_TEST_I	0x00000001
+#define	AR5K_PHY_ADC_TEST_Q	0x00000200
+
+/*
+ * PHY DAC test register
+ */
+#define	AR5K_PHY_DAC_TEST	0x9c28
+#define	AR5K_PHY_DAC_TEST_I	0x00000001
+#define	AR5K_PHY_DAC_TEST_Q	0x00000200
+
+/*
+ * PHY PTAT register (?)
+ */
+#define	AR5K_PHY_PTAT		0x9c2c
+
+/*
+ * PHY Illegal TX rate register [5112+]
+ */
+#define	AR5K_PHY_BAD_TX_RATE	0x9c30
+
+/*
+ * PHY SPUR Power register [5112+]
+ */
+#define	AR5K_PHY_SPUR_PWR	0x9c34			/* Register Address */
+#define	AR5K_PHY_SPUR_PWR_I	0x00000001	/* SPUR Power estimate for I (field) */
+#define	AR5K_PHY_SPUR_PWR_Q	0x00000100	/* SPUR Power estimate for Q (field) */
+#define	AR5K_PHY_SPUR_PWR_FILT	0x00010000	/* Power with SPUR removed (field) */
+
+/*
+ * PHY Channel status register [5112+] (?)
+ */
+#define	AR5K_PHY_CHAN_STATUS		0x9c38
+#define	AR5K_PHY_CHAN_STATUS_BT_ACT	0x00000001
+#define	AR5K_PHY_CHAN_STATUS_RX_CLR_RAW	0x00000002
+#define	AR5K_PHY_CHAN_STATUS_RX_CLR_MAC	0x00000004
+#define	AR5K_PHY_CHAN_STATUS_RX_CLR_PAP	0x00000008
+
+/*
+ * PHY PAPD I (power?) table (?)
+ * (92! entries)
+ */
+#define	AR5K_PHY_PAPD_I_BASE	0xa000
+#define	AR5K_PHY_PAPD_I(_n)	(AR5K_PHY_PAPD_I_BASE + ((_n) << 2))
 
 /*
  * PHY PCDAC TX power table
  */
 #define	AR5K_PHY_PCDAC_TXPOWER_BASE_5211	0xa180
-#define AR5K_PHY_PCDAC_TXPOWER_BASE_5413	0xa280
-#define AR5K_PHY_PCDAC_TXPOWER_BASE	(ah->ah_radio >= AR5K_RF5413 ? \
-					AR5K_PHY_PCDAC_TXPOWER_BASE_5413 :\
+#define AR5K_PHY_PCDAC_TXPOWER_BASE_2413	0xa280
+#define AR5K_PHY_PCDAC_TXPOWER_BASE	(ah->ah_radio >= AR5K_RF2413 ? \
+					AR5K_PHY_PCDAC_TXPOWER_BASE_2413 :\
 					AR5K_PHY_PCDAC_TXPOWER_BASE_5211)
 #define	AR5K_PHY_PCDAC_TXPOWER(_n)	(AR5K_PHY_PCDAC_TXPOWER_BASE + ((_n) << 2))
 
 /*
  * PHY mode register [5111+]
  */
-#define	AR5K_PHY_MODE			0x0a200		/* Register address */
-#define	AR5K_PHY_MODE_MOD		0x00000001	/* PHY Modulation mask*/
+#define	AR5K_PHY_MODE			0x0a200			/* Register Address */
+#define	AR5K_PHY_MODE_MOD		0x00000001	/* PHY Modulation bit */
 #define AR5K_PHY_MODE_MOD_OFDM		0
 #define AR5K_PHY_MODE_MOD_CCK		1
-#define AR5K_PHY_MODE_FREQ		0x00000002	/* Freq mode mask */
+#define AR5K_PHY_MODE_FREQ		0x00000002	/* Freq mode bit */
 #define	AR5K_PHY_MODE_FREQ_5GHZ		0
 #define	AR5K_PHY_MODE_FREQ_2GHZ		2
-#define AR5K_PHY_MODE_MOD_DYN		0x00000004	/* Dynamic OFDM/CCK mode mask [5112+] */
+#define AR5K_PHY_MODE_MOD_DYN		0x00000004	/* Enable Dynamic OFDM/CCK mode [5112+] */
 #define AR5K_PHY_MODE_RAD		0x00000008	/* [5212+] */
 #define AR5K_PHY_MODE_RAD_RF5111	0
 #define AR5K_PHY_MODE_RAD_RF5112	8
-#define AR5K_PHY_MODE_XR		0x00000010	/* [5112+] */
+#define AR5K_PHY_MODE_XR		0x00000010	/* Enable XR mode [5112+] */
+#define	AR5K_PHY_MODE_HALF_RATE		0x00000020	/* Enable Half rate (test) */
+#define	AR5K_PHY_MODE_QUARTER_RATE	0x00000040	/* Enable Quarter rat (test) */
 
 /*
  * PHY CCK transmit control register [5111+ (?)]
@@ -1979,6 +2426,15 @@ after DFS is enabled */
 #define AR5K_PHY_CCKTXCTL		0xa204
 #define AR5K_PHY_CCKTXCTL_WORLD		0x00000000
 #define AR5K_PHY_CCKTXCTL_JAPAN		0x00000010
+#define	AR5K_PHY_CCKTXCTL_SCRAMBLER_DIS	0x00000001
+#define	AR5K_PHY_CCKTXCTK_DAC_SCALE	0x00000004
+
+/*
+ * PHY CCK Cross-correlator Barker RSSI threshold register [5212+]
+ */
+#define AR5K_PHY_CCK_CROSSCORR			0xa208
+#define AR5K_PHY_CCK_CROSSCORR_WEAK_SIG_THR	0x0000000f
+#define AR5K_PHY_CCK_CROSSCORR_WEAK_SIG_THR_S	0
 
 /*
  * PHY 2GHz gain register [5111+]
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 1acfbcd..9509fd2 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -305,9 +305,10 @@ static inline void ipw_write_reg32(struct ipw_priv *a, u32 b, u32 c)
 #define _ipw_write8(ipw, ofs, val) writeb((val), (ipw)->hw_base + (ofs))
 
 /* 8-bit direct write (for low 4K of SRAM/regs), with debug wrapper */
-#define ipw_write8(ipw, ofs, val) \
+#define ipw_write8(ipw, ofs, val) do { \
  IPW_DEBUG_IO("%s %d: write_direct8(0x%08X, 0x%08X)\n", __FILE__, __LINE__, (u32)(ofs), (u32)(val)); \
- _ipw_write8(ipw, ofs, val)
+ _ipw_write8(ipw, ofs, val); \
+ } while (0)
 
 /* 16-bit direct write (low 4K) */
 #define _ipw_write16(ipw, ofs, val) writew((val), (ipw)->hw_base + (ofs))
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index a51e0ea..56a9361 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -710,10 +710,7 @@ static void iwl3945_rx_reply_rx(struct iwl3945_priv *priv,
 		return;
 	}
 
-	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR) {
-		iwl3945_pass_packet_to_mac80211(priv, rxb, &rx_status);
-		return;
-	}
+
 
 	/* Convert 3945's rssi indicator to dBm */
 	rx_status.signal = rx_stats->rssi - IWL_RSSI_OFFSET;
@@ -775,6 +772,11 @@ static void iwl3945_rx_reply_rx(struct iwl3945_priv *priv,
 		priv->last_rx_noise = rx_status.noise;
 	}
 
+	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR) {
+		iwl3945_pass_packet_to_mac80211(priv, rxb, &rx_status);
+		return;
+	}
+
 	switch (le16_to_cpu(header->frame_control) & IEEE80211_FCTL_FTYPE) {
 	case IEEE80211_FTYPE_MGMT:
 		switch (le16_to_cpu(header->frame_control) &
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index f72cd0b..0182e4d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -962,16 +962,16 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	if (ret)
 		return ret;
 
-	if ((iwl_queue_space(q) < q->high_mark)
-	    && priv->mac80211_registered) {
+	if ((iwl_queue_space(q) < q->high_mark) && priv->mac80211_registered) {
 		if (wait_write_ptr) {
 			spin_lock_irqsave(&priv->lock, flags);
 			txq->need_update = 1;
 			iwl_txq_update_write_ptr(priv, txq);
 			spin_unlock_irqrestore(&priv->lock, flags);
+		} else {
+			ieee80211_stop_queue(priv->hw,
+					     skb_get_queue_mapping(skb));
 		}
-
-		ieee80211_stop_queue(priv->hw, skb_get_queue_mapping(skb));
 	}
 
 	return 0;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 14d5d61..bd32ac0 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -297,9 +297,7 @@ static ssize_t lbs_rtap_set(struct device *dev,
 			lbs_add_rtap(priv);
 		}
 		priv->monitormode = monitor_mode;
-	}
-
-	else {
+	} else {
 		if (!priv->monitormode)
 			return strlen(buf);
 		priv->monitormode = 0;
@@ -1242,8 +1240,6 @@ int lbs_start_card(struct lbs_private *priv)
 		lbs_pr_err("cannot register ethX device\n");
 		goto done;
 	}
-	if (device_create_file(&dev->dev, &dev_attr_lbs_rtap))
-		lbs_pr_err("cannot register lbs_rtap attribute\n");
 
 	lbs_update_channel(priv);
 
@@ -1275,6 +1271,13 @@ int lbs_start_card(struct lbs_private *priv)
 
 			if (device_create_file(&dev->dev, &dev_attr_lbs_mesh))
 				lbs_pr_err("cannot register lbs_mesh attribute\n");
+
+			/* While rtap isn't related to mesh, only mesh-enabled
+			 * firmware implements the rtap functionality via
+			 * CMD_802_11_MONITOR_MODE.
+			 */
+			if (device_create_file(&dev->dev, &dev_attr_lbs_rtap))
+				lbs_pr_err("cannot register lbs_rtap attribute\n");
 		}
 	}
 
@@ -1306,9 +1309,9 @@ void lbs_stop_card(struct lbs_private *priv)
 	netif_carrier_off(priv->dev);
 
 	lbs_debugfs_remove_one(priv);
-	device_remove_file(&dev->dev, &dev_attr_lbs_rtap);
 	if (priv->mesh_tlv) {
 		device_remove_file(&dev->dev, &dev_attr_lbs_mesh);
+		device_remove_file(&dev->dev, &dev_attr_lbs_rtap);
 	}
 
 	/* Flush pending command nodes */
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 97fa14e..3d75a71 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -2518,7 +2518,7 @@ enum {
 
 #define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024
 #define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
-((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
+	offsetof(struct prism2_hostapd_param, u.generic_elem.data)
 
 /* Maximum length for algorithm names (-1 for nul termination)
  * used in ioctl() */
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index aa6dfb8..181a146 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1220,6 +1220,7 @@ static void rt2500pci_write_tx_desc(struct rt2x00_dev *rt2x00dev,
 	rt2x00_set_field32(&word, TXD_W0_IFS, txdesc->ifs);
 	rt2x00_set_field32(&word, TXD_W0_RETRY_MODE,
 			   test_bit(ENTRY_TXD_RETRY_MODE, &txdesc->flags));
+	rt2x00_set_field32(&word, TXD_W0_DATABYTE_COUNT, skb->len);
 	rt2x00_set_field32(&word, TXD_W0_CIPHER_ALG, CIPHER_NONE);
 	rt2x00_desc_write(txd, 0, word);
 }
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 3078417..c6f6eb6 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1376,6 +1376,9 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_VGCLOWER, bbp);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_VGC, word);
 		EEPROM(rt2x00dev, "BBPtune vgc: 0x%04x\n", word);
+	} else {
+		rt2x00_set_field16(&word, EEPROM_BBPTUNE_VGCLOWER, bbp);
+		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_VGC, word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_BBPTUNE_R17, &word);
@@ -1384,9 +1387,6 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R17_HIGH, 0x41);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_R17, word);
 		EEPROM(rt2x00dev, "BBPtune r17: 0x%04x\n", word);
-	} else {
-		rt2x00_set_field16(&word, EEPROM_BBPTUNE_VGCLOWER, bbp);
-		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_VGC, word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_BBPTUNE_R24, &word);
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index db2dc97..8b10ea4 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -368,6 +368,12 @@ struct rt2x00_intf {
 #define DELAYED_CONFIG_ERP		0x00000002
 #define DELAYED_LED_ASSOC		0x00000004
 
+	/*
+	 * Software sequence counter, this is only required
+	 * for hardware which doesn't support hardware
+	 * sequence counting.
+	 */
+	spinlock_t seqlock;
 	u16 seqno;
 };
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/rt2x00/rt2x00config.c
index 3f89516..d134c3b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00config.c
+++ b/drivers/net/wireless/rt2x00/rt2x00config.c
@@ -254,6 +254,8 @@ config:
 			libconf.ant.rx = default_ant->rx;
 		else if (active_ant->rx == ANTENNA_SW_DIVERSITY)
 			libconf.ant.rx = ANTENNA_B;
+		else
+			libconf.ant.rx = active_ant->rx;
 
 		if (conf->antenna_sel_tx)
 			libconf.ant.tx = conf->antenna_sel_tx;
@@ -261,6 +263,8 @@ config:
 			libconf.ant.tx = default_ant->tx;
 		else if (active_ant->tx == ANTENNA_SW_DIVERSITY)
 			libconf.ant.tx = ANTENNA_B;
+		else
+			libconf.ant.tx = active_ant->tx;
 	}
 
 	if (flags & CONFIG_UPDATE_SLOT_TIME) {
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index 300cf06..6bee1d6 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -372,9 +372,6 @@ static ssize_t rt2x00debug_write_##__name(struct file *file,	\
 	if (*offset)						\
 		return 0;					\
 								\
-	if (!capable(CAP_NET_ADMIN))				\
-		return -EPERM;					\
-								\
 	if (intf->offset_##__name >= debug->__name.word_count)	\
 		return -EINVAL;					\
 								\
@@ -454,7 +451,7 @@ static struct dentry *rt2x00debug_create_file_driver(const char *name,
 	data += sprintf(data, "compiled: %s %s\n", __DATE__, __TIME__);
 	blob->size = strlen(blob->data);
 
-	return debugfs_create_blob(name, S_IRUGO, intf->driver_folder, blob);
+	return debugfs_create_blob(name, S_IRUSR, intf->driver_folder, blob);
 }
 
 static struct dentry *rt2x00debug_create_file_chipset(const char *name,
@@ -482,7 +479,7 @@ static struct dentry *rt2x00debug_create_file_chipset(const char *name,
 	data += sprintf(data, "rf length: %d\n", debug->rf.word_count);
 	blob->size = strlen(blob->data);
 
-	return debugfs_create_blob(name, S_IRUGO, intf->driver_folder, blob);
+	return debugfs_create_blob(name, S_IRUSR, intf->driver_folder, blob);
 }
 
 void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
@@ -517,7 +514,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 	if (IS_ERR(intf->chipset_entry))
 		goto exit;
 
-	intf->dev_flags = debugfs_create_file("dev_flags", S_IRUGO,
+	intf->dev_flags = debugfs_create_file("dev_flags", S_IRUSR,
 					      intf->driver_folder, intf,
 					      &rt2x00debug_fop_dev_flags);
 	if (IS_ERR(intf->dev_flags))
@@ -532,7 +529,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 ({								\
 	(__intf)->__name##_off_entry =				\
 	    debugfs_create_u32(__stringify(__name) "_offset",	\
-			       S_IRUGO | S_IWUSR,		\
+			       S_IRUSR | S_IWUSR,		\
 			       (__intf)->register_folder,	\
 			       &(__intf)->offset_##__name);	\
 	if (IS_ERR((__intf)->__name##_off_entry))		\
@@ -540,7 +537,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 								\
 	(__intf)->__name##_val_entry =				\
 	    debugfs_create_file(__stringify(__name) "_value",	\
-				S_IRUGO | S_IWUSR,		\
+				S_IRUSR | S_IWUSR,		\
 				(__intf)->register_folder,	\
 				(__intf), &rt2x00debug_fop_##__name);\
 	if (IS_ERR((__intf)->__name##_val_entry))		\
@@ -560,7 +557,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 		goto exit;
 
 	intf->queue_frame_dump_entry =
-	    debugfs_create_file("dump", S_IRUGO, intf->queue_folder,
+	    debugfs_create_file("dump", S_IRUSR, intf->queue_folder,
 				intf, &rt2x00debug_fop_queue_dump);
 	if (IS_ERR(intf->queue_frame_dump_entry))
 		goto exit;
@@ -569,7 +566,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 	init_waitqueue_head(&intf->frame_dump_waitqueue);
 
 	intf->queue_stats_entry =
-	    debugfs_create_file("queue", S_IRUGO, intf->queue_folder,
+	    debugfs_create_file("queue", S_IRUSR, intf->queue_folder,
 				intf, &rt2x00debug_fop_queue_stats);
 
 	return;
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index c3ee4ec..bd422fd 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -247,6 +247,7 @@ int rt2x00mac_add_interface(struct ieee80211_hw *hw,
 		rt2x00dev->intf_sta_count++;
 
 	spin_lock_init(&intf->lock);
+	spin_lock_init(&intf->seqlock);
 	intf->beacon = entry;
 
 	if (conf->type == IEEE80211_IF_TYPE_AP)
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 3b27f6a..898cdd7 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -128,6 +128,7 @@ static void rt2x00queue_create_tx_descriptor(struct queue_entry *entry,
 	unsigned int data_length;
 	unsigned int duration;
 	unsigned int residual;
+	unsigned long irqflags;
 
 	memset(txdesc, 0, sizeof(*txdesc));
 
@@ -213,14 +214,14 @@ static void rt2x00queue_create_tx_descriptor(struct queue_entry *entry,
 	 * sequence counter given by mac80211.
 	 */
 	if (tx_info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
-		spin_lock(&intf->lock);
+		spin_lock_irqsave(&intf->seqlock, irqflags);
 
 		if (test_bit(ENTRY_TXD_FIRST_FRAGMENT, &txdesc->flags))
 			intf->seqno += 0x10;
 		hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
 		hdr->seq_ctrl |= cpu_to_le16(intf->seqno);
 
-		spin_unlock(&intf->lock);
+		spin_unlock_irqrestore(&intf->seqlock, irqflags);
 
 		__set_bit(ENTRY_TXD_GENERATE_SEQ, &txdesc->flags);
 	}
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index fbe2a65..087e90b 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1004,6 +1004,11 @@ static int rt61pci_load_firmware(struct rt2x00_dev *rt2x00dev, const void *data,
 	}
 
 	/*
+	 * Hardware needs another millisecond before it is ready.
+	 */
+	msleep(1);
+
+	/*
 	 * Reset MAC and BBP registers.
 	 */
 	reg = 0;
diff --git a/drivers/net/wireless/rtl8187.h b/drivers/net/wireless/rtl8187.h
index 1b0d750..5a9515c 100644
--- a/drivers/net/wireless/rtl8187.h
+++ b/drivers/net/wireless/rtl8187.h
@@ -94,6 +94,10 @@ struct rtl8187_priv {
 	const struct rtl818x_rf_ops *rf;
 	struct ieee80211_vif *vif;
 	int mode;
+	/* The mutex protects the TX loopback state.
+	 * Any attempt to set channels concurrently locks the device.
+	 */
+	struct mutex conf_mutex;
 
 	/* rtl8187 specific */
 	struct ieee80211_channel channels[14];
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index 177988e..57376fb 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -31,6 +31,8 @@ MODULE_DESCRIPTION("RTL8187/RTL8187B USB wireless driver");
 MODULE_LICENSE("GPL");
 
 static struct usb_device_id rtl8187_table[] __devinitdata = {
+	/* Asus */
+	{USB_DEVICE(0x0b05, 0x171d), .driver_info = DEVICE_RTL8187},
 	/* Realtek */
 	{USB_DEVICE(0x0bda, 0x8187), .driver_info = DEVICE_RTL8187},
 	{USB_DEVICE(0x0bda, 0x8189), .driver_info = DEVICE_RTL8187B},
@@ -726,6 +728,7 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 	if (ret)
 		return ret;
 
+	mutex_lock(&priv->conf_mutex);
 	if (priv->is_rtl8187b) {
 		reg = RTL818X_RX_CONF_MGMT |
 		      RTL818X_RX_CONF_DATA |
@@ -747,6 +750,7 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 				  (7 << 0  /* long retry limit */) |
 				  (7 << 21 /* MAX TX DMA */));
 		rtl8187_init_urbs(dev);
+		mutex_unlock(&priv->conf_mutex);
 		return 0;
 	}
 
@@ -790,6 +794,7 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 	reg |= RTL818X_CMD_TX_ENABLE;
 	reg |= RTL818X_CMD_RX_ENABLE;
 	rtl818x_iowrite8(priv, &priv->map->CMD, reg);
+	mutex_unlock(&priv->conf_mutex);
 
 	return 0;
 }
@@ -801,6 +806,7 @@ static void rtl8187_stop(struct ieee80211_hw *dev)
 	struct sk_buff *skb;
 	u32 reg;
 
+	mutex_lock(&priv->conf_mutex);
 	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
 
 	reg = rtl818x_ioread8(priv, &priv->map->CMD);
@@ -820,7 +826,7 @@ static void rtl8187_stop(struct ieee80211_hw *dev)
 		usb_kill_urb(info->urb);
 		kfree_skb(skb);
 	}
-	return;
+	mutex_unlock(&priv->conf_mutex);
 }
 
 static int rtl8187_add_interface(struct ieee80211_hw *dev,
@@ -840,6 +846,7 @@ static int rtl8187_add_interface(struct ieee80211_hw *dev,
 		return -EOPNOTSUPP;
 	}
 
+	mutex_lock(&priv->conf_mutex);
 	priv->vif = conf->vif;
 
 	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
@@ -848,6 +855,7 @@ static int rtl8187_add_interface(struct ieee80211_hw *dev,
 				 ((u8 *)conf->mac_addr)[i]);
 	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_NORMAL);
 
+	mutex_unlock(&priv->conf_mutex);
 	return 0;
 }
 
@@ -855,8 +863,10 @@ static void rtl8187_remove_interface(struct ieee80211_hw *dev,
 				     struct ieee80211_if_init_conf *conf)
 {
 	struct rtl8187_priv *priv = dev->priv;
+	mutex_lock(&priv->conf_mutex);
 	priv->mode = IEEE80211_IF_TYPE_MNTR;
 	priv->vif = NULL;
+	mutex_unlock(&priv->conf_mutex);
 }
 
 static int rtl8187_config(struct ieee80211_hw *dev, struct ieee80211_conf *conf)
@@ -864,6 +874,7 @@ static int rtl8187_config(struct ieee80211_hw *dev, struct ieee80211_conf *conf)
 	struct rtl8187_priv *priv = dev->priv;
 	u32 reg;
 
+	mutex_lock(&priv->conf_mutex);
 	reg = rtl818x_ioread32(priv, &priv->map->TX_CONF);
 	/* Enable TX loopback on MAC level to avoid TX during channel
 	 * changes, as this has be seen to causes problems and the
@@ -896,6 +907,7 @@ static int rtl8187_config(struct ieee80211_hw *dev, struct ieee80211_conf *conf)
 	rtl818x_iowrite16(priv, &priv->map->ATIMTR_INTERVAL, 100);
 	rtl818x_iowrite16(priv, &priv->map->BEACON_INTERVAL, 100);
 	rtl818x_iowrite16(priv, &priv->map->BEACON_INTERVAL_TIME, 100);
+	mutex_unlock(&priv->conf_mutex);
 	return 0;
 }
 
@@ -907,6 +919,7 @@ static int rtl8187_config_interface(struct ieee80211_hw *dev,
 	int i;
 	u8 reg;
 
+	mutex_lock(&priv->conf_mutex);
 	for (i = 0; i < ETH_ALEN; i++)
 		rtl818x_iowrite8(priv, &priv->map->BSSID[i], conf->bssid[i]);
 
@@ -920,6 +933,7 @@ static int rtl8187_config_interface(struct ieee80211_hw *dev,
 		rtl818x_iowrite8(priv, &priv->map->MSR, reg);
 	}
 
+	mutex_unlock(&priv->conf_mutex);
 	return 0;
 }
 
@@ -1187,6 +1201,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 		printk(KERN_ERR "rtl8187: Cannot register device\n");
 		goto err_free_dev;
 	}
+	mutex_init(&priv->conf_mutex);
 
 	printk(KERN_INFO "%s: hwaddr %s, %s V%d + %s\n",
 	       wiphy_name(dev->wiphy), print_mac(mac, dev->wiphy->perm_addr),
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index a4f9a83..a2e200f 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -586,6 +586,7 @@ struct ieee80211_local {
 	struct timer_list sta_cleanup;
 
 	unsigned long queues_pending[BITS_TO_LONGS(IEEE80211_MAX_QUEUES)];
+	unsigned long queues_pending_run[BITS_TO_LONGS(IEEE80211_MAX_QUEUES)];
 	struct ieee80211_tx_stored_packet pending_packet[IEEE80211_MAX_QUEUES];
 	struct tasklet_struct tx_pending_tasklet;
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 69019e9..771ec68 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1060,13 +1060,14 @@ static int ieee80211_tx_prepare(struct ieee80211_tx_data *tx,
 static int __ieee80211_tx(struct ieee80211_local *local, struct sk_buff *skb,
 			  struct ieee80211_tx_data *tx)
 {
-	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct ieee80211_tx_info *info;
 	int ret, i;
 
-	if (netif_subqueue_stopped(local->mdev, skb))
-		return IEEE80211_TX_AGAIN;
-
 	if (skb) {
+		if (netif_subqueue_stopped(local->mdev, skb))
+			return IEEE80211_TX_AGAIN;
+		info =  IEEE80211_SKB_CB(skb);
+
 		ieee80211_dump_frame(wiphy_name(local->hw.wiphy),
 				     "TX to low-level driver", skb);
 		ret = local->ops->tx(local_to_hw(local), skb);
@@ -1215,6 +1216,7 @@ retry:
 
 		if (ret == IEEE80211_TX_FRAG_AGAIN)
 			skb = NULL;
+
 		set_bit(queue, local->queues_pending);
 		smp_mb();
 		/*
@@ -1708,14 +1710,19 @@ void ieee80211_tx_pending(unsigned long data)
 	netif_tx_lock_bh(dev);
 	for (i = 0; i < ieee80211_num_regular_queues(&local->hw); i++) {
 		/* Check that this queue is ok */
-		if (__netif_subqueue_stopped(local->mdev, i))
+		if (__netif_subqueue_stopped(local->mdev, i) &&
+		    !test_bit(i, local->queues_pending_run))
 			continue;
 
 		if (!test_bit(i, local->queues_pending)) {
+			clear_bit(i, local->queues_pending_run);
 			ieee80211_wake_queue(&local->hw, i);
 			continue;
 		}
 
+		clear_bit(i, local->queues_pending_run);
+		netif_start_subqueue(local->mdev, i);
+
 		store = &local->pending_packet[i];
 		tx.extra_frag = store->extra_frag;
 		tx.num_extra_frag = store->num_extra_frag;
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 19f85e1..0d463c8 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -361,6 +361,7 @@ void ieee80211_wake_queue(struct ieee80211_hw *hw, int queue)
 	struct ieee80211_local *local = hw_to_local(hw);
 
 	if (test_bit(queue, local->queues_pending)) {
+		set_bit(queue, local->queues_pending_run);
 		tasklet_schedule(&local->tx_pending_tasklet);
 	} else {
 		netif_wake_subqueue(local->mdev, queue);
diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index 8aa8227..e5b6955 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -109,6 +109,25 @@ static DEFINE_RFKILL_TASK(rfkill_uwb, RFKILL_TYPE_UWB);
 static DEFINE_RFKILL_TASK(rfkill_wimax, RFKILL_TYPE_WIMAX);
 static DEFINE_RFKILL_TASK(rfkill_wwan, RFKILL_TYPE_WWAN);
 
+static void rfkill_schedule_evsw_rfkillall(int state)
+{
+	/* EVERY radio type. state != 0 means radios ON */
+	/* handle EPO (emergency power off) through shortcut */
+	if (state) {
+		rfkill_schedule_set(&rfkill_wwan,
+				    RFKILL_STATE_UNBLOCKED);
+		rfkill_schedule_set(&rfkill_wimax,
+				    RFKILL_STATE_UNBLOCKED);
+		rfkill_schedule_set(&rfkill_uwb,
+				    RFKILL_STATE_UNBLOCKED);
+		rfkill_schedule_set(&rfkill_bt,
+				    RFKILL_STATE_UNBLOCKED);
+		rfkill_schedule_set(&rfkill_wlan,
+				    RFKILL_STATE_UNBLOCKED);
+	} else
+		rfkill_schedule_epo();
+}
+
 static void rfkill_event(struct input_handle *handle, unsigned int type,
 			unsigned int code, int data)
 {
@@ -132,21 +151,7 @@ static void rfkill_event(struct input_handle *handle, unsigned int type,
 	} else if (type == EV_SW) {
 		switch (code) {
 		case SW_RFKILL_ALL:
-			/* EVERY radio type. data != 0 means radios ON */
-			/* handle EPO (emergency power off) through shortcut */
-			if (data) {
-				rfkill_schedule_set(&rfkill_wwan,
-						    RFKILL_STATE_UNBLOCKED);
-				rfkill_schedule_set(&rfkill_wimax,
-						    RFKILL_STATE_UNBLOCKED);
-				rfkill_schedule_set(&rfkill_uwb,
-						    RFKILL_STATE_UNBLOCKED);
-				rfkill_schedule_set(&rfkill_bt,
-						    RFKILL_STATE_UNBLOCKED);
-				rfkill_schedule_set(&rfkill_wlan,
-						    RFKILL_STATE_UNBLOCKED);
-			} else
-				rfkill_schedule_epo();
+			rfkill_schedule_evsw_rfkillall(data);
 			break;
 		default:
 			break;
@@ -168,6 +173,7 @@ static int rfkill_connect(struct input_handler *handler, struct input_dev *dev,
 	handle->handler = handler;
 	handle->name = "rfkill";
 
+	/* causes rfkill_start() to be called */
 	error = input_register_handle(handle);
 	if (error)
 		goto err_free_handle;
@@ -185,6 +191,23 @@ static int rfkill_connect(struct input_handler *handler, struct input_dev *dev,
 	return error;
 }
 
+static void rfkill_start(struct input_handle *handle)
+{
+	/* Take event_lock to guard against configuration changes, we
+	 * should be able to deal with concurrency with rfkill_event()
+	 * just fine (which event_lock will also avoid). */
+	spin_lock_irq(&handle->dev->event_lock);
+
+	if (test_bit(EV_SW, handle->dev->evbit)) {
+		if (test_bit(SW_RFKILL_ALL, handle->dev->swbit))
+			rfkill_schedule_evsw_rfkillall(test_bit(SW_RFKILL_ALL,
+							handle->dev->sw));
+		/* add resync for further EV_SW events here */
+	}
+
+	spin_unlock_irq(&handle->dev->event_lock);
+}
+
 static void rfkill_disconnect(struct input_handle *handle)
 {
 	input_close_device(handle);
@@ -225,6 +248,7 @@ static struct input_handler rfkill_handler = {
 	.event =	rfkill_event,
 	.connect =	rfkill_connect,
 	.disconnect =	rfkill_disconnect,
+	.start =	rfkill_start,
 	.name =		"rfkill",
 	.id_table =	rfkill_ids,
 };
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index c6f2f38..d2d4565 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -105,6 +105,16 @@ static void rfkill_led_trigger(struct rfkill *rfkill,
 #endif /* CONFIG_RFKILL_LEDS */
 }
 
+#ifdef CONFIG_RFKILL_LEDS
+static void rfkill_led_trigger_activate(struct led_classdev *led)
+{
+	struct rfkill *rfkill = container_of(led->trigger,
+			struct rfkill, led_trigger);
+
+	rfkill_led_trigger(rfkill, rfkill->state);
+}
+#endif /* CONFIG_RFKILL_LEDS */
+
 static void notify_rfkill_state_change(struct rfkill *rfkill)
 {
 	blocking_notifier_call_chain(&rfkill_notifier_list,
@@ -589,7 +599,10 @@ static void rfkill_led_trigger_register(struct rfkill *rfkill)
 #ifdef CONFIG_RFKILL_LEDS
 	int error;
 
-	rfkill->led_trigger.name = rfkill->dev.bus_id;
+	if (!rfkill->led_trigger.name)
+		rfkill->led_trigger.name = rfkill->dev.bus_id;
+	if (!rfkill->led_trigger.activate)
+		rfkill->led_trigger.activate = rfkill_led_trigger_activate;
 	error = led_trigger_register(&rfkill->led_trigger);
 	if (error)
 		rfkill->led_trigger.name = NULL;
-- 
John W. Linville
linville@tuxdriver.com
