From: Timothy I Mattox <tmattox@engr.uky.edu>
Subject: Re: [PATCH] tulip, kernel 2.4.26-rc2, 3rd try
Date: Fri, 9 Apr 2004 16:39:01 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.43.0404091631060.19041-100000@skyhawk.ecc.engr.uky.edu>
References: <Pine.LNX.4.43.0404091538000.19041-100000@skyhawk.ecc.engr.uky.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tulip-devel@lists.sourceforge.net, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <Pine.LNX.4.43.0404091538000.19041-100000@skyhawk.ecc.engr.uky.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Attached is the patch with the netif_carrier_xxx() calls active
for the ADMtek Comet version of the tulip.
I tested pulling the cable & reconnecting it on both a laptop as well
as a desktop machine with a LNE100TX v4.1 and tulip_debug=2.
All appears to work as expected.

If you like, I can submit a seperate patch enabling netif_carrier_xxx()
in the rest of the tulip driver, but I don't have other flavors of
tulip cards to test on.  It looks like the calls are all there, just
that they are commented out.
-- 
Tim Mattox - tmattox@engr.uky.edu - http://homepage.mac.com/tmattox/
    http://aggregate.org/KAOS/ - http://advogato.org/person/tmattox/

On Fri, 9 Apr 2004, Timothy I Mattox wrote:
> OK, testing now...  I had the netif_carrier_xxx code commented out
> from seeing them commented out in the tulip_timer routine just a few
> lines above in the comet_timer() routine.
>
> On Fri, 9 Apr 2004, Jeff Garzik wrote:
> > Looks OK, but can you test without netif_carrier_xxx commented out?
> >
> > I would prefer to leave those active.
> >
> > 	Jeff

diff -Naur -p linux-2.4.26-rc2/drivers/net/tulip/ChangeLog linux-2.4.26-rc2-comet/drivers/net/tulip/ChangeLog
--- linux-2.4.26-rc2/drivers/net/tulip/ChangeLog	Fri Jun 13 10:51:35 2003
+++ linux-2.4.26-rc2-comet/drivers/net/tulip/ChangeLog	Fri Apr  9 15:08:44 2004
@@ -1,3 +1,11 @@
+2004-04-02  Tim Mattox  <tmattox at engr.uky.edu>
+
+	Add MII support for ADMtek Comet (Linksys LNE100TX v4.1 & others):
+	* tulip_core.c: add HAS_MII flag to COMET entry in tulip_tbl[]
+	* timer.c (comet_timer): add missing call to tulip_check_duplex()
+	and replace inl() calls with tulip_mdio_read() calls
+	Changes modeled after Donald Becker's tulip.c:v0.98 1/8/2004
+
 2002-09-18  Ryan Bradetich  <rbradetich@uswest.net>

 	tulip hppa support:
diff -Naur -p linux-2.4.26-rc2/drivers/net/tulip/timer.c linux-2.4.26-rc2-comet/drivers/net/tulip/timer.c
--- linux-2.4.26-rc2/drivers/net/tulip/timer.c	Fri Jun 13 10:51:35 2003
+++ linux-2.4.26-rc2-comet/drivers/net/tulip/timer.c	Fri Apr  9 15:37:32 2004
@@ -211,10 +211,16 @@ void comet_timer(unsigned long data)
 	if (tulip_debug > 1)
 		printk(KERN_DEBUG "%s: Comet link status %4.4x partner capability "
 			   "%4.4x.\n",
-			   dev->name, inl(ioaddr + 0xB8), inl(ioaddr + 0xC8));
+			   dev->name,
+			   tulip_mdio_read(dev, tp->phys[0], 1),
+			   tulip_mdio_read(dev, tp->phys[0], 5));
 	/* mod_timer synchronizes us with potential add_timer calls
 	 * from interrupts.
 	 */
+	if (tulip_check_duplex(dev) < 0)
+		{ netif_carrier_off(dev); }
+	else
+		{ netif_carrier_on(dev); }
 	mod_timer(&tp->timer, RUN_AT(next_tick));
 }

diff -Naur -p linux-2.4.26-rc2/drivers/net/tulip/tulip_core.c linux-2.4.26-rc2-comet/drivers/net/tulip/tulip_core.c
--- linux-2.4.26-rc2/drivers/net/tulip/tulip_core.c	Fri Apr  9 15:02:34 2004
+++ linux-2.4.26-rc2-comet/drivers/net/tulip/tulip_core.c	Fri Apr  9 15:08:44 2004
@@ -176,7 +176,7 @@ struct tulip_chip_table tulip_tbl[] = {

   /* COMET */
   { "ADMtek Comet", 256, 0x0001abef,
-	MC_HASH_ONLY | COMET_MAC_ADDR, comet_timer },
+	HAS_MII | MC_HASH_ONLY | COMET_MAC_ADDR, comet_timer },

   /* COMPEX9881 */
   { "Compex 9881 PMAC", 128, 0x0001ebef,
