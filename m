From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/4] can: kvaser_usb: Retry the first bulk transfer on -ETIMEDOUT
Date: Tue, 27 Jan 2015 09:01:26 +0100
Message-ID: <1422345687-12839-4-git-send-email-mkl@pengutronix.de>
References: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

On some x86 laptops, plugging a Kvaser device again after an
unplug makes the firmware always ignore the very first command.
For such a case, provide some room for retries instead of
completely exiting the driver init code.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index f0c62075df0a..55407b9663a6 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1585,7 +1585,7 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 {
 	struct kvaser_usb *dev;
 	int err = -ENOMEM;
-	int i;
+	int i, retry = 3;
 
 	dev = devm_kzalloc(&intf->dev, sizeof(*dev), GFP_KERNEL);
 	if (!dev)
@@ -1603,7 +1603,15 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 
 	usb_set_intfdata(intf, dev);
 
-	err = kvaser_usb_get_software_info(dev);
+	/* On some x86 laptops, plugging a Kvaser device again after
+	 * an unplug makes the firmware always ignore the very first
+	 * command. For such a case, provide some room for retries
+	 * instead of completely exiting the driver.
+	 */
+	do {
+		err = kvaser_usb_get_software_info(dev);
+	} while (--retry && err == -ETIMEDOUT);
+
 	if (err) {
 		dev_err(&intf->dev,
 			"Cannot get software infos, error %d\n", err);
-- 
2.1.4

