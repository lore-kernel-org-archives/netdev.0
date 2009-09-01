From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] WARNING: some request_irq() failures ignored in el2_open()
Date: Tue, 01 Sep 2009 18:24:53 +0200
Message-ID: <4A9D4AD5.1010404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:33708 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbZIAQTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:19:09 -0400
Received: by ewy2 with SMTP id 2so96879ewy.17
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 09:19:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Request_irq() may fail in different ways, handle accordingly.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Don't we have to do something like this? 

diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index 134638a..81c148a 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -383,7 +383,7 @@ out:
 static int
 el2_open(struct net_device *dev)
 {
-    int retval = -EAGAIN;
+    int retval;
 
     if (dev->irq < 2) {
 	int irqlist[] = {5, 9, 3, 4, 0};
@@ -391,7 +391,8 @@ el2_open(struct net_device *dev)
 
 	outb(EGACFR_NORM, E33G_GACFR);	/* Enable RAM and interrupts. */
 	do {
-	    if (request_irq (*irqp, NULL, 0, "bogus", dev) != -EBUSY) {
+	    retval = request_irq(*irqp, NULL, 0, "bogus", dev);
+	    if (retval >= 0) {
 		/* Twinkle the interrupt, and check if it's seen. */
 		unsigned long cookie = probe_irq_on();
 		outb_p(0x04 << ((*irqp == 9) ? 2 : *irqp), E33G_IDCFR);
@@ -400,11 +401,14 @@ el2_open(struct net_device *dev)
 		    && ((retval = request_irq(dev->irq = *irqp,
 		    eip_interrupt, 0, dev->name, dev)) == 0))
 		    break;
+	    } else {
+		    if (retval != -EBUSY)
+			    return reval;
 	    }
 	} while (*++irqp);
 	if (*irqp == 0) {
 	    outb(EGACFR_IRQOFF, E33G_GACFR);	/* disable interrupts. */
-	    return retval;
+	    return -EAGAIN;
 	}
     } else {
 	if ((retval = request_irq(dev->irq, eip_interrupt, 0, dev->name, dev))) {
