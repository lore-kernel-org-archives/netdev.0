From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/7] rtlwifi: Convert RTPRINT macro to use ##__VA_ARGS__
Date: Wed,  4 Jan 2012 19:40:42 -0800
Message-ID: <a5d37be2937822b107d12ac5182974430106154b.1325734203.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consolidate printks to avoid possible message interleaving
and reduce the object size.

Remove unnecessary RTPRINT parentheses.
Coalesce formats.
Align arguments.

$ size drivers/net/wireless/rtlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 590002	  55333	 127560	 772895	  bcb1f	drivers/net/wireless/rtlwifi/built-in.o.new
 594841	  55333	 129680	 779854	  be64e	drivers/net/wireless/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/debug.h         |    6 +-
 drivers/net/wireless/rtlwifi/efuse.c         |   28 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |   74 ++++----
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c  |   77 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c  |   71 ++++----
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c  |   65 ++++----
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c |  250 +++++++++++++-------------
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c  |   69 ++++----
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c  |   85 +++++-----
 9 files changed, 355 insertions(+), 370 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 8c13969..8b51a82 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -175,11 +175,11 @@ do {									\
 	}								\
 } while (0)
 
-#define RTPRINT(rtlpriv, dbgtype, dbgflag, printstr)			\
+#define RTPRINT(rtlpriv, dbgtype, dbgflag, fmt, ...)			\
 do {									\
 	if (unlikely(rtlpriv->dbg.dbgp_type[dbgtype] & dbgflag)) {	\
-		printk(KERN_DEBUG "%s: ", KBUILD_MODNAME);		\
-		printk printstr;					\
+		printk(KERN_DEBUG KBUILD_MODNAME ": " fmt,		\
+		       ##__VA_ARGS__);					\
 	}								\
 } while (0)
 
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 2885131..a079a31 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -280,7 +280,7 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	if (*rtemp8 != 0xFF) {
 		efuse_utilized++;
 		RTPRINT(rtlpriv, FEEPROM, EFUSE_READ_ALL,
-			("Addr=%d\n", efuse_addr));
+			"Addr=%d\n", efuse_addr);
 		efuse_addr++;
 	}
 
@@ -290,13 +290,13 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 		if (offset < efuse_max_section) {
 			wren = (*rtemp8 & 0x0f);
 			RTPRINT(rtlpriv, FEEPROM, EFUSE_READ_ALL,
-				("offset-%d Worden=%x\n", offset, wren));
+				"offset-%d Worden=%x\n", offset, wren);
 
 			for (i = 0; i < EFUSE_MAX_WORD_UNIT; i++) {
 				if (!(wren & 0x01)) {
 					RTPRINT(rtlpriv, FEEPROM,
-						EFUSE_READ_ALL, ("Addr=%d\n",
-								 efuse_addr));
+						EFUSE_READ_ALL,
+						"Addr=%d\n", efuse_addr);
 
 					read_efuse_byte(hw, efuse_addr, rtemp8);
 					efuse_addr++;
@@ -308,8 +308,8 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 						break;
 
 					RTPRINT(rtlpriv, FEEPROM,
-						EFUSE_READ_ALL, ("Addr=%d\n",
-								 efuse_addr));
+						EFUSE_READ_ALL,
+						"Addr=%d\n", efuse_addr);
 
 					read_efuse_byte(hw, efuse_addr, rtemp8);
 					efuse_addr++;
@@ -326,7 +326,7 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 		}
 
 		RTPRINT(rtlpriv, FEEPROM, EFUSE_READ_ALL,
-			("Addr=%d\n", efuse_addr));
+			"Addr=%d\n", efuse_addr);
 		read_efuse_byte(hw, efuse_addr, rtemp8);
 		if (*rtemp8 != 0xFF && (efuse_addr < efuse_len)) {
 			efuse_utilized++;
@@ -850,7 +850,7 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 			}
 		}
 	}
-	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG, ("efuse PG_STATE_HEADER-1\n"));
+	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,  "efuse PG_STATE_HEADER-1\n");
 }
 
 static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
@@ -915,7 +915,7 @@ static void efuse_write_data_case2(struct ieee80211_hw *hw, u16 *efuse_addr,
 		}
 
 		RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
-			("efuse PG_STATE_HEADER-2\n"));
+			"efuse PG_STATE_HEADER-2\n");
 	}
 }
 
@@ -935,7 +935,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	if (efuse_get_current_size(hw) >=
 	    (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES)) {
 		RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
-			("efuse_pg_packet_write error\n"));
+			"efuse_pg_packet_write error\n");
 		return false;
 	}
 
@@ -947,7 +947,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 	efuse_word_enable_data_read(word_en, data, target_pkt.data);
 	target_word_cnts = efuse_calculate_word_cnts(target_pkt.word_en);
 
-	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG, ("efuse Power ON\n"));
+	RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,  "efuse Power ON\n");
 
 	while (continual && (efuse_addr <
 	       (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES))) {
@@ -955,7 +955,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 		if (write_state == PG_STATE_HEADER) {
 			badworden = 0x0F;
 			RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
-				("efuse PG_STATE_HEADER\n"));
+				"efuse PG_STATE_HEADER\n");
 
 			if (efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
 			    (efuse_data != 0xFF))
@@ -975,7 +975,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 
 		} else if (write_state == PG_STATE_DATA) {
 			RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
-				("efuse PG_STATE_DATA\n"));
+				"efuse PG_STATE_DATA\n");
 			badworden =
 			    efuse_word_enable_data_write(hw, efuse_addr + 1,
 							 target_pkt.word_en,
@@ -998,7 +998,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 					result = false;
 				}
 				RTPRINT(rtlpriv, FEEPROM, EFUSE_PG,
-					("efuse PG_STATE_HEADER-3\n"));
+					"efuse PG_STATE_HEADER-3\n");
 			}
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 4aa228f..2d01673 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1362,25 +1362,24 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM CCK Area(%d) = 0x%x\n", rf_path,
-				 i,
-				 rtlefuse->
-				 eeprom_chnlarea_txpwr_cck[rf_path][i]));
+				"RF(%d) EEPROM CCK Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->
+				eeprom_chnlarea_txpwr_cck[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->
-				 eeprom_chnlarea_txpwr_ht40_1s[rf_path][i]));
+				"RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->
+				eeprom_chnlarea_txpwr_ht40_1s[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->
-				 eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
-				 [i]));
+				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->
+				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
@@ -1411,11 +1410,11 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 		for (i = 0; i < 14; i++) {
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = "
-				 "[0x%x / 0x%x / 0x%x]\n", rf_path, i,
-				 rtlefuse->txpwrlevel_cck[rf_path][i],
-				 rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
-				 rtlefuse->txpwrlevel_ht40_2s[rf_path][i]));
+				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n",
+				rf_path, i,
+				rtlefuse->txpwrlevel_cck[rf_path][i],
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
+				rtlefuse->txpwrlevel_ht40_2s[rf_path][i]);
 		}
 	}
 
@@ -1452,13 +1451,13 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			}
 
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF-%d pwrgroup_ht20[%d] = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->pwrgroup_ht20[rf_path][i]));
+				"RF-%d pwrgroup_ht20[%d] = 0x%x\n",
+				rf_path, i,
+				rtlefuse->pwrgroup_ht20[rf_path][i]);
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF-%d pwrgroup_ht40[%d] = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->pwrgroup_ht40[rf_path][i]));
+				"RF-%d pwrgroup_ht40[%d] = 0x%x\n",
+				rf_path, i,
+				rtlefuse->pwrgroup_ht40[rf_path][i]);
 		}
 	}
 
@@ -1497,27 +1496,27 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-A Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]));
+			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-A Legacy to Ht40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]));
+			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-B Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]));
+			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-B Legacy to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]));
+			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 
 	if (!autoload_fail)
 		rtlefuse->eeprom_regulatory = (hwinfo[RF_OPTION1] & 0x7);
 	else
 		rtlefuse->eeprom_regulatory = 0;
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory));
+		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 
 	if (!autoload_fail) {
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = hwinfo[EEPROM_TSSI_A];
@@ -1526,10 +1525,9 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = EEPROM_DEFAULT_TSSI;
 		rtlefuse->eeprom_tssi[RF90_PATH_B] = EEPROM_DEFAULT_TSSI;
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("TSSI_A = 0x%x, TSSI_B = 0x%x\n",
-		 rtlefuse->eeprom_tssi[RF90_PATH_A],
-		 rtlefuse->eeprom_tssi[RF90_PATH_B]));
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
+		rtlefuse->eeprom_tssi[RF90_PATH_A],
+		rtlefuse->eeprom_tssi[RF90_PATH_B]);
 
 	if (!autoload_fail)
 		tempval = hwinfo[EEPROM_THERMAL_METER];
@@ -1542,7 +1540,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter));
+		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 }
 
 static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
