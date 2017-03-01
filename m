From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in neigh_timer_handler/sock_wfree
Date: Wed, 1 Mar 2017 13:43:44 -0800
Message-ID: <CAM_iQpUdpjXS-yq8McZne+hobWv+pQS-Q0Fk4w0i0mXJQQ8fhQ@mail.gmail.com>
References: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
 <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 1:24 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Mar 1, 2017 at 11:27 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Hello,
>>
>> I am seeing the following use-after-free report while running
>> syzkaller fuzzer on
>> linux-next/3e7350242c6f3d41d28e03418bd781cc1b7bad5f:
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in constant_test_bit
>> arch/x86/include/asm/bitops.h:324 [inline] at addr ffff8801c56d5460
>> BUG: KASAN: use-after-free in sock_flag include/net/sock.h:789
>> [inline] at addr ffff8801c56d5460
>> BUG: KASAN: use-after-free in sock_wfree+0x118/0x120
>> net/core/sock.c:1630 at addr ffff8801c56d5460
>> Read of size 8 by task syz-fuzzer/3261
>> CPU: 0 PID: 3261 Comm: syz-fuzzer Not tainted 4.10.0-next-20170224+ #1
>> Hardware name: Google Google Compute Engine/Google Compute Engine,
>> BIOS Google 01/01/2011
>> Call Trace:
>>  <IRQ>
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>>  constant_test_bit arch/x86/include/asm/bitops.h:324 [inline]
>>  sock_flag include/net/sock.h:789 [inline]
>>  sock_wfree+0x118/0x120 net/core/sock.c:1630
>>  skb_release_head_state+0xfc/0x200 net/core/skbuff.c:654
>>  skb_release_all+0x15/0x60 net/core/skbuff.c:667
>>  __kfree_skb+0x15/0x20 net/core/skbuff.c:683
>>  kfree_skb+0x16e/0x4c0 net/core/skbuff.c:704
>>  ndisc_error_report+0xbb/0x190 net/ipv6/ndisc.c:683
>>  neigh_invalidate+0x23e/0x570 net/core/neighbour.c:848
>>  neigh_timer_handler+0x4e7/0x1140 net/core/neighbour.c:933
>>  call_timer_fn+0x241/0x820 kernel/time/timer.c:1266
>>  expire_timers kernel/time/timer.c:1305 [inline]
>>  __run_timers+0x960/0xcf0 kernel/time/timer.c:1599
>>  run_timer_softirq+0x21/0x80 kernel/time/timer.c:1612
>>  __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
>>  invoke_softirq kernel/softirq.c:364 [inline]
>>  irq_exit+0x1cc/0x200 kernel/softirq.c:405
>>  exiting_irq arch/x86/include/asm/apic.h:658 [inline]
>>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
>>  apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:707
>
> This one looks very similar to a previous one:
> https://groups.google.com/forum/#!topic/syzkaller/BhyN5OFd7sQ
>
> Both happen on raw v6 sockets.
>
> For me, it seems the sk refcnt is not correct, skb should still hold
> a refcnt so it should not be freed before kfree_skb() in a timer
> handler...

More precisely, after this commit:

commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Jun 11 02:55:43 2009 -0700

    net: No more expensive sock_hold()/sock_put() on each tx

we don't take (old) refcnt any more on TX path, sk_wmem_alloc
is the new refcnt. ;)
