From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH v3] net: wireless: brcm80211: brcmsmac: phy: phy_cmn.c:  Remove some unused functions
Date: Sun, 21 Dec 2014 01:30:02 +0100
Message-ID: <1419121803-14422-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@adurom.com>,
	Fabian Frederick <fabf@skynet.be>,
	Peter Senna Tschudin <peter.senna@gmail.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:39925 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbaLUA1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 19:27:17 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so5039550wiv.8
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2014 16:27:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes some functions that are not used anywhere:
wlc_phy_edcrs_lock() wlc_phy_txpower_ipa_ison() wlc_phy_upd_rssi_offset()
wlc_phy_get_pwrdet_offsets() wlc_lcnphy_epa_switch() wlc_phy_stf_ssmode_get()
wlc_phy_stf_chain_get() write_phy_channel_reg() wlc_phy_BSSinit()
wlc_phy_set_deaf() wlc_phy_freqtrack_end() wlc_phy_freqtrack_start()
wlc_phy_noise_sample_request_external() wlc_phy_test_ison()
wlc_phy_txpower_hw_ctrl_set() wlc_phy_bf_preempt_enable()
wlc_phy_runbist_config() wlc_phy_txpwr_percent_set()
wlc_phy_txpower_get_target_max() wlc_radioreg_exit()
wlc_phy_txpower_get_target_min() wlc_phy_txpower_boardlimit_band()
wlc_phy_txpower_sromlimit_max_get() wlc_radioreg_enter()
wlc_phy_txpower_target_set() wlc_phy_chanspec_band_firstch()
wlc_phy_chanspec_bandrange_get() wlc_phy_bw_state_get() wlc_phy_clear_tssi()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |  433 --------------------
 .../net/wireless/brcm80211/brcmsmac/phy/phy_hal.h  |   29 --
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  |    8 -
 3 files changed, 470 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
index 941b1e4..af428bb 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
@@ -138,23 +138,6 @@ void wlc_phyreg_exit(struct brcms_phy_pub *pih)
 	wlapi_bmac_ucode_wake_override_phyreg_clear(pi->sh->physhim);
 }
 
-void wlc_radioreg_enter(struct brcms_phy_pub *pih)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-	wlapi_bmac_mctrl(pi->sh->physhim, MCTL_LOCK_RADIO, MCTL_LOCK_RADIO);
-
-	udelay(10);
-}
-
-void wlc_radioreg_exit(struct brcms_phy_pub *pih)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-
-	(void)bcma_read16(pi->d11core, D11REGOFFS(phyversion));
-	pi->phy_wreg = 0;
-	wlapi_bmac_mctrl(pi->sh->physhim, MCTL_LOCK_RADIO, 0);
-}
-
 u16 read_radio_reg(struct brcms_phy *pi, u16 addr)
 {
 	u16 data;
@@ -274,11 +257,6 @@ void mod_radio_reg(struct brcms_phy *pi, u16 addr, u16 mask, u16 val)
 	write_radio_reg(pi, addr, (rval & ~mask) | (val & mask));
 }
 
-void write_phy_channel_reg(struct brcms_phy *pi, uint val)
-{
-	bcma_write16(pi->d11core, D11REGOFFS(phychannel), val);
-}
-
 u16 read_phy_reg(struct brcms_phy *pi, u16 addr)
 {
 	bcma_wflush16(pi->d11core, D11REGOFFS(phyregaddr), addr);
@@ -703,18 +681,6 @@ void wlc_phy_por_inform(struct brcms_phy_pub *ppi)
 	pi->phy_init_por = true;
 }
 
-void wlc_phy_edcrs_lock(struct brcms_phy_pub *pih, bool lock)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-
-	pi->edcrs_threshold_lock = lock;
-
-	write_phy_reg(pi, 0x22c, 0x46b);
-	write_phy_reg(pi, 0x22d, 0x46b);
-	write_phy_reg(pi, 0x22e, 0x3c0);
-	write_phy_reg(pi, 0x22f, 0x3c0);
-}
-
 void wlc_phy_initcal_enable(struct brcms_phy_pub *pih, bool initcal)
 {
 	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
@@ -1094,20 +1060,6 @@ void wlc_phy_mute_upd(struct brcms_phy_pub *pih, bool mute, u32 flags)
 	return;
 }
 
