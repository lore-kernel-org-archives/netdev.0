From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [2.6 patch] eepro100 resume patch
Date: Mon, 23 Jul 2007 09:44:51 +0200
Message-ID: <20070723074451.GA9169@elf.ucw.cz>
References: <20070714000151.GA31482@spacedout.fries.net> <46984CF0.8080700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Fries <david@fries.net>, NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:55619 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765014AbXGWQIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 12:08:13 -0400
Content-Disposition: inline
In-Reply-To: <46984CF0.8080700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 2007-07-13 21:11:28, Kok, Auke wrote:
> [adding netdev]
> 
> David Fries wrote:
> >When I did a software suspend to disk then resumed the Intel network
> >card using eepro100 driver would be unable to transmit packets.  I
> >tracked this down and found a register write after the print message
> >"DP83840 specific setup" which wasn't being executed when the system
> >was restored.  This fix moves that write and another write which
> >forces the link speed and duplex.
> >
> >After doing this work and preparing the patch I checked out the
> >mailing list only to find a patch that removes the eepro100.  I then
> >updated Kconfig, though I wonder why it didn't have a similar message
> >in it long time ago.
> >
> >I too had tried the e100 driver some time ago and it didn't work,
> 
> That argument is pretty useless right now. Please *test* e100 and *report 
> issues*. I recently did some very intensive suspend/resume testing (and 
> fixes) on e100 and I have yet to hear of any problems with it since... that 
> was 2.6.18 or so even.
> 
> >eepro100 did and I've been using it so long that I've almost forgotten
> >about that.  I just gave the e100 driver a try and I've been running
> >for about an hour now without any problems and it does resume after a
> >suspend to disk operation.
> >
> >Signed-off-by: David Fries <David@Fries.net>
> 
> I don't think I need to NAK this. I doubt that Jeff Garzik will apply this 
> in the first place. eepro100 is on it's way out, so let's focus on what 
> matters.

Well, I believe we should either remove eepro100 _now_ or fix issues
with it. "Keep it in the tree, and broken at the same time" is unnice.


> >@@ -743,20 +746,22 @@
> > 				   phys[(eeprom[7]>>8)&7]);
> > 		if (((eeprom[6]>>8) & 0x3f) == DP83840
> > 			||  ((eeprom[6]>>8) & 0x3f) == DP83840A) {
> >-			int mdi_reg23 = mdio_read(dev, eeprom[6] & 0x1f, 23) 
> >| 0x0422;
> >+			int mdi_reg23_orig = mdio_read(dev, eeprom[6] & 
> >0x1f, 23);
> >+			int mdi_reg23 = mdi_reg23_orig | 0x0422;
> > 			if (congenb)
> > 			  mdi_reg23 |= 0x0100;
> >-			printk(KERN_INFO"  DP83840 specific setup, setting 
> >register 23 to %4.4x.\n",
> >-				   mdi_reg23);
> >-			mdio_write(dev, eeprom[6] & 0x1f, 23, mdi_reg23);
> >+			/* Print the message here, write in speedo_resume, 
> >which
> >+			 * is called both on module load and from
> >+			 * eepro100_resume.
> >+			 */
> >+			printk(KERN_INFO"  DP83840 specific setup, setting 
> >register 23 to %4.4x, was %4.4x.\n",
> >+				   mdi_reg23, mdi_reg23_orig);
> > 		}
> > 		if ((option >= 0) && (option & 0x70)) {
> >+			/* Print here, write in speedo_resume. */
> > 			printk(KERN_INFO "  Forcing %dMbs %s-duplex 
> > 			operation.\n",
> > 				   (option & 0x20 ? 100 : 10),
> > 				   (option & 0x10 ? "full" : "half"));
> >-			mdio_write(dev, eeprom[6] & 0x1f, MII_BMCR,
> >-					   ((option & 0x20) ? 0x2000 : 0) |  
> >/* 100mbps? */
> >-					   ((option & 0x10) ? 0x0100 : 0)); 
> >/* Full duplex? */
> > 		}
> > 
> > 		/* Perform a system self-test. */
> >@@ -1050,6 +1055,24 @@
> > 	struct speedo_private *sp = netdev_priv(dev);
> > 	void __iomem *ioaddr = sp->regs;
> > 
> >+	/* DP83840 specific setup, moved here from from speedo_found1 because
> >+	 * it needs to called after resume, ie suspend to disk.
> >+	 * 07-11-2007 David Fries <david@fries.net>
> >+	 */
> >+	if (((sp->phy[0]>>8) & 0x3f) == DP83840
> >+		||  ((sp->phy[0]>>8) & 0x3f) == DP83840A) {
> >+		int mdi_reg23 = mdio_read(dev, sp->phy[0] & 0x1f, 23) | 
> >0x0422;
> >+		if (congenb)
> >+			mdi_reg23 |= 0x0100;
> >+		mdio_write(dev, sp->phy[0] & 0x1f, 23, mdi_reg23);
> >+	}
> >+	if ((sp->option >= 0) && (sp->option & 0x70)) {
> >+		mdio_write(dev, sp->phy[0] & 0x1f, MII_BMCR,
> >+			((sp->option & 0x20) ? 0x2000 : 0) | 	/* 100mbps? 
> >*/
> >+			((sp->option & 0x10) ? 0x0100 : 0)); /* Full duplex? 
> >*/
> >+	}
> >+
> >+
> > 	/* Start with a Tx threshold of 256 (0x..20.... 8 byte units). */
> > 	sp->tx_threshold = 0x01208000;
> > 
> >
> >
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
