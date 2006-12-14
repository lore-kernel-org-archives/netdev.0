From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 2/6] d80211: create "wifi.h" to define WIFI OUIs
Date: Thu, 14 Dec 2006 12:02:16 +0800
Message-ID: <20061214040216.GA10652@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46733 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbWLNEON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 23:14:13 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace hard coded WIFI OUIs and parse TSPEC information element.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/d80211/ieee80211_sta.c |   36 ++++++++++++++++++++++++++++++++----
 net/d80211/wifi.h          |   28 ++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 4 deletions(-)
 create mode 100644 net/d80211/wifi.h

d30f04a9e760702363bdad8aef47477762f6d06f
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 4985afe..cf11e88 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -27,6 +27,7 @@
 
 #include <net/d80211.h>
 #include <net/d80211_mgmt.h>
+#include "wifi.h"
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "hostapd_ioctl.h"
@@ -97,6 +98,8 @@ struct ieee802_11_elems {
 	u8 wmm_info_len;
 	u8 *wmm_param;
 	u8 wmm_param_len;
+	u8 *tspec;
+	u8 tspec_len;
 };
 
 typedef enum { ParseOK = 0, ParseUnknown = 1, ParseFailed = -1 } ParseRes;
@@ -165,17 +168,34 @@ static ParseRes ieee802_11_parse_elems(u
 			if (elen >= 4 && pos[0] == 0x00 && pos[1] == 0x50 &&
 			    pos[2] == 0xf2) {
 				/* Microsoft OUI (00:50:F2) */
-				if (pos[3] == 1) {
+				if (pos[3] == WIFI_OUI_TYPE_WPA) {
 					/* OUI Type 1 - WPA IE */
 					elems->wpa = pos;
 					elems->wpa_len = elen;
-				} else if (elen >= 5 && pos[3] == 2) {
-					if (pos[4] == 0) {
+				} else if (elen >= 5 &&
+					   pos[3] == WIFI_OUI_TYPE_WMM) {
+					switch (pos[4]) {
+					case WIFI_OUI_STYPE_WMM_INFO:
 						elems->wmm_info = pos;
 						elems->wmm_info_len = elen;
-					} else if (pos[4] == 1) {
+						break;
+					case WIFI_OUI_STYPE_WMM_PARAM:
 						elems->wmm_param = pos;
 						elems->wmm_param_len = elen;
+						break;
+					case WIFI_OUI_STYPE_WMM_TSPEC:
+						if (elen != 61) {
+							printk(KERN_ERR "Wrong "
+							       "TSPEC size.\n");
+							break;
+						}
+						elems->tspec = pos + 6;
+						elems->tspec_len = elen - 6;
+						break;
+					default:
+						//printk(KERN_ERR "Unsupported "
+						//       "WiFi OUI %d\n", pos[4]);
+						break;
 					}
 				}
 			}
@@ -192,6 +212,14 @@ static ParseRes ieee802_11_parse_elems(u
 			elems->ext_supp_rates = pos;
 			elems->ext_supp_rates_len = elen;
 			break;
+		case WLAN_EID_TSPEC:
+			if (elen != 55) {
+				printk(KERN_ERR "Wrong TSPEC size.\n");
+				break;
+			}
+			elems->tspec = pos;
+			elems->tspec_len = elen;
+			break;
 		default:
 #if 0
 			printk(KERN_DEBUG "IEEE 802.11 element parse ignored "
diff --git a/net/d80211/wifi.h b/net/d80211/wifi.h
new file mode 100644
index 0000000..8ed1b63
--- /dev/null
+++ b/net/d80211/wifi.h
@@ -0,0 +1,28 @@
+/*
+ * This file defines Wi-Fi(r) OUIs for 80211.o
+ * Copyright 2006, Zhu Yi <yi.zhu@intel.com>  Intel Corp.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef D802_11_WIFI_H
+#define D802_11_WIFI_H
+
+/* WI-FI Alliance OUI Type and Subtype */
+enum wifi_oui_type {
+	WIFI_OUI_TYPE_WPA = 1,
+	WIFI_OUI_TYPE_WMM = 2,
+	WIFI_OUI_TYPE_WSC = 4,
+	WIFI_OUI_TYPE_PSD = 6,
+};
+
+enum wifi_oui_stype_wmm {
+	WIFI_OUI_STYPE_WMM_INFO = 0,
+	WIFI_OUI_STYPE_WMM_PARAM = 1,
+	WIFI_OUI_STYPE_WMM_TSPEC = 2,
+};
+
+
+#endif /* D802_11_WIFI_H */
-- 
1.2.6
