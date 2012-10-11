From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 07/11] usbnet: net1080: apply introduced usb command APIs
Date: Thu, 11 Oct 2012 20:39:25 +0800
Message-ID: <1349959169-9432-8-git-send-email-ming.lei@canonical.com>
References: <1349959169-9432-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1349959169-9432-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/net1080.c |  110 +++++++++++++--------------------------------
 1 file changed, 30 insertions(+), 80 deletions(-)

diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index c062a3e..93e0716 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -109,13 +109,11 @@ struct nc_trailer {
 static int
 nc_vendor_read(struct usbnet *dev, u8 req, u8 regnum, u16 *retval_ptr)
 {
-	int status = usb_control_msg(dev->udev,
-		usb_rcvctrlpipe(dev->udev, 0),
-		req,
-		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		0, regnum,
-		retval_ptr, sizeof *retval_ptr,
-		USB_CTRL_GET_TIMEOUT);
+	int status = usbnet_read_cmd(dev, req,
+				     USB_DIR_IN | USB_TYPE_VENDOR |
+				     USB_RECIP_DEVICE,
+				     0, regnum, retval_ptr,
+				     sizeof *retval_ptr);
 	if (status > 0)
 		status = 0;
 	if (!status)
@@ -133,13 +131,9 @@ nc_register_read(struct usbnet *dev, u8 regnum, u16 *retval_ptr)
 static void
 nc_vendor_write(struct usbnet *dev, u8 req, u8 regnum, u16 value)
 {
-	usb_control_msg(dev->udev,
-		usb_sndctrlpipe(dev->udev, 0),
-		req,
-		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		value, regnum,
-		NULL, 0,			// data is in setup packet
-		USB_CTRL_SET_TIMEOUT);
+	usbnet_write_cmd(dev, req,
+			 USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			 value, regnum, NULL, 0);
 }
 
 static inline void
@@ -288,37 +282,34 @@ static inline void nc_dump_ttl(struct usbnet *dev, u16 ttl)
 static int net1080_reset(struct usbnet *dev)
 {
 	u16		usbctl, status, ttl;
-	u16		*vp = kmalloc(sizeof (u16), GFP_KERNEL);
+	u16		vp;
 	int		retval;
 
-	if (!vp)
-		return -ENOMEM;
-
 	// nc_dump_registers(dev);
 
-	if ((retval = nc_register_read(dev, REG_STATUS, vp)) < 0) {
+	if ((retval = nc_register_read(dev, REG_STATUS, &vp)) < 0) {
 		netdev_dbg(dev->net, "can't read %s-%s status: %d\n",
 			   dev->udev->bus->bus_name, dev->udev->devpath, retval);
 		goto done;
 	}
-	status = *vp;
+	status = vp;
 	nc_dump_status(dev, status);
 
-	if ((retval = nc_register_read(dev, REG_USBCTL, vp)) < 0) {
+	if ((retval = nc_register_read(dev, REG_USBCTL, &vp)) < 0) {
 		netdev_dbg(dev->net, "can't read USBCTL, %d\n", retval);
 		goto done;
 	}
-	usbctl = *vp;
+	usbctl = vp;
 	nc_dump_usbctl(dev, usbctl);
 
 	nc_register_write(dev, REG_USBCTL,
 			USBCTL_FLUSH_THIS | USBCTL_FLUSH_OTHER);
 
-	if ((retval = nc_register_read(dev, REG_TTL, vp)) < 0) {
+	if ((retval = nc_register_read(dev, REG_TTL, &vp)) < 0) {
 		netdev_dbg(dev->net, "can't read TTL, %d\n", retval);
 		goto done;
 	}
-	ttl = *vp;
+	ttl = vp;
 	// nc_dump_ttl(dev, ttl);
 
 	nc_register_write(dev, REG_TTL,
@@ -331,7 +322,6 @@ static int net1080_reset(struct usbnet *dev)
 	retval = 0;
 
 done:
-	kfree(vp);
 	return retval;
 }
 
@@ -339,13 +329,10 @@ static int net1080_check_connect(struct usbnet *dev)
 {
 	int			retval;
 	u16			status;
-	u16			*vp = kmalloc(sizeof (u16), GFP_KERNEL);
+	u16			vp;
 
-	if (!vp)
-		return -ENOMEM;
-	retval = nc_register_read(dev, REG_STATUS, vp);
-	status = *vp;
-	kfree(vp);
+	retval = nc_register_read(dev, REG_STATUS, &vp);
+	status = vp;
 	if (retval != 0) {
 		netdev_dbg(dev->net, "net1080_check_conn read - %d\n", retval);
 		return retval;
@@ -355,59 +342,22 @@ static int net1080_check_connect(struct usbnet *dev)
 	return 0;
 }
 
-static void nc_flush_complete(struct urb *urb)
-{
-	kfree(urb->context);
-	usb_free_urb(urb);
-}
-
 static void nc_ensure_sync(struct usbnet *dev)
 {
-	dev->frame_errors++;
-	if (dev->frame_errors > 5) {
-		struct urb		*urb;
-		struct usb_ctrlrequest	*req;
-		int			status;
-
-		/* Send a flush */
-		urb = usb_alloc_urb(0, GFP_ATOMIC);
-		if (!urb)
-			return;
-
-		req = kmalloc(sizeof *req, GFP_ATOMIC);
-		if (!req) {
-			usb_free_urb(urb);
-			return;
-		}
+	if (++dev->frame_errors <= 5)
+		return;
 
-		req->bRequestType = USB_DIR_OUT
-			| USB_TYPE_VENDOR
-			| USB_RECIP_DEVICE;
-		req->bRequest = REQUEST_REGISTER;
-		req->wValue = cpu_to_le16(USBCTL_FLUSH_THIS
-				| USBCTL_FLUSH_OTHER);
-		req->wIndex = cpu_to_le16(REG_USBCTL);
-		req->wLength = cpu_to_le16(0);
-
-		/* queue an async control request, we don't need
-		 * to do anything when it finishes except clean up.
-		 */
-		usb_fill_control_urb(urb, dev->udev,
-			usb_sndctrlpipe(dev->udev, 0),
-			(unsigned char *) req,
-			NULL, 0,
-			nc_flush_complete, req);
-		status = usb_submit_urb(urb, GFP_ATOMIC);
-		if (status) {
-			kfree(req);
-			usb_free_urb(urb);
-			return;
-		}
+	if (usbnet_write_cmd_async(dev, REQUEST_REGISTER,
+					USB_DIR_OUT | USB_TYPE_VENDOR |
+					USB_RECIP_DEVICE,
+					USBCTL_FLUSH_THIS |
+					USBCTL_FLUSH_OTHER,
+					REG_USBCTL, NULL, 0))
+		return;
 
-		netif_dbg(dev, rx_err, dev->net,
-			  "flush net1080; too many framing errors\n");
-		dev->frame_errors = 0;
-	}
+	netif_dbg(dev, rx_err, dev->net,
+		  "flush net1080; too many framing errors\n");
+	dev->frame_errors = 0;
 }
 
 static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
