From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Mon, 8 Jul 2013 12:37:06 -0700
Message-ID: <CA+55aFwWAmHhYaPWVm7rsqiD9+RhDPpgVC1yWc0oNmP38bty4Q@mail.gmail.com>
References: <20130708132034.17639.4396.stgit@ladj378.jer.intel.com>
	<CA+55aFxgrOtsv7vCtic97ehpvqyezCzDcyqHVD+821BiTuiRtw@mail.gmail.com>
	<51DAF373.4040606@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51DAF373.4040606@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 8, 2013 at 10:14 AM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
>
> I think there is no way for the compiler to know the value of
> can_busy_loop at compile time. It depends on the replies we get
> from polling the sockets. ll_flag was there to make sure the compiler
> will know when things are defined out.

No, my point was that we want to handle the easily seen register test
first, and not even have to load current().

The compiler may end up scheduling the code to load current anyway,
but the way you wrote it it's pretty much guaranteed that it will do
it.

>> I also think that we should clear busy_flag if we don't continue, no?
>
> I'm not sure. If the time the user specified to busy-poll is not over,
> and the reason we didn't do it last time was that the sockets did not
> report that they have valid polling information (perhaps a route changed
> or a device we reset), but how we do have sockets that can busy-poll,
> wouldn't polling be the right thing to do?

Well, we would have slept already, and then microseconds will have
passed. Also, if we schedule, we may overflow a 32-bit time which can
screw up the later optimization:

> Originally the code used time_after() and only kept the start time.
> People on the list voiced concerns that using sched_clock() might be
> risky since we may end up on another CPU with a different time.

No, I agree with the "don't call sched_clock() unless necessary".

It's the end_time I disagree with. There's no point. Just do the
start-time (preferably as just a "unsigned long" in microseconds), and
let it be.

In fact, I'd argue for initializing start_time to zero, and have the
"have we timed out" logic load it only if necessary, rather than
initializing it based on whether POLL_BUSY_WAIT was set or not.
Because one common case - even with POLL_BUSY_WAIT - is that we go
through the loop exactly once, and the data exists on the very first
try. And that is in fact the case we want to optimize and not do any
extra work for at all.

So I would actually argue that the whole timeout code might as well be
something like

    unsigned long start_time = 0;
    ...
    if (want_busy_poll && !need_resched()) {
        unsigned long now = busy_poll_sched_clock();
        if (!start_time) {
            start_time = now + sysctl.busypoll;
            continue;
        }
        if (time_before(start_time, now))
            continue;
    }

or similar. Just one time variable, and it doesn't even need to be
64-bit on 32-bit architectures. Which makes all the code generation
much simpler. And notice how this has basically no cost if we already
found data, because we won't even get here. So there's only cost if we
actually might want to busy-poll.

> OK, but please answer my questions above, it is starting to be late here
> and I would really like to send a fix that everyone will find
> acceptable today.

I think it's getting closer, and I'm ok with the last final details
being sorted out later. I just can't reasonably test any of my
suggestions, so I'd like to get it to a point where when I pull, I
don't feel like I'm pulling core code that I really detest. And the
VFS layer in particular I'm pretty attached to.

                  Linus
