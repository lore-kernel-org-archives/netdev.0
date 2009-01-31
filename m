From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 15:27:11 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311516360.2978@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312242.17273.rjw@sisk.pl> <alpine.LFD.2.00.0901311348000.4064@localhost.localdomain> <200902010008.32126.rjw@sisk.pl>
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
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42889 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751848AbZAaX1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 18:27:46 -0500
In-Reply-To: <200902010008.32126.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 1 Feb 2009, Rafael J. Wysocki wrote:
> 
> Alternatively, the core may check the state_saved bit and look at current_state
> to see if the device need not be put into a low power state.  Still, putting
> the device into a low power state need not be desirable anyway.

I'd be surprised if we didn't have devices that cannot act as wakeup 
devices in D3, for example. Yes, I'm sure it _should_ work, and I realize 
that the whole "platform_pci_choose_state()" is supposed to do this all 
right, but let me just take a wild stab at guessing that it's not always 
going to work.

So I would not be surprised if some devices will want to not be put in D3.

There's also the issue of debugging: we may well want to simply skip 
suspending the console device (and all bridges leading up to it). We don't 
do that right now, and we basically depend on "no_suspend_console" just 
working _despite_ that (because our legacy PCI power management never put 
things into sleep states), but that's another example of something where a 
driver might simply decide that it doesn't want the default PCI layer 
decisions: not because the device cannot do it, but because _we_ don't 
want it to do it.

> > Why? Think about a shared interrupt again - but now coming in at just the 
> > wrong time during _suspend_. The PCI layer has turned off the device. 
> > Oops. Lockup. The same lock-up we worked so hard to avoid during resume.
> 
> I know.  Still, all of the drivers that implement suspend-resume put the
> devices into low power states in ->suspend and it's never been observed to
> be a source of problems.

I do agree that problems at suspend time are probably somewhat less likely 
than at resume time. The devices are mostly in known states (rather than 
whatever random state they come up in and the BIOS early programming may 
do), and hopefully quiescent (because we told user space to freeze).

But I wouldn't bet on it in general. Think network cards on a shared 
interrupt, where the network card gets suspended _after_ the device that 
it shares interrupts with. Is the network quiescent? On a lot of desktop 
machines it probably is.

But how many people test STR while doing a "ping -f" from another machine?

It _should_ work. Do you guarantee that it does?

I think we should aim for "yes, we do guarantee that it does".

			Linus
