From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8192ce: Log message that B_CUT device may not work
Date: Tue, 11 Sep 2012 11:11:13 -0500
Message-ID: <1347379873-9390-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Anisse Astier <anisse@astier.eu>,
	Li Chaoming <chaoming_li@realsil.com.cn>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:44076 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab2IKQLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 12:11:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a number of problems that occur for the latest version
of the Realtek RTL8188CE device with the in-kernel driver. These
include selection of the wrong firmware, and system lockup. A full
fix is known, but is too invasive for inclusion in stable. This patch
fixes the problem with loading the wrong firmware, and logs a message
that the device may not work for kernels 3.6 and older.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
Cc: Anisse Astier <anisse@astier.eu>
Cc: Li Chaoming <chaoming_li@realsil.com.cn>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |   12 ++++++++++--
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |    6 ++++--
 3 files changed, 15 insertions(+), 4 deletions(-)
---

John,

Although this patch does not fix a regression, it should prevent the
system freezes that are associated with selecting the wrong firmware
for the new devices. I hope it can be included in 3.6.

A full patch to fix the problems is nearly ready, and will be submitted
for -next later today.

Thanks,

Larry
---

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
index 04c3aef..2925094 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -117,6 +117,7 @@
 
 #define CHIP_VER_B			BIT(4)
 #define CHIP_92C_BITMASK		BIT(0)
+#define CHIP_UNKNOWN			BIT(7)
 #define CHIP_92C_1T2R			0x03
 #define CHIP_92C			0x01
 #define CHIP_88C			0x00
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index cc89582..86d73b3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -994,8 +994,16 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
 		version = (value32 & TYPE_ID) ? VERSION_A_CHIP_92C :
 			   VERSION_A_CHIP_88C;
 	} else {
-		version = (value32 & TYPE_ID) ? VERSION_B_CHIP_92C :
-			   VERSION_B_CHIP_88C;
+		version = (enum version_8192c) (CHIP_VER_B |
+				((value32 & TYPE_ID) ? CHIP_92C_BITMASK : 0) |
+				((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
+		if ((!IS_CHIP_VENDOR_UMC(version)) && (value32 &
+		     CHIP_VER_RTL_MASK)) {
+			version = (enum version_8192c)(version |
+				   ((((value32 & CHIP_VER_RTL_MASK) == BIT(12))
+				   ? CHIP_VENDOR_UMC_B_CUT : CHIP_UNKNOWN) |
+				   CHIP_VENDOR_UMC));
+		}
 	}
 
 	switch (version) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 60451ee..ea2e1bd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -162,10 +162,12 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
 
 	/* request fw */
 	if (IS_VENDOR_UMC_A_CUT(rtlhal->version) &&
-	    !IS_92C_SERIAL(rtlhal->version))
+	    !IS_92C_SERIAL(rtlhal->version)) {
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cfwU.bin";
-	else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
+	} else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cfwU_B.bin";
+		pr_info("****** This B_CUT device may not work with kernels 3.6 and earlier\n");
+	}
 
 	rtlpriv->max_fw_size = 0x4000;
 	pr_info("Using firmware %s\n", rtlpriv->cfg->fw_name);
-- 
1.7.10.4
