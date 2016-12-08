From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: peak: fix bad memory access and free sequence
Date: Thu,  8 Dec 2016 16:35:52 +0100
Message-ID: <20161208153552.18122-2-mkl@pengutronix.de>
References: <20161208153552.18122-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        =?UTF-8?q?=EC=B6=94=EC=A7=80=ED=98=B8?= <jiho.chu@samsung.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:43891 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932312AbcLHPf7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:35:59 -0500
In-Reply-To: <20161208153552.18122-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 추지호 <jiho.chu@samsung.com>

Fix for bad memory access while disconnecting. netdev is freed before
private data free, and dev is accessed after freeing netdev.

This makes a slub problem, and it raise kernel oops with slub debugger
config.

Signed-off-by: Jiho Chu <jiho.chu@samsung.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index f3141ca56bc3..0b0302af3bd2 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -870,23 +870,25 @@ static int peak_usb_create_dev(const struct peak_usb_adapter *peak_usb_adapter,
 static void peak_usb_disconnect(struct usb_interface *intf)
 {
 	struct peak_usb_device *dev;
+	struct peak_usb_device *dev_prev_siblings;
 
 	/* unregister as many netdev devices as siblings */
-	for (dev = usb_get_intfdata(intf); dev; dev = dev->prev_siblings) {
+	for (dev = usb_get_intfdata(intf); dev; dev = dev_prev_siblings) {
 		struct net_device *netdev = dev->netdev;
 		char name[IFNAMSIZ];
 
+		dev_prev_siblings = dev->prev_siblings;
 		dev->state &= ~PCAN_USB_STATE_CONNECTED;
 		strncpy(name, netdev->name, IFNAMSIZ);
 
 		unregister_netdev(netdev);
-		free_candev(netdev);
 
 		kfree(dev->cmd_buf);
 		dev->next_siblings = NULL;
 		if (dev->adapter->dev_free)
 			dev->adapter->dev_free(dev);
 
+		free_candev(netdev);
 		dev_info(&intf->dev, "%s removed\n", name);
 	}
 
-- 
2.10.2
