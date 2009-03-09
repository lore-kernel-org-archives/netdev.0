From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 3c59x: shared interrupt problem
Date: Mon, 9 Mar 2009 16:49:27 -0700
Message-ID: <20090309164927.6eb12aff@nehalam>
References: <20090309224253.135220@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Gerhard Pircher" <gerhard_pircher@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbZCIXtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 19:49:31 -0400
In-Reply-To: <20090309224253.135220@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 Mar 2009 23:42:53 +0100
"Gerhard Pircher" <gerhard_pircher@gmx.net> wrote:

> Hi!
> 
> Large network transfers fail on my machine (with kernel versions
> >v2.6.26) with the kernel oops below. eth0 (3c59x driver) normally
> shares its IRQ line with 3 OHCI USB ports (IRQ 7), as the excerpt of
> /proc/interrupt shows. Removing USB support from the kernel makes it
> work again. I wasn't able to do a full git bisect run yet, as v2.6.27
> didn't produce a bootable kernel image for my machine. The machine is
> an AmigaOne PowerPC G4 with an onboard 3c920 network chip.
> 
> Any idea?

Does this help, it looks like boomerang_interrupt was not doing
shared irq stuff correctly.

--- a/drivers/net/3c59x.c	2009-03-09 16:07:13.372670015 -0700
+++ b/drivers/net/3c59x.c	2009-03-09 16:08:50.214357441 -0700
@@ -2301,6 +2301,7 @@ boomerang_interrupt(int irq, void *dev_i
 	void __iomem *ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
+	int handled = 0;
 
 	ioaddr = vp->ioaddr;
 
@@ -2323,6 +2324,7 @@ boomerang_interrupt(int irq, void *dev_i
 			printk(KERN_DEBUG "boomerang_interrupt(1): status = 0xffff\n");
 		goto handler_exit;
 	}
+	handled = 1;
 
 	if (status & IntReq) {
 		status |= vp->deferred;
@@ -2417,7 +2419,7 @@ boomerang_interrupt(int irq, void *dev_i
 			   dev->name, status);
 handler_exit:
 	spin_unlock(&vp->lock);
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(handled);
 }
 
 static int vortex_rx(struct net_device *dev)