-void wlc_phy_clear_tssi(struct brcms_phy_pub *pih)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-
-	if (ISNPHY(pi)) {
-		return;
-	} else {
-		wlapi_bmac_write_shm(pi->sh->physhim, M_B_TSSI_0, NULL_TSSI_W);
-		wlapi_bmac_write_shm(pi->sh->physhim, M_B_TSSI_1, NULL_TSSI_W);
-		wlapi_bmac_write_shm(pi->sh->physhim, M_G_TSSI_0, NULL_TSSI_W);
-		wlapi_bmac_write_shm(pi->sh->physhim, M_G_TSSI_1, NULL_TSSI_W);
-	}
-}
-
 static bool wlc_phy_cal_txpower_recalc_sw(struct brcms_phy *pi)
 {
 	return false;
@@ -1147,13 +1099,6 @@ void wlc_phy_switch_radio(struct brcms_phy_pub *pih, bool on)
 	}
 }
 
-u16 wlc_phy_bw_state_get(struct brcms_phy_pub *ppi)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	return pi->bw;
-}
-
 void wlc_phy_bw_state_set(struct brcms_phy_pub *ppi, u16 bw)
 {
 	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
@@ -1209,20 +1154,6 @@ int wlc_phy_chanspec_freq2bandrange_lpssn(uint freq)
 	return range;
 }
 
-int wlc_phy_chanspec_bandrange_get(struct brcms_phy *pi, u16 chanspec)
-{
-	int range = -1;
-	uint channel = CHSPEC_CHANNEL(chanspec);
-	uint freq = wlc_phy_channel2freq(channel);
-
-	if (ISNPHY(pi))
-		range = wlc_phy_get_chan_freq_range_nphy(pi, channel);
-	else if (ISLCNPHY(pi))
-		range = wlc_phy_chanspec_freq2bandrange_lpssn(freq);
-
-	return range;
-}
-
 void wlc_phy_chanspec_ch14_widefilter_set(struct brcms_phy_pub *ppi,
 					  bool wide_filter)
 {
@@ -1265,50 +1196,6 @@ wlc_phy_chanspec_band_validch(struct brcms_phy_pub *ppi, uint band,
 	}
 }
 
-u16 wlc_phy_chanspec_band_firstch(struct brcms_phy_pub *ppi, uint band)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-	uint i;
-	uint channel;
-	u16 chspec;
-
-	for (i = 0; i < ARRAY_SIZE(chan_info_all); i++) {
-		channel = chan_info_all[i].chan;
-
-		if (ISNPHY(pi) && pi->bw == WL_CHANSPEC_BW_40) {
-			uint j;
-
-			for (j = 0; j < ARRAY_SIZE(chan_info_all); j++) {
-				if (chan_info_all[j].chan ==
-				    channel + CH_10MHZ_APART)
-					break;
-			}
-
-			if (j == ARRAY_SIZE(chan_info_all))
-				continue;
-
-			channel = upper_20_sb(channel);
-			chspec =  channel | WL_CHANSPEC_BW_40 |
-				  WL_CHANSPEC_CTL_SB_LOWER;
-			if (band == BRCM_BAND_2G)
-				chspec |= WL_CHANSPEC_BAND_2G;
-			else
-				chspec |= WL_CHANSPEC_BAND_5G;
-		} else
-			chspec = ch20mhz_chspec(channel);
-
-		if ((pi->a_band_high_disable) && (channel >= FIRST_REF5_CHANNUM)
-		    && (channel <= LAST_REF5_CHANNUM))
-			continue;
-
-		if ((band == BRCM_BAND_2G && channel <= CH_MAX_2G_CHANNEL) ||
-		    (band == BRCM_BAND_5G && channel > CH_MAX_2G_CHANNEL))
-			return chspec;
-	}
-
-	return (u16) INVCHANSPEC;
-}
-
 int wlc_phy_txpower_get(struct brcms_phy_pub *ppi, uint *qdbm, bool *override)
 {
 	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
@@ -1319,56 +1206,6 @@ int wlc_phy_txpower_get(struct brcms_phy_pub *ppi, uint *qdbm, bool *override)
 	return 0;
 }
 
