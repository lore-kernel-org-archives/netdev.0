From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: OFT - reserving CPU's for networking
Date: Thu, 29 Apr 2010 21:19:36 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com> <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi> <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop> <1272293707.19143.51.camel@edumazet-laptop>
 <20100429174056.GA8044@gargoyle.fritz.box> <1272563772.2222.301.camel@edumazet-laptop> <20100429111047.031eeff9@nehalam>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1546049908-1272568780=:2951"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andi Kleen <ak@gargoyle.fritz.box>, netdev@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>,
	Peter Zijlstra <peterz@infradead.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:36196 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932479Ab0D3RMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:12:53 -0400
In-Reply-To: <20100429111047.031eeff9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1546049908-1272568780=:2951
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 29 Apr 2010, Stephen Hemminger wrote:
> > Le jeudi 29 avril 2010 à 19:42 +0200, Andi Kleen a écrit :
> > > > Andi, what do you think of this one ?
> > > > Dont we have a function to send an IPI to an individual cpu instead ?  
> > > 
> > > That's what this function already does. You only set a single CPU 
> > > in the target mask, right?
> > > 
> > > IPIs are unfortunately always a bit slow. Nehalem-EX systems have X2APIC
> > > which is a bit faster for this, but that's not available in the lower
> > > end Nehalems. But even then it's not exactly fast.
> > > 
> > > I don't think the IPI primitive can be optimized much. It's not a cheap 
> > > operation.
> > > 
> > > If it's a problem do it less often and batch IPIs.
> > > 
> > > It's essentially the same problem as interrupt mitigation or NAPI 
> > > are solving for NICs. I guess just need a suitable mitigation mechanism.
> > > 
> > > Of course that would move more work to the sending CPU again, but 
> > > perhaps there's no alternative. I guess you could make it cheaper it by
> > > minimizing access to packet data.
> > > 
> > > -Andi  
> > 
> > Well, IPI are already batched, and rate is auto adaptative.
> > 
> > After various changes, it seems things are going better, maybe there is
> > something related to cache line trashing.
> > 
> > I 'solved' it by using idle=poll, but you might take a look at
> > clockevents_notify (acpi_idle_enter_bm) abuse of a shared and higly
> > contended spinlock...

Say thanks to Intel/AMD for providing us timers which stop in lower
c-states.

Not much we can do about the broadcast lock when several cores are
going idle and we need to setup a global timer to work around the
lapic timer stops in C2/C3 issue.

Simply the C-state timer broadcasting does not scale. And it was never
meant to scale. It's a workaround for laptops to have functional NOHZ.

There are several ways to work around that on larger machines:

 - Restrict c-states
 - Disable NOHZ and highres timers
 - idle=poll is definitely the worst of all possible solutions

> I keep getting asked about taking some core's away from clock and scheduler
> to be reserved just for network processing. Seeing this kind of stuff
> makes me wonder if maybe that isn't a half bad idea.

This comes up every few month and we pointed out several times what
needs to be done to make this work w/o these weird hacks which put a
core offline and then start some magic undebugable binary blob on it.
We have not seen anyone working on this, but the "set cores aside and
let them do X" idea seems to stick in peoples heads.

Seriously, that's not a solution. It's going to be some hacked up
nightmare which is completely unmaintainable.

Aside of that I seriously doubt that you can do networking w/o time
and timers.

Thanks,

	tglx
--8323328-1546049908-1272568780=:2951--
