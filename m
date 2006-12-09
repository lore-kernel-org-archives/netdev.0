From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 3/4] d80211: merge d80211_mgmt.h into linux/ieee80211.h
Date: Sat, 9 Dec 2006 03:21:27 -0500
Message-ID: <200612090321.31652.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4257809.VzfBpMRsqc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:59289 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936120AbWLII3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 03:29:50 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4257809.VzfBpMRsqc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: merge d80211_mgmt.h into linux/ieee80211.h

This merges d80211_mgmt.h with linux/ieee80211.h, to keep all the general
802.11 definitions in one place.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h |    1=20
 include/linux/ieee80211.h                     |  208 +++++++++++++++++++++=
++
 include/net/d80211_mgmt.h                     |  223 ---------------------=
=2D---
 net/d80211/ieee80211.c                        |    1=20
 net/d80211/ieee80211_iface.c                  |    1=20
 net/d80211/ieee80211_ioctl.c                  |    1=20
 net/d80211/ieee80211_sta.c                    |    1=20
 7 files changed, 208 insertions(+), 228 deletions(-)

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wi=
reless/d80211/bcm43xx/bcm43xx.h
index 2a18875..a607857 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -14,7 +14,6 @@
 #include <linux/ssb.h>
 #include <linux/wireless.h>
 #include <net/d80211.h>
=2D#include <net/d80211_mgmt.h>
 #include <net/d80211_common.h>
=20
 #include "bcm43xx_debugfs.h"
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index c7503eb..817001c 100644
=2D-- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -104,4 +104,212 @@ struct ieee80211_hdr {
 	__u8 addr4[6];
 } __attribute__ ((packed));
