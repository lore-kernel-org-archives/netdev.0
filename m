From: Olivier Blin <olivier.blin@softathome.com>
Subject: [PATCH net 2/3] cdc-ether: extract usbnet_cdc_update_filter function
Date: Fri, 24 Oct 2014 19:43:01 +0200
Message-ID: <1414172582-30844-3-git-send-email-olivier.blin@softathome.com>
References: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Cc: oneukum@suse.de, hayeswang@realtek.com, bjorn@mork.no,
	davem@davemloft.net, Olivier Blin <olivier.blin@softathome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 92-137-167-83.reverse.alphalink.fr ([83.167.137.92]:39353 "EHLO
	mtantr1.softathome.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757037AbaJXRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 13:52:09 -0400
In-Reply-To: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used by the set_rx_mode callback.

Also move a comment about multicast filtering in this new function.

Signed-off-by: Olivier Blin <olivier.blin@softathome.com>
---
 drivers/net/usb/cdc_ether.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 2a32d91..bee3689 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -67,6 +67,32 @@ static const u8 mbm_guid[16] = {
 	0xa6, 0x07, 0xc0, 0xff, 0xcb, 0x7e, 0x39, 0x2a,
 };
 
+static void usbnet_cdc_update_filter(struct usbnet *dev)
+{
+	struct cdc_state	*info = (void *) &dev->data;
+	struct usb_interface	*intf = info->control;
+
+	u16 cdc_filter =
+	    USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTED |
+	    USB_CDC_PACKET_TYPE_BROADCAST;
+
+	/* FIXME cdc-ether has some multicast code too, though it complains
+	 * in routine cases.  info->ether describes the multicast support.
+	 * Implement that here, manipulating the cdc filter as needed.
+	 */
+
+	usb_control_msg(dev->udev,
+			usb_sndctrlpipe(dev->udev, 0),
+			USB_CDC_SET_ETHERNET_PACKET_FILTER,
+			USB_TYPE_CLASS | USB_RECIP_INTERFACE,
+			cdc_filter,
+			intf->cur_altsetting->desc.bInterfaceNumber,
+			NULL,
+			0,
+			USB_CTRL_SET_TIMEOUT
+		);
+}
+
 /* probes control interface, claims data interface, collects the bulk
  * endpoints, activates data interface (if needed), maybe sets MTU.
  * all pure cdc, except for certain firmware workarounds, and knowing
@@ -347,16 +373,8 @@ next_desc:
 	 * don't do reset all the way. So the packet filter should
 	 * be set to a sane initial value.
 	 */
-	usb_control_msg(dev->udev,
-			usb_sndctrlpipe(dev->udev, 0),
-			USB_CDC_SET_ETHERNET_PACKET_FILTER,
-			USB_TYPE_CLASS | USB_RECIP_INTERFACE,
-			USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTED | USB_CDC_PACKET_TYPE_BROADCAST,
-			intf->cur_altsetting->desc.bInterfaceNumber,
-			NULL,
-			0,
-			USB_CTRL_SET_TIMEOUT
-		);
+	usbnet_cdc_update_filter(dev);
+
 	return 0;
 
 bad_desc:
@@ -468,10 +486,6 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 		return status;
 	}
 
-	/* FIXME cdc-ether has some multicast code too, though it complains
-	 * in routine cases.  info->ether describes the multicast support.
-	 * Implement that here, manipulating the cdc filter as needed.
-	 */
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_bind);
-- 
2.1.2

-- This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome.s ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
-- This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome.s ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
