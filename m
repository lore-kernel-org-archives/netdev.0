From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: RFC: Linux wireless extensions and WPA support
Date: Sun, 6 Jun 2004 19:34:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607023455.GA10424@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I started working on WPA extension for the Linux wireless extensions
based on our earlier discussion. This patch file for V16 shows my
current work version. It is not yet ready to be merged into any tree and
is here mainly to allow review of the changes and generate some
discussion (and well, to describe the changes without me having to write
a long email doing that ;-).

This has not yet been tested, but I'm starting to add support for it
into the wireless-2.6 version of Host AP driver and wpa_supplicant. I'll
make an updated patch available once everything seems to be working.

To avoid using much more ioctl numbers, I extended the previously
defined SIOCSIWENCODE/SIOCGIWENCODE and SIOCSIWSCAN instead of defining
new ioctls. Similarily, SIOCSIWAUTH/SIOCGIWAUTH uses one pair of ioctls
to allow configuring multiple (4096) different parameters.

supported_features bit field in struct iw_range will be used by the WPA
Supplicant to determine which modes can be used with the current driver.

Comments are very much welcome, especially from other authors of
wireless device driver. I went through the wpa_supplicant driver
interface and tried to include everything needed here. However, I did
not yet verify whether some of the existing driver interfaces would
benefit from additional fields in wireless extensions.


===== include/linux/wireless.h 1.9 vs edited =====
--- 1.9/include/linux/wireless.h	Fri Apr 16 13:56:10 2004
+++ edited/include/linux/wireless.h	Sun Jun  6 19:11:03 2004
@@ -1,7 +1,7 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	16	2.4.03
+ * Version :	17	6.6.04
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
  * Copyright (c) 1997-2002 Jean Tourrilhes, All Rights Reserved.
@@ -82,7 +82,7 @@
  * (there is some stuff that will be added in the future...)
  * I just plan to increment with each new version.
  */
-#define WIRELESS_EXT	16
+#define WIRELESS_EXT	17
 
 /*
  * Changes :
@@ -175,6 +175,20 @@
  *	- Remove IW_MAX_GET_SPY because conflict with enhanced spy support
  *	- Add SIOCSIWTHRSPY/SIOCGIWTHRSPY and "struct iw_thrspy"
  *	- Add IW_ENCODE_TEMP and iw_range->encoding_login_index
+ *
+ * V16 to V17
+ * ----------
+ *	- Add support for WPA/WPA2
+ *	- Add extended encoding configuration (IW_ENCODE_EXTENDED flag for
+ *	  SIOCSIWENCODE and SIOCGIWENCODE)
+ *	- Larger IW_ENCODING_TOKEN_MAX (32 -> 256)
+ *	- Add SIOCSIWGENIE/SIOCGIWGENIE
+ *	- Add SIOCSIWMLME
+ *	- Add struct iw_range bit field for listing supported driver features
+ *	- Add optional parameter structure for SIOCSIWSCAN
+ *	- Add SIOCSIWAUTH/SIOCGIWAUTH for setting authentication and WPA
+ *	  related parameters (extensible up to 4096 parameter values)
+ *	- Add wireless events: IWEVPAIE, IWEVRSNIE, IWEVMICHAELMICFAILURE
  */
 
 /**************************** CONSTANTS ****************************/
@@ -249,6 +263,17 @@
 #define SIOCSIWPOWER	0x8B2C		/* set Power Management settings */
 #define SIOCGIWPOWER	0x8B2D		/* get Power Management settings */
 
+/* Generic IEEE 802.11 informatiom element (e.g., for WPA/RSN/WME) */
+#define SIOCSIWGENIE	0x8B2E		/* set generic IE */
+#define SIOCGIWGENIE	0x8B2F		/* get generic IE */
+
+/* IEEE 802.11 MLME requests */
+#define SIOCSIWMLME	0x8B30		/* request MLME operation */
+
+/* Authentication mode parameters */
+#define SIOCSIWAUTH	0x8B31		/* set authentication mode params */
+#define SIOCGIWAUTH	0x8B32		/* get authentication mode params */
+
 /* -------------------- DEV PRIVATE IOCTL LIST -------------------- */
 
 /* These 16 ioctl are wireless device private.
@@ -290,6 +315,11 @@
 #define IWEVCUSTOM	0x8C02		/* Driver specific ascii string */
 #define IWEVREGISTERED	0x8C03		/* Discovered a new node (AP mode) */
 #define IWEVEXPIRED	0x8C04		/* Expired a node (AP mode) */
