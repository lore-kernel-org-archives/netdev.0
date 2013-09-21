From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: pcan_usb_core: fix memory leak on failure paths in peak_usb_start()
Date: Sat, 21 Sep 2013 16:08:13 +0200
Message-ID: <1379772493-7856-2-git-send-email-mkl@pengutronix.de>
References: <1379772493-7856-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36729 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab3IUOIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 10:08:19 -0400
In-Reply-To: <1379772493-7856-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>

Tx and rx urbs are not deallocated if something goes wrong in peak_usb_start().
The patch fixes error handling to deallocate all the resources.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index a0f647f..0b7a4c3 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -463,7 +463,7 @@ static int peak_usb_start(struct peak_usb_device *dev)
 	if (i < PCAN_USB_MAX_TX_URBS) {
 		if (i == 0) {
 			netdev_err(netdev, "couldn't setup any tx URB\n");
-			return err;
+			goto err_tx;
 		}
 
 		netdev_warn(netdev, "tx performance may be slow\n");
@@ -472,7 +472,7 @@ static int peak_usb_start(struct peak_usb_device *dev)
 	if (dev->adapter->dev_start) {
 		err = dev->adapter->dev_start(dev);
 		if (err)
-			goto failed;
+			goto err_adapter;
 	}
 
 	dev->state |= PCAN_USB_STATE_STARTED;
@@ -481,19 +481,26 @@ static int peak_usb_start(struct peak_usb_device *dev)
 	if (dev->adapter->dev_set_bus) {
 		err = dev->adapter->dev_set_bus(dev, 1);
 		if (err)
-			goto failed;
+			goto err_adapter;
 	}
 
 	dev->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	return 0;
 
-failed:
+err_adapter:
 	if (err == -ENODEV)
 		netif_device_detach(dev->netdev);
 
 	netdev_warn(netdev, "couldn't submit control: %d\n", err);
 
+	for (i = 0; i < PCAN_USB_MAX_TX_URBS; i++) {
+		usb_free_urb(dev->tx_contexts[i].urb);
+		dev->tx_contexts[i].urb = NULL;
+	}
+err_tx:
+	usb_kill_anchored_urbs(&dev->rx_submitted);
+
 	return err;
 }
 
-- 
1.8.4.rc3
