From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: link state detection for 8139too against 2.4.20rc2 / 2.5
Date: Sun, 24 Nov 2002 13:47:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE0CA4C.730699FC@isg.de>
References: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com> <3DA96BCC.B2589AC0@isg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------E38573049F6802A399D73CEF"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------E38573049F6802A399D73CEF
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

> > Uhmmm, you don't need to poll with the rtl8139.  There is a link change
> > interrupt.  Here is the recently added from rtl8139.c
> 
> ok, I'll try this next time I have access to the card.

...that was some days ago. I've seen that Jeff is enhancing the MII
interface library, so I used the functions provided there. Patch is
against 2.4.20rc2 and 2.5 with some offset. Please apply if it looks
good.

Cheers, Stefan
--------------E38573049F6802A399D73CEF
Content-Type: text/plain; charset=us-ascii;
 name="patch-ls-8139too"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-ls-8139too"

--- linux/drivers/net/8139too.c.old	2002-11-19 00:32:04.000000000 +0100
+++ linux/drivers/net/8139too.c	2002-11-21 22:32:39.000000000 +0100
@@ -1335,18 +1335,7 @@
 	struct rtl8139_private *tp = dev->priv;
 
 	if (tp->phys[0] >= 0) {
-		u16 mii_lpa = mdio_read(dev, tp->phys[0], MII_LPA);
-		if (mii_lpa == 0xffff)
-			;					/* Not there */
-		else if ((mii_lpa & LPA_100FULL) == LPA_100FULL
-				 || (mii_lpa & 0x00C0) == LPA_10FULL)
-			tp->mii.full_duplex = 1;
-
-		printk (KERN_INFO"%s: Setting %s%s-duplex based on"
-				" auto-negotiated partner ability %4.4x.\n",
-		        dev->name, mii_lpa == 0 ? "" :
-				(mii_lpa & 0x0180) ? "100mbps " : "10mbps ",
-			tp->mii.full_duplex ? "full" : "half", mii_lpa);
+		mii_check_media(&tp->mii, 1, 1);
 	}
 }
 
@@ -1994,18 +1983,7 @@
 
 	if ((status & RxUnderrun) && link_changed &&
 	    (tp->drv_flags & HAS_LNK_CHNG)) {
-		/* Really link-change on new chips. */
-		int lpar = RTL_R16 (NWayLPAR);
-		int duplex = (lpar & LPA_100FULL) || (lpar & 0x01C0) == 0x0040
-				|| tp->mii.force_media;
-		if (tp->mii.full_duplex != duplex) {
-			tp->mii.full_duplex = duplex;
-#if 0
-			RTL_W8 (Cfg9346, Cfg9346_Unlock);
-			RTL_W8 (Config1, tp->mii.full_duplex ? 0x60 : 0x20);
-			RTL_W8 (Cfg9346, Cfg9346_Lock);
-#endif
-		}
+		rtl_check_media(dev);
 		status &= ~RxUnderrun;
 	}
 


--------------E38573049F6802A399D73CEF--
