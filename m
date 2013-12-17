From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: ems_usb: fix urb leaks on failure paths
Date: Tue, 17 Dec 2013 11:44:48 +0100
Message-ID: <1387277089-25554-2-git-send-email-mkl@pengutronix.de>
References: <1387277089-25554-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1387277089-25554-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>

There are a couple failure paths where urb leaks.
Is spare code within ems_usb_start_xmit(),
usb_free_urb() should be used to deallocate urb instead of usb_unanchor_urb().
In ems_usb_start() there is no usb_free_urb() if usb_submit_urb() fails.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Acked-by: Sebastian Haas <dev@sebastianhaas.info>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/ems_usb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 5f9a7ad..8aeec0b 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -625,6 +625,7 @@ static int ems_usb_start(struct ems_usb *dev)
 			usb_unanchor_urb(urb);
 			usb_free_coherent(dev->udev, RX_BUFFER_SIZE, buf,
 					  urb->transfer_dma);
+			usb_free_urb(urb);
 			break;
 		}
 
@@ -798,8 +799,8 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
 	 * allowed (MAX_TX_URBS).
 	 */
 	if (!context) {
-		usb_unanchor_urb(urb);
 		usb_free_coherent(dev->udev, size, buf, urb->transfer_dma);
+		usb_free_urb(urb);
 
 		netdev_warn(netdev, "couldn't find free context\n");
 
-- 
1.8.5.1

