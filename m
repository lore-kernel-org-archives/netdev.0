From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: kvaser_usb: fix usb endpoints detection
Date: Thu, 31 Oct 2013 20:24:50 +0100
Message-ID: <1383247490-26984-3-git-send-email-mkl@pengutronix.de>
References: <1383247490-26984-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Olivier Sobrie <olivier@sobrie.be>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59158 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428Ab3JaTY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 15:24:58 -0400
In-Reply-To: <1383247490-26984-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olivier Sobrie <olivier@sobrie.be>

Some devices, like the Kvaser Memorator Professional, have several bulk in
endpoints. Only the first one found must be used by the driver. The same holds
for the bulk out endpoint. The official Kvaser driver (leaf) was used as
reference for this patch.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 3b95465..4b2d5ed 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1544,9 +1544,9 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 	return 0;
 }
 
-static void kvaser_usb_get_endpoints(const struct usb_interface *intf,
-				     struct usb_endpoint_descriptor **in,
-				     struct usb_endpoint_descriptor **out)
+static int kvaser_usb_get_endpoints(const struct usb_interface *intf,
+				    struct usb_endpoint_descriptor **in,
+				    struct usb_endpoint_descriptor **out)
 {
 	const struct usb_host_interface *iface_desc;
 	struct usb_endpoint_descriptor *endpoint;
@@ -1557,12 +1557,18 @@ static void kvaser_usb_get_endpoints(const struct usb_interface *intf,
 	for (i = 0; i < iface_desc->desc.bNumEndpoints; ++i) {
 		endpoint = &iface_desc->endpoint[i].desc;
 
-		if (usb_endpoint_is_bulk_in(endpoint))
+		if (!*in && usb_endpoint_is_bulk_in(endpoint))
 			*in = endpoint;
 
-		if (usb_endpoint_is_bulk_out(endpoint))
+		if (!*out && usb_endpoint_is_bulk_out(endpoint))
 			*out = endpoint;
+
+		/* use first bulk endpoint for in and out */
+		if (*in && *out)
+			return 0;
 	}
+
+	return -ENODEV;
 }
 
 static int kvaser_usb_probe(struct usb_interface *intf,
@@ -1576,8 +1582,8 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 	if (!dev)
 		return -ENOMEM;
 
-	kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out);
-	if (!dev->bulk_in || !dev->bulk_out) {
+	err = kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out);
+	if (err) {
 		dev_err(&intf->dev, "Cannot get usb endpoint(s)");
 		return err;
 	}
-- 
1.8.4.rc3