index 3ba1a4f..5ef9604 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
@@ -123,8 +123,8 @@ void rtl92ce_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 	rtl_set_bbreg(hw, RTXAGC_A_CCK1_MCS32, MASKBYTE1, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_A_CCK1_MCS32));
+		"CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_A_CCK1_MCS32);
 
 	tmpval = tx_agc[RF90_PATH_A] >> 8;
 
@@ -133,22 +133,22 @@ void rtl92ce_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_B_CCK11_A_CCK2_11));
+		"CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK11_A_CCK2_11);
 
 	tmpval = tx_agc[RF90_PATH_B] >> 24;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, MASKBYTE0, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_B_CCK11_A_CCK2_11));
+		"CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK11_A_CCK2_11);
 
 	tmpval = tx_agc[RF90_PATH_B] & 0x00ffffff;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32, 0xffffff00, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_B_CCK1_55_MCS32));
+		"CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK1_55_MCS32);
 }
 
 static void rtl92c_phy_get_power_base(struct ieee80211_hw *hw,
@@ -171,8 +171,8 @@ static void rtl92c_phy_get_power_base(struct ieee80211_hw *hw,
 		    (powerBase0 << 8) | powerBase0;
 		*(ofdmbase + i) = powerBase0;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			(" [OFDM power base index rf(%c) = 0x%x]\n",
-			 ((i == 0) ? 'A' : 'B'), *(ofdmbase + i)));
+			" [OFDM power base index rf(%c) = 0x%x]\n",
+			i == 0 ? 'A' : 'B', *(ofdmbase + i));
 	}
 
 	for (i = 0; i < 2; i++) {
@@ -187,8 +187,8 @@ static void rtl92c_phy_get_power_base(struct ieee80211_hw *hw,
 		*(mcsbase + i) = powerBase1;
 
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			(" [MCS power base index rf(%c) = 0x%x]\n",
-			 ((i == 0) ? 'A' : 'B'), *(mcsbase + i)));
+			" [MCS power base index rf(%c) = 0x%x]\n",
+			i == 0 ? 'A' : 'B', *(mcsbase + i));
 	}
 }
 
@@ -215,9 +215,8 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			    + ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("RTK better performance, "
-				 "writeVal(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeVal));
+				"RTK better performance, writeVal(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		case 1:
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
@@ -225,9 +224,8 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					    powerBase1[rf]);
 
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("Realtek regulatory, 40MHz, "
-					 "writeVal(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'), writeVal));
+					"Realtek regulatory, 40MHz, writeVal(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B', writeVal);
 			} else {
 				if (rtlphy->pwrgroup_cnt == 1)
 					chnlgroup = 0;
@@ -249,9 +247,8 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 							      powerBase1[rf]);
 
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("Realtek regulatory, 20MHz, "
-					 "writeVal(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'), writeVal));
+					"Realtek regulatory, 20MHz, writeVal(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B', writeVal);
 			}
 			break;
 		case 2:
@@ -259,27 +256,24 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			    ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Better regulatory, "
-				 "writeVal(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeVal));
+				"Better regulatory, writeVal(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		case 3:
 			chnlgroup = 0;
 
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("customer's limit, 40MHz "
-					 "rf(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'),
-					 rtlefuse->pwrgroup_ht40[rf][channel -
-								     1]));
+					"customer's limit, 40MHz rf(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B',
+					rtlefuse->pwrgroup_ht40[rf][channel -
+								    1]);
 			} else {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("customer's limit, 20MHz "
-					 "rf(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'),
-					 rtlefuse->pwrgroup_ht20[rf][channel -
-								     1]));
+					"customer's limit, 20MHz rf(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B',
+					rtlefuse->pwrgroup_ht20[rf][channel -
+								    1]);
 			}
 			for (i = 0; i < 4; i++) {
 				pwr_diff_limit[i] =
@@ -311,15 +305,15 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			    (pwr_diff_limit[1] << 8) | (pwr_diff_limit[0]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Customer's limit rf(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), customer_limit));
+				"Customer's limit rf(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', customer_limit);
 
 			writeVal = customer_limit +
 			    ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Customer, writeVal rf(%c)= 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeVal));
+				"Customer, writeVal rf(%c)= 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		default:
 			chnlgroup = 0;
@@ -329,9 +323,8 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			    + ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("RTK better performance, writeVal "
-				 "rf(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeVal));
+				"RTK better performance, writeVal rf(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		}
 
@@ -383,7 +376,7 @@ static void _rtl92c_write_ofdm_power_reg(struct ieee80211_hw *hw,
 		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeVal);
 
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			("Set 0x%x = %08x\n", regoffset, writeVal));
+			"Set 0x%x = %08x\n", regoffset, writeVal);
 
 		if (((get_rf_type(rtlphy) == RF_2T2R) &&
 		     (regoffset == RTXAGC_A_MCS15_MCS12 ||
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 80bd17d..de1542f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -162,24 +162,24 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM CCK Area(%d) = 0x%x\n", rf_path,
-				 i, rtlefuse->
-				 eeprom_chnlarea_txpwr_cck[rf_path][i]));
+				"RF(%d) EEPROM CCK Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->
+				eeprom_chnlarea_txpwr_cck[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->
-				 eeprom_chnlarea_txpwr_ht40_1s[rf_path][i]));
+				"RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->
+				eeprom_chnlarea_txpwr_ht40_1s[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->
-				 eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
-				 [i]));
+				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->
+				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
 			index = _rtl92c_get_chnl_group((u8) i);
@@ -205,11 +205,10 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		}
 		for (i = 0; i < 14; i++) {
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = "
-				 "[0x%x / 0x%x / 0x%x]\n", rf_path, i,
-				 rtlefuse->txpwrlevel_cck[rf_path][i],
-				 rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
-				 rtlefuse->txpwrlevel_ht40_2s[rf_path][i]));
+				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n", rf_path, i,
+				rtlefuse->txpwrlevel_cck[rf_path][i],
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
+				rtlefuse->txpwrlevel_ht40_2s[rf_path][i]);
 		}
 	}
 	for (i = 0; i < 3; i++) {
@@ -242,13 +241,13 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				      & 0xf0) >> 4);
 			}
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF-%d pwrgroup_ht20[%d] = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->pwrgroup_ht20[rf_path][i]));
+				"RF-%d pwrgroup_ht20[%d] = 0x%x\n",
+				rf_path, i,
+				rtlefuse->pwrgroup_ht20[rf_path][i]);
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF-%d pwrgroup_ht40[%d] = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->pwrgroup_ht40[rf_path][i]));
+				"RF-%d pwrgroup_ht40[%d] = 0x%x\n",
+				rf_path, i,
+				rtlefuse->pwrgroup_ht40[rf_path][i]);
 		}
 	}
 	for (i = 0; i < 14; i++) {
@@ -277,26 +276,26 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	    rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][7];
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-A Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]));
+			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-A Legacy to Ht40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]));
+			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-B Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]));
+			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-B Legacy to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]));
+			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 	if (!autoload_fail)
 		rtlefuse->eeprom_regulatory = (hwinfo[RF_OPTION1] & 0x7);
 	else
 		rtlefuse->eeprom_regulatory = 0;
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory));
+		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 	if (!autoload_fail) {
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = hwinfo[EEPROM_TSSI_A];
 		rtlefuse->eeprom_tssi[RF90_PATH_B] = hwinfo[EEPROM_TSSI_B];
@@ -305,9 +304,9 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_tssi[RF90_PATH_B] = EEPROM_DEFAULT_TSSI;
 	}
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("TSSI_A = 0x%x, TSSI_B = 0x%x\n",
-		 rtlefuse->eeprom_tssi[RF90_PATH_A],
-		 rtlefuse->eeprom_tssi[RF90_PATH_B]));
+		"TSSI_A = 0x%x, TSSI_B = 0x%x\n",
+		rtlefuse->eeprom_tssi[RF90_PATH_A],
+		rtlefuse->eeprom_tssi[RF90_PATH_B]);
 	if (!autoload_fail)
 		tempval = hwinfo[EEPROM_THERMAL_METER];
 	else
@@ -320,7 +319,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->apk_thermalmeterignore = true;
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter));
+		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 }
 
 static void _rtl92cu_read_board_type(struct ieee80211_hw *hw, u8 *contents)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
index 7b48ee9..e132cb3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
@@ -140,26 +140,26 @@ void rtl92cu_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 	rtl_set_bbreg(hw, RTXAGC_A_CCK1_MCS32, MASKBYTE1, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_A_CCK1_MCS32));
+		"CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_A_CCK1_MCS32);
 
 	tmpval = tx_agc[RF90_PATH_A] >> 8;
 	if (mac->mode == WIRELESS_MODE_B)
 		tmpval = tmpval & 0xff00ffff;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_B_CCK11_A_CCK2_11));
+		"CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK11_A_CCK2_11);
 	tmpval = tx_agc[RF90_PATH_B] >> 24;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, MASKBYTE0, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_B_CCK11_A_CCK2_11));
