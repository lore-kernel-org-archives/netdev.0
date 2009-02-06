From: Ilkka Virta <itvirta@iki.fi>
Subject: Soft lockup in sungem on Netra AC200 when switching interface up
Date: Fri, 6 Feb 2009 13:29:02 +0200
Message-ID: <20090206112902.GS4362@tango.lnet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.lnet.fi ([86.50.38.234]:50225 "EHLO tango.lnet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbZBFL42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 06:56:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What ho, chaps

The sungem network driver seems to be broken with the integrated
Ethernet ports of a Sun Netra T1 AC200. On that machine, switching the
interface up when link is up leads to a soft lockup. However,
switching the interface up with no link, and only then connecting the
cable works; as does the same driver on seemingly same hardware on a
Sun Blade 1000.

lspci doesn't show any real differences between the gems on the Netra
and on the Blade, both are these: 
0000:00:05.1 Ethernet controller [0200]: Sun Microsystems Computer
             Corp. RIO 10/100 Ethernet [eri] [108e:1101] (rev 01)

Earlier reports of the same problem indicate that the driver was
broken by commit bea3348eef27e6044b6161fd04c3152215f96411 in around
2.6.24, but the problem still exists in 2.6.28.

http://kerneltrap.org/mailarchive/linux-kernel/2008/8/7/2856094
http://bugzilla.kernel.org/show_bug.cgi?id=10309
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=508151

Now, I didn't find any ready-made cure for this, so I poked around the
driver a bit to see what happens. What follows is very much only
guesswork, since I don't really know anything about Linux network
drivers.

In the lockup situation the driver seems to go off in an eternal storm
of interrupts right after calling request_irq(). It doesn't actually
do anything interesting in the interrupt handler. Since connecting the link
afterwards works, something later in initialization must fix this.

Looking at gem_do_start() and gem_open(), it seems that the only thing
done while opening the device after the request_irq(), is a call to
napi_enable().

I don't know what the ordering requirements are for the
initialization, but I boldly tried to move the napi_enable() call
inside gem_do_start() before the link state is checked and interrupts
subsequently enabled, and it seems to work for me. Doesn't even break
anything too obvious...

Any ideas on how this really should be fixed?

--- linux-2.6.28.2/drivers/net/sungem.c.orig	2009-01-25 02:42:07.000000000 +0200
+++ linux-2.6.28.2/drivers/net/sungem.c	2009-02-05 20:46:23.000000000 +0200
@@ -2222,6 +2222,8 @@ static int gem_do_start(struct net_devic
 
 	gp->running = 1;
 
+	napi_enable(&gp->napi);
+
 	if (gp->lstate == link_up) {
 		netif_carrier_on(gp->dev);
 		gem_set_link_modes(gp);
@@ -2239,6 +2241,8 @@ static int gem_do_start(struct net_devic
 		spin_lock_irqsave(&gp->lock, flags);
 		spin_lock(&gp->tx_lock);
 
+		napi_disable(&gp->napi);
+
 		gp->running =  0;
 		gem_reset(gp);
 		gem_clean_rings(gp);
@@ -2339,8 +2343,6 @@ static int gem_open(struct net_device *d
 	if (!gp->asleep)
 		rc = gem_do_start(dev);
 	gp->opened = (rc == 0);
-	if (gp->opened)
-		napi_enable(&gp->napi);
 
 	mutex_unlock(&gp->pm_mutex);
 
@@ -2477,8 +2479,6 @@ static int gem_resume(struct pci_dev *pd
 
 		/* Re-attach net device */
 		netif_device_attach(dev);
-
-		napi_enable(&gp->napi);
 	}
 
 	spin_lock_irqsave(&gp->lock, flags);

-- 
Ilkka Virta / itvirta at iki dot fi / ilkkachu@IRCNet
 ()  ascii ribbon campaign - against HTML mail and attachments in 
 /\                          closed file formats
