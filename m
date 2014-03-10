From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT] rtlwifi: rtl8723be: Fix array dimension problems
Date: Mon, 10 Mar 2014 18:53:10 -0500
Message-ID: <1394495590-2351-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:53083 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbaCJXxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 19:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a619d1abe20c leads to the following static checker warning:

drivers/net/wireless/rtlwifi/rtl8723be/phy.c:667 _rtl8723be_store_tx_power_by_rate()
error: buffer overflow 'rtlphy->tx_power_by_rate_offset[band]' 4 <= 5

This warning arises because the code is testing the indices for the wrong maximum
values. In addition, the tests merely putput a warning, and then procedes to
corrupt memory. With this change, any such invalid memory access is avoided.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
index cadae9b..1575ef9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
@@ -629,18 +629,22 @@ static void _rtl8723be_store_tx_power_by_rate(struct ieee80211_hw *hw,
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	u8 rate_section = _rtl8723be_get_rate_section_index(regaddr);
 
-	if (band != BAND_ON_2_4G && band != BAND_ON_5G)
+	if (band != BAND_ON_2_4G && band != BAND_ON_5G) {
 		RT_TRACE(rtlpriv, COMP_POWER, PHY_TXPWR,
 			 "Invalid Band %d\n", band);
+		return;
+	}
 
-	if (rfpath > MAX_RF_PATH)
+	if (rfpath > TX_PWR_BY_RATE_NUM_RF) {
 		RT_TRACE(rtlpriv, COMP_POWER, PHY_TXPWR,
 			 "Invalid RfPath %d\n", rfpath);
-
-	if (txnum > MAX_RF_PATH)
+		return;
+	}
+	if (txnum > TX_PWR_BY_RATE_NUM_RF) {
 		RT_TRACE(rtlpriv, COMP_POWER, PHY_TXPWR,
 			 "Invalid TxNum %d\n", txnum);
-
+		return;
+	}
 	rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][rate_section] =
 									data;
 }
-- 
1.8.4.5