+		"CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK11_A_CCK2_11);
 	tmpval = tx_agc[RF90_PATH_B] & 0x00ffffff;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32, 0xffffff00, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		 RTXAGC_B_CCK1_55_MCS32));
+		"CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK1_55_MCS32);
 }
 
 static void rtl92c_phy_get_power_base(struct ieee80211_hw *hw,
@@ -181,8 +181,8 @@ static void rtl92c_phy_get_power_base(struct ieee80211_hw *hw,
 		    (powerBase0 << 8) | powerBase0;
 		*(ofdmbase + i) = powerBase0;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			(" [OFDM power base index rf(%c) = 0x%x]\n",
-			 ((i == 0) ? 'A' : 'B'), *(ofdmbase + i)));
+			" [OFDM power base index rf(%c) = 0x%x]\n",
+			i == 0 ? 'A' : 'B', *(ofdmbase + i));
 	}
 	for (i = 0; i < 2; i++) {
 		if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20) {
@@ -194,8 +194,8 @@ static void rtl92c_phy_get_power_base(struct ieee80211_hw *hw,
 		    (powerBase1 << 16) | (powerBase1 << 8) | powerBase1;
 		*(mcsbase + i) = powerBase1;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			(" [MCS power base index rf(%c) = 0x%x]\n",
-			 ((i == 0) ? 'A' : 'B'), *(mcsbase + i)));
+			" [MCS power base index rf(%c) = 0x%x]\n",
+			i == 0 ? 'A' : 'B', *(mcsbase + i));
 	}
 }
 
@@ -219,8 +219,8 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			    [chnlgroup][index + (rf ? 8 : 0)]
 			    + ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("RTK better performance,writeVal(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal));
+				"RTK better performance,writeVal(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		case 1:
 			if (rtlphy->pwrgroup_cnt == 1)
@@ -244,32 +244,31 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					((index < 2) ? powerBase0[rf] :
 					powerBase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Realtek regulatory, 20MHz, "
-				"writeVal(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal));
+				"Realtek regulatory, 20MHz, writeVal(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		case 2:
 			writeVal = ((index < 2) ? powerBase0[rf] :
 				   powerBase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Better regulatory,writeVal(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeVal));
+				"Better regulatory,writeVal(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		case 3:
 			chnlgroup = 0;
 			if (rtlphy->current_chan_bw ==
 			    HT_CHANNEL_WIDTH_20_40) {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("customer's limit, 40MHzrf(%c) = "
-					"0x%x\n", ((rf == 0) ? 'A' : 'B'),
+					"customer's limit, 40MHzrf(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B',
 					rtlefuse->pwrgroup_ht40[rf]
-					[channel - 1]));
+					[channel - 1]);
 			} else {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("customer's limit, 20MHz rf(%c) = "
-					"0x%x\n", ((rf == 0) ? 'A' : 'B'),
+					"customer's limit, 20MHz rf(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B',
 					rtlefuse->pwrgroup_ht20[rf]
-					[channel - 1]));
+					[channel - 1]);
 			}
 			for (i = 0; i < 4; i++) {
 				pwr_diff_limit[i] =
@@ -297,22 +296,22 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			    (pwr_diff_limit[2] << 16) |
 			    (pwr_diff_limit[1] << 8) | (pwr_diff_limit[0]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Customer's limit rf(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), customer_limit));
+				"Customer's limit rf(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', customer_limit);
 			writeVal = customer_limit + ((index < 2) ?
 				   powerBase0[rf] : powerBase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Customer, writeVal rf(%c)= 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeVal));
+				"Customer, writeVal rf(%c)= 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		default:
 			chnlgroup = 0;
 			writeVal = rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
 				   [index + (rf ? 8 : 0)] + ((index < 2) ?
 				   powerBase0[rf] : powerBase1[rf]);
-			RTPRINT(rtlpriv, FPHY, PHY_TXPWR, ("RTK better "
-				"performance, writeValrf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal));
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"RTK better performance, writeValrf(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeVal);
 			break;
 		}
 		if (rtlpriv->dm.dynamic_txhighpower_lvl ==
@@ -365,7 +364,7 @@ static void _rtl92c_write_ofdm_power_reg(struct ieee80211_hw *hw,
 			regoffset = regoffset_b[index];
 		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeVal);
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			("Set 0x%x = %08x\n", regoffset, writeVal));
+			"Set 0x%x = %08x\n", regoffset, writeVal);
 		if (((get_rf_type(rtlphy) == RF_2T2R) &&
 		     (regoffset == RTXAGC_A_MCS15_MCS12 ||
 		      regoffset == RTXAGC_B_MCS15_MCS12)) ||
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index 82cc052..c736b93 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -1446,8 +1446,8 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 	if (rtlhal->current_bandtype == BAND_ON_5G) {
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>5G\n");
 		u4tmp = curveindex_5g[channel - 1];
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("ver 1 set RF-A, 5G, "
-			"0x28 = 0x%x !!\n", u4tmp));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,
+			"ver 1 set RF-A, 5G, 0x28 = 0x%x !!\n", u4tmp);
 		for (i = 0; i < RF_CHNL_NUM_5G; i++) {
 			if (channel == rf_chnl_5g[i] && channel <= 140)
 				index = 0;
@@ -1545,8 +1545,8 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 	} else if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>2.4G\n");
 		u4tmp = curveindex_2g[channel - 1];
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("ver 3 set RF-B, 2G, "
-			"0x28 = 0x%x !!\n", u4tmp));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,
+			"ver 3 set RF-B, 2G, 0x28 = 0x%x !!\n", u4tmp);
 		if (channel == 1 || channel == 2 || channel == 4 || channel == 9
 		    || channel == 10 || channel == 11 || channel == 12)
 			index = 0;
@@ -1589,8 +1589,8 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 					       BRFREGOFFSETMASK));
 		}
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("cosa ver 3 set RF-B, 2G, 0x28 = 0x%x !!\n",
-			rf_syn_g4_for_c_cut_2g | (u4tmp << 11)));
+			"cosa ver 3 set RF-B, 2G, 0x28 = 0x%x !!\n",
+			rf_syn_g4_for_c_cut_2g | (u4tmp << 11));
 
 		rtl_set_rfreg(hw, (enum radio_path)path, RF_SYN_G4,
 			      BRFREGOFFSETMASK,
@@ -1637,9 +1637,9 @@ static u8 _rtl92d_phy_patha_iqk(struct ieee80211_hw *hw, bool configpathb)
 	u32 regeac, rege94, rege9c, regea4;
 	u8 result = 0;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path A IQK!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path A IQK!\n");
 	/* path-A IQK setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path-A IQK setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path-A IQK setting!\n");
 	if (rtlhal->interfaceindex == 0) {
 		rtl_set_bbreg(hw, 0xe30, BMASKDWORD, 0x10008c1f);
 		rtl_set_bbreg(hw, 0xe34, BMASKDWORD, 0x10008c1f);
@@ -1657,26 +1657,26 @@ static u8 _rtl92d_phy_patha_iqk(struct ieee80211_hw *hw, bool configpathb)
 		rtl_set_bbreg(hw, 0xe5c, BMASKDWORD, 0x28160206);
 	}
 	/* LO calibration setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("LO calibration setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "LO calibration setting!\n");
 	rtl_set_bbreg(hw, 0xe4c, BMASKDWORD, 0x00462911);
 	/* One shot, path A LOK & IQK */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("One shot, path A LOK & IQK!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "One shot, path A LOK & IQK!\n");
 	rtl_set_bbreg(hw, 0xe48, BMASKDWORD, 0xf9000000);
 	rtl_set_bbreg(hw, 0xe48, BMASKDWORD, 0xf8000000);
 	/* delay x ms */
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("Delay %d ms for One shot, path A LOK & IQK.\n",
-		IQK_DELAY_TIME));
+		"Delay %d ms for One shot, path A LOK & IQK\n",
+		IQK_DELAY_TIME);
 	mdelay(IQK_DELAY_TIME);
 	/* Check failed */
 	regeac = rtl_get_bbreg(hw, 0xeac, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xeac = 0x%x\n", regeac));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xeac = 0x%x\n", regeac);
 	rege94 = rtl_get_bbreg(hw, 0xe94, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xe94 = 0x%x\n", rege94));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xe94 = 0x%x\n", rege94);
 	rege9c = rtl_get_bbreg(hw, 0xe9c, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xe9c = 0x%x\n", rege9c));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xe9c = 0x%x\n", rege9c);
 	regea4 = rtl_get_bbreg(hw, 0xea4, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xea4 = 0x%x\n", regea4));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xea4 = 0x%x\n", regea4);
 	if (!(regeac & BIT(28)) && (((rege94 & 0x03FF0000) >> 16) != 0x142) &&
 	    (((rege9c & 0x03FF0000) >> 16) != 0x42))
 		result |= 0x01;
