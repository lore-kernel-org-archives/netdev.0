From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: deadlock between ip_expire/sch_direct_xmit
Date: Mon, 20 Mar 2017 10:59:54 +0100
Message-ID: <CACT4Y+a0sL_XZftyNoAyEVZEo6VHQe2wPRrPgAMnvG32VbMw6g@mail.gmail.com>
References: <CACT4Y+ZrHr0Cqw5RPeZ6QW16auOPyKSCOea6AciHBswAT3t14Q@mail.gmail.com>
 <1489502504.28631.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+bLJtO55iP5uNPZV+_B+H5-Z2gOiF26sXDmWk9L0rESsw@mail.gmail.com>
 <CANn89iLO1neA3-4ipYr==n_3iDXDXgY0MCkPkp=cEf8n4w6i=g@mail.gmail.com> <CAM_iQpV9iyOHoYUUO=wwHWz0GpUoQzwX+f3DSxwJo54eCcqH2g@mail.gmail.com>
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
        Jamal Hadi Salim <jhs@mojatatu.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpV9iyOHoYUUO=wwHWz0GpUoQzwX+f3DSxwJo54eCcqH2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 14, 2017 at 5:41 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Mar 14, 2017 at 7:56 AM, Eric Dumazet <edumazet@google.com> wrote:
