From: Timothy I Mattox <tmattox@engr.uky.edu>
Subject: [PATCH] tulip, kernel 2.4.26-rc1
Date: Fri, 2 Apr 2004 15:22:30 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0404021455140.4496-100000@seahawk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tulip-users@lists.sourceforge.net, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a patch for the tulip driver found in kernel 2.4.26-rc1
This adds MII functionality to the ADMtek Comet flavor of the tulip,
specifically, the ability to detect and report the link status with MII.

I've tested on several Linksys LNE100TX v4.1 PCI cards, as well as on
an HP Pavilion N5475 laptop with a built-in NIC that is detected as
this same model of chip.

This patch was modeled after Donald Becker's tulip.c:v0.98 1/8/2004, but
the specific bits from his driver have been there for about two years.

Please apply to 2.4 mainline.  If this is accepted, I will convert & 
test it for the 2.6 kernel series as well.
-- 
Tim Mattox - tmattox at engr.uky.edu - http://homepage.mac.com/tmattox/
    http://aggregate.org/KAOS/ - http://advogato.org/person/tmattox/


diff -Naur -p linux-2.4.26-rc1/drivers/net/tulip/ChangeLog linux-2.4.26-rc1-comet/drivers/net/tulip/ChangeLog
--- linux-2.4.26-rc1/drivers/net/tulip/ChangeLog	Fri Jun 13 10:51:35 2003
+++ linux-2.4.26-rc1-comet/drivers/net/tulip/ChangeLog	Fri Apr  2 14:58:31 2004
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
diff -Naur -p linux-2.4.26-rc1/drivers/net/tulip/timer.c linux-2.4.26-rc1-comet/drivers/net/tulip/timer.c
--- linux-2.4.26-rc1/drivers/net/tulip/timer.c	Fri Jun 13 10:51:35 2003
+++ linux-2.4.26-rc1-comet/drivers/net/tulip/timer.c	Fri Apr  2 14:36:51 2004
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
+		{ /* netif_carrier_off(dev); */ }
+	else
+		{ /* netif_carrier_on(dev); */ }
 	mod_timer(&tp->timer, RUN_AT(next_tick));
 }
 
diff -Naur -p linux-2.4.26-rc1/drivers/net/tulip/tulip_core.c linux-2.4.26-rc1-comet/drivers/net/tulip/tulip_core.c
--- linux-2.4.26-rc1/drivers/net/tulip/tulip_core.c	Fri Apr  2 14:31:27 2004
+++ linux-2.4.26-rc1-comet/drivers/net/tulip/tulip_core.c	Fri Apr  2 14:36:38 2004
@@ -176,7 +176,7 @@ struct tulip_chip_table tulip_tbl[] = {
 
   /* COMET */
   { "ADMtek Comet", 256, 0x0001abef,
-	MC_HASH_ONLY | COMET_MAC_ADDR, comet_timer },
+	HAS_MII | MC_HASH_ONLY | COMET_MAC_ADDR, comet_timer },
 
   /* COMPEX9881 */
   { "Compex 9881 PMAC", 128, 0x0001ebef,
