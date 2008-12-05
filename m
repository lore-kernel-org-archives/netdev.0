From: "john stultz" <johnstul@us.ibm.com>
Subject: Re: [RFC PATCH 08/11] clocksource: allow usage independent of timekeeping.c
Date: Fri, 5 Dec 2008 13:05:28 -0800
Message-ID: <1f1b08da0812051305hdca5b4bs1662368cda86255d@mail.gmail.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-3-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-5-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-6-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-7-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-8-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-9-git-send-email-patrick.ohly@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"Magnus Damm" <magnus.damm@gmail.com>
To: "Patrick Ohly" <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:14262 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbYLEVFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 16:05:30 -0500
Received: by yw-out-2324.google.com with SMTP id 9so113759ywe.1
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2008 13:05:28 -0800 (PST)
In-Reply-To: <1227096528-24150-9-git-send-email-patrick.ohly@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 4:08 AM, Patrick Ohly <patrick.ohly@intel.com> wrote:
> So far struct clocksource acted as the interface between time/timekeeping
> and hardware. This patch generalizes the concept so that the same
> interface can also be used in other contexts.

Hey Patrick,
   Sorry for not noticing this thread earlier!

> The only change as far as kernel/time/timekeeping is concerned is that
> the hardware access can be done either with or without passing
> the clocksource pointer as context. This is necessary in those
> cases when there is more than one instance of the hardware.

So as a heads up, the bit about passing the clocksource to the
read_clock() function looks very similar to a bit of what Magnus Damm
was recently working on.

> The extensions in this patch add code which turns the raw cycle count
> provided by hardware into a continously increasing time value. This
> reuses fields also used by timekeeping.c. Because of slightly different
> semantic (__get_nsec_offset does not update cycle_last, clocksource_read_ns
> does that transparently) timekeeping.c was not modified to use the
> generalized code.

Hrm.. I'm a little wary here. Your patch basically creates new
semantics to how the clocksource structure is used,  which will likely
cause confusion.  I'll agree that the clocksource structure has been
somewhat more cluttered with timekeeping-isms then I'd prefer, so
maybe your patches give us the need to clean it up and better separate
the hardware clocksource accessor information and the timekeeping
state.

So to be clear, let me see if I understand your needs from your patch:

1) Need an interface to a counter, who's interface monotonically increases.
2) Need to translate the counter to nanoseconds and nanoseconds back
to the counter
3) The counter will likely not be registered for use in timekeeping
4) The counter's sense of time will not be steered via frequency adjustments.

Is that about the right set of assumptions?

So if we break the clocksource structure into two portions (ignore
name deatils for now)

 strucut counter{
      char* name,
      u32 mult,
      u32 shift,
      cycle_t mask,
      cycle_t (*read)(struct counter*);
      cycle_t (*vread)(void);

     /* bits needed here for real monotonic interface, more on that below */

    /* other arch specific needs */
}

struct timeclock {
      struct counter* counter,
      u32 adjusted_mult,
      cycle_t cycle_last,
      u32 flags;
      u64 xtime_nsec;
      s64 error;
      /* other timekeeping bits go here */
}

So given that, do you think you'd be ok with using just the first
counter structure?

Now there's sort of larger problem I've glossed over. Specifically in
assumption #1 up there. The bit about the interface to the monotonic
counter. Now many hardware counters wrap, and some wrap fairly
quickly. This means we need to have some sort of infrastructure to
periodically accumulate cycles into some "cycle store" value. As long
as the cycle store is 64bits wide, we probably don't have to worry
about overflows  (if I recall 64bits at 1GHZ gives us ~500 years).

Now, currently the timekeeping core does this for the active in-use
clocksource.  However, if we have a number of counter structs that are
being used in different contexts, maybe three registered for
timekeeping, and a few more for different types of timestamping (maybe
audio, networking, maybe even performance counters?), we suddenly have
to do the accumulation step on a quite a few counters to avoid
wrapping.

You dodged this accumulation infrastructure in your patch, by just
accumulating at read time. This works, as long as you can guarantee
that read events occur more often then the wrap frequency. And in most
cases that's probably not too hard, but with some in-developement
work, like the -rt patches, kernel work (even most interrupt
processing) can be deferred by high priority tasks for an unlimited
amount of time.

So this requires thinking this through maybe a bit more, trying to
figure out how to create a guaranteed accumulation frequency, but only
do so on counters that are really actively in use (we don't want to
accumulate on counters that no one cares about). Its probably not too
much work, but we may want to consider other approaches as well.

Another issue that multiple clocksources can cause, is dealing with
time intervals between clocksources. Different clocksources  may be
driven by different crystals, so they will drift apart. Also since the
clocksource used for timekeeping is adjusted by adjtimex(), you'll
likely have to deal with small differences in system time intervals
and clocksource time intervals.

I see you've maybe tried to address some of this with the following
time_sync patch, but I'm not sure I've totally grokked that patch yet.


Anyway, sorry to ramble on so much.  I'm really interested in your
work, its really interesting! But we might want to make sure the right
changes are being made to the right place so we don't get too much
confusion with the same variables meaning different things in
different contexts.

thanks
-john
