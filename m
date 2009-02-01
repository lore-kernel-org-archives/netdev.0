From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sun, 1 Feb 2009 01:11:07 +0100
Message-ID: <200902010111.08433.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312346.35265.rjw@sisk.pl> <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain>
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
Received: from ogre.sisk.pl ([217.79.144.158]:54829 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbZBAAMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 19:12:03 -0500
In-Reply-To: <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 01 February 2009, Linus Torvalds wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> > 
> > But many drivers have an analogous code sequence in their PM callbacks and
> > I've tested it with several drivers on my test boxes.  It's never failed for me.
> 
> Rafael!
> 
> Read what I write. Twice.

You didn't give me a chance by removing it. ;-)

> Here it is again: "Imagine that you're a bridge."
> 
> Stop the idiocy of just ignoring what I write, and talking about something 
> else.
> 
> Bridges are special.

[Confused] Yes, they are.

And yes, I agreed that the bus master bit shouldn't be cleared for them.  Which
does not necessarily imply that clearing that bit will always lead to problems
in practice.

> > > But as to why it fixes Parag's case - I think that's because the new PM 
> > > resume does more than the legacy resume does, so it ends up re-enabling 
> > > things anyway. It does it too late, but it doesn't matter in this case (no 
> > > shared irq issues with the only device behind the pci-e bridge).
> > 
> > Still, the 2.6.28 resume didn't do the "reenable device" thing and it worked.
> > 
> > I think in the Parag's case the problem is the "double restore".
> 
> It's possible. Still, it really shouldn't matter.
> 
> Or at least, it shouldn't matter, as long as what you restore is sane. 
> You're just going to rewrite the same data, after all.

Yes, but I suspect the device is misbehaving due to some timing issues.

With devices that behave totally correctly the current code doesn't appear to
cause problems.

> That's why I was trying to see if the IO/MEM bits got cleared in the save 
> image for some reason.

Well, we never clear them.

> > > See above. I think you really haven't thought the new PM code through.
> > 
> > Yes, I have, but my experience apparently doesn't match yours.
> 
> The problem is that you're looking at some individual devices, and saying 
> "it works for them, so it must work for everybody".

Look.  I have only a limited set of data from devices that have been tested.
On the other hand I have some pieces of documentation that are sometimes not
very clear.  I try to use the data and the docs I have to figure out how things
actually work.

That's why the cases like the Parag's one are so important.  They allow me to
verify assumptions.

So no, I don't say "it must work for everybody", but I have to assume
_something_ if I don't know that _for_ _sure_.  I sometimes make wrong
assumptions, which is a consequence of the fact that I can only use a limited
set of data to verify my observations.

And please note, we still don't know for sure why the Parag's box actually
fails.  We have some theories that may or may not be correct, but that's it.

> Add to that the fact that you apparently _still_ haven't figured out the
> difference between bridges and regular devices, and that most most
> motherboards probably keep the PCI bridges powered anyway, and...

[Confused again] Why are you talking about keeping bridges powered?
 
> And yes, I realize that this is how PM under Linux has worked for a long 
> time. But it's what I think we should get away from. It's why I pushed so 
> hard to get the whole interrupt handling sane and stable. 
> 
> The argument that "it works for a lot of machines" IS NOT AN ARGUMENT, 
> Rafael! Stop using it as such.
>
> We know that 2.6.28 suspend/resume works for a lot of laptops. Even 
> possibly _most_ laptops. But it was still broken. We want to get _away_ 
> from that.

Working on many (different) systems is a good indication of what is and what
is not going to work in general.  It obviously doesn't imply correctness,
though.

> > DMA will only not work until the ->resume sets the bus master bit, which
> > happes before the ->resume of any device behind the bridge runs.
> 
> Read my emails. THIS ISN'T EVEN A RESUME-TIME PROBLEM!
> 
> The problems happen on purely the suspend path. How the f*ck do you know 
> that the drivers behind the bridge don't do everything at 'suspend_late' 
> time, and expect to be working up until that time?

DMA from suspend_late?  Come on.

> Here's a big hint: YOU DO NOT KNOW. YOU MUST NOT TURN OFF THE BRIDGE AT 
> SUSPEND TIME!
> 
> I'm getting really fed up with you here. You're not even listening. And 
> you are _definitely_ not doing any "deep thinking" here.

Why are you shouting at me?  Did you read my reply to your other message?
How many times do I have to tell you I AGREE THAT I SHOULD NOT TURN OFF THE
BUS MASTER BIT FOR BRIDGES so that you actually get it?

> > > How about devices that have magic power-down sequences? For example, a 
> > > quick grep shows that USB on a PPC PMAC has a special "disable ASIC clocks 
> > > for USB" thing after it puts the USB controller to sleep.
> > 
> > This is exceptional, from what I can tell.
> 
> So?
> 
> Irrelevant. We want to handle the exceptional case too. And we generally 
> want to handle them _automatically, rather than by:
> 
> > We may need an "override default resume" flag for such drivers.
> 
> .. why? Wouldn't it be a hell of a lot nicer if the PCI layer just did 
> things right automatically. 
> 
> Which the legacy layer already does. It sees "ok, the driver did it's own 
> pci_save_state(), I'm not going to do it for it".
> 
> THAT is robust. And simple. Wouldn't you agree?
> 
> So why not do the same in the new one? Why do you want to make the new 
> interfaces _inferior_ to the old ones?

On suspend we have two things to do:
- save the state
- put the device into a low power state

The state_saved flag can be used to see if the driver has saved the state.

What about powering off?  Are we going to assume that if the driver has saved
the state of the device, the core should not put the device into a low power
state?

Rafael
