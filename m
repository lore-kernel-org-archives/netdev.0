From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 13/14] d80211: merge d80211_mgmt.h into linux/ieee80211.h
Date: Wed, 13 Dec 2006 17:41:48 +0100 (CET)
Message-ID: <20061213164148.00F213AA7EC@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57271 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965048AbWLMRI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:56 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This merges d80211_mgmt.h with linux/ieee80211.h, to keep all the general
802.11 definitions in one place.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h |    1 
 include/linux/ieee80211.h                     |  208 +++++++++++++++++++++++
 include/net/d80211_mgmt.h                     |  223 -------------------------
 net/d80211/ieee80211.c                        |    1 
 net/d80211/ieee80211_iface.c                  |    1 
 net/d80211/ieee80211_ioctl.c                  |    1 
 net/d80211/ieee80211_sta.c                    |    1 
 7 files changed, 208 insertions(+), 228 deletions(-)
 delete mode 100644 include/net/d80211_mgmt.h

3c00986b08e969cc141bd094dfd8e2f20340c8c7
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
index 2a18875..a607857 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -14,7 +14,6 @@ #include <asm/io.h>
 #include <linux/ssb.h>
 #include <linux/wireless.h>
 #include <net/d80211.h>
-#include <net/d80211_mgmt.h>
 #include <net/d80211_common.h>
 
 #include "bcm43xx_debugfs.h"
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 9afa694..fe9ef26 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -104,4 +104,212 @@ struct ieee80211_hdr {
 	__u8 addr4[6];
 } __attribute__ ((packed));
 
