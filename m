From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v4 4/4] can: kvaser_usb: Retry first bulk transfer on
 -ETIMEDOUT
Date: Sun, 11 Jan 2015 15:45:08 -0500
Message-ID: <20150111204508.GB8999@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
 <20150111201519.GC8855@linux>
 <20150111203612.GA8999@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linux-USB <linux-usb@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150111203612.GA8999@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

(This is a draft patch, I'm not sure if this fixes the USB
bug or only its psymptom. Feedback from the linux-usb folks
is really appreciated.)

When plugging the Kvaser USB/CAN dongle the first time, everything
works as expected and all of the transfers from and to the USB
device succeeds.

Meanwhile, after unplugging the device and plugging it again, the
first bulk transfer _always_ returns an -ETIMEDOUT. The following
behaviour was observied:

- Setting higher timeout values for the first bulk transfer never
  solved the issue.

- Unloading, then loading, our kvaser_usb module in question
  __always__ solved the issue.

- Checking first bulk transfer status, and retry the transfer
  again in case of an -ETIMEDOUT also __always__ solved the issue.
  This is what the patch below does.

- In the testing done so far, this issue appears only on laptops
  but never on PCs (possibly power related?)

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index da47d17..5925637 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1927,7 +1927,7 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 {
 	struct kvaser_usb *dev;
 	int err = -ENOMEM;
-	int i;
+	int i, retry = 3;
 
 	dev = devm_kzalloc(&intf->dev, sizeof(*dev), GFP_KERNEL);
 	if (!dev)
@@ -1956,7 +1956,16 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 
 	usb_set_intfdata(intf, dev);
 
-	err = kvaser_usb_get_software_info(dev);
+	/* On some x86 laptops, plugging a USBCAN device again after
+	 * an unplug makes the firmware always ignore the very first
+	 * command. For such a case, provide some room for retries
+	 * instead of completly exiting the driver.
+	 */
+	while (retry--) {
+		err = kvaser_usb_get_software_info(dev);
+		if (err != -ETIMEDOUT)
+			break;
+	}
 	if (err) {
 		dev_err(&intf->dev,
 			"Cannot get software infos, error %d\n", err);
-- 
1.9.1

