From: Andrey Konovalov <andreyknvl@google.com>
Subject: net: possible deadlock in skb_queue_tail
Date: Mon, 20 Feb 2017 14:29:34 +0100
Message-ID: <CAAeHK+yCwsZE9iv+OLHJaU+7FEka8UHy_t5vMqFUBpQ8srBbsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:36566 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752726AbdBTN3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 08:29:47 -0500
Received: by mail-wr0-f171.google.com with SMTP id 89so59546320wrr.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 05:29:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit c470abd4fde40ea6a0846a2beab642a578c0b8cd (4.10).

Unfortunately I can't reproduce it.

======================================================
[ INFO: possible circular locking dependency detected ]
4.10.0-rc8+ #201 Not tainted
-------------------------------------------------------
kworker/0:2/1404 is trying to acquire lock:
 (&(&list->lock)->rlock#3){+.-...}, at: [<ffffffff8335b23f>]
skb_queue_tail+0xcf/0x2f0 net/core/skbuff.c:2478

but task is already holding lock:
 (&(&pcpu->lock)->rlock){+.-...}, at: [<ffffffff8366b55f>] spin_lock
include/linux/spinlock.h:302 [inline]
 (&(&pcpu->lock)->rlock){+.-...}, at: [<ffffffff8366b55f>]
ecache_work_evict_list+0xaf/0x590
net/netfilter/nf_conntrack_ecache.c:48

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&(&pcpu->lock)->rlock){+.-...}:
       validate_chain kernel/locking/lockdep.c:2265 [inline]
       __lock_acquire+0x20a7/0x3270 kernel/locking/lockdep.c:3338
       lock_acquire+0x241/0x580 kernel/locking/lockdep.c:3753
       __raw_spin_lock include/linux/spinlock_api_smp.h:144 [inline]
       _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
       spin_lock include/linux/spinlock.h:302 [inline]
       nf_ct_del_from_dying_or_unconfirmed_list+0x10e/0x2f0
net/netfilter/nf_conntrack_core.c:347
       destroy_conntrack+0x261/0x430 net/netfilter/nf_conntrack_core.c:409
       nf_conntrack_destroy+0x107/0x240 net/netfilter/core.c:398
       nf_conntrack_put include/linux/skbuff.h:3561 [inline]
       skb_release_head_state+0x19e/0x250 net/core/skbuff.c:658
       skb_release_all+0x15/0x60 net/core/skbuff.c:668
       __kfree_skb+0x15/0x20 net/core/skbuff.c:684
       kfree_skb+0x16e/0x4e0 net/core/skbuff.c:705
       kfree_skb_list net/core/skbuff.c:714 [inline]
       skb_release_data+0x38e/0x470 net/core/skbuff.c:609
       skb_release_all+0x4a/0x60 net/core/skbuff.c:670
       __kfree_skb+0x15/0x20 net/core/skbuff.c:684
       kfree_skb+0x16e/0x4e0 net/core/skbuff.c:705
       first_packet_length+0x3c4/0x6e0 net/ipv4/udp.c:1376
       udp_poll+0x423/0x550 net/ipv4/udp.c:2343
       sock_poll+0x1ae/0x210 net/socket.c:1051
       do_pollfd fs/select.c:781 [inline]
       do_poll fs/select.c:831 [inline]
       do_sys_poll+0x8a6/0x1340 fs/select.c:925
       SYSC_poll fs/select.c:983 [inline]
       SyS_poll+0x147/0x490 fs/select.c:971
       entry_SYSCALL_64_fastpath+0x1f/0xc2

-> #0 (&(&list->lock)->rlock#3){+.-...}:
       check_prev_add kernel/locking/lockdep.c:1828 [inline]
       check_prevs_add+0xaad/0x1a10 kernel/locking/lockdep.c:1938
       validate_chain kernel/locking/lockdep.c:2265 [inline]
       __lock_acquire+0x20a7/0x3270 kernel/locking/lockdep.c:3338
       lock_acquire+0x241/0x580 kernel/locking/lockdep.c:3753
       __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:112 [inline]
       _raw_spin_lock_irqsave+0xc9/0x110 kernel/locking/spinlock.c:159
       skb_queue_tail+0xcf/0x2f0 net/core/skbuff.c:2478
       __netlink_sendskb+0x58/0xa0 net/netlink/af_netlink.c:1177
       netlink_broadcast_deliver net/netlink/af_netlink.c:1302 [inline]
       do_one_broadcast net/netlink/af_netlink.c:1386 [inline]
       netlink_broadcast_filtered+0xe26/0x1420 net/netlink/af_netlink.c:1430
       netlink_broadcast net/netlink/af_netlink.c:1454 [inline]
       nlmsg_multicast include/net/netlink.h:576 [inline]
       nlmsg_notify+0xa2/0x140 net/netlink/af_netlink.c:2341
       nfnetlink_send+0x63/0x80 net/netfilter/nfnetlink.c:133
       ctnetlink_conntrack_event+0x10b3/0x1720
net/netfilter/nf_conntrack_netlink.c:740
       nf_conntrack_eventmask_report+0x61b/0x850