@@ -1687,7 +1687,7 @@ static u8 _rtl92d_phy_patha_iqk(struct ieee80211_hw *hw, bool configpathb)
 	    (((regeac & 0x03FF0000) >> 16) != 0x36))
 		result |= 0x02;
 	else
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path A Rx IQK fail!!\n"));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path A Rx IQK fail!!\n");
 	return result;
 }
 
@@ -1708,9 +1708,9 @@ static u8 _rtl92d_phy_patha_iqk_5g_normal(struct ieee80211_hw *hw,
 		TxOKBit = BIT(31);
 		RxOKBit = BIT(30);
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path A IQK!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path A IQK!\n");
 	/* path-A IQK setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path-A IQK setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path-A IQK setting!\n");
 	rtl_set_bbreg(hw, 0xe30, BMASKDWORD, 0x18008c1f);
 	rtl_set_bbreg(hw, 0xe34, BMASKDWORD, 0x18008c1f);
 	rtl_set_bbreg(hw, 0xe38, BMASKDWORD, 0x82140307);
@@ -1723,7 +1723,7 @@ static u8 _rtl92d_phy_patha_iqk_5g_normal(struct ieee80211_hw *hw,
 		rtl_set_bbreg(hw, 0xe5c, BMASKDWORD, 0x68110000);
 	}
 	/* LO calibration setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("LO calibration setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "LO calibration setting!\n");
 	rtl_set_bbreg(hw, 0xe4c, BMASKDWORD, 0x00462911);
 	/* path-A PA on */
 	rtl_set_bbreg(hw, RFPGA0_XAB_RFINTERFACESW, BMASKDWORD, 0x07000f60);
@@ -1731,29 +1731,29 @@ static u8 _rtl92d_phy_patha_iqk_5g_normal(struct ieee80211_hw *hw,
 	for (i = 0; i < retrycount; i++) {
 		/* One shot, path A LOK & IQK */
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("One shot, path A LOK & IQK!\n"));
+			"One shot, path A LOK & IQK!\n");
 		rtl_set_bbreg(hw, 0xe48, BMASKDWORD, 0xf9000000);
 		rtl_set_bbreg(hw, 0xe48, BMASKDWORD, 0xf8000000);
 		/* delay x ms */
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("Delay %d ms for One shot, path A LOK & IQK.\n",
-			IQK_DELAY_TIME));
+			"Delay %d ms for One shot, path A LOK & IQK.\n",
+			IQK_DELAY_TIME);
 		mdelay(IQK_DELAY_TIME * 10);
 		/* Check failed */
 		regeac = rtl_get_bbreg(hw, 0xeac, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xeac = 0x%x\n", regeac));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xeac = 0x%x\n", regeac);
 		rege94 = rtl_get_bbreg(hw, 0xe94, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xe94 = 0x%x\n", rege94));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xe94 = 0x%x\n", rege94);
 		rege9c = rtl_get_bbreg(hw, 0xe9c, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xe9c = 0x%x\n", rege9c));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xe9c = 0x%x\n", rege9c);
 		regea4 = rtl_get_bbreg(hw, 0xea4, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xea4 = 0x%x\n", regea4));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xea4 = 0x%x\n", regea4);
 		if (!(regeac & TxOKBit) &&
 		     (((rege94 & 0x03FF0000) >> 16) != 0x142)) {
 			result |= 0x01;
 		} else { /* if Tx not OK, ignore Rx */
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path A Tx IQK fail!!\n"));
+				"Path A Tx IQK fail!!\n");
 			continue;
 		}
 
@@ -1764,7 +1764,7 @@ static u8 _rtl92d_phy_patha_iqk_5g_normal(struct ieee80211_hw *hw,
 			break;
 		} else {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path A Rx IQK fail!!\n"));
+				"Path A Rx IQK fail!!\n");
 		}
 	}
 	/* path A PA off */
@@ -1782,27 +1782,26 @@ static u8 _rtl92d_phy_pathb_iqk(struct ieee80211_hw *hw)
 	u32 regeac, regeb4, regebc, regec4, regecc;
 	u8 result = 0;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path B IQK!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path B IQK!\n");
 	/* One shot, path B LOK & IQK */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("One shot, path A LOK & IQK!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "One shot, path A LOK & IQK!\n");
 	rtl_set_bbreg(hw, 0xe60, BMASKDWORD, 0x00000002);
 	rtl_set_bbreg(hw, 0xe60, BMASKDWORD, 0x00000000);
 	/* delay x ms  */
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("Delay %d ms for One shot, path B LOK & IQK.\n",
-		IQK_DELAY_TIME));
+		"Delay %d ms for One shot, path B LOK & IQK\n", IQK_DELAY_TIME);
 	mdelay(IQK_DELAY_TIME);
 	/* Check failed */
 	regeac = rtl_get_bbreg(hw, 0xeac, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xeac = 0x%x\n", regeac));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xeac = 0x%x\n", regeac);
 	regeb4 = rtl_get_bbreg(hw, 0xeb4, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xeb4 = 0x%x\n", regeb4));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xeb4 = 0x%x\n", regeb4);
 	regebc = rtl_get_bbreg(hw, 0xebc, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xebc = 0x%x\n", regebc));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xebc = 0x%x\n", regebc);
 	regec4 = rtl_get_bbreg(hw, 0xec4, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xec4 = 0x%x\n", regec4));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xec4 = 0x%x\n", regec4);
 	regecc = rtl_get_bbreg(hw, 0xecc, BMASKDWORD);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xecc = 0x%x\n", regecc));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xecc = 0x%x\n", regecc);
 	if (!(regeac & BIT(31)) && (((regeb4 & 0x03FF0000) >> 16) != 0x142) &&
 	    (((regebc & 0x03FF0000) >> 16) != 0x42))
 		result |= 0x01;
@@ -1812,7 +1811,7 @@ static u8 _rtl92d_phy_pathb_iqk(struct ieee80211_hw *hw)
 	    (((regecc & 0x03FF0000) >> 16) != 0x36))
 		result |= 0x02;
 	else
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path B Rx IQK fail!!\n"));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path B Rx IQK fail!!\n");
 	return result;
 }
 
@@ -1826,9 +1825,9 @@ static u8 _rtl92d_phy_pathb_iqk_5g_normal(struct ieee80211_hw *hw)
 	u8 i;
 	u8 retrycount = 2;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path B IQK!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path B IQK!\n");
 	/* path-A IQK setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path-A IQK setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path-A IQK setting!\n");
 	rtl_set_bbreg(hw, 0xe30, BMASKDWORD, 0x18008c1f);
 	rtl_set_bbreg(hw, 0xe34, BMASKDWORD, 0x18008c1f);
 	rtl_set_bbreg(hw, 0xe38, BMASKDWORD, 0x82110000);
@@ -1841,7 +1840,7 @@ static u8 _rtl92d_phy_pathb_iqk_5g_normal(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, 0xe5c, BMASKDWORD, 0x68160960);
 
 	/* LO calibration setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("LO calibration setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "LO calibration setting!\n");
 	rtl_set_bbreg(hw, 0xe4c, BMASKDWORD, 0x00462911);
 
 	/* path-B PA on */
@@ -1851,26 +1850,26 @@ static u8 _rtl92d_phy_pathb_iqk_5g_normal(struct ieee80211_hw *hw)
 	for (i = 0; i < retrycount; i++) {
 		/* One shot, path B LOK & IQK */
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("One shot, path A LOK & IQK!\n"));
+			"One shot, path A LOK & IQK!\n");
 		rtl_set_bbreg(hw, 0xe48, BMASKDWORD, 0xfa000000);
 		rtl_set_bbreg(hw, 0xe48, BMASKDWORD, 0xf8000000);
 
 		/* delay x ms */
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("Delay %d ms for One shot, path B LOK & IQK.\n", 10));
+			"Delay %d ms for One shot, path B LOK & IQK.\n", 10);
 		mdelay(IQK_DELAY_TIME * 10);
 
 		/* Check failed */
 		regeac = rtl_get_bbreg(hw, 0xeac, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xeac = 0x%x\n", regeac));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xeac = 0x%x\n", regeac);
 		regeb4 = rtl_get_bbreg(hw, 0xeb4, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xeb4 = 0x%x\n", regeb4));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xeb4 = 0x%x\n", regeb4);
 		regebc = rtl_get_bbreg(hw, 0xebc, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xebc = 0x%x\n", regebc));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xebc = 0x%x\n", regebc);
 		regec4 = rtl_get_bbreg(hw, 0xec4, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xec4 = 0x%x\n", regec4));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xec4 = 0x%x\n", regec4);
 		regecc = rtl_get_bbreg(hw, 0xecc, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xecc = 0x%x\n", regecc));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "0xecc = 0x%x\n", regecc);
 		if (!(regeac & BIT(31)) &&
 		    (((regeb4 & 0x03FF0000) >> 16) != 0x142))
 			result |= 0x01;
@@ -1882,7 +1881,7 @@ static u8 _rtl92d_phy_pathb_iqk_5g_normal(struct ieee80211_hw *hw)
 			break;
 		} else {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path B Rx IQK fail!!\n"));
+				"Path B Rx IQK fail!!\n");
 		}
 	}
 
