From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Thu, 10 Feb 2005 18:49:27 -0600
Message-ID: <420C0117.9070603@linux.intel.com>
References: <4203C32A.70402@linux.intel.com> <20050208042950.GD8366@jm.kir.nu> <420885B6.7090606@linux.intel.com> <42094A6D.9080508@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040200080309090603080508"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <42094A6D.9080508@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040200080309090603080508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:

> Just to keep everything moving, my recommendation would be to move the 
> code to net/*, and resend the patch (with whatever changes you have 
> made to date).

Alrighty... attached is the latest diff against netdev-2.6. 

Changes since last version:

* Includes previously missing files
* Lots of whitespace cleanups
* Various syntactical cleanups
* Moved to net/ieee80211 from drivers/net/wireless/ieee80211
-- I wasn't sure what people's thoughts were for how Wireless is 
currently leveled under menuconfig.
* Moved ieee80211.h and ieee80211_crypt.h to include/net
* Updated descriptions of WEP, TKIP, and CCMP software cipher suites and 
reworked Makefile to match
* Verified that the patch applies, can be configured via menuconfig, and 
builds
successfully
* Changed AES_586 selection to just AES

Also attached is the list of items folks have sent me that I have not 
resolved (if anyone wants to throw me a patch that hits any of these, 
feel free)

I've pushed the above changes to bk://ipw.bkbits.net/ipw-2.6 if anyone 
wants to use them on conjunction w/ the current development snapshots of 
the ipw* drivers.

James


--------------040200080309090603080508
Content-Type: text/x-patch;
 name="ieee80211-021005.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ieee80211-021005.patch"

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/include/net/ieee80211.h netdev-2.6-ipw/include/net/ieee80211.h
--- netdev-2.6/include/net/ieee80211.h	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/include/net/ieee80211.h	2005-02-10 16:46:19 -06:00
@@ -0,0 +1,883 @@
+/*
+ * Merged with mainline ieee80211.h in Aug 2004.  Original ieee802_11
+ * remains copyright by the original authors
+ *
+ * Portions of the merged code are based on Host AP (software wireless
+ * LAN access point) driver for Intersil Prism2/2.5/3.
+ *
+ * Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+ * <jkmaline@cc.hut.fi>
+ * Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ *
+ * Adaption to a generic IEEE 802.11 stack by James Ketrenos
+ * <jketreno@linux.intel.com>
+ * Copyright (c) 2004, Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+#ifndef IEEE80211_H
+#define IEEE80211_H
+#include <linux/if_ether.h> /* ETH_ALEN */
+#include <linux/kernel.h>   /* ARRAY_SIZE */
+
+#if WIRELESS_EXT < 17
+#define IW_QUAL_QUAL_INVALID   0x10
+#define IW_QUAL_LEVEL_INVALID  0x20
+#define IW_QUAL_NOISE_INVALID  0x40
+#define IW_QUAL_QUAL_UPDATED   0x1
+#define IW_QUAL_LEVEL_UPDATED  0x2
+#define IW_QUAL_NOISE_UPDATED  0x4
+#endif
+
+#define IEEE80211_DATA_LEN		2304
+/* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
+   6.2.1.1.2.
+
+   The figure in section 7.1.2 suggests a body size of up to 2312
+   bytes is allowed, which is a bit confusing, I suspect this
+   represents the 2304 bytes of real data, plus a possible 8 bytes of
+   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
+
+
+#define IEEE80211_HLEN			30
+#define IEEE80211_FRAME_LEN		(IEEE80211_DATA_LEN + IEEE80211_HLEN)
+
+struct ieee80211_hdr {
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
+	u16 seq_ctl;
+	u8 addr4[ETH_ALEN];
+} __attribute__ ((packed));
+
+struct ieee80211_hdr_3addr {
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
+	u16 seq_ctl;
+} __attribute__ ((packed));
+
+static const char *eap_types[] = {
+	"EAP-Packet", "EAPOL-Start", "EAPOL-Logoff", "EAPOL-Key",
+	"EAPOL-Encap-ASF-Alert", "Unknown"
+};
+
+static inline const char *eap_get_type(int type)
+{
+	if (type > ARRAY_SIZE(eap_types))
+		type = ARRAY_SIZE(eap_types) - 1;
+	return eap_types[type];
+}
+
+struct eapol {
+	u8 snap[6];
+	u16 ethertype;
+	u8 version;
+	u8 type;
+	u16 length;
+} __attribute__ ((packed));
+
+#define IEEE80211_3ADDR_LEN 24
+#define IEEE80211_4ADDR_LEN 30
+#define IEEE80211_FCS_LEN    4
+
+#define MIN_FRAG_THRESHOLD     256U
+#define	MAX_FRAG_THRESHOLD     2346U
+
+/* Frame control field constants */
+#define IEEE80211_FCTL_VERS		0x0002
+#define IEEE80211_FCTL_FTYPE		0x000c
+#define IEEE80211_FCTL_STYPE		0x00f0
+#define IEEE80211_FCTL_TODS		0x0100
+#define IEEE80211_FCTL_FROMDS		0x0200
+#define IEEE80211_FCTL_MOREFRAGS	0x0400
+#define IEEE80211_FCTL_RETRY		0x0800
+#define IEEE80211_FCTL_PM		0x1000
+#define IEEE80211_FCTL_MOREDATA	0x2000
+#define IEEE80211_FCTL_WEP		0x4000
+#define IEEE80211_FCTL_ORDER		0x8000
+
+#define IEEE80211_FTYPE_MGMT		0x0000
+#define IEEE80211_FTYPE_CTL		0x0004
+#define IEEE80211_FTYPE_DATA		0x0008
+
+/* management */
+#define IEEE80211_STYPE_ASSOC_REQ	0x0000
+#define IEEE80211_STYPE_ASSOC_RESP 	0x0010
+#define IEEE80211_STYPE_REASSOC_REQ	0x0020
+#define IEEE80211_STYPE_REASSOC_RESP	0x0030
+#define IEEE80211_STYPE_PROBE_REQ	0x0040
+#define IEEE80211_STYPE_PROBE_RESP	0x0050
+#define IEEE80211_STYPE_BEACON		0x0080
+#define IEEE80211_STYPE_ATIM		0x0090
+#define IEEE80211_STYPE_DISASSOC	0x00A0
+#define IEEE80211_STYPE_AUTH		0x00B0
+#define IEEE80211_STYPE_DEAUTH		0x00C0
+
+/* control */
+#define IEEE80211_STYPE_PSPOLL		0x00A0
+#define IEEE80211_STYPE_RTS		0x00B0
+#define IEEE80211_STYPE_CTS		0x00C0
+#define IEEE80211_STYPE_ACK		0x00D0
+#define IEEE80211_STYPE_CFEND		0x00E0
+#define IEEE80211_STYPE_CFENDACK	0x00F0
+
+/* data */
+#define IEEE80211_STYPE_DATA		0x0000
+#define IEEE80211_STYPE_DATA_CFACK	0x0010
+#define IEEE80211_STYPE_DATA_CFPOLL	0x0020
+#define IEEE80211_STYPE_DATA_CFACKPOLL	0x0030
+#define IEEE80211_STYPE_NULLFUNC	0x0040
+#define IEEE80211_STYPE_CFACK		0x0050
+#define IEEE80211_STYPE_CFPOLL		0x0060
+#define IEEE80211_STYPE_CFACKPOLL	0x0070
+
+#define IEEE80211_SCTL_FRAG		0x000F
+#define IEEE80211_SCTL_SEQ		0xFFF0
+
+
+/* debug macros */
+
+#ifdef CONFIG_IEEE80211_DEBUG
+extern u32 ieee80211_debug_level;
+#define IEEE80211_DEBUG(level, fmt, args...) \
+do { if (ieee80211_debug_level & (level)) \
+  printk(KERN_DEBUG "ieee80211: %c %s " fmt, \
+         in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+#else
+#define IEEE80211_DEBUG(level, fmt, args...) do {} while (0)
+#endif	/* CONFIG_IEEE80211_DEBUG */
+
+/*
+ * To use the debug system;
+ *
+ * If you are defining a new debug classification, simply add it to the #define
+ * list here in the form of:
+ *
+ * #define IEEE80211_DL_xxxx VALUE
+ *
+ * shifting value to the left one bit from the previous entry.  xxxx should be
+ * the name of the classification (for example, WEP)
+ *
+ * You then need to either add a IEEE80211_xxxx_DEBUG() macro definition for your
+ * classification, or use IEEE80211_DEBUG(IEEE80211_DL_xxxx, ...) whenever you want
+ * to send output to that classification.
+ *
+ * To add your debug level to the list of levels seen when you perform
+ *
+ * % cat /proc/net/ipw/debug_level
+ *
+ * you simply need to add your entry to the ipw_debug_levels array.
+ *
+ * If you do not see debug_level in /proc/net/ipw then you do not have
+ * CONFIG_IEEE80211_DEBUG defined in your kernel configuration
+ *
+ */
+
+#define IEEE80211_DL_INFO          (1<<0)
+#define IEEE80211_DL_WX            (1<<1)
+#define IEEE80211_DL_SCAN          (1<<2)
+#define IEEE80211_DL_STATE         (1<<3)
+#define IEEE80211_DL_MGMT          (1<<4)
+#define IEEE80211_DL_FRAG          (1<<5)
+#define IEEE80211_DL_EAP           (1<<6)
+#define IEEE80211_DL_DROP          (1<<7)
+
+#define IEEE80211_DL_TX            (1<<8)
+#define IEEE80211_DL_RX            (1<<9)
+
+#define IEEE80211_ERROR(f, a...) printk(KERN_ERR "ieee80211: " f, ## a)
+#define IEEE80211_WARNING(f, a...) printk(KERN_WARNING "ieee80211: " f, ## a)
+#define IEEE80211_DEBUG_INFO(f, a...)   IEEE80211_DEBUG(IEEE80211_DL_INFO, f, ## a)
+
+#define IEEE80211_DEBUG_WX(f, a...)     IEEE80211_DEBUG(IEEE80211_DL_WX, f, ## a)
+#define IEEE80211_DEBUG_SCAN(f, a...)   IEEE80211_DEBUG(IEEE80211_DL_SCAN, f, ## a)
+#define IEEE80211_DEBUG_STATE(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_STATE, f, ## a)
+#define IEEE80211_DEBUG_MGMT(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_MGMT, f, ## a)
+#define IEEE80211_DEBUG_FRAG(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_FRAG, f, ## a)
+#define IEEE80211_DEBUG_EAP(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_EAP, f, ## a)
+#define IEEE80211_DEBUG_DROP(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_DROP, f, ## a)
+#define IEEE80211_DEBUG_TX(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_TX, f, ## a)
+#define IEEE80211_DEBUG_RX(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_RX, f, ## a)
+#include <linux/netdevice.h>
+#include <linux/wireless.h>
+#include <linux/if_arp.h> /* ARPHRD_ETHER */
+
+#ifndef WIRELESS_SPY
+#define WIRELESS_SPY		// enable iwspy support
+#endif
+#include <net/iw_handler.h>	// new driver API
+
+#ifndef ETH_P_PAE
+#define ETH_P_PAE 0x888E /* Port Access Entity (IEEE 802.1X) */
+#endif /* ETH_P_PAE */
+
+#define ETH_P_PREAUTH 0x88C7 /* IEEE 802.11i pre-authentication */
+
+#ifndef ETH_P_80211_RAW
+#define ETH_P_80211_RAW (ETH_P_ECONET + 1)
+#endif
+
+/* IEEE 802.11 defines */
+
+#define P80211_OUI_LEN 3
+
+struct ieee80211_snap_hdr {
+
+        u8    dsap;   /* always 0xAA */
+        u8    ssap;   /* always 0xAA */
+        u8    ctrl;   /* always 0x03 */
+        u8    oui[P80211_OUI_LEN];    /* organizational universal id */
+
+} __attribute__ ((packed));
+
+#define SNAP_SIZE sizeof(struct ieee80211_snap_hdr)
+
+#define WLAN_FC_GET_TYPE(fc) ((fc) & IEEE80211_FCTL_FTYPE)
+#define WLAN_FC_GET_STYPE(fc) ((fc) & IEEE80211_FCTL_STYPE)
+
+#define WLAN_GET_SEQ_FRAG(seq) ((seq) & IEEE80211_SCTL_FRAG)
+#define WLAN_GET_SEQ_SEQ(seq)  ((seq) & IEEE80211_SCTL_SEQ)
+
+/* Authentication algorithms */
+#define WLAN_AUTH_OPEN 0
+#define WLAN_AUTH_SHARED_KEY 1
+
+#define WLAN_AUTH_CHALLENGE_LEN 128
+
+#define WLAN_CAPABILITY_BSS (1<<0)
+#define WLAN_CAPABILITY_IBSS (1<<1)
+#define WLAN_CAPABILITY_CF_POLLABLE (1<<2)
+#define WLAN_CAPABILITY_CF_POLL_REQUEST (1<<3)
+#define WLAN_CAPABILITY_PRIVACY (1<<4)
+#define WLAN_CAPABILITY_SHORT_PREAMBLE (1<<5)
+#define WLAN_CAPABILITY_PBCC (1<<6)
+#define WLAN_CAPABILITY_CHANNEL_AGILITY (1<<7)
+
+/* Status codes */
+#define WLAN_STATUS_SUCCESS 0
+#define WLAN_STATUS_UNSPECIFIED_FAILURE 1
+#define WLAN_STATUS_CAPS_UNSUPPORTED 10
+#define WLAN_STATUS_REASSOC_NO_ASSOC 11
+#define WLAN_STATUS_ASSOC_DENIED_UNSPEC 12
+#define WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG 13
+#define WLAN_STATUS_UNKNOWN_AUTH_TRANSACTION 14
+#define WLAN_STATUS_CHALLENGE_FAIL 15
+#define WLAN_STATUS_AUTH_TIMEOUT 16
+#define WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA 17
+#define WLAN_STATUS_ASSOC_DENIED_RATES 18
+/* 802.11b */
+#define WLAN_STATUS_ASSOC_DENIED_NOSHORT 19
+#define WLAN_STATUS_ASSOC_DENIED_NOPBCC 20
+#define WLAN_STATUS_ASSOC_DENIED_NOAGILITY 21
+
+/* Reason codes */
+#define WLAN_REASON_UNSPECIFIED 1
+#define WLAN_REASON_PREV_AUTH_NOT_VALID 2
+#define WLAN_REASON_DEAUTH_LEAVING 3
+#define WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY 4
+#define WLAN_REASON_DISASSOC_AP_BUSY 5
+#define WLAN_REASON_CLASS2_FRAME_FROM_NONAUTH_STA 6
+#define WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA 7
+#define WLAN_REASON_DISASSOC_STA_HAS_LEFT 8
+#define WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH 9
+
+
+/* Information Element IDs */
+#define WLAN_EID_SSID 0
+#define WLAN_EID_SUPP_RATES 1
+#define WLAN_EID_FH_PARAMS 2
+#define WLAN_EID_DS_PARAMS 3
+#define WLAN_EID_CF_PARAMS 4
+#define WLAN_EID_TIM 5
+#define WLAN_EID_IBSS_PARAMS 6
+#define WLAN_EID_CHALLENGE 16
+#define WLAN_EID_RSN 48
+#define WLAN_EID_GENERIC 221
+
+#define IEEE80211_MGMT_HDR_LEN 24
+#define IEEE80211_DATA_HDR3_LEN 24
+#define IEEE80211_DATA_HDR4_LEN 30
+
+
+#define IEEE80211_STATMASK_SIGNAL (1<<0)
+#define IEEE80211_STATMASK_RSSI (1<<1)
+#define IEEE80211_STATMASK_NOISE (1<<2)
+#define IEEE80211_STATMASK_RATE (1<<3)
+#define IEEE80211_STATMASK_WEMASK 0x7
+
+
+#define IEEE80211_CCK_MODULATION    (1<<0)
+#define IEEE80211_OFDM_MODULATION   (1<<1)
+
+#define IEEE80211_24GHZ_BAND     (1<<0)
+#define IEEE80211_52GHZ_BAND     (1<<1)
+
+#define IEEE80211_CCK_RATE_1MB		        0x02
+#define IEEE80211_CCK_RATE_2MB		        0x04
+#define IEEE80211_CCK_RATE_5MB		        0x0B
+#define IEEE80211_CCK_RATE_11MB		        0x16
+#define IEEE80211_OFDM_RATE_6MB		        0x0C
+#define IEEE80211_OFDM_RATE_9MB		        0x12
+#define IEEE80211_OFDM_RATE_12MB		0x18
+#define IEEE80211_OFDM_RATE_18MB		0x24
+#define IEEE80211_OFDM_RATE_24MB		0x30
+#define IEEE80211_OFDM_RATE_36MB		0x48
+#define IEEE80211_OFDM_RATE_48MB		0x60
+#define IEEE80211_OFDM_RATE_54MB		0x6C
+#define IEEE80211_BASIC_RATE_MASK		0x80
+
+#define IEEE80211_CCK_RATE_1MB_MASK		(1<<0)
+#define IEEE80211_CCK_RATE_2MB_MASK		(1<<1)
+#define IEEE80211_CCK_RATE_5MB_MASK		(1<<2)
+#define IEEE80211_CCK_RATE_11MB_MASK		(1<<3)
+#define IEEE80211_OFDM_RATE_6MB_MASK		(1<<4)
+#define IEEE80211_OFDM_RATE_9MB_MASK		(1<<5)
+#define IEEE80211_OFDM_RATE_12MB_MASK		(1<<6)
+#define IEEE80211_OFDM_RATE_18MB_MASK		(1<<7)
+#define IEEE80211_OFDM_RATE_24MB_MASK		(1<<8)
+#define IEEE80211_OFDM_RATE_36MB_MASK		(1<<9)
+#define IEEE80211_OFDM_RATE_48MB_MASK		(1<<10)
+#define IEEE80211_OFDM_RATE_54MB_MASK		(1<<11)
+
+#define IEEE80211_CCK_RATES_MASK	        0x0000000F
+#define IEEE80211_CCK_BASIC_RATES_MASK	(IEEE80211_CCK_RATE_1MB_MASK | \
+	IEEE80211_CCK_RATE_2MB_MASK)
+#define IEEE80211_CCK_DEFAULT_RATES_MASK	(IEEE80211_CCK_BASIC_RATES_MASK | \
+        IEEE80211_CCK_RATE_5MB_MASK | \
+        IEEE80211_CCK_RATE_11MB_MASK)
+
+#define IEEE80211_OFDM_RATES_MASK		0x00000FF0
+#define IEEE80211_OFDM_BASIC_RATES_MASK	(IEEE80211_OFDM_RATE_6MB_MASK | \
+	IEEE80211_OFDM_RATE_12MB_MASK | \
+	IEEE80211_OFDM_RATE_24MB_MASK)
+#define IEEE80211_OFDM_DEFAULT_RATES_MASK	(IEEE80211_OFDM_BASIC_RATES_MASK | \
+	IEEE80211_OFDM_RATE_9MB_MASK  | \
+	IEEE80211_OFDM_RATE_18MB_MASK | \
+	IEEE80211_OFDM_RATE_36MB_MASK | \
+	IEEE80211_OFDM_RATE_48MB_MASK | \
+	IEEE80211_OFDM_RATE_54MB_MASK)
+#define IEEE80211_DEFAULT_RATES_MASK (IEEE80211_OFDM_DEFAULT_RATES_MASK | \
+                                IEEE80211_CCK_DEFAULT_RATES_MASK)
+
+#define IEEE80211_NUM_OFDM_RATES	    8
+#define IEEE80211_NUM_CCK_RATES	            4
+#define IEEE80211_OFDM_SHIFT_MASK_A         4
+
+
+
+
+/* NOTE: This data is for statistical purposes; not all hardware provides this
+ *       information for frames received.  Not setting these will not cause
+ *       any adverse affects. */
+struct ieee80211_rx_stats {
+	u32 mac_time;
+	s8 rssi;
+	u8 signal;
+	u8 noise;
+	u16 rate; /* in 100 kbps */
+	u8 received_channel;
+	u8 control;
+	u8 mask;
+	u8 freq;
+	u16 len;
+};
+
+/* IEEE 802.11 requires that STA supports concurrent reception of at least
+ * three fragmented frames. This define can be increased to support more
+ * concurrent frames, but it should be noted that each entry can consume about
+ * 2 kB of RAM and increasing cache size will slow down frame reassembly. */
+#define IEEE80211_FRAG_CACHE_LEN 4
+
+struct ieee80211_frag_entry {
+	unsigned long first_frag_time;
+	unsigned int seq;
+	unsigned int last_frag;
+	struct sk_buff *skb;
+	u8 src_addr[ETH_ALEN];
+	u8 dst_addr[ETH_ALEN];
+};
+
+struct ieee80211_stats {
+	unsigned int tx_unicast_frames;
+	unsigned int tx_multicast_frames;
+	unsigned int tx_fragments;
+	unsigned int tx_unicast_octets;
+	unsigned int tx_multicast_octets;
+	unsigned int tx_deferred_transmissions;
+	unsigned int tx_single_retry_frames;
+	unsigned int tx_multiple_retry_frames;
+	unsigned int tx_retry_limit_exceeded;
+	unsigned int tx_discards;
+	unsigned int rx_unicast_frames;
+	unsigned int rx_multicast_frames;
+	unsigned int rx_fragments;
+	unsigned int rx_unicast_octets;
+	unsigned int rx_multicast_octets;
+	unsigned int rx_fcs_errors;
+	unsigned int rx_discards_no_buffer;
+	unsigned int tx_discards_wrong_sa;
+	unsigned int rx_discards_undecryptable;
+	unsigned int rx_message_in_msg_fragments;
+	unsigned int rx_message_in_bad_msg_fragments;
+};
+
+struct ieee80211_device;
+
+#include "ieee80211_crypt.h"
+
+#define SEC_KEY_1         (1<<0)
+#define SEC_KEY_2         (1<<1)
+#define SEC_KEY_3         (1<<2)
+#define SEC_KEY_4         (1<<3)
+#define SEC_ACTIVE_KEY    (1<<4)
+#define SEC_AUTH_MODE     (1<<5)
+#define SEC_UNICAST_GROUP (1<<6)
+#define SEC_LEVEL         (1<<7)
+#define SEC_ENABLED       (1<<8)
+
+#define SEC_LEVEL_0      0 /* None */
+#define SEC_LEVEL_1      1 /* WEP 40 and 104 bit */
+#define SEC_LEVEL_2      2 /* Level 1 + TKIP */
+#define SEC_LEVEL_2_CKIP 3 /* Level 1 + CKIP */
+#define SEC_LEVEL_3      4 /* Level 2 + CCMP */
+
+#define WEP_KEYS 4
+#define WEP_KEY_LEN 13
+
+struct ieee80211_security {
+	u16 active_key:2,
+            enabled:1,
+	    auth_mode:2,
+            auth_algo:4,
+            unicast_uses_group:1;
+	u8 key_sizes[WEP_KEYS];
+	u8 keys[WEP_KEYS][WEP_KEY_LEN];
+	u8 level;
+	u16 flags;
+} __attribute__ ((packed));
+
+
+/*
+
+ 802.11 data frame from AP
+
+      ,-------------------------------------------------------------------.
+Bytes |  2   |  2   |    6    |    6    |    6    |  2   | 0..2312 |   4  |
+      |------|------|---------|---------|---------|------|---------|------|
+Desc. | ctrl | dura |  DA/RA  |   TA    |    SA   | Sequ |  frame  |  fcs |
+      |      | tion | (BSSID) |         |         | ence |  data   |      |
+      `-------------------------------------------------------------------'
+
+Total: 28-2340 bytes
+
+*/
+
+struct ieee80211_header_data {
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[6];
+	u8 addr2[6];
+	u8 addr3[6];
+	u16 seq_ctrl;
+};
+
+#define BEACON_PROBE_SSID_ID_POSITION 12
+
+/* Management Frame Information Element Types */
+#define MFIE_TYPE_SSID       0
+#define MFIE_TYPE_RATES      1
+#define MFIE_TYPE_FH_SET     2
+#define MFIE_TYPE_DS_SET     3
+#define MFIE_TYPE_CF_SET     4
+#define MFIE_TYPE_TIM        5
+#define MFIE_TYPE_IBSS_SET   6
+#define MFIE_TYPE_CHALLENGE  16
+#define MFIE_TYPE_RSN	     48
+#define MFIE_TYPE_RATES_EX   50
+#define MFIE_TYPE_GENERIC    221
+
+struct ieee80211_info_element_hdr {
+	u8 id;
+	u8 len;
+} __attribute__ ((packed));
+
+struct ieee80211_info_element {
+	u8 id;
+	u8 len;
+	u8 data[0];
+} __attribute__ ((packed));
+
+/*
+ * These are the data types that can make up management packets
+ *
+	u16 auth_algorithm;
+	u16 auth_sequence;
+	u16 beacon_interval;
+	u16 capability;
+	u8 current_ap[ETH_ALEN];
+	u16 listen_interval;
+	struct {
+		u16 association_id:14, reserved:2;
+	} __attribute__ ((packed));
+	u32 time_stamp[2];
+	u16 reason;
+	u16 status;
+*/
+
+struct ieee80211_authentication {
+	struct ieee80211_header_data header;
+	u16 algorithm;
+	u16 transaction;
+	u16 status;
+	struct ieee80211_info_element info_element;
+} __attribute__ ((packed));
+
+
+struct ieee80211_probe_response {
+	struct ieee80211_header_data header;
+	u32 time_stamp[2];
+	u16 beacon_interval;
+	u16 capability;
+	struct ieee80211_info_element info_element;
+} __attribute__ ((packed));
+
+struct ieee80211_assoc_request_frame {
+	u16 capability;
+	u16 listen_interval;
+	u8 current_ap[ETH_ALEN];
+	struct ieee80211_info_element info_element;
+} __attribute__ ((packed));
+
+struct ieee80211_assoc_response_frame {
+	struct ieee80211_hdr_3addr header;
+	u16 capability;
+	u16 status;
+	u16 aid;
+	struct ieee80211_info_element info_element; /* supported rates */
+} __attribute__ ((packed));
+
+
+struct ieee80211_txb {
+	u8 nr_frags;
+	u8 encrypted;
+	u16 reserved;
+	u16 frag_size;
+	u16 payload_size;
+	struct sk_buff *fragments[0];
+};
+
+
+/* SWEEP TABLE ENTRIES NUMBER*/
+#define MAX_SWEEP_TAB_ENTRIES		  42
+#define MAX_SWEEP_TAB_ENTRIES_PER_PACKET  7
+/* MAX_RATES_LENGTH needs to be 12.  The spec says 8, and many APs
+ * only use 8, and then use extended rates for the remaining supported
+ * rates.  Other APs, however, stick all of their supported rates on the
+ * main rates information element... */
+#define MAX_RATES_LENGTH                  ((u8)12)
+#define MAX_RATES_EX_LENGTH               ((u8)16)
+#define MAX_NETWORK_COUNT                  128
+
+#define CRC_LENGTH                 4U
+
+#define MAX_WPA_IE_LEN 64
+
+#define NETWORK_EMPTY_ESSID (1<<0)
+#define NETWORK_HAS_OFDM    (1<<1)
+#define NETWORK_HAS_CCK     (1<<2)
+
+struct ieee80211_network {
+	/* These entries are used to identify a unique network */
+	u8 bssid[ETH_ALEN];
+	u8 channel;
+	/* Ensure null-terminated for any debug msgs */
+	u8 ssid[IW_ESSID_MAX_SIZE + 1];
+	u8 ssid_len;
+
+	/* These are network statistics */
+	struct ieee80211_rx_stats stats;
+	u16 capability;
+	u8 rates[MAX_RATES_LENGTH];
+	u8 rates_len;
+	u8 rates_ex[MAX_RATES_EX_LENGTH];
+	u8 rates_ex_len;
+	unsigned long last_scanned;
+	u8 mode;
+	u8 flags;
+	u32 last_associate;
+	u32 time_stamp[2];
+	u16 beacon_interval;
+	u16 listen_interval;
+	u16 atim_window;
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
+	u8 rsn_ie[MAX_WPA_IE_LEN];
+	size_t rsn_ie_len;
+	struct list_head list;
+};
+
+enum ieee80211_state {
+	IEEE80211_UNINITIALIZED = 0,
+	IEEE80211_INITIALIZED,
+	IEEE80211_ASSOCIATING,
+	IEEE80211_ASSOCIATED,
+	IEEE80211_AUTHENTICATING,
+	IEEE80211_AUTHENTICATED,
+	IEEE80211_SHUTDOWN
+};
+
+#define DEFAULT_MAX_SCAN_AGE (15 * HZ)
+#define DEFAULT_FTS 2346
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ARG(x) ((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x))[3],((u8*)(x))[4],((u8*)(x))[5]
+
+
+extern inline int is_multicast_ether_addr(const u8 *addr)
+{
+	return ((addr[0] != 0xff) && (0x01 & addr[0]));
+}
+
+extern inline int is_broadcast_ether_addr(const u8 *addr)
+{
+	return ((addr[0] == 0xff) && (addr[1] == 0xff) && (addr[2] == 0xff) &&   \
+		(addr[3] == 0xff) && (addr[4] == 0xff) && (addr[5] == 0xff));
+}
+
+#define CFG_IEEE80211_RESERVE_FCS (1<<0)
+#define CFG_IEEE80211_COMPUTE_FCS (1<<1)
+
+struct ieee80211_device {
+	struct net_device *dev;
+
+	/* Bookkeeping structures */
+	struct net_device_stats stats;
+	struct ieee80211_stats ieee_stats;
+
+	/* Probe / Beacon management */
+	struct list_head network_free_list;
+	struct list_head network_list;
+	struct ieee80211_network *networks;
+	int scans;
+	int scan_age;
+
+	int iw_mode; /* operating mode (IW_MODE_*) */
+
+	spinlock_t lock;
+
+	int tx_headroom; /* Set to size of any additional room needed at front
+			  * of allocated Tx SKBs */
+	u32 config;
+
+	/* WEP and other encryption related settings at the device level */
+	int open_wep; /* Set to 1 to allow unencrypted frames */
+
+	int reset_on_keychange; /* Set to 1 if the HW needs to be reset on
+				 * WEP key changes */
+
+	/* If the host performs {en,de}cryption, then set to 1 */
+	int host_encrypt;
+	int host_decrypt;
+	int ieee802_1x; /* is IEEE 802.1X used */
+
+	/* WPA data */
+	int wpa_enabled;
+	int drop_unencrypted;
+	int tkip_countermeasures;
+	int privacy_invoked;
+	size_t wpa_ie_len;
+	u8 *wpa_ie;
+
+	struct list_head crypt_deinit_list;
+	struct ieee80211_crypt_data *crypt[WEP_KEYS];
+	int tx_keyidx; /* default TX key index (crypt[tx_keyidx]) */
+	struct timer_list crypt_deinit_timer;
+
+	int bcrx_sta_key; /* use individual keys to override default keys even
+			   * with RX of broad/multicast frames */
+
+	/* Fragmentation structures */
+	struct ieee80211_frag_entry frag_cache[IEEE80211_FRAG_CACHE_LEN];
+	unsigned int frag_next_idx;
+	u16 fts; /* Fragmentation Threshold */
+
+	/* Association info */
+	u8 bssid[ETH_ALEN];
+
+	enum ieee80211_state state;
+
+	int mode;       /* A, B, G */
+	int modulation; /* CCK, OFDM */
+	int freq_band;  /* 2.4Ghz, 5.2Ghz, Mixed */
+	int abg_ture;   /* ABG flag              */
+
+	/* Callback functions */
+	void (*set_security)(struct net_device *dev,
+			     struct ieee80211_security *sec);
+	int (*hard_start_xmit)(struct ieee80211_txb *txb,
+			       struct net_device *dev);
+	int (*reset_port)(struct net_device *dev);
+
+	/* This must be the last item so that it points to the data
+	 * allocated beyond this structure by alloc_ieee80211 */
+	u8 priv[0];
+};
+
+#define IEEE_A            (1<<0)
+#define IEEE_B            (1<<1)
+#define IEEE_G            (1<<2)
+#define IEEE_MODE_MASK    (IEEE_A|IEEE_B|IEEE_G)
+
+extern inline void *ieee80211_priv(struct net_device *dev)
+{
+	return ((struct ieee80211_device *)netdev_priv(dev))->priv;
+}
+
+extern inline int ieee80211_is_empty_essid(const char *essid, int essid_len)
+{
+	/* Single white space is for Linksys APs */
+	if (essid_len == 1 && essid[0] == ' ')
+		return 1;
+
+	/* Otherwise, if the entire essid is 0, we assume it is hidden */
+	while (essid_len) {
+		essid_len--;
+		if (essid[essid_len] != '\0')
+			return 0;
+	}
+
+	return 1;
+}
+
+extern inline int ieee80211_is_valid_mode(struct ieee80211_device *ieee, int mode)
+{
+	/*
+	 * It is possible for both access points and our device to support
+	 * combinations of modes, so as long as there is one valid combination
+	 * of ap/device supported modes, then return success
+	 *
+	 */
+	if ((mode & IEEE_A) &&
+	    (ieee->modulation & IEEE80211_OFDM_MODULATION) &&
+	    (ieee->freq_band & IEEE80211_52GHZ_BAND))
+		return 1;
+
+	if ((mode & IEEE_G) &&
+	    (ieee->modulation & IEEE80211_OFDM_MODULATION) &&
+	    (ieee->freq_band & IEEE80211_24GHZ_BAND))
+		return 1;
+
+	if ((mode & IEEE_B) &&
+	    (ieee->modulation & IEEE80211_CCK_MODULATION) &&
+	    (ieee->freq_band & IEEE80211_24GHZ_BAND))
+		return 1;
+
+	return 0;
+}
+
+extern inline int ieee80211_get_hdrlen(u16 fc)
+{
+	int hdrlen = 24;
+
+	switch (WLAN_FC_GET_TYPE(fc)) {
+	case IEEE80211_FTYPE_DATA:
+		if ((fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS))
+			hdrlen = 30; /* Addr4 */
+		break;
+	case IEEE80211_FTYPE_CTL:
+		switch (WLAN_FC_GET_STYPE(fc)) {
+		case IEEE80211_STYPE_CTS:
+		case IEEE80211_STYPE_ACK:
+			hdrlen = 10;
+			break;
+		default:
+			hdrlen = 16;
+			break;
+		}
+		break;
+	}
+
+	return hdrlen;
+}
+
+
+
+/* ieee80211.c */
+extern void free_ieee80211(struct net_device *dev);
+extern struct net_device *alloc_ieee80211(int sizeof_priv);
+
+extern int ieee80211_set_encryption(struct ieee80211_device *ieee);
+
+/* ieee80211_tx.c */
+
+
+extern int ieee80211_xmit(struct sk_buff *skb,
+			  struct net_device *dev);
+extern void ieee80211_txb_free(struct ieee80211_txb *);
+
+
+/* ieee80211_rx.c */
+extern int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
+			struct ieee80211_rx_stats *rx_stats);
+extern void ieee80211_rx_mgt(struct ieee80211_device *ieee,
+			     struct ieee80211_hdr *header,
+			     struct ieee80211_rx_stats *stats);
+
+/* iee80211_wx.c */
+extern int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu, char *key);
+extern int ieee80211_wx_set_encode(struct ieee80211_device *ieee,
+				   struct iw_request_info *info,
+				   union iwreq_data *wrqu, char *key);
+extern int ieee80211_wx_get_encode(struct ieee80211_device *ieee,
+				   struct iw_request_info *info,
+				   union iwreq_data *wrqu, char *key);
+
+
+extern inline void ieee80211_increment_scans(struct ieee80211_device *ieee)
+{
+	ieee->scans++;
+}
+
+extern inline int ieee80211_get_scans(struct ieee80211_device *ieee)
+{
+	return ieee->scans;
+}
+
+static inline const char *escape_essid(const char *essid, u8 essid_len) {
+	static char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
+	const char *s = essid;
+	char *d = escaped;
+
+	if (ieee80211_is_empty_essid(essid, essid_len)) {
+		memcpy(escaped, "<hidden>", sizeof("<hidden>"));
+		return escaped;
+	}
+
+	essid_len = min(essid_len, (u8)IW_ESSID_MAX_SIZE);
+	while (essid_len--) {
+		if (*s == '\0') {
+			*d++ = '\\';
+			*d++ = '0';
+			s++;
+		} else {
+			*d++ = *s++;
+		}
+	}
+	*d = '\0';
+	return escaped;
+}
+
+#ifndef offset_in_page
+#define offset_in_page(p) ((unsigned long)(p) & ~PAGE_MASK)
+#endif
+
+#endif /* IEEE80211_H */
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/include/net/ieee80211_crypt.h netdev-2.6-ipw/include/net/ieee80211_crypt.h
--- netdev-2.6/include/net/ieee80211_crypt.h	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/include/net/ieee80211_crypt.h	2005-02-10 16:46:19 -06:00
@@ -0,0 +1,86 @@
+/*
+ * Original code based on Host AP (software wireless LAN access point) driver
+ * for Intersil Prism2/2.5/3.
+ *
+ * Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+ * <jkmaline@cc.hut.fi>
+ * Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ *
+ * Adaption to a generic IEEE 802.11 stack by James Ketrenos
+ * <jketreno@linux.intel.com>
+ *
+ * Copyright (c) 2004, Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+
+/*
+ * This file defines the interface to the ieee80211 crypto module.
+ */
+#ifndef IEEE80211_CRYPT_H
+#define IEEE80211_CRYPT_H
+
+#include <linux/skbuff.h>
+
+struct ieee80211_crypto_ops {
+	const char *name;
+
+	/* init new crypto context (e.g., allocate private data space,
+	 * select IV, etc.); returns NULL on failure or pointer to allocated
+	 * private data on success */
+	void * (*init)(int keyidx);
+
+	/* deinitialize crypto context and free allocated private data */
+	void (*deinit)(void *priv);
+
+	/* encrypt/decrypt return < 0 on error or >= 0 on success. The return
+	 * value from decrypt_mpdu is passed as the keyidx value for
+	 * decrypt_msdu. skb must have enough head and tail room for the
+	 * encryption; if not, error will be returned; these functions are
+	 * called for all MPDUs (i.e., fragments).
+	 */
+	int (*encrypt_mpdu)(struct sk_buff *skb, int hdr_len, void *priv);
+	int (*decrypt_mpdu)(struct sk_buff *skb, int hdr_len, void *priv);
+
+	/* These functions are called for full MSDUs, i.e. full frames.
+	 * These can be NULL if full MSDU operations are not needed. */
+	int (*encrypt_msdu)(struct sk_buff *skb, int hdr_len, void *priv);
+	int (*decrypt_msdu)(struct sk_buff *skb, int keyidx, int hdr_len,
+			    void *priv);
+
+	int (*set_key)(void *key, int len, u8 *seq, void *priv);
+	int (*get_key)(void *key, int len, u8 *seq, void *priv);
+
+	/* procfs handler for printing out key information and possible
+	 * statistics */
+	char * (*print_stats)(char *p, void *priv);
+
+	/* maximum number of bytes added by encryption; encrypt buf is
+	 * allocated with extra_prefix_len bytes, copy of in_buf, and
+	 * extra_postfix_len; encrypt need not use all this space, but
+	 * the result must start at the beginning of the buffer and correct
+	 * length must be returned */
+	int extra_prefix_len, extra_postfix_len;
+
+	struct module *owner;
+};
+
+struct ieee80211_crypt_data {
+	struct list_head list; /* delayed deletion list */
+	struct ieee80211_crypto_ops *ops;
+	void *priv;
+	atomic_t refcnt;
+};
+
+int ieee80211_register_crypto_ops(struct ieee80211_crypto_ops *ops);
+int ieee80211_unregister_crypto_ops(struct ieee80211_crypto_ops *ops);
+struct ieee80211_crypto_ops * ieee80211_get_crypto_ops(const char *name);
+void ieee80211_crypt_deinit_entries(struct ieee80211_device *, int);
+void ieee80211_crypt_deinit_handler(unsigned long);
+void ieee80211_crypt_delayed_deinit(struct ieee80211_device *ieee,
+				    struct ieee80211_crypt_data **crypt);
+
+#endif
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/Kconfig netdev-2.6-ipw/net/Kconfig
--- netdev-2.6/net/Kconfig	2005-02-04 10:11:14 -06:00
+++ netdev-2.6-ipw/net/Kconfig	2005-02-10 17:40:59 -06:00
@@ -653,6 +653,8 @@
 
 source "net/bluetooth/Kconfig"
 
