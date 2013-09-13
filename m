From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 6/7] rtlwifi: Fix smatch warnings in usb.c
Date: Fri, 13 Sep 2013 12:45:03 -0500
Message-ID: <1379094304-22041-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379094304-22041-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Smatch displays the following:
  CHECK   drivers/net/wireless/rtlwifi/usb.c
drivers/net/wireless/rtlwifi/usb.c:458 _rtl_usb_rx_process_agg() warn: assigning (-98) to unsigned variable 'stats.noise'
drivers/net/wireless/rtlwifi/usb.c:503 _rtl_usb_rx_process_noagg() warn: assigning (-98) to unsigned variable 'stats.noise'
drivers/net/wireless/rtlwifi/usb.c:596 _rtl_rx_get_padding() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/usb.c:596 _rtl_rx_get_padding() info: ignoring unreachable code.

The negative number to an unsigned quantity is fixed by adding 256 to -98
to get the equivalent negative number.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/usb.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index e56778c..9f3dcb8 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -455,7 +455,7 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 	struct ieee80211_rx_status rx_status = {0};
 	struct rtl_stats stats = {
 		.signal = 0,
-		.noise = -98,
+		.noise = 158, /* -98 dBm */
 		.rate = 0,
 	};
 
@@ -498,7 +498,7 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 	struct ieee80211_rx_status rx_status = {0};
 	struct rtl_stats stats = {
 		.signal = 0,
-		.noise = -98,
+		.noise = 158, /* -98 dBm */
 		.rate = 0,
 	};
 
@@ -582,12 +582,15 @@ static void _rtl_rx_work(unsigned long param)
 static unsigned int _rtl_rx_get_padding(struct ieee80211_hdr *hdr,
 					unsigned int len)
 {
+#if NET_IP_ALIGN != 0
 	unsigned int padding = 0;
+#endif
 
 	/* make function no-op when possible */
-	if (NET_IP_ALIGN == 0 || len < sizeof(*hdr))
+	if (NET_IP_ALIGN == 0 || len < sizeof(struct ieee80211_hdr))
 		return 0;
 
+#if NET_IP_ALIGN != 0
 	/* alignment calculation as in lbtf_rx() / carl9170_rx_copy_data() */
 	/* TODO: deduplicate common code, define helper function instead? */
 
@@ -608,6 +611,7 @@ static unsigned int _rtl_rx_get_padding(struct ieee80211_hdr *hdr,
 		padding ^= NET_IP_ALIGN;
 
 	return padding;
+#endif
 }
 
 #define __RADIO_TAP_SIZE_RSV	32
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
