From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/4] Net: ath5k, initial write cleanup
Date: Sat, 25 Aug 2007 03:58:07 -0400
Message-ID: <22354126342082518046@pripojeni.net>
References: <149438602455517207@pripojeni.net>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <149438602455517207-+5AFNAhbZwkm4RdzfppkhA@public.gmane.org>
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ath5k, initial write cleanup

The final step of initial writing cleanup. ar5211_rf is going away.

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

---
commit 0aebc8bb5574b6b0cc8f9f0d73672c1bee5cbfbb
tree a9a5e6bb4fa99b82fc345f8f52d2d202ddcec06b
parent 06615d9cdf1ae777821dfcd7845c72c38ff14ffa
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sat, 25 Aug 2007 09:22:49 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sat, 25 Aug 2007 09:22:49 +0200

 drivers/net/wireless/ath5k.h    |    1 
 drivers/net/wireless/ath5k_hw.c |  327 +++++++--------
 drivers/net/wireless/ath5k_hw.h |  849 ++++++++++++++++++---------------------
 3 files changed, 540 insertions(+), 637 deletions(-)

diff --git a/drivers/net/wireless/ath5k.h b/drivers/net/wireless/ath5k.h
index 2913a0a..c70cd30 100644
--- a/drivers/net/wireless/ath5k.h
+++ b/drivers/net/wireless/ath5k.h
@@ -1036,7 +1036,6 @@ int ath5k_hw_phy_calibrate(struct ath_hw *hal, struct ieee80211_channel *channel
 bool ath5k_hw_phy_disable(struct ath_hw *hal);
 void ath5k_hw_set_def_antenna(struct ath_hw *hal, unsigned int ant);
 unsigned int ath5k_hw_get_def_antenna(struct ath_hw *hal);
-bool ath5k_hw_rfgain(struct ath_hw *hal, unsigned int phy, u_int freq);
 enum ath5k_rfgain ath5k_hw_get_rf_gain(struct ath_hw *hal);
 /* Misc functions */
 int ath5k_hw_set_txpower_limit(struct ath_hw *hal, unsigned int power);
diff --git a/drivers/net/wireless/ath5k_hw.c b/drivers/net/wireless/ath5k_hw.c
index 4375129..887213d 100644
--- a/drivers/net/wireless/ath5k_hw.c
+++ b/drivers/net/wireless/ath5k_hw.c
@@ -70,40 +70,43 @@ static int ath5k_hw_rf5111_rfregs(struct ath_hw *, struct ieee80211_channel *,
 		unsigned int);
 static int ath5k_hw_rf5112_rfregs(struct ath_hw *, struct ieee80211_channel *,
 		unsigned int);
-static void ath5k_hw_ar5211_rfregs(struct ath_hw *, struct ieee80211_channel *,
-		unsigned int, unsigned int);
+static int ath5k_hw_rfgain(struct ath_hw *, unsigned int);
 
 /*
  * Initial register dumps
  */
+
+/*
+ * MAC/PHY Settings
+ */
+/* Common for all modes */
 static const struct ath5k_ini ar5210_ini[] = AR5K_AR5210_INI;
 static const struct ath5k_ini ar5211_ini[] = AR5K_AR5211_INI;
 static const struct ath5k_ini ar5212_ini[] = AR5K_AR5212_INI;
-static const struct ath5k_ar5211_ini_mode ar5211_mode[] = AR5K_AR5211_INI_MODE;
-static const struct ath5k_ar5212_ini_mode ar5212_mode[] = AR5K_AR5212_INI_MODE;
 
-/* RF Initial BB gain settings */
-static const struct ath5k_ini rf5111_bbgain_ini[] = AR5K_RF5111_BBGAIN_INI;
-static const struct ath5k_ini rf5112_bbgain_ini[] = AR5K_RF5112_BBGAIN_INI;
-
-/* This is going out soon */
-static const struct ath5k_ar5211_ini_rf ar5211_rf[] = AR5K_AR5211_INI_RF;
+/* Mode-specific settings */
+static const struct ath5k_ini_mode ar5211_ini_mode[] = AR5K_AR5211_INI_MODE;
+static const struct ath5k_ini_mode ar5212_ini_mode[] = AR5K_AR5212_INI_MODE;
+static const struct ath5k_ini_mode ar5212_rf5111_ini_mode[] = AR5K_AR5212_RF5111_INI_MODE;
+static const struct ath5k_ini_mode ar5212_rf5112_ini_mode[] = AR5K_AR5212_RF5112_INI_MODE;
 
-/*
- * Initial gain optimization values
- */
-static const struct ath5k_gain_opt rf5111_gain_opt = AR5K_RF5111_GAIN_OPT;
-static const struct ath5k_gain_opt rf5112_gain_opt = AR5K_RF5112_GAIN_OPT;
+/* RF Initial BB gain settings */
+static const struct ath5k_ini rf5111_ini_bbgain[] = AR5K_RF5111_INI_BBGAIN;
+static const struct ath5k_ini rf5112_ini_bbgain[] = AR5K_RF5112_INI_BBGAIN;
 
 /*
- * Initial register settings for the radio chipsets
+ * RF Settings
  */
 /* RF Banks */
 static const struct ath5k_ini_rf rf5111_rf[] = AR5K_RF5111_INI_RF;
 static const struct ath5k_ini_rf rf5112_rf[] = AR5K_RF5112_INI_RF;
 static const struct ath5k_ini_rf rf5112a_rf[] = AR5K_RF5112A_INI_RF;
-/* Common (5111/5112) rf gain table */
-static const struct ath5k_ini_rfgain ath5k_rfg[] = AR5K_INI_RFGAIN;
+/* Initial mode-specific RF gain table for 5111/5112 */
+static const struct ath5k_ini_rfgain rf5111_ini_rfgain[] = AR5K_RF5111_INI_RFGAIN;
+static const struct ath5k_ini_rfgain rf5112_ini_rfgain[] = AR5K_RF5112_INI_RFGAIN;
+/* Initial gain optimization tables */
+static const struct ath5k_gain_opt rf5111_gain_opt = AR5K_RF5111_GAIN_OPT;
+static const struct ath5k_gain_opt rf5112_gain_opt = AR5K_RF5112_GAIN_OPT;
 
 /*
  * Enable to overwrite the country code (use "00" for debug)
@@ -257,6 +260,8 @@ static void ath5k_hw_ini_registers(struct ath_hw *hal, unsigned int size,
 
 	/* Write initial registers */
 	for (i = 0; i < size; i++) {
+		/* On channel change there is
+		 * no need to mess with PCU */
 		if (change_channel &&
 				ini_regs[i].ini_register >= AR5K_PCU_MIN &&
 				ini_regs[i].ini_register <= AR5K_PCU_MAX)
@@ -276,6 +281,20 @@ static void ath5k_hw_ini_registers(struct ath_hw *hal, unsigned int size,
 	}
 }
 
+static void ath5k_hw_ini_mode_registers(struct ath_hw *hal,
+		unsigned int size, const struct ath5k_ini_mode *ini_mode,
+		u8 mode)
+{
+	unsigned int i;
+
+	for (i = 0; i < size; i++) {
+		AR5K_REG_WAIT(i);
+		ath5k_hw_reg_write(hal, ini_mode[i].mode_value[mode],
+			(u32)ini_mode[i].mode_register);
+	}
+
+}
+
 /***************************************\
 	Attach/Detach Functions
 \***************************************/
@@ -291,8 +310,6 @@ struct ath_hw *ath5k_hw_attach(u16 device, u8 mac_version, void *sc,
 	int ret;
 	u32 srev;
 
-	/*TODO:Use eeprom_magic to verify chipset*/
-
 	/*If we passed the test malloc a hal struct*/
 	hal = kzalloc(sizeof(struct ath_hw), GFP_KERNEL);
 	if (hal == NULL) {
@@ -500,24 +517,34 @@ static int ath5k_hw_nic_wakeup(struct ath_hw *hal, int flags, bool initial)
 		if (flags & CHANNEL_2GHZ) {
 			mode |= AR5K_PHY_MODE_FREQ_2GHZ;
 			clock |= AR5K_PHY_PLL_44MHZ;
+
+			if (flags & CHANNEL_CCK) {
+				mode |= AR5K_PHY_MODE_MOD_CCK;
+			} else if (flags & CHANNEL_OFDM) {
+				/* XXX Dynamic OFDM/CCK is not supported by the
+				 * AR5211 so we set MOD_OFDM for plain g (no
+				 * CCK headers) operation. We need to test
+				 * this, 5211 might support ofdm-only g after
+				 * all, there are also initial register values
+				 * in the code for g mode (see ath5k_hw.h). */
+				if (hal->ah_version == AR5K_AR5211)
+					mode |= AR5K_PHY_MODE_MOD_OFDM;
+				else
+					mode |= AR5K_PHY_MODE_MOD_DYN;
+			} else {
+				AR5K_PRINT("invalid radio modulation mode\n");
+				return -EINVAL;
+			}
 		} else if (flags & CHANNEL_5GHZ) {
 			mode |= AR5K_PHY_MODE_FREQ_5GHZ;
 			clock |= AR5K_PHY_PLL_40MHZ;
-		} else {
-			AR5K_PRINT("invalid radio frequency mode\n");
-			return -EINVAL;
-		}
 
-		if (flags & CHANNEL_CCK) {
-			mode |= AR5K_PHY_MODE_MOD_CCK;
-		} else if (flags & CHANNEL_G) {
-			/* Dynamic OFDM/CCK is not supported by the AR5211 */
-			if (hal->ah_version == AR5K_AR5211)
-				mode |= AR5K_PHY_MODE_MOD_CCK;
-			else
-				mode |= AR5K_PHY_MODE_MOD_DYN;
-		} else if (flags & CHANNEL_OFDM) {
-			mode |= AR5K_PHY_MODE_MOD_OFDM;
+			if (flags & CHANNEL_OFDM)
+				mode |= AR5K_PHY_MODE_MOD_OFDM;
+			else {
+				AR5K_PRINT("invalid radio modulation mode\n");
+				return -EINVAL;
+			}
 		} else {
 			AR5K_PRINT("invalid radio frequency mode\n");
 			return -EINVAL;
@@ -642,7 +669,6 @@ static u16 ath5k_hw_radio_revision(struct ath_hw *hal, unsigned int chan)
 
 /*
  * Get the rate table for a specific operation mode
- * TODO:Limit this per chipset
  */
 const struct ath5k_rate_table *ath5k_hw_get_rate_table(struct ath_hw *hal,
 		unsigned int mode)
@@ -697,7 +723,7 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 	struct ath5k_eeprom_info *ee = &hal->ah_capabilities.cap_eeprom;
 	u32 data, noise_floor, s_seq, s_ant, s_led[3];
 	u8 mac[ETH_ALEN];
-	unsigned int i, phy, mode, freq, off, ee_mode, ant[2];
+	unsigned int i, mode, freq, ee_mode, ant[2];
 	int ret;
 
 	AR5K_TRACE;
@@ -707,7 +733,6 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 	ee_mode = 0;
 	freq = 0;
 	mode = 0;
-	phy = 0;
 
 	/*
 	 * Save some registers before a reset
@@ -747,11 +772,8 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 	 * 5210 only comes with RF5110
 	 */
 	if (hal->ah_version != AR5K_AR5210) {
-		if (hal->ah_radio == AR5K_RF5111)
-			phy = AR5K_INI_PHY_5111;
-		else if (hal->ah_radio == AR5K_RF5112)
-			phy = AR5K_INI_PHY_5112;
-		else {
+		if (hal->ah_radio != AR5K_RF5111 &&
+				hal->ah_radio != AR5K_RF5112) {
 			AR5K_PRINTF("invalid phy radio: %u\n", hal->ah_radio);
 			return -EINVAL;
 		}
@@ -767,6 +789,7 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 			freq = AR5K_INI_RFGAIN_2GHZ;
 			ee_mode = AR5K_EEPROM_MODE_11B;
 			break;
+		/* Is this ok on 5211 too ? */
 		case CHANNEL_G:
 			mode = AR5K_INI_VAL_11G;
 			freq = AR5K_INI_RFGAIN_2GHZ;
@@ -800,51 +823,32 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 		/* PHY access enable */
 		ath5k_hw_reg_write(hal, AR5K_PHY_SHIFT_5GHZ, AR5K_PHY(0));
 
-		/*
-		 * Write initial RF registers on 5211
-		 * do we need that ? Is ath5k_hw_rfregs going to work for
-		 * 5211 (5111) ?
-		 */
-		if (hal->ah_version == AR5K_AR5211)
-			ath5k_hw_ar5211_rfregs(hal, channel, freq, ee_mode);
 	}
 
 	/*
-	 * Write initial mode settings
-	 * TODO:Do this in a common way
+	 * Write initial mode-specific settings
 	 */
 	/*For 5212*/
 	if (hal->ah_version == AR5K_AR5212) {
-		for (i = 0; i < ARRAY_SIZE(ar5212_mode); i++) {
-			if (ar5212_mode[i].mode_flags == AR5K_INI_FLAG_511X)
-				off = AR5K_INI_PHY_511X;
-			else if (ar5212_mode[i].mode_flags & AR5K_INI_FLAG_5111
-					&& hal->ah_radio == AR5K_RF5111)
-				off = AR5K_INI_PHY_5111;
-			else if (ar5212_mode[i].mode_flags & AR5K_INI_FLAG_5112
-					&& hal->ah_radio == AR5K_RF5112)
-				off = AR5K_INI_PHY_5112;
-			else
-				continue;
-
-			AR5K_REG_WAIT(i);
-			ath5k_hw_reg_write(hal,
-					ar5212_mode[i].mode_value[off][mode],
-					(u32)ar5212_mode[i].mode_register);
-		}
+		ath5k_hw_ini_mode_registers(hal, ARRAY_SIZE(ar5212_ini_mode),
+				ar5212_ini_mode, mode);
+		if (hal->ah_radio == AR5K_RF5111)
+			ath5k_hw_ini_mode_registers(hal,
+					ARRAY_SIZE(ar5212_rf5111_ini_mode),
+					ar5212_rf5111_ini_mode, mode);
+		else if (hal->ah_radio == AR5K_RF5112)
+			ath5k_hw_ini_mode_registers(hal,
+					ARRAY_SIZE(ar5212_rf5112_ini_mode),
+					ar5212_rf5112_ini_mode, mode);
 	}
 	/*For 5211*/
-	if (hal->ah_version == AR5K_AR5211) {
-		for (i = 0; i < ARRAY_SIZE(ar5211_mode); i++) {
-			AR5K_REG_WAIT(i);
-			ath5k_hw_reg_write(hal,
-				ar5211_mode[i].mode_value[mode],
-				(u32)ar5211_mode[i].mode_register);
-		}
-	}
+	if (hal->ah_version == AR5K_AR5211)
+		ath5k_hw_ini_mode_registers(hal, ARRAY_SIZE(ar5211_ini_mode),
+				ar5211_ini_mode, mode);
+	/* For 5210 mode settings check out ath5k_hw_reset_tx_queue */
 
 	/*
-	 * Initial register dump common for all modes
+	 * Write initial settings common for all modes
 	 */
 	/*For 5212*/
 	if (hal->ah_version == AR5K_AR5212) {
@@ -854,23 +858,23 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 			ath5k_hw_reg_write(hal, AR5K_PHY_PAPD_PROBE_INI_5112,
 					AR5K_PHY_PAPD_PROBE);
 			ath5k_hw_ini_registers(hal,
-					ARRAY_SIZE(rf5112_bbgain_ini),
-					rf5112_bbgain_ini, change_channel);
+					ARRAY_SIZE(rf5112_ini_bbgain),
+					rf5112_ini_bbgain, change_channel);
 		} else if (hal->ah_radio == AR5K_RF5111) {
 			ath5k_hw_reg_write(hal, AR5K_PHY_GAIN_2GHZ_INI_5111,
 					AR5K_PHY_GAIN_2GHZ);
 			ath5k_hw_reg_write(hal, AR5K_PHY_PAPD_PROBE_INI_5111,
 					AR5K_PHY_PAPD_PROBE);
 			ath5k_hw_ini_registers(hal,
-					ARRAY_SIZE(rf5111_bbgain_ini),
-					rf5111_bbgain_ini, change_channel);
+					ARRAY_SIZE(rf5111_ini_bbgain),
+					rf5111_ini_bbgain, change_channel);
 		}
 	} else if (hal->ah_version == AR5K_AR5211) {
 		ath5k_hw_ini_registers(hal, ARRAY_SIZE(ar5211_ini),
 				ar5211_ini, change_channel);
 		/* AR5211 only comes with 5111 */
-		ath5k_hw_ini_registers(hal, ARRAY_SIZE(rf5111_bbgain_ini),
-				rf5111_bbgain_ini, change_channel);
+		ath5k_hw_ini_registers(hal, ARRAY_SIZE(rf5111_ini_bbgain),
+				rf5111_ini_bbgain, change_channel);
 	} else if (hal->ah_version == AR5K_AR5210) {
 		ath5k_hw_ini_registers(hal, ARRAY_SIZE(ar5210_ini),
 				ar5210_ini, change_channel);
@@ -884,8 +888,9 @@ int ath5k_hw_reset(struct ath_hw *hal, enum ieee80211_if_types op_mode,
 		 * Write initial RF gain settings
 		 * This should work for both 5111/5112
 		 */
-		if (ath5k_hw_rfgain(hal, phy, freq) == false)
-			return -EIO;
+		ret = ath5k_hw_rfgain(hal, freq);
+		if (ret)
+			return ret;
 
 		mdelay(1);
 
@@ -1945,6 +1950,9 @@ static int ath5k_hw_eeprom_write(struct ath_hw *hal, u32 offset, u16 data)
 	return -EIO;
 }
 
+/*
+ * Translate binary channel representation in EEPROM to frequency
+ */
 static u16 ath5k_eeprom_bin2freq(struct ath_hw *hal, u16 bin, unsigned int mode)
 {
 	u16 val;
@@ -3371,9 +3379,6 @@ int ath5k_hw_reset_tx_queue(struct ath_hw *hal, unsigned int queue)
 {
 	u32 cw_min, cw_max, retry_lg, retry_sh;
 	struct ath5k_txq_info *tq = &hal->ah_txq[queue];
-	int i;
-	struct ath5k_ar5210_ini_mode ar5210_mode[] =
-			AR5K_AR5210_INI_MODE(hal, hal->ah_aifs + tq->tqi_aifs);
 
 	AR5K_TRACE;
 	AR5K_ASSERT_ENTRY(queue, hal->ah_capabilities.cap_queues.q_tx_num);
@@ -3388,14 +3393,46 @@ int ath5k_hw_reset_tx_queue(struct ath_hw *hal, unsigned int queue)
 		if (tq->tqi_type != AR5K_TX_QUEUE_DATA)
 			return -EINVAL;
 
-		/*
-		 * Write initial mode register settings
-		 */
-		for (i = 0; i < ARRAY_SIZE(ar5210_mode); i++)
-			ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
-				ar5210_mode[i].mode_turbo :
-				ar5210_mode[i].mode_base,
-				(u32)ar5210_mode[i].mode_register);
+		/* Set Slot time */
+		ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
+			AR5K_INIT_SLOT_TIME_TURBO : AR5K_INIT_SLOT_TIME,
+			AR5K_SLOT_TIME);
+		/* Set ACK_CTS timeout */
+		ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
+			AR5K_INIT_ACK_CTS_TIMEOUT_TURBO :
+			AR5K_INIT_ACK_CTS_TIMEOUT, AR5K_SLOT_TIME);
+		/* Set Transmit Latency */
+		ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
+			AR5K_INIT_TRANSMIT_LATENCY_TURBO :
+			AR5K_INIT_TRANSMIT_LATENCY, AR5K_USEC_5210);
+		/* Set IFS0 */
+		if (hal->ah_turbo == true)
+			 ath5k_hw_reg_write(hal, ((AR5K_INIT_SIFS_TURBO +
+				(hal->ah_aifs + tq->tqi_aifs) *
+				AR5K_INIT_SLOT_TIME_TURBO) <<
+				AR5K_IFS0_DIFS_S) | AR5K_INIT_SIFS_TURBO,
+				AR5K_IFS0);
+		else
+			ath5k_hw_reg_write(hal, ((AR5K_INIT_SIFS +
+				(hal->ah_aifs + tq->tqi_aifs) *
+				AR5K_INIT_SLOT_TIME) << AR5K_IFS0_DIFS_S) |
+				AR5K_INIT_SIFS, AR5K_IFS0);
+
+		/* Set IFS1 */
+		ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
+			AR5K_INIT_PROTO_TIME_CNTRL_TURBO :
+			AR5K_INIT_PROTO_TIME_CNTRL, AR5K_IFS1);
+		/* Set PHY register 0x9844 (??) */
+		ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
+			(ath5k_hw_reg_read(hal, AR5K_PHY(17)) & ~0x7F) | 0x38 :
+			(ath5k_hw_reg_read(hal, AR5K_PHY(17)) & ~0x7F) | 0x1C,
+			AR5K_PHY(17));
+		/* Set Frame Control Register */
+		ath5k_hw_reg_write(hal, hal->ah_turbo == true ?
+			(AR5K_PHY_FRAME_CTL_INI | AR5K_PHY_TURBO_MODE |
+			AR5K_PHY_TURBO_SHORT | 0x2020) :
+			(AR5K_PHY_FRAME_CTL_INI | 0x1020),
+			AR5K_PHY_FRAME_CTL_5210);
 	}
 
 	/*
@@ -4857,6 +4894,9 @@ ath5k_hw_get_def_antenna(struct ath_hw *hal)
 	return false; /*XXX: What do we return for 5210 ?*/
 }
 
