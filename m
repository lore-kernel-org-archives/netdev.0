From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] usbnet: Set link down initially for drivers that update
 link state
Date: Thu, 05 Nov 2009 01:29:52 +0000
Message-ID: <1257384592.3136.473.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <greg@kroah.com>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	David Brownell <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42834 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750862AbZKEBaS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 20:30:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some usbnet drivers update link state while others do not due to
hardware limitations.  Add a flag to distinguish those that do, and
set the link down initially for their devices.

This is intended to fix this bug: http://bugs.debian.org/444043

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
All drivers that update the link status are supposed to set it down
initially.  These drivers will need to be tested to verify that if the
physical link is already up then they update the link status correctly
when the interface is brought up.

Ben.

 drivers/net/usb/asix.c      |   12 ++++++------
 drivers/net/usb/cdc_ether.c |    2 +-
 drivers/net/usb/dm9601.c    |    2 +-
 drivers/net/usb/usbnet.c    |    4 +++-
 include/linux/usb/usbnet.h  |    1 +
 5 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 6ce7f77..1bef39a 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1327,7 +1327,7 @@ static const struct driver_info ax8817x_info = {
 	.status = asix_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER,
+	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
 	.data = 0x00130103,
 };
 
@@ -1337,7 +1337,7 @@ static const struct driver_info dlink_dub_e100_info = {
 	.status = asix_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER,
+	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
 	.data = 0x009f9d9f,
 };
 
@@ -1347,7 +1347,7 @@ static const struct driver_info netgear_fa120_info = {
 	.status = asix_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER,
+	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
 	.data = 0x00130103,
 };
 
@@ -1357,7 +1357,7 @@ static const struct driver_info hawking_uf200_info = {
 	.status = asix_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER,
+	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
 	.data = 0x001f1d1f,
 };
 
@@ -1367,7 +1367,7 @@ static const struct driver_info ax88772_info = {
 	.status = asix_status,
 	.link_reset = ax88772_link_reset,
 	.reset = ax88772_link_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
 	.rx_fixup = asix_rx_fixup,
 	.tx_fixup = asix_tx_fixup,
 };
@@ -1378,7 +1378,7 @@ static const struct driver_info ax88178_info = {
 	.status = asix_status,
 	.link_reset = ax88178_link_reset,
 	.reset = ax88178_link_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
 	.rx_fixup = asix_rx_fixup,
 	.tx_fixup = asix_tx_fixup,
 };
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 71e65fc..dcf6dbd 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -413,7 +413,7 @@ static int cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
-	.flags =	FLAG_ETHER,
+	.flags =	FLAG_ETHER | FLAG_LINK_INTR,
 	// .check_connect = cdc_check_connect,
 	.bind =		cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index a2b30a1..3d406f9 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -611,7 +611,7 @@ static int dm9601_link_reset(struct usbnet *dev)
 
 static const struct driver_info dm9601_info = {
 	.description	= "Davicom DM9601 USB Ethernet",
-	.flags		= FLAG_ETHER,
+	.flags		= FLAG_ETHER | FLAG_LINK_INTR,
 	.bind		= dm9601_bind,
 	.rx_fixup	= dm9601_rx_fixup,
 	.tx_fixup	= dm9601_tx_fixup,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 378da8c..04f3f28 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1352,9 +1352,11 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	// ok, it's ready to go.
 	usb_set_intfdata (udev, dev);
 
-	// start as if the link is up
 	netif_device_attach (net);
 
+	if (dev->driver_info->flags & FLAG_LINK_INTR)
+		netif_carrier_off(net);
+
 	return 0;
 
 out3:
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 86c31b7..8c84881 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -92,6 +92,7 @@ struct driver_info {
 #define FLAG_SEND_ZLP	0x0200		/* hw requires ZLPs are sent */
 #define FLAG_WWAN	0x0400		/* use "wwan%d" names */
 
+#define FLAG_LINK_INTR	0x0800		/* updates link (carrier) status */
 
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
-- 
1.6.5.2


