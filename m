From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: What should PCI core do during suspend-resume? (was: Re: 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 22:42:16 +0100
Message-ID: <200901312242.17273.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain> <200901312208.20850.rjw@sisk.pl>
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
Received: from ogre.sisk.pl ([217.79.144.158]:54555 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466AbZAaVnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 16:43:08 -0500
In-Reply-To: <200901312208.20850.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Rafael J. Wysocki wrote:
> On Saturday 31 January 2009, Linus Torvalds wrote:
> > 
> > On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > > 
> > > Can you test the patch below, please?
> > 
> > Rafael, you're making this _way_ too difficult.
> > 
> > Don't make it use the new PM infrastructure, because that one is certainly 
> > broken: pci_pm_default_suspend_generic() is total crap.
> 
> Oh my.  I beg to differ.
> 
> > It's saving the disabled state. No WAY is that correct.
> 
> So why does it work, actually?
> 
> > That "pci_disable_enabled_device()" should be removed, but even then 
> > that's wrong, because if the driver suspend disabled it, you're now 
> > (again) saving the disabled state.
> > 
> > But all of that is only called if you use the new PM infrastructure. So 
> > the thing is, when you're trying to move the PCI-E drive to the new pm 
> > infrastructure, you're making things _worse_.
> 
> I don't really think so (see below).
> 
> > The legacy PM infrastructure at least does the whole
> > 
> > 	pci_dev->state_saved = false;
> > 	i = drv->suspend(pci_dev, state);
> > 	..
> > 	if (pci_dev->state_saved)
> > 		goto Fixup;
> > 
> > thing, which will avoid overwriting the state if it was already saved.
> > 
> > HOWEVER. The problem here (I think) is that PCI-E actually does the state 
> > save late, so it won't ever see the "state_saved" in the early ->suspend. 
> > I think a patch like the one below at least simplifies this all, and lets 
> > the PCI layer itself do all the core restore stuff.
> > 
> > The new PM infrastructure gets this totally wrong, and
> >  (a) disables the device before saving state
> 
> pci_disable_device() does really only one thing: it clears the bus master bit.
> Yes, it also calls pcibios_disable_device(), but on x86 this is a NOP.
> 
> I don't think it is SO bad, is it?
> 
> > and
> >  (b) overwrites the (now corrupted) saved state that the driver perhaps 
> >      already saved, after the driver may even have put it to sleep.
> 
> The driver using the new model is not supposed to save the state and power
> off the device.  Still, it's probably a good idea not to trust the drivers. :-)
> 
> > So let's not use the new PM infrastructure - I don't think it's ready yet.
> >
> > Let's start simplifying first. Start off by getting rid of the 
> > suspend_early/resume_late, since the PCI layer now does it for us.
> > 
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
> 
> The "new infrastracture" patch makes pci_disable_enabled_device() be called in
> the suspend code path, but that only disables the bus master bit, and
> pci_reenable_device() be called in the resume code path, but that only sets the
> bus master bit back again.

I should have said "in this particular case", because it actually makes a
difference for devices using interrupt pins.  Namely, pcibios_enable_device()
additionally enables PCI resources (that may make a difference, but everything
should have been restored already) and sets up an interrupt link for the
device.  If the link has been set up already, which often is the case, it
increases a reference count and exits.

Now, this reference count is not used for anything, but it was supposed to be
used for disabling the interrupt links that are no longer needed.  This
mechanism is currently disabled, but if we enable it at one point (which may
be necessary to fix suspend-resume on some boxes), it won't work if
the "enable" calls are not balanced with "disable" ones.  IOW, for every
pcibios_enable_device() call there should be a complementary
pcibios_disable_device() call.  That's why I decided to put the
disable/enable things into the PCI core's suspend/resume code paths (also,
because pci_reenable_device() has been already there for driverless devices).
This might not be the right choice, but I don't really think it does break
things.

Anyway, from what I can tell reading your messages in this thread so far,
you seem to want the PCI core to:
(1) save the state of devices during suspend (avoid doing that if the driver has
    already saved the state),
(2) put devices into D0 during resume (early),
(3) restore the state of devices during resume (early).
Still, you don't want the core to disable devices during suspend and to enable
(or reenable) them during resume.

What about putting devices into low power states?  [Note that ACPI may be
necessary for this purpose.]

What about devices with no drivers and/or without suspend/resume support?
Do you want them to be disabled during suspend and enabled during resume by
the core?  [I guess you do, they have no interrupt handlers that may break
after all.]

Thanks,
Rafael
