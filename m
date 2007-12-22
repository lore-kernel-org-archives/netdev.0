From: Bjorge Dijkstra <bjd@jooz.net>
Subject: [PATCH 7/8] Add Wireless Extensions to rndis_host
Date: Sat, 22 Dec 2007 22:51:33 +0100
Message-ID: <11983602951628-git-send-email-bjd@jooz.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:26454 "EHLO
	viefep33-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753502AbXLVVvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 16:51:36 -0500
In-Reply-To: <11983602942818-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bulk of this patch is the addition of a new file that
implements the wireless extensions for RNDIS devices.
The rest are some smaller changes to usbnet and rndis_host
to hook the wireless extensions into them:
* a private data pointer is added to usbnet.
* a callback is added to driver_info to signal link state changes.
* a physical medium type check is added to rndis_bind to check for
  wireless lan devices and turn on the wireless extensions.
* and finally a Kconfig option to enable/disable this all.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>
---
 drivers/net/usb/Kconfig      |    7 +
 drivers/net/usb/Makefile     |    4 +
 drivers/net/usb/rndis_base.c |   50 +-
 drivers/net/usb/rndis_host.h |   18 +
 drivers/net/usb/rndis_wext.c | 2177 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/usbnet.h     |    4 +
 6 files changed, 2255 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/usb/rndis_wext.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index a12c9c4..cc38294 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -239,6 +239,13 @@ config USB_NET_RNDIS_HOST
 	  The protocol specification is incomplete, and is controlled by
 	  (and for) Microsoft; it isn't an "Open" ecosystem or market.
 
+config USB_NET_RNDIS_WEXT
+	boolean "Wireless Extensions for RNDIS host driver"
+	depends on USB_NET_RNDIS_HOST && WLAN_80211 && EXPERIMENTAL
+	select WIRELESS_EXT
+	help
+	  This option enables support for RNDIS based wireless LAN devices.
+
 config USB_NET_CDC_SUBSET
 	tristate "Simple USB Network Links (CDC Ethernet subset)"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 611ab62..83c14f1 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -14,6 +14,10 @@ obj-$(CONFIG_USB_NET_NET1080)	+= net1080.o
 obj-$(CONFIG_USB_NET_PLUSB)	+= plusb.o
 obj-$(CONFIG_USB_NET_RNDIS_HOST)	+= rndis_host.o
 rndis_host-objs			+= rndis_base.o
+ifeq ($(CONFIG_USB_NET_RNDIS_WEXT),y)
+rndis_host-objs += rndis_wext.o
+endif
+
 obj-$(CONFIG_USB_NET_CDC_SUBSET)	+= cdc_subset.o
 obj-$(CONFIG_USB_NET_ZAURUS)	+= zaurus.o
 obj-$(CONFIG_USB_NET_MCS7830)	+= mcs7830.o
