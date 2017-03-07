From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 7 Mar 2017 19:13:33 +0100
Message-ID: <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com> <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:36160 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755212AbdCGSOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 13:14:09 -0500
Received: by mail-ua0-f180.google.com with SMTP id 72so15286583uaf.3
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 10:13:55 -0800 (PST)
In-Reply-To: <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 7, 2017 at 7:03 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 3/7/17 2:21 AM, Dmitry Vyukov wrote:
>> I've commented that warning just to see I can obtain more information.
>> Then I also got this:
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 2 PID: 3990 at net/ipv6/ip6_fib.c:991
>> fib6_add+0x2e12/0x3290 net/ipv6/ip6_fib.c:991 net/ipv6/ip6_fib.c:991
>> Kernel panic - not syncing: panic_on_warn set ...
>
> again panic_on_warn is triggering ...
>
>>
>> CPU: 2 PID: 3990 Comm: kworker/2:4 Not tainted 4.11.0-rc1+ #311
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Workqueue: ipv6_addrconf addrconf_dad_work
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:16 [inline]
>>  __dump_stack lib/dump_stack.c:16 [inline] lib/dump_stack.c:52
>>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52 lib/dump_stack.c:52
>>  panic+0x20f/0x426 kernel/panic.c:180 kernel/panic.c:180
>>  __warn+0x1c4/0x1e0 kernel/panic.c:541 kernel/panic.c:541
>>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584 kernel/panic.c:584
>>  fib6_add+0x2e12/0x3290 net/ipv6/ip6_fib.c:991 net/ipv6/ip6_fib.c:991
>
> on this warning:
>
> /* dst.next really should not be set at this point */
> if (rt->dst.next && rt->dst.next->ops->family != AF_INET6) {
>         pr_warn("fib6_add: adding rt with bad next -- family %d dst
> flags %x\n",
>                 rt->dst.next->ops->family, rt->dst.next->flags);
>
>         WARN_ON(1);
> }
>
> You should have seen the pr_warn in the log preceding the WARN_ON dump.


Right. They all have the same "IPv6: fib6_add: adding rt with bad next
-- family 2 dst flags 6"

