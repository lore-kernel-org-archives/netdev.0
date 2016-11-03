From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/netlink: null-ptr-deref in netlink_dump/lock_acquire
Date: Wed, 02 Nov 2016 19:58:26 -0700
Message-ID: <1478141906.7065.421.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+wM9yG3c9AksSyj7jYSY4ujssH+vTuV2nyz=-0enLrB8w@mail.gmail.com>
         <CAAeHK+xCmN7n1MTocLK9A864YGkq-7a-1NESYkWyLYgLRScF=Q@mail.gmail.com>
         <CAAeHK+y_1CuCCMDz+sbwS0zG=G9tWvfcFunqgmY8UtR_D=xMww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Decotigny <decot@googlers.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dmitry Ivanov <dmitrijs.ivanovs@ubnt.com>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>,
        Greg Rose <grose@lightfleet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Johannes Berg <johannes.berg@intel.com>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
To: Andrey Konovalov <andreyknvl@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+y_1CuCCMDz+sbwS0zG=G9tWvfcFunqgmY8UtR_D=xMww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-11-03 at 03:36 +0100, Andrey Konovalov wrote:
> On Thu, Nov 3, 2016 at 1:15 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > On Wed, Oct 19, 2016 at 4:13 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> >> Hi,
> >>
> >> I've got the following error report while running the syzkaller fuzzer:
> >>
> >> kasan: CONFIG_KASAN_INLINE enabled
> >> kasan: GPF could be caused by NULL-ptr deref or user memory access
> >> general protection fault: 0000 [#1] SMP KASAN
> >> Modules linked in:
> >> CPU: 1 PID: 3933 Comm: syz-executor Not tainted 4.9.0-rc1+ #230
> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >> task: ffff88006b79d800 task.stack: ffff88006bbc0000
> >> RIP: 0010:[<ffffffff8120872d>]  [<ffffffff8120872d>]
> >> __lock_acquire+0x12d/0x3450 kernel/locking/lockdep.c:3221
> >> RSP: 0018:ffff88006bbc7420  EFLAGS: 00010006
> >> RAX: 0000000000000046 RBX: dffffc0000000000 RCX: 0000000000000000
> >> RDX: 000000000000000c RSI: 0000000000000000 RDI: 0000000000000003
> >> RBP: ffff88006bbc75c0 R08: 0000000000000001 R09: 0000000000000000
> >> R10: 0000000000000000 R11: ffffffff85f42240 R12: ffff88006b79d800
> >> R13: ffffffff84bfe4e0 R14: 0000000000000001 R15: 0000000000000060
> >> FS:  00007fd9c41cc700(0000) GS:ffff88006cd00000(0000) knlGS:0000000000000000
> >> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> CR2: 0000000000451f80 CR3: 00000000638f0000 CR4: 00000000000006e0
> >> Stack:
> >>  0000000000000000 ffff88006bbc0000 ffff88006bbc8000 0000000000000000
> >>  0000000000000002 ffff88006b79d800 0000000000000000 ffff88006bbc7f48
> >>  ffffffff852adc60 0000000000000000 ffffffff852adc64 1ffffffff0b40135
> >> Call Trace:
> >>  [<ffffffff8120c5ae>] lock_acquire+0x17e/0x340 kernel/locking/lockdep.c:3746
> >>  [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
> >>  [<ffffffff83fb6fe1>] mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
> >>  [<ffffffff82db6fd0>] netlink_dump+0x50/0xac0 net/netlink/af_netlink.c:2067
> >>  [<ffffffff82dba381>] __netlink_dump_start+0x501/0x770
> >> net/netlink/af_netlink.c:2200
> >>  [<ffffffff82dc35b2>] genl_family_rcv_msg+0xa02/0xc80
> >> net/netlink/genetlink.c:595
> >>  [<ffffffff82dc39e6>] genl_rcv_msg+0x1b6/0x270 net/netlink/genetlink.c:658
> >>  [<ffffffff82dc1a70>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
> >>  [<ffffffff82dc2b98>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
> >>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
> >>  [<ffffffff82dc0329>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
> >>  [<ffffffff82dc0fb7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
> >>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
> >>  [<ffffffff82b7075c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
> >>  [<ffffffff82b709c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
> >>  [<     inline     >] new_sync_write fs/read_write.c:499
> >>  [<ffffffff8151c944>] __vfs_write+0x334/0x570 fs/read_write.c:512
> >>  [<ffffffff8152045b>] vfs_write+0x17b/0x500 fs/read_write.c:560
> >>  [<     inline     >] SYSC_write fs/read_write.c:607
> >>  [<ffffffff81523d84>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
> >>  [<ffffffff83fc0141>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> >> arch/x86/entry/entry_64.S:209
> >> Code: 0f 1f 44 00 00 f6 c4 02 0f 85 24 0a 00 00 44 8b 35 c9 61 8b 03
> >> 45 85 f6 74 2c 4c 89 fa 48 bb 00 00 00 00 00 fc ff df 48 c1 ea 03 <80>
> >> 3c 1a 00 0f 85 04 2f 00 00 49 81 3f a0 dc 2a 85 41 be 00 00
> >> RIP  [<ffffffff8120872d>] __lock_acquire+0x12d/0x3450
> >> kernel/locking/lockdep.c:3221
> >>  RSP <ffff88006bbc7420>
> >> ---[ end trace 685b3c182bf7f25c ]---
> >>
> >> The reproducer is attached.
> >>
> >> On commit 1a1891d762d6e64daf07b5be4817e3fbb29e3c59 (Oct 18).
> >
> > (Adding more maintainers)
> >
> > Still seeing this on 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
> 
> Here is another report that might be related:
> 
> =====================================
> [ BUG: bad unlock balance detected! ]
> 4.9.0-rc3+ #336 Not tainted
> -------------------------------------
> syz-executor/4018 is trying to release lock ([   36.220068] nl_table_lock
> ) at:
> [<ffffffff82dc8683>] netlink_diag_dump+0x1a3/0x250 net/netlink/diag.c:182
> but there are no more locks to release!
> 
> other info that might help us debug this:
> 3 locks held by syz-executor/4018:
>  #0: [   36.220068]  (
> sock_diag_mutex[   36.220068] ){+.+.+.}
> , at: [   36.220068] [<ffffffff82c3873b>] sock_diag_rcv+0x1b/0x40
>  #1: [   36.220068]  (
> sock_diag_table_mutex[   36.220068] ){+.+.+.}
> , at: [   36.220068] [<ffffffff82c38e00>] sock_diag_rcv_msg+0x140/0x3a0
>  #2: [   36.220068]  (
> nlk->cb_mutex[   36.220068] ){+.+.+.}
> , at: [   36.220068] [<ffffffff82db6600>] netlink_dump+0x50/0xac0
> 
> stack backtrace:
> CPU: 1 PID: 4018 Comm: syz-executor Not tainted 4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800645df688 ffffffff81b46934 ffffffff84eb3e78 ffff88006ad85800
>  ffffffff82dc8683 ffffffff84eb3e78 ffff8800645df6b8 ffffffff812043ca
>  dffffc0000000000 ffff88006ad85ff8 ffff88006ad85fd0 00000000ffffffff
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff812043ca>] print_unlock_imbalance_bug+0x17a/0x1a0
> kernel/locking/lockdep.c:3388
>  [<     inline     >] __lock_release kernel/locking/lockdep.c:3512
>  [<ffffffff8120cfd8>] lock_release+0x8e8/0xc60 kernel/locking/lockdep.c:3765
>  [<     inline     >] __raw_read_unlock ./include/linux/rwlock_api_smp.h:225
>  [<ffffffff83fc001a>] _raw_read_unlock+0x1a/0x30 kernel/locking/spinlock.c:255
>  [<ffffffff82dc8683>] netlink_diag_dump+0x1a3/0x250 net/netlink/diag.c:182
>  [<ffffffff82db6947>] netlink_dump+0x397/0xac0 net/netlink/af_netlink.c:2110
>  [<ffffffff82db99b1>] __netlink_dump_start+0x501/0x770
> net/netlink/af_netlink.c:2200
>  [<     inline     >] netlink_dump_start ./include/linux/netlink.h:165
>  [<ffffffff82dc75d1>] netlink_diag_handler_dump+0x191/0x220
> net/netlink/diag.c:218
>  [<     inline     >] __sock_diag_cmd net/core/sock_diag.c:239
>  [<ffffffff82c38fd6>] sock_diag_rcv_msg+0x316/0x3a0 net/core/sock_diag.c:270
>  [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
>  [<ffffffff82c3874a>] sock_diag_rcv+0x2a/0x40 net/core/sock_diag.c:281
>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
>  [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
>  [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>  [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>  [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>  [<     inline     >] new_sync_write fs/read_write.c:499
>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>  [<     inline     >] SYSC_write fs/read_write.c:607
>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 4018 at net/core/skbuff.c:654[<        none
>  >] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
> Modules linked in:
> CPU: 1 PID: 4018 Comm: syz-executor Not tainted 4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800645df920 ffffffff81b46934 0000000000000000 0000000000000000
>  ffffffff84401fa0 0000000000000000 ffff8800645df968 ffffffff811112f7
>  ffffffff83fb92f2 ffff88000000028e ffffffff84401fa0 000000000000028e
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff811112f7>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>  [<ffffffff8111150c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
>  [<ffffffff82b885ea>] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
>  [<ffffffff82b91815>] skb_release_all+0x15/0x60 net/core/skbuff.c:668
>  [<     inline     >] __kfree_skb net/core/skbuff.c:684
>  [<ffffffff82ba0175>] consume_skb+0x115/0x2e0 net/core/skbuff.c:757
>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1215
>  [<ffffffff82dbf961>] netlink_unicast+0x5b1/0x880 net/netlink/af_netlink.c:1240
>  [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>  [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>  [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>  [<     inline     >] new_sync_write fs/read_write.c:499
>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>  [<     inline     >] SYSC_write fs/read_write.c:607
>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> ---[ end trace bb9fa7cf182d59a5 ]---
> BUG: scheduling while atomic: syz-executor/4018/0x7fffffff
> INFO: lockdep is turned off.
> Modules linked in:
> CPU: 1 PID: 4018 Comm: syz-executor Tainted: G        W       4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800645dfe28 ffffffff81b46934 dffffc0000000000 000000007fffffff
>  00000000000214c0 0000000000000001 ffff8800645dfe48 ffffffff8119113a
>  ffff88006cd214c0 0000000000000000 ffff8800645dfec8 ffffffff83fb030a
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff8119113a>] __schedule_bug+0xfa/0x140 kernel/sched/core.c:3230
>  [<     inline     >] schedule_debug kernel/sched/core.c:3245
>  [<ffffffff83fb030a>] __schedule+0xfda/0x1ab0 kernel/sched/core.c:3345
>  [<ffffffff83fb0e70>] schedule+0x90/0x1b0 kernel/sched/core.c:3457
>  [<ffffffff810039e9>] exit_to_usermode_loop+0xc9/0x130
> arch/x86/entry/common.c:149
>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>  [<ffffffff81006298>] syscall_return_slowpath+0x1a8/0x1e0
> arch/x86/entry/common.c:259
>  [<ffffffff83fc04a2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
> arch/x86/entry/entry_64.S:244
> NOHZ: local_softirq_pending 202
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 4018 at net/core/skbuff.c:654[<        none
>  >] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
> Modules linked in:[   36.328353] CPU: 1 PID: 4018 Comm: syz-executor
> Tainted: G        W       4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800645df920 ffffffff81b46934 0000000000000000 0000000000000000
>  ffffffff84401fa0 0000000000000000 ffff8800645df968 ffffffff811112f7
>  ffffffff83fb92f2 ffff88000000028e ffffffff84401fa0 000000000000028e
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff811112f7>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>  [<ffffffff8111150c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
>  [<ffffffff82b885ea>] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
>  [<ffffffff82b91815>] skb_release_all+0x15/0x60 net/core/skbuff.c:668
>  [<     inline     >] __kfree_skb net/core/skbuff.c:684
>  [<ffffffff82ba0175>] consume_skb+0x115/0x2e0 net/core/skbuff.c:757
>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1215
>  [<ffffffff82dbf961>] netlink_unicast+0x5b1/0x880 net/netlink/af_netlink.c:1240
>  [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>  [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>  [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>  [<     inline     >] new_sync_write fs/read_write.c:499
>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>  [<     inline     >] SYSC_write fs/read_write.c:607
>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> ---[ end trace bb9fa7cf182d59a6 ]---
> BUG: sleeping function called from invalid context at
> ./include/linux/freezer.h:56
> in_atomic(): 1, irqs_disabled(): 0, pid: 4018, name: syz-executor
> INFO: lockdep is turned off.
> CPU: 1 PID: 4018 Comm: syz-executor Tainted: G        W       4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800645dfbb0 ffffffff81b46934 ffff88006ad85800 ffff8800645d8000
>  ffff88006ad85800 0000000000000000 ffff8800645dfbd8 ffffffff81192131
>  ffff88006ad85800 ffffffff8404c140 0000000000000038 ffff8800645dfc18
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff81192131>] ___might_sleep+0x281/0x3c0 kernel/sched/core.c:7767
>  [<ffffffff81192306>] __might_sleep+0x96/0x1a0 kernel/sched/core.c:7726
>  [<     inline     >] try_to_freeze_unsafe ./include/linux/freezer.h:56
>  [<     inline     >] try_to_freeze ./include/linux/freezer.h:66
>  [<ffffffff81143849>] get_signal+0x129/0x15a0 kernel/signal.c:2147
>  [<ffffffff81054aad>] do_signal+0x8d/0x1a30 arch/x86/kernel/signal.c:807
>  [<ffffffff81003a05>] exit_to_usermode_loop+0xe5/0x130
> arch/x86/entry/common.c:156
>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>  [<ffffffff81006298>] syscall_return_slowpath+0x1a8/0x1e0
> arch/x86/entry/common.c:259
>  [<ffffffff83fc04a2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
> arch/x86/entry/entry_64.S:244
> Kernel panic - not syncing: Aiee, killing interrupt handler!
> CPU: 1 PID: 4018 Comm: syz-executor Tainted: G        W       4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800645df998 ffffffff81b46934 0000000000000003 dffffc0000000000
>  dffffc0000000000 ffff8800645dfa04 ffff8800645dfa60 ffffffff8140bf7a
>  0000000041b58ab3 ffffffff84797a7d ffffffff8140bdbe ffffffff00000000
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff8140bf7a>] panic+0x1bc/0x39d kernel/panic.c:179
>  [<ffffffff8111cfd8>] do_exit+0x1b48/0x2ac0 kernel/exit.c:740
>  [<ffffffff811222be>] do_group_exit+0x10e/0x340 kernel/exit.c:931
>  [<ffffffff81143d54>] get_signal+0x634/0x15a0 kernel/signal.c:2307
>  [<ffffffff81054aad>] do_signal+0x8d/0x1a30 arch/x86/kernel/signal.c:807
>  [<ffffffff81003a05>] exit_to_usermode_loop+0xe5/0x130
> arch/x86/entry/common.c:156
>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>  [<ffffffff81006298>] syscall_return_slowpath+0x1a8/0x1e0
> arch/x86/entry/common.c:259
>  [<ffffffff83fc04a2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
> arch/x86/entry/entry_64.S:244
> Kernel Offset: disabled
> ---[ end Kernel panic - not syncing: Aiee, killing interrupt handler!


This is probably a leftover after commit
ad202074320cd75b31b8cdb58cca0d4ef6aaea8a
("netlink: Use rhashtable walk interface in diag dump")

Please try this trivial fix :

diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index b2f0e986a6f4..a5546249fb10 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -178,11 +178,8 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		}
 		cb->args[1] = i;
 	} else {
-		if (req->sdiag_protocol >= MAX_LINKS) {
-			read_unlock(&nl_table_lock);
-			rcu_read_unlock();
+		if (req->sdiag_protocol >= MAX_LINKS)
 			return -ENOENT;
-		}
 
 		err = __netlink_diag_dump(skb, cb, req->sdiag_protocol, s_num);
 	}
