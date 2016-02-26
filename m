From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: gs_usb: fixed disconnect bug by removing erroneous use of kfree()
Date: Fri, 26 Feb 2016 08:42:58 +0100
Message-ID: <1456472578-16272-2-git-send-email-mkl@pengutronix.de>
References: <1456472578-16272-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Maximilain Schneider <max@schneidersoft.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456472578-16272-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maximilain Schneider <max@schneidersoft.net>

gs_destroy_candev() erroneously calls kfree() on a struct gs_can *, which is
allocated through alloc_candev() and should instead be freed using
free_candev() alone.

The inappropriate use of kfree() causes the kernel to hang when
gs_destroy_candev() is called.

Only the struct gs_usb * which is allocated through kzalloc() should be freed
using kfree() when the device is disconnected.

Signed-off-by: Maximilian Schneider <max@schneidersoft.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/gs_usb.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index 5eee62badf45..cbc99d5649af 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -826,9 +826,8 @@ static struct gs_can *gs_make_candev(unsigned int channel, struct usb_interface
 static void gs_destroy_candev(struct gs_can *dev)
 {
 	unregister_candev(dev->netdev);
-	free_candev(dev->netdev);
 	usb_kill_anchored_urbs(&dev->tx_submitted);
-	kfree(dev);
+	free_candev(dev->netdev);
 }
 
 static int gs_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
@@ -913,12 +912,15 @@ static int gs_usb_probe(struct usb_interface *intf, const struct usb_device_id *
 	for (i = 0; i < icount; i++) {
 		dev->canch[i] = gs_make_candev(i, intf);
 		if (IS_ERR_OR_NULL(dev->canch[i])) {
+			/* save error code to return later */
+			rc = PTR_ERR(dev->canch[i]);
+
 			/* on failure destroy previously created candevs */
 			icount = i;
-			for (i = 0; i < icount; i++) {
+			for (i = 0; i < icount; i++)
 				gs_destroy_candev(dev->canch[i]);
-				dev->canch[i] = NULL;
-			}
+
+			usb_kill_anchored_urbs(&dev->rx_submitted);
 			kfree(dev);
 			return rc;
 		}
@@ -939,16 +941,12 @@ static void gs_usb_disconnect(struct usb_interface *intf)
 		return;
 	}
 
-	for (i = 0; i < GS_MAX_INTF; i++) {
-		struct gs_can *can = dev->canch[i];
-
-		if (!can)
-			continue;
-
-		gs_destroy_candev(can);
-	}
+	for (i = 0; i < GS_MAX_INTF; i++)
+		if (dev->canch[i])
+			gs_destroy_candev(dev->canch[i]);
 
 	usb_kill_anchored_urbs(&dev->rx_submitted);
+	kfree(dev);
 }
 
 static const struct usb_device_id gs_usb_table[] = {
-- 
2.7.0

