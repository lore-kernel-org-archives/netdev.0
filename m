From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/4] isdn/gigaset: use USB API function usb_endpoint_num()
Date: Fri, 3 Oct 2014 17:03:32 +0200
Message-ID: <7e4c1c111e523966c0202aee8a73103ef3a1735f.1412348612.git.tilman@imap.cc>
References: <cover.1412348612.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:41729 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134AbaJCQ2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:28:21 -0400
In-Reply-To: <cover.1412348612.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use function usb_endpoint_num() for the bulk endpoint and store
the endpoint number in the cardstate structure instead of the raw
endpoint address value.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 8bda5c8..82e91ba 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -135,7 +135,7 @@ struct usb_cardstate {
 	/* Output buffer */
 	unsigned char		*bulk_out_buffer;
 	int			bulk_out_size;
-	__u8			bulk_out_endpointAddr;
+	int			bulk_out_epnum;
 	struct urb		*bulk_out_urb;
 
 	/* Input buffer */
@@ -465,7 +465,7 @@ static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
 
 			usb_fill_bulk_urb(ucs->bulk_out_urb, ucs->udev,
 					  usb_sndbulkpipe(ucs->udev,
-							  ucs->bulk_out_endpointAddr & 0x0f),
+							  ucs->bulk_out_epnum),
 					  cb->buf + cb->offset, count,
 					  gigaset_write_bulk_callback, cs);
 
@@ -627,8 +627,7 @@ static int write_modem(struct cardstate *cs)
 	if (cs->connected) {
 		usb_fill_bulk_urb(ucs->bulk_out_urb, ucs->udev,
 				  usb_sndbulkpipe(ucs->udev,
-						  ucs->bulk_out_endpointAddr &
-						  0x0f),
+						  ucs->bulk_out_epnum),
 				  ucs->bulk_out_buffer, count,
 				  gigaset_write_bulk_callback, cs);
 		ret = usb_submit_urb(ucs->bulk_out_urb, GFP_ATOMIC);
@@ -713,7 +712,7 @@ static int gigaset_probe(struct usb_interface *interface,
 
 	buffer_size = le16_to_cpu(endpoint->wMaxPacketSize);
 	ucs->bulk_out_size = buffer_size;
-	ucs->bulk_out_endpointAddr = endpoint->bEndpointAddress;
+	ucs->bulk_out_epnum = usb_endpoint_num(endpoint);
 	ucs->bulk_out_buffer = kmalloc(buffer_size, GFP_KERNEL);
 	if (!ucs->bulk_out_buffer) {
 		dev_err(cs->dev, "Couldn't allocate bulk_out_buffer\n");
@@ -748,8 +747,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	}
 	/* Fill the interrupt urb and send it to the core */
 	usb_fill_int_urb(ucs->read_urb, udev,
-			 usb_rcvintpipe(udev,
-					usb_endpoint_num(endpoint)),
+			 usb_rcvintpipe(udev, usb_endpoint_num(endpoint)),
 			 ucs->rcvbuf, buffer_size,
 			 gigaset_read_int_callback,
 			 cs, endpoint->bInterval);
-- 
1.9.2.459.g68773ac