@@ -1901,7 +1900,7 @@ static void _rtl92d_phy_save_adda_registers(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Save ADDA parameters.\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Save ADDA parameters.\n");
 	for (i = 0; i < regnum; i++)
 		adda_backup[i] = rtl_get_bbreg(hw, adda_reg[i], BMASKDWORD);
 }
@@ -1912,7 +1911,7 @@ static void _rtl92d_phy_save_mac_registers(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Save MAC parameters.\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Save MAC parameters.\n");
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++)
 		macbackup[i] = rtl_read_byte(rtlpriv, macreg[i]);
 	macbackup[i] = rtl_read_dword(rtlpriv, macreg[i]);
@@ -1926,7 +1925,7 @@ static void _rtl92d_phy_reload_adda_registers(struct ieee80211_hw *hw,
 	u32 i;
 
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("Reload ADDA power saving parameters !\n"));
+		"Reload ADDA power saving parameters !\n");
 	for (i = 0; i < regnum; i++)
 		rtl_set_bbreg(hw, adda_reg[i], BMASKDWORD, adda_backup[i]);
 }
@@ -1937,7 +1936,7 @@ static void _rtl92d_phy_reload_mac_registers(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Reload MAC parameters !\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Reload MAC parameters !\n");
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++)
 		rtl_write_byte(rtlpriv, macreg[i], (u8) macbackup[i]);
 	rtl_write_byte(rtlpriv, macreg[i], macbackup[i]);
@@ -1950,7 +1949,7 @@ static void _rtl92d_phy_path_adda_on(struct ieee80211_hw *hw,
 	u32 pathon;
 	u32 i;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("ADDA ON.\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "ADDA ON.\n");
 	pathon = patha_on ? 0x04db25a4 : 0x0b1b25a4;
 	if (patha_on)
 		pathon = rtlpriv->rtlhal.interfaceindex == 0 ?
@@ -1965,7 +1964,7 @@ static void _rtl92d_phy_mac_setting_calibration(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("MAC settings for Calibration.\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "MAC settings for Calibration.\n");
 	rtl_write_byte(rtlpriv, macreg[0], 0x3F);
 
 	for (i = 1; i < (IQK_MAC_REG_NUM - 1); i++)
@@ -1977,7 +1976,7 @@ static void _rtl92d_phy_mac_setting_calibration(struct ieee80211_hw *hw,
 static void _rtl92d_phy_patha_standby(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path-A standby mode!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path-A standby mode!\n");
 
 	rtl_set_bbreg(hw, 0xe28, BMASKDWORD, 0x0);
 	rtl_set_bbreg(hw, RFPGA0_XA_LSSIPARAMETER, BMASKDWORD, 0x00010000);
@@ -1990,7 +1989,7 @@ static void _rtl92d_phy_pimode_switch(struct ieee80211_hw *hw, bool pi_mode)
 	u32 mode;
 
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("BB Switch to %s mode!\n", (pi_mode ? "PI" : "SI")));
+		"BB Switch to %s mode!\n", pi_mode ? "PI" : "SI");
 	mode = pi_mode ? 0x01000100 : 0x01000000;
 	rtl_set_bbreg(hw, 0x820, BMASKDWORD, mode);
 	rtl_set_bbreg(hw, 0x828, BMASKDWORD, mode);
@@ -2022,12 +2021,12 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 	const u32 retrycount = 2;
 	u32 bbvalue;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("IQK for 2.4G :Start!!!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "IQK for 2.4G :Start!!!\n");
 	if (t == 0) {
 		bbvalue = rtl_get_bbreg(hw, RFPGA0_RFMOD, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("==>0x%08x\n", bbvalue));
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("IQ Calibration for %s\n",
-			(is2t ? "2T2R" : "1T1R")));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "==>0x%08x\n", bbvalue);
+		RTPRINT(rtlpriv, FINIT, INIT_IQK, "IQ Calibration for %s\n",
+			is2t ? "2T2R" : "1T1R");
 
 		/*  Save ADDA parameters, turn Path A ADDA on */
 		_rtl92d_phy_save_adda_registers(hw, adda_reg,
@@ -2065,7 +2064,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 	if (is2t)
 		rtl_set_bbreg(hw, 0xb6c, BMASKDWORD, 0x0f600000);
 	/* IQ calibration setting */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("IQK setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "IQK setting!\n");
 	rtl_set_bbreg(hw, 0xe28, BMASKDWORD, 0x80800000);
 	rtl_set_bbreg(hw, 0xe40, BMASKDWORD, 0x01007c00);
 	rtl_set_bbreg(hw, 0xe44, BMASKDWORD, 0x01004800);
@@ -2073,7 +2072,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 		patha_ok = _rtl92d_phy_patha_iqk(hw, is2t);
 		if (patha_ok == 0x03) {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path A IQK Success!!\n"));
+				"Path A IQK Success!!\n");
 			result[t][0] = (rtl_get_bbreg(hw, 0xe94, BMASKDWORD) &
 					0x3FF0000) >> 16;
 			result[t][1] = (rtl_get_bbreg(hw, 0xe9c, BMASKDWORD) &
@@ -2086,7 +2085,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 		} else if (i == (retrycount - 1) && patha_ok == 0x01) {
 			/* Tx IQK OK */
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path A IQK Only  Tx Success!!\n"));
+				"Path A IQK Only  Tx Success!!\n");
 
 			result[t][0] = (rtl_get_bbreg(hw, 0xe94, BMASKDWORD) &
 					0x3FF0000) >> 16;
@@ -2095,7 +2094,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 		}
 	}
 	if (0x00 == patha_ok)
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path A IQK failed!!\n"));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path A IQK failed!!\n");
 	if (is2t) {
 		_rtl92d_phy_patha_standby(hw);
 		/* Turn Path B ADDA on */
@@ -2104,7 +2103,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 			pathb_ok = _rtl92d_phy_pathb_iqk(hw);
 			if (pathb_ok == 0x03) {
 				RTPRINT(rtlpriv, FINIT, INIT_IQK,
-					("Path B IQK Success!!\n"));
+					"Path B IQK Success!!\n");
 				result[t][4] = (rtl_get_bbreg(hw, 0xeb4,
 					       BMASKDWORD) & 0x3FF0000) >> 16;
 				result[t][5] = (rtl_get_bbreg(hw, 0xebc,
@@ -2117,7 +2116,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 			} else if (i == (retrycount - 1) && pathb_ok == 0x01) {
 				/* Tx IQK OK */
 				RTPRINT(rtlpriv, FINIT, INIT_IQK,
-					("Path B Only Tx IQK Success!!\n"));
+					"Path B Only Tx IQK Success!!\n");
 				result[t][4] = (rtl_get_bbreg(hw, 0xeb4,
 					       BMASKDWORD) & 0x3FF0000) >> 16;
 				result[t][5] = (rtl_get_bbreg(hw, 0xebc,
@@ -2126,12 +2125,12 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 		}
 		if (0x00 == pathb_ok)
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path B IQK failed!!\n"));
+				"Path B IQK failed!!\n");
 	}
 
 	/* Back to BB mode, load original value */
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("IQK:Back to BB mode, load original value!\n"));
+		"IQK:Back to BB mode, load original value!\n");
 
 	rtl_set_bbreg(hw, 0xe28, BMASKDWORD, 0);
 	if (t != 0) {
@@ -2156,7 +2155,7 @@ static void _rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw, long result[][8],
 		rtl_set_bbreg(hw, 0xe30, BMASKDWORD, 0x01008c00);
 		rtl_set_bbreg(hw, 0xe34, BMASKDWORD, 0x01008c00);
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("<==\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "<==\n");
 }
 
 static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
@@ -2188,13 +2187,13 @@ static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
 	/* Note: IQ calibration must be performed after loading
 	 * PHY_REG.txt , and radio_a, radio_b.txt */
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("IQK for 5G NORMAL:Start!!!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "IQK for 5G NORMAL:Start!!!\n");
 	mdelay(IQK_DELAY_TIME * 20);
 	if (t == 0) {
 		bbvalue = rtl_get_bbreg(hw, RFPGA0_RFMOD, BMASKDWORD);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("==>0x%08x\n", bbvalue));
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("IQ Calibration for %s\n",
-			(is2t ? "2T2R" : "1T1R")));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "==>0x%08x\n", bbvalue);
+		RTPRINT(rtlpriv, FINIT, INIT_IQK, "IQ Calibration for %s\n",
+			is2t ? "2T2R" : "1T1R");
 		/* Save ADDA parameters, turn Path A ADDA on */
 		_rtl92d_phy_save_adda_registers(hw, adda_reg,
 						rtlphy->adda_backup,
@@ -2231,13 +2230,13 @@ static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
 	if (is2t)
 		rtl_set_bbreg(hw, 0xb6c, BMASKDWORD, 0x0f600000);
 	/* IQ calibration setting  */
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("IQK setting!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "IQK setting!\n");
 	rtl_set_bbreg(hw, 0xe28, BMASKDWORD, 0x80800000);
 	rtl_set_bbreg(hw, 0xe40, BMASKDWORD, 0x10007c00);
 	rtl_set_bbreg(hw, 0xe44, BMASKDWORD, 0x01004800);
 	patha_ok = _rtl92d_phy_patha_iqk_5g_normal(hw, is2t);
 	if (patha_ok == 0x03) {
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path A IQK Success!!\n"));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path A IQK Success!!\n");
 		result[t][0] = (rtl_get_bbreg(hw, 0xe94, BMASKDWORD) &
 				0x3FF0000) >> 16;
 		result[t][1] = (rtl_get_bbreg(hw, 0xe9c, BMASKDWORD) &
@@ -2248,14 +2247,14 @@ static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
 				0x3FF0000) >> 16;
 	} else if (patha_ok == 0x01) {	/* Tx IQK OK */
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("Path A IQK Only  Tx Success!!\n"));
+			"Path A IQK Only  Tx Success!!\n");
 
 		result[t][0] = (rtl_get_bbreg(hw, 0xe94, BMASKDWORD) &
 				0x3FF0000) >> 16;
 		result[t][1] = (rtl_get_bbreg(hw, 0xe9c, BMASKDWORD) &
 				0x3FF0000) >> 16;
 	} else {
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path A IQK Fail!!\n"));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "Path A IQK Fail!!\n");
 	}
 	if (is2t) {
 		/* _rtl92d_phy_patha_standby(hw); */
@@ -2264,7 +2263,7 @@ static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
 		pathb_ok = _rtl92d_phy_pathb_iqk_5g_normal(hw);
 		if (pathb_ok == 0x03) {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path B IQK Success!!\n"));
+				"Path B IQK Success!!\n");
 			result[t][4] = (rtl_get_bbreg(hw, 0xeb4, BMASKDWORD) &
 			     0x3FF0000) >> 16;
 			result[t][5] = (rtl_get_bbreg(hw, 0xebc, BMASKDWORD) &
@@ -2275,20 +2274,20 @@ static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
 			     0x3FF0000) >> 16;
 		} else if (pathb_ok == 0x01) { /* Tx IQK OK */
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path B Only Tx IQK Success!!\n"));
+				"Path B Only Tx IQK Success!!\n");
 			result[t][4] = (rtl_get_bbreg(hw, 0xeb4, BMASKDWORD) &
 			     0x3FF0000) >> 16;
 			result[t][5] = (rtl_get_bbreg(hw, 0xebc, BMASKDWORD) &
 			     0x3FF0000) >> 16;
 		} else {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("Path B IQK failed!!\n"));
