From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: RFC: Linux wireless extensions and WPA support
Date: Tue, 8 Jun 2004 20:45:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040609034546.GA7347@jm.kir.nu>
References: <20040607023455.GA10424@jm.kir.nu> <20040608002659.GA18087@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20040608002659.GA18087@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 07, 2004 at 05:26:59PM -0700, Jean Tourrilhes wrote:

> 	Actually, I don't like the extension of SIOC*IWENCODE. This
> ioctl is already messy/complex enough as it is, and I think we would
> benefit greatly in separating the two code paths, therefore using a
> new iotcl for it. It's not like we are short of ioctls.

OK.

> 	The extension of SIOCSIWSCAN was always something desired, but
> I never got sure of which way it was supposed to be done (look at the
> unused IW_SCAN_* flags in wireless.h).
> 	Do you think that ESSID is the only request filter that is
> worthwhile ? Another option would be to allow an "iwevent" structure
> allow to specify any kind of filter.

Yes, there are other parameters that may be useful at some point.
Actually, IEEE 802.11 specifies this list as parameters to
MLME-SCAN.request and I changed struct iw_scan_req to include all the
parameters. I would assume many drivers would not include some of the
timing values, but at least this should cover all cases mentioned in the
standard.

> 	It took me a while to understand how this one is supposed to
> works (which means that it may need better documentation). It's a
> sub-ioctl kind of thing, right ? The SET accept two 32 bit integers,
> the GET accept one and return one.

sub-ioctl kind, but in that way.. I agree on the lack of documentation
part.

> 	You current definition doesn't work, because you are using
> IW_HEADER_TYPE_PARAM that carry only a single 32bit integer. There are
> two solutions. The first is fit the IW_AUTH_INDEX in the 16 bits of
> iw_param->flags. The second is to use IW_HEADER_TYPE_UINT.

struct iw_param has 16-bit flags field and my definition was trying to
make it clear that that was indeed used for the IW_AUTH_* index numbers.
In other words, I was using the first solution you list here. I added
some more explicit text to make this clear.

> 	Also, all the constant used for this command should have the
> IW_AUTH_* prefix (IW_CIPHER_NONE => IW_AUTH_CIPHER_NONE), so that we
> can see clearly that they apply to this command. I would even go
> futher and have common prefixes between request and values :

OK.

> 	I think that "supported_feature" is too generic a name for
> what you are using it now. As there are other "supported_feature" type
> of fields in iw_range (pm_capa, txpower_capa, retry_capa), I would
> suggest to use a more descriptive name, such as "enc_features" or
> "enc_capa".

My bad.. I didn't look at existing fields in struct iw_range and I
didn't even remember that I have actually used those before ;-). Changed
to enc_capa to match with existing fields.

> > +/* IEEE 802.11 MLME requests */
> > +#define SIOCSIWMLME	0x8B30		/* request MLME operation */
> 
> 	I don't see a struct for it, so I assume the format of that is
> defined somewhere in the 802.11 spec ? May be worth documenting where
> to look for it.

struct iw_mlme (and yes, it is based on IEEE 802.11, but does not
include all parameters for all possible MLME requests).

> 	I hope I did not sound too "picky", but I hope that my
> suggestion are not too difficult to implement while adding some
> value. Tell me what you think ;-)

Thanks for all comments. That was not at all picky; I think I agreed
with everything. Here's an updated version of the patch (again, not yet
tested, so not ready to be applied). Please let me know if I missed
something.


===== include/linux/wireless.h 1.9 vs edited =====
--- 1.9/include/linux/wireless.h	Fri Apr 16 13:56:10 2004
+++ edited/include/linux/wireless.h	Tue Jun  8 20:43:09 2004
@@ -1,7 +1,7 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	16	2.4.03
+ * Version :	17	6.8.04
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
@@ -175,6 +175,19 @@
  *	- Remove IW_MAX_GET_SPY because conflict with enhanced spy support
  *	- Add SIOCSIWTHRSPY/SIOCGIWTHRSPY and "struct iw_thrspy"
  *	- Add IW_ENCODE_TEMP and iw_range->encoding_login_index
+ *
+ * V16 to V17
+ * ----------
+ *	- Add support for WPA/WPA2
+ *	- Add extended encoding configuration (SIOCSIWENCODEEXT and
+ *	  SIOCGIWENCODEEXT)
+ *	- Add SIOCSIWGENIE/SIOCGIWGENIE
+ *	- Add SIOCSIWMLME
+ *	- Add struct iw_range bit field for supported encoding capabilities
+ *	- Add optional parameter structure for SIOCSIWSCAN
+ *	- Add SIOCSIWAUTH/SIOCGIWAUTH for setting authentication and WPA
+ *	  related parameters (extensible up to 4096 parameter values)
+ *	- Add wireless events: IWEVWPAIE, IWEVRSNIE, IWEVMICHAELMICFAILURE
  */
 
 /**************************** CONSTANTS ****************************/
@@ -249,6 +262,22 @@
 #define SIOCSIWPOWER	0x8B2C		/* set Power Management settings */
 #define SIOCGIWPOWER	0x8B2D		/* get Power Management settings */
 