+
+struct ieee80211_mgmt {
+	__le16 frame_control;
+	__le16 duration;
+	__u8 da[6];
+	__u8 sa[6];
+	__u8 bssid[6];
+	__le16 seq_ctrl;
+	union {
+		struct {
+			__le16 auth_alg;
+			__le16 auth_transaction;
+			__le16 status_code;
+			/* possibly followed by Challenge text */
+			__u8 variable[0];
+		} __attribute__ ((packed)) auth;
+		struct {
+			__le16 reason_code;
+		} __attribute__ ((packed)) deauth;
+		struct {
+			__le16 capab_info;
+			__le16 listen_interval;
+			/* followed by SSID and Supported rates */
+			u8 variable[0];
+		} __attribute__ ((packed)) assoc_req;
+		struct {
+			__le16 capab_info;
+			__le16 status_code;
+			__le16 aid;
+			/* followed by Supported rates */
+			__u8 variable[0];
+		} __attribute__ ((packed)) assoc_resp, reassoc_resp;
+		struct {
+			__le16 capab_info;
+			__le16 listen_interval;
+			__u8 current_ap[6];
+			/* followed by SSID and Supported rates */
+			__u8 variable[0];
+		} __attribute__ ((packed)) reassoc_req;
+		struct {
+			__le16 reason_code;
+		} __attribute__ ((packed)) disassoc;
+		struct {
+			__le64 timestamp;
+			__le16 beacon_int;
+			__le16 capab_info;
+			/* followed by some of SSID, Supported rates,
+			 * FH Params, DS Params, CF Params, IBSS Params, TIM */
+			__u8 variable[0];
+		} __attribute__ ((packed)) beacon;
+		struct {
+			/* only variable items: SSID, Supported rates */
+			__u8 variable[0];
+		} __attribute__ ((packed)) probe_req;
+		struct {
+			__le64 timestamp;
+			__le16 beacon_int;
+			__le16 capab_info;
+			/* followed by some of SSID, Supported rates,
+			 * FH Params, DS Params, CF Params, IBSS Params */
+			__u8 variable[0];
+		} __attribute__ ((packed)) probe_resp;
+		struct {
+			__u8 category;
+			union {
+				struct {
+					__u8 action_code;
+					__u8 dialog_token;
+					__u8 status_code;
+					__u8 variable[0];
+				} __attribute__ ((packed)) wme_action;
+				struct{
+					__u8 action_code;
+					__u8 element_id;
+					__u8 length;
+					__u8 switch_mode;
+					__u8 new_chan;
+					__u8 switch_count;
+				} __attribute__((packed)) chan_switch;
+			} u;
+		} __attribute__ ((packed)) action;
+	} u;
+} __attribute__ ((packed));
+
+
+/* Authentication algorithms */
+#define WLAN_AUTH_OPEN 0
+#define WLAN_AUTH_SHARED_KEY 1
+#define WLAN_AUTH_LEAP 128
+
+#define WLAN_AUTH_CHALLENGE_LEN 128
+
+#define WLAN_CAPABILITY_ESS		(1<<0)
+#define WLAN_CAPABILITY_IBSS		(1<<1)
+#define WLAN_CAPABILITY_CF_POLLABLE	(1<<2)
+#define WLAN_CAPABILITY_CF_POLL_REQUEST	(1<<3)
+#define WLAN_CAPABILITY_PRIVACY		(1<<4)
+#define WLAN_CAPABILITY_SHORT_PREAMBLE	(1<<5)
+#define WLAN_CAPABILITY_PBCC		(1<<6)
+#define WLAN_CAPABILITY_CHANNEL_AGILITY	(1<<7)
+/* 802.11h */
+#define WLAN_CAPABILITY_SPECTRUM_MGMT	(1<<8)
+#define WLAN_CAPABILITY_QOS		(1<<9)
+#define WLAN_CAPABILITY_SHORT_SLOT_TIME	(1<<10)
+#define WLAN_CAPABILITY_DSSS_OFDM	(1<<13)
+
+/* Status codes */
+enum ieee80211_statuscode {
+	WLAN_STATUS_SUCCESS = 0,
+	WLAN_STATUS_UNSPECIFIED_FAILURE = 1,
+	WLAN_STATUS_CAPS_UNSUPPORTED = 10,
+	WLAN_STATUS_REASSOC_NO_ASSOC = 11,
+	WLAN_STATUS_ASSOC_DENIED_UNSPEC = 12,
+	WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG = 13,
+	WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION = 14,
+	WLAN_STATUS_CHALLENGE_FAIL = 15,
+	WLAN_STATUS_AUTH_TIMEOUT = 16,
+	WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA = 17,
+	WLAN_STATUS_ASSOC_DENIED_RATES = 18,
+	/* 802.11b */
+	WLAN_STATUS_ASSOC_DENIED_NOSHORTPREAMBLE = 19,
+	WLAN_STATUS_ASSOC_DENIED_NOPBCC = 20,
+	WLAN_STATUS_ASSOC_DENIED_NOAGILITY = 21,
+	/* 802.11h */
+	WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM = 22,
+	WLAN_STATUS_ASSOC_REJECTED_BAD_POWER = 23,
+	WLAN_STATUS_ASSOC_REJECTED_BAD_SUPP_CHAN = 24,
+	/* 802.11g */
+	WLAN_STATUS_ASSOC_DENIED_NOSHORTTIME = 25,
+	WLAN_STATUS_ASSOC_DENIED_NODSSSOFDM = 26,
+	/* 802.11i */
+	WLAN_STATUS_INVALID_IE = 40,
+	WLAN_STATUS_INVALID_GROUP_CIPHER = 41,
+	WLAN_STATUS_INVALID_PAIRWISE_CIPHER = 42,
+	WLAN_STATUS_INVALID_AKMP = 43,
+	WLAN_STATUS_UNSUPP_RSN_VERSION = 44,
+	WLAN_STATUS_INVALID_RSN_IE_CAP = 45,
+	WLAN_STATUS_CIPHER_SUITE_REJECTED = 46,
+};
+
+
+/* Reason codes */
+enum ieee80211_reasoncode {
+	WLAN_REASON_UNSPECIFIED = 1,
+	WLAN_REASON_PREV_AUTH_NOT_VALID = 2,
+	WLAN_REASON_DEAUTH_LEAVING = 3,
+	WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY = 4,
+	WLAN_REASON_DISASSOC_AP_BUSY = 5,
+	WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA = 6,
+	WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA = 7,
+	WLAN_REASON_DISASSOC_STA_HAS_LEFT = 8,
+	WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH = 9,
+	/* 802.11h */
+	WLAN_REASON_DISASSOC_BAD_POWER = 10,
+	WLAN_REASON_DISASSOC_BAD_SUPP_CHAN = 11,
+	/* 802.11i */
+	WLAN_REASON_INVALID_IE = 13,
+	WLAN_REASON_MIC_FAILURE = 14,
+	WLAN_REASON_4WAY_HANDSHAKE_TIMEOUT = 15,
+	WLAN_REASON_GROUP_KEY_HANDSHAKE_TIMEOUT = 16,
+	WLAN_REASON_IE_DIFFERENT = 17,
+	WLAN_REASON_INVALID_GROUP_CIPHER = 18,
+	WLAN_REASON_INVALID_PAIRWISE_CIPHER = 19,
+	WLAN_REASON_INVALID_AKMP = 20,
+	WLAN_REASON_UNSUPP_RSN_VERSION = 21,
+	WLAN_REASON_INVALID_RSN_IE_CAP = 22,
+	WLAN_REASON_IEEE8021X_FAILED = 23,
+	WLAN_REASON_CIPHER_SUITE_REJECTED = 24,
+};
+
+
+/* Information Element IDs */
+enum ieee80211_eid {
+	WLAN_EID_SSID = 0,
+	WLAN_EID_SUPP_RATES = 1,
+	WLAN_EID_FH_PARAMS = 2,
+	WLAN_EID_DS_PARAMS = 3,
+	WLAN_EID_CF_PARAMS = 4,
+	WLAN_EID_TIM = 5,
+	WLAN_EID_IBSS_PARAMS = 6,
+	WLAN_EID_CHALLENGE = 16,
+	/* 802.11d */
+	WLAN_EID_COUNTRY = 7,
+	WLAN_EID_HP_PARAMS = 8,
+	WLAN_EID_HP_TABLE = 9,
+	WLAN_EID_REQUEST = 10,
+	/* 802.11h */
+	WLAN_EID_PWR_CONSTRAINT = 32,
+	WLAN_EID_PWR_CAPABILITY = 33,
+	WLAN_EID_TPC_REQUEST = 34,
+	WLAN_EID_TPC_REPORT = 35,
+	WLAN_EID_SUPPORTED_CHANNELS = 36,
+	WLAN_EID_CHANNEL_SWITCH = 37,
+	WLAN_EID_MEASURE_REQUEST = 38,
+	WLAN_EID_MEASURE_REPORT = 39,
+	WLAN_EID_QUIET = 40,
+	WLAN_EID_IBSS_DFS = 41,
+	/* 802.11g */
+	WLAN_EID_ERP_INFO = 42,
+	WLAN_EID_EXT_SUPP_RATES = 50,
+	/* 802.11i */
+	WLAN_EID_RSN = 48,
+	WLAN_EID_WPA = 221,
+	WLAN_EID_GENERIC = 221,
+	WLAN_EID_VENDOR_SPECIFIC = 221,
+	WLAN_EID_QOS_PARAMETER = 222
+};
+
 #endif /* IEEE80211_H */
diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
deleted file mode 100644
index 87141d4..0000000
--- a/include/net/d80211_mgmt.h
+++ /dev/null
@@ -1,223 +0,0 @@
-/*
- * IEEE 802.11 -- shared defines for 80211.o and hostapd
- * Copyright 2002, Jouni Malinen <jkmaline@cc.hut.fi>
- * Copyright 2002-2004, Instant802 Networks, Inc.
- * Copyright 2005, Devicescape Software, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef D802_11_MGMT_H
-#define D802_11_MGMT_H
-
-#include <linux/types.h>
-
-struct ieee80211_mgmt {
-	__le16 frame_control;
-	__le16 duration;
-	u8 da[6];
-	u8 sa[6];
-	u8 bssid[6];
-	__le16 seq_ctrl;
-	union {
-		struct {
-			__le16 auth_alg;
-			__le16 auth_transaction;
-			__le16 status_code;
-			/* possibly followed by Challenge text */
-			u8 variable[0];
-		} __attribute__ ((packed)) auth;
-		struct {
-			__le16 reason_code;
-		} __attribute__ ((packed)) deauth;
-		struct {
-			__le16 capab_info;
-			__le16 listen_interval;
-			/* followed by SSID and Supported rates */
-			u8 variable[0];
-		} __attribute__ ((packed)) assoc_req;
-		struct {
-			__le16 capab_info;
-			__le16 status_code;
-			__le16 aid;
-			/* followed by Supported rates */
-			u8 variable[0];
-		} __attribute__ ((packed)) assoc_resp, reassoc_resp;
-		struct {
-			__le16 capab_info;
-			__le16 listen_interval;
-			u8 current_ap[6];
-			/* followed by SSID and Supported rates */
-			u8 variable[0];
-		} __attribute__ ((packed)) reassoc_req;
-		struct {
-			__le16 reason_code;
-		} __attribute__ ((packed)) disassoc;
-		struct {
-			__le64 timestamp;
-			__le16 beacon_int;
-			__le16 capab_info;
-			/* followed by some of SSID, Supported rates,
-			 * FH Params, DS Params, CF Params, IBSS Params, TIM */
-			u8 variable[0];
-		} __attribute__ ((packed)) beacon;
-		struct {
-			/* only variable items: SSID, Supported rates */
-			u8 variable[0];
-		} __attribute__ ((packed)) probe_req;
-		struct {
-			__le64 timestamp;
-			__le16 beacon_int;
-			__le16 capab_info;
-			/* followed by some of SSID, Supported rates,
-			 * FH Params, DS Params, CF Params, IBSS Params */
-			u8 variable[0];
-		} __attribute__ ((packed)) probe_resp;
-		struct {
-			u8 category;
-			union {
-				struct {
-					u8 action_code;
-					u8 dialog_token;
-					u8 status_code;
-					u8 variable[0];
-				} __attribute__ ((packed)) wme_action;
-				struct{
-					u8 action_code;
-					u8 element_id;
-					u8 length;
-					u8 switch_mode;
-					u8 new_chan;
-					u8 switch_count;
-				} __attribute__((packed)) chan_switch;
-			} u;
-		} __attribute__ ((packed)) action;
-	} u;
-} __attribute__ ((packed));
-
-
-/* Authentication algorithms */
-#define WLAN_AUTH_OPEN 0
-#define WLAN_AUTH_SHARED_KEY 1
-#define WLAN_AUTH_LEAP 128
-
-#define WLAN_AUTH_CHALLENGE_LEN 128
-
-#define WLAN_CAPABILITY_ESS BIT(0)
-#define WLAN_CAPABILITY_IBSS BIT(1)
-#define WLAN_CAPABILITY_CF_POLLABLE BIT(2)
-#define WLAN_CAPABILITY_CF_POLL_REQUEST BIT(3)
-#define WLAN_CAPABILITY_PRIVACY BIT(4)
-#define WLAN_CAPABILITY_SHORT_PREAMBLE BIT(5)
-#define WLAN_CAPABILITY_PBCC BIT(6)
-#define WLAN_CAPABILITY_CHANNEL_AGILITY BIT(7)
-/* 802.11h */
-#define WLAN_CAPABILITY_SPECTRUM_MGMT BIT(8)
-#define WLAN_CAPABILITY_SHORT_SLOT_TIME BIT(10)
-#define WLAN_CAPABILITY_DSSS_OFDM BIT(13)
-
-/* Status codes */
-enum ieee80211_statuscode {
-	WLAN_STATUS_SUCCESS = 0,
-	WLAN_STATUS_UNSPECIFIED_FAILURE = 1,
-	WLAN_STATUS_CAPS_UNSUPPORTED = 10,
-	WLAN_STATUS_REASSOC_NO_ASSOC = 11,
-	WLAN_STATUS_ASSOC_DENIED_UNSPEC = 12,
-	WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG = 13,
-	WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION = 14,
-	WLAN_STATUS_CHALLENGE_FAIL = 15,
-	WLAN_STATUS_AUTH_TIMEOUT = 16,
-	WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA = 17,
-	WLAN_STATUS_ASSOC_DENIED_RATES = 18,
-	/* 802.11b */
-	WLAN_STATUS_ASSOC_DENIED_NOSHORTPREAMBLE = 19,
-	WLAN_STATUS_ASSOC_DENIED_NOPBCC = 20,
-	WLAN_STATUS_ASSOC_DENIED_NOAGILITY = 21,
-	/* 802.11h */
-	WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM = 22,
-	WLAN_STATUS_ASSOC_REJECTED_BAD_POWER = 23,
-	WLAN_STATUS_ASSOC_REJECTED_BAD_SUPP_CHAN = 24,
-	/* 802.11g */
-	WLAN_STATUS_ASSOC_DENIED_NOSHORTTIME = 25,
-	WLAN_STATUS_ASSOC_DENIED_NODSSSOFDM = 26,
-	/* 802.11i */
-	WLAN_STATUS_INVALID_IE = 40,
-	WLAN_STATUS_INVALID_GROUP_CIPHER = 41,
-	WLAN_STATUS_INVALID_PAIRWISE_CIPHER = 42,
-	WLAN_STATUS_INVALID_AKMP = 43,
-	WLAN_STATUS_UNSUPP_RSN_VERSION = 44,
-	WLAN_STATUS_INVALID_RSN_IE_CAP = 45,
-	WLAN_STATUS_CIPHER_SUITE_REJECTED = 46,
-};
-
-
-/* Reason codes */
-enum ieee80211_reasoncode {
-	WLAN_REASON_UNSPECIFIED = 1,
-	WLAN_REASON_PREV_AUTH_NOT_VALID = 2,
-	WLAN_REASON_DEAUTH_LEAVING = 3,
-	WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY = 4,
-	WLAN_REASON_DISASSOC_AP_BUSY = 5,
-	WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA = 6,
-	WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA = 7,
-	WLAN_REASON_DISASSOC_STA_HAS_LEFT = 8,
-	WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH = 9,
-	/* 802.11h */
-	WLAN_REASON_DISASSOC_BAD_POWER = 10,
-	WLAN_REASON_DISASSOC_BAD_SUPP_CHAN = 11,
-	/* 802.11i */
-	WLAN_REASON_INVALID_IE = 13,
-	WLAN_REASON_MIC_FAILURE = 14,
-	WLAN_REASON_4WAY_HANDSHAKE_TIMEOUT = 15,
-	WLAN_REASON_GROUP_KEY_HANDSHAKE_TIMEOUT = 16,
-	WLAN_REASON_IE_DIFFERENT = 17,
-	WLAN_REASON_INVALID_GROUP_CIPHER = 18,
-	WLAN_REASON_INVALID_PAIRWISE_CIPHER = 19,
-	WLAN_REASON_INVALID_AKMP = 20,
-	WLAN_REASON_UNSUPP_RSN_VERSION = 21,
-	WLAN_REASON_INVALID_RSN_IE_CAP = 22,
-	WLAN_REASON_IEEE8021X_FAILED = 23,
-	WLAN_REASON_CIPHER_SUITE_REJECTED = 24,
-};
-
-
-/* Information Element IDs */
-enum ieee80211_eid {
-	WLAN_EID_SSID = 0,
-	WLAN_EID_SUPP_RATES = 1,
-	WLAN_EID_FH_PARAMS = 2,
-	WLAN_EID_DS_PARAMS = 3,
-	WLAN_EID_CF_PARAMS = 4,
-	WLAN_EID_TIM = 5,
-	WLAN_EID_IBSS_PARAMS = 6,
-	WLAN_EID_CHALLENGE = 16,
-	/* 802.11d */
-	WLAN_EID_COUNTRY = 7,
-	WLAN_EID_HP_PARAMS = 8,
-	WLAN_EID_HP_TABLE = 9,
-	WLAN_EID_REQUEST = 10,
-	/* 802.11h */
-	WLAN_EID_PWR_CONSTRAINT = 32,
-	WLAN_EID_PWR_CAPABILITY = 33,
-	WLAN_EID_TPC_REQUEST = 34,
-	WLAN_EID_TPC_REPORT = 35,
-	WLAN_EID_SUPPORTED_CHANNELS = 36,
-	WLAN_EID_CHANNEL_SWITCH = 37,
-	WLAN_EID_MEASURE_REQUEST = 38,
-	WLAN_EID_MEASURE_REPORT = 39,
-	WLAN_EID_QUIET = 40,
-	WLAN_EID_IBSS_DFS = 41,
-	/* 802.11g */
-	WLAN_EID_ERP_INFO = 42,
-	WLAN_EID_EXT_SUPP_RATES = 50,
-	/* 802.11i */
-	WLAN_EID_RSN = 48,
-	WLAN_EID_WPA = 221,
-	WLAN_EID_GENERIC = 221,
-	WLAN_EID_VENDOR_SPECIFIC = 221,
-	WLAN_EID_QOS_PARAMETER = 222
-};
-
-#endif /* D802_11_MGMT_H */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 4b2eebe..6e6d8bd 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -23,7 +23,6 @@ #include <linux/compiler.h>
 #include <linux/bitmap.h>
 
 #include <net/d80211_common.h>
-#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "wep.h"
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3d5b73c..6b45895 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -12,7 +12,6 @@ #include <linux/if_arp.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
-#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "sta_info.h"
 
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 1643216..6c262e8 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -20,7 +20,6 @@ #include <net/iw_handler.h>
 #include <asm/uaccess.h>
 
 #include <net/d80211.h>
-#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "hostapd_ioctl.h"
 #include "ieee80211_rate.h"
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 3f45110..df7a238 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -26,7 +26,6 @@ #include <asm/types.h>
 #include <asm/delay.h>
 
 #include <net/d80211.h>
-#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "hostapd_ioctl.h"
-- 
1.3.0