-void wlc_phy_txpower_target_set(struct brcms_phy_pub *ppi,
-				struct txpwr_limits *txpwr)
-{
-	bool mac_enabled = false;
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	memcpy(&pi->tx_user_target[TXP_FIRST_CCK],
-	       &txpwr->cck[0], BRCMS_NUM_RATES_CCK);
-
-	memcpy(&pi->tx_user_target[TXP_FIRST_OFDM],
-	       &txpwr->ofdm[0], BRCMS_NUM_RATES_OFDM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_OFDM_20_CDD],
-	       &txpwr->ofdm_cdd[0], BRCMS_NUM_RATES_OFDM);
-
-	memcpy(&pi->tx_user_target[TXP_FIRST_OFDM_40_SISO],
-	       &txpwr->ofdm_40_siso[0], BRCMS_NUM_RATES_OFDM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_OFDM_40_CDD],
-	       &txpwr->ofdm_40_cdd[0], BRCMS_NUM_RATES_OFDM);
-
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_20_SISO],
-	       &txpwr->mcs_20_siso[0], BRCMS_NUM_RATES_MCS_1_STREAM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_20_CDD],
-	       &txpwr->mcs_20_cdd[0], BRCMS_NUM_RATES_MCS_1_STREAM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_20_STBC],
-	       &txpwr->mcs_20_stbc[0], BRCMS_NUM_RATES_MCS_1_STREAM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_20_SDM],
-	       &txpwr->mcs_20_mimo[0], BRCMS_NUM_RATES_MCS_2_STREAM);
-
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_40_SISO],
-	       &txpwr->mcs_40_siso[0], BRCMS_NUM_RATES_MCS_1_STREAM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_40_CDD],
-	       &txpwr->mcs_40_cdd[0], BRCMS_NUM_RATES_MCS_1_STREAM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_40_STBC],
-	       &txpwr->mcs_40_stbc[0], BRCMS_NUM_RATES_MCS_1_STREAM);
-	memcpy(&pi->tx_user_target[TXP_FIRST_MCS_40_SDM],
-	       &txpwr->mcs_40_mimo[0], BRCMS_NUM_RATES_MCS_2_STREAM);
-
-	if (bcma_read32(pi->d11core, D11REGOFFS(maccontrol)) & MCTL_EN_MAC)
-		mac_enabled = true;
-
-	if (mac_enabled)
-		wlapi_suspend_mac_and_wait(pi->sh->physhim);
-
-	wlc_phy_txpower_recalc_target(pi);
-	wlc_phy_cal_txpower_recalc_sw(pi);
-
-	if (mac_enabled)
-		wlapi_enable_mac(pi->sh->physhim);
-}
-
 int wlc_phy_txpower_set(struct brcms_phy_pub *ppi, uint qdbm, bool override)
 {
 	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
@@ -1452,59 +1289,6 @@ wlc_phy_txpower_sromlimit(struct brcms_phy_pub *ppi, uint channel, u8 *min_pwr,
 	}
 }
 
-void
-wlc_phy_txpower_sromlimit_max_get(struct brcms_phy_pub *ppi, uint chan,
-				  u8 *max_txpwr, u8 *min_txpwr)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-	u8 tx_pwr_max = 0;
-	u8 tx_pwr_min = 255;
-	u8 max_num_rate;
-	u8 maxtxpwr, mintxpwr, rate, pactrl;
-
-	pactrl = 0;
-
-	max_num_rate = ISNPHY(pi) ? TXP_NUM_RATES :
-		       ISLCNPHY(pi) ? (TXP_LAST_SISO_MCS_20 +
-				       1) : (TXP_LAST_OFDM + 1);
-
-	for (rate = 0; rate < max_num_rate; rate++) {
-
-		wlc_phy_txpower_sromlimit(ppi, chan, &mintxpwr, &maxtxpwr,
-					  rate);
-
-		maxtxpwr = (maxtxpwr > pactrl) ? (maxtxpwr - pactrl) : 0;
-
-		maxtxpwr = (maxtxpwr > 6) ? (maxtxpwr - 6) : 0;
-
-		tx_pwr_max = max(tx_pwr_max, maxtxpwr);
-		tx_pwr_min = min(tx_pwr_min, maxtxpwr);
-	}
-	*max_txpwr = tx_pwr_max;
-	*min_txpwr = tx_pwr_min;
-}
-
-void
-wlc_phy_txpower_boardlimit_band(struct brcms_phy_pub *ppi, uint bandunit,
-				s32 *max_pwr, s32 *min_pwr, u32 *step_pwr)
-{
-	return;
-}
-
-u8 wlc_phy_txpower_get_target_min(struct brcms_phy_pub *ppi)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	return pi->tx_power_min;
-}
-
-u8 wlc_phy_txpower_get_target_max(struct brcms_phy_pub *ppi)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	return pi->tx_power_max;
-}
-
 static s8 wlc_phy_env_measure_vbat(struct brcms_phy *pi)
 {
 	if (ISLCNPHY(pi))
@@ -1810,13 +1594,6 @@ wlc_phy_txpower_reg_limit_calc(struct brcms_phy *pi, struct txpwr_limits *txpwr,
 	}
 }
 
