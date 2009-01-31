From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: What should PCI core do during suspend-resume? (was: Re: 2.6.29-rc3: tg3 dead after resume)
Date: Sun, 1 Feb 2009 00:08:31 +0100
Message-ID: <200902010008.32126.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312242.17273.rjw@sisk.pl> <alpine.LFD.2.00.0901311348000.4064@localhost.localdomain>
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
Received: from ogre.sisk.pl ([217.79.144.158]:54701 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbZAaXJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 18:09:12 -0500
In-Reply-To: <alpine.LFD.2.00.0901311348000.4064@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > 
> > Anyway, from what I can tell reading your messages in this thread so far,
> > you seem to want the PCI core to:
> > (1) save the state of devices during suspend (avoid doing that if the driver has
> >     already saved the state),
> 
> Yes, but I'd at least want the device drivers to have the _option_ to 
> do it themselves.

(As I wrote in the other message just sent) I wonder if it's a good idea to
introduce an "override default PCI suspend/resume" flag for this purpose.

The drivers that want to handle the PCI stuff themselves would be able to use
this flag to tell the core not to try to power manage the device etc.

Alternatively, the core may check the state_saved bit and look at current_state
to see if the device need not be put into a low power state.  Still, putting
the device into a low power state need not be desirable anyway.

> I would expect that by default any normal PCI driver would just rely on 
> the PCI layer doing it all for them. But I suspect we may have cases where 
> the chip driver will simply want to override things, for one reason or 
> another.
> 
> We do know that some devices seem to be very picky and get unhappy about 
> being put to sleep (we don't put devices into D3 by default in the legacy 
> PM case for a reason!), and we do know that some existing drivers do extra 
> things _after_ they've put the device to D3.
> 
> So there very much are arguments for drivers wanting to do their own "save 
> state and power off" if they have special needs.
> 
> (Side note: it's entirely possible that one of the reasons we don't put 
> devices into D3 in the legacy code-path is purely historical: maybe not 
> because the devices were unhappy, but simply because it triggered the 
> whole "interrupt at an unlucky place" thing. So I'm hoping that we'll 
> actually not have this as a real issue, but..)

It actually has been confirmed recently that this is a real issue.  Sadly.

> > (2) put devices into D0 during resume (early),
> > (3) restore the state of devices during resume (early).
> 
> Yes.
> 
> > Still, you don't want the core to disable devices during suspend and to enable
> > (or reenable) them during resume.
> 
> At an absolute _minimum_, bridges are special. 
>
> We already know bridges are special: we do things like
> 
> 	if (!pci_is_bridge(pci_dev))
> 		pci_prepare_to_sleep(pci_dev);
> 
> 
> ie we don't actually put the bridges into D3 sleep, because the devices 
> behind the bridge still need to be available until at LEAST the 
> "suspend_late()" stage.
> 
> But then pci_pm_default_suspend_generic() does that 
> pci_disable_enabled_device() unconditionally - even for bridges. That's 
> just wrong, wrong, wrong.

OK, I see your point.

> > What about putting devices into low power states?  [Note that ACPI may be
> > necessary for this purpose.]
> 
> I do think we should do it, although I'd at least personally prefer 
> delaying it to the suspend_late (noirq) phase.
> 
> Why? Think about a shared interrupt again - but now coming in at just the 
> wrong time during _suspend_. The PCI layer has turned off the device. 
> Oops. Lockup. The same lock-up we worked so hard to avoid during resume.

I know.  Still, all of the drivers that implement suspend-resume put the
devices into low power states in ->suspend and it's never been observed to
be a source of problems.

Unfortunately, on many systems we are supposed to use ACPI for putting PCI
devices into low power states and right now we can't do that with interrupts
off due to the limitations of our AML interpreter.

The same applies to resume, BTW, but resume is easier, because devices tend
to already be in D0 from the start.  Admittedly, though, we may have a problem
with devices that are not in D0 at that point and _require_ ACPI to power them
up (ie. don't support the native PCI PM).  Not that I know of any, but still.

ISTR that some devices will not wake up the system if they are not put into
the low power state by ACPI during suspend.

So, I wonder.  Do we need to make the AML interpreter allow us to run code
with interrupts off?

> > What about devices with no drivers and/or without suspend/resume support?
> 
> Oh, suspending those early and aggressively may be the right thing. But 
> again, at least bridges are special.
> 
> Some bridges have drivers (pci-e and cardbus bridges at least), others 
> don't (regular pci bridges). So bridges hit both the "has drivers" and 
> "don't have drivers" case, and are special in both cases.

Yes, the bridges with drivers are somewhat special.

Thanks,
Rafael
