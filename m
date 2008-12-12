From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 08/11] clocksource: allow usage independent of
	timekeeping.c
Date: Fri, 12 Dec 2008 09:50:14 +0100
Message-ID: <1229071814.18038.38.camel@ecld0pohly>
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
	 <1229034208.6801.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>
To: john stultz <johnstul@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42969 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756150AbYLLIuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 03:50:18 -0500
In-Reply-To: <1229034208.6801.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-11 at 22:23 +0000, john stultz wrote:
> On Thu, 2008-12-11 at 13:11 +0100, Patrick Ohly wrote:
> > That's true. I could keep the code separate, if that helps. I just
> > didn't want to duplicate the whole structure definition.
> 
> I think either keeping it separate, using your own structure, or
> properly splitting out the  counter / time-clock interface would be the
> way to go.

Okay, will do that. I'll try to do it so that later the clocksource can
be rewritten so that it uses the same definition.

> > There are two additional ways of using the counter:
> > * Get nanosecond delay measurements (clocksource_read_ns). Calling this
> >   "resets" the counter.
> 
> Just so I understand, do you mean clocksource_read_ns() returns the
> number of nanoseconds since the last call to clocksource_read_ns()?

Yes.

> Why exactly is this useful, as opposed to creating a monotonically
> increasing function which can be sampled and the state is managed by the
> users of the interface?

The monotonically increasing function already is based on a stateful
function which calculcates the delta; calculating the original delta
based on a derived value didn't seem right. But I don't really care much
about this part of the API, so I'll just make it internal.

> > * Get a continously increasing timer value 
> >   (clocksource_init_time/clocksource_read_time). The clock is only reset
> >   when calling clocksource_init_time().
> 
> So a monotonic 64bit wide counter. Close to what I described above. Is
> there actually a  need for it to reset ever?

Perhaps. A device might decide to reset the time each time hardware time
stamping is activated.

> > Some additional members must be moved to struct counter:
> > * cycle_last (for the overflow handling)
> > * xtime_nsec (for the continously increasing timer)
> 
> Hmm. I'd still prefer those values to be stored elsewhere. As you add
> state to the structure, that limits how the structure can be used. For
> instance, if cycles_last and xtime_nsec are in the counter structure,
> then that means one counter could not be used for both timekeeping and
> the hardware time-stamping you're doing.

The clean solution would be
* struct cyclecounter: abstract API to access hardware cycle counter
  The cycle counter may roll over relatively quickly. The implementor
  needs to provide information about the width of the counter and its
  frequency.
* struct timecounter: turns cycles from one cyclecounter into a 
  nanosecond count
  Must detect and deal with cycle counter overflows. Uses a 64 bit
  counter for time, so it itself doesn't overflow (unless we build
  hardware that runs for a *really* long time).

Now, should struct timecounter contain a struct cyclecounter or a
pointer to it? A pointer is more flexible, but overkill for the usage I
had in mind. I'll use a pointer anyway, just in case.

> Instead that state should be stored in the timekeeping and timestamping
> structures respectively.

I'm not sure whether timestamping can be separated from timekeeping: it
depends on the same cycle counter state as the timekeeping.

> > > You dodged this accumulation infrastructure in your patch, by just
> > > accumulating at read time. This works, as long as you can guarantee
> > > that read events occur more often then the wrap frequency.
> > 
> > Exactly. My plan was that the user of such a custom clocksource is
> > responsible for querying it often enough so that clocksource_read_ns()
> > can detect the wrap around.
> 
> Right, however my point quoted below was that this will likely break in
> the -rt kernel, since those users may be deferred for a undefined amount
> of time. So we'll need to do something here.

If the code isn't called often enough to deal with the regular PTP Sync
messages (sent every two seconds), then such a system would already have
quite a few other problems.

> > >  And in most
> > > cases that's probably not too hard, but with some in-developement
> > > work, like the -rt patches, kernel work (even most interrupt
> > > processing) can be deferred by high priority tasks for an unlimited
> > > amount of time.
> > 
> > I'm not sure what can be done in such a case. Use decent hardware which
> > doesn't wrap around so quickly, I guess. It's not an issue with the
> > Intel NIC (sorry for the advertising... ;-)
> 
> Well, I think it would be good to create a infrastructure that will work
> on most hardware.

Most hardware doesn't have hardware time stamping. Is there any hardware
which has hardware time stamping, but only with such a limited counter
that we run into this problem?

I agree that this problem needs to be taken into account now (while
designing these data structures) and be addressed as soon as it becomes
necessary - but not sooner. Otherwise we might end up with dead code
that isn't used at all.

> And I think it can work, but in order to make it work cleanly, we'll
> have to have some form of accumulation infrastructure, which will not be
> able to be deferred.
> 
> However, some careful thought will be needed here, so that we don't
> create latencies by wasting time sampling unused hardware counters in
> the hardirq context.

Currently the structures are owned by the device driver which owns the
hardware. Perhaps the device driver could register the structure with
such an accumulation infrastructure if the driver itself cannot
guarantee that it will check the cycle counter often enough. Concurrent
access to the cycle counter hardware and state could make this tricky.

This goes into areas where I have no experience at all, so I would
depend on others to provide that code.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