-void wlc_phy_txpwr_percent_set(struct brcms_phy_pub *ppi, u8 txpwr_percent)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	pi->txpwr_percent = txpwr_percent;
-}
-
 void wlc_phy_machwcap_set(struct brcms_phy_pub *ppi, u32 machwcap)
 {
 	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
@@ -1824,35 +1601,6 @@ void wlc_phy_machwcap_set(struct brcms_phy_pub *ppi, u32 machwcap)
 	pi->sh->machwcap = machwcap;
 }
 
-void wlc_phy_runbist_config(struct brcms_phy_pub *ppi, bool start_end)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-	u16 rxc;
-	rxc = 0;
-
-	if (start_end == ON) {
-		if (!ISNPHY(pi))
-			return;
-
-		if (NREV_IS(pi->pubpi.phy_rev, 3)
-		    || NREV_IS(pi->pubpi.phy_rev, 4)) {
-			bcma_wflush16(pi->d11core, D11REGOFFS(phyregaddr),
-				      0xa0);
-			bcma_set16(pi->d11core, D11REGOFFS(phyregdata),
-				   0x1 << 15);
-		}
-	} else {
-		if (NREV_IS(pi->pubpi.phy_rev, 3)
-		    || NREV_IS(pi->pubpi.phy_rev, 4)) {
-			bcma_wflush16(pi->d11core, D11REGOFFS(phyregaddr),
-				      0xa0);
-			bcma_write16(pi->d11core, D11REGOFFS(phyregdata), rxc);
-		}
-
-		wlc_phy_por_inform(ppi);
-	}
-}
-
 void
 wlc_phy_txpower_limit_set(struct brcms_phy_pub *ppi, struct txpwr_limits *txpwr,
 			  u16 chanspec)
@@ -1886,13 +1634,6 @@ void wlc_phy_ofdm_rateset_war(struct brcms_phy_pub *pih, bool war)
 	pi->ofdm_rateset_war = war;
 }
 
-void wlc_phy_bf_preempt_enable(struct brcms_phy_pub *pih, bool bf_preempt)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-
-	pi->bf_preempt_4306 = bf_preempt;
-}
-
 void wlc_phy_txpower_update_shm(struct brcms_phy *pi)
 {
 	int j;
@@ -1953,37 +1694,6 @@ bool wlc_phy_txpower_hw_ctrl_get(struct brcms_phy_pub *ppi)
 		return pi->hwpwrctrl;
 }
 
-void wlc_phy_txpower_hw_ctrl_set(struct brcms_phy_pub *ppi, bool hwpwrctrl)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-	bool suspend;
-
-	if (!pi->hwpwrctrl_capable)
-		return;
-
-	pi->hwpwrctrl = hwpwrctrl;
-	pi->nphy_txpwrctrl = hwpwrctrl;
-	pi->txpwrctrl = hwpwrctrl;
-
-	if (ISNPHY(pi)) {
-		suspend = (0 == (bcma_read32(pi->d11core,
-					     D11REGOFFS(maccontrol)) &
-				 MCTL_EN_MAC));
-		if (!suspend)
-			wlapi_suspend_mac_and_wait(pi->sh->physhim);
-
-		wlc_phy_txpwrctrl_enable_nphy(pi, pi->nphy_txpwrctrl);
-		if (pi->nphy_txpwrctrl == PHY_TPC_HW_OFF)
-			wlc_phy_txpwr_fixpower_nphy(pi);
-		else
-			mod_phy_reg(pi, 0x1e7, (0x7f << 0),
-				    pi->saved_txpwr_idx);
-
-		if (!suspend)
-			wlapi_enable_mac(pi->sh->physhim);
-	}
-}
-
 void wlc_phy_txpower_ipa_upd(struct brcms_phy *pi)
 {
 
@@ -2141,13 +1851,6 @@ void wlc_phy_antsel_type_set(struct brcms_phy_pub *ppi, u8 antsel_type)
 	pi->antsel_type = antsel_type;
 }
 