net/netfilter/nf_conntrack_ecache.c:149
       nf_conntrack_event
include/net/netfilter/nf_conntrack_ecache.h:122 [inline]
       ecache_work_evict_list+0x33e/0x590 net/netfilter/nf_conntrack_ecache.c:61
       ecache_work+0xf2/0x220 net/netfilter/nf_conntrack_ecache.c:98
       process_one_work+0xc06/0x1c20 kernel/workqueue.c:2098
       worker_thread+0x223/0x19c0 kernel/workqueue.c:2232
       kthread+0x326/0x3f0 kernel/kthread.c:227
       ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&pcpu->lock)->rlock);
                               lock(&(&list->lock)->rlock#3);
                               lock(&(&pcpu->lock)->rlock);
  lock(&(&list->lock)->rlock#3);

 *** DEADLOCK ***

4 locks held by kworker/0:2/1404:
 #0:  ("events"){.+.+.+}, at: [<ffffffff8133a239>] __write_once_size
include/linux/compiler.h:272 [inline]
 #0:  ("events"){.+.+.+}, at: [<ffffffff8133a239>] atomic64_set
arch/x86/include/asm/atomic64_64.h:33 [inline]
 #0:  ("events"){.+.+.+}, at: [<ffffffff8133a239>] atomic_long_set
include/asm-generic/atomic-long.h:56 [inline]
 #0:  ("events"){.+.+.+}, at: [<ffffffff8133a239>] set_work_data
kernel/workqueue.c:617 [inline]
 #0:  ("events"){.+.+.+}, at: [<ffffffff8133a239>]
set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
 #0:  ("events"){.+.+.+}, at: [<ffffffff8133a239>]
process_one_work+0xae9/0x1c20 kernel/workqueue.c:2091
 #1:  ((&(&net->ct.ecache_dwork)->work)){+.+...}, at:
[<ffffffff8133a28d>] process_one_work+0xb3d/0x1c20
kernel/workqueue.c:2095
 #2:  (&(&pcpu->lock)->rlock){+.-...}, at: [<ffffffff8366b55f>]
spin_lock include/linux/spinlock.h:302 [inline]
 #2:  (&(&pcpu->lock)->rlock){+.-...}, at: [<ffffffff8366b55f>]
ecache_work_evict_list+0xaf/0x590
net/netfilter/nf_conntrack_ecache.c:48
 #3:  (rcu_read_lock){......}, at: [<ffffffff8366ad08>] read_pnet
include/net/net_namespace.h:260 [inline]
 #3:  (rcu_read_lock){......}, at: [<ffffffff8366ad08>] nf_ct_net
include/net/netfilter/nf_conntrack.h:153 [inline]
 #3:  (rcu_read_lock){......}, at: [<ffffffff8366ad08>]
nf_conntrack_eventmask_report+0xa8/0x850
net/netfilter/nf_conntrack_ecache.c:124

stack backtrace:
CPU: 0 PID: 1404 Comm: kworker/0:2 Not tainted 4.10.0-rc8+ #201
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: events ecache_work
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:51
 print_circular_bug+0x310/0x3c0 kernel/locking/lockdep.c:1202
 check_prev_add kernel/locking/lockdep.c:1828 [inline]
 check_prevs_add+0xaad/0x1a10 kernel/locking/lockdep.c:1938
 validate_chain kernel/locking/lockdep.c:2265 [inline]
 __lock_acquire+0x20a7/0x3270 kernel/locking/lockdep.c:3338
 lock_acquire+0x241/0x580 kernel/locking/lockdep.c:3753
 __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:112 [inline]
 _raw_spin_lock_irqsave+0xc9/0x110 kernel/locking/spinlock.c:159
 skb_queue_tail+0xcf/0x2f0 net/core/skbuff.c:2478
 __netlink_sendskb+0x58/0xa0 net/netlink/af_netlink.c:1177
 netlink_broadcast_deliver net/netlink/af_netlink.c:1302 [inline]
 do_one_broadcast net/netlink/af_netlink.c:1386 [inline]
 netlink_broadcast_filtered+0xe26/0x1420 net/netlink/af_netlink.c:1430
 netlink_broadcast net/netlink/af_netlink.c:1454 [inline]
 nlmsg_multicast include/net/netlink.h:576 [inline]
 nlmsg_notify+0xa2/0x140 net/netlink/af_netlink.c:2341
 nfnetlink_send+0x63/0x80 net/netfilter/nfnetlink.c:133
 ctnetlink_conntrack_event+0x10b3/0x1720
net/netfilter/nf_conntrack_netlink.c:740
 nf_conntrack_eventmask_report+0x61b/0x850
net/netfilter/nf_conntrack_ecache.c:149
 nf_conntrack_event include/net/netfilter/nf_conntrack_ecache.h:122 [inline]
 ecache_work_evict_list+0x33e/0x590 net/netfilter/nf_conntrack_ecache.c:61
 ecache_work+0xf2/0x220 net/netfilter/nf_conntrack_ecache.c:98
 process_one_work+0xc06/0x1c20 kernel/workqueue.c:2098
 worker_thread+0x223/0x19c0 kernel/workqueue.c:2232
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
