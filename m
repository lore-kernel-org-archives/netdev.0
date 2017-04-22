From: Maksim Salau <maksim.salau@gmail.com>
Subject: [PATCH] net: can: usb: gs_usb: Fix buffer on stack
Date: Sat, 22 Apr 2017 19:56:26 +0300
Message-ID: <20170422165626.10534-1-maksim.salau@gmail.com>
Cc: Maksim Salau <maksim.salau@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Maximilian Schneider <max@schneidersoft.net>,
        Hubert Denkmair <hubert@denkmair.de>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        Ethan Zonca <e@ethanzonca.com>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34247 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425924AbdDVQ46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:56:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate buffer on HEAP instead of STACK for a local structure
that is to be sent using usb_control_msg().

Signed-off-by: Maksim Salau <maksim.salau@gmail.com>
---
 drivers/net/can/usb/gs_usb.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index a0dabd4..98f972a 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -740,13 +740,18 @@ static const struct net_device_ops gs_usb_netdev_ops = {
 static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
 {
 	struct gs_can *dev = netdev_priv(netdev);
-	struct gs_identify_mode imode;
+	struct gs_identify_mode *imode = NULL;
 	int rc;
 
+	imode = kmalloc(sizeof(*imode), GFP_KERNEL);
+
+	if (!imode)
+		return -ENOMEM;
+
 	if (do_identify)
-		imode.mode = GS_CAN_IDENTIFY_ON;
+		imode->mode = GS_CAN_IDENTIFY_ON;
 	else
-		imode.mode = GS_CAN_IDENTIFY_OFF;
+		imode->mode = GS_CAN_IDENTIFY_OFF;
 
 	rc = usb_control_msg(interface_to_usbdev(dev->iface),
 			     usb_sndctrlpipe(interface_to_usbdev(dev->iface),
@@ -756,10 +761,12 @@ static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
 			     USB_RECIP_INTERFACE,
 			     dev->channel,
 			     0,
-			     &imode,
-			     sizeof(imode),
+			     imode,
+			     sizeof(*imode),
 			     100);
 
+	kfree(imode);
+
 	return (rc > 0) ? 0 : rc;
 }
 
-- 
2.9.3
