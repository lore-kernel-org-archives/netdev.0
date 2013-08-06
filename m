From: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH] rndis_host: do not use stack as URB transfer_buffer
Date: Tue, 06 Aug 2013 14:42:08 +0300
Message-ID: <20130806114208.20561.43444.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Patch fixes rndis_host not to use stack as URB transfer_buffer. URB buffers need
to be DMA-able, which stack is not.

Patch is only compile tested.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
---
 drivers/net/usb/rndis_host.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index cc49aac..2f232c3 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -105,7 +105,6 @@ static void rndis_msg_indicate(struct usbnet *dev, struct rndis_indicate *msg,
 int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 {
 	struct cdc_state	*info = (void *) &dev->data;
-	struct usb_cdc_notification notification;
 	int			master_ifnum;
 	int			retval;
 	int			partial;
@@ -140,12 +139,17 @@ int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf, int buflen)
 	/* Some devices don't respond on the control channel until
 	 * polled on the status channel, so do that first. */
 	if (dev->driver_info->data & RNDIS_DRIVER_DATA_POLL_STATUS) {
+		struct usb_cdc_notification *notification;
+		notification = kmalloc(sizeof(*notification), GFP_KERNEL);
+		if (!notification)
+			return -ENOMEM;
 		retval = usb_interrupt_msg(
 			dev->udev,
 			usb_rcvintpipe(dev->udev,
 				       dev->status->desc.bEndpointAddress),
-			&notification, sizeof(notification), &partial,
+			notification, sizeof(*notification), &partial,
 			RNDIS_CONTROL_TIMEOUT_MS);
+		kfree(notification);
 		if (unlikely(retval < 0))
 			return retval;
 	}

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
