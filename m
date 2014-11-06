From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] cdc-ether: implement MULTICAST flag on the device
Date: Thu,  6 Nov 2014 15:19:14 +0100
Message-ID: <1415283554-27024-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, olivier.blin@softathome.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52201 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbaKFOTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 09:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olivier having laid the groundwork this patch transmits the
multicast flag to the device to save some bus traffic.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_ether.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index d3920b5..9311a08 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -71,18 +71,19 @@ static void usbnet_cdc_update_filter(struct usbnet *dev)
 {
 	struct cdc_state	*info = (void *) &dev->data;
 	struct usb_interface	*intf = info->control;
+	struct net_device	*net = dev->net;
 
-	u16 cdc_filter =
-	    USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTED |
-	    USB_CDC_PACKET_TYPE_BROADCAST;
+	u16 cdc_filter = USB_CDC_PACKET_TYPE_DIRECTED
+			| USB_CDC_PACKET_TYPE_BROADCAST;
 
-	if (dev->net->flags & IFF_PROMISC)
-		cdc_filter |= USB_CDC_PACKET_TYPE_PROMISCUOUS;
-
-	/* FIXME cdc-ether has some multicast code too, though it complains
-	 * in routine cases.  info->ether describes the multicast support.
-	 * Implement that here, manipulating the cdc filter as needed.
+	/* filtering on the device is an optional feature and not worth
+	 * the hassle so we just roughly care about snooping and if any
+	 * multicast is requested, we take every multicast
 	 */
+	if (net->flags & IFF_PROMISC)
+		cdc_filter |= USB_CDC_PACKET_TYPE_PROMISCUOUS;
+	if (!netdev_mc_empty(net) || (net->flags & IFF_ALLMULTI))
+		cdc_filter |= USB_CDC_PACKET_TYPE_ALL_MULTICAST;
 
 	usb_control_msg(dev->udev,
 			usb_sndctrlpipe(dev->udev, 0),
-- 
1.8.4.5
