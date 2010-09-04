From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] usbnet: allow rx_process() to ignore packets
Date: Sat, 4 Sep 2010 23:52:22 +0200
Message-ID: <201009042352.24197.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: David Brownell <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:53461 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753670Ab0IDVwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 17:52:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow rx_process() to ignore a packet without incrementing error counters if 
rx_fixup() returns value other than 0 or 1 (e.g. 2).

This allows to simplify rx_fixup() functions of drivers who do complex 
processing there. Currently, drivers must process the last packet in a 
special way - leave it for usbnet to process. This is not easily possible 
when a driver (like the new cx82310_eth) needs to process packets that cross 
URB (and thus skb) boundaries. With this patch, the driver can process all 
packets in the skb and just return 2 at the end.

Also fix asix driver that was returning 2 at one place before this change 
(probably by mistake).

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-orig/drivers/net/usb/usbnet.c	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/usb/usbnet.c	2010-09-04 23:47:14.000000000 +0200
@@ -385,18 +385,24 @@ static int rx_submit (struct usbnet *dev
 
 static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 {
-	if (dev->driver_info->rx_fixup &&
-	    !dev->driver_info->rx_fixup (dev, skb))
-		goto error;
-	// else network stack removes extra byte if we forced a short packet
+	int fixup = 1;
 
-	if (skb->len)
-		usbnet_skb_return (dev, skb);
-	else {
-		netif_dbg(dev, rx_err, dev->net, "drop\n");
-error:
+	if (dev->driver_info->rx_fixup)
+		fixup = dev->driver_info->rx_fixup(dev, skb);
+
+	switch (fixup) {
+	case 1:	/* skb is correct */
+		if (skb->len) {
+			usbnet_skb_return(dev, skb);
+			break;
+		} else
+			netif_dbg(dev, rx_err, dev->net, "drop\n");
+		/* fall through */
+	case 0: /* skb is incorrect */
 		dev->net->stats.rx_errors++;
-		skb_queue_tail (&dev->done, skb);
+		/* fall through */
+	default: /* skb does not need processing */
+		skb_queue_tail(&dev->done, skb);
 	}
 }
 
--- linux-2.6.36-rc3-orig/drivers/net/usb/asix.c	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/usb/asix.c	2010-09-04 23:48:42.000000000 +0200
@@ -341,7 +341,7 @@ static int asix_rx_fixup(struct usbnet *
 				skb->data -= realignment;
 				skb_set_tail_pointer(skb, size);
 			}
-			return 2;
+			return 1;
 		}
 
 		if (size > dev->net->mtu + ETH_HLEN) {


-- 
Ondrej Zary
