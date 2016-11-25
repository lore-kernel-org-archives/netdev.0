From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/netlink: null-ptr-deref in netlink_dump/lock_acquire
Date: Fri, 25 Nov 2016 19:57:48 +0100
Message-ID: <CACT4Y+ZcCiRkCD8VW=q6j-ewMDmJrpEtH17Seey1xrnscyna5Q@mail.gmail.com>
References: <CAAeHK+wM9yG3c9AksSyj7jYSY4ujssH+vTuV2nyz=-0enLrB8w@mail.gmail.com>
 <CAAeHK+xCmN7n1MTocLK9A864YGkq-7a-1NESYkWyLYgLRScF=Q@mail.gmail.com>
 <CAAeHK+y_1CuCCMDz+sbwS0zG=G9tWvfcFunqgmY8UtR_D=xMww@mail.gmail.com>
 <1478141906.7065.421.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAeHK+xUFKMfW4WoYgyjJeYJZm_gAg3Nr3S0+8M-5H+6a=RVKw@mail.gmail.com> <CAAeHK+wL62MN20hi6=XZzKNskqKbZdsPoXp+fLGVHxhpY+pStA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Decotigny <decot@googlers.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dmitry Ivanov <dmitrijs.ivanovs@ubnt.com>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>,
        Greg Rose <grose@lightfleet.com>,
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
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wL62MN20hi6=XZzKNskqKbZdsPoXp+fLGVHxhpY+pStA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 3, 2016 at 6:21 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> Another report that looks related:
>
> [ INFO: possible circular locking dependency detected ]
> 4.9.0-rc3+ #344 Not tainted
> -------------------------------------------------------
> syz-executor/25526 is trying to acquire lock:
>  ([  950.351060] &table[i].mutex
> [<ffffffff82dcf798>] nfnl_lock+0x28/0x30 net/netfilter/nfnetlink.c:61
>
> but task is already holding lock:
>  ([  950.351060] rtnl_mutex
> [<     inline     >] rtnl_lock net/core/rtnetlink.c:70
> [<ffffffff82c15efb>] rtnetlink_rcv+0x1b/0x40 net/core/rtnetlink.c:4032
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> :
>        [  950.351060] [<ffffffff8120c52e>] lock_acquire+0x17e/0x340
> kernel/locking/lockdep.c:3746
>        [  950.351060] [<     inline     >] __mutex_lock_common
> kernel/locking/mutex.c:521
>        [  950.351060] [<ffffffff83fb7221>]
> mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>        [  950.351060] [<ffffffff82c11297>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:70
>        [  950.351060] [<ffffffff839fe31f>]
> nl80211_get_reg_dump+0x5f/0x400 net/wireless/nl80211.c:6171
>        [  950.351060] [<ffffffff82dc18d8>] genl_lock_dumpit+0x68/0x90
> net/netlink/genetlink.c:517
>        [  950.351060] [<ffffffff82db6947>] netlink_dump+0x397/0xac0
> net/netlink/af_netlink.c:2110
>        [  950.351060] [<ffffffff82db99b1>]
> __netlink_dump_start+0x501/0x770 net/netlink/af_netlink.c:2200
>        [  950.351060] [<ffffffff82dc2cb8>]
> genl_family_rcv_msg+0xad8/0xc80 net/netlink/genetlink.c:584
>        [  950.351060] [<ffffffff82dc3016>] genl_rcv_msg+0x1b6/0x270
> net/netlink/genetlink.c:658
>        [  950.351060] [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0
> net/netlink/af_netlink.c:2281
>        [  950.351060] [<ffffffff82dc21c8>] genl_rcv+0x28/0x40
> net/netlink/genetlink.c:669
>        [  950.351060] [<     inline     >] netlink_unicast_kernel
> net/netlink/af_netlink.c:1214
>        [  950.351060] [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880
> net/netlink/af_netlink.c:1240
>        [  950.351060] [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0
> net/netlink/af_netlink.c:1786
>        [  950.351060] [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>        [  950.351060] [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110
> net/socket.c:616
>        [  950.351060] [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0
> net/socket.c:814
>        [  950.351060] [<     inline     >] new_sync_write fs/read_write.c:499
>        [  950.351060] [<ffffffff8151bd44>] __vfs_write+0x334/0x570
> fs/read_write.c:512
>        [  950.351060] [<ffffffff8151f85b>] vfs_write+0x17b/0x500
> fs/read_write.c:560
>        [  950.351060] [<     inline     >] SYSC_write fs/read_write.c:607
>        [  950.351060] [<ffffffff81523184>] SyS_write+0xd4/0x1a0
> fs/read_write.c:599
>        [  950.351060] [<ffffffff83fc0281>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> :
>        [  950.351060] [<ffffffff8120c52e>] lock_acquire+0x17e/0x340
> kernel/locking/lockdep.c:3746
>        [  950.351060] [<     inline     >] __mutex_lock_common
> kernel/locking/mutex.c:521
>        [  950.351060] [<ffffffff83fb7221>]
> mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>        [  950.351060] [<     inline     >] genl_lock net/netlink/genetlink.c:31
>        [  950.351060] [<ffffffff82dc18b1>] genl_lock_dumpit+0x41/0x90
> net/netlink/genetlink.c:516
>        [  950.351060] [<ffffffff82db6947>] netlink_dump+0x397/0xac0
> net/netlink/af_netlink.c:2110
>        [  950.351060] [<ffffffff82db99b1>]
> __netlink_dump_start+0x501/0x770 net/netlink/af_netlink.c:2200
>        [  950.351060] [<ffffffff82dc2cb8>]
> genl_family_rcv_msg+0xad8/0xc80 net/netlink/genetlink.c:584
>        [  950.351060] [<ffffffff82dc3016>] genl_rcv_msg+0x1b6/0x270
> net/netlink/genetlink.c:658
>        [  950.351060] [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0
> net/netlink/af_netlink.c:2281
>        [  950.351060] [<ffffffff82dc21c8>] genl_rcv+0x28/0x40
> net/netlink/genetlink.c:669
>        [  950.351060] [<     inline     >] netlink_unicast_kernel
> net/netlink/af_netlink.c:1214
>        [  950.351060] [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880
> net/netlink/af_netlink.c:1240
>        [  950.351060] [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0
> net/netlink/af_netlink.c:1786
>        [  950.351060] [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>        [  950.351060] [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110
> net/socket.c:616
>        [  950.351060] [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0
> net/socket.c:814
>        [  950.351060] [<     inline     >] new_sync_write fs/read_write.c:499
>        [  950.351060] [<ffffffff8151bd44>] __vfs_write+0x334/0x570
> fs/read_write.c:512
>        [  950.351060] [<ffffffff8151f85b>] vfs_write+0x17b/0x500
> fs/read_write.c:560
>        [  950.351060] [<     inline     >] SYSC_write fs/read_write.c:607
>        [  950.351060] [<ffffffff81523184>] SyS_write+0xd4/0x1a0
> fs/read_write.c:599
>        [  950.351060] [<ffffffff83fc0281>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> :
>        [  950.351060] [<ffffffff8120c52e>] lock_acquire+0x17e/0x340
> kernel/locking/lockdep.c:3746
>        [  950.351060] [<     inline     >] __mutex_lock_common
> kernel/locking/mutex.c:521
>        [  950.351060] [<ffffffff83fb7221>]
> mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>        [  950.351060] [<ffffffff82db95aa>]
> __netlink_dump_start+0xfa/0x770 net/netlink/af_netlink.c:2170
>        [  950.351060] [<     inline     >] netlink_dump_start
> include/linux/netlink.h:165
>        [  950.351060] [<ffffffff82e19309>]
> ctnetlink_stat_ct_cpu+0xd9/0x130
> net/netfilter/nf_conntrack_netlink.c:2045
>        [  950.351060] [<ffffffff82dd1d80>]
> nfnetlink_rcv_msg+0xa10/0xc10 net/netfilter/nfnetlink.c:212
>        [  950.351060] [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0
> net/netlink/af_netlink.c:2281
>        [  950.351060] [<ffffffff82dd07e8>] nfnetlink_rcv+0x848/0x1170
> net/netfilter/nfnetlink.c:474
>        [  950.351060] [<     inline     >] netlink_unicast_kernel
> net/netlink/af_netlink.c:1214
>        [  950.351060] [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880
> net/netlink/af_netlink.c:1240
>        [  950.351060] [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0
> net/netlink/af_netlink.c:1786
>        [  950.351060] [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>        [  950.351060] [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110
> net/socket.c:616
>        [  950.351060] [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0
> net/socket.c:814
>        [  950.351060] [<     inline     >] new_sync_write fs/read_write.c:499
>        [  950.351060] [<ffffffff8151bd44>] __vfs_write+0x334/0x570
> fs/read_write.c:512
>        [  950.351060] [<ffffffff8151f85b>] vfs_write+0x17b/0x500
> fs/read_write.c:560
>        [  950.351060] [<     inline     >] SYSC_write fs/read_write.c:607
>        [  950.351060] [<ffffffff81523184>] SyS_write+0xd4/0x1a0
> fs/read_write.c:599
>        [  950.351060] [<ffffffff83fc0281>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> :
>        [  950.351060] [<     inline     >] check_prev_add
> kernel/locking/lockdep.c:1829
>        [  950.351060] [<     inline     >] check_prevs_add
> kernel/locking/lockdep.c:1939
>        [  950.351060] [<     inline     >] validate_chain
> kernel/locking/lockdep.c:2266
>        [  950.351060] [<ffffffff8120b0ca>]
> __lock_acquire+0x2b4a/0x3450 kernel/locking/lockdep.c:3335
>        [  950.351060] [<ffffffff8120c52e>] lock_acquire+0x17e/0x340
> kernel/locking/lockdep.c:3746
>        [  950.351060] [<     inline     >] __mutex_lock_common
> kernel/locking/mutex.c:521
>        [  950.351060] [<ffffffff83fb7221>]
> mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>        [  950.351060] [<ffffffff82dcf798>] nfnl_lock+0x28/0x30
> net/netfilter/nfnetlink.c:61
>        [  950.351060] [<ffffffff82e847bf>]
> nf_tables_netdev_event+0x14f/0x590
> net/netfilter/nf_tables_netdev.c:122
>        [  950.351060] [<ffffffff8117c131>]
> notifier_call_chain+0x91/0x1a0 kernel/notifier.c:93
>        [  950.351060] [<     inline     >] __raw_notifier_call_chain
> kernel/notifier.c:394
>        [  950.351060] [<ffffffff8117c2bd>]
> raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
>        [  950.351060] [<ffffffff82bc3851>]
> call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1645
>        [  950.351060] [<     inline     >] call_netdevice_notifiers
> net/core/dev.c:1661
>        [  950.351060] [<ffffffff82be77c7>] dev_change_name+0x5d7/0x920
> net/core/dev.c:1204
>        [  950.351060] [<ffffffff82c171dd>] do_setlink+0x83d/0x30d0
> net/core/rtnetlink.c:1993
>        [  950.351060] [<ffffffff82c19ce0>] rtnl_setlink+0x270/0x330
> net/core/rtnetlink.c:2231
>        [  950.351060] [<ffffffff82c254a4>]
> rtnetlink_rcv_msg+0x274/0x700 net/core/rtnetlink.c:4027
>        [  950.351060] [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0
> net/netlink/af_netlink.c:2281
>        [  950.351060] [<ffffffff82c15f0a>] rtnetlink_rcv+0x2a/0x40
> net/core/rtnetlink.c:4033
>        [  950.351060] [<     inline     >] netlink_unicast_kernel
> net/netlink/af_netlink.c:1214
>        [  950.351060] [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880
> net/netlink/af_netlink.c:1240
>        [  950.351060] [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0
> net/netlink/af_netlink.c:1786
>        [  950.351060] [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>        [  950.351060] [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110
> net/socket.c:616
>        [  950.351060] [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0
> net/socket.c:814
>        [  950.351060] [<     inline     >] new_sync_write fs/read_write.c:499
>        [  950.351060] [<ffffffff8151bd44>] __vfs_write+0x334/0x570
> fs/read_write.c:512
>        [  950.351060] [<ffffffff8151f85b>] vfs_write+0x17b/0x500
> fs/read_write.c:560
>        [  950.351060] [<     inline     >] SYSC_write fs/read_write.c:607
>        [  950.351060] [<ffffffff81523184>] SyS_write+0xd4/0x1a0
> fs/read_write.c:599
>        [  950.351060] [<ffffffff81006465>] do_syscall_64+0x195/0x490
> arch/x86/entry/common.c:280
>        [  950.351060] [<ffffffff83fc0349>] return_from_SYSCALL_64+0x0/0x7a
>
> other info that might help us debug this:
>
> Chain exists of:
>
>
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock([  950.351060] rtnl_mutex
> );
>                                lock([  950.351060] genl_mutex
> );
>                                lock([  950.351060] rtnl_mutex
> );
>   lock([  950.351060] &table[i].mutex
> );
>
>  *** DEADLOCK ***
>
> 1 lock held by syz-executor/25526:
>  #0: [  950.351060]  (
>
> stack backtrace:
> CPU: 0 PID: 25526 Comm: syz-executor Not tainted 4.9.0-rc3+ #344
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff8800692b6d30 ffffffff81b46934 ffffffff859bdf80 ffffffff859de740
>  ffffffff859b3870 1ffffffff0bade82 ffff8800692b6d80 ffffffff81204cfd
>  ffffffff859b3870 ffff88006859cca0 000000006859c480 ffff88006859cca0
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff81204cfd>] print_circular_bug+0x28d/0x350
> kernel/locking/lockdep.c:1202
>  [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
>  [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1939
>  [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
>  [<ffffffff8120b0ca>] __lock_acquire+0x2b4a/0x3450 kernel/locking/lockdep.c:3335
>  [<ffffffff8120c52e>] lock_acquire+0x17e/0x340 kernel/locking/lockdep.c:3746
>  [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
>  [<ffffffff83fb7221>] mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>  [<ffffffff82dcf798>] nfnl_lock+0x28/0x30 net/netfilter/nfnetlink.c:61
>  [<ffffffff82e847bf>] nf_tables_netdev_event+0x14f/0x590
> net/netfilter/nf_tables_netdev.c:122
>  [<ffffffff8117c131>] notifier_call_chain+0x91/0x1a0 kernel/notifier.c:93
>  [<     inline     >] __raw_notifier_call_chain kernel/notifier.c:394
>  [<ffffffff8117c2bd>] raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
>  [<ffffffff82bc3851>] call_netdevice_notifiers_info+0x51/0x90
> net/core/dev.c:1645
>  [<     inline     >] call_netdevice_notifiers net/core/dev.c:1661
>  [<ffffffff82be77c7>] dev_change_name+0x5d7/0x920 net/core/dev.c:1204
>  [<ffffffff82c171dd>] do_setlink+0x83d/0x30d0 net/core/rtnetlink.c:1993
>  [<ffffffff82c19ce0>] rtnl_setlink+0x270/0x330 net/core/rtnetlink.c:2231
>  [<ffffffff82c254a4>] rtnetlink_rcv_msg+0x274/0x700 net/core/rtnetlink.c:4027
>  [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
>  [<ffffffff82c15f0a>] rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4033
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
>  [<ffffffff81006465>] do_syscall_64+0x195/0x490 arch/x86/entry/common.c:280
>  [<ffffffff83fc0349>] entry_SYSCALL64_slow_path+0x25/0x25
>
> On Thu, Nov 3, 2016 at 4:08 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi Eric,
>>
>> This fixes the second report, the first one is still there.
>> Apparently these are two separate issues.
>>
>> For the second one:
>> Tested-by: Andrey Konovalov <andreyknvl@google.com>
>>
>> Thanks for the fix!
>>
>> On Thu, Nov 3, 2016 at 3:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Thu, 2016-11-03 at 03:36 +0100, Andrey Konovalov wrote:
>>>> On Thu, Nov 3, 2016 at 1:15 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>> > On Wed, Oct 19, 2016 at 4:13 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>> >> Hi,
>>>> >>
>>>> >> I've got the following error report while running the syzkaller fuzzer:
>>>> >>
>>>> >> kasan: CONFIG_KASAN_INLINE enabled
>>>> >> kasan: GPF could be caused by NULL-ptr deref or user memory access
>>>> >> general protection fault: 0000 [#1] SMP KASAN
>>>> >> Modules linked in:
>>>> >> CPU: 1 PID: 3933 Comm: syz-executor Not tainted 4.9.0-rc1+ #230
>>>> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>> >> task: ffff88006b79d800 task.stack: ffff88006bbc0000
>>>> >> RIP: 0010:[<ffffffff8120872d>]  [<ffffffff8120872d>]
>>>> >> __lock_acquire+0x12d/0x3450 kernel/locking/lockdep.c:3221
>>>> >> RSP: 0018:ffff88006bbc7420  EFLAGS: 00010006
>>>> >> RAX: 0000000000000046 RBX: dffffc0000000000 RCX: 0000000000000000
>>>> >> RDX: 000000000000000c RSI: 0000000000000000 RDI: 0000000000000003
>>>> >> RBP: ffff88006bbc75c0 R08: 0000000000000001 R09: 0000000000000000
>>>> >> R10: 0000000000000000 R11: ffffffff85f42240 R12: ffff88006b79d800
>>>> >> R13: ffffffff84bfe4e0 R14: 0000000000000001 R15: 0000000000000060
>>>> >> FS:  00007fd9c41cc700(0000) GS:ffff88006cd00000(0000) knlGS:0000000000000000
>>>> >> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> >> CR2: 0000000000451f80 CR3: 00000000638f0000 CR4: 00000000000006e0
>>>> >> Stack:
>>>> >>  0000000000000000 ffff88006bbc0000 ffff88006bbc8000 0000000000000000
>>>> >>  0000000000000002 ffff88006b79d800 0000000000000000 ffff88006bbc7f48
>>>> >>  ffffffff852adc60 0000000000000000 ffffffff852adc64 1ffffffff0b40135
>>>> >> Call Trace:
>>>> >>  [<ffffffff8120c5ae>] lock_acquire+0x17e/0x340 kernel/locking/lockdep.c:3746
>>>> >>  [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
>>>> >>  [<ffffffff83fb6fe1>] mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>>>> >>  [<ffffffff82db6fd0>] netlink_dump+0x50/0xac0 net/netlink/af_netlink.c:2067
>>>> >>  [<ffffffff82dba381>] __netlink_dump_start+0x501/0x770
>>>> >> net/netlink/af_netlink.c:2200
>>>> >>  [<ffffffff82dc35b2>] genl_family_rcv_msg+0xa02/0xc80
>>>> >> net/netlink/genetlink.c:595
>>>> >>  [<ffffffff82dc39e6>] genl_rcv_msg+0x1b6/0x270 net/netlink/genetlink.c:658
>>>> >>  [<ffffffff82dc1a70>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
>>>> >>  [<ffffffff82dc2b98>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
>>>> >>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
>>>> >>  [<ffffffff82dc0329>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
>>>> >>  [<ffffffff82dc0fb7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>>>> >>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>>>> >>  [<ffffffff82b7075c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>>>> >>  [<ffffffff82b709c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>>>> >>  [<     inline     >] new_sync_write fs/read_write.c:499
>>>> >>  [<ffffffff8151c944>] __vfs_write+0x334/0x570 fs/read_write.c:512
>>>> >>  [<ffffffff8152045b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>>>> >>  [<     inline     >] SYSC_write fs/read_write.c:607
>>>> >>  [<ffffffff81523d84>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>>>> >>  [<ffffffff83fc0141>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>> >> arch/x86/entry/entry_64.S:209
>>>> >> Code: 0f 1f 44 00 00 f6 c4 02 0f 85 24 0a 00 00 44 8b 35 c9 61 8b 03
>>>> >> 45 85 f6 74 2c 4c 89 fa 48 bb 00 00 00 00 00 fc ff df 48 c1 ea 03 <80>
>>>> >> 3c 1a 00 0f 85 04 2f 00 00 49 81 3f a0 dc 2a 85 41 be 00 00
>>>> >> RIP  [<ffffffff8120872d>] __lock_acquire+0x12d/0x3450
>>>> >> kernel/locking/lockdep.c:3221
>>>> >>  RSP <ffff88006bbc7420>
>>>> >> ---[ end trace 685b3c182bf7f25c ]---
>>>> >>
>>>> >> The reproducer is attached.
>>>> >>
>>>> >> On commit 1a1891d762d6e64daf07b5be4817e3fbb29e3c59 (Oct 18).
>>>> >
>>>> > (Adding more maintainers)
>>>> >
>>>> > Still seeing this on 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
>>>>
>>>> Here is another report that might be related:
>>>>
>>>> =====================================
>>>> [ BUG: bad unlock balance detected! ]
>>>> 4.9.0-rc3+ #336 Not tainted
>>>> -------------------------------------
>>>> syz-executor/4018 is trying to release lock ([   36.220068] nl_table_lock
>>>> ) at:
>>>> [<ffffffff82dc8683>] netlink_diag_dump+0x1a3/0x250 net/netlink/diag.c:182
>>>> but there are no more locks to release!
>>>>
>>>> other info that might help us debug this:
>>>> 3 locks held by syz-executor/4018:
>>>>  #0: [   36.220068]  (
>>>> sock_diag_mutex[   36.220068] ){+.+.+.}
>>>> , at: [   36.220068] [<ffffffff82c3873b>] sock_diag_rcv+0x1b/0x40
>>>>  #1: [   36.220068]  (
>>>> sock_diag_table_mutex[   36.220068] ){+.+.+.}
>>>> , at: [   36.220068] [<ffffffff82c38e00>] sock_diag_rcv_msg+0x140/0x3a0
>>>>  #2: [   36.220068]  (
>>>> nlk->cb_mutex[   36.220068] ){+.+.+.}
>>>> , at: [   36.220068] [<ffffffff82db6600>] netlink_dump+0x50/0xac0
>>>>
>>>> stack backtrace:
>>>> CPU: 1 PID: 4018 Comm: syz-executor Not tainted 4.9.0-rc3+ #336
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>  ffff8800645df688 ffffffff81b46934 ffffffff84eb3e78 ffff88006ad85800
>>>>  ffffffff82dc8683 ffffffff84eb3e78 ffff8800645df6b8 ffffffff812043ca
>>>>  dffffc0000000000 ffff88006ad85ff8 ffff88006ad85fd0 00000000ffffffff
>>>> Call Trace:
>>>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>>>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>>>  [<ffffffff812043ca>] print_unlock_imbalance_bug+0x17a/0x1a0
>>>> kernel/locking/lockdep.c:3388
>>>>  [<     inline     >] __lock_release kernel/locking/lockdep.c:3512
>>>>  [<ffffffff8120cfd8>] lock_release+0x8e8/0xc60 kernel/locking/lockdep.c:3765
>>>>  [<     inline     >] __raw_read_unlock ./include/linux/rwlock_api_smp.h:225
>>>>  [<ffffffff83fc001a>] _raw_read_unlock+0x1a/0x30 kernel/locking/spinlock.c:255
>>>>  [<ffffffff82dc8683>] netlink_diag_dump+0x1a3/0x250 net/netlink/diag.c:182
>>>>  [<ffffffff82db6947>] netlink_dump+0x397/0xac0 net/netlink/af_netlink.c:2110
>>>>  [<ffffffff82db99b1>] __netlink_dump_start+0x501/0x770
>>>> net/netlink/af_netlink.c:2200
>>>>  [<     inline     >] netlink_dump_start ./include/linux/netlink.h:165
>>>>  [<ffffffff82dc75d1>] netlink_diag_handler_dump+0x191/0x220
>>>> net/netlink/diag.c:218
>>>>  [<     inline     >] __sock_diag_cmd net/core/sock_diag.c:239
>>>>  [<ffffffff82c38fd6>] sock_diag_rcv_msg+0x316/0x3a0 net/core/sock_diag.c:270
>>>>  [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
>>>>  [<ffffffff82c3874a>] sock_diag_rcv+0x2a/0x40 net/core/sock_diag.c:281
>>>>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
>>>>  [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
>>>>  [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>>>>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>>>>  [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>>>>  [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>>>>  [<     inline     >] new_sync_write fs/read_write.c:499
>>>>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>>>>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>>>>  [<     inline     >] SYSC_write fs/read_write.c:607
>>>>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>>>>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>> arch/x86/entry/entry_64.S:209
>>>> ------------[ cut here ]------------
>>>> WARNING: CPU: 1 PID: 4018 at net/core/skbuff.c:654[<        none
>>>>  >] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
>>>> Modules linked in:
>>>> CPU: 1 PID: 4018 Comm: syz-executor Not tainted 4.9.0-rc3+ #336
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>  ffff8800645df920 ffffffff81b46934 0000000000000000 0000000000000000
>>>>  ffffffff84401fa0 0000000000000000 ffff8800645df968 ffffffff811112f7
>>>>  ffffffff83fb92f2 ffff88000000028e ffffffff84401fa0 000000000000028e
>>>> Call Trace:
>>>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>>>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>>>  [<ffffffff811112f7>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>>>>  [<ffffffff8111150c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
>>>>  [<ffffffff82b885ea>] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
>>>>  [<ffffffff82b91815>] skb_release_all+0x15/0x60 net/core/skbuff.c:668
>>>>  [<     inline     >] __kfree_skb net/core/skbuff.c:684
>>>>  [<ffffffff82ba0175>] consume_skb+0x115/0x2e0 net/core/skbuff.c:757
>>>>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1215
>>>>  [<ffffffff82dbf961>] netlink_unicast+0x5b1/0x880 net/netlink/af_netlink.c:1240
>>>>  [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>>>>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>>>>  [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>>>>  [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>>>>  [<     inline     >] new_sync_write fs/read_write.c:499
>>>>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>>>>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>>>>  [<     inline     >] SYSC_write fs/read_write.c:607
>>>>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>>>>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>> arch/x86/entry/entry_64.S:209
>>>> ---[ end trace bb9fa7cf182d59a5 ]---
>>>> BUG: scheduling while atomic: syz-executor/4018/0x7fffffff
>>>> INFO: lockdep is turned off.
>>>> Modules linked in:
>>>> CPU: 1 PID: 4018 Comm: syz-executor Tainted: G        W       4.9.0-rc3+ #336
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>  ffff8800645dfe28 ffffffff81b46934 dffffc0000000000 000000007fffffff
>>>>  00000000000214c0 0000000000000001 ffff8800645dfe48 ffffffff8119113a
>>>>  ffff88006cd214c0 0000000000000000 ffff8800645dfec8 ffffffff83fb030a
>>>> Call Trace:
>>>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>>>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>>>  [<ffffffff8119113a>] __schedule_bug+0xfa/0x140 kernel/sched/core.c:3230
>>>>  [<     inline     >] schedule_debug kernel/sched/core.c:3245
>>>>  [<ffffffff83fb030a>] __schedule+0xfda/0x1ab0 kernel/sched/core.c:3345
>>>>  [<ffffffff83fb0e70>] schedule+0x90/0x1b0 kernel/sched/core.c:3457
>>>>  [<ffffffff810039e9>] exit_to_usermode_loop+0xc9/0x130
>>>> arch/x86/entry/common.c:149
>>>>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>>>>  [<ffffffff81006298>] syscall_return_slowpath+0x1a8/0x1e0
>>>> arch/x86/entry/common.c:259
>>>>  [<ffffffff83fc04a2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
>>>> arch/x86/entry/entry_64.S:244
>>>> NOHZ: local_softirq_pending 202
>>>> ------------[ cut here ]------------
>>>> WARNING: CPU: 1 PID: 4018 at net/core/skbuff.c:654[<        none
>>>>  >] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
>>>> Modules linked in:[   36.328353] CPU: 1 PID: 4018 Comm: syz-executor
>>>> Tainted: G        W       4.9.0-rc3+ #336
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>  ffff8800645df920 ffffffff81b46934 0000000000000000 0000000000000000
>>>>  ffffffff84401fa0 0000000000000000 ffff8800645df968 ffffffff811112f7
>>>>  ffffffff83fb92f2 ffff88000000028e ffffffff84401fa0 000000000000028e
>>>> Call Trace:
>>>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>>>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>>>  [<ffffffff811112f7>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>>>>  [<ffffffff8111150c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
>>>>  [<ffffffff82b885ea>] skb_release_head_state+0x1ca/0x240 net/core/skbuff.c:654
>>>>  [<ffffffff82b91815>] skb_release_all+0x15/0x60 net/core/skbuff.c:668
>>>>  [<     inline     >] __kfree_skb net/core/skbuff.c:684
>>>>  [<ffffffff82ba0175>] consume_skb+0x115/0x2e0 net/core/skbuff.c:757
>>>>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1215
>>>>  [<ffffffff82dbf961>] netlink_unicast+0x5b1/0x880 net/netlink/af_netlink.c:1240
>>>>  [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>>>>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>>>>  [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>>>>  [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>>>>  [<     inline     >] new_sync_write fs/read_write.c:499
>>>>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>>>>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>>>>  [<     inline     >] SYSC_write fs/read_write.c:607
>>>>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>>>>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>> arch/x86/entry/entry_64.S:209
>>>> ---[ end trace bb9fa7cf182d59a6 ]---
>>>> BUG: sleeping function called from invalid context at
>>>> ./include/linux/freezer.h:56
>>>> in_atomic(): 1, irqs_disabled(): 0, pid: 4018, name: syz-executor
>>>> INFO: lockdep is turned off.
>>>> CPU: 1 PID: 4018 Comm: syz-executor Tainted: G        W       4.9.0-rc3+ #336
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>  ffff8800645dfbb0 ffffffff81b46934 ffff88006ad85800 ffff8800645d8000
>>>>  ffff88006ad85800 0000000000000000 ffff8800645dfbd8 ffffffff81192131
>>>>  ffff88006ad85800 ffffffff8404c140 0000000000000038 ffff8800645dfc18
>>>> Call Trace:
>>>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>>>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>>>  [<ffffffff81192131>] ___might_sleep+0x281/0x3c0 kernel/sched/core.c:7767
>>>>  [<ffffffff81192306>] __might_sleep+0x96/0x1a0 kernel/sched/core.c:7726
>>>>  [<     inline     >] try_to_freeze_unsafe ./include/linux/freezer.h:56
>>>>  [<     inline     >] try_to_freeze ./include/linux/freezer.h:66
>>>>  [<ffffffff81143849>] get_signal+0x129/0x15a0 kernel/signal.c:2147
>>>>  [<ffffffff81054aad>] do_signal+0x8d/0x1a30 arch/x86/kernel/signal.c:807
>>>>  [<ffffffff81003a05>] exit_to_usermode_loop+0xe5/0x130
>>>> arch/x86/entry/common.c:156
>>>>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>>>>  [<ffffffff81006298>] syscall_return_slowpath+0x1a8/0x1e0
>>>> arch/x86/entry/common.c:259
>>>>  [<ffffffff83fc04a2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
>>>> arch/x86/entry/entry_64.S:244
>>>> Kernel panic - not syncing: Aiee, killing interrupt handler!
>>>> CPU: 1 PID: 4018 Comm: syz-executor Tainted: G        W       4.9.0-rc3+ #336
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>>>  ffff8800645df998 ffffffff81b46934 0000000000000003 dffffc0000000000
>>>>  dffffc0000000000 ffff8800645dfa04 ffff8800645dfa60 ffffffff8140bf7a
>>>>  0000000041b58ab3 ffffffff84797a7d ffffffff8140bdbe ffffffff00000000
>>>> Call Trace:
>>>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>>>  [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>>>  [<ffffffff8140bf7a>] panic+0x1bc/0x39d kernel/panic.c:179
>>>>  [<ffffffff8111cfd8>] do_exit+0x1b48/0x2ac0 kernel/exit.c:740
>>>>  [<ffffffff811222be>] do_group_exit+0x10e/0x340 kernel/exit.c:931
>>>>  [<ffffffff81143d54>] get_signal+0x634/0x15a0 kernel/signal.c:2307
>>>>  [<ffffffff81054aad>] do_signal+0x8d/0x1a30 arch/x86/kernel/signal.c:807
>>>>  [<ffffffff81003a05>] exit_to_usermode_loop+0xe5/0x130
>>>> arch/x86/entry/common.c:156
>>>>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>>>>  [<ffffffff81006298>] syscall_return_slowpath+0x1a8/0x1e0
>>>> arch/x86/entry/common.c:259
>>>>  [<ffffffff83fc04a2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
>>>> arch/x86/entry/entry_64.S:244
>>>> Kernel Offset: disabled
>>>> ---[ end Kernel panic - not syncing: Aiee, killing interrupt handler!
>>>
>>>
>>> This is probably a leftover after commit
>>> ad202074320cd75b31b8cdb58cca0d4ef6aaea8a
>>> ("netlink: Use rhashtable walk interface in diag dump")
>>>
>>> Please try this trivial fix :
>>>
>>> diff --git a/net/netlink/diag.c b/net/netlink/diag.c
>>> index b2f0e986a6f4..a5546249fb10 100644
>>> --- a/net/netlink/diag.c
>>> +++ b/net/netlink/diag.c
>>> @@ -178,11 +178,8 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
>>>                 }
>>>                 cb->args[1] = i;
>>>         } else {
>>> -               if (req->sdiag_protocol >= MAX_LINKS) {
>>> -                       read_unlock(&nl_table_lock);
>>> -                       rcu_read_unlock();
>>> +               if (req->sdiag_protocol >= MAX_LINKS)
>>>                         return -ENOENT;
>>> -               }
>>>
>>>                 err = __netlink_diag_dump(skb, cb, req->sdiag_protocol, s_num);
>>>         }
>>>
>>>




ping

I am seeing thousands of these deadlock reports on commit
623898671c8eb05639e746e6d84cffa281616438:


[ INFO: possible circular locking dependency detected ]
4.9.0-rc5+ #54 Not tainted
-------------------------------------------------------
syz-executor/12883 is trying to acquire lock:
 ([  450.846039] rtnl_mutex
[<ffffffff86b3d34c>] rtnl_lock+0x1c/0x20 net/core/rtnetlink.c:70

but task is already holding lock:
 ([  450.846039] genl_mutex
[<     inline     >] genl_lock net/netlink/genetlink.c:31
[<ffffffff86cb5ab6>] genl_lock_dumpit+0x46/0xa0 net/netlink/genetlink.c:518

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

:
       [  450.853245] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2266
       [  450.853245] [<ffffffff81569546>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3335
       [  450.853245] [<ffffffff8156b642>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3746
       [  450.853245] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  450.853245] [<ffffffff88139aff>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  450.862462] [<     inline     >] genl_lock net/netlink/genetlink.c:31
       [  450.862462] [<ffffffff86cb5ab6>] genl_lock_dumpit+0x46/0xa0
net/netlink/genetlink.c:518
       [  450.862462] [<ffffffff86ca8256>] netlink_dump+0x576/0xd70
net/netlink/af_netlink.c:2110
       [  450.862462] [<ffffffff86caca1a>]
__netlink_dump_start+0x4ea/0x760 net/netlink/af_netlink.c:2200
       [  450.862462] [<ffffffff86cb7199>]
genl_family_rcv_msg+0xdc9/0x1070 net/netlink/genetlink.c:586
       [  450.866287] [<ffffffff86cb75f0>] genl_rcv_msg+0x1b0/0x260
net/netlink/genetlink.c:660
       [  450.867554] [<ffffffff86cb51e0>] netlink_rcv_skb+0x2b0/0x390
net/netlink/af_netlink.c:2281
       [  450.870045] [<ffffffff86cb63bd>] genl_rcv+0x2d/0x40
net/netlink/genetlink.c:671
       [  450.870045] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1214
       [  450.870045] [<ffffffff86cb3a14>] netlink_unicast+0x514/0x730
net/netlink/af_netlink.c:1240
       [  450.870045] [<ffffffff86cb46d4>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1786
       [  450.870045] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  450.870045] [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  450.870045] [<ffffffff86a6d8bb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  450.870045] [<     inline     >] new_sync_write fs/read_write.c:499
       [  450.870045] [<ffffffff81a6f24e>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  450.870045] [<ffffffff81a70cf5>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  450.870045] [<     inline     >] SYSC_write fs/read_write.c:607
       [  450.870045] [<ffffffff81a75180>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  450.870045] [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6

:
       [  450.870045] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2266
       [  450.870045] [<ffffffff81569546>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3335
       [  450.870045] [<ffffffff8156b642>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3746
       [  450.870045] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  450.870045] [<ffffffff88139aff>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  450.870045] [<ffffffff86cac629>]
__netlink_dump_start+0xf9/0x760 net/netlink/af_netlink.c:2170
       [  450.870045] [<     inline     >] netlink_dump_start
include/linux/netlink.h:165
       [  450.870045] [<ffffffff86d09dfc>]
ctnetlink_get_conntrack+0x71c/0xa90
net/netfilter/nf_conntrack_netlink.c:1205
       [  450.870045] [<ffffffff86cc7c3e>]
nfnetlink_rcv_msg+0x9be/0xd60 net/netfilter/nfnetlink.c:212
       [  450.886719] [<ffffffff86cb51e0>] netlink_rcv_skb+0x2b0/0x390
net/netlink/af_netlink.c:2281
       [  450.886719] [<ffffffff86cc666c>] nfnetlink_rcv+0x7cc/0x10c0
net/netfilter/nfnetlink.c:474
       [  450.889046] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1214
       [  450.889046] [<ffffffff86cb3a14>] netlink_unicast+0x514/0x730
net/netlink/af_netlink.c:1240
       [  450.889046] [<ffffffff86cb46d4>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1786
       [  450.889046] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  450.889046] [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  450.889046] [<ffffffff86a6d8bb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  450.889046] [<     inline     >] new_sync_write fs/read_write.c:499
       [  450.889046] [<ffffffff81a6f24e>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  450.894033] [<ffffffff81a70cf5>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  450.894033] [<     inline     >] SYSC_write fs/read_write.c:607
       [  450.894033] [<ffffffff81a75180>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  450.894033] [<ffffffff81009a24>] do_syscall_64+0x2f4/0x940
arch/x86/entry/common.c:280
       [  450.894033] [<ffffffff88149e8d>] return_from_SYSCALL_64+0x0/0x7a

:
       [  450.900551] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2266
       [  450.900551] [<ffffffff81569546>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3335
       [  450.900551] [<ffffffff8156b642>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3746
       [  450.900551] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  450.900551] [<ffffffff88139aff>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  450.900551] [<ffffffff86cc534d>] nfnl_lock+0x2d/0x30
net/netfilter/nfnetlink.c:61
       [  450.900551] [<ffffffff86d62e51>]
nf_tables_netdev_event+0x1f1/0x720
net/netfilter/nf_tables_netdev.c:122
       [  450.900551] [<ffffffff814908ea>]
notifier_call_chain+0x14a/0x2f0 kernel/notifier.c:93
       [  450.900551] [<     inline     >] __raw_notifier_call_chain
kernel/notifier.c:394
       [  450.900551] [<ffffffff81490b12>]
raw_notifier_call_chain+0x32/0x40 kernel/notifier.c:401
       [  450.900551] [<ffffffff86adb746>]
call_netdevice_notifiers_info+0x56/0x90 net/core/dev.c:1645
       [  450.900551] [<     inline     >] call_netdevice_notifiers
net/core/dev.c:1661
       [  450.900551] [<ffffffff86aef59d>]
rollback_registered_many+0x73d/0xba0 net/core/dev.c:6759
       [  450.900551] [<ffffffff86aefaae>]
rollback_registered+0xae/0x100 net/core/dev.c:6800
       [  450.900551] [<ffffffff86aefb86>]
unregister_netdevice_queue+0x86/0x140 net/core/dev.c:7787
       [  450.900551] [<     inline     >] unregister_netdevice
include/linux/netdevice.h:2455
       [  450.900551] [<ffffffff8490cc36>] __tun_detach+0xc66/0xea0
drivers/net/tun.c:567
       [  450.900551] [<     inline     >] tun_detach drivers/net/tun.c:578
       [  450.900551] [<ffffffff8490ceb9>] tun_chr_close+0x49/0x60
drivers/net/tun.c:2352
       [  450.900551] [<ffffffff81a7701e>] __fput+0x34e/0x910
fs/file_table.c:208
       [  450.900551] [<ffffffff81a7766a>] ____fput+0x1a/0x20
fs/file_table.c:244
       [  450.900551] [<ffffffff81483bb0>] task_work_run+0x1a0/0x280
kernel/task_work.c:116
       [  450.900551] [<     inline     >] exit_task_work
include/linux/task_work.h:21
       [  450.900551] [<ffffffff8141297a>] do_exit+0x183a/0x2640
kernel/exit.c:828
       [  450.900551] [<ffffffff8141393e>] do_group_exit+0x14e/0x420
kernel/exit.c:931
       [  450.900551] [<ffffffff81442ad3>] get_signal+0x663/0x1880
kernel/signal.c:2307
       [  450.900551] [<ffffffff81239b45>] do_signal+0xc5/0x2190
arch/x86/kernel/signal.c:807
       [  450.900551] [<ffffffff8100666a>]
exit_to_usermode_loop+0x1ea/0x2d0 arch/x86/entry/common.c:156
       [  450.900551] [<     inline     >] prepare_exit_to_usermode
arch/x86/entry/common.c:190
       [  450.900551] [<ffffffff81009693>]
syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
       [  450.900551] [<ffffffff88149e66>] entry_SYSCALL_64_fastpath+0xc4/0xc6

:
       [  450.900551] [<     inline     >] check_prev_add
kernel/locking/lockdep.c:1829
       [  450.900551] [<ffffffff8156306b>]
check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1939
       [  450.900551] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2266
       [  450.900551] [<ffffffff81569546>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3335
       [  450.900551] [<ffffffff8156b642>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3746
       [  450.900551] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  450.900551] [<ffffffff88139aff>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  450.900551] [<ffffffff86b3d34c>] rtnl_lock+0x1c/0x20
net/core/rtnetlink.c:70
       [  450.900551] [<ffffffff87efd7c7>]
ieee802154_nl_fill_phy.isra.6+0x127/0x690 net/ieee802154/nl-phy.c:53
       [  450.900551] [<ffffffff87efde82>]
ieee802154_dump_phy_iter+0x152/0x200 net/ieee802154/nl-phy.c:137
       [  450.900551] [<ffffffff87eff49f>] wpan_phy_iter+0x5f/0x80
net/ieee802154/core.c:65
       [  450.900551] [<ffffffff8416f508>]
class_for_each_device+0x138/0x240 drivers/base/class.c:382
       [  450.900551] [<ffffffff87eff690>]
wpan_phy_for_each+0xc0/0x110 net/ieee802154/core.c:76
       [  450.900551] [<ffffffff87efe383>]
ieee802154_dump_phy+0x153/0x2a0 net/ieee802154/nl-phy.c:162
       [  450.900551] [<ffffffff86cb5add>] genl_lock_dumpit+0x6d/0xa0
net/netlink/genetlink.c:519
       [  450.900551] [<ffffffff86ca8256>] netlink_dump+0x576/0xd70
net/netlink/af_netlink.c:2110
       [  450.900551] [<ffffffff86caca1a>]
__netlink_dump_start+0x4ea/0x760 net/netlink/af_netlink.c:2200
       [  450.900551] [<ffffffff86cb7199>]
genl_family_rcv_msg+0xdc9/0x1070 net/netlink/genetlink.c:586
       [  450.900551] [<ffffffff86cb75f0>] genl_rcv_msg+0x1b0/0x260
net/netlink/genetlink.c:660
       [  450.900551] [<ffffffff86cb51e0>] netlink_rcv_skb+0x2b0/0x390
net/netlink/af_netlink.c:2281
       [  450.900551] [<ffffffff86cb63bd>] genl_rcv+0x2d/0x40
net/netlink/genetlink.c:671
       [  450.900551] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1214
       [  450.900551] [<ffffffff86cb3a14>] netlink_unicast+0x514/0x730
net/netlink/af_netlink.c:1240
       [  450.900551] [<ffffffff86cb46d4>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1786
       [  450.900551] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  450.900551] [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  450.900551] [<ffffffff86a6d8bb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  450.900551] [<     inline     >] new_sync_write fs/read_write.c:499
       [  450.900551] [<ffffffff81a6f24e>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  450.900551] [<ffffffff81a70cf5>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  450.900551] [<     inline     >] SYSC_write fs/read_write.c:607
       [  450.900551] [<ffffffff81a75180>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  450.900551] [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6

other info that might help us debug this:

Chain exists of:


 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock([  450.958731] genl_mutex
);
                               lock([  450.958731] nlk->cb_mutex
QAT: Invalid ioctl
);
                               lock([  450.958731] genl_mutex
);
  lock([  450.958731] rtnl_mutex
);

 *** DEADLOCK ***

QAT: Invalid ioctl
3 locks held by syz-executor/12883:
 #0: [  450.958731]  (
 #1: [  450.958731]  (
 #2: [  450.958731]  (

stack backtrace:
CPU: 2 PID: 12883 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff880069616088 ffffffff834c2e39 ffffffff00000002 1ffff1000d2c2ba4
 ffffed000d2c2b9c 0000000041b58ab3 ffffffff89575550 ffffffff834c2b4b
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c2e39>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<ffffffff81560c70>] print_circular_bug+0x310/0x3c0
kernel/locking/lockdep.c:1202
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
 [<ffffffff8156306b>] check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1939
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
 [<ffffffff81569546>] __lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3335
 [<ffffffff8156b642>] lock_acquire+0x2a2/0x790 kernel/locking/lockdep.c:3746
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
 [<ffffffff88139aff>] mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
 [<ffffffff86b3d34c>] rtnl_lock+0x1c/0x20 net/core/rtnetlink.c:70
 [<ffffffff87efd7c7>] ieee802154_nl_fill_phy.isra.6+0x127/0x690
net/ieee802154/nl-phy.c:53
 [<ffffffff87efde82>] ieee802154_dump_phy_iter+0x152/0x200
net/ieee802154/nl-phy.c:137
 [<ffffffff87eff49f>] wpan_phy_iter+0x5f/0x80 net/ieee802154/core.c:65
 [<ffffffff8416f508>] class_for_each_device+0x138/0x240 drivers/base/class.c:382
 [<ffffffff87eff690>] wpan_phy_for_each+0xc0/0x110 net/ieee802154/core.c:76
 [<ffffffff87efe383>] ieee802154_dump_phy+0x153/0x2a0
net/ieee802154/nl-phy.c:162
 [<ffffffff86cb5add>] genl_lock_dumpit+0x6d/0xa0 net/netlink/genetlink.c:519
 [<ffffffff86ca8256>] netlink_dump+0x576/0xd70 net/netlink/af_netlink.c:2110
 [<ffffffff86caca1a>] __netlink_dump_start+0x4ea/0x760
net/netlink/af_netlink.c:2200
 [<ffffffff86cb7199>] genl_family_rcv_msg+0xdc9/0x1070
net/netlink/genetlink.c:586
 [<ffffffff86cb75f0>] genl_rcv_msg+0x1b0/0x260 net/netlink/genetlink.c:660
 [<ffffffff86cb51e0>] netlink_rcv_skb+0x2b0/0x390 net/netlink/af_netlink.c:2281
 [<ffffffff86cb63bd>] genl_rcv+0x2d/0x40 net/netlink/genetlink.c:671
 [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
 [<ffffffff86cb3a14>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1240
 [<ffffffff86cb46d4>] netlink_sendmsg+0xaa4/0xe50 net/netlink/af_netlink.c:1786
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
 [<ffffffff86a6d8bb>] sock_write_iter+0x32b/0x620 net/socket.c:829
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff81a6f24e>] __vfs_write+0x4fe/0x830 fs/read_write.c:512
 [<ffffffff81a70cf5>] vfs_write+0x175/0x4e0 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81a75180>] SyS_write+0x100/0x240 fs/read_write.c:599
 [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
