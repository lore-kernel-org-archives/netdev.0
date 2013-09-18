From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/8 V3] rtlwifi: Fix smatch warnings in usb.c
Date: Wed, 18 Sep 2013 14:58:57 -0500
Message-ID: <1379534339-14895-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:47931 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab3IRT7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 15:59:31 -0400
In-Reply-To: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch displays the following:
  CHECK   drivers/net/wireless/rtlwifi/usb.c
drivers/net/wireless/rtlwifi/usb.c:458 _rtl_usb_rx_process_agg() warn: assigning (-98) to unsigned variable 'stats.noise'
drivers/net/wireless/rtlwifi/usb.c:503 _rtl_usb_rx_process_noagg() warn: assigning (-98) to unsigned variable 'stats.noise'
drivers/net/wireless/rtlwifi/usb.c:596 _rtl_rx_get_padding() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/usb.c:596 _rtl_rx_get_padding() info: ignoring unreachable code.

The variable 'stats.noise' is not used, thus the initializers are removed.
The unreachable code info is fixed by including the appropriate section inside
#ifdef .. #endif constructions.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/usb.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: wireless-testing-save/drivers/net/wireless/rtlwifi/usb.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/usb.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/usb.c
@@ -455,7 +455,6 @@ static void _rtl_usb_rx_process_agg(stru
 	struct ieee80211_rx_status rx_status = {0};
 	struct rtl_stats stats = {
 		.signal = 0,
-		.noise = -98,
 		.rate = 0,
 	};
 
@@ -498,7 +497,6 @@ static void _rtl_usb_rx_process_noagg(st
 	struct ieee80211_rx_status rx_status = {0};
 	struct rtl_stats stats = {
 		.signal = 0,
-		.noise = -98,
 		.rate = 0,
 	};
 
@@ -582,12 +580,15 @@ static void _rtl_rx_work(unsigned long p
 static unsigned int _rtl_rx_get_padding(struct ieee80211_hdr *hdr,
 					unsigned int len)
 {
+#if NET_IP_ALIGN != 0
 	unsigned int padding = 0;
+#endif
 
 	/* make function no-op when possible */
 	if (NET_IP_ALIGN == 0 || len < sizeof(*hdr))
 		return 0;
 
+#if NET_IP_ALIGN != 0
 	/* alignment calculation as in lbtf_rx() / carl9170_rx_copy_data() */
 	/* TODO: deduplicate common code, define helper function instead? */
 
@@ -608,6 +609,7 @@ static unsigned int _rtl_rx_get_padding(
 		padding ^= NET_IP_ALIGN;
 
 	return padding;
+#endif
 }
 
 #define __RADIO_TAP_SIZE_RSV	32