-bool wlc_phy_test_ison(struct brcms_phy_pub *ppi)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	return pi->phytest_on;
-}
-
 void wlc_phy_ant_rxdiv_set(struct brcms_phy_pub *ppi, u8 val)
 {
 	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
@@ -2461,15 +2164,6 @@ done:
 
 }
 
-void wlc_phy_noise_sample_request_external(struct brcms_phy_pub *pih)
-{
-	u8 channel;
-
-	channel = CHSPEC_CHANNEL(wlc_phy_chanspec_get(pih));
-
-	wlc_phy_noise_sample_request(pih, PHY_NOISE_SAMPLE_EXTERNAL, channel);
-}
-
 static const s8 lcnphy_gain_index_offset_for_pkt_rssi[] = {
 	8,
 	8,
@@ -2568,27 +2262,6 @@ end:
 	return rssi;
 }
 
-void wlc_phy_freqtrack_start(struct brcms_phy_pub *pih)
-{
-	return;
-}
-
-void wlc_phy_freqtrack_end(struct brcms_phy_pub *pih)
-{
-	return;
-}
-
-void wlc_phy_set_deaf(struct brcms_phy_pub *ppi, bool user_flag)
-{
-	struct brcms_phy *pi;
-	pi = (struct brcms_phy *) ppi;
-
-	if (ISLCNPHY(pi))
-		wlc_lcnphy_deaf_mode(pi, true);
-	else if (ISNPHY(pi))
-		wlc_nphy_deaf_mode(pi, true);
-}
-
 void wlc_phy_watchdog(struct brcms_phy_pub *pih)
 {
 	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
@@ -2649,28 +2322,6 @@ void wlc_phy_watchdog(struct brcms_phy_pub *pih)
 	}
 }
 
-void wlc_phy_BSSinit(struct brcms_phy_pub *pih, bool bonlyap, int rssi)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-	uint i;
-	uint k;
-
-	for (i = 0; i < MA_WINDOW_SZ; i++)
-		pi->sh->phy_noise_window[i] = (s8) (rssi & 0xff);
-	if (ISLCNPHY(pi)) {
-		for (i = 0; i < MA_WINDOW_SZ; i++)
-			pi->sh->phy_noise_window[i] =
-				PHY_NOISE_FIXED_VAL_LCNPHY;
-	}
-	pi->sh->phy_noise_index = 0;
-
-	for (i = 0; i < PHY_NOISE_WINDOW_SZ; i++) {
-		for (k = WL_ANT_IDX_1; k < WL_ANT_RX_MAX; k++)
-			pi->nphy_noise_win[k][i] = PHY_NOISE_FIXED_VAL_NPHY;
-	}
-	pi->nphy_noise_index = 0;
-}
-
 void
 wlc_phy_papd_decode_epsilon(u32 epsilon, s32 *eps_real, s32 *eps_imag)
 {
@@ -2825,14 +2476,6 @@ void wlc_phy_stf_chain_set(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain)
 	pi->pubpi.phy_corenum = (u8)hweight8(pi->sh->phyrxchain);
 }
 
-void wlc_phy_stf_chain_get(struct brcms_phy_pub *pih, u8 *txchain, u8 *rxchain)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-
-	*txchain = pi->sh->phytxchain;
-	*rxchain = pi->sh->phyrxchain;
-}
-
 u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih)
 {
 	s16 nphy_currtemp;
@@ -2865,89 +2508,13 @@ u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih)
 	return active_bitmap;
 }
 
