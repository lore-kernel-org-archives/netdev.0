From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Mon, 08 Jul 2013 20:14:27 +0300
Message-ID: <51DAF373.4040606@linux.intel.com>
References: <20130708132034.17639.4396.stgit@ladj378.jer.intel.com> <CA+55aFxgrOtsv7vCtic97ehpvqyezCzDcyqHVD+821BiTuiRtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46481 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab3GHROe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 13:14:34 -0400
In-Reply-To: <CA+55aFxgrOtsv7vCtic97ehpvqyezCzDcyqHVD+821BiTuiRtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 19:37, Linus Torvalds wrote:
> On Mon, Jul 8, 2013 at 6:20 AM, Eliezer Tamir
> <eliezer.tamir@linux.intel.com> wrote:
>>
>> -               /* only if on, have sockets with POLL_LL and not out of time */
>> -               if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
>> +               /* only if found POLL_BUSY_LOOP sockets && not out of time */
>> +               if (!need_resched() && can_busy_loop &&
>> +                   busy_loop_range(busy_start, busy_end))
>>                         continue;
> 
> Better, but still horribly ugly. I also suspect the need_resched()
> test should be done after testing can_busy_loop, just in case the
> compiler can avoid having to load things off the current pointer.

I think there is no way for the compiler to know the value of
can_busy_loop at compile time. It depends on the replies we get
from polling the sockets. ll_flag was there to make sure the compiler
will know when things are defined out.

I would be very happy to hear suggestions for better names for things.

> I also think that we should clear busy_flag if we don't continue, no?

I'm not sure. If the time the user specified to busy-poll is not over,
and the reason we didn't do it last time was that the sockets did not
report that they have valid polling information (perhaps a route changed
or a device we reset), but how we do have sockets that can busy-poll,
wouldn't polling be the right thing to do?

> I also don't understand why the code keeps both busy_start and
> busy_end around. It all looks completely pointless. Why have two
> variables, and why make the comparisons more complicated, and the code
> look more complex than it actually is?

Originally the code used time_after() and only kept the start time.
People on the list voiced concerns that using sched_clock() might be
risky since we may end up on another CPU with a different time.

We used sched_clock() because we don't need the time to be very
accurate, this is only a cut-off time to make sure we never spin
forever when no event ever happens.

I then changed this to use time_in_range() so that if we wake up with a
completely random time, we will be out of the range and fail safely.

If you think that is wrong we can go back to use time_after().

> I also suspect there's a lot of other micro-optimizations that could
> be done: while keeping *two* 64-bit timeouts is just completely insane
> on a 32-bit architecture, keeping even just one is debatable. I
> suspect the timeouts should be just "unsigned long", so that 32-bit
> architectures don't bother with unnecessary 64-bit clocks. 32-bit
> clocks are several seconds even if you count nanoseconds, and you
> actually only do microseconds anyway (so instead of shifting the
> microseconds left by ten like you do, shift the nanoseconds of
> sched_clock right by ten, and now you only need 32-bit values).

OK, but please answer my questions above, it is starting to be late here
and I would really like to send a fix that everyone will find
acceptable today.

Thanks,
Eliezer
