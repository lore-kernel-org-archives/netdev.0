From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Initialize power-setting callback for USB devices
Date: Fri, 28 Jun 2013 09:12:53 -0500
Message-ID: <1372428773-9993-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Richard Genoud <richard.genoud@gmail.com>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f180.google.com ([209.85.128.180]:42992 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143Ab3F1ONL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 10:13:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a269913c5 entitled "rtlwifi: Rework rtl_lps_leave() and
rtl_lps_enter() to use work queue" has two bugs for USB drivers.
Firstly, the work queue in question was not initialized. Secondly,
the callback routine used by this queue is contained within the
file used for PCI devices. As a result, it is not available for
architectures without PCI hardware.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Richard Genoud <richard.genoud@gmail.com>
Tested-by: Richard Genoud <richard.genoud@gmail.com>
Cc: Richard Genoud <richard.genoud@gmail.com>
Cc: Stable <stable@vger.kernel.org> [3.10]
---

John,

Ideally, this patch should be pushed to the 3.10 stream; however, at this late time
that is not possible. Please push it for 3.11 and the Cc to stable will get it
into 3.10.X.

Larry
---
 drivers/net/wireless/rtlwifi/pci.c | 13 -------------
 drivers/net/wireless/rtlwifi/ps.c  | 12 ++++++++++++
 drivers/net/wireless/rtlwifi/ps.h  |  1 +
 drivers/net/wireless/rtlwifi/usb.c |  2 ++
 4 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index c97e9d3..e70b4ff 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1008,19 +1008,6 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	return;
 }
 
-static void rtl_lps_change_work_callback(struct work_struct *work)
-{
-	struct rtl_works *rtlworks =
-	    container_of(work, struct rtl_works, lps_change_work);
-	struct ieee80211_hw *hw = rtlworks->hw;
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-
-	if (rtlpriv->enter_ps)
-		rtl_lps_enter(hw);
-	else
-		rtl_lps_leave(hw);
-}
-
 static void _rtl_pci_init_trx_var(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 884bcea..71e917d 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -611,6 +611,18 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 			MSECS(sleep_intv * mac->vif->bss_conf.beacon_int - 40));
 }
 
+void rtl_lps_change_work_callback(struct work_struct *work)
+{
+	struct rtl_works *rtlworks =
+	    container_of(work, struct rtl_works, lps_change_work);
+	struct ieee80211_hw *hw = rtlworks->hw;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->enter_ps)
+		rtl_lps_enter(hw);
+	else
+		rtl_lps_leave(hw);
+}
 
 void rtl_swlps_wq_callback(void *data)
 {
diff --git a/drivers/net/wireless/rtlwifi/ps.h b/drivers/net/wireless/rtlwifi/ps.h
index 4d682b7..88bd76e 100644
--- a/drivers/net/wireless/rtlwifi/ps.h
+++ b/drivers/net/wireless/rtlwifi/ps.h
@@ -49,5 +49,6 @@ void rtl_swlps_rf_awake(struct ieee80211_hw *hw);
 void rtl_swlps_rf_sleep(struct ieee80211_hw *hw);
 void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
 void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len);
+void rtl_lps_change_work_callback(struct work_struct *work);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index a3532e0..1feebdc 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -1070,6 +1070,8 @@ int rtl_usb_probe(struct usb_interface *intf,
 	spin_lock_init(&rtlpriv->locks.usb_lock);
 	INIT_WORK(&rtlpriv->works.fill_h2c_cmd,
 		  rtl_fill_h2c_cmd_work_callback);
+	INIT_WORK(&rtlpriv->works.lps_change_work,
+		  rtl_lps_change_work_callback);
 
 	rtlpriv->usb_data_index = 0;
 	init_completion(&rtlpriv->firmware_loading_complete);
-- 
1.8.1.4