-s8 wlc_phy_stf_ssmode_get(struct brcms_phy_pub *pih, u16 chanspec)
-{
-	struct brcms_phy *pi = container_of(pih, struct brcms_phy, pubpi_ro);
-	u8 siso_mcs_id, cdd_mcs_id;
-
-	siso_mcs_id =
-		(CHSPEC_IS40(chanspec)) ? TXP_FIRST_MCS_40_SISO :
-		TXP_FIRST_MCS_20_SISO;
-	cdd_mcs_id =
-		(CHSPEC_IS40(chanspec)) ? TXP_FIRST_MCS_40_CDD :
-		TXP_FIRST_MCS_20_CDD;
-
-	if (pi->tx_power_target[siso_mcs_id] >
-	    (pi->tx_power_target[cdd_mcs_id] + 12))
-		return PHY_TXC1_MODE_SISO;
-	else
-		return PHY_TXC1_MODE_CDD;
-}
-
 const u8 *wlc_phy_get_ofdm_rate_lookup(void)
 {
 	return ofdm_rate_lookup;
 }
 
-void wlc_lcnphy_epa_switch(struct brcms_phy *pi, bool mode)
-{
-	if ((pi->sh->chip == BCMA_CHIP_ID_BCM4313) &&
-	    (pi->sh->boardflags & BFL_FEM)) {
-		if (mode) {
-			u16 txant = 0;
-			txant = wlapi_bmac_get_txant(pi->sh->physhim);
-			if (txant == 1) {
-				mod_phy_reg(pi, 0x44d, (0x1 << 2), (1) << 2);
-
-				mod_phy_reg(pi, 0x44c, (0x1 << 2), (1) << 2);
-
-			}
-
-			bcma_chipco_gpio_control(&pi->d11core->bus->drv_cc,
-						 0x0, 0x0);
-			bcma_chipco_gpio_out(&pi->d11core->bus->drv_cc,
-					     ~0x40, 0x40);
-			bcma_chipco_gpio_outen(&pi->d11core->bus->drv_cc,
-					       ~0x40, 0x40);
-		} else {
-			mod_phy_reg(pi, 0x44c, (0x1 << 2), (0) << 2);
-
-			mod_phy_reg(pi, 0x44d, (0x1 << 2), (0) << 2);
-
-			bcma_chipco_gpio_out(&pi->d11core->bus->drv_cc,
-					     ~0x40, 0x00);
-			bcma_chipco_gpio_outen(&pi->d11core->bus->drv_cc,
-					       ~0x40, 0x00);
-			bcma_chipco_gpio_control(&pi->d11core->bus->drv_cc,
-						 0x0, 0x40);
-		}
-	}
-}
-
 void wlc_phy_ldpc_override_set(struct brcms_phy_pub *ppi, bool ldpc)
 {
 	return;
 }
 
-void
-wlc_phy_get_pwrdet_offsets(struct brcms_phy *pi, s8 *cckoffset, s8 *ofdmoffset)
-{
-	*cckoffset = 0;
-	*ofdmoffset = 0;
-}
-
-s8 wlc_phy_upd_rssi_offset(struct brcms_phy *pi, s8 rssi, u16 chanspec)
-{
-
-	return rssi;
-}
-
-bool wlc_phy_txpower_ipa_ison(struct brcms_phy_pub *ppi)
-{
-	struct brcms_phy *pi = container_of(ppi, struct brcms_phy, pubpi_ro);
-
-	if (ISNPHY(pi))
-		return wlc_phy_n_txpower_ipa_ison(pi);
-	else
-		return 0;
-}
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
index 4d3734f..841f7c2 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
@@ -202,7 +202,6 @@ void wlc_phy_antsel_init(struct brcms_phy_pub *ppi, bool lut_init);
 void wlc_phy_chanspec_set(struct brcms_phy_pub *ppi, u16 chanspec);
 u16 wlc_phy_chanspec_get(struct brcms_phy_pub *ppi);
 void wlc_phy_chanspec_radio_set(struct brcms_phy_pub *ppi, u16 newch);
