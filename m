From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock tuning.
Date: Thu, 09 Sep 2010 14:01:24 -0700
Message-ID: <1284066084.2762.172.camel@localhost.localdomain>
References: <cover.1283504065.git.richard.cochran@omicron.at>
	 <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
	 <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-09 at 12:49 +0200, Thomas Gleixner wrote:
> On Fri, 3 Sep 2010, Richard Cochran wrote:
> 
> This patch needs to be split in pieces. The syscall change is totally
> unrelated to the dynamic clock id creation. Though I do not like
> either of them. :)
> 
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
> 
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
> 
> As far as I understood from the previous discussions, the final goal
> is to provide PTP support, right?
> 
> But what I see is an approach which tries to implement disconnected
> special purpose clocks which have the ability to be adjusted
> independently. What's the purpose of this ? Why can't we just use the
> existing clocks and make PTP work on them ?

So this too was my initial gut response. It seems ridiculous to expose
two clock_ids (CLOCK_REALTIME and CLOCK_PTP)that conceptually represent
the same thing (ie: number of seconds,nanoseconds since 1970).

It doesn't help that one of the use cases that Richard suggests is "for
example in an embedded control application. The userland software can
simply ignore the wrong system time." 

As someone who's spent a *lot* of time trying to fix the "wrong system
time" these use cases reek of work-around solutions instead of properly
fixing whatever keeps the system time from being accurately sycned.

However, as I've worked on understanding the issue, I realize that there
is some validity to needing to expose more then one hardware clock the
conceptually is the same as CLOCK_REALTIME. And that most of my gut
reaction to this was me being a bit oversensitive. :)

> I know that lots of embedded folks think that they need their special
> timers and extra magic to make stuff work, but that's the wrong
> approach.
> 
> What's wrong with the existing clocks? Nothing, except that we have no
> way to sync CLOCK_MONOTONIC across several machines. And that's what
> you really want if you try to do distributed control and data
> acquisition stuff.

Err.. s/CLOCK_MONOTONIC/CLOCK_REALTIME/ :)

> That's a single CLOCK_MONOTONIC_GLOBAL and not a bunch of completely
> disconnected clock implementations with random clock ids and random
> feature sets.

Specifically, because the way the correction feedback loops work with
PTP, working against the hardware clock that is generating the
timestamps directly is going to get the best results. 

Additionally, it allows multiple syncing methods to be tried in
userland, rather then trying jam it all in the kernel in order to make
it look like there is only one global system time. The parallel with
audio hardware is also valid, as we currently ignore any skew between
audio hardware clocks and system time, as there's no useful way to
expose those clocks (that I'm aware of atleast, not too familiar with
alsa, but my googling didn't show much).

However, since there may be multiple PTP clocks or audio clocks or
whatever, allocating static clockids for each type isn't quite useful,
as we need to deal with mapping the clockids to hardware. So exposing
the clockids via sysfs allows us to understand the physical mapping of
what bus and device the clock hangs off of.

Now, I'm not a fan of the clockid directory that Richard proposed, I'd
rather add a clock_id to the devices sysfs entry. But these are details
and can be worked out as the patch gets refined.


thanks
-john
