From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 24/27] rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192de: rtl8723ae: Add changes required by adding rtl81988ee
Date: Mon, 25 Feb 2013 18:13:36 -0600
Message-ID: <1361837619-2985-25-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:39111 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab3BZAOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:50 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch combines the remaining changes in the rtlwifi family to handle
the addition of rtl8188ee.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/base.c               |  1 +
 drivers/net/wireless/rtlwifi/debug.h              |  6 +-
 drivers/net/wireless/rtlwifi/efuse.h              |  1 -
 drivers/net/wireless/rtlwifi/pci.c                |  3 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 12 +--
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c       | 20 ++---
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c       |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c       | 20 ++---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c       |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       | 24 +++---
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h      |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c       |  6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c       | 14 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c       | 26 +++---
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c       |  2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c       | 12 +--
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c       | 34 +++-----
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c      | 22 +++--
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c       |  2 +-
 drivers/net/wireless/rtlwifi/wifi.h               | 99 ++++++++++++++++++++---
 20 files changed, 194 insertions(+), 116 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index e5b14b8..fd684a0 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -471,6 +471,7 @@ int rtl_init_core(struct ieee80211_hw *hw)
 	spin_lock_init(&rtlpriv->locks.rf_lock);
 	spin_lock_init(&rtlpriv->locks.waitq_lock);
 	spin_lock_init(&rtlpriv->locks.entry_list_lock);
+	spin_lock_init(&rtlpriv->locks.fw_ps_lock);
 	spin_lock_init(&rtlpriv->locks.cck_and_rw_pagea_lock);
 	spin_lock_init(&rtlpriv->locks.check_sendpkt_lock);
 	spin_lock_init(&rtlpriv->locks.fw_ps_lock);
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 60119a6..6d66936 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -115,11 +115,11 @@
 /* Define EEPROM and EFUSE  check module bit*/
 #define EEPROM_W			BIT(0)
 #define EFUSE_PG			BIT(1)
-#define EFUSE_READ_ALL		BIT(2)
+#define EFUSE_READ_ALL			BIT(2)
 
 /* Define init check for module bit*/
 #define	INIT_EEPROM			BIT(0)
-#define	INIT_TxPower		BIT(1)
+#define	INIT_TXPOWER			BIT(1)
 #define	INIT_IQK			BIT(2)
 #define	INIT_RF				BIT(3)
 
@@ -142,6 +142,8 @@
 #define DM_DIG				BIT(3)
 #define DM_EDCA_TURBO			BIT(4)
 
