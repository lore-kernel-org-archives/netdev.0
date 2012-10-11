From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 05/11] usbnet: int51x1: apply introduced usb command APIs
Date: Thu, 11 Oct 2012 20:39:23 +0800
Message-ID: <1349959169-9432-6-git-send-email-ming.lei@canonical.com>
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
 drivers/net/usb/int51x1.c |   52 +++------------------------------------------
 1 file changed, 3 insertions(+), 49 deletions(-)

diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index 8de6417..ace9e74 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -116,23 +116,8 @@ static struct sk_buff *int51x1_tx_fixup(struct usbnet *dev,
 	return skb;
 }
 
-static void int51x1_async_cmd_callback(struct urb *urb)
-{
-	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;
-
-	if (status < 0)
-		dev_warn(&urb->dev->dev, "async callback failed with %d\n", status);
-
-	kfree(req);
-	usb_free_urb(urb);
-}
-
 static void int51x1_set_multicast(struct net_device *netdev)
 {
-	struct usb_ctrlrequest *req;
-	int status;
-	struct urb *urb;
 	struct usbnet *dev = netdev_priv(netdev);
 	u16 filter = PACKET_TYPE_DIRECTED | PACKET_TYPE_BROADCAST;
 
@@ -149,40 +134,9 @@ static void int51x1_set_multicast(struct net_device *netdev)
 		netdev_dbg(dev->net, "receive own packets only\n");
 	}
 
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_warn(dev->net, "Error allocating URB\n");
-		return;
-	}
-
-	req = kmalloc(sizeof(*req), GFP_ATOMIC);
-	if (!req) {
-		netdev_warn(dev->net, "Error allocating control msg\n");
-		goto out;
-	}
-
-	req->bRequestType = USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
-	req->bRequest = SET_ETHERNET_PACKET_FILTER;
-	req->wValue = cpu_to_le16(filter);
-	req->wIndex = 0;
-	req->wLength = 0;
-
-	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
-		(void *)req, NULL, 0,
-		int51x1_async_cmd_callback,
-		(void *)req);
