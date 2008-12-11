From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 08/11] clocksource: allow usage independent of
	timekeeping.c
Date: Thu, 11 Dec 2008 13:11:37 +0100
Message-ID: <1228997497.26315.106.camel@ecld0pohly>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-3-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-5-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-6-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-7-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-8-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-9-git-send-email-patrick.ohly@intel.com>
	 <1f1b08da0812051305hdca5b4bs1662368cda86255d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>
To: john stultz <johnstul@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49384 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044AbYLKMLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 07:11:44 -0500
In-Reply-To: <1f1b08da0812051305hdca5b4bs1662368cda86255d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-05 at 21:05 +0000, john stultz wrote:
> On Wed, Nov 19, 2008 at 4:08 AM, Patrick Ohly <patrick.ohly@intel.com> wrote:
> > So far struct clocksource acted as the interface between time/timekeeping
> > and hardware. This patch generalizes the concept so that the same
> > interface can also be used in other contexts.
> 
> Hey Patrick,
>    Sorry for not noticing this thread earlier!

No problem, it's not holding up anything. The question of how to extend
skb hasn't been settled either. Thanks for taking the time to consider
it.

> > The extensions in this patch add code which turns the raw cycle count
> > provided by hardware into a continously increasing time value. This
> > reuses fields also used by timekeeping.c. Because of slightly different
> > semantic (__get_nsec_offset does not update cycle_last, clocksource_read_ns
> > does that transparently) timekeeping.c was not modified to use the
> > generalized code.
> 
> Hrm.. I'm a little wary here. Your patch basically creates new
> semantics to how the clocksource structure is used,  which will likely
> cause confusion.

That's true. I could keep the code separate, if that helps. I just
didn't want to duplicate the whole structure definition.

>   I'll agree that the clocksource structure has been
> somewhat more cluttered with timekeeping-isms then I'd prefer, so
> maybe your patches give us the need to clean it up and better separate
> the hardware clocksource accessor information and the timekeeping
> state.
> 
> So to be clear, let me see if I understand your needs from your patch:
> 
> 1) Need an interface to a counter, who's interface monotonically increases.
> 2) Need to translate the counter to nanoseconds and nanoseconds back
> to the counter

There are two additional ways of using the counter:
* Get nanosecond delay measurements (clocksource_read_ns). Calling this
  "resets" the counter.
* Get a continously increasing timer value 
  (clocksource_init_time/clocksource_read_time). The clock is only reset
  when calling clocksource_init_time().

The two are mutually exclusive because clocksource_read_time() depends
on clocksource_read_ns(). If this is too confusing, then
clocksource_read_ns() could be turned into an internal helper function.
I left it in the header because there might be other uses for it. The
rest of the patches only needs clocksource_read_time().

Nanoseconds never have to be converted back to the counter. That
wouldn't be possible anyway (hardware counter might roll over, whereas
the clock counts nanoseconds in a 64 bit value and thus will last longer
than the hardware it runs on).

> 3) The counter will likely not be registered for use in timekeeping
> 4) The counter's sense of time will not be steered via frequency adjustments.
> 
> Is that about the right set of assumptions?

About right ;-)

> So if we break the clocksource structure into two portions (ignore
> name deatils for now)
> 
>  strucut counter{
>       char* name,
>       u32 mult,
>       u32 shift,
>       cycle_t mask,
>       cycle_t (*read)(struct counter*);
>       cycle_t (*vread)(void);
> 
>      /* bits needed here for real monotonic interface, more on that below */
> 
>     /* other arch specific needs */
> }
> 
> struct timeclock {
>       struct counter* counter,
>       u32 adjusted_mult,
>       cycle_t cycle_last,
>       u32 flags;
>       u64 xtime_nsec;
>       s64 error;
>       /* other timekeeping bits go here */
> }
> 
> So given that, do you think you'd be ok with using just the first
> counter structure?

Some additional members must be moved to struct counter:
* cycle_last (for the overflow handling)
* xtime_nsec (for the continously increasing timer)

Except from those the first struct is okay.

> Now there's sort of larger problem I've glossed over. Specifically in
> assumption #1 up there. The bit about the interface to the monotonic
> counter. Now many hardware counters wrap, and some wrap fairly
> quickly.
[...]
> You dodged this accumulation infrastructure in your patch, by just
> accumulating at read time. This works, as long as you can guarantee
> that read events occur more often then the wrap frequency.

Exactly. My plan was that the user of such a custom clocksource is
responsible for querying it often enough so that clocksource_read_ns()
can detect the wrap around. This works in the context of PTP (which
causes regular events). Network driver developers must be a bit careful
when there is no active PTP daemon: either they reinitialize the timer
when it starts to get used or probe it automatically after certain
delays.

>  And in most
> cases that's probably not too hard, but with some in-developement
> work, like the -rt patches, kernel work (even most interrupt
> processing) can be deferred by high priority tasks for an unlimited
> amount of time.

I'm not sure what can be done in such a case. Use decent hardware which
doesn't wrap around so quickly, I guess. It's not an issue with the
Intel NIC (sorry for the advertising... ;-)

> Another issue that multiple clocksources can cause, is dealing with
> time intervals between clocksources. Different clocksources  may be
> driven by different crystals, so they will drift apart. Also since the
> clocksource used for timekeeping is adjusted by adjtimex(), you'll
> likely have to deal with small differences in system time intervals
> and clocksource time intervals.
> 
> I see you've maybe tried to address some of this with the following
> time_sync patch, but I'm not sure I've totally grokked that patch yet.

The clocksource API extension and the time sync code are independent at
the moment: the time sync code assumes that it gets two, usually
increasing timer values and tries to match them by measuring skew and
drift between them. If the timer values jump, then the sync code adapts
these values accordingly.

I don't think it will be necessary to add something like adjtimex() to a
clocksource. Either the hardware supports it natively (like the Intel
NIC does, sorry again), or the current time sync deals with frequency
changes by adapting the drift factor.

> Anyway, sorry to ramble on so much.  I'm really interested in your
> work, its really interesting! But we might want to make sure the right
> changes are being made to the right place so we don't get too much
> confusion with the same variables meaning different things in
> different contexts.

Thanks for your comments. I agree that splitting the structures would
help. But the variables really have the same meaning. They are just used
in different functions.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

