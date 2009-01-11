From: Alexey Klimov <klimov.linux@gmail.com>
Subject: [patch review 1/3] net/usb: catc.c - place dev_err instead of err()
Date: Sun, 11 Jan 2009 19:16:31 +0300
Message-ID: <1231690591.2050.103.camel@tux.localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: dbrownell@users.sourceforge.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:28809 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177AbZAKQQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 11:16:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

there are 3 patches for usb-network drivers that use err macroses.

Probably, few mistakes exist in this 3 patches and they should be
reformatted. May be they should be joined in one patch. Please, review.

---
Remove err-messages and place dev_err there.

Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>

--
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index cb7acbb..e23fa80 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -339,14 +339,14 @@ static void catc_irq_done(struct urb *urb)
 		} else {
 			catc->rx_urb->dev = catc->usbdev;
 			if ((res = usb_submit_urb(catc->rx_urb, GFP_ATOMIC)) < 0) {
-				err("submit(rx_urb) status %d", res);
+				dev_err(&urb->dev->dev, "submit(rx_urb) status %d\n", res);
 			}
 		} 
 	}
 resubmit:
 	res = usb_submit_urb (urb, GFP_ATOMIC);
 	if (res)
-		err ("can't resubmit intr, %s-%s, status %d",
+		dev_err(&urb->dev->dev,"can't resubmit intr, %s-%s, status %d\n",
 				catc->usbdev->bus->bus_name,
 				catc->usbdev->devpath, res);
 }
@@ -367,7 +367,7 @@ static int catc_tx_run(struct catc *catc)
 	catc->tx_urb->dev = catc->usbdev;
 
 	if ((status = usb_submit_urb(catc->tx_urb, GFP_ATOMIC)) < 0)
-		err("submit(tx_urb), status %d", status);
+		dev_err(&catc->usbdev->dev, "submit(tx_urb), status %d\n", status);
 
 	catc->tx_idx = !catc->tx_idx;
 	catc->tx_ptr = 0;
@@ -496,7 +496,7 @@ static void catc_ctrl_run(struct catc *catc)
 		memcpy(catc->ctrl_buf, q->buf, q->len);
 
 	if ((status = usb_submit_urb(catc->ctrl_urb, GFP_KERNEL)))
-		err("submit(ctrl_urb) status %d", status);
+		dev_err(&usbdev->dev, "submit(ctrl_urb) status %d\n", status);
 }
 
 static void catc_ctrl_done(struct urb *urb)
@@ -555,7 +555,7 @@ static int catc_ctrl_async(struct catc *catc, u8 dir, u8 request, u16 value,
 	catc->ctrl_head = (catc->ctrl_head + 1) & (CTRL_QUEUE - 1);
 
 	if (catc->ctrl_head == catc->ctrl_tail) {
-		err("ctrl queue full");
+		dev_err(&catc->usbdev->dev, "ctrl queue full\n");
 		catc->ctrl_tail = (catc->ctrl_tail + 1) & (CTRL_QUEUE - 1);
 		retval = -1;
 	}
@@ -721,7 +721,7 @@ static int catc_open(struct net_device *netdev)
 
 	catc->irq_urb->dev = catc->usbdev;
 	if ((status = usb_submit_urb(catc->irq_urb, GFP_KERNEL)) < 0) {
-		err("submit(irq_urb) status %d", status);
+		dev_err(&netdev->dev, "submit(irq_urb) status %d\n", status);
 		return -1;
 	}
 
@@ -764,7 +764,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
-                err("Can't set altsetting 1.");
+                dev_err(&intf->dev, "Can't set altsetting 1.\n");
 		return -EIO;
 	}
 
@@ -799,7 +799,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	catc->irq_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if ((!catc->ctrl_urb) || (!catc->tx_urb) || 
 	    (!catc->rx_urb) || (!catc->irq_urb)) {
-		err("No free urbs available.");
+		dev_err(&intf->dev, "No free urbs available.\n");
 		usb_free_urb(catc->ctrl_urb);
 		usb_free_urb(catc->tx_urb);
 		usb_free_urb(catc->rx_urb);

-- 
Best regards, Klimov Alexey

