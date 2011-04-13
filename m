From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCHv2 net-next-2.6] rndis_host: Poll status before control
 channel where necessary
Date: Wed, 13 Apr 2011 05:55:23 +0100
Message-ID: <1302670523.5282.610.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mark Glassberg <vzeeaxwl-ubggFOsnOr3gwBMGfI3FeA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some RNDIS devices don't respond on the control channel until polled
on the status channel.  In particular, this was reported to be the
case for the 2Wire HomePortal 1000SW and for some Windows Mobile
devices.

This is roughly based on a patch by John Carr <john.carr-3P/l8hQepEe9FHfhHBbuYA@public.gmane.org>
which is currently applied by Mandriva.

Reported-by: Mark Glassberg <vzeeaxwl-ubggFOsnOr3gwBMGfI3FeA@public.gmane.org>
Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
---
The first version made this behaviour unconditional and had to be
reverted.  This version adds a quirk flag instead.

Ben.

 drivers/net/usb/rndis_host.c   |   39 ++++++++++++++++++++++++++++++++-------
 include/linux/usb/rndis_host.h |    2 ++
 2 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 5994a25..6d6c1da 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -104,8 +104,10 @@ static void rndis_msg_indicate(struct usbnet *dev, struct rndis_indicate *msg,
 int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 {
 	struct cdc_state	*info = (void *) &dev->data;
+	struct usb_cdc_notification notification;
 	int			master_ifnum;
 	int			retval;
+	int			partial;
 	unsigned		count;
 	__le32			rsp;
 	u32			xid = 0, msg_len, request_id;
@@ -133,13 +135,20 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	if (unlikely(retval < 0 || xid == 0))
 		return retval;
 
-	// FIXME Seems like some devices discard responses when
-	// we time out and cancel our "get response" requests...
-	// so, this is fragile.  Probably need to poll for status.
+	/* Some devices don't respond on the control channel until
+	 * polled on the status channel, so do that first. */
+	if (dev->driver_info->data & RNDIS_DRIVER_DATA_POLL_STATUS) {
+		retval = usb_interrupt_msg(
+			dev->udev,
+			usb_rcvintpipe(dev->udev,
+				       dev->status->desc.bEndpointAddress),
+			&notification, sizeof(notification), &partial,
+			RNDIS_CONTROL_TIMEOUT_MS);
+		if (unlikely(retval < 0))
+			return retval;
+	}
 
-	/* ignore status endpoint, just poll the control channel;
-	 * the request probably completed immediately
-	 */
+	/* Poll the control channel; the request probably completed immediately */
 	rsp = buf->msg_type | RNDIS_MSG_COMPLETION;
 	for (count = 0; count < 10; count++) {
 		memset(buf, 0, CONTROL_BUFFER_SIZE);
@@ -581,17 +590,33 @@ static const struct driver_info	rndis_info = {
 	.tx_fixup =	rndis_tx_fixup,
 };
 
+static const struct driver_info	rndis_poll_status_info = {
+	.description =	"RNDIS device (poll status before control)",
+	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
+	.data =		RNDIS_DRIVER_DATA_POLL_STATUS,
+	.bind =		rndis_bind,
+	.unbind =	rndis_unbind,
+	.status =	rndis_status,
+	.rx_fixup =	rndis_rx_fixup,
+	.tx_fixup =	rndis_tx_fixup,
+};
+
 /*-------------------------------------------------------------------------*/
 
 static const struct usb_device_id	products [] = {
 {
+	/* 2Wire HomePortal 1000SW */
+	USB_DEVICE_AND_INTERFACE_INFO(0x1630, 0x0042,
+				      USB_CLASS_COMM, 2 /* ACM */, 0x0ff),
+	.driver_info = (unsigned long) &rndis_poll_status_info,
+}, {
 	/* RNDIS is MSFT's un-official variant of CDC ACM */
 	USB_INTERFACE_INFO(USB_CLASS_COMM, 2 /* ACM */, 0x0ff),
 	.driver_info = (unsigned long) &rndis_info,
 }, {
 	/* "ActiveSync" is an undocumented variant of RNDIS, used in WM5 */
 	USB_INTERFACE_INFO(USB_CLASS_MISC, 1, 1),
-	.driver_info = (unsigned long) &rndis_info,
+	.driver_info = (unsigned long) &rndis_poll_status_info,
 }, {
 	/* RNDIS for tethering */
 	USB_INTERFACE_INFO(USB_CLASS_WIRELESS_CONTROLLER, 1, 3),
diff --git a/include/linux/usb/rndis_host.h b/include/linux/usb/rndis_host.h
index 05ef528..88fceb7 100644
--- a/include/linux/usb/rndis_host.h
+++ b/include/linux/usb/rndis_host.h
@@ -256,6 +256,8 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
 #define FLAG_RNDIS_PHYM_NOT_WIRELESS	0x0001
 #define FLAG_RNDIS_PHYM_WIRELESS	0x0002
 
+/* Flags for driver_info::data */
+#define RNDIS_DRIVER_DATA_POLL_STATUS	1	/* poll status before control */
 
 extern void rndis_status(struct usbnet *dev, struct urb *urb);
 extern int
-- 
1.7.4.1


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
