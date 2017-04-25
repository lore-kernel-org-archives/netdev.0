From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] net: can: usb: gs_usb: Fix buffer on stack
Date: Tue, 25 Apr 2017 14:16:45 +0200
Message-ID: <20170425121645.9946-4-mkl@pengutronix.de>
References: <20170425121645.9946-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Maksim Salau <maksim.salau@gmail.com>,
        "linux-stable # = v4 . 8" <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56621 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1428582AbdDYMQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 08:16:54 -0400
In-Reply-To: <20170425121645.9946-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maksim Salau <maksim.salau@gmail.com>

Allocate buffers on HEAP instead of STACK for local structures
that are to be sent using usb_control_msg().

Signed-off-by: Maksim Salau <maksim.salau@gmail.com>
Cc: linux-stable <stable@vger.kernel.org> # >= v4.8
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/gs_usb.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index 300349fe8dc0..eecee7f8dfb7 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -739,13 +739,18 @@ static const struct net_device_ops gs_usb_netdev_ops = {
 static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
 {
 	struct gs_can *dev = netdev_priv(netdev);
-	struct gs_identify_mode imode;
+	struct gs_identify_mode *imode;
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
@@ -755,10 +760,12 @@ static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
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
2.11.0