+				"Path B IQK failed!!\n");
 		}
 	}
 
 	/* Back to BB mode, load original value */
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("IQK:Back to BB mode, load original value!\n"));
+		"IQK:Back to BB mode, load original value!\n");
 	rtl_set_bbreg(hw, 0xe28, BMASKDWORD, 0);
 	if (t != 0) {
 		if (is2t)
@@ -2310,7 +2309,7 @@ static void _rtl92d_phy_iq_calibrate_5g_normal(struct ieee80211_hw *hw,
 						  rtlphy->adda_backup,
 						  IQK_ADDA_REG_NUM);
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("<==\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "<==\n");
 }
 
 static bool _rtl92d_phy_simularity_compare(struct ieee80211_hw *hw,
@@ -2384,8 +2383,7 @@ static void _rtl92d_phy_patha_fill_iqk_matrix(struct ieee80211_hw *hw,
 	    rtlhal->macphymode == DUALMAC_DUALPHY;
 
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("Path A IQ Calibration %s !\n",
-		(iqk_ok) ? "Success" : "Failed"));
+		"Path A IQ Calibration %s !\n", iqk_ok ? "Success" : "Failed");
 	if (final_candidate == 0xFF) {
 		return;
 	} else if (iqk_ok) {
@@ -2395,8 +2393,9 @@ static void _rtl92d_phy_patha_fill_iqk_matrix(struct ieee80211_hw *hw,
 		if ((val_x & 0x00000200) != 0)
 			val_x = val_x | 0xFFFFFC00;
 		tx0_a = (val_x * oldval_0) >> 8;
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("X = 0x%x, tx0_a = 0x%x,"
-			" oldval_0 0x%x\n",	val_x, tx0_a, oldval_0));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,
+			"X = 0x%x, tx0_a = 0x%x, oldval_0 0x%x\n",
+			val_x, tx0_a, oldval_0);
 		rtl_set_bbreg(hw, ROFDM0_XATxIQIMBALANCE, 0x3FF, tx0_a);
 		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(24),
 			      ((val_x * oldval_0 >> 7) & 0x1));
@@ -2408,8 +2407,9 @@ static void _rtl92d_phy_patha_fill_iqk_matrix(struct ieee80211_hw *hw,
 			rtlhal->current_bandtype == BAND_ON_5G)
 			val_y += 3;
 		tx0_c = (val_y * oldval_0) >> 8;
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Y = 0x%lx, tx0_c = 0x%lx\n",
-			val_y, tx0_c));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,
+			"Y = 0x%lx, tx0_c = 0x%lx\n",
+			val_y, tx0_c);
 		rtl_set_bbreg(hw, ROFDM0_XCTxAFE, 0xF0000000,
 			      ((tx0_c & 0x3C0) >> 6));
 		rtl_set_bbreg(hw, ROFDM0_XATxIQIMBALANCE, 0x003F0000,
@@ -2417,11 +2417,11 @@ static void _rtl92d_phy_patha_fill_iqk_matrix(struct ieee80211_hw *hw,
 		if (is2t)
 			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(26),
 				      ((val_y * oldval_0 >> 7) & 0x1));
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("0xC80 = 0x%x\n",
-			 rtl_get_bbreg(hw, ROFDM0_XATxIQIMBALANCE,
-				       BMASKDWORD)));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK, "0xC80 = 0x%x\n",
+			rtl_get_bbreg(hw, ROFDM0_XATxIQIMBALANCE,
+				      BMASKDWORD));
 		if (txonly) {
-			RTPRINT(rtlpriv, FINIT, INIT_IQK, ("only Tx OK\n"));
+			RTPRINT(rtlpriv, FINIT, INIT_IQK,  "only Tx OK\n");
 			return;
 		}
 		reg = result[final_candidate][2];
@@ -2441,8 +2441,8 @@ static void _rtl92d_phy_pathb_fill_iqk_matrix(struct ieee80211_hw *hw,
 	u32 oldval_1, val_x, tx1_a, reg;
 	long val_y, tx1_c;
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Path B IQ Calibration %s !\n",
-		 (iqk_ok) ? "Success" : "Failed"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK, "Path B IQ Calibration %s !\n",
+		iqk_ok ? "Success" : "Failed");
 	if (final_candidate == 0xFF) {
 		return;
 	} else if (iqk_ok) {
@@ -2452,8 +2452,8 @@ static void _rtl92d_phy_pathb_fill_iqk_matrix(struct ieee80211_hw *hw,
 		if ((val_x & 0x00000200) != 0)
 			val_x = val_x | 0xFFFFFC00;
 		tx1_a = (val_x * oldval_1) >> 8;
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("X = 0x%x, tx1_a = 0x%x\n",
-			val_x, tx1_a));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK, "X = 0x%x, tx1_a = 0x%x\n",
+			val_x, tx1_a);
 		rtl_set_bbreg(hw, ROFDM0_XBTxIQIMBALANCE, 0x3FF, tx1_a);
 		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(28),
 			      ((val_x * oldval_1 >> 7) & 0x1));