+/*
+ * Used to modify RF Banks before writing them to AR5K_RF_BUFFER
+ */
 static unsigned int ath5k_hw_rfregs_op(u32 *rf, u32 offset, u32 reg, u32 bits,
 		u32 first, u32 col, bool set)
 {
@@ -5072,7 +5112,7 @@ static int ath5k_hw_rfregs(struct ath_hw *hal,
 }
 
 /*
- * Initialize RF5111
+ * Read EEPROM Calibration data, modify RF Banks and Initialize RF5111
  */
 static int ath5k_hw_rf5111_rfregs(struct ath_hw *hal,
 		struct ieee80211_channel *channel, unsigned int mode)
@@ -5173,7 +5213,7 @@ static int ath5k_hw_rf5111_rfregs(struct ath_hw *hal,
 }
 
 /*
- * Initialize RF5112
+ * Read EEPROM Calibration data, modify RF Banks and Initialize RF5112
  */
 static int ath5k_hw_rf5112_rfregs(struct ath_hw *hal,
 		struct ieee80211_channel *channel, unsigned int mode)
@@ -5267,81 +5307,22 @@ static int ath5k_hw_rf5112_rfregs(struct ath_hw *hal,
 	return 0;
 }
 
-/*
- * Initialize 5211 RF
- * TODO: is this needed ? i mean 5211 has a 5111 RF
- * doesn't ar5k_rfregs work ?
- */
-static void ath5k_hw_ar5211_rfregs(struct ath_hw *hal,
-		struct ieee80211_channel *channel, unsigned int freq,
-		unsigned int ee_mode)
-{
-	struct ath5k_eeprom_info *ee = &hal->ah_capabilities.cap_eeprom;
-	struct ath5k_ar5211_ini_rf rf[ARRAY_SIZE(ar5211_rf)];
-	u32 ob, db, obdb, xpds, xpdp, x_gain;
-	unsigned int i;
-
-	memcpy(rf, ar5211_rf, sizeof(rf));
-	obdb = 0;
-
-	if (freq == AR5K_INI_RFGAIN_2GHZ &&
-		hal->ah_ee_version >= AR5K_EEPROM_VERSION_3_1) {
-			ob = ath5k_hw_bitswap(ee->ee_ob[ee_mode][0], 3);
-			db = ath5k_hw_bitswap(ee->ee_db[ee_mode][0], 3);
-		rf[25].rf_value[freq] =
-			((ob << 6) & 0xc0) | (rf[25].rf_value[freq] & ~0xc0);
-		rf[26].rf_value[freq] =
-			(((ob >> 2) & 0x1) | ((db << 1) & 0xe)) |
-			(rf[26].rf_value[freq] & ~0xf);
-	}
-
-	if (freq == AR5K_INI_RFGAIN_5GHZ) {
-		/* For 11a and Turbo */
-		obdb =	 channel->freq >= 5725 ? 3 :
-			(channel->freq >= 5500 ? 2 :
-			(channel->freq >= 5260 ? 1 :
-			(channel->freq >  4000 ? 0 : -1)));
-	}
-
-	ob = ee->ee_ob[ee_mode][obdb];
-	db = ee->ee_db[ee_mode][obdb];
-	x_gain = ee->ee_x_gain[ee_mode];
-	xpds = ee->ee_xpd[ee_mode];
-	xpdp = !xpds;
-
-	rf[11].rf_value[freq] = (rf[11].rf_value[freq] & ~0xc0) |
-		(((ath5k_hw_bitswap(x_gain, 4) << 7) | (xpdp << 6)) & 0xc0);
-	rf[12].rf_value[freq] = (rf[12].rf_value[freq] & ~0x7) |
-		((ath5k_hw_bitswap(x_gain, 4) >> 1) & 0x7);
-	rf[12].rf_value[freq] = (rf[12].rf_value[freq] & ~0x80) |
-		((ath5k_hw_bitswap(ob, 3) << 7) & 0x80);
-	rf[13].rf_value[freq] = (rf[13].rf_value[freq] & ~0x3) |
-		((ath5k_hw_bitswap(ob, 3) >> 1) & 0x3);
-	rf[13].rf_value[freq] = (rf[13].rf_value[freq] & ~0x1c) |
-		((ath5k_hw_bitswap(db, 3) << 2) & 0x1c);
-	rf[17].rf_value[freq] = (rf[17].rf_value[freq] & ~0x8) |
-		((xpds << 3) & 0x8);
-
-	for (i = 0; i < ARRAY_SIZE(rf); i++) {
-		AR5K_REG_WAIT(i);
-		ath5k_hw_reg_write(hal, rf[i].rf_value[freq],
-			(u32)rf[i].rf_register);
-	}
-
-	hal->ah_rf_gain = AR5K_RFGAIN_INACTIVE;
-}
-
-bool
-ath5k_hw_rfgain(struct ath_hw *hal, unsigned int phy, u_int freq)
+static int ath5k_hw_rfgain(struct ath_hw *hal, unsigned int freq)
 {
-	unsigned int i;
+	const struct ath5k_ini_rfgain *ath5k_rfg;
+	unsigned int i, size;
 
-	switch (phy) {
-	case AR5K_INI_PHY_5111:
-	case AR5K_INI_PHY_5112:
+	switch (hal->ah_radio) {
+	case AR5K_RF5111:
+		ath5k_rfg = rf5111_ini_rfgain;
+		size = ARRAY_SIZE(rf5111_ini_rfgain);
+		break;
+	case AR5K_RF5112:
+		ath5k_rfg = rf5112_ini_rfgain;
+		size = ARRAY_SIZE(rf5112_ini_rfgain);
 		break;
 	default:
-		return false;
+		return -EINVAL;
 	}
 
 	switch (freq) {
@@ -5349,16 +5330,16 @@ ath5k_hw_rfgain(struct ath_hw *hal, unsigned int phy, u_int freq)
 	case AR5K_INI_RFGAIN_5GHZ:
 		break;
 	default:
-		return false;
+		return -EINVAL;
 	}
 
-	for (i = 0; i < ARRAY_SIZE(ath5k_rfg); i++) {
+	for (i = 0; i < size; i++) {
 		AR5K_REG_WAIT(i);
-		ath5k_hw_reg_write(hal, ath5k_rfg[i].rfg_value[phy][freq],
+		ath5k_hw_reg_write(hal, ath5k_rfg[i].rfg_value[freq],
 			(u32)ath5k_rfg[i].rfg_register);
 	}
 
-	return true;
+	return 0;
 }
 
 enum ath5k_rfgain ath5k_hw_get_rf_gain(struct ath_hw *hal)
diff --git a/drivers/net/wireless/ath5k_hw.h b/drivers/net/wireless/ath5k_hw.h
index cff160b..5549135 100644
--- a/drivers/net/wireless/ath5k_hw.h
+++ b/drivers/net/wireless/ath5k_hw.h
@@ -160,11 +160,14 @@ struct ath5k_eeprom_info {
 	u16	ee_cck_ofdm_gain_delta;
 	u16	ee_cck_ofdm_power_delta;
 	u16	ee_scaled_cck_delta;
+
+	/* Used for tx thermal adjustment (eeprom_init, rfregs) */
 	u16	ee_tx_clip;
 	u16	ee_pwd_84;
 	u16	ee_pwd_90;
 	u16	ee_gain_select;
 
+	/* RF Calibration settings (reset, rfregs) */
 	u16	ee_i_cal[AR5K_EEPROM_N_MODES];
 	u16	ee_q_cal[AR5K_EEPROM_N_MODES];
 	u16	ee_fixed_bias[AR5K_EEPROM_N_MODES];
@@ -184,13 +187,17 @@ struct ath5k_eeprom_info {
 	u16	ee_x_gain[AR5K_EEPROM_N_MODES];
 	u16	ee_i_gain[AR5K_EEPROM_N_MODES];
 	u16	ee_margin_tx_rx[AR5K_EEPROM_N_MODES];
+
+	/* Unused */
 	u16	ee_false_detect[AR5K_EEPROM_N_MODES];
 	u16	ee_cal_pier[AR5K_EEPROM_N_MODES][AR5K_EEPROM_N_2GHZ_CHAN];
-	u16	ee_channel[AR5K_EEPROM_N_MODES][AR5K_EEPROM_MAX_CHAN];
+	u16	ee_channel[AR5K_EEPROM_N_MODES][AR5K_EEPROM_MAX_CHAN]; /*empty*/
 
+	/* Conformance test limits (Unused) */
 	u16	ee_ctls;
 	u16	ee_ctl[AR5K_EEPROM_MAX_CTLS];
 
+	/* Noise Floor Calibration settings */
 	s16	ee_noise_floor_thr[AR5K_EEPROM_N_MODES];
 	s8	ee_adc_desired_size[AR5K_EEPROM_N_MODES];
 	s8	ee_pga_desired_size[AR5K_EEPROM_N_MODES];
@@ -605,14 +612,10 @@ struct ath5k_hw_tx_status {
 #define AR5K_INI_VAL_XR			0
 #define AR5K_INI_VAL_MAX		5
 
-#define AR5K_INI_PHY_5111		0
-#define AR5K_INI_PHY_5112		1
-#define AR5K_INI_PHY_511X		1
-
 #define AR5K_RF5111_INI_RF_MAX_BANKS	AR5K_MAX_RF_BANKS
 #define AR5K_RF5112_INI_RF_MAX_BANKS	AR5K_MAX_RF_BANKS
 
-/* Struct to hold initial RF register values */
+/* Struct to hold initial RF register values (RF Banks) */
 struct ath5k_ini_rf {
 	u8	rf_bank;	/* check out ath5k_reg.h */
 	u16	rf_register;	/* register address */
@@ -945,151 +948,164 @@ struct ath5k_ini_rf {
 }
 
 /*
- * Mode-specific RF Gain registers
+ * Mode-specific RF Gain table (64bytes) for RF5111/5112
+ * (RF5110 only comes with AR5210 and only supports a/turbo a mode so initial
+ * RF Gain values are included in AR5K_AR5210_INI)
  */
 struct ath5k_ini_rfgain {
-	u16	rfg_register;		/* RF Gain register address */
-	u32	rfg_value[2][2];	/* [phy (above)][freq (below)] */
+	u16	rfg_register;	/* RF Gain register address */
+	u32	rfg_value[2];	/* [freq (see below)] */
 
 #define AR5K_INI_RFGAIN_5GHZ	0
 #define AR5K_INI_RFGAIN_2GHZ	1
 };
 
-#define AR5K_INI_RFGAIN	{						    \
-	{ 0x9a00, {							    \
-		/* 5111 5Ghz  5111 2Ghz       5112 5Ghz   5112 2Ghz */	    \
-		{ 0x000001a9, 0x00000000 }, { 0x00000007, 0x00000007 } } }, \
-	{ 0x9a04, {							    \
-		{ 0x000001e9, 0x00000040 }, { 0x00000047, 0x00000047 } } }, \
-	{ 0x9a08, {							    \
-		{ 0x00000029, 0x00000080 }, { 0x00000087, 0x00000087 } } }, \
-	{ 0x9a0c, {							    \
-		{ 0x00000069, 0x00000150 }, { 0x000001a0, 0x000001a0 } } }, \
-	{ 0x9a10, {							    \
-		{ 0x00000199, 0x00000190 }, { 0x000001e0, 0x000001e0 } } }, \
-	{ 0x9a14, {							    \
-		{ 0x000001d9, 0x000001d0 }, { 0x00000020, 0x00000020 } } }, \
-	{ 0x9a18, {							    \
-		{ 0x00000019, 0x00000010 }, { 0x00000060, 0x00000060 } } }, \
-	{ 0x9a1c, {							    \
-		{ 0x00000059, 0x00000044 }, { 0x000001a1, 0x000001a1 } } }, \
-	{ 0x9a20, {							    \
-		{ 0x00000099, 0x00000084 }, { 0x000001e1, 0x000001e1 } } }, \
-	{ 0x9a24, {							    \
-		{ 0x000001a5, 0x00000148 }, { 0x00000021, 0x00000021 } } }, \
-	{ 0x9a28, {							    \
-		{ 0x000001e5, 0x00000188 }, { 0x00000061, 0x00000061 } } }, \
-	{ 0x9a2c, {							    \
-		{ 0x00000025, 0x000001c8 }, { 0x00000162, 0x00000162 } } }, \
-	{ 0x9a30, {							    \
-		{ 0x000001c8, 0x00000014 }, { 0x000001a2, 0x000001a2 } } }, \
-	{ 0x9a34, {							    \
-		{ 0x00000008, 0x00000042 }, { 0x000001e2, 0x000001e2 } } }, \
-	{ 0x9a38, {							    \
-		{ 0x00000048, 0x00000082 }, { 0x00000022, 0x00000022 } } }, \
-	{ 0x9a3c, {							    \
-		{ 0x00000088, 0x00000178 }, { 0x00000062, 0x00000062 } } }, \
-	{ 0x9a40, {							    \
-		{ 0x00000198, 0x000001b8 }, { 0x00000163, 0x00000163 } } }, \
-	{ 0x9a44, {							    \
-		{ 0x000001d8, 0x000001f8 }, { 0x000001a3, 0x000001a3 } } }, \
-	{ 0x9a48, {							    \
-		{ 0x00000018, 0x00000012 }, { 0x000001e3, 0x000001e3 } } }, \
-	{ 0x9a4c, {							    \
-		{ 0x00000058, 0x00000052 }, { 0x00000023, 0x00000023 } } }, \
-	{ 0x9a50, {							    \
-		{ 0x00000098, 0x00000092 }, { 0x00000063, 0x00000063 } } }, \
-	{ 0x9a54, {							    \
-		{ 0x000001a4, 0x0000017c }, { 0x00000184, 0x00000184 } } }, \
-	{ 0x9a58, {							    \
-		{ 0x000001e4, 0x000001bc }, { 0x000001c4, 0x000001c4 } } }, \
-	{ 0x9a5c, {							    \
-		{ 0x00000024, 0x000001fc }, { 0x00000004, 0x00000004 } } }, \
-	{ 0x9a60, {							    \
-		{ 0x00000064, 0x0000000a }, { 0x000001ea, 0x0000000b } } }, \
-	{ 0x9a64, {							    \
-		{ 0x000000a4, 0x0000004a }, { 0x0000002a, 0x0000004b } } }, \
-	{ 0x9a68, {							    \
-		{ 0x000000e4, 0x0000008a }, { 0x0000006a, 0x0000008b } } }, \
-	{ 0x9a6c, {							    \
-		{ 0x0000010a, 0x0000015a }, { 0x000000aa, 0x000001ac } } }, \
-	{ 0x9a70, {							    \
-		{ 0x0000014a, 0x0000019a }, { 0x000001ab, 0x000001ec } } }, \
-	{ 0x9a74, {							    \
-		{ 0x0000018a, 0x000001da }, { 0x000001eb, 0x0000002c } } }, \
-	{ 0x9a78, {							    \
-		{ 0x000001ca, 0x0000000e }, { 0x0000002b, 0x00000012 } } }, \
-	{ 0x9a7c, {							    \
-		{ 0x0000000a, 0x0000004e }, { 0x0000006b, 0x00000052 } } }, \
-	{ 0x9a80, {							    \
-		{ 0x0000004a, 0x0000008e }, { 0x000000ab, 0x00000092 } } }, \
-	{ 0x9a84, {							    \
-		{ 0x0000008a, 0x0000015e }, { 0x000001ac, 0x00000193 } } }, \
-	{ 0x9a88, {							    \
-		{ 0x000001ba, 0x0000019e }, { 0x000001ec, 0x000001d3 } } }, \
-	{ 0x9a8c, {							    \
-		{ 0x000001fa, 0x000001de }, { 0x0000002c, 0x00000013 } } }, \
-	{ 0x9a90, {							    \
-		{ 0x0000003a, 0x00000009 }, { 0x0000003a, 0x00000053 } } }, \
-	{ 0x9a94, {							    \
-		{ 0x0000007a, 0x00000049 }, { 0x0000007a, 0x00000093 } } }, \
-	{ 0x9a98, {							    \
-		{ 0x00000186, 0x00000089 }, { 0x000000ba, 0x00000194 } } }, \
-	{ 0x9a9c, {							    \
-		{ 0x000001c6, 0x00000179 }, { 0x000001bb, 0x000001d4 } } }, \
-	{ 0x9aa0, {							    \
-		{ 0x00000006, 0x000001b9 }, { 0x000001fb, 0x00000014 } } }, \
-	{ 0x9aa4, {							    \
-		{ 0x00000046, 0x000001f9 }, { 0x0000003b, 0x0000003a } } }, \
-	{ 0x9aa8, {							    \
-		{ 0x00000086, 0x00000039 }, { 0x0000007b, 0x0000007a } } }, \
-	{ 0x9aac, {							    \
-		{ 0x000000c6, 0x00000079 }, { 0x000000bb, 0x000000ba } } }, \
-	{ 0x9ab0, {							    \
-		{ 0x000000c6, 0x000000b9 }, { 0x000001bc, 0x000001bb } } }, \
-	{ 0x9ab4, {							    \
-		{ 0x000000c6, 0x000001bd }, { 0x000001fc, 0x000001fb } } }, \
-	{ 0x9ab8, {							    \
-		{ 0x000000c6, 0x000001fd }, { 0x0000003c, 0x0000003b } } }, \
-	{ 0x9abc, {							    \
-		{ 0x000000c6, 0x0000003d }, { 0x0000007c, 0x0000007b } } }, \
-	{ 0x9ac0, {							    \
-		{ 0x000000c6, 0x0000007d }, { 0x000000bc, 0x000000bb } } }, \
-	{ 0x9ac4, {							    \
-		{ 0x000000c6, 0x000000bd }, { 0x000000fc, 0x000001bc } } }, \
-	{ 0x9ac8, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000001fc } } }, \
-	{ 0x9acc, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x0000003c } } }, \
-	{ 0x9ad0, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x0000007c } } }, \
-	{ 0x9ad4, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000bc } } }, \
-	{ 0x9ad8, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9adc, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9ae0, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9ae4, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9ae8, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9aec, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9af0, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9af4, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9af8, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
-	{ 0x9afc, {							    \
-		{ 0x000000c6, 0x000000fd }, { 0x000000fc, 0x000000fc } } }, \
+/* Initial RF Gain settings for RF5111 */
+#define AR5K_RF5111_INI_RFGAIN	{				\
+	/*			      5Ghz	2Ghz	*/	\
+	{ AR5K_RF_GAIN(0),	{ 0x000001a9, 0x00000000 } },	\
+	{ AR5K_RF_GAIN(1),	{ 0x000001e9, 0x00000040 } },	\
+	{ AR5K_RF_GAIN(2),	{ 0x00000029, 0x00000080 } },	\
+	{ AR5K_RF_GAIN(3),	{ 0x00000069, 0x00000150 } },	\
+	{ AR5K_RF_GAIN(4),	{ 0x00000199, 0x00000190 } },	\
+	{ AR5K_RF_GAIN(5),	{ 0x000001d9, 0x000001d0 } },	\
+	{ AR5K_RF_GAIN(6),	{ 0x00000019, 0x00000010 } },	\
+	{ AR5K_RF_GAIN(7),	{ 0x00000059, 0x00000044 } },	\
+	{ AR5K_RF_GAIN(8),	{ 0x00000099, 0x00000084 } },	\
+	{ AR5K_RF_GAIN(9),	{ 0x000001a5, 0x00000148 } },	\
+	{ AR5K_RF_GAIN(10),	{ 0x000001e5, 0x00000188 } },	\
+	{ AR5K_RF_GAIN(11),	{ 0x00000025, 0x000001c8 } },	\
+	{ AR5K_RF_GAIN(12),	{ 0x000001c8, 0x00000014 } },	\
+	{ AR5K_RF_GAIN(13),	{ 0x00000008, 0x00000042 } },	\
+	{ AR5K_RF_GAIN(14),	{ 0x00000048, 0x00000082 } },	\
+	{ AR5K_RF_GAIN(15),	{ 0x00000088, 0x00000178 } },	\
+	{ AR5K_RF_GAIN(16),	{ 0x00000198, 0x000001b8 } },	\
+	{ AR5K_RF_GAIN(17),	{ 0x000001d8, 0x000001f8 } },	\
+	{ AR5K_RF_GAIN(18),	{ 0x00000018, 0x00000012 } },	\
+	{ AR5K_RF_GAIN(19),	{ 0x00000058, 0x00000052 } },	\
+	{ AR5K_RF_GAIN(20),	{ 0x00000098, 0x00000092 } },	\
+	{ AR5K_RF_GAIN(21),	{ 0x000001a4, 0x0000017c } },	\
+	{ AR5K_RF_GAIN(22),	{ 0x000001e4, 0x000001bc } },	\
+	{ AR5K_RF_GAIN(23),	{ 0x00000024, 0x000001fc } },	\
+	{ AR5K_RF_GAIN(24),	{ 0x00000064, 0x0000000a } },	\
+	{ AR5K_RF_GAIN(25),	{ 0x000000a4, 0x0000004a } },	\
+	{ AR5K_RF_GAIN(26),	{ 0x000000e4, 0x0000008a } },	\
+	{ AR5K_RF_GAIN(27),	{ 0x0000010a, 0x0000015a } },	\
+	{ AR5K_RF_GAIN(28),	{ 0x0000014a, 0x0000019a } },	\
+	{ AR5K_RF_GAIN(29),	{ 0x0000018a, 0x000001da } },	\
+	{ AR5K_RF_GAIN(30),	{ 0x000001ca, 0x0000000e } },	\
+	{ AR5K_RF_GAIN(31),	{ 0x0000000a, 0x0000004e } },	\
+	{ AR5K_RF_GAIN(32),	{ 0x0000004a, 0x0000008e } },	\
+	{ AR5K_RF_GAIN(33),	{ 0x0000008a, 0x0000015e } },	\
+	{ AR5K_RF_GAIN(34),	{ 0x000001ba, 0x0000019e } },	\
+	{ AR5K_RF_GAIN(35),	{ 0x000001fa, 0x000001de } },	\
+	{ AR5K_RF_GAIN(36),	{ 0x0000003a, 0x00000009 } },	\
+	{ AR5K_RF_GAIN(37),	{ 0x0000007a, 0x00000049 } },	\
+	{ AR5K_RF_GAIN(38),	{ 0x00000186, 0x00000089 } },	\
+	{ AR5K_RF_GAIN(39),	{ 0x000001c6, 0x00000179 } },	\
+	{ AR5K_RF_GAIN(40),	{ 0x00000006, 0x000001b9 } },	\
+	{ AR5K_RF_GAIN(41),	{ 0x00000046, 0x000001f9 } },	\
+	{ AR5K_RF_GAIN(42),	{ 0x00000086, 0x00000039 } },	\
+	{ AR5K_RF_GAIN(43),	{ 0x000000c6, 0x00000079 } },	\
+	{ AR5K_RF_GAIN(44),	{ 0x000000c6, 0x000000b9 } },	\
+	{ AR5K_RF_GAIN(45),	{ 0x000000c6, 0x000001bd } },	\
+	{ AR5K_RF_GAIN(46),	{ 0x000000c6, 0x000001fd } },	\
+	{ AR5K_RF_GAIN(47),	{ 0x000000c6, 0x0000003d } },	\
+	{ AR5K_RF_GAIN(48),	{ 0x000000c6, 0x0000007d } },	\
+	{ AR5K_RF_GAIN(49),	{ 0x000000c6, 0x000000bd } },	\
+	{ AR5K_RF_GAIN(50),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(51),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(52),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(53),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(54),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(55),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(56),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(57),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(58),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(59),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(60),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(61),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(62),	{ 0x000000c6, 0x000000fd } },	\
+	{ AR5K_RF_GAIN(63),	{ 0x000000c6, 0x000000fd } },	\
 }
 
