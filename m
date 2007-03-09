From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: netconsole system freeze when cable unplugged
Date: Fri, 9 Mar 2007 21:42:43 +0100
Message-ID: <20070309204243.GA28441@electric-eye.fr.zoreil.com>
References: <45F1B6FD.1060902@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59485 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965817AbXCIUnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 15:43:20 -0500
Content-Disposition: inline
In-Reply-To: <45F1B6FD.1060902@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Arlott <simon@fire.lp0.eu> :
> When I unplug the cable the system just stops responding to anything, 
> at all. No message is printed to the console when the cable is plugged 
> back in.

rtl8139_interrupt (spin_lock(&tp->lock))
-> rtl8139_weird_interrupt
   -> rtl_check_media
      -> mii_check_media (printk(KERN_INFO "%s: link down\n", ...))
         [netpoll stuff here]
         -> rtl8139_poll_controller
            -> rtl8139_interrupt
               *deadlock*

See below for my random stuff of the day. Feel free to open a PR at
bugzilla.kernel.org if the issue does not go away.

--------8<-----------------------------------------------------------------

8139too: netconsole breakage when link changes

rtl8139_interrupt is not supposed to be reentrant but its link
management part can emit printk.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 99304b2..64467ad 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2215,9 +2215,16 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
  */
 static void rtl8139_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	struct rtl8139_private *tp = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+
+	rc = spin_trylock_irqsave(&tp->lock, flags);
+	if (!rc)
+		return;
+	spin_unlock(&tp->lock);
 	rtl8139_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	local_irq_restore(flags);
 }
 #endif
 
