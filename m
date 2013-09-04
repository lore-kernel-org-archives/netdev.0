From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] can: pcan_usb_core: fix memory leak on failure paths in peak_usb_start()
Date: Thu,  5 Sep 2013 01:46:09 +0400
Message-ID: <1378331169-26285-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tx and rx urbs are not deallocated if something goes wrong in peak_usb_start().
The patch fixes error handling to deallocate all the resources.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
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
1.8.1.2