+/* Initial RF Gain settings for RF5112 */
+#define AR5K_RF5112_INI_RFGAIN	{				\
+	/*			      5Ghz	2Ghz	*/	\
+	{ AR5K_RF_GAIN(0),	{ 0x00000007, 0x00000007 } },	\
+	{ AR5K_RF_GAIN(1),	{ 0x00000047, 0x00000047 } },	\
+	{ AR5K_RF_GAIN(2),	{ 0x00000087, 0x00000087 } },	\
+	{ AR5K_RF_GAIN(3),	{ 0x000001a0, 0x000001a0 } },	\
+	{ AR5K_RF_GAIN(4),	{ 0x000001e0, 0x000001e0 } },	\
+	{ AR5K_RF_GAIN(5),	{ 0x00000020, 0x00000020 } },	\
+	{ AR5K_RF_GAIN(6),	{ 0x00000060, 0x00000060 } },	\
+	{ AR5K_RF_GAIN(7),	{ 0x000001a1, 0x000001a1 } },	\
+	{ AR5K_RF_GAIN(8),	{ 0x000001e1, 0x000001e1 } },	\
+	{ AR5K_RF_GAIN(9),	{ 0x00000021, 0x00000021 } },	\
+	{ AR5K_RF_GAIN(10),	{ 0x00000061, 0x00000061 } },	\
+	{ AR5K_RF_GAIN(11),	{ 0x00000162, 0x00000162 } },	\
+	{ AR5K_RF_GAIN(12),	{ 0x000001a2, 0x000001a2 } },	\
+	{ AR5K_RF_GAIN(13),	{ 0x000001e2, 0x000001e2 } },	\
+	{ AR5K_RF_GAIN(14),	{ 0x00000022, 0x00000022 } },	\
+	{ AR5K_RF_GAIN(15),	{ 0x00000062, 0x00000062 } },	\
+	{ AR5K_RF_GAIN(16),	{ 0x00000163, 0x00000163 } },	\
+	{ AR5K_RF_GAIN(17),	{ 0x000001a3, 0x000001a3 } },	\
+	{ AR5K_RF_GAIN(18),	{ 0x000001e3, 0x000001e3 } },	\
+	{ AR5K_RF_GAIN(19),	{ 0x00000023, 0x00000023 } },	\
+	{ AR5K_RF_GAIN(20),	{ 0x00000063, 0x00000063 } },	\
+	{ AR5K_RF_GAIN(21),	{ 0x00000184, 0x00000184 } },	\
+	{ AR5K_RF_GAIN(22),	{ 0x000001c4, 0x000001c4 } },	\
+	{ AR5K_RF_GAIN(23),	{ 0x00000004, 0x00000004 } },	\
+	{ AR5K_RF_GAIN(24),	{ 0x000001ea, 0x0000000b } },	\
+	{ AR5K_RF_GAIN(25),	{ 0x0000002a, 0x0000004b } },	\
+	{ AR5K_RF_GAIN(26),	{ 0x0000006a, 0x0000008b } },	\
+	{ AR5K_RF_GAIN(27),	{ 0x000000aa, 0x000001ac } },	\
+	{ AR5K_RF_GAIN(28),	{ 0x000001ab, 0x000001ec } },	\
+	{ AR5K_RF_GAIN(29),	{ 0x000001eb, 0x0000002c } },	\
+	{ AR5K_RF_GAIN(30),	{ 0x0000002b, 0x00000012 } },	\
+	{ AR5K_RF_GAIN(31),	{ 0x0000006b, 0x00000052 } },	\
+	{ AR5K_RF_GAIN(32),	{ 0x000000ab, 0x00000092 } },	\
+	{ AR5K_RF_GAIN(33),	{ 0x000001ac, 0x00000193 } },	\
+	{ AR5K_RF_GAIN(34),	{ 0x000001ec, 0x000001d3 } },	\
+	{ AR5K_RF_GAIN(35),	{ 0x0000002c, 0x00000013 } },	\
+	{ AR5K_RF_GAIN(36),	{ 0x0000003a, 0x00000053 } },	\
+	{ AR5K_RF_GAIN(37),	{ 0x0000007a, 0x00000093 } },	\
+	{ AR5K_RF_GAIN(38),	{ 0x000000ba, 0x00000194 } },	\
+	{ AR5K_RF_GAIN(39),	{ 0x000001bb, 0x000001d4 } },	\
+	{ AR5K_RF_GAIN(40),	{ 0x000001fb, 0x00000014 } },	\
+	{ AR5K_RF_GAIN(41),	{ 0x0000003b, 0x0000003a } },	\
+	{ AR5K_RF_GAIN(42),	{ 0x0000007b, 0x0000007a } },	\
+	{ AR5K_RF_GAIN(43),	{ 0x000000bb, 0x000000ba } },	\
+	{ AR5K_RF_GAIN(44),	{ 0x000001bc, 0x000001bb } },	\
+	{ AR5K_RF_GAIN(45),	{ 0x000001fc, 0x000001fb } },	\
+	{ AR5K_RF_GAIN(46),	{ 0x0000003c, 0x0000003b } },	\
+	{ AR5K_RF_GAIN(47),	{ 0x0000007c, 0x0000007b } },	\
+	{ AR5K_RF_GAIN(48),	{ 0x000000bc, 0x000000bb } },	\
+	{ AR5K_RF_GAIN(49),	{ 0x000000fc, 0x000001bc } },	\
+	{ AR5K_RF_GAIN(50),	{ 0x000000fc, 0x000001fc } },	\
+	{ AR5K_RF_GAIN(51),	{ 0x000000fc, 0x0000003c } },	\
+	{ AR5K_RF_GAIN(52),	{ 0x000000fc, 0x0000007c } },	\
+	{ AR5K_RF_GAIN(53),	{ 0x000000fc, 0x000000bc } },	\
+	{ AR5K_RF_GAIN(54),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(55),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(56),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(57),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(58),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(59),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(60),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(61),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(62),	{ 0x000000fc, 0x000000fc } },	\
+	{ AR5K_RF_GAIN(63),	{ 0x000000fc, 0x000000fc } },	\
+}
+
+
+/*
+ * MAC/PHY REGISTERS
+ */
+
 
 /*
- * Mode-independet initial register writes
+ * Mode-independent initial register writes
  */
 
 struct ath5k_ini {
@@ -1239,7 +1255,7 @@ struct ath5k_ini {
 	{ AR5K_BB_GAIN(61), 0x0000002f },	\
 	{ AR5K_BB_GAIN(62), 0x0000002f },	\
 	{ AR5K_BB_GAIN(63), 0x0000002f },	\
-	/* RF gain table (64btes) */		\
+	/* 5110 RF gain table (64btes) */	\
 	{ AR5K_RF_GAIN(0), 0x0000001d },	\
 	{ AR5K_RF_GAIN(1), 0x0000005d },	\
 	{ AR5K_RF_GAIN(2), 0x0000009d },	\
@@ -1597,6 +1613,7 @@ struct ath5k_ini {
 	{ 0x87d4, 0x17161514 },			\
 	{ 0x87d8, 0x1b1a1918 },			\
 	{ 0x87dc, 0x1f1e1d1c },			\
+	/* loop ? */				\
 	{ 0x87e0, 0x03020100 },			\
 	{ 0x87e4, 0x07060504 },			\
 	{ 0x87e8, 0x0b0a0908 },			\
@@ -1686,8 +1703,14 @@ struct ath5k_ini {
 	{ AR5K_PHY(658), 0x0fff3ffc },		\
 	{ AR5K_PHY_CCKTXCTL, 0x00000000 },	\
 }
-/* RF5111 Initial BB Gain settings */
-#define AR5K_RF5111_BBGAIN_INI {		\
+
+/*
+ * Initial BaseBand Gain settings for RF5111/5112 (only AR5210 comes with
+ * RF5110 so initial BB Gain settings are included in AR5K_AR5210_INI)
+ */
+
+/* RF5111 Initial BaseBand Gain settings */
+#define AR5K_RF5111_INI_BBGAIN {		\
 	{ AR5K_BB_GAIN(0), 0x00000000 },	\
 	{ AR5K_BB_GAIN(1), 0x00000020 },	\
 	{ AR5K_BB_GAIN(2), 0x00000010 },	\
@@ -1754,8 +1777,8 @@ struct ath5k_ini {
 	{ AR5K_BB_GAIN(63), 0x00000016 },	\
 }
 
-/* RF 5112 Initial BB Gain settings */
-#define AR5K_RF5112_BBGAIN_INI {		\
+/* RF 5112 Initial BaseBand Gain settings */
+#define AR5K_RF5112_INI_BBGAIN {		\
 	{ AR5K_BB_GAIN(0), 0x00000000 },	\
 	{ AR5K_BB_GAIN(1), 0x00000001 },	\
 	{ AR5K_BB_GAIN(2), 0x00000002 },	\
@@ -1822,331 +1845,231 @@ struct ath5k_ini {
 	{ AR5K_BB_GAIN(63), 0x0000001a },	\
 }
 
-struct ath5k_ar5210_ini_mode{
-	u16 mode_register;
-	u32 mode_base, mode_turbo;
-};
-
-#define AR5K_AR5210_INI_MODE(hal, _aifs) {			\
-	{ AR5K_SLOT_TIME,					\
-	    AR5K_INIT_SLOT_TIME,				\
-	    AR5K_INIT_SLOT_TIME_TURBO },			\
-	{ AR5K_SLOT_TIME,					\
-	    AR5K_INIT_ACK_CTS_TIMEOUT,				\
-	    AR5K_INIT_ACK_CTS_TIMEOUT_TURBO },			\
-	{ AR5K_USEC_5210,					\
-	    AR5K_INIT_TRANSMIT_LATENCY,				\
-	    AR5K_INIT_TRANSMIT_LATENCY_TURBO},			\
-	{ AR5K_IFS0,						\
-	    ((AR5K_INIT_SIFS + (_aifs) * AR5K_INIT_SLOT_TIME)	\
-	    << AR5K_IFS0_DIFS_S) | AR5K_INIT_SIFS,		\
-	    ((AR5K_INIT_SIFS_TURBO + (_aifs) * AR5K_INIT_SLOT_TIME_TURBO) \
-	    << AR5K_IFS0_DIFS_S) | AR5K_INIT_SIFS_TURBO },	\
-	{ AR5K_IFS1,						\
-	    AR5K_INIT_PROTO_TIME_CNTRL,				\
-	    AR5K_INIT_PROTO_TIME_CNTRL_TURBO },			\
-	{ AR5K_PHY(17),						\
-	    (ath5k_hw_reg_read(hal, AR5K_PHY(17)) & ~0x7F) | 0x1C, \
-	    (ath5k_hw_reg_read(hal, AR5K_PHY(17)) & ~0x7F) | 0x38 }, \
-	{ AR5K_PHY_FRAME_CTL_5210,				\
-	    AR5K_PHY_FRAME_CTL_SERVICE_ERR |			\
-	    AR5K_PHY_FRAME_CTL_TXURN_ERR |			\
-	    AR5K_PHY_FRAME_CTL_ILLLEN_ERR |			\
-	    AR5K_PHY_FRAME_CTL_ILLRATE_ERR |			\
-	    AR5K_PHY_FRAME_CTL_PARITY_ERR |			\
-	    AR5K_PHY_FRAME_CTL_TIMING_ERR | 0x1020,		\
-	    AR5K_PHY_FRAME_CTL_SERVICE_ERR |			\
-	    AR5K_PHY_FRAME_CTL_TXURN_ERR |			\
-	    AR5K_PHY_FRAME_CTL_ILLLEN_ERR |			\
-	    AR5K_PHY_FRAME_CTL_ILLRATE_ERR |			\
-	    AR5K_PHY_FRAME_CTL_PARITY_ERR |			\
-	/*PHY_TURBO is PHY_FRAME_CTL on 5210*/			\
-	    AR5K_PHY_TURBO_MODE |				\
-	    AR5K_PHY_TURBO_SHORT |				\
-	    AR5K_PHY_FRAME_CTL_TIMING_ERR | 0x2020 },		\
-}
+/*
+ * Mode specific initial register values
+ */
 
-struct ath5k_ar5211_ini_mode {
+struct ath5k_ini_mode {
 	u16	mode_register;
-	u32	mode_value[4];
+	u32	mode_value[5];
 };
 
-#define AR5K_AR5211_INI_MODE {						\
-	{ 0x0030, { 0x00000017, 0x00000017, 0x00000017, 0x00000017 } },	\
-	{ 0x1040, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1044, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1048, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x104c, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1050, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1054, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1058, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x105c, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1060, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1064, { 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f } },	\
-	{ 0x1070, { 0x00000168, 0x000001e0, 0x000001b8, 0x00000168 } },	\
-	{ 0x1030, { 0x00000230, 0x000001e0, 0x000000b0, 0x00000230 } },	\
-	{ 0x10b0, { 0x00000d98, 0x00001180, 0x00001f48, 0x00000d98 } },	\
-	{ 0x10f0, { 0x0000a0e0, 0x00014068, 0x00005880, 0x0000a0e0 } },	\
-	{ 0x8014, { 0x04000400, 0x08000800, 0x20003000, 0x04000400 } },	\
-	{ 0x801c, { 0x0e8d8fa7, 0x0e8d8fcf, 0x01608f95, 0x0e8d8fa7 } },	\
-	{ 0x9804, { 0x00000000, 0x00000003, 0x00000000, 0x00000000 } },	\
-	{ 0x9820, { 0x02020200, 0x02020200, 0x02010200, 0x02020200 } },	\
-	{ 0x9824, { 0x00000e0e, 0x00000e0e, 0x00000707, 0x00000e0e } },	\
-	{ 0x9828, { 0x0a020001, 0x0a020001, 0x05010000, 0x0a020001 } },	\
-	{ 0x9834, { 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e } },	\
-	{ 0x9838, { 0x00000007, 0x00000007, 0x0000000b, 0x0000000b } },	\
-	{ 0x9844, { 0x1372169c, 0x137216a5, 0x137216a8, 0x1372169c } },	\
-	{ 0x9848, { 0x0018ba67, 0x0018ba67, 0x0018ba69, 0x0018ba69 } },	\
-	{ 0x9850, { 0x0c28b4e0, 0x0c28b4e0, 0x0c28b4e0, 0x0c28b4e0 } },	\
-	{ 0x9858, { 0x7e800d2e, 0x7e800d2e, 0x7ec00d2e, 0x7e800d2e } },	\
-	{ 0x985c, { 0x31375d5e, 0x31375d5e, 0x313a5d5e, 0x31375d5e } },	\
-	{ 0x9860, { 0x0000bd10, 0x0000bd10, 0x0000bd38, 0x0000bd10 } },	\
-	{ 0x9864, { 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00 } },	\
-	{ 0x9914, { 0x00002710, 0x00002710, 0x0000157c, 0x00002710 } },	\
-	{ 0x9918, { 0x00000190, 0x00000190, 0x00000084, 0x00000190 } },	\
-	{ 0x9944, { 0x6fe01020, 0x6fe01020, 0x6fe00920, 0x6fe01020 } },	\
-	{ 0xa180, { 0x05ff14ff, 0x05ff14ff, 0x05ff14ff, 0x05ff19ff } },	\
-	{ 0x98d4, { 0x00000010, 0x00000014, 0x00000010, 0x00000010 } },	\
+/* Initial mode-specific settings for AR5211
+ * XXX: how about gTurbo ? RF5111 supports it, how about AR5211 ?
+ */
+#define AR5K_AR5211_INI_MODE { \
+	{ AR5K_TXCFG,									\
+	/*	  a/XR	      aTurbo	  b	      g(OFDM?)	  gTurbo (N/A) */	\
+ 		{ 0x00000017, 0x00000017, 0x00000017, 0x00000017, 0x00000017 } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(0),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(1),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(2),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(3),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(4),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(5),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(6),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(7),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(8),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(9),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_DCU_GBL_IFS_SLOT,							\
+		{ 0x00000168, 0x000001e0, 0x000001b8, 0x00000168, 0x00000168 } },	\
+	{ AR5K_DCU_GBL_IFS_SIFS,							\
+		{ 0x00000230, 0x000001e0, 0x000000b0, 0x00000230, 0x00000230 } },	\
+	{ AR5K_DCU_GBL_IFS_EIFS,							\
+		{ 0x00000d98, 0x00001180, 0x00001f48, 0x00000d98, 0x00000d98 } },	\
+	{ AR5K_DCU_GBL_IFS_MISC,							\
+		{ 0x0000a0e0, 0x00014068, 0x00005880, 0x0000a0e0, 0x0000a0e0 } },	\
+	{ AR5K_TIME_OUT,								\
+		{ 0x04000400, 0x08000800, 0x20003000, 0x04000400, 0x04000400 } },	\
+	{ AR5K_USEC_5211,								\
+		{ 0x0e8d8fa7, 0x0e8d8fcf, 0x01608f95, 0x0e8d8fa7, 0x0e8d8fa7 } },	\
+	{ AR5K_PHY_TURBO,								\
+		{ 0x00000000, 0x00000003, 0x00000000, 0x00000000, 0x00000000 } },	\
+	{ 0x9820,									\
+		{ 0x02020200, 0x02020200, 0x02010200, 0x02020200, 0x02020200 } },	\
+	{ 0x9824,									\
+		{ 0x00000e0e, 0x00000e0e, 0x00000707, 0x00000e0e, 0x00000e0e } },	\
+	{ 0x9828,									\
+		{ 0x0a020001, 0x0a020001, 0x05010000, 0x0a020001, 0x0a020001 } },	\
+	{ 0x9834,									\
+		{ 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e } },	\
+	{ 0x9838,									\
+		{ 0x00000007, 0x00000007, 0x0000000b, 0x0000000b, 0x0000000b } },	\
+	{ 0x9844,									\
+		{ 0x1372169c, 0x137216a5, 0x137216a8, 0x1372169c, 0x1372169c } },	\
+	{ 0x9848,									\
+		{ 0x0018ba67, 0x0018ba67, 0x0018ba69, 0x0018ba69, 0x0018ba69 } },	\
+	{ 0x9850,									\
+		{ 0x0c28b4e0, 0x0c28b4e0, 0x0c28b4e0, 0x0c28b4e0, 0x0c28b4e0 } },	\
+	{ AR5K_PHY_SIG,									\
+		{ 0x7e800d2e, 0x7e800d2e, 0x7ec00d2e, 0x7e800d2e, 0x7e800d2e } },	\
+	{ AR5K_PHY_AGCCOARSE,								\
+		{ 0x31375d5e, 0x31375d5e, 0x313a5d5e, 0x31375d5e, 0x31375d5e } },	\
+	{ AR5K_PHY_AGCCTL,								\
+		{ 0x0000bd10, 0x0000bd10, 0x0000bd38, 0x0000bd10, 0x0000bd10 } },	\
+	{ AR5K_PHY_NF,									\
+		{ 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00 } },	\
+	{ AR5K_PHY_RX_DELAY,								\
+		{ 0x00002710, 0x00002710, 0x0000157c, 0x00002710, 0x00002710 } },	\
+	{ 0x9918,									\
+		{ 0x00000190, 0x00000190, 0x00000084, 0x00000190, 0x00000190 } },	\
+	{ AR5K_PHY_FRAME_CTL_5211,							\
+		{ 0x6fe01020, 0x6fe01020, 0x6fe00920, 0x6fe01020, 0x6fe01020 } },	\
+	{ AR5K_PHY_PCDAC_TXPOWER(0),							\
+		{ 0x05ff14ff, 0x05ff14ff, 0x05ff14ff, 0x05ff19ff, 0x05ff19ff } },	\
+	{ AR5K_RF_BUFFER_CONTROL_4,							\
+		{ 0x00000010, 0x00000014, 0x00000010, 0x00000010, 0x00000010 } },	\
 }
 
-struct ath5k_ar5212_ini_mode {
-	u16	mode_register;
-	u8	mode_flags;
-	u32	mode_value[2][5];
-};
-
-#define AR5K_INI_FLAG_511X	0x00
-#define AR5K_INI_FLAG_5111	0x01
-#define AR5K_INI_FLAG_5112	0x02
-#define AR5K_INI_FLAG_BOTH	(AR5K_INI_FLAG_5111 | AR5K_INI_FLAG_5112)
-
-#define AR5K_AR5212_INI_MODE {							\
-	{ 0x0030, AR5K_INI_FLAG_511X, {					       \
-		{ 0, },							       \
-		{ 0x00008107, 0x00008107, 0x00008107, 0x00008107, 0x00008107 } \
-	} },									\
-	{ 0x1040, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1044, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1048, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x104c, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1050, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1054, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1058, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x105c, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1060, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1064, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f }	\
-	} },									\
-	{ 0x1030, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000230, 0x000001e0, 0x000000b0, 0x00000160, 0x000001e0 }	\
-	} },									\
-	{ 0x1070, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000168, 0x000001e0, 0x000001b8, 0x0000018c, 0x000001e0 }	\
-	} },									\
-	{ 0x10b0, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000e60, 0x00001180, 0x00001f1c, 0x00003e38, 0x00001180 }	\
-	} },									\
-	{ 0x10f0, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x0000a0e0, 0x00014068, 0x00005880, 0x0000b0e0, 0x00014068 }	\
-	} },									\
-	{ 0x8014, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x03e803e8, 0x06e006e0, 0x04200420, 0x08400840, 0x06e006e0 }	\
-	} },									\
-	{ 0x9804, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000000, 0x00000003, 0x00000000, 0x00000000, 0x00000003 }	\
-	} },									\
-	{ 0x9820, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x02020200, 0x02020200, 0x02010200, 0x02020200, 0x02020200 }	\
-	} },									\
-	{ 0x9834, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e }	\
-	} },									\
-	{ 0x9838, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000007, 0x00000007, 0x0000000b, 0x0000000b, 0x0000000b }	\
-	} },									\
-	{ 0x9844, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x1372161c, 0x13721c25, 0x13721728, 0x137216a2, 0x13721c25 }	\
-	} },									\
-	{ 0x9850, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0 }	\
-	} },									\
-	{ 0x9858, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x7e800d2e, 0x7e800d2e, 0x7ee84d2e, 0x7ee84d2e, 0x7e800d2e }	\
-	} },									\
-	{ 0x9860, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00009d10, 0x00009d10, 0x00009d18, 0x00009d10, 0x00009d10 }	\
-	} },									\
-	{ 0x9864, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00 }	\
-	} },									\
-	{ 0x9868, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x409a4190, 0x409a4190, 0x409a4190, 0x409a4190, 0x409a4190 }	\
-	} },									\
-	{ 0x9918, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x000001b8, 0x000001b8, 0x00000084, 0x00000108, 0x000001b8 }	\
-	} },									\
-	{ 0x9924, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x10058a05, 0x10058a05, 0x10058a05, 0x10058a05, 0x10058a05 }	\
-	} },									\
-	{ 0xa180, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x10ff14ff, 0x10ff14ff, 0x10ff10ff, 0x10ff19ff, 0x10ff19ff }	\
-	} },									\
-	{ 0xa230, AR5K_INI_FLAG_511X, {						\
-		{ 0, },								\
-		{ 0x00000000, 0x00000000, 0x00000000, 0x00000108, 0x00000000 }	\
-	} },									\
-	{ 0x801c, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x128d8fa7, 0x09880fcf, 0x04e00f95, 0x128d8fab, 0x09880fcf }, \
-		{ 0x128d93a7, 0x098813cf, 0x04e01395, 0x128d93ab, 0x098813cf }	\
-	} },									\
-	{ 0x9824, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x00000e0e, 0x00000e0e, 0x00000707, 0x00000e0e, 0x00000e0e },	\
-		{ 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e }	\
-	} },									\
-	{ 0x9828, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x0a020001, 0x0a020001, 0x05010100, 0x0a020001, 0x0a020001 },	\
-		{ 0x0a020001, 0x0a020001, 0x05020100, 0x0a020001, 0x0a020001 }	\
-	} },									\
-	{ 0x9848, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x0018da5a, 0x0018da5a, 0x0018ca69, 0x0018ca69, 0x0018ca69 },	\
-		{ 0x0018da6d, 0x0018da6d, 0x0018ca75, 0x0018ca75, 0x0018ca75 }	\
-	} },									\
-	{ 0x985c, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x3137665e, 0x3137665e, 0x3137665e, 0x3137665e, 0x3137615e },	\
-		{ 0x3137665e, 0x3137665e, 0x3137665e, 0x3137665e, 0x3137665e }	\
-	} },									\
-	{ 0x986c, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x050cb081, 0x050cb081, 0x050cb081, 0x050cb080, 0x050cb080 },	\
-		{ 0x050cb081, 0x050cb081, 0x050cb081, 0x050cb081, 0x050cb081 }	\
-	} },									\
-	{ 0x9914, AR5K_INI_FLAG_BOTH, {						\
-		{ 0x00002710, 0x00002710, 0x0000157c, 0x00002af8, 0x00002710 },	\
-		{ 0x000007d0, 0x000007d0, 0x0000044c, 0x00000898, 0x000007d0 }	\
-	} },									\
-	{ 0x9944, AR5K_INI_FLAG_BOTH, {						\
-		{ 0xffb81020, 0xffb81020, 0xffb80d20, 0xffb81020, 0xffb81020 },	\
-		{ 0xffb81020, 0xffb81020, 0xffb80d10, 0xffb81010, 0xffb81010 }	\
-	} },									\
-	{ 0xa204, AR5K_INI_FLAG_5112, {						\
-		{ 0, },								\
-		{ 0x00000000, 0x00000000, 0x00000004, 0x00000004, 0x00000004 }	\
-	} },									\
-	{ 0xa208, AR5K_INI_FLAG_BOTH, {						\
-		{ 0xd03e6788, 0xd03e6788, 0xd03e6788, 0xd03e6788, 0xd03e6788 },	\
-		{ 0xd6be6788, 0xd6be6788, 0xd03e6788, 0xd03e6788, 0xd03e6788 }	\
-	} },									\
-	{ 0xa20c, AR5K_INI_FLAG_5112, {						\
-		{ 0, },								\
-		{ 0x642c0140, 0x642c0140, 0x6442c160, 0x6442c160, 0x6442c160 }	\
-	} },									\
+/* Initial mode-specific settings for AR5212 */
+#define AR5K_AR5212_INI_MODE { \
+	{ AR5K_TXCFG,									\
+	/*	  a/XR	      aTurbo	  b	      g (DYN)	  gTurbo */		\
+		{ 0x00008107, 0x00008107, 0x00008107, 0x00008107, 0x00008107 } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(0),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(1),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(2),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(3),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(4),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(5),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(6),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(7),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(8),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_QUEUE_DFS_LOCAL_IFS(9),							\
+		{ 0x002ffc0f, 0x002ffc0f, 0x002ffc1f, 0x002ffc0f, 0x002ffc0f } },	\
+	{ AR5K_DCU_GBL_IFS_SIFS,							\
+		{ 0x00000230, 0x000001e0, 0x000000b0, 0x00000160, 0x000001e0 } },	\
+	{ AR5K_DCU_GBL_IFS_SLOT,							\
+		{ 0x00000168, 0x000001e0, 0x000001b8, 0x0000018c, 0x000001e0 } },	\
+	{ AR5K_DCU_GBL_IFS_EIFS,							\
+		{ 0x00000e60, 0x00001180, 0x00001f1c, 0x00003e38, 0x00001180 } },	\
+	{ AR5K_DCU_GBL_IFS_MISC,							\
+		{ 0x0000a0e0, 0x00014068, 0x00005880, 0x0000b0e0, 0x00014068 } },	\
+	{ AR5K_TIME_OUT,								\
+		{ 0x03e803e8, 0x06e006e0, 0x04200420, 0x08400840, 0x06e006e0 } },	\
 }
 
