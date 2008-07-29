From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH-2.4] via-rhine: fix duplex detection issue
Date: Wed, 30 Jul 2008 00:08:02 +0200
Message-ID: <20080729220802.GA25729@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2268 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754328AbYG2WII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 18:08:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roger,

I've ran into a nasty problem on 2.4 involving via-rhine and bonding.
The symptom was that after plugging a link to one of the interfaces
(all VT6105M, it's on an ALIX motherboard), sometimes the data rate
was horribly slow and unstable, just as if there was a duplex
mismatch. But ethtool reported full duplex, and so did the other
end. Interestingly, 2.6 did not have any such problem.

I found that enabling debug=3 would report enough useful information
without pollution (kudos for the useful debugging info BTW). I noticed
that sometimes during a link state change, there was no indication of
a duplex change in the logs. After almost all plug in/out, a message
indicated switching to half duplex (plug out) or full duplex (plug in).
And I never caught a missing message for the non-bonded interfaces.
The driver is pretty clear on this, the duplex is enabled after the
printk, so no "full duplex" message, duplex never enabled on the NIC,
confirming the suspected duplex mismatch.

I finally found the racy cause of this problem : the function
via_rhine_check_duplex() is called from the link check timer to
detect if the link state has changed. It uses mii_if.full_duplex
as a cache for previous state. But with bonding regularly calling
netdev_get_settings(), we have mii_if.full_duplex magically change
below us, which implies that sometimes, via_rhine_check_duplex()
thinks the link was already set to full duplex while it had not
been yet.

I looked at how 2.6 managed the issue and found that it relies on
a much cleaner approach, delivering interrupts on link changes,
thus not relying on timers nor caches.

So I came to the conclusion that using a more reliable cache was
needed, and I added the field in the struct netdev_private. I also
took this opportunity to make use of mii_check_media() instead
of sparse calls to mdio_read() followed by the MII magics, as
mii_check_media() does all the correct netdev_carrier_on/off
work for us. This allowed me to completely get rid of the
mii_status member of the struct netdev_private so that its size
finally remains unchanged.

With the above changes applied, I got all problems definitely
solved (and all link transitions were correctly detected).

Now two options are left to me :

  - try to backport the 2.6 driver to 2.4. It seems very much
    cleaner, seems to take a lot more care about race conditions
    and also provides immediate link state change detection, as
    opposed to the 10 seconds in 2.4 (I've patched it to use
    200ms with bonding but that's another story). The code does
    not look really complex, I don't think it should take much
    time, but bugs may be introduced in tricky areas.

  - just apply the patch below (after cleaning up, it's the
    result of mainline and my debug tree). It would simply
    fix the problem without touching other areas, maintaining
    the risk of regressions very low, though possibly leaving
    other bugs or race conditions still open.

The user that I am suggest using #1, but the maintainer that
I am prefers #2. So I think I'll just go with the patch for
the specific issue, and only consider the backport for my
personal trees the day I have time to spend on this. That way
we get one small patch for one small issue.

I'd like to get your opinion on this, and to check with you
if you are basically OK with that change in principle.

Thanks in advance,
Willy


--- linux-2.4.36/drivers/net/via-rhine.c	2006-06-19 09:01:32 +0200
+++ linux-2.4.36-rhine/drivers/net/via-rhine.c	2008-07-29 00:21:36 +0200
@@ -530,7 +530,7 @@ struct netdev_private {
 	/* MII transceiver section. */
 	unsigned char phys[MAX_MII_CNT];			/* MII device addresses. */
 	unsigned int mii_cnt;			/* number of MIIs found, but only the first one is used */
-	u16 mii_status;						/* last read MII status */
+	int last_duplex;					/* last checked duplex */
 	struct mii_if_info mii_if;
 };
 
@@ -808,11 +808,11 @@ static int __devinit via_rhine_init_one 
 	/* The lower four bits are the media type. */
 	if (option > 0) {
 		if (option & 0x220)
-			np->mii_if.full_duplex = 1;
+			np->last_duplex = np->mii_if.full_duplex = 1;
 		np->default_port = option & 15;
 	}
 	if (card_idx < MAX_UNITS  &&  full_duplex[card_idx] > 0)
-		np->mii_if.full_duplex = 1;
+		np->last_duplex = np->mii_if.full_duplex = 1;
 
 	if (np->mii_if.full_duplex) {
 		printk(KERN_INFO "%s: Set to forced full duplex, autonegotiation"
@@ -859,7 +859,7 @@ static int __devinit via_rhine_init_one 
 	/* Allow forcing the media type. */
 	if (option > 0) {
 		if (option & 0x220)
-			np->mii_if.full_duplex = 1;
+			np->last_duplex = np->mii_if.full_duplex = 1;
 		np->default_port = option & 0x3ff;
 		if (np->default_port & 0x330) {
 			/* FIXME: shouldn't someone check this variable? */
@@ -1058,6 +1058,7 @@ static void init_registers(struct net_de
 	np->tx_thresh = 0x20;
 	np->rx_thresh = 0x60;			/* Written in via_rhine_set_rx_mode(). */
 	np->mii_if.full_duplex = 0;
+	np->last_duplex = 0;
 
 	if (dev->if_port == 0)
 		dev->if_port = np->default_port;
@@ -1119,7 +1120,7 @@ static void mdio_write(struct net_device
 			if (value & 0x9000)			/* Autonegotiation. */
 				np->mii_if.force_media = 0;
 			else
-				np->mii_if.full_duplex = (value & 0x0100) ? 1 : 0;
+				np->last_duplex = np->mii_if.full_duplex = (value & 0x0100) ? 1 : 0;
 			break;
 		case MII_ADVERTISE:
 			np->mii_if.advertising = value;
@@ -1184,20 +1186,20 @@ static void via_rhine_check_duplex(struc
 {
 	struct netdev_private *np = dev->priv;
 	long ioaddr = dev->base_addr;
-	int mii_lpa = mdio_read(dev, np->phys[0], MII_LPA);
-	int negotiated = mii_lpa & np->mii_if.advertising;
-	int duplex;
 
-	if (np->mii_if.force_media  ||  mii_lpa == 0xffff)
+	if (np->mii_if.force_media)
 		return;
-	duplex = (negotiated & 0x0100) || (negotiated & 0x01C0) == 0x0040;
-	if (np->mii_if.full_duplex != duplex) {
-		np->mii_if.full_duplex = duplex;
+
+	mii_check_media(&np->mii_if, debug, 0);
+
+	if (np->last_duplex != np->mii_if.full_duplex) {
+		np->last_duplex = np->mii_if.full_duplex;
 		if (debug)
 			printk(KERN_INFO "%s: Setting %s-duplex based on MII #%d link"
 				   " partner capability of %4.4x.\n", dev->name,
-				   duplex ? "full" : "half", np->phys[0], mii_lpa);
-		if (duplex)
+				   np->mii_if.full_duplex ? "full" : "half", np->phys[0],
+			           mdio_read(dev, np->phys[0], MII_LPA));
+		if (np->mii_if.full_duplex)
 			np->chip_cmd |= CmdFDuplex;
 		else
 			np->chip_cmd &= ~CmdFDuplex;
@@ -1223,16 +1224,6 @@ static void via_rhine_timer(unsigned lon
 
 	via_rhine_check_duplex(dev);
 
-	/* make IFF_RUNNING follow the MII status bit "Link established" */
-	mii_status = mdio_read(dev, np->phys[0], MII_BMSR);
-	if ( (mii_status & BMSR_LSTATUS) != (np->mii_status & BMSR_LSTATUS) ) {
-		if (mii_status & BMSR_LSTATUS)
-			netif_carrier_on(dev);
-		else
-			netif_carrier_off(dev);
-	}
-	np->mii_status = mii_status;
-
 	spin_unlock_irq (&np->lock);
 
 	np->timer.expires = jiffies + next_tick;


