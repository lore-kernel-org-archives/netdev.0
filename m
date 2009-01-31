From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 13:59:53 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311348000.4064@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain> <200901312208.20850.rjw@sisk.pl> <200901312242.17273.rjw@sisk.pl>
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
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59110 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750856AbZAaWAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 17:00:07 -0500
In-Reply-To: <200901312242.17273.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> 
> Anyway, from what I can tell reading your messages in this thread so far,
> you seem to want the PCI core to:
> (1) save the state of devices during suspend (avoid doing that if the driver has
>     already saved the state),

Yes, but I'd at least want the device drivers to have the _option_ to 
do it themselves.

I would expect that by default any normal PCI driver would just rely on 
the PCI layer doing it all for them. But I suspect we may have cases where 
the chip driver will simply want to override things, for one reason or 
another.

We do know that some devices seem to be very picky and get unhappy about 
being put to sleep (we don't put devices into D3 by default in the legacy 
PM case for a reason!), and we do know that some existing drivers do extra 
things _after_ they've put the device to D3.

So there very much are arguments for drivers wanting to do their own "save 
state and power off" if they have special needs.

(Side note: it's entirely possible that one of the reasons we don't put 
devices into D3 in the legacy code-path is purely historical: maybe not 
because the devices were unhappy, but simply because it triggered the 
whole "interrupt at an unlucky place" thing. So I'm hoping that we'll 
actually not have this as a real issue, but..)

> (2) put devices into D0 during resume (early),
> (3) restore the state of devices during resume (early).

Yes.

> Still, you don't want the core to disable devices during suspend and to enable
> (or reenable) them during resume.

At an absolute _minimum_, bridges are special. 

We already know bridges are special: we do things like

	if (!pci_is_bridge(pci_dev))
		pci_prepare_to_sleep(pci_dev);


ie we don't actually put the bridges into D3 sleep, because the devices 
behind the bridge still need to be available until at LEAST the 
"suspend_late()" stage.

But then pci_pm_default_suspend_generic() does that 
pci_disable_enabled_device() unconditionally - even for bridges. That's 
just wrong, wrong, wrong.

> What about putting devices into low power states?  [Note that ACPI may be
> necessary for this purpose.]

I do think we should do it, although I'd at least personally prefer 
delaying it to the suspend_late (noirq) phase.

Why? Think about a shared interrupt again - but now coming in at just the 
wrong time during _suspend_. The PCI layer has turned off the device. 
Oops. Lockup. The same lock-up we worked so hard to avoid during resume.

> What about devices with no drivers and/or without suspend/resume support?

Oh, suspending those early and aggressively may be the right thing. But 
again, at least bridges are special.

Some bridges have drivers (pci-e and cardbus bridges at least), others 
don't (regular pci bridges). So bridges hit both the "has drivers" and 
"don't have drivers" case, and are special in both cases.

				Linus
