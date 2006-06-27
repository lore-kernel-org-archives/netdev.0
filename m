From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 21:47:04 +0200
Message-ID: <200606272147.04477.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606271831.02108.mb@bu3sch.de> <20060627193259.GE1207@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:18648
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932536AbWF0TrK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 15:47:10 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060627193259.GE1207@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 21:33, John W. Linville wrote:
> On Tue, Jun 27, 2006 at 06:31:01PM +0200, Michael Buesch wrote:
> > On Tuesday 27 June 2006 18:12, Jeff Garzik wrote:
> > > Michael Buesch wrote:
> > > > So, I will submit a patch to lower the udelay(10) to udelay(1)
> > > > and we can close the discussion? ;)
> > > 
> > > No, that totally avoids my point.  Your "otherwise idle machine" test is 
> > > probably nowhere near worst case in the field, for loops that can 
> > > potentially lock the CPU for a long time upon hardware fault.  And then 
> > > there are the huge delays in specific functions that I pointed out...
> > 
> > wtf are you requesting from me?
> > 1) I proved you that the loop does only spin _once_ or even _less_.
> > 2) If the hardware is faulty, the user must replace it.
> >    Because, if the hardware is faulty, it can crash the whole
> >    machine anyway, obviously.
> > 
> > 3) There is no "huge delay". I proved it with my logs.
> >    -> No CPU hog => Nothing to fix.
> 
> Michael,
> 
> I think Jeff's concern is that by using udelay you are busy-waiting.
> And, the for loop limit of 100000 means you could freeze the kernel
> for up to a whole second.  Granted that this won't happen very often

s/very often/ever/

It won't happen, as long as the driver is not buggy, or the device
is hardware broken. So, if it happens, something has to be fixed.
In fact, it did happen _never_ for me.
If it triggers, the device does not work _at all_ anyway.

> and in the grand scheme of things a second isn't all _that_ long,
> but still it would be better to avoid a delay like that -- a second
> could be the time it takes to avoid a meltdown at the nuclear power
> plant. :-)
> 
> Could you not use msleep instead of udelay (and scale the for loop
> appropriately)?  What would be the problem with that?  It would get
> rid of the busy waiting.

Becauses it horribly _increases_ the delay.
We "spin" for _at most_ 10 usecs here. Please always remember that.
We are talking about a 10 usec delay here. And I already sent a
patch to even reduce this to under 10 usec.

> To be fair, this code was already in the driver and was only being
> moved by this patch.  Still, what better time to fix it than now? :-)

If it ain't broken, don't fix it.

> I'll go ahead and reshuffle wireless-2.6 to drop this patch.  A new
> patch that passes muster w/ Jeff will be most welcome! :-)

A new patch won't appear, as there is no problem with this
delay.
Please don't drop anything and apply the following patch on top
of it:

--

Microoptimization:
This reduces the udelay in bcm43xx_mac_suspend.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-27 17:47:24.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-27 17:53:29.000000000 +0200
@@ -2328,7 +2328,7 @@
 			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 			if (tmp & BCM43xx_IRQ_READY)
 				goto out;
-			udelay(10);
+			udelay(1);
 		}
 		printkl(KERN_ERR PFX "MAC suspend failed\n");
 	}


-- 
Greetings Michael.
