From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Fri, 25 Sep 2009 15:02:41 +0200
Message-ID: <200909251502.42014.rjw@sisk.pl>
References: <Pine.LNX.4.44L0.0909250038300.14463-100000@netrider.rowland.org> <200909251432.30738.rjw@sisk.pl> <20090925125616.GA20863@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:52370 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbZIYNBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 09:01:43 -0400
In-Reply-To: <20090925125616.GA20863@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 September 2009, Anton Vorontsov wrote:
> On Fri, Sep 25, 2009 at 02:32:30PM +0200, Rafael J. Wysocki wrote:
> > On Friday 25 September 2009, Alan Stern wrote:
> > > On Thu, 24 Sep 2009, Anton Vorontsov wrote:
> > > 
> > > > Though, there are few other issues with suspend/resume in this driver.
> > > > The intention of calling free_irq() in suspend() was to avoid any
> > > > possible spurious interrupts (see commit 5b039e681b8c5f30aac9cc04385
> > > > "3c59x PM fixes"). But,
> > > > 
> > > > - On resume, the driver was requesting IRQ just after pci_set_master(),
> > > >   but before vortex_up() (which actually resets 3c59x chips).
> > > 
> > > Shouldn't it be possible to reset the chip (or at least prevent it from 
> > > generating spurious IRQs) during the early-resume phase?
> > > 
> > > > - Issuing free_irq() on a shared IRQ doesn't guarantee that a buggy
> > > >   HW won't trigger spurious interrupts in another driver that
> > > >   requested the same interrupt. So, if we want to protect from
> > > >   unexpected interrupts, then on suspend we should issue disable_irq(),
> > > >   not free_irq().
> > > 
> > > What if some other device shares the IRQ and still relies on receiving
> > > interrupts when this code runs?  Won't disable_irq() mess up the other
> > > device?
> > 
> > Ah, I overlooked the disable_irq()/enable_irq() part, which is not really
> > necessary anyway.
> 
> Well, it is necessary if 3c59x really throws spurious interrupts
> upon suspend (i.e. after pci_disable_device(pdev)). My first though
> was to just remove free/request_irq stuff, but then I could introduce
> a regression if 3c59x really throws unexpected IRQs and 3c59x was
> the only user of a PCI IRQ (in that case free_irq() would actually
> help).
> 
> > Anton, have you tried without that?
> 
> Yes, and there wasn't any issues for 3x59x I have. Alan raised a very
> good point, and converting to dev_pm_opsas as you've suggested would
> solve it in a nice way, since if we use the dev_pm_ops, PCI core
> will disable the device in _noirq suspend, after we quiesced the
> chip itself.

That's exactly why I suggested to do that. :-)

> I'll send another patch that reworks PM stuff in the driver soon.

Thanks a lot for taking care of this!

Best,
Rafael
