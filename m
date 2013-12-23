From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH] usbnet: mcs7830: rework link state detection
Date: Mon, 23 Dec 2013 19:06:31 +0200
Message-ID: <1387818391-12935-1-git-send-email-octavian.purdila@intel.com>
Cc: linux-usb@vger.kernel.org, hunold@linuxtv.org, jeroen@koekkoek.nl,
	Octavian Purdila <octavian.purdila@intel.com>,
	Ondrej Zary <linux@rainbow-software.org>,
	Michael Leun <lkml20120218@newton.leun.net>,
	Ming Lei <ming.lei@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36196 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab3LWRHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 12:07:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even with the quirks in commit dabdaf0c (mcs7830: Fix link state
detection) there are still spurious link-down events for some chips
where the false link-down events count go over a few hundreds.

This patch takes a more conservative approach and only looks at
link-down events where the link-down state is not combined with other
states (e.g. half/full speed, pending frames in SRAM or TX status
information valid). In all other cases we assume the link is up.

Tested on MCS7830CV-DA (USB ID 9710:7830).

Cc: Ondrej Zary <linux@rainbow-software.org>
Cc: Michael Leun <lkml20120218@newton.leun.net>
Cc: Ming Lei <ming.lei@canonical.com>
Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 drivers/net/usb/mcs7830.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03832d3..f546378 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -117,7 +117,6 @@ enum {
 struct mcs7830_data {
 	u8 multi_filter[8];
 	u8 config;
-	u8 link_counter;
 };
 
 static const char driver_name[] = "MOSCHIP usb-ethernet driver";
@@ -561,26 +560,16 @@ static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 {
 	u8 *buf = urb->transfer_buffer;
 	bool link, link_changed;
-	struct mcs7830_data *data = mcs7830_get_data(dev);
 
 	if (urb->actual_length < 16)
 		return;
 
-	link = !(buf[1] & 0x20);
+	link = !(buf[1] == 0x20);
 	link_changed = netif_carrier_ok(dev->net) != link;
 	if (link_changed) {
-		data->link_counter++;
-		/*
-		   track link state 20 times to guard against erroneous
-		   link state changes reported sometimes by the chip
-		 */
-		if (data->link_counter > 20) {
-			data->link_counter = 0;
-			usbnet_link_change(dev, link, 0);
-			netdev_dbg(dev->net, "Link Status is: %d\n", link);
-		}
-	} else
-		data->link_counter = 0;
+		usbnet_link_change(dev, link, 0);
+		netdev_dbg(dev->net, "Link Status is: %d\n", link);
+	}
 }
 
 static const struct driver_info moschip_info = {
-- 
1.8.3.2