+#define DM_PWDB				BIT(1)
+
 enum dbgp_flag_e {
 	FQOS = 0,
 	FTX = 1,
diff --git a/drivers/net/wireless/rtlwifi/efuse.h b/drivers/net/wireless/rtlwifi/efuse.h
index 2bdea9a..395a326 100644
--- a/drivers/net/wireless/rtlwifi/efuse.h
+++ b/drivers/net/wireless/rtlwifi/efuse.h
@@ -32,7 +32,6 @@
 
 #define EFUSE_IC_ID_OFFSET		506
 
-#define EFUSE_REAL_CONTENT_LEN		512
 #define EFUSE_MAP_LEN			128
 #define EFUSE_MAX_WORD_UNIT		4
 
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 3bd98f7..42c442e 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -672,6 +672,7 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 	skb = dev_alloc_skb(rtlpci->rxbuffersize);
 	if (!skb)
 		return 0;
+	kmemleak_not_leak(skb);
 	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
 
 	/* just set skb->cb to mapping addr
@@ -893,7 +894,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE, "beacon interrupt!\n");
 	}
 
-	if (inta & rtlpriv->cfg->maps[RTL_IMR_BcnInt]) {
+	if (inta & rtlpriv->cfg->maps[RTL_IMR_BCNINT]) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
 			 "prepare beacon for interrupt!\n");
 		tasklet_schedule(&rtlpriv->works.irq_prepare_bcn_tasklet);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index b0b9f90..926e2a3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -174,8 +174,8 @@ static void rtl92c_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
 	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
 	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	dm_digtable->rx_gain_range_max = DM_DIG_MAX;
-	dm_digtable->rx_gain_range_min = DM_DIG_MIN;
+	dm_digtable->rx_gain_max = DM_DIG_MAX;
+	dm_digtable->rx_gain_min = DM_DIG_MIN;
 	dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
 	dm_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
 	dm_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
@@ -300,11 +300,11 @@ static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
 	}
 
 	if ((digtable->rssi_val_min + 10 - digtable->back_val) >
-	    digtable->rx_gain_range_max)
-		digtable->cur_igvalue = digtable->rx_gain_range_max;
+	    digtable->rx_gain_max)
+		digtable->cur_igvalue = digtable->rx_gain_max;
 	else if ((digtable->rssi_val_min + 10 -
-		  digtable->back_val) < digtable->rx_gain_range_min)
-		digtable->cur_igvalue = digtable->rx_gain_range_min;
+		  digtable->back_val) < digtable->rx_gain_min)
+		digtable->cur_igvalue = digtable->rx_gain_min;
 	else
 		digtable->cur_igvalue = digtable->rssi_val_min + 10 -
 		    digtable->back_val;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 3da9a78..a82b30a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1503,7 +1503,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		}
 
 		for (i = 0; i < 14; i++) {
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n",
 				rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
@@ -1544,11 +1544,11 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				      & 0xf0) >> 4);
 			}
 
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht20[%d] = 0x%x\n",
 				rf_path, i,
 				rtlefuse->pwrgroup_ht20[rf_path][i]);
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht40[%d] = 0x%x\n",
 				rf_path, i,
 				rtlefuse->pwrgroup_ht40[rf_path][i]);
@@ -1589,19 +1589,19 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	    rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][7];
 
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 
@@ -1609,7 +1609,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_regulatory = (hwinfo[RF_OPTION1] & 0x7);
 	else
 		rtlefuse->eeprom_regulatory = 0;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 
 	if (!autoload_fail) {
@@ -1619,7 +1619,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = EEPROM_DEFAULT_TSSI;
 		rtlefuse->eeprom_tssi[RF90_PATH_B] = EEPROM_DEFAULT_TSSI;
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
 		rtlefuse->eeprom_tssi[RF90_PATH_A],
 		rtlefuse->eeprom_tssi[RF90_PATH_B]);
 
@@ -1633,7 +1633,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->apk_thermalmeterignore = true;
 
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 7347f59..1420356 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -311,7 +311,7 @@ static struct rtl_hal_cfg rtl92ce_hal_cfg = {
 
 	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
 	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
-	.maps[RTL_IMR_BcnInt] = IMR_BCNINT,
+	.maps[RTL_IMR_BCNINT] = IMR_BCNINT,
 	.maps[RTL_IMR_RXFOVW] = IMR_RXFOVW,
 	.maps[RTL_IMR_RDU] = IMR_RDU,
 	.maps[RTL_IMR_ATIMEND] = IMR_ATIMEND,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index b1ccff4..a586c1b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -202,7 +202,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			}
 		}
 		for (i = 0; i < 14; i++) {
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n", rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
 				rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
@@ -238,11 +238,11 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				    ((rtlefuse->eeprom_pwrlimit_ht40[index]
 				      & 0xf0) >> 4);
 			}
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht20[%d] = 0x%x\n",
 				rf_path, i,
 				rtlefuse->pwrgroup_ht20[rf_path][i]);
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht40[%d] = 0x%x\n",
 				rf_path, i,
 				rtlefuse->pwrgroup_ht40[rf_path][i]);
@@ -273,26 +273,26 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	rtlefuse->legacy_ht_txpowerdiff =
 	    rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][7];
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 	if (!autoload_fail)
 		rtlefuse->eeprom_regulatory = (hwinfo[RF_OPTION1] & 0x7);
 	else
 		rtlefuse->eeprom_regulatory = 0;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 	if (!autoload_fail) {
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = hwinfo[EEPROM_TSSI_A];
@@ -301,7 +301,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = EEPROM_DEFAULT_TSSI;
 		rtlefuse->eeprom_tssi[RF90_PATH_B] = EEPROM_DEFAULT_TSSI;
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"TSSI_A = 0x%x, TSSI_B = 0x%x\n",
 		rtlefuse->eeprom_tssi[RF90_PATH_A],
 		rtlefuse->eeprom_tssi[RF90_PATH_B]);
@@ -316,7 +316,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	if (rtlefuse->eeprom_thermalmeter == 0x1f || autoload_fail)
 		rtlefuse->apk_thermalmeterignore = true;
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 97b7349..970dac3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -223,7 +223,7 @@ static struct rtl_hal_cfg rtl92cu_hal_cfg = {
 
 	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
 	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
-	.maps[RTL_IMR_BcnInt] = IMR_BCNINT,
+	.maps[RTL_IMR_BCNINT] = IMR_BCNINT,
 	.maps[RTL_IMR_RXFOVW] = IMR_RXFOVW,
 	.maps[RTL_IMR_RDU] = IMR_RDU,
 	.maps[RTL_IMR_ATIMEND] = IMR_ATIMEND,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index 5251fb8..55b2a2a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -171,8 +171,8 @@ static void rtl92d_dm_diginit(struct ieee80211_hw *hw)
 	de_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
 	de_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
 	de_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	de_digtable->rx_gain_range_max = DM_DIG_FA_UPPER;
-	de_digtable->rx_gain_range_min = DM_DIG_FA_LOWER;
+	de_digtable->rx_gain_max = DM_DIG_FA_UPPER;
+	de_digtable->rx_gain_min = DM_DIG_FA_LOWER;
 	de_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
 	de_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
 	de_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
@@ -444,8 +444,8 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 		 "dm_DIG() Before: large_fa_hit=%d, forbidden_igi=%x\n",
 		 de_digtable->large_fa_hit, de_digtable->forbidden_igi);
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 "dm_DIG() Before: Recover_cnt=%d, rx_gain_range_min=%x\n",
-		 de_digtable->recover_cnt, de_digtable->rx_gain_range_min);
+		 "dm_DIG() Before: Recover_cnt=%d, rx_gain_min=%x\n",
+		 de_digtable->recover_cnt, de_digtable->rx_gain_min);
 
 	/* deal with abnorally large false alarm */
 	if (falsealm_cnt->cnt_all > 10000) {
@@ -459,9 +459,9 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 		}
 		if (de_digtable->large_fa_hit >= 3) {
 			if ((de_digtable->forbidden_igi + 1) > DM_DIG_MAX)
-				de_digtable->rx_gain_range_min = DM_DIG_MAX;
+				de_digtable->rx_gain_min = DM_DIG_MAX;
 			else
-				de_digtable->rx_gain_range_min =
+				de_digtable->rx_gain_min =
 				    (de_digtable->forbidden_igi + 1);
 			de_digtable->recover_cnt = 3600;	/* 3600=2hr */
 		}
@@ -475,12 +475,12 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 				    DM_DIG_FA_LOWER) {
 					de_digtable->forbidden_igi =
 							 DM_DIG_FA_LOWER;
-					de_digtable->rx_gain_range_min =
+					de_digtable->rx_gain_min =
 							 DM_DIG_FA_LOWER;
 
 				} else {
 					de_digtable->forbidden_igi--;
-					de_digtable->rx_gain_range_min =
+					de_digtable->rx_gain_min =
 					    (de_digtable->forbidden_igi + 1);
 				}
 			} else if (de_digtable->large_fa_hit == 3) {
@@ -492,13 +492,13 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 		 "dm_DIG() After: large_fa_hit=%d, forbidden_igi=%x\n",
 		 de_digtable->large_fa_hit, de_digtable->forbidden_igi);
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 "dm_DIG() After: recover_cnt=%d, rx_gain_range_min=%x\n",
-		 de_digtable->recover_cnt, de_digtable->rx_gain_range_min);
+		 "dm_DIG() After: recover_cnt=%d, rx_gain_min=%x\n",
+		 de_digtable->recover_cnt, de_digtable->rx_gain_min);
 
 	if (value_igi > DM_DIG_MAX)
 		value_igi = DM_DIG_MAX;
