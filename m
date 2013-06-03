From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] net: can: esd_usb2: Do not do dma on the stack
Date: Mon,  3 Jun 2013 14:15:32 +0200
Message-ID: <1370261733-22935-3-git-send-email-mkl@pengutronix.de>
References: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, davem@davemloft.net,
	Olivier Sobrie <olivier@sobrie.be>,
	Matthias Fuchs <matthias.fuchs@esd.eu>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie <olivier@sobrie.be>

smatch reports the following warnings:
drivers/net/can/usb/esd_usb2.c:640 esd_usb2_start() error: doing dma on the stack (&msg)
drivers/net/can/usb/esd_usb2.c:846 esd_usb2_close() error: doing dma on the stack (&msg)
drivers/net/can/usb/esd_usb2.c:855 esd_usb2_close() error: doing dma on the stack (&msg)
drivers/net/can/usb/esd_usb2.c:923 esd_usb2_set_bittiming() error: doing dma on the stack (&msg)
drivers/net/can/usb/esd_usb2.c:1047 esd_usb2_probe() error: doing dma on the stack (&msg)
drivers/net/can/usb/esd_usb2.c:1053 esd_usb2_probe() error: doing dma on the stack (&msg)

See "Documentation/DMA-API-HOWTO.txt" section "What memory is DMA'able?"

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
Cc: Matthias Fuchs <matthias.fuchs@esd.eu>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/esd_usb2.c | 127 ++++++++++++++++++++++++-----------------
 1 file changed, 76 insertions(+), 51 deletions(-)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 9b74d1e..6aa7b32 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -612,9 +612,15 @@ static int esd_usb2_start(struct esd_usb2_net_priv *priv)
 {
 	struct esd_usb2 *dev = priv->usb2;
 	struct net_device *netdev = priv->netdev;
-	struct esd_usb2_msg msg;
+	struct esd_usb2_msg *msg;
 	int err, i;
 
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
 	/*
 	 * Enable all IDs
 	 * The IDADD message takes up to 64 32 bit bitmasks (2048 bits).
@@ -628,33 +634,32 @@ static int esd_usb2_start(struct esd_usb2_net_priv *priv)
 	 * the number of the starting bitmask (0..64) to the filter.option
 	 * field followed by only some bitmasks.
 	 */
-	msg.msg.hdr.cmd = CMD_IDADD;
-	msg.msg.hdr.len = 2 + ESD_MAX_ID_SEGMENT;
-	msg.msg.filter.net = priv->index;
-	msg.msg.filter.option = ESD_ID_ENABLE; /* start with segment 0 */
+	msg->msg.hdr.cmd = CMD_IDADD;
+	msg->msg.hdr.len = 2 + ESD_MAX_ID_SEGMENT;
+	msg->msg.filter.net = priv->index;
+	msg->msg.filter.option = ESD_ID_ENABLE; /* start with segment 0 */
 	for (i = 0; i < ESD_MAX_ID_SEGMENT; i++)
-		msg.msg.filter.mask[i] = cpu_to_le32(0xffffffff);
+		msg->msg.filter.mask[i] = cpu_to_le32(0xffffffff);
 	/* enable 29bit extended IDs */
-	msg.msg.filter.mask[ESD_MAX_ID_SEGMENT] = cpu_to_le32(0x00000001);
+	msg->msg.filter.mask[ESD_MAX_ID_SEGMENT] = cpu_to_le32(0x00000001);
 
-	err = esd_usb2_send_msg(dev, &msg);
+	err = esd_usb2_send_msg(dev, msg);
 	if (err)
-		goto failed;
+		goto out;
 
 	err = esd_usb2_setup_rx_urbs(dev);
 	if (err)
-		goto failed;
+		goto out;
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
-	return 0;
-
-failed:
+out:
 	if (err == -ENODEV)
 		netif_device_detach(netdev);
+	if (err)
+		netdev_err(netdev, "couldn't start device: %d\n", err);
 
-	netdev_err(netdev, "couldn't start device: %d\n", err);
-
+	kfree(msg);
 	return err;
 }
 
