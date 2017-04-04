From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Tue, 4 Apr 2017 15:39:10 -0700
Message-ID: <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
References: <1491107321.13631.33.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491107321.13631.33.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 1, 2017 at 9:28 PM, Mike Galbraith <efault@gmx.de> wrote:
> Greetings network wizards,
>
> Quoting kernel/sched/core.c:
> /**
>  * yield - yield the current processor to other threads.
>  *
>  * Do not ever use this function, there's a 99% chance you're doing it wrong.
>  *
>  * The scheduler is at all times free to pick the calling task as the most
>  * eligible task to run, if removing the yield() call from your code breaks
>  * it, its already broken.
>  *
>  * Typical broken usage is:
>  *
>  * while (!event)
>  *      yield();
>  *
>  * where one assumes that yield() will let 'the other' process run that will
>  * make event true. If the current task is a SCHED_FIFO task that will never
>  * happen. Never use yield() as a progress guarantee!!
>  *
>  * If you want to use yield() to wait for something, use wait_event().
>  * If you want to use yield() to be 'nice' for others, use cond_resched().
>  * If you still want to use yield(), do not!
>  */
>
> Livelock can be triggered by setting kworkers to SCHED_FIFO, then
> suspend/resume.. you come back from sleepy-land with a spinning
> kworker.  For whatever reason, I can only do that with an enterprise
> like config, my standard config refuses to play, but no matter, it's
> "Typical broken usage".
>
> (yield() should be rendered dead)


Thanks for the report! Looks like a quick solution here is to replace
this yield() with cond_resched(), it is harder to really wait for
all qdisc's to transmit all packets.