-	else if (value_igi < de_digtable->rx_gain_range_min)
-		value_igi = de_digtable->rx_gain_range_min;
+	else if (value_igi < de_digtable->rx_gain_min)
+		value_igi = de_digtable->rx_gain_min;
 	de_digtable->cur_igvalue = value_igi;
 	rtl92d_dm_write_dig(hw);
 	if (rtlpriv->rtlhal.current_bandtype != BAND_ON_5G)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/reg.h b/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
index ebb1d5f..b7498c5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/reg.h
@@ -543,7 +543,7 @@
 #define	IMR_TIMEOUT1			BIT(16)
 #define	IMR_TXFOVW			BIT(15)
 #define	IMR_PSTIMEOUT			BIT(14)
-#define	IMR_BcnInt			BIT(13)
+#define	IMR_BCNINT			BIT(13)
 #define	IMR_RXFOVW			BIT(12)
 #define	IMR_RDU				BIT(11)
 #define	IMR_ATIMEND			BIT(10)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index 03c6d18..c18c04b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -166,7 +166,7 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
 
 	/* for early mode */
-	rtlpriv->rtlhal.earlymode_enable = true;
+	rtlpriv->rtlhal.earlymode_enable = false;
 	for (tid = 0; tid < 8; tid++)
 		skb_queue_head_init(&rtlpriv->mac80211.skb_waitq[tid]);
 
