From: john stultz <johnstul@us.ibm.com>
Subject: Re: [RFC PATCH 08/11] clocksource: allow usage independent of
	timekeeping.c
Date: Thu, 11 Dec 2008 14:23:28 -0800
Message-ID: <1229034208.6801.32.camel@localhost.localdomain>
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
	 <1228997497.26315.106.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:46669 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863AbYLKWXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:23:42 -0500
In-Reply-To: <1228997497.26315.106.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-11 at 13:11 +0100, Patrick Ohly wrote:
> On Fri, 2008-12-05 at 21:05 +0000, john stultz wrote:
> > On Wed, Nov 19, 2008 at 4:08 AM, Patrick Ohly <patrick.ohly@intel.com> wrote:
> > > The extensions in this patch add code which turns the raw cycle count
> > > provided by hardware into a continously increasing time value. This
> > > reuses fields also used by timekeeping.c. Because of slightly different
> > > semantic (__get_nsec_offset does not update cycle_last, clocksource_read_ns
> > > does that transparently) timekeeping.c was not modified to use the
> > > generalized code.
> > 
> > Hrm.. I'm a little wary here. Your patch basically creates new
> > semantics to how the clocksource structure is used,  which will likely
> > cause confusion.
> 
> That's true. I could keep the code separate, if that helps. I just
> didn't want to duplicate the whole structure definition.

I think either keeping it separate, using your own structure, or
properly splitting out the  counter / time-clock interface would be the
way to go.

> >   I'll agree that the clocksource structure has been
> > somewhat more cluttered with timekeeping-isms then I'd prefer, so
> > maybe your patches give us the need to clean it up and better separate
> > the hardware clocksource accessor information and the timekeeping
> > state.
> > 
> > So to be clear, let me see if I understand your needs from your patch:
> > 
> > 1) Need an interface to a counter, who's interface monotonically increases.
> > 2) Need to translate the counter to nanoseconds and nanoseconds back
> > to the counter
> 
> There are two additional ways of using the counter:
> * Get nanosecond delay measurements (clocksource_read_ns). Calling this
>   "resets" the counter.

Just so I understand, do you mean clocksource_read_ns() returns the
number of nanoseconds since the last call to clocksource_read_ns() ?

That seems like an odd interface to define, since effectively you're
storing state inside the interface. 

Why exactly is this useful, as opposed to creating a monotonically
increasing function which can be sampled and the state is managed by the
users of the interface?


> * Get a continously increasing timer value 
>   (clocksource_init_time/clocksource_read_time). The clock is only reset
>   when calling clocksource_init_time().

So a monotonic 64bit wide counter. Close to what I described above. Is
there actually a  need for it to reset ever?


> The two are mutually exclusive because clocksource_read_time() depends
> on clocksource_read_ns(). If this is too confusing, then
> clocksource_read_ns() could be turned into an internal helper function.
> I left it in the header because there might be other uses for it. The
> rest of the patches only needs clocksource_read_time().

Yea. It seems like an odd interface, as the internal state seems to
limit its use.

> Nanoseconds never have to be converted back to the counter. That
> wouldn't be possible anyway (hardware counter might roll over, whereas
> the clock counts nanoseconds in a 64 bit value and thus will last longer
> than the hardware it runs on).

Right, but if its a monotonically increasing 64bit counter, rollover
isn't likely an issue. I think we're basically communicating the same
idea here, just the question is do you want to make the interface
provide nanoseconds or cycles. 