+source "net/ieee80211/Kconfig"
+
 source "drivers/net/Kconfig"
 
 endmenu
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/Makefile netdev-2.6-ipw/net/Makefile
--- netdev-2.6/net/Makefile	2005-02-04 10:11:14 -06:00
+++ netdev-2.6-ipw/net/Makefile	2005-02-10 17:40:04 -06:00
@@ -42,6 +42,7 @@
 obj-$(CONFIG_ECONET)		+= econet/
 obj-$(CONFIG_VLAN_8021Q)	+= 8021q/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
+obj-$(CONFIG_IEEE80211)		+= ieee80211/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/Kconfig netdev-2.6-ipw/net/ieee80211/Kconfig
--- netdev-2.6/net/ieee80211/Kconfig	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/Kconfig	2005-02-10 17:48:14 -06:00
@@ -0,0 +1,71 @@
+config IEEE80211
+	tristate "Generic IEEE 802.11 Networking Stack"
+	select NET_RADIO
+	---help---
+	This option enables the hardware independent IEEE 802.11 
+	networking stack.  This option will also select NET_RADIO.
+
+config IEEE80211_DEBUG
+	bool "Enable full debugging output"
+	depends on IEEE80211
+	---help---
+	  This option will enable debug tracing output for the 
+	  ieee80211 network stack.  
+
+	  This will result in the kernel module being ~70k larger.  You 
+	  can control which debug output is sent to the kernel log by 
+	  setting the value in 
+
+	  /proc/net/ieee80211/debug_level
+
+	  For example:
+
+	  % echo 0x00000FFO > /proc/net/ieee80211/debug_level
+
+	  For a list of values you can assign to debug_level, you 
+	  can look at the bit mask values in <net/ieee80211.h>
+
+	  If you are not trying to debug or develop the ieee80211 
+	  subsystem, you most likely want to say N here.
+
+config IEEE80211_CRYPT_WEP
+	tristate "IEEE 802.11 WEP encryption (802.1x)"
+	depends on IEEE80211
+	select CRYPTO
+	select CRYPTO_ARC4
+	select CRC32
+	---help---
+	Include software based cipher suites in support of IEEE 
+	802.11's WEP.  This is needed for WEP as well as 802.1x.  This 
+	selects ARC4 under kernel crypto libraries, and CRC32 under 
+	kernel libraries. 
+
+	This can be compiled as a modules and it will be called
+	"ieee80211_crypt_wep".
+
+config IEEE80211_CRYPT_CCMP
+	tristate "IEEE 802.11i CCMP support"
+	depends on IEEE80211
+	select CRYPTO_AES
+	---help---
+	Include software based cipher suites in support of IEEE 802.11i 
+	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with CCMP enabled 
+	networks.  This selects AES support under kernel crypto 
+	libraries.
+
+	This can be compiled as a modules and it will be called
+	"ieee80211_crypt_ccmp".
+
+config IEEE80211_CRYPT_TKIP
+	tristate "IEEE 802.11i TKIP encryption"
+	depends on IEEE80211
+	select CRYPTO_MICHAEL_MIC
+	---help---
+	Include software based cipher suites in support of IEEE 802.11i 
+	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with TKIP enabled 
+	networks.  This selects Michael Mic support under kernel crypto 
+	libraries. 
+
+	This can be compiled as a modules and it will be called
+	"ieee80211_crypt_tkip".
+
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/Makefile netdev-2.6-ipw/net/ieee80211/Makefile
--- netdev-2.6/net/ieee80211/Makefile	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/Makefile	2005-02-10 17:55:08 -06:00
@@ -0,0 +1,11 @@
+obj-$(CONFIG_IEEE80211) += ieee80211.o 
+obj-$(CONFIG_IEEE80211) += ieee80211_crypt.o
+obj-$(CONFIG_IEEE80211_CRYPT_WEP) += ieee80211_crypt_wep.o
+obj-$(CONFIG_IEEE80211_CRYPT_CCMP) += ieee80211_crypt_ccmp.o
+obj-$(CONFIG_IEEE80211_CRYPT_TKIP) += ieee80211_crypt_tkip.o
+ieee80211-objs := \
+	ieee80211_module.o \
+	ieee80211_tx.o \
+	ieee80211_rx.o \
+	ieee80211_wx.o
+
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_crypt.c netdev-2.6-ipw/net/ieee80211/ieee80211_crypt.c
--- netdev-2.6/net/ieee80211/ieee80211_crypt.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_crypt.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,253 @@
+/*
+ * Host AP crypto routines
+ *
+ * Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ * Portions Copyright (C) 2004, Intel Corporation <jketreno@linux.intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <asm/string.h>
+#include <asm/errno.h>
+
+#include <net/ieee80211.h>
+
+MODULE_AUTHOR("Jouni Malinen");
+MODULE_DESCRIPTION("HostAP crypto");
+MODULE_LICENSE("GPL");
+
+struct ieee80211_crypto_alg {
+	struct list_head list;
+	struct ieee80211_crypto_ops *ops;
+};
+
+
+struct ieee80211_crypto {
+	struct list_head algs;
+	spinlock_t lock;
+};
+
+static struct ieee80211_crypto *hcrypt;
+
+void ieee80211_crypt_deinit_entries(struct ieee80211_device *ieee,
+					   int force)
+{
+	struct list_head *ptr, *n;
+	struct ieee80211_crypt_data *entry;
+
+	for (ptr = ieee->crypt_deinit_list.next, n = ptr->next;
+	     ptr != &ieee->crypt_deinit_list; ptr = n, n = ptr->next) {
+		entry = list_entry(ptr, struct ieee80211_crypt_data, list);
+
+		if (atomic_read(&entry->refcnt) != 0 && !force)
+			continue;
+
+		list_del(ptr);
+
+		if (entry->ops) {
+			entry->ops->deinit(entry->priv);
+			module_put(entry->ops->owner);
+		}
+		kfree(entry);
+	}
+}
+
+void ieee80211_crypt_deinit_handler(unsigned long data)
+{
+	struct ieee80211_device *ieee = (struct ieee80211_device *)data;
+	unsigned long flags;
+
+	spin_lock_irqsave(&ieee->lock, flags);
+	ieee80211_crypt_deinit_entries(ieee, 0);
+	if (!list_empty(&ieee->crypt_deinit_list)) {
+		printk(KERN_DEBUG "%s: entries remaining in delayed crypt "
+		       "deletion list\n", ieee->dev->name);
+		ieee->crypt_deinit_timer.expires = jiffies + HZ;
+		add_timer(&ieee->crypt_deinit_timer);
+	}
+	spin_unlock_irqrestore(&ieee->lock, flags);
+
+}
+
+void ieee80211_crypt_delayed_deinit(struct ieee80211_device *ieee,
+				    struct ieee80211_crypt_data **crypt)
+{
+	struct ieee80211_crypt_data *tmp;
+	unsigned long flags;
+
+	if (*crypt == NULL)
+		return;
+
+	tmp = *crypt;
+	*crypt = NULL;
+
+	/* must not run ops->deinit() while there may be pending encrypt or
+	 * decrypt operations. Use a list of delayed deinits to avoid needing
+	 * locking. */
+
+	spin_lock_irqsave(&ieee->lock, flags);
+	list_add(&tmp->list, &ieee->crypt_deinit_list);
+	if (!timer_pending(&ieee->crypt_deinit_timer)) {
+		ieee->crypt_deinit_timer.expires = jiffies + HZ;
+		add_timer(&ieee->crypt_deinit_timer);
+	}
+	spin_unlock_irqrestore(&ieee->lock, flags);
+}
+
+int ieee80211_register_crypto_ops(struct ieee80211_crypto_ops *ops)
+{
+	unsigned long flags;
+	struct ieee80211_crypto_alg *alg;
+
+	if (hcrypt == NULL)
+		return -1;
+
+	alg = kmalloc(sizeof(*alg), GFP_KERNEL);
+	if (alg == NULL)
+		return -ENOMEM;
+
+	memset(alg, 0, sizeof(*alg));
+	alg->ops = ops;
+
+	spin_lock_irqsave(&hcrypt->lock, flags);
+	list_add(&alg->list, &hcrypt->algs);
+	spin_unlock_irqrestore(&hcrypt->lock, flags);
+
+	printk(KERN_DEBUG "ieee80211_crypt: registered algorithm '%s'\n",
+	       ops->name);
+
+	return 0;
+}
+
+int ieee80211_unregister_crypto_ops(struct ieee80211_crypto_ops *ops)
+{
+	unsigned long flags;
+	struct list_head *ptr;
+	struct ieee80211_crypto_alg *del_alg = NULL;
+
+	if (hcrypt == NULL)
+		return -1;
+
+	spin_lock_irqsave(&hcrypt->lock, flags);
+	for (ptr = hcrypt->algs.next; ptr != &hcrypt->algs; ptr = ptr->next) {
+		struct ieee80211_crypto_alg *alg =
+			(struct ieee80211_crypto_alg *) ptr;
+		if (alg->ops == ops) {
+			list_del(&alg->list);
+			del_alg = alg;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&hcrypt->lock, flags);
+
+	if (del_alg) {
+		printk(KERN_DEBUG "ieee80211_crypt: unregistered algorithm "
+		       "'%s'\n", ops->name);
+		kfree(del_alg);
+	}
+
+	return del_alg ? 0 : -1;
+}
+
+
+struct ieee80211_crypto_ops * ieee80211_get_crypto_ops(const char *name)
+{
+	unsigned long flags;
+	struct list_head *ptr;
+	struct ieee80211_crypto_alg *found_alg = NULL;
+
+	if (hcrypt == NULL)
+		return NULL;
+
+	spin_lock_irqsave(&hcrypt->lock, flags);
+	for (ptr = hcrypt->algs.next; ptr != &hcrypt->algs; ptr = ptr->next) {
+		struct ieee80211_crypto_alg *alg =
+			(struct ieee80211_crypto_alg *) ptr;
+		if (strcmp(alg->ops->name, name) == 0) {
+			found_alg = alg;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&hcrypt->lock, flags);
+
+	if (found_alg)
+		return found_alg->ops;
+	else
+		return NULL;
+}
+
+
+static void * ieee80211_crypt_null_init(int keyidx) { return (void *) 1; }
+static void ieee80211_crypt_null_deinit(void *priv) {}
+
+static struct ieee80211_crypto_ops ieee80211_crypt_null = {
+	.name			= "NULL",
+	.init			= ieee80211_crypt_null_init,
+	.deinit			= ieee80211_crypt_null_deinit,
+	.encrypt_mpdu		= NULL,
+	.decrypt_mpdu		= NULL,
+	.encrypt_msdu		= NULL,
+	.decrypt_msdu		= NULL,
+	.set_key		= NULL,
+	.get_key		= NULL,
+	.extra_prefix_len	= 0,
+	.extra_postfix_len	= 0,
+	.owner			= THIS_MODULE,
+};
+
+
+static int __init ieee80211_crypto_init(void)
+{
+	hcrypt = kmalloc(sizeof(*hcrypt), GFP_KERNEL);
+	if (hcrypt == NULL)
+		return -ENOMEM;
+
+	memset(hcrypt, 0, sizeof(*hcrypt));
+	INIT_LIST_HEAD(&hcrypt->algs);
+	spin_lock_init(&hcrypt->lock);
+
+	(void) ieee80211_register_crypto_ops(&ieee80211_crypt_null);
+
+	return 0;
+}
+
+
+static void __exit ieee80211_crypto_deinit(void)
+{
+	struct list_head *ptr, *n;
+
+	if (hcrypt == NULL)
+		return;
+
+	for (ptr = hcrypt->algs.next, n = ptr->next; ptr != &hcrypt->algs;
+	     ptr = n, n = ptr->next) {
+		struct ieee80211_crypto_alg *alg =
+			(struct ieee80211_crypto_alg *) ptr;
+		list_del(ptr);
+		printk(KERN_DEBUG "ieee80211_crypt: unregistered algorithm "
+		       "'%s' (deinit)\n", alg->ops->name);
+		kfree(alg);
+	}
+
+	kfree(hcrypt);
+}
+
+EXPORT_SYMBOL(ieee80211_crypt_deinit_entries);
+EXPORT_SYMBOL(ieee80211_crypt_deinit_handler);
+EXPORT_SYMBOL(ieee80211_crypt_delayed_deinit);
+
+EXPORT_SYMBOL(ieee80211_register_crypto_ops);
+EXPORT_SYMBOL(ieee80211_unregister_crypto_ops);
+EXPORT_SYMBOL(ieee80211_get_crypto_ops);
+
+module_init(ieee80211_crypto_init);
+module_exit(ieee80211_crypto_deinit);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_crypt_ccmp.c netdev-2.6-ipw/net/ieee80211/ieee80211_crypt_ccmp.c
--- netdev-2.6/net/ieee80211/ieee80211_crypt_ccmp.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_crypt_ccmp.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,473 @@
+/*
+ * Host AP crypt: host-based CCMP encryption implementation for Host AP driver
+ *
+ * Copyright (c) 2003-2004, Jouni Malinen <jkmaline@cc.hut.fi>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/random.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_arp.h>
+#include <asm/string.h>
+#include <linux/wireless.h>
+
+#include <net/ieee80211.h>
+
+
+#include <linux/crypto.h>
+#include <asm/scatterlist.h>
+
+MODULE_AUTHOR("Jouni Malinen");
+MODULE_DESCRIPTION("Host AP crypt: CCMP");
+MODULE_LICENSE("GPL");
+
+#define AES_BLOCK_LEN 16
+#define CCMP_HDR_LEN 8
+#define CCMP_MIC_LEN 8
+#define CCMP_TK_LEN 16
+#define CCMP_PN_LEN 6
+
+struct ieee80211_ccmp_data {
+	u8 key[CCMP_TK_LEN];
+	int key_set;
+
+	u8 tx_pn[CCMP_PN_LEN];
+	u8 rx_pn[CCMP_PN_LEN];
+
+	u32 dot11RSNAStatsCCMPFormatErrors;
+	u32 dot11RSNAStatsCCMPReplays;
+	u32 dot11RSNAStatsCCMPDecryptErrors;
+
+	int key_idx;
+
+	struct crypto_tfm *tfm;
+
+	/* scratch buffers for virt_to_page() (crypto API) */
+	u8 tx_b0[AES_BLOCK_LEN], tx_b[AES_BLOCK_LEN],
+		tx_e[AES_BLOCK_LEN], tx_s0[AES_BLOCK_LEN];
+	u8 rx_b0[AES_BLOCK_LEN], rx_b[AES_BLOCK_LEN], rx_a[AES_BLOCK_LEN];
+};
+
+void ieee80211_ccmp_aes_encrypt(struct crypto_tfm *tfm,
+			     const u8 pt[16], u8 ct[16])
+{
+	struct scatterlist src, dst;
+
+	src.page = virt_to_page(pt);
+	src.offset = offset_in_page(pt);
+	src.length = AES_BLOCK_LEN;
+
+	dst.page = virt_to_page(ct);
+	dst.offset = offset_in_page(ct);
+	dst.length = AES_BLOCK_LEN;
+
+	crypto_cipher_encrypt(tfm, &dst, &src, AES_BLOCK_LEN);
+}
+
+static void * ieee80211_ccmp_init(int key_idx)
+{
+	struct ieee80211_ccmp_data *priv;
+
+	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
+	if (priv == NULL)
+		goto fail;
+	memset(priv, 0, sizeof(*priv));
+	priv->key_idx = key_idx;
+
+	priv->tfm = crypto_alloc_tfm("aes", 0);
+	if (priv->tfm == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_ccmp: could not allocate "
+		       "crypto API aes\n");
+		goto fail;
+	}
+
+	return priv;
+
+fail:
+	if (priv) {
+		if (priv->tfm)
+			crypto_free_tfm(priv->tfm);
+		kfree(priv);
+	}
+
+	return NULL;
+}
+
+
+static void ieee80211_ccmp_deinit(void *priv)
+{
+	struct ieee80211_ccmp_data *_priv = priv;
+	if (_priv && _priv->tfm)
+		crypto_free_tfm(_priv->tfm);
+	kfree(priv);
+}
+
+
+static inline void xor_block(u8 *b, u8 *a, size_t len)
+{
+	int i;
+	for (i = 0; i < len; i++)
+		b[i] ^= a[i];
+}
+
+
+static void ccmp_init_blocks(struct crypto_tfm *tfm,
+			     struct ieee80211_hdr *hdr,
+			     u8 *pn, size_t dlen, u8 *b0, u8 *auth,
+			     u8 *s0)
+{
+	u8 *pos, qc = 0;
+	size_t aad_len;
+	u16 fc;
+	int a4_included, qc_included;
+	u8 aad[2 * AES_BLOCK_LEN];
+
+	fc = le16_to_cpu(hdr->frame_ctl);
+	a4_included = ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
+		       (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS));
+	qc_included = ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_DATA) &&
+		       (WLAN_FC_GET_STYPE(fc) & 0x08));
+	aad_len = 22;
+	if (a4_included)
+		aad_len += 6;
+	if (qc_included) {
+		pos = (u8 *) &hdr->addr4;
+		if (a4_included)
+			pos += 6;
+		qc = *pos & 0x0f;
+		aad_len += 2;
+	}
+
+	/* CCM Initial Block:
+	 * Flag (Include authentication header, M=3 (8-octet MIC),
+	 *       L=1 (2-octet Dlen))
+	 * Nonce: 0x00 | A2 | PN
+	 * Dlen */
+	b0[0] = 0x59;
+	b0[1] = qc;
+	memcpy(b0 + 2, hdr->addr2, ETH_ALEN);
+	memcpy(b0 + 8, pn, CCMP_PN_LEN);
+	b0[14] = (dlen >> 8) & 0xff;
+	b0[15] = dlen & 0xff;
+
+	/* AAD:
+	 * FC with bits 4..6 and 11..13 masked to zero; 14 is always one
+	 * A1 | A2 | A3
+	 * SC with bits 4..15 (seq#) masked to zero
+	 * A4 (if present)
+	 * QC (if present)
+	 */
+	pos = (u8 *) hdr;
+	aad[0] = 0; /* aad_len >> 8 */
+	aad[1] = aad_len & 0xff;
+	aad[2] = pos[0] & 0x8f;
+	aad[3] = pos[1] & 0xc7;
+	memcpy(aad + 4, hdr->addr1, 3 * ETH_ALEN);
+	pos = (u8 *) &hdr->seq_ctl;
+	aad[22] = pos[0] & 0x0f;
+	aad[23] = 0; /* all bits masked */
+	memset(aad + 24, 0, 8);
+	if (a4_included)
+		memcpy(aad + 24, hdr->addr4, ETH_ALEN);
+	if (qc_included) {
+		aad[a4_included ? 30 : 24] = qc;
+		/* rest of QC masked */
+	}
+
+	/* Start with the first block and AAD */
+	ieee80211_ccmp_aes_encrypt(tfm, b0, auth);
+	xor_block(auth, aad, AES_BLOCK_LEN);
+	ieee80211_ccmp_aes_encrypt(tfm, auth, auth);
+	xor_block(auth, &aad[AES_BLOCK_LEN], AES_BLOCK_LEN);
+	ieee80211_ccmp_aes_encrypt(tfm, auth, auth);
+	b0[0] &= 0x07;
+	b0[14] = b0[15] = 0;
+	ieee80211_ccmp_aes_encrypt(tfm, b0, s0);
+}
+
+
+static int ieee80211_ccmp_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct ieee80211_ccmp_data *key = priv;
+	int data_len, i, blocks, last, len;
+	u8 *pos, *mic;
+	struct ieee80211_hdr *hdr;
+	u8 *b0 = key->tx_b0;
+	u8 *b = key->tx_b;
+	u8 *e = key->tx_e;
+	u8 *s0 = key->tx_s0;
+
+	if (skb_headroom(skb) < CCMP_HDR_LEN ||
+	    skb_tailroom(skb) < CCMP_MIC_LEN ||
+	    skb->len < hdr_len)
+		return -1;
+
+	data_len = skb->len - hdr_len;
+	pos = skb_push(skb, CCMP_HDR_LEN);
+	memmove(pos, pos + CCMP_HDR_LEN, hdr_len);
+	pos += hdr_len;
+	mic = skb_put(skb, CCMP_MIC_LEN);
+
+	i = CCMP_PN_LEN - 1;
+	while (i >= 0) {
+		key->tx_pn[i]++;
+		if (key->tx_pn[i] != 0)
+			break;
+		i--;
+	}
+
+	*pos++ = key->tx_pn[5];
+	*pos++ = key->tx_pn[4];
+	*pos++ = 0;
+	*pos++ = (key->key_idx << 6) | (1 << 5) /* Ext IV included */;
+	*pos++ = key->tx_pn[3];
+	*pos++ = key->tx_pn[2];
+	*pos++ = key->tx_pn[1];
+	*pos++ = key->tx_pn[0];
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	ccmp_init_blocks(key->tfm, hdr, key->tx_pn, data_len, b0, b, s0);
+
+	blocks = (data_len + AES_BLOCK_LEN - 1) / AES_BLOCK_LEN;
+	last = data_len % AES_BLOCK_LEN;
+
+	for (i = 1; i <= blocks; i++) {
+		len = (i == blocks && last) ? last : AES_BLOCK_LEN;
+		/* Authentication */
+		xor_block(b, pos, len);
+		ieee80211_ccmp_aes_encrypt(key->tfm, b, b);
+		/* Encryption, with counter */
+		b0[14] = (i >> 8) & 0xff;
+		b0[15] = i & 0xff;
+		ieee80211_ccmp_aes_encrypt(key->tfm, b0, e);
+		xor_block(pos, e, len);
+		pos += len;
+	}
+
+	for (i = 0; i < CCMP_MIC_LEN; i++)
+		mic[i] = b[i] ^ s0[i];
+
+	return 0;
+}
+
+
+static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct ieee80211_ccmp_data *key = priv;
+	u8 keyidx, *pos;
+	struct ieee80211_hdr *hdr;
+	u8 *b0 = key->rx_b0;
+	u8 *b = key->rx_b;
+	u8 *a = key->rx_a;
+	u8 pn[6];
+	int i, blocks, last, len;
+	size_t data_len = skb->len - hdr_len - CCMP_HDR_LEN - CCMP_MIC_LEN;
+	u8 *mic = skb->data + skb->len - CCMP_MIC_LEN;
+
+	if (skb->len < hdr_len + CCMP_HDR_LEN + CCMP_MIC_LEN) {
+		key->dot11RSNAStatsCCMPFormatErrors++;
+		return -1;
+	}
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	pos = skb->data + hdr_len;
+	keyidx = pos[3];
+	if (!(keyidx & (1 << 5))) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "CCMP: received packet without ExtIV"
+			       " flag from " MAC_FMT "\n", MAC_ARG(hdr->addr2));
+		}
+		key->dot11RSNAStatsCCMPFormatErrors++;
+		return -2;
+	}
+	keyidx >>= 6;
+	if (key->key_idx != keyidx) {
+		printk(KERN_DEBUG "CCMP: RX tkey->key_idx=%d frame "
+		       "keyidx=%d priv=%p\n", key->key_idx, keyidx, priv);
+		return -6;
+	}
+	if (!key->key_set) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "CCMP: received packet from " MAC_FMT
+			       " with keyid=%d that does not have a configured"
+			       " key\n", MAC_ARG(hdr->addr2), keyidx);
+		}
+		return -3;
+	}
+
+	pn[0] = pos[7];
+	pn[1] = pos[6];
+	pn[2] = pos[5];
+	pn[3] = pos[4];
+	pn[4] = pos[1];
+	pn[5] = pos[0];
+	pos += 8;
+
+	if (memcmp(pn, key->rx_pn, CCMP_PN_LEN) <= 0) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "CCMP: replay detected: STA=" MAC_FMT
+			       " previous PN %02x%02x%02x%02x%02x%02x "
+			       "received PN %02x%02x%02x%02x%02x%02x\n",
+			       MAC_ARG(hdr->addr2), MAC_ARG(key->rx_pn),
+			       MAC_ARG(pn));
+		}
+		key->dot11RSNAStatsCCMPReplays++;
+		return -4;
+	}
+
+	ccmp_init_blocks(key->tfm, hdr, pn, data_len, b0, a, b);
+	xor_block(mic, b, CCMP_MIC_LEN);
+
+	blocks = (data_len + AES_BLOCK_LEN - 1) / AES_BLOCK_LEN;
+	last = data_len % AES_BLOCK_LEN;
+
+	for (i = 1; i <= blocks; i++) {
+		len = (i == blocks && last) ? last : AES_BLOCK_LEN;
+		/* Decrypt, with counter */
+		b0[14] = (i >> 8) & 0xff;
+		b0[15] = i & 0xff;
+		ieee80211_ccmp_aes_encrypt(key->tfm, b0, b);
+		xor_block(pos, b, len);
+		/* Authentication */
+		xor_block(a, pos, len);
+		ieee80211_ccmp_aes_encrypt(key->tfm, a, a);
+		pos += len;
+	}
+
+	if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "CCMP: decrypt failed: STA="
+			       MAC_FMT "\n", MAC_ARG(hdr->addr2));
+		}
+		key->dot11RSNAStatsCCMPDecryptErrors++;
+		return -5;
+	}
+
+	memcpy(key->rx_pn, pn, CCMP_PN_LEN);
+
+	/* Remove hdr and MIC */
+	memmove(skb->data + CCMP_HDR_LEN, skb->data, hdr_len);
+	skb_pull(skb, CCMP_HDR_LEN);
+	skb_trim(skb, skb->len - CCMP_MIC_LEN);
+
+	return keyidx;
+}
+
+
+static int ieee80211_ccmp_set_key(void *key, int len, u8 *seq, void *priv)
+{
+	struct ieee80211_ccmp_data *data = priv;
+	int keyidx;
+	struct crypto_tfm *tfm = data->tfm;
+
+	keyidx = data->key_idx;
+	memset(data, 0, sizeof(*data));
+	data->key_idx = keyidx;
+	data->tfm = tfm;
+	if (len == CCMP_TK_LEN) {
+		memcpy(data->key, key, CCMP_TK_LEN);
+		data->key_set = 1;
+		if (seq) {
+			data->rx_pn[0] = seq[5];
+			data->rx_pn[1] = seq[4];
+			data->rx_pn[2] = seq[3];
+			data->rx_pn[3] = seq[2];
+			data->rx_pn[4] = seq[1];
+			data->rx_pn[5] = seq[0];
+		}
+		crypto_cipher_setkey(data->tfm, data->key, CCMP_TK_LEN);
+	} else if (len == 0)
+		data->key_set = 0;
+	else
+		return -1;
+
+	return 0;
+}
+
+
+static int ieee80211_ccmp_get_key(void *key, int len, u8 *seq, void *priv)
+{
+	struct ieee80211_ccmp_data *data = priv;
+
+	if (len < CCMP_TK_LEN)
+		return -1;
+
+	if (!data->key_set)
+		return 0;
+	memcpy(key, data->key, CCMP_TK_LEN);
+
+	if (seq) {
+		seq[0] = data->tx_pn[5];
+		seq[1] = data->tx_pn[4];
+		seq[2] = data->tx_pn[3];
+		seq[3] = data->tx_pn[2];
+		seq[4] = data->tx_pn[1];
+		seq[5] = data->tx_pn[0];
+	}
+
+	return CCMP_TK_LEN;
+}
+
+
+static char * ieee80211_ccmp_print_stats(char *p, void *priv)
+{
+	struct ieee80211_ccmp_data *ccmp = priv;
+	p += sprintf(p, "key[%d] alg=CCMP key_set=%d "
+		     "tx_pn=%02x%02x%02x%02x%02x%02x "
+		     "rx_pn=%02x%02x%02x%02x%02x%02x "
+		     "format_errors=%d replays=%d decrypt_errors=%d\n",
+		     ccmp->key_idx, ccmp->key_set,
+		     MAC_ARG(ccmp->tx_pn), MAC_ARG(ccmp->rx_pn),
+		     ccmp->dot11RSNAStatsCCMPFormatErrors,
+		     ccmp->dot11RSNAStatsCCMPReplays,
+		     ccmp->dot11RSNAStatsCCMPDecryptErrors);
+
+	return p;
+}
+
+
+static struct ieee80211_crypto_ops ieee80211_crypt_ccmp = {
+	.name			= "CCMP",
+	.init			= ieee80211_ccmp_init,
+	.deinit			= ieee80211_ccmp_deinit,
+	.encrypt_mpdu		= ieee80211_ccmp_encrypt,
+	.decrypt_mpdu		= ieee80211_ccmp_decrypt,
+	.encrypt_msdu		= NULL,
+	.decrypt_msdu		= NULL,
+	.set_key		= ieee80211_ccmp_set_key,
+	.get_key		= ieee80211_ccmp_get_key,
+	.print_stats		= ieee80211_ccmp_print_stats,
+	.extra_prefix_len	= CCMP_HDR_LEN,
+	.extra_postfix_len	= CCMP_MIC_LEN,
+	.owner			= THIS_MODULE,
+};
+
+
+static int __init ieee80211_crypto_ccmp_init(void)
+{
+	if (ieee80211_register_crypto_ops(&ieee80211_crypt_ccmp) < 0)
+		return -1;
+
+	return 0;
+}
+
+
+static void __exit ieee80211_crypto_ccmp_exit(void)
+{
+	ieee80211_unregister_crypto_ops(&ieee80211_crypt_ccmp);
+}
+
+
+module_init(ieee80211_crypto_ccmp_init);
+module_exit(ieee80211_crypto_ccmp_exit);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_crypt_tkip.c netdev-2.6-ipw/net/ieee80211/ieee80211_crypt_tkip.c
--- netdev-2.6/net/ieee80211/ieee80211_crypt_tkip.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_crypt_tkip.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,711 @@
+/*
+ * Host AP crypt: host-based TKIP encryption implementation for Host AP driver
+ *
+ * Copyright (c) 2003-2004, Jouni Malinen <jkmaline@cc.hut.fi>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/random.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_arp.h>
+#include <asm/string.h>
+
+#include <net/ieee80211.h>
+
+
+#include <linux/crypto.h>
+#include <asm/scatterlist.h>
+#include <linux/crc32.h>
+
+MODULE_AUTHOR("Jouni Malinen");
+MODULE_DESCRIPTION("Host AP crypt: TKIP");
+MODULE_LICENSE("GPL");
+
+struct ieee80211_tkip_data {
+#define TKIP_KEY_LEN 32
+	u8 key[TKIP_KEY_LEN];
+	int key_set;
+
+	u32 tx_iv32;
+	u16 tx_iv16;
+	u16 tx_ttak[5];
+	int tx_phase1_done;
+
+	u32 rx_iv32;
+	u16 rx_iv16;
+	u16 rx_ttak[5];
+	int rx_phase1_done;
+	u32 rx_iv32_new;
+	u16 rx_iv16_new;
+
+	u32 dot11RSNAStatsTKIPReplays;
+	u32 dot11RSNAStatsTKIPICVErrors;
+	u32 dot11RSNAStatsTKIPLocalMICFailures;
+
+	int key_idx;
+
+	struct crypto_tfm *tfm_arc4;
+	struct crypto_tfm *tfm_michael;
+
+	/* scratch buffers for virt_to_page() (crypto API) */
+	u8 rx_hdr[16], tx_hdr[16];
+};
+
+static void * ieee80211_tkip_init(int key_idx)
+{
+	struct ieee80211_tkip_data *priv;
+
+	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
+	if (priv == NULL)
+		goto fail;
+	memset(priv, 0, sizeof(*priv));
+	priv->key_idx = key_idx;
+
+	priv->tfm_arc4 = crypto_alloc_tfm("arc4", 0);
+	if (priv->tfm_arc4 == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
+		       "crypto API arc4\n");
+		goto fail;
+	}
+
+	priv->tfm_michael = crypto_alloc_tfm("michael_mic", 0);
+	if (priv->tfm_michael == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
+		       "crypto API michael_mic\n");
+		goto fail;
+	}
+
+	return priv;
+
+fail:
+	if (priv) {
+		if (priv->tfm_michael)
+			crypto_free_tfm(priv->tfm_michael);
+		if (priv->tfm_arc4)
+			crypto_free_tfm(priv->tfm_arc4);
+		kfree(priv);
+	}
+
+	return NULL;
+}
+
+
+static void ieee80211_tkip_deinit(void *priv)
+{
+	struct ieee80211_tkip_data *_priv = priv;
+	if (_priv && _priv->tfm_michael)
+		crypto_free_tfm(_priv->tfm_michael);
+	if (_priv && _priv->tfm_arc4)
+		crypto_free_tfm(_priv->tfm_arc4);
+	kfree(priv);
+}
+
+
+static inline u16 RotR1(u16 val)
+{
+	return (val >> 1) | (val << 15);
+}
+
+
+static inline u8 Lo8(u16 val)
+{
+	return val & 0xff;
+}
+
+
+static inline u8 Hi8(u16 val)
+{
+	return val >> 8;
+}
+
+
+static inline u16 Lo16(u32 val)
+{
+	return val & 0xffff;
+}
+
+
+static inline u16 Hi16(u32 val)
+{
+	return val >> 16;
+}
+
+
+static inline u16 Mk16(u8 hi, u8 lo)
+{
+	return lo | (((u16) hi) << 8);
+}
+
+
+static inline u16 Mk16_le(u16 *v)
+{
+	return le16_to_cpu(*v);
+}
+
+
+static const u16 Sbox[256] =
+{
+	0xC6A5, 0xF884, 0xEE99, 0xF68D, 0xFF0D, 0xD6BD, 0xDEB1, 0x9154,
+	0x6050, 0x0203, 0xCEA9, 0x567D, 0xE719, 0xB562, 0x4DE6, 0xEC9A,
+	0x8F45, 0x1F9D, 0x8940, 0xFA87, 0xEF15, 0xB2EB, 0x8EC9, 0xFB0B,
+	0x41EC, 0xB367, 0x5FFD, 0x45EA, 0x23BF, 0x53F7, 0xE496, 0x9B5B,
+	0x75C2, 0xE11C, 0x3DAE, 0x4C6A, 0x6C5A, 0x7E41, 0xF502, 0x834F,
+	0x685C, 0x51F4, 0xD134, 0xF908, 0xE293, 0xAB73, 0x6253, 0x2A3F,
+	0x080C, 0x9552, 0x4665, 0x9D5E, 0x3028, 0x37A1, 0x0A0F, 0x2FB5,
+	0x0E09, 0x2436, 0x1B9B, 0xDF3D, 0xCD26, 0x4E69, 0x7FCD, 0xEA9F,
+	0x121B, 0x1D9E, 0x5874, 0x342E, 0x362D, 0xDCB2, 0xB4EE, 0x5BFB,
+	0xA4F6, 0x764D, 0xB761, 0x7DCE, 0x527B, 0xDD3E, 0x5E71, 0x1397,
+	0xA6F5, 0xB968, 0x0000, 0xC12C, 0x4060, 0xE31F, 0x79C8, 0xB6ED,
+	0xD4BE, 0x8D46, 0x67D9, 0x724B, 0x94DE, 0x98D4, 0xB0E8, 0x854A,
+	0xBB6B, 0xC52A, 0x4FE5, 0xED16, 0x86C5, 0x9AD7, 0x6655, 0x1194,
+	0x8ACF, 0xE910, 0x0406, 0xFE81, 0xA0F0, 0x7844, 0x25BA, 0x4BE3,
+	0xA2F3, 0x5DFE, 0x80C0, 0x058A, 0x3FAD, 0x21BC, 0x7048, 0xF104,
+	0x63DF, 0x77C1, 0xAF75, 0x4263, 0x2030, 0xE51A, 0xFD0E, 0xBF6D,
+	0x814C, 0x1814, 0x2635, 0xC32F, 0xBEE1, 0x35A2, 0x88CC, 0x2E39,
+	0x9357, 0x55F2, 0xFC82, 0x7A47, 0xC8AC, 0xBAE7, 0x322B, 0xE695,
+	0xC0A0, 0x1998, 0x9ED1, 0xA37F, 0x4466, 0x547E, 0x3BAB, 0x0B83,
+	0x8CCA, 0xC729, 0x6BD3, 0x283C, 0xA779, 0xBCE2, 0x161D, 0xAD76,
+	0xDB3B, 0x6456, 0x744E, 0x141E, 0x92DB, 0x0C0A, 0x486C, 0xB8E4,
+	0x9F5D, 0xBD6E, 0x43EF, 0xC4A6, 0x39A8, 0x31A4, 0xD337, 0xF28B,
+	0xD532, 0x8B43, 0x6E59, 0xDAB7, 0x018C, 0xB164, 0x9CD2, 0x49E0,
+	0xD8B4, 0xACFA, 0xF307, 0xCF25, 0xCAAF, 0xF48E, 0x47E9, 0x1018,
+	0x6FD5, 0xF088, 0x4A6F, 0x5C72, 0x3824, 0x57F1, 0x73C7, 0x9751,
+	0xCB23, 0xA17C, 0xE89C, 0x3E21, 0x96DD, 0x61DC, 0x0D86, 0x0F85,
+	0xE090, 0x7C42, 0x71C4, 0xCCAA, 0x90D8, 0x0605, 0xF701, 0x1C12,
+	0xC2A3, 0x6A5F, 0xAEF9, 0x69D0, 0x1791, 0x9958, 0x3A27, 0x27B9,
+	0xD938, 0xEB13, 0x2BB3, 0x2233, 0xD2BB, 0xA970, 0x0789, 0x33A7,
+	0x2DB6, 0x3C22, 0x1592, 0xC920, 0x8749, 0xAAFF, 0x5078, 0xA57A,
+	0x038F, 0x59F8, 0x0980, 0x1A17, 0x65DA, 0xD731, 0x84C6, 0xD0B8,
+	0x82C3, 0x29B0, 0x5A77, 0x1E11, 0x7BCB, 0xA8FC, 0x6DD6, 0x2C3A,
+};
+
+
+static inline u16 _S_(u16 v)
+{
+	u16 t = Sbox[Hi8(v)];
+	return Sbox[Lo8(v)] ^ ((t << 8) | (t >> 8));
+}
+
+
+#define PHASE1_LOOP_COUNT 8
+
+static void tkip_mixing_phase1(u16 *TTAK, const u8 *TK, const u8 *TA, u32 IV32)
+{
+	int i, j;
+
+	/* Initialize the 80-bit TTAK from TSC (IV32) and TA[0..5] */
+	TTAK[0] = Lo16(IV32);
+	TTAK[1] = Hi16(IV32);
+	TTAK[2] = Mk16(TA[1], TA[0]);
+	TTAK[3] = Mk16(TA[3], TA[2]);
+	TTAK[4] = Mk16(TA[5], TA[4]);
+
+	for (i = 0; i < PHASE1_LOOP_COUNT; i++) {
+		j = 2 * (i & 1);
+		TTAK[0] += _S_(TTAK[4] ^ Mk16(TK[1 + j], TK[0 + j]));
+		TTAK[1] += _S_(TTAK[0] ^ Mk16(TK[5 + j], TK[4 + j]));
+		TTAK[2] += _S_(TTAK[1] ^ Mk16(TK[9 + j], TK[8 + j]));
+		TTAK[3] += _S_(TTAK[2] ^ Mk16(TK[13 + j], TK[12 + j]));
+		TTAK[4] += _S_(TTAK[3] ^ Mk16(TK[1 + j], TK[0 + j])) + i;
+	}
+}
+
+
+static void tkip_mixing_phase2(u8 *WEPSeed, const u8 *TK, const u16 *TTAK,
+			       u16 IV16)
+{
+	/* Make temporary area overlap WEP seed so that the final copy can be
+	 * avoided on little endian hosts. */
+	u16 *PPK = (u16 *) &WEPSeed[4];
+
+	/* Step 1 - make copy of TTAK and bring in TSC */
+	PPK[0] = TTAK[0];
+	PPK[1] = TTAK[1];
+	PPK[2] = TTAK[2];
+	PPK[3] = TTAK[3];
+	PPK[4] = TTAK[4];
+	PPK[5] = TTAK[4] + IV16;
+
+	/* Step 2 - 96-bit bijective mixing using S-box */
+	PPK[0] += _S_(PPK[5] ^ Mk16_le((u16 *) &TK[0]));
+	PPK[1] += _S_(PPK[0] ^ Mk16_le((u16 *) &TK[2]));
+	PPK[2] += _S_(PPK[1] ^ Mk16_le((u16 *) &TK[4]));
+	PPK[3] += _S_(PPK[2] ^ Mk16_le((u16 *) &TK[6]));
+	PPK[4] += _S_(PPK[3] ^ Mk16_le((u16 *) &TK[8]));
+	PPK[5] += _S_(PPK[4] ^ Mk16_le((u16 *) &TK[10]));
+
+	PPK[0] += RotR1(PPK[5] ^ Mk16_le((u16 *) &TK[12]));
+	PPK[1] += RotR1(PPK[0] ^ Mk16_le((u16 *) &TK[14]));
+	PPK[2] += RotR1(PPK[1]);
+	PPK[3] += RotR1(PPK[2]);
+	PPK[4] += RotR1(PPK[3]);
+	PPK[5] += RotR1(PPK[4]);
+
+	/* Step 3 - bring in last of TK bits, assign 24-bit WEP IV value
+	 * WEPSeed[0..2] is transmitted as WEP IV */
+	WEPSeed[0] = Hi8(IV16);
+	WEPSeed[1] = (Hi8(IV16) | 0x20) & 0x7F;
+	WEPSeed[2] = Lo8(IV16);
+	WEPSeed[3] = Lo8((PPK[5] ^ Mk16_le((u16 *) &TK[0])) >> 1);
+
+#ifdef __BIG_ENDIAN
+	{
+		int i;
+		for (i = 0; i < 6; i++)
+			PPK[i] = (PPK[i] << 8) | (PPK[i] >> 8);
+	}
+#endif
+}
+
+static int ieee80211_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct ieee80211_tkip_data *tkey = priv;
+	int len;
+	u8 rc4key[16], *pos, *icv;
+	struct ieee80211_hdr *hdr;
+	u32 crc;
+	struct scatterlist sg;
+
+	if (skb_headroom(skb) < 8 || skb_tailroom(skb) < 4 ||
+	    skb->len < hdr_len)
+		return -1;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	if (!tkey->tx_phase1_done) {
+		tkip_mixing_phase1(tkey->tx_ttak, tkey->key, hdr->addr2,
+				   tkey->tx_iv32);
+		tkey->tx_phase1_done = 1;
+	}
+	tkip_mixing_phase2(rc4key, tkey->key, tkey->tx_ttak, tkey->tx_iv16);
+
+	len = skb->len - hdr_len;
+	pos = skb_push(skb, 8);
+	memmove(pos, pos + 8, hdr_len);
+	pos += hdr_len;
+	icv = skb_put(skb, 4);
+
+	*pos++ = rc4key[0];
+	*pos++ = rc4key[1];
+	*pos++ = rc4key[2];
+	*pos++ = (tkey->key_idx << 6) | (1 << 5) /* Ext IV included */;
+	*pos++ = tkey->tx_iv32 & 0xff;
+	*pos++ = (tkey->tx_iv32 >> 8) & 0xff;
+	*pos++ = (tkey->tx_iv32 >> 16) & 0xff;
+	*pos++ = (tkey->tx_iv32 >> 24) & 0xff;
+
+	crc = ~crc32_le(~0, pos, len);
+	icv[0] = crc;
+	icv[1] = crc >> 8;
+	icv[2] = crc >> 16;
+	icv[3] = crc >> 24;
+
+	crypto_cipher_setkey(tkey->tfm_arc4, rc4key, 16);
+	sg.page = virt_to_page(pos);
+	sg.offset = offset_in_page(pos);
+	sg.length = len + 4;
+	crypto_cipher_encrypt(tkey->tfm_arc4, &sg, &sg, len + 4);
+
+	tkey->tx_iv16++;
+	if (tkey->tx_iv16 == 0) {
+		tkey->tx_phase1_done = 0;
+		tkey->tx_iv32++;
+	}
+
+	return 0;
+}
+
+static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct ieee80211_tkip_data *tkey = priv;
+	u8 rc4key[16];
+	u8 keyidx, *pos;
+	u32 iv32;
+	u16 iv16;
+	struct ieee80211_hdr *hdr;
+	u8 icv[4];
+	u32 crc;
+	struct scatterlist sg;
+	int plen;
+
+	if (skb->len < hdr_len + 8 + 4)
+		return -1;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	pos = skb->data + hdr_len;
+	keyidx = pos[3];
+	if (!(keyidx & (1 << 5))) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "TKIP: received packet without ExtIV"
+			       " flag from " MAC_FMT "\n", MAC_ARG(hdr->addr2));
+		}
+		return -2;
+	}
+	keyidx >>= 6;
+	if (tkey->key_idx != keyidx) {
+		printk(KERN_DEBUG "TKIP: RX tkey->key_idx=%d frame "
+		       "keyidx=%d priv=%p\n", tkey->key_idx, keyidx, priv);
+		return -6;
+	}
+	if (!tkey->key_set) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "TKIP: received packet from " MAC_FMT
+			       " with keyid=%d that does not have a configured"
+			       " key\n", MAC_ARG(hdr->addr2), keyidx);
+		}
+		return -3;
+	}
+	iv16 = (pos[0] << 8) | pos[2];
+	iv32 = pos[4] | (pos[5] << 8) | (pos[6] << 16) | (pos[7] << 24);
+	pos += 8;
+
+	if (iv32 < tkey->rx_iv32 ||
+	    (iv32 == tkey->rx_iv32 && iv16 <= tkey->rx_iv16)) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "TKIP: replay detected: STA=" MAC_FMT
+			       " previous TSC %08x%04x received TSC "
+			       "%08x%04x\n", MAC_ARG(hdr->addr2),
+			       tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
+		}
+		tkey->dot11RSNAStatsTKIPReplays++;
+		return -4;
+	}
+
+	if (iv32 != tkey->rx_iv32 || !tkey->rx_phase1_done) {
+		tkip_mixing_phase1(tkey->rx_ttak, tkey->key, hdr->addr2, iv32);
+		tkey->rx_phase1_done = 1;
+	}
+	tkip_mixing_phase2(rc4key, tkey->key, tkey->rx_ttak, iv16);
+
+	plen = skb->len - hdr_len - 12;
+
+	crypto_cipher_setkey(tkey->tfm_arc4, rc4key, 16);
+	sg.page = virt_to_page(pos);
+	sg.offset = offset_in_page(pos);
+	sg.length = plen + 4;
+	crypto_cipher_decrypt(tkey->tfm_arc4, &sg, &sg, plen + 4);
+
+	crc = ~crc32_le(~0, pos, plen);
+	icv[0] = crc;
+	icv[1] = crc >> 8;
+	icv[2] = crc >> 16;
+	icv[3] = crc >> 24;
+	if (memcmp(icv, pos + plen, 4) != 0) {
+		if (iv32 != tkey->rx_iv32) {
+			/* Previously cached Phase1 result was already lost, so
+			 * it needs to be recalculated for the next packet. */
+			tkey->rx_phase1_done = 0;
+		}
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "TKIP: ICV error detected: STA="
+			       MAC_FMT "\n", MAC_ARG(hdr->addr2));
+		}
+		tkey->dot11RSNAStatsTKIPICVErrors++;
+		return -5;
+	}
+
+	/* Update real counters only after Michael MIC verification has
+	 * completed */
+	tkey->rx_iv32_new = iv32;
+	tkey->rx_iv16_new = iv16;
+
+	/* Remove IV and ICV */
+	memmove(skb->data + 8, skb->data, hdr_len);
+	skb_pull(skb, 8);
+	skb_trim(skb, skb->len - 4);
+
+	return keyidx;
+}
+
+
+static int michael_mic(struct ieee80211_tkip_data *tkey, u8 *key, u8 *hdr,
+		       u8 *data, size_t data_len, u8 *mic)
+{
+	struct scatterlist sg[2];
+
+	if (tkey->tfm_michael == NULL) {
+		printk(KERN_WARNING "michael_mic: tfm_michael == NULL\n");
+		return -1;
+	}
+	sg[0].page = virt_to_page(hdr);
+	sg[0].offset = offset_in_page(hdr);
+	sg[0].length = 16;
+
+	sg[1].page = virt_to_page(data);
+	sg[1].offset = offset_in_page(data);
+	sg[1].length = data_len;
+
+	crypto_digest_init(tkey->tfm_michael);
+	crypto_digest_setkey(tkey->tfm_michael, key, 8);
+	crypto_digest_update(tkey->tfm_michael, sg, 2);
+	crypto_digest_final(tkey->tfm_michael, mic);
+
+	return 0;
+}
+
+static void michael_mic_hdr(struct sk_buff *skb, u8 *hdr)
+{
+	struct ieee80211_hdr *hdr11;
+
+	hdr11 = (struct ieee80211_hdr *) skb->data;
+	switch (le16_to_cpu(hdr11->frame_ctl) &
+		(IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) {
+	case IEEE80211_FCTL_TODS:
+		memcpy(hdr, hdr11->addr3, ETH_ALEN); /* DA */
+		memcpy(hdr + ETH_ALEN, hdr11->addr2, ETH_ALEN); /* SA */
+		break;
+	case IEEE80211_FCTL_FROMDS:
+		memcpy(hdr, hdr11->addr1, ETH_ALEN); /* DA */
+		memcpy(hdr + ETH_ALEN, hdr11->addr3, ETH_ALEN); /* SA */
+		break;
+	case IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS:
+		memcpy(hdr, hdr11->addr3, ETH_ALEN); /* DA */
+		memcpy(hdr + ETH_ALEN, hdr11->addr4, ETH_ALEN); /* SA */
+		break;
+	case 0:
+		memcpy(hdr, hdr11->addr1, ETH_ALEN); /* DA */
+		memcpy(hdr + ETH_ALEN, hdr11->addr2, ETH_ALEN); /* SA */
+		break;
+	}
+
+	hdr[12] = 0; /* priority */
+	hdr[13] = hdr[14] = hdr[15] = 0; /* reserved */
+}
+
+
+static int ieee80211_michael_mic_add(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct ieee80211_tkip_data *tkey = priv;
+	u8 *pos;
+
+	if (skb_tailroom(skb) < 8 || skb->len < hdr_len) {
+		printk(KERN_DEBUG "Invalid packet for Michael MIC add "
+		       "(tailroom=%d hdr_len=%d skb->len=%d)\n",
+		       skb_tailroom(skb), hdr_len, skb->len);
+		return -1;
+	}
+
+	michael_mic_hdr(skb, tkey->tx_hdr);
+	pos = skb_put(skb, 8);
+	if (michael_mic(tkey, &tkey->key[16], tkey->tx_hdr,
+			skb->data + hdr_len, skb->len - 8 - hdr_len, pos))
+		return -1;
+
+	return 0;
+}
+
+
+#if WIRELESS_EXT >= 18
+static void ieee80211_michael_mic_failure(struct net_device *dev,
+				       struct ieee80211_hdr *hdr,
+				       int keyidx)
+{
+	union iwreq_data wrqu;
+	struct iw_michaelmicfailure ev;
+
+	/* TODO: needed parameters: count, keyid, key type, TSC */
+	memset(&ev, 0, sizeof(ev));
+	ev.flags = keyidx & IW_MICFAILURE_KEY_ID;
+	if (hdr->addr1[0] & 0x01)
+		ev.flags |= IW_MICFAILURE_GROUP;
+	else
+		ev.flags |= IW_MICFAILURE_PAIRWISE;
+	ev.src_addr.sa_family = ARPHRD_ETHER;
+	memcpy(ev.src_addr.sa_data, hdr->addr2, ETH_ALEN);
+	memset(&wrqu, 0, sizeof(wrqu));
+	wrqu.data.length = sizeof(ev);
+	wireless_send_event(dev, IWEVMICHAELMICFAILURE, &wrqu, (char *) &ev);
+}
+#elif WIRELESS_EXT >= 15
+static void ieee80211_michael_mic_failure(struct net_device *dev,
+				       struct ieee80211_hdr *hdr,
+				       int keyidx)
+{
+	union iwreq_data wrqu;
+	char buf[128];
+
+	/* TODO: needed parameters: count, keyid, key type, TSC */
+	sprintf(buf, "MLME-MICHAELMICFAILURE.indication(keyid=%d %scast addr="
+		MAC_FMT ")", keyidx, hdr->addr1[0] & 0x01 ? "broad" : "uni",
+		MAC_ARG(hdr->addr2));
+	memset(&wrqu, 0, sizeof(wrqu));
+	wrqu.data.length = strlen(buf);
+	wireless_send_event(dev, IWEVCUSTOM, &wrqu, buf);
+}
+#else /* WIRELESS_EXT >= 15 */
+static inline void ieee80211_michael_mic_failure(struct net_device *dev,
+					      struct ieee80211_hdr *hdr,
+					      int keyidx)
+{
+}
+#endif /* WIRELESS_EXT >= 15 */
+
+
+static int ieee80211_michael_mic_verify(struct sk_buff *skb, int keyidx,
+				     int hdr_len, void *priv)
+{
+	struct ieee80211_tkip_data *tkey = priv;
+	u8 mic[8];
+
+	if (!tkey->key_set)
+		return -1;
+
+	michael_mic_hdr(skb, tkey->rx_hdr);
+	if (michael_mic(tkey, &tkey->key[24], tkey->rx_hdr,
+			skb->data + hdr_len, skb->len - 8 - hdr_len, mic))
+		return -1;
+	if (memcmp(mic, skb->data + skb->len - 8, 8) != 0) {
+		struct ieee80211_hdr *hdr;
+		hdr = (struct ieee80211_hdr *) skb->data;
+		printk(KERN_DEBUG "%s: Michael MIC verification failed for "
+		       "MSDU from " MAC_FMT " keyidx=%d\n",
+		       skb->dev ? skb->dev->name : "N/A", MAC_ARG(hdr->addr2),
+		       keyidx);
+		if (skb->dev)
+			ieee80211_michael_mic_failure(skb->dev, hdr, keyidx);
+		tkey->dot11RSNAStatsTKIPLocalMICFailures++;
+		return -1;
+	}
+
+	/* Update TSC counters for RX now that the packet verification has
+	 * completed. */
+	tkey->rx_iv32 = tkey->rx_iv32_new;
+	tkey->rx_iv16 = tkey->rx_iv16_new;
+
+	skb_trim(skb, skb->len - 8);
+
+	return 0;
+}
+
+
+static int ieee80211_tkip_set_key(void *key, int len, u8 *seq, void *priv)
+{
+	struct ieee80211_tkip_data *tkey = priv;
+	int keyidx;
+	struct crypto_tfm *tfm = tkey->tfm_michael;
+	struct crypto_tfm *tfm2 = tkey->tfm_arc4;
+
+	keyidx = tkey->key_idx;
+	memset(tkey, 0, sizeof(*tkey));
+	tkey->key_idx = keyidx;
+	tkey->tfm_michael = tfm;
+	tkey->tfm_arc4 = tfm2;
+	if (len == TKIP_KEY_LEN) {
+		memcpy(tkey->key, key, TKIP_KEY_LEN);
+		tkey->key_set = 1;
+		tkey->tx_iv16 = 1; /* TSC is initialized to 1 */
+		if (seq) {
+			tkey->rx_iv32 = (seq[5] << 24) | (seq[4] << 16) |
+				(seq[3] << 8) | seq[2];
+			tkey->rx_iv16 = (seq[1] << 8) | seq[0];
+		}
+	} else if (len == 0)
+		tkey->key_set = 0;
+	else
+		return -1;
+
+	return 0;
+}
+
+
+static int ieee80211_tkip_get_key(void *key, int len, u8 *seq, void *priv)
+{
+	struct ieee80211_tkip_data *tkey = priv;
+
+	if (len < TKIP_KEY_LEN)
+		return -1;
+
+	if (!tkey->key_set)
+		return 0;
+	memcpy(key, tkey->key, TKIP_KEY_LEN);
+
+	if (seq) {
+		/* Return the sequence number of the last transmitted frame. */
+		u16 iv16 = tkey->tx_iv16;
+		u32 iv32 = tkey->tx_iv32;
+		if (iv16 == 0)
+			iv32--;
+		iv16--;
+		seq[0] = tkey->tx_iv16;
+		seq[1] = tkey->tx_iv16 >> 8;
+		seq[2] = tkey->tx_iv32;
+		seq[3] = tkey->tx_iv32 >> 8;
+		seq[4] = tkey->tx_iv32 >> 16;
+		seq[5] = tkey->tx_iv32 >> 24;
+	}
+
+	return TKIP_KEY_LEN;
+}
+
+
+static char * ieee80211_tkip_print_stats(char *p, void *priv)
+{
+	struct ieee80211_tkip_data *tkip = priv;
+	p += sprintf(p, "key[%d] alg=TKIP key_set=%d "
+		     "tx_pn=%02x%02x%02x%02x%02x%02x "
+		     "rx_pn=%02x%02x%02x%02x%02x%02x "
+		     "replays=%d icv_errors=%d local_mic_failures=%d\n",
+		     tkip->key_idx, tkip->key_set,
+		     (tkip->tx_iv32 >> 24) & 0xff,
+		     (tkip->tx_iv32 >> 16) & 0xff,
+		     (tkip->tx_iv32 >> 8) & 0xff,
+		     tkip->tx_iv32 & 0xff,
+		     (tkip->tx_iv16 >> 8) & 0xff,
+		     tkip->tx_iv16 & 0xff,
+		     (tkip->rx_iv32 >> 24) & 0xff,
+		     (tkip->rx_iv32 >> 16) & 0xff,
+		     (tkip->rx_iv32 >> 8) & 0xff,
+		     tkip->rx_iv32 & 0xff,
+		     (tkip->rx_iv16 >> 8) & 0xff,
+		     tkip->rx_iv16 & 0xff,
+		     tkip->dot11RSNAStatsTKIPReplays,
+		     tkip->dot11RSNAStatsTKIPICVErrors,
+		     tkip->dot11RSNAStatsTKIPLocalMICFailures);
+	return p;
+}
+
+
+static struct ieee80211_crypto_ops ieee80211_crypt_tkip = {
+	.name			= "TKIP",
+	.init			= ieee80211_tkip_init,
+	.deinit			= ieee80211_tkip_deinit,
+	.encrypt_mpdu		= ieee80211_tkip_encrypt,
+	.decrypt_mpdu		= ieee80211_tkip_decrypt,
+	.encrypt_msdu		= ieee80211_michael_mic_add,
+	.decrypt_msdu		= ieee80211_michael_mic_verify,
+	.set_key		= ieee80211_tkip_set_key,
+	.get_key		= ieee80211_tkip_get_key,
+	.print_stats		= ieee80211_tkip_print_stats,
+	.extra_prefix_len	= 4 + 4, /* IV + ExtIV */
+	.extra_postfix_len	= 8 + 4, /* MIC + ICV */
+	.owner		        = THIS_MODULE,
+};
+
+
+static int __init ieee80211_crypto_tkip_init(void)
+{
+	if (ieee80211_register_crypto_ops(&ieee80211_crypt_tkip) < 0)
+		return -1;
+
+	return 0;
+}
+
+
+static void __exit ieee80211_crypto_tkip_exit(void)
+{
+	ieee80211_unregister_crypto_ops(&ieee80211_crypt_tkip);
+}
+
+
+module_init(ieee80211_crypto_tkip_init);
+module_exit(ieee80211_crypto_tkip_exit);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_crypt_wep.c netdev-2.6-ipw/net/ieee80211/ieee80211_crypt_wep.c
--- netdev-2.6/net/ieee80211/ieee80211_crypt_wep.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_crypt_wep.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,275 @@
+/*
+ * Host AP crypt: host-based WEP encryption implementation for Host AP driver
+ *
+ * Copyright (c) 2002-2004, Jouni Malinen <jkmaline@cc.hut.fi>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/random.h>
+#include <linux/skbuff.h>
+#include <asm/string.h>
+
+#include <net/ieee80211.h>
+
+
+#include <linux/crypto.h>
+#include <asm/scatterlist.h>
+#include <linux/crc32.h>
+
+MODULE_AUTHOR("Jouni Malinen");
+MODULE_DESCRIPTION("Host AP crypt: WEP");
+MODULE_LICENSE("GPL");
+
+
+struct prism2_wep_data {
+	u32 iv;
+#define WEP_KEY_LEN 13
+	u8 key[WEP_KEY_LEN + 1];
+	u8 key_len;
+	u8 key_idx;
+	struct crypto_tfm *tfm;
+};
+
+
+static void * prism2_wep_init(int keyidx)
+{
+	struct prism2_wep_data *priv;
+
+	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
+	if (priv == NULL)
+		goto fail;
+	memset(priv, 0, sizeof(*priv));
+	priv->key_idx = keyidx;
+
+	priv->tfm = crypto_alloc_tfm("arc4", 0);
+	if (priv->tfm == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_wep: could not allocate "
+		       "crypto API arc4\n");
+		goto fail;
+	}
+
+	/* start WEP IV from a random value */
+	get_random_bytes(&priv->iv, 4);
+
+	return priv;
+
+fail:
+	if (priv) {
+		if (priv->tfm)
+			crypto_free_tfm(priv->tfm);
+		kfree(priv);
+	}
+	return NULL;
+}
+
+
+static void prism2_wep_deinit(void *priv)
+{
+	struct prism2_wep_data *_priv = priv;
+	if (_priv && _priv->tfm)
+		crypto_free_tfm(_priv->tfm);
+	kfree(priv);
+}
+
+
+/* Perform WEP encryption on given skb that has at least 4 bytes of headroom
+ * for IV and 4 bytes of tailroom for ICV. Both IV and ICV will be transmitted,
+ * so the payload length increases with 8 bytes.
+ *
+ * WEP frame payload: IV + TX key idx, RC4(data), ICV = RC4(CRC32(data))
+ */
+static int prism2_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct prism2_wep_data *wep = priv;
+	u32 crc, klen, len;
+	u8 key[WEP_KEY_LEN + 3];
+	u8 *pos, *icv;
+	struct scatterlist sg;
+
+	if (skb_headroom(skb) < 4 || skb_tailroom(skb) < 4 ||
+	    skb->len < hdr_len)
+		return -1;
+
+	len = skb->len - hdr_len;
+	pos = skb_push(skb, 4);
+	memmove(pos, pos + 4, hdr_len);
+	pos += hdr_len;
+
+	klen = 3 + wep->key_len;
+
+	wep->iv++;
+
+	/* Fluhrer, Mantin, and Shamir have reported weaknesses in the key
+	 * scheduling algorithm of RC4. At least IVs (KeyByte + 3, 0xff, N)
+	 * can be used to speedup attacks, so avoid using them. */
+	if ((wep->iv & 0xff00) == 0xff00) {
+		u8 B = (wep->iv >> 16) & 0xff;
+		if (B >= 3 && B < klen)
+			wep->iv += 0x0100;
+	}
+
+	/* Prepend 24-bit IV to RC4 key and TX frame */
+	*pos++ = key[0] = (wep->iv >> 16) & 0xff;
+	*pos++ = key[1] = (wep->iv >> 8) & 0xff;
+	*pos++ = key[2] = wep->iv & 0xff;
+	*pos++ = wep->key_idx << 6;
+
+	/* Copy rest of the WEP key (the secret part) */
+	memcpy(key + 3, wep->key, wep->key_len);
+
+	/* Append little-endian CRC32 and encrypt it to produce ICV */
+	crc = ~crc32_le(~0, pos, len);
+	icv = skb_put(skb, 4);
+	icv[0] = crc;
+	icv[1] = crc >> 8;
+	icv[2] = crc >> 16;
+	icv[3] = crc >> 24;
+
+	crypto_cipher_setkey(wep->tfm, key, klen);
+	sg.page = virt_to_page(pos);
+	sg.offset = offset_in_page(pos);
+	sg.length = len + 4;
+	crypto_cipher_encrypt(wep->tfm, &sg, &sg, len + 4);
+
+	return 0;
+}
+
+
+/* Perform WEP decryption on given buffer. Buffer includes whole WEP part of
+ * the frame: IV (4 bytes), encrypted payload (including SNAP header),
+ * ICV (4 bytes). len includes both IV and ICV.
+ *
+ * Returns 0 if frame was decrypted successfully and ICV was correct and -1 on
+ * failure. If frame is OK, IV and ICV will be removed.
+ */
+static int prism2_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
+{
+	struct prism2_wep_data *wep = priv;
+	u32 crc, klen, plen;
+	u8 key[WEP_KEY_LEN + 3];
+	u8 keyidx, *pos, icv[4];
+	struct scatterlist sg;
+
+	if (skb->len < hdr_len + 8)
+		return -1;
+
+	pos = skb->data + hdr_len;
+	key[0] = *pos++;
+	key[1] = *pos++;
+	key[2] = *pos++;
+	keyidx = *pos++ >> 6;
+	if (keyidx != wep->key_idx)
+		return -1;
+
+	klen = 3 + wep->key_len;
+
+	/* Copy rest of the WEP key (the secret part) */
+	memcpy(key + 3, wep->key, wep->key_len);
+
+	/* Apply RC4 to data and compute CRC32 over decrypted data */
+	plen = skb->len - hdr_len - 8;
+
+	crypto_cipher_setkey(wep->tfm, key, klen);
+	sg.page = virt_to_page(pos);
+	sg.offset = offset_in_page(pos);
+	sg.length = plen + 4;
+	crypto_cipher_decrypt(wep->tfm, &sg, &sg, plen + 4);
+
+	crc = ~crc32_le(~0, pos, plen);
+	icv[0] = crc;
+	icv[1] = crc >> 8;
+	icv[2] = crc >> 16;
+	icv[3] = crc >> 24;
+	if (memcmp(icv, pos + plen, 4) != 0) {
+		/* ICV mismatch - drop frame */
+		return -2;
+	}
+
+	/* Remove IV and ICV */
+	memmove(skb->data + 4, skb->data, hdr_len);
+	skb_pull(skb, 4);
+	skb_trim(skb, skb->len - 4);
+
+	return 0;
+}
+
+
+static int prism2_wep_set_key(void *key, int len, u8 *seq, void *priv)
+{
+	struct prism2_wep_data *wep = priv;
+
+	if (len < 0 || len > WEP_KEY_LEN)
+		return -1;
+
+	memcpy(wep->key, key, len);
+	wep->key_len = len;
+
+	return 0;
+}
+
+
+static int prism2_wep_get_key(void *key, int len, u8 *seq, void *priv)
+{
+	struct prism2_wep_data *wep = priv;
+
+	if (len < wep->key_len)
+		return -1;
+
+	memcpy(key, wep->key, wep->key_len);
+
+	return wep->key_len;
+}
+
+
+static char * prism2_wep_print_stats(char *p, void *priv)
+{
+	struct prism2_wep_data *wep = priv;
+	p += sprintf(p, "key[%d] alg=WEP len=%d\n",
+		     wep->key_idx, wep->key_len);
+	return p;
+}
+
+
+static struct ieee80211_crypto_ops ieee80211_crypt_wep = {
+	.name			= "WEP",
+	.init			= prism2_wep_init,
+	.deinit			= prism2_wep_deinit,
+	.encrypt_mpdu		= prism2_wep_encrypt,
+	.decrypt_mpdu		= prism2_wep_decrypt,
+	.encrypt_msdu		= NULL,
+	.decrypt_msdu		= NULL,
+	.set_key		= prism2_wep_set_key,
+	.get_key		= prism2_wep_get_key,
+	.print_stats		= prism2_wep_print_stats,
+	.extra_prefix_len	= 4, /* IV */
+	.extra_postfix_len	= 4, /* ICV */
+	.owner			= THIS_MODULE,
+};
+
+
+static int __init ieee80211_crypto_wep_init(void)
+{
+	if (ieee80211_register_crypto_ops(&ieee80211_crypt_wep) < 0)
+		return -1;
+
+	return 0;
+}
+
+
+static void __exit ieee80211_crypto_wep_exit(void)
+{
+	ieee80211_unregister_crypto_ops(&ieee80211_crypt_wep);
+}
+
+
+module_init(ieee80211_crypto_wep_init);
+module_exit(ieee80211_crypto_wep_exit);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_module.c netdev-2.6-ipw/net/ieee80211/ieee80211_module.c
--- netdev-2.6/net/ieee80211/ieee80211_module.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_module.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,268 @@
+/*******************************************************************************
+
+  Copyright(c) 2004 Intel Corporation. All rights reserved.
+
+  Portions of this file are based on the WEP enablement code provided by the
+  Host AP project hostap-drivers v0.1.3
+  Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+  <jkmaline@cc.hut.fi>
+  Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of version 2 of the GNU General Public License as
+  published by the Free Software Foundation.
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc., 59
+  Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+  The full GNU General Public License is included in this distribution in the
+  file called LICENSE.
+
+  Contact Information:
+  James P. Ketrenos <ipw2100-admin@linux.intel.com>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/compiler.h>
+#include <linux/config.h>
+#include <linux/errno.h>
+#include <linux/if_arp.h>
+#include <linux/in6.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/types.h>
+#include <linux/version.h>
+#include <linux/wireless.h>
+#include <linux/etherdevice.h>
+#include <asm/uaccess.h>
+#include <net/arp.h>
+
+#include <net/ieee80211.h>
+
+MODULE_DESCRIPTION("802.11 data/management/control stack");
+MODULE_AUTHOR("Copyright (C) 2004 Intel Corporation <jketreno@linux.intel.com>");
+MODULE_LICENSE("GPL");
+
+#define DRV_NAME "ieee80211"
+
+static inline int ieee80211_networks_allocate(struct ieee80211_device *ieee)
+{
+	if (ieee->networks)
+		return 0;
+
+	ieee->networks = kmalloc(
+		MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
+		GFP_KERNEL);
+	if (!ieee->networks) {
+		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
+		       ieee->dev->name);
+		return -ENOMEM;
+	}
+
+	memset(ieee->networks, 0,
+	       MAX_NETWORK_COUNT * sizeof(struct ieee80211_network));
+
+	return 0;
+}
+
+static inline void ieee80211_networks_free(struct ieee80211_device *ieee)
+{
+	if (!ieee->networks)
+		return;
+	kfree(ieee->networks);
+	ieee->networks = NULL;
+}
+
+static inline void ieee80211_networks_initialize(struct ieee80211_device *ieee)
+{
+	int i;
+
+	INIT_LIST_HEAD(&ieee->network_free_list);
+	INIT_LIST_HEAD(&ieee->network_list);
+	for (i = 0; i < MAX_NETWORK_COUNT; i++)
+		list_add_tail(&ieee->networks[i].list, &ieee->network_free_list);
+}
+
+
+struct net_device *alloc_ieee80211(int sizeof_priv)
+{
+	struct ieee80211_device *ieee;
+	struct net_device *dev;
+	int err;
+
+	IEEE80211_DEBUG_INFO("Initializing...\n");
+
+	dev = alloc_etherdev(sizeof(struct ieee80211_device) + sizeof_priv);
+	if (!dev) {
+		IEEE80211_ERROR("Unable to network device.\n");
+		goto failed;
+	}
+	ieee = netdev_priv(dev);
+	dev->hard_start_xmit = ieee80211_xmit;
+
+	ieee->dev = dev;
+
+	err = ieee80211_networks_allocate(ieee);
+	if (err) {
+		IEEE80211_ERROR("Unable to allocate beacon storage: %d\n",
+				err);
+		goto failed;
+	}
+	ieee80211_networks_initialize(ieee);
+
+	/* Default fragmentation threshold is maximum payload size */
+	ieee->fts = DEFAULT_FTS;
+	ieee->scan_age = DEFAULT_MAX_SCAN_AGE;
+	ieee->open_wep = 1;
+
+	/* Default to enabling full open WEP with host based encrypt/decrypt */
+	ieee->host_encrypt = 1;
+	ieee->host_decrypt = 1;
+	ieee->ieee802_1x = 1; /* Default to supporting 802.1x */
+
+	INIT_LIST_HEAD(&ieee->crypt_deinit_list);
+	init_timer(&ieee->crypt_deinit_timer);
+	ieee->crypt_deinit_timer.data = (unsigned long)ieee;
+	ieee->crypt_deinit_timer.function = ieee80211_crypt_deinit_handler;
+
+	spin_lock_init(&ieee->lock);
+
+ 	ieee->wpa_enabled = 0;
+ 	ieee->tkip_countermeasures = 0;
+ 	ieee->drop_unencrypted = 0;
+ 	ieee->privacy_invoked = 0;
+ 	ieee->ieee802_1x = 1;
+
+	return dev;
+
+ failed:
+	if (dev)
+		free_netdev(dev);
+	return NULL;
+}
+
+
+void free_ieee80211(struct net_device *dev)
+{
+	struct ieee80211_device *ieee = netdev_priv(dev);
+
+	int i;
+
+	del_timer_sync(&ieee->crypt_deinit_timer);
+	ieee80211_crypt_deinit_entries(ieee, 1);
+
+	for (i = 0; i < WEP_KEYS; i++) {
+		struct ieee80211_crypt_data *crypt = ieee->crypt[i];
+		if (crypt) {
+			if (crypt->ops) {
+				crypt->ops->deinit(crypt->priv);
+				module_put(crypt->ops->owner);
+			}
+			kfree(crypt);
+			ieee->crypt[i] = NULL;
+		}
+	}
+
+	ieee80211_networks_free(ieee);
+	free_netdev(dev);
+}
+
+#ifdef CONFIG_IEEE80211_DEBUG
+
+static int debug = 0;
+u32 ieee80211_debug_level = 0;
+struct proc_dir_entry *ieee80211_proc = NULL;
+
+static int show_debug_level(char *page, char **start, off_t offset,
+			    int count, int *eof, void *data)
+{
+	return snprintf(page, count, "0x%08X\n", ieee80211_debug_level);
+}
+
+static int store_debug_level(struct file *file, const char *buffer,
+			     unsigned long count, void *data)
+{
+	char buf[] = "0x00000000";
+	unsigned long len = min(sizeof(buf) - 1, (u32)count);
+	char *p = (char *)buf;
+	unsigned long val;
+
+	if (copy_from_user(buf, buffer, len))
+		return count;
+	buf[len] = 0;
+	if (p[1] == 'x' || p[1] == 'X' || p[0] == 'x' || p[0] == 'X') {
+		p++;
+		if (p[0] == 'x' || p[0] == 'X')
+			p++;
+		val = simple_strtoul(p, &p, 16);
+	} else
+		val = simple_strtoul(p, &p, 10);
+	if (p == buf)
+		printk(KERN_INFO DRV_NAME
+		       ": %s is not in hex or decimal form.\n", buf);
+	else
+		ieee80211_debug_level = val;
+
+	return strnlen(buf, count);
+}
+
+static int __init ieee80211_init(void)
+{
+	struct proc_dir_entry *e;
+
+	ieee80211_debug_level = debug;
+	ieee80211_proc = create_proc_entry(DRV_NAME, S_IFDIR, proc_net);
+	if (ieee80211_proc == NULL) {
+		IEEE80211_ERROR("Unable to create " DRV_NAME
+				" proc directory\n");
+		return -EIO;
+	}
+	e = create_proc_entry("debug_level", S_IFREG | S_IRUGO | S_IWUSR,
+			      ieee80211_proc);
+	if (!e) {
+		remove_proc_entry(DRV_NAME, proc_net);
+		ieee80211_proc = NULL;
+		return -EIO;
+	}
+	e->read_proc = show_debug_level;
+	e->write_proc = store_debug_level;
+	e->data = NULL;
+
+	return 0;
+}
+
+static void __exit ieee80211_exit(void)
+{
+	if (ieee80211_proc) {
+		remove_proc_entry("debug_level", ieee80211_proc);
+		remove_proc_entry(DRV_NAME, proc_net);
+		ieee80211_proc = NULL;
+	}
+}
+
+#include <linux/moduleparam.h>
+module_param(debug, int, 0444);
+MODULE_PARM_DESC(debug, "debug output mask");
+
+
+module_exit(ieee80211_exit);
+module_init(ieee80211_init);
+#endif
+
+EXPORT_SYMBOL(alloc_ieee80211);
+EXPORT_SYMBOL(free_ieee80211);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_rx.c netdev-2.6-ipw/net/ieee80211/ieee80211_rx.c
--- netdev-2.6/net/ieee80211/ieee80211_rx.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_rx.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,1206 @@
+/*
+ * Original code based Host AP (software wireless LAN access point) driver
+ * for Intersil Prism2/2.5/3 - hostap.o module, common routines
+ *
+ * Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+ * <jkmaline@cc.hut.fi>
+ * Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ * Copyright (c) 2004, Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation. See README and COPYING for
+ * more details.
+ */
+
+#include <linux/compiler.h>
+#include <linux/config.h>
+#include <linux/errno.h>
+#include <linux/if_arp.h>
+#include <linux/in6.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/types.h>
+#include <linux/version.h>
+#include <linux/wireless.h>
+#include <linux/etherdevice.h>
+#include <asm/uaccess.h>
+#include <linux/ctype.h>
+
+#include <net/ieee80211.h>
+
+static inline void ieee80211_monitor_rx(struct ieee80211_device *ieee,
+					struct sk_buff *skb,
+					struct ieee80211_rx_stats *rx_stats)
+{
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	u16 fc = le16_to_cpu(hdr->frame_ctl);
+
+	skb->dev = ieee->dev;
+	skb->mac.raw = skb->data;
+	skb_pull(skb, ieee80211_get_hdrlen(fc));
+	skb->pkt_type = PACKET_OTHERHOST;
+	skb->protocol = __constant_htons(ETH_P_80211_RAW);
+	memset(skb->cb, 0, sizeof(skb->cb));
+	netif_rx(skb);
+}
+
+
+/* Called only as a tasklet (software IRQ) */
+static struct ieee80211_frag_entry *
+ieee80211_frag_cache_find(struct ieee80211_device *ieee, unsigned int seq,
+			  unsigned int frag, u8 *src, u8 *dst)
+{
+	struct ieee80211_frag_entry *entry;
+	int i;
+
+	for (i = 0; i < IEEE80211_FRAG_CACHE_LEN; i++) {
+		entry = &ieee->frag_cache[i];
+		if (entry->skb != NULL &&
+		    time_after(jiffies, entry->first_frag_time + 2 * HZ)) {
+			IEEE80211_DEBUG_FRAG(
+				"expiring fragment cache entry "
+				"seq=%u last_frag=%u\n",
+				entry->seq, entry->last_frag);
+			dev_kfree_skb_any(entry->skb);
+			entry->skb = NULL;
+		}
+
+		if (entry->skb != NULL && entry->seq == seq &&
+		    (entry->last_frag + 1 == frag || frag == -1) &&
+		    memcmp(entry->src_addr, src, ETH_ALEN) == 0 &&
+		    memcmp(entry->dst_addr, dst, ETH_ALEN) == 0)
+			return entry;
+	}
+
+	return NULL;
+}
+
+/* Called only as a tasklet (software IRQ) */
+static struct sk_buff *
+ieee80211_frag_cache_get(struct ieee80211_device *ieee,
+			 struct ieee80211_hdr *hdr)
+{
+	struct sk_buff *skb = NULL;
+	u16 sc;
+	unsigned int frag, seq;
+	struct ieee80211_frag_entry *entry;
+
+	sc = le16_to_cpu(hdr->seq_ctl);
+	frag = WLAN_GET_SEQ_FRAG(sc);
+	seq = WLAN_GET_SEQ_SEQ(sc);
+
+	if (frag == 0) {
+		/* Reserve enough space to fit maximum frame length */
+		skb = dev_alloc_skb(ieee->dev->mtu +
+				    sizeof(struct ieee80211_hdr) +
+				    8 /* LLC */ +
+				    2 /* alignment */ +
+				    8 /* WEP */ + ETH_ALEN /* WDS */);
+		if (skb == NULL)
+			return NULL;
+
+		entry = &ieee->frag_cache[ieee->frag_next_idx];
+		ieee->frag_next_idx++;
+		if (ieee->frag_next_idx >= IEEE80211_FRAG_CACHE_LEN)
+			ieee->frag_next_idx = 0;
+
+		if (entry->skb != NULL)
+			dev_kfree_skb_any(entry->skb);
+
+		entry->first_frag_time = jiffies;
+		entry->seq = seq;
+		entry->last_frag = frag;
+		entry->skb = skb;
+		memcpy(entry->src_addr, hdr->addr2, ETH_ALEN);
+		memcpy(entry->dst_addr, hdr->addr1, ETH_ALEN);
+	} else {
+		/* received a fragment of a frame for which the head fragment
+		 * should have already been received */
+		entry = ieee80211_frag_cache_find(ieee, seq, frag, hdr->addr2,
+						  hdr->addr1);
+		if (entry != NULL) {
+			entry->last_frag = frag;
+			skb = entry->skb;
+		}
+	}
+
+	return skb;
+}
+
+
+/* Called only as a tasklet (software IRQ) */
+static int ieee80211_frag_cache_invalidate(struct ieee80211_device *ieee,
+					   struct ieee80211_hdr *hdr)
+{
+	u16 sc;
+	unsigned int seq;
+	struct ieee80211_frag_entry *entry;
+
+	sc = le16_to_cpu(hdr->seq_ctl);
+	seq = WLAN_GET_SEQ_SEQ(sc);
+
+	entry = ieee80211_frag_cache_find(ieee, seq, -1, hdr->addr2,
+					  hdr->addr1);
+
+	if (entry == NULL) {
+		IEEE80211_DEBUG_FRAG(
+			"could not invalidate fragment cache "
+			"entry (seq=%u)\n", seq);
+		return -1;
+	}
+
+	entry->skb = NULL;
+	return 0;
+}
+
+
+#ifdef NOT_YET
+/* ieee80211_rx_frame_mgtmt
+ *
+ * Responsible for handling management control frames
+ *
+ * Called by ieee80211_rx */
+static inline int
+ieee80211_rx_frame_mgmt(struct ieee80211_device *ieee, struct sk_buff *skb,
+			struct ieee80211_rx_stats *rx_stats, u16 type,
+			u16 stype)
+{
+	if (ieee->iw_mode == IW_MODE_MASTER) {
+		printk(KERN_DEBUG "%s: Master mode not yet suppported.\n",
+		       ieee->dev->name);
+		return 0;
+/*
+  hostap_update_sta_ps(ieee, (struct hostap_ieee80211_hdr *)
+  skb->data);*/
+	}
+
+	if (ieee->hostapd && type == WLAN_FC_TYPE_MGMT) {
+		if (stype == WLAN_FC_STYPE_BEACON &&
+		    ieee->iw_mode == IW_MODE_MASTER) {
+			struct sk_buff *skb2;
+			/* Process beacon frames also in kernel driver to
+			 * update STA(AP) table statistics */
+			skb2 = skb_clone(skb, GFP_ATOMIC);
+			if (skb2)
+				hostap_rx(skb2->dev, skb2, rx_stats);
+		}
+
+		/* send management frames to the user space daemon for
+		 * processing */
+		ieee->apdevstats.rx_packets++;
+		ieee->apdevstats.rx_bytes += skb->len;
+		prism2_rx_80211(ieee->apdev, skb, rx_stats, PRISM2_RX_MGMT);
+		return 0;
+	}
+
+	    if (ieee->iw_mode == IW_MODE_MASTER) {
+		if (type != WLAN_FC_TYPE_MGMT && type != WLAN_FC_TYPE_CTRL) {
+			printk(KERN_DEBUG "%s: unknown management frame "
+			       "(type=0x%02x, stype=0x%02x) dropped\n",
+			       skb->dev->name, type, stype);
+			return -1;
+		}
+
+		hostap_rx(skb->dev, skb, rx_stats);
+		return 0;
+	}
+
+	printk(KERN_DEBUG "%s: hostap_rx_frame_mgmt: management frame "
+	       "received in non-Host AP mode\n", skb->dev->name);
+	return -1;
+}
+#endif
+
+
+/* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
+/* Ethernet-II snap header (RFC1042 for most EtherTypes) */
+static unsigned char rfc1042_header[] =
+{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
+/* Bridge-Tunnel header (for EtherTypes ETH_P_AARP and ETH_P_IPX) */
+static unsigned char bridge_tunnel_header[] =
+{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
+/* No encapsulation header if EtherType < 0x600 (=length) */
+
+/* Called by ieee80211_rx_frame_decrypt */
+static int ieee80211_is_eapol_frame(struct ieee80211_device *ieee,
+				    struct sk_buff *skb)
+{
+	struct net_device *dev = ieee->dev;
+	u16 fc, ethertype;
+	struct ieee80211_hdr *hdr;
+	u8 *pos;
+
+	if (skb->len < 24)
+		return 0;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	fc = le16_to_cpu(hdr->frame_ctl);
+
+	/* check that the frame is unicast frame to us */
+	if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
+	    IEEE80211_FCTL_TODS &&
+	    memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0 &&
+	    memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0) {
+		/* ToDS frame with own addr BSSID and DA */
+	} else if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
+		   IEEE80211_FCTL_FROMDS &&
+		   memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0) {
+		/* FromDS frame with own addr as DA */
+	} else
+		return 0;
+
+	if (skb->len < 24 + 8)
+		return 0;
+
+	/* check for port access entity Ethernet type */
+	pos = skb->data + 24;
+	ethertype = (pos[6] << 8) | pos[7];
+	if (ethertype == ETH_P_PAE)
+		return 1;
+
+	return 0;
+}
+
+/* Called only as a tasklet (software IRQ), by ieee80211_rx */
+static inline int
+ieee80211_rx_frame_decrypt(struct ieee80211_device* ieee, struct sk_buff *skb,
+			   struct ieee80211_crypt_data *crypt)
+{
+	struct ieee80211_hdr *hdr;
+	int res, hdrlen;
+
+	if (crypt == NULL || crypt->ops->decrypt_mpdu == NULL)
+		return 0;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	hdrlen = ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
+
+#ifdef CONFIG_IEEE80211_CRYPT_TKIP
+	if (ieee->tkip_countermeasures &&
+	    strcmp(crypt->ops->name, "TKIP") == 0) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
+			       "received packet from " MAC_FMT "\n",
+			       ieee->dev->name, MAC_ARG(hdr->addr2));
+		}
+		return -1;
+	}
+#endif
+
+	atomic_inc(&crypt->refcnt);
+	res = crypt->ops->decrypt_mpdu(skb, hdrlen, crypt->priv);
+	atomic_dec(&crypt->refcnt);
+	if (res < 0) {
+		IEEE80211_DEBUG_DROP(
+			"decryption failed (SA=" MAC_FMT
+			") res=%d\n", MAC_ARG(hdr->addr2), res);
+		if (res == -2)
+			IEEE80211_DEBUG_DROP("Decryption failed ICV "
+					     "mismatch (key %d)\n",
+					     skb->data[hdrlen + 3] >> 6);
+		ieee->ieee_stats.rx_discards_undecryptable++;
+		return -1;
+	}
+
+	return res;
+}
+
+
+/* Called only as a tasklet (software IRQ), by ieee80211_rx */
+static inline int
+ieee80211_rx_frame_decrypt_msdu(struct ieee80211_device* ieee, struct sk_buff *skb,
+			     int keyidx, struct ieee80211_crypt_data *crypt)
+{
+	struct ieee80211_hdr *hdr;
+	int res, hdrlen;
+
+	if (crypt == NULL || crypt->ops->decrypt_msdu == NULL)
+		return 0;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	hdrlen = ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
+
+	atomic_inc(&crypt->refcnt);
+	res = crypt->ops->decrypt_msdu(skb, keyidx, hdrlen, crypt->priv);
+	atomic_dec(&crypt->refcnt);
+	if (res < 0) {
+		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
+		       " (SA=" MAC_FMT " keyidx=%d)\n",
+		       ieee->dev->name, MAC_ARG(hdr->addr2), keyidx);
+		return -1;
+	}
+
+	return 0;
+}
+
+
+/* All received frames are sent to this function. @skb contains the frame in
+ * IEEE 802.11 format, i.e., in the format it was sent over air.
+ * This function is called only as a tasklet (software IRQ). */
+int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
+		 struct ieee80211_rx_stats *rx_stats)
+{
+	struct net_device *dev = ieee->dev;
+	struct ieee80211_hdr *hdr;
+	size_t hdrlen;
+	u16 fc, type, stype, sc;
+	struct net_device_stats *stats;
+	unsigned int frag;
+	u8 *payload;
+	u16 ethertype;
+#ifdef NOT_YET
+	struct net_device *wds = NULL;
+	struct sk_buff *skb2 = NULL;
+	struct net_device *wds = NULL;
+	int frame_authorized = 0;
+	int from_assoc_ap = 0;
+	void *sta = NULL;
+#endif
+	u8 dst[ETH_ALEN];
+	u8 src[ETH_ALEN];
+	struct ieee80211_crypt_data *crypt = NULL;
+	int keyidx = 0;
+
+	hdr = (struct ieee80211_hdr *)skb->data;
+	stats = &ieee->stats;
+
+	if (skb->len < 10) {
+		printk(KERN_INFO "%s: SKB length < 10\n",
+		       dev->name);
+		goto rx_dropped;
+	}
+
+	fc = le16_to_cpu(hdr->frame_ctl);
+	type = WLAN_FC_GET_TYPE(fc);
+	stype = WLAN_FC_GET_STYPE(fc);
+	sc = le16_to_cpu(hdr->seq_ctl);
+	frag = WLAN_GET_SEQ_FRAG(sc);
+	hdrlen = ieee80211_get_hdrlen(fc);
+
+#ifdef NOT_YET
+#if WIRELESS_EXT > 15
+	/* Put this code here so that we avoid duplicating it in all
+	 * Rx paths. - Jean II */
+#ifdef IW_WIRELESS_SPY		/* defined in iw_handler.h */
+	/* If spy monitoring on */
+	if (iface->spy_data.spy_number > 0) {
+		struct iw_quality wstats;
+		wstats.level = rx_stats->signal;
+		wstats.noise = rx_stats->noise;
+		wstats.updated = 6;	/* No qual value */
+		/* Update spy records */
+		wireless_spy_update(dev, hdr->addr2, &wstats);
+	}
+#endif /* IW_WIRELESS_SPY */
+#endif /* WIRELESS_EXT > 15 */
+	hostap_update_rx_stats(local->ap, hdr, rx_stats);
+#endif
+
+#if WIRELESS_EXT > 15
+	if (ieee->iw_mode == IW_MODE_MONITOR) {
+		ieee80211_monitor_rx(ieee, skb, rx_stats);
+		stats->rx_packets++;
+		stats->rx_bytes += skb->len;
+		return 1;
+	}
+#endif
+
+	if (ieee->host_decrypt) {
+		int idx = 0;
+		if (skb->len >= hdrlen + 3)
+			idx = skb->data[hdrlen + 3] >> 6;
+		crypt = ieee->crypt[idx];
+#ifdef NOT_YET
+		sta = NULL;
+
+		/* Use station specific key to override default keys if the
+		 * receiver address is a unicast address ("individual RA"). If
+		 * bcrx_sta_key parameter is set, station specific key is used
+		 * even with broad/multicast targets (this is against IEEE
+		 * 802.11, but makes it easier to use different keys with
+		 * stations that do not support WEP key mapping). */
+
+		if (!(hdr->addr1[0] & 0x01) || local->bcrx_sta_key)
+			(void) hostap_handle_sta_crypto(local, hdr, &crypt,
+							&sta);
+#endif
+
+		/* allow NULL decrypt to indicate an station specific override
+		 * for default encryption */
+		if (crypt && (crypt->ops == NULL ||
+			      crypt->ops->decrypt_mpdu == NULL))
+			crypt = NULL;
+
+		if (!crypt && (fc & IEEE80211_FCTL_WEP)) {
+			/* This seems to be triggered by some (multicast?)
+			 * frames from other than current BSS, so just drop the
+			 * frames silently instead of filling system log with
+			 * these reports. */
+			IEEE80211_DEBUG_DROP("Decryption failed (not set)"
+					     " (SA=" MAC_FMT ")\n",
+					     MAC_ARG(hdr->addr2));
+			ieee->ieee_stats.rx_discards_undecryptable++;
+			goto rx_dropped;
+		}
+	}
+
+#ifdef NOT_YET
+	if (type != WLAN_FC_TYPE_DATA) {
+		if (type == WLAN_FC_TYPE_MGMT && stype == WLAN_FC_STYPE_AUTH &&
+		    fc & IEEE80211_FCTL_WEP && ieee->host_decrypt &&
+		    (keyidx = hostap_rx_frame_decrypt(ieee, skb, crypt)) < 0)
+		{
+			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
+			       "from " MAC_FMT "\n", dev->name,
+			       MAC_ARG(hdr->addr2));
+			/* TODO: could inform hostapd about this so that it
+			 * could send auth failure report */
+			goto rx_dropped;
+		}
+
+		if (ieee80211_rx_frame_mgmt(ieee, skb, rx_stats, type, stype))
+			goto rx_dropped;
+		else
+			goto rx_exit;
+	}
+#endif
+
+	/* Data frame - extract src/dst addresses */
+	if (skb->len < IEEE80211_DATA_HDR3_LEN)
+		goto rx_dropped;
+
+	switch (fc & (IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) {
+	case IEEE80211_FCTL_FROMDS:
+		memcpy(dst, hdr->addr1, ETH_ALEN);
+		memcpy(src, hdr->addr3, ETH_ALEN);
+		break;
+	case IEEE80211_FCTL_TODS:
+		memcpy(dst, hdr->addr3, ETH_ALEN);
+		memcpy(src, hdr->addr2, ETH_ALEN);
+		break;
+	case IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS:
+		if (skb->len < IEEE80211_DATA_HDR4_LEN)
+			goto rx_dropped;
+		memcpy(dst, hdr->addr3, ETH_ALEN);
+		memcpy(src, hdr->addr4, ETH_ALEN);
+		break;
+	case 0:
+		memcpy(dst, hdr->addr1, ETH_ALEN);
+		memcpy(src, hdr->addr2, ETH_ALEN);
+		break;
+	}
+
+#ifdef NOT_YET
+	if (hostap_rx_frame_wds(ieee, hdr, fc, &wds))
+		goto rx_dropped;
+	if (wds) {
+		skb->dev = dev = wds;
+		stats = hostap_get_stats(dev);
+	}
+
+	if (ieee->iw_mode == IW_MODE_MASTER && !wds &&
+	    (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) == IEEE80211_FCTL_FROMDS &&
+	    ieee->stadev &&
+	    memcmp(hdr->addr2, ieee->assoc_ap_addr, ETH_ALEN) == 0) {
+		/* Frame from BSSID of the AP for which we are a client */
+		skb->dev = dev = ieee->stadev;
+		stats = hostap_get_stats(dev);
+		from_assoc_ap = 1;
+	}
+#endif
+
+	dev->last_rx = jiffies;
+
+#ifdef NOT_YET
+	if ((ieee->iw_mode == IW_MODE_MASTER ||
+	     ieee->iw_mode == IW_MODE_REPEAT) &&
+	    !from_assoc_ap) {
+		switch (hostap_handle_sta_rx(ieee, dev, skb, rx_stats,
+					     wds != NULL)) {
+		case AP_RX_CONTINUE_NOT_AUTHORIZED:
+			frame_authorized = 0;
+			break;
+		case AP_RX_CONTINUE:
+			frame_authorized = 1;
+			break;
+		case AP_RX_DROP:
+			goto rx_dropped;
+		case AP_RX_EXIT:
+			goto rx_exit;
+		}
+	}
+#endif
+
+	/* Nullfunc frames may have PS-bit set, so they must be passed to
+	 * hostap_handle_sta_rx() before being dropped here. */
+	if (stype != IEEE80211_STYPE_DATA &&
+	    stype != IEEE80211_STYPE_DATA_CFACK &&
+	    stype != IEEE80211_STYPE_DATA_CFPOLL &&
+	    stype != IEEE80211_STYPE_DATA_CFACKPOLL) {
+		if (stype != IEEE80211_STYPE_NULLFUNC)
+			IEEE80211_DEBUG_DROP(
+				"RX: dropped data frame "
+				"with no data (type=0x%02x, "
+				"subtype=0x%02x, len=%d)\n",
+				type, stype, skb->len);
+		goto rx_dropped;
+	}
+
+	/* skb: hdr + (possibly fragmented, possibly encrypted) payload */
+
+	if (ieee->host_decrypt && (fc & IEEE80211_FCTL_WEP) &&
+	    (keyidx = ieee80211_rx_frame_decrypt(ieee, skb, crypt)) < 0)
+		goto rx_dropped;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+
+	/* skb: hdr + (possibly fragmented) plaintext payload */
+	// PR: FIXME: hostap has additional conditions in the "if" below:
+	// ieee->host_decrypt && (fc & IEEE80211_FCTL_WEP) &&
+	if ((frag != 0 || (fc & IEEE80211_FCTL_MOREFRAGS))) {
+		int flen;
+		struct sk_buff *frag_skb = ieee80211_frag_cache_get(ieee, hdr);
+		IEEE80211_DEBUG_FRAG("Rx Fragment received (%u)\n", frag);
+
+		if (!frag_skb) {
+			IEEE80211_DEBUG(IEEE80211_DL_RX | IEEE80211_DL_FRAG,
+					"Rx cannot get skb from fragment "
+					"cache (morefrag=%d seq=%u frag=%u)\n",
+					(fc & IEEE80211_FCTL_MOREFRAGS) != 0,
+					WLAN_GET_SEQ_SEQ(sc), frag);
+			goto rx_dropped;
+		}
+
+		flen = skb->len;
+		if (frag != 0)
+			flen -= hdrlen;
+
+		if (frag_skb->tail + flen > frag_skb->end) {
+			printk(KERN_WARNING "%s: host decrypted and "
+			       "reassembled frame did not fit skb\n",
+			       dev->name);
+			ieee80211_frag_cache_invalidate(ieee, hdr);
+			goto rx_dropped;
+		}
+
+		if (frag == 0) {
+			/* copy first fragment (including full headers) into
+			 * beginning of the fragment cache skb */
+			memcpy(skb_put(frag_skb, flen), skb->data, flen);
+		} else {
+			/* append frame payload to the end of the fragment
+			 * cache skb */
+			memcpy(skb_put(frag_skb, flen), skb->data + hdrlen,
+			       flen);
+		}
+		dev_kfree_skb_any(skb);
+		skb = NULL;
+
+		if (fc & IEEE80211_FCTL_MOREFRAGS) {
+			/* more fragments expected - leave the skb in fragment
+			 * cache for now; it will be delivered to upper layers
+			 * after all fragments have been received */
+			goto rx_exit;
+		}
+
+		/* this was the last fragment and the frame will be
+		 * delivered, so remove skb from fragment cache */
+		skb = frag_skb;
+		hdr = (struct ieee80211_hdr *) skb->data;
+		ieee80211_frag_cache_invalidate(ieee, hdr);
+	}
+
+	/* skb: hdr + (possible reassembled) full MSDU payload; possibly still
+	 * encrypted/authenticated */
+	if (ieee->host_decrypt && (fc & IEEE80211_FCTL_WEP) &&
+	    ieee80211_rx_frame_decrypt_msdu(ieee, skb, keyidx, crypt))
+		goto rx_dropped;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	if (crypt && !(fc & IEEE80211_FCTL_WEP) && !ieee->open_wep) {
+		if (/*ieee->ieee802_1x &&*/
+		    ieee80211_is_eapol_frame(ieee, skb)) {
+#ifdef CONFIG_IEEE80211_DEBUG
+			/* pass unencrypted EAPOL frames even if encryption is
+			 * configured */
+			struct eapol *eap = (struct eapol *)(skb->data +
+				24);
+			IEEE80211_DEBUG_EAP("RX: IEEE 802.1X EAPOL frame: %s\n",
+						eap_get_type(eap->type));
+#endif
+		} else {
+			IEEE80211_DEBUG_DROP(
+				"encryption configured, but RX "
+				"frame not encrypted (SA=" MAC_FMT ")\n",
+				MAC_ARG(hdr->addr2));
+			goto rx_dropped;
+		}
+	}
+
+#ifdef CONFIG_IEEE80211_DEBUG
+	if (crypt && !(fc & IEEE80211_FCTL_WEP) &&
+	    ieee80211_is_eapol_frame(ieee, skb)) {
+			struct eapol *eap = (struct eapol *)(skb->data +
+				24);
+			IEEE80211_DEBUG_EAP("RX: IEEE 802.1X EAPOL frame: %s\n",
+						eap_get_type(eap->type));
+	}
+#endif
+
+	if (crypt && !(fc & IEEE80211_FCTL_WEP) && !ieee->open_wep &&
+	    !ieee80211_is_eapol_frame(ieee, skb)) {
+		IEEE80211_DEBUG_DROP(
+			"dropped unencrypted RX data "
+			"frame from " MAC_FMT
+			" (drop_unencrypted=1)\n",
+			MAC_ARG(hdr->addr2));
+		goto rx_dropped;
+	}
+
+	/* skb: hdr + (possible reassembled) full plaintext payload */
+
+	payload = skb->data + hdrlen;
+	ethertype = (payload[6] << 8) | payload[7];
+
+#ifdef NOT_YET
+	/* If IEEE 802.1X is used, check whether the port is authorized to send
+	 * the received frame. */
+	if (ieee->ieee802_1x && ieee->iw_mode == IW_MODE_MASTER) {
+		if (ethertype == ETH_P_PAE) {
+			printk(KERN_DEBUG "%s: RX: IEEE 802.1X frame\n",
+			       dev->name);
+			if (ieee->hostapd && ieee->apdev) {
+				/* Send IEEE 802.1X frames to the user
+				 * space daemon for processing */
+				prism2_rx_80211(ieee->apdev, skb, rx_stats,
+						PRISM2_RX_MGMT);
+				ieee->apdevstats.rx_packets++;
+				ieee->apdevstats.rx_bytes += skb->len;
+				goto rx_exit;
+			}
+		} else if (!frame_authorized) {
+			printk(KERN_DEBUG "%s: dropped frame from "
+			       "unauthorized port (IEEE 802.1X): "
+			       "ethertype=0x%04x\n",
+			       dev->name, ethertype);
+			goto rx_dropped;
+		}
+	}
+#endif
+
+	/* convert hdr + possible LLC headers into Ethernet header */
+	if (skb->len - hdrlen >= 8 &&
+	    ((memcmp(payload, rfc1042_header, SNAP_SIZE) == 0 &&
+	      ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
+	     memcmp(payload, bridge_tunnel_header, SNAP_SIZE) == 0)) {
+		/* remove RFC1042 or Bridge-Tunnel encapsulation and
+		 * replace EtherType */
+		skb_pull(skb, hdrlen + SNAP_SIZE);
+		memcpy(skb_push(skb, ETH_ALEN), src, ETH_ALEN);
+		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
+	} else {
+		u16 len;
+		/* Leave Ethernet header part of hdr and full payload */
+		skb_pull(skb, hdrlen);
+		len = htons(skb->len);
+		memcpy(skb_push(skb, 2), &len, 2);
+		memcpy(skb_push(skb, ETH_ALEN), src, ETH_ALEN);
+		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
+	}
+
+#ifdef NOT_YET
+	if (wds && ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
+		    IEEE80211_FCTL_TODS) &&
+	    skb->len >= ETH_HLEN + ETH_ALEN) {
+		/* Non-standard frame: get addr4 from its bogus location after
+		 * the payload */
+		memcpy(skb->data + ETH_ALEN,
+		       skb->data + skb->len - ETH_ALEN, ETH_ALEN);
+		skb_trim(skb, skb->len - ETH_ALEN);
+	}
+#endif
+
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+
+#ifdef NOT_YET
+	if (ieee->iw_mode == IW_MODE_MASTER && !wds &&
+	    ieee->ap->bridge_packets) {
+		if (dst[0] & 0x01) {
+			/* copy multicast frame both to the higher layers and
+			 * to the wireless media */
+			ieee->ap->bridged_multicast++;
+			skb2 = skb_clone(skb, GFP_ATOMIC);
+			if (skb2 == NULL)
+				printk(KERN_DEBUG "%s: skb_clone failed for "
+				       "multicast frame\n", dev->name);
+		} else if (hostap_is_sta_assoc(ieee->ap, dst)) {
+			/* send frame directly to the associated STA using
+			 * wireless media and not passing to higher layers */
+			ieee->ap->bridged_unicast++;
+			skb2 = skb;
+			skb = NULL;
+		}
+	}
+
+	if (skb2 != NULL) {
+		/* send to wireless media */
+		skb2->protocol = __constant_htons(ETH_P_802_3);
+		skb2->mac.raw = skb2->nh.raw = skb2->data;
+		/* skb2->nh.raw = skb2->data + ETH_HLEN; */
+		skb2->dev = dev;
+		dev_queue_xmit(skb2);
+	}
+
+#endif
+
+	if (skb) {
+		skb->protocol = eth_type_trans(skb, dev);
+		memset(skb->cb, 0, sizeof(skb->cb));
+		skb->dev = dev;
+		skb->ip_summed = CHECKSUM_NONE; /* 802.11 crc not sufficient */
+		netif_rx(skb);
+	}
+
+ rx_exit:
+#ifdef NOT_YET
+	if (sta)
+		hostap_handle_sta_release(sta);
+#endif
+	return 1;
+
+ rx_dropped:
+	stats->rx_dropped++;
+
+	/* Returning 0 indicates to caller that we have not handled the SKB--
+	 * so it is still allocated and can be used again by underlying
+	 * hardware as a DMA target */
+	return 0;
+}
+
+#define MGMT_FRAME_FIXED_PART_LENGTH		0x24
+
+static inline int ieee80211_is_ofdm_rate(u8 rate)
+{
+	switch (rate & ~IEEE80211_BASIC_RATE_MASK) {
+	case IEEE80211_OFDM_RATE_6MB:
+	case IEEE80211_OFDM_RATE_9MB:
+	case IEEE80211_OFDM_RATE_12MB:
+	case IEEE80211_OFDM_RATE_18MB:
+	case IEEE80211_OFDM_RATE_24MB:
+	case IEEE80211_OFDM_RATE_36MB:
+	case IEEE80211_OFDM_RATE_48MB:
+	case IEEE80211_OFDM_RATE_54MB:
+		return 1;
+	}
+        return 0;
+}
+
+
+static inline int ieee80211_network_init(
+	struct ieee80211_device *ieee,
+	struct ieee80211_probe_response *beacon,
+	struct ieee80211_network *network,
+	struct ieee80211_rx_stats *stats)
+{
+#ifdef CONFIG_IEEE80211_DEBUG
+	char rates_str[64];
+	char *p;
+#endif
+	struct ieee80211_info_element *info_element;
+ 	u16 left;
+	u8 i;
+
+	/* Pull out fixed field data */
+	memcpy(network->bssid, beacon->header.addr3, ETH_ALEN);
+	network->capability = beacon->capability;
+	network->last_scanned = jiffies;
+	network->time_stamp[0] = beacon->time_stamp[0];
+	network->time_stamp[1] = beacon->time_stamp[1];
+	network->beacon_interval = beacon->beacon_interval;
+	/* Where to pull this? beacon->listen_interval;*/
+	network->listen_interval = 0x0A;
+	network->rates_len = network->rates_ex_len = 0;
+	network->last_associate = 0;
+	network->ssid_len = 0;
+	network->flags = 0;
+	network->atim_window = 0;
+
+	if (stats->freq == IEEE80211_52GHZ_BAND) {
+		/* for A band (No DS info) */
+		network->channel = stats->received_channel;
+	} else
+		network->flags |= NETWORK_HAS_CCK;
+
+ 	network->wpa_ie_len = 0;
+ 	network->rsn_ie_len = 0;
+
+ 	info_element = &beacon->info_element;
+	left = stats->len - ((void *)info_element - (void *)beacon);
+	while (left >= sizeof(struct ieee80211_info_element_hdr)) {
+		if (sizeof(struct ieee80211_info_element_hdr) + info_element->len > left) {
+			IEEE80211_DEBUG_SCAN("SCAN: parse failed: info_element->len + 2 > left : info_element->len+2=%d left=%d.\n",
+					     info_element->len + sizeof(struct ieee80211_info_element),
+					     left);
+			return 1;
+               	}
+
+		switch (info_element->id) {
+		case MFIE_TYPE_SSID:
+			if (ieee80211_is_empty_essid(info_element->data,
+						     info_element->len)) {
+				network->flags |= NETWORK_EMPTY_ESSID;
+				break;
+			}
+
+			network->ssid_len = min(info_element->len,
+						(u8)IW_ESSID_MAX_SIZE);
+			memcpy(network->ssid, info_element->data, network->ssid_len);
+        		if (network->ssid_len < IW_ESSID_MAX_SIZE)
+                		memset(network->ssid + network->ssid_len, 0,
+				       IW_ESSID_MAX_SIZE - network->ssid_len);
+
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_SSID: '%s' len=%d.\n",
+					     network->ssid, network->ssid_len);
+			break;
+
+		case MFIE_TYPE_RATES:
+#ifdef CONFIG_IEEE80211_DEBUG
+			p = rates_str;
+#endif
+			network->rates_len = min(info_element->len, MAX_RATES_LENGTH);
+			for (i = 0; i < network->rates_len; i++) {
+				network->rates[i] = info_element->data[i];
+#ifdef CONFIG_IEEE80211_DEBUG
+				p += snprintf(p, sizeof(rates_str) - (p - rates_str), "%02X ", network->rates[i]);
+#endif
+				if (ieee80211_is_ofdm_rate(info_element->data[i])) {
+					network->flags |= NETWORK_HAS_OFDM;
+					if (info_element->data[i] &
+					    IEEE80211_BASIC_RATE_MASK)
+						network->flags &=
+							~NETWORK_HAS_CCK;
+				}
+			}
+
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_RATES: '%s' (%d)\n",
+					     rates_str, network->rates_len);
+			break;
+
+		case MFIE_TYPE_RATES_EX:
+#ifdef CONFIG_IEEE80211_DEBUG
+			p = rates_str;
+#endif
+			network->rates_ex_len = min(info_element->len, MAX_RATES_EX_LENGTH);
+			for (i = 0; i < network->rates_ex_len; i++) {
+				network->rates_ex[i] = info_element->data[i];
+#ifdef CONFIG_IEEE80211_DEBUG
+				p += snprintf(p, sizeof(rates_str) - (p - rates_str), "%02X ", network->rates[i]);
+#endif
+				if (ieee80211_is_ofdm_rate(info_element->data[i])) {
+					network->flags |= NETWORK_HAS_OFDM;
+					if (info_element->data[i] &
+					    IEEE80211_BASIC_RATE_MASK)
+						network->flags &=
+							~NETWORK_HAS_CCK;
+				}
+			}
+
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_RATES_EX: '%s' (%d)\n",
+					     rates_str, network->rates_ex_len);
+			break;
+
+		case MFIE_TYPE_DS_SET:
+  			IEEE80211_DEBUG_SCAN("MFIE_TYPE_DS_SET: %d\n",
+					     info_element->data[0]);
+			if (stats->freq == IEEE80211_24GHZ_BAND)
+				network->channel = info_element->data[0];
+			break;
+
+	 	case MFIE_TYPE_FH_SET:
+  			IEEE80211_DEBUG_SCAN("MFIE_TYPE_FH_SET: ignored\n");
+			break;
+
+		case MFIE_TYPE_CF_SET:
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_CF_SET: ignored\n");
+			break;
+
+		case MFIE_TYPE_TIM:
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_TIM: ignored\n");
+			break;
+
+		case MFIE_TYPE_IBSS_SET:
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_IBSS_SET: ignored\n");
+			break;
+
+		case MFIE_TYPE_CHALLENGE:
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_CHALLENGE: ignored\n");
+			break;
+
+		case MFIE_TYPE_GENERIC:
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_GENERIC: %d bytes\n",
+					     info_element->len);
+			if (info_element->len >= 4  &&
+			    info_element->data[0] == 0x00 &&
+			    info_element->data[1] == 0x50 &&
+			    info_element->data[2] == 0xf2 &&
+			    info_element->data[3] == 0x01) {
+				network->wpa_ie_len = min(info_element->len + 2,
+							 MAX_WPA_IE_LEN);
+				memcpy(network->wpa_ie, info_element,
+				       network->wpa_ie_len);
+			}
+			break;
+
+		case MFIE_TYPE_RSN:
+			IEEE80211_DEBUG_SCAN("MFIE_TYPE_RSN: %d bytes\n",
+					     info_element->len);
+			network->rsn_ie_len = min(info_element->len + 2,
+						 MAX_WPA_IE_LEN);
+			memcpy(network->rsn_ie, info_element,
+			       network->rsn_ie_len);
+			break;
+
+		default:
+			IEEE80211_DEBUG_SCAN("unsupported IE %d\n",
+					     info_element->id);
+                        break;
+  		}
+
+		left -= sizeof(struct ieee80211_info_element_hdr) +
+			info_element->len;
+		info_element = (struct ieee80211_info_element *)
+                	&info_element->data[info_element->len];
+  	}
+
+	network->mode = 0;
+	if (stats->freq == IEEE80211_52GHZ_BAND)
+		network->mode = IEEE_A;
+	else {
+		if (network->flags & NETWORK_HAS_OFDM)
+			network->mode |= IEEE_G;
+		if (network->flags & NETWORK_HAS_CCK)
+			network->mode |= IEEE_B;
+	}
+
+	if (network->mode == 0) {
+		IEEE80211_DEBUG_SCAN("Filtered out '%s (" MAC_FMT ")' "
+				     "network.\n",
+				     escape_essid(network->ssid,
+						  network->ssid_len),
+				     MAC_ARG(network->bssid));
+		return 1;
+	}
+
+	if (ieee80211_is_empty_essid(network->ssid, network->ssid_len))
+		network->flags |= NETWORK_EMPTY_ESSID;
+
+	memcpy(&network->stats, stats, sizeof(network->stats));
+
+	return 0;
+}
+
+static inline int is_same_network(struct ieee80211_network *src,
+				  struct ieee80211_network *dst)
+{
+	/* A network is only a duplicate if the channel, BSSID, and ESSID
+	 * all match.  We treat all <hidden> with the same BSSID and channel
+	 * as one network */
+	return ((src->ssid_len == dst->ssid_len) &&
+		(src->channel == dst->channel) &&
+		!memcmp(src->bssid, dst->bssid, ETH_ALEN) &&
+		!memcmp(src->ssid, dst->ssid, src->ssid_len));
+}
+
+static inline void update_network(struct ieee80211_network *dst,
+				  struct ieee80211_network *src)
+{
+	memcpy(&dst->stats, &src->stats, sizeof(struct ieee80211_rx_stats));
+	dst->capability = src->capability;
+	memcpy(dst->rates, src->rates, src->rates_len);
+	dst->rates_len = src->rates_len;
+	memcpy(dst->rates_ex, src->rates_ex, src->rates_ex_len);
+	dst->rates_ex_len = src->rates_ex_len;
+
+	dst->mode = src->mode;
+	dst->flags = src->flags;
+	dst->time_stamp[0] = src->time_stamp[0];
+	dst->time_stamp[1] = src->time_stamp[1];
+
+	dst->beacon_interval = src->beacon_interval;
+	dst->listen_interval = src->listen_interval;
+	dst->atim_window = src->atim_window;
+
+	memcpy(dst->wpa_ie, src->wpa_ie, src->wpa_ie_len);
+	dst->wpa_ie_len = src->wpa_ie_len;
+	memcpy(dst->rsn_ie, src->rsn_ie, src->rsn_ie_len);
+	dst->rsn_ie_len = src->rsn_ie_len;
+
+	dst->last_scanned = jiffies;
+	/* dst->last_associate is not overwritten */
+}
+
+static inline void ieee80211_process_probe_response(
+	struct ieee80211_device *ieee,
+	struct ieee80211_probe_response *beacon,
+	struct ieee80211_rx_stats *stats)
+{
+	struct ieee80211_network network;
+	struct ieee80211_network *target;
+	struct ieee80211_network *oldest = NULL;
+#ifdef CONFIG_IEEE80211_DEBUG
+	struct ieee80211_info_element *info_element = &beacon->info_element;
+#endif
+	unsigned long flags;
+
+	IEEE80211_DEBUG_SCAN(
+		"'%s' (" MAC_FMT "): %c%c%c%c %c%c%c%c-%c%c%c%c %c%c%c%c\n",
+		escape_essid(info_element->data, info_element->len),
+		MAC_ARG(beacon->header.addr3),
+		(beacon->capability & (1<<0xf)) ? '1' : '0',
+		(beacon->capability & (1<<0xe)) ? '1' : '0',
+		(beacon->capability & (1<<0xd)) ? '1' : '0',
+		(beacon->capability & (1<<0xc)) ? '1' : '0',
+		(beacon->capability & (1<<0xb)) ? '1' : '0',
+		(beacon->capability & (1<<0xa)) ? '1' : '0',
+		(beacon->capability & (1<<0x9)) ? '1' : '0',
+		(beacon->capability & (1<<0x8)) ? '1' : '0',
+		(beacon->capability & (1<<0x7)) ? '1' : '0',
+		(beacon->capability & (1<<0x6)) ? '1' : '0',
+		(beacon->capability & (1<<0x5)) ? '1' : '0',
+		(beacon->capability & (1<<0x4)) ? '1' : '0',
+		(beacon->capability & (1<<0x3)) ? '1' : '0',
+		(beacon->capability & (1<<0x2)) ? '1' : '0',
+		(beacon->capability & (1<<0x1)) ? '1' : '0',
+		(beacon->capability & (1<<0x0)) ? '1' : '0');
+
+	if (ieee80211_network_init(ieee, beacon, &network, stats)) {
+		IEEE80211_DEBUG_SCAN("Dropped '%s' (" MAC_FMT ") via %s.\n",
+				     escape_essid(info_element->data,
+						  info_element->len),
+				     MAC_ARG(beacon->header.addr3),
+				     WLAN_FC_GET_STYPE(beacon->header.frame_ctl) ==
+				     IEEE80211_STYPE_PROBE_RESP ?
+				     "PROBE RESPONSE" : "BEACON");
+		return;
+	}
+
+	/* The network parsed correctly -- so now we scan our known networks
+	 * to see if we can find it in our list.
+	 *
+	 * NOTE:  This search is definitely not optimized.  Once its doing
+	 *        the "right thing" we'll optimize it for efficiency if
+	 *        necessary */
+
+	/* Search for this entry in the list and update it if it is
+	 * already there. */
+
+	spin_lock_irqsave(&ieee->lock, flags);
+
+	list_for_each_entry(target, &ieee->network_list, list) {
+		if (is_same_network(target, &network))
+			break;
+
+		if ((oldest == NULL) ||
+		    (target->last_scanned < oldest->last_scanned))
+			oldest = target;
+	}
+
+	/* If we didn't find a match, then get a new network slot to initialize
+	 * with this beacon's information */
+	if (&target->list == &ieee->network_list) {
+		if (list_empty(&ieee->network_free_list)) {
+			/* If there are no more slots, expire the oldest */
+			list_del(&oldest->list);
+			target = oldest;
+			IEEE80211_DEBUG_SCAN("Expired '%s' (" MAC_FMT ") from "
+					     "network list.\n",
+					     escape_essid(target->ssid,
+							  target->ssid_len),
+					     MAC_ARG(target->bssid));
+		} else {
+			/* Otherwise just pull from the free list */
+			target = list_entry(ieee->network_free_list.next,
+					    struct ieee80211_network, list);
+			list_del(ieee->network_free_list.next);
+		}
+
+
+#ifdef CONFIG_IEEE80211_DEBUG
+		IEEE80211_DEBUG_SCAN("Adding '%s' (" MAC_FMT ") via %s.\n",
+				     escape_essid(network.ssid,
+						  network.ssid_len),
+				     MAC_ARG(network.bssid),
+				     WLAN_FC_GET_STYPE(beacon->header.frame_ctl) ==
+				     IEEE80211_STYPE_PROBE_RESP ?
+				     "PROBE RESPONSE" : "BEACON");
+#endif
+		memcpy(target, &network, sizeof(*target));
+		list_add_tail(&target->list, &ieee->network_list);
+	} else {
+		IEEE80211_DEBUG_SCAN("Updating '%s' (" MAC_FMT ") via %s.\n",
+				     escape_essid(target->ssid,
+						  target->ssid_len),
+				     MAC_ARG(target->bssid),
+				     WLAN_FC_GET_STYPE(beacon->header.frame_ctl) ==
+				     IEEE80211_STYPE_PROBE_RESP ?
+				     "PROBE RESPONSE" : "BEACON");
+		update_network(target, &network);
+	}
+
+	spin_unlock_irqrestore(&ieee->lock, flags);
+}
+
+void ieee80211_rx_mgt(struct ieee80211_device *ieee,
+		      struct ieee80211_hdr *header,
+		      struct ieee80211_rx_stats *stats)
+{
+	switch (WLAN_FC_GET_STYPE(header->frame_ctl)) {
+	case IEEE80211_STYPE_ASSOC_RESP:
+		IEEE80211_DEBUG_MGMT("received ASSOCIATION RESPONSE (%d)\n",
+				     WLAN_FC_GET_STYPE(header->frame_ctl));
+		break;
+
+	case IEEE80211_STYPE_REASSOC_RESP:
+		IEEE80211_DEBUG_MGMT("received REASSOCIATION RESPONSE (%d)\n",
+				     WLAN_FC_GET_STYPE(header->frame_ctl));
+		break;
+
+	case IEEE80211_STYPE_PROBE_RESP:
+		IEEE80211_DEBUG_MGMT("received PROBE RESPONSE (%d)\n",
+				     WLAN_FC_GET_STYPE(header->frame_ctl));
+		IEEE80211_DEBUG_SCAN("Probe response\n");
+		ieee80211_process_probe_response(
+			ieee, (struct ieee80211_probe_response *)header, stats);
+		break;
+
+	case IEEE80211_STYPE_BEACON:
+		IEEE80211_DEBUG_MGMT("received BEACON (%d)\n",
+				     WLAN_FC_GET_STYPE(header->frame_ctl));
+		IEEE80211_DEBUG_SCAN("Beacon\n");
+		ieee80211_process_probe_response(
+			ieee, (struct ieee80211_probe_response *)header, stats);
+		break;
+
+	default:
+		IEEE80211_DEBUG_MGMT("received UNKNOWN (%d)\n",
+				     WLAN_FC_GET_STYPE(header->frame_ctl));
+		IEEE80211_WARNING("%s: Unknown management packet: %d\n",
+				  ieee->dev->name,
+				  WLAN_FC_GET_STYPE(header->frame_ctl));
+		break;
+	}
+}
+
+
+EXPORT_SYMBOL(ieee80211_rx_mgt);
+EXPORT_SYMBOL(ieee80211_rx);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_tx.c netdev-2.6-ipw/net/ieee80211/ieee80211_tx.c
--- netdev-2.6/net/ieee80211/ieee80211_tx.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_tx.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,448 @@
+/******************************************************************************
+
+  Copyright(c) 2003 - 2004 Intel Corporation. All rights reserved.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of version 2 of the GNU General Public License as
+  published by the Free Software Foundation.
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc., 59
+  Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+  The full GNU General Public License is included in this distribution in the
+  file called LICENSE.
+
+  Contact Information:
+  James P. Ketrenos <ipw2100-admin@linux.intel.com>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+******************************************************************************/
+#include <linux/compiler.h>
+#include <linux/config.h>
+#include <linux/errno.h>
+#include <linux/if_arp.h>
+#include <linux/in6.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/types.h>
+#include <linux/version.h>
+#include <linux/wireless.h>
+#include <linux/etherdevice.h>
+#include <asm/uaccess.h>
+
+#include <net/ieee80211.h>
+
+
+/*
+
+
+802.11 Data Frame
+
+      ,-------------------------------------------------------------------.
+Bytes |  2   |  2   |    6    |    6    |    6    |  2   | 0..2312 |   4  |
+      |------|------|---------|---------|---------|------|---------|------|
+Desc. | ctrl | dura |  DA/RA  |   TA    |    SA   | Sequ |  Frame  |  fcs |
+      |      | tion | (BSSID) |         |         | ence |  data   |      |
+      `--------------------------------------------------|         |------'
+Total: 28 non-data bytes                                 `----.----'
+                                                              |
+       .- 'Frame data' expands to <---------------------------'
+       |
+       V
+      ,---------------------------------------------------.
+Bytes |  1   |  1   |    1    |    3     |  2   |  0-2304 |
+      |------|------|---------|----------|------|---------|
+Desc. | SNAP | SNAP | Control |Eth Tunnel| Type | IP      |
+      | DSAP | SSAP |         |          |      | Packet  |
+      | 0xAA | 0xAA |0x03 (UI)|0x00-00-F8|      |         |
+      `-----------------------------------------|         |
+Total: 8 non-data bytes                         `----.----'
+                                                     |
+       .- 'IP Packet' expands, if WEP enabled, to <--'
+       |
+       V
+      ,-----------------------.
+Bytes |  4  |   0-2296  |  4  |
+      |-----|-----------|-----|
+Desc. | IV  | Encrypted | ICV |
+      |     | IP Packet |     |
+      `-----------------------'
+Total: 8 non-data bytes
+
+
+802.3 Ethernet Data Frame
+
+      ,-----------------------------------------.
+Bytes |   6   |   6   |  2   |  Variable |   4  |
+      |-------|-------|------|-----------|------|
+Desc. | Dest. | Source| Type | IP Packet |  fcs |
+      |  MAC  |  MAC  |      |           |      |
+      `-----------------------------------------'
+Total: 18 non-data bytes
+
+In the event that fragmentation is required, the incoming payload is split into
+N parts of size ieee->fts.  The first fragment contains the SNAP header and the
+remaining packets are just data.
+
+If encryption is enabled, each fragment payload size is reduced by enough space
+to add the prefix and postfix (IV and ICV totalling 8 bytes in the case of WEP)
+So if you have 1500 bytes of payload with ieee->fts set to 500 without
+encryption it will take 3 frames.  With WEP it will take 4 frames as the
+payload of each frame is reduced to 492 bytes.
+
+* SKB visualization
+*
+*  ,- skb->data
+* |
+* |    ETHERNET HEADER        ,-<-- PAYLOAD
+* |                           |     14 bytes from skb->data
+* |  2 bytes for Type --> ,T. |     (sizeof ethhdr)
+* |                       | | |
+* |,-Dest.--. ,--Src.---. | | |
+* |  6 bytes| | 6 bytes | | | |
+* v         | |         | | | |
+* 0         | v       1 | v | v           2
+* 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5
+*     ^     | ^         | ^ |
+*     |     | |         | | |
+*     |     | |         | `T' <---- 2 bytes for Type
+*     |     | |         |
+*     |     | '---SNAP--' <-------- 6 bytes for SNAP
+*     |     |
+*     `-IV--' <-------------------- 4 bytes for IV (WEP)
+*
+*      SNAP HEADER
+*
+*/
+
+static u8 P802_1H_OUI[P80211_OUI_LEN] = { 0x00, 0x00, 0xf8 };
+static u8 RFC1042_OUI[P80211_OUI_LEN] = { 0x00, 0x00, 0x00 };
+
+static inline int ieee80211_put_snap(u8 *data, u16 h_proto)
+{
+	struct ieee80211_snap_hdr *snap;
+	u8 *oui;
+
+	snap = (struct ieee80211_snap_hdr *)data;
+	snap->dsap = 0xaa;
+	snap->ssap = 0xaa;
+	snap->ctrl = 0x03;
+
+	if (h_proto == 0x8137 || h_proto == 0x80f3)
+		oui = P802_1H_OUI;
+	else
+		oui = RFC1042_OUI;
+	snap->oui[0] = oui[0];
+	snap->oui[1] = oui[1];
+	snap->oui[2] = oui[2];
+
+	*(u16 *)(data + SNAP_SIZE) = htons(h_proto);
+
+	return SNAP_SIZE + sizeof(u16);
+}
+
+static inline int ieee80211_encrypt_fragment(
+	struct ieee80211_device *ieee,
+	struct sk_buff *frag,
+	int hdr_len)
+{
+	struct ieee80211_crypt_data* crypt = ieee->crypt[ieee->tx_keyidx];
+	int res;
+
+#ifdef CONFIG_IEEE80211_CRYPT_TKIP
+	struct ieee80211_hdr *header;
+
+	if (ieee->tkip_countermeasures &&
+	    crypt && crypt->ops && strcmp(crypt->ops->name, "TKIP") == 0) {
+		header = (struct ieee80211_hdr *) frag->data;
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
+			       "TX packet to " MAC_FMT "\n",
+			       ieee->dev->name, MAC_ARG(header->addr1));
+		}
+		return -1;
+	}
+#endif
+	/* To encrypt, frame format is:
+	 * IV (4 bytes), clear payload (including SNAP), ICV (4 bytes) */
+
+	// PR: FIXME: Copied from hostap. Check fragmentation/MSDU/MPDU encryption.
+	/* Host-based IEEE 802.11 fragmentation for TX is not yet supported, so
+	 * call both MSDU and MPDU encryption functions from here. */
+	atomic_inc(&crypt->refcnt);
+	res = 0;
+	if (crypt->ops->encrypt_msdu)
+		res = crypt->ops->encrypt_msdu(frag, hdr_len, crypt->priv);
+	if (res == 0 && crypt->ops->encrypt_mpdu)
+		res = crypt->ops->encrypt_mpdu(frag, hdr_len, crypt->priv);
+
+	atomic_dec(&crypt->refcnt);
+	if (res < 0) {
+		printk(KERN_INFO "%s: Encryption failed: len=%d.\n",
+		       ieee->dev->name, frag->len);
+		ieee->ieee_stats.tx_discards++;
+		return -1;
+	}
+
+	return 0;
+}
+
+
+void ieee80211_txb_free(struct ieee80211_txb *txb) {
+	int i;
+	if (unlikely(!txb))
+		return;
+	for (i = 0; i < txb->nr_frags; i++)
+		if (txb->fragments[i])
+			dev_kfree_skb_any(txb->fragments[i]);
+	kfree(txb);
+}
+
+struct ieee80211_txb *ieee80211_alloc_txb(int nr_frags, int txb_size,
+					  int gfp_mask)
+{
+	struct ieee80211_txb *txb;
+	int i;
+	txb = kmalloc(
+		sizeof(struct ieee80211_txb) + (sizeof(u8*) * nr_frags),
+		gfp_mask);
+	if (!txb)
+		return NULL;
+
+	memset(txb, sizeof(struct ieee80211_txb), 0);
+	txb->nr_frags = nr_frags;
+	txb->frag_size = txb_size;
+
+	for (i = 0; i < nr_frags; i++) {
+		txb->fragments[i] = dev_alloc_skb(txb_size);
+		if (unlikely(!txb->fragments[i])) {
+			i--;
+			break;
+		}
+	}
+	if (unlikely(i != nr_frags)) {
+		while (i >= 0)
+			dev_kfree_skb_any(txb->fragments[i--]);
+		kfree(txb);
+		return NULL;
+	}
+	return txb;
+}
+
+/* SKBs are added to the ieee->tx_queue. */
+int ieee80211_xmit(struct sk_buff *skb,
+		   struct net_device *dev)
+{
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ieee80211_txb *txb = NULL;
+	struct ieee80211_hdr *frag_hdr;
+	int i, bytes_per_frag, nr_frags, bytes_last_frag, frag_size;
+	unsigned long flags;
+	struct net_device_stats *stats = &ieee->stats;
+	int ether_type, encrypt;
+	int bytes, fc, hdr_len;
+	struct sk_buff *skb_frag;
+	struct ieee80211_hdr header = { /* Ensure zero initialized */
+		.duration_id = 0,
+		.seq_ctl = 0
+	};
+	u8 dest[ETH_ALEN], src[ETH_ALEN];
+
+	struct ieee80211_crypt_data* crypt;
+
+	spin_lock_irqsave(&ieee->lock, flags);
+
+	/* If there is no driver handler to take the TXB, dont' bother
+	 * creating it... */
+	if (!ieee->hard_start_xmit) {
+		printk(KERN_WARNING "%s: No xmit handler.\n",
+		       ieee->dev->name);
+		goto success;
+	}
+
+	if (unlikely(skb->len < SNAP_SIZE + sizeof(u16))) {
+		printk(KERN_WARNING "%s: skb too small (%d).\n",
+		       ieee->dev->name, skb->len);
+		goto success;
+	}
+
+	ether_type = ntohs(((struct ethhdr *)skb->data)->h_proto);
+
+	crypt = ieee->crypt[ieee->tx_keyidx];
+
+	encrypt = !(ether_type == ETH_P_PAE && ieee->ieee802_1x) &&
+		ieee->host_encrypt && crypt && crypt->ops;
+
+	if (!encrypt && ieee->ieee802_1x &&
+	    ieee->drop_unencrypted && ether_type != ETH_P_PAE) {
+		stats->tx_dropped++;
+		goto success;
+	}
+
+#ifdef CONFIG_IEEE80211_DEBUG
+	if (crypt && !encrypt && ether_type == ETH_P_PAE) {
+		struct eapol *eap = (struct eapol *)(skb->data +
+			sizeof(struct ethhdr) - SNAP_SIZE - sizeof(u16));
+		IEEE80211_DEBUG_EAP("TX: IEEE 802.11 EAPOL frame: %s\n",
+			eap_get_type(eap->type));
+	}
+#endif
+
+	/* Save source and destination addresses */
+	memcpy(&dest, skb->data, ETH_ALEN);
+	memcpy(&src, skb->data+ETH_ALEN, ETH_ALEN);
+
+	/* Advance the SKB to the start of the payload */
+	skb_pull(skb, sizeof(struct ethhdr));
+
+	/* Determine total amount of storage required for TXB packets */
+	bytes = skb->len + SNAP_SIZE + sizeof(u16);
+
+	if (encrypt)
+		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA |
+			IEEE80211_FCTL_WEP;
+	else
+		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA;
+
+	if (ieee->iw_mode == IW_MODE_INFRA) {
+		fc |= IEEE80211_FCTL_TODS;
+		/* To DS: Addr1 = BSSID, Addr2 = SA,
+		   Addr3 = DA */
+		memcpy(&header.addr1, ieee->bssid, ETH_ALEN);
+		memcpy(&header.addr2, &src, ETH_ALEN);
+		memcpy(&header.addr3, &dest, ETH_ALEN);
+	} else if (ieee->iw_mode == IW_MODE_ADHOC) {
+		/* not From/To DS: Addr1 = DA, Addr2 = SA,
+		   Addr3 = BSSID */
+		memcpy(&header.addr1, dest, ETH_ALEN);
+		memcpy(&header.addr2, src, ETH_ALEN);
+		memcpy(&header.addr3, ieee->bssid, ETH_ALEN);
+	}
+	header.frame_ctl = cpu_to_le16(fc);
+	hdr_len = IEEE80211_3ADDR_LEN;
+
+	/* Determine fragmentation size based on destination (multicast
+	 * and broadcast are not fragmented) */
+	if (is_multicast_ether_addr(dest) ||
+	    is_broadcast_ether_addr(dest))
+		frag_size = MAX_FRAG_THRESHOLD;
+	else
+		frag_size = ieee->fts;
+
+	/* Determine amount of payload per fragment.  Regardless of if
+	 * this stack is providing the full 802.11 header, one will
+	 * eventually be affixed to this fragment -- so we must account for
+	 * it when determining the amount of payload space. */
+	bytes_per_frag = frag_size - IEEE80211_3ADDR_LEN;
+	if (ieee->config &
+	    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
+		bytes_per_frag -= IEEE80211_FCS_LEN;
+
+	/* Each fragment may need to have room for encryptiong pre/postfix */
+	if (encrypt)
+		bytes_per_frag -= crypt->ops->extra_prefix_len +
+			crypt->ops->extra_postfix_len;
+
+	/* Number of fragments is the total bytes_per_frag /
+	 * payload_per_fragment */
+	nr_frags = bytes / bytes_per_frag;
+	bytes_last_frag = bytes % bytes_per_frag;
+	if (bytes_last_frag)
+		nr_frags++;
+	else
+		bytes_last_frag = bytes_per_frag;
+
+	/* When we allocate the TXB we allocate enough space for the reserve
+	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
+	 * postfix, header, FCS, etc.) */
+	txb = ieee80211_alloc_txb(nr_frags, frag_size, GFP_ATOMIC);
+	if (unlikely(!txb)) {
+		printk(KERN_WARNING "%s: Could not allocate TXB\n",
+		       ieee->dev->name);
+		goto failed;
+	}
+	txb->encrypted = encrypt;
+	txb->payload_size = bytes;
+
+	for (i = 0; i < nr_frags; i++) {
+		skb_frag = txb->fragments[i];
+
+		if (encrypt)
+			skb_reserve(skb_frag, crypt->ops->extra_prefix_len);
+
+		frag_hdr = (struct ieee80211_hdr *)skb_put(skb_frag, hdr_len);
+		memcpy(frag_hdr, &header, hdr_len);
+
+		/* If this is not the last fragment, then add the MOREFRAGS
+		 * bit to the frame control */
+		if (i != nr_frags - 1) {
+			frag_hdr->frame_ctl = cpu_to_le16(
+				fc | IEEE80211_FCTL_MOREFRAGS);
+			bytes = bytes_per_frag;
+		} else {
+			/* The last fragment takes the remaining length */
+			bytes = bytes_last_frag;
+		}
+
+	       	/* Put a SNAP header on the first fragment */
+		if (i == 0) {
+			ieee80211_put_snap(
+				skb_put(skb_frag, SNAP_SIZE + sizeof(u16)),
+				ether_type);
+			bytes -= SNAP_SIZE + sizeof(u16);
+		}
+
+		memcpy(skb_put(skb_frag, bytes), skb->data, bytes);
+
+		/* Advance the SKB... */
+		skb_pull(skb, bytes);
+
+		/* Encryption routine will move the header forward in order
+		 * to insert the IV between the header and the payload */
+		if (encrypt)
+			ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
+		if (ieee->config &
+		    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
+			skb_put(skb_frag, 4);
+	}
+
+
+ success:
+	spin_unlock_irqrestore(&ieee->lock, flags);
+
+	dev_kfree_skb_any(skb);
+
+	if (txb) {
+		if ((*ieee->hard_start_xmit)(txb, dev) == 0) {
+			stats->tx_packets++;
+			stats->tx_bytes += txb->payload_size;
+			return 0;
+		}
+		ieee80211_txb_free(txb);
+	}
+
+	return 0;
+
+ failed:
+	spin_unlock_irqrestore(&ieee->lock, flags);
+	netif_stop_queue(dev);
+	stats->tx_errors++;
+	return 1;
+
+}
+
+EXPORT_SYMBOL(ieee80211_txb_free);
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/net/ieee80211/ieee80211_wx.c netdev-2.6-ipw/net/ieee80211/ieee80211_wx.c
--- netdev-2.6/net/ieee80211/ieee80211_wx.c	1969-12-31 18:00:00 -06:00
+++ netdev-2.6-ipw/net/ieee80211/ieee80211_wx.c	2005-02-10 17:07:47 -06:00
@@ -0,0 +1,471 @@
+/******************************************************************************
+
+  Copyright(c) 2004 Intel Corporation. All rights reserved.
+
+  Portions of this file are based on the WEP enablement code provided by the
+  Host AP project hostap-drivers v0.1.3
+  Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+  <jkmaline@cc.hut.fi>
+  Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of version 2 of the GNU General Public License as
+  published by the Free Software Foundation.
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc., 59
+  Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+  The full GNU General Public License is included in this distribution in the
+  file called LICENSE.
+
+  Contact Information:
+  James P. Ketrenos <ipw2100-admin@linux.intel.com>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+******************************************************************************/
+#include <linux/wireless.h>
+#include <linux/version.h>
+#include <linux/kmod.h>
+#include <linux/module.h>
+
+#include <net/ieee80211.h>
+static const char *ieee80211_modes[] = {
+	"?", "a", "b", "ab", "g", "ag", "bg", "abg"
+};
+
+#define MAX_CUSTOM_LEN 64
+static inline char *ipw2100_translate_scan(struct ieee80211_device *ieee,
+ 					   char *start, char *stop,
+					   struct ieee80211_network *network)
+{
+	char custom[MAX_CUSTOM_LEN];
+	char *p;
+	struct iw_event iwe;
+	int i, j;
+	u8 max_rate, rate;
+
+	/* First entry *MUST* be the AP MAC address */
+	iwe.cmd = SIOCGIWAP;
+	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
+	memcpy(iwe.u.ap_addr.sa_data, network->bssid, ETH_ALEN);
+	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_ADDR_LEN);
+
+	/* Remaining entries will be displayed in the order we provide them */
+
+	/* Add the ESSID */
+	iwe.cmd = SIOCGIWESSID;
+	iwe.u.data.flags = 1;
+	if (network->flags & NETWORK_EMPTY_ESSID) {
+		iwe.u.data.length = sizeof("<hidden>");
+		start = iwe_stream_add_point(start, stop, &iwe, "<hidden>");
+	} else {
+		iwe.u.data.length = min(network->ssid_len, (u8)32);
+		start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+	}
+
+	/* Add the protocol name */
+	iwe.cmd = SIOCGIWNAME;
+	snprintf(iwe.u.name, IFNAMSIZ, "IEEE 802.11%s", ieee80211_modes[network->mode]);
+	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_CHAR_LEN);
+
+        /* Add mode */
+        iwe.cmd = SIOCGIWMODE;
+        if (network->capability &
+	    (WLAN_CAPABILITY_BSS | WLAN_CAPABILITY_IBSS)) {
+		if (network->capability & WLAN_CAPABILITY_BSS)
+			iwe.u.mode = IW_MODE_MASTER;
+		else
+			iwe.u.mode = IW_MODE_ADHOC;
+
+		start = iwe_stream_add_event(start, stop, &iwe,
+					     IW_EV_UINT_LEN);
+	}
+
+        /* Add frequency/channel */
+	iwe.cmd = SIOCGIWFREQ;
+/*	iwe.u.freq.m = ieee80211_frequency(network->channel, network->mode);
+	iwe.u.freq.e = 3; */
+	iwe.u.freq.m = network->channel;
+	iwe.u.freq.e = 0;
+	iwe.u.freq.i = 0;
+	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
+
+	/* Add encryption capability */
+	iwe.cmd = SIOCGIWENCODE;
+	if (network->capability & WLAN_CAPABILITY_PRIVACY)
+		iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
+	else
+		iwe.u.data.flags = IW_ENCODE_DISABLED;
+	iwe.u.data.length = 0;
+	start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
+
+	/* Add basic and extended rates */
+	max_rate = 0;
+	p = custom;
+	p += snprintf(p, MAX_CUSTOM_LEN - (p - custom), " Rates (Mb/s): ");
+	for (i = 0, j = 0; i < network->rates_len; ) {
+		if (j < network->rates_ex_len &&
+		    ((network->rates_ex[j] & 0x7F) <
+		     (network->rates[i] & 0x7F)))
+			rate = network->rates_ex[j++] & 0x7F;
+		else
+			rate = network->rates[i++] & 0x7F;
+		if (rate > max_rate)
+			max_rate = rate;
+		p += snprintf(p, MAX_CUSTOM_LEN - (p - custom),
+			      "%d%s ", rate >> 1, (rate & 1) ? ".5" : "");
+	}
+	for (; j < network->rates_ex_len; j++) {
+		rate = network->rates_ex[j] & 0x7F;
+		p += snprintf(p, MAX_CUSTOM_LEN - (p - custom),
+			      "%d%s ", rate >> 1, (rate & 1) ? ".5" : "");
+		if (rate > max_rate)
+			max_rate = rate;
+	}
+
+	iwe.cmd = SIOCGIWRATE;
+	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+	iwe.u.bitrate.value = max_rate * 500000;
+	start = iwe_stream_add_event(start, stop, &iwe,
+				     IW_EV_PARAM_LEN);
+
+	iwe.cmd = IWEVCUSTOM;
+	iwe.u.data.length = p - custom;
+	if (iwe.u.data.length)
+		start = iwe_stream_add_point(start, stop, &iwe, custom);
+
+	/* Add quality statistics */
+	/* TODO: Fix these values... */
+	iwe.cmd = IWEVQUAL;
+	iwe.u.qual.qual = network->stats.signal;
+	iwe.u.qual.level = network->stats.rssi;
+	iwe.u.qual.noise = network->stats.noise;
+	iwe.u.qual.updated = network->stats.mask & IEEE80211_STATMASK_WEMASK;
+	if (!(network->stats.mask & IEEE80211_STATMASK_RSSI))
+		iwe.u.qual.updated |= IW_QUAL_LEVEL_INVALID;
+	if (!(network->stats.mask & IEEE80211_STATMASK_NOISE))
+		iwe.u.qual.updated |= IW_QUAL_NOISE_INVALID;
+	if (!(network->stats.mask & IEEE80211_STATMASK_SIGNAL))
+		iwe.u.qual.updated |= IW_QUAL_QUAL_INVALID;
+
+	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_QUAL_LEN);
+
+	iwe.cmd = IWEVCUSTOM;
+	p = custom;
+
+	iwe.u.data.length = p - custom;
+	if (iwe.u.data.length)
+		start = iwe_stream_add_point(start, stop, &iwe, custom);
+
+	if (ieee->wpa_enabled && network->wpa_ie_len){
+		char buf[MAX_WPA_IE_LEN * 2 + 30];
+
+		u8 *p = buf;
+		p += sprintf(p, "wpa_ie=");
+		for (i = 0; i < network->wpa_ie_len; i++) {
+			p += sprintf(p, "%02x", network->wpa_ie[i]);
+		}
+
+		memset(&iwe, 0, sizeof(iwe));
+		iwe.cmd = IWEVCUSTOM;
+		iwe.u.data.length = strlen(buf);
+		start = iwe_stream_add_point(start, stop, &iwe, buf);
+	}
+
+	if (ieee->wpa_enabled && network->rsn_ie_len){
+		char buf[MAX_WPA_IE_LEN * 2 + 30];
+
+		u8 *p = buf;
+		p += sprintf(p, "rsn_ie=");
+		for (i = 0; i < network->rsn_ie_len; i++) {
+			p += sprintf(p, "%02x", network->rsn_ie[i]);
+		}
+
+		memset(&iwe, 0, sizeof(iwe));
+		iwe.cmd = IWEVCUSTOM;
+		iwe.u.data.length = strlen(buf);
+		start = iwe_stream_add_point(start, stop, &iwe, buf);
+	}
+
+	/* Add EXTRA: Age to display seconds since last beacon/probe response
+	 * for given network. */
+	iwe.cmd = IWEVCUSTOM;
+	p = custom;
+	p += snprintf(p, MAX_CUSTOM_LEN - (p - custom),
+		      " Last beacon: %lums ago", (jiffies - network->last_scanned) / (HZ / 100));
+	iwe.u.data.length = p - custom;
+	if (iwe.u.data.length)
+		start = iwe_stream_add_point(start, stop, &iwe, custom);
+
+
+	return start;
+}
+
+int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
+			  struct iw_request_info *info,
+			  union iwreq_data *wrqu, char *extra)
+{
+	struct ieee80211_network *network;
+	unsigned long flags;
+
+	char *ev = extra;
+	char *stop = ev + IW_SCAN_MAX_DATA;
+	int i = 0;
+
+	IEEE80211_DEBUG_WX("Getting scan\n");
+
+	spin_lock_irqsave(&ieee->lock, flags);
+
+	list_for_each_entry(network, &ieee->network_list, list) {
+		i++;
+		if (ieee->scan_age == 0 ||
+		    time_after(network->last_scanned + ieee->scan_age, jiffies))
+			ev = ipw2100_translate_scan(ieee, ev, stop, network);
+		else
+			IEEE80211_DEBUG_SCAN(
+				"Not showing network '%s ("
+				MAC_FMT ")' due to age (%lums).\n",
+				escape_essid(network->ssid,
+					     network->ssid_len),
+				MAC_ARG(network->bssid),
+				(jiffies - network->last_scanned) / (HZ / 100));
+	}
+
+	spin_unlock_irqrestore(&ieee->lock, flags);
+
+	wrqu->data.length = ev -  extra;
+	wrqu->data.flags = 0;
+
+	IEEE80211_DEBUG_WX("exit: %d networks returned.\n", i);
+
+	return 0;
+}
+
+int ieee80211_wx_set_encode(struct ieee80211_device *ieee,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *keybuf)
+{
+	struct iw_point *erq = &(wrqu->encoding);
+	struct net_device *dev = ieee->dev;
+	struct ieee80211_security sec = {
+		.flags = 0
+	};
+	int i, key, key_provided, len;
+	struct ieee80211_crypt_data **crypt;
+
+	IEEE80211_DEBUG_WX("SET_ENCODE\n");
+
+	key = erq->flags & IW_ENCODE_INDEX;
+	if (key) {
+		if (key > WEP_KEYS)
+			return -EINVAL;
+		key--;
+		key_provided = 1;
+	} else {
+		key_provided = 0;
+		key = ieee->tx_keyidx;
+	}
+
+	IEEE80211_DEBUG_WX("Key: %d [%s]\n", key, key_provided ?
+			   "provided" : "default");
+
+	crypt = &ieee->crypt[key];
+
+	if (erq->flags & IW_ENCODE_DISABLED) {
+		if (key_provided && *crypt) {
+			IEEE80211_DEBUG_WX("Disabling encryption on key %d.\n",
+					   key);
+			ieee80211_crypt_delayed_deinit(ieee, crypt);
+		} else
+			IEEE80211_DEBUG_WX("Disabling encryption.\n");
+
+		/* Check all the keys to see if any are still configured,
+		 * and if no key index was provided, de-init them all */
+		for (i = 0; i < WEP_KEYS; i++) {
+			if (ieee->crypt[i] != NULL) {
+				if (key_provided)
+					break;
+				ieee80211_crypt_delayed_deinit(
+					ieee, &ieee->crypt[i]);
+			}
+		}
+
+		if (i == WEP_KEYS) {
+			sec.enabled = 0;
+			sec.level = SEC_LEVEL_0;
+			sec.flags |= SEC_ENABLED | SEC_LEVEL;
+		}
+
+		goto done;
+	}
+
+
+
+	sec.enabled = 1;
+	sec.flags |= SEC_ENABLED;
+
+	if (*crypt != NULL && (*crypt)->ops != NULL &&
+	    strcmp((*crypt)->ops->name, "WEP") != 0) {
+		/* changing to use WEP; deinit previously used algorithm
+		 * on this key */
+		ieee80211_crypt_delayed_deinit(ieee, crypt);
+	}
+
+	if (*crypt == NULL) {
+		struct ieee80211_crypt_data *new_crypt;
+
+		/* take WEP into use */
+		new_crypt = kmalloc(sizeof(struct ieee80211_crypt_data),
+				    GFP_KERNEL);
+		if (new_crypt == NULL)
+			return -ENOMEM;
+		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
+		new_crypt->ops = ieee80211_get_crypto_ops("WEP");
+		if (!new_crypt->ops) {
+			request_module("ieee80211_crypt_wep");
+			new_crypt->ops = ieee80211_get_crypto_ops("WEP");
+		}
+
+		if (new_crypt->ops && try_module_get(new_crypt->ops->owner))
+			new_crypt->priv = new_crypt->ops->init(key);
+
+		if (!new_crypt->ops || !new_crypt->priv) {
+			kfree(new_crypt);
+			new_crypt = NULL;
+
+			printk(KERN_WARNING "%s: could not initialize WEP: "
+			       "load module ieee80211_crypt_wep\n",
+			       dev->name);
+			return -EOPNOTSUPP;
+		}
+		*crypt = new_crypt;
+	}
+
+	/* If a new key was provided, set it up */
+	if (erq->length > 0) {
+		len = erq->length <= 5 ? 5 : 13;
+		memcpy(sec.keys[key], keybuf, erq->length);
+		if (len > erq->length)
+			memset(sec.keys[key] + erq->length, 0,
+			       len - erq->length);
+		IEEE80211_DEBUG_WX("Setting key %d to '%s' (%d:%d bytes)\n",
+				   key, escape_essid(sec.keys[key], len),
+				   erq->length, len);
+		sec.key_sizes[key] = len;
+ 		(*crypt)->ops->set_key(sec.keys[key], len, NULL,
+				       (*crypt)->priv);
+		sec.flags |= (1 << key);
+		/* This ensures a key will be activated if no key is
+		 * explicitely set */
+		if (key == sec.active_key)
+			sec.flags |= SEC_ACTIVE_KEY;
+	} else {
+		len = (*crypt)->ops->get_key(sec.keys[key], WEP_KEY_LEN,
+					     NULL, (*crypt)->priv);
+		if (len == 0) {
+			/* Set a default key of all 0 */
+			IEEE80211_DEBUG_WX("Setting key %d to all zero.\n",
+					   key);
+			memset(sec.keys[key], 0, 13);
+			(*crypt)->ops->set_key(sec.keys[key], 13, NULL,
+					       (*crypt)->priv);
+			sec.key_sizes[key] = 13;
+			sec.flags |= (1 << key);
+		}
+
+		/* No key data - just set the default TX key index */
+		if (key_provided) {
+			IEEE80211_DEBUG_WX(
+				"Setting key %d to default Tx key.\n", key);
+			ieee->tx_keyidx = key;
+			sec.active_key = key;
+			sec.flags |= SEC_ACTIVE_KEY;
+		}
+	}
+
+ done:
+	ieee->open_wep = !(erq->flags & IW_ENCODE_RESTRICTED);
+	sec.auth_mode = ieee->open_wep ? WLAN_AUTH_OPEN : WLAN_AUTH_SHARED_KEY;
+	sec.flags |= SEC_AUTH_MODE;
+	IEEE80211_DEBUG_WX("Auth: %s\n", sec.auth_mode == WLAN_AUTH_OPEN ?
+			   "OPEN" : "SHARED KEY");
+
+	/* For now we just support WEP, so only set that security level...
+	 * TODO: When WPA is added this is one place that needs to change */
+	sec.flags |= SEC_LEVEL;
+	sec.level = SEC_LEVEL_1; /* 40 and 104 bit WEP */
+
+	if (ieee->set_security)
+		ieee->set_security(dev, &sec);
+
+	/* Do not reset port if card is in Managed mode since resetting will
+	 * generate new IEEE 802.11 authentication which may end up in looping
+	 * with IEEE 802.1X.  If your hardware requires a reset after WEP
+	 * configuration (for example... Prism2), implement the reset_port in
+	 * the callbacks structures used to initialize the 802.11 stack. */
+	if (ieee->reset_on_keychange &&
+	    ieee->iw_mode != IW_MODE_INFRA &&
+	    ieee->reset_port && ieee->reset_port(dev)) {
+		printk(KERN_DEBUG "%s: reset_port failed\n", dev->name);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+int ieee80211_wx_get_encode(struct ieee80211_device *ieee,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *keybuf)
+{
+	struct iw_point *erq = &(wrqu->encoding);
+	int len, key;
+	struct ieee80211_crypt_data *crypt;
+
+	IEEE80211_DEBUG_WX("GET_ENCODE\n");
+
+	key = erq->flags & IW_ENCODE_INDEX;
+	if (key) {
+		if (key > WEP_KEYS)
+			return -EINVAL;
+		key--;
+	} else
+		key = ieee->tx_keyidx;
+
+	crypt = ieee->crypt[key];
+	erq->flags = key + 1;
+
+	if (crypt == NULL || crypt->ops == NULL) {
+		erq->length = 0;
+		erq->flags |= IW_ENCODE_DISABLED;
+		return 0;
+	}
+
+	if (strcmp(crypt->ops->name, "WEP") != 0) {
+		/* only WEP is supported with wireless extensions, so just
+		 * report that encryption is used */
+		erq->length = 0;
+		erq->flags |= IW_ENCODE_ENABLED;
+		return 0;
+	}
+
+	len = crypt->ops->get_key(keybuf, WEP_KEY_LEN, NULL, crypt->priv);
+	erq->length = (len >= 0 ? len : 0);
+
+	erq->flags |= IW_ENCODE_ENABLED;
+
+	if (ieee->open_wep)
+		erq->flags |= IW_ENCODE_OPEN;
+	else
+		erq->flags |= IW_ENCODE_RESTRICTED;
+
+	return 0;
+}
+
+EXPORT_SYMBOL(ieee80211_wx_get_scan);
+EXPORT_SYMBOL(ieee80211_wx_set_encode);
+EXPORT_SYMBOL(ieee80211_wx_get_encode);

--------------040200080309090603080508
Content-Type: text/plain;
 name="TODO"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TODO"

-------

>From Randy Dunlap:

3.  +static int __init ieee80211_crypto_init(void)
+    (void) ieee80211_register_crypto_ops(&ieee80211_crypt_null);

That register call can fail, so I'd rather see it checked, as in all
of the other similar register calls.


6.  +struct ieee80211_ccmp_data {

+    u32 dot11RSNAStatsCCMPFormatErrors;
+    u32 dot11RSNAStatsCCMPReplays;
+    u32 dot11RSNAStatsCCMPDecryptErrors;

Are these MIB-mandated names?  otherwise the studlyCaps should go.

7.  +static int ieee80211_ccmp_decrypt()

Does anything care about the various negative/error case return
values?

8.  What calls the .print_stats functions?
static char * ieee80211_ccmp_print_stats()

Is it possible to use seq_file there instead of sprintf(),
or is this in /sysfs (so seq_file is not possible)?
Are there any overflow possibilities?

Enough for tonight...
Here are a few more comments.

1.  No need to check ptr for NULL before kfree(ptr), so several
places like this can be simplified:

+fail:
+    if (priv) {
+        if (priv->tfm)
+            crypto_free_tfm(priv->tfm);
+        kfree(priv);
+    }


3.  +static inline int ieee80211_network_init()
is more than 200 lines.  Somebody likes huge inline functions.

-------------------------
>From Stephen Hemminger


1. You can get rid of the /proc interface altogether since now 
with sysfs module parameters can be made accessible via module_param

2. Include files need to be moved and factored better:
	include/linux/ieee80211.h for anything exposed to utilities and
	   general API related
	include/net/ieee80211.h for interfaces other drivers would use.
	drivers/net/wireless/iee80211/iee80211_xxx.h for stuff that
	   only gets used internally.


4. Don't put data in .h files like eap_types[]
   Maybe just move eap_get_type() to .c fle

5. Use C99 initializers for tags arrays like eap_types[]
 i.e static const char *eap_types[] = {
	[EAP_PACKET] = "EAP-Packet",
...
	
5. Move is_broadcast_addr and is_multicast_addr to etherdevice.h
   besides is_muliticast_addr(x) has extra uneeded test.

6. Don't put format type stuff in .h file MAC_FMT, MAC_ARG, etc...

8. Patch if_ether.h rather than stuff like:
 	#ifndef ETH_P_80211_RAW
 	#define ETH_P_80211_RAW (ETH_P_ECONET + 1)
	#endif

9. Isn't SNAP generic and not part of just wireless, LLC and other places
   like ATM have the similar stuff, maybe one set of routines and definitions?

10. Do we really need another set of statistics?  Already have ethtool, net_stats, wireless, ...?

11. Does ieee->scans need to be atomic?

12.  offset_in_page() shouldn't be here and is defined elsewhere.

The basic philosophy changes as this gets incorporated in mailine kernel.
You need to feel free to patch in several existing header files rather than
standing alone as required in an out of tree driver.

----

>From Jouni Malinen

>When you look through the patch you'll likely notice the #ifdef 
>> NOTYET/#endif sequences surrounding portions of code from the hostap 
>> project.  Portions of this subsystem were based on an earlier version of 
>> the hostap project.  Those areas that weren't directly supported by the 
>> ipw* projects weren't ported to be completely hardware independent 
>> (since I don't have the hardware to test it), and so are still wrapped 
>> in the ifdefs.  These sections mainly cover support for MASTER and WDS 
>> modes.


We will need to take care of these areas in order to be able to call
this "generic IEEE 802.11 networking stack".. I would like to be able to
test replacing the upper level code in Host AP driver with this and
verify that all functionality is still available. Another useful test
case would be to go through what needs to be done to make this work with
the madwifi driver (i.e., merge some parts of net80211 code with this
and make the low-level parts of the driver use the combination for IEEE
802.11 processing).
>+static void * ieee80211_ccmp_init(int key_idx)
>> +{
>> +	struct ieee80211_ccmp_data *priv;
>> +
>> +	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);


You do not seem to include try_module_get(THIS_MODULE) here (and
matching module_put in deinit) like the version in Host AP driver is
using. What is protecting the CCMP/TKIP modules from being unloaded when
they are still used?





--------------040200080309090603080508--
