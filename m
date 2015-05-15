From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/5] rtlwifi: Update regulatory database
Date: Fri, 15 May 2015 16:32:59 -0500
Message-ID: <1431725583-7324-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Shao Fu <shaofu@realtek.com>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33532 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964796AbbEOVdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:33:14 -0400
In-Reply-To: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shao Fu <shaofu@realtek.com>

Driver rtlwifi maintains its own regulatory information, The Chrome Autotest
(https://www.chromium.org/chromium-os/testing/autotest-user-doc)
showed some errors. This patch adds the necessary information for rtlwifi.

Signed-off-by: Shao Fu <shaofu@realtek.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/regd.c | 42 +++++++++++++++++++++++++++++++++----
 drivers/net/wireless/rtlwifi/regd.h |  1 +
 2 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/regd.c b/drivers/net/wireless/rtlwifi/regd.c
index 1893d01..a62bf0a 100644
--- a/drivers/net/wireless/rtlwifi/regd.c
+++ b/drivers/net/wireless/rtlwifi/regd.c
@@ -40,6 +40,7 @@ static struct country_code_to_enum_rd allCountries[] = {
 	{COUNTRY_CODE_GLOBAL_DOMAIN, "JP"},
 	{COUNTRY_CODE_WORLD_WIDE_13, "EC"},
 	{COUNTRY_CODE_TELEC_NETGEAR, "EC"},
+	{COUNTRY_CODE_WORLD_WIDE_13_5G_ALL, "US"},
 };
 
 /*
@@ -124,6 +125,17 @@ static const struct ieee80211_regdomain rtl_regdom_14_60_64 = {
 		      }
 };
 
+static const struct ieee80211_regdomain rtl_regdom_12_13_5g_all = {
+	.n_reg_rules = 4,
+	.alpha2 = "99",
+	.reg_rules = {
+			RTL819x_2GHZ_CH01_11,
+			RTL819x_2GHZ_CH12_13,
+			RTL819x_5GHZ_5150_5350,
+			RTL819x_5GHZ_5470_5850,
+		}
+};
+
 static const struct ieee80211_regdomain rtl_regdom_14 = {
 	.n_reg_rules = 3,
 	.alpha2 = "99",
@@ -348,6 +360,8 @@ static const struct ieee80211_regdomain *_rtl_regdomain_select(
 		return &rtl_regdom_14_60_64;
 	case COUNTRY_CODE_GLOBAL_DOMAIN:
 		return &rtl_regdom_14;
+	case COUNTRY_CODE_WORLD_WIDE_13_5G_ALL:
+		return &rtl_regdom_12_13_5g_all;
 	default:
 		return &rtl_regdom_no_midband;
 	}
@@ -384,6 +398,25 @@ static struct country_code_to_enum_rd *_rtl_regd_find_country(u16 countrycode)
 	return NULL;
 }
 
+static u8 channel_plan_to_country_code(u8 channelplan)
+{
+	switch (channelplan) {
+	case 0x20:
+	case 0x21:
+		return COUNTRY_CODE_WORLD_WIDE_13;
+	case 0x22:
+		return COUNTRY_CODE_IC;
+	case 0x32:
+		return COUNTRY_CODE_TELEC_NETGEAR;
+	case 0x41:
+		return COUNTRY_CODE_GLOBAL_DOMAIN;
+	case 0x7f:
+		return COUNTRY_CODE_WORLD_WIDE_13_5G_ALL;
+	default:
+		return COUNTRY_CODE_MAX; /*Error*/
+	}
+}
+
 int rtl_regd_init(struct ieee80211_hw *hw,
 		  void (*reg_notifier)(struct wiphy *wiphy,
 				       struct regulatory_request *request))
@@ -396,11 +429,12 @@ int rtl_regd_init(struct ieee80211_hw *hw,
 		return -EINVAL;
 
 	/* init country_code from efuse channel plan */
-	rtlpriv->regd.country_code = rtlpriv->efuse.channel_plan;
+	rtlpriv->regd.country_code =
+		channel_plan_to_country_code(rtlpriv->efuse.channel_plan);
 
-	RT_TRACE(rtlpriv, COMP_REGD, DBG_TRACE,
-		 "rtl: EEPROM regdomain: 0x%0x\n",
-		  rtlpriv->regd.country_code);
+	RT_TRACE(rtlpriv, COMP_REGD, DBG_DMESG,
+		 "rtl: EEPROM regdomain: 0x%0x conuntry code: %d\n",
+		 rtlpriv->efuse.channel_plan, rtlpriv->regd.country_code);
 
 	if (rtlpriv->regd.country_code >= COUNTRY_CODE_MAX) {
 		RT_TRACE(rtlpriv, COMP_REGD, DBG_DMESG,
diff --git a/drivers/net/wireless/rtlwifi/regd.h b/drivers/net/wireless/rtlwifi/regd.h
index 3bbbaaa..f7f15bc 100644
--- a/drivers/net/wireless/rtlwifi/regd.h
+++ b/drivers/net/wireless/rtlwifi/regd.h
@@ -49,6 +49,7 @@ enum country_code_type_t {
 	COUNTRY_CODE_GLOBAL_DOMAIN = 10,
 	COUNTRY_CODE_WORLD_WIDE_13 = 11,
 	COUNTRY_CODE_TELEC_NETGEAR = 12,
+	COUNTRY_CODE_WORLD_WIDE_13_5G_ALL = 13,
 
 	/*add new channel plan above this line */
 	COUNTRY_CODE_MAX
-- 
2.1.4