> > 3) The counter will likely not be registered for use in timekeeping
> > 4) The counter's sense of time will not be steered via frequency adjustments.
> > 
> > Is that about the right set of assumptions?
> 
> About right ;-)
> 
> > So if we break the clocksource structure into two portions (ignore
> > name deatils for now)
> > 
> >  strucut counter{
> >       char* name,
> >       u32 mult,
> >       u32 shift,
> >       cycle_t mask,
> >       cycle_t (*read)(struct counter*);
> >       cycle_t (*vread)(void);
> > 
> >      /* bits needed here for real monotonic interface, more on that below */
> > 
> >     /* other arch specific needs */
> > }
> > 
> > struct timeclock {
> >       struct counter* counter,
> >       u32 adjusted_mult,
> >       cycle_t cycle_last,
> >       u32 flags;
> >       u64 xtime_nsec;
> >       s64 error;
> >       /* other timekeeping bits go here */
> > }
> > 
> > So given that, do you think you'd be ok with using just the first
> > counter structure?
> 
> Some additional members must be moved to struct counter:
> * cycle_last (for the overflow handling)
> * xtime_nsec (for the continously increasing timer)

Hmm. I'd still prefer those values to be stored elsewhere. As you add
state to the structure, that limits how the structure can be used. For
instance, if cycles_last and xtime_nsec are in the counter structure,
then that means one counter could not be used for both timekeeping and
the hardware time-stamping you're doing.

Instead that state should be stored in the timekeeping and timestamping
structures respectively.

> Except from those the first struct is okay.
> 
> > Now there's sort of larger problem I've glossed over. Specifically in
> > assumption #1 up there. The bit about the interface to the monotonic
> > counter. Now many hardware counters wrap, and some wrap fairly
> > quickly.
> [...]
> > You dodged this accumulation infrastructure in your patch, by just
> > accumulating at read time. This works, as long as you can guarantee
> > that read events occur more often then the wrap frequency.
> 
> Exactly. My plan was that the user of such a custom clocksource is
> responsible for querying it often enough so that clocksource_read_ns()
> can detect the wrap around.

Right, however my point quoted below was that this will likely break in
the -rt kernel, since those users may be deferred for a undefined amount
of time. So we'll need to do something here.


> >  And in most
> > cases that's probably not too hard, but with some in-developement
> > work, like the -rt patches, kernel work (even most interrupt
> > processing) can be deferred by high priority tasks for an unlimited
> > amount of time.
> 
> I'm not sure what can be done in such a case. Use decent hardware which
> doesn't wrap around so quickly, I guess. It's not an issue with the
> Intel NIC (sorry for the advertising... ;-)

Well, I think it would be good to create a infrastructure that will work
on most hardware. 

And I think it can work, but in order to make it work cleanly, we'll
have to have some form of accumulation infrastructure, which will not be
able to be deferred.

However, some careful thought will be needed here, so that we don't
create latencies by wasting time sampling unused hardware counters in
the hardirq context.


> > Another issue that multiple clocksources can cause, is dealing with
> > time intervals between clocksources. Different clocksources  may be
> > driven by different crystals, so they will drift apart. Also since the
> > clocksource used for timekeeping is adjusted by adjtimex(), you'll
> > likely have to deal with small differences in system time intervals
> > and clocksource time intervals.
> > 
> > I see you've maybe tried to address some of this with the following
> > time_sync patch, but I'm not sure I've totally grokked that patch yet.
> 
> The clocksource API extension and the time sync code are independent at
> the moment: the time sync code assumes that it gets two, usually
> increasing timer values and tries to match them by measuring skew and
> drift between them. If the timer values jump, then the sync code adapts
> these values accordingly.

Ok. I'll have to spend some more time on that patch, but it sounds like
you're handling the issue.


> > Anyway, sorry to ramble on so much.  I'm really interested in your
> > work, its really interesting! But we might want to make sure the right
> > changes are being made to the right place so we don't get too much
> > confusion with the same variables meaning different things in
> > different contexts.
> 
> Thanks for your comments. I agree that splitting the structures would
> help. But the variables really have the same meaning. They are just used
> in different functions.

Err, you might be misunderstanding their current meaning. However, its
not your fault, as the naming is not as clear as I like.  For instance,
xtime_nsec stores the sub-nanoseconds (shifted up by clocksource->shift)
not represented in the xtime value.

So yes, while you likely want to keep similar state as the timekeeping
core does, I really think splitting it out fully is going to be the way
to go.

Thanks for the consideration of my comments! I look forward to your
future patches!
-john