-struct ath5k_ar5211_ini_rf {
-	u16	rf_register;
-	u32	rf_value[2];
-};
+/* Initial mode-specific settings for AR5212 + RF5111 */
+#define AR5K_AR5212_RF5111_INI_MODE { \
+	{ AR5K_USEC_5211,								\
+	/*	  a/XR	      aTurbo	  b	      g		  gTurbo */		\
+		{ 0x128d8fa7, 0x09880fcf, 0x04e00f95, 0x128d8fab, 0x09880fcf } },	\
+	{ AR5K_PHY_TURBO,								\
+		{ 0x00000000, 0x00000003, 0x00000000, 0x00000000, 0x00000003 } },	\
+	{ 0x9820,									\
+		{ 0x02020200, 0x02020200, 0x02010200, 0x02020200, 0x02020200 } },	\
+	{ 0x9824,									\
+		{ 0x00000e0e, 0x00000e0e, 0x00000707, 0x00000e0e, 0x00000e0e } },	\
+	{ 0x9828,									\
+		{ 0x0a020001, 0x0a020001, 0x05010100, 0x0a020001, 0x0a020001 } },	\
+	{ 0x9834,									\
+		{ 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e } },	\
+	{ 0x9838,									\
+		{ 0x00000007, 0x00000007, 0x0000000b, 0x0000000b, 0x0000000b } },	\
+	{ 0x9844,									\
+		{ 0x1372161c, 0x13721c25, 0x13721728, 0x137216a2, 0x13721c25 } },	\
+	{ 0x9848,									\
+		{ 0x0018da5a, 0x0018da5a, 0x0018ca69, 0x0018ca69, 0x0018ca69 } },	\
+	{ 0x9850,									\
+		{ 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0 } },	\
+	{ AR5K_PHY_SIG,									\
+		{ 0x7e800d2e, 0x7e800d2e, 0x7ee84d2e, 0x7ee84d2e, 0x7e800d2e } },	\
+	{ AR5K_PHY_AGCCOARSE,								\
+		{ 0x3137665e, 0x3137665e, 0x3137665e, 0x3137665e, 0x3137615e } },	\
+	{ AR5K_PHY_AGCCTL,								\
+		{ 0x00009d10, 0x00009d10, 0x00009d18, 0x00009d10, 0x00009d10 } },	\
+	{ AR5K_PHY_NF,									\
+		{ 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00 } },	\
+	{ AR5K_PHY_ADCSAT,								\
+		{ 0x409a4190, 0x409a4190, 0x409a4190, 0x409a4190, 0x409a4190 } },	\
+	{ 0x986c,									\
+		{ 0x050cb081, 0x050cb081, 0x050cb081, 0x050cb080, 0x050cb080 } },	\
+	{ AR5K_PHY_RX_DELAY,								\
+		{ 0x00002710, 0x00002710, 0x0000157c, 0x00002af8, 0x00002710 } },	\
+	{ 0x9918,									\
+		{ 0x000001b8, 0x000001b8, 0x00000084, 0x00000108, 0x000001b8 } },	\
+	{ 0x9924,									\
+		{ 0x10058a05, 0x10058a05, 0x10058a05, 0x10058a05, 0x10058a05 } },	\
+	{ AR5K_PHY_FRAME_CTL_5211,							\
+		{ 0xffb81020, 0xffb81020, 0xffb80d20, 0xffb81020, 0xffb81020 } },	\
+	{ AR5K_PHY_PCDAC_TXPOWER(0),							\
+		{ 0x10ff14ff, 0x10ff14ff, 0x10ff10ff, 0x10ff19ff, 0x10ff19ff } },	\
+	{ 0xa230,									\
+		{ 0x00000000, 0x00000000, 0x00000000, 0x00000108, 0x00000000 } },	\
+	{ 0xa208,									\
+		{ 0xd03e6788, 0xd03e6788, 0xd03e6788, 0xd03e6788, 0xd03e6788 } },	\
+}
 
