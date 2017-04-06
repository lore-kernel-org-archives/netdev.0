From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Thu, 6 Apr 2017 12:26:48 +0200
Message-ID: <20170406102648.4cycknb2jk5ftovh@hirez.programming.kicks-ass.net>
References: <1491107321.13631.33.camel@gmx.de>
 <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
 <1491362429.4536.77.camel@gmx.de>
 <CAM_iQpVTmDfATw1HMPE9NnRBNnhgidz+UZOQDqyeq2uo0=c-+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Galbraith <efault@gmx.de>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpVTmDfATw1HMPE9NnRBNnhgidz+UZOQDqyeq2uo0=c-+g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 04, 2017 at 10:25:19PM -0700, Cong Wang wrote:
> On Tue, Apr 4, 2017 at 8:20 PM, Mike Galbraith <efault@gmx.de> wrote:
> > -               while (some_qdisc_is_busy(dev))
> > -                       yield();
> > +               swait_event_timeout(swait, !some_qdisc_is_busy(dev), 1);
> >  }
> 
> I don't see why this is an improvement even if I don't care about the
> hardcoded timeout for now... Why the scheduler can make a better
> decision with swait_event_timeout() than with cond_resched()?

cond_resched() might be a no-op.

and doing yield() will result in a priority inversion deadlock. Imagine
the task doing yield() being the top priority (fifo99) task in the
system. Then it will simply spin forever, not giving whatever task is
required to make your condition true time to run.
