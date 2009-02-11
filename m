From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] rndis: remove private wrapper of __constant_cpu_to_le32
Date: Wed, 11 Feb 2009 13:56:50 -0800
Message-ID: <1234389410.5566.5.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, John Linville <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:56614 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbZBKV4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:56:55 -0500
Received: by yw-out-2324.google.com with SMTP id 5so224280ywh.1
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 13:56:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use cpu_to_le32 directly as it handles constant folding now, replace direct
uses of __constant_cpu_to_{endian} as well.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave (Miller), I guess your tree would be best to take this through as it is
mostly networking.  But I can do a split patch for each tree if desired.

 drivers/net/usb/rndis_host.c      |   25 ++++------
 drivers/net/wireless/rndis_wlan.c |   90 ++++++++++++++++++------------------
 drivers/usb/gadget/rndis.c        |   92 ++++++++++++++++++------------------
 include/linux/usb/rndis_host.h    |   85 ++++++++++++++++------------------
 4 files changed, 143 insertions(+), 149 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index bcd858c..b7f763e 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -169,7 +169,7 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 				struct rndis_keepalive_c *msg = (void *)buf;
 
 				msg->msg_type = RNDIS_MSG_KEEPALIVE_C;
-				msg->msg_len = ccpu2(sizeof *msg);
+				msg->msg_len = cpu_to_le32(sizeof *msg);
 				msg->status = RNDIS_STATUS_SUCCESS;
 				retval = usb_control_msg(dev->udev,
 					usb_sndctrlpipe(dev->udev, 0),
@@ -237,7 +237,7 @@ static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
 	u.get->msg_len = cpu_to_le32(sizeof *u.get + in_len);
 	u.get->oid = oid;
 	u.get->len = cpu_to_le32(in_len);
-	u.get->offset = ccpu2(20);
+	u.get->offset = cpu_to_le32(20);
 
 	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
@@ -297,9 +297,9 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		goto fail;
 
 	u.init->msg_type = RNDIS_MSG_INIT;
-	u.init->msg_len = ccpu2(sizeof *u.init);
-	u.init->major_version = ccpu2(1);
-	u.init->minor_version = ccpu2(0);
+	u.init->msg_len = cpu_to_le32(sizeof *u.init);
+	u.init->major_version = cpu_to_le32(1);
+	u.init->minor_version = cpu_to_le32(0);
 
 	/* max transfer (in spec) is 0x4000 at full speed, but for
 	 * TX we'll stick to one Ethernet packet plus RNDIS framing.
@@ -403,10 +403,10 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	/* set a nonzero filter to enable data transfers */
 	memset(u.set, 0, sizeof *u.set);
 	u.set->msg_type = RNDIS_MSG_SET;
-	u.set->msg_len = ccpu2(4 + sizeof *u.set);
+	u.set->msg_len = cpu_to_le32(4 + sizeof *u.set);
 	u.set->oid = OID_GEN_CURRENT_PACKET_FILTER;
-	u.set->len = ccpu2(4);
-	u.set->offset = ccpu2((sizeof *u.set) - 8);
+	u.set->len = cpu_to_le32(4);
+	u.set->offset = cpu_to_le32((sizeof *u.set) - 8);
 	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
 
 	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
@@ -423,7 +423,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 halt_fail_and_release:
 	memset(u.halt, 0, sizeof *u.halt);
 	u.halt->msg_type = RNDIS_MSG_HALT;
-	u.halt->msg_len = ccpu2(sizeof *u.halt);
+	u.halt->msg_len = cpu_to_le32(sizeof *u.halt);
 	(void) rndis_command(dev, (void *)u.halt, CONTROL_BUFFER_SIZE);
 fail_and_release:
 	usb_set_intfdata(info->data, NULL);
@@ -448,7 +448,7 @@ void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 	halt = kzalloc(CONTROL_BUFFER_SIZE, GFP_KERNEL);
 	if (halt) {
 		halt->msg_type = RNDIS_MSG_HALT;
-		halt->msg_len = ccpu2(sizeof *halt);
+		halt->msg_len = cpu_to_le32(sizeof *halt);
 		(void) rndis_command(dev, (void *)halt, CONTROL_BUFFER_SIZE);
 		kfree(halt);
 	}
@@ -543,7 +543,7 @@ fill:
 	memset(hdr, 0, sizeof *hdr);
 	hdr->msg_type = RNDIS_MSG_PACKET;
 	hdr->msg_len = cpu_to_le32(skb->len);
-	hdr->data_offset = ccpu2(sizeof(*hdr) - 8);
+	hdr->data_offset = cpu_to_le32(sizeof(*hdr) - 8);
 	hdr->data_len = cpu_to_le32(len);
 
 	/* FIXME make the last packet always be short ... */
@@ -562,9 +562,6 @@ static const struct driver_info	rndis_info = {
 	.tx_fixup =	rndis_tx_fixup,
 };
 
-#undef ccpu2
-
-
 /*-------------------------------------------------------------------------*/
 
 static const struct usb_device_id	products [] = {
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 105f214..82af21e 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -90,44 +90,44 @@ MODULE_PARM_DESC(workaround_interval,
 
 
 /* various RNDIS OID defs */
-#define OID_GEN_LINK_SPEED			ccpu2(0x00010107)
-#define OID_GEN_RNDIS_CONFIG_PARAMETER		ccpu2(0x0001021b)
-
-#define OID_GEN_XMIT_OK				ccpu2(0x00020101)
-#define OID_GEN_RCV_OK				ccpu2(0x00020102)
-#define OID_GEN_XMIT_ERROR			ccpu2(0x00020103)
-#define OID_GEN_RCV_ERROR			ccpu2(0x00020104)
-#define OID_GEN_RCV_NO_BUFFER			ccpu2(0x00020105)
-
-#define OID_802_3_PERMANENT_ADDRESS		ccpu2(0x01010101)
-#define OID_802_3_CURRENT_ADDRESS		ccpu2(0x01010102)
-#define OID_802_3_MULTICAST_LIST		ccpu2(0x01010103)
-#define OID_802_3_MAXIMUM_LIST_SIZE		ccpu2(0x01010104)
-
-#define OID_802_11_BSSID			ccpu2(0x0d010101)
-#define OID_802_11_SSID				ccpu2(0x0d010102)
-#define OID_802_11_INFRASTRUCTURE_MODE		ccpu2(0x0d010108)
-#define OID_802_11_ADD_WEP			ccpu2(0x0d010113)
-#define OID_802_11_REMOVE_WEP			ccpu2(0x0d010114)
-#define OID_802_11_DISASSOCIATE			ccpu2(0x0d010115)
-#define OID_802_11_AUTHENTICATION_MODE		ccpu2(0x0d010118)
-#define OID_802_11_PRIVACY_FILTER		ccpu2(0x0d010119)
-#define OID_802_11_BSSID_LIST_SCAN		ccpu2(0x0d01011a)
-#define OID_802_11_ENCRYPTION_STATUS		ccpu2(0x0d01011b)
-#define OID_802_11_ADD_KEY			ccpu2(0x0d01011d)
-#define OID_802_11_REMOVE_KEY			ccpu2(0x0d01011e)
-#define OID_802_11_ASSOCIATION_INFORMATION	ccpu2(0x0d01011f)
-#define OID_802_11_PMKID			ccpu2(0x0d010123)
-#define OID_802_11_NETWORK_TYPES_SUPPORTED	ccpu2(0x0d010203)
-#define OID_802_11_NETWORK_TYPE_IN_USE		ccpu2(0x0d010204)
-#define OID_802_11_TX_POWER_LEVEL		ccpu2(0x0d010205)
-#define OID_802_11_RSSI				ccpu2(0x0d010206)
-#define OID_802_11_RSSI_TRIGGER			ccpu2(0x0d010207)
-#define OID_802_11_FRAGMENTATION_THRESHOLD	ccpu2(0x0d010209)
-#define OID_802_11_RTS_THRESHOLD		ccpu2(0x0d01020a)
-#define OID_802_11_SUPPORTED_RATES		ccpu2(0x0d01020e)
-#define OID_802_11_CONFIGURATION		ccpu2(0x0d010211)
-#define OID_802_11_BSSID_LIST			ccpu2(0x0d010217)
+#define OID_GEN_LINK_SPEED			cpu_to_le32(0x00010107)
+#define OID_GEN_RNDIS_CONFIG_PARAMETER		cpu_to_le32(0x0001021b)
+
+#define OID_GEN_XMIT_OK				cpu_to_le32(0x00020101)
+#define OID_GEN_RCV_OK				cpu_to_le32(0x00020102)
+#define OID_GEN_XMIT_ERROR			cpu_to_le32(0x00020103)
+#define OID_GEN_RCV_ERROR			cpu_to_le32(0x00020104)
+#define OID_GEN_RCV_NO_BUFFER			cpu_to_le32(0x00020105)
+
+#define OID_802_3_PERMANENT_ADDRESS		cpu_to_le32(0x01010101)
+#define OID_802_3_CURRENT_ADDRESS		cpu_to_le32(0x01010102)
+#define OID_802_3_MULTICAST_LIST		cpu_to_le32(0x01010103)
+#define OID_802_3_MAXIMUM_LIST_SIZE		cpu_to_le32(0x01010104)
+
+#define OID_802_11_BSSID			cpu_to_le32(0x0d010101)
+#define OID_802_11_SSID				cpu_to_le32(0x0d010102)
+#define OID_802_11_INFRASTRUCTURE_MODE		cpu_to_le32(0x0d010108)
+#define OID_802_11_ADD_WEP			cpu_to_le32(0x0d010113)
+#define OID_802_11_REMOVE_WEP			cpu_to_le32(0x0d010114)
+#define OID_802_11_DISASSOCIATE			cpu_to_le32(0x0d010115)
+#define OID_802_11_AUTHENTICATION_MODE		cpu_to_le32(0x0d010118)
+#define OID_802_11_PRIVACY_FILTER		cpu_to_le32(0x0d010119)
+#define OID_802_11_BSSID_LIST_SCAN		cpu_to_le32(0x0d01011a)
+#define OID_802_11_ENCRYPTION_STATUS		cpu_to_le32(0x0d01011b)
+#define OID_802_11_ADD_KEY			cpu_to_le32(0x0d01011d)
+#define OID_802_11_REMOVE_KEY			cpu_to_le32(0x0d01011e)
+#define OID_802_11_ASSOCIATION_INFORMATION	cpu_to_le32(0x0d01011f)
+#define OID_802_11_PMKID			cpu_to_le32(0x0d010123)
+#define OID_802_11_NETWORK_TYPES_SUPPORTED	cpu_to_le32(0x0d010203)
+#define OID_802_11_NETWORK_TYPE_IN_USE		cpu_to_le32(0x0d010204)
+#define OID_802_11_TX_POWER_LEVEL		cpu_to_le32(0x0d010205)
+#define OID_802_11_RSSI				cpu_to_le32(0x0d010206)
+#define OID_802_11_RSSI_TRIGGER			cpu_to_le32(0x0d010207)
+#define OID_802_11_FRAGMENTATION_THRESHOLD	cpu_to_le32(0x0d010209)
+#define OID_802_11_RTS_THRESHOLD		cpu_to_le32(0x0d01020a)
+#define OID_802_11_SUPPORTED_RATES		cpu_to_le32(0x0d01020e)
+#define OID_802_11_CONFIGURATION		cpu_to_le32(0x0d010211)
+#define OID_802_11_BSSID_LIST			cpu_to_le32(0x0d010217)
 
 
 /* Typical noise/maximum signal level values taken from ndiswrapper iw_ndis.h */
@@ -144,8 +144,8 @@ MODULE_PARM_DESC(workaround_interval,
 
 
 /* codes for "status" field of completion messages */
-#define RNDIS_STATUS_ADAPTER_NOT_READY		ccpu2(0xc0010011)
-#define RNDIS_STATUS_ADAPTER_NOT_OPEN		ccpu2(0xc0010012)
+#define RNDIS_STATUS_ADAPTER_NOT_READY		cpu_to_le32(0xc0010011)
+#define RNDIS_STATUS_ADAPTER_NOT_OPEN		cpu_to_le32(0xc0010012)
 
 
 /* NDIS data structures. Taken from wpa_supplicant driver_ndis.c
@@ -442,7 +442,7 @@ static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
 
 	memset(u.get, 0, sizeof *u.get);
 	u.get->msg_type = RNDIS_MSG_QUERY;
-	u.get->msg_len = ccpu2(sizeof *u.get);
+	u.get->msg_len = cpu_to_le32(sizeof *u.get);
 	u.get->oid = oid;
 
 	ret = rndis_command(dev, u.header, buflen);
@@ -491,8 +491,8 @@ static int rndis_set_oid(struct usbnet *dev, __le32 oid, void *data, int len)
 	u.set->msg_len = cpu_to_le32(sizeof(*u.set) + len);
 	u.set->oid = oid;
 	u.set->len = cpu_to_le32(len);
-	u.set->offset = ccpu2(sizeof(*u.set) - 8);
-	u.set->handle = ccpu2(0);
+	u.set->offset = cpu_to_le32(sizeof(*u.set) - 8);
+	u.set->handle = cpu_to_le32(0);
 	memcpy(u.buf + sizeof(*u.set), data, len);
 
 	ret = rndis_command(dev, u.header, buflen);
@@ -1630,7 +1630,7 @@ static int rndis_iw_set_scan(struct net_device *dev,
 	devdbg(usbdev, "SIOCSIWSCAN");
 
 	if (wrqu->data.flags == 0) {
-		tmp = ccpu2(1);
+		tmp = cpu_to_le32(1);
 		ret = rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
 								sizeof(tmp));
 		evt.data.flags = 0;
@@ -2428,7 +2428,7 @@ static void rndis_update_wireless_stats(struct work_struct *work)
 		/* Send scan OID. Use of both OIDs is required to get device
 		 * working.
 		 */
-		tmp = ccpu2(1);
+		tmp = cpu_to_le32(1);
 		rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
 								sizeof(tmp));
 
diff --git a/drivers/usb/gadget/rndis.c b/drivers/usb/gadget/rndis.c
index 8c26f5e..d2860a8 100644
--- a/drivers/usb/gadget/rndis.c
+++ b/drivers/usb/gadget/rndis.c
@@ -63,7 +63,7 @@ MODULE_PARM_DESC (rndis_debug, "enable debugging");
 static rndis_params rndis_per_dev_params [RNDIS_MAX_CONFIGS];
 
 /* Driver Version */
-static const __le32 rndis_driver_version = __constant_cpu_to_le32 (1);
+static const __le32 rndis_driver_version = cpu_to_le32 (1);
 
 /* Function Prototypes */
 static rndis_resp_t *rndis_add_response (int configNr, u32 length);
@@ -190,7 +190,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 
 	/* response goes here, right after the header */
 	outbuf = (__le32 *) &resp[1];
-	resp->InformationBufferOffset = __constant_cpu_to_le32 (16);
+	resp->InformationBufferOffset = cpu_to_le32 (16);
 
 	net = rndis_per_dev_params[configNr].dev;
 	if (net->get_stats)
@@ -221,7 +221,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 		 * reddite ergo quae sunt Caesaris Caesari
 		 * et quae sunt Dei Deo!
 		 */
-		*outbuf = __constant_cpu_to_le32 (0);
+		*outbuf = cpu_to_le32 (0);
 		retval = 0;
 		break;
 
@@ -256,7 +256,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 			pr_debug("%s: OID_GEN_LINK_SPEED\n", __func__);
 		if (rndis_per_dev_params [configNr].media_state
 				== NDIS_MEDIA_STATE_DISCONNECTED)
-			*outbuf = __constant_cpu_to_le32 (0);
+			*outbuf = cpu_to_le32 (0);
 		else
 			*outbuf = cpu_to_le32 (
 				rndis_per_dev_params [configNr].speed);
@@ -317,7 +317,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 	/* mandatory */
 	case OID_GEN_MAXIMUM_TOTAL_SIZE:
 		pr_debug("%s: OID_GEN_MAXIMUM_TOTAL_SIZE\n", __func__);
-		*outbuf = __constant_cpu_to_le32(RNDIS_MAX_TOTAL_SIZE);
+		*outbuf = cpu_to_le32(RNDIS_MAX_TOTAL_SIZE);
 		retval = 0;
 		break;
 
@@ -332,7 +332,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 
 	case OID_GEN_PHYSICAL_MEDIUM:
 		pr_debug("%s: OID_GEN_PHYSICAL_MEDIUM\n", __func__);
-		*outbuf = __constant_cpu_to_le32 (0);
+		*outbuf = cpu_to_le32 (0);
 		retval = 0;
 		break;
 
@@ -342,7 +342,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 	 */
 	case OID_GEN_MAC_OPTIONS:		/* from WinME */
 		pr_debug("%s: OID_GEN_MAC_OPTIONS\n", __func__);
-		*outbuf = __constant_cpu_to_le32(
+		*outbuf = cpu_to_le32(
 			  NDIS_MAC_OPTION_RECEIVE_SERIALIZED
 			| NDIS_MAC_OPTION_FULL_DUPLEX);
 		retval = 0;
@@ -431,7 +431,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 	case OID_802_3_MULTICAST_LIST:
 		pr_debug("%s: OID_802_3_MULTICAST_LIST\n", __func__);
 		/* Multicast base address only */
-		*outbuf = __constant_cpu_to_le32 (0xE0000000);
+		*outbuf = cpu_to_le32 (0xE0000000);
 		retval = 0;
 		break;
 
@@ -439,7 +439,7 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 	case OID_802_3_MAXIMUM_LIST_SIZE:
 		pr_debug("%s: OID_802_3_MAXIMUM_LIST_SIZE\n", __func__);
 		/* Multicast base address only */
-		*outbuf = __constant_cpu_to_le32 (1);
+		*outbuf = cpu_to_le32 (1);
 		retval = 0;
 		break;
 
@@ -461,14 +461,14 @@ gen_ndis_query_resp (int configNr, u32 OID, u8 *buf, unsigned buf_len,
 	/* mandatory */
 	case OID_802_3_XMIT_ONE_COLLISION:
 		pr_debug("%s: OID_802_3_XMIT_ONE_COLLISION\n", __func__);
-		*outbuf = __constant_cpu_to_le32 (0);
+		*outbuf = cpu_to_le32 (0);
 		retval = 0;
 		break;
 
 	/* mandatory */
 	case OID_802_3_XMIT_MORE_COLLISIONS:
 		pr_debug("%s: OID_802_3_XMIT_MORE_COLLISIONS\n", __func__);
-		*outbuf = __constant_cpu_to_le32 (0);
+		*outbuf = cpu_to_le32 (0);
 		retval = 0;
 		break;
 
@@ -572,24 +572,24 @@ static int rndis_init_response (int configNr, rndis_init_msg_type *buf)
 		return -ENOMEM;
 	resp = (rndis_init_cmplt_type *) r->buf;
 
-	resp->MessageType = __constant_cpu_to_le32 (
+	resp->MessageType = cpu_to_le32 (
 			REMOTE_NDIS_INITIALIZE_CMPLT);
-	resp->MessageLength = __constant_cpu_to_le32 (52);
+	resp->MessageLength = cpu_to_le32 (52);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
-	resp->Status = __constant_cpu_to_le32 (RNDIS_STATUS_SUCCESS);
-	resp->MajorVersion = __constant_cpu_to_le32 (RNDIS_MAJOR_VERSION);
-	resp->MinorVersion = __constant_cpu_to_le32 (RNDIS_MINOR_VERSION);
-	resp->DeviceFlags = __constant_cpu_to_le32 (RNDIS_DF_CONNECTIONLESS);
-	resp->Medium = __constant_cpu_to_le32 (RNDIS_MEDIUM_802_3);
-	resp->MaxPacketsPerTransfer = __constant_cpu_to_le32 (1);
+	resp->Status = cpu_to_le32 (RNDIS_STATUS_SUCCESS);
+	resp->MajorVersion = cpu_to_le32 (RNDIS_MAJOR_VERSION);
+	resp->MinorVersion = cpu_to_le32 (RNDIS_MINOR_VERSION);
+	resp->DeviceFlags = cpu_to_le32 (RNDIS_DF_CONNECTIONLESS);
+	resp->Medium = cpu_to_le32 (RNDIS_MEDIUM_802_3);
+	resp->MaxPacketsPerTransfer = cpu_to_le32 (1);
 	resp->MaxTransferSize = cpu_to_le32 (
 		  params->dev->mtu
 		+ sizeof (struct ethhdr)
 		+ sizeof (struct rndis_packet_msg_type)
 		+ 22);
-	resp->PacketAlignmentFactor = __constant_cpu_to_le32 (0);
-	resp->AFListOffset = __constant_cpu_to_le32 (0);
-	resp->AFListSize = __constant_cpu_to_le32 (0);
+	resp->PacketAlignmentFactor = cpu_to_le32 (0);
+	resp->AFListOffset = cpu_to_le32 (0);
+	resp->AFListSize = cpu_to_le32 (0);
 
 	params->resp_avail(params->v);
 	return 0;
@@ -617,7 +617,7 @@ static int rndis_query_response (int configNr, rndis_query_msg_type *buf)
 		return -ENOMEM;
 	resp = (rndis_query_cmplt_type *) r->buf;
 
-	resp->MessageType = __constant_cpu_to_le32 (REMOTE_NDIS_QUERY_CMPLT);
+	resp->MessageType = cpu_to_le32 (REMOTE_NDIS_QUERY_CMPLT);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
 
 	if (gen_ndis_query_resp (configNr, le32_to_cpu (buf->OID),
@@ -626,13 +626,13 @@ static int rndis_query_response (int configNr, rndis_query_msg_type *buf)
 			le32_to_cpu(buf->InformationBufferLength),
 			r)) {
 		/* OID not supported */
-		resp->Status = __constant_cpu_to_le32 (
+		resp->Status = cpu_to_le32 (
 				RNDIS_STATUS_NOT_SUPPORTED);
-		resp->MessageLength = __constant_cpu_to_le32 (sizeof *resp);
-		resp->InformationBufferLength = __constant_cpu_to_le32 (0);
-		resp->InformationBufferOffset = __constant_cpu_to_le32 (0);
+		resp->MessageLength = cpu_to_le32 (sizeof *resp);
+		resp->InformationBufferLength = cpu_to_le32 (0);
+		resp->InformationBufferOffset = cpu_to_le32 (0);
 	} else
-		resp->Status = __constant_cpu_to_le32 (RNDIS_STATUS_SUCCESS);
+		resp->Status = cpu_to_le32 (RNDIS_STATUS_SUCCESS);
 
 	params->resp_avail(params->v);
 	return 0;
@@ -665,14 +665,14 @@ static int rndis_set_response (int configNr, rndis_set_msg_type *buf)
 	pr_debug("\n");
 #endif
 
-	resp->MessageType = __constant_cpu_to_le32 (REMOTE_NDIS_SET_CMPLT);
-	resp->MessageLength = __constant_cpu_to_le32 (16);
+	resp->MessageType = cpu_to_le32 (REMOTE_NDIS_SET_CMPLT);
+	resp->MessageLength = cpu_to_le32 (16);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
 	if (gen_ndis_set_resp (configNr, le32_to_cpu (buf->OID),
 			((u8 *) buf) + 8 + BufOffset, BufLength, r))
-		resp->Status = __constant_cpu_to_le32 (RNDIS_STATUS_NOT_SUPPORTED);
+		resp->Status = cpu_to_le32 (RNDIS_STATUS_NOT_SUPPORTED);
 	else
-		resp->Status = __constant_cpu_to_le32 (RNDIS_STATUS_SUCCESS);
+		resp->Status = cpu_to_le32 (RNDIS_STATUS_SUCCESS);
 
 	params->resp_avail(params->v);
 	return 0;
@@ -689,11 +689,11 @@ static int rndis_reset_response (int configNr, rndis_reset_msg_type *buf)
 		return -ENOMEM;
 	resp = (rndis_reset_cmplt_type *) r->buf;
 
-	resp->MessageType = __constant_cpu_to_le32 (REMOTE_NDIS_RESET_CMPLT);
-	resp->MessageLength = __constant_cpu_to_le32 (16);
-	resp->Status = __constant_cpu_to_le32 (RNDIS_STATUS_SUCCESS);
+	resp->MessageType = cpu_to_le32 (REMOTE_NDIS_RESET_CMPLT);
+	resp->MessageLength = cpu_to_le32 (16);
+	resp->Status = cpu_to_le32 (RNDIS_STATUS_SUCCESS);
 	/* resent information */
-	resp->AddressingReset = __constant_cpu_to_le32 (1);
+	resp->AddressingReset = cpu_to_le32 (1);
 
 	params->resp_avail(params->v);
 	return 0;
@@ -713,11 +713,11 @@ static int rndis_keepalive_response (int configNr,
 		return -ENOMEM;
 	resp = (rndis_keepalive_cmplt_type *) r->buf;
 
-	resp->MessageType = __constant_cpu_to_le32 (
+	resp->MessageType = cpu_to_le32 (
 			REMOTE_NDIS_KEEPALIVE_CMPLT);
-	resp->MessageLength = __constant_cpu_to_le32 (16);
+	resp->MessageLength = cpu_to_le32 (16);
 	resp->RequestID = buf->RequestID; /* Still LE in msg buffer */
-	resp->Status = __constant_cpu_to_le32 (RNDIS_STATUS_SUCCESS);
+	resp->Status = cpu_to_le32 (RNDIS_STATUS_SUCCESS);
 
 	params->resp_avail(params->v);
 	return 0;
@@ -742,12 +742,12 @@ static int rndis_indicate_status_msg (int configNr, u32 status)
 		return -ENOMEM;
 	resp = (rndis_indicate_status_msg_type *) r->buf;
 
-	resp->MessageType = __constant_cpu_to_le32 (
+	resp->MessageType = cpu_to_le32 (
 			REMOTE_NDIS_INDICATE_STATUS_MSG);
-	resp->MessageLength = __constant_cpu_to_le32 (20);
+	resp->MessageLength = cpu_to_le32 (20);
 	resp->Status = cpu_to_le32 (status);
-	resp->StatusBufferLength = __constant_cpu_to_le32 (0);
-	resp->StatusBufferOffset = __constant_cpu_to_le32 (0);
+	resp->StatusBufferLength = cpu_to_le32 (0);
+	resp->StatusBufferOffset = cpu_to_le32 (0);
 
 	params->resp_avail(params->v);
 	return 0;
@@ -963,9 +963,9 @@ void rndis_add_hdr (struct sk_buff *skb)
 		return;
 	header = (void *) skb_push (skb, sizeof *header);
 	memset (header, 0, sizeof *header);
-	header->MessageType = __constant_cpu_to_le32(REMOTE_NDIS_PACKET_MSG);
+	header->MessageType = cpu_to_le32(REMOTE_NDIS_PACKET_MSG);
 	header->MessageLength = cpu_to_le32(skb->len);
-	header->DataOffset = __constant_cpu_to_le32 (36);
+	header->DataOffset = cpu_to_le32 (36);
 	header->DataLength = cpu_to_le32(skb->len - sizeof *header);
 }
 
@@ -1029,7 +1029,7 @@ int rndis_rm_hdr(struct sk_buff *skb)
 	__le32		*tmp = (void *) skb->data;
 
 	/* MessageType, MessageLength */
-	if (__constant_cpu_to_le32(REMOTE_NDIS_PACKET_MSG)
+	if (cpu_to_le32(REMOTE_NDIS_PACKET_MSG)
 			!= get_unaligned(tmp++))
 		return -EINVAL;
 	tmp++;
diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_host.h
index 0a6e6d4..37836b9 100644
--- a/include/linux/usb/rndis_host.h
+++ b/include/linux/usb/rndis_host.h
@@ -49,48 +49,45 @@ struct rndis_msg_hdr {
  */
 #define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
 
-
-#define ccpu2 __constant_cpu_to_le32
-
-#define RNDIS_MSG_COMPLETION	ccpu2(0x80000000)
+#define RNDIS_MSG_COMPLETION	cpu_to_le32(0x80000000)
 
 /* codes for "msg_type" field of rndis messages;
  * only the data channel uses packet messages (maybe batched);
  * everything else goes on the control channel.
  */
-#define RNDIS_MSG_PACKET	ccpu2(0x00000001)	/* 1-N packets */
-#define RNDIS_MSG_INIT		ccpu2(0x00000002)
+#define RNDIS_MSG_PACKET	cpu_to_le32(0x00000001)	/* 1-N packets */
+#define RNDIS_MSG_INIT		cpu_to_le32(0x00000002)
 #define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_HALT		ccpu2(0x00000003)
-#define RNDIS_MSG_QUERY		ccpu2(0x00000004)
+#define RNDIS_MSG_HALT		cpu_to_le32(0x00000003)
+#define RNDIS_MSG_QUERY		cpu_to_le32(0x00000004)
 #define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_SET		ccpu2(0x00000005)
+#define RNDIS_MSG_SET		cpu_to_le32(0x00000005)
 #define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_RESET		ccpu2(0x00000006)
+#define RNDIS_MSG_RESET		cpu_to_le32(0x00000006)
 #define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_INDICATE	ccpu2(0x00000007)
-#define RNDIS_MSG_KEEPALIVE	ccpu2(0x00000008)
+#define RNDIS_MSG_INDICATE	cpu_to_le32(0x00000007)
+#define RNDIS_MSG_KEEPALIVE	cpu_to_le32(0x00000008)
 #define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
 
 /* codes for "status" field of completion messages */
-#define	RNDIS_STATUS_SUCCESS		ccpu2(0x00000000)
-#define	RNDIS_STATUS_FAILURE		ccpu2(0xc0000001)
-#define	RNDIS_STATUS_INVALID_DATA	ccpu2(0xc0010015)
-#define	RNDIS_STATUS_NOT_SUPPORTED	ccpu2(0xc00000bb)
-#define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
-#define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
+#define	RNDIS_STATUS_SUCCESS		cpu_to_le32(0x00000000)
+#define	RNDIS_STATUS_FAILURE		cpu_to_le32(0xc0000001)
+#define	RNDIS_STATUS_INVALID_DATA	cpu_to_le32(0xc0010015)
+#define	RNDIS_STATUS_NOT_SUPPORTED	cpu_to_le32(0xc00000bb)
+#define	RNDIS_STATUS_MEDIA_CONNECT	cpu_to_le32(0x4001000b)
+#define	RNDIS_STATUS_MEDIA_DISCONNECT	cpu_to_le32(0x4001000c)
 
 /* codes for OID_GEN_PHYSICAL_MEDIUM */
-#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	ccpu2(0x00000000)
-#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	ccpu2(0x00000001)
-#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	ccpu2(0x00000002)
-#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	ccpu2(0x00000003)
-#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	ccpu2(0x00000004)
-#define	RNDIS_PHYSICAL_MEDIUM_DSL		ccpu2(0x00000005)
-#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	ccpu2(0x00000006)
-#define	RNDIS_PHYSICAL_MEDIUM_1394		ccpu2(0x00000007)
-#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	ccpu2(0x00000008)
-#define	RNDIS_PHYSICAL_MEDIUM_MAX		ccpu2(0x00000009)
+#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	cpu_to_le32(0x00000000)
+#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	cpu_to_le32(0x00000001)
+#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	cpu_to_le32(0x00000002)
+#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	cpu_to_le32(0x00000003)
+#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	cpu_to_le32(0x00000004)
+#define	RNDIS_PHYSICAL_MEDIUM_DSL		cpu_to_le32(0x00000005)
+#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	cpu_to_le32(0x00000006)
+#define	RNDIS_PHYSICAL_MEDIUM_1394		cpu_to_le32(0x00000007)
+#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	cpu_to_le32(0x00000008)
+#define	RNDIS_PHYSICAL_MEDIUM_MAX		cpu_to_le32(0x00000009)
 
 struct rndis_data_hdr {
 	__le32	msg_type;		/* RNDIS_MSG_PACKET */
@@ -228,24 +225,24 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
  * there are gobs more that may optionally be supported.  We'll avoid as much
  * of that mess as possible.
  */
-#define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
-#define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
-#define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
-#define OID_GEN_PHYSICAL_MEDIUM		ccpu2(0x00010202)
+#define OID_802_3_PERMANENT_ADDRESS	cpu_to_le32(0x01010101)
+#define OID_GEN_MAXIMUM_FRAME_SIZE	cpu_to_le32(0x00010106)
+#define OID_GEN_CURRENT_PACKET_FILTER	cpu_to_le32(0x0001010e)
+#define OID_GEN_PHYSICAL_MEDIUM		cpu_to_le32(0x00010202)
 
 /* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
-#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
-#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
-#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
-#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
-#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
-#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
-#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
-#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
-#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
-#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
-#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
-#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
+#define RNDIS_PACKET_TYPE_DIRECTED		cpu_to_le32(0x00000001)
+#define RNDIS_PACKET_TYPE_MULTICAST		cpu_to_le32(0x00000002)
+#define RNDIS_PACKET_TYPE_ALL_MULTICAST		cpu_to_le32(0x00000004)
+#define RNDIS_PACKET_TYPE_BROADCAST		cpu_to_le32(0x00000008)
+#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	cpu_to_le32(0x00000010)
+#define RNDIS_PACKET_TYPE_PROMISCUOUS		cpu_to_le32(0x00000020)
+#define RNDIS_PACKET_TYPE_SMT			cpu_to_le32(0x00000040)
+#define RNDIS_PACKET_TYPE_ALL_LOCAL		cpu_to_le32(0x00000080)
+#define RNDIS_PACKET_TYPE_GROUP			cpu_to_le32(0x00001000)
+#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	cpu_to_le32(0x00002000)
+#define RNDIS_PACKET_TYPE_FUNCTIONAL		cpu_to_le32(0x00004000)
+#define RNDIS_PACKET_TYPE_MAC_FRAME		cpu_to_le32(0x00008000)
 
 /* default filter used with RNDIS devices */
 #define RNDIS_DEFAULT_FILTER ( \
-- 
1.6.2.rc0.218.gde7c



