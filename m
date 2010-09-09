From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock tuning.
Date: Thu, 9 Sep 2010 15:34:49 +0200
Message-ID: <20100909133449.GB2823@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1009091159260.2477-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 09, 2010 at 12:49:27PM +0200, Thomas Gleixner wrote:
> On Fri, 3 Sep 2010, Richard Cochran wrote:
> 
> This patch needs to be split in pieces. The syscall change is totally
> unrelated to the dynamic clock id creation. Though I do not like
> either of them. :)

That is not a problem. Splitting up the patch, I mean.

> > A new syscall is introduced that allows tuning of a POSIX clock. The
> > syscall is implemented for four architectures: arm, blackfin, powerpc,
> > and x86.
> > 
> > The new syscall, clock_adjtime, takes two parameters, the clock ID,
> > and a pointer to a struct timex. The semantics of the timex struct
> > have been expanded by one additional mode flag, which allows an
> > absolute offset correction. When specificied, the clock offset is
> > immediately corrected by skipping to the new time value.
> 
> And why do we need a separate syscall for this?

Because we cannot, in general, offer PTP hardware clocks as clock
sources. We need to tune the PTP hardware clock, even if there is no
connection to the Linux kernel system time.

> > In addition, the POSIX clock code has been augmented to offer a
> > dynamic clock creation method. Instead of registering a hard
> > coded clock ID, modules may call create_posix_clock(), which
> > returns a new clock ID.
> 
> This has been discussed for years and I still fail to see the
> requirement for this. The only result is that it allows folks to
> create their special purpose clock stuff and keep it out of tree
> instead of fixing the problems they have with the existing clock
> infrastructure in the kernel.

Do you have any pointers to this discussion?

> But what I see is an approach which tries to implement disconnected
> special purpose clocks which have the ability to be adjusted
> independently. What's the purpose of this ? Why can't we just use the
> existing clocks and make PTP work on them ?
> 
> I know that lots of embedded folks think that they need their special
> timers and extra magic to make stuff work, but that's the wrong
> approach.

Its not just embedded who want better synchronization, but also big
iron for microtrading on Wall Street, for example.

> What's wrong with the existing clocks? Nothing, except that we have no
> way to sync CLOCK_MONOTONIC across several machines. And that's what
> you really want if you try to do distributed control and data
> acquisition stuff.
> 
> That's a single CLOCK_MONOTONIC_GLOBAL and not a bunch of completely
> disconnected clock implementations with random clock ids and random
> feature sets.
> 
> Thoughts ?

There isn't really anything wrong with the existing clock
infrastructure, in my view. I think the stumbling block is the idea
that there can be more than one clock in a computer system, and that
user space needs access to more than just one of them.

It is a fact that PTP hardware clocks are separate from the system
clock, and this situation will presist for some time, if not
indefinitely. It is ironic that the very best PTP clocks, the PHY
clocks, are the farthest away from the system clock.

Using PTP (or any disributed time protocol, eg NTP) involves a number
of options and choices. This complexity belongs in user space. The
kernel should simply offer a way to access the hardware clocks
(mechanism, not policy). For NTP, the kernel has to have a special
role running the clock servo, but this is an exception.

Of course, the kernel wants to present a consistent system time to
user space, hiding the ugly clock details. However, when it comes to
PTP hardware clocks, the kernel needs a little help.  Only one
program, lets call it the ptpd, needs to know about the PTP
clock. What this program does depends on the operational mode and on
the user's preferences.

What follows uses the posix clock api idea just to illustrate. You
could just as well use chardev ioctls. I am not arguing about the
API. Rather I am trying to explain why the kernel must expose multiple
clocks to user space.

1. Master with external time source (like GPS)

   Using the PPS subsystem, the system time is latched on the 1 PPS
   from the GPS. Using the PTP external timestamp feature, the PTP
   clock time is also latched.  The ptpd then adjusts *both* the
   kernel time and the PTP clock time.

   systime = get_pps();
   adj = servo(systime);
   clock_adjtime(clock_realtime, adj);

   ptptime = ptp_external_timestamp();
   adj = servo(ptptime);
   clock_adjtime(clock_ptp, adj);

2. Master with PTP clock as time source

   In this case, there is no external reference clock, and we know
   that the PTP clock's oscillator is more stable than the
   system's. The ptpd enables the 1 PPS from the PTP clock and adjusts
   the system clock according to the latched system time.

   t = get_pps();
   adj = servo(t);
   clock_adjtime(clock_realtime, adj);

3. Master with kernel as time source

   In this case, we are using the system time (which could be from an
   oven quartz, for example). The ptpd enables the 1 PPS from the PTP
   clock and adjusts the PTP clock according to the latched system
   time.

   t = get_pps();
   adj = servo(t);
   clock_adjtime(clock_ptp, adj);

4. Slave with PPS hook

   Here we want to synchronize the system and the PTP clock to a
   remote clock. The ptpd uses timestamps on network packets to feed a
   servo that controls the PTP clock. The ptpd also enables the 1 PPS
   from the PTP clock and adjusts the system clock according to the
   latched system time (like case 2).

In all of these examples, most userland programs will not be aware of
what is going on, just like when NTP is used. Only the ptpd knows that
there are multiple clocks, and that program really *does* need access
to the various clocks.

Finally, there is one case which is dumb from a hardware design point
of view, but still possible. Lets say that we have a PHY based PTP
clock witnout any interrupt to the CPU. You could still use such a
computer in a distributed application by just ignoring the wrong
system time, provided that the kernel offers a way to control the PTP
hardware clock.

Richard
