From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/17 v5] rndis_host: cleanup: byteswap data from device instead of RNDIS_* defines
Date: Sat, 12 May 2012 10:17:34 +0200
Message-ID: <1336810654-5650-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

All other values from device provided buffer are byteswapped, so it seems
more logical to do same for these.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/usb/rndis_host.c |   53 ++++++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index dd342dc..74315fd 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -77,16 +77,17 @@ static void rndis_msg_indicate(struct usbnet *dev, struct rndis_indicate *msg,
 	if (dev->driver_info->indication) {
 		dev->driver_info->indication(dev, msg, buflen);
 	} else {
-		switch (msg->status) {
-		case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
+		u32 status = le32_to_cpu(msg->status);
+
+		switch (status) {
+		case RNDIS_STATUS_MEDIA_CONNECT:
 			dev_info(udev, "rndis media connect\n");
 			break;
-		case cpu_to_le32(RNDIS_STATUS_MEDIA_DISCONNECT):
+		case RNDIS_STATUS_MEDIA_DISCONNECT:
 			dev_info(udev, "rndis media disconnect\n");
 			break;
 		default:
-			dev_info(udev, "rndis indication: 0x%08x\n",
-					le32_to_cpu(msg->status));
+			dev_info(udev, "rndis indication: 0x%08x\n", status);
 		}
 	}
 }
@@ -109,16 +110,17 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	int			retval;
 	int			partial;
 	unsigned		count;
-	__le32			rsp;
-	u32			xid = 0, msg_len, request_id;
+	u32			xid = 0, msg_len, request_id, msg_type, rsp,
+				status;
 
 	/* REVISIT when this gets called from contexts other than probe() or
 	 * disconnect(): either serialize, or dispatch responses on xid
 	 */
 
+	msg_type = le32_to_cpu(buf->msg_type);
+
 	/* Issue the request; xid is unique, don't bother byteswapping it */
-	if (likely(buf->msg_type != cpu_to_le32(RNDIS_MSG_HALT) &&
-		   buf->msg_type != cpu_to_le32(RNDIS_MSG_RESET))) {
+	if (likely(msg_type != RNDIS_MSG_HALT && msg_type != RNDIS_MSG_RESET)) {
 		xid = dev->xid++;
 		if (!xid)
 			xid = dev->xid++;
@@ -149,7 +151,7 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	}
 
 	/* Poll the control channel; the request probably completed immediately */
-	rsp = buf->msg_type | cpu_to_le32(RNDIS_MSG_COMPLETION);
+	rsp = le32_to_cpu(buf->msg_type) | RNDIS_MSG_COMPLETION;
 	for (count = 0; count < 10; count++) {
 		memset(buf, 0, CONTROL_BUFFER_SIZE);
 		retval = usb_control_msg(dev->udev,
@@ -160,30 +162,31 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 			buf, buflen,
 			RNDIS_CONTROL_TIMEOUT_MS);
 		if (likely(retval >= 8)) {
+			msg_type = le32_to_cpu(buf->msg_type);
 			msg_len = le32_to_cpu(buf->msg_len);
+			status = le32_to_cpu(buf->status);
 			request_id = (__force u32) buf->request_id;
-			if (likely(buf->msg_type == rsp)) {
+			if (likely(msg_type == rsp)) {
 				if (likely(request_id == xid)) {
-					if (unlikely(rsp ==
-					    cpu_to_le32(RNDIS_MSG_RESET_C)))
+					if (unlikely(rsp == RNDIS_MSG_RESET_C))
 						return 0;
-					if (likely(cpu_to_le32(RNDIS_STATUS_SUCCESS)
-							== buf->status))
+					if (likely(RNDIS_STATUS_SUCCESS ==
+							status))
 						return 0;
 					dev_dbg(&info->control->dev,
 						"rndis reply status %08x\n",
-						le32_to_cpu(buf->status));
+						status);
 					return -EL3RST;
 				}
 				dev_dbg(&info->control->dev,
 					"rndis reply id %d expected %d\n",
 					request_id, xid);
 				/* then likely retry */
-			} else switch (buf->msg_type) {
-			case cpu_to_le32(RNDIS_MSG_INDICATE): /* fault/event */
+			} else switch (msg_type) {
+			case RNDIS_MSG_INDICATE: /* fault/event */
 				rndis_msg_indicate(dev, (void *)buf, buflen);
 				break;
-			case cpu_to_le32(RNDIS_MSG_KEEPALIVE): { /* ping */
+			case RNDIS_MSG_KEEPALIVE: { /* ping */
 				struct rndis_keepalive_c *msg = (void *)buf;
 
 				msg->msg_type = cpu_to_le32(RNDIS_MSG_KEEPALIVE_C);
@@ -404,14 +407,14 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		phym = &phym_unspec;
 	}
 	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
-	    *phym != cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN)) {
+	    le32_to_cpup(phym) != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
 		netif_dbg(dev, probe, dev->net,
 			  "driver requires wireless physical medium, but device is not\n");
 		retval = -ENODEV;
 		goto halt_fail_and_release;
 	}
 	if ((flags & FLAG_RNDIS_PHYM_NOT_WIRELESS) &&
-	    *phym == cpu_to_le32(RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN)) {
+	    le32_to_cpup(phym) == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
 		netif_dbg(dev, probe, dev->net,
 			  "driver requires non-wireless physical medium, but device is wireless.\n");
 		retval = -ENODEV;
@@ -496,16 +499,16 @@ int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	while (likely(skb->len)) {
 		struct rndis_data_hdr	*hdr = (void *)skb->data;
 		struct sk_buff		*skb2;
-		u32			msg_len, data_offset, data_len;
+		u32			msg_type, msg_len, data_offset, data_len;
 
+		msg_type = le32_to_cpu(hdr->msg_type);
 		msg_len = le32_to_cpu(hdr->msg_len);
 		data_offset = le32_to_cpu(hdr->data_offset);
 		data_len = le32_to_cpu(hdr->data_len);
 
 		/* don't choke if we see oob, per-packet data, etc */
-		if (unlikely(hdr->msg_type != cpu_to_le32(RNDIS_MSG_PACKET) ||
-			     skb->len < msg_len ||
-			     (data_offset + data_len + 8) > msg_len)) {
+		if (unlikely(msg_type != RNDIS_MSG_PACKET || skb->len < msg_len
+				|| (data_offset + data_len + 8) > msg_len)) {
 			dev->net->stats.rx_frame_errors++;
 			netdev_dbg(dev->net, "bad rndis message %d/%d/%d/%d, len %d\n",
 				   le32_to_cpu(hdr->msg_type),
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