+#define IWEVWPAIE	0x8C05		/* WPA IE (scan results) */
+#define IWEVRSNIE	0x8C06		/* RSN IE (WPA2) (scan results) */
+#define IWEVMICHAELMICFAILURE 0x8C07	/* Michael MIC failure
+					 * (struct iw_michaelmicfailure)
+					 */
 
 #define IWEVFIRST	0x8C00
 
@@ -357,7 +387,7 @@
 #define IW_MAX_ENCODING_SIZES	8
 
 /* Maximum size of the encoding token in bytes */
-#define IW_ENCODING_TOKEN_MAX	32	/* 256 bits (for now) */
+#define IW_ENCODING_TOKEN_MAX	256
 
 /* Flags for encoding (along with the token) */
 #define IW_ENCODE_INDEX		0x00FF	/* Token index (if needed) */
@@ -369,6 +399,36 @@
 #define IW_ENCODE_OPEN		0x2000	/* Accept non-encoded packets */
 #define IW_ENCODE_NOKEY		0x0800  /* Key is write only, so not present */
 #define IW_ENCODE_TEMP		0x0400  /* Temporary key */
+#define IW_ENCODE_EXTENDED	0x0200  /* Use extended data structure
+					 * (struct iw_encode_ext) for
+					 * encoding parameters */
+
+#define IW_ENCODE_SEQ_MAX_SIZE	8
+
+#define IW_ENCODE_ALG_NONE	0
+#define IW_ENCODE_ALG_WEP	1
+#define IW_ENCODE_ALG_TKIP	2
+#define IW_ENCODE_ALG_CCMP	3
+
+/* IW_AUTH_WPA_VERSION values */
+#define IW_AUTH_VERSION_WPA_DISABLED 0
+#define IW_AUTH_VERSION_WPA	1
+#define IW_AUTH_VERSION_WPA2	2
+
+/* IW_AUTH_PAIRWISE_CIPHER and IW_AUTH_GROUP_CIPHER values */
+#define IW_CIPHER_NONE		0
+#define IW_CIPHER_WEP40		1
+#define IW_CIPHER_TKIP		2
+#define IW_CIPHER_CCMP		4
+#define IW_CIPHER_WEP104	5
+
+/* IW_AUTH_KEY_MGMT values */
+#define IW_KEY_MGMT_802_1X	1
+#define IW_KEY_MGMT_PSK		2
+
+/* IW_AUTH_80211_AUTH_ALG values (bit field) */
+#define IW_AUTH_ALG_OPEN_SYSTEM	0x00000001
+#define IW_AUTH_ALG_SHARED_KEY	0x00000002
 
 /* Power management flags available (along with the value, if any) */
 #define IW_POWER_ON		0x0000	/* No details... */
@@ -418,6 +478,32 @@
 /* Max number of char in custom event - use multiple of them if needed */
 #define IW_CUSTOM_MAX		256	/* In bytes */
 
+/* Generic information element */
+#define IW_GENERIC_IE_MAX	256
+
+/* MLME requests */
+#define IW_MLME_DEAUTH		0
+#define IW_MLME_DISASSOC	1
+
+/* Bit field values for supported_features in struct iw_range */
+#define IW_FEATURE_WPA		0x00000001
+#define IW_FEATURE_WPA2		0x00000002
+#define IW_FEATURE_CIPHER_TKIP	0x00000004
+#define IW_FEATURE_CIPHER_CCMP	0x00000008
+
+/* SIOCSIWAUTH/SIOCGIWAUTH flags */
+#define IW_AUTH_INDEX		0x0FFF
+#define IW_AUTH_FLAGS		0xF000
+/* SIOCSIWAUTH/SIOCGIWAUTH parameters (0 .. 4095) */
+#define IW_AUTH_WPA_VERSION	0
+#define IW_AUTH_PAIRWISE_CIPHER	1
+#define IW_AUTH_GROUP_CIPHER	2
+#define IW_AUTH_KEY_MGMT	3
+#define IW_AUTH_TKIP_COUNTERMEASURES	4
+#define IW_AUTH_DROP_UNENCRYPTED	5
+#define IW_AUTH_80211_AUTH_ALG	6
+
+
 /****************************** TYPES ******************************/
 
 /* --------------------------- SUBTYPES --------------------------- */
