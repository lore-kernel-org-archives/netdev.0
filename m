From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rtlwifi: fix error handling in *_read_adapter_info()
Date: Mon, 30 May 2016 17:26:16 +0200
Message-ID: <1464622792-1749047-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	Taehee Yoo <ap420073@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are nine copies of the _rtl88ee_read_adapter_info() function,
and most but not all of them cause a build warning in some configurations:

rtl8192de/hw.c: In function '_rtl92de_read_adapter_info':
rtl8192de/hw.c:1767:12: error: 'hwinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
rtl8723ae/hw.c: In function '_rtl8723e_read_adapter_info.constprop':
rtlwifi/rtl8723ae/hw.c:1654:12: error: 'hwinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The problem is that when rtlefuse->epromtype is something other than
EEPROM_BOOT_EFUSE, the rest of the function uses undefined data, resulting
in random behavior later.

Apparently, in some drivers, the problem was already found and fixed
but the fix did not make it into the others.

This picks one approach to deal with the problem and applies identical
code to all 9 files, to simplify the later consolidation of those.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c | 12 +++++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c | 17 ++++++++++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c | 16 +++++++++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c | 16 +++++++++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c | 12 +++++++-----
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c | 20 ++++++++++++++------
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c | 13 +++++++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c | 16 ++++++++++++----
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c | 15 +++++++++++----
 9 files changed, 94 insertions(+), 43 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
index 8ee83b093c0d..e26a233684bb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
@@ -1839,20 +1839,22 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
 
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
+		break;
 
-		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
 		return;
-	} else {
+
+	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "boot from neither eeprom nor efuse, check it !!");
 		return;
 	}
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
 		      hwinfo, HWSET_MAX_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
index 04eb5c3f8464..58b7ac6899ef 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
@@ -1680,21 +1680,28 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct device *dev = &rtl_pcipriv(hw)->dev.pdev->dev;
 	u16 i, usvalue;
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
 
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
+		break;
 
-		memcpy((void *)hwinfo,
-		       (void *)&rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
+		return;
+
+	default:
+		dev_warn(dev, "no efuse data\n");
+		return;
 	}
 
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
+
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c
index 34ce06441d1b..ae1129f916d5 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c
@@ -351,15 +351,21 @@ static void _rtl92cu_read_adapter_info(struct ieee80211_hw *hw)
 	u8 hwinfo[HWSET_MAX_SIZE] = {0};
 	u16 eeprom_id;
 
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
-		memcpy((void *)hwinfo,
-		       (void *)&rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+		break;
+
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!\n");
+		return;
+
+	default:
+		pr_warn("rtl92cu: no efuse data\n\n");
+		return;
 	}
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 	eeprom_id = le16_to_cpu(*((__le16 *)&hwinfo[0]));
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c
index f49b60d31450..8618c322a3f8 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/hw.c
@@ -1744,23 +1744,29 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct device *dev = &rtl_pcipriv(hw)->dev.pdev->dev;
 	u16 i, usvalue;
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
 	unsigned long flags;
 
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		spin_lock_irqsave(&globalmutex_for_power_and_efuse, flags);
 		rtl_efuse_shadow_map_update(hw);
 		_rtl92de_efuse_update_chip_version(hw);
 		spin_unlock_irqrestore(&globalmutex_for_power_and_efuse, flags);
-		memcpy((void *)hwinfo, (void *)&rtlefuse->efuse_map
-		       [EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+		break;
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!\n");
+		return;
+	default:
+		dev_warn(dev, "no efuse data\n");
+		return;
 	}
+
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
index 9fd3f1b6e4a8..28c260dd11ea 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
@@ -2102,20 +2102,22 @@ static void _rtl92ee_read_adapter_info(struct ieee80211_hw *hw)
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
 
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
+		break;
 
-		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
 		return;
-	} else {
+
+	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "boot from neither eeprom nor efuse, check it !!");
 		return;
 	}
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
 		      hwinfo, HWSET_MAX_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
index 12b0978ba4fa..442f2b68ee58 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
@@ -1673,23 +1673,31 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct device *dev = &rtl_pcipriv(hw)->dev.pdev->dev;
 	u16 i, usvalue;
 	u16	eeprom_id;
 	u8 tempval;
 	u8 hwinfo[HWSET_MAX_SIZE_92S];
 	u8 rf_path, index;
 
-	if (rtlefuse->epromtype == EEPROM_93C46) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
+		rtl_efuse_shadow_map_update(hw);
+		break;
+
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!\n");
-	} else if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
-		rtl_efuse_shadow_map_update(hw);
+		return;
 
-		memcpy((void *)hwinfo, (void *)
-			&rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-			HWSET_MAX_SIZE_92S);
+	default:
+		dev_warn(dev, "no efuse data\n");
+		return;
 	}
 
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
+	       HWSET_MAX_SIZE_92S);
+
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE_92S);
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index a4b7eac6856f..57a1ba8822b1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -1630,6 +1630,7 @@ static void _rtl8723e_read_adapter_info(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct device *dev = &rtl_pcipriv(hw)->dev.pdev->dev;
 	u16 i, usvalue;
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
@@ -1638,15 +1639,19 @@ static void _rtl8723e_read_adapter_info(struct ieee80211_hw *hw,
 		/* need add */
 		return;
 	}
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
 
-		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
+		return;
+
+	default:
+		dev_warn(dev, "no efuse data\n");
 	}
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
 		      hwinfo, HWSET_MAX_SIZE);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 5a3df9198ddf..08288ac9020a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -2026,6 +2026,7 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct device *dev = &rtl_pcipriv(hw)->dev.pdev->dev;
 	u16 i, usvalue;
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
@@ -2055,15 +2056,22 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 		/* needs to be added */
 		return;
 	}
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
+		break;
 
-		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
+		return;
+
+	default:
+		dev_warn(dev, "no efuse data\n");
+		return;
 	}
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, ("MAP\n"),
 		      hwinfo, HWSET_MAX_SIZE);
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index 71e4dd9965bb..b9436df9e1ec 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -3101,6 +3101,7 @@ static void _rtl8821ae_read_adapter_info(struct ieee80211_hw *hw, bool b_pseudo_
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct device *dev = &rtl_pcipriv(hw)->dev.pdev->dev;
 	u16 i, usvalue;
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
@@ -3109,14 +3110,20 @@ static void _rtl8821ae_read_adapter_info(struct ieee80211_hw *hw, bool b_pseudo_
 		;/* need add */
 	}
 
-	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+	switch (rtlefuse->epromtype) {
+	case EEPROM_BOOT_EFUSE:
 		rtl_efuse_shadow_map_update(hw);
-		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
-		       HWSET_MAX_SIZE);
-	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+		break;
+
+	case EEPROM_93C46:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
+		return;
+
+	default:
+		dev_warn(dev, "no efuse data\n");
 	}
+	memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0], HWSET_MAX_SIZE);
 
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
 		      hwinfo, HWSET_MAX_SIZE);
-- 
2.7.0
