From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 16/16 V2] rtlwifi: rtl8723be: Turn on building of new driver
Date: Sat, 22 Feb 2014 11:17:12 -0600
Message-ID: <1393089433-28270-17-git-send-email-Larry.Finger@lwfinger.net>
References: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:64208 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbaBVRRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 12:17:39 -0500
In-Reply-To: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All code for the new driver was previously committed and it is now
possible to build the new driver.

This commit also modifies this new driver for the changed API for
ieee80211_is_robust_mgmt_frame().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/Kconfig            | 19 ++++++++++++++++---
 drivers/net/wireless/rtlwifi/Makefile           |  1 +
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile | 20 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c    |  2 +-
 4 files changed, 38 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/Makefile

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index 9251e0d..bf3cf12 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -5,7 +5,7 @@ menuconfig RTL_CARDS
 	---help---
 	  This option will enable support for the Realtek mac80211-based
 	  wireless drivers. Drivers rtl8192ce, rtl8192cu, rtl8192se, rtl8192de,
-	  rtl8723ae, and rtl8188ae share some common code.
+	  rtl8723ae, rtl8723be, and rtl8188ae share some common code.
 
 if RTL_CARDS
 
@@ -56,6 +56,19 @@ config RTL8723AE
 
 	If you choose to build it as a module, it will be called rtl8723ae
 
+config RTL8723BE
+	tristate "Realtek RTL8723BE PCIe Wireless Network Adapter"
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
+	select RTL8723_COMMON
+	select RTLBTCOEXIST
+	---help---
+	This is the driver for Realtek RTL8723BE 802.11n PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called rtl8723be
+
 config RTL8188EE
 	tristate "Realtek RTL8188EE Wireless Network Adapter"
 	depends on PCI
@@ -105,12 +118,12 @@ config RTL8192C_COMMON
 
 config RTL8723_COMMON
 	tristate
-	depends on RTL8723AE
+	depends on RTL8723AE || RTL8723BE
 	default y
 
 config RTLBTCOEXIST
 	tristate
-	depends on RTL8723AE
+	depends on RTL8723AE || RTL8723BE
 	default y
 
 endif
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wireless/rtlwifi/Makefile
index d97d1b9..bba36a0 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_RTL8192CU)		+= rtl8192cu/
 obj-$(CONFIG_RTL8192SE)		+= rtl8192se/
 obj-$(CONFIG_RTL8192DE)		+= rtl8192de/
 obj-$(CONFIG_RTL8723AE)		+= rtl8723ae/
+obj-$(CONFIG_RTL8723BE)		+= rtl8723be/
 obj-$(CONFIG_RTL8188EE)		+= rtl8188ee/
 obj-$(CONFIG_RTLBTCOEXIST)	+= btcoexist/
 obj-$(CONFIG_RTL8723_COMMON)	+= rtl8723com/
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/Makefile b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
new file mode 100644
index 0000000..4a75aab
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
@@ -0,0 +1,20 @@
+obj-m := rtl8723be.o
+
+
+rtl8723be-objs :=		\
+		dm.o		\
+		fw.o		\
+		hw.o		\
+		led.o		\
+		phy.o		\
+		pwrseq.o	\
+		pwrseqcmd.o	\
+		rf.o		\
+		sw.o		\
+		table.o		\
+		trx.o		\
+
+
+obj-$(CONFIG_RTL8723BE) += rtl8723be.o
+
+ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index d84adb3..58f1fa1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -602,7 +602,7 @@ bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 			return false;
 		}
 
-		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
+		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 		else
-- 
1.8.4.5
