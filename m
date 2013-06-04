From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Tue, 4 Jun 2013 20:28:30 +0200
Message-ID: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>,
	Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>From 307685fe8e6dfc8181e30167b9c31479332cb22f Mon Sep 17 00:00:00 2001
From: Andreas Mohr <andim2@users.sourceforge.net>
Date: Sun, 2 Jun 2013 20:37:05 +0200
Subject: [PATCH] usbnet: improve/fix status interrupt endpoint interval
 tweaking.

- failed to take super-speed into account
- <= full-speed seems to have wrong value (specified as frames [ms],
  thus 3 is not suitable to achieve 8ms)
  Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155
- add detailed docs and question marks about current practice
---
 drivers/net/usb/usbnet.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)


Found this with MCS7830 on a full-speed USB 1.1 port (Inspiron 8000).
Good to have a rusty notebook with noisy PSU coils, else it would
have taken a lot longer to nail it ;)
Tested on -rc4, checkpath.pl:d.

Signed-off-by: Andreas Mohr <andim2@users.sourceforge.net>


diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 06ee82f..b6e9569 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -231,8 +231,23 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 	maxp = usb_maxpacket (dev->udev, pipe, 0);
 
 	/* avoid 1 msec chatter:  min 8 msec poll rate */
+	/* High/SuperSpeed expresses intervals in microframes
+	 * (in logarithmic encoding, PRIOR to encoding in URB)
+	 * rather than frames.
+	 * Thus, for >= HighSpeed: == X [microframes] * 125us [-> 8ms],
+	 * <= FullSpeed: == X [ms] [-> 8ms].
+	 * Finally, it's questionable whether we'll even get away unscathed
+	 * with doing such rate tweaking at all:
+	 * bInterval value is declared as being a hard demand by a device
+	 * in order to guarantee having its I/O needs serviced properly...
+	 * if we don't do this, then... [overruns], [fire], [apocalypse]?
+	 * If this turns out to be problematic, such policy should be moved
+	 * to individual drivers (indicate flag to [dis]allow rate tweaking
+	 * as tolerated by specific devices).
+	 */
 	period = max ((int) dev->status->desc.bInterval,
-		(dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
+		((dev->udev->speed == USB_SPEED_HIGH) ||
+		 (dev->udev->speed == USB_SPEED_SUPER)) ? 7 : 8);
 
 	buf = kmalloc (maxp, GFP_KERNEL);
 	if (buf) {
-- 
1.7.10.4
