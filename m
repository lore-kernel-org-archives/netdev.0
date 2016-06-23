From: Soohoon Lee <Soohoon.Lee@f5.com>
Subject: [ PATCH] usbnet.c mtu change needs to stop RX
Date: Thu, 23 Jun 2016 18:43:35 +0000
Message-ID: <0ffe756fb77249c6bcc751c423590827@seaexchmbx01.olympus.F5Net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "oneukum@suse.com" <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.f5.com ([208.85.209.139]:64827 "EHLO mail.f5.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832AbcFWSxP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 14:53:15 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When MTU is changed unlink_urbs() flushes RX Q but mean while usbnet_bh() can fill up the Q at the same time.
Depends on which HCD is down there unlink takes long time then the flush never ends.


diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 61ba464..e03e3e6 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -708,6 +708,7 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
        int                     count = 0;
 
        spin_lock_irqsave (&q->lock, flags);
+       usbnet_pause_rx(dev);
        while (!skb_queue_empty(q)) {
                struct skb_data         *entry;
                struct urb              *urb;
@@ -742,6 +743,7 @@ found:
                usb_put_urb(urb);
                spin_lock_irqsave(&q->lock, flags);
        }
+       usbnet_resume_rx(dev);
        spin_unlock_irqrestore (&q->lock, flags);
        return count;
 }
@@ -1509,6 +1511,7 @@ static void usbnet_bh (unsigned long param)
                   netif_device_present (dev->net) &&
                   netif_carrier_ok(dev->net) &&
                   !timer_pending (&dev->delay) &&
+                  !test_bit (EVENT_RX_PAUSED, &dev->flags) &&
                   !test_bit (EVENT_RX_HALT, &dev->flags)) {
                int     temp = dev->rxq.qlen;