@@ -2463,8 +2463,8 @@ static void _rtl92d_phy_pathb_fill_iqk_matrix(struct ieee80211_hw *hw,
 		if (rtlhal->current_bandtype == BAND_ON_5G)
 			val_y += 3;
 		tx1_c = (val_y * oldval_1) >> 8;
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("Y = 0x%lx, tx1_c = 0x%lx\n",
-			val_y, tx1_c));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK, "Y = 0x%lx, tx1_c = 0x%lx\n",
+			val_y, tx1_c);
 		rtl_set_bbreg(hw, ROFDM0_XDTxAFE, 0xF0000000,
 			      ((tx1_c & 0x3C0) >> 6));
 		rtl_set_bbreg(hw, ROFDM0_XBTxIQIMBALANCE, 0x003F0000,
@@ -2496,7 +2496,7 @@ void rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw)
 	unsigned long flag = 0;
 
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("IQK:Start!!!channel %d\n", rtlphy->current_channel));
+		"IQK:Start!!!channel %d\n", rtlphy->current_channel);
 	for (i = 0; i < 8; i++) {
 		result[0][i] = 0;
 		result[1][i] = 0;
@@ -2510,7 +2510,7 @@ void rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw)
 	is23simular = false;
 	is13simular = false;
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("IQK !!!currentband %d\n", rtlhal->current_bandtype));
+		"IQK !!!currentband %d\n", rtlhal->current_bandtype);
 	rtl92d_acquire_cckandrw_pagea_ctl(hw, &flag);
 	for (i = 0; i < 3; i++) {
 		if (rtlhal->current_bandtype == BAND_ON_5G) {
@@ -2562,10 +2562,9 @@ void rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw)
 		regec4 = result[i][6];
 		regecc = result[i][7];
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("IQK: rege94=%lx rege9c=%lx regea4=%lx regeac=%lx "
-			"regeb4=%lx regebc=%lx regec4=%lx regecc=%lx\n ",
+			"IQK: rege94=%lx rege9c=%lx regea4=%lx regeac=%lx regeb4=%lx regebc=%lx regec4=%lx regecc=%lx\n",
 			rege94, rege9c, regea4, regeac, regeb4, regebc, regec4,
-			regecc));
+			regecc);
 	}
 	if (final_candidate != 0xff) {
 		rtlphy->reg_e94 = rege94 = result[final_candidate][0];
@@ -2577,12 +2576,11 @@ void rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw)
 		regec4 = result[final_candidate][6];
 		regecc = result[final_candidate][7];
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("IQK: final_candidate is %x\n", final_candidate));
+			"IQK: final_candidate is %x\n", final_candidate);
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("IQK: rege94=%lx rege9c=%lx regea4=%lx regeac=%lx "
-			"regeb4=%lx regebc=%lx regec4=%lx regecc=%lx\n ",
+			"IQK: rege94=%lx rege9c=%lx regea4=%lx regeac=%lx regeb4=%lx regebc=%lx regec4=%lx regecc=%lx\n",
 			rege94, rege9c, regea4, regeac, regeb4, regebc, regec4,
-			regecc));
+			regecc);
 		patha_ok = pathb_ok = true;
 	} else {
 		rtlphy->reg_e94 = rtlphy->reg_eb4 = 0x100; /* X default value */
@@ -2716,8 +2714,8 @@ static void _rtl92d_phy_calc_curvindex(struct ieee80211_hw *hw,
 			}
 		}
 		smallest_abs_val = 0xffffffff;
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("curveindex[%d] = %x\n", i,
-			curveindex[i]));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK, "curveindex[%d] = %x\n",
+			i, curveindex[i]);
 	}
 }
 
@@ -2733,13 +2731,13 @@ static void _rtl92d_phy_reload_lck_setting(struct ieee80211_hw *hw,
 	bool bneed_powerdown_radio = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "path %d\n", erfpath);
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("band type = %d\n",
-		rtlpriv->rtlhal.current_bandtype));
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("channel = %d\n", channel));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK, "band type = %d\n",
+		rtlpriv->rtlhal.current_bandtype);
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "channel = %d\n", channel);
 	if (rtlpriv->rtlhal.current_bandtype == BAND_ON_5G) {/* Path-A for 5G */
 		u4tmp = curveindex_5g[channel-1];
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("ver 1 set RF-A, 5G,	0x28 = 0x%ulx !!\n", u4tmp));
+			"ver 1 set RF-A, 5G,	0x28 = 0x%ulx !!\n", u4tmp);
 		if (rtlpriv->rtlhal.macphymode == DUALMAC_DUALPHY &&
 			rtlpriv->rtlhal.interfaceindex == 1) {
 			bneed_powerdown_radio =
@@ -2758,7 +2756,7 @@ static void _rtl92d_phy_reload_lck_setting(struct ieee80211_hw *hw,
 	} else if (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G) {
 		u4tmp = curveindex_2g[channel-1];
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("ver 3 set RF-B, 2G, 0x28 = 0x%ulx !!\n", u4tmp));
+			"ver 3 set RF-B, 2G, 0x28 = 0x%ulx !!\n", u4tmp);
 		if (rtlpriv->rtlhal.macphymode == DUALMAC_DUALPHY &&
 			rtlpriv->rtlhal.interfaceindex == 0) {
 			bneed_powerdown_radio =
@@ -2770,8 +2768,8 @@ static void _rtl92d_phy_reload_lck_setting(struct ieee80211_hw *hw,
 		}
 		rtl_set_rfreg(hw, erfpath, RF_SYN_G4, 0x3f800, u4tmp);
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("ver 3 set RF-B, 2G, 0x28 = 0x%ulx !!\n",
-			rtl_get_rfreg(hw,  erfpath, RF_SYN_G4, 0x3f800)));
+			"ver 3 set RF-B, 2G, 0x28 = 0x%ulx !!\n",
+			rtl_get_rfreg(hw,  erfpath, RF_SYN_G4, 0x3f800));
 		if (bneed_powerdown_radio)
 			_rtl92d_phy_restore_rf_env(hw, erfpath, &u4regvalue);
 		if (rtlpriv->rtlhal.during_mac0init_radiob)
@@ -2825,20 +2823,20 @@ static void _rtl92d_phy_lc_calibrate_sw(struct ieee80211_hw *hw, bool is2t)
 					      RF_SYN_G6, BRFREGOFFSETMASK);
 		}
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
-			("PHY_LCK finish delay for %d ms=2\n", timecount));
+			"PHY_LCK finish delay for %d ms=2\n", timecount);
 		u4tmp = rtl_get_rfreg(hw, index, RF_SYN_G4, BRFREGOFFSETMASK);
 		if (index == 0 && rtlhal->interfaceindex == 0) {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("path-A / 5G LCK\n"));
+				"path-A / 5G LCK\n");
 		} else {
 			RTPRINT(rtlpriv, FINIT, INIT_IQK,
-				("path-B / 2.4G LCK\n"));
+				"path-B / 2.4G LCK\n");
 		}
 		memset(&curvecount_val[0], 0, CV_CURVE_CNT * 2);
 		/* Set LC calibration off */
 		rtl_set_rfreg(hw, (enum radio_path)index, RF_CHNLBW,
 			      0x08000, 0x0);
-		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("set RF 0x18[15] = 0\n"));
+		RTPRINT(rtlpriv, FINIT, INIT_IQK,  "set RF 0x18[15] = 0\n");
 		/* save Curve-counting number */
 		for (i = 0; i < CV_CURVE_CNT; i++) {
 			u32 readval = 0, readval2 = 0;
@@ -2888,7 +2886,7 @@ static void _rtl92d_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("cosa PHY_LCK ver=2\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "cosa PHY_LCK ver=2\n");
 	_rtl92d_phy_lc_calibrate_sw(hw, is2t);
 }
 
@@ -2906,8 +2904,8 @@ void rtl92d_phy_lc_calibrate(struct ieee80211_hw *hw)
 
 	rtlphy->lck_inprogress = true;
 	RTPRINT(rtlpriv, FINIT, INIT_IQK,
-		("LCK:Start!!! currentband %x delay %d ms\n",
-		 rtlhal->current_bandtype, timecount));
+		"LCK:Start!!! currentband %x delay %d ms\n",
+		rtlhal->current_bandtype, timecount);
 	if (IS_92D_SINGLEPHY(rtlhal->version)) {
 		_rtl92d_phy_lc_calibrate(hw, true);
 	} else {
@@ -2915,7 +2913,7 @@ void rtl92d_phy_lc_calibrate(struct ieee80211_hw *hw)
 		_rtl92d_phy_lc_calibrate(hw, false);
 	}
 	rtlphy->lck_inprogress = false;
-	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("LCK:Finish!!!\n"));
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,  "LCK:Finish!!!\n");
 }
 
 void rtl92d_phy_ap_calibrate(struct ieee80211_hw *hw, char delta)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
index 3bf21c2..2e174f4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
@@ -127,23 +127,23 @@ void rtl92d_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 	tmpval = tx_agc[RF90_PATH_A] & 0xff;
 	rtl_set_bbreg(hw, RTXAGC_A_CCK1_MCS32, BMASKBYTE1, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_A_CCK1_MCS32));
+		"CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_A_CCK1_MCS32);
 	tmpval = tx_agc[RF90_PATH_A] >> 8;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_B_CCK11_A_CCK2_11));
+		"CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK11_A_CCK2_11);
 	tmpval = tx_agc[RF90_PATH_B] >> 24;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, BMASKBYTE0, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_B_CCK11_A_CCK2_11));