@@ -319,7 +319,7 @@ static struct rtl_hal_cfg rtl92de_hal_cfg = {
 
 	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
 	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
-	.maps[RTL_IMR_BcnInt] = IMR_BcnInt,
+	.maps[RTL_IMR_BCNINT] = IMR_BCNINT,
 	.maps[RTL_IMR_RXFOVW] = IMR_RXFOVW,
 	.maps[RTL_IMR_RDU] = IMR_RDU,
 	.maps[RTL_IMR_ATIMEND] = IMR_ATIMEND,
@@ -333,7 +333,7 @@ static struct rtl_hal_cfg rtl92de_hal_cfg = {
 	.maps[RTL_IMR_VIDOK] = IMR_VIDOK,
 	.maps[RTL_IMR_VODOK] = IMR_VODOK,
 	.maps[RTL_IMR_ROK] = IMR_ROK,
-	.maps[RTL_IBSS_INT_MASKS] = (IMR_BcnInt | IMR_TBDOK | IMR_TBDER),
+	.maps[RTL_IBSS_INT_MASKS] = (IMR_BCNINT | IMR_TBDOK | IMR_TBDER),
 
 	.maps[RTL_RC_CCK_RATE1M] = DESC92_RATE1M,
 	.maps[RTL_RC_CCK_RATE2M] = DESC92_RATE2M,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index e2a0faa..b3a2d5e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -472,13 +472,13 @@ static void _rtl92s_dm_initial_gain_sta_beforeconnect(struct ieee80211_hw *hw)
 				digtable->back_val = DM_DIG_BACKOFF;
 
 			if ((digtable->rssi_val + 10 - digtable->back_val) >
-				digtable->rx_gain_range_max)
+				digtable->rx_gain_max)
 				digtable->cur_igvalue =
-						digtable->rx_gain_range_max;
+						digtable->rx_gain_max;
 			else if ((digtable->rssi_val + 10 - digtable->back_val)
-				 < digtable->rx_gain_range_min)
+				 < digtable->rx_gain_min)
 				digtable->cur_igvalue =
-						digtable->rx_gain_range_min;
+						digtable->rx_gain_min;
 			else
 				digtable->cur_igvalue = digtable->rssi_val + 10
 					- digtable->back_val;
@@ -490,7 +490,7 @@ static void _rtl92s_dm_initial_gain_sta_beforeconnect(struct ieee80211_hw *hw)
 
 			if (falsealm_cnt->cnt_all > 16000)
 				digtable->cur_igvalue =
-						 digtable->rx_gain_range_max;
+						 digtable->rx_gain_max;
 		/* connected -> connected or disconnected -> disconnected  */
 		} else {
 			/* Firmware control DIG, do nothing in driver dm */
@@ -692,9 +692,9 @@ static void _rtl92s_dm_init_dig(struct ieee80211_hw *hw)
 	/* for dig debug rssi value */
 	digtable->rssi_val = 50;
 	digtable->back_val = DM_DIG_BACKOFF;
-	digtable->rx_gain_range_max = DM_DIG_MAX;
+	digtable->rx_gain_max = DM_DIG_MAX;
 
-	digtable->rx_gain_range_min = DM_DIG_MIN;
+	digtable->rx_gain_min = DM_DIG_MIN;
 
 	digtable->backoffval_range_max = DM_DIG_BACKOFF_MAX;
 	digtable->backoffval_range_min = DM_DIG_BACKOFF_MIN;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index a4f41b1..4f46178 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1791,7 +1791,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 		}
 
 		for (i = 0; i < 14; i++) {
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n",
 				rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
@@ -1828,11 +1828,11 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 				((rtlefuse->eeprom_pwrgroup[rf_path][index] &
 				0xf0) >> 4);
 
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht20[%d] = 0x%x\n",
 				rf_path, i,
 				rtlefuse->pwrgroup_ht20[rf_path][i]);
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht40[%d] = 0x%x\n",
 				rf_path, i,
 				rtlefuse->pwrgroup_ht40[rf_path][i]);
