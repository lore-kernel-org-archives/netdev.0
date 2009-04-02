From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH 2/2] hso: fix for the 'invalid frame length' messages
Date: Thu, 2 Apr 2009 10:59:07 +0200
Message-ID: <20090402085906.GB8663@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:59294 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761234AbZDBI7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:59:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Some devices cannot send very short usb transfers. To get around this the
firmware adds a known pattern and flags the driver that it should check for
this pattern on short transfers. This flag was not taken into account by
the driver.
    
Signed-off-by: Jan Dumon <j.dumon@option.com>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 779a007..f84b78d 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2536,14 +2536,15 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 }
 
 /* Creates our network device */
-static struct hso_device *hso_create_net_device(struct usb_interface *interface)
+static struct hso_device *hso_create_net_device(struct usb_interface *interface,
+						int port_spec)
 {
 	int result, i;
 	struct net_device *net;
 	struct hso_net *hso_net;
 	struct hso_device *hso_dev;
 
-	hso_dev = hso_create_device(interface, HSO_INTF_MUX | HSO_PORT_NETWORK);
+	hso_dev = hso_create_device(interface, port_spec);
 	if (!hso_dev)
 		return NULL;
 
@@ -2943,7 +2944,8 @@ static int hso_probe(struct usb_interface *interface,
 		if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) {
 			/* Create the network device */
 			if (!disable_net) {
-				hso_dev = hso_create_net_device(interface);
+				hso_dev = hso_create_net_device(interface,
+								port_spec);
 				if (!hso_dev)
 					goto exit;
 				tmp_dev = hso_dev;
@@ -2975,7 +2977,7 @@ static int hso_probe(struct usb_interface *interface,
 		/* It's a regular bulk interface */
 		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK)
 		    && !disable_net)
-			hso_dev = hso_create_net_device(interface);
+			hso_dev = hso_create_net_device(interface, port_spec);
 		else
 			hso_dev =
 			    hso_create_bulk_serial_device(interface, port_spec);