-#define AR5K_AR5211_INI_RF	{					\
-/* Static -> moved on ar5211_ini */					\
-	{ 0x0000a204, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000a208, { 0x503e4646, 0x503e4646 } },			\
-	{ 0x0000a20c, { 0x6480416c, 0x6480416c } },			\
-	{ 0x0000a210, { 0x0199a003, 0x0199a003 } },			\
-	{ 0x0000a214, { 0x044cd610, 0x044cd610 } },			\
-	{ 0x0000a218, { 0x13800040, 0x13800040 } },			\
-	{ 0x0000a21c, { 0x1be00060, 0x1be00060 } },			\
-	{ 0x0000a220, { 0x0c53800a, 0x0c53800a } },			\
-	{ 0x0000a224, { 0x0014df3b, 0x0014df3b } },			\
-	{ 0x0000a228, { 0x000001b5, 0x000001b5 } },			\
-	{ 0x0000a22c, { 0x00000020, 0x00000020 } },			\
-/* Bank 6 ? */								\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00380000, 0x00380000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x000400f9, 0x000400f9 } },			\
-	{ 0x000098d4, { 0x00000000, 0x00000004 } },			\
-/* Bank 7 ? */								\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x10000000, 0x10000000 } },			\
-	{ 0x0000989c, { 0x04000000, 0x04000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x00000000 } },			\
-	{ 0x0000989c, { 0x00000000, 0x0a000000 } },			\
-	{ 0x0000989c, { 0x00380080, 0x02380080 } },			\
-	{ 0x0000989c, { 0x00020006, 0x00000006 } },			\
-	{ 0x0000989c, { 0x00000092, 0x00000092 } },			\
-	{ 0x0000989c, { 0x000000a0, 0x000000a0 } },			\
-	{ 0x0000989c, { 0x00040007, 0x00040007 } },			\
-	{ 0x000098d4, { 0x0000001a, 0x0000001a } },			\
-	{ 0x0000989c, { 0x00000048, 0x00000048 } },			\
-	{ 0x0000989c, { 0x00000010, 0x00000010 } },			\
-	{ 0x0000989c, { 0x00000008, 0x00000008 } },			\
-	{ 0x0000989c, { 0x0000000f, 0x0000000f } },			\
-	{ 0x0000989c, { 0x000000f2, 0x00000062 } },			\
-	{ 0x0000989c, { 0x0000904f, 0x0000904c } },			\
-	{ 0x0000989c, { 0x0000125a, 0x0000129a } },			\
-	{ 0x000098cc, { 0x0000000e, 0x0000000f } },			\
+/* Initial mode-specific settings for AR5212 + RF5112 */
+#define AR5K_AR5212_RF5112_INI_MODE { \
+	{ AR5K_USEC_5211,								\
+	/*	  a/XR	      aTurbo	  b	      g		  gTurbo */		\
+		{ 0x128d93a7, 0x098813cf, 0x04e01395, 0x128d93ab, 0x098813cf } },	\
+	{ AR5K_PHY_TURBO,								\
+		{ 0x00000000, 0x00000003, 0x00000000, 0x00000000, 0x00000003 } },	\
+	{ 0x9820,									\
+		{ 0x02020200, 0x02020200, 0x02010200, 0x02020200, 0x02020200 } },	\
+	{ 0x9824,									\
+		{ 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e } },	\
+	{ 0x9828,									\
+		{ 0x0a020001, 0x0a020001, 0x05020100, 0x0a020001, 0x0a020001 } },	\
+	{ 0x9834,									\
+		{ 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e, 0x00000e0e } },	\
+	{ 0x9838,									\
+		{ 0x00000007, 0x00000007, 0x0000000b, 0x0000000b, 0x0000000b } },	\
+	{ 0x9844,									\
+		{ 0x1372161c, 0x13721c25, 0x13721728, 0x137216a2, 0x13721c25 } },	\
+	{ 0x9848,									\
+		{ 0x0018da6d, 0x0018da6d, 0x0018ca75, 0x0018ca75, 0x0018ca75 } },	\
+	{ 0x9850,									\
+		{ 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0, 0x0de8b4e0 } },	\
+	{ AR5K_PHY_SIG,									\
+		{ 0x7e800d2e, 0x7e800d2e, 0x7ee84d2e, 0x7ee84d2e, 0x7e800d2e } },	\
+	{ AR5K_PHY_AGCCOARSE,								\
+		{ 0x3137665e, 0x3137665e, 0x3137665e, 0x3137665e, 0x3137665e } },	\
+	{ AR5K_PHY_AGCCTL,								\
+		{ 0x00009d10, 0x00009d10, 0x00009d18, 0x00009d10, 0x00009d10 } },	\
+	{ AR5K_PHY_NF,									\
+		{ 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00, 0x0001ce00 } },	\
+	{ AR5K_PHY_ADCSAT,								\
+		{ 0x409a4190, 0x409a4190, 0x409a4190, 0x409a4190, 0x409a4190 } },	\
+	{ 0x986c,									\
+		{ 0x050cb081, 0x050cb081, 0x050cb081, 0x050cb081, 0x050cb081 } },	\
+	{ AR5K_PHY_RX_DELAY,								\
+		{ 0x000007d0, 0x000007d0, 0x0000044c, 0x00000898, 0x000007d0 } },	\
+	{ 0x9918,									\
+		{ 0x000001b8, 0x000001b8, 0x00000084, 0x00000108, 0x000001b8 } },	\
+	{ 0x9924,									\
+		{ 0x10058a05, 0x10058a05, 0x10058a05, 0x10058a05, 0x10058a05 } },	\
+	{ AR5K_PHY_FRAME_CTL_5211,							\
+		{ 0xffb81020, 0xffb81020, 0xffb80d10, 0xffb81010, 0xffb81010 } },	\
+	{ AR5K_PHY_PCDAC_TXPOWER(0),							\
+		{ 0x10ff14ff, 0x10ff14ff, 0x10ff10ff, 0x10ff19ff, 0x10ff19ff } },	\
+	{ 0xa230,									\
+		{ 0x00000000, 0x00000000, 0x00000000, 0x00000108, 0x00000000 } },	\
+	{ AR5K_PHY_CCKTXCTL,								\
+		{ 0x00000000, 0x00000000, 0x00000004, 0x00000004, 0x00000004 } },	\
+	{ 0xa208,									\
+		{ 0xd6be6788, 0xd6be6788, 0xd03e6788, 0xd03e6788, 0xd03e6788 } },	\
+	{ AR5K_PHY_GAIN_2GHZ,								\
+		{ 0x642c0140, 0x642c0140, 0x6442c160, 0x6442c160, 0x6442c160 } },	\
 }