@@ -833,26 +838,30 @@ nourbmem:
 static int esd_usb2_close(struct net_device *netdev)
 {
 	struct esd_usb2_net_priv *priv = netdev_priv(netdev);
-	struct esd_usb2_msg msg;
+	struct esd_usb2_msg *msg;
 	int i;
 
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
 	/* Disable all IDs (see esd_usb2_start()) */
-	msg.msg.hdr.cmd = CMD_IDADD;
-	msg.msg.hdr.len = 2 + ESD_MAX_ID_SEGMENT;
-	msg.msg.filter.net = priv->index;
-	msg.msg.filter.option = ESD_ID_ENABLE; /* start with segment 0 */
+	msg->msg.hdr.cmd = CMD_IDADD;
+	msg->msg.hdr.len = 2 + ESD_MAX_ID_SEGMENT;
+	msg->msg.filter.net = priv->index;
+	msg->msg.filter.option = ESD_ID_ENABLE; /* start with segment 0 */
 	for (i = 0; i <= ESD_MAX_ID_SEGMENT; i++)
-		msg.msg.filter.mask[i] = 0;
-	if (esd_usb2_send_msg(priv->usb2, &msg) < 0)
+		msg->msg.filter.mask[i] = 0;
+	if (esd_usb2_send_msg(priv->usb2, msg) < 0)
 		netdev_err(netdev, "sending idadd message failed\n");
 
 	/* set CAN controller to reset mode */
-	msg.msg.hdr.len = 2;
-	msg.msg.hdr.cmd = CMD_SETBAUD;
-	msg.msg.setbaud.net = priv->index;
-	msg.msg.setbaud.rsvd = 0;
-	msg.msg.setbaud.baud = cpu_to_le32(ESD_USB2_NO_BAUDRATE);
-	if (esd_usb2_send_msg(priv->usb2, &msg) < 0)
+	msg->msg.hdr.len = 2;
+	msg->msg.hdr.cmd = CMD_SETBAUD;
+	msg->msg.setbaud.net = priv->index;
+	msg->msg.setbaud.rsvd = 0;
+	msg->msg.setbaud.baud = cpu_to_le32(ESD_USB2_NO_BAUDRATE);
+	if (esd_usb2_send_msg(priv->usb2, msg) < 0)
 		netdev_err(netdev, "sending setbaud message failed\n");
 
 	priv->can.state = CAN_STATE_STOPPED;
@@ -861,6 +870,8 @@ static int esd_usb2_close(struct net_device *netdev)
 
 	close_candev(netdev);
 
+	kfree(msg);
+
 	return 0;
 }
 
@@ -886,7 +897,8 @@ static int esd_usb2_set_bittiming(struct net_device *netdev)
 {
 	struct esd_usb2_net_priv *priv = netdev_priv(netdev);
 	struct can_bittiming *bt = &priv->can.bittiming;
-	struct esd_usb2_msg msg;
+	struct esd_usb2_msg *msg;
+	int err;
 	u32 canbtr;
 	int sjw_shift;
 
@@ -912,15 +924,22 @@ static int esd_usb2_set_bittiming(struct net_device *netdev)
 	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
 		canbtr |= ESD_USB2_3_SAMPLES;
 
-	msg.msg.hdr.len = 2;
-	msg.msg.hdr.cmd = CMD_SETBAUD;
-	msg.msg.setbaud.net = priv->index;
-	msg.msg.setbaud.rsvd = 0;
-	msg.msg.setbaud.baud = cpu_to_le32(canbtr);
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	msg->msg.hdr.len = 2;
+	msg->msg.hdr.cmd = CMD_SETBAUD;
+	msg->msg.setbaud.net = priv->index;
+	msg->msg.setbaud.rsvd = 0;
+	msg->msg.setbaud.baud = cpu_to_le32(canbtr);
 
 	netdev_info(netdev, "setting BTR=%#x\n", canbtr);
 
-	return esd_usb2_send_msg(priv->usb2, &msg);
+	err = esd_usb2_send_msg(priv->usb2, msg);
+
+	kfree(msg);
+	return err;
 }
 
 static int esd_usb2_get_berr_counter(const struct net_device *netdev,
@@ -1022,7 +1041,7 @@ static int esd_usb2_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
 	struct esd_usb2 *dev;
-	struct esd_usb2_msg msg;
+	struct esd_usb2_msg *msg;
 	int i, err;
 
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
@@ -1037,27 +1056,33 @@ static int esd_usb2_probe(struct usb_interface *intf,
 
 	usb_set_intfdata(intf, dev);
 
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto free_msg;
+	}
+
 	/* query number of CAN interfaces (nets) */
-	msg.msg.hdr.cmd = CMD_VERSION;
-	msg.msg.hdr.len = 2;
-	msg.msg.version.rsvd = 0;
-	msg.msg.version.flags = 0;
-	msg.msg.version.drv_version = 0;
+	msg->msg.hdr.cmd = CMD_VERSION;
+	msg->msg.hdr.len = 2;
+	msg->msg.version.rsvd = 0;
+	msg->msg.version.flags = 0;
+	msg->msg.version.drv_version = 0;
 
-	err = esd_usb2_send_msg(dev, &msg);
+	err = esd_usb2_send_msg(dev, msg);
 	if (err < 0) {
 		dev_err(&intf->dev, "sending version message failed\n");
-		goto free_dev;
+		goto free_msg;
 	}
 
-	err = esd_usb2_wait_msg(dev, &msg);
+	err = esd_usb2_wait_msg(dev, msg);
 	if (err < 0) {
 		dev_err(&intf->dev, "no version message answer\n");
-		goto free_dev;
+		goto free_msg;
 	}
 
-	dev->net_count = (int)msg.msg.version_reply.nets;
-	dev->version = le32_to_cpu(msg.msg.version_reply.version);
+	dev->net_count = (int)msg->msg.version_reply.nets;
+	dev->version = le32_to_cpu(msg->msg.version_reply.version);
 
 	if (device_create_file(&intf->dev, &dev_attr_firmware))
 		dev_err(&intf->dev,
@@ -1075,10 +1100,10 @@ static int esd_usb2_probe(struct usb_interface *intf,
 	for (i = 0; i < dev->net_count; i++)
 		esd_usb2_probe_one_net(intf, i);
 
-	return 0;
-
-free_dev:
-	kfree(dev);
+free_msg:
+	kfree(msg);
+	if (err)
+		kfree(dev);
 done:
 	return err;
 }
-- 
1.8.2.rc2

