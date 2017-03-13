From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/atm: warning in alloc_tx/__might_sleep
Date: Mon, 13 Mar 2017 18:43:51 +0100
Message-ID: <CAAeHK+z=KB8+Gy43BpFVG+bbfsQzvX59KFbftvipPefghsUKcQ@mail.gmail.com>
References: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
 <1484145426.1643.7.camel@gmail.com> <20170111194525.GA16375@dhcp22.suse.cz>
 <20170111194645.GM16365@dhcp22.suse.cz> <CAM_iQpWqCaHp2OxdaTOvJrf5vuvPn=rVGTvpGuZMEoBNC95EEQ@mail.gmail.com>
 <1484217654.1643.12.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Michal Hocko <mhocko@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484217654.1643.12.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2017 at 11:40 AM, Chas Williams <3chas3@gmail.com> wrote:
> On Wed, 2017-01-11 at 20:36 -0800, Cong Wang wrote:
>> On Wed, Jan 11, 2017 at 11:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Wed 11-01-17 20:45:25, Michal Hocko wrote:
>> >> On Wed 11-01-17 09:37:06, Chas Williams wrote:
>> >> > On Mon, 2017-01-09 at 18:20 +0100, Andrey Konovalov wrote:
>> >> > > Hi!
>> >> > >
>> >> > > I've got the following error report while running the syzkaller fuzzer.
>> >> > >
>> >> > > On commit a121103c922847ba5010819a3f250f1f7fc84ab8 (4.10-rc3).
>> >> > >
>> >> > > A reproducer is attached.
>> >> > >
>> >> > > ------------[ cut here ]------------
>> >> > > WARNING: CPU: 0 PID: 4114 at kernel/sched/core.c:7737 __might_sleep+0x149/0x1a0
>> >> > > do not call blocking ops when !TASK_RUNNING; state=1 set at
>> >> > > [<ffffffff813fcb22>] prepare_to_wait+0x182/0x530
>> >> > > Modules linked in:
>> >> > > CPU: 0 PID: 4114 Comm: a.out Not tainted 4.10.0-rc3+ #59
>> >> > > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> >> > > Call Trace:
>> >> > >  __dump_stack lib/dump_stack.c:15
>> >> > >  dump_stack+0x292/0x398 lib/dump_stack.c:51
>> >> > >  __warn+0x19f/0x1e0 kernel/panic.c:547
>> >> > >  warn_slowpath_fmt+0xc5/0x110 kernel/panic.c:562
>> >> > >  __might_sleep+0x149/0x1a0 kernel/sched/core.c:7732
>> >> > >  slab_pre_alloc_hook mm/slab.h:408
>> >> > >  slab_alloc_node mm/slub.c:2634
>> >> > >  kmem_cache_alloc_node+0x14a/0x280 mm/slub.c:2744
>> >> > >  __alloc_skb+0x10f/0x800 net/core/skbuff.c:219
>> >> > >  alloc_skb ./include/linux/skbuff.h:926
>> >> > >  alloc_tx net/atm/common.c:75
>> >> >
>> >> > This is likely alloc_skb(..., GFP_KERNEL) in alloc_tx().  The simplest
>> >> > fix for this would be simply to switch this GFP_ATOMIC.  See if this is
>> >> > any better.
>> >> >
>> >> > diff --git a/net/atm/common.c b/net/atm/common.c
>> >> > index a3ca922..d84220c 100644
>> >> > --- a/net/atm/common.c
>> >> > +++ b/net/atm/common.c
>> >> > @@ -72,7 +72,7 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
>> >> >                      sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
>> >> >             return NULL;
>> >> >     }
>> >> > -   while (!(skb = alloc_skb(size, GFP_KERNEL)))
>> >> > +   while (!(skb = alloc_skb(size, GFP_ATOMIC)))
>> >> >             schedule();
>> >> >     pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
>> >> >     atomic_add(skb->truesize, &sk->sk_wmem_alloc);
>> >>
>> >> Blee, this code is just horrendous. But the "fix" is obviously broken!
>> >> schedule() is just a noop if you do not change the task state and what
>> >> you are just asking for is a never failing non sleeping allocation - aka
>> >> a busy loop in the kernel!
>> >
>> > And btw. this while loop should be really turned into GFP_KERNEL |
>> > __GFP_NOFAIL with and explanation why this allocation cannot possibly
>> > fail.
>>
>> I think a nested loop is quite unnecessary, probably due to the code itself
>> is pretty old. The alloc_tx() is in the outer loop, the alloc_skb() is
>> in the inner
>> loop, both seem to wait for a successful GFP allocation. The inner one
>> is even more unnecessary.
>>
>> Of course, I am not surprised MM may already have a mechanism to do
>> the similar logic.
>>
>> There maybe some reason ATM needs such a logic, although other proto
>> could handle skb allocation failure quite well in ->sendmsg().
>
>
> I can't think of any particular reason that it needs this loop here.  I suspect
> that the loop for alloc_tx() predates the wait logic in ->sendmsg() and that the
> original looping was in alloc_tx() initially and was simply never removed.  Changes
> here would date back to before the git conversion.
>

Hi,

I'm still seeing this on 4495c08e84729385774601b5146d51d9e5849f81 (4.11-rc2).

Thanks!
