From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/7] rtlwifi: Implement a common rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:27 -0500
Message-ID: <1380219933-16784-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54273 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab3IZS0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:03 -0400
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several of the drivers supported by rtlwifi individually implement the same
routine that supports scans. As a first step, create this routine in
driver rtlwifi.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/base.c | 29 +++++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/base.h |  1 +
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 8bb4a9a..9a78e3d 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1613,6 +1613,35 @@ err_free:
 }
 EXPORT_SYMBOL(rtl_send_smps_action);
 
+void rtl_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	enum io_type iotype;
+
+	if (!is_hal_stop(rtlhal)) {
+		switch (operation) {
+		case SCAN_OPT_BACKUP:
+			iotype = IO_CMD_PAUSE_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+			break;
+		case SCAN_OPT_RESTORE:
+			iotype = IO_CMD_RESUME_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Unknown Scan Backup operation.\n");
+			break;
+		}
+	}
+}
+EXPORT_SYMBOL(rtl_phy_scan_operation_backup);
+
 /* There seem to be issues in mac80211 regarding when del ba frames can be
  * received. As a work around, we make a fake del_ba if we receive a ba_req;
  * however, rx_agg was opened to let mac80211 release some ba related
diff --git a/drivers/net/wireless/rtlwifi/base.h b/drivers/net/wireless/rtlwifi/base.h
index c07f114..0cd0742 100644
--- a/drivers/net/wireless/rtlwifi/base.h
+++ b/drivers/net/wireless/rtlwifi/base.h
@@ -152,5 +152,6 @@ int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
 bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb);
 struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
 				u8 *sa, u8 *bssid, u16 tid);
+void rtl_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 
 #endif
-- 
1.8.1.4
