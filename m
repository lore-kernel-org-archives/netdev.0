From: Stefan Rompf <srompf@isg.de>
Subject: Patch: link state detection for 8139too against 2.5.41
Date: Sat, 12 Oct 2002 01:55:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA764D8.FCDF34F8@isg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------69CFC4E010FA068A120E8BE6"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@mandrakesoft.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------69CFC4E010FA068A120E8BE6
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi Jeff,

attached you find a patch that enables link state detection for the
8139too driver. It applies cleanly against 2.5.41 and with some line
offset against 2.4.19.

I've written this stuff on a friends' computer using 2.4.18, so it is
only slightly tested.

Cheers, Stefan
--------------69CFC4E010FA068A120E8BE6
Content-Type: text/plain; charset=us-ascii;
 name="patch-linkstate-8139too-2.5.41"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-linkstate-8139too-2.5.41"

--- linux/drivers/net/8139too.c.orig	Tue Oct  1 09:05:46 2002
+++ linux/drivers/net/8139too.c	Thu Oct 10 00:37:37 2002
@@ -1534,9 +1534,16 @@
 				 struct rtl8139_private *tp,
 				 void *ioaddr)
 {
-	int mii_lpa;
+	int mii_lpa, mii_bmsr;
 
 	mii_lpa = mdio_read (dev, tp->phys[0], MII_LPA);
+	mii_bmsr = mdio_read(dev, tp->phys[0], MII_BMSR);
+
+	if (mii_bmsr & BMSR_LSTATUS && !netif_carrier_ok(dev)) {
+		netif_carrier_on(dev);
+	} else if (netif_carrier_ok(dev)) {
+		netif_carrier_off(dev);
+	}
 
 	if (!tp->mii.force_media && mii_lpa != 0xffff) {
 		int duplex = (mii_lpa & LPA_100FULL)
@@ -1563,7 +1570,7 @@
 		}
 	}
 
-	next_tick = HZ * 60;
+	next_tick = HZ * 3;
 
 	rtl8139_tune_twister (dev, tp);
 

--------------69CFC4E010FA068A120E8BE6--
