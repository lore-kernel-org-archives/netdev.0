From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 05/12] usbnet: int51x1: apply introduced usb command APIs
Date: Tue,  2 Oct 2012 14:51:16 +0800
Message-ID: <1349160684-6627-6-git-send-email-ming.lei@canonical.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61045 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234Ab2JBGwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 02:52:08 -0400
In-Reply-To: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ming Lei <ming.lei@canonical.com>
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
-
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status < 0) {
-		netdev_warn(dev->net, "Error submitting control msg, sts=%d\n",
-			    status);
-		goto out1;
-	}
-	return;
-out1:
-	kfree(req);
-out:
-	usb_free_urb(urb);
+	usbnet_write_cmd_async(dev, SET_ETHERNET_PACKET_FILTER,
+			       USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE,
+			       filter, 0, NULL, 0);
 }
 
 static const struct net_device_ops int51x1_netdev_ops = {
-- 
1.7.9.5
