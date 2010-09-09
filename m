From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock
 tuning.
Date: Thu, 9 Sep 2010 22:10:01 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009092102150.2477@localhost6.localdomain6>
References: <cover.1283504065.git.richard.cochran@omicron.at> <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at> <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6> <20100909133449.GB2823@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100909133449.GB2823-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Richard,

On Thu, 9 Sep 2010, Richard Cochran wrote:

> On Thu, Sep 09, 2010 at 12:49:27PM +0200, Thomas Gleixner wrote:
> > On Fri, 3 Sep 2010, Richard Cochran wrote:
> > > In addition, the POSIX clock code has been augmented to offer a
> > > dynamic clock creation method. Instead of registering a hard
> > > coded clock ID, modules may call create_posix_clock(), which
> > > returns a new clock ID.
> > 
> > This has been discussed for years and I still fail to see the
> > requirement for this. The only result is that it allows folks to
> > create their special purpose clock stuff and keep it out of tree
> > instead of fixing the problems they have with the existing clock
> > infrastructure in the kernel.
> 
> Do you have any pointers to this discussion?

Not out of the box. Need to ask the oracle of google [ I wonder if
this expression is politically correct today :) ]

My personal stance on this is clear: Assign fixed ID.

The point is, that if we provide something like CLOCK_PTP, then we can
abstract the real hardware drivers behind this clock id and we get a
consistent feature set for these drivers and a consistent behaviour on
the user space interface. There still might be a hardware driver which
cannot provide a specific feature, but there is nothing wrong to
return -ENOSYS in such a case.

> There isn't really anything wrong with the existing clock
> infrastructure, in my view. I think the stumbling block is the idea
> that there can be more than one clock in a computer system, and that
> user space needs access to more than just one of them.
> 
> It is a fact that PTP hardware clocks are separate from the system
> clock, and this situation will presist for some time, if not
> indefinitely. It is ironic that the very best PTP clocks, the PHY
> clocks, are the farthest away from the system clock.

In terms of hardware, yes.
 
> Using PTP (or any disributed time protocol, eg NTP) involves a number
> of options and choices. This complexity belongs in user space. The
> kernel should simply offer a way to access the hardware clocks
> (mechanism, not policy). For NTP, the kernel has to have a special

I completely agree with that.

> role running the clock servo, but this is an exception.
> 
> Of course, the kernel wants to present a consistent system time to
> user space, hiding the ugly clock details. However, when it comes to
> PTP hardware clocks, the kernel needs a little help.  Only one
> program, lets call it the ptpd, needs to know about the PTP
> clock. What this program does depends on the operational mode and on
> the user's preferences.

No objections
 
> What follows uses the posix clock api idea just to illustrate. You
> could just as well use chardev ioctls. I am not arguing about the
> API. Rather I am trying to explain why the kernel must expose multiple
> clocks to user space.
> 
> 1. Master with external time source (like GPS)
> 2. Master with PTP clock as time source
> 3. Master with kernel as time source
> 4. Slave with PPS hook

Ok, that makes a lot of sense now. Thanks for taking the time and
shedding some light on me!

So you want to utilize the posix-timer infrastructure to make all this
happen. This new clock basically needs clock_[get|set]time plus the
new clock_adjust syscall, nothing more. The normal application stuff
will still use what's already there, right ?

If that's the case, then I'm not going to stand in the way, except for
some implementation details like the new syscall clock_adjust: 

Please make this thing new from ground up and not just a modified copy
of sys_adjtimex.

 1) This avoids the compat syscall crap

 2) It allows you to add the extra control stuff for your PTP magic
     (PPS, whatever) which you would need to expose by some other
     means otherwise.

Thanks,

	tglx