+/* Generic IEEE 802.11 informatiom element (e.g., for WPA/RSN/WME) */
+#define SIOCSIWGENIE	0x8B2E		/* set generic IE */
+#define SIOCGIWGENIE	0x8B2F		/* get generic IE */
+
+/* IEEE 802.11 MLME requests */
+#define SIOCSIWMLME	0x8B30		/* request MLME operation; uses
+					 * struct iw_scan_req */
+
+/* Authentication mode parameters */
+#define SIOCSIWAUTH	0x8B31		/* set authentication mode params */
+#define SIOCGIWAUTH	0x8B32		/* get authentication mode params */
+
+/* Extended version of encoding configuration */
+#define SIOCSIWENCODEEXT 0x8B33		/* set encoding token & mode */
+#define SIOCGIWENCODEEXT 0x8B34		/* get encoding token & mode */
+
 /* -------------------- DEV PRIVATE IOCTL LIST -------------------- */
 
 /* These 16 ioctl are wireless device private.
@@ -290,6 +319,11 @@
 #define IWEVCUSTOM	0x8C02		/* Driver specific ascii string */
 #define IWEVREGISTERED	0x8C03		/* Discovered a new node (AP mode) */
 #define IWEVEXPIRED	0x8C04		/* Expired a node (AP mode) */
+#define IWEVWPAIE	0x8C05		/* WPA IE (scan results) */
+#define IWEVRSNIE	0x8C06		/* RSN IE (WPA2) (scan results) */
+#define IWEVMICHAELMICFAILURE 0x8C07	/* Michael MIC failure
+					 * (struct iw_michaelmicfailure)
+					 */
 
 #define IWEVFIRST	0x8C00
 
@@ -370,6 +404,33 @@
 #define IW_ENCODE_NOKEY		0x0800  /* Key is write only, so not present */
 #define IW_ENCODE_TEMP		0x0400  /* Temporary key */
 
+#define IW_ENCODE_SEQ_MAX_SIZE	8
+
+#define IW_ENCODE_ALG_NONE	0
+#define IW_ENCODE_ALG_WEP	1
+#define IW_ENCODE_ALG_TKIP	2
+#define IW_ENCODE_ALG_CCMP	3
+
+/* IW_AUTH_WPA_VERSION values */
+#define IW_AUTH_WPA_VERSION_DISABLED	0
+#define IW_AUTH_WPA_VERSION_WPA		1
+#define IW_AUTH_WPA_VERSION_WPA2	2
+
+/* IW_AUTH_PAIRWISE_CIPHER and IW_AUTH_GROUP_CIPHER values */
+#define IW_AUTH_CIPHER_NONE	0
+#define IW_AUTH_CIPHER_WEP40	1
+#define IW_AUTH_CIPHER_TKIP	2
+#define IW_AUTH_CIPHER_CCMP	4
+#define IW_AUTH_CIPHER_WEP104	5
+
+/* IW_AUTH_KEY_MGMT values */
+#define IW_AUTH_KEY_MGMT_802_1X	1
+#define IW_AUTH_KEY_MGMT_PSK	2
+
+/* IW_AUTH_80211_AUTH_ALG values (bit field) */
+#define IW_AUTH_ALG_OPEN_SYSTEM	0x00000001
+#define IW_AUTH_ALG_SHARED_KEY	0x00000002
+
 /* Power management flags available (along with the value, if any) */
 #define IW_POWER_ON		0x0000	/* No details... */
 #define IW_POWER_TYPE		0xF000	/* Type of parameter */
@@ -412,12 +473,46 @@
 #define IW_SCAN_THIS_MODE	0x0020	/* Scan only this Mode */
 #define IW_SCAN_ALL_RATE	0x0040	/* Scan all Bit-Rates */
 #define IW_SCAN_THIS_RATE	0x0080	/* Scan only this Bit-Rate */
+
+/* struct iw_scan_req scan_type */
+#define IW_SCAN_TYPE_ACTIVE 0
+#define IW_SCAN_TYPE_PASSIVE 1
+
 /* Maximum size of returned data */
 #define IW_SCAN_MAX_DATA	4096	/* In bytes */
 
 /* Max number of char in custom event - use multiple of them if needed */
 #define IW_CUSTOM_MAX		256	/* In bytes */
 