=20
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
+	WLAN_STATUS_SUCCESS =3D 0,
+	WLAN_STATUS_UNSPECIFIED_FAILURE =3D 1,
+	WLAN_STATUS_CAPS_UNSUPPORTED =3D 10,
+	WLAN_STATUS_REASSOC_NO_ASSOC =3D 11,
+	WLAN_STATUS_ASSOC_DENIED_UNSPEC =3D 12,
+	WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG =3D 13,
+	WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION =3D 14,
+	WLAN_STATUS_CHALLENGE_FAIL =3D 15,
+	WLAN_STATUS_AUTH_TIMEOUT =3D 16,
+	WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA =3D 17,
+	WLAN_STATUS_ASSOC_DENIED_RATES =3D 18,
+	/* 802.11b */
+	WLAN_STATUS_ASSOC_DENIED_NOSHORTPREAMBLE =3D 19,
+	WLAN_STATUS_ASSOC_DENIED_NOPBCC =3D 20,
+	WLAN_STATUS_ASSOC_DENIED_NOAGILITY =3D 21,
+	/* 802.11h */
+	WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM =3D 22,
+	WLAN_STATUS_ASSOC_REJECTED_BAD_POWER =3D 23,
+	WLAN_STATUS_ASSOC_REJECTED_BAD_SUPP_CHAN =3D 24,
+	/* 802.11g */
+	WLAN_STATUS_ASSOC_DENIED_NOSHORTTIME =3D 25,
+	WLAN_STATUS_ASSOC_DENIED_NODSSSOFDM =3D 26,
+	/* 802.11i */
+	WLAN_STATUS_INVALID_IE =3D 40,
+	WLAN_STATUS_INVALID_GROUP_CIPHER =3D 41,
+	WLAN_STATUS_INVALID_PAIRWISE_CIPHER =3D 42,
+	WLAN_STATUS_INVALID_AKMP =3D 43,
+	WLAN_STATUS_UNSUPP_RSN_VERSION =3D 44,
+	WLAN_STATUS_INVALID_RSN_IE_CAP =3D 45,
+	WLAN_STATUS_CIPHER_SUITE_REJECTED =3D 46,
+};
+
+
+/* Reason codes */
+enum ieee80211_reasoncode {
+	WLAN_REASON_UNSPECIFIED =3D 1,
+	WLAN_REASON_PREV_AUTH_NOT_VALID =3D 2,
+	WLAN_REASON_DEAUTH_LEAVING =3D 3,
+	WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY =3D 4,
+	WLAN_REASON_DISASSOC_AP_BUSY =3D 5,
+	WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA =3D 6,
+	WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA =3D 7,
+	WLAN_REASON_DISASSOC_STA_HAS_LEFT =3D 8,
+	WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH =3D 9,
+	/* 802.11h */
+	WLAN_REASON_DISASSOC_BAD_POWER =3D 10,
+	WLAN_REASON_DISASSOC_BAD_SUPP_CHAN =3D 11,
+	/* 802.11i */
+	WLAN_REASON_INVALID_IE =3D 13,
+	WLAN_REASON_MIC_FAILURE =3D 14,
+	WLAN_REASON_4WAY_HANDSHAKE_TIMEOUT =3D 15,
+	WLAN_REASON_GROUP_KEY_HANDSHAKE_TIMEOUT =3D 16,
+	WLAN_REASON_IE_DIFFERENT =3D 17,
+	WLAN_REASON_INVALID_GROUP_CIPHER =3D 18,
+	WLAN_REASON_INVALID_PAIRWISE_CIPHER =3D 19,
+	WLAN_REASON_INVALID_AKMP =3D 20,
+	WLAN_REASON_UNSUPP_RSN_VERSION =3D 21,
+	WLAN_REASON_INVALID_RSN_IE_CAP =3D 22,
+	WLAN_REASON_IEEE8021X_FAILED =3D 23,
+	WLAN_REASON_CIPHER_SUITE_REJECTED =3D 24,
+};
+
+
+/* Information Element IDs */
+enum ieee80211_eid {
+	WLAN_EID_SSID =3D 0,
+	WLAN_EID_SUPP_RATES =3D 1,
+	WLAN_EID_FH_PARAMS =3D 2,
+	WLAN_EID_DS_PARAMS =3D 3,
+	WLAN_EID_CF_PARAMS =3D 4,
+	WLAN_EID_TIM =3D 5,
+	WLAN_EID_IBSS_PARAMS =3D 6,
+	WLAN_EID_CHALLENGE =3D 16,
+	/* 802.11d */
+	WLAN_EID_COUNTRY =3D 7,
+	WLAN_EID_HP_PARAMS =3D 8,
+	WLAN_EID_HP_TABLE =3D 9,
+	WLAN_EID_REQUEST =3D 10,
+	/* 802.11h */
+	WLAN_EID_PWR_CONSTRAINT =3D 32,
+	WLAN_EID_PWR_CAPABILITY =3D 33,
+	WLAN_EID_TPC_REQUEST =3D 34,
+	WLAN_EID_TPC_REPORT =3D 35,
+	WLAN_EID_SUPPORTED_CHANNELS =3D 36,
+	WLAN_EID_CHANNEL_SWITCH =3D 37,
+	WLAN_EID_MEASURE_REQUEST =3D 38,
+	WLAN_EID_MEASURE_REPORT =3D 39,
+	WLAN_EID_QUIET =3D 40,
+	WLAN_EID_IBSS_DFS =3D 41,
+	/* 802.11g */
+	WLAN_EID_ERP_INFO =3D 42,
+	WLAN_EID_EXT_SUPP_RATES =3D 50,
+	/* 802.11i */
+	WLAN_EID_RSN =3D 48,
+	WLAN_EID_WPA =3D 221,
+	WLAN_EID_GENERIC =3D 221,
+	WLAN_EID_VENDOR_SPECIFIC =3D 221,
+	WLAN_EID_QOS_PARAMETER =3D 222
+};
+
 #endif /* IEEE80211_H */
