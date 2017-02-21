From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: use-after-free in tw_timer_handler
Date: Tue, 21 Feb 2017 13:40:24 +0300
Message-ID: <CACT4Y+azJjsfVMH6f-dnweoi5yrUb7ANNLU0YM29mY1Pn8WEHw@mail.gmail.com>
References: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
 <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
 <1485268138.16328.297.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+b=-XJCwofbCRo6BnKJRU=amd7pxYpNrGdPEFT0bAtJaQ@mail.gmail.com>
 <CANn89iK=5uPEDLpM6=JAKzJ=1GuSSiXw5b_8BrkVUvhYRi_9mw@mail.gmail.com>
 <CACT4Y+bRP9ffnXDJeOD5VkqFw+-cDHh4hEVzcnv3vnHh+vdqBQ@mail.gmail.com>
 <CAM_iQpXDtOY+A2pEqGeggBONnGawt=Xv6PdcWJpUB-4dqv4hpA@mail.gmail.com>
 <CACT4Y+ZR8aQsrfVBxtg45YYyNZsYqHvUDkRrqAgE=+v+8O1pDg@mail.gmail.com>
 <CAM_iQpWgUQiarfH9wkxEkCoFkwvKJt75uX4CP1-MUU6u_hkLYQ@mail.gmail.com> <CACT4Y+YqdkALRjYcPkHdF30DJQNviRwHgi0QnzyFWfbKzFA7fQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+YqdkALRjYcPkHdF30DJQNviRwHgi0QnzyFWfbKzFA7fQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2017 at 12:46 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Sat, Feb 18, 2017 at 1:30 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>>>>>
