From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: What should PCI core do during suspend-resume? (was: Re: 2.6.29-rc3: tg3 dead after resume)
Date: Sun, 1 Feb 2009 01:36:54 +0100
Message-ID: <200902010136.55375.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901311516360.2978@localhost.localdomain> <alpine.LFD.2.00.0901311534340.3067@localhost.localdomain>
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
Received: from ogre.sisk.pl ([217.79.144.158]:54875 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751517AbZBAAhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 19:37:32 -0500
In-Reply-To: <alpine.LFD.2.00.0901311534340.3067@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 01 February 2009, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Linus Torvalds wrote:
> > 
> > But how many people test STR while doing a "ping -f" from another machine?
> > 
> > It _should_ work. Do you guarantee that it does?
> 
> Btw, this really only is interesting if there's a shared interrupt. 
> 
> I'm sure that there are network drivers that will crash even on their own 
> with _just_ the right timing (imagine having a delayed interrupt pending, 
> then doing the "pci_set_power_state(PCI_D3hot)" thing, and then get the 
> interrupt handler invoked on another CPU _just_ afterwards), but it's 
> probably really hard to trigger, and a bug in that specific driver anyway.
> 
> But what's much more interesting (and not necessarily a driver bug, but a 
> general PM infrastructure problem) is if we have that shared interrupt 
> case, and the network driver gets lots of interrupts just as "driver X" is 
> shutting down with that interrupt shared. Then, "driver X" will get 
> interrupts after the PM layer has put its device to sleep, and now "driver 
> X" is quite understandably confused - it didn't even do the "put to sleep" 
> itself, but now its device is no longer responding.
> 
> And now it's not a really unlikely race condition any more. 

All this leads to the conclusion that we should put devices into low power
states with interrupts off and this seems to imply that we'll need to make the
AML interpreter allow us to run AML with interrupts off.

Still, what about the following rule:
- If the device is supposed to wake up the system, the driver should prepare it
  and put it into a low power state using the existing PCI callbacks, in
  ->suspend().  In that case, the driver is also required to save the state of
  the device before putting it into the low power state.  It is also required
  to make sure that its interrupt handler will not get confused in case of
  shared interrupts.
- If the state of the device hasn't been saved by the driver, the core is
  required to save its state (with interrupts off, I suppose?).
- If the state of the device hasn't been saved by the driver, the core will
  attempt to put the device into a low power state, using the native PCI PM and
  with interrupts off, unless PCI_DEV_FLAGS_NO_D3 is set in dev->flags.

Thanks,
Rafael