diff --git a/include/net/d80211_mgmt.h b/include/net/d80211_mgmt.h
deleted file mode 100644
index 87141d4..0000000
=2D-- a/include/net/d80211_mgmt.h
+++ /dev/null
@@ -1,223 +0,0 @@
=2D/*
=2D * IEEE 802.11 -- shared defines for 80211.o and hostapd
=2D * Copyright 2002, Jouni Malinen <jkmaline@cc.hut.fi>
=2D * Copyright 2002-2004, Instant802 Networks, Inc.
=2D * Copyright 2005, Devicescape Software, Inc.
=2D *
=2D * This program is free software; you can redistribute it and/or modify
=2D * it under the terms of the GNU General Public License version 2 as
=2D * published by the Free Software Foundation.
=2D */
=2D
=2D#ifndef D802_11_MGMT_H
=2D#define D802_11_MGMT_H
=2D
=2D#include <linux/types.h>
=2D
=2Dstruct ieee80211_mgmt {
=2D	__le16 frame_control;
=2D	__le16 duration;
=2D	u8 da[6];
=2D	u8 sa[6];
=2D	u8 bssid[6];
=2D	__le16 seq_ctrl;
=2D	union {
=2D		struct {
=2D			__le16 auth_alg;
=2D			__le16 auth_transaction;
=2D			__le16 status_code;
=2D			/* possibly followed by Challenge text */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) auth;
=2D		struct {
=2D			__le16 reason_code;
=2D		} __attribute__ ((packed)) deauth;
=2D		struct {
=2D			__le16 capab_info;
=2D			__le16 listen_interval;
=2D			/* followed by SSID and Supported rates */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) assoc_req;
=2D		struct {
=2D			__le16 capab_info;
=2D			__le16 status_code;
=2D			__le16 aid;
=2D			/* followed by Supported rates */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) assoc_resp, reassoc_resp;
=2D		struct {
=2D			__le16 capab_info;
=2D			__le16 listen_interval;
=2D			u8 current_ap[6];
=2D			/* followed by SSID and Supported rates */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) reassoc_req;
=2D		struct {
=2D			__le16 reason_code;
=2D		} __attribute__ ((packed)) disassoc;
=2D		struct {
=2D			__le64 timestamp;
=2D			__le16 beacon_int;
=2D			__le16 capab_info;
=2D			/* followed by some of SSID, Supported rates,
=2D			 * FH Params, DS Params, CF Params, IBSS Params, TIM */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) beacon;
=2D		struct {
=2D			/* only variable items: SSID, Supported rates */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) probe_req;
=2D		struct {
=2D			__le64 timestamp;
=2D			__le16 beacon_int;
=2D			__le16 capab_info;
=2D			/* followed by some of SSID, Supported rates,
=2D			 * FH Params, DS Params, CF Params, IBSS Params */
=2D			u8 variable[0];
=2D		} __attribute__ ((packed)) probe_resp;
=2D		struct {
=2D			u8 category;
=2D			union {
=2D				struct {
=2D					u8 action_code;
=2D					u8 dialog_token;
=2D					u8 status_code;
=2D					u8 variable[0];
=2D				} __attribute__ ((packed)) wme_action;
=2D				struct{
=2D					u8 action_code;
=2D					u8 element_id;
=2D					u8 length;
=2D					u8 switch_mode;
=2D					u8 new_chan;
=2D					u8 switch_count;
=2D				} __attribute__((packed)) chan_switch;
=2D			} u;
=2D		} __attribute__ ((packed)) action;
=2D	} u;
=2D} __attribute__ ((packed));
=2D
=2D
=2D/* Authentication algorithms */
=2D#define WLAN_AUTH_OPEN 0
=2D#define WLAN_AUTH_SHARED_KEY 1
=2D#define WLAN_AUTH_LEAP 128
=2D
=2D#define WLAN_AUTH_CHALLENGE_LEN 128
=2D
=2D#define WLAN_CAPABILITY_ESS BIT(0)
=2D#define WLAN_CAPABILITY_IBSS BIT(1)
=2D#define WLAN_CAPABILITY_CF_POLLABLE BIT(2)
=2D#define WLAN_CAPABILITY_CF_POLL_REQUEST BIT(3)
=2D#define WLAN_CAPABILITY_PRIVACY BIT(4)
=2D#define WLAN_CAPABILITY_SHORT_PREAMBLE BIT(5)
=2D#define WLAN_CAPABILITY_PBCC BIT(6)
=2D#define WLAN_CAPABILITY_CHANNEL_AGILITY BIT(7)
=2D/* 802.11h */
=2D#define WLAN_CAPABILITY_SPECTRUM_MGMT BIT(8)
=2D#define WLAN_CAPABILITY_SHORT_SLOT_TIME BIT(10)
=2D#define WLAN_CAPABILITY_DSSS_OFDM BIT(13)
=2D
=2D/* Status codes */
=2Denum ieee80211_statuscode {
=2D	WLAN_STATUS_SUCCESS =3D 0,
=2D	WLAN_STATUS_UNSPECIFIED_FAILURE =3D 1,
=2D	WLAN_STATUS_CAPS_UNSUPPORTED =3D 10,
=2D	WLAN_STATUS_REASSOC_NO_ASSOC =3D 11,
=2D	WLAN_STATUS_ASSOC_DENIED_UNSPEC =3D 12,
=2D	WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG =3D 13,
=2D	WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION =3D 14,
=2D	WLAN_STATUS_CHALLENGE_FAIL =3D 15,
=2D	WLAN_STATUS_AUTH_TIMEOUT =3D 16,
=2D	WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA =3D 17,
=2D	WLAN_STATUS_ASSOC_DENIED_RATES =3D 18,
=2D	/* 802.11b */
=2D	WLAN_STATUS_ASSOC_DENIED_NOSHORTPREAMBLE =3D 19,
=2D	WLAN_STATUS_ASSOC_DENIED_NOPBCC =3D 20,
=2D	WLAN_STATUS_ASSOC_DENIED_NOAGILITY =3D 21,
=2D	/* 802.11h */
=2D	WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM =3D 22,
=2D	WLAN_STATUS_ASSOC_REJECTED_BAD_POWER =3D 23,
=2D	WLAN_STATUS_ASSOC_REJECTED_BAD_SUPP_CHAN =3D 24,
=2D	/* 802.11g */
=2D	WLAN_STATUS_ASSOC_DENIED_NOSHORTTIME =3D 25,
=2D	WLAN_STATUS_ASSOC_DENIED_NODSSSOFDM =3D 26,
=2D	/* 802.11i */
=2D	WLAN_STATUS_INVALID_IE =3D 40,
=2D	WLAN_STATUS_INVALID_GROUP_CIPHER =3D 41,
=2D	WLAN_STATUS_INVALID_PAIRWISE_CIPHER =3D 42,
=2D	WLAN_STATUS_INVALID_AKMP =3D 43,
=2D	WLAN_STATUS_UNSUPP_RSN_VERSION =3D 44,
=2D	WLAN_STATUS_INVALID_RSN_IE_CAP =3D 45,
=2D	WLAN_STATUS_CIPHER_SUITE_REJECTED =3D 46,
=2D};
=2D
=2D
=2D/* Reason codes */
=2Denum ieee80211_reasoncode {
=2D	WLAN_REASON_UNSPECIFIED =3D 1,
=2D	WLAN_REASON_PREV_AUTH_NOT_VALID =3D 2,
=2D	WLAN_REASON_DEAUTH_LEAVING =3D 3,
=2D	WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY =3D 4,
=2D	WLAN_REASON_DISASSOC_AP_BUSY =3D 5,
=2D	WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA =3D 6,
=2D	WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA =3D 7,
=2D	WLAN_REASON_DISASSOC_STA_HAS_LEFT =3D 8,
=2D	WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH =3D 9,
=2D	/* 802.11h */
=2D	WLAN_REASON_DISASSOC_BAD_POWER =3D 10,
=2D	WLAN_REASON_DISASSOC_BAD_SUPP_CHAN =3D 11,
=2D	/* 802.11i */
=2D	WLAN_REASON_INVALID_IE =3D 13,
=2D	WLAN_REASON_MIC_FAILURE =3D 14,
=2D	WLAN_REASON_4WAY_HANDSHAKE_TIMEOUT =3D 15,
=2D	WLAN_REASON_GROUP_KEY_HANDSHAKE_TIMEOUT =3D 16,
=2D	WLAN_REASON_IE_DIFFERENT =3D 17,
=2D	WLAN_REASON_INVALID_GROUP_CIPHER =3D 18,
=2D	WLAN_REASON_INVALID_PAIRWISE_CIPHER =3D 19,
=2D	WLAN_REASON_INVALID_AKMP =3D 20,
=2D	WLAN_REASON_UNSUPP_RSN_VERSION =3D 21,
=2D	WLAN_REASON_INVALID_RSN_IE_CAP =3D 22,
=2D	WLAN_REASON_IEEE8021X_FAILED =3D 23,
=2D	WLAN_REASON_CIPHER_SUITE_REJECTED =3D 24,
=2D};
=2D
=2D
=2D/* Information Element IDs */
=2Denum ieee80211_eid {
=2D	WLAN_EID_SSID =3D 0,
=2D	WLAN_EID_SUPP_RATES =3D 1,
=2D	WLAN_EID_FH_PARAMS =3D 2,
=2D	WLAN_EID_DS_PARAMS =3D 3,
=2D	WLAN_EID_CF_PARAMS =3D 4,
=2D	WLAN_EID_TIM =3D 5,
=2D	WLAN_EID_IBSS_PARAMS =3D 6,
=2D	WLAN_EID_CHALLENGE =3D 16,
=2D	/* 802.11d */
=2D	WLAN_EID_COUNTRY =3D 7,
=2D	WLAN_EID_HP_PARAMS =3D 8,
=2D	WLAN_EID_HP_TABLE =3D 9,
=2D	WLAN_EID_REQUEST =3D 10,
=2D	/* 802.11h */
=2D	WLAN_EID_PWR_CONSTRAINT =3D 32,
=2D	WLAN_EID_PWR_CAPABILITY =3D 33,
=2D	WLAN_EID_TPC_REQUEST =3D 34,
=2D	WLAN_EID_TPC_REPORT =3D 35,
=2D	WLAN_EID_SUPPORTED_CHANNELS =3D 36,
=2D	WLAN_EID_CHANNEL_SWITCH =3D 37,
=2D	WLAN_EID_MEASURE_REQUEST =3D 38,
=2D	WLAN_EID_MEASURE_REPORT =3D 39,
=2D	WLAN_EID_QUIET =3D 40,
=2D	WLAN_EID_IBSS_DFS =3D 41,
=2D	/* 802.11g */
=2D	WLAN_EID_ERP_INFO =3D 42,
=2D	WLAN_EID_EXT_SUPP_RATES =3D 50,
=2D	/* 802.11i */
=2D	WLAN_EID_RSN =3D 48,
=2D	WLAN_EID_WPA =3D 221,
=2D	WLAN_EID_GENERIC =3D 221,
=2D	WLAN_EID_VENDOR_SPECIFIC =3D 221,
=2D	WLAN_EID_QOS_PARAMETER =3D 222
=2D};
=2D
=2D#endif /* D802_11_MGMT_H */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ec62c6e..d07d927 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -23,7 +23,6 @@
 #include <linux/bitmap.h>
=20
 #include <net/d80211_common.h>
=2D#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "wep.h"
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3e9d531..6d7222b 100644
=2D-- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -12,7 +12,6 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
=2D#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "sta_info.h"
=20
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index c74b431..fdd669c 100644
=2D-- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -20,7 +20,6 @@
 #include <asm/uaccess.h>
=20
 #include <net/d80211.h>
=2D#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "hostapd_ioctl.h"
 #include "ieee80211_rate.h"
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 7594022..5196f67 100644
=2D-- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -26,7 +26,6 @@
 #include <asm/delay.h>
=20
 #include <net/d80211.h>
=2D#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "hostapd_ioctl.h"

--nextPart4257809.VzfBpMRsqc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFenILT3Oqt9AH4aERAhqoAJ0VBdoqe5M/DJvj69YI+Ll48WVy9QCgnHyR
sgF7PnBpMbnvhV6RHpe22Ho=
=54da
-----END PGP SIGNATURE-----

--nextPart4257809.VzfBpMRsqc--
