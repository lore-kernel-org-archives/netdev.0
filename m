From: Petr Konecny <pekon@fi.muni.cz>
Subject: Re: PATCH: netpoll with xircom_cb
Date: Thu, 14 Oct 2004 16:40:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <qww4qkxs6qd.fsf@decibel.fi.muni.cz>
References: <qwwd5zmrrpt.fsf@decibel.fi.muni.cz>
	<20041014124140.GI2646@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arjan van de Ven <arjanv@redhat.com>
In-Reply-To: <20041014124140.GI2646@devserv.devel.redhat.com> (Arjan van de
 Ven's message of "Thu, 14 Oct 2004 14:41:40 +0200")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Arjan> On Thu, Oct 14, 2004 at 03:52:46AM +0200, Petr Konecny wrote:
 >> Hi,
 >> 
 >> I have a headless computer with xircom pcmcia card and needed netconsole
 >> on it. After looking around in other drivers I concocted this patch.  It
 >> survived light testing. I have no documentation for the hw, so it maybe
 >> totally bogus. What do you think ?

 Arjan> looks correct to me,however I have one remark

 >> +#ifdef CONFIG_NET_POLL_CONTROLLER
 >> +static void xircom_poll_controller(struct net_device *dev)
 >> +{
 >> +	disable_irq(dev->irq);
 >> +	xircom_interrupt(dev->irq, dev, NULL);
 >> +	enable_irq(dev->irq);
 >> +}
 >> +#endif
AFAICS all other drivers call the interrupt routine. They differ only in
disabling interrupts: some use local_irq_disable, some don't disable it
at all, because of a spinlock taken in the interrupt routine. Perhaps
the latter would work with xircom_cb.

 Arjan> I think you want to call investigate_read_descriptor() and
 Arjan> investigate_read_descriptor() instead of this.
But this works too, at least with netconsole. Patch on top of the last
one.

                                             Petr

--- 2.6old/drivers/net/tulip/xircom_cb.c	2004-10-13 18:49:59.000000000 -0700
+++ 2.6/drivers/net/tulip/xircom_cb.c	2004-10-14 07:55:08.000000000 -0700
@@ -509,9 +509,17 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xircom_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	xircom_interrupt(dev->irq, dev, NULL);
-	enable_irq(dev->irq);
+	struct xircom_private *card = netdev_priv(dev);
+	int i;
+
+	enter("xircom_poll");
+	spin_lock(&card->lock);
+	for (i=0;i<NUMDESCRIPTORS;i++) 
+		investigate_write_descriptor(dev,card,i,bufferoffsets[i]);
+	for (i=0;i<NUMDESCRIPTORS;i++) 
+		investigate_read_descriptor(dev,card,i,bufferoffsets[i]);
+	spin_unlock(&card->lock);
+	leave("xircom_poll");
 }
 #endif
 
