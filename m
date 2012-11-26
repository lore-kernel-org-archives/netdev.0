From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: peak_usb: fix hwtstamp assignment
Date: Mon, 26 Nov 2012 22:47:09 +0100
Message-ID: <1353966430-12601-2-git-send-email-mkl@pengutronix.de>
References: <1353966430-12601-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36534 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755483Ab2KZVrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 16:47:13 -0500
In-Reply-To: <1353966430-12601-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

The skb->tstamp is set to the hardware timestamp when available in the USB
urb message. This leads to user visible timestamps which contain the 'uptime'
of the USB adapter - and not the usual system generated timestamp.

Fix this wrong assignment by applying the available hardware timestamp to the
skb_shared_hwtstamps data structure - which is intended for this purpose.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb.c     |    8 ++++++--
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c |    8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb.c b/drivers/net/can/usb/peak_usb/pcan_usb.c
index 86f26a1..25723d8 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb.c
@@ -519,8 +519,10 @@ static int pcan_usb_decode_error(struct pcan_usb_msg_context *mc, u8 n,
 	mc->pdev->dev.can.state = new_state;
 
 	if (status_len & PCAN_USB_STATUSLEN_TIMESTAMP) {
+		struct skb_shared_hwtstamps *hwts = skb_hwtstamps(skb);
+
 		peak_usb_get_ts_tv(&mc->pdev->time_ref, mc->ts16, &tv);
-		skb->tstamp = timeval_to_ktime(tv);
+		hwts->hwtstamp = timeval_to_ktime(tv);
 	}
 
 	netif_rx(skb);
@@ -605,6 +607,7 @@ static int pcan_usb_decode_data(struct pcan_usb_msg_context *mc, u8 status_len)
 	struct sk_buff *skb;
 	struct can_frame *cf;
 	struct timeval tv;
+	struct skb_shared_hwtstamps *hwts;
 
 	skb = alloc_can_skb(mc->netdev, &cf);
 	if (!skb)
@@ -652,7 +655,8 @@ static int pcan_usb_decode_data(struct pcan_usb_msg_context *mc, u8 status_len)
 
 	/* convert timestamp into kernel time */
 	peak_usb_get_ts_tv(&mc->pdev->time_ref, mc->ts16, &tv);
-	skb->tstamp = timeval_to_ktime(tv);
+	hwts = skb_hwtstamps(skb);
+	hwts->hwtstamp = timeval_to_ktime(tv);
 
 	/* push the skb */
 	netif_rx(skb);
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index e1626d9..30d79bf 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -532,6 +532,7 @@ static int pcan_usb_pro_handle_canmsg(struct pcan_usb_pro_interface *usb_if,
 	struct can_frame *can_frame;
 	struct sk_buff *skb;
 	struct timeval tv;
+	struct skb_shared_hwtstamps *hwts;
 
 	skb = alloc_can_skb(netdev, &can_frame);
 	if (!skb)
@@ -549,7 +550,8 @@ static int pcan_usb_pro_handle_canmsg(struct pcan_usb_pro_interface *usb_if,
 		memcpy(can_frame->data, rx->data, can_frame->can_dlc);
 
 	peak_usb_get_ts_tv(&usb_if->time_ref, le32_to_cpu(rx->ts32), &tv);
-	skb->tstamp = timeval_to_ktime(tv);
+	hwts = skb_hwtstamps(skb);
+	hwts->hwtstamp = timeval_to_ktime(tv);
 
 	netif_rx(skb);
 	netdev->stats.rx_packets++;
@@ -570,6 +572,7 @@ static int pcan_usb_pro_handle_error(struct pcan_usb_pro_interface *usb_if,
 	u8 err_mask = 0;
 	struct sk_buff *skb;
 	struct timeval tv;
+	struct skb_shared_hwtstamps *hwts;
 
 	/* nothing should be sent while in BUS_OFF state */
 	if (dev->can.state == CAN_STATE_BUS_OFF)
@@ -664,7 +667,8 @@ static int pcan_usb_pro_handle_error(struct pcan_usb_pro_interface *usb_if,
 	dev->can.state = new_state;
 
 	peak_usb_get_ts_tv(&usb_if->time_ref, le32_to_cpu(er->ts32), &tv);
-	skb->tstamp = timeval_to_ktime(tv);
+	hwts = skb_hwtstamps(skb);
+	hwts->hwtstamp = timeval_to_ktime(tv);
 	netif_rx(skb);
 	netdev->stats.rx_packets++;
 	netdev->stats.rx_bytes += can_frame->can_dlc;
-- 
1.7.10.4
