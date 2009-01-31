From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 23:46:34 +0100
Message-ID: <200901312346.35265.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312208.20850.rjw@sisk.pl> <alpine.LFD.2.00.0901311318570.4064@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54656 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbZAaWra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 17:47:30 -0500
In-Reply-To: <alpine.LFD.2.00.0901311318570.4064@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > > 
> > > Don't make it use the new PM infrastructure, because that one is certainly 
> > > broken: pci_pm_default_suspend_generic() is total crap.
> > 
> > Oh my.  I beg to differ.
> 
> Imagine that you're a bridge. Imagine what this does to any device 
> _behind_ you. Any device that plans to still do something at suspend_late 
> time, to be specific.
> 
> > > It's saving the disabled state. No WAY is that correct.
> > 
> > So why does it work, actually?
> 
> And I suspect it simply doesn't. And since almost nobody uses the new PM 
> state, you just don't see it.

But many drivers have an analogous code sequence in their PM callbacks and
I've tested it with several drivers on my test boxes.  It's never failed for me.

> But as to why it fixes Parag's case - I think that's because the new PM 
> resume does more than the legacy resume does, so it ends up re-enabling 
> things anyway. It does it too late, but it doesn't matter in this case (no 
> shared irq issues with the only device behind the pci-e bridge).

Still, the 2.6.28 resume didn't do the "reenable device" thing and it worked.

I think in the Parag's case the problem is the "double restore".

> > > But all of that is only called if you use the new PM infrastructure. So 
> > > the thing is, when you're trying to move the PCI-E drive to the new pm 
> > > infrastructure, you're making things _worse_.
> > 
> > I don't really think so (see below).
> 
> See above. I think you really haven't thought the new PM code through.

Yes, I have, but my experience apparently doesn't match yours.

> > pci_disable_device() does really only one thing: it clears the bus master bit.
> > Yes, it also calls pcibios_disable_device(), but on x86 this is a NOP.
> > 
> > I don't think it is SO bad, is it?
> 
> It's bad. It means that DMA won't work across such a bridge. Yes, it is 
> probably bridge-dependent, and I know for a fact that at least some Intel 
> bridges just hard-code the busmaster bit to 1 (at a minimum the host 
> bridges do, I'm not sure about others), but I also know for a fact that 
> some other bridges _will_ stop DMA to devices behind them if the BM bit is 
> clear.

DMA will only not work until the ->resume sets the bus master bit, which
happes before the ->resume of any device behind the bridge runs.  There only
is a small window where something (theoretically) may go wrong and I really
don't expect any driver to start DMA from its ->resume_realy or an interrupt
handler.

> But more importantly: Why do you do it? What's the upside? I don't see it.

OK, point taken.
 
> There's a known downside - you're saving state that is something else than 
> what the driver really expects. 
> 
> So I think clearing bus-master is a huge bug on a bridge, but I think that 
> on normal devices it's just pointless.
>
> > The driver using the new model is not supposed to save the state and power
> > off the device.  Still, it's probably a good idea not to trust the drivers. :-)
> 
> How about devices that have magic power-down sequences? For example, a 
> quick grep shows that USB on a PPC PMAC has a special "disable ASIC clocks 
> for USB" thing after it puts the USB controller to sleep.

This is exceptional, from what I can tell.

> That was literally the _first_ driver I looked at. Admittedly because I 
> knew that USB host controllers tend to be more aware of all the issues 
> than most random drivers, but still...
> 
> I agree that the new model should turn off devices by default, but the 
> thing is, it should also allow drivers that really know better to do magic 
> things.
> 
> Of course, we can say that such devices should just continue to use the 
> legacy model, but I thought that the long-term plan was to just replace 
> it. And if you do, you need to allow for drivers that do special things 
> due to known motherboard- or chip-specific "issues" (aka "PCI extensions" 
> aka "hardware bugs").

We may need an "override default resume" flag for such drivers.

> And yes, I suspect that the magic PPC USB clock thing could maybe be 
> rewritten as a system device, so there are other alternatives here, but I 
> do suspect that it will be very painful if the new PM layer _forces_ a 
> very specific model on drivers that they can't modify at all.
> 
> > > I don't see why we don't resume with IO/MEM on, though. The legacy suspend 
> > > sequence shouldn't disable them, afaik.
> > 
> > No, it shouldn't.
> > 
> > However, the patch below actually may help and it really is not too different
> > from my "new infrastructure" patch.  It leaves the pcie_portdrv_restore_config()
> > in the PCIe port driver's ->resume(), but that shouldn't change things,
> > pci_enable_device() in there shouldn't do anything and the bus master bit
> > should already be set.
> 
> I absolutely agree with this patch.

Well, it's your patch after all, isn't it? ;-)

Rafael
