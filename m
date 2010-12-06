From: Indrek Peri <Indrek.Peri@Ericsson.com>
Subject: [PATCH] Insert interrupt URB after resume, so that status transfers can flow.
Date: Mon, 6 Dec 2010 11:23:03 +0100
Message-ID: <1291630983-23725-1-git-send-email-Indrek.Peri@Ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Indrek Peri <Indrek.Peri@Ericsson.com>
To: <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:65017 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab0LFKWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 05:22:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Indrek Peri <Indrek.Peri@Ericsson.com>
---
 drivers/net/usb/usbnet.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index c04d49e..eaa83f9 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -719,6 +719,7 @@ int usbnet_open (struct net_device *net)
 
 	/* start any status interrupt transfer */
 	if (dev->interrupt) {
+		usb_kill_urb(dev->interrupt); /* resume may add int urb */
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
 			netif_err(dev, ifup, dev->net,
@@ -1495,6 +1496,17 @@ int usbnet_resume (struct usb_interface *intf)
 		spin_unlock_irq(&dev->txq.lock);
 		if (!(dev->txq.qlen >= TX_QLEN(dev)))
 			netif_start_queue(dev->net);
+
+		/* start any status interrupt transfer */
+		if (dev->interrupt) {
+			retval = usb_submit_urb(dev->interrupt, GFP_KERNEL);
+			if (retval < 0) {
+				netif_err(dev, ifup, dev->net,
+				  "intr submit %d\n", retval);
+				return retval;
+			}
+		}
+
 		tasklet_schedule (&dev->bh);
 	}
 	return 0;
-- 
1.7.0.3

