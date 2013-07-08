From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Mon, 8 Jul 2013 12:59:38 -0700
Message-ID: <20130708125938.11ea37b4@nehalam.linuxnetplumber.net>
References: <20130708132034.17639.4396.stgit@ladj378.jer.intel.com>
	<CA+55aFxgrOtsv7vCtic97ehpvqyezCzDcyqHVD+821BiTuiRtw@mail.gmail.com>
	<51DAF373.4040606@linux.intel.com>
	<CA+55aFwWAmHhYaPWVm7rsqiD9+RhDPpgVC1yWc0oNmP38bty4Q@mail.gmail.com>
	<51DB16FC.7060003@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51DB16FC.7060003@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Jul 2013 22:46:04 +0300
Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:

> On 08/07/2013 22:37, Linus Torvalds wrote:
> > On Mon, Jul 8, 2013 at 10:14 AM, Eliezer Tamir
> > <eliezer.tamir@linux.intel.com> wrote:
> >>
> >> I think there is no way for the compiler to know the value of
> >> can_busy_loop at compile time. It depends on the replies we get
> >> from polling the sockets. ll_flag was there to make sure the compiler
> >> will know when things are defined out.
> > 
> > No, my point was that we want to handle the easily seen register test
> > first, and not even have to load current().
> > 
> > The compiler may end up scheduling the code to load current anyway,
> > but the way you wrote it it's pretty much guaranteed that it will do
> > it.
> 
> I see. OK.
> 
> > In fact, I'd argue for initializing start_time to zero, and have the
> > "have we timed out" logic load it only if necessary, rather than
> > initializing it based on whether POLL_BUSY_WAIT was set or not.
> > Because one common case - even with POLL_BUSY_WAIT - is that we go
> > through the loop exactly once, and the data exists on the very first
> > try. And that is in fact the case we want to optimize and not do any
> > extra work for at all.
> > 
> > So I would actually argue that the whole timeout code might as well be
> > something like
> > 
> >     unsigned long start_time = 0;
> >     ...
> >     if (want_busy_poll && !need_resched()) {
> >         unsigned long now = busy_poll_sched_clock();
> >         if (!start_time) {
> >             start_time = now + sysctl.busypoll;
> >             continue;
> >         }
> >         if (time_before(start_time, now))
> >             continue;
> >     }
> > 
> 
> OK.

Since this is special case in the hot path, it looks like a good case
for static branch logic.