-u16 wlc_phy_bw_state_get(struct brcms_phy_pub *ppi);
 void wlc_phy_bw_state_set(struct brcms_phy_pub *ppi, u16 bw);
 
 int wlc_phy_rssi_compute(struct brcms_phy_pub *pih, struct d11rxhdr *rxh);
@@ -210,52 +209,32 @@ void wlc_phy_por_inform(struct brcms_phy_pub *ppi);
 void wlc_phy_noise_sample_intr(struct brcms_phy_pub *ppi);
 bool wlc_phy_bist_check_phy(struct brcms_phy_pub *ppi);
 
-void wlc_phy_set_deaf(struct brcms_phy_pub *ppi, bool user_flag);
-
 void wlc_phy_switch_radio(struct brcms_phy_pub *ppi, bool on);
 void wlc_phy_anacore(struct brcms_phy_pub *ppi, bool on);
 
 
-void wlc_phy_BSSinit(struct brcms_phy_pub *ppi, bool bonlyap, int rssi);
-
 void wlc_phy_chanspec_ch14_widefilter_set(struct brcms_phy_pub *ppi,
 					  bool wide_filter);
 void wlc_phy_chanspec_band_validch(struct brcms_phy_pub *ppi, uint band,
 				   struct brcms_chanvec *channels);
-u16 wlc_phy_chanspec_band_firstch(struct brcms_phy_pub *ppi, uint band);
 
 void wlc_phy_txpower_sromlimit(struct brcms_phy_pub *ppi, uint chan, u8 *_min_,
 			       u8 *_max_, int rate);
-void wlc_phy_txpower_sromlimit_max_get(struct brcms_phy_pub *ppi, uint chan,
-				       u8 *_max_, u8 *_min_);
-void wlc_phy_txpower_boardlimit_band(struct brcms_phy_pub *ppi, uint band,
-				     s32 *, s32 *, u32 *);
 void wlc_phy_txpower_limit_set(struct brcms_phy_pub *ppi, struct txpwr_limits *,
 			       u16 chanspec);
 int wlc_phy_txpower_get(struct brcms_phy_pub *ppi, uint *qdbm, bool *override);
 int wlc_phy_txpower_set(struct brcms_phy_pub *ppi, uint qdbm, bool override);
-void wlc_phy_txpower_target_set(struct brcms_phy_pub *ppi,
-				struct txpwr_limits *);
 bool wlc_phy_txpower_hw_ctrl_get(struct brcms_phy_pub *ppi);
-void wlc_phy_txpower_hw_ctrl_set(struct brcms_phy_pub *ppi, bool hwpwrctrl);
-u8 wlc_phy_txpower_get_target_min(struct brcms_phy_pub *ppi);
-u8 wlc_phy_txpower_get_target_max(struct brcms_phy_pub *ppi);
-bool wlc_phy_txpower_ipa_ison(struct brcms_phy_pub *pih);
 
 void wlc_phy_stf_chain_init(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain);
 void wlc_phy_stf_chain_set(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain);
-void wlc_phy_stf_chain_get(struct brcms_phy_pub *pih, u8 *txchain, u8 *rxchain);
 u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih);
-s8 wlc_phy_stf_ssmode_get(struct brcms_phy_pub *pih, u16 chanspec);
 void wlc_phy_ldpc_override_set(struct brcms_phy_pub *ppi, bool val);
 
 void wlc_phy_cal_perical(struct brcms_phy_pub *ppi, u8 reason);
-void wlc_phy_noise_sample_request_external(struct brcms_phy_pub *ppi);
-void wlc_phy_edcrs_lock(struct brcms_phy_pub *pih, bool lock);
 void wlc_phy_cal_papd_recal(struct brcms_phy_pub *ppi);
 
 void wlc_phy_ant_rxdiv_set(struct brcms_phy_pub *ppi, u8 val);
-void wlc_phy_clear_tssi(struct brcms_phy_pub *ppi);
 void wlc_phy_hold_upd(struct brcms_phy_pub *ppi, u32 id, bool val);
 void wlc_phy_mute_upd(struct brcms_phy_pub *ppi, bool val, u32 flags);
 
@@ -265,17 +244,9 @@ void wlc_phy_txpower_get_current(struct brcms_phy_pub *ppi,
 				 struct tx_power *power, uint channel);
 
 void wlc_phy_initcal_enable(struct brcms_phy_pub *pih, bool initcal);
