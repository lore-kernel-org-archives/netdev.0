From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: ems_usb: Fix possible tx overflow
Date: Sun, 21 Feb 2016 16:27:38 +0100
Message-ID: <1456068458-14271-2-git-send-email-mkl@pengutronix.de>
References: <1456068458-14271-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:40719 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752807AbcBURXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:23:05 -0500
In-Reply-To: <1456068458-14271-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>

This patch fixes the problem that more CAN messages could be sent to the
interface as could be send on the CAN bus. This was more likely for slow baud
rates. The sleeping _start_xmit was woken up in the _write_bulk_callback. Under
heavy TX load this produced another bulk transfer without checking the
free_slots variable and hence caused the overflow in the interface.

Signed-off-by: Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/ems_usb.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index fc5b75675cd8..eb7192fab593 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -117,6 +117,9 @@ MODULE_LICENSE("GPL v2");
  */
 #define EMS_USB_ARM7_CLOCK 8000000
 
+#define CPC_TX_QUEUE_TRIGGER_LOW	25
+#define CPC_TX_QUEUE_TRIGGER_HIGH	35
+
 /*
  * CAN-Message representation in a CPC_MSG. Message object type is
  * CPC_MSG_TYPE_CAN_FRAME or CPC_MSG_TYPE_RTR_FRAME or
@@ -278,6 +281,11 @@ static void ems_usb_read_interrupt_callback(struct urb *urb)
 	switch (urb->status) {
 	case 0:
 		dev->free_slots = dev->intr_in_buffer[1];
+		if(dev->free_slots > CPC_TX_QUEUE_TRIGGER_HIGH){
+			if (netif_queue_stopped(netdev)){
+				netif_wake_queue(netdev);
+			}
+		}
 		break;
 
 	case -ECONNRESET: /* unlink */
@@ -526,8 +534,6 @@ static void ems_usb_write_bulk_callback(struct urb *urb)
 	/* Release context */
 	context->echo_index = MAX_TX_URBS;
 
-	if (netif_queue_stopped(netdev))
-		netif_wake_queue(netdev);
 }
 
 /*
@@ -587,7 +593,7 @@ static int ems_usb_start(struct ems_usb *dev)
 	int err, i;
 
 	dev->intr_in_buffer[0] = 0;
-	dev->free_slots = 15; /* initial size */
+	dev->free_slots = 50; /* initial size */
 
 	for (i = 0; i < MAX_RX_URBS; i++) {
 		struct urb *urb = NULL;
@@ -835,7 +841,7 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
 
 		/* Slow down tx path */
 		if (atomic_read(&dev->active_tx_urbs) >= MAX_TX_URBS ||
-		    dev->free_slots < 5) {
+		    dev->free_slots < CPC_TX_QUEUE_TRIGGER_LOW) {
 			netif_stop_queue(netdev);
 		}
 	}
-- 
2.7.0