[  171.222795] IPv6: fib6_add: adding rt with bad next -- family 2 dst flags 6
[  171.223809] ------------[ cut here ]------------
[  171.224407] WARNING: CPU: 3 PID: 27 at net/ipv6/ip6_fib.c:991
fib6_add+0x2e12/0x3290
[  171.225327] Kernel panic - not syncing: panic_on_warn set ...
[  171.225327]
[  171.226066] CPU: 3 PID: 27 Comm: kworker/3:0 Not tainted 4.11.0-rc1+ #311
[  171.226304] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS Bochs 01/01/2011
[  171.226304] Workqueue: ipv6_addrconf addrconf_dad_work
[  171.226304] Call Trace:
[  171.226304]  dump_stack+0x2fb/0x3fd
[  171.226304]  ? arch_local_irq_restore+0x53/0x53
[  171.226304]  ? vprintk_emit+0x566/0x770
[  171.226304]  ? console_unlock+0xf50/0xf50
[  171.226304]  ? vprintk_emit+0x566/0x770
[  171.226304]  ? console_unlock+0xf50/0xf50
[  171.226304]  ? vprintk_emit+0x566/0x770
[  171.226304]  ? console_unlock+0xf50/0xf50
[  171.226304]  ? check_noncircular+0x20/0x20
[  171.226304]  ? trace_hardirqs_on+0xd/0x10
[  171.226304]  ? perf_trace_lock_acquire+0x141/0xa00
[  171.226304]  ? trace_hardirqs_off+0xd/0x10
[  171.226304]  ? quarantine_put+0xea/0x190
[  171.226304]  ? check_noncircular+0x20/0x20
[  171.236060]  ? vprintk_default+0x28/0x30
[  171.236662]  ? vprintk_func+0x47/0x90
[  171.236662]  ? printk+0xc8/0xf9
[  171.236662]  ? load_image_and_restore+0x134/0x134
[  171.236662]  ? pointer+0xac0/0xac0
[  171.236662]  panic+0x20f/0x426
[  171.236662]  ? copy_mm+0x1219/0x1219
[  171.236662]  ? vprintk_func+0x47/0x90
[  171.236662]  ? printk+0xc8/0xf9
[  171.236662]  ? fib6_add+0x2e12/0x3290
[  171.236662]  __warn+0x1c4/0x1e0
[  171.236662]  warn_slowpath_null+0x2c/0x40
[  171.236662]  fib6_add+0x2e12/0x3290
[  171.236662]  ? kasan_check_write+0x14/0x20
[  171.236662]  ? netlink_broadcast_filtered+0x734/0x1380
[  171.236662]  ? fib6_force_start_gc+0xf0/0xf0
[  171.236662]  ? netlink_has_listeners+0x450/0x450
[  171.236662]  ? memcpy+0x45/0x50
[  171.236662]  ? __nla_put+0x37/0x40
[  171.236662]  ? nla_put+0xf9/0x130
[  171.236662]  ? skb_put+0x149/0x1c0
[  171.236662]  ? kasan_check_write+0x14/0x20
[  171.236662]  ? do_raw_write_lock+0xbd/0x1e0
[  171.236662]  __ip6_ins_rt+0x60/0x80
[  171.236662]  ip6_ins_rt+0x19b/0x220
[  171.236662]  ? ip6_route_info_create+0x2380/0x2380
[  171.236662]  ? nlmsg_notify+0xaf/0x160
[  171.236662]  ? rtnl_notify+0xbb/0xe0
[  171.236662]  __ipv6_ifa_notify+0x62e/0x7a0
[  171.251057]  ipv6_ifa_notify+0xdf/0x1d0
[  171.251057]  ? __ipv6_ifa_notify+0x7a0/0x7a0
[  171.251057]  addrconf_dad_completed+0xe6/0x950
[  171.251057]  ? addrconf_verify_work+0x20/0x20
[  171.251057]  ? kasan_check_write+0x14/0x20
[  171.251057]  addrconf_dad_work+0x32a/0xea0
[  171.251057]  ? addrconf_ifdown+0x1ad0/0x1ad0
[  171.251057]  ? rcu_pm_notify+0xc0/0xc0
[  171.251057]  ? wq_update_unbound_numa+0x8d0/0x8d0
[  171.251057]  ? kasan_check_write+0x14/0x20
[  171.251057]  process_one_work+0xc06/0x1c40
[  171.251057]  ? process_one_work+0xb3d/0x1c40
[  171.251057]  ? pwq_dec_nr_in_flight+0x470/0x470
[  171.251057]  ? preempt_notifier_register+0x1f0/0x1f0
[  171.259856]  ? __schedule+0x893/0x22d0
[  171.259856]  ? kasan_check_write+0x14/0x20
[  171.259856]  ? worker_thread+0x47d/0x19f0
[  171.259856]  ? lock_set_class+0xc00/0xc00
[  171.259856]  ? worker_thread+0x467/0x19f0
[  171.259856]  ? lock_acquire+0x630/0x630
[  171.259856]  ? _raw_spin_unlock_irq+0x27/0x70
[  171.259856]  ? check_noncircular+0x20/0x20
[  171.259856]  ? mark_held_locks+0x100/0x100
[  171.259856]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[  171.259856]  ? __schedule+0x22d0/0x22d0
[  171.259856]  ? do_raw_spin_trylock+0x1a0/0x1a0
[  171.259856]  ? do_raw_spin_lock+0xbd/0x1f0
[  171.259856]  worker_thread+0x223/0x19f0
[  171.259856]  ? process_one_work+0x1c40/0x1c40
[  171.259856]  ? lock_repin_lock+0x4a0/0x4a0
[  171.259856]  ? unwind_dump.isra.5.part.6+0x320/0x320
[  171.259856]  ? kasan_check_write+0x14/0x20
[  171.259856]  ? finish_task_switch+0x1ea/0x740
[  171.259856]  ? finish_task_switch+0x196/0x740
[  171.259856]  ? preempt_notifier_register+0x1f0/0x1f0
[  171.259856]  ? __schedule+0x893/0x22d0
[  171.259856]  ? lockdep_count_backward_deps+0x480/0x480
[  171.259856]  ? ret_from_fork+0x31/0x40
[  171.259856]  ? do_raw_spin_lock+0xbd/0x1f0
[  171.259856]  ? complete+0xbf/0x190
[  171.259856]  ? register_lock_class+0x1c30/0x1c30
[  171.276560]  ? __wake_up_common+0xb4/0x150
[  171.276560]  ? rcu_pm_notify+0xc0/0xc0
[  171.276560]  ? __schedule+0x22d0/0x22d0
[  171.276560]  ? __init_waitqueue_head+0x8a/0x120
[  171.276560]  ? __wake_up_bit+0x290/0x290
[  171.279715]  ? preempt_notifier_register+0x1f0/0x1f0
[  171.279715]  ? __kthread_parkme+0x173/0x240
[  171.279715]  kthread+0x334/0x400
[  171.279715]  ? process_one_work+0x1c40/0x1c40
[  171.279715]  ? kthread_create_on_node+0x110/0x110
[  171.279715]  ret_from_fork+0x31/0x40
[  171.279715] Dumping ftrace buffer:
[  171.279715]    (ftrace buffer empty)
[  171.279715] Kernel Offset: disabled
[  171.279715] Rebooting in 86400 seconds..




>>  __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948 net/ipv6/route.c:948
>>  ip6_ins_rt+0x19b/0x220 net/ipv6/route.c:959 net/ipv6/route.c:959
>>  __ipv6_ifa_notify+0x62e/0x7a0 net/ipv6/addrconf.c:5485 net/ipv6/addrconf.c:5485
>>  ipv6_ifa_notify+0xdf/0x1d0 net/ipv6/addrconf.c:5518 net/ipv6/addrconf.c:5518
>>  addrconf_dad_completed+0xe6/0x950 net/ipv6/addrconf.c:3983
>> net/ipv6/addrconf.c:3983
>>  addrconf_dad_begin net/ipv6/addrconf.c:3797 [inline]
>>  addrconf_dad_begin net/ipv6/addrconf.c:3797 [inline] net/ipv6/addrconf.c:3897
>>  addrconf_dad_work+0x32a/0xea0 net/ipv6/addrconf.c:3897 net/ipv6/addrconf.c:3897
>>  process_one_work+0xc06/0x1c40 kernel/workqueue.c:2096 kernel/workqueue.c:2096
>>  worker_thread+0x223/0x19f0 kernel/workqueue.c:2230 kernel/workqueue.c:2230
>>  kthread+0x334/0x400 kernel/kthread.c:229 kernel/kthread.c:229
>>  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
>> arch/x86/entry/entry_64.S:430
>>
>>
>>
>> And this without any preceding warnings:
>>
>> ==================================================================
>> BUG: KASAN: slab-out-of-bounds in fib6_age+0x3fd/0x480
>> net/ipv6/ip6_fib.c:1787 at addr ffff88004d4fbe54
>
> another ipv4 route in ipv6 fib walk
