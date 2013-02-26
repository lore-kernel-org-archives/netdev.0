From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 25/27] rtlwifi: rtl8188ee: Enable recognition of RTL8188EE
Date: Mon, 25 Feb 2013 18:13:37 -0600
Message-ID: <1361837619-2985-26-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:63248 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932366Ab3BZAOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:52 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches modify the common probe routine to recognize the RTL8188EE
chip and implement asynchronous firmware reading in the callback routine
to initialize the sw variables.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/efuse.c        | 11 +++++++++--
 drivers/net/wireless/rtlwifi/pci.c          |  4 ++++
 drivers/net/wireless/rtlwifi/pci.h          |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c | 28 ++++++++++++++--------------
 drivers/net/wireless/rtlwifi/wifi.h         |  1 +
 5 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 41a03b1..95f5e98 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -1124,8 +1124,11 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 	u8 tempval;
 	u16 tmpV16;
 
-	if (pwrstate && (rtlhal->hw_type !=
-		HARDWARE_TYPE_RTL8192SE)) {
+	if (pwrstate && (rtlhal->hw_type != HARDWARE_TYPE_RTL8192SE)) {
+		if(rtlhal->hw_type == HARDWARE_TYPE_RTL8188EE)
+			rtl_write_byte(rtlpriv, rtlpriv->cfg->maps[EFUSE_ACCESS],
+				       0x69);
+
 		tmpV16 = rtl_read_word(rtlpriv,
 				       rtlpriv->cfg->maps[SYS_ISO_CTRL]);
 		if (!(tmpV16 & rtlpriv->cfg->maps[EFUSE_PWC_EV12V])) {
@@ -1175,6 +1178,10 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
 		}
 
 	} else {
+		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8188EE)
+			rtl_write_byte(rtlpriv,
+				       rtlpriv->cfg->maps[EFUSE_ACCESS], 0);
+
 		if (write) {
 			tempval = rtl_read_byte(rtlpriv,
 						rtlpriv->cfg->maps[EFUSE_TEST] +
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 42c442e..541939a 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1721,6 +1721,10 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			 "8192D PCI-E is found - vid/did=%x/%x\n",
 			 venderid, deviceid);
+	} else if(deviceid == RTL_PCI_8188EE_DID){
+		rtlhal->hw_type = HARDWARE_TYPE_RTL8188EE;
+		RT_TRACE(rtlpriv, COMP_INIT,DBG_LOUD,
+			 "Find adapter, Hardware type is 8188EE\n");
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Err: Unknown device - vid/did=%x/%x\n",
diff --git a/drivers/net/wireless/rtlwifi/pci.h b/drivers/net/wireless/rtlwifi/pci.h
index bd368d9..d3262ec 100644
--- a/drivers/net/wireless/rtlwifi/pci.h
+++ b/drivers/net/wireless/rtlwifi/pci.h
@@ -94,6 +94,7 @@
 #define RTL_PCI_8192CU_DID	0x8191	/*8192ce */
 #define RTL_PCI_8192DE_DID	0x8193	/*8192de */
 #define RTL_PCI_8192DE_DID2	0x002B	/*92DE*/
+#define RTL_PCI_8188EE_DID	0x8179  /*8188ee*/
 
 /*8192 support 16 pages of IO registers*/
 #define RTL_MEM_MAPPED_IO_RANGE_8190PCI		0x1000
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index 690f8e2..3e8fe6d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -89,8 +89,6 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	int err = 0;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	const struct firmware *firmware;
-	char *fw_name = NULL;
 	u8 tid;
 
 	rtl8188ee_bt_reg_init(hw);
@@ -136,10 +134,17 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 				0);
 	rtlpci->irq_mask[1] = (u32) (IMR_RXFOVW | 0);
 	rtlpci->sys_irq_mask = (u32) (HSIMR_PDN_INT_EN | HSIMR_RON_INT_EN);
+
+	/* for debug level */
+	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
 	/* for LPS & IPS */
 	rtlpriv->psc.inactiveps = rtlpriv->cfg->mod_params->inactiveps;
 	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
 	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
+	if (!rtlpriv->psc.inactiveps)
+		pr_info("rtl8188ee: Power Save off (module option)\n");
+	if (!rtlpriv->psc.fwctrl_lps)
+		pr_info("rtl8188ee: FW Power Save off (module option)\n");
 	rtlpriv->psc.reg_fwctrl_lps = 3;
 	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
 	/* for ASPM, you can close aspm through
@@ -162,23 +167,18 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 		return 1;
 	}
 
-	fw_name = "rtlwifi/rtl8188efw.bin";
-	err = request_firmware(&firmware, fw_name, rtlpriv->io.dev);
-
+	/* TODO: convert to asynchronous firmware loading */
+	rtlpriv->cfg->fw_name = "rtlwifi/rtl8188efw.bin";
+	rtlpriv->max_fw_size = 0x8000;
+	pr_info("Using firmware %s\n", rtlpriv->cfg->fw_name);
+	err = request_firmware_nowait(THIS_MODULE, 1, rtlpriv->cfg->fw_name,
+				      rtlpriv->io.dev, GFP_KERNEL, hw,
+				      rtl_fw_cb);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Failed to request firmware!\n");
 		return 1;
 	}
-	if (firmware->size > 0x8000) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Firmware is too big!\n");
-		release_firmware(firmware);
-		return 1;
-	}
-	memcpy(rtlpriv->rtlhal.pfirmware, firmware->data, firmware->size);
-	rtlpriv->rtlhal.fwsize = firmware->size;
-	release_firmware(firmware);
 
 	/* for early mode */
 	rtlpriv->rtlhal.earlymode_enable = false;
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index c3a8e9e..6026d10 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -162,6 +162,7 @@ enum hardware_type {
 	HARDWARE_TYPE_RTL8192DU,
 	HARDWARE_TYPE_RTL8723AE,
 	HARDWARE_TYPE_RTL8723U,
+	HARDWARE_TYPE_RTL8188EE,
 
 	/* keep it last */
 	HARDWARE_TYPE_NUM
-- 
1.8.1.4