@@ -1887,27 +1887,27 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 			rtlefuse->eeprom_regulatory =
 				 (hwinfo[EEPROM_REGULATORY] & 0x1);
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n",
 			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"TxPwrSafetyFlag = %d\n", rtlefuse->txpwr_safetyflag);
 
 	/* Read RF-indication and Tx Power gain
@@ -1917,7 +1917,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->legacy_httxpowerdiff =
 		rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][0];
 
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"TxPowerDiff = %#x\n", rtlefuse->eeprom_txpowerdiff);
 
 	/* Get TSSI value for each path. */
@@ -1926,7 +1926,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	usvalue = hwinfo[EEPROM_TSSI_B];
 	rtlefuse->eeprom_tssi[RF90_PATH_B] = (u8)(usvalue & 0xff);
 
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
 		rtlefuse->eeprom_tssi[RF90_PATH_A],
 		rtlefuse->eeprom_tssi[RF90_PATH_B]);
 
@@ -1934,7 +1934,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	/* and read ThermalMeter from EEPROM */
 	tempval = hwinfo[EEPROM_THERMALMETER];
 	rtlefuse->eeprom_thermalmeter = tempval;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 
 	/* ThermalMeter, BIT(0)~3 for RFIC1, BIT(4)~7 for RFIC2 */
@@ -1951,7 +1951,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	/* Version ID, Channel plan */
 	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->txpwr_fromeprom = true;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"EEPROM ChannelPlan = 0x%4x\n", rtlefuse->eeprom_channelplan);
 
 	/* Read Customer ID or Board Type!!! */
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 2c115b0..2e8e6f8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -367,7 +367,7 @@ static struct rtl_hal_cfg rtl92se_hal_cfg = {
 
 	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
 	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
-	.maps[RTL_IMR_BcnInt] = IMR_BCNINT,
+	.maps[RTL_IMR_BCNINT] = IMR_BCNINT,
 	.maps[RTL_IMR_RXFOVW] = IMR_RXFOVW,
 	.maps[RTL_IMR_RDU] = IMR_RDU,
 	.maps[RTL_IMR_ATIMEND] = IMR_ATIMEND,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index f9b7467..a36eee2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -166,8 +166,8 @@ static void rtl8723ae_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
 	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
 	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	dm_digtable->rx_gain_range_max = DM_DIG_MAX;
-	dm_digtable->rx_gain_range_min = DM_DIG_MIN;
+	dm_digtable->rx_gain_max = DM_DIG_MAX;
+	dm_digtable->rx_gain_min = DM_DIG_MIN;
 	dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
 	dm_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
 	dm_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
@@ -291,11 +291,11 @@ static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
 	}
 
 	if ((dgtbl->rssi_val_min + 10 - dgtbl->back_val) >
-	    dgtbl->rx_gain_range_max)
-		dgtbl->cur_igvalue = dgtbl->rx_gain_range_max;
+	    dgtbl->rx_gain_max)
+		dgtbl->cur_igvalue = dgtbl->rx_gain_max;
 	else if ((dgtbl->rssi_val_min + 10 -
-		  dgtbl->back_val) < dgtbl->rx_gain_range_min)
-		dgtbl->cur_igvalue = dgtbl->rx_gain_range_min;
+		  dgtbl->back_val) < dgtbl->rx_gain_min)
+		dgtbl->cur_igvalue = dgtbl->rx_gain_min;
 	else
 		dgtbl->cur_igvalue = dgtbl->rssi_val_min + 10 - dgtbl->back_val;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 1784622..c333dfd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -1415,7 +1415,7 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		}
 
 		for (i = 0; i < 14; i++) {
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = "
 				"[0x%x / 0x%x / 0x%x]\n", rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
@@ -1456,10 +1456,10 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				    0xf0) >> 4);
 			}
 
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht20[%d] = 0x%x\n", rf_path, i,
 				rtlefuse->pwrgroup_ht20[rf_path][i]);
-			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF-%d pwrgroup_ht40[%d] = 0x%x\n", rf_path, i,
 				rtlefuse->pwrgroup_ht40[rf_path][i]);
 		}
@@ -1499,19 +1499,19 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	    rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][7];
 
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n", i,
 			rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n", i,
 			rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n", i,
 			rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
-		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n", i,
 			rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 
