From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH v3] rtlwifi: rtl8192se firmware load can overflow target buffer
Date: Thu,  9 Feb 2012 18:19:52 -0600
Message-ID: <1328833192-10681-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:54920 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757799Ab2BJAUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 19:20:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Gardner <tim.gardner@canonical.com>

Define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE which represents the
maximimum possible firmware file size. Use it in the definition
of the buffer which receives the firmware file data.

Set RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE closer to the actual size of
the firmware file, e.g., 90000 (down from hard coded 164000). The current
size of rtlwifi/rtl8192sefw.bin is 88856.

Set max_fw_size to RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE for the size limit
check. Fix the error case where max_fw_size is not cleared if the size
limit check fails.

Cc: Chaoming Li <chaoming_li@realsil.com.cn>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h |    3 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
index babe85d..b4afff6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
@@ -30,6 +30,7 @@
 #define __REALTEK_FIRMWARE92S_H__
 
 #define RTL8190_MAX_FIRMWARE_CODE_SIZE		64000
+#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	90000
 #define RTL8190_CPU_START_OFFSET		0x80
 /* Firmware Local buffer size. 64k */
 #define	MAX_FIRMWARE_CODE_SIZE			0xFF00
@@ -217,7 +218,7 @@ struct rt_firmware {
 	u8 fw_emem[RTL8190_MAX_FIRMWARE_CODE_SIZE];
 	u32 fw_imem_len;
 	u32 fw_emem_len;
-	u8 sz_fw_tmpbuffer[164000];
+	u8 sz_fw_tmpbuffer[RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE];
 	u32 sz_fw_tmpbufferlen;
 	u16 cmdpacket_fragthresold;
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index ca38dd9..345d752 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -108,6 +108,7 @@ static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
 	if (firmware->size > rtlpriv->max_fw_size) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Firmware is too big!\n");
+		rtlpriv->max_fw_size = 0;
 		release_firmware(firmware);
 		return;
 	}
@@ -232,7 +233,7 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 		return 1;
 	}
 
-	rtlpriv->max_fw_size = sizeof(struct rt_firmware);
+	rtlpriv->max_fw_size = RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE;
 
 	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
 		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
-- 
1.7.9