-bool wlc_phy_test_ison(struct brcms_phy_pub *ppi);
-void wlc_phy_txpwr_percent_set(struct brcms_phy_pub *ppi, u8 txpwr_percent);
 void wlc_phy_ofdm_rateset_war(struct brcms_phy_pub *pih, bool war);
-void wlc_phy_bf_preempt_enable(struct brcms_phy_pub *pih, bool bf_preempt);
 void wlc_phy_machwcap_set(struct brcms_phy_pub *ppi, u32 machwcap);
 
-void wlc_phy_runbist_config(struct brcms_phy_pub *ppi, bool start_end);
-
-void wlc_phy_freqtrack_start(struct brcms_phy_pub *ppi);
-void wlc_phy_freqtrack_end(struct brcms_phy_pub *ppi);
-
 const u8 *wlc_phy_get_ofdm_rate_lookup(void);
 
 s8 wlc_phy_get_tx_power_offset_by_mcs(struct brcms_phy_pub *ppi,
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
index 4960f7d..22a77fd 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
@@ -926,8 +926,6 @@ void write_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
 
 void wlc_phyreg_enter(struct brcms_phy_pub *pih);
 void wlc_phyreg_exit(struct brcms_phy_pub *pih);
-void wlc_radioreg_enter(struct brcms_phy_pub *pih);
-void wlc_radioreg_exit(struct brcms_phy_pub *pih);
 
 void wlc_phy_read_table(struct brcms_phy *pi,
 			const struct phytbl_info *ptbl_info,
@@ -939,7 +937,6 @@ void wlc_phy_table_addr(struct brcms_phy *pi, uint tbl_id, uint tbl_offset,
 			u16 tblAddr, u16 tblDataHi, u16 tblDataLo);
 void wlc_phy_table_data_write(struct brcms_phy *pi, uint width, u32 val);
 
-void write_phy_channel_reg(struct brcms_phy *pi, uint val);
 void wlc_phy_txpower_update_shm(struct brcms_phy *pi);
 
 u8 wlc_phy_nbits(s32 value);
@@ -975,7 +972,6 @@ void wlc_phy_chanspec_set_lcnphy(struct brcms_phy *pi, u16 chanspec);
 void wlc_phy_chanspec_set_fixup_lcnphy(struct brcms_phy *pi, u16 chanspec);
 int wlc_phy_channel2freq(uint channel);
 int wlc_phy_chanspec_freq2bandrange_lpssn(uint);
-int wlc_phy_chanspec_bandrange_get(struct brcms_phy *, u16 chanspec);
 
 void wlc_lcnphy_set_tx_pwr_ctrl(struct brcms_phy *pi, u16 mode);
 s8 wlc_lcnphy_get_current_tx_pwr_idx(struct brcms_phy *pi);
@@ -1003,7 +999,6 @@ s8 wlc_lcnphy_tempsense_degree(struct brcms_phy *pi, bool mode);
 s8 wlc_lcnphy_vbatsense(struct brcms_phy *pi, bool mode);
 void wlc_phy_carrier_suppress_lcnphy(struct brcms_phy *pi);
 void wlc_lcnphy_crsuprs(struct brcms_phy *pi, int channel);
-void wlc_lcnphy_epa_switch(struct brcms_phy *pi, bool mode);
 void wlc_2064_vco_cal(struct brcms_phy *pi);
 
 void wlc_phy_txpower_recalc_target(struct brcms_phy *pi);
@@ -1134,9 +1129,6 @@ int wlc_phy_rssi_compute_nphy(struct brcms_phy *pi, struct d11rxhdr *rxh);
 
 void wlc_phy_nphy_tkip_rifs_war(struct brcms_phy *pi, u8 rifs);
 
-void wlc_phy_get_pwrdet_offsets(struct brcms_phy *pi, s8 *cckoffset,
-				s8 *ofdmoffset);
-s8 wlc_phy_upd_rssi_offset(struct brcms_phy *pi, s8 rssi, u16 chanspec);
 
 bool wlc_phy_n_txpower_ipa_ison(struct brcms_phy *pih);
 #endif				/* _BRCM_PHY_INT_H_ */
-- 
1.7.10.4