>> On Tue, Mar 14, 2017 at 7:46 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>
>>> I am confused. Lockdep has observed both of these stacks:
>>>
>>>        CPU0                    CPU1
>>>        ----                    ----
>>>   lock(&(&q->lock)->rlock);
>>>                                lock(_xmit_ETHER#2);
>>>                                lock(&(&q->lock)->rlock);
>>>   lock(_xmit_ETHER#2);
>>>
>>>
>>> So it somehow happened. Or what do you mean?
>>>
>>
>> Lockdep said " possible circular locking dependency detected " .
>> It is not an actual deadlock, but lockdep machinery firing.
>>
>> For a dead lock to happen, this would require that he ICMP message
>> sent by ip_expire() is itself fragmented and reassembled.
>> This cannot be, because ICMP messages are not candidates for
>> fragmentation, but lockdep can not know that of course...
>
> It doesn't have to be ICMP, as long as get the same hash for
> the inet_frag_queue, we will need to take the same lock and
> deadlock will happen.
>
>         hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
>
> So it is really up to this hash function.



Is the following the same issue?
It mentions dev->qdisc_tx_busylock, but I am not sure if it's relevant
if there already a cycle between  _xmit_ETHER#2 -->
&(&q->lock)->rlock#2.


[ INFO: possible circular locking dependency detected ]
4.11.0-rc2+ #340 Not tainted
-------------------------------------------------------
swapper/1/0 is trying to acquire lock:
 (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at:
[<ffffffff834cff12>] spin_lock include/linux/spinlock.h:299 [inline]
 (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at:
[<ffffffff834cff12>] __dev_xmit_skb net/core/dev.c:3077 [inline]
 (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at:
[<ffffffff834cff12>] __dev_queue_xmit+0x11b2/0x1ed0
net/core/dev.c:3359

but task is already holding lock:
 (&(&q->lock)->rlock#2){+.-...}, at: [<ffffffff8368dc21>] spin_lock
include/linux/spinlock.h:299 [inline]
 (&(&q->lock)->rlock#2){+.-...}, at: [<ffffffff8368dc21>]
ip_expire+0x51/0x6d0 net/ipv4/ip_fragment.c:201

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&(&q->lock)->rlock#2){+.-...}:
       lock_acquire+0x217/0x5e0 kernel/locking/lockdep.c:3762
       __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
       _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
       spin_lock include/linux/spinlock.h:299 [inline]
       ip_defrag+0x395/0x4070 net/ipv4/ip_fragment.c:669
       ip_check_defrag+0x4e7/0x890 net/ipv4/ip_fragment.c:713
       packet_rcv_fanout+0x26b/0x7f0 net/packet/af_packet.c:1459
       deliver_skb net/core/dev.c:1835 [inline]
       dev_queue_xmit_nit+0x2a6/0xaa0 net/core/dev.c:1891
       xmit_one net/core/dev.c:2904 [inline]
       dev_hard_start_xmit+0x16b/0xb20 net/core/dev.c:2924
       sch_direct_xmit+0x31d/0x6d0 net/sched/sch_generic.c:182
       __dev_xmit_skb net/core/dev.c:3093 [inline]
       __dev_queue_xmit+0x166a/0x1ed0 net/core/dev.c:3359
       dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
       neigh_hh_output include/net/neighbour.h:468 [inline]
       neigh_output include/net/neighbour.h:476 [inline]
       ip_finish_output2+0xe91/0x13f0 net/ipv4/ip_output.c:228
       ip_do_fragment+0x1d17/0x25f0 net/ipv4/ip_output.c:672
       ip_fragment.constprop.53+0x145/0x200 net/ipv4/ip_output.c:545
       ip_finish_output+0x5c1/0xb40 net/ipv4/ip_output.c:314
       NF_HOOK_COND include/linux/netfilter.h:246 [inline]
       ip_output+0x1d0/0x870 net/ipv4/ip_output.c:404
       dst_output include/net/dst.h:486 [inline]
       ip_local_out+0x95/0x170 net/ipv4/ip_output.c:124
       ip_send_skb+0x3c/0xc0 net/ipv4/ip_output.c:1492
       ip_push_pending_frames+0x64/0x80 net/ipv4/ip_output.c:1512
       raw_sendmsg+0x25e9/0x3870 net/ipv4/raw.c:655
       inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:762
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       ___sys_sendmsg+0x35e/0x860 net/socket.c:1986
       __sys_sendmmsg+0x1e6/0x5f0 net/socket.c:2076
       SYSC_sendmmsg net/socket.c:2107 [inline]
       SyS_sendmmsg+0x35/0x60 net/socket.c:2102
       do_syscall_64+0x26c/0x810 arch/x86/entry/common.c:281
       return_from_SYSCALL_64+0x0/0x7a

-> #1 (_xmit_ETHER#2){+.-...}:
       lock_acquire+0x217/0x5e0 kernel/locking/lockdep.c:3762
       __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
       _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
       spin_lock include/linux/spinlock.h:299 [inline]
       __netif_tx_lock include/linux/netdevice.h:3486 [inline]
       sch_direct_xmit+0x280/0x6d0 net/sched/sch_generic.c:180
       __dev_xmit_skb net/core/dev.c:3093 [inline]
       __dev_queue_xmit+0x166a/0x1ed0 net/core/dev.c:3359
       dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
       neigh_hh_output include/net/neighbour.h:468 [inline]
       neigh_output include/net/neighbour.h:476 [inline]
       ip6_finish_output2+0x1421/0x2270 net/ipv6/ip6_output.c:123
       ip6_fragment+0x2c6c/0x3920 net/ipv6/ip6_output.c:724
       ip6_finish_output+0x319/0x950 net/ipv6/ip6_output.c:147
       NF_HOOK_COND include/linux/netfilter.h:246 [inline]
       ip6_output+0x1b6/0x890 net/ipv6/ip6_output.c:163
       dst_output include/net/dst.h:486 [inline]
       ip6_local_out+0x95/0x170 net/ipv6/output_core.c:172
       ip6_send_skb+0xa1/0x340 net/ipv6/ip6_output.c:1739
       ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1759
       rawv6_push_pending_frames net/ipv6/raw.c:613 [inline]
       rawv6_sendmsg+0x2d7c/0x3ee0 net/ipv6/raw.c:930
       inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:762
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       ___sys_sendmsg+0x738/0x860 net/socket.c:1986
       __sys_sendmsg+0xe5/0x210 net/socket.c:2020
       SYSC_sendmsg net/socket.c:2031 [inline]
       SyS_sendmsg+0x2d/0x50 net/socket.c:2027
       entry_SYSCALL_64_fastpath+0x1f/0xc2

-> #0 (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}:
       check_prev_add kernel/locking/lockdep.c:1830 [inline]
       check_prevs_add kernel/locking/lockdep.c:1940 [inline]
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2f07/0x3a80 kernel/locking/lockdep.c:3347
       lock_acquire+0x217/0x5e0 kernel/locking/lockdep.c:3762
       __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
       _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
       spin_lock include/linux/spinlock.h:299 [inline]
       __dev_xmit_skb net/core/dev.c:3077 [inline]
       __dev_queue_xmit+0x11b2/0x1ed0 net/core/dev.c:3359
       dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
       neigh_hh_output include/net/neighbour.h:468 [inline]
       neigh_output include/net/neighbour.h:476 [inline]
       ip_finish_output2+0xe91/0x13f0 net/ipv4/ip_output.c:228
       ip_finish_output+0x7a3/0xb40 net/ipv4/ip_output.c:316
       NF_HOOK_COND include/linux/netfilter.h:246 [inline]
       ip_output+0x1d0/0x870 net/ipv4/ip_output.c:404
       dst_output include/net/dst.h:486 [inline]
       ip_local_out+0x95/0x170 net/ipv4/ip_output.c:124
       ip_send_skb+0x3c/0xc0 net/ipv4/ip_output.c:1492
       ip_push_pending_frames+0x64/0x80 net/ipv4/ip_output.c:1512
       icmp_push_reply+0x372/0x4c0 net/ipv4/icmp.c:394
       icmp_send+0x12f5/0x1920 net/ipv4/icmp.c:754
       ip_expire+0x420/0x6d0 net/ipv4/ip_fragment.c:239
       call_timer_fn+0x254/0x940 kernel/time/timer.c:1268
       expire_timers kernel/time/timer.c:1307 [inline]
       __run_timers+0x716/0xbb0 kernel/time/timer.c:1601
       run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
       __do_softirq+0x2fc/0xbf6 kernel/softirq.c:284
       invoke_softirq kernel/softirq.c:364 [inline]
       irq_exit+0x1cc/0x200 kernel/softirq.c:405
       exiting_irq arch/x86/include/asm/apic.h:657 [inline]
       smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
       apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
       native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
       arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
       default_idle+0xba/0x480 arch/x86/kernel/process.c:275
       arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:266
       default_idle_call+0x44/0xa0 kernel/sched/idle.c:97
       cpuidle_idle_call kernel/sched/idle.c:155 [inline]
       do_idle+0x296/0x410 kernel/sched/idle.c:244
       cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:346
       start_secondary+0x2a7/0x340 arch/x86/kernel/smpboot.c:275
       verify_cpu+0x0/0xfc

other info that might help us debug this:

Chain exists of:
  dev->qdisc_tx_busylock ?: &qdisc_tx_busylock --> _xmit_ETHER#2 -->
&(&q->lock)->rlock#2

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&q->lock)->rlock#2);
                               lock(_xmit_ETHER#2);
                               lock(&(&q->lock)->rlock#2);
  lock(dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);

 *** DEADLOCK ***

6 locks held by swapper/1/0:
 #0:  (((&q->timer))){+.-...}, at: [<ffffffff815d9716>]
lockdep_copy_map include/linux/lockdep.h:175 [inline]
 #0:  (((&q->timer))){+.-...}, at: [<ffffffff815d9716>]
call_timer_fn+0x1c6/0x940 kernel/time/timer.c:1258
 #1:  (&(&q->lock)->rlock#2){+.-...}, at: [<ffffffff8368dc21>]
spin_lock include/linux/spinlock.h:299 [inline]
 #1:  (&(&q->lock)->rlock#2){+.-...}, at: [<ffffffff8368dc21>]
ip_expire+0x51/0x6d0 net/ipv4/ip_fragment.c:201
 #2:  (rcu_read_lock){......}, at: [<ffffffff8368dd95>]
ip_expire+0x1c5/0x6d0 net/ipv4/ip_fragment.c:216
 #3:  (k-slock-AF_INET){+.-...}, at: [<ffffffff83797f54>] spin_trylock
include/linux/spinlock.h:309 [inline]
 #3:  (k-slock-AF_INET){+.-...}, at: [<ffffffff83797f54>]
icmp_xmit_lock net/ipv4/icmp.c:219 [inline]
 #3:  (k-slock-AF_INET){+.-...}, at: [<ffffffff83797f54>]
icmp_send+0x6e4/0x1920 net/ipv4/icmp.c:681
 #4:  (rcu_read_lock_bh){......}, at: [<ffffffff8369e5ed>]
ip_finish_output2+0x22d/0x13f0 net/ipv4/ip_output.c:198
 #5:  (rcu_read_lock_bh){......}, at: [<ffffffff834cefb4>]
__dev_queue_xmit+0x254/0x1ed0 net/core/dev.c:3325

stack backtrace:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.11.0-rc2+ #340
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 print_circular_bug+0x358/0x400 kernel/locking/lockdep.c:1204
 check_prev_add kernel/locking/lockdep.c:1830 [inline]
 check_prevs_add kernel/locking/lockdep.c:1940 [inline]
 validate_chain kernel/locking/lockdep.c:2267 [inline]
 __lock_acquire+0x2f07/0x3a80 kernel/locking/lockdep.c:3347
 lock_acquire+0x217/0x5e0 kernel/locking/lockdep.c:3762
 __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
 _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
 spin_lock include/linux/spinlock.h:299 [inline]
 __dev_xmit_skb net/core/dev.c:3077 [inline]
 __dev_queue_xmit+0x11b2/0x1ed0 net/core/dev.c:3359
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
 neigh_hh_output include/net/neighbour.h:468 [inline]
 neigh_output include/net/neighbour.h:476 [inline]
 ip_finish_output2+0xe91/0x13f0 net/ipv4/ip_output.c:228
 ip_finish_output+0x7a3/0xb40 net/ipv4/ip_output.c:316
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip_output+0x1d0/0x870 net/ipv4/ip_output.c:404
 dst_output include/net/dst.h:486 [inline]
 ip_local_out+0x95/0x170 net/ipv4/ip_output.c:124
 ip_send_skb+0x3c/0xc0 net/ipv4/ip_output.c:1492
 ip_push_pending_frames+0x64/0x80 net/ipv4/ip_output.c:1512
 icmp_push_reply+0x372/0x4c0 net/ipv4/icmp.c:394
 icmp_send+0x12f5/0x1920 net/ipv4/icmp.c:754
 ip_expire+0x420/0x6d0 net/ipv4/ip_fragment.c:239
 call_timer_fn+0x254/0x940 kernel/time/timer.c:1268
 expire_timers kernel/time/timer.c:1307 [inline]
 __run_timers+0x716/0xbb0 kernel/time/timer.c:1601
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
 __do_softirq+0x2fc/0xbf6 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:657 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
RSP: 0018:ffff88003e027db0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000000 RBX: 1ffff10007c04fb9 RCX: 0000000000000000
RDX: 1ffffffff09d8ed4 RSI: 0000000000000001 RDI: ffffffff84ec76a0
RBP: ffff88003e027db0 R08: ffffed0007c03461 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff84ec7690
R13: ffff88003e027e68 R14: 0000000000000000 R15: 0000000000000001
 </IRQ>
 arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
 default_idle+0xba/0x480 arch/x86/kernel/process.c:275
 arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:266
 default_idle_call+0x44/0xa0 kernel/sched/idle.c:97
 cpuidle_idle_call kernel/sched/idle.c:155 [inline]
 do_idle+0x296/0x410 kernel/sched/idle.c:244
 cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:346
 start_secondary+0x2a7/0x340 arch/x86/kernel/smpboot.c:275
 start_cpu+0x14/0x14 arch/x86/kernel/head_64.S:306