@@ -507,6 +593,59 @@
 	struct iw_quality	high;		/* High threshold */
 };
 
+/*
+ *	Optional data for scan request
+ */
+struct	iw_scan_req
+{
+	/* Use this SSID if IW_SCAN_THIS_ESSID flag is used instead of using
+	 * the current SSID. This allows scan requests for specific SSID
+	 * without having to change the current SSID and potentially breaking
+	 * the current association. */
+	__u8		ssid_len;
+	__u8		ssid[IW_ESSID_MAX_SIZE];
+};
+
+/*
+ *	Extended data structure for get/set encoding (this is used if
+ *	IW_ENCODE_EXTENDED flag is set).
+ */
+struct	iw_encode_ext
+{
+#define IW_ENCODE_EXT_TX_SEQ_VALID	0x00000001
+#define IW_ENCODE_EXT_RX_SEQ_VALID	0x00000002
+#define IW_ENCODE_EXT_GROUP_KEY		0x00000004
+	__u32		ext_flags;
+	__u8		tx_seq[IW_ENCODE_SEQ_MAX_SIZE]; /* LSB first */
+	__u8		rx_seq[IW_ENCODE_SEQ_MAX_SIZE]; /* LSB first */
+	__u16		alg; /* IW_ENCODE_ALG_* */
+	struct sockaddr	addr; /* ff:ff:ff:ff:ff:ff for broadcast/multicast
+			       * (group) keys or unicast address for
+			       * individual keys */
+	__u16		key_len;
+	__u8		key[0];
+};
+
+struct	iw_mlme
+{
+	__u16		cmd; /* IW_MLME_* */
+	__u16		reason_code;
+	struct sockaddr	addr;
+};
+
+struct	iw_michaelmicfailure
+{
+#define IW_MICFAILURE_KEY_ID	0x00000003 /* Key ID 0..3 */
+#define IW_MICFAILURE_GROUP	0x00000004
+#define IW_MICFAILURE_PAIRWISE	0x00000008
+#define IW_MICFAILURE_STAKEY	0x00000010
+#define IW_MICFAILURE_COUNT	0x00000060 /* 1 or 2 (0 = count not supported)
+					    */
+	__u32		flags;
+	struct sockaddr	src_addr;
+	__u8		tsc[IW_ENCODE_SEQ_MAX_SIZE]; /* LSB first */
+};
+
 /* ------------------------ WIRELESS STATS ------------------------ */
 /*
  * Wireless statistics (used for /proc/net/wireless)
@@ -685,6 +824,8 @@
 	struct iw_freq	freq[IW_MAX_FREQUENCIES];	/* list */
 	/* Note : this frequency list doesn't need to fit channel numbers,
 	 * because each entry contain its channel index */
+
+	__u32		supported_features; /* IW_FEATURE_* bit field */
 };
 
 /*
===== net/core/wireless.c 1.15 vs edited =====
--- 1.15/net/core/wireless.c	Sun Sep 28 15:29:53 2003
+++ edited/net/core/wireless.c	Sun Jun  6 18:43:31 2004
@@ -189,6 +189,8 @@
 	},
 	[SIOCSIWSCAN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
+		.token_size	= sizeof(struct iw_scan_req),
+		.max_tokens	= 1,
 	},
 	[SIOCGIWSCAN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
@@ -263,6 +265,27 @@
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
 	[SIOCGIWPOWER	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_PARAM,
+	},
+	[SIOCSIWGENIE	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_POINT,
+		.token_size	= 1,
+		.max_tokens	= IW_GENERIC_IE_MAX,
+	},
+	[SIOCGIWGENIE	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_POINT,
+		.token_size	= 1,
+		.max_tokens	= IW_GENERIC_IE_MAX,
+	},
+	[SIOCSIWMLME	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_POINT,
+		.token_size	= sizeof(struct iw_mlme),
+		.max_tokens	= 1,
+	},
+	[SIOCSIWAUTH	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_PARAM,
+	},
+	[SIOCGIWAUTH	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
 };

-- 
Jouni Malinen                                            PGP id EFC895FA