+/* Generic information element */
+#define IW_GENERIC_IE_MAX	256
+
+/* MLME requests (SIOCSIWMLME / struct iw_mlme) */
+#define IW_MLME_DEAUTH		0
+#define IW_MLME_DISASSOC	1
+
+/* Bit field values for enc_capa in struct iw_range */
+#define IW_ENC_CAPA_WPA		0x00000001
+#define IW_ENC_CAPA_WPA2	0x00000002
+#define IW_ENC_CAPA_CIPHER_TKIP	0x00000004
+#define IW_ENC_CAPA_CIPHER_CCMP	0x00000008
+
+/* SIOCSIWAUTH/SIOCGIWAUTH struct iw_param flags */
+#define IW_AUTH_INDEX		0x0FFF
+#define IW_AUTH_FLAGS		0xF000
+/* SIOCSIWAUTH/SIOCGIWAUTH parameters (0 .. 4095)
+ * (IW_AUTH_INDEX mask in struct iw_param flags; this is the index of the
+ * parameter that is being set/get to; value will be read/written to
+ * struct iw_param value field) */
+#define IW_AUTH_WPA_VERSION	0
+#define IW_AUTH_CIPHER_PAIRWISE	1
+#define IW_AUTH_CIPHER_GROUP	2
+#define IW_AUTH_KEY_MGMT	3
+#define IW_AUTH_TKIP_COUNTERMEASURES	4
+#define IW_AUTH_DROP_UNENCRYPTED	5
+#define IW_AUTH_80211_AUTH_ALG	6
+
+
 /****************************** TYPES ******************************/
 
 /* --------------------------- SUBTYPES --------------------------- */
@@ -507,6 +602,75 @@
 	struct iw_quality	high;		/* High threshold */
 };
 
+/*
+ *	Optional data for scan request (MLME-SCAN.request)
+ */
+struct	iw_scan_req
+{
+	__u8		bss_type; /* IW_MODE_AUTO (= Both), IW_MODE_ADHOC, or
+				   * IW_MODE_INFRA */
+	__u8		scan_type; /* IW_SCAN_TYPE_{ACTIVE,PASSIVE} */
+	__u8		ssid_len;
+	__u8		num_channels; /* num entries in channel_list;
+				       * 0 = scan all allowed channels */
+	struct sockaddr	bssid; /* ff:ff:ff:ff:ff:ff for broadcast BSSID or
+				* individual address of a specific BSS */
+	/* Use this SSID if IW_SCAN_THIS_ESSID flag is used instead of using
+	 * the current SSID. This allows scan requests for specific SSID
+	 * without having to change the current SSID and potentially breaking
+	 * the current association. */
+	__u8		ssid[IW_ESSID_MAX_SIZE];
+	__u32		probe_delay; /* delay in usec prior to transmitting
+				      * ProbeReq */
+	__u32		min_channel_time; /* in TU, >= probe_delay */
+	__u32		max_channel_time; /* in TU, >= min_channel_time */
+	struct iw_freq	channel_list[IW_MAX_FREQUENCIES];
+};
+
+/*
+ *	Extended data structure for get/set encoding (this is used with
+ *	SIOCSIWENCODEEXT/SIOCGIWENCODEEXT. struct iw_point and IW_ENCODE_*
+ *	flags are used in the same way as with SIOCSIWENCODE/SIOCGIWENCODE and
+ *	only the data contents changes (key data -> this structure, including
+ *	key data).
+ */
+struct	iw_encode_ext
+{
+#define IW_ENCODE_EXT_TX_SEQ_VALID	0x00000001
+#define IW_ENCODE_EXT_RX_SEQ_VALID	0x00000002
+#define IW_ENCODE_EXT_GROUP_KEY		0x00000004
+	__u32		ext_flags;
+	__u8		tx_seq[IW_ENCODE_SEQ_MAX_SIZE]; /* LSB first */
+	__u8		rx_seq[IW_ENCODE_SEQ_MAX_SIZE]; /* LSB first */
+	struct sockaddr	addr; /* ff:ff:ff:ff:ff:ff for broadcast/multicast
+			       * (group) keys or unicast address for
+			       * individual keys */
+	__u16		alg; /* IW_ENCODE_ALG_* */
+	__u16		key_len;
+	__u8		key[0];
+};
+
+/* SIOCSIWMLME data */
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
@@ -685,6 +849,8 @@
 	struct iw_freq	freq[IW_MAX_FREQUENCIES];	/* list */
 	/* Note : this frequency list doesn't need to fit channel numbers,
 	 * because each entry contain its channel index */
+
+	__u32		enc_capa; /* IW_ENC_CAPA_* bit field */
 };
 
 /*
===== net/core/wireless.c 1.15 vs edited =====
--- 1.15/net/core/wireless.c	Sun Sep 28 15:29:53 2003
+++ edited/net/core/wireless.c	Tue Jun  8 20:10:36 2004
@@ -189,6 +189,8 @@
 	},
 	[SIOCSIWSCAN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
+		.token_size	= sizeof(struct iw_scan_req),
+		.max_tokens	= 1,
 	},
 	[SIOCGIWSCAN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
@@ -264,6 +266,39 @@
 	},
 	[SIOCGIWPOWER	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
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
+		.header_type	= IW_HEADER_TYPE_PARAM,
+	},
+	[SIOCSIWENCODEEXT - SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_POINT,
+		.token_size	= 1,
+		.max_tokens	= sizeof(struct iw_encode_ext) +
+				  IW_ENCODING_TOKEN_MAX,
+	},
+	[SIOCGIWENCODEEXT - SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_POINT,
+		.token_size	= 1,
+		.max_tokens	= sizeof(struct iw_encode_ext) +
+				  IW_ENCODING_TOKEN_MAX,
 	},
 };
 static const int standard_ioctl_num = (sizeof(standard_ioctl) /

-- 
Jouni Malinen                                            PGP id EFC895FA