@@ -1519,14 +1519,14 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_regulatory = (hwinfo[RF_OPTION1] & 0x7);
 	else
 		rtlefuse->eeprom_regulatory = 0;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 
 	if (!autoload_fail)
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = hwinfo[EEPROM_TSSI_A];
 	else
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = EEPROM_DEFAULT_TSSI;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"TSSI_A = 0x%x, TSSI_B = 0x%x\n",
 		rtlefuse->eeprom_tssi[RF90_PATH_A],
 		rtlefuse->eeprom_tssi[RF90_PATH_B]);
@@ -1541,7 +1541,7 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->apk_thermalmeterignore = true;
 
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 }
 
@@ -1749,19 +1749,7 @@ static void _rtl8723ae_hal_customized_behavior(struct ieee80211_hw *hw)
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
-	switch (rtlhal->oem_id) {
-	case RT_CID_819x_HP:
-		pcipriv->ledctl.led_opendrain = true;
-		break;
-	case RT_CID_819x_Lenovo:
-	case RT_CID_DEFAULT:
-	case RT_CID_TOSHIBA:
-	case RT_CID_CCX:
-	case RT_CID_819x_Acer:
-	case RT_CID_WHQL:
-	default:
-		break;
-	}
+	pcipriv->ledctl.led_opendrain = true;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		 "RT Customized ID: 0x%02X\n", rtlhal->oem_id);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/led.c b/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
index 9c4e1d8..061526f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
@@ -54,8 +54,9 @@ void rtl8723ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	case LED_PIN_GPIO0:
 		break;
 	case LED_PIN_LED0:
+		ledcfg &= ~BIT(6);
 		rtl_write_byte(rtlpriv,
-			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5) | BIT(6));
+			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5));
 		break;
 	case LED_PIN_LED1:
 		rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg & 0x0f) | BIT(5));
@@ -84,16 +85,21 @@ void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	case LED_PIN_LED0:
 		ledcfg &= 0xf0;
-		if (pcipriv->ledctl.led_opendrain)
+		if (pcipriv->ledctl.led_opendrain) {
+			ledcfg &= 0x90;
+			rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg|BIT(3)));
+			ledcfg = rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
+			ledcfg &= 0xFE;
+			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG, ledcfg);
+		} else {
+			ledcfg &= ~BIT(6);
 			rtl_write_byte(rtlpriv, REG_LEDCFG2,
-				       (ledcfg | BIT(1) | BIT(5) | BIT(6)));
-		else
-			rtl_write_byte(rtlpriv, REG_LEDCFG2,
-				       (ledcfg | BIT(3) | BIT(5) | BIT(6)));
+				       (ledcfg | BIT(3) | BIT(5)));
+		}
 		break;
 	case LED_PIN_LED1:
