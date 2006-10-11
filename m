From: Amol Lad <amol@verismonetworks.com>
Subject: [PATCH 1/4] drivers/net/depca.c: Replacing yield() with a better
	alternative
Date: Wed, 11 Oct 2006 18:37:58 +0530
Message-ID: <1160572078.19143.345.camel@amol.verismonetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel Janitors <kernel-janitors@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.verismonetworks.com ([164.164.99.228]:8941 "EHLO
	mail01.verismonetworks.com") by vger.kernel.org with ESMTP
	id S1751270AbWJKNEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 09:04:37 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 2.6, the semantics of calling yield() changed from "sleep for a
bit" to "I really don't want to run for a while".  This matches POSIX
better, but there's a lot of drivers still using yield() when they mean
cond_resched(), schedule() or even schedule_timeout().

For this driver schedule_timeout_interruptible seems to be a better
alternative

Tested compile only

Signed-off-by: Amol Lad <amol@verismonetworks.com>
---
diff -uprN -X linux-2.6.19-rc1-orig/Documentation/dontdiff linux-2.6.19-rc1-orig/drivers/net/depca.c linux-2.6.19-rc1/drivers/net/depca.c
--- linux-2.6.19-rc1-orig/drivers/net/depca.c	2006-10-05 14:00:47.000000000 +0530
+++ linux-2.6.19-rc1/drivers/net/depca.c	2006-10-11 17:57:02.000000000 +0530
@@ -738,7 +738,7 @@ static int __init depca_hw_init (struct 
 	   interrupts. For now we will always get a DMA error. */
 	if (dev->irq < 2) {
 		unsigned char irqnum;
-		unsigned long irq_mask, delay;
+		unsigned long irq_mask;
 
 		irq_mask = probe_irq_on();
 
@@ -767,9 +767,7 @@ static int __init depca_hw_init (struct 
 		/* Trigger an initialization just for the interrupt. */
 		outw(INEA | INIT, DEPCA_DATA);
 
-		delay = jiffies + HZ/50;
-		while (time_before(jiffies, delay))
-			yield();
+		schedule_timeout_interruptible(jiffies + HZ/50);
 
 		irqnum = probe_irq_off(irq_mask);
 


