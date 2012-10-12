From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH v2] mcs7830: Fix link state detection
Date: Fri, 12 Oct 2012 10:51:41 +0200
Message-ID: <201210121051.42359.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <gregkh@linuxfoundation.org>, davem@davemloft.net,
	Michael Leun <lkml20120218@newton.leun.net>,
	netdev@vger.kernel.org,
	Michael Leun <lkml20120218@newton.leun.net>,
	linux-kernel@vger.kernel.org
To: "Andreas Mohr" <andi@lisas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device had an undocumented "feature": it can provide a sequence of
spurious link-down status data even if the link is up all the time.
A sequence of 10 was seen so update the link state only after the device
reports the same link state 20 times.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
Reported-by: Michael Leun <lkml20120218@newton.leun.net>
Tested-by: Michael Leun <lkml20120218@newton.leun.net>
---
 drivers/net/usb/mcs7830.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03c2d8d..cc7e720 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -117,6 +117,7 @@ enum {
 struct mcs7830_data {
 	u8 multi_filter[8];
 	u8 config;
+	u8 link_counter;
 };
 
 static const char driver_name[] = "MOSCHIP usb-ethernet driver";
@@ -632,20 +633,31 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 {
 	u8 *buf = urb->transfer_buffer;
-	bool link;
+	bool link, link_changed;
+	struct mcs7830_data *data = mcs7830_get_data(dev);
 
 	if (urb->actual_length < 16)
 		return;
 
 	link = !(buf[1] & 0x20);
-	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
-		} else
-			netif_carrier_off(dev->net);
-		netdev_dbg(dev->net, "Link Status is: %d\n", link);
-	}
+	link_changed = netif_carrier_ok(dev->net) != link;
+	if (link_changed) {
+		data->link_counter++;
+		/*
+		   track link state 20 times to guard against erroneous
+		   link state changes reported sometimes by the chip
+		 */
+		if (data->link_counter > 20) {
+			data->link_counter = 0;
+			if (link) {
+				netif_carrier_on(dev->net);
+				usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+			} else
+				netif_carrier_off(dev->net);
+			netdev_dbg(dev->net, "Link Status is: %d\n", link);
+		}
+	} else
+		data->link_counter = 0;
 }
 
 static const struct driver_info moschip_info = {

-- 
Ondrej Zary
