From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 15:01:50 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312208.20850.rjw@sisk.pl> <alpine.LFD.2.00.0901311318570.4064@localhost.localdomain> <200901312346.35265.rjw@sisk.pl>
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
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52685 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752346AbZAaXB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 18:01:57 -0500
In-Reply-To: <200901312346.35265.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> 
> But many drivers have an analogous code sequence in their PM callbacks and
> I've tested it with several drivers on my test boxes.  It's never failed for me.

Rafael!

Read what I write. Twice.

Here it is again: "Imagine that you're a bridge."

Stop the idiocy of just ignoring what I write, and talking about something 
else.

Bridges are special.

> > But as to why it fixes Parag's case - I think that's because the new PM 
> > resume does more than the legacy resume does, so it ends up re-enabling 
> > things anyway. It does it too late, but it doesn't matter in this case (no 
> > shared irq issues with the only device behind the pci-e bridge).
> 
> Still, the 2.6.28 resume didn't do the "reenable device" thing and it worked.
> 
> I think in the Parag's case the problem is the "double restore".

It's possible. Still, it really shouldn't matter.

Or at least, it shouldn't matter, as long as what you restore is sane. 
You're just going to rewrite the same data, after all.

That's why I was trying to see if the IO/MEM bits got cleared in the save 
image for some reason.

> > See above. I think you really haven't thought the new PM code through.
> 
> Yes, I have, but my experience apparently doesn't match yours.

The problem is that you're looking at some individual devices, and saying 
"it works for them, so it must work for everybody". Add to that the fact 
that you apparently _still_ haven't figured out the difference between 
bridges and regular devices, and that most most motherboards probably keep 
the PCI bridges powered anyway, and...

And yes, I realize that this is how PM under Linux has worked for a long 
time. But it's what I think we should get away from. It's why I pushed so 
hard to get the whole interrupt handling sane and stable. 

The argument that "it works for a lot of machines" IS NOT AN ARGUMENT, 
Rafael! Stop using it as such.

We know that 2.6.28 suspend/resume works for a lot of laptops. Even 
possibly _most_ laptops. But it was still broken. We want to get _away_ 
from that.

> DMA will only not work until the ->resume sets the bus master bit, which
> happes before the ->resume of any device behind the bridge runs.

Read my emails. THIS ISN'T EVEN A RESUME-TIME PROBLEM!

The problems happen on purely the suspend path. How the f*ck do you know 
that the drivers behind the bridge don't do everything at 'suspend_late' 
time, and expect to be working up until that time?

Here's a big hint: YOU DO NOT KNOW. YOU MUST NOT TURN OFF THE BRIDGE AT 
SUSPEND TIME!

I'm getting really fed up with you here. You're not even listening. And 
you are _definitely_ not doing any "deep thinking" here.

> > How about devices that have magic power-down sequences? For example, a 
> > quick grep shows that USB on a PPC PMAC has a special "disable ASIC clocks 
> > for USB" thing after it puts the USB controller to sleep.
> 
> This is exceptional, from what I can tell.

So?

Irrelevant. We want to handle the exceptional case too. And we generally 
want to handle them _automatically, rather than by:

> We may need an "override default resume" flag for such drivers.

.. why? Wouldn't it be a hell of a lot nicer if the PCI layer just did 
things right automatically. 

Which the legacy layer already does. It sees "ok, the driver did it's own 
pci_save_state(), I'm not going to do it for it".

THAT is robust. And simple. Wouldn't you agree?

So why not do the same in the new one? Why do you want to make the new 
interfaces _inferior_ to the old ones?

			Linus
