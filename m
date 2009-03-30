From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso: fix for the 'invalid frame length' messages
Date: Mon, 30 Mar 2009 11:44:59 +0200
Message-ID: <20090330094459.GC9849@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Some devices cannot send very short usb transfers. To get around this the
firmware adds a known pattern and flags the driver that it should check for
this pattern on short transfers. This flag was not taken into account by
the driver.

Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index a9320db..67f05ad 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2532,14 +2532,15 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
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
 
@@ -2939,7 +2940,8 @@ static int hso_probe(struct usb_interface *interface,
 		if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) {
 			/* Create the network device */
 			if (!disable_net) {
-				hso_dev = hso_create_net_device(interface);
+				hso_dev = hso_create_net_device(interface,
+								port_spec);
 				if (!hso_dev)
 					goto exit;
 				tmp_dev = hso_dev;
@@ -2971,7 +2973,7 @@ static int hso_probe(struct usb_interface *interface,
 		/* It's a regular bulk interface */
 		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK)
 		    && !disable_net)
-			hso_dev = hso_create_net_device(interface);
+			hso_dev = hso_create_net_device(interface, port_spec);
 		else
 			hso_dev =
 			    hso_create_bulk_serial_device(interface, port_spec);
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
