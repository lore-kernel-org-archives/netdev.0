From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [2.6 PATCH]: Fix deadlock in driver 3c574_cs.c
Date: Wed, 3 Dec 2003 12:26:02 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0312031207430.29582@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0311271114010.2966@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dahinds@users.sourceforge.net, akpm@digeo.com, jgarzik@pobox.com
In-Reply-To: <Pine.LNX.4.58.0311271114010.2966@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I already sent a report about this to linux-net earlier, but I guess it
went unnoticed due to thanksgiving...

The deadlock occurs when update_stats() is called from el3_interrupt(),
which already holds the lp->window_lock. The patch below fixes this
behavior.

Thanks,
Ville

===== drivers/net/pcmcia/3c574_cs.c 1.25 vs edited =====
--- 1.25/drivers/net/pcmcia/3c574_cs.c	Sat Sep  6 22:50:44 2003
+++ edited/drivers/net/pcmcia/3c574_cs.c	Thu Nov 27 10:26:34 2003
@@ -1092,8 +1092,12 @@
 {
 	struct el3_private *lp = (struct el3_private *)dev->priv;

-	if (netif_device_present(dev))
+	if (netif_device_present(dev)) {
+		unsigned long flags;
+		spin_lock_irqsave(&lp->window_lock, flags);
 		update_stats(dev);
+		spin_unlock_irqrestore(&lp->window_lock, flags);
+	}
 	return &lp->stats;
 }

@@ -1105,7 +1109,6 @@
 {
 	struct el3_private *lp = (struct el3_private *)dev->priv;
 	ioaddr_t ioaddr = dev->base_addr;
-	unsigned long flags;
 	u8 rx, tx, up;

 	DEBUG(2, "%s: updating the statistics.\n", dev->name);
@@ -1113,8 +1116,6 @@
 	if (inw(ioaddr+EL3_STATUS) == 0xffff) /* No card. */
 		return;

-	spin_lock_irqsave(&lp->window_lock, flags);
-
 	/* Unlike the 3c509 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
@@ -1139,7 +1140,6 @@
 	lp->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);

 	EL3WINDOW(1);
-	spin_unlock_irqrestore(&lp->window_lock, flags);
 }

 static int el3_rx(struct net_device *dev, int worklimit)
@@ -1281,6 +1281,8 @@
 	DEBUG(2, "%s: shutting down ethercard.\n", dev->name);

 	if (DEV_OK(link)) {
+		unsigned long flags;
+
 		/* Turn off statistics ASAP.  We update lp->stats below. */
 		outw(StatsDisable, ioaddr + EL3_CMD);

@@ -1290,8 +1292,9 @@

 		/* Note: Switching to window 0 may disable the IRQ. */
 		EL3WINDOW(0);
-
+		spin_lock_irqsave(&lp->window_lock, flags);
 		update_stats(dev);
+		spin_unlock_irqrestore(&lp->window_lock, flags);
 	}

 	link->open--;

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
