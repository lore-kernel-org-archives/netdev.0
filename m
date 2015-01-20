From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v5 4/5] can: kvaser_usb: Retry the first bulk transfer on
 -ETIMEDOUT
Date: Tue, 20 Jan 2015 16:48:34 -0500
Message-ID: <20150120214834.GD16828@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux>
 <20150120214709.GC16828@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150120214709.GC16828@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

On some x86 laptops, plugging a Kvaser device again after an
unplug makes the firmware always ignore the very first command.
For such a case, provide some room for retries instead of
completly exiting the driver init code.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 640b0eb..068e76c 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1614,7 +1614,7 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 {
 	struct kvaser_usb *dev;
 	int err = -ENOMEM;
-	int i;
+	int i, retry = 3;
 
 	dev = devm_kzalloc(&intf->dev, sizeof(*dev), GFP_KERNEL);
 	if (!dev)
@@ -1632,7 +1632,15 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 
 	usb_set_intfdata(intf, dev);
 
-	err = kvaser_usb_get_software_info(dev);
+	/* On some x86 laptops, plugging a Kvaser device again after
+	 * an unplug makes the firmware always ignore the very first
+	 * command. For such a case, provide some room for retries
+	 * instead of completly exiting the driver.
+	 */
+	do {
+		err = kvaser_usb_get_software_info(dev);
+	} while (--retry && err == -ETIMEDOUT);
+
 	if (err) {
 		dev_err(&intf->dev,
 			"Cannot get software infos, error %d\n", err);
-- 
1.9.1

