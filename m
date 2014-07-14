From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [RFC 0/7] hrtimer: drop active hrtimer checks after adding it
Date: Mon, 14 Jul 2014 10:11:35 +0530
Message-ID: <CAKohpokECgtn_ZFYv-LEv8F2yqwVOgKcu6oNc_Zg9mm9-4BTow@mail.gmail.com>
References: <cover.1404888801.git.viresh.kumar@linaro.org>
	<alpine.DEB.2.10.1407092321130.4357@nanos>
	<20140710013456.GB6480@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lists linaro-kernel <linaro-kernel@lists.linaro.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Arvind Chauhan <arvind.chauhan@arm.com>,
	Preeti U Murthy <preeti@linux.vnet.ibm.com>,
	Kevin Hilman <khilman@linaro.org>,
	Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>
To: Frederic Weisbecker <fweisbec@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:55332 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaGNElf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 00:41:35 -0400
Received: by mail-oa0-f46.google.com with SMTP id m1so3654372oag.5
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 21:41:35 -0700 (PDT)
In-Reply-To: <20140710013456.GB6480@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On 10 July 2014 07:04, Frederic Weisbecker <fweisbec@gmail.com> wrote:
> On Wed, Jul 09, 2014 at 11:30:41PM +0200, Thomas Gleixner wrote:
>> On Wed, 9 Jul 2014, Viresh Kumar wrote:
>>
>> So your patch series drops active hrtimer checks after adding it,
>> according to your subject line.
>>
>> Quite useeul to drop something after adding it, right?

I meant "hrtimer" by "it". Will fix it in case this patchset is still required.

>> > As hrtimer_start*() never fails, hrtimer_active() is guaranteed to return '1'.
>> > So, there is no point calling hrtimer_active().
>>
>> Wrong as usual.

I cross-checked this with Frederic and Preeti before reaching out to
you, to make sure its not 'obviously stupid'. And still couldn't get it
right. :(

>> It's a common pattern that short timeouts are given which lead to
>> immediate expiry so the extra round through schedule is even more
>> pointless than the extra check.

Just wanted to confirm it again, you are talking about CPU being
interrupted by clockevent device's interrupt right after hrtimer_start*()
returns and before calling hrtimer_active()?

> It may be a common pattern but it's not obvious at all as is in the code
> except for timers gurus.
>
> It looks like error handling while it's actually an optimization.
>
> Also what about this pattern when it's used in interrupt or interrupt-disabled code?
> In this case the handler is not going to fire right away, unless it's enqueued
> on another CPU for unpinned timers.
>
> For example this code in tick_nohz_stop_sched_tick():
>
>           hrtimer_start(&ts->sched_timer, expires, HRTIMER_MODE_ABS_PINNED);
>           /* Check, if the timer was already in the past */
>           if (hrtimer_active(&ts->sched_timer))
>                  goto out;
>
> It's not clear what this is handling. Concurrent immediate callback expiration from another CPU?
> But the timer is pinned local so it can't execute right away between hrtimer_start() and hrtimer_active()
> check...

Actually I was concerned about other cases as well.

- Timeouts

I do agree that an extra check is better than an extra round of schedule().
But this is already achieved without calling hrtimer_active(), isn't it?

All these timeout hrtimers have hrtimer_wakeup() as there handler (as
these are initialized with: hrtimer_init_sleeper()).

And on expiration hrtimer_wakeup() does this:  t->task = NULL;

So would this extra call to hrtimer_active() make any difference?

- Process-context: sched changes

I am not sure if scheduler routines: start_bandwidth_timer() and
start_dl_timer() would get called *only* with interrupts disabled.

But, it doesn't look obvious that the optimization Thomas mentioned
earlier is relevant here as well. These might be added here for error
checking.

I might be wrong here as I don't have any understanding of this code
and so sorry in advance.


Note: My tree is monitored by kbuild-bot and these changes are under
testing for over a week now. And I haven't received any reports of the
WARN() firing in __hrtimer_start_range_ns().. Probably these short
timeouts aren't getting hit at all by bot's tests.

--
viresh
