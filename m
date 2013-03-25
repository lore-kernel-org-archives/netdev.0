From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 24/25] rtlwifi: rtl8188ee: Enable recognition of RTL8188EE
Date: Sun, 24 Mar 2013 22:06:56 -0500
Message-ID: <1364180817-8028-25-git-send-email-Larry.Finger@lwfinger.net>
References: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz, zhiyuan_yang@realsil.com.cn, page_he@realsil.com.cn
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:56177 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460Ab3CYDHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:07:53 -0400
In-Reply-To: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches modify the common probe routine to recognize the RTL8188EE
chip and implement asynchronous firmware reading in the callback routine
to initialize the sw variables.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
Cc: zhiyuan_yang@realsil.com.cn
Cc: page_he@realsil.com.cn
---
 drivers/net/wireless/rtlwifi/efuse.c | 11 +++++++++--
 drivers/net/wireless/rtlwifi/pci.c   |  4 ++++
 drivers/net/wireless/rtlwifi/pci.h   |  1 +
 drivers/net/wireless/rtlwifi/wifi.h  |  1 +
 4 files changed, 15 insertions(+), 2 deletions(-)

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
+		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8188EE)
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
index eab4492..e186322 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1750,6 +1750,10 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			 "8192D PCI-E is found - vid/did=%x/%x\n",
 			 venderid, deviceid);
+	} else if (deviceid == RTL_PCI_8188EE_DID) {
+		rtlhal->hw_type = HARDWARE_TYPE_RTL8188EE;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
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
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index c796b01..44328ba 100644
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
