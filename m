From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 13:47:22 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311318570.4064@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310138.51214.rjw@sisk.pl> <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain> <200901312208.20850.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48966 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751502AbZAaVri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 16:47:38 -0500
In-Reply-To: <200901312208.20850.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > 
> > Don't make it use the new PM infrastructure, because that one is certainly 
> > broken: pci_pm_default_suspend_generic() is total crap.
> 
> Oh my.  I beg to differ.

Imagine that you're a bridge. Imagine what this does to any device 
_behind_ you. Any device that plans to still do something at suspend_late 
time, to be specific.

> > It's saving the disabled state. No WAY is that correct.
> 
> So why does it work, actually?

And I suspect it simply doesn't. And since almost nobody uses the new PM 
state, you just don't see it.

But as to why it fixes Parag's case - I think that's because the new PM 
resume does more than the legacy resume does, so it ends up re-enabling 
things anyway. It does it too late, but it doesn't matter in this case (no 
shared irq issues with the only device behind the pci-e bridge).

> > But all of that is only called if you use the new PM infrastructure. So 
> > the thing is, when you're trying to move the PCI-E drive to the new pm 
> > infrastructure, you're making things _worse_.
> 
> I don't really think so (see below).

See above. I think you really haven't thought the new PM code through.

> pci_disable_device() does really only one thing: it clears the bus master bit.
> Yes, it also calls pcibios_disable_device(), but on x86 this is a NOP.
> 
> I don't think it is SO bad, is it?

It's bad. It means that DMA won't work across such a bridge. Yes, it is 
probably bridge-dependent, and I know for a fact that at least some Intel 
bridges just hard-code the busmaster bit to 1 (at a minimum the host 
bridges do, I'm not sure about others), but I also know for a fact that 
some other bridges _will_ stop DMA to devices behind them if the BM bit is 
clear.

But more importantly: Why do you do it? What's the upside? I don't see it. 
There's a known downside - you're saving state that is something else than 
what the driver really expects. 

So I think clearing bus-master is a huge bug on a bridge, but I think that 
on normal devices it's just pointless.

> The driver using the new model is not supposed to save the state and power
> off the device.  Still, it's probably a good idea not to trust the drivers. :-)

How about devices that have magic power-down sequences? For example, a 
quick grep shows that USB on a PPC PMAC has a special "disable ASIC clocks 
for USB" thing after it puts the USB controller to sleep.

That was literally the _first_ driver I looked at. Admittedly because I 
knew that USB host controllers tend to be more aware of all the issues 
than most random drivers, but still...

I agree that the new model should turn off devices by default, but the 
thing is, it should also allow drivers that really know better to do magic 
things.

Of course, we can say that such devices should just continue to use the 
legacy model, but I thought that the long-term plan was to just replace 
it. And if you do, you need to allow for drivers that do special things 
due to known motherboard- or chip-specific "issues" (aka "PCI extensions" 
aka "hardware bugs").

And yes, I suspect that the magic PPC USB clock thing could maybe be 
rewritten as a system device, so there are other alternatives here, but I 
do suspect that it will be very painful if the new PM layer _forces_ a 
very specific model on drivers that they can't modify at all.

> > I don't see why we don't resume with IO/MEM on, though. The legacy suspend 
> > sequence shouldn't disable them, afaik.
> 
> No, it shouldn't.
> 
> However, the patch below actually may help and it really is not too different
> from my "new infrastructure" patch.  It leaves the pcie_portdrv_restore_config()
> in the PCIe port driver's ->resume(), but that shouldn't change things,
> pci_enable_device() in there shouldn't do anything and the bus master bit
> should already be set.

I absolutely agree with this patch. I'd just not expect it to make a 
difference (except for the "cleanup factor"). I think it's worth applying, 
and _if_ it makes a difference for Parag it's very interesting indeed.

> The "new infrastracture" patch makes pci_disable_enabled_device() be called in
> the suspend code path, but that only disables the bus master bit, and
> pci_reenable_device() be called in the resume code path, but that only sets the
> bus master bit back again.  So, they are almost the same and I'd be surprised
> if your patch didn't help.

Hmm. We'll see. I'm a bit doubtful. But we'll see..

		Linus
