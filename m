From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/4] can: usb_8dev: Fix memory leak of priv->cmd_msg_buffer
Date: Fri,  3 Mar 2017 14:55:34 +0100
Message-ID: <20170303135535.22937-4-mkl@pengutronix.de>
References: <20170303135535.22937-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170303135535.22937-1-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The priv->cmd_msg_buffer is allocated in the probe function, but never
kfree()ed. This patch converts the kzalloc() to resource-managed
kzalloc.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/usb_8dev.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index 108a30e15097..d000cb62d6ae 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -951,8 +951,8 @@ static int usb_8dev_probe(struct usb_interface *intf,
 	for (i = 0; i < MAX_TX_URBS; i++)
 		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
 
-	priv->cmd_msg_buffer = kzalloc(sizeof(struct usb_8dev_cmd_msg),
-				      GFP_KERNEL);
+	priv->cmd_msg_buffer = devm_kzalloc(&intf->dev, sizeof(struct usb_8dev_cmd_msg),
+					    GFP_KERNEL);
 	if (!priv->cmd_msg_buffer)
 		goto cleanup_candev;
 
@@ -966,7 +966,7 @@ static int usb_8dev_probe(struct usb_interface *intf,
 	if (err) {
 		netdev_err(netdev,
 			"couldn't register CAN device: %d\n", err);
-		goto cleanup_cmd_msg_buffer;
+		goto cleanup_candev;
 	}
 
 	err = usb_8dev_cmd_version(priv, &version);
@@ -987,9 +987,6 @@ static int usb_8dev_probe(struct usb_interface *intf,
 cleanup_unregister_candev:
 	unregister_netdev(priv->netdev);
 
-cleanup_cmd_msg_buffer:
-	kfree(priv->cmd_msg_buffer);
-
 cleanup_candev:
 	free_candev(netdev);
 
-- 
2.11.0
