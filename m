From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: use-after-free in tw_timer_handler
Date: Tue, 24 Jan 2017 06:28:58 -0800
Message-ID: <1485268138.16328.297.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
         <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-01-23 at 11:23 +0100, Dmitry Vyukov wrote:
> On Mon, Jan 23, 2017 at 11:19 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > Hello,
> >
> > While running syzkaller fuzzer I started seeing use-after-frees in
> > tw_timer_handler. It happens with very low frequency, so far I've seen
> > 22 of them. But all reports look consistent, so I would assume that it
> > is real, just requires a very tricky race to happen. I've stared
> > seeing it around Jan 17, however I did not update kernels for some
> > time before that so potentially the issues was introduced somewhat
> > earlier. Or maybe fuzzer just figured how to trigger it, and the bug
> > is actually old. I am seeing it on all of torvalds/linux-next/mmotm,
> > some commits if it matters: 7a308bb3016f57e5be11a677d15b821536419d36,
> > 5cf7a0f3442b2312326c39f571d637669a478235,
> > c497f8d17246720afe680ea1a8fa6e48e75af852.
> > Majority of reports points to net_drop_ns as the offending free, but
> > it may be red herring. Since the access happens in timer, it can
> > happen long after free and the memory could have been reused. I've
> > also seen few where the access in tw_timer_handler is reported as
> > out-of-bounds on task_struct and on struct filename.
> 
> 
> 
> I've briefly skimmed through the code. Assuming that it requires a
> very tricky race to be triggered, the most suspicious looks
> inet_twsk_deschedule_put vs __inet_twsk_schedule:
> 
> void inet_twsk_deschedule_put(struct inet_timewait_sock *tw)
> {
>         if (del_timer_sync(&tw->tw_timer))
>                 inet_twsk_kill(tw);
>         inet_twsk_put(tw);
> }
> 
> void __inet_twsk_schedule(struct inet_timewait_sock *tw, int timeo, bool rearm)
> {
>         tw->tw_kill = timeo <= 4*HZ;
>         if (!rearm) {
>                 BUG_ON(mod_timer(&tw->tw_timer, jiffies + timeo));
>                 atomic_inc(&tw->tw_dr->tw_count);
>         } else {
>                 mod_timer_pending(&tw->tw_timer, jiffies + timeo);
>         }
> }
> 
> Can't it somehow end up rearming already deleted timer? Or maybe the
> first mod_timer happens after del_timer_sync?

This code was changed a long time ago :

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054

So I suspect a recent patch broke the logic.

You might start a bisection :

I would check if 4.7 and 4.8 trigger the issue you noticed.

Thanks.
