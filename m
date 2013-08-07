From: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH 1/2] net/usb: catc: allocate URB setup_packet as separate
 buffer
Date: Wed, 07 Aug 2013 16:26:29 +0300
Message-ID: <20130807132629.14001.2370.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

URB setup packet must not be allocated as part of larger structure
because DMA coherence issues.

Patch changes catc to allocate ctrl_dr member as separate buffer.

Patch is only compile tested.

Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
---
 drivers/net/usb/catc.c |   40 +++++++++++++++++++++++++---------------
 1 file changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 8d5cac2..a7d3c1b 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -173,7 +173,7 @@ struct catc {
 	u8 rx_buf[RX_MAX_BURST * (PKT_SZ + 2)];
 	u8 irq_buf[2];
 	u8 ctrl_buf[64];
-	struct usb_ctrlrequest ctrl_dr;
+	struct usb_ctrlrequest *ctrl_dr;
 
 	struct timer_list timer;
 	u8 stats_buf[8];
@@ -485,7 +485,7 @@ static void catc_ctrl_run(struct catc *catc)
 	struct ctrl_queue *q = catc->ctrl_queue + catc->ctrl_tail;
 	struct usb_device *usbdev = catc->usbdev;
 	struct urb *urb = catc->ctrl_urb;
-	struct usb_ctrlrequest *dr = &catc->ctrl_dr;
+	struct usb_ctrlrequest *dr = catc->ctrl_dr;
 	int status;
 
 	dr->bRequest = q->request;
@@ -779,7 +779,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	struct net_device *netdev;
 	struct catc *catc;
 	u8 broadcast[6];
-	int i, pktsz;
+	int i, pktsz, err;
 
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
@@ -793,6 +793,12 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 
 	catc = netdev_priv(netdev);
 
+	catc->ctrl_dr = kzalloc(sizeof(*catc->ctrl_dr), GFP_KERNEL);
+	if (!catc->ctrl_dr) {
+		err = -ENOMEM;
+		goto err_free_dev;
+	}
+
 	netdev->netdev_ops = &catc_netdev_ops;
 	netdev->watchdog_timeo = TX_TIMEOUT;
 	SET_ETHTOOL_OPS(netdev, &ops);
@@ -814,12 +820,8 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	if ((!catc->ctrl_urb) || (!catc->tx_urb) || 
 	    (!catc->rx_urb) || (!catc->irq_urb)) {
 		dev_err(&intf->dev, "No free urbs available.\n");
-		usb_free_urb(catc->ctrl_urb);
-		usb_free_urb(catc->tx_urb);
-		usb_free_urb(catc->rx_urb);
-		usb_free_urb(catc->irq_urb);
-		free_netdev(netdev);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_free;
 	}
 
 	/* The F5U011 has the same vendor/product as the netmate but a device version of 0x130 */
@@ -918,14 +920,21 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
 		usb_set_intfdata(intf, NULL);
-		usb_free_urb(catc->ctrl_urb);
-		usb_free_urb(catc->tx_urb);
-		usb_free_urb(catc->rx_urb);
-		usb_free_urb(catc->irq_urb);
-		free_netdev(netdev);
-		return -EIO;
+		err = -EIO;
+		goto err_free;
 	}
 	return 0;
+
+err_free:
+	usb_free_urb(catc->ctrl_urb);
+	usb_free_urb(catc->tx_urb);
+	usb_free_urb(catc->rx_urb);
+	usb_free_urb(catc->irq_urb);
+	kfree(catc->ctrl_dr);
+err_free_dev:
+	free_netdev(netdev);
+
+	return err;
 }
 
 static void catc_disconnect(struct usb_interface *intf)
@@ -939,6 +948,7 @@ static void catc_disconnect(struct usb_interface *intf)
 		usb_free_urb(catc->tx_urb);
 		usb_free_urb(catc->rx_urb);
 		usb_free_urb(catc->irq_urb);
+		kfree(catc->ctrl_dr);
 		free_netdev(catc->netdev);
 	}
 }

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