-		ledcfg &= 0x0f;
-		rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg | BIT(3)));
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1) & 0x10;
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, (ledcfg | BIT(3)));
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
index bb7cc90..e4c4cdc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
@@ -305,7 +305,7 @@ static struct rtl_hal_cfg rtl8723ae_hal_cfg = {
 
 	.maps[RTL_IMR_TXFOVW] = PHIMR_TXFOVW,
 	.maps[RTL_IMR_PSTIMEOUT] = PHIMR_PSTIMEOUT,
-	.maps[RTL_IMR_BcnInt] = PHIMR_BCNDMAINT0,
+	.maps[RTL_IMR_BCNINT] = PHIMR_BCNDMAINT0,
 	.maps[RTL_IMR_RXFOVW] = PHIMR_RXFOVW,
 	.maps[RTL_IMR_RDU] = PHIMR_RDU,
 	.maps[RTL_IMR_ATIMEND] = PHIMR_ATIMEND_E,
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index f6825c1..c3a8e9e 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -99,12 +99,36 @@
 #define	CHANNEL_GROUP_MAX_5G		9
 #define CHANNEL_MAX_NUMBER_2G		14
 #define AVG_THERMAL_NUM			8
+#define AVG_THERMAL_NUM_88E		4
 #define MAX_TID_COUNT			9
 
 /* for early mode */
 #define FCS_LEN				4
 #define EM_HDR_LEN			8
 
+#define MAX_TX_COUNT			4
+#define	MAX_RF_PATH			4
+#define	MAX_CHNL_GROUP_24G		6
+#define	MAX_CHNL_GROUP_5G		14
+
+struct txpower_info_2g {
+	u8 index_cck_base[MAX_RF_PATH][MAX_CHNL_GROUP_24G];
+	u8 index_bw40_base[MAX_RF_PATH][MAX_CHNL_GROUP_24G];
+	/*If only one tx, only BW20 and OFDM are used.*/
+	u8 cck_diff[MAX_RF_PATH][MAX_TX_COUNT];
+	u8 ofdm_diff[MAX_RF_PATH][MAX_TX_COUNT];
+	u8 bw20_diff[MAX_RF_PATH][MAX_TX_COUNT];
+	u8 bw40_diff[MAX_RF_PATH][MAX_TX_COUNT];
+};
+
+struct txpower_info_5g {
+	u8 index_bw40_base[MAX_RF_PATH][MAX_CHNL_GROUP_5G];
+	/*If only one tx, only BW20, OFDM, BW80 and BW160 are used.*/
+	u8 ofdm_diff[MAX_RF_PATH][MAX_TX_COUNT];
+	u8 bw20_diff[MAX_RF_PATH][MAX_TX_COUNT];
+	u8 bw40_diff[MAX_RF_PATH][MAX_TX_COUNT];
+};
+
 enum intf_type {
 	INTF_PCI = 0,
 	INTF_USB = 1,
@@ -499,7 +523,7 @@ enum rtl_var_map {
 	RTL_IMR_TIMEOUT1,	/*Timeout interrupt 1 */
 	RTL_IMR_TXFOVW,		/*Transmit FIFO Overflow */
 	RTL_IMR_PSTIMEOUT,	/*Power save time out interrupt */
-	RTL_IMR_BcnInt,		/*Beacon DMA Interrupt 0 */
+	RTL_IMR_BCNINT,		/*Beacon DMA Interrupt 0 */
 	RTL_IMR_RXFOVW,		/*Receive FIFO Overflow */
 	RTL_IMR_RDU,		/*Receive Descriptor Unavailable */
 	RTL_IMR_ATIMEND,	/*For 92C,ATIM Window End Interrupt */
@@ -514,7 +538,7 @@ enum rtl_var_map {
 	RTL_IMR_VIDOK,		/*AC_VI DMA OK Interrupt */
 	RTL_IMR_VODOK,		/*AC_VO DMA Interrupt */
 	RTL_IMR_ROK,		/*Receive DMA OK Interrupt */
-	RTL_IBSS_INT_MASKS,	/*(RTL_IMR_BcnInt | RTL_IMR_TBDOK |
+	RTL_IBSS_INT_MASKS,	/*(RTL_IMR_BCNINT | RTL_IMR_TBDOK |
 				 * RTL_IMR_TBDER) */
 	RTL_IMR_C2HCMD,		/*fw interrupt*/
 
@@ -1278,6 +1302,29 @@ struct rtl_security {
 	u8 *pairwise_key;
 };
 
+#define ASSOCIATE_ENTRY_NUM	33
+
+struct fast_ant_training {
+	u8	bssid[6];
+	u8	antsel_rx_keep_0;
+	u8	antsel_rx_keep_1;
+	u8	antsel_rx_keep_2;
+	u32	ant_sum[7];
+	u32	ant_cnt[7];
+	u32	ant_ave[7];
+	u8	fat_state;
+	u32	train_idx;
+	u8	antsel_a[ASSOCIATE_ENTRY_NUM];
+	u8	antsel_b[ASSOCIATE_ENTRY_NUM];
+	u8	antsel_c[ASSOCIATE_ENTRY_NUM];
+	u32	main_ant_sum[ASSOCIATE_ENTRY_NUM];
+	u32	aux_ant_sum[ASSOCIATE_ENTRY_NUM];
+	u32	main_ant_cnt[ASSOCIATE_ENTRY_NUM];
+	u32	aux_ant_cnt[ASSOCIATE_ENTRY_NUM];
+	u8	rx_idle_ant;
+	bool	becomelinked;
+};
+
 struct rtl_dm {
 	/*PHY status for Dynamic Management */
 	long entry_min_undec_sm_pwdb;
@@ -1314,9 +1361,24 @@ struct rtl_dm {
 	bool disable_tx_int;
 	char ofdm_index[2];
 	char cck_index;
+	char delta_power_index;
+	char delta_power_index_last;
+	char power_index_offset;
+
+	/*88e tx power tracking*/
+	u8	swing_idx_ofdm[2];
+	u8	swing_idx_ofdm_cur;
+	u8	swing_idx_ofdm_base;
+	bool	swing_flag_ofdm;
+	u8	swing_idx_cck;
+	u8	swing_idx_cck_cur;
+	u8	swing_idx_cck_base;
+	bool	swing_flag_cck;
 
 	/* DMSP */
 	bool supp_phymode_switch;
+
+	struct fast_ant_training fat_table;
 };
 
 #define	EFUSE_MAX_LOGICAL_SIZE			256
@@ -1349,6 +1411,9 @@ struct rtl_efuse {
 	u8 external_pa;
 
 	u8 dev_addr[6];
+	u8 wowlan_enable;
+	u8 antenna_div_cfg;
+	u8 antenna_div_type;
 
 	bool txpwr_fromeprom;
 	u8 eeprom_crystalcap;
@@ -1404,14 +1469,12 @@ struct rtl_ps_ctl {
 	bool rfchange_inprogress;
 	bool swrf_processing;
 	bool hwradiooff;
-
 	/*
 	 * just for PCIE ASPM
 	 * If it supports ASPM, Offset[560h] = 0x40,
 	 * otherwise Offset[560h] = 0x00.
 	 * */
 	bool support_aspm;
-
 	bool support_backdoor;
 
 	/*for LPS */
@@ -1472,7 +1535,7 @@ struct rtl_stats {
 	s8 rssi;
 	u8 signal;
 	u8 noise;
-	u16 rate;		/*in 100 kbps */
+	u8 rate;		/* hw desc rate */
 	u8 received_channel;
 	u8 control;
 	u8 mask;
@@ -1514,8 +1577,16 @@ struct rtl_stats {
 	bool packet_toself;
 	bool packet_beacon;	/*for rssi */
 	char cck_adc_pwdb[4];	/*for rx path selection */
+
+	u8 packet_report_type;
+
+	u32 macid;
+	u8 wake_match;
+	u32 bt_rx_rssi_percentage;
+	u32 macid_valid_entry[2];
 };
 
+
 struct rt_link_detect {
 	/* count for roaming */
 	u32 bcn_rx_inperiod;
@@ -1568,7 +1639,8 @@ struct rtl_tcb_desc {
 	/* early mode */
 	u8 empkt_num;
 	/* The max value by HW */
-	u32 empkt_len[5];
+	u32 empkt_len[10];
+	bool btx_enable_sw_calc_duration;
 };
 
 struct rtl_hal_ops {
@@ -1779,7 +1851,6 @@ struct rtl_works {
 	struct timer_list dualmac_easyconcurrent_retrytimer;
 	struct timer_list fw_clockoff_timer;
 	struct timer_list fast_antenna_training_timer;
-
 	/*task */
 	struct tasklet_struct irq_tasklet;
 	struct tasklet_struct irq_prepare_bcn_tasklet;
@@ -1864,10 +1935,12 @@ struct dig_t {
 	char back_val;
 	char back_range_max;
 	char back_range_min;
-	u8 rx_gain_range_max;
-	u8 rx_gain_range_min;
+	u8 rx_gain_max;
+	u8 rx_gain_min;
 	u8 min_undec_pwdb_for_dm;
 	u8 rssi_val_min;
+	u8 pre_cck_cca_thres;
+	u8 cur_cck_cca_thres;
 	u8 pre_cck_pd_state;
 	u8 cur_cck_pd_state;
 	u8 pre_cck_fa_state;
@@ -1889,6 +1962,13 @@ struct dig_t {
 	u8 backoff_enable_flag;
 	char backoffval_range_max;
 	char backoffval_range_min;
+	u8 dig_min_0;
+	u8 dig_min_1;
+	bool media_connect_0;
+	bool media_connect_1;
+
+	u32 antdiv_rssi_max;
+	u32 rssi_max;
 };
 
 struct rtl_global_var {
@@ -2229,6 +2309,7 @@ value to host byte ordering.*/
 #define SEQ_TO_SN(seq)		(((seq) & IEEE80211_SCTL_SEQ) >> 4)
 #define SN_TO_SEQ(ssn)		(((ssn) << 4) & IEEE80211_SCTL_SEQ)
 #define MAX_SN			((IEEE80211_SCTL_SEQ) >> 4)
+#define rtl_dm(rtlpriv)		(&((rtlpriv)->dm))
 
 #define	RT_RF_OFF_LEVL_ASPM		BIT(0)	/*PCI ASPM */
 #define	RT_RF_OFF_LEVL_CLK_REQ		BIT(1)	/*PCI clock request */
-- 
1.8.1.4