diff --git a/drivers/net/usb/rndis_base.c b/drivers/net/usb/rndis_base.c
index f3b0c00..97faaed 100644
--- a/drivers/net/usb/rndis_base.c
+++ b/drivers/net/usb/rndis_base.c
@@ -148,10 +148,26 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
 					request_id, xid);
 				/* then likely retry */
 			} else switch (buf->msg_type) {
-			case RNDIS_MSG_INDICATE: {	/* fault */
-				// struct rndis_indicate *msg = (void *)buf;
-				dev_info(&info->control->dev,
-					"rndis fault indication\n");
+			case RNDIS_MSG_INDICATE: {	/* fault/event */
+				struct rndis_indicate *msg = (void *)buf;
+
+				switch (msg->status) {
+				case RNDIS_STATUS_MEDIA_CONNECT:
+					dev_info(&info->control->dev,
+						"rndis media connect\n");
+					if (dev->driver_info->link_change)
+					    dev->driver_info->link_change(dev, 1);
+					break;
+				case RNDIS_STATUS_MEDIA_DISCONNECT:
+					dev_info(&info->control->dev,
+						"rndis media disconnect\n");
+					if (dev->driver_info->link_change)
+					    dev->driver_info->link_change(dev, 0);
+					break;
+				default:
+					dev_info(&info->control->dev,
+						"rndis indication\n");
+				}
 				}
 				break;
 			case RNDIS_MSG_KEEPALIVE: {	/* ping */
@@ -271,7 +287,7 @@ int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
 		struct rndis_set_c	*set_c;
 		struct rndis_halt	*halt;
 	} u;
-	u32			tmp;
+	u32			tmp, *phym;
 	int			reply_len;
 	unsigned char		*bp;
 
@@ -336,6 +352,30 @@ int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
 		dev->hard_mtu, tmp, dev->rx_urb_size,
 		1 << le32_to_cpu(u.init_c->packet_alignment));
 
+	/* Check physical medium */
+	reply_len = sizeof *phym;
+	retval = rndis_query(dev, intf, u.buf, OID_GEN_PHYSICAL_MEDIUM,
+			0, (void **) &phym, &reply_len);
+	if (retval != 0) {
+		dev_err(&intf->dev, "rndis get physical medium, %d\n", retval);
+		tmp = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
+	} else
+		tmp = *phym;
+
+	if (tmp == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
+#ifdef CONFIG_USB_NET_RNDIS_WEXT
+		dev_info(&info->control->dev, "RNDIS wlan device,"
+				" turning on wireless extensions\n");
+		dev->driver_info = &rndis_wext_info;
+		retval = dev->driver_info->bind(dev, intf);
+		if (retval < 0)
+			goto halt_fail_and_release;
+#else
+		dev_info(&info->control->dev, "RNDIS wlan device,"
+				" wireless extensions not available\n");
+#endif
+	}
+
 	/* Get designated host ethernet address */
 	reply_len = ETH_ALEN;
 	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
diff --git a/drivers/net/usb/rndis_host.h b/drivers/net/usb/rndis_host.h
index 56de532..6427315 100644
--- a/drivers/net/usb/rndis_host.h
+++ b/drivers/net/usb/rndis_host.h
@@ -82,6 +82,18 @@ struct rndis_msg_hdr {
 #define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
 #define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
 
+/* codes for OID_GEN_PHYSICAL_MEDIUM */
+#define RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED       ccpu2(0x00000000)
+#define RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN      ccpu2(0x00000001)
+#define RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM       ccpu2(0x00000002)
+#define RNDIS_PHYSICAL_MEDIUM_PHONE_LINE        ccpu2(0x00000003)
+#define RNDIS_PHYSICAL_MEDIUM_POWER_LINE        ccpu2(0x00000004)
+#define RNDIS_PHYSICAL_MEDIUM_DSL               ccpu2(0x00000005)
+#define RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL     ccpu2(0x00000006)
+#define RNDIS_PHYSICAL_MEDIUM_1394              ccpu2(0x00000007)
+#define RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN      ccpu2(0x00000008)
+#define RNDIS_PHYSICAL_MEDIUM_MAX               ccpu2(0x00000009)
+
 
 struct rndis_data_hdr {
 	__le32	msg_type;		/* RNDIS_MSG_PACKET */
@@ -222,6 +234,7 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
 #define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
 #define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
 #define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
+#define OID_GEN_PHYSICAL_MEDIUM		ccpu2(0x00010202)
 
 /* packet filter bits used by NDIS_OID_PACKET_FILTER */
 #define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
@@ -252,5 +265,10 @@ extern int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb);
 extern struct sk_buff *
 rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
 
+#ifdef CONFIG_USB_NET_RNDIS_WEXT
+/* from rndis_wext.c */
+extern struct driver_info rndis_wext_info;
+#endif
+
 #endif	/* __RNDIS_HOST_H */
 
diff --git a/drivers/net/usb/rndis_wext.c b/drivers/net/usb/rndis_wext.c
new file mode 100644
index 0000000..a9ce944
--- /dev/null
+++ b/drivers/net/usb/rndis_wext.c
@@ -0,0 +1,2177 @@
+/*
+ * Wireless Extensions for RNDIS host
+ * Copyright (C) 2007 by Bjorge Dijkstra (bjd@jooz.net)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Portions of this file are based on NDISwrapper project,
+ * Copyright (C) 2003-2005 Pontus Fuchs, Giridhar Pemmasani
+ * http://ndiswrapper.sourceforge.net/
+ */
+
+// #define	DEBUG			// error path messages, extra info
+// #define	VERBOSE			// more; success messages
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/workqueue.h>
+#include <linux/mutex.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include <linux/wireless.h>
+#include <linux/if_arp.h>
+#include <net/iw_handler.h>
+#include <net/ieee80211.h>
+
+
+#include "usbnet.h"
+#include "rndis_host.h"
+
+/* various RNDIS OID defs */
+#define OID_GEN_LINK_SPEED			ccpu2(0x00010107)
+#define OID_GEN_RNDIS_CONFIG_PARAMETER		ccpu2(0x0001021b)
+
+#define OID_802_3_PERMANENT_ADDRESS		ccpu2(0x01010101)
+#define OID_802_3_CURRENT_ADDRESS		ccpu2(0x01010102)
+#define OID_802_3_MULTICAST_LIST        	ccpu2(0x01010103)
+
+#define OID_802_11_BSSID			ccpu2(0x0d010101)
+#define OID_802_11_SSID				ccpu2(0x0d010102)
+#define OID_802_11_INFRASTRUCTURE_MODE		ccpu2(0x0d010108)
+#define OID_802_11_ADD_WEP			ccpu2(0x0d010113)
+#define OID_802_11_REMOVE_WEP			ccpu2(0x0d010114)
+#define OID_802_11_DISASSOCIATE			ccpu2(0x0d010115)
+#define OID_802_11_AUTHENTICATION_MODE		ccpu2(0x0d010118)
+#define OID_802_11_PRIVACY_FILTER		ccpu2(0x0d010119)
+#define OID_802_11_BSSID_LIST_SCAN		ccpu2(0x0d01011a)
+#define OID_802_11_ENCRYPTION_STATUS		ccpu2(0x0d01011b)
+#define OID_802_11_ADD_KEY			ccpu2(0x0d01011d)
+#define OID_802_11_REMOVE_KEY			ccpu2(0x0d01011e)
+#define OID_802_11_PMKID			ccpu2(0x0d010123)
+#define OID_802_11_NETWORK_TYPES_SUPPORTED	ccpu2(0x0d010203)
+#define OID_802_11_NETWORK_TYPE_IN_USE		ccpu2(0x0d010204)
+#define OID_802_11_TX_POWER_LEVEL		ccpu2(0x0d010205)
+#define OID_802_11_RSSI				ccpu2(0x0d010206)
+#define OID_802_11_RSSI_TRIGGER			ccpu2(0x0d010207)
+#define OID_802_11_FRAGMENTATION_THRESHOLD	ccpu2(0x0d010209)
+#define OID_802_11_RTS_THRESHOLD		ccpu2(0x0d01020a)
+#define OID_802_11_SUPPORTED_RATES		ccpu2(0x0d01020e)
+#define OID_802_11_CONFIGURATION		ccpu2(0x0d010211)
+#define OID_802_11_BSSID_LIST			ccpu2(0x0d010217)
+#define OID_802_11_STATISTICS			ccpu2(0x0d020212)
+
+
+/* Typical noise/maximum signal level values taken from ndiswrapper iw_ndis.h */
+#define	WL_NOISE	-96	/* typical noise level in dBm */
+#define	WL_SIGMAX	-32	/* typical maximum signal level in dBm */
+
+
+/* Assume that Broadcom 4320 (only chipset at time of writing known to be
+ * based on wireless rndis) has default txpower of 13dBm as Linksys WUSB54GSC.
+ * This value is from Linksys WUSB54GSC User Guide, Appendix F: Specifications.
+ *   13dBm == 19.9mW
+ */
+#define BCM4320_DEFAULT_TXPOWER 20
+
+
+/* codes for "status" field of completion messages */
+#define RNDIS_STATUS_ADAPTER_NOT_READY		ccpu2(0xc0010011)
+#define RNDIS_STATUS_ADAPTER_NOT_OPEN		ccpu2(0xc0010012)
+
+
+/* NDIS data structures. Taken from wpa_supplicant driver_ndis.c
+ * slightly modified for datatype endianess, etc
+ */
+#define NDIS_802_11_LENGTH_SSID 32
+#define NDIS_802_11_LENGTH_RATES 8
+#define NDIS_802_11_LENGTH_RATES_EX 16
+
+struct NDIS_802_11_SSID {
+	__le32 SsidLength;
+	u8 Ssid[NDIS_802_11_LENGTH_SSID];
+};
+
+enum NDIS_802_11_NETWORK_TYPE {
+	Ndis802_11FH,
+	Ndis802_11DS,
+	Ndis802_11OFDM5,
+	Ndis802_11OFDM24,
+	Ndis802_11NetworkTypeMax
+};
+
+struct NDIS_802_11_CONFIGURATION_FH {
+	__le32 Length;
+	__le32 HopPattern;
+	__le32 HopSet;
+	__le32 DwellTime;
+};
+
+struct NDIS_802_11_CONFIGURATION {
+	__le32 Length;
+	__le32 BeaconPeriod;
+	__le32 ATIMWindow;
+	__le32 DSConfig;
+	struct NDIS_802_11_CONFIGURATION_FH FHConfig;
+};
+
+struct NDIS_802_11_STATS {
+	__le32 Length;
+	__le64 TxFrag;
+	__le64 TxMultiFrag;
+	__le64 Failed;
+	__le64 Retry;
+	__le64 MultiRetry;
+	__le64 RtssSucc;
+	__le64 RtssFail;
+	__le64 AckFail;
+	__le64 FrameDup;
+	__le64 RxFrag;
+	__le64 RxMultiFrag;
+	__le64 FcsErr;
+	__le64 TkipLocalMicFailures;
+	__le64 TkipIcvErrors;
+	__le64 TkipCounterMeasuresInvoked;
+	__le64 TkipReplays;
+	__le64 CcmpFormatErrors;
+	__le64 CcmpReplays;
+	__le64 CcmpDecryptErrors;
+	__le64 FourwayHandshakeFailures;
+	__le64 WepUndecryptableCount;
+	__le64 WepIcvErrorcount;
+	__le64 DecryptSuccessCount;
+	__le64 DecryptFailureCount;
+} __attribute__((packed));
+
+enum NDIS_802_11_NETWORK_INFRASTRUCTURE {
+	Ndis802_11IBSS,
+	Ndis802_11Infrastructure,
+	Ndis802_11AutoUnknown,
+	Ndis802_11InfrastructureMax
+};
+
+enum NDIS_802_11_AUTHENTICATION_MODE {
+	Ndis802_11AuthModeOpen,
+	Ndis802_11AuthModeShared,
+	Ndis802_11AuthModeAutoSwitch,
+	Ndis802_11AuthModeWPA,
+	Ndis802_11AuthModeWPAPSK,
+	Ndis802_11AuthModeWPANone,
+	Ndis802_11AuthModeWPA2,
+	Ndis802_11AuthModeWPA2PSK,
+	Ndis802_11AuthModeMax
+};
+
+enum NDIS_802_11_ENCRYPTION_STATUS {
+	Ndis802_11WEPEnabled,
+	Ndis802_11Encryption1Enabled = Ndis802_11WEPEnabled,
+	Ndis802_11WEPDisabled,
+	Ndis802_11EncryptionDisabled = Ndis802_11WEPDisabled,
+	Ndis802_11WEPKeyAbsent,
+	Ndis802_11Encryption1KeyAbsent = Ndis802_11WEPKeyAbsent,
+	Ndis802_11WEPNotSupported,
+	Ndis802_11EncryptionNotSupported = Ndis802_11WEPNotSupported,
+	Ndis802_11Encryption2Enabled,
+	Ndis802_11Encryption2KeyAbsent,
+	Ndis802_11Encryption3Enabled,
+	Ndis802_11Encryption3KeyAbsent
+};
+
+enum NDIS_802_11_PRIVACY_FILTER {
+	Ndis802_11PrivFilterAcceptAll,
+	Ndis802_11PrivFilter8021xWEP
+};
+
+struct NDIS_WLAN_BSSID_EX {
+	__le32 Length;
+	u8 MacAddress[6];
+	u8 Padding[2];
+	struct NDIS_802_11_SSID Ssid;
+	__le32 Privacy;
+	__le32 Rssi;
+	enum NDIS_802_11_NETWORK_TYPE NetworkTypeInUse;
+	struct NDIS_802_11_CONFIGURATION Configuration;
+	enum NDIS_802_11_NETWORK_INFRASTRUCTURE InfrastructureMode;
+	u8 SupportedRates[NDIS_802_11_LENGTH_RATES_EX];
+	__le32 IELength;
+	u8 IEs[0];
+};
+
+struct NDIS_802_11_BSSID_LIST_EX {
+	__le32 NumberOfItems;
+	struct NDIS_WLAN_BSSID_EX Bssid[0];
+};
+
+struct NDIS_802_11_FIXED_IEs {
+	u8 Timestamp[8];
+	__le16 BeaconInterval;
+	__le16 Capabilities;
+};
+
+struct NDIS_802_11_WEP {
+	__le32 Length;
+	__le32 KeyIndex;
+	__le32 KeyLength;
+	u8 KeyMaterial[0];
+};
+
+struct NDIS_802_11_KEY {
+	__le32 Length;
+	__le32 KeyIndex;
+	__le32 KeyLength;
+	u8 Bssid[6];
+	u8 Padding[6];
+	u8 KeyRSC[8];
+	u8 KeyMaterial[32];
+};
+
+struct NDIS_802_11_REMOVE_KEY {
+	__le32 Length;
+	__le32 KeyIndex;
+	u8 Bssid[6];
+};
+
+struct RNDIS_CONFIG_PARAMETER_INFOBUFFER {
+	__le32 ParameterNameOffset;
+	__le32 ParameterNameLength;
+	__le32 ParameterType;
+	__le32 ParameterValueOffset;
+	__le32 ParameterValueLength;
+} __attribute__((packed));
+
+/*
+ *  private data
+ */
+#define NET_TYPE_11FB	0
+
+#define CAP_MODE_80211A		1
+#define CAP_MODE_80211B		2
+#define CAP_MODE_80211G		4
+#define CAP_MODE_MASK		7
+#define CAP_SUPPORT_TXPOWER	8
+
+/* RNDIS device private data */
+struct rndis_wext_private {
+	char name[32];
+
+	struct usbnet *usbdev;
+
+	struct workqueue_struct *workqueue;
+	struct delayed_work stats_work;
+	struct work_struct work;
+	struct mutex command_lock;
+	struct mutex stats_lock;
+
+	struct iw_statistics iwstats;
+	struct iw_statistics privstats;
+	int  nick_len;
+	char nick[32];
+
+	int caps;
+	int mode;
+	int radio_on;
+
+	/* general encryption stuff */
+	int privacy;
+
+	/* wep stuff */
+	int  wep_def_key;
+	int  wep_enabled;
+	char wep_keys[4][13];
+	int  wep_key_len[4];
+
+	/* wpa stuff */
+	int wpa_enabled;
+	int wpa_version;
+	int wpa_keymgmt;
+	int wpa_authalg;
+	int wpa_ie_len;
+	u8 *wpa_ie;
+	int wpa_cipher_pair;
+	int wpa_cipher_group;
+	struct NDIS_802_11_KEY wpa_keys[4];
+};
+
+
+static const int freq_chan[] = { 2412, 2417, 2422, 2427, 2432, 2437, 2442,
+				2447, 2452, 2457, 2462, 2467, 2472, 2484 };
+
+static const int rates_80211g[8] = { 6, 9, 12, 18, 24, 36, 48, 54 };
+
+static const int bcm4320_power_output[4] = { 25, 50, 75, 100 };
+
+static const unsigned char zero_bssid[ETH_ALEN] = {0,};
+
+
+static inline struct rndis_wext_private *get_rndis_wext_priv(struct usbnet *dev)
+{
+	return (struct rndis_wext_private *)dev->driver_priv;
+}
+
+
+static inline u32 get_bcm4320_power(struct rndis_wext_private *priv)
+{
+	return BCM4320_DEFAULT_TXPOWER;
+}
+
+
+/* translate error code */
+static int rndis_error_status(__le32 rndis_status)
+{
+	int ret = -EINVAL;
+	switch (rndis_status) {
+	case RNDIS_STATUS_SUCCESS:
+		ret = 0;
+		break;
+	case RNDIS_STATUS_FAILURE:
+	case RNDIS_STATUS_INVALID_DATA:
+		ret = -EINVAL;
+		break;
+	case RNDIS_STATUS_NOT_SUPPORTED:
+		ret = -EOPNOTSUPP;
+		break;
+	case RNDIS_STATUS_ADAPTER_NOT_READY:
+	case RNDIS_STATUS_ADAPTER_NOT_OPEN:
+		ret = -EBUSY;
+		break;
+	}
+	return ret;
+}
+
+
+static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(dev);
+	union {
+		void			*buf;
+		struct rndis_msg_hdr	*header;
+		struct rndis_query	*get;
+		struct rndis_query_c	*get_c;
+	} u;
+	int ret, buflen;
+
+	buflen = *len + sizeof(*u.get);
+	if (buflen < CONTROL_BUFFER_SIZE)
+		buflen = CONTROL_BUFFER_SIZE;
+	u.buf = kmalloc(buflen, GFP_KERNEL);
+	if (!u.buf)
+		return -ENOMEM;
+	memset(u.get, 0, sizeof *u.get);
+	u.get->msg_type = RNDIS_MSG_QUERY;
+	u.get->msg_len = ccpu2(sizeof *u.get);
+	u.get->oid = oid;
+
+	mutex_lock(&priv->command_lock);
+	ret = rndis_command(dev, u.header);
+	mutex_unlock(&priv->command_lock);
+
+	if (ret == 0) {
+		ret = le32_to_cpu(u.get_c->len);
+		*len = (*len > ret) ? ret : *len;
+		memcpy(data, u.buf + le32_to_cpu(u.get_c->offset) + 8, *len);
+		ret = rndis_error_status(u.get_c->status);
+	}
+
+	kfree(u.buf);
+	return ret;
+}
+
+
+static int rndis_set_oid(struct usbnet *dev, __le32 oid, void *data, int len)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(dev);
+	union {
+		void			*buf;
+		struct rndis_msg_hdr	*header;
+		struct rndis_set	*set;
+		struct rndis_set_c	*set_c;
+	} u;
+	int ret, buflen;
+
+	buflen = len + sizeof(*u.set);
+	if (buflen < CONTROL_BUFFER_SIZE)
+		buflen = CONTROL_BUFFER_SIZE;
+	u.buf = kmalloc(buflen, GFP_KERNEL);
+	if (!u.buf)
+		return -ENOMEM;
+
+	memset(u.set, 0, sizeof *u.set);
+	u.set->msg_type = RNDIS_MSG_SET;
+	u.set->msg_len = cpu_to_le32(sizeof(*u.set) + len);
+	u.set->oid = oid;
+	u.set->len = cpu_to_le32(len);
+	u.set->offset = ccpu2(sizeof(*u.set) - 8);
+	u.set->handle = ccpu2(0);
+	memcpy(u.buf + sizeof(*u.set), data, len);
+
+	mutex_lock(&priv->command_lock);
+	ret = rndis_command(dev, u.header);
+	mutex_unlock(&priv->command_lock);
+
+	if (ret == 0)
+		ret = rndis_error_status(u.set_c->status);
+
+	kfree(u.buf);
+	return ret;
+}
+
+
+/*
+ * Specs say that we can only set config parameters only soon after device
+ * initialization.
+ *   value_type: 0 = u32, 2 = unicode string
+ */
+static int rndis_set_config_parameter(struct usbnet *dev, char *param,
+						int value_type, void *value)
+{
+	struct RNDIS_CONFIG_PARAMETER_INFOBUFFER *infobuf;
+	int value_len, info_len, param_len, ret, i;
+	__le16 *unibuf;
+	__le32 *dst_value;
+
+	if (value_type == 0)
+		value_len = sizeof(__le32);
+	else if (value_type == 2)
+		value_len = strlen(value) * sizeof(__le16);
+	else
+		return -EINVAL;
+
+	param_len = strlen(param) * sizeof(__le16);
+	info_len = sizeof(*infobuf) + param_len + value_len;
+
+	infobuf = kmalloc(info_len + 12, GFP_KERNEL);
+	if (!infobuf)
+		return -ENOMEM;
+
+#ifdef DEBUG
+	/* extra 12 bytes are for padding (debug output) */
+	memset(infobuf, 0xCC, info_len + 12);
+#endif
+
+	if (value_type == 2)
+		devdbg(dev, "setting config parameter: %s, value: %s",
+						param, (u8 *)value);
+	else
+		devdbg(dev, "setting config parameter: %s, value: %d",
+						param, *(u32 *)value);
+
+	infobuf->ParameterNameOffset = cpu_to_le32(sizeof(*infobuf));
+	infobuf->ParameterNameLength = cpu_to_le32(param_len);
+	infobuf->ParameterType = cpu_to_le32(value_type);
+	infobuf->ParameterValueOffset = cpu_to_le32(sizeof(*infobuf) +
+								param_len);
+	infobuf->ParameterValueLength = cpu_to_le32(value_len);
+
+	/* simple string to unicode string conversion */
+	unibuf = (void *)infobuf + sizeof(*infobuf);
+	for (i = 0; i < param_len / sizeof(__le16); i++)
+		unibuf[i] = cpu_to_le16(param[i]);
+
+	if (value_type == 2) {
+		unibuf = (void *)infobuf + sizeof(*infobuf) + param_len;
+		for (i = 0; i < value_len / sizeof(__le16); i++)
+			unibuf[i] = cpu_to_le16(((u8 *)value)[i]);
+	} else {
+		dst_value = (void *)infobuf + sizeof(*infobuf) + param_len;
+		*dst_value = cpu_to_le32(*(u32 *)value);
+	}
+
+#ifdef DEBUG
+	devdbg(dev, "info buffer (len: %d):", info_len);
+	for (i = 0; i < info_len; i += 12) {
+		u32 *tmp = (u32 *)((u8 *)infobuf + i);
+		devdbg(dev, "%08X:%08X:%08X",
+			cpu_to_be32(tmp[0]),
+			cpu_to_be32(tmp[1]),
+			cpu_to_be32(tmp[2]));
+	}
+#endif
+
+	ret = rndis_set_oid(dev, OID_GEN_RNDIS_CONFIG_PARAMETER,
+							infobuf, info_len);
+	if (ret != 0)
+		devdbg(dev, "setting rndis config parameter failed, %d.", ret);
+
+	kfree(infobuf);
+	return ret;
+}
+
+static inline int rndis_set_config_parameter_str(struct usbnet *dev,
+						char *param, char *value)
+{
+	return(rndis_set_config_parameter(dev, param, 2, value));
+}
+
+static inline int rndis_set_config_parameter_u32(struct usbnet *dev,
+						char *param, u32 value)
+{
+	return(rndis_set_config_parameter(dev, param, 0, &value));
+}
+
+
+/*
+ * data conversion functions
+ */
+static inline int level_to_qual(int level)
+{
+	int qual = 100 * (level - WL_NOISE) / (WL_SIGMAX - WL_NOISE);
+	return qual >= 0 ? (qual <= 100 ? qual : 100) : 0;
+}
+
+
+static inline void dsconfig_to_freq(unsigned int dsconfig, struct iw_freq *freq)
+{
+	freq->e = 0;
+	freq->i = 0;
+	freq->flags = 0;
+
+	/* see comment in wireless.h above the "struct iw_freq"
+	 * definition for an explanation of this if
+	 * NOTE: 1000000 is due to the kHz
+	 */
+	if (dsconfig > 1000000) {
+		freq->m = dsconfig / 10;
+		freq->e = 1;
+	} else
+		freq->m = dsconfig;
+
+	/* convert from kHz to Hz */
+	freq->e += 3;
+}
+
+
+static inline int freq_to_dsconfig(struct iw_freq *freq, unsigned int *dsconfig)
+{
+	if (freq->m < 1000 && freq->e == 0) {
+		if (freq->m >= 1 &&
+			freq->m <= (sizeof(freq_chan) / sizeof(freq_chan[0])))
+			*dsconfig = freq_chan[freq->m - 1] * 1000;
+		else
+			return -1;
+	} else {
+		int i;
+		*dsconfig = freq->m;
+		for (i = freq->e; i > 0; i--)
+			*dsconfig *= 10;
+		*dsconfig /= 1000;
+	}
+
+	return 0;
+}
+
+
+/*
+ * common functions
+ */
+static void set_default_iw_params(struct usbnet *dev)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(dev);
+	__le32 tmp;
+
+	priv->wpa_keymgmt = 0;
+	priv->wpa_version = 0;
+
+	tmp = cpu_to_le32(Ndis802_11Infrastructure);
+	rndis_set_oid(dev, OID_802_11_INFRASTRUCTURE_MODE, &tmp, sizeof(tmp));
+	tmp = cpu_to_le32(Ndis802_11EncryptionDisabled);
+	rndis_set_oid(dev, OID_802_11_ENCRYPTION_STATUS, &tmp, sizeof(tmp));
+	tmp = cpu_to_le32(Ndis802_11AuthModeOpen);
+	rndis_set_oid(dev, OID_802_11_AUTHENTICATION_MODE, &tmp, sizeof(tmp));
+	tmp = cpu_to_le32(Ndis802_11PrivFilter8021xWEP);
+	rndis_set_oid(dev, OID_802_11_PRIVACY_FILTER, &tmp, sizeof(tmp));
+}
+
+
+static int get_essid(struct usbnet *usbdev, struct NDIS_802_11_SSID *ssid)
+{
+	int ret, len;
+
+	len = sizeof(*ssid);
+	ret = rndis_query_oid(usbdev, OID_802_11_SSID, ssid, &len);
+
+	if (ret != 0)
+		ssid->SsidLength = 0;
+
+#ifdef DEBUG
+	{
+		unsigned char tmp[NDIS_802_11_LENGTH_SSID + 1];
+
+		memcpy(tmp, ssid->Ssid, le32_to_cpu(ssid->SsidLength));
+		tmp[le32_to_cpu(ssid->SsidLength)] = 0;
+		devdbg(usbdev, "get_essid: '%s', ret: %d", tmp, ret);
+	}
+#endif
+	return ret;
+}
+
+
+static int set_essid(struct usbnet *usbdev, struct NDIS_802_11_SSID *ssid)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	int ret;
+
+	ret = rndis_set_oid(usbdev, OID_802_11_SSID, ssid, sizeof(*ssid));
+	if (ret == 0) {
+		priv->radio_on = 1;
+		devdbg(usbdev, "set_essid: radio_on = 1");
+	}
+
+	return ret;
+}
+
+
+static int get_bssid(struct usbnet *usbdev, unsigned char bssid[ETH_ALEN])
+{
+	int ret, len;
+
+	len = ETH_ALEN;
+	ret = rndis_query_oid(usbdev, OID_802_11_BSSID, bssid, &len);
+
+	if (ret != 0)
+		memset(bssid, 0, ETH_ALEN);
+
+	return ret;
+}
+
+
+static int is_associated(struct usbnet *usbdev)
+{
+	unsigned char bssid[ETH_ALEN];
+	int ret;
+
+	ret = get_bssid(usbdev, bssid);
+
+	return(ret == 0 && memcmp(bssid, zero_bssid, ETH_ALEN) != 0);
+}
+
+
+static int disassociate(struct usbnet *usbdev, int reset_ssid)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	struct NDIS_802_11_SSID ssid;
+	int i, ret = 0;
+
+	if (priv->radio_on) {
+		ret = rndis_set_oid(usbdev, OID_802_11_DISASSOCIATE, NULL, 0);
+		if (ret == 0) {
+			priv->radio_on = 0;
+			devdbg(usbdev, "disassociate: radio_on = 0");
+
+			if (reset_ssid)
+				msleep(100);
+		}
+	}
+
+	/* disassociate causes radio to be turned off; if reset_ssid
+	 * is given, set ssid to random to enable radio */
+	if (reset_ssid) {
+		ssid.SsidLength = cpu_to_le32(sizeof(ssid.Ssid));
+		get_random_bytes(&ssid.Ssid[2], sizeof(ssid.Ssid)-2);
+		ssid.Ssid[0] = 0x01;
+		ssid.Ssid[1] = 0xff;
+		for (i = 2; i < sizeof(ssid.Ssid); i++)
+			ssid.Ssid[i] = 0x1 + (ssid.Ssid[i] * 0xfe / 0xff);
+		ret = set_essid(usbdev, &ssid);
+	}
+	return ret;
+}
+
+
+static int deauthenticate(struct usbnet *usbdev)
+{
+	int ret;
+
+	ret = disassociate(usbdev, 1);
+	set_default_iw_params(usbdev);
+	return ret;
+}
+
+
+static int add_wep_key(struct usbnet *usbdev, char *key, int keylength,
+    int index)
+{
+	struct NDIS_802_11_WEP *wepkey;
+	int ret;
+
+	/* get memory for max size wep key */
+	wepkey = kmalloc(sizeof(*wepkey) + 13, GFP_KERNEL);
+	if (!wepkey)
+		return -ENOMEM;
+
+	memcpy(wepkey->KeyMaterial, key, keylength);
+	wepkey->Length = cpu_to_le32(sizeof(*wepkey) + keylength);
+	wepkey->KeyIndex = cpu_to_le32(index);
+	if (index == 0)
+		wepkey->KeyIndex = cpu_to_le32(1 << 31);
+	wepkey->KeyLength = cpu_to_le32(keylength);
+	ret = rndis_set_oid(usbdev, OID_802_11_ADD_WEP, wepkey,
+			sizeof(*wepkey) + keylength);
+
+	kfree(wepkey);
+	return ret;
+}
+
+
+/*
+ * wireless extension handlers
+ */
+
+static int rndis_iw_commit(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	/* dummy op */
+	return 0;
+}
+
+
+static int rndis_iw_get_range(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct iw_range *range = (struct iw_range *)extra;
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	int len, ret, i, j, num, has_80211g_rates;
+	u8 rates[8];
+	__le32 tx_power;
+
+	devdbg(usbdev, "SIOCGIWRANGE");
+
+	/* clear iw_range struct */
+	memset(range, 0, sizeof(*range));
+	wrqu->data.length = sizeof(*range);
+
+	range->txpower_capa = IW_TXPOW_MWATT;
+	range->num_txpower = 1;
+	if (priv->caps & CAP_SUPPORT_TXPOWER) {
+		len = sizeof(tx_power);
+		ret = rndis_query_oid(usbdev, OID_802_11_TX_POWER_LEVEL,
+						&tx_power, &len);
+		if (ret == 0 && le32_to_cpu(tx_power) != 0xFF)
+			range->txpower[0] = le32_to_cpu(tx_power);
+		else
+			range->txpower[0] = get_bcm4320_power(priv);
+	} else
+		range->txpower[0] = get_bcm4320_power(priv);
+
+	len = sizeof(rates);
+	ret = rndis_query_oid(usbdev, OID_802_11_SUPPORTED_RATES, &rates,
+								&len);
+	has_80211g_rates = 0;
+	if (ret == 0) {
+		j = 0;
+		for (i = 0; i < len; i++) {
+			if (rates[i] == 0)
+				break;
+			range->bitrate[j] = (rates[i] & 0x7f) * 500000;
+			/* check for non 802.11b rates */
+			if (range->bitrate[j] == 6000000 ||
+				range->bitrate[j] == 9000000 ||
+				(range->bitrate[j] >= 12000000 &&
+				range->bitrate[j] != 22000000))
+				has_80211g_rates = 1;
+			j++;
+		}
+		range->num_bitrates = j;
+	} else
+		range->num_bitrates = 0;
+
+	/* fill in 802.11g rates */
+	if (has_80211g_rates) {
+		num = range->num_bitrates;
+		for (i = 0; i < sizeof(rates_80211g); i++) {
+			for (j = 0; j < num; j++) {
+				if (range->bitrate[j] ==
+					rates_80211g[i] * 1000000)
+					break;
+			}
+			if (j == num)
+				range->bitrate[range->num_bitrates++] =
+					rates_80211g[i] * 1000000;
+			if (range->num_bitrates == IW_MAX_BITRATES)
+				break;
+		}
+
+		/* estimated max real througput in bps */
+		range->throughput = 54 * 1000 * 1000 / 2;
+	} else {
+		/* estimated max real througput in bps */
+		range->throughput = 11 * 1000 * 1000 / 2;
+	}
+
+	range->num_channels = (sizeof(freq_chan)/sizeof(freq_chan[0]));
+
+	for (i = 0; i < (sizeof(freq_chan)/sizeof(freq_chan[0])) &&
+			i < IW_MAX_FREQUENCIES; i++) {
+		range->freq[i].i = i + 1;
+		range->freq[i].m = freq_chan[i] * 100000;
+		range->freq[i].e = 1;
+	}
+	range->num_frequency = i;
+
+	range->min_rts = 0;
+	range->max_rts = 2347;
+	range->min_frag = 256;
+	range->max_frag = 2346;
+
+	/* Setup max_qual as ndiswrapper does in iw_ndis.c */
+	range->max_qual.qual = 100;
+	range->max_qual.level = 154;
+	range->max_qual.updated = IW_QUAL_QUAL_UPDATED
+				| IW_QUAL_LEVEL_UPDATED
+				| IW_QUAL_NOISE_INVALID;
+
+	range->we_version_compiled = WIRELESS_EXT;
+	range->we_version_source = WIRELESS_EXT;
+
+	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
+			IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
+	return 0;
+}
+
+
+static int rndis_iw_get_name(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+
+	strcpy(wrqu->name, priv->name);
+	return 0;
+}
+
+
+static int rndis_iw_set_essid(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *essid)
+{
+	struct NDIS_802_11_SSID ssid;
+	int length = wrqu->essid.length;
+	struct usbnet *usbdev = dev->priv;
+
+	devdbg(usbdev, "SIOCSIWESSID: [flags:%d,len:%d] '%.32s'",
+		wrqu->essid.flags, wrqu->essid.length, essid);
+
+	if (length > NDIS_802_11_LENGTH_SSID)
+		length = NDIS_802_11_LENGTH_SSID;
+
+	ssid.SsidLength = cpu_to_le32(length);
+	if (length > 0) {
+		memcpy(ssid.Ssid, essid, length);
+	} else {
+		memset(ssid.Ssid, 0, NDIS_802_11_LENGTH_SSID);
+	}
+
+	if (!wrqu->essid.flags || length == 0)
+		return disassociate(usbdev, 1);
+	else
+		return set_essid(usbdev, &ssid);
+}
+
+
+static int rndis_iw_get_essid(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *essid)
+{
+	struct NDIS_802_11_SSID ssid;
+	struct usbnet *usbdev = dev->priv;
+	int ret;
+
+	ret = get_essid(usbdev, &ssid);
+
+	if (ret == 0 && ssid.SsidLength) {
+		wrqu->essid.flags = 1;
+		wrqu->essid.length = le32_to_cpu(ssid.SsidLength);
+		memcpy(essid, ssid.Ssid, wrqu->essid.length);
+		essid[wrqu->essid.length] = 0;
+	} else {
+		memset(essid, 0, sizeof(NDIS_802_11_LENGTH_SSID));
+		wrqu->essid.flags = 0;
+		wrqu->essid.length = 0;
+	}
+	devdbg(usbdev, "SIOCGIWESSID: %s", essid);
+	return ret;
+}
+
+
+static int rndis_iw_get_bssid(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	unsigned char bssid[ETH_ALEN];
+	int ret;
+
+	ret = get_bssid(usbdev, bssid);
+
+	if (ret == 0)
+		devdbg(usbdev, "SIOCGIWAP: %02x:%02x:%02x:%02x:%02x:%02x",
+			bssid[0], bssid[1], bssid[2],
+			bssid[3], bssid[4], bssid[5]);
+	else
+		devdbg(usbdev, "SIOCGIWAP: <not associated>");
+
+	wrqu->ap_addr.sa_family = ARPHRD_ETHER;
+	memcpy(wrqu->ap_addr.sa_data, bssid, ETH_ALEN);
+
+	return ret;
+}
+
+
+static int rndis_iw_set_bssid(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	u8 *bssid = (u8 *)wrqu->ap_addr.sa_data;
+
+	devdbg(usbdev, "SIOCSIWAP: %02x:%02x:%02x:%02x:%02x:%02x",
+				bssid[0], bssid[1], bssid[2],
+				bssid[3], bssid[4], bssid[5]);
+
+	return rndis_set_oid(usbdev, OID_802_11_BSSID, bssid, ETH_ALEN);
+}
+
+
+static int rndis_iw_set_auth(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct iw_param *p = &wrqu->param;
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	int ret = -ENOTSUPP;
+	int auth = Ndis802_11AuthModeOpen;
+	int enc = Ndis802_11EncryptionDisabled;
+	__le32 tmp;
+
+	switch (p->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+		devdbg(usbdev, "SIOCSIWAUTH: WPA_VERSION, %08x", p->value);
+		priv->wpa_version |= p->value;
+		ret = 0;
+		break;
+
+	case IW_AUTH_CIPHER_PAIRWISE:
+		devdbg(usbdev, "SIOCSIWAUTH: CIPHER_PAIRWISE, %08x", p->value);
+		priv->wpa_cipher_pair = p->value;
+		ret = 0;
+		break;
+
+	case IW_AUTH_CIPHER_GROUP:
+		devdbg(usbdev, "SIOCSIWAUTH: CIPHER_GROUP, %08x", p->value);
+		priv->wpa_cipher_group = p->value;
+		ret = 0;
+		break;
+
+	case IW_AUTH_KEY_MGMT:
+		devdbg(usbdev, "SIOCSIWAUTH: KEY_MGMT, %08x", p->value);
+		priv->wpa_keymgmt = p->value;
+		ret = 0;
+		break;
+
+	case IW_AUTH_TKIP_COUNTERMEASURES:
+		devdbg(usbdev, "SIOCSIWAUTH: TKIP_COUNTERMEASURES, %08x",
+								p->value);
+		ret = 0;
+		break;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		devdbg(usbdev, "SIOCSIWAUTH: DROP_UNENCRYPTED, %08x", p->value);
+		ret = 0;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		devdbg(usbdev, "SIOCSIWAUTH: 80211_AUTH_ALG, %08x", p->value);
+		priv->wpa_authalg = p->value;
+		ret = 0;
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		devdbg(usbdev, "SIOCSIWAUTH: WPA_ENABLED, %08x", p->value);
+		if (p->value) {
+			deauthenticate(usbdev);
+			priv->wpa_version &= ~IW_AUTH_WPA_VERSION_DISABLED;
+		} else
+			priv->wpa_version |= IW_AUTH_WPA_VERSION_DISABLED;
+		ret = 0;
+		break;
+
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		devdbg(usbdev, "SIOCSIWAUTH: RX_UNENCRYPTED_EAPOL, %08x",
+								p->value);
+		ret = 0;
+		break;
+
+	case IW_AUTH_ROAMING_CONTROL:
+		devdbg(usbdev, "SIOCSIWAUTH: ROAMING_CONTROL, %08x", p->value);
+		ret = 0;
+		break;
+
+	case IW_AUTH_PRIVACY_INVOKED:
+		devdbg(usbdev, "SIOCSIWAUTH: PRIVACY_INVOKED, %08x", p->value);
+
+		priv->privacy = p->value;
+
+		if (priv->privacy) {
+			switch (priv->wpa_keymgmt) {
+			case IW_AUTH_KEY_MGMT_PSK:
+				if (priv->wpa_version == 0) {
+					auth = Ndis802_11AuthModeShared;
+					enc  = Ndis802_11Encryption1Enabled;
+				} else if (priv->wpa_version ==
+						IW_AUTH_WPA_VERSION_WPA) {
+					auth = Ndis802_11AuthModeWPAPSK;
+					enc  = Ndis802_11Encryption2Enabled;
+				} else if (priv->wpa_version ==
+						IW_AUTH_WPA_VERSION_WPA2) {
+					auth = Ndis802_11AuthModeWPA2PSK;
+					enc  = Ndis802_11Encryption3Enabled;
+				} else {
+					devdbg(usbdev, "weird wpa_version %08x",
+							priv->wpa_version);
+					auth = Ndis802_11AuthModeWPA2PSK;
+					enc  = Ndis802_11Encryption3Enabled;
+				}
+				break;
+
+			case IW_AUTH_KEY_MGMT_802_1X:
+				if (priv->wpa_version == 0) {
+					auth = Ndis802_11AuthModeShared;
+					enc  = Ndis802_11Encryption1Enabled;
+				} else if (priv->wpa_version ==
+						IW_AUTH_WPA_VERSION_WPA) {
+					auth = Ndis802_11AuthModeWPA;
+					enc  = Ndis802_11Encryption2Enabled;
+				} else if (priv->wpa_version ==
+						IW_AUTH_WPA_VERSION_WPA2) {
+					auth = Ndis802_11AuthModeWPA2;
+					enc  = Ndis802_11Encryption3Enabled;
+				} else {
+					devdbg(usbdev, "weird wpa_version %08x",
+							priv->wpa_version);
+					auth = Ndis802_11AuthModeWPA2;
+					enc  = Ndis802_11Encryption3Enabled;
+				}
+				break;
+			}
+		} else {
+			auth = Ndis802_11AuthModeOpen;
+			enc  = Ndis802_11EncryptionDisabled;
+		}
+		tmp = cpu_to_le32(auth);
+		rndis_set_oid(usbdev, OID_802_11_AUTHENTICATION_MODE, &tmp,
+								sizeof(tmp));
+		tmp = cpu_to_le32(enc);
+		rndis_set_oid(usbdev, OID_802_11_ENCRYPTION_STATUS, &tmp,
+								sizeof(tmp));
+		ret = 0;
+		break;
+
+	default:
+		devdbg(usbdev, "SIOCSIWAUTH: UKNOWN  %08x, %08x",
+			p->flags & IW_AUTH_INDEX, p->value);
+	}
+	return ret;
+}
+
+
+static int rndis_iw_get_mode(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+
+	switch (priv->mode) {
+	case Ndis802_11IBSS:
+		wrqu->mode = IW_MODE_ADHOC;
+		break;
+	case Ndis802_11Infrastructure:
+		wrqu->mode = IW_MODE_INFRA;
+		break;
+	/*case Ndis802_11AutoUnknown:*/
+	default:
+		wrqu->mode = IW_MODE_AUTO;
+		break;
+	}
+	devdbg(usbdev, "SIOCGIWMODE: %08x", wrqu->mode);
+	return 0;
+}
+
+
+static int rndis_iw_set_mode(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	int i, ret = -EINVAL;
+	__le32 tmp;
+
+	devdbg(usbdev, "SIOCSIWMODE: %08x", wrqu->mode);
+
+	switch (wrqu->mode) {
+	case IW_MODE_ADHOC:
+		priv->mode = Ndis802_11IBSS;
+		break;
+
+	case IW_MODE_INFRA:
+		priv->mode = Ndis802_11Infrastructure;
+		break;
+
+	/*case IW_MODE_AUTO:*/
+	default:
+		priv->mode = Ndis802_11AutoUnknown;
+		break;
+	}
+	tmp = cpu_to_le32(priv->mode);
+	ret = rndis_set_oid(usbdev, OID_802_11_INFRASTRUCTURE_MODE, &tmp,
+								sizeof(tmp));
+	if (ret != 0)
+		return ret;
+
+	/* NDIS drivers clear keys when infrastructure mode is
+	 * changed. But Linux tools assume otherwise. So set the
+	 * keys */
+	if (priv->wpa_keymgmt == 0 ||
+		priv->wpa_keymgmt == IW_AUTH_KEY_MGMT_802_1X) {
+		for (i = 0; i < 4; i++) {
+			if (priv->wep_key_len[i] > 0)
+				add_wep_key(usbdev, priv->wep_keys[i],
+						priv->wep_key_len[i], i);
+		}
+	}
+
+	return ret;
+}
+
+
+static int rndis_iw_set_encode(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct iw_point *param = &wrqu->encoding;
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	int	ret = 0;
+	int	index;
+	int	auth =  Ndis802_11AuthModeOpen;
+	int	enc = Ndis802_11EncryptionDisabled;
+	__le32	tmp;
+
+	devdbg(usbdev, "SIOCSIWENCODE: %08x, %08x",
+		param->flags, param->length);
+
+	index = (param->flags & IW_ENCODE_INDEX) - 1;
+
+	if (param->length > 0) {
+		int current_index = priv->wep_def_key;
+		/* Check the size of the key */
+		if (param->length > 13)
+			return -EINVAL;
+		/* Check the index (none -> use current) */
+		if (index < 0 || index >= 4)
+			index = current_index;
+		else
+			priv->wep_def_key = index;
+		/* Set the length */
+		if (param->length > 5)
+			priv->wep_key_len[index] = 13;
+		else
+			if (param->length > 0)
+				priv->wep_key_len[index] = 5;
+			else
+				/* Disable the key */
+				priv->wep_key_len[index] = 0;
+		/* Check if the key is not marked as invalid */
+		if (!(param->flags & IW_ENCODE_NOKEY)) {
+			/* Cleanup */
+			memset(priv->wep_keys[index], 0, 13);
+			/* Copy the key in the driver */
+			memcpy(priv->wep_keys[index], extra, param->length);
+		}
+		/* WE specify that if a valid key is set, encryption
+		 * should be enabled (user may turn it off later)
+		 * This is also how "iwconfig ethX key on" works
+		 */
+		if (index == current_index && priv->wep_key_len[index] > 0)
+			priv->wep_enabled = 1;
+	} else {
+		if (index >= 0 && index < 4)
+			priv->wep_def_key = index;
+		else
+			/* Don't complain if only change the mode */
+			if (!param->flags & IW_ENCODE_MODE)
+				return -EINVAL;
+	}
+
+	if (index >= 0 && index < 4) {
+		add_wep_key(usbdev, priv->wep_keys[index],
+				priv->wep_key_len[index], index);
+	}
+
+
+	/* Read the flags */
+	if (param->flags & IW_ENCODE_DISABLED) {
+		priv->wep_enabled = 0;
+	} else {
+		priv->wep_enabled = 1;
+	}
+
+	if (param->flags & IW_ENCODE_RESTRICTED)
+		auth = Ndis802_11AuthModeShared;
+	if (param->flags & IW_ENCODE_OPEN)
+		auth = Ndis802_11AuthModeOpen;
+
+	if (priv->wep_enabled) {
+		if (param->flags & IW_ENCODE_MODE)
+			enc = Ndis802_11WEPEnabled;
+	} else
+		enc = Ndis802_11WEPDisabled;
+
+	tmp = cpu_to_le32(auth);
+	rndis_set_oid(usbdev, OID_802_11_AUTHENTICATION_MODE, &tmp,
+			sizeof(tmp));
+	tmp = cpu_to_le32(enc);
+	rndis_set_oid(usbdev, OID_802_11_ENCRYPTION_STATUS, &tmp,
+			sizeof(tmp));
+
+	return ret;
+}
+
+
+static int rndis_iw_set_encode_ext(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct iw_encode_ext *ext = (void *)extra;
+	struct usbnet *usbdev = dev->priv;
+	int ret = -EINVAL, keyindex;
+	struct NDIS_802_11_REMOVE_KEY rem_key;
+	struct NDIS_802_11_KEY add_key;
+
+	devdbg(usbdev, "SIOCSIWENCODEEXT: ext. flags:%08x, alg:%08x: keylen:%d",
+				ext->ext_flags, ext->alg, ext->key_len);
+	devdbg(usbdev, "                : enc. flags:%08x, length:%d",
+				wrqu->encoding.flags, wrqu->encoding.length);
+
+	keyindex = (wrqu->encoding.flags & IW_ENCODE_INDEX) - 1;
+
+	/* TX key */
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY)
+		keyindex |= (1 << 31);
+
+	/* pairwise key */
+	if (!(ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY))
+		keyindex |= (1 << 30);
+
+	if (wrqu->encoding.flags & IW_ENCODE_DISABLED) {
+		memset(&rem_key, 0, sizeof(rem_key));
+		rem_key.Length = cpu_to_le32(sizeof(rem_key));
+		rem_key.KeyIndex = cpu_to_le32(keyindex);
+		if (keyindex & (1 << 30)) {
+			memcpy(rem_key.Bssid, ext->addr.sa_data, ETH_ALEN);
+		} else {
+			memset(rem_key.Bssid, 0xff, ETH_ALEN);
+		}
+		ret = rndis_set_oid(usbdev, OID_802_11_REMOVE_KEY, &rem_key,
+							sizeof(rem_key));
+	} else {
+		if (ext->key_len > sizeof(add_key.KeyMaterial))
+			return -EINVAL;
+
+		memset(&add_key, 0, sizeof(add_key));
+		add_key.Length = cpu_to_le32(sizeof(add_key));
+
+		if (ext->ext_flags & IW_ENCODE_EXT_RX_SEQ_VALID) {
+			memcpy(&add_key.KeyRSC, ext->rx_seq,
+					IW_ENCODE_SEQ_MAX_SIZE);
+			keyindex |= (1 << 29);
+		}
+
+		if (ext->ext_flags & IW_ENCODE_EXT_TX_SEQ_VALID) {
+			memcpy(&add_key.KeyRSC, ext->tx_seq,
+					IW_ENCODE_SEQ_MAX_SIZE);
+			keyindex |= (1 << 29);
+		}
+
+		add_key.KeyIndex = cpu_to_le32(keyindex);
+		add_key.KeyLength = cpu_to_le32(ext->key_len);
+		if (keyindex & (1 << 30)) {
+			memcpy(add_key.Bssid, ext->addr.sa_data, ETH_ALEN);
+		} else {
+			memset(add_key.Bssid, 0xff, ETH_ALEN);
+		}
+		if (ext->alg == IW_ENCODE_ALG_TKIP) {
+			memcpy(add_key.KeyMaterial, ext->key, 16);
+			memcpy(add_key.KeyMaterial + 16, ext->key + 24, 8);
+			memcpy(add_key.KeyMaterial + 24, ext->key + 16, 8);
+		} else {
+			memcpy(add_key.KeyMaterial, ext->key, ext->key_len);
+		}
+		/* kludge alert - breaking a race between ioctl and network
+		 * packet.  This delay is to prevent encryption being enabled
+		 * while the last authentication handshake packet is still
+		 * underway in the stack somewhere. If encryption is enabled
+		 * too early the AP will not see this last handshake packet and
+		 * association fails.
+		 *
+		 * also see:
+		 * http://lists.shmoo.com/pipermail/hostap/2006-September/\
+		 *						014157.html
+		 */
+		msleep(500);
+
+		ret = rndis_set_oid(usbdev, OID_802_11_ADD_KEY, &add_key,
+							sizeof(add_key));
+	}
+	return ret;
+}
+
+
+static int rndis_iw_set_scan(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct iw_param *param = &wrqu->param;
+	struct usbnet *usbdev = dev->priv;
+	union iwreq_data evt;
+	int ret = -EINVAL;
+	__le32 tmp;
+
+	devdbg(usbdev, "SIOCSIWSCAN");
+
+	if (param->flags == 0) {
+		tmp = ccpu2(1);
+		ret = rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
+								sizeof(tmp));
+		evt.data.flags = 0;
+		evt.data.length = 0;
+		wireless_send_event(dev, SIOCGIWSCAN, &evt, NULL);
+	}
+	return ret;
+}
+
+
+static char *rndis_translate_scan(struct net_device *dev,
+    char *cev, char *end_buf, struct NDIS_WLAN_BSSID_EX *bssid)
+{
+#ifdef DEBUG
+	struct usbnet *usbdev = dev->priv;
+#endif
+	struct ieee80211_info_element *ie;
+	char *current_val;
+	int bssid_len, ie_len, i;
+	u32 beacon, atim;
+	struct iw_event iwe;
+	unsigned char sbuf[32];
+
+	bssid_len = le32_to_cpu(bssid->Length);
+
+	devdbg(usbdev, "BSSID %02x:%02x:%02x:%02x:%02x:%02x",
+			bssid->MacAddress[0], bssid->MacAddress[1],
+			bssid->MacAddress[2], bssid->MacAddress[3],
+			bssid->MacAddress[4], bssid->MacAddress[5]);
+	iwe.cmd = SIOCGIWAP;
+	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
+	memcpy(iwe.u.ap_addr.sa_data, bssid->MacAddress, ETH_ALEN);
+	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_ADDR_LEN);
+
+	devdbg(usbdev, "SSID(%d) %s",
+		le32_to_cpu(bssid->Ssid.SsidLength),
+		bssid->Ssid.Ssid);
+	iwe.cmd = SIOCGIWESSID;
+	iwe.u.essid.length = le32_to_cpu(bssid->Ssid.SsidLength);
+	iwe.u.essid.flags = 1;
+	cev = iwe_stream_add_point(cev, end_buf, &iwe,
+						bssid->Ssid.Ssid);
+
+	devdbg(usbdev, "MODE %d",
+			le32_to_cpu(bssid->InfrastructureMode));
+	iwe.cmd = SIOCGIWMODE;
+	switch (le32_to_cpu(bssid->InfrastructureMode)) {
+	case Ndis802_11IBSS:
+		iwe.u.mode = IW_MODE_ADHOC;
+		break;
+	case Ndis802_11Infrastructure:
+		iwe.u.mode = IW_MODE_INFRA;
+		break;
+	/*case Ndis802_11AutoUnknown:*/
+	default:
+		iwe.u.mode = IW_MODE_AUTO;
+		break;
+	}
+	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_UINT_LEN);
+
+	devdbg(usbdev, "FREQ %d kHz",
+		le32_to_cpu(bssid->Configuration.DSConfig));
+	iwe.cmd = SIOCGIWFREQ;
+	dsconfig_to_freq(le32_to_cpu(bssid->Configuration.DSConfig),
+								&iwe.u.freq);
+	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_FREQ_LEN);
+
+	devdbg(usbdev, "QUAL %d", le32_to_cpu(bssid->Rssi));
+	iwe.cmd = IWEVQUAL;
+	iwe.u.qual.qual  = level_to_qual(le32_to_cpu(bssid->Rssi));
+	iwe.u.qual.level = le32_to_cpu(bssid->Rssi);
+	iwe.u.qual.updated = IW_QUAL_QUAL_UPDATED
+			| IW_QUAL_LEVEL_UPDATED
+			| IW_QUAL_NOISE_INVALID;
+	cev = iwe_stream_add_event(cev, end_buf, &iwe, IW_EV_QUAL_LEN);
+
+	devdbg(usbdev, "ENCODE %d", le32_to_cpu(bssid->Privacy));
+	iwe.cmd = SIOCGIWENCODE;
+	iwe.u.data.length = 0;
+	if (le32_to_cpu(bssid->Privacy) == Ndis802_11PrivFilterAcceptAll)
+		iwe.u.data.flags = IW_ENCODE_DISABLED;
+	else
+		iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
+
+	cev = iwe_stream_add_point(cev, end_buf, &iwe, NULL);
+
+	devdbg(usbdev, "RATES:");
+	current_val = cev + IW_EV_LCP_LEN;
+	iwe.cmd = SIOCGIWRATE;
+	for (i = 0; i < sizeof(bssid->SupportedRates); i++) {
+		if (bssid->SupportedRates[i] & 0x7f) {
+			iwe.u.bitrate.value =
+				((bssid->SupportedRates[i] & 0x7f) *
+				500000);
+			devdbg(usbdev, " %d", iwe.u.bitrate.value);
+			current_val = iwe_stream_add_value(cev,
+				current_val, end_buf, &iwe,
+				IW_EV_PARAM_LEN);
+		}
+	}
+
+	if ((current_val - cev) > IW_EV_LCP_LEN)
+		cev = current_val;
+
+	beacon = le32_to_cpu(bssid->Configuration.BeaconPeriod);
+	devdbg(usbdev, "BCN_INT %d", beacon);
+	iwe.cmd = IWEVCUSTOM;
+	snprintf(sbuf, sizeof(sbuf), "bcn_int=%d", beacon);
+	iwe.u.data.length = strlen(sbuf);
+	cev = iwe_stream_add_point(cev, end_buf, &iwe, sbuf);
+
+	atim = le32_to_cpu(bssid->Configuration.ATIMWindow);
+	devdbg(usbdev, "ATIM %d", atim);
+	iwe.cmd = IWEVCUSTOM;
+	snprintf(sbuf, sizeof(sbuf), "atim=%u", atim);
+	iwe.u.data.length = strlen(sbuf);
+	cev = iwe_stream_add_point(cev, end_buf, &iwe, sbuf);
+
+	ie = (void *)(bssid->IEs + sizeof(struct NDIS_802_11_FIXED_IEs));
+	ie_len = min(bssid_len - (int)sizeof(*bssid),
+					(int)le32_to_cpu(bssid->IELength));
+	ie_len -= sizeof(struct NDIS_802_11_FIXED_IEs);
+	while (ie_len >= sizeof(*ie) && sizeof(*ie) + ie->len <= ie_len) {
+		if ((ie->id == MFIE_TYPE_GENERIC && ie->len >= 4 &&
+				memcmp(ie->data, "\x00\x50\xf2\x01", 4) == 0) ||
+				ie->id == MFIE_TYPE_RSN) {
+			devdbg(usbdev, "IE: WPA%d",
+					(ie->id == MFIE_TYPE_RSN) ? 2 : 1);
+			iwe.cmd = IWEVGENIE;
+			iwe.u.data.length = min(ie->len + 2, MAX_WPA_IE_LEN);
+			cev = iwe_stream_add_point(cev, end_buf, &iwe,
+								   (u8 *)ie);
+		}
+
+		ie_len -= sizeof(*ie) + ie->len;
+		ie = (struct ieee80211_info_element *)&ie->data[ie->len];
+	}
+
+	return cev;
+}
+
+
+static int rndis_iw_get_scan(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	void *buf = NULL;
+	char *cev = extra;
+	struct NDIS_802_11_BSSID_LIST_EX *bssid_list;
+	struct NDIS_WLAN_BSSID_EX *bssid;
+	int ret = -EINVAL, len, count, bssid_len;
+
+	devdbg(usbdev, "SIOCGIWSCAN");
+
+	len = CONTROL_BUFFER_SIZE;
+	buf = kmalloc(len, GFP_KERNEL);
+	if (!buf) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = rndis_query_oid(usbdev, OID_802_11_BSSID_LIST, buf, &len);
+
+	if (ret != 0)
+		goto out;
+
+	bssid_list = buf;
+	bssid = bssid_list->Bssid;
+	bssid_len = le32_to_cpu(bssid->Length);
+	count = le32_to_cpu(bssid_list->NumberOfItems);
+	devdbg(usbdev, "SIOCGIWSCAN: %d BSSIDs found", count);
+
+	while (count && ((void *)bssid + bssid_len) <= (buf + len)) {
+		cev = rndis_translate_scan(dev, cev, extra + IW_SCAN_MAX_DATA,
+									bssid);
+		bssid = (void *)bssid + bssid_len;
+		bssid_len = le32_to_cpu(bssid->Length);
+		count--;
+	}
+
+out:
+	wrqu->data.length = cev - extra;
+	wrqu->data.flags = 0;
+	kfree(buf);
+	return ret;
+}
+
+
+static int rndis_iw_set_genie(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	int ret = 0;
+
+#ifdef DEBUG
+	int j;
+	u8 *gie = extra;
+	for (j = 0; j < wrqu->data.length; j += 8)
+		devdbg(usbdev,
+			"SIOCSIWGENIE %04x - "
+			"%02x %02x %02x %02x %02x %02x %02x %02x", j,
+			gie[j + 0], gie[j + 1], gie[j + 2], gie[j + 3],
+			gie[j + 4], gie[j + 5], gie[j + 6], gie[j + 7]);
+#endif
+	/* clear existing IEs */
+	if (priv->wpa_ie_len) {
+		kfree(priv->wpa_ie);
+		priv->wpa_ie_len = 0;
+	}
+
+	/* set new IEs */
+	priv->wpa_ie = kmalloc(wrqu->data.length, GFP_KERNEL);
+	if (priv->wpa_ie) {
+		priv->wpa_ie_len = wrqu->data.length;
+		memcpy(priv->wpa_ie, extra, priv->wpa_ie_len);
+	} else
+		ret = -ENOMEM;
+	return ret;
+}
+
+
+static int rndis_iw_get_genie(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+
+	devdbg(usbdev, "SIOCGIWGENIE");
+
+	if (priv->wpa_ie_len == 0 || priv->wpa_ie == NULL) {
+		wrqu->data.length = 0;
+		return 0;
+	}
+
+	if (wrqu->data.length < priv->wpa_ie_len)
+		return -E2BIG;
+
+	wrqu->data.length = priv->wpa_ie_len;
+	memcpy(extra, priv->wpa_ie, priv->wpa_ie_len);
+
+	return 0;
+}
+
+
+static int rndis_iw_set_rts(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	__le32 tmp;
+	devdbg(usbdev, "SIOCSIWRTS");
+
+	tmp = cpu_to_le32(wrqu->rts.value);
+	return rndis_set_oid(usbdev, OID_802_11_RTS_THRESHOLD, &tmp,
+								sizeof(tmp));
+}
+
+
+static int rndis_iw_get_rts(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	__le32 tmp;
+	int len, ret;
+
+	len = sizeof(tmp);
+	ret = rndis_query_oid(usbdev, OID_802_11_RTS_THRESHOLD, &tmp, &len);
+	if (ret == 0) {
+		wrqu->rts.value = le32_to_cpu(tmp);
+		wrqu->rts.flags = 1;
+		wrqu->rts.disabled = 0;
+	}
+
+	devdbg(usbdev, "SIOCGIWRTS: %d", wrqu->rts.value);
+
+	return ret;
+}
+
+
+static int rndis_iw_set_frag(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	__le32 tmp;
+
+	devdbg(usbdev, "SIOCSIWFRAG");
+
+	tmp = cpu_to_le32(wrqu->frag.value);
+	return rndis_set_oid(usbdev, OID_802_11_FRAGMENTATION_THRESHOLD, &tmp,
+								sizeof(tmp));
+}
+
+
+static int rndis_iw_get_frag(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	__le32 tmp;
+	int len, ret;
+
+	len = sizeof(tmp);
+	ret = rndis_query_oid(usbdev, OID_802_11_FRAGMENTATION_THRESHOLD, &tmp,
+									&len);
+	if (ret == 0) {
+		wrqu->frag.value = le32_to_cpu(tmp);
+		wrqu->frag.flags = 1;
+		wrqu->frag.disabled = 0;
+	}
+	devdbg(usbdev, "SIOCGIWFRAG: %d", wrqu->frag.value);
+	return ret;
+}
+
+
+static int rndis_iw_set_nick(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+
+	devdbg(usbdev, "SIOCSIWNICK");
+
+	priv->nick_len = wrqu->data.length;
+	if (priv->nick_len > 32)
+		priv->nick_len = 32;
+
+	memcpy(priv->nick, extra, priv->nick_len);
+	return 0;
+}
+
+
+static int rndis_iw_get_nick(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+
+	wrqu->data.flags = 1;
+	wrqu->data.length = priv->nick_len;
+	memcpy(extra, priv->nick, priv->nick_len);
+
+	devdbg(usbdev, "SIOCGIWNICK: '%s'", priv->nick);
+
+	return 0;
+}
+
+
+static int rndis_iw_set_freq(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct NDIS_802_11_CONFIGURATION config;
+	unsigned int dsconfig;
+	int len, ret;
+
+	/* this OID is valid only when not associated */
+	if (is_associated(usbdev))
+		return 0;
+
+	dsconfig = 0;
+	if (freq_to_dsconfig(&wrqu->freq, &dsconfig))
+		return -EINVAL;
+
+	len = sizeof(config);
+	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
+	if (ret != 0) {
+		devdbg(usbdev, "SIOCSIWFREQ: querying configuration failed");
+		return 0;
+	}
+
+	config.DSConfig = cpu_to_le32(dsconfig);
+
+	devdbg(usbdev, "SIOCSIWFREQ: %d * 10^%d", wrqu->freq.m, wrqu->freq.e);
+	return rndis_set_oid(usbdev, OID_802_11_CONFIGURATION, &config,
+								sizeof(config));
+}
+
+
+static int rndis_iw_get_freq(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct NDIS_802_11_CONFIGURATION config;
+	int len, ret;
+
+	len = sizeof(config);
+	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
+	if (ret == 0)
+		dsconfig_to_freq(le32_to_cpu(config.DSConfig), &wrqu->freq);
+
+	devdbg(usbdev, "SIOCGIWFREQ: %d", wrqu->freq.m);
+	return ret;
+}
+
+
+static int rndis_iw_get_txpower(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	__le32 tx_power;
+	int ret = 0, len;
+
+	if (priv->radio_on) {
+		if (priv->caps & CAP_SUPPORT_TXPOWER) {
+			len = sizeof(tx_power);
+			ret = rndis_query_oid(usbdev, OID_802_11_TX_POWER_LEVEL,
+							&tx_power, &len);
+			if (ret != 0)
+				return ret;
+		} else
+			/* fake incase not supported */
+			tx_power = cpu_to_le32(get_bcm4320_power(priv));
+
+		wrqu->txpower.flags = IW_TXPOW_MWATT;
+		wrqu->txpower.value = le32_to_cpu(tx_power);
+		wrqu->txpower.disabled = 0;
+	} else {
+		wrqu->txpower.flags = IW_TXPOW_MWATT;
+		wrqu->txpower.value = 0;
+		wrqu->txpower.disabled = 1;
+	}
+
+	devdbg(usbdev, "SIOCGIWTXPOW: %d", wrqu->txpower.value);
+
+	return ret;
+}
+
+
+static int rndis_iw_set_txpower(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+	__le32 tx_power;
+	int ret = 0;
+
+	if (wrqu->txpower.disabled)
+		tx_power = 0;
+	else {
+		if (wrqu->txpower.flags == IW_TXPOW_MWATT)
+			tx_power = cpu_to_le32(wrqu->txpower.value);
+		else {
+			/* wrqu->txpower.flags == IW_TXPOW_DBM */
+			if (wrqu->txpower.value > 20)
+				tx_power = cpu_to_le32(128);
+			else if (wrqu->txpower.value < -43)
+				tx_power = cpu_to_le32(127);
+			else {
+				signed char tmp;
+				tmp = wrqu->txpower.value;
+				tmp = -12 - tmp;
+				tmp <<= 2;
+				tx_power = cpu_to_le32((unsigned char)tmp);
+			}
+		}
+	}
+
+	devdbg(usbdev, "SIOCSIWTXPOW: %d", le32_to_cpu(tx_power));
+
+	if (le32_to_cpu(tx_power) != 0) {
+		if (priv->caps & CAP_SUPPORT_TXPOWER) {
+			/* turn radio on first */
+			if (!priv->radio_on)
+				disassociate(usbdev, 1);
+
+			ret = rndis_set_oid(usbdev, OID_802_11_TX_POWER_LEVEL,
+						&tx_power, sizeof(tx_power));
+			if (ret != 0)
+				ret = -EOPNOTSUPP;
+			return ret;
+		} else {
+			/* txpower unsupported, just turn radio on */
+			if (!priv->radio_on)
+				return disassociate(usbdev, 1);
+			return 0; /* all ready on */
+		}
+	}
+
+	/* tx_power == 0, turn off radio */
+	return disassociate(usbdev, 0);
+}
+
+
+static int rndis_iw_get_rate(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	__le32 tmp;
+	int ret, len;
+
+	len = sizeof(tmp);
+	ret = rndis_query_oid(usbdev, OID_GEN_LINK_SPEED, &tmp, &len);
+	if (ret == 0) {
+		wrqu->bitrate.value = le32_to_cpu(tmp) * 100;
+		wrqu->bitrate.disabled = 0;
+		wrqu->bitrate.flags = 1;
+	}
+	return ret;
+}
+
+
+static int rndis_iw_set_mlme(struct net_device *dev,
+    struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct iw_mlme *mlme = (struct iw_mlme *)extra;
+	unsigned char bssid[ETH_ALEN];
+
+	get_bssid(usbdev, bssid);
+
+	if (memcmp(bssid, mlme->addr.sa_data, ETH_ALEN))
+		return -EINVAL;
+
+	switch (mlme->cmd) {
+	case IW_MLME_DEAUTH:
+		return deauthenticate(usbdev);
+	case IW_MLME_DISASSOC:
+		return disassociate(usbdev, 1);
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+
+static struct iw_statistics *rndis_get_wireless_stats(struct net_device *dev)
+{
+	struct usbnet *usbdev = dev->priv;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
+
+	mutex_lock(&priv->stats_lock);
+	memcpy(&priv->iwstats, &priv->privstats, sizeof(priv->iwstats));
+	mutex_unlock(&priv->stats_lock);
+
+	return &priv->iwstats;
+}
+
+
+#define IW_IOCTL(x) [(x) - SIOCSIWCOMMIT]
+static const iw_handler rndis_iw_handler[] =
+{
+	IW_IOCTL(SIOCSIWCOMMIT)    = rndis_iw_commit,
+	IW_IOCTL(SIOCGIWNAME)      = rndis_iw_get_name,
+	IW_IOCTL(SIOCSIWFREQ)      = rndis_iw_set_freq,
+	IW_IOCTL(SIOCGIWFREQ)      = rndis_iw_get_freq,
+	IW_IOCTL(SIOCSIWMODE)      = rndis_iw_set_mode,
+	IW_IOCTL(SIOCGIWMODE)      = rndis_iw_get_mode,
+	IW_IOCTL(SIOCGIWRANGE)     = rndis_iw_get_range,
+	IW_IOCTL(SIOCSIWAP)        = rndis_iw_set_bssid,
+	IW_IOCTL(SIOCGIWAP)        = rndis_iw_get_bssid,
+	IW_IOCTL(SIOCSIWSCAN)      = rndis_iw_set_scan,
+	IW_IOCTL(SIOCGIWSCAN)      = rndis_iw_get_scan,
+	IW_IOCTL(SIOCSIWESSID)     = rndis_iw_set_essid,
+	IW_IOCTL(SIOCGIWESSID)     = rndis_iw_get_essid,
+	IW_IOCTL(SIOCSIWNICKN)     = rndis_iw_set_nick,
+	IW_IOCTL(SIOCGIWNICKN)     = rndis_iw_get_nick,
+	IW_IOCTL(SIOCGIWRATE)      = rndis_iw_get_rate,
+	IW_IOCTL(SIOCSIWRTS)       = rndis_iw_set_rts,
+	IW_IOCTL(SIOCGIWRTS)       = rndis_iw_get_rts,
+	IW_IOCTL(SIOCSIWFRAG)      = rndis_iw_set_frag,
+	IW_IOCTL(SIOCGIWFRAG)      = rndis_iw_get_frag,
+	IW_IOCTL(SIOCSIWTXPOW)     = rndis_iw_set_txpower,
+	IW_IOCTL(SIOCGIWTXPOW)     = rndis_iw_get_txpower,
+	IW_IOCTL(SIOCSIWENCODE)    = rndis_iw_set_encode,
+	IW_IOCTL(SIOCSIWENCODEEXT) = rndis_iw_set_encode_ext,
+	IW_IOCTL(SIOCSIWAUTH)      = rndis_iw_set_auth,
+	IW_IOCTL(SIOCSIWGENIE)     = rndis_iw_set_genie,
+	IW_IOCTL(SIOCGIWGENIE)     = rndis_iw_get_genie,
+	IW_IOCTL(SIOCSIWMLME)      = rndis_iw_set_mlme,
+};
+
+static const iw_handler rndis_wext_private_handler[] = {
+};
+
+static const struct iw_priv_args rndis_wext_private_args[] = {
+};
+
+
+static const struct iw_handler_def rndis_iw_handlers = {
+	.num_standard = ARRAY_SIZE(rndis_iw_handler),
+	.num_private  = ARRAY_SIZE(rndis_wext_private_handler),
+	.num_private_args = ARRAY_SIZE(rndis_wext_private_args),
+	.standard = (iw_handler *)rndis_iw_handler,
+	.private  = (iw_handler *)rndis_wext_private_handler,
+	.private_args = (struct iw_priv_args *)rndis_wext_private_args,
+	.get_wireless_stats = rndis_get_wireless_stats,
+};
+
+
+static void rndis_wext_connect_event_work(struct work_struct *work)
+{
+	struct rndis_wext_private *priv =
+		container_of(work, struct rndis_wext_private, work);
+	struct usbnet *usbdev = priv->usbdev;
+	union iwreq_data evt;
+	unsigned char bssid[ETH_ALEN];
+	int ret;
+
+	ret = get_bssid(usbdev, bssid);
+
+	if (!ret) {
+		evt.data.flags = 0;
+		evt.data.length = 0;
+		memcpy(evt.ap_addr.sa_data, bssid, ETH_ALEN);
+		wireless_send_event(usbdev->net, SIOCGIWAP, &evt, NULL);
+	}
+}
+
+static void rndis_wext_link_change(struct usbnet *dev, int state)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(dev);
+	union iwreq_data evt;
+
+	if (state) {
+		/* queue work to avoid recursive calls into rndis_command */
+		queue_work(priv->workqueue, &priv->work);
+	} else {
+		evt.data.flags = 0;
+		evt.data.length = 0;
+		memset(evt.ap_addr.sa_data, 0, ETH_ALEN);
+		wireless_send_event(dev->net, SIOCGIWAP, &evt, NULL);
+	}
+}
+
+static int rndis_wext_get_caps(struct usbnet *dev)
+{
+	struct {
+		__le32	num_items;
+		__le32	items[8];
+	} networks_supported;
+	int len, retval, i, n;
+	__le32 tx_power;
+	struct rndis_wext_private *priv = get_rndis_wext_priv(dev);
+
+	/* determine if supports setting txpower */
+	len = sizeof(tx_power);
+	retval = rndis_query_oid(dev, OID_802_11_TX_POWER_LEVEL, &tx_power,
+								&len);
+	if (retval == 0 && le32_to_cpu(tx_power) != 0xFF)
+		priv->caps |= CAP_SUPPORT_TXPOWER;
+
+	/* determine supported modes */
+	len = sizeof(networks_supported);
+	retval = rndis_query_oid(dev, OID_802_11_NETWORK_TYPES_SUPPORTED,
+						&networks_supported, &len);
+	if (retval >= 0) {
+		n = le32_to_cpu(networks_supported.num_items);
+		if (n > 8)
+			n = 8;
+		for (i = 0; i < n; i++) {
+			switch (le32_to_cpu(networks_supported.items[i])) {
+			case Ndis802_11FH:
+			case Ndis802_11DS:
+				priv->caps |= CAP_MODE_80211B;
+				break;
+			case Ndis802_11OFDM5:
+				priv->caps |= CAP_MODE_80211A;
+				break;
+			case Ndis802_11OFDM24:
+				priv->caps |= CAP_MODE_80211G;
+				break;
+			}
+		}
+		if (priv->caps & CAP_MODE_80211A)
+			strcat(priv->name, "a");
+		if (priv->caps & CAP_MODE_80211B)
+			strcat(priv->name, "b");
+		if (priv->caps & CAP_MODE_80211G)
+			strcat(priv->name, "g");
+	}
+
+	return retval;
+}
+
+
+#define STATS_UPDATE_JIFFIES (HZ * 2)
+static void rndis_update_wireless_stats(struct work_struct *work)
+{
+	struct rndis_wext_private *priv =
+		container_of(work, struct rndis_wext_private, stats_work.work);
+	struct usbnet *usbdev = priv->usbdev;
+	struct NDIS_802_11_STATS stats;
+	struct iw_statistics iwstats;
+	__le32 rssi;
+	int len, ret;
+
+	mutex_lock(&priv->stats_lock);
+	memcpy(&iwstats, &priv->privstats, sizeof(iwstats));
+	mutex_unlock(&priv->stats_lock);
+
+	/* only update stats when connected */
+	if (!is_associated(usbdev)) {
+		iwstats.qual.qual = 0;
+		iwstats.qual.level = 0;
+		iwstats.qual.updated = IW_QUAL_QUAL_UPDATED
+				| IW_QUAL_LEVEL_UPDATED
+				| IW_QUAL_NOISE_INVALID
+				| IW_QUAL_QUAL_INVALID
+				| IW_QUAL_LEVEL_INVALID;
+		goto end;
+	}
+
+	len = sizeof(rssi);
+	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+
+	devdbg(usbdev, "stats: OID_802_11_RSSI -> %d, rssi:%d", ret,
+							le32_to_cpu(rssi));
+	if (ret == 0) {
+		memset(&iwstats.qual, 0, sizeof(iwstats.qual));
+		iwstats.qual.qual  = level_to_qual(le32_to_cpu(rssi));
+		iwstats.qual.level = le32_to_cpu(rssi);
+		iwstats.qual.updated = IW_QUAL_QUAL_UPDATED
+				| IW_QUAL_LEVEL_UPDATED
+				| IW_QUAL_NOISE_INVALID;
+	}
+
+	len = sizeof(stats);
+	ret = rndis_query_oid(usbdev, OID_802_11_STATISTICS, &stats, &len);
+
+	devdbg(usbdev, "stats: OID_802_11_STATISTICS -> %d", ret);
+	if (ret == 0) {
+		memset(&iwstats.discard, 0, sizeof(iwstats.discard));
+		iwstats.discard.retries =
+			(u32)le64_to_cpu(stats.Retry) +
+			(u32)le64_to_cpu(stats.MultiRetry);
+		iwstats.discard.misc =
+			(u32)le64_to_cpu(stats.FcsErr) +
+			(u32)le64_to_cpu(stats.RtssFail) +
+			(u32)le64_to_cpu(stats.AckFail) +
+			(u32)le64_to_cpu(stats.FrameDup);
+		iwstats.discard.fragment =
+			(u32)le64_to_cpu(stats.RxFrag) +
+			(u32)le64_to_cpu(stats.RxMultiFrag);
+	}
+
+end:
+	mutex_lock(&priv->stats_lock);
+	memcpy(&priv->privstats, &iwstats, sizeof(iwstats));
+	mutex_unlock(&priv->stats_lock);
+
+	queue_delayed_work(priv->workqueue, &priv->stats_work,
+		round_jiffies_relative(STATS_UPDATE_JIFFIES));
+
+}
+
+static int rndis_wext_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct net_device *net = dev->net;
+	struct rndis_wext_private *priv;
+
+	/* allocate rndis private data */
+	priv = kmalloc(sizeof(struct rndis_wext_private), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	dev->driver_priv = priv;
+	memset(priv, 0, sizeof(*priv));
+	memset(priv->name, 0, sizeof(priv->name));
+	strcpy(priv->name, "IEEE802.11");
+	net->wireless_handlers = &rndis_iw_handlers;
+	priv->usbdev = dev;
+
+	mutex_init(&priv->command_lock);
+	mutex_init(&priv->stats_lock);
+
+	priv->iwstats.qual.qual = 0;
+	priv->iwstats.qual.level = 0;
+	priv->iwstats.qual.updated = IW_QUAL_QUAL_UPDATED
+					| IW_QUAL_LEVEL_UPDATED
+					| IW_QUAL_NOISE_INVALID
+					| IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID;
+
+	rndis_wext_get_caps(dev);
+	set_default_iw_params(dev);
+
+	/* turn radio on */
+	priv->radio_on = 1;
+	disassociate(dev, 1);
+
+	/* because rndis_command() sleeps we need to use workqueue */
+	priv->workqueue = create_singlethread_workqueue("rndis_wext");
+	INIT_DELAYED_WORK(&priv->stats_work, rndis_update_wireless_stats);
+	queue_delayed_work(priv->workqueue, &priv->stats_work,
+		round_jiffies_relative(STATS_UPDATE_JIFFIES));
+	INIT_WORK(&priv->work, rndis_wext_connect_event_work);
+
+	return 0;
+}
+
+static void rndis_wext_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct rndis_wext_private *priv = get_rndis_wext_priv(dev);
+
+	/* turn radio off */
+	disassociate(dev, 0);
+
+	cancel_delayed_work_sync(&priv->stats_work);
+	cancel_work_sync(&priv->work);
+	flush_workqueue(priv->workqueue);
+	destroy_workqueue(priv->workqueue);
+
+	if (priv && priv->wpa_ie_len)
+		kfree(priv->wpa_ie);
+	kfree(priv);
+
+	rndis_unbind(dev, intf);
+}
+
+static int rndis_wext_reset(struct usbnet *dev)
+{
+	return deauthenticate(dev);
+}
+
+struct driver_info rndis_wext_info = {
+	.description =	"Wireless RNDIS device",
+	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
+	.bind =		rndis_wext_bind,
+	.unbind =	rndis_wext_unbind,
+	.status =	rndis_status,
+	.rx_fixup =	rndis_rx_fixup,
+	.tx_fixup =	rndis_tx_fixup,
+	.reset =	rndis_wext_reset,
+	.link_change =	rndis_wext_link_change,
+};
diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
index 1fae434..83860a0 100644
--- a/drivers/net/usb/usbnet.h
+++ b/drivers/net/usb/usbnet.h
@@ -31,6 +31,7 @@ struct usbnet {
 	struct usb_interface	*intf;
 	struct driver_info	*driver_info;
 	const char		*driver_name;
+	void			*driver_priv;
 	wait_queue_head_t	*wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
@@ -109,6 +110,9 @@ struct driver_info {
 	/* fixup rx packet (strip framing) */
 	int	(*rx_fixup)(struct usbnet *dev, struct sk_buff *skb);
 
+	/* called when link state changes */
+	void    (*link_change)(struct usbnet *dev, int state);
+
 	/* fixup tx packet (add framing) */
 	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
 				struct sk_buff *skb, gfp_t flags);
-- 
1.5.2.5