+		"CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK11_A_CCK2_11);
 	tmpval = tx_agc[RF90_PATH_B] & 0x00ffffff;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32, 0xffffff00, tmpval);
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-		("CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_B_CCK1_55_MCS32));
+		"CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n",
+		tmpval, RTXAGC_B_CCK1_55_MCS32);
 }
 
 static void _rtl92d_phy_get_power_base(struct ieee80211_hw *hw,
@@ -165,8 +165,8 @@ static void _rtl92d_phy_get_power_base(struct ieee80211_hw *hw,
 		    (powerbase0 << 8) | powerbase0;
 		*(ofdmbase + i) = powerbase0;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			(" [OFDM power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(ofdmbase + i)));
+			" [OFDM power base index rf(%c) = 0x%x]\n",
+			i == 0 ? 'A' : 'B', *(ofdmbase + i));
 	}
 
 	for (i = 0; i < 2; i++) {
@@ -179,8 +179,8 @@ static void _rtl92d_phy_get_power_base(struct ieee80211_hw *hw,
 			     (powerbase1 << 8) | powerbase1;
 		*(mcsbase + i) = powerbase1;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			(" [MCS power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(mcsbase + i)));
+			" [MCS power base index rf(%c) = 0x%x]\n",
+			i == 0 ? 'A' : 'B', *(mcsbase + i));
 	}
 }
 
@@ -232,9 +232,9 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					(rf ? 8 : 0)] + ((index < 2) ?
 					powerbase0[rf] :
 					powerbase1[rf]);
-			RTPRINT(rtlpriv, FPHY, PHY_TXPWR, ("RTK better "
-				"performance, writeval(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeval));
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"RTK better performance, writeval(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeval);
 			break;
 		case 1:
 			if (rtlphy->pwrgroup_cnt == 1)
@@ -253,33 +253,31 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 						powerbase0[rf] :
 						powerbase1[rf]);
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("Realtek regulatory, "
-					"20MHz, writeval(%c) = 0x%x\n",
-					((rf == 0) ? 'A' : 'B'),
-					writeval));
+					"Realtek regulatory, 20MHz, writeval(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B', writeval);
 			}
 			break;
 		case 2:
 			writeval = ((index < 2) ? powerbase0[rf] :
 				   powerbase1[rf]);
-			RTPRINT(rtlpriv, FPHY, PHY_TXPWR, ("Better regulatory, "
-				"writeval(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeval));
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Better regulatory, writeval(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeval);
 			break;
 		case 3:
 			chnlgroup = 0;
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("customer's limit, 40MHz rf(%c) = "
-					"0x%x\n", ((rf == 0) ? 'A' : 'B'),
+					"customer's limit, 40MHz rf(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B',
 					rtlefuse->pwrgroup_ht40[rf]
-					[channel - 1]));
+					[channel - 1]);
 			} else {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					("customer's limit, 20MHz rf(%c) = "
-					"0x%x\n", ((rf == 0) ? 'A' : 'B'),
+					"customer's limit, 20MHz rf(%c) = 0x%x\n",
+					rf == 0 ? 'A' : 'B',
 					rtlefuse->pwrgroup_ht20[rf]
-					[channel - 1]));
+					[channel - 1]);
 			}
 			for (i = 0; i < 4; i++) {
 				pwr_diff_limit[i] =
@@ -308,13 +306,13 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					 (pwr_diff_limit[1] << 8) |
 					 (pwr_diff_limit[0]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Customer's limit rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), customer_limit));
+				"Customer's limit rf(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', customer_limit);
 			writeval = customer_limit + ((index < 2) ?
 				   powerbase0[rf] : powerbase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("Customer, writeval rf(%c)= 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeval));
+				"Customer, writeval rf(%c)= 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeval);
 			break;
 		default:
 			chnlgroup = 0;
@@ -323,9 +321,8 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 				   (rf ? 8 : 0)] + ((index < 2) ?
 				   powerbase0[rf] : powerbase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				("RTK better performance, writeval "
-				"rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeval));
+				"RTK better performance, writeval rf(%c) = 0x%x\n",
+				rf == 0 ? 'A' : 'B', writeval);
 			break;
 		}
 		*(p_outwriteval + rf) = writeval;
@@ -367,7 +364,7 @@ static void _rtl92d_write_ofdm_power_reg(struct ieee80211_hw *hw,
 			regoffset = regoffset_b[index];
 		rtl_set_bbreg(hw, regoffset, BMASKDWORD, writeval);
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			("Set 0x%x = %08x\n", regoffset, writeval));
+			"Set 0x%x = %08x\n", regoffset, writeval);
 		if (((get_rf_type(rtlphy) == RF_2T2R) &&
 		    (regoffset == RTXAGC_A_MCS15_MCS12 ||
 		    regoffset == RTXAGC_B_MCS15_MCS12)) ||
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index dffcafe..acab878 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1704,23 +1704,24 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM CCK Area(%d) = 0x%x\n", rf_path,
-				i, rtlefuse->eeprom_chnlarea_txpwr_cck
-					[rf_path][i]));
+				"RF(%d) EEPROM CCK Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->eeprom_chnlarea_txpwr_cck
+				[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
-						[rf_path][i]));
+				"RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
+				[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				("RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
-					[rf_path][i]));
+				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
+				rf_path, i,
+				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 
@@ -1751,11 +1752,11 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 
 		for (i = 0; i < 14; i++) {
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = "
-				 "[0x%x / 0x%x / 0x%x]\n", rf_path, i,
-				 rtlefuse->txpwrlevel_cck[rf_path][i],
-				 rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
-				 rtlefuse->txpwrlevel_ht40_2s[rf_path][i]));
+				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n",
+				rf_path, i,
+				rtlefuse->txpwrlevel_cck[rf_path][i],
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
+				rtlefuse->txpwrlevel_ht40_2s[rf_path][i]);
 		}
 	}
 
@@ -1788,13 +1789,13 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 				0xf0) >> 4);
 
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF-%d pwrgroup_ht20[%d] = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->pwrgroup_ht20[rf_path][i]));
+				"RF-%d pwrgroup_ht20[%d] = 0x%x\n",
+				rf_path, i,
+				rtlefuse->pwrgroup_ht20[rf_path][i]);
 			RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-				("RF-%d pwrgroup_ht40[%d] = 0x%x\n",
-				 rf_path, i,
-				 rtlefuse->pwrgroup_ht40[rf_path][i]));
+				"RF-%d pwrgroup_ht40[%d] = 0x%x\n",
+				rf_path, i,
+				rtlefuse->pwrgroup_ht40[rf_path][i]);
 			}
 	}
 
@@ -1849,27 +1850,27 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 				 (hwinfo[EEPROM_REGULATORY] & 0x1);
 	}
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-		("eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory));
+		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-A Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]));
+			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-A Legacy to Ht40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]));
+			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-B Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]));
+			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TxPower,
-			("RF-B Legacy to HT40 Diff[%d] = 0x%x\n", i,
-			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]));
+			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n",
+			i, rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, ("TxPwrSafetyFlag = %d\n",
-		rtlefuse->txpwr_safetyflag));
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		"TxPwrSafetyFlag = %d\n", rtlefuse->txpwr_safetyflag);
 
 	/* Read RF-indication and Tx Power gain
 	 * index diff of legacy to HT OFDM rate. */
@@ -1878,8 +1879,8 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->legacy_httxpowerdiff =
 		rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][0];
 
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, ("TxPowerDiff = %#x\n",
-		rtlefuse->eeprom_txpowerdiff));
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		"TxPowerDiff = %#x\n", rtlefuse->eeprom_txpowerdiff);
 
 	/* Get TSSI value for each path. */
 	usvalue = *(u16 *)&hwinfo[EEPROM_TSSI_A];
@@ -1887,16 +1888,16 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	usvalue = *(u8 *)&hwinfo[EEPROM_TSSI_B];
 	rtlefuse->eeprom_tssi[RF90_PATH_B] = (u8)(usvalue & 0xff);
 
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, ("TSSI_A = 0x%x, TSSI_B = 0x%x\n",
-		 rtlefuse->eeprom_tssi[RF90_PATH_A],
-		 rtlefuse->eeprom_tssi[RF90_PATH_B]));
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
+		rtlefuse->eeprom_tssi[RF90_PATH_A],
+		rtlefuse->eeprom_tssi[RF90_PATH_B]);
 
 	/* Read antenna tx power offset of B/C/D to A  from EEPROM */
 	/* and read ThermalMeter from EEPROM */
 	tempval = *(u8 *)&hwinfo[EEPROM_THERMALMETER];
 	rtlefuse->eeprom_thermalmeter = tempval;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, ("thermalmeter = 0x%x\n",
-		rtlefuse->eeprom_thermalmeter));
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 
 	/* ThermalMeter, BIT(0)~3 for RFIC1, BIT(4)~7 for RFIC2 */
 	rtlefuse->thermalmeter[0] = (rtlefuse->eeprom_thermalmeter & 0x1f);
@@ -1912,8 +1913,8 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	/* Version ID, Channel plan */
 	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->txpwr_fromeprom = true;
-	RTPRINT(rtlpriv, FINIT, INIT_TxPower, ("EEPROM ChannelPlan = 0x%4x\n",
-		rtlefuse->eeprom_channelplan));
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		"EEPROM ChannelPlan = 0x%4x\n", rtlefuse->eeprom_channelplan);
 
 	/* Read Customer ID or Board Type!!! */
 	tempval = *(u8 *)&hwinfo[EEPROM_BOARDTYPE];
-- 
1.7.8.111.gad25c.dirty
