From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/13] drivers/net/usb: use USB API functions rather than
 constants
Date: Mon, 29 Dec 2008 11:21:07 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812291120450.9555@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: jgarzik@pobox.com, netdev@vger.kernel.org, gregkh@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755958AbYL2KVn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

This set of patches introduces calls to the following set of functions:

usb_endpoint_dir_in(epd)
usb_endpoint_dir_out(epd)
usb_endpoint_is_bulk_in(epd)
usb_endpoint_is_bulk_out(epd)
usb_endpoint_is_int_in(epd)
usb_endpoint_is_int_out(epd)
usb_endpoint_num(epd)
usb_endpoint_type(epd)
usb_endpoint_xfer_bulk(epd)
usb_endpoint_xfer_control(epd)
usb_endpoint_xfer_int(epd)
usb_endpoint_xfer_isoc(epd)

In some cases, introducing one of these functions is not possible, and it
just replaces an explicit integer value by one of the following constants:

USB_ENDPOINT_XFER_BULK
USB_ENDPOINT_XFER_CONTROL
USB_ENDPOINT_XFER_INT
USB_ENDPOINT_XFER_ISOC

In drivers/net/wireless/zd1211rw/zd_usb.c the code:

(endpoint->bEndpointAddress & USB_TYPE_MASK) == USB_DIR_OUT

is suspicious.  If it is intended to use USB_ENDPOINT_DIR_MASK rather than
USB_TYPE_MASK, then the whole conditional test could be converted to a call
to usb_endpoint_is_bulk_in.

An extract of the semantic patch that makes these changes is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r1@ struct usb_endpoint_descriptor *epd; @@

- ((epd->bmAttributes & \(USB_ENDPOINT_XFERTYPE_MASK\|3\)) ==
- \(USB_ENDPOINT_XFER_CONTROL\|0\))
+ usb_endpoint_xfer_control(epd)

@r5@ struct usb_endpoint_descriptor *epd; @@

- ((epd->bEndpointAddress & \(USB_ENDPOINT_DIR_MASK\|0x80\)) ==
-  \(USB_DIR_IN\|0x80\))
+ usb_endpoint_dir_in(epd)

@inc@
@@

#include <linux/usb.h>

@depends on !inc && (r1||r5)@
@@

+ #include <linux/usb.h>
  #include <linux/usb/...>
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/usb/hso.c                  |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 2d41a10..6c30c4f 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -3177,7 +3177,7 @@ static struct usb_endpoint_descriptor *hso_get_ep(struct usb_interface *intf,
 	for (i = 0; i < iface->desc.bNumEndpoints; i++) {
 		endp = &iface->endpoint[i].desc;
 		if (((endp->bEndpointAddress & USB_ENDPOINT_DIR_MASK) == dir) &&
-		    ((endp->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == type))
+		    (usb_endpoint_type(endp) == type))
 			return endp;
 	}
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 04c1396..b5db57d 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -1065,8 +1065,7 @@ static int eject_installer(struct usb_interface *intf)
 	/* Find bulk out endpoint */
 	endpoint = &iface_desc->endpoint[1].desc;
 	if ((endpoint->bEndpointAddress & USB_TYPE_MASK) == USB_DIR_OUT &&
-	    (endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) ==
-	    USB_ENDPOINT_XFER_BULK) {
+	    usb_endpoint_xfer_bulk(endpoint)) {
 		bulk_out_ep = endpoint->bEndpointAddress;
 	} else {
 		dev_err(&udev->dev,