>>>>>>>> This code was changed a long time ago :
>>>>>>>>
>>>>>>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
>>>>>>>>
>>>>>>>> So I suspect a recent patch broke the logic.
>>>>>>>>
>>>>>>>> You might start a bisection :
>>>>>>>>
>>>>>>>> I would check if 4.7 and 4.8 trigger the issue you noticed.
>>>>>>>
>>>>>>>
>>>>>>> It happens with too low rate for bisecting (few times per day). I
>>>>>>> could add some additional checks into code, but I don't know what
>>>>>>> checks could be useful.
>>>>>>
>>>>>> If you can not tell if 4.7 and/or 4.8 have the problem, I am not sure
>>>>>> we are able to help.
>>>>>
>>>>>
>>>>> There are also chances that the problem is older.
>>>>>
>>>>> Looking at the code, this part of inet_twsk_purge looks fishy:
>>>>>
>>>>> 285                         if (unlikely((tw->tw_family != family) ||
>>>>> 286                                      atomic_read(&twsk_net(tw)->count))) {
>>>>>
>>>>> It uses net->count == 0 check to find the right sockets. But what if
>>>>> there are several nets with count == 0 in flight, can't there be
>>>>> several inet_twsk_purge calls running concurrently freeing each other
>>>>> sockets? If so it looks like inet_twsk_purge can call
>>>>> inet_twsk_deschedule_put twice for a socket. Namely, two calls for
>>>>> different nets discover the socket, check that net->count==0 and both
>>>>> call inet_twsk_deschedule_put. Shouldn't we just give inet_twsk_purge
>>>>> net that it needs to purge?
>>>>
>>>> I don't think this could happen, because cleanup_net() is called in a
>>>> work struct, and this work can't be scheduled twice, so there should
>>>> not be any parallel cleanup_net().
>>>>
>>>> Also, inet_twsk_deschedule_put() already waits for the flying timer,
>>>> net->count==0 at this point and all sockets in this netns are already
>>>> gone, so I don't know how a timer could be still fired after this.
>>>
>>>
>>> One thing that I noticed is that use-after-free always happens in
>>> tw_timer_handler, but never in timer code. This suggests that:
>>> 1. Whoever frees the struct waits for the timer mutex unlock.
>>> 2. Free happens almost at the same time as timer fires (otherwise the
>>> timer would probably be cancelled).
>>>
>>> That could happen if there is a race in timer code during cancellation
>>> or rearming. I understand that it's heavily stressed code, but who
>>> knows...
>>
>> Good point! I think this could happen since timer is deactivated before
>> unlinking the tw sock, so another CPU could find it and rearm the timer
>> during such window?
>>
>>>
>>> I still wonder if twsk_net(tw)->count==0 is the right condition. This
>>> net may not yet have been scheduled for destruction, but another task
>>> could pick it up and start destroying...
>>
>> Good question. net_exit_list is just a snapshot of the cleanup_list, so
>> it is true that inet_twsk_purge() could purge more netns'es than in
>> net_exit_list, but I don't see any problem with this, the work later can't
>> find the same twsck again since it is unlinked from hashtable.
>> Do you see otherwise?
>
> No, I don't see otherwise. But it's just something suspicious in the
> context of an elusive race that happens under load.
>
>>> Cong, do you have any ideas as to what debugging checks I could add to
>>> help track this down?
>>
>> I don't have any theory for the cause of this bug. Your point above actually
>> makes sense for me. Maybe you can add some code in between the following
>> code:
>>
>>         if (del_timer_sync(&tw->tw_timer))
>>                 inet_twsk_kill(tw);
>>
>> to verify is the timer is rearmed or not.
>
> Now looking at the reports more closely, I think that debug info is
> off-by-one, and the use-after-free happens on the net object on this
> line: __NET_INC_STATS(twsk_net(tw), LINUX_MIB_TIMEWAITKILLED).
>
> And this report is actually all correct:
>
> BUG: KASAN: use-after-free in tw_timer_handler+0xc3/0xd0
> net/ipv4/inet_timewait_sock.c:149 at addr ffff88018063a460
> Read of size 8 by task swapper/1/0
> CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.10.0-rc8+ #65
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> Call Trace:
>  <IRQ>
>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>  tw_timer_handler+0xc3/0xd0 net/ipv4/inet_timewait_sock.c:149
>  call_timer_fn+0x241/0x820 kernel/time/timer.c:1308
>  expire_timers kernel/time/timer.c:1348 [inline]
>  __run_timers+0x9e7/0xe90 kernel/time/timer.c:1642
>  run_timer_softirq+0x21/0x80 kernel/time/timer.c:1655
>  __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364 [inline]
>  irq_exit+0x1cc/0x200 kernel/softirq.c:405
>  exiting_irq arch/x86/include/asm/apic.h:658 [inline]
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:961
>  apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:707
>
> Object at ffff88018063a240, in cache net_namespace size: 6784
>
> Allocated:
> PID = 3270
>  kmem_cache_zalloc include/linux/slab.h:626 [inline]
>  net_alloc net/core/net_namespace.c:339 [inline]
>  copy_net_ns+0x196/0x530 net/core/net_namespace.c:379
>  create_new_namespaces+0x409/0x860 kernel/nsproxy.c:106
>  copy_namespaces+0x34d/0x420 kernel/nsproxy.c:164
>  copy_process.part.42+0x20c6/0x5fd0 kernel/fork.c:1664
>  copy_process kernel/fork.c:1486 [inline]
>  _do_fork+0x200/0xff0 kernel/fork.c:1942
>  SYSC_clone kernel/fork.c:2052 [inline]
>  SyS_clone+0x37/0x50 kernel/fork.c:2046
>  do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
>  return_from_SYSCALL_64+0x0/0x7a
>
> Freed:
> PID = 8056
>  kmem_cache_free+0x71/0x240 mm/slab.c:3762
>  net_free+0xd7/0x110 net/core/net_namespace.c:355
>  net_drop_ns+0x31/0x40 net/core/net_namespace.c:362
>  cleanup_net+0x7f2/0xa90 net/core/net_namespace.c:479
>  process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2098
>  worker_thread+0x223/0x1990 kernel/workqueue.c:2232
>  kthread+0x326/0x3f0 kernel/kthread.c:227
>  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
>
> The read is of size 8, but read of tw->tw_kill should be 4.
> We could also double check offset within the object and check if it
> matches what __NET_INC_STATS(twsk_net(tw)) reads.
>
> So the net is somehow freed while the timer is active.


Suspecting a race between inet_twsk_deschedule_put and
inet_twsk_reschedule, but don't see any bugs.

Can inet_twsk_deschedule_put run concurrently with inet_twsk_schedule
(not the reschedule)? That might explain the bug, but that's probably
not possible, right?

Starring at the code, this part looks wrong:

960 static inline int
961 __mod_timer(struct timer_list *timer, unsigned long expires, bool
pending_only)
962 {
...
975         if (timer_pending(timer)) {
976                 if (timer->expires == expires)
977                         return 1;
...
985                 base = lock_timer_base(timer, &flags);
987                 clk = base->clk;
988                 idx = calc_wheel_index(expires, clk);
995                 if (idx == timer_get_idx(timer)) {
996                         timer->expires = expires;
997                         ret = 1;
998                         goto out_unlock;
999                 }


We check timer_pending before taking the lock, and not re-check it
after taking the lock. So we can merely update timer->expires for a
non-pending timer and fail to requeue it. It's fine for pending_only
(as it has already fired), but not for !pending_only. Am I missing
something? But it still does not explain the original bug.
