From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/14] usb/net: rndis: inline the cpu_to_le32() macro
Date: Sun,  8 Apr 2012 10:47:19 +0200
Message-ID: <1333874839-4203-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The header file <linux/usb/rndis_host.h> used a number of #defines
that included the cpu_to_le32() macro to assure the result will be
in LE endianness. Inlining this into the code instead of using it
in the code definitions yields consolidation opportunities later
on as you will see in the following patches. The individual
drivers also used local defines - all are switched over to the
pattern of doing the conversion at the call sites instead.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/usb/rndis_host.c      |   52 +++++++-------
 drivers/net/wireless/rndis_wlan.c |  138 +++++++++++++++++++------------------
 include/linux/usb/rndis_host.h    |   84 +++++++++++-----------
 3 files changed, 139 insertions(+), 135 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index c8f1b5b..05cad0b 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -78,10 +78,10 @@ static void rndis_msg_indicate(struct usbnet *dev, struct rndis_indicate *msg,
 		dev->driver_info->indication(dev, msg, buflen);
 	} else {
 		switch (msg->status) {
-		case RNDIS_STATUS_MEDIA_CONNECT:
+		case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
 			dev_info(udev, "rndis media connect\n");
 			break;
-		case RNDIS_STATUS_MEDIA_DISCONNECT:
+		case cpu_to_le32(RNDIS_STATUS_MEDIA_DISCONNECT):
 			dev_info(udev, "rndis media disconnect\n");
 			break;
 		default:
@@ -117,8 +117,8 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	 */
 
 	/* Issue the request; xid is unique, don't bother byteswapping it */
-	if (likely(buf->msg_type != RNDIS_MSG_HALT &&
-		   buf->msg_type != RNDIS_MSG_RESET)) {
+	if (likely(buf->msg_type != cpu_to_le32(RNDIS_MSG_HALT) &&
+		   buf->msg_type != cpu_to_le32(RNDIS_MSG_RESET))) {
 		xid = dev->xid++;
 		if (!xid)
 			xid = dev->xid++;
@@ -164,9 +164,10 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 			request_id = (__force u32) buf->request_id;
 			if (likely(buf->msg_type == rsp)) {
 				if (likely(request_id == xid)) {
-					if (unlikely(rsp == RNDIS_MSG_RESET_C))
+					if (unlikely(rsp ==
+					    cpu_to_le32(RNDIS_MSG_RESET_C)))
 						return 0;
-					if (likely(RNDIS_STATUS_SUCCESS
+					if (likely(cpu_to_le32(RNDIS_STATUS_SUCCESS)
 							== buf->status))
 						return 0;
 					dev_dbg(&info->control->dev,
@@ -179,16 +180,15 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 					request_id, xid);
 				/* then likely retry */
 			} else switch (buf->msg_type) {
-			case RNDIS_MSG_INDICATE:	/* fault/event */
+			case cpu_to_le32(RNDIS_MSG_INDICATE): /* fault/event */
 				rndis_msg_indicate(dev, (void *)buf, buflen);
-
 				break;
-			case RNDIS_MSG_KEEPALIVE: {	/* ping */
+			case cpu_to_le32(RNDIS_MSG_KEEPALIVE): { /* ping */
 				struct rndis_keepalive_c *msg = (void *)buf;
 
-				msg->msg_type = RNDIS_MSG_KEEPALIVE_C;
+				msg->msg_type = cpu_to_le32(RNDIS_MSG_KEEPALIVE_C);
 				msg->msg_len = cpu_to_le32(sizeof *msg);
-				msg->status = RNDIS_STATUS_SUCCESS;
+				msg->status = cpu_to_le32(RNDIS_STATUS_SUCCESS);
 				retval = usb_control_msg(dev->udev,
 					usb_sndctrlpipe(dev->udev, 0),
 					USB_CDC_SEND_ENCAPSULATED_COMMAND,
@@ -251,7 +251,7 @@ static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
 	u.buf = buf;
 
 	memset(u.get, 0, sizeof *u.get + in_len);
-	u.get->msg_type = RNDIS_MSG_QUERY;
+	u.get->msg_type = cpu_to_le32(RNDIS_MSG_QUERY);
 	u.get->msg_len = cpu_to_le32(sizeof *u.get + in_len);
 	u.get->oid = oid;
 	u.get->len = cpu_to_le32(in_len);
@@ -324,7 +324,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	if (retval < 0)
 		goto fail;
 
-	u.init->msg_type = RNDIS_MSG_INIT;
+	u.init->msg_type = cpu_to_le32(RNDIS_MSG_INIT);
 	u.init->msg_len = cpu_to_le32(sizeof *u.init);
 	u.init->major_version = cpu_to_le32(1);
 	u.init->minor_version = cpu_to_le32(0);
@@ -395,22 +395,23 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	/* Check physical medium */
 	phym = NULL;
 	reply_len = sizeof *phym;
-	retval = rndis_query(dev, intf, u.buf, OID_GEN_PHYSICAL_MEDIUM,
+	retval = rndis_query(dev, intf, u.buf,
+			     cpu_to_le32(OID_GEN_PHYSICAL_MEDIUM),
 			0, (void **) &phym, &reply_len);
 	if (retval != 0 || !phym) {
 		/* OID is optional so don't fail here. */
-		phym_unspec = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
+		phym_unspec = cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED);
 		phym = &phym_unspec;
 	}
 	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
-			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
+	    *phym != cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN)) {
 		netif_dbg(dev, probe, dev->net,
 			  "driver requires wireless physical medium, but device is not\n");
 		retval = -ENODEV;
 		goto halt_fail_and_release;
 	}
 	if ((flags & FLAG_RNDIS_PHYM_NOT_WIRELESS) &&
-			*phym == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
+	    *phym == cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN)) {
 		netif_dbg(dev, probe, dev->net,
 			  "driver requires non-wireless physical medium, but device is wireless.\n");
 		retval = -ENODEV;
@@ -419,7 +420,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 
 	/* Get designated host ethernet address */
 	reply_len = ETH_ALEN;
-	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
+	retval = rndis_query(dev, intf, u.buf,
+			     cpu_to_le32(OID_802_3_PERMANENT_ADDRESS),
 			48, (void **) &bp, &reply_len);
 	if (unlikely(retval< 0)) {
 		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
@@ -430,12 +432,12 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 
 	/* set a nonzero filter to enable data transfers */
 	memset(u.set, 0, sizeof *u.set);
-	u.set->msg_type = RNDIS_MSG_SET;
+	u.set->msg_type = cpu_to_le32(RNDIS_MSG_SET);
 	u.set->msg_len = cpu_to_le32(4 + sizeof *u.set);
-	u.set->oid = OID_GEN_CURRENT_PACKET_FILTER;
+	u.set->oid = cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER);
 	u.set->len = cpu_to_le32(4);
 	u.set->offset = cpu_to_le32((sizeof *u.set) - 8);
-	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
+	*(__le32 *)(u.buf + sizeof *u.set) = cpu_to_le32(RNDIS_DEFAULT_FILTER);
 
 	retval = rndis_command(dev, u.header, CONTROL_BUFFER_SIZE);
 	if (unlikely(retval < 0)) {
@@ -450,7 +452,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 
 halt_fail_and_release:
 	memset(u.halt, 0, sizeof *u.halt);
-	u.halt->msg_type = RNDIS_MSG_HALT;
+	u.halt->msg_type = cpu_to_le32(RNDIS_MSG_HALT);
 	u.halt->msg_len = cpu_to_le32(sizeof *u.halt);
 	(void) rndis_command(dev, (void *)u.halt, CONTROL_BUFFER_SIZE);
 fail_and_release:
@@ -475,7 +477,7 @@ void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 	/* try to clear any rndis state/activity (no i/o from stack!) */
 	halt = kzalloc(CONTROL_BUFFER_SIZE, GFP_KERNEL);
 	if (halt) {
-		halt->msg_type = RNDIS_MSG_HALT;
+		halt->msg_type = cpu_to_le32(RNDIS_MSG_HALT);
 		halt->msg_len = cpu_to_le32(sizeof *halt);
 		(void) rndis_command(dev, (void *)halt, CONTROL_BUFFER_SIZE);
 		kfree(halt);
@@ -501,7 +503,7 @@ int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		data_len = le32_to_cpu(hdr->data_len);
 
 		/* don't choke if we see oob, per-packet data, etc */
-		if (unlikely(hdr->msg_type != RNDIS_MSG_PACKET ||
+		if (unlikely(hdr->msg_type != cpu_to_le32(RNDIS_MSG_PACKET) ||
 			     skb->len < msg_len ||
 			     (data_offset + data_len + 8) > msg_len)) {
 			dev->net->stats.rx_frame_errors++;
@@ -569,7 +571,7 @@ rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 fill:
 	hdr = (void *) __skb_push(skb, sizeof *hdr);
 	memset(hdr, 0, sizeof *hdr);
-	hdr->msg_type = RNDIS_MSG_PACKET;
+	hdr->msg_type = cpu_to_le32(RNDIS_MSG_PACKET);
 	hdr->msg_len = cpu_to_le32(skb->len);
 	hdr->data_offset = cpu_to_le32(sizeof(*hdr) - 8);
 	hdr->data_len = cpu_to_le32(len);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d66e298..a935012 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -90,45 +90,45 @@ MODULE_PARM_DESC(workaround_interval,
 
 
 /* various RNDIS OID defs */
-#define OID_GEN_LINK_SPEED			cpu_to_le32(0x00010107)
-#define OID_GEN_RNDIS_CONFIG_PARAMETER		cpu_to_le32(0x0001021b)
-
-#define OID_GEN_XMIT_OK				cpu_to_le32(0x00020101)
-#define OID_GEN_RCV_OK				cpu_to_le32(0x00020102)
-#define OID_GEN_XMIT_ERROR			cpu_to_le32(0x00020103)
-#define OID_GEN_RCV_ERROR			cpu_to_le32(0x00020104)
-#define OID_GEN_RCV_NO_BUFFER			cpu_to_le32(0x00020105)
-
-#define OID_802_3_CURRENT_ADDRESS		cpu_to_le32(0x01010102)
-#define OID_802_3_MULTICAST_LIST		cpu_to_le32(0x01010103)
-#define OID_802_3_MAXIMUM_LIST_SIZE		cpu_to_le32(0x01010104)
-
-#define OID_802_11_BSSID			cpu_to_le32(0x0d010101)
-#define OID_802_11_SSID				cpu_to_le32(0x0d010102)
-#define OID_802_11_INFRASTRUCTURE_MODE		cpu_to_le32(0x0d010108)
-#define OID_802_11_ADD_WEP			cpu_to_le32(0x0d010113)
-#define OID_802_11_REMOVE_WEP			cpu_to_le32(0x0d010114)
-#define OID_802_11_DISASSOCIATE			cpu_to_le32(0x0d010115)
-#define OID_802_11_AUTHENTICATION_MODE		cpu_to_le32(0x0d010118)
-#define OID_802_11_PRIVACY_FILTER		cpu_to_le32(0x0d010119)
-#define OID_802_11_BSSID_LIST_SCAN		cpu_to_le32(0x0d01011a)
-#define OID_802_11_ENCRYPTION_STATUS		cpu_to_le32(0x0d01011b)
-#define OID_802_11_ADD_KEY			cpu_to_le32(0x0d01011d)
-#define OID_802_11_REMOVE_KEY			cpu_to_le32(0x0d01011e)
-#define OID_802_11_ASSOCIATION_INFORMATION	cpu_to_le32(0x0d01011f)
-#define OID_802_11_CAPABILITY			cpu_to_le32(0x0d010122)
-#define OID_802_11_PMKID			cpu_to_le32(0x0d010123)
-#define OID_802_11_NETWORK_TYPES_SUPPORTED	cpu_to_le32(0x0d010203)
-#define OID_802_11_NETWORK_TYPE_IN_USE		cpu_to_le32(0x0d010204)
-#define OID_802_11_TX_POWER_LEVEL		cpu_to_le32(0x0d010205)
-#define OID_802_11_RSSI				cpu_to_le32(0x0d010206)
-#define OID_802_11_RSSI_TRIGGER			cpu_to_le32(0x0d010207)
-#define OID_802_11_FRAGMENTATION_THRESHOLD	cpu_to_le32(0x0d010209)
-#define OID_802_11_RTS_THRESHOLD		cpu_to_le32(0x0d01020a)
-#define OID_802_11_SUPPORTED_RATES		cpu_to_le32(0x0d01020e)
-#define OID_802_11_CONFIGURATION		cpu_to_le32(0x0d010211)
-#define OID_802_11_POWER_MODE			cpu_to_le32(0x0d010216)
-#define OID_802_11_BSSID_LIST			cpu_to_le32(0x0d010217)
+#define OID_GEN_LINK_SPEED			0x00010107
+#define OID_GEN_RNDIS_CONFIG_PARAMETER		0x0001021b
+
+#define OID_GEN_XMIT_OK				0x00020101
+#define OID_GEN_RCV_OK				0x00020102
+#define OID_GEN_XMIT_ERROR			0x00020103
+#define OID_GEN_RCV_ERROR			0x00020104
+#define OID_GEN_RCV_NO_BUFFER			0x00020105
+
+#define OID_802_3_CURRENT_ADDRESS		0x01010102
+#define OID_802_3_MULTICAST_LIST		0x01010103
+#define OID_802_3_MAXIMUM_LIST_SIZE		0x01010104
+
+#define OID_802_11_BSSID			0x0d010101
+#define OID_802_11_SSID				0x0d010102
+#define OID_802_11_INFRASTRUCTURE_MODE		0x0d010108
+#define OID_802_11_ADD_WEP			0x0d010113
+#define OID_802_11_REMOVE_WEP			0x0d010114
+#define OID_802_11_DISASSOCIATE			0x0d010115
+#define OID_802_11_AUTHENTICATION_MODE		0x0d010118
+#define OID_802_11_PRIVACY_FILTER		0x0d010119
+#define OID_802_11_BSSID_LIST_SCAN		0x0d01011a
+#define OID_802_11_ENCRYPTION_STATUS		0x0d01011b
+#define OID_802_11_ADD_KEY			0x0d01011d
+#define OID_802_11_REMOVE_KEY			0x0d01011e
+#define OID_802_11_ASSOCIATION_INFORMATION	0x0d01011f
+#define OID_802_11_CAPABILITY			0x0d010122
+#define OID_802_11_PMKID			0x0d010123
+#define OID_802_11_NETWORK_TYPES_SUPPORTED	0x0d010203
+#define OID_802_11_NETWORK_TYPE_IN_USE		0x0d010204
+#define OID_802_11_TX_POWER_LEVEL		0x0d010205
+#define OID_802_11_RSSI				0x0d010206
+#define OID_802_11_RSSI_TRIGGER			0x0d010207
+#define OID_802_11_FRAGMENTATION_THRESHOLD	0x0d010209
+#define OID_802_11_RTS_THRESHOLD		0x0d01020a
+#define OID_802_11_SUPPORTED_RATES		0x0d01020e
+#define OID_802_11_CONFIGURATION		0x0d010211
+#define OID_802_11_POWER_MODE			0x0d010216
+#define OID_802_11_BSSID_LIST			0x0d010217
 
 
 /* Typical noise/maximum signal level values taken from ndiswrapper iw_ndis.h */
@@ -151,8 +151,8 @@ MODULE_PARM_DESC(workaround_interval,
 
 
 /* codes for "status" field of completion messages */
-#define RNDIS_STATUS_ADAPTER_NOT_READY		cpu_to_le32(0xc0010011)
-#define RNDIS_STATUS_ADAPTER_NOT_OPEN		cpu_to_le32(0xc0010012)
+#define RNDIS_STATUS_ADAPTER_NOT_READY		0xc0010011
+#define RNDIS_STATUS_ADAPTER_NOT_OPEN		0xc0010012
 
 
 /* Known device types */
@@ -673,7 +673,7 @@ static int rndis_akm_suite_to_key_mgmt(u32 akm_suite)
 static const char *oid_to_string(__le32 oid)
 {
 	switch (oid) {
-#define OID_STR(oid) case oid: return(#oid)
+#define OID_STR(oid) case cpu_to_le32(oid): return(#oid)
 		/* from rndis_host.h */
 		OID_STR(OID_802_3_PERMANENT_ADDRESS);
 		OID_STR(OID_GEN_MAXIMUM_FRAME_SIZE);
@@ -737,18 +737,18 @@ static int rndis_error_status(__le32 rndis_status)
 {
 	int ret = -EINVAL;
 	switch (rndis_status) {
-	case RNDIS_STATUS_SUCCESS:
+	case cpu_to_le32(RNDIS_STATUS_SUCCESS):
 		ret = 0;
 		break;
-	case RNDIS_STATUS_FAILURE:
-	case RNDIS_STATUS_INVALID_DATA:
+	case cpu_to_le32(RNDIS_STATUS_FAILURE):
+	case cpu_to_le32(RNDIS_STATUS_INVALID_DATA):
 		ret = -EINVAL;
 		break;
-	case RNDIS_STATUS_NOT_SUPPORTED:
+	case cpu_to_le32(RNDIS_STATUS_NOT_SUPPORTED):
 		ret = -EOPNOTSUPP;
 		break;
-	case RNDIS_STATUS_ADAPTER_NOT_READY:
-	case RNDIS_STATUS_ADAPTER_NOT_OPEN:
+	case cpu_to_le32(RNDIS_STATUS_ADAPTER_NOT_READY):
+	case cpu_to_le32(RNDIS_STATUS_ADAPTER_NOT_OPEN):
 		ret = -EBUSY;
 		break;
 	}
@@ -782,7 +782,7 @@ static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
 	mutex_lock(&priv->command_lock);
 
 	memset(u.get, 0, sizeof *u.get);
-	u.get->msg_type = RNDIS_MSG_QUERY;
+	u.get->msg_type = cpu_to_le32(RNDIS_MSG_QUERY);
 	u.get->msg_len = cpu_to_le32(sizeof *u.get);
 	u.get->oid = oid;
 
@@ -866,7 +866,7 @@ static int rndis_set_oid(struct usbnet *dev, __le32 oid, const void *data,
 	mutex_lock(&priv->command_lock);
 
 	memset(u.set, 0, sizeof *u.set);
-	u.set->msg_type = RNDIS_MSG_SET;
+	u.set->msg_type = cpu_to_le32(RNDIS_MSG_SET);
 	u.set->msg_len = cpu_to_le32(sizeof(*u.set) + len);
 	u.set->oid = oid;
 	u.set->len = cpu_to_le32(len);
@@ -908,7 +908,7 @@ static int rndis_reset(struct usbnet *usbdev)
 
 	reset = (void *)priv->command_buffer;
 	memset(reset, 0, sizeof(*reset));
-	reset->msg_type = RNDIS_MSG_RESET;
+	reset->msg_type = cpu_to_le32(RNDIS_MSG_RESET);
 	reset->msg_len = cpu_to_le32(sizeof(*reset));
 	priv->current_command_oid = 0;
 	ret = rndis_command(usbdev, (void *)reset, CONTROL_BUFFER_SIZE);
@@ -994,7 +994,7 @@ static int rndis_set_config_parameter(struct usbnet *dev, char *param,
 	}
 #endif
 
-	ret = rndis_set_oid(dev, OID_GEN_RNDIS_CONFIG_PARAMETER,
+	ret = rndis_set_oid(dev, cpu_to_le32(OID_GEN_RNDIS_CONFIG_PARAMETER),
 							infobuf, info_len);
 	if (ret != 0)
 		netdev_dbg(dev->net, "setting rndis config parameter failed, %d\n",
@@ -1626,14 +1626,14 @@ static void set_multicast_list(struct usbnet *usbdev)
 	char *mc_addrs = NULL;
 	int mc_count;
 
-	basefilter = filter = RNDIS_PACKET_TYPE_DIRECTED |
-			      RNDIS_PACKET_TYPE_BROADCAST;
+	basefilter = filter = cpu_to_le32(RNDIS_PACKET_TYPE_DIRECTED |
+					  RNDIS_PACKET_TYPE_BROADCAST);
 
 	if (usbdev->net->flags & IFF_PROMISC) {
-		filter |= RNDIS_PACKET_TYPE_PROMISCUOUS |
-			RNDIS_PACKET_TYPE_ALL_LOCAL;
+		filter |= cpu_to_le32(RNDIS_PACKET_TYPE_PROMISCUOUS |
+				      RNDIS_PACKET_TYPE_ALL_LOCAL);
 	} else if (usbdev->net->flags & IFF_ALLMULTI) {
-		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
+		filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
 	}
 
 	if (filter != basefilter)
@@ -1646,7 +1646,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 	netif_addr_lock_bh(usbdev->net);
 	mc_count = netdev_mc_count(usbdev->net);
 	if (mc_count > priv->multicast_size) {
-		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
+		filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
 	} else if (mc_count) {
 		int i = 0;
 
@@ -1673,9 +1673,9 @@ static void set_multicast_list(struct usbnet *usbdev)
 				    mc_count * ETH_ALEN);
 		kfree(mc_addrs);
 		if (ret == 0)
-			filter |= RNDIS_PACKET_TYPE_MULTICAST;
+			filter |= cpu_to_le32(RNDIS_PACKET_TYPE_MULTICAST);
 		else
-			filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
+			filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
 
 		netdev_dbg(usbdev->net, "OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d\n",
 			   mc_count, priv->multicast_size, ret);
@@ -3096,7 +3096,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 	struct rndis_indicate *msg = ind;
 
 	switch (msg->status) {
-	case RNDIS_STATUS_MEDIA_CONNECT:
+	case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
 		if (priv->current_command_oid == OID_802_11_ADD_KEY) {
 			/* OID_802_11_ADD_KEY causes sometimes extra
 			 * "media connect" indications which confuses driver
@@ -3116,7 +3116,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 		queue_work(priv->workqueue, &priv->work);
 		break;
 
-	case RNDIS_STATUS_MEDIA_DISCONNECT:
+	case cpu_to_le32(RNDIS_STATUS_MEDIA_DISCONNECT):
 		netdev_info(usbdev->net, "media disconnect\n");
 
 		/* queue work to avoid recursive calls into rndis_command */
@@ -3124,7 +3124,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 		queue_work(priv->workqueue, &priv->work);
 		break;
 
-	case RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION:
+	case cpu_to_le32(RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION):
 		rndis_wlan_media_specific_indication(usbdev, msg, buflen);
 		break;
 
@@ -3465,13 +3465,15 @@ static int rndis_wlan_bind(struct usbnet *usbdev, struct usb_interface *intf)
 	 */
 	usbdev->net->netdev_ops = &rndis_wlan_netdev_ops;
 
-	tmp = RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST;
-	retval = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &tmp,
-								sizeof(tmp));
+	tmp = cpu_to_le32(RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST);
+	retval = rndis_set_oid(usbdev,
+			       cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER),
+			       &tmp, sizeof(tmp));
 
 	len = sizeof(tmp);
-	retval = rndis_query_oid(usbdev, OID_802_3_MAXIMUM_LIST_SIZE, &tmp,
-								&len);
+	retval = rndis_query_oid(usbdev,
+				 cpu_to_le32(OID_802_3_MAXIMUM_LIST_SIZE),
+				 &tmp, &len);
 	priv->multicast_size = le32_to_cpu(tmp);
 	if (retval < 0 || priv->multicast_size < 0)
 		priv->multicast_size = 0;
diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_host.h
index 88fceb7..9a005b6 100644
--- a/include/linux/usb/rndis_host.h
+++ b/include/linux/usb/rndis_host.h
@@ -49,46 +49,46 @@ struct rndis_msg_hdr {
  */
 #define	RNDIS_CONTROL_TIMEOUT_MS	(5 * 1000)
 
-#define RNDIS_MSG_COMPLETION	cpu_to_le32(0x80000000)
+#define RNDIS_MSG_COMPLETION	0x80000000
 
 /* codes for "msg_type" field of rndis messages;
  * only the data channel uses packet messages (maybe batched);
  * everything else goes on the control channel.
  */
-#define RNDIS_MSG_PACKET	cpu_to_le32(0x00000001)	/* 1-N packets */
-#define RNDIS_MSG_INIT		cpu_to_le32(0x00000002)
+#define RNDIS_MSG_PACKET	0x00000001	/* 1-N packets */
+#define RNDIS_MSG_INIT		0x00000002
 #define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_HALT		cpu_to_le32(0x00000003)
-#define RNDIS_MSG_QUERY		cpu_to_le32(0x00000004)
+#define RNDIS_MSG_HALT		0x00000003
+#define RNDIS_MSG_QUERY		0x00000004
 #define RNDIS_MSG_QUERY_C	(RNDIS_MSG_QUERY|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_SET		cpu_to_le32(0x00000005)
+#define RNDIS_MSG_SET		0x00000005
 #define RNDIS_MSG_SET_C		(RNDIS_MSG_SET|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_RESET		cpu_to_le32(0x00000006)
+#define RNDIS_MSG_RESET		0x00000006
 #define RNDIS_MSG_RESET_C	(RNDIS_MSG_RESET|RNDIS_MSG_COMPLETION)
-#define RNDIS_MSG_INDICATE	cpu_to_le32(0x00000007)
-#define RNDIS_MSG_KEEPALIVE	cpu_to_le32(0x00000008)
+#define RNDIS_MSG_INDICATE	0x00000007
+#define RNDIS_MSG_KEEPALIVE	0x00000008
 #define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
 
 /* codes for "status" field of completion messages */
-#define	RNDIS_STATUS_SUCCESS			cpu_to_le32(0x00000000)
-#define	RNDIS_STATUS_FAILURE			cpu_to_le32(0xc0000001)
-#define	RNDIS_STATUS_INVALID_DATA		cpu_to_le32(0xc0010015)
-#define	RNDIS_STATUS_NOT_SUPPORTED		cpu_to_le32(0xc00000bb)
-#define	RNDIS_STATUS_MEDIA_CONNECT		cpu_to_le32(0x4001000b)
-#define	RNDIS_STATUS_MEDIA_DISCONNECT		cpu_to_le32(0x4001000c)
-#define	RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION	cpu_to_le32(0x40010012)
+#define	RNDIS_STATUS_SUCCESS			0x00000000
+#define	RNDIS_STATUS_FAILURE			0xc0000001
+#define	RNDIS_STATUS_INVALID_DATA		0xc0010015
+#define	RNDIS_STATUS_NOT_SUPPORTED		0xc00000bb
+#define	RNDIS_STATUS_MEDIA_CONNECT		0x4001000b
+#define	RNDIS_STATUS_MEDIA_DISCONNECT		0x4001000c
+#define	RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION	0x40010012
 
 /* codes for OID_GEN_PHYSICAL_MEDIUM */
-#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	cpu_to_le32(0x00000000)
-#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	cpu_to_le32(0x00000001)
-#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	cpu_to_le32(0x00000002)
-#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	cpu_to_le32(0x00000003)
-#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	cpu_to_le32(0x00000004)
-#define	RNDIS_PHYSICAL_MEDIUM_DSL		cpu_to_le32(0x00000005)
-#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	cpu_to_le32(0x00000006)
-#define	RNDIS_PHYSICAL_MEDIUM_1394		cpu_to_le32(0x00000007)
-#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	cpu_to_le32(0x00000008)
-#define	RNDIS_PHYSICAL_MEDIUM_MAX		cpu_to_le32(0x00000009)
+#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	0x00000000
+#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	0x00000001
+#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	0x00000002
+#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	0x00000003
+#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	0x00000004
+#define	RNDIS_PHYSICAL_MEDIUM_DSL		0x00000005
+#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	0x00000006
+#define	RNDIS_PHYSICAL_MEDIUM_1394		0x00000007
+#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	0x00000008
+#define	RNDIS_PHYSICAL_MEDIUM_MAX		0x00000009
 
 struct rndis_data_hdr {
 	__le32	msg_type;		/* RNDIS_MSG_PACKET */
@@ -226,24 +226,24 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
  * there are gobs more that may optionally be supported.  We'll avoid as much
  * of that mess as possible.
  */
-#define OID_802_3_PERMANENT_ADDRESS	cpu_to_le32(0x01010101)
-#define OID_GEN_MAXIMUM_FRAME_SIZE	cpu_to_le32(0x00010106)
-#define OID_GEN_CURRENT_PACKET_FILTER	cpu_to_le32(0x0001010e)
-#define OID_GEN_PHYSICAL_MEDIUM		cpu_to_le32(0x00010202)
+#define OID_802_3_PERMANENT_ADDRESS	0x01010101
+#define OID_GEN_MAXIMUM_FRAME_SIZE	0x00010106
+#define OID_GEN_CURRENT_PACKET_FILTER	0x0001010e
+#define OID_GEN_PHYSICAL_MEDIUM		0x00010202
 
 /* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
-#define RNDIS_PACKET_TYPE_DIRECTED		cpu_to_le32(0x00000001)
-#define RNDIS_PACKET_TYPE_MULTICAST		cpu_to_le32(0x00000002)
-#define RNDIS_PACKET_TYPE_ALL_MULTICAST		cpu_to_le32(0x00000004)
-#define RNDIS_PACKET_TYPE_BROADCAST		cpu_to_le32(0x00000008)
-#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	cpu_to_le32(0x00000010)
-#define RNDIS_PACKET_TYPE_PROMISCUOUS		cpu_to_le32(0x00000020)
-#define RNDIS_PACKET_TYPE_SMT			cpu_to_le32(0x00000040)
-#define RNDIS_PACKET_TYPE_ALL_LOCAL		cpu_to_le32(0x00000080)
-#define RNDIS_PACKET_TYPE_GROUP			cpu_to_le32(0x00001000)
-#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	cpu_to_le32(0x00002000)
-#define RNDIS_PACKET_TYPE_FUNCTIONAL		cpu_to_le32(0x00004000)
-#define RNDIS_PACKET_TYPE_MAC_FRAME		cpu_to_le32(0x00008000)
+#define RNDIS_PACKET_TYPE_DIRECTED		0x00000001
+#define RNDIS_PACKET_TYPE_MULTICAST		0x00000002
+#define RNDIS_PACKET_TYPE_ALL_MULTICAST		0x00000004
+#define RNDIS_PACKET_TYPE_BROADCAST		0x00000008
+#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	0x00000010
+#define RNDIS_PACKET_TYPE_PROMISCUOUS		0x00000020
+#define RNDIS_PACKET_TYPE_SMT			0x00000040
+#define RNDIS_PACKET_TYPE_ALL_LOCAL		0x00000080
+#define RNDIS_PACKET_TYPE_GROUP			0x00001000
+#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	0x00002000
+#define RNDIS_PACKET_TYPE_FUNCTIONAL		0x00004000
+#define RNDIS_PACKET_TYPE_MAC_FRAME		0x00008000
 
 /* default filter used with RNDIS devices */
 #define RNDIS_DEFAULT_FILTER ( \
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
